#!/bin/bash

set -e

# get the name of kubeconfig
read -p 'Name (the name of user, cluster and context): ' name

# create and use a tmp dir
tmpdir="/tmp/kubeconfig/${name}"
mkdir -p ${tmpdir} && cd ${tmpdir}

# create csr and approve it
openssl genrsa -out ${name}.key 2048
openssl req -new -key ${name}.key -out ${name}.csr -subj "/CN=${name}"
cat ${name}.csr | base64 | tr -d "\n" >${name}-base64.csr
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${name}
spec:
  groups:
  - system:authenticated  
  request: $(cat $name-base64.csr)
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 315360000  # ten years
  usages:
  - client auth
EOF
kubectl certificate approve ${name}

# get the certificate for user
kubectl get certificatesigningrequests ${name} -o jsonpath='{ .status.certificate }' | base64 --decode >${name}.crt

# use lb to expose apiserver, and wait for the lb ip
kubectl patch service/kubernetes -n default -p '{"spec":{"type":"LoadBalancer"}}' --type=merge
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' service/kubernetes -n default
lb_ip=$(kubectl get service kubernetes -n default -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -z "${lb_ip}" ]; then
  echo "failed to get the loadbalancer ip of apiserver, please check the service kubernetes:\nkubectl get service kubernetes -n default"
  exit 1
fi

# set cluster and user
kubectl config set-cluster --server=https://${lb_ip}:443 --insecure-skip-tls-verify=true --kubeconfig=${name}.conf
kubectl config set-credentials ${name} --client-key=${name}.key --client-certificate=${name}.crt --embed-certs=true --kubeconfig=${name}.conf

# set context
kubectl config set-context --cluster= --user=${name} --kubeconfig=${name}.conf
kubectl config use-context --kubeconfig=${name}.conf

# grant admin permission
kubectl create clusterrole ${name} --verb="*" --resource="*"
kubectl create clusterrolebinding ${name} --clusterrole=${name} --user=${name}

echo "kubeconfig created successfully, you can copy the kubeconfig below:"
cat ${name}.conf
cd -
rm -rf ${tmpdir}

function kay --description "Add yaml files to kustomization.yaml (kay: kustomize add yaml)"
    for file in *.yaml
        if test $file != "kustomization.yaml"
            kustomize edit add resource $file
        end
    end
end

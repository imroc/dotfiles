function lstag --description "List docker image tags use skopeo list-tags"
    skopeo list-tags docker://$argv[1] | jq -cr '.Tags[]'
end

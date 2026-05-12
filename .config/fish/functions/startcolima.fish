function startcolima --description "start colima vm"
    colima start \
        --vm-type=vz \
        --mount-type=virtiofs \
        --vz-rosetta \
        --cpu 4 \
        --memory 8
end

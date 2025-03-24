#!/usr/bin/env bash

set -eux

selector=$1
source=$2
dest=$3

pod="$(kubectl get pods -l "$selector" -o name | head -n 1)"
dir="$(dirname "$(readlink -f "$0")")"

# TODO: timeouts for expect and kubectl commands
expect "$dir/hold.expect" "$pod"

kubectl exec "$pod" -- tar cf - "$source" > "$dest"

expect "$dir/resume.expect" "$pod"

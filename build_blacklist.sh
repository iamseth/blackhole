#!/bin/bash

set -e
set -u
set -o pipefail


readonly TMP=$(mktemp -d)


cleanup() {
  rm -rf "${TMP}"
}


main() {
  mapfile -t sources < sources.txt
  for i in "${!sources[@]}"; do
    curl -sL "${sources[${i}]}" > "${TMP}/${i}.list"
    # Remove extra fields, comments, blank lines, and concat into a hosts.
    grep -v '#' "/${TMP}/${i}.list" | grep . | awk '{print $NF}' | grep -v '^0.0.0.0' >> "${TMP}/hosts"
  done

  # Remove duplicates and sort.
  sort -u -o "${TMP}/hosts" "${TMP}/hosts"

  # convert to unix line endings
  dos2unix -q "${TMP}/hosts"

  # Build the hosts file.
  cat ./hosts.template ~/.hosts > hosts 2>/dev/null
  sed 's/^/0.0.0.0 /' "${TMP}/hosts" >> hosts
  sed 's/^/::1 /' "${TMP}/hosts" >> hosts
}

trap cleanup EXIT

main "${@}"

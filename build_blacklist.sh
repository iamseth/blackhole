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

  # create unbound config
  :>unbound
  for host in $(cat ${TMP}/hosts); do
    echo "local-zone: \"${host}\" redirect" >> unbound
    echo "local-data: \"${host} A 0.0.0.0\"" >> unbound
    echo "local-data: \"${host} 86400 IN AAAA ::0\"" >> unbound
  done
  mv -f unbound adservers
  cat custom >> adservers
}

trap cleanup EXIT

main "${@}"



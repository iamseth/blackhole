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
  sed 's/^/local-data: "/' "${TMP}/hosts" | sed 's/$/ A 0.0.0.0"/' > ./unbound
  sed 's/^/local-data: "/' "${TMP}/hosts" | sed 's/$/ AAAA ::0"/' >> ./unbound

}

trap cleanup EXIT

main "${@}"


#!/usr/bin/env bash

set -euo pipefail

readonly TMP="$(mktemp -d)"

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

  # ensure unix line endings
  dos2unix -q "${TMP}/hosts"

  # create unbound config

  for host in $(cat "${TMP}/hosts"); do
    echo "local-data: \"${host} A 0.0.0.0\"" >> "${TMP}/blacklist"
    echo "local-data: \"${host} AAAA ::0\"" >> "${TMP}/blacklist"
  done
  mv "${TMP}/blacklist" ./
  cat custom.txt >> blacklist
}

trap cleanup EXIT

main "${@}"

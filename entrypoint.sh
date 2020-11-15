#!/usr/bin/env bash

set -euo pipefail

_install_dhall() {
  local dhall_haskell_ver; dhall_haskell_ver="$1"
  local bin_zip_name; bin_zip_name="dhall-${dhall_haskell_ver}-x86_64-linux.tar.bz2"

  wget "https://github.com/dhall-lang/dhall-haskell/releases/download/${dhall_haskell_ver}/${bin_zip_name}" \
    && tar -xjvf "./${bin_zip_name}" \
    && rm -rvf "./${bin_zip_name}"
  mv ./bin/dhall /bin

  which dhall
  dhall --version && dhall --help
}

_install_dhall "$1"

temp_file="$(mktemp)"

collect_errors() {
  echo
  find . -type f -name '*.dhall' | while read -r fpath; do
    set +e
    echo "Checking ${fpath} ..."
    dhall --no-cache <<< "${fpath}" > /dev/null
    set -e
  done
}

collect_errors 2> "${temp_file}"

if [ $(( $(wc -l < "${temp_file}") )) != 0 ]; then
  cat "${temp_file}"
  exit 1
fi

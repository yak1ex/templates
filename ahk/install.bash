#!/bin/bash

target_dir=/cygdrive/c/usr/local/bin

function install_imev2() {
  name=IMEv2.ahk
  target=${target_dir}/${name}
  account=k-ayaki
  repo=IMEv2.ahk

  date_remote=$(wget -qO- "https://api.github.com/repos/${account}/${repo}/commits?path=${name}&page=1&per_page=1" | jq '.[0].commit.committer.date' | sed -e 's/"//g' | tr -d \\r)
  tmpfile=$(mktemp)
  touch --date=${date_remote} $tmpfile
  if [[ ! -e $target || $tmpfile -nt $target ]]; then
    wget -O $target https://raw.githubusercontent.com/${account}/${repo}/master/${name}
    touch --date=${date_remote} $target
    echo Update ${name}
  else
    echo Skip ${name}
  fi
  rm $tmpfile
}

function install_resident() {
  target=${target_dir}/resident.ahk

  if [[ ! -e $target ]]; then
    req=1
  else
    for i in *.ahk; do
      if [[ $i -nt $target ]]; then
        req=1
        break
      fi
    done
  fi
  if [[ -n $req ]]; then
    cat *.ahk > $target
  fi
}

install_imev2
install_resident

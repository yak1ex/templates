#!/bin/bash

target_dir=/cygdrive/c/usr/local/bin

function install_imev2() {
  target=${target_dir}/IMEv2.ahk

  date_remote=$(wget -qO- 'https://api.github.com/repos/k-ayaki/IMEv2.ahk/commits?path=IMEv2%2eahk&page=1&per_page=1' | jq '.[0].commit.committer.date' | sed -e 's/"//g' | tr -d \\r)
  tmpfile=$(mktemp)
  touch --date=${date_remote} $tmpfile
  if [[ ! -e $target || $tmpfile -nt $target ]]; then
    wget -O $target https://raw.githubusercontent.com/k-ayaki/IMEv2.ahk/master/IMEv2.ahk
    touch --date=${date_remote} $target
  else
    echo Skip IMEv2.ahk
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

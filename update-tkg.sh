#!/usr/bin/env bash

DIR_TKG=$HOME/GIT/wine-tkg-git/wine-tkg-git
TKG_PKG=$(ls -t1 ${DIR_TKG}/wine*.xz | head -n1)

repo-add --new --remove ${DIR_TKG}/wine-tk.db.tar.gz ${TKG_PKG}

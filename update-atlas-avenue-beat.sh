#!/usr/bin/env bash

URL_RSS="https://www.spreaker.com/show/3369253/episodes/feed"
PRETTY_NAME="Atlas Avenue Beat"
GOOD_REGEX="^[eE]pisode.*$"

DEBUG=TRUE
# JUST_TEST=TRUE
NO_SLACK=TRUE
UPDATE_SYNCTHING=TRUE
# NO_UPDATE_REMOTE=TRUE

source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

WriteFeed

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  if [[ ! "${RAW_TITLE}" =~ Recap ]] ; then

    [ ${DEBUG} ] && echo "PASS regex: \"${RAW_TITLE}\""

    TITLE="${RAW_TITLE}"

    TRACK="$(date -d "${PUBDATE}" +%y%m)"

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

    UnsetThese

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"${RAW_TITLE}\""
  fi
done

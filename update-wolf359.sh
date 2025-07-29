#!/usr/bin/env bash

# URL_RSS="http://wolf359radio.libsyn.com/rss"
URL_RSS="https://www.patreon.com/rss/Wolf359Radio?auth=sx27a8ikePR56G4Kbnr-91sZRVV02Wtr&show=870604"
PRETTY_NAME="Wolf 359"
GOOD_REGEX="^Episode [0-9]+: "

DEBUG=TRUE
# JUST_TEST=TRUE
NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE
# NO_UPDATE_REMOTE=TRUE


source $HOME/GIT/podcast-scripts/common-functions.sh

WriteFeed

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  echo RAW_TITLE="${RAW_TITLE}"
  echo TYPE="${TYPE}"
  

  if [[ "${RAW_TITLE}" =~ ${GOOD_REGEX} ]] ; then
    [ ${DEBUG} ] && echo "PASS regex: \"${RAW_TITLE}\""

    eval $(echo "${RAW_TITLE}" | sed 's/Episode \([0-9]\+\): \(.*\)/EPISODE="\1"\nTITLE="\2"/')

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${EPISODE}"

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"${RAW_TITLE}\""
  fi
  UnsetThese

done

# sed 's/^url="\?\(.*mp3.*\)/EPURL="\1"/' \

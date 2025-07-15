#!/usr/bin/env bash

URL_RSS="http://nightvale.libsyn.com/rss"
PRETTY_NAME="Nightvale"
GOOD_REGEX="^[0-9]+ "



DEBUG=TRUE
JUST_TEST=TRUE
NO_SLACK=TRUE
NO_UPDATE_SYNCTHING=TRUE
NO_UPDATE_REMOTE=TRUE


source $HOME/GIT/podcast-scripts/common-functions.sh

WriteFeed

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  DumpFound

  if [[ "${RAW_TITLE}" =~ ${GOOD_REGEX} ]] ; then

    [ ${DEBUG} ] && echo "PASS regex: \"${RAW_TITLE}\""

    eval $(echo ${RAW_TITLE} | sed 's/\([0-9]\+\) \+[–-] \+\(.*\)/TRACK=\"\1\"\nTITLE=\"\2\"/')

    echo "THIS: $TRACK | $TITLE"

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

    UnsetThese

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"${RAW_TITLE}\""
  fi
done

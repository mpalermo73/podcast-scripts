#!/usr/bin/env bash

URL_RSS="https://rss.libsyn.com/shows/71769/destinations/306069.xml"
PRETTY_NAME="Rex Rivetter"
GOOD_REGEX="^[eE]pisode.*$"

DEBUG=TRUE
# JUST_TEST=TRUE
NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE
# NO_UPDATE_REMOTE=TRUE

source $HOME/GIT/podcast-scripts/common-functions.sh


WriteFeed

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  if [[ "${RAW_TITLE}" =~ ${GOOD_REGEX} ]] ; then

    [ ${DEBUG} ] && echo "PASS regex: \"${RAW_TITLE}\""

    [ ! "${TRACK}" ] && TRACK="02"
    [[ ${#TRACK} -lt 2 ]] && TRACK="0${TRACK}"
    [[ ${#SEASON} -lt 2 ]] && SEASON="0${SEASON}"
    TRACK="${SEASON}${TRACK}"

    eval $(echo "$RAW_TITLE" | sed 's/.*: \(.*\)$/TITLE="\1"/')

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

    UnsetThese

    TRACK_COUNTING=$(echo "${TRACK_COUNTING} - 1" | bc)

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"${RAW_TITLE}\""
  fi
done

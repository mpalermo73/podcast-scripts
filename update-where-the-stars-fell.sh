#!/usr/bin/env bash

URL_RSS="https://fableandfolly.supportingcast.fm/content/eyJ0IjoicCIsImMiOiIxOTY5IiwidSI6IjIyNTkyMTEiLCJkIjoiMTY1NTQ5MDU3OSIsImsiOjI4NX18YjM5ZjI1NTAyYjdhOGE0MTU4NDQ5ZDExMDk5OTlhZGMwYWIxYzY2OTdkZjQ3ZDFjOWM3MDBhNDkzOTZiYmUwYg.rss"
PRETTY_NAME="Where the Stars Fell"
GOOD_REGEX="^Episode [0-9]+:"

DEBUG=TRUE
JUST_TEST=TRUE
NO_SLACK=TRUE
NO_UPDATE_SYNCTHING=TRUE
NO_UPDATE_REMOTE=TRUE

source $HOME/GIT/podcast-scripts/common-functions.sh

WriteFeed

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  # if [ ${TYPE} == "full" ] && [[ "${RAW_TITLE}" =~ ${GOOD_REGEX} ]] ; then
  if [ ${TYPE} == "full" ] ; then

    [ ${DEBUG} ] && echo "PASS regex: \"${RAW_TITLE}\""

    # eval $(echo ${RAW_TITLE} | sed 's/^[0-9]\+: \(.*\)/TITLE="\1"/')
    eval $(echo ${RAW_TITLE} | sed 's/\(^[0-9]\+\):\s\+\(.*\)/TRACK="\1"\nTITLE="\2"/')

    [ ${#TRACK} -eq 3 ] && TRACK="0${TRACK}"

    # TRACK="${SEASON}${TRACK}"

    # YEAR=$(date -d "$PUBDATE" +%Y)
    # TRACK="${YEAR}${TRACK}"

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

    UnsetThese

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"${TYPE}\" - \"${RAW_TITLE}\""
  fi
done

#!/usr/bin/env bash

# URL_RSS="https://feeds.megaphone.fm/FAFO7407442460"
URL_RSS="https://fableandfolly.supportingcast.fm/content/eyJ0IjoicCIsImMiOiI0OTkxIiwidSI6IjIyNTkyMTEiLCJkIjoiMTY4ODc3MTEyMyIsImsiOjI4NX18MjBjNWZmNWY0ODY5ZmFhY2ZiYTlkMmQ0MWM0YWExMGIxZGEyMTUzMzkwYzg1ZWY0MzY3NDgxZGMxZDBlYjEyMQ.rss"
PRETTY_NAME="Nightlight"
GOOD_REGEX="^[0-9]+:"

DEBUG=TRUE
# JUST_TEST=TRUE
NO_SLACK=TRUE
NO_UPDATE_SYNCTHING=TRUE
NO_UPDATE_REMOTE=TRUE

source $HOME/GIT/podcast-scripts/common-functions.sh

WriteFeed

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  if [ ${TYPE} == "full" ] && [[ "${RAW_TITLE}" =~ ${GOOD_REGEX} ]] ; then

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

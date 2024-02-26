#!/usr/bin/env bash

URL_RSS="https://feeds.megaphone.fm/moonbasethetaout"
PRETTY_NAME="Moonbase Theta Out"
GOOD_REGEX="^MTO Season [0-9]"

DEBUG=TRUE
# JUST_TEST=TRUE
NO_SLACK=TRUE
UPDATE_SYNCTHING=TRUE
# NO_UPDATE_REMOTE=TRUE

source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

WriteFeed

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  if [ "${TYPE}" == "full" ] && [[ "${RAW_TITLE}" =~ ${GOOD_REGEX} ]] && [ "${TRACK}" ]; then

    [ ${DEBUG} ] && echo "PASS regex: \"${RAW_TITLE}\""

    eval $(echo "${RAW_TITLE}" | sed 's/.*: \“\(.*\)\”.*/TITLE=\"\1\"/')

    echo "THIS: $(echo "${RAW_TITLE}" | sed 's/.*: \“\(.*\)\”.*/TITLE=\"\1\"/')"

    [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"
    [ ${#TRACK} -eq 1 ] && TRACK="0${TRACK}"

    TRACK="${SEASON}${TRACK}"

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

    UnsetThese

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"${RAW_TITLE}\""
  fi
done

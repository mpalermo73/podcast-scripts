#!/usr/bin/env bash

URL_RSS="https://pod.link/304481704.rss"
PRETTY_NAME="The Leviathan Chronicles"
GOOD_REGEX=".*Leviathan.*"

# DEBUG=TRUE
# JUST_TEST=TRUE
NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE
# NO_UPDATE_REMOTE=TRUE

source $HOME/GIT/podcast-scripts/common-functions.sh

WriteFeed

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  if [ "${TYPE}" == "full" ] && [[ "${RAW_TITLE}" =~ ${GOOD_REGEX} ]] ; then

    [ ${DEBUG} ] && echo "PASS regex: \"${RAW_TITLE}\""

    TITLE=$(echo "${RAW_TITLE}" | sed 's/.*- \(.*\)/\1/')

    TRACK="$(date -d "${PUBDATE}" +%y%m)"

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

    UnsetThese

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"$TYPE\" - \"${RAW_TITLE}\""
  fi
done

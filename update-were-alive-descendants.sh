#!/usr/bin/env bash

URL_RSS="https://feeds.acast.com/public/shows/d1b39068-c10f-5817-8324-88ba173183cd"
PRETTY_NAME="We’re Alive - Descendants"
GOOD_REGEX="^[wW]e.*[aA]live.*[dD]escendants+"

# DEBUG=TRUE
# JUST_TEST=TRUE
NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE
# NO_UPDATE_REMOTE=TRUE

source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

WriteFeed

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  if [[ "${RAW_TITLE}" =~ ${GOOD_REGEX} ]] && [ "${TYPE}" == "full" ] ; then

    [ ${DEBUG} ] && echo "PASS regex: \"${RAW_TITLE}\""

    TITLE=$(echo "${RAW_TITLE}" | cut -d '-' -f3- | sed 's/^ \+//')

    [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"
    [ ${#TRACK} -eq 1 ] && TRACK="0${TRACK}"
    TRACK="${SEASON}${TRACK}"

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

    UnsetThese

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"$TYPE\" - \"${RAW_TITLE}\""
  fi
done

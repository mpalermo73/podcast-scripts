#!/usr/bin/env bash

URL_RSS="https://feeds.megaphone.fm/unwell"
PRETTY_NAME="Unwell - a Midwestern Gothic Mystery"
GOOD_REGEX="^[0-9]+.[0-9]+"


# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# UPDATE_SYNCTHING=TRUE
# NO_UPDATE_REMOTE=TRUE


source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

WriteFeed

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  if [ "${TYPE}" == "full" ] && [[ "${RAW_TITLE}" =~ ${GOOD_REGEX} ]] ; then

    eval $(echo "${RAW_TITLE}" | sed 's/\([0-9]\+\)\.\([0-9]\+\)\ \{0,1\}-\ \{0,1\}\([a-zA-Z0-9].*\)/SEASON="\1"\nTRACK="\2"\nTITLE="\3"/')

    [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"
    [ ${#TRACK} -eq 1 ] && TRACK="0${TRACK}"

    TRACK="${SEASON}${TRACK}"

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

    UnsetThese

  else
    [ ${DEBUG} ] && echo "FAIL regex: TYPE: $TYPE || \"${RAW_TITLE}\""
  fi
done

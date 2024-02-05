#!/usr/bin/env bash

URL_RSS="https://ourfaircity.libsyn.com/rss"
PRETTY_NAME="Our Fair City"
GOOD_REGEX="^[eE]pisode [0-9]+.[0-9]+"

# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
UPDATE_SYNCTHING=TRUE
# NO_UPDATE_REMOTE=TRUE

source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

WriteFeed

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  if [[ "${RAW_TITLE}" =~ ${GOOD_REGEX} ]] ; then

    [ ${DEBUG} ] && echo "PASS regex: \"${RAW_TITLE}\""

    # eval $(echo "${RAW_TITLE}" | sed 's/.*- \(.*\)/TITLE="\1"/')
    TITLE=$(echo "${RAW_TITLE}" | sed 's/[eE]pisode [0-9]\+\.[0-9]\+ \(.*\)/\1/ ; s/- \(.*\)/\1/')

    [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"
    [ ${#TRACK} -eq 1 ] && TRACK="0${TRACK}"

    TRACK="${SEASON}${TRACK}"

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

    UnsetThese

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"$TYPE\" - \"${RAW_TITLE}\""
  fi
done

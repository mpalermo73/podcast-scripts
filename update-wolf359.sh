#!/usr/bin/env bash

URL_RSS="http://wolf359radio.libsyn.com/rss"
PRETTY_NAME="Wolf 359"
GOOD_REGEX="^Episode [0-9]+: "

DEBUG=TRUE
# JUST_TEST=TRUE
NO_SLACK=TRUE
NO_UPDATE_SYNCTHING=TRUE
NO_UPDATE_REMOTE=TRUE


source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

WriteFeed

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  if [[ "${RAW_TITLE}" =~ ${GOOD_REGEX} ]] && [ "${TYPE}" == "full" ] ; then
    [ ${DEBUG} ] && echo "PASS regex: \"${RAW_TITLE}\""

    eval $(echo "${TITLE}" | sed 's/.*Episode.\([0-9]\+\):.\(.*\)/EPISODE="\1"\nTITLE="\2"/')

    TITLE="${EPISODE} - ${RAW_TITLE}"

    DisectInfo "${PUBDATE}" "${EPURL}" "${RAW_TITLE}"

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"${RAW_TITLE}\""
  fi
  UnsetThese

done

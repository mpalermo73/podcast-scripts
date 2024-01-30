#!/usr/bin/env bash

URL_RSS="https://link.chtbl.com/mockerymanor?id=mockerymanor&platform=rss"
PRETTY_NAME="Mockery Manor"
GOOD_REGEX="^S[0-9]+ E[0-9]+"

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

    eval $(echo "${RAW_TITLE}" | sed 's/S\([0-9]\+\) E\([0-9]\+\) - \(.*\)/SEASON="\1"\nTRACK="\2"\nTITLE="\3"/')

    [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"
    [ ${#TRACK} -eq 1 ] && TRACK="0${TRACK}"

    TRACK="${SEASON}${TRACK}"

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

    UnsetThese

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"$TYPE\" - \"${RAW_TITLE}\""
  fi
done

#!/usr/bin/env bash

URL_RSS="https://oz9podcast.libsyn.com/rss"
PRETTY_NAME="Oz 9"
GOOD_REGEX="^[eE]pisode.*$"

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

    eval $(echo ${RAW_TITLE} | sed 's/episode \([a-zA-Z]\+-\{0,1\}[a-zA-Z]\+\).*: \+\(.*\)/TRACK=\"\1\"\nTITLE=\"\2\"/')

    TRACK=$(${HERE}/w2n.pl "${TRACK}")

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

    UnsetThese

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"${RAW_TITLE}\""
  fi
done

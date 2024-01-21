#!/usr/bin/env bash

URL_RSS="https://mabel.libsyn.com/rss"
PRETTY_NAME="Mabel"
GOOD_REGEX="^[eE]pisode.*:"

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

    TITLE=$(echo "${RAW_TITLE}" | sed 's/.*: \+\(.*\)/\1/')

    TRACK=$(${HERE}/w2n.pl $(echo "${RAW_TITLE}" | sed 's/.*Epis[io]de \+\(.*\):.*/\1/ ; s/Four Point Five/4/'))

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

    UnsetThese

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"${RAW_TITLE}\""
  fi
done

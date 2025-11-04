#!/usr/bin/env bash

URL_RSS="https://audioboom.com/channels/4256036.rss"
PRETTY_NAME="King Falls AM"
GOOD_REGEX="^Episode .*[a-zA-Z]+:"



DEBUG=TRUE
JUST_TEST=TRUE
# NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE
# NO_UPDATE_REMOTE=TRUE

source $HOME/GIT/podcast-scripts/common-functions.sh

WriteFeed

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  PUB_YEAR=$(date -d "${PUBDATE}" +%y)

  # if [[ "${RAW_TITLE}" =~ ${GOOD_REGEX} ]] ; then

    [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

    WORD_NUMS="$(echo ${TITLE,,} | sed 's/episode \(.*[a-z]\+\): .*/\1/')"
    TITLE="$(echo $TITLE | sed "s/\([eE]pisode \).*[a-z]\+:\(.*\)/$($HOME/GIT/podcast-scripts/w2n.pl ${WORD_NUMS}) -\2/")"

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

  # else
  #   [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
  # fi

done

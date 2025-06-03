#!/usr/bin/env bash

URL_RSS="https://ericbusbypresents.com/category/the-byron-chronicles/feed/"
PRETTY_NAME="The Byron Chronicles"
GOOD_REGEX="^[eE]pisode [0-9]+.[0-9]+"

# DEBUG=TRUE
# JUST_TEST=TRUE
NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE
# NO_UPDATE_REMOTE=TRUE

source $HOME/GIT/podcast-scripts/common-functions.sh

WriteFeed

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  if [ "${TYPE}" == "full" ] ; then

    [ ${DEBUG} ] && echo "PASS regex: \"${RAW_TITLE}\""

    # eval $(echo "${RAW_TITLE}" | sed 's/.*- \(.*\)/TITLE="\1"/')
    # TITLE=$(echo "${RAW_TITLE}" | sed 's/[eE]pisode [0-9]\+\.[0-9]\+ \(.*\)/\1/ ; s/- \(.*\)/\1/')
    # eval $(echo "${RAW_TITLE}" | sed 's/[eE]pisode [0-9]\+\.[0-9]\+[ -:]\{0,1\}[ -:]\{0,1\} \(.*\)/TITLE="\1"/')
    TITLE=$(echo "${RAW_TITLE}" | sed 's/:/ -/ ; s/[–-]/-/ ; s/  / /g ; s/\([0-9]\+\)-/\1 -/ ; s/Season \([0-9]\+\) Episode \([0-9]\+\)/\1.\2/ ; s/The Byron Chronicles - //')

    TRACK="$(date -d "${PUBDATE}" +%y%m)"

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

    UnsetThese

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"$TYPE\" - \"${RAW_TITLE}\""
  fi
done

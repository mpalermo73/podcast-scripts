#!/usr/bin/env bash

URL_RSS="http://relativity.podomatic.com/rss2.xml"
PRETTY_NAME="Relativity"
GOOD_REGEX="^[rR][eE][lL][aA][tT][iI][vV][iI][tT][yY] [0-9]+"

DEBUG=TRUE
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

    if [ "${#RAW_TITLE}" -le 14 ] ; then

      TITLE="$(echo "${TITLE,,}" | sed -e 's/\b[a-z]/\U&/g')"

    else

      eval $(echo "${RAW_TITLE}" | sed 's/[()]//g ; s/\([0-9]\+\)-\([a-zA-Z]\+.*\)/\1 \2/ ; s/\([0-9]\):/\1/ ; ; s/[rR][eE][lL][aA][tT][iI][vV][iI][tT][yY] \+[0-9]\+\t\{0,1\}\(.*\).*/TITLE="\1"/')
    fi

    # [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"
    # [ ${#TRACK} -eq 1 ] && TRACK="0${TRACK}"

    TRACK="${SEASON}${TRACK}"

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

    UnsetThese

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"${RAW_TITLE}\""
  fi
done

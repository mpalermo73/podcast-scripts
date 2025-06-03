#!/usr/bin/env bash

URL_RSS="http://feeds.feedburner.com/agchbbc"
PRETTY_NAME="Agatha Christie"
GOOD_REGEX="Agatha Christie BBC"



# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE


source $HOME/GIT/podcast-scripts/common-functions.sh

CurlFeed

for LINE in ${EPISODES} ; do

  LINE=$(echo "${LINE}" | sed 's/<\!\[CDATA\[//g;s/\]\]>//g')
  # echo "LINE: ${LINE}"

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" ] ; then

    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] ; then

      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      eval $(echo "${TITLE}" | sed 's/.*: \([0-9]\+\).*- \(.*\)/EPISODE="\1"\nTITLE="\2"/;s/.*: \([0-9]\+\). \(.*\)/EPISODE="\1"\nTITLE="\2"/')

      [ ${#EPISODE} -eq 1 ] && EPISODE="0${EPISODE}"

      TITLE="${EPISODE} - ${TITLE}"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      echo "---------"
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
      # DumpFound
      echo "---------"
    fi
    UnsetThese
  fi

done

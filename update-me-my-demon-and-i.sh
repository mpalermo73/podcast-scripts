#!/usr/bin/env bash

URL_RSS="https://anchor.fm/s/e09c708/podcast/rss"
PRETTY_NAME="Me, My Demon, and I"
GOOD_REGEX="Episode [0-9]"



DEBUG=TRUE
JUST_TEST=TRUE
NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE


source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  LINE=$(echo "${LINE}" | sed 's/<\!\[CDATA\[//g;s/\]\]>//g')
  # echo "LINE: ${LINE}"

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${IMAGE}" -a "${SEASON}" -a "${EPISODE}" ] ; then

    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] && [[ "${TYPE}" =~ "full" ]] ; then

      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      [ ${#EPISODE} -eq 1 ] && EPISODE="0${EPISODE}"
      [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"

      TITLE="${SEASON}${EPISODE} - ${TITLE}"

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

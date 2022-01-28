#!/usr/bin/env bash

URL_RSS="https://feeds.acast.com/public/shows/fb402915-1004-584f-883e-8823fc306633"
PRETTY_NAME="Vast Horizon"
GOOD_REGEX="Entry [0-9]+"



# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
UPDATE_SYNCTHING=TRUE


source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${IMAGE}" -a "${EPISODE}" -a "${SEASON}" ] ; then

    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] ; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"
      [ ${#EPISODE} -eq 1 ] && EPISODE="0${EPISODE}"

      TITLE="${SEASON}${EPISODE} - $(echo "${TITLE}" | cut -d: -f2- | sed 's/^[ \t]\+//g')"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

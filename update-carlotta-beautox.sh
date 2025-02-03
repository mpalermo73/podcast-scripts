#!/usr/bin/env bash

URL_RSS="https://feeds.megaphone.fm/carlottabeautox"
PRETTY_NAME="The Carlotta Beautox Chronicles"
GOOD_REGEX="[0-9][0-9][0-9]$"

# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE


source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${IMAGE}" -a "${SEASON}" -a "${EPISODE}" ] ; then
    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] ; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"
      [ ${#EPISODE} -eq 1 ] && EPISODE="0${EPISODE}"

      TITLE="${SEASON}${EPISODE} - $(echo ${TITLE} | sed 's/\(.*\) --.*/\1/g')"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

#!/usr/bin/env bash

URL_RSS="http://feeds.wnyc.org/orbitinghumancircus"
PRETTY_NAME="The Orbiting Human Circus"
GOOD_REGEX="^[0-9]+"


# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE


source $HOME/GIT/podcast-scripts/common-functions.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${TYPE}" -a "${SEASON}" -a "${EPISODE}" ] ; then
    if [ "${TYPE}" == "full" ] ; then

      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"
      [ ${#EPISODE} -eq 1 ] && EPISODE="0${EPISODE}"

      TITLE="${SEASON}${EPISODE} - $(echo "${TITLE}" | sed 's/.*— \(.*\)/\1/')"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"
    fi

    UnsetThese
  fi

done

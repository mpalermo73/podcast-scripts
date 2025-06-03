#!/usr/bin/env bash

URL_RSS="https://decoderring.libsyn.com/rss"
PRETTY_NAME="Black Jack Justice"
GOOD_REGEX="^Black Jack Justice"



DEBUG=TRUE
# JUST_TEST=TRUE
NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE
NO_UPDATE_REMOTE=TRUE

source $HOME/GIT/podcast-scripts/common-functions.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" ] ; then

    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] && [[ ! "${TITLE}" =~ "Dead Men Run" ]] && [[ ! "${TITLE}" =~ "(book)" ]] ; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      EPISODE="$(echo $TITLE | sed 's/^.*\([0-9]\{2\}\).*/\1/')"
      TITLE=$(echo $TITLE | sed 's/.*[0-9]\{2\})\? \+-\? \?\(.*\)/\1/')

      TITLE="${EPISODE} - ${TITLE}"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

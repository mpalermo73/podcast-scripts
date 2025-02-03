#!/usr/bin/env bash

URL_RSS="https://www.spreaker.com/show/2910400/episodes/feed"
PRETTY_NAME="The Lift"
GOOD_REGEX="[sS][0-9]+[eE][0-9]+"



# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE


source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${IMAGE}" ] ; then

    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] ; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      SEASON=$(echo ${TITLE} | sed 's/[sS]\([0-9]\+\)[eE][0-9]\+.*/\1/')
      EPISODE=$(echo ${TITLE} | sed 's/[sS][0-9]\+[eE]\([0-9]\+\).*/\1/')

      [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"
      [ ${#EPISODE} -eq 1 ] && EPISODE="0${EPISODE}"

      TRACK="${SEASON}${EPISODE}"
      TITLE="${TRACK} - $(echo ${TITLE} | sed 's/[sS][0-9]\+[eE][0-9]\+:[ ]\?\(.*\)/\1/')"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

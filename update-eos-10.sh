#!/usr/bin/env bash

URL_RSS="https://feed.podbean.com/planetm/feed.xml"
PRETTY_NAME="EOS 10"
GOOD_REGEX="^[0-9]+ —"


# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# UPDATE_SYNCTHING=TRUE


source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${IMAGE}" ] ; then

    [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

    [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"
    [ ${#EPISODE} -eq 1 ] && EPISODE="0${EPISODE}"

    TITLE="${SEASON}${EPISODE} - $(echo "${TITLE}" | sed 's/.*— \+\(.*\)$/\1/;s/^.*: \(.*\)/\1/')"

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    UnsetThese
  fi

done

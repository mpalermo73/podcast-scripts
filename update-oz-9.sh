#!/usr/bin/env bash

URL_RSS="https://oz9podcast.libsyn.com/rss"
PRETTY_NAME="Oz 9"
GOOD_REGEX="^episode.*$"

# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
UPDATE_SYNCTHING=TRUE


source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${IMAGE}" -a "${SEASON}" -a "${EPISODE}" ] ; then
    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] ; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"
      [ ${#EPISODE} -eq 1 ] && EPISODE="0${EPISODE}"

      TITLE="${SEASON}${EPISODE} - $(echo ${TITLE} | sed 's/.*: \(.*\)/\1/;s/[&#*?!]//g')"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

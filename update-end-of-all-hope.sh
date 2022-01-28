#!/usr/bin/env bash

URL_RSS="https://www.spreaker.com/show/3369237/episodes/feed"
PRETTY_NAME="End of All Hope"
GOOD_REGEX="S[0-9]+E[0-9]+"



# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
UPDATE_SYNCTHING=TRUE

source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${TYPE}" ] ; then

    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] ; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      eval "$(echo "${TITLE}" | sed 's/^S\([0-9]\+\)E\([0-9]\+\): \(.*\)/SEASON="\1"\nEPISODE="\2"\nTITLE="\3"/')"

      [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"
      [ ${#EPISODE} -eq 1 ] && EPISODE="0${EPISODE}"

      TITLE="${SEASON}${EPISODE} - ${TITLE}"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

#!/usr/bin/env bash

URL_RSS="https://feed.podbean.com/dwad/feed.xml"
PRETTY_NAME="Doctor Who"
# GOOD_REGEX="S[0-9]+E[0-9]+"



# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# UPDATE_SYNCTHING=TRUE

source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${IMAGE}" -a "${EPISODE}" ] ; then

    if [[ "${TYPE}" =~ "full" ]] ; then

      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      [ ${#EPISODE} -eq 1 ] && EPISODE="00${EPISODE}"
      [ ${#EPISODE} -eq 2 ] && EPISODE="0${EPISODE}"
      # [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"

      TITLE="${EPISODE} - ${TITLE}"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      echo "---------"
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\" ${TYPE}"
      # DumpFound
      echo "---------"
    fi
    UnsetThese
  fi

done

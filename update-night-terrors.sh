#!/usr/bin/env bash

URL_RSS="http://darkerprojects.com/night-terrors/feed/"
PRETTY_NAME="Night Terrors"
GOOD_REGEX="[eE][pP] [0-9]+"

# DEBUG=TRUE
# JUST_TEST=TRUE
NO_SLACK=TRUE
# UPDATE_SYNCTHING=TRUE

source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" ] ; then

    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] && [[ ! "${TITLE}" =~ Remastered ]]; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      EPISODE=$(date -d "${PUBDATE}" +%y%m%d)

      TITLE="${EPISODE} - $(echo "${TITLE}" | sed 's/.*[eE][pP] [0-9]\+:[ \t]\+\(.*\)/\1/')"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

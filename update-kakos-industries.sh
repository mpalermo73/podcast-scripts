#!/usr/bin/env bash

URL_RSS="https://kakosindustries.com/feed/podcast"
PRETTY_NAME="Kakos Industries"
GOOD_REGEX="^[0-9]"



# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# UPDATE_SYNCTHING=TRUE

source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${IMAGE}" ] ; then

    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] && [[ "${TYPE,,}" == full ]]; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      [ ! ${EPISODE} ] && EPISODE=$(echo ${TITLE} | awk '{print $1}')

      [ ${#EPISODE} -eq 1 ] && EPISODE="00${EPISODE}"
      [ ${#EPISODE} -eq 2 ] && EPISODE="0${EPISODE}"

      TITLE="$(echo ${TITLE} | sed 's/^[0-9]\+.\?[–-]\?.\?\([A-Z].*\)/\1/g')"

      TITLE="${EPISODE} - ${TITLE}"

      # DisectInfo "${PUBDATE}" "${EPURL}" "${EPISODE}" "${TITLE}"
      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex or type: \"${TYPE}\" - \"${TITLE}\""
    fi
    UnsetThese
  fi

done

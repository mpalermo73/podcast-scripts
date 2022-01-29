#!/usr/bin/env bash

URL_RSS="https://feeds.simplecast.com/yMwA0_RF"
PRETTY_NAME="Mission Rejected"
GOOD_REGEX="[0-9]+"



# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
UPDATE_SYNCTHING=TRUE


source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${IMAGE}" -a "${TYPE}" ] ; then

    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] && [[ ! "${TYPE}" =~ "[Tr][Rr][Aa][Ii][Ll][Ee][Rr]" ]]; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      EPISODE=$(date -d "${PUBDATE}" +%y%m%d)

      [[ "${TITLE}" =~ [0-9]+: ]] && TITLE=$(echo "${TITLE}" | cut -d ' ' -f2-)

      TITLE="${EPISODE} - ${TITLE}"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

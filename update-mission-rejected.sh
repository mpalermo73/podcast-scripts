#!/usr/bin/env bash

URL_RSS="https://feeds.simplecast.com/yMwA0_RF"
PRETTY_NAME="Mission Rejected"
GOOD_REGEX="^[0-9]+"



# DEBUG=TRUE
JUST_TEST=TRUE
# NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE
# NO_UPDATE_REMOTE=TRUE


source $HOME/GIT/podcast-scripts/common-functions.sh


WriteFeed

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  # DumpFound

  if [[ "${RAW_TITLE}" =~ ${GOOD_REGEX} ]] ; then

    [ ${DEBUG} ] && echo "PASS regex: \"${RAW_TITLE}\""

    eval $(echo ${RAW_TITLE} | sed 's/\([0-9]\+\): \+\(.*\)/TRACK=\"\1\"\nTITLE=\"\2\"/')

    TRACK="$(printf "%04d" ${TRACK})"

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

    UnsetThese

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"${RAW_TITLE}\""
  fi
done


exit
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

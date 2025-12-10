#!/usr/bin/env bash

# URL_RSS="https://oz9podcast.libsyn.com/rss"
# URL_RSS="https://feeds.megaphone.fm/oz9"
URL_RSS="https://fableandfolly.supportingcast.fm/content/eyJ0IjoicCIsImMiOiIxMTE0OSIsInUiOiIyMjU5MjExIiwiZCI6IjE3MDYxMjkzMjkiLCJrIjoyODV9fDM0M2M5MzlmYzQxMGNjYTRiZGI4NGNiY2QwZGQ1ODIwNTQ4YTNmZGMyMTg0MDNlODUwNTlmMzY1OThjMzYwZWI.rss"
PRETTY_NAME="Oz 9"
GOOD_REGEX="^[eE]pisode.*$"

# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE
# NO_UPDATE_REMOTE=TRUE

source $HOME/GIT/podcast-scripts/common-functions.sh


WriteFeed

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  PUB_YEAR=$(date -d "${PUBDATE}" +%y)

  if [[ "${RAW_TITLE}" =~ ${GOOD_REGEX} ]] ; then

    [ ${DEBUG} ] && echo "PASS regex: \"${RAW_TITLE}\""

    # LAST_YEAR=0

    if [ "${PUB_YEAR}" -gt "${LAST_YEAR}" ] ; then

      [ ${DEBUG} ] && echo -e "\n\n--------------------------- START OF TRACK ${TRACK_COUNTING} (${ITEM} of ${ITEM_COUNT}) ---------------------------"

      [ ! ${TRACK_COUNTING} ] && TRACK_COUNTING=$(yq --input-format xml --output-format json "/tmp/${GENERIC_NAME}.xml" | sed 's/"+@\?/"/g ; s/itunes://g' | jq -S '[.rss.channel.item[] | select(.episodeType == "full")]' | jq length)

      TRACK=${TRACK_COUNTING}
      [[ ${#TRACK} -le 2 ]] && TRACK="0${TRACK}"
      [[ ${#TRACK} -le 1 ]] && TRACK="00${TRACK}"

      eval $(echo "$RAW_TITLE" | sed 's/.*: \(.*\)$/TITLE="\1"/')

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

      UnsetThese

      [ ${DEBUG} ] && echo "--------------------------- END OF TRACK ${TRACK_COUNTING} (${ITEM} of ${ITEM_COUNT}) ---------------------------"

      TRACK_COUNTING=$(echo "${TRACK_COUNTING} - 1" | bc)

    else
      [ ${DEBUG} ] && echo "Skipping old episode: ${RAW_TITLE} (${PUB_YEAR} <= ${LAST_YEAR})"
    fi

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"${RAW_TITLE}\""
  fi
done

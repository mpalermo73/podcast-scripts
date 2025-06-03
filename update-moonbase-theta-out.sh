#!/usr/bin/env bash

# URL_RSS="https://feeds.megaphone.fm/moonbasethetaout"
URL_RSS="https://fableandfolly.supportingcast.fm/content/eyJ0IjoicCIsImMiOiIxNjUyIiwidSI6IjIyNTkyMTEiLCJkIjoiMTY0MzMxNzU3NCIsImsiOjI4NX18NTI3MzQ0MjMzZjg2ZGYyZTg4MjMyYmFjYTdmMmEyOWNiYTQyZjUzMmFmZjM0NWFmNjQxNjBmMWVjY2E5Y2MwYg.rss"
PRETTY_NAME="Moonbase Theta Out"
GOOD_REGEX="^MTO Season [0-9]"

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

  if [ "${TYPE}" == "full" ] ; then

    [ ${DEBUG} ] && echo "PASS regex: \"${RAW_TITLE}\""

    # LAST_YEAR=0

    if [ "${PUB_YEAR}" -gt "${LAST_YEAR}" ] ; then

      [ ${DEBUG} ] && echo -e "\n\n--------------------------- START OF TRACK ${TRACK_COUNTING} (${ITEM} of ${ITEM_COUNT}) ---------------------------"

      [ ! ${TRACK_COUNTING} ] && TRACK_COUNTING=$(yq --input-format xml --output-format json /tmp/MoonbaseThetaOut.xml | sed 's/"+@\?/"/g' | jq '[.rss.channel.item[] | select(.episodeType == "full")]' | jq length)

      TRACK=${TRACK_COUNTING}
      [[ ${#TRACK} -le 2 ]] && TRACK="0${TRACK}"
      [[ ${#TRACK} -le 1 ]] && TRACK="00${TRACK}"

      eval $(echo "${RAW_TITLE}" | sed 's/.*: \“\(.*\)\”.*/TITLE=\"\1\"/ ; s/.*MTO.*Phases.*\(Story\s\+[0-9]\+:\s\+.*\)/TITLE="\1"/')

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

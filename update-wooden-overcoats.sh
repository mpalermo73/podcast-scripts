#!/usr/bin/env bash

# URL_RSS="http://www.woodenovercoats.com/episodes?format=rss"
URL_RSS="https://fableandfolly.supportingcast.fm/content/eyJ0IjoicCIsImMiOiIxOTM0NyIsInUiOiIyMjU5MjExIiwiZCI6IjE3NDQ0MDYwMTgiLCJrIjoyODV9fDEwNzA0ODEyMTgyNzk0YzRmMmJhYjk4OGQwZmIzNWVkY2Y0ODg3ODA4MGZkM2RkZGE0YmE5MmI0YWU3ZWEyM2U.rss"
PRETTY_NAME="Wooden Overcoats"
GOOD_REGEX="Episode [0-9]+"



# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE
# NO_UPDATE_REMOTE=TRUE


source $HOME/GIT/podcast-scripts/common-functions.sh

WriteFeed

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  echo $ITEM

  if [[ "${RAW_TITLE}" =~ ${GOOD_REGEX} ]] ; then
    [ ${DEBUG} ] && echo "PASS regex: \"${RAW_TITLE}\""

      [ ! ${TRACK_COUNTING} ] && TRACK_COUNTING=$(yq --input-format xml --output-format json /tmp/WoodenOvercoats.xml | sed 's/"+@\?/"/g' | jq '[.rss.channel.item[] | select((.episodeType == "full") and ((.title | tostring) | contains("Episode")))]' | jq length)

      TRACK=${TRACK_COUNTING}
      [[ ${#TRACK} -le 1 ]] && TRACK="0${TRACK}"

      eval $(echo "${RAW_TITLE}" | sed 's/ -/:/ ; s/.*:\s\+\(.*\)/TITLE="\1"/')

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

      UnsetThese

      [ ${DEBUG} ] && echo "--------------------------- END OF TRACK ${TRACK_COUNTING} (${ITEM} of ${ITEM_COUNT}) ---------------------------"

      TRACK_COUNTING=$(echo "${TRACK_COUNTING} - 1" | bc)

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"${RAW_TITLE}\""
  fi

  UnsetThese

done

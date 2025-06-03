#!/usr/bin/env bash

URL_RSS="https://anchor.fm/s/fd9adcbc/podcast/rss"
PRETTY_NAME="90 Degrees South"
GOOD_REGEX="^Episode .*[0-9]+:"



DEBUG=TRUE
JUST_TEST=TRUE
NO_SLACK=TRUE
NO_UPDATE_SYNCTHING=TRUE
NO_UPDATE_REMOTE=TRUE


source $HOME/GIT/podcast-scripts/common-functions.sh


WriteFeed

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  if [ $TYPE = "full" ] ; then

    [ ${DEBUG} ] && echo "PASS regex: \"${RAW_TITLE}\""

    [ ${DEBUG} ] && echo "--------------------------- START OF TRACK ${TRACK_COUNTING} (${ITEM} of ${ITEM_COUNT}) ---------------------------"

    [ ! ${TRACK_COUNTING} ] && TRACK_COUNTING=$(yq --input-format xml --output-format json /tmp/90DegreesSouth.xml | sed 's/"+@\?/"/g' | jq '[.rss.channel.item[] | select(.episodeType == "full")]' | jq length)

    TITLE="${RAW_TITLE#*:}"

    TRACK=${TRACK_COUNTING}
    [[ ${#TRACK} -le 2 ]] && TRACK="0${TRACK}"

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

    UnsetThese

    [ ${DEBUG} ] && echo "--------------------------- END OF TRACK ${TRACK_COUNTING} (${ITEM} of ${ITEM_COUNT}) ---------------------------"

    TRACK_COUNTING=$(echo "${TRACK_COUNTING} - 1" | bc)

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"${RAW_TITLE}\""
  fi
done


# -> % yq --input-format xml --output-format json /tmp/90DegreesSouth.xml | sed 's/"+@\?/"/g' | jq '[.rss.channel.item[] | select(.episodeType == "full")]' | jq length
# 55

# -> % yq --input-format xml --output-format json /tmp/90DegreesSouth.xml | sed 's/"+@\?/"/g' | jq '[.rss.channel.item[] | select(.episodeType != "full")]' | jq length
8


#!/usr/bin/env bash

URL_RSS="https://anchor.fm/s/fd9adcbc/podcast/rss"
PRETTY_NAME="90 Degrees South"
GOOD_REGEX="^Episode .*[0-9]+:"



# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE
# NO_UPDATE_REMOTE=TRUE


source $HOME/GIT/podcast-scripts/update-podcasts-common.sh


WriteFeed

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  if [[ "${RAW_TITLE}" =~ ${GOOD_REGEX} ]] && [ $TYPE = "full" ] ; then

    [ ${DEBUG} ] && echo "PASS regex: \"${RAW_TITLE}\""

    TITLE="${RAW_TITLE#*:}"

    [[ ${#SEASON} -le 2 ]] && SEASON=$(printf "%02d\\n" ${SEASON})

    TRACK="${SEASON}$(printf "%02d\\n" ${TRACK#*0})"

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

    UnsetThese

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"${RAW_TITLE}\""
  fi
done


# -> % yq --input-format xml --output-format json /tmp/90DegreesSouth.xml | sed 's/"+@\?/"/g' | jq '[.rss.channel.item[] | select(.episodeType == "full")]' | jq length
# 55

# -> % yq --input-format xml --output-format json /tmp/90DegreesSouth.xml | sed 's/"+@\?/"/g' | jq '[.rss.channel.item[] | select(.episodeType != "full")]' | jq length
8


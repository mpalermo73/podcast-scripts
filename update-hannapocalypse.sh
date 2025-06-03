#!/usr/bin/env bash

URL_RSS="https://fableandfolly.supportingcast.fm/content/eyJ0IjoicCIsImMiOiIzNjY1IiwidSI6IjIyNTkyMTEiLCJkIjoiMTY3NDI1Mzg3NiIsImsiOjI4NX18NjhjZWMzZDA2ZjlkNzFjMjA5MmY1ZjVmNmM3NDNjYTNjYjIxOTkxYjhiYjRkYzRiYjQ5Njg3NmMwOTE2ZmY3Mw.rss"
PRETTY_NAME="Hannahpocalypse"
GOOD_REGEX="^[0-9]+"

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

  # LAST_YEAR=0

if [ ${TYPE} == "full" ] && [[ "${RAW_TITLE}" =~ ${GOOD_REGEX} ]]; then

  if [ "${PUB_YEAR}" -gt "${LAST_YEAR}" ] ; then

    [ ! ${TRACK_COUNTING} ] && TRACK_COUNTING=$(yq --input-format xml --output-format json "/tmp/${GENERIC_NAME}.xml" | sed 's/"+@\?/"/g' | jq '[.rss.channel.item[] | select((.episodeType == "full") and ((.title | tostring)| match("[0-9]")))]' | jq length)

    TRACK=${TRACK_COUNTING}
    [[ ${#TRACK} -le 2 ]] && TRACK="0${TRACK}"
    [[ ${#TRACK} -le 1 ]] && TRACK="00${TRACK}"

    TITLE="$(echo ${RAW_TITLE} | sed 's/^[0-9. -]\+\(.*\)/\1/')"

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

    UnsetThese

    TRACK_COUNTING=$(echo "${TRACK_COUNTING} - 1" | bc)

  else
    [ ${DEBUG} ] && echo "Skipping old episode: ${RAW_TITLE} (${PUB_YEAR} <= ${LAST_YEAR})"
  fi
else
  [ ${DEBUG} ] && echo "Skipping: \"${TYPE}\""
  [ ${DEBUG} ] && echo "Skipping: ${RAW_TITLE} does not match regex ${GOOD_REGEX}"
fi
done

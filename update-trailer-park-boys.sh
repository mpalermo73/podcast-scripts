#!/usr/bin/env bash

URL_RSS="https://tpbpodcast.libsyn.com/rss"
PRETTY_NAME="Trailer Park Boys"
# GOOD_REGEX="^[0-9].*$"

# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE
# NO_UPDATE_REMOTE=TRUE


source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

WriteFeed


LAST_YEAR=$(date -d "last year" +%y)
# LAST_YEAR=0

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  PUB_YEAR=$(date -d "${PUBDATE}" +%y)

  if [ "${PUB_YEAR}" -gt "${LAST_YEAR}" ] ; then

    [ ${DEBUG} ] && echo "--------------------------- START OF TRACK ${TRACK_COUNTING} (${ITEM} of ${ITEM_COUNT}) ---------------------------"

    [ ! ${TRACK_COUNTING} ] && TRACK_COUNTING=${ITEM_COUNT}

    TRACK=${TRACK_COUNTING}

    [[ "${RAW_TITLE}" =~ ^"TPB in Quarantine" ]] && RAW_TITLE="$(echo "${RAW_TITLE}" | sed 's/.*Episode\s\+\([0-9]\+\).*/Episode \1 - Quarantine Episode \1/')"

    eval $(echo "$RAW_TITLE" | sed 's/.*Episode\s\+\([0-9]\+\)\s\?\+.\s\?\+\(.*\)/TITLE="\2"/')

    [[ ${#TRACK} -le 2 ]] && TRACK="0${TRACK}"

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

    TRACK_COUNTING=$(echo "${TRACK_COUNTING} - 1" | bc)

    [ ${DEBUG} ] && echo "--------------------------- END OF TRACK ${TRACK_COUNTING} (${ITEM} of ${ITEM_COUNT}) ---------------------------"

  else
    [ ${DEBUG} ] && echo "Skipping old episode: ${RAW_TITLE} (${PUB_YEAR} <= ${LAST_YEAR})"
    exit 0
  fi
done

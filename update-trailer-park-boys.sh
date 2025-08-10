#!/usr/bin/env bash

# -> % for YEAR in $(jq -r '.rss.channel.item[].pubDate | strptime("%a, %d %b %Y %H:%M:%S %z") | strftime("%Y")' ~/Desktop/TrailerParkBoys.json | uniq) ; do jq --arg YEAR $YEAR '[.rss.channel.item[] | select(.pubDate | contains($YEAR))]' ~/Desktop/TrailerParkBoys.json | jq length ; done


URL_RSS="https://tpbpodcast.libsyn.com/rss"
PRETTY_NAME="Trailer Park Boys"
# GOOD_REGEX="^[0-9].*$"

DEBUG=TRUE
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

  if [ "${PUB_YEAR}" -gt "${LAST_YEAR}" ] ; then


    [ ${DEBUG} ] && echo "--------------------------- START OF TRACK ${TRACK_COUNTING} (${ITEM} of ${ITEM_COUNT}) ---------------------------"

    if [ "${RAW_TITLE/TPB in Quarantine*/true}" == "true" ] ; then
      [ ${DEBUG} ] && echo -e "${BD}${WH}QUARANTINE Episode detected: ${RAW_TITLE}${NO}"
      eval $(echo "${RAW_TITLE}" | sed 's/.*Episode\s\+\([0-9]\+\).*/TITLE="Quarantine Episode \1"/')

    elif [ "${RAW_TITLE/Episode [0-9]*/true}" == "true" ] ; then
      [ ${DEBUG} ] && echo "${BD}${WH}STANDARD Episode detected: ${RAW_TITLE}${NO}"
      eval $(echo "${RAW_TITLE}" | sed 's/.*Episode\s\+\([0-9]\+\)\s\?\+.\s\?\+\(.*\)/TRACK="\1"\nTITLE="\2"/')

    else
      [ ${DEBUG} ] && echo "${BD}${WH}UNKNOWN Episode format detected: ${RAW_TITLE}${NO}"
        TITLE="${RAW_TITLE}"
    fi

    TRACK=$(date -d "${PUBDATE}" +%y%V)

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

    UnsetThese

    [ ${DEBUG} ] && echo -e "--------------------------- END OF TRACK ${TRACK_COUNTING} (${ITEM} of ${ITEM_COUNT}) ---------------------------\n"

  else
    [ ${DEBUG} ] && echo "Skipping old episode: ${RAW_TITLE} (${PUB_YEAR} <= ${LAST_YEAR})"
    exit 0
  fi
done

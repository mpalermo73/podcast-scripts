#!/usr/bin/env bash

URL_RSS="https://fableandfolly.supportingcast.fm/content/eyJ0IjoicCIsImMiOiIyMDkzIiwidSI6IjIyNTkyMTEiLCJkIjoiMTY1OTczMDMxNyIsImsiOjI4NX18NjNkZGFkYjhmNGY1YmY5ZWM5MzI4NGI3ZjE0ODIzZjg2Mzc4MmZmZTAyMjY3NzgxOGFkYzFiZTRhYTY0ZTJiMg.rss?0t=1772926659848"
PRETTY_NAME="The Strange Case of Starship Iris"
GOOD_REGEX="^[0-9]\.[0-9]"

# DEBUG=TRUE
# JUST_TEST=TRUE
NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE
# NO_UPDATE_REMOTE=TRUE

source $HOME/GIT/podcast-scripts/common-functions.sh


WriteFeed

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  PUB_YEAR=$(date -d "${PUBDATE}" +%y)

  if [[ "${RAW_TITLE}" =~ ${GOOD_REGEX} && "${TYPE}" == "full" ]] ; then

    [ ${DEBUG} ] && echo "PASS regex: \"${RAW_TITLE}\""

      TITLE="$(echo "${RAW_TITLE}" | sed 's/[0-9].[0-9]\+\.\?[0-9]\+\?\+\s\+//')"

      TRACK=$(date -d "${PUBDATE}" +%y%U)

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

      UnsetThese

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"${RAW_TITLE}\""
  fi
done

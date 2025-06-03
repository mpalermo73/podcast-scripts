#!/usr/bin/env bash

# URL_RSS="https://rss.art19.com/the-amelia-project"
URL_RSS="https://fableandfolly.supportingcast.fm/content/eyJ0IjoicCIsImMiOiIxNTk2IiwidSI6IjIyNTkyMTEiLCJkIjoiMTY0MzMwODAxMCIsImsiOjI4NX18ZDllODhjMmZhNGFkZTE3MjNjZTRhMjQ4N2E4MTE1NDI5MGJhMzE3YTQ3YWJmZWI2ODQ4Y2UyMWQ3MTM3NmRlYw.rss"
PRETTY_NAME="The Amelia Project"
GOOD_REGEX="^Episode [0-9]+ - "



# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE


source $HOME/GIT/podcast-scripts/common-functions.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${IMAGE}" ] ; then
    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] && [ "${TYPE}" == "full" ] ; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"
      [ ${#EPISODE} -eq 1 ] && EPISODE="0${EPISODE}"

      TITLE="${SEASON}${EPISODE} - $(echo ${TITLE} | sed 's/Episode [0-9]\+ - \(.*\)/\1/')"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

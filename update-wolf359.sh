#!/usr/bin/env bash

URL_RSS="http://wolf359radio.libsyn.com/rss"
PRETTY_NAME="Wolf 359"
GOOD_REGEX="^Episode [0-9]+: "
DATE_MIN=$(date -d "- 100 year" "+%b %d, %Y")



DEBUG=TRUE
JUST_TEST=TRUE
NO_SLACK=TRUE
# UPDATE_SYNCTHING=TRUE
# NO_UPDATE_REMOTE=TRUE


source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" ] ; then
    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] && [ "${TYPE}" == "full" ] ; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      # PRETITLE=${TITLE}

      # | sed 's/.*Episode.\([0-9]\+\):.\(.*\)/EPISODE="\1"\nTITLE="\2"/'

      # [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"
      # [ ${#EPISODE} -eq 1 ] && EPISODE="0${EPISODE}"

      eval $(echo "${TITLE}" | sed 's/.*Episode.\([0-9]\+\):.\(.*\)/EPISODE="\1"\nTITLE="\2"/')

      TITLE="${EPISODE} - ${TITLE}"
      # TITLE="${SEASON}${EPISODE} - $(echo ${PRETITLE} | sed 's/Episode [0-9]\+:.\(.*\)/\1/')"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

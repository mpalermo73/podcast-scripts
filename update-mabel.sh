#!/usr/bin/env bash

URL_RSS="https://mabel.libsyn.com/rss"
PRETTY_NAME="Mabel"
GOOD_REGEX="^[eE]pisode.*:"

# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
UPDATE_SYNCTHING=TRUE


source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" ] ; then
    # if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] ; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      TITLE=$(echo "${TITLE}" | sed 's/[()]//g')

      EPISODE=$(basename ${EPURL} | sed 's/.*[eE][pP][iI][sS][oO][dD][eE]_\([0-9]\+\).*/\1/ ; s/.*[mM][aA][bB][eE][lL]_\([0-9]\+\).*/\1/ ; s/.*[eE][pP][iI][sS][oO][dD][eE]_\([a-zA-Z]\+\).*/\1/')

      EPISODE=$($HOME/GIT/podcast-scripts/w2n.pl ${EPISODE})

      # WORD_NUMS=$(echo ${TITLE} | sed 's/^.*[eE]pis.de \(.*\):.*/\1/')

      # if [[ ! "${WORD_NUMS}" =~ [0-9] ]] ; then
      #   EPISODE=$($HOME/GIT/podcast-scripts/w2n.pl "${WORD_NUMS}")
      # else
      #   EPISODE=${WORD_NUMS}
      # fi

      [ ${#EPISODE} -eq 1 ] && EPISODE="00${EPISODE}"
      [ ${#EPISODE} -eq 2 ] && EPISODE="0${EPISODE}"

      TITLE="${EPISODE} - $(echo ${TITLE} | sed 's/^.*: //')"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    # else
    #   [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    # fi
    UnsetThese
  fi

done

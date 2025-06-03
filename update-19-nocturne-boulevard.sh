#!/usr/bin/env bash

URL_RSS="https://nineteennocturne.libsyn.com/rss"
PRETTY_NAME="19 Nocturne Boulevard"
GOOD_REGEX="^19 Nocturne"



# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE

source $HOME/GIT/podcast-scripts/common-functions.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${TYPE}" ] ; then

    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] && [[ ! "${TITLE}" =~ [rR][eE][iI][sS][sS][uU][eE] ]]; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      DASHCOUNT=$(echo ${TITLE//[^-]} | wc -c)

      TITLE="$(date -d "${PUBDATE}" +%y%m%d) - $(echo "${TITLE}" | cut -d '-' -f ${DASHCOUNT} | awk '{$1=$1};1')"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

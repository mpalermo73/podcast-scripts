#!/usr/bin/env bash

URL_RSS="https://feeds.feedburner.com/edictzero-fis"
PRETTY_NAME="Edict Zero FIS"
GOOD_REGEX="^Edict.*EP[0-9]"

# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE

source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${MEDIA}" -a "${TITLE}" -a "${PUBDATE}" ] ; then
    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] ; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      EPURL="${MEDIA}"

      eval $(echo "${TITLE}" | sed 's/.*Edict Zero – FIS – EP\([0-9]\+\) – \(“\?.*”\?.*\)/EP=\1\nTITLE="\2"/ ; s/[“”]//g')
      eval $(echo ${EP} | sed 's/\([0-9\]\+\)\([0-9]\{2\}\)/SEASON=\1\nEPISODE=\2/')

      [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"
      [ ${#EPISODE} -eq 1 ] && EPISODE="0${EPISODE}"

      TITLE="${SEASON}${EPISODE} - ${TITLE}"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  else
    [ ${DEBUG} ] && echo "NOTHING: $LINE"
    unset EPURL
  fi

done

#!/usr/bin/env bash

URL_RSS="http://www.woodenovercoats.com/episodes?format=rss"
PRETTY_NAME="Wooden Overcoats"
GOOD_REGEX="Episode [0-9]+"



# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# UPDATE_SYNCTHING=TRUE


source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${IMAGE}" ] ; then

    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] && [[ ! "${TITLE}" =~ Remastered ]]; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"
      [ ${#EPISODE} -eq 1 ] && EPISODE="0${EPISODE}"

      TITLE="${SEASON}${EPISODE} - $(echo "${TITLE}" | sed 's/.*Season.*Episode.*[0-9]\+[ -:]\+//')"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

#!/usr/bin/env bash

URL_RSS="https://nocturnepodcast.org/feed/podcast/"
PRETTY_NAME="Nocturne"
GOOD_REGEX=""



# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# UPDATE_SYNCTHING=TRUE

source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" ] ; then

    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] && [[ ! "${TITLE}" =~ Remastered ]]; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      EPISODE=$(date -d "${PUBDATE}" +%y%m%d)

      TITLE="$(echo "$TITLE" | sed 's/\!//g')"
      TITLE="${EPISODE} - ${TITLE}"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

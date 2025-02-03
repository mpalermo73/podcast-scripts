#!/usr/bin/env bash

URL_RSS="https://boston.libsyn.com/rss"
PRETTY_NAME="Boston Blackie Master Detective"
GOOD_REGEX="S[0-9]+E[0-9]+"



# DEBUG=TRUE
# JUST_TEST=TRUE
NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE

source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" ] ; then

    TITLE="$(echo "${TITLE}" | sed 's/Boston Blackie -\? \?// ; s/[0-9]\{6\}-// ; s/_/ /g ; s/\.$//')"

    EPISODE=$(date -d "${PUBDATE}" +%g%m)
    TITLE="${EPISODE} - ${TITLE}"

    DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"
    UnsetThese
  fi

done

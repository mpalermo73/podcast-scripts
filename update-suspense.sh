#!/usr/bin/env bash

URL_RSS="http://feeds.soundcloud.com/users/soundcloud:users:200829781/sounds.rss"
PRETTY_NAME="Suspense Radio Drama"
GOOD_REGEX="^Episode [0-9]+: "



# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE


source $HOME/GIT/podcast-scripts/common-functions.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${IMAGE}" ] ; then
    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] ; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      eval $(echo "${TITLE}" | sed 's/Episode \([0-9]\+\): \+.\(.*\)./EPISODE="\1"\nTITLE="\1 - \2"/')

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

#!/usr/bin/env bash

URL_RSS="http://feeds.soundcloud.com/users/soundcloud:users:200829781/sounds.rss"
PRETTY_NAME="Artie Lange's Halfway House"
GOOD_REGEX="^[0-9]+"



DEBUG=TRUE
JUST_TEST=TRUE
NO_SLACK=TRUE
# UPDATE_SYNCTHING=TRUE


source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${IMAGE}" -a ${EPISODE}" ] ; then
    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] ; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      TITLE="${EPISODE}$(echo "${TITLE}" | sed 's/\(.*\)/\L\1/;s/[0-9]\+ - \(.*\)/\1/;s/\b\(.\)/\u\1/g')"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

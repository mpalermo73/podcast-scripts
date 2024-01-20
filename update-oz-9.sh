#!/usr/bin/env bash

URL_RSS="https://oz9podcast.libsyn.com/rss"
PRETTY_NAME="Oz 9"
GOOD_REGEX="^[eE]pisode.*$"
HERE=$(dirname $0)

# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
UPDATE_SYNCTHING=TRUE
# NO_UPDATE_REMOTE=true

source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${IMAGE}" ] ; then
    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] ; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      eval $(echo ${TITLE} | sed 's/episode \([a-zA-Z]\+-\{0,1\}[a-zA-Z]\+\).*: \+\(.*\)/EPISODE=\"\1\"\nTITLE=\"\2\"/')

      EPISODE=$(printf "%03d\\n" $(${HERE}/w2n.pl "${EPISODE}"))

      TITLE="${EPISODE} - $(echo ${TITLE} | sed 's/.*: \(.*\)/\1/;s/[&#*?!]//g')"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

#!/usr/bin/env bash

URL_RSS="https://decoderring.libsyn.com/rss"
PRETTY_NAME="Red Panda Adventures"
GOOD_REGEX="^Red Panda Adv"

# wget -q -O - "https://decoderring.libsyn.com/rss" | xmllint --format --nsclean --xpath '//item[contains(.,"Red Panda Adv")] | //item/title[text()] | //item/*[name()="enclosure"] | //item/pubDate[text()] | //item/*[name()="itunes:image"] | //item/*[name()="itunes:episodeType"] | //item/*[name()="itunes:season"] | //item/*[name()="itunes:episode"]' - | sed 's/"//g;s/\&amp\;/\&/g;s/^[\ \t]\+//g' | sed 's/<title>\(.*\)<\/title>/TITLE="\1"/' | sed 's/<pubDate>\(.*\)<\/pubDate>/PUBDATE="\1"/' | sed 's/<enclosure.*url=\(..*mp3\).*/EPURL="\1"/' | sed 's/.*itunes:episodeType>\(.*\)<\/itunes.*/TYPE="\1"/' | sed 's/.*itunes:season>\(.*\)<\/itunes.*/SEASON="\1"/' | sed 's/.*itunes:episode>\(.*\)<\/itunes.*/EPISODE="\1"/' | sed 's/.*itunes:image href="\?\(.*\)"\?\/>/IMAGE="\1"/'

# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
UPDATE_SYNCTHING=TRUE
# NO_UPDATE_REMOTE=TRUE

source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${SEASON}" ] ; then

    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] ; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      eval $(echo "${TITLE}" | sed 's/.*(\([0-9]\+\)) -\? \?\(.*\)/EPISODE="\1"\nTITLE="\1 - \2"/')

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

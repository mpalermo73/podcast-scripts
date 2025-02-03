#!/usr/bin/env bash

URL_RSS="https://archive81.libsyn.com/rss"
PRETTY_NAME="Archive81"
GOOD_REGEX="^[0-9].*$"



# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE


EPISODES="$(curl -sL ${URL_RSS} | xmllint --format - \
  | egrep "<title>|<pubDate>|<enclosure.*url" \
  | sed 's/"//g;s/\&amp\;/\&/g;s/^\ \+//g;s/<title>\(.*\)<\/title>/TITLE="\1"/;s/<pubDate>\(.*\)<\/pubDate>/PUBDATE="\1"/;s/<enclosure.*url=\(..*mp3\).*/EPURL="\1"/')"


source $HOME/GIT/podcast-scripts/update-podcasts-common.sh



for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" ] ; then
    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] ; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""
      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"
    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
      unset PUBDATE EPFILE EPURL TITLE
    fi
  fi

done

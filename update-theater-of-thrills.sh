#!/usr/bin/env bash

URL_RSS="http://theaterofthrills.libsyn.com/rss"
PRETTY_NAME="Theater Of Thrills"
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

    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] ; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      PRETITLE=${TITLE}
      TITLE="$(date -d "${PUBDATE}" +%y%m%d) - ${TITLE}"
      TITLE="$(echo ${TITLE} | sed 's/\//-/;s/^[ \t]\+//g;s/[ \t]\+$//g')"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

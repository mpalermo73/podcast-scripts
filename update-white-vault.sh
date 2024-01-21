#!/usr/bin/env bash

URL_RSS="https://whitevault.libsyn.com/rss"
PRETTY_NAME="White Vault"
GOOD_REGEX="Episode [0-9]+"



# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# UPDATE_SYNCTHING=TRUE


source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${TYPE}" -a "${SEASON}" -a "${EPISODE}" ] ; then

    [ "${TYPE}" == "full" ] && if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] ; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      EPISODE=$(date -d "${PUBDATE}" +%y%m%d)

      TITLE="${EPISODE} - $(echo "${TITLE}" | sed 's/.*:: \(.*\).*/\1/')"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

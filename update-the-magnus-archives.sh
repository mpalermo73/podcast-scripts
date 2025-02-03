#!/usr/bin/env bash

URL_RSS="http://rss.acast.com/themagnusarchives"
PRETTY_NAME="The Magnus Archives"
GOOD_REGEX="MAG [0-9]+ "



# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# NO_UPDATE_SYNCTHING=TRUE


source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${IMAGE}" -a "${TYPE}" -a "${SEASON}" -a "${EPISODE}" ] ; then

    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] && [[ "${TYPE}" == full ]]; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      EPISODE="$(echo "${TITLE}" | sed 's/^MAG \([0-9]\+\).*/\1/')"

      TITLE="${EPISODE} - $(echo "${TITLE}" | sed 's/^MAG \+[0-9]\+ \+\(.*\)/\1/ ; s/^- //')"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

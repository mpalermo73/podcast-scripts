#!/usr/bin/env bash

URL_RSS="https://audioboom.com/channels/4256036.rss"
PRETTY_NAME="King Falls AM"
GOOD_REGEX="^Episode .*[a-zA-Z]+:"



# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
# UPDATE_SYNCTHING=TRUE


source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${IMAGE}" ] ; then
    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] ; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      WORD_NUMS="$(echo ${TITLE,,} | sed 's/episode \(.*[a-z]\+\): .*/\1/')"
      TITLE="$(echo $TITLE | sed "s/\([eE]pisode \).*[a-z]\+:\(.*\)/$($HOME/GIT/podcast-scripts/words_to_numbers.py ${WORD_NUMS}) -\2/")"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

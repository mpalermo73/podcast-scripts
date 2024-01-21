#!/usr/bin/env bash

URL_RSS="https://www.omnycontent.com/d/playlist/aaea4e69-af51-495e-afc9-a9760146922b/48da3539-5da0-41ed-a1c3-aac50170b88f/f7810480-e2d3-4be5-a559-aac50170b8a6/podcast.rss"
PRETTY_NAME="The Magic Tavern"
GOOD_REGEX="^Season.*[0-9].*$"

# https://hellofromthemagictavern.com/episodes?format=rss

DEBUG=TRUE
JUST_TEST=TRUE
NO_SLACK=TRUE
# UPDATE_SYNCTHING=TRUE


source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${IMAGE}" ] ; then
    if [[ "${TITLE}" =~ ${GOOD_REGEX} ]] ; then
      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""

      eval $(echo "Season 3, Ep 75 - Blacksmith (w/ Lily Sullivan)" | sed 's/[sS]eason \([0-9]\+\).*[eE]p \([0-9]\+\) - \(.*\))/SEASON="\1"\nEPISODE="\2"\nTITLE="\3"/')

      # SEASON=$(echo ${TITLE} | sed 's/[sS]\([0-9]\+\)[eE][0-9]\+.*/\1/')
      # EPISODE=$(echo ${TITLE} | sed 's/[sS][0-9]\+[eE]\([0-9]\+\).*/\1/')

      [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"
      [ ${#EPISODE} -eq 1 ] && EPISODE="0${EPISODE}"

      TRACK="${SEASON}${EPISODE}"
      TITLE="${TRACK} - $(echo ${TITLE} | sed 's/[sS][0-9]\+[eE][0-9]\+:[ ]\?\(.*\)/\1/')"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      [ ${DEBUG} ] && echo "FAIL regex: \"${TITLE}\""
    fi
    UnsetThese
  fi

done

#!/usr/bin/env bash

URL_RSS="https://tpbpodcast.libsyn.com/rss"
PRETTY_NAME="Trailer Park Boys"
# GOOD_REGEX="^[0-9].*$"
# DATE_MIN="Jan 1, 2020"



# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
UPDATE_SYNCTHING=TRUE

source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

# Season Starts
# S01: April 5 2019 7:00AM UTC - 1554436800
S01="1554436800"
# S02: May 29 2020 7:00AM UTC - 1590724800
S02="1590724800"
# S03: May 28 2021 9:00PM UTC - 1622174400
S03="1622174400"
# S04:
S04=""

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${TITLE}" -a "${EPURL}" -a "${IMAGE}" ] ; then

    PUBEPOCH=$(date -d "${PUBDATE}" +%s)

    if [ ${PUBEPOCH} -ge ${S03} ] ; then
      if [ "${PUBEPOCH}" -lt ${S02} ] ; then SEASON="01"
      elif [ "${PUBEPOCH}" -ge ${S02} -a "${PUBEPOCH}" -lt ${S03} ] ; then SEASON="02"
      elif [ "${PUBEPOCH}" -ge ${S03} ] ; then SEASON="03"
      else
        echo "CAN'T FIND SEASON: ${PUBEPOCH}"
        echo "${PUBEPOCH} - ${SEASON} - ${TITLE}"
        exit 1
      fi

      if [[ "${TITLE}" =~ ^"TPB in Quarantine" ]] ; then
        EPISODE=$(( 52 + $(echo "${TITLE}" | sed 's/.*\([0-9]\)$/\1/') ))
        TITLE="${SEASON}${EPISODE} - $(echo ${TITLE} | sed 's/\(.*\) - \(.*\)/\1 \2/')"
      else
        EPISODE="$(echo "${TITLE}" | sed 's/.*Episode \([0-9]\+\).*/\1/')"
        [ ${#EPISODE} -eq 1 ] && EPISODE="0${EPISODE}"
        TITLE="$(echo ${TITLE} | sed 's/.*Episode [0-9]\+ - //;s/S[h\*][i\*]t/Shit/g;s/\([fF]\)[u*][c*]k/\1uck/g;s/ÿ/y/g;s/\?\+//g')"
        TITLE="${SEASON}${EPISODE} - ${TITLE}"
      fi

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"
    else
      [ ${DEBUG} ] && echo "TOO OLD: ${PUBDATE} - ${TITLE}"
    fi

    UnsetThese
  fi
done

# SEASON_CURRENT="$(curl -sL "https://www.swearnet.com/shows/park-after-dark" | grep -c1 "^Season [0-9]\+")"
# SEASON_COUNT="$(curl -sL "https://www.swearnet.com/shows/park-after-dark/seasons" | grep -c "Season [0-9]\+")"

# -> % for S in 1 2 3 ; do curl -sL --head $(curl -sL "https://www.swearnet.com/shows/park-after-dark/seasons/$S" | grep -B1 ".*href.*seasons/$S/episodes/1\".*" | sed 's/.*url(\(\/\/.*jpeg\)).*/http:\1/' | grep "^http") | grep Modified ; done
# Last-Modified: Fri, 28 Feb 2020 22:42:24 GMT
# Last-Modified: Fri, 29 May 2020 09:52:52 GMT
# Last-Modified: Sat, 29 May 2021 00:08:55 GMT

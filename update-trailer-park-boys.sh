#!/usr/bin/env bash

URL_RSS="https://tpbpodcast.libsyn.com/rss"
PRETTY_NAME="Trailer Park Boys"
# GOOD_REGEX="^[0-9].*$"

# DEBUG=TRUE
# JUST_TEST=TRUE
# NO_SLACK=TRUE
UPDATE_SYNCTHING=TRUE
# NO_UPDATE_REMOTE=TRUE

# Season Starts
# S01: April 5 2019 7:00AM UTC - 1554436800
S01="1554436800"
# S02: May 29 2020 7:00AM UTC - 1590724800
S02="1590724800"
# S03: May 28 2021 9:00PM UTC - 1622174400
S03="1622174400"
# S04: May 30 00:00 - 1653883200
S04="1653883200"
# S05: May 29 12:00:00
S05="1685332800"
# S06: May 29 12:00:00
S06="1716782400"

source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

WriteFeed

SEASON=$(printf "%02d\\n" $(curl -sL ${URL_RSS} | xmllint --format --nsclean --xpath '//item/title' - | grep -m1 -i season | sed 's/<title>[sS]eason \([0-9]\+\).*/\1/'))

for ITEM in $(seq 1 ${ITEM_COUNT}) ; do

  eval $(GetItem ${ITEM})

  [ ${SEASON_SAVE} ] && SEASON=${SEASON_SAVE}

  if [[ "${RAW_TITLE}" =~ ${GOOD_REGEX} ]] ; then

    [ ${DEBUG} ] && echo "PASS regex: \"${RAW_TITLE}\""

    PUBEPOCH=$(date -d "${PUBDATE}" +%s)

    if [ ${PUBEPOCH} -ge ${S06} ] ; then
      # if [ "${PUBEPOCH}" -ge ${S05} ] ; then SEASON="05"
      # elif [ "${PUBEPOCH}" -ge ${S04} ] ; then SEASON="04"
      # elif [ "${PUBEPOCH}" -ge ${S03} ] ; then SEASON="03"
      # elif [ "${PUBEPOCH}" -ge ${S02} ] ; then SEASON="02"
      # elif [ "${PUBEPOCH}" -lt ${S02} ] ; then SEASON="01"
      # else
      #   echo "CAN'T FIND SEASON: ${PUBEPOCH}"
      #   echo "${PUBEPOCH} - ${SEASON} - ${TITLE}"
      #   exit 1
      # fi

      if [[ "${RAW_TITLE}" =~ ^"TPB in Quarantine" ]] ; then
        TRACK="${SEASON}"
        TRACK+="$(printf "%02d\\n" $(( 52 + $(echo "${RAW_TITLE}" | sed 's/.*\([0-9]\)$/\1/') )))"
        TITLE="$(echo ${RAW_TITLE} | sed 's/\(.*\) - \(.*\)/\1 \2/')"
      else
        TRACK="${SEASON}"
        TRACK+="$(printf "%02d\\n" $(echo "${RAW_TITLE}" | sed 's/.*Episode \([0-9]\+\).*/\1/'))"
        TITLE="$(echo ${RAW_TITLE} | sed 's/.*Episode [0-9]\+ - //;s/S[h\*][i\*]t/Shit/g;s/\([fF]\)[u*][c*]k/\1uck/g;s/ÿ/y/g;s/\?\+//g')"
      fi

      SEASON_SAVE=${SEASON}

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}" "${TRACK}"

      UnsetThese

    else
      [ ${DEBUG} ] && echo "TOO OLD: ${PUBDATE} - ${TITLE}"
      exit
    fi

  # exit

  else
    [ ${DEBUG} ] && echo "FAIL regex: \"${RAW_TITLE}\""
  fi
done

# SEASON_CURRENT="$(curl -sL "https://www.swearnet.com/shows/park-after-dark" | grep -c1 "^Season [0-9]\+")"
# SEASON_COUNT="$(curl -sL "https://www.swearnet.com/shows/park-after-dark/seasons" | grep -c "Season [0-9]\+")"

# -> % for S in 1 2 3 ; do curl -sL --head $(curl -sL "https://www.swearnet.com/shows/park-after-dark/seasons/$S" | grep -B1 ".*href.*seasons/$S/episodes/1\".*" | sed 's/.*url(\(\/\/.*jpeg\)).*/http:\1/' | grep "^http") | grep Modified ; done
# Last-Modified: Fri, 28 Feb 2020 22:42:24 GMT
# Last-Modified: Fri, 29 May 2020 09:52:52 GMT
# Last-Modified: Sat, 29 May 2021 00:08:55 GMT

# -> % IFS=$'\n'; for LINE in $(curl -sL https://tpbpodcast.libsyn.com/rss | xmllint --format --nsclean --xpath '//item/title | //item/pubDate' - | sed 's/<title>\(.*\)<\/title>/RAW_TITLE="\1"/ ; s/<pubDate>\(.*\)<\/pubDate>/PUBDATE="\1"/' | grep -A1 Season) ; do eval "$LINE" ; if [ "${RAW_TITLE}" -a "${PUBDATE}" ] ; then echo -e "RAW_TITLE: $RAW_TITLE\nPUBDATE: $PUBDATE" ; unset RAW_TITLE PUBDATE ; fi ; echo "---------" ; done
# ---------
# RAW_TITLE: Season 6 Episode 1 - The Silence Of The Bubbles
# PUBDATE: Mon, 27 May 2024 10:00:00 +0000
# ---------
# ---------
# ---------
# RAW_TITLE: Season 5 Episode 1 - Boys vs. Wild
# PUBDATE: Mon, 29 May 2023 10:00:00 +0000
# ---------
# ---------
# ---------
# RAW_TITLE: Season 4 Episode 1 - Live As F**k In Orlando
# PUBDATE: Mon, 30 May 2022 10:00:19 +0000
# ---------
# ---------
# ---------
# RAW_TITLE: Season 2 Episode 1 - Smurfgate
# PUBDATE: Mon, 01 Jun 2020 10:00:00 +0000
# ---------

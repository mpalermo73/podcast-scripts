#!/usr/bin/env bash

URL_RSS="https://feed.podbean.com/dwad/feed.xml"
PRETTY_NAME="Doctor Who"
# GOOD_REGEX="S[0-9]+E[0-9]+"



DEBUG=TRUE
JUST_TEST=TRUE
# NO_SLACK=TRUE
# UPDATE_SYNCTHING=TRUE

source $HOME/GIT/podcast-scripts/update-podcasts-common.sh

CurlFeed

for LINE in ${EPISODES} ; do

  eval "${LINE}"

  if [ "${PUBDATE}" -a "${EPURL}" -a "${TITLE}" -a "${IMAGE}" -a "${EPISODE}" ] ; then

    [ ${DEBUG} ] && echo "---------"

    if [[ ! "${TITLE}" =~ Trailer ]] ; then


      [ ${DEBUG} ] && echo "PASS regex: \"${TITLE}\""


      PART=$(echo "${TITLE}" | sed 's/.*[pP][aA][rR][tT] \([a-zA-Z]\+\).*/\1/ ; s/^[0-9]\+ // ; s/[oO][nN][eE]/1/ ; s/[tT][wW][oO]/2/ ; s/[tT][hH][rR][eE][eE]/3/ ; s/[fF][oO][uU][rR]/4/ ; s/[fF][iI][vV][eE]/5/ ; s/[sS][iI][xX]/6/ ; s/[sS][eE][vV][eE][nN]/7/ ;  ; s/[eE][iI][gG][hH][tT]/8/ ; s/[nN][iI][nN][eE]/9/')
      # EPISODE=$(echo "${TITLE}" | sed 's/^\(0-9]\+\)/\1/')
      TITLE=$(echo ${TITLE} | sed 's/^[0-9]\+ \(.*\) part.*/\1/')
      
      if [ "${PART}" ] ; then
        EPISODE="$(echo "${TITLE}" | sed 's/^\(0-9]\+\)/\1/').${PART}"
      else
        EPISODE="$(echo "${TITLE}" | sed 's/^\(0-9]\+\)/\1/')"
      fi

      [ ${#PART} -eq 1 ] && PART="0${PART}"

      [ ${#EPISODE} -eq 1 ] && EPISODE="00${EPISODE}"
      [ ${#EPISODE} -eq 2 ] && EPISODE="0${EPISODE}"
      # [ ${#SEASON} -eq 1 ] && SEASON="0${SEASON}"

      TITLE="${EPISODE} - ${TITLE}"

      DisectInfo "${PUBDATE}" "${EPURL}" "${TITLE}"

    else
      if [ ${DEBUG} ] ; then
        echo "FAIL regex: \"${TITLE}\" ${TYPE}"
        DumpFound
      fi
      UnsetThese
    fi

    UnsetThese
    [ ${DEBUG} ] && echo -e "---------\n\n"
  fi

done

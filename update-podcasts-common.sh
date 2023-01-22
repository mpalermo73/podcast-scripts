#!/usr/bin/env bash

# NOTE: mp3gain -s r -T -r -p -c *mp3


IFS_BAK=$IFS
IFS=$'\n'

GENERIC_NAME=$(echo "${PRETTY_NAME}" | sed 's/[ \t,]\+//g')
[ ! "${GENRE}" ] && GENRE="Podcast"

MOUNT_MEDIA="/mnt/MEDIA"
TANK_MEDIA="${MOUNT_MEDIA}/MUSIC/Podcasts/${PRETTY_NAME}"

MOUNT_SYNCTHING="/mnt/syncthing"
TANK_SYNCTHING="${MOUNT_SYNCTHING}/${PRETTY_NAME}"

TANK="/usr/local/Podcasts/${PRETTY_NAME}"
PODCAST_ALBUM_ART="${TANK}/${PRETTY_NAME}.jpg"
QUALITY=100
MAX_DIMENSION="1000"
MAX_SIZE="1024"


[ ! ${DEBUG} ] && WGET_DEBUG="--quiet"
[ ! "${DATE_MIN}" ] && DATE_MIN="Jun 30, 1908"
[ ! -d "${TANK}" ] && mkdir -p "${TANK}"

if [ $# -eq 1 ] && [[ "$1" =~ ^[rR][eE][tT][aA][gG]$ ]] ; then
  DO_RETAG=TRUE
fi



function AlbumArtCheck() {

  if [ ! -f "${PODCAST_ALBUM_ART}" -a ! "${IMAGE}" ] ; then
    echo "MISSING EITHER:"
    echo "PODCAST ALBUM ART: \"${PODCAST_ALBUM_ART}\""
    echo "REMOTE IMAGE: \"${IMAGE}\""
    exit 1
  else
    [ "${IMAGE}" ] && PODCAST_ALBUM_ART="/tmp/$(basename "${IMAGE}")"
    [ "${IMAGE}" ] && [ -f "${PODCAST_ALBUM_ART}" ] && rm -f "${PODCAST_ALBUM_ART}"
    [ ! "${IMAGE}" ] && PODCAST_ALBUM_ART="${TANK}/${PRETTY_NAME}.jpg"
  fi
}



function GetPodcastImage() {

  if [ "${IMAGE}" ] ; then

    TMP_ART="${PODCAST_ALBUM_ART}.tmp"

    wget ${WGET_DEBUG} "${IMAGE}" -O "${TMP_ART}"

    eval "$(/usr/bin/vendor_perl/exiftool -q -f "${TMP_ART}" \
      -p 'IMAGE_WIDTH="$imageWidth"' \
      -p 'IMAGE_HEIGHT="$imageHeight"')"

    if [ ${DEBUG} ] ; then
      echo -e "\\tIMAGE_WIDTH: \"${IMAGE_WIDTH}\""
      echo -e "\\tIMAGE_HEIGHT: \"${IMAGE_HEIGHT}\""
    fi

    PODCAST_ALBUM_ART="/tmp/${PRETTY_NAME}.jpg"

    convert -resize ${MAX_DIMENSION}x${MAX_DIMENSION}! -quality ${QUALITY} "${TMP_ART}" "${PODCAST_ALBUM_ART}"

    while [ $(ls -sk "${PODCAST_ALBUM_ART}" | awk '{print $1}') -gt ${MAX_SIZE} ] ; do
      convert -resize ${MAX_DIMENSION}x${MAX_DIMENSION}! -quality ${QUALITY} "${TMP_ART}" "${PODCAST_ALBUM_ART}"
      QUALITY=$(( ${QUALITY} - 1))
    done

    [ -f "${TMP_ART}" ] && rm -f "${TMP_ART}"

    unset TMP_ART

  elif [ ! -f "${PODCAST_ALBUM_ART}" ]; then
    echo -e "IMAGE is not set and ${PODCAST_ALBUM_ART} doesn't exist"
    echo -e "Can't tag ${TANK}/${OUTFILE}"
    exit 1
  fi
}



function CopyEpisode() {

  [ ${DEBUG} ] && echo "CopyEpisode - \"$1\""

  # TODO:
  # -> % cmp -s /mnt/syncthing/Trailer\ Park\ Boys/001\ -\ Can\'t\ Get\ You\ Out\ Of\ My\ Head.mp3 001\ -\ Can\'t\ Get\ You\ Out\ Of\ My\ Head.mp3 ; echo $?
  # 0


  for MTANK in ${TANK_MEDIA} ${TANK_SYNCTHING} ; do

    case ${MTANK} in
      ${TANK_SYNCTHING})
        if [ ${UPDATE_SYNCTHING} ] && [ ${NEW_EPISODE} ] ; then
          [ ! "$(mount | grep ${MOUNT_SYNCTHING})" ] && mount ${MOUNT_SYNCTHING}
          [ ${DEBUG} ] && echo "UPDATING ${MTANK}"
          [ ${DEBUG} ] && [ -f "${MTANK}/$(basename "$1")" ] && echo "EXISTS - ${MTANK}/$(basename "$1")"
          [ ${DEBUG} ] && [ ! -f "${MTANK}/$(basename "$1")" ] && echo "COPYING $(basename "$1") --> ${MTANK}"
          [ ! -d "${MTANK}" ] && mkdir -p "${MTANK}"
          [ ! -f "${MTANK}/$(basename "$1")" ] && cp -a "$1" "${MTANK}/$(basename "$1")"
        fi
        ;;
      ${TANK_MEDIA})
        if [ ! ${NO_UPDATE_REMOTE} ] ; then
          [ ${DEBUG} ] && echo "UPDATING ${MTANK}"
          [ ! "$(mount | grep ${MOUNT_MEDIA})" ] && mount ${MOUNT_MEDIA}
          [ ${DEBUG} ] && [ -f "${MTANK}/$(basename "$1")" ] && echo "EXISTS - ${MTANK}/$(basename "$1")"
          [ ${DEBUG} ] && [ ! -f "${MTANK}/$(basename "$1")" ] && echo "COPYING $(basename "$1") --> ${MTANK}"
          [ ! -d "${MTANK}" ] && mkdir -p "${MTANK}"
          [ ! -f "${MTANK}/$(basename "$1")" ] && cp -a "$1" "${MTANK}/$(basename "$1")"
        fi
        ;;
      *)
        echo "\"${MTANK}\" is an unknown tank.  Bailing..."
        exit 1
        ;;
    esac
  done



  # for MOUNT in ${MOUNT_MEDIA} ${MOUNT_SYNCTHING} ; do
  #   if [ ! ${UPDATE_SYNCTHING} ] && [ "${MOUNT}" == "${MOUNT_SYNCTHING}" ] ; then
  #     [ ${DEBUG} ] && echo "SKIPPING MOUNT ${MOUNT}"
  #   else
  #     [ ${DEBUG} ] && echo "MOUNTING ${MOUNT}"
  #     [ ! "$(mount | grep ${MOUNT})" ] && mount ${MOUNT}
  #   fi
  # done
  #
  # for MTANK in ${TANK_MEDIA} ${TANK_SYNCTHING} ; do
  #   if [ ! ${UPDATE_SYNCTHING} ] && [ ! ${NEW_EPISODE} ] && [ ${MTANK} == ${TANK_SYNCTHING} ] ; then
  #     [ ${DEBUG} ] && echo "SKIPPING UPDATE ${MTANK}"
  #   else
  #     [ ${DEBUG} ] && echo "UPDATING ${MTANK}"
  #     [ ${DEBUG} ] && [ -f "${MTANK}/$(basename "$1")" ] && echo "EXISTS - ${MTANK}/$(basename "$1")"
  #     [ ${DEBUG} ] && [ ! -f "${MTANK}/$(basename "$1")" ] && echo "COPYING $(basename "$1") --> ${MTANK}"
  #     [ ! -d "${MTANK}" ] && mkdir -p "${MTANK}"
  #     [ ! -f "${MTANK}/$(basename "$1")" ] && cp -a "$1" "${MTANK}/$(basename "$1")"
  #   fi
  # done
}



function EpisodeTagging() {

  YEAR=$(date -d "$PUBDATE" +%Y)

  # [ "${IMAGE}" ] && GetPodcastImage
  GetPodcastImage

  if [ $# -eq 1 ] && [ -f "$1" ] ; then
    TAGGING_FILE="$1"
  else
    TAGGING_FILE="${TANK}/${OUTFILE}"
  fi

  [ ${DEBUG} ] && echo "EpisodeTagging \"$TAGGING_FILE\""

  [ ${DEBUG} ] && DumpFound

  eyeD3 -l critical --no-color --preserve-file-times --quiet --remove-all "${TAGGING_FILE}" &>/dev/null

 	eyeD3 -l critical --force-update --no-color --preserve-file-times --quiet \
	--add-image="${PODCAST_ALBUM_ART}":FRONT_COVER:"${PRETTY_NAME}" \
	--text-frame="TYER:${YEAR}" \
	--text-frame="TPOS:" \
	-t "${TITLE}" \
	-G "${GENRE}" \
	-A "${PRETTY_NAME} Podcast" \
	-a "${PRETTY_NAME}" \
	-n "${TRACK}" \
	"${TAGGING_FILE}" 1>/dev/null

  touch -d "$(date -d "${PUBDATE}" +%Y-%m-%d)" "${TAGGING_FILE}"
}



function GetEpisode() {
  [ ${DEBUG} ] && echo GetEpisode "${TRACK}" "${TITLE}" "${OUTFILE}" "${PUBDATE}" "${EPURL}"

  TRACK=${1}
  TITLE=${2}
  OUTFILE=${3}
  PUBDATE=${4}
  FILEURL=${5}

  wget ${WGET_DEBUG} "${FILEURL}" -O "${TANK}/${OUTFILE}"
}



function AnnounceEpisode() {
  [ ! "${IMAGE}" ] && OUTPUT="New Episode!\n"
  [ "${IMAGE}" ] && OUTPUT="<${IMAGE}|${PRETTY_NAME}>\n"
  OUTPUT+="<${FILEURL}|${TITLE}>\n"
  [ ${UPDATE_SYNCTHING} ] && [ ${NEW_EPISODE} ] && OUTPUT+="Copied to Syncthing"

  [ ${DEBUG} ] && echo PAYLOAD: \"$(echo ${OUTPUT} | sed 's/\\n/\n/g')\"

  $HOME/GIT/scripts-git/slack.py -c another -i headphones -u "${PRETTY_NAME}" -m "$(echo ${OUTPUT} | sed 's/\\n/\n/g')"
}



function DisectInfo() {

  [ ${DEBUG} ] && echo "DisectInfo \"${PUBDATE}\" \"${EPURL}\" \"${TITLE}\""

  PUBDATE=$1
  EPURL=$2
  TITLE=$3

  [ ! "${EPISODE}" ] && EPISODE=$(date -d "${PUBDATE}" +%y%m%d)

  [ "${IMAGE}" ] && IMAGE="$(echo "${IMAGE}" | sed 's/\(.*\)?.*/\1/')"

  TRACK="$(echo ${TITLE} | awk '{print $1}' | sed 's/\([0-9]\+\).*/\1/')"
  [ ${#TRACK} -eq 1 ] && TRACK="00${TRACK}"
  [ ${#TRACK} -eq 2 ] && TRACK="0${TRACK}"


  if [[ "${TRACK}" =~ ^[0-9]+$ ]] ; then

    [ ${DEBUG} ] && echo "TRACK IS ONLY NUMBERS: \"$TRACK\""

    TITLE=$(echo "${TITLE}" | cut -d' ' -f3-)

    OUTFILE="${TRACK} - $(echo ${TITLE} | sed 's/[*]/_/g').mp3"

    PUBEPOCH="$(date -d "${PUBDATE}" +%s)"

    [ ${DEBUG} ] && DumpFound

    [ ! ${JUST_TEST} ] && ProcessEpisode

    UnsetThese
  else
    echo -e "\\n\\nTRACK is empty or not only numbers: \"${TRACK}\".  Bailing..."
    DumpFound
    UnsetThese
    exit
  fi
}



function ProcessEpisode() {

  # AlbumArtCheck

  if [ ${DO_RETAG} ] ; then


    for MTANK in ${TANK_MEDIA} ${TANK_SYNCTHING} ; do
      if [ -f "${TANK}/$(basename "${OUTFILE}")" ] ; then
        echo "RETAGGING ${TANK}/$(basename "${OUTFILE}")"
        EpisodeTagging "${TANK}/$(basename "${OUTFILE}")"
        [ -f "${MTANK}/$(basename "${OUTFILE}")" ] && cp -av "${TANK}/$(basename "${OUTFILE}")" "${MTANK}/$(basename "${OUTFILE}")"
      fi
    done

  else

    if [ ${PUBEPOCH} -ge $(date -d "${DATE_MIN}" +%s) ] ; then

      if [ ! -f "${TANK}/${OUTFILE}" ] ; then

        [ ${DEBUG} ] && echo "NEED: ${OUTFILE}"

        NEW_EPISODE=TRUE

        GetEpisode "${TRACK}" "${TITLE}" "${OUTFILE}" "${PUBDATE}" "${EPURL}"
        EpisodeTagging
        CopyEpisode "${TANK}/${OUTFILE}"
        [ ! ${NO_SLACK} ] && AnnounceEpisode

      elif [ -f "${TANK}/${OUTFILE}" ] ; then
        [ ${DEBUG} ] && echo "HAVE: ${OUTFILE}"
        touch -d "$(date -d "${PUBDATE}" +%Y-%m-%d)" "${TANK}/${OUTFILE}"
        CopyEpisode "${TANK}/${OUTFILE}"
      else
        [ ${DEBUG} ] && echo "DUNNO: ${PUBDATE} || ${EPURL} || ${#SUMMARY}"
      fi

      UnsetThese

    else
      [ ${DEBUG} ] && echo "$(date -d @${PUBEPOCH} "+%b %d, %Y") is older than ${DATE_MIN}.  Skipping..."
    fi
  fi

  UnsetThese
  [ ${DEBUG} ] && echo "---------"
}



function CurlFeed() {

  # | sed 's/<enclosure.*url=\(..*mp3\).*/EPURL="\1"/' \
  # | sed 's/<enclosure.*url=\(..*mp3\).*/EPURL="\1"/' \
  # | //item/*[name()="itunes:summary"]

  EPISODES="$(curl -sL ${URL_RSS} | tidy -xml -w 100000 -q - \
    | xmllint --format --nsclean --xpath '//item/title[text()] | //item/*[name()="enclosure"]/@url | //item/pubDate[text()] | //item/*[name()="itunes:image"] | //item/*[name()="itunes:episodeType"] | //item/*[name()="itunes:season"] | //item/*[name()="itunes:episode"]' - \
    | sed 's/"//g;s/\&amp\;/\&/g;s/^[\ \t]\+//g;s/<\!\[CDATA\[//g;s/\]\]>//g' \
    | sed 's/<title>\(.*\)<\/title>/TITLE="\1"/' \
    | sed 's/<pubDate>\(.*\)<\/pubDate>/PUBDATE="\1"/' \
    | sed 's/^url="\?\(.*mp3\).*/EPURL="\1"/' \
    | sed 's/.*itunes:episodeType>\(.*\)<\/itunes.*/TYPE="\1"/' \
    | sed 's/.*itunes:season>\(.*\)<\/itunes.*/SEASON="\1"/' \
    | sed 's/.*itunes:episode>\(.*\)<\/itunes.*/EPISODE="\1"/' \
    | sed 's/.*itunes:image href="\?\(.*\)"\?\/>.*/IMAGE="\1"/')"
}



function DumpFound() {
  echo "FOUND ALL:"
  [ "${PRETTY_NAME}" ] && echo -e "\\tPRETTY_NAME: ${PRETTY_NAME}"
  [ "${GENERIC_NAME}" ] && echo -e "\\tGENERIC_NAME: ${GENERIC_NAME}"
  [ "${PUBDATE}" ] && echo -e "\\tPUBDATE: ${PUBDATE}"
  [ "${PUBEPOCH}" ] && echo -e "\\tPUBEPOCH: ${PUBEPOCH}"
  [ "${PRETITLE}" ] && echo -e "\\tPRETITLE: ${PRETITLE}"
  [ "${TYPE}" ] && echo -e "\\tTYPE: ${TYPE}"
  [ "${SEASON}" ] && echo -e "\\tSEASON: ${SEASON}"
  [ "${EPISODE}" ] && echo -e "\\tEPISODE: ${EPISODE}"
  [ "${TITLE}" ] && echo -e "\\tTITLE: ${TITLE}"
  [ "${EPURL}" ] && echo -e "\\tEPURL: ${EPURL}"
  [ "${TRACK}" ] && echo -e "\\tTRACK: ${TRACK}"
  [ "${OUTFILE}" ] && echo -e "\\tOUTFILE: ${OUTFILE}"
  [ "${IMAGE}" ] && echo -e "\\tIMAGE: ${IMAGE}"
  [ "${DO_RETAG}" ] && echo -e "\\tDO_RETAG: ${DO_RETAG}"
}



function UnsetThese() {
  # unset EPURL PUBDATE PUBEPOCH OLD OUTFILE TITLE TRACK IMAGE PODCAST_ALBUM_ART
  unset EPURL IMAGE EPISODE NEW_EPISODE PRETITLE PUBDATE PUBEPOCH OLD OUTFILE SEASON TITLE TRACK TYPE
}

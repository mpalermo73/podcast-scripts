#!/usr/bin/env bash

# NOTE: mp3gain -s r -T -r -p -c *mp3


IFS_BAK=$IFS
IFS=$'\n'

GENERIC_NAME=$(echo "${PRETTY_NAME}" | sed 's/[ \t,]\+//g')
[ ! "${GENRE}" ] && GENRE="Podcast"

HERE=$(dirname $0)
MOUNT_MEDIA="/mnt/MEDIA"
TANK_MEDIA="${MOUNT_MEDIA}/MUSIC/Podcasts/${PRETTY_NAME}"

MOUNT_SYNCTHING="/mnt/syncthing"
TANK_SYNCTHING="${MOUNT_SYNCTHING}/${PRETTY_NAME}"

TANK_LOCAL="/usr/local/Podcasts/${PRETTY_NAME}"
PODCAST_ALBUM_ART="${TANK_LOCAL}/${PRETTY_NAME}.jpg"
QUALITY=100
MAX_DIMENSION="1000"
MAX_SIZE="1024"

ITEM_COUNT="${ITEM_COUNT:-0}"

[ ! ${DEBUG} ] && WGET_DEBUG="--quiet"
# [ ! "${DATE_MIN}" ] && DATE_MIN=$(date -d "- 100 year" "+%F")
[ ! -d "${TANK_LOCAL}" ] && mkdir -p "${TANK_LOCAL}"

if [ $# -eq 1 ] && [[ "$1" =~ ^[rR][eE][tT][aA][gG]$ ]] ; then
  DO_RETAG=TRUE
fi



function GetPodcastImage() {

  if [ "${IMAGE}" ] ; then

    PODCAST_ALBUM_ART="/tmp/${PRETTY_NAME}.jpg"
    curl -A "${UA}" -sL "${IMAGE}" | convert -resize ${MAX_DIMENSION} -define jpeg:extent=${MAX_SIZE}K - "${PODCAST_ALBUM_ART}"
    if [ ! -f "${TANK_LOCAL}/.folder.jpg" ] ; then
      cp -av "${PODCAST_ALBUM_ART}" "${TANK_LOCAL}/.folder.jpg"
      echo -e "[Desktop Entry]\\nIcon=./.folder.jpg" > "${TANK_LOCAL}/.directory"
    fi

  elif [ ! -f "${PODCAST_ALBUM_ART}" ]; then
    echo -e "IMAGE var is not set and \"${PODCAST_ALBUM_ART}\" not found"
    echo -e "Can't tag ${TANK_LOCAL}/${OUTFILE}"
    exit 1
  fi
}



function CopyEpisode() {

  [ ${DEBUG} ] && echo "CopyEpisode - \"$1\""

  for MTANK in ${TANK_MEDIA} ${TANK_SYNCTHING} ; do

    case ${MTANK} in
      ${TANK_SYNCTHING})
        if [ ${UPDATE_SYNCTHING} ] ; then
          [ ${DEBUG} ] && echo "UPDATING ${MTANK}"
          [ ! "$(mount | grep ${MOUNT_SYNCTHING})" ] && mount ${MOUNT_SYNCTHING}
          
          if [ ! -f "${MTANK}/$(basename "$1")" ] ; then
            [ ${DEBUG} ] && echo "COPYING $(basename "$1") --> ${MTANK}"
            [ ! -d "${MTANK}" ] && mkdir -p "${MTANK}"
            cp -a "$1" "${MTANK}/$(basename "$1")"
          else
            [ ${DEBUG} ] && echo "EXISTS - ${MTANK}/$(basename "$1")"
          fi
        fi
        ;;
      ${TANK_MEDIA})
        if [ ! ${NO_UPDATE_REMOTE} ] ; then
          [ ${DEBUG} ] && echo "UPDATING ${MTANK}"
          [ ! "$(mount | grep ${MOUNT_MEDIA})" ] && mount ${MOUNT_MEDIA}

          if [ ! -f "${MTANK}/$(basename "$1")" ] ; then
            [ ${DEBUG} ] && echo "COPYING $(basename "$1") --> ${MTANK}"
            [ ! -d "${MTANK}" ] && mkdir -p "${MTANK}"
            [ ! -f "${MTANK}/$(basename "$1")" ] && cp -a "$1" "${MTANK}/$(basename "$1")"
          else
            [ ${DEBUG} ] && echo "EXISTS - ${MTANK}/$(basename "$1")"
          fi
        fi
        ;;
      *)
        echo "\"${MTANK}\" is an unknown tank.  Bailing..."
        exit 1
        ;;
    esac
  done
}



function EpisodeTagging() {

  YEAR=$(date -d "$PUBDATE" +%Y)

  GetPodcastImage

  if [ $# -eq 1 ] && [ -f "$1" ] ; then
    TAGGING_FILE="$1"
  else
    TAGGING_FILE="${TANK_LOCAL}/${OUTFILE}"
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

  wget ${WGET_DEBUG} "${FILEURL}" -O "${TANK_LOCAL}/${OUTFILE}"
}



function AnnounceEpisode() {
  [ ! "${IMAGE}" ] && OUTPUT="New Episode!\n"
  [ "${IMAGE}" ] && OUTPUT="<${IMAGE}|${PRETTY_NAME}>\n"
  OUTPUT+="<${FILEURL}|${TITLE}>\n"
  # [ ${UPDATE_SYNCTHING} ] && [ ${NEW_EPISODE} ] && OUTPUT+="Copied to Syncthing"
  [ ${UPDATE_SYNCTHING} ] && OUTPUT+="Copied to Syncthing"

  [ ${DEBUG} ] && echo PAYLOAD: \"$(echo ${OUTPUT} | sed 's/\\n/\n/g')\"

  $HOME/GIT/scripts-git/slack.py -c another -i headphones -u "${PRETTY_NAME}" -m "$(echo ${OUTPUT} | sed 's/\\n/\n/g')"
}



function DisectInfo() {

  [ ${DEBUG} ] && echo "DisectInfo \"${PUBDATE}\" \"${EPURL}\" \"${TITLE}\" \"${TRACK}\""

  PUBDATE=$1
  EPURL=$2
  TITLE=$3
  TRACK=$4

  [ ! "${TRACK}" ] && TRACK=$(date -d "${PUBDATE}" +%y%m%d)
  [ ! "${TITLE}" ] && TITLE="${RAW_TITLE}"

  if [[ "${TRACK}" =~ ^[0-9]+$ ]] ; then

    [ ${DEBUG} ] && echo "TRACK IS ONLY NUMBERS: \"$TRACK\""

    TITLE=$(echo ${TITLE} | awk '{$1=$1};1')
    [[ ${#TRACK} -le 3 ]] && TRACK=$(printf "%03d\\n" ${TRACK})

    OUTFILE="${TRACK} - ${TITLE}.mp3"
    # OUTFILE=$(echo "${OUTFILE}" | sed 's/.*: \(.*\)/\1/;s/[&#*?!]//g')
    OUTFILE=$(echo "${OUTFILE}" | sed 's/[&#*?!]//g')

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

  if [ ${DO_RETAG} ] ; then

    for MTANK in ${TANK_MEDIA} ${TANK_SYNCTHING} ; do
      if [ -f "${TANK_LOCAL}/$(basename "${OUTFILE}")" ] ; then
        echo "RETAGGING ${TANK_LOCAL}/$(basename "${OUTFILE}")"
        EpisodeTagging "${TANK_LOCAL}/$(basename "${OUTFILE}")"
        [ -f "${MTANK}/$(basename "${OUTFILE}")" ] && cp -av "${TANK_LOCAL}/$(basename "${OUTFILE}")" "${MTANK}/$(basename "${OUTFILE}")"
      fi
    done

  else

    if [ ! -f "${TANK_LOCAL}/${OUTFILE}" ] ; then
      [ ${DEBUG} ] && echo "NEED: ${OUTFILE}"

      GetEpisode "${TRACK}" "${TITLE}" "${OUTFILE}" "${PUBDATE}" "${EPURL}"
      EpisodeTagging
      CopyEpisode "${TANK_LOCAL}/${OUTFILE}"
      [ ! ${NO_SLACK} ] && AnnounceEpisode

    else [ -f "${TANK_LOCAL}/${OUTFILE}" ]
      [ ${DEBUG} ] && echo "HAVE: ${OUTFILE}"

      touch -d "$(date -d "${PUBDATE}" +%Y-%m-%d)" "${TANK_LOCAL}/${OUTFILE}"
      CopyEpisode "${TANK_LOCAL}/${OUTFILE}"
    fi

    UnsetThese
  fi

  UnsetThese
  [ ${DEBUG} ] && echo "---------"
}



function WriteFeed() {
  curl -A "${UA}" -sL "${URL_RSS}" | xmllint --format --output "/tmp/${GENERIC_NAME}.xml" -
  ITEM_COUNT=$(xmllint --format --xpath "count(//item)" "/tmp/${GENERIC_NAME}.xml")
}



function GetItem() {

  ITEM=$1

  xmllint --xpath "//item[$ITEM]/title | //item[$ITEM]/enclosure/@url | //item[$ITEM]/pubDate | //item[$ITEM]/*[name()='itunes:image'] | //item[$ITEM]/*[name()='itunes:episodeType'] | //item[$ITEM]/*[name()='itunes:episode'] | //item[$ITEM]/*[name()='itunes:season'] | //item/*[@medium='audio']" "/tmp/${GENERIC_NAME}.xml" \
  | sed 's/"//g;s/\&amp\;/\&/g;s/^[\ \t]\+//g;s/<\!\[CDATA\[//g;s/\]\]>//g' \
  | sed 's/<title>\(.*\)<\/title>/RAW_TITLE="\1"/' \
  | sed 's/<pubDate>\(.*\)<\/pubDate>/PUBDATE="\1"/' \
  | sed 's/<description>\(.*\)<\/description>/DESCRIPTION="\1"/' \
  | sed 's/^url="\?\(.*mp3\).*/EPURL="\1"/' \
  | sed 's/.*media:content.*url=\(.*\)\/>$/MEDIA="\1"/' \
  | sed 's/.*itunes:episodeType>\(.*\)<\/itunes.*/TYPE="\1"/' \
  | sed 's/.*itunes:season>\(.*\)<\/itunes.*/SEASON="\1"/' \
  | sed 's/.*itunes:episode>\(.*\)<\/itunes.*/TRACK="\1"/' \
  | sed 's/.*itunes:image href=\(.*\.[a-zA-Z]\+\).*/IMAGE="\1"/'
}



function DumpFound() {
  echo "FOUND ALL:"
  [ "${DO_RETAG}" ] && echo -e "\\tDO_RETAG: ${DO_RETAG}"
  [ "${EPISODE}" ] && echo -e "\\tEPISODE: ${EPISODE}"
  [ "${EPURL}" ] && echo -e "\\tEPURL: ${EPURL}"
  [ "${GENERIC_NAME}" ] && echo -e "\\tGENERIC_NAME: ${GENERIC_NAME}"
  [ "${IMAGE}" ] && echo -e "\\tIMAGE: ${IMAGE}"
  [ "${OUTFILE}" ] && echo -e "\\tOUTFILE: ${OUTFILE}"
  [ "${PART}" ] && echo -e "\\tDO_RETAG: ${PART}"
  [ "${PODCAST_ALBUM_ART}" ] && echo -e "\\tPODCAST_ALBUM_ART: ${PODCAST_ALBUM_ART}"
  [ "${PRETTY_NAME}" ] && echo -e "\\tPRETTY_NAME: ${PRETTY_NAME}"
  [ "${PUBDATE}" ] && echo -e "\\tPUBDATE: ${PUBDATE}"
  [ "${PUBEPOCH}" ] && echo -e "\\tPUBEPOCH: ${PUBEPOCH}"
  [ "${RAW_TITLE}" ] && echo -e "\\tRAW_TITLE: ${RAW_TITLE}"
  [ "${SEASON}" ] && echo -e "\\tSEASON: ${SEASON}"
  [ "${TITLE}" ] && echo -e "\\tTITLE: ${TITLE}"
  [ "${TRACK}" ] && echo -e "\\tTRACK: ${TRACK}"
  [ "${TYPE}" ] && echo -e "\\tTYPE: ${TYPE}"
  [ "${WORD_NUMS}" ] && echo -e "\\tDO_RETAG: ${WORD_NUMS}"
}


function UnsetThese() {
  unset EPURL IMAGE MEDIA NEW_EPISODE OLD OUTFILE PART PUBDATE PUBEPOCH SEASON TITLE TRACK TYPE
}

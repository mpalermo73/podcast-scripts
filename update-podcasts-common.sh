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

TANK="/usr/local/Podcasts/${PRETTY_NAME}"
PODCAST_ALBUM_ART="${TANK}/${PRETTY_NAME}.jpg"
QUALITY=100
MAX_DIMENSION="1000"
MAX_SIZE="1024"

ITEM_COUNT="${ITEM_COUNT:-0}"

[ ! ${DEBUG} ] && WGET_DEBUG="--quiet"
# [ ! "${DATE_MIN}" ] && DATE_MIN=$(date -d "- 100 year" "+%F")
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
    echo -e "IMAGE var is not set and \"${PODCAST_ALBUM_ART}\" not found"
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
        # if [ ${UPDATE_SYNCTHING} ] && [ ${NEW_EPISODE} ] ; then
        if [ ${UPDATE_SYNCTHING} ] ; then
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

    if [ ! -f "${TANK}/${OUTFILE}" ] ; then
      [ ${DEBUG} ] && echo "NEED: ${OUTFILE}"

      GetEpisode "${TRACK}" "${TITLE}" "${OUTFILE}" "${PUBDATE}" "${EPURL}"
      EpisodeTagging
      CopyEpisode "${TANK}/${OUTFILE}"
      [ ! ${NO_SLACK} ] && AnnounceEpisode

    else [ -f "${TANK}/${OUTFILE}" ]
      [ ${DEBUG} ] && echo "HAVE: ${OUTFILE}"

      touch -d "$(date -d "${PUBDATE}" +%Y-%m-%d)" "${TANK}/${OUTFILE}"
      CopyEpisode "${TANK}/${OUTFILE}"
    fi

    UnsetThese
  fi

  UnsetThese
  [ ${DEBUG} ] && echo "---------"
}



function WriteFeed() {
  curl -sL "${URL_RSS}" | xmllint --format --output "/tmp/${GENERIC_NAME}.xml" -
  ITEM_COUNT=$(xmllint --format --xpath "count(//item)" "/tmp/${GENERIC_NAME}.xml")
}


function GetItem() {
  xmllint --xpath "//item[$1]/title | //item[$1]/enclosure/@url | //item[$1]/pubDate | //item[$1]/*[name()='itunes:image'] | //item[$1]/*[name()='itunes:episodeType'] | //item[$1]/*[name()='itunes:season'] | //item/*[@medium='audio']" "/tmp/${GENERIC_NAME}.xml" \
  | sed 's/"//g;s/\&amp\;/\&/g;s/^[\ \t]\+//g;s/<\!\[CDATA\[//g;s/\]\]>//g' \
  | sed 's/<title>\(.*\)<\/title>/RAW_TITLE="\1"/' \
  | sed 's/<pubDate>\(.*\)<\/pubDate>/PUBDATE="\1"/' \
  | sed 's/<description>\(.*\)<\/description>/DESCRIPTION="\1"/' \
  | sed 's/^url="\?\(.*mp3\).*/EPURL="\1"/' \
  | sed 's/.*media:content.*url=\(.*\)\/>$/MEDIA="\1"/' \
  | sed 's/.*itunes:episodeType>\(.*\)<\/itunes.*/TYPE="\1"/' \
  | sed 's/.*itunes:season>\(.*\)<\/itunes.*/SEASON="\1"/' \
  | sed 's/.*itunes:episode>\(.*\)<\/itunes.*/TRACK="\1"/' \
  | sed 's/.*itunes:image href=\(.*\.[a-zA-Z]\{3\}\).*/IMAGE="\1"/'
}



function DumpFound() {
  echo "FOUND ALL:"
  [ "${DO_RETAG}" ] && echo -e "\\tDO_RETAG: ${DO_RETAG}"
  [ "${EPURL}" ] && echo -e "\\tEPURL: ${EPURL}"
  [ "${GENERIC_NAME}" ] && echo -e "\\tGENERIC_NAME: ${GENERIC_NAME}"
  [ "${IMAGE}" ] && echo -e "\\tIMAGE: ${IMAGE}"
  [ "${OUTFILE}" ] && echo -e "\\tOUTFILE: ${OUTFILE}"
  [ "${PART}" ] && echo -e "\\tDO_RETAG: ${PART}"
  [ "${PODCAST_ALBUM_ART}" ] && echo -e "\\PODCAST_ALBUM_ART: ${PODCAST_ALBUM_ART}"
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

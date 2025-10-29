#!/usr/bin/env bash

# NOTE: mp3gain -s r -T -r -p -c *mp3

# PATH=$PATH:/usr/local/bin

source $HOME/GIT/scripts-git/shell_colors.sh

IFS_BAK=$IFS
IFS=$'\n'

GENERIC_NAME=$(echo "${PRETTY_NAME}" | sed 's/[ \t,]\+//g')
[ ! "${GENRE}" ] && GENRE="Podcast"

HERE=$(dirname $0)
MOUNT_MEDIA="/mnt/MEDIA"
TANK_MEDIA="${MOUNT_MEDIA}/Podcasts/${PRETTY_NAME}"

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
[ ! -d "${TANK_LOCAL}" ] && [ ! "${JUST_TEST}" ] && mkdir -p "${TANK_LOCAL}"

if [ $# -eq 1 ] && [[ "$1" =~ ^[rR][eE][tT][aA][gG]$ ]] ; then
  DO_RETAG=TRUE
fi

LAST_YEAR=$(date -d "last year" +%y)

function GetPodcastImage() {

  if [ "${IMAGE}" ] ; then

    PODCAST_ALBUM_ART="/tmp/${PRETTY_NAME}.jpg"
    curl -A "${UA}" -sL "${IMAGE}" | magick - -resize ${MAX_DIMENSION} -define jpeg:extent=${MAX_SIZE}K "${PODCAST_ALBUM_ART}"
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
        if [ ! ${NO_UPDATE_SYNCTHING} ] ; then
          # [ ${DEBUG} ] && echo "UPDATING ${MTANK}"
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
          # [ ${DEBUG} ] && echo "UPDATING ${MTANK}"
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

  [ ${DEBUG} ] && echo "========================== STRIP MP3 TAGS =========================="
  [ ${DEBUG} ] && echo "Stripping tags from ${TAGGING_FILE}"
  [ ${DEBUG} ] && echo "Using eyeD3 to remove all tags from ${TAGGING_FILE}"
  [ ${DEBUG} ] && echo "Tagging ${TAGGING_FILE} with:"
  [ ${DEBUG} ] && echo "  TITLE: ${TITLE}"
  [ ${DEBUG} ] && echo "  TRACK: ${TRACK}"
  [ ${DEBUG} ] && echo "  YEAR: ${YEAR}"
  [ ${DEBUG} ] && echo "  GENRE: ${GENRE}"
  [ ${DEBUG} ] && echo "  PRETTY_NAME: ${PRETTY_NAME}"
  [ ${DEBUG} ] && echo "  PODCAST_ALBUM_ART: ${PODCAST_ALBUM_ART}"
  # eyeD3 -l critical --no-color --preserve-file-times --quiet --remove-all "${TAGGING_FILE}" &>/dev/null
  # eyeD3 --no-color --preserve-file-times --quiet --remove-all "${TAGGING_FILE}" &>/dev/null
  id3convert --strip "${TAGGING_FILE}" > /dev/null

  [ ${DEBUG} ] && echo "Stripped tags from ${TAGGING_FILE}"

  [ ${DEBUG} ] && echo "========================== WRITE MP3 TAGS =========================="
 	# eyeD3 -l critical --force-update --no-color --preserve-file-times --quiet \

[ ${DEBUG} ] && echo "eyeD3 --force-update --no-color --preserve-file-times --quiet \
	--add-image=\"${PODCAST_ALBUM_ART}\":FRONT_COVER:\"${PRETTY_NAME}\" \
	--text-frame=\"TYER:${YEAR}\" \
	--text-frame=\"TPOS:\" \
	-t \"${TITLE}\" \
	-G \"${GENRE}\" \
	-A \"${PRETTY_NAME} Podcast\" \
	-a \"${PRETTY_NAME}\" \
	-n \"${TRACK}\" \
	\"${TAGGING_FILE}\""

 	eyeD3 --force-update --no-color --preserve-file-times --quiet \
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

  OUTFILE_SIZE=$(du -s "${TANK_LOCAL}/${OUTFILE}" | cut -f1)

  if [ ${OUTFILE_SIZE} -eq 0 ] ; then
    [ ${DEBUG} ] && echo "BAD DOWNLOAD: ${OUTFILE_SIZE}. Trying again..."
    sleep 3
    wget ${WGET_DEBUG} "${FILEURL}" -O "${TANK_LOCAL}/${OUTFILE}"
  fi
}



function AnnounceEpisode() {
  [ ! "${IMAGE}" ] && OUTPUT="New Episode!\n"
  [ "${IMAGE}" ] && OUTPUT="<${IMAGE}|${PRETTY_NAME}>\n"
  OUTPUT+="<${FILEURL}|${TITLE}>\n"
  # [ ! ${NO_UPDATE_SYNCTHING} ] && [ ${NEW_EPISODE} ] && OUTPUT+="Copied to Syncthing"
  [ ! ${NO_UPDATE_SYNCTHING} ] && OUTPUT+="Copied to Syncthing"

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
    # [[ ${#TRACK} -le 3 ]] && TRACK=$(printf "%03d\\n" ${TRACK})

    [[ ${#TRACK} -lt 2 ]] && TRACK="0${TRACK}"
    [[ ${#TRACK} -lt 3 ]] && TRACK="0${TRACK}"


    OUTFILE="${TRACK} - ${TITLE}.mp3"
    # OUTFILE=$(echo "${OUTFILE}" | sed 's/.*: \(.*\)/\1/;s/[&#*?!]//g')
    OUTFILE=$(echo "${OUTFILE}" | sed 's/[&#*?¡!\/]//g ; s/:/ -/g')

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
  # curl -A "${UA}" -sL "${URL_RSS}" | xmllint --format --output "/tmp/${GENERIC_NAME}.xml" -
  curl -sL "${URL_RSS}" | xmllint --format --output "/tmp/${GENERIC_NAME}.xml" -
  ITEM_COUNT=$(xmllint --format --xpath "count(//item)" "/tmp/${GENERIC_NAME}.xml")
}



function GetItem() {

  ITEM=$1

  xmllint --xpath "//item[$ITEM]/title | //item[$ITEM]/enclosure/@url | //item[$ITEM]/pubDate | //item[$ITEM]/*[name()='itunes:image'] | //item[$ITEM]/*[name()='itunes:episodeType'] | //item[$ITEM]/*[name()='itunes:episode'] | //item[$ITEM]/*[name()='itunes:season'] | //item[$ITEM]/*[@medium='audio']" "/tmp/${GENERIC_NAME}.xml" \
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



function GetItemJson(){
  
  ITEM=$1

  yq --input-format xml --output-format json "/tmp/${GENERIC_NAME}.xml" > "/tmp/${GENERIC_NAME}.json"

  

  jq -r ".rss.channel.item[$((ITEM - 1))] | .title as \$title | .pubDate as \$pubDate | .enclosure.url as \$epurl | .itunes.image.href as \$image | .itunes.episodeType as \$type | .itunes.episode as \$track | .itunes.season as \$season | {RAW_TITLE: (\$title | if type == \"array\" then (.[0] | tostring) else (.|tostring) end), PUBDATE: \$pubDate, EPURL: \$epurl, IMAGE: \$image, TYPE: \$type, TRACK: \$track, SEASON: \$season}"
}



function DumpFound() {
  echo "FOUND THESE:"
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
  [ "${GENRE}" ] && echo -e "\\tGENRE: ${GENRE}"
  # echo "---------------------------"
}


function UnsetThese() {
  unset EPURL IMAGE MEDIA NEW_EPISODE OLD OUTFILE PART PUBDATE PUBEPOCH SEASON TITLE TRACK TYPE
}


#  curl -sL "rss" | yq --input-format xml --output-format json - | sed 's/\(.*\s\+"\)+@\?/\1/'

# {
# "title": "Feed Drop! Unwell 1.01: Homecoming",
# "episodeType": "trailer"
# }
# {
# "title": [
# "2.09 Extraordinary Times",
# "Extraordinary Times"
# ],
# "episodeType": "full"
# }
# jq '.rss.channel.item[] | select(.episodeType == "full") | .title = (.title | if type=="array" then (.[0]|tostring) else (.|tostring) end) | {title,episodeType}'

# {
# "pubDate": "Wed, 11 Dec 2024 05:02:00 -0000",
# "title": "The Matty Tapes - 3 - Christmas 1996",
# "number": 62
# }
# palermo@aragorn [10:27:33 AM EDT] [~/Desktop/F & F]
# curl -sL "https://fableandfolly.supportingcast.fm/content/eyJ0IjoicCIsImMiOiIxNjUwIiwidSI6IjIyNTkyMTEiLCJkIjoiMTY0MzMxNzU1OSIsImsiOjI4NX18MDA1ZWMxZmY5NzE4NWIxYjc4ZTJkZWYxNTdjMzJmNjE5Y2FkYTNiNmE0OGU2NGI1ODdhMGVkYWRiZDc3Y2QzZQ.rss" | yq --input-format xml --output-format json | sed 's/"+\?@\?/"/g' | jq . | jq '.rss.channel.item | reverse | range(0; length) as $i | (.[$i]) + {indexNumber: ($i + 1)} | .title = (.title | if type=="array" then (.[0]|tostring) else (.|tostring) end) | . '


# -> % cat ~/Desktop/oz9.json | jq '.rss.channel.item[1] | .title = (.title | if type=="array" then (.[0]|tostring) else (.|tostring) end) | .description = (.description // .summary) | .url = (.enclosure.url) | .image=(.image.href) | {title,pubDate,episodeType,season,episode,url,image,description}'

# | sed 's/"+\?@\?/"/g' 


# -> % cat ~/Desktop/oz9.json | jq -r '.rss.channel.item[10] | 
  # "RAW_TITLE=\""+ (.title | if type=="array" then (.[0]|tostring) else (.|tostring) end) +"\"", 
  # "PUBDATE=\""+ .pubDate +"\"", 
  # "DESCRIPTION=\""+ (.description // .summary) +"\"", 
  # "EPURL=\""+ (.enclosure.url) +"\"", 
  # (if select(.image.href != null) then "IMAGE=\""+ .image.href +"\"" end),
  # (if select(.episodeType != null) then "TYPE=\""+ .episodeType +"\"" end),
  # (if select(.season != null) then "SEASON=\""+ .season +"\"" end),
  # (if select(.episode != null) then "TRACK=\""+ .episode +"\"" end),
  # (if select(.poop != null) then "POOP=\""+ .poop +"\"" end)
  # '

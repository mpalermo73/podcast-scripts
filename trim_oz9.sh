#!/usr/bin/env zsh

if [ ! "$1" ] ; then
  echo "give me a file"
  exit 1
fi

if [ ! -f "$1" ] ; then
  echo "\"$1\" is not a file"
  exit 1
fi


EPISODE="$1"


ffmpeg -y -loglevel error -i "$EPISODE" -t 5:00 "${EPISODE[0,3]%.mp3}.wav"

INTRO="$(find_sample.py samples/oz9_intro_full_mono.wav "${EPISODE[0,3]%.mp3}.wav" 2>/dev/null)"


ffmpeg -y -loglevel error -ss "$INTRO" -i "$EPISODE" "${EPISODE[0,3]%.mp3}_tail.wav"
ffmpeg -y -loglevel error -ss "$INTRO" -i "$EPISODE" -acodec copy "${EPISODE[0,3]}_tail.mp3"


OUTRO="$(find_sample.py samples/oz9_intro_full_mono.wav "${EPISODE[0,3]%.mp3}_tail.wav" 2>/dev/null)"


ffmpeg -y -loglevel error -i "${EPISODE[0,3]}_tail.mp3" -t "$OUTRO" -acodec copy "${EPISODE[0,3]}.mp3"


eyeD3 --write-images=. "$EPISODE"

eyeD3 --add-image="FRONT_COVER.jpg":FRONT_COVER:"$(basename $PWD)" "${EPISODE[0,3]}.mp3"

touch -r "$EPISODE" "${EPISODE[0,3]}.mp3"

mv "$EPISODE" BAK/

mv -vi "${EPISODE[0,3]}.mp3" "$EPISODE"


rm FRONT_COVER.jpg "${EPISODE[0,3]%.mp3}.wav" "${EPISODE[0,3]%.mp3}_tail.wav" "${EPISODE[0,3]}_tail.mp3"
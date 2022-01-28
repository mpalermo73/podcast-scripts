#!/usr/bin/env bash

TOKEN=$($HOME/GIT/podcast-scripts/blizzard_api_token.sh)

RENDER=$(curl -sL -H "Authorization: Bearer ${TOKEN}" "https://us.api.blizzard.com/profile/wow/character/dawnbringer/lofar/character-media?namespace=profile-us&locale=en_US" | jq -r '.assets[3].value')

#echo TOKEN: $TOKEN
#echo RENDER: $RENDER

#wget -q "${RENDER}" -O $HOME/.local/share/lutris/coverart/world-of-warcraft.jpg

# curl -sL https://render-us.worldofwarcraft.com/character/dawnbringer/52/181114420-main-raw.png | convert  -trim +repage - /usr/local/palermo/.local/share/lutris/coverart/world-of-warcraft.jpg

curl -sL ${RENDER} | convert - /usr/local/palermo/.local/share/lutris/coverart/world-of-warcraft.jpg

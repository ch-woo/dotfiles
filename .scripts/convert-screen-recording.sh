#!/bin/bash

INPUT="$1"
INPUT_DIR=$(dirname "$INPUT")
EXT="${INPUT##*.}"

# Skip if already .mp4 (to prevent looping)
if [[ "$INPUT" == *.mp4 ]]; then
  echo "Already processed: $INPUT" >> ~/scripts/conversion_log.txt
  exit 0
fi

# Check MIME type
MIME_TYPE=$(file --mime-type -b "$INPUT")
if [[ "$MIME_TYPE" != video/* ]]; then
  echo "Skipped non-video file: $INPUT ($MIME_TYPE)" >> ~/scripts/conversion_log.txt
  exit 0
fi

# Build nice timestamp filename
TIMESTAMP=$(date +"%Y-%m-%d at %H.%M.%S")
BASENAME="Screen Recording ${TIMESTAMP}"
OUTPUT="$INPUT_DIR/${BASENAME}.mp4"

# Avoid overwriting if same second
COUNTER=1
while [[ -e "$OUTPUT" ]]; do
  OUTPUT="$INPUT_DIR/${BASENAME} $COUNTER.mp4"
  ((COUNTER++))
done

# Convert
/opt/homebrew/bin/ffmpeg -i "$INPUT" -vcodec libx264 -crf 23 -preset fast "$OUTPUT"

# Delete original
rm "$INPUT"

echo "Converted: $INPUT → $OUTPUT" >> ~/scripts/conversion_log.txt

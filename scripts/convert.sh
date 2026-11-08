#!/bin/sh
set -e
apk add --no-cache ffmpeg >/dev/null
mkdir -p /work/sounds
for f in /work/source/usr/share/sounds/freedesktop/stereo/*.oga; do
  b=$(basename "$f" .oga)
  case "$b" in
    audio-channel-*|audio-test-signal) continue ;;
  esac
  echo "CONVERT $b"
  ffmpeg -y -hide_banner -loglevel error -i "$f" -acodec pcm_s16le -ar 44100 -ac 2 "/work/sounds/${b}.wav"
done
ls -la /work/sounds

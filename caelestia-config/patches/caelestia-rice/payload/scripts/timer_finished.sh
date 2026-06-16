#!/usr/bin/env bash

TITLE="Timer finished"
BODY="Your countdown is complete."

if command -v notify-send >/dev/null 2>&1; then
  notify-send --app-name="Caelestia Timer" --urgency=normal --icon=alarm-symbolic "$TITLE" "$BODY"
fi

if command -v canberra-gtk-play >/dev/null 2>&1; then
  canberra-gtk-play -i complete -d "Timer finished" 2>/dev/null \
    || canberra-gtk-play -i alarm -d "Timer finished" 2>/dev/null \
    || true
elif command -v paplay >/dev/null 2>&1; then
  for sound in \
    /usr/share/sounds/freedesktop/stereo/complete.oga \
    /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga \
    /usr/share/sounds/freedesktop/stereo/bell.oga \
    /usr/share/sounds/freedesktop/stereo/message.oga
  do
    if [[ -f "$sound" ]]; then
      paplay "$sound" >/dev/null 2>&1 || true
      exit 0
    fi
  done
elif command -v pw-play >/dev/null 2>&1; then
  for sound in \
    /usr/share/sounds/freedesktop/stereo/complete.oga \
    /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga \
    /usr/share/sounds/freedesktop/stereo/bell.oga \
    /usr/share/sounds/freedesktop/stereo/message.oga
  do
    if [[ -f "$sound" ]]; then
      pw-play "$sound" >/dev/null 2>&1 || true
      exit 0
    fi
  done
fi

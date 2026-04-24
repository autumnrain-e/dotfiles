#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Focus Left Half
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ◧

osascript -e '
tell application "Finder"
  set screenBounds to bounds of window of desktop
  set screenWidth to item 3 of screenBounds
  set screenHeight to item 4 of screenBounds
end tell
tell application "System Events"
  set frontApp to first application process whose frontmost is true
  set padTop to 48
  set padSide to 8
  set padBottom to 8
  set halfWidth to (screenWidth / 2)
  tell frontApp
    set frontWindow to first window
    set position of frontWindow to {padSide, padTop}
    set size of frontWindow to {halfWidth - (padSide * 2), screenHeight - padTop - padBottom}
  end tell
end tell'

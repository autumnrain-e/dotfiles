#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Focus Maximize
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔲

osascript -e '
tell application "Finder"
  set screenBounds to bounds of window of desktop
  set screenWidth to item 3 of screenBounds
  set screenHeight to item 4 of screenBounds
end tell
tell application "System Events"
  set frontApp to first application process whose frontmost is true
  -- Hide all other apps
  set visible of every process whose name is not (name of frontApp) and visible is true to false
  -- Maximize the front window with padding
  set padTop to 48 
  set padSide to 8
  set padBottom to 8
  tell frontApp
    set frontWindow to first window
    set position of frontWindow to {padSide, padTop}
    set size of frontWindow to {screenWidth - (padSide * 2), screenHeight - padTop - padBottom}
  end tell
end tell'

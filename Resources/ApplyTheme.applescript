tell application "Terminal"
    set oldWindowIDs to id of every window
    open POSIX file "__THEME_PATH__"
    set importedWindow to front window
    set importedWindowID to id of importedWindow
    set importedProfile to current settings of selected tab of importedWindow
    set default settings to importedProfile
    set startup settings to importedProfile
    repeat with terminalWindow in every window
        repeat with terminalTab in tabs of terminalWindow
            set current settings of terminalTab to importedProfile
        end repeat
    end repeat
    if (count oldWindowIDs) > 0 and importedWindowID is not in oldWindowIDs then
        close importedWindow
    end if
end tell

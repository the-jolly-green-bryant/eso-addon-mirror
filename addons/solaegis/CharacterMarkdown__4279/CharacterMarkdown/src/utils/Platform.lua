-- CharacterMarkdown - Platform Detection
-- Detects operating system based on file paths

local CM = CharacterMarkdown

CM.utils = CM.utils or {}

-- Detect OS based on saved variables path structure
local function DetectOperatingSystem(forceRedetect)
    local settings = CM.GetSettings()

    -- Check if already detected and saved (unless forcing re-detection)
    if not forceRedetect and settings and settings.detectedOS and settings.detectedOS ~= "unknown" then
        return settings.detectedOS
    end

    -- Try to auto-detect based on filesystem path
    local detectedOS

    -- GetAddOnSavedVariablesDirectory() returns paths like:
    -- Mac:     /Users/username/Documents/Elder Scrolls Online/live/SavedVariables/
    -- Windows: C:\Users\username\Documents\Elder Scrolls Online\live\SavedVariables\
    local svPath = GetAddOnSavedVariablesDirectory and GetAddOnSavedVariablesDirectory()

    if svPath then
        -- Mac paths start with / and use forward slashes
        -- Check if path starts with / (Unix/Mac style) or contains /Users/ with forward slashes
        local startsWithSlash = string.sub(svPath, 1, 1) == "/"
        local hasMacUsersPath = string.find(svPath, "/Users/", 1, true) ~= nil
        local hasMacDocumentsPath = string.find(svPath, "/Documents/", 1, true) ~= nil

        -- Windows paths typically start with C:\ or use backslashes
        local startsWithWindowsDrive = string.find(svPath, "^[A-Z]:\\", 1, false) ~= nil -- Pattern mode for drive letter
        local hasWindowsBackslashes = string.find(svPath, "\\Users\\", 1, true) ~= nil
            or string.find(svPath, "\\Documents\\", 1, true) ~= nil

        -- Prioritize Mac detection - check Mac patterns first
        if startsWithSlash or hasMacUsersPath or hasMacDocumentsPath then
            detectedOS = "mac"
        elseif startsWithWindowsDrive or hasWindowsBackslashes then
            detectedOS = "windows"
        else
            -- If we can't determine, check if path contains forward slashes (more likely Mac)
            -- or backslashes (more likely Windows)
            local hasForwardSlashes = string.find(svPath, "/", 1, true) ~= nil
            local hasBackslashes = string.find(svPath, "\\", 1, true) ~= nil

            if hasForwardSlashes and not hasBackslashes then
                detectedOS = "mac"
            elseif hasBackslashes and not hasForwardSlashes then
                detectedOS = "windows"
            else
                -- Last resort: default to unknown instead of assuming Windows
                detectedOS = "unknown"
                CM.DebugPrint("PLATFORM", "Could not detect OS from path: " .. svPath)
            end
        end
    else
        -- Fallback if API not available
        detectedOS = "unknown"
        CM.DebugPrint("PLATFORM", "GetAddOnSavedVariablesDirectory not available")
    end

    -- Save the detected OS to SavedVariables (persist permanently)
    if CharacterMarkdownSettings then
        local previousOS = CharacterMarkdownSettings.detectedOS
        CharacterMarkdownSettings.detectedOS = detectedOS
        CharacterMarkdownSettings._lastModified = GetTimeStamp()
        CM.InvalidateSettingsCache()

        -- Only log if OS changed or detection failed
        if previousOS and previousOS ~= "unknown" and previousOS ~= detectedOS then
            CM.DebugPrint("PLATFORM", string.format("OS changed: %s -> %s", previousOS, detectedOS))
        elseif detectedOS == "unknown" then
            CM.DebugPrint("PLATFORM", "OS detection failed")
        end
    end

    return detectedOS
end

-- Get keyboard shortcut text for current OS
local function GetShortcutText(action)
    local os = DetectOperatingSystem()

    if action == "select_all" then
        if os == "mac" then
            return "Cmd+A"
        else
            return "Ctrl+A"
        end
    elseif action == "copy" then
        if os == "mac" then
            return "Cmd+C"
        else
            return "Ctrl+C"
        end
    elseif action == "paste" then
        if os == "mac" then
            return "Cmd+V"
        else
            return "Ctrl+V"
        end
    elseif action == "select_copy" then
        if os == "mac" then
            return "Cmd+A then Cmd+C"
        else
            return "Ctrl+A then Ctrl+C"
        end
    end

    return ""
end

-- Allow manual OS override (useful for initial setup or if detection fails)
local function SetOperatingSystem(os)
    if os ~= "windows" and os ~= "mac" then
        CM.Error("Invalid OS. Use 'windows' or 'mac'")
        return false
    end

    if CharacterMarkdownSettings then
        CharacterMarkdownSettings.detectedOS = os
        CharacterMarkdownSettings._lastModified = GetTimeStamp()
        CM.InvalidateSettingsCache()
        CM.Info("OS set to: " .. os)
        return true
    end

    return false
end

-- Reset cached OS detection to force re-detection
local function ResetOperatingSystem()
    if CharacterMarkdownSettings then
        CharacterMarkdownSettings.detectedOS = "unknown"
        CharacterMarkdownSettings._lastModified = GetTimeStamp()
        CM.InvalidateSettingsCache()
        CM.Info("OS detection reset - re-detecting...")
        -- Force immediate re-detection
        return DetectOperatingSystem(true) ~= "unknown"
    end
    return false
end

CM.utils.Platform = {
    DetectOperatingSystem = DetectOperatingSystem,
    GetShortcutText = GetShortcutText,
    SetOperatingSystem = SetOperatingSystem,
    ResetOperatingSystem = ResetOperatingSystem,
}

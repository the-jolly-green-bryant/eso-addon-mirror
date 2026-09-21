ClayladonsFriendStatus = {}
ClayladonsFriendStatus.name = "ClayladonsFriendStatus"

-- Define default values for SavedVars here:
local defaultSettings = {
    showAccountName = true,
    showCharacterName = true,
    showZone = true,
    onLogin = true,
    showFriends = true,
    showWatchlist = false,
    friendsColour = { r = 0.63, g = 0.51, b = 0.75 },
    watchlists = {
        [1] = { name = "Watchlist #1", rawText = "", enabled = true, colour = { r = 0.35, g = 0.75, b = 1.00 }},
        [2] = { name = "Watchlist #2", rawText = "", enabled = false, colour = { r = 1.00, g = 0.80, b = 0.20 }},
        [3] = { name = "Watchlist #3", rawText = "", enabled = false, colour = { r = 0.40, g = 1.00, b = 0.40 }},
        [4] = { name = "Watchlist #4", rawText = "", enabled = false, colour = { r = 1.00, g = 0.40, b = 0.40 }},
    }
}

-- Helper function to automatically format and print text stylishly
local function stylish_print(in_text, in_hexColour)
    -- d("|cA183C0" .. in_text .. "|r")
    local targetColour = in_hexColour or "A183C0"
    d("|c" .. targetColour .. in_text .. "|r")
end

-- Helper function to parse the raw watchlist string
local function GetWatchlistSet(in_rawText)
    local watchlistSet = {}
    local rawText = in_rawText or ""

    -- Split the raw string on commas
    for name in string.gmatch(rawText, "([^,\r\n]+)") do
        -- Remove whitespace
        name = name:match("^%s*(.-)%s*$")
        -- If this is actually a name
        if name and name ~= "" then
            -- Prepend '@' if the user forgot to add it
            if not name:find("^@") then
                name = "@" .. name
            end
            -- Store it lowercase
            watchlistSet[string.lower(name)] = true
        end
    end
    return watchlistSet
end

-- Helper function to print info given the flexibility with SavedVars
local function printInfo(in_displayName, in_sanitizedCharacterName, in_zoneName, in_hexColour)
    local outputString1 = in_displayName or ""
    local outputString2 = " is playing "
    local outputString3 = in_sanitizedCharacterName or ""
    local outputString4 = " in "
    local outputString5 = in_zoneName or ""

    if not ClayladonsFriendStatus.savedVars.showAccountName then
        outputString1 = ""
        outputString2 = ""
    end

    if not ClayladonsFriendStatus.savedVars.showCharacterName then
        outputString2 = ""
        outputString3 = ""
    end

    if not ClayladonsFriendStatus.savedVars.showZone then
        outputString4 = ""
        outputString5 = ""
    end

    if not (ClayladonsFriendStatus.savedVars.showAccountName or ClayladonsFriendStatus.savedVars.showCharacterName) then
        outputString4 = ""
    end

    stylish_print(string.format("  * %s%s%s%s%s", outputString1, outputString2, outputString3, outputString4, outputString5), in_hexColour)
end

-- Helper function to translate from RGB colour to Hex colour
local function GetHexColour(in_RGBColour)
    if not in_RGBColour then return "ffffff" end
    local r = math.floor(in_RGBColour.r * 255)
    local g = math.floor(in_RGBColour.g * 255)
    local b = math.floor(in_RGBColour.b * 255)
    return string.format("%02x%02x%02x", r, g, b)
end

-- Print to chat window
local function PrintOnlineFriends()
    -- Output heading, no matter what
    stylish_print("[Clayladon's Friend Status]:", "A183C0")
    local friendsHexColour = GetHexColour(ClayladonsFriendStatus.savedVars.friendsColour)

    -- Friends section
    if ClayladonsFriendStatus.savedVars.showFriends then
        stylish_print("Friends:", friendsHexColour)

        -- Grab total number of friends to bind the loop
        local totalFriends = GetNumFriends()
        local anyoneOnline = false
        
        -- If no friends, print and bail
        if totalFriends == 0 then
            stylish_print("Your friends list is currently empty.", friendsHexColour)
        end

        -- For each friend, print their info
        for index = 1, totalFriends do
            local displayName, _, playerStatus = GetFriendInfo(index)
            if displayName and playerStatus then
                if playerStatus ~= PLAYER_STATUS_OFFLINE then
                    local hasCharacter, characterName, zoneName = GetFriendCharacterInfo(index)
                    if hasCharacter then
                        anyoneOnline = true
                        local sanitizedCharacterName = zo_strformat("<<1>>", characterName)

                        printInfo(displayName, sanitizedCharacterName, zoneName, friendsHexColour)
                    end
                end
            end
        end

        -- If nobody's online, print that
        if totalFriends > 0 and not anyoneOnline then
            stylish_print("    None of your friends are online right now.", friendsHexColour)
        end
    end

    -- Guild watchlist section
    if ClayladonsFriendStatus.savedVars.showWatchlist then
        for watchlistIndex = 1, 4 do
            local watchlistData = ClayladonsFriendStatus.savedVars.watchlists[watchlistIndex]
            if watchlistData.enabled and watchlistData.rawText ~= "" then

                local watchlistHexColour = GetHexColour(watchlistData.colour)
                stylish_print(" ", watchlistHexColour)
                stylish_print(watchlistData.name .. ":", watchlistHexColour)

                local watchlistSet = GetWatchlistSet(watchlistData.rawText)
                local watchlistOnline = false
                local printedWatchlist = {}

                -- Adding friends list to watchlist options
                local totalFriends = GetNumFriends()
                for friendIndex = 1, totalFriends do
                    local displayName, _, playerStatus = GetFriendInfo(friendIndex)
                    if displayName and playerStatus then
                        local lowerName = string.lower(displayName)
                        if playerStatus ~= PLAYER_STATUS_OFFLINE and watchlistSet[lowerName] and not printedWatchlist[lowerName] then
                            local hasCharacter, characterName, zoneName = GetFriendCharacterInfo(friendIndex)
                            if hasCharacter then
                                watchlistOnline = true
                                printedWatchlist[lowerName] = true
                                local sanitizedCharacterName = zo_strformat("<<1>>", characterName)

                                printInfo(displayName, sanitizedCharacterName, zoneName, watchlistHexColour)
                            end
                        end
                    end
                end

                -- Original watchlist print, checks guild rosters
                local numGuilds = GetNumGuilds()
                for guildIndex = 1, numGuilds do
                    local guildId = GetGuildId(guildIndex)
                    local numMembers = GetNumGuildMembers(guildId)

                    for memberIndex = 1, numMembers do
                        local displayName, _, _, playerStatus = GetGuildMemberInfo(guildId, memberIndex)
                        if displayName and playerStatus then
                            local lowerName = string.lower(displayName)
                            if playerStatus ~= PLAYER_STATUS_OFFLINE and watchlistSet[lowerName] and not printedWatchlist[lowerName] then
                                local hasCharacter, characterName, zoneName = GetGuildMemberCharacterInfo(guildId, memberIndex)

                                if hasCharacter then
                                    watchlistOnline = true
                                    printedWatchlist[lowerName] = true
                                    local sanitizedCharacterName = zo_strformat("<<1>>", characterName)
                                    
                                    printInfo(displayName, sanitizedCharacterName, zoneName, watchlistHexColour)
                                end
                            end
                        end
                    end
                end

                if not watchlistOnline then
                    stylish_print("    Nobody from " .. watchlistData.name .. " is online right now.", watchlistHexColour)
                end    
            end
        end
    end
end

-- Create the LibAddonMenu-2.0 settings panel
local function InitializeSettingsMenu()
    -- Create a pointer to the LibAddonMenu2 object
    local ptr_LibAddonMenu2 = LibAddonMenu2

    -- If LibAddonMenu2 doesn't exist, don't do anything else
    if not ptr_LibAddonMenu2 then return end

    -- Create the panel
    local panelData = {
        type = "panel",
        name = "Clayladon's Friend Status",
        displayName = "|cA183C0Clayladon's Friend Status|r",
        author = "@Clayladon",
        version = "1.0.9",
        registerForRefresh = true,
    }

    -- Design the panel
    local optionsTable = {
        {
            type = "header",
            name = "Watchlist Configuration",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Friend Status on Login",
            tooltip = "Uncheck this if you don't want to see Friend Status in your chat window on login.",
            getFunc = function()
                return ClayladonsFriendStatus.savedVars.onLogin
            end,
            setFunc = function(value)
                ClayladonsFriendStatus.savedVars.onLogin = value
            end,
            width = "full",
            default = defaultSettings.onLogin,
        },
        {
            type = "checkbox",
            name = "Show Friends",
            tooltip = "Uncheck this if you only want to see your Watchlist in Friend Status.",
            getFunc = function()
                return ClayladonsFriendStatus.savedVars.showFriends
            end,
            setFunc = function(value)
                ClayladonsFriendStatus.savedVars.showFriends = value
            end,
            width = "half",
            default = defaultSettings.showFriends,
        },
        {
            type = "colorpicker",
            name = "Friends' Colour",
            tooltip = "Text display colour for your Friends.",
            getFunc = function() 
                return ClayladonsFriendStatus.savedVars.friendsColour.r,
                        ClayladonsFriendStatus.savedVars.friendsColour.g,
                        ClayladonsFriendStatus.savedVars.friendsColour.b
            end,
            setFunc = function(r, g, b)
                ClayladonsFriendStatus.savedVars.friendsColour.r = r
                ClayladonsFriendStatus.savedVars.friendsColour.g = g
                ClayladonsFriendStatus.savedVars.friendsColour.b = b
            end,
            width = "half",
            default = defaultSettings.friendsColour,
            disabled = function() return not ClayladonsFriendStatus.savedVars.showFriends end,
        },
        {
            type = "divider",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Account Names",
            tooltip = "Uncheck this if you only want to see character names.",
            getFunc = function()
                return ClayladonsFriendStatus.savedVars.showAccountName
            end,
            setFunc = function(value)
                ClayladonsFriendStatus.savedVars.showAccountName = value
            end,
            width = "full",
            default = defaultSettings.showAccountName,
        },
        {
            type = "checkbox",
            name = "Show Character Names",
            tooltip = "Uncheck this if you only want to see @AccountNames.",
            getFunc = function()
                return ClayladonsFriendStatus.savedVars.showCharacterName
            end,
            setFunc = function(value)
                ClayladonsFriendStatus.savedVars.showCharacterName = value
            end,
            width = "full",
            default = defaultSettings.showCharacterName,
        },
        {
            type = "checkbox",
            name = "Show Zone",
            tooltip = "Uncheck this if you don't want to see the zones people are in.",
            getFunc = function()
                return ClayladonsFriendStatus.savedVars.showZone
            end,
            setFunc = function(value)
                ClayladonsFriendStatus.savedVars.showZone = value
            end,
            width = "full",
            default = defaultSettings.showZone,
        },
        {
            type = "divider",
            width = "full",
        },

        -- Watchlist supersection
        {
            type = "checkbox",
            name = "Show Guild Watchlists",
            tooltip = "Check this if you want to include specific people from your friends or guilds in your Friend Status. This might be for trial groups, PvP guildies, or anyone who isn't quite on your friends list yet!",
            getFunc = function()
                return ClayladonsFriendStatus.savedVars.showWatchlist
            end,
            setFunc = function(value)
                ClayladonsFriendStatus.savedVars.showWatchlist = value
            end,
            width = "full",
            default = defaultSettings.showWatchlist,
        },
        {
            type = "description",
            text = "Enter the @AccountNames of any specific friends/guildmates you want to include in the Friend Status output, separated by commas.",
            width = "full",
            disabled = function()
                return not ClayladonsFriendStatus.savedVars.showWatchlist
            end,
        },

        -- Watchlist #1
        {
            type = "checkbox",
            name = "Enable Guildmate Watchlist #1",
            tooltip = "Check to enable/disable this Watchlist.",
            getFunc = function()
                return ClayladonsFriendStatus.savedVars.watchlists[1].enabled
            end,
            setFunc = function(value)
                ClayladonsFriendStatus.savedVars.watchlists[1].enabled = value
            end,
            width = "half",
            default = defaultSettings.watchlists[1].enabled,
            disabled = function()
                return not ClayladonsFriendStatus.savedVars.showWatchlist
            end,
        },
        {
            type = "colorpicker",
            name = "Guildmate Watchlist #1 Colour",
            tooltip = "Text display colour for Guildmate Watchlist #1.",
            getFunc = function() 
                return ClayladonsFriendStatus.savedVars.watchlists[1].colour.r,
                        ClayladonsFriendStatus.savedVars.watchlists[1].colour.g,
                        ClayladonsFriendStatus.savedVars.watchlists[1].colour.b
            end,
            setFunc = function(r, g, b)
                ClayladonsFriendStatus.savedVars.watchlists[1].colour.r = r
                ClayladonsFriendStatus.savedVars.watchlists[1].colour.g = g
                ClayladonsFriendStatus.savedVars.watchlists[1].colour.b = b
            end,
            width = "half",
            default = defaultSettings.watchlists[1].colour,
            disabled = function() return not (ClayladonsFriendStatus.savedVars.watchlists[1].enabled and ClayladonsFriendStatus.savedVars.showWatchlist) end,
        },
        {
            type = "editbox",
            name = "Guildmate Watchlist #1: Name",
            tooltip = "Example: Tuesday Trial Group",
            getFunc = function()
                return ClayladonsFriendStatus.savedVars.watchlists[1].name
            end,
            setFunc = function(text)
                ClayladonsFriendStatus.savedVars.watchlists[1].name = text
            end,
            width = "half",
            default = defaultSettings.watchlists[1].name,
            disabled = function()
                return not (ClayladonsFriendStatus.savedVars.watchlists[1].enabled and ClayladonsFriendStatus.savedVars.showWatchlist)
            end,
        },
        {
            type = "editbox",
            name = "Guildmate Watchlist #1: Members",
            tooltip = "Example: @MolagBal, @MehrunesDagon, @Boethiah",
            getFunc = function()
                return ClayladonsFriendStatus.savedVars.watchlists[1].rawText
            end,
            setFunc = function(text)
                ClayladonsFriendStatus.savedVars.watchlists[1].rawText = text
            end,
            isMultiline = true,
            width = "half",
            default = defaultSettings.watchlists[1].rawText,
            disabled = function()
                return not (ClayladonsFriendStatus.savedVars.watchlists[1].enabled and ClayladonsFriendStatus.savedVars.showWatchlist)
            end,
        },
        
        -- Watchlist #2
        {
            type = "checkbox",
            name = "Enable Guildmate Watchlist #2",
            tooltip = "Check to enable/disable this Watchlist.",
            getFunc = function()
                return ClayladonsFriendStatus.savedVars.watchlists[2].enabled
            end,
            setFunc = function(value)
                ClayladonsFriendStatus.savedVars.watchlists[2].enabled = value
            end,
            width = "half",
            default = defaultSettings.watchlists[2].enabled,
            disabled = function()
                return not ClayladonsFriendStatus.savedVars.showWatchlist
            end,
        },
        {
            type = "colorpicker",
            name = "Guildmate Watchlist #2 Colour",
            tooltip = "Text display colour for Guildmate Watchlist #2.",
            getFunc = function() 
                return ClayladonsFriendStatus.savedVars.watchlists[2].colour.r,
                        ClayladonsFriendStatus.savedVars.watchlists[2].colour.g,
                        ClayladonsFriendStatus.savedVars.watchlists[2].colour.b
            end,
            setFunc = function(r, g, b)
                ClayladonsFriendStatus.savedVars.watchlists[2].colour.r = r
                ClayladonsFriendStatus.savedVars.watchlists[2].colour.g = g
                ClayladonsFriendStatus.savedVars.watchlists[2].colour.b = b
            end,
            width = "half",
            default = defaultSettings.watchlists[2].colour,
            disabled = function() return not (ClayladonsFriendStatus.savedVars.watchlists[2].enabled and ClayladonsFriendStatus.savedVars.showWatchlist) end,
        },
        {
            type = "editbox",
            name = "Guildmate Watchlist #2: Name",
            tooltip = "Example: Dungeon Prog Group",
            getFunc = function()
                return ClayladonsFriendStatus.savedVars.watchlists[2].name
            end,
            setFunc = function(text)
                ClayladonsFriendStatus.savedVars.watchlists[2].name = text
            end,
            width = "half",
            default = defaultSettings.watchlists[2].name,
            disabled = function()
                return not (ClayladonsFriendStatus.savedVars.watchlists[2].enabled and ClayladonsFriendStatus.savedVars.showWatchlist)
            end,
        },
        {
            type = "editbox",
            name = "Guildmate Watchlist #2: Members",
            tooltip = "Example: @Azura, @Sheogorath, @Nocturnal",
            getFunc = function()
                return ClayladonsFriendStatus.savedVars.watchlists[2].rawText
            end,
            setFunc = function(text)
                ClayladonsFriendStatus.savedVars.watchlists[2].rawText = text
            end,
            isMultiline = true,
            width = "half",
            default = defaultSettings.watchlists[2].rawText,
            disabled = function()
                return not (ClayladonsFriendStatus.savedVars.watchlists[2].enabled and ClayladonsFriendStatus.savedVars.showWatchlist)
            end,
        },
        
        -- Watchlist #3
        {
            type = "checkbox",
            name = "Enable Guildmate Watchlist #3",
            tooltip = "Check to enable/disable this Watchlist.",
            getFunc = function()
                return ClayladonsFriendStatus.savedVars.watchlists[3].enabled
            end,
            setFunc = function(value)
                ClayladonsFriendStatus.savedVars.watchlists[3].enabled = value
            end,
            width = "half",
            default = defaultSettings.watchlists[3].enabled,
            disabled = function()
                return not ClayladonsFriendStatus.savedVars.showWatchlist
            end,
        },
        {
            type = "colorpicker",
            name = "Guildmate Watchlist #3 Colour",
            tooltip = "Text display colour for Guildmate Watchlist #3.",
            getFunc = function() 
                return ClayladonsFriendStatus.savedVars.watchlists[3].colour.r,
                        ClayladonsFriendStatus.savedVars.watchlists[3].colour.g,
                        ClayladonsFriendStatus.savedVars.watchlists[3].colour.b
            end,
            setFunc = function(r, g, b)
                ClayladonsFriendStatus.savedVars.watchlists[3].colour.r = r
                ClayladonsFriendStatus.savedVars.watchlists[3].colour.g = g
                ClayladonsFriendStatus.savedVars.watchlists[3].colour.b = b
            end,
            width = "half",
            default = defaultSettings.watchlists[3].colour,
            disabled = function() return not (ClayladonsFriendStatus.savedVars.watchlists[3].enabled and ClayladonsFriendStatus.savedVars.showWatchlist) end,
        },
        {
            type = "editbox",
            name = "Guildmate Watchlist #3: Name",
            tooltip = "Example: Cyrodiil Crew",
            getFunc = function()
                return ClayladonsFriendStatus.savedVars.watchlists[3].name
            end,
            setFunc = function(text)
                ClayladonsFriendStatus.savedVars.watchlists[3].name = text
            end,
            width = "half",
            default = defaultSettings.watchlists[3].name,
            disabled = function()
                return not (ClayladonsFriendStatus.savedVars.watchlists[3].enabled and ClayladonsFriendStatus.savedVars.showWatchlist)
            end,
        },
        {
            type = "editbox",
            name = "Guildmate Watchlist #3: Members",
            tooltip = "Example: @Hircine, @Sanguine, @Vaermina",
            getFunc = function()
                return ClayladonsFriendStatus.savedVars.watchlists[3].rawText
            end,
            setFunc = function(text)
                ClayladonsFriendStatus.savedVars.watchlists[3].rawText = text
            end,
            isMultiline = true,
            width = "half",
            default = defaultSettings.watchlists[3].rawText,
            disabled = function()
                return not (ClayladonsFriendStatus.savedVars.watchlists[3].enabled and ClayladonsFriendStatus.savedVars.showWatchlist)
            end,
        },
        
        -- Watchlist #4
        {
            type = "checkbox",
            name = "Enable Guildmate Watchlist #4",
            tooltip = "Check to enable/disable this Watchlist.",
            getFunc = function()
                return ClayladonsFriendStatus.savedVars.watchlists[4].enabled
            end,
            setFunc = function(value)
                ClayladonsFriendStatus.savedVars.watchlists[4].enabled = value
            end,
            width = "half",
            default = defaultSettings.watchlists[4].enabled,
            disabled = function()
                return not ClayladonsFriendStatus.savedVars.showWatchlist
            end,
        },
        {
            type = "colorpicker",
            name = "Guildmate Watchlist #4 Colour",
            tooltip = "Text display colour for Guildmate Watchlist #4.",
            getFunc = function() 
                return ClayladonsFriendStatus.savedVars.watchlists[4].colour.r,
                        ClayladonsFriendStatus.savedVars.watchlists[4].colour.g,
                        ClayladonsFriendStatus.savedVars.watchlists[4].colour.b
            end,
            setFunc = function(r, g, b)
                ClayladonsFriendStatus.savedVars.watchlists[4].colour.r = r
                ClayladonsFriendStatus.savedVars.watchlists[4].colour.g = g
                ClayladonsFriendStatus.savedVars.watchlists[4].colour.b = b
            end,
            width = "half",
            default = defaultSettings.watchlists[4].colour,
            disabled = function() return not (ClayladonsFriendStatus.savedVars.watchlists[4].enabled and ClayladonsFriendStatus.savedVars.showWatchlist) end,
        },
        {
            type = "editbox",
            name = "Guildmate Watchlist #4: Name",
            tooltip = "Example: Guild Officers",
            getFunc = function()
                return ClayladonsFriendStatus.savedVars.watchlists[4].name
            end,
            setFunc = function(text)
                ClayladonsFriendStatus.savedVars.watchlists[4].name = text
            end,
            width = "half",
            default = defaultSettings.watchlists[4].name,
            disabled = function()
                return not (ClayladonsFriendStatus.savedVars.watchlists[4].enabled and ClayladonsFriendStatus.savedVars.showWatchlist)
            end,
        },
        {
            type = "editbox",
            name = "Guildmate Watchlist #4: Members",
            tooltip = "Example: @Peryite, @Namira, @Malacath",
            getFunc = function()
                return ClayladonsFriendStatus.savedVars.watchlists[4].rawText
            end,
            setFunc = function(text)
                ClayladonsFriendStatus.savedVars.watchlists[4].rawText = text
            end,
            isMultiline = true,
            width = "half",
            default = defaultSettings.watchlists[4].rawText,
            disabled = function()
                return not (ClayladonsFriendStatus.savedVars.watchlists[4].enabled and ClayladonsFriendStatus.savedVars.showWatchlist)
            end,
        },
    }

    -- Register the panel with LibAddonMenu-2.0
    ptr_LibAddonMenu2:RegisterAddonPanel("ClayladonsFriendStatusOptions", panelData)
    ptr_LibAddonMenu2:RegisterOptionControls("ClayladonsFriendStatusOptions", optionsTable)


end

-- Run the printout when you log in
local function OnPlayerActivated(eventCode, initial)
        EVENT_MANAGER:UnregisterForEvent(ClayladonsFriendStatus.name, EVENT_PLAYER_ACTIVATED)
        if ClayladonsFriendStatus.savedVars.onLogin then
            zo_callLater(function()
                PrintOnlineFriends()
            end, 3000)
        end
        
end

-- Futureproofing for when I implement anything with Saved Variables
local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= ClayladonsFriendStatus.name then return end
    EVENT_MANAGER:UnregisterForEvent(ClayladonsFriendStatus.name, EVENT_ADD_ON_LOADED)

    -- Set up saved variable storage
    ClayladonsFriendStatus.savedVars = ZO_SavedVars:NewAccountWide(
        "ClayladonsFriendStatusVariables",
        1,
        nil,
        defaultSettings
    )

    -- Create the settings menu
    InitializeSettingsMenu()


    EVENT_MANAGER:RegisterForEvent(ClayladonsFriendStatus.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

-- Slash command because it's cool. No more pressing "o". #cool
SLASH_COMMANDS["/friendstatus"] = function()
    PrintOnlineFriends()
end

-- Equivalent to calling main (starts the cascade of event listens)
EVENT_MANAGER:RegisterForEvent(ClayladonsFriendStatus.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
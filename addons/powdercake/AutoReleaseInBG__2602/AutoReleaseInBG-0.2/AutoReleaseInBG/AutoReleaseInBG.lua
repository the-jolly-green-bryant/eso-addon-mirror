AutoReleaseInBG = {}
AutoReleaseInBG.name = "AutoReleaseInBG"

function AutoReleaseInBG:Initialize()
    -- Get saved variables, if there are any. If not, create them.
    self.savedVariables = ZO_SavedVars:NewAccountWide("AutoReleaseInBGSavedVariables", 1, nil, AutoReleaseInBG.Default)

    -- If no saved state, initialize to true
    if (not(AutoReleaseInBG.savedVariables.enabled == true or AutoReleaseInBG.savedVariables.enabled == false)) then
        AutoReleaseInBG.savedVariables.enabled = true
    end

    -- Register slash commands
    SLASH_COMMANDS["/arbg"] = ARBGSlashCommand

    function OnPlayerDead()
        -- If addon is enabled
        if AutoReleaseInBG.savedVariables.enabled == true then
            -- and player is in battleground
            if IsActiveWorldBattleground() == true then
                -- Release spirit
                Release()
            end
        end
    end
    EVENT_MANAGER:RegisterForEvent(AutoReleaseInBG.name, EVENT_PLAYER_DEAD , OnPlayerDead)
end

--[[
Valid slash commands:
	/arbg             Display status
	/arbg on          Enable auto-release in battleground (default)
	/arbg off         Disable auto-release in battleground
	/arbg <anything>  Display help
]]--
function ARBGSlashCommand(--[[optional]]option)
    -- source: https://wiki.esoui.com/How_to_add_a_slash_command
    local options = {}
    local searchResult = { string.match(option,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end

    if (options[1] == nil or options[1] == '' or option == '') then
        AutoReleaseInBG:PrintStatus()
    elseif (options[1] == "off") then
        AutoReleaseInBG:SetAutoReleaseInBG(0)
    elseif (options[1] == "on") then
        AutoReleaseInBG:SetAutoReleaseInBG(1)
    else
        AutoReleaseInBG:PrintHelp()
    end
end

-- Set addon enabled/disabled
function AutoReleaseInBG:SetAutoReleaseInBG(state)
    if state == 0 then
        d("|cFF0000AutoReleaseInBG|r has been |c00FF00disabled|r.")
        AutoReleaseInBG.savedVariables.enabled = false
        EVENT_MANAGER:UnregisterForEvent(AutoReleaseInBG.name, EVENT_PLAYER_DEAD)
    elseif state == 1 then
        d("|cFF0000AutoReleaseInBG|r has been |c00FF00enabled|r.")
        AutoReleaseInBG.savedVariables.enabled = true
        EVENT_MANAGER:RegisterForEvent(AutoReleaseInBG.name, EVENT_PLAYER_DEAD , OnPlayerDead)
    end
end

-- Print addon status (enabled/disabled) to chat
function AutoReleaseInBG:PrintStatus()
    if AutoReleaseInBG.savedVariables.enabled then
        d("|cFF0000AutoReleaseInBG|r is |c00FF00enabled|r. For help, type |c00FF00/arbg help|r.")
    else
        d("|cFF0000AutoReleaseInBG|r is |c00FF00disabled|r. For help, type |c00FF00/arbg help|r.")
    end
end

-- Print help menu to chat
function AutoReleaseInBG:PrintHelp()
    d("|cFF0000AutoReleaseInBG|r Help:" ..
            "\n|c00FF00/arbg help|r Display help" ..
            "\n|c00FF00/arbg on|r Enable auto-release in battlegrounds." ..
            "\n|c00FF00/arbg off|r Disable auto-release in battlegrounds.")
end

-- Initialize the addon
function AutoReleaseInBG.OnAddOnLoaded(event, addonName)
    if addonName == AutoReleaseInBG.name then
        -- Initialize the addon
        AutoReleaseInBG:Initialize()

        -- Cleanup
        EVENT_MANAGER:UnregisterForEvent(AutoReleaseInBG.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(AutoReleaseInBG.name, EVENT_ADD_ON_LOADED, AutoReleaseInBG.OnAddOnLoaded)
SencheGuild = {
    name = "SencheGuild",
    version = "1"
}
local libAM = LibAddonMenu2
local savedVars
local validArg = false
local acceptInv = false
local autoInvEnabled = false
local autoInvWhitelist = {}
local defaultSavedVars = {
    Enabled = false,
    Whitelist = {}
}
local descText = {
    [1] = "|cc5c29eType|r |cff8200/senche|r |cc5c29efollowed by an option below to port to the following player homes:|r",
    [2] = "|cff8200parse|r |cc5c29e- port to|r |c76bcc3@Deathlikebean|r|cc5c29e's guild hall|r",
    [3] = "|cff8200craft|r |cc5c29e- port to|r |c76bcc3@lifelikebean|r|cc5c29e's crafting hall|r",
    [4] = "|cc5c29eKeybinds for these destinations may be set in the Controls menu.|r",
}

--Ensure arguments following the /senche command are valid.
function validateArg(arg)
    if arg == "parse" or arg == "craft" then
        validArg = true
    else
        validArg = false
    end
end

--Count the number of entries in a given table.
function tableCount(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

--Port to a player home based on the argument following the /senche command.
function SencheGuild.Port(dest)
    local dInfo = {
        ["parse"] = {playerId = "@Deathlikebean", houseId = 46, houseName = "Linchal Grand Manor"},
        ["craft"] = {playerId = "@lifelikebean", houseId = 54, houseName = "Pariah's Pinnacle"},
        }

    --Print a list of valid arguments if an invalid arguement is given.
    validateArg(dest)
    if validArg == false or dest == "" then
            d("SencheGuild: |cf10000invalid command|r\n"..descText[1].."\n"..descText[2].."\n"..descText[3].."\n"..descText[4])
        return
    end

    --Print a message displaying the destination when porting to a player home.
    d("Porting to |c76bcc3"..dInfo[dest].playerId.."|r's "..dInfo[dest].houseName..".")
    JumpToSpecificHouse(dInfo[dest].playerId, dInfo[dest].houseId)
end

--Convert editbox text in the settings to a table.
function tableTranslate(text)
    if text ~= nil then
        local outputTable = {}
            for line in (text..","):gmatch("([^, ]*),") do
                table.insert(outputTable, line)
            end
        savedVars.Whitelist = outputTable
    else
        local outputString = table.concat(savedVars.Whitelist, ", ")
        return outputString
    end
end

--Automatically accept group invites from player @names provided in the addon settings.
function SencheGuild.OnGroupInviteReceived(eventCode, invChar, invDisp)
    for i, _ in pairs(autoInvWhitelist) do
        if autoInvWhitelist[i] == invDisp then
            acceptInv = true
        end
    end

    if acceptInv == true then
        AcceptGroupInvite()
        d("|cff8200Accepted group invite from|r |c76bcc3"..invDisp.."|r.")
        acceptInv = false
    end
end

function InitSavedVars()
    savedVars = ZO_SavedVars:NewAccountWide("SencheGuild_vars", 1, nil, defaultSavedVars, GetWorldName())
    autoInvEnabled = savedVars.Enabled
    autoInvWhitelist = savedVars.Whitelist
end

function SencheGuild.OnAddOnLoaded(event, addonName)
	if addonName == SencheGuild.name then
        SLASH_COMMANDS["/senche"] = SencheGuild.Port,
        InitSavedVars(),
        reg_libAM(),
        ZO_CreateStringId("SI_BINDING_NAME_PORT_TO_PARSE_HALL", "Port to Guild Hall"),
        ZO_CreateStringId("SI_BINDING_NAME_PORT_TO_CRAFT_HALL", "Port to Craft Hall"),
		EVENT_MANAGER:UnregisterForEvent(SencheGuild.name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(SencheGuild.name, EVENT_GROUP_INVITE_RECEIVED, SencheGuild.OnGroupInviteReceived)
EVENT_MANAGER:RegisterForEvent(SencheGuild.name, EVENT_ADD_ON_LOADED, SencheGuild.OnAddOnLoaded)

--Initialize settings panel with libAddonMenu2
function reg_libAM()
    local panel = {
        type = "panel",
        name = ""..SencheGuild.name,
        displayName = "|cff8200Senche|r|cf7d226Guild|r",
        version = ""..SencheGuild.version,
        author = "|c4713d2S|r|c4826a5o|r|c4a3878m|r|c4b4b4ba|r",
        slashCommand = "/senche",
    }
    local options = {
        {
            type = "description",
            text = descText[1].."\n"..string.format("%90s", descText[2]).."\n"..string.format("%92s", descText[3]).."\n"..descText[4],
        },

        {
            type = "divider",
        },

        {
            type = "checkbox",
            name = "Enable Auto-Accept Group Invites",
            tooltip = "When enabled group invites from players listed below will be automatically accepted",
            getFunc = function()
                return savedVars.Enabled
            end,
            setFunc = function(bool)
                savedVars.Enabled = bool
            end,
        },

        {
            type = "editbox",
            name = "Auto-Accept Invites From:",
            tooltip = "Type a list of @names seperated by commas, group invites from these players will be automatically accepted.",
            isMultiline = true,
            isExtraWide = true,
            getFunc = function()
                return tableTranslate()
            end,
            setFunc = function(text)
                tableTranslate(text)
            end,
        },
    }
    libAM:RegisterAddonPanel(SencheGuild.name.."_Options", panel)
    libAM:RegisterOptionControls(SencheGuild.name.."_Options", options)
end
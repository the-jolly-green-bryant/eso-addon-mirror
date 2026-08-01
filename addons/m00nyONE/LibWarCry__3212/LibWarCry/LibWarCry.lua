LibWarCry = LibWarCry or {}
LibWarCry.name = "LibWarCry"
LibWarCry.color = "8B0000"
LibWarCry.credits = "|c76c3f4@m00nyONE|r"
LibWarCry.version = "2.1.1"
LibWarCry.slashCmdShort = "/wc"
LibWarCry.slashCmdLong = "/warcry"
LibWarCry.variableVersion = 1
LibWarCry.List = {}
LibWarCry.defaultVariables = {
    debug = false,
    groupCommands = true,
}

local function print(str)
    d("|c8B0000LibWarCry:|r " .. str )
end

-- function that creates a warcry and adds it to the internal list
function LibWarCry:CreateWarCry(name, ids)
    -- error catching to prevent addon developers from doing something bad
    if name == nil then print(GetString(LIBWARCRY_ERROR_NAME_MUST_NOT_BE_NIL)) return end
    if type(ids) ~= "table" then print(GetString(LIBWARCRY_ERROR_IDS_MUST_BE_TABLE)) return end

    -- create a new table inside of the warcry list and fill it with nessecary information
    LibWarCry.List[name] = {}
    -- iterate over the inserted values
    for _, value in ipairs(ids) do
        -- check if they are numbers
        if type(value) =="number" then
            -- add them to the table
            LibWarCry.List[name].collectibleIDs = LibWarCry.List[name].collectibleIDs or {}
            table.insert(LibWarCry.List[name].collectibleIDs, value)
        end
        -- check if they are strings
        if type(value) == "string" then
            -- TODO: implement blacklist system
            if value == "/logout" or value == "/quit" then
                d("NO WAY")
            end
            -- add them to the table
            LibWarCry.List[name].emoteCommands = LibWarCry.List[name].emoteCommands or {}
            table.insert(LibWarCry.List[name].emoteCommands, value)
        end
    end

    -- tell the user that the warcry has been created - this will usually not be seen because of the Chat UI loading slower than the addons
    print(zo_strformat(GetString(LIBWARCRY_CREATED), name))
end

-- function that plays the collectible/s
function LibWarCry:PlayWarCry(name)
    -- error handling to not crash when a user inserts numbers or tables into chat
    if name == nil then return end
    if type(name) ~= "string" then return end

    -- create a new table called playable - it will store the ID's of the warcry the player has access to
    local playable = {}
    -- check if the warcry exists
    if LibWarCry.List[name] ~= nil then

        -- check the collectibleIDs first
        if LibWarCry.List[name].collectibleIDs then
            -- iterate over the collectible ids of the warcry
            for _, value in ipairs(LibWarCry.List[name].collectibleIDs) do
                -- check if the collectible is unlocked
                if GetCollectibleUnlockStateById(value) == 2 then
                    -- if so, insert it into the playable table/array
                    table.insert(playable, value)
                else
                    -- otherwise display a message which collectible is missing and where to get it from
                    print(zo_strformat(GetString(LIBWARCRY_ERROR_MISSING_COLLECTIBLE), value))
                end
            end
        end

        -- then check emoteCommands
        if LibWarCry.List[name].emoteCommands then
            -- iterate over the emoteCommands of the warcry
            for _, value in ipairs(LibWarCry.List[name].emoteCommands) do
                -- check if the emoteCommands is unlocked
                if SLASH_COMMANDS[value] ~= nil then
                    -- if so, insert it into the playable table/array
                    table.insert(playable, value)
                else
                    -- otherwise display a message which collectible is missing and where to get it from
                    -- TODO: Check the collectible ID of the emote to display it
                    --print(zo_strformat(GetString(LIBWARCRY_ERROR_MISSING_COLLECTIBLE), value))
                end
            end
        end

        -- return when there is nothing that can be played
        if #playable == 0 then  return end

        -- play random collectible/emote from playable array
        local warCry = playable[math.random(#playable)]
        if type(warCry) == "string" then
            DoCommand(warCry)
            return
        end
        if type(warCry) == "number" then
            UseCollectible(warCry)
            return
        end

    end

end

-- callback function that gets excecuted when a message is sent to the group channel
local chatCallback = function(_, messageType, _, message, _, fromDisplayName)
    -- check if message is in group chat
    if messageType == CHAT_CHANNEL_PARTY then
        -- check if message is the one we are listening for
        if LibWarCry.List[string.lower(message)] ~= nil then
            -- check if the message is from the group leader
            if fromDisplayName == GetUnitDisplayName(GetGroupLeaderUnitTag()) then
                -- play the warcry from the list
                LibWarCry:PlayWarCry(string.lower(message))
            end
        end
    end
end

-- start listener by subscribing to EVENT_CHAT_MESSAGE_CHANNEL
local function startChatListener()
    EVENT_MANAGER:RegisterForEvent(LibWarCry.name, EVENT_CHAT_MESSAGE_CHANNEL, chatCallback)
    print(GetString(LIBWARCRY_ENABLED))
end
-- stop listener by unsubscribing from EVENT_CHAT_MESSAGE_CHANNEL
local function stopChatListener()
    EVENT_MANAGER:UnregisterForEvent(LibWarCry.name, EVENT_CHAT_MESSAGE_CHANNEL)
    print(GetString(LIBWARCRY_DISABLED))
end

-- toggles the group listener on and off
function LibWarCry.toggleListener(value)
    if value then
        startChatListener()
    else
        stopChatListener()
    end

    -- write value to saved vars
    LibWarCry.savedVariables.groupCommands = value
end

-- donate to me if you want to
function LibWarCry.donate()
    -- show message window
	SCENE_MANAGER:Show('mailSend')
    -- wait 200 ms async
	zo_callLater(
		function()
            -- fill out messagebox
			ZO_MailSendToField:SetText("@m00nyONE")
			ZO_MailSendSubjectField:SetText("Donation for LibWarCry")
			QueueMoneyAttachment(1)
			ZO_MailSendBodyField:TakeFocus()
		end,
	200)
end

-- function to print all registered warcrys to chat
local function printWarCryList()
    -- create an array for the warcry list to be sorted in
    local sortedWarCryList = {}

    -- loop over the list of warcrys and put them into the newly created sortedWarCryList array
    for wc, _ in pairs(LibWarCry.List) do
        table.insert(sortedWarCryList, wc)
    end

    -- sort sortedWarCryList alphabetically
    table.sort(sortedWarCryList)

    -- arrange the warcrys together into one string
    local listStr = ""

    for i, wc in ipairs(sortedWarCryList) do
        if i ~= #sortedWarCryList then
            listStr = listStr .. wc .. ", "
        else
            listStr = listStr .. wc
        end
    end
    -- print sortedWarCryList  to chat
    print(GetString(LIBWARCRY_LIST_AVAILABLE))
    print(listStr)
end

-- function to play warcry when entering /wc $NAME
local function slashCommand(str)
    if LibWarCry.List[string.lower(str)] ~= nil then
        LibWarCry:PlayWarCry(string.lower(str))
        return
    end

    if str ~= "" then
        print(str .. " " .. GetString(LIBWARCRY_ERROR_NAME_NOT_FOUND))
    end

    -- if warcry is not found or no name given, print all available warcrys
    printWarCryList()
end

function LibWarCry.OnAddOnLoaded(event, addonName)
    if addonName == LibWarCry.name then
        EVENT_MANAGER:UnregisterForEvent(LibWarCry.name, EVENT_ADD_ON_LOADED)

        -- load saved variables ( global )
        LibWarCry.savedVariables = LibWarCry.savedVariables or {}
        LibWarCry.savedVariables = ZO_SavedVars:NewAccountWide("LibWarCryVars", LibWarCry.variableVersion, nil, LibWarCry.defaultVariables, GetWorldName())

        -- create the LibAddonMenu entry
        LibWarCry.createMenu()

        -- check if the group listener is enabled. if so, start it
        if LibWarCry.savedVariables.groupCommands == true then
            startChatListener()
        end
    end
end

EVENT_MANAGER:RegisterForEvent(LibWarCry.name, EVENT_ADD_ON_LOADED, LibWarCry.OnAddOnLoaded)

--- create SLASH_COMMAND that can play every warcry available in the list
SLASH_COMMANDS[LibWarCry.slashCmdShort] = slashCommand
SLASH_COMMANDS[LibWarCry.slashCmdLong] = slashCommand

SLASH_COMMANDS["/wcdebug"] = function(str)
    LibWarCry.savedVariables.debug = not LibWarCry.savedVariables.debug
end
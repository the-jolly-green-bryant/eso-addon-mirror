ChaoticTools = {
	userValues = nil,
	name = "ChaoticTools",
	addonName = "Chaotic Tools",
	displayName = "Chaotic Tools",
	addonVersion = "2.17",
	addonAuthor = "@Kanori",
	
	defaults = {
    	AnnounceMotdUpdate = true,
    	GuildHallOwner = "@Kanori",
    	GuildHallHouseID = 41,
    	GuildHallX = 20,
    	GuildHallY = 20,
    	GuildHallButtonHidden = false,
    	GuildHallButtonLocked = false,
    	GuildChoice = 0,
    	GuildDiscord = "{full URL to your discord}",
    	GuildMemberRecentName = 'none',
    	GuildMemberRecentTime = 0,
    	GuildMemberOnline = {
								['1'] = true,
								['2'] = true,
								['3'] = true,
								['4'] = true,
								['5'] = true
							}
	}
}

-------------------------------------------------------------------------------------------------
-- settings menu
-------------------------------------------------------------------------------------------------
function ChaoticTools.settingsMenu()
	local LAM2 = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = ChaoticTools.addonName,
		displayName = ChaoticTools.displayName,
		author = ChaoticTools.addonAuthor,
		version = ChaoticTools.addonVersion,
		slashCommand = "/ct",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	LAM2:RegisterAddonPanel(ChaoticTools.name .. "ChaoticToolsOptions", panelData)
	
	local optionsTable = {
        {
			type = "header",
			name = "Guild MotD Settings",
			width = "full",
		},
		{
			type = "description",
			text = "Use Slash Command: /motd",
		},
        {
            type = "checkbox",
            name = "Show When MotD Updated",
            default = ChaoticTools.defaults.AnnounceMotdUpdate,
            getFunc = function() return ChaoticTools.userValues.AnnounceMotdUpdate end,
            setFunc = function(value) ChaoticTools.userValues.AnnounceMotdUpdate = value end
        },
        {
            type = "dropdown",
            name = "Guild To Show",
            choices = {"All Guilds", 
            			GetGuildName(GetGuildId(1)), 
            			GetGuildName(GetGuildId(2)), 
            			GetGuildName(GetGuildId(3)), 
            			GetGuildName(GetGuildId(4)), 
            			GetGuildName(GetGuildId(5))},
            choicesValues = {0,1,2,3,4,5},
            default = ChaoticTools.defaults.GuildChoice,
            getFunc = function() return ChaoticTools.userValues.GuildChoice end,
            setFunc = function(value) ChaoticTools.userValues.GuildChoice = value end
        },
        {
			type = "header",
			name = "Discord Link",
			width = "full",
		},
		{
			type = "description",
			text = "Use Slash Command: /discord",
		},
		{
			type = "editbox",
			name = "Discord Link",
			tooltip = "The discord link you would normally paste into chat.",
			width = "full",
			default = ChaoticTools.defaults.GuildDiscord,
			getFunc = function() return ChaoticTools.userValues.GuildDiscord end,
			setFunc = function(choice) ChaoticTools.userValues.GuildDiscord = choice end
		},
		{
			type = "header",
			name = "Guild Hall",
			width = "full",
		},
		{
			type = "description",
			text = "Setup information for the chat window Guild Hall icon.",
		},
		{
            type = "checkbox",
            name = "Show/Hide the Guild Hall icon.",
            default = ChaoticTools.defaults.GuildHallButtonHidden,
            getFunc = function() return ChaoticTools.userValues.GuildHallButtonHidden end,
            setFunc = function(value) ChaoticTools.userValues.GuildHallButtonHidden = value ChaoticTools.guildHallIconHidden(value) end
        },
        {
            type = "checkbox",
            name = "Lock the Guild Hall icon.",
            default = ChaoticTools.defaults.GuildHallButtonLocked,
            getFunc = function() return ChaoticTools.userValues.GuildHallButtonLocked end,
            setFunc = function(value) ChaoticTools.userValues.GuildHallButtonLocked = value ChaoticTools.guildHallIconLocked(value) end
        },
		{
			type = "editbox",
			name = "Guild Hall Owner",
			tooltip = "The @ name of who runs your Guild Hall.",
			width = "full",
			default = ChaoticTools.defaults.GuildHallOwner,
			getFunc = function() return ChaoticTools.userValues.GuildHallOwner end,
			setFunc = function(choice) ChaoticTools.userValues.GuildHallOwner = choice end
		},
		{
			type = "editbox",
			name = "Guild Hall House ID",
			tooltip = "The ZoS house ID of your Guild Hall.",
			width = "full",
			default = ChaoticTools.defaults.GuildHallHouseID,
			getFunc = function() return ChaoticTools.userValues.GuildHallHouseID end,
			setFunc = function(choice) ChaoticTools.userValues.GuildHallHouseID = choice end
		},
		{
			type = "header",
			name = "Guild Member Login/Logout Notification",
			width = "full",
		},
		{
			type = "description",
			text = "Be notified when guild members login/logout",
		},
	}
	
	local gNum = GetNumGuilds()
	for i = 1, gNum, 1 do
		table.insert(optionsTable, {
            							type = "checkbox",
            							name = GetGuildName(GetGuildId(i)),
            							default = ChaoticTools.defaults.GuildMemberOnline[i],
            							getFunc = function() return ChaoticTools.userValues.GuildMemberOnline[i] end,
            							setFunc = function(value) ChaoticTools.userValues.GuildMemberOnline[i] = value end
        							}
        			)
	end
    
    table.insert(optionsTable, {
			type = "header",
			name = "Utility Slash Commands",
			width = "full",
		}
	)
	table.insert(optionsTable, 
		{
			type = "description",
			text = "Multiply:\n/mult {num} {num}\n\nAdd:\n/add {num} {num} ...\n\nSubract:\n/sub {num} {num} ...\n\nDivide:\n/div {num} {num}\n\nRandom:\n/rand {num} {num}"
		}
	)
	
	LAM2:RegisterOptionControls(ChaoticTools.name .. "ChaoticToolsOptions", optionsTable)
end

-------------------------------------------------------------------------------------------------
-- notify in chat when login status changes
-------------------------------------------------------------------------------------------------
--@param eventCode int
--@param guildId int (ZoS ID)
--@param playerName string
--@param previousStatus string
--@param currentStatus string
function ChaoticTools.onGuildMemberPlayerStatusChanged(eventCode, guildId, playerName, previousStatus, currentStatus)

	-- just return on repeats (same player - multiple guilds)
	if ChaoticTools.userValues.GuildMemberRecentName == playerName then
		local rightNow = os.time(os.date("*t"))
		if ChaoticTools.userValues.GuildMemberRecentTime >= rightNow - 2 then
			return
		end
	end
	
    local gNum = GetNumGuilds()
    local gid = 1
    
    -- get our local guild number from ZoS guild id
    for i = 1, gNum, 1 do
    	if guildId == GetGuildId(i) then 
    		gid = i
    		break 
    	end
    end
    
    -- send to chat window if enabled for this guild
    if ChaoticTools.userValues.GuildMemberOnline[gid] == true then
		if (currentStatus == PLAYER_STATUS_ONLINE and playerName ~= GetDisplayName()) then
			d(string.format("|cE86A66%s|r from |c3BD68D%s|r has logged on", ZO_LinkHandler_CreateDisplayNameLink(playerName), GetGuildName(guildId)))
		end
	
		if (currentStatus == PLAYER_STATUS_OFFLINE) then
			d(string.format("|cE86A66%s|r from |c3BD68D%s|r has logged off", playerName, GetGuildName(guildId)))
		end
		
		-- set most recent user to keep track of repeats (same player - multiple guilds)
		ChaoticTools.userValues.GuildMemberRecentName = playerName
    	ChaoticTools.userValues.GuildMemberRecentTime = os.time(os.date("*t"))
	end
    
end

-------------------------------------------------------------------------------------------------
-- add guild hall button root interface
-------------------------------------------------------------------------------------------------
function ChaoticTools.guildHallButton()
		
	GHButton:ClearAnchors()
    GHButton:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ChaoticTools.userValues.GuildHallX, ChaoticTools.userValues.GuildHallY)
    GHButton:SetMovable(true)
	
	GHButtonHouse:SetHidden(ChaoticTools.userValues.GuildHallButtonHidden)
	ChaoticTools.guildHallIconHidden(ChaoticTools.userValues.GuildHallButtonHidden)
	GHButtonHouse:SetTexture("/esoui/art/icons/poi/poi_group_house_owned.dds")
    GHButtonHouse:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control, TOPRIGHT, 0, 5, BOTTOMRIGHT) SetTooltipText(InformationTooltip, "Jump To Guild Hall") end)
	GHButtonHouse:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
	ChaoticTools.guildHallIconLocked(ChaoticTools.userValues.GuildHallButtonLocked)
end

-------------------------------------------------------------------------------------------------
-- show/hide guild hall icon
-------------------------------------------------------------------------------------------------
--@param value boolean
function ChaoticTools.guildHallIconHidden(value)
	GHButtonHouse:SetHidden(not value)
end

-------------------------------------------------------------------------------------------------
-- lock guild hall icon
-------------------------------------------------------------------------------------------------
--@param value boolean
function ChaoticTools.guildHallIconLocked(value)
	GHButtonHouse:SetMovable(not value)
end

-------------------------------------------------------------------------------------------------
-- hide icon for menus or in combat
-------------------------------------------------------------------------------------------------
function ChaoticTools.guildHallIconUpdate()

	-- this pile of if's seems to catch all the menus without errors, even on controller
	if not ZO_KeybindStripControl:IsHidden() or (SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene() and (SCENE_MANAGER:GetCurrentScene():GetName() ~= "hud" and SCENE_MANAGER:GetCurrentScene():GetName() ~= "hudui")) then
		ChaoticTools.guildHallIconHidden(false)
	elseif IsUnitInCombat("player") then
		ChaoticTools.guildHallIconHidden(false)
	else
		-- check against nil index at ui load
		if ChaoticTools and ChaoticTools.userValues and ChaoticTools.userValues.GuildHallButtonHidden then
    		ChaoticTools.guildHallIconHidden(ChaoticTools.userValues.GuildHallButtonHidden)
		end
	end
	
end

-------------------------------------------------------------------------------------------------
-- guild hall button clicked
-------------------------------------------------------------------------------------------------
function ChaoticTools.guildHallButtonClick()
	if GetDisplayName() == ChaoticTools.userValues.GuildHallOwner then
		RequestJumpToHouse(ChaoticTools.userValues.GuildHallHouseID)
	else
		JumpToHouse(ChaoticTools.userValues.GuildHallOwner, ChaoticTools.userValues.GuildHallHouseID)
	end
end

-------------------------------------------------------------------------------------------------
-- save guild hall button location after drag
-------------------------------------------------------------------------------------------------
function ChaoticTools.guildHallButtonDragStop()
	ChaoticTools.userValues.GuildHallX = GHButtonHouse:GetLeft()
	ChaoticTools.userValues.GuildHallY = GHButtonHouse:GetTop()
	GHButton:ClearAnchors()
	GHButton:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ChaoticTools.userValues.GuildHallX, ChaoticTools.userValues.GuildHallY)
end

-------------------------------------------------------------------------------------------------
-- push MOTD to chat
-------------------------------------------------------------------------------------------------
--@param gid number (0 - 5)
function ChaoticTools.printConsoleMotd(gid)
    d("MotD for " .. GetGuildName(GetGuildId(gid)) .. ": " .. GetGuildMotD(GetGuildId(gid)))
end

-------------------------------------------------------------------------------------------------
-- slash command function to display MOTD in chat per settings
-------------------------------------------------------------------------------------------------
--@param command string (not used)
function ChaoticTools.showMotd(command)
	local gNum = GetNumGuilds()
	
    --display all MotDs
    if gNum > 0 and ChaoticTools.userValues.GuildChoice == 0 then
        for i = 1, gNum, 1 do
            ChaoticTools.printConsoleMotd(i)
        end

    --print selected guild
    elseif ChaoticTools.userValues.GuildChoice <= gNum and ChaoticTools.userValues.GuildChoice ~= 0 then
        ChaoticTools.printConsoleMotd(ChaoticTools.userValues.GuildChoice)

    --not in a guild
    elseif gNum == 0 then
        --do nothing if not in a guild
    else
        d("Chaotic Tools cannot find a guild to show, please update your 'Guild To Show' settings in settings>Addons>Chaotic Tools")
    end
end

-------------------------------------------------------------------------------------------------
-- slash command function to display discord in group chat
-------------------------------------------------------------------------------------------------
--@param command string
function ChaoticTools.showDiscordToGroup(command)
	CHAT_SYSTEM:StartTextEntry(ChaoticTools.userValues.GuildDiscord, CHAT_CHANNEL_PARTY)
end

-------------------------------------------------------------------------------------------------
-- do multiply
-------------------------------------------------------------------------------------------------
--@param command string
function ChaoticTools.doMultiply(command)
	local parts = ChaoticTools.splitArgs(command)
	if(#(parts) >= 2) then
		d(ChaoticTools.commaValue(parts[1] * parts[2]))
	end
end

-------------------------------------------------------------------------------------------------
-- do division
-------------------------------------------------------------------------------------------------
--@param command string
function ChaoticTools.doDivision(command)
	local parts = ChaoticTools.splitArgs(command)
	if(#(parts) >= 2) then
		d(math.floor(parts[1] / parts[2]) .. " Remainder " .. parts[1] % parts[2])
	end
end

-------------------------------------------------------------------------------------------------
-- do addition
-------------------------------------------------------------------------------------------------
--@param command string
function ChaoticTools.doAddition(command)
	local parts = ChaoticTools.splitArgs(command)
	if(#(parts) >= 2) then
		local total = 0
		for _, val in ipairs(parts) do
    		total = total + val
		end
		d(total)
	end
end
-------------------------------------------------------------------------------------------------
-- do substraction
-------------------------------------------------------------------------------------------------
--@param command string
function ChaoticTools.doSubtraction(command)
	local parts = ChaoticTools.splitArgs(command)
	if(#(parts) >= 2) then 
		d(parts[1] - parts[2])
	end
end

-------------------------------------------------------------------------------------------------
-- do random number
-------------------------------------------------------------------------------------------------
--@param command string
function ChaoticTools.doRandom(command)
	local parts = ChaoticTools.splitArgs(command)
	if(#(parts) >= 2) then
		local rNum = math.random(parts[1], parts[2])
		local msg = "Random number between "..parts[1] .. " and " .. parts[2] .. ". The number is " .. rNum
		CHAT_SYSTEM:StartTextEntry(msg, CHAT_CHANNEL_SAY)
	end
end

-------------------------------------------------------------------------------------------------
-- split string on spaces
-------------------------------------------------------------------------------------------------
--@param str string
function ChaoticTools.splitArgs(str)
	parts = {}
	for part in str:gmatch("%S+") do 
		table.insert(parts, part) 
	end
	return parts
end

-------------------------------------------------------------------------------------------------
-- format number with commas
-------------------------------------------------------------------------------------------------
--@param amount string
function ChaoticTools.commaValue(amount)
  local formatted = amount
  while true do  
  	formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k == 0) then
    	break
  	end
  end
  return formatted
end

-------------------------------------------------------------------------------------------------
-- initialize addon
-- set slash commands
-- set db defaults
-------------------------------------------------------------------------------------------------
function ChaoticTools.initialize()
	
	SLASH_COMMANDS["/motd"] = function(command)
		ChaoticTools.showMotd(command)
	end
    SLASH_COMMANDS["/discord"] = function(command)
    	ChaoticTools.showDiscordToGroup(command)
    end
    SLASH_COMMANDS["/mult"] = function(command) 
    	ChaoticTools.doMultiply(command)
    end
    SLASH_COMMANDS["/div"] = function(command)
    	ChaoticTools.doDivision(command)
    end
    SLASH_COMMANDS["/add"] = function(command)
    	ChaoticTools.doAddition(command)
    end
    SLASH_COMMANDS["/sub"] = function(command)
    	ChaoticTools.doSubtraction(command)
    end
    SLASH_COMMANDS["/rand"] = function(command)
    	ChaoticTools.doRandom(command)
    end
    
    EVENT_MANAGER:RegisterForEvent(ChaoticTools.name, EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, ChaoticTools.onGuildMemberPlayerStatusChanged)
    
    ChaoticTools.userValues = ZO_SavedVars:NewAccountWide("ChaoticVariables", 1, nil, ChaoticTools.defaults)
	ChaoticTools.settingsMenu()
	ChaoticTools.guildHallButton()
    
end

-------------------------------------------------------------------------------------------------
-- addon loaded
-------------------------------------------------------------------------------------------------
function ChaoticTools.onAddOnLoaded(event, addon)
	if addon == ChaoticTools.name then
		ChaoticTools.initialize()
		ZO_CreateStringId("SI_BINDING_NAME_CHAOTIC_GO_GUILD_HALL", "Jump To Guild Hall")
		EVENT_MANAGER:UnregisterForEvent(ChaoticTools.name, EVENT_ADD_ON_LOADED)
	end
end

-------------------------------------------------------------------------------------------------
-- register addon hooks
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(ChaoticTools.name, EVENT_ADD_ON_LOADED, ChaoticTools.onAddOnLoaded)



























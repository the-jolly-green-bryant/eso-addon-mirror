-- ***** Pawprint's PVP Tools - AutoInvite *****
--------------------------------------------------
-- Initialize our namespace
--------------------------------------------------
if not PVPTools then PVPTools = {} end
if not PVPTools.AutoInvite then PVPTools.AutoInvite = {} end
local PT = PVPTools
local AI = PVPTools.AutoInvite

-- Bug Workaround
-- GetUnitRawWorldPosition(string unitTag)
-- Returns: integer zoneId, integer worldX, integer worldY, integer worldZ

--[[
	format
		[1] = {
				displayName = @name because unitTag can change as people leave and join group
				zone = zoneId
				X = worldX
				Y = worldY
				Z = worldZ
				fails = 0 is active 3 is three failed movment checks
--]]

PT.AIBugFixGroupPlayerList = {}




function AI.GroupBugFix()
	-- /script PVPTools.AutoInvite.GroupBugFix()
	if PT.debug then PT.DebugEntry("PVPTools.AutoInvite.GroupBugFix") end
	
	
	d("AI.GroupBugFix")
	
	
	
	local kickTable = {}
	local locationTable = {}
	-- format will be [1] = zone, [2] = X, [3] = Y, [4] = Z
	
	AI.PurgeAIBugFixGroupPlayerList()
	for index = 1, GetGroupSize() do
		
		local checkTag = GetGroupUnitTagByIndex(index)
		local displayName = GetUnitDisplayName(checkTag)
			
		locationTable = { GetUnitRawWorldPosition(checkTag) }
		
		local found, key, data = AI.IsPlayerInBugFixList(displayName)
		
		
		
		d("IsPlayerInBugFixList Results")
		d(PT.ConvertBool(found)) d(key) d(data)
		
		
		
		if found then
			if AI.HasPlayerMoved(locationTable, data) then
				data["zone"] = locationTable[1]
				data["worldX"] = locationTable[2]
				data["worldY"] = locationTable[3]
				data["worldZ"] = locationTable[4]
				data["fails"] = 0
			else
				if data["fails"] > 3 then
					table.insert(kickTable, {checkTag, key})
				else
					data["fails"] = data["fails"]  + 1
				end
				
				d("Fails Updated")
				d(data["fails"])
				
			end
		else
			AI.AddPlayerToBugFixList(locationTable, displayName)
		end
		
		
	end
	
	d("Kick Table")
	d(kickTable)
	
	
	
	-- if we kick them from group while looping through the group list it will mess up the index, so we kick then from group and remove them from the bug fix table after all the checks.
	for key, entry in ipairs(kickTable) do
		GroupKick(entry[1])
		table.remove(PT.AIBugFixGroupPlayerList, entry[2])
	end
	
	if GetGroupSize() > 0 then
		zo_callLater(function() AI.GroupBugFix() end, 50 * 1000)
	end
	
end

function AI.PurgeAIBugFixGroupPlayerList()
	
	
	d("PurgeAIBugFixGroupPlayerList")
	
	
	local groupTable = {}
	local removeTable = {}
	
	for index = 1, GetGroupSize() do
		local tag = GetGroupUnitTagByIndex(index)
		local name = GetUnitDisplayName(tag)
		table.insert(groupTable, name)
	end
	
	for key, data in ipairs(PT.AIBugFixGroupPlayerList) do
		local found = false
		
		for index, name in ipairs(groupTable) do
			if name == data["displayName"] then found = true end
			if not found then table.insert(removeTable, key) end
		end
	end
	
	for key, entry in ipairs(removeTable) do
		table.remove(PT.AIBugFixGroupPlayerList, entry)
	end
	
	
	
	d("Bug Fix Player List")
	d(PT.AIBugFixGroupPlayerList)
	
	
	
end


function AI.IsPlayerInBugFixList(displayName)
	
	d("IsPlayerInBugFixList")
	
	
	for key, data in ipairs(PT.AIBugFixGroupPlayerList) do
		
		
		
		d("Display Name:" .. displayName)
		d("data Name: "..data["displayName"])
		
		
		
		if displayName == data["displayName"] then
			return true, key, data
		end
	end
end

function AI.HasPlayerMoved(locationTable, data)
	
	-- d("HasPlayerMoved")
	-- d("locationTable")
	-- d(locationTable)
	-- d("Bug Fix List Data")
	-- d(data)
	
	if 	locationTable[2] == data["zone"] and
		locationTable[3] == data["worldX"] and
		locationTable[4] == data["worldY"] and
		locationTable[5] == data["worldZ"] then
		
		return false
	else
		return true
	end	
end



function AI.AddPlayerToBugFixList(locationTable, displayName)
		
	d("AddPlayerToBugFixList")
	-- d(locationTable)
	-- d(displayName)
	
	local tempTable = {
		["displayName"] = displayName,
		["zone"] 		= locationTable[1],
		["worldX"]		= locationTable[2],
		["worldY"]		= locationTable[3],
		["worldZ"]		= locationTable[4],
		["fails"]		= 0,
	}
	
	
	-- d(tempTable)
	
	
	
	table.insert(PT.AIBugFixGroupPlayerList, tempTable)
end

--------------------------------------------------
-- Initialize - centeral function to initialize elements of the AutoInvite
--------------------------------------------------
function AI.Initialize()
	if PT.debug then PT.DebugEntry ("PVPTools.AutoInvite.Initialize") end
	
	-- even though we save the enabled field with the saved variables, we want to make sure they are all turned off when we initially start so that the user can choose which strings they want to enable.
	for key, value in ipairs(PT.ASV.settingsAIWatchStrings) do
		if value["enabled"] == true then value["enabled"] = false end
	end
	
	if PT.controlGroupMenuKeyboardPVPToolsIcon == 0 then
		AI.CreateGroupMenuFragment()
		AI.CreateGroupMenuEntry()
	end
end


--------------------------------------------------
-- ToggleAutoInviteModule - toggles if the AutoInvite module
--------------------------------------------------
function AI.ToggleAutoInviteModule()
	if PT.debug then PT.DebugEntry("PVPTools.AutoInvite.ToggleAutoInviteModule") end
	
	if PT.ASV.settingsAIModuleOn then
		for key, value in ipairs(PT.ASV.settingsAIWatchStrings) do
			if value["enabled"] == true then value["enabled"] = false end
		end
		PT.ASV.settingsAIModuleOn = false
		PT.dataGroupMenuKeyboardPVPToolsData.visible = false
	else
		PT.ASV.settingsAIModuleOn = true
		PT.dataGroupMenuKeyboardPVPToolsData.visible = true
	end
	
	AI.AdjustIconColor()
	GROUP_MENU_KEYBOARD:RebuildCategories()
	PT.CheckEventRegistrations()
	
end


function AI.SetKickDelay(value)
	if PT.debug then PT.DebugEntry("PVPTools.AutoInvite.SetKickDelay") end
	
	local delay = tonumber(value)
	
	if delay == nil then delay = 1 end
	if delay > 600 then delay = 600 end
	
	PVPTools.ASV.settingsAIKickDelay = delay
end


--------------------------------------------------
-- AdjustIconColor - toggles the coloring of the icon in front of the AutoInvite entry in the Group Finder.  If we don't turn off the color when we turn off the module, icon color will stay in place for whatever option gets moved up to take AutoInvite's place.
--------------------------------------------------
function AI.AdjustIconColor()
	if PT.debug then PT.DebugEntry("PVPTools.AutoInvite.AdjustIconColor") end
	
	if PT.ASV.settingsAIModuleOn then
		local r=175/255 
		local g=84/255 
		local b=209/255 
		PT.controlGroupMenuKeyboardPVPToolsIcon:SetColor(r,g,b,1.00)
	else
		PT.controlGroupMenuKeyboardPVPToolsIcon:SetColor(255,255,255,1)
	end
end


--------------------------------------------------
-- ColorizeString - Add the AutoInvite color to the passed string and return it
--------------------------------------------------
function AI.ColorizeString(text)
	if PT.debug then PT.DebugEntry("PVPTools.AutoInvite.ColorizeString") end
	
	return "|cAF54D1"..text.."|r"
end



function AI.AddToIgnoreList(name)
	if PT.debug then PT.DebugEntry("PVPTools.AutoInvite.AddToIgnoreList") end
	
	if string.find(name, "@") then
		if not AI.IsPlayerOnIgnoreList(name) then
			table.insert(PVPTools.ASV.settingsAIIgnoreList, name)
			PVPTools.AMS.DisplayMessage(name.." added to Ignore List.", "ai")
			PlaySound(SOUNDS.GUILD_ROSTER_ADDED)
		else
			PVPTools.AMS.DisplayMessage(name.." is already on the Ignore List.", "ai")
			PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
		end
	else
		PVPTools.AMS.DisplayMessage("Missing @ in the player's @ name.", "ai")
		PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
	end
	
	-- Needed for Settings Menu
	local bannedKey = {}
	local bannedNames = {}
	
	if #PVPTools.ASV.settingsAIIgnoreList > 0 then
		for key, banned in ipairs(PVPTools.ASV.settingsAIIgnoreList) do
			table.insert(bannedKey, key)
			table.insert(bannedNames, banned)
		end
	end
	
	AutoInviteBannedList:UpdateChoices(bannedNames, bannedKey)
	AutoInviteBanPerson.editbox:SetText("")
end


function AI.RemoveFromIgnoreList(index)
	if PT.debug then PT.DebugEntry("PVPTools.AutoInvite.RemoveFromIgnoreList") end
	
	local name = PVPTools.ASV.settingsAIIgnoreList[index]
	table.remove(PVPTools.ASV.settingsAIIgnoreList, index)
	PVPTools.AMS.DisplayMessage(name.." removed from Ignore List.", "ai")
	PlaySound(SOUNDS.GUILD_ROSTER_REMOVED)
	
	-- Needed for Settings Menu
	local bannedKey = {}
	local bannedNames = {}
	
	if #PVPTools.ASV.settingsAIIgnoreList > 0 then
		for key, banned in ipairs(PVPTools.ASV.settingsAIIgnoreList) do
			table.insert(bannedKey, key)
			table.insert(bannedNames, banned)
		end
	end
	
	AutoInviteBannedList:UpdateChoices(bannedNames, bannedKey)
end





function AI.CreateGroupMenuEntry()
	if PT.debug then PT.DebugEntry("PVPTools.AutoInvite.CreateGroupMenuEntry") end
	--[[
		Here are the various priorities defined by the game
		esoui/ingame/lfg/zo_actifityfinderroot_manager.lua (line 1)
		ZO_ACTIVITY_FINDER_SORT_PRIORITY =
		{
			GROUP = 0,
			PROMOTIONAL_EVENTS = 100,
			SPECIAL_EVENTS = 200,
			GROUP_FINDER = 300,
			TIMED_ACTIVITIES = 400,
			ZONE_STORIES = 500,
			DUNGEONS = 600,
			BATTLEGROUNDS = 700,
			TRIBUNE = 800,
			HOUSE_TOURS = 900,
		}
	]]--

	-- esoui/esoui/ingame/group/keyboard/zo_grouplist_keyboard.lua line 70
	entryData = {
		priority = 10,
		name = AI.ColorizeString("Auto Invite"),
		categoryFragment = PVPTOOLS_GROUPMENUKEYBOARDFRAGMENT, 
		normalIcon = "/esoui/art/treeicons/collection_indexicon_weapons+armor_up.dds",
		pressedIcon = "/esoui/art/treeicons/collection_indexicon_weapons+armor_down.dds",
		mouseoverIcon = "/esoui/art/treeicons/collection_indexicon_weapons+armor_over.dds",
		visible = true,
	}
	GROUP_MENU_KEYBOARD:AddCategory(entryData)
	
	local childrenTable = GROUP_MENU_KEYBOARD.navigationTree.rootNode.children
	for key, element in ipairs(childrenTable) do
		if string.find(childrenTable[key].data.name, "Auto Invite") then
			PT.dataGroupMenuKeyboardPVPToolsData = childrenTable[key].data
			PT.controlGroupMenuKeyboardPVPToolsIcon = GetControl("ZO_GroupMenu_KeyboardCategoriesScrollChildZO_GroupMenuKeyboard_StatusIconChildlessHeader"..key.."Icon") 
		end
	end
	
	
	if PT.ASV.settingsAIModuleOn == false then
		PT.dataGroupMenuKeyboardPVPToolsData.visible = false
	else
		PT.dataGroupMenuKeyboardPVPToolsData.visible = true
	end
	
	AI.AdjustIconColor()
	GROUP_MENU_KEYBOARD:RebuildCategories()
end


function AI.CreateGroupMenuFragment()
	if PT.debug then PT.DebugEntry("PVPTools.AutoInvite.CreateGroupMenuFragment") end
	
	--[[
		LAM Editbox Controls
			label - the text sent in "name"
			container - holds the editbox and the background
			editbox - the actual edit box control
			bg - the background of the edit box ie. the white box
		LAM Checkbox Controls
			label - the text that identifies the checkbox
			container - holds the label
			checkbox - the checkbox itself
	--]]
	
	-- Initialize a whole bunch of stuff.  We may be able to get rid of a few of these along the way.
	local WM = WINDOW_MANAGER
	local fragment = PVPTools.groupMenuKeyboardFragment
	local rightPanelxOffset = 250
	local rightPanelyOffset = 15
	local rightPanelWidth = 680
	local half = 300
	local r=175/255 
	local g=84/255 
	local b=209/255
	local a = 1
	local fontName = "HANDWRITTEN_FONT"
	local fontSize = 54
	local fontStyle = "FONT_STYLE_OUTLINE_THICK"
	local fontString = string.format("$(%s)|$(KB_%s)|%s", fontName, fontSize, fontStyle)
	local channelName = ""
	
	fragment.main = WM:CreateControl("PVPToolsRightPanelFragment", PVPTools_GroupMenuKeyboardRightPanel, CT_CONTROL)
	
	fragment.main:SetWidth(rightPanelWidth)
	fragment.scroll = fragment.main
	fragment.panel = fragment.main
	fragment.panel.data = {}	
	
	fragment.panel:SetAnchor(TOPLEFT, PVPTools_GroupMenuKeyboardRightPanel, TOPLEFT, rightPanelxOffset, rightPanelyOffset)

	
	
	
	-- Title
	fragment.title = WM:CreateControl("PVPToolsRightPanelFragmentTitle", fragment.main, CT_LABEL)
	fragment.title:SetAnchor(TOPLEFT, fragment.panel, TOPLEFT, 0,-10)
	fragment.title:SetText("PVPTools Auto Invite")
	fragment.title:SetWidth(rightPanelWidth)
	fragment.title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	fragment.title:SetColor(r,g,b,a)
	fragment.title:SetFont(fontString)
	
	-- Title Divider
	fragment.titledivider = WM:CreateControl("PVPToolsRightPanelFragmentTitleDivider", fragment.main, CT_TEXTURE)
	fragment.titledivider:SetTexture("/esoui/art/miscellaneous/horizontaldivider_dynamic.dds")
	fragment.titledivider:SetColor(r,g,b,a)
	fragment.titledivider:SetWidth(rightPanelWidth)
	fragment.titledivider:SetHidden(false)
	fragment.titledivider:SetDimensions(rightPanelWidth, 16)
	fragment.titledivider:SetAnchor(TOPLEFT, fragment.title, BOTTOMLEFT, 0,-15)
	
	-- Auto Kick
	fragment.autoKick = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = "Auto Kick on disconnect / logout: ",
		tooltip = "Set whether to kick people who logout or get disconnected who do not log back on.",
		getFunc = function() return PVPTools.ASV.settingsAIAutoKick end,
		setFunc = function(value) PVPTools.ASV.settingsAIAutoKick = value PT.CheckEventRegistrations() end, 
	})
	
	fragment.autoKick.checkbox:SetAnchor(TOPLEFT, fragment.titledivider, BOTTOMLEFT, 250, 5)
	fragment.autoKick:SetAnchor(TOPLEFT, fragment.titledivider, BOTTOMLEFT, 0, 5)
	
	-- Kick Delay
	fragment.kickDelay = LAMCreateControl.editbox(fragment.main,{
		type = "editbox",
		name = "Kick Delay: ",
		tooltip = "Kick delay in seconds (minimum: 1 second / maximum: 600 seconds (10 min))",
		getFunc = function()return PVPTools.ASV.settingsAIKickDelay end,
		setFunc = function(value) AI.SetKickDelay(value)  end,
	})
	fragment.kickDelay.container:ClearAnchors()
	fragment.kickDelay.editbox:ClearAnchors()
	fragment.kickDelay.bg:ClearAnchors()
	
	fragment.kickDelay:SetWidth(150)
	fragment.kickDelay.container:SetWidth(150)
	fragment.kickDelay.editbox:SetWidth(50)
	fragment.kickDelay.bg:SetWidth(50)
	
	fragment.kickDelay.container:SetAnchor(BOTTOMLEFT, fragment.kickDelay.label, BOTTOMRIGHT, 5, 0)
	fragment.kickDelay.editbox:SetAnchor(LEFT, fragment.kickDelay.container, LEFT, 10, 0)
	fragment.kickDelay.bg:SetAnchor(LEFT, fragment.kickDelay.container, LEFT, 5, 0)
	
	fragment.kickDelay:SetAnchor(TOPLEFT, fragment.titledivider, BOTTOMLEFT, 325, 5)
	
	
	
	-- For now we are hard-wiring in three potential autoinvite listeners.
	
	
	
	-- First Listening String
	do -- code folding for Listener A
	
	-- Listener Divider A	
	fragment.dividerA = LAMCreateControl.divider(fragment.main,{
		type = "divider",
		height = 10,
		alpha = 1,
	})
	fragment.dividerA:SetAnchor(TOPLEFT, fragment.autoKick, BOTTOMLEFT, 0, 10)
	fragment.dividerA.divider:SetColor(r,g,b,a)
	fragment.dividerA.divider:SetTexture("/esoui/art/miscellaneous/horizontaldivider_dynamic.dds")
	fragment.dividerA.divider:SetDimensions(rightPanelWidth, 16)
	
	-- Editbox Invite String A
	fragment.listenStringA = LAMCreateControl.editbox(fragment.main,{
		type = "editbox",
		name = "Invite string 1: ",
		tooltip = "The string to listen for to trigger the auto invite.  Maximum of 10 characters long.",
		getFunc = function() return PVPTools.ASV.settingsAIWatchStrings[1]["text"] end,
		setFunc = function(value) if value=="" then value = "nullvalue" fragment.listenStringA.editbox:SetText(value) end PVPTools.ASV.settingsAIWatchStrings[1]["text"] = string.lower(value) end,
		width = "half",
	})
	
	fragment.listenStringA.container:ClearAnchors()
	fragment.listenStringA.editbox:ClearAnchors()
	fragment.listenStringA.bg:ClearAnchors()
	
	fragment.listenStringA:SetWidth(200)
	fragment.listenStringA.container:SetWidth(100)
	fragment.listenStringA.editbox:SetWidth(100)
	fragment.listenStringA.bg:SetWidth(100)
	
	fragment.listenStringA.container:SetAnchor(BOTTOMLEFT, fragment.listenStringA.label, BOTTOMRIGHT, 5, -2)
	fragment.listenStringA.editbox:SetAnchor(LEFT, fragment.listenStringA.container, LEFT, 10, 0 )
	fragment.listenStringA.bg:SetAnchor(LEFT, fragment.listenStringA.container, LEFT, 0,0)
	
	fragment.listenStringA:SetAnchor(TOPLEFT, fragment.dividerA, BOTTOMLEFT, 0, 10)
	
	-- Checkbox Enable Invite String A
	fragment.enableCheckboxA = LAMCreateControl.checkbox(fragment.main,{
		type = "checkbox",
		name = "Enable",
		tooltip = "Enable this Auto Invite listening string.",
		getFunc = function() return PVPTools.ASV.settingsAIWatchStrings[1]["enabled"] end,
		setFunc = function() PVPTools.ASV.settingsAIWatchStrings[1]["enabled"] = not PVPTools.ASV.settingsAIWatchStrings[1]["enabled"] PT.CheckEventRegistrations() end,
	})
	fragment.enableCheckboxA.checkbox:SetAnchor(LEFT, fragment.listenStringA, RIGHT, 75, -9)	
	fragment.enableCheckboxA:SetAnchor(LEFT, fragment.listenStringA, RIGHT, 10, -9)
	
	-- PT.guilds is an indexed table with each guild (1-5) having a row.  Each row has a subtable where [1] is the guild id and [2] is the guild name
	
	-- Checkbox Listen To Guild A
	channelName = AI.GetGuildName(1)
	fragment.listenCheckboxAguildA = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = channelName,
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_GUILD_1, 1) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_GUILD_1, 1) end,
		disabled = function() if channelName == "N/A" then return true else return false end end,
		width = "half"
	})
	fragment.listenCheckboxAguildA:SetWidth(half-60)
	fragment.listenCheckboxAguildA:SetAnchor(TOPLEFT, fragment.listenStringA, BOTTOMLEFT, 50, 5)
	fragment.listenCheckboxAguildA.checkbox:SetAnchor(TOPLEFT, fragment.listenStringA, BOTTOMLEFT, 15, 5)
	
	-- Checkbox Listen To Guild B
	channelName = AI.GetGuildName(2)
	fragment.listenCheckboxAguildB = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = channelName,
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_GUILD_2, 1) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_GUILD_2, 1) end,
		disabled = function() if channelName == "N/A" then return true else return false end end,
	})
	fragment.listenCheckboxAguildB:SetAnchor(TOPLEFT, fragment.listenStringA, BOTTOMLEFT, half + 35, 5)
	fragment.listenCheckboxAguildB.checkbox:SetAnchor(TOPLEFT, fragment.listenStringA, BOTTOMLEFT, half, 5)
	
	-- Checkbox Listen To Guild C
	channelName = AI.GetGuildName(3)
	fragment.listenCheckboxAguildC = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = channelName,
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_GUILD_3, 1) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_GUILD_3, 1) end,
		disabled = function() if channelName == "N/A" then return true else return false end end,
		width = "half",
	})
	fragment.listenCheckboxAguildC:SetWidth(half-60)
	fragment.listenCheckboxAguildC:SetAnchor(TOPLEFT, fragment.listenCheckboxAguildA.checkbox, BOTTOMLEFT, 35, 5)
	fragment.listenCheckboxAguildC.checkbox:SetAnchor(TOPLEFT, fragment.listenCheckboxAguildA.checkbox, BOTTOMLEFT, 0,5)
	
	-- Checkbox Listen To Guild D
	channelName = AI.GetGuildName(4)
	fragment.listenCheckboxAguildD = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = channelName,
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_GUILD_4, 1) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_GUILD_4, 1) end,
		disabled = function() if channelName == "N/A" then return true else return false end end,
	})
	
	fragment.listenCheckboxAguildD:SetAnchor(TOPLEFT, fragment.listenCheckboxAguildA.checkbox, BOTTOMLEFT, half + 20, 5)
	fragment.listenCheckboxAguildD.checkbox:SetAnchor(TOPLEFT, fragment.listenCheckboxAguildA.checkbox, BOTTOMLEFT, half - 15, 5)
	
	-- Checkbox Listen To Guild E
	channelName = AI.GetGuildName(5)
	fragment.listenCheckboxAguildE = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = channelName,
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_GUILD_5, 1) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_GUILD_5, 1) end,
		disabled = function() if channelName == "N/A" then return true else return false end end,
		width = "half",
	})
	fragment.listenCheckboxAguildE:SetWidth(half-60)
	fragment.listenCheckboxAguildE:SetAnchor(TOPLEFT, fragment.listenCheckboxAguildC.checkbox, BOTTOMLEFT, 35, 5)
	fragment.listenCheckboxAguildE.checkbox:SetAnchor(TOPLEFT, fragment.listenCheckboxAguildC.checkbox, BOTTOMLEFT, 0, 5)
	
	-- Checkbox Listen To Zone Chat
	fragment.listenCheckboxAguildF = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = "Zone",
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_ZONE, 1) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_ZONE, 1) end,
	
	})
	fragment.listenCheckboxAguildF:SetAnchor(TOPLEFT, fragment.listenCheckboxAguildC.checkbox, BOTTOMLEFT, half + 20, 5)
	fragment.listenCheckboxAguildF.checkbox:SetAnchor(TOPLEFT, fragment.listenCheckboxAguildC.checkbox, BOTTOMLEFT, half - 15, 5)
	
	-- Checkbox Listen To Say
	fragment.listenCheckboxAguildG = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = "Say",
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_SAY, 1) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_SAY, 1) end,
	
	})
	fragment.listenCheckboxAguildG:SetWidth(half-60)
	fragment.listenCheckboxAguildG:SetAnchor(TOPLEFT, fragment.listenCheckboxAguildE.checkbox, BOTTOMLEFT, 35, 5)
	fragment.listenCheckboxAguildG.checkbox:SetAnchor(TOPLEFT, fragment.listenCheckboxAguildE.checkbox,BOTTOMLEFT, 0, 5)
	
	end -- Code Folding for Listener A
	
	
	-- Second Listening String
	do -- code folding for Listener B
	
	-- Listener Divider B	
	fragment.dividerB = LAMCreateControl.divider(fragment.main,{
		type = "divider",
		height = 10,
		alpha = 1,
	})
	fragment.dividerB:SetAnchor(TOPLEFT, fragment.listenCheckboxAguildG, BOTTOMLEFT, -45, 10)
	fragment.dividerB.divider:SetColor(r,g,b,a)
	fragment.dividerB.divider:SetTexture("/esoui/art/miscellaneous/horizontaldivider_dynamic.dds")
	fragment.dividerB.divider:SetDimensions(rightPanelWidth, 16)

	-- Editbox Invite String B
	fragment.listenStringB = LAMCreateControl.editbox(fragment.main,{
		type = "editbox",
		name = "Invite string 2: ",
		tooltip = "The string to listen for to trigger the auto invite.  Maximum of 10 characters long.",
		getFunc = function() return PVPTools.ASV.settingsAIWatchStrings[2]["text"] end,
		setFunc = function(value) if value=="" then value = "nullvalue" fragment.listenStringB.editbox:SetText(value) end PVPTools.ASV.settingsAIWatchStrings[2]["text"] = string.lower(value) end,
		width = "half",
	})
	
	fragment.listenStringB.container:ClearAnchors()
	fragment.listenStringB.editbox:ClearAnchors()
	fragment.listenStringB.bg:ClearAnchors()
	
	fragment.listenStringB:SetWidth(200)
	fragment.listenStringB.container:SetWidth(100)
	fragment.listenStringB.editbox:SetWidth(100)
	fragment.listenStringB.bg:SetWidth(100)
	
	fragment.listenStringB.container:SetAnchor(BOTTOMLEFT, fragment.listenStringB.label, BOTTOMRIGHT, 5, -2)
	fragment.listenStringB.editbox:SetAnchor(LEFT, fragment.listenStringB.container, LEFT, 10, 0 )
	fragment.listenStringB.bg:SetAnchor(LEFT, fragment.listenStringB.container, LEFT, 0,0)
	
	fragment.listenStringB:SetAnchor(TOPLEFT, fragment.dividerB, BOTTOMLEFT, 0, 10)
	
	-- Checkbox Enable Invite String B
	fragment.enableCheckboxB = LAMCreateControl.checkbox(fragment.main,{
		type = "checkbox",
		name = "Enable",
		tooltip = "Enable this Auto Invite listening string.",
		getFunc = function() return PVPTools.ASV.settingsAIWatchStrings[2]["enabled"] end,
		setFunc = function() PVPTools.ASV.settingsAIWatchStrings[2]["enabled"] = not PVPTools.ASV.settingsAIWatchStrings[2]["enabled"] PT.CheckEventRegistrations() end,
	})
	fragment.enableCheckboxB.checkbox:SetAnchor(LEFT, fragment.listenStringB, RIGHT, 75, -9)	
	fragment.enableCheckboxB:SetAnchor(LEFT, fragment.listenStringB, RIGHT, 10, -9)
	
	-- PT.guilds is an indexed table with each guild (1-5) having a row.  Each row has a subtable where [1] is the guild id and [2] is the guild name
	
	-- Checkbox Listen To Guild A
	channelName = AI.GetGuildName(1)
	fragment.listenCheckboxBguildA = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = channelName,
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_GUILD_1, 2) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_GUILD_1, 2) end,
		disabled = function() if channelName == "N/A" then return true else return false end end,
		width = "half"
	})
	fragment.listenCheckboxBguildA:SetWidth(half-60)
	fragment.listenCheckboxBguildA:SetAnchor(TOPLEFT, fragment.listenStringB, BOTTOMLEFT, 50, 5)
	fragment.listenCheckboxBguildA.checkbox:SetAnchor(TOPLEFT, fragment.listenStringB, BOTTOMLEFT, 15, 5)
	
	-- Checkbox Listen To Guild B
	channelName = AI.GetGuildName(2)
	fragment.listenCheckboxBguildB = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = channelName,
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_GUILD_2, 2) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_GUILD_2, 2) end,
		disabled = function() if channelName == "N/A" then return true else return false end end,
	})
	fragment.listenCheckboxBguildB:SetAnchor(TOPLEFT, fragment.listenStringB, BOTTOMLEFT, half + 35, 5)
	fragment.listenCheckboxBguildB.checkbox:SetAnchor(TOPLEFT, fragment.listenStringB, BOTTOMLEFT, half, 5)
	
	-- Checkbox Listen To Guild C
	channelName = AI.GetGuildName(3)
	fragment.listenCheckboxBguildC = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = channelName,
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_GUILD_3, 2) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_GUILD_3, 2) end,
		disabled = function() if channelName == "N/A" then return true else return false end end,
		width = "half",
	})
	fragment.listenCheckboxBguildC:SetWidth(half-60)
	fragment.listenCheckboxBguildC:SetAnchor(TOPLEFT, fragment.listenCheckboxBguildA.checkbox, BOTTOMLEFT, 35, 5)
	fragment.listenCheckboxBguildC.checkbox:SetAnchor(TOPLEFT, fragment.listenCheckboxBguildA.checkbox, BOTTOMLEFT, 0,5)
	
	-- Checkbox Listen To Guild D
	channelName = AI.GetGuildName(4)
	fragment.listenCheckboxBguildD = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = channelName,
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_GUILD_4, 2) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_GUILD_4, 2) end,
		disabled = function() if channelName == "N/A" then return true else return false end end,
	})
	
	fragment.listenCheckboxBguildD:SetAnchor(TOPLEFT, fragment.listenCheckboxBguildA.checkbox, BOTTOMLEFT, half + 20, 5)
	fragment.listenCheckboxBguildD.checkbox:SetAnchor(TOPLEFT, fragment.listenCheckboxBguildA.checkbox, BOTTOMLEFT, half - 15, 5)
	
	-- Checkbox Listen To Guild E
	channelName = AI.GetGuildName(5)
	fragment.listenCheckboxBguildE = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = channelName,
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_GUILD_5, 2) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_GUILD_5, 2) end,
		disabled = function() if channelName == "N/A" then return true else return false end end,
		width = "half",
	})
	fragment.listenCheckboxBguildE:SetWidth(half-60)
	fragment.listenCheckboxBguildE:SetAnchor(TOPLEFT, fragment.listenCheckboxBguildC.checkbox, BOTTOMLEFT, 35, 5)
	fragment.listenCheckboxBguildE.checkbox:SetAnchor(TOPLEFT, fragment.listenCheckboxBguildC.checkbox, BOTTOMLEFT, 0, 5)
	
	-- Checkbox Listen To Zone Chat
	fragment.listenCheckboxBguildF = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = "Zone",
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_ZONE, 2) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_ZONE, 2) end,
	
	})
	fragment.listenCheckboxBguildF:SetAnchor(TOPLEFT, fragment.listenCheckboxBguildC.checkbox, BOTTOMLEFT, half + 20, 5)
	fragment.listenCheckboxBguildF.checkbox:SetAnchor(TOPLEFT, fragment.listenCheckboxBguildC.checkbox, BOTTOMLEFT, half - 15, 5)
	
	-- Checkbox Listen To Say
	fragment.listenCheckboxBguildG = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = "Say",
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_SAY, 2) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_SAY, 2) end,
	
	})
	fragment.listenCheckboxBguildG:SetWidth(half-60)
	fragment.listenCheckboxBguildG:SetAnchor(TOPLEFT, fragment.listenCheckboxBguildE.checkbox, BOTTOMLEFT, 35, 5)
	fragment.listenCheckboxBguildG.checkbox:SetAnchor(TOPLEFT, fragment.listenCheckboxBguildE.checkbox,BOTTOMLEFT, 0, 5)
	
	end -- Code Folding for Listener B

	
	
	-- Third Listening String
	do -- code folding for Listener C
	
	-- Listener Divider C	
	fragment.dividerC = LAMCreateControl.divider(fragment.main,{
		type = "divider",
		height = 10,
		alpha = 1,
	})
	fragment.dividerC:SetAnchor(TOPLEFT, fragment.listenCheckboxBguildG, BOTTOMLEFT, -45, 10)
	fragment.dividerC.divider:SetColor(r,g,b,a)
	fragment.dividerC.divider:SetTexture("/esoui/art/miscellaneous/horizontaldivider_dynamic.dds")
	fragment.dividerC.divider:SetDimensions(rightPanelWidth, 16)
	
	-- Editbox Invite String C
	fragment.listenStringC = LAMCreateControl.editbox(fragment.main,{
		type = "editbox",
		name = "Invite string 3: ",
		tooltip = "The string to listen for to trigger the auto invite.  Maximum of 10 characters long.",
		getFunc = function() return PVPTools.ASV.settingsAIWatchStrings[3]["text"] end,
		setFunc = function(value) if value=="" then value = "nullvalue" fragment.listenStringA.editbox:SetText(value) end PVPTools.ASV.settingsAIWatchStrings[3]["text"] = string.lower(value) end,
		width = "half",
	})
	
	fragment.listenStringC.container:ClearAnchors()
	fragment.listenStringC.editbox:ClearAnchors()
	fragment.listenStringC.bg:ClearAnchors()
	
	fragment.listenStringC:SetWidth(200)
	fragment.listenStringC.container:SetWidth(100)
	fragment.listenStringC.editbox:SetWidth(100)
	fragment.listenStringC.bg:SetWidth(100)
	
	fragment.listenStringC.container:SetAnchor(BOTTOMLEFT, fragment.listenStringC.label, BOTTOMRIGHT, 5, -2)
	fragment.listenStringC.editbox:SetAnchor(LEFT, fragment.listenStringC.container, LEFT, 10, 0 )
	fragment.listenStringC.bg:SetAnchor(LEFT, fragment.listenStringC.container, LEFT, 0,0)
	
	fragment.listenStringC:SetAnchor(TOPLEFT, fragment.dividerC, BOTTOMLEFT, 0, 10)
	
	-- Checkbox Enable Invite String C
	fragment.enableCheckboxC = LAMCreateControl.checkbox(fragment.main,{
		type = "checkbox",
		name = "Enable",
		tooltip = "Enable this Auto Invite listening string.",
		getFunc = function() return PVPTools.ASV.settingsAIWatchStrings[3]["enabled"] end,
		setFunc = function() PVPTools.ASV.settingsAIWatchStrings[3]["enabled"] = not PVPTools.ASV.settingsAIWatchStrings[3]["enabled"] PT.CheckEventRegistrations() end,
	})
	fragment.enableCheckboxC.checkbox:SetAnchor(LEFT, fragment.listenStringC, RIGHT, 75, -9)	
	fragment.enableCheckboxC:SetAnchor(LEFT, fragment.listenStringC, RIGHT, 10, -9)
	
	-- PT.guilds is an indexed table with each guild (1-5) having a row.  Each row has a subtable where [1] is the guild id and [2] is the guild name
	
	-- Checkbox Listen To Guild A
	channelName = AI.GetGuildName(1)
	fragment.listenCheckboxCguildA = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = channelName,
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_GUILD_1, 3) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_GUILD_1, 3) end,
		disabled = function() if channelName == "N/A" then return true else return false end end,
		width = "half"
	})
	fragment.listenCheckboxCguildA:SetWidth(half-60)
	fragment.listenCheckboxCguildA:SetAnchor(TOPLEFT, fragment.listenStringC, BOTTOMLEFT, 50, 5)
	fragment.listenCheckboxCguildA.checkbox:SetAnchor(TOPLEFT, fragment.listenStringC, BOTTOMLEFT, 15, 5)
	
	-- Checkbox Listen To Guild B
	channelName = AI.GetGuildName(2)
	fragment.listenCheckboxCguildB = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = channelName,
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_GUILD_2, 3) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_GUILD_2, 3) end,
		disabled = function() if channelName == "N/A" then return true else return false end end,
	})
	fragment.listenCheckboxCguildB:SetAnchor(TOPLEFT, fragment.listenStringC, BOTTOMLEFT, half + 35, 5)
	fragment.listenCheckboxCguildB.checkbox:SetAnchor(TOPLEFT, fragment.listenStringC, BOTTOMLEFT, half, 5)
	
	-- Checkbox Listen To Guild C
	channelName = AI.GetGuildName(3)
	fragment.listenCheckboxCguildC = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = channelName,
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_GUILD_3, 3) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_GUILD_3, 3) end,
		disabled = function() if channelName == "N/A" then return true else return false end end,
		width = "half",
	})
	fragment.listenCheckboxCguildC:SetWidth(half-60)
	fragment.listenCheckboxCguildC:SetAnchor(TOPLEFT, fragment.listenCheckboxCguildA.checkbox, BOTTOMLEFT, 35, 5)
	fragment.listenCheckboxCguildC.checkbox:SetAnchor(TOPLEFT, fragment.listenCheckboxCguildA.checkbox, BOTTOMLEFT, 0,5)
	
	-- Checkbox Listen To Guild D
	channelName = AI.GetGuildName(4)
	fragment.listenCheckboxCguildD = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = channelName,
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_GUILD_4, 3) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_GUILD_4, 3) end,
		disabled = function() if channelName == "N/A" then return true else return false end end,
	})
	
	fragment.listenCheckboxCguildD:SetAnchor(TOPLEFT, fragment.listenCheckboxCguildA.checkbox, BOTTOMLEFT, half + 20, 5)
	fragment.listenCheckboxCguildD.checkbox:SetAnchor(TOPLEFT, fragment.listenCheckboxCguildA.checkbox, BOTTOMLEFT, half - 15, 5)
	
	-- Checkbox Listen To Guild E
	channelName = AI.GetGuildName(5)
	fragment.listenCheckboxCguildE = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = channelName,
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_GUILD_5, 3) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_GUILD_5, 3) end,
		disabled = function() if channelName == "N/A" then return true else return false end end,
		width = "half",
	})
	fragment.listenCheckboxCguildE:SetWidth(half-60)
	fragment.listenCheckboxCguildE:SetAnchor(TOPLEFT, fragment.listenCheckboxCguildC.checkbox, BOTTOMLEFT, 35, 5)
	fragment.listenCheckboxCguildE.checkbox:SetAnchor(TOPLEFT, fragment.listenCheckboxCguildC.checkbox, BOTTOMLEFT, 0, 5)
	
	-- Checkbox Listen To Zone Chat
	fragment.listenCheckboxCguildF = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = "Zone",
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_ZONE, 3) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_ZONE, 3) end,
	
	})
	fragment.listenCheckboxCguildF:SetAnchor(TOPLEFT, fragment.listenCheckboxCguildC.checkbox, BOTTOMLEFT, half + 20, 5)
	fragment.listenCheckboxCguildF.checkbox:SetAnchor(TOPLEFT, fragment.listenCheckboxCguildC.checkbox, BOTTOMLEFT, half - 15, 5)
	
	-- Checkbox Listen To Say
	fragment.listenCheckboxCguildG = LAMCreateControl.checkbox(fragment.main, {
		type = "checkbox",
		name = "Say",
		getFunc = function() return AI.AreWeListeningToThisChannel(CHAT_CHANNEL_SAY, 3) end,
		setFunc = function() AI.SetListeningToThisChannel(CHAT_CHANNEL_SAY, 3) end,
	
	})
	fragment.listenCheckboxCguildG:SetWidth(half-60)
	fragment.listenCheckboxCguildG:SetAnchor(TOPLEFT, fragment.listenCheckboxCguildE.checkbox, BOTTOMLEFT, 35, 5)
	fragment.listenCheckboxCguildG.checkbox:SetAnchor(TOPLEFT, fragment.listenCheckboxCguildE.checkbox,BOTTOMLEFT, 0, 5)
	
	end -- Code Folding
	
	
	PVPTOOLS_GROUPMENUKEYBOARDFRAGMENT = ZO_FadeSceneFragment:New(PVPTools_GroupMenuKeyboardRightPanel)
end

function AI.AutoInviteShouldBeListening()
	-- /script d(PVPTools.ConvertBool(PVPTools.AutoInvite.AutoInviteShouldBeListening()))
	if PT.debug then PT.DebugEntry("PVPTools.AutoInvite.AutoInviteShouldBeListening") end
	
	local activated = false
	
	for key, data in ipairs(PT.ASV.settingsAIWatchStrings) do
		if data["enabled"] == true then activated = true end
	end
	
	if PT.debug then PT.DebugEntry(PT.Spacer()..PT.ConvertBool(activated)) end
	return activated
end

function AI.IsListenStringEnabled(index)
	if PT.debug then PT.DebugEntry("PVPTools.AutoInvite. IsListenStringEnabled") end
	
	if PT.ASV.settingsAIWatchStrings[index]["enabled"] then 
		return true
	else
		return false
	end
end



function AI.GetGuildName(index)
	if PT.debug then PT.DebugEntry("PVPTools.AutoInvite.GetGuildName") end
	
	if PT.guilds[index][1] ~= 0 then 
		return PT.guilds[index][2]
	else
		return "N/A"
	end
	
end



function AI.AreWeListeningToThisChannel(channel, listener)
	if PT.debug then PT.DebugEntry("PVPTools.AutoInvite.AreWeListeningToThisChannel") end
	
	local listeningChannels = PVPTools.ASV.settingsAIWatchStrings[listener]["channels"]
	local found = false
	
	for key, chan in ipairs(listeningChannels) do
		if chan == channel then found = true break end
	end
	
	return found
end

function AI.SetListeningToThisChannel(channel, listener)
	if PT.debug then PT.DebugEntry ("PVPTools.AutoInvite.SetListeningToThisChannel") end
	
	local listeningChannels = PVPTools.ASV.settingsAIWatchStrings[listener]["channels"]
	local found = false
	
	for key, chan in ipairs(listeningChannels) do
		if chan == channel then table.remove(listeningChannels, key) found = true break end
	end
	
	if (not found) then
		table.insert(listeningChannels, channel)
	end
end



function AI.ProcessMessage(channel, message, player)
	-- /script PVPTools.AutoInvite.ProcessMessage(CHAT_CHANNEL_GUILD_3, "lfg", "@name")
	-- /script d(PVPTools.ASV.settingsAIWatchStrings)
	-- CHAT_CHANNEL_GUILD_1  CHAT_CHANNEL_GUILD_2  CHAT_CHANNEL_GUILD_3  CHAT_CHANNEL_GUILD_4  CHAT_CHANNEL_GUILD_5  CHAT_CHANNEL_SAY  CHAT_CHANNEL_ZONE
	if PT.debug then 
		PT.DebugEntry("PVPTools.AutoInvite.ProcessMessage")
		PT.DebugEntry(PT.Spacer() .. "Channel: " .. channel)
		PT.DebugEntry(PT.Spacer() .. "Message: " .. message)
		PT.DebugEntry(PT.Spacer() .. "Player: " .. player)
	end
	
	local validString = false
	
	if PT.IsMe(player) then return end
	
	message = string.lower(message)
	
	for index = 1, 3 do
		if AI.IsListenStringEnabled(index) and not validString then
			if AI.AreWeListeningToThisChannel(channel, index) then
				if message == PT.ASV.settingsAIWatchStrings[index]["text"] then
					validString = true
				end
			end
		end
	end
	
	if validString then
		if not AI.IsPlayerOnIgnoreList(player) then
			if GetGroupSize() < 12 then
				PVPTools.AMS.DisplayChatMessage("Sending group invite to "..player, "ai")
				GroupInviteByName(player)
			else
				PVPTools.AMS.DisplayMessage("Group is full.", "ai")
				PlaySound(PT.soundError)
			end
		else
			PVPTools.AMS.DisplayChatMessage("Invite not sent.  "..player.." is on the Ignore List.", "ai")	
		end	
	end
end


function AI.IsPlayerOnIgnoreList(checkName)
	if PT.debug then PT.DebugEntry("PVPTools.AutoInvite.IsPlayerOnIgnoreList") end
	
	local found = false
	
	for key, listName in ipairs(PVPTools.ASV.settingsAIIgnoreList) do
		if listName == checkName then found = true break end
	end
	
	return found
end


function AI.PlayerDisconnected(displayName)
	if PT.debug then PT.DebugEntry("PVPTools.AutoInvite.PlayerDisconnected") end
	
	for index = 1, GetGroupSize() do
		local checkTag = GetGroupUnitTagByIndex(index)
		local checkName = GetUnitDisplayName(checkTag)
		if checkName == displayName then
			if not IsUnitOnline(checkTag) then
				GroupKick(checkTag)
			end
			break 
		end
	end
end




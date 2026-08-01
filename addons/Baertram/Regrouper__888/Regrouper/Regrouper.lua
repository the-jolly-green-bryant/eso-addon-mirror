-- VARIABLE DECLARATION
local groupMembers 	= {}
local addon    		= {}
addon.name	   		= "Regrouper"
addon.author		= "Baertram & Aju"
addon.version  		= 1.4
addon.shownVersion  = "2.2"

addon.preventerVars = {}
addon.preventerVars.fadingIn = false
addon.preventerVars.fadingOut = false
addon.preventerVars.mouseEntered = false

local settings = {}
settings.lastGroupMembers = {}
local tooltip = {}
tooltip.groupText = "Regroup"

local function SaveLocMinimized()
	settings.OffsetXMinimized = regrouper:GetLeft()
	settings.OffsetYMinimized = regrouper:GetTop()
    d(">> Position (with chat minimized) saved")
end

function SaveLoc()
	if not CHAT_SYSTEM:IsMinimized() then
		settings.OffsetX = regrouper:GetLeft()
		settings.OffsetY = regrouper:GetTop()
    else
		if settings.repositionOnChatMinimize then
			SaveLocMinimized()
        end
    end
end

--Enable/Dsiable buttons if in a group or not
local function updateButton(buttonCtrl, newState)
	if buttonCtrl ~= nil then
        buttonCtrl:SetInheritAlpha(true)
		if newState == nil then

            if buttonCtrl == regrouperregroup then
				--Is any previous group data given?
				if #groupMembers <= 0 and #settings.lastGroupMembers <= 0 then
					buttonCtrl:SetMouseEnabled(false)
					buttonCtrl:SetEnabled(false)
                else
					buttonCtrl:SetMouseEnabled(true)
					buttonCtrl:SetEnabled(true)
                end
            else
				--Are we inside a group?
				local grouped = GetGroupSize() > 1
				if grouped then
					buttonCtrl:SetMouseEnabled(true)
					buttonCtrl:SetEnabled(true)
		        else
					buttonCtrl:SetMouseEnabled(false)
					buttonCtrl:SetEnabled(false)
		        end
            end
        else
			buttonCtrl:SetMouseEnabled(newState)
			buttonCtrl:SetEnabled(newState)
        end
	end
end

--Update the buttons
local function updateButtons()
	updateButton(regroupersave)
	updateButton(regrouperdisband)
	updateButton(regrouperregroup)
end

function save()
	-- Get group Size
	local groupSize = GetGroupSize()
    if groupSize <= 1 then
    	d(">> You are not in a group")
    	return
    end

	--Initialize the array
    groupMembers = {}

	local charName
    local playerName = GetUnitName("player")
	-- Cycle through group and save their "unitTags"
	for i=1, groupSize, 1 do
		charName = GetUnitName(GetGroupUnitTagByIndex(i))
        if charName ~= playerName then
	    	table.insert(groupMembers, charName)
        end
	end
	if #groupMembers > 0 then
		d(">> Group saved")
		settings.lastGroupMembers = groupMembers
	end
end

function disband()
	if GetGroupSize() > 1 then
		GroupDisband()
	else
    	d(">> You are not in a group")
        return
	end
end

function reGroup()
	if #groupMembers <= 0 and #settings.lastGroupMembers <= 0 then
    	d(">> Last group list is empty")
    	return
    end

	if #groupMembers <= 0 then
    	if #settings.lastGroupMembers > 0 then
        	groupMembers = settings.lastGroupMembers
		end
    end
	d(">> Regrouping")
	-- Cycle through array and invite people
	local myPlayerName = GetUnitName("player")
	for i=1, #groupMembers, 1 do
        if groupMembers[i] ~= nil and groupMembers[i] ~= "" and groupMembers[i] ~= myPlayerName then
	    	GroupInviteByName(groupMembers[i])
			d("--> invited: " .. groupMembers[i])
        end
	end
end

--Show last group members
local function listGroup(tooltipMode)
	tooltipMode = tooltipMode or false
	local groupPlayers = {}
	if #groupMembers <= 0 then
    	if #settings.lastGroupMembers > 0 then
        	groupPlayers = settings.lastGroupMembers
		end
	else
    	groupPlayers = groupMembers
    end
    if #groupPlayers > 0 then
		if tooltipMode then
			--Tooltip building mode
			tooltip.groupText = "Regroup:\n"
			for i=1, #groupPlayers, 1 do
				tooltip.groupText = tooltip.groupText .. groupPlayers[i]
                if i < #groupPlayers then
                	tooltip.groupText = tooltip.groupText .. "\n"
                end
	        end
			updateButton(regrouperregroup)
	    else
			d(">> Last players in group:")
			for i=1, #groupPlayers, 1 do
	        	d("--> " .. groupPlayers[i])
	        end
			updateButton(regrouperregroup)
		end
	else
    	if tooltipMode then
			tooltip.groupText = "Regroup"
        else
	    	d(">> Last group list is empty")
        end
    end
end

--Clear the last saved player names from the arrays and settings
local function clear(where)
	local somethingCleared = false
	where = where or 1
	if where == 3 then
		if #groupMembers > 0 then
	    	groupMembers = {}
	        d(">> Cleared last player names")
            somethingCleared = true
	    end
		if #settings.lastGroupMembers > 0 then
	    	settings.lastGroupMembers = {}
	        d(">> Removed last player names from SavedVariables")
            somethingCleared = true
	    end
        tooltip.groupText = "Regroup"
    elseif where == 2 then
		if #settings.lastGroupMembers > 0 then
	    	settings.lastGroupMembers = {}
	        d(">> Removed last player names from SavedVariables")
            somethingCleared = true
	    end
    elseif where == 1 then
		if #groupMembers > 0 then
	    	groupMembers = {}
	        d(">> Cleared last player names")
            somethingCleared = true
	    end
    end

	if #groupMembers <= 0 and #settings.lastGroupMembers <= 0 then
		tooltip.groupText = "Regroup"
	end

    if somethingCleared then
		updateButtons()
    else
    	d(">> Last group list is empty")
    end
end

--Change drag & drop ability of regrouper buttons
local function move(canMove)
	if canMove == -1 then
		canMove = not settings.movable
	else
		canMove = canMove or false
    end

  	regrouper:SetMovable(canMove)

	if canMove then
		d(">> Drag & Drop enabled")
    else
		d(">> Drag & Drop disabled")
    end

    settings.movable = canMove
end

--Change layout (horizontal, vertical) of regrouper buttons
local function layout(layout, layoutType, chatOutput)
    if chatOutput == nil then chatOutput = true end
	--Get the layout type. Normal or Chat minimized
    layoutType = layoutType or "normal"
	if layoutType == nil or (layoutType ~= "normal" and layoutType ~= "min") then return end
	--Addon layout is already the correct one? Then leave here
   	if layoutType == "normal" and layout ~= -1 and settings.layout == 1 then return end
   	--if layoutType == "min" and layout ~= -1 and settings.layoutMinimized == 1 then return end

	--Normal layout
	if layoutType == "normal" then
		--Toogle between different layouts?
		if layout == -1 then
	    	if settings.layout == 1 then
	        	layout = 2
	        else
	        	layout = 1
	        end
	    else
	    	layout = layout or 1
	    end

		--Vertical
		if layout == 1 then
	        regrouper:ClearAnchors()
			regrouper:SetWidth(33)
	    	regrouper:SetHeight(90)
			regrouper:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settings.OffsetX, settings.OffsetY)

	        regrouperBG:ClearAnchors()
	    	regrouperBG:SetWidth(33)
	    	regrouperBG:SetHeight(10)
			regrouperBG:SetAnchor(TOPLEFT, regrouper, TOPLEFT, 0, 0)

			regroupersave:ClearAnchors()
			regroupersave:SetAnchor(TOPLEFT, regrouper, TOPLEFT, 2, 10)

			regrouperdisband:ClearAnchors()
			regrouperdisband:SetAnchor(TOPLEFT, regrouper, TOPLEFT, 3, 38)

			regrouperregroup:ClearAnchors()
			regrouperregroup:SetAnchor(TOPLEFT, regrouper, TOPLEFT, 3, 64)
            if chatOutput then
				d(">> Vertical layout")
            end

		--Horizontal
	    else
	        regrouper:ClearAnchors()
	    	regrouper:SetWidth(90)
	    	regrouper:SetHeight(33)
			regrouper:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settings.OffsetX, settings.OffsetY)

	        regrouperBG:ClearAnchors()
	    	regrouperBG:SetWidth(10)
	    	regrouperBG:SetHeight(33)
			regrouperBG:SetAnchor(TOPLEFT, regrouper, TOPLEFT, 0, 0)

			regroupersave:ClearAnchors()
			regroupersave:SetAnchor(TOPLEFT, regrouper, TOPLEFT, 10, 0)

			regrouperdisband:ClearAnchors()
			regrouperdisband:SetAnchor(TOPLEFT, regrouper, TOPLEFT, 38, 4)

			regrouperregroup:ClearAnchors()
			regrouperregroup:SetAnchor(TOPLEFT, regrouper, TOPLEFT, 66, 4)

            if chatOutput then
				d(">> Horizontal layout")
            end
	    end

		--Update local instance variables from SavedVariables
	    settings.layout = layout
    else
	--Chat minimized layout

		if settings.OffsetXMinimized == 0 and settings.OffsetYMinimized == 0 then
			--Copy offsets from normal state
			if settings.OffsetX ~= 0 then
				settings.OffsetXMinimized = settings.OffsetX
			end
			if settings.OffsetY ~= 0 then
				settings.OffsetYMinimized = settings.OffsetY
			end
		end

		--Toogle between different layouts?
		if layout == -1 then
	    	if settings.layoutMinimized == 1 then
	        	layout = 2
	        else
	        	layout = 1
	        end
	    else
	    	layout = layout or 1
	    end

		--Vertical
		if layout == 1 then
	        regrouper:ClearAnchors()
			regrouper:SetWidth(33)
	    	regrouper:SetHeight(90)
			regrouper:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settings.OffsetXMinimized, settings.OffsetYMinimized)

	        regrouperBG:ClearAnchors()
	    	regrouperBG:SetWidth(33)
	    	regrouperBG:SetHeight(10)
			regrouperBG:SetAnchor(TOPLEFT, regrouper, TOPLEFT, 0, 0)

			regroupersave:ClearAnchors()
			regroupersave:SetAnchor(TOPLEFT, regrouper, TOPLEFT, 2, 10)

			regrouperdisband:ClearAnchors()
			regrouperdisband:SetAnchor(TOPLEFT, regrouper, TOPLEFT, 3, 38)

			regrouperregroup:ClearAnchors()
			regrouperregroup:SetAnchor(TOPLEFT, regrouper, TOPLEFT, 3, 64)

            if chatOutput then
				d(">> Vertical chat minimized layout")
            end

		--Horizontal
	    else
	        regrouper:ClearAnchors()
	    	regrouper:SetWidth(90)
	    	regrouper:SetHeight(33)
			regrouper:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settings.OffsetXMinimized, settings.OffsetYMinimized)

	        regrouperBG:ClearAnchors()
	    	regrouperBG:SetWidth(10)
	    	regrouperBG:SetHeight(33)
			regrouperBG:SetAnchor(TOPLEFT, regrouper, TOPLEFT, 0, 0)

			regroupersave:ClearAnchors()
			regroupersave:SetAnchor(TOPLEFT, regrouper, TOPLEFT, 10, 0)

			regrouperdisband:ClearAnchors()
			regrouperdisband:SetAnchor(TOPLEFT, regrouper, TOPLEFT, 38, 4)

			regrouperregroup:ClearAnchors()
			regrouperregroup:SetAnchor(TOPLEFT, regrouper, TOPLEFT, 66, 4)

            if chatOutput then
				d(">> Horizontal chat minimized layout")
            end
	    end

		--Update local instance variables from SavedVariables
	    settings.layoutMinimized = layout
    end
end

--Move regrouper frame to last saved position
local function RepositionRegrouper()
	if CHAT_SYSTEM:IsMinimized() and settings.repositionOnChatMinimize then
		--Were the offets already changed?
		if settings.OffsetXMinimized == 0 and settings.OffsetYMinimized == 0 then
			--Copy offsets from normal state
			if settings.OffsetX ~= 0 then
				settings.OffsetXMinimized = settings.OffsetX
			end
			if settings.OffsetY ~= 0 then
				settings.OffsetYMinimized = settings.OffsetY
			end
		end
		if (  (settings.OffsetXMinimized ~= 0 and settings.OffsetYMinimized ~= 0)
           or (settings.OffsetXMinimized ~= 0 and settings.OffsetYMinimized == 0)
           or (settings.OffsetXMinimized == 0 and settings.OffsetYMinimized ~= 0) ) then
			regrouper:ClearAnchors()
			regrouper:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settings.OffsetXMinimized, settings.OffsetYMinimized)
			--Change the regrouper layout to horizontal or vertical
			layout(settings.layoutMinimized, "min", false)
		end
	else
		regrouper:ClearAnchors()
		regrouper:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settings.OffsetX, settings.OffsetY)
		--Change the regrouper layout to horizontal or vertical
	    layout(settings.layout, "normal", false)
    end
end

--Add a name to the last saved players list
local function add(nameParts)
	local noCharName = false
	if nameParts ~= nil and #nameParts == 2 then
		--Build the name from the 2nd arguments from the chat, to skip 1st one ("add")
        local playerName = nameParts[2]
    	if playerName ~= "" then
			if playerName == GetUnitName("player") then
				d(">> You cannot add yourself to the last group list")
            	return
            end
            local alreadyIn = false
			local playersLastInGroup = {}
            if #groupMembers > 0 then
            	playersLastInGroup = groupMembers
            elseif #settings.lastGroupMembers > 0 then
            	playersLastInGroup = settings.lastGroupMember
            end
            if #playersLastInGroup > 0 then
				for i=1, #playersLastInGroup, 1 do
					if playersLastInGroup[i] == playerName then
	                	alreadyIn = true
	                    break
	                end
		        end
      		end
			if not alreadyIn then
				table.insert(groupMembers, playerName)
				settings.lastGroupMembers = groupMembers
				d(">> Added player [" .. playerName .. "] to last group")
				updateButton(regrouperregroup)
			else
				d(">> Player [" .. playerName .. "] was already in last group")
			end
		else
           	noCharName = true
        end
	else
    	noCharName = true
    end
    if noCharName then
		d(">> No character name specified. Syntax: /rg add <character name>")
    end
end

--Chat slash commands handler
local function chatCommand(command)
    --Parse the arguments string
	local cmd_options = {}
    local searchResult = { string.match(command, "^(%S*)%s*(.-)$") }
	local noLowerCase = false
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            if noLowerCase then
        		cmd_options[i] = v
            else
        		cmd_options[i] = string.lower(v)
           	end
            if i == 1 and v == "add" then
				noLowerCase = true
			end
        end
    end

	if command == "" or #cmd_options == 0 or cmd_options == nil then
		regrouper:SetHidden(not regrouper:IsHidden())
    else
    	if cmd_options[1] == "help" then
        	d("[Regrouper "..tostring(addon.shownVersion).."] - Available chat commands:")
			d("-> help: Show this list of chat commands")
        	d("-> save: Save the current group")
        	d("-> disband: Disband your current group")
        	d("-> regroup: Regroup with the last players")
        	d("-> list: List the last players in your group")
            d("-> add <name>: Add the player <name> to the last saved player names")
            d("-> clear <where?>: Clear the last saved player names at")
            d("-----> <where?> 1: This session, 2: SavedVariables, 3: Both")
            d("-> layout: Toggle button layout between vertical/horizontal")
            d("-> move: Toggle drag & drop ability of buttons")
			d("-> chatmin: Toggle the settings ON/OFF for an alternative Regrouper position if the chat is minimized. Drag/drop Regrouper to the new position and use the following chat commands to save and change the look:")
            d("--> savemin: Save the current position. Regrouper will be moved here if the chat gets minimized.")
            d("--> layoutmin: Toggle button layout between vertical/horizontal. Regrouper will use this layout if the chat gets minimized.")
            d("-> chatfade: Enable/Dsiable if regrouper should fade out/in with the chat.")
    	elseif cmd_options[1] == "list" then
        	listGroup(false)
    	elseif cmd_options[1] == "save" then
        	save()
    	elseif cmd_options[1] == "disband" then
        	disband()
    	elseif cmd_options[1] == "regroup" then
        	reGroup()
    	elseif cmd_options[1] == "clear" and cmd_options[2] ~= "" then
        	clear(tonumber(cmd_options[2]))
    	elseif cmd_options[1] == "layout" then
        	layout(-1, "normal")
    	elseif cmd_options[1] == "move" then
        	move(-1)
    	elseif cmd_options[1] == "add" and cmd_options[2] ~= "" then
        	add(cmd_options)
        elseif cmd_options[1] == "layoutmin" then
	        layout(-1, "min")
        elseif cmd_options[1] == "savemin" then
	        SaveLocMinimized()
        elseif cmd_options[1] == "chatfade" then
            settings.fadeOutOnChatFadeOut = not settings.fadeOutOnChatFadeOut
            local fadeOutSettingsString
            if settings.fadeOutOnChatFadeOut then
                fadeOutSettingsString = "ON"
            else
                fadeOutSettingsString = "OFF"
            end
            d("-> Fading out on chat fade out: " .. fadeOutSettingsString)
        elseif cmd_options[1] == "chatmin" then
        	settings.repositionOnChatMinimize = not settings.repositionOnChatMinimize
            local settingsString
            if settings.repositionOnChatMinimize then
            	settingsString = "ON"
            else
            	settingsString = "OFF"
            end
            d("-> Alternative position for minimized chat: " .. settingsString)
        end
    end
end

-- Define new chat command
SLASH_COMMANDS["/regrouper"] = chatCommand
SLASH_COMMANDS["/rg"] = chatCommand

--Event function for event EVENT_GROUP_MEMBER_JOINED
local function OnGroupMemberJoined(eventCode, characterName)
   	updateButtons()
end

--Event function for event EVENT_GROUP_MEMBER_LEFT
local function OnGroupMemberLeft(eventCode, characterName, reason, wasLocalPlayer, amLeader)
   	updateButtons()
end

--The pre hooks for the game menu etc.
local function PreHooks()
    -- Hook the game menus etc to Hide / Show
    ZO_PreHookHandler(ZO_GameMenu_InGame, "OnShow", function()
        regrouper:SetHidden(true)
    end)
    ZO_PreHookHandler(ZO_GameMenu_InGame, "OnHide", function()
        regrouper:SetHidden(false)
    end)
    ZO_PreHookHandler(ZO_InteractWindow, "OnShow", function()
        regrouper:SetHidden(true)
    end)
    ZO_PreHookHandler(ZO_InteractWindow, "OnHide", function()
        regrouper:SetHidden(false)
    end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnShow", function()
        regrouper:SetHidden(true)
    end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnHide", function()
        regrouper:SetHidden(false)
    end)
    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnShow", function()
        regrouper:SetHidden(true)
    end)
    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnHide", function()
        regrouper:SetHidden(false)
    end)
    CHAMPION_PERKS_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            regrouper:SetHidden(true)
        elseif newState == SCENE_HIDDEN then
            regrouper:SetHidden(false)
        end
    end)
    --OnMinimize of the chat system
    ZO_PreHook(CHAT_SYSTEM, "Minimize", function()
        if settings.repositionOnChatMinimize then
            --Reposition Regrouper
            zo_callLater(function() RepositionRegrouper() end, 250)
        end
    end)
    --OnMaximize of the chat system
    ZO_PreHook(CHAT_SYSTEM, "Maximize", function()
        --Reposition Regrouper
        zo_callLater(function() RepositionRegrouper() end, 250)
    end)
end

local function FadeInCheck()
    local chatContainer = CHAT_SYSTEM.primaryContainer
    if chatContainer ~= nil then
        local maxAlpha = chatContainer.maxAlpha or 1
        if maxAlpha == 0 then maxAlpha = 0.10 end
        if settings.fadeOutOnChatFadeOut and not regrouper:IsHidden() and regrouper:GetAlpha() < maxAlpha then
            regrouper:SetAlpha(maxAlpha)
        end
    end
end

local function FadeOutCheck(doOverride)
    doOverride = doOverride or false
    local chatContainer = CHAT_SYSTEM.primaryContainer
    if chatContainer ~= nil then
        local minAlpha = chatContainer.minAlpha or 0.10
        if minAlpha == 0 then minAlpha = 0.10 end
        if (doOverride or (settings.fadeOutOnChatFadeOut and not regrouper:IsHidden() and regrouper:GetAlpha() > minAlpha and chatContainer.control:GetAlpha() == minAlpha)) then
            zo_callLater(function() regrouper:SetAlpha(minAlpha) end, 100)
        end
    end
end

--Player activated
local function OnPlayerActivated(event)
    --Hook the game menus etc.
    PreHooks()

    --Set inherit alpha from parent for the regrouper controls
    regrouperBG:SetInheritAlpha(true)
    regroupersave:SetInheritAlpha(true)
    regrouperdisband:SetInheritAlpha(true)
    regrouperregroup:SetInheritAlpha(true)

    --FadeOut
    local chatContainer = CHAT_SYSTEM.primaryContainer
    if chatContainer ~= nil then
        ZO_PreHook(chatContainer, "FadeOut", function(ctrl)
            if addon.preventerVars.mouseEntered then return false end
            local minAlpha = chatContainer.minAlpha or 0.1
            if minAlpha == 0 then minAlpha = 0.10 end
            if not addon.preventerVars.fadingOut and settings.fadeOutOnChatFadeOut and not regrouper:IsHidden() and regrouper:GetAlpha() > minAlpha  then
                addon.preventerVars.fadingOut = true
                addon.preventerVars.fadingIn = false
                zo_callLater(function()
                addon.preventerVars.fadingOut = false
                if addon.preventerVars.mouseEntered then return false end
                regrouper:SetAlpha(minAlpha)
                end, 3050)
            end
        end) -- ZO_PreHook(FadeOut)
        --FadeIn
        ZO_PreHook(chatContainer, "FadeIn", function(ctrl)
            if addon.preventerVars.mouseEntered then return false end
            local maxAlpha = chatContainer.maxAlpha or 1
            if maxAlpha == 0 then maxAlpha = 0.10 end
            if not addon.preventerVars.fadingIn and settings.fadeOutOnChatFadeOut and not regrouper:IsHidden() and regrouper:GetAlpha() < maxAlpha then
                addon.preventerVars.fadingIn = true
                addon.preventerVars.fadingOut = false
                zo_callLater(function()
                    addon.preventerVars.fadingIn = false
                    if addon.preventerVars.mouseEntered then return false end
                    regrouper:SetAlpha(maxAlpha)
                end, 50)
            end
        end) -- ZO_PreHook(FadeIn)
    end -- if CHAT_SYSTEM.primaryContainer ~= nil

    --Do the fadeout check now with an override if the setting for the fadeout is enabled
    if settings.fadeOutOnChatFadeOut then
        FadeOutCheck(true)
    end
end

--Addon initialization
local function AddonInitialize()
	local defaultSettings = {
    	OffsetX 			= 0,
        OffsetY 			= 0,
    	OffsetXMinimized	= 0,
        OffsetYMinimized	= 0,
        lastGroupMembers  	= {},
        layout			 	= 1,
        layoutMinimized		= 1,
        movable 			= true,
        repositionOnChatMinimize = true,
        fadeOutOnChatFadeOut = false,
    }
	settings = ZO_SavedVars:New("RegrouperSettings", addon.version, nil, defaultSettings)

	--Reposition Regrouper
    zo_callLater(function() RepositionRegrouper() end, 250)

	--Make Regrouper movable, if enabled
    move(settings.movable)

	--register needed events
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_GROUP_MEMBER_JOINED, OnGroupMemberJoined)
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_GROUP_MEMBER_LEFT, OnGroupMemberLeft)
end

--The event handlers for the buttons etc.
local function EventHandlers()
	-- save button
	regroupersave:SetNormalTexture("esoui/art/buttons/edit_save_up.dds")
	regroupersave:SetMouseOverTexture("esoui/art/buttons/edit_save_over.dds")
	regroupersave:SetPressedMouseOverTexture("esoui/art/buttons/edit_save_down.dds")
	regroupersave:SetDisabledTexture("esoui/art/buttons/edit_save_disabled.dds")
	regroupersave:SetHandler("OnMouseEnter", function(self)
        addon.preventerVars.mouseEntered = true
        FadeInCheck()
		ZO_Tooltips_ShowTextTooltip(regroupersave, LEFT, "Save Group")
	end)
	regroupersave:SetHandler("OnMouseExit", function(self)
        addon.preventerVars.mouseEntered = false
        FadeOutCheck()
		ZO_Tooltips_HideTextTooltip()
	end)
    updateButton(regroupersave)

	-- disband button
	regrouperdisband:SetNormalTexture("esoui/art/buttons/pointsminus_up.dds")
	regrouperdisband:SetMouseOverTexture("esoui/art/buttons/pointsminus_over.dds")
	regrouperdisband:SetPressedMouseOverTexture("esoui/art/buttons/pointsminus_down.dds")
	regrouperdisband:SetDisabledTexture("esoui/art/buttons/pointsminus_disabled.dds")
	regrouperdisband:SetHandler("OnMouseEnter", function(self)
        addon.preventerVars.mouseEntered = true
        FadeInCheck()
		ZO_Tooltips_ShowTextTooltip(regrouperdisband, LEFT, "Disband Group")
	end)
	regrouperdisband:SetHandler("OnMouseExit", function(self)
        addon.preventerVars.mouseEntered = false
        FadeOutCheck()
		ZO_Tooltips_HideTextTooltip()
	end)
    updateButton(regrouperdisband)

	-- regroup button
	regrouperregroup:SetNormalTexture("esoui/art/buttons/pointsplus_up.dds")
	regrouperregroup:SetMouseOverTexture("esoui/art/buttons/pointsplus_over.dds")
	regrouperregroup:SetPressedMouseOverTexture("esoui/art/buttons/pointsplus_down.dds")
	regrouperregroup:SetDisabledTexture("esoui/art/buttons/pointsplus_disabled.dds")
	regrouperregroup:SetHandler("OnMouseEnter", function(self)
        addon.preventerVars.mouseEntered = true
        FadeInCheck()
		--Build the tooltip text for last group members
        listGroup(true)
		ZO_Tooltips_ShowTextTooltip(regrouperregroup, LEFT, tooltip.groupText)
	end)
	regrouperregroup:SetHandler("OnMouseExit", function(self)
        addon.preventerVars.mouseEntered = false
        FadeOutCheck()
		ZO_Tooltips_HideTextTooltip()
	end)
    updateButton(regrouperregroup)

	-- Backdrop
	regrouper:SetHandler("OnMouseEnter", function(self)
        addon.preventerVars.mouseEntered = true
        FadeInCheck()
		if settings.movable then regrouperBG:SetAlpha("1") end
	end)
	regrouper:SetHandler("OnMouseExit", function(self)
        addon.preventerVars.mouseEntered = false
       	regrouperBG:SetAlpha("0.0")
        FadeOutCheck()
	end)
end

--Callback function for event EVENT_ADD_ON_LOADED
local function OnAddOnLoaded(event, addonName)
	if addonName ~= addon.name then return end

	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	--Initialize the settings etc.
	AddonInitialize()

    --Set the event handlers for the buttons and backdrop
    EventHandlers()

    --Register callback function for player activated event
    EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

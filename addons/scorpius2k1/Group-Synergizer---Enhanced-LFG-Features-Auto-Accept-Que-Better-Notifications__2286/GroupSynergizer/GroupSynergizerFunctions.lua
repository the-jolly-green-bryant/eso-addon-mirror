function GROUP_SYNERGIZER.leaveGroup()

	if IsPlayerInGroup(GROUP_SYNERGIZER.playerName) then
		GroupLeave()
		d("You have left the group.")
		zo_callLater(function() CHAT_SYSTEM:Minimize() end, 3000)
		--GROUP_SYNERGIZER.print("Left Group")
	else
		--GROUP_SYNERGIZER.print("Not In Group")
	end
end

function GROUP_SYNERGIZER.print(message, ...)
	df("|cb7ff00[%s]|r |cffffff%s|r", GROUP_SYNERGIZER.name, message:format(...))
end

function GROUP_SYNERGIZER.printCenter(message)
	local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
	messageParams:SetText(message)
	messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

function GROUP_SYNERGIZER.printLFGDebug(statusCode)
	if statusCode == ACTIVITY_FINDER_STATUS_NONE then df("s: %s (ACTIVITY_FINDER_STATUS_NONE)", statusCode)
	elseif statusCode == ACTIVITY_FINDER_STATUS_QUEUED then df("s: %s (ACTIVITY_FINDER_STATUS_QUEUED)", statusCode)
	elseif statusCode == ACTIVITY_FINDER_STATUS_IN_PROGRESS then df("s: %s (ACTIVITY_FINDER_STATUS_IN_PROGRESS)", statusCode)
	elseif statusCode == ACTIVITY_FINDER_STATUS_FORMING_GROUP then df("s: %s (ACTIVITY_FINDER_STATUS_FORMING_GROUP)", statusCode)
	elseif statusCode == ACTIVITY_FINDER_STATUS_COMPLETE then df("s: %s (ACTIVITY_FINDER_STATUS_COMPLETE)", statusCode)
	elseif statusCode == ACTIVITY_FINDER_STATUS_READY_CHECK then df("s: %s (ACTIVITY_FINDER_STATUS_READY_CHECK)", statusCode)
	else df("s: %s (OTHER)", statusCode)
	end
end

function GROUP_SYNERGIZER.AutoAcceptCheckbox(visible)
	if visible then
		if not GROUP_SYNERGIZER.EnhanceGAF then return end

		local left
		local lang = GROUP_SYNERGIZER.Localization.language

		--[[
		if 		lang == "en" then left = 412
		elseif 	lang == "fr" then left = 440
		elseif 	lang == "de" then left = 440
		elseif 	lang == "ru" then left = 470
		else 	left = 412
		end
		]]

		if 		lang == "en" then left = -42
		elseif 	lang == "fr" then left = -18
		elseif 	lang == "de" then left = -24
		elseif 	lang == "ru" then left = 6
		else 	left = -42
		end		

		local cb=GROUP_SYNERGIZER.CheckBoxSettings(
			"GROUP_SYNERGIZER_AutoAccept",
			ZO_SearchingForGroupStatus,
			{256,28}, -- label dims
			--{BOTTOMLEFT,TOPLEFT,left+16,GROUP_SYNERGIZER.checkAuto.top-8},
			--{BOTTOMLEFT,TOPLEFT,-30,88},
			{BOTTOMLEFT,TOPLEFT,left,-8},
			BSTATE_NORMAL,
			GROUP_SYNERGIZER.Localization.Loc("AutoAccept"),
			"ZoFontHeader2",
			{0,0},
			{0.773,0.761,0.62,1},
			nil,
			{0.937,0.922,0.745,1},
			false,
			GROUP_SYNERGIZER.AutoAccept,
			0
		)

		if GROUP_SYNERGIZER.perfectPixelCompat then
			if GROUP_SYNERGIZER.checkAuto.top == 0 then GROUP_SYNERGIZER.checkAuto.top = -64 end
			cb:ClearAnchors()
			--cb:SetAnchor(BOTTOM,ZO_SearchingForGroup,BOTTOM,-104,-152)
			cb:SetAnchor(BOTTOM,ZO_SearchingForGroup,BOTTOM,-104,GROUP_SYNERGIZER.checkAuto.top)
		end

	else
		if GROUP_SYNERGIZER_AutoAccept ~= nil then GROUP_SYNERGIZER_AutoAccept:SetHidden(true) end
	end
end

function GROUP_SYNERGIZER.CallLater(name,ms,func,opt1,opt2)
	if ms then
		GROUP_SYNERGIZER.eventManager:RegisterForUpdate("CallLater_"..name, ms,
		function()
			GROUP_SYNERGIZER.eventManager:UnregisterForUpdate("CallLater_"..name) func(opt1,opt2) end)
	else
		GROUP_SYNERGIZER.eventManager:UnregisterForUpdate("CallLater_"..name)
	end
end

function GROUP_SYNERGIZER.Chain(object)
	--Setup the metatable
	local T={}
	setmetatable(T, {__index=function(self, func)
		--Know when to stop chaining
		if func=="__END" then return object end
		--Otherwise, add the method to the parent object
		return function(self, ...)
			assert(object[func], func .. " missing in object")
			object[func](object, ...)
			return self
		end
	end})
	--Return the metatable
	return T
end

function GROUP_SYNERGIZER.CheckBoxSettings(name, parent, dims, anchor, state, text, font, align, normal, pressed, mouseover, hidden, checked, settings)
	local cb=GROUP_SYNERGIZER.Button(name, parent, {16,16}, {anchor[1],anchor[2],anchor[3],anchor[4]}, state, nil, nil, align, nil, nil, nil, nil)
	local lb=GROUP_SYNERGIZER.Button(name.."_lb", cb, dims, {0,0,20,-4}, state, text, font, align, normal, pressed, mouseover, hidden)
	cb:SetNormalTexture(checked and "esoui/art/buttons/checkbox_checked.dds" or "esoui/art/buttons/checkbox_unchecked.dds")

	local function ControlUpdate(control, settings)
		checked = not checked
		control:SetNormalTexture(checked and "esoui/art/buttons/checkbox_checked.dds" or "esoui/art/buttons/checkbox_unchecked.dds")
		if settings ~= nil then
			if settings == 0 then
				GROUP_SYNERGIZER.AutoAccept = not GROUP_SYNERGIZER.AutoAccept
				GROUP_SYNERGIZER.savedVariables.AutoAccept = GROUP_SYNERGIZER.AutoAccept
			end
		end
	end

	cb:SetHandler("OnMouseEnter", function(self)
		lb:SetNormalFontColor(unpack(mouseover))
	end)
	cb:SetHandler("OnMouseExit", function(self)
		lb:SetNormalFontColor(unpack(normal))
	end)
	cb:SetHandler("OnClicked", function(self)
		ControlUpdate(self, settings)
	end)
	lb:SetHandler("OnClicked", function(self)
		ControlUpdate(cb, settings)
	end)

	return cb,lb
end

function GROUP_SYNERGIZER.Label(name, parent, dims, anchor, font, color, align, text, hidden)
	--Validate arguments
	--	if (name==nil or name=="") then return end
	parent=(parent==nil) and GuiRoot or parent
	if (#anchor~=4 and #anchor~=5) then return end
	font	=(font==nil) and "ZoFontGame" or font
	color	=(color~=nil and #color==4) and color or {1,1,1,1}
	align	=(align~=nil and #align==2) and align or {0,0}
	hidden=(hidden==nil) and false or hidden

	--Create the label
	local label=_G[name] or WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)

	if dims then label:SetDimensions(dims[1], dims[2]) end
	label:ClearAnchors()
	label:SetAnchor(anchor[1], #anchor==5 and anchor[5] or parent, anchor[2], anchor[3], anchor[4])
	label:SetFont(font)
	label:SetColor(unpack(color))
	label:SetHorizontalAlignment(align[1])
	label:SetVerticalAlignment(align[2])
	label:SetText(text)
	label:SetHidden(hidden)

	local fragment = ZO_FadeSceneFragment:New(label)
	KEYBOARD_GROUP_MENU_SCENE:AddFragment(fragment)
	GAMEPAD_ACTIVITY_FINDER_ROOT_SCENE:AddFragment(fragment)	

	return label
end

function GROUP_SYNERGIZER.Button(name, parent, dims, anchor, state, text, font, align, normal, pressed, mouseover, hidden)
	--Validate arguments
	if (name==nil or name=="") then return end
	parent=(parent==nil) and GuiRoot or parent
	if (dims=="inherit" or #dims~=2) then dims={parent:GetWidth(), parent:GetHeight()} end
	if (#anchor~=4 and #anchor~=5) then return end
	state=(state~=nil) and state or BSTATE_NORMAL
	font=(font==nil) and "ZoFontGame" or font
	align=(align~=nil and #align==2) and align or {1, 1}
	normal=(normal~=nil and #normal==4) and normal or {1, 1, 1, 1}
	pressed=(pressed~=nil and #pressed==4) and pressed or {1, 1, 1, 1}
	mouseover=(mouseover~=nil and #mouseover==4) and mouseover or {1, 1, 1, 1}
	hidden=(hidden==nil) and false or hidden

	--Create the button
	local button=_G[name]
	if (button==nil) then button=WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON) end

	--Apply properties
	local button=GROUP_SYNERGIZER.Chain(button)
		:SetDimensions(dims[1], dims[2])
		:ClearAnchors()
		:SetAnchor(anchor[1], #anchor==5 and anchor[5] or parent, anchor[2], anchor[3], anchor[4])
		:SetState(state)
		:SetFont(font)
		:SetNormalFontColor(normal[1], normal[2], normal[3], normal[4])
		:SetPressedFontColor(pressed[1], pressed[2], pressed[3], pressed[4])
		:SetMouseOverFontColor(mouseover[1], mouseover[2], mouseover[3], mouseover[4])
		:SetHorizontalAlignment(align[1])
		:SetVerticalAlignment(align[2])
		:SetHidden(hidden)
		:SetText(text)
	.__END
	return button
end

function GROUP_SYNERGIZER.groupFinderVisible(oldState, newState)
	GROUP_SYNERGIZER.AutoAcceptCheckbox(newState == SCENE_FRAGMENT_SHOWN)
	if GROUP_SYNERGIZER.BUICompat then BUI_AutoQueue:SetHidden(GROUP_SYNERGIZER.BUICompat) end
	--d(newState == SCENE_FRAGMENT_SHOWN)
end

local function PerfectPixelCheck()
	local am = GetAddOnManager()
	for i = 1, am:GetNumAddOns() do
		local name, _, _, _, enabled, loadable, _, _ = am:GetAddOnInfo(i)
		name:gsub("|[cC]%x%x%x%x%x%x", ""):gsub("|[rR]", "") -- Decolorize
		if name == "PerfectPixel" and enabled == true and loadable == 2 then return true end
	end

	return false
end

local function BUICheck()
	local am = GetAddOnManager()
	for i = 1, am:GetNumAddOns() do
		local name, _, _, _, enabled, loadable, _, _ = am:GetAddOnInfo(i)
		name:gsub("|[cC]%x%x%x%x%x%x", ""):gsub("|[rR]", "") -- Decolorize
		if name == "BanditsUserInterface" and enabled == true and loadable == 2 then return true end
	end

	return false
end

GROUP_SYNERGIZER.perfectPixelCompat	= PerfectPixelCheck()
GROUP_SYNERGIZER.BUICompat = BUICheck()


--[[
function GROUP_SYNERGIZER.isPlayerLeader(playeraccname)
	--if not IsUnitGrouped('player') then return true end -- IsUnitSoloOrGroupLeader
	if not IsPlayerInGroup(playeraccname) then return true end

	local groupSize = GetGroupSize()
	for i = 1, groupSize do
		local unitTag = GetGroupUnitTagByIndex(i)
		if string.sub(unitTag, 0, 5)=="group" then
			local accname = GetUnitDisplayName(unitTag)
			if IsUnitGroupLeader(unitTag) and accname == playeraccname then return true end
		end
	end

	return false
end
]]

--[[
local tlw, texture
tlw = WINDOW_MANAGER:CreateTopLevelWindow()
tlw:SetDimensions(100,100)
tlw:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
tlw:SetHidden(true)
texture = WINDOW_MANAGER:CreateControl(nil, tlw, CT_TEXTURE)
texture:SetTexture("/esoui/art/icons/poi/poi_groupboss_complete.dds")
texture:SetAnchorFill(tlw)
 
--create a scene fragment (1000ms show duration, 500ms hide duration)
local fragment = ZO_HUDFadeSceneFragment:New(tlw, 1000, 500)
 
--add my fragment to scenes:
HUD_SCENE:AddFragment(fragment)
HUD_UI_SCENE:AddFragment(fragment)



function GROUP_SYNERGIZER.SetLocationSelected(self, location, selected)
	if selected then
		local groupType = {
			dungeon = {
				[2] = true, -- normal
				[3] = true, -- vet
			},
			battleground = {
				[7] = true,
				[8] = true,
			}
		}
		
		GROUP_SYNERGIZER.OnCooldownsUpdate(EVENT_ACTIVITY_FINDER_COOLDOWNS_UPDATE)

		if groupType.dungeon[location:GetActivityType()] then
			GROUP_SYNERGIZER.AutoAcceptCheckbox(not GROUP_SYNERGIZER.coolDownStatus[LFG_COOLDOWN_ACTIVITY_STARTED])
		elseif groupType.battleground[location:GetActivityType()] then
			GROUP_SYNERGIZER.AutoAcceptCheckbox(not GROUP_SYNERGIZER.coolDownStatus[LFG_COOLDOWN_BATTLEGROUND_DESERTED])					
		end

		return
	end

	GROUP_SYNERGIZER.AutoAcceptCheckbox(false)
end



]]
-- Load libraries (fized by razielsoulshadow)
local LAM = LibAddonMenu2
local LMP = LibMediaProvider

SwitchBar.name = "SwitchBar II"
SwitchBar.version = "1.3.3"
SwitchBar.revision = .3
SwitchBar.author = "Elsys,dOpiate,manavortex,razielsoulshadow"

local last_inCombat = false
local switch_fragment = ZO_HUDFadeSceneFragment:New(SwitchBarMain)

function SwitchBar.SetIcon(identifier, texture)
	local icon =  SwitchBar.GetControl(identifier)
	icon:SetTexture(texture)
end

function SwitchBar.GetControl(identifier)

	if identifier == nil then 
		identifier = SwitchBar.SavedVars.activeBar
	end
	
	if identifier == "1" then
		return SwitchBar_Icon1
	elseif identifier == "2" then
		return SwitchBar_Icon2
	end
	
end

function SwitchBar.GetColours(identifier)
	
	if identifier == nil then 
		identifier = SwitchBar.SavedVars.activeBar
	end
	
	if identifier == "1" then
		return SwitchBar.SavedVars.colours["1"]
	elseif identifier == "2" then
		return SwitchBar.SavedVars.colours["2"]
	end
	
end

function SwitchBar.GetBgColor(identifier)
	
	local colours = SwitchBar.GetColours(identifier)
	
	return colours.r, colours.g, colours.b, colours.a
end

function SwitchBar.SetBgColor(r,g,b,a, identifier)
	
	local colours = SwitchBar.GetColours(identifier)
	local control = SwitchBar.GetControl(identifier)
	
	colours.r = r
	colours.g = g
	colours.b = b
	colours.a = a
	--[[propogate changes to saved vars so on next load it pulls the right values.
	there is no need for if else test here because identifier will never be nil.]]
	SwitchBar.SavedVars.colours[tostring(identifier)] = { ["r"]=r, ["g"]=g, ["b"]=b, ["a"]=a }
	control:SetColor(r,g,b,a)

end

--[[
	Update functions
]]

-- configured to call from xml
function SwitchBar.UpdatePosition()
	-- save current postion after we stop moving the widget
	SwitchBar.SavedVars.offsetX = SwitchBarMain:GetLeft()
	SwitchBar.SavedVars.offsetY = SwitchBarMain:GetTop()
end

function SwitchBar.SetAlpha(alpha)
	SwitchBar.SavedVars.bgAlpha = alpha
	local alphaUpdate = alpha/100

	SwitchBarMain:SetAlpha(alphaUpdate)
	SwitchBar_Icon1:SetAlpha(alphaUpdate)
	SwitchBar_Icon2:SetAlpha(alphaUpdate)
end

function SwitchBar.SetBGHidden(bool)
	SwitchBar.SavedVars.hideBackground = bool
	SwitchBarBG:SetHidden(bool)
end

function SwitchBar.SetSize(size)
	SwitchBar.SavedVars.size = size
	SwitchBar_Icon1:SetDimensions(size, size)
	SwitchBar_Icon2:SetDimensions(size, size)
	local backgroundX = math.max(SwitchBar_Icon1:GetWidth(), SwitchBar_Icon2:GetWidth())
	local backgroundY = math.max(SwitchBar_Icon1:GetHeight(), SwitchBar_Icon2:GetHeight())
	SwitchBarMain:SetDimensions(backgroundX, backgroundY)
end

function SwitchBar.UpdateShowAlways(value)
--If we want to register for the combat event or not if always shown
SwitchBar.SavedVars.showAlwaysOption = value
	if value == true then
		EVENT_MANAGER:UnregisterForEvent("SwitchBar", EVENT_PLAYER_COMBAT_STATE)
		HUD_SCENE:AddFragment(switch_fragment)
	else
		EVENT_MANAGER:RegisterForEvent("SwitchBar", EVENT_PLAYER_COMBAT_STATE, SwitchBar.OnPlayerCombatState)
		if last_inCombat then
			HUD_SCENE:AddFragment(switch_fragment)
		else
			HUD_SCENE:RemoveFragment(switch_fragment)
		end
	end
end

function SwitchBar.UpdateMouseLock(value)
	 SwitchBarMain:SetMovable(value)
	 SwitchBarMain:SetMouseEnabled(value)
end

--[[
	Initilization helpers, workaround for bug involving saved variables not being immediately updated for some reason
]]

function SwitchBar.UpdateDimensions()
	local size = SwitchBar.SavedVars.size

	SwitchBar_Icon1:SetDimensions(size, size)
	SwitchBar_Icon2:SetDimensions(size, size)
	
	local backgroundX = math.max(SwitchBar_Icon1:GetWidth(), SwitchBar_Icon2:GetWidth())
	local backgroundY = math.max(SwitchBar_Icon1:GetHeight(), SwitchBar_Icon2:GetHeight())
	
	SwitchBarMain:SetDimensions(backgroundX, backgroundY)
end

function SwitchBar.UpdateVisibility()
	local backgroundAlpha = SwitchBar.SavedVars.bgAlpha
	local hideBackground = SwitchBar.SavedVars.hideBackground
	
	SwitchBarBG:SetHidden(hideBackground)
	SwitchBarMain:SetAlpha(backgroundAlpha/100)
	SwitchBar_Icon1:SetAlpha(backgroundAlpha/100)
	SwitchBar_Icon2:SetAlpha(backgroundAlpha/100)
	
	SwitchBarMain:SetHidden(not SwitchBar.SavedVars.showAlwaysOption)
	SwitchBar.GetControl(nil):SetHidden(not SwitchBar.SavedVars.showAlwaysOption)
end

function SwitchBar.SetUpIcon(identifier)
	
	icon = SwitchBar.GetControl(identifier)
	
	icon:SetAnchor(CENTER, SwitchBarMain, CENTER, 0, 0)	
	SwitchBar.SetIcon(identifier, SwitchBar.SavedVars.icons[identifier])
	local colours = SwitchBar.GetColours(identifier)
	icon:SetColor(colours.r,colours.g,colours.b,colours.a)
end
SwitchBar.GetAPIVersion = function() return 2 end

function SwitchBar.InstallOptionalIcons()
	for index,value in ipairs(SwitchBar.iconPak) do
	 	table.insert(SwitchBar.iconTextures, value)
	 	if SwitchBar.iconTip[index] ~= nil then
	 	table.insert(SwitchBar.iconTooltips, SwitchBar.iconTip[index])
	 	else
	 	table.insert(SwitchBar.iconTooltips, tostring(#SwitchBar.iconTextures))
	 	end
	end
	SwitchBar.iconPak = nil
	SwitchBar.iconTip = nil
end

--[[
	Toggles
]]


-- function fixed by dOpiate

function SwitchBar.Swap(eventCode, identifier, notDoneYet)

	if identifier == 1  then
		SwitchBar.SavedVars.activeBar = tostring(identifier)
		SwitchBar_Icon1:SetHidden(tostring(identifier) == "2")
		SwitchBar_Icon2:SetHidden(tostring(identifier) == "1")
	else
		SwitchBar_Icon1:SetHidden(tostring(identifier) == "2")
		SwitchBar_Icon2:SetHidden(tostring(identifier) == "1")	
	end
end

-- For KeyBind
function SwitchBar.ToggleHidden()
	SwitchBar.UpdateShowAlways(not SwitchBar.SavedVars.showAlwaysOption)
end

function SwitchBar.OnPlayerCombatState(EVENT_PLAYER_COMBAT_STATE, inCombat)
	last_inCombat = inCombat
	if inCombat then
		HUD_SCENE:AddFragment(switch_fragment)
	else
		HUD_SCENE:RemoveFragment(switch_fragment)
	end
end


function SwitchBar.RegisterForEvents()
	
	EVENT_MANAGER:RegisterForEvent("SwitchBarLoaded", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, SwitchBar.Swap)
	if SwitchBar.SavedVars.showAlwaysOption == false then
		--before I was checking on enter combat for this option but why even register the event if the option is off less work for the addon to do
		EVENT_MANAGER:RegisterForEvent("SwitchBar", EVENT_PLAYER_COMBAT_STATE, SwitchBar.OnPlayerCombatState)
	else
		HUD_SCENE:AddFragment(switch_fragment)
	end
end

function SwitchBar.Init(eventCode, addOnName)
	
	if addOnName ~= "SwitchBar" then return end

	-- we've been called to setup, get us out of the event list now
	EVENT_MANAGER:UnregisterForEvent("SwitchBar", EVENT_ADD_ON_LOADED)

	--[[Removed check for current saved variables unneccessary under current eso api addon actually errors once before working with this statement so its gone.
	Changed saved vars line to from static version now on updates we don't need to worry about removing saved variables and or conflicts must be higher than
	last saved variable version to avoid out of date!]]
	SwitchBar.SavedVars = ZO_SavedVars:New("SwitchBarSavedVars", SwitchBar.revision, nil, SwitchBar.defaults) 
	
	-- Main Box is in the window xml
	SwitchBarMain:ClearAnchors()

	-- Set position if it's been saved, otherwise default to 200, 200
	if SwitchBar.SavedVars.offsetX or SwitchBar.SavedVars.offsetY then
		SwitchBarMain:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SwitchBar.SavedVars.offsetX, SwitchBar.SavedVars.offsetY)
	else
		SwitchBarMain:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SwitchBar.defaults.offsetX, SwitchBar.defaults.offsetY)
	end

	SwitchBarMain:SetMovable(SwitchBar.SavedVars.positionLockOption)
	SwitchBarMain:SetMouseEnabled(SwitchBar.SavedVars.positionLockOption)
	
	--[[ 
	Create and initialise icons. To avoid redundancy, see helper function.
	]]
	
	SwitchBar.SetUpIcon("1")
	SwitchBar.SetUpIcon("2")
	
	-- now make sure everything has the right size and transparency
	SwitchBar.UpdateDimensions()
	SwitchBar.UpdateVisibility()
	if SwitchBar.installOptionalIcons then
		SwitchBar.InstallOptionalIcons()
	end
	SwitchBar.CreateSettings(SwitchBar.SavedVars, SwitchBar.defaults, SwitchBar.iconTextures) 
		
	-- make sure that we're properly setup on first run
	SwitchBar.Swap(nil, SwitchBar.SavedVars.activeBar)

	-- when scene changes, see if we should be showing the widget
	SwitchBar.RegisterForEvents()

	--Register to the scenes for proper hide/show handling context
	HUD_UI_SCENE:AddFragment(switch_fragment)
	GAME_MENU_SCENE:AddFragment(switch_fragment)
end

EVENT_MANAGER:RegisterForEvent("SwitchBarLoaded", EVENT_ADD_ON_LOADED, SwitchBar.Init)

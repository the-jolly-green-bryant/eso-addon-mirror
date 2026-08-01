GroupUIMover = {}

GroupUIMover.name = "GroupUIMover"
GroupUIMover.VisualName = "Group UI Mover"
GroupUIMover.version = 1
GroupUIMover.defaultCharacter = 
{	
	["small"] = {
		["offsetX"] = 70,
		["offsetY"] = 55,	
	},
	["large"] = {
		["offsetX"] = 100,
		["offsetY"] = 50,
	},
	["scale"] = 1,
	["useCharacterSettings"] = false,
}
GroupUIMover.default = {
	["accountWideProfile"] = GroupUIMover.defaultCharacter,
}
GroupUIMover.defaultSettings =
{
	["scaleMin"] = 0.5,
	["scaleMax"] = 1.5,
	["xMin"] = 0,
	["yMin"] = 0,
}
local xMax, yMax
function GroupUIMover.GetSettings()--
	if GroupUIMover.charSavedVars.useCharacterSettings then
		return GroupUIMover.charSavedVars
	else
		return GroupUIMover.savedvars.accountWideProfile
	end
end
function GroupUIMover.enableInheritScaleRecursive(control)
    if not control then return end
    if not control:GetInheritsScale() then control:SetInheritScale(true) end
    local numChildren = control:GetNumChildren()
    for i = 1, numChildren do
        local child = control:GetChild(i)
        if child then
            GroupUIMover.enableInheritScaleRecursive(child)
        end
    end
end
---Applies scale transform to Quest Tracker (ty DakJaniels)
function GroupUIMover.applyScale(controlToScale, scale)
    if not controlToScale then return end
    local appliedScale = scale or 1
    GroupUIMover.enableInheritScaleRecursive(controlToScale);
    controlToScale:SetTransformScale(appliedScale);
end

function GroupUIMover.ApplySmallAnchor()
	ZO_SmallGroupAnchorFrame:ClearAnchors()	
	ZO_SmallGroupAnchorFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GroupUIMover.GetSettings().small.offsetX, GroupUIMover.GetSettings().small.offsetY)	

end	
function GroupUIMover.ApplyLargeAnchor()
	ZO_LargeGroupAnchorFrame1:ClearAnchors()	
	ZO_LargeGroupAnchorFrame1:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GroupUIMover.GetSettings().large.offsetX, GroupUIMover.GetSettings().large.offsetY)	
	for i=2,3 do
		local control = GetControl("ZO_LargeGroupAnchorFrame"..i)
		control:ClearAnchors()	
		control:SetAnchor(TOPLEFT, GetControl("ZO_LargeGroupAnchorFrame"..(i-1)), TOPLEFT,211,0 )	-- Y distance (48*6)	
	end
end	
function GroupUIMover.ApplyScale()
	GroupUIMover.applyScale(ZO_UnitFramesGroups,GroupUIMover.GetSettings().scale)
	GroupUIMover.applyScale(ZO_CompanionUnitFramecompanion,GroupUIMover.GetSettings().scale)
end

function GroupUIMover.ApplyAnchors()
	GroupUIMover.ApplySmallAnchor()
	GroupUIMover.ApplyLargeAnchor()
	GroupUIMover.ApplyScale()
end

function GroupUIMover.CreateSettingsMenu()
    local LHAS = LibHarvensAddonSettings	
	if LHAS == nil then return end
    local options = {
        allowDefaults = true,
		allowRefresh = false,
		defaultsFunction = function()      
		d("GroupUIMover Reset")
        end,
    }
    
    local settings = LHAS:AddAddon(GroupUIMover.VisualName, options)
    if not settings then
        return
    end
	--On/Off for Character Settings
    local checkbox = {
        type = LHAS.ST_CHECKBOX,
        label = "Use character settings", 
		--default = false, 
        setFunction = function(value)
           GroupUIMover.charSavedVars.useCharacterSettings = value
        end,
        getFunction = function()
            return GroupUIMover.charSavedVars.useCharacterSettings
        end,
    }
    settings:AddSetting(checkbox)
	--Add / Remove functions for the Button below
	local GroupUIInMenu = false
	local scene
	--adds it
	local function addGroupUI()
		if GroupUIInMenu then return end
		scene = SCENE_MANAGER:GetCurrentScene()					
		scene:AddFragment(UNIT_FRAMES_FRAGMENT)
		UNIT_FRAMES_FRAGMENT:Refresh()	
		GroupUIInMenu = true	
	end
	--removes it
	local function addonSelected(_, addonSettings)
		if GroupUIInMenu then	
			scene:RemoveFragment(UNIT_FRAMES_FRAGMENT)
			UNIT_FRAMES_FRAGMENT:Refresh()
			GroupUIInMenu = false
		end
	end
		
	CALLBACK_MANAGER:RegisterCallback("LibHarvensAddonSettings_AddonSelected", addonSelected)
	--Button to show the  Group UI in the menu for easy movement
	local button = {
        type = LHAS.ST_BUTTON,
        label = "Show Group UI",	
		tooltip = "Shows your current group on this page",		
        buttonText = "Show",
        clickHandler = function(control, button)
			if not GroupUIInMenu then
				addGroupUI()
			else
				addonSelected()
			end
        end,
    }
	settings:AddSetting(button)
	local section = {
        type = LHAS.ST_SECTION,
        label = "Small Group Settings",
    }
    settings:AddSetting(section)
	--Slider to Adjust Small Group UI's Y Position
    local slider = {
        type = LHAS.ST_SLIDER,
        label = "Up <- -> Down",
		tooltip = "Default: "..GroupUIMover.defaultCharacter.small.offsetY,
        setFunction = function(value)
            GroupUIMover.GetSettings().small.offsetY = value
			GroupUIMover.ApplySmallAnchor()
        end,
        getFunction = function()
            return GroupUIMover.GetSettings().small.offsetY
        end,
        default = GroupUIMover.defaultCharacter.small.offsetY,
        min = GroupUIMover.defaultSettings.yMin,
        max = yMax,
        step = 5
    }
    settings:AddSetting(slider)
	--Slider to Adjust Small Group UI's X Position
	 local slider = {
        type = LHAS.ST_SLIDER,
        label = "Left <- -> Right",
		tooltip = "Default: "..GroupUIMover.defaultCharacter.small.offsetX,
        setFunction = function(value)
            GroupUIMover.GetSettings().small.offsetX = value
			GroupUIMover.ApplySmallAnchor()
        end,
        getFunction = function()
            return GroupUIMover.GetSettings().small.offsetX
        end,
        default = GroupUIMover.defaultCharacter.small.offsetX,
        min = GroupUIMover.defaultSettings.xMin,
        max = xMax,
        step = 5
    }
    settings:AddSetting(slider)
	local section = {
        type = LHAS.ST_SECTION,
        label = "Large Group Settings",
    }
    settings:AddSetting(section)
	--Slider to Adjust Large Group UI's Y Position
    local slider = {
        type = LHAS.ST_SLIDER,
        label = "Up <- -> Down",
		tooltip = "Default: "..GroupUIMover.defaultCharacter.large.offsetY,
        setFunction = function(value)
            GroupUIMover.GetSettings().large.offsetY = value
			GroupUIMover.ApplyLargeAnchor()
        end,
        getFunction = function()
            return GroupUIMover.GetSettings().large.offsetY
        end,
        default = GroupUIMover.defaultCharacter.large.offsetY,
        min = GroupUIMover.defaultSettings.yMin,
        max = yMax,
        step = 5
    }
    settings:AddSetting(slider)
	--Slider to Adjust Large Group UI's X Position
	 local slider = {
        type = LHAS.ST_SLIDER,
        label = "Left <- -> Right",
		tooltip = "Default: "..GroupUIMover.defaultCharacter.large.offsetX,
        setFunction = function(value)
            GroupUIMover.GetSettings().large.offsetX = value
			GroupUIMover.ApplyLargeAnchor()
        end,
        getFunction = function()
            return GroupUIMover.GetSettings().large.offsetX
        end,
        default = GroupUIMover.defaultCharacter.large.offsetX,
        min = GroupUIMover.defaultSettings.xMin,
        max = xMax,
        step = 5
    }
    settings:AddSetting(slider)
	local section = {
        type = LHAS.ST_SECTION,
        label = "Scale & Feedback",
    }
    settings:AddSetting(section)
	--Slider to Adjust Small Scale
    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "SCALE\nSmall <- -> Large",
		tooltip = "Default: "..GroupUIMover.defaultCharacter.scale,
        setFunction = function(value)
            GroupUIMover.GetSettings().scale = value
			GroupUIMover.ApplyScale()
        end,
        getFunction = function()
            return GroupUIMover.GetSettings().scale
        end,
        default = GroupUIMover.defaultCharacter.scale,
        min = GroupUIMover.defaultSettings.scaleMin,
        max = GroupUIMover.defaultSettings.scaleMax,
        step = 0.05
    })
	
	settings:AddSetting({
        type = LHAS.ST_BUTTON,
        label = "Submit Feedback / Request",
		tooltip = "link to a form where you can leave feedback or even leave a request",
		buttonText = "Open URL",
		clickHandler = function(control, button)
			RequestOpenUnsafeURL("https://docs.google.com/forms/d/e/1FAIpQLScYWtcIJmjn0ZUrjsvpB5rwA5AlsLvasHUIcKqzIYcogo9vjQ/viewform?usp=pp_url&entry.550722213="..GroupUIMover.VisualName)
		end,
	})
end
function GroupUIMover.CreateSlashCommands()
	
	SLASH_COMMANDS["/guimhelp"]=function()
		d("How to change Vaules in GroupUIMover")
		d("/guimreport")
		d("Small Group")
		d("/guimsscale (number)")
		d("/guimsx (number)")
		d("/guimsy (number)")	
		d("Large Group")
		d("/guimlscale (number)")
		d("/guimlx (number)")
		d("/guimly (number)")	
	end
	SLASH_COMMANDS["/guimreport"]=function()
		RequestOpenUnsafeURL("https://docs.google.com/forms/d/e/1FAIpQLScYWtcIJmjn0ZUrjsvpB5rwA5AlsLvasHUIcKqzIYcogo9vjQ/viewform?usp=pp_url&entry.550722213="..GroupUIMover.VisualName)
	end
	SLASH_COMMANDS["/guimscale"]=function(n)
		n=tonumber(n)	
		if n and n>=GroupUIMover.defaultSettings.scaleMin and n<=GroupUIMover.defaultSettings.scaleMax then
			d("GroupUIMover: Scale changed from "..GroupUIMover.GetSettings().scale.." to "..n)
			GroupUIMover.GetSettings().scale = n
			GroupUIMover.applyScales()
		else
			d("GroupUIMover: Scale is between "..GroupUIMover.defaultSettings.scaleMin.." and "..GroupUIMover.defaultSettings.scaleMax)
		end
	end
	SLASH_COMMANDS["/guimsx"]=function(n)
		n=tonumber(n)	
		if n and n>=GroupUIMover.defaultSettings.xMin and n<=xMax then
			d("GroupUIMover: Small X changed from "..GroupUIMover.GetSettings().small.offsetX .." to "..n)
			GroupUIMover.GetSettings().small.offsetX = n
			GroupUIMover.ApplyAnchor()
		else
			d("GroupUIMover: X is between "..GroupUIMover.defaultSettings.xMin.." and "..xMax)
		end
	end
	SLASH_COMMANDS["/guimsy"]=function(n)
		n=tonumber(n)	
		if n and n>=GroupUIMover.defaultSettings.yMin and n<=yMax then
			d("GroupUIMover: Small Y changed from "..GroupUIMover.GetSettings().small.offsetY .." to "..n)
			GroupUIMover.GetSettings().small.offsetY = n
			GroupUIMover.ApplyAnchor()
		else
			d("GroupUIMover: Y is between "..GroupUIMover.defaultSettings.yMin.." and "..yMax)
		end
	end
	SLASH_COMMANDS["/guimlx"]=function(n)
		n=tonumber(n)	
		if n and n>=GroupUIMover.defaultSettings.xMin and n<=xMax then
			d("GroupUIMover: Large X changed from "..GroupUIMover.GetSettings().large.offsetX .." to "..n)
			GroupUIMover.GetSettings().large.offsetX = n
			GroupUIMover.ApplyAnchor()
		else
			d("GroupUIMover: X is between "..GroupUIMover.defaultSettings.xMin.." and "..xMax)
		end
	end
	SLASH_COMMANDS["/guimly"]=function(n)
		n=tonumber(n)	
		if n and n>=GroupUIMover.defaultSettings.yMin and n<=yMax then
			d("GroupUIMover: Large Y changed from "..GroupUIMover.GetSettings().large.offsetY .." to "..n)
			GroupUIMover.GetSettings().large.offsetY = n
			GroupUIMover.ApplyAnchor()
		else
			d("GroupUIMover: Y is between "..GroupUIMover.defaultSettings.yMin.." and "..yMax)
		end
	end
end

function GroupUIMover.Initialize()
	--Load up, those Saved Vars
	local serverName = GetWorldName()
	GroupUIMover.savedvars = ZO_SavedVars:NewAccountWide("GroupUIMoverSavedVariables", GroupUIMover.version, serverName, GroupUIMover.default)
	GroupUIMover.charSavedVars = ZO_SavedVars:NewCharacterIdSettings("GroupUIMoverSavedVariables",GroupUIMover.version, serverName, GroupUIMover.savedvars.accountWideProfile) 	
	--Updating it via the callback of where the frames are moved, then just putting them where i want them
	CALLBACK_MANAGER:RegisterCallback("OnUnitFrameAnchorsUpdated", function() GroupUIMover.ApplyAnchors() end)
	xMax, yMax = GuiRoot:GetDimensions()
	xMax = math.floor(xMax)
	yMax = math.floor(yMax)
	GroupUIMover.CreateSettingsMenu()
	GroupUIMover.CreateSlashCommands()
end
function GroupUIMover.OnAddOnLoaded(event, addonName)
	if addonName == GroupUIMover.name then
		GroupUIMover.Initialize()		
		EVENT_MANAGER:UnregisterForEvent(GroupUIMover.name, EVENT_ADD_ON_LOADED)
	end
end
 
EVENT_MANAGER:RegisterForEvent(GroupUIMover.name, EVENT_ADD_ON_LOADED, GroupUIMover.OnAddOnLoaded)
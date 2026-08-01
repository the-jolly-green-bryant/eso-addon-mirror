local LAM2 = LibStub("LibAddonMenu-2.0")
local PT={}
PT.version="1.06"
PT.name = "Poison_Tracker"
PT.Default_Icon='esoui/art/characterwindow/gearslot_poison.dds'
PT.currentStackSize={0,0}
local POISON_TRACKER_SCENE_FRAGMENT

PT.defaults={
	enabled=true,
	unlocked=true,
	bgFrameType=2,
	alphaBG=0.7,
	controlScale=1.0,
	hideEmpty=false,
	playAnimation=true,
	playSound=true,
	offsetX=0,
	offsetY=0,
}

function PT_SavePosition()
	local coordX, coordY=PT_Frame:GetCenter()
	PT.savedVariables.offsetX=coordX-(GuiRoot:GetWidth()/2)
	PT.savedVariables.offsetY=coordY-(GuiRoot:GetHeight()/2)
	PT.UpdateControl()
end

function PT.StartAnimation()
	local control = PT_Frame
	
	control:ClearAnchors()
	control:SetAnchor(CENTER, GuiRoot, CENTER, PT.savedVariables.offsetX, PT.savedVariables.offsetY)
    local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = control:GetAnchor()
 
    local timeline = ANIMATION_MANAGER:CreateTimeline()
 
    local popup = timeline:InsertAnimation(ANIMATION_SCALE, control)
    popup:SetScaleValues(PT.savedVariables.controlScale, PT.savedVariables.controlScale*3)
    popup:SetDuration(120)
    popup:SetEasingFunction(ZO_EaseInQuadratic)    
	
	local popout = timeline:InsertAnimation(ANIMATION_SCALE, control, 200)
    popout:SetScaleValues(PT.savedVariables.controlScale*3, PT.savedVariables.controlScale)
    popout:SetDuration(200)
    popout:SetEasingFunction(ZO_EaseOutQuadratic)

	
	local anim = CreateSimpleAnimation(ANIMATION_TEXTURE, PT_Frame_Star)
	anim:SetImageData(16,1)
	anim:SetFramerate(32)
	
	anim:SetHandler('OnStop', function()
		PT_Frame_Star:SetHidden(true)
    end)
	
    timeline:SetHandler('OnStop', function()
        control:ClearAnchors()
        control:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
    end)
 
	PT_Frame_Star:SetHidden(false)
    timeline:PlayFromStart()
    anim:GetTimeline():PlayFromStart()
end

	
function PT.onProc(slotId)
	local control = PT_Frame_CooldownMain

	control:ResetCooldown()
	control:StartCooldown(10000, 10000, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false)
	control:SetHandler('OnStop', function() self:SetHidden(true) end)
	control:SetHidden(false)
	
	if PT.savedVariables.playAnimation then 
		PT.StartAnimation() 
	end
	
	if PT.savedVariables.playSound then
		PlaySound(SOUNDS.DUEL_START)
		PlaySound(SOUNDS.DUEL_START)
	end
end

function PT.OnSingleSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackSizeChange)
	local isMainPair = slotId == EQUIP_SLOT_POISON
	local isBackPair = slotId == EQUIP_SLOT_BACKUP_POISON
	if itemSoundCategory~=20 or bagId~=0 then return end
	if stackSizeChange==-1 then PT.onProc(slotId) end
	if isMainPair then
		PT.currentStackSize[ACTIVE_WEAPON_PAIR_MAIN] = PT.currentStackSize[ACTIVE_WEAPON_PAIR_MAIN]+stackSizeChange
		PT.UpdateControl(isMainPair, PT.currentStackSize[ACTIVE_WEAPON_PAIR_MAIN])
	elseif isBackPair then
		PT.currentStackSize[ACTIVE_WEAPON_PAIR_BACKUP] = PT.currentStackSize[ACTIVE_WEAPON_PAIR_BACKUP]+stackSizeChange
		PT.UpdateControl(isMainPair, PT.currentStackSize[ACTIVE_WEAPON_PAIR_BACKUP])
	end
	
end

function PT.UpdateControl(isMainPair, stackSize)
	local activeWeaponPair = GetActiveWeaponPairInfo()
	if activeWeaponPair==ACTIVE_WEAPON_PAIR_NONE then return end
	if not stackSize then 
		stackSize=PT.GetStackSize(activeWeaponPair) 
	end
	
	if (isMainPair and activeWeaponPair==ACTIVE_WEAPON_PAIR_MAIN) or (isMainPair==false and activeWeaponPair==ACTIVE_WEAPON_PAIR_BACKUP) or isMainPair==nil then --change control on screen
		if stackSize==0 then
			PT_Frame_Icon:SetTexture(PT.Default_Icon)
			if PT.savedVariables.hideEmpty then 
				PT.unlocked(not PT.savedVariables.unlocked)
				PT_Frame:SetHidden(true) 
			else
				PT.unlocked(PT.savedVariables.unlocked)
				PT_Frame:SetHidden(false)
			end
			PT_Frame_Stacks:SetHidden(true) 
		else
			PT.unlocked(PT.savedVariables.unlocked)
			local newIcon=PT.GetPoisonIcon(activeWeaponPair)
			PT_Frame_Icon:SetTexture(newIcon)
			PT_Frame_Stacks:SetHidden(false)
			PT_Frame:SetHidden(false)
		end
		PT_Frame_Stacks:SetText(stackSize)
	end
end

function PT.GetStackSize(activeWeaponPair)
	local equipSlot, stackSize
	if activeWeaponPair==ACTIVE_WEAPON_PAIR_MAIN then 
		equipSlot = EQUIP_SLOT_MAIN_HAND
	else 
		equipSlot = EQUIP_SLOT_BACKUP_MAIN
	end
	
	_, stackSize = GetItemPairedPoisonInfo(equipSlot) 
	
	return stackSize
end

function PT.GetPoisonIcon(activeWeaponPair)
	if activeWeaponPair==ACTIVE_WEAPON_PAIR_MAIN then return GetEquippedItemInfo(EQUIP_SLOT_POISON)
	else return GetEquippedItemInfo(EQUIP_SLOT_BACKUP_POISON) end
end

function PT.InitControls()
	PT_Frame:ClearAnchors()
	PT_Frame:SetAnchor(CENTER, GuiRoot, CENTER, PT.savedVariables.offsetX, PT.savedVariables.offsetY)
	PT_Frame_IconBG:SetTexture("")
	PT_Frame_IconBG:SetColor(0,0,0,PT.savedVariables.alphaBG)
	PT_Frame_CooldownMain:SetAlpha(0.9)
	PT_Frame_CooldownMain:SetHidden(true)
	PT_Frame_CooldownMain:ResetCooldown()
	PT_Frame:SetScale(PT.savedVariables.controlScale)
	PT_Frame:SetMouseEnabled(PT.savedVariables.unlocked) 
	PT_Frame:SetMovable(PT.savedVariables.unlocked)
	PT_Frame_Unlocked:SetHidden(not PT.savedVariables.unlocked)
	if PT.savedVariables.bgFrameType==1 then 
		PT_Frame_IconBGFrame:SetHidden(true)
		PT_Frame_IconBGCorners:SetHidden(true)
	elseif PT.savedVariables.bgFrameType==2 then
		PT_Frame_IconBGFrame:SetHidden(true)
		PT_Frame_IconBGCorners:SetHidden(false)	
	elseif PT.savedVariables.bgFrameType==3 then
		PT_Frame_IconBGFrame:SetHidden(false)
		PT_Frame_IconBGCorners:SetHidden(true)
	elseif 	PT.savedVariables.bgFrameType==4 then
		PT_Frame_IconBGFrame:SetHidden(false)
		PT_Frame_IconBGCorners:SetHidden(false)
	end
	PT.UpdateControl()
end

function PT.OnFullUpdate(eventCode, isHotbarSwap)
	if not isHotbarSwap then return end
	PT.UpdateControl()
end

function PT.unlocked(unlocked)
	if unlocked then
		if HUD_SCENE:HasFragment(POISON_TRACKER_SCENE_FRAGMENT) and HUD_UI_SCENE:HasFragment(POISON_TRACKER_SCENE_FRAGMENT) and LOOT_SCENE:HasFragment(POISON_TRACKER_SCENE_FRAGMENT) then
			HUD_SCENE:RemoveFragment(POISON_TRACKER_SCENE_FRAGMENT)
			HUD_UI_SCENE:RemoveFragment(POISON_TRACKER_SCENE_FRAGMENT)
			LOOT_SCENE:RemoveFragment(POISON_TRACKER_SCENE_FRAGMENT)
		end
	else
		if (not HUD_SCENE:HasFragment(POISON_TRACKER_SCENE_FRAGMENT)) and 
			(not HUD_UI_SCENE:HasFragment(POISON_TRACKER_SCENE_FRAGMENT)) and 
			(not LOOT_SCENE:HasFragment(POISON_TRACKER_SCENE_FRAGMENT)) then
				HUD_SCENE:AddFragment(POISON_TRACKER_SCENE_FRAGMENT)
				HUD_UI_SCENE:AddFragment(POISON_TRACKER_SCENE_FRAGMENT)
				LOOT_SCENE:AddFragment(POISON_TRACKER_SCENE_FRAGMENT)
		end
	end	
end


function PT.initializeAddonMenu()
	local panelData = {
		type = "panel",
		name = "Poison Tracker",
		displayName = "Poison Tracker",
		author = "Dorrino",
		version = 1.1,
		slashCommand = "/pt_tracker",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	local optionsPanel = LAM2:RegisterAddonPanel("Poison_Tracker_Panel", panelData)
		
	local optionsData = {}
	
	table.insert(optionsData, {
		type = "header",
		name = "Poison Tracker options",
		})
	table.insert(optionsData, {
		type = "checkbox",
		name = "ADDON ENABLED",
		tooltip = "ON - enabled, OFF - disabled",
		default = PT.defaults.enabled,
		getFunc = function() return PT.savedVariables.enabled end,
		setFunc = function(newValue) PT.savedVariables.enabled = newValue PT.OnOff() end,
		})	
	table.insert(optionsData, {
		type = "checkbox",
		name = "POSITION UNLOCKED",
		tooltip = "ON - icon can me moved on the screen by left clicking and dragging, OFF - icon is locked in place and can not be moved",
		default = PT.defaults.unlocked,
		disabled = function() return not PT.savedVariables.enabled end,
		getFunc = function() return PT.savedVariables.unlocked end,
		setFunc = function(newValue) PT.savedVariables.unlocked = newValue PT.unlocked(PT.savedVariables.unlocked) PT.InitControls() end,
		})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Use global settings",
		tooltip = "ON - use global settings for all characters, OFF - use individual settings for each character",
		default = PT.accountWideDefaults.accountWide, 
		disabled = function() return not PT.savedVariables.enabled end,
		getFunc = function() return PT.DS.accountWide end,
		setFunc = function(newValue) PT.DS.accountWide = newValue ReloadUI() end,
		warning = "Triggering this options with reload the UI",
	})
	table.insert(optionsData, {
		type = "header",
		name = "Poison Tracker icon options",
		})
	table.insert(optionsData, {
			type = "dropdown",
			name = "Icon frame type",
			tooltip = "No frame around the icon, shows corners only, shows border only, shows full frame border with corners",
			choices = {"No frame", "Only corners", "Only border", "Full frame"},
			getFunc = function() 
				if PT.savedVariables.bgFrameType==1 then 
					return "No frame"
				elseif PT.savedVariables.bgFrameType==2 then
					return "Only corners"				
				elseif PT.savedVariables.bgFrameType==3 then
					return "Only border"
				elseif PT.savedVariables.bgFrameType==4 then
					return "Full frame"
				end
			end,
			setFunc = function(newValue)
				if newValue=="No frame" then 
					PT.savedVariables.bgFrameType=1
					PT_Frame_IconBGFrame:SetHidden(true)
					PT_Frame_IconBGCorners:SetHidden(true)
					-- PT.zoneIconSize=48
				elseif newValue=="Only corners" then
					PT.savedVariables.bgFrameType=2
					PT_Frame_IconBGFrame:SetHidden(true)
					PT_Frame_IconBGCorners:SetHidden(false)
					-- PT.zoneIconSize=64				
				elseif newValue=="Only border" then
					PT.savedVariables.bgFrameType=3
					PT_Frame_IconBGFrame:SetHidden(false)
					PT_Frame_IconBGCorners:SetHidden(true)
					-- PT.zoneIconSize=64
				elseif 	newValue=="Full frame" then
					PT.savedVariables.bgFrameType=4
					PT_Frame_IconBGFrame:SetHidden(false)
					PT_Frame_IconBGCorners:SetHidden(false)
					-- PT.zoneIconSize=72
				end
				PT.InitControls()
			end,
			default = "Only corners",
			disabled = function() return not PT.savedVariables.enabled end,
		})			
	table.insert(optionsData, {
		type = "checkbox",
		name = "Hidden if no poison applied",
		tooltip = "ON - icon is hidden, OFF - icon is shown",
		default = PT.defaults.hideEmpty,
		disabled = function() return not PT.savedVariables.enabled end,
		getFunc = function() return PT.savedVariables.hideEmpty end,
		setFunc = function(newValue) PT.savedVariables.hideEmpty = newValue PT.InitControls() end,
		})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Play proc animation",
		tooltip = "ON - play animation if the current poison is applied to the target, OFF - do not play animation",
		default = PT.defaults.playAnimation,
		disabled = function() return not PT.savedVariables.enabled end,
		getFunc = function() return PT.savedVariables.playAnimation end,
		-- setFunc = function(newValue) PT.savedVariables.playAnimation = newValue PT.timelineAnimation(PT_Frame)	PT.StartProcAnimation(PT_Frame_Star) end,
		setFunc = function(newValue) PT.savedVariables.playAnimation = newValue PT.StartAnimation() end,
		})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Play proc sound",
		tooltip = "ON - play a sound when the current poison is applied to the target, OFF - do not play the sound",
		default = PT.defaults.playSound,
		disabled = function() return not PT.savedVariables.enabled end,
		getFunc = function() return PT.savedVariables.playSound end,
		-- setFunc = function(newValue) PT.savedVariables.playAnimation = newValue PT.timelineAnimation(PT_Frame)	PT.StartProcAnimation(PT_Frame_Star) end,
		setFunc = function(newValue) PT.savedVariables.playSound = newValue end,
		})
	table.insert(optionsData, {
		type = "slider",
		name = "Set icon scale (%)",
		tooltip = "Icon scale changes from 20% to 200% of original scale",
		default = tonumber(string.format("%.0f", 100*PT.defaults.controlScale)),
		disabled = function() return not PT.savedVariables.enabled end,
		min     = 20,
        max     = 200,
        step    = 1,
		-- getFunc = function() return tonumber(string.format("%.2f", PT.savedVariables.controlScale)) end,
		getFunc = function() return tonumber(string.format("%.0f", 100*PT.savedVariables.controlScale)) end,
		setFunc = function(newValue) PT.savedVariables.controlScale = newValue/100 PT.InitControls() end,
		})			
	table.insert(optionsData, {
		type = "slider",
		name = "Set icon background opacity (%)",
		tooltip = "Background transparency changes from 0% (fully transparent) to 100% (fully opaque)",
		default = tonumber(string.format("%.0f", PT.defaults.alphaBG*100)),
		disabled = function() return not PT.savedVariables.enabled end,
		min     = 0,
        max     = 100,
        step    = 1,
		getFunc = function() return tonumber(string.format("%.0f", PT.savedVariables.alphaBG*100))  end,
		setFunc = function(newValue) PT.savedVariables.alphaBG = newValue/100 PT.InitControls() end,
		})	
	
	LAM2:RegisterOptionControls("Poison_Tracker_Panel", optionsData)	
end

function PT.OnOff()
	if PT.savedVariables.enabled then 
		EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_PLAYER_ACTIVATED, PT.Activated)
		EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, PT.OnSingleSlotUpdate)
		EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_ACTION_SLOTS_FULL_UPDATE, PT.OnFullUpdate)
		PT_Frame:SetHidden(false)
		PT.unlocked(PT.savedVariables.unlocked)
		PT.Activated() 
	else
		EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_PLAYER_ACTIVATED)
		EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_ACTION_SLOTS_FULL_UPDATE)
		PT.unlocked(true)
		PT_Frame:SetHidden(true)
	end
end

function PT.Activated()
	PT.currentStackSize[ACTIVE_WEAPON_PAIR_MAIN]=PT.GetStackSize(ACTIVE_WEAPON_PAIR_MAIN)
	PT.currentStackSize[ACTIVE_WEAPON_PAIR_BACKUP]=PT.GetStackSize(ACTIVE_WEAPON_PAIR_BACKUP)
	PT.InitControls()
end

PT.accountWideDefaults = {
	accountWide = false,
}

function PT.OnLoad(eventCode, addonName)
	if addonName~=PT.name then return end
	EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_ADD_ON_LOADED, PT.OnLoad)
	
	PT.DS = ZO_SavedVars:NewAccountWide("PoisonTrackerSettings", 999, "AccountWide", PT.accountWideDefaults)
	if PT.DS.accountWide then
		PT.savedVariables = ZO_SavedVars:NewAccountWide("PoisonTrackerSettings", PT.version, "Settings", PT.defaults)
	else
		PT.savedVariables = ZO_SavedVars:New("PoisonTrackerSettings", PT.version, "Settings", PT.defaults)
	end
	
	
	PT.savedVariables = ZO_SavedVars:New("PoisonTrackerSettings", 1.0, nil, PT.defaults)
	PT.initializeAddonMenu()
	POISON_TRACKER_SCENE_FRAGMENT = ZO_FadeSceneFragment:New(PT_Frame, nil, 0)
	PT.OnOff()
end

EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_ADD_ON_LOADED, PT.OnLoad)

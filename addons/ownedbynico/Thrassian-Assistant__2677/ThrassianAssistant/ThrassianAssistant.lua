TA = TA or {}
TA.name = "ThrassianAssistant"
TA.version = "1.2"

TA.panel = ZO_SimpleSceneFragment:New(ThrassianAssistantPanel)

TA.SET = "|H1:item:164291:364:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h"
TA.SETID = 164291
TA.BUFFID = 136123
TA.CROUCHBIND = "SPECIAL_MOVE_CROUCH"

function TA.InitSavedVariables()
	local defaults = {
		lockui = false,
		panel = {
			enabled = true,
			top = -1,
			left = -1
		},
		nocrouch = true,
		gloveSwap = false,
		keys = {
			[1] = KEY_CTRL,
			[2] = KEY_INVALID,
			[3] = KEY_INVALID,
			[4] = KEY_INVALID,
		},
		swapwarning = false,
	}
	TA.savedVariables = ZO_SavedVars:NewAccountWide("TASV", 1, nil, defaults)
end

function TA.InitAddonMenu()
	local panelData = {
		type = "panel",
		name = "Thrassian Assistant",
		displayName = "Thrassian Assistant",
		author = "ownedbynico",
		version = TA.version,
	}
	local optionsData = {
		{
			type = "checkbox",
			name = "Enable Tracker",
			getFunc = function() return TA.savedVariables.panel.enabled end,
			setFunc = function(value)
						TA.savedVariables.panel.enabled = value
						TA.ShowPanel(TA.DoesWearGloves() and TA.savedVariables.panel.enabled)
					  end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Lock Tracker Position",
			getFunc = function() return TA.savedVariables.lockui end,
			setFunc = function(value)
						TA.savedVariables.lockui = value
						ThrassianAssistantPanel:SetMovable(not value)
					  end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Unbind Crouch Key",
			getFunc = function() return TA.savedVariables.nocrouch end,
			setFunc = function(value)
						TA.savedVariables.nocrouch = value
						TA.OnGloveChange(_, _, EQUIP_SLOT_HAND)
						if value == false then
							local layer, category, action = GetActionIndicesFromName(TA.CROUCHBIND)
							for i = 1, 4 do
								CallSecureProtected("BindKeyToAction", layer, category, action, i, TA.savedVariables.keys[i])
							end
							TA.savedVariables.gloveSwap = false
						end
					  end,
			width = "full",
			tooltip = "Unbinds your crouch key to prevent you from losing stacks. Keys will be binded again if you unequip the gloves.",
		},
		{
			type = "checkbox",
			name = "AlphaGear Swap Warning",
			getFunc = function() return TA.savedVariables.swapwarning end,
			setFunc = function(value) TA.savedVariables.swapwarning = value end,
			width = "full",
			tooltip = "Adds a confirmation you have to accept in order to swap to a setup without gloves (if you wear them at that moment).",
			requiresReload = true,
		},		
	}
	LibAddonMenu2:RegisterAddonPanel("TAHS", panelData)
	LibAddonMenu2:RegisterOptionControls("TAHS", optionsData)
end

function TA.ResetPanelPosition()
	local panelLeft = TA.savedVariables.panel.left
	local panelTop = TA.savedVariables.panel.top
	if panelTop > -1 and panelLeft > -1 then
		ThrassianAssistantPanel:ClearAnchors()
		ThrassianAssistantPanel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, panelLeft, panelTop)
	end
	if TA.savedVariables.lockui == true then
		ThrassianAssistantPanel:SetMovable(false)
	end	
end

function TA.ShowPanel(show)
	if show == true then
		HUD_SCENE:AddFragment(TA.panel)
		HUD_UI_SCENE:AddFragment(TA.panel)
		ThrassianAssistantPanel:SetHidden(false)
	else
		ThrassianAssistantPanel:SetHidden(true)
		HUD_SCENE:RemoveFragment(TA.panel)
		HUD_UI_SCENE:RemoveFragment(TA.panel)
	end
end

function TA.OnEffectChanged()
	ThrassianAssistantPanelLabel:SetText(tostring(TA.GetStacks()))
end

function TA.GetStacks()
	for i = 1, GetNumBuffs("player") do
		local _, _, _, _, stacks, _, _, _, _, _, id = GetUnitBuffInfo("player", i)
		if id == TA.BUFFID then
			return stacks
		end
	end
	return 0
end

function TA.OnBindingsChanged(_, layerIndex, categoryIndex, actionIndex, bindingIndex, keyCode)
	local layer, category, action = GetActionIndicesFromName(TA.CROUCHBIND)
	if layerIndex == layer and categoryIndex == category and actionIndex == action then
		TA.savedVariables.keys[bindingIndex] = keyCode
	end
end

function TA.DoesWearGloves()
	_, _, _, numEquipped = GetItemLinkSetInfo(TA.SET, true)
	return (numEquipped == 1)
end

function TA.SaveCrouchKeys()
	local layer, category, action = GetActionIndicesFromName(TA.CROUCHBIND)
	for i = 1, 4 do
		TA.savedVariables.keys[i] = GetActionBindingInfo(layer, category, action, i)
	end
end

function TA.OnGloveChange(_, _, slot)
	if slot ~= EQUIP_SLOT_HAND then return end
	if TA.DoesWearGloves() == true then
		TA.ShowPanel(true and TA.savedVariables.panel.enabled)
		if TA.savedVariables.nocrouch == true then
			TA.SaveCrouchKeys()
			local layer, category, action = GetActionIndicesFromName(TA.CROUCHBIND)
			CallSecureProtected("UnbindAllKeysFromAction", layer, category, action)
			TA.savedVariables.gloveSwap = true
		end
	else
		TA.ShowPanel(false)
		if TA.savedVariables.gloveSwap == true then
			local layer, category, action = GetActionIndicesFromName(TA.CROUCHBIND)
			for i = 1, 4 do
				CallSecureProtected("BindKeyToAction", layer, category, action, i, TA.savedVariables.keys[i])
			end
			TA.savedVariables.gloveSwap = false
		end
	end
end

function TA.OverrideAlphaGear()
	
	if TA.savedVariables.swapwarning ~= true then return end
	if not AG then return end
	
	local setnr = 0
	
	LibDialog:RegisterDialog(TA.name, "GloveConfirmation", "|t35:35:/esoui/art/icons/achievement_su_karnwasten_groupevent.dds|t Thrassian Assistant",
		"Are you sure you want to swap your setup and lose all stacks?",
		function() --yes handler
			AG.LoadSet(setnr, true)
		end,
		function() --no handler
			
		end)
	
	local origFunc = AG.LoadSet
	AG.LoadSet = function(nr, swap)
		local gear = AG.setdata[nr].Gear
		for i = 1, #gear do
			local itemLink = gear[i].link
			if GetItemLinkItemId(itemLink) == TA.SETID then
				swap = true
			end
		end
		
		if TA.DoesWearGloves() == true and not swap then
			setnr = nr
			LibDialog:ShowDialog(TA.name, "GloveConfirmation")
		else	
			origFunc(nr)
		end
	end
end


function TA.OnAddOnLoaded(_, addonName)
	if addonName ~= TA.name then return end
	
	TA.InitSavedVariables()
	TA.InitAddonMenu()
	TA.OnEffectChanged()
	TA.ResetPanelPosition()
	TA.ShowPanel(TA.DoesWearGloves() and TA.savedVariables.panel.enabled)
	
	TA.OverrideAlphaGear()
	
	EVENT_MANAGER:RegisterForEvent(TA.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, TA.OnGloveChange)
	EVENT_MANAGER:AddFilterForEvent(TA.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
	EVENT_MANAGER:AddFilterForEvent(TA.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
	EVENT_MANAGER:RegisterForEvent(TA.name, EVENT_KEYBINDING_SET, TA.OnBindingsChanged)
	EVENT_MANAGER:RegisterForEvent(TA.name, EVENT_EFFECT_CHANGED, TA.OnEffectChanged)
	EVENT_MANAGER:AddFilterForEvent(TA.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
	EVENT_MANAGER:AddFilterForEvent(TA.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, TA.BUFFID)
	EVENT_MANAGER:RegisterForEvent(TA.name, EVENT_PLAYER_ACTIVATED, TA.OnEffectChanged)
end

EVENT_MANAGER:RegisterForEvent(TA.name, EVENT_ADD_ON_LOADED, TA.OnAddOnLoaded)
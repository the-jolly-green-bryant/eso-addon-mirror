AL = {
	name = "ArmoryLocker",
    varsPath = "ArmoryLocker_Data",
	varsVer = 1
}

function AL.isCurrentBuildLocked()
    local build = AL.vars.builds[ARMORY_KEYBOARD.selectedBuildIndex]
    if build == nil then 
        return false
    else return build.locked end
end

function AL.CreateButton(name, parent)
	local button = WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON)
	
	button:SetInheritScale(false)
	button:SetDrawTier(DT_HIGH)
	button:SetDrawLayer(DL_OVERLAY)
	button:SetMouseEnabled(true)
	button:SetState(BSTATE_NORMAL)
	button:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	button:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	button:SetFont("ZoFontHeader")
	button:SetNormalTexture("ESOUI/art/miscellaneous/gamepad/gp_icon_locked32.dds")
  
	return button
end

function AL.RefreshUI()
    if AL.isCurrentBuildLocked() then
        AL.lockButton:SetNormalTexture("ESOUI/art/miscellaneous/gamepad/gp_icon_locked32.dds")
        AL.lockButton:SetAnchor(RIGHT, AL.Collapse, RIGHT, -30, 0)
    else
        AL.lockButton:SetNormalTexture("ESOUI/art/miscellaneous/gamepad/gp_icon_unlocked32.dds")
	    AL.lockButton:SetAnchor(RIGHT, AL.Collapse, RIGHT, -27, 0)
    end
end

function AL.CreateUI(control)
    local UIContainer = control:GetNamedChild("Container")	
	local Header =  UIContainer:GetNamedChild("Header")
	local Collapse =  Header:GetNamedChild("Collapse")

    AL.lockButton = AL.CreateButton("AL-lock", Header)
	AL.lockButton:SetDimensions(32, 32)
	AL.lockButton:SetAnchor(RIGHT, Collapse, RIGHT, -30, 0)
    
    AL.lockButton:SetHandler("OnMouseUp",function(self)
		if AL.vars.builds[ARMORY_KEYBOARD.selectedBuildIndex] == nil then
            AL.vars.builds[ARMORY_KEYBOARD.selectedBuildIndex] = {}
            AL.vars.builds[ARMORY_KEYBOARD.selectedBuildIndex].locked = false
        end

        AL.vars.builds[ARMORY_KEYBOARD.selectedBuildIndex].locked = not AL.vars.builds[ARMORY_KEYBOARD.selectedBuildIndex].locked

		KEYBIND_STRIP:UpdateKeybindButtonGroup(ARMORY_KEYBOARD.keybindStripDescriptor)
		AL.RefreshUI()
	end)

    AL.RefreshUI()
	return false
end

function AL.Initialize()
    -- Create saved variables.
    AL.vars = ZO_SavedVars:NewCharacterIdSettings(AL.varsPath, AL.varsVer, nil, {
        builds = {}
    })

    -- Hook for armory events.
    ZO_PreHook("ZO_Armory_ExpandedEntry_OnInitialized", AL.CreateUI)
	ZO_PostHook(ARMORY_KEYBOARD, "RefreshBuilds", AL.RefreshUI)

    ARMORY_KEYBOARD.keybindStripDescriptor[2].enabled = function()
        if AL.isCurrentBuildLocked() then return false end
        local function disabledAlertText()
            return zo_strformat(SI_ARMORY_BUILD_OPERATION_COOLDOWN_ALERT, ZO_FormatTimeMilliseconds(ARMORY_OPERATION_COOLDOWN_DURATION_MS, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS))
        end
        return not ZO_ARMORY_MANAGER:IsBuildOperationInProgress(), disabledAlertText
    end
end

function AL.OnAddonLoaded(e, addonName)
	if addonName ~= AL.name then return end
	AL.Initialize()
end

EVENT_MANAGER:RegisterForEvent(AL.name, EVENT_ADD_ON_LOADED, AL.OnAddonLoaded)
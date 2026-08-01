FastVolume = {}
FastVolume.name = "FastVolume"

doubleClick = false
 
function FastVolume:Initialize()
	-- Get saved variables, if there are any. If not, create them.
	self.savedVariables = ZO_SavedVars:NewAccountWide("FastVolumeSavedVariables", 1, nil, FastVolume.Default)

	-- Restore saved window state
    self:RestoreState()
	
	-- Register slash commands
	SLASH_COMMANDS["/fv"] = FVSlashCommand
	SLASH_COMMANDS["/fastvolume"] = FVSlashCommand

    -- Hide the addon when a different HUD scene occurs
    local fragmentFastVolume = ZO_HUDFadeSceneFragment:New(FastVolumePanel, nil, 0)
    HUD_SCENE:AddFragment(fragmentFastVolume)
    HUD_UI_SCENE:AddFragment(fragmentFastVolume)

	--------------
	-- BINDINGS --
	--------------

    -- Click to toggle visibility
    FastVolumeSubPanelToggle:SetHandler("OnClicked", function(self)
        -- If a second click doesn't come within 300 ms, consider it a single click
        zo_callLater(function ()
            FastVolume:TrySingleClick()
        end, 300)
        zo_callLater(function ()
            doubleClick = false
        end, 500)
    end)

    -- Double click to mute
    FastVolumeSubPanelToggle:SetHandler("OnMouseDoubleClick", function(self)
        doubleClick = true
        FastVolume:ToggleMute()
    end)

	-- Mute tooltip
	FastVolumeSubPanelToggle.tooltipText = "Double-click to toggle mute."
	FastVolumeSubPanelToggle:SetHandler("OnMouseEnter", function(self)
      ZO_Tooltips_ShowTextTooltip(self, TOP, self.tooltipText)
    end)
    FastVolumeSubPanelToggle:SetHandler("OnMouseExit", function(self)
       ZO_Tooltips_HideTextTooltip()
    end)

	-- Anchor tooltip
	FastVolumeAnchor.tooltipText = "Drag to reposition. Double-click to lock."
	FastVolumeAnchor:SetHandler("OnMouseEnter", function(self)
      ZO_Tooltips_ShowTextTooltip(self, TOP, self.tooltipText)
    end)
	FastVolumeAnchor:SetHandler("OnMouseExit", function(self)
       ZO_Tooltips_HideTextTooltip()
    end)
	
	-- Lock frame position when you double-click the anchor.
	-- Renable it using the /fv unlock command
	FastVolumeAnchor:SetHandler("OnMouseDoubleClick", function(self)
		FastVolume:Lock()
    end)
end

function FastVolume:TrySingleClick()
    if (doubleClick == false) then
        FastVolume:TogglePanel()
    end
end

-- Save window position
function FastVolume:OnIndicatorMoveStop()
    FastVolume.savedVariables.left = FastVolumeAnchor:GetLeft()
    FastVolume.savedVariables.top = FastVolumeAnchor:GetTop()
end

-- Lock window position
function FastVolume:Lock()
	FastVolume:SilentLock()
	d("|cFF0000FastVolume|r has been locked. Type |c00FF00/fv unlock|r to move it.")
end

-- Lock window position
function FastVolume:SilentLock()
    FastVolumeAnchor:SetHidden(true)
    FastVolume.savedVariables.locked = true
end

-- Unlock window position, allowing it to be moved
function FastVolume:Unlock()
	FastVolumeAnchor:SetHidden(false)
	FastVolume.savedVariables.locked = false
	d("|cFF0000FastVolume|r has been unlocked. Double-click the red anchor or type |c00FF00/fv lock|r to lock its position.")
end

-- Restore saved window position and muted state icon
function FastVolume:RestoreState()
    -- Restore muted icon
    if(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_ENABLED) == "0") then
        FastVolumeSubPanelToggle:SetNormalTexture("FastVolume/media/muted.dds")
    end
    -- Restore visibility
    FastVolume:FVSetHidden(self.savedVariables.visibility)

    -- Restore locked status
    if(self.savedVariables.locked == true) then
        FastVolume:SilentLock()
    end

    -- Restore window position
    local left = self.savedVariables.left
    local top = self.savedVariables.top
    FastVolumeAnchor:ClearAnchors()
    FastVolumeAnchor:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

--[[
Valid slash commands:
	/fv             Display help
	/fv help        Display help
	/fv [0-100]     Set volume to value
	/fv mute        Toggle mute
	/fv unmute      Alias of mute
	/fv mute on     Alias of mute
	/fv mute off    Alias of mute
	/fv lock        Lock window position
	/fv unlock      Unlock window position
]]--
function FVSlashCommand(--[[optional]]option)
    -- source: https://wiki.esoui.com/How_to_add_a_slash_command
    local options = {}
    local searchResult = { string.match(option,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end

       -- Handle help or missing parameters
    if (options[1] == nil or options[1] == '' or options[1] == 'help' or option == '') then
        FastVolume:PrintHelp()
        -- Handle mute parameters
    elseif (options[1] == "mute" or options[1] == "unmute" or (options[1] == "mute" and (options[2] == "on" or options[2] == "off"))) then
        FastVolume:ToggleMute()
        -- Handle unlock parameter
    elseif (options[1] == "unlock") then
        FastVolume:Unlock()
        -- Handle lock parameter
    elseif (options[1] == "lock") then
        FastVolume:Lock()
        -- Handle non-numeric parameters
    elseif (tonumber(options[1]) == nil) then
        d(zo_strformat("|cFF0000FastVolume|r |c00FF00Error:|r <<1>> is not a valid volume level. Type /fv [0-100] to set the volume to a given level.",options[1]))
    else
        -- Set the volume to the given value
        FastVolume:SetMasterVolume(tonumber(options[1]))
        FastVolume:SetSelectedButtonTexture(tonumber(options[1]))
    end
end

function FastVolume:PrintHelp()
    d("|cFF0000FastVolume|r Help:" ..
      "\n|c00FF00/fv help|r  Display help" ..
      "\n|c00FF00/fv [0-100]|r  Set volume to value" ..
      "\n|c00FF00/fv mute|r  Toggle mute" ..
      "\n|c00FF00/fv lock|r  Lock window position" ..
      "\n|c00FF00/fv unlock|r  Unlock window position")
end

-- Set volume to the specified value
function FastVolume:SetMasterVolume(option)
	if (option >= 0 and option <= 100) then
        d(zo_strformat("|cFF0000FastVolume|r set master volume to <<1>>.",option))
        SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME, option)
    else
        -- Handle numbers outside of the valid range
        d(zo_strformat("|cFF0000FastVolume|r |c00FF00Error:|r <<1>> is not a valid volume level. The volume level must be an integer between 0 and 100.",option))
	end
end

-- Toggle muted state
function FastVolume:ToggleMute()
    if(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_ENABLED) == "1") then
        FastVolumeSubPanelToggle:SetNormalTexture("FastVolume/media/muted.dds")
        SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_ENABLED, "0")
        d("|cFF0000FastVolume|r mute ON.")
    else
        SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_ENABLED, "1")
        FastVolumeSubPanelToggle:SetNormalTexture("/esoui/art/voip/gamepad/gp_voip_listening.dds")
        d("|cFF0000FastVolume|r mute OFF.")
    end
end

-- Play a button click sound when setting the volume with a button
function FastVolume:SetMasterVolumeWithButton(value)
    PlaySound(SOUNDS.DEFAULT_CLICK)
    FastVolume:SetSelectedButtonTexture(value)
    FastVolume:SetMasterVolume(value)
end

-- Use a texture to mark which button is currently selected
function FastVolume:SetSelectedButtonTexture(value)
    local selected_texture = "/esoui/art/buttons/32x32button_genericmouseover.dds"
    local blank_texture = "/esoui/art/auras/aura_warrior.dds"

    -- Remove any set textures
    FastVolumeSubPanelButton0:SetNormalTexture(blank_texture)
    FastVolumeSubPanelButton25:SetNormalTexture(blank_texture)
    FastVolumeSubPanelButton50:SetNormalTexture(blank_texture)
    FastVolumeSubPanelButton75:SetNormalTexture(blank_texture)
    FastVolumeSubPanelButton100:SetNormalTexture(blank_texture)

    -- Add the special texture to the selected button
    if value == 0 then
        FastVolumeSubPanelButton0:SetNormalTexture(selected_texture)
    elseif value == 25 then
        FastVolumeSubPanelButton25:SetNormalTexture(selected_texture)
    elseif value == 50 then
        FastVolumeSubPanelButton50:SetNormalTexture(selected_texture)
    elseif value == 75 then
        FastVolumeSubPanelButton75:SetNormalTexture(selected_texture)
    elseif value == 100 then
        FastVolumeSubPanelButton100:SetNormalTexture(selected_texture)
    end
end

-- Set visibility of volume buttons
function FastVolume:FVSetHidden(state)
    FastVolume.savedVariables.visibility = state
    visibility = state
	FastVolumeSubPanelBackdrop:SetHidden(state)
	FastVolumeSubPanelButton0:SetHidden(state)
	FastVolumeSubPanelButton25:SetHidden(state)
	FastVolumeSubPanelButton50:SetHidden(state)
	FastVolumeSubPanelButton75:SetHidden(state)
	FastVolumeSubPanelButton100:SetHidden(state)
end

-- Toggle volume button visibility
function FastVolume:TogglePanel()
	PlaySound(SOUNDS.DEFAULT_CLICK)
	FastVolume:FVSetHidden(not(visibility))
end
 
function FastVolume.OnAddOnLoaded(event, addonName)
    if addonName == FastVolume.name then
        -- Initialize the addon
        FastVolume:Initialize()

        -- Cleanup
        EVENT_MANAGER:UnregisterForEvent(FastVolume.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(FastVolume.name, EVENT_ADD_ON_LOADED, FastVolume.OnAddOnLoaded)
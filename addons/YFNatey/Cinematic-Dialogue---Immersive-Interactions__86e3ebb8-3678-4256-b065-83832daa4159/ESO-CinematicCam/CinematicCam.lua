--[[
===============================================================================
Cinematic Dialogue - An Elder Scrolls Online Addon
Author: YFNatey

===============================================================================
]]
local ADDON_NAME = "CinematicCam"

CinematicCam = {}
CinematicCam.savedVars = nil
local interactionTypeMap = {}
local CURRENT_VERSION = "3.96"

-- State tracking
CinematicCam.isInteractionModified = false
CinematicCam.settingsUpdatedThisSession = false
CinematicCam.isMenuActive = false
CinematicCam.blockGamepad = false
CinematicCam.lastWeaponsState = nil
CinematicCam.isMounted = false
CinematicCam.currentZoneType = nil
CinematicCam.reloadUI = false
CinematicCam.isHoveringOccupationalNPC = false
CinematicCam.currentOccupation = nil
-- Camera Renaming
CinematicCam.CAMERA_MODE = {
    -- SetGameCameraUIMode()
    FREE     = false,
    STATIC   = true,

    -- SetInteractionUsingInteractCamera()
    INTERACT = true,
    GAMEPLAY = false,
}


function CinematicCam:InitializeInteractionSettings()
    interactionTypeMap = {
        [INTERACTION_CONVERSATION] = self.savedVars.interaction.forceThirdPersonDialogue,
        [INTERACTION_QUEST] = self.savedVars.interaction.forceThirdPersonQuest,
        [INTERACTION_VENDOR] = self.savedVars.interaction.forceThirdPersonVendor,
        [INTERACTION_STORE] = self.savedVars.interaction.forceThirdPersonVendor,
        [INTERACTION_GUILDBANK] = self.savedVars.interaction.forceThirdPersonBank,
        [INTERACTION_TRADINGHOUSE] = self.savedVars.interaction.forceThirdPersonVendor,
        [INTERACTION_STABLE] = self.savedVars.interaction.forceThirdPersonVendor,
        [INTERACTION_CRAFT] = self.savedVars.interaction.forceThirdPersonCrafting,
        [INTERACTION_DYE_STATION] = self.savedVars.interaction.forceThirdPersonDye,

    }
end

-- Handles the visibility of the games default subtitles.
-- @param visibility string: the user settings. If using "cinematic" layout, the default subtitles need to be hidden on each new dialogue event
function CinematicCam:HandleDefaultSubtitles(visibility)
    -- Hide Subtitles with user settings
    local npcSubtitles = ZO_InteractWindowTargetAreaBodyText
    local npcName = ZO_InteractWindow_GamepadContainerText
    if visibility == "savedSettings" then
        if npcSubtitles then
            npcSubtitles:SetHidden(self.savedVars.interaction.subtitles.isHidden)
        end
        if npcName then
            npcName:SetHidden(self.savedVars.interaction.subtitles.isHidden)
        end
    end
    -- Hide
    if visibility == "cinematic" then
        if npcSubtitles then
            npcSubtitles:SetHidden(true)
        end
        if npcName then
            npcName:SetHidden(true)
        end
    end
end

-- Handles the logic when the player enters an interaction with an interactive object (NPCs, notes, quest starters, etc)
-- Tracks the state of the interaction using dialogue events to watch for subtitle changes, update the chunked text system and apply the appropriate visibility settings.
function CinematicCam:OnInteractionStart()
    local useGameplayCam = false
    local interactionType = GetInteractionType()

    if self.isHoveringOccupationalNPC and self.savedVars.interaction.forceThirdPersonOccupationalNPC then
        useGameplayCam = true

        -- Then check user settings for camera mode based on current interaction type
    elseif interactionTypeMap[interactionType] == true then
        useGameplayCam = true
    end

    -- Handle the default subtitle visibility immediately
    CinematicCam:HandleDefaultSubtitles("savedSettings")

    if useGameplayCam then
        SetGameCameraUIMode(CinematicCam.CAMERA_MODE.FREE) -- Enable free camera movement

        local fontPath = self:GetCurrentFont()
        self.savedVars.interface.keybindIsHidden = true

        CinematicCam:UpdateKeybindStripVisibility()
        CinematicCam.isInteractionModified = true

        if CinematicCam.savedVars.interaction.allowCameraMovementDuringDialogue or CinematicCam.savedVars.interaction.allowImmersionControls then
            if not self.gamepadStickPoll then
                self.gamepadStickPoll = {
                    isActive = true,
                    deadzone = 0.2,
                    moveThreshold = 0.5,
                    lastMove = GetGameTimeMilliseconds(),
                    lastCameraSwitch = 0,
                    cameraSwitchCooldown = 500,
                    lastEmoteTime = 0,
                    emoteCooldown = 2000,
                }
            end

            self.gamepadStickPoll.isActive = true

            -- Initialize and show emote wheel
            if CinematicCam.savedVars.interaction.allowImmersionControls then
                if not self.emoteWheelInitialized then
                    self.emoteWheelInitialized = true
                end
                if not self.cameraWheelInitialized then
                    self.cameraWheelInitialized = true
                end
                if self.savedVars.interaction.ButtonsVisible then
                    CinematicCam:ShowEmoteWheel()
                end
            end

            if CinematicCam.savedVars.interaction.allowCameraMovementDuringDialogue then
                if self.savedVars.interaction.ButtonsVisible then
                    CinematicCam:ShowCameraWheel()
                end
            end

            zo_callLater(function()
                local isVendor = CinematicCam:IsVendorInteraction()
                CinematicCam.blockGamepad = isVendor

                if isVendor then
                    CinematicCam:HideEmoteWheel()
                    CinematicCam:HideCameraWheel()
                    CinematicCam:HideEmotePad()
                    CinematicCam:HideCameraPad()
                elseif CinematicCam.isInteractionModified then
                    EVENT_MANAGER:RegisterForUpdate("CinematicCam_GamepadStickPoll", 50, function()
                        CinematicCam:StartGamepadStickPoll()
                    end)
                    EVENT_MANAGER:RegisterForUpdate("CinematicCam_GamepadConsumedUIPoll", 0, function()
                        CinematicCam:StartGamepadConsumedUIPoll()
                    end)

                    --
                end
            end)
        end
        if interactionType == INTERACTION_FURNITURE or interactionType == INTERACTION_STORE then
            CinematicCam:StopGamepadStickPoll()
        end

        CinematicCam:ApplyDialogueRepositioning()

        -- CHATTER
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_ChatterBegin", EVENT_CHATTER_BEGIN)
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_ConversationUpdate", EVENT_CONVERSATION_UPDATED)
        EVENT_MANAGER:RegisterForEvent(
            ADDON_NAME .. "_ChatterBegin",
            EVENT_CHATTER_BEGIN,
            function()
                if self.isHoveringOccupationalNPC then
                    SetInteractionUsingInteractCamera(CinematicCam.CAMERA_MODE.INTERACT)
                    SetGameCameraUIMode(CinematicCam.CAMERA_MODE.STATIC)
                else
                    SetInteractionUsingInteractCamera(self.savedVars.useCinematicCamera)
                    SetGameCameraUIMode(CinematicCam.CAMERA_MODE.FREE)
                end
                if self.savedVars.interaction.subtitles.hidePlayerOptionsUntilLastChunk == false then
                    CinematicCam:ShowPlayerResponse()
                end

                if self.savedVars.interaction.layoutPreset == "cinematic" then
                    CinematicCam:HandleDefaultSubtitles("cinematic")
                    CinematicCam:InterceptDialogueForChunking("ChatterBegin")
                    if not self.savedVars.interaction.autoEmotes then
                        return
                    end
                    if self.savedVars.interaction.GreetingType == "none" then
                        return
                    end
                end
            end
        )

        -- CONVERSATION UPDATE
        EVENT_MANAGER:RegisterForEvent(
            ADDON_NAME .. "_ConversationUpdate",
            EVENT_CONVERSATION_UPDATED,
            function()
                SetInteractionUsingInteractCamera(self.savedVars.useCinematicCamera)
                SetGameCameraUIMode(CinematicCam.CAMERA_MODE.FREE)
                if self.savedVars.interaction.subtitles.hidePlayerOptionsUntilLastChunk == false then
                    CinematicCam:ShowPlayerResponse()
                end

                if self.savedVars.interaction.layoutPreset == "cinematic" then
                    CinematicCam:HandleDefaultSubtitles("cinematic")
                    CinematicCam:InterceptDialogueForChunking("ConversationUpdate")

                    -- automatic greeting when entering dialogue
                    if not self.savedVars.interaction.autoEmotes then return end
                    if self.savedVars.interaction.ChatType == "none" then return end

                    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_ChatterBegin", EVENT_CHATTER_BEGIN)
                end
            end
        )

        -- QUEST OFFERED
        EVENT_MANAGER:RegisterForEvent(
            ADDON_NAME .. "_QuestOffered",
            EVENT_QUEST_OFFERED,
            function()
                SetInteractionUsingInteractCamera(self.savedVars.useCinematicCamera)
                SetGameCameraUIMode(CinematicCam.CAMERA_MODE.FREE)
                if self.savedVars.interaction.subtitles.hidePlayerOptionsUntilLastChunk == false then
                    CinematicCam:ShowPlayerResponse()
                end

                if self.savedVars.interaction.layoutPreset == "cinematic" then
                    CinematicCam:HandleDefaultSubtitles("cinematic")


                    CinematicCam:InterceptDialogueForChunking("QuestOffered")
                    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_ChatterBegin", EVENT_CHATTER_BEGIN)
                    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_ConversationUpdate", EVENT_CONVERSATION_UPDATED)
                end
            end
        )

        -- QUEST COMPLETE
        EVENT_MANAGER:RegisterForEvent(
            ADDON_NAME .. "_QuestCompleteDialog",
            EVENT_QUEST_COMPLETE_DIALOG,
            function()
                SetInteractionUsingInteractCamera(self.savedVars.useCinematicCamera)
                SetGameCameraUIMode(CinematicCam.CAMERA_MODE.FREE)
                if self.savedVars.interaction.subtitles.hidePlayerOptionsUntilLastChunk == false then
                    CinematicCam:ShowPlayerResponse()
                end

                if self.savedVars.interaction.layoutPreset == "cinematic" then
                    CinematicCam:HandleDefaultSubtitles("cinematic")


                    CinematicCam:InterceptDialogueForChunking("QuestCompleteDialog")
                    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_ChatterBegin", EVENT_CHATTER_BEGIN)
                    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_ConversationUpdate", EVENT_CONVERSATION_UPDATED)
                    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_QuestOffered", EVENT_QUEST_OFFERED)
                end
            end
        )
        -- Move NPC dialogue text off-screen for cinematic mode (instead of hiding) to prevent flashing
        if self.savedVars.interaction.layoutPreset == "cinematic" then
            CinematicCam:HandleDefaultSubtitles("cinematic")
        end

        -- Hide UI Panels according to user preferences
        if self.savedVars.interaction.ui.hidePanelsESO then
            CinematicCam:HideDialoguePanels()
        end

        -- Player options background
        if self.savedVars.interface.usePlayerOptionsBackground then
            CinematicCam:ShowPlayerOptionsBackground()
        end

        -- Letterbox handling
        zo_callLater(function()
            if CinematicCam:AutoShowLetterbox(interactionType) and not CinematicCam:CheckPlayerOptionsForVendorText() then
                if not self.savedVars.letterbox.letterboxVisible then
                    CinematicCam:ShowLetterbox()
                end
            end
        end, 200)
        -- dof handling
        if self.savedVars.interaction.depthOfField.enabled then
            local param1 = self.savedVars.interaction.depthOfField.param1
            local param2 = self.savedVars.interaction.depthOfField.param2
            SetFullscreenEffect(FULLSCREEN_EFFECT_CHARACTER_FRAMING_BLUR, param1, param2, true)
            self.dofActive = true
        end
    end
end

function CinematicCam:OnInteractionEnd()
    EVENT_MANAGER:UnregisterForUpdate("CinematicCam_GamepadStickPoll")
    EVENT_MANAGER:UnregisterForUpdate("CinematicCam_GamepadConsumedUIPoll")
    SetInteractionUsingInteractCamera(CinematicCam.CAMERA_MODE.GAMEPLAY)

    CinematicCam.lastWeaponsState = nil
    CinematicCam:UpdateUIVisibility()
    CinematicCam:InitializeUITweaks()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_ConversationUpdate", EVENT_CONVERSATION_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_ChatterBegin", EVENT_CHATTER_BEGIN)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_QuestOffered", EVENT_QUEST_OFFERED)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_QuestCompleteDialog", EVENT_QUEST_COMPLETE_DIALOG)
    if CinematicCam.isInteractionModified then
        CinematicCam.isInteractionModified = false

        --Reset chunked dialogue state
        CinematicCam:ResetChunkedDialogueState()
        self.savedVars.interface.keybindIsHidden = false
        CinematicCam:RestoreKeybindStripVisibility()

        --hide dof
        if self.savedVars.interaction.depthOfField.enabled then
            SetFullscreenEffect(FULLSCREEN_EFFECT_NONE, 0, 0, true)
            self.dofActive = false
        end
        -- Hide letterbox if was visible
        if self.savedVars.interaction.auto.autoLetterboxDialogue and not self.savedVars.letterbox.perma then
            CinematicCam:HideLetterbox()
        end
    end
end

function CinematicCam:InitDefaults()
    CinematicCam.savedVars = ZO_SavedVars:NewAccountWide("CinematicCam2SavedVars", 2, nil, CinematicCam.defaults)
end

---=============================================================================
-- Initialize
--=============================================================================
local function Initialize()
    CinematicCam.reloadUI = false
    CinematicCam:InitDefaults()
    CinematicCam:ConfigurePlayerOptionsBackground()
    CinematicCam:InitializeChunkedTextControl()
    CinematicCam:InitializePreviewSystem()
    CinematicCam:InitializeEmoteWheel()
    CinematicCam:RegisterFontEvents()
    CinematicCam:InitializeCameraWheel()
    CinematicCam:InitializeLibRadialMenu()

    zo_callLater(function()
        CinematicCam:InitializeLetterbox()
        CinematicCam:MigrateSettings()
        CinematicCam:InitializeInteractionSettings()
        CinematicCam:RegisterUIRefreshEvent()
        CinematicCam:CreateSettingsMenu()


        CinematicCam:BuildHomeIdsLookup()
        CinematicCam:InitializeUpdateSystem()
        CinematicCam:UpdateUIVisibility()
    end, 1000)
    zo_callLater(function()
        CinematicCam:InitializeCustomPresets()
        CinematicCam:InitializeUITweaks()
        CinematicCam:InitializeUI()
    end, 2000)

    -- Register slash commands
    SLASH_COMMANDS["/ccui"] = function()
        CinematicCam:ToggleUI()
    end

    SLASH_COMMANDS["/ccbars"] = function()
        CinematicCam:ToggleLetterbox()
    end
    SLASH_COMMANDS["/p1"] = function()
        CinematicCam:LoadFromPresetSlot(1)
        CinematicCam:ShowPresetNotificationUI("Home")
    end
    SLASH_COMMANDS["/p2"] = function()
        CinematicCam:LoadFromPresetSlot(2)
        CinematicCam:ShowPresetNotificationUI("Overland")
    end
    SLASH_COMMANDS["/p3"] = function()
        CinematicCam:LoadFromPresetSlot(3)
        CinematicCam:ShowPresetNotificationUI("Dungeon/Trials")
    end
    SLASH_COMMANDS["/movie"] = function()
        CinematicCam:MovieMode()
    end
end



local function OnAddOnLoaded(event, addonName)
    if addonName == ADDON_NAME then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)


---=============================================================================
-- Events
--=============================================================================
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GAME_CAMERA_DEACTIVATED, function()
    CinematicCam:OnInteractionStart()
end)

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHATTER_END, function()
    CinematicCam:OnInteractionEnd()
end)

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_COMPLETE_DIALOG, function()
    CinematicCam:ShowPlayerOptionsOnLastChunk()
end)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_COMPLETE, function()
    CinematicCam:OnInteractionEnd()
end)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CLOSE_STORE, function()
    CinematicCam:OnInteractionEnd()
end)

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CLOSE_BANK, function()
    CinematicCam:OnInteractionEnd()
end)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_RETICLE_TARGET_CHANGED,
    function() CinematicCam:OnReticleTargetChanged() end)

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_MOUNTED_STATE_CHANGED, function(eventCode, mounted)
    if mounted then
        CinematicCam:OnMountUp()
        CinematicCam.isMounted = true
    else
        CinematicCam:OnMountDown()
        CinematicCam.isMounted = false
    end
end)

function CinematicCam:RegisterUIRefreshEvent()
    EVENT_MANAGER:RegisterForEvent("CinematicCam", EVENT_RETICLE_HIDDEN_UPDATE, function(eventCode, hidden)
        if not hidden then
            if self.isInteractionModified then
                return
            end
            -- Reticle now visible, player has exited menus/settings
            -- update Ui visibility when exiting menus, maps, quickslot wheel
            zo_callLater(function()
                local currentWeaponState = ArePlayerWeaponsSheathed()

                CinematicCam.lastWeaponsState = not currentWeaponState -- Set to opposite of current

                if self.manualUIHidden then
                    self:HideUI()
                else
                    -- Otherwise update based on settings (weapons/combat/etc)
                    CinematicCam:UpdateUIVisibility()
                end
                -- Check each setting independently
                SetInteractionUsingInteractCamera(CinematicCam.CAMERA_MODE.GAMEPLAY)
                if not self.isInteractionModified then
                    CinematicCam:InitializeUITweaks()
                end
                if self.presetPending then
                    CinematicCam:InitializeChunkedTextControl()
                    CinematicCam:InitializeLetterbox()
                    CinematicCam:InitializeUI()
                    CinematicCam:ConfigurePlayerOptionsBackground()
                    CinematicCam:InitializePreviewSystem()
                    CinematicCam:InitializeInteractionSettings()
                    CinematicCam:ApplyPresetSettings()
                    CinematicCam:OnFontChanged()
                    self.presetPending = false
                end
                if self.pendingUIRefresh then
                    CinematicCam:UpdateUIVisibility()
                    self.pendingUIRefresh = false
                end
                if CinematicCam.reloadUI then
                    ReloadUI()
                end
            end, 200)
        end
    end)
end

function CinematicCam:OnReticleTargetChanged()
    if DoesUnitExist("reticleover") then
        local occupation = GetUnitCaption("reticleover")

        if self:IsOccupationalNPC(occupation) then
            if self.savedVars.interaction.forceThirdPersonOccupationalNPC then
                self.isHoveringOccupationalNPC = true
                self.currentOccupation = occupation
            end
        else
            self.isHoveringOccupationalNPC = false
            self.currentOccupation = nil
        end
    else
        self.isHoveringOccupationalNPC = false
        self.currentOccupation = nil
    end
end

function CinematicCam:IsOccupationalNPC(occupation)
    if not occupation or occupation == "" then
        return false
    end

    -- check for key workds in occupations
    local occupationLower = string.lower(occupation)

    local occupationalKeywords = {
        "merchant",
        "blacksmith",
        "banker",
        "armorer",
        "woodworker",
        "clothier",
        "enchanter",
        "grocer",
        "alchemist",
        "provisioner",
        "trader",
        "fence",
        "stable",
        "mystic",
        "outlaw",
        "achievement",
        "undaunted",
        "brewer",
        "innkeeper",
        "chef",
        "cook",
        "banker",
        "money"
    }

    for _, keyword in ipairs(occupationalKeywords) do
        if string.find(occupationLower, keyword) then
            return true
        end
    end

    return false
end

-- Combat state change for compass, reticle, and action bar
EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Combat", EVENT_PLAYER_COMBAT_STATE, function(eventCode, inCombat)
    CinematicCam:InitializeUITweaks()
end)

-- Font events
function CinematicCam:RegisterFontEvents()
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Font", EVENT_CHATTER_BEGIN, function()
        CinematicCam:ApplyFontsToUI()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Font", EVENT_CONVERSATION_UPDATED, function()
        CinematicCam:ApplyFontsToUI()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Font", EVENT_QUEST_COMPLETE_DIALOG, function()
        CinematicCam:ApplyFontsToUI()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Font", EVENT_INTERACTION_UPDATED, function()
        CinematicCam:ApplyFontsToUI()
    end)

    -- Add more specific events
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Font", EVENT_SHOW_BOOK, function()
        CinematicCam:ApplyFontsToUI()
    end)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_ChatterEnd_StopPoll", EVENT_CHATTER_END, function()
    if CinematicCam.gamepadStickPoll and CinematicCam.gamepadStickPoll.isActive then
        CinematicCam:StopGamepadStickPoll()
    end
end)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_HousingState", EVENT_HOUSING_EDITOR_MODE_CHANGED,
    function(eventCode, oldMode, newMode)
        -- newMode values:
        -- HOUSING_EDITOR_MODE_DISABLED = 0 (not in housing editor)
        -- HOUSING_EDITOR_MODE_BROWSE = 1 (browsing/placing items)
        -- HOUSING_EDITOR_MODE_PLACEMENT = 2 (actively placing an item)
        -- HOUSING_EDITOR_MODE_NODE_SELECTION = 3 (path nodes)

        if newMode ~= HOUSING_EDITOR_MODE_DISABLED then
            CinematicCam.inHousingEditor = true
        else
            CinematicCam.inHousingEditor = false
        end
    end)


EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_ZoneChange", EVENT_PLAYER_ACTIVATED, function()
    zo_callLater(function()
        -- Check if auto-swap is enabled
        if not CinematicCam.savedVars.autoSwapPresets then
            return
        end

        local newZoneType = nil
        local presetToLoad = nil

        -- Home
        local zoneId = GetZoneId(GetCurrentMapZoneIndex())
        local homeId = CinematicCam:CheckAndApplyHomePreset(zoneId)

        if homeId then
            newZoneType = "home"
            if CinematicCam.savedVars.homePresets and CinematicCam.savedVars.homePresets[homeId] then
                presetToLoad = CinematicCam.savedVars.homePresets[homeId]
            end
            -- Dungeon
        elseif IsUnitInDungeon("player") then
            newZoneType = "dungeon"
            presetToLoad = 3

            CinematicCam:LoadFromPresetSlot(3)
            -- Overland
        elseif not IsUnitInDungeon("player") and not CinematicCam.savedVars.isHome then
            newZoneType = "overland"
            presetToLoad = 2
        end

        -- Only apply preset if zone type changed
        if newZoneType and newZoneType ~= CinematicCam.currentZoneType then
            CinematicCam.currentZoneType = newZoneType

            if presetToLoad then
                CinematicCam:LoadFromPresetSlot(presetToLoad)
            end
        end
    end, 1000)
end)


---=============================================================================
-- Utility Functions
--=============================================================================
function CinematicCam:MigrateSettings()
    if self.savedVars.interaction.subtitles.posX ~= 0.5 then
        self.savedVars.interaction.subtitles.posX = 0.5
    end
    -- Migrate hideCompass from boolean to string
    if type(self.savedVars.interface.hideCompass) == "boolean" then
        self.savedVars.interface.hideCompass = self.savedVars.interface.hideCompass and "never" or "always"
    end

    -- Migrate hideReticle from boolean to string
    if type(self.savedVars.interface.hideReticle) == "boolean" then
        self.savedVars.interface.hideReticle = self.savedVars.interface.hideReticle and "never" or "always"
    end

    -- Migrate hideActionBar from boolean to string
    if type(self.savedVars.interface.hideActionBar) == "boolean" then
        self.savedVars.interface.hideActionBar = self.savedVars.interface.hideActionBar and "never" or "always"
    end

    -- Prevent settings errors from removed emote packs
    if not self.savedVars.emoteWheelVersion or self.savedVars.emoteWheelVersion < 1 then
        self.savedVars.emoteWheel = {
            slot1 = "friendly",
            slot2 = "confused",
            slot3 = "greeting",
            slot4 = "idle"
        }
        self.savedVars.emoteWheelVersion = 2
    end

    if self.savedVars.interaction.forceThirdPersonVendor == true then
        self.savedVars.interaction.forceThirdPersonVendor = false
    end

    if self.savedVars.interaction.forceThirdPersonBank == true then
        self.savedVars.interaction.forceThirdPersonBank = false
    end



    CinematicCam:InitializeInteractionSettings()
end

function CinematicCam:UpdateKeybindStripVisibility()
    -- only hide in dialogue interactions. called by OnInteractionStart
    if not self.savedVars.interface.keybindIsHidden then
        return
    end
    local keybindControl = _G["ZO_KeybindStripControlCenterParent"]
    local gamepadBackground = _G["ZO_KeybindStripGamepadBackgroundTexture"]

    if self.savedVars.interface.hideKeybindStrip then
        -- Hide keyboard keybind strip
        if keybindControl then
            keybindControl:ClearAnchors()
            keybindControl:SetAnchor(TOP, GuiRoot, TOP, 0, -5000)
            keybindControl:SetHidden(true)
        end

        -- Hide gamepad background
        if gamepadBackground then
            gamepadBackground:SetHidden(true)
        end
    else
        -- Show keyboard keybind strip
        if keybindControl then
            keybindControl:ClearAnchors()
            keybindControl:SetAnchor(BOTTOM, GuiRoot, BOTTOM, 0, -20)
            keybindControl:SetHidden(false)
        end

        -- Show gamepad background
        if gamepadBackground then
            gamepadBackground:SetHidden(false)
        end
    end
end

function CinematicCam:RestoreKeybindStripVisibility()
    -- Restore when leaving dialogue. called by OnInteractionEnd
    local gamepadBackground = _G["ZO_KeybindStripGamepadBackgroundTexture"]

    if gamepadBackground then
        gamepadBackground:SetHidden(false)
    end
end

---=============================================================================
-- Update System
--=============================================================================
function CinematicCam:InitializeUpdateSystem()
    if not self.savedVars then
        zo_callLater(function()
            CinematicCam:InitializeUpdateSystem()
        end, 1000)
        return
    end
    -- Check for updates
    CinematicCam:CheckForUpdates()
end

function CinematicCam:CheckForUpdates()
    -- Don't show during initial loading screen
    if not GetWorldName() or GetWorldName() == "" then
        -- Wait for world to load, then check
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_UpdateCheck", EVENT_PLAYER_ACTIVATED, function()
            EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_UpdateCheck", EVENT_PLAYER_ACTIVATED)
            zo_callLater(function()
                CinematicCam:DetermineNotificationType()
            end, 2000)
        end)
        return
    end

    CinematicCam:DetermineNotificationType()
end

function CinematicCam:IsNewerVersion(current, last)
    if last == "0.0.0" then return true end

    local currentParts = {}
    local lastParts = {}

    for num in current:gmatch("(%d+)") do
        table.insert(currentParts, tonumber(num))
    end

    for num in last:gmatch("(%d+)") do
        table.insert(lastParts, tonumber(num))
    end

    -- Compare major, minor, patch
    for i = 1, math.max(#currentParts, #lastParts) do
        local currentNum = currentParts[i] or 0
        local lastNum = lastParts[i] or 0

        if currentNum > lastNum then
            return true
        elseif currentNum < lastNum then
            return false
        end
    end

    return false
end

function CinematicCam:ShowUpdateNotificationUI()
    local notification = _G["CinematicCam_UpdateNotification"]
    local notificationText = _G["CinematicCam_UpdateNotificationText"]
    if not notification then
        return
    end

    notification:SetHidden(false)
    notification:SetAlpha(0)
    notificationText:SetText(
        "Cinematic Dialogue Updated.\nTip: Download LibRadialMenu to add commands to quickslot menu ")

    -- Start fade in animation
    CinematicCam:AnimateUpdateNotification(notification, true)

    -- Auto-hide after 5 seconds
    zo_callLater(function()
        CinematicCam:HideUpdateNotification()
    end, 7000)
end

function CinematicCam:ShowWelcomeNotificationUI()
    if self.savedVars.hasSeenWelcomeMessage then
        return
    end
    local notification = _G["CinematicCam_UpdateNotification"]
    local notificationText = _G["CinematicCam_UpdateNotificationText"]
    if not notification then
        return
    end

    notification:SetHidden(false)
    notification:SetAlpha(0)
    notificationText:SetText(
        "|cFFD700Cinematic Dialogue|r \n|cFFFFFFTry it out by talking to an NPC|r\n|cE0E0E0Check the settings menu for more customization options|r")

    -- Start fade in animation
    CinematicCam:AnimateUpdateNotification(notification, true)

    -- Auto-hide after 5 seconds
    zo_callLater(function()
        CinematicCam:HideUpdateNotification()
    end, 10000)
    self.savedVars.hasSeenWelcomeMessage = true
end

function CinematicCam:ShowPresetNotificationUI(slotName)
    local notification = _G["CinematicCam_UpdateNotification"]
    local notificationText = _G["CinematicCam_UpdateNotificationText"]
    if not notification then
        return
    end

    notification:SetHidden(false)
    notification:SetAlpha(0)
    notificationText:SetText("Cinematic Dialogue: " .. slotName)

    -- Start fade in animation
    CinematicCam:AnimateUpdateNotification(notification, true)

    -- Auto-hide after 5 seconds
    zo_callLater(function()
        CinematicCam:HideUpdateNotification()
    end, 6000)
end

function CinematicCam:HideUpdateNotification()
    local notification = _G["CinematicCam_UpdateNotification"]
    local notificationText = _G["CinematicCam_UpdateNotificationText"]
    if not notification then
        return
    end

    -- Start fade out animation
    CinematicCam:AnimateUpdateNotification(notification, false)

    zo_callLater(function()
        if notification then
            notification:SetHidden(true)
        end
    end, 350)

    zo_callLater(function()
        notificationText:SetText(self:CC_L("UPDATE_NOTIFICATION_RADIAL_TIP"))
    end, 400)
end

-- Animate notification
function CinematicCam:AnimateUpdateNotification(control, fadeIn)
    if not control then
        return
    end


    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local animation = timeline:InsertAnimation(ANIMATION_ALPHA, control)

    if fadeIn then
        animation:SetAlphaValues(0, 1)
        control:SetAlpha(0)
    else
        animation:SetAlphaValues(control:GetAlpha(), 0)
    end

    animation:SetDuration(300)
    animation:SetEasingFunction(ZO_EaseOutQuadratic)

    timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
    timeline:PlayFromStart()
end

function CinematicCam:DetermineNotificationType()
    local lastSeenVersion = self.savedVars.lastSeenUpdateVersion or "0.0.0"
    local hasSeenWelcome = self.savedVars.hasSeenWelcomeMessage or false

    -- Compare versions
    if CinematicCam:IsNewerVersion(CURRENT_VERSION, lastSeenVersion) then
        -- Determine if this is a first install or update
        local isFirstInstall = (lastSeenVersion == "0.0.0" and not hasSeenWelcome)

        if isFirstInstall then
            CinematicCam:ShowWelcomeNotificationUI()
        else
            CinematicCam:ShowUpdateNotificationUI()
            -- Set flag that user needs to reload to clear update indicators
            self.savedVars.hasReloadedSinceUpdate = false
        end

        -- Mark this version as seen
        self.savedVars.lastSeenUpdateVersion = CURRENT_VERSION
        self.savedVars.hasSeenWelcomeMessage = true
    else
        local notification = _G["CinematicCam_UpdateNotification"]
        if notification then
            notification:SetHidden(true)
        end
    end
end

---=============================================================================
-- Scene Management System
--=============================================================================
function CinematicCam:RegisterSceneHiddenCallbacks()
    local scenesToWatch = {
        "gamepad_store",
        "gamepad_housing_furniture_scene",
        "housingEditorHud",
        "hudui",
        "gamepadMainMenu",
        "hud",
        "gamepad_banking",
        "gamepad_WorldMap",
        "gamepadChatMenu"
    }

    for _, sceneName in ipairs(scenesToWatch) do
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene then
            scene:RegisterCallback("StateChange", function(oldState, newState)
                if newState == SCENE_SHOWN then
                    CinematicCam:OnTargetSceneShown(sceneName)
                elseif newState == SCENE_HIDDEN then
                    CinematicCam:OnTargetSceneHidden(sceneName)
                end
            end)
        end
    end
end

function CinematicCam:OnTargetSceneShown(sceneName)
    if sceneName == "gamepad_store" then
        CinematicCam:StopGamepadStickPoll()
    elseif sceneName == "gamepad_housing_furniture_scene" then
        CinematicCam:StopGamepadStickPoll()
    elseif sceneName == "housingEditorHud" then
        CinematicCam:StopGamepadStickPoll()
    elseif sceneName == "hudui" then
        if CinematicCam.isInteractionModified then
            SetGameCameraUIMode(CinematicCam.CAMERA_MODE.FREE)
        end
        zo_callLater(function()
            CinematicCam:ToggleUI()
        end, 800)

        -- mark when menu is opened so StopGamepadStickPoll doesn't override
    elseif sceneName == "gamepadMainMenu" then
        CinematicCam.isMenuActive = true
        CinematicCam:StopGamepadStickPoll()
    elseif sceneName == "gamepad_banking" then
        CinematicCam:StopGamepadStickPoll()
    end
end

function CinematicCam:OnTargetSceneHidden(sceneName)
    if sceneName == "gamepad_store" then
        SetGameCameraUIMode(CinematicCam.CAMERA_MODE.FREE)
    elseif sceneName == "gamepad_housing_furniture_scene" then
        SetGameCameraUIMode(CinematicCam.CAMERA_MODE.FREE)
    elseif sceneName == "housingEditorHud" then
        SetGameCameraUIMode(CinematicCam.CAMERA_MODE.FREE)
    elseif sceneName == "hudui" then
        if not CinematicCam.isInteractionModified then
            SetGameCameraUIMode(CinematicCam.CAMERA_MODE.FREE)
        end
    elseif sceneName == "gamepadMainMenu" then
        -- Menu is closing - safe to reset
        CinematicCam.isMenuActive = false
        CinematicCam.isInteractionModified = false

        SetGameCameraUIMode(CinematicCam.CAMERA_MODE.FREE)
    elseif sceneName == "gamepad_banking" then
        CinematicCam:StopGamepadStickPoll()
    end
end

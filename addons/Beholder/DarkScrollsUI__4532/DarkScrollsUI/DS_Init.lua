-----------------------------------------------------------
-- DarkScrollsUI - DS_Init.lua
-- Addon initialization: EVENT_ADD_ON_LOADED handler,
-- SavedVars loading, profile migration, slash commands,
-- control creation, and main update loops.
-----------------------------------------------------------

local function OnLoaded(_, name)
    if name ~= DarkScrollsUI.AddonNameIdentifier then return end

    EVENT_MANAGER:UnregisterForEvent(DarkScrollsUI.AddonNameIdentifier, EVENT_ADD_ON_LOADED)

    -----------------------------------------------------------
    -- SAVED VARIABLES & PROFILES
    -----------------------------------------------------------
    DarkScrollsUI.MasterSavedVariables = ZO_SavedVars:NewAccountWide("DarkScrollsUIVars", 1, GetWorldName(), {})

    if type(DarkScrollsUI.MasterSavedVariables.currentProfile) ~= "number" then
        DarkScrollsUI.MasterSavedVariables.currentProfile = 1
    end

    -- Migrate legacy installations (no profile system)
    if type(DarkScrollsUI.MasterSavedVariables.profiles) ~= "table" then
        DarkScrollsUI.MasterSavedVariables.profiles = {}
        local legacyProfile = {}
        for k, v in pairs(DarkScrollsUI.MasterSavedVariables) do
            if k ~= "profiles" and k ~= "currentProfile" then
                legacyProfile[k] = type(v) == "table" and ZO_DeepTableCopy(v) or v
            end
        end
        if next(legacyProfile) ~= nil then DarkScrollsUI.MasterSavedVariables.profiles[1] = legacyProfile end
    end

    -- Ensure all 5 profiles exist
    for i = 1, 5 do
        if type(DarkScrollsUI.MasterSavedVariables.profiles[i]) ~= "table" then
            DarkScrollsUI.MasterSavedVariables.profiles[i] = DarkScrollsUI.GetDefaultProfileSettings()
        end
    end

    DarkScrollsUI.SavedVariables = DarkScrollsUI.MasterSavedVariables.profiles[DarkScrollsUI.MasterSavedVariables.currentProfile]

    -- Migrate missing boolean settings (safe defaults for existing profiles)
    if DarkScrollsUI.SavedVariables.graySkillsEnabled        == nil then DarkScrollsUI.SavedVariables.graySkillsEnabled        = true  end
    if DarkScrollsUI.SavedVariables.graySaturation            == nil then DarkScrollsUI.SavedVariables.graySaturation            = 0.15  end
    if DarkScrollsUI.SavedVariables.grayUltSaturation         == nil then DarkScrollsUI.SavedVariables.grayUltSaturation         = 0.90  end
    if DarkScrollsUI.SavedVariables.customQuestTrackerEnabled == nil then DarkScrollsUI.SavedVariables.customQuestTrackerEnabled = true  end
    if DarkScrollsUI.SavedVariables.damageFlashEnabled        == nil then DarkScrollsUI.SavedVariables.damageFlashEnabled        = true  end
    if DarkScrollsUI.SavedVariables.damageFlashLightZoomDistance == nil then DarkScrollsUI.SavedVariables.damageFlashLightZoomDistance = 0.4   end
    if DarkScrollsUI.SavedVariables.damageFlashLightZoomReturn   == nil then DarkScrollsUI.SavedVariables.damageFlashLightZoomReturn   = 600   end
    if DarkScrollsUI.SavedVariables.damageFlashHeavyZoomDistance == nil then DarkScrollsUI.SavedVariables.damageFlashHeavyZoomDistance = 1.0   end
    if DarkScrollsUI.SavedVariables.damageFlashHeavyZoomReturn   == nil then DarkScrollsUI.SavedVariables.damageFlashHeavyZoomReturn   = 1000  end

    -----------------------------------------------------------
    -- SLASH COMMANDS
    -----------------------------------------------------------
    SLASH_COMMANDS["/ds"] = function()
        DarkScrollsUI.DisplayProfileSystemMessage("|c00aaff[Edit]|r Editing Profile " .. DarkScrollsUI.MasterSavedVariables.currentProfile)
        DarkScrollsUI.ToggleInterfaceLockStatus()
    end

    SLASH_COMMANDS["/dsreset"] = DarkScrollsUI.ResetAllAttributeBars
    SLASH_COMMANDS["/dsall"]   = DarkScrollsUI.ToggleGlobalEditModeActive
    SLASH_COMMANDS["/dsflash"] = DarkScrollsUI.TestDamageFlashEffect

    for i = 1, 5 do
        SLASH_COMMANDS["/ds"..i] = function()
            if DarkScrollsUI.MasterSavedVariables.currentProfile ~= i then
                DarkScrollsUI.MasterSavedVariables.currentProfile = i
                DarkScrollsUI.SavedVariables = DarkScrollsUI.MasterSavedVariables.profiles[i]
                DarkScrollsUI.DisplayProfileSystemMessage("|c00FF00[Loading]|r Applying Profile " .. i)
                zo_callLater(function() ReloadUI() end, 1000)
            else
                DarkScrollsUI.DisplayProfileSystemMessage("|cFFFF00Profile " .. i .. " is already active!|r")
            end
        end
    end

    -----------------------------------------------------------
    -- SETTINGS MENU (LAM)
    -----------------------------------------------------------
    DarkScrollsUI.BuildAddonSettingsMenu()

    -- Initialise the damage flash overlay (DS_DamageFlash.lua)
    DarkScrollsUI.InitDamageFlash()

    -----------------------------------------------------------
    -- HIDE NATIVE ESO HUD ELEMENTS
    -----------------------------------------------------------
    local function Hide(c) if c then c:SetHidden(true) c:SetAlpha(0) end end
    Hide(ZO_PlayerAttributeHealth)
    Hide(ZO_PlayerAttributeMagicka)
    Hide(ZO_PlayerAttributeStamina)
    Hide(ZO_PlayerAttributeMountStamina)

    -- Quest tracker: the native hook and fragment removal are applied only
    -- when the custom tracker is enabled. DarkScrollsUI.ApplyQuestTrackerDisplaySetting()
    -- (defined in DS_Core.lua) handles both states after controls are created.
    --
    -- We install a pre-hook here so the game cannot re-show the native tracker
    -- while our custom one is active. The hook checks the live setting each call,
    -- so toggling via the menu takes effect immediately without a reload.
    if ZO_FocusedQuestTrackerPanel then
        ZO_PreHook(ZO_FocusedQuestTrackerPanel, "SetHidden", function(_, hidden)
            -- Block any attempt by the game to show the native tracker while
            -- our custom tracker is enabled.
            if not hidden and DarkScrollsUI.SavedVariables and DarkScrollsUI.SavedVariables.customQuestTrackerEnabled then
                return true -- returning true cancels the original call
            end
        end)
    end

    -- Conditionally block native boss bar (only when our boss bar is active)
    local function ShouldHideNative() return DarkScrollsUI.isCustomBossBarActive end

    if ZO_BossBar then
        ZO_PreHook(ZO_BossBar, "SetHidden", function(self, hidden) if not hidden and ShouldHideNative() then return true end end)
    end

    if ZO_CompassCenterOverlays then
        ZO_PreHook(ZO_CompassCenterOverlays, "SetHidden", function(self, hidden) if not hidden and ShouldHideNative() then return true end end)
    end

    if ZO_ActionBar1 then
        Hide(ZO_ActionBar1)
        ZO_PreHook(ZO_ActionBar1, "SetHidden", function(_, hidden) if not hidden then return true end end)
    end

    -- Custom target bar (replaces ZO_TargetUnitFramereticleover)
    if DarkScrollsUI.InitTargetBar then DarkScrollsUI.InitTargetBar() end

    -----------------------------------------------------------
    -- CREATE ATTRIBUTE BARS
    -----------------------------------------------------------
    local function BarColor(id)
        local data = DarkScrollsUI.SavedVariables[id]
        return (data and data.color) or DarkScrollsUI.GetDefaultProfileSettings()[id].color
    end

    local function MakeBar(id, attr)
        local c = BarColor(id)
        local defaultPos = DarkScrollsUI.SavedVariables[id] or DarkScrollsUI.GetDefaultProfileSettings()[id]
        DarkScrollsUI.CreateAttributeResourceBar(id, {c.r*0.3, c.g*0.3, c.b*0.3, 1}, {c.r, c.g, c.b, 1}, attr, defaultPos)
    end

    MakeBar("DarkScrollsUI_PlayerHealthBar",        POWERTYPE_HEALTH)
    MakeBar("DarkScrollsUI_PlayerMagickaBar",     POWERTYPE_MAGICKA)
    MakeBar("DarkScrollsUI_PlayerStaminaBar",     POWERTYPE_STAMINA)
    MakeBar("DarkScrollsUI_PlayerShieldBar",      "SHIELD")
    MakeBar("DarkScrollsUI_PlayerMountStaminaBar", POWERTYPE_MOUNT_STAMINA)

    -----------------------------------------------------------
    -- CREATE SKILL ICONS & QUICKSLOT
    -----------------------------------------------------------
    local defaultProfile = DarkScrollsUI.GetDefaultProfileSettings()
    local actionSlotNames = {
        [3] = "DarkScrollsUI_ActionButtonSlotThree",
        [4] = "DarkScrollsUI_ActionButtonSlotFour",
        [5] = "DarkScrollsUI_ActionButtonSlotFive",
        [6] = "DarkScrollsUI_ActionButtonSlotSix",
        [7] = "DarkScrollsUI_ActionButtonSlotSeven",
        [8] = "DarkScrollsUI_UltimateAbilitySlot",
    }

    for i = 3, 8 do
        local slotName = actionSlotNames[i]
        DarkScrollsUI.CreateActionButtonIcon(i, slotName, defaultProfile[slotName])
    end
    DarkScrollsUI.CreateActionButtonIcon("Quickslot", "DarkScrollsUI_QuickslotItemSlot", defaultProfile["DarkScrollsUI_QuickslotItemSlot"])

    -----------------------------------------------------------
    -- CREATE BUFF / DEBUFF TRACKERS
    -----------------------------------------------------------
    DarkScrollsUI.CreateBuffTrackerUserInterface("DarkScrollsUI_PlayerBuffTracker", defaultProfile["DarkScrollsUI_PlayerBuffTracker"])
    DarkScrollsUI.CreateBuffTrackerUserInterface("DarkScrollsUI_TargetBuffTracker", defaultProfile["DarkScrollsUI_TargetBuffTracker"])

    -----------------------------------------------------------
    -- CREATE WEAPON ICONS
    -----------------------------------------------------------
    DarkScrollsUI.CreateWeaponIndicatorIcon("DarkScrollsUI_PrimaryWeaponIndicator",   defaultProfile["DarkScrollsUI_PrimaryWeaponIndicator"])
    DarkScrollsUI.CreateWeaponIndicatorIcon("DarkScrollsUI_SecondaryWeaponIndicator", defaultProfile["DarkScrollsUI_SecondaryWeaponIndicator"])
    DarkScrollsUI.UpdateWeaponIndicatorIcons()

    -----------------------------------------------------------
    -- CREATE COMPASS
    -----------------------------------------------------------
    DarkScrollsUI.CreateCompassUserInterface("DarkScrollsUI_CompassNavigationFrame", defaultProfile["DarkScrollsUI_CompassNavigationFrame"])

    -----------------------------------------------------------
    -- CREATE BOSS BAR
    -----------------------------------------------------------
    if DarkScrollsUI.CreateCustomBossBarHealthBar then DarkScrollsUI.CreateCustomBossBarHealthBar() end

    -----------------------------------------------------------
    -- CREATE QUEST TRACKER
    -----------------------------------------------------------
    if DarkScrollsUI.CreateQuestTrackerDisplay then DarkScrollsUI.CreateQuestTrackerDisplay() end

    -----------------------------------------------------------
    -- APPLY QUEST TRACKER SETTING
    -- Must run after DarkScrollsUI.CreateQuestTrackerDisplay() so DarkScrollsUI.QuestTrackerDisplay exists.
    -- Handles both the enabled (hide native) and disabled (hide custom) paths.
    -----------------------------------------------------------
    DarkScrollsUI.ApplyQuestTrackerDisplaySetting()

    -----------------------------------------------------------
    -- CREATE GROUP FRAME
    -----------------------------------------------------------
    if DarkScrollsUI.CreatePvPGroupFrameDisplay then DarkScrollsUI.CreatePvPGroupFrameDisplay() end

    -----------------------------------------------------------
    -- HUD SCENE INTEGRATION
    -- Registers all controls as scene fragments so they
    -- automatically hide when any menu (inventory, map, etc.)
    -- is opened and reappear when the player returns to gameplay.
    -----------------------------------------------------------
    local function RegisterHUDFragment(ctrl)
        if not ctrl then return end
        local fragment = ZO_HUDFadeSceneFragment:New(ctrl)
        HUD_SCENE:AddFragment(fragment)
        HUD_UI_SCENE:AddFragment(fragment)

        -- Also show controls while the LAM settings panel is open
        local lamScene = SCENE_MANAGER:GetScene("gameMenuInGame")
        if lamScene then
            lamScene:AddFragment(fragment)
        end

        ctrl.DarkScrollsUI_HUDFragment = fragment
    end

    RegisterHUDFragment(_G["DarkScrollsUI_PlayerHealthBar"])
    RegisterHUDFragment(_G["DarkScrollsUI_PlayerMagickaBar"])
    RegisterHUDFragment(_G["DarkScrollsUI_PlayerStaminaBar"])
    RegisterHUDFragment(_G["DarkScrollsUI_PlayerShieldBar"])
    RegisterHUDFragment(_G["DarkScrollsUI_PlayerMountStaminaBar"])

    for i = 3, 7 do RegisterHUDFragment(_G["DarkScrollsUI_ActionButtonSlot"..(({"Three","Four","Five","Six","Seven"})[i-2])]) end
    RegisterHUDFragment(_G["DarkScrollsUI_UltimateAbilitySlot"])
    RegisterHUDFragment(_G["DarkScrollsUI_QuickslotItemSlot"])

    RegisterHUDFragment(_G["DarkScrollsUI_PlayerBuffTracker"])
    RegisterHUDFragment(_G["DarkScrollsUI_TargetBuffTracker"])

    RegisterHUDFragment(_G["DarkScrollsUI_PrimaryWeaponIndicator"])
    RegisterHUDFragment(_G["DarkScrollsUI_SecondaryWeaponIndicator"])

    RegisterHUDFragment(_G["DarkScrollsUI_CompassNavigationFrame"])

    RegisterHUDFragment(_G["DarkScrollsUI_TargetHealthBar"])

    -- DS_BossBar manages its own visibility; do not register here.
    -- The custom quest tracker fragment is registered only when enabled;
    -- DarkScrollsUI.ApplyQuestTrackerDisplaySetting() above already handled its visibility.
    if DarkScrollsUI.QuestTrackerDisplay and DarkScrollsUI.SavedVariables.customQuestTrackerEnabled then
        RegisterHUDFragment(DarkScrollsUI.QuestTrackerDisplay)
    end
    if DarkScrollsUI.PlayerGroupFrameDisplay then RegisterHUDFragment(DarkScrollsUI.PlayerGroupFrameDisplay) end

    -----------------------------------------------------------
    -- WEAPON SWAP EVENTS
    -----------------------------------------------------------
    EVENT_MANAGER:RegisterForEvent(DarkScrollsUI.AddonNameIdentifier .. "_WeapSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function()
        DarkScrollsUI.UpdateWeaponIndicatorIcons()
    end)

    EVENT_MANAGER:RegisterForEvent(DarkScrollsUI.AddonNameIdentifier .. "_WeapEquip", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId, slotId)
        if bagId == BAG_WORN and (slotId == EQUIP_SLOT_MAIN_HAND or slotId == EQUIP_SLOT_BACKUP_MAIN) then
            DarkScrollsUI.UpdateWeaponIndicatorIcons()
        end
    end)

    -----------------------------------------------------------
    -- PLAYER ACTIVATED: fix compass and force-read bar values
    -----------------------------------------------------------
    EVENT_MANAGER:RegisterForEvent(DarkScrollsUI.AddonNameIdentifier .. "_Ready", EVENT_PLAYER_ACTIVATED, function()
        if DarkScrollsUI.UpdateCompassElementAnchors then DarkScrollsUI.UpdateCompassElementAnchors() end

        local hp,   maxHp   = GetUnitPower("player", POWERTYPE_HEALTH)
        local mag,  maxMag  = GetUnitPower("player", POWERTYPE_MAGICKA)
        local stam, maxStam = GetUnitPower("player", POWERTYPE_STAMINA)

        if _G["DarkScrollsUI_PlayerHealthBar"]    then DarkScrollsUI.UpdateAttributeBarFillValue(_G["DarkScrollsUI_PlayerHealthBar"],    POWERTYPE_HEALTH,  hp,   maxHp)   end
        if _G["DarkScrollsUI_PlayerMagickaBar"] then DarkScrollsUI.UpdateAttributeBarFillValue(_G["DarkScrollsUI_PlayerMagickaBar"], POWERTYPE_MAGICKA, mag,  maxMag)  end
        if _G["DarkScrollsUI_PlayerStaminaBar"] then DarkScrollsUI.UpdateAttributeBarFillValue(_G["DarkScrollsUI_PlayerStaminaBar"], POWERTYPE_STAMINA, stam, maxStam) end

        if _G["DarkScrollsUI_PlayerMountStaminaBar"] and IsMounted() then
            local mountStam, mountMaxStam = GetUnitPower("player", POWERTYPE_MOUNT_STAMINA)
            DarkScrollsUI.UpdateAttributeBarFillValue(_G["DarkScrollsUI_PlayerMountStaminaBar"], POWERTYPE_MOUNT_STAMINA, mountStam, mountMaxStam)
        end
    end)

    -----------------------------------------------------------
    -- SKILL USE EVENT: visual feedback flash
    -----------------------------------------------------------
    EVENT_MANAGER:RegisterForEvent(DarkScrollsUI.AddonNameIdentifier .. "_SkillUsed", EVENT_ACTION_SLOT_ABILITY_USED, function(_, slotId)
        if slotId >= 3 and slotId <= 8 then
            local actionSlotNames = {
                [3] = "DarkScrollsUI_ActionButtonSlotThree",
                [4] = "DarkScrollsUI_ActionButtonSlotFour",
                [5] = "DarkScrollsUI_ActionButtonSlotFive",
                [6] = "DarkScrollsUI_ActionButtonSlotSix",
                [7] = "DarkScrollsUI_ActionButtonSlotSeven",
                [8] = "DarkScrollsUI_UltimateAbilitySlot",
            }
            local btn = _G[actionSlotNames[slotId]]
            if btn then btn.lastUsedTime = GetFrameTimeSeconds() end
        end
    end)

    -----------------------------------------------------------
    -- PER-FRAME BAR ANIMATION LOOP
    -----------------------------------------------------------
    EVENT_MANAGER:RegisterForUpdate(DarkScrollsUI.AddonNameIdentifier .. "_Bars", 0, DarkScrollsUI.TickAllAttributeBars)

    -----------------------------------------------------------
    -- 100ms UPDATE LOOP (skills, quickslot, buffs, HUD fade)
    -----------------------------------------------------------
    DarkScrollsUI.globalInterfaceFadeAlpha   = 1.0
    DarkScrollsUI.hudAlphaHookSetupCompleted  = false

    DarkScrollsUI.currentInterfaceFadeState     = "VISIBLE"
    DarkScrollsUI.interfaceFadeWaitStartTime = 0
    DarkScrollsUI.interfaceFadeAnimationStartTime = 0
    DarkScrollsUI.lastObservedWeaponPairIndex = GetActiveWeaponPairInfo()

    EVENT_MANAGER:RegisterForUpdate(DarkScrollsUI.AddonNameIdentifier, 100, function()

        -- One-time alpha hook setup for all registered controls
        if not DarkScrollsUI.hudAlphaHookSetupCompleted and DarkScrollsUI.SavedVariables then
            local allHooked = true
            for name, data in pairs(DarkScrollsUI.SavedVariables) do
                if type(data) == "table" and data.a then
                    local ctrl = _G[name]
                    if ctrl and type(ctrl) == "userdata" and ctrl.SetAlpha then
                        if not ctrl.DarkScrollsUI_AlphaHookApplied then
                            ctrl.DarkScrollsUI_AlphaHookApplied = true
                            ctrl.DarkScrollsUI_OriginalSetAlpha = ctrl.SetAlpha
                            ctrl.SetAlpha = function(self, alpha)
                                self.DarkScrollsUI_OriginalSetAlpha(self, alpha * DarkScrollsUI.globalInterfaceFadeAlpha)
                            end
                            ctrl:SetAlpha(data.a)
                        end
                    else
                        allHooked = false
                    end
                end
            end
            if allHooked then DarkScrollsUI.hudAlphaHookSetupCompleted = true end
        end

        -- Weapon swap detection (triggers immediate HUD visibility)
        local currentPair  = GetActiveWeaponPairInfo()
        local weaponSwapped = false
        if DarkScrollsUI.lastObservedWeaponPairIndex ~= currentPair then
            weaponSwapped      = true
            DarkScrollsUI.lastObservedWeaponPairIndex  = currentPair
        end

        -- Player state detection for auto-fade
        local inCombat        = IsUnitInCombat("player")
        local isEditing       = not DarkScrollsUI.isInterfaceLocked or DarkScrollsUI.isGlobalEditModeActive or DarkScrollsUI.isSettingsMenuOpen
        local isBlocking      = IsBlockActive()
        local isMoving        = IsPlayerMoving()
        local isMounted       = IsMounted()

        local health, maxHealth   = GetUnitPower("player", POWERTYPE_HEALTH)
        local magicka, maxMagicka = GetUnitPower("player", POWERTYPE_MAGICKA)
        local stamina, maxStamina = GetUnitPower("player", POWERTYPE_STAMINA)
        local missingResources    = (health < maxHealth) or (magicka < maxMagicka) or (stamina < maxStamina)

        if isMounted then
            local curMS, maxMS = GetUnitPower("player", POWERTYPE_MOUNT_STAMINA)
            if curMS < maxMS then missingResources = true end
        end

        local shouldBeVisible = (isEditing or inCombat or isBlocking or missingResources or isMoving)

        -- Fade state machine
        local now           = GetGameTimeMilliseconds()
        local previousAlpha = DarkScrollsUI.globalInterfaceFadeAlpha

        if weaponSwapped then
            DarkScrollsUI.currentInterfaceFadeState      = "VISIBLE"
            DarkScrollsUI.globalInterfaceFadeAlpha = 1.0
        end

        if shouldBeVisible then
            if DarkScrollsUI.currentInterfaceFadeState ~= "VISIBLE" then
                DarkScrollsUI.currentInterfaceFadeState       = "VISIBLE"
                DarkScrollsUI.globalInterfaceFadeAlpha = 1.0
            end
        else
            if DarkScrollsUI.currentInterfaceFadeState == "VISIBLE" then
                DarkScrollsUI.currentInterfaceFadeState      = "WAITING"
                DarkScrollsUI.interfaceFadeWaitStartTime  = now

            elseif DarkScrollsUI.currentInterfaceFadeState == "WAITING" then
                -- Wait 20 seconds before starting to fade
                if now - DarkScrollsUI.interfaceFadeWaitStartTime >= 20000 then
                    DarkScrollsUI.currentInterfaceFadeState      = "FADING"
                    DarkScrollsUI.interfaceFadeAnimationStartTime  = now
                end

            elseif DarkScrollsUI.currentInterfaceFadeState == "FADING" then
                -- Fade from 100% to 10% over 500ms
                local elapsed  = now - DarkScrollsUI.interfaceFadeAnimationStartTime
                local progress = math.min(1, elapsed / 500)
                DarkScrollsUI.globalInterfaceFadeAlpha = 1.0 - (0.9 * progress)
                if progress >= 1 then
                    DarkScrollsUI.currentInterfaceFadeState       = "HIDDEN"
                    DarkScrollsUI.globalInterfaceFadeAlpha = 0.1
                end
            end
        end

        -- Apply alpha changes only when value changed this frame
        if DarkScrollsUI.globalInterfaceFadeAlpha ~= previousAlpha then
            if DarkScrollsUI.SavedVariables then
                for name, data in pairs(DarkScrollsUI.SavedVariables) do
                    -- The custom boss bar manages its own alpha; exclude it from global fade
                    if name ~= "DarkScrollsUI_BossHealthBarDisplay" then
                        local ctrl = _G[name]
                        if ctrl and ctrl.DarkScrollsUI_AlphaHookApplied and data.a then
                            ctrl:SetAlpha(data.a)
                        end
                    end
                end
            end

            if DarkScrollsUI.UpdateWeaponIndicatorIcons then DarkScrollsUI.UpdateWeaponIndicatorIcons() end
        end

        local mountBar = _G["DarkScrollsUI_PlayerMountStaminaBar"]
        if mountBar then
            local targetHidden = not isEditing and (IsReticleHidden() or not isMounted)
            if mountBar:IsHidden() ~= targetHidden then
                mountBar:SetHidden(targetHidden)
            end
        end

        -- Per-frame skill, quickslot, and buff updates
        local actionSlotNames = {
            [3] = "DarkScrollsUI_ActionButtonSlotThree",
            [4] = "DarkScrollsUI_ActionButtonSlotFour",
            [5] = "DarkScrollsUI_ActionButtonSlotFive",
            [6] = "DarkScrollsUI_ActionButtonSlotSix",
            [7] = "DarkScrollsUI_ActionButtonSlotSeven",
            [8] = "DarkScrollsUI_UltimateAbilitySlot",
        }
        for i = 3, 8 do
            local btn = _G[actionSlotNames[i]]
            if btn then DarkScrollsUI.UpdateSkillIconVisualStatus(btn, i) end
        end

        local quickBtn = _G["DarkScrollsUI_QuickslotItemSlot"]
        if quickBtn then DarkScrollsUI.UpdateQuickslotIconVisualStatus(quickBtn) end

        DarkScrollsUI.UpdateBuffTrackerInformation(_G["DarkScrollsUI_PlayerBuffTracker"], "player")
        DarkScrollsUI.UpdateBuffTrackerInformation(_G["DarkScrollsUI_TargetBuffTracker"], "reticleover")

        -- Only update the custom quest tracker when it is enabled
        if DarkScrollsUI.SavedVariables.customQuestTrackerEnabled and DarkScrollsUI.UpdateQuestTrackerInformation then
            DarkScrollsUI.UpdateQuestTrackerInformation()
        end

        if DarkScrollsUI.UpdatePvPGroupMemberInformation then DarkScrollsUI.UpdatePvPGroupMemberInformation() end
    end)
end

EVENT_MANAGER:RegisterForEvent(DarkScrollsUI.AddonNameIdentifier, EVENT_ADD_ON_LOADED, OnLoaded)

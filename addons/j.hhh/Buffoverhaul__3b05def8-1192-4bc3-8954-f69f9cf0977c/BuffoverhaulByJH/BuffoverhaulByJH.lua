-- Buffoverhaul by JH
-- v0.2.2-console
-- Minimal patch on top of ESO's built-in buff/debuff UI.

local ADDON_NAME = "BuffoverhaulByJH"

local function PatchAuraIcon(control)
    if not control then return end

    local duration = control.duration or control:GetNamedChild("Duration")
    local icon = control:GetNamedChild("Icon")
    if duration and icon then
        duration:ClearAnchors()
        duration:SetAnchor(CENTER, icon, CENTER, 0, 0)
        duration:SetDimensions(icon:GetWidth(), icon:GetHeight())
        duration:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        duration:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        duration:SetFont("ZoFontGamepadBold20")
    end

    -- This is ESO's own cooldown control. BuffDebuffStyles.lua drives it.
    control.showCooldown = true
end

local function InstallIconHook()
    if not ZO_BuffDebuffStyleObject or not ZO_BuffDebuffStyleObject.SetupIcon then
        return false
    end
    ZO_PostHook(ZO_BuffDebuffStyleObject, "SetupIcon", function(_, control)
        PatchAuraIcon(control)
    end)
    return true
end

-- Re-synchronise the native reticleover container from the already working
-- player container. We keep ESO's original pools, templates, sorting and
-- GetUnitBuffInfo("reticleover") path; no custom target bar is created.
local function RepairNativeTargetContainer()
    if not BUFF_DEBUFF or not BUFF_DEBUFF.containerObjectsByUnitTag then return end

    local player = BUFF_DEBUFF.containerObjectsByUnitTag["player"]
    local target = BUFF_DEBUFF.containerObjectsByUnitTag["reticleover"]
    if not player or not target then return end

    -- The common visibility settings should match the self container. This
    -- also fixes a target container that remained at its constructor default
    -- BUFF_DEBUFF_ENABLED_CHOICE_DONT_SHOW after addon/settings init.
    local commonSettings = {
        BUFFS_SETTING_ALL_ENABLED,
        BUFFS_SETTING_DEBUFFS_ENABLED,
        BUFFS_SETTING_LONG_EFFECTS,
        BUFFS_SETTING_PERMANENT_EFFECTS,
    }
    for _, settingId in ipairs(commonSettings) do
        if player.settings and target.settings then
            target.settings[settingId] = player.settings[settingId]
        end
    end

    -- We only want native target debuffs. Target buffs remain disabled.
    if target.settings then
        target.settings[BUFFS_SETTING_BUFFS_ENABLED] = false
        target.settings[BUFFS_SETTING_BUFFS_ENABLED_FOR_TARGET] = false

        -- Respect ESO's actual "debuffs from others" option when available.
        if GetSetting_Bool then
            target.settings[BUFFS_SETTING_DEBUFFS_ENABLED_FOR_TARGET_FROM_OTHERS] =
                GetSetting_Bool(SETTING_TYPE_BUFFS, BUFFS_SETTING_DEBUFFS_ENABLED_FOR_TARGET_FROM_OTHERS)
        end
    end

    target.isDirty = true

    -- Update immediately when possible. The original style then reads
    -- GetNumBuffs/GetUnitBuffInfo for reticleover and acquires native icons.
    if target.ShouldContextuallyShow and target:ShouldContextuallyShow() then
        target:Update()
        if target.control then
            target.control:SetAlpha(1)
        end
        if target.RefreshContainerVisibility then
            target:RefreshContainerVisibility()
        end
    end
end

local function OnTargetChanged()
    zo_callLater(RepairNativeTargetContainer, 50)
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    InstallIconHook()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Target", EVENT_RETICLE_TARGET_CHANGED, OnTargetChanged)

    -- BUFF_DEBUFF and the target frame/settings can finish initialization
    -- after this addon. Retry after the UI has settled.
    zo_callLater(RepairNativeTargetContainer, 250)
    zo_callLater(RepairNativeTargetContainer, 1000)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

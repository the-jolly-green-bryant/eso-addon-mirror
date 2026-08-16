AbilityIconsFramework = {}

--- @class (partial) AbilityIconsFramework
local AbilityIconsFramework = AbilityIconsFramework

------------------
-- Declarations --
------------------

local ADDON_VERSION = "160"

AbilityIconsFramework.version = ADDON_VERSION
AbilityIconsFramework.name = "AbilityIconsFramework"

-- If icon packs call AddCustomIconPack before settings exist, queue them here.
AbilityIconsFramework._earlyIconPacks = AbilityIconsFramework._earlyIconPacks or {}

---------------
-- Functions --
---------------

local function ProcessEarlyIconPacks()
    if not AbilityIconsFramework._earlyIconPacks then return end
    if AbilityIconsFramework.GetSettings == nil then return end

    for packDir, packIcons in pairs(AbilityIconsFramework._earlyIconPacks) do
        -- Re-run AddCustomIconPack now that settings exist
        AbilityIconsFramework.AddCustomIconPack(packDir, packIcons)
    end

    AbilityIconsFramework._earlyIconPacks = {}
end

--- Initializes the saved variables and replaces mismatched base skill icons, if the saved variables dictate it.
function AbilityIconsFramework.Initialize()
    AbilityIconsFramework.ResetAllTextureRedirects() -- reset in case we had some icon pack disabled

    AbilityIconsFramework.InitializeSettings()
    ProcessEarlyIconPacks()

    AbilityIconsFramework.InitializeAutoConfirm()
	
	AbilityIconsFramework.ApplyFixVas()

    AbilityIconsFramework.GenerateReplacementLists()
    AbilityIconsFramework.ReplaceMismatchedIcons()
    AbilityIconsFramework.UpdateDefaultScribingIcons()

    AbilityIconsFramework.InitializeSortOrderEntries()

    AbilityIconsFramework:InitializeHeroismPotions()

    AbilityIconsFramework.UpdateAllSlots()

    -- completely reset all base game redirects in case there were changes in loaded icon packs
    AbilityIconsFramework.SetOptionMismatchedIcons(false)
    AbilityIconsFramework.SetOptionMismatchedIcons(true)

    -- Already has UpdateAllSlots() inside it
    AbilityIconsFramework.OnScribingUpdate()
end

function AbilityIconsFramework.AddCustomIconPack(PackDirectory, PackIcons)
    if PackDirectory == nil or PackIcons == nil or #PackIcons == 0 then
        return
    end

    -- Always register as enabled
    AbilityIconsFramework.ENABLED_ICON_PACKS[PackDirectory] = PackIcons

    -- Settings might not exist yet (if another addon calls us very early)
    if AbilityIconsFramework.GetSettings == nil then
        AbilityIconsFramework._earlyIconPacks[PackDirectory] = PackIcons
        return
    end

    local settings = AbilityIconsFramework:GetSettings()
    if settings == nil then
        AbilityIconsFramework._earlyIconPacks[PackDirectory] = PackIcons
        return
    end

    -- If we already had this pack's info saved we can exit
    if settings.iconPacksData[PackDirectory] ~= nil then
        return
    end

    -- Get pack's addon folder name
    local packName = PackDirectory:match("/(.*)/")
    if packName then
        packName = packName:match("(.*)/") or packName
    else
        packName = PackDirectory
    end

    local highestOrder = 0
    if AbilityIconsFramework.GetHighestIconPackOrder ~= nil then
        highestOrder = AbilityIconsFramework.GetHighestIconPackOrder()
    end

    settings.iconPacksData[PackDirectory] = {
        packDisplayName = packName,
        loadOrder = highestOrder + 1,
        packExampleTexture = PackDirectory .. PackIcons[1],
    }
end

-- Auto confirm logic
function AbilityIconsFramework.InitializeAutoConfirm()
    if AbilityIconsFramework._autoConfirmHooked then return end
    AbilityIconsFramework._autoConfirmHooked = true
	
    --- Applies or removes the vAS 64x64 dimension constraints to the combat tips icon.
    function AbilityIconsFramework.ApplyFixVas()
        if AbilityIconsFramework.GetSettings == nil then return end
        local settings = AbilityIconsFramework:GetSettings()
        
        if ZO_ActiveCombatTipsTipIcon then
            if settings and settings.fixVas then
                ZO_ActiveCombatTipsTipIcon:SetDimensionConstraints(64, 64, 64, 64)
            else
                -- 0 removes the constraint, restoring default UI behavior
                ZO_ActiveCombatTipsTipIcon:SetDimensionConstraints(0, 0, 0, 0) 
            end
        end
    end

    local function hook(...)
        zo_callLater(function()
            if AbilityIconsFramework.GetSettings == nil then return end
            local settings = AbilityIconsFramework:GetSettings()
            if settings == nil or not settings.autoTypeConfirm then return end

            if ZO_Dialog1 and ZO_Dialog1.textParams and ZO_Dialog1.textParams.mainTextParams then
                for _, v in pairs(ZO_Dialog1.textParams.mainTextParams) do
                    if type(v) == "string" and v == string.upper(v) then
                        if ZO_Dialog1EditBox and ZO_Dialog1EditBox.SetText then
                            ZO_Dialog1EditBox:SetText(v)
                            ZO_Dialog1EditBox:LoseFocus()
                        end
                    end
                end
            end
        end, 10)
    end

    ZO_PreHook("ZO_Dialogs_ShowDialog", hook)
end

------------
-- Events --
------------

function AbilityIconsFramework.OnScribingUpdate()
    if AbilityIconsFramework:GetSettings().showCustomScribeIcons then
        AbilityIconsFramework.SetOptionCustomIcons(false)
        AbilityIconsFramework.SetOptionCustomIcons(true)
    end

    AbilityIconsFramework.UpdateAllSlots()
end

function AbilityIconsFramework.HandleSlotChanged(actionSlotIndex, hotbarCategory)
    local btn = ZO_ActionBar_GetButton(actionSlotIndex, hotbarCategory)
    if btn then
        btn:HandleSlotChanged()
    end
end

-- This function not only triggers action bar icons update, but has a side-effect of force-updating any other pending texture redirects
function AbilityIconsFramework.UpdateAllSlots()
    local activeHotbarCategory = GetActiveHotbarCategory()
    local inactiveHotbarCategory = activeHotbarCategory == HOTBAR_CATEGORY_BACKUP and HOTBAR_CATEGORY_PRIMARY or HOTBAR_CATEGORY_BACKUP

    for slotIndex = AbilityIconsFramework.MIN_INDEX, AbilityIconsFramework.MAX_INDEX do
        -- Update base game action bars
        AbilityIconsFramework.HandleSlotChanged(slotIndex, activeHotbarCategory)
        AbilityIconsFramework.HandleSlotChanged(slotIndex, inactiveHotbarCategory)
    end
end

--- To be used during game initialization. Code contained in this method needs to run conditionally, for this addon only.
--- @param eventCode any
--- @param addOnName any
function AbilityIconsFramework.OnAddOnLoaded(eventCode, addOnName)
    if addOnName == AbilityIconsFramework.name then
        EVENT_MANAGER:UnregisterForEvent(AbilityIconsFramework.name, EVENT_ADD_ON_LOADED)

        AbilityIconsFramework.CreateSlashCommands()

        -- Slight delay to let icon pack changes to be applied first
        zo_callLater(function()
            AbilityIconsFramework.Initialize()
        end, 250)

        -- Event firing when scribing craft completes - so we might want to update scribing icons
        CALLBACK_MANAGER:RegisterCallback("CraftingAnimationsStopped", function()
            AbilityIconsFramework.OnScribingUpdate()
        end)
    end
end

----------
-- Main --
----------

EVENT_MANAGER:RegisterForEvent(AbilityIconsFramework.name, EVENT_ADD_ON_LOADED, AbilityIconsFramework.OnAddOnLoaded)
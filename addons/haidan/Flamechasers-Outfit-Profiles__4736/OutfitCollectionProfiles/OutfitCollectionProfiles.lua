OutfitCollectionProfiles = OutfitCollectionProfiles or {}
local OCP = OutfitCollectionProfiles

OCP.name = "OutfitCollectionProfiles"
OCP.displayName = "Flamechasers Outfit Profiles"
OCP.version = "0.3.8"
OCP.pollIntervalMs = 500
OCP.applyDelayMs = 900
OCP.maxUseAttempts = 5

local KEEP = "keep"
local NONE = "none"

local defaults = {
    debug = false,
    collectibleDelaySeconds = 2.5,
    profiles = {},
}

function OCP.GetCollectibleDelayMs()
    local seconds = tonumber(OCP.saved and OCP.saved.collectibleDelaySeconds) or 2.5
    seconds = zo_clamp(seconds, 0.5, 10)
    return math.floor(seconds * 1000 + 0.5)
end

function OCP.SetCollectibleDelaySeconds(value)
    local normalized = tostring(value or ""):gsub(",", ".")
    local seconds = tonumber(normalized)
    if not seconds then seconds = 2.5 end
    seconds = zo_clamp(seconds, 0.5, 10)
    OCP.saved.collectibleDelaySeconds = math.floor(seconds * 10 + 0.5) / 10
    return OCP.saved.collectibleDelaySeconds
end

-- The older API names are still the internal names for the modern Collections labels.
OCP.categoryDefinitions = {
    { key = "hat",             label = "Hat",               constant = "COLLECTIBLE_CATEGORY_TYPE_HAT" },
    { key = "hair",            label = "Hair Style",        constant = "COLLECTIBLE_CATEGORY_TYPE_HAIR" },
    { key = "headMarking",     label = "Head Marking",      constant = "COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING" },
    { key = "facialHair",      label = "Facial Hair",       constant = "COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS" },
    { key = "majorAdornment",  label = "Major Adornment",   constant = "COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY" },
    { key = "minorAdornment",  label = "Minor Adornment",   constant = "COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY" },
    { key = "costume",         label = "Costume",           constant = "COLLECTIBLE_CATEGORY_TYPE_COSTUME" },
    { key = "bodyMarking",     label = "Body Marking",      constant = "COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING" },
    { key = "skin",            label = "Skin",              constant = "COLLECTIBLE_CATEGORY_TYPE_SKIN" },
    { key = "personality",     label = "Personality",       constant = "COLLECTIBLE_CATEGORY_TYPE_PERSONALITY" },
    { key = "mount",           label = "Mount",             constant = "COLLECTIBLE_CATEGORY_TYPE_MOUNT" },
    { key = "vanityPet",       label = "Non-Combat Pet",    constant = "COLLECTIBLE_CATEGORY_TYPE_VANITY_PET" },
}

local function Debug(message)
    if OCP.saved and OCP.saved.debug then
        d(string.format("|c78D8FF[OCP]|r %s", tostring(message)))
    end
end

local function GetCategoryType(definition)
    return rawget(_G, definition.constant)
end

function OCP.GetEquippedOutfitIndex()
    if ZO_OUTFIT_MANAGER and ZO_OUTFIT_MANAGER.GetEquippedOutfitIndex then
        return ZO_OUTFIT_MANAGER:GetEquippedOutfitIndex(GAMEPLAY_ACTOR_CATEGORY_PLAYER) or 0
    end
    if GetEquippedOutfitIndex then
        return GetEquippedOutfitIndex(GAMEPLAY_ACTOR_CATEGORY_PLAYER) or 0
    end
    return 0
end

function OCP.GetNumOutfits()
    if ZO_OUTFIT_MANAGER and ZO_OUTFIT_MANAGER.GetNumOutfits then
        return ZO_OUTFIT_MANAGER:GetNumOutfits(GAMEPLAY_ACTOR_CATEGORY_PLAYER) or 0
    end
    return 0
end

function OCP.GetOutfitName(index)
    if index == 0 then return "No Outfit" end
    if ZO_OUTFIT_MANAGER and ZO_OUTFIT_MANAGER.GetOutfitName then
        local name = ZO_OUTFIT_MANAGER:GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, index)
        if name and name ~= "" then return zo_strformat("<<1>>", name) end
    end
    return string.format("Outfit %d", index)
end

function OCP.GetOutfitNameSignature()
    local names = {}
    for index = 0, OCP.GetNumOutfits() do
        names[#names + 1] = tostring(index) .. ":" .. OCP.GetOutfitName(index)
    end
    return table.concat(names, "|")
end

function OCP.GetProfile(outfitIndex, create)
    local key = tostring(outfitIndex or 0)
    local profile = OCP.saved.profiles[key]
    if not profile and create then
        profile = {}
        OCP.saved.profiles[key] = profile
    end
    return profile
end

function OCP.GetSetting(outfitIndex, categoryKey)
    local profile = OCP.GetProfile(outfitIndex, false)
    local setting = profile and profile[categoryKey]
    if type(setting) ~= "table" then return { mode = KEEP } end
    return setting
end

function OCP.SetSetting(outfitIndex, categoryKey, mode, collectibleId)
    local profile = OCP.GetProfile(outfitIndex, true)
    profile[categoryKey] = {
        mode = mode,
        collectibleId = mode == "item" and collectibleId or nil,
    }
end

local function CopySetting(setting)
    if type(setting) ~= "table" then return { mode = KEEP } end
    return { mode = setting.mode or KEEP, collectibleId = setting.collectibleId }
end

function OCP.LoadDraft(outfitIndex)
    OCP.draftOutfitIndex = outfitIndex
    OCP.draft = {}
    for _, definition in ipairs(OCP.categoryDefinitions) do
        OCP.draft[definition.key] = CopySetting(OCP.GetSetting(outfitIndex, definition.key))
    end
    OCP.draftDirty = false
end

function OCP.EnsureDraft(outfitIndex)
    if OCP.draftOutfitIndex ~= outfitIndex or type(OCP.draft) ~= "table" then
        OCP.LoadDraft(outfitIndex)
    end
end

function OCP.GetDraftSetting(categoryKey)
    OCP.EnsureDraft(OCP.selectedOutfitIndex or OCP.GetEquippedOutfitIndex())
    return OCP.draft[categoryKey] or { mode = KEEP }
end

function OCP.SetDraftSetting(categoryKey, mode, collectibleId)
    OCP.EnsureDraft(OCP.selectedOutfitIndex or OCP.GetEquippedOutfitIndex())
    OCP.draft[categoryKey] = {
        mode = mode,
        collectibleId = mode == "item" and collectibleId or nil,
    }
    OCP.draftDirty = true
end

function OCP.GetDraftProfile()
    OCP.EnsureDraft(OCP.selectedOutfitIndex or OCP.GetEquippedOutfitIndex())
    local profile = {}
    for _, definition in ipairs(OCP.categoryDefinitions) do
        profile[definition.key] = CopySetting(OCP.draft[definition.key])
    end
    return profile
end

function OCP.SaveDraftConfirmed()
    local outfitIndex = OCP.selectedOutfitIndex or OCP.GetEquippedOutfitIndex()
    OCP.saved.profiles[tostring(outfitIndex)] = OCP.GetDraftProfile()
    OCP.draftDirty = false
    d(string.format("|cF05A28[Flamechasers]|r Saved Collection profile for |cFFFFFF%s|r.", OCP.GetOutfitName(outfitIndex)))
    if OCP.RefreshWindow then OCP.RefreshWindow() end
end

function OCP.RequestSaveDraft()
    local outfitIndex = OCP.selectedOutfitIndex or OCP.GetEquippedOutfitIndex()
    if OCP.HasSavedProfile(outfitIndex) then
        ZO_Dialogs_ShowDialog("OCP_CONFIRM_DRAFT_OVERWRITE", { outfitIndex = outfitIndex })
    else
        OCP.SaveDraftConfirmed()
    end
end

function OCP.HasSavedProfile(outfitIndex)
    local profile = OCP.GetProfile(outfitIndex, false)
    if type(profile) ~= "table" then return false end
    for _, definition in ipairs(OCP.categoryDefinitions) do
        local setting = profile[definition.key]
        if type(setting) == "table" and setting.mode then return true end
    end
    return false
end

function OCP.GetProfileSummary(outfitIndex)
    if not OCP.HasSavedProfile(outfitIndex) then return "No saved Collection setup" end
    local parts = {}
    local profile = OCP.GetProfile(outfitIndex, false)
    for _, definition in ipairs(OCP.categoryDefinitions) do
        local setting = profile[definition.key]
        if setting and setting.mode and setting.mode ~= KEEP then
            local value = "None"
            if setting.mode == "item" and tonumber(setting.collectibleId) then
                local name = GetCollectibleName(tonumber(setting.collectibleId))
                value = (name and name ~= "") and zo_strformat("<<1>>", name) or "Unknown"
            end
            parts[#parts + 1] = definition.label .. ": " .. value
        end
    end
    if #parts == 0 then return "Saved setup — all categories set to Keep Current" end
    return table.concat(parts, "  •  ")
end

function OCP.GetActiveCollectible(categoryType)
    if not categoryType then return 0 end
    return GetActiveCollectibleByType(categoryType, GAMEPLAY_ACTOR_CATEGORY_PLAYER) or 0
end

function OCP.GetCollectibles(definition)
    local results = {}
    local categoryType = GetCategoryType(definition)
    if not categoryType then return results end

    local count = GetTotalCollectiblesByCategoryType(categoryType) or 0
    for index = 1, count do
        local collectibleId = GetCollectibleIdFromType(categoryType, index)
        if collectibleId and collectibleId > 0 and IsCollectibleUnlocked(collectibleId) then
            results[#results + 1] = {
                id = collectibleId,
                name = zo_strformat("<<1>>", GetCollectibleName(collectibleId)),
                icon = GetCollectibleIcon(collectibleId),
            }
        end
    end
    table.sort(results, function(a, b) return a.name < b.name end)
    return results
end

function OCP.CaptureCurrent(outfitIndex)
    OCP.selectedOutfitIndex = outfitIndex
    OCP.EnsureDraft(outfitIndex)
    for _, definition in ipairs(OCP.categoryDefinitions) do
        local categoryType = GetCategoryType(definition)
        if categoryType then
            local activeId = OCP.GetActiveCollectible(categoryType)
            if activeId > 0 then
                OCP.SetDraftSetting(definition.key, "item", activeId)
            else
                OCP.SetDraftSetting(definition.key, NONE)
            end
        end
    end
    if OCP.RefreshWindow then OCP.RefreshWindow() end
end

function OCP.ConfirmCapture(outfitIndex)
    OCP.selectedOutfitIndex = outfitIndex
    OCP.LoadDraft(outfitIndex)
    OCP.CaptureCurrent(outfitIndex)
    OCP.saved.profiles[tostring(outfitIndex)] = OCP.GetDraftProfile()
    OCP.draftDirty = false
    d(string.format("|c78D8FF[OCP]|r Saved current Collections setup for |cFFFFFF%s|r.", OCP.GetOutfitName(outfitIndex)))
end

function OCP.RequestCapture(outfitIndex)
    outfitIndex = outfitIndex == nil and OCP.GetEquippedOutfitIndex() or outfitIndex
    if OCP.HasSavedProfile(outfitIndex) then
        ZO_Dialogs_ShowDialog("OCP_CONFIRM_PROFILE_OVERWRITE", { outfitIndex = outfitIndex })
    else
        OCP.ConfirmCapture(outfitIndex)
    end
end

function OCP.SaveCurrentOutfitProfile()
    OCP.RequestCapture(OCP.GetEquippedOutfitIndex())
end

function OCP.CancelApply()
    OCP.applyGeneration = (OCP.applyGeneration or 0) + 1
end

function OCP.ApplyOutfitProfile(outfitIndex, reason, profileOverride)
    outfitIndex = outfitIndex == nil and OCP.GetEquippedOutfitIndex() or outfitIndex
    local profile = profileOverride or OCP.GetProfile(outfitIndex, false)
    if not profile then
        Debug("No profile for " .. OCP.GetOutfitName(outfitIndex))
        return
    end

    OCP.CancelApply()
    local generation = OCP.applyGeneration
    Debug(string.format("Applying %s (%s)", OCP.GetOutfitName(outfitIndex), reason or "manual"))

    local jobs = {}
    for _, definition in ipairs(OCP.categoryDefinitions) do
        local setting = profile[definition.key]
        local categoryType = GetCategoryType(definition)
        if categoryType and setting and setting.mode and setting.mode ~= KEEP then
            jobs[#jobs + 1] = {
                definition = definition,
                categoryType = categoryType,
                setting = setting,
            }
        end
    end

    local function ProcessJob(jobIndex)
        if generation ~= OCP.applyGeneration then return end
        local job = jobs[jobIndex]
        if not job then
            if OCP.RefreshStatus then OCP.RefreshStatus() end
            return
        end

        local attempts = 0
        local function TryJob()
            if generation ~= OCP.applyGeneration then return end
            attempts = attempts + 1

            local activeId = OCP.GetActiveCollectible(job.categoryType)
            local desiredId = job.setting.mode == "item" and tonumber(job.setting.collectibleId) or 0
            if activeId == desiredId then
                zo_callLater(function() ProcessJob(jobIndex + 1) end, 50)
                return
            end

            local useId = desiredId > 0 and desiredId or activeId
            if useId <= 0 then
                zo_callLater(function() ProcessJob(jobIndex + 1) end, 50)
                return
            end

            if IsCollectibleUnlocked(useId)
                and IsCollectibleUsable(useId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
                and IsCollectibleValidForPlayer(useId)
                and not IsCollectibleBlocked(useId) then
                UseCollectible(useId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
            end

            zo_callLater(function()
                if generation ~= OCP.applyGeneration then return end
                local nowActive = OCP.GetActiveCollectible(job.categoryType)
                if nowActive == desiredId or attempts >= OCP.maxUseAttempts then
                    if nowActive ~= desiredId then
                        Debug("Could not apply " .. job.definition.label .. "; it will retry after combat or activation")
                    end
                    ProcessJob(jobIndex + 1)
                else
                    TryJob()
                end
            end, OCP.GetCollectibleDelayMs())
        end
        TryJob()
    end

    ProcessJob(1)
end

function OCP.ScheduleApply(reason, delayMs)
    OCP.scheduleGeneration = (OCP.scheduleGeneration or 0) + 1
    local generation = OCP.scheduleGeneration
    zo_callLater(function()
        if generation ~= OCP.scheduleGeneration then return end
        OCP.ApplyOutfitProfile(nil, reason)
    end, delayMs or OCP.applyDelayMs)
end

function OCP.PollOutfit()
    local current = OCP.GetEquippedOutfitIndex()
    if OCP.lastOutfitIndex ~= current then
        OCP.lastOutfitIndex = current
        if OCP.window and not OCP.window:IsHidden() then
            OCP.selectedOutfitIndex = current
            OCP.RefreshWindow()
        end
        OCP.ScheduleApply("outfit changed")
    end

    local nameSignature = OCP.GetOutfitNameSignature()
    if OCP.lastOutfitNameSignature ~= nameSignature then
        OCP.lastOutfitNameSignature = nameSignature
        if OCP.window and not OCP.window:IsHidden() then OCP.RefreshWindow() end
    end
end

function OCP.OnPlayerActivated()
    OCP.lastOutfitIndex = OCP.GetEquippedOutfitIndex()
    OCP.lastOutfitNameSignature = OCP.GetOutfitNameSignature()
    OCP.ScheduleApply("player activated", 1500)
end

function OCP.OnArmoryRestored(result)
    if result and result ~= ARMORY_BUILD_RESTORE_RESULT_SUCCESS then return end
    -- Armory restoration is asynchronous. Polling catches the slot change, while
    -- these passes cover slow equipment/appearance completion and same-slot restores.
    OCP.ScheduleApply("armory restored", 1800)
    zo_callLater(function() OCP.ScheduleApply("armory settled", 800) end, 3500)
end

function OCP.Initialize()
    -- Character-ID settings are already isolated by ESO's server-specific
    -- character ID ranges, so no separate GetWorldName profile is required.
    OCP.saved = ZO_SavedVars:NewCharacterIdSettings(
        "OutfitCollectionProfilesSavedVariables",
        1,
        nil,
        defaults
    )

    OCP.lastOutfitIndex = OCP.GetEquippedOutfitIndex()
    OCP.selectedOutfitIndex = OCP.lastOutfitIndex
    OCP.LoadDraft(OCP.selectedOutfitIndex)
    OCP.CreateWindow()

    ZO_CreateStringId("SI_BINDING_NAME_FLAMECHASERS_CATEGORY", "Flamechasers")
    ZO_CreateStringId("SI_BINDING_NAME_OCP_TOGGLE_WINDOW", "Open Flamechasers Outfit Profiles")
    ZO_CreateStringId("SI_BINDING_NAME_OCP_SAVE_CURRENT_PROFILE", "Save Collections for Current Outfit")
    ZO_Dialogs_RegisterCustomDialog("OCP_CONFIRM_PROFILE_OVERWRITE", {
        title = { text = "Overwrite Collection Profile?" },
        mainText = {
            text = function(dialog)
                local index = dialog.data and dialog.data.outfitIndex or 0
                return string.format("%s already has a saved Collection setup. Replace it with everything currently active?", OCP.GetOutfitName(index))
            end,
        },
        buttons = {
            {
                text = SI_DIALOG_CONFIRM,
                callback = function(dialog)
                    OCP.ConfirmCapture(dialog.data.outfitIndex)
                end,
            },
            { text = SI_DIALOG_CANCEL },
        },
    })
    ZO_Dialogs_RegisterCustomDialog("OCP_CONFIRM_DRAFT_OVERWRITE", {
        title = { text = "Overwrite Collection Profile?" },
        mainText = {
            text = function(dialog)
                local index = dialog.data and dialog.data.outfitIndex or 0
                return string.format("%s already has a saved Collection setup. Replace it with the settings currently shown in the addon window?", OCP.GetOutfitName(index))
            end,
        },
        buttons = {
            { text = SI_DIALOG_CONFIRM, callback = function() OCP.SaveDraftConfirmed() end },
            { text = SI_DIALOG_CANCEL },
        },
    })

    EVENT_MANAGER:RegisterForEvent(OCP.name, EVENT_PLAYER_ACTIVATED, function() OCP.OnPlayerActivated() end)
    EVENT_MANAGER:RegisterForEvent(OCP.name, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        if not inCombat then OCP.ScheduleApply("combat ended", 1000) end
    end)

    if EVENT_ARMORY_BUILD_RESTORE_RESPONSE then
        EVENT_MANAGER:RegisterForEvent(OCP.name .. "Armory", EVENT_ARMORY_BUILD_RESTORE_RESPONSE, function(_, result)
            OCP.OnArmoryRestored(result)
        end)
    end

    EVENT_MANAGER:RegisterForUpdate(OCP.name .. "Poll", OCP.pollIntervalMs, function() OCP.PollOutfit() end)
    SLASH_COMMANDS["/ocp"] = function() OCP.ToggleWindow() end
    SLASH_COMMANDS["/outfitprofiles"] = function() OCP.ToggleWindow() end
    SLASH_COMMANDS["/fop"] = function() OCP.ToggleWindow() end
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= OCP.name then return end
    EVENT_MANAGER:UnregisterForEvent(OCP.name, EVENT_ADD_ON_LOADED)
    OCP.Initialize()
end

EVENT_MANAGER:RegisterForEvent(OCP.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

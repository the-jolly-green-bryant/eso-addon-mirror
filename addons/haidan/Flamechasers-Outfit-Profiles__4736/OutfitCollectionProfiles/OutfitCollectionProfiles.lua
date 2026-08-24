OutfitCollectionProfiles = OutfitCollectionProfiles or {}
local OCP = OutfitCollectionProfiles

OCP.name = "OutfitCollectionProfiles"
OCP.displayName = "Flamechasers Outfit Profiles"
OCP.version = "0.4.1"
OCP.pollIntervalMs = 500
OCP.applyDelayMs = 900
OCP.maxUseAttempts = 5

-- Bindings.xml is loaded after this file. Register these labels now so the
-- shared category already exists when ESO parses the binding definitions.
if _G["SI_BINDING_NAME_FLAMECHASERS_CATEGORY"] == nil then
    ZO_CreateStringId("SI_BINDING_NAME_FLAMECHASERS_CATEGORY", "Flamechasers")
end
ZO_CreateStringId("SI_BINDING_NAME_OCP_TOGGLE_WINDOW", "Open Flamechasers Outfit Profiles")
ZO_CreateStringId("SI_BINDING_NAME_OCP_SAVE_CURRENT_PROFILE", "Save Collections for Current Outfit")

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
    { key = "hat",             label = "Hat",               categoryType = COLLECTIBLE_CATEGORY_TYPE_HAT },
    { key = "hair",            label = "Hair Style",        categoryType = COLLECTIBLE_CATEGORY_TYPE_HAIR },
    { key = "headMarking",     label = "Head Marking",      categoryType = COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING },
    { key = "facialHair",      label = "Facial Hair",       categoryType = COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS },
    { key = "majorAdornment",  label = "Major Adornment",   categoryType = COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY },
    { key = "minorAdornment",  label = "Minor Adornment",   categoryType = COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY },
    { key = "costume",         label = "Costume",           categoryType = COLLECTIBLE_CATEGORY_TYPE_COSTUME },
    { key = "bodyMarking",     label = "Body Marking",      categoryType = COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING },
    { key = "skin",            label = "Skin",              categoryType = COLLECTIBLE_CATEGORY_TYPE_SKIN },
    { key = "personality",     label = "Personality",       categoryType = COLLECTIBLE_CATEGORY_TYPE_PERSONALITY },
    { key = "mount",           label = "Mount",             categoryType = COLLECTIBLE_CATEGORY_TYPE_MOUNT },
    { key = "vanityPet",       label = "Non-Combat Pet",    categoryType = COLLECTIBLE_CATEGORY_TYPE_VANITY_PET },
}

local function Debug(message)
    if OCP.saved and OCP.saved.debug then
        d(string.format("|c78D8FF[OCP]|r %s", tostring(message)))
    end
end

function OCP.GetEquippedOutfitIndex()
    -- ESO documents this return as nilable when no outfit is equipped.
    return GetEquippedOutfitIndex(GAMEPLAY_ACTOR_CATEGORY_PLAYER) or 0
end

function OCP.GetNumOutfits()
    return GetNumUnlockedOutfits(GAMEPLAY_ACTOR_CATEGORY_PLAYER)
end

function OCP.GetOutfitName(index)
    if index == 0 then return "No Outfit" end
    local name = GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, index)
    if name ~= "" then return zo_strformat("<<1>>", name) end
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
    d(string.format("|cC8643B[Flamechasers]|r Saved Collection profile for |cFFFFFF%s|r.", OCP.GetOutfitName(outfitIndex)))
    OCP.RefreshWindow()
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
                value = name ~= "" and zo_strformat("<<1>>", name) or "Unknown"
            end
            parts[#parts + 1] = definition.label .. ": " .. value
        end
    end
    if #parts == 0 then return "Saved setup — no categories tracked" end
    return table.concat(parts, "  •  ")
end

function OCP.GetActiveCollectible(categoryType)
    if not categoryType then return 0 end
    return GetActiveCollectibleByType(categoryType, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
end

function OCP.GetCollectibles(definition)
    local results = {}
    local categoryType = definition.categoryType

    local count = GetTotalCollectiblesByCategoryType(categoryType)
    for index = 1, count do
        local collectibleId = GetCollectibleIdFromType(categoryType, index)
        if collectibleId > 0 and IsCollectibleUnlocked(collectibleId) then
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
        local activeId = OCP.GetActiveCollectible(definition.categoryType)
        if activeId > 0 then
            OCP.SetDraftSetting(definition.key, "item", activeId)
        else
            OCP.SetDraftSetting(definition.key, NONE)
        end
    end
    OCP.RefreshWindow()
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

function OCP.SetApplyState(state, completed, total, detail)
    OCP.applyState = state or "idle"
    OCP.applyCompleted = completed or 0
    OCP.applyTotal = total or 0
    OCP.applyDetail = detail
    if OCP.RefreshStatus then OCP.RefreshStatus() end
end

function OCP.CancelApply(resetState)
    OCP.applyGeneration = (OCP.applyGeneration or 0) + 1
    if OCP.pendingApply then
        OCP.pendingApply.scheduleToken = (OCP.pendingApply.scheduleToken or 0) + 1
        OCP.pendingApply.scheduled = false
    end
    OCP.pendingApply = nil
    if resetState ~= false then OCP.SetApplyState("idle") end
end

function OCP.SchedulePendingApply(delayMs)
    local task = OCP.pendingApply
    if not task or task.scheduled or not OCP.playerActivated then return end

    task.scheduleToken = (task.scheduleToken or 0) + 1
    local token = task.scheduleToken
    task.scheduled = true
    zo_callLater(function()
        if OCP.pendingApply ~= task or token ~= task.scheduleToken then return end
        task.scheduled = false
        if OCP.playerActivated then OCP.ProcessPendingApply() end
    end, delayMs or 0)
end

function OCP.CompletePendingApply(task)
    if OCP.pendingApply ~= task then return end

    -- Confirm the whole profile once more before sleeping. This catches a
    -- category that changed again while later collectible actions were queued.
    for index, job in ipairs(task.jobs) do
        if not job.failed and OCP.GetActiveCollectible(job.categoryType) ~= job.desiredId then
            if job.confirmed then
                job.confirmed = false
                task.completed = math.max(0, task.completed - 1)
            end
            job.attempts = 0
            task.jobIndex = index
            OCP.SetApplyState("waiting", task.completed, #task.jobs,
                "confirming " .. job.definition.label)
            OCP.SchedulePendingApply(150)
            return
        end
    end

    OCP.pendingApply = nil
    if task.failed > 0 then
        OCP.SetApplyState("warning", #task.jobs - task.failed, #task.jobs,
            string.format("%d unavailable", task.failed))
    else
        OCP.SetApplyState("complete", #task.jobs, #task.jobs)
    end
    Debug("Finished applying " .. OCP.GetOutfitName(task.outfitIndex))
end

function OCP.ProcessPendingApply()
    local task = OCP.pendingApply
    if not task or not OCP.playerActivated then return end
    if task.generation ~= OCP.applyGeneration then return end

    -- Automatic jobs belong to one equipped outfit. If another outfit replaces
    -- it before polling catches up, stop touching Collections immediately.
    if task.requiresOutfitMatch
        and OCP.GetEquippedOutfitIndex() ~= task.outfitIndex then
        OCP.PollOutfit("outfit changed during profile apply")
        return
    end

    local job = task.jobs[task.jobIndex]
    if not job then
        OCP.CompletePendingApply(task)
        return
    end

    local activeId = OCP.GetActiveCollectible(job.categoryType)
    if activeId == job.desiredId then
        if not job.confirmed then
            job.confirmed = true
            task.completed = task.completed + 1
        end
        task.jobIndex = task.jobIndex + 1
        OCP.SetApplyState("applying", task.completed, #task.jobs)
        OCP.SchedulePendingApply(50)
        return
    end

    local useId = job.desiredId > 0 and job.desiredId or activeId
    if useId <= 0 then
        if not job.confirmed then
            job.confirmed = true
            task.completed = task.completed + 1
        end
        task.jobIndex = task.jobIndex + 1
        OCP.SchedulePendingApply(50)
        return
    end

    -- An unlocked collectible can become temporarily unusable or blocked by
    -- combat, movement, transformations, or a loading transition. Keep this
    -- one apply job alive and retry only while it remains unfinished.
    if not IsCollectibleUnlocked(useId) then
        Debug("Saved collectible is no longer unlocked for " .. job.definition.label)
        job.failed = true
        task.failed = task.failed + 1
        task.jobIndex = task.jobIndex + 1
        OCP.SetApplyState("warning", task.completed, #task.jobs,
            job.definition.label .. " unavailable")
        OCP.SchedulePendingApply(50)
        return
    end

    job.attempts = job.attempts + 1
    if IsCollectibleUsable(useId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        and IsCollectibleValidForPlayer(useId)
        and not IsCollectibleBlocked(useId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
        UseCollectible(useId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        OCP.SetApplyState("applying", task.completed, #task.jobs,
            job.definition.label)
    else
        OCP.SetApplyState("waiting", task.completed, #task.jobs,
            job.definition.label)
    end

    local delayMs = OCP.GetCollectibleDelayMs()
    if job.attempts >= OCP.maxUseAttempts then
        Debug("ESO is still delaying " .. job.definition.label .. "; keeping the active job pending")
        job.attempts = 0
        delayMs = math.max(delayMs, 1500)
        OCP.SetApplyState("waiting", task.completed, #task.jobs,
            job.definition.label)
    end
    OCP.SchedulePendingApply(delayMs)
end

function OCP.ApplyOutfitProfile(outfitIndex, reason, profileOverride)
    outfitIndex = outfitIndex == nil and OCP.GetEquippedOutfitIndex() or outfitIndex
    local profile = profileOverride or OCP.GetProfile(outfitIndex, false)

    OCP.CancelApply(false)
    if not profile then
        Debug("No profile for " .. OCP.GetOutfitName(outfitIndex))
        OCP.SetApplyState("untracked")
        return
    end

    local jobs = {}
    for _, definition in ipairs(OCP.categoryDefinitions) do
        local setting = profile[definition.key]
        if setting and setting.mode and setting.mode ~= KEEP then
            jobs[#jobs + 1] = {
                definition = definition,
                categoryType = definition.categoryType,
                desiredId = setting.mode == "item"
                    and (tonumber(setting.collectibleId) or 0) or 0,
                attempts = 0,
                confirmed = false,
                failed = false,
            }
        end
    end

    if #jobs == 0 then
        OCP.SetApplyState("untracked")
        return
    end

    OCP.pendingApply = {
        generation = OCP.applyGeneration,
        outfitIndex = outfitIndex,
        reason = reason or "manual",
        requiresOutfitMatch = profileOverride == nil,
        jobs = jobs,
        jobIndex = 1,
        completed = 0,
        failed = 0,
        scheduled = false,
        scheduleToken = 0,
    }
    Debug(string.format("Applying %s (%s)",
        OCP.GetOutfitName(outfitIndex), reason or "manual"))
    OCP.SetApplyState("applying", 0, #jobs)
    OCP.SchedulePendingApply(OCP.applyDelayMs)
end

function OCP.HandleOutfitChanged(current, reason)
    OCP.lastOutfitIndex = current
    if OCP.window and not OCP.window:IsHidden() then
        OCP.selectedOutfitIndex = current
        OCP.LoadDraft(current)
        OCP.RefreshWindow()
    end
    OCP.ApplyOutfitProfile(current, reason or "outfit changed")
end

function OCP.PollOutfit(reason)
    local current = OCP.GetEquippedOutfitIndex()
    if OCP.lastOutfitIndex ~= current then
        OCP.HandleOutfitChanged(current, reason or "outfit changed")
    end

    local nameSignature = OCP.GetOutfitNameSignature()
    if OCP.lastOutfitNameSignature ~= nameSignature then
        OCP.lastOutfitNameSignature = nameSignature
        if OCP.window and not OCP.window:IsHidden() then OCP.RefreshWindow() end
    end
end

function OCP.OnPlayerActivated()
    OCP.playerActivated = true
    local current = OCP.GetEquippedOutfitIndex()
    if OCP.lastOutfitIndex ~= current then
        OCP.HandleOutfitChanged(current, "outfit changed during loading")
    elseif OCP.pendingApply then
        OCP.SetApplyState("applying", OCP.pendingApply.completed,
            #OCP.pendingApply.jobs, "resuming")
        OCP.SchedulePendingApply(300)
    end
    OCP.lastOutfitNameSignature = OCP.GetOutfitNameSignature()
end

function OCP.OnPlayerDeactivated()
    OCP.playerActivated = false
    if OCP.pendingApply then
        OCP.pendingApply.scheduleToken = OCP.pendingApply.scheduleToken + 1
        OCP.pendingApply.scheduled = false
        OCP.SetApplyState("paused", OCP.pendingApply.completed,
            #OCP.pendingApply.jobs, "loading")
    end
end

function OCP.ResumePendingApply(reason)
    if not OCP.pendingApply then return end
    Debug("Resuming unfinished profile after " .. (reason or "interruption"))
    OCP.SetApplyState("applying", OCP.pendingApply.completed,
        #OCP.pendingApply.jobs, "resuming")
    OCP.SchedulePendingApply(250)
end

function OCP.OnArmoryRestored(result)
    if result ~= ARMORY_BUILD_RESTORE_RESULT_SUCCESS then return end
    -- An Armory restore starts work only if it actually changes the equipped
    -- outfit. Same-outfit restores deliberately leave Collections untouched.
    zo_callLater(function() OCP.PollOutfit("outfit changed by Armory") end, 250)
    zo_callLater(function() OCP.PollOutfit("outfit changed by Armory") end, 1800)
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
    OCP.playerActivated = false
    OCP.applyState = "idle"
    OCP.LoadDraft(OCP.selectedOutfitIndex)
    OCP.CreateWindow()

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
    EVENT_MANAGER:RegisterForEvent(OCP.name, EVENT_PLAYER_DEACTIVATED,
        function() OCP.OnPlayerDeactivated() end)
    EVENT_MANAGER:RegisterForEvent(OCP.name, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        if not inCombat then OCP.ResumePendingApply("combat") end
    end)

    EVENT_MANAGER:RegisterForEvent(OCP.name .. "Armory", EVENT_ARMORY_BUILD_RESTORE_RESPONSE, function(_, result)
        OCP.OnArmoryRestored(result)
    end)

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

-- CustomNames.lua
-- Entry point: initialises saved variables, merges offline edits, and wires up hooks.

local CN = CustomNames

------------------------------------------------------------------------
-- Lookup helpers
------------------------------------------------------------------------

local function makeLookup(tableKey)
    return function(name)
        if not name or name == "" then return name or "" end
        if not CN.savedVars or not CN.savedVars.enabled then return name end
        local t = CN.savedVars[tableKey]
        if not t then return name end
        if t[name] ~= nil then return t[name] end
        local lower = name:lower()
        for k, v in pairs(t) do
            if k:lower() == lower then return v end
        end
        return name
    end
end

CN.LookupZone     = makeLookup("zoneNames")
CN.LookupLocation = makeLookup("locationNames")
CN.LookupNPC      = makeLookup("npcNames")

-- LookupNPC is replaced below to also check quest-conditional renames.
local _baseLookupNPC = CN.LookupNPC
CN.LookupNPC = function(name)
    if not name or name == "" then return name or "" end
    if not CN.savedVars or not CN.savedVars.enabled then return name end

    -- First apply any unconditional NPC rename.
    local renamed = _baseLookupNPC(name)

    -- Then check quest-conditional renames. Each entry:
    --   { original = "Raw Name", questId = 1234, custom = "New Name" }
    -- If the quest is complete, this overrides the unconditional rename.
    local qlist = CN.savedVars.npcQuestNames
    if qlist then
        local lower = name:lower()
        for _, entry in ipairs(qlist) do
            if type(entry) == "table" and type(entry.original) == "string" then
                if entry.original == name or entry.original:lower() == lower then
                    if entry.questId and IsQuestComplete(entry.questId) then
                        return entry.custom or name
                    end
                end
            end
        end
    end

    return renamed
end

function CN.LookupAny(name)
    if not name or name == "" then return name or "" end
    local z = CN.LookupZone(name)
    if z ~= name then return z end
    return CN.LookupLocation(name)
end

------------------------------------------------------------------------
-- Offline merge
-- CustomNames_UserData is a flat SavedVariables file the user can edit
-- while the game is closed. On load we merge its entries INTO savedVars.
-- Entries already in savedVars are NOT overwritten, so in-game edits win.
-- Entries only in UserData are imported once, then live in savedVars.
------------------------------------------------------------------------

local function MergeUserData()
    local ud = CustomNames_UserData
    if type(ud) ~= "table" then return end

    local merged = 0
    for _, key in ipairs({"zoneNames", "locationNames", "npcNames", "zoneBlobScales"}) do
        local src = ud[key]
        if type(src) == "table" then
            local dst = CN.savedVars[key]
            for orig, val in pairs(src) do
                if type(orig) == "string" and dst[orig] == nil then
                    dst[orig] = val
                    merged = merged + 1
                end
            end
        end
    end

    -- npcQuestNames is an array — merge entries not already present
    -- (matched by original+questId pair).
    local srcQ = ud.npcQuestNames
    if type(srcQ) == "table" then
        local dstQ = CN.savedVars.npcQuestNames
        for _, entry in ipairs(srcQ) do
            if type(entry) == "table" and entry.original and entry.questId then
                local found = false
                for _, existing in ipairs(dstQ) do
                    if existing.original == entry.original
                       and existing.questId == entry.questId then
                        found = true; break
                    end
                end
                if not found then
                    dstQ[#dstQ + 1] = {
                        original = entry.original,
                        questId  = entry.questId,
                        custom   = entry.custom or "",
                    }
                    merged = merged + 1
                end
            end
        end
    end

    if merged > 0 then
        CHAT_SYSTEM:AddMessage(
            "|c88aaff[CustomNames]|r Imported " .. merged ..
            " new entr" .. (merged == 1 and "y" or "ies") ..
            " from CustomNames_UserData.")
    end
end

------------------------------------------------------------------------
-- RefreshAll
------------------------------------------------------------------------

function CN.RefreshAll()
    CN.RefreshHUDLabels()
    CN.RefreshNPCNameplates()
end

------------------------------------------------------------------------
-- Slash commands
------------------------------------------------------------------------

-- /cnzone  prints the raw zone name to use as a settings key
SLASH_COMMANDS["/cnzone"] = function()
    local name = CN.GetCurrentZoneName()
    CHAT_SYSTEM:AddMessage("|c88aaff[CustomNames]|r Current zone: |cffd700'" .. name .. "'|r")
end

------------------------------------------------------------------------
-- Boot
------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(
    CN.ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    function(_, addonName)
        if addonName ~= CN.ADDON_NAME then return end
        EVENT_MANAGER:UnregisterForEvent(CN.ADDON_NAME, EVENT_ADD_ON_LOADED)

        -- Primitives-only defaults so ZO_SavedVars never touches subtables.
        local primitiveDefaults = {
            version = CN.DEFAULTS.version,
            enabled = CN.DEFAULTS.enabled,
        }
        CN.savedVars = ZO_SavedVars:NewAccountWide(
            "CustomNames_SavedVars",
            CN.DEFAULTS.version,
            nil,
            primitiveDefaults
        )

        -- Initialise subtables only if absent; never overwrite existing data.
        if CN.savedVars.zoneNames        == nil then CN.savedVars.zoneNames        = {} end
        if CN.savedVars.locationNames    == nil then CN.savedVars.locationNames    = {} end
        if CN.savedVars.npcNames         == nil then CN.savedVars.npcNames         = {} end
        if CN.savedVars.zoneBlobScales   == nil then CN.savedVars.zoneBlobScales   = {} end
        -- npcQuestNames: array of { original, questId, custom }
        if CN.savedVars.npcQuestNames    == nil then CN.savedVars.npcQuestNames    = {} end
        -- doorNames: ["Zone:Name:X:Y"] = "Custom Name"
        if CN.savedVars.doorNames        == nil then CN.savedVars.doorNames        = {} end
        -- blobDefaultScales: ["Zone Name"] = nameScale float, persisted so the map
        -- needn't be opened each session for the settings display to show defaults.
        if CN.savedVars.blobDefaultScales == nil then CN.savedVars.blobDefaultScales = {} end

        -- One-time safety migration: if any blobDefaultScale matches a zoneBlobScale
        -- override exactly, it was likely captured from an already-overridden render
        -- and is untrustworthy. Clear those entries so they get re-captured cleanly.
        local scales = CN.savedVars.zoneBlobScales
        if scales then
            for k, overrideVal in pairs(scales) do
                local captured = CN.savedVars.blobDefaultScales[k]
                if captured and math.abs(captured - overrideVal) < 0.001 then
                    CN.savedVars.blobDefaultScales[k] = nil
                end
            end
        end

        -- Wire blob defaults table so GetMapBlobNameInfo populates it at render time.
        CN.blobDefaultScales = CN.savedVars.blobDefaultScales

        -- Merge any entries the user added to CustomNames_UserData offline.
        MergeUserData()

        CN.InitHUD()
        CN.InitNPC()
        CN.InitQuest()
        CN.BuildSettingsPanel()

        CHAT_SYSTEM:AddMessage(
            "|c88aaff[CustomNames]|r v" .. CN.VERSION ..
            " loaded. |cffd700/cn|r = settings  |  |cffd700/cnzone|r = show raw zone name")
    end
)

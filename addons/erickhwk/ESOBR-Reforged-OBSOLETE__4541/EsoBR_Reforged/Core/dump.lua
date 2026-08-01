local Dump = Reforged.Dump
local mr = function(s, w, r) return Reforged.Strings.magicReplace(s, w, r) end

Dump.progress = { phase = "", current = 0, total = 0 }

-- Temporarily sets ShowLocations to a given mode while fn() runs, then restores it.
-- Required because the game API returns names in the active language only.
local function withLocationsMode(mode, fn)
    local backup = Reforged.Settings.ShowLocations
    Reforged.Settings.ShowLocations = mode
    fn()
    Reforged.Settings.ShowLocations = backup
end

-- Collects Portuguese-language IDs. Must run while language.2 == "br".
function Dump.dumpBr()
    local rsv = Reforged.Settings.Data
    local links = Reforged.Data.Links

    -- Clear in-place (preserves the table reference held by all modules) and
    -- reset version markers so isStale() returns true until dumpEn completes.
    -- Without this, stale EN strings from a previous dumpEn survive into the
    -- next dumpEn and cause type errors (e.g. %d receiving a string).
    rsv.Items           = {}
    rsv.Sets            = {}
    rsv.SetsNames       = {}
    rsv.Potions         = {}
    rsv.Parts           = {}
    rsv.EnchantPrefixes = {}
    rsv.Prefixes        = {}
    rsv.Affixes         = {}
    rsv.Locations       = {}
    rsv.ApiVersion      = 0
    rsv.AddonVersion    = ""

    Dump.progress.phase = "br-items"
    Dump.progress.total = 300000
    for i = 1, 300000 do
        Dump.progress.current = i
        local ok, hasSet, setName = pcall(function()
            return GetItemLinkSetInfo(
                string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", i))
        end)
        if ok and hasSet then
            rsv.SetsNames[ZO_CachedStrFormat("<<z:1>>", setName)] = i
        end
    end

    Dump.progress.phase = "br-potions"
    for i = 1, #links.potions do
        local link = string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", links.potions[i])
        rsv.Potions[zo_strlower(GetItemLinkName(link))] = links.potions[i]
    end

    Dump.progress.phase = "br-parts"
    for i = 1, #links.parts do
        local link = string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", links.parts[i])
        rsv.Parts[ZO_CachedStrFormat("<<z:1>>", GetItemLinkName(link))] = links.parts[i]
    end

    Dump.progress.phase = "br-enchant-prefixes"
    local baseEnchantName = zo_strlower(GetItemLinkName("|H1:item:5364:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"))
    for i = 1, #links.enchantPrefixes do
        local fullName = zo_strlower(GetItemLinkName(
            string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", links.enchantPrefixes[i])))
        local prefix = mr(fullName, baseEnchantName .. " ", "")
        if prefix == fullName then
            prefix = mr(fullName, " " .. baseEnchantName, "")
        end
        if prefix ~= fullName and prefix ~= "" then
            rsv.EnchantPrefixes[prefix] = links.enchantPrefixes[i]
        end
    end

    Dump.progress.phase = "br-prefixes"
    for i = 1, #links.prefixes do
        local fullName = ZO_CachedStrFormat("<<z:1>>", GetItemLinkName(
            string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", links.prefixes[i])))
        local baseLink = "|H1:item:" .. string.match(links.prefixes[i], "^(%d+):") .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
        local baseName = ZO_CachedStrFormat("<<z:1>>", GetItemLinkName(baseLink))
        local prefix = mr(fullName, baseName .. " ", "")
        if prefix == fullName then
            prefix = mr(fullName, " " .. baseName, "")
        end
        if prefix ~= fullName and prefix ~= "" then
            rsv.Prefixes[prefix] = links.prefixes[i]
        end
    end

    Dump.progress.phase = "br-affixes"
    local baseAffix = ZO_CachedStrFormat("<<z:1>>", GetItemLinkName("|H1:item:43533:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"))
    for i = 1, #links.affixes do
        local name = ZO_CachedStrFormat("<<z:1>>", GetItemLinkName(
            string.format("|H1:item:43533:0:0:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", links.affixes[i])))
        local key = mr(name, baseAffix .. " ", "")
        if key ~= name and key ~= "" then
            rsv.Affixes[key] = links.affixes[i]
        end
    end

    Dump.progress.phase = "br-locations"
    withLocationsMode("br", function()
        local zonesCount = GetNumZones()
        for i = 1, zonesCount do
            local locName = ZO_CachedStrFormat("<<z:1>>", GetZoneNameByIndex(i))
            if locName then rsv.Locations[locName] = string.format("zone:%d:0", i) end
            local poisCount = GetNumPOIs(i)
            for j = 1, poisCount do
                local poiName = ZO_CachedStrFormat("<<z:1>>", GetPOIInfo(i, j))
                if poiName then rsv.Locations[poiName] = string.format("poi:%d:%d", i, j) end
            end
        end
        for i = 1, GetNumFastTravelNodes() do
            local _, ftName = GetFastTravelNodeInfo(i)
            if ftName then rsv.Locations[ZO_CachedStrFormat("<<z:1>>", ftName)] = string.format("ft:%d:0", i) end
        end
        for i = 1, 1000 do
            local keepName = ZO_CachedStrFormat("<<z:1>>", GetKeepName(i))
            if keepName then rsv.Locations[keepName] = string.format("keep:%d:0", i) end
        end
    end)

    -- Signal to Check() that the English phase should run next
    Reforged.Settings["enDump"] = true
    SetCVar("language.2", "en")
end

-- Collects English-language names. Must run while language.2 == "en".
function Dump.dumpEn()
    local rsv = Reforged.Settings.Data
    local links = Reforged.Data.Links

    Dump.progress.phase = "en-items"
    Dump.progress.total = 300000
    for i = 1, 300000 do
        Dump.progress.current = i
        local ok, itemName = pcall(GetItemLinkName,
            string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", i))
        if ok and itemName and itemName ~= "" and not string.match(itemName, "_") then
            rsv.Items[i] = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, itemName)
        end

        local ok2, hasSet, setName, _, _, _, setId = pcall(function()
            return GetItemLinkSetInfo(
                string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", i))
        end)
        if ok2 and hasSet then
            rsv.Sets[setId] = setName
        end
    end

    Dump.progress.phase = "en-set-names"
    for index, value in pairs(rsv.SetsNames) do
        local id = tonumber(value)
        if id then
            local _, setName = GetItemLinkSetInfo(
                string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", id))
            rsv.SetsNames[index] = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, setName)
        end
    end

    Dump.progress.phase = "en-potions"
    for index, value in pairs(rsv.Potions) do
        rsv.Potions[index] = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME,
            GetItemLinkName(string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", value)))
    end

    Dump.progress.phase = "en-parts"
    for index, value in pairs(rsv.Parts) do
        local id = tonumber(value)
        if id then
            rsv.Parts[index] = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME,
                GetItemLinkName(string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", id)))
        end
    end

    Dump.progress.phase = "en-enchant-prefixes"
    local baseEnchantEn = GetItemLinkName("|H1:item:5364:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")
    for index, value in pairs(rsv.EnchantPrefixes) do
        rsv.EnchantPrefixes[index] = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME,
            mr(GetItemLinkName(string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", value)),
               " " .. baseEnchantEn, ""))
    end

    Dump.progress.phase = "en-prefixes"
    for index, value in pairs(rsv.Prefixes) do
        local baseLink = "|H1:item:" .. string.match(value, "^(%d+):") .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
        local baseName = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(baseLink))
        rsv.Prefixes[index] = mr(
            ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(
                string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", value))),
            " " .. baseName, "")
    end

    Dump.progress.phase = "en-affixes"
    local baseAffixEn = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME,
        GetItemLinkName("|H1:item:43533:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"))
    for index, value in pairs(rsv.Affixes) do
        rsv.Affixes[index] = mr(
            ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(
                string.format("|H1:item:43533:0:0:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", value))),
            baseAffixEn .. " ", "")
    end

    Dump.progress.phase = "en-locations"
    withLocationsMode("br", function()
        for index, value in pairs(rsv.Locations) do
            local locType, locId, locSubId = string.match(value, "^(.*):(%d+):(%d+)$")
            if locType then
                if locType == "zone" then
                    rsv.Locations[index] = ZO_CachedStrFormat(SI_ZONE_NAME, GetZoneNameByIndex(locId))
                elseif locType == "poi" then
                    rsv.Locations[index] = ZO_CachedStrFormat(SI_ZONE_NAME, GetPOIInfo(locId, locSubId))
                elseif locType == "keep" then
                    rsv.Locations[index] = ZO_CachedStrFormat(SI_ZONE_NAME, GetKeepName(locId))
                elseif locType == "ft" then
                    local _, ftName = GetFastTravelNodeInfo(locId)
                    rsv.Locations[index] = ZO_CachedStrFormat(SI_ZONE_NAME, ftName)
                end
            end
        end
    end)

    Dump.progress.phase = "en-traits"
    for i = 1, 100 do
        local traitName = GetString("SI_ITEMTRAITTYPE", i)
        if traitName and traitName ~= "" then rsv.Traits[i] = traitName end
    end

    Dump.progress.phase = "en-abilities"
    local numSkillTypes = GetNumSkillTypes()
    for i = 1, numSkillTypes do
        for j = 1, GetNumSkillLines(i) do
            for k = 1, GetNumSkillAbilities(i, j) do
                local _, _, _, passive = GetSkillAbilityInfo(i, j, k)
                if passive then
                    for l = 1, GetNumPassiveSkillRanks(i, j, k) do
                        local morphId = GetSpecificSkillAbilityInfo(i, j, k, 0, l)
                        rsv.Abilities[morphId] = GetAbilityName(morphId)
                    end
                else
                    for morph = 0, 2 do
                        local morphId = GetSpecificSkillAbilityInfo(i, j, k, morph, 1)
                        rsv.Abilities[morphId] = GetAbilityName(morphId)
                    end
                end
            end
        end
    end

    for key in pairs(links.companionAbilities) do
        rsv.Abilities[key] = GetAbilityName(key)
    end

    for i = 1, GetNumChampionDisciplines() do
        for j = 1, GetNumChampionDisciplineSkills(i) do
            local skillId = GetChampionSkillId(i, j)
            rsv.Abilities[GetChampionAbilityId(skillId)] = GetChampionSkillName(skillId)
        end
    end

    Reforged.Settings["enDump"] = nil
    Reforged.Settings["success"] = true
    rsv.ApiVersion   = GetAPIVersion()
    rsv.AddonVersion = Reforged.VERSION
    Reforged.Settings.IsUpdateNeeded = true

    SetCVar("language.2", "br")
    Dump.progress.phase = "done"
end

-- Checks pending dump flags and dispatches to the correct phase.
-- Called from Reforged.OnPlayerActivated.
function Dump.check()
    local s = Reforged.Settings
    if GetCVar("language.2") == "en" and s["enDump"] ~= nil then
        Dump.dumpEn()
    end
    if GetCVar("language.2") == "br" and s["brDump"] ~= nil then
        s["brDump"] = nil
        Dump.dumpBr()
    end
    if s["success"] ~= nil then
        s["success"] = nil
    end
end

-- Initiates the dump sequence from the BR phase.
-- If language is already "en" (e.g. after maintenance reset), switches back to
-- "br" so the full dumpBr → dumpEn cycle runs correctly on next activation.
function Dump.run()
    Reforged.Settings["enDump"] = nil
    Reforged.Settings["brDump"] = true
    if GetCVar("language.2") == "en" then
        SetCVar("language.2", "br")
    else
        Dump.check()
    end
end

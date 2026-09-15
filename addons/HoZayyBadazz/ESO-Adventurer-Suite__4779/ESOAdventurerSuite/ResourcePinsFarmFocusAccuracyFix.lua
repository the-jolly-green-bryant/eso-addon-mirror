-- ESO Adventurer Suite
-- v0.29.666 - Farm Focus live-target validation and chest rarity glow.
-- Community/learned locations remain useful as navigation hints at range, but
-- close-range Farm Focus markers must agree with ESO's actual interactable.

local EPC = ESOProgressionCoach
local R = EPC and EPC.ResourcePins
if type(R) ~= "table" then return end
if R._easFarmFocusAccuracy029666 then return end
R._easFarmFocusAccuracy029666 = true

local CLOSE_VALIDATE_M = 3.25

local function lower(value)
    value = tostring(value or "")
    if type(zo_strlower) == "function" then
        local ok, text = pcall(zo_strlower, value)
        if ok and type(text) == "string" then return text end
    end
    return string.lower(value)
end

local function getLiveInteractable()
    if type(GetGameCameraInteractableActionInfo) ~= "function" then return nil end
    local ok, action, name, blocked, owned, additionalInfo, context, contextLink, criminal = pcall(GetGameCameraInteractableActionInfo)
    if not ok then return nil end

    name = tostring(name or "")
    local interactionType = nil
    if type(GetInteractionType) == "function" then
        local okType, value = pcall(GetInteractionType)
        if okType then interactionType = value end
    end

    local kind = type(R.ClassifyByName) == "function" and R:ClassifyByName(name) or nil
    local supported = type(R.IsSupportedResourceInteraction) == "function"
        and R:IsSupportedResourceInteraction(interactionType, name) == true

    return {
        name = name,
        kind = kind,
        supported = supported,
        interactionType = interactionType,
        additionalInfo = additionalInfo,
        context = context,
        contextLink = contextLink,
    }
end

local function sameFarmKind(candidateKind, liveKind)
    candidateKind = tostring(candidateKind or "RESOURCE")
    liveKind = tostring(liveKind or "RESOURCE")
    if candidateKind == liveKind then return true end
    if candidateKind == "RESOURCE" or liveKind == "RESOURCE" then return true end

    -- Alchemy subtypes are deliberately compatible with one another because a
    -- community point can be a generic reagent spawn while ESO exposes the
    -- specific plant/mushroom name currently occupying that spawn.
    local alchemy = {
        ALCHEMY = true, MUSHROOM = true, FLOWER = true, WATERPLANT = true,
    }
    if alchemy[candidateKind] and alchemy[liveKind] then return true end
    return false
end

local function chestTierFromContext(live)
    if type(live) ~= "table" or tostring(live.kind or "") ~= "CHEST" then return nil end
    if rawget(_G, "ADDITIONAL_INTERACT_INFO_LOCKED") ~= nil
        and live.additionalInfo ~= rawget(_G, "ADDITIONAL_INTERACT_INFO_LOCKED") then
        return nil
    end

    local context = live.context
    local comparisons = {
        { "LOCK_QUALITY_MASTER", "EPIC" },
        { "LOCK_QUALITY_ADVANCED", "RARE" },
        { "LOCK_QUALITY_INTERMEDIATE", "UNCOMMON" },
        { "LOCK_QUALITY_SIMPLE", "COMMON" },
        { "LOCK_QUALITY_PRACTICE", "COMMON" },
    }
    for i = 1, #comparisons do
        local value = rawget(_G, comparisons[i][1])
        if value ~= nil and context == value then return comparisons[i][2] end
    end

    -- ESO exposes the lock-quality text from the same context value used by the
    -- reticle. Keep a localized-string fallback for API builds where only part
    -- of the LockQuality enum is exported to insecure addon code.
    if context ~= nil and type(GetString) == "function" then
        local ok, text = pcall(GetString, "SI_LOCKQUALITY", context)
        text = ok and lower(text) or ""
        if string.find(text, "master", 1, true) then return "EPIC" end
        if string.find(text, "advanced", 1, true) then return "RARE" end
        if string.find(text, "intermediate", 1, true) then return "UNCOMMON" end
        if string.find(text, "simple", 1, true) or string.find(text, "practice", 1, true) then return "COMMON" end
    end
    return nil
end

local TIER_VISUALS = {
    COMMON = { color = { 0.95, 0.95, 0.95 }, alpha = 0.34 },
    UNCOMMON = { color = { 0.28, 0.86, 1.00 }, alpha = 0.50 },
    RARE = { color = { 0.82, 0.40, 1.00 }, alpha = 0.66 },
    EPIC = { color = { 1.00, 0.78, 0.22 }, alpha = 0.82 },
}

local baseGlow = R.GetGlowVisualForEntry
function R:GetGlowVisualForEntry(entry, alphaBase)
    local forcedTier = type(entry) == "table" and tostring(entry.easFarmLiveTier029666 or "") or ""
    local visual = TIER_VISUALS[forcedTier]
    if visual then
        local saved = EPC.saved or {}
        local strength = math.max(0, math.min(1, (tonumber(saved.resourcePinsGlowStrength) or 78) / 100))
        local alpha = math.max(0.22, math.min(1.0, (tonumber(alphaBase) or 0.72) * visual.alpha * (0.70 + strength * 0.65)))
        local size = 0.98 + (0.08 * strength)
        return visual.color, alpha, size, forcedTier
    end
    if type(baseGlow) == "function" then return baseGlow(self, entry, alphaBase) end
    return { 1, 1, 1 }, tonumber(alphaBase) or 0.72, 1.0, "COMMON"
end

local baseDeduplicate = R.DeduplicateVisibleCandidates
function R:DeduplicateVisibleCandidates(visible)
    if not EPC.saved or EPC.saved.resourcePinsFarmFocusEnabled ~= true or type(visible) ~= "table" then
        return type(baseDeduplicate) == "function" and baseDeduplicate(self, visible) or visible
    end

    local live = getLiveInteractable()
    local liveKind = live and live.supported and live.kind or nil
    local liveTier = chestTierFromContext(live)
    local filtered = {}

    for i = 1, #visible do
        local candidate = visible[i]
        local keep = type(candidate) == "table"
        if keep and candidate.debug ~= true and candidate.focusedMissing ~= true and candidate.skyshard ~= true then
            local distanceM = tonumber(candidate.horizontalDistanceM) or tonumber(candidate.distanceM) or 999999
            if distanceM <= CLOSE_VALIDATE_M then
                local entryKind = candidate.entry and tostring(candidate.entry.kind or "RESOURCE") or "RESOURCE"
                -- At interaction range, a database point is only trustworthy when
                -- ESO currently exposes a compatible live resource. Otherwise it
                -- is a stale/depleted/misaligned navigation hint and must vanish.
                keep = liveKind ~= nil and sameFarmKind(entryKind, liveKind)
                if keep and liveTier and type(candidate.entry) == "table" then
                    candidate.entry.easFarmLiveTier029666 = liveTier
                end
            end
        end
        if keep then filtered[#filtered + 1] = candidate end
    end

    -- Always add one marker for the resource ESO actually exposes under the
    -- reticle. This corrects stale community classifications (for example an
    -- Alchemy point occupying the same area as a live Heavy Sack) and gives a
    -- locked chest its real Simple/Intermediate/Advanced/Master glow.
    if liveKind and type(self.IsKindEnabled) == "function" and self:IsKindEnabled(liveKind)
        and type(self.GetApproximateInteractablePosition) == "function" then
        local zoneId, x, y, z = self:GetApproximateInteractablePosition()
        if zoneId and x and y and z then
            local entry = {
                kind = liveKind,
                name = live.name ~= "" and live.name or liveKind,
                x = x, y = y, z = z,
                source = "live",
                liveConfirmed029666 = true,
                easFarmLiveTier029666 = liveTier,
            }
            filtered[#filtered + 1] = {
                entry = entry,
                distanceM = 1.45,
                horizontalDistanceM = 1.45,
                learned = true,
                liveConfirmed029666 = true,
                noDepletionProbe = true,
            }
        end
    end

    if type(baseDeduplicate) == "function" then return baseDeduplicate(self, filtered) end
    return filtered
end

EPC.resourcePinsFarmFocusAccuracy029666 = true

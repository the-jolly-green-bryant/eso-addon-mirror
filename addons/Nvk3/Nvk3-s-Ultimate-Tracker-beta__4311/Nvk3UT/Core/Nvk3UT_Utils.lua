-- Core/Nvk3UT_Utils.lua
-- Generic helpers shared across the addon. No event wires, no UI construction.
-- This module loads before Core/Nvk3UT_Core.lua, so it cannot assume that the
-- global addon table (Nvk3UT) already exists when the file is executed. The
-- helpers below therefore guard every access to the addon root and expose
-- AttachToRoot so Core can connect the tables once it is ready.
--
-- TODO: After Events/Nvk3UT_EventHandlerBase.lua and the rest of the v3 refactor land,
-- Core/Nvk3UT_Core.lua will call Nvk3UT_Utils.AttachToRoot(Nvk3UT) during OnAddonLoaded()
-- so that all utils are reachable at Nvk3UT.Utils.<fn>. For now we avoid doing that here
-- because Core is not loaded yet at file scope.
--
-- TODO: This module previously bundled tracker/UI specific helpers such as
-- ShouldShowCategoryCounts. Those helpers will be migrated into their
-- controller/layout modules during upcoming migration tokens.

Nvk3UT_Utils = Nvk3UT_Utils or {}

local Utils = Nvk3UT_Utils

local isAttachedToRoot = false

local function ensureRoot()
    if isAttachedToRoot then
        return
    end

    local root = rawget(_G, "Nvk3UT")
    if type(root) == "table" then
        root.Utils = root.Utils or Utils
        isAttachedToRoot = true
    end
end

function Utils.AttachToRoot(root)
    if type(root) ~= "table" then
        return
    end

    root.Utils = root.Utils or Utils
    isAttachedToRoot = true
end

local function formatMessage(fmt, ...)
    if fmt == nil then
        return "<nil>"
    end

    if select("#", ...) > 0 then
        local ok, message = pcall(string.format, tostring(fmt), ...)
        if ok then
            return message
        end
    end

    return tostring(fmt)
end

local function debugInternal(fmt, ...)
    ensureRoot()

    local root = rawget(_G, "Nvk3UT")
    if root and type(root.Debug) == "function" then
        return root.Debug(fmt, ...)
    end

    if type(d) == "function" then
        local message = formatMessage(fmt, ...)
        d("[Nvk3UT Utils] " .. message)
    end
end

function Utils.Debug(fmt, ...)
    return debugInternal(fmt, ...)
end

function Utils.d(...)
    return Utils.Debug(...)
end

function Utils.IsDebugEnabled()
    local root = rawget(_G, "Nvk3UT")
    local diagnostics = (root and root.Diagnostics) or rawget(_G, "Nvk3UT_Diagnostics")
    if diagnostics and type(diagnostics.IsDebugEnabled) == "function" then
        return diagnostics:IsDebugEnabled()
    end
    if root and type(root.IsDebugEnabled) == "function" then
        return root:IsDebugEnabled()
    end
    local sv = root and (root.sv or root.SV)
    if type(sv) == "table" and sv.debug ~= nil then
        return sv.debug == true
    end
    return false
end

Utils.isDebugEnabled = Utils.IsDebugEnabled

local function timestampFallback()
    if type(GetFrameTimeMilliseconds) == "function" then
        local ok, value = pcall(GetFrameTimeMilliseconds)
        if ok and type(value) == "number" then
            return math.floor(value / 1000)
        end
    end

    if type(GetFrameTimeSeconds) == "function" then
        local ok, seconds = pcall(GetFrameTimeSeconds)
        if ok and type(seconds) == "number" then
            return math.floor(seconds)
        end
    end

    return 0
end

function Utils.Now()
    if type(GetTimeStamp) == "function" then
        local ok, stamp = pcall(GetTimeStamp)
        if ok and type(stamp) == "number" then
            return stamp
        end
    end

    return timestampFallback()
end

Utils.now = Utils.Now

local function isValidTexture(path)
    if type(path) ~= "string" or path == "" then
        return false
    end

    if type(GetInterfaceTextureInfo) == "function" then
        local ok, width, height = pcall(GetInterfaceTextureInfo, path)
        if not ok then
            return false
        end
        if type(width) == "number" and type(height) == "number" then
            return (width > 0) and (height > 0)
        end
        return false
    end

    return true
end

local function normalizeTexturePath(path)
    if type(path) ~= "string" or path == "" then
        return nil
    end

    if isValidTexture(path) then
        return path
    end

    local fallback = path:gsub("_64%.dds$", ".dds")
    if fallback ~= path and isValidTexture(fallback) then
        return fallback
    end

    return path
end

function Utils.ResolveTexturePath(path)
    return normalizeTexturePath(path)
end

function Utils.GetIconTagForTexture(path, size)
    local normalized = normalizeTexturePath(path)
    if not normalized then
        return ""
    end

    local iconSize = tonumber(size) or 32
    return string.format("|t%d:%d:%s|t ", iconSize, iconSize, normalized)
end

local MENU_OPTION_LABEL = (_G and _G.MENU_ADD_OPTION_LABEL) or 1

local function evaluateMenuGate(flag, anchorControl)
    if flag == nil then
        return true
    end

    local flagType = type(flag)
    if flagType == "function" then
        local ok, result = pcall(flag, anchorControl)
        if not ok then
            debugInternal("Context menu gate failed: %s", tostring(result))
            return false
        end
        return result ~= false
    end

    if flagType == "boolean" then
        return flag
    end

    return true
end

local function safeSetMenuItemEnabled(index, enabled)
    if type(SetMenuItemEnabled) ~= "function" or type(index) ~= "number" then
        return false
    end

    local ok = pcall(SetMenuItemEnabled, index, enabled ~= false)
    return ok == true
end

local function wrapMenuCallback(callback)
    if type(callback) ~= "function" then
        return function() end
    end

    return function(...)
        if type(ClearMenu) == "function" then
            pcall(ClearMenu)
        end

        local ok, err = pcall(callback, ...)
        if not ok then
            debugInternal("Context menu callback failed: %s", tostring(err))
        end
    end
end

function Utils.ShowContextMenu(anchorControl, entries)
    if not anchorControl or type(entries) ~= "table" then
        return false
    end

    if not (ClearMenu and AddCustomMenuItem and ShowMenu) then
        return false
    end

    ClearMenu()

    local added = 0
    for _, entry in ipairs(entries) do
        if type(entry) == "table" then
            local label = entry.label
            local callback = entry.callback
            if type(label) == "string" and label ~= "" and type(callback) == "function" then
                local visible = evaluateMenuGate(entry.visible, anchorControl)
                if visible then
                    local isEnabled = evaluateMenuGate(entry.enabled, anchorControl)
                    local disabled = not isEnabled
                    local itemType = entry.itemType or MENU_OPTION_LABEL
                    local itemId = entry.itemId
                    local icon = entry.icon
                    local beforeCount = ZO_Menu_GetNumMenuItems() or 0
                    AddCustomMenuItem(
                        label,
                        wrapMenuCallback(callback),
                        itemType,
                        itemId,
                        icon
                    )
                    local afterCount = ZO_Menu_GetNumMenuItems()
                    local itemIndex = afterCount or (beforeCount + 1)
                    if itemIndex then
                        safeSetMenuItemEnabled(itemIndex, not disabled)
                    end
                    added = added + 1
                end
            end
        end
    end

    if added > 0 then
        ShowMenu(anchorControl)
        return true
    end

    ClearMenu()
    return false
end

local function extractLeadingIcons(text)
    if type(text) ~= "string" or text == "" then
        return "", text
    end

    local prefix = ""
    local remainder = text

    while true do
        local iconTag, after = remainder:match("^(|t[^|]-|t%s*)(.*)$")
        if not iconTag then
            break
        end

        prefix = prefix .. iconTag
        remainder = after
    end

    return prefix, remainder
end

function Utils.FormatCategoryHeaderText(baseText, count, showCounts)
    local text = baseText or ""
    local iconPrefix = ""

    if text ~= "" then
        iconPrefix, text = extractLeadingIcons(text)

        if text ~= "" then
            if type(zo_strupper) == "function" then
                text = zo_strupper(text)
            else
                text = string.upper(text)
            end
        end

        text = iconPrefix .. text
    end

    local shouldShowCount = showCounts
    if type(showCounts) == "function" then
        local ok, result = pcall(showCounts)
        shouldShowCount = ok and result ~= false
    elseif showCounts == nil then
        shouldShowCount = true
    else
        shouldShowCount = showCounts ~= false
    end

    local numericCount = tonumber(count)
    if shouldShowCount and numericCount and numericCount >= 0 then
        numericCount = math.floor(numericCount + 0.5)
        return string.format("%s (%d)", text, numericCount)
    end

    return text
end

local function stripLeadingIcon(text)
    if type(text) ~= "string" or text == "" then
        return text
    end

    local previous
    local stripped = text
    repeat
        previous = stripped
        stripped = stripped:gsub("^|t[^|]-|t%s*", "")
    until stripped == previous

    if stripped ~= text then
        stripped = stripped:gsub("^%s+", "")
    end

    return stripped
end

function Utils.StripLeadingIconTag(text)
    return stripLeadingIcon(text)
end

-- TODO: The achievement helpers below will migrate into the Achievement model
-- once those modules are refactored. They remain here temporarily for
-- compatibility with existing callers.

function Utils.GetAchievementCategoryIconTextures(topCategoryId)
    if type(GetAchievementCategoryKeyboardIcons) ~= "function" then
        return nil
    end
    if type(topCategoryId) ~= "number" then
        return nil
    end

    local ok, normal, pressed, mouseover, selected = pcall(GetAchievementCategoryKeyboardIcons, topCategoryId)
    if not ok then
        return nil
    end

    local textures
    local function assign(key, value)
        local normalized = normalizeTexturePath(value)
        if normalized and normalized ~= "" then
            textures = textures or {}
            textures[key] = normalized
        end
    end

    assign("normal", normal)
    assign("pressed", pressed)
    assign("mouseover", mouseover)
    assign("selected", selected)

    if not textures then
        return nil
    end

    local base = textures.normal or textures.pressed or textures.mouseover or textures.selected
    if not base then
        return nil
    end

    textures.normal = textures.normal or base
    textures.pressed = textures.pressed or base
    textures.mouseover = textures.mouseover or textures.pressed or base
    textures.selected = textures.selected or textures.mouseover or base

    return textures
end

function Utils.GetAchievementCategoryIconPath(topCategoryId)
    local textures = Utils.GetAchievementCategoryIconTextures(topCategoryId)
    if not textures then
        return nil
    end
    return textures.normal
end

function Utils.GetAchievementCategoryIconTag(topCategoryId, size)
    local textures = Utils.GetAchievementCategoryIconTextures(topCategoryId)
    if not textures or not textures.normal then
        return ""
    end
    return Utils.GetIconTagForTexture(textures.normal, size)
end

local stageCache = {}

local function currentTimestamp()
    local stamp = Utils.Now()
    if type(stamp) == "number" then
        return stamp
    end
    return 0
end

local function safeAchievementInfo(id)
    if type(GetAchievementInfo) ~= "function" then
        return false
    end
    local ok, _, _, _, completed = pcall(GetAchievementInfo, id)
    if not ok then
        return false
    end
    return completed == true
end

local function computeCriteriaState(id)
    if type(id) ~= "number" then
        return nil
    end
    if type(GetAchievementNumCriteria) ~= "function" or type(GetAchievementCriterion) ~= "function" then
        return nil
    end

    local okCount, numCriteria = pcall(GetAchievementNumCriteria, id)
    if not okCount or type(numCriteria) ~= "number" or numCriteria <= 0 then
        stageCache[id] = {
            total = 0,
            completed = 0,
            stages = {},
            allComplete = safeAchievementInfo(id) == true,
            refreshedAt = currentTimestamp(),
        }
        return stageCache[id]
    end

    local completedCount = 0
    local stageFlags = {}

    for index = 1, numCriteria do
        local okCrit, _, numCompleted, numRequired = pcall(GetAchievementCriterion, id, index)
        if okCrit then
            local achieved = false
            local completedValue = tonumber(numCompleted) or 0
            local requiredValue = tonumber(numRequired) or 0

            if requiredValue > 0 then
                achieved = completedValue >= requiredValue
            else
                achieved = completedValue > 0
            end

            stageFlags[index] = achieved == true
            if stageFlags[index] then
                completedCount = completedCount + 1
            end
        else
            stageFlags[index] = false
        end
    end

    local allComplete = numCriteria > 0 and completedCount >= numCriteria

    stageCache[id] = {
        total = numCriteria,
        completed = completedCount,
        stages = stageFlags,
        allComplete = allComplete,
        refreshedAt = currentTimestamp(),
    }

    return stageCache[id]
end

function Utils.GetAchievementCriteriaState(id, forceRefresh)
    if forceRefresh then
        stageCache[id] = nil
    end
    if not stageCache[id] then
        stageCache[id] = computeCriteriaState(id)
    end
    return stageCache[id]
end

local function isCriteriaComplete(id)
    local state = Utils.GetAchievementCriteriaState(id, true)
    if not state then
        return false
    end
    if state.total <= 0 then
        return state.allComplete == true
    end
    return state.allComplete == true
end

local function getBaseAchievementId(id)
    if type(id) ~= "number" then
        return nil
    end
    if type(ACHIEVEMENTS) == "table" and type(ACHIEVEMENTS.GetBaseAchievementId) == "function" then
        local ok, baseId = pcall(ACHIEVEMENTS.GetBaseAchievementId, ACHIEVEMENTS, id)
        if ok and type(baseId) == "number" and baseId ~= 0 then
            return baseId
        end
    end
    return id
end

local function getNextAchievementId(id)
    if type(GetNextAchievementInLine) ~= "function" then
        return nil
    end
    local ok, nextId = pcall(GetNextAchievementInLine, id)
    if ok and type(nextId) == "number" and nextId ~= 0 then
        return nextId
    end
    return nil
end

local function buildAchievementChain(id)
    if type(id) ~= "number" then
        return nil
    end

    local startId = getBaseAchievementId(id) or id
    if not startId or startId == 0 then
        return nil
    end

    local visited = {}
    local stages = {}
    local stageId = startId

    while type(stageId) == "number" and stageId ~= 0 and not visited[stageId] do
        visited[stageId] = true
        stages[#stages + 1] = stageId
        stageId = getNextAchievementId(stageId)
    end

    local looped = stageId and stageId ~= 0 and visited[stageId] == true

    return {
        startId = startId,
        stages = stages,
        looped = looped,
    }
end

function Utils.NormalizeAchievementId(id)
    local baseId = getBaseAchievementId(id)
    if baseId and baseId ~= 0 then
        return baseId
    end
    return id
end

function Utils.IsMultiStageAchievement(id)
    if type(id) ~= "number" then
        return false
    end

    local chain = buildAchievementChain(id)
    if chain and #chain.stages > 1 then
        return true
    end

    local criteria = Utils.GetAchievementCriteriaState(id)
    if criteria and criteria.total and criteria.total > 1 then
        return true
    end

    if chain and chain.startId and chain.startId ~= id then
        local baseCriteria = Utils.GetAchievementCriteriaState(chain.startId)
        if baseCriteria and baseCriteria.total and baseCriteria.total > 1 then
            return true
        end
    end

    return false
end

function Utils.IsAchievementFullyComplete(id)
    if type(id) ~= "number" then
        return false
    end

    local chain = buildAchievementChain(id)
    if not chain or #chain.stages <= 1 then
        if isCriteriaComplete(id) then
            return true
        end
        local normalized = chain and chain.startId or id
        if normalized ~= id and isCriteriaComplete(normalized) then
            return true
        end
        return safeAchievementInfo(normalized)
    end

    local satisfiedUpstream = false
    for index = #chain.stages, 1, -1 do
        local stageId = chain.stages[index]
        local stageComplete = isCriteriaComplete(stageId) or safeAchievementInfo(stageId) == true
        local satisfied = stageComplete or satisfiedUpstream
        if not satisfied then
            local diagnostics = Nvk3UT and Nvk3UT.Diagnostics
            if diagnostics and diagnostics.Debug_AchStagePending then
                diagnostics.Debug_AchStagePending(id, stageId, index)
            else
                debugInternal(
                    "Achievement stage pending: id=%d stage=%d index=%d",
                    id,
                    stageId,
                    index
                )
            end
            return false
        end
        satisfiedUpstream = satisfied
    end

    if chain.looped then
        return isCriteriaComplete(id) or safeAchievementInfo(id)
    end

    return satisfiedUpstream
end

ensureRoot()

return Utils

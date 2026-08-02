NCollections = NCollections or {}

local Util = {}

local DEFAULT_FONT = "EsoUI/Common/Fonts/FTN57.slug"
local FONT_CHOICES = {
    "EsoUI/Common/Fonts/FTN47.slug",
    DEFAULT_FONT,
    "EsoUI/Common/Fonts/FTN87.slug",
    "EsoUI/Common/Fonts/Univers67.slug",
    "EsoUI/Common/Fonts/Univers57.slug",
    "EsoUI/Common/Fonts/ProseAntiquePSMT.slug",
    "EsoUI/Common/Fonts/Handwritten_Bold.slug",
}
local FONT_CHOICE_NAMES = NCollections.Lexicon.LocalizedList({
    "common.font.gamepad_light",
    "common.font.gamepad_medium",
    "common.font.gamepad_bold",
    "common.font.keyboard_bold",
    "common.font.keyboard_medium",
    "common.font.antique",
    "common.font.handwritten",
})
local LOCALE_FONT_OVERRIDES = {
    ru = {
        default = "EsoUI/Common/Fonts/Univers57Cyrillic-Condensed.slug",
        ["EsoUI/Common/Fonts/FTN87.slug"] = "EsoUI/Common/Fonts/Univers67Cyrillic-CondensedBold.slug",
        ["EsoUI/Common/Fonts/Univers67.slug"] = "EsoUI/Common/Fonts/Univers67Cyrillic-CondensedBold.slug",
        ["EsoUI/Common/Fonts/ProseAntiquePSMT.slug"] = "EsoUI/Common/Fonts/ProseAntiquePSMTCyrillic.slug",
        ["EsoUI/Common/Fonts/Handwritten_Bold.slug"] = "EsoUI/Common/Fonts/HandwrittenCyrillic_Bold.slug",
    },
    jp = {
        default = "EsoUI/Common/Fonts/ESO_FWNTLGUDC70-DB.slug",
        ["EsoUI/Common/Fonts/ProseAntiquePSMT.slug"] = "EsoUI/Common/Fonts/ESO_KafuPenji-M.slug",
        ["EsoUI/Common/Fonts/Handwritten_Bold.slug"] = "EsoUI/Common/Fonts/ESO_KafuPenji-M.slug",
    },
    zh = {
        default = "EsoUI/Common/Fonts/MYingHeiPRC-W5.slug",
        ["EsoUI/Common/Fonts/ProseAntiquePSMT.slug"] = "EsoUI/Common/Fonts/MYoyoPRC-Medium.slug",
        ["EsoUI/Common/Fonts/Handwritten_Bold.slug"] = "EsoUI/Common/Fonts/MYoyoPRC-Medium.slug",
    },
}
local VALID_FONTS = {}
for _, font in ipairs(FONT_CHOICES) do
    VALID_FONTS[font] = true
end

function Util.Clamp(value, minValue, maxValue)
    value = tonumber(value) or minValue

    if zo_clamp then
        return zo_clamp(value, minValue, maxValue)
    end

    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

function Util.Round(value)
    value = tonumber(value) or 0
    return zo_round and zo_round(value) or math.floor(value + 0.5)
end

function Util.IsNonEmptyString(value)
    return type(value) == "string" and value ~= ""
end

function Util.GetLanguage()
    return NCollections.Lexicon and NCollections.Lexicon.GetLanguage() or "en"
end

function Util.Lower(value)
    local text = tostring(value or "")
    return zo_strlower and zo_strlower(text) or string.lower(text)
end

function Util.Upper(value)
    local text = tostring(value or "")
    return zo_strupper and zo_strupper(text) or string.upper(text)
end

function Util.Substring(value, firstIndex, lastIndex)
    local text = tostring(value or "")
    return zo_strsub and zo_strsub(text, firstIndex, lastIndex) or string.sub(text, firstIndex, lastIndex)
end

function Util.UsesCollectionLetterGroups()
    local language = Util.GetLanguage()
    return language ~= "jp" and language ~= "zh"
end

function Util.GetCollectionLetterGroup(value)
    local language = Util.GetLanguage()
    if language == "jp" or language == "zh" then
        return nil, nil
    end

    local first = Util.Upper(Util.Substring(value, 1, 1))
    if language == "ru" then
        if first == "Ё" then first = "Е" end
        local groups = {
            { "А", "Д", "А–Д" }, { "Е", "К", "Е–К" }, { "Л", "П", "Л–П" },
            { "Р", "У", "Р–У" }, { "Ф", "Я", "Ф–Я" },
        }
        for index, group in ipairs(groups) do
            if first >= group[1] and first <= group[2] then return index, group[3] end
        end
        return #groups + 1, NCollections.L("common.other")
    end

    local accents = {
        ["À"] = "A", ["Á"] = "A", ["Â"] = "A", ["Ã"] = "A", ["Ä"] = "A", ["Å"] = "A",
        ["Ç"] = "C", ["È"] = "E", ["É"] = "E", ["Ê"] = "E", ["Ë"] = "E",
        ["Ì"] = "I", ["Í"] = "I", ["Î"] = "I", ["Ï"] = "I", ["Ñ"] = "N",
        ["Ò"] = "O", ["Ó"] = "O", ["Ô"] = "O", ["Õ"] = "O", ["Ö"] = "O",
        ["Ù"] = "U", ["Ú"] = "U", ["Û"] = "U", ["Ü"] = "U", ["Ý"] = "Y",
    }
    first = accents[first] or first
    local groups = { { "A", "D" }, { "E", "H" }, { "I", "L" }, { "M", "P" }, { "Q", "T" }, { "U", "Z" } }
    for index, group in ipairs(groups) do
        if first >= group[1] and first <= group[2] then return index, group[1] .. "–" .. group[2] end
    end
    return #groups + 1, NCollections.L("common.other")
end

local frameTasks = {}
local FRAME_TASK_MIN_BUDGET_MS = 4
local FRAME_TASK_MAX_BUDGET_MS = 8
local FRAME_TASK_FRAME_SHARE = 0.20
local FRAME_TASK_MAX_CHECKPOINTS_PER_FRAME = 1024
local SORT_CHECKPOINT_SIZE = 25
local activeFrameTask
local GARBAGE_COLLECTION_UPDATE_NAMESPACE = "NCollections_DeferredGarbageCollection"
local GARBAGE_COLLECTION_STEP_SIZE = 64
local fullGarbageCollectionRequested = false

local function StopGarbageCollectionUpdate()
    if EVENT_MANAGER and EVENT_MANAGER.UnregisterForUpdate then
        EVENT_MANAGER:UnregisterForUpdate(GARBAGE_COLLECTION_UPDATE_NAMESPACE)
    end
end

local function AdvanceGarbageCollection()
    if fullGarbageCollectionRequested then
        fullGarbageCollectionRequested = false
        collectgarbage("collect")
        StopGarbageCollectionUpdate()
        return
    end
    if not collectgarbage or collectgarbage("step", GARBAGE_COLLECTION_STEP_SIZE) then
        StopGarbageCollectionUpdate()
    end
end

function Util.RequestGarbageCollection(fullCollection)
    if not collectgarbage then return end
    if fullCollection then fullGarbageCollectionRequested = true end
    if EVENT_MANAGER and EVENT_MANAGER.RegisterForUpdate then
        StopGarbageCollectionUpdate()
        EVENT_MANAGER:RegisterForUpdate(GARBAGE_COLLECTION_UPDATE_NAMESPACE, 100, AdvanceGarbageCollection)
    else
        if fullCollection then fullGarbageCollectionRequested = false end
        collectgarbage("collect")
    end
end

local function GetFrameTaskTimeMilliseconds()
    if GetGameTimeMilliseconds then return tonumber(GetGameTimeMilliseconds()) or 0 end
    if GetFrameTimeMilliseconds then return tonumber(GetFrameTimeMilliseconds()) or 0 end
    return 0
end

local function GetFrameTaskBudgetMilliseconds()
    if not GetFrameDeltaTimeMilliseconds then return FRAME_TASK_MIN_BUDGET_MS end
    local frameDuration = tonumber(GetFrameDeltaTimeMilliseconds()) or 0
    if frameDuration <= 0 then return FRAME_TASK_MIN_BUDGET_MS end
    return Util.Clamp(
        frameDuration * FRAME_TASK_FRAME_SHARE,
        FRAME_TASK_MIN_BUDGET_MS,
        FRAME_TASK_MAX_BUDGET_MS
    )
end

local function StopFrameTask(namespace, task)
    if frameTasks[namespace] ~= task then return end
    frameTasks[namespace] = nil
    task.thread = nil
    if EVENT_MANAGER and EVENT_MANAGER.UnregisterForUpdate then
        EVENT_MANAGER:UnregisterForUpdate(namespace)
    end
end

function Util.CancelFrameTask(namespace)
    local task = frameTasks[namespace]
    if task then StopFrameTask(namespace, task) end
end

function Util.StartFrameTask(namespace, worker, onComplete)
    Util.CancelFrameTask(namespace)

    local task = { thread = coroutine.create(worker) }
    frameTasks[namespace] = task
    local function ResumeTask()
        if frameTasks[namespace] ~= task then return end
        local startedAt = GetFrameTaskTimeMilliseconds()
        task.deadline = startedAt + GetFrameTaskBudgetMilliseconds()
        task.checkpoints = 0
        activeFrameTask = task
        local succeeded, failure = coroutine.resume(task.thread)
        activeFrameTask = nil
        if not succeeded then
            StopFrameTask(namespace, task)
            error(failure)
        end
        if coroutine.status(task.thread) == "dead" then
            StopFrameTask(namespace, task)
            if onComplete then onComplete() end
        end
    end

    if EVENT_MANAGER and EVENT_MANAGER.RegisterForUpdate then
        EVENT_MANAGER:RegisterForUpdate(namespace, 0, ResumeTask)
    else
        while frameTasks[namespace] == task do ResumeTask() end
    end
end

function Util.FrameTaskCheckpoint(index, batchSize)
    batchSize = math.max(tonumber(batchSize) or 1, 1)
    if (tonumber(index) or 0) % batchSize ~= 0 then return end
    local running, isMain = coroutine.running()
    if not running or isMain then return end
    local task = activeFrameTask
    if task then
        task.checkpoints = task.checkpoints + 1
        if task.checkpoints < FRAME_TASK_MAX_CHECKPOINTS_PER_FRAME
            and GetFrameTaskTimeMilliseconds() < task.deadline then
            return
        end
    end
    coroutine.yield()
end

local function PassesFrameTaskFilters(value, filters)
    for _, filter in ipairs(filters or {}) do
        if not filter(value) then return false end
    end
    return true
end

function Util.ForEachCollectibleDataObject(manager, categoryFilters, collectibleFilters, callback, batchSize)
    if not manager then return false end

    local processed = 0
    local function VisitCategory(categoryData)
        if not categoryData then return end
        for collectibleIndex = 1, categoryData:GetNumCollectibles() do
            local collectibleData = categoryData:GetCollectibleDataByIndex(collectibleIndex)
            if PassesFrameTaskFilters(collectibleData, collectibleFilters) then callback(collectibleData) end
            processed = processed + 1
            Util.FrameTaskCheckpoint(processed, batchSize)
        end
        if categoryData.IsTopLevelCategory and categoryData:IsTopLevelCategory() then
            for subcategoryIndex = 1, categoryData:GetNumSubcategories() do
                VisitCategory(categoryData:GetSubcategoryData(subcategoryIndex))
            end
        end
    end

    if manager.CategoryIterator then
        for _, categoryData in manager:CategoryIterator() do
            if PassesFrameTaskFilters(categoryData, categoryFilters) then VisitCategory(categoryData) end
        end
        return true
    end

    if not manager.GetAllCollectibleDataObjects then return false end
    local collectibles = manager:GetAllCollectibleDataObjects(categoryFilters, collectibleFilters, false)
    for index, collectibleData in ipairs(collectibles or {}) do
        callback(collectibleData)
        Util.FrameTaskCheckpoint(index, batchSize)
    end
    return true
end

function Util.SortIncrementally(values, compare, batchSize)
    local count = #values
    if count < 2 then return end

    local scratch = {}
    local source = values
    local width = 1
    local work = 0
    while width < count do
        local target = source == values and scratch or values
        local first = 1
        while first <= count do
            local middle = math.min(first + width, count + 1)
            local last = math.min(first + (width * 2) - 1, count)
            local left = first
            local right = middle
            local output = first
            while output <= last do
                if left < middle and (right > last or not compare(source[right], source[left])) then
                    target[output] = source[left]
                    left = left + 1
                else
                    target[output] = source[right]
                    right = right + 1
                end
                output = output + 1
                work = work + 1
                Util.FrameTaskCheckpoint(work, batchSize or SORT_CHECKPOINT_SIZE)
            end
            first = first + (width * 2)
        end
        source = target
        width = width * 2
    end

    if source ~= values then
        for index = 1, count do
            values[index] = source[index]
            Util.FrameTaskCheckpoint(index, batchSize or SORT_CHECKPOINT_SIZE)
        end
    end
end

function Util.GetConsolePlatform()
    local serviceType = GetPlatformServiceType and GetPlatformServiceType() or nil
    if serviceType == PLATFORM_SERVICE_TYPE_XBL then return "XBOX" end
    if serviceType == PLATFORM_SERVICE_TYPE_PSN then return "PS" end

    if serviceType == PLATFORM_SERVICE_TYPE_ZOS
        or serviceType == PLATFORM_SERVICE_TYPE_STEAM
        or serviceType == PLATFORM_SERVICE_TYPE_EPIC
        or serviceType == PLATFORM_SERVICE_TYPE_DMM then
        return "PC"
    end

    return "?"
end

function Util.GetMegaserverName()
    if GetWorldName then
        local worldName = GetWorldName()
        if Util.IsNonEmptyString(worldName) then return worldName end
    end
    return NCollections.L("common.unknown_value")
end

function Util.GetDefaultFont()
    return DEFAULT_FONT
end

function Util.GetFontChoices()
    return FONT_CHOICES
end

function Util.GetFontChoiceNames()
    return FONT_CHOICE_NAMES
end

function Util.IsFontChoice(value)
    return VALID_FONTS[value] == true
end

function Util.ResolveFont(font)
    local localeFonts = LOCALE_FONT_OVERRIDES[Util.GetLanguage()]
    return localeFonts and (localeFonts[font] or localeFonts.default) or font
end

function Util.CreateFontString(font, size, fallbackFont)
    if ZO_CreateFontString then
        local fontStyle = FONT_STYLE_SOFT_SHADOW_THIN or FONT_STYLE_SHADOW or 1
        return ZO_CreateFontString(Util.ResolveFont(font), size, fontStyle)
    end
    return fallbackFont or "ZoFontGamepad34"
end

local function SetContentTextureLoadingState(textureControl)
    if not textureControl then return end

    textureControl:SetHidden(true)
    local loadingControl = textureControl.ncollectionsLoadingControl
    if loadingControl then loadingControl:SetHidden(true) end
    local loadedFrame = textureControl.ncollectionsLoadedFrame
    if loadedFrame then loadedFrame:SetHidden(true) end
end

local function OnContentTextureLoaded(textureControl)
    if not textureControl or not textureControl.ncollectionsRequestedTexturePath then return end
    if textureControl.IsTextureLoaded and not textureControl:IsTextureLoaded() then return end

    textureControl:SetHidden(false)
    local loadingControl = textureControl.ncollectionsLoadingControl
    if loadingControl then loadingControl:SetHidden(true) end
    local loadedFrame = textureControl.ncollectionsLoadedFrame
    if loadedFrame then loadedFrame:SetHidden(false) end
end

local CONTENT_TEXTURE_DELAY_MS = 180
local CONTENT_TEXTURE_UPDATE_INTERVAL_MS = 50
local CONTENT_TEXTURE_UPDATE_NAMESPACE = "NCollections_ContentTextureLoader"
local pendingContentTextures = setmetatable({}, { __mode = "k" })
local contentTextureUpdateRunning = false

local function GetContentTextureTimeMilliseconds()
    if GetFrameTimeMilliseconds then return GetFrameTimeMilliseconds() end
    if GetGameTimeMilliseconds then return GetGameTimeMilliseconds() end
    return 0
end

local function StopContentTextureUpdate()
    if not contentTextureUpdateRunning then return end
    if EVENT_MANAGER and EVENT_MANAGER.UnregisterForUpdate then
        EVENT_MANAGER:UnregisterForUpdate(CONTENT_TEXTURE_UPDATE_NAMESPACE)
    end
    contentTextureUpdateRunning = false
end

local function ProcessPendingContentTextures()
    local now = GetContentTextureTimeMilliseconds()
    local hasPendingTexture = false

    for textureControl in pairs(pendingContentTextures) do
        local texturePath = textureControl.ncollectionsRequestedTexturePath
        local loadAt = textureControl.ncollectionsContentTextureLoadAt
        if not texturePath or not loadAt then
            pendingContentTextures[textureControl] = nil
        elseif now >= loadAt then
            pendingContentTextures[textureControl] = nil
            textureControl.ncollectionsContentTextureLoadAt = nil
            textureControl:SetTexture(texturePath)
            if not textureControl.IsTextureLoaded or textureControl:IsTextureLoaded() then
                OnContentTextureLoaded(textureControl)
            end
        else
            hasPendingTexture = true
        end
    end

    if not hasPendingTexture and not next(pendingContentTextures) then StopContentTextureUpdate() end
end

local function StartContentTextureUpdate()
    if contentTextureUpdateRunning then return end
    if not EVENT_MANAGER or not EVENT_MANAGER.RegisterForUpdate then
        for textureControl in pairs(pendingContentTextures) do
            textureControl.ncollectionsContentTextureLoadAt = 0
        end
        ProcessPendingContentTextures()
        return
    end

    contentTextureUpdateRunning = true
    EVENT_MANAGER:RegisterForUpdate(CONTENT_TEXTURE_UPDATE_NAMESPACE, CONTENT_TEXTURE_UPDATE_INTERVAL_MS, ProcessPendingContentTextures)
end

function Util.ConfigureContentTexture(textureControl, loadingControl, loadedFrame)
    if not textureControl then return end

    textureControl.ncollectionsLoadingControl = loadingControl
    textureControl.ncollectionsLoadedFrame = loadedFrame
    SetContentTextureLoadingState(textureControl)
    if textureControl.SetTextureReleaseOption and RELEASE_TEXTURE_AT_ZERO_REFERENCES then
        textureControl:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
    end
    if textureControl.SetHandler then
        textureControl:SetHandler("OnTextureLoaded", OnContentTextureLoaded)
    end
end

function Util.ReleaseContentTexture(textureControl)
    if not textureControl then return end

    pendingContentTextures[textureControl] = nil
    textureControl.ncollectionsRequestedTexturePath = nil
    textureControl.ncollectionsContentTextureLoadAt = nil
    textureControl:SetTexture(nil)
    SetContentTextureLoadingState(textureControl)
    if not next(pendingContentTextures) then StopContentTextureUpdate() end
end

function Util.LoadContentTexture(textureControl, texturePath)
    if not textureControl or not Util.IsNonEmptyString(texturePath) then
        Util.ReleaseContentTexture(textureControl)
        return false
    end

    textureControl.ncollectionsRequestedTexturePath = nil
    textureControl.ncollectionsContentTextureLoadAt = nil
    textureControl:SetTexture(nil)
    SetContentTextureLoadingState(textureControl)
    textureControl.ncollectionsRequestedTexturePath = texturePath
    textureControl.ncollectionsContentTextureLoadAt = GetContentTextureTimeMilliseconds() + CONTENT_TEXTURE_DELAY_MS
    pendingContentTextures[textureControl] = true
    StartContentTextureUpdate()
    return true
end

NCollections.Util = Util

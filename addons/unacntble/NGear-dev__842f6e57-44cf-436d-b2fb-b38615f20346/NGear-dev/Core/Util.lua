NGear = NGear or {}

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
local FONT_CHOICE_NAMES = NGear.Lexicon.LocalizedList({
    "common.font.gamepad_light",
    "common.font.gamepad_medium",
    "common.font.gamepad_bold",
    "common.font.keyboard_bold",
    "common.font.keyboard_medium",
    "common.font.antique",
    "common.font.handwritten",
})
local VALID_FONTS = {}
for _, font in ipairs(FONT_CHOICES) do
    VALID_FONTS[font] = true
end
local LATIN_INITIALS = {
    ["À"] = "A", ["Á"] = "A", ["Â"] = "A", ["Ã"] = "A", ["Ä"] = "A", ["Å"] = "A",
    ["Ç"] = "C", ["È"] = "E", ["É"] = "E", ["Ê"] = "E", ["Ë"] = "E",
    ["Ì"] = "I", ["Í"] = "I", ["Î"] = "I", ["Ï"] = "I", ["Ñ"] = "N",
    ["Ò"] = "O", ["Ó"] = "O", ["Ô"] = "O", ["Õ"] = "O", ["Ö"] = "O",
    ["Ù"] = "U", ["Ú"] = "U", ["Û"] = "U", ["Ü"] = "U", ["Ý"] = "Y",
}

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
    return NGear.Lexicon and NGear.Lexicon.GetLanguage and NGear.Lexicon.GetLanguage() or "en"
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

function Util.GetCollectionInitial(value)
    local language = Util.GetLanguage()
    local first = Util.Upper(Util.Substring(value, 1, 1))
    local other = NGear.L and NGear.L("common.other") or "Other"
    if first == "" then return other end
    if language == "jp" or language == "zh" then return first end
    if language == "ru" then
        if first == "Ё" then first = "Е" end
        return first >= "А" and first <= "Я" and first or other
    end
    first = LATIN_INITIALS[first] or first
    return first >= "A" and first <= "Z" and first or other
end

function Util.GetCollectionLetterGroup(value)
    local language = Util.GetLanguage()
    if language == "jp" or language == "zh" then
        return nil, nil
    end

    local first = Util.GetCollectionInitial(value)
    if language == "ru" then
        local groups = {
            { "А", "Д", "А–Д" }, { "Е", "К", "Е–К" }, { "Л", "П", "Л–П" },
            { "Р", "У", "Р–У" }, { "Ф", "Я", "Ф–Я" },
        }
        for index, group in ipairs(groups) do
            if first >= group[1] and first <= group[2] then return index, group[3] end
        end
        return #groups + 1, NGear.L("common.other")
    end

    local groups = { { "A", "D" }, { "E", "H" }, { "I", "L" }, { "M", "P" }, { "Q", "T" }, { "U", "Z" } }
    for index, group in ipairs(groups) do
        if first >= group[1] and first <= group[2] then return index, group[1] .. "–" .. group[2] end
    end
    return #groups + 1, NGear.L("common.other")
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
    return NGear.L("common.unknown_value")
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

local function SetContentTextureLoadingState(textureControl)
    if not textureControl then return end

    textureControl:SetHidden(true)
    local loadingControl = textureControl.ngearLoadingControl
    if loadingControl then loadingControl:SetHidden(true) end
    local loadedFrame = textureControl.ngearLoadedFrame
    if loadedFrame then loadedFrame:SetHidden(true) end
end

local function OnContentTextureLoaded(textureControl)
    if not textureControl or not textureControl.ngearRequestedTexturePath then return end
    if textureControl.IsTextureLoaded and not textureControl:IsTextureLoaded() then return end

    textureControl:SetHidden(false)
    local loadingControl = textureControl.ngearLoadingControl
    if loadingControl then loadingControl:SetHidden(true) end
    local loadedFrame = textureControl.ngearLoadedFrame
    if loadedFrame then loadedFrame:SetHidden(false) end
end

local CONTENT_TEXTURE_DELAY_MS = 180
local CONTENT_TEXTURE_UPDATE_INTERVAL_MS = 50
local CONTENT_TEXTURE_UPDATE_NAMESPACE = "NGear_ContentTextureLoader"
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
        local texturePath = textureControl.ngearRequestedTexturePath
        local loadAt = textureControl.ngearContentTextureLoadAt
        if not texturePath or not loadAt then
            pendingContentTextures[textureControl] = nil
        elseif now >= loadAt then
            pendingContentTextures[textureControl] = nil
            textureControl.ngearContentTextureLoadAt = nil
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
            textureControl.ngearContentTextureLoadAt = 0
        end
        ProcessPendingContentTextures()
        return
    end

    contentTextureUpdateRunning = true
    EVENT_MANAGER:RegisterForUpdate(CONTENT_TEXTURE_UPDATE_NAMESPACE, CONTENT_TEXTURE_UPDATE_INTERVAL_MS, ProcessPendingContentTextures)
end

function Util.ConfigureContentTexture(textureControl, loadingControl, loadedFrame)
    if not textureControl then return end

    textureControl.ngearLoadingControl = loadingControl
    textureControl.ngearLoadedFrame = loadedFrame
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
    textureControl.ngearRequestedTexturePath = nil
    textureControl.ngearContentTextureLoadAt = nil
    textureControl:SetTexture(nil)
    SetContentTextureLoadingState(textureControl)
    if not next(pendingContentTextures) then StopContentTextureUpdate() end
end

function Util.LoadContentTexture(textureControl, texturePath)
    if not textureControl or not Util.IsNonEmptyString(texturePath) then
        Util.ReleaseContentTexture(textureControl)
        return false
    end

    textureControl.ngearRequestedTexturePath = nil
    textureControl.ngearContentTextureLoadAt = nil
    textureControl:SetTexture(nil)
    SetContentTextureLoadingState(textureControl)
    textureControl.ngearRequestedTexturePath = texturePath
    textureControl.ngearContentTextureLoadAt = GetContentTextureTimeMilliseconds() + CONTENT_TEXTURE_DELAY_MS
    pendingContentTextures[textureControl] = true
    StartContentTextureUpdate()
    return true
end

NGear.Util = Util

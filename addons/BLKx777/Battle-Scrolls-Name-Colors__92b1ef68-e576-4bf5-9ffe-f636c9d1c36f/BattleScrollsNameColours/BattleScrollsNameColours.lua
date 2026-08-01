local ADDON_NAME = "BattleScrollsNameColours"
local DISPLAY_NAME = "Battle Scrolls Name Colours"
local VERSION = "0.4.12-beta"

BattleScrollsNameColours = BattleScrollsNameColours or {}
local BSNC = BattleScrollsNameColours

local STYLE_PLAIN = "plain"
local STYLE_GRADIENT = "gradient"
local STYLE_TO_ID = {
    [STYLE_PLAIN] = 1,
    [STYLE_GRADIENT] = 2,
}

local ID_TO_STYLE = {
    [1] = STYLE_PLAIN,
    [2] = STYLE_GRADIENT,
}

local STYLE_LABELS = {
    [STYLE_PLAIN] = "Plain colour",
    [STYLE_GRADIENT] = "Gradient",
}

local COLOUR_PRESETS = {
    { id = 1,  name = "Black",       hex = "000000" },
    { id = 2,  name = "Near Black",  hex = "101010" },
    { id = 3,  name = "Charcoal",    hex = "1E1E1E" },
    { id = 4,  name = "Graphite",    hex = "303030" },
    { id = 5,  name = "Slate",       hex = "46505A" },
    { id = 6,  name = "Steel",       hex = "6E7681" },
    { id = 7,  name = "Ash",         hex = "8A8A8A" },
    { id = 8,  name = "Silver",      hex = "C0C0C0" },
    { id = 9,  name = "Pale Silver", hex = "E0E0E0" },
    { id = 10, name = "White",       hex = "FFFFFF" },
    { id = 11, name = "Blood",       hex = "8B0000" },
    { id = 12, name = "Crimson",     hex = "C1121F" },
    { id = 13, name = "Scarlet",     hex = "FF2400" },
    { id = 14, name = "Red",         hex = "FF2020" },
    { id = 15, name = "Rose",        hex = "D7265F" },
    { id = 16, name = "Coral",       hex = "FF6B6B" },
    { id = 17, name = "Ember",       hex = "FF4500" },
    { id = 18, name = "Orange",      hex = "FF7A00" },
    { id = 19, name = "Amber",       hex = "FFBF00" },
    { id = 20, name = "Gold",        hex = "FFD700" },
    { id = 21, name = "Pale Gold",   hex = "FFE680" },
    { id = 22, name = "Yellow",      hex = "FFFF40" },
    { id = 23, name = "Lime",        hex = "BFFF00" },
    { id = 24, name = "Toxic",       hex = "7CFF00" },
    { id = 25, name = "Green",       hex = "22C55E" },
    { id = 26, name = "Emerald",     hex = "00A86B" },
    { id = 27, name = "Forest",      hex = "228B22" },
    { id = 28, name = "Mint",        hex = "98FF98" },
    { id = 29, name = "Teal",        hex = "008080" },
    { id = 30, name = "Turquoise",   hex = "40E0D0" },
    { id = 31, name = "Aqua",        hex = "00FFFF" },
    { id = 32, name = "Cyan",        hex = "00D5FF" },
    { id = 33, name = "Ice Blue",    hex = "AFEFFF" },
    { id = 34, name = "Sky Blue",    hex = "87CEEB" },
    { id = 35, name = "Azure",       hex = "007FFF" },
    { id = 36, name = "Royal Blue",  hex = "4169E1" },
    { id = 37, name = "Blue",        hex = "205DFF" },
    { id = 38, name = "Deep Blue",   hex = "00008B" },
    { id = 39, name = "Indigo",      hex = "4B0082" },
    { id = 40, name = "Violet",      hex = "8F00FF" },
    { id = 41, name = "Purple",      hex = "A020F0" },
    { id = 42, name = "Magenta",     hex = "FF00FF" },
    { id = 43, name = "Hot Pink",    hex = "FF1493" },
    { id = 44, name = "Pink",        hex = "FF69B4" },
    { id = 45, name = "Rose Pink",   hex = "FF8ACD" },
    { id = 46, name = "Lavender",    hex = "C8A2C8" },
    { id = 47, name = "Bronze",      hex = "CD7F32" },
    { id = 48, name = "Copper",      hex = "B87333" },
    { id = 49, name = "Tan",         hex = "D2B48C" },
    { id = 50, name = "Ivory",       hex = "FFFFF0" },
}

local COLOUR_BY_ID = {}
local COLOUR_DROPDOWN_ITEMS = {}

for _, colour in ipairs(COLOUR_PRESETS) do
    COLOUR_BY_ID[colour.id] = colour
    COLOUR_DROPDOWN_ITEMS[#COLOUR_DROPDOWN_ITEMS + 1] = { name = colour.name, data = colour.id }
end


local DEFAULTS = {
    enabled = true,
    colourHex = "FF0000",
    gradientHex = "FFFFFF",
    solidColourId = 14,
    gradientStartColourId = 14,
    gradientEndColourId = 33,
    style = STYLE_PLAIN,
    livePreview = true,
}

local PROTOCOL_ID = 439
local STALE_REMOTE_PROFILE_MS = 300000
local STALE_CLEAN_INTERVAL_MS = 60000
local REFRESH_DELAY_MS = 80
local PROFILE_BROADCAST_MIN_INTERVAL_MS = 10000

local sv
local remoteProfiles = {}
local patchedDesigns = setmetatable({}, { __mode = "k" })
local didPatchApplyGroupDesign = false
local didPatchUpdateGroupDisplay = false
local broadcastProtocol = nil
local broadcastSetupAttempted = false
local delayedBroadcastScheduled = false
local refreshScheduled = false
local settingsRegistered = false
local livePreviewControl = nil
local livePreviewLabel = nil
local livePreviewTimerId = nil
local ownNameLookupCache = nil
local ownProfileCache = {}
local formattedNameCache = {}
local formattedNameCacheCount = 0
local labelState = setmetatable({}, { __mode = "k" })
local visitTokenByControl = setmetatable({}, { __mode = "k" })
local visitToken = 0
local lastStaleCleanMs = 0
local lastProfileBroadcastMs = 0

local function NowMs()
    if GetFrameTimeMilliseconds then
        return GetFrameTimeMilliseconds()
    end
    return 0
end

local function StripESOColourCodes(text)
    text = tostring(text or "")
    text = text:gsub("|c%x%x%x%x%x%x", "")
    text = text:gsub("|C%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    text = text:gsub("|R", "")
    return text
end

local function NormaliseHex(value)
    local hex = tostring(value or "")
    hex = hex:gsub("%s+", "")
    hex = hex:gsub("^#", "")
    hex = hex:gsub("^|c", "")
    hex = hex:gsub("^|C", "")
    hex = hex:gsub("|r$", "")
    hex = hex:gsub("|R$", "")
    hex = hex:upper()

    if hex:match("^[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]$") then
        return hex
    end

    return nil
end

local function HexToNumber(hex)
    hex = NormaliseHex(hex)
    if not hex then return nil end
    return tonumber(hex, 16)
end

local function NumberToHex(value)
    value = tonumber(value)
    if not value then return nil end
    if value < 0 then return nil end
    if value > 0xFFFFFF then return nil end
    return string.format("%06X", value)
end

local function ClampByte(value)
    value = tonumber(value) or 0
    if value < 0 then return 0 end
    if value > 255 then return 255 end
    return zo_round and zo_round(value) or math.floor(value + 0.5)
end

local function HexToRGB(hex)
    hex = NormaliseHex(hex) or "FFFFFF"
    return tonumber(hex:sub(1, 2), 16) or 255,
           tonumber(hex:sub(3, 4), 16) or 255,
           tonumber(hex:sub(5, 6), 16) or 255
end

local function RGBToHex(r, g, b)
    return string.format("%02X%02X%02X", ClampByte(r), ClampByte(g), ClampByte(b))
end

local function ValidStyle(style)
    if style == STYLE_GRADIENT or style == STYLE_PLAIN then
        return style
    end
    return STYLE_PLAIN
end

local function ValidColourId(id, fallbackId)
    id = tonumber(id)
    if id and COLOUR_BY_ID[id] then
        return id
    end
    return fallbackId
end

local function GetPresetHex(id, fallbackId)
    id = ValidColourId(id, fallbackId)
    local preset = COLOUR_BY_ID[id]
    return preset and preset.hex or "FFFFFF"
end

local function GetPresetName(id, fallbackId)
    id = ValidColourId(id, fallbackId)
    local preset = COLOUR_BY_ID[id]
    return preset and preset.name or "White"
end

local function FindClosestColourId(hex, fallbackId)
    hex = NormaliseHex(hex)
    if not hex then return fallbackId end

    local r, g, b = HexToRGB(hex)
    local bestId = fallbackId
    local bestDistance = nil

    for _, preset in ipairs(COLOUR_PRESETS) do
        local pr, pg, pb = HexToRGB(preset.hex)
        local dr = r - pr
        local dg = g - pg
        local db = b - pb
        local distance = (dr * dr) + (dg * dg) + (db * db)
        if not bestDistance or distance < bestDistance then
            bestDistance = distance
            bestId = preset.id
        end
    end

    return bestId
end

local function ColourText(text, hex)
    if not text or text == "" then return text end
    hex = NormaliseHex(hex)
    if not hex then return text end
    return "|c" .. hex .. StripESOColourCodes(text) .. "|r"
end

local function InterpolateByte(a, b, t)
    return ClampByte(a + ((b - a) * t))
end

local function GetLinearGradientHex(startHex, endHex, index, length)
    startHex = NormaliseHex(startHex) or "FFFFFF"
    endHex = NormaliseHex(endHex) or "FFFFFF"
    index = tonumber(index) or 1
    length = tonumber(length) or 1

    if length <= 1 then
        return startHex
    end

    local r1, g1, b1 = HexToRGB(startHex)
    local r2, g2, b2 = HexToRGB(endHex)
    local t = (index - 1) / (length - 1)
    local r = InterpolateByte(r1, r2, t)
    local g = InterpolateByte(g1, g2, t)
    local b = InterpolateByte(b1, b2, t)
    return RGBToHex(r, g, b)
end

local function GradientText(text, startHex, endHex)
    text = StripESOColourCodes(text)
    if text == "" then return text end

    local length = string.len(text)
    if length <= 1 then
        return ColourText(text, startHex)
    end

    local output = {}
    for i = 1, length do
        output[#output + 1] = "|c" .. GetLinearGradientHex(startHex, endHex, i, length) .. text:sub(i, i) .. "|r"
    end

    return table.concat(output)
end

local function ClearFormattedNameCache()
    formattedNameCache = {}
    formattedNameCacheCount = 0
end

local function GetProfileCacheKey(profile)
    if not profile then return "" end

    local style = ValidStyle(profile.style)
    local parts = {
        style,
        NormaliseHex(profile.colourHex) or DEFAULTS.colourHex,
        NormaliseHex(profile.gradientHex) or DEFAULTS.gradientHex,
    }

    return table.concat(parts, ":")
end


local function FormatNameWithProfile(rawName, profile)
    if not profile then return rawName end

    rawName = StripESOColourCodes(rawName)
    local profileKey = GetProfileCacheKey(profile)
    local cacheKey = rawName .. "\31" .. profileKey
    local cached = formattedNameCache[cacheKey]
    if cached then
        return cached
    end

    local style = ValidStyle(profile.style)
    local primary = NormaliseHex(profile.colourHex) or DEFAULTS.colourHex
    local gradient = NormaliseHex(profile.gradientHex) or DEFAULTS.gradientHex
    local result

    if style == STYLE_GRADIENT then
        result = GradientText(rawName, primary, gradient)
    else
        result = ColourText(rawName, primary)
    end

    if formattedNameCacheCount > 96 then
        ClearFormattedNameCache()
    end
    formattedNameCache[cacheKey] = result
    formattedNameCacheCount = formattedNameCacheCount + 1
    return result
end

local function ApplyProfileToLabel(label, rawName, profile, fontSize)
    if not label or not profile then return false end

    local state = labelState[label]
    if not state then
        state = {}
        labelState[label] = state
    end

    rawName = StripESOColourCodes(rawName)
    local styleKey = rawName .. "\31" .. GetProfileCacheKey(profile)

    if type(label.SetText) == "function" and state.appliedTextKey ~= styleKey then
        local styledName = FormatNameWithProfile(rawName, profile)
        pcall(label.SetText, label, styledName)
        state.appliedTextKey = styleKey
    end

    return true
end

local function StripStyleDecorations(text)
    text = StripESOColourCodes(text)
    text = text:gsub("^▌", "")
    text = text:gsub("▐$", "")
    return text
end

local function GetOwnDisplayName()
    if GetDisplayName then
        return GetDisplayName()
    end
    return nil
end

local function AddNameToLookup(lookup, value)
    value = StripESOColourCodes(value)
    if value and value ~= "" then
        lookup[value] = true
    end
end

local function BuildOwnNameLookup()
    if ownNameLookupCache then
        return ownNameLookupCache
    end

    local lookup = {}

    AddNameToLookup(lookup, GetOwnDisplayName())

    if GetUnitDisplayName then
        AddNameToLookup(lookup, GetUnitDisplayName("player"))
    end

    if GetUnitName then
        AddNameToLookup(lookup, GetUnitName("player"))
    end

    if GetRawUnitName then
        AddNameToLookup(lookup, GetRawUnitName("player"))
    end

    if BattleScrolls and BattleScrolls.utils and BattleScrolls.utils.GetUndecoratedDisplayName then
        local ok, name = pcall(BattleScrolls.utils.GetUndecoratedDisplayName, "player")
        if ok then
            AddNameToLookup(lookup, name)
        end
    end

    ownNameLookupCache = lookup
    return lookup
end

local function IsOwnVisibleName(rawName)
    rawName = StripESOColourCodes(rawName)
    if not rawName or rawName == "" then return false end
    return BuildOwnNameLookup()[rawName] == true
end

local function IsGrouped()
    if IsUnitGrouped then
        return IsUnitGrouped("player")
    end
    if GetGroupSize then
        return GetGroupSize() > 0
    end
    return false
end

local function GetUndecoratedNameFromUnitTag(unitTag)
    if BattleScrolls and BattleScrolls.utils and BattleScrolls.utils.GetUndecoratedDisplayName then
        local ok, name = pcall(BattleScrolls.utils.GetUndecoratedDisplayName, unitTag)
        if ok and name and name ~= "" then
            return StripESOColourCodes(name)
        end
    end

    if GetUnitDisplayName then
        local name = GetUnitDisplayName(unitTag)
        if name and name ~= "" then
            return StripESOColourCodes(name)
        end
    end

    return nil
end

local function SaveRemoteProfile(rawName, colourHex, style, gradientHex)
    rawName = StripESOColourCodes(rawName)
    colourHex = NormaliseHex(colourHex)
    gradientHex = NormaliseHex(gradientHex) or DEFAULTS.gradientHex
    style = ValidStyle(style)

    if not rawName or rawName == "" or not colourHex then
        return
    end

    remoteProfiles[rawName] = {
        colourHex = colourHex,
        gradientHex = gradientHex,
        style = style,
        lastSeen = NowMs(),
    }
end

local function CleanStaleRemoteProfiles()
    local now = NowMs()
    if now <= 0 or now - lastStaleCleanMs < STALE_CLEAN_INTERVAL_MS then return end
    lastStaleCleanMs = now

    for name, profile in pairs(remoteProfiles) do
        if profile.lastSeen and now - profile.lastSeen > STALE_REMOTE_PROFILE_MS then
            remoteProfiles[name] = nil
        end
    end
end

local function GetOwnProfile()
    if not sv then return nil end

    local style = ValidStyle(sv.style)
    local primaryHex
    local gradientHex

    if style == STYLE_GRADIENT then
        primaryHex = GetPresetHex(sv.gradientStartColourId, DEFAULTS.gradientStartColourId)
        gradientHex = GetPresetHex(sv.gradientEndColourId, DEFAULTS.gradientEndColourId)
    else
        primaryHex = GetPresetHex(sv.solidColourId, DEFAULTS.solidColourId)
        gradientHex = GetPresetHex(sv.gradientEndColourId, DEFAULTS.gradientEndColourId)
    end

    ownProfileCache.colourHex = primaryHex
    ownProfileCache.gradientHex = gradientHex
    ownProfileCache.style = style
    return ownProfileCache
end

function BSNC.GetProfileForName(rawName)
    if not sv or not sv.enabled then
        return nil
    end

    rawName = StripESOColourCodes(rawName)
    if IsOwnVisibleName(rawName) then
        return GetOwnProfile()
    end

    return remoteProfiles[rawName]
end

function BSNC.GetStyledName(rawName)
    return FormatNameWithProfile(rawName, BSNC.GetProfileForName(rawName))
end

local function CreateLivePreviewControl()
    if livePreviewControl then return end
    if not WINDOW_MANAGER or not GuiRoot then return end

    livePreviewControl = WINDOW_MANAGER:CreateTopLevelWindow("BSNC_LivePreview")
    livePreviewControl:SetDimensions(520, 54)
    livePreviewControl:SetAnchor(TOP, GuiRoot, TOP, 0, 125)
    livePreviewControl:SetDrawTier(DT_HIGH)
    livePreviewControl:SetDrawLayer(DL_OVERLAY)
    livePreviewControl:SetHidden(true)

    local bg = WINDOW_MANAGER:CreateControl("BSNC_LivePreviewBG", livePreviewControl, CT_BACKDROP)
    bg:SetAnchorFill(livePreviewControl)
    bg:SetCenterColor(0, 0, 0, 0.72)
    bg:SetEdgeColor(1, 1, 1, 0.15)

    livePreviewLabel = WINDOW_MANAGER:CreateControl("BSNC_LivePreviewLabel", livePreviewControl, CT_LABEL)
    livePreviewLabel:SetAnchor(CENTER, livePreviewControl, CENTER, 0, 0)
    livePreviewLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    livePreviewLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    livePreviewLabel:SetFont("$(BOLD_FONT)|24|soft-shadow-thick")
    livePreviewLabel:SetText("Preview")
end

function BSNC.ShowLivePreview(durationMs)
    if not sv or sv.livePreview == false then return end

    CreateLivePreviewControl()
    if not livePreviewControl or not livePreviewLabel then return end

    local name = GetUndecoratedNameFromUnitTag("player") or GetOwnDisplayName() or "@PlayerName"
    local profile = GetOwnProfile()
    livePreviewLabel:SetText("Preview: " .. FormatNameWithProfile(name, profile))
    livePreviewControl:SetHidden(false)

    if livePreviewTimerId then
        zo_removeCallLater(livePreviewTimerId)
        livePreviewTimerId = nil
    end

    livePreviewTimerId = zo_callLater(function()
        livePreviewTimerId = nil
        if livePreviewControl then
            livePreviewControl:SetHidden(true)
        end
    end, durationMs or 4500)
end

function BSNC.ApplyDirectMeterStyling()
    if not sv or not sv.enabled then return end

    visitToken = visitToken + 1

    local function visit(control, depth)
        if not control or visitTokenByControl[control] == visitToken or depth > 10 then return end
        visitTokenByControl[control] = visitToken

        if type(control.GetText) == "function" and type(control.SetText) == "function" then
            local okText, currentText = pcall(control.GetText, control)
            if okText and currentText and currentText ~= "" then
                local rawText = StripStyleDecorations(currentText)
                local profile = BSNC.GetProfileForName(rawText)
                if profile then
                    ApplyProfileToLabel(control, rawText, profile)
                end
            end
        end

        if type(control.GetNumChildren) == "function" and type(control.GetChild) == "function" then
            local okCount, count = pcall(control.GetNumChildren, control)
            if okCount and count then
                for i = 1, count do
                    local okChild, child = pcall(control.GetChild, control, i)
                    if okChild and child then
                        visit(child, depth + 1)
                    end
                end
            end
        end
    end

    visit(_G.BattleScrolls_DPSMeterGroup, 0)
    visit(_G.BattleScrolls_DPSMeterGroupDefault, 0)
    visit(_G.BattleScrolls_DPSMeterGroupHodor, 0)
    visit(_G.BattleScrolls_DPSMeterGroupBars, 0)
end

function BSNC.RefreshBattleScrolls()
    BSNC.PatchBattleScrolls()

    local updated = false
    if BattleScrolls and BattleScrolls.dpsMeter and type(BattleScrolls.dpsMeter.UpdateGroupDisplay) == "function" then
        updated = pcall(BattleScrolls.dpsMeter.UpdateGroupDisplay, BattleScrolls.dpsMeter)
    end

    if not updated then
        BSNC.ApplyDirectMeterStyling()
    end
end

function BSNC.ScheduleRefresh()
    if refreshScheduled then return end
    refreshScheduled = true

    zo_callLater(function()
        refreshScheduled = false
        BSNC.RefreshBattleScrolls()
    end, REFRESH_DELAY_MS)
end

function BSNC.ScheduleProfileBroadcast()
    if delayedBroadcastScheduled then return end
    delayedBroadcastScheduled = true

    zo_callLater(function()
        delayedBroadcastScheduled = false
        BSNC.BroadcastProfile()
    end, 1000)
end

function BSNC.OnProfileChanged(shouldBroadcast)
    if not sv then return end

    sv.solidColourId = ValidColourId(sv.solidColourId, DEFAULTS.solidColourId)
    sv.gradientStartColourId = ValidColourId(sv.gradientStartColourId, DEFAULTS.gradientStartColourId)
    sv.gradientEndColourId = ValidColourId(sv.gradientEndColourId, DEFAULTS.gradientEndColourId)
    sv.style = ValidStyle(sv.style)
    if sv.livePreview == nil then sv.livePreview = DEFAULTS.livePreview end

    local profile = GetOwnProfile()
    sv.colourHex = profile.colourHex
    sv.gradientHex = profile.gradientHex

    ClearFormattedNameCache()
    BSNC.ScheduleRefresh()
    BSNC.ShowLivePreview(4500)

    if shouldBroadcast ~= false then
        BSNC.ScheduleProfileBroadcast()
    end
end

function BSNC.SetColourPreset(settingName, colourId, shouldBroadcast)
    colourId = ValidColourId(colourId, nil)
    if not colourId or not sv then return false end
    sv[settingName] = colourId
    BSNC.OnProfileChanged(shouldBroadcast)
    return true
end

function BSNC.SetStyle(style, shouldBroadcast)
    style = ValidStyle(style)
    sv.style = style
    BSNC.OnProfileChanged(shouldBroadcast)
end

function BSNC.SetEnabled(enabled)
    sv.enabled = enabled and true or false
    BSNC.OnProfileChanged(true)
end

local function StyleMemberRow(member)
    if not member or not member.name then
        return nil
    end

    local rawName = StripESOColourCodes(member.name)
    local profile = BSNC.GetProfileForName(rawName)
    if not profile then
        return nil
    end

    member.name = FormatNameWithProfile(rawName, profile)
    return rawName
end

local function PatchDesign(design)
    if not design or patchedDesigns[design] then
        return false
    end

    if type(design.Render) ~= "function" then
        return false
    end

    local originalRender = design.Render

    design.Render = function(self, members, ctx, ...)
        if not sv or not sv.enabled or type(members) ~= "table" then
            return originalRender(self, members, ctx, ...)
        end

        CleanStaleRemoteProfiles()

        local originals = {}
        for i, member in ipairs(members) do
            originals[i] = StyleMemberRow(member)
        end

        local originalPlayerDisplayName
        local originalFallbackName
        if type(ctx) == "table" then
            originalPlayerDisplayName = ctx.playerDisplayName
            originalFallbackName = ctx.highlightFallbackName

            if ctx.playerDisplayName then
                ctx.playerDisplayName = BSNC.GetStyledName(ctx.playerDisplayName)
            end
            if ctx.highlightFallbackName then
                ctx.highlightFallbackName = BSNC.GetStyledName(ctx.highlightFallbackName)
            end
        end

        local ok, err = pcall(originalRender, self, members, ctx, ...)

        if type(ctx) == "table" then
            ctx.playerDisplayName = originalPlayerDisplayName
            ctx.highlightFallbackName = originalFallbackName
        end

        for i, member in ipairs(members) do
            if originals[i] then
                member.name = originals[i]
            end
        end

        if not ok then
            error(err)
        end
    end

    patchedDesigns[design] = true
    return true
end

function BSNC.PatchKnownBattleScrollsDesigns()
    if not BattleScrolls then
        return false
    end

    local patchedAny = false

    if BattleScrolls.dpsMeter and BattleScrolls.dpsMeter.currentGroupDesign then
        patchedAny = PatchDesign(BattleScrolls.dpsMeter.currentGroupDesign) or patchedAny
    end

    local registry = BattleScrolls.dpsMeterDesigns
    if registry and type(registry.GetGroupDesignIds) == "function" and type(registry.GetGroupDesign) == "function" then
        local okIds, ids = pcall(registry.GetGroupDesignIds, registry)
        if okIds and type(ids) == "table" then
            for _, designId in ipairs(ids) do
                local okDesign, design = pcall(registry.GetGroupDesign, registry, designId)
                if okDesign and design then
                    patchedAny = PatchDesign(design) or patchedAny
                end
            end
        end
    end

    return patchedAny
end

function BSNC.PatchBattleScrolls()
    if not BattleScrolls or not BattleScrolls.dpsMeter then
        return false
    end

    BSNC.PatchKnownBattleScrollsDesigns()

    if not didPatchApplyGroupDesign and type(BattleScrolls.dpsMeter.ApplyGroupDesign) == "function" then
        local originalApplyGroupDesign = BattleScrolls.dpsMeter.ApplyGroupDesign

        BattleScrolls.dpsMeter.ApplyGroupDesign = function(self, ...)
            local resultA, resultB, resultC, resultD = originalApplyGroupDesign(self, ...)
            BSNC.PatchKnownBattleScrollsDesigns()
            BSNC.ApplyDirectMeterStyling()
            return resultA, resultB, resultC, resultD
        end

        didPatchApplyGroupDesign = true
    end

    if not didPatchUpdateGroupDisplay and type(BattleScrolls.dpsMeter.UpdateGroupDisplay) == "function" then
        local originalUpdateGroupDisplay = BattleScrolls.dpsMeter.UpdateGroupDisplay

        BattleScrolls.dpsMeter.UpdateGroupDisplay = function(self, ...)
            local resultA, resultB, resultC, resultD = originalUpdateGroupDisplay(self, ...)
            BSNC.ApplyDirectMeterStyling()
            return resultA, resultB, resultC, resultD
        end

        didPatchUpdateGroupDisplay = true
    end

    return true
end

local function AddNumericProtocolField(LGB, protocol, fieldName, options)
    if not LGB or not protocol or type(protocol.AddField) ~= "function" or type(LGB.CreateNumericField) ~= "function" then
        return false
    end

    local okField, field = pcall(LGB.CreateNumericField, fieldName, options)
    if not okField or not field then
        return false
    end

    local okAdd = pcall(protocol.AddField, protocol, field)
    return okAdd == true
end

local function TryProtocolSend(protocol, data)
    if not protocol or type(protocol.Send) ~= "function" then
        return false
    end

    local ok, sent = pcall(protocol.Send, protocol, data)
    return ok and sent == true
end

local function OnRemoteStyleData(unitTag, data)
    if type(data) ~= "table" then
        return
    end

    local rawName = GetUndecoratedNameFromUnitTag(unitTag)
    if not rawName or rawName == "" then
        return
    end

    local styleId = tonumber(data.style or data[2]) or STYLE_TO_ID[STYLE_PLAIN]
    local style = ID_TO_STYLE[styleId] or STYLE_PLAIN
    local solidId = ValidColourId(data.solid or data.solidColour or data[1], DEFAULTS.solidColourId)
    local gradientStartId = ValidColourId(data.gradientStart or data.gradStart or data[3], DEFAULTS.gradientStartColourId)
    local gradientEndId = ValidColourId(data.gradientEnd or data.gradEnd or data[4], DEFAULTS.gradientEndColourId)

    local colourHex
    local gradientHex

    if style == STYLE_GRADIENT then
        colourHex = GetPresetHex(gradientStartId, DEFAULTS.gradientStartColourId)
        gradientHex = GetPresetHex(gradientEndId, DEFAULTS.gradientEndColourId)
    else
        colourHex = GetPresetHex(solidId, DEFAULTS.solidColourId)
        gradientHex = GetPresetHex(gradientEndId, DEFAULTS.gradientEndColourId)
    end

    SaveRemoteProfile(rawName, colourHex, style, gradientHex)
    ClearFormattedNameCache()
    BSNC.ScheduleRefresh()
end

function BSNC.SetupBroadcastProtocol()
    if broadcastSetupAttempted then
        return broadcastProtocol ~= nil
    end

    broadcastSetupAttempted = true

    local LGB = LibGroupBroadcast
    if not LGB then
        return false
    end

    if PROTOCOL_ID < 0 or PROTOCOL_ID > 511 then
        return false
    end

    local handler
    if type(LGB.RegisterHandler) == "function" then
        local ok, result = pcall(LGB.RegisterHandler, LGB, ADDON_NAME)
        if ok then handler = result end
    end

    if not handler then
        return false
    end

    if type(handler.SetDisplayName) == "function" then
        pcall(handler.SetDisplayName, handler, DISPLAY_NAME)
    end

    if type(handler.SetDescription) == "function" then
        pcall(handler.SetDescription, handler, "Shares Battle Scrolls name colour settings with group members who also run this addon.")
    end

    local protocol
    if type(handler.DeclareProtocol) == "function" then
        local ok, result = pcall(handler.DeclareProtocol, handler, PROTOCOL_ID, "BattleScrollsNameColours_Profile")
        if ok then protocol = result end
    end

    if not protocol then
        return false
    end

    local fieldsOk = true
    fieldsOk = AddNumericProtocolField(LGB, protocol, "solid", { minValue = 1, maxValue = 50, numBits = 6 }) and fieldsOk
    fieldsOk = AddNumericProtocolField(LGB, protocol, "style", { minValue = 1, maxValue = 2, numBits = 2 }) and fieldsOk
    fieldsOk = AddNumericProtocolField(LGB, protocol, "gradientStart", { minValue = 1, maxValue = 50, numBits = 6 }) and fieldsOk
    fieldsOk = AddNumericProtocolField(LGB, protocol, "gradientEnd", { minValue = 1, maxValue = 50, numBits = 6 }) and fieldsOk

    if not fieldsOk then
        return false
    end

    if type(protocol.OnData) ~= "function" then
        return false
    end

    local okOnData = pcall(protocol.OnData, protocol, OnRemoteStyleData)
    if not okOnData then
        return false
    end

    local okFinalize, finalized = pcall(protocol.Finalize, protocol, {
        isRelevantInCombat = true,
        replaceQueuedMessages = true,
    })

    if not okFinalize or finalized ~= true then
        return false
    end

    broadcastProtocol = protocol
    return true
end

function BSNC.BroadcastProfile(force)
    if not sv or not sv.enabled then
        return false
    end

    if not IsGrouped() then
        return false
    end

    local now = NowMs()
    if not force and now > 0 and lastProfileBroadcastMs > 0 and now - lastProfileBroadcastMs < PROFILE_BROADCAST_MIN_INTERVAL_MS then
        return false
    end

    if not broadcastProtocol then
        BSNC.SetupBroadcastProtocol()
    end

    if not broadcastProtocol then
        return false
    end

    local style = ValidStyle(sv.style)
    local styleId = STYLE_TO_ID[style] or STYLE_TO_ID[STYLE_PLAIN]

    local data = {
        solid = ValidColourId(sv.solidColourId, DEFAULTS.solidColourId),
        style = styleId,
        gradientStart = ValidColourId(sv.gradientStartColourId, DEFAULTS.gradientStartColourId),
        gradientEnd = ValidColourId(sv.gradientEndColourId, DEFAULTS.gradientEndColourId),
    }

    local sent = TryProtocolSend(broadcastProtocol, data)
    if sent then
        lastProfileBroadcastMs = now
    end

    return sent
end

local function RegisterSettingsMenu()
    if settingsRegistered then return true end

    local LHAS = LibHarvensAddonSettings
    if not LHAS or type(LHAS.AddAddon) ~= "function" then
        return false
    end

    local options = {
        allowDefaults = true,
        allowRefresh = true,
        defaultsFunction = function()
            sv.enabled = DEFAULTS.enabled
            sv.solidColourId = DEFAULTS.solidColourId
            sv.gradientStartColourId = DEFAULTS.gradientStartColourId
            sv.gradientEndColourId = DEFAULTS.gradientEndColourId
            sv.style = DEFAULTS.style
            sv.livePreview = DEFAULTS.livePreview
            BSNC.OnProfileChanged(true)
        end,
    }

    local settings = LHAS:AddAddon(DISPLAY_NAME, options)
    if not settings then
        return false
    end

    settings:AddSetting({
        type = LHAS.ST_SECTION,
        label = "Name Colour Display",
    })

    settings:AddSetting({
        type = LHAS.ST_LABEL,
        label = "Changes apply to Battle Scrolls group DPS meter names. A floating preview appears outside this menu while editing. Other players see your style only if they also run this addon.",
    })

    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Enable name styling",
        tooltip = "Turns Battle Scrolls name colouring on or off.",
        default = DEFAULTS.enabled,
        setFunction = function(state)
            BSNC.SetEnabled(state)
        end,
        getFunction = function()
            return sv.enabled
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Show floating preview while editing",
        tooltip = "Shows a live preview outside the settings list while changing preset colours or style.",
        default = DEFAULTS.livePreview,
        setFunction = function(state)
            sv.livePreview = state and true or false
            if sv.livePreview then
                BSNC.ShowLivePreview(4500)
            elseif livePreviewControl then
                livePreviewControl:SetHidden(true)
            end
        end,
        getFunction = function()
            return sv.livePreview
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_DROPDOWN,
        label = "Style selector",
        tooltip = "Plain keeps one solid colour. Gradient uses the selected start and finish preset colours.",
        default = STYLE_LABELS[DEFAULTS.style],
        items = {
            { name = STYLE_LABELS[STYLE_PLAIN], data = STYLE_PLAIN },
            { name = STYLE_LABELS[STYLE_GRADIENT], data = STYLE_GRADIENT },
        },
        setFunction = function(combobox, name, item)
            if item and item.data then
                BSNC.SetStyle(item.data, true)
            end
        end,
        getFunction = function()
            return STYLE_LABELS[ValidStyle(sv.style)]
        end,
    })


    settings:AddSetting({
        type = LHAS.ST_SECTION,
        label = "Preset Colours",
    })

    settings:AddSetting({
        type = LHAS.ST_LABEL,
        label = "This version uses selector presets instead of RGB sliders. Holding sliders caused repeated UI updates and memory warnings on console; presets only update once per confirmed selection.",
    })

    settings:AddSetting({
        type = LHAS.ST_DROPDOWN,
        label = "Solid Colour",
        tooltip = "Colour used when Style is set to Plain colour.",
        default = GetPresetName(DEFAULTS.solidColourId, DEFAULTS.solidColourId),
        items = COLOUR_DROPDOWN_ITEMS,
        setFunction = function(combobox, name, item)
            if item and item.data then
                BSNC.SetColourPreset("solidColourId", item.data, true)
            end
        end,
        getFunction = function()
            return GetPresetName(sv.solidColourId, DEFAULTS.solidColourId)
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_DROPDOWN,
        label = "Gradient Start",
        tooltip = "Start colour used when Style is set to Gradient.",
        default = GetPresetName(DEFAULTS.gradientStartColourId, DEFAULTS.gradientStartColourId),
        items = COLOUR_DROPDOWN_ITEMS,
        disable = function() return ValidStyle(sv.style) == STYLE_PLAIN end,
        setFunction = function(combobox, name, item)
            if item and item.data then
                BSNC.SetColourPreset("gradientStartColourId", item.data, true)
            end
        end,
        getFunction = function()
            return GetPresetName(sv.gradientStartColourId, DEFAULTS.gradientStartColourId)
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_DROPDOWN,
        label = "Gradient End",
        tooltip = "Finish colour used when Style is set to Gradient.",
        default = GetPresetName(DEFAULTS.gradientEndColourId, DEFAULTS.gradientEndColourId),
        items = COLOUR_DROPDOWN_ITEMS,
        disable = function() return ValidStyle(sv.style) == STYLE_PLAIN end,
        setFunction = function(combobox, name, item)
            if item and item.data then
                BSNC.SetColourPreset("gradientEndColourId", item.data, true)
            end
        end,
        getFunction = function()
            return GetPresetName(sv.gradientEndColourId, DEFAULTS.gradientEndColourId)
        end,
    })

    settingsRegistered = true
    return true
end

local function TryPatchLoop(attempt)
    attempt = attempt or 1

    local patched = BSNC.PatchBattleScrolls()
    if patched then
        return
    end

    if attempt < 12 then
        zo_callLater(function()
            TryPatchLoop(attempt + 1)
        end, 1000)
    end
end

local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    sv = ZO_SavedVars:NewAccountWide("BattleScrollsNameColoursSavedVariables", 2, nil, DEFAULTS)
    sv.solidColourId = ValidColourId(sv.solidColourId, FindClosestColourId(sv.colourHex, DEFAULTS.solidColourId))
    sv.gradientStartColourId = ValidColourId(sv.gradientStartColourId, FindClosestColourId(sv.colourHex, DEFAULTS.gradientStartColourId))
    sv.gradientEndColourId = ValidColourId(sv.gradientEndColourId, FindClosestColourId(sv.gradientHex, DEFAULTS.gradientEndColourId))
    sv.style = ValidStyle(sv.style)
    if sv.livePreview == nil then sv.livePreview = DEFAULTS.livePreview end

    local profile = GetOwnProfile()
    sv.colourHex = profile.colourHex
    sv.gradientHex = profile.gradientHex

    RegisterSettingsMenu()
    BSNC.SetupBroadcastProtocol()

    zo_callLater(function()
        TryPatchLoop(1)
        BSNC.BroadcastProfile(true)
    end, 1500)
end

local function OnGroupChanged()
    if not sv then return end
    ownNameLookupCache = nil
    zo_callLater(function()
        if not sv then return end
        BSNC.BroadcastProfile(true)
        BSNC.ScheduleRefresh()
    end, 1000)
    zo_callLater(function()
        if not sv then return end
        BSNC.BroadcastProfile(true)
    end, 5000)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)

if EVENT_PLAYER_ACTIVATED then
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Activated", EVENT_PLAYER_ACTIVATED, OnGroupChanged)
end

if EVENT_GROUP_MEMBER_JOINED then
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "GroupJoined", EVENT_GROUP_MEMBER_JOINED, OnGroupChanged)
end

if EVENT_GROUP_MEMBER_LEFT then
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "GroupLeft", EVENT_GROUP_MEMBER_LEFT, OnGroupChanged)
end

if EVENT_GROUP_UPDATE then
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "GroupUpdate", EVENT_GROUP_UPDATE, OnGroupChanged)
end

if EVENT_PLAYER_COMBAT_STATE then
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Combat", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        if inCombat then
            BSNC.ScheduleProfileBroadcast()
        end
    end)
end

local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MATH FUNCTIONS BECAUSE I HATE LUA FOR NOT ALLOWING ++
-- lokal PP = CC.Math.PlusPlus --> PP(counter), MM(counter) etc
----------------------------------------------------------------------------------------------------
CC.Math = {
    Default = {},
    ---@type table|any
    SV = {},
}

function CC.Math.PlusPlus(value)
    return value + 1
end

function CC.Math.MinusMinus(value)
    return value - 1
end

function CC.Math.Not(value)
    return not value
end

----------------------------------------------------------------------------------------------------
-- GENERAL DEBUG
----------------------------------------------------------------------------------------------------
function CC.Debug(msg)
    if CC.SV.enableDebug then
        d(CC.CHAT .. " " .. msg)
    end
end

SLASH_COMMANDS["/cc_debug"] = function()
    CC.SV.enableDebug = not CC.SV.enableDebug
    d(CC.CHAT .. (CC.SV.enableDebug and " |c00FF00Enable Debug|r" or " |cFF0000Disable Debug|r"))
end

----------------------------------------------------------------------------------------------------
-- ZONE MAP REVERSE LOOKUP
----------------------------------------------------------------------------------------------------
CC.ZoneSyncMap = {}
for syncId, zoneId in pairs(CC.ZoneMap) do
    if syncId > 0 then
        CC.ZoneSyncMap[zoneId] = syncId
    end
end

----------------------------------------------------------------------------------------------------
-- DECODE ZONE FLAG
-- 0 = TARGETS ZONE, 1 = SENDERS ZONE, 2.. = ZONE MAP
----------------------------------------------------------------------------------------------------
function CC.GetZoneIdFromFlag(RX, senderTag)
    local decodedRX = RX or 0
    if decodedRX == 0 then
        return CC.GetCleanZoneId()
    elseif decodedRX == 1 then
        return CC.GetCleanZoneId(GetUnitRawWorldPosition(senderTag))
    else
        return CC.ZoneMap[decodedRX] or 0
    end
end

----------------------------------------------------------------------------------------------------
-- GET EQUIPPED SET STATUS
----------------------------------------------------------------------------------------------------
function CC.GetPlayerSetStatus(setType)
    local sets = {}
    if setType == "SLAYER" then
        sets = { [331] = 1, [332] = 2, [346] = 3 } -- WM, MA, ROJO
    elseif setType == "ARKASIS" then
        sets = { [518] = 1 } -- ARKASIS GENIUS
    else
        return 0
    end

    local ItemCounts = {}
    local ItemSlots = CC.ITEM_SLOTS

    for _, itemSlot in ipairs(ItemSlots) do
        local itemLink = GetItemLink(BAG_WORN, itemSlot)
        local hasSet, _, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)

        if hasSet and sets[setId] then
            ItemCounts[setId] = (ItemCounts[setId] or 0)
            local weaponType = GetItemWeaponType(BAG_WORN, itemSlot) or 0

            -- IF TWO HANDED -> ItemCounts AS 2
            if CC.WEAPONTYPE_TWO_HANDED[weaponType] then
                ItemCounts[setId] = ItemCounts[setId] + 2
            else
                ItemCounts[setId] = ItemCounts[setId] + 1
            end

            if ItemCounts[setId] >= 5 then
                return sets[setId]
            end
        end
    end
    return 0
end

----------------------------------------------------------------------------------------------------
-- RAIDLEAD HELPER / COMMAND
----------------------------------------------------------------------------------------------------
function CC.IsRaidlead()
    return CC.SV.isRaidlead == true
end

SLASH_COMMANDS["/cc_raidlead"] = function()
    CC.SV.isRaidlead = not CC.SV.isRaidlead
    CC.SV.isRaidleadIntent = CC.SV.isRaidlead

    d(string.format("%s Raidlead features are now %s", CC.CHAT, CC.SV.isRaidlead and CC.ColorString("ON", "GN") or CC.ColorString("OFF", "RD")))

    if CC.DisplayPanel.SV.isVisible then
        CC.DisplayPanel:UpdateDimensions()
    end
end

----------------------------------------------------------------------------------------------------
-- PLAY A SOUND
----------------------------------------------------------------------------------------------------
function CC.PlaySound(sound, volume)
    if not sound then return end
    local vol = math.min(10, math.max(1, volume or 1))

    for i = 1, vol do
        PlaySound(sound)
    end
end

----------------------------------------------------------------------------------------------------
-- CALC COLOR(S)
----------------------------------------------------------------------------------------------------
function CC.GetNormalColor(Color)
    return { Color[1] or 1, Color[2] or 1, Color[3] or 1, 1 }
end

function CC.GetHighlightColor(Color)
    local r, g, b = Color[1] or 1, Color[2] or 1, Color[3] or 1
    local lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
    local boost = 0.25 + (lum * 0.25)

    return { math.min(1, r + boost), math.min(1, g + boost), math.min(1, b + boost), 1 }
end

----------------------------------------------------------------------------------------------------
-- TIMER COLOR GRADIENT (GREEN -> YELLOW -> RED)
----------------------------------------------------------------------------------------------------
function CC.GetTimerColor(remaining, duration)
    if not duration or duration <= 0 then return {1, 1, 1, 1} end
    local p = math.max(0, math.min(1, remaining / duration))
    local r, g = 0, 0

    if p >= 0.75 then
        r, g = (1 - p) / 0.25 * 0.5, 1.0
    elseif p >= 0.50 then
        r, g = 0.5 + (0.75 - p) / 0.25 * 0.5, 1.0
    elseif p >= 0.25 then
        r, g = 1.0, 0.5 + (p - 0.25) / 0.25 * 0.5
    else
        r, g = 1.0, p / 0.25 * 0.5
    end

    return { r, g, 0, 1 }
end

---------------------------------------------------------------------------
-- CALCULATE COLOR
---------------------------------------------------------------------------
function CC.GetPercentageColor(perc)
    local p = math.max(0, math.min(100, perc)) / 100
    local r, g = 0, 0

    if p >= 0.75 then
        r, g = (1 - p) / 0.25 * 0.5, 1.0
    elseif p >= 0.50 then
        r, g = 0.5 + (0.75 - p) / 0.25 * 0.5, 1.0
    elseif p >= 0.25 then
        r, g = 1.0, 0.5 + (p - 0.25) / 0.25 * 0.5
    else
        r, g = 1.0, p / 0.25 * 0.5
    end

    return { r, g, 0, 1 }
end

----------------------------------------------------------------------------------------------------
-- VALIDATE TRIAL ZONE ID
----------------------------------------------------------------------------------------------------
function CC.GetCleanZoneId(zoneId)
    local id = zoneId or GetUnitRawWorldPosition("player") or 0
    return CC.TrialZones[id] and id or 0
end

----------------------------------------------------------------------------------------------------
-- GET CURRENT TRIAL ZONE (RETURNS ID AND NAME)
----------------------------------------------------------------------------------------------------
function CC.GetCurrentTrialZone()
    local zoneId = CC.GetCleanZoneId()
    return zoneId, CC.TrialZones[zoneId] or "General"
end

----------------------------------------------------------------------------------------------------
-- ENCODE RADIANT
----------------------------------------------------------------------------------------------------
function CC.GetEncodedRadiant(rad)
    return math.floor((((rad or 0) % (2 * math.pi)) * 100) + 0.5)
end

----------------------------------------------------------------------------------------------------
-- GET COLOR BY GROUP INDEX
----------------------------------------------------------------------------------------------------
function CC.GetColorFromGroupIndex(unitTag)
    if not IsUnitGrouped("player") then return CC.GroupColors["player"] end

    for i = 1, GetGroupSize() do
        local groupTag = GetGroupUnitTagByIndex(i)
        if AreUnitsEqual(groupTag, unitTag) then
            return CC.GroupColors[i] or { 1, 1, 1, 1 }
        end
    end
    return { 1, 1, 1, 1 }
end

----------------------------------------------------------------------------------------------------
-- GET CLICKABLE LINK
----------------------------------------------------------------------------------------------------
function CC.GetPlayerLinkFromDisplayName(displayName)
    if not displayName then return end
    return "|cFF7F00" .. ZO_LinkHandler_CreatePlayerLink(displayName) .. "|r"
end

----------------------------------------------------------------------------------------------------
-- COLOR STRING
----------------------------------------------------------------------------------------------------
function CC.ColorString(menuName, menuLayer)
    if not menuName then return "" end
    if not menuLayer then return menuName end

    local LAYER = {
        [0] = "|cFF7F00", -- 1 0.5   0
        [1] = "|cFF9F3F", -- 1 0.625 0.25
        [2] = "|cFFBF7F", -- 1 0.75  0.5
        [3] = "|cFFDFBF", -- 1 0.875 0.75
        [4] = "|cFFFFFF", -- 1 1     1

        ["tier1"] = "|cFF7F00", -- 1 0.5   0
        ["tier2"] = "|cFF9F3F", -- 1 0.625 0.25
        ["tier3"] = "|cFFBF7F", -- 1 0.75  0.5
        ["tier4"] = "|cFFDFBF", -- 1 0.875 0.75
        ["tier5"] = "|cFFFFFF", -- 1 1 1

        ["GN"] = "|c00FF00",
        ["RD"] = "|cFF0000",
        ["WH"] = "|cFFFFFF",
        ["OG"] = "|cFF7F00",
        ["BU"] = "|c007FFF",
    }

    local colorHex = LAYER[menuLayer] or "|cFFFFFF"
    return string.format("%s%s|r", colorHex, menuName)
end

----------------------------------------------------------------------------------------------------
-- GET LINEAR GRADIENT
----------------------------------------------------------------------------------------------------
function CC.GetLinearColor(factor, ColorStart, ColorEnd)
    local f = math.max(0, math.min(1, factor))

    local midR = math.max(ColorStart[1], ColorEnd[1])
    local midG = math.max(ColorStart[2], ColorEnd[2])
    local midB = math.max(ColorStart[3], ColorEnd[3])
    local midA = (ColorStart[4] + ColorEnd[4]) / 2

    local r, g, b, a

    if f >= 0.5 then
        local p = (f - 0.5) * 2
        r = midR + (ColorStart[1] - midR) * p
        g = midG + (ColorStart[2] - midG) * p
        b = midB + (ColorStart[3] - midB) * p
        a = midA + (ColorStart[4] - midA) * p
    else
        local p = f * 2
        r = ColorEnd[1] + (midR - ColorEnd[1]) * p
        g = ColorEnd[2] + (midG - ColorEnd[2]) * p
        b = ColorEnd[3] + (midB - ColorEnd[3]) * p
        a = ColorEnd[4] + (midA - ColorEnd[4]) * p
    end

    return {r or 1, g or 1, b or 1, a or 1}
end

----------------------------------------------------------------------------------------------------
-- TABLE TO HEX
----------------------------------------------------------------------------------------------------
function CC.GetHexColorFromArray(Color)
    if type(Color) ~= "table" then return "|cFFFFFF" end

    local r = math.max(0, math.min(255, math.floor(((Color[1] or 1) * 255) + 0.5)))
    local g = math.max(0, math.min(255, math.floor(((Color[2] or 1) * 255) + 0.5)))
    local b = math.max(0, math.min(255, math.floor(((Color[3] or 1) * 255) + 0.5)))

    return string.format("|c%02X%02X%02X", r, g, b)
end

----------------------------------------------------------------------------------------------------
-- (NOT SO) RANDOM COLOR FROM ABILITYID; COOL TRICK, HUH?
----------------------------------------------------------------------------------------------------
function CC.GetColorFromAbilityId(abilityId)
    local r = 63 + ((abilityId * 137) % 192)
    local g = 63 + ((abilityId * 43) % 192)
    local b = 63 + ((abilityId * 211) % 192)
    return string.format("%02X%02X%02X", r, g, b)
end

----------------------------------------------------------------------------------------------------
-- GET R,G,B,A FROM {ARRAY} FOR MENU
----------------------------------------------------------------------------------------------------
function CC.GetRgbaFromArray(ColorArray)
    if not ColorArray then return { r = 1, g = 1, b = 1, a = 1 } end
    return { r = ColorArray[1], g = ColorArray[2], b = ColorArray[3], a = ColorArray[4] }
end

----------------------------------------------------------------------------------------------------
-- GET GAME AOE COLORS TO MESS WITH LATER
----------------------------------------------------------------------------------------------------
--SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_COLOR, format("%02x%02x%02x", red, green, blue))
function CC.GetGameAoeFriendlyColor()
    local ColorHex = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_COLOR)
    local r, g, b = ZO_ColorDef:New(ColorHex):UnpackRGB()
    local a = math.min(1, tonumber(GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_BRIGHTNESS)) / 50)

    return {r, g, b, a}
end

--SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR, format("%02x%02x%02x", red, green, blue))
function CC.GetGameAoeEnemyColor()
    local ColorHex = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR)
    local r, g, b = ZO_ColorDef:New(ColorHex):UnpackRGB()
    local a = math.min(1, tonumber(GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS)) / 50)

    return {r, g, b, a}
end

----------------------------------------------------------------------------------------------------
-- GET UNITTAG FROM UNKNOWN API IDENTIFIER
----------------------------------------------------------------------------------------------------
function CC.GetUnitTagFromIdentifier(identifier)
    if type(identifier) ~= "string" or identifier == "" then return nil end

    local lowerId = string.lower(identifier)
    if (lowerId == "player" or string.match(lowerId, "^group%d+$")) and DoesUnitExist(lowerId) then
        return lowerId
    end

    if GetUnitDisplayName("player") == identifier or GetRawUnitName("player") == identifier then
        return "player"
    end

    if IsUnitGrouped("player") then
        for i = 1, GetGroupSize() do
            local tag = GetGroupUnitTagByIndex(i)
            if GetUnitDisplayName(tag) == identifier or GetRawUnitName(tag) == identifier then
                return tag
            end
        end
    end

    return nil
end

----------------------------------------------------------------------------------------------------
-- GET UNITNAME FROM (HOPEFULLY FETCHED) UNITID
----------------------------------------------------------------------------------------------------
function CC.GetUnitNameFromUnitId(unitId)
    return CC.UnitNames[unitId] or nil
end

----------------------------------------------------------------------------------------------------
-- GET UNITNAME FROM DISPLAYNAME
----------------------------------------------------------------------------------------------------
function CC.GetUnitNameFromUnitDisplayName(displayName)
    if type(displayName) ~= "string" or displayName == "" then return "" end

    if displayName == GetUnitDisplayName("player") then
        return GetRawUnitName("player")
    end

    if IsUnitGrouped("player") then
        for i = 1, GetGroupSize() do
            local unitTag = GetGroupUnitTagByIndex(i)
            if displayName == GetUnitDisplayName(unitTag) then
                return GetRawUnitName(unitTag)
            end
        end
    end

    return nil
end

----------------------------------------------------------------------------------------------------
-- GET DISPLAYNAME FROM UNITNAME
----------------------------------------------------------------------------------------------------
function CC.GetUnitDisplayNameFromUnitName(unitName)
    if type(unitName) ~= "string" or unitName == "" then return "" end

    if unitName == GetRawUnitName("player") then
        return GetUnitDisplayName("player")
    end

    if IsUnitGrouped("player") then
        for i = 1, GetGroupSize() do
            local unitTag = GetGroupUnitTagByIndex(i)
            if unitName == GetRawUnitName(unitTag) then
                return GetUnitDisplayName(unitTag)
            end
        end
    end

    return nil
end
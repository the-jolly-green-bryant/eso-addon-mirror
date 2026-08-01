RezBot                = RezBot or {}

RezBot.name           = "RezBot"
RezBot.version        = "1.9.4"

-- Resurrection status constants
RezBot.STATUS_DOWN    = "down"
RezBot.STATUS_PENDING = "pending rez"
RezBot.STATUS_REZZING = "being rezzed"

----------------------------------------------------------------
-- DEFAULTS ----------------------------------------------------
----------------------------------------------------------------
RezBot.defaults       = {
    enabled           = true,
    uiEnabled         = true,
    showHeaderLabel   = true,
    chatOutput        = false,
    uiOpacity         = 0.85,
    uiBackgroundColor = { 0.00, 0.00, 0.00, 0.75 },
    fontIndex         = 5,
    fontName          = "ZoFontGamepad27",
    colorDown         = { 1.00, 0.33, 0.33, 1.0 },
    colorRezzing      = { 0.33, 1.00, 0.33, 1.0 },
    colorPending      = { 1.00, 0.87, 0.33, 1.0 },
    anchorPoint       = "RIGHT",
    offsetX           = 0,
    offsetY           = -50,
    showDown          = true,
    showPending       = true,
    showRezzing       = true,
    ignoreCompanions  = true,
    debug             = false,
}
RezBot.saved          = nil

-- Group role constants
GROUP_ROLE_NONE       = 0
GROUP_ROLE_TANK       = 2
GROUP_ROLE_HEALER     = 4
GROUP_ROLE_DPS        = 1

----------------------------------------------------------------
-- Internal state ----------------------------------------------
----------------------------------------------------------------
-- resStates[unitName] = { status = "down" | "pending rez" | "being rezzed", since = ms, rezzer = unitId }
local resStates       = {}
local rowColorCache   = {}

-- UI and settings state
local isSettingsOpen  = false
local WRAP_ELLIPSIS   = TEXT_WRAP_MODE_ELLIPSIS or 2

-- Constants
local GROUP_SIZE_MAX  = 12  -- ESO group size limit
local UPDATE_MS       = 100 -- UI update interval in milliseconds


----------------------------------------------------------------
-- Debug -------------------------------------------------------
----------------------------------------------------------------


function RezBot.isDev()
    local name = GetDisplayName()
    return (name == "@ohmygoron" or name == "@goron_spice") and RezBot.saved and RezBot.saved.debug
end

function RezBot.dbg(msg)
    if RezBot.isDev and RezBot.isDev() then
        d("|c00ff00[RezBot Debug]:|r " .. tostring(msg))
    end
end

----------------------------------------------------------------
-- Helpers -----------------------------------------------------
----------------------------------------------------------------

-- Removes ^<Account> suffix from names
local function cleanse(n)
    return n and n:gsub("%^[A-Za-z]+", "") or ""
end

local function normalizeName(name)
    return string.gsub(name or "", "^@", "")
end

-- Anchor fallback for invalid points
local function safeAnchor(point)
    return _G[point] or TOPLEFT
end

-- RGB array to hex (e.g., {1, 0.5, 0} -> "FF8000")
local function rgbaToHex(arr)
    return string.format("%02X%02X%02X", arr[1] * 255, arr[2] * 255, arr[3] * 255)
end

-- FONT CONFIG OPTIONS AND UTILITIES
local FONT_OPTS = {
    "ZoFontGamepad18",
    "ZoFontGamepad20",
    "ZoFontGamepad22",
    "ZoFontGamepad25",
    "ZoFontGamepad27", -- default
    "ZoFontGamepad34",
    "ZoFontGamepad36",
    "ZoFontGamepad42",
    -- Skipping ZoFontGamepad45 (broken)
    "ZoFontGamepad54",
}
local FONT_HEIGHTS = {
    ZoFontGamepad18 = 20,
    ZoFontGamepad20 = 22,
    ZoFontGamepad22 = 24,
    ZoFontGamepad25 = 27,
    ZoFontGamepad27 = 29,
    ZoFontGamepad34 = 36,
    ZoFontGamepad36 = 38,
    ZoFontGamepad42 = 44,
    ZoFontGamepad54 = 56,
}

-- Clamps a value between a lower and upper bound, preventing out-of-range values (e.g., font indices).
function math.clamp(v, lo, hi)
    return math.min(math.max(v, lo), hi)
end

local function fontByIndex(i)
    return FONT_OPTS[math.clamp(i, 1, #FONT_OPTS)]
end

-- Used for dropdown display
local function prettifyAnchor(anchor)
    return anchor
        :gsub("TOPLEFT", "TOP LEFT")
        :gsub("TOPRIGHT", "TOP RIGHT")
        :gsub("BOTTOMLEFT", "BOTTOM LEFT")
        :gsub("BOTTOMRIGHT", "BOTTOM RIGHT")
end
local function uglifyAnchor(pretty)
    return pretty:gsub(" ", "")
end

-- Converts unit ID to name
local function getNameFromUnitId(id)
    for i = 1, GROUP_SIZE_MAX do
        local tag = "group" .. i
        if DoesUnitExist(tag) and GetUnitUniqueIdentifier(tag) == id then
            return GetUnitName(tag)
        end
    end
    return nil
end

-- Converts character name to account name (strips @)
local function getAccountNameFromCharName(charName)
    charName = cleanse(charName)

    for i = 1, GROUP_SIZE_MAX do
        local tag = "group" .. i
        if DoesUnitExist(tag) and cleanse(GetUnitName(tag)) == charName then
            return string.gsub(GetUnitDisplayName(tag), "^@", "")
        end
    end

    if DoesUnitExist("player") and cleanse(GetUnitName("player")) == charName then
        return string.gsub(GetUnitDisplayName("player"), "^@", "")
    end

    if DoesUnitExist("companion") and cleanse(GetUnitName("companion")) == charName then
        return GetUnitName("companion")
    end

    return nil
end

local function getCharNameFromAccountName(accountName)
    for i = 1, GROUP_SIZE_MAX do
        local tag = "group" .. i
        if DoesUnitExist(tag) and cleanse(GetUnitDisplayName(tag)) == "@" .. accountName then
            return cleanse(GetUnitName(tag))
        end
    end
    if DoesUnitExist("player") and cleanse(GetUnitDisplayName("player")) == "@" .. accountName then
        return cleanse(GetUnitName("player"))
    end
    return nil
end

-- Finds unitTag by name
local function findUnitTagByName(n)
    for i = 1, GROUP_SIZE_MAX do
        local tag = "group" .. i
        if DoesUnitExist(tag) and cleanse(GetUnitName(tag)) == n then
            return tag
        end
    end
    -- Check for player (solo)
    if DoesUnitExist("player") and cleanse(GetUnitName("player")) == n then
        return "player"
    end
    if DoesUnitExist("companion") and cleanse(GetUnitName("companion")) == n then
        return "companion"
    end
    return nil
end

-- Chat output for tracking
local function echoStatus(targetName, status, targetTag, sourceName)
    if not (RezBot and RezBot.saved and RezBot.saved.chatOutput) then return end

    if status == RezBot.STATUS_DOWN and RezBot.saved.showDown == false then return end
    if status == RezBot.STATUS_PENDING and RezBot.saved.showPending == false then return end
    if status == RezBot.STATUS_REZZING and RezBot.saved.showRezzing == false then return end

    local accountTarget = getAccountNameFromCharName and getAccountNameFromCharName(targetName) or targetName or
        "Unknown"

    local msg
    if status == RezBot.STATUS_REZZING then
        local accountSource = getAccountNameFromCharName and getAccountNameFromCharName(sourceName) or sourceName or
            "Unknown"
        msg = string.format("%s is being rezzed by %s.", accountTarget, accountSource)
    else
        msg = string.format("%s is %s.", accountTarget, status or "unknown")
    end

    pcall(function() d("|cFFFF66RezBot|r: " .. msg) end)
end

local GRAY_COLOR = "AAAAAA" -- Hex for gray

local function getRowColor(name, status)
    local cacheKey = name .. ":" .. tostring(status)
    if rowColorCache[cacheKey] then
        return rowColorCache[cacheKey]
    end

    local accountName = getAccountNameFromCharName(name) or name

    -- If this is a companion, always use normal color logic (pretend they have RezBot)
    local tag = findUnitTagByName and findUnitTagByName(name)
    local color
    if tag == "companion" or tag == "player" then
        color = rgbaToHex(
            (status == RezBot.STATUS_DOWN and RezBot.saved.colorDown) or
            (status == RezBot.STATUS_PENDING and RezBot.saved.colorPending) or
            (status == RezBot.STATUS_REZZING and RezBot.saved.colorRezzing) or
            { 1, 1, 1, 1 }
        )
    elseif not accountName then
        color = GRAY_COLOR
    elseif RezBotSync and RezBotSync.HasRezBot and not RezBotSync.HasRezBot(accountName) then
        color = GRAY_COLOR
    else
        color = rgbaToHex(
            (status == RezBot.STATUS_DOWN and RezBot.saved.colorDown) or
            (status == RezBot.STATUS_PENDING and RezBot.saved.colorPending) or
            (status == RezBot.STATUS_REZZING and RezBot.saved.colorRezzing) or
            { 1, 1, 1, 1 }
        )
    end

    rowColorCache[cacheKey] = color
    return color
end


-- Strip companion entries from state
local function purgeCompanions()
    for name, info in pairs(resStates) do
        if info.tag == "companion" then
            resStates[name] = nil
            RezBot.dbg("Purged companion from resStates: " .. name)
        end
    end
end

-- Returns the group role for a given character name ("tank", "healer", "dps", or "none")
local function getGroupRoleByName(accountName)
    -- accountName = cleanse(accountName)
    for i = 1, GROUP_SIZE_MAX do
        local tag = "group" .. i
        if DoesUnitExist(tag) then
            local unitDisplayName = normalizeName(tostring(GetUnitDisplayName(tag)))
            -- RezBot.dbg("  Player exists, name: " .. unitDisplayName)
            -- RezBot.dbg("  Account name: " .. tostring(accountName))
            if unitDisplayName == accountName then
                -- RezBot.dbg("  Matched group member: " .. tag)
                if GetGroupMemberSelectedRole then
                    local role = GetGroupMemberSelectedRole(tag)
                    -- RezBot.dbg("    Role for " .. tag .. ": " .. tostring(role))
                    if role == GROUP_ROLE_TANK then
                        return "tank"
                    elseif role == GROUP_ROLE_HEALER then
                        return "healer"
                    elseif role == GROUP_ROLE_DPS then
                        return "dps"
                    else
                        --RezBot.dbg("    Unknown group role for " .. tag)
                        return "none"
                    end
                else
                    -- RezBot.dbg("    GetGroupMemberSelectedRole is nil")
                end
            end
        end
    end

    -- player support
    if DoesUnitExist("player") then
        local unitDisplayName = normalizeName(tostring(GetUnitDisplayName("player")))
        -- Check if the player is the one we're looking for
        RezBot.dbg(unitDisplayName == accountName)
        if unitDisplayName == accountName then
            RezBot.dbg("  unit display == accountName, name: " .. unitDisplayName)
            if GetGroupMemberAssignedRole then
                local role = GetGroupMemberAssignedRole("player")
                -- RezBot.dbg("    Role for player: " .. tostring(role))
                if role == GROUP_ROLE_TANK then
                    return "tank"
                elseif role == GROUP_ROLE_HEALER then
                    return "healer"
                elseif role == GROUP_ROLE_DPS then
                    return "dps"
                else
                    RezBot.dbg("    Unknown group role for player")
                    return "none"
                end
            else
                RezBot.dbg("    GetGroupMemberSelectedRole is nil")
            end
        end
    end

    -- Companion support
    if DoesUnitExist("companion") then
        RezBot.dbg("  Companion exists, name: " .. tostring(GetUnitName("companion")))
        if cleanse(GetUnitName("companion")) == charName then
            RezBot.dbg("  Matched companion")
            return "companion"
        end
    end

    -- RezBot.dbg("  No match found, returning 'none'")
    return "none"
end

local function getRoleIcon(role)
    local size = FONT_HEIGHTS[RezBot.saved.fontName] or 24
    local path
    if role == "tank" then
        path = "EsoUI/Art/LFG/Gamepad/LFG_roleIcon_tank.dds"
    elseif role == "healer" then
        path = "EsoUI/Art/LFG/Gamepad/LFG_roleIcon_healer.dds"
    elseif role == "dps" then
        path = "EsoUI/Art/LFG/Gamepad/LFG_roleIcon_dps.dds"
    else
        return ""
    end
    return string.format("|t%d:%d:%s|t", size, size, path)
end


----------------------------------------------------------------
-- UI ----------------------------------------------------------
----------------------------------------------------------------
local uiFrame, listContainer, rowPool

-- EnsureUI creates the UI elements only once
local function EnsureUI()
    if uiFrame then return end

    uiFrame       = RezBotUI     -- top-level from XML
    listContainer = RezBotUIList -- <Control name="$(parent)List" />

    if not uiFrame or not listContainer then
        if RezBot and RezBot.dbg then
            RezBot.dbg("RezBotUI.xml missing – UI disabled")
        else
            d(
                "[RezBot] RezBotUI.xml missing – UI disabled")
        end
        return
    end

    uiFrame:SetMovable(true)
    uiFrame:SetMouseEnabled(true)

    rowPool = ZO_ControlPool:New("RezBotRowTemplate", listContainer, "RezBotRow")
end

-- RefreshUI updates the visible list based on current state
local function RefreshUI()
    EnsureUI()
    if not rowPool then return end

    rowPool:ReleaseAllObjects()
    local y               = 10

    local headerVisible   = RezBot.saved and RezBot.saved.showHeaderLabel
    local HEADER_HEIGHT   = headerVisible and 50 or 0
    local BOTTOM_PADDING  = 35
    local rowHeight       = FONT_HEIGHTS[RezBot.saved.fontName] or 34

    local SAMPLE_DATA     = {
        ["Almalexia"] = { status = RezBot.STATUS_DOWN, rezzer = nil },
        ["Vivec"]     = { status = RezBot.STATUS_PENDING, rezzer = nil },
        ["Sotha Sil"] = { status = RezBot.STATUS_REZZING, rezzer = "Namira" },
        ["Molag Bal"] = { status = RezBot.STATUS_DOWN, rezzer = nil },
    }

    local usingSampleData = isSettingsOpen
    local source          = usingSampleData and SAMPLE_DATA or resStates

    local hasVisibleRows  = false

    for name, info in pairs(source or {}) do
        local role = getGroupRoleByName(name)
        local showRole

        local inBG = false
        local battlegroundTeamSize = GetBattlegroundTeamSize()
        if battlegroundTeamSize then
            inBG = true
        end
        local inCyro = IsPlayerInAvAWorld()

        if inBG or inCyro then
            showRole = true -- Always show in BG or Cyrodiil
        else
            if role == "tank" then
                showRole = RezBot.saved.showTanks ~= false
            elseif role == "healer" then
                showRole = RezBot.saved.showHealers ~= false
            elseif role == "dps" then
                showRole = RezBot.saved.showDPS ~= false
            elseif role == "companion" then
                showRole = RezBot.saved.showCompanions ~= false
            else
                showRole = false
            end
        end

        if showRole then
            if not (RezBot.saved.ignoreCompanions and info.tag == "companion") then
                local show = (
                    (info.status == RezBot.STATUS_DOWN and RezBot.saved.showDown ~= false) or
                    (info.status == RezBot.STATUS_PENDING and RezBot.saved.showPending ~= false) or
                    (info.status == RezBot.STATUS_REZZING and RezBot.saved.showRezzing ~= false)
                )

                if show then
                    hasVisibleRows = true
                    local row = rowPool:AcquireObject()
                    local color = getRowColor(name, info.status)
                    local icon = getRoleIcon(role) or ""
                    local displayName = (isSettingsOpen and name or (getAccountNameFromCharName(name) or name))
                    local line

                    local rezzer = "?"
                    if type(info.rezzer) == "string" then
                        rezzer = getAccountNameFromCharName(info.rezzer) or info.rezzer
                    elseif type(info.rezzer) == "number" then
                        local rezName = getNameFromUnitId(info.rezzer)
                        rezzer = rezName and (getAccountNameFromCharName(rezName) or rezName) or tostring(info.rezzer)
                    end

                    row:SetWidth(400)
                    row:ClearAnchors()
                    row:SetAnchor(TOPLEFT, listContainer, TOPLEFT, 0, y)
                    row:SetHidden(false)

                    row:SetFont(RezBot.saved.fontName)
                    row:SetWrapMode(WRAP_ELLIPSIS)
                    row:SetMaxLineCount(1)

                    if info.status == RezBot.STATUS_REZZING and info.rezzer then
                        line = zo_strformat("<<1>> <<2>> is being rezzed by <<3>>", icon, displayName, rezzer)
                        line = "|c" .. color .. line .. "|r"
                    else
                        line = zo_strformat("<<1>> <<2>> is <<3>>", icon, displayName, info.status)
                        line = "|c" .. color .. line .. "|r"
                    end
                    row:SetText(line)

                    y = y + rowHeight + 4
                end
            end
        end
    end

    if RezBotUIBG then
        local h = math.max(50, y + HEADER_HEIGHT + BOTTOM_PADDING)
        RezBotUIBG:SetHeight(h)
        RezBotUIBG:SetCenterColor(unpack(RezBot.saved.uiBackgroundColor or { 0, 0, 0, 1 }))
        RezBotUIBG:SetAlpha(RezBot.saved.uiOpacity or 0.85)
        uiFrame:SetHeight(h)
    end

    local shouldShow = RezBot.saved.uiEnabled and (usingSampleData or hasVisibleRows)
    uiFrame:SetHidden(not shouldShow)
end



----------------------------------------------------------------
-- Combat handling ---------------------------------------------
----------------------------------------------------------------
local BEGIN   = ACTION_RESULT_BEGIN
local REZZED  = ACTION_RESULT_EFFECT_GAINED
local PENDING = ACTION_RESULT_EFFECT_GAINED_DURATION
local IGNORE  = ACTION_RESULT_BAD_TARGET -- fires after successful rez; ignore
local STUNNED = ACTION_RESULT_STUNNED    -- ignore this, it's not a rez

local function safe(str)
    return tostring(str or "<nil>")
end

local function setRezState(targetName, charName, status, tag, sourceName, sourceUnitId)
    RezBot.dbg("setRezState called")
    if not targetName or not status then return end
    local now           = GetGameTimeMilliseconds()
    resStates           = resStates or {}
    local normName      = normalizeName(targetName)
    resStates[normName] = resStates[normName] or {}
    local charName      = charName or nil

    local state         = resStates[normName]
    local statusChanged = state.status ~= status
    local rezzerChanged = state.rezzer ~= sourceName
    local tagChanged    = state.tag ~= tag

    if statusChanged or rezzerChanged or tagChanged then
        RezBot.dbg(string.format("setRezState: %s, %s, %s, %s, %s", tostring(targetName), tostring(status), tostring(tag),
            tostring(sourceName), tostring(sourceUnitId)))
        RezBot.dbg(string.format("  Previous state: status=%s, rezzer=%s, tag=%s", tostring(state.status),
            tostring(state.rezzer), tostring(state.tag)))
        state.charName = charName
        state.status   = status
        state.since    = now
        state.rezzer   = sourceName
        state.rezzerId = sourceUnitId
        state.tag      = tag

        if echoStatus then
            pcall(function() echoStatus(targetName, status, tag, sourceName) end)
        end
        if tag ~= "companion" and RezBotSync and RezBotSync.SendStatus then
            pcall(function() RezBotSync.SendStatus(targetName, charName, status, sourceName) end)
        end
    end
end

local function onCombat(_, result, _, abilityName, _, _, sourceName, _, targetName, _, _, _, _, _, sourceUnitId)
    local lname = (abilityName or ""):lower()
    if not lname:find("resurrect") then return end
    if not sourceUnitId or sourceUnitId == 0 or not targetName then return end
    RezBot.dbg("onCombat called with resurrect event: " .. lname)
    if cleanse then
        sourceName = cleanse(sourceName)
        targetName = cleanse(targetName)
    end

    local charName = targetName
    local tag = findUnitTagByName and findUnitTagByName(targetName)
    if not tag then
        RezBot.dbg("Target not in group, skipping setRezState for: " .. safe(targetName))
        return
    end
    RezBot.dbg("Target name is: " .. safe(targetName))
    local accountName = GetUnitDisplayName(tag)
    accountName = cleanse and cleanse(accountName) or accountName

    RezBot.dbg("Account name is: " .. safe(accountName))
    if RezBot and RezBot.saved and RezBot.saved.ignoreCompanions and tag == "companion" then
        if RezBot.dbg then pcall(function() RezBot.dbg("Ignoring companion resurrection event: " .. targetName) end) end
        return
    end

    if result == IGNORE or result == STUNNED then
        if RezBot and RezBot.dbg then
            pcall(function()
                RezBot.dbg(string.format("[Skip] %s → %s [%s] (IGNORED)", safe(sourceName), safe(accountName),
                    safe(lname)))
            end)
        end
        return
    end

    if RezBot and RezBot.dbg then
        pcall(function()
            RezBot.dbg(string.format("[Rez Event] [%s] %s → %s (%s)", safe(result), safe(sourceName), safe(accountName),
                safe(lname)))
            RezBot.dbg("Unit Tag: " .. safe(tag))
        end)
    end

    -- setRezState(targetName, RezBot.STATUS_DOWN, tag, nil, nil)

    if result == BEGIN then
        setRezState(accountName, charName, RezBot.STATUS_REZZING, tag, sourceName, sourceUnitId)
    elseif result == PENDING then
        setRezState(accountName, charName, RezBot.STATUS_PENDING, tag, sourceName, sourceUnitId)
    elseif result == REZZED then
        local normName = normalizeName(accountName)
        if resStates then resStates[normName] = nil end
        if echoStatus then
            pcall(function() echoStatus(accountName, "rez complete") end)
        end
        if RezBotSync and RezBotSync.SendStatus then
            pcall(function() RezBotSync.SendStatus(accountName, charName, "cleared", nil) end)
        end
    end
end



----------------------------------------------------------------
-- Group death polling -----------------------------------------
----------------------------------------------------------------
local function pollGroupDeaths()
    local function setStatus(name, charName, status, rezzer, tag)
        if not name or not status then return end
        local normName = normalizeName(name)
        resStates = resStates or {}
        local entry = resStates[normName]
        if not entry or entry.status ~= status or entry.rezzer ~= rezzer then
            resStates[normName] = {
                status = status,
                since = GetGameTimeMilliseconds(),
                rezzer = rezzer,
                tag = tag or (findUnitTagByName and findUnitTagByName(name)),
            }
            if tag ~= "companion" and RezBotSync and RezBotSync.SendStatus then
                RezBot.dbg("Sending status update for " .. name .. ": " .. status)
                pcall(function() RezBotSync.SendStatus(name, charName, status, rezzer) end)
            end
            if echoStatus then
                pcall(function() echoStatus(name, status) end)
            end
        end
    end

    local function checkDeathAndRezState(tag)
        if not DoesUnitExist or not DoesUnitExist(tag) then return end
        local name = cleanse and cleanse(GetUnitDisplayName(tag)) or GetUnitDisplayName(tag)
        local charName = GetUnitName(tag)

        if not name or name == "" then
            RezBot.dbg("checkDeathAndRezState: No name found for tag: " .. tostring(tag))
            return
        end
        if not GetUnitName or not GetUnitName(tag) then
            RezBot.dbg("GetUnitName failed for tag: " .. tostring(tag))
            return
        end

        if not charName or charName == "" then return end
        if not name or name == "" then return end

        local normName = normalizeName(name)
        local isDead = IsUnitDead and IsUnitDead(tag) and GetUnitPower(tag, POWERTYPE_HEALTH) == 0
        local isBeingRezzed = IsUnitBeingResurrected and IsUnitBeingResurrected(tag)
        local isPending = IsResurrectPending and IsResurrectPending(tag)

        if isDead then
            if isBeingRezzed then
                setStatus(normName, charName, RezBot.STATUS_REZZING, nil, tag)
            elseif isPending then
                RezBot.dbg("[PENDING] Event triggered")
                setStatus(normName, charName, RezBot.STATUS_PENDING, nil, tag)
            else
                -- Only set to DOWN if not already pending or rezzing (from sync)
                local entry = resStates[normName]
                if not entry or (entry.status ~= RezBot.STATUS_PENDING and entry.status ~= RezBot.STATUS_REZZING) then
                    setStatus(normName, charName, RezBot.STATUS_DOWN, nil, tag)
                end
            end
        else
            if resStates and resStates[normName] then
                resStates[normName] = nil
                if tag ~= "companion" and RezBotSync and RezBotSync.SendStatus then
                    pcall(function() RezBotSync.SendStatus(normName, charName, "cleared", nil) end)
                end
                if RefreshUI then
                    pcall(function() RefreshUI() end)
                end
            end
        end
    end

    for i = 1, GROUP_SIZE_MAX do
        checkDeathAndRezState("group" .. i)
    end

    if DoesUnitExist("player") then
        checkDeathAndRezState("player")
    end

    if not (RezBot and RezBot.saved and RezBot.saved.ignoreCompanions) then
        checkDeathAndRezState("companion")
    end

    for name, entry in pairs(resStates or {}) do
        -- this needs to be a display name
        local charName = getCharNameFromAccountName and getCharNameFromAccountName(name) or name
        local tag = findUnitTagByName and findUnitTagByName(charName)
        if not tag then
            RezBot.dbg("No tag found for " .. tostring(charName))
            return
        else
            --
        end
        local stillDead = tag and IsUnitDead and IsUnitDead(tag) and GetUnitPower(tag, POWERTYPE_HEALTH) == 0
        -- RezBot.dbg("Checking death state for " .. name .. ": " .. tostring(stillDead))
        local stillBeingRezzed = tag and IsUnitBeingResurrected and IsUnitBeingResurrected(tag)
        -- RezBot.dbg("Checking rezzing state for " .. name .. ": " .. tostring(stillBeingRezzed))
        local stillPending = tag and IsResurrectPending and IsResurrectPending(tag)
        -- RezBot.dbg("Checking pending state for " .. name .. ": " .. tostring(stillPending))

        if not stillDead and not stillBeingRezzed and not stillPending then
            if RezBot and RezBot.dbg then
                pcall(function()
                    RezBot.dbg(name .. " is no longer dead/pending/rezzing (cleared in sweep)")
                end)
            end
            local normName = normalizeName(name)
            resStates[normName] = nil
            if RezBotSync and RezBotSync.SendStatus then
                pcall(function() RezBotSync.SendStatus(normName, "cleared", nil) end)
            end
            if RefreshUI then
                pcall(function() RefreshUI() end)
            end
        end
    end
end


----------------------------------------------------------------
-- Update ticker -----------------------------------------------
-- Runs every tick (100ms) to check for timeouts or dead units.
-- If someone stops casting rez mid-way, assume it failed.
----------------------------------------------------------------
local function onUpdate()
    local now = (type(since) == "number" and since > 0) and since or GetGameTimeMilliseconds()
    for name, entry in pairs(resStates) do
        -- Only set to DOWN if not pending (protects against sync overwrites)
        if entry.status == RezBot.STATUS_REZZING and not IsUnitBeingResurrected(entry.tag) then
            if entry.status ~= RezBot.STATUS_PENDING then
                RezBot.dbg("Tag: " .. tostring(entry.tag))
                RezBot.dbg(string.format("%s's rez from %s timed out", name, tostring(entry.rezzer)))
                entry.status = RezBot.STATUS_DOWN
                entry.since  = now
                entry.rezzer = nil
            end
        end
    end

    pollGroupDeaths()
    RefreshUI()
end

----------------------------------------------------------------
-- Enable / Disable --------------------------------------------
----------------------------------------------------------------

local function register()
    EVENT_MANAGER:RegisterForEvent(RezBot.name, EVENT_COMBAT_EVENT, onCombat)
    EVENT_MANAGER:RegisterForUpdate(RezBot.name .. "_Tick", UPDATE_MS, onUpdate)
end

local function unregister()
    EVENT_MANAGER:UnregisterForEvent(RezBot.name, EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForUpdate(RezBot.name .. "_Tick")
    resStates = {}; RefreshUI()
end


function RezBot.Enable(state)
    RezBot.saved.enabled = state
    if state then register() else unregister() end
    RezBot.dbg(state and "Enabled" or "Disabled")
end

----------------------------------------------------------------
-- Settings Panel
----------------------------------------------------------------
local function AddSettings()
    local HAS = LibHarvensAddonSettings
    if not HAS then return end

    local panel = HAS:AddAddon(RezBot.name, {
        allowDefaults = true,
        allowRefresh = true,
        defaultsFunction = function()
            -- Reset each saved key to its default, preserving metatables and extra keys
            for k, v in pairs(RezBot.defaults) do
                RezBot.saved[k] = v
            end
            RefreshUI()
        end,
    })
    if not panel then return end

    panel.panelControl = panel

    ----------------------------------------------------------------
    -- GENERAL
    ----------------------------------------------------------------
    panel:AddSetting({ type = HAS.ST_HEADER, label = "General" })

    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Disable UI",
        tooltip = "Hide the on-screen list without disabling tracking.",
        default = true,
        getFunction = function() return RezBot.saved.uiEnabled end,
        setFunction = function(val)
            RezBot.saved.uiEnabled = val; uiFrame:SetHidden(not val)
        end,
    })

    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Chat Output",
        tooltip = "Echo RezBot events to the chat window. Pair with Disable UI to save screen real estate.",
        default = false,
        getFunction = function() return RezBot.saved.chatOutput end,
        setFunction = function(val) RezBot.saved.chatOutput = val end,
    })

    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Ignore Companion Deaths",
        tooltip = "Prevents companions from cluttering your death list. They’ve died enough already.",
        getFunction = function() return RezBot.saved.ignoreCompanions end,
        setFunction = function(val)
            RezBot.saved.ignoreCompanions = val
            if val then purgeCompanions() end
            RefreshUI()
        end,
        default = true,
    })

    if GetDisplayName() == "@ohmygoron" or GetDisplayName() == "@goron_spice" then
        panel:AddSetting({
            type = HAS.ST_CHECKBOX,
            label = "Enable Debug Logging",
            tooltip = "Developer-only logging for testing and diagnostics.",
            default = false,
            getFunction = function() return RezBot.saved.debug end,
            setFunction = function(val) RezBot.saved.debug = val end,
        })
        if RezBotDebugLog and RezBotDebugLog.RegisterSetting then
            RezBotDebugLog.RegisterSetting(panel)
        end
    end

    ----------------------------------------------------------------
    -- TEXT
    ----------------------------------------------------------------
    panel:AddSetting({ type = HAS.ST_SECTION, label = "Text" })

    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Show Header Label",
        tooltip = "Toggles the 'REZ TRACKER:' label at the top of the UI.",
        default = true,
        getFunction = function() return RezBot.saved.showHeaderLabel end,
        setFunction = function(val)
            RezBot.saved.showHeaderLabel = val
            RezBotUILabel:SetHidden(not val)
            RezBotUIList:ClearAnchors()
            if val then
                RezBotUIList:SetAnchor(TOPLEFT, RezBotUILabel, BOTTOMLEFT, 0, 0)
                RezBotUIList:SetAnchor(TOPRIGHT, RezBotUILabel, BOTTOMRIGHT, 0, 0)
                RezBotUIList:SetWidth(400)
            else
                RezBotUIList:SetAnchor(TOPLEFT, RezBotUI, TOPLEFT, 20, 10) -- manual offset to match label height
                RezBotUIList:SetAnchor(TOPRIGHT, RezBotUI, TOPRIGHT, -20, 10)
                RezBotUIList:SetWidth(400)
            end

            RefreshUI()
        end,
    })

    panel:AddSetting({
        type = HAS.ST_SLIDER,
        label = "Font Size",
        tooltip = "Adjust the row font by stepping through ESO's gamepad font sizes.",
        min = 1,
        max = #FONT_OPTS,
        step = 1,
        default = 5,
        getFunction = function()
            return RezBot.saved.fontIndex or 5
        end,
        setFunction = function(val)
            RezBot.saved.fontIndex = val
            RezBot.saved.fontName  = fontByIndex(val)
            RefreshUI()
        end,
    })

    panel:AddSetting({
        type = HAS.ST_COLOR,
        label = "Needs Resurrection Color",
        tooltip =
        "Choose the text color for players needing resurrection. Only applies to players with RezBot installed.",

        getFunction = function()
            return unpack(RezBot.saved.colorDown)
        end,
        setFunction = function(r, g, b, a)
            RezBot.saved.colorDown = { r, g, b, a }
            RefreshUI()
        end,
        default = { 1.00, 0.33, 0.33, 1.0 },
    })

    panel:AddSetting({
        type = HAS.ST_COLOR,
        label = "Being Resurrected Color",
        tooltip = "Choose the text color for players being resurrected. Only applies to players with RezBot installed.",
        getFunction = function()
            return unpack(RezBot.saved.colorRezzing)
        end,
        setFunction = function(r, g, b, a)
            RezBot.saved.colorRezzing = { r, g, b, a }
            RefreshUI()
        end,
        default = { 0.33, 1.0, 0.33, 1.0 },
    })


    panel:AddSetting({
        type = HAS.ST_COLOR,
        label = "Pending Resurrection Color",
        tooltip =
        "Choose the text color for players pending resurrection. Only applies to players with RezBot installed.",
        getFunction = function()
            return unpack(RezBot.saved.colorPending)
        end,
        setFunction = function(r, g, b, a)
            RezBot.saved.colorPending = { r, g, b, a }
            RefreshUI()
        end,
        default = { 1.00, 0.87, 0.33, 1.0 },
    })

    ----------------------------------------------------------------
    -- LAYOUT
    ----------------------------------------------------------------
    panel:AddSetting({ type = HAS.ST_SECTION, label = "Layout" })

    panel:AddSetting({
        type = HAS.ST_DROPDOWN,
        label = "Position",
        items = {
            { name = "TOP LEFT",     data = 1 },
            { name = "TOP",          data = 2 },
            { name = "TOP RIGHT",    data = 3 },
            { name = "LEFT",         data = 4 },
            { name = "CENTER",       data = 5 },
            { name = "RIGHT",        data = 6 },
            { name = "BOTTOM LEFT",  data = 7 },
            { name = "BOTTOM",       data = 8 },
            { name = "BOTTOM RIGHT", data = 9 },
        },
        default = "RIGHT",
        getFunction = function()
            return prettifyAnchor(RezBot.saved.anchorPoint or "TOPLEFT")
        end,
        setFunction = function(control, itemName, itemData)
            RezBot.saved.anchorPoint = uglifyAnchor(itemName)
            local anchor = safeAnchor(RezBot.saved.anchorPoint)
            uiFrame:ClearAnchors()
            uiFrame:SetAnchor(anchor, GuiRoot, anchor, RezBot.saved.offsetX, RezBot.saved.offsetY)

            RefreshUI()
        end,
    })

    local function offsetSlider(label, key, default)
        panel:AddSetting({
            type = HAS.ST_SLIDER,
            label = label,
            min = -500,
            max = 500,
            step = 1,
            default = default,
            getFunction = function() return RezBot.saved[key] end,
            setFunction = function(val)
                RezBot.saved[key] = val
                uiFrame:ClearAnchors()
                local a = safeAnchor(RezBot.saved.anchorPoint)
                uiFrame:SetAnchor(a, GuiRoot, a,
                    RezBot.saved.offsetX, RezBot.saved.offsetY)
            end,
        })
    end
    offsetSlider("X Offset", "offsetX", 0)
    offsetSlider("Y Offset", "offsetY", -50)

    panel:AddSetting({
        type = HAS.ST_SLIDER,
        label = "Background Opacity",
        tooltip = "Adjusts the background transparency of the on-screen list.",
        min = 0,
        max = 1.0,
        step = 0.05,
        default = 0.85,
        getFunction = function() return RezBot.saved.uiOpacity end,
        setFunction = function(val)
            RezBot.saved.uiOpacity = val
            local r, g, b = unpack(RezBot.saved.uiBackgroundColor)
            RezBot.saved.uiBackgroundColor = { r, g, b, val }
            RefreshUI()
        end,
    })

    panel:AddSetting({
        type = HAS.ST_COLOR,
        label = "UI Background Color",
        tooltip = "Choose the background color of the on-screen list",
        getFunction = function()
            local r, g, b = unpack(RezBot.saved.uiBackgroundColor)
            local a = RezBot.saved.uiOpacity or 0.75
            return r, g, b, a
        end,
        setFunction = function(r, g, b, a)
            RezBot.saved.uiBackgroundColor = { r, g, b, a } -- Storing only RBG as console can't control alpha
            RefreshUI()
        end,
        default = { 0.00, 0.00, 0.00, 0.75 },
    })

    ----------------------------------------------------------------
    -- STATUSES
    ----------------------------------------------------------------
    panel:AddSetting({ type = HAS.ST_SECTION, label = "Filter Statuses" })

    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Show 'Down'",
        tooltip = "Display players who are dead and need a resurrection.",
        default = true,
        getFunction = function() return RezBot.saved.showDown end,
        setFunction = function(val)
            RezBot.saved.showDown = val; RefreshUI()
        end,
    })

    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Show 'Pending'",
        tooltip = "Display players who haven't accepted a pending resurrection.",
        default = true,
        getFunction = function() return RezBot.saved.showPending end,
        setFunction = function(val)
            RezBot.saved.showPending = val; RefreshUI()
        end,
    })

    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Show 'Being Rezzed'",
        tooltip = "Display players who are actively being resurrected.",
        default = true,
        getFunction = function() return RezBot.saved.showRezzing end,
        setFunction = function(val)
            RezBot.saved.showRezzing = val; RefreshUI()
        end,
    })

    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Show Tanks",
        tooltip = "Display tanks in the resurrection tracker.",
        default = true,
        getFunction = function() return RezBot.saved.showTanks ~= false end,
        setFunction = function(val)
            RezBot.saved.showTanks = val; RefreshUI()
        end,
    })

    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Show Healers",
        tooltip = "Display healers in the resurrection tracker.",
        default = true,
        getFunction = function() return RezBot.saved.showHealers ~= false end,
        setFunction = function(val)
            RezBot.saved.showHealers = val; RefreshUI()
        end,
    })

    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Show DPS",
        tooltip = "Display DPS in the resurrection tracker.",
        default = true,
        getFunction = function() return RezBot.saved.showDPS ~= false end,
        setFunction = function(val)
            RezBot.saved.showDPS = val; RefreshUI()
        end,
    })
end


----------------------------------------------------------------
-- SLASH COMMANDS ----------------------------------------------
----------------------------------------------------------------
-- Helper to print current tank/healer/dps display settings
local function showStatus()
    d(string.format(
        "RezBot: showTanks=%s, showHealers=%s, showDPS=%s",
        tostring(RezBot.saved.showTanks ~= false),
        tostring(RezBot.saved.showHealers ~= false),
        tostring(RezBot.saved.showDPS ~= false)
    ))
end

SLASH_COMMANDS["/rezbot"] = function(text)
    local arg = string.lower(text or ""):match("^%s*(.-)%s*$") -- trim whitespace

    if arg == "help" then
        d("RezBot Commands:")
        d("/rezbot           - Show current version")
        d("/rezbot help      - Show this help message")
        d("/rezbot clear     - Clear all tracked resurrection states")
        d("/rezbot status    - Show current tank/healer/dps display settings")
        d("/rezbot tanks     - Toggle showTanks")
        d("/rezbot healers   - Toggle showHealers")
        d("/rezbot dps       - Toggle showDPS")
        d("/rezbot list      - List all tracked players and their properties")
    elseif arg == "list" then
        d("RezBot: Listing all tracked players in resStates:")
        for name, entry in pairs(resStates or {}) do
            local props = {}
            for k, v in pairs(entry) do
                table.insert(props, k .. "=" .. tostring(v))
            end
            d(string.format("  %s: %s", tostring(name), table.concat(props, ", ")))
        end
    elseif arg == "clear" then
        resStates = {}
        RefreshUI()
        d("RezBot: all resurrection states cleared.")
    elseif arg == "status" then
        showStatus()
    elseif arg == "tanks" then
        RezBot.saved.showTanks = not (RezBot.saved.showTanks ~= false)
        RefreshUI()
        d("RezBot: showTanks set to " .. tostring(RezBot.saved.showTanks ~= false))
        showStatus()
    elseif arg == "healers" then
        RezBot.saved.showHealers = not (RezBot.saved.showHealers ~= false)
        RefreshUI()
        d("RezBot: showHealers set to " .. tostring(RezBot.saved.showHealers ~= false))
        showStatus()
    elseif arg == "dps" then
        RezBot.saved.showDPS = not (RezBot.saved.showDPS ~= false)
        RefreshUI()
        d("RezBot: showDPS set to " .. tostring(RezBot.saved.showDPS ~= false))
        showStatus()
    elseif arg == "" then
        d("RezBot v" .. RezBot.version .. " — type '/rezbot help' for commands.")
    elseif arg == "meril" then
        d("RezBot: ")
        d("        __,----._.--, .")
        d("     /\\_r---,    \\__   )")
        d(".--.)   __;='__ _/   (. ;")
        d("\\    \\'            \\/        )")
        d("  L.   '---.  ___.'        ||--'")
        d("  <_`---'   \\ '_.      /")
        d("     `'---. __(     //")
        d("     ___      \\ \\,         _____")
        d("    \\      .'--.   \\ \\     --'__.    /")
        d("        '.__'   '.  \\ \\/.--' __.'' ")
        d("            '----``   \\  ( '----' ")
        d("~* m e r y l *~     \\ \\")
        d("                            `\\ \\,")
        d("                                \\||")
    elseif arg == "bean" then
        d("RezBot: ")
        d("           c,_.--------.,..p")
        d("            7        a . a (")
        d("           (              ,_Y)")
        d("            :            '-----;")
        d("      ___.'\\.     ----- (")
        d("   .'\"\"\"\"\"S,._'------'_2..,_____")
        d(" ||            ':::::::=:::::::              \\")
        d("  .           f== ;--,---------.'        T")
        d("   Y.          r,------,_/_            ||")
        d("     ||:\\___.------'         '-----./")
        d("     ||'`                            )")
        d("       \\                            ,")
        d("       ':;,.__________.;L")
        d("     /     '----------------'     ||")
        d("    ||                                \\")
        d("    L-----'------,----.---'---,-------'")
        d("        T       /      \\      Y")
        d("        ||      Y       ,      ||")
        d("        ||      \\      (      ||")
        d("        (      )          \\,_L")
        d("        7-.   /            )  `,")
        d("       /     _(            '._  \\")
        d("     That'll do, Bean. That'll do.")
    elseif arg == "shib" then
        d("RezBot: ")
        d("    /\\    /\\")
        d("  (   o    o   )    In loving memory of Rick")
        d("  \\  >#<   /    Faithful companion to Shib,")
        d("  /            \\   silent observer of heals cast.")
        d(" (              )   May his spirit nap in peace.")
        d("  \\__/\\__/")
    elseif arg == "goron" then
        d("RezBot: ")
        d("  ^ _____^        ,--.")
        d("(     ^    ^    )    / ,-'")
        d(" \\   =_T_= /-._( (")
        d("/                  `. \\")
        d("||                  _    \\")
        d(" \\    \\ ,           /     ||")
        d("  ||    |-_\\__         /")
        d(" ((_/`   (____,-'   In loving memory of Boo,")
        d("faithful companion to Goron")
    elseif arg == "bless" then
        d("RezBot blesses your run. May your parse be higher than your latency.")
    else
        d("RezBot: unknown command '" .. arg .. "'. Try '/rezbot help'.")
    end
end


----------------------------------------------------------------
-- INTIALIZATION -----------------------------------------------
----------------------------------------------------------------

local function onLoaded(_, addon)
    if addon ~= RezBot.name then return end
    RezBot.saved = ZO_SavedVars:NewAccountWide("RezBotSV", 1, nil, RezBot.defaults)

    -- Failsafe: fill in any missing keys
    for k, v in pairs(RezBot.defaults) do
        if RezBot.saved[k] == nil then
            RezBot.saved[k] = v
        end
    end

    RezBotUIVersion:SetText("RezBot v" .. RezBot.version)
    EnsureUI()

    if uiFrame then
        uiFrame:ClearAnchors()
        local anchor = safeAnchor(RezBot.saved.anchorPoint or "TOPLEFT")
        uiFrame:SetAnchor(anchor, GuiRoot, anchor,
            RezBot.saved.offsetX or 0,
            RezBot.saved.offsetY or 0)
    end

    if RezBot.saved.enabled then
        register()
    end

    AddSettings()

    EVENT_MANAGER:RegisterForUpdate("RezBot_CheckHarvenScene", 500, function()
        local scene = SCENE_MANAGER:GetScene("LibHarvensAddonSettingsScene")
        if scene then
            scene:RegisterCallback("StateChange", function(oldState, newState)
                local HAS = LibHarvensAddonSettings
                -- Only react if REZBOT is selected
                if HAS and HAS.selectedAddon == RezBot.name then
                    if newState == SCENE_SHOWING then
                        isSettingsOpen = true
                        RefreshUI()
                    elseif newState == SCENE_HIDDEN then
                        isSettingsOpen = false
                        RefreshUI()
                    end
                end
            end)
            EVENT_MANAGER:UnregisterForUpdate("RezBot_CheckHarvenScene")
        end
    end)

    -- Apply saved header visibility BEFORE anchoring anything dependent on it
    RezBotUILabel:SetHidden(not RezBot.saved.showHeaderLabel)

    -- Re-anchor the list container properly based on current header state
    RezBotUIList:ClearAnchors()
    if RezBot.saved.showHeaderLabel then
        RezBotUIList:SetAnchor(TOPLEFT, RezBotUILabel, BOTTOMLEFT, 0, 0)
        RezBotUIList:SetAnchor(TOPRIGHT, RezBotUILabel, BOTTOMRIGHT, 0, 0)
        RezBotUIList:SetWidth(400)
    else
        RezBotUIList:SetAnchor(TOPLEFT, RezBotUI, TOPLEFT, 20, 10)
        RezBotUIList:SetAnchor(TOPRIGHT, RezBotUI, TOPRIGHT, -20, 10)
        RezBotUIList:SetWidth(400)
    end

    RefreshUI()

    RezBot.dbg("v" .. RezBot.version .. " loaded")

    -- Notify RezBotSync that this user has RezBot
    if RezBotSync and RezBotSync.isInstalled then
        local playerName = cleanse and cleanse(GetUnitDisplayName("player")) or GetUnitDisplayName("player")
        local charName = cleanse and cleanse(GetUnitName("player")) or GetUnitName("player")
        pcall(function()
            RezBotSync.isInstalled(playerName, charName)
        end)
    end
end

EVENT_MANAGER:RegisterForEvent(RezBot.name .. "_Load", EVENT_ADD_ON_LOADED, onLoaded)
EVENT_MANAGER:RegisterForEvent("RezBotCombatDeath", EVENT_COMBAT_EVENT,
    function(_, result, _, _, _, _, _, _, targetName, targetType)
        if result == ACTION_RESULT_DIED and (targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_GROUP) then
            RezBot.dbg("Player death detected and Target Type: " .. tostring(targetType))
            local cleansedName = cleanse and cleanse(targetName) or targetName
            local tag = findUnitTagByName and findUnitTagByName(cleansedName)
            setRezState(cleansedName, RezBot.STATUS_DOWN, tag, nil, nil)
        end
    end)

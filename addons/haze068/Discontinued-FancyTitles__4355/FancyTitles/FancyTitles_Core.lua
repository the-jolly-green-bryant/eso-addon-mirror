--[[
    FancyTitles Core
    Version: 5.2.0
    
    Changes from 5.1:
    - New ftchatdata.lua: per-player chat name color, message color, custom display name
    - Chat hook now uses FancyTitles_ChatData instead of global color
    - Admin commands for chat data management
]]--

FancyTitles = {}
FancyTitles.name = "FancyTitles"
FancyTitles.version = "5.2.0"
FancyTitles.author = "@haze068"
FancyTitles.discordUrl = "https://discord.gg/jPwtKbtu8W"

FancyTitles.ADMIN_ACCOUNTS = {
    ["@haze068"] = true,
	["@abstand1312"] = true,
	["@raikiki"] = true,
	["@keytextv"] = true,
}

-- Rank order: creator, exclusive, enjoyer (removed admin and supporter)
FancyTitles.RANK_CONFIG = {
    creator = { gradient = { "FF6B00", "FFD700", "FFFACD" }, order = 1 },
    exclusive = { gradient = { "E6007E", "FF1493", "FF69B4", "FFB6C1", "E6007E" }, order = 2 },
    enjoyer = { gradient = { "FF0000", "FF2400", "FF4500", "FF6600", "FF0000" }, order = 3 },
}

-- Rank display order for lists (removed admin and supporter)
FancyTitles.RANK_ORDER = {"creator", "exclusive", "enjoyer"}

local COLORS = {
    SUCCESS = "00FF00", ERROR = "FF4444", WARNING = "FFAA00",
    INFO = "00AAFF", WHITE = "FFFFFF", GRAY = "888888", ADMIN = "FF00FF",
}

local registeredTitles = {}

-- Internal title storage
FancyTitles.customTitles = {}

--- Register a custom title for a display name
-- @param displayName The player's display name (e.g., "@PlayerName")
-- @param title The custom title to display (can include color codes)
-- @return true if successful, false otherwise
function FancyTitles.RegisterCustomTitle(displayName, title)
    if type(displayName) ~= "string" or type(title) ~= "string" then 
        return false 
    end
    displayName = displayName:lower()
    if displayName:sub(1, 1) ~= "@" then 
        displayName = "@" .. displayName 
    end
    FancyTitles.customTitles[displayName] = title
    return true
end

--- Unregister a custom title for a display name
-- @param displayName The player's display name
-- @return true if successful, false otherwise
function FancyTitles.UnregisterCustomTitle(displayName)
    if type(displayName) ~= "string" then 
        return false 
    end
    displayName = displayName:lower()
    if displayName:sub(1, 1) ~= "@" then 
        displayName = "@" .. displayName 
    end
    FancyTitles.customTitles[displayName] = nil
    return true
end

--- Get the custom title for a display name
-- @param displayName The player's display name
-- @return The custom title or nil if not found
function FancyTitles.GetCustomTitle(displayName)
    if type(displayName) ~= "string" then 
        return nil 
    end
    displayName = displayName:lower()
    if displayName:sub(1, 1) ~= "@" then 
        displayName = "@" .. displayName 
    end
    return FancyTitles.customTitles[displayName]
end

-- Hook into GetUnitTitle to return custom titles
-- Supports combining ESO title with custom title based on settings
local originalGetUnitTitle = GetUnitTitle
if originalGetUnitTitle then
    GetUnitTitle = function(unitTag)
        local displayName = GetUnitDisplayName(unitTag)
        if displayName then
            local customTitle = FancyTitles.GetCustomTitle(displayName)
            if customTitle then
                -- Check if we should combine with ESO title
                if FancyTitles.db and FancyTitles.db.showEsoTitle then
                    local esoTitle = originalGetUnitTitle(unitTag)
                    if esoTitle and esoTitle ~= "" then
                        return string.format("%s |c888888-|r %s", esoTitle, customTitle)
                    end
                end
                return customTitle
            end
        end
        return originalGetUnitTitle(unitTag)
    end
end

--[[
    ============================================
    Core Utility Functions
    ============================================
]]--

local function HexToRGB(hex)
    hex = hex:gsub("#", "")
    if #hex ~= 6 then return 1, 1, 1 end
    return tonumber(hex:sub(1, 2), 16) / 255,
           tonumber(hex:sub(3, 4), 16) / 255,
           tonumber(hex:sub(5, 6), 16) / 255
end

local function RGBToHex(r, g, b)
    return string.format("%02X%02X%02X", math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5))
end

local function ColorText(text, hexColor)
    if not text or text == "" then return "" end
    if type(text) ~= "string" then text = tostring(text) end
    return string.format("|c%s%s|r", hexColor, text)
end

local function LerpColor(hex1, hex2, t)
    local r1, g1, b1 = HexToRGB(hex1)
    local r2, g2, b2 = HexToRGB(hex2)
    return RGBToHex(r1 + (r2 - r1) * t, g1 + (g2 - g1) * t, b1 + (b2 - b1) * t)
end

-- Split a UTF-8 string into a table of individual characters
-- Handles multi-byte chars (umlauts, special chars, etc.)
local function Utf8Chars(text)
    local chars = {}
    local i = 1
    local len = #text
    while i <= len do
        local byte = text:byte(i)
        local charLen = 1
        if byte >= 240 then     -- 4-byte sequence (emojis etc.)
            charLen = 4
        elseif byte >= 224 then -- 3-byte sequence
            charLen = 3
        elseif byte >= 192 then -- 2-byte sequence (umlauts: ä ö ü ß etc.)
            charLen = 2
        end
        -- Safety: don't exceed string length
        if i + charLen - 1 > len then charLen = len - i + 1 end
        table.insert(chars, text:sub(i, i + charLen - 1))
        i = i + charLen
    end
    return chars
end

local function CreateMultiGradientText(text, colors)
    if type(text) ~= "string" or text == "" then return tostring(text or "") end
    if not colors or #colors == 0 then return text end
    if #colors == 1 then return ColorText(text, colors[1]) end

    local chars = Utf8Chars(text)
    local numChars = #chars
    if numChars == 0 then return "" end

    local result = ""
    local segments = #colors - 1

    for i = 1, numChars do
        local char = chars[i]
        if char == " " then
            result = result .. " "
        else
            local progress = (i - 1) / math.max(numChars - 1, 1)
            local scaledProgress = progress * segments
            local segmentIndex = math.min(math.floor(scaledProgress), segments - 1)
            local segmentProgress = scaledProgress - segmentIndex
            local finalColor = LerpColor(colors[segmentIndex + 1], colors[segmentIndex + 2], segmentProgress)
            result = result .. string.format("|c%s%s|r", finalColor, char)
        end
    end
    return result
end

local function CreateRainbowText(text)
    return CreateMultiGradientText(text, { "FF0000", "FF8000", "FFFF00", "00FF00", "00FFFF", "0080FF", "8000FF", "FF00FF" })
end

--- Colorize chat text while preserving ESO links (items, achievements, etc.)
-- ESO links have the format: |H...|h...|h
-- These must NOT be modified by color codes, otherwise they break.
-- This function splits the text into link and non-link segments,
-- only applies coloring to non-link parts, and leaves links untouched.
local function ColorizePreservingLinks(text, colors)
    if type(text) ~= "string" or text == "" then return text end

    -- Split text into segments: { {text, isLink}, ... }
    local segments = {}
    local pos = 1
    local len = #text

    while pos <= len do
        -- Find the next ESO link start: |H
        local linkStart = text:find("|H", pos, true)
        if not linkStart then
            -- No more links, rest is plain text
            table.insert(segments, { text = text:sub(pos), isLink = false })
            break
        end

        -- Add plain text before the link
        if linkStart > pos then
            table.insert(segments, { text = text:sub(pos, linkStart - 1), isLink = false })
        end

        -- Find the closing |h...|h pattern
        -- ESO link format: |H<linkData>|h<displayText>|h
        -- First |h after |H marks end of link data / start of display text
        local firstH = text:find("|h", linkStart + 2, true)
        if not firstH then
            -- Malformed link, treat rest as plain text
            table.insert(segments, { text = text:sub(linkStart), isLink = false })
            break
        end
        -- Second |h marks end of the link
        local secondH = text:find("|h", firstH + 2, true)
        if not secondH then
            -- Malformed link, treat rest as plain text
            table.insert(segments, { text = text:sub(linkStart), isLink = false })
            break
        end

        -- Full link: from |H to the second |h (inclusive)
        local linkEnd = secondH + 1  -- "|h" is 2 chars, so end at secondH+1
        table.insert(segments, { text = text:sub(linkStart, linkEnd), isLink = true })
        pos = linkEnd + 1
    end

    -- Now colorize only non-link segments
    -- For gradient: we need to track character position across all non-link segments
    -- so the gradient flows naturally across the entire message
    if not colors or #colors == 0 then
        -- No colors, return as-is
        local result = ""
        for _, seg in ipairs(segments) do
            result = result .. seg.text
        end
        return result
    end

    -- Count total visible (non-link) characters for gradient calculation
    local totalPlainChars = 0
    local plainCharLists = {}
    for idx, seg in ipairs(segments) do
        if not seg.isLink then
            local chars = Utf8Chars(seg.text)
            plainCharLists[idx] = chars
            for _, c in ipairs(chars) do
                if c ~= " " then
                    totalPlainChars = totalPlainChars + 1
                end
            end
        end
    end

    if totalPlainChars == 0 then
        -- Only links or spaces, return as-is
        local result = ""
        for _, seg in ipairs(segments) do
            result = result .. seg.text
        end
        return result
    end

    -- Single color mode (no gradient needed)
    local singleColor = (#colors == 1) or (totalPlainChars <= 1)

    local result = ""
    local charIndex = 0  -- running index of visible non-space chars across all segments
    local numSegments = #colors - 1

    for idx, seg in ipairs(segments) do
        if seg.isLink then
            -- Link: add unchanged
            result = result .. seg.text
        else
            local chars = plainCharLists[idx] or Utf8Chars(seg.text)
            for _, char in ipairs(chars) do
                if char == " " then
                    result = result .. " "
                else
                    if singleColor then
                        result = result .. string.format("|c%s%s|r", colors[1], char)
                    else
                        local progress = charIndex / math.max(totalPlainChars - 1, 1)
                        local scaledProgress = progress * numSegments
                        local segmentIndex = math.min(math.floor(scaledProgress), numSegments - 1)
                        local segmentProgress = scaledProgress - segmentIndex
                        local finalColor = LerpColor(colors[segmentIndex + 1], colors[segmentIndex + 2], segmentProgress)
                        result = result .. string.format("|c%s%s|r", finalColor, char)
                    end
                    charIndex = charIndex + 1
                end
            end
        end
    end

    return result
end

local function NormalizeDisplayName(displayName)
    if type(displayName) ~= "string" or displayName == "" then return "" end
    displayName = displayName:gsub("^%s+", ""):gsub("%s+$", ""):lower()
    if displayName:sub(1, 1) ~= "@" then displayName = "@" .. displayName end
    return displayName
end

local function IsValidHexColor(hex)
    if type(hex) ~= "string" then return false end
    hex = hex:gsub("#", "")
    return #hex == 6 and hex:match("^%x+$") ~= nil
end

-- Returns a valid 6-char hex color, defaulting to FFFFFF if empty/invalid
local function SafeColor(hex, default)
    default = default or "FFFFFF"
    if type(hex) ~= "string" or hex == "" or not IsValidHexColor(hex) then return default end
    return hex:gsub("#", ""):upper()
end

local function IsValidRank(rankId)
    return type(rankId) == "string" and FancyTitles.RANK_CONFIG[rankId:lower()] ~= nil
end

local function IsCurrentPlayerAdmin()
    return FancyTitles.ADMIN_ACCOUNTS[NormalizeDisplayName(GetDisplayName())] == true
end

local function SafeFormat(message, ...)
    if not message or message == "" then return "" end
    local args = {...}
    if #args == 0 then return message end
    local success, result = pcall(string.format, message, ...)
    return success and result or message
end

local function LogSuccess(message, ...) d(ColorText("[FancyTitles]", COLORS.GRAY) .. " " .. ColorText(SafeFormat(message, ...), COLORS.SUCCESS)) end
local function LogError(message, ...) d(ColorText("[FancyTitles]", COLORS.GRAY) .. " " .. ColorText(SafeFormat(message, ...), COLORS.ERROR)) end
local function LogWarning(message, ...) d(ColorText("[FancyTitles]", COLORS.GRAY) .. " " .. ColorText(SafeFormat(message, ...), COLORS.WARNING)) end
local function LogInfo(message, ...) d(ColorText("[FancyTitles]", COLORS.GRAY) .. " " .. ColorText(SafeFormat(message, ...), COLORS.INFO)) end
local function LogAdmin(message, ...) d(ColorText("[FancyTitles]", COLORS.GRAY) .. " " .. CreateRainbowText(SafeFormat(message, ...))) end

--[[
    ============================================
    Player Data Management
    ============================================
]]--

function FancyTitles.GetAllPlayers()
    return FancyTitles_Data or {}
end

function FancyTitles.GetPlayerData(displayName)
    return FancyTitles.GetAllPlayers()[NormalizeDisplayName(displayName)]
end

function FancyTitles.GetFormattedTitle(displayName)
    local playerData = FancyTitles.GetPlayerData(displayName)
    if not playerData or not playerData.title or playerData.title == "" then return nil end
    
    local colors
    if playerData.colorStart and playerData.colorEnd and playerData.colorStart ~= "" and playerData.colorEnd ~= "" then
        colors = { playerData.colorStart, playerData.colorEnd }
    else
        local config = FancyTitles.RANK_CONFIG[playerData.rank]
        colors = config and config.gradient
    end
    
    if not colors then return playerData.title end
    return CreateMultiGradientText(playerData.title, colors)
end

function FancyTitles.GetFormattedRank(rankId)
    local config = FancyTitles.RANK_CONFIG[rankId]
    if not config then return rankId or "" end
    local name = rankId:sub(1,1):upper() .. rankId:sub(2)
    return CreateMultiGradientText(name, config.gradient)
end

function FancyTitles.GetPlayerCounts()
    local counts = { creator = 0, exclusive = 0, enjoyer = 0, total = 0 }
    for _, playerData in pairs(FancyTitles.GetAllPlayers()) do
        if playerData.rank and counts[playerData.rank] then
            counts[playerData.rank] = counts[playerData.rank] + 1
        end
        counts.total = counts.total + 1
    end
    return counts
end

--[[
    ============================================
    Admin Functions
    ============================================
]]--

function FancyTitles.AddPlayer(displayName, rankId, title)
    if not IsCurrentPlayerAdmin() then LogError("No permission") return false end
    local normalized = NormalizeDisplayName(displayName)
    if normalized == "" then LogError("Invalid name") return false end
    rankId = rankId:lower()
    if not IsValidRank(rankId) then LogError("Invalid rank: %s (valid: creator, exclusive, enjoyer)", rankId) return false end
    if not title or title == "" then LogError("Title required") return false end
    if FancyTitles_Data[normalized] then LogWarning("Player exists, updating") end
    FancyTitles_Data[normalized] = { rank = rankId, title = title, colorStart = "", colorEnd = "" }
    FancyTitles.RegisterAllTitles()
    LogSuccess("Added %s as %s with title: %s", normalized, FancyTitles.GetFormattedRank(rankId), FancyTitles.GetFormattedTitle(normalized))
    return true
end

function FancyTitles.RemovePlayer(displayName)
    if not IsCurrentPlayerAdmin() then LogError("No permission") return false end
    local normalized = NormalizeDisplayName(displayName)
    if not FancyTitles_Data[normalized] then LogError("Player not found: %s", normalized) return false end
    FancyTitles_Data[normalized] = nil
    FancyTitles.UnregisterCustomTitle(normalized)
    FancyTitles.RegisterAllTitles()
    LogSuccess("Removed %s", normalized)
    return true
end

function FancyTitles.SetPlayerTitle(displayName, title)
    if not IsCurrentPlayerAdmin() then LogError("No permission") return false end
    local normalized = NormalizeDisplayName(displayName)
    local playerData = FancyTitles_Data[normalized]
    if not playerData then LogError("Player not found: %s", normalized) return false end
    if not title or title == "" then LogError("Title required") return false end
    playerData.title = title
    FancyTitles.RegisterAllTitles()
    LogSuccess("Title changed for %s: %s", normalized, FancyTitles.GetFormattedTitle(normalized))
    return true
end

function FancyTitles.SetPlayerRank(displayName, rankId)
    if not IsCurrentPlayerAdmin() then LogError("No permission") return false end
    local normalized = NormalizeDisplayName(displayName)
    local playerData = FancyTitles_Data[normalized]
    if not playerData then LogError("Player not found: %s", normalized) return false end
    rankId = rankId:lower()
    if not IsValidRank(rankId) then LogError("Invalid rank: %s (valid: creator, exclusive, enjoyer)", rankId) return false end
    playerData.rank = rankId
    FancyTitles.RegisterAllTitles()
    LogSuccess("Rank changed for %s: %s", normalized, FancyTitles.GetFormattedRank(rankId))
    return true
end

function FancyTitles.SetPlayerGradient(displayName, colorStart, colorEnd)
    if not IsCurrentPlayerAdmin() then LogError("No permission") return false end
    local normalized = NormalizeDisplayName(displayName)
    local playerData = FancyTitles_Data[normalized]
    if not playerData then LogError("Player not found: %s", normalized) return false end
    colorStart = colorStart:gsub("#", ""):upper()
    colorEnd = colorEnd:gsub("#", ""):upper()
    if not IsValidHexColor(colorStart) or not IsValidHexColor(colorEnd) then LogError("Invalid hex color (use 6-digit hex, e.g., FF00AA)") return false end
    playerData.colorStart = colorStart
    playerData.colorEnd = colorEnd
    FancyTitles.RegisterAllTitles()
    LogSuccess("Gradient changed for %s", normalized)
    return true
end

function FancyTitles.ResetPlayerGradient(displayName)
    if not IsCurrentPlayerAdmin() then LogError("No permission") return false end
    local normalized = NormalizeDisplayName(displayName)
    local playerData = FancyTitles_Data[normalized]
    if not playerData then LogError("Player not found: %s", normalized) return false end
    playerData.colorStart = nil
    playerData.colorEnd = nil
    FancyTitles.RegisterAllTitles()
    LogSuccess("Gradient reset for %s", normalized)
    return true
end

--[[
    ============================================
    Chat Data Management (ftchatdata.lua)
    ============================================
]]--

function FancyTitles.GetAllChatPlayers()
    return FancyTitles_ChatData or {}
end

function FancyTitles.GetChatData(displayName)
    return FancyTitles.GetAllChatPlayers()[NormalizeDisplayName(displayName)]
end

function FancyTitles.GetChatPlayerCounts()
    local count = 0
    for _ in pairs(FancyTitles.GetAllChatPlayers()) do count = count + 1 end
    return count
end

function FancyTitles.AddChatPlayer(displayName, nameColor, msgColorStart, msgColorEnd, chatDisplayName)
    if not IsCurrentPlayerAdmin() then LogError("No permission") return false end
    local normalized = NormalizeDisplayName(displayName)
    if normalized == "" then LogError("Invalid name") return false end
    nameColor = (nameColor or "FF0000"):gsub("#", ""):upper()
    msgColorStart = (msgColorStart or "FF0000"):gsub("#", ""):upper()
    msgColorEnd = (msgColorEnd or msgColorStart):gsub("#", ""):upper()
    if not IsValidHexColor(nameColor) then LogError("Invalid name color: %s", nameColor) return false end
    if not IsValidHexColor(msgColorStart) then LogError("Invalid msg start color: %s", msgColorStart) return false end
    if not IsValidHexColor(msgColorEnd) then LogError("Invalid msg end color: %s", msgColorEnd) return false end
    chatDisplayName = chatDisplayName or ""
    if FancyTitles_ChatData[normalized] then LogWarning("Chat player exists, updating") end
    FancyTitles_ChatData[normalized] = {
        displayName = chatDisplayName,
        nameColor = nameColor,
        msgColorStart = msgColorStart,
        msgColorEnd = msgColorEnd,
    }
    if FancyTitles.RefreshChatLookup then FancyTitles.RefreshChatLookup() end
    local preview = CreateMultiGradientText("sample text", { msgColorStart, msgColorEnd })
    LogSuccess("Chat data added for %s | msg: %s", normalized, preview)
    return true
end

function FancyTitles.RemoveChatPlayer(displayName)
    if not IsCurrentPlayerAdmin() then LogError("No permission") return false end
    local normalized = NormalizeDisplayName(displayName)
    if not FancyTitles_ChatData[normalized] then LogError("Chat player not found: %s", normalized) return false end
    FancyTitles_ChatData[normalized] = nil
    LogSuccess("Chat data removed for %s", normalized)
    return true
end

function FancyTitles.SetChatNameColor(displayName, nameColor)
    if not IsCurrentPlayerAdmin() then LogError("No permission") return false end
    local normalized = NormalizeDisplayName(displayName)
    local chatData = FancyTitles_ChatData[normalized]
    if not chatData then LogError("Chat player not found: %s", normalized) return false end
    nameColor = (nameColor or ""):gsub("#", ""):upper()
    if not IsValidHexColor(nameColor) then LogError("Invalid hex color: %s", nameColor) return false end
    chatData.nameColor = nameColor
    LogSuccess("Name color changed for %s: |c%s%s|r", normalized, nameColor, normalized)
    return true
end

function FancyTitles.SetChatMessageColor(displayName, msgColorStart, msgColorEnd)
    if not IsCurrentPlayerAdmin() then LogError("No permission") return false end
    local normalized = NormalizeDisplayName(displayName)
    local chatData = FancyTitles_ChatData[normalized]
    if not chatData then LogError("Chat player not found: %s", normalized) return false end
    msgColorStart = (msgColorStart or ""):gsub("#", ""):upper()
    msgColorEnd = (msgColorEnd or msgColorStart):gsub("#", ""):upper()
    if not IsValidHexColor(msgColorStart) then LogError("Invalid hex color: %s", msgColorStart) return false end
    if not IsValidHexColor(msgColorEnd) then LogError("Invalid hex color: %s", msgColorEnd) return false end
    chatData.msgColorStart = msgColorStart
    chatData.msgColorEnd = msgColorEnd
    if FancyTitles.RefreshChatLookup then FancyTitles.RefreshChatLookup() end
    local preview = CreateMultiGradientText("sample text", { msgColorStart, msgColorEnd })
    LogSuccess("Message color changed for %s: %s", normalized, preview)
    return true
end

function FancyTitles.SetChatDisplayName(displayName, newDisplayName)
    if not IsCurrentPlayerAdmin() then LogError("No permission") return false end
    local normalized = NormalizeDisplayName(displayName)
    local chatData = FancyTitles_ChatData[normalized]
    if not chatData then LogError("Chat player not found: %s", normalized) return false end
    chatData.displayName = newDisplayName or ""
    if newDisplayName and newDisplayName ~= "" then
        LogSuccess("Display name changed for %s: %s", normalized, ColorText(newDisplayName, SafeColor(chatData.nameColor, "FFFFFF")))
    else
        LogSuccess("Display name reset for %s (using default)", normalized)
    end
    return true
end

--[[
    ============================================
    Title Registration
    ============================================
]]--

local function RegisterTitle(displayName)
    if not FancyTitles.db or not FancyTitles.db.enabled then return end
    local normalized = NormalizeDisplayName(displayName)
    local formattedTitle = FancyTitles.GetFormattedTitle(normalized)
    if not formattedTitle or formattedTitle == "" then return end
    local currentPlayer = NormalizeDisplayName(GetDisplayName())
    if normalized == currentPlayer and not FancyTitles.db.showOwnTitle then return end
    if normalized ~= currentPlayer and not FancyTitles.db.showOtherTitles then return end
    registeredTitles[normalized] = formattedTitle
    -- Use integrated custom title system
    FancyTitles.RegisterCustomTitle(normalized, formattedTitle)
end

function FancyTitles.RegisterAllTitles()
    registeredTitles = {}
    -- Clear all custom titles first
    FancyTitles.customTitles = {}
    for displayName in pairs(FancyTitles.GetAllPlayers()) do RegisterTitle(displayName) end
end

--[[
    ============================================
    Commands
    ============================================
]]--

function FancyTitles.ShowAllCommands()
    d("========================================")
    d("  " .. CreateRainbowText("FancyTitles v" .. FancyTitles.version))
    d("========================================")
    d(ColorText("  General Commands:", COLORS.INFO))
    d("    " .. ColorText("/ft help", "00FFAA") .. ColorText(" - Show this help overview", COLORS.GRAY))
    d("    " .. ColorText("/ft list", "00FFAA") .. ColorText(" - List all registered players sorted by rank", COLORS.GRAY))
    d("    " .. ColorText("/ft info @name", "00FFAA") .. ColorText(" - Show detailed info for a player (rank, title, colors)", COLORS.GRAY))
    d("    " .. ColorText("/ft chatinfo @name", "00FFAA") .. ColorText(" - Show chat data for a player (name color, gradient, display name)", COLORS.GRAY))
    d("    " .. ColorText("/ft reload", "00FFAA") .. ColorText(" - Reload all custom titles from the database", COLORS.GRAY))
    d("    " .. ColorText("/ft export", "00FFAA") .. ColorText(" - Export the full title database to chat (copy-paste ready)", COLORS.GRAY))
    if IsCurrentPlayerAdmin() then
        d("  " .. ColorText("------", COLORS.GRAY) .. " " .. ColorText("Admin: Title Management", "FFD700") .. " " .. ColorText("------", COLORS.GRAY))
        d("    " .. ColorText("/ft add", "FF80FF") .. ColorText(" @name rank title", COLORS.WHITE) .. ColorText(" - Register a new player with rank and custom title", COLORS.GRAY))
        d("    " .. ColorText("/ft remove", "FF80FF") .. ColorText(" @name", COLORS.WHITE) .. ColorText(" - Permanently remove a player and their title", COLORS.GRAY))
        d("    " .. ColorText("/ft settitle", "FF80FF") .. ColorText(" @name title", COLORS.WHITE) .. ColorText(" - Update a player's displayed title text", COLORS.GRAY))
        d("    " .. ColorText("/ft setrank", "FF80FF") .. ColorText(" @name rank", COLORS.WHITE) .. ColorText(" - Change a player's rank tier", COLORS.GRAY))
        d("    " .. ColorText("/ft setcolor", "FF80FF") .. ColorText(" @name START END", COLORS.WHITE) .. ColorText(" - Set title gradient (hex codes, e.g. FF0000 00FF00)", COLORS.GRAY))
        d("    " .. ColorText("/ft resetcolor", "FF80FF") .. ColorText(" @name", COLORS.WHITE) .. ColorText(" - Remove custom gradient, revert to rank default color", COLORS.GRAY))
        d("    " .. ColorText("Available Ranks: ", COLORS.INFO) .. ColorText("creator", "FFD700") .. ColorText(" - ", COLORS.GRAY) .. ColorText("exclusive", "E6007E") .. ColorText(" - ", COLORS.GRAY) .. ColorText("enjoyer", "DC143C"))
        d("  " .. ColorText("------", COLORS.GRAY) .. " " .. ColorText("Admin: Chat Data Management", "FF0000") .. " " .. ColorText("------", COLORS.GRAY))
        d("    " .. ColorText("/ft chatadd", "FF80FF") .. ColorText(" @name NAMECOL MSGSTART MSGEND [displayname]", COLORS.WHITE))
        d(ColorText("        Add a player to chat coloring (all colors as 6-digit hex, display name is optional)", COLORS.GRAY))
        d("    " .. ColorText("/ft chatremove", "FF80FF") .. ColorText(" @name", COLORS.WHITE) .. ColorText(" - Remove a player from chat coloring", COLORS.GRAY))
        d("    " .. ColorText("/ft chatname", "FF80FF") .. ColorText(" @name COLOR", COLORS.WHITE) .. ColorText(" - Change how a player's name appears in chat (hex color)", COLORS.GRAY))
        d("    " .. ColorText("/ft chatmsg", "FF80FF") .. ColorText(" @name START [END]", COLORS.WHITE) .. ColorText(" - Set message gradient (omit END for solid color)", COLORS.GRAY))
        d("    " .. ColorText("/ft chatdisplay", "FF80FF") .. ColorText(" @name displayname", COLORS.WHITE) .. ColorText(" - Set an alternative display name shown in chat", COLORS.GRAY))
        d("    " .. ColorText("/ft chatlist", "FF80FF") .. ColorText(" - List all players with chat coloring", COLORS.GRAY))
        d("    " .. ColorText("/ft chatexport", "FF80FF") .. ColorText(" - Export chat data to chat (copy-paste ready)", COLORS.GRAY))
    end
    d("========================================")
end

local function ListPlayers()
    local players = FancyTitles.GetAllPlayers()
    local counts = FancyTitles.GetPlayerCounts()
    d(CreateRainbowText("Player List") .. " (" .. counts.total .. ")")
    for _, rankId in ipairs(FancyTitles.RANK_ORDER) do
        local rankPlayers = {}
        for name, data in pairs(players) do
            if data.rank == rankId then table.insert(rankPlayers, {name = name, data = data}) end
        end
        if #rankPlayers > 0 then
            d(FancyTitles.GetFormattedRank(rankId) .. " (" .. #rankPlayers .. ")")
            table.sort(rankPlayers, function(a, b) return a.name < b.name end)
            for _, player in ipairs(rankPlayers) do d("  " .. player.name .. " - " .. FancyTitles.GetFormattedTitle(player.name)) end
        end
    end
end

local function ShowPlayerInfo(playerName)
    if not playerName then LogWarning("Usage: /ft info @name") return end
    local normalized = NormalizeDisplayName(playerName)
    local playerData = FancyTitles.GetPlayerData(playerName)
    if not playerData then LogError("Not found: %s", normalized) return end
    d("Player: " .. ColorText(normalized, COLORS.WHITE))
    d("  Rank: " .. FancyTitles.GetFormattedRank(playerData.rank))
    d("  Title: " .. FancyTitles.GetFormattedTitle(playerName))
    if playerData.colorStart and playerData.colorStart ~= "" then d("  Custom: " .. playerData.colorStart .. " -> " .. playerData.colorEnd) end
end

local function ShowStatus()
    local counts = FancyTitles.GetPlayerCounts()
    local server = GetWorldName() or "Unknown"
    d(CreateRainbowText("Status:") .. " v" .. FancyTitles.version .. " | Server: " .. ColorText(server, COLORS.INFO) .. " | Admin: " .. (IsCurrentPlayerAdmin() and ColorText("Yes", COLORS.SUCCESS) or ColorText("No", COLORS.ERROR)) .. " | Players: " .. counts.total)
end

local function ExportDatabase()
    d("FancyTitles_Data = {")
    for name, data in pairs(FancyTitles.GetAllPlayers()) do
        local line = string.format('    ["%s"] = { rank = "%s", title = "%s"', name, data.rank or "", data.title or "")
        if data.colorStart and data.colorStart ~= "" then line = line .. string.format(', colorStart = "%s", colorEnd = "%s"', data.colorStart, data.colorEnd or "") end
        d(line .. " },")
    end
    d("}")
end

local function ListChatPlayers()
    local chatPlayers = FancyTitles.GetAllChatPlayers()
    local count = FancyTitles.GetChatPlayerCounts()
    d(CreateRainbowText("Chat Data List") .. " (" .. count .. ")")
    local sorted = {}
    for name, data in pairs(chatPlayers) do
        table.insert(sorted, {name = name, data = data})
    end
    table.sort(sorted, function(a, b) return a.name < b.name end)
    for _, entry in ipairs(sorted) do
        local nc = SafeColor(entry.data.nameColor, "FFFFFF")
        local display = entry.data.displayName ~= "" and (" -> " .. ColorText(entry.data.displayName, nc)) or ""
        local cs = SafeColor(entry.data.msgColorStart or entry.data.messageColor, "FF0000")
        local ce = SafeColor(entry.data.msgColorEnd, cs)
        local preview = CreateMultiGradientText("sample", { cs, ce })
        d("  " .. ColorText(entry.name, nc) .. display .. " | msg: " .. preview)
    end
end

local function ShowChatPlayerInfo(playerName)
    if not playerName then LogWarning("Usage: /ft chatinfo @name") return end
    local normalized = NormalizeDisplayName(playerName)
    local chatData = FancyTitles.GetChatData(normalized)
    if not chatData then LogError("Chat data not found: %s", normalized) return end
    local nc = SafeColor(chatData.nameColor, "FFFFFF")
    local cs = SafeColor(chatData.msgColorStart or chatData.messageColor, "FF0000")
    local ce = SafeColor(chatData.msgColorEnd, cs)
    d("Chat Player: " .. ColorText(normalized, nc))
    d("  Name Color: |c" .. nc .. nc .. "|r")
    d("  Msg Gradient: |c" .. cs .. cs .. "|r -> |c" .. ce .. ce .. "|r")
    d("  Display Name: " .. (chatData.displayName ~= "" and ColorText(chatData.displayName, nc) or ColorText("(default)", COLORS.GRAY)))
    d("  Preview: " .. CreateMultiGradientText("This is a Chat Color Preview", { cs, ce }))
end

local function ExportChatDatabase()
    d("FancyTitles_ChatData = {")
    for name, data in pairs(FancyTitles.GetAllChatPlayers()) do
        local nc = SafeColor(data.nameColor, "FFFFFF")
        local cs = SafeColor(data.msgColorStart or data.messageColor, "FF0000")
        local ce = SafeColor(data.msgColorEnd, cs)
        local line = string.format('    ["%s"] = { displayName = "%s", nameColor = "%s", msgColorStart = "%s", msgColorEnd = "%s" },',
            name, data.displayName or "", nc, cs, ce)
        d(line)
    end
    d("}")
end

local function HandleCommand(input)
    if not input or input == "" then FancyTitles.ShowAllCommands() return end
    local args = {}
    for word in input:gmatch("%S+") do table.insert(args, word) end
    local cmd = args[1]:lower()
    table.remove(args, 1)
    
    if cmd == "help" then FancyTitles.ShowAllCommands()
    elseif cmd == "list" then ListPlayers()
    elseif cmd == "info" then ShowPlayerInfo(args[1])
    elseif cmd == "status" then ShowStatus()
    elseif cmd == "export" then ExportDatabase()
    elseif cmd == "reload" then FancyTitles.RegisterAllTitles() LogSuccess("Reloaded")
    elseif cmd == "add" then
        if #args < 3 then LogWarning("/ft add @name rank title") return end
        local name, rank = args[1], args[2]
        table.remove(args, 1) table.remove(args, 1)
        FancyTitles.AddPlayer(name, rank, table.concat(args, " "))
    elseif cmd == "remove" then if #args < 1 then LogWarning("/ft remove @name") return end FancyTitles.RemovePlayer(args[1])
    elseif cmd == "settitle" then
        if #args < 2 then LogWarning("/ft settitle @name title") return end
        local name = args[1] table.remove(args, 1)
        FancyTitles.SetPlayerTitle(name, table.concat(args, " "))
    elseif cmd == "setrank" then if #args < 2 then LogWarning("/ft setrank @name rank") return end FancyTitles.SetPlayerRank(args[1], args[2])
    elseif cmd == "setcolor" then if #args < 3 then LogWarning("/ft setcolor @name START END") return end FancyTitles.SetPlayerGradient(args[1], args[2], args[3])
    elseif cmd == "resetcolor" then if #args < 1 then LogWarning("/ft resetcolor @name") return end FancyTitles.ResetPlayerGradient(args[1])
    -- Chat Data Commands
    elseif cmd == "chatadd" then
        if #args < 4 then LogWarning("/ft chatadd @name NAMECOLOR MSGSTART MSGEND [displayname]") return end
        local name, nameCol, msStart, msEnd = args[1], args[2], args[3], args[4]
        table.remove(args, 1) table.remove(args, 1) table.remove(args, 1) table.remove(args, 1)
        local chatDisplayName = #args > 0 and table.concat(args, " ") or ""
        FancyTitles.AddChatPlayer(name, nameCol, msStart, msEnd, chatDisplayName)
    elseif cmd == "chatremove" then
        if #args < 1 then LogWarning("/ft chatremove @name") return end
        FancyTitles.RemoveChatPlayer(args[1])
    elseif cmd == "chatname" then
        if #args < 2 then LogWarning("/ft chatname @name COLOR") return end
        FancyTitles.SetChatNameColor(args[1], args[2])
    elseif cmd == "chatmsg" then
        if #args < 2 then LogWarning("/ft chatmsg @name START [END]") return end
        FancyTitles.SetChatMessageColor(args[1], args[2], args[3])
    elseif cmd == "chatdisplay" then
        if #args < 2 then LogWarning("/ft chatdisplay @name displayname") return end
        local name = args[1] table.remove(args, 1)
        FancyTitles.SetChatDisplayName(name, table.concat(args, " "))
    elseif cmd == "chatlist" then ListChatPlayers()
    elseif cmd == "chatinfo" then ShowChatPlayerInfo(args[1])
    elseif cmd == "chatexport" then ExportChatDatabase()
    else LogError("Unknown: %s", cmd) end
end

--[[
    ============================================
    Initialization
    ============================================
]]--

local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= FancyTitles.name then return end
    EVENT_MANAGER:UnregisterForEvent(FancyTitles.name, EVENT_ADD_ON_LOADED)
    
    -- Server-aware SavedVariables using GetWorldName()
    -- This ensures NA, EU, and PTS have separate saved data
    local serverName = GetWorldName() or "Default"
    
    FancyTitles.db = ZO_SavedVars:NewAccountWide("FancyTitlesDB", 1, nil, {
        enabled = true, 
        showOwnTitle = true, 
        showOtherTitles = true,
        showEsoTitle = false,
        chatColorEnabled = true,
        tooltipEnabled = true,
        chatPreviewText = "This is a sample chat message with gradient!",
        chatPreviewStart = "FF0000",
        chatPreviewEnd = "FFAA00",
        wishTitle = "", 
        wishColorStart = "FFFFFF", 
        wishColorEnd = "FFFFFF",
    }, nil, serverName) -- Added server name for server-specific SavedVariables
    
    SLASH_COMMANDS["/fancytitles"] = HandleCommand
    SLASH_COMMANDS["/ft"] = HandleCommand
    
    EVENT_MANAGER:RegisterForEvent(FancyTitles.name .. "_Activate", EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(FancyTitles.name .. "_Activate", EVENT_PLAYER_ACTIVATED)
        FancyTitles.RegisterAllTitles()
        FancyTitles.HookChatSystem()
        FancyTitles.HookTooltips()
        if FancyTitles.InitializeUI then FancyTitles.InitializeUI() end
        local server = GetWorldName() or "Unknown"
        LogSuccess("Loaded on %s - %d players", server, FancyTitles.GetPlayerCounts().total)
        if IsCurrentPlayerAdmin() then LogAdmin("Admin mode active") end
    end)
end

--[[
    ============================================
    Tooltip Integration
    ============================================
    Shows FancyTitles rank, title, and chat color preview
    when hovering over a player in the world (target frame)
    or when hovering over a player link in chat.
    
    ESO tooltip API:
    - ZO_Tooltips_ShowTextTooltip(control, position, text)
    - InformationTooltip:AddLine(text, font, r, g, b)
    - ItemTooltip / PopupTooltip work similarly
    
    Player hover in world: ZO_TargetUnitFramereticle OnMouseEnter
    Player link hover in chat: LINK_HANDLER OnLinkMouseUp
]]--

function FancyTitles.HookTooltips()
    if not FancyTitles.db or not FancyTitles.db.enabled then return end

    -- Build tooltip lines for a given display name
    local function GetTooltipText(displayName)
        if not FancyTitles.db.tooltipEnabled then return nil end
        local normalized = NormalizeDisplayName(displayName)
        local playerData = FancyTitles.GetPlayerData(normalized)
        local chatData = FancyTitles.GetChatData(normalized)
        if not playerData and not chatData then return nil end

        local lines = { "" }  -- empty line as spacer
        table.insert(lines, "|cFFD700- FancyTitles -|r")

        if playerData then
            local rank = FancyTitles.GetFormattedRank(playerData.rank)
            local title = FancyTitles.GetFormattedTitle(normalized)
            table.insert(lines, rank .. "  " .. title)
        end

        if chatData then
            local cs = SafeColor(chatData.msgColorStart or chatData.messageColor, "FF0000")
            local ce = SafeColor(chatData.msgColorEnd, cs)
            table.insert(lines, CreateMultiGradientText("Chat Color Preview", { cs, ce }))
        end

        return lines
    end

    -- Hook 1: Target unit frame (hover over player in world)
    -- ESO's ZO_TargetUnitFramereticle shows a tooltip via InformationTooltip
    local targetFrame = ZO_TargetUnitFramereticle
    if targetFrame then
        local origHandler = targetFrame:GetHandler("OnMouseEnter")
        targetFrame:SetHandler("OnMouseEnter", function(control, ...)
            -- Call original first so ESO builds its tooltip
            if origHandler then origHandler(control, ...) end

            -- Now add our lines
            if not FancyTitles.db or not FancyTitles.db.enabled then return end
            if not DoesUnitExist("reticleover") or not IsUnitPlayer("reticleover") then return end

            local displayName = GetUnitDisplayName("reticleover")
            if not displayName or displayName == "" then return end

            local lines = GetTooltipText(displayName)
            if not lines then return end

            -- InformationTooltip is the standard tooltip used by target frames
            if InformationTooltip then
                for _, line in ipairs(lines) do
                    InformationTooltip:AddLine(line, "", 1, 1, 1)
                end
            end
        end)
    end

    -- Hook 2: Group member unit frames (hover over group member frames)
    -- Group frames are: ZO_GroupUnitFramegroup1, ZO_GroupUnitFramegroup2, etc.
    for i = 1, 24 do
        local groupFrame = GetControl("ZO_GroupUnitFramegroup" .. i)
        if groupFrame then
            local origHandler = groupFrame:GetHandler("OnMouseEnter")
            groupFrame:SetHandler("OnMouseEnter", function(control, ...)
                if origHandler then origHandler(control, ...) end

                if not FancyTitles.db or not FancyTitles.db.enabled then return end

                local unitTag = "group" .. i
                if not DoesUnitExist(unitTag) or not IsUnitPlayer(unitTag) then return end

                local displayName = GetUnitDisplayName(unitTag)
                if not displayName or displayName == "" then return end

                local lines = GetTooltipText(displayName)
                if not lines then return end

                if InformationTooltip then
                    for _, line in ipairs(lines) do
                        InformationTooltip:AddLine(line, "", 1, 1, 1)
                    end
                end
            end)
        end
    end

    -- Hook 3: Chat player link click (right-click menu on player name in chat)
    -- When you click a player link, ESO calls LINK_HANDLER:OnLinkMouseUp
    -- We hook this to show FancyTitles info in chat when a player is clicked
    if LINK_HANDLER then
        SecurePostHook(LINK_HANDLER, "OnLinkMouseUp", function(self, linkData, linkText, button)
            -- Only on left-click show info, right-click opens ESO menu
            if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
            if not linkData or type(linkData) ~= "string" then return end
            if not FancyTitles.db or not FancyTitles.db.enabled then return end

            -- Player link data format: "1:LINK_TYPE:DISPLAY_NAME"
            local linkType, displayName = linkData:match("^1:(%d+):(.*)")
            if not displayName or displayName == "" then return end

            local normalized = NormalizeDisplayName(displayName)
            local playerData = FancyTitles.GetPlayerData(normalized)
            local chatData = FancyTitles.GetChatData(normalized)
            if not playerData and not chatData then return end

            -- Show info as a small chat notification
            local parts = { "|cFFD700[FancyTitles]|r " .. "|cFFFFFF" .. displayName .. "|r" }
            if playerData then
                table.insert(parts, "  " .. FancyTitles.GetFormattedRank(playerData.rank) .. " | " .. FancyTitles.GetFormattedTitle(normalized))
            end
            if chatData then
                local cs = SafeColor(chatData.msgColorStart or chatData.messageColor, "FF0000")
                local ce = SafeColor(chatData.msgColorEnd, cs)
                table.insert(parts, "  Chat: " .. CreateMultiGradientText("Color Preview", { cs, ce }))
            end
            for _, line in ipairs(parts) do
                d(line)
            end
        end)
    end
end

--[[
    ============================================
    Chat Coloring System
    ============================================
    Uses FancyTitles_ChatData for per-player chat message coloring.

    Only the message text (text parameter) is colored.
    The player name, channel tags, timestamps etc. remain
    100% original ESO formatting. The text parameter is the
    only place where |c color codes are not escaped by ESO.
]]--

function FancyTitles.HookChatSystem()
    if not CHAT_ROUTER then
        LogWarning("Chat coloring: CHAT_ROUTER not available")
        return
    end

    -- Build fast lookup
    local chatLookup = {}
    for name, data in pairs(FancyTitles.GetAllChatPlayers()) do
        chatLookup[name] = data
    end

    function FancyTitles.RefreshChatLookup()
        chatLookup = {}
        for name, data in pairs(FancyTitles.GetAllChatPlayers()) do
            chatLookup[name] = data
        end
    end

    local originalFormatAndAdd = CHAT_ROUTER.FormatAndAddChatMessage

    CHAT_ROUTER.FormatAndAddChatMessage = function(self, eventCode, channelType, fromName, text, isCustomerService, fromDisplayName, ...)
        -- Safety: text must be a string (ESO passes boolean for system events like leaving group)
        if type(text) ~= "string" then
            return originalFormatAndAdd(self, eventCode, channelType, fromName, text, isCustomerService, fromDisplayName, ...)
        end

        if FancyTitles.db and FancyTitles.db.enabled and FancyTitles.db.chatColorEnabled
           and fromDisplayName and fromDisplayName ~= "" then

            -- For whisper sent: fromDisplayName is the RECIPIENT, not us
            -- Use our own chatData so our outgoing whispers show our color
            local lookupName = fromDisplayName
            if channelType == CHAT_CHANNEL_WHISPER_SENT then
                lookupName = GetDisplayName() or ""
            end

            local normalized = NormalizeDisplayName(lookupName)
            local chatData = chatLookup[normalized]

            if chatData then
                local cs = SafeColor(chatData.msgColorStart or chatData.messageColor, "FF0000")
                local ce = SafeColor(chatData.msgColorEnd, cs)
                -- Use ColorizePreservingLinks to keep item/achievement links intact
                text = ColorizePreservingLinks(text, { cs, ce })
            end
        end

        return originalFormatAndAdd(self, eventCode, channelType, fromName, text, isCustomerService, fromDisplayName, ...)
    end
end

EVENT_MANAGER:RegisterForEvent(FancyTitles.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

-- Export public functions and constants
FancyTitles.COLORS = COLORS
FancyTitles.ColorText = ColorText
FancyTitles.CreateMultiGradientText = CreateMultiGradientText
FancyTitles.CreateRainbowText = CreateRainbowText
FancyTitles.ColorizePreservingLinks = ColorizePreservingLinks
FancyTitles.IsCurrentPlayerAdmin = IsCurrentPlayerAdmin
FancyTitles.NormalizeDisplayName = NormalizeDisplayName
FancyTitles.IsValidHexColor = IsValidHexColor
FancyTitles.GetAllChatPlayers = FancyTitles.GetAllChatPlayers
FancyTitles.GetChatData = FancyTitles.GetChatData
FancyTitles.GetChatPlayerCounts = FancyTitles.GetChatPlayerCounts
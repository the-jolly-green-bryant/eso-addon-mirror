-- Battleboard_Features.lua  (Small reusable UI/gameplay feature helpers)
-- Part of Battleboard. Cross-file constants and helpers are read from Battleboard.__constants.

local BL = Battleboard
local _x = BL.__constants

local MAX_LOCKED_MATCHES = _x.MAX_LOCKED_MATCHES

function BL.IsLocked(matchId)
    local match = BL.GetMatch(matchId)
    return match and match.isLocked == true
end

function BL.ToggleLocked(matchId)
    local match = BL.GetMatch(matchId)
    if not match then return end
    if not match.isLocked then
        local count = 0
        for _, m in ipairs(BL.matches or {}) do
            if m and m.isLocked then count = count + 1 end
        end
        if count >= MAX_LOCKED_MATCHES then
            ZO_Dialogs_ShowDialog("BATTLEBOARD_LOCKED_LIMIT")
            return
        end
        match.isLocked = true
    else
        match.isLocked = false
    end
    BL.UpdateHistorySelectionVisuals()
    BL.RefreshHistory(true)
end

local function NormalizeWhisperTarget(displayName)
    local target = zo_strformat(SI_PLAYER_NAME, displayName or "")
    target = tostring(target or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if target == "" then return nil end
    if target:sub(1, 1) ~= "@" then
        target = "@" .. target
    end
    return target
end

function BL.StartWhisperToDisplayName(displayName)
    local target = NormalizeWhisperTarget(displayName)
    if not target then return end

    local text = "/w " .. target .. " "
    if type(StartChatInput) == "function" then
        StartChatInput(text)
    elseif CHAT_SYSTEM and type(CHAT_SYSTEM.StartTextEntry) == "function" then
        CHAT_SYSTEM:StartTextEntry(text)
    else
        d("|cFFD700Battleboard|r whisper target: " .. text)
    end
end

function BL.ShowPlayerContextMenu(control, player)
    local target = NormalizeWhisperTarget(player and player.displayName)
    if not target then return end

    ClearMenu()
    AddCustomMenuItem("Whisper", function()
        BL.StartWhisperToDisplayName(target)
    end)
    ShowMenu(control)
end

-----------------------------------------------------------
-- Share Stepper
-- First-class journal view for multi-part browser sharing. The journal scene
-- survives RequestOpenUnsafeURL round-trips (dialogs do not), so each part is
-- fired by a real keybind press: send part, confirm the browser prompt,
-- return to the game with this screen still open, press again.
--
-- Stateless renderer over BattleScrolls.shareUrl.getState(); the shareUrl
-- observer wired in journal.lua re-renders on every transition.
-----------------------------------------------------------

if not SemisPlaygroundCheckAccess() then
    return
end

BattleScrolls = BattleScrolls or {}
BattleScrolls.journal = BattleScrolls.journal or {}

local shareStepper = {}
BattleScrolls.journal.shareStepper = shareStepper

local ICON_SENT = "EsoUI/Art/Miscellaneous/Gamepad/gp_checkmark.dds"
local ICON_NEXT = "EsoUI/Art/Miscellaneous/Gamepad/gp_rightArrow.dds"
local MAX_DIAG_ROWS = 8

---Appends the newest share-trace entries (newest first). The Xbox
---browser-exit leak can only be diagnosed on the console, where this
---screen is the only readable output.
---@param list ZO_ParametricScrollList
local function appendDiagnostics(list)
    local entryBuilder = BattleScrolls.journal.EntryBuilder
    local entries = BattleScrolls.shareTrace.list()
    local nowMs = GetGameTimeMilliseconds()
    local shown = 0
    for i = #entries, 1, -1 do
        if shown >= MAX_DIAG_ROWS then
            break
        end
        local e = entries[i]
        entryBuilder.addEntry(list, {
            label = string.format("-%.1fs  %s", (nowMs - e.gameMs) / 1000, e.text),
            header = shown == 0 and GetString(BATTLESCROLLS_SHARE_DIAG_HEADER) or nil,
        })
        shown = shown + 1
    end
end

---Renders the stepper into the share list.
---@param list ZO_ParametricScrollList
function shareStepper.render(list)
    local entryBuilder = BattleScrolls.journal.EntryBuilder
    local state = BattleScrolls.shareUrl.getState()
    list:Clear()

    if state.phase == "building" then
        entryBuilder.addEntry(list, {
            label = GetString(BATTLESCROLLS_SHARE_PREPARING),
            header = GetString(BATTLESCROLLS_SHARE_TITLE),
        })
    elseif state.phase == "failed" then
        entryBuilder.addEntry(list, {
            label = GetString(BATTLESCROLLS_SHARE_FAILED),
            header = GetString(BATTLESCROLLS_SHARE_TITLE),
        })
    elseif state.phase == "sending" or state.phase == "done" then
        for seq = 1, state.total do
            local label
            local icon
            if state.resendingSeq == seq then
                label = zo_strformat(GetString(BATTLESCROLLS_SHARE_PART_RESENDING), seq)
                icon = ICON_NEXT
            elseif seq <= state.sentCount then
                label = zo_strformat(GetString(BATTLESCROLLS_SHARE_PART_SENT), seq)
                icon = ICON_SENT
            elseif state.phase == "sending" and seq == state.sentCount + 1 then
                label = zo_strformat(GetString(BATTLESCROLLS_SHARE_PART_READY), seq)
                icon = ICON_NEXT
            else
                label = zo_strformat(GetString(BATTLESCROLLS_SHARE_PART_PENDING), seq)
            end
            local entry = entryBuilder.addEntry(list, {
                label = label,
                icon = icon,
                header = seq == 1 and GetString(BATTLESCROLLS_SHARE_PROGRESS_HEADER) or nil,
            })
            -- Selecting a sent part offers a resend (crashed browser tabs
            -- lose their chunk; the upload page names the missing parts)
            entry.partSeq = seq
        end
        if state.phase == "done" then
            entryBuilder.addEntry(list, {
                label = GetString(BATTLESCROLLS_SHARE_DONE_HINT),
                header = GetString(BATTLESCROLLS_SHARE_DONE_HEADER),
            })
            entryBuilder.addEntry(list, {
                label = GetString(BATTLESCROLLS_SHARE_DONE_RESEND_HINT),
            })
        else
            entryBuilder.addEntry(list, {
                label = GetString(BATTLESCROLLS_SHARE_HINT),
                header = GetString(BATTLESCROLLS_SHARE_HINT_HEADER),
            })
            entryBuilder.addEntry(list, {
                label = GetString(BATTLESCROLLS_SHARE_HINT_LEAVE),
            })
        end
    end

    appendDiagnostics(list)
    list:Commit()
end

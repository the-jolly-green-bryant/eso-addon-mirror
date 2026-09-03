local HV = HousingVote

-- Plain top-level window, shown/hidden directly -- no SCENE_MANAGER, no
-- ZO_Gamepad_ParametricList_Screen. That framework went through four
-- rounds of confirmed, source-verified bugs and still never rendered
-- anything visible once all of them were fixed. This construction is
-- copied from a second, unrelated addon (PullCard) confirmed working on
-- the actual target device.
--
-- FIX ATTEMPT #1 (kept, but confirmed NOT sufficient on its own):
-- SetKeyboardEnabled(true)/(false) on open/close, so the OnKeyDown handler
-- below can receive events -- real per ESOUI docs, but tested in-game and
-- still no focus. Most likely explanation: SetKeyboardEnabled governs
-- literal keyboard input, which doesn't help when testing purely with a
-- controller and no paired keyboard.
--
-- FIX ATTEMPT #2 (the real one for controller input): KEYBIND_STRIP.
-- Confirmed directly from esoui/libraries/zo_keybindstrip/zo_keybindstrip.lua
-- that AddKeybindButtonGroup/RemoveKeybindButtonGroup work standalone (no
-- scene required in the no-stateIndex call path we use) and that
-- UI_SHORTCUT_LEFT_TRIGGER / UI_SHORTCUT_RIGHT_TRIGGER / UI_SHORTCUT_PRIMARY
-- / UI_SHORTCUT_NEGATIVE are real action-name constants (verified against
-- the library's own enum table, not guessed). This is the same mechanism
-- that reliably drives every controller button prompt in the base game --
-- unlike a bare top-level window, KEYBIND_STRIP is specifically the
-- system responsible for dispatching real gamepad button presses to a
-- callback, independent of the scene/fragment machinery that never
-- rendered for us. Registered alongside the OnKeyDown path, not instead
-- of it -- both call the same OnBrowse/OnAction/OnBack functions, so
-- whichever one actually fires on your hardware, it works.
--
-- Font sizes below are copied from PullCard's already-tuned values, not
-- guessed fresh.

local menu = {
    mode = "contests", -- "contests" | "roster"
    index = 1,
    contests = {},
    rosterContestId = nil,
    roster = {},
}

-- Mirrors whatever the action button currently shows, so the keybind
-- strip's on-screen prompt (built below) stays in sync with it.
local currentActionLabel = "Action"
local currentActionVisible = true

-- ============================================================
-- font helpers (copied from PullCard's proven-working values)
-- ============================================================

local function SetReadableFont(control, size, isBold)
    if not control then return end
    local base = isBold and "$(BOLD_FONT)" or "$(MEDIUM_FONT)"
    control:SetFont(string.format("%s|%d|soft-shadow-thick", base, size))
end

local function NormalizeButtonFontSize(size)
    local requested = tonumber(size) or 20
    if requested < 22 then
        return 22
    end
    return requested
end

local function EnsureLargeButtonLabel(button, text, size, isBold)
    if not button then return end
    size = NormalizeButtonFontSize(size)
    if not button.hvLabel then
        local label = WINDOW_MANAGER:CreateControl(nil, button, CT_LABEL)
        button.hvLabel = label
        label:SetAnchor(TOPLEFT, button, TOPLEFT, 6, 2)
        label:SetAnchor(BOTTOMRIGHT, button, BOTTOMRIGHT, -6, -2)
        label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetMouseEnabled(false)
    end

    SetReadableFont(button.hvLabel, size, isBold)
    button.hvLabel:SetColor(1, 1, 1, 1)
    button.hvLabel:SetText(text or "")
    button:SetText("")
end

local function SetButtonLabelText(button, text)
    if not button then return end
    if button.hvLabel then
        button.hvLabel:SetText(text)
    else
        button:SetText(text)
    end
end

-- ============================================================
-- key handling
-- ============================================================

local function IsDismissKey(key)
    return key == KEY_ESCAPE
        or key == KEY_GAMEPAD_BUTTON_1
        or key == KEY_GAMEPAD_BACK
        or key == KEY_GAMEPAD_START
end

local function IsPrevKey(key)
    return key == KEY_LEFT
        or key == KEY_A
        or key == KEY_GAMEPAD_DPAD_LEFT
        or key == KEY_GAMEPAD_LEFT_SHOULDER
end

local function IsNextKey(key)
    return key == KEY_RIGHT
        or key == KEY_D
        or key == KEY_GAMEPAD_DPAD_RIGHT
        or key == KEY_GAMEPAD_RIGHT_SHOULDER
end

local function IsActivateKey(key)
    return key == KEY_ENTER
        or key == KEY_SPACE
        or key == KEY_GAMEPAD_BUTTON_2
        or key == KEY_GAMEPAD_BUTTON_3
end

-- ============================================================
-- display / navigation
-- ============================================================

local function ClampIndex(count)
    if count == 0 then
        menu.index = 1
    elseif menu.index < 1 then
        menu.index = count
    elseif menu.index > count then
        menu.index = 1
    end
end

local function SetActionButton(win, label)
    if label then
        win.actionButton:SetHidden(false)
        SetButtonLabelText(win.actionButton, label)
        currentActionLabel = label
        currentActionVisible = true
    else
        win.actionButton:SetHidden(true)
        currentActionVisible = false
    end
end

local function RefreshDisplay()
    local win = HV.gamepadWindow
    if not win then return end

    if menu.mode == "contests" then
        menu.contests = HV.GetKnownContests()
        ClampIndex(#menu.contests)
        local entry = menu.contests[menu.index]

        if not entry then
            win.title:SetText("Housing Vote")
            win.body:SetText("No known contests yet.\n\nHost one with /hv create, or wait for a guild MOTD pointer to be noticed.")
            SetActionButton(win, nil)
        else
            win.title:SetText(string.format("[%d/%d] %s", menu.index, #menu.contests, entry.title))
            win.body:SetText(string.format("Hosted by %s\nRole: %s\nState: %s", entry.hostDisplayName or "?", entry.role, entry.state))

            if entry.role == "discovered" then
                SetActionButton(win, "Join")
            elseif entry.role == "joined" and entry.state == HV.CONTEST_STATE.INTEREST then
                SetActionButton(win, "Submit Interest")
            elseif entry.role == "joined" and entry.state == HV.CONTEST_STATE.VOTING then
                SetActionButton(win, "Vote")
            elseif entry.role == "hosting" then
                SetActionButton(win, "Status")
            else
                SetActionButton(win, nil)
            end
        end
        SetButtonLabelText(win.backButton, "Close")
    else -- "roster"
        ClampIndex(#menu.roster)
        local rEntry = menu.roster[menu.index]

        win.title:SetText(string.format("Vote [%d/%d]", menu.index, #menu.roster))
        if rEntry then
            win.body:SetText(string.format("%s\n(%s)", rEntry.houseName, rEntry.displayName))
            SetActionButton(win, "Vote for this house")
        else
            win.body:SetText("No roster entries.")
            SetActionButton(win, nil)
        end
        SetButtonLabelText(win.backButton, "< Back")
    end

    if KEYBIND_STRIP and HV.gamepadKeybindDescriptor then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(HV.gamepadKeybindDescriptor)
    end
end

local function EnterRosterMode(contestId)
    local joined = HV.sv.joinedContests[contestId]
    if not joined or not joined.roster or #joined.roster == 0 then
        HV.Print("|cFF0000No roster available yet for that contest.|r")
        return
    end
    menu.mode = "roster"
    menu.rosterContestId = contestId
    menu.roster = joined.roster
    menu.index = 1
    RefreshDisplay()
end

local function BackToContests()
    menu.mode = "contests"
    menu.index = 1
    RefreshDisplay()
end

local function OnBrowse(delta)
    menu.index = menu.index + delta
    RefreshDisplay()
end

local function OnAction()
    if menu.mode == "contests" then
        local entry = menu.contests[menu.index]
        if not entry then return end

        if entry.role == "discovered" then
            HV.JoinContest(entry.contestId, entry.hostDisplayName)
            RefreshDisplay()
        elseif entry.role == "joined" and entry.state == HV.CONTEST_STATE.INTEREST then
            HV.SubmitInterest(entry.contestId)
        elseif entry.role == "joined" and entry.state == HV.CONTEST_STATE.VOTING then
            EnterRosterMode(entry.contestId)
        elseif entry.role == "hosting" then
            local contest = HV.sv.hostedContests[entry.contestId]
            if contest then
                HV.Print(string.format("|c00CCFF'%s' [%s] -- %d interested, %d votes. Use /hv open or /hv close to advance it.|r",
                    contest.title, contest.state, HV.CountKeys(contest.interests), HV.CountKeys(contest.votes)))
            end
        end
    else
        local rEntry = menu.roster[menu.index]
        if not rEntry then return end
        HV.SubmitVote(menu.rosterContestId, rEntry.displayName)
        BackToContests()
    end
end

local function OnBack()
    if menu.mode == "roster" then
        BackToContests()
    else
        HV.CloseGamepadWindow()
    end
end

local function BuildKeybindDescriptor()
    return {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            keybind = "UI_SHORTCUT_LEFT_TRIGGER",
            name = "Prev",
            callback = function() OnBrowse(-1) end,
        },
        {
            keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
            name = "Next",
            callback = function() OnBrowse(1) end,
        },
        {
            keybind = "UI_SHORTCUT_PRIMARY",
            name = function() return currentActionLabel end,
            visible = function() return currentActionVisible end,
            callback = function() OnAction() end,
        },
        {
            keybind = "UI_SHORTCUT_NEGATIVE",
            name = "Close",
            callback = function() OnBack() end,
        },
    }
end

local function AddKeybinds()
    if not KEYBIND_STRIP then return end
    if not HV.gamepadKeybindDescriptor then
        HV.gamepadKeybindDescriptor = BuildKeybindDescriptor()
    end
    KEYBIND_STRIP:AddKeybindButtonGroup(HV.gamepadKeybindDescriptor)
end

local function RemoveKeybinds()
    if not KEYBIND_STRIP or not HV.gamepadKeybindDescriptor then return end
    KEYBIND_STRIP:RemoveKeybindButtonGroup(HV.gamepadKeybindDescriptor)
end

function HV.OpenGamepadWindow()
    if not HV.gamepadWindow then return end
    menu.mode = "contests"
    menu.index = 1
    HV.gamepadWindow:SetHidden(false)
    HV.gamepadWindow:SetKeyboardEnabled(true)
    AddKeybinds()
    RefreshDisplay()
end

function HV.CloseGamepadWindow()
    if not HV.gamepadWindow then return end
    RemoveKeybinds()
    HV.gamepadWindow:SetKeyboardEnabled(false)
    HV.gamepadWindow:SetHidden(true)
end

function HV.ToggleGamepadWindow()
    if not HV.gamepadWindow then return end
    if HV.gamepadWindow:IsHidden() then
        HV.OpenGamepadWindow()
    else
        HV.CloseGamepadWindow()
    end
end

-- Jumps straight into the roster/voting view for a specific contest (used
-- by /hv voteui). Uses whatever roster this character already has locally
-- stored -- see Contest.lua VoterHandleInfo -- doesn't fetch anything.
function HV.ShowVoteScreenFor(contestId)
    if not HV.gamepadWindow then return end
    HV.gamepadWindow:SetHidden(false)
    HV.gamepadWindow:SetKeyboardEnabled(true)
    AddKeybinds()
    EnterRosterMode(contestId)
end

local function CreateWindow()
    local wm = WINDOW_MANAGER

    local top = wm:CreateTopLevelWindow("HousingVoteWindow")
    HV.gamepadWindow = top
    top:SetDimensions(620, 380)
    top:SetAnchor(CENTER, GuiRoot, CENTER, 0, 60)
    top:SetMovable(true)
    top:SetMouseEnabled(true)
    top:SetClampedToScreen(true)
    top:SetHidden(true)

    -- FIX ATTEMPT #3 (reverted): registering a fragment on HUD_SCENE gave
    -- no interactivity benefit (confirmed by testing) and caused a real
    -- regression -- the window started appearing automatically on login,
    -- since ZO_SimpleSceneFragment took over visibility from our own
    -- SetHidden calls. This window is now superseded by ConsoleMenu.lua
    -- (native LCM rows) as the primary interactive surface; kept here only
    -- for /hv voteui / /hv menu as a secondary, non-primary path.

    top:SetHandler("OnKeyDown", function(_, key)
        if IsDismissKey(key) then
            OnBack()
            return true
        end
        if IsPrevKey(key) then
            OnBrowse(-1)
            return true
        end
        if IsNextKey(key) then
            OnBrowse(1)
            return true
        end
        if IsActivateKey(key) then
            OnAction()
            return true
        end
    end)

    local bg = wm:CreateControl(nil, top, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.05, 0.05, 0.05, 0.94)
    bg:SetEdgeColor(0.5, 0.5, 0.5, 0.9)
    bg:SetEdgeTexture("", 1, 1, 1)

    local title = wm:CreateControl(nil, top, CT_LABEL)
    top.title = title
    SetReadableFont(title, 34, true)
    title:SetAnchor(TOPLEFT, top, TOPLEFT, 18, 16)
    title:SetAnchor(TOPRIGHT, top, TOPRIGHT, -18, 16)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetText("Housing Vote")

    local body = wm:CreateControl(nil, top, CT_LABEL)
    top.body = body
    SetReadableFont(body, 22, false)
    body:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 20)
    body:SetAnchor(TOPRIGHT, title, BOTTOMRIGHT, 0, 20)
    body:SetHeight(190)
    body:SetVerticalAlignment(TEXT_ALIGN_TOP)

    local controlsHint = wm:CreateControl(nil, top, CT_LABEL)
    SetReadableFont(controlsHint, 18, false)
    controlsHint:SetAnchor(BOTTOMLEFT, top, BOTTOMLEFT, 18, -60)
    controlsHint:SetAnchor(BOTTOMRIGHT, top, BOTTOMRIGHT, -18, -60)
    controlsHint:SetHeight(26)
    controlsHint:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    controlsHint:SetColor(0.84, 0.84, 0.84, 1)
    controlsHint:SetText("Left/Right: browse   Confirm: action   Back: close")

    local prev = wm:CreateControlFromVirtual("HousingVotePrevButton", top, "ZO_DefaultButton")
    prev:SetDimensions(100, 40)
    prev:SetAnchor(BOTTOMLEFT, top, BOTTOMLEFT, 18, -16)
    EnsureLargeButtonLabel(prev, "< Prev", 20, true)
    prev:SetHandler("OnClicked", function() OnBrowse(-1) end)

    local nextBtn = wm:CreateControlFromVirtual("HousingVoteNextButton", top, "ZO_DefaultButton")
    nextBtn:SetDimensions(100, 40)
    nextBtn:SetAnchor(LEFT, prev, RIGHT, 10, 0)
    EnsureLargeButtonLabel(nextBtn, "Next >", 20, true)
    nextBtn:SetHandler("OnClicked", function() OnBrowse(1) end)

    local action = wm:CreateControlFromVirtual("HousingVoteActionButton", top, "ZO_DefaultButton")
    top.actionButton = action
    action:SetDimensions(180, 40)
    action:SetAnchor(LEFT, nextBtn, RIGHT, 10, 0)
    EnsureLargeButtonLabel(action, "Action", 20, true)
    action:SetHandler("OnClicked", function() OnAction() end)

    local backBtn = wm:CreateControlFromVirtual("HousingVoteBackButton", top, "ZO_DefaultButton")
    top.backButton = backBtn
    backBtn:SetDimensions(100, 40)
    backBtn:SetAnchor(LEFT, action, RIGHT, 10, 0)
    EnsureLargeButtonLabel(backBtn, "Close", 20, true)
    backBtn:SetHandler("OnClicked", function() OnBack() end)
end

function HV.InitGamepadWindow()
    CreateWindow()
end

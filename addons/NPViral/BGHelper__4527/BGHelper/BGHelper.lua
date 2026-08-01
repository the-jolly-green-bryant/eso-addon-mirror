-- ============================================================
--  BGHelper  v2.8  |  @NPViral
--  Battleground queue helper — filters, auto-release,
--  ready-check auto-accept, and live KDA HUD.
-- ============================================================
BGHelper = BGHelper or {}
local BGH = BGHelper

BGH.name    = "BGHelper"
BGH.version = "2.8"
BGH.vars    = nil

BGH.queueLocations    = {}
BGH.settingsPanel     = nil
BGH.playerDeadHandler = nil
BGH.queueStateHandler = nil
BGH.zoneGuard         = nil
BGH.hudFadeHandle     = nil
BGH.hudFadeNonce      = 0

-- HUD control references
BGH.hud = {
    window   = nil,
    bg       = nil,
    border   = nil,
    fragment = nil,
    valK     = nil,
    valD     = nil,
    valA     = nil,
    valDmg   = nil,
    valHeal  = nil,
    valRank  = nil,
}

-- ============================================================
--  Colours
-- ============================================================
local C = {
    gold   = { r=0.898, g=0.800, b=0.502 },
    green  = { r=0.200, g=0.925, b=0.200 },
    red    = { r=1.000, g=0.300, b=0.300 },
    yellow = { r=1.000, g=0.875, b=0.200 },
    orange = { r=1.000, g=0.580, b=0.180 },
    teal   = { r=0.200, g=0.900, b=0.700 },
    dim    = { r=0.550, g=0.550, b=0.550 },
}

-- ============================================================
--  HUD layout — fixed column positions
-- ============================================================
local ROW_H = 26
local DIV_H = 3
local HUD_W = 210
local HUD_H = (ROW_H * 3) + (DIV_H * 2)
local PAD   = 8

local COL = {
    capK = PAD,  valK = 26,
    capD = 82,   valD = 98,
    capA = 148,  valA = 164,
    capDmg  = PAD, valDmg  = 46,
    capHeal = 118, valHeal = 162,
    capRank = PAD, valRank = 52,
}

local DEF_X       = -10
local DEF_Y       = 80
local DIVIDER_TEX = "/esoui/art/miscellaneous/horizontaldivider.dds"
local FADE_STEPS  = 8
local FADE_MS     = 30

-- ============================================================
--  Defaults
-- ============================================================
local defaults = {
    autoRelease      = true,
    releaseDelayMs   = 2000,
    autoAcceptReady  = true,
    readyDelayMs     = 0,
    queue4v4         = true,
    queue8v8         = true,
    allowSoloQueues  = true,
    allowGroupQueues = true,
    showHud          = true,
    hudLocked        = true,
    hudOpacity       = 1.0,
    hudShowAnywhere  = false,
    showChatAlerts   = true,
    lastVersion      = "",
}

-- ============================================================
--  Chat helpers
-- ============================================================
local TAG = "|c5BB8FF[BGHelper]|r "

local function Print(msg)
    if BGH.vars and BGH.vars.showChatAlerts == false then return end
    CHAT_SYSTEM:AddMessage(TAG .. tostring(msg))
end

local function PrintAlways(msg)
    CHAT_SYSTEM:AddMessage(TAG .. tostring(msg))
end

local function BoolWord(v)
    return v and "|c33DD33ON|r" or "|cFF5555OFF|r"
end

local function Hi(text)
    return "|cFFFFFF" .. tostring(text) .. "|r"
end

local function Dim(text)
    return "|c888888" .. tostring(text) .. "|r"
end

-- ============================================================
--  Stat formatting
-- ============================================================
local function FormatStat(n)
    n = n or 0
    if     n >= 1000000 then return string.format("%.1fm", n / 1000000)
    elseif n >= 1000    then return string.format("%dk",   math.floor(n / 1000))
    else                     return tostring(n)
    end
end

-- ============================================================
--  Deep copy — SavedVars migration
-- ============================================================
local function DeepCopy(orig)
    local copy = {}
    for k, v in pairs(orig) do
        copy[k] = (type(v) == "table") and DeepCopy(v) or v
    end
    return copy
end

-- ============================================================
--  SavedVars migration from BGUnified
-- ============================================================
function BGH:MigrateOldSavedVars()
    if BGUnifiedSavedVars and not BGHelperSavedVars then
        BGHelperSavedVars = DeepCopy(BGUnifiedSavedVars)
    end
end

-- ============================================================
--  Version notice — shown only when version changes
-- ============================================================
function BGH:CheckVersionNotice()
    if self.vars.lastVersion ~= self.version then
        self.vars.lastVersion = self.version
        PrintAlways("Updated to " .. Hi("v" .. self.version) .. "  —  /bgh for help.")
    end
end

-- ============================================================
--  Queue filter helpers
-- ============================================================
local function NormalizeQueueName(location)
    local raw = ""
    if location and location.rawName then
        raw = tostring(location.rawName)
    elseif location and location.GetName then
        local ok, val = pcall(function() return location:GetName() end)
        if ok and val then raw = tostring(val) end
    end
    return zo_strlower(raw)
end

local function GetLocalScoreboardIndex()
    if type(GetScoreboardLocalPlayerEntryIndex) == "function" then
        local idx = GetScoreboardLocalPlayerEntryIndex()
        if idx and idx > 0 then return idx end
    end
    if type(GetScoreboardPlayerEntryIndex) == "function" then
        local idx = GetScoreboardPlayerEntryIndex()
        if idx and idx > 0 then return idx end
    end
    return nil
end

local function IsLikely4v4Queue(name)
    return name:find("4v4", 1, true)
        or name:find("4vs4", 1, true)
        or name:find("4 x 4", 1, true)
        or name:find("4v4v4", 1, true)
        or name:find("4vs4vs4", 1, true)
end

local function IsLikely8v8Queue(name)
    return name:find("8v8", 1, true)
        or name:find("8vs8", 1, true)
        or name:find("8 x 8", 1, true)
end

local function IsSoloQueue(location, name)
    if type(location) == "table" and type(location.maxGroupSize) == "number" then
        if location.maxGroupSize <= 1 then return true end
        if location.maxGroupSize > 1 then return false end
    end
    return name:find("solo", 1, true) ~= nil
end

local function IsGroupQueue(location, name)
    if type(location) == "table" and type(location.maxGroupSize) == "number" then
        if location.maxGroupSize > 1 then return true end
        if location.maxGroupSize <= 1 then return false end
    end
    return name:find("group", 1, true) ~= nil
end

local function QueueMatchesSettings(location)
    if not BGH.vars then return false end
    local name = NormalizeQueueName(location)

    local sizeAllowed
    if IsLikely4v4Queue(name) then
        sizeAllowed = BGH.vars.queue4v4
    elseif IsLikely8v8Queue(name) then
        sizeAllowed = BGH.vars.queue8v8
    else
        sizeAllowed = BGH.vars.queue4v4 or BGH.vars.queue8v8
    end

    local typeAllowed
    if IsSoloQueue(location, name) then
        typeAllowed = BGH.vars.allowSoloQueues
    elseif IsGroupQueue(location, name) then
        typeAllowed = BGH.vars.allowGroupQueues
    else
        typeAllowed = BGH.vars.allowSoloQueues or BGH.vars.allowGroupQueues
    end

    return sizeAllowed and typeAllowed
end

function BGH:ValidateFilters()
    if not self.vars.queue4v4 and not self.vars.queue8v8 then
        Print("|cFF5555Enable at least one queue size (4v4 or 8v8).|r")
        return false
    end
    if not self.vars.allowSoloQueues and not self.vars.allowGroupQueues then
        Print("|cFF5555Enable solo or group queues.|r")
        return false
    end
    return true
end

-- ============================================================
--  Queue location builder
-- ============================================================
function BGH:RebuildQueueLocations()
    self.queueLocations = {}
    if not ZO_ActivityFinderFilterModeData or not ZO_ACTIVITY_FINDER_ROOT_MANAGER then
        Print("|cFF5555Activity Finder API unavailable.|r")
        return
    end

    local fmd = ZO_ActivityFinderFilterModeData:New(
        LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL,
        LFG_ACTIVITY_BATTLE_GROUND_CHAMPION,
        LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION)
    fmd:SetSubmenuFilterNames(
        GetString(SI_BATTLEGROUND_FINDER_SPECIFIC_FILTER_TEXT),
        GetString(SI_BATTLEGROUND_FINDER_RANDOM_FILTER_TEXT))
    fmd:SetVisibleEntryTypes(ZO_ACTIVITY_FINDER_LOCATION_ENTRY_TYPE.SET)

    for _, activityType in ipairs(fmd:GetActivityTypes()) do
        if ZO_ACTIVITY_FINDER_ROOT_MANAGER:GetNumLocationsByActivity(
                activityType, fmd:GetVisibleEntryTypes()) > 0 then
            local isLocked = ZO_ActivityFinderTemplate_Shared:GetLevelLockInfoByActivity(activityType)
            if not isLocked then
                local locs = ZO_ACTIVITY_FINDER_ROOT_MANAGER:GetLocationsData(activityType)
                for _, location in ipairs(locs) do
                    if fmd:IsEntryTypeVisible(location:GetEntryType())
                    and location:IsActive() then
                        self.queueLocations[#self.queueLocations + 1] = location
                    end
                end
            end
        end
    end
end

-- ============================================================
--  Queue
-- ============================================================
function BGH:QueueSelectedBattlegrounds()
    if not self.vars then return false end

    if IsCurrentlySearchingForGroup() then
        Print("Already in queue.")
        return false
    end

    if not self:ValidateFilters() then return false end

    if not ZO_ACTIVITY_FINDER_ROOT_MANAGER then
        Print("|cFF5555Activity Finder not available.|r")
        return false
    end

    self:RebuildQueueLocations()

    if #self.queueLocations == 0 then
        Print("|cFF5555No Battlegrounds available here.|r")
        return false
    end

    if type(ZO_ACTIVITY_FINDER_ROOT_MANAGER.ClearSelections) == "function" then
        ZO_ACTIVITY_FINDER_ROOT_MANAGER:ClearSelections()
    end

    local count = 0
    local groupSize = GetGroupSize()
    for _, location in ipairs(self.queueLocations) do
        local canUse = groupSize <= (location.maxGroupSize or groupSize)
        local shouldSelect = canUse and QueueMatchesSettings(location)
        location:SetSelected(shouldSelect)
        if shouldSelect then count = count + 1 end
    end

    if count == 0 then
        Print("|cFF5555No queues matched your filters. Check settings.|r")
        return false
    end

    local ok, err = pcall(function() ZO_ACTIVITY_FINDER_ROOT_MANAGER:StartSearch() end)
    if not ok then
        Print("|cFF5555Queue error: |r" .. tostring(err))
        return false
    end

    Print("Queued for " .. Hi(count) .. " Battleground(s).")
    return true
end

-- ============================================================
--  Queue state — auto-accept ready check
-- ============================================================
function BGH:OnActivityFinderStatus(_, status)
    if not self.vars then return end
    if status == ACTIVITY_FINDER_STATUS_READY_CHECK then
        if self.vars.autoAcceptReady and HasLFGReadyCheckNotification() then
            local delay = self.vars.readyDelayMs or 0
            if delay > 0 then
                zo_callLater(function()
                    if HasLFGReadyCheckNotification() then
                        AcceptLFGReadyCheckNotification()
                        Print("|c33DD33Ready check accepted.|r")
                    end
                end, delay)
            else
                AcceptLFGReadyCheckNotification()
                Print("|c33DD33Ready check accepted.|r")
            end
        end
    end
end

function BGH:RefreshQueueStateRegistration()
    EVENT_MANAGER:UnregisterForEvent(self.name .. "_QueueState", EVENT_ACTIVITY_FINDER_STATUS_UPDATE)
    if not self.queueStateHandler then
        self.queueStateHandler = function(ev, status)
            self:OnActivityFinderStatus(ev, status)
        end
    end
    EVENT_MANAGER:RegisterForEvent(
        self.name .. "_QueueState",
        EVENT_ACTIVITY_FINDER_STATUS_UPDATE,
        self.queueStateHandler)
end


-- ============================================================
--  Auto-release
-- ============================================================
function BGH:OnPlayerDead()
    if not self.vars or not self.vars.autoRelease then return end
    if not IsActiveWorldBattleground() then return end
    local delay = math.max(self.vars.releaseDelayMs or 2000, 200)
    zo_callLater(function()
        if IsActiveWorldBattleground() and IsUnitDead("player") then
            Release()
        end
    end, delay)
end

function BGH:RefreshAutoReleaseRegistration()
    if not self.playerDeadHandler then
        self.playerDeadHandler = function() self:OnPlayerDead() end
    end
    EVENT_MANAGER:UnregisterForEvent(self.name .. "_Dead", EVENT_PLAYER_DEAD)
    if self.vars and self.vars.autoRelease then
        EVENT_MANAGER:RegisterForEvent(
            self.name .. "_Dead", EVENT_PLAYER_DEAD, self.playerDeadHandler)
    end
end

-- ============================================================
--  Team rank
-- ============================================================
local function GetPlayerTeamRank()
    local playerAlliance = GetUnitBattlegroundAlliance("player")
    if not playerAlliance then return nil end

    local myIndex = GetLocalScoreboardIndex()
    if not myIndex or myIndex <= 0 then return nil end

    local teamScores = {}
    for i = 1, GetNumScoreboardEntries() do
        local _, _, alliance, _ = GetScoreboardEntryInfo(i)
        if alliance == playerAlliance then
            local s = GetScoreboardEntryScoreByType(i, SCORE_TRACKER_TYPE_SCORE) or 0
            teamScores[#teamScores + 1] = { score = s, index = i }
        end
    end

    if #teamScores == 0 then return nil end
    table.sort(teamScores, function(a, b) return a.score > b.score end)

    for rank, entry in ipairs(teamScores) do
        if entry.index == myIndex then
            return rank, #teamScores
        end
    end
    return nil
end

-- ============================================================
--  HUD helpers
-- ============================================================
local function MakeDivider(parent, name, offsetY)
    local div = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
    div:SetTexture(DIVIDER_TEX)
    div:SetHeight(DIV_H)
    div:SetAnchor(TOPLEFT,  parent, TOPLEFT,  -4, offsetY)
    div:SetAnchor(TOPRIGHT, parent, TOPRIGHT,  4, offsetY)
    div:SetColor(0.4, 0.4, 0.4, 0.8)
    return div
end

local function MakeFixedLabel(wm, parent, baseName, capText, capX, valX, capColor, valColor)
    local cap = wm:CreateControl(baseName .. "Cap", parent, CT_LABEL)
    cap:SetFont("ZoFontGame")
    cap:SetColor(capColor.r, capColor.g, capColor.b, 1)
    cap:SetText(capText)
    cap:SetAnchor(LEFT, parent, LEFT, capX, 0)

    local val = wm:CreateControl(baseName .. "Val", parent, CT_LABEL)
    val:SetFont("ZoFontGame")
    val:SetColor(valColor.r, valColor.g, valColor.b, 1)
    val:SetText("—")
    val:SetAnchor(LEFT, parent, LEFT, valX, 0)
    return val
end

function BGH:SaveHudPosition()
    if not self.vars or not self.hud.window then return end
    local gw, gh = GuiRoot:GetWidth(), GuiRoot:GetHeight()
    if gw > 0 and gh > 0 then
        self.vars.hudXPct = self.hud.window:GetLeft()  / gw
        self.vars.hudYPct = self.hud.window:GetTop()   / gh
    end
end

function BGH:RestoreHudPosition()
    local w = self.hud.window
    if not w then return end
    w:ClearAnchors()
    if self.vars.hudXPct and self.vars.hudYPct then
        w:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
            self.vars.hudXPct * GuiRoot:GetWidth(),
            self.vars.hudYPct * GuiRoot:GetHeight())
    else
        w:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, DEF_X, DEF_Y)
    end
end

function BGH:CancelHudFade()
    self.hudFadeNonce = (self.hudFadeNonce or 0) + 1
    self.hudFadeHandle = nil
end

function BGH:ShowHudInstant()
    if not self.hud.window then return end
    self:CancelHudFade()
    self.hud.window:SetHidden(false)
    self.hud.window:SetAlpha(self.vars and self.vars.hudOpacity or 1.0)
    if self.hud.fragment then
        self.hud.fragment:Show()
    end
end

function BGH:HideHud()
    if not self.hud.window then return end
    self:CancelHudFade()
    if self.hud.fragment then
        self.hud.fragment:Hide()
    end
    self.hud.window:SetHidden(true)
    self.hud.window:SetAlpha(self.vars and self.vars.hudOpacity or 1.0)
end

function BGH:SetHudEnabled(enabled, silent)
    if not self.vars then return end
    self.vars.showHud = enabled and true or false

    if self.vars.showHud then
        if not self.hud.window then self:CreateHud() end
        self:RefreshHudRegistration()
        if IsActiveWorldBattleground() then
            self:ResetHudValues()
            self:UpdateHud()
            self:FadeInHud()
        elseif self.vars.hudShowAnywhere then
            self:UpdateHud()
            self:ShowHudInstant()
        else
            self:HideHud()
            Print("HUD enabled — will show when you enter a Battleground.")
        end
    else
        self:RefreshHudRegistration()
        self:HideHud()
    end

    if not silent then
        Print("HUD: " .. BoolWord(self.vars.showHud))
    end
end

function BGH:SetHudLocked(locked)
    self.vars.hudLocked = locked
    local w = self.hud.window
    if not w then return end
    w:SetMovable(not locked)
    w:SetMouseEnabled(not locked)
    if self.hud.bg     then self.hud.bg:SetColor(0, 0, 0, locked and 0.60 or 0.75) end
    if self.hud.border then
        if locked then
            self.hud.border:SetEdgeColor(0.25, 0.25, 0.25, 0.9)
        else
            self.hud.border:SetEdgeColor(0.9, 0.3, 0.3, 1.0)
        end
    end
    if locked then
        self:SaveHudPosition()
        Print("HUD " .. Hi("locked") .. ".")
    else
        Print("HUD " .. Hi("unlocked") .. "  —  drag to reposition, then " .. Dim("/bgh hud lock") .. ".")
    end
end

function BGH:ResetHudValues()
    local h = self.hud
    if not h.valK then return end
    h.valK:SetText("0")
    h.valD:SetText("0")
    h.valA:SetText("0")
    h.valDmg:SetText("0")
    h.valHeal:SetText("0")
    h.valRank:SetText("—")
end

function BGH:ApplyHudOpacity()
    if not self.hud.window then return end
    local opacity = self.vars.hudOpacity or 1.0
    self.hud.window:SetAlpha(opacity)
end

function BGH:FadeInHud()
    if not self.hud.window then return end
    self:CancelHudFade()

    local w      = self.hud.window
    local step   = 0
    local target = self.vars.hudOpacity or 1.0
    local nonce  = self.hudFadeNonce

    w:SetAlpha(0)
    if self.hud.fragment then
        self.hud.fragment:Show()
    end

    local function tick()
        if nonce ~= self.hudFadeNonce then return end
        step = step + 1
        w:SetAlpha((step / FADE_STEPS) * target)
        if step < FADE_STEPS then
            self.hudFadeHandle = zo_callLater(tick, FADE_MS)
        else
            w:SetAlpha(target)
            self.hudFadeHandle = nil
        end
    end

    self.hudFadeHandle = zo_callLater(tick, FADE_MS)
end

-- ============================================================
--  HUD creation
-- ============================================================
function BGH:CreateHud()
    if self.hud.window then return end

    local wm     = WINDOW_MANAGER
    local h      = self.hud
    local base   = "BGHelperHUD"
    local locked = self.vars.hudLocked ~= false

    local w = wm:CreateTopLevelWindow(base)
    w:SetDimensions(HUD_W, HUD_H)
    w:SetMovable(not locked)
    w:SetMouseEnabled(not locked)
    w:SetClampedToScreen(true)
    w:SetAlpha(self.vars.hudOpacity or 1.0)
    h.window = w
    w:SetHandler("OnMoveStop", function() self:SaveHudPosition() end)

    -- Integrate into ESO scene system so HUD auto-hides with menus
    local fragment = ZO_HUDFadeSceneFragment:New(w)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
    h.fragment = fragment

    -- Override fragment Show so the scene system never reveals the HUD
    -- unless our own conditions are met (in BG, or hudShowAnywhere enabled)
    local originalShow = fragment.Show
    function fragment:Show(force)
        if not BGH.vars or not BGH.vars.showHud then return end
        if not IsActiveWorldBattleground() and not BGH.vars.hudShowAnywhere then return end
        originalShow(self, force)
    end

    local bg = wm:CreateControl(base .. "_BG", w, CT_TEXTURE)
    bg:SetAnchorFill(w)
    bg:SetColor(0, 0, 0, locked and 0.60 or 0.75)
    h.bg = bg

    local border = wm:CreateControl(base .. "_Border", w, CT_BACKDROP)
    border:SetAnchorFill(w)
    border:SetCenterColor(0, 0, 0, 0)
    border:SetEdgeColor(locked and 0.25 or 0.9, locked and 0.25 or 0.3, locked and 0.25 or 0.3, locked and 0.9 or 1.0)
    border:SetEdgeTexture("", 1, 1, 1, 0)
    h.border = border

    -- Row 1: K / D / A
    local r1 = wm:CreateControl(base .. "_R1", w, CT_CONTROL)
    r1:SetDimensions(HUD_W, ROW_H)
    r1:SetAnchor(TOPLEFT, w, TOPLEFT, 0, 0)
    h.valK = MakeFixedLabel(wm, r1, base .. "_K", "K", COL.capK, COL.valK, C.dim, C.green)
    h.valD = MakeFixedLabel(wm, r1, base .. "_D", "D", COL.capD, COL.valD, C.dim, C.red)
    h.valA = MakeFixedLabel(wm, r1, base .. "_A", "A", COL.capA, COL.valA, C.dim, C.yellow)

    MakeDivider(w, base .. "_Div1", ROW_H)

    -- Row 2: Dmg / Heals
    local r2 = wm:CreateControl(base .. "_R2", w, CT_CONTROL)
    r2:SetDimensions(HUD_W, ROW_H)
    r2:SetAnchor(TOPLEFT, w, TOPLEFT, 0, ROW_H + DIV_H)
    h.valDmg  = MakeFixedLabel(wm, r2, base .. "_Dmg",  "Dmg",   COL.capDmg,  COL.valDmg,  C.dim, C.orange)
    h.valHeal = MakeFixedLabel(wm, r2, base .. "_Heal", "Heals", COL.capHeal, COL.valHeal, C.dim, C.teal)

    MakeDivider(w, base .. "_Div2", ROW_H + DIV_H + ROW_H)

    -- Row 3: Rank
    local r3 = wm:CreateControl(base .. "_R3", w, CT_CONTROL)
    r3:SetDimensions(HUD_W, ROW_H)
    r3:SetAnchor(TOPLEFT, w, TOPLEFT, 0, (ROW_H + DIV_H) * 2)
    h.valRank = MakeFixedLabel(wm, r3, base .. "_Rank", "Rank", COL.capRank, COL.valRank, C.dim, C.gold)

    self:RestoreHudPosition()

    -- Start hidden — visibility managed by fragment and OnPlayerActivated
    fragment:Hide()
end

-- ============================================================
--  HUD update
-- ============================================================
function BGH:UpdateHud()
    if not self.vars or not self.vars.showHud then return end
    local inBg = IsActiveWorldBattleground()
    if not inBg and not self.vars.hudShowAnywhere then return end
    if not self.hud.window then self:CreateHud() end
    if not self.hud.valK then return end

    -- Outside BG: show placeholder values only
    if not inBg then
        self.hud.valK:SetText("—")
        self.hud.valD:SetText("—")
        self.hud.valA:SetText("—")
        self.hud.valDmg:SetText("—")
        self.hud.valHeal:SetText("—")
        self.hud.valRank:SetText("—")
        return
    end

    local idx = GetLocalScoreboardIndex()
    if idx and idx > 0 then
        local k  = GetScoreboardEntryScoreByType(idx, SCORE_TRACKER_TYPE_KILL)         or 0
        local d  = GetScoreboardEntryScoreByType(idx, SCORE_TRACKER_TYPE_DEATH)        or 0
        local a  = GetScoreboardEntryScoreByType(idx, SCORE_TRACKER_TYPE_ASSISTS)      or 0
        local dm = GetScoreboardEntryScoreByType(idx, SCORE_TRACKER_TYPE_DAMAGE_DONE)  or 0
        local hl = GetScoreboardEntryScoreByType(idx, SCORE_TRACKER_TYPE_HEALING_DONE) or 0
        self.hud.valK:SetText(tostring(k))
        self.hud.valD:SetText(tostring(d))
        self.hud.valA:SetText(tostring(a))
        self.hud.valDmg:SetText(FormatStat(dm))
        self.hud.valHeal:SetText(FormatStat(hl))
    end

    local rank, teamSize = GetPlayerTeamRank()
    if rank and teamSize then
        self.hud.valRank:SetText(string.format("#%d / %d", rank, teamSize))
    else
        self.hud.valRank:SetText("—")
    end
end

function BGH:RefreshHudRegistration()
    EVENT_MANAGER:UnregisterForEvent(self.name .. "_Score", EVENT_BATTLEGROUND_SCOREBOARD_UPDATED)
    if self.vars and self.vars.showHud then
        EVENT_MANAGER:RegisterForEvent(
            self.name .. "_Score",
            EVENT_BATTLEGROUND_SCOREBOARD_UPDATED,
            function() self:UpdateHud() end)
    else
        self:HideHud()
    end
end

-- ============================================================
--  Zone change
-- ============================================================
function BGH:OnPlayerActivated()
    self.zoneGuard = zo_callLater(function()
        self.zoneGuard = nil
        if not self.vars then return end

        local inBg = IsActiveWorldBattleground()

        if not self.vars.showHud then
            self:HideHud()
            EVENT_MANAGER:UnregisterForEvent(
                self.name .. "_Score", EVENT_BATTLEGROUND_SCOREBOARD_UPDATED)
            return
        end

        if not self.hud.window then self:CreateHud() end

        if inBg then
            self:ResetHudValues()
            self:RefreshHudRegistration()
            self:UpdateHud()
            self:FadeInHud()
        elseif self.vars.hudShowAnywhere then
            -- Show with placeholder values for positioning
            self:UpdateHud()
            self:ShowHudInstant()
            EVENT_MANAGER:UnregisterForEvent(
                self.name .. "_Score", EVENT_BATTLEGROUND_SCOREBOARD_UPDATED)
        else
            self:HideHud()
            EVENT_MANAGER:UnregisterForEvent(
                self.name .. "_Score", EVENT_BATTLEGROUND_SCOREBOARD_UPDATED)
        end
    end, 50)
end

-- ============================================================
--  Status
-- ============================================================
function BGH:PrintStatus()
    local v = self.vars
    Print(
        "4v4:" .. BoolWord(v.queue4v4) ..
        "  8v8:" .. BoolWord(v.queue8v8) ..
        "  Solo:" .. BoolWord(v.allowSoloQueues) ..
        "  Group:" .. BoolWord(v.allowGroupQueues) ..
        Dim("  |  ") ..
        "Release:" .. BoolWord(v.autoRelease) ..
        Dim("(" .. math.max(v.releaseDelayMs or 2000, 200) .. "ms)") ..
        "  Ready:" .. BoolWord(v.autoAcceptReady) ..
        "  HUD:" .. BoolWord(v.showHud))
end

-- ============================================================
--  LAM Settings Panel
-- ============================================================
function BGH:BuildSettingsPanel()
    if not LibAddonMenu2 then return end

    self.settingsPanel = LibAddonMenu2:RegisterAddonPanel(self.name .. "Panel", {
        type                = "panel",
        name                = "BGHelper",
        displayName         = "|c5BB8FFBGHelper|r",
        author              = "@NPViral",
        version             = self.version,
        slashCommand        = "/bghelpersettings",
        registerForRefresh  = true,
        registerForDefaults = true,
    })

    LibAddonMenu2:RegisterOptionControls(self.name .. "Panel", {

        { type = "description",
          text = "|c5BB8FFBGHelper|r — Battleground queue helper with live KDA HUD, "
              .. "auto-release, and ready-check auto-accept.\n\n"
              .. "|cFFFFFFKeybinds:|r Set up your binds under "
              .. "|cFFFFFFESC → Controls → Keybindings → BGHelper|r "
              .. "for the best experience." },

        -- ── QUEUE FILTERS ─────────────────────────────────────
        { type = "submenu", name = "Queue Filters", controls = {

            { type = "checkbox", name = "4v4",
              tooltip = "Include 4v4 Battleground queues.",
              getFunc = function() return self.vars.queue4v4 end,
              setFunc = function(v) self.vars.queue4v4 = v end,
              default = defaults.queue4v4, width = "half" },

            { type = "checkbox", name = "8v8",
              tooltip = "Include 8v8 Battleground queues.",
              getFunc = function() return self.vars.queue8v8 end,
              setFunc = function(v) self.vars.queue8v8 = v end,
              default = defaults.queue8v8, width = "half" },

            { type = "checkbox", name = "Solo",
              tooltip = "Include solo Battleground queues.",
              getFunc = function() return self.vars.allowSoloQueues end,
              setFunc = function(v) self.vars.allowSoloQueues = v end,
              default = defaults.allowSoloQueues, width = "half" },

            { type = "checkbox", name = "Group",
              tooltip = "Include group Battleground queues.",
              getFunc = function() return self.vars.allowGroupQueues end,
              setFunc = function(v) self.vars.allowGroupQueues = v end,
              default = defaults.allowGroupQueues, width = "half" },

            { type = "button", name = "Queue Now",
              func    = function() self:QueueSelectedBattlegrounds() end,
              warning = "Queues immediately using your current filter settings.",
              width   = "full" },
        }},

        -- ── AUTO-RELEASE ───────────────────────────────────────
        { type = "submenu", name = "Auto-Release", controls = {

            { type = "checkbox", name = "Enable auto-release",
              tooltip = "Automatically release to respawn on death in a Battleground.",
              getFunc = function() return self.vars.autoRelease end,
              setFunc = function(v)
                  self.vars.autoRelease = v
                  self:RefreshAutoReleaseRegistration()
              end,
              default = defaults.autoRelease, width = "full" },

            { type = "slider", name = "Release delay (ms)",
              tooltip = "Delay before releasing after death. Keep at 2000 ms to avoid "
                     .. "the 'not ready yet' spam from ESO. Minimum 200 ms.",
              min = 200, max = 2000, step = 100,
              getFunc = function() return math.max(self.vars.releaseDelayMs or 2000, 200) end,
              setFunc = function(v) self.vars.releaseDelayMs = v end,
              default = defaults.releaseDelayMs, width = "full" },
        }},

        -- ── READY CHECK ────────────────────────────────────────
        { type = "submenu", name = "Ready Check", controls = {

            { type = "checkbox", name = "Auto-accept ready check",
              tooltip = "Automatically accept the match-found popup.",
              getFunc = function() return self.vars.autoAcceptReady end,
              setFunc = function(v) self.vars.autoAcceptReady = v end,
              default = defaults.autoAcceptReady, width = "full" },

            { type = "slider", name = "Accept delay (ms)",
              tooltip = "Wait this long before auto-accepting the ready check. "
                     .. "0 = instant. Useful if you want a moment to cancel.",
              min = 0, max = 5000, step = 250,
              getFunc = function() return self.vars.readyDelayMs or 0 end,
              setFunc = function(v) self.vars.readyDelayMs = v end,
              default = defaults.readyDelayMs, width = "full" },
        }},

        -- ── KDA HUD ────────────────────────────────────────────
        { type = "submenu", name = "KDA HUD", controls = {

            { type = "checkbox", name = "Show live HUD",
              tooltip = "Show K/D/A, Damage, Heals and Team Rank in Battlegrounds. "
                     .. "Use /bgh hud reset if the HUD goes off-screen.",
              getFunc = function() return self.vars.showHud end,
              setFunc = function(v)
                  self:SetHudEnabled(v, true)
                  if v then
                      Print("HUD enabled — will show when you enter a Battleground.")
                  else
                      Print("HUD disabled.")
                  end
              end,
              default = defaults.showHud, width = "half" },

            { type = "checkbox", name = "Lock position",
              tooltip = "Uncheck to drag the HUD. Border turns red while unlocked.",
              getFunc = function() return self.vars.hudLocked ~= false end,
              setFunc = function(v) self:SetHudLocked(v) end,
              default = defaults.hudLocked, width = "half" },

            { type = "checkbox", name = "Show outside Battlegrounds",
              tooltip = "Shows the HUD anywhere so you can position and adjust it before entering a fight. Displays placeholder values outside a Battleground.",
              getFunc = function() return self.vars.hudShowAnywhere end,
              setFunc = function(v)
                  self.vars.hudShowAnywhere = v
                  if not self.hud.window then self:CreateHud() end
                  if v then
                      self:UpdateHud()
                      self:ShowHudInstant()
                      Print("HUD visible everywhere for positioning.")
                  else
                      if not IsActiveWorldBattleground() then
                          self:HideHud()
                      end
                      Print("HUD will show in Battlegrounds only.")
                  end
              end,
              default = defaults.hudShowAnywhere, width = "full" },

            { type = "slider", name = "Opacity",
              tooltip = "Overall HUD transparency. 10 = nearly invisible, 100 = fully opaque.",
              min = 10, max = 100, step = 5,
              getFunc = function() return math.floor((self.vars.hudOpacity or 1.0) * 100) end,
              setFunc = function(v)
                  self.vars.hudOpacity = v / 100
                  self:ApplyHudOpacity()
              end,
              default = 100, width = "full" },
        }},

        -- ── BOTTOM CONTROLS ────────────────────────────────────
        { type = "checkbox", name = "Chat alerts",
          tooltip = "Show BGHelper status messages in chat.",
          getFunc = function() return self.vars.showChatAlerts end,
          setFunc = function(v) self.vars.showChatAlerts = v end,
          default = defaults.showChatAlerts, width = "full" },

        { type = "button", name = "Print Status",
          func  = function() self:PrintStatus() end,
          width = "half" },

        { type = "button", name = "Reload UI",
          func    = function() ReloadUI() end,
          warning = "This will reload the UI immediately.",
          width   = "half" },

        { type = "button", name = "Feeling generous?",
          tooltip = "Donations keep the skooma flowing.",
          func = function()
              local ok = pcall(function()
                  if MAIN_MENU_KEYBOARD and type(MAIN_MENU_KEYBOARD.ShowScene) == "function" then
                      MAIN_MENU_KEYBOARD:ShowScene("mailSend")
                  end
                  if ZO_MailSendToField and type(ZO_MailSendToField.SetText) == "function" then
                      ZO_MailSendToField:SetText("@NPViral")
                  end
                  if ZO_MailSendSubjectField and type(ZO_MailSendSubjectField.SetText) == "function" then
                      ZO_MailSendSubjectField:SetText("Skooma Fund")
                  end
                  if ZO_MailSendBodyField and type(ZO_MailSendBodyField.SetText) == "function" then
                      ZO_MailSendBodyField:SetText("Thanks for the addon!")
                  end
              end)
              if not ok then
                  PrintAlways("Could not open mail automatically. Send gold manually to " .. Hi("@NPViral") .. ".")
              end
          end,
          width = "full" },
    })
end

function BGH:OpenSettings()
    if LibAddonMenu2 and self.settingsPanel then
        LibAddonMenu2:OpenToPanel(self.settingsPanel)
    else
        PrintAlways("Settings panel unavailable.")
    end
end

-- ============================================================
--  Slash commands
-- ============================================================
function BGH:RegisterSlashCommands()
    SLASH_COMMANDS["/bgq"] = function()
        self:QueueSelectedBattlegrounds()
    end

    SLASH_COMMANDS["/bgh"] = function(args)
        args = zo_strlower(zo_strtrim(args or "")):gsub("%s+", " ")

        if     args == "" or args == "status"  then self:PrintStatus()
        elseif args == "queue"                 then self:QueueSelectedBattlegrounds()
        elseif args == "settings"              then self:OpenSettings()
        elseif args == "release on"            then
            self.vars.autoRelease = true
            self:RefreshAutoReleaseRegistration()
            Print("Auto-release: " .. BoolWord(true))
        elseif args == "release off"           then
            self.vars.autoRelease = false
            self:RefreshAutoReleaseRegistration()
            Print("Auto-release: " .. BoolWord(false))
        elseif args == "release toggle"        then
            self.vars.autoRelease = not self.vars.autoRelease
            self:RefreshAutoReleaseRegistration()
            Print("Auto-release: " .. BoolWord(self.vars.autoRelease))
        elseif args == "hud"                   then
            self:SetHudEnabled(not self.vars.showHud, false)
        elseif args == "hud lock"              then
            if not self.hud.window then self:CreateHud() end
            self:SetHudLocked(true)
        elseif args == "hud unlock"            then
            if not self.hud.window then self:CreateHud() end
            self:SetHudLocked(false)
        elseif args == "hud reset"             then
            self.vars.hudXPct = nil
            self.vars.hudYPct = nil
            if not self.hud.window then self:CreateHud() end
            self:RestoreHudPosition()
            Print("HUD position reset to default.")
        elseif args == "chat"                  then
            self.vars.showChatAlerts = not self.vars.showChatAlerts
            PrintAlways("Chat alerts: " .. BoolWord(self.vars.showChatAlerts))
        elseif args == "version"               then
            PrintAlways("v" .. self.version)
        else
            Print(Dim("Commands: ") ..
                "status  queue  settings  " ..
                "release on/off/toggle  " ..
                "hud  hud lock/unlock/reset  " ..
                "chat  version")
        end
    end

    SLASH_COMMANDS["/bghelper"]         = function(a) SLASH_COMMANDS["/bgh"](a) end
    SLASH_COMMANDS["/bghelpersettings"] = function()  self:OpenSettings()       end
    SLASH_COMMANDS["/bghstatus"]        = function()  self:PrintStatus()        end
end

-- ============================================================
--  Initialize
-- ============================================================
function BGH:Initialize()
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)

    self:MigrateOldSavedVars()
    self.vars = ZO_SavedVars:NewAccountWide("BGHelperSavedVars", 1, nil, defaults)

    self:RegisterSlashCommands()
    self:BuildSettingsPanel()
    self:RefreshAutoReleaseRegistration()
    self:RefreshQueueStateRegistration()

    if self.vars.showHud then
        self:CreateHud()
        self:RefreshHudRegistration()
    end

    EVENT_MANAGER:RegisterForEvent(
        self.name .. "_Activated",
        EVENT_PLAYER_ACTIVATED,
        function() self:OnPlayerActivated() end)

    ZO_CreateStringId("SI_BINDING_NAME_BGH_QUEUE_SELECTED", "Queue Selected Battlegrounds")
    ZO_CreateStringId("SI_BINDING_NAME_BGH_OPEN_SETTINGS",  "Open BGHelper Settings")
    ZO_CreateStringId("SI_BINDING_NAME_BGH_TOGGLE_RELEASE", "Toggle Auto-Release")
    ZO_CreateStringId("SI_BINDING_NAME_BGH_TOGGLE_HUD",     "Toggle KDA HUD")

    self:CheckVersionNotice()
end

function BGH.OnAddonLoaded(_, addonName)
    if addonName ~= BGH.name then return end
    BGH:Initialize()
end

-- ============================================================
--  Keybind entry points (Bindings.xml)
-- ============================================================
function BGHelper_QueueSelected()  BGH:QueueSelectedBattlegrounds() end
function BGHelper_OpenSettings()   BGH:OpenSettings()               end

function BGHelper_ToggleRelease()
    if not BGH.vars then return end
    BGH.vars.autoRelease = not BGH.vars.autoRelease
    BGH:RefreshAutoReleaseRegistration()
    Print("Auto-release: " .. BoolWord(BGH.vars.autoRelease))
end

function BGHelper_ToggleHud()
    if not BGH.vars then return end
    BGH:SetHudEnabled(not BGH.vars.showHud, false)
end

EVENT_MANAGER:RegisterForEvent(BGH.name, EVENT_ADD_ON_LOADED, BGH.OnAddonLoaded)

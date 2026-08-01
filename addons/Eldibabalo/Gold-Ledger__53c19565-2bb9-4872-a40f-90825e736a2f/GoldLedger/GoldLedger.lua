local ADDON_NAME = "GoldLedger"
local PRUNE_SECONDS = 14 * 24 * 3600
local ROLLING_WEEK_SECONDS = 7 * 24 * 3600
local SV_VERSION = 4
local LOC_WALLET = "wallet"
local LOC_BANK = "bank"

GoldLedger = GoldLedger or {}
local G = GoldLedger
G.sceneName = "GoldLedgerScene"
G.scene = nil
G.hubRetryScheduled = false
-- Session-only last known amounts per location (never persist — avoids 0 vs "unloaded" bugs).
G.snapshots = G.snapshots or {}

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d, e, f = pcall(fn, ...)
    if ok then return a, b, c, d, e, f end
    return nil
end

local function SafeNum(v, fallback)
    local n = tonumber(v)
    if n == nil then return fallback or 0 end
    return n
end

local function GetMoneyType()
    return _G["CURT_MONEY"] or _G["CURTYPE_MONEY"]
end

local function GetWalletLocation()
    return _G["CURRENCY_LOCATION_CHARACTER"]
end

local function GetBankLocation()
    return _G["CURRENCY_LOCATION_BANK"]
end

local function GetCharKey()
    -- Used to separate character wallet history (bank is account-wide on ESO).
    local name = SafeCall(GetUnitName, "player")
    if type(name) == "string" and name ~= "" then
        return name
    end
    return "UnknownChar"
end

-- Readable thousands: 10000000 -> 10'000'000 (apostrophe separators).
local function FormatGold(n)
    n = math.floor(SafeNum(n, 0))
    local neg = n < 0
    if neg then
        n = -n
    end
    local s = tostring(n)
    if s == "0" then
        return neg and "-0" or "0"
    end
    local rev = s:reverse()
    local chunks = {}
    for i = 1, #rev, 3 do
        chunks[#chunks + 1] = rev:sub(i, math.min(i + 2, #rev))
    end
    local joined = table.concat(chunks, "'")
    local out = joined:reverse()
    if neg then
        out = "-" .. out
    end
    return out
end

-- Single-line "how much went up/down" (net change) with a leading + for gains.
local function FormatSignedNet(n)
    local v = math.floor(SafeNum(n, 0))
    if v > 0 then
        return "+" .. FormatGold(v)
    end
    return FormatGold(v)
end

local function GetLocalStartOfDayTimestamp(ts)
    ts = ts or SafeCall(GetTimeStamp) or 0
    local t = os.date("*t", ts)
    if not t then return ts end
    t.hour, t.min, t.sec = 0, 0, 0
    local startTs = os.time(t)
    if type(startTs) == "number" then
        return startTs
    end
    return ts
end

local function EnsureSV()
    GoldLedgerSV = GoldLedgerSV or {}
    if GoldLedgerSV.version == nil then
        GoldLedgerSV.version = SV_VERSION
    end
    local ver = SafeNum(GoldLedgerSV.version, 1)
    if type(GoldLedgerSV.deltas) ~= "table" then
        GoldLedgerSV.deltas = {}
    end
    if type(GoldLedgerSV.charKey) ~= "string" then
        GoldLedgerSV.charKey = ""
    end
    -- Never persist lastGold — was causing false income when bank read as 0 but last was stored as 0.
    GoldLedgerSV.lastGold = nil
    if ver < SV_VERSION then
        if ver < 3 then
            -- v2 -> v3: keep bank history, but drop wallet history entries that have no char tag.
            local kept = {}
            for _, e in ipairs(GoldLedgerSV.deltas) do
                if type(e) == "table" then
                    if e.loc == nil then
                        e.loc = LOC_WALLET
                    end
                    if e.loc == LOC_BANK then
                        table.insert(kept, e)
                    elseif e.loc == LOC_WALLET then
                        if type(e.char) == "string" and e.char ~= "" then
                            table.insert(kept, e)
                        end
                    end
                end
            end
            GoldLedgerSV.deltas = kept
        end
        if ver < 4 then
            -- v4: reset history — prior bank totals could be inflated (baseline 0 vs real balance).
            GoldLedgerSV.deltas = {}
        end
        GoldLedgerSV.version = SV_VERSION
    end
end

function G:GetGoldAtLocation(locationConst)
    local mt = GetMoneyType()
    if type(mt) ~= "number" or type(locationConst) ~= "number" then
        return 0
    end
    if type(GetCurrencyAmount) ~= "function" then
        return 0
    end
    return math.floor(SafeNum(SafeCall(GetCurrencyAmount, mt, locationConst), 0))
end

function G:GetWalletGold()
    return self:GetGoldAtLocation(GetWalletLocation())
end

function G:GetBankGold()
    return self:GetGoldAtLocation(GetBankLocation())
end

function G:PruneDeltas()
    local sv = self.sv
    if not sv or type(sv.deltas) ~= "table" then return end
    local now = SafeCall(GetTimeStamp) or 0
    local cutoff = now - PRUNE_SECONDS
    local kept = {}
    for _, e in ipairs(sv.deltas) do
        if type(e) == "table" and type(e.t) == "number" and type(e.d) == "number" then
            if e.loc ~= LOC_WALLET and e.loc ~= LOC_BANK then
                e.loc = LOC_WALLET
            end
            if e.t >= cutoff then
                table.insert(kept, e)
            end
        end
    end
    sv.deltas = kept
end

function G:RecordDelta(delta, locKey)
    local d = math.floor(SafeNum(delta, 0))
    if d == 0 then return end
    if locKey ~= LOC_WALLET and locKey ~= LOC_BANK then
        locKey = LOC_WALLET
    end
    EnsureSV()
    self.sv = GoldLedgerSV
    local ts = SafeCall(GetTimeStamp) or 0
    local entry = { t = ts, d = d, loc = locKey }
    if locKey == LOC_WALLET then
        entry.char = self.sv.charKey or GetCharKey()
    end
    table.insert(self.sv.deltas, entry)
    self:PruneDeltas()
end

-- locFilter: "wallet", "bank", or nil for wallet+bank combined
function G:ComputeWindow(startTs, endTs, locFilter)
    local income = 0
    local expenseAbs = 0
    local sv = self.sv
    if not sv or type(sv.deltas) ~= "table" then
        return 0, 0, 0
    end
    local charKey = sv.charKey
    for _, e in ipairs(sv.deltas) do
        if type(e) == "table" and type(e.t) == "number" and type(e.d) == "number" then
            local loc = e.loc or LOC_WALLET
            if loc ~= LOC_WALLET and loc ~= LOC_BANK then
                loc = LOC_WALLET
            end
            if loc == LOC_WALLET then
                -- Wallet is per-character; bank is shared and has no char tag.
                if type(e.char) == "string" and e.char ~= "" and charKey ~= "" and e.char ~= charKey then
                    loc = nil -- skip other character's wallet deltas
                elseif type(e.char) ~= "string" or e.char == "" then
                    -- Back-compat safety: ignore untagged wallet deltas in v3.
                    loc = nil
                end
            end

            if loc == nil then
                -- skipped (untagged wallet delta)
            elseif locFilter ~= nil and loc ~= locFilter then
                -- skip
            elseif e.t >= startTs and e.t <= endTs then
                if e.d > 0 then
                    income = income + e.d
                elseif e.d < 0 then
                    expenseAbs = expenseAbs + (-e.d)
                end
            end
        end
    end
    local net = income - expenseAbs
    return income, expenseAbs, net
end

function G:OnCurrencyUpdate(_, currencyType, currencyLocation, newAmount, oldAmount)
    local mt = GetMoneyType()
    local walletLoc = GetWalletLocation()
    local bankLoc = GetBankLocation()
    if type(mt) ~= "number" then
        return
    end
    if SafeNum(currencyType, -1) ~= mt then
        return
    end
    local cloc = SafeNum(currencyLocation, -1)
    local locKey = nil
    if type(walletLoc) == "number" and cloc == walletLoc then
        locKey = LOC_WALLET
    elseif type(bankLoc) == "number" and cloc == bankLoc then
        locKey = LOC_BANK
    else
        return
    end
    local newAmt = math.floor(SafeNum(newAmount, 0))
    EnsureSV()
    self.sv = GoldLedgerSV
    self.snapshots = self.snapshots or {}
    local last = self.snapshots[locKey]
    -- nil = not seeded yet (do NOT treat 0 as "seeded" — bank often reads 0 before load).
    if last == nil then
        self.snapshots[locKey] = newAmt
        return
    end

    local delta = newAmt - last
    if delta ~= 0 then
        self:RecordDelta(delta, locKey)
    end
    self.snapshots[locKey] = newAmt
    local root = _G["GoldLedger_Window"]
    if root and not root:IsHidden() then
        self:RefreshUI()
    end
end

local function EnsureOpaqueWindow(root)
    if not root then return end
    root:SetAlpha(1)
    local bg = root:GetNamedChild("BG")
    if bg then
        bg:SetAlpha(1)
        if type(bg.SetColor) == "function" then
            bg:SetColor(0, 0, 0, 1)
        end
    end
    local frame = root:GetNamedChild("Frame")
    if frame and type(frame.SetCenterColor) == "function" then
        frame:SetCenterColor(0, 0, 0, 1)
    end
    local ol = root:GetNamedChild("OpaqueLayer")
    if ol then
        ol:SetAlpha(1)
        if type(ol.SetColor) == "function" then
            ol:SetColor(0, 0, 0, 1)
        end
    end
end

local function SetText(control, text)
    if control and control.SetText then
        control:SetText(tostring(text or ""))
    end
end

function G:RefreshUI()
    local root = _G["GoldLedger_Window"]
    if not root then return end
    EnsureOpaqueWindow(root)

    local now = SafeCall(GetTimeStamp) or 0
    local dayStart = GetLocalStartOfDayTimestamp(now)
    local weekStart = now - ROLLING_WEEK_SECONDS

    local dCombIn, dCombOut, dCombNet = self:ComputeWindow(dayStart, now, nil)
    local dWalIn, dWalOut, dWalNet = self:ComputeWindow(dayStart, now, LOC_WALLET)
    local dBankIn, dBankOut, dBankNet = self:ComputeWindow(dayStart, now, LOC_BANK)

    local wCombIn, wCombOut, wCombNet = self:ComputeWindow(weekStart, now, nil)
    local wWalIn, wWalOut, wWalNet = self:ComputeWindow(weekStart, now, LOC_WALLET)
    local wBankIn, wBankOut, wBankNet = self:ComputeWindow(weekStart, now, LOC_BANK)

    local walletBal = self:GetWalletGold()
    local bankBal = self:GetBankGold()
    SetText(root:GetNamedChild("Balance"), string.format(
        "Wallet: %s  |  Bank: %s  |  Total: %s",
        FormatGold(walletBal),
        FormatGold(bankBal),
        FormatGold(walletBal + bankBal)
    ))

    SetText(root:GetNamedChild("Legend"), string.format(
        "|cAAAAAAInc|r = gold that arrived  |  |cAAAAAAExp|r = gold that left  |  |cAAAAAANet|r = Inc−Exp\n" ..
        "|c888888Wallet/Bank lines use one number = Net change only (e.g. deposit: wallet |cFF9090-|r, bank |c90EE90+|r; combined Net ~0).|r"
    ))

    -- Combined: keep full Inc / Exp / Net (total gold movement story).
    SetText(root:GetNamedChild("DailyIncome"), string.format("Combined — Inc: %s  Exp: %s  Net: %s", FormatGold(dCombIn), FormatGold(dCombOut), FormatGold(dCombNet)))
    -- Wallet / bank: single signed net (what most people mean by "I moved 25k today").
    SetText(root:GetNamedChild("DailyExpense"), string.format("Wallet (today net): %s", FormatSignedNet(dWalNet)))
    SetText(root:GetNamedChild("DailyNet"), string.format("Bank (today net): %s", FormatSignedNet(dBankNet)))

    SetText(root:GetNamedChild("WeekIncome"), string.format("Combined — Inc: %s  Exp: %s  Net: %s", FormatGold(wCombIn), FormatGold(wCombOut), FormatGold(wCombNet)))
    SetText(root:GetNamedChild("WeekExpense"), string.format("Wallet (7 days net): %s", FormatSignedNet(wWalNet)))
    SetText(root:GetNamedChild("WeekNet"), string.format("Bank (7 days net): %s", FormatSignedNet(wBankNet)))
end

local function IsNegativeCloseKey(keyCode)
    if keyCode == nil then return false end
    local candidates = {
        134,
        _G.KEY_GAMEPAD_BUTTON_2,
        _G.KEY_GAMEPAD_CIRCLE,
        _G.KEY_GAMEPAD_BACK,
        _G.KEY_ESCAPE,
    }
    for _, c in ipairs(candidates) do
        if type(c) == "number" and keyCode == c then
            return true
        end
    end
    return false
end

local lastCloseAt = 0
local function IsDebounced(cooldownMs)
    local now = 0
    if type(GetFrameTimeMilliseconds) == "function" then
        now = SafeNum(SafeCall(GetFrameTimeMilliseconds), 0)
    end
    if now <= 0 then return false, now end
    if (now - lastCloseAt) < SafeNum(cooldownMs, 200) then
        return true, now
    end
    lastCloseAt = now
    return false, now
end

function G:OnKeyDown(_, keyCode)
    if not IsNegativeCloseKey(keyCode) then
        return false
    end
    local blocked = IsDebounced(220)
    if blocked then return true end
    G:ToggleWindow()
    return true
end

function G:SetupScene()
    if self.scene then
        return
    end
    local root = _G["GoldLedger_Window"]
    if not root then
        return
    end
    local scene = ZO_Scene:New(self.sceneName, SCENE_MANAGER)
    scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    if GAMEPAD_MENU_SOUND_FRAGMENT then
        scene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
    end
    scene:AddFragment(ZO_SimpleSceneFragment:New(root))
    scene:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWING then
            EnsureOpaqueWindow(root)
            self:RefreshUI()
            if not G.mainKeyHandlerBound then
                root:SetHandler("OnKeyDown", function(control, keyCode)
                    return G:OnKeyDown(control, keyCode)
                end)
                G.mainKeyHandlerBound = true
            end
        end
    end)
    self.scene = scene
end

function G:RegisterInTrackingToolsHub()
    if ELDIBABALO_TRACKING_TOOLS and ELDIBABALO_TRACKING_TOOLS.Register then
        ELDIBABALO_TRACKING_TOOLS:Register(
            "Gold Ledger",
            "EsoUI/Art/currency/currency_gold.dds",
            self.sceneName
        )
        if ELDIBABALO_TRACKING_TOOLS.RefreshList then
            ELDIBABALO_TRACKING_TOOLS:RefreshList()
        end
        self.hubRetryScheduled = false
        return true
    end
    if not self.hubRetryScheduled then
        self.hubRetryScheduled = true
        zo_callLater(function()
            self.hubRetryScheduled = false
            self:RegisterInTrackingToolsHub()
        end, 1500)
    end
    return false
end

function G:ToggleWindow()
    self:SetupScene()
    self:RegisterInTrackingToolsHub()
    if not self.sceneName or not SCENE_MANAGER then
        return
    end
    pcall(function()
        if SCENE_MANAGER:IsShowing(self.sceneName) then
            SCENE_MANAGER:Hide(self.sceneName)
        else
            SCENE_MANAGER:Show(self.sceneName)
        end
    end)
end

function G:OnPlayerActivated()
    EnsureSV()
    self.sv = GoldLedgerSV
    self:UpdateBaselines()
end

function G:UpdateBaselines()
    EnsureSV()
    self.sv = GoldLedgerSV
    self.sv.charKey = GetCharKey()
    self.snapshots = self.snapshots or {}
    self.snapshots[LOC_WALLET] = self:GetWalletGold()
    local bankAmt = self:GetBankGold()
    -- If bank reports 0, keep snapshot nil so first EVENT seeds without counting full balance as income.
    self.snapshots[LOC_BANK] = (bankAmt > 0) and bankAmt or nil
end

function G:Initialize()
    EnsureSV()
    self.sv = GoldLedgerSV
    -- Establish initial baselines early so the first currency update isn't counted as "income".
    G:UpdateBaselines()

    ZO_CreateStringId("SI_BINDING_NAME_GOLDLEDGER_TOGGLE", "Toggle Gold Ledger")

    SLASH_COMMANDS["/goldledger"] = function()
        G:ToggleWindow()
    end
    SLASH_COMMANDS["/gledger"] = function()
        G:ToggleWindow()
    end

    if type(_G["EVENT_CURRENCY_UPDATE"]) == "number" then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Currency", _G["EVENT_CURRENCY_UPDATE"], function(eventCode, currencyType, currencyLocation, newAmount, oldAmount)
            local ok = pcall(function()
                G:OnCurrencyUpdate(eventCode, currencyType, currencyLocation, newAmount, oldAmount)
            end)
            if not ok then
                -- Swallow currency callback faults (console-safe).
            end
        end)
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
        G:OnPlayerActivated()
    end)

    G:SetupScene()
    G:RegisterInTrackingToolsHub()
    zo_callLater(function()
        G:RegisterInTrackingToolsHub()
    end, 2000)
end

function GOLDLEDGER_ToggleWindow()
    G:ToggleWindow()
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end
    G:Initialize()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)

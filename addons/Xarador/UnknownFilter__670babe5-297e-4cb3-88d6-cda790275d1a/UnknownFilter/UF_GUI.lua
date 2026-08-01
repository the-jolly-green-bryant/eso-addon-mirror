-- UF_GUI.lua (v0.2.13)
-- Gamepad Guild Store GUI pruning, scene-scoped hook & keybinds

local UF = UnknownFilter

UF.TARGET_LIST_NAME = UF.TARGET_LIST_NAME or "ZO_TradingHouse_BrowseResults_GamepadContainerList"

local CANDIDATE_NAMES = {
    "ZO_TradingHouse_BrowseResults_GamepadContainerList",
    "ZO_TradingHouse_BrowseResults_GamepadList",
    "ZO_TradingHouse_BrowseResults_Gamepad",
}

-- ========= Helpers =========

local function IsCallable(f) return type(f)=="function" end

local function Safe_ZO_ScrollList_GetDataList(control)
    if not control or not IsCallable(ZO_ScrollList_GetDataList) then return nil end
    local ok, list = pcall(ZO_ScrollList_GetDataList, control)
    if ok and type(list)=="table" then return list end
    return nil
end

local function Safe_GetResultLinkByIndex(idx)
    if not (idx and idx>0 and IsCallable(GetTradingHouseSearchResultItemLink)) then return nil end
    local ok, l = pcall(GetTradingHouseSearchResultItemLink, idx)
    if ok and type(l)=="string" and l~="" then return l end
    return nil
end

local function IsTradingSceneShown()
    local sc = SCENE_MANAGER and SCENE_MANAGER:GetScene("gamepad_trading_house")
    if not sc then return false end
    if sc.IsShowing and sc:IsShowing() then return true end
    if sc.GetState and sc:GetState() == SCENE_SHOWN then return true end
    return false
end

local function IsBrowseMode()
    if TRADING_HOUSE_GAMEPAD and TRADING_HOUSE_GAMEPAD.GetCurrentMode then
        local mode = TRADING_HOUSE_GAMEPAD:GetCurrentMode()
        if type(ZO_TRADING_HOUSE_MODE_BROWSE) == "number" then
            return mode == ZO_TRADING_HOUSE_MODE_BROWSE
        end
        return mode == 1
    end
    return false
end

local function IsTargetControlName(name)
    if not name then return false end
    if name == UF.TARGET_LIST_NAME then return true end
    for i=1,#CANDIDATE_NAMES do
        if name == CANDIDATE_NAMES[i] then return true end
    end
    return false
end

local function IsTargetControl(self, control)
    if not (control and control.GetName) then return false end
    local name = control:GetName()
    if IsTargetControlName(name) then return true end
    for _ = 1, 3 do
        if control.GetParent then
            control = control:GetParent()
            if control and control.GetName and IsTargetControlName(control:GetName()) then
                return true
            end
        end
    end
    return false
end

function UF:GetResultList()
    local first = GetControl(self.TARGET_LIST_NAME)
    if first then return first end
    for i = 1, #CANDIDATE_NAMES do
        local c = GetControl(CANDIDATE_NAMES[i])
        if c then return c end
    end
    return nil
end

-- ========= SAFE WRAPPER (nur SelectDataAndScrollIntoView, nur unsere Liste) ==

local Orig_SelectAndScroll

-- tolerant identity helpers (entry vs entry.data / index / link-ish)
local IDX_KEYS = { "resultIndex","tradingHouseIndex","searchResultIndex","slotIndex","index" }
local NESTS = { "itemData","data","details","payload","value" }

local function ExtractIndex(tbl)
    if type(tbl) ~= "table" then return nil end
    for _,k in ipairs(IDX_KEYS) do
        local v = tbl[k]; if type(v)=="number" and v>0 then return v end
    end
    for _,n in ipairs(NESTS) do
        local sub = tbl[n]
        if type(sub)=="table" then
            for _,k in ipairs(IDX_KEYS) do
                local v = sub[k]; if type(v)=="number" and v>0 then return v end
            end
        end
    end
    return nil
end

local function ExtractLinkish(tbl)
    if type(tbl) ~= "table" then return nil end
    if type(tbl.itemLink)=="string" and tbl.itemLink~="" then return tbl.itemLink end
    if type(tbl.link)=="string" and tbl.link~="" then return tbl.link end
    local d = tbl.data or tbl.itemData or tbl.details
    if type(d)=="table" then
        if type(d.itemLink)=="string" and d.itemLink~="" then return d.itemLink end
        if type(d.link)=="string" and d.link~="" then return d.link end
    end
    return nil
end

local function SameData(a,b)
    if a == b then return true end
    if type(a)~="table" or type(b)~="table" then return false end
    if a.data and a.data == b then return true end
    if b.data and b.data == a then return true end
    local ia, ib = ExtractIndex(a), ExtractIndex(b)
    if ia and ib and ia==ib then return true end
    local la, lb = ExtractLinkish(a), ExtractLinkish(b)
    if la and lb and la==lb then return true end
    return false
end

local function SafeDataList(list)
    local dl = Safe_ZO_ScrollList_GetDataList(list)
    if type(dl)=="table" then return dl end
    return nil
end

local function DataInList(list, data)
    local dl = SafeDataList(list)
    if not dl then return nil end      -- unklar -> nicht eingreifen
    for _, entry in ipairs(dl) do
        if entry then
            if SameData(entry, data) or SameData(entry.data, data) then
                return true
            end
        end
    end
    return false
end

local function FirstData(list)
    local dl = SafeDataList(list)
    if dl and dl[1] then return dl[1].data or dl[1] end
    return nil
end

local function IsUFScrollList(list)
    if not (list and list.GetName) then return false end
    if IsTargetControlName(list:GetName()) then return true end
    local parent = list.GetParent and list:GetParent()
    for _=1,3 do
        if not parent or not parent.GetName then break end
        if IsTargetControlName(parent:GetName()) then return true end
        parent = parent.GetParent and parent:GetParent()
    end
    return false
end

local function InstallSafeScrollWrapper()
    if UF._safeScrollInstalled then return end
    if not IsCallable(ZO_ScrollList_SelectDataAndScrollIntoView) then return end

    Orig_SelectAndScroll = ZO_ScrollList_SelectDataAndScrollIntoView
    ZO_ScrollList_SelectDataAndScrollIntoView = function(list, data, ...)
        -- Nur unsere Browse-Liste schützen; alles andere sofort durchreichen
        if not IsUFScrollList(list) then
            return Orig_SelectAndScroll(list, data, ...)
        end

        -- Nur eingreifen, wenn wir sicher wissen, dass 'data' NICHT in der Liste ist
        local present = DataInList(list, data)
        if present == nil or present == true then
            return Orig_SelectAndScroll(list, data, ...)
        end

        -- 'data' existiert nicht mehr -> wähle den ersten gültigen Eintrag (falls vorhanden)
        local first = FirstData(list)
        if first then
            return Orig_SelectAndScroll(list, first, ...)
        end
        -- leere Liste → no-op
    end

    UF._safeScrollInstalled = true
end

-- ========= Mode change / Commit hook / Prune ================================

local function UF_OnTradingHouseModeChanged()
    if UF and UF._kbGroup and KEYBIND_STRIP then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(UF._kbGroup)
    end
    if UF and UF._armed and IsTradingSceneShown() and IsBrowseMode() then
        zo_callLater(function()
            if UF._armed and IsTradingSceneShown() and IsBrowseMode() then
                UF:PruneResultList()
            end
        end, 0)
    end
end

local function WireModeHooksOnce()
    if UF._modeHooksWired then return end
    if not TRADING_HOUSE_GAMEPAD then return end
    if ZO_PreHook and TRADING_HOUSE_GAMEPAD.SwitchToMode then
        ZO_PreHook(TRADING_HOUSE_GAMEPAD, "SwitchToMode", function(_) UF_OnTradingHouseModeChanged() return false end)
    end
    if ZO_PreHook and TRADING_HOUSE_GAMEPAD.SetCurrentMode then
        ZO_PreHook(TRADING_HOUSE_GAMEPAD, "SetCurrentMode", function(_) UF_OnTradingHouseModeChanged() return false end)
    end
    if ZO_PreHook and TRADING_HOUSE_GAMEPAD.RefreshHeader then
        ZO_PreHook(TRADING_HOUSE_GAMEPAD, "RefreshHeader", function(_) UF_OnTradingHouseModeChanged() return false end)
    end
    UF._modeHooksWired = true
end

local Orig_ScrollList_Commit = nil
local function OurCommitWrapper(control, ...)
    if not IsCallable(Orig_ScrollList_Commit) then return end
    if UF._inCommitHook then
        return Orig_ScrollList_Commit(control, ...)
    end
    UF._inCommitHook = true
    local r = { Orig_ScrollList_Commit(control, ...) }
    if UF._armed and IsTradingSceneShown() and IsBrowseMode() and IsTargetControl(UF, control) then
        pcall(function() UF:PruneResultList() end)
    end
    UF._inCommitHook = false
    return unpack(r)
end

function UF:HookCommitForScene()
    if self._commitHooked then return end
    if not IsCallable(ZO_ScrollList_Commit) then return end
    Orig_ScrollList_Commit = ZO_ScrollList_Commit
    ZO_ScrollList_Commit = OurCommitWrapper
    self._commitHooked = true
end

function UF:UnhookCommitForScene()
    if not self._commitHooked then return end
    if ZO_ScrollList_Commit == OurCommitWrapper and IsCallable(Orig_ScrollList_Commit) then
        ZO_ScrollList_Commit = Orig_ScrollList_Commit
    end
    Orig_ScrollList_Commit = nil
    self._commitHooked = false
end

function UF:PruneResultList()
    if not self._armed then return 0,0 end
    if not IsTradingSceneShown() then return 0,0 end
    if not IsBrowseMode() then return 0,0 end

    local mode = (self.saved and self.saved.mode) or self.MODE_OFF
    if mode == self.MODE_OFF then return 0,0 end

    local control = self:GetResultList()
    if not control then return 0,0 end

    local dataList = Safe_ZO_ScrollList_GetDataList(control)
    if type(dataList) ~= "table" then return 0,0 end
    local n = #dataList
    if n == 0 then return 0,0 end

    local kept, dropped = 0, 0
    local dbgCap   = (self.saved and self.saved.debugScan) and (self.saved.debugCap or 80) or 0
    local dbgShown = 0
    local keepIfNo = (self.saved and self.saved.keepIfNoLink) or false

    for i = n, 1, -1 do
        local row = dataList[i]
        if type(row) ~= "table" then
            table.remove(dataList, i); dropped = dropped + 1
        else
            local data = row.data or row.itemData or row.value or row.payload
            local link = nil

            if data and IsCallable(self.DeepLink) then
                local ok, l = pcall(self.DeepLink, self, data)
                if ok and type(l)=="string" and l~="" then link = l end
            end

            if (not link or link=="") and data and IsCallable(self.ResultIndexFromRow) then
                local okIdx, idx = pcall(self.ResultIndexFromRow, self, data)
                if okIdx and idx then link = Safe_GetResultLinkByIndex(idx) end
            end

            local keep, via
            if link and link ~= "" then
                local okPass, k, how = pcall(self.Passes, self, link, mode)
                if okPass then keep, via = (k==true), (how or "live")
                else keep, via = keepIfNo, "passes-error" end
            else
                keep, via = keepIfNo, "no-link"
            end

            if dbgShown < dbgCap then
                local nm = (link and GetItemLinkName and GetItemLinkName(link)) or "<no link>"
                self:Say(string.format("ROW %d | %s | keep=%s via=%s", i, nm, tostring(keep), tostring(via)))
                dbgShown = dbgShown + 1
            end

            if not keep then table.remove(dataList, i); dropped = dropped + 1 else kept = kept + 1 end
        end
    end

    if IsCallable(Orig_ScrollList_Commit) then
        Orig_ScrollList_Commit(control)
    elseif IsCallable(ZO_ScrollList_Commit) then
        ZO_ScrollList_Commit(control)
    end

    if self._passByIndex then for k in pairs(self._passByIndex) do self._passByIndex[k] = nil end end
    if self._passByLink  then for k in pairs(self._passByLink)  do self._passByLink[k]  = nil end end
    self._passTotal = 0

    return kept, dropped
end

-- ========= Keybind & scene wiring ==========================================

function UF:RebuildAndPrune()
    if not self._armed then return end
    zo_callLater(function()
        if self._armed and IsTradingSceneShown() and IsBrowseMode() then
            self:PruneResultList()
        end
        if self._kbGroup and KEYBIND_STRIP then
            KEYBIND_STRIP:UpdateKeybindButtonGroup(self._kbGroup)
        end
    end, 30)
end

function UF:ToggleMode()
    if not self._armed then return end
    local m = (self.saved and self.saved.mode) or self.MODE_OFF
    if m==self.MODE_OFF then m=self.MODE_GEAR
    elseif m==self.MODE_GEAR then m=self.MODE_LEARN
    elseif m==self.MODE_LEARN then m=self.MODE_MOTIF
    elseif m==self.MODE_MOTIF then m=self.MODE_COLLECT
    else m=self.MODE_OFF end
    self.saved.mode = m
    self:RebuildAndPrune()
end

function UF:_AddL3Keybind()
    if self._kbGroup or not KEYBIND_STRIP then return end
    self._kbGroup = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            name    = function() return "Filter: ".. self:ModeShort((self.saved and self.saved.mode) or self.MODE_OFF) end,
            keybind = "UI_SHORTCUT_LEFT_STICK",
            callback= function() self:ToggleMode() end,
            visible = function()
                return self._armed and IsTradingSceneShown() and IsBrowseMode()
            end,
        },
    }
    KEYBIND_STRIP:AddKeybindButtonGroup(self._kbGroup)
end

function UF:_RemoveL3Keybind()
    if self._kbGroup and KEYBIND_STRIP then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(self._kbGroup)
        self._kbGroup = nil
    end
end

function UF:WireSceneKeybind()
    if self._sceneWired then return end
    local scene = SCENE_MANAGER and SCENE_MANAGER:GetScene("gamepad_trading_house")
    if not scene then return end

    InstallSafeScrollWrapper()

    scene:RegisterCallback("StateChange", function(_, newState)
        if not self._armed then return end
        if newState == SCENE_SHOWN then
            self:HookCommitForScene()
            self:_AddL3Keybind()
            WireModeHooksOnce()
            UF_OnTradingHouseModeChanged()
        elseif newState == SCENE_SHOWING then
            self:UnhookCommitForScene()
        elseif newState == SCENE_HIDDEN then
            self:_RemoveL3Keybind()
            self:UnhookCommitForScene()
            self:FreeMemory()
        end
    end)
    self._sceneWired = true
end

function UF:FreeMemory()
    if self._kbGroup and KEYBIND_STRIP then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(self._kbGroup)
        self._kbGroup = nil
    end
    if self._passByIndex then for k in pairs(self._passByIndex) do self._passByIndex[k] = nil end end
    if self._passByLink  then for k in pairs(self._passByLink)  do self._passByLink[k]  = nil end end
    self._passTotal = 0
end

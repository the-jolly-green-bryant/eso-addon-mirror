-- This file is part of CyrHUD
--
-- (C) 2015 Scott Yeskie (Sasky)
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

CyrHUD = CyrHUD or {}

----------------------------------------------
-- Utility
----------------------------------------------
local function bl(val)
	if val == nil then return "NIL" elseif val then return "T" else return "F" end
end

local function nn(val)
    if val == nil then return "NIL" end
    return val
end

function CyrHUD.formatTime(delta, inclueSec)
    local sec = delta % 60
    delta = (delta - sec) / 60
    local min = delta % 60
    local out = min .. "m"

    if inclueSec then
        out = out .. " " .. sec .. "s"
    end
    return out
end

CyrHUD.errors = {}
function CyrHUD:error(val)
    if not self.errors[val] then
        self.errors[val] = 1
        d("|cFF0000ERROR (CyrHUD): " .. val .. "\n|CCCCCCCPlease file this bug info with a screenshot at |CEEEEFFesoui.com (CyrHUD)")
    end
end

----------------------------------------------
-- Events
----------------------------------------------
function CyrHUD.eventAttackChange(_, keepID, battlegroundContext, underAttack)
    local self = CyrHUD

    --Optionally hide IC district battles
    if GetKeepType(keepID) == KEEPTYPE_IMPERIAL_CITY_DISTRICT then
        if CyrHUD.cfg.hideImpBattles then
            return;
        end
    end

    if underAttack then
        self:add(keepID)
    elseif self.battles[keepID] ~= nil then
        self.battles[keepID]:update()
    end
    self.battleContext = battlegroundContext
end

function CyrHUD.saveWindowPosition( window )
    local _, sP, _, aP, x, y = window:GetAnchor()
    CyrHUD.cfg.anchPoint = aP
    CyrHUD.cfg.selfPoint = sP
    CyrHUD.cfg.xoff = x
    CyrHUD.cfg.yoff = y
end

function CyrHUD.actionLayerChange(_, _, activeLayerIndex)
    CyrHUD_UI:SetHidden(activeLayerIndex > 2)
end

----------------------------------------------
-- Notification UI pool
----------------------------------------------
CyrHUD.entryCount = 0
CyrHUD.entries = {}

function CyrHUD:reconfigureLabels()
    for _,entry in pairs(self.entries) do
        --Forces reconfigure on next update
        entry.type = nil
    end
end

function CyrHUD:hideRow(index)
    if self.entries[index] then
        self.entries[index].main:SetHidden(true)
    end
end

function CyrHUD:getUIRow(index)
    if #self.entries < index then
        table.insert(self.entries, self.Label())
        index = #self.entries
    end
    self.entries[index].main:SetHidden(false)
    return self.entries[index]
end

function CyrHUD:printAll()
    local i = 1
    for _,status in ipairs(self.statusBars) do
        self:getUIRow(i):update(status)
        i = i + 1
    end

    for _,battle in pairs(self.battles) do
        self:getUIRow(i):update(battle)
        i = i + 1
    end
    --Fix since auto-resize doesn't seem to work well
    self.ui:SetHeight(math.max(i*35,70))
    for j=i,#self.entries do
        self:hideRow(j)
    end
end

----------------------------------------------
-- Battle management
----------------------------------------------
CyrHUD.battles = {}
function CyrHUD:add(keepID)
    if self.battles[keepID] == nil then
        self.battles[keepID] = self.Battle(keepID)
    else
        self.battles[keepID]:restart()
    end
end

function CyrHUD:checkAdd(keepID)
    if self.battles[keepID] == nil then
        local battle = self.Battle(keepID)
        if battle:isBattle() then
            self.battles[keepID] = battle
        end
    elseif self.battles[keepID]:isBattle() then
        self.battles[keepID]:restart()
    end
end

function CyrHUD:updateAll()
    for i,_ in pairs(self.battles) do
        --Update in-place
        self.battles[i]:update()
    end

    for _,status in pairs(self.statusBars) do
        status:update()
    end
end

function CyrHUD:scanKeeps()
    --Main keeps
    for i=3,20 do
        self:checkAdd(i)
    end

    --Outposts
    for i=132,134 do
        self:checkAdd(i)
    end

    --Note: Resources and Imperial Disatricts are not included in scan
    --Those would add a lots of checks for something with fast turnover.
end

------------------------------------------------------------------------
-- Initialization
------------------------------------------------------------------------
CyrHUD.visible = false
function CyrHUD:init()
    --Init UI
    self:disableQuestTrackers()
    self.ui:SetHidden(false)

    --Populate data
    self:refresh()

    --Add events
    EVENT_MANAGER:RegisterForUpdate("CyrHUDKeepCheck", 5000, function()
        self:scanKeeps()
        self:updateAll()
    end)
    EVENT_MANAGER:RegisterForUpdate("CyrHUDUIUpdate", 1000, function()
        self:printAll()
    end)
    EVENT_MANAGER:RegisterForEvent("CyrHUDAttackChange", EVENT_KEEP_UNDER_ATTACK_CHANGED, self.eventAttackChange)
    self.visible = true

    EVENT_MANAGER:RegisterForEvent('CyrHUD', EVENT_ACTION_LAYER_POPPED, self.actionLayerChange)
    EVENT_MANAGER:RegisterForEvent('CyrHUD', EVENT_ACTION_LAYER_PUSHED, self.actionLayerChange)
end

function CyrHUD:refresh()
    if not self.cfg.aprOff and ((GetDate() % 1000) == 401) then
        local side = GetUnitAlliance("player")
        local color = self.info[side].color
        for i=1,3 do
            self.info[i].color = self.info[side].opcolor
        end
        self.info[side].color = color
    else
        self.info[ALLIANCE_ALDMERI_DOMINION].color = self.colors.yellow
        self.info[ALLIANCE_DAGGERFALL_COVENANT].color = self.colors.blue
        self.info[ALLIANCE_EBONHEART_PACT].color = self.colors.red
    end

    --Get initial scan
    self.battles = {}
    self.battleContext = BGQUERY_LOCAL
    self.campaign = GetCurrentCampaignId()
    --Could separate this with a data refresh eventually, but just do a hard reset for now
    self.statusBars = {}
    table.insert(self.statusBars, self.ScoringBar())
    self:scanKeeps()

    --Force update on status bar
    self:reconfigureLabels()
end

function CyrHUD:disableQuestTrackers()
    self.trackers = {}
    if self.cfg.trackerDisable then
        if WYK_QuestTracker_MQT then
            self.trackers.WYK_QuestTracker_MQT = WYK_QuestTracker_MQT:IsHidden()
            WYK_QuestTracker_MQT:SetHidden(true)
        end
    end
    if self.cfg.zosTrackerDisable then
        self.trackers.ZO_QuestTracker = ZO_QuestTracker:IsHidden()
        self.trackers.ZO_FocusedQuestTrackerPanel = ZO_FocusedQuestTrackerPanel:IsHidden()
        ZO_FocusedQuestTrackerPanel:SetHidden(true)
        ZO_QuestTracker:SetHidden(true)
    end
end

function CyrHUD:reEnableQuestTrackers()
    if self.trackers then
        for k,v in pairs(self.trackers) do
            if _G[k] ~= nil then _G[k]:SetHidden(v) end
        end
    end
end

function CyrHUD:deinit()
    self:reEnableQuestTrackers()
    EVENT_MANAGER:UnregisterForUpdate("CyrHUDKeepCheck")
    EVENT_MANAGER:UnregisterForUpdate("CyrHUDUIUpdate")
    EVENT_MANAGER:UnregisterForUpdate("CyrHUDUpdateAPCount")
    EVENT_MANAGER:UnregisterForEvent("CyrHUD", EVENT_ACTION_LAYER_POPPED)
    EVENT_MANAGER:UnregisterForEvent("CyrHUD", EVENT_ACTION_LAYER_PUSHED)
    CyrHUD_UI:SetHidden(true)
    self.visible = false
end


function CyrHUD.toggle()
    local self = CyrHUD
    if self.visible then
        self:deinit()
    else
        self:init()
    end
end
--TODO: Properly setup on Addon init or playerLoad
--TODO: only show while in Cyrodiil?
SLASH_COMMANDS["/cyrhud"] = CyrHUD.toggle

--Called once. Handles controls, etc.
function CyrHUD.addonInit()
    local self = CyrHUD

    --Init saved variables
    local def = {
        xoff = -10,
        yoff = 60,
        trackerDisable = false,
        showPopBars = false,
    }
    self.cfg = ZO_SavedVars:NewAccountWide("CyrHUD_SavedVars", 1.0, "config", def)

    --Create UI
    self.ui = WINDOW_MANAGER:CreateTopLevelWindow("CyrHUD_UI")
    self.ui:SetWidth(280)
    self.ui:SetMouseEnabled(true)
    self.ui:SetMovable(true)
    self.ui:SetClampedToScreen(true)
    self.ui:SetHandler("OnMoveStop", self.saveWindowPosition)
    local _, pt, relTo, relPt = CyrHUD_UI:GetAnchor()
    self.ui:ClearAnchors()
    self.ui:SetAnchor(CyrHUD.cfg.selfPoint or TOPLEFT,
        GuiRoot, CyrHUD.cfg.anchPoint or TOPRIGHT,
        CyrHUD.cfg.xoff, CyrHUD.cfg.yoff)

    --Create settings menu
    local LAM = LibStub("LibAddonMenu-2.0")
    LAM:RegisterAddonPanel("CyrHUD-LAM", self.menuPanel)
    LAM:RegisterOptionControls("CyrHUD-LAM", self.menuOptions)
    self.initLAM = true

    if (GetDate() % 1000)== 401 then
        --NOTE: If you see this before 4/1, please don't share
        table.insert(self.menuOptions,{
            type = "checkbox",
            name = GetString(SI_CYRHUD_APRIL1),
            tooltip = GetString(SI_CYRHUD_APRIL1_TOOLTIP),
            getFunc = function() return CyrHUD.cfg.aprOff or false end,
            setFunc = function(v) CyrHUD.cfg.aprOff = v; CyrHUD:refresh() end,
        })
    end
end

function CyrHUD.playerInit()
    local self = CyrHUD
    if not self.initLAM then
        self.addonInit()
    end

    if IsPlayerInAvAWorld() then
        if self.visible then
            self:refresh()
        else
            self:init()
        end
    elseif self.visible then
        self:deinit()
    end
end

EVENT_MANAGER:RegisterForEvent("CyrHUD-init", EVENT_PLAYER_ACTIVATED, CyrHUD.playerInit)

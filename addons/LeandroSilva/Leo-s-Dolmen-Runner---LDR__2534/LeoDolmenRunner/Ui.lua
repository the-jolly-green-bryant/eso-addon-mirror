local Ui = {}
local LDR = LeoDolmenRunner

local function getColor(value, max)
    local rate = value / max
    if rate > 0.8 then return '10FF10' end
    if rate > 0.5 then return 'FFFF00' end
    return 'FF1010'
end

function Ui:UpdateTrainingGear()
    local stack = 0
    local stackRepair = 0
    local maxItems = 9
    local numItems = 0
    local bag = SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_WORN)
    for _, data in pairs(bag) do
        local link = GetItemLink(data.bagId, data.slotIndex)
        if GetItemLinkTraitType(link) == ITEM_TRAIT_TYPE_ARMOR_TRAINING or GetItemLinkTraitType(link) == ITEM_TRAIT_TYPE_WEAPON_TRAINING then
            local activeWeaponPair = GetActiveWeaponPairInfo()
            if ( GetItemLinkItemType(link) == ITEMTYPE_ARMOR
                or
                (activeWeaponPair == ACTIVE_WEAPON_PAIR_MAIN and (data.slotIndex == EQUIP_SLOT_MAIN_HAND or data.slotIndex == EQUIP_SLOT_OFF_HAND))
                or
                (activeWeaponPair == ACTIVE_WEAPON_PAIR_BACKUP and (data.slotIndex == EQUIP_SLOT_BACKUP_MAIN or data.slotIndex == EQUIP_SLOT_BACKUP_OFF)))
            then
                local quality = select(8, GetItemInfo(data.bagId, data.slotIndex))
                local condition = GetItemCondition(data.bagId, data.slotIndex)
                local equipType = select(6, GetItemInfo(data.bagId, data.slotIndex))
                numItems = numItems + 1
                local xp = 0
                if GetItemLinkItemType(link) == ITEMTYPE_ARMOR then
                    xp = 6 + quality
                elseif equipType == EQUIP_TYPE_TWO_HAND then
                    numItems = numItems + 1
                    xp = 4 + quality
                else
                    xp = 2 + (0.5 * quality)
                end
                stack = stack + xp
                if condition == 0 then stackRepair = stackRepair + xp end
            end
        end
    end

    local text = ""

    if stackRepair > 0 then
        text = "|c" .. getColor(stack - stackRepair, stack) .. " " .. (stack - stackRepair) .. " / " .. stack .. "%|r (Repair)"
    else
        text = "|c" .. getColor(stack, stack) .. stack .. "%|r"
    end

    LeoDolmenRunnerWindowPanelXpFromGear:SetText(text)
    LeoDolmenRunnerWindowPanelTrainingGear:SetText("|c" .. getColor(numItems, maxItems) .. numItems .. " / " .. maxItems .. "|r")
end

function Ui:CreateUI()
    LeoDolmenRunnerWindowPanelStartStopLabel:SetText(LDR.runner.started and "Stop" or "Start")
    LeoDolmenRunnerWindowPanelOrientationLabel:SetText(LDR.runner.data.direction == LDR.runner.directions.cw and "CW" or "CCW")

    LeoDolmenRunnerWindowInviterPanel:SetHidden(not IsUnitSoloOrGroupLeader("player"))
    LeoDolmenRunnerWindowInviterPanelMessage:SetText(LDR.inviter.message)

    self:UpdateTrainingGear()
end

local function FormatNumber(num)
    return zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(num))
end

local function FormatTime(seconds, short, colorizeCountdown)
    if short == nil then short = false end
    local formats = {
        dhm = SI_TIME_FORMAT_DDHHMM_DESC_SHORT,
        day = SI_TIME_FORMAT_DAYS,
        hm = SI_TIME_FORMAT_HHMM_DESC_SHORT,
        hms = SI_TIME_FORMAT_HHMMSS_DESC_SHORT,
        hour = SI_TIME_FORMAT_HOURS,
        ms = SI_TIME_FORMAT_MMSS_DESC_SHORT,
        m = SI_TIME_FORMAT_MINUTES
    }
    if seconds and seconds > 0 then
        local ss = seconds % 60
        local mm = math.floor(seconds / 60)
        local hh = math.floor(mm / 60)
        mm = mm % 60
        local dn = math.floor(hh / 24)
        local hhdn = hh - (dn*24)

        local ssF = string.format("%02d", ss)
        local mmF = string.format("%02d", mm)
        local hhF = string.format("%02d", hh)
        local hhdnF = string.format("%02d", hhdn)

        local result = ''
        if dn > 0 then
            if short then
                result = ZO_CachedStrFormat(GetString(formats.day), dn) .." "..ZO_CachedStrFormat(GetString(formats.hour), hhdnF)
            else
                result = ZO_CachedStrFormat(GetString(formats.dhm), dn, hhdnF, mmF)
            end
        elseif hh > 0 then
            if short then
                result = ZO_CachedStrFormat(GetString(formats.hm), hhF, mmF)
            else
                result = ZO_CachedStrFormat(GetString(formats.hms), hhF, mmF, ssF)
            end
        elseif mm >= 0 then result = ZO_CachedStrFormat(GetString(formats.ms), mmF, ssF)
        end
        return result
    else return ZO_CachedStrFormat(GetString(formats.m), 0) end
end

function Ui:Update(tick)

    if not LDR.runner.started then return end

    if tick == 5 then
        self:UpdateTrainingGear()
    end

    if LDR.runner.started and LeoDolmenRunner.runner.data.startedTime > 0 then
        local secs = GetTimeStamp() - LeoDolmenRunner.runner.data.startedTime
        if secs > 0 then
            LeoDolmenRunnerWindowPanelTime:SetText(FormatTime(secs))
        end
    end

    LeoDolmenRunnerWindowPanelDolmensClosed:SetText(LDR.runner.data.dolmensClosed)
    LeoDolmenRunnerWindowPanelCurrentDolmen:SetText(FormatNumber(LDR.runner.data.currentDolmen))
    LeoDolmenRunnerWindowPanelLastDolmen:SetText(FormatNumber(LDR.runner.data.lastDolmen))
    LeoDolmenRunnerWindowPanelBeforeLastDolmen:SetText(FormatNumber(LDR.runner.data.beforeLastDolmen))
    LeoDolmenRunnerWindowPanelXP:SetText(FormatNumber(math.ceil(LDR.runner.data.xpPerMinute)) .. " / min")

    LeoDolmenRunnerWindowPanelXPNext:SetText(ZO_CachedStrFormat(GetString(SI_TIME_FORMAT_HHMM_DESC_SHORT), LDR.runner.data.hoursToLevel, LDR.runner.data.minutesToLevel))

    LeoDolmenRunnerWindowInviterPanelMessage:SetText(LDR.inviter.message)
    LeoDolmenRunnerWindowInviterPanel:SetHidden(not IsUnitSoloOrGroupLeader("player"))
end

function Ui:OnWindowMoveStop()
    LDR.settings.position = {
        left = self.frame:GetLeft(),
        top = self.frame:GetTop()
    }
end

function Ui:RestorePosition()
    local position = LDR.settings.position or { left = 200; top = 200; }
    local left = position.left
    local top = position.top

    self.frame:ClearAnchors()
    self.frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    self.frame:SetDrawTier(DT_MEDIUM)
end

function Ui:Initialize()
    self.frame = LeoDolmenRunnerWindow

    self:RestorePosition()

    self:CreateUI()

    self.frame:SetHidden(LeoDolmenRunner.settings.hidden)
end

LeoDolmenRunner.ui = Ui

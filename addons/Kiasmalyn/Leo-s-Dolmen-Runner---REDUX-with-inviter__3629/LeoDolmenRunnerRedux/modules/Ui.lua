local Ui = {}
local LDR = LeoDolmenRunnerRedux
local Exp = {
    savedVariablesChar = {
        enabled = true
    }
}
local settings = {
    activeWindow = false
}
local TLC = LeoDolmenRunnerReduxWindow
local tlcFragment = nil

local function FormatNumber(num)
    return zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(num))
end

local function FormatTime(seconds, short, colorizeCountdown)
    if short == nil then
        short = false
    end
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
        local hhdn = hh - (dn * 24)

        local ssF = string.format("%02d", ss)
        local mmF = string.format("%02d", mm)
        local hhF = string.format("%02d", hh)
        local hhdnF = string.format("%02d", hhdn)

        local result = ''
        if dn > 0 then
            if short then
                result = ZO_CachedStrFormat(GetString(formats.day), dn) .. " " .. ZO_CachedStrFormat(GetString(formats.hour), hhdnF)
            else
                result = ZO_CachedStrFormat(GetString(formats.dhm), dn, hhdnF, mmF)
            end
        elseif hh > 0 then
            if short then
                result = ZO_CachedStrFormat(GetString(formats.hm), hhF, mmF)
            else
                result = ZO_CachedStrFormat(GetString(formats.hms), hhF, mmF, ssF)
            end
        elseif mm >= 0 then
            result = ZO_CachedStrFormat(GetString(formats.ms), mmF, ssF)
        end
        return result
    else
        return ZO_CachedStrFormat(GetString(formats.m), 0)
    end
end

local function getColor(value, max)
    local rate = value / max
    if rate > 0.8 then
        return '10FF10'
    end
    if rate > 0.5 then
        return 'FFFF00'
    end
    return 'FF1010'
end

function Ui:UpdateTrainingGear()
    local stack = 0
    local stackRepair = 0
    local maxItems = 9
    local numItems = 0
    local bag = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_WORN)
    for _, data in pairs(bag) do
        local link = GetItemLink(data.bagId, data.slotIndex)
        if GetItemLinkTraitType(link) == ITEM_TRAIT_TYPE_ARMOR_TRAINING or GetItemLinkTraitType(link) == ITEM_TRAIT_TYPE_WEAPON_TRAINING then
            local activeWeaponPair = GetActiveWeaponPairInfo()
            if (GetItemLinkItemType(link) == ITEMTYPE_ARMOR
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
                if condition == 0 then
                    stackRepair = stackRepair + xp
                end
            end
        end
    end

    local text = ""

    if stackRepair > 0 then
        text = "|c" .. getColor(stack - stackRepair, stack) .. " " .. (stack - stackRepair) .. " / " .. stack .. "%|r (Repair)"
    else
        text = "|c" .. getColor(stack, stack) .. stack .. "%|r"
    end

    LeoDolmenRunnerReduxWindowPanelXpFromGear:SetText(text)
    LeoDolmenRunnerReduxWindowPanelTrainingGear:SetText("|c" .. getColor(numItems, maxItems) .. numItems .. " / " .. maxItems .. "|r")
end

function Ui:GetExpBuff()
    local numBuffs = GetNumBuffs("player")
    local hasActiveEffects = numBuffs > 0
    local indexXPBuff = 0
    if hasActiveEffects then
        for i = 1, numBuffs do
            local checkBuffName = GetUnitBuffInfo("player", i)
            if checkBuffName:find("Experience") then
                indexXPBuff = i
            elseif checkBuffName:find("Ambrosia") then
                indexXPBuff = i
            end
        end
        if indexXPBuff ~= 0 then
            local buffName, startTime, endTime = GetUnitBuffInfo("player", indexXPBuff)

            local timeLeft = math.floor(((endTime * 1000.0) - GetFrameTimeMilliseconds()) / 1000)
            --local duration = endTime - startTime --for testing only
            local xpSeconds = timeLeft % 60
            local xpMinutes = (math.floor(timeLeft / 60)) % 60
            local xpHours = math.floor(timeLeft / 60 / 60)
            if xpMinutes < 10 then
                xpMinutes = "0" .. xpMinutes
            end
            if xpSeconds < 10 then
                xpSeconds = "0" .. xpSeconds
            end
            xpText = xpHours .. ":" .. xpMinutes .. ":" .. xpSeconds

            if buffName:find("Experience") then
                LeoDolmenRunnerReduxWindowPanelExpBuffLabel:SetText("Exp Buff")
                -- LeoDolmenRunnerReduxWindowPanel_Icon:SetTexture("esoui/art/icons/store_expriencescroll_001.dds")
            elseif buffName:find("Ambrosia") then
                LeoDolmenRunnerReduxWindowPanelExpBuffLabel:SetText("Amb Buff")
                -- LeoDolmenRunnerReduxWindowPanel_Icon:SetTexture("esoui/art/icons/quest_potion_001.dds")
            end

            --d(buffName.. ": " .. duration.. ": " .. timeLeft.. " "..indexXPBuff) --for testing only
            LeoDolmenRunnerReduxWindowPanelExpBuff:SetText(xpText)

            if timeLeft > 300 then
                LeoDolmenRunnerReduxWindowPanelExpBuff:SetColor(0.5, 1, 0.5)
            else
                LeoDolmenRunnerReduxWindowPanelExpBuff:SetColor(1, 1, 0.5)
            end
        else
            LeoDolmenRunnerReduxWindowPanelExpBuff:SetText("None")
            LeoDolmenRunnerReduxWindowPanelExpBuff:SetColor(1, 0.5, 0.5)
            -- LeoDolmenRunnerReduxWindowPanel_Icon:SetTexture("esoui/art/icons/icon_experience.dds")
        end
    end
    if Exp.savedVariablesChar.enabled then
        zo_callLater(function()
            self:GetExpBuff()
        end, 500)
    end
end

-- ***************** init and updates 

function Ui:Initialize()
    self.frame = LeoDolmenRunnerReduxWindow
    self:RestorePosition()

    self:CreateUI()
end

function Ui:ToggleShow()
    settings.activeWindow = not settings.activeWindow
    if (tlcFragment ~= nil) then
        if (settings.activeWindow == true) then
            tlcFragment:Show()
        else
            tlcFragment:Hide()
        end
    end
end

function Ui:AddTLCFragment(fragment)
    SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)
end

function Ui:CreateUI()
    LeoDolmenRunnerReduxWindowPanelStartStopLabel:SetText(LDR.runner.started and "Stop" or "Start")
    LeoDolmenRunnerReduxWindowPanelOrientationLabel:SetText(LDR.runner.data.direction == LDR.runner.directions.cw and "CW" or "CCW")

    LeoDolmenRunnerReduxWindowInviterPanel:SetHidden(not IsUnitSoloOrGroupLeader("player"))
    self:UpdateTrainingGear()
    self:GetExpBuff()

    tlcFragment = ZO_SimpleSceneFragment:New(LeoDolmenRunnerReduxWindow)

    tlcFragment:SetConditional(function()
        return settings.activeWindow
    end)

    SCENE_MANAGER:GetScene("hud"):AddFragment(tlcFragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(tlcFragment)
end

function Ui:Update(tick)

    if not LDR.runner.started then
        return
    end

    if tick == 5 then
        self:UpdateTrainingGear()
        self:GetExpBuff()
    end

    if LDR.runner.started and LeoDolmenRunnerRedux.runner.data.startedTime > 0 then
        local secs = GetTimeStamp() - LeoDolmenRunnerRedux.runner.data.startedTime
        if secs > 0 then
            LeoDolmenRunnerReduxWindowPanelTime:SetText(FormatTime(secs))
        end
    end

    LeoDolmenRunnerReduxWindowPanelDolmensClosed:SetText(LDR.runner.data.dolmensClosed)
    LeoDolmenRunnerReduxWindowPanelCurrentDolmen:SetText(FormatNumber(LDR.runner.data.currentDolmen))
    LeoDolmenRunnerReduxWindowPanelLastDolmen:SetText(FormatNumber(LDR.runner.data.lastDolmen))
    LeoDolmenRunnerReduxWindowPanelBeforeLastDolmen:SetText(FormatNumber(LDR.runner.data.beforeLastDolmen))
    LeoDolmenRunnerReduxWindowPanelXP:SetText(FormatNumber(math.ceil(LDR.runner.data.xpPerMinute)) .. " / min")

    LeoDolmenRunnerReduxWindowPanelXPNext:SetText(ZO_CachedStrFormat(GetString(SI_TIME_FORMAT_HHMM_DESC_SHORT), LDR.runner.data.hoursToLevel, LDR.runner.data.minutesToLevel))

    LeoDolmenRunnerReduxWindowInviterPanel:SetHidden(not IsUnitSoloOrGroupLeader("player"))
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

LeoDolmenRunnerRedux.ui = Ui

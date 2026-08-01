CitizenRG = {
    name = "CitizenRG",
}
local bahsei ={
    bleed = {},
    MTTstack = 0,
    MTTfragment = nil
}

--Unregistor
local function Unregistor()
    CitizenNotifier.RemoveAllBanners()
    EVENT_MANAGER:UnregisterForEvent(CitizenRG.name .."OaxPoisonOSI", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(CitizenRG.name .."BahseiDeathTouchOSI", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(CitizenRG.name .."BleedTrace", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForUpdate(CitizenRG.name .."BleedCheck")
    EVENT_MANAGER:UnregisterForEvent(CitizenRG.name .."MoulderingTaintTracker", EVENT_COMBAT_EVENT)
end

--Check time of Bleeds
---CitizenRG.name .."BleedCheck", 200
local function BleedChecker()
    local currentTime = GetGameTimeMilliseconds() / 1000
    local timer = bahsei.bleed[1] - currentTime

    if currentTime >= bahsei.bleed[1] then
        table.remove(bahsei.bleed, 1)
    end

    if CitizenAddon.PVEcontent.RG.bahsei.offTankOnly then
        if #bahsei.bleed == 1 then
            CitizenNotifier.SetBanner("|c990000Bleed|r: ".. string.format("%.0f", timer) .."s")
        elseif #bahsei.bleed == 2 then
            CitizenNotifier.SetBanner("Double!|c990000Bleed|r: ".. string.format("%.0f", timer) .."s")
        elseif #bahsei.bleed == 3 then
            CitizenNotifier.SetBanner("|cd4af37Triple!!|r|c990000Bleed|r: ".. string.format("%.0f", timer) .."s")
        elseif #bahsei.bleed == 4 then
            CitizenNotifier.SetBanner("|c288ba8Quadruple!!!|r|c990000Bleed|r: ".. string.format("%.0f", timer) .."s")
        elseif #bahsei.bleed >= 5 then
            CitizenNotifier.SetBanner("U GUYS AFK OR WHAT?")
        else
            CitizenNotifier.RemoveBanner()
        end
    else
        if #bahsei.bleed == 1 then
            CitizenNotifier.SetBanner("|c990000Bleed|r: ".. string.format("%.0f", timer) .."s")
        elseif #bahsei.bleed == 2 then
            CitizenNotifier.SetBanner("|c990000Bleed|r: ".. string.format("%.0f", timer) .."s".." |c990000/|r ".. string.format("%.0f", bahsei.bleed[2] - currentTime) .."s")
        elseif #bahsei.bleed == 3 then
            CitizenNotifier.SetBanner("|c990000Bleed|r: ".. string.format("%.0f", timer) .."s".." |c990000/|r ".. string.format("%.0f", bahsei.bleed[2] - currentTime) .."s".." |c990000/|r ".. string.format("%.0f", bahsei.bleed[3] - currentTime) .."s")
        elseif #bahsei.bleed == 4 then
            CitizenNotifier.SetBanner("|c990000Bleed|r: ".. string.format("%.0f", timer) .."s".." |c990000/|r ".. string.format("%.0f", bahsei.bleed[2] - currentTime) .."s".." |c990000/|r ".. string.format("%.0f", bahsei.bleed[3] - currentTime) .."s".." |c990000/|r ".. string.format("%.0f", bahsei.bleed[4] - currentTime) .."s")
        elseif #bahsei.bleed >= 5 then
            CitizenNotifier.SetBanner("U GUYS AFK OR WHAT?")
        else
            CitizenNotifier.RemoveBanner()
        end
    end

    if timer <= 0 then
        CitizenNotifier.RemoveBanner()
    end
    if #bahsei.bleed == 0 then
        EVENT_MANAGER:UnregisterForUpdate(CitizenRG.name .."BleedCheck")
    end
end

--Track Abo Bleed Attack
---CitizenRG.name .."BleedTrace", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_BEGIN
    --ABILITY_ID, 150008
local function BleedTracker(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId, _, _)
    local currentTime = GetGameTimeMilliseconds() / 1000

    local targetUnitDisplayName = GetUnitDisplayName(CitizenAddon.group.unitIdToUnitTag[targetUnitId])

    if CitizenAddon.PVEcontent.RG.bahsei.bleedOsi then
        CitizenNotifier.Icon(targetUnitDisplayName, CitizenMarker.iconData[13], CitizenAddon.PVEcontent.RG.bahsei.bleedOsiIconSize, {1,0,0}, nil, nil, {10000,true,true,false})
    end

    if CitizenAddon.PVEcontent.RG.bahsei.offTankOnly then
        if CitizenAddon.PVEcontent.RG.bahsei.offTankDisplayName == targetUnitDisplayName then
            table.insert(bahsei.bleed, currentTime+10)
            EVENT_MANAGER:RegisterForUpdate(CitizenRG.name .."BleedCheck", 200, BleedChecker)
        end
    elseif CitizenAddon.PVEcontent.RG.bahsei.bleedTracker then
        table.insert(bahsei.bleed, currentTime+10)
        EVENT_MANAGER:RegisterForUpdate(CitizenRG.name .."BleedCheck", 200, BleedChecker)
    end
end

--Bahsei OSI death touch
---CitizenRG.name .."BahseiDeathTouchOSI", EVENT_EFFECT_CHANGED
    --UNIT_TAG_PREFIX, 'group'
    --ABILITY_ID, 150078
local function BahseiDeathTouch(_, changeType, _, _, unitTag, _, _, _, _, _, _, _, _, _, _, _, _)
    if changeType == EFFECT_RESULT_GAINED then
        CitizenNotifier.Icon(GetUnitDisplayName(unitTag), CitizenMarker.iconData[13], nil, {0,1,1}, nil, nil, {9000,true})
    elseif changeType == EFFECT_RESULT_FADED then
        CitizenNotifier.RemoveIcon(GetUnitDisplayName(unitTag))
    end
end

--Oax OSI poison
---CitizenRG.name .."OaxPoisonOSI", EVENT_EFFECT_CHANGED
    --UNIT_TAG_PREFIX, 'group'
    --ABILITY_ID, 157860
local function OaxPoison(_, changeType, _, _, unitTag, _, _, _, _, _, _, _, _, _, _, _, _)
    if changeType == EFFECT_RESULT_GAINED then
        CitizenNotifier.Icon(GetUnitDisplayName(unitTag), CitizenMarker.iconData[13], CitizenAddon.PVEcontent.RG.oax.poisonOsiIconSize, {0,1,0}, nil, nil, nil)
    elseif changeType == EFFECT_RESULT_FADED then
        CitizenNotifier.RemoveIcon(GetUnitDisplayName(unitTag))
    end
end

local function MoulderingTaintTracker(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _)
    local MTTtime = (GetGameTimeMilliseconds()/1000) + 3.5 --Its a changable number between 2.506s and 3.12s based on something I could not find accorind to Logs, so I played it safe
    bahsei.MTTstack = bahsei.MTTstack + 1

    CitizenMTT_Stack:SetText(bahsei.MTTstack)
    CitizenMTT_Stack:SetColor(1, 1, 1, 1)

    EVENT_MANAGER:RegisterForUpdate(CitizenRG.name .."MTTRefresh", 100, function ()
        local timeLeft = MTTtime - (GetGameTimeMilliseconds()/1000)
        CitizenMTT_Timer:SetText(string.format("%.1f", timeLeft).."s")
        if timeLeft <= 0 then
            EVENT_MANAGER:UnregisterForUpdate(CitizenRG.name .."MTTRefresh")
            bahsei.MTTstack = 0
            CitizenMTT_Timer:SetText("0s")
            CitizenMTT_Stack:SetText("0")
            CitizenMTT_Stack:SetColor(0, 0.8, 0, 1)
        end
    end)
end

local function MoulderingTaintTrackerUI()
    if _G["CitizenMTT"] then
        return
    else
        local CitizenMTT = CreateControl("CitizenMTT", GuiRoot, CT_TOPLEVELCONTROL)
        CitizenMTT:SetDimensions(54, 64)
        CitizenMTT:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CitizenAddon.PVEcontent.RG.bahsei.moulderingTaintLeft, CitizenAddon.PVEcontent.RG.bahsei.moulderingTaintTop)
        CitizenMTT:SetMouseEnabled(true)
        CitizenMTT:SetMovable(true)
        CitizenMTT:SetClampedToScreen(true)
        CitizenMTT:SetDrawTier(DT_MEDIUM)
        CitizenMTT:SetHidden(false)
        CitizenMTT:SetHandler("OnMoveStop", function ()
            CitizenAddon.PVEcontent.RG.bahsei.moulderingTaintLeft = CitizenMTT:GetLeft()
            CitizenAddon.PVEcontent.RG.bahsei.moulderingTaintTop = CitizenMTT:GetTop()
        end)
        -- Border Backdrop
        local border = CreateControl("CitizenMTT_Border", CitizenMTT, CT_BACKDROP)
        border:SetDimensions(54, 64)
        border:SetAnchor(CENTER, CitizenMTT, CENTER, 0, 0)
        border:SetEdgeTexture("", 1, 1, 3)
        border:SetCenterColor(0.2, 0, 0.3, 0.7)
        border:SetEdgeColor(0.2, 0.5, 0.3, 0.7)
        -- Main Text Label
        local stackLabel = CreateControl("CitizenMTT_Stack", CitizenMTT, CT_LABEL)
        stackLabel:SetFont("$(MEDIUM_FONT)|40|thin-outline")
        stackLabel:SetColor(0, 0.8, 0, 1)
        stackLabel:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
        stackLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        stackLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        stackLabel:SetText("0")
        stackLabel:SetAnchor(TOP, CitizenMTT, TOP, 0, -2)
        -- Timer Label
        local timerLabel = CreateControl("CitizenMTT_Timer", CitizenMTT, CT_LABEL)
        timerLabel:SetFont("$(BOLD_FONT)|15|thin-outline")
        timerLabel:SetColor(1, 1, 1, 1)
        timerLabel:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
        timerLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        timerLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        timerLabel:SetText("0s")
        timerLabel:SetAnchor(BOTTOM, border, BOTTOM, 0, -5)
        -- Name text Label
        local nameLabel = CreateControl("CitizenMTT_Name", CitizenMTT, CT_LABEL)
        nameLabel:SetFont("$(BOLD_FONT)|13|thin-outline")
        nameLabel:SetColor(1, 1, 1, 1)
        nameLabel:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
        nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        nameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        nameLabel:SetText("Mouldering Taint")
        nameLabel:SetAnchor(BOTTOM, CitizenMTT, TOP, 0, 0)

        bahsei.MTTfragment = ZO_SimpleSceneFragment:New(CitizenMTT)
    end
end

--Is player in combat with correct target
---CitizenAddon.name .."InCombatInRG", EVENT_PLAYER_COMBAT_STATE
function CitizenRG.CombatState(_, inCombat)
    if inCombat then
        if DoesUnitExist('boss1') then
            if GetUnitName('boss1') == "Oaxiltso" then
                if CitizenAddon.PVEcontent.RG.oax.poisonOsi then
                    EVENT_MANAGER:RegisterForEvent(CitizenRG.name .."OaxPoisonOSI", EVENT_EFFECT_CHANGED, OaxPoison)--FILTERS
                        EVENT_MANAGER:AddFilterForEvent(CitizenRG.name .."OaxPoisonOSI", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, 'group')
                        EVENT_MANAGER:AddFilterForEvent(CitizenRG.name .."OaxPoisonOSI", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 157860)
                    --
                end
            elseif GetUnitName('boss1') == "Flame-Herald Bahsei" then
                if CitizenAddon.PVEcontent.RG.bahsei.deathTouchOsi then
                    EVENT_MANAGER:RegisterForEvent(CitizenRG.name .."BahseiDeathTouchOSI", EVENT_EFFECT_CHANGED, BahseiDeathTouch)--FILTERS
                        EVENT_MANAGER:AddFilterForEvent(CitizenRG.name .."BahseiDeathTouchOSI", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, 'group')
                        EVENT_MANAGER:AddFilterForEvent(CitizenRG.name .."BahseiDeathTouchOSI", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 150078)
                    --
                end
                if CitizenAddon.PVEcontent.RG.bahsei.bleedTracker or CitizenAddon.PVEcontent.RG.bahsei.bleedOsi then
                    EVENT_MANAGER:RegisterForEvent(CitizenRG.name .."BleedTrace", EVENT_COMBAT_EVENT, BleedTracker)--FILTERS
                        EVENT_MANAGER:AddFilterForEvent(CitizenRG.name .."BleedTrace", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
                        EVENT_MANAGER:AddFilterForEvent(CitizenRG.name .."BleedTrace", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 150008)
                    --
                end
            end
        end
    else
        Unregistor()
    end
end

--Boss changed
---CitizenAddon.name .."BossChangedInRG", EVENT_BOSSES_CHANGED
function CitizenRG.BossChanged(_, _)
    if GetUnitName('boss1') == "Flame-Herald Bahsei" then
        if CitizenAddon.PVEcontent.RG.bahsei.moulderingTaint then
            MoulderingTaintTrackerUI()
            HUD_SCENE:AddFragment(bahsei.MTTfragment)
            HUD_UI_SCENE:AddFragment(bahsei.MTTfragment)
            EVENT_MANAGER:RegisterForEvent("MoulderingTaintTracker", EVENT_COMBAT_EVENT, MoulderingTaintTracker)--FILTERS
                EVENT_MANAGER:AddFilterForEvent("MoulderingTaintTracker", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 150002)
                EVENT_MANAGER:AddFilterForEvent("MoulderingTaintTracker", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DAMAGE)
                EVENT_MANAGER:AddFilterForEvent("MoulderingTaintTracker", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
            --
        end
    else
        HUD_SCENE:RemoveFragment(bahsei.MTTfragment)
        HUD_UI_SCENE:RemoveFragment(bahsei.MTTfragment)
    end
end
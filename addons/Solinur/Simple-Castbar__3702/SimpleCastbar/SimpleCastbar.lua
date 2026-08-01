local em = GetEventManager()
local _
local dx = 1 / (tonumber(GetCVar("WindowedWidth")) / GuiRoot:GetWidth())
SIMPLE_CASTBAR_LINE_SIZE = tostring(dx)

SCB = SCB or {}
local SCB = SCB

SCB.name = "SimpleCastbar"
SCB.version = "1.3.4"
SCB.internal = {}
local SCBint = SCB.internal
SCBint.isCastbarMoveable = false

local LC = LibCombat
if not LibCombat then return end

local GetFormattedAbilityName = LC.GetFormattedAbilityName
local GetFormattedAbilityIcon = LC.GetFormattedAbilityIcon

local dev = false or GetDisplayName() == "@Solinur"

local function Print(message, ...)

    if not dev then return end

    df("[%s] %s", "SCB", message:format(...))

end

local abilityDelayData = {    -- Radiant Destruction and morphs have a 100ms delay after casting. 50ms for Jabs
    [63044] = 100,
    [63029] = 100,
    [63046] = 100,
    -- [26797] = 50,
    -- [38857] = 200
}

local ignoredAbilities = {    -- for stuff that's off the GCD

    [132141] = true,    -- Blood Frenzy (Vampire Toggle)
    [134160] = true,    -- Simmering Frenzy (Vampire Toggle)
    [135841] = true,    -- Sated Fury (Vampire Toggle)

}

local lastSlotUses = {}

for i = 3,8 do

    lastSlotUses[i] = 0
    lastSlotUses[i+10] = 0

end

local lastQueuedAbilities = {}

local red = ZO_ColorDef:New(1, 0, 0)
local green = ZO_ColorDef:New(0, 0.95, 0.1)
local yellow = ZO_ColorDef:New(1, 1, 0)
local grey = ZO_ColorDef:New(.4, .4, .4)

local isLastAttackLightAttack = false
local lastSkillEnd = 0
local secondLastSkillEnd = 0

local function OnSkillEvent(_, timems, reducedslot, abilityId, status, _, castTime)

    local timerbar = SCBint.timerbar
    local timerbarControl = timerbar.control
    ---@type StatusBarControl
    local barControl = timerbarControl:GetNamedChild("Status")
    local slot = reducedslot % 10

    if status == LIBCOMBAT_SKILLSTATUS_REGISTERED then

        lastSlotUses[reducedslot] = timems

        local lineControl = timerbarControl:GetNamedChild(slot == 1 and "LineLA" or "LineSkill")

        local min, max = barControl:GetMinMax()

        local pos = barControl:GetValue()/(max-min) * barControl:GetWidth()

        Print("val: %.3f (%.3f/%.3f)", barControl:GetValue()/(max-min), barControl:GetValue(), (max-min))

        lineControl:ClearAnchors()
        lineControl:SetAnchor(TOP, barControl, TOPLEFT, pos)
        lineControl:SetAnchor(BOTTOM, barControl, BOTTOMLEFT, pos)
        lineControl:SetAlpha(1)

        return

    elseif status == LIBCOMBAT_SKILLSTATUS_QUEUE then

        lastQueuedAbilities[abilityId] = timems
        return

    end

    local lineControl = timerbarControl:GetNamedChild("LineDelay")

    if slot == 1 then

        isLastAttackLightAttack = true

    else

        local abilityName = GetFormattedAbilityName(abilityId)

        local totalDuration = 1000

        if status == LIBCOMBAT_SKILLSTATUS_BEGIN_DURATION or status == LIBCOMBAT_SKILLSTATUS_BEGIN_CHANNEL then
            local _, durationValue = GetAbilityCastInfo(abilityId)
            if castTime and castTime > 0 then durationValue = castTime end

            local abilityDuration = math.max(durationValue or 0, 1000)
            local abilityDelay = abilityDelayData[abilityId] or 0
            local latencyOffset = GetLatency()/2

            totalDuration = abilityDuration + abilityDelay + latencyOffset

        end

        local endTime = timems + totalDuration

        timerbar:SetLabel(abilityName)

        timerbarControl:GetNamedChild("Icon"):SetTexture(GetFormattedAbilityIcon(abilityId))

        if status == LIBCOMBAT_SKILLSTATUS_SUCCESS then

            Print("%s ends", abilityName)

            return

        elseif status <= 4 then

            timerbar:Start(timems / 1000, endTime / 1000)

            Print("%s starts", abilityName)

            local LAline = timerbarControl:GetNamedChild("LineLA")
            local SkillLine = timerbarControl:GetNamedChild("LineSkill")

            if LAline:GetAlpha() < 0.9 then LAline:SetAlpha(0) else LAline:SetAlpha(0.8) end
            if SkillLine:GetAlpha() < 0.9 then SkillLine:SetAlpha(0) else SkillLine:SetAlpha(0.8) end

        end

        local useTime = math.max(lastSlotUses[reducedslot], lastQueuedAbilities[abilityId] or 0)

        local offsetTime = useTime and (useTime + totalDuration) or endTime

        if offsetTime > (timems + 400) then

            local relPos = math.min(math.max((offsetTime - timems)/(endTime - timems),0),1)

            local LAtime = timems - lastSkillEnd
            local color = isLastAttackLightAttack and (LAtime < SCBint.sv.maxGoodWeavingDelay and green or yellow) or red

            local pos = barControl:GetWidth() * relPos

            lineControl:ClearAnchors()
            lineControl:SetAnchor(TOP, barControl, TOPLEFT, pos)
            lineControl:SetAnchor(BOTTOM, barControl, BOTTOMLEFT, pos)
            lineControl:SetHidden(false)
            timerbarControl:GetNamedChild("Backdrop"):SetEdgeColor(color:UnpackRGB())

        else

            timerbarControl:GetNamedChild("LineDelay"):SetHidden(true)

        end

        isLastAttackLightAttack = false
        secondLastSkillEnd = lastSkillEnd
        lastSkillEnd = endTime

    end
end

local remainingUntilUpdate

local function TimerBarUpdate(self, time) -- rewrite of original function from ZOS

    if time > self.ends then

        self:Stop()
        return

    end

    local barReady = time > self.nextBarUpdate
    local labelReady = self.time and time > self.nextLabelUpdate

    if not (barReady or labelReady) then return end

    local timeString = ""

    if self.direction == TIMER_BAR_COUNTS_UP then

        local totalElapsed = time - self.starts - self.pauseElapsed

        if barReady then self.status:SetValue(totalElapsed) end

        if labelReady then

            timeString, remainingUntilUpdate =
                ZO_FormatTime(totalElapsed, self.timeFormatStyle,
                              self.timePrecision,
                              TIME_FORMAT_DIRECTION_ASCENDING)
            self.time:SetText(timeString)

        end

    else

        local totalRemaining = self.ends - time

        if barReady then self.status:SetValue(totalRemaining) end

        local totalRemainingRounded = zo_roundToNearest(totalRemaining, 0.1)

        if labelReady then

            timeString, remainingUntilUpdate =
                ZO_FormatTime(totalRemainingRounded, self.timeFormatStyle,
                              self.timePrecision,
                              TIME_FORMAT_DIRECTION_DESCENDING)
            self.time:SetText(timeString)

        end

    end

    if barReady then self.nextBarUpdate = time + self.barUpdateInterval end

    if labelReady then self.nextLabelUpdate = math.ceil(time * 10) / 10 end
end

-- Addon settings menu

local function SetAccountwideSV(value)

    local svChar = SCBint.svChar
    local svAcc = SCBint.svAcc

    if value == false then
        SCBint.svChar = ZO_DeepTableCopy(SCBint.svAcc)
        svChar.accountWide = false
        SCBint.sv = svChar
    elseif value == true then
        svChar.accountWide = true
        SCBint.sv = svAcc
    end
end

local emKeyHideDelayed = SCB.name .. "_HideCastbarDelayed"  -- key for registering delayed hiding of the cast bar

local function ToggleCastbarMoveable()

    if SCBint.isCastbarMoveable == true then

        em:UnregisterForUpdate(emKeyHideDelayed)
        SimpleCastbar_TLW:SetMouseEnabled(true)
        SimpleCastbar_TLW:SetMovable(true)
        SimpleCastbar_TLW:SetHidden(false)

    else

        SimpleCastbar_TLW:SetMouseEnabled(false)
        SimpleCastbar_TLW:SetMovable(false)
        SimpleCastbar_TLW:SetHidden(true)

    end
end

local function TemporaryShowCastbar(hideDelay)

    SimpleCastbar_TLW:SetHidden(false)
    em:UnregisterForUpdate(emKeyHideDelayed)

    em:RegisterForUpdate(emKeyHideDelayed, hideDelay, function()
        em:UnregisterForUpdate(emKeyHideDelayed)
        if SCBint.isCastbarMoveable == true then return end
        SimpleCastbar_TLW:SetHidden(true)
    end)
end

local function ApplySettingsToCastbar()

    ---@type TopLevelWindow
    local tlw = SimpleCastbar_TLW
    local outerBg = tlw:GetNamedChild("Backdrop2")

    local timeLabel = tlw:GetNamedChild("Time")
    local icon = tlw:GetNamedChild("Icon")

    local abilityLabel = tlw:GetNamedChild("Label")

    tlw:SetAnchor(BOTTOM, GuiRoot, BOTTOM, SCBint.sv.castbarPosX, SCBint.sv.castbarPosY)

    outerBg:SetHidden(SCBint.sv.hideOuterBg)

    local scale = SCBint.sv.castbarSize / 100
    tlw:SetDimensions(300 * scale, 32 * scale)
    outerBg:SetAnchor(BOTTOMRIGHT, nil, nil, 100 * scale, 4)
    timeLabel:SetWidth(50*scale)
    icon:SetDimensions(32*scale-8, 32*scale-8)
    abilityLabel:SetAnchor(TOPLEFT, nil, nil, 32 * scale)

    local fontsize = math.floor(scale*20)
    local fontstring = string.format("$(MEDIUM_FONT)|$(KB_%d)|soft-shadow-thin", fontsize)

    timeLabel:SetFont(fontstring)
    abilityLabel:SetFont(fontstring)

end

local svdefaults = {
    ["accountWide"] = false,
    ["hideOuterBg"] = false,
    ["castbarSize"] = 100,
    ["castbarPosX"] = 0,
    ["castbarPosY"] = -160,
    ["maxGoodWeavingDelay"] = 80,
}

local function MakeMenu()
    -- load the settings->addons menu library
    local menu = LibAddonMenu2
    if not LibAddonMenu2 then return end
    local def = svdefaults
    local sv = SCBint.sv

    -- the panel for the addons menu
    local panel = {
        type = "panel",
        name = "SimpleCastbar",
        displayName = "SimpleCastbar",
        author = "Solinur",
        version = SCB.version or "",
        registerForRefresh = false,
    }

    SCBint.addonpanel = menu:RegisterAddonPanel("SimpleCastbar_Menu", panel)

    --this adds entries in the addon menu
    local options = {
        {
            type = "checkbox",
            name = GetString(SCB_STRING_MENU_ACCOUNTWIDE),
            default = def.accountwide,
            getFunc = function() return SCBint.svChar.accountWide end,
            setFunc = function(value) SetAccountwideSV(value) end,
        },
        {
            type = "checkbox",
            name = GetString(SCB_STRING_MENU_UNLOCK),
            tooltip = GetString(SCB_STRING_MENU_UNLOCK_TOOLTIP),
            default = false,
            getFunc = function() return SCBint.isCastbarMoveable end,
            setFunc = function(value)
                SCBint.isCastbarMoveable = value
                ToggleCastbarMoveable()
            end,
        },
        {
            type = "checkbox",
            name = GetString(SCB_STRING_MENU_HIDEOUTERBG),
            tooltip = GetString(SCB_STRING_MENU_HIDEOUTERBG_TOOLTIP),
            default = def.accountwide,
            getFunc = function() return sv.hideOuterBg end,
            setFunc = function(value)
                SCBint.sv.hideOuterBg = value
                ApplySettingsToCastbar()
                TemporaryShowCastbar(5000)
            end
        },
        {
            type = "slider",
            name = GetString(SCB_STRING_MENU_CASTBARSIZE),
            tooltip = GetString(SCB_STRING_MENU_CASTBARSIZE_TOOLTIP),
            min = 50,
            max = 200,
            step = 5,
            default = def.castbarSize,
            getFunc = function() return sv.castbarSize end,
            setFunc = function(value)

                sv.castbarSize = value
                ApplySettingsToCastbar()
                TemporaryShowCastbar(5000)

            end,
        },
        {
            type = "slider",
            name = GetString(SCB_STRING_MENU_WEAVE_THRESHOLD),
            tooltip = GetString(SCB_STRING_MENU_WEAVE_THRESHOLD_TOOLTIP),
            min = 0,
            max = 200,
            step = 10,
            default = def.maxGoodWeavingDelay,
            getFunc = function() return sv.maxGoodWeavingDelay end,
            setFunc = function(value) sv.maxGoodWeavingDelay = value end,
        },
    }

    menu:RegisterOptionControls("SimpleCastbar_Menu", options)
end

local function InitializeCastBar()
    ---@type TopLevelWindow
    local tlw = SimpleCastbar_TLW

    SCBint.timerbar = ZO_TimerBar:New(tlw)
    SCBint.timerbar:SetTimeFormatParameters(
        TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL_SHOW_TENTHS_SECS,
        TIME_FORMAT_PRECISION_MILLISECONDS)
    SCBint.timerbar.Update = TimerBarUpdate

    ---@diagnostic disable-next-line: missing-parameter
    tlw:SetHandler("OnMoveStop", function(self)

        local bottom = tlw:GetBottom()
        local left = tlw:GetLeft()
        local right = tlw:GetRight()

        SCBint.sv.castbarPosX = (left + right - GuiRoot:GetWidth())/2
        SCBint.sv.castbarPosY = bottom - GuiRoot:GetHeight()

    end)

        ---@diagnostic disable-next-line: missing-parameter
        tlw:SetHandler("OnHide", function()
            SCBint.isCastbarMoveable = false
            ToggleCastbarMoveable()
        end)

    ApplySettingsToCastbar()
end

local function Initialize(event, addon)

    if addon ~= SCB.name then return end

    SCBint.svChar = ZO_SavedVars:NewCharacterIdSettings("SimpleCastbarSV", 1, "Settings", svdefaults)
    SCBint.svAcc = ZO_SavedVars:NewAccountWide("SimpleCastbarSV", 1, "Settings", svdefaults)
    SCBint.sv = SCBint.svChar.accountWide and SCBint.svAcc or SCBint.svChar

    LC:RegisterForCombatEvent(SCB.name, LIBCOMBAT_EVENT_SKILL_TIMINGS, OnSkillEvent)

    InitializeCastBar()
    MakeMenu()

    SLASH_COMMANDS["/scb"] = function() LibAddonMenu2:OpenToPanel(SCBint.addonpanel) end

    em:UnregisterForEvent(SCB.name, EVENT_ADD_ON_LOADED)

end

em:RegisterForEvent(SCB.name, EVENT_ADD_ON_LOADED, Initialize)

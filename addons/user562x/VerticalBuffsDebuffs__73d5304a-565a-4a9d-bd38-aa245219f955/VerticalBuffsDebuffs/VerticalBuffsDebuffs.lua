VerticalBuffsDebuffs = {}
VerticalBuffsDebuffs.name = "VerticalBuffsDebuffs"
VerticalBuffsDebuffs.savedVariables = nil
VerticalBuffsDebuffs.previewMode = false

local activeBuffs   = {}
local activeDebuffs = {}

local buffRows   = {}
local debuffRows = {}

local SIDE_MARGIN    = 8
local MAX_EFFECTS    = 30
local SHOW_THRESHOLD = 60

local ORANGE_THRESHOLD = 0.50
local RED_THRESHOLD    = 0.25

local PREVIEW_EFFECTS = {
    { name = "Major Sorcery",   duration = 20, elapsed = 2  },
    { name = "Minor Brutality", duration = 20, elapsed = 8  },
    { name = "Major Resolve",   duration = 20, elapsed = 12 },
    { name = "Minor Endurance", duration = 20, elapsed = 16 },
    { name = "Major Fortitude", duration = 20, elapsed = 18 },
}

--------------------------------------------------
-- Timer Color (percentage based)
--------------------------------------------------
local function GetTimerColor(remaining, totalDuration)
    if totalDuration <= 0 then
        return 0.2, 1.0, 0.2
    end

    local pct = remaining / totalDuration

    if pct <= RED_THRESHOLD then
        return 1.0, 0.2, 0.2
    elseif pct <= ORANGE_THRESHOLD then
        return 1.0, 0.55, 0.0
    else
        return 0.2, 1.0, 0.2
    end
end

--------------------------------------------------
-- Font / Size
--------------------------------------------------
function VerticalBuffsDebuffs:GetFont()
    return string.format(
        "EsoUI/Common/Fonts/univers67.otf|%d|soft-shadow-thick",
        self.savedVariables.fontSize
    )
end

function VerticalBuffsDebuffs:GetRowHeight()
    return self.savedVariables.fontSize + 20
end

function VerticalBuffsDebuffs:GetIconSize()
    return math.floor(self.savedVariables.fontSize * 1.60)
end

--------------------------------------------------
-- Apply Panel Positions
--------------------------------------------------
function VerticalBuffsDebuffs:ApplyBuffPosition()
    self.buffPanel:ClearAnchors()
    self.buffPanel:SetAnchor(
        TOPLEFT, GuiRoot, TOPLEFT,
        self.savedVariables.buffPosX,
        self.savedVariables.buffPosY
    )
end

function VerticalBuffsDebuffs:ApplyDebuffPosition()
    self.debuffPanel:ClearAnchors()
    self.debuffPanel:SetAnchor(
        TOPLEFT, GuiRoot, TOPLEFT,
        self.savedVariables.debuffPosX,
        self.savedVariables.debuffPosY
    )
end

--------------------------------------------------
-- Create Panels
--------------------------------------------------
function VerticalBuffsDebuffs:CreatePanels()
    self.buffPanel = WINDOW_MANAGER:CreateTopLevelWindow("VerticalBuffsDebuffs_BuffPanel")
    self.buffPanel:SetClampedToScreen(true)
    self.buffPanel:SetDrawLayer(DL_BACKGROUND)
    self.buffPanel:SetDrawTier(DT_LOW)
    self.buffPanel:SetHidden(true)
    self:ApplyBuffPosition()

    self.debuffPanel = WINDOW_MANAGER:CreateTopLevelWindow("VerticalBuffsDebuffs_DebuffPanel")
    self.debuffPanel:SetClampedToScreen(true)
    self.debuffPanel:SetDrawLayer(DL_BACKGROUND)
    self.debuffPanel:SetDrawTier(DT_LOW)
    self.debuffPanel:SetHidden(true)
    self:ApplyDebuffPosition()
end

--------------------------------------------------
-- Create Effect Row
--------------------------------------------------
function VerticalBuffsDebuffs:CreateEffectRow(parent, index)
    local rowHeight = self:GetRowHeight()
    local iconSize  = self:GetIconSize()
    local yOff      = (index - 1) * rowHeight

    local row = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, yOff)
    row:SetDimensions(400, rowHeight)

    local icon = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
    icon:SetDimensions(iconSize, iconSize)
    icon:SetAnchor(LEFT, row, LEFT, SIDE_MARGIN, 0)
    row.icon = icon

    local nameLabel = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    nameLabel:SetFont(self:GetFont())
    nameLabel:SetAnchor(LEFT, icon, RIGHT, 6, 0)
    nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.nameLabel = nameLabel

    local timerLabel = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    timerLabel:SetFont(self:GetFont())
    timerLabel:SetAnchor(LEFT, nameLabel, RIGHT, 8, 0)
    timerLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.timerLabel = timerLabel

    row:SetHidden(true)
    return row
end

--------------------------------------------------
-- Build Row Pools
--------------------------------------------------
function VerticalBuffsDebuffs:BuildRowPools()
    for _, row in ipairs(buffRows) do
        row:SetHidden(true)
        row:SetParent(nil)
        row:ClearAnchors()
    end
    for _, row in ipairs(debuffRows) do
        row:SetHidden(true)
        row:SetParent(nil)
        row:ClearAnchors()
    end

    buffRows   = {}
    debuffRows = {}

    for i = 1, MAX_EFFECTS do
        buffRows[i]   = self:CreateEffectRow(self.buffPanel,   i)
        debuffRows[i] = self:CreateEffectRow(self.debuffPanel, i)
    end
end

--------------------------------------------------
-- Render Row Pool
--------------------------------------------------
function VerticalBuffsDebuffs:RenderRows(rowPool, effectsList, isDebuff)
    local nameR, nameG, nameB = 0.2, 1.0, 0.2
    if isDebuff then
        nameR, nameG, nameB = 1.0, 0.2, 0.2
    end

    local fullFont    = self:GetFont()
    local smallFont   = string.format(
        "EsoUI/Common/Fonts/univers67.otf|%d|soft-shadow-thick",
        math.max(10, math.floor(self.savedVariables.fontSize * 0.5))
    )
    local fullIcon    = self:GetIconSize()
    local smallIcon   = math.max(8, math.floor(fullIcon * 0.5))
    local fullHeight  = self:GetRowHeight()
    local smallHeight = math.max(12, math.floor(fullHeight * 0.5))

    local showText = isDebuff and self.savedVariables.showDebuffText
                              or self.savedVariables.showBuffText

    local visible = 0
    local yOffset = 0

    for i, row in ipairs(rowPool) do
        local entry = effectsList[i]
        if entry then
            local isSmall  = self.savedVariables.scaleOverflow and (i > 10)
            local font     = isSmall and smallFont or fullFont
            local iconSize = isSmall and smallIcon or fullIcon
            local rowH     = isSmall and smallHeight or fullHeight

            row:ClearAnchors()
            row:SetAnchor(TOPLEFT, row:GetParent(), TOPLEFT, 0, yOffset)
            row:SetDimensions(400, rowH)

            row.icon:SetDimensions(iconSize, iconSize)
            if entry.fx.icon then
                row.icon:SetTexture(entry.fx.icon)
                row.icon:SetHidden(false)
            else
                row.icon:SetHidden(true)
            end

            if showText then
                row.nameLabel:SetFont(font)
                row.nameLabel:SetText(entry.fx.name)
                row.nameLabel:SetColor(nameR, nameG, nameB, 1)
                row.nameLabel:SetHidden(false)
                row.timerLabel:ClearAnchors()
                row.timerLabel:SetAnchor(LEFT, row.nameLabel, RIGHT, 8, 0)
            else
                row.nameLabel:SetHidden(true)
                row.timerLabel:ClearAnchors()
                row.timerLabel:SetAnchor(LEFT, row.icon, RIGHT, 8, 0)
            end

            row.timerLabel:SetFont(font)
            if entry.fx.isPermanent then
                row.timerLabel:SetText("∞")
                row.timerLabel:SetColor(nameR, nameG, nameB, 1)
            else
                row.timerLabel:SetText(
                    string.format("%.1fs", math.max(entry.remaining, 0))
                )
                local tr, tg, tb = GetTimerColor(entry.remaining, entry.fx.totalDuration)
                row.timerLabel:SetColor(tr, tg, tb, 1)
            end

            row:SetHidden(false)
            visible = visible + 1
            yOffset = yOffset + rowH
        else
            row:SetHidden(true)
        end
    end

    return visible, yOffset
end

--------------------------------------------------
-- Refresh Display
--------------------------------------------------
function VerticalBuffsDebuffs:RefreshDisplay()
    local now           = GetGameTimeSeconds()
    local buffsToShow   = {}
    local debuffsToShow = {}

    if self.previewMode then
        for _, fx in ipairs(PREVIEW_EFFECTS) do
            local remaining = fx.duration - fx.elapsed
            local entry = {
                remaining = remaining,
                fx = {
                    name          = fx.name,
                    icon          = nil,
                    isPermanent   = false,
                    totalDuration = fx.duration,
                },
            }
            table.insert(buffsToShow,   entry)
            table.insert(debuffsToShow, entry)
        end
    else
        for slot, fx in pairs(activeBuffs) do
            local remaining = fx.endTime - now
            if remaining > 0 and remaining <= SHOW_THRESHOLD then
                table.insert(buffsToShow, { remaining = remaining, fx = fx })
            end
        end

        for slot, fx in pairs(activeDebuffs) do
            local remaining = fx.endTime - now
            if remaining > 0 and remaining <= SHOW_THRESHOLD then
                table.insert(debuffsToShow, { remaining = remaining, fx = fx })
            end
        end

        table.sort(buffsToShow,   function(a, b) return a.remaining < b.remaining end)
        table.sort(debuffsToShow, function(a, b) return a.remaining < b.remaining end)
    end

    local buffVisible,   buffHeight   = self:RenderRows(buffRows,   buffsToShow,   false)
    local debuffVisible, debuffHeight = self:RenderRows(debuffRows, debuffsToShow, true)

    self.buffPanel:SetHidden(not self.savedVariables.showBuffs or buffVisible == 0)
    if self.savedVariables.showBuffs and buffVisible > 0 then
        self.buffPanel:SetDimensions(400, buffHeight)
    end

    self.debuffPanel:SetHidden(not self.savedVariables.showDebuffs or debuffVisible == 0)
    if self.savedVariables.showDebuffs and debuffVisible > 0 then
        self.debuffPanel:SetDimensions(400, debuffHeight)
    end
end

--------------------------------------------------
-- EVENT_EFFECT_CHANGED Handler
--------------------------------------------------
function VerticalBuffsDebuffs:OnEffectChanged(eventCode, changeType, effectSlot, effectName,
    unitTag, beginTime, endTime, stackCount, iconName, buffType,
    effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType)

    if unitTag ~= "player" then return end

    local isPermanent   = (endTime == 0)
    local totalDuration = endTime - beginTime

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        local entry = {
            name          = effectName,
            icon          = iconName,
            endTime       = endTime,
            isPermanent   = isPermanent,
            totalDuration = totalDuration,
        }
        if effectType == BUFF_EFFECT_TYPE_DEBUFF then
            activeDebuffs[effectSlot] = entry
            activeBuffs[effectSlot]   = nil
        else
            activeBuffs[effectSlot]   = entry
            activeDebuffs[effectSlot] = nil
        end

    elseif changeType == EFFECT_RESULT_FADED then
        activeBuffs[effectSlot]   = nil
        activeDebuffs[effectSlot] = nil
    end
end

--------------------------------------------------
-- Initial Effect Scan
--------------------------------------------------
function VerticalBuffsDebuffs:ScanExistingEffects()
    local numEffects = GetNumBuffs("player")
    for i = 1, numEffects do
        local name, startTime, endTime, stackCount, effectType, iconName =
            GetUnitBuffInfo("player", i)
        if name and name ~= "" then
            local isPermanent   = (endTime == 0)
            local totalDuration = endTime - startTime
            local entry = {
                name          = name,
                icon          = iconName,
                endTime       = endTime,
                isPermanent   = isPermanent,
                totalDuration = totalDuration,
            }
            if effectType == BUFF_EFFECT_TYPE_DEBUFF then
                activeDebuffs[i] = entry
            else
                activeBuffs[i] = entry
            end
        end
    end
end

--------------------------------------------------
-- Scene Handling
--------------------------------------------------
function VerticalBuffsDebuffs:InitializeSceneHiding()

    local function OnSceneStateChange(oldState, newState)
        if newState == SCENE_SHOWING then
            VerticalBuffsDebuffs.buffPanel:SetHidden(true)
            VerticalBuffsDebuffs.debuffPanel:SetHidden(true)
        elseif newState == SCENE_HIDDEN then
            VerticalBuffsDebuffs:RefreshDisplay()
        end
    end

    if SCENE_MANAGER:GetScene("worldMap") then
        SCENE_MANAGER:GetScene("worldMap"):RegisterCallback("StateChange", OnSceneStateChange)
    end

    if SCENE_MANAGER:GetScene("gameMenuInGame") then
        SCENE_MANAGER:GetScene("gameMenuInGame"):RegisterCallback("StateChange", OnSceneStateChange)
    end

end

--------------------------------------------------
-- Settings
--------------------------------------------------
function VerticalBuffsDebuffs:CreateSettings()
    local LAM = LibAddonMenu2

    local panelData = {
        type               = "panel",
        name               = "Vertical Buffs Debuffs",
        displayName        = "Vertical Buffs Debuffs",
        author             = "user562",
        version            = "1.4",
        registerForRefresh = true,
    }

    LAM:RegisterAddonPanel("VerticalBuffsDebuffs_Settings", panelData)

    local options = {

        {
            type    = "checkbox",
            name    = "Preview",
            getFunc = function() return self.previewMode end,
            setFunc = function(val)
                self.previewMode = val
                self:RefreshDisplay()
            end,
        },

        { type = "divider" },

        {
            type    = "checkbox",
            name    = "Enable |c33FF33Buff|r Panel",
            getFunc = function() return self.savedVariables.showBuffs end,
            setFunc = function(val)
                self.savedVariables.showBuffs = val
                self:RefreshDisplay()
            end,
        },
        {
            type    = "checkbox",
            name    = "Show Text",
            getFunc = function() return self.savedVariables.showBuffText end,
            setFunc = function(val)
                self.savedVariables.showBuffText = val
                self:RefreshDisplay()
            end,
        },
        {
            type    = "slider",
            name    = "Horizontal Position",
            min     = 0, max = 3000, step = 10,
            getFunc = function() return self.savedVariables.buffPosX end,
            setFunc = function(val)
                self.savedVariables.buffPosX = val
                self:ApplyBuffPosition()
            end,
        },
        {
            type    = "slider",
            name    = "Vertical Position",
            min     = 0, max = 2000, step = 10,
            getFunc = function() return self.savedVariables.buffPosY end,
            setFunc = function(val)
                self.savedVariables.buffPosY = val
                self:ApplyBuffPosition()
            end,
        },

        { type = "divider" },

        {
            type    = "checkbox",
            name    = "Enable |cFF3333Debuff|r Panel",
            getFunc = function() return self.savedVariables.showDebuffs end,
            setFunc = function(val)
                self.savedVariables.showDebuffs = val
                self:RefreshDisplay()
            end,
        },
        {
            type    = "checkbox",
            name    = "Show Text",
            getFunc = function() return self.savedVariables.showDebuffText end,
            setFunc = function(val)
                self.savedVariables.showDebuffText = val
                self:RefreshDisplay()
            end,
        },
        {
            type    = "slider",
            name    = "Horizontal Position",
            min     = 0, max = 3000, step = 10,
            getFunc = function() return self.savedVariables.debuffPosX end,
            setFunc = function(val)
                self.savedVariables.debuffPosX = val
                self:ApplyDebuffPosition()
            end,
        },
        {
            type    = "slider",
            name    = "Vertical Position",
            min     = 0, max = 2000, step = 10,
            getFunc = function() return self.savedVariables.debuffPosY end,
            setFunc = function(val)
                self.savedVariables.debuffPosY = val
                self:ApplyDebuffPosition()
            end,
        },

        { type = "divider" },

        { type = "header", name = "General" },
        {
            type    = "slider",
            name    = "Text Size",
            min     = 18, max = 60, step = 1,
            getFunc = function() return self.savedVariables.fontSize end,
            setFunc = function(val)
                self.savedVariables.fontSize = val
                self:BuildRowPools()
            end,
        },
        {
            type    = "checkbox",
            name    = "1-10 ^ - 11+ 50% Smaller",
            getFunc = function() return self.savedVariables.scaleOverflow end,
            setFunc = function(val)
                self.savedVariables.scaleOverflow = val
            end,
        },
    }

    LAM:RegisterOptionControls("VerticalBuffsDebuffs_Settings", options)
end

--------------------------------------------------
-- Load
--------------------------------------------------
local function OnAddonLoaded(event, addonName)
    if addonName == VerticalBuffsDebuffs.name then

        VerticalBuffsDebuffs.savedVariables = ZO_SavedVars:NewAccountWide(
            "VerticalBuffsDebuffs_SavedVars",
            2,
            nil,
            {
                buffPosX      = 680,
                buffPosY      = 600,
                debuffPosX    = 1470,
                debuffPosY    = 600,
                fontSize      = 31,
                scaleOverflow = false,
                showBuffs     = true,
                showDebuffs   = true,
                showBuffText  = true,
                showDebuffText = true,
            }
        )

        VerticalBuffsDebuffs:CreatePanels()
        VerticalBuffsDebuffs:BuildRowPools()
        VerticalBuffsDebuffs:CreateSettings()
        VerticalBuffsDebuffs:InitializeSceneHiding()

        EVENT_MANAGER:RegisterForEvent(
            VerticalBuffsDebuffs.name,
            EVENT_EFFECT_CHANGED,
            function(...) VerticalBuffsDebuffs:OnEffectChanged(...) end
        )

        EVENT_MANAGER:AddFilterForEvent(
            VerticalBuffsDebuffs.name,
            EVENT_EFFECT_CHANGED,
            REGISTER_FILTER_UNIT_TAG, "player"
        )

        EVENT_MANAGER:RegisterForUpdate(
            VerticalBuffsDebuffs.name,
            100,
            function() VerticalBuffsDebuffs:RefreshDisplay() end
        )

        EVENT_MANAGER:RegisterForEvent(
            VerticalBuffsDebuffs.name,
            EVENT_PLAYER_ACTIVATED,
            function() VerticalBuffsDebuffs:ScanExistingEffects() end
        )

        EVENT_MANAGER:UnregisterForEvent(VerticalBuffsDebuffs.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(VerticalBuffsDebuffs.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

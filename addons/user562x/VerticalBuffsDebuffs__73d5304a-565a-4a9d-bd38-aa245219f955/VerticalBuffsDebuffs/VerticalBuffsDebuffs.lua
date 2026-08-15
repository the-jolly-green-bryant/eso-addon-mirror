VerticalBuffsDebuffs = {}
VerticalBuffsDebuffs.name = "VerticalBuffsDebuffs"
VerticalBuffsDebuffs.savedVariables = nil
VerticalBuffsDebuffs.previewBuffs = false
VerticalBuffsDebuffs.previewDebuffs = false

VerticalBuffsDebuffs.defaults = {
    buffPosX           = 680,
    buffPosY           = 600,
    debuffPosX         = 1470,
    debuffPosY         = 600,
    buffSize           = 31,
    debuffSize         = 31,
    buffScaleOverflow  = false,
    debuffScaleOverflow = false,
    showBuffs          = true,
    showDebuffs        = true,
    showBuffText       = true,
    showDebuffText     = true,
}

local activeBuffs   = {}
local activeDebuffs = {}

local buffBoxes   = {}
local debuffBoxes = {}

local boxCounter = 0

local SIDE_MARGIN    = 8
local BOX_GAP        = 6
local RING_PAD       = 10
local FRAME_PAD      = 14
local MAX_EFFECTS    = 30
local SHOW_THRESHOLD = 60

local NAME_SCALE     = 26 / 31

local PERMANENT_MS   = 3600000

local MOVE_TIMEOUT   = 30000
local MOVE_SNAP      = 10

local ORANGE_THRESHOLD = 0.50
local RED_THRESHOLD    = 0.25

local PREVIEW_EFFECTS = {
    { name = "Major Sorcery",   duration = 20, elapsed = 2,  icon = "/esoui/art/icons/ability_mage_022.dds" },
    { name = "Minor Brutality", duration = 20, elapsed = 8,  icon = "/esoui/art/icons/ability_warrior_003.dds" },
    { name = "Major Resolve",   duration = 20, elapsed = 12, icon = "/esoui/art/icons/ability_armor_002.dds" },
    { name = "Minor Endurance", duration = 20, elapsed = 16, icon = "/esoui/art/icons/ability_rogue_051.dds" },
    { name = "Major Fortitude", duration = 20, elapsed = 18, icon = "/esoui/art/icons/ability_healer_012.dds" },
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
function VerticalBuffsDebuffs:GetFont(size)
    return string.format(
        "EsoUI/Common/Fonts/univers67.otf|%d|soft-shadow-thick",
        size
    )
end

function VerticalBuffsDebuffs:GetNumberFont(iconSize)
    return string.format(
        "EsoUI/Common/Fonts/univers67.otf|%d|outline",
        math.max(12, math.floor(iconSize * 0.5))
    )
end

function VerticalBuffsDebuffs:GetNameFontSize(size)
    return math.max(10, math.floor(size * NAME_SCALE))
end

function VerticalBuffsDebuffs:GetIconSize(size)
    return math.floor(size * 1.60)
end

function VerticalBuffsDebuffs:GetPanelSize(isDebuff)
    if isDebuff then
        return self.savedVariables.debuffSize
    end
    return self.savedVariables.buffSize
end

function VerticalBuffsDebuffs:GetPanelOverflow(isDebuff)
    if isDebuff then
        return self.savedVariables.debuffScaleOverflow
    end
    return self.savedVariables.buffScaleOverflow
end

function VerticalBuffsDebuffs:GetPanelShowText(isDebuff)
    if isDebuff then
        return self.savedVariables.showDebuffText
    end
    return self.savedVariables.showBuffText
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
-- Create Effect Box
--------------------------------------------------
function VerticalBuffsDebuffs:CreateEffectBox(parent)
    boxCounter = boxCounter + 1

    local box = WINDOW_MANAGER:CreateControlFromVirtual(
        "VerticalBuffsDebuffs_Box" .. boxCounter,
        parent,
        "VerticalBuffsDebuffs_EffectBox"
    )

    box.frame     = box:GetNamedChild("Frame")
    box.radial    = box:GetNamedChild("Radial")
    box.inner     = box:GetNamedChild("Inner")
    box.icon      = box:GetNamedChild("Icon")
    box.number    = box:GetNamedChild("Number")
    box.nameLabel = box:GetNamedChild("Name")

    box.cdKey = nil
    box.cdEnd = 0

    box:SetHidden(true)
    return box
end

--------------------------------------------------
-- Size Effect Box
--------------------------------------------------
function VerticalBuffsDebuffs:SizeBox(box, iconSize, nameFont)
    local ringSize  = iconSize + RING_PAD
    local frameSize = iconSize + FRAME_PAD

    box:SetDimensions(frameSize, frameSize)
    box.frame:SetDimensions(frameSize, frameSize)
    box.radial:SetDimensions(ringSize, ringSize)
    box.inner:SetDimensions(iconSize, iconSize)
    box.icon:SetDimensions(iconSize, iconSize)
    box.number:SetDimensions(iconSize, iconSize)
    box.number:SetFont(self:GetNumberFont(iconSize))
    box.nameLabel:SetFont(nameFont)

    return frameSize
end

--------------------------------------------------
-- Build Box Pools
--------------------------------------------------
function VerticalBuffsDebuffs:BuildBoxPools()
    for _, box in ipairs(buffBoxes) do
        box:SetHidden(true)
        box:ClearAnchors()
        box:SetParent(nil)
    end
    for _, box in ipairs(debuffBoxes) do
        box:SetHidden(true)
        box:ClearAnchors()
        box:SetParent(nil)
    end

    buffBoxes   = {}
    debuffBoxes = {}

    for i = 1, MAX_EFFECTS do
        buffBoxes[i]   = self:CreateEffectBox(self.buffPanel)
        debuffBoxes[i] = self:CreateEffectBox(self.debuffPanel)
    end
end

--------------------------------------------------
-- Render Box Pool
--------------------------------------------------
function VerticalBuffsDebuffs:RenderBoxes(boxPool, effectsList, isDebuff)
    local ringR, ringG, ringB = 0.2, 1.0, 0.2
    if isDebuff then
        ringR, ringG, ringB = 1.0, 0.2, 0.2
    end

    local now = GetGameTimeSeconds()

    local panelSize = self:GetPanelSize(isDebuff)
    local nameSize  = self:GetNameFontSize(panelSize)
    local fullFont  = self:GetFont(nameSize)
    local smallFont = self:GetFont(math.max(10, math.floor(nameSize * 0.5)))
    local fullIcon  = self:GetIconSize(panelSize)
    local smallIcon = math.max(12, math.floor(fullIcon * 0.5))

    local scaleOverflow = self:GetPanelOverflow(isDebuff)
    local showText      = self:GetPanelShowText(isDebuff)

    local visible = 0
    local yOffset = 0

    for i, box in ipairs(boxPool) do
        local entry = effectsList[i]
        if entry then
            local isSmall  = scaleOverflow and (i > 10)
            local iconSize = isSmall and smallIcon or fullIcon
            local nameFont = isSmall and smallFont or fullFont

            local frameSize = self:SizeBox(box, iconSize, nameFont)

            box:ClearAnchors()
            box:SetAnchor(TOPLEFT, box:GetParent(), TOPLEFT, SIDE_MARGIN, yOffset)

            if entry.fx.icon then
                box.icon:SetTexture(entry.fx.icon)
                box.icon:SetHidden(false)
            else
                box.icon:SetHidden(true)
            end

            box.radial:SetFillColor(ringR, ringG, ringB, 1)

            if box.cdKey ~= entry.key or now >= box.cdEnd then
                box.cdKey = entry.key
                if entry.fx.isPermanent then
                    box.cdEnd = now + (PERMANENT_MS / 1000)
                    box.radial:StartCooldown(PERMANENT_MS, PERMANENT_MS, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false)
                else
                    local remainingMs = math.max(entry.remaining, 0) * 1000
                    local totalMs     = math.max(entry.fx.totalDuration, entry.remaining) * 1000
                    box.cdEnd = now + math.max(entry.remaining, 0)
                    box.radial:StartCooldown(remainingMs, totalMs, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false)
                end
            end

            if entry.fx.isPermanent then
                box.number:SetText("∞")
                box.number:SetColor(ringR, ringG, ringB, 1)
            else
                box.number:SetText(string.format("%.1f", math.max(entry.remaining, 0)))
                local tr, tg, tb = GetTimerColor(entry.remaining, entry.fx.totalDuration)
                box.number:SetColor(tr, tg, tb, 1)
            end

            if showText then
                box.nameLabel:SetText(entry.fx.name)
                box.nameLabel:SetColor(ringR, ringG, ringB, 1)
                box.nameLabel:SetHidden(false)
            else
                box.nameLabel:SetHidden(true)
            end

            box:SetHidden(false)
            visible = visible + 1
            yOffset = yOffset + frameSize + BOX_GAP
        else
            box.cdKey = nil
            box.cdEnd = 0
            box:SetHidden(true)
        end
    end

    return visible, yOffset
end

--------------------------------------------------
-- Refresh Display
--------------------------------------------------
local function BuildPreviewList()
    local list = {}
    for i, fx in ipairs(PREVIEW_EFFECTS) do
        table.insert(list, {
            remaining = fx.duration - fx.elapsed,
            key       = "preview" .. i,
            fx = {
                name          = fx.name,
                icon          = fx.icon,
                isPermanent   = false,
                totalDuration = fx.duration,
            },
        })
    end
    return list
end

local function BuildActiveList(source, now)
    local list = {}
    for slot, fx in pairs(source) do
        local remaining = fx.endTime - now
        if remaining > 0 and remaining <= SHOW_THRESHOLD then
            table.insert(list, {
                remaining = remaining,
                key       = slot .. ":" .. fx.endTime,
                fx        = fx,
            })
        end
    end
    table.sort(list, function(a, b) return a.remaining < b.remaining end)
    return list
end

function VerticalBuffsDebuffs:RefreshDisplay()
    local now = GetGameTimeSeconds()

    local buffsToShow, debuffsToShow

    if self.previewBuffs then
        buffsToShow = BuildPreviewList()
    else
        buffsToShow = BuildActiveList(activeBuffs, now)
    end

    if self.previewDebuffs then
        debuffsToShow = BuildPreviewList()
    else
        debuffsToShow = BuildActiveList(activeDebuffs, now)
    end

    local buffVisible,   buffHeight   = self:RenderBoxes(buffBoxes,   buffsToShow,   false)
    local debuffVisible, debuffHeight = self:RenderBoxes(debuffBoxes, debuffsToShow, true)

    local showBuffs   = self.savedVariables.showBuffs   or self.movingBuffs   or self.previewBuffs
    local showDebuffs = self.savedVariables.showDebuffs or self.movingDebuffs or self.previewDebuffs

    self.buffPanel:SetHidden(not showBuffs or buffVisible == 0)
    if showBuffs and buffVisible > 0 then
        self.buffPanel:SetDimensions(400, buffHeight)
    end

    self.debuffPanel:SetHidden(not showDebuffs or debuffVisible == 0)
    if showDebuffs and debuffVisible > 0 then
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
-- Reset
--------------------------------------------------
function VerticalBuffsDebuffs:ResetSettings()
    if not self.savedVariables then return end

    for key, value in pairs(self.defaults) do
        self.savedVariables[key] = value
    end

    self.previewBuffs   = false
    self.previewDebuffs = false
    self:ApplyBuffPosition()
    self:ApplyDebuffPosition()
    self:BuildBoxPools()
    self:RefreshDisplay()
end

--------------------------------------------------
-- Move Mode
--------------------------------------------------
function VerticalBuffsDebuffs:GetMover(isDebuff)
    local LCA = LibCombatAlerts
    if not LCA then return nil end

    if isDebuff then
        if not self.debuffMover then
            self.debuffMover = LCA.MoveableControl:New(self.debuffPanel, { color = 0xFF3333FF, size = 2 })
            self.debuffMover:SetSnap(MOVE_SNAP)
            self.debuffMover:RegisterCallback(
                "VerticalBuffsDebuffs_DebuffMoveStop",
                LCA.EVENT_CONTROL_MOVE_STOP,
                function() VerticalBuffsDebuffs:OnMoveStopped(true) end
            )
        end
        return self.debuffMover
    end

    if not self.buffMover then
        self.buffMover = LCA.MoveableControl:New(self.buffPanel, { color = 0x33FF33FF, size = 2 })
        self.buffMover:SetSnap(MOVE_SNAP)
        self.buffMover:RegisterCallback(
            "VerticalBuffsDebuffs_BuffMoveStop",
            LCA.EVENT_CONTROL_MOVE_STOP,
            function() VerticalBuffsDebuffs:OnMoveStopped(false) end
        )
    end
    return self.buffMover
end

function VerticalBuffsDebuffs:EnsureKeybind()
    if self.keybindDescriptor then return end

    self.actionLayerName = GetString(SI_KEYBINDINGS_LAYER_USER_INTERFACE_SHORTCUTS)

    self.keybindDescriptor = {
        {
            name     = "Save & Exit",
            keybind  = "UI_SHORTCUT_NEGATIVE",
            callback = function() VerticalBuffsDebuffs:StopMove() end,
        },
    }
end

function VerticalBuffsDebuffs:AddKeybind()
    self:EnsureKeybind()

    local scene = SCENE_MANAGER:GetCurrentScene()
    if KEYBIND_STRIP_GAMEPAD_FRAGMENT and scene
       and not scene:HasFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT) then
        scene:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
        self.keybindFragmentScene = scene
    end

    if self.keybindActive then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindDescriptor)
    else
        KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindDescriptor)
        PushActionLayerByName(self.actionLayerName)
        self.keybindActive = true
    end
end

function VerticalBuffsDebuffs:ExitMoveMode()
    if self.keybindActive then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindDescriptor)
        RemoveActionLayerByName(self.actionLayerName)
        self.keybindActive = false
    end

    if self.keybindFragmentScene then
        if KEYBIND_STRIP_GAMEPAD_FRAGMENT then
            self.keybindFragmentScene:RemoveFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
        end
        self.keybindFragmentScene = nil
    end

    self.movingBuffs    = false
    self.movingDebuffs  = false
    self.previewBuffs   = false
    self.previewDebuffs = false

    self:RefreshDisplay()
end

function VerticalBuffsDebuffs:OnMoveStopped(isDebuff)
    local panel = isDebuff and self.debuffPanel or self.buffPanel

    local x = math.max(0, math.floor(panel:GetLeft()))
    local y = math.max(0, math.floor(panel:GetTop()))

    if isDebuff then
        self.savedVariables.debuffPosX = x
        self.savedVariables.debuffPosY = y
        self:ApplyDebuffPosition()
    else
        self.savedVariables.buffPosX = x
        self.savedVariables.buffPosY = y
        self:ApplyBuffPosition()
    end

    self:ExitMoveMode()
end

function VerticalBuffsDebuffs:StopMove()
    if self.buffMover then
        self.buffMover:ToggleGamepadMove(false)
    end
    if self.debuffMover then
        self.debuffMover:ToggleGamepadMove(false)
    end

    self:ExitMoveMode()
end

function VerticalBuffsDebuffs:StartMove(isDebuff)
    local mover = self:GetMover(isDebuff)
    if not mover then return end

    self:StopMove()

    SCENE_MANAGER:ShowBaseScene()

    if isDebuff then
        self.movingDebuffs  = true
        self.previewDebuffs = true
    else
        self.movingBuffs  = true
        self.previewBuffs = true
    end

    self:RefreshDisplay()

    zo_callLater(function()
        VerticalBuffsDebuffs:AddKeybind()
        mover:ToggleGamepadMove(true, MOVE_TIMEOUT)
    end, 250)
end

--------------------------------------------------
-- Settings
--------------------------------------------------
function VerticalBuffsDebuffs:CreateSettings()
    local LCM = LibConsoleMenu
    if not LCM then return end

    local menu = LCM:CreateAddonMenu("VerticalBuffsDebuffs", {
        title          = "Vertical Buffs Debuffs",
        author         = "user562",
        version        = "1.5",
        category       = MOD_BROWSER_CATEGORY_TYPE_BUFFS_AND_DEBUFFS,
        enableDefaults = true,
        enableReset    = true,
        resetFunc      = function() self:ResetSettings() end,
    })

    if not menu then return end

    local options = {

        {
            type    = "submenu",
            name    = "|c33FF33Buffs|r",
            align   = "left",
            indent  = true,
            icon    = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_buffsAndDebuffs.dds",
            options = {
                {
                    type    = "toggle",
                    name    = "Preview",
                    getFunc = function() return self.previewBuffs end,
                    setFunc = function(val)
                        self.previewBuffs = val
                        self:RefreshDisplay()
                    end,
                },
                {
                    type    = "button",
                    name    = "Move |c33FF33Buffs|r",
                    tooltip = "Move with the right stick. Press B to save and exit.",
                    func    = function() self:StartMove(false) end,
                },
                {
                    type    = "toggle",
                    name    = "Enabled",
                    default = self.defaults.showBuffs,
                    getFunc = function() return self.savedVariables.showBuffs end,
                    setFunc = function(val)
                        self.savedVariables.showBuffs = val
                        self:RefreshDisplay()
                    end,
                },
                {
                    type    = "toggle",
                    name    = "Show Text",
                    default = self.defaults.showBuffText,
                    getFunc = function() return self.savedVariables.showBuffText end,
                    setFunc = function(val)
                        self.savedVariables.showBuffText = val
                        self:RefreshDisplay()
                    end,
                },
                {
                    type    = "slider",
                    name    = "Size",
                    min     = 18, max = 60, step = 1,
                    default = self.defaults.buffSize,
                    getFunc = function() return self.savedVariables.buffSize end,
                    setFunc = function(val)
                        self.savedVariables.buffSize = val
                        self:RefreshDisplay()
                    end,
                },
                {
                    type    = "toggle",
                    name    = "1-10 ^ - 11+ 50% Smaller",
                    default = self.defaults.buffScaleOverflow,
                    getFunc = function() return self.savedVariables.buffScaleOverflow end,
                    setFunc = function(val)
                        self.savedVariables.buffScaleOverflow = val
                        self:RefreshDisplay()
                    end,
                },
            },
        },

        {
            type    = "submenu",
            name    = "|cFF3333Debuffs|r",
            align   = "left",
            indent  = true,
            icon    = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_buffsAndDebuffs.dds",
            options = {
                {
                    type    = "toggle",
                    name    = "Preview",
                    getFunc = function() return self.previewDebuffs end,
                    setFunc = function(val)
                        self.previewDebuffs = val
                        self:RefreshDisplay()
                    end,
                },
                {
                    type    = "button",
                    name    = "Move |cFF3333Debuffs|r",
                    tooltip = "Move with the right stick. Press B to save and exit.",
                    func    = function() self:StartMove(true) end,
                },
                {
                    type    = "toggle",
                    name    = "Enabled",
                    default = self.defaults.showDebuffs,
                    getFunc = function() return self.savedVariables.showDebuffs end,
                    setFunc = function(val)
                        self.savedVariables.showDebuffs = val
                        self:RefreshDisplay()
                    end,
                },
                {
                    type    = "toggle",
                    name    = "Show Text",
                    default = self.defaults.showDebuffText,
                    getFunc = function() return self.savedVariables.showDebuffText end,
                    setFunc = function(val)
                        self.savedVariables.showDebuffText = val
                        self:RefreshDisplay()
                    end,
                },
                {
                    type    = "slider",
                    name    = "Size",
                    min     = 18, max = 60, step = 1,
                    default = self.defaults.debuffSize,
                    getFunc = function() return self.savedVariables.debuffSize end,
                    setFunc = function(val)
                        self.savedVariables.debuffSize = val
                        self:RefreshDisplay()
                    end,
                },
                {
                    type    = "toggle",
                    name    = "1-10 ^ - 11+ 50% Smaller",
                    default = self.defaults.debuffScaleOverflow,
                    getFunc = function() return self.savedVariables.debuffScaleOverflow end,
                    setFunc = function(val)
                        self.savedVariables.debuffScaleOverflow = val
                        self:RefreshDisplay()
                    end,
                },
            },
        },
    }

    menu:AddOptions(options)
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
            VerticalBuffsDebuffs.defaults
        )

        local sv = VerticalBuffsDebuffs.savedVariables
        if sv.fontSize then
            sv.buffSize   = sv.fontSize
            sv.debuffSize = sv.fontSize
            sv.fontSize   = nil
        end
        if sv.scaleOverflow ~= nil then
            sv.buffScaleOverflow   = sv.scaleOverflow
            sv.debuffScaleOverflow = sv.scaleOverflow
            sv.scaleOverflow       = nil
        end

        VerticalBuffsDebuffs:CreatePanels()
        VerticalBuffsDebuffs:BuildBoxPools()
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

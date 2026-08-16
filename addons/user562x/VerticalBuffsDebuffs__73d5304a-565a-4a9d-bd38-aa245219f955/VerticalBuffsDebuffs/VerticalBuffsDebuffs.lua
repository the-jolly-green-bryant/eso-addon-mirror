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
    buffCap            = 0,
    debuffCap          = 0,
}

VerticalBuffsDebuffs.capChoices = {
    { name = "All", value = 0  },
    { name = "5",   value = 5  },
    { name = "10",  value = 10 },
    { name = "15",  value = 15 },
    { name = "20",  value = 20 },
}

local activeBuffs   = {}
local activeDebuffs = {}

local buffBoxes   = {}
local debuffBoxes = {}

local boxCounter = 0

local fontCache   = {}
local numberFonts = {}
local timerTexts  = {}
local entryPool   = {}
local buffList    = {}
local debuffList  = {}
local previewList = nil

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
local MOVE_DIM_ALPHA = 0.35

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
    local font = fontCache[size]
    if not font then
        font = string.format("EsoUI/Common/Fonts/univers67.otf|%d|soft-shadow-thick", size)
        fontCache[size] = font
    end
    return font
end

function VerticalBuffsDebuffs:GetNumberFont(iconSize)
    local font = numberFonts[iconSize]
    if not font then
        font = string.format(
            "EsoUI/Common/Fonts/univers67.otf|%d|outline",
            math.max(12, math.floor(iconSize * 0.5))
        )
        numberFonts[iconSize] = font
    end
    return font
end

local function GetTimerText(remaining)
    local tenths = math.floor(remaining * 10)
    if tenths < 0 then tenths = 0 end

    local text = timerTexts[tenths]
    if not text then
        text = string.format("%.1f", tenths / 10)
        timerTexts[tenths] = text
    end
    return text
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

function VerticalBuffsDebuffs:GetPanelCap(isDebuff)
    if isDebuff then
        return self.savedVariables.debuffCap or 0
    end
    return self.savedVariables.buffCap or 0
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
    local frameSize = iconSize + FRAME_PAD

    if box.sizedFor ~= iconSize then
        local ringSize = iconSize + RING_PAD

        box:SetDimensions(frameSize, frameSize)
        box.frame:SetDimensions(frameSize, frameSize)
        box.radial:SetDimensions(ringSize, ringSize)
        box.inner:SetDimensions(iconSize, iconSize)
        box.icon:SetDimensions(iconSize, iconSize)
        box.number:SetDimensions(iconSize, iconSize)
        box.number:SetFont(self:GetNumberFont(iconSize))

        box.sizedFor = iconSize
    end

    if box.sizedFont ~= nameFont then
        box.nameLabel:SetFont(nameFont)
        box.sizedFont = nameFont
    end

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
    local cap           = self:GetPanelCap(isDebuff)

    local visible = 0
    local yOffset = 0

    for i, box in ipairs(boxPool) do
        local entry = effectsList[i]
        if cap > 0 and i > cap then
            entry = nil
        end
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

            if box.cdSlot ~= entry.slot or box.cdStamp ~= entry.stamp or now >= box.cdExpire then
                box.cdSlot  = entry.slot
                box.cdStamp = entry.stamp
                if entry.fx.isPermanent then
                    box.cdExpire = now + (PERMANENT_MS / 1000)
                    box.radial:StartCooldown(PERMANENT_MS, PERMANENT_MS, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false)
                else
                    local remainingMs = math.max(entry.remaining, 0) * 1000
                    local totalMs     = math.max(entry.fx.totalDuration, entry.remaining) * 1000
                    box.cdExpire = now + math.max(entry.remaining, 0)
                    box.radial:StartCooldown(remainingMs, totalMs, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false)
                end
            end

            if entry.fx.isPermanent then
                box.number:SetText("∞")
                box.number:SetColor(ringR, ringG, ringB, 1)
            else
                box.number:SetText(GetTimerText(entry.remaining))
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
            box.cdSlot   = nil
            box.cdStamp  = nil
            box.cdExpire = 0
            box:SetHidden(true)
        end
    end

    return visible, yOffset
end

--------------------------------------------------
-- Refresh Display
--------------------------------------------------
local function SortByRemaining(a, b)
    return a.remaining < b.remaining
end

local function GetPreviewList()
    if not previewList then
        previewList = {}
        for i, fx in ipairs(PREVIEW_EFFECTS) do
            previewList[i] = {
                remaining = fx.duration - fx.elapsed,
                slot      = -i,
                stamp     = fx.duration,
                fx = {
                    name          = fx.name,
                    icon          = fx.icon,
                    isPermanent   = false,
                    totalDuration = fx.duration,
                },
            }
        end
    end
    return previewList
end

local function BuildActiveList(source, now, list)
    for i = #list, 1, -1 do
        entryPool[#entryPool + 1] = list[i]
        list[i] = nil
    end

    local count = 0
    for slot, fx in pairs(source) do
        local remaining = fx.endTime - now
        if remaining > 0 and remaining <= SHOW_THRESHOLD then
            local pooled = #entryPool
            local entry
            if pooled > 0 then
                entry = entryPool[pooled]
                entryPool[pooled] = nil
            else
                entry = {}
            end

            entry.remaining = remaining
            entry.slot      = slot
            entry.stamp     = fx.endTime
            entry.fx        = fx

            count = count + 1
            list[count] = entry
        end
    end

    table.sort(list, SortByRemaining)
    return list
end

function VerticalBuffsDebuffs:RefreshDisplay()
    local now = GetGameTimeSeconds()

    local buffsToShow
    if self.previewBuffs then
        buffsToShow = GetPreviewList()
    else
        buffsToShow = BuildActiveList(activeBuffs, now, buffList)
    end

    local debuffsToShow
    if self.previewDebuffs then
        debuffsToShow = GetPreviewList()
    else
        debuffsToShow = BuildActiveList(activeDebuffs, now, debuffList)
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

    if numEffects > 0 then
        activeBuffs   = {}
        activeDebuffs = {}
    end

    for i = 1, numEffects do
        local name, startTime, endTime, buffSlot, stackCount, iconName, buffType, effectType =
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
            local slot = buffSlot or i
            if effectType == BUFF_EFFECT_TYPE_DEBUFF then
                activeDebuffs[slot] = entry
                activeBuffs[slot]   = nil
            else
                activeBuffs[slot]   = entry
                activeDebuffs[slot] = nil
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
-- Profile
--------------------------------------------------
function VerticalBuffsDebuffs:GetAccountProfile()
    if not self.accountVars then
        self.accountVars = ZO_SavedVars:NewAccountWide(
            "VerticalBuffsDebuffs_SavedVars",
            2,
            nil,
            self.defaults
        )
    end
    return self.accountVars
end

function VerticalBuffsDebuffs:GetCharacterProfile()
    if not self.characterVars then
        self.characterVars = ZO_SavedVars:NewCharacterIdSettings(
            "VerticalBuffsDebuffs_SavedVars",
            2,
            nil,
            self.defaults
        )
    end
    return self.characterVars
end

function VerticalBuffsDebuffs:MigrateProfile(sv)
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
end

function VerticalBuffsDebuffs:LoadProfile()
    local account = self:GetAccountProfile()
    self:MigrateProfile(account)

    if self.profileVars.useCharacterSettings then
        local character = self:GetCharacterProfile()
        self:MigrateProfile(character)

        if not character.seeded then
            for key in pairs(self.defaults) do
                character[key] = account[key]
            end
            character.seeded = true
        end

        self.savedVariables = character
    else
        self.savedVariables = account
    end
end

function VerticalBuffsDebuffs:SetUseCharacterSettings(value)
    if self.profileVars.useCharacterSettings == value then return end

    self.profileVars.useCharacterSettings = value
    self:LoadProfile()

    self:ApplyBuffPosition()
    self:ApplyDebuffPosition()
    self:RefreshDisplay()

    if self.menu and self.menu.UpdateControls then
        self.menu:UpdateControls()
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
        {
            name = function()
                if VerticalBuffsDebuffs.moveTarget then
                    return "Move |c33FF33Buffs|r"
                end
                return "Move |cFF3333Debuffs|r"
            end,
            keybind                 = "UI_SHORTCUT_INPUT_LEFT",
            gamepadPreferredKeybind = "UI_SHORTCUT_LEFT_SHOULDER",
            alignment               = KEYBIND_STRIP_ALIGN_RIGHT,
            callback                = function() VerticalBuffsDebuffs:SwitchMoveTarget() end,
        },
        {
            name = function()
                if VerticalBuffsDebuffs.moveTarget then
                    return "Move |c33FF33Buffs|r"
                end
                return "Move |cFF3333Debuffs|r"
            end,
            keybind                 = "UI_SHORTCUT_INPUT_RIGHT",
            gamepadPreferredKeybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            alignment               = KEYBIND_STRIP_ALIGN_RIGHT,
            callback                = function() VerticalBuffsDebuffs:SwitchMoveTarget() end,
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

function VerticalBuffsDebuffs:UpdateMoveFocus()
    if not self.moveActive then
        self.buffPanel:SetAlpha(1)
        self.debuffPanel:SetAlpha(1)
        return
    end

    if self.moveTarget then
        self.buffPanel:SetAlpha(MOVE_DIM_ALPHA)
        self.debuffPanel:SetAlpha(1)
    else
        self.buffPanel:SetAlpha(1)
        self.debuffPanel:SetAlpha(MOVE_DIM_ALPHA)
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

    self.moveActive     = false
    self.movingBuffs    = false
    self.movingDebuffs  = false
    self.previewBuffs   = false
    self.previewDebuffs = false

    self:UpdateMoveFocus()
    self:RefreshDisplay()
end

function VerticalBuffsDebuffs:SaveMoverPosition(isDebuff)
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
end

function VerticalBuffsDebuffs:OnMoveStopped(isDebuff)
    self:SaveMoverPosition(isDebuff)

    if not self.switchingTarget then
        self:ExitMoveMode()
    end
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

function VerticalBuffsDebuffs:SwitchMoveTarget()
    if not self.moveActive then return end

    local current = self:GetMover(self.moveTarget)

    self.switchingTarget = true
    if current then
        current:ToggleGamepadMove(false)
    end
    self.switchingTarget = false

    self.moveTarget = not self.moveTarget

    local nextMover = self:GetMover(self.moveTarget)
    if nextMover then
        nextMover:ToggleGamepadMove(true, MOVE_TIMEOUT)
    end

    self:UpdateMoveFocus()
    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindDescriptor)
end

function VerticalBuffsDebuffs:StartMove()
    local mover = self:GetMover(false)
    if not mover then return end

    self:StopMove()

    SCENE_MANAGER:ShowBaseScene()

    self.moveActive     = true
    self.moveTarget     = false
    self.movingBuffs    = true
    self.movingDebuffs  = true
    self.previewBuffs   = true
    self.previewDebuffs = true

    self:UpdateMoveFocus()
    self:RefreshDisplay()

    zo_callLater(function()
        VerticalBuffsDebuffs:AddKeybind()
        mover:ToggleGamepadMove(true, MOVE_TIMEOUT)
    end, 250)
end

--------------------------------------------------
-- Settings
--------------------------------------------------
function VerticalBuffsDebuffs:HasConsoleMenu()
    return type(LibConsoleMenu) == "table"
       and type(LibConsoleMenu.CreateAddonMenu) == "function"
end

function VerticalBuffsDebuffs:CreateSettings()
    if not self:HasConsoleMenu() then
        VerticalBuffsDebuffs.settingsUnavailable = true
        return
    end

    local LCM = LibConsoleMenu

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

    self.menu = menu

    local options = {

        {
            type    = "toggle",
            name    = "Character Settings",
            tooltip = "Off uses one layout for the whole account. On gives this character its own, starting as a copy of the account layout.",
            getFunc = function() return self.profileVars.useCharacterSettings end,
            setFunc = function(val) self:SetUseCharacterSettings(val) end,
        },

        {
            type    = "button",
            name    = "Move |c33FF33Buffs|r / |cFF3333Debuffs|r",
            func    = function() self:StartMove() end,
        },

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
                {
                    type    = "dropdown",
                    name    = "Cap At",
                    choices = self.capChoices,
                    default = 0,
                    getFunc = function() return self.savedVariables.buffCap end,
                    setFunc = function(val)
                        self.savedVariables.buffCap = val
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
                {
                    type    = "dropdown",
                    name    = "Cap At",
                    choices = self.capChoices,
                    default = 0,
                    getFunc = function() return self.savedVariables.debuffCap end,
                    setFunc = function(val)
                        self.savedVariables.debuffCap = val
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

        VerticalBuffsDebuffs.profileVars = ZO_SavedVars:NewAccountWide(
            "VerticalBuffsDebuffs_SavedVars",
            2,
            "Profile",
            { useCharacterSettings = false }
        )

        VerticalBuffsDebuffs:LoadProfile()

        VerticalBuffsDebuffs:CreatePanels()
        VerticalBuffsDebuffs:BuildBoxPools()
        local settingsOk, settingsErr = pcall(function() VerticalBuffsDebuffs:CreateSettings() end)
        if not settingsOk then
            VerticalBuffsDebuffs.settingsUnavailable = true
            VerticalBuffsDebuffs.settingsError = tostring(settingsErr)
        end

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

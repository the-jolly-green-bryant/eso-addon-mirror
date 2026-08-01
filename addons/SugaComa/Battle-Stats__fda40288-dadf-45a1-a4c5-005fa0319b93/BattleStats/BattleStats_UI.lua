BattleStats = BattleStats or {}
BattleStats.UI = BattleStats.UI or {}
local UI = BattleStats.UI
local Util = BattleStats.Util

UI.blocks = UI.blocks or {}

local function BuildFont(size)
    local s = tonumber(size) or 22
    return string.format("ZoFontGame|%d|soft-shadow-thick", s)
end

local function ApplyBackground(block, enabled)
    if not block or not block.bg then return end
    if enabled then
        block.bg:SetCenterColor(0, 0, 0, 0.35)
        block.bg:SetEdgeColor(0, 0, 0, 0.7)
    else
        block.bg:SetCenterColor(0, 0, 0, 0)
        block.bg:SetEdgeColor(0, 0, 0, 0)
    end
end

local function ApplyBlockDimensions(block, fontSize)
    if not block or not block.window or not block.label then return end
    local lineCount = block.lineCount or 1
    local size = tonumber(fontSize) or 22
    local lineHeight = size + 6
    local width = 420
    local height = (lineHeight * lineCount) + 12
    block.window:SetDimensions(width, height)
    block.label:SetDimensions(width - 20, height - 10)
    block.bg:SetDimensions(width, height)
    block.label:SetFont(BuildFont(size))
end

local function GetDefaultAnchorTarget()
    local base = BattleStats.SV and BattleStats.SV.anchorBase
    if base == "reticle" then
        if ZO_ReticleContainer then return ZO_ReticleContainer end
        if GuiRoot then return GuiRoot end
        return nil
    end
    if ZO_PlayerAttribute then return ZO_PlayerAttribute end
    if GuiRoot then return GuiRoot end
    return nil
end

local function GetCustomAnchorTarget()
    if ZO_ReticleContainer then return ZO_ReticleContainer end
    if GuiRoot then return GuiRoot end
    return nil
end

local function ApplyBlockPosition(key, block, settings)
    if not block or not block.window then return end
    local sv = settings or {}
    local offsetX = tonumber(sv.offsetX) or 0
    local offsetY = tonumber(sv.offsetY) or 0

    block.window:ClearAnchors()

    if sv.useCustom == true then
        local customTarget = GetCustomAnchorTarget()
        if not customTarget then return end
        local x = (tonumber(sv.posX) or 0) + offsetX
        local y = (tonumber(sv.posY) or 0) + offsetY
        block.window:SetAnchor(CENTER, customTarget, CENTER, x, y)
        return
    end

    local target = GetDefaultAnchorTarget()
    if target == ZO_PlayerAttribute then
        if key == "magRecovery" or key == "stamRecovery" or key == "healthRecovery" then
            block.window:SetAnchor(BOTTOM, target, TOP, offsetX, offsetY)
        else
            block.window:SetAnchor(TOP, target, BOTTOM, offsetX, offsetY)
        end
    elseif target == ZO_ReticleContainer then
        block.window:SetAnchor(CENTER, target, CENTER, offsetX, offsetY)
    elseif target == GuiRoot then
        block.window:SetAnchor(CENTER, target, CENTER, offsetX, offsetY)
    end
end

local function SaveBlockPosition(key)
    local sv = BattleStats.SV
    if not sv or not sv[key] then return end
    local block = UI.blocks[key]
    local base = GetCustomAnchorTarget()
    if not block or not block.window or not base then return end
    if not block.window.GetCenter or not base.GetCenter then return end

    local cx, cy = block.window:GetCenter()
    local bx, by = base:GetCenter()
    if not (cx and cy and bx and by) then return end

    local offsetX = tonumber(sv[key].offsetX) or 0
    local offsetY = tonumber(sv[key].offsetY) or 0
    sv[key].posX = math.floor((cx - bx) + 0.5) - offsetX
    sv[key].posY = math.floor((cy - by) + 0.5) - offsetY
    sv[key].useCustom = true
end

local function SetBlockMovable(key, block, unlocked)
    if not block or not block.window then return end
    block.window:SetMouseEnabled(unlocked == true)
    block.window:SetMovable(unlocked == true)

    if unlocked then
        local left = MOUSE_BUTTON_INDEX_LEFT or 1
        block.window:SetHandler("OnMouseDown", function(self, button)
            if button == left then
                self:StartMoving()
            end
        end)
        block.window:SetHandler("OnMouseUp", function(self, button)
            if button == left then
                self:StopMovingOrResizing()
            end
        end)
        block.window:SetHandler("OnMoveStop", function()
            SaveBlockPosition(key)
        end)
    else
        block.window:SetHandler("OnMouseDown", nil)
        block.window:SetHandler("OnMouseUp", nil)
        block.window:SetHandler("OnMoveStop", nil)
    end
end

function UI.CreateBlock(key, lineCount)
    if UI.blocks[key] then return end
    if not WINDOW_MANAGER or not GuiRoot then return end

    local name = "BattleStats_" .. tostring(key)
    local win = WINDOW_MANAGER:CreateTopLevelWindow(name)
    win:SetHidden(false)
    win:SetMouseEnabled(false)
    win:SetMovable(false)

    local bg = WINDOW_MANAGER:CreateControl("$(parent)BG", win, CT_BACKDROP)
    bg:SetAnchor(CENTER, win, CENTER, 0, 0)
    bg:SetCenterColor(0, 0, 0, 0)
    bg:SetEdgeColor(0, 0, 0, 0)

    local label = WINDOW_MANAGER:CreateControl("$(parent)Label", win, CT_LABEL)
    label:SetAnchor(CENTER, win, CENTER, 0, 0)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetText("")

    UI.blocks[key] = {
        key = key,
        window = win,
        bg = bg,
        label = label,
        lineCount = lineCount or 1,
        lastText = nil,
    }
end

function UI.Init()
    UI.CreateBlock("magRecovery", 1)
    UI.CreateBlock("stamRecovery", 1)
    UI.CreateBlock("healthRecovery", 1)
    UI.CreateBlock("damage", 2)
    UI.CreateBlock("resist", 2)
    UI.CreateBlock("pen", 2)
    UI.ApplySettings()
end

function UI.ApplySettings()
    local sv = BattleStats.SV
    if not sv then return end

    for key, block in pairs(UI.blocks) do
        ApplyBlockDimensions(block, sv.fontSize)
        ApplyBackground(block, sv.background == true)
        block.window:SetScale(tonumber(sv.scale) or 1)
        ApplyBlockPosition(key, block, sv[key] or {})
    end

    UI.UpdateVisibility()
    UI.UpdateInteraction()
end

function UI.UpdateVisibility()
    local sv = BattleStats.SV
    if not sv then return end
    local base = (sv.forceShow == true) or Util.IsGameplayHUDActive()

    local enabled = (sv.enabled == true)
    local showMag = enabled and base and (sv.showMagRecovery == true)
    local showStam = enabled and base and (sv.showStamRecovery == true)
    local showHealth = enabled and base and (sv.showHealthRecovery == true)
    local showDamage = enabled and base and (sv.showDamage == true)
    local showResist = enabled and base and (sv.showResist == true)
    local showPen = enabled and base and (sv.showPen == true)

    local block = UI.blocks.magRecovery
    if block and block.window then
        block.window:SetHidden(not showMag)
    end

    block = UI.blocks.stamRecovery
    if block and block.window then
        block.window:SetHidden(not showStam)
    end

    block = UI.blocks.healthRecovery
    if block and block.window then
        block.window:SetHidden(not showHealth)
    end

    block = UI.blocks.damage
    if block and block.window then
        block.window:SetHidden(not showDamage)
    end

    block = UI.blocks.resist
    if block and block.window then
        block.window:SetHidden(not showResist)
    end

    block = UI.blocks.pen
    if block and block.window then
        block.window:SetHidden(not showPen)
    end
end

function UI.UpdateInteraction()
    local sv = BattleStats.SV
    if not sv then return end
    local base = (sv.forceShow == true) or Util.IsGameplayHUDActive()
    local canMove = (sv.unlocked == true) and base
    for key, block in pairs(UI.blocks) do
        SetBlockMovable(key, block, canMove)
    end
end

function UI.SetBlockText(key, text)
    local block = UI.blocks[key]
    if not block or not block.label then return end
    if block.lastText == text then return end
    block.lastText = text
    block.label:SetText(text)
end

function UI.ResetPositions()
    local sv = BattleStats.SV
    if not sv then return end
    local keys = { "magRecovery", "stamRecovery", "healthRecovery", "damage", "resist" }
    keys[#keys + 1] = "pen"
    for i = 1, #keys do
        local key = keys[i]
        if sv[key] then
            sv[key].useCustom = false
            sv[key].posX = 0
            sv[key].posY = 0
        end
    end
    UI.ApplySettings()
end

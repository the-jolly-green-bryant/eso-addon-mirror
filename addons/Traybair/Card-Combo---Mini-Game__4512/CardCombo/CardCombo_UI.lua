local CardCombo = CardCombo

local ADDON_NAME = CardCombo.ADDON_NAME
local DISPLAY_NAME = CardCombo.DISPLAY_NAME

local ROWS = CardCombo.ROWS
local COLS = CardCombo.COLS
local CARD_COUNT = CardCombo.CARD_COUNT
local BASE_MOVES = CardCombo.BASE_MOVES
local MOVE_LIMIT = CardCombo.MOVE_LIMIT
local PANEL_WIDTH = 310
local PANEL_HEIGHT = 495
local CARD_WIDTH = 58
local CARD_HEIGHT = 86
local CARD_GAP = 8
local BOARD_WIDTH = (CARD_WIDTH * COLS) + (CARD_GAP * (COLS - 1))
local BOARD_HEIGHT = (CARD_HEIGHT * ROWS) + (CARD_GAP * (ROWS - 1))
local MOVES_TOP_OFFSET = 76
local BOARD_TOP_OFFSET = 100
local GAME_OVER_LABEL_OFFSET_Y = -34
local GAME_OVER_BUTTON_OFFSET_Y = 26
local GAME_OVER_BUTTON_WIDTH = 126
local GAME_OVER_BUTTON_HEIGHT = 34
local GAME_OVER_OVERLAY_DRAW_LEVEL = 10
local GAME_OVER_LABEL_DRAW_LEVEL = 11
local GAME_OVER_BUTTON_DRAW_LEVEL = 12

local PANEL_BG_COLOR = { 0.035, 0.035, 0.045, 0.96 }
local HEADER_DIVIDER_TEXTURE = "EsoUI/Art/Miscellaneous/horizontalDivider.dds"
local HEADER_DIVIDER_WIDTH = 360
local HEADER_DIVIDER_HEIGHT = 8
local HEADER_DIVIDER_TOP_OFFSET = 44
local INFO_BUTTON_SIZE = 24
local INFO_BUTTON_TOP_OFFSET = 12
local INFO_BUTTON_LEFT_OFFSET = 12
local INFO_ICON_TEXTURE = "/esoui/art/login/login_icon_info.dds"
local CLOSE_BUTTON_SIZE = 20
local CLOSE_BUTTON_TOP_OFFSET = 15
local CLOSE_BUTTON_RIGHT_OFFSET = 12
local CLOSE_BUTTON_TEXTURE = "EsoUI/Art/Buttons/closebutton_up.dds"
local CLOSE_BUTTON_PRESSED_TEXTURE = "EsoUI/Art/Buttons/closebutton_down.dds"
local CLOSE_BUTTON_MOUSEOVER_TEXTURE = "EsoUI/Art/Buttons/closebutton_mouseover.dds"
local CLOSE_BUTTON_TEXTURE_COORDS = { 0, 0.625, 0, 0.625 }
local RULES_TEXT =
"Click a card to increase its value by 1. Make groups of 4+ adjacent matching cards within 4 moves or it is game over!"
local CENTER_TEXTURE = "EsoUI/Art/Tooltips/UI-TooltipCenter.dds"
local EDGE_TEXTURE = "EsoUI/Art/Tooltips/UI-Border.dds"

-- Card value colors repeat if values climb above the palette.
local VALUE_COLORS = {
    { 0.78, 0.12, 0.16 },
    { 0.10, 0.43, 0.82 },
    { 0.94, 0.70, 0.12 },
    { 0.10, 0.62, 0.27 },
    { 0.76, 0.28, 0.72 },
    { 0.07, 0.65, 0.70 },
    { 0.90, 0.38, 0.12 },
    { 0.52, 0.52, 0.56 },
    { 0.58, 0.18, 0.14 },
    { 0.24, 0.62, 0.96 },
    { 0.98, 0.84, 0.22 },
    { 0.26, 0.76, 0.42 },
}

local function ApplyBackdrop(control, edgeSize)
    control:SetCenterTexture(CENTER_TEXTURE)
    control:SetEdgeTexture(EDGE_TEXTURE, 128, 16, edgeSize or 8)
    control:SetInsets(edgeSize or 4, edgeSize or 4, -(edgeSize or 4), -(edgeSize or 4))
end

local function ApplySolidBackdrop(control)
    control:SetCenterTexture("")
    control:SetEdgeTexture("", 1, 1, 2, 0)
    control:SetInsets(0, 0, 0, 0)
end

local function GetValueColor(value)
    return VALUE_COLORS[((value - 1) % #VALUE_COLORS) + 1]
end

local function SetGameOverVisible(self, visible)
    local hidden = not visible

    self.gameOverDim:SetHidden(hidden)
    self.gameOverLabel:SetHidden(hidden)
    self.newGameButton:SetHidden(hidden)
    self.newGameButtonLabel:SetHidden(hidden)
end

local function CreateLabel(parent, name, font, text, color)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetFont(font)
    label:SetText(text or "")

    if color then
        label:SetColor(color[1], color[2], color[3], color[4] or 1)
    end

    return label
end

local function CreateButton(parent, name, text, width, height, callback)
    local button = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_DefaultButton")
    button:SetDimensions(width, height)
    button:SetText(text)
    button:SetHandler("OnClicked", callback)
    return button
end

local function CreateIconButton(parent, name, texture, width, height, callback, mouseOverTexture, pressedTexture,
                                textureCoords)
    local button = WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON)
    button:SetDimensions(width, height)
    button:SetNormalTexture(texture)
    button:SetMouseOverTexture(mouseOverTexture or texture)
    button:SetPressedTexture(pressedTexture or texture)
    if textureCoords then
        button:SetTextureCoords(textureCoords[1], textureCoords[2], textureCoords[3], textureCoords[4])
    end
    button:SetAlpha(0.82)
    button:SetHandler("OnClicked", callback)
    return button
end

local function CreateCardControl(self, parent, index, row, col)
    local cardControl = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "Card" .. tostring(index), parent, CT_BACKDROP)

    cardControl:SetDimensions(CARD_WIDTH, CARD_HEIGHT)
    cardControl:SetAnchor(TOPLEFT, parent, TOPLEFT, (col - 1) * (CARD_WIDTH + CARD_GAP),
        (row - 1) * (CARD_HEIGHT + CARD_GAP))
    cardControl:SetMouseEnabled(false)
    ApplySolidBackdrop(cardControl)
    cardControl:SetCenterColor(0.12, 0.12, 0.12, 1)
    cardControl:SetEdgeColor(0.01, 0.01, 0.01, 1)

    local function OnCardClicked(_, button, upInside)
        if upInside ~= false and button == MOUSE_BUTTON_INDEX_LEFT then
            self:ClickCard(index)
        end
    end

    local valueLabel = CreateLabel(cardControl, ADDON_NAME .. "CardValue" .. tostring(index), "ZoFontWinH1",
        "1", { 0.98, 0.98, 0.96, 1 })
    valueLabel:SetAnchor(CENTER, cardControl, CENTER, 0, 0)
    valueLabel:SetMouseEnabled(false)
    cardControl.valueLabel = valueLabel

    local hitbox = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "CardHitbox" .. tostring(index), cardControl,
        CT_CONTROL)
    hitbox:SetAnchor(TOPLEFT, cardControl, TOPLEFT, 0, 0)
    hitbox:SetAnchor(BOTTOMRIGHT, cardControl, BOTTOMRIGHT, 0, 0)
    hitbox:SetMouseEnabled(true)
    hitbox:SetHandler("OnMouseUp", OnCardClicked)
    cardControl.hitbox = hitbox

    return cardControl
end

function CardCombo:Toggle()
    self.panel:SetHidden(not self.panel:IsHidden())

    if not self.panel:IsHidden() and not self.board then
        self:NewGame()
    end
end

function CardCombo:Refresh()
    if not self.panel then
        return
    end

    self.scoreLabel:SetText("Score: " .. tostring(self.score or 0))
    self.bestLabel:SetText("Best: " .. tostring(self.saved.bestScore or 0))
    self.movesLabel:SetText("Moves: " .. tostring(self.moves or BASE_MOVES) .. "/" .. tostring(MOVE_LIMIT))
    SetGameOverVisible(self, self.gameOver)

    for index = 1, CARD_COUNT do
        local cardControl = self.cardControls[index]
        local card = self.board and self.board[index] or nil

        if card then
            cardControl:SetHidden(false)

            local valueColor = GetValueColor(card.value)

            cardControl:SetCenterColor(valueColor[1], valueColor[2], valueColor[3],
                self.gameOver and 0.45 or 0.96)
            cardControl:SetEdgeColor(0.01, 0.01, 0.01, self.gameOver and 0.35 or 1.0)
            cardControl.valueLabel:SetText(tostring(card.value))
            cardControl.valueLabel:SetColor(1, 1, 1, self.gameOver and 0.65 or 1)
        else
            cardControl:SetHidden(false)
            cardControl:SetCenterColor(0, 0, 0, 0.82)
            cardControl:SetEdgeColor(0.15, 0.15, 0.15, 1)
            cardControl.valueLabel:SetText("")
        end
    end
end

function CardCombo:CreateUI()
    local panel = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "Window")
    self.panel = panel

    panel:SetDimensions(PANEL_WIDTH, PANEL_HEIGHT)
    panel:SetMouseEnabled(true)
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)
    panel:SetHidden(true)

    if self.saved.window and self.saved.window.x ~= nil and self.saved.window.y ~= nil then
        panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.saved.window.x, self.saved.window.y)
    else
        panel:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end

    panel:SetHandler("OnMoveStop", function()
        self.saved.window = {
            x = panel:GetLeft(),
            y = panel:GetTop(),
        }
    end)

    local backdrop = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "Backdrop", panel, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, 0)
    backdrop:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, 0, 0)
    backdrop:SetMouseEnabled(false)
    ApplyBackdrop(backdrop, 8)
    backdrop:SetCenterColor(PANEL_BG_COLOR[1], PANEL_BG_COLOR[2], PANEL_BG_COLOR[3], PANEL_BG_COLOR[4])
    backdrop:SetEdgeColor(0.82, 0.70, 0.38, 0.90)
    self.backdrop = backdrop

    local title = CreateLabel(panel, ADDON_NAME .. "Title", "ZoFontWinH2", DISPLAY_NAME,
        { 1.00, 0.92, 0.62, 1 })
    title:SetAnchor(TOP, panel, TOP, 0, 12)

    local closeButton = CreateIconButton(panel, ADDON_NAME .. "Close", CLOSE_BUTTON_TEXTURE, CLOSE_BUTTON_SIZE,
        CLOSE_BUTTON_SIZE, function()
            panel:SetHidden(true)
        end, CLOSE_BUTTON_MOUSEOVER_TEXTURE, CLOSE_BUTTON_PRESSED_TEXTURE, CLOSE_BUTTON_TEXTURE_COORDS)
    closeButton:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -CLOSE_BUTTON_RIGHT_OFFSET, CLOSE_BUTTON_TOP_OFFSET)
    closeButton:SetAlpha(1)

    local rulesButton = CreateIconButton(panel, ADDON_NAME .. "Rules", INFO_ICON_TEXTURE, INFO_BUTTON_SIZE,
        INFO_BUTTON_SIZE, function() end)
    rulesButton:SetAnchor(TOPLEFT, panel, TOPLEFT, INFO_BUTTON_LEFT_OFFSET, INFO_BUTTON_TOP_OFFSET)
    rulesButton:SetHandler("OnMouseEnter", function(control)
        control:SetAlpha(1)
        ZO_Tooltips_ShowTextTooltip(control, TOP, RULES_TEXT)
    end)
    rulesButton:SetHandler("OnMouseExit", function(control)
        control:SetAlpha(0.82)
        ZO_Tooltips_HideTextTooltip()
    end)

    local headerDivider = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "HeaderDivider", panel, CT_TEXTURE)
    headerDivider:SetTexture(HEADER_DIVIDER_TEXTURE)
    headerDivider:SetDimensions(HEADER_DIVIDER_WIDTH, HEADER_DIVIDER_HEIGHT)
    headerDivider:SetAnchor(TOP, panel, TOP, 0, HEADER_DIVIDER_TOP_OFFSET)
    headerDivider:SetMouseEnabled(false)
    self.headerDivider = headerDivider

    self.scoreLabel = CreateLabel(panel, ADDON_NAME .. "Score", "ZoFontGameLargeBold", "Score: 0",
        { 0.94, 0.92, 0.86, 1 })
    self.scoreLabel:SetAnchor(TOPLEFT, panel, TOPLEFT, 16, 52)

    self.movesLabel = CreateLabel(panel, ADDON_NAME .. "Moves", "ZoFontGameLargeBold", "Moves: 4/4",
        { 0.74, 0.94, 1.00, 1 })
    self.movesLabel:SetAnchor(TOP, panel, TOP, 0, MOVES_TOP_OFFSET)

    self.bestLabel = CreateLabel(panel, ADDON_NAME .. "Best", "ZoFontGameLargeBold", "Best: 0",
        { 0.94, 0.92, 0.86, 1 })
    self.bestLabel:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -16, 52)

    local board = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "Board", panel, CT_CONTROL)
    board:SetDimensions(BOARD_WIDTH, BOARD_HEIGHT)
    board:SetAnchor(TOP, panel, TOP, 0, BOARD_TOP_OFFSET)
    self.boardControl = board

    self.cardControls = {}

    for row = 1, ROWS do
        for col = 1, COLS do
            local index = self:Index(row, col)
            self.cardControls[index] = CreateCardControl(self, board, index, row, col)
        end
    end

    local gameOverDim = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "GameOverDim", board, CT_BACKDROP)
    gameOverDim:SetAnchor(TOPLEFT, board, TOPLEFT, 0, 0)
    gameOverDim:SetAnchor(BOTTOMRIGHT, board, BOTTOMRIGHT, 0, 0)
    gameOverDim:SetMouseEnabled(false)
    gameOverDim:SetDrawTier(DT_HIGH)
    gameOverDim:SetDrawLayer(DL_BACKGROUND)
    gameOverDim:SetDrawLevel(GAME_OVER_OVERLAY_DRAW_LEVEL)
    ApplySolidBackdrop(gameOverDim)
    gameOverDim:SetCenterColor(0, 0, 0, 0.72)
    gameOverDim:SetEdgeColor(0, 0, 0, 0)
    gameOverDim:SetHidden(true)
    self.gameOverDim = gameOverDim

    self.gameOverLabel = CreateLabel(board, ADDON_NAME .. "GameOver", "ZoFontWinH1", "Game Over!",
        { 1.00, 0.92, 0.62, 1 })
    self.gameOverLabel:SetDimensions(BOARD_WIDTH, 48)
    self.gameOverLabel:SetAnchor(CENTER, board, CENTER, 0, GAME_OVER_LABEL_OFFSET_Y)
    self.gameOverLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.gameOverLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.gameOverLabel:SetMouseEnabled(false)
    self.gameOverLabel:SetDrawTier(DT_HIGH)
    self.gameOverLabel:SetDrawLayer(DL_OVERLAY)
    self.gameOverLabel:SetDrawLevel(GAME_OVER_LABEL_DRAW_LEVEL)
    self.gameOverLabel:SetHidden(true)

    local newButton = CreateButton(board, ADDON_NAME .. "NewGame", "New Game",
        GAME_OVER_BUTTON_WIDTH, GAME_OVER_BUTTON_HEIGHT, function()
            self:NewGame()
        end)
    newButton:SetText("")
    newButton:SetAnchor(CENTER, board, CENTER, 0, GAME_OVER_BUTTON_OFFSET_Y)
    newButton:SetMouseEnabled(true)
    newButton:SetEnabled(true)
    newButton:SetDrawTier(DT_HIGH)
    newButton:SetDrawLayer(DL_OVERLAY)
    newButton:SetDrawLevel(GAME_OVER_BUTTON_DRAW_LEVEL)
    newButton:SetHidden(true)
    self.newGameButton = newButton

    local newButtonLabel = CreateLabel(board, ADDON_NAME .. "NewGameLabel", "ZoFontGameBold", "New Game",
        { 1.00, 0.92, 0.62, 1 })
    newButtonLabel:SetDimensions(GAME_OVER_BUTTON_WIDTH, GAME_OVER_BUTTON_HEIGHT)
    newButtonLabel:SetAnchor(CENTER, newButton, CENTER, 0, 0)
    newButtonLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    newButtonLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    newButtonLabel:SetMouseEnabled(false)
    newButtonLabel:SetDrawTier(DT_HIGH)
    newButtonLabel:SetDrawLayer(DL_OVERLAY)
    newButtonLabel:SetDrawLevel(GAME_OVER_BUTTON_DRAW_LEVEL + 1)
    newButtonLabel:SetHidden(true)
    self.newGameButtonLabel = newButtonLabel
end

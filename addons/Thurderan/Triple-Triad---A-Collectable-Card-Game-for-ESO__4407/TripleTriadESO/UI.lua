--[[
    Triple Triad ESO - User Interface (v2 — Full Rewrite)

    Fixes from v1:
    - Window is much larger so nothing overflows
    - Card placement click handlers work properly (mouse passthrough on card children)
    - Board cells highlight on hover when a card is selected
    - Turn indicator tells you exactly what to do
    - All controls properly sized and anchored with absolute positions
]]--

local TT = TripleTriadESO

TT.UI = {}
local UI = TT.UI

-- ─────────────────────────────────────────────
-- Color Constants
-- ─────────────────────────────────────────────
local STAR_COLORS = {
    [1] = { r = 1.0, g = 0.84, b = 0.0 },
    [2] = { r = 1.0, g = 0.84, b = 0.0 },
    [3] = { r = 1.0, g = 0.84, b = 0.0 },
    [4] = { r = 1.0, g = 0.84, b = 0.0 },
    [5] = { r = 1.0, g = 0.84, b = 0.0 },
}

local PLAYER_BG   = { r = 0.08, g = 0.15, b = 0.35 }
local NPC_BG      = { r = 0.35, g = 0.08, b = 0.08 }
local PLAYER_EDGE = { r = 0.2, g = 0.6, b = 1.0 }
local NPC_EDGE    = { r = 1.0, g = 0.2, b = 0.2 }

-- ─────────────────────────────────────────────
-- Dimensions (~3:4 card ratio)
-- ─────────────────────────────────────────────
local CELL_W      = 138
local CELL_H      = 174
local CELL_GAP    = 5
local CARD_W      = 128
local CARD_H      = 164
local HAND_CARD_W = 96
local HAND_CARD_H = 124
local HAND_GAP    = 4

local GRID_W      = CELL_W * 3 + CELL_GAP * 2   -- 424
local GRID_H      = CELL_H * 3 + CELL_GAP * 2   -- 532
local HAND_TOTAL  = HAND_CARD_H * 5 + HAND_GAP * 4  -- 636
local BOARD_W     = HAND_CARD_W + 30 + GRID_W + 30 + HAND_CARD_W + 50  -- ~726
local BOARD_H     = math.max(GRID_H, HAND_TOTAL) + 150  -- ~786

-- ─────────────────────────────────────────────
-- ZO_ScrollContainer helper (ESO built-in with native clipping)
-- ─────────────────────────────────────────────
local function MakeScrollArea(name, parent, w, h, anchorPoint, anchorTo, anchorRelative, offX, offY)
    local container = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_ScrollContainer")
    container:SetDimensions(w, h)
    container:SetAnchor(anchorPoint or TOP, anchorTo or parent, anchorRelative or TOP, offX or 0, offY or 0)
    local scrollChild = GetControl(container, "ScrollChild")
    scrollChild:SetResizeToFitPadding(0, 10)
    return container, scrollChild
end

-- ─────────────────────────────────────────────
-- Initialize
-- ─────────────────────────────────────────────
function UI:Initialize()
    self:CreateGameBoard()
    self:CreateCollectionWindow()
    self:CreateStatsWindow()
    self:CreateDeckBuilder()
    self:CreateResultWindow()
    self:CreateRulesWindow()
end

-- ═══════════════════════════════════════════════
-- HELPER: Create a draggable window
-- ═══════════════════════════════════════════════
local function MakeWindow(name, w, h, title)
    local win = WINDOW_MANAGER:CreateTopLevelWindow(name)
    win:SetDimensions(w, h)
    win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    win:SetMovable(true)
    win:SetMouseEnabled(true)
    win:SetClampedToScreen(true)
    win:SetHidden(true)
    win:SetDrawLayer(DL_OVERLAY)
    win:SetDrawTier(DT_HIGH)

    local bg = WINDOW_MANAGER:CreateControl(name .. "_BG", win, CT_BACKDROP)
    bg:SetAnchorFill(win)
    bg:SetCenterColor(0.04, 0.04, 0.06, 0.97)
    bg:SetEdgeColor(0.55, 0.45, 0.15, 1)
    bg:SetEdgeTexture("", 2, 2, 2, 2)

    local ttl = WINDOW_MANAGER:CreateControl(name .. "_Title", win, CT_LABEL)
    ttl:SetFont("ZoFontWinH1")
    ttl:SetColor(1, 0.84, 0, 1)
    ttl:SetText(title)
    ttl:SetAnchor(TOP, win, TOP, 0, 14)
    ttl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local cls = WINDOW_MANAGER:CreateControl(name .. "_X", win, CT_BUTTON)
    cls:SetDimensions(32, 32)
    cls:SetAnchor(TOPRIGHT, win, TOPRIGHT, -10, 10)
    cls:SetFont("ZoFontWinH2")
    cls:SetNormalFontColor(1, 0.3, 0.3, 1)
    cls:SetMouseOverFontColor(1, 0.6, 0.6, 1)
    cls:SetText("X")
    cls:SetHandler("OnClicked", function() win:SetHidden(true) end)

    return win
end

-- ═══════════════════════════════════════════════
-- HELPER: Create a card display
-- ═══════════════════════════════════════════════
local function MakeCard(name, parent, w, h)
    local ctrl = WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL)
    ctrl:SetDimensions(w, h)
    ctrl:SetMouseEnabled(true)

    local bg = WINDOW_MANAGER:CreateControl(name .. "_BG", ctrl, CT_BACKDROP)
    bg:SetAnchorFill(ctrl)
    bg:SetCenterColor(0.10, 0.08, 0.14, 1)
    bg:SetEdgeColor(0.45, 0.38, 0.18, 1)
    bg:SetEdgeTexture("", 4, 4, 4, 4)
    bg:SetMouseEnabled(false)

    -- Inner dark area for card art
    local inner = WINDOW_MANAGER:CreateControl(name .. "_Inner", ctrl, CT_BACKDROP)
    inner:SetAnchor(TOPLEFT, ctrl, TOPLEFT, 4, 4)
    inner:SetAnchor(BOTTOMRIGHT, ctrl, BOTTOMRIGHT, -4, -4)
    inner:SetCenterColor(0.07, 0.06, 0.10, 1)
    inner:SetEdgeColor(0, 0, 0, 0)
    inner:SetMouseEnabled(false)

    -- Creature icon (ESO built-in texture, centered in card art area)
    local iconPad = math.max(6, math.floor(w * 0.10))
    local topPad = math.floor(h * 0.20)    -- leave room for name + stars
    local botPad = math.floor(h * 0.16)    -- leave room for bottom value
    local tex = WINDOW_MANAGER:CreateControl(name .. "_Tex", ctrl, CT_TEXTURE)
    tex:SetAnchor(TOPLEFT, ctrl, TOPLEFT, iconPad, topPad)
    tex:SetAnchor(BOTTOMRIGHT, ctrl, BOTTOMRIGHT, -iconPad, -botPad)
    tex:SetHidden(true)
    tex:SetMouseEnabled(false)
    tex:SetAlpha(0.85)

    -- Name
    local nm = WINDOW_MANAGER:CreateControl(name .. "_Name", ctrl, CT_LABEL)
    nm:SetFont(h >= 130 and "ZoFontGameBold" or "ZoFontGameSmall")
    nm:SetColor(1, 0.9, 0.6, 1)
    nm:SetAnchor(TOP, ctrl, TOP, 0, 3)
    nm:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    nm:SetDimensions(w - 6, 16)
    nm:SetMouseEnabled(false)

    -- Stars
    local st = WINDOW_MANAGER:CreateControl(name .. "_Stars", ctrl, CT_LABEL)
    st:SetFont(h >= 130 and "ZoFontGame" or "ZoFontGameSmall")
    st:SetAnchor(TOP, nm, BOTTOM, 0, -3)
    st:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    st:SetMouseEnabled(false)

    -- Edge values — positioned over the card art
    local edgeFont = h >= 130 and "ZoFontWinH2" or (h >= 100 and "ZoFontWinH3" or "ZoFontGameBold")
    local topOffset = h >= 130 and 36 or (h >= 100 and 26 or 22)
    local bottomOffset = h >= 130 and -6 or -4
    local sideOffsetX = h >= 130 and 8 or 5
    local sideOffsetY = h >= 130 and 8 or 4

    local topV = WINDOW_MANAGER:CreateControl(name .. "_Top", ctrl, CT_LABEL)
    topV:SetFont(edgeFont)
    topV:SetColor(1, 1, 1, 1)
    topV:SetAnchor(TOP, ctrl, TOP, 0, topOffset)
    topV:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    topV:SetMouseEnabled(false)

    local rightV = WINDOW_MANAGER:CreateControl(name .. "_Right", ctrl, CT_LABEL)
    rightV:SetFont(edgeFont)
    rightV:SetColor(1, 1, 1, 1)
    rightV:SetAnchor(RIGHT, ctrl, RIGHT, -sideOffsetX, sideOffsetY)
    rightV:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    rightV:SetMouseEnabled(false)

    local bottomV = WINDOW_MANAGER:CreateControl(name .. "_Bottom", ctrl, CT_LABEL)
    bottomV:SetFont(edgeFont)
    bottomV:SetColor(1, 1, 1, 1)
    bottomV:SetAnchor(BOTTOM, ctrl, BOTTOM, 0, bottomOffset)
    bottomV:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    bottomV:SetMouseEnabled(false)

    local leftV = WINDOW_MANAGER:CreateControl(name .. "_Left", ctrl, CT_LABEL)
    leftV:SetFont(edgeFont)
    leftV:SetColor(1, 1, 1, 1)
    leftV:SetAnchor(LEFT, ctrl, LEFT, sideOffsetX, sideOffsetY)
    leftV:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    leftV:SetMouseEnabled(false)

    -- Element indicator (bottom-left corner)
    local elemLbl = WINDOW_MANAGER:CreateControl(name .. "_Elem", ctrl, CT_LABEL)
    elemLbl:SetFont("ZoFontGameSmall")
    elemLbl:SetAnchor(BOTTOMLEFT, ctrl, BOTTOMLEFT, 6, -4)
    elemLbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    elemLbl:SetMouseEnabled(false)
    elemLbl:SetHidden(true)

    return ctrl
end

-- ═══════════════════════════════════════════════
-- HELPER: Set card data
-- ═══════════════════════════════════════════════
local function FillCard(ctrl, data, showVals)
    if not ctrl or not data then return end
    local n = ctrl:GetName()

    local nm = WINDOW_MANAGER:GetControlByName(n .. "_Name")
    if nm then nm:SetText(data.name) end

    local st = WINDOW_MANAGER:GetControlByName(n .. "_Stars")
    if st then
        local c = STAR_COLORS[data.stars] or STAR_COLORS[1]
        st:SetColor(c.r, c.g, c.b, 1)
        st:SetText(string.rep("*", data.stars))
    end

    local tex = WINDOW_MANAGER:GetControlByName(n .. "_Tex")
    if tex and data.icon then
        tex:SetTexture(data.icon)
        tex:SetHidden(false)
    elseif tex then
        tex:SetHidden(true)
    end

    local function vs(v) return v >= 10 and "A" or tostring(v) end

    if showVals ~= false then
        local topV = WINDOW_MANAGER:GetControlByName(n .. "_Top")
        if topV then topV:SetText(vs(data.top)) end
        local rightV = WINDOW_MANAGER:GetControlByName(n .. "_Right")
        if rightV then rightV:SetText(vs(data.right)) end
        local bottomV = WINDOW_MANAGER:GetControlByName(n .. "_Bottom")
        if bottomV then bottomV:SetText(vs(data.bottom)) end
        local leftV = WINDOW_MANAGER:GetControlByName(n .. "_Left")
        if leftV then leftV:SetText(vs(data.left)) end
    else
        for _, s in ipairs({"_Top", "_Right", "_Bottom", "_Left"}) do
            local lbl = WINDOW_MANAGER:GetControlByName(n .. s)
            if lbl then lbl:SetText("?") end
        end
    end

    -- Element indicator
    local elemLbl = WINDOW_MANAGER:GetControlByName(n .. "_Elem")
    if elemLbl then
        if data.element then
            local ELEM_DISPLAY = {
                fire      = { abbr = "F", r = 1.0,  g = 0.4,  b = 0.1  },
                ice       = { abbr = "I", r = 0.4,  g = 0.85, b = 1.0  },
                lightning = { abbr = "L", r = 0.9,  g = 0.9,  b = 0.2  },
                earth     = { abbr = "E", r = 0.65, g = 0.5,  b = 0.25 },
                water     = { abbr = "W", r = 0.2,  g = 0.6,  b = 1.0  },
                air       = { abbr = "A", r = 0.7,  g = 1.0,  b = 0.7  },
            }
            local ed = ELEM_DISPLAY[data.element]
            if ed then
                elemLbl:SetText(ed.abbr)
                elemLbl:SetColor(ed.r, ed.g, ed.b, 1)
                elemLbl:SetHidden(false)
            else
                elemLbl:SetHidden(true)
            end
        else
            elemLbl:SetHidden(true)
        end
    end
end

-- ═══════════════════════════════════════════════
-- HELPER: Color card by owner
-- ═══════════════════════════════════════════════
local function ColorCard(ctrl, owner)
    if not ctrl then return end
    local n = ctrl:GetName()
    local bg = WINDOW_MANAGER:GetControlByName(n .. "_BG")
    local inner = WINDOW_MANAGER:GetControlByName(n .. "_Inner")
    if not bg then return end
    local GL = TT.GameLogic
    if owner == GL.PLAYER then
        bg:SetCenterColor(PLAYER_BG.r, PLAYER_BG.g, PLAYER_BG.b, 0.95)
        bg:SetEdgeColor(PLAYER_EDGE.r, PLAYER_EDGE.g, PLAYER_EDGE.b, 1)
        if inner then inner:SetCenterColor(PLAYER_BG.r * 0.8, PLAYER_BG.g * 0.8, PLAYER_BG.b * 0.8, 0.9) end
    else
        bg:SetCenterColor(NPC_BG.r, NPC_BG.g, NPC_BG.b, 0.95)
        bg:SetEdgeColor(NPC_EDGE.r, NPC_EDGE.g, NPC_EDGE.b, 1)
        if inner then inner:SetCenterColor(NPC_BG.r * 0.8, NPC_BG.g * 0.8, NPC_BG.b * 0.8, 0.9) end
    end
end


-- ═══════════════════════════════════════════════
-- GAME BOARD
-- ═══════════════════════════════════════════════
function UI:CreateGameBoard()
    self.gameBoard = MakeWindow("TTB", BOARD_W, BOARD_H, "Triple Triad")

    -- Score
    self.scoreLabel = WINDOW_MANAGER:CreateControl("TTB_Score", self.gameBoard, CT_LABEL)
    self.scoreLabel:SetFont("ZoFontWinH3")
    self.scoreLabel:SetColor(1, 1, 1, 1)
    self.scoreLabel:SetAnchor(TOP, self.gameBoard, TOP, 0, 48)
    self.scoreLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    -- Grid anchor point (centered in window) — MUST NOT consume mouse
    local gridAnchor = WINDOW_MANAGER:CreateControl("TTB_GridAnchor", self.gameBoard, CT_CONTROL)
    gridAnchor:SetDimensions(GRID_W, GRID_H)
    gridAnchor:SetAnchor(TOP, self.scoreLabel, BOTTOM, 0, 12)
    gridAnchor:SetMouseEnabled(false)

    -- 3x3 cells — use CT_CONTROL with CT_BACKDROP child (CT_BACKDROP doesn't fire OnMouseUp in ESO)
    self.boardCells = {}
    for r = 1, 3 do
        self.boardCells[r] = {}
        for c = 1, 3 do
            local cn = "TTB_C" .. r .. c

            -- Outer container that receives clicks
            local cellWrap = WINDOW_MANAGER:CreateControl(cn, gridAnchor, CT_CONTROL)
            cellWrap:SetDimensions(CELL_W, CELL_H)
            cellWrap:SetAnchor(TOPLEFT, gridAnchor, TOPLEFT,
                (c - 1) * (CELL_W + CELL_GAP),
                (r - 1) * (CELL_H + CELL_GAP))
            cellWrap:SetMouseEnabled(true)

            -- Visual backdrop (child, does NOT consume mouse)
            local cellBG = WINDOW_MANAGER:CreateControl(cn .. "_BG", cellWrap, CT_BACKDROP)
            cellBG:SetAnchorFill(cellWrap)
            cellBG:SetCenterColor(0.07, 0.07, 0.10, 0.95)
            cellBG:SetEdgeColor(0.35, 0.30, 0.12, 1)
            cellBG:SetEdgeTexture("", 4, 4, 4, 4)
            cellBG:SetMouseEnabled(false)

            -- Card display inside cell
            local cardCtrl = MakeCard(cn .. "K", cellWrap, CARD_W, CARD_H)
            cardCtrl:SetAnchor(CENTER, cellWrap, CENTER, 0, 0)
            cardCtrl:SetHidden(true)
            cardCtrl:SetMouseEnabled(false)

            -- Click handler on the wrapper CT_CONTROL
            local row, col = r, c
            cellWrap:SetHandler("OnMouseUp", function(_, button, upInside)
                if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
                    TT.GameLogic:PlayerPlaceCard(row, col)
                end
            end)

            cellWrap:SetHandler("OnMouseEnter", function()
                local GL = TT.GameLogic
                if GL.gameActive and GL:IsPlayerTurn() and GL.selectedCard and not GL.board[row][col] then
                    cellBG:SetCenterColor(0.18, 0.22, 0.30, 0.95)
                    cellBG:SetEdgeColor(1, 0.84, 0, 1)
                end
            end)

            cellWrap:SetHandler("OnMouseExit", function()
                if not TT.GameLogic.board[row][col] then
                    cellBG:SetCenterColor(0.07, 0.07, 0.10, 0.95)
                    cellBG:SetEdgeColor(0.35, 0.30, 0.12, 1)
                end
            end)

            self.boardCells[r][c] = { cell = cellWrap, cellBG = cellBG, cardCtrl = cardCtrl }
        end
    end

    -- Player hand (left)
    self.playerHandCards = {}
    local phAnchor = WINDOW_MANAGER:CreateControl("TTB_PHA", self.gameBoard, CT_CONTROL)
    phAnchor:SetDimensions(HAND_CARD_W, HAND_CARD_H * 5 + HAND_GAP * 4)
    phAnchor:SetAnchor(RIGHT, gridAnchor, LEFT, -20, 0)
    phAnchor:SetMouseEnabled(false)

    local phTitle = WINDOW_MANAGER:CreateControl("TTB_PHT", self.gameBoard, CT_LABEL)
    phTitle:SetFont("ZoFontWinH3")
    phTitle:SetColor(PLAYER_EDGE.r, PLAYER_EDGE.g, PLAYER_EDGE.b, 1)
    phTitle:SetText("YOUR HAND")
    phTitle:SetAnchor(BOTTOM, phAnchor, TOP, 0, -6)
    phTitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    for i = 1, 5 do
        local cn = "TTB_PH" .. i
        local card = MakeCard(cn, phAnchor, HAND_CARD_W, HAND_CARD_H)
        card:SetAnchor(TOPLEFT, phAnchor, TOPLEFT, 0, (i - 1) * (HAND_CARD_H + HAND_GAP))
        card:SetHidden(true)

        local idx = i
        card:SetHandler("OnMouseUp", function(_, button, upInside)
            if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
                TT.GameLogic:PlayerSelectCard(idx)
            end
        end)
        card:SetHandler("OnMouseEnter", function()
            local bg = WINDOW_MANAGER:GetControlByName(cn .. "_BG")
            if bg then bg:SetEdgeColor(1, 0.84, 0, 1) end
        end)
        card:SetHandler("OnMouseExit", function()
            local bg = WINDOW_MANAGER:GetControlByName(cn .. "_BG")
            if bg and TT.GameLogic.selectedCard ~= idx then
                bg:SetEdgeColor(PLAYER_EDGE.r, PLAYER_EDGE.g, PLAYER_EDGE.b, 1)
            end
        end)

        self.playerHandCards[i] = card
    end

    -- NPC hand (right)
    self.npcHandCards = {}
    local nhAnchor = WINDOW_MANAGER:CreateControl("TTB_NHA", self.gameBoard, CT_CONTROL)
    nhAnchor:SetDimensions(HAND_CARD_W, HAND_CARD_H * 5 + HAND_GAP * 4)
    nhAnchor:SetAnchor(LEFT, gridAnchor, RIGHT, 20, 0)
    nhAnchor:SetMouseEnabled(false)

    self.npcNameLabel = WINDOW_MANAGER:CreateControl("TTB_NHT", self.gameBoard, CT_LABEL)
    self.npcNameLabel:SetFont("ZoFontWinH3")
    self.npcNameLabel:SetColor(NPC_EDGE.r, NPC_EDGE.g, NPC_EDGE.b, 1)
    self.npcNameLabel:SetText("OPPONENT")
    self.npcNameLabel:SetAnchor(BOTTOM, nhAnchor, TOP, 0, -6)
    self.npcNameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    for i = 1, 5 do
        local cn = "TTB_NH" .. i
        local card = MakeCard(cn, nhAnchor, HAND_CARD_W, HAND_CARD_H)
        card:SetAnchor(TOPLEFT, nhAnchor, TOPLEFT, 0, (i - 1) * (HAND_CARD_H + HAND_GAP))
        card:SetHidden(true)
        card:SetMouseEnabled(false)
        self.npcHandCards[i] = card
    end

    -- Turn indicator
    self.turnIndicator = WINDOW_MANAGER:CreateControl("TTB_Turn", self.gameBoard, CT_LABEL)
    self.turnIndicator:SetFont("ZoFontWinH2")
    self.turnIndicator:SetColor(0.3, 0.7, 1, 1)
    self.turnIndicator:SetText("")
    self.turnIndicator:SetAnchor(BOTTOM, self.gameBoard, BOTTOM, 0, -45)
    self.turnIndicator:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    -- Forfeit
    local forfeit = WINDOW_MANAGER:CreateControl("TTB_Forfeit", self.gameBoard, CT_BUTTON)
    forfeit:SetDimensions(120, 34)
    forfeit:SetAnchor(BOTTOMLEFT, self.gameBoard, BOTTOMLEFT, 20, -12)
    forfeit:SetFont("ZoFontWinH4")
    forfeit:SetNormalFontColor(1, 0.3, 0.3, 1)
    forfeit:SetMouseOverFontColor(1, 0.6, 0.6, 1)
    forfeit:SetText("Forfeit")
    forfeit:SetHandler("OnClicked", function() TT.GameLogic:Forfeit() end)

    -- Rules display + clickable help button
    self.rulesLabel = WINDOW_MANAGER:CreateControl("TTB_Rules", self.gameBoard, CT_LABEL)
    self.rulesLabel:SetFont("ZoFontGame")
    self.rulesLabel:SetColor(0.6, 0.6, 0.6, 1)
    self.rulesLabel:SetAnchor(BOTTOMRIGHT, self.gameBoard, BOTTOMRIGHT, -60, -16)
    self.rulesLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    local rulesBtn = WINDOW_MANAGER:CreateControl("TTB_RulesBtn", self.gameBoard, CT_BUTTON)
    rulesBtn:SetDimensions(36, 26)
    rulesBtn:SetAnchor(BOTTOMRIGHT, self.gameBoard, BOTTOMRIGHT, -16, -12)
    rulesBtn:SetFont("ZoFontWinH4")
    rulesBtn:SetNormalFontColor(0.3, 0.7, 1, 1)
    rulesBtn:SetMouseOverFontColor(0.5, 0.9, 1, 1)
    rulesBtn:SetText("[?]")
    rulesBtn:SetHandler("OnClicked", function() TT.UI:ToggleRules() end)
end

-- ─────────────────────────────────────────────
function UI:ShowGameBoard()
    if not self.gameBoard then return end
    local GL = TT.GameLogic

    if GL.currentNPC then
        self.npcNameLabel:SetText(GL.currentNPC.name)
    end

    -- Rules text
    local r = {}
    if GL.rules.same then table.insert(r, "|cFFFF00Same|r") end
    if GL.rules.plus then table.insert(r, "|cFF8800Plus|r") end
    if GL.rules.elemental then table.insert(r, "|cFF00FFElemental|r") end
    self.rulesLabel:SetText(#r > 0 and ("Rules: " .. table.concat(r, "  ")) or "Standard Rules")

    -- Player hand
    local ph = GL:GetPlayerHand()
    for i = 1, 5 do
        local c = self.playerHandCards[i]
        if ph[i] then
            FillCard(c, ph[i].card, true)
            ColorCard(c, GL.PLAYER)
            c:SetHidden(false)
            c:SetAlpha(1)
            c:SetMouseEnabled(true)  -- Re-enable for new game
            -- Reset edge color (might be dimmed from previous game)
            local bg = WINDOW_MANAGER:GetControlByName(c:GetName() .. "_BG")
            if bg then
                bg:SetEdgeColor(PLAYER_EDGE.r, PLAYER_EDGE.g, PLAYER_EDGE.b, 1)
                bg:SetCenterColor(PLAYER_BG.r, PLAYER_BG.g, PLAYER_BG.b, 0.95)
            end
        else
            c:SetHidden(true)
        end
    end

    -- NPC hand
    local nh = GL:GetNPCHand()
    local showV = GL.currentNPC and GL.currentNPC.rank <= 2
    for i = 1, 5 do
        local c = self.npcHandCards[i]
        if nh[i] then
            FillCard(c, nh[i].card, showV)
            ColorCard(c, GL.NPC)
            c:SetHidden(false)
            c:SetAlpha(1)
        else
            c:SetHidden(true)
        end
    end

    -- Clear board
    for row = 1, 3 do
        for col = 1, 3 do
            self.boardCells[row][col].cardCtrl:SetHidden(true)
            self.boardCells[row][col].cellBG:SetCenterColor(0.07, 0.07, 0.10, 0.95)
            self.boardCells[row][col].cellBG:SetEdgeColor(0.35, 0.30, 0.12, 1)
        end
    end

    -- Set initial turn indicator based on who goes first
    if GL:IsPlayerTurn() then
        self.turnIndicator:SetText("Your Turn — Click a card in your hand to select it")
        self.turnIndicator:SetColor(0.3, 0.7, 1, 1)
    else
        local name = GL.currentNPC and GL.currentNPC.name or "Opponent"
        self.turnIndicator:SetText(name .. " goes first...")
        self.turnIndicator:SetColor(1, 0.3, 0.3, 1)
    end
    self.scoreLabel:SetText("")

    self.gameBoard:SetHidden(false)
    SCENE_MANAGER:SetInUIMode(true)
end

function UI:HideGameBoard()
    if self.gameBoard then self.gameBoard:SetHidden(true) end
    SCENE_MANAGER:SetInUIMode(false)
end

-- ─────────────────────────────────────────────
function UI:UpdateGameBoard()
    if not self.gameBoard or self.gameBoard:IsHidden() then return end
    local GL = TT.GameLogic
    local board = GL:GetBoardState()

    -- Board cards
    for row = 1, 3 do
        for col = 1, 3 do
            local data = board[row] and board[row][col]
            local ui = self.boardCells[row][col]
            if data then
                FillCard(ui.cardCtrl, data.card, true)
                local cardBG = WINDOW_MANAGER:GetControlByName(ui.cardCtrl:GetName() .. "_BG")
                if data.owner == GL.PLAYER then
                    -- Blue tinted card + bright blue cell border
                    if cardBG then
                        cardBG:SetCenterColor(0.06, 0.10, 0.25, 0.95)
                        cardBG:SetEdgeColor(0.2, 0.6, 1.0, 1)
                    end
                    ui.cellBG:SetCenterColor(0.04, 0.08, 0.20, 0.7)
                    ui.cellBG:SetEdgeColor(0.2, 0.6, 1.0, 1)
                else
                    -- Red tinted card + bright red cell border
                    if cardBG then
                        cardBG:SetCenterColor(0.25, 0.06, 0.06, 0.95)
                        cardBG:SetEdgeColor(1.0, 0.2, 0.2, 1)
                    end
                    ui.cellBG:SetCenterColor(0.20, 0.04, 0.04, 0.7)
                    ui.cellBG:SetEdgeColor(1.0, 0.2, 0.2, 1)
                end
                ui.cardCtrl:SetHidden(false)
            end
        end
    end

    -- Dim played cards in hands
    local ph = GL:GetPlayerHand()
    for i, e in ipairs(ph) do
        if self.playerHandCards[i] then
            self.playerHandCards[i]:SetAlpha(e.inHand and 1.0 or 0.2)
            self.playerHandCards[i]:SetMouseEnabled(e.inHand)
        end
    end
    local nh = GL:GetNPCHand()
    for i, e in ipairs(nh) do
        if self.npcHandCards[i] then
            self.npcHandCards[i]:SetAlpha(e.inHand and 1.0 or 0.2)
        end
    end

    -- Turn indicator
    if not GL.gameActive then
        self.turnIndicator:SetText("Game Over!")
        self.turnIndicator:SetColor(1, 0.84, 0, 1)
    elseif GL:IsPlayerTurn() then
        if GL.selectedCard then
            self.turnIndicator:SetText("Your Turn — Click an empty cell on the board")
            self.turnIndicator:SetColor(1, 0.84, 0, 1)
        else
            self.turnIndicator:SetText("Your Turn — Click a card in your hand to select it")
            self.turnIndicator:SetColor(0.3, 0.7, 1, 1)
        end
    else
        local name = GL.currentNPC and GL.currentNPC.name or "Opponent"
        self.turnIndicator:SetText(name .. " is thinking...")
        self.turnIndicator:SetColor(1, 0.3, 0.3, 1)
    end

    -- Score - count board ownership only
    local pTotal, nTotal = 0, 0
    for row = 1, 3 do for col = 1, 3 do
        local d = board[row] and board[row][col]
        if d then
            if d.owner == GL.PLAYER then pTotal = pTotal + 1 else nTotal = nTotal + 1 end
        end
    end end
    self.scoreLabel:SetText(string.format("|c4488FFYou: %d|r       |cFF4444%s: %d|r",
        pTotal, GL.currentNPC and GL.currentNPC.name or "Opponent", nTotal))
end

-- ─────────────────────────────────────────────
function UI:HighlightSelectedCard(handIndex)
    for i, card in ipairs(self.playerHandCards) do
        local bg = WINDOW_MANAGER:GetControlByName(card:GetName() .. "_BG")
        if bg then
            if i == handIndex then
                bg:SetEdgeColor(1, 0.84, 0, 1)
                bg:SetCenterColor(0.22, 0.26, 0.42, 1)
            else
                bg:SetEdgeColor(PLAYER_EDGE.r, PLAYER_EDGE.g, PLAYER_EDGE.b, 1)
                bg:SetCenterColor(PLAYER_BG.r, PLAYER_BG.g, PLAYER_BG.b, 0.95)
            end
        end
    end
    self.turnIndicator:SetText("Your Turn — Click an empty cell on the board")
    self.turnIndicator:SetColor(1, 0.84, 0, 1)
end


-- ═══════════════════════════════════════════════
-- RESULT WINDOW
-- ═══════════════════════════════════════════════
function UI:CreateResultWindow()
    self.resultWindow = MakeWindow("TTR", 420, 250, "Match Result")
    -- Ensure result window draws on top of game board
    self.resultWindow:SetDrawLayer(DL_OVERLAY)
    self.resultWindow:SetDrawTier(DT_HIGH)
    self.resultWindow:SetDrawLevel(10)
end

function UI:ShowGameResult(result, pScore, nScore)
    if not self.resultWindow then return end

    -- Update the turn indicator to show game over
    self.turnIndicator:SetText("Game Over!")
    self.turnIndicator:SetColor(1, 0.84, 0, 1)

    local ttl = WINDOW_MANAGER:GetControlByName("TTR_Title")
    if ttl then
        if result == "win" then ttl:SetText("|c00FF00VICTORY!|r")
        elseif result == "loss" then ttl:SetText("|cFF4444DEFEAT|r")
        else ttl:SetText("|cFFFF00DRAW|r") end
    end

    local scoreLbl = WINDOW_MANAGER:GetControlByName("TTR_ScoreLbl")
    if not scoreLbl then
        scoreLbl = WINDOW_MANAGER:CreateControl("TTR_ScoreLbl", self.resultWindow, CT_LABEL)
        scoreLbl:SetFont("ZoFontWinH1")
        scoreLbl:SetColor(1, 1, 1, 1)
        scoreLbl:SetAnchor(CENTER, self.resultWindow, CENTER, 0, 10)
        scoreLbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    end
    scoreLbl:SetText(string.format("%d  —  %d", pScore, nScore))

    if not WINDOW_MANAGER:GetControlByName("TTR_Again") then
        local btn1 = WINDOW_MANAGER:CreateControl("TTR_Again", self.resultWindow, CT_BUTTON)
        btn1:SetDimensions(140, 40)
        btn1:SetAnchor(BOTTOM, self.resultWindow, BOTTOM, -85, -20)
        btn1:SetFont("ZoFontWinH3")
        btn1:SetNormalFontColor(0.3, 0.9, 0.3, 1)
        btn1:SetMouseOverFontColor(0.5, 1, 0.5, 1)
        btn1:SetText("Play Again")
        btn1:SetHandler("OnClicked", function()
            self.resultWindow:SetHidden(true)
            self:HideGameBoard()
            if TT.GameLogic.currentNPC then
                -- Check cooldown before allowing replay
                local npcName = TT.GameLogic.currentNPC.name
                local cooldownKey = string.lower(npcName)
                local cd = TT.npcCooldowns and TT.npcCooldowns[cooldownKey]
                if cd and cd.cooldownEnd then
                    local remaining = cd.cooldownEnd - GetGameTimeMilliseconds()
                    if remaining > 0 then
                        local secs = math.ceil(remaining / 1000)
                        local mins = math.floor(secs / 60)
                        secs = secs % 60
                        TT:Msg(string.format("|cFFD700[Triple Triad]|r |cFF4444%s|r needs a break. Try again in |cFFFFFF%d:%02d|r.", npcName, mins, secs))
                        return
                    else
                        -- Cooldown expired, reset
                        TT.npcCooldowns[cooldownKey] = nil
                    end
                end
                TT.GameLogic:StartGame(TT.GameLogic.currentNPC)
            end
        end)

        local btn2 = WINDOW_MANAGER:CreateControl("TTR_Done", self.resultWindow, CT_BUTTON)
        btn2:SetDimensions(140, 40)
        btn2:SetAnchor(BOTTOM, self.resultWindow, BOTTOM, 85, -20)
        btn2:SetFont("ZoFontWinH3")
        btn2:SetNormalFontColor(1, 0.8, 0.3, 1)
        btn2:SetMouseOverFontColor(1, 1, 0.5, 1)
        btn2:SetText("Quit")
        btn2:SetHandler("OnClicked", function()
            self.resultWindow:SetHidden(true)
            self:HideGameBoard()
        end)
    end

    -- Bring result window to front
    self.resultWindow:SetHidden(false)
    self.resultWindow:BringWindowToTop()
end


-- ═══════════════════════════════════════════════
-- COLLECTION WINDOW (with scroll, owned cards only)
-- ═══════════════════════════════════════════════
function UI:CreateCollectionWindow()
    self.collectionWindow = MakeWindow("TTC", 800, 700, "Card Collection")

    self.collStats = WINDOW_MANAGER:CreateControl("TTC_Stats", self.collectionWindow, CT_LABEL)
    self.collStats:SetFont("ZoFontWinH4")
    self.collStats:SetColor(0.8, 0.8, 0.8, 1)
    self.collStats:SetAnchor(TOP, self.collectionWindow, TOP, 0, 52)
    self.collStats:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    -- How to Play button
    local helpBtn = WINDOW_MANAGER:CreateControl("TTC_Help", self.collectionWindow, CT_BUTTON)
    helpBtn:SetDimensions(36, 26)
    helpBtn:SetAnchor(TOPRIGHT, self.collectionWindow, TOPRIGHT, -48, 14)
    helpBtn:SetFont("ZoFontWinH4")
    helpBtn:SetNormalFontColor(0.3, 0.7, 1, 1)
    helpBtn:SetMouseOverFontColor(0.5, 0.9, 1, 1)
    helpBtn:SetText("[?]")
    helpBtn:SetHandler("OnClicked", function() TT.UI:ToggleRules() end)

    -- ZO_ScrollContainer (native clipping + scrollbar)
    local scrollContainer, scrollChild = MakeScrollArea("TTC_Scroll", self.collectionWindow, 770, 590,
        TOP, self.collStats, BOTTOM, 0, 10)
    self.collContent = scrollChild
    self.collCards = {}
end

function UI:PopulateCollection()
    for _, c in ipairs(self.collCards) do c:SetHidden(true) end

    local cards = TT.CardDatabase
    local owned = TT.sv.collectedCards

    -- Build list of owned cards only
    local ownedCards = {}
    for _, cd in ipairs(cards) do
        if owned[cd.id] == true then
            table.insert(ownedCards, cd)
        end
    end

    self.collStats:SetText(string.format("Collected: %d / %d   |   W:%d  L:%d  D:%d",
        #ownedCards, #cards, TT.sv.wins, TT.sv.losses, TT.sv.draws))

    local cols = 6
    local cw, ch, px, py = 108, 140, 12, 8

    for i, cd in ipairs(ownedCards) do
        local cn = "TTC_C" .. i
        local ctrl = self.collCards[i]
        if not ctrl then
            ctrl = MakeCard(cn, self.collContent, cw, ch)
            self.collCards[i] = ctrl
        end

        ctrl:ClearAnchors()
        local row = math.floor((i-1) / cols)
        local col = (i-1) % cols
        ctrl:SetAnchor(TOPLEFT, self.collContent, TOPLEFT, col * (cw+px), row * (ch+py))

        FillCard(ctrl, cd, true)
        ctrl:SetAlpha(1.0)
        ctrl._savedAlpha = 1.0

        -- Add quantity label        local qtyName = cn .. "_Qty"
        local qtyLbl = WINDOW_MANAGER:GetControlByName(qtyName)
        if not qtyLbl then
            qtyLbl = WINDOW_MANAGER:CreateControl(qtyName, ctrl, CT_LABEL)
            qtyLbl:SetFont("ZoFontGameBold")
            qtyLbl:SetAnchor(BOTTOMRIGHT, ctrl, BOTTOMRIGHT, -6, -4)
            qtyLbl:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            qtyLbl:SetMouseEnabled(false)
        end
        local qty = TT.sv.cardMultiples[cd.id] or 1
        if qty > 1 then
            qtyLbl:SetText(string.format("|c00FF00x%d|r", qty))
        else
            qtyLbl:SetText("")
        end
        qtyLbl:SetHidden(false)

        local cardData = cd
        ctrl:SetHandler("OnMouseEnter", function()
            InformationTooltip:ClearLines()
            InformationTooltip:SetOwner(ctrl, BOTTOM, 0, 5)
            local sc = STAR_COLORS[cardData.stars]
            InformationTooltip:AddLine(cardData.name, "ZoFontWinH3", 1, 0.84, 0, 1)
            InformationTooltip:AddLine(string.rep("*", cardData.stars) .. " (" .. cardData.stars .. " Star)", "ZoFontGame", sc.r, sc.g, sc.b, 1)
            InformationTooltip:AddLine(string.format("T:%d  R:%d  B:%d  L:%d", cardData.top, cardData.right, cardData.bottom, cardData.left), "ZoFontGame", 0.8, 0.8, 0.8, 1)
            if cardData.element then InformationTooltip:AddLine("Element: "..cardData.element, "ZoFontGame", 0.6, 0.8, 1, 1) end
            InformationTooltip:AddLine(cardData.desc, "ZoFontGameSmall", 0.6, 0.6, 0.6, 1)
            InformationTooltip:AddLine("Copies owned: "..qty, "ZoFontGameSmall", 0.5, 0.8, 0.5, 1)
        end)
        ctrl:SetHandler("OnMouseExit", function()
            InformationTooltip:ClearLines()
            InformationTooltip:SetHidden(true)
        end)

        ctrl:SetHidden(false)
    end
end

function UI:ToggleCollection()
    if not self.collectionWindow then return end
    if self.collectionWindow:IsHidden() then
        self:PopulateCollection()
        self.collectionWindow:SetHidden(false)
        SCENE_MANAGER:SetInUIMode(true)
    else
        self.collectionWindow:SetHidden(true)
        SCENE_MANAGER:SetInUIMode(false)
    end
end


-- ═══════════════════════════════════════════════
-- STATS WINDOW
-- ═══════════════════════════════════════════════
function UI:CreateStatsWindow()
    self.statsWindow = MakeWindow("TTS", 500, 550, "Statistics")

    -- Summary section at top
    self.statsSummary = WINDOW_MANAGER:CreateControl("TTS_Summary", self.statsWindow, CT_LABEL)
    self.statsSummary:SetFont("ZoFontWinH3")
    self.statsSummary:SetColor(1, 1, 1, 1)
    self.statsSummary:SetAnchor(TOP, self.statsWindow, TOP, 0, 55)
    self.statsSummary:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    -- Divider label
    local divider = WINDOW_MANAGER:CreateControl("TTS_Divider", self.statsWindow, CT_LABEL)
    divider:SetFont("ZoFontWinH4")
    divider:SetColor(1, 0.84, 0, 1)
    divider:SetText("NPC Records")
    divider:SetAnchor(TOP, self.statsSummary, BOTTOM, 0, 16)
    divider:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    -- ZO_ScrollContainer (native clipping + scrollbar)
    local scrollContainer, scrollChild = MakeScrollArea("TTS_Scroll", self.statsWindow, 460, 390,
        TOP, divider, BOTTOM, 0, 10)
    self.statsContent = scrollChild
    self.statsRows = {}
end

function UI:PopulateStats()
    -- Hide old rows
    for _, row in ipairs(self.statsRows) do row:SetHidden(true) end

    local total = #TT.CardDatabase
    local collected = TT:GetCollectedCount()

    self.statsSummary:SetText(string.format(
        "Cards: |c00FF00%d|r / |cFFFFFF%d|r     |c00FF00%d|rW  |cFF4444%d|rL  |cFFFF00%d|rD",
        collected, total, TT.sv.wins, TT.sv.losses, TT.sv.draws))

    -- Build sorted NPC list
    local names = {}
    if TT.sv.npcStats then
        for name, _ in pairs(TT.sv.npcStats) do
            table.insert(names, name)
        end
        table.sort(names)
    end

    local rowH = 32
    local y = 0

    if #names == 0 then
        local row = self.statsRows[1]
        if not row then
            row = WINDOW_MANAGER:CreateControl("TTS_Row1", self.statsContent, CT_LABEL)
            row:SetFont("ZoFontWinH4")
            row:SetColor(0.5, 0.5, 0.5, 1)
            row:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            self.statsRows[1] = row
        end
        row:ClearAnchors()
        row:SetAnchor(TOP, self.statsContent, TOP, 0, 20)
        row:SetText("No matches played yet.")
        row:SetHidden(false)
        self.statsContentHeight = 60
    else
        for i, name in ipairs(names) do
            local s = TT.sv.npcStats[name]
            local totalGames = s.wins + s.losses + s.draws

            -- NPC name row
            local nameIdx = (i - 1) * 2 + 1
            local nameRow = self.statsRows[nameIdx]
            if not nameRow then
                nameRow = WINDOW_MANAGER:CreateControl("TTS_Row" .. nameIdx, self.statsContent, CT_LABEL)
                nameRow:SetFont("ZoFontWinH3")
                nameRow:SetDimensions(460, rowH)
                nameRow:SetMouseEnabled(true)
                self.statsRows[nameIdx] = nameRow
            end
            nameRow:ClearAnchors()
            nameRow:SetAnchor(TOPLEFT, self.statsContent, TOPLEFT, 10, y)
            nameRow:SetText(string.format("|cFF8800%s|r", name))
            nameRow:SetHidden(false)

            -- Stats row
            local statIdx = (i - 1) * 2 + 2
            local statRow = self.statsRows[statIdx]
            if not statRow then
                statRow = WINDOW_MANAGER:CreateControl("TTS_Row" .. statIdx, self.statsContent, CT_LABEL)
                statRow:SetFont("ZoFontWinH4")
                statRow:SetDimensions(460, rowH - 4)
                statRow:SetMouseEnabled(true)
                self.statsRows[statIdx] = statRow
            end
            statRow:ClearAnchors()
            statRow:SetAnchor(TOPLEFT, self.statsContent, TOPLEFT, 20, y + rowH)
            statRow:SetText(string.format(
                "|c00FF00%d Wins|r   |cFF4444%d Losses|r   |cFFFF00%d Draws|r   |c888888(%d games)|r",
                s.wins, s.losses, s.draws, totalGames))
            statRow:SetHidden(false)

            y = y + rowH * 2 + 8
        end
        self.statsContentHeight = y
    end
end

function UI:ToggleStats()
    if not self.statsWindow then return end
    if self.statsWindow:IsHidden() then
        self:PopulateStats()
        self.statsWindow:SetHidden(false)
        SCENE_MANAGER:SetInUIMode(true)
    else
        self.statsWindow:SetHidden(true)
        SCENE_MANAGER:SetInUIMode(false)
    end
end


-- ═══════════════════════════════════════════════
-- DECK BUILDER
-- ═══════════════════════════════════════════════
function UI:CreateDeckBuilder()
    self.deckWindow = MakeWindow("TTD", 780, 640, "Deck Builder")

    local instr = WINDOW_MANAGER:CreateControl("TTD_Instr", self.deckWindow, CT_LABEL)
    instr:SetFont("ZoFontGame")
    instr:SetColor(0.7, 0.7, 0.7, 1)
    instr:SetText("Click a deck slot above, then click a card below to assign it.")
    instr:SetAnchor(TOP, self.deckWindow, TOP, 0, 52)
    instr:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    self.deckSlots = {}
    local sw, sh = 108, 140
    local totalW = sw * 5 + 10 * 4
    local startX = -totalW / 2

    for i = 1, 5 do
        local cn = "TTD_S" .. i
        local slot = MakeCard(cn, self.deckWindow, sw, sh)
        slot:SetAnchor(TOPLEFT, self.deckWindow, TOP, startX + (i-1)*(sw+10), 75)

        local lbl = WINDOW_MANAGER:CreateControl(cn.."_Lbl", self.deckWindow, CT_LABEL)
        lbl:SetFont("ZoFontGameSmall")
        lbl:SetColor(0.5, 0.5, 0.5, 1)
        lbl:SetText("Slot "..i)
        lbl:SetAnchor(TOP, slot, BOTTOM, 0, 2)
        lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

        local idx = i
        slot:SetHandler("OnMouseUp", function(_, button, upInside)
            if upInside then
                self.selectedDeckSlot = idx
                self:HighlightDeckSlot(idx)
            end
        end)
        self.deckSlots[i] = slot
    end

    self.selectedDeckSlot = nil

    local avLbl = WINDOW_MANAGER:CreateControl("TTD_AvLbl", self.deckWindow, CT_LABEL)
    avLbl:SetFont("ZoFontWinH4")
    avLbl:SetColor(1, 0.84, 0, 1)
    avLbl:SetText("Available Cards")
    avLbl:SetAnchor(TOP, self.deckWindow, TOP, 0, 262)
    avLbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    -- ZO_ScrollContainer (native clipping + scrollbar)
    local scrollContainer, scrollChild = MakeScrollArea("TTD_Scroll", self.deckWindow, 740, 340,
        TOP, avLbl, BOTTOM, 0, 6)
    self.deckAvailCont = scrollChild
    self.deckAvailCards = {}
end

function UI:PopulateDeckBuilder()
    for i = 1, 5 do
        local cardId = TT.sv.selectedDeck[i]
        local card = TT:GetCard(cardId)
        local slot = self.deckSlots[i]
        if card and TT:HasCard(cardId) then
            FillCard(slot, card, true)
            slot:SetAlpha(1)
        else
            local n = slot:GetName()
            local nm = WINDOW_MANAGER:GetControlByName(n.."_Name")
            if nm then nm:SetText("[Empty]") end
            local st = WINDOW_MANAGER:GetControlByName(n.."_Stars")
            if st then st:SetText("") end
            for _, s in ipairs({"_Top","_Right","_Bottom","_Left"}) do
                local l = WINDOW_MANAGER:GetControlByName(n..s)
                if l then l:SetText("-") end
            end
            slot:SetAlpha(0.5)
        end
    end

    local ownedCards = TT:GetCollectedCards()
    local cols, cw, ch, px, py = 7, 88, 114, 6, 6

    for _, c in ipairs(self.deckAvailCards) do c:SetHidden(true) end

    for i, cd in ipairs(ownedCards) do
        local cn = "TTD_A" .. i
        local ctrl = self.deckAvailCards[i]
        if not ctrl then
            ctrl = MakeCard(cn, self.deckAvailCont, cw, ch)
            self.deckAvailCards[i] = ctrl
        end

        ctrl:ClearAnchors()
        local row = math.floor((i-1)/cols)
        local col = (i-1) % cols
        ctrl:SetAnchor(TOPLEFT, self.deckAvailCont, TOPLEFT, col*(cw+px), row*(ch+py))
        FillCard(ctrl, cd, true)

        local inDeck = false
        for _, did in ipairs(TT.sv.selectedDeck) do
            if did == cd.id then inDeck = true; break end
        end
        ctrl:SetAlpha(inDeck and 0.35 or 1.0)
        ctrl._savedAlpha = inDeck and 0.35 or 1.0

        local cData = cd        ctrl:SetHandler("OnMouseUp", function(_, button, upInside)
            if upInside and self.selectedDeckSlot then
                if TT:SetDeckCard(self.selectedDeckSlot, cData.id) then
                    d(string.format("|cFFD700[Triple Triad]|r Set |c00FF00%s|r to slot %d.", cData.name, self.selectedDeckSlot))
                    self:PopulateDeckBuilder()
                else
                    d("|cFFD700[Triple Triad]|r Card already in deck or invalid.")
                end
            elseif upInside then
                d("|cFFD700[Triple Triad]|r Click a deck slot first!")
            end
        end)
        ctrl:SetHidden(false)
    end
end

function UI:HighlightDeckSlot(slotIdx)
    for i, slot in ipairs(self.deckSlots) do
        local bg = WINDOW_MANAGER:GetControlByName(slot:GetName().."_BG")
        if bg then
            bg:SetEdgeColor(i == slotIdx and 1 or 0.45, i == slotIdx and 0.84 or 0.38, i == slotIdx and 0 or 0.18, 1)
        end
    end
end

function UI:ToggleDeckBuilder()
    if not self.deckWindow then return end
    if self.deckWindow:IsHidden() then
        self:PopulateDeckBuilder()
        self.deckWindow:SetHidden(false)
        SCENE_MANAGER:SetInUIMode(true)
    else
        self.deckWindow:SetHidden(true)
        SCENE_MANAGER:SetInUIMode(false)
    end
end


-- ═══════════════════════════════════════════════
-- RULES / HOW TO PLAY WINDOW
-- ═══════════════════════════════════════════════
function UI:CreateRulesWindow()
    self.rulesWindow = MakeWindow("TTRULES", 620, 660, "How to Play")

    -- ZO_ScrollContainer (native clipping + scrollbar)
    local scrollContainer, scrollChild = MakeScrollArea("TTRULES_Scroll", self.rulesWindow, 590, 600,
        TOP, self.rulesWindow, TOP, 0, 50)
    self.rulesContent = scrollChild

    -- Build all the text content
    self:PopulateRules()
end

function UI:PopulateRules()
    -- Build a single formatted string for all rules text
    local text = table.concat({
        "|cFFD700THE BASICS|r\n",
        "Triple Triad is a card game played on a 3x3 grid. You and your opponent each have a hand of 5 cards. ",
        "Players take turns placing one card onto an empty cell. The player who controls the most cards when the board is full wins!\n\n",
        "To start a game, target a friendly NPC and use |cFFFFFF/tt play|r or press your keybind.\n\n",

        "|cFFD700CARDS|r\n",
        "Each card has four numbers on its edges: |cAADDFFTop|r, |cAADDFFRight|r, |cAADDFFBottom|r, and |cAADDFFLeft|r. ",
        "These values range from 1 to 10 (shown as A). Cards also have a star rating (1-5 stars) indicating overall power.\n\n",
        "Some cards have an |c66AAFFelemental affinity|r (Fire, Ice, Lightning, Earth, Water, Air) which matters when the Elemental rule is active.\n\n",

        "|cFFD700CAPTURING CARDS|r\n",
        "When you place a card, its edge values are compared to the adjacent edges of neighboring cards. ",
        "If your card's edge value is |cFFFF00higher|r than the opponent's touching edge, you capture their card — it flips to your color!\n\n",
        "Example: You place a card with Right=7 next to an opponent's card with Left=4. Since 7 > 4, you capture their card.\n\n",

        "|cFFD700WINNING THE GAME|r\n",
        "The game ends when all 9 cells are filled. Your score counts every card you control — both on the board and any remaining in your hand.\n\n",
        "|c00FF00Win|r: You control more cards.  |cFF4444Lose|r: Opponent controls more.  |cFFFF00Draw|r: Equal cards.\n\n",
        "When you win, you receive a random card from the NPC's hand as a reward!\n\n",

        "|cFFD700BUILDING YOUR DECK|r\n",
        "You start with 5 basic cards. Win matches to earn new ones! Use |cFFFFFF/tt deck|r to open the Deck Builder. ",
        "Use |cFFFFFF/tt|r to view your full card collection.\n\n",

        "|cFFD700NPC RANKS & DIFFICULTY|r\n",
        "|cFFD700Rank 1|r — Starter zones. Easy opponents. Standard rules only.\n",
        "|cFFD700Rank 2|r — Mid-level zones. Slightly stronger cards.\n",
        "|cFFD700Rank 3|r — Advanced zones. |cFFFF00Same|r rule is added.\n",
        "|cFFD700Rank 4|r — Difficult zones. |cFF8800Plus|r rule is added.\n",
        "|cFFD700Rank 5|r — Endgame zones. |cFF00FFElemental|r rule is added.\n",
        "Higher-rank NPCs have better card rewards!\n\n",

        "|cFFFF00RULE: Same|r  |cAAAAAA(unlocked at Rank 3)|r\n",
        "If |cFFFF00two or more|r of your card's edges match the |cFFFF00exact same value|r as touching opponent edges, ",
        "those matching cards are captured! This works even when values aren't higher — only equal.\n\n",

        "|cFF8800RULE: Plus|r  |cAAAAAA(unlocked at Rank 4)|r\n",
        "The game adds each pair of touching edges. If |cFF8800two or more|r sums are |cFF8800equal|r, ",
        "those opponent cards are captured! Lets you capture strong cards by cleverly matching sums.\n\n",

        "|cFF00FFRULE: Elemental|r  |cAAAAAA(unlocked at Rank 5)|r\n",
        "Board cells get random elements. If a card's element |c00FF00matches|r the cell, edges get |c00FF00+1|r. ",
        "If it |cFF4444doesn't match|r, edges get |cFF4444-1|r. Cards with no element are unaffected.\n\n",

        "|cFFD700COOLDOWNS & REPLAYS|r\n",
        "You can replay the same NPC up to 3 times, then there's a 5-minute cooldown. ",
        "Different NPCs have separate cooldowns.\n\n",

        "|cFFD700COMMANDS|r\n",
        "|cFFFFFF/tt|r — Card collection    |cFFFFFF/tt play|r — Challenge NPC\n",
        "|cFFFFFF/tt deck|r — Deck builder    |cFFFFFF/tt stats|r — Statistics\n",
        "|cFFFFFF/tt rules|r — This window    |cFFFFFF/tt quiet|r — Toggle chat\n",
        "|cFFFFFF/tt help|r — All commands",
    })

    -- Single label for all text
    if not self.rulesTextLabel then
        self.rulesTextLabel = WINDOW_MANAGER:CreateControl("TTRULES_Text", self.rulesContent, CT_LABEL)
        self.rulesTextLabel:SetFont("ZoFontGame")
        self.rulesTextLabel:SetColor(0.85, 0.85, 0.85, 1)
        self.rulesTextLabel:SetDimensions(555, 0)
    end
    self.rulesTextLabel:ClearAnchors()
    self.rulesTextLabel:SetAnchor(TOPLEFT, self.rulesContent, TOPLEFT, 12, 0)
    self.rulesTextLabel:SetText(text)
end

function UI:ToggleRules()
    if not self.rulesWindow then return end
    if self.rulesWindow:IsHidden() then
        self.rulesWindow:SetHidden(false)
        SCENE_MANAGER:SetInUIMode(true)
    else
        self.rulesWindow:SetHidden(true)
        SCENE_MANAGER:SetInUIMode(false)
    end
end

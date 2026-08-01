-- Addon Struct, holds everything of importance
Tetris = {
    name = "Tetris",
    author = "Sem",
    manipulations = {},
    array = {},
    blocks = {},
    Block = {},
    PV = TetrisPV,
    brdr = 8,
    width = 10,
    height = 20
}
-- Struct for Block Manipulations
Tetris.manipulations = {
    nothing = 0,
    left = 1,
    right = 2,
    rotate = 3,
    rotatecounter = 4,
    slam = 5,
    down = 6
}
--Struct for Block types
Tetris.blocks = {
    none = 0,
    j = 1,
    l = 2,
    t = 3,
    i = 4,
    z = 5,
    s = 6,
    o = 7
}
-- SavedVar
local Tetrisparams = {}
local Tetrisdefaults = {
    pixelsize    = 16,
    timeout      = 500,
    posx         = 0,
    posy         = 0,
    blink        = true,
    lookingPause = false,
    bscore       = 0,
    lscore       = 0,
    showStats    = true,
    array        = nil,
    Block        = nil,
    preview      = true
}

-- Imports
--local logger = LibDebugLogger(Tetris.name)

-- Maximum manipulations per tick
local maxManipulations = { left = 5, right = 5, rotate = 4 }

-- Temporary variables
local gameover = false
local greyline = Tetris.height-1

local blink = 1
local tmpFishingState = 0
local tmpInteractableName = ""


-- update score for menu
local function _updateScore(ls, bs)
    Tetrisparams.lscore = ls
    Tetrisparams.bscore = bs

    if TetrisStatistic then
        TetrisStatistic.data.text = "Lines: " .. Tetrisparams.lscore .. ", Blocks: " .. Tetrisparams.bscore
        TetrisStatistic:UpdateValue()
    end
end


-- Set Block in Tetris array
local function _setBlockToArray(typus)
    Tetris.array[Tetris.Block.a.x][Tetris.Block.a.y] = typus
    Tetris.array[Tetris.Block.b.x][Tetris.Block.b.y] = typus
    Tetris.array[Tetris.Block.c.x][Tetris.Block.c.y] = typus
    Tetris.array[Tetris.Block.d.x][Tetris.Block.d.y] = typus
end


-- Executes Manipulation on pixel array if possible
local function _execManipulation(manipulation)
    tempBlock = ZO_DeepTableCopy(Tetris.Block, tempBlock)

    -- unset old position
    _setBlockToArray(Tetris.blocks.none)

    if manipulation == Tetris.manipulations.left then
        Tetris.Block = TetrisMoves.left(Tetris.Block)
    elseif manipulation == Tetris.manipulations.right then
        Tetris.Block = TetrisMoves.right(Tetris.Block)
    elseif manipulation == Tetris.manipulations.rotate then
        Tetris.Block = TetrisMoves.rotate(Tetris.Block)
    elseif manipulation == Tetris.manipulations.rotatecounter then
        Tetris.Block = TetrisMoves.rotatecounter(Tetris.Block)
    elseif manipulation == Tetris.manipulations.down then
        Tetris.Block = TetrisMoves.down(Tetris.Block)
    end

    --check if it is outside of the grid
    --bottom
    if Tetris.Block.a.y >= Tetris.height or Tetris.Block.b.y >= Tetris.height or
       Tetris.Block.c.y >= Tetris.height or Tetris.Block.d.y >= Tetris.height then
        Tetris.Block = ZO_DeepTableCopy(tempBlock, Tetris.Block)
        Tetrisparams.Block = ZO_DeepTableCopy(Tetris.Block, Tetrisparams.Block)

        _setBlockToArray(Tetris.Block.typus)
        return false
    end
    --left border
    if Tetris.Block.a.x < 0 or Tetris.Block.b.x < 0 or
       Tetris.Block.c.x < 0 or Tetris.Block.d.x < 0 then
        Tetris.Block = ZO_DeepTableCopy(tempBlock, Tetris.Block)
        Tetrisparams.Block = ZO_DeepTableCopy(Tetris.Block, Tetrisparams.Block)

        _setBlockToArray(Tetris.Block.typus)
        return false
    end
    --right border
    if Tetris.Block.a.x >= Tetris.width or Tetris.Block.b.x >= Tetris.width or
       Tetris.Block.c.x >= Tetris.width or Tetris.Block.d.x >= Tetris.width then
        Tetris.Block = ZO_DeepTableCopy(tempBlock, Tetris.Block)
        Tetrisparams.Block = ZO_DeepTableCopy(Tetris.Block, Tetrisparams.Block)

        _setBlockToArray(Tetris.Block.typus)
        return false
    end

     --check if pixels are free
    if Tetris.array[Tetris.Block.a.x][Tetris.Block.a.y] and Tetris.array[Tetris.Block.a.x][Tetris.Block.a.y] > Tetris.blocks.none
    or Tetris.array[Tetris.Block.b.x][Tetris.Block.b.y] and Tetris.array[Tetris.Block.b.x][Tetris.Block.b.y] > Tetris.blocks.none
    or Tetris.array[Tetris.Block.c.x][Tetris.Block.c.y] and Tetris.array[Tetris.Block.c.x][Tetris.Block.c.y] > Tetris.blocks.none
    or Tetris.array[Tetris.Block.d.x][Tetris.Block.d.y] and Tetris.array[Tetris.Block.d.x][Tetris.Block.d.y] > Tetris.blocks.none then
        Tetris.Block = ZO_DeepTableCopy(tempBlock, Tetris.Block)
        Tetrisparams.Block = ZO_DeepTableCopy(Tetris.Block, Tetrisparams.Block)

        _setBlockToArray(Tetris.Block.typus)
        return false
    end

    -- set new position
    Tetrisparams.Block = ZO_DeepTableCopy(Tetris.Block, Tetrisparams.Block)
    _setBlockToArray(Tetris.Block.typus)
    return true
end


-- Draw the target UI based on source array
local function _drawPixel(source, target, w, h, bg)
    for i=0,w-1 do
        for j=0,h-1 do
            if source[i][j] == Tetris.blocks.j then
                target[i][j]:SetColor(0.06, 0.12, 0.90, 1) --blue
            elseif source[i][j] == Tetris.blocks.l then
                target[i][j]:SetColor(0.87, 0.60, 0.15, 1) --orange
            elseif source[i][j] == Tetris.blocks.t then
                target[i][j]:SetColor(0.53, 0.17, 0.90, 1) --purple
            elseif source[i][j] == Tetris.blocks.i then
                target[i][j]:SetColor(0.41, 0.91, 0.93, 1) --turquoise
            elseif source[i][j] == Tetris.blocks.z then
                target[i][j]:SetColor(0.83, 0.18, 0.07, 1) --red
            elseif source[i][j] == Tetris.blocks.s then
                target[i][j]:SetColor(0.41, 0.90, 0.21, 1) --green
            elseif source[i][j] == Tetris.blocks.o then
                target[i][j]:SetColor(0.93, 0.92, 0.22, 1) --yellow
            elseif source[i][j] == Tetris.blocks.none then
                target[i][j]:SetColor(1, 1, 1, 1) --white
            end
            bg:SetColor(0,0,0,1)
        end
    end
    Tetrisparams.array = ZO_DeepTableCopy(Tetris.array, Tetrisparams.array)
end


-- Convenient function to redraw the User Interface of Tetris
local function _drawUI()
    _drawPixel(Tetris.array, Tetris.UI.pixel, Tetris.width, Tetris.height, Tetris.UI.background)
end


-- Convenient function to redraw the Preview Interface
local function _drawPV()
    _drawPixel(Tetris.PV.array, Tetris.PV.UI.pixel, Tetris.PV.width, Tetris.PV.height, Tetris.PV.UI.background)
end


-- Checks if any more downwards moves are possible for active Block
-- returns TRUE if down move is possible for Block
-- else FALSE
local function _isFreeBelow()
    -- hit the bottom
    if Tetris.Block.a.y+1 >= Tetris.height or Tetris.Block.b.y+1 >= Tetris.height
    or Tetris.Block.c.y+1 >= Tetris.height or Tetris.Block.d.y+1 >= Tetris.height then
        return false
    end

    if Tetris.array[Tetris.Block.a.x][Tetris.Block.a.y+1] -- the block below A is in the playing field
        and Tetris.array[Tetris.Block.a.x][Tetris.Block.a.y+1] ~= Tetris.blocks.none -- the block below has no color
        and not (Tetris.Block.a.y+1 == Tetris.Block.b.y and Tetris.Block.a.x == Tetris.Block.b.x) -- it is not b
        and not (Tetris.Block.a.y+1 == Tetris.Block.c.y and Tetris.Block.a.x == Tetris.Block.c.x) -- nor c
        and not (Tetris.Block.a.y+1 == Tetris.Block.d.y and Tetris.Block.a.x == Tetris.Block.d.x) -- nor d
    then
        return false
    end

    --analog for B,C and D
    if Tetris.array[Tetris.Block.b.x][Tetris.Block.b.y+1]
        and Tetris.array[Tetris.Block.b.x][Tetris.Block.b.y+1] ~= Tetris.blocks.none
        and not (Tetris.Block.b.y+1 == Tetris.Block.a.y and Tetris.Block.b.x == Tetris.Block.a.x)
        and not (Tetris.Block.b.y+1 == Tetris.Block.c.y and Tetris.Block.b.x == Tetris.Block.c.x)
        and not (Tetris.Block.b.y+1 == Tetris.Block.d.y and Tetris.Block.b.x == Tetris.Block.d.x)
    then
        return false
    end

    if Tetris.array[Tetris.Block.c.x][Tetris.Block.c.y+1]
        and Tetris.array[Tetris.Block.c.x][Tetris.Block.c.y+1] ~= Tetris.blocks.none
        and not (Tetris.Block.c.y+1 == Tetris.Block.a.y and Tetris.Block.c.x == Tetris.Block.a.x)
        and not (Tetris.Block.c.y+1 == Tetris.Block.b.y and Tetris.Block.c.x == Tetris.Block.b.x)
        and not (Tetris.Block.c.y+1 == Tetris.Block.d.y and Tetris.Block.c.x == Tetris.Block.d.x)
    then
        return false
    end

    if Tetris.array[Tetris.Block.d.x][Tetris.Block.d.y+1]
        and Tetris.array[Tetris.Block.d.x][Tetris.Block.d.y+1] ~= Tetris.blocks.none
        and not (Tetris.Block.d.y+1 == Tetris.Block.a.y and Tetris.Block.d.x == Tetris.Block.a.x)
        and not (Tetris.Block.d.y+1 == Tetris.Block.b.y and Tetris.Block.d.x == Tetris.Block.b.x)
        and not (Tetris.Block.d.y+1 == Tetris.Block.c.y and Tetris.Block.d.x == Tetris.Block.c.x)
    then
        return false
    end

    return true
end


-- Collects the typus of the next Block and generates the following
local function _getNextBlock()
    --math.random does not feel random in a pleasant way
    typus = Tetris.PV:getNextTypus()
    if typus == nil then
        typus = math.random(Tetris.blocks.j, Tetris.blocks.o)
    else
        _drawPV()
    end

    return typus
end


local function _showMessagePopup(messageText, dimx, dimy, pause)
    if pause then
        Tetris.running = false
    end
    Tetris.UI.label:SetText(messageText)
    Tetris.UI.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    Tetris.UI.labelBg:SetDimensions(dimx, dimy)
    Tetris.UI.labelBg:SetHidden(false)
    Tetris.PV:hide()
end


local function _hideMessagePopup(pause)
    Tetris.UI.labelBg:SetHidden(true)
    Tetris.UI.label:SetText("")
    Tetris.UI.labelBg:SetDimensions(200, 100)
    Tetris.PV:show()
    if pause then
        Tetris.running = true
    end
end


-- Creates a new Block if possible, else it triggers "game over" state
local function _createBlock()
    -- get the Block start layout from  Moves.lua
    typus = _getNextBlock()
    Tetris.Block = TetrisMoves.start(typus)
    Tetrisparams.Block = ZO_DeepTableCopy(Tetris.Block, Tetrisparams.Block)

    -- check for "game over"
    if not _isFreeBelow() then
        EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "tick")
        EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "lockDown")
        gameover = true

        Tetris.PV:hide()

        if Tetrisparams.showStats == true then
            _showMessagePopup("GAME OVER\nLines removed: " .. Tetrisparams.lscore .. "\nBlocks spawned: " .. Tetrisparams.bscore, 200, 100, false)
        else
            _showMessagePopup("GAME OVER", 200, 100, false)
        end
        EVENT_MANAGER:RegisterForUpdate(Tetris.name .. "gameover", 150, Tetris.gameOver)
    else
        _setBlockToArray(typus)
    end

    _updateScore(Tetrisparams.lscore, Tetrisparams.bscore + 1)

    _drawUI()
end


function cleanUpRandom()
    math.randomseed(GetGameTimeMilliseconds())
    math.random(0, math.random(3,7))
end


-- "Game over" state control and animation
function Tetris.gameOver()
    EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "gameover")
    EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "tick")

    -- exit condition, for when all lines are removed
    if greyline == -1 then
        gameover = false
        greyline = Tetris.height-1
        _updateScore(0, 0)

        cleanUpRandom()
        Tetris.PV:clearBag()

        if Tetris.running == true and not SCENE_MANAGER:IsShowing("gameMenuInGame") then
            _hideMessagePopup(false)
            Tetris.PV:show()
            _createBlock()
            EVENT_MANAGER:RegisterForUpdate(Tetris.name .. "tick", Tetrisparams.timeout, Tetris.tick)
        end
        return
    end

    -- remove next line and timeout
    for i=0,Tetris.width-1 do
        Tetris.array[i][greyline] = Tetris.blocks.none
    end
    _drawUI()

    greyline = greyline - 1

    EVENT_MANAGER:RegisterForUpdate(Tetris.name .. "gameover", 150, Tetris.gameOver)
end


-- Remove lines that are completed
local function _removeLines()
    rm = 0

    --bottom up
    for j=Tetris.height-1,0,-1 do
        line = 0
        for i=0,Tetris.width-1 do
            --add up line
            if Tetris.array[i][j] ~= Tetris.blocks.none then
                line = line + 1
            end

            -- move line down rm steps
            for r=0,rm-1 do
                --line under j becomes line j+1
                Tetris.array[i][j+1+r] = Tetris.array[i][j+r]
                --line j is deleted
                Tetris.array[i][j+r] = Tetris.blocks.none
            end
        end

        if line == Tetris.width then
            for i=0,Tetris.width-1 do
                Tetris.array[i][j] = Tetris.blocks.none
            end
            rm = rm + 1
        end
    end

    _updateScore(Tetrisparams.lscore + rm, Tetrisparams.bscore )
    _drawUI()
end


-- lockDown timeout to allow one more manipulation after slam
willLockSoon = false
local function _lockDown()
    EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "lockDown")
    willLockSoon = false

    if not _isFreeBelow() then
        _removeLines()
        _createBlock()
    end

    Tetris.tick()
end


local function _locking()
    if not willLockSoon then
        -- lockDown timeout to allow one more manipulation after slam
        EVENT_MANAGER:RegisterForUpdate(Tetris.name .. "lockDown", 500, _lockDown)
        willLockSoon = true
    else
        _lockDown()
    end
end


-- Manipulate active Block (left,right,rotate,slam)
local function _manipulate(manipulation)
    if Tetris.running == false then
        return false
    end

    result = true
    if manipulation == Tetris.manipulations.slam then
        EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "tick")
        while _isFreeBelow() and result do
            result = _execManipulation(Tetris.manipulations.down)
        end

        _locking()

    elseif manipulation == Tetris.manipulations.down then
        result = _execManipulation(manipulation)

    elseif manipulation == Tetris.manipulations.left and maxManipulations.left > 0 then
        maxManipulations.left = maxManipulations.left - 1
        result = _execManipulation(manipulation)

    elseif manipulation == Tetris.manipulations.right and maxManipulations.right > 0 then
        maxManipulations.right = maxManipulations.right - 1
        result = _execManipulation(manipulation)

    elseif manipulation == Tetris.manipulations.rotate and maxManipulations.rotate > 0 then
        maxManipulations.rotate = maxManipulations.rotate - 1
        result = _execManipulation(manipulation)

    elseif manipulation == Tetris.manipulations.rotatecounter and maxManipulations.rotate > 0 then
        maxManipulations.rotate = maxManipulations.rotate - 1
        result = _execManipulation(manipulation)
    end

    if willLockSoon and _isFreeBelow() then
        _locking()
    end

    _drawUI()

    return result
end


-- execute move on key or after timeout
function Tetris.tick()
    --unset timer
    EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "tick")

    -- ticks only in hud scene
    if not SCENE_MANAGER:IsShowing("hud") or gameover then
        return
    end

    if not _manipulate(Tetris.manipulations.down) then
        _locking()
        return
    end

    --reset maxManipulations
    maxManipulations = { left = 5, right = 5, rotate = 4 }

    --set timer
    if Tetris.running then
        EVENT_MANAGER:RegisterForUpdate(Tetris.name .. "tick", Tetrisparams.timeout, Tetris.tick)
    end
end


--Keybinding Actions
function Tetris.keyLeft()
    if gameover == false and Tetris.running == true then
        _manipulate(Tetris.manipulations.left)
    end
end
function Tetris.keyRight()
    if gameover == false and Tetris.running == true then
        _manipulate(Tetris.manipulations.right)
    end
end
function Tetris.keyRotate()
    if gameover == false and Tetris.running == true then
        _manipulate(Tetris.manipulations.rotate)
    end
end
function Tetris.keyRotateCounter()
    if gameover == false and Tetris.running == true then
        _manipulate(Tetris.manipulations.rotatecounter)
    end
end
function Tetris.keySlam()
    if gameover == false and Tetris.running == true then
        _manipulate(Tetris.manipulations.slam)
    end
end


local function _backgroundBlink()
    EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "reelinBlink")
    Tetris.UI.background:SetColor(blink, blink, blink, 1)
    blink = (blink + 1) % 2
    EVENT_MANAGER:RegisterForUpdate(Tetris.name .. "reelinBlink", 200, _backgroundBlink)
end


-- Toggle Tetris running state and visibility
function Tetris.toggle(fishingState)

    -- pause tetris, if some keybinds are not set
    if  ZO_Keybindings_GetHighestPriorityBindingStringFromAction("TETRISLEFT", KEYBIND_TEXT_OPTIONS_FULL_NAME) == nil or
        ZO_Keybindings_GetHighestPriorityBindingStringFromAction("TETRISRIGHT", KEYBIND_TEXT_OPTIONS_FULL_NAME) == nil or
        ZO_Keybindings_GetHighestPriorityBindingStringFromAction("TETRISROTATE", KEYBIND_TEXT_OPTIONS_FULL_NAME) == nil or
        ZO_Keybindings_GetHighestPriorityBindingStringFromAction("TETRISROTATECOUNTER", KEYBIND_TEXT_OPTIONS_FULL_NAME) == nil or
        ZO_Keybindings_GetHighestPriorityBindingStringFromAction("TETRISSLAM", KEYBIND_TEXT_OPTIONS_FULL_NAME) == nil then
            EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "tick")
            _showMessagePopup("You have\nunassigned Keybinds\n\nGo to controls\nand enter Tetris keys", 200, 200, true)
            Tetris.PV:hide()
            HUD_SCENE:AddFragment(Tetris.fragment)
            LOOT_SCENE:AddFragment(Tetris.fragment)
            return
    else
            _hideMessagePopup(false)
    end

    if fishingState == FishingStateMachine.state.reelin and Tetrisparams.blink == true then
        _backgroundBlink()
    else
        EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "reelinBlink")
        Tetris.UI.background:SetColor(0, 0, 0, 1)
    end

    -- FishingStateMachine states that start Tetris
    if SCENE_MANAGER:IsShowing("hud")
        and (((fishingState == FishingStateMachine.state.looking or fishingState == FishingStateMachine.state.reelin) and not Tetrisparams.lookingPause)
        or fishingState == FishingStateMachine.state.fishing)
    then
        if Tetris.running == false then
            HUD_SCENE:AddFragment(Tetris.fragment)
            LOOT_SCENE:AddFragment(Tetris.fragment)
            Tetris.PV:show()
            _hideMessagePopup(true)
            cleanUpRandom()
            EVENT_MANAGER:RegisterForUpdate(Tetris.name .. "tick", Tetrisparams.timeout, Tetris.tick)
        end

    -- FishingStateMachine states that pause Tetris
    elseif fishingState == FishingStateMachine.state.loot or
           ((fishingState == FishingStateMachine.state.reelin or fishingState == FishingStateMachine.state.looking) and Tetrisparams.lookingPause) then
        EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "tick")

        if Tetrisparams.showStats == true then
            _showMessagePopup("Pause\nLines removed: " .. Tetrisparams.lscore .. "\nBlocks spawned: " .. Tetrisparams.bscore, 200, 100, true)
        else
            _showMessagePopup("Pause", 200, 100, true)
        end
        HUD_SCENE:AddFragment(Tetris.fragment)
        Tetris.PV:hide()

    --All other FishingStateMachine states stop and hide Tetris
    else
        EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "tick")
        Tetris.running = false
        Tetris.PV:hide()
        HUD_SCENE:RemoveFragment(Tetris.fragment)
        LOOT_SCENE:RemoveFragment(Tetris.fragment)
    end
end

local function _toggleWrapper(oldState, newState)
    if newState == SCENE_HIDDEN then
        Tetris.toggle(FishingStateMachine.state.idle)
    elseif newState == SCENE_SHOWN then
        Tetris.toggle(FishingStateMachine:getState())
    end
end


-- Create UI elements and Fragment
local function _createUI()
    dimX = Tetris.brdr + Tetris.width*Tetrisparams.pixelsize + Tetris.brdr
    dimY = Tetris.brdr + Tetris.height*Tetrisparams.pixelsize + Tetris.brdr

    -- UI Toplevel
    Tetris.UI = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_TOPLEVELCONTROL)
    Tetris.UI:SetMouseEnabled(true)
    Tetris.UI:SetClampedToScreen(true)
    Tetris.UI:SetMovable(true)
    Tetris.UI:SetDimensions(dimX, dimY)
    Tetris.UI:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, Tetrisparams.posx, Tetrisparams.posy)
    Tetris.UI:SetDrawLevel(0)
    Tetris.UI:SetDrawLayer(DL_MAX_VALUE-1)
    Tetris.UI:SetDrawTier(DT_MAX_VALUE-1)

    -- Black Background
    Tetris.UI.background = WINDOW_MANAGER:CreateControl(nil, Tetris.UI, CT_TEXTURE)
    Tetris.UI.background:SetDimensions(dimX, dimY)
    Tetris.UI.background:SetColor(0, 0, 0, 1)
    Tetris.UI.background:SetAnchor(TOPLEFT, Tetris.UI, TOPLEFT, 0, 0)
    Tetris.UI.background:SetHidden(false)
    Tetris.UI.background:SetDrawLevel(0)

    -- Setup Pixel matrix
    Tetris.UI.pixel = {}
    for i=0,Tetris.width-1 do
        Tetris.UI.pixel[i] = {}
        Tetris.array[i] = {}
        for j=0,Tetris.height-1 do
            if Tetrisparams.array then Tetris.array[i][j] = Tetrisparams.array[i][j] else Tetris.array[i][j] = 0 end
            Tetris.UI.pixel[i][j] = WINDOW_MANAGER:CreateControl(nil, Tetris.UI, CT_TEXTURE)
            Tetris.UI.pixel[i][j]:SetDimensions(Tetrisparams.pixelsize-2, Tetrisparams.pixelsize-2)
            Tetris.UI.pixel[i][j]:SetColor(1, 1, 1, 1)
            Tetris.UI.pixel[i][j]:SetAnchor(TOPLEFT, Tetris.UI.background, TOPLEFT, Tetris.brdr+1+(i*Tetrisparams.pixelsize), Tetris.brdr+1+(j*Tetrisparams.pixelsize))
            Tetris.UI.pixel[i][j]:SetHidden(false)
            Tetris.UI.pixel[i][j]:SetDrawLevel(1)
        end
    end

    -- Create Message Popup and Background
    Tetris.UI.labelBg = WINDOW_MANAGER:CreateControl(nil, Tetris.UI, CT_TEXTURE)
    Tetris.UI.labelBg:SetDimensions(200, 100)
    Tetris.UI.labelBg:SetColor(0.8, 0.8, 0.8, 0.8)
    Tetris.UI.labelBg:SetAnchor(CENTER, Tetris.UI, CENTER, 0, 0)
    Tetris.UI.labelBg:SetDrawLevel(2)
    Tetris.UI.labelBg:SetHidden(true)

    Tetris.UI.label = WINDOW_MANAGER:CreateControl(Tetris.name .. "label", Tetris.UI.labelBg, CT_LABEL)
    Tetris.UI.label:SetFont("ZoFontChat")
    Tetris.UI.label:SetColor(0,0,0)
    Tetris.UI.label:SetAnchor(CENTER, Tetris.UI.labelBg, CENTER, 0, 0)
    Tetris.UI.label:SetText("TESTLABEL")
    Tetris.UI.label:SetDrawLevel(3)
    Tetris.UI.label:SetHidden(false)

    -- Create UI for Preview
    Tetris.PV:createUI(Tetrisparams)
    Tetris.PV:getNextTypus()
    _drawPV()

    -- Setup fragment for Scene management
    Tetris.fragment = ZO_FadeSceneFragment:New(Tetris.UI, 100, 200)
    Tetris.UI:SetHidden(true)

    Tetris.UI:SetHandler("OnMoveStop", function()
        Tetrisparams.posy = Tetris.UI:GetTop()
        Tetrisparams.posx = Tetris.UI:GetRight() - GuiRoot:GetRight()
        Tetris.PV:resize(Tetrisparams.pixelsize)
    end)
end

local function _resize(newPxSize)
    Tetrisparams.pixelsize = newPxSize

    dimX = Tetris.brdr + Tetris.width*Tetrisparams.pixelsize + Tetris.brdr
    dimY = Tetris.brdr + Tetris.height*Tetrisparams.pixelsize + Tetris.brdr
    Tetris.UI:SetDimensions(dimX, dimY)
    Tetris.UI.background:SetDimensions(dimX, dimY)

    for i=0,Tetris.width-1 do
        for j=0,Tetris.height-1 do
            Tetris.UI.pixel[i][j]:SetDimensions(Tetrisparams.pixelsize-2, Tetrisparams.pixelsize-2)
            Tetris.UI.pixel[i][j]:SetAnchor(TOPLEFT, Tetris.UI.background, TOPLEFT, Tetris.brdr+1+(i*Tetrisparams.pixelsize), Tetris.brdr+1+(j*Tetrisparams.pixelsize))
        end
    end

    Tetris.PV:resize(newPxSize)
end


local function _createMenu()
    --#region addon menu
    --addon menu
    local LAM = LibAddonMenu2

    local pressedShow = false

    local panelName = Tetris.name .. "Settings"

    local panelData = {
        type = "panel",
        name = Tetris.name,
        author = Tetris.author,
    }
    local panel = LAM:RegisterAddonPanel(panelName, panelData)

    local optionsData = {
        {
            type = "slider",
            name = "Pixel Size",
            min = 1,
            max = 100,
            default = Tetrisparams.pixelsize,
            getFunc = function() return Tetrisparams.pixelsize end,
            setFunc = function(value)
                _resize(value)
            end,
            tooltip = "Set the size of each pixel of the Tetris field.",
            requiresReload = false
        },
        {
            type = "slider",
            name = "Gamespeed",
            min = 1,
            max = 20,
            step = 1,
            default = 20 - math.floor(Tetrisparams.timeout / 100),
            getFunc = function() return (20 - math.floor(Tetrisparams.timeout / 100)) end,
            setFunc = function(value) Tetrisparams.timeout = ((20 - value) * 100) end,
            tooltip = "Blocks will drop faster with higher Gamespeeds.",
            requiresReload = false
        },
        {
            type = "checkbox",
            name = "Show stats in Pause and Game Over screen.",
            default = Tetrisparams.showStats,
            getFunc = function() return Tetrisparams.showStats end,
            setFunc = function(value) Tetrisparams.showStats = value end,
            requiresReload = false
        },
        {
            type = "checkbox",
            name = "Show a Preview for the next Block.",
            default = true,
            getFunc = function() return Tetris.PV.enabled end,
            setFunc = function(value)
                        Tetris.PV.enabled = value
                        Tetrisparams.preview = value
                      end,
        },
        {
            type = "divider",
        },
        {
            type = "checkbox",
            name = "Blink when the fish is on the hook.",
            default = function() return Tetrisparams.blink end,
            getFunc = function() return Tetrisparams.blink end,
            setFunc = function(value) Tetrisparams.blink = value end,
            tooltip = "Lead's your attention back to fishing when needed.",
            requiresReload = false
        },
        {
            type = "checkbox",
            name = "Pause while looking at a fishing hole.",
            default = function() return Tetrisparams.lookingPause end,
            getFunc = function() return Tetrisparams.lookingPause end,
            setFunc = function(value) Tetrisparams.lookingPause = value end,
            tooltip = "Start fishing to start the game.",
            requiresReload = false
        },
        {
            type = "divider",
        },
        {
            type = "description",
            text = "Show or hide Tetris field so you can choose a position:",
            width = "full"
        },
        {
            type = "button",
            name = "Tetris visibility",
            func = function()
                if pressedShow == false then
                    pressedShow = true
                    HUD_UI_SCENE:AddFragment(Tetris.fragment)
                    Tetris.UI:SetHidden(false)
                    Tetris.PV:show()
                elseif pressedShow == true then
                    pressedShow = false
                    Tetrisparams.posy = Tetris.UI:GetTop()
                    Tetrisparams.posx = Tetris.UI:GetRight() - GuiRoot:GetRight()
                    HUD_UI_SCENE:RemoveFragment(Tetris.fragment)
                    Tetris.UI:SetHidden(true)
                    Tetris.PV:hide()
                end
            end,
            width = "half",
            requiresReload = false,
        },
        {
            type = "button",
            name = "Tetris visibility",
            func = function()
                if pressedShow == false then
                    pressedShow = true
                    HUD_UI_SCENE:AddFragment(Tetris.fragment)
                    Tetris.UI:SetHidden(false)
                    Tetris.PV:show()
                elseif pressedShow == true then
                    pressedShow = false
                    Tetrisparams.posy = Tetris.UI:GetTop()
                    Tetrisparams.posx = Tetris.UI:GetRight() - GuiRoot:GetRight()
                    HUD_UI_SCENE:RemoveFragment(Tetris.fragment)
                    Tetris.UI:SetHidden(true)
                    Tetris.PV:hide()
                end
            end,
            width = "half",
            requiresReload = false,
        },
        {
            type = "divider",
        },
        {
            type = "description",
            title = "Statistic",
            text = "Lines: " .. Tetrisparams.lscore .. ", Blocks: " .. Tetrisparams.bscore,
            width = "full",
            reference = "TetrisStatistic"
        }
    }

    LAM:RegisterOptionControls(panelName, optionsData)

end


-- Main function
function Tetris.OnAddOnLoaded(event, addonName)
    if addonName == Tetris.name then
        -- init once and never come here again
        EVENT_MANAGER:UnregisterForEvent(Tetris.name, EVENT_ADD_ON_LOADED)

        -- save/load last game
        Tetrisparams.array = nil
        Tetrisparams = ZO_SavedVars:NewAccountWide("Tetrisparamsvar", 1, nil, Tetrisdefaults)

        -- strings for keybindings
        ZO_CreateStringId("SI_BINDING_NAME_TETRISLEFT", "Move Left")
        ZO_CreateStringId("SI_BINDING_NAME_TETRISRIGHT", "Move Right")
        ZO_CreateStringId("SI_BINDING_NAME_TETRISROTATE", "Rotate Clockwise")
        ZO_CreateStringId("SI_BINDING_NAME_TETRISROTATECOUNTER", "Rotate Counterclockwise")
        ZO_CreateStringId("SI_BINDING_NAME_TETRISSLAM", "Slam")

        -- create UI
        _createUI()
        _createMenu()

        -- reinit last game from savedvar
        if Tetrisparams.array then
            Tetris.array = ZO_DeepTableCopy(Tetrisparams.array, Tetris.array)
        end
        if Tetrisparams.Block then
            Tetris.Block = ZO_DeepTableCopy(Tetrisparams.Block, Tetris.Block)
        end
        if not Tetris.Block.typus then
            _createBlock()
        end

        _drawUI()

        -- init state
        Tetris.running = false

        -- connect to FishingStateMachine
        FishingStateMachine:registerOnStateChange(Tetris.toggle)
        HUD_SCENE:RegisterCallback("StateChange", _toggleWrapper)

    end
end

-- Hook into game load system
EVENT_MANAGER:RegisterForEvent(Tetris.name, EVENT_ADD_ON_LOADED, Tetris.OnAddOnLoaded)

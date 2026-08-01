-- Preview Struct
TetrisPV = {
    name = "TetrisPV",
    array = {},
    Block = {},
    bag = {},
    width = 4,
    height = 4,
    enabled = true
}

--local logger = LibDebugLogger(TetrisPV.name)

-- Clear and set Block in Preview array
local function _setBlocktoArray()
    for i=0,TetrisPV.width-1 do
        for j=0,TetrisPV.height-1 do
            TetrisPV.array[i][j] = Tetris.blocks.none
        end
    end

    TetrisPV.array[TetrisPV.Block.a.x - 3][TetrisPV.Block.a.y + 3] = TetrisPV.Block.typus
    TetrisPV.array[TetrisPV.Block.b.x - 3][TetrisPV.Block.b.y + 3] = TetrisPV.Block.typus
    TetrisPV.array[TetrisPV.Block.c.x - 3][TetrisPV.Block.c.y + 3] = TetrisPV.Block.typus
    TetrisPV.array[TetrisPV.Block.d.x - 3][TetrisPV.Block.d.y + 3] = TetrisPV.Block.typus
end


-- shuffle the bag
local function _shuffleBag()
  local bag = {Tetris.blocks.i, Tetris.blocks.t, Tetris.blocks.l,
    Tetris.blocks.j, Tetris.blocks.s, Tetris.blocks.z, Tetris.blocks.o}
  for i = #bag, 2, -1 do
    local j = math.random(i)
    bag[i], bag[j] = bag[j], bag[i]
  end
  return bag
end


function TetrisPV:clearBag()
    TetrisPV.bag = {}
    TetrisPV.bag = _shuffleBag()
    TetrisPV.nextTypus = table.remove(TetrisPV.bag)
end


-- Define a function to pop one item from the bag
function TetrisPV:getNextTypus()
    -- Regenerate and shuffle the bag if it's empty
    if #TetrisPV.bag == 0 then
        TetrisPV.bag = _shuffleBag()
    end
    -- Pop one item from the bag and return its corresponding number
    local tetromino = table.remove(TetrisPV.bag)

    typus = TetrisPV.nextTypus
    TetrisPV.nextTypus = tetromino
    TetrisPV.Block = TetrisMoves.start(TetrisPV.nextTypus)
    _setBlocktoArray()
    return typus
end


function TetrisPV:show()
    if TetrisPV.enabled then
        TetrisPV.UI:SetHidden(false)
        HUD_SCENE:AddFragment(TetrisPV.fragment)
        LOOT_SCENE:AddFragment(TetrisPV.fragment)
    else
        TetrisPV:hide()
    end
end


function TetrisPV:hide()
    TetrisPV.UI:SetHidden(true)
    HUD_SCENE:RemoveFragment(TetrisPV.fragment)
    LOOT_SCENE:RemoveFragment(TetrisPV.fragment)
end


function TetrisPV:resize(newPxSize)
    dimXPV = Tetris.brdr + TetrisPV.width*newPxSize + Tetris.brdr
    dimYPV = Tetris.brdr + TetrisPV.height*newPxSize + Tetris.brdr
    dimX,dimY = Tetris.UI.background:GetDimensions()
    posy = Tetris.UI:GetTop()
    posx = Tetris.UI:GetRight() - GuiRoot:GetRight()

    TetrisPV.UI:SetDimensions(dimXPV, dimYPV)
    TetrisPV.UI:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, posx - ((dimX - dimXPV)/2), posy - dimYPV)
    TetrisPV.UI.background:SetDimensions(dimXPV, dimYPV)

    for i=0,TetrisPV.width-1 do
        for j=0,TetrisPV.height-1 do
            TetrisPV.UI.pixel[i][j]:SetDimensions(newPxSize-2, newPxSize-2)
            TetrisPV.UI.pixel[i][j]:SetAnchor(TOPLEFT, TetrisPV.UI.background, TOPLEFT, Tetris.brdr+1+(i*newPxSize), Tetris.brdr+1+(j*newPxSize))
        end
    end
end


-- Create UI for Preview
function TetrisPV:createUI(params)

    TetrisPV.enabled = params.preview

    dimXPV = Tetris.brdr + TetrisPV.width*params.pixelsize + Tetris.brdr
    dimYPV = Tetris.brdr + TetrisPV.height*params.pixelsize + Tetris.brdr
    dimX,dimY = Tetris.UI.background:GetDimensions()

    -- PV Toplevel
    TetrisPV.UI = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_TOPLEVELCONTROL)
    TetrisPV.UI:SetMouseEnabled(true)
    TetrisPV.UI:SetClampedToScreen(true)
    TetrisPV.UI:SetMovable(true)
    TetrisPV.UI:SetDimensions(dimXPV, dimYPV)
    TetrisPV.UI:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, params.posx - ((dimX - dimXPV)/2), params.posy - dimYPV)
    TetrisPV.UI:SetDrawLevel(0)
    TetrisPV.UI:SetDrawLayer(DL_MAX_VALUE-1)
    TetrisPV.UI:SetDrawTier(DT_MAX_VALUE-1)

    -- Black Background
    TetrisPV.UI.background = WINDOW_MANAGER:CreateControl(nil, TetrisPV.UI, CT_TEXTURE)
    TetrisPV.UI.background:SetDimensions(dimXPV, dimYPV)
    TetrisPV.UI.background:SetColor(0, 0, 0, 1)
    TetrisPV.UI.background:SetAnchor(TOPLEFT, TetrisPV.UI, TOPLEFT, 0, 0)
    TetrisPV.UI.background:SetHidden(false)
    TetrisPV.UI.background:SetDrawLevel(0)

    -- Setup Preview matrix
    TetrisPV.UI.pixel = {}
    for i=0,TetrisPV.width-1 do
        TetrisPV.UI.pixel[i] = {}
        TetrisPV.array[i] = {}
        for j=0,TetrisPV.height-1 do
            TetrisPV.UI.pixel[i][j] = WINDOW_MANAGER:CreateControl(nil, TetrisPV.UI, CT_TEXTURE)
            TetrisPV.UI.pixel[i][j]:SetDimensions(params.pixelsize-2, params.pixelsize-2)
            TetrisPV.UI.pixel[i][j]:SetColor(1, 1, 1, 1)
            TetrisPV.UI.pixel[i][j]:SetAnchor(TOPLEFT, TetrisPV.UI.background, TOPLEFT, Tetris.brdr+1+(i*params.pixelsize), Tetris.brdr+1+(j*params.pixelsize))
            TetrisPV.UI.pixel[i][j]:SetHidden(false)
            TetrisPV.UI.pixel[i][j]:SetDrawLevel(1)
        end
    end

    TetrisPV.fragment = ZO_FadeSceneFragment:New(TetrisPV.UI, 100, 200)
    TetrisPV.UI:SetHidden(true)

    TetrisPV.fragment:RegisterCallback("StateChange", function()
        TetrisPV.UI:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, params.posx - ((dimX - dimXPV)/2), params.posy - dimYPV)
    end)
end
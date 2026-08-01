-- Initialize File
PITHKA = PITHKA or {}
PITHKA.views = PITHKA.views or {}
PITHKA.views.baseDungeons = {}

-- convenient namespacing
local layout = PITHKA.layout
local constants = PITHKA.common.constants
local ui = PITHKA.ui

local baseDungeonScreen = nil

local function populateBaseDungeonScreen()
	-- create header as function because it's used in both columns
    local function createHeader() 
        return {
            ui.label.basic{text="Dungeons with I/II", width=165, tt="Click to Port"},
            ui.label.basic{text="VET", tt="Veteran"},
            ui.label.basic{text="HM",  tt="Hard Mode"},
            ui.label.basic{text="SR",  tt="Speed Run"},
            ui.label.basic{text="ND",  tt="No Death"},
        }
    end

    -- create row as function because it's used in both columns
    local function createRowUI(row)
        return {
            ui.label.teleport{text=row.NAME, width=165, tt="Click to Port", vQueue=row.vQueue, nQueue=row.nQueue, portId=row.portID},
            ui.icon.achievement(row.VET),
            ui.icon.achievement(row.HM),
            ui.icon.achievement(row.SR),
            ui.icon.achievement(row.ND),
        }
    end
      
    ------ CREATE LEFT COLUMN OF DUNGEONS ------
    -- initialize grid
    local grid = layout.grid.new(30,50) -- passing x,y offsets
    baseDungeonScreen:addObject(grid)

    -- create header and add to grid
    local header = createHeader()
    grid:addRow(header)

    -- create rows and add to grid
    local rows = PITHKA.data.filterAchievements({TYPE='baseDungeon-wI'})
    for _, row in pairs(rows) do
        rowUI = createRowUI(row)
        grid:addRow(rowUI)
    end

    ------ CREATE RIGHT COLUMN OF DUNGEONS ------
    -- initialize grid
    local grid = layout.grid.new(350,50) -- passing x,y offsets
    baseDungeonScreen:addObject(grid)

    -- create header and add to grid
    local header = createHeader()
    grid:addRow(header)

    -- create rows and add to grid
    local rows = PITHKA.data.filterAchievements({TYPE='baseDungeon-noI'})
    for _, row in pairs(rows) do
        rowUI = createRowUI(row)
        grid:addRow(rowUI)
    end
end


function PITHKA.views.baseDungeons.initialize()
    local dims = constants.screenDimensions.baseDungeons
    baseDungeonScreen = layout.screen.new(constants.textures.DUNGEON, dims[1], dims[2], 'Starter Dungeons', populateBaseDungeonScreen)
    
    return baseDungeonScreen
end
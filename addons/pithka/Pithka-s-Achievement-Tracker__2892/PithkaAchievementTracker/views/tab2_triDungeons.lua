-- Initialize File
PITHKA = PITHKA or {}
PITHKA.views = PITHKA.views or {}
PITHKA.views.trifectaDungeons = {}

-- convenient namespacing
local layout = PITHKA.layout
local constants = PITHKA.common.constants
local ui = PITHKA.ui

local triDungeonScreen = nil

local function populateTriDungeonScreen()
	-- initialize grid
    local grid = layout.grid.new(30,50) 
    triDungeonScreen:addObject(grid)
    
    -- create header and add to grid
    local header = {
        ui.label.basic{text="TRIFECTA DUNGEONS", width=165, tt="Click to Port"},
        ui.label.basic{text="VET", tt="Veteran"},
        ui.other.spacer(20),
        ui.label.basic{text="HM",  tt="Hard Mode"},
        ui.label.basic{text="SR",  tt="Speed Run"},
        ui.label.basic{text="ND",  tt="No Death"},
        ui.other.spacer(20),
        ui.label.basic{text="CHALLENGER & TRIFECTA", width=270},
        ui.label.basic{text="EXTRAS", width=200},
    }
    grid:addRow(header)
           
    -- create rows and add to grid
    local rows = PITHKA.data.filterAchievements({TYPE='triDungeon'}) -- all tri dungeons
    
    -- append BRP
    table.insert(rows, PITHKA.data.filterAchievements({ABBV='BRP'}))

    for _, row in pairs(rows) do
        local rowUI =   {
            ui.label.teleport{text=row.NAME, width=165, tt="Click to Port", vQueue=row.vQueue, nQueue=row.nQueue, portId=row.portID},
            ui.icon.achievement(row.VET),
            ui.other.spacer(20),
            ui.icon.achievement(row.HM),
            ui.icon.achievement(row.SR),
            ui.icon.achievement(row.ND),
            ui.other.spacer(20),
            ui.icon.achievement(row.CHA),
            ui.icon.achievement(row.TRI),
            ui.label.achievement{text=row.TRINAME, width=220, AID=row.TRI},
            ui.icon.achievement(row.EXT),
            ui.label.achievement{text=row.EXTNAME, width=200, AID=row.EXT},
        }
        grid:addRow(rowUI)
    end
end

function PITHKA.views.trifectaDungeons.initialize()
    local dims = constants.screenDimensions.trifectaDungeons
    triDungeonScreen = layout.screen.new(constants.textures.INSTANCE, dims[1], dims[2], '4 Man Trifectas', populateTriDungeonScreen)

    return triDungeonScreen
end
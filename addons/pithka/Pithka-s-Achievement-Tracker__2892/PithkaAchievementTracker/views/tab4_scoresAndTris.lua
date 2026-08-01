-- Initialize File
PITHKA = PITHKA or {}
PITHKA.views = PITHKA.views or {}
PITHKA.views.scoresAndTris = {}

-- convenient namespacing
local layout = PITHKA.layout
local constants = PITHKA.common.constants
local ui = PITHKA.ui
local data = PITHKA.data

local allScoreScreen = nil

local function populateAllTrifectasScreen()

    -- initialize grid
    local leftGrid = layout.grid.new(30,50) 
    allScoreScreen:addObject(leftGrid)
    
    -- TRIALS ----------------------------------------------------------------------------------------
    -- create header and add to grid
    local header = {
        ui.label.basic{text="TRIALS", width=155},
        ui.label.basic{text="BEST SCORE", width=75, align=TEXT_ALIGN_RIGHT},
        ui.other.spacer(20),
        ui.label.basic{text="TRIFECTA", width=215},
    }
    leftGrid:addRow(header)

    -- create rows and add to grid
    local rows = data.filterAchievements({TYPE='trial', SCORED=true}) -- all trials with a score
    for _, row in pairs(rows) do
        local rowUI = {
            ui.label.teleport{text=row.NAME, width=155, tt="Click to Port", vQueue=nil, nQueue=nil, portId=row.portID},
            ui.label.score(row),
            ui.other.spacer(20),            
            ui.icon.achievement(row.TRI),
            ui.label.achievement{text=row.TRINAME, width=190, font=constants.font.defaultFont, AID=row.TRI},
        }
        leftGrid:addRow(rowUI)
    end

    -- ARENAS ----------------------------------------------------------------------------------------
    -- vertical spacer
    leftGrid:addRow{ui.other.spacer(20)}

    -- create header and add to grid
    local header = {
        ui.label.basic{text="ARENAS", width=155},
        ui.label.basic{text="BEST SCORE", width=75, align=TEXT_ALIGN_RIGHT},
        ui.other.spacer(20),
        ui.label.basic{text="TRIFECTA", width=215},
    }
    leftGrid:addRow(header)

    -- -- create rows and add to grid
    local rows = data.filterAchievements({TYPE='arena'}) -- all tri dungeons
    for _, row in pairs(rows) do
        local rowUI = {
            ui.label.teleport{text=row.NAME, width=155, tt="Click to Port", vQueue=nil, nQueue=nil, portId=row.portID},
            ui.label.score(row),
            ui.other.spacer(20),            
            ui.icon.achievement(row.TRI),
            ui.label.achievement{text=row.TRINAME, width=190, font=constants.font.defaultFont, AID=row.TRI},
        }
        leftGrid:addRow(rowUI)
    end

    -- ENDLESS ARCHIVE ----------------------------------------------------------------------------------------
    --vertical spacer
    leftGrid:addRow{ui.other.spacer(20)}

    -- create header and add to grid
    local header = {
        ui.label.basic{text="INFINITE ARCHIVE", width=155},
    }
    leftGrid:addRow(header)

    -- create rows and add to grid
    local rows = PITHKA.data.filterAchievements({TYPE='endless'}) -- all tri dungeons
    for _, row in pairs(rows) do
        local rowUI = {
            ui.label.teleport{text=row.NAME, width=155, tt="Click to Port", vQueue=nil, nQueue=nil, portId=row.portID},
            ui.label.score(row),
            ui.other.spacer(20),            
            ui.icon.achievement(row.TRI),
        }
        leftGrid:addRow(rowUI)
    end
        
    -- -- DUNGEONS ----------------------------------------------------------------------------------------
    -- initialize grid
    local rightGrid = layout.grid.new(500,50) 
    allScoreScreen:addObject(rightGrid)
    
    -- create header and add to grid
    local header = {
        ui.label.basic{text="TRIFECTA DUNGEONS", width=165, tt="Click to Port"},
        ui.label.basic{text="TRIFECTAS", width=270},
    }
    rightGrid:addRow(header)
           
    -- create rows and add to rightGrid
    local rows = PITHKA.data.filterAchievements({TYPE='triDungeon'}) -- all tri dungeons

    for _, row in pairs(rows) do
        local rowUI =   {
            ui.label.teleport{text=row.NAME, width=165, tt="Click to Port", vQueue=row.vQueue, nQueue=row.nQueue, portId=row.portID},
            ui.icon.achievement(row.TRI), 
            ui.label.achievement{text=row.TRINAME, width=220, AID=row.TRI},
        }
        rightGrid:addRow(rowUI)
    end
end

function PITHKA.views.scoresAndTris.initialize()
    -- Create main screen
    local dims = constants.screenDimensions.scoresAndTris
    allScoreScreen = layout.screen.new(constants.textures.STAR, dims[1], dims[2], 'All Scores and Tris', populateAllTrifectasScreen)


    return allScoreScreen
end
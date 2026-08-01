-- Initialize File
PITHKA = PITHKA or {}
PITHKA.views = PITHKA.views or {}
PITHKA.views.trials = {}

-- convenient namespacing
local layout = PITHKA.layout
local constants = PITHKA.common.constants
local ui = PITHKA.ui
local gridXOffset = 30

local trialScreen = nil

local function populateTrialScreen()

    -- initialize grid
    local grid = layout.grid.new(gridXOffset,50) 
    trialScreen:addObject(grid)
    

    
    -- create header and add to grid
    local header = {
        ui.label.basic{text="TRIALS", width=155},
        ui.label.basic{text="BEST SCORE", width=75, align=TEXT_ALIGN_RIGHT},
        ui.other.spacer(20),
        ui.label.basic{text="VET", width=46},
        ui.label.basic{text="PARTIAL HM", width=105},
        ui.label.basic{text="PARTIAL HM", width=105},
        ui.label.basic{text="HARDMODE", width=150},
        ui.label.basic{text="TRIFECTA", width=215},
        ui.label.basic{text="EXTRA", width=250},
    }
    grid:addRow(header)

    -- create rows and add to grid
    local rows = PITHKA.data.filterAchievements({TYPE='trial'}) -- all tri dungeons
    for _, row in pairs(rows) do
        local rowUI = {
            ui.label.teleport{text=row.NAME, width=155, tt="Click to Port", vQueue=nil, nQueue=nil, portId=row.portID},
            ui.label.score(row),
            ui.other.spacer(20),
            
            ui.icon.achievement(row.VET),
            ui.other.spacer(20),
            
            ui.icon.achievement(row.PHM1),
            ui.label.achievement{text=row.PHM1NAME, width=80, AID=row.PHM1},
            
            ui.icon.achievement(row.PHM2),
            ui.label.achievement{text=row.PHM2NAME, width=80, AID=row.PHM2},
            
            ui.icon.achievement(row.HM),
            ui.label.achievement{text=row.HMNAME, width=120, AID=row.HM},
            
            ui.icon.achievement(row.TRI),
            ui.label.achievement{text=row.TRINAME, width=190, font=constants.font.defaultFont, AID=row.TRI},
            
            ui.icon.achievement(row.EXT),
            ui.label.achievement{text=row.EXTNAME, width=250, font=constants.font.defaultFont, AID=row.EXT},
        }
        grid:addRow(rowUI)
    end
end

function PITHKA.views.trials.initialize()
    local dims = constants.screenDimensions.trials
    trialScreen = layout.screen.new(constants.textures.TRIAL, dims[1], dims[2], 'Trials', populateTrialScreen)

    return trialScreen
end
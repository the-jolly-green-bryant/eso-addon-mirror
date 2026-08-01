BedlamVeilHelper = BedlamVeilHelper or { }
local BedlamVeilHelper = BedlamVeilHelper


BedlamVeilHelper.name		= "BedlamVeilHelper"
BedlamVeilHelper.version	= "1.0.0"
BedlamVeilHelper.varVersion	= "1"

BedlamVeilHelper.downTime	= 0

BedlamVeilHelper.UPDATE_INTERVAL	= 100

BedlamVeilHelper.addonLoaded = false





BedlamVeilHelper.defaults	= {


    ["offsetPuzzleX"]	= 500,
	["offsetPuzzleY"]	= 500,


}

local BLUE_LINE = {33/255, 70/255, 150/255}
local YELLOW_LINE = { 168/255, 168/255, 50/255}
local ORANGE_LINE = { 168/255, 86/255, 50/255}

BedlamVeilHelper.puzzles = {
    [1] = {
        [0]= {"4-1","1A"},--"Puzzle 1 solution A
        --   HIDDEN   COLOR
        [1]= {false, BLUE_LINE},
        [2]= {false, YELLOW_LINE},
        [3]= {true,  BLUE_LINE},

        [4]= {false, YELLOW_LINE},
        [5]= {false, BLUE_LINE},
        [6]= {false, BLUE_LINE},
        [7]= {true,  BLUE_LINE},

        [8]= {false, BLUE_LINE},
        [9]= {false, BLUE_LINE},
        [10]={true,  BLUE_LINE},

        [11]={false, YELLOW_LINE},
        [12]={false, BLUE_LINE},
        [13]={false, ORANGE_LINE},
        [14]={true,  BLUE_LINE},

        [15]={false, BLUE_LINE},
        [16]={false, ORANGE_LINE},
        [17]={true,  BLUE_LINE},
    },
    [2] = {
        [0]= {"1-2","1B"},
        --   HIDDEN   COLOR
        [1]= {false, BLUE_LINE},
        [2]= {false, ORANGE_LINE},
        [3]= {true,  BLUE_LINE},

        [4]= {false, BLUE_LINE},
        [5]= {false, YELLOW_LINE},
        [6]= {false, ORANGE_LINE},
        [7]= {true,  BLUE_LINE},

        [8]= {false, BLUE_LINE},
        [9]= {false, BLUE_LINE},
        [10]={true,  BLUE_LINE},


        [11]={false, BLUE_LINE},
        [12]={false, BLUE_LINE},
        [13]={false, BLUE_LINE},
        [14]={true,  BLUE_LINE},

        [15]={false, YELLOW_LINE},
        [16]={false, YELLOW_LINE},
        [17]={true,  BLUE_LINE},
    },




    [4] = {
        [0]= {"3-2","2A"},
        --   HIDDEN   COLOR
        [1]= {false, YELLOW_LINE},
        [2]= {false, YELLOW_LINE},
        [3]= {true,  BLUE_LINE},

        [4]= {false, YELLOW_LINE},
        [5]= {false, ORANGE_LINE},
        [6]= {false, BLUE_LINE},
        [7]= {true,  BLUE_LINE},

        [8]= {false, BLUE_LINE},
        [9]= {false, ORANGE_LINE},
        [10]={true,  BLUE_LINE},

        [11]={false, BLUE_LINE},
        [12]={false, BLUE_LINE},
        [13]={false, BLUE_LINE},
        [14]={true,  BLUE_LINE},

        [15]={false, BLUE_LINE},
        [16]={false, YELLOW_LINE},
        [17]={true,  BLUE_LINE},
    },
    [5] = {
        [0]= {"3-2","2A"},
        --   HIDDEN   COLOR
        [1]= {false, YELLOW_LINE},
        [2]= {false, YELLOW_LINE},
        [3]= {true,  BLUE_LINE},

        [4]= {false, BLUE_LINE},
        [5]= {false, BLUE_LINE},
        [6]= {false, BLUE_LINE},
        [7]= {true,  BLUE_LINE},

        [8]= {false, ORANGE_LINE},
        [9]= {false, BLUE_LINE},
        [10]={true,  BLUE_LINE},

        [11]={false, YELLOW_LINE},
        [12]={false, ORANGE_LINE},
        [13]={false, BLUE_LINE},
        [14]={true,  BLUE_LINE},

        [15]={false, BLUE_LINE},
        [16]={false, YELLOW_LINE},
        [17]={true,  BLUE_LINE},
    },



[7] = {
        [0]= {"1-2-3","3A"},
        --   HIDDEN   COLOR
        [1]= {false, BLUE_LINE},
        [2]= {false, BLUE_LINE},
        [3]= {false, YELLOW_LINE},

        [4]= {false, BLUE_LINE},
        [5]= {false, BLUE_LINE},
        [6]= {false, BLUE_LINE},
        [7]= {false,  BLUE_LINE},

        [8]= {false, YELLOW_LINE},
        [9]= {false, BLUE_LINE},
        [10]={false,  ORANGE_LINE},

        [11]={false, ORANGE_LINE},
        [12]={false, BLUE_LINE},
        [13]={false, BLUE_LINE},
        [14]={false,  BLUE_LINE},

        [15]={false, ORANGE_LINE},
        [16]={false, YELLOW_LINE},
        [17]={false,  YELLOW_LINE},
    },

[8] = {
        [0]= {"2-3-1","3B"},
        --   HIDDEN   COLOR
        [1]= {false, BLUE_LINE},
        [2]= {false, ORANGE_LINE},
        [3]= {false, YELLOW_LINE},

        [4]= {false, YELLOW_LINE},
        [5]= {false, BLUE_LINE},
        [6]= {false, BLUE_LINE},
        [7]= {false,  BLUE_LINE},

        [8]= {false, YELLOW_LINE},
        [9]= {false, BLUE_LINE},
        [10]={false,  BLUE_LINE},

        [11]={false, ORANGE_LINE},
        [12]={false, YELLOW_LINE},
        [13]={false, BLUE_LINE},
        [14]={false,  BLUE_LINE},

            [15]={false, ORANGE_LINE},
        [16]={false, BLUE_LINE},
        [17]={false,  BLUE_LINE},
    },

    [9] = {
        [0]= {"2-2-2","3C"},
        --   HIDDEN   COLOR
        [1]= {false, YELLOW_LINE},
        [2]= {false, ORANGE_LINE},
        [3]= {false, BLUE_LINE},

        [4]= {false, BLUE_LINE},
        [5]= {false, BLUE_LINE},
        [6]= {false, YELLOW_LINE},
        [7]= {false,  BLUE_LINE},

        [8]= {false, BLUE_LINE},
        [9]= {false, ORANGE_LINE},
        [10]={false,  BLUE_LINE},

        [11]={false, BLUE_LINE},
        [12]={false, YELLOW_LINE},
        [13]={false, BLUE_LINE},
        [14]={false,  BLUE_LINE},

        [15]={false, BLUE_LINE},
        [16]={false, ORANGE_LINE},
        [17]={false,  YELLOW_LINE},
    },


}


function BedlamVeilHelper.GetPlayerDistance(x2,z2)
	local zone1, x1, y1, z1 = GetUnitWorldPosition("player")

	if zone1~=1471 then
		return 100000000 -- some large number
	else
		return(zo_sqrt((x1 - x2)^2 + (z1 - z2)^2) / 100)
	end
end

function BedlamVeilHelper.checkInRangeOfPuzzle()
    local distPuzzle1  = BedlamVeilHelper.GetPlayerDistance(111659,142161)
    local distPuzzle2  = BedlamVeilHelper.GetPlayerDistance(99255,151672)
    local distPuzzle3  = BedlamVeilHelper.GetPlayerDistance(88659,141600)


    if distPuzzle1 < 12 then
        --d("close to puzzle 1")
        if BedlamVeilHelper.currentPuzzle == 0 then
            BedlamVeilHelper.currentPuzzle = 1
            BedlamVeilHelper.showPuzzleSolution(BedlamVeilHelper.currentPuzzle)
            BedlamVeilHelper.LoadJumpDetector()
        end
    elseif distPuzzle2 < 12 then
        --d("close to puzzle 1")
        if BedlamVeilHelper.currentPuzzle == 0 then
            BedlamVeilHelper.currentPuzzle = 4
            BedlamVeilHelper.showPuzzleSolution(BedlamVeilHelper.currentPuzzle)
            BedlamVeilHelper.LoadJumpDetector()
        end
    elseif distPuzzle3 < 12 then
        --d("close to puzzle 1")
        if BedlamVeilHelper.currentPuzzle == 0 then
            BedlamVeilHelper.currentPuzzle = 7
            BedlamVeilHelper.showPuzzleSolution(BedlamVeilHelper.currentPuzzle)
            BedlamVeilHelper.LoadJumpDetector()
        end
    else
        if BedlamVeilHelper.currentPuzzle ~= 0 then
            BedlamVeilHelper.currentPuzzle = 0
            BedlamVeilHelper.showPuzzleSolution(BedlamVeilHelper.currentPuzzle)
            BedlamVeilHelper.UnloadJumpDetector()
        end

    end

end


function BedlamVeilHelper.showPuzzleSolution(solution)
    if solution == 0 then
        BedlamVeilHelperPuzzleFrame:SetHidden(true)
        return
    end
    local solutionData = BedlamVeilHelper.puzzles[solution]
    if solutionData==nil then
        d("BVH: solution ".. solution .." does not exist")
        return
    end
    --d("BVH: Found puzzle "..solution)
    for k,v in pairs(solutionData) do
        if k == 0 then
            BedlamVeilHelperPuzzleFrameLabel:SetText("Jump "..v[1])
        else
            local lineControl = _G["BedlamVeilHelperPuzzleFrameLine" .. k]
            lineControl:SetHidden(v[1])
            lineControl:SetColor(unpack(v[2]))
        end

    end
    BedlamVeilHelperPuzzleFrame:SetHidden(false)

end



BedlamVeilHelper.currentPuzzle = 0
function BedlamVeilHelper.nextPuzzle()


    if BedlamVeilHelper.currentPuzzle==1 then
        BedlamVeilHelper.currentPuzzle=2
    elseif BedlamVeilHelper.currentPuzzle==2 then
        BedlamVeilHelper.currentPuzzle=1


    elseif BedlamVeilHelper.currentPuzzle==4 then
        BedlamVeilHelper.currentPuzzle=5
    elseif BedlamVeilHelper.currentPuzzle==5 then
        BedlamVeilHelper.currentPuzzle=4


    elseif BedlamVeilHelper.currentPuzzle==7 then
        BedlamVeilHelper.currentPuzzle=8
    elseif BedlamVeilHelper.currentPuzzle==8 then
        BedlamVeilHelper.currentPuzzle=9
    elseif BedlamVeilHelper.currentPuzzle==9 then
        BedlamVeilHelper.currentPuzzle=7
    end

    BedlamVeilHelper.showPuzzleSolution(BedlamVeilHelper.currentPuzzle)
end

function BedlamVeilHelper.LoadJumpDetector()
    EVENT_MANAGER:RegisterForUpdate(BedlamVeilHelper.name.."JumpCheck", 100, BedlamVeilHelper.checkForJump)
end

function BedlamVeilHelper.UnloadJumpDetector()
    EVENT_MANAGER:UnregisterForUpdate(BedlamVeilHelper.name.."JumpCheck")
end

BedlamVeilHelper.inAirLast = false
function BedlamVeilHelper.checkForJump()
    local newInAir = IsUnitInAir("player")
    if newInAir ~= BedlamVeilHelper.inAirLast then
        if newInAir then
            BedlamVeilHelper.nextPuzzle()
        end
        BedlamVeilHelper.inAirLast = newInAir
    end
end



function BedlamVeilHelper.PlayerActivated()


        BedlamVeilHelper.checkIfAddonNeedsToBeLoadedOrUnloaded()
end

function BedlamVeilHelper.setPos()

	local x, y = BedlamVeilHelper.savedVars.offsetPuzzleX, BedlamVeilHelper.savedVars.offsetPuzzleY
	BedlamVeilHelperPuzzleFrame:ClearAnchors()
	BedlamVeilHelperPuzzleFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)

end

function BedlamVeilHelper.savePos()

	BedlamVeilHelper.savedVars.offsetPuzzleX = BedlamVeilHelperPuzzleFrame:GetLeft()
	BedlamVeilHelper.savedVars.offsetPuzzleY = BedlamVeilHelperPuzzleFrame:GetTop()

end





function BedlamVeilHelper.checkIfAddonNeedsToBeLoadedOrUnloaded()
    local playerWorldZone, playerWorldX, playerWorldY, playerWorldZ = GetUnitWorldPosition("player")

	if playerWorldZone==1471  then
	    BedlamVeilHelper.LoadAddon()
	else
	    BedlamVeilHelper.UnloadAddon()
	end
end




function BedlamVeilHelper.LoadAddon()
    if BedlamVeilHelper.addonLoaded == false then
        d("Bedlam Veil Helper Loaded")

        EVENT_MANAGER:RegisterForUpdate(BedlamVeilHelper.name.."PuzzleCheck", 1000, BedlamVeilHelper.checkInRangeOfPuzzle)

        BedlamVeilHelperWarningFrame:SetHidden(true)

	    BedlamVeilHelper.addonLoaded=true
	end
end
function BedlamVeilHelper.UnloadAddon()
    if BedlamVeilHelper.addonLoaded == true then

        EVENT_MANAGER:UnregisterForEvent(BedlamVeilHelper.name.."PuzzleCheck")


	    BedlamVeilHelper.addonLoaded=false
	end
end

function BedlamVeilHelper.adjustUI()


    BedlamVeilHelper.setPos()


end

function BedlamVeilHelper.Init(event, addon)
	if addon ~= BedlamVeilHelper.name then return end




	EVENT_MANAGER:UnregisterForEvent(BedlamVeilHelper.name.."Load", EVENT_ADD_ON_LOADED)




	BedlamVeilHelper.savedVars = ZO_SavedVars:New(BedlamVeilHelper.name.."SavedVars", BedlamVeilHelper.varVersion, nil, BedlamVeilHelper.defaults)
	


    BedlamVeilHelper.adjustUI()



    EVENT_MANAGER:RegisterForEvent(BedlamVeilHelper.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, BedlamVeilHelper.PlayerActivated)



end

EVENT_MANAGER:RegisterForEvent(BedlamVeilHelper.name.."Load", EVENT_ADD_ON_LOADED, BedlamVeilHelper.Init)

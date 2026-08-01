BalSunnarHelper = BalSunnarHelper or { }
local BalSunnarHelper = BalSunnarHelper

local EM		= GetEventManager()


BalSunnarHelper.name		= "BalSunnarHelper"
BalSunnarHelper.version		= "1.0.0"
BalSunnarHelper.version		= "1.0.0"
BalSunnarHelper.varVersion 	= "1"


BalSunnarHelper.lastChokingPestilence=0


BalSunnarHelper.defaults	= {
	["offsetX"]	= 500,
	["offsetY"]	= 500,
	["spiderSpawn"]=true,
    ["kovanJump"]=true,

    ["showBeamIcons"]=false,
    ["showHealerStack"]=false,
    ["showDps1Stack"]=false,
    ["showDps2Stack"]=false,
    ["showTankStack"]=false,
    ["showGroundHealCentre"]=false,
    ["showEntranceLeft"]=false,
    ["showEntranceRight"]=false,
    ["showExitLeft"]=false,
    ["showExitRight"]=false,

    ["showEntranceSpread"]=true,
    ["showExitSpread"]=true,
    ["showRightSpread"]=true,
    ["showLeftSpread"]=true,

}






-- puzzle 2 location
-- [20:04] local icon = OSI.CreatePositionIcon(139228,35177,166644, "odysupporticons/icons/squares/squaretwo_red_one.dds",150, {1, 1, 1})
BalSunnarHelper.currentPuzzle = 0

function BalSunnarHelper.checkInRangeOfPuzzle()
    local distPuzzle1  = BalSunnarHelper.GetPlayerDistance(38969,67035)
    local distPuzzle2  = BalSunnarHelper.GetPlayerDistance(138243,167910)



    if distPuzzle1 < 24 then

        if BalSunnarHelper.currentPuzzle == 0 then
            BalSunnarHelper.currentPuzzle = 1

             d("Bal Sunnar: Jump to change puzzle solutions")
            if BalSunnarHelper.puzzle==2 then

                BalSunnarHelper.Puzzle1AIcons()
            elseif BalSunnarHelper.puzzle==3 then

                BalSunnarHelper.Puzzle1BIcons()
            elseif BalSunnarHelper.puzzle==4 then

                BalSunnarHelper.Puzzle1CIcons()
            else
                BalSunnarHelper.puzzle=2
                BalSunnarHelper.Puzzle1AIcons()
            end

            BalSunnarHelper.LoadJumpDetector()


        end
    elseif distPuzzle2 < 30.6 then

        if BalSunnarHelper.currentPuzzle == 0 then
            d("Bal Sunnar: Jump to change puzzle solutions")
            BalSunnarHelper.currentPuzzle = 2
            if BalSunnarHelper.puzzle==2 then

                BalSunnarHelper.Puzzle2AIcons()
            elseif BalSunnarHelper.puzzle==3 then

                BalSunnarHelper.Puzzle2BIcons()
            elseif BalSunnarHelper.puzzle==4 then

                BalSunnarHelper.Puzzle2CIcons()
            else
                BalSunnarHelper.puzzle=2
                BalSunnarHelper.Puzzle2AIcons()
            end

            BalSunnarHelper.LoadJumpDetector()
        end

    else
        if BalSunnarHelper.currentPuzzle ~= 0 then
            BalSunnarHelper.currentPuzzle = 0

            BalSunnarHelper.removeIcons()

            BalSunnarHelper.UnloadJumpDetector()
        end

    end


end


function BalSunnarHelper.LoadJumpDetector()
    EVENT_MANAGER:RegisterForUpdate(BalSunnarHelper.name.."JumpCheck", 200, BalSunnarHelper.checkForJump)
end

function BalSunnarHelper.UnloadJumpDetector()
    EVENT_MANAGER:UnregisterForUpdate(BalSunnarHelper.name.."JumpCheck")
end

BalSunnarHelper.inAirLast = false
function BalSunnarHelper.checkForJump()
    local newInAir = IsUnitInAir("player")
    if newInAir ~= BalSunnarHelper.inAirLast then
        if newInAir then
            BalSunnarHelper.PuzzleJumpToggle()
        end
        BalSunnarHelper.inAirLast = newInAir
    end
end



function BalSunnarHelper.GetPlayerDistance(x2,z2)
	local zone1, x1, y1, z1 = GetUnitWorldPosition("player")
    --d(zone1)
	if zone1~=1389 then
		return 100000000 -- some large number
	else
		return(zo_sqrt((x1 - x2)^2 + (z1 - z2)^2) / 100)
	end
end


function BalSunnarHelper.setPos()
	local x, y = BalSunnarHelper.savedVars.offsetX, BalSunnarHelper.savedVars.offsetY
	BalSunnarHelperFrame:ClearAnchors()
	BalSunnarHelperFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

function BalSunnarHelper.savePos()
	BalSunnarHelper.savedVars.offsetX = BalSunnarHelperFrame:GetLeft()
	BalSunnarHelper.savedVars.offsetY = BalSunnarHelperFrame:GetTop()
end



function BalSunnarHelper.countDown()

        local remaining = GetGameTimeMilliseconds()-BalSunnarHelper.lastChokingPestilence
        remaining = remaining / 1000
        remaining = 30 - remaining
        if remaining > 0 then
            BalSunnarHelperFrameTime:SetHidden(false)
            BalSunnarHelperFrameTime:SetText(string.format("%.1f", remaining))
            if remaining > 12 then
                BalSunnarHelperFrameTime:SetColor(unpack({1, 0, 0}))
            else
                BalSunnarHelperFrameTime:SetColor(unpack({0, 1, 0}))
            end

        else
            BalSunnarHelperFrameTime:SetHidden(true)
            EM:UnregisterForUpdate(BalSunnarHelper.name.."Update")
        end

end


function BalSunnarHelper.combatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
    if GetGameTimeMilliseconds()-BalSunnarHelper.lastChokingPestilence>25000 then
        --d("Start Choking Pestilence timer")
        BalSunnarHelper.lastChokingPestilence = GetGameTimeMilliseconds()
        EM:RegisterForUpdate(BalSunnarHelper.name.."Update", 100, BalSunnarHelper.countDown)
    end
end

function BalSunnarHelper.hideSpider()
    --d("Hiding spider")
    ScrivenersHallFrame:SetHidden(true)
    EM:UnregisterForUpdate(BalSunnarHelper.name.."UpdateSpider")
end



function BalSunnarHelper.combatEventKovanFold(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
    --d("SPIDER DROP"..targetName.."("..targetUnitId.."/"..targetType..") src:"..sourceName.." ("..sourceUnitId..") ability:"..abilityName.."("..abilityId..") duration/gained "..result)
    if BalSunnarHelper.savedVars.kovanJump then

        ScrivenersHallFrameLeftTop:SetText("JUMP")
        ScrivenersHallFrameRightTop:SetText("JUMP")
        ScrivenersHallFrameLeftBottom:SetText("JUMP")
        ScrivenersHallFrameRightBottom:SetText("JUMP")

        ScrivenersHallFrame:SetHidden(false)

        EM:RegisterForUpdate(BalSunnarHelper.name.."UpdateSpider", 1500, BalSunnarHelper.hideSpider)
    end

end



function BalSunnarHelper.removeIcons()
    if BalSunnarHelper.iconsUp == true then
        BalSunnarHelper.iconsUp = false
        if BalSunnarHelper.icon1 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon1 )
        end
        if BalSunnarHelper.icon2 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon2 )
        end
        if BalSunnarHelper.icon3 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon3 )
        end
        if BalSunnarHelper.icon4 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon4 )
        end
        if BalSunnarHelper.icon5 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon5 )
        end
        if BalSunnarHelper.icon6 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon6 )
        end
        if BalSunnarHelper.icon7 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon7 )
        end
        if BalSunnarHelper.icon8 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon8 )
        end
        if BalSunnarHelper.icon9 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon9 )
        end
        if BalSunnarHelper.icon10 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon10 )
        end
        if BalSunnarHelper.icon11 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon11 )
        end
        if BalSunnarHelper.icon12 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon12 )
        end
        if BalSunnarHelper.icon13 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon13 )
        end
        if BalSunnarHelper.icon14 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon14 )
        end
        if BalSunnarHelper.icon15 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon15 )
        end
        if BalSunnarHelper.icon16 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon16 )
        end
        if BalSunnarHelper.icon17 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon17 )
        end
        if BalSunnarHelper.icon18 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon18 )
        end
        if BalSunnarHelper.icon19 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon19 )
        end
        if BalSunnarHelper.icon20 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon20 )
        end

        if BalSunnarHelper.icon101 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon101 )
        end
        if BalSunnarHelper.icon102 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon102 )
        end
        if BalSunnarHelper.icon103 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon103 )
        end
        if BalSunnarHelper.icon104 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon104 )
        end
        if BalSunnarHelper.icon105 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon105 )
        end
        if BalSunnarHelper.icon106 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon106 )
        end
        if BalSunnarHelper.icon107 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon107 )
        end
        if BalSunnarHelper.icon108 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon108 )
        end

        if BalSunnarHelper.icon120 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon120 )
        end
        if BalSunnarHelper.icon121 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon121)
        end
        if BalSunnarHelper.icon122 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon122)
        end
        if BalSunnarHelper.icon123 then
            OSI.DiscardPositionIcon(BalSunnarHelper.icon123)
        end


        BalSunnarHelper.icon1=nil
        BalSunnarHelper.icon2=nil
        BalSunnarHelper.icon3=nil
        BalSunnarHelper.icon4=nil
        BalSunnarHelper.icon5=nil
        BalSunnarHelper.icon6=nil
        BalSunnarHelper.icon7=nil
        BalSunnarHelper.icon8=nil
        BalSunnarHelper.icon9=nil
        BalSunnarHelper.icon10=nil
        BalSunnarHelper.icon11=nil
        BalSunnarHelper.icon12=nil
        BalSunnarHelper.icon13=nil
        BalSunnarHelper.icon14=nil
        BalSunnarHelper.icon15=nil
        BalSunnarHelper.icon16=nil

        BalSunnarHelper.icon101=nil
        BalSunnarHelper.icon102=nil
        BalSunnarHelper.icon103=nil
        BalSunnarHelper.icon104=nil
        BalSunnarHelper.icon105=nil
        BalSunnarHelper.icon106=nil
        BalSunnarHelper.icon107=nil
        BalSunnarHelper.icon108=nil

        BalSunnarHelper.icon120=nil
        BalSunnarHelper.icon121=nil
        BalSunnarHelper.icon122=nil
        BalSunnarHelper.icon123=nil


    end
end


function BalSunnarHelper.addBoss1Icons()
    if BalSunnarHelper.iconsUp == false then
        BalSunnarHelper.iconsUp=true


        if BalSunnarHelper.savedVars.showRightSpread then BalSunnarHelper.icon120 = OSI.CreatePositionIcon(43944,26396-75,41304, "BalSunnarHelper/icons/circle-c.dds",75, {1, 1, 1}) end
        if BalSunnarHelper.savedVars.showLeftSpread then BalSunnarHelper.icon121 = OSI.CreatePositionIcon(41845,26396-75,41320, "BalSunnarHelper/icons/circle-b.dds",75, {1, 1, 1}) end
        if BalSunnarHelper.savedVars.showEntranceSpread then BalSunnarHelper.icon122 = OSI.CreatePositionIcon(42878,26396-75,42437, "BalSunnarHelper/icons/circle-a.dds",75, {1, 1, 1}) end
        if BalSunnarHelper.savedVars.showExitSpread then BalSunnarHelper.icon123 = OSI.CreatePositionIcon(42862,26396-75,40288, "BalSunnarHelper/icons/circle-a.dds",75, {1, 1, 1}) end

        if BalSunnarHelper.savedVars.showExitLeft then
           if BalSunnarHelper.savedVars.showGroundHealCentre then BalSunnarHelper.icon1 = OSI.CreatePositionIcon(42193,26396-75,40646, "odysupporticons/icons/squares/marker_lightblue.dds",75, {1, 1, 1}) end
           if BalSunnarHelper.savedVars.showHealerStack then BalSunnarHelper.icon2 = OSI.CreatePositionIcon(41840,26396-75,40298, "odysupporticons/icons/squares/squaretwo_blue_three.dds",75, {1, 1, 1}) end
           if BalSunnarHelper.savedVars.showDps1Stack then BalSunnarHelper.icon3 = OSI.CreatePositionIcon(42540,26396-75,40293, "odysupporticons/icons/squares/squaretwo_blue_one.dds",75, {1, 1, 1}) end
           if BalSunnarHelper.savedVars.showDps2Stack then BalSunnarHelper.icon4 = OSI.CreatePositionIcon(41845,26396-75,40998, "odysupporticons/icons/squares/squaretwo_blue_two.dds",75, {1, 1, 1}) end
           if BalSunnarHelper.savedVars.showTankStack then BalSunnarHelper.icon5 = OSI.CreatePositionIcon(42545,26396-75,40993, "odysupporticons/icons/squares/squaretwo_blue_four.dds",75, {1, 1, 1}) end
        end
        if BalSunnarHelper.savedVars.showExitRight then
           if BalSunnarHelper.savedVars.showGroundHealCentre then BalSunnarHelper.icon6 = OSI.CreatePositionIcon(43536,26396-75,40636, "odysupporticons/icons/squares/marker_lightblue.dds",75, {1, 1, 1}) end
           if BalSunnarHelper.savedVars.showHealerStack then BalSunnarHelper.icon7 = OSI.CreatePositionIcon(43883,26396-75,40283, "odysupporticons/icons/squares/squaretwo_blue_three.dds",75, {1, 1, 1}) end
           if BalSunnarHelper.savedVars.showDps1Stack then BalSunnarHelper.icon8 = OSI.CreatePositionIcon(43888,26396-75,40983, "odysupporticons/icons/squares/squaretwo_blue_one.dds",75, {1, 1, 1}) end
           if BalSunnarHelper.savedVars.showDps2Stack then BalSunnarHelper.icon9 = OSI.CreatePositionIcon(43183,26396-75,40288, "odysupporticons/icons/squares/squaretwo_blue_two.dds",75, {1, 1, 1}) end
           if BalSunnarHelper.savedVars.showTankStack then BalSunnarHelper.icon10 = OSI.CreatePositionIcon(43188,26396-75,40988, "odysupporticons/icons/squares/squaretwo_blue_four.dds",75, {1, 1, 1}) end
        end
        if BalSunnarHelper.savedVars.showEntranceRight then
           if BalSunnarHelper.savedVars.showGroundHealCentre then BalSunnarHelper.icon11 = OSI.CreatePositionIcon(43546,26396-75,41979, "odysupporticons/icons/squares/marker_lightblue.dds",75, {1, 1, 1}) end
           if BalSunnarHelper.savedVars.showHealerStack then BalSunnarHelper.icon12 = OSI.CreatePositionIcon(43898,26396-75,42326, "odysupporticons/icons/squares/squaretwo_blue_three.dds",75, {1, 1, 1}) end
           if BalSunnarHelper.savedVars.showDps1Stack then BalSunnarHelper.icon13 = OSI.CreatePositionIcon(43198,26396-75,42331, "odysupporticons/icons/squares/squaretwo_blue_one.dds",75, {1, 1, 1}) end
           if BalSunnarHelper.savedVars.showDps2Stack then BalSunnarHelper.icon14 = OSI.CreatePositionIcon(43893,26396-75,41626, "odysupporticons/icons/squares/squaretwo_blue_two.dds",75, {1, 1, 1}) end
           if BalSunnarHelper.savedVars.showTankStack then BalSunnarHelper.icon15 = OSI.CreatePositionIcon(43193,26396-75,41631, "odysupporticons/icons/squares/squaretwo_blue_four.dds",75, {1, 1, 1}) end
        end
        if BalSunnarHelper.savedVars.showEntranceLeft then
           if BalSunnarHelper.savedVars.showGroundHealCentre then BalSunnarHelper.icon16 = OSI.CreatePositionIcon(42203,26396-75,41989, "odysupporticons/icons/squares/marker_lightblue.dds",75, {1, 1, 1}) end
           if BalSunnarHelper.savedVars.showHealerStack then BalSunnarHelper.icon17 = OSI.CreatePositionIcon(41855,26396-75,42341, "odysupporticons/icons/squares/squaretwo_blue_three.dds",75, {1, 1, 1}) end
           if BalSunnarHelper.savedVars.showDps1Stack then BalSunnarHelper.icon18 = OSI.CreatePositionIcon(41850,26396-75,41641, "odysupporticons/icons/squares/squaretwo_blue_one.dds",75, {1, 1, 1}) end
           if BalSunnarHelper.savedVars.showDps2Stack then BalSunnarHelper.icon19 = OSI.CreatePositionIcon(42555,26396-75,42336, "odysupporticons/icons/squares/squaretwo_blue_two.dds",75, {1, 1, 1}) end
           if BalSunnarHelper.savedVars.showTankStack then BalSunnarHelper.icon20 = OSI.CreatePositionIcon(42550,26396-75,41636, "odysupporticons/icons/squares/squaretwo_blue_four.dds",75, {1, 1, 1}) end
        end


    end
end
-- the healing AOE circle is 10m diameter (5m radius)


function BalSunnarHelper.addBoss2Icons()
    if BalSunnarHelper.iconsUp == false then
        BalSunnarHelper.iconsUp=true

        BalSunnarHelper.icon1 = OSI.CreatePositionIcon(136671,30700-75,80145, "BalSunnarHelper/icons/circle-a.dds",150, {1, 1, 1}) -- banner
        BalSunnarHelper.icon2 = OSI.CreatePositionIcon(141369,30706-75,76589, "BalSunnarHelper/icons/circle-b.dds",150, {1, 1, 1}) -- left
        BalSunnarHelper.icon3 = OSI.CreatePositionIcon(141493,30702-75,82684, "BalSunnarHelper/icons/circle-c.dds",150, {1, 1, 1}) -- right
    end
end


function BalSunnarHelper.Puzzle1AIcons()
   BalSunnarHelper.removeIcons()
   if BalSunnarHelper.iconsUp == false then
        BalSunnarHelper.iconsUp=true

        --d("Bal Sunnar Second Puzzle 1-Green")

        BalSunnarHelper.icon1 = OSI.CreatePositionIcon(39246,35271+200,67084, "odysupporticons/icons/squares/squaretwo_green_one.dds",75, {1, 1, 1}) -- 1 turn
        BalSunnarHelper.icon2 = OSI.CreatePositionIcon(39075,35271+200,67006, "odysupporticons/icons/squares/squaretwo_green_one.dds",75, {1, 1, 1}) -- 2 turn
        BalSunnarHelper.icon3 = OSI.CreatePositionIcon(38900,35271+200,66901, "odysupporticons/icons/squares/squaretwo_green_one.dds",75, {1, 1, 1}) -- 2 turn
        BalSunnarHelper.icon4 = OSI.CreatePositionIcon(38709,35271+200,66824, "odysupporticons/icons/squares/squaretwo_green_one.dds",75, {1, 1, 1}) -- 0 turn

        BalSunnarHelper.icon5  = OSI.CreatePositionIcon(39422,35177-75,68700, "odysupporticons/icons/squares/squaretwo_green.dds",100, {1, 1, 1}) -- green

    end
end


function BalSunnarHelper.Puzzle1BIcons()
   BalSunnarHelper.removeIcons()
   if BalSunnarHelper.iconsUp == false then
        BalSunnarHelper.iconsUp=true

       -- d("Bal Sunnar Second Puzzle 1-Blue")

        BalSunnarHelper.icon1 = OSI.CreatePositionIcon(39246,35271+200,67084, "odysupporticons/icons/squares/squaretwo_green_one.dds",75, {1, 1, 1}) -- 1 turn
        BalSunnarHelper.icon2 = OSI.CreatePositionIcon(39075,35271+200,67006, "odysupporticons/icons/squares/squaretwo_green_two.dds",75, {1, 1, 1}) -- 2 turn
        --BalSunnarHelper.icon3 = OSI.CreatePositionIcon(38900,35271+200,66901, "odysupporticons/icons/squares/squaretwo_green.dds",50, {1, 1, 1}) -- 0 turn
        BalSunnarHelper.icon4 = OSI.CreatePositionIcon(38709,35271+200,66824, "odysupporticons/icons/squares/squaretwo_green_one.dds",75, {1, 1, 1}) -- 1 turn

        BalSunnarHelper.icon5  = OSI.CreatePositionIcon(39422,35177-75,68700, "odysupporticons/icons/squares/squaretwo_blue.dds",100, {1, 1, 1}) -- green

    end
end



function BalSunnarHelper.Puzzle1CIcons()
   BalSunnarHelper.removeIcons()
   if BalSunnarHelper.iconsUp == false then
        BalSunnarHelper.iconsUp=true

        --d("Bal Sunnar Second Puzzle 1-Red")

        --BalSunnarHelper.icon1 = OSI.CreatePositionIcon(39246,35271+200,67084, "odysupporticons/icons/squares/squaretwo_green.dds",50, {1, 1, 1}) -- 0 turn
        BalSunnarHelper.icon2 = OSI.CreatePositionIcon(39075,35271+200,67006, "odysupporticons/icons/squares/squaretwo_green_one.dds",75, {1, 1, 1}) -- 1 turn
        --BalSunnarHelper.icon3 = OSI.CreatePositionIcon(38900,35271+200,66901, "odysupporticons/icons/squares/squaretwo_green.dds",50, {1, 1, 1}) -- 1 turn
        BalSunnarHelper.icon4 = OSI.CreatePositionIcon(38709,35271+200,66824, "odysupporticons/icons/squares/squaretwo_green_one.dds",75, {1, 1, 1}) -- 0 turn

        BalSunnarHelper.icon5  = OSI.CreatePositionIcon(39422,35177-75,68700, "odysupporticons/icons/squares/squaretwo_red.dds",100, {1, 1, 1}) -- green

    end
end

function BalSunnarHelper.Puzzle2AIcons()
   BalSunnarHelper.removeIcons()
   if BalSunnarHelper.iconsUp == false then
        BalSunnarHelper.iconsUp=true

        --d("Bal Sunnar Second Puzzle A")

        BalSunnarHelper.icon1 = OSI.CreatePositionIcon(139842,35177-75,167927, "odysupporticons/icons/squares/squaretwo_green_one.dds",150, {1, 1, 1}) -- 1 turn
        BalSunnarHelper.icon2 = OSI.CreatePositionIcon(139261,35177-75,167349, "odysupporticons/icons/squares/squaretwo_green_two.dds",150, {1, 1, 1}) -- 2 turn
        BalSunnarHelper.icon3 = OSI.CreatePositionIcon(138743,35177-75,166999, "odysupporticons/icons/squares/squaretwo_green_two.dds",150, {1, 1, 1}) -- 2 turn
        BalSunnarHelper.icon4 = OSI.CreatePositionIcon(138927,35177-75,166519, "odysupporticons/icons/squares/squaretwo_green_two.dds",150, {1, 1, 1}) -- 0 turn
        BalSunnarHelper.icon5  = OSI.CreatePositionIcon(138127,35177-75,165776, "odysupporticons/icons/squares/squaretwo_green_one.dds",150, {1, 1, 1}) -- 1 turn
        BalSunnarHelper.icon6  = OSI.CreatePositionIcon(139381,35177-75,165508, "odysupporticons/icons/squares/squaretwo_green_one.dds",150, {1, 1, 1}) -- 1 turn
        BalSunnarHelper.icon7  = OSI.CreatePositionIcon(138633,35177-75,165278, "odysupporticons/icons/squares/squaretwo_green_two.dds",150, {1, 1, 1}) -- 2 turn
    end
end

function BalSunnarHelper.Puzzle2BIcons() -- verified works perfectly
   BalSunnarHelper.removeIcons()
   if BalSunnarHelper.iconsUp == false then
        BalSunnarHelper.iconsUp=true

        --d("Bal Sunnar Second Puzzle B")

        BalSunnarHelper.icon1 = OSI.CreatePositionIcon(140634,35177-75,166863, "odysupporticons/icons/squares/squaretwo_green_one.dds",150, {1, 1, 1}) -- turn 1
        BalSunnarHelper.icon2 = OSI.CreatePositionIcon(139843,35177-75,167480, "odysupporticons/icons/squares/squaretwo_green.dds",150, {1, 1, 1}) -- turn 0
        BalSunnarHelper.icon3 = OSI.CreatePositionIcon(139260,35177-75,167008, "odysupporticons/icons/squares/squaretwo_green_one.dds",150, {1, 1, 1}) -- turn 1
        BalSunnarHelper.icon4 = OSI.CreatePositionIcon(138532,35177-75,167088, "odysupporticons/icons/squares/squaretwo_green_two.dds",150, {1, 1, 1}) -- turn 2
        BalSunnarHelper.icon5  = OSI.CreatePositionIcon(138180,35177-75,168049, "odysupporticons/icons/squares/squaretwo_green_one.dds",150, {1, 1, 1}) -- turn 1
        BalSunnarHelper.icon6  = OSI.CreatePositionIcon(138691,35177-75,166652, "odysupporticons/icons/squares/squaretwo_green_one.dds",150, {1, 1, 1}) -- turn 1
        BalSunnarHelper.icon7  = OSI.CreatePositionIcon(138369,35177-75,165788, "odysupporticons/icons/squares/squaretwo_green_one.dds",150, {1, 1, 1}) -- turn 1
    end
end


function BalSunnarHelper.Puzzle2CIcons() -- verified works perfectly
   BalSunnarHelper.removeIcons()
   if BalSunnarHelper.iconsUp == false then
        BalSunnarHelper.iconsUp=true

        --d("Bal Sunnar Second Puzzle C")

        BalSunnarHelper.icon1 = OSI.CreatePositionIcon(140233,35177,165873, "odysupporticons/icons/squares/squaretwo_green_one.dds",150, {1, 1, 1}) -- turn 1
        BalSunnarHelper.icon2 = OSI.CreatePositionIcon(140032,35177,167870, "odysupporticons/icons/squares/squaretwo_green_one.dds",150, {1, 1, 1}) -- turn 1
        BalSunnarHelper.icon3 = OSI.CreatePositionIcon(139313,35177,167688, "odysupporticons/icons/squares/squaretwo_green_one.dds",150, {1, 1, 1}) -- turn 1
        BalSunnarHelper.icon4 = OSI.CreatePositionIcon(138776,35177,167901, "odysupporticons/icons/squares/squaretwo_green_one.dds",150, {1, 1, 1}) -- turn 1
        BalSunnarHelper.icon5  = OSI.CreatePositionIcon(138873,35177,166955, "odysupporticons/icons/squares/squaretwo_green_two.dds",150, {1, 1, 1}) -- turn 2
        BalSunnarHelper.icon6  = OSI.CreatePositionIcon(138511,35177,166521, "odysupporticons/icons/squares/squaretwo_green_two.dds",150, {1, 1, 1}) -- turn 2
        BalSunnarHelper.icon7  = OSI.CreatePositionIcon(138455,35177,165817, "odysupporticons/icons/squares/squaretwo_green_two.dds",150, {1, 1, 1}) -- turn 2
    end
end




BalSunnarHelper.iconsUp = false

function BalSunnarHelper.BossesChanged( eventCode )

    zid = GetCurrentMapZoneIndex()

    local bossName = string.lower(GetUnitName("boss1"))

    if bossName=="roksa the warped" then
        BalSunnarHelper.addBoss2Icons()

    elseif bossName=="kovan giryon" then
            BalSunnarHelper.addBoss1Icons()
    else
        --d("boss:"..bossName)
        BalSunnarHelper.removeIcons()
    end

end



BalSunnarHelper.puzzle = 0
function BalSunnarHelper.PuzzleToggle()
    BalSunnarHelper.puzzle= BalSunnarHelper.puzzle +1
    if BalSunnarHelper.puzzle>4 then
        BalSunnarHelper.puzzle=1
    end
    if BalSunnarHelper.puzzle==1 then
        BalSunnarHelper.puzzle1()
    elseif BalSunnarHelper.puzzle==2 then
        BalSunnarHelper.Puzzle2AIcons()
    elseif BalSunnarHelper.puzzle==3 then
        BalSunnarHelper.Puzzle2BIcons()
    elseif BalSunnarHelper.puzzle==4 then
        BalSunnarHelper.Puzzle2CIcons()
    end
end





function BalSunnarHelper.PuzzleJumpToggle()
    BalSunnarHelper.puzzle= BalSunnarHelper.puzzle +1
    if BalSunnarHelper.puzzle>4 then
        BalSunnarHelper.puzzle=2
    end
    if BalSunnarHelper.puzzle<2 then
        BalSunnarHelper.puzzle=2
    end

    if BalSunnarHelper.currentPuzzle==1 then
        if BalSunnarHelper.puzzle==2 then
            BalSunnarHelper.Puzzle1AIcons()
        elseif BalSunnarHelper.puzzle==3 then
            BalSunnarHelper.Puzzle1BIcons()
        elseif BalSunnarHelper.puzzle==4 then
            BalSunnarHelper.Puzzle1CIcons()
        end
    end

    if BalSunnarHelper.currentPuzzle==2 then
        if BalSunnarHelper.puzzle==2 then
            BalSunnarHelper.Puzzle2AIcons()
        elseif BalSunnarHelper.puzzle==3 then
            BalSunnarHelper.Puzzle2BIcons()
        elseif BalSunnarHelper.puzzle==4 then
            BalSunnarHelper.Puzzle2CIcons()
        end
    end
end



function BalSunnarHelper.PlayerActivated()


        BalSunnarHelper.checkIfAddonNeedsToBeLoadedOrUnloaded()
end




function BalSunnarHelper.checkIfAddonNeedsToBeLoadedOrUnloaded()
    local playerWorldZone, playerWorldX, playerWorldY, playerWorldZ = GetUnitWorldPosition("player")

	if playerWorldZone==1389 then
	    BalSunnarHelper.LoadAddon()
	else
	    BalSunnarHelper.UnloadAddon()
	end
end



BalSunnarHelper.addonLoaded= false
function BalSunnarHelper.LoadAddon()
    if BalSunnarHelper.addonLoaded == false then
        d("Bal Sunnar Helper Loaded")



        EM:RegisterForEvent(BalSunnarHelper.name.."ECE" , EVENT_COMBAT_EVENT, BalSunnarHelper.combatEvent)
        EM:AddFilterForEvent(BalSunnarHelper.name.."ECE", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 177291) -- Choking Pestilence bal sunnar
        EM:AddFilterForEvent(BalSunnarHelper.name.."ECE", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)


        EM:RegisterForEvent(BalSunnarHelper.name.."ECEKovan" , EVENT_COMBAT_EVENT, BalSunnarHelper.combatEventKovanFold)
        EM:AddFilterForEvent(BalSunnarHelper.name.."ECEKovan", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 176453) -- kovan jump
        EM:AddFilterForEvent(BalSunnarHelper.name.."ECEKovan", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
        EM:AddFilterForEvent(BalSunnarHelper.name.."ECEKovan", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- kovan jump


        EM:RegisterForUpdate(BalSunnarHelper.name.."PuzzleCheck", 1000, BalSunnarHelper.checkInRangeOfPuzzle)

        EM:RegisterForEvent(BalSunnarHelper.name .. "_EventBossChanged", EVENT_BOSSES_CHANGED, BalSunnarHelper.BossesChanged)


	    BalSunnarHelper.addonLoaded=true
	end
end
function BalSunnarHelper.UnloadAddon()
    if BalSunnarHelper.addonLoaded == true then
        d("Bal Sunnar Helper Unloaded")

        EM:UnregisterForEvent(BalSunnarHelper.name.."ECE" , EVENT_COMBAT_EVENT)

        EM:UnregisterForEvent(BalSunnarHelper.name.."ECEKovan" , EVENT_COMBAT_EVENT)


        EM:UnregisterForUpdate(BalSunnarHelper.name.."PuzzleCheck")

        EM:UnregisterForEvent(BalSunnarHelper.name .. "_EventBossChanged", EVENT_BOSSES_CHANGED)


	    BalSunnarHelper.addonLoaded=false
	end
end





function BalSunnarHelper.Init(event, addon)
	if addon ~= BalSunnarHelper.name then return end


	EM:UnregisterForEvent(BalSunnarHelper.name.."Load", EVENT_ADD_ON_LOADED)

	BalSunnarHelper.savedVars = ZO_SavedVars:New(BalSunnarHelper.name.."SavedVars", BalSunnarHelper.varVersion, nil, BalSunnarHelper.defaults)


	BalSunnarHelper.setPos()
	BalSunnarHelperFrameTime:SetHidden(true)


    EM:RegisterForEvent(BalSunnarHelper.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, BalSunnarHelper.PlayerActivated)

    BalSunnarHelper.setupMenu()

    BalSunnarHelper.savedVars.showExitRight = false
    BalSunnarHelper.savedVars.showExitLeft = false
    BalSunnarHelper.savedVars.showEntranceRight = false
    BalSunnarHelper.savedVars.showEntranceLeft = false
    BalSunnarHelper.savedVars.showTankStack = false
    BalSunnarHelper.savedVars.showDps2Stack = false
    BalSunnarHelper.savedVars.showDps1Stack = false
    BalSunnarHelper.savedVars.showHealerStack = false
    BalSunnarHelper.savedVars.showGroundHealCentre = false

end

EM:RegisterForEvent(BalSunnarHelper.name.."Load", EVENT_ADD_ON_LOADED, BalSunnarHelper.Init)

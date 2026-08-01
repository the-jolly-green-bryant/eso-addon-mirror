vASHelper = vASHelper or { }
local vASHelper = vASHelper

local EM		= GetEventManager()


vASHelper.name		= "vASHelper"
vASHelper.version		= "1.0.5"
vASHelper.varVersion 	= "1"
vASHelper.debug 	= false

vASHelper.bossNames  = {
    ["saint olms the just"]        = true, -- EN
    ["святой олмс справедливый"]   = true, -- RU
    ["heiliger olms der gerechte"] = true, -- DE
    ["saint olms le juste"]        = true, -- FR
    ["san olms el justo"]          = true, -- SP
}


vASHelper.defaults	= {
	["offsetX"]	= 500,
	["offsetX"]	= 500,
	["offsetY"]	= 500,

	["displayLane1"] = true,
	["displayLane2"] = true,
	["displayLane3"] = true,
	["displayLane4"] = true,
	["displayLane5"] = true,
	["displayLane6"] = true,
	["displayLane7"] = true,
	["displayLane8"] = true,
	["displayHealerZone"] = false,
	["displayOlhmsJumpZone"]= false,
	["displayMtLocation"]=false,
	["selfishPurge"]=false,

    ["iconSize"]=100,
}



function vASHelper.refreshIcons()
    local playerWorldZone, playerWorldX, playerWorldY, playerWorldZ = GetUnitWorldPosition("player")
    --local zid = GetCurrentMapZoneIndex()
    if playerWorldZone == 1000 then
	--if zid == 608 then
	    vASHelper.hideMTIcons()
        vASHelper.hideLanes()
        vASHelper.hideHeals()
        vASHelper.hideOlmsJumpBorders()

        vASHelper.showMTIcons()
        vASHelper.showLanes()
        vASHelper.showHeals()
        vASHelper.showOlmsJumpBorders()
    end
end


function vASHelper.hideAllIcons()
    vASHelper.hideMTIcons()
    vASHelper.hideLanes()
    vASHelper.hideHeals()
    vASHelper.hideOlmsJumpBorders()
end


function vASHelper.BossesChanged( eventCode )
    local playerWorldZone, playerWorldX, playerWorldY, playerWorldZ = GetUnitWorldPosition("player")
    --local zid = GetCurrentMapZoneIndex()
    vASHelperFrame:SetHidden(true)
    if playerWorldZone == 1000 then
	--if zid == 608 then
		    local bossName = string.lower(GetUnitName("boss1"))


            if vASHelper.bossNames[bossName] then --bossName=="saint olms the just" then

                vASHelper.showMTIcons()
                vASHelper.showLanes()
                vASHelper.showHeals()
                vASHelper.showOlmsJumpBorders()

            else
                vASHelper.hideMTIcons()
                vASHelper.hideLanes()
                vASHelper.hideHeals()
                vASHelper.hideOlmsJumpBorders()
            end

    else
        vASHelper.hideMTIcons()
        vASHelper.hideLanes()
        vASHelper.hideHeals()
        vASHelper.hideOlmsJumpBorders()
	end
end



local lanesIconsLoaded = false
local lanesIcons = {}

function vASHelper.showLanes()

    if (lanesIconsLoaded) then

        return
    end
    if vASHelper.debug then d("vASHelper.showLanes()") end


    local iconHeight = 61450 -- put it in the ground
    local iconSize = vASHelper.savedVars.iconSize

    local A1x = 97793
    local A1y = 100906

    local B1x = 96356
    local B1y = 100522


    local A2x = 97823
    local A2y = 100560

    local B2x = 96257
    local B2y = 99522


    local A3x = 98118
    local A3y = 100234

    local B3x = 96784
    local B3y = 98733

    local A4x = 98541
    local A4y = 100005

    local B4x = 97950
    local B4y = 98302

    local reflectionX = 98783

    local A5x = reflectionX + (reflectionX - A4x)
    local A5y = A4y

    local B5x = reflectionX + (reflectionX - B4x)
    local B5y = B4y

    local A6x = reflectionX + (reflectionX - A3x)
    local A6y = A3y

    local B6x = reflectionX + (reflectionX - B3x)
    local B6y = B3y

    local A7x = reflectionX + (reflectionX - A2x)
    local A7y = A2y

    local B7x = reflectionX + (reflectionX - B2x)
    local B7y = B2y

    local A8x = reflectionX + (reflectionX - A1x)
    local A8y = A1y

    local B8x = reflectionX + (reflectionX - B1x)
    local B8y = B1y

    if vASHelper.savedVars.displayLane1 then
        local iconLane1A = OSI.CreatePositionIcon(A1x,iconHeight,A1y, "odysupporticons/icons/squares/squaretwo_green_one.dds",iconSize, {1, 1, 1})
        local iconLane1B = OSI.CreatePositionIcon(B1x,iconHeight,B1y, "odysupporticons/icons/squares/squaretwo_green_one.dds",iconSize, {1, 1, 1})
        lanesIcons["iconLane1A"] = iconLane1A
        lanesIcons["iconLane1B"] = iconLane1B
    end

    if vASHelper.savedVars.displayLane2 then
        local iconLane2A = OSI.CreatePositionIcon(A2x,iconHeight,A2y, "odysupporticons/icons/squares/squaretwo_green_two.dds",iconSize, {1, 1, 1})
        local iconLane2B = OSI.CreatePositionIcon(B2x,iconHeight,B2y, "odysupporticons/icons/squares/squaretwo_green_two.dds",iconSize, {1, 1, 1})
        lanesIcons["iconLane2A"] = iconLane2A
        lanesIcons["iconLane2B"] = iconLane2B
    end

    if vASHelper.savedVars.displayLane3 then
        local iconLane3A = OSI.CreatePositionIcon(A3x,iconHeight,A3y, "odysupporticons/icons/squares/squaretwo_green_three.dds",iconSize, {1, 1, 1})
        local iconLane3B = OSI.CreatePositionIcon(B3x,iconHeight,B3y, "odysupporticons/icons/squares/squaretwo_green_three.dds",iconSize, {1, 1, 1})
        lanesIcons["iconLane3A"] = iconLane3A
        lanesIcons["iconLane3B"] = iconLane3B
    end

    if vASHelper.savedVars.displayLane4 then
        local iconLane4A = OSI.CreatePositionIcon(A4x,iconHeight,A4y, "odysupporticons/icons/squares/squaretwo_green_four.dds",iconSize, {1, 1, 1})
        local iconLane4B = OSI.CreatePositionIcon(B4x,iconHeight,B4y, "odysupporticons/icons/squares/squaretwo_green_four.dds",iconSize, {1, 1, 1})
        lanesIcons["iconLane4A"] = iconLane4A
        lanesIcons["iconLane4B"] = iconLane4B
    end

    if vASHelper.savedVars.displayLane5 then
        local iconLane5A = OSI.CreatePositionIcon(A5x,iconHeight,A5y, "odysupporticons/icons/squares/squaretwo_red_five.dds",iconSize, {1, 1, 1})
        local iconLane5B = OSI.CreatePositionIcon(B5x,iconHeight,B5y, "odysupporticons/icons/squares/squaretwo_red_five.dds",iconSize, {1, 1, 1})
        lanesIcons["iconLane5A"] = iconLane5A
        lanesIcons["iconLane5B"] = iconLane5B
    end

    if vASHelper.savedVars.displayLane6 then
        local iconLane6A = OSI.CreatePositionIcon(A6x,iconHeight,A6y, "odysupporticons/icons/squares/squaretwo_red_six.dds",iconSize, {1, 1, 1})
        local iconLane6B = OSI.CreatePositionIcon(B6x,iconHeight,B6y, "odysupporticons/icons/squares/squaretwo_red_six.dds",iconSize, {1, 1, 1})
        lanesIcons["iconLane6A"] = iconLane6A
        lanesIcons["iconLane6B"] = iconLane6B
    end

    if vASHelper.savedVars.displayLane7 then
        local iconLane7A = OSI.CreatePositionIcon(A7x,iconHeight,A7y, "odysupporticons/icons/squares/squaretwo_red_seven.dds",iconSize, {1, 1, 1})
        local iconLane7B = OSI.CreatePositionIcon(B7x,iconHeight,B7y, "odysupporticons/icons/squares/squaretwo_red_seven.dds",iconSize, {1, 1, 1})
        lanesIcons["iconLane7A"] = iconLane7A
        lanesIcons["iconLane7B"] = iconLane7B
    end

    if vASHelper.savedVars.displayLane8 then
        local iconLane8A = OSI.CreatePositionIcon(A8x,iconHeight,A8y, "odysupporticons/icons/squares/squaretwo_red_eight.dds",iconSize, {1, 1, 1})
        local iconLane8B = OSI.CreatePositionIcon(B8x,iconHeight,B8y, "odysupporticons/icons/squares/squaretwo_red_eight.dds",iconSize, {1, 1, 1})
        lanesIcons["iconLane8A"] = iconLane8A
        lanesIcons["iconLane8B"] = iconLane8B
    end


    lanesIconsLoaded = true

end


function vASHelper.hideLanes()

    if not (lanesIconsLoaded) then
        return
    end

    if vASHelper.debug then d("vASHelper.hideLanes()") end

    if lanesIcons["iconLane1A"]~= nil then
        OSI.DiscardPositionIcon(lanesIcons["iconLane1A"])
        if vASHelper.debug then d("vASHelper.hideLanes() 1A") end
    end

    if lanesIcons["iconLane1B"]~= nil then
        OSI.DiscardPositionIcon(lanesIcons["iconLane1B"])
        if vASHelper.debug then d("vASHelper.hideLanes() 1B") end
    end

    if lanesIcons["iconLane2A"]~= nil then
        OSI.DiscardPositionIcon(lanesIcons["iconLane2A"])
        if vASHelper.debug then d("vASHelper.hideLanes() 2A") end
    end

    if lanesIcons["iconLane2B"]~= nil then
        OSI.DiscardPositionIcon(lanesIcons["iconLane2B"])
        if vASHelper.debug then d("vASHelper.hideLanes() 2B") end
    end

    if lanesIcons["iconLane3A"]~= nil then
        OSI.DiscardPositionIcon(lanesIcons["iconLane3A"])
        if vASHelper.debug then d("vASHelper.hideLanes() 3A") end
    end

    if lanesIcons["iconLane3B"]~= nil then
        OSI.DiscardPositionIcon(lanesIcons["iconLane3B"])
        if vASHelper.debug then d("vASHelper.hideLanes() 3B") end
    end

    if lanesIcons["iconLane4A"]~= nil then
        OSI.DiscardPositionIcon(lanesIcons["iconLane4A"])
    end
    if lanesIcons["iconLane4B"]~= nil then

        OSI.DiscardPositionIcon(lanesIcons["iconLane4B"])
    end
    if lanesIcons["iconLane5A"]~= nil then
        OSI.DiscardPositionIcon(lanesIcons["iconLane5A"])
    end
    if lanesIcons["iconLane5B"]~= nil then

        OSI.DiscardPositionIcon(lanesIcons["iconLane5B"])
    end
    if lanesIcons["iconLane6A"]~= nil then
        OSI.DiscardPositionIcon(lanesIcons["iconLane6A"])
    end
    if lanesIcons["iconLane6B"]~= nil then
        OSI.DiscardPositionIcon(lanesIcons["iconLane6B"])
    end
    if lanesIcons["iconLane7A"]~= nil then
        OSI.DiscardPositionIcon(lanesIcons["iconLane7A"])
    end
    if lanesIcons["iconLane7B"]~= nil then
        OSI.DiscardPositionIcon(lanesIcons["iconLane7B"])
    end
    if lanesIcons["iconLane8A"]~= nil then
        OSI.DiscardPositionIcon(lanesIcons["iconLane8A"])
    end
    if lanesIcons["iconLane8B"]~= nil then
        OSI.DiscardPositionIcon(lanesIcons["iconLane8B"])
    end


    lanesIcons["iconLane1A"] = nil
    lanesIcons["iconLane1B"] = nil
    lanesIcons["iconLane2A"] = nil
    lanesIcons["iconLane2B"] = nil
    lanesIcons["iconLane3A"] = nil
    lanesIcons["iconLane3B"] = nil
    lanesIcons["iconLane4A"] = nil
    lanesIcons["iconLane4B"] = nil
    lanesIcons["iconLane5A"] = nil
    lanesIcons["iconLane5B"] = nil
    lanesIcons["iconLane6A"] = nil
    lanesIcons["iconLane6B"] = nil
    lanesIcons["iconLane7A"] = nil
    lanesIcons["iconLane7B"] = nil
    lanesIcons["iconLane8A"] = nil
    lanesIcons["iconLane8B"] = nil

    lanesIconsLoaded = false

end






local healIconsLoaded = false
local healIcons = {}

function vASHelper.showHeals()


    if (healIconsLoaded) then
        return
    end
    if vASHelper.savedVars.displayHealerZone==false then
        return
    end

    if vASHelper.debug then d("vASHelper.showHeals()") end

    local iconHeight = 61450-75 -- put it in the ground
    local iconSize = vASHelper.savedVars.iconSize/2

    local centre1y = 98255
    local centre3y = 101646+99


    local reflectionX = 98783

    local heal_distance = 2800
    local heal_c_exit_x= 98146+2800
    local heal_c_entrance_x= reflectionX+(reflectionX-heal_c_exit_x)

    local heal_c_y = (centre3y-centre1y)/2+centre1y



    local heal_distanceA1 = 600
    local heal_distanceB1 = math.sqrt(heal_distance*heal_distance - heal_distanceA1*heal_distanceA1)

    local heal_distanceA2 = heal_distance / math.sqrt(2)
    local heal_distanceB2 = heal_distance / math.sqrt(2)

    local heal_distanceA3 = 1000
    local heal_distanceB3 = math.sqrt(heal_distance*heal_distance - heal_distanceA3*heal_distanceA3)

    local heal_distanceA4 = 1300
    local heal_distanceB4 = math.sqrt(heal_distance*heal_distance - heal_distanceA4*heal_distanceA4)

    local heal_distanceA5 = 1600
    local heal_distanceB5 = math.sqrt(heal_distance*heal_distance - heal_distanceA5*heal_distanceA5)

    local icon_h1_1 = OSI.CreatePositionIcon(heal_c_exit_x-heal_distance,iconHeight,heal_c_y, "odysupporticons/icons/squares/squaretwo_green.dds",iconSize, {1, 1, 1})
    local icon_h1_2 = OSI.CreatePositionIcon(heal_c_exit_x-heal_distanceB1,iconHeight,heal_c_y-heal_distanceA1, "odysupporticons/icons/squares/squaretwo_green.dds",iconSize, {1, 1, 1})
    local icon_h1_3 = OSI.CreatePositionIcon(heal_c_exit_x-heal_distanceB1,iconHeight,heal_c_y+heal_distanceA1, "odysupporticons/icons/squares/squaretwo_green.dds",iconSize, {1, 1, 1})
    local icon_h1_4 = OSI.CreatePositionIcon(heal_c_exit_x-heal_distanceA2,iconHeight,heal_c_y-heal_distanceB2, "odysupporticons/icons/squares/squaretwo_green.dds",iconSize, {1, 1, 1})
    local icon_h1_5 = OSI.CreatePositionIcon(heal_c_exit_x-heal_distanceA1,iconHeight,heal_c_y-heal_distanceB1, "odysupporticons/icons/squares/squaretwo_green.dds",iconSize, {1, 1, 1})
    local icon_h1_6 = OSI.CreatePositionIcon(heal_c_exit_x-heal_distanceA3,iconHeight,heal_c_y-heal_distanceB3, "odysupporticons/icons/squares/squaretwo_green.dds",iconSize, {1, 1, 1})
    local icon_h1_7 = OSI.CreatePositionIcon(heal_c_exit_x-heal_distanceA4,iconHeight,heal_c_y-heal_distanceB4, "odysupporticons/icons/squares/squaretwo_green.dds",iconSize, {1, 1, 1})
    local icon_h1_8 = OSI.CreatePositionIcon(heal_c_exit_x-heal_distanceA5,iconHeight,heal_c_y-heal_distanceB5, "odysupporticons/icons/squares/squaretwo_green.dds",iconSize, {1, 1, 1})

    local icon_h2_1 = OSI.CreatePositionIcon(heal_c_entrance_x+heal_distance,iconHeight,heal_c_y, "odysupporticons/icons/squares/squaretwo_green.dds",iconSize, {1, 1, 1})
    local icon_h2_2 = OSI.CreatePositionIcon(heal_c_entrance_x+heal_distanceB1,iconHeight,heal_c_y-heal_distanceA1, "odysupporticons/icons/squares/squaretwo_green.dds",iconSize, {1, 1, 1})
    local icon_h2_3 = OSI.CreatePositionIcon(heal_c_entrance_x+heal_distanceB1,iconHeight,heal_c_y+heal_distanceA1, "odysupporticons/icons/squares/squaretwo_green.dds",iconSize, {1, 1, 1})
    local icon_h2_4 = OSI.CreatePositionIcon(heal_c_entrance_x+heal_distanceA2,iconHeight,heal_c_y-heal_distanceB2, "odysupporticons/icons/squares/squaretwo_green.dds",iconSize, {1, 1, 1})
    local icon_h2_5 = OSI.CreatePositionIcon(heal_c_entrance_x+heal_distanceA1,iconHeight,heal_c_y-heal_distanceB1, "odysupporticons/icons/squares/squaretwo_green.dds",iconSize, {1, 1, 1})
    local icon_h2_6 = OSI.CreatePositionIcon(heal_c_entrance_x+heal_distanceA3,iconHeight,heal_c_y-heal_distanceB3, "odysupporticons/icons/squares/squaretwo_green.dds",iconSize, {1, 1, 1})
    local icon_h2_7 = OSI.CreatePositionIcon(heal_c_entrance_x+heal_distanceA4,iconHeight,heal_c_y-heal_distanceB4, "odysupporticons/icons/squares/squaretwo_green.dds",iconSize, {1, 1, 1})
    local icon_h2_8 = OSI.CreatePositionIcon(heal_c_entrance_x+heal_distanceA5,iconHeight,heal_c_y-heal_distanceB5, "odysupporticons/icons/squares/squaretwo_green.dds",iconSize, {1, 1, 1})

    healIcons["icon_h1_1"] = icon_h1_1
    healIcons["icon_h1_2"] = icon_h1_2
    healIcons["icon_h1_3"] = icon_h1_3
    healIcons["icon_h1_4"] = icon_h1_4
    healIcons["icon_h1_5"] = icon_h1_5
    healIcons["icon_h1_6"] = icon_h1_6
    healIcons["icon_h1_7"] = icon_h1_7
    healIcons["icon_h1_8"] = icon_h1_8

    healIcons["icon_h2_1"] = icon_h2_1
    healIcons["icon_h2_2"] = icon_h2_2
    healIcons["icon_h2_3"] = icon_h2_3
    healIcons["icon_h2_4"] = icon_h2_4
    healIcons["icon_h2_5"] = icon_h2_5
    healIcons["icon_h2_6"] = icon_h2_6
    healIcons["icon_h2_7"] = icon_h2_7
    healIcons["icon_h2_8"] = icon_h2_8

    healIconsLoaded = true
end



function vASHelper.hideHeals()


    if not (healIconsLoaded) then
        return
    end

    if vASHelper.debug then d("vASHelper.hideHeals()") end

    if healIcons["icon_h1_1"]~=nil then
        OSI.DiscardPositionIcon(healIcons["icon_h1_1"])
    end
    if healIcons["icon_h1_2"]~=nil then
        OSI.DiscardPositionIcon(healIcons["icon_h1_2"])
    end
    if healIcons["icon_h1_3"]~=nil then
        OSI.DiscardPositionIcon(healIcons["icon_h1_3"])
    end
    if healIcons["icon_h1_4"]~=nil then
        OSI.DiscardPositionIcon(healIcons["icon_h1_4"])
    end
    if healIcons["icon_h1_5"]~=nil then
        OSI.DiscardPositionIcon(healIcons["icon_h1_5"])
    end
    if healIcons["icon_h1_6"]~=nil then
        OSI.DiscardPositionIcon(healIcons["icon_h1_6"])
    end
    if healIcons["icon_h1_7"]~=nil then
        OSI.DiscardPositionIcon(healIcons["icon_h1_7"])
    end
    if healIcons["icon_h1_8"]~=nil then
        OSI.DiscardPositionIcon(healIcons["icon_h1_8"])
    end

    if healIcons["icon_h2_1"]~=nil then
        OSI.DiscardPositionIcon(healIcons["icon_h2_1"])
    end
    if healIcons["icon_h2_2"]~=nil then
        OSI.DiscardPositionIcon(healIcons["icon_h2_2"])
    end
    if healIcons["icon_h2_3"]~=nil then
        OSI.DiscardPositionIcon(healIcons["icon_h2_3"])
    end
    if healIcons["icon_h2_4"]~=nil then
        OSI.DiscardPositionIcon(healIcons["icon_h2_4"])
    end
    if healIcons["icon_h2_5"]~=nil then
        OSI.DiscardPositionIcon(healIcons["icon_h2_5"])
    end
    if healIcons["icon_h2_7"]~=nil then
        OSI.DiscardPositionIcon(healIcons["icon_h2_6"])
    end
    if healIcons["icon_h2_7"]~=nil then
        OSI.DiscardPositionIcon(healIcons["icon_h2_7"])
    end
    if healIcons["icon_h2_8"]~=nil then
        OSI.DiscardPositionIcon(healIcons["icon_h2_8"])
    end


    healIcons["icon_h1_1"] = nil
    healIcons["icon_h1_2"] = nil
    healIcons["icon_h1_3"] = nil
    healIcons["icon_h1_4"] = nil
    healIcons["icon_h1_5"] = nil
    healIcons["icon_h1_6"] = nil
    healIcons["icon_h1_7"] = nil
    healIcons["icon_h1_8"] = nil

    healIcons["icon_h2_1"] = nil
    healIcons["icon_h2_2"] = nil
    healIcons["icon_h2_3"] = nil
    healIcons["icon_h2_4"] = nil
    healIcons["icon_h2_5"] = nil
    healIcons["icon_h2_6"] = nil
    healIcons["icon_h2_7"] = nil
    healIcons["icon_h2_8"] = nil

    healIconsLoaded = false

end






local mtIconsLoaded = false
local mtIcons = {}

function vASHelper.showMTIcons()


    if vASHelper.savedVars.displayMtLocation==false then
        return
    end

    if (mtIconsLoaded) then
        --d("Icon already loaded")
        return
    end
    if vASHelper.debug then d("vASHelper.showMTIcons()") end

    local iconHeight = 61450-75 -- put it in the ground

    local icon_mt_1 = OSI.CreatePositionIcon(98785,iconHeight,102335, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_mt_2 = OSI.CreatePositionIcon(98807,iconHeight,102634, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_mt_3 = OSI.CreatePositionIcon(98303,iconHeight,102335, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_mt_4 = OSI.CreatePositionIcon(99454,iconHeight,102335, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})


    mtIcons["icon_mt_1"] = icon_mt_1
    mtIcons["icon_mt_2"] = icon_mt_2
    mtIcons["icon_mt_3"] = icon_mt_3
    mtIcons["icon_mt_4"] = icon_mt_4

    mtIconsLoaded = true

end


function vASHelper.hideMTIcons()


    if not (mtIconsLoaded) then
        return
    end

    if vASHelper.debug then d("vASHelper.hideMTIcons()") end

    if mtIcons["icon_mt_1"]~=nil then
        OSI.DiscardPositionIcon(mtIcons["icon_mt_1"])
    end
    if mtIcons["icon_mt_2"]~=nil then
        OSI.DiscardPositionIcon(mtIcons["icon_mt_2"])
    end
    if mtIcons["icon_mt_3"]~=nil then
        OSI.DiscardPositionIcon(mtIcons["icon_mt_3"])
    end
    if mtIcons["icon_mt_4"]~=nil then
        OSI.DiscardPositionIcon(mtIcons["icon_mt_4"])
    end

    mtIcons["icon_mt_1"] = nil
    mtIcons["icon_mt_2"] = nil
    mtIcons["icon_mt_3"] = nil
    mtIcons["icon_mt_4"] = nil
    mtIconsLoaded = false

end


local ohmsIconsLoaded = false
local icons = {}

function vASHelper.showOlmsJumpBorders()
    if vASHelper.savedVars.displayOlhmsJumpZone==false then
        return
    end

    if (ohmsIconsLoaded) then
        --d("Icon already loaded")
        return
    end

    if vASHelper.debug then d("vASHelper.showOlmsJumpBorders()") end


    local iconHeight = 61450-75 -- put it in the ground
    local iconSize = vASHelper.savedVars.iconSize/2

    local arenaCenterX = 98781

    local center1x = 98469
    local centre1y = 98255

    local center2x = center1x + (arenaCenterX-center1x)*2
    local centre2y = centre1y

    local center3x = center1x
    local centre3y = 101646+99

    local center4x = center2x
    local centre4y = centre3y



    local distanceC = 2000

    local distanceA1 = 800
    local distanceB1 = math.sqrt(distanceC*distanceC - distanceA1*distanceA1)

    local distanceA2 = distanceC / math.sqrt(2)
    local distanceB2 = distanceC / math.sqrt(2)

    local distanceA3 = (centre3y-centre1y)/2
    local distanceB3 = math.sqrt(distanceC*distanceC - distanceA3*distanceA3)


    local icon_c1_1 = OSI.CreatePositionIcon(center1x,iconHeight,centre1y+distanceC, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c1_2 = OSI.CreatePositionIcon(center1x,iconHeight,centre1y-distanceC, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c1_3 = OSI.CreatePositionIcon(center1x-distanceB1,iconHeight,centre1y+distanceA1, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c1_4 = OSI.CreatePositionIcon(center1x-distanceB1,iconHeight,centre1y-distanceA1, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c1_5 = OSI.CreatePositionIcon(center1x-distanceB2,iconHeight,centre1y+distanceA2, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c1_6 = OSI.CreatePositionIcon(center1x-distanceB2,iconHeight,centre1y-distanceA2, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c1_7 = OSI.CreatePositionIcon(center1x-distanceA1,iconHeight,centre1y+distanceB1, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c1_8 = OSI.CreatePositionIcon(center1x-distanceA1,iconHeight,centre1y-distanceB1, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})


    local icon_c2_1 = OSI.CreatePositionIcon(center2x,iconHeight,centre2y+distanceC, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c2_2 = OSI.CreatePositionIcon(center2x,iconHeight,centre2y-distanceC, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c2_3 = OSI.CreatePositionIcon(center2x+distanceB1,iconHeight,centre2y+distanceA1, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c2_4 = OSI.CreatePositionIcon(center2x+distanceB1,iconHeight,centre2y-distanceA1, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c2_5 = OSI.CreatePositionIcon(center2x+distanceB2,iconHeight,centre2y+distanceA2, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c2_6 = OSI.CreatePositionIcon(center2x+distanceB2,iconHeight,centre2y-distanceA2, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c2_7 = OSI.CreatePositionIcon(center2x+distanceA1,iconHeight,centre2y+distanceB1, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c2_8 = OSI.CreatePositionIcon(center2x+distanceA1,iconHeight,centre2y-distanceB1, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})


    local icon_c3_1 = OSI.CreatePositionIcon(center3x,iconHeight,centre3y+distanceC, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c3_2 = OSI.CreatePositionIcon(center3x,iconHeight,centre3y-distanceC, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c3_3 = OSI.CreatePositionIcon(center3x-distanceB1,iconHeight,centre3y+distanceA1, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c3_4 = OSI.CreatePositionIcon(center3x-distanceB1,iconHeight,centre3y-distanceA1, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c3_5 = OSI.CreatePositionIcon(center3x-distanceB2,iconHeight,centre3y+distanceA2, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c3_6 = OSI.CreatePositionIcon(center3x-distanceB2,iconHeight,centre3y-distanceA2, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c3_7 = OSI.CreatePositionIcon(center3x-distanceA1,iconHeight,centre3y+distanceB1, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c3_8 = OSI.CreatePositionIcon(center3x-distanceA1,iconHeight,centre3y-distanceB1, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})


    local icon_c4_1 = OSI.CreatePositionIcon(center4x,iconHeight,centre4y+distanceC, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c4_2 = OSI.CreatePositionIcon(center4x,iconHeight,centre4y-distanceC, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c4_3 = OSI.CreatePositionIcon(center4x+distanceB1,iconHeight,centre4y+distanceA1, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c4_4 = OSI.CreatePositionIcon(center4x+distanceB1,iconHeight,centre4y-distanceA1, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c4_5 = OSI.CreatePositionIcon(center4x+distanceB2,iconHeight,centre4y+distanceA2, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c4_6 = OSI.CreatePositionIcon(center4x+distanceB2,iconHeight,centre4y-distanceA2, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c4_7 = OSI.CreatePositionIcon(center4x+distanceA1,iconHeight,centre4y+distanceB1, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c4_8 = OSI.CreatePositionIcon(center4x+distanceA1,iconHeight,centre4y-distanceB1, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})

    local icon_c13_1 = OSI.CreatePositionIcon(center1x-distanceB3,iconHeight,centre1y+distanceA3, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})
    local icon_c24_1 = OSI.CreatePositionIcon(center2x+distanceB3,iconHeight,centre2y+distanceA3, "odysupporticons/icons/squares/squaretwo_pink.dds",iconSize, {1, 1, 1})



    icons["icon_c1_1"] = icon_c1_1
    icons["icon_c1_2"] = icon_c1_2
    icons["icon_c1_3"] = icon_c1_3
    icons["icon_c1_4"] = icon_c1_4
    icons["icon_c1_5"] = icon_c1_5
    icons["icon_c1_6"] = icon_c1_6
    icons["icon_c1_7"] = icon_c1_7
    icons["icon_c1_8"] = icon_c1_8

    icons["icon_c2_1"] = icon_c2_1
    icons["icon_c2_2"] = icon_c2_2
    icons["icon_c2_3"] = icon_c2_3
    icons["icon_c2_4"] = icon_c2_4
    icons["icon_c2_5"] = icon_c2_5
    icons["icon_c2_6"] = icon_c2_6
    icons["icon_c2_7"] = icon_c2_7
    icons["icon_c2_8"] = icon_c2_8

    icons["icon_c3_1"] = icon_c3_1
    icons["icon_c3_2"] = icon_c3_2
    icons["icon_c3_3"] = icon_c3_3
    icons["icon_c3_4"] = icon_c3_4
    icons["icon_c3_5"] = icon_c3_5
    icons["icon_c3_6"] = icon_c3_6
    icons["icon_c3_7"] = icon_c3_7
    icons["icon_c3_8"] = icon_c3_8

    icons["icon_c4_1"] = icon_c4_1
    icons["icon_c4_2"] = icon_c4_2
    icons["icon_c4_3"] = icon_c4_3
    icons["icon_c4_4"] = icon_c4_4
    icons["icon_c4_5"] = icon_c4_5
    icons["icon_c4_6"] = icon_c4_6
    icons["icon_c4_7"] = icon_c4_7
    icons["icon_c4_8"] = icon_c4_8

    icons["icon_c13_1"] = icon_c13_1
    icons["icon_c24_1"] = icon_c24_1

    ohmsIconsLoaded = true

end

function vASHelper.hideOlmsJumpBorders()


    if not (ohmsIconsLoaded) then
        --d("Icon not loaded")
        return
    end

    if vASHelper.debug then d("vASHelper.hideOlmsJumpBorders()") end

    if icons["icon_c1_1"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c1_1"])
    end
    if icons["icon_c1_2"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c1_2"])
    end
    if icons["icon_c1_3"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c1_3"])
    end
    if icons["icon_c1_4"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c1_4"])
    end
    if icons["icon_c1_5"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c1_5"])
    end
    if icons["icon_c1_6"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c1_6"])
    end
    if icons["icon_c1_7"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c1_7"])
    end
    if icons["icon_c1_8"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c1_8"])
    end
    if icons["icon_c2_1"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c2_1"])
    end
    if icons["icon_c2_2"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c2_2"])
    end
    if icons["icon_c2_3"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c2_3"])
    end
    if icons["icon_c2_4"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c2_4"])
    end
    if icons["icon_c2_5"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c2_5"])
    end
    if icons["icon_c2_6"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c2_6"])
    end
    if icons["icon_c2_7"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c2_7"])
    end
    if icons["icon_c2_8"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c2_8"])
    end
    if icons["icon_c3_1"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c3_1"])
    end


    if icons["icon_c3_2"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c3_2"])
    end
    if icons["icon_c3_3"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c3_3"])
    end
    if icons["icon_c3_4"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c3_4"])
    end
    if icons["icon_c3_5"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c3_5"])
    end
    if icons["icon_c3_6"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c3_6"])
    end
    if icons["icon_c3_7"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c3_7"])
    end
    if icons["icon_c3_8"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c3_8"])
    end
    if icons["icon_c4_1"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c4_1"])
    end
    if icons["icon_c4_2"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c4_2"])
    end
    if icons["icon_c4_3"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c4_3"])
    end
    if icons["icon_c4_4"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c4_4"])
    end
    if icons["icon_c4_5"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c4_5"])
    end
    if icons["icon_c4_6"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c4_6"])
    end
    if icons["icon_c4_7"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c4_7"])
    end
    if icons["icon_c4_8"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c4_8"])
    end
    if icons["icon_c13_1"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c13_1"])
    end
    if icons["icon_c24_1"]~=nil then
        OSI.DiscardPositionIcon(icons["icon_c24_1"])
    end

    icons["icon_c1_1"] = nil
    icons["icon_c1_2"] = nil
    icons["icon_c1_3"] = nil
    icons["icon_c1_4"] = nil
    icons["icon_c1_5"] = nil
    icons["icon_c1_6"] = nil
    icons["icon_c1_7"] = nil
    icons["icon_c1_8"] = nil
    icons["icon_c2_1"] = nil
    icons["icon_c2_2"] = nil
    icons["icon_c2_3"] = nil
    icons["icon_c2_4"] = nil
    icons["icon_c2_5"] = nil
    icons["icon_c2_6"] = nil
    icons["icon_c2_7"] = nil
    icons["icon_c2_8"] = nil
    icons["icon_c3_1"] = nil
    icons["icon_c3_2"] = nil
    icons["icon_c3_3"] = nil
    icons["icon_c3_4"] = nil
    icons["icon_c3_5"] = nil
    icons["icon_c3_6"] = nil
    icons["icon_c3_7"] = nil
    icons["icon_c3_8"] = nil
    icons["icon_c4_1"] = nil
    icons["icon_c4_2"] = nil
    icons["icon_c4_3"] = nil
    icons["icon_c4_4"] = nil
    icons["icon_c4_5"] = nil
    icons["icon_c4_6"] = nil
    icons["icon_c4_7"] = nil
    icons["icon_c4_8"] = nil
    icons["icon_c13_1"] = nil
    icons["icon_c24_1"] = nil

    ohmsIconsLoaded = false
end





function vASHelper.combatEventPurgeNeeded(eventCode,result,isError,ability5Name,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
    if vASHelper.savedVars.selfishPurge then
        local playerWorldZone, playerWorldX, playerWorldY, playerWorldZ = GetUnitWorldPosition("player")
        --local zid = GetCurrentMapZoneIndex()
        if playerWorldZone == 1000 then
	    --if zid == 608 or zid == 590 then -- vAS downstairs and upstairs
            vASHelperFrame:SetHidden(false)
        end
    end
end

function vASHelper.combatEventPurgeNotNeeded(eventCode,result,isError,ability5Name,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
    vASHelperFrame:SetHidden(true)
end

function vASHelper.Init(event, addon)
	if addon ~= vASHelper.name then return end

    vASHelper.units = {}
    vASHelper.unitsTag = {}

    LibUnits2.RefreshUnits()

	vASHelper.inCombat = IsUnitInCombat("player")


	EM:UnregisterForEvent(vASHelper.name.."Load", EVENT_ADD_ON_LOADED)

	vASHelper.savedVars = ZO_SavedVars:New(vASHelper.name.."SavedVars", vASHelper.varVersion, nil, vASHelper.defaults)


	vASHelper.setupMenu()

    EM:RegisterForEvent(vASHelper.name .. "_EventBossChanged", EVENT_BOSSES_CHANGED, vASHelper.BossesChanged)

    EM:RegisterForEvent(vASHelper.name.."_EventCombatEvent99131Purge", EVENT_COMBAT_EVENT, vASHelper.combatEventPurgeNeeded)
    EM:AddFilterForEvent(vASHelper.name.."_EventCombatEvent99131Purge", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    EM:AddFilterForEvent(vASHelper.name.."_EventCombatEvent99131Purge", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 99131) -- Bleeding - vAS Felm Jump
    EM:AddFilterForEvent(vASHelper.name.."_EventCombatEvent99131Purge", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)

    EM:RegisterForEvent(vASHelper.name.."_EventCombatEvent101101Purge", EVENT_COMBAT_EVENT, vASHelper.combatEventPurgeNeeded)
    EM:AddFilterForEvent(vASHelper.name.."_EventCombatEvent101101Purge", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    EM:AddFilterForEvent(vASHelper.name.."_EventCombatEvent101101Purge", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 101101) -- TRIAL BY FIRE - vAS Execute fire
    EM:AddFilterForEvent(vASHelper.name.."_EventCombatEvent101101Purge", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)


    EM:RegisterForEvent(vASHelper.name.."_EventCombatEvent99131NoPurge", EVENT_COMBAT_EVENT, vASHelper.combatEventPurgeNotNeeded)
    EM:AddFilterForEvent(vASHelper.name.."_EventCombatEvent99131NoPurge", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    EM:AddFilterForEvent(vASHelper.name.."_EventCombatEvent99131NoPurge", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 99131) -- Bleeding - vAS Felm Jump
    EM:AddFilterForEvent(vASHelper.name.."_EventCombatEvent99131NoPurge", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)

    EM:RegisterForEvent(vASHelper.name.."_EventCombatEvent101101NoPurge", EVENT_COMBAT_EVENT, vASHelper.combatEventPurgeNotNeeded)
    EM:AddFilterForEvent(vASHelper.name.."_EventCombatEvent101101NoPurge", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    EM:AddFilterForEvent(vASHelper.name.."_EventCombatEvent101101NoPurge", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 101101) -- TRIAL BY FIRE - vAS Execute fire
    EM:AddFilterForEvent(vASHelper.name.."_EventCombatEvent101101NoPurge", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)

    SLASH_COMMANDS["/vashelperhide"] = vASHelper.hideAllIcons

end

EM:RegisterForEvent(vASHelper.name.."Load", EVENT_ADD_ON_LOADED, vASHelper.Init)

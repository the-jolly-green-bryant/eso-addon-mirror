FineClubIcons = FineClubIcons or {}

local function GetFalgravnIconsSize()
    return FineClubIcons.savedVariables.kynesaegis.falgravnIconsSize
end

local icons = {}

local iconPositions = {
    -- 2nd Floor HM-Positions by Thelinor, Alcadeios, and Floliroy
    ["Falgravn2ndFloor1"] = {x = 24948, y = 14569, z = 10579, texture = "odysupporticons/icons/squares/squaretwo_blue_one.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, --D1
    ["Falgravn2ndFloor2"] = {x = 25607, y = 14569, z = 10356, texture = "odysupporticons/icons/squares/squaretwo_blue_two.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, --D2
    ["Falgravn2ndFloor3"] = {x = 25578, y = 14569, z = 9655, texture = "odysupporticons/icons/squares/squaretwo_blue_three.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, --D3
    ["Falgravn2ndFloor4"] = {x = 24855, y = 14569, z = 9382, texture = "odysupporticons/icons/squares/squaretwo_blue_four.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, --D4
    ["Falgravn2ndFloor5"] = {x = 24505, y = 14569, z = 10262, texture = "odysupporticons/icons/squares/squaretwo_yellow.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, --D5
    ["Falgravn2ndFloorHR"] = {x = 24310, y = 14569, z = 10567, texture = "odysupporticons/icons/squares/squaretwo_green.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, --Heal Right

    -- 1st Floor Line Positions by Thelinor, Alcadeios, and Floliroy
    ["FalgravnL11"] = {x = 23241, y = 21700, z = 11704, texture = "odysupporticons/icons/squares/squaretwo_blue_one.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, --27m
    ["FalgravnL12"] = {x = 23660, y = 21700, z = 11287, texture = "odysupporticons/icons/squares/squaretwo_blue_two.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, --19m
    ["FalgravnL13"] = {x = 24084, y = 21700, z = 10889, texture = "odysupporticons/icons/squares/squaretwo_blue_three.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, --15m
    ["FalgravnL14"] = {x = 24574, y = 21700, z = 10380, texture = "odysupporticons/icons/squares/squaretwo_blue_four.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, 

    ["FalgravnL21"] = {x = 23333, y = 21700, z = 8285, texture = "odysupporticons/icons/squares/squaretwo_blue_one.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, --27m
    ["FalgravnL22"] = {x = 23767, y = 21700, z = 8711, texture = "odysupporticons/icons/squares/squaretwo_blue_two.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, --19m
    ["FalgravnL23"] = {x = 24229, y = 21700, z = 9198, texture = "odysupporticons/icons/squares/squaretwo_blue_three.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, --14m
    ["FalgravnL24"] = {x = 24640, y = 21700, z = 9621, texture = "odysupporticons/icons/squares/squaretwo_blue_four.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, 

    ["FalgravnL31"] = {x = 26725, y = 21700, z = 8349, texture = "odysupporticons/icons/squares/squaretwo_blue_one.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, --27m
    ["FalgravnL32"] = {x = 26266, y = 21700, z = 8771, texture = "odysupporticons/icons/squares/squaretwo_blue_two.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, --19m
    ["FalgravnL33"] = {x = 25840, y = 21700, z = 9188, texture = "odysupporticons/icons/squares/squaretwo_blue_three.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, --15m
    ["FalgravnL34"] = {x = 25394, y = 21700, z = 9611, texture = "odysupporticons/icons/squares/squaretwo_blue_four.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, 

    ["FalgravnL41"] = {x = 26618, y = 21700, z = 11711, texture = "odysupporticons/icons/squares/squaretwo_blue_one.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, --27m
    ["FalgravnL42"] = {x = 26197, y = 21700, z = 11298, texture = "odysupporticons/icons/squares/squaretwo_blue_two.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, --19m
    ["FalgravnL43"] = {x = 25779, y = 21700, z = 10854, texture = "odysupporticons/icons/squares/squaretwo_blue_three.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, --15m
    ["FalgravnL44"] = {x = 25346, y = 21700, z = 10410, texture = "odysupporticons/icons/squares/squaretwo_blue_four.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, 

    -- 1st Floor Stack Positions by Thelinor and Alcadeios
    ["Falgravn1stFloorL"] = {x = 25227 , y = 21700, z = 9801, texture = "odysupporticons/icons/squares/squaretwo_orange.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, -- Left Slayer Stack
    ["Falgravn1stFloorR"] = {x = 24749, y = 21700, z = 9789, texture = "odysupporticons/icons/squares/squaretwo_green.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, -- Right Slayer Stack
    ["Falgravn1stFloorT"] = {x = 24960, y = 21700, z = 10422, texture = "odysupporticons/icons/squares/square_red_MT.dds", size = GetFalgravnIconsSize, color = {1, 1, 1}}, -- MT position
}

function FineClubIcons.WorldIconsEnabled()
    return OSI ~= nil and OSI.CreatePositionIcon ~= nil
end

function FineClubIcons.EnableIcon(name)
    if (not FineClubIcons.WorldIconsEnabled()) then
        return
    end

    if (icons[name]) then
        FineClubIcons.debug("|cFF0000Icon already enabled " .. name .. "|r")
        return
    end

    local iconData = iconPositions[name]
    if (not iconData) then
        FineClubIcons.debug("|cFF0000Invalid icon name " .. name .. "|r")
        return
    end

    local icon = OSI.CreatePositionIcon(iconData.x, iconData.y, iconData.z, iconData.texture, iconData.size(), iconData.color)
    icons[name] = icon
end

function FineClubIcons.DisableIcon(name)
    if (not FineClubIcons.WorldIconsEnabled()) then
        return
    end

    if (not icons[name]) then
        return
    end

    OSI.DiscardPositionIcon(icons[name])
    icons[name] = nil
end

BSCHTKAHelper = BSCHTKAHelper or {}
local BSCHTKA = BSCHTKAHelper

BSCHTKA.Name = "BSCs-HowToKynesAegis"
BSCHTKA.Version = 1
BSCHTKA.SavedVar = "BSCHTKASaved"

BSCHTKA.NameSpaced = "BloodStainChild666's How To How To Kynes Aegis"
BSCHTKA.Author = "@BloodStainChild666"
BSCHTKA.NameMenu = "BSCs-HowToKynesAegis"
BSCHTKA.VersionDisplay = "2.1.3"

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local ico_r = "odysupporticons/icons/squares/square_red.dds"		-- 
local ico_y = "odysupporticons/icons/squares/square_yellow.dds"		-- 
local ico_g = "odysupporticons/icons/squares/square_green.dds"		-- 

local ico_p = "odysupporticons/icons/squares/square_pink.dds"		-- 
local ico_o = "odysupporticons/icons/squares/square_orange.dds"		-- 
local ico_b = "odysupporticons/icons/squares/square_blue.dds"		-- 

local TORTURER_ODIS_LIST = { }
local ICON_INFO_LIST = { }
-- Top Side (Right)
table.insert(TORTURER_ODIS_LIST, { x = 25069, y = 7722, z = 7114,  name = "Brekalda",	texture = ico_r, size = 200, color = { 1, 1, 1 } }) -- [OSI] x=25069 y=7722 z=7114 zone=1196
table.insert(TORTURER_ODIS_LIST, { x = 27000, y = 7711, z = 8062,  name = "Thjorlak", 	texture = ico_r, size = 200, color = { 1, 1, 1 } }) -- [OSI] x=27000 y=7711 z=8062 zone=1196
table.insert(TORTURER_ODIS_LIST, { x = 27796, y = 7710, z = 10040, name = "Aevar", 		texture = ico_r, size = 200, color = { 1, 1, 1 } }) -- [OSI] x=27796 y=7710 z=10040 zone=1196
table.insert(TORTURER_ODIS_LIST, { x = 26966, y = 7715, z = 12008, name = "Triveta", 	texture = ico_r, size = 200, color = { 1, 1, 1 } }) -- [OSI] x=26966 y=7715 z=12008 zone=1196
-- Down Side (Left)
table.insert(TORTURER_ODIS_LIST, { x = 24944, y = 7703, z = 12970, name = "Skormgondar", 	texture = ico_r, size = 200, color = { 1, 1, 1 } }) -- [OSI] x=24944 y=7703 z=12970 zone=1196 
table.insert(TORTURER_ODIS_LIST, { x = 22966, y = 7718, z = 12034, name = "Irthrig",		texture = ico_r, size = 200, color = { 1, 1, 1 } }) -- [OSI] x=22966 y=7718 z=12034 zone=1196
table.insert(TORTURER_ODIS_LIST, { x = 22300, y = 7742, z = 10000, name = "Ama",			texture = ico_r, size = 200, color = { 1, 1, 1 } }) -- [OSI] x=22300 y=7742 z=10000 zone=1196
table.insert(TORTURER_ODIS_LIST, { x = 23133, y = 7733, z = 8085,  name = "Sislea",			texture = ico_r, size = 200, color = { 1, 1, 1 } }) -- [OSI] x=23133 y=7733 z=8085 zone=1196

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local ico_g_1 = "odysupporticons/icons/squares/squaretwo_green_one.dds"		-- 
local ico_g_2 = "odysupporticons/icons/squares/squaretwo_green_two.dds"		-- 
local ico_g_3 = "odysupporticons/icons/squares/squaretwo_green_three.dds"	-- 
local ico_g_4 = "odysupporticons/icons/squares/squaretwo_green_four.dds"	-- 
local ico_g_5 = "odysupporticons/icons/squares/squaretwo_green_five.dds"	-- 

local ico_r_1 = "odysupporticons/icons/squares/squaretwo_red_one.dds"		-- 
local ico_r_2 = "odysupporticons/icons/squares/squaretwo_red_two.dds"		-- 
local ico_r_3 = "odysupporticons/icons/squares/squaretwo_red_three.dds"		-- 
local ico_r_4 = "odysupporticons/icons/squares/squaretwo_red_four.dds"		-- 
local ico_r_5 = "odysupporticons/icons/squares/squaretwo_red_five.dds"		-- 

local POSITION_ODIS_LIST = { }
local ICON_POSITION = { }
-- Links NW
table.insert(POSITION_ODIS_LIST, { x = 23311, y = 21700, z = 8270,  name = "LN1",	texture = ico_r_1, size = 100, color = { 1, 1, 1 } }) -- Wall
table.insert(POSITION_ODIS_LIST, { x = 23647, y = 21672, z = 8594,  name = "LN2",	texture = ico_r_2, size = 100, color = { 1, 1, 1 } })
table.insert(POSITION_ODIS_LIST, { x = 23931, y = 21670, z = 8901,  name = "LN3",	texture = ico_r_3, size = 100, color = { 1, 1, 1 } })
table.insert(POSITION_ODIS_LIST, { x = 24254, y = 21670, z = 9200,  name = "LN4",	texture = ico_r_4, size = 100, color = { 1, 1, 1 } })
table.insert(POSITION_ODIS_LIST, { x = 24546, y = 21670, z = 9530,  name = "LN5",	texture = ico_r_5, size = 100, color = { 1, 1, 1 } }) -- Boss
-- Links SW
table.insert(POSITION_ODIS_LIST, { x = 23165, y = 21700, z = 11754,  name = "LS1",	texture = ico_r_1, size = 100, color = { 1, 1, 1 } }) -- Wall
table.insert(POSITION_ODIS_LIST, { x = 23521, y = 21672, z = 11378,  name = "LS2",	texture = ico_r_2, size = 100, color = { 1, 1, 1 } })
table.insert(POSITION_ODIS_LIST, { x = 23832, y = 21670, z = 11079,  name = "LS3",	texture = ico_r_3, size = 100, color = { 1, 1, 1 } })
table.insert(POSITION_ODIS_LIST, { x = 24138, y = 21670, z = 10786,  name = "LS4",	texture = ico_r_4, size = 100, color = { 1, 1, 1 } })
table.insert(POSITION_ODIS_LIST, { x = 24488, y = 21670, z = 10457,  name = "LS5",	texture = ico_r_5, size = 100, color = { 1, 1, 1 } }) -- Boss
-- Rechts NO
table.insert(POSITION_ODIS_LIST, { x = 26800, y = 21700, z = 8315,  name = "RN1",	texture = ico_r_1, size = 100, color = { 1, 1, 1 } }) -- Wall
table.insert(POSITION_ODIS_LIST, { x = 26486, y = 21672, z = 8627,  name = "RN2",	texture = ico_r_2, size = 100, color = { 1, 1, 1 } })
table.insert(POSITION_ODIS_LIST, { x = 26169, y = 21670, z = 8939,  name = "RN3",	texture = ico_r_3, size = 100, color = { 1, 1, 1 } })
table.insert(POSITION_ODIS_LIST, { x = 25865, y = 21670, z = 9236,  name = "RN4",	texture = ico_r_4, size = 100, color = { 1, 1, 1 } })
table.insert(POSITION_ODIS_LIST, { x = 25513, y = 21670, z = 9517,  name = "RN5",	texture = ico_r_5, size = 100, color = { 1, 1, 1 } }) -- Boss
-- Rechts SO
table.insert(POSITION_ODIS_LIST, { x = 26718, y = 21700, z = 11705,  name = "RS1",	texture = ico_r_1, size = 100, color = { 1, 1, 1 } }) -- Wall
table.insert(POSITION_ODIS_LIST, { x = 26404, y = 21672, z = 11409,  name = "RS2",	texture = ico_r_2, size = 100, color = { 1, 1, 1 } })
table.insert(POSITION_ODIS_LIST, { x = 26115, y = 21670, z = 11104,  name = "RS3",	texture = ico_r_3, size = 100, color = { 1, 1, 1 } })
table.insert(POSITION_ODIS_LIST, { x = 25822, y = 21670, z = 10828,  name = "RS4",	texture = ico_r_4, size = 100, color = { 1, 1, 1 } })
table.insert(POSITION_ODIS_LIST, { x = 25483, y = 21670, z = 10509,  name = "RS5",	texture = ico_r_5, size = 100, color = { 1, 1, 1 } }) -- Boss

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local ico_p1 = "odysupporticons/icons/squares/squaretwo_orange_one.dds"
local ico_p2 = "odysupporticons/icons/squares/squaretwo_orange_two.dds"
local ico_p3 = "odysupporticons/icons/squares/squaretwo_orange_three.dds"
local ico_p4 = "odysupporticons/icons/squares/squaretwo_orange_four.dds"

local PBLOOD_POSITION_ODIS_LIST = { }
local ICON_PBLOOD_OSITION = { }
table.insert(PBLOOD_POSITION_ODIS_LIST, { x = 24546, y = 14570, z = 9530,  name = "PS1", texture = ico_p1, size = 100, color = { 1, 1, 1 } })
table.insert(PBLOOD_POSITION_ODIS_LIST, { x = 24488, y = 14570, z = 10457, name = "PS2", texture = ico_p2, size = 100, color = { 1, 1, 1 } })
table.insert(PBLOOD_POSITION_ODIS_LIST, { x = 25483, y = 14570, z = 10509, name = "PS3", texture = ico_p3, size = 100, color = { 1, 1, 1 } })
table.insert(PBLOOD_POSITION_ODIS_LIST, { x = 25513, y = 14570, z = 9517,  name = "PS4", texture = ico_p4, size = 100, color = { 1, 1, 1 } })

--/script OSI.CreatePositionIcon(27246, 26790, 20355, "odysupporticons/icons/squares/squaretwo_orange_four.dds", 100, { 1, 1, 1 })
--/script BSCHTKAHelper.EnableAllPosIconConn()
--/script BSCHTKAHelper.DisableAllPosIconConn()
--/script BSCHTKAHelper.EnableAllPosIconBlood()
--/script BSCHTKAHelper.EnableAllTorturerIcons()


-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local function CreatePOSIcon()
	ICON_POSITION = { }
	for i, v in ipairs(POSITION_ODIS_LIST) do
		local icon = OSI.CreatePositionIcon(v.x, v.y, v.z, v.texture, v.size, v.color)
		ICON_POSITION[v.name] = icon
	end	
end
local function CreateTUTIcon()
	ICON_INFO_LIST = { }
	for i, v in ipairs(TORTURER_ODIS_LIST) do
		local icon = OSI.CreatePositionIcon(v.x, v.y, v.z, v.texture, v.size, v.color)
		ICON_INFO_LIST[v.name] = icon		
	end
end
local function CreateBloodIcon()
	ICON_PBLOOD_OSITION = { }
	for i, v in ipairs(PBLOOD_POSITION_ODIS_LIST) do
		local icon = OSI.CreatePositionIcon(v.x, v.y, v.z, v.texture, v.size, v.color)
		ICON_PBLOOD_OSITION[v.name] = icon
	end
end

function BSCHTKA.CreateAllIcons()
	if OSI and OSI.CreatePositionIcon then
		zo_callLater(function() CreatePOSIcon() end, 10)
		
		zo_callLater(function() CreateTUTIcon() end, 100)
		
		zo_callLater(function() CreateBloodIcon() end, 200)
		
		zo_callLater(function() 
			BSCHTKA.UpdateAllTorturerIcons()
			BSCHTKA.DisableAllTorturerIcons()
			BSCHTKA.UpdateAllPosIconConn()
			BSCHTKA.UpdatePosIcon()
			BSCHTKA.UpdateAllPosIconBlood()
			BSCHTKA.DisableAllPosIconBlood()
			BSCHTKA.DisableAllPosIconConn()
		end, 300)
	end	
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function BSCHTKA.DeleteAllIcons()
	if OSI and OSI.CreatePositionIcon then		
		for i, v in ipairs(POSITION_ODIS_LIST) do			
			OSI.DiscardPositionIcon(ICON_POSITION[v.name])
		end	
		ICON_POSITION = { }
		for i, v in ipairs(TORTURER_ODIS_LIST) do
			OSI.DiscardPositionIcon(ICON_INFO_LIST[v.name])	
		end		
		ICON_INFO_LIST = { }
		for i, v in ipairs(PBLOOD_POSITION_ODIS_LIST) do
			OSI.DiscardPositionIcon(ICON_PBLOOD_OSITION[v.name])
		end
		ICON_PBLOOD_OSITION = { }		
	end
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function BSCHTKA.EnableAllPosIconBlood()
	if OSI and OSI.CreatePositionIcon then
		for name, v in pairs(ICON_PBLOOD_OSITION) do
			ICON_PBLOOD_OSITION[name].use = true
		end
	end
end

function BSCHTKA.DisableAllPosIconBlood()
	if OSI and OSI.CreatePositionIcon then
		for name, v in pairs(ICON_PBLOOD_OSITION) do
			ICON_PBLOOD_OSITION[name].use = false
		end
	end
end
function BSCHTKA.UpdateAllPosIconBlood()
	if OSI and OSI.CreatePositionIcon then
		for name, v in pairs(ICON_PBLOOD_OSITION) do
			ICON_PBLOOD_OSITION[name].data.size = BSCHTKA.SV_ACC.BB_ODYICON_FALGRAVN_SIZE 
		end
	end
end


-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function BSCHTKA.ToggleTorturerIcon(name)
	if ICON_INFO_LIST[name] ~= nil then 
		if ICON_INFO_LIST[name].use then
			ICON_INFO_LIST[name].use = false
		else			
			ICON_INFO_LIST[name].use = true
		end
	end	
end
function BSCHTKA.EnableAllTorturerIcons()
	if OSI and OSI.CreatePositionIcon then
		for name, v in pairs(ICON_INFO_LIST) do
			BSCHTKA.UpdateTorturerIcon(name, 2)
			ICON_INFO_LIST[name].use = true
		end
	end
end
function BSCHTKA.DisableAllTorturerIcons()
	if OSI and OSI.CreatePositionIcon then
		for name, v in pairs(ICON_INFO_LIST) do
			ICON_INFO_LIST[name].use = false
		end
	end
end
function BSCHTKA.UpdateTorturerIcon(name, stage)
	if OSI and OSI.CreatePositionIcon then
		if ICON_INFO_LIST[name] ~= nil then 
			local texture = ico_r
			if stage == 0 then
				texture = ico_y
			elseif stage == 1 then
				texture = ico_g
			elseif stage == 2 then
				texture = ico_b
			elseif stage == 3 then
				texture = ico_r
			end	
			ICON_INFO_LIST[name].data.texture = texture
			OSI.UpdateIconData( ICON_INFO_LIST[name], texture, nil, nil )
		end
	end
end
function BSCHTKA.UpdateAllTorturerIcons()
	if OSI and OSI.CreatePositionIcon then
		for name, v in pairs(ICON_INFO_LIST) do
			ICON_INFO_LIST[name].data.texture = ico_r
			OSI.UpdateIconData( ICON_INFO_LIST[name], ico_r, nil, nil )			
			ICON_INFO_LIST[name].data.size = BSCHTKA.SV_ACC.TUT_ODYICON_FALGRAVN_SIZE 
		end
	end
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function BSCHTKA.EnableAllPosIconConn()
	if OSI and OSI.CreatePositionIcon then
		for name, v in pairs(ICON_POSITION) do		
			if ICON_POSITION[name].bscEnable then
				ICON_POSITION[name].use = true
			end
		end
	end
end
function BSCHTKA.DisableAllPosIconConn()
	if OSI and OSI.CreatePositionIcon then
		for name, v in pairs(ICON_POSITION) do
			ICON_POSITION[name].use = false
		end
	end
end
function BSCHTKA.UpdateAllPosIconConn()
	if OSI and OSI.CreatePositionIcon then
		for name, v in pairs(ICON_POSITION) do
			ICON_POSITION[name].bscEnable = true
			ICON_POSITION[name].data.size = BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_SIZE 
		end
	end
end

function BSCHTKA.UpdatePosIconOne(name, texture, enable)
	if ICON_POSITION[name] ~= nil then 
		ICON_POSITION[name].data.texture = texture
		ICON_POSITION[name].bscEnable = enable
		OSI.UpdateIconData( ICON_POSITION[name], texture, nil, nil )
	end
end

function BSCHTKA.UpdatePosIcon()
	if OSI and OSI.CreatePositionIcon then	
		local position = BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_POS	
		BSCHTKA.UpdatePosIconOne("LN1", ico_r_1, BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL)
		BSCHTKA.UpdatePosIconOne("LS1", ico_r_1, BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL)
		BSCHTKA.UpdatePosIconOne("RN1", ico_r_1, BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL)
		BSCHTKA.UpdatePosIconOne("RS1", ico_r_1, BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL)
			
		BSCHTKA.UpdatePosIconOne("LN2", ico_r_2, BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL)
		BSCHTKA.UpdatePosIconOne("LS2", ico_r_2, BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL)
		BSCHTKA.UpdatePosIconOne("RN2", ico_r_2, BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL)
		BSCHTKA.UpdatePosIconOne("RS2", ico_r_2, BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL)
		
		BSCHTKA.UpdatePosIconOne("LN3", ico_r_3, BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL)
		BSCHTKA.UpdatePosIconOne("LS3", ico_r_3, BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL)
		BSCHTKA.UpdatePosIconOne("RN3", ico_r_3, BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL)
		BSCHTKA.UpdatePosIconOne("RS3", ico_r_3, BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL)
		
		BSCHTKA.UpdatePosIconOne("LN4", ico_r_4, BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL)
		BSCHTKA.UpdatePosIconOne("LS4", ico_r_4, BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL)
		BSCHTKA.UpdatePosIconOne("RN4", ico_r_4, BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL)
		BSCHTKA.UpdatePosIconOne("RS4", ico_r_4, BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL)
		
		BSCHTKA.UpdatePosIconOne("LN5", ico_r_5, BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL)
		BSCHTKA.UpdatePosIconOne("LS5", ico_r_5, BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL)
		BSCHTKA.UpdatePosIconOne("RN5", ico_r_5, BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL)
		BSCHTKA.UpdatePosIconOne("RS5", ico_r_5, BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL)
		
		if position == 1 then
			BSCHTKA.UpdatePosIconOne("LN1", ico_g_1, true)
			BSCHTKA.UpdatePosIconOne("LS1", ico_g_1, true)
			BSCHTKA.UpdatePosIconOne("RN1", ico_g_1, true)
			BSCHTKA.UpdatePosIconOne("RS1", ico_g_1, true)			
		elseif position == 2 then			
			BSCHTKA.UpdatePosIconOne("LN2", ico_g_2, true)
			BSCHTKA.UpdatePosIconOne("LS2", ico_g_2, true)
			BSCHTKA.UpdatePosIconOne("RN2", ico_g_2, true)
			BSCHTKA.UpdatePosIconOne("RS2", ico_g_2, true)
		elseif position == 3 then			
			BSCHTKA.UpdatePosIconOne("LN3", ico_g_3, true)
			BSCHTKA.UpdatePosIconOne("LS3", ico_g_3, true)
			BSCHTKA.UpdatePosIconOne("RN3", ico_g_3, true)
			BSCHTKA.UpdatePosIconOne("RS3", ico_g_3, true)
		elseif position == 4 then
			BSCHTKA.UpdatePosIconOne("LN4", ico_g_4, true)
			BSCHTKA.UpdatePosIconOne("LS4", ico_g_4, true)
			BSCHTKA.UpdatePosIconOne("RN4", ico_g_4, true)
			BSCHTKA.UpdatePosIconOne("RS4", ico_g_4, true)
		elseif position == 5 then			
			BSCHTKA.UpdatePosIconOne("LN5", ico_g_5, true)
			BSCHTKA.UpdatePosIconOne("LS5", ico_g_5, true)
			BSCHTKA.UpdatePosIconOne("RN5", ico_g_5, true)
			BSCHTKA.UpdatePosIconOne("RS5", ico_g_5, true)
		end		
	end
end

local ICON_PORTAL = nil
function BSCHTKA.AddPortalIcon()
	if OSI and OSI.CreatePositionIcon and ICON_PORTAL == nil then
		ICON_PORTAL = OSI.CreatePositionIcon(114624, 25764, 71349, "/esoui/art/icons/malatar_agonizingbolts.dds", 100, { 1, 1, 1 })
	end
end
function BSCHTKA.RemovePortalIcon()
	if OSI and OSI.CreatePositionIcon and ICON_PORTAL ~= nil then
		OSI.DiscardPositionIcon(ICON_PORTAL)
		ICON_PORTAL = nil
	end
end



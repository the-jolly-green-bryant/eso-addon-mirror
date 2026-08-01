-- RdK Group Tool
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}
RdKGTool.addonName = "RdKGroupTool"
RdKGTool.version = 1 --for saved vars, shouldn't be used (version.fix instead)
RdKGTool.versionString = "2.2.2"
RdKGTool.updateInterval = 50 -- in ms
RdKGTool.author = "@s0rdrak (PC / EU)"
RdKGTool.credits = "RdK :)"
RdKGTool.contributors = "@LeeJayBee"
RdKGTool.slashCmd = "/rdk"
RdKGTool.PREFIX = "+"

RdKGTool.addonState = {}

RdKGTool.config = {}
RdKGTool.config.constants = {}

RdKGTool.constants = {}

RdKGTool.default = {}


RdKGTool.menu = {}
RdKGTool.menu.name = "RdKGroupToolMenu"

RdKGTool.state = {}

--do not directly access them!
RdKGTool.vars = {}

--/script RdKGTool.RdKGToolOnInitialize(nil, "RdKGroupTool")
function RdKGTool.RdKGToolOnInitialize(event, addonName)
	if addonName == RdKGTool.addonName then
		local libsLoaded, missingLibs = RdKGTool.AreLibrariesLoaded()
		if libsLoaded == false then
			zo_callLater(
			function()
				d(RdKGTool.constants.MISSING_LIBRARIES)
				for i = 1, #missingLibs do
					d(missingLibs[i])
				end
			end, 5000)
			return
		end
		--create default values in case there aren't any saved vars
		RdKGTool.default.profiles = RdKGTool.profile.GetAccountDefaults()
		RdKGTool.default.character = RdKGTool.profile.GetCharacterDefaults()
		
		--update this part when new defaults / functionality is added
		if RdKGTool.default.profiles ~= nil and RdKGTool.default.profiles.profiles ~= nil then
			for key, value in pairs(RdKGTool.default.profiles.profiles) do
				RdKGTool.default.profiles.profiles[key] = RdKGTool.CreateCleanProfile()
			end
		end
			
		local charVars = ZO_SavedVars:New("RdKGroupToolVars", RdKGTool.version, nil, RdKGTool.default.character)
		local accVars = ZO_SavedVars:NewAccountWide("RdKGroupToolVars", RdKGTool.version, nil, RdKGTool.default.profiles)
			
		for i = 1, #accVars.profiles do
			local profile = RdKGTool.CreateCleanProfile()
			profile.name = "___"
			RdKGTool.PopulateWithDefaults(accVars.profiles[i], profile)
		end
		--do not directly access them!
		RdKGTool.vars.acc = accVars
		RdKGTool.vars.char = charVars
	
		RdKGTool.util.versioning.InitializeFixes(accVars, charVars)

			
		RdKGTool.profile.Initialize(accVars, charVars)
			
		RdKGTool.ui.Initialize()
		RdKGTool.util.Initialize()			
		RdKGTool.group.Initialize()
		RdKGTool.compass.Initialize()
		RdKGTool.toolbox.Initialize()
		RdKGTool.classRole.Initialize()
		RdKGTool.addOnIntegration.Initialize()
		RdKGTool.admin.Initialize()
		RdKGTool.cfg.Initialize()
			
		RdKGTool.menu.Initialize()

		EVENT_MANAGER:UnregisterForEvent(RdKGTool.addonName, EVENT_ADD_ON_LOADED)

	end
end

--update this method when new defaults / functionality is added
function RdKGTool.CreateCleanProfile()
	local profile = RdKGTool.profile.GetAccountDefaults().profiles[1]
	profile.ui = RdKGTool.ui.GetDefaults()
	profile.group = RdKGTool.group.GetDefaults()
	profile.compass = RdKGTool.compass.GetDefaults()
	profile.toolbox = RdKGTool.toolbox.GetDefaults()
	profile.classRole = RdKGTool.classRole.GetDefaults()
	profile.addOnIntegration = RdKGTool.addOnIntegration.GetDefaults()
	profile.util = RdKGTool.util.GetDefaults()
	profile.admin = RdKGTool.admin.GetDefaults()
	profile.cfg = RdKGTool.cfg.GetDefaults()
	return profile
end

--helper functions
function RdKGTool.PopulateWithDefaults(orig, defaults)
	if orig ~= nil and type(orig) == "table" then
		for key, value in pairs(defaults) do
			if orig[key] == nil then
				orig[key] = defaults[key]
			elseif type(orig[key]) == "table" and type(defaults[key]) == "table" then
				RdKGTool.PopulateWithDefaults(orig[key], defaults[key])
			end
		end
	end
end

function RdKGTool.AreLibrariesLoaded()
	local loaded = true
	local missingLibs = {}
	if LibAddonMenu2 == nil then
		loaded = false
		table.insert(missingLibs, "LibAddonMenu")
	end
	if LibMapPing == nil then
		loaded = false
		table.insert(missingLibs, "LibMapPing")
	end
	if LibGPS2 == nil then
		loaded = false
		table.insert(missingLibs, "LibGPS")
	end
	if Lib3D == nil then
		loaded = false
		table.insert(missingLibs, "Lib3D-v3")
	end
	if LIB_FOOD_DRINK_BUFF == nil then
		loaded = false
		table.insert(missingLibs, "LibFoodDrinkBuff")
	end
	if LibPotionBuff == nil then
		loaded = false
		table.insert(missingLibs, "LibPotionBuff")
	end
	if LibCustomMenu == nil then
		loaded = false
		table.insert(missingLibs, "LibCustomMenu")
		
	end
	return loaded, missingLibs
end

EVENT_MANAGER:RegisterForEvent(RdKGTool.addonName, EVENT_ADD_ON_LOADED, RdKGTool.RdKGToolOnInitialize)


SLASH_COMMANDS[RdKGTool.slashCmd] = function(param)
	local chat = RdKGTool.util.chatSystem
	chat.SendChatMessage(string.format("%s %s", RdKGTool.slashCmd, param), RdKGTool.PREFIX, chat.constants.messageTypes.MESSAGE_NORMAL)
	--param = zo_strtrim(param)
	param = {zo_strsplit(" ", zo_strtrim(param))}
	--d(param)
	if param == nil then
		chat.SendChatMessage(RdKGTool.config.constants.CMD_TEXT_MENU)
		--d(RdKGTool.config.constants.CMD_TEXT_MENU)
	else
		param[1] = string.lower(param[1])
		--d(param)
		if param[1] == "menu" then
			RdKGTool.menu.OpenMenu()
		elseif param[1] == "ai" then
			RdKGTool.group.SlashCmd(param)
		elseif param[1] == "crown" then
			RdKGTool.group.SlashCmd(param)
		elseif param[1] == "hdm" then
			RdKGTool.group.SlashCmd(param)
		elseif param[1] == "admin" then
			RdKGTool.admin.SlashCmd(param)
		elseif param[1] == "config" then
			RdKGTool.cfg.SlashCmd(param)
		else
			chat.SendChatMessage(RdKGTool.config.constants.CMD_TEXT_MENU, RdKGTool.PREFIX, chat.constants.messageTypes.MESSAGE_NORMAL)
		end
	end
end



























--[[

<TopLevelControl name="RdKGTool_Crown_Test" tier="0" layer="0" level="0">
			<Controls>
				<Texture name="$(parent)Icon" textureFile="RdKGroupTool/Art/Crowns/Krone.dds" level="3" />
]]

function testMultiLineEdit()
	local wm = GetWindowManager()
	local container = wm:CreateTopLevelWindow("testingEdit")
	bd = wm:CreateControlFromVirtual(nil, container, "ZO_EditBackdrop")
	editbox = wm:CreateControlFromVirtual(nil, bd, "ZO_DefaultEditMultiLineForBackdrop")
	
	
	bd:SetAnchor(TOPLEFT, container, TOPLEFT, 255, 255)
	bd:SetDimensions(300,300)
	
	local text = ""
	for i = 1, 1000 do
		text = text .. "aaaaaaaaaa"
		text = text .. "aaaaaaaaaa"
		text = text .. "aaaaaaaaaa"
		text = text .. "aaaaaaaaaa"
		text = text .. "aaaaaaaaaa"
		text = text .. "aaaaaaaaaa"
		text = text .. "aaaaaaaaaa"
		text = text .. "aaaaaaaaaa"
		text = text .. "aaaaaaaaaa"
		text = text .. "aaaaaaaaaa"
	end
	
	editbox:SetMaxInputChars(100000)
	editbox:SetText(text)
	--editbox:SetHandler("OnTextChanged", PortToFriend.SearchTextChanged)
	editbox:SetAnchor(TOPLEFT, container, TOPLEFT, 255, 255)
	editbox:SetDimensions(300,300)
	local text2 = editbox:GetText()
	d(string.len(text2))
	--d(editbox:GetMaxInputChars())

end


--Test Crap - Remove later
--local lib3D = LibStub("Lib3D2")
local control = RdKGTool_Crown_Test
local controlIcon = RdKGTool_Crown_TestIcon
function test3d()
--[[
	local wm = GetWindowManager() 
	controlX = wm:CreateControl("weeeeeeeeeeeeeeeeeeeeeeeeee", GuiRoot, CT_CONTROL)
	d(controlX)
	d(controlX:GetParent())
	controlX:SetDrawTier(0)
	controlX:SetDrawLayer(0)
	controlX:SetDrawLevel(0)
	controlX:SetDimensions(100,100)
	lib3D:RegisterControl(controlX)
	controlX.texture = wm:CreateControl(nil, controlX, CT_TEXTURE)
	controlX.texture:SetTexture("RdKGroupTool/Art/3DObjects/ray.dds")
	controlX:Create3DRenderSpace()
	controlX.texture:Create3DRenderSpace()
	controlX.texture:Set3DLocalDimensions(1, 1)
	controlX.texture:SetDrawLevel(3)
	controlX.texture:SetColor(1,1,1,1)
	--lib3D:RegisterControl(controlX.texture)
	]]
	if control == nil or controlIcon == nil then
		test3dControls(RdKGTool_Crown_Test, RdKGTool_Crown_TestIcon)
	end
	
	control:Create3DRenderSpace()
	--lib3D:RegisterControl(control)
	controlIcon:Create3DRenderSpace()
	test3dDimensions(1, 256)
	controlIcon:Set3DRenderSpaceUsesDepthBuffer(true)
	--d(RdKGTool_Crown_Test:GetParent())
	--local x, y, z = GetMapPlayerPosition("player")
	local name = controlIcon.name
	if name == nil then
		name = "player"
	end
	local x, y, z = GetMapPlayerPosition(name)
	--local x, y, z = GetMapPlayerPosition("group3")
	local worldX, worldZ = lib3D:LocalToWorld(x, y)
	local _, height, _ = lib3D:GetCameraRenderSpacePosition()
	
	controlIcon:Set3DRenderSpaceOrigin(worldX, height, worldZ)
	--controlX.texture:Set3DRenderSpaceOrigin(worldX, height, worldZ)
	--RdKGTool_Crown_TestIcon:Set3DRenderSpaceOrigin(8,8,8)
	--RdKGTool_Crown_Test:Set3DRenderSpaceOrigin(8,8,8)
	--RdKGTool_Crown_Test:SetHidden(true)
	--RdKGTool_Crown_TestIcon:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(GetMapPlayerPosition("player")))
	--EVENT_MANAGER:RegisterForUpdate("dafuqtest",10,dafuqupdatetest)
end

function test3dControls(c, ci)
	control = c
	controlIcon = ci
end

function test3dColor(r,g,b,a)
	controlIcon:SetColor(r,g,b,a)
end

function test3dTexture(texture)
	controlIcon:SetTexture(texture)
end

-- Hi Baetram ;)
--[[
function compareLibs()
	local lib3D = LibStub("Lib3D")
	local lib3D2 = LibStub("Lib3D2")
	local mapX, mapY = GetMapPlayerPosition("player")
	d("-----")
	d("Map X: " .. mapX)
	d("Map Y: " .. mapY)
	local libX, libY = lib3D:GetCurrentWorldCoordsFromLocal(mapX, mapY)
	local lib2X, lib2Y = lib3D2:LocalToWorld(mapX, mapY)
	d("Lib X: " .. libX)
	d("Lib Y: " .. libY)
	d("Lib2 X: " .. lib2X)
	d("Lib2 Y: " .. lib2Y)
	local libGPS = LibGPS2
	local gpsX, gpsY = libGPS:LocalToGlobal(mapX, mapY)
	d("GPS X: " .. gpsX)
	d("GPS Y: " .. gpsY)
	local libCalcX, libCalcY = lib3D:GetCurrentWorldCoordsFromGlobal(gpsX, gpsY)
	local lib2CalcX, lib2CalcY = lib3D2:GlobalToWorld(gpsX, gpsY)
	d("Lib Calc X: " .. libCalcX)
	d("Lib Calc Y: " .. libCalcY)
	d("Lib2 Calc X: " .. lib2CalcX)
	d("Lib2 Calc Y: " .. lib2CalcY)
	local libFactor = lib3D:GetGlobalToWorldFactor(GetZoneId(GetUnitZoneIndex("player")))
	local lib2Factor = lib3D2:GetGlobalToWorldFactor(GetZoneId(GetUnitZoneIndex("player")))
	d("Lib Factor: " .. libFactor)
	d("Lib2 Factor: " .. lib2Factor)
	d("Lib Zone Factor: " .. lib3D.SPECIAL_GLOBAL_TO_WORLD_FACTORS[GetZoneId(GetUnitZoneIndex("player"))])
	d("Lib2 Zone Factor: " .. lib3D2.SPECIAL_GLOBAL_TO_WORLD_FACTORS[GetZoneId(GetUnitZoneIndex("player"))])
	local originX, originY = lib3D2:GetWorldOriginAsGlobal()
	d("Lib2 Origin X: " .. originX)
	d("Lib2 Origin Y: " .. originY)
	d("Map X: " .. mapX)
	d("Map Y: " .. mapY)
end
]]

--[[
function dafuqupdatetest()
	local lib3D = LibStub("Lib3D2")
	
	--local x, y, z = GetMapPlayerPosition("player")
	local name = controlIcon.name
	if name == nil then
		name = "player"
	end
	local x, y, z = GetMapPlayerPosition(name)
	local worldX, worldZ = lib3D:LocalToWorld(x, y)
	local _, height, _ = lib3D:GetCameraRenderSpacePosition()
	--local _, height, _ = lib3D:GetCameraCurrentWorldCoords()
	--d(y)
	--d(worldX .. ", ".. worldZ)
	if worldX ~= nil and worldZ ~= nil then
		worldX, _, worldZ = WorldPositionToGuiRender3DPosition(worldX * 100, 0, worldZ*100)
	end
	controlIcon:Set3DRenderSpaceOrigin(worldX, height , worldZ)
	--RdKGTool_Crown_TestIcon:Set3DRenderSpaceOrigin(19194.756282235,120.04095458984,9457.358678526)
	local heading = GetPlayerCameraHeading()
	if heading > math.pi then 
		heading = heading - 2 * math.pi
	end
	testData1 = {}
	testData1.x = worldX
	testData1.y = worldZ
	controlIcon:Set3DRenderSpaceOrientation(0, heading, 0)
	--controlX.texture:Set3DRenderSpaceOrigin(worldX, height, worldZ)
	--/script lx, ly, lz = RdKGTool_Crown_TestIcon:Get3DRenderSpaceOrigin()
	--/script RdKGTool_Crown_TestIcon:Set3DRenderSpaceOrigin(lx, ly, lz)
	--
	
	local x, y, z = GetMapPlayerPosition(GetGroupUnitTagByIndex(1))
	local worldX, worldZ = lib3D:GetPersistentWorldCoordsFromLocal(x, currentY)
	local _, height, _ = lib3D:GetCameraCurrentWorldCoords()
	
	RdKGTool_Crown_TestIcon:Set3DRenderSpaceOrigin(worldX, height, worldZ)

	
end
]]
function test3dPlayer(name)
	controlIcon.name = name
end

function test3dDimensions(width, height)
	controlIcon:Set3DLocalDimensions(width, height)
end

function test3d2(player1, player2)
	RdKGTool_Crown_Test:Create3DRenderSpace()
	RdKGTool_Crown_TestIcon:Create3DRenderSpace()
	RdKGTool_Crown_TestIcon.player = player1
	RdKGTool_Crown_TestIcon:SetColor(1,0,0,0.5)
	RdKGTool_Crown_TestIcon2:Create3DRenderSpace()
	RdKGTool_Crown_TestIcon2.player = player2
	RdKGTool_Crown_TestIcon2:SetColor(0,0,1,0.5)
	RdKGTool_Crown_TestIcon:Set3DLocalDimensions(1, 256)
	RdKGTool_Crown_TestIcon2:Set3DLocalDimensions(1, 256)
	RdKGTool_Crown_Test:Set3DRenderSpaceOrigin(0,0,0)
	EVENT_MANAGER:RegisterForUpdate("test3d2",10,test3d2OnUpdate)
end
--[[
function test3d2OnUpdate()
	local lib3D = LibStub("Lib3D2")
	
	local x, y, z = GetMapPlayerPosition(RdKGTool_Crown_TestIcon.player)
	local worldX, worldZ = lib3D:LocalToWorld(x, y)
	local _, height, _ = lib3D:GetCameraRenderSpacePosition()
	--local _, height, _ = lib3D:GetCameraCurrentWorldCoords()
	--d(y)
	--d(worldX .. ", ".. worldZ)
	if worldX ~= nil and worldZ ~= nil then
		worldX, _, worldZ = WorldPositionToGuiRender3DPosition(worldX * 100, 0, worldZ*100)
	end
	RdKGTool_Crown_TestIcon:Set3DRenderSpaceOrigin(worldX, height , worldZ)
	
	x, y, z = GetMapPlayerPosition(RdKGTool_Crown_TestIcon2.player)
	worldX, worldZ = lib3D:LocalToWorld(x, y)
	_, height, _ = lib3D:GetCameraRenderSpacePosition()
	--local _, height, _ = lib3D:GetCameraCurrentWorldCoords()
	--d(y)
	--d(worldX .. ", ".. worldZ)
	if worldX ~= nil and worldZ ~= nil then
		worldX, _, worldZ = WorldPositionToGuiRender3DPosition(worldX * 100, 0, worldZ*100)
	end
	RdKGTool_Crown_TestIcon2:Set3DRenderSpaceOrigin(worldX, height , worldZ)
	
	local heading = GetPlayerCameraHeading()
	if heading > math.pi then 
		heading = heading - 2 * math.pi
	end
	RdKGTool_Crown_TestIcon:Set3DRenderSpaceOrientation(0, heading, 0)
	RdKGTool_Crown_TestIcon2:Set3DRenderSpaceOrientation(0, heading, 0)
	
end]]

function analyzeIconMetatables()
	local metatable = getmetatable(getmetatable(RdKGTool_Crown_TestIcon)["__index"])["__index"]
	iconTable = {}
	for key, value in pairs(metatable) do
		--d(key)
		if type(value) == "function" and key:sub(1,3) == "Get" then
			pcall(function() iconTable[key] = value(RdKGTool_Crown_TestIcon) end)
		end
	end
	
	metatable = getmetatable(controlX.texture)["__index"]
	textureTable = {}
	for key, value in pairs(metatable) do
		if type(value) == "function" and key:sub(1,3) == "Get" then
			pcall(function() textureTable[key] = value(controlX) end)
		end
	end
	
	tableDifferences = {}
	for key, value in pairs(iconTable) do
		if value ~= textureTable[key] then
			tableDifferences[key] = {}
			tableDifferences[key].icon = value
			tableDifferences[key].texture = textureTable[key]
		end
	end
end

function analyzeControlMetatables()
	local metatable = getmetatable(RdKGTool_Crown_Test)["__index"]
	iconTable = {}
	for key, value in pairs(metatable) do
		--d(key)
		if type(value) == "function" and key:sub(1,3) == "Get" then
			pcall(function() iconTable[key] = value(RdKGTool_Crown_Test) end)
		end
	end
	
	metatable = getmetatable(getmetatable(controlX)["__index"])["__index"]
	textureTable = {}
	for key, value in pairs(metatable) do
		if type(value) == "function" and key:sub(1,3) == "Get" then
			pcall(function() textureTable[key] = value(controlX) end)
		end
	end
	
	tableDifferences = {}
	for key, value in pairs(iconTable) do
		if value ~= textureTable[key] then
			tableDifferences[key] = {}
			tableDifferences[key].icon = value
			tableDifferences[key].texture = textureTable[key]
		end
	end
end

--[[
function test3d3()

	local lib3D = LibStub("Lib3D2")

	local wm = GetWindowManager() 
	--controlX = wm:CreateControl("weeeeeeeeeeeeeeeeeeeeeeeeee", GuiRoot, CT_CONTROL)
	controlX = wm:CreateTopLevelWindow("weeeeeeeeeeeeeeeeeeeeeeeeee")
	--d(controlX)
	--d(controlX:GetParent())
	controlX:SetDrawTier(0)
	controlX:SetDrawLayer(0)
	controlX:SetDrawLevel(0)
	--controlX:SetDimensions(100,100)
	--lib3D:RegisterControl(controlX)
	controlX.texture = wm:CreateControl("weeeeee22", controlX, CT_TEXTURE)
	controlX.texture:SetTexture("RdKGroupTool/Art/3DObjects/Beam1.dds")
	controlX:Create3DRenderSpace()
	controlX.texture:Create3DRenderSpace()
	controlX.texture:Set3DLocalDimensions(1, 256)
	controlX.texture:SetDrawLevel(3)
	controlX.texture:SetColor(1,1,1,1)
	controlX.texture:SetParent(controlX) --works with RdKGTool_Crown_Test
	--controlX.texture:SetAlpha(1)
	controlX:Set3DRenderSpaceOrigin(0,0,0)
	
	local x, y, z = GetMapPlayerPosition("player")
	local worldX, worldZ = lib3D:LocalToWorld(x, y)
	local _, height, _ = lib3D:GetCameraRenderSpacePosition()
	d(worldX)
	d(height)
	d(worldZ)
	if worldX ~= nil and worldZ ~= nil then
		worldX, _, worldZ = WorldPositionToGuiRender3DPosition(worldX * 100, 0, worldZ*100)
	end
	d(worldX)
	d(height)
	d(worldZ)
	controlX.texture:Set3DRenderSpaceOrigin(worldX, height , worldZ)
	--test3d2("player","player")
	--analyzeMetatables()
end]]

function RdKGTool.CreateTempBuffIconPicker()
	local effects = GroupBuffsData.effects
	if effects ~= nil then
	
		local colorpicker = {
			[1] = {
				type = "iconpicker",
				name = "My Icon Picker", -- or string id or function returning a string
				choices = {"texture path 1", "texture path 2", "texture path 3"},
				getFunc = function() return "" end,
				setFunc = function(var) end,
				tooltip = "Color Picker's tooltip text.", -- or string id or function returning a string (optional)
				choicesTooltips = {"icon tooltip 1", "icon tooltip 2", "icon tooltip 3"}, -- or array of string ids or array of functions returning a string (optional)
				maxColumns = 5, -- number of icons in one row (optional)
				visibleRows = 4.5, -- number of visible rows (optional)
				iconSize = 28, -- size of the icons (optional)
				defaultColor = ZO_ColorDef:New("FFFFFF"), -- default color of the icons (optional)
				width = "full", --or "half" (optional)
				beforeShow = function(control, iconPicker) return preventShow end, --(optional)
				disabled = function() return db.someBooleanSetting end, --or boolean (optional)
				warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
				requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
				default = defaults.var, -- default value or function that returns the default value (optional)
				reference = "MyAddonIconPicker" -- unique global reference to control (optional)
			}
		}
		
	end

end

function test3dNew()
	local wm = GetWindowManager() 
	controlY = wm:CreateTopLevelWindow("test3dNew")
	controlY:SetDrawTier(0)
	controlY:SetDrawLayer(0)
	controlY:SetDrawLevel(0)
	controlY.texture = wm:CreateControl("test3dNew2", controlY, CT_TEXTURE)
	controlY.texture:SetTexture("RdKGroupTool/Art/3DObjects/Beam1.dds")
	controlY:Create3DRenderSpace()
	controlY.texture:Create3DRenderSpace()
	controlY.texture:Set3DLocalDimensions(1, 1)
	controlY.texture:SetDrawLevel(3)
	controlY.texture:SetColor(1,1,1,1)
	controlY.texture:Set3DRenderSpaceUsesDepthBuffer(true)
	--controlY.texture:SetParent(controlY)
	controlY:Set3DRenderSpaceOrigin(0,0,0)
	local _, worldX, worldY, worldZ = GetUnitWorldPosition("player") 
	d(worldX)
	d(worldY)
	d(worldZ)
	worldX, worldY, worldZ = WorldPositionToGuiRender3DPosition(worldX, worldY, worldZ)
	d(worldX)
	d(worldY)
	d(worldZ)
	controlY.texture:Set3DRenderSpaceOrigin(worldX, worldY , worldZ)
end

function test3dad(height)
	local _, worldX, worldY, worldZ = GetUnitWorldPosition("player")
	worldX, worldY, worldZ = WorldPositionToGuiRender3DPosition(worldX, worldY, worldZ)
	controlY.texture:Set3DRenderSpaceOrigin(worldX, worldY + height, worldZ)
end

function test3dtext(texture)
	controlY.texture:SetTexture(texture)
end

function test3ddimensions(width, height)
	controlY.texture:Set3DLocalDimensions(width, height)
end

function test3dcolor(r,g,b,a)
	controlY.texture:SetColor(r,g,b,a)
end

function test3dcontrol()
	return controlY.texture
end

function test3d2New()
	local wm = GetWindowManager() 
	controlZ = wm:CreateTopLevelWindow("test3d2New")
	controlZ:SetDrawTier(0)
	controlZ:SetDrawLayer(0)
	controlZ:SetDrawLevel(0)
	controlZ.child = RdKGTool.ui.buffs.CreateBuffControl(controlZ,0,0)
	controlZ.child:Create3DRenderSpace()
	--controlZ.child:Set3DLocalDimensions(1, 1)
	controlZ.child.backdrop:Create3DRenderSpace()
	controlZ.child.edge:Create3DRenderSpace()
	controlZ.child.progress:Create3DRenderSpace()
	controlZ.child.timeLabel:Create3DRenderSpace()
	controlZ.child.timeLabel:SetText("t")
	controlZ.child.texture:Create3DRenderSpace()
	controlZ:Set3DRenderSpaceOrigin(0,0,0)
	local _, worldX, worldY, worldZ = GetUnitWorldPosition("player") 
	worldX, worldY, worldZ = WorldPositionToGuiRender3DPosition(worldX, worldY, worldZ)
	controlZ.child:Set3DRenderSpaceOrigin(worldX, worldY , worldZ)
	--controlZ.child.backdrop:Set3DRenderSpaceOrigin(worldX, worldY , worldZ)
	--controlZ.child.edge:Set3DRenderSpaceOrigin(worldX, worldY , worldZ)
	--controlZ.child.progress:Set3DRenderSpaceOrigin(worldX, worldY , worldZ)
	--controlZ.child.timeLabel:Set3DRenderSpaceOrigin(worldX, worldY , worldZ)
	--controlZ.child.texture:Set3DRenderSpaceOrigin(worldX, worldY , worldZ)
end

function test3d2ad(height)
	local _, worldX, worldY, worldZ = GetUnitWorldPosition("player")
	worldX, worldY, worldZ = WorldPositionToGuiRender3DPosition(worldX, worldY, worldZ)
	controlZ.child:Set3DRenderSpaceOrigin(worldX, worldY + height, worldZ)
end

function RdKGTool.Temp_SortTheCrap(a,b) 
	if a.secsSinceLogoff<b.secsSinceLogoff then
		return true
	else
		return false
	end
	d("failure >_<")
end

function Temp_ExtractGuildInfo()
	d(GetGuildName(1))
	if GetGuildName(1) == "Retter des Kaiserreiches" then
		local count = GetNumGuildMembers(1)
		local retTable = ""
		local retVals = {}
		for i = 1, count do
			local name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(1, i)
			retVals[i] = {}
			retVals[i].name = name
			retVals[i].secsSinceLogoff = secsSinceLogoff
			--retTable = retTable .. name .. " - " .. secsSinceLogoff .. "\r\n"
		end
		--implement sort here
		table.sort(retVals, function(a,b) return RdKGTool.Temp_SortTheCrap(a,b) end)
		for i = 1, #retVals do
			retTable = retTable .. retVals[i].name .. " - " .. retVals[i].secsSinceLogoff .. "\r\n"
		end
		RdKGTool.savedVars.GuildMembers = retTable
	end
end

function testEffectChanged()
	EVENT_MANAGER:RegisterForEvent("RdKGToolTestEffectChanged", EVENT_EFFECT_CHANGED, function(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType) 
		if unitTag ~= nil and unitTag ~= "player" and unitTag ~= "" then
			if effectType == BUFF_EFFECT_TYPE_DEBUFF then
				d("---------")
				d(unitTag)
				d(unitName)
				d(abilityId)
				if abilityId ~= nil then
					d(GetAbilityName(abilityId))
				end
				d(effectType)
			end
		end
	end)
end
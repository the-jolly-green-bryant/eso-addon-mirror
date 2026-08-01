NailDownGui = NailDownGui or {}
NDG = NailDownGui
NailDownGui.settings = NailDownGui.settings  or {}
NailDownGui.SettingsPanel = nil
local settings = NailDownGui.settings


local LL 	= LibLazy
local LAM 	= LibStub("LibAddonMenu-2.0")

local defaults = {	
	
	debugOutput = false,		
	global = true,
	
	chatInBackground = true,
	chatStartMaximized = true,
	chatAlwaysMaximized = false,
	WorldMapOnTop = true,
	
	resizeOnPlayerInitialized = true,
	resizeOnSizeChange = true,
	resizeOnGuiLoad = true,
	onActionLayer = true,
	
	tbugInBackground = true, 
	
	torchbug = {
		addonName = "merTorchbug",
		active = true,
	},
	chatContainer = {
		controlName = "ZO_ChatWindow",
		active = true,
		drawLayer = 0,
		position = "BOTTOMLEFT",
		anchorPosition = "TOPLEFT",
		anchorName = "GuiRoot",
		width = 1000,
		height = 600,
		offsetX = 0, 
		offsetY = 0,
	},
	ravaloxQT = {
		addonName = "Ravalox'QuestTracker",
		controlName = "QuestTrackerWin",
		active = true,
		position = "RIGHT",
		anchorPosition = "RIGHT",
		anchorName = "GuiRoot",
		width = 0,
		height = 0,
		offsetX = 0, 
		offsetY = 0,
	},
	wykkydsToolbar = {
		addonName = "wykkydsToolbar",
		controlName = "wykkydsToolbar",
		active = true,
		position = "BOTTOMLEFT",
		anchorPosition = "BOTTOMLEFT",
		anchorName = "GuiRoot",
		width = 0,
		height = 0,
		offsetX = 0, 
		offsetY = 0,
	},
	lootDrop = {
		addonName = "LootDrop",
		controlName = "LootDropGui",
		active = true,
		drawLayer = 1,
		position = "LEFT",
		anchorPosition = "LEFT",
		anchorName = "GuiRoot",
		width = 0,
		height = 0,
		offsetX = 0, 
		offsetY = 0,
	},
	das = {
		addonName = "DailyAutoShare",
		controlName = "DasHandle",
		active = true,
		position = "BOTTOMRIGHT",
		anchorPosition = "BOTTOMRIGHT",
		anchorName = "GuiRoot",
		width = 0,
		height = 0,
		offsetX = 0, 
		offsetY = 0,
	},
	switchBar = {
		addonName = "SwitchBar",
		controlName = "SwitchBarMain",
		active = true,
		position = "BOTTOMRIGHT",
		anchorPosition = "BOTTOMRIGHT",
		anchorName = "GuiRoot",
		width = 0,
		height = 0,
		offsetX = 0, 
		offsetY = 0,
	},
	miniMap = {
		addonName = "AUI",
		controlName = "AUI_Minimap_MainWindow",
		active = true,
		position = "TOPRIGHT",
		anchorPosition = "TOPRIGHT",
		anchorName = "GuiRoot",
		width = 0,
		height = 0,
		offsetX = 0, 
		offsetY = 0,
	},
	achievementTracker = {
		addonName = "wykkydsToolbar",
		controlName = "wykkyddsAchievementTrackerWindow",
		active = true,
		position = "TOPLEFT",
		anchorPosition = "TOPLEFT",
		anchorName = "GuiRoot",
		width = 0,
		height = 0,
		offsetX = 0, 
		offsetY = 0,
	},
	alertText = {
		controlName = "ZO_QuestTrackerTimerAnchor",
		active = true,
		position = "TOPRIGHT",
		anchorPosition = "TOPRIGHT",
		anchorName = "GuiRoot",
		width = 0,
		height = 0,
		offsetX = 0, 
		offsetY = 0,
	},		
	healthBar = {
		controlName = "ZO_PlayerAttributeHealth",
		active = true,
		position = "BOTTOM",
		anchorPosition = "BOTTOM",
		anchorName = "GuiRoot",
		width = 0,
		height = 0,
		offsetX = 0, 
		offsetY = -150
	},
	magickaBar = {
		controlName = "ZO_PlayerAttributeMagicka",
		active = true,
		position = "TOPRIGHT",
		anchorPosition = "BOTTOM",
		anchorName = "ZO_PlayerAttributeHealth",
		width = 0,
		height = 0,
		offsetX = 0, 
		offsetY = 0
	}, 
	staminaBar = {
		controlName = "ZO_PlayerAttributeStamina",
		active = true,
		position = "TOPLEFT",
		anchorPosition = "BOTTOM",
		anchorName = "ZO_PlayerAttributeHealth",
		width = 0,
		height = 0,
		offsetX = 0, 
		offsetY = 0
	},
		
}

NailDownGui.controlsToHandle = {
	"achievementTracker",
	"wykkydsToolbar",
	"miniMap",
	"switchBar",
	"ravaloxQT",
	"lootDrop",
	"das",
	"alertText",
	"healthBar",
	"magickaBar",
	"staminaBar",
	"chatContainer",
}

NailDownGui.attributeBarControls = {
	healthBar = {
		first = "AUI_PlayerFrame_Health", 
		second = "AUI_Tactical_PlayerFrame_Health",
		third = "TESO_PlayerFrame_Health",
		fourth = "ZO_PlayerAttributeHealth"
	},
	magickaBar = {  
		first = "AUI_PlayerFrame_Magicka",
		second = "AUI_Tactical_PlayerFrame_Magicka",
		third = "TESO_PlayerFrame_Magicka",
		fourth = "ZO_PlayerAttributeMagicka"
	},
	staminaBar = {
		first = "AUI_PlayerFrame_Stamina",
		second = "AUI_Tactical_PlayerFrame_Stamina",
		third = "TESO_PlayerFrame_Stamina",
		fourth = "ZO_PlayerAttributeStamina"
	}, 	
}


NailDownGui.controls = {
	miniMap = {
		first = "AUI_Minimap_MainWindow",
		second = "ZO_WorldMap",
	}
}

local function resizeControl(control, width, height)
	if nil ~= width and tonumber(width) > 0 then 
		control:SetWidth(width)
	end
	if nil ~= height and tonumber(height) > 0 then 
		control:SetHeight(height)
	end
end

function NailDownGui.UpdateControl(key)															-- needs to be global, is called from settings
	
	local controlName =  NDG.GetControlName(key)	
	local control = _G[controlName]

	if (not NDG.GetActive(key)) or (nil == controlName) or (nil == control) then return false end

	control:SetDrawLayer(NDG.GetDrawLayer(key))
	 
	resizeControl(control, NDG.GetSizeX(key), NDG.GetSizeY(key))	
	
	local position, anchorPosition, anchor = _G[NDG.GetPosition(key)], _G[NDG.GetAnchorPosition(key)], _G[NDG.GetAnchorName(key)]
	local offsetX, offsetY = NDG.GetXOffset(key), NDG.GetYOffset(key)
	
	control:ClearAnchors()
	control:SetAnchor(position, anchor, anchorPosition, offsetX, offsetY)
	
	return true
	
end

function NailDownGui.InitAttribBars()		

	local bars = NailDownGui.attributeBarControls
	
	if not (NDG.GetActive("healthBar") and LL.IsAddonEnabled("AUI")) then return end			-- do not do anything if we're not active	
	local control = nil
	for index, controlName in pairs(bars.healthBar) do 						-- first, find out which attributeBar we're using
		control = _G[controlName]	 
		if nil ~= control then
			NDG.SetControlName("healthBar", controlName)
			NDG.SetControlName("magickaBar", bars.magickaBar[index])
			NDG.SetControlName("staminaBar", bars.staminaBar[index])
		end
	end	
end

local function anchorChildren(key)

	local settingsArray = NailDownGui.settings[key]
	local controlName = settingsArray.controlName
	
	if nil == controlName then return end
	
	for _, entryName in pairs(NailDownGui.controlsToHandle) do
		if type(setting) == table then 
			if setting.anchorName == controlName then
				NailDownGui.UpdateControl(entryName)
			end
		end
	end

end

function tryReposition(key, counter)
	
	local settingsArray = NailDownGui.settings[key]
	
	-- break if addon not loaded
	if (nil ~= settingsArray.addOnName) and not (LL.IsAddonEnabled(addOnName)) then return end
	
	if nil == counter then counter = 1 end
	
	if counter < 3 and settingsArray.active then	
	
		if NailDownGui.UpdateControl(key) then 	-- if control exists, we'll do our job, try to reposition everything that anchors to it, and leave
			anchorChildren(key)
			return true 
		end											
		return zo_callLater(function() tryReposition(key, counter+1) end, 1000) 
				
	end	
	
end

local function setDrawLayer(control, layer)
	if nil == control then return end
	control:SetDrawLayer(layer)
end

function NailDownGui.handleChat()
	
	if NailDownGui.settings.chatStartMaximized then CHAT_SYSTEM:Maximize() end
	
	-- chat in background:
	if not NailDownGui.settings.chatInBackground then return end
	
	setDrawLayer(ZO_ChatWindow, 0)

	ZO_ChatWindow:SetDrawTier(0)
	ZO_ChatWindow:SetDrawLevel(0)
	
	if LL.IsAddonEnabled("wykkydsEnhancedChat") then
		setDrawLayer(_G["wykkydsChatFrameBackPanel"], 0)
		setDrawLayer(_G["wykkydsChatFrameBackPanel_bg"], 0)
	end

	-- make sure that the ingame menu is on top of everything
	ZO_GameMenu_InGame:SetDrawTier(2)
	ZO_SharedWideLeftPanelBackground:SetDrawLevel(1)
	
end

local function handleTbug()
	if nil ~= tbugGlobalInspector then 
		tbugGlobalInspector:SetClampedToScreen(NDG.GetActive("torchbug"))
	end
end

function NailDownGui.Work(continue)	

	if NailDownGui.settings.chatAlwaysMaximized or continue then 
		NailDownGui.handleChat()
	end
	
	-- NailDownGui.InitializeAttributeBars() 
	if not continue then return end
	
	for _, controlName in pairs(NailDownGui.controlsToHandle) do
		
		NailDownGui.UpdateControl(controlName) 
		anchorChildren(controlName)
		-- tryReposition(controlName)	
	end
	
	handleTbug()

end

function NailDownGui.SlashCommand(input)
	if(input == "") then
		NailDownGui.Work()
	else
		LAM:OpenToPanel(NailDownGui.SettingsPanel)
	end
end

-- initialization stuff
function NailDownGui.Initialize(eventCode, addOnName)

	if (addOnName ~= "NailDownGui") then return end
	
	NailDownGui.settings = ZO_SavedVars:NewAccountWide("NailDownGui_SavedVariables", 1, nil, defaults)
	NailDownGui.CreateSettings(NailDownGui.settings, defaults)
	
	SLASH_COMMANDS["/ndg"] = NailDownGui.SlashCommand
	zo_callLater(function() NailDownGui.Work() end, 1000) 
	
end

function NailDownGui.OnScreenResized()
	NailDownGui.Work(NailDownGui.settings.resizeOnSizeChange)
end

function NailDownGui.OnPlayerInitialized()
	NailDownGui.Work(NailDownGui.settings.resizeOnPlayerInitialized)
end

function NailDownGui.OnGuiLoaded()
	NailDownGui.Work(NailDownGui.settings.resizeOnGuiLoad)
end

function NailDownGui.OnActionLayer()
	NailDownGui.Work(NailDownGui.settings.onActionLayer)
end

function NailDownGui.OnSlashCommand()
	NailDownGui.Work()
end
					
EVENT_MANAGER:RegisterForEvent("NailDownGuiResized",  			EVENT_SCREEN_RESIZED, function(...) 				NailDownGui.OnScreenResized(...) end)
EVENT_MANAGER:RegisterForEvent("NailDownGuiPlayerInitialised",  EVENT_PLAYER_ACTIVATED, function(...) 				NailDownGui.OnPlayerInitialized(...) end)
EVENT_MANAGER:RegisterForEvent("NailDownGuiGuiLoadingProgress", EVENT_UPDATE_GUI_LOADING_PROGRESS, function(...) 	NailDownGui.OnGuiLoaded(...) end)
EVENT_MANAGER:RegisterForEvent("NailDownActionLayerPushed",  	EVENT_ACTION_LAYER_PUSHED, function(...) 			NailDownGui.OnActionLayer(...) end)

EVENT_MANAGER:RegisterForEvent("NailDownGuiLoaded", 			EVENT_ADD_ON_LOADED, function(...) 					NailDownGui.Initialize(...) 	end)
EVENT_MANAGER:RegisterForEvent("NailDownGuiLoaded", 			EVENT_ADD_ON_LOADED, function(...) 					zo_callLater(function() NDG.InitAttribBars() end, 500)  	end)
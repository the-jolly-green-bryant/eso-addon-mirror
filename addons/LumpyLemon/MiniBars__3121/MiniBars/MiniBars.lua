-------------------------------------------------------------------------------
-- MINIBARS v0.2
-------------------------------------------------------------------------------

	--[[
	
	Update Notes v0.3:
	1. /mbcolor slash command for color blind settings.
	2. no more reload ui for changes.
	3. some design improvements
	4. some tweaks to improve performance 

	Update Notes v0.2:
	1. /mbforcescale slash command removed because it's not really necessary.
	2. better and faster functions to handle scene changes.
	3. simplified slash commands 
	4. no more lib dependency

	]]--

MiniBars = {}
local MiniBars = MiniBars
local EM = EVENT_MANAGER
MiniBars.name = "MiniBars"
MiniBars.version = 0.1
MiniBars.activeLayerIndex = 0
MiniBars.default = {
	Width = 160,
	offSetX = 0,
	offSetY = -10,
	hpcolor = 'EC271B',
	shcolor = 'FFFFFF',
	macolor = '0064B1',
	stcolor = '06A841',
	lock = false,
	size = 1,
}

function MiniBars:Initialize()
	MiniBars.savedVariables = ZO_SavedVars:New("MiniBarsSavedVariables", MiniBars.version, nil, MiniBars.default)
	self.RestoreSettings()
-------------------------------------------------------------------------------
-- REGISTER ADDON
-------------------------------------------------------------------------------

	EM:RegisterForEvent(self.name, EVENT_ADD_ON_LOADED, self.OnAddOnLoaded)
	EM:RegisterForEvent(self.name, EVENT_POWER_UPDATE, self.UpdateResource)
	EM:RegisterForEvent(self.name, EVENT_ACTION_LAYER_POPPED, self.OnActionLayerChange)
	EM:RegisterForEvent(self.name, EVENT_ACTION_LAYER_PUSHED, self.OnActionLayerChange)
	EM:RegisterForEvent(moduleName, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, self.OnVisualizationAdded )
    EM:RegisterForEvent(moduleName, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, self.OnVisualizationRemoved )
    EM:RegisterForEvent(moduleName, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, self.OnVisualizationUpdated )

end

-- initialize
function MiniBars.OnAddOnLoaded(event, addonName)
	if addonName == MiniBars.name then

	--[[ ZO_PlayerAttributeHealth:SetHidden(true)
		 ZO_PlayerAttributeMagicka:SetHidden(true)
		 ZO_PlayerAttributeStamina:SetHidden(true) 
		 Not sure yet if this should be default. ]]--

		MiniBars:Initialize()

	end
end

-------------------------------------------------------------------------------
-- HELPERS
-------------------------------------------------------------------------------

-- function to move
function MiniBars.OnBarMoveDone()
	MiniBars.savedVariables.offSetX = MiniBarsWindow:GetLeft()
	MiniBars.savedVariables.offSetY = MiniBarsWindow:GetTop()
end

-- function to hide
function MiniBars.OnActionLayerChange(event, layerIndex, activeLayerIndex)
	MiniBars.activeLayerIndex = activeLayerIndex
	MiniBarsWindow:SetHidden(MiniBars.activeLayerIndex > 2)
end

-- function to convert hex to rgb

function hex2rgb (hex)
    local hex = hex:gsub("#","")
    if hex:len() == 3 then
      return (tonumber("0x"..hex:sub(1,1))*17)/255, (tonumber("0x"..hex:sub(2,2))*17)/255, (tonumber("0x"..hex:sub(3,3))*17)/255
    else
      return tonumber("0x"..hex:sub(1,2))/255, tonumber("0x"..hex:sub(3,4))/255, tonumber("0x"..hex:sub(5,6))/255
    end
end

-------------------------------------------------------------------------------
-- SLASH COMMANDS
-------------------------------------------------------------------------------

-- function to resize minibars with mbscale command
function MiniBars.Scale(newValue)
	-- checks for correct entry. 
	if newValue == '' or newValue > '2' or newValue < '0.5' then
		df('MiniBars: Requires numeric entry between 0.5 and 2 after command. e.g. /mbscale 1.5')
	else
	-- changes size and reloads.
		MiniBars.savedVariables.Width = 160 * newValue
		MiniBars.RestoreSettings()
		df('Minibars: Scale value changed to %s', newValue)
	end
end

-- function to restore default settings
function MiniBars.Default()
		
	MiniBars.savedVariables.Width = 160
	MiniBars.savedVariables.offSetX = 0
	MiniBars.savedVariables.offSetY = -10
	MiniBars.savedVariables.hpcolor = 'EC271B'
	MiniBars.savedVariables.shcolor = 'FFFFFF'
	MiniBars.savedVariables.macolor = '0064B1'
	MiniBars.savedVariables.stcolor = '06A841'
	MiniBarsWindow:SetMovable(true)
	MiniBarsWindow:SetMouseEnabled(true)
	MiniBars.savedVariables.lock = true
	MiniBars.RestoreSettings()
	df('MiniBars: Settings have been reset to default.')

end

-- function to change color mode
function MiniBars.Colormode(newValue)
	
	if newValue == 'n' then
		MiniBars.savedVariables.hpcolor = 'EC271B'
		MiniBars.savedVariables.shcolor = 'FFFFFF'
		MiniBars.savedVariables.macolor = '0064B1'
		MiniBars.savedVariables.stcolor = '06A841'
		MiniBars.RestoreSettings()
		df('MiniBars: Colorblind mode Normal Vision')
	elseif newValue == 'p' then
		MiniBars.savedVariables.hpcolor = '704D1C'
		MiniBars.savedVariables.shcolor = 'FFFFFF'
		MiniBars.savedVariables.macolor = '0064B1'
		MiniBars.savedVariables.stcolor = 'DB9940'
		MiniBars.RestoreSettings()
		df('MiniBars: Colorblind mode Protan')
	elseif newValue == 'd' then
		MiniBars.savedVariables.hpcolor = '99660C'
		MiniBars.savedVariables.shcolor = 'FFFFFF'
		MiniBars.savedVariables.macolor = '0064B1'
		MiniBars.savedVariables.stcolor = 'BD8745'
		MiniBars.RestoreSettings()
		df('MiniBars: Colorblind mode Deutran')
	elseif newValue == 't' then
		MiniBars.savedVariables.hpcolor = 'EE1646'
		MiniBars.savedVariables.shcolor = 'FFFFFF'
		MiniBars.savedVariables.macolor = '007385'
		MiniBars.savedVariables.stcolor = '5B97A2'
		MiniBars.RestoreSettings()
		df('MiniBars: Colorblind mode Tritan')
	else 
		df('MiniBars: n: Normal Vision, p: Protan, d: Deutran, t: Tritan')
	end

end

-- function to lock bar position
function MiniBars.Lock()
	
	if MiniBars.savedVariables.lock then
	MiniBarsWindow:SetMovable(false)
	MiniBarsWindow:SetMouseEnabled(false)
	MiniBars.savedVariables.lock = false
	df('MiniBars: Bar position locked.')
	else 
	MiniBarsWindow:SetMovable(true)
	MiniBarsWindow:SetMouseEnabled(true)
	MiniBars.savedVariables.lock = true
	df('MiniBars: Bar position unlocked.')
	end

end

SLASH_COMMANDS["/mbscale"] = MiniBars.Scale
SLASH_COMMANDS["/mbreset"] = MiniBars.Default
SLASH_COMMANDS["/mbcolor"] = MiniBars.Colormode
SLASH_COMMANDS["/mblock"] = MiniBars.Lock

-------------------------------------------------------------------------------
-- VISUALS
-------------------------------------------------------------------------------

function MiniBars.RestoreSettings()

	-- Load colors 

	MiniBarsWindowStatusBarHealth:SetColor(hex2rgb(MiniBars.savedVariables.hpcolor)) -- Health color
	MiniBarsWindowStatusBarShield:SetColor(hex2rgb(MiniBars.savedVariables.shcolor)) -- Shield color
	MiniBarsWindowStatusBarMagicka:SetColor(hex2rgb(MiniBars.savedVariables.macolor)) -- Magicka color
	MiniBarsWindowStatusBarStamina:SetColor(hex2rgb(MiniBars.savedVariables.stcolor)) -- Stamina color

	-- Load variables

	MiniBarsWindow:ClearAnchors()
	MiniBarsWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, MiniBars.savedVariables.offSetX, MiniBars.savedVariables.offSetY) -- Position
	MiniBarsWindow:SetDimensions(MiniBars.savedVariables.Width, (MiniBars.savedVariables.Width / 8 * 3)) -- Total window size
	MiniBarsWindowStatusBarShield:SetHidden(true) -- Shield is hidden

	-- Status bar size

	MiniBarsWindowStatusBarShield:SetDimensions(MiniBars.savedVariables.Width, MiniBars.savedVariables.Width / 8) -- Shield overlay
	MiniBarsWindowStatusBarHealth:SetDimensions(MiniBars.savedVariables.Width, MiniBars.savedVariables.Width / 8) -- Health status bar size	
	MiniBarsWindowStatusBarMagicka:SetDimensions(MiniBars.savedVariables.Width, MiniBars.savedVariables.Width / 8) -- Magicka status bar size
	MiniBarsWindowStatusBarStamina:SetDimensions(MiniBars.savedVariables.Width, MiniBars.savedVariables.Width / 8) -- Stamina status bar size	

	-- Backdrop size

	MiniBarsWindowBackdropHealth:SetDimensions(MiniBars.savedVariables.Width, MiniBars.savedVariables.Width / 8) -- Health background size
	MiniBarsWindowBackdropMagicka:SetDimensions(MiniBars.savedVariables.Width, MiniBars.savedVariables.Width / 8) -- Magicka background size
	MiniBarsWindowBackdropStamina:SetDimensions(MiniBars.savedVariables.Width, MiniBars.savedVariables.Width / 8) -- Stamina background size

	-- Status bar position

	MiniBarsWindowStatusBarMagicka:SetAnchor(TOPLEFT, MiniBarsWindow, TOPLEFT, 0, (MiniBars.savedVariables.Width / 8)) -- Magicka status bar position
	MiniBarsWindowStatusBarStamina:SetAnchor(TOPLEFT, MiniBarsWindow, TOPLEFT, 0, (MiniBars.savedVariables.Width / 8 * 2)) -- Stamina status bar position

	-- Backdrop position

	MiniBarsWindowBackdropMagicka:SetAnchor(TOPLEFT, MiniBarsWindow, TOPLEFT, 0, (MiniBars.savedVariables.Width / 8)) -- Magicka background position
	MiniBarsWindowBackdropStamina:SetAnchor(TOPLEFT, MiniBarsWindow, TOPLEFT, 0, (MiniBars.savedVariables.Width / 8 * 2)) -- Stamina background position
	
	-- Update Resource

	MiniBars.UpdateResource()

end

function MiniBars.UpdateResource()

	local health_current, health_max, health_effectiveMax = GetUnitPower("player", POWERTYPE_HEALTH)
	local magicka_current, magicka_max, magicka_effectiveMax = GetUnitPower("player", POWERTYPE_MAGICKA)
	local stamina_current, stamina_max, stamina_effectiveMax = GetUnitPower("player", POWERTYPE_STAMINA)
  
	MiniBarsWindowStatusBarHealth:SetMinMax(0, health_max)
	MiniBarsWindowStatusBarHealth:SetValue(health_current)
  
	MiniBarsWindowStatusBarMagicka:SetMinMax(0, magicka_max)
	MiniBarsWindowStatusBarMagicka:SetValue(magicka_current)
  
	MiniBarsWindowStatusBarStamina:SetMinMax(0, stamina_max)
	MiniBarsWindowStatusBarStamina:SetValue(stamina_current)

end

function MiniBars.SetBarSize(Width, Height)

	MiniBarsWindowBackdropHealth:SetDimensions(Width, Width / 8)
	MiniBarsWindowStatusBarHealth:SetDimensions(Width, Width / 8)
	MiniBarsWindowBorderHealth:SetDimensions(Width, Width / 8)
	
	MiniBarsWindowStatusBarShield:SetDimensions(Width, Width / 8)
	
	MiniBarsWindowBackdropMagicka:SetDimensions(Width, Width / 8)
	MiniBarsWindowStatusBarMagicka:SetDimensions(Width, Width / 8)
	MiniBarsWindowBorderMagicka:SetDimensions(Width, Width / 8)
	
	MiniBarsWindowBackdropStamina:SetDimensions(Width, Width / 8)
	MiniBarsWindowStatusBarStamina:SetDimensions(Width, Width / 8)
	MiniBarsWindowBorderStamina:SetDimensions(Width, Width / 8)

end

function MiniBars.OnVisualizationAdded(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)

    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING and unitTag == 'player' then
		MiniBarsWindowStatusBarShield:SetMinMax(0, maxValue)
		MiniBarsWindowStatusBarShield:SetValue(value)
		MiniBarsWindowStatusBarShield:SetHidden(false)
    end

end

function MiniBars.OnVisualizationRemoved(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)

    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING and unitTag == 'player' then
		MiniBarsWindowStatusBarShield:SetMinMax(0, maxValue)
		MiniBarsWindowStatusBarShield:SetValue(0)
		MiniBarsWindowStatusBarShield:SetHidden(true)
    end

end

function MiniBars.OnVisualizationUpdated(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue)
	
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING and unitTag == 'player' then
		MiniBarsWindowStatusBarShield:SetMinMax(0, newMaxValue)
		MiniBarsWindowStatusBarShield:SetValue(newValue)
		MiniBarsWindowStatusBarShield:SetHidden(true)
    end

end

-------------------------------------------------------------------------------
-- EVENT HANDLER FUNCTION
-------------------------------------------------------------------------------

EM:RegisterForEvent(MiniBars.name, EVENT_ADD_ON_LOADED, MiniBars.OnAddOnLoaded)
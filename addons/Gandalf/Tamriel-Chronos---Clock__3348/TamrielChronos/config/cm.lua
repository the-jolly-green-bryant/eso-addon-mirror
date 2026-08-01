-----------------------------------------------------------------------------
-- 					      									               --
-- 	Title:		 Tamriel Chronos                    					   --
--	Description: Tamriel Time and astronomical data                        --
--	Author: 	 Gandalf (@Gandalf2675)									   --
-- 					      									               --
-----------------------------------------------------------------------------

TaChronos.cm = TaChronos.cm or {}
local cm     = TaChronos.cm

cm.varVersion      = 2
cm.varName         = "TamrielChronosVar"
cm.config          = {}
cm.defaults        = {
			 	        mode         = "h24",  
				        clocks       = {},
				        conv         = {p=CENTER, rp=CENTER, x=0, y=-200},
				        showHolidays = true,
				        hide         = false,
				        timeLimit    = 0,
		  	         }
-- Fonts
cm.fonts = {
			   ["Consolas"]					= "EsoUI/Common/Fonts/consola.ttf",
			   ["Futura Condensed"]			= "EsoUI/Common/Fonts/FTN57.otf",
			   ["Futura Condensed Bold"]	= "EsoUI/Common/Fonts/FTN87.otf",
			   ["Futura Condensed Light"]	= "EsoUI/Common/Fonts/FTN47.otf",
			   ["ProseAntique"]				= "EsoUI/Common/Fonts/ProseAntiquePSMT.otf",
			   ["Skyrim Handwritten"]		= "EsoUI/Common/Fonts/Handwritten_Bold.otf",
	           ["Trajan Pro"]				= "EsoUI/Common/Fonts/trajanpro-regular.otf",
			   ["Univers 55"]				= "EsoUI/Common/Fonts/univers55.otf",
			   ["Univers 57"]				= "EsoUI/Common/Fonts/univers57.otf",
		       ["Univers 67"]				= "EsoUI/Common/Fonts/univers67.otf",
		   }
						  
local LAM          = LibAddonMenu2
local modesT       = {}
local modesIcn     = {} 
local modesIcnIdx  = {}


local function setScale(scale)
	cm.config.clocks[cm:GetClockMode()].scale = scale/100
	local clock = TaChronos.clocks[cm:GetClockMode()]
	clock.SetScale(clock, scale/100)
end

local function getScale()
	return cm.config.clocks[cm:GetClockMode()].scale
end

local function setSecs(val)
	cm.config.clocks[cm:GetClockMode()].secs = val
end

local function getSecs()
	return cm.config.clocks[cm:GetClockMode()].secs
end

local function isDisabledSecs()
	return TaChronos.clocks[cm:GetClockMode()]:IsDisabledSecs()
end

local function setTc(r,g,b,a)
	local c = cm.config.clocks[cm:GetClockMode()].tc
	c.r, c.g, c.b, c.a = r, g, b, a
	local clock = TaChronos.clocks[cm:GetClockMode()]
	clock.time:SetColor(c.r, c.g, c.b, c.a)
end

local function getFont()
	return cm.config.clocks[cm:GetClockMode()].font.type
end

local function setFont(val)
	local font = cm.config.clocks[cm:GetClockMode()].font
	font.type  = val
	TaChronos.clocks[cm:GetClockMode()]:UpdateFont()
end

local function isDisabledFont()
	return TaChronos.clocks[cm:GetClockMode()]:IsDisabledFont()
end

local function getTc()
	local c = cm.config.clocks[cm:GetClockMode()].tc
	return c.r, c.g, c.b, c.a
end

local function isDisabledTc()
	return TaChronos.clocks[cm:GetClockMode()]:IsDisabledTc()
end

local function setReal(val)
	cm.config.clocks[cm:GetClockMode()].real = val
end

local function getReal()
	return cm.config.clocks[cm:GetClockMode()].real
end

local function isDisabledReal()
	return TaChronos.clocks[cm:GetClockMode()]:IsDisabledReal()
end

local function buildDefaults()
	for k,p in pairs(TaChronos.clocks) do
		ZO_DeepTableCopy(p.defaults, cm.defaults.clocks)
	end
end

local function buildModes()
	local t =  {}
	for k,p in pairs(TaChronos.clocks) do table.insert(t ,p.longName) end
	table.sort(t)
	for k,ln in pairs(t) do
		for k,p in pairs(TaChronos.clocks) do
			if p.longName == ln then
				table.insert(modesT,     p.longName..p.description)
				table.insert(modesIcn,   p.choiceIcn)
				modesIcnIdx[p.choiceIcn] = p.name
			end
		end
	end
end

local function LAMBuild()
	local cnf = cm.config
	-- Build menu
	local panelData = {
		type                = "panel",
		name                = TaChronos.ADDON_TITLE,
		author              = TaChronos.ADDON_AUTHOR,
		version             = tostring(TaChronos.ADDON_VERSION),
		registerForRefresh  = true,
		registerForDefaults = false,
	}
	LAM:RegisterAddonPanel("CHRONOS_OPTIONS", panelData)
	
	local optionsData = {
		{
			type = "header",
			name = GetString(SI_TACHRONOS_TITLE_CONF),
		},	
		{
			type            = "iconpicker",
    		name 			= GetString(SI_TACHRONOS_MODE),
			tooltip         = GetString(SI_TACHRONOS_MODE_tt), 
    		choices         = modesIcn,
    		choicesTooltips = modesT,
    		iconSize        = 128, 
            maxColumns      = 1,
			visibleRows 	= 3,
            getFunc         = function() return TaChronos.clocks[cm:GetClockMode()].choiceIcn end,
    		setFunc         = function(val) TaChronos:ResetZoom() cnf.mode = modesIcnIdx[val]  TaChronos:RefreshClocks() end,
		}, 	
        {
			type          = "slider",
			name          = GetString(SI_TACHRONOS_SCALE),
			tooltip       = GetString(SI_TACHRONOS_SCALE_tt), 
    		min           = 45,
    		max           = 200,
    		getFunc       = function() return zo_floor(100*getScale()) end,
    		setFunc       = function (val) setScale(val) end,
		},     	
    	{
			type 		  = "checkbox",
			name 		  = GetString(SI_TACHRONOS_SECS),
			getFunc 	  = function() return getSecs() end,
			setFunc 	  = function(val) setSecs(val) end,
			tooltip 	  = GetString(SI_TACHRONOS_SECS_tt),
			disabled      = function() return isDisabledSecs() end,
		},  
		{
			type 		  = "checkbox",
			name 		  = GetString(SI_TACHRONOS_REAL),
			getFunc 	  = function() return getReal() end,
			setFunc 	  = function(val) setReal(val) end,
			tooltip 	  = GetString(SI_TACHRONOS_REAL_tt),
			disabled      = function() return isDisabledReal() end,
		},  	  	  
		{
			type 		  = "dropdown",
			name 		  = GetString(SI_TACHRONOS_TIME_FONT),
			tooltip    	  = GetString(SI_TACHRONOS_TIME_FONT_tt),
            choices       = cm:GetFontList(),	
			getFunc 	  = function() return getFont() end,	
			setFunc		  = function(val) setFont(val) end,
			sort          = "name-up",
			disabled      = function() return isDisabledFont() end,
		}, 		
		{
			type 		  = "colorpicker",
			name 		  = GetString(SI_TACHRONOS_TIME_COLOR),
			tooltip    	  = GetString(SI_TACHRONOS_TIME_COLOR_tt),
			getFunc 	  = function() return getTc() end,	
			setFunc		  = function(r,g,b,a) setTc(r,g,b,a) end,
			disabled      = function() return isDisabledTc() end,
		}, 
		{
			type 		  = "checkbox",
			name 		  = GetString(SI_TACHRONOS_SHOW_HOLIDAYS),
			tooltip    	  = GetString(SI_TACHRONOS_SHOW_HOLIDAYS_tt),
			getFunc 	  = function() return cnf.showHolidays end,	
			setFunc		  = function(val) cnf.showHolidays = val end,
		}, 
        {
			type          = "slider",
			name          = GetString(SI_TACHRONOS_HEALTH),
			tooltip       = GetString(SI_TACHRONOS_HEALTH_tt), 
    		min           = 0,
    		max           = 120,
    		getFunc       = function() return cnf.timeLimit end,
    		setFunc       = function (val) cnf.timeLimit = val TaChronos.health:Initialize() end,
		},     	
		{
			type 		  = "checkbox",
			name 		  = GetString(SI_TACHRONOS_HIDE),
			tooltip    	  = GetString(SI_TACHRONOS_HIDE_tt),
			getFunc 	  = function() return cnf.hide end,	
			setFunc		  = function(val) cnf.hide = val end,
		}, 
		{
            type          = "divider",
            width         = "full", -- or "half" (optional)
            height        = 10, -- (optional)
            alpha         = 0, -- (optional)
        }, 
		{
			type          = "header",
			name          = GetString(SI_TACHRONOS_HELP),
		},
		{
    		type   		  = "description",
    		reference     = "CHRONOS_HELP",
    		text 		  = GetString(SI_TACHRONOS_HELP_F_DESC),
    		width 		  = "full", 
 		},			
	}
	LAM:RegisterOptionControls("CHRONOS_OPTIONS", optionsData)	
end

local function LAMPimp()
	local x, y = -80, -60
	
	-- make room for the logo
	CHRONOS_OPTIONS.label:SetText("                   "..CHRONOS_OPTIONS.label:GetText())
	CHRONOS_OPTIONS.info:SetText("                                "..CHRONOS_OPTIONS.info:GetText())

	-- set our logo
	local masser, secunda = TaChronos.moon:GetData()
	CHRONOS_OPTIONS.masser = CreateControl(nil, CHRONOS_OPTIONS, CT_TEXTURE)
	CHRONOS_OPTIONS.masser:SetAnchor(TOPLEFT, CHRONOS_OPTIONS, TOPLEFT, 0, 10)
	CHRONOS_OPTIONS.masser:SetAlpha(1)
	CHRONOS_OPTIONS.masser:SetTexture(masser)
	CHRONOS_OPTIONS.masser:SetDimensions(48, 48)
	CHRONOS_OPTIONS.masser:SetDrawLayer(DL_CONTROLS)
	--
	CHRONOS_OPTIONS.secunda = CreateControl(nil, CHRONOS_OPTIONS, CT_TEXTURE)
	CHRONOS_OPTIONS.secunda:SetAnchor(TOPLEFT, CHRONOS_OPTIONS, TOPLEFT, 40, -12)
	CHRONOS_OPTIONS.secunda:SetAlpha(1)
	CHRONOS_OPTIONS.secunda:SetTexture(secunda)
	CHRONOS_OPTIONS.secunda:SetDimensions(48, 48)
	CHRONOS_OPTIONS.secunda:SetDrawLayer(DL_CONTROLS)
	
	-- Use a smaller font for the help text	
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function (control)
    	if CHRONOS_HELP and not TaChronos.fontPimpHelp then 
    		CHRONOS_HELP.desc:SetFont("$(MEDIUM_FONT)|16)|soft-shadow-thin")
    		TaChronos.fontPimpHelp = true
    	end
	end)
end

function cm:Initialize()
	buildDefaults()
	buildModes()
	self.config = ZO_SavedVars:NewAccountWide(self.varName, self.varVersion, nil, self.defaults, nil)
	LAMBuild()	-- LibAddonMenu -> define addon settings
	LAMPimp()   -- apply some magic, we are Gandalf after all :)
end

function cm:GetClockConf(clock)
	return self.config.clocks[clock]
end

function cm:GetClockMode()
	return self.config.mode
end

function cm:GetTimeLimit()
	return cm.config.timeLimit
end

function cm:GetFontList()
	local list = {}
	for k,f in pairs(self.fonts) do
		table.insert(list,k)
	end
	return list
end

function cm:GetFontPath(type)
	local path = self.fonts[type] or self.font["Univers 57"]
	return path
end

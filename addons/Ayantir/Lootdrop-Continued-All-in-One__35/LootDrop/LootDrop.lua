------------------------------------------------
-- Loot Drop - show me what I got
--
-- @author Pawkette ( pawkette.heals@gmail.com )
------------------------------------------------

--Local constants--------------------------------------------------------------
local ADDON_VERSION = "3.5"
local ADDON_NAME = "LootDrop"
local LootDrop_sDefRushmik          = "|cD3B830Rushmik|r"
local LootDrop_sDefPawkette         = "|cFF66CCPawkette|r"
local LootDrop_sDefDefault          = "Default"
local LootDrop_sListBoxNo           = "No"
local LootDrop_sListBoxStacked      = "Stacked"
local LootDrop_sListBoxNotStacked   = "Not Stacked"
local LootDrop_sListBoxStandard     = "Standard"
local LootDrop_sListBoxExtended     = "Extended"
--Libraries--------------------------------------------------------------------
local CBM = CALLBACK_MANAGER
local LAM2 = LibStub("LibAddonMenu-2.0")
if ( not LAM2 ) then return end
--Icons------------------------------------------------------------------------
local LootDrop_sApIcon              = [[/lootdrop/textures/ap_up.dds]]
local LootDrop_sXpIcon              = [[/lootdrop/textures/xp_up.dds]]
local LootDrop_sTVIcon              = [[esoui/art/icons/icon_telvarstone.dds]]
local LootDrop_sSkillXpIcon         = [[/lootdrop/textures/skill_up.dds]]

local LootDrop_sAnvilXpIcon         = [[esoui/art/icons/servicemappins/servicepin_smithy.dds]]
local LootDrop_sWoodXpIcon          = [[esoui/art/icons/servicemappins/servicepin_woodworking.dds]]
local LootDrop_sAlchimyXpIcon       = [[esoui/art/icons/servicemappins/servicepin_alchemy.dds]]
local LootDrop_sClothierXpIcon      = [[esoui/art/icons/servicemappins/servicepin_outfitter.dds]]
local LootDrop_sEnchanterXpIcon     = [[esoui/art/icons/servicemappins/servicepin_enchanting.dds]]
local LootDrop_sProvisioningXpIcon  = [[esoui/art/icons/servicemappins/servicepin_inn.dds]]

local LootDrop_sMagesGuildXpIcon    = [[esoui/art/icons/servicemappins/servicepin_magesguild.dds]]
local LootDrop_sFighterGuildXpIcon  = [[esoui/art/icons/servicemappins/servicepin_fightersguild.dds]]
local LootDrop_sOthersGuildXpIcon   = [[esoui/art/icons/poi/poi_groupinstance_complete.dds]]
local LootDrop_sBooksXpIcon         = [[esoui/art/mainmenu/menubar_journal_up.dds]]
local LootDrop_sFenceXpIcon         = [[/esoui/art/icons/servicemappins/servicepin_fence.dds]]
local LootDrop_sThievesXpIcon       = [[/esoui/art/icons/servicemappins/servicepin_thievesguild.dds]]
local LootDrop_sBrotherhoodXpIcon   = [[/esoui/art/icons/poi/poi_darkbrotherhood_complete.dds]]

local LootDrop_sBgTexture           = [[/lootdrop/textures/default_bg.dds]]
local LootDrop_sRarityTexture       = [[/lootdrop/textures/default_rarity.dds]]
--Default Values for SavedVars-------------------------------------------------
local LootDrop_Defaults =
{
	displayduration	= 10,
	experience			= LootDrop_sListBoxExtended,
	coin					= LootDrop_sListBoxExtended,
	loot					= true,
	alliance				= LootDrop_sListBoxExtended,
	telvar				= LootDrop_sListBoxExtended,
	width					= 220,
	height				= 45,
	padding				= 5,
	sListStyle			= LootDrop_sDefDefault,
	FontSize				= 18,
	rarity				= true,
	MoveUp				= true,
	lootdrop_x			= 0,
	lootdrop_y			= 0,
	lootdrop_lock		= true,
	DbgLog				= false,
	DbgLogTime			= false,
	DbgLogItemStyle	= true,
	DbgLogXp				= true,
	DbgLogGold			= true,
	DbgLogTag			= false,
	DbgLogOthers		= false,
	DbgLogOthersQlty	= ITEM_QUALITY_NORMAL,
	Junk					= false,
	mailloot				= true,
	nameloot				= true,
	stackloot			= true,
	styleloot			= false,
	SkillXp				= LootDrop_sListBoxNotStacked, 	--craft
	Guilds				= LootDrop_sListBoxStacked, 	   --guild reputation
	Books					= LootDrop_sListBoxNotStacked,	--book knowledge
	Fence					= LootDrop_sListBoxStacked		--Fence skillline
}
--Local Functions--------------------------------------------------------------
local tinsert           = table.insert
local tremove           = table.remove
local zo_strsplit       = zo_strsplit
local ZO_ColorDef       = ZO_ColorDef
local zo_parselink      = ZO_LinkHandler_ParseLink
local zo_min            = zo_min
local CBM               = CALLBACK_MANAGER
local _
--LootDrop Objects defined in other files--------------------------------------
local LootDropFade      = LootDropFade
local LootDropSlide     = LootDropSlide
local LootDropPop       = LootDropPop
-------------------------------------------------------------------------------
--- Flags for updating UI aspects
local DirtyFlags =
{
	LAYOUT = 1 -- we've added or removed a droppable
}

--LootDropPool-----------------------------------------------------------------
local LootDropPool = ZO_Object:Subclass()
-------------------------------------------------------------------------------
function LootDropPool:New()
	return ZO_Object.New( self )
end
-------------------------------------------------------------------------------
function LootDropPool:Initialize( create, reset )
	self._create    = create
	self._reset     = reset
	self._active    = {}
	self._inactive  = {}
	self._controlId = 0
end
-------------------------------------------------------------------------------
function LootDropPool:GetNextId()
	self._controlId = self._controlId + 1
	return self._controlId
end
-------------------------------------------------------------------------------
function LootDropPool:Active()
	return self._active
end
-------------------------------------------------------------------------------
function LootDropPool:Acquire()
	local result = nil
	if ( #self._inactive > 0 ) then
		result = tremove( self._inactive, 1 )
	else
		result = self._create()
	end

	tinsert( self._active, result )
	return result, #self._active
end
-------------------------------------------------------------------------------
function LootDropPool:Get( key )
	if ( not key or type( key ) ~= 'number' or key > #self._active ) then
		return nil
	end

	return self._active[ key ]
end
-------------------------------------------------------------------------------
function LootDropPool:Release( object )
	local i = 1
	while( i <= #self._active ) do
		if ( self._active[ i ] == object ) then
			self._reset( object, i )
			tinsert( self._inactive, tremove( self._active, i ) )
			break
		else
			i = i + 1 
		end
	end
end
-------------------------------------------------------------------------------
function LootDropPool:ReleaseAll()
	for i=#self._active,1,-1 do 
		tinsert( self._inactive, tremove( self._active, i ) )
	end
end
-------------------------------------------------------------------------------



--LootDropConfig---------------------------------------------------------------
local LootDropConfig                   = ZO_Object:Subclass()
--Constants--------------------------------------------------------------------
LootDropConfig.EVENT_TOGGLE_XP         = 'LOOTDROP_TOGGLE_XP'
LootDropConfig.EVENT_TOGGLE_SKILL_XP   = 'LOOTDROP_TOGGLE_SKILL_XP'
LootDropConfig.EVENT_TOGGLE_COIN       = 'LOOTDROP_TOGGLE_COIN'
LootDropConfig.EVENT_TOGGLE_LOOT       = 'LOOTDROP_TOGGLE_LOOT'
LootDropConfig.EVENT_TOGGLE_MAIL_LOOT  = 'LOOTDROP_TOGGLE_MAIL_LOOT'
LootDropConfig.EVENT_TOGGLE_AP         = 'LOOTDROP_TOGGLE_AP'
LootDropConfig.EVENT_TOGGLE_TV         = 'LOOTDROP_TOGGLE_TV'
LootDropConfig.EVENT_TOGGLE_JUNK       = 'LOOTDROP_TOGGLE_JUNK'
LootDropConfig.EVENT_TOGGLE_DEBUGLOG   = 'LOOTDROP_TOGGLE_DEBUGLOG'
LootDropConfig.EVENT_TOGGLE_STYLE      = 'LOOTDROP_TOGGLE_STYLE'
LootDropConfig.EVENT_TOGGLE_LOCK       = 'LOOTDROP_TOGGLE_LOCK'
LootDropConfig.EVENT_TOGGLE_RARITY     = 'LOOTDROP_TOGGLE_RARITY'
LootDropConfig.EVENT_TOGGLE_MOVEUP     = 'LOOTDROP_TOGGLE_MOVEUP'
LootDropConfig.EVENT_CHANGE_DIMENSIONS = 'LOOTDROP_CHANGE_DIMENSIONS'
-------------------------------------------------------------------------------
function LootDropConfig:New( ... )
	local result = ZO_Object.New( self )
	result:Initialize( ... )
	return result
end
-------------------------------------------------------------------------------
function LootDropConfig:Initialize( db )
	self.db = db
	
	local panelData = {
		type = "panel",
		name = ADDON_NAME,
		displayName = ADDON_NAME .. " continued",
		author = "|cFF66CCPawkette|r, |cAA0000Flagrick|r & Ayantir",
		version = ADDON_VERSION,
		slashCommand = "/lootdrop",
		registerForRefresh = true,
		registerForDefaults = true,
		website = "http://www.esoui.com/downloads/info35-LootdropContinuedAllinOne.html"
	}

	LAM2:RegisterAddonPanel(ADDON_NAME, panelData)

	--local variables
	local qualityChoices = {}
	local reverseQualityChoices = {}
	for i = 0, ITEM_QUALITY_LEGENDARY do
		local color = GetItemQualityColor(i)
		local qualName = color:Colorize(GetString("SI_ITEMQUALITY", i))
		qualityChoices[i] = qualName
		reverseQualityChoices[qualName] = i
	end
	
	local optionsTable = {
		------------GENERAL--------------
		{
			type = "header",
			name = "General",
			width = "full",
		},
		{
			type = "dropdown",
			name = "Experience",
			tooltip = "Should we show experience gains ?",
			choices = {LootDrop_sListBoxNo, LootDrop_sListBoxStandard, LootDrop_sListBoxExtended},
			getFunc = function() self:ManageCompatibility_Xp() return self.db.experience end,
			setFunc = function(valueString) self:ToggleXP(valueString) end,
			width = "full",
			default = LootDrop_Defaults.experience
			},
		{
			type = "dropdown",
			name = "Gold & Tel Var",
			tooltip = "Should we show gold and Tel Var gain and loss ?",
			choices = {LootDrop_sListBoxNo, LootDrop_sListBoxStandard, LootDrop_sListBoxExtended},
			getFunc = function() self:ManageCompatibility_Money() return self.db.coin end,
			setFunc = function(valueString) self:ToggleCoin(valueString) end,
			width = "full",
			default = LootDrop_Defaults.coin
			},
		{
			type = "dropdown",
			name = "Alliance Points",
			tooltip = "Should we show Alliance Points ?",
			choices = {LootDrop_sListBoxNo, LootDrop_sListBoxStacked, LootDrop_sListBoxNotStacked, LootDrop_sListBoxExtended},
			getFunc = function() self:ManageCompatibility_AP() return self.db.alliance end,
			setFunc = function(valueString) self:ToggleAP(valueString) end,
			width = "full",
			default = LootDrop_Defaults.alliance
			},
		{
			type = "dropdown",
			name = "Telvar Stones",
			tooltip = "Should we show Telvar Stones ?",
			choices = {LootDrop_sListBoxNo, LootDrop_sListBoxStacked, LootDrop_sListBoxNotStacked, LootDrop_sListBoxExtended},
			getFunc = function() self:ManageCompatibility_TV() return self.db.telvar end,
			setFunc = function(valueString) self:ToggleTV(valueString) end,
			width = "full",
			default = LootDrop_Defaults.telvar
			},
		{
			type = "checkbox",
			name = "Loot",
			tooltip = "Should we show loot ?",
			getFunc = function() return self.db.loot end,
			setFunc = function(value) self:ToggleLoot(value) end,
			width = "full",
			default = LootDrop_Defaults.loot
			},
		{
			type = "checkbox",
			name = "- Mail Loot",
			tooltip = "Should we show mail loot ?",
			getFunc = function() return self.db.mailloot end,
			setFunc = function(value) self:ToggleMailLoot(value) end,
			width = "full",
			disabled = function() return not self.db.loot end,
			default = LootDrop_Defaults.mailloot
			},
		{
			type = "checkbox",
			name = "- Name Loot",
			tooltip = "Should we show name of loot ?",
			getFunc = function() return self.db.nameloot end,
			setFunc = function(value) self:ToggleNameLoot(value) end,
			width = "full",
			disabled = function() return not self.db.loot end,
			default = LootDrop_Defaults.nameloot
			},
		{
			type = "checkbox",
			name = "- Inventory stack Loot",
			tooltip = "Should we show inventory stack of loot ?",
			getFunc = function() return self.db.stackloot end,
			setFunc = function(value) self:ToggleStackLoot(value) end,
			width = "full",
			disabled = function() return not self.db.loot end,
			default = LootDrop_Defaults.stackloot
			},
		{
			type = "checkbox",
			name = "- Style Loot",
			tooltip = "Should we show style of loot ?",
			getFunc = function() return self.db.styleloot end,
			setFunc = function(value) self:ToggleStyleLoot(value) end,
			width = "full",
			disabled = function() return not self.db.loot end,
			default = LootDrop_Defaults.styleloot
		},
		{
			type = "checkbox",
			name = "Junk",
			tooltip = "Should we send trash items as junk in inventory bag ?",
			getFunc = function() return self.db.Junk end,
			setFunc = function(value) self:ToggleJunk(value) end,
			width = "full",
			default = LootDrop_Defaults.Junk
		},
		------------SKILLS--------------
		{
			type = "header",
			name = "Skills",
			width = "full",
		},
		{
			type = "dropdown",
			name = "Craft Xp",
			tooltip = "Should we show Craft Xp ?",
			choices = {LootDrop_sListBoxNo, LootDrop_sListBoxStacked, LootDrop_sListBoxNotStacked},
			getFunc = function() self:ManageCompatibility_Craft() return self.db.SkillXp end,
			setFunc = function(value) self:ToggleSkillXp(value) end,
			width = "full",
			default = LootDrop_Defaults.SkillXp
		},
		{
			type = "dropdown",
			name = "Guild reputation",
			tooltip = "Should we show Guild reputation Xp?",
			choices = {LootDrop_sListBoxNo, LootDrop_sListBoxStacked, LootDrop_sListBoxNotStacked},
			getFunc = function() return self.db.Guilds end,
			setFunc = function(value) self:ToggleGuildXp(value) end,
			width = "full",
			default = LootDrop_Defaults.Guilds
		},
		{
			type = "dropdown",
			name = "Fence Xp",
			tooltip = "Should we show Fence Xp?",
			choices = {LootDrop_sListBoxNo, LootDrop_sListBoxStacked, LootDrop_sListBoxNotStacked},
			getFunc = function() return self.db.Fence end,
			setFunc = function(value) self:ToggleFenceXp(value) end,
			width = "full",
			default = LootDrop_Defaults.Fence
		},
		{
			type = "dropdown",
			name = "Book knowledge",
			tooltip = "Should we show Book knowledge Xp ?",
			choices = {LootDrop_sListBoxNo, LootDrop_sListBoxNotStacked},
			getFunc = function() return self.db.Books end,
			setFunc = function(value) self:ToggleBookXp(value) end,
			width = "full",
			default = LootDrop_Defaults.Books
		},
		------------DIM & STYLE--------------
		{
			type = "header",
			name = "Dimensions and style",
			width = "full",
		},
		{
			type = "slider",
			name = "Display Duration",
			tooltip = "How long should we show droppables for ?",
			min = 1,
			max = 30,
			step = 1,
			getFunc = function() return self.db.displayduration end,
			setFunc = function(value) self.db.displayduration = value end,
			width = "half",
			default = LootDrop_Defaults.displayduration
		},
		{
			type = "slider",
			name = "Width",
			tooltip = "Entry Width.",
			min = 100,
			max = 300,
			step = 1,
			getFunc = function() return self.db.width end,
			setFunc = function(value) self:ChangeWidth(value) end,
			width = "half",
			default = LootDrop_Defaults.width
		},
		{
			type = "slider",
			name = "Height",
			tooltip = "Entry Height.",
			min = 25,
			max = 100,
			step = 1,
			getFunc = function() return self.db.height end,
			setFunc = function(value) self:ChangeHeight(value) end,
			width = "half",
			default = LootDrop_Defaults.height
		},
		{
			type = "slider",
			name = "Padding",
			tooltip = "Padding between entries.",
			min = 0,
			max = 25,
			step = 1,
			getFunc = function() return self.db.padding end,
			setFunc = function(value) self:ChangePadding(value) end,
			width = "half",
			default = LootDrop_Defaults.padding
		},
		{
			type = "checkbox",
			name = "Stack Up",
			tooltip = "If checked, the loots will be stack up at bottom right position of Lootdrop frame, otherwise stack down at top left position of Lootdrop frame.",
			getFunc = function() return self.db.MoveUp end,
			setFunc = function(value) self:ToggleMoveUp(value) end,
			width = "full",
			default = LootDrop_Defaults.MoveUp
		},
		{
			type = "checkbox",
			name = "Rarity border view",
			tooltip = "If not checked, LootDrop will not show item rarity.",
			getFunc = function() return self.db.rarity end,
			setFunc = function(value) self:ToggleRarity(value) end,
			width = "full",
			default = LootDrop_Defaults.rarity
		},
		{
			type = "dropdown",
			name = "Style",
			tooltip = "Pick a style.",
			choices = {LootDrop_sDefDefault, LootDrop_sDefPawkette, LootDrop_sDefRushmik},
			getFunc = function() return self.db.sListStyle end,
			setFunc = function(valueString) self:PickStyle(valueString) end,
			width = "full",
			default = LootDrop_Defaults.sListStyle
		},
		{
			type = "slider",
			name = "Font Size",
			tooltip = "Label font size.",
			min = 10,
			max = 22,
			step = 1,
			getFunc = function() return self.db.FontSize end,
			setFunc = function(value) self:ChangeFontSize(value) end,
			width = "full",
			default = LootDrop_Defaults.FontSize
		},
		------------CHAT--------------
		{
			type = "header",
			name = "Chat options",
			width = "full",
		},
		{
			type = "checkbox",
			name = "Log my loots / Exp / Currencies / in Chat",
			tooltip = "Should we send debug Loot log in chat box ?",
			getFunc = function() return self.db.DbgLog end,
			setFunc = function(value) self:ToggleDbgLog(value) end,
			width = "full",
			default = LootDrop_Defaults.DbgLog
		},
		{
			type = "checkbox",
			name = "Log Groupmates loots ",
			tooltip = "Should we display party members loots ?",
			getFunc = function() return self.db.DbgLogOthers end,
			setFunc = function(value) self:ToggleOthersLog(value) end,
			width = "half",
			default = LootDrop_Defaults.DbgLogOthers
		},
		{
			type = "dropdown",
			name = "Only if quality upper or equal to:",
			tooltip = "Output groupmate loot only if item quality is upper or equal to the selected value.",
			choices = qualityChoices,
			getFunc = function() return qualityChoices[self.db.DbgLogOthersQlty] end,
			setFunc = function(choice) self.db.DbgLogOthersQlty = reverseQualityChoices[choice] end,
			width = "half",
			disabled = function() return not self.db.DbgLogOthers end,
			default = qualityChoices[LootDrop_Defaults.DbgLogOthersQlty],
		},
		{
			type = "checkbox",
			name = "Log time",
			tooltip = "Should we display time with debug log ?",
			getFunc = function() return self.db.DbgLogTime end,
			setFunc = function(value) self:ToggleDbgLogTime(value) end,
			width = "full",
			disabled = function() return (not self.db.DbgLog and not self.db.DbgLogOthers) end,
			default = LootDrop_Defaults.DbgLogTime
		},
		{
			type = "checkbox",
			name = "Log item style",
			tooltip = "Should we display item style with debug log ?",
			getFunc = function() return self.db.DbgLogItemStyle end,
			setFunc = function(value) self:ToggleDbgLogItemStyle(value) end,
			width = "full",
			disabled = function() return (not self.db.DbgLog and not self.db.DbgLogOthers) end,
			default = LootDrop_Defaults.DbgLogItemStyle
		},
		{
			type = "checkbox",
			name = "Log Xp, Ap and Skill",
			tooltip = "Should we display Xp, Ap and Skill with debug log ? (Xp, Ap and Skills have to be checked in LootDrop General & Skills settings)",
			getFunc = function() return self.db.DbgLogXp end,
			setFunc = function(value) self:ToggleDbgLogXp(value) end,
			width = "full",
			disabled = function() return not self.db.DbgLog end,
			default = LootDrop_Defaults.DbgLogXp
		},
		{
			type = "checkbox",
			name = "Log Currencies",
			tooltip = "Should we display gold / Telvar with debug log ? (They have to be enabled in LootDrop general settings)",
			getFunc = function() return self.db.DbgLogGold end,
			setFunc = function(value) self:ToggleDbgLogGold(value) end,
			width = "full",
			disabled = function() return not self.db.DbgLog end,
			default = LootDrop_Defaults.DbgLogGold
		},
		{
			type = "checkbox",
			name = "Log Tag",
			tooltip = "Should we display tag with debug log ?",
			getFunc = function() return self.db.DbgLogTag end,
			setFunc = function(value) self:ToggleDbgLogTag(value) end,
			width = "full",
			disabled = function() return (not self.db.DbgLog and not self.db.DbgLogOthers) end,
			default = LootDrop_Defaults.DbgLogTag
		},
		------------LOCK/UNLOCK--------------
		{
			type = "header",
			name = "Lock/Unlock Frame",
			width = "full",
		},
		{
			type = "description",
			--title = "My Title",
			title = nil,
			text = "Unlock the LootDrop main frame makes it darker, and allows you to move it freely. When locked, it becomes transparent.",
			width = "full",
		},
		{
			type = "button",
			name = "Lock/Unlock",
			tooltip = "Click to move the LootDrop Frame, or to lock it.",
			func = function() self:ToggleLock() end,
			width = "half",
		},
	}

	LAM2:RegisterOptionControls(ADDON_NAME, optionsTable)

end
-------------------------------------------------------------------------------
function LootDropConfig:ManageCompatibility_Craft()
	if (self.db.SkillXp == false ) then
		self.db.SkillXp = LootDrop_sListBoxNo
	elseif (self.db.SkillXp == true ) then
		self.db.SkillXp = LootDrop_sListBoxNotStacked
	end
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleSkillXp(value)
	self.db.SkillXp = value
	CBM:FireCallbacks( self.EVENT_TOGGLE_SKILL_XP )
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleGuildXp(value)
	self.db.Guilds = value
	CBM:FireCallbacks( self.EVENT_TOGGLE_SKILL_XP )
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleFenceXp(value)
	self.db.Fence = value
	CBM:FireCallbacks( self.EVENT_TOGGLE_SKILL_XP )
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleBookXp(value)
	self.db.Books = value
	CBM:FireCallbacks( self.EVENT_TOGGLE_SKILL_XP )
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleDbgLog(value)
	self.db.DbgLog = value
	CBM:FireCallbacks( self.EVENT_TOGGLE_DEBUGLOG )
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleDbgLogTime(value)
	self.db.DbgLogTime = value
	CBM:FireCallbacks( self.EVENT_TOGGLE_DEBUGLOG )
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleDbgLogItemStyle(value)
	self.db.DbgLogItemStyle = value
	CBM:FireCallbacks( self.EVENT_TOGGLE_DEBUGLOG )
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleDbgLogXp(value)
	self.db.DbgLogXp = value
	CBM:FireCallbacks( self.EVENT_TOGGLE_DEBUGLOG )
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleDbgLogGold(value)
	self.db.DbgLogGold = value
	CBM:FireCallbacks( self.EVENT_TOGGLE_DEBUGLOG )
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleDbgLogTag(value)
	self.db.DbgLogTag = value
	CBM:FireCallbacks( self.EVENT_TOGGLE_DEBUGLOG )
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleOthersLog(value)
	self.db.DbgLogOthers = value
	CBM:FireCallbacks( self.EVENT_TOGGLE_DEBUGLOG )
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleJunk(value)
	self.db.Junk = value
	CBM:FireCallbacks( self.EVENT_TOGGLE_JUNK )
end
-------------------------------------------------------------------------------
function LootDropConfig:ChangeWidth(width)
	self.db.width = width
	CBM:FireCallbacks( self.EVENT_CHANGE_DIMENSIONS )
end
-------------------------------------------------------------------------------
function LootDropConfig:ChangeHeight(height)
	self.db.height = height
	CBM:FireCallbacks( self.EVENT_CHANGE_DIMENSIONS )
end
-------------------------------------------------------------------------------
function LootDropConfig:ChangePadding(padding)
	self.db.padding = padding
	CBM:FireCallbacks( self.EVENT_CHANGE_DIMENSIONS )
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleMoveUp(value) 
	self.db.MoveUp = value
	CBM:FireCallbacks( self.EVENT_TOGGLE_MOVEUP )
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleRarity(value) 
	self.db.rarity = value
	CBM:FireCallbacks( self.EVENT_TOGGLE_RARITY )
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleLock() 
	self.db.lootdrop_lock = not self.db.lootdrop_lock
	CBM:FireCallbacks( self.EVENT_TOGGLE_LOCK )
end
-------------------------------------------------------------------------------
function LootDropConfig:PickStyle(sValue)
   self.db.sListStyle = sValue
   CBM:FireCallbacks( self.EVENT_TOGGLE_STYLE )
end
-------------------------------------------------------------------------------
function LootDropConfig:ChangeFontSize(sValue)
   self.db.FontSize = sValue
   CBM:FireCallbacks( self.EVENT_TOGGLE_STYLE )
end
-------------------------------------------------------------------------------
function LootDropConfig:ManageCompatibility_Xp()
    if (self.db.experience == false ) then
        self.db.experience = LootDrop_sListBoxNo
    elseif (self.db.experience == true ) then
        self.db.experience = LootDrop_sListBoxExtended
    end
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleXP(valueString)
    self.db.experience = valueString
    CBM:FireCallbacks( self.EVENT_TOGGLE_XP )
end
-------------------------------------------------------------------------------
function LootDropConfig:ManageCompatibility_Money()
    if (self.db.coin == false ) then
        self.db.coin = LootDrop_sListBoxNo
    elseif (self.db.coin == true ) then
        self.db.coin = LootDrop_sListBoxExtended
    end
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleCoin(valueString)
    self.db.coin = valueString
    CBM:FireCallbacks( self.EVENT_TOGGLE_COIN )
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleLoot(value)
    self.db.loot = value
    CBM:FireCallbacks( self.EVENT_TOGGLE_LOOT )
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleMailLoot(value)
    self.db.mailloot = value
    CBM:FireCallbacks( self.EVENT_TOGGLE_MAIL_LOOT )
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleNameLoot(value)
    self.db.nameloot = value
    CBM:FireCallbacks( self.EVENT_TOGGLE_LOOT )
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleStackLoot(value)
    self.db.stackloot = value
    CBM:FireCallbacks( self.EVENT_TOGGLE_LOOT )
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleStyleLoot(value)
    self.db.styleloot = value
    CBM:FireCallbacks( self.EVENT_TOGGLE_LOOT )
end
-------------------------------------------------------------------------------
function LootDropConfig:ManageCompatibility_AP()
    if (self.db.alliance == false ) then
        self.db.alliance = LootDrop_sListBoxNo
    elseif (self.db.alliance == true ) then
        self.db.alliance = LootDrop_sListBoxStacked
    end
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleAP(valueString)
    self.db.alliance = valueString
    CBM:FireCallbacks( self.EVENT_TOGGLE_AP )
end
-------------------------------------------------------------------------------
function LootDropConfig:ManageCompatibility_TV()
    if (self.db.telvar == false ) then
        self.db.telvar = LootDrop_sListBoxNo
    elseif (self.db.telvar == true ) then
        self.db.telvar = LootDrop_sListBoxStacked
    end
end
-------------------------------------------------------------------------------
function LootDropConfig:ToggleTV(valueString)
    self.db.telvar = valueString
    CBM:FireCallbacks( self.EVENT_TOGGLE_TV )
end
-------------------------------------------------------------------------------
-- Called by bindings, objects & config cannot be called because of protection by the local vars, so using the global ref to acess them.
function LootDrop_LockUnlock()
	LOOTDROP_DB.Default[GetDisplayName()]["$AccountWide"].lootdrop_lock = not LOOTDROP_DB.Default[GetDisplayName()]["$AccountWide"].lootdrop_lock
	CBM:FireCallbacks( LootDropConfig.EVENT_TOGGLE_LOCK )
end
-------------------------------------------------------------------------------
-- Called by bindings
function LootDrop_ToggleAutoloot()

	local Setting = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT)
	local Autolootinfo = ""

	if LOOTDROP_DB.Default[GetDisplayName()]["$AccountWide"].DbgLogTime then
		Autolootinfo = "[" .. GetTimeString() .. "]:"
	end
	
	if (Setting == "1") then
		Setting = "0"
		CHAT_SYSTEM:AddMessage(Autolootinfo .. 'LootDrop, autoloot OFF')
	else
		Setting = "1"
		CHAT_SYSTEM:AddMessage(Autolootinfo .. 'LootDrop, autoloot ON')
	end

	SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, Setting, 1)
	
end
-------------------------------------------------------------------------------

--LootDroppable----------------------------------------------------------------
local LootDroppable           = ZO_Object:Subclass()
-------------------------------------------------------------------------------
--- Create a new instance of a LootDroppable
-- @treturn LootDroppable
function LootDroppable:New( ... )
	local result = ZO_Object.New( self )
	result:Initialize( ... )
	return result
end
-------------------------------------------------------------------------------
--- Constructor
--
function LootDroppable:Initialize( objectPool )
	self.pool    = objectPool
	self.db      = objectPool.db
	self.control = CreateControlFromVirtual( 'LootDroppable', objectPool:GetControl(), 'LootDroppable', objectPool:GetNextId() )
	self.label   = self.control:GetNamedChild( '_Name' )
	self.icon    = self.control:GetNamedChild( '_Icon' )
	self.border  = self.control:GetNamedChild( '_Rarity' )
	self.bg      = self.control:GetNamedChild( '_BG' )
end
-------------------------------------------------------------------------------
--- Visibility Getter
-- @treturn boolean
function LootDroppable:IsVisible()
	return self.control:GetAlpha() > 0
end
-------------------------------------------------------------------------------
--- Show this droppable
-- @tparam number y
function LootDroppable:Show( x, y )
	self.enter_animation:Play()
	local current_x, current_y = self:GetOffsets()
	self.move_animation = self.pool._slide:Apply( self.control, current_x, current_y, x, y )
	self.move_animation:Play()
end
-------------------------------------------------------------------------------
function LootDroppable:Hide()
	if ( self.exit_animation ) then
		self.exit_animation:InsertCallback( function( ... ) self:Reset() end, 200 )
		self.exit_animation:Play()
	else
		self.control:SetAlpha( 0.0 )
		self:Reset()
	end
end
-------------------------------------------------------------------------------
--- Ready this droppable to show
function LootDroppable:Prepare(StackUp)

	if (StackUp==nil) then StackUp=true end
	local xdim, ydim = self.pool:GetControl():GetDimensions()
	local StartHeight=( #self.pool._active + 1 ) * ( self.db.height + self.db.padding )

	--self:SetAnchor( BOTTOMRIGHT, self.pool:GetControl(), BOTTOMRIGHT, self.db.width, ( #self.pool._active - 1 ) * ( ( self.db.height + self.db.padding ) * -1 ) )
	if (StackUp) then
		self:SetAnchor( BOTTOMRIGHT, self.pool:GetControl(), BOTTOMRIGHT, 0, - StartHeight )
	else
		self:SetAnchor( BOTTOMRIGHT, self.pool:GetControl(), BOTTOMRIGHT, 0, StartHeight - ydim )
	end

	self.control:SetWidth( self.db.width )
	self.control:SetHeight( self.db.height )
	self.icon:SetWidth( self.db.height )
	self.icon:SetHeight( self.db.height )

	self.enter_animation = self.pool._fadeIn:Apply( self.control )
	self.exit_animation  = self.pool._fadeOut:Apply( self.control )
	self.move_animation  = nil

	self.control:SetAlpha( 0 )
	self.label:SetText( '' )
	self.icon:SetTexture( '' )
	self.bg:SetTexture( '' )
	self.border:SetTexture( '' )
	self.timestamp = 0
end
-------------------------------------------------------------------------------
--- Reset this droppable
function LootDroppable:Reset()
	self.enter_animation = nil
	self.exit_animation  = nil
	self.move_animation  = nil

	self.label:SetText( '' )
	self.icon:SetHidden( true )
	self.bg:SetHidden( true )
	self.border:SetHidden( true )
	self.timestamp = 0
end
-------------------------------------------------------------------------------
--- Control getter
-- @treturn table
function LootDroppable:GetControl()
	return self.control
end
-------------------------------------------------------------------------------
--- Set show timestamp
-- @tparam number stamp
function LootDroppable:SetTimestamp( stamp )
	self.timestamp = stamp
end
-------------------------------------------------------------------------------
--- Get show timestamp
-- @treturn number
function LootDroppable:GetTimestamp()
	return self.timestamp
end
-------------------------------------------------------------------------------
--- Set label
-- @tparam string label
function LootDroppable:SetLabel( label )
	self.label:SetText( label )
end
-------------------------------------------------------------------------------
--- Set label Size
-- @tparam number size
function LootDroppable:SetLabelSize( size )
	local size = size or 14
	local font='$(BOLD_FONT)|' .. size .. '|soft-shadow-thin'
	self.label:SetFont( font )
end
-------------------------------------------------------------------------------
function LootDroppable:SetBackground()
	self.bg:SetTexture(LootDrop_sBgTexture)
	self.bg:SetHidden( false )
end
-------------------------------------------------------------------------------
--- Set rarity border
-- @tparam ZO_ColorDef color
function LootDroppable:SetRarity( color , b_rarity )

	if (b_rarity==nil) then 
		b_rarity=true
	end

	if (( not color ) and (b_rarity)) then
		color = ZO_ColorDef:New( 1, 1, 1, 1 )
	end

	if (not b_rarity) then
		color = ZO_ColorDef:New( 0, 0, 0, 0)
	end

	self.border:SetTexture(LootDrop_sRarityTexture)
	self.border:SetColor( color:UnpackRGBA() )
	self.border:SetHidden( false )
end
-------------------------------------------------------------------------------
function LootDroppable:GetLabel()
	return tonumber( self.label:GetText() or 0 )
end
-------------------------------------------------------------------------------
--- Set Icon
-- @tparam string icon
function LootDroppable:SetIcon( icon, coords )
	--local texture = self.icon:GetTextureInfo()
	local texture = self.icon:GetTextureFileName()

	if ( texture ~= icon ) then
		self.icon:SetTexture( icon )
	end

	if ( coords ) then
		self.icon:SetTextureCoords( unpack( coords ) )
	else
		self.icon:SetTextureCoords( 0, 1, 0, 1 )
	end

	self.icon:SetHidden( false )
end
-------------------------------------------------------------------------------
--- Pass anchor information to control
function LootDroppable:SetAnchor( ... )
	self.control:SetAnchor( ... )
end
-------------------------------------------------------------------------------
--- Pass translate information to animation
function LootDroppable:Move( x, y )
	local current_x, current_y = self:GetOffsets()
	self.move_animation = self.pool._slide:Apply( self.control, current_x, current_y, x, y )
	self.move_animation:Play()
end
-------------------------------------------------------------------------------
--- Get current y offset
-- @treturn number
function LootDroppable:GetOffsets()
	local _, _, _, _, offsX, offsY = self.control:GetAnchor( 0 )
	return offsX, offsY
end
-------------------------------------------------------------------------------


--LootDrop Object--------------------------------------------------------------
local LootDrop								= LootDropPool:Subclass()

LootDrop.dirty_flags						= setmetatable( {}, { __mode = 'kv'} )
LootDrop.config							= nil
LootDrop.db									= nil
LootDrop.ScreenMaxWidth					= 800
LootDrop.ScreenMaxHeight				= 600
LootDrop.CurrentItemBag_ItemStyle	= nil
LootDrop.CurrentItemBag_ItemType		= nil
LootDrop.CurrentItemBag_ItemLink		= nil
LootDrop.CurrentItemBag_ItemQuality	= nil
LootDrop.CurrentItemBag_ItemNb		= nil
LootDrop.ItemToPrint						= {iconFileName  = [[/esoui/art/icons/icon_missing.dds]], color='FFFFFF', quantity=0, nb=0, text='', tag='', itemstyle=nil}
LootDrop.MailStacks						= {}
LootDrop.loaded							= false
-------------------------------------------------------------------------------
--- Create our ObjectPool
-- @param ...
function LootDrop:New( ... )
	local result = LootDropPool.New( self )
	result:Initialize( ... )
	return result
end
-------------------------------------------------------------------------------
--- I swear I'm going to use this for something
-- @param ...
function LootDrop:Initialize( control )
	self.control = control
	self.control:RegisterForEvent( EVENT_ADD_ON_LOADED, function( ... ) self:OnLoaded( ... ) end )

	LootDropPool.Initialize( self, function() return self:CreateDroppable() end, function( ... ) self:ResetDroppable( ... ) end  )

	self.control:SetHandler( 'OnUpdate',			function( _, ft )		self:OnUpdate( ft )		end )
	self.control:SetHandler( 'OnMoveStop',			function( )				self:OnMoveStop( )		end )

	self._fadeIn  = LootDropFade:New( 0.0, 1.0, 200 )
	self._fadeOut = LootDropFade:New( 1.0, 0.0, 200 )
	self._slide   = LootDropSlide:New( 200 )
	self._pop     = LootDropPop:New()

	self._coinId						= nil
	self._coinLastVal					= 0

	self._xpId							= nil
	self._xpLastVal					= 0

	self._apId							= nil
	self._apLastVal					= 0

	self._tvId							= nil
	self._tvLastVal					= 0

	self._skillXpId					= nil
	self._skillXpLastVal				= 0

	self._skillMageXpId				= nil
	self._skillMageXpLastVal		= 0

	self._skillFighterXpId			= nil
	self._skillFighterXpLastVal	= 0

	self._skillUndauntedXpId		= nil
	self._skillUndauntedXpLastVal	= 0

	self._skillBookXpId				= nil

	self._skillFenceXpId				= nil
	self._skillFenceXpLastVal		= 0
	
	self._skillThievesXpId			= nil
	self._skillThievesXpLastVal	= 0
	
	self._skillBrotherhoodXpId			= nil
	self._skillBrotherhoodXpLastVal	= 0

	CBM:RegisterCallback( LootDropConfig.EVENT_TOGGLE_COIN,			function() self:ToggleCoin()    end )
	CBM:RegisterCallback( LootDropConfig.EVENT_TOGGLE_XP,				function() self:ToggleXP()      end )
	CBM:RegisterCallback( LootDropConfig.EVENT_TOGGLE_LOOT,			function() self:ToggleLoot()    end )
	CBM:RegisterCallback( LootDropConfig.EVENT_TOGGLE_MAIL_LOOT,	function() self:ToggleMailLoot()    end )
	CBM:RegisterCallback( LootDropConfig.EVENT_TOGGLE_AP,				function() self:ToggleAP()      end )
	CBM:RegisterCallback( LootDropConfig.EVENT_TOGGLE_TV,				function() self:ToggleTV()      end )

	CBM:RegisterCallback( LootDropConfig.EVENT_TOGGLE_STYLE,			function() self:ToggleStyle()    end )
	CBM:RegisterCallback( LootDropConfig.EVENT_TOGGLE_LOCK,			function() self:ToggleLock()    end )
	CBM:RegisterCallback( LootDropConfig.EVENT_TOGGLE_RARITY,		function() self:ToggleRarity()    end )
	CBM:RegisterCallback( LootDropConfig.EVENT_TOGGLE_MOVEUP,		function() self:ToggleMoveUp()    end )
	CBM:RegisterCallback( LootDropConfig.EVENT_TOGGLE_JUNK,			function() self:ToggleJunk()    end )
	CBM:RegisterCallback( LootDropConfig.EVENT_TOGGLE_DEBUGLOG,		function() self:ToggleDbgLog()    end )
	CBM:RegisterCallback( LootDropConfig.EVENT_TOGGLE_SKILL_XP,		function() self:ToggleSkillXp()    end )

	CBM:RegisterCallback( LootDropConfig.EVENT_CHANGE_DIMENSIONS,	function() self:ChangeDimensions()    end )
end
-------------------------------------------------------------------------------
function LootDrop:OnLoaded( event, addon )
	if ( addon ~= ADDON_NAME ) then
		return
	end

	self.db     = ZO_SavedVars:NewAccountWide( 'LOOTDROP_DB', 3.0, nil, LootDrop_Defaults )
	self.config = LootDropConfig:New( self.db )

	self:ToggleCoin()
	self:ToggleXP()
	self:ToggleLoot()
	self:ToggleMailLoot()
	self:ToggleAP()
	self:ToggleTV()

	self:ToggleSkillXp()
	self:ToggleStyle()
	
	self:DisableZOSLoot()

	local leftScreen, topScreen, rightScreen, bottomScreen  = GuiRoot:GetScreenRect()
	self.ScreenMaxWidth = rightScreen
	self.ScreenMaxHeight = bottomScreen

	self.control:ClearAnchors()
	self.control:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, self.db.lootdrop_x, self.db.lootdrop_y)
	local x = zo_min((self.ScreenMaxWidth-50),(self.db.width+1))
	local y = zo_min((self.ScreenMaxHeight-50),11*(self.db.height + self.db.padding))
	self.control:SetDimensions(x, y)
	self.control:SetDrawLayer(0)
	self.control:SetMovable(not self.db.lootdrop_lock)
	self.control:SetMouseEnabled(not self.db.lootdrop_lock)

	local MoveBG = WINDOW_MANAGER:CreateControl( "LootDropMoveMeBg",  self.control, CT_BACKDROP)  
	LootDropMoveMeBg:SetHidden(self.db.lootdrop_lock)
	LootDropMoveMeBg:SetAnchor(BOTTOMRIGHT, self.control, BOTTOMRIGHT, 0, 0)
	LootDropMoveMeBg:SetAnchorFill(self.control)
	LootDropMoveMeBg:SetCenterColor( 0,0,0,0.4 )
	LootDropMoveMeBg:SetCenterTexture("",8,1,2)
	LootDropMoveMeBg:SetEdgeColor( 0,0,0,0 )
	LootDropMoveMeBg:SetEdgeTexture("",8,1,2)

	self.loaded = true
end
-------------------------------------------------------------------------------
function LootDrop:ChangeDimensions()
	self.control:SetDimensions(zo_min((self.ScreenMaxWidth-50),(self.db.width+1)), zo_min((self.ScreenMaxHeight-50),11*(self.db.height + self.db.padding)))
end
-------------------------------------------------------------------------------
function LootDrop:ToggleMoveUp()
	--nothing to do, function just in case ... ;-)
	self.db.MoveUp = self.db.MoveUp	
end
-------------------------------------------------------------------------------
function LootDrop:ToggleRarity()
	--nothing to do, function just in case ... ;-)
	self.db.rarity = self.db.rarity
end
-------------------------------------------------------------------------------
function LootDrop:ToggleJunk()
	--nothing to do, function just in case ... ;-)
	self.db.Junk = self.db.Junk
end
-------------------------------------------------------------------------------
function LootDrop:ToggleDbgLog()
	--nothing to do, function just in case ... ;-)
	self.db.DbgLog          = self.db.DbgLog
	self.db.DbgLogTime      = self.db.DbgLogTime
	self.db.DbgLogItemStyle = self.db.DbgLogItemStyle
	self.db.DbgLogXp        = self.db.DbgLogXp
	self.db.DbgLogGold      = self.db.DbgLogGold
	self.db.DbgLogTag       = self.db.DbgLogTag
	self.db.DbgLogOthers    = self.db.DbgLogOthers
end
-------------------------------------------------------------------------------
function LootDrop:ToggleStyle()

	if (self.db.sListStyle == LootDrop_sDefRushmik) then
		LootDrop_sApIcon        = [[/lootdrop/textures/ap_rushmik_up.dds]]
		LootDrop_sXpIcon        = [[/lootdrop/textures/xp_rushmik_up.dds]]
      LootDrop_sSkillXpIcon   = [[/lootdrop/textures/skill_rushmik_up.dds]]

		LootDrop_sBgTexture     = [[/lootdrop/textures/rushmik_bg.dds]]
		LootDrop_sRarityTexture = [[/lootdrop/textures/rushmik_rarity.dds]]

	elseif (self.db.sListStyle == LootDrop_sDefPawkette) then
		LootDrop_sApIcon        = [[/lootdrop/textures/ap_pawkette_up.dds]]
		LootDrop_sXpIcon        = [[/lootdrop/textures/xp_pawkette_up.dds]]
      LootDrop_sSkillXpIcon   = [[/lootdrop/textures/skill_pawkette_up.dds]]

		LootDrop_sBgTexture     = [[/lootdrop/textures/default_bg.dds]]
		LootDrop_sRarityTexture = [[/lootdrop/textures/default_rarity.dds]]

	else
	--Default
		LootDrop_sApIcon        = [[/lootdrop/textures/ap_up.dds]]
		LootDrop_sXpIcon        = [[/lootdrop/textures/xp_up.dds]]
      LootDrop_sSkillXpIcon   = [[/lootdrop/textures/skill_up.dds]]

		LootDrop_sBgTexture     = [[/lootdrop/textures/default_bg.dds]]
		LootDrop_sRarityTexture = [[/lootdrop/textures/default_rarity.dds]]
	end
end
-------------------------------------------------------------------------------
function LootDrop:ToggleLock()

	self.control:SetMovable(not self.db.lootdrop_lock)
	self.control:SetMouseEnabled(not self.db.lootdrop_lock)
	LootDropMoveMeBg:SetHidden(self.db.lootdrop_lock)

	if (self.db.lootdrop_lock) then
		local leftScreen, topScreen, rightScreen, bottomScreen  = GuiRoot:GetScreenRect()
		local left, top, right, bottom = self.control:GetScreenRect()

		self.db.lootdrop_x = math.floor(right - rightScreen)
		self.db.lootdrop_y = math.floor(bottom - bottomScreen)
	end
end
-------------------------------------------------------------------------------
function LootDrop:ToggleCoin()
	if ( self.db.coin ~= LootDrop_sListBoxNo ) then
		self.current_money = GetCurrentMoney()
		self.control:RegisterForEvent( EVENT_MONEY_UPDATE, function( _, ... ) self:OnMoneyUpdated( ... )  end )
	else
		self.control:UnregisterForEvent( EVENT_MONEY_UPDATE )
	end
end
-------------------------------------------------------------------------------
function LootDrop:ToggleXP()
	if ( self.db.experience ~= LootDrop_sListBoxNo ) then
		if GetUnitLevel("player") < GetMaxLevel() then
			self.current_xp = GetUnitXP('player')
		else
			self.current_xp = GetPlayerChampionXP()
		end
		self.control:RegisterForEvent( EVENT_EXPERIENCE_GAIN, function( _, ... ) self:OnXPUpdated( ... )     end )
	else
		self.control:UnregisterForEvent( EVENT_EXPERIENCE_GAIN )
	end
end
-------------------------------------------------------------------------------
function LootDrop:ToggleSkillXp()
	if (( self.db.SkillXp ~= LootDrop_sListBoxNo ) or ( self.db.Guilds ~= LootDrop_sListBoxNo ) or ( self.db.Books ~= LootDrop_sListBoxNo ) ) then
		self.control:RegisterForEvent( EVENT_SKILL_XP_UPDATE, function( ... ) self:OnSkillXPUpdated( ... )     end )
	else
		self.control:UnregisterForEvent( EVENT_SKILL_XP_UPDATE )
	end
end
-------------------------------------------------------------------------------
function LootDrop:ToggleLoot()
	if ( self.db.loot ) then
		self.control:RegisterForEvent( EVENT_LOOT_RECEIVED, function( _, ... ) self:OnLootReceived( ... )    end )
		self.control:RegisterForEvent( EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function( ... ) self:OnSingleSlotUpdate( ... )    end )
	else
		self.control:UnregisterForEvent( EVENT_LOOT_RECEIVED )
		self.control:UnregisterForEvent( EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
	end
end
-------------------------------------------------------------------------------
function LootDrop:ToggleMailLoot()
	if ( self.db.mailloot ) and ( self.db.loot )then
		self.control:RegisterForEvent( EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, function( _, ... ) self:OnMailItemLooted( ... )    end )
		self.control:RegisterForEvent( EVENT_MAIL_READABLE, function( _, ... ) self:OnMailReadable( ... )    end )
	else
		self.control:UnregisterForEvent( EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS )
		self.control:UnregisterForEvent( EVENT_MAIL_READABLE )
	end
end
-------------------------------------------------------------------------------
function LootDrop:ToggleAP()
	if ( self.db.alliance == LootDrop_sListBoxNo) then
        self.control:UnregisterForEvent( EVENT_ALLIANCE_POINT_UPDATE )
	else
        self.control:RegisterForEvent( EVENT_ALLIANCE_POINT_UPDATE, function( _, ... ) self:OnAPUpdate( ... ) end )
	end
end
-------------------------------------------------------------------------------
function LootDrop:ToggleTV()
	if ( self.db.telvar == LootDrop_sListBoxNo) then
		self.control:UnregisterForEvent( EVENT_TELVAR_STONE_UPDATE )
	else
		self.current_telvar = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
		self.control:RegisterForEvent( EVENT_TELVAR_STONE_UPDATE, function( _, ... ) self:OnTVUpdate( ... ) end )
	end
end
-------------------------------------------------------------------------------
function LootDrop:DisableZOSLoot()
	SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_LOOT_HISTORY, "0", 1)
end
-------------------------------------------------------------------------------
--- Check if any flags are set
-- if no flag is passed will check if any flag is set.
-- @tparam DirtyFlags flag
-- @treturn boolean
function LootDrop:IsDirty( flag )
	if ( not flag ) then return #self.dirty_flags ~= 0 end

	for _,v in pairs( self.dirty_flags ) do
		if ( v == flag ) then
			return true
		end
	end

	return false
end
-------------------------------------------------------------------------------
function LootDrop:OnMoveStop()
	if (not self.loaded) then
		return
	end
	
	local _, _, rightScreen, bottomScreen  = GuiRoot:GetScreenRect()
	local _, _, right, bottom = self.control:GetScreenRect()
	
	self.db.lootdrop_x = math.floor(right-rightScreen)
	self.db.lootdrop_y = math.floor(bottom-bottomScreen)
end
-------------------------------------------------------------------------------
--- On every consecutive frame
function LootDrop:OnUpdate( frameTime ) 
	if (( not #self._active) or (not self.loaded)) then
		return
	end

	local i = 1
	local entry = nil
	while( i <= #self._active ) do
		entry = self._active[ i ]

		if ( frameTime - entry:GetTimestamp() > self.db.displayduration ) then
			self:Release( entry )
			tinsert( self.dirty_flags, DirtyFlags.LAYOUT )
		else
			i = i + 1
		end
	end

	if ( self:IsDirty( DirtyFlags.LAYOUT ) ) then
		local last_y = 0
		local last_x = 0
		local entry = nil

		if (not self.db.MoveUp) then
			local xdim, ydim = self.control:GetDimensions()
			--y is count from the bottom right, so the top is negative number
			last_y = ( self.db.height + self.db.padding ) - ydim
			last_x = ( self.db.width) - xdim
		end
		
		for i=1,#self._active do
			entry = self._active[ i ]

			if ( not entry:IsVisible() ) then
				entry:Show( last_x, last_y )
			else            
				entry:Move( last_x, last_y )
			end
			
			if (self.db.MoveUp) then
				last_y = last_y - ( self.db.height + self.db.padding )
			else
				--y is count from the bottom right and last y is negative number
				last_y = last_y + ( self.db.height + self.db.padding )
			end
		end
	end

	self.dirty_flags = {}
end
-------------------------------------------------------------------------------
--- Create a new loot droppable
-- @tparam ZO_ObjectPool _ unused
function LootDrop:CreateDroppable()
	return LootDroppable:New( self )
end
-------------------------------------------------------------------------------
--- Reset a loot droppable
-- @tparam LootDroppable droppable 
function LootDrop:ResetDroppable( droppable, key )
	if ( key == self._coinId ) then
		self._coinId = nil
		self._coinLastVal = 0
	elseif( key == self._apId ) then
		self._apId = nil
		self._apLastVal = 0
	elseif( key == self._tvId ) then
		self._tvId   = nil
		self._tvLastVal = 0
	elseif( key == self._xpId ) then
		self._xpId = nil
		self._xpLastVal=0
	elseif ( key == self._skillXpId ) then
		self._skillXpId = nil
		self._skillXpLastVal = 0
	elseif ( key == self._skillMageXpId ) then
		self._skillMageXpId = nil
		self._skillMageXpLastVal = 0
	elseif ( key == self._skillFighterXpId ) then
		self._skillFighterXpId = nil
		self._skillFighterXpLastVal = 0
	elseif ( key == self._skillThievesXpId ) then
		self._skillThievesXpId = nil
		self._skillThievesXpLastVal = 0
	elseif ( key == self._skillUndauntedXpId ) then
		self._skillUndauntedXpId = nil
		self._skillUndauntedXpLastVal = 0
	elseif ( key == self._skillBookXpId ) then
		self._skillBookXpId = nil
	elseif ( key == self._skillFenceXpId ) then
		self._skillFenceXpId = nil
		self._skillFenceXpLastVal = 0
	elseif ( key == self._skillBrotherhoodXpId ) then
		self._skillBrotherhoodXpId = nil
		self._skillBrotherhoodXpLastVal = 0
	end

	droppable:Hide()
end
-------------------------------------------------------------------------------
function LootDrop:Acquire()
	local result, key = LootDropPool.Acquire( self )
	result:Prepare(self.db.MoveUp)

	tinsert( self.dirty_flags, DirtyFlags.LAYOUT )

	return result, key
end
-------------------------------------------------------------------------------
function LootDrop:FormatAmount( amount )
	return ZO_CommaDelimitNumber( amount )
end
-------------------------------------------------------------------------------
function LootDrop:ParseLink( link )
	if ( type( link ) ~= 'string' ) then
		return nil, nil
	end

	local text, color = zo_parselink( link )

	if (text=="") then
		text = link 
	end

	if color == "" or color == "0" or color == "1" then
		color = 'FFFFFF'
	end

	return text, color
end
-------------------------------------------------------------------------------
function LootDrop:NewParseLink( NewLink )
	if ( type( NewLink ) ~= 'string' ) then
		return nil, nil
	end

	local Text, LinkStyle = zo_parselink( NewLink )
	Text=zo_strformat("<<x:1>>", Text)

	if (Text=="") then
		Text = NewLink 
	end

	return Text, LinkStyle
end
-------------------------------------------------------------------------------
function LootDrop:ResetCurrentItemBag( )
	self.lastSingleSlotUpdateSlotId = nil
	self.lastSingleSlotUpdateBagId = nil
end
-------------------------------------------------------------------------------
function LootDrop:ResetItemToPrint( )
	self.ItemToPrint.iconFileName = [[/esoui/art/icons/icon_missing.dds]]
	self.ItemToPrint.color        = 'FFFFFF'
	self.ItemToPrint.quantity     = 0
	self.ItemToPrint.nb           = 0
	self.ItemToPrint.text         = ''
	self.ItemToPrint.tag          = ''
	self.ItemToPrint.itemStyle    = nil
end
-------------------------------------------------------------------------------
--TESO GUILDS TYPES
-- 0 : unknow
-- 1 : Fighter, guerrier, Krieger
-- 2 : Mage, mage, Magier
-- 3 : Thieves Huild, Guilde des voleurs, Diebesgilde 
-- 4 : Undaunted, Indomptable, Unerschrockene 
function LootDrop:GetGuildType(skillType,  skillIndex)
	local GuildTypeRet = 0
	
	if (skillType ~= SKILL_TYPE_GUILD) then return GuildTypeRet end
	
	local skillName = GetSkillLineInfo(skillType, skillIndex)
	skillName = skillName:lower()

	if ( (string.find(skillName, "brotherhood") ~= nil) or (string.find(skillName, "confrérie") ~= nil) or (string.find(skillName, "dunkle") ~= nil)) then
		GuildTypeRet=1
	elseif ( (string.find(skillName, "fighter") ~= nil) or (string.find(skillName, "guerrier") ~= nil) or (string.find(skillName, "krieger") ~= nil)) then
		GuildTypeRet=2
	elseif ( (string.find(skillName, "mage") ~= nil ) or (string.find(skillName, "magier") ~= nil )) then
		GuildTypeRet=3
	elseif ( (string.find(skillName, "thieves") ~= nil) or (string.find(skillName, "voleurs") ~= nil) or (string.find(skillName, "diebesgilde") ~= nil) ) then
		GuildTypeRet=4
	elseif ( (string.find(skillName, "undaunted") ~= nil) or (string.find(skillName, "indomptable") ~= nil) or (string.find(skillName, "unerschrockene") ~= nil) ) then
		GuildTypeRet=5
	end

	return GuildTypeRet
end
-------------------------------------------------------------------------------
function LootDrop:OnSkillXPUpdated( eventCode,  skillType,  skillIndex,  reason,  rank,  previousXP,  currentXP) 

-- SkillType
	-- SKILL_TYPE_ARMOR = 3
	-- SKILL_TYPE_AVA = 6
	-- SKILL_TYPE_CLASS = 1
	-- SKILL_TYPE_GUILD = 5
	-- SKILL_TYPE_NONE = 0
	-- SKILL_TYPE_RACIAL = 7
	-- SKILL_TYPE_TRADESKILL = 8
	-- SKILL_TYPE_WEAPON = 2
	-- SKILL_TYPE_WORLD = 4 
-- reason
	-- PROGRESS_REASON_ACHIEVEMENT = 25
	-- PROGRESS_REASON_ACTION = 13
	-- PROGRESS_REASON_ALLIANCE_POINTS = 33
	-- PROGRESS_REASON_AVA = 15
	-- PROGRESS_REASON_BATTLEGROUND = 6
	-- PROGRESS_REASON_BOOK_COLLECTION_COMPLETE = 12
	-- PROGRESS_REASON_BOSS_KILL = 26
	-- PROGRESS_REASON_COLLECT_BOOK = 11
	-- PROGRESS_REASON_COMMAND = 4
	-- PROGRESS_REASON_COMPLETE_POI = 2
	-- PROGRESS_REASON_DARK_ANCHOR_CLOSED = 28
	-- PROGRESS_REASON_DARK_FISSURE_CLOSED = 29
	-- PROGRESS_REASON_DISCOVER_POI = 3
	-- PROGRESS_REASON_DUNGEON_CHALLENGE = 35
	-- PROGRESS_REASON_EVENT = 27
	-- PROGRESS_REASON_FINESSE = 9
	-- PROGRESS_REASON_GRANT_REPUTATION = 32
	-- PROGRESS_REASON_GUILD_REP = 14
	-- PROGRESS_REASON_JUSTICE_SKILL_EVENT = 36
	-- PROGRESS_REASON_KEEP_REWARD = 5
	-- PROGRESS_REASON_KILL = 0
	-- PROGRESS_REASON_LOCK_PICK = 10
	-- PROGRESS_REASON_MEDAL = 8
	-- PROGRESS_REASON_NONE = -1
	-- PROGRESS_REASON_OTHER = 31
	-- PROGRESS_REASON_OVERLAND_BOSS_KILL = 24
	-- PROGRESS_REASON_PVP_EMPEROR = 34
	-- PROGRESS_REASON_QUEST = 1
	-- PROGRESS_REASON_REWARD = 17
	-- PROGRESS_REASON_SCRIPTED_EVENT = 7
	-- PROGRESS_REASON_SKILL_BOOK = 30
	-- PROGRESS_REASON_TRADESKILL = 16
	-- PROGRESS_REASON_TRADESKILL_ACHIEVEMENT = 18
	-- PROGRESS_REASON_TRADESKILL_CONSUME = 20
	-- PROGRESS_REASON_TRADESKILL_HARVEST = 21
	-- PROGRESS_REASON_TRADESKILL_QUEST = 19
	-- PROGRESS_REASON_TRADESKILL_RECIPE = 22
	-- PROGRESS_REASON_TRADESKILL_TRAIT = 23 
	
--TradeskillType
	-- CRAFTING_TYPE_ALCHEMY = 4
	-- CRAFTING_TYPE_BLACKSMITHING = 1
	-- CRAFTING_TYPE_CLOTHIER = 2
	-- CRAFTING_TYPE_ENCHANTING = 3
	-- CRAFTING_TYPE_INVALID = 0
	-- CRAFTING_TYPE_PROVISIONING = 5
	-- CRAFTING_TYPE_WOODWORKING = 6 

	local bprint=false
	local stacked=false
	local tag=''
	local color='6BB5FF'
	local icon = LootDrop_sSkillXpIcon
	local dropid = self._skillXpId
	local lastval = self._skillXpLastVal
	local GuildType = 0

	--Skill Xp from craft
	if (( skillType == SKILL_TYPE_TRADESKILL ) and (reason == PROGRESS_REASON_TRADESKILL)) then
		bprint=(self.db.SkillXp ~= LootDrop_sListBoxNo)
		stacked=(self.db.SkillXp ~= LootDrop_sListBoxNotStacked)
		tag='CRAFT'
		
		local CraftType = GetCraftingInteractionType()
		
		if (CraftType == CRAFTING_TYPE_BLACKSMITHING) then
			icon = LootDrop_sAnvilXpIcon
		elseif (CraftType == CRAFTING_TYPE_CLOTHIER) then
			icon = LootDrop_sClothierXpIcon
		elseif (CraftType == CRAFTING_TYPE_ENCHANTING) then
			icon = LootDrop_sEnchanterXpIcon
		elseif (CraftType == CRAFTING_TYPE_ALCHEMY) then
			icon = LootDrop_sAlchimyXpIcon
		elseif (CraftType == CRAFTING_TYPE_PROVISIONING) then
			icon = LootDrop_sProvisioningXpIcon
		elseif (CraftType == CRAFTING_TYPE_WOODWORKING) then
			icon = LootDrop_sWoodXpIcon
		else -- craft book
			bprint=(self.db.Books ~= LootDrop_sListBoxNo)
			stacked=(self.db.Books ~= LootDrop_sListBoxNotStacked)
			tag='BOOK'
			icon = LootDrop_sBooksXpIcon
			dropid = self._skillBookXpId
			lastval = 0
		end

	--Skill Xp GUILD REPUTATION
	elseif ( skillType == SKILL_TYPE_GUILD ) then
		bprint=(self.db.Guilds ~= LootDrop_sListBoxNo)
		stacked=(self.db.Guilds ~= LootDrop_sListBoxNotStacked)
		tag='GUILD'
		GuildType = self:GetGuildType(skillType,  skillIndex)
		--d('GuildType' .. GuildType)
		if ( GuildType == 1 ) then
			icon = LootDrop_sBrotherhoodXpIcon
			dropid = self._skillBrotherhoodXpId
			lastval = self._skillBrotherhoodXpLastVal
		elseif ( GuildType == 2 ) then
			icon = LootDrop_sFighterGuildXpIcon
			dropid = self._skillFighterXpId
			lastval = self._skillFighterXpLastVal
		elseif ( GuildType == 3 ) then
			icon = LootDrop_sMagesGuildXpIcon
			dropid = self._skillMageXpId
			lastval = self._skillMageXpLastVal
		elseif ( GuildType == 4 ) then
			icon = LootDrop_sThievesXpIcon
			dropid = self._skillThievesXpId
			lastval = self._skillThievesXpLastVal
		elseif ( GuildType == 5 ) then
			icon = LootDrop_sOthersGuildXpIcon
			dropid = self._skillUndauntedXpId
			lastval = self._skillUndauntedXpLastVal
		else
			icon = LootDrop_sOthersGuildXpIcon
			dropid = self._skillUndauntedXpId
			lastval = self._skillUndauntedXpLastVal
		end
	--Skill XP from books in library
	elseif (reason == PROGRESS_REASON_SKILL_BOOK) then
		bprint=(self.db.Books ~= LootDrop_sListBoxNo)
		stacked=(self.db.Books ~= LootDrop_sListBoxNotStacked)
		tag='BOOK'
		icon = LootDrop_sBooksXpIcon
		dropid = self._skillBookXpId
		lastval = 0
	-- Fence skilline
	elseif (reason == PROGRESS_REASON_JUSTICE_SKILL_EVENT) then
		bprint=(self.db.Fence ~= LootDrop_sListBoxNo)
		stacked=(self.db.Fence ~= LootDrop_sListBoxNotStacked)
		tag='FENCE'
		icon = LootDrop_sFenceXpIcon
		dropid = self._skillFenceXpId
		lastval = self._skillFenceXpLastVal
	end

	if(bprint) then
		local RealGain = currentXP-previousXP
		local skillName = GetSkillLineInfo(skillType, skillIndex)
		local lastSkillXP, nextSkillXP, currentSkillXP = GetSkillLineXPInfo(skillType, skillIndex)
		local maxedSkill = (nextSkillXP == 0)
		local SkillXp = (currentSkillXP - lastSkillXP)
		local SkillXpTotal = SkillXp
		if (not maxed) then
			SkillXpTotal = nextSkillXP - lastSkillXP
		end

		--DROP LABEL (RealGain value could be stacked in SetSkillNewDrop)
		local pccurrent=0
		if (SkillXpTotal>0) then
			pccurrent = math.floor(100*(SkillXp/SkillXpTotal))
		end
		local pctexts = zo_strformat( '|c736F6E(<<1>>%)|r', pccurrent )
		local finaltext=zo_strformat( '|cFFFFFF[<<1>>]|r', skillName )

		if ((( skillType == SKILL_TYPE_TRADESKILL ) or (skillType == SKILL_TYPE_GUILD) or (( skillType == SKILL_TYPE_WORLD ) and (reason == PROGRESS_REASON_JUSTICE_SKILL_EVENT))) and (tag~='BOOK'))then
			finaltext=pctexts
		end

		--DBG LOG (always not stacked)
		local finaldbgtext=zo_strformat( '|c6BB5FF<<1>>|r  |c736F6E-> <<2>> / <<3>>|r  <<4>> |cFFFFFF[<<t:5>>]|r', self:FormatAmount(RealGain), self:FormatAmount(SkillXp), self:FormatAmount(SkillXpTotal), pctexts, skillName )
		local dropidout, lastvalout = self:SetNewDrop(stacked, dropid, color, icon, lastval, RealGain, finaltext, finaldbgtext, tag)

		--CRAFT
		if (( skillType == SKILL_TYPE_TRADESKILL ) and (reason == PROGRESS_REASON_TRADESKILL)) then
			self._skillXpId = dropidout
			self._skillXpLastVal = lastvalout
		--GUILD REPUTATION
		elseif ( skillType == SKILL_TYPE_GUILD ) then
			if ( GuildType == 1 ) then
				self._skillBrotherhoodXpId = dropidout
				self._skillBrotherhoodXpLastVal = lastvalout
			elseif ( GuildType == 2 ) then
				self._skillFighterXpId = dropidout
				self._skillFighterXpLastVal = lastvalout
			elseif ( GuildType == 3 ) then
				self._skillMageXpId = dropidout
				self._skillMageXpLastVal = lastvalout
			elseif ( GuildType == 4 ) then
				self._skillThievesXpId = dropidout
				self._skillThievesXpLastVal = lastvalout
			elseif ( GuildType == 5 ) then
				self._skillUndauntedXpId = dropidout
				self._skillUndauntedXpLastVal = lastvalout
			else
				self._skillUndauntedXpId = dropidout
				self._skillUndauntedXpLastVal = lastvalout
			end
		--BOOKS
		elseif (reason == PROGRESS_REASON_SKILL_BOOK) then
			self._skillBookXpId = dropidout
		-- FENCE
		elseif (reason == PROGRESS_REASON_JUSTICE_SKILL_EVENT) then
			self._skillFenceXpId = dropidout
			self._skillFenceXpLastVal = lastvalout
		end
	end
end
-------------------------------------------------------------------------------
function LootDrop:SetNewDrop(stacked, dropid, color, icon, lastval, val, label, dbglabel, tag)
	if ((label ~= nil) and (color ~= nil) and (val ~= 0)) then
		local newDrop = nil
        local pop = false

		if (stacked) then
			if ( dropid ) then
				newDrop = self:Get( dropid )
				if ( newDrop ) then
					pop = true
					val = val + lastval
				end
			end
		end

		if ( not newDrop ) then
			newDrop, dropid = self:Acquire()
		end

		lastval = val

		local zo_color = ZO_ColorDef:New( color )
		newDrop:SetTimestamp( GetFrameTimeSeconds() )
		newDrop:SetBackground()

		newDrop:SetLabelSize( self.db.FontSize )
		newDrop:SetRarity( zo_color, self.db.rarity )
		newDrop:SetIcon( icon )
		local slabel = zo_strformat( ' |c6BB5FF<<1>>|r  <<t:2>>', self:FormatAmount(val), label)
		newDrop:SetLabel(slabel)
		if dbglabel == nil then dbglabel = slabel end
		if self.db.DbgLogXp then
			self:ChatOutput(icon, 1, dbglabel, tag, true)
		end
		
		if ( pop ) then
			local anim = self._pop:Apply( newDrop.control )
			anim:Forward()
		end
	end

	return dropid, lastval
end
-------------------------------------------------------------------------------
function LootDrop:GetStyleColoredString( itemStyle )
	local StyleColoredString = nil
	--style info
	if (itemStyle and (not (itemStyle == ITEMSTYLE_NONE or itemStyle == ITEMSTYLE_UNIVERSAL))) then
		
		local stylestring = zo_strformat("<<1>>", GetString("SI_ITEMSTYLE", itemStyle))
		local color = "FFFFFF"

		if itemStyle >= ITEMSTYLE_RACIAL_BRETON and itemStyle <= ITEMSTYLE_RACIAL_KHAJIIT then
			color = GetItemQualityColor(ITEM_QUALITY_ARCANE)
		elseif itemStyle == ITEMSTYLE_RACIAL_IMPERIAL or itemStyle == ITEMSTYLE_AREA_DWEMER or itemStyle == ITEMSTYLE_GLASS or itemStyle == ITEMSTYLE_AREA_XIVKYN then
			color = GetItemQualityColor(ITEM_QUALITY_LEGENDARY)
		else
			color = GetItemQualityColor(ITEM_QUALITY_ARTIFACT)
		end
		StyleColoredString = ("|c%s [%s]|r"):format (color:ToHex(), stylestring)
	end

	return StyleColoredString
	
end
-------------------------------------------------------------------------------
-- Called when one of your bag (inventory, bank, gbank, buyback ..) is updated -- Huge source of lua consumption
function LootDrop:OnSingleSlotUpdate(_, bagId, slotId, _, _, updateReason)
	
	if (bagId == BAG_BACKPACK or bagId == BAG_VIRTUAL) and updateReason == INVENTORY_UPDATE_REASON_DEFAULT and IsUnderArrest() == false then
		
		self.lastSingleSlotUpdateSlotId = slotId
		self.lastSingleSlotUpdateBagId = bagId
		
		--for mail loot
		if ( self.db.mailloot ) then
			for mailitemindex, item in pairs(self.MailStacks) do
				local itemLink = GetItemLink(bagId, slotId, LINK_STYLE_DEFAULT)
				-- itemLink can't be used as comparator because on hirelings mails (only thoses?), itemLink is incorrect
				local itemName = GetItemLinkName(itemLink)
				if (itemLink == item.itemLink) or (itemName == item.itemName)then
					item.bagId = bagId
					item.slotId = slotId
					break
				end
			end
		end
		
	end
end
-------------------------------------------------------------------------------
--- Called when you loot an Item
-- @tparam string itemLink
-- @tparam number quantity 
-- @tparam boolean mine
function LootDrop:OnLootReceived(unitName, itemLink, quantity, _, lootType, mine)
	
	if not mine and (not self.db.DbgLogOthers or lootType == LOOT_TYPE_QUEST_ITEM) then
		return
	end
	
	-- itemLink can be an itemName if lootType == LOOT_TYPE_QUEST_ITEM. itemId param #9 can't be used for this lootType, questItemIcon returns nil
	
	local icon, color
	if lootType == LOOT_TYPE_QUEST_ITEM then
		self.ItemToPrint.tag = 'QUEST'
		
		-- searching for item in questCache to get its icon
		for journalIndex, questData in pairs(SHARED_INVENTORY.questCache) do
			for itemIndex, itemData in pairs (questData) do
				if itemData.name == zo_strformat(SI_TOOLTIP_ITEM_NAME, itemLink) then
					icon = itemData.iconFile
					break
				end
			end
		end
		
		if ( (not icon) or (icon == '') or (icon == [[/esoui/art/icons/icon_missing.dds]])) then
			icon = [[/esoui/art/inventory/inventory_tabicon_quest_down.dds]]
		end
		
		color = GetItemQualityColor(GetItemLinkQuality(nil))
		
	else
		
		local itemStyle
		icon, _, _, _, itemStyle   = GetItemLinkInfo(itemLink)
		color                      = GetItemQualityColor(GetItemLinkQuality(itemLink))
		self.ItemToPrint.tag       = 'INV'
		self.ItemToPrint.itemStyle = self:GetStyleColoredString( itemStyle )
		
		if mine then
			if self.db.Junk and GetItemLinkItemType(itemLink) == ITEMTYPE_TRASH and IsItemJunk(self.lastSingleSlotUpdateBagId, self.lastSingleSlotUpdateSlotId) == false then
				SetItemIsJunk(self.lastSingleSlotUpdateBagId, self.lastSingleSlotUpdateSlotId, true)
				self.ItemToPrint.tag = 'JUNK'
			end
			self.ItemToPrint.nb = GetSlotStackSize(self.lastSingleSlotUpdateBagId, self.lastSingleSlotUpdateSlotId)
			self:ResetCurrentItemBag()
		end
		
	end
	
	local newDrop, _ = self:Acquire()
	self:LootPrint(newDrop, icon, color, quantity, itemLink, mine, unitName)
	
end
-------------------------------------------------------------------------------
-- Calledn when you read a mail
function LootDrop:OnMailReadable(mailId)
	
	self.MailStacks = {}
	
	for attachIndex = 1, GetMailAttachmentInfo( mailId ) do
		self.MailStacks[attachIndex] = {}
		local icon, stack, _, _, _, _, itemStyle, quality = GetAttachedItemInfo( mailId, attachIndex)
		local mailitemlink                                = GetAttachedItemLink( mailId, attachIndex, LINK_STYLE_DEFAULT)
		local mailitemName                                = GetItemLinkName(mailitemlink)
		self.MailStacks[attachIndex].icon                 = icon
		self.MailStacks[attachIndex].stack                = stack
		self.MailStacks[attachIndex].itemLink             = mailitemlink
		self.MailStacks[attachIndex].itemName             = mailitemName
		self.MailStacks[attachIndex].itemStyle            = self:GetStyleColoredString( itemStyle )
		self.MailStacks[attachIndex].quality              = quality
	end
end
-------------------------------------------------------------------------------
-- Called (a single time) when you take mail attachements
function LootDrop:OnMailItemLooted(mailId)
	
	-- Buggy if bag is full, it will consider all items as looted, even if only some are not. To fix quickly at 2.3
	
	for mailitemindex, item in pairs(self.MailStacks) do
		local color = GetItemQualityColor(item.quality)
		
		self.ItemToPrint.nb        = GetSlotStackSize(item.bagId, item.slotId)
		self.ItemToPrint.tag       = 'MAIL'
		self.ItemToPrint.itemStyle = item.itemStyle
		
		local newDrop, _ = self:Acquire()
		self:LootPrint(newDrop, item.icon, color, item.stack, item.itemLink, true)
		
	end

	self.MailStacks = {}
	self:ResetCurrentItemBag()
	
end
-------------------------------------------------------------------------------
-- Print a loot in LottDrop Gui and send it in chat if enabled
function LootDrop:LootPrint(newDrop, icon, c, quantity, text, mine, unitName)

	if ( not icon or icon == '' )then
		icon = [[/esoui/art/icons/icon_missing.dds]]
	end
	
	local color = c:ToHex()
	local guiName = text
	local quality = ITEM_QUALITY_TRASH
	-- Remove ItemLink for LootDropGui, because of some rare items with wrong itemLink in FR/DE. (ex few set items - |H1:item:55383:283:50:0:0:0:0:0:0:0:0:0:0:0:0:33:0:0:0:0:0|h|h)
	if string.find(text, "|H(.-):item:(.-)|h(.-)|h") then
		guiName = zo_strformat("|c<<1>><<2>>|r", color, zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(text)))
		quality = GetItemLinkQuality(text)
	else
		-- Quest items
		guiName = zo_strformat(SI_TOOLTIP_ITEM_NAME, text)
	end
	
	text = zo_strformat(SI_TOOLTIP_ITEM_NAME, text)

	local label = zo_strformat(" <<1[//$dx]>> <<t:2>>", quantity, guiName )
	local tag = self.ItemToPrint.tag

	if not self.db.nameloot and (tag == "INV" or tag == "JUNK" or tag == "MAIL") then
		label = zo_strformat(" <<1[//$dx]>>", quantity )
	end

	local invstack = ""
	local style = ""

	if tag == "INV" or tag == "JUNK" or tag == "MAIL" then
		if self.db.stackloot then
			invstack=zo_strformat(" |c736F6E(<<1>>)|r", self.ItemToPrint.nb)
		end
		if self.db.styleloot and self.ItemToPrint.itemStyle then
			style = self.ItemToPrint.itemStyle
		end
	end
	
	if mine then
		label = label .. invstack .. style
		newDrop:SetTimestamp( GetFrameTimeSeconds() )
		newDrop:SetBackground()
		newDrop:SetLabelSize( self.db.FontSize )
		newDrop:SetRarity( c , self.db.rarity)
		newDrop:SetIcon( icon )
		newDrop:SetLabel( label )
		local anim = self._pop:Apply( newDrop.control )
		anim:Forward()
	end
	
	self:ChatOutput(icon, quantity, text, tag, mine, unitName, quality)
	self:ResetItemToPrint()
	
end
-------------------------------------------------------------------------------
--- Called when the amount of money you have changes
-- @tparam number money 
function LootDrop:OnMoneyUpdated( newMoney )

	if ( self.current_money == newMoney ) then
		return
	end
	
	local difference = newMoney - self.current_money
	self.current_money = newMoney
	
	local pop = false
	local newDrop = nil

	if ( self._coinId ) then
		newDrop = self:Get( self._coinId )
		if ( newDrop ) then
			pop = true
			difference = difference + self._coinLastVal
		end
	end

	if ( not newDrop ) then
		newDrop, self._coinId = self:Acquire()
	end
	
	self._coinLastVal = difference

	local c = 'FFFF66'

	newDrop:SetTimestamp( GetFrameTimeSeconds() )
	newDrop:SetBackground()
	newDrop:SetLabelSize( self.db.FontSize )
	newDrop:SetRarity( ZO_ColorDef:New( c ), self.db.rarity )
	newDrop:SetIcon( [[/esoui/art/icons/item_generic_coinbag.dds]] )

	if (self.db.coin == LootDrop_sListBoxExtended) then
		newDrop:SetLabel(zo_strformat('<<1>>  |c736F6E-> <<2>>|r', self:FormatAmount(difference), self:FormatAmount(newMoney)))
	else
		newDrop:SetLabel( self:FormatAmount(difference) )
	end

	if (self.db.DbgLogGold) then
		local text=zo_strformat('<<1>>  |c736F6E-> <<2>>|r', self:FormatAmount(difference), self:FormatAmount(newMoney))
		self:ChatOutput([[/esoui/art/icons/item_generic_coinbag.dds]], 1, text, '', true)
	end

	if ( pop ) then
		local anim = self._pop:Apply( newDrop.control )
		anim:Forward()
	end
end
-------------------------------------------------------------------------------
function LootDrop:OnXPUpdated( _, level, previousExperience, currentExperience, championPoints )
	
	local gain = currentExperience - self.current_xp
	
	-- We hitted a new level
	if (currentExperience > previousExperience) then
		self.current_xp = currentExperience
	else
		self.current_xp = 0
	end

	if ( gain <= 0 ) then
		return
	end

	local RealDiff=gain

	local pop = false

	local newDrop = nil
	if ( self._xpId ) then
		newDrop = self:Get( self._xpId )

		if ( newDrop ) then
			pop = true
			gain = gain + self._xpLastVal
		end
	end

	if ( not newDrop ) then
		newDrop, self._xpId = self:Acquire()
	end

	self._xpLastVal = gain

	local c = 'FFFFFF'
	if (self.db.sListStyle==LootDrop_sDefPawkette) then
		c = '00FF00'
	end
	
	newDrop:SetTimestamp( GetFrameTimeSeconds() )
	newDrop:SetBackground()
	newDrop:SetLabelSize( self.db.FontSize )
	newDrop:SetRarity( ZO_ColorDef:New( c ), self.db.rarity )
	newDrop:SetIcon( LootDrop_sXpIcon )
	
	local xpForLevelUp
	if level < GetMaxLevel() then
		xpForLevelUp = GetNumExperiencePointsInLevel(level)
	else
		xpForLevelUp = GetNumChampionXPInChampionPoint(championPoints)
	end
	
	if (self.db.experience == LootDrop_sListBoxExtended) then
		
		local pcgain = 0
		local pccurrent = 100
		
		if (xpForLevelUp > 0) then
			pccurrent = math.floor(100*(currentExperience/xpForLevelUp))
			pcgain = math.floor(100 * (gain/xpForLevelUp))
		end
		
		local pctexts = zo_strformat( '|c736F6E(+<<1>>% -> <<2>>%)|r', pcgain, pccurrent )
		newDrop:SetLabel( zo_strformat('<<1>> <<2>>', self:FormatAmount(gain), pctexts))
		
	else
		newDrop:SetLabel( self:FormatAmount(gain) )
	end

	if (self.db.DbgLogXp) then
		local text = zo_strformat('<<1>>  |c736F6E-> <<2>> / <<3>>|r', self:FormatAmount(RealDiff), self:FormatAmount(currentExperience), self:FormatAmount(xpForLevelUp))
		self:ChatOutput(LootDrop_sXpIcon, 1, text, 'Xp', true)
	end

	if ( pop ) then
		local anim = self._pop:Apply( newDrop.control )
		anim:Forward()
	end
end
-------------------------------------------------------------------------------
function LootDrop:OnAPUpdate( _, _, difference )

	if ((difference <= 0) or (self.db.alliance == LootDrop_sListBoxNo))then return end
	
	local pop = false
	local newDrop = nil
	local RealDiff=difference
	local fullRankPoints = 0
	
	local rankPoints = GetUnitAvARankPoints("player")
	local _, _, rankStartsAt, nextRankAt = GetAvARankProgress(rankPoints)
	local pointsNeededForRank = nextRankAt - rankStartsAt
	local actualPointsInRank = rankPoints - rankStartsAt
	
	if (self.db.alliance ~= LootDrop_sListBoxNotStacked) then
		if ( self._apId ) then
			newDrop = self:Get( self._apId )
			if ( newDrop ) then
				pop = true
				difference = difference + self._apLastVal
			end
		end
	end

	if ( not newDrop ) then
		newDrop, self._apId = self:Acquire()
	end

	self._apLastVal=difference

	local c = 'C5FFC0'
	if (self.db.sListStyle==LootDrop_sDefPawkette) then
		c = '0000FF'
	end

	newDrop:SetTimestamp( GetFrameTimeSeconds() ) 
	newDrop:SetBackground()
	newDrop:SetLabelSize( self.db.FontSize )
	newDrop:SetRarity( ZO_ColorDef:New( c ) , self.db.rarity)
	newDrop:SetIcon( LootDrop_sApIcon )
	
	if (self.db.experience == LootDrop_sListBoxExtended) then

		local maxRank = 50
		local maxRankPointsAt = GetNumPointsNeededForAvARank(maxRank)

		local pcgain = 0
		local pccurrent=100

		if (pointsNeededForRank>0 and pointsNeededForRank ~= maxRankPointsAt) then
			pccurrent = math.floor(100*(actualPointsInRank/pointsNeededForRank))
			pcgain = (math.floor(100000 * (difference/pointsNeededForRank)) / 1000)
		end
		local pctexts = zo_strformat( '|c736F6E(+<<1>>% -> <<2>>%)|r', pcgain, pccurrent )

		newDrop:SetLabel( zo_strformat('<<1>> <<2>>', self:FormatAmount(difference), pctexts ) )
	else
		newDrop:SetLabel(self:FormatAmount(difference) )
	end

	if (self.db.DbgLogXp) then
		local text = zo_strformat('<<1>> |c736F6E -> <<2>> / <<3>>|r', self:FormatAmount(RealDiff), self:FormatAmount(actualPointsInRank), self:FormatAmount(pointsNeededForRank))
		self:ChatOutput(LootDrop_sApIcon, 1, text, 'AP', true)
	end

	if ( pop ) then
		local anim = self._pop:Apply( newDrop.control )
		anim:Forward()
	end
end
-------------------------------------------------------------------------------
function LootDrop:OnTVUpdate( newTelvarStones, oldTelvarStones, reason )
	
	local difference = newTelvarStones - self.current_telvar
	self.current_telvar = newTelvarStones
	local RealDiff=difference

	local pop = false

	if (difference ~= 0) then
		local newDrop = nil

		if ( self._tvId ) then
			newDrop = self:Get( self._tvId )
			if ( newDrop ) then
				pop = true
				difference = difference + self._tvLastVal
			end
		end

		if ( not newDrop ) then
			newDrop, self._tvId = self:Acquire()
		end

		self._tvLastVal = difference

		local c = 'FFFF66'

		newDrop:SetTimestamp( GetFrameTimeSeconds() )
		newDrop:SetBackground()
		newDrop:SetLabelSize( self.db.FontSize )
		newDrop:SetRarity( ZO_ColorDef:New( c ), self.db.rarity )
		newDrop:SetIcon( LootDrop_sTVIcon )
		
		if (self.db.telvar == LootDrop_sListBoxExtended) then
			newDrop:SetLabel(zo_strformat('<<1>>  |c736F6E-> <<2>>|r', self:FormatAmount(difference), self:FormatAmount(self.current_telvar)))
		else
			newDrop:SetLabel( self:FormatAmount(difference) )
		end

		if (self.db.DbgLogGold) then
			local text=zo_strformat('<<1>>  |c736F6E-> <<2>>|r', self:FormatAmount(RealDiff), self:FormatAmount(self.current_telvar))
			self:ChatOutput(LootDrop_sTVIcon, 1, text, '', true)
		end

		if ( pop ) then
			local anim = self._pop:Apply( newDrop.control )
			anim:Forward()
		end
	end
end
-------------------------------------------------------------------------------
--- Getter for the control xml element
-- @treturn table 
function LootDrop:GetControl()
	return self.control
end
-------------------------------------------------------------------------------
function LootDrop_Initialized( self )
    LootDrop:New( self )
end
-------------------------------------------------------------------------------
function LootDrop:ChatOutput(iconFilename, quantity, text, tag, mine, unitName, quality)

	local function CreateIcon(filename, width, height)
		return zo_iconFormat(filename, width or 16, height or 16)
	end
	
	if (mine and not self.db.DbgLog) or (not mine and not self.db.DbgLogOthers) or (not mine and self.db.DbgLogOthers and quality < self.db.DbgLogOthersQlty) then
		return
	end

	if not iconFilename or iconFilename == '' then
		iconFilename = [[/esoui/art/icons/icon_missing.dds]]
	end

	local dbgLogTime = ""
	if self.db.DbgLogTime then
		dbgLogTime = string.format("[%s]:", GetTimeString())
	end
	
	local icon = CreateIcon(iconFilename)

	local dbgText2 = zo_strformat('<<1[//$dx]>> <<2>>', quantity, text)
	
	if tag == 'INV' or tag == 'JUNK' or tag == 'MAIL' then
		if mine then
			dbgText2 = zo_strformat( '<<1[//$dx]>> <<2>> |c736F6E(<<3>>)|r', quantity, text, self.ItemToPrint.nb)
		else
			dbgText2 = zo_strformat( '<<1[//$dx]>> <<2>>', quantity, text)
		end
		
		if ((self.db.DbgLogItemStyle) and (self.ItemToPrint.itemStyle ~= nil)) then
			dbgText2 = dbgText2 .. self.ItemToPrint.itemStyle
		end
	end

	local dbgText3='.'
	if ((tag~='') and  (self.db.DbgLogTag)) then dbgText3=' (' .. tag .. ').' end
	
	if mine then
		CHAT_SYSTEM:AddMessage(zo_strformat( '<<1>> <<2>> <<3>><<4>>', dbgLogTime, icon, dbgText2, dbgText3))
	else
		CHAT_SYSTEM:AddMessage(zo_strformat( "<<1>> <<2>>: <<3>> <<4>>", dbgLogTime, unitName, icon, dbgText2))
	end
		
end
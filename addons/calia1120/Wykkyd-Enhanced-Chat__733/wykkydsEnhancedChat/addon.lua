--[[
  * Wykkyd [ Enhanced Chat ]
  * Sponsored & Supported by: The Prydonian Elders
  * Author: Ravalox Darkshire (support@ecgroup.us) & Calia1120
  * Embedded: LibStub & libAddonMenu by Seerah.
  * Special Thanks To: Zenimax Online Studios & Bethesda for The Elder Scrolls Online
]]--

local _addon = {}
_addon._v = {}
_addon._v.major		= 2
_addon._v.monthly 	= 6
_addon._v.daily 	= 0
_addon._v.minor 	= 0
_addon.Version 	= _addon._v.major
	..".".._addon._v.monthly
	..".".._addon._v.daily
	..".".._addon._v.minor
_addon.Name			= "wykkydsEnhancedChat"
_addon.MAJOR 		= _addon.Name..".".._addon._v.major
_addon.MINOR 		= string.format(".%02d%02d%03d", _addon._v.monthly, _addon._v.daily, _addon._v.minor)
_addon.DisplayName  = "Wykkyd Enhanced Chat"
_addon.SavedVariableVersion = 3
_addon.Player = "" -- will be set on load by LibWykkkydFactory
_addon.Settings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.GlobalSettings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.wykkydPreferred = {
	["chat_bg"] =
	{
		["r"] = 0.062745,
		["a"] = 1,
		["g"] = 0.007843,
		["b"] = 0,
	},
	["loot_gold_chat"] = true,
	["edit_box_label_size"] = 13,
	["edit_box_font_type"] = "Univers 57",
	["edit_box_label_style"] = "soft-shadow-thin",
	["show_new_chat_bg"] = true,
	["hide_default_bg"] = true,
	["prevent_window_fade"] = true,
	["edit_box_font_style"] = "soft-shadow-thick",
	["loot_whole_group"] = true,
	["edit_box_font_size"] = 14.500000,
	["edit_box_bg"] =
	{
		["r"] = 0.062745,
		["a"] = 1,
		["g"] = 0.007843,
		["b"] = 0,
	},
	["enhance_edit_box"] = true,
	["edit_box_label_type"] = "Univers 57",
	["loot_in_chat"] = true,
	["prevent_chat_fade"] = true,
	["edit_box_bg_enabled"] = true,
}


_addon.LoadSavedVariables = function( self )
	self._fontList = self.GLOBAL.Fonts
	self._fonts = {}; local i = 0; for k in pairs(self._fontList) do i = i + 1; self._fonts[i] = k; end table.sort(self._fonts);
	self._fontStyles = {"normal", "outline", "thick-outline", "shadow", "soft-shadow-thick", "soft-shadow-thin"}
	self._overlayFormats = {"Off","Current / Max","Current / Max (%)","Percent","Current"}
end

local colorGetFunc = function( self, key, defaultC )
	local cc = {}
	cc.r = defaultC[1]
	cc.g = defaultC[2]
	cc.b = defaultC[3]
	cc.a = defaultC[4]
	local c = self:GetOrDefault( cc, self.Settings[ key ] )
	if c[r] then
		return c[r], c[g], c[b], c[a]
	else
		if c["r"] then
			self.Settings[ key ]  = {}
			self.Settings[ key ].r = c["r"]
			self.Settings[ key ].g = c["g"]
			self.Settings[ key ].b = c["b"]
			self.Settings[ key ].a = c["a"]
			return c["r"], c["g"], c["b"], c["a"]
		else
			self.Settings[ key ]  = {}
			self.Settings[ key ].r = c[1]
			self.Settings[ key ].g = c[2]
			self.Settings[ key ].b = c[3]
			self.Settings[ key ].a = c[4]
			return c[1], c[2], c[3], c[4]
		end
	end
end
local colorSetFunc = function( self, key, r, g, b, a )
	self.Settings[ key ] = {}
	self.Settings[ key ].r = r
	self.Settings[ key ].g = g
	self.Settings[ key ].b = b
	self.Settings[ key ].a = a
end
local makeColorOption = function( self, key, defaultC, label )
	local target = self:MakeStandardOption( self.Settings, label, key, defaultC, "colorpicker", { default=defaultC, } )
	target.getFunc = function() return colorGetFunc( self, key, defaultC ) end
	target.setFunc = function( r, g, b, a )
		colorSetFunc( self, key, r, g, b, a )
		if key == "chat_bg" then _addon.ShowNewChatBG()
		else _addon.EnhanceEditBox() end
	end
	return target
end

_addon.LoadSettingsMenu = function( self )
	local panelData = {
		type = "panel",
		name = "Wykkyd Enh. Chat",
		displayName = "|cFF2222Wykkyd Enh. Chat|r",
		author = "Exodus Code Group",
		version = self.Version,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local optionsTable = {
		[1] = {
			type = "description",
			text = "This addon offers small enhancements to the default chat frame.",
		},
		[2] = self:MakeStandardOption( self.Settings, "Hide the default black background", "hide_default_bg", false, "checkbox", { warning="Reloads your UI when setting is turned off", default=false, } ),
		[3] = self:MakeStandardOption( self.Settings, "Prevent chat text from fading", "prevent_chat_fade", false, "checkbox", { default=false, } ),
		[4] = {
			type = "submenu",
			name = "|cCAB222Simple Chat Background|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show a simpler chat background", "show_new_chat_bg", false, "checkbox", { default=false, } ),
				[2] = makeColorOption( _addon, "chat_bg", {0.1,0.1,0.1,1}, "Background Color / Opacity" ),
			},
		},
		[5] = {
			type = "submenu",
			name = "|cCAB222Edit Box Enhancement|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Slightly enhance the edit box", "enhance_edit_box", false, "checkbox", { warning="Reloads your UI when setting is turned off", default=false, } ),
				[2] = self:MakeStandardOption( self.Settings, "Modify the background", "edit_box_bg_enabled", false, "checkbox", { default=false, } ),
				[3] = makeColorOption( _addon, "edit_box_bg", {0.1,0.1,0.1,1}, "Background Color / Opacity" ),
				[4] = _addon:MakeStandardOption( _addon.Settings, "Font", "edit_box_font_type", "Univers 57", "dropdown", { choices=_addon._fonts, default="Univers 57", } ),
				[5] = _addon:MakeStandardOption( _addon.Settings, "Font Style", "edit_box_font_style", "soft-shadow-thin", "dropdown", { choices=_addon._fontStyles, default="soft-shadow-thin", } ),
				[6] = _addon:MakeStandardOption( _addon.Settings, "Font Size", "edit_box_font_size", 14.5, "slider", { min=8, max=22, step=.5, default=16, } ),
				[7] = _addon:MakeStandardOption( _addon.Settings, "Font", "edit_box_label_type", "Univers 57", "dropdown", { choices=_addon._fonts, default="Univers 57", } ),
				[8] = _addon:MakeStandardOption( _addon.Settings, "Font Style", "edit_box_label_style", "soft-shadow-thin", "dropdown", { choices=_addon._fontStyles, default="soft-shadow-thin", } ),
				[9] = _addon:MakeStandardOption( _addon.Settings, "Font Size", "edit_box_label_size", 14, "slider", { min=8, max=22, step=.5, default=16, } ),
			},
		},
		[6] = {
			type = "submenu",
			name = "|cCAB222Loot Announcements|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show loot in chat", "loot_in_chat", false, "checkbox", { default=false, } ),
				[2] = self:MakeStandardOption( self.Settings, "Show bagged count", "loot_count", false, "checkbox", { default=false, } ),
				[3] = self:MakeStandardOption( self.Settings, "Include Gold notices", "loot_gold_chat", false, "checkbox", { default=false, } ),
				[4] = self:MakeStandardOption( self.Settings, "Include Party group", "loot_whole_group", false, "checkbox", { tooltip="Rare or better loot that you party loots. Show loot must be enabled.",default=false, } ),
				[5] = {
					type = "description",
					text = "Loot settings in this addon will not take affect if Wykkyd's Loot Manager is enabled.",
				},
			},
		},
		[7] = self:MakeStandardOption( self.Settings, "Force window not to fade", "prevent_window_fade", false, "checkbox", { default=false, } ),
	}
	optionsTable[2].setFunc = function( val ) self.Settings["hide_default_bg"] = val; _addon.HideDefaultBG(); end
	optionsTable[3].setFunc = function( val ) self.Settings["prevent_chat_fade"] = val; _addon.PreventChatFade(); end
	optionsTable[4].controls[1].setFunc = function( val ) self.Settings["show_new_chat_bg"] = val; _addon.ShowNewChatBG(); end
	for xx = 1, 9, 1 do
		local oldFunc = optionsTable[5].controls[xx].setFunc
		if xx == 1 then
			optionsTable[5].controls[xx].setFunc = function( val )
				self.Settings["enhance_edit_box"] = val
				self:ReloadUI()
			end
		end
		if xx ~= 3 then
			optionsTable[5].controls[xx].setFunc = function( val ) oldFunc( val ); _addon.EnhanceEditBox(); end
		end
	end
	optionsTable[6].controls[1].setFunc = function( val ) self.Settings["loot_in_chat"] = val; _addon.LootInChat(); end
	optionsTable[6].controls[2].setFunc = function( val ) self.Settings["loot_count"] = val; _addon.LootInChat(); end
	optionsTable[6].controls[3].setFunc = function( val ) self.Settings["loot_gold_chat"] = val; _addon.LootInChat(); end
	optionsTable[6].controls[4].setFunc = function( val ) self.Settings["loot_whole_group"] = val; _addon.LootInChat(); end
	optionsTable = self:InjectAdvancedSettings( optionsTable, 1 )
	self.LAM:RegisterAddonPanel(_addon.Name.."_LAM", panelData)
	self.LAM:RegisterOptionControls(_addon.Name.."_LAM", optionsTable)
end

_addon.HideDefaultBG = function( onStartup )
	if _addon:GetOrDefault( false, _addon.Settings["hide_default_bg"] ) then
		ZO_ChatWindowBg:SetHidden(true)
	else
		if not onStartup then _addon:ReloadUI() end
	end
end

_addon.ShowNewChatBG = function()
	local key, keybg = "wykkydsChatFrameBackPanel", "wykkydsChatFrameBackPanel_bg"
	if _addon:GetOrDefault( false, _addon.Settings["show_new_chat_bg"] ) then
		if _G[ key ] then
			_G[ key ]:SetHidden(false);
			_G[ keybg ]:SetHidden(false);
			_G[ keybg ]:SetCenterColor(colorGetFunc( _addon, "chat_bg", {0.1,0.1,0.1,1} ))
		else
			local w, h = ZO_ChatWindow:GetWidth()-20, ZO_ChatWindow:GetHeight()-20
			o = _addon.Frames.NewTopLevel(key)
			o.bg = _addon.Frames.__NewBackdrop(keybg, o)
				:SetAnchor(TOPLEFT, ZO_ChatWindow, TOPLEFT, 20, 40)
				:SetAnchor(BOTTOMRIGHT, ZO_ChatWindowTextEntryEdit, TOPRIGHT, 0, -1)
				:SetDimensions( w , h )
				:SetCenterColor(colorGetFunc( _addon, "chat_bg", {0.1,0.1,0.1,1} ))
				:SetEdgeColor(0,0,0,0)
				:SetEdgeTexture("", 1, 1, 0)
				:SetAlpha(.65)
				:SetHidden(false)
			.__END
			o:SetHidden(false)
			o.bg:SetHidden(false)
		end
	else
		if _G[ key ] then
			_G[ key ]:SetHidden(false)
			_G[ keybg ]:SetHidden(false)
		end
	end
end

_addon.EnhanceEditBox = function( onStartup )
	local key, keybg = "wykkydsEditBoxBackPanel", "wykkydsEditBoxBackPanel_bg"
	if _addon:GetOrDefault( false, _addon.Settings["enhance_edit_box"] ) then
		ZO_ChatWindowTextEntryEditBox:SetFont(string.format( "%s|%d|%s"
			, _addon._fontList[_addon:GetOrDefault( "Univers 57", _addon.Settings["edit_box_font_type"] )]
			, _addon:GetOrDefault( 14.5, _addon.Settings["edit_box_font_size"] )
			, _addon:GetOrDefault( "soft-shadow-thin", _addon.Settings["edit_box_font_style"] )
		))
		ZO_ChatWindowTextEntryLabel:SetFont(string.format( "%s|%d|%s"
			, _addon._fontList[_addon:GetOrDefault( "Univers 57", _addon.Settings["edit_box_label_type"] )]
			, _addon:GetOrDefault( 14, _addon.Settings["edit_box_label_size"] )
			, _addon:GetOrDefault( "soft-shadow-thin", _addon.Settings["edit_box_label_style"] )
		))
		if _addon:GetOrDefault( false, _addon.Settings["edit_box_bg_enabled"] ) then
			ZO_ChatWindowTextEntryEdit:SetCenterColor(1,1,1,0)
			ZO_ChatWindowTextEntryEdit:SetEdgeColor(0,0,0,0)
			ZO_ChatWindowTextEntryEdit:SetEdgeTexture("", 1, 1, 0)
			if _G[ key ] then
				_G[ key ]:SetHidden(false);
				_G[ keybg ]:SetHidden(false);
				_G[ keybg ]:SetCenterColor(colorGetFunc( _addon, "edit_box_bg", {0.1,0.1,0.1,1} ))
			else
				local w, h = ZO_ChatWindow:GetWidth()-20, ZO_ChatWindow:GetHeight()-20
				o = _addon.Frames.NewTopLevel(key)
				o.bg = _addon.Frames.__NewBackdrop(keybg, o)
					:SetAnchor(TOPLEFT, ZO_ChatWindowTextEntryEdit, TOPLEFT, 0, 0)
					:SetAnchor(BOTTOMRIGHT, ZO_ChatWindowTextEntryEdit, BOTTOMRIGHT, 0, 0)
					:SetDimensions( w , h )
					:SetCenterColor(colorGetFunc( _addon, "edit_box_bg", {0.1,0.1,0.1,1} ))
					:SetEdgeColor(0,0,0,0)
					:SetEdgeTexture("", 1, 1, 0)
					:SetAlpha(.65)
					:SetHidden(false)
				.__END
				o:SetHidden(false)
				o.bg:SetHidden(false)
			end
		else
			if _G[ key ] then
				_G[ key ]:SetHidden(false)
				_G[ keybg ]:SetHidden(false)
			end
		end
	else
		if not onStartup then _addon:ReloadUI() end
	end
end

local UIREADY = false

local PreventTextFade = function()
	if not ZO_ChatWindow then return end
	if not ZO_ChatWindow.container then return end
	if not ZO_ChatWindow.container.currentBuffer then return end
	if _addon:GetOrDefault( false, _addon.Settings["prevent_chat_fade"] ) then ZO_ChatWindow.container.currentBuffer:ShowFadedLines() end
	if _addon:GetOrDefault( false, _addon.Settings["prevent_window_fade"] ) then CHAT_SYSTEM:SetMinAlpha( 1 ) end
end

_addon.PreventChatFade = function()
	_addon:OnUpdateCallback( "wykkydsEnhancedChat_FadePrevention", PreventTextFade, .15 )
	CHAT_SYSTEM.maxContainerWidth, CHAT_SYSTEM.maxContainerHeight = GuiRoot:GetDimensions()
end

local lootToChat = function(...)
	if WYK_LootManager then return end
	local green = "0B610B"
	local eventCode, lootedBy, itemLink, quantity, itemSound, lootType, self = ...
        itemLink = itemLink:gsub("%^%a+","")
        if self then
            local inBags, haveCount = 0, " no idea"
            if _addon:GetOrDefault( false, _addon.Settings["loot_count"] ) then
                -- How many do I have? In the bank? Craft bag?
                local ctBackpack, ctBank, ctCraftBag = GetItemLinkStacks(itemLink)
                inBags = ctBackpack + ctBank + ctCraftBag
     
                -- Is this a raw material, refinable? How many refined do I have?
                local refinedItemLink = GetItemLinkRefinedMaterialItemLink(itemLink, LINK_STYLE_DEFAULT)
                local ctBackpackRefined, ctBankRefined, ctCraftBagRefined = GetItemLinkStacks(refinedItemLink)
                local ctRefined = ctBackpackRefined + ctBankRefined + ctCraftBagRefined
                if ctRefined ~= 0 then
                    inBags = "raw: " .. tostring(inBags) .. " refined:" .. tostring(ctRefined)
                end
            end
		if inBags ~= 0 then
                _addon:Print("|c"..green.."Looted [ " .. itemLink.. " |c"..green.."][ |cBEF781" .. quantity .. "|c"..green.." ]{|c886A08 "..tostring(inBags).." |c"..green.."}" )
            else
                _addon:Print("|c"..green.."Looted [ " .. itemLink.. " |c"..green.."] x|cBEF781" .. quantity )
            end
        else
            if _addon:GetOrDefault( false, _addon.Settings["loot_whole_group"] ) and lootType == LOOT_TYPE_ITEM then
                local icon,sellPrice,meetsUsageRequirement,equipType,itemStyle = GetItemLinkInfo(itemLink)
                local quality = GetItemLinkQuality(itemLink)
                if equipType ~= 0 and ( quality >= 3 ) then
                    _addon:Print( "|c32CE41" .. lootedBy:gsub("%^%a+","") .. " Got: [ " .. itemLink:gsub("%^%a+","") .. "|c32CE41 ] " .. quantity .."" )
                end
            end
        end
end

local goldQueue = {}
local lastGold = GetFrameTimeMilliseconds()
local goldTic = false

local goldToChat = function()
	if WYK_LootManager then return end
	local now = GetFrameTimeMilliseconds()
	if now == lastGold then return end
	local tbl = goldQueue
	goldQueue = {}
	lastGold = GetFrameTimeMilliseconds()
	_addon:OnUpdateCallback( "wykkydsEnhancedChat_GoldTic" )
	goldTic = false
	local sumL, sumG, gained, lost = 0, 0, false, false
	for ii = 1, _addon:GetCountOf( tbl ), 1 do
		local newMoney, oldMoney = tbl[ ii ].newMoney, tbl[ ii ].oldMoney
		if tbl[ ii ].gain then
			if oldMoney ~= newMoney then
				sumG = sumG + (newMoney - oldMoney)
				gained = true
			end
		else
			if oldMoney ~= newMoney then
				sumL = sumL + (oldMoney - newMoney);
				lost = true
			end
		end
	end
	if gained then _addon:Print( "|c32DF41Received Gold [|cCCCC33 " .. _addon:comma_value(sumG) .." |c32DF41] New total: |cCCCC33" .. _addon:comma_value(GetCurrentMoney()) .."" ) end
	if lost then _addon:Print( "|cDF3241Spent Gold [|cCCCC33 " .. _addon:comma_value(sumL) .." |cDF3241] New total: |cCCCC33" .. _addon:comma_value(GetCurrentMoney()) .."" ) end
end

local goldPrep = function(...)
	if WYK_LootManager then return end
	if not goldTic then
		goldTic = true
		_addon:OnUpdateCallback( "wykkydsEnhancedChat_GoldTic", goldToChat )
	end
	local eventCode, newMoney, oldMoney, reason = ...
	local nn = _addon:GetNextOf( goldQueue )
	goldQueue[nn] = {}
	goldQueue[nn].newMoney = newMoney
	goldQueue[nn].oldMoney = oldMoney
	goldQueue[nn].gain = (newMoney > oldMoney)
	lastGold = GetFrameTimeMilliseconds()
end

_addon.LootInChat = function()
	if WYK_LootManager then return end
	if _addon:GetOrDefault( false, _addon.Settings["loot_in_chat"] ) then
		_addon:RegisterEvent( EVENT_LOOT_RECEIVED, lootToChat )
	else
		_addon:UnregisterEvent( EVENT_LOOT_RECEIVED )
	end
	if _addon:GetOrDefault( false, _addon.Settings["loot_gold_chat"] ) then
		_addon:RegisterEvent( EVENT_MONEY_UPDATE, goldPrep )
	else
		_addon:UnregisterEvent( EVENT_MONEY_UPDATE )
	end
end

_addon.Initialize = function( self )
	self.HideDefaultBG( true )
	self.ShowNewChatBG()
	self.EnhanceEditBox( true )
	self.PreventChatFade()
	self.LootInChat()
end

if wykkydsEnhancedChatGlobal == nil then wykkydsEnhancedChatGlobal = {} end
LWF4.REGISTER_FACTORY(
	_addon, false, true,
	function( self ) _addon:LoadSavedVariables( self ) end,
	function( self ) _addon:LoadSettingsMenu( self ) end,
	function( self ) _addon:Initialize( self ) end,
	"wykkydsEnhancedChatGlobal", true
)

WYK_EnhancedChat = _addon

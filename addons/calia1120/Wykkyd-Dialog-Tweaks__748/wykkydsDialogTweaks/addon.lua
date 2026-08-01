--[[
  * Wykkyd [ Dialog Tweaks ]
  * Authors: Ravalox Darkshire (support@ecgroup.us) & Calia1120
  * Embedded: LibStub & libAddonMenu by Seerah.
  * Special credit to Biki, the original author of DialogTweaks from which this was derived
  * Special Thanks To: Zenimax Online Studios & Bethesda for The Elder Scrolls Online
]]--

local _addon = {}
_addon._v = {}
_addon._v.major		= 2
_addon._v.monthly 	= 4
_addon._v.daily 	= 0
_addon._v.minor 	= 0
_addon.Version 	= _addon._v.major
	..".".._addon._v.monthly
	..".".._addon._v.daily
	..".".._addon._v.minor
_addon.Name			= "wykkydsDialogTweaks"
_addon.MAJOR 		= _addon.Name..".".._addon._v.major
_addon.MINOR 		= string.format(".%02d%02d%03d", _addon._v.monthly, _addon._v.daily, _addon._v.minor)
_addon.DisplayName  = "Wykkyd Dialog Tweaks"
_addon.SavedVariableVersion = 3
_addon.Player = "" -- will be set on load by LibWykkkydFactory
_addon.Settings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.GlobalSettings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.wykkydPreferred = {
	["nameColor"] =
	{
		["b"] = 0.745098,
		["g"] = 0.921569,
		["a"] = 1,
		["r"] = 0.937255,
	},
	["removeDashes"] = true,
	["numberedOptions"] = true,
	["notSoVisibleGoodbye"] = true,
	["removeDashes"] = true,
	["nameAlignment"] = "center",
}

local zosHighlight = { ZO_HIGHLIGHT_TEXT.r, ZO_HIGHLIGHT_TEXT.g, ZO_HIGHLIGHT_TEXT.b, ZO_HIGHLIGHT_TEXT.a }

_addon.LoadSavedVariables = function( self )
	self.alignments = {
	   "left",
	   "center",
	   "right"
	}
	self.options = {
	   [1] = "ZO_ChatterOption1",
	   [2] = "ZO_ChatterOption2",
	   [3] = "ZO_ChatterOption3",
	   [4] = "ZO_ChatterOption4",
	   [5] = "ZO_ChatterOption5",
	   [6] = "ZO_ChatterOption6",
	   [7] = "ZO_ChatterOption7",
	   [8] = "ZO_ChatterOption8",
	   [9] = "ZO_ChatterOption9",
	   [10] = "ZO_ChatterOption10"
	}
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
	end
	return target
end

_addon.LoadSettingsMenu = function( self )
	local panelData = self:MakeStandardSettingsPanel( "Exodus Code Group", "|cFF2222" )
	local optionsTable = {
		[1] = {
			type = "description",
			text = "This addon provides customization to the conversation dialogs you encounter as you interact with characters around the world. This addon is based upon Biki's Dialog Tweaks and acts as a replacement of that addon since Biki has stepped away from the game.",
		},
		[2] = self:MakeStandardLAMOption( self.Settings, "Number the options", "numberedOptions", true, "checkbox", { tooltip = "Numbers the options in a dialog beginning with 1. You can press the corresponding key to select that option.", default=true } ),
		[3] = self:MakeStandardLAMOption( self.Settings, "Gray out 'Goodbye'", "notSoVisibleGoodbye", true, "checkbox", { tooltip = "Grays out the Goodbye option a bit so it is less distracting.", default=true } ),
		[4] = self:MakeStandardLAMOption( self.Settings, "Remove dashes from NPC name", "removeDashes", true, "checkbox", { tooltip = "Removes the dashes (-) from the NPC/target name.", default=true } ),
		[5] = self:MakeStandardLAMOption( self.Settings, "Alignment of NPC name", "nameAlignment", "center", "dropdown", { tooltip = "Select the alignment of the NPC/target name", default="center", choices = self.alignments } ),
		[6] = makeColorOption(self, "nameColor", zosHighlight, "NPC name/target color"),
	}
	optionsTable = self:InjectAdvancedSettings( optionsTable, 1 )
	self.LAM:RegisterAddonPanel(_addon.Name.."_LAM", panelData)
	self.LAM:RegisterOptionControls(_addon.Name.."_LAM", optionsTable)
end

_addon.Initialize = function( self )
	ZO_InteractWindowPlayerAreaOptions:RegisterForEvent(EVENT_CHATTER_BEGIN, function() self:applyTweaks() end)
	ZO_InteractWindowPlayerAreaOptions:RegisterForEvent(EVENT_CONVERSATION_UPDATED, function() self:applyTweaks() end)
	ZO_InteractWindowPlayerAreaOptions:RegisterForEvent(EVENT_QUEST_COMPLETE_DIALOG, function() self:applyTweaks() end)
	ZO_InteractWindowPlayerAreaOptions:RegisterForEvent(EVENT_QUEST_OFFERED, function() self:applyTweaks() end)
end

if wykkydsDialogTweaksGlobal == nil then wykkydsDialogTweaksGlobal = {} end
LWF4.REGISTER_FACTORY(
	_addon, false, true,
	function( self ) _addon:LoadSavedVariables( self ) end,
	function( self ) _addon:LoadSettingsMenu( self ) end,
	function( self ) _addon:Initialize( self ) end,
	"wykkydsDialogTweaksGlobal", true
)

_addon.applyTweaks = function( self )
   local lastOption = 0
   for k, v in pairs(self.options) do
      local option = _G[v]
      if self:GetOrDefault( true, self.Settings[ "numberedOptions" ] ) then
         option:SetText(tostring(k .. " - " .. option:GetText()))
      end
      if option:IsHidden() == true and lastOption == 0 then
         lastOption = k - 1
      end
   end
   if self:GetOrDefault( true, self.Settings[ "notSoVisibleGoodbye" ] ) then
      _G[self.options[lastOption]]:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
   end

   local npc = ZO_InteractWindowTargetAreaTitle
   local r,g,b,a = colorGetFunc( self, "nameColor", zosHighlight )
   npc:SetColor(r,g,b,a)

   if self:GetOrDefault( true, self.Settings[ "removeDashes" ] ) then
      local npcName = npc:GetText()
      local prettyName = string.sub(npcName, 2, string.len(npcName) - 1)
      npc:SetText(prettyName)
   end

   local align = self:GetOrDefault( "center", self.Settings[ "nameAlignment" ] )

   if align == "left" then npc:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
   elseif align == "center" then npc:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
   elseif align == "right" then npc:SetHorizontalAlignment(TEXT_ALIGN_RIGHT) end
end

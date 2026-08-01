--[[
  * Wykkyd's [ Auto Repair ]
  * Authors: Wykkyd
  * Embedded: LibStub & libAddonMenu by Seerah.
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
_addon.Name			= "wykkydsAutoRepair"
_addon.MAJOR 		= _addon.Name..".".._addon._v.major
_addon.MINOR 		= string.format(".%02d%02d%03d", _addon._v.monthly, _addon._v.daily, _addon._v.minor)
_addon.DisplayName  = "Wykkyd Auto Repair"
_addon.SavedVariableVersion = 3
_addon.Player = "" -- will be set on load by LibWykkkydFactory
_addon.Settings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.GlobalSettings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.wykkydPreferred = {
	["threshold"] = 100,
	["Enabled"] = true,
}

local p = function() return end -- this will be replaced when initialized

_addon.LoadSavedVariables = function( self )
	if self.Settings.Enabled == nil then self.Settings.Enabled = true end
end

_addon.LoadSettingsMenu = function( self )
	local panelData = self:MakeStandardSettingsPanel( "Exodus Code Group", "|cFF2222" )
	local optionsTable = {
		[1] = {
			type = "description",
			text = "Will automatically repair your gear when you visit a vendor. Has options to repair gear in your bag as well.",
		},
		[2] = self:MakeStandardOption( self.Settings, "Auto-Repair", "enabled", false, "checkbox", { default=false, } ),
		[3] = self:MakeStandardOption( self.Settings, "Repair Only Equipped Items", "worn", true, "checkbox", { default=true, } ),
		[4] = self:MakeStandardOption( self.Settings, "Report Repairs To Chat", "verbose", true, "checkbox", { default=true, } ),
		[5] = self:MakeStandardOption( self.Settings, "Repair items below this %", "threshold", 100, "slider", { min=5, max=100, step=1, default=100, } ),
	}
	optionsTable = self:InjectAdvancedSettings( optionsTable, 1 )
	self.LAM:RegisterAddonPanel(_addon.Name.."_LAM", panelData)
	self.LAM:RegisterOptionControls(_addon.Name.."_LAM", optionsTable)
end

_addon.Initialize = function( self )
    self:RegisterEvent(EVENT_OPEN_STORE, _addon.HandleRepairs, false)
	p = function( msg )
		_addon:Print( "|c610B0B[AutoRepair]"..LWF4_DEFAULT_CHAT_COLOR.." "..tostring(msg).."|r" )
	end
end

if wykkydsAutoRepairGlobal == nil then wykkydsAutoRepairGlobal = {} end
LWF4.REGISTER_FACTORY(
	_addon, false, true,
	function( self ) _addon:LoadSavedVariables( self ) end,
	function( self ) _addon:LoadSettingsMenu( self ) end,
	function( self ) _addon:Initialize( self ) end,
	"wykkydsAutoRepairGlobal", true
)
local totalCost = 0

_addon.RepairItem = function( bag, slot, cost, link )
	totalCost = totalCost + cost
	if _addon:GetOrDefault( true, _addon.Settings["verbose"] ) then
		if bag == 0 then
			p( "Worn Item "..link:gsub("%^%a+","")..""..LWF4_DEFAULT_CHAT_COLOR.." repaired for: |c888800"..tostring( cost ).. ""..LWF4_DEFAULT_CHAT_COLOR.." g" )
		else
			p( "Bagged Item "..link:gsub("%^%a+","")..""..LWF4_DEFAULT_CHAT_COLOR.." repaired for: |c888800"..tostring( cost ).. ""..LWF4_DEFAULT_CHAT_COLOR.." g" )
		end
	end
	RepairItem( bag, slot )
end

_addon.HandleRepairs = function()
	if not _addon:GetOrDefault( true, _addon.Settings["enabled"] ) then return end
	local maxBag = 1
	if _addon:GetOrDefault( false, _addon.Settings["worn"] ) then maxBag = 0 end
	totalCost = 0
    for bag = 0, maxBag, 1 do
        for slot = 0, GetBagSize(bag) do
            local itemName, itemCondition = GetItemName(bag, slot), GetItemCondition(bag, slot)
            if itemName ~= "" and itemCondition < _addon:GetOrDefault( 100, _addon.Settings["threshold"] ) then
                local repairCost, itemLink = GetItemRepairCost(bag, slot), GetItemLink(bag, slot, LINK_STYLE_BRACKETS)
				_addon.RepairItem( bag, slot, repairCost, itemLink )
			end
		end
	end
	if _addon:GetOrDefault( true, _addon.Settings["verbose"] ) then
		if totalCost == 0 then
			p( "Nothing to repair" )
		else
			p( "Total repair cost: |c888800"..tostring( totalCost ).. ""..LWF4_DEFAULT_CHAT_COLOR.." g" )
		end
	end
end

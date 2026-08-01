--[[
  * Wykkyd [ Loot Manager ]
  * Sponsored & Supported by: The Prydonian Elders
  * Author: Ravalox Darkshire (support@ecgroup.us)
  * Embedded: LibStub & libAddonMenu by Seerah.
  * Special Thanks To: Zenimax Online Studios & Bethesda for The Elder Scrolls Online
]]--

-- Added Malachite and Charcoal to exception list 10/2/15 - Ravalox
-- Added Laurel to the exception list 3/15/16 - Ravalox

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
_addon.Name			= "wykkydsLootManager"
_addon.MAJOR 		= _addon.Name..".".._addon._v.major
_addon.MINOR 		= string.format(".%02d%02d%03d", _addon._v.monthly, _addon._v.daily, _addon._v.minor)
_addon.DisplayName  = "Wykkyd Loot Manager"
_addon.SavedVariableVersion = 3
_addon.Player = "" -- will be set on load by LibWykkkydFactory
_addon.Settings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.GlobalSettings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.wykkydPreferred = {
	["loot_gold_chat"] = true,
	["loot_count"] = true,
	["loot_whole_group"] = true,
	["loot_in_chat"] = true,
	["delete_useless"] = false,
}

_addon.__cold = {}
_addon.__stale = {}
_addon.__congealed = {}
_addon.__flat = {}
_addon.__murky = {}
_addon.__cloudy = {}

_addon.LoadSavedVariables = function( self )
	-- Taken from parsing, and then assisted by Dustman's data list ( saved me a lot of parsing, thanks Garkin ;) ) and a couple other sources (thanks to all who mailed me items for testing/parsing)
	self.__cold = self:MakeList{ "30456","30457","30589","32070","32076","32094","32100","32118","32124","32142","32148","37773","37779","37785","37791","37797","37803","37809","37815","37869","37875","37881","37887","37893","37899","37905","37911", }
	self.__stale = self:MakeList{ "30458","30459","30585","30588","30590","32071","32077","32095","32101","32119","32125","32143","32149","37774","37780","37786","37792","37798","37804","37810","37816","37870","37876","37882","37888","37894","37900"
		,"37912","40298", }
	self.__congealed = self:MakeList{ "30460","30461","30586","32072","32078","32096","32102","32120","32126","32144","32150","37775","37781","37787","37793","37799","37805","37811","37817","37871","37877","37883","37889","37895","37901","37907","37913", }
	self.__flat = self:MakeList{ "30450","30451","32067","32073","32091","32097","32115","32121","32139","32145","37770","37776","37782","37788","37794","37800","37806","37812","37866","37872","37878","37884","37890","37896","37902","37908", }
	self.__murky = self:MakeList{ "30452","30453","32068","32074","32092","32098","32116","32122","32140","32146","37771","37777","37783","37789","37795","37801","37807","37813","37867","37873","37879","37885","37891","37897","37903","37909", }
	self.__cloudy = self:MakeList{ "30454","30455","30587","32069","32075","32093","32099","32117","32123","32141","32147","37772","37778","37784","37790","37796","37802","37808","37814","37868","37874","37880","37886","37892","37898","37904","37910", }
end

_addon.LoadSettingsMenu = function( self )
	local panelData = {
		type = "panel",
		name = "Wykkyd Loot Manager",
		displayName = "|cFF2222Wykkyd Loot Manager|r",
		author = "Ravalox",
		version = self.Version,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local optionsTable = {
		[1] = {
			type = "description",
			text = "This addon offers loot notifications and simple loot management. It will override the loot handling features of Wykkyd's Enhanced Chat if enabled.",
		},
		[2] = {
			type = "submenu",
			name = "|cCAB222Loot Announcements|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show loot in chat", "loot_in_chat", true, "checkbox", { default=true, } ),
				[2] = self:MakeStandardOption( self.Settings, "Show bagged count", "loot_count", true, "checkbox", { default=true, } ),
				[3] = self:MakeStandardOption( self.Settings, "Include Gold notices", "loot_gold_chat", true, "checkbox", { default=true, } ),
				[4] = self:MakeStandardOption( self.Settings, "Include Party group", "loot_whole_group", true, "checkbox", { tooltip="Rare or better loot that you party loots. Show loot must be enabled.",default=true, } ),
			},
		},
		[3] = {
			type = "submenu",
			name = "|cCAB222Trash Deletion|r",
			controls = {
				[1] = {
					type = "description",
					text = "Note about auto-delete: While I have made every attempt to make this safe, and reliable, there is a chance that patches, unknown tweaks or edits to this addon by other processes or persons might cause the auto-delete to behave in an unsavory manner. Use at your own risk (I use it, if that helps). Check CONTROLS for keybind options.",
				},
				[2] = self:MakeStandardOption( self.Settings, "Auto-Deletions Enabled (keybindable)", "master_delete", true, "checkbox", { default=true, } ),
				[3] = self:MakeStandardOption( self.Settings, "Notify Deletions", "delete_notify", true, "checkbox", { default=true, } ),
				[4] = self:MakeStandardOption( self.Settings, "Include Useless Gear", "delete_useless", false, "checkbox", { tooltip="Will auto-delete WHITE quality, NO trait armor and weapons of 0 value. This includes items already in your bags.", warning="By enabling this feature you are accepting the risk involved in auto-delete of items.",default=false, } ),
				[5] = self:MakeStandardOption( self.Settings, "Include Old Food", "delete_bad_food", false, "checkbox", { tooltip="Will auto-delete STALE, CONGEALED, etc food items when looting. This includes items already in your bags.", warning="By enabling this feature you are accepting the risk involved in auto-delete of items.",default=false, } ),
				[6] = self:MakeStandardOption( self.Settings, "Include Basic Gems", "delete_bad_gems", false, "checkbox", { tooltip="Will auto-delete vendor-purchasable TRAIT and STYLE gems when looting. This includes items already in your bags.", warning="By enabling this feature you are accepting the risk involved in auto-delete of items.",default=false, } ),
				[7] = self:MakeStandardOption( self.Settings, "Include Lures", "delete_lures", false, "checkbox", { tooltip="Will auto-delete Lures. This includes items already in your bags.", warning="By enabling this feature you are accepting the risk involved in auto-delete of items.",default=false, } ),
			},
		},
	}
	optionsTable[2].controls[1].setFunc = function( val ) self.Settings["loot_in_chat"] = val; _addon.LootInChat(); end
	optionsTable[2].controls[2].setFunc = function( val ) self.Settings["loot_count"] = val; _addon.LootInChat(); end
	optionsTable[2].controls[3].setFunc = function( val ) self.Settings["loot_gold_chat"] = val; _addon.LootInChat(); end
	optionsTable[2].controls[4].setFunc = function( val ) self.Settings["loot_whole_group"] = val; _addon.LootInChat(); end
	optionsTable[3].controls[2].setFunc = function( val ) self.Settings["master_delete"] = val; _addon.LootInChat(); end
	optionsTable[3].controls[3].setFunc = function( val ) self.Settings["delete_notify"] = val; _addon.LootInChat(); end
	optionsTable[3].controls[4].setFunc = function( val ) self.Settings["delete_useless"] = val; _addon.LootInChat(); end
	optionsTable[3].controls[5].setFunc = function( val ) self.Settings["delete_bad_food"] = val; _addon.LootInChat(); end
	optionsTable[3].controls[6].setFunc = function( val ) self.Settings["delete_bad_gems"] = val; _addon.LootInChat(); end
	optionsTable[3].controls[7].setFunc = function( val ) self.Settings["delete_lures"] = val; _addon.LootInChat(); end
	optionsTable = self:InjectAdvancedSettings( optionsTable, 1 )
	self.LAM:RegisterAddonPanel(_addon.Name.."_LAM", panelData)
	self.LAM:RegisterOptionControls(_addon.Name.."_LAM", optionsTable)
end

local UIREADY = false
local notificationsList = {}

local notifyDeletion = function(itemLink, notice)
	if _addon:BufferPause( "item_destroy_notice", 2) then notificationsList = {} end
	if notificationsList[itemLink] == nil then
		notificationsList[itemLink] = true
		_addon:Print( notice )
	end
end

_addon.ToggleMasterDelete = function()
	_addon.Settings["master_delete"] = not _addon:GetOrDefault( true, _addon.Settings["master_delete"] )
	if _addon.Settings["master_delete"] then
		_addon:Print( "|c610B0B[LootManager] |c555555Auto-Delete Enabled" )
	else
		_addon:Print( "|c610B0B[LootManager] |c555555Auto-Delete Disabled" )
	end
end

_addon.deleteUseless = function( itemLink )
	if not _addon:GetOrDefault( false, _addon.Settings["delete_useless"] ) then return false; end
	local itemValue = GetItemLinkValue( itemLink )
	local armorType = GetItemLinkArmorType( itemLink )
	local weaponType =  GetItemLinkWeaponType( itemLink )
	local equipType = GetItemLinkEquipType( itemLink )
	local traitType,_ = GetItemLinkTraitInfo( itemLink )
	return itemValue == 0
		and (
			armorType ~= ARMORTYPE_NONE
			or weaponType ~= WEAPONTYPE_NONE
			or equipType == EQUIP_TYPE_NECK
			or equipType == EQUIP_TYPE_RING
		)
		and traitType == ITEM_TRAIT_TYPE_NONE
		and not IsItemLinkBound( itemLink )
end

_addon.deleteFoodDrink = function( itemLink )
	if not _addon:GetOrDefault( false, _addon.Settings["delete_bad_food"] ) then return false; end
	local iType = GetItemLinkItemType( itemLink )
	local ix = select(4, ZO_LinkHandler_ParseLink( itemLink ) )
	if not ( iType == ITEMTYPE_DRINK or iType == ITEMTYPE_FOOD ) then return false; end
	if _addon.__cold[ix] ~= nil then return true; end
	if _addon.__stale[ix] ~= nil then return true; end
	if _addon.__congealed[ix] ~= nil then return true; end
	if _addon.__flat[ix] ~= nil then return true; end
	if _addon.__murky[ix] ~= nil then return true; end
	if _addon.__cloudy[ix] ~= nil then return true; end
	return false
end

_addon.deleteCommonTraitStyleGems = function( itemLink )
	if not _addon:GetOrDefault( false, _addon.Settings["delete_bad_gems"] ) then return false; end
	local itemType = GetItemLinkItemType( itemLink )
	local name = GetItemLinkName( itemLink )
	return (
			itemType == ITEMTYPE_STYLE_MATERIAL
			or itemType == ITEMTYPE_ARMOR_TRAIT
			or itemType == ITEMTYPE_WEAPON_TRAIT
		) and (
			string.upper(name) ~= "ARGENTUM"                 -- 20	Primal
			and string.upper(name) ~= "COPPER"               -- 18	Barbaric
			and string.upper(name) ~= "PALLADIUM"            -- 16	Ancient Elf
			and string.upper(name) ~= "DAEDRA HEART"         -- 21	Daedric
			and string.upper(name) ~= "MALACHITE SHARD"      -- 29	GLASS
			and string.upper(name) ~= "MALACHITE"            -- 29	GLASS
			and string.upper(name) ~= "CHARCOAL OF REMORSE"  -- 30	XIVKYN
			and string.upper(name) ~= "LAUREL"               -- 27	MERCENARY
			and string.upper(name) ~= "FINE CHALK"           -- 12	Thieves Guild
			and string.upper(name) ~= "BLACK BEESWAX"        -- 13	Dark Brotherhood
			and string.upper(name) ~= "POTASH"               -- 14	Malacath
			and string.upper(name) ~= "PEARL SAND"           -- 17	Order of the Hour			
			and string.upper(name) ~= "AURIC TUSK"           -- 22	TRINIMAC
			and string.upper(name) ~= "CASSITERITE"          -- 23	ANCIENT ORC
			and string.upper(name) ~= "LION FANG"            -- 24	DAGGERFALL COVENANT
			and string.upper(name) ~= "DRAGON SCUTE"         -- 25	EBONHEART PACT
			and string.upper(name) ~= "EAGLE FEATHER"        -- 26	ALDMERI DOMINION
			and string.upper(name) ~= "STAR SAPHIRE"         -- 28	CELESTIAL
			and string.upper(name) ~= "AZURE PLASM"          -- 31	SOUL-SHRIVEN
			and string.upper(name) ~= "PRISTINE SHROUD"      -- 32	DRAUGR
			and string.upper(name) ~= "GOLDSCALE"            -- 34	AKAVIRI
			and string.upper(name) ~= "NICKEL"               -- 35	IMPERIAL
			and string.upper(name) ~= "FERROUS SALTS"        -- 36	YOKUDAN
			and string.upper(name) ~= "CROWN MIMIC STONE"    -- 37	MIMIC (ANY)
			and string.upper(name) ~= "OXBLOOD FUNGUS"       -- 40	MINOTAUR
			and string.upper(name) ~= "NIGHT PUMICE"         -- 41	EBONY
			and string.upper(name) ~= "POLISHED SHILLING"    -- 42	ABAH'S WATCH
			and string.upper(name) ~= "WOLFSBANE INCENSE"    -- 43	SKINCHANGER
			and string.upper(name) ~= "SANDSTONE"            -- 45	RA GADA
			and string.upper(name) ~= "DEFILED WHISKERS"     -- 46	DRO-M'ATHRA   (60$ my ass)
			and string.upper(name) ~= "TAINTED BLOOD"        -- 47	ASSASSINS LEAGUE
			and string.upper(name) ~= "ROGUE'S SOOT"         -- 48	OUTLAW
			and string.upper(name) ~= "STALHRIM SHARD"       -- 54	FROSTCASTER
			and string.upper(name) ~= "DISTILLED SLOWSILVER" -- 57	SILKEN RING
			and string.upper(name) ~= "LEVIATHAN SCRIMSHAW"  -- 58	MAZZATUN
			and string.upper(name) ~= "GRINSTONES"           -- 59	GRIM HARLEQUIN
			and string.upper(name) ~= "AMBER MARBLE"         -- 60	HOLLOWJACK
			
			and (not _addon:EndsWith( name, "nirncrux" ))
		)
end

_addon.deleteLures = function( itemLink )
	if not _addon:GetOrDefault( false, _addon.Settings["delete_lures"] ) then return false; end
	local itemType = GetItemLinkItemType( itemLink )
	return itemType == ITEMTYPE_LURE
end

_addon.handleDeletes = function(...)
	local masterDelete = _addon:GetOrDefault( true, _addon.Settings["master_delete"] )
	local delNotify = _addon:GetOrDefault( true, _addon.Settings["delete_notify"] )
	local hadToDelete, bSize = false, GetBagSize( 1 )
	local eventCode, lootedBy, itemName, quantity, itemSound, lootType, self = ...
	if not ( masterDelete or eventCode == -666 ) then return end
	if itemName == nil then itemName = "" end
	itemName = itemName:gsub("%^%a+","")
	for ii = 1, bSize, 1 do
		local iLink = GetItemLink( 1, ii ):gsub("%^%a+","")
		local iName = GetItemName( 1, ii )
		local ix = select(4, ZO_LinkHandler_ParseLink( iLink ) )
		if _addon.deleteUseless( iLink )
		or _addon.deleteFoodDrink( iLink )
		or _addon.deleteCommonTraitStyleGems( iLink )
		or _addon.deleteLures( iLink )
		and (
			ix ~= "57587" 		-- 15	Dwemer	Dwemer Frame
			and ix ~= "57665" 	-- Dwemer Scrap
		)
		then
			if itemName~= "" then if GetItemLinkName( itemName ) == iName then hadToDelete = true end end
			DestroyItem(1, ii)
			if delNotify then notifyDeletion( iLink, "|c610B0B[LootManager] |c555555[ "..iLink.." |c555555] deleted" ) end
		end
	end
	return hadToDelete
end

local lootToChat = function(...)
	local masterDelete = _addon:GetOrDefault( true, _addon.Settings["master_delete"] )
	local notifyLoot = _addon:GetOrDefault( true, _addon.Settings["loot_in_chat"] )
	local delUseless = _addon:GetOrDefault( false, _addon.Settings["delete_useless"] )
	local delBadFood = _addon:GetOrDefault( false, _addon.Settings["delete_bad_food"] )
	local delBadGems = _addon:GetOrDefault( false, _addon.Settings["delete_bad_gems"] )
	local delNotify = _addon:GetOrDefault( true, _addon.Settings["delete_notify"] )
	local delLures = _addon:GetOrDefault( false, _addon.Settings["delete_lures"] )
	local green, hadToDelete = "0B610B", false
	local bSize = GetBagSize( 1 )
	local eventCode, lootedBy, itemName, quantity, itemSound, lootType, self = ...
	itemName = itemName:gsub("%^%a+","")
	if masterDelete and ( delUseless or delBadFood or delBadGems or delLures ) and self then
		hadToDelete = _addon.handleDeletes(eventCode, lootedBy, itemName, quantity, itemSound, lootType, self)
	end
	if self and notifyLoot and (not hadToDelete) then
		local inBags, haveCount = 0, ""
		if _addon:GetOrDefault( true, _addon.Settings["loot_count"] ) then
			local lName = GetItemLinkName( itemName )
			for ii = 1, bSize, 1 do
				local nm = GetItemName( 1, ii )
				if lName == nm then inBags = GetItemTotalCount( 1, ii ); break; end
			end
		end
		if inBags > 0 then
			_addon:Print("|c"..green.."Looted [ " .. itemName.. " |c"..green.."][ |cBEF781" .. quantity .. "|c"..green.." ]{|c886A08 "..tostring(inBags).." |c"..green.."}" )
		else
			_addon:Print("|c"..green.."Looted [ " .. itemName.. " |c"..green.."] x|cBEF781" .. quantity )
		end
	else
		if _addon:GetOrDefault( true, _addon.Settings["loot_whole_group"] ) and lootType == LOOT_TYPE_ITEM and notifyLoot then
			local icon,sellPrice,meetsUsageRequirement,equipType,itemStyle = GetItemLinkInfo(itemName)
			local quality = GetItemLinkQuality(itemName)
			if equipType ~= 0 and ( quality >= 3 ) then
				_addon:Print( "|c32CE41" .. lootedBy:gsub("%^%a+","") .. " Got: [ " .. itemName:gsub("%^%a+","") .. "|c32CE41 ] " .. quantity .."" )
			end
		end
	end

end

local goldQueue = {}
local lastGold = GetFrameTimeMilliseconds()
local goldTic = false

local goldToChat = function()
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
	if _addon:GetOrDefault( true, _addon.Settings["loot_in_chat"] ) or _addon:GetOrDefault( false, _addon.Settings["delete_useless"] )
	or _addon:GetOrDefault( false, _addon.Settings["delete_bad_food"] )  or _addon:GetOrDefault( false, _addon.Settings["delete_bad_gems"]
	or _addon:GetOrDefault( false, _addon.Settings["delete_lures"] )
	) then
		_addon:RegisterEvent( EVENT_LOOT_RECEIVED, lootToChat )
	else
		_addon:UnregisterEvent( EVENT_LOOT_RECEIVED )
	end
	if _addon:GetOrDefault( true, _addon.Settings["loot_gold_chat"] ) then
		_addon:RegisterEvent( EVENT_MONEY_UPDATE, goldPrep )
	else
		_addon:UnregisterEvent( EVENT_MONEY_UPDATE )
	end
end

_addon.Initialize = function( self ) self.LootInChat() end

if wykkydsLootManagerGlobal == nil then wykkydsLootManagerGlobal = {} end
LWF4.REGISTER_FACTORY(
	_addon, false, true,
	function( self ) _addon:LoadSavedVariables( self ) end,
	function( self ) _addon:LoadSettingsMenu( self ) end,
	function( self ) _addon:Initialize( self ) end,
	"wykkydsLootManagerGlobal", true
)

WYK_LootManager = _addon


--[[

	Addon: ADVANCED LOOT TRACKER
	Created by: @Lum1on

]]--

local LibAM = LibStub:GetLibrary ( "LibAddonMenu-2.0" )
local LibS = LibStub:GetLibrary ( "LibScroll_Modified" )

AdvancedLootTracker = { }
AdvancedLootTracker.name = "AdvancedLootTracker"
AdvancedLootTracker.version = 1.0

--
-- MISC. FUNCTIONS

local function UpdateLootTable ( dataItem, _item, _player )
	local dataItems = { }
	
	if dataItem then
		local dataTable = {
			text = dataItem,
			item = _item,
			player = _player
		}
		
		table.insert ( dataItems, dataTable )
	end
	
	return dataItems
end

local function CreateWindow ( )
	LootWindow = WINDOW_MANAGER:CreateTopLevelWindow ( "LootTable" )
	
	if AdvancedLootTracker.LootWindowX
	and AdvancedLootTracker.LootWindowY then
		LootWindow:SetAnchor ( TOPLEFT, GuiRoot, TOPLEFT, AdvancedLootTracker.LootWindowX, AdvancedLootTracker.LootWindowY )
	else
		LootWindow:SetAnchor ( TOPLEFT, GuiRoot, TOPLEFT, 200.0, 200.0 )
	end
	
	local _LootWindowWidth = ( AdvancedLootTracker.LootWindowWidth or 500.0 )
	local _LootWindowHeight = ( AdvancedLootTracker.LootWindowHeight or 300.0 )
	
	LootWindow:SetDimensions ( _LootWindowWidth, _LootWindowHeight )
	LootWindow:SetMouseEnabled ( false )
	LootWindow:SetMovable ( false )
	LootWindow:SetResizeHandleSize ( 5.0 )
	LootWindow:SetClampedToScreen ( true )
	LootWindow:SetDimensionConstraints ( 300.0, 100.0, 700.0, 500.0 )
	
	if AdvancedLootTracker.Position == "Chat" then
		LootWindow:SetHidden ( true )
	else
		LootWindow:SetHidden ( false )
	end
	
	LootWindow.Title = WINDOW_MANAGER:CreateControlFromVirtual ( "LootWindowTitle", LootWindow, "_LootWindowTitle" )
	LootWindow.Title:SetDimensions (( LootWindow:GetWidth ( ) - 30.0 ), 35.0 )
	
	LootWindow.Settings = WINDOW_MANAGER:CreateControlFromVirtual ( "LootWindowSettings", LootWindow, "_LootWindowSettings" )
	
	LootWindow.Background = WINDOW_MANAGER:CreateControlFromVirtual ( "LootTableBackground", LootWindow, "ZO_DefaultBackdrop" )
	LootWindow.Background:SetAnchorFill ( )
	LootWindow.Background:SetAlpha ( AdvancedLootTracker.Opacity / 100.0 )
	
	LootWindow:SetHandler ( "OnMoveStop", function ( )
		AdvancedLootTracker.LootWindowX = LootWindow:GetLeft ( )
		AdvancedLootTracker.savedVariables.LootWindowX = LootWindow:GetLeft ( )
		
		AdvancedLootTracker.LootWindowY = LootWindow:GetTop ( )
		AdvancedLootTracker.savedVariables.LootWindowY = LootWindow:GetTop ( )
	end )
	
	LootWindow:SetHandler ( "OnResizeStop", function ( )
		-- AdvancedLootTracker.LootWindowWidth = LootWindow:GetWidth ( )
		AdvancedLootTracker.savedVariables.LootWindowWidth = LootWindow:GetWidth ( )
		
		-- AdvancedLootTracker.LootWindowHeight = LootWindow:GetHeight ( )
		AdvancedLootTracker.savedVariables.LootWindowHeight = LootWindow:GetHeight ( )
		
		LootWindow.Title:SetDimensions (( LootWindow:GetWidth ( ) - 30.0 ), 35.0 )
		lootTable:SetDimensions (( LootWindow:GetWidth ( ) - 30.0 ), ( LootWindow:GetHeight ( ) - 60.0 ))
	end )
	
	LootWindow.Settings:SetHandler ( "OnMouseDown", function ( _control, _button )
		if _button == MOUSE_BUTTON_INDEX_LEFT or _button == MOUSE_BUTTON_INDEX_RIGHT then
			ClearMenu ( )
			
			AddMenuItem ( "Clear history", function ( )
				local x = ""
				
				if AdvancedLootTracker.Time then
					x = zo_strformat ( "[<<1>>] ",
					string.sub ( GetTimeString ( ), 0.0, 5.0 ))
				end
	
				lootTable:Clear ( )
				
				d (
					zo_strformat ( "<<1>>Loot tracker history has been cleared.",
					x )
				)
			end )
			
			if AdvancedLootTracker.Lock then
				AddMenuItem ( "Unlock window", function ( )
					LootWindow:SetMouseEnabled ( true )
					LootWindow:SetMovable ( true )
					LootWindow:SetResizeHandleSize ( 5.0 )
					
					AdvancedLootTracker.Lock = false
				end )
			else
				AddMenuItem ( "Lock window", function ( )
					LootWindow:SetMouseEnabled ( false )
					LootWindow:SetMovable ( false )
					LootWindow:SetResizeHandleSize ( 0.0 )
					
					AdvancedLootTracker.Lock = true
				end )
			end
			
			ShowMenu ( _control )
		end
	end )
	
	return LootWindow
end

local function SetupData ( rowControl, dataTable, lootTable )
	rowControl:SetText ( dataTable.text )
	rowControl:SetFont ( "ZoFontWinH4" )
	
	rowControl:SetHandler ( "OnMouseUp", function ( )
		local x = ""
		
		if AdvancedLootTracker.Time then
			x = zo_strformat ( "[<<1>>] ",
			string.sub ( GetTimeString ( ), 0.0, 5.0 ))
		end
		
		d (
			zo_strformat ( "<<1>><<2>> looted <<3>>",
			x, dataTable.player, dataTable.item )
		)
	end )
end

local function SelectData ( previousData, selectedData, reselecting )
	--
end

local function CreateLootTable ( )
	local mainWindow = CreateWindow ( )
	
	local dataTable = {
		name = "LootTableWindow",
		parent = mainWindow,
		width = ( LootWindow:GetWidth ( ) - 30.0 ),
		height = ( LootWindow:GetHeight ( ) - 60.0 ),
		rowHeight = 26.0,
		setupCallback = SetupData,
		selectCallback = SelectData
	}
	
	lootTable = LibS:CreateScrollList ( dataTable )
	
	lootTable:SetAnchor ( TOPLEFT, mainWindow, TOPLEFT, 15.0, 50.0 )
	
	return lootTable
end

local function InitializeScrollList ( )
	lootTable = CreateLootTable ( )
	local lootTableData = UpdateLootTable ( )
		
	lootTable:Update ( lootTableData )
end

local function AddonSettings ( )
	local panelData = {
		type = "panel",
		name = "Advanced loot tracker",
		displayName = "Advanced loot tracker -settings",
		author = "@Lum1on",
		version = "1.3",
		slashCommand = "/loot settings",
		registerForRefresh = true,
		registerForDefaults = true
	}
	
	local cntrlOptionsPanel = LibAM:RegisterAddonPanel ( "AdvancedLootTrackerPanel", panelData )
	
	local optionsData = {
		[1] = {
			type = "header",
			name = "Basic ",
			width = "full"
		},
		
		--[[
		
		[x] = {
			type = "button",
			name = "",
			-- tooltip = "",
			width = "full",
			
			func = function ( )
				--
			end
		},
		
		]]--
		
		[2] = {
			type = "checkbox",
			name = "Enable addon",
			-- tooltip = "",
			default = true,
			width = "full",
			
			getFunc = function ( )
				return AdvancedLootTracker.savedVariables.Loot
			end,
			
			setFunc = function ( Loot )
				AdvancedLootTracker.Loot = Loot
				AdvancedLootTracker.savedVariables.Loot = Loot
			end
		},
		
		[3] = {
			type = "dropdown",
			name = "Position",
			-- tooltip = "",
			default = "Window",
			width = "full",
			
			choices = {
				"Chat",
				"Window"
			},
			
			getFunc = function ( )
				return AdvancedLootTracker.savedVariables.Position
			end,
			
			setFunc = function ( Position )
				AdvancedLootTracker.Position = Position
				AdvancedLootTracker.savedVariables.Position = Position
				
				if AdvancedLootTracker.Position == "Chat" then
					LootWindow:SetHidden ( true )
				else
					LootWindow:SetHidden ( false )
				end
			end
		},
		
		[4] = {
			type = "checkbox",
			name = "Icons",
			-- tooltip = "",
			default = true,
			width = "full",
			
			getFunc = function ( )
				return AdvancedLootTracker.savedVariables.Icons
			end,
			
			setFunc = function ( Icons )
				AdvancedLootTracker.Icons = Icons
				AdvancedLootTracker.savedVariables.Icons = Icons
			end
		},
		
		[5] = {
			type = "checkbox",
			name = "Show timestamp",
			-- tooltip = "",
			default = false,
			width = "full",
			
			getFunc = function ( )
				return AdvancedLootTracker.savedVariables.Time
			end,
			
			setFunc = function ( Time )
				AdvancedLootTracker.Time = Time
				AdvancedLootTracker.savedVariables.Time = Time
			end
		},

		[6] = {
			type = "slider",
			name = "Background opacity",
			-- tooltip = "",
			min = 0.0,
			max = 100.0,
			step = 5.0,
			default = 50.0,
			width = "full",
			
			getFunc = function ( )
				return AdvancedLootTracker.savedVariables.Opacity
			end,
			
			setFunc = function ( Opacity )
				AdvancedLootTracker.Opacity = Opacity
				AdvancedLootTracker.savedVariables.Opacity = Opacity
				
				LootWindow.Background:SetAlpha ( Opacity / 100.0 )
			end
		},
		
		[7] = {
			type = "header",
			name = "Filters",
			width = "full"
		},
		
		[8] = {
			type = "checkbox",
			name = "Currency",
			-- tooltip = "",
			default = true,
			width = "full",
			
			getFunc = function ( )
				return AdvancedLootTracker.savedVariables.Currency
			end,
			
			setFunc = function ( Currency )
				AdvancedLootTracker.Currency = Currency
				AdvancedLootTracker.savedVariables.Currency = Currency
			end
		},
		
		[9] = {
			type = "slider",
			name = "Money (update interval)",
			-- tooltip = "",
			min = 0.0,
			max = 10000.0,
			step = 500.0,
			default = 5000.0,
			width = "full",
			
			getFunc = function ( )
				return AdvancedLootTracker.savedVariables.Money
			end,
			
			setFunc = function ( Money )
				AdvancedLootTracker.Money = Money
				AdvancedLootTracker.savedVariables.Money = Money
			end
		},
		
		[10] = {
			type = "dropdown",
			name = "Quality",
			-- tooltip = "",
			default = "|c2DC50EFine",
			width = "full",
			
			choices = {
				"|cC5C29ENormal",
				"|c2DC50EFine",
				"|c3A92FFSuperior",
				"|cA02EF7Epic",
				"|cCCAA1ALegendary"
			},
			
			getFunc = function ( )
				return AdvancedLootTracker.savedVariables.Quality
			end,
			
			setFunc = function ( Quality )
				AdvancedLootTracker.Quality = Quality
				AdvancedLootTracker.savedVariables.Quality = Quality
			end
		},
		
		[11] = {
			type = "editbox",
			name = "Keyword",
			-- tooltip = "",
			isMultiline = false,
			default = "",
			width = "full",
			
			getFunc = function ( )
				return AdvancedLootTracker.savedVariables.Filter
			end,
			
			setFunc = function ( Filter )
				local x = ""
				
				if AdvancedLootTracker.Time then
					x = zo_strformat ( "[<<1>>] ",
					string.sub ( GetTimeString ( ), 0.0, 5.0 ))
				end
		
				AdvancedLootTracker.Filter = string.lower ( Filter )
				AdvancedLootTracker.savedVariables.Filter = string.lower ( Filter )
				
				if Filter == "" then
					d (
						zo_strformat ( "<<1>>No longer tracking items with a keyword.",
						x )
					)
				else
					d (
						zo_strformat ( "<<1>>Tracking items with a keyword \"<<2>>\".",
						x, string.lower ( Filter ))
					)
				end
			end
		},
		
		[12] = {
			type = "header",
			name = "Gear",
			width = "full"
		},
		
		[13] = {
			type = "checkbox",
			name = "Display traits",
			-- tooltip = "",
			default = true,
			width = "full",
					
			getFunc = function ( )
				return AdvancedLootTracker.savedVariables.Trait
			end,
					
			setFunc = function ( Trait )
				AdvancedLootTracker.Trait = Trait
				AdvancedLootTracker.savedVariables.Trait = Trait
			end
		},
		
		[14] = {
			type = "dropdown",
			name = "Armor",
			-- tooltip = "",
			default = "All",
			width = "full",
			
			choices = {
				"All",
				"Divines",
				"Impenetrable",
				"Infused",
				"Nirnhoned",
				"Prosperous",
				"Reinforced",
				"Sturdy",
				"Training",
				"Well-fitted"
			},
			
			getFunc = function ( )
				return AdvancedLootTracker.savedVariables.ArmorTrait
			end,
			
			setFunc = function ( ArmorTrait )
				AdvancedLootTracker.ArmorTrait = ArmorTrait
				AdvancedLootTracker.savedVariables.ArmorTrait = ArmorTrait
			end
		},
		
		[15] = {
			type = "dropdown",
			name = "Weapon",
			-- tooltip = "",
			default = "All",
			width = "full",
			
			choices = {
				"All",
				"Charged",
				"Decisive",
				"Defending",
				"Infused",
				"Nirnhoned",
				"Powered",
				"Precise",
				"Sharpened",
				"Training"
			},
			
			getFunc = function ( )
				return AdvancedLootTracker.savedVariables.WeaponTrait
			end,
			
			setFunc = function ( WeaponTrait )
				AdvancedLootTracker.WeaponTrait = WeaponTrait
				AdvancedLootTracker.savedVariables.WeaponTrait = WeaponTrait
			end
		},
		
		[16] = {
			type = "dropdown",
			name = "Jewelry",
			-- tooltip = "",
			default = "All",
			width = "full",
			
			choices = {
				"All",
				"Arcane",
				"Healthy",
				"Robust"
			},
			
			getFunc = function ( )
				return AdvancedLootTracker.savedVariables.JewelryTrait
			end,
			
			setFunc = function ( JewelryTrait )
				AdvancedLootTracker.JewelryTrait = JewelryTrait
				AdvancedLootTracker.savedVariables.JewelryTrait = JewelryTrait
			end
		},
		
		[17] = {
			type = "header",
			name = "Group",
			width = "full"
		},
		
		[18] = {
			type = "checkbox",
			name = "Group loot",
			-- tooltip = "",
			default = true,
			width = "full",
					
			getFunc = function ( )
				return AdvancedLootTracker.savedVariables.Group
			end,
					
			setFunc = function ( Group )
				AdvancedLootTracker.Group = Group
				AdvancedLootTracker.savedVariables.Group = Group
			end
		}
	}
	
	LibAM:RegisterOptionControls ( "AdvancedLootTrackerPanel", optionsData )
end

-- Formatting numbers:
-- http://lua-users.org/wiki/FormattingNumbers

local function comma_value ( a )
	local amount = a
	local i
	
	while true do
		amount, i = string.gsub ( amount, "^(-?%d+)(%d%d%d)", '%1,%2' )
		
		if i == 0.0 then
			break
		end
	end
	
	return amount
end

--
-- "EVENT_LOOT_RECEIVED"

local function LootReceived ( eventCode, lootedBy, itemLink, quantity, itemSound, lootType, self )
	if AdvancedLootTracker.Loot then
		local looted_by = lootedBy
		
		if string.find ( lootedBy, "%^" ) then
			looted_by = string.sub ( lootedBy, 0, ( string.find ( lootedBy, "%^" ) - 1.0 ))
		end
		
		local x = ""
		local y = ""
		local z = ""
		
		if AdvancedLootTracker.Time then
			x = zo_strformat ( "[<<1>>] ",
			string.sub ( GetTimeString ( ), 0.0, 5.0 ))
		end
		
		if AdvancedLootTracker.Filter ~= "" then
			if string.find ( string.lower ( GetItemLinkName ( itemLink )), AdvancedLootTracker.Filter ) == nil then
				return
			end
		end
		
		local icon, sellPrice, meetsUsageRequirement, equipType, itemStyle = GetItemLinkInfo ( itemLink )
		local traitType, traitDescription, traitSubtype, traitSubtypeName, traitSubtypeDescription = GetItemLinkTraitInfo ( itemLink )
		
		local temp_Icon = ""
		
		if AdvancedLootTracker.Icons then
			temp_Icon = zo_strformat ( "|t24:24:<<1>>|t",
			icon )
		end
		
		if AdvancedLootTracker.savedVariables.Trait
		and traitType > 0.0
		and AdvancedLootTracker.Traits [ traitType ] ~= "" then
			y = zo_strformat ( " (<<1>>)",
			AdvancedLootTracker.Traits [ traitType ])
		end
		
		if AdvancedLootTracker.savedVariables.ArmorTrait ~= "All" then
			local equipTypeArmor = {
				EQUIP_TYPE_CHEST,
				EQUIP_TYPE_FEET,
				EQUIP_TYPE_HAND,
				EQUIP_TYPE_HEAD,
				EQUIP_TYPE_LEGS,
				EQUIP_TYPE_SHOULDERS,
				EQUIP_TYPE_WAIST,
				EQUIP_TYPE_OFF_HAND
			}
			
			local i
		
			for i = 1.0, table.getn ( equipTypeArmor ), 1.0 do
				if equipType == equipTypeArmor [ i ] then
					if AdvancedLootTracker.Traits [ traitType ] ~= AdvancedLootTracker.savedVariables.ArmorTrait then
						return
					end
					
					break
				end
			end
		end
		
		if AdvancedLootTracker.savedVariables.WeaponTrait ~= "All" then
			local equipTypeWeapon = {
				EQUIP_TYPE_ONE_HAND,
				EQUIP_TYPE_TWO_HAND
			}
			
			local j
		
			for j = 1.0, table.getn ( equipTypeWeapon ), 1.0 do
				if equipType == equipTypeWeapon [ j ] then
					if AdvancedLootTracker.Traits [ traitType ] ~= AdvancedLootTracker.savedVariables.WeaponTrait then
						return
					end
					
					break
				end
			end
		end
		
		if AdvancedLootTracker.savedVariables.JewelryTrait ~= "All" then
			local equipTypeJewelry = {
				EQUIP_TYPE_NECK,
				EQUIP_TYPE_RING
			}
			
			local k
		
			for k = 1.0, table.getn ( equipTypeJewelry ), 1.0 do
				if equipType == equipTypeJewelry [ k ] then
					if AdvancedLootTracker.Traits [ traitType ] ~= AdvancedLootTracker.savedVariables.JewelryTrait then
						return
					end
					
					break
				end
			end
		end
		
		local temp_Quality
		
		if AdvancedLootTracker.Quality == "|cC5C29ENormal" then
			temp_Quality = ITEM_QUALITY_NORMAL
		elseif AdvancedLootTracker.Quality == "|c2DC50EFine" then
			temp_Quality = ITEM_QUALITY_MAGIC
		elseif AdvancedLootTracker.Quality == "|c3A92FFSuperior" then
			temp_Quality = ITEM_QUALITY_ARCANE
		elseif AdvancedLootTracker.Quality == "|cA02EF7Epic" then
			temp_Quality = ITEM_QUALITY_ARTIFACT
		elseif AdvancedLootTracker.Quality == "|cCCAA1ALegendary" then
			temp_Quality = ITEM_QUALITY_LEGENDARY
		end
		
		if GetItemLinkQuality ( itemLink ) > ( temp_Quality - 1.0 ) then
			if zo_strformat ( SI_UNIT_NAME, lootedBy ) == GetUnitName ( "player" ) then
				local stackCountBackpack, stackCountBank, stackCountCraftBag = GetItemLinkStacks ( itemLink )
				
				local item_total_count = ""
				
				if stackCountBackpack > 1.0 then
					item_total_count = zo_strformat ( "<<1>> (<<2>>)",
					item_total_count, comma_value ( stackCountBackpack ))
				end
				
				if stackCountBank > 1.0 then
					item_total_count = zo_strformat ( "<<1>> (<<2>>)",
					item_total_count, comma_value ( stackCountBank ))
				end
				
				if stackCountCraftBag > 1.0 then
					item_total_count = zo_strformat ( "<<1>> (|t24:24:esoui/art/tooltips/icon_craft_bag.dds|t <<2>>)",
					item_total_count, comma_value ( stackCountCraftBag ))
				end
				
				if quantity == 1.0 then
					z = zo_strformat ( "<<1>>You looted <<2>> <<3>> <<4>> <<5>>",
					x, temp_Icon, itemLink, y, item_total_count )
				else
					z = zo_strformat ( "<<1>>You looted <<2>> x <<3>> <<4>> <<5>> <<6>>",
					x, quantity, temp_Icon, itemLink, y, item_total_count )
				end
			else
				if AdvancedLootTracker.Group then
					if quantity == 1.0 then
						z = zo_strformat ( "<<1>><<2>> looted <<3>> <<4>> <<5>> <<6>>",
						x, ZO_LinkHandler_CreateLink ( zo_strformat ( SI_UNIT_NAME, lootedBy ), LINK_STYLE_BRACKETS, DISPLAY_NAME_LINK_TYPE, lootedBy ), temp_Icon, itemLink, y )
					else
						z = zo_strformat ( "<<1>><<2>> looted <<3>> x <<4>> <<5>> <<6>> <<7>>",
						x, ZO_LinkHandler_CreateLink ( zo_strformat ( SI_UNIT_NAME, lootedBy ), LINK_STYLE_BRACKETS, DISPLAY_NAME_LINK_TYPE, lootedBy ), quantity, temp_Icon, itemLink, y )
					end
				end
			end
		end
		
		if z ~= "" then
			if AdvancedLootTracker.Position == "Chat" then
				d ( z )
			else
				local lootTableData = UpdateLootTable ( z, itemLink, ZO_LinkHandler_CreateLink ( zo_strformat ( SI_UNIT_NAME, lootedBy ), LINK_STYLE_BRACKETS, DISPLAY_NAME_LINK_TYPE, lootedBy ))
				
				lootTable:Update ( lootTableData )
			end
		end
	end
end

--
-- "EVENT_MONEY_UPDATE"

local function MoneyUpdate ( eventCode, newMoney, oldMoney, reason )
	if AdvancedLootTracker.Currency then		
		if AdvancedLootTracker.OldMoney == 0.0 then
			AdvancedLootTracker.OldMoney = oldMoney
		end
		
		if newMoney - AdvancedLootTracker.OldMoney >= AdvancedLootTracker.Money
		or AdvancedLootTracker.OldMoney - newMoney >= AdvancedLootTracker.Money then
			local x = ""
			local z = ""
			
			if AdvancedLootTracker.Time then
				x = zo_strformat ( "[<<1>>] ",
				string.sub ( GetTimeString ( ), 0.0, 5.0 ))
			end
			
			local temp_Icon = ""
			
			if AdvancedLootTracker.Icons then
				temp_Icon = "|t24:24:esoui/art/currency/currency_gold_32.dds|t "
			end
			
			z = zo_strformat ( "<<1>>You have <<2>><<3>> gold.", -- (<<4>>).",
			x, temp_Icon, comma_value ( newMoney )) --, comma_value ( newMoney - AdvancedLootTracker.OldMoney ))
			
			local lootTableData = UpdateLootTable ( z )
				
			lootTable:Update ( lootTableData )
			
			AdvancedLootTracker.OldMoney = newMoney
		end
	end
end

--
-- "EVENT_ADD_ON_LOADED"

local function AddOnLoaded ( event, addonName )
	if addonName == AdvancedLootTracker.name then
		AdvancedLootTracker.Lock = true
		AdvancedLootTracker.OldMoney = 0.0
		
		AdvancedLootTracker.Default = {
			Loot = true,
			Currency = true,
			Group = true,
			Quality = "|c2DC50EFine",
			Filter = "",
			Time = false,
			Trait = true,
			ArmorTrait = "All",
			WeaponTrait = "All",
			JewelryTrait = "All",
			Opacity = 50.0,
			Money = 5000.0,
			Position = "Window",
			Icons = true
		}
		
		AdvancedLootTracker.Traits =  {
			"Powered",
			"Charged",
			"Precise",
			"Infused",
			"Defending",
			"Training",
			"Sharpened",
			"Decisive",
			"Intricate",
			"Ornate",
			"Sturdy",
			"Impenetrable",
			"Reinforced",
			"Well-fitted",
			"Training",
			"Infused",
			"Prosperous",
			"Divines",
			"Ornate",
			"Intricate",
			"Healthy",
			"Arcane",
			"Robust",
			"Ornate",
			"Nirnhoned",
			"Nirnhoned",
			"",
		}
		
		AdvancedLootTracker.savedVariables = ZO_SavedVars:NewAccountWide ( "AdvancedLootTrackerVariables", AdvancedLootTracker.version, nil, AdvancedLootTracker.Default )
		
		AddonSettings ( )
		
		AdvancedLootTracker.Loot = AdvancedLootTracker.savedVariables.Loot
		AdvancedLootTracker.Currency = AdvancedLootTracker.savedVariables.Currency
		AdvancedLootTracker.Group = AdvancedLootTracker.savedVariables.Group
		AdvancedLootTracker.Quality = AdvancedLootTracker.savedVariables.Quality
		AdvancedLootTracker.Filter = AdvancedLootTracker.savedVariables.Filter
		AdvancedLootTracker.Time = AdvancedLootTracker.savedVariables.Time
		AdvancedLootTracker.Trait = AdvancedLootTracker.savedVariables.Trait
		AdvancedLootTracker.ArmorTrait = AdvancedLootTracker.savedVariables.ArmorTrait
		AdvancedLootTracker.WeaponTrait = AdvancedLootTracker.savedVariables.WeaponTrait
		AdvancedLootTracker.JewelryTrait = AdvancedLootTracker.savedVariables.JewelryTrait
		AdvancedLootTracker.Opacity = AdvancedLootTracker.savedVariables.Opacity
		AdvancedLootTracker.Money = AdvancedLootTracker.savedVariables.Money
		AdvancedLootTracker.Position = AdvancedLootTracker.savedVariables.Position
		AdvancedLootTracker.Icons = AdvancedLootTracker.savedVariables.Icons
		
		AdvancedLootTracker.LootWindowX = AdvancedLootTracker.savedVariables.LootWindowX
		AdvancedLootTracker.LootWindowY = AdvancedLootTracker.savedVariables.LootWindowY
		AdvancedLootTracker.LootWindowWidth = AdvancedLootTracker.savedVariables.LootWindowWidth
		AdvancedLootTracker.LootWindowWidth = AdvancedLootTracker.savedVariables.LootWindowWidth
		
		InitializeScrollList ( )
		
		EVENT_MANAGER:RegisterForEvent ( AdvancedLootTracker.name, EVENT_LOOT_RECEIVED, LootReceived )
		EVENT_MANAGER:RegisterForEvent ( AdvancedLootTracker.name, EVENT_MONEY_UPDATE, MoneyUpdate )
		
		EVENT_MANAGER:UnregisterForEvent ( AdvancedLootTracker.name, EVENT_ADD_ON_LOADED )
	end
end

--
-- MAIN FUNCTION

EVENT_MANAGER:RegisterForEvent ( AdvancedLootTracker.name, EVENT_ADD_ON_LOADED, AddOnLoaded )

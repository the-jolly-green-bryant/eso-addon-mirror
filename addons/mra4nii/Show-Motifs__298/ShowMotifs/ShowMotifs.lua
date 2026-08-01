------------------------------------------------------------------
--ShowMotifs.lua
--Author: mra4nii & Phinix
--[[
Based on "Research Assistant" framework by ingeniousclown, 
used with his permission

Shows you the racial motif the armor type of weapsons and armors 
in your inventory.
]]
------------------------------------------------------------------
-- our global variables
local ShowMotifs = _G['ShowMotifs']
-- table to check equip type, anything we don't need is -1
local equipTypes = {
	[EQUIP_TYPE_CHEST] = 3,
	[EQUIP_TYPE_COSTUME] = -1,
	[EQUIP_TYPE_FEET] = 10,
	[EQUIP_TYPE_HAND] = 13,
	[EQUIP_TYPE_HEAD] = 1,
	[EQUIP_TYPE_INVALID] = -1,
	[EQUIP_TYPE_LEGS] = 9,
	[EQUIP_TYPE_MAIN_HAND] = 100,
	[EQUIP_TYPE_NECK] = -1,
	[EQUIP_TYPE_OFF_HAND] = 100,
	[EQUIP_TYPE_ONE_HAND] = 100,
	[EQUIP_TYPE_POISON] = -1,
	[EQUIP_TYPE_RING] = -1,
	[EQUIP_TYPE_SHOULDERS] = 4,
	[EQUIP_TYPE_TWO_HAND] = 100,
	[EQUIP_TYPE_WAIST] = 8,
	}

local RARE_TEXTURE = [[/esoui/art/buttons/swatchframe_over.dds]]

-- where do we want to show our icons
local BACKPACK = ZO_PlayerInventoryBackpack
local BANK = ZO_PlayerBankBackpack
local GUILD_BANK = ZO_GuildBankBackpack
local DECONSTRUCTION = ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack
local IMPROVEMENT = ZO_SmithingTopLevelImprovementPanelInventoryBackpack
local STORE = ZO_StoreWindowList
local STORE_BUYBACK = ZO_BuyBackList
local STORE_REPAIR = ZO_RepairWindowList

local SMSettings = nil

--
-- functions to manipulate tooltips for icons
local function AddTooltips(control, text)
	control:SetHandler("OnMouseEnter", function(self)
			ZO_Tooltips_ShowTextTooltip(self, TOP, text)
		end)
	control:SetHandler("OnMouseExit", function(self)
			ZO_Tooltips_HideTextTooltip()
		end)
end
--
--
local function RemoveTooltips(control)
	control:SetHandler("OnMouseEnter", nil)
	control:SetHandler("OnMouseExit", nil)
end
--
--
local function HandleTooltips(control, text)
	if ( SMSettings:ShowTooltips() ) then
		control:SetMouseEnabled(true)
		AddTooltips(control, text)
	else
		control:SetMouseEnabled(false)
		RemoveTooltips(control)
	end
end

--
-- functions to create racial motif control, initially invisible
local function CreateMotifControl(parent)
	local control = WINDOW_MANAGER:CreateControl(parent:GetName() .. "ShowMotifs_MotifStyle", parent, CT_TEXTURE)
	control:SetHidden(true)

	return control
end

--
-- functions to create racial motif bg control, initially invisible
local function CreateMotifBGControl(parent)
	local control = WINDOW_MANAGER:CreateControl(parent:GetName() .. "ShowMotifs_MotifStyleBG", parent, CT_TEXTURE)
	control:SetHidden(true)

	return control
end

--
-- function to create armor type control, initially invisible
local function CreateArmorControl(parent)
	local control = WINDOW_MANAGER:CreateControl(parent:GetName() .. "ShowMotifs_ArmorType", parent, CT_TEXTURE)
	control:SetHidden(true)

	return control
end

--
-- function checks if item is a weapon or an armor/shield and returns racial motif ID
local function CheckMotifID(ItemLink)
	local equipType = GetItemLinkEquipType(ItemLink)
	if ( equipTypes[equipType] < 0 ) then
		return -1
	end
	
	local MotifID = GetItemLinkItemStyle(ItemLink)
	if (not SMSettings:GetMotif(MotifID)) then
		return 0
	end
	
	return MotifID
end

--
-- function checks if item is an armor and returns armor type ID
local function CheckArmorID(ItemLink)
	local equipType = GetItemLinkEquipType(ItemLink)
	if ( equipTypes[equipType] < 0 or equipTypes[equipType] >= 100 ) then
		return -1
	end

	return GetItemLinkArmorType(ItemLink)
end

--
-- repositioning item name
local function PositioningIcons(control, list)
	local controlName = WINDOW_MANAGER:GetControlByName(control:GetName() .. "Name") --270
	local controlStat = WINDOW_MANAGER:GetControlByName(control:GetName() .. "StatValue") --270
	local controlTimeRemaining = WINDOW_MANAGER:GetControlByName(control:GetName() .. "TimeRemaining") --342/290
	local controlCustom = WINDOW_MANAGER:GetControlByName(control:GetName() .. "Custom")
	if ( not ( controlName and ( controlTimeRemaining or controlStat or controlCustom) ) ) then
		return
	end

-- save original values if not saved yet for name control
	if ( not controlName.SMorigWidth ) then
		controlName.SMorigWidth = controlName:GetWidth()
	end

	if ( controlStat ) then
		local _, AnchorPosition, relativeTo, relativePoint, offsetX, offsetY = controlStat:GetAnchor() --2(LEFT),name,8(RIGHT),5,0
		if ( not controlStat.SMorigoffsetX ) then
			controlStat.SMorigoffsetX = offsetX
		end
-- repositioning name and, if exist, stats control
--		controlStat:ClearAnchors()
--		if ( ( controlName.SMorigWidth + SMSettings:GetIconPosition(list) ) < controlName.SMorigWidth ) then
--			controlName:SetWidth(controlName.SMorigWidth + SMSettings:GetIconPosition(list))
--			controlStat:SetAnchor(AnchorPosition, relativeTo, relativePoint, controlStat.SMorigoffsetX - SMSettings:GetIconPosition(list), offsetY)
--			return
--		else
--			controlName:SetWidth(controlName.SMorigWidth)
--			controlStat:SetAnchor(AnchorPosition, relativeTo, relativePoint, controlStat.SMorigoffsetX, offsetY)
--			return
--		end		
	end

	if ( controlCustom ) then
		local _, AnchorPosition, relativeTo, relativePoint, offsetX, offsetY = controlCustom:GetAnchor() --2(LEFT),name,8(RIGHT),2,0
		if ( not controlCustom.SMorigoffsetX ) then
			controlCustom.SMorigoffsetX = offsetX
		end
-- repositioning name and, if exist, Custom control
--		controlCustom:ClearAnchors()
--		if ( ( controlName.SMorigWidth + SMSettings:GetIconPosition(list) ) < controlName.SMorigWidth ) then
--			controlName:SetWidth(controlName.SMorigWidth + SMSettings:GetIconPosition(list))
--			controlCustom:SetAnchor(AnchorPosition, relativeTo, relativePoint, controlCustom.SMorigoffsetX - SMSettings:GetIconPosition(list), offsetY)
--			return
--		else
--			controlName:SetWidth(controlName.SMorigWidth)
--			controlCustom:SetAnchor(AnchorPosition, relativeTo, relativePoint, controlCustom.SMorigoffsetX, offsetY)
--			return
--		end		
	end
	
	if ( controlTimeRemaining ) then
		local _, AnchorPosition, relativeTo, relativePoint, offsetX, offsetY = controlTimeRemaining:GetAnchor() --2(LEFT),name,12(BOTTOMRIGHT),0,0
		if ( not controlTimeRemaining.SMorigoffsetX ) then
			controlTimeRemaining.SMorigoffsetX = offsetX
		end
-- repositioning name and, if exist, controlTimeRemaining control
--		controlTimeRemaining:ClearAnchors()
--		if ( ( controlName.SMorigWidth + SMSettings:GetIconPosition(list) ) < controlName.SMorigWidth ) then
--			controlName:SetWidth(controlName.SMorigWidth + SMSettings:GetIconPosition(list))
--			controlTimeRemaining:SetAnchor(AnchorPosition, relativeTo, relativePoint, controlTimeRemaining.SMorigoffsetX - SMSettings:GetIconPosition(list), offsetY)
--			return
--		else
--			controlName:SetWidth(controlName.SMorigWidth)
--			controlTimeRemaining:SetAnchor(AnchorPosition, relativeTo, relativePoint, controlTimeRemaining.SMorigoffsetX, offsetY)
--			return
--		end			
	end

end

--
-- function to add racial motif icon to inventory slot if none exist: set texture, tooltip text, color, size, position and make visible
local function AddMotifIndicatorToSlot(control, ItemLink, relativePoint, list)
	
-- check if icon is added already, if not add one, make invisible for now	
	local MotifControl = control:GetNamedChild("ShowMotifs_MotifStyle")
	if ( not SMSettings:IsMotifIconEnabled() and MotifControl ) then
		MotifControl:SetHidden(true)
		return
	end
	if ( not MotifControl ) then
		MotifControl = CreateMotifControl(control)
	end

-- check if grid mode enabled, hide if not
	if ( control.isGrid or ( control:GetWidth() - control:GetHeight() < 5 ) ) then
		MotifControl:SetHidden(true)
		return
	end

-- check if item is armor, weapon or shield
	local MotifID = CheckMotifID(ItemLink)
	if ( MotifID and MotifID < 0 ) then
		MotifControl:SetHidden(true)
		return
	end
	
-- add color based on quality
	local quality = GetItemLinkQuality(ItemLink)
	MotifControl:SetColor(255, 255, 255, 1)
	if ( ( SMSettings:GetIconColor() ) and ( quality > 0 ) ) then
		local color = GetItemQualityColor(quality)
		MotifControl:SetColor(color.r, color.g, color.b, color.a)
	end
	
-- positioning motif control
--	local controlName = WINDOW_MANAGER:GetControlByName(control:GetName() .. "TraitInfo")

	MotifControl:ClearAnchors()

	if ( SMSettings:GetIconPosition(list) > 0) then
		MotifControl:SetAnchor(LEFT, control, relativePoint, 2 + SMSettings:GetIconPosition(list) + 2 + SMSettings:GetArmorTextureSize())
	else
		MotifControl:SetAnchor(LEFT, control, relativePoint, 2 + 2 + SMSettings:GetArmorTextureSize())
	end

-- add tooltip and make it visible
	HandleTooltips(MotifControl, SMSettings:GetMotifName(MotifID))
	MotifControl:SetDimensions(SMSettings:GetMotifTextureSize(), SMSettings:GetMotifTextureSize())
	MotifControl:SetTexture(SMSettings:GetMotifTexture(MotifID))

	MotifControl:SetDimensions(SMSettings:GetMotifTextureSize(), SMSettings:GetMotifTextureSize())
	MotifControl:SetHidden(false)
end

--
-- function to add armor type icon to inventory slot if none exist: set texture, tooltip text, color, size, position and make visible
local function AddArmorIndicatorToSlot(control, ItemLink, relativePoint, list)

-- check if icon is added already, if not add one, make invisible for now
	local ArmorControl = control:GetNamedChild("ShowMotifs_ArmorType")
	if not SMSettings:IsArmorIconEnabled() then
		if ArmorControl then
			ArmorControl:SetHidden(true)
			return
		else
			return
		end
	end
	if ( not ArmorControl ) then
		ArmorControl = CreateArmorControl(control)
	end

-- check if item is armor or if grid mode enabled, hide if not
	if ( control.isGrid or ( control:GetWidth() - control:GetHeight() < 5 ) ) then
		ArmorControl:SetHidden(true)
		return
	end
	local ArmorTypeID = CheckArmorID(ItemLink)
	if ( ArmorTypeID and ArmorTypeID <= 0 ) then
		ArmorControl:SetHidden(true)
		return
	end

-- add color based on quality
	local quality = GetItemLinkQuality(ItemLink)
	ArmorControl:SetColor(255, 255, 255, 1)
	if ( ( SMSettings:GetIconColor() ) and ( quality > 0 ) ) then
		local color = GetItemQualityColor(quality)
		ArmorControl:SetColor(color.r, color.g, color.b, color.a)
	end

-- positioning armor control
--	local controlName = WINDOW_MANAGER:GetControlByName(control:GetName() .. "TraitInfo")

	ArmorControl:ClearAnchors()

	if ( SMSettings:GetIconPosition(list) > 0) then
		ArmorControl:SetAnchor(LEFT, control, relativePoint, 2 + SMSettings:GetIconPosition(list))
	else
		ArmorControl:SetAnchor(LEFT, control, relativePoint, 2 )
		
	end

-- add tooltip and make it visible
	HandleTooltips(ArmorControl,SMSettings:GetArmorName(ArmorTypeID))
	ArmorControl:SetDimensions(SMSettings:GetArmorTextureSize(), SMSettings:GetArmorTextureSize())
	ArmorControl:SetTexture(SMSettings:GetArmorTexture(ArmorTypeID))
	ArmorControl:SetHidden(false)
	
end

--
-- custom hooks for inventories
local function ShowMotifs_InvUpdate( ... )
-- hook to inventories
	for k,v in pairs(PLAYER_INVENTORY.inventories) do
		local listView = v.listView
		if ( listView and listView.dataTypes and listView.dataTypes[1] ) then
			ZO_PreHook(listView.dataTypes[1], "setupCallback", function(control, slot)
				local ItemLink = GetItemLink(control.dataEntry.data.bagId, control.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
				PositioningIcons(control, 1)
				AddArmorIndicatorToSlot(control, ItemLink, LEFT, 1)
				AddMotifIndicatorToSlot(control, ItemLink, LEFT, 1)
			end)
		end
	end

-- hook to deconstruction
	ZO_PreHook(DECONSTRUCTION.dataTypes[1], "setupCallback", function(control, slot)
		local ItemLink = GetItemLink(control.dataEntry.data.bagId, control.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
		PositioningIcons(control, 1)
		AddArmorIndicatorToSlot(control, ItemLink, LEFT, 1)
		AddMotifIndicatorToSlot(control, ItemLink, LEFT, 1)
	end)

-- hook to improvement
	ZO_PreHook(IMPROVEMENT.dataTypes[1], "setupCallback", function(control, slot)
		local ItemLink = GetItemLink(control.dataEntry.data.bagId, control.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
		PositioningIcons(control, 1)
		AddArmorIndicatorToSlot(control, ItemLink, LEFT, 1)
		AddMotifIndicatorToSlot(control, ItemLink, LEFT, 1)
	end)

end

--
-- hook to guild store

local function ShowMotifs_TradingHouse(eventCode, responseType, result)
	ZO_PreHook(TRADING_HOUSE.searchResultsList.dataTypes[1], "setupCallback", function( ... )
		local control, data = ...
	--	Zgoo.CommandHandler(control) -- tradehouse debug
		if ( control.slotControlType and control.slotControlType == 'listSlot' and control.dataEntry.data.slotIndex ) then
			local ItemLink = GetTradingHouseSearchResultItemLink(control.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
			PositioningIcons(control, 2)
			AddArmorIndicatorToSlot(control, ItemLink, LEFT, 2)
			AddMotifIndicatorToSlot(control, ItemLink, LEFT, 2)
		end
	end)
	ZO_PreHook(TRADING_HOUSE.postedItemsList.dataTypes[2], "setupCallback", function( ... )
		local control, data = ...
		if ( control.slotControlType and control.slotControlType == 'listSlot' and control.dataEntry.data.slotIndex ) then
			local ItemLink = GetTradingHouseListingItemLink(control.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
			PositioningIcons(control, 3)
			AddArmorIndicatorToSlot(control, ItemLink, LEFT, 3)
			AddMotifIndicatorToSlot(control, ItemLink, LEFT, 3)
		end
	end)
end

--
-- hook to store
local function ShowMotifs_Store( ... )
--- hook to sell tab, not work
--	local hookFunction = STORE.dataTypes[1].setupCallback
--	STORE.dataTypes[1].setupCallback = function( ... )
--		local control, data = ...
--		hookFunction( ... )
--		if ( control.slotControlType and control.slotControlType == "listSlot" and control.dataEntry.data.slotIndex ) then
--			local ItemLink = GetStoreItemLink(control.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
--			PositioningIcons(control)
--			AddMotifIndicatorToSlot(control, ItemLink, LEFT)
--		end
--	end
	
-- hook to buyback
	ZO_PreHook(ZO_BuyBackList.dataTypes[1], "setupCallback", function( ... )
		local control, data = ...
		if ( control.slotControlType and control.slotControlType == "listSlot" and control.dataEntry.data.slotIndex ) then
			local ItemLink = GetBuybackItemLink(control.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
			PositioningIcons(control, 1)
			AddArmorIndicatorToSlot(control, ItemLink, LEFT, 1)
			AddMotifIndicatorToSlot(control, ItemLink, LEFT, 1)
		end
	end)

-- hook to repair
	ZO_PreHook(STORE_REPAIR.dataTypes[1], "setupCallback", function( ... )
		local control, data = ...
		if ( control.slotControlType and control.slotControlType == "listSlot" and control.dataEntry.data.slotIndex ) then
			local ItemLink = GetItemLink(control.dataEntry.data.bagId, control.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
			PositioningIcons(control, 1)
			AddArmorIndicatorToSlot(control, ItemLink, LEFT, 1)
			AddMotifIndicatorToSlot(control, ItemLink, LEFT, 1)
		end
	end)

end

--
-- load add-on, register for events for when inventory is updated(add/remove item) and make hooks for events
local function ShowMotifs_Loaded(eventCode, addOnName)
	if ( addOnName ~= "ShowMotifs" ) then
        return
    end

	SMSettings = ShowMotifs.ShowMotifsSettings:New()
		
	EVENT_MANAGER:RegisterForEvent("ShowMotifs", EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, ShowMotifs_TradingHouse)
	EVENT_MANAGER:RegisterForEvent("ShowMotifs", EVENT_OPEN_STORE, ShowMotifs_Store)
	ShowMotifs_InvUpdate()

	EVENT_MANAGER:UnregisterForEvent("ShowMotifs", EVENT_ADD_ON_LOADED)
end

--
-- initialize add-on
local function ShowMotifs_Initialized()
	EVENT_MANAGER:RegisterForEvent("ShowMotifs", EVENT_ADD_ON_LOADED, ShowMotifs_Loaded)
end

ShowMotifs_Initialized()
MPPLoot = {}
local MPPLoot = MPPLoot
MPPLoot.name = "MPPLoot"
MPPLoot.version = "1.1"

MPPLoot.defaults = {
    minQuality = 4,
    format = 0,
    chatOutput = false,
    useDisplayName = false,
    color = "white",
	showTrait = false,
}

local formats = {
    [0] = MPP_LOOT_FORMAT_1,
    [1] = MPP_LOOT_FORMAT_2,
    [2] = MPP_LOOT_FORMAT_3,
}

local colors = {
    white   = "EsoUI/Art/HUD/lootHistory_highlight.dds",
    red     = "EsoUI/Art/HUD/lootHistory_highlight_stolen.dds",
    blue    = "MPPLoot/tex/loothistory_highlight_group_blue.dds",
    yellow  = "MPPLoot/tex/loothistory_highlight_group_yellow.dds",
    orange  = "MPPLoot/tex/loothistory_highlight_group_orange.dds",
    green   = "MPPLoot/tex/loothistory_highlight_group_green.dds",
    purple  = "MPPLoot/tex/loothistory_highlight_group_purple.dds",
}

--ITEM_QUALITY_LEGENDARY  = 5
--ITEM_QUALITY_ARTIFACT   = 4
--ITEM_QUALITY_ARCANE     = 3
--ITEM_QUALITY_MAGIC      = 2
--ITEM_QUALITY_NORMAL     = 1
--ITEM_QUALITY_TRASH      = 0 


--/script MPPLoot.IsRelevant("|H1:item:176736:430:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")

-- TODO: More configurable way of determining what is relevant and what isn't (i.e. user options)
function MPPLoot.IsRelevant(itemLink)
    if not itemLink or itemLink == "" then return false, "No item link" end
    
    local itemType, specializedItemType = GetItemLinkItemType(itemLink)
    local bindType = GetItemLinkBindType(itemLink)
    
    local isSetItem = GetItemLinkSetInfo(itemLink)

    if IsItemLinkBound(itemLink) then
		
        return false, "Bound"
    elseif IsItemLinkStolen(itemLink) then
        return false, "Stolen"
    elseif bindType == BIND_TYPE_ON_PICKUP then
		-- Todo: more refined: if the actual looter is who got the item
        return IsUnitInDungeon("player") and isSetItem, "Bind on pickup"
    elseif bindType == BIND_TYPE_ON_PICKUP_BACKPACK then
        return false, "Bind on pickup (Character)"
    else
		if itemType == ITEMTYPE_ARMOR then
            return isSetItem, (isSetItem == true and "Set Item" or "No Set Item")
		elseif itemType == ITEMTYPE_WEAPON then
            return isSetItem, (isSetItem == true and "Set Item" or "No Set Item")
        elseif itemType == ITEMTYPE_SOUL_GEM then
            return false, "Soul Gem"
        elseif itemType == ITEMTYPE_TREASURE then
            return false, "Treasure"
		elseif itemType == ITEMTYPE_TROPHY then 
			if not (specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT or specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT or specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP) then
				return false, "Trophy"
			end
        end
    end
    return true
end

--/script MPPLoot.ShowLoot("|H1:item:127705:364:50:68343:370:50:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h", "Groupmember", nil, 1)
local idCounter = 0 -- Counts upwards to prevent stacking of items from different group members
function MPPLoot.ShowLoot(itemLink, looter, quantity, itemId)
    if not itemLink or itemLink == "" then return end
    if not quantity then quantity = 1 end
		
    local itemName = GetItemLinkName(itemLink)
	local itemType, specializedItemType = GetItemLinkItemType(itemLink)
    local icon = GetItemLinkInfo(itemLink)
    local displayQuality = GetItemLinkDisplayQuality(itemLink)
    local color = GetItemQualityColor(displayQuality)
	
    local trait = ""
	if MPPLoot.SV.showTrait then
		if GetItemLinkTraitCategory(itemLink) ~= ITEM_TRAIT_TYPE_CATEGORY_NONE then
			trait = " (" .. GetString("SI_ITEMTRAITTYPE", GetItemLinkTraitInfo(itemLink)) .. ") "
		end
	end

    local lootData ={
        text = zo_strformat(formats[MPPLoot.SV.format], looter, itemName, trait),
        icon = icon,
        stackCount = quantity,
        color = color,
        itemId = idCounter,
        displayQuality = displayQuality,
        quality = 1337,
        isCraftBagItem = false,
        isStolen = false,
        statusIcon = "EsoUI/Art/LFG/gamepad/gp_lfg_icon_groupsize.dds",
        highlight = colors[MPPLoot.SV.color],
        entryType = LOOT_ENTRY_TYPE_ITEM,
        iconOverlayText = quantity,
        showIconOverlayText = quantity > 1 or false,
    }
    
    -- Highlight unknown item set pieces and recipes
    if IsItemLinkSetCollectionPiece(itemLink) and not IsItemSetCollectionPieceUnlocked(itemId) then
        lootData.color = ZO_ColorDef:New(1, 0, 0, 1)
	elseif itemType == ITEMTYPE_RECIPE and not IsItemLinkRecipeKnown(itemLink) then
		lootData.color = ZO_ColorDef:New(1, 0, 0, 1)
    end
    
    --Texture in text:
    --zo_iconFormat("EsoUI/Art/Tooltips/icon_lock.dds", 24, 24)
    --zo_iconFormat(ZO_TRADE_BOP_ICON, 24, 24)
    
    idCounter = idCounter + 1
    local lootEntry = SYSTEMS:GetObject(ZO_LOOT_HISTORY_NAME):CreateLootEntry(lootData)
    lootEntry.isPersistent = true
    SYSTEMS:GetObject(ZO_LOOT_HISTORY_NAME):InsertOrQueue(lootEntry)
end

local function OnLootReceived(event, receivedBy, itemLink, quantity, soundCategory, lootType, self, isPickpocketLoot, questItemIcon, itemId, isStolen)
    -- Exit on items not worth displaying
    if not lootType == LOOT_TYPE_ITEM then return end
    if isStolen or isPickpocketLoot then return end
    
    if (GetItemLinkDisplayQuality(itemLink) >= MPPLoot.SV.minQuality) and not self then
        -- Try and replace name with UserID. If that fails, nothing will change and it will display the name given by the event.
        if MPPLoot.SV.useDisplayName then
            for i = 1, GetGroupSize() do
                if GetRawUnitName("group"..i) == receivedBy then
                    receivedBy = GetUnitDisplayName("group"..i)
                end
            end
        end

		local _debug_printTochat = false
		local relevant, reason = MPPLoot.IsRelevant(itemLink)
		if relevant then
			if _debug_printTochat then
				d(zo_strformat("<<1>> is relevant (<<2>>)", itemLink, receivedBy))
			end
			MPPLoot.ShowLoot(itemLink, receivedBy, quantity, itemId)
		elseif _debug_printTochat then
			d(zo_strformat("<<1>> is not relevant: <<2>> (<<3>>)", itemLink, reason, receivedBy))
		end
        
        if MPPLoot.SV.chatOutput then
            d(zo_strformat(MPP_LOOT_FORMAT_CHAT, receivedBy, itemLink, quantity))
        end
    end
end

local function InitializeAddonMenu()
	local panelData = {
		type = "panel",
		name = "MrPikPik's Loot Log",
		displayName = "MrPikPik's Loot Log",
		author = "MrPikPik",
		version = MPPLoot.version,
		registerForRefresh = true,
		registerForDefaults = true
	}
	
	local optionsData = {}
    
    -- Description
	table.insert(optionsData, {
		type = "description",
		text = GetString(MPP_LOOT_OPTIONS_DESCRIPTION),
	})
    
    -- Options header
	table.insert(optionsData, {
		type = "header",
		name = GetString(MPP_LOOT_HEADER_SETTINGS),
	})
    

    -- Display quality
	table.insert(optionsData, {
		type = "dropdown",
		name = GetString(MPP_LOOT_OPTIONS_QUALITY),
		tooltip = GetString(MPP_LOOT_OPTIONS_QUALITY_TT),
		choices = {
            GetString(MPP_LOOT_OPTIONS_QUALITY_0),
            GetString(MPP_LOOT_OPTIONS_QUALITY_1),
            GetString(MPP_LOOT_OPTIONS_QUALITY_2),
            GetString(MPP_LOOT_OPTIONS_QUALITY_3),
            GetString(MPP_LOOT_OPTIONS_QUALITY_4),
            GetString(MPP_LOOT_OPTIONS_QUALITY_5),
        },
		getFunc = function() 
            if MPPLoot.SV.minQuality == 0 then
                return GetString(MPP_LOOT_OPTIONS_QUALITY_0)
			elseif MPPLoot.SV.minQuality == 1 then 
				return GetString(MPP_LOOT_OPTIONS_QUALITY_1)
			elseif MPPLoot.SV.minQuality == 2 then 
				return GetString(MPP_LOOT_OPTIONS_QUALITY_2)
            elseif MPPLoot.SV.minQuality == 3 then 
				return GetString(MPP_LOOT_OPTIONS_QUALITY_3)
            elseif MPPLoot.SV.minQuality == 4 then 
				return GetString(MPP_LOOT_OPTIONS_QUALITY_4)
            elseif MPPLoot.SV.minQuality == 5 then 
				return GetString(MPP_LOOT_OPTIONS_QUALITY_5)
			end
		end,
		setFunc = function(newValue)
			if newValue == GetString(MPP_LOOT_OPTIONS_QUALITY_0) then 
				MPPLoot.SV.minQuality = 0
			elseif newValue == GetString(MPP_LOOT_OPTIONS_QUALITY_1) then
				MPPLoot.SV.minQuality = 1
			elseif newValue == GetString(MPP_LOOT_OPTIONS_QUALITY_2) then
				MPPLoot.SV.minQuality = 2
            elseif newValue == GetString(MPP_LOOT_OPTIONS_QUALITY_3) then
				MPPLoot.SV.minQuality = 3
            elseif newValue == GetString(MPP_LOOT_OPTIONS_QUALITY_4) then
				MPPLoot.SV.minQuality = 4
            elseif newValue == GetString(MPP_LOOT_OPTIONS_QUALITY_5) then
				MPPLoot.SV.minQuality = 5
			end
		end,
		default = MPPLoot.defaults.minQuality,
	})
    
    -- Display format
	table.insert(optionsData, {
		type = "dropdown",
		name = GetString(MPP_LOOT_OPTIONS_FORMAT),
		tooltip = GetString(MPP_LOOT_OPTIONS_FORMAT_TT),
		choices = {
            "NAME: ITEM",
            "ITEM (NAME)",
            "NAME looted ITEM",
        },
		getFunc = function() 
            if MPPLoot.SV.format == 0 then
                return "NAME: ITEM"
			elseif MPPLoot.SV.format == 1 then 
				return "ITEM (NAME)"
            elseif MPPLoot.SV.format == 2 then 
				return "NAME looted ITEM"
			end
		end,
		setFunc = function(newValue)
			if newValue == "NAME: ITEM" then 
				MPPLoot.SV.format = 0
			elseif newValue == "ITEM (NAME)" then
				MPPLoot.SV.format = 1
            elseif newValue == "NAME looted ITEM" then
				MPPLoot.SV.format = 2
			end
		end,
		default = MPPLoot.defaults.format,
	})
    
    -- Highlight color
	table.insert(optionsData, {
		type = "dropdown",
		name = GetString(MPP_LOOT_OPTIONS_COLOR),
		tooltip = GetString(MPP_LOOT_OPTIONS_COLOR_TT),
		choices = {
            GetString(MPP_LOOT_OPTIONS_COLOR_1),
            GetString(MPP_LOOT_OPTIONS_COLOR_2),
            GetString(MPP_LOOT_OPTIONS_COLOR_3),
            GetString(MPP_LOOT_OPTIONS_COLOR_4),
            GetString(MPP_LOOT_OPTIONS_COLOR_5),
            GetString(MPP_LOOT_OPTIONS_COLOR_6),
            GetString(MPP_LOOT_OPTIONS_COLOR_7),
        },
		getFunc = function() 
            if MPPLoot.SV.color == "white" then
                return GetString(MPP_LOOT_OPTIONS_COLOR_1)
			elseif MPPLoot.SV.color == "red" then 
				return GetString(MPP_LOOT_OPTIONS_COLOR_2)
			elseif MPPLoot.SV.color == "blue" then 
				return GetString(MPP_LOOT_OPTIONS_COLOR_3)
            elseif MPPLoot.SV.color == "yellow" then 
				return GetString(MPP_LOOT_OPTIONS_COLOR_4)
            elseif MPPLoot.SV.color == "orange" then 
				return GetString(MPP_LOOT_OPTIONS_COLOR_5)
            elseif MPPLoot.SV.color == "green" then 
				return GetString(MPP_LOOT_OPTIONS_COLOR_6)
            elseif MPPLoot.SV.color == "purple" then 
				return GetString(MPP_LOOT_OPTIONS_COLOR_7)
			end
		end,
		setFunc = function(newValue)
			if newValue == GetString(MPP_LOOT_OPTIONS_COLOR_1) then 
				MPPLoot.SV.color = "white"
			elseif newValue == GetString(MPP_LOOT_OPTIONS_COLOR_2) then
				MPPLoot.SV.color = "red"
			elseif newValue == GetString(MPP_LOOT_OPTIONS_COLOR_3) then
				MPPLoot.SV.color = "blue"
            elseif newValue == GetString(MPP_LOOT_OPTIONS_COLOR_4) then
				MPPLoot.SV.color = "yellow"
            elseif newValue == GetString(MPP_LOOT_OPTIONS_COLOR_5) then
				MPPLoot.SV.color = "orange"
            elseif newValue == GetString(MPP_LOOT_OPTIONS_COLOR_6) then
				MPPLoot.SV.color = "green"
            elseif newValue == GetString(MPP_LOOT_OPTIONS_COLOR_7) then
				MPPLoot.SV.color = "purple"
			end
		end,
		default = MPPLoot.defaults.color,
	})
    
	-- Show trait
    table.insert(optionsData, {
		type = "checkbox",
		name = GetString(MPP_LOOT_OPTIONS_TRAIT),
        tooltip = GetString(MPP_LOOT_OPTIONS_TRAIT_TT),
		default = MPPLoot.defaults.showTrait,
		getFunc = function() return MPPLoot.SV.showTrait end,
		setFunc = function(newValue) MPPLoot.SV.showTrait = newValue end,
	})
	
    -- Chat output
    table.insert(optionsData, {
		type = "checkbox",
		name = GetString(MPP_LOOT_OPTIONS_CHAT),
        tooltip = GetString(MPP_LOOT_OPTIONS_CHAT_TT),
		default = MPPLoot.defaults.chatOutput,
		getFunc = function() return MPPLoot.SV.chatOutput end,
		setFunc = function(newValue) MPPLoot.SV.chatOutput = newValue end,
	})
    
    -- Use display name
    table.insert(optionsData, {
		type = "checkbox",
		name = GetString(MPP_LOOT_OPTIONS_DISPLAY_NAME),
        tooltip = GetString(MPP_LOOT_OPTIONS_DISPLAY_NAME_TT),
		default = MPPLoot.defaults.useDisplayName,
		getFunc = function() return MPPLoot.SV.useDisplayName end,
		setFunc = function(newValue) MPPLoot.SV.useDisplayName = newValue end,
	})
    
    
	local optionsPanel = LibAddonMenu2:RegisterAddonPanel(MPPLoot.name .. "Settings", panelData)
	LibAddonMenu2:RegisterOptionControls(MPPLoot.name .. "Settings", optionsData)
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= MPPLoot.name then return end
    EVENT_MANAGER:UnregisterForEvent(MPPLoot.name, EVENT_ADD_ON_LOADED) 

    MPPLoot.SV = ZO_SavedVars:NewAccountWide("MPPLootSavedVariables", 1.0, nil, MPPLoot.defaults)
    
    EVENT_MANAGER:RegisterForEvent(MPPLoot.name, EVENT_LOOT_RECEIVED, OnLootReceived)
    
    InitializeAddonMenu()
end
EVENT_MANAGER:RegisterForEvent(MPPLoot.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
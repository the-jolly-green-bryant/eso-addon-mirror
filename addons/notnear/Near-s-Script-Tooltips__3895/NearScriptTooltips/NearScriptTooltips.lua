local addon = {
	name = "NearScriptTooltips",
}
-------------------------------------------------------------------------------------------------------------------------

local font = "$(BOLD_FONT)|$(KB_14)|soft-shadow-thin"
local color = ZO_ColorDef:New("c0c09c")
local r, g, b = 255, 255, 255
local lineAnchor = LABEL_LINE_ANCHOR_TOP
local modifyTextType = MODIFY_TEXT_TYPE_NONE
local textAlignment = TEXT_ALIGN_LEFT
local setToFullSize = true

local function ReturnItemLink(itemLink)
	return itemLink
end

--- from ZO_Tooltip:LayoutCraftedAbilityScriptItem
---@param itemLink string
---@return integer
local function GetItemLinkCraftedAbilityScriptId(itemLink)
	return GetItemLinkItemUseReferenceId(itemLink)
end

local function TooltipHook(tooltipControl, method, linkFunc)
	local origMethod = tooltipControl[method]

	tooltipControl[method] = function(self, ...)
		local itemLink = linkFunc(...)
		local itemType = GetItemLinkItemType(itemLink)
		origMethod(self, ...)

		if itemType == ITEMTYPE_CRAFTED_ABILITY_SCRIPT then
			ZO_Tooltip_AddDivider(tooltipControl)
			tooltipControl:AddLine("Compatible with:", font, r, g, b)

    		local craftedAbilityScriptId = GetItemLinkCraftedAbilityScriptId(itemLink)

			local grimoireNames_table = {}

			for craftedAbilityId = 1, GetNumCraftedAbilities() do
				local description1 = GetCraftedAbilityScriptDescription(craftedAbilityId, craftedAbilityScriptId)
				local description2 = GetCraftedAbilityScriptGeneralDescription(craftedAbilityScriptId)

				if description1 ~= description2 then
					local craftedAbilityName = GetCraftedAbilityDisplayName(craftedAbilityId)
					craftedAbilityName = color:Colorize(craftedAbilityName)
					-- tooltipControl:AddLine(craftedAbilityName, font, r, g, b, lineAnchor, modifyTextType, textAlignment, setToFullSize)
					grimoireNames_table[#grimoireNames_table + 1] = craftedAbilityName
				end
			end

			-- Sort the names
			table.sort(grimoireNames_table)
			local grimoireNames = table.concat(grimoireNames_table, '\n')

			tooltipControl:AddLine(grimoireNames, font, r, g, b, lineAnchor, modifyTextType, textAlignment, setToFullSize)
		end
	end
end

local function Initialize()
	TooltipHook(ItemTooltip, "SetBagItem", GetItemLink)
	TooltipHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
	TooltipHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
	TooltipHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
	TooltipHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
	TooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
	TooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
	TooltipHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
	TooltipHook(ItemTooltip, "SetLink", ReturnItemLink)
	TooltipHook(PopupTooltip, "SetLink", ReturnItemLink)
end

-------------------------------------------------------------------------------------------------------------------------
-- Addon loading
-------------------------------------------------------------------------------------------------------------------------
local function OnAddonLoaded(_, name)
	if name ~= addon.name then return end
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	Initialize()
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

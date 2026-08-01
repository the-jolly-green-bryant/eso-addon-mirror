
--[[-- TODO --
* don't overwrite user tooltip positions
* add additional info to base tooltips as well
* show more info, not just style
--]]

-- GLOBALS: _G, SMITHING, LINK_STYLE_DEFAULT, SI_FORMAT_BULLET_SPACING, SI_TOOLTIP_ITEM_NAME
-- GLOBALS: LibStub, PopupTooltip, ItemTooltip, ComparativeTooltip1, ComparativeTooltip2, ZO_PreHook, ZO_PreHookHandler, ZO_SavedVars
-- GLOBALS: GetItemLink, GetSmithingPatternResultLink, GetSmithingImprovedItemLink, GetComparisonEquipSlotsFromItemLink, GetWindowManager, GetString, GetItemLinkInfo, GetInterfaceColor, IsShiftKeyDown, ZO_PlayShowAnimationOnComparisonTooltip, ZO_Tooltips_SetupDynamicTooltipAnchors, ZO_ItemTooltip_SetEquippedInfo, ZO_Tooltip_AddDivider, ZO_Inventory_GetBagAndIndex, ZO_InventorySlot_GetItemListDialog, ZO_PopupTooltip_Hide
-- GLOBALS: unpack, type, moc, zo_strjoin, zo_callLater, zo_strformat

-- Init
CraftCompare = {}
CraftCompare.name = 'CraftCompare'
CraftCompare.author = 'ckaotik & Ayantir'
CraftCompare.version = '1.17'
CraftCompare.website = 'http://www.esoui.com/downloads/info773-CraftCompareUpdated.html'
CraftCompare.Tooltip = CraftCompare.name..'Tooltip'
CraftCompare.DeconstructTooltip = CraftCompare.name..'DeconstructTooltip'

--The SMITHINMG modes which prevent the normal tooltips (Refine, Research, Housing)
local preventingSmithingModes = {
    [SMITHING_MODE_REFINMENT]   = true, --Old and wrong way of writing the constant! ZOs renamed it later on to SMITHING_MODE_REFINEMENT
    [SMITHING_MODE_REFINEMENT]  = true, --Refine
    [SMITHING_MODE_RESEARCH]    = true, --Research
    [SMITHING_MODE_RECIPES]     = true, --Housing recipes
}
--Is the crafting compare tooltip activated at the ghiven crafting mode?
local function isCCActivatedAtCraftPanel(craftingMode)
    local compareStyle = CraftCompare.db[craftingMode]
    local prevent = preventingSmithingModes[craftingMode] or false
    if not prevent and compareStyle and compareStyle ~= 'None' then
        return true
    end
    return false
end

--Constants
local CC_TOOLTIP_TYPE_POPUP         = "PopupTooltip"
local CC_TOOLTIP_TYPE_COMPARATIVE   = "ComparativeTooltip"

-- Library
local LAM = LibStub('LibAddonMenu-2.0')

-- ========================================================
--  Other addons
-- ========================================================
-- DoItAll: http://www.esoui.com/downloads/info690-DoItAll.html
local function IsDoItAllExtractionActive()
    --If the addon DoItAll is enabled and currently mass-deconstructing items: Abort here and do not show the tooltips -> They would add extra lag
    local isExtractionActive = (DoItAll ~= nil and DoItAll.extractionActive) or false
    return isExtractionActive
end

-- ========================================================
--  Settings
-- ========================================================
function CraftCompare.CreateSettings()

	-- Default Settings
	local defaultSettings = {}
	defaultSettings[SMITHING_MODE_CREATION] = true
	defaultSettings[SMITHING_MODE_IMPROVEMENT] = CC_TOOLTIP_TYPE_POPUP
	defaultSettings[SMITHING_MODE_DECONSTRUCTION] = CC_TOOLTIP_TYPE_POPUP
	--defaultSettings[SMITHING_MODE_RESEARCH] = CC_TOOLTIP_TYPE_POPUP
	defaultSettings.showInfo = true
	
	-- Get Vars
    CraftCompare.db = ZO_SavedVars:NewCharacterIdSettings(CraftCompare.name..'DB', 4, nil, defaultSettings, GetWorldName())
    --Disabled: ESO shows the itemstyle within the tooltips header meanwhile
    CraftCompare.db.showInfo = false
    --Old setting was only boolean false/true. Change it to the new value now, if so
    local improvementPopupSetting = CraftCompare.db[SMITHING_MODE_IMPROVEMENT]
    if improvementPopupSetting ~= nil and type(improvementPopupSetting) == "boolean" then
        CraftCompare.db[SMITHING_MODE_IMPROVEMENT] = CC_TOOLTIP_TYPE_POPUP
    end

	local panelData = {
		type = 'panel',
		name = CraftCompare.name,
		author = CraftCompare.author,
		version = CraftCompare.version,
		registerForRefresh = true,
		registerForDefaults = true,
        website = CraftCompare.website,
	}

	local optionsTable = {
		{
			type = 'description',
			text = 'CraftCompare helps you to compare new crafted items with your current equipment',
		},
--[[
        {
			type = 'checkbox',
			name = 'Item Details',
			tooltip = 'Enable display of item details such as item style.',
			getFunc = function() return CraftCompare.db.showInfo end,
			setFunc = function(value) CraftCompare.db.showInfo = value end,
			default = defaultSettings.showInfo
		},
]]
		{
			type = 'description',
			text = 'Hint: Hold down SHIFT key to compare to your alternate weapon set',
		},
		{
			type = 'header',
			name = 'Compare in crafting mode',
		},
		{
			type = 'checkbox',
			name = 'Creation',
			tooltip = 'Enable item comparison when in "Creation" mode',
			getFunc = function() return CraftCompare.db[SMITHING_MODE_CREATION] end,
			setFunc = function(newValue) CraftCompare.db[SMITHING_MODE_CREATION] = newValue end,
			default = defaultSettings[SMITHING_MODE_CREATION]
		},
		{
            type = 'dropdown',
            name = 'Improvement',
            tooltip = 'Select if and how to compare in "Improvement" mode',
            choices = {'None', CC_TOOLTIP_TYPE_POPUP, CC_TOOLTIP_TYPE_COMPARATIVE},
            getFunc = function() return CraftCompare.db[SMITHING_MODE_IMPROVEMENT] end,
            setFunc = function(newValue) CraftCompare.db[SMITHING_MODE_IMPROVEMENT] = newValue end,
            default = defaultSettings[SMITHING_MODE_IMPROVEMENT]
		},
		{
			type = 'dropdown',
			name = 'Deconstruction',
			tooltip = 'Select if and how to compare in "Deconstruction" mode',
			choices = {'None', CC_TOOLTIP_TYPE_POPUP, CC_TOOLTIP_TYPE_COMPARATIVE},
			getFunc = function() return CraftCompare.db[SMITHING_MODE_DECONSTRUCTION] end,
			setFunc = function(newValue) CraftCompare.db[SMITHING_MODE_DECONSTRUCTION] = newValue end,
			default = defaultSettings[SMITHING_MODE_DECONSTRUCTION]
		},
		--[[
        {
			type = 'dropdown',
			name = 'Research',
			tooltip = 'Select if and how to compare in "Research" mode',
			choices = {'None', CC_TOOLTIP_TYPE_POPUP, CC_TOOLTIP_TYPE_COMPARATIVE},
			getFunc = function() return CraftCompare.db.SMITHING_MODE_RESEARCH end,
			setFunc = function(newValue) CraftCompare.db.SMITHING_MODE_RESEARCH = newValue end,
			default = defaultSettings.SMITHING_MODE_RESEARCH
		},
		]]
		{
			type = 'description',
			text = 'PopupTooltip can be moved and closed.\nComparativeTooltip is attached to the normal item tooltip.',
		},
	}
	
	LAM:RegisterAddonPanel(CraftCompare.name .. 'Options', panelData)
	LAM:RegisterOptionControls(CraftCompare.name .. 'Options', optionsTable)
	
end

-- ========================================================
--  Functionality
-- ========================================================
function CraftCompare.GetValidSmithingItemLink(patternIndex)
	--d("CraftCompare.GetValidSmithingItemLink")
	-- this is a crafting process
	local patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex, _ = SMITHING.creationPanel:GetAllCraftingParameters()
    -- assumption: crafting and research share the same indices for the same slots: Wrong!
    local itemLink = GetSmithingPatternResultLink(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex) -- , linkStyle)
	if itemLink and itemLink ~= '' then
		return itemLink
	end
	
end

function CraftCompare.GetCompareSlots(itemLink)
	if not itemLink or itemLink == '' then return end
	local alternateSlot = {
		[_G.EQUIP_SLOT_MAIN_HAND]   = _G.EQUIP_SLOT_BACKUP_MAIN,
		[_G.EQUIP_SLOT_BACKUP_MAIN] = _G.EQUIP_SLOT_MAIN_HAND,
		[_G.EQUIP_SLOT_OFF_HAND]    = _G.EQUIP_SLOT_BACKUP_OFF,
		[_G.EQUIP_SLOT_BACKUP_OFF]  = _G.EQUIP_SLOT_OFF_HAND,
	}
	local slot, otherSlot = GetComparisonEquipSlotsFromItemLink(itemLink)
	if IsShiftKeyDown() then
		local altSlot, altOtherSlot = alternateSlot[slot], alternateSlot[otherSlot]
		if altSlot or altOtherSlot then
			return altSlot, altOtherSlot
		end
	end
	return slot, otherSlot
end

function CraftCompare.TooltipText(text)
	if type(text) == 'number' then
		-- get the string from this constant
		text = GetString(text)
	end
	return zo_strformat(SI_TOOLTIP_ITEM_NAME, text)
end

function CraftCompare.AddCraftingItemInfo(tooltip, itemLink, slot)
--d("[CraftCompare]AddCraftingItemInfo")
	local font = 'ZoFontWinT2'
	local r, g, b, a = GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_ATTRIBUTE_TOOLTIP)
	local separator = ' '..GetString(SI_FORMAT_BULLET_SPACING)
	
	--local texture, sellPrice, canUse, equipType, itemStyle = GetItemLinkInfo(itemLink)
    --GetItemLinkInfo = icon string,sellPrice integer,meetsUsageRequirement bool,equipType [EquipType|#EquipType],itemStyleId integer
    local texture, _, _, _, itemStyleId = GetItemLinkInfo(itemLink)
	-- update item icon
	local icon = tooltip:GetNamedChild('Icon')
	if icon then
		local hidden = not texture
		tooltip:GetNamedChild('FadeLeft'):SetHidden(hidden)
    	tooltip:GetNamedChild('FadeRight'):SetHidden(hidden)
		
		icon:SetHidden(hidden)
		if not hidden then
			icon:SetTexture(texture)
		end
	end
	-- update equipped info
	if slot then
        ZO_ItemTooltip_SetEquippedInfo(tooltip, slot)
	end

    --Disabled: ESO shows the item style in the head row meanwhile!
	if not CraftCompare.db.showInfo then return end
	-- show item style
	tooltip:AddVerticalPadding(10)
	ZO_Tooltip_AddDivider(tooltip)
	tooltip:AddLine(zo_strjoin(separator, CraftCompare.TooltipText(_G['SI_ITEMSTYLECHAPTER'..itemStyleId])), font, r, g, b)
	-- tooltip:AddHeaderLine(GetString(_G['SI_ITEMSTYLE'..itemStyle]), 'ZoFontWinT2', 1, _G.TOOLTIP_HEADER_SIDE_RIGHT, GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_ATTRIBUTE_TOOLTIP))
end

function CraftCompare.UpdateTooltips(slot, otherSlot, tooltip, otherTooltip)
	-- handle primary tooltip
	local itemLink = slot and GetItemLink(_G.BAG_WORN, slot)
	tooltip = tooltip or PopupTooltip
	if itemLink and itemLink ~= '' then
		InitializeTooltip(tooltip)
		ZO_PlayShowAnimationOnComparisonTooltip(tooltip)
		
		-- fill in tooltip information
		tooltip:SetLink(itemLink)
		CraftCompare.AddCraftingItemInfo(tooltip, itemLink, slot)
	else
		ClearTooltip(tooltip)
		if tooltip == PopupTooltip then
			ZO_PopupTooltip_Hide()
		else
			ZO_PlayHideAnimationOnComparisonTooltip(tooltip)
		end
		tooltip = nil
	end

	-- handle secondary tooltip
	local otherLink = otherSlot and GetItemLink(_G.BAG_WORN, otherSlot)
	otherTooltip = otherTooltip or CraftCompare.tooltip
	if otherLink and otherLink ~= '' then
		InitializeTooltip(otherTooltip)
		-- ZO_PlayShowAnimationOnComparisonTooltip(otherTooltip)
		
		-- fill in tooltip information
		otherTooltip:SetLink(otherLink)
		CraftCompare.AddCraftingItemInfo(otherTooltip, otherLink, otherSlot)
	else
		ClearTooltip(otherTooltip)
		-- ZO_PlayHideAnimationOnComparisonTooltip(otherTooltip)
		otherTooltip = nil
	end
	
	return tooltip, otherTooltip
	
end

function CraftCompare.UpdateComparativeTooltips()
    local allow = isCCActivatedAtCraftPanel(SMITHING.mode)
    if allow then
        local button = moc() and moc():GetNamedChild('Button')
        if button then
            local bag, slot = ZO_Inventory_GetBagAndIndex(button)
            if not bag or not slot then return end
            local itemLink = GetItemLink(bag, slot)
            local slot, otherSlot = CraftCompare.GetCompareSlots(itemLink)
            local tooltip, otherTooltip = ComparativeTooltip1, ComparativeTooltip2

            local tt1, tt2 = CraftCompare.UpdateTooltips(slot, otherSlot, tooltip, otherTooltip)
            if tt1 or tt2 then
                -- AddCraftingItemInfo(ItemTooltip, itemLink)
                -- position things nicely
                ZO_Tooltips_SetupDynamicTooltipAnchors(ItemTooltip, button.tooltipAnchor or button, tooltip, otherTooltip)
            else
                ItemTooltip:HideComparativeTooltips()
            end
        end
    end
end

function CraftCompare.Update(hasItemSlotted)
    hasItemSlotted = hasItemSlotted or false
    local mode = SMITHING.mode
	local compareStyle = CraftCompare.db[mode]
--d("[CraftCompare]Update->Check:mode:" .. tostring(mode) .. "; compareStyle:" .. tostring(compareStyle))
	if not mode or not compareStyle or compareStyle == 'None' then return end
	--d("CraftCompare:Update->do")
	if compareStyle == CC_TOOLTIP_TYPE_COMPARATIVE then
        CraftCompare.UpdateComparativeTooltips()
	else
		--d("CraftCompare:Update->Tooltip")
		local itemLink
		if mode == SMITHING_MODE_CREATION then
			--d("CraftCompare:Update->SMITHING_MODE_CREATION")
			-- Create items
			itemLink = CraftCompare.GetValidSmithingItemLink()
			
		elseif mode == SMITHING_MODE_IMPROVEMENT then
            --SMITHING.improvementPanel:HasSelections() might return false as the function would need a slight delay of a few ms here.
            local hasImpItem = SMITHING.improvementPanel:HasSelections() or hasItemSlotted
            --d("CraftCompare:Update->SMITHING_MODE_IMPROVEMENT, hasImpItem: " ..tostring(hasImpItem))
            -- Improve items
			if hasImpItem then
                local bag, slot, craftSkillType = SMITHING.improvementPanel:GetCurrentImprovementParams()
                itemLink = GetSmithingImprovedItemLink(bag, slot, craftSkillType)
            end

		elseif mode == SMITHING_MODE_DECONSTRUCTION then
            --SMITHING.deconstructionPanel:HasSelections() might return false as the function would need a slight delay of a few ms here.
            local hasSelections = SMITHING.deconstructionPanel:HasSelections() or hasItemSlotted
			--d("CraftCompare:Update->SMITHING_MODE_DECONSTRUCTION, hasSelections: " .. tostring(hasSelections))
            if hasSelections then
                -- Deconstruct items; only when item is already selected
                local itemSlot = SMITHING.deconstructionPanel.extractionSlot
                itemLink = GetItemLink(itemSlot.bagId, itemSlot.slotIndex, LINK_STYLE_DEFAULT)
            end

		--[[
        elseif mode == SMITHING_MODE_RESEARCH then
			--d("CraftCompare:Update->SMITHING_MODE_RESEARCH")
			-- Research traits
			local data = SMITHING.researchPanel:GetSelectedData()
			
			if data and not data.areAllTraitsKnown then
				itemLink = CraftCompare.GetValidSmithingItemLink(data.researchLineIndex)
			end
        ]]
        end

		-- show our tooltips
		local slot, otherSlot = CraftCompare.GetCompareSlots(itemLink)
		local tooltip, otherTooltip = CraftCompare.UpdateTooltips(slot, otherSlot)
		
		-- update tooltip positions
		if tooltip then
			if otherTooltip and otherTooltip:GetHeight() == 0 then
				-- in case the tooltip is unitialized, try again later
				tooltip:SetHidden(true)
				otherTooltip:SetHidden(true)
				zo_callLater(CraftCompare.Update, 1)
				return
			end
			local anchors = {
				[SMITHING_MODE_CREATION]		= { _G.BOTTOMRIGHT, SMITHING.creationPanel.resultTooltip, _G.BOTTOMLEFT, -10, 0 },
				[SMITHING_MODE_IMPROVEMENT]		= { _G.BOTTOMRIGHT, SMITHING.improvementPanel.resultTooltip, _G.BOTTOMLEFT, -10, 0 },
				[SMITHING_MODE_DECONSTRUCTION]	= { _G.BOTTOMRIGHT, SMITHING.deconstructionPanel.extractionSlot.control, _G.TOPLEFT, -190+4, -93 },
				--[SMITHING_MODE_RESEARCH]		= { _G.BOTTOMRIGHT, GuiRoot, _G.CENTER, -240, 257 },
			}
			tooltip:ClearAnchors()
			tooltip:SetAnchor(unpack(anchors[mode] or {}))
			if otherTooltip then
				-- move tooltips so secondary (bottom one) aligns properly
				local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = tooltip:GetAnchor(0)
				if isValidAnchor then
					tooltip:ClearAnchors()
					tooltip:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY - otherTooltip:GetHeight() - 10)
				end
			end
		end
	end
	
end

-- ========================================================
--  Setup
-- ========================================================
function CraftCompare.onAddonLoaded(eventID, addonName)
	--Protect
	if addonName ~= CraftCompare.name then return end
	--Unregisters itselfs
	EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
	-- Settings & LAM
	CraftCompare.CreateSettings()
	local compareTooltip = WINDOW_MANAGER:CreateControlFromVirtual(CraftCompare.Tooltip, PopupTooltip, 'ZO_ItemIconTooltip')
	compareTooltip:ClearAnchors()
	compareTooltip:SetAnchor(TOP, PopupTooltip, BOTTOM, 0, 10)
	compareTooltip:SetHidden(true)
	compareTooltip:SetClampedToScreen(true)
	compareTooltip:SetMouseEnabled(true)
	compareTooltip:SetMovable(true)
	compareTooltip:SetExcludeFromResizeToFitExtents(true)
	CraftCompare.tooltip = compareTooltip

	local resultTooltip = WINDOW_MANAGER:CreateControlFromVirtual(CraftCompare.DeconstructTooltip, SMITHING.control, 'ZO_ItemIconTooltip')
	resultTooltip:ClearAnchors()
	resultTooltip:SetAnchor(BOTTOM, SMITHING.deconstructionPanel.extractionSlot.control, TOP, 0, -93)
	resultTooltip:SetHidden(true)
	resultTooltip:SetClampedToScreen(true)

    local function CCHideTooltips()
        -- Hide comparison tooltips
        PopupTooltip:SetHidden(true)
        resultTooltip:SetHidden(true)
    end

    local function updateDeconstructionSlottedItemTooltip(bag, slot)
        local tooltip = resultTooltip
        if bag and slot then
            local itemLink = GetItemLink(bag, slot)
            -- update our custom deconstruct tooltip
            InitializeTooltip(tooltip)
            tooltip:SetLink(itemLink)
            --Show the deconstruction tooltip for the item in the decon. slot
            CraftCompare.AddCraftingItemInfo(tooltip, itemLink)
        else
            ClearTooltip(tooltip)
        end
    end

	-- Compare to alternate set
	local isSHIFTCompared, lastSHIFTCheck = nil, 0
	ZO_PreHookHandler(SMITHING.control, 'OnUpdate', function(self, elapsed)
		if elapsed <= lastSHIFTCheck + 0.25 then return end
		lastSHIFTCheck = elapsed
		
		local shift = IsShiftKeyDown()
		if isSHIFTCompared ~= shift then
			isSHIFTCompared = shift
			local mode = SMITHING.mode
			local compareStyle = CraftCompare.db[mode]
			-- only show research PopupTooltip when dialog is actually open
            local allow = isCCActivatedAtCraftPanel(mode)
				and compareStyle == CC_TOOLTIP_TYPE_POPUP
				and ZO_InventorySlot_GetItemListDialog():GetControl():IsHidden()
			if allow then
				CraftCompare.Update()
			end
		end
	end)
	
	-- Hooks
	
	-- Hide PopUp when leaving craft station
	EVENT_MANAGER:RegisterForEvent(addonName, EVENT_END_CRAFTING_STATION_INTERACT, ZO_PopupTooltip_Hide)

	--> 2018-09-29, Baertram: Try to fix error within AdvancedFilters if used with CraftCompare. Error occured upon opening of the crafting table (Smithing e.g.)
	-- Remove PreHook of ZO_Smithing.SetMode and use a Mixture of PreHook and PostHook instead
	local originalSmithingSetMode = ZO_Smithing.SetMode
	-- Before changing mode (change tab)
	--PostHook of ZO_Smithing.SetMode function to update the tooltip afterwards
	ZO_Smithing.SetMode = function(self, mode)
        --d("[CraftCompare]ZO_Smithing.SetMode, mode: " ..tostring(mode))
        CCHideTooltips()
		--Call the original ZO_Smithing.SetMode function (SMITHING.SetMode)
		originalSmithingSetMode(self, mode)
		--Update the new tooltips now
		local allow = isCCActivatedAtCraftPanel(mode)
        if allow then
			CraftCompare.Update()
            --Deconstruction panel enabled? ReShow the currently slotted item tooltip again
            if mode == SMITHING_MODE_DECONSTRUCTION then
                local hasSelections = SMITHING.deconstructionPanel:HasSelections()
                if hasSelections then
                    -- Deconstruct items; only when item is already selected
                    local itemSlot = SMITHING.deconstructionPanel.extractionSlot
                    updateDeconstructionSlottedItemTooltip(itemSlot.bagId, itemSlot.slotIndex)
                end
            end
		end

	end

	ZO_PreHook(SMITHING, 'OnSelectedPatternChanged', function()
        local allow = isCCActivatedAtCraftPanel(SMITHING.mode)
        if allow then CraftCompare.Update() end
    end)  -- Crafting create

	--ZO_PreHook(SMITHING.researchPanel, 'Research', CraftCompare.Update) -- Research
	local dialog = ZO_InventorySlot_GetItemListDialog():GetControl()
	ZO_PreHook(dialog, 'SetHidden', function(self, hidden)
		if hidden and not SMITHING.control:IsHidden() and not PopupTooltip:IsHidden() then
			ZO_PopupTooltip_Hide()
		end
	end)

    local function doOnSlotChangedTooltipsChecks(slot, bagId, slotIndex, type)
        if slot == nil then return false end
        type = type or ""
        local tooltip = resultTooltip
        if bagId and slotIndex then
            local typeToSmithindMode = {
                ["deconstruction"]  = SMITHING_MODE_DECONSTRUCTION,
                ["improvement"]     = SMITHING_MODE_IMPROVEMENT,
            }
            if type == "deconstruction" then
                if IsDoItAllExtractionActive() then return end

            elseif type == "improvement" then
            end
            local smithingMode = typeToSmithindMode[type]
            if smithingMode == nil then return false end
            if CraftCompare.db[smithingMode] ~= CC_TOOLTIP_TYPE_POPUP then return end
            local allow = isCCActivatedAtCraftPanel(SMITHING.mode)
            if allow then
                if type == "deconstruction" then
                    updateDeconstructionSlottedItemTooltip(bagId, slotIndex)
                end
                --Show the equipped item tooltip, but delay it abit. Otherwise the bag, slot data is nil in the decon. panel
                zo_callLater(function() CraftCompare.Update(true) end, 50)
            end
        else
            ClearTooltip(tooltip)
            CCHideTooltips()
        end
    end

	-- update our custom deconstruct tooltip
	ZO_PreHook(SMITHING.deconstructionPanel, 'SetExtractionSlotItem', function(extractionSlot, bag, slot)
        --d("[CraftCompare]Deconstruction SetExtractionSlotItem")
        doOnSlotChangedTooltipsChecks(extractionSlot, bag, slot, "deconstruction")
    end)

    -- update our custom improvement tooltip
    ZO_PreHook(SMITHING.improvementPanel, 'SetImprovementSlotItem', function(improvementSlot, bag, slot)
        --d("[CraftCompare]Improvement SetImprovementSlotItem")
        doOnSlotChangedTooltipsChecks(improvementSlot, bag, slot, "improvement")
    end)

	-- ComparativeTooltips
	local origItemTooltipSetBagItem = ItemTooltip.SetBagItem
	ItemTooltip.SetBagItem = function(self, bag, slot)
		origItemTooltipSetBagItem(self, bag, slot)
		
		if not SMITHING.control:IsHidden() and CraftCompare.db[SMITHING.mode] == CC_TOOLTIP_TYPE_COMPARATIVE then
			CraftCompare.UpdateComparativeTooltips()
		end
	end
end

-- Initialize Addon
EVENT_MANAGER:RegisterForEvent(CraftCompare.name, EVENT_ADD_ON_LOADED, CraftCompare.onAddonLoaded)
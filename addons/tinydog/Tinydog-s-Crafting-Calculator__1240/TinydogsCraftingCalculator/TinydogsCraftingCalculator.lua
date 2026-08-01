-- TinydogsCraftingCalculator Main LUA File
-- Last Updated June 29, 2024 by @tinydog
-- Created September 2015 by @tinydog - tinydog1234@hotmail.com

tcc = {}
tcc.Version = "1.23.42"
tcc.Scope = {}
tcc.SavedVars = {}

function tcc_OnLoadEventHandler()
	EVENT_MANAGER:UnregisterForEvent("tcc_OnLoad", EVENT_ADD_ON_LOADED)

	-- Syntax:  ZO_SavedVars:New(savedVariableTable, version, namespace, defaults, profile, displayName, characterName)
	-- *savedVariableTable - The string name of the saved variable table
	-- *version - The current version. If the saved data is a lower version it is destroyed and replaced with the defaults
	-- *namespace - An optional string namespace to separate other variables using the same table
	-- *defaults - A table describing the default saved variables, see the example below
	-- *profile - An optional string to describe the profile, or "Default"
	tcc.SavedVars.Local = ZO_SavedVars:New("TinydogsCraftingCalculatorVars", 2, nil, { 
			TabSelected = "tccBuilderTabButton",
			CraftSelected = "Blacksmithing",
		})
	-- Syntax:  ZO_SavedVars:NewAccountWide(savedVariableTable, version, namespace, defaults, profile, displayName)
	tcc.SavedVars.Global = ZO_SavedVars:NewAccountWide("TinydogsCraftingCalculatorVars", 2, nil, {
			EsoPlus = false,
			Scope = {
				ItemOrder = "Local",
			},
		})
	
	tcc_RegisterAddonSettingsMenu()
end

function tcc_ToggleCalculatorWindow()
	if SCENE_MANAGER:GetCurrentScene():GetName() == 'gameMenuInGame' then return end
	if tcc.IsInitialized == nil or tcc.IsInitialized == false then
		tcc_Initialize()
	end
	
	tccUI:SetHidden(tcc.IsVisible)
	if tcc.IsVisible == true then
		tcc.IsVisible = false
		if tccLoadSaveItemOrder:IsHidden() == false then tcc_HideLoadSaveDialog() end
		SetGameCameraUIMode(SCENE_MANAGER:GetCurrentScene():GetName() ~= 'hudui')
	else
		tcc.IsVisible = true
		tcc.CursorWasActive = IsGameCameraUIModeActive()
		SetGameCameraUIMode(true)
		tcc_InitQualityMats()
		if tcc.IntegrateMM then 
			tcc_CalculateTotalCostOfMaterials(tccTotalMaterialsCost, tccTotalMaterialsNeededForOrder:GetNamedChild("ListItems"))
		end
		tcc_ExpandShrinkCalculatorWindow()
	end
end
SLASH_COMMANDS["/tcc"] = tcc_ToggleCalculatorWindow

function tcc_Initialize()
	tcc.IntegrateMM = (MasterMerchant ~= nil)
	-- Add MM tooltip info to item "MouseOver" tooltips.  The "Popup" tooltips work without extra code.
	if tcc.IntegrateMM then ZO_PreHookHandler(ItemTooltip, 'OnUpdate', function() tcc_MM_addStatsItemTooltip() end) end
	tccTotalMaterialsCostLabel:SetHidden(tcc.IntegrateMM == false)
	tccTotalMaterialsCost:SetHidden(tcc.IntegrateMM == false)
	
	-- Get the UI's window position from tcc.SavedVars.Local.
	tcc_RestoreSavedWindowPosition(tccUI)
	
	tcc.IsVisible = false
	tcc.IsInitialized = false
	tcc.ItemBuilder = {}
	tcc_InitItemData()
	tcc_InitCraftingData()

	tcc.FONT_TABLE_HEADER = "ZoFontWindowSubtitle"
	tcc.FONT_TABLE_CELL_HEAVY = "tcc_ZoFontWindowSubtitleSmall"
	tcc.FONT_TABLE_CELL_MEDIUM = "tcc_ZoFontTooltipSubtitleSmall"
	tcc.FONT_TABLE_CELL_TINY = "tcc_ZoFontTooltipSubtitleTiny"

	-- Set version text
	tccVersion:SetText("v " .. tcc.Version)
	
	-- Crafting Simulator
	tccLevelSlider:SetMinMax(1, table.getn(tcc.ItemLevels))
	tccLevelSlider:SetValue(tcc_GetLevelIndex(tcc_GetPlayerLevel()))
	tcc_InitItemTraitIcons(tccItemTraitRow)
	tcc_InitRacialStyleDropdown(tccItemStyleRow)
	tcc_InitItemQualityIcons(tccItemQualityRow)
	tcc_SelectItemTrait(tccItemTraitRowNone)
	tcc_SelectItemQuality(tccItemQualityRowWhite)
	tcc_InitItemSetDropdown(tccItemStyleRow)
	tcc_PopulateImprovementSkillsBox()

	-- Order Scroll List
	-- Syntax:  ZO_ScrollList_AddDataType(scrollControl, dataTypeId, templateName, height, setupCallback, hideCallback, dataTypeSelectSound, resetControlCallback)  
	ZO_ScrollList_AddDataType(tccOrderList, 1, "tccOrderItemTemplate", 25, tcc_SetOrderItem)
	-- Syntax:  ZO_ScrollList_AddCategory(self, categoryId, parentId)
	ZO_ScrollList_SetUseFadeGradient(tccOrderList, true)
	-- Restore the order items from SavedVariables
	tcc_LoadOrderItemListData()

	-- Saved Order Scroll List
	ZO_ScrollList_AddDataType(tccSavedOrderList, 1, "tccSavedOrderTemplate", 25, tcc_SetSavedOrder)
	ZO_ScrollList_SetUseFadeGradient(tccSavedOrderList, true)
	tcc_LoadSavedOrderListData()
	
	-- Crafting XP
	tcc_InitXPModifiers()
	tcc.CraftSelected = tcc.SavedVars.Local.CraftSelected
	tcc.CreateOrDeconSelected = "Deconstruct"
	tcc.XpQualitySelected = tcc.ItemQuality["White"]
	tccDesiredCraftingSkillLevel:SetText("50")
	if tcc.CraftSelected == "Enchanting" then tcc_InitEnchantingXpTable() else tcc_InitCraftingXpTable() end
	tcc_SelectCraft(tcc.CraftSelected)
	
	-- Restore tab selection from tcc.SavedVars.Local
	tcc.TabSelected = tcc.SavedVars.Local.TabSelected
	tcc_SelectTab(tcc.TabSelected) 
	
	-- Hide TCC if the game menu is opened, and restore TCC once the game menu is exited.
	ZO_PreHookHandler(ZO_GameMenu_InGame, 'OnShow', function()  
			if tccLoadSaveItemOrder:IsHidden() == false then tcc_HideLoadSaveDialog() end
			if tccClipboardWindow:IsHidden() == false then tccClipboardWindow:SetHidden(true) end
			if tcc.IsVisible then tccUI:SetHidden(true) end  
		end)
	ZO_PreHookHandler(ZO_GameMenu_InGame, 'OnHide', function()  
			if tcc.IsVisible then tccUI:SetHidden(false) end  
		end)

	tcc.IsInitialized = true
end

function tcc_SelectTab(controlName)
	tcc.SavedVars.Local.TabSelected = controlName
	tccCraftingXpFrame:SetHidden(controlName == "tccBuilderTabButton")
	tccItemBuilderFrame:SetHidden(controlName == "tccXpTabButton")
	if controlName == "tccXpTabButton" then
		tccSubtitle:SetText("Crafting XP (Inspiration)")
	elseif controlName == "tccBuilderTabButton" then
		tccSubtitle:SetText("Item Builder")
	end
	tcc_ExpandShrinkCalculatorWindow()
end

function tcc_ExpandShrinkCalculatorWindow()
	if tccCraftingXpFrame:IsHidden() == false then
		-- Last visible child (XP grid cell) of last visible child (XP frame or Enchanting XP frame)
		tccUI:SetHeight(3 + tcc_GetLastVisibleChild(tcc_GetLastVisibleChild(tccXpTableFrame)):GetBottom() - tccUI:GetTop())
	else
		tccUI:SetHeight(10 + tccOrderListFrame:GetBottom() - tccUI:GetTop())
	end
end


--[[ Utility Functions ]]--

function tcc_InitCheckbox(checkbox, toggleFunction, label, tooltip, initialValue)
	ZO_CheckButton_SetToggleFunction(checkbox, toggleFunction)
	ZO_CheckButton_SetLabelText(checkbox, label)  -- This creates {checkbox}Label.
	local labelControl = checkbox:GetChild(1)
	labelControl:SetFont("tcc_ZoFontBookRubbingSmallShadow")
	labelControl:SetColor(0.81, 0.86, 0.74, 1)
	labelControl:SetHandler('OnMouseEnter', function() 
		tcc_ShowTextTooltip(labelControl, tooltip) 
		ZO_CheckButtonLabel_ColorText(labelControl, true)  -- Checkbox label mouseover highlight
	end)
	labelControl:SetHandler('OnMouseExit', function() 
		tcc_ClearTooltip(labelControl, InformationTooltip) 
		ZO_CheckButtonLabel_ColorText(labelControl, false)
	end)
	ZO_CheckButton_SetCheckState(checkbox, initialValue)
end

function tcc_RestoreSavedWindowPosition(control)
	local x, y
	if tcc.SavedVars.Local.WindowPosition ~= nil then
		if tcc.SavedVars.Local.WindowPosition[control:GetName()] ~= nil then
			x = tcc.SavedVars.Local.WindowPosition[control:GetName()].x
			y = tcc.SavedVars.Local.WindowPosition[control:GetName()].y
		end
	end
	if x ~= nil and y ~= nil then
		tccUI:ClearAnchors()
		tccUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
	end
end

function tcc_SaveWindowPosition(control)
	if tcc.SavedVars.Local.WindowPosition == nil then tcc.SavedVars.Local.WindowPosition = { } end
	tcc.SavedVars.Local.WindowPosition[control:GetName()] = { x = control:GetLeft(), y = control:GetTop() }
end

function tcc_GetPlayerLevel()
	local nonVetLevel = GetUnitLevel("player")
	local vetRank = GetUnitVeteranRank("player")
	if vetRank > 0 then
		return "CP" .. vetRank
	else
		return nonVetLevel
	end
end

-- Returns player's rank (1+) in the given ability, or 0 if the ability is not purchased
-- Example:  local hasAbility = tcc_GetAbilityRank(SKILL_TYPE_RACIAL, TCC_RACIAL_SKILLS_INDEX, TCC_RACIAL_SKILL_ORC_CRAFTSMAN_INDEX)
function tcc_GetAbilityRank(skillType, skillIndex, abilityIndex)
	local name, texture, earnedRank, passive, ultimate, purchased, progressionIndex = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
	return purchased and earnedRank or 0
end

function tcc_CopyToClipboard(text)
	tccClipboard:SetText(text)
	tccClipboardWindow:SetHidden(false)
	tccClipboard:SelectAll()
	tccClipboard:TakeFocus()
end

function tcc_PasteToChat(text)
    local ChatEditControl = CHAT_SYSTEM.textEntry.editControl
    if (not ChatEditControl:HasFocus()) then StartChatInput() end
    ChatEditControl:InsertText(text)
end

function tcc_PasteToMail(to, subject, body)
	if SCENE_MANAGER:IsShowing('mailSend') == false then SCENE_MANAGER:Show('mailSend') end
	if ZO_MailSendToField:GetText() == "" then ZO_MailSendToField:SetText(to) end
	if ZO_MailSendSubjectField:GetText() == "" then ZO_MailSendSubjectField:SetText(subject) end
	ZO_MailSendBodyField:SetText((ZO_MailSendBodyField:GetText() ~= "" and ZO_MailSendBodyField:GetText() .. "\n" or "") .. body)
    ZO_MailSendBodyField:TakeFocus()
end

--function tcc_RegisterItemLinkClick(control, itemLink)
--	control:SetMouseEnabled(true)
--	control:SetHandler('OnClicked', function() tcc_ShowItemTooltip(control, itemLink) end) --tcc_PasteToChat(itemLink)
--end

--function tcc_UnregisterItemLinkClick(control)
--	control:SetMouseEnabled(false)
--	control:SetHandler('OnClicked', nil)
--	control.ItemLink = nil
--end

function tcc_RegisterItemTooltip(control, itemLink)
	control:SetMouseEnabled(true)
	control:SetHandler('OnMouseEnter', function() tcc_ShowItemTooltip(control, itemLink) end)
	control:SetHandler('OnMouseExit', function() ClearTooltip(ItemTooltip) end)
	control.ItemLink = itemLink
end

function tcc_RegisterTextTooltip(control, tooltipText, highlightOnMouseOver)
	control:SetMouseEnabled(true)
	control:SetHandler('OnMouseEnter', function() tcc_ShowTextTooltip(control, tooltipText, highlightOnMouseOver) end)
	control:SetHandler('OnMouseExit', function() tcc_ClearTooltip(control, InformationTooltip, highlightOnMouseOver) end)
end

function tcc_RegisterItemPlusTextTooltip(control, itemLink, tooltipText, highlightOnMouseOver)
	control:SetMouseEnabled(true)
	control:SetHandler('OnMouseEnter', function() 
		tcc_ShowItemTooltip(control, itemLink)
		tcc_ShowTextTooltip(control, tooltipText, highlightOnMouseOver)
	end)
	control:SetHandler('OnMouseExit', function() 
		ClearTooltip(ItemTooltip)
		tcc_ClearTooltip(control, InformationTooltip, highlightOnMouseOver)
	end)
	control.ItemLink = itemLink
end

function tcc_RegisterSkillAbilityTooltip(control, skillType, skillIndex, abilityIndex)
	control.skillType = skillType
	control.lineIndex = skillIndex
	control.index = abilityIndex
	control:SetMouseEnabled(true)
	control:SetHandler("OnMouseEnter", function() tcc_ZO_Skills_AbilitySlot_OnMouseEnter(control) end)
	control:SetHandler("OnMouseExit", function() ZO_Skills_AbilitySlot_OnMouseExit() end)
end

-- Duplicate of stock function, used to circumvent an error when mousing over the Item Improvement Skills craft icons
-- https://esoapi.uesp.net/100020/src/ingame/skills/keyboard/zo_skills.lua.html#676
function tcc_ZO_Skills_AbilitySlot_OnMouseEnter(control)
    InitializeTooltip(SkillTooltip, control, TOPLEFT, 5, -5, TOPRIGHT)
    SkillTooltip:SetSkillAbility(control.skillType, control.lineIndex, control.index)
end

-- Function courtesy Dolgubon. Patch 4.3.7 3/11/2019 broke the stock function GetCraftingSkillLineIndices().
function tcc_GetCraftingSkillLineIndices(tradeskillType)
    local skillLineData = SKILLS_DATA_MANAGER:GetCraftingSkillLineData(tradeskillType)
    if skillLineData then
        return skillLineData:GetIndices()
    end
    return 0, 0, 0
end

function tcc_ClearTooltip(control, tooltipType, highlightOnMouseOver)
	ClearTooltip(tooltipType) 
	if highlightOnMouseOver then tcc_UnHighlightText(control) end
end

function tcc_UnregisterTooltip(control)
	control:SetMouseEnabled(false)
	control:SetHandler('OnMouseEnter', nil)
	control:SetHandler('OnMouseExit', nil)
	control.ItemLink = nil
end

function tcc_ShowItemTooltip(control, itemLink)
	InitializeTooltip(ItemTooltip, control)
	ItemTooltip:SetLink(itemLink)
end

function tcc_ShowTextTooltip(control, tooltipText, highlightOnMouseOver)
	InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -5)
	SetTooltipText(InformationTooltip, tooltipText)
	if highlightOnMouseOver then tcc_HighlightText(control) end
end

function tcc_HighlightText(control)
	if control ~= nil then
		control.OriginalColorR, control.OriginalColorG, control.OriginalColorB, control.OriginalColorA = control:GetColor()
		control:SetColor(1, 0.5, 0, 1) 
	end
end

function tcc_UnHighlightText(control)
	if control ~= nil and control.OriginalColorR ~= nil then
		control:SetColor(control.OriginalColorR, control.OriginalColorG, control.OriginalColorB, control.OriginalColorA) 
	end
end

function tcc_Colorize(stringToColorize, rgbHex)
	return "|c" .. rgbHex .. stringToColorize .. "|r"
end

function tcc_StripColorTags(stringToStrip)
	local stripped = string.gsub(stringToStrip, "|[cC][%dA-Fa-f][%dA-Fa-f][%dA-Fa-f][%dA-Fa-f][%dA-Fa-f][%dA-Fa-f]", "")
	stripped = string.gsub(stripped, "|[rR]", "")
	return stripped
end

function tcc_IsInteger(value)
	return value == math.floor(value)
end

function tcc_CommaValue(n) -- credit http://richard.warburton.it
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

--[[
function tcc_ShallowCopyTable(orig) -- credit http://lua-users.org/wiki/CopyTable
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
]]

function tcc_DeepCopyTable(orig) -- credit http://lua-users.org/wiki/CopyTable
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[tcc_DeepCopyTable(orig_key)] = tcc_DeepCopyTable(orig_value)
        end
        setmetatable(copy, tcc_DeepCopyTable(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- indexOrFieldName is optional.
function tcc_Sort(tableToSort, indexOrFieldName) --, descending)
	if tableToSort == nil or type(tableToSort) ~= "table" then return end
	if indexOrFieldName ~= nil and (type(indexOrFieldName) == "number" or type(indexOrFieldName) == "string") then
		-- The function argument of table.sort returns true if "a" should be sorted before "b".
		table.sort(tableToSort, function(a, b)
				return (a[indexOrFieldName] < b[indexOrFieldName])
			end)
	else
		table.sort(tableToSort, function(a, b)
				return (a < b)
			end)
	end
end

function tcc_EnforcePositiveIntegerValue(control, substituteValueIfInvalid)
	if control == nil then return end
	local value = tonumber(control:GetText())
	if value == nil or value < 0 then 
		value = (substituteValueIfInvalid and substituteValueIfInvalid or nil)
		control:SetText(substituteValueIfInvalid and substituteValueIfInvalid or "")
	else
		value = math.ceil(value) 
		control:SetText(value)
	end
	return value
end

function tcc_InitIcon(parentControl, anchorControl, iconData, onClickFunction)
	local offsetX = ((iconData.Key == "None" or iconData.Key == "Any" or iconData.IconType == "Quality") and 5 or 2)
	local width, height
	if iconData.Key == "None" or iconData.Key == "Any" then 
		width = 32
		height = 32
	else 
		width = 28
		height = 28
	end
	local icon, iconLabel
	icon = tcc_GetOrCreateControlFromVirtual(parentControl, parentControl:GetName() .. iconData.Key, "tccIconButtonTemplate")
	icon:SetDimensions(width, height)
	icon:SetAnchor(LEFT, anchorControl, RIGHT, offsetX, 0)
	icon:SetNormalTexture(iconData.NormalTexture)
	icon.IconData = iconData
	icon:SetMouseOverTexture(iconData.MouseOverTexture ~= nil and iconData.MouseOverTexture or iconData.NormalTexture)
	icon:SetPressedTexture(iconData.SelectedTexture ~= nil and iconData.SelectedTexture or (iconData.MouseOverTexture ~= nil and iconData.MouseOverTexture or iconData.NormalTexture))
	icon:SetHandler("OnMouseEnter", function() tcc_ShowTextTooltip(icon, iconData.Name) end)
	icon:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
	if onClickFunction ~= nil then
		icon:SetHandler("OnClicked", function() onClickFunction(icon) end)
	end
	return icon
end

-- additionalTooltipText is optional
function tcc_CreateLinkEnabledIcon(parent, controlName, itemLink, texturePath, width, height, anchorPoint, anchorRelativeTo, anchorRelativePoint, anchorOffsetX, anchorOffsetY, additionalTooltipText)
	if width == nil then width = 32 end
	if height == nil then height = 32 end
	if anchorPoint == nil then anchorPoint = TOPLEFT end
	if anchorRelativeTo == nil then anchorRelativeTo = parent end
	if anchorRelativePoint == nil then anchorRelativePoint = TOPLEFT end
	if anchorOffsetX == nil then anchorOffsetX = 0 end
	if anchorOffsetY == nil then anchorOffsetY = 0 end
	local icon, iconButton 
	if icon == nil then icon = tcc_GetOrCreateControlFromVirtual(parent, controlName, "tccLinkEnabledLabelTemplate") end
	icon:ClearAnchors()
	icon:SetAnchor(anchorPoint, anchorRelativeTo, anchorRelativePoint, anchorOffsetX, anchorOffsetY)
	icon:SetDimensions(width, height)
	icon:SetMouseEnabled(true)
	icon:SetText(itemLink)
	icon:SetAlpha(0)
	icon:SetHidden(false)
	icon.ItemLink = itemLink
	if additionalTooltipText and additionalTooltipText ~= "" then
		-- tcc_RegisterItemPlusTextTooltip(control, itemLink, tooltipText, highlightOnMouseOver)
		tcc_RegisterItemPlusTextTooltip(icon, itemLink, additionalTooltipText, false)
	else
		tcc_RegisterItemTooltip(icon, itemLink)
	end
	if iconButton == nil then iconButton = tcc_GetOrCreateControlFromVirtual(parent, controlName .. "Texture", "tccIconButtonTemplate") end
	iconButton:ClearAnchors()
	iconButton:SetAnchor(anchorPoint, anchorRelativeTo, anchorRelativePoint, anchorOffsetX, anchorOffsetY)
	iconButton:SetDimensions(width, height)
	iconButton:SetNormalTexture(texturePath)
	iconButton:SetHidden(false)
	return icon, iconButton
end

function tcc_GetOrCreateControlFromVirtual(parent, controlName, virtualControlName)
	local child
	if parent == nil then return nil end
	if parent:GetNumChildren() > 0 then
		for i = 1, parent:GetNumChildren() do
			if parent:GetChild(i) ~= nil and parent:GetChild(i):GetName() == controlName then return parent:GetChild(i) end
		end
	end
	child = CreateControlFromVirtual(controlName, parent, virtualControlName)
	return child
end

function tcc_GetOrCreateControl(parent, controlName, controlType)
	local child
	if parent == nil then return nil end
	if parent:GetNumChildren() > 0 then
		for i = 1, parent:GetNumChildren() do
			if parent:GetChild(i) ~= nil and parent:GetChild(i):GetName() == controlName then return parent:GetChild(i) end
		end
	end
	child = parent:CreateControl(controlName, controlType)
	return child
end

function tcc_DrawBorder(control, r, g, b, a, thickness, offset)
	local sides = {
		tcc_GetOrCreateControl(control, control:GetName() .. "BorderTop", CT_LINE),
		tcc_GetOrCreateControl(control, control:GetName() .. "BorderLeft", CT_LINE),
		tcc_GetOrCreateControl(control, control:GetName() .. "BorderBottom", CT_LINE),
		tcc_GetOrCreateControl(control, control:GetName() .. "BorderRight", CT_LINE),
	}
	-- TOP = 1
	-- LEFT = 2
	-- BOTTOM = 4
	-- RIGHT = 8
	-- TOPLEFT = 3
	-- BOTTOMLEFT = 6
	-- TOPRIGHT = 9
	-- BOTTOMRIGHT = 12
	local topAnchors = { TOPLEFT, TOPLEFT, BOTTOMLEFT, TOPRIGHT }
	local bottomAnchors = { TOPRIGHT, BOTTOMLEFT, BOTTOMRIGHT, BOTTOMRIGHT }
	local topOffsetX = { offset * -1, offset * -1, offset * -1, offset }
	local topOffsetY = { offset * -1, offset * -1, offset, offset * -1 }
	local bottomOffsetX = { offset, offset * -1, offset, offset }
	local bottomOffsetY = { offset * -1, offset, offset, offset }
	for i, side in ipairs(sides) do
		side:SetColor(r, g, b, a)
		side:SetThickness(thickness)
		side:SetInheritScale(false)
		side:ClearAnchors()
		side:SetAnchor(TOP, control, topAnchors[i], topOffsetX[i], topOffsetY[i])
		side:SetAnchor(BOTTOM, control, bottomAnchors[i], bottomOffsetX[i], bottomOffsetY[i])
		side:SetHidden(false)
	end
end

function tcc_HideBorder(control)
	if control:GetNamedChild("BorderTop") ~= nil then control:GetNamedChild("BorderTop"):SetHidden(true) end
	if control:GetNamedChild("BorderLeft") ~= nil then control:GetNamedChild("BorderLeft"):SetHidden(true) end
	if control:GetNamedChild("BorderBottom") ~= nil then control:GetNamedChild("BorderBottom"):SetHidden(true) end
	if control:GetNamedChild("BorderRight") ~= nil then control:GetNamedChild("BorderRight"):SetHidden(true) end
end

function tcc_HideOverlay(control)
	if control == nil or control.Overlay == nil then return end
	control.Overlay:SetHidden(true)
end

function tcc_ControlTypeName(control)
	if control:GetType() == CT_BACKDROP then return "CT_BACKDROP" end
	if control:GetType() == CT_BROWSER then return "CT_BROWSER" end
	if control:GetType() == CT_BUTTON then return "CT_BUTTON" end
	if control:GetType() == CT_COLORSELECT then return "CT_COLORSELECT" end
	if control:GetType() == CT_COMPASS then return "CT_COMPASS" end
	if control:GetType() == CT_CONTROL then return "CT_CONTROL" end
	if control:GetType() == CT_COOLDOWN then return "CT_COOLDOWN" end
	if control:GetType() == CT_DEBUGTEXT then return "CT_DEBUGTEXT" end
	if control:GetType() == CT_EDITBOX then return "CT_EDITBOX" end
	if control:GetType() == CT_INVALID_TYPE then return "CT_INVALID_TYPE" end
	if control:GetType() == CT_LABEL then return "CT_LABEL" end
	if control:GetType() == CT_LINE then return "CT_LINE" end
	if control:GetType() == CT_MAPDISPLAY then return "CT_MAPDISPLAY" end
	if control:GetType() == CT_ROOT_WINDOW then return "CT_ROOT_WINDOW" end
	if control:GetType() == CT_SCROLL then return "CT_SCROLL" end
	if control:GetType() == CT_SLIDER then return "CT_SLIDER" end
	if control:GetType() == CT_STATUSBAR then return "CT_STATUSBAR" end
	if control:GetType() == CT_TEXTBUFFER then return "CT_TEXTBUFFER" end
	if control:GetType() == CT_TEXTURE then return "CT_TEXTURE" end
	if control:GetType() == CT_TEXTURECOMPOSITE then return "CT_TEXTURECOMPOSITE" end
	if control:GetType() == CT_TOOLTIP then return "CT_TOOLTIP" end
	if control:GetType() == CT_TOPLEVELCONTROL then return "CT_TOPLEVELCONTROL" end
end

function tcc_GetLastVisibleChild(control)
	local child
	if control == nil then return end
	if control:GetNumChildren() == 0 then return control end
	for i = control:GetNumChildren(), 1, -1 do
		child = control:GetChild(i)
		if child:IsHidden() == false then return child end
	end
end


--[[ Table Functions ]]--

function tcc_DrawTable(parent, tableName, numRows, colWidthsArray, hasHeaderRow)
	local ROW_HEIGHT = 22
	local HEADER_HEIGHT = 23
	if tcc.Tables == nil then tcc.Tables = {} end
	tcc.Tables[tableName] = tcc_GetOrCreateControl(parent, parent:GetName() .. tableName, CT_CONTROL)
	tcc.Tables[tableName].Name = tableName
	tcc.Tables[tableName].ColWidths = colWidthsArray
	tcc.Tables[tableName].HasHeaderRow = hasHeaderRow
	tcc.Tables[tableName].CellLabels = {}
	tcc.Tables[tableName]:ClearAnchors()
	tcc.Tables[tableName]:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
	local rowHeight, cell, font
	local offsetX = 0
	local offsetY = 0
	local textOffsetY = 0
	for row = 1, numRows, 1 do
		offsetX = 0
		for col, colWidth in ipairs(colWidthsArray) do
			if row == 1 and hasHeaderRow then	-- Header row
				rowHeight = 46
				font = tcc.FONT_TABLE_HEADER
				textOffsetY = 0
			else								-- All other rows
				rowHeight = 24
				font = tcc.FONT_TABLE_CELL_MEDIUM
				textOffsetY = 2
			end
			cell = tcc_GetOrCreateControl(tcc.Tables[tableName], tcc.Tables[tableName]:GetName() .. "_CellR" .. row .. "C" .. col, CT_BACKDROP)
			-- SetCenterColor(number r, number g, number b, number a)
			cell:SetCenterColor(0, 0, 0, 0)
			-- SetEdgeTexture(string filename, integer edgeFileWidth, integer edgeFileHeight, integer edgeSize, integer edgeFilePadding)
			cell:SetEdgeTexture("/EsoUI/Art/Tooltips/UI-SliderBackdrop.dds", 32, 4, nil, nil)
			cell:ClearAnchors()
			cell:SetAnchor(TOPLEFT, tcc.Tables[tableName], TOPLEFT, offsetX, offsetY)
			cell:SetDimensions(colWidth, rowHeight)
			if tcc.Tables[tableName].CellLabels[row] == nil then tcc.Tables[tableName].CellLabels[row] = { 
				ParentTable = tcc.Tables[tableName],
				RowNum = row,
			} end
			tcc.Tables[tableName].CellLabels[row][col] = tcc_GetOrCreateControl(cell, cell:GetName() .. "Label", CT_LABEL)
			tcc.Tables[tableName].CellLabels[row][col].ParentRow = tcc.Tables[tableName].CellLabels[row]
			tcc.Tables[tableName].CellLabels[row][col].ParentTable = tcc.Tables[tableName]
			tcc.Tables[tableName].CellLabels[row][col]:SetFont(font)
			tcc.Tables[tableName].CellLabels[row][col]:SetColor(0.81, 0.86, 0.74, 1)
			tcc.Tables[tableName].CellLabels[row][col]:SetWrapMode(ELLIPSIS)
			tcc.Tables[tableName].CellLabels[row][col]:SetVerticalAlignment(TOP)
			tcc.Tables[tableName].CellLabels[row][col]:SetHorizontalAlignment(CENTER)
			tcc.Tables[tableName].CellLabels[row][col]:ClearAnchors()
			tcc.Tables[tableName].CellLabels[row][col]:SetAnchor(TOPLEFT, cell, TOPLEFT, 6, textOffsetY)
			offsetX = offsetX + colWidth
		end --col
		offsetY = offsetY + rowHeight
	end --row
	return tcc.Tables[tableName]
end

function tcc_ClearTableCell(cellControl)
	if cellControl == nil then return end
	local child
	if cellControl:GetType() == CT_LABEL then cellControl:SetText("") end
	tcc_UnregisterTooltip(cellControl)
	if cellControl:GetNumChildren() > 0 then
		for childNum = 1, cellControl:GetNumChildren(), 1 do
			child = cellControl:GetChild(childNum)
			if child:GetType() == CT_LABEL then child:SetText("") else child:SetHidden(true) end
			tcc_UnregisterTooltip(child)
		end
	end
end

-- Requires that the table cells' numeric .Value property was set.
function tcc_HighlightLowestValueInTableColumn(tableControl, colIndex)
	if tableControl == nil or tableControl.CellLabels == nil or colIndex < 1 or colIndex > table.getn(tableControl.CellLabels[1]) then return end
	local lowestValue = 0
	local value
	-- Iteration 1: Find the lowest value.
	for rowIndex, row in ipairs(tableControl.CellLabels) do
		local cell = row[colIndex]
		value = cell.Value
		if value ~= nil then
			if lowestValue == 0 or value < lowestValue then lowestValue = value end
		end
	end
	-- Iteration 2: Highlight the lowest value, and dehighlight everything else.
	for rowIndex, row in ipairs(tableControl.CellLabels) do
		local cell = row[colIndex]
		value = cell.Value
		if value ~= nil and value == lowestValue then
			if cell.OriginalColorR == nil then 
				cell.OriginalColorR, cell.OriginalColorG, cell.OriginalColorB, cell.OriginalColorA = cell:GetColor()
			end
			cell:SetColor(1, 0.5, 0, 1) 
		else
			if cell.OriginalColorR ~= nil then
				cell:SetColor(cell.OriginalColorR, cell.OriginalColorG, cell.OriginalColorB, cell.OriginalColorA)
				cell.OriginalColorR = nil
				cell.OriginalColorG = nil
				cell.OriginalColorB = nil
				cell.OriginalColorA = nil
			end
		end
	end
end

function tcc_SetRowHidden(tableControl, rowNum, hidden)
	if tableControl == nil then return end
	if tableControl.CellLabels[rowNum] == nil then return end
	local numCols = table.getn(tableControl.CellLabels[rowNum])
	if numCols == 0 then return end
	for colIndex = 1, numCols do
		tableControl.CellLabels[rowNum][colIndex]:GetParent():SetHidden(hidden)
	end
end


--[[ Master Merchant Integration Functions ]]--

-- This bit is necessary in order for MM to recognize and add its info to TCC's mouseover item tooltips, 
-- since MM looks only for specific control names.
function tcc_MM_addStatsItemTooltip()
	local skMoc = moc()
	local itemLink = skMoc.ItemLink
	-- While it's not technically necessary to limit this conditional to only controls whose names start with "tcc", 
	-- it ensures that TCC doesn't overstep its bounds and affect other add-ons.
	if itemLink and string.sub(skMoc:GetName(), 1, 3) == "tcc" then
		if MasterMerchant.tippingControl ~= skMoc then
			if ItemTooltip.graphPool then
				ItemTooltip.graphPool:ReleaseAllObjects()
			end
			ItemTooltip.mmGraph = nil
			if ItemTooltip.textPool then
				ItemTooltip.textPool:ReleaseAllObjects()
			end
			ItemTooltip.mmText = nil
		end

		MasterMerchant.tippingControl = skMoc
		MasterMerchant.isShiftPressed = IsShiftKeyDown()
		MasterMerchant.isCtrlPressed = IsControlKeyDown()
		MasterMerchant:addStatsAndGraph(ItemTooltip, itemLink)
	end
end


--[[ OnLoad Event ]]--
EVENT_MANAGER:RegisterForEvent("tcc_OnLoad", EVENT_ADD_ON_LOADED, tcc_OnLoadEventHandler)

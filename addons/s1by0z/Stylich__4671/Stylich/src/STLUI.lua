-- addon namespace (single global table, defined in STLConstants.lua)
local STLUI = Stylich.UI
local STLApp = Stylich.App
local STLModel = Stylich.Model
local STLLang = Stylich.Lang

-- Helper
local SM = SCENE_MANAGER
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER
local OFMGR = ZO_OUTFIT_MANAGER
local ZOSF = zo_strformat

-- locals
local STYLE_BG_COLOR = ZO_ColorDef:New(0, 0, 0, 0.2)
local STYLE_BORDER_COLOR = ZO_ColorDef:New(0xFC, 0xFC, 0xFC, 0.5)
local DUMMY_CATEGORY_COSTUME = 999
local STILESETS_DATA = 5
local MSG = STLLang.msg

-- Weapon slots shown in the detail panel (front bar main+off, back bar main+off)
local WEAPON_DISPLAY_SLOTS = {
	EQUIP_SLOT_MAIN_HAND,
	EQUIP_SLOT_OFF_HAND,
	EQUIP_SLOT_BACKUP_MAIN,
	EQUIP_SLOT_BACKUP_OFF,
}
local TEX_WEAPON_UNEQUIP = "esoui/art/buttons/decline_up.dds"    -- saved empty -> will unequip
local TEX_WEAPON_NONE = "esoui/art/miscellaneous/locked_up.dds"  -- keep / don't touch this slot



-- Stylich App / Meta
STLApp.name = 'Stylich'
STLApp.displayname = 'Stylich'
STLApp.version = 'v1.2.2'
STLApp.author = '@s1by0z'

-- Update Event Queue
STLApp.Jobs = {}                -- List of jobs to be executed in the OnUpdate event. Element of form {JOB_TYPE, BAG, SLOT}
STLApp.NextEventTime = 0        -- Time for the next event

-- Stylich UI
STLUI.detailControls = {}
STLUI.currentStyleSetId = false


--- Writes trace messages to the console
-- fmt with %d, %s,
local function trace(fmt, ...)
	if STLModel.isDebug then
		d(string.format(fmt, ...))
    end
end

function STLUI.SetCurrentStyleSetId(id)
	STLUI.currentStyleSetId = id
end

function STLUI.GetCurrentStyleSetId()
	return STLUI.currentStyleSetId
end

----------------------------- Helper

local function CreateBuildSectionLabel (parent, sectionId, previousCtrl, anchorPoint, relPoint, xOffset, yOffset)
	local sectionInfo = SET_SECTIONS[sectionId]

	local buildSectionLabelCtrl = WM:CreateControlFromVirtual("$(parent)_"..sectionInfo[2], parent, 'STL_SectionLabelTemplate')
	buildSectionLabelCtrl:SetAnchor(anchorPoint, previousCtrl, relPoint, xOffset, yOffset)

	buildSectionLabelCtrl:GetNamedChild("Label"):SetText(sectionInfo[1])
	buildSectionLabelCtrl:GetNamedChild("Label"):SetHorizontalAlignment(TEXT_ALIGN_LEFT)

	return buildSectionLabelCtrl
end


function STLUI.HideDetails()
	for _, ctrl in pairs(STLUI.detailControls) do
		ctrl:SetHidden(true)
	end
end

function STLUI.ShowEditorTooltip(control, msg) 
	InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -5)
	SetTooltipText(InformationTooltip, msg)
end

function STLUI.HideEditorTooltip() 
	ClearTooltip(InformationTooltip)	
end



function STLUI.ListColls()
	
	for categoryIndex=1, GetNumCollectibleCategories() do

		local name, numSubCatgories, numCollectibles, unlockedCollectibles = GetCollectibleCategoryInfo(categoryIndex)

		if numSubCatgories > 0 then
			for subCategoryIndex=1, numSubCatgories do
			
				local subCategoryName, subCategoryNumCollectibles, subCategoryUnlockedCollectibles = GetCollectibleSubCategoryInfo(categoryIndex, subCategoryIndex)

				local catId = GetCollectibleCategoryId(categoryIndex, subCategoryIndex)

				d("Cat: "..name.."/"..subCategoryName.." CatIndex: "..categoryIndex.."/"..subCategoryIndex.." CatId: "..catId)
		
				--[[
				for collectibleIndex=1, subCategoryNumCollectibles do
				
					local collectibleId = GetCollectibleId(categoryIndex, subCategoryIndex, collectibleIndex)
					local collectibleName, _, _, _, unlocked, _, _, categoryType = GetCollectibleInfo(collectibleId)

					d("Cat: "..name.." SC: "..subCategoryName.." Col: "..collectibleName)
				end
			--]]
			end
		else
			local catId = GetCollectibleCategoryId(categoryIndex, nil)
			d("Cat: "..name.." CatIndex: "..categoryIndex.." CatId: "..catId)
		end
	end
				
end


function STLUI.ShowTooltip(parent)
	-- Weapon cells carry a StyleWeaponSlot instead of a category type
	local weaponSlot = parent["StyleWeaponSlot"]
	if weaponSlot then
		local style = STLModel.GetStyleById(STLUI.GetCurrentStyleSetId())
		if not style then return end

		ClearTooltip(ItemTooltip)
		local offsetX = parent:GetParent():GetLeft() - parent:GetLeft() - 5
		InitializeTooltip(ItemTooltip, parent, RIGHT, offsetX, 0, LEFT)

		local weapon = style.Weapons and style.Weapons[weaponSlot]
		if weapon and weapon.id ~= 0 then
			ItemTooltip:SetLink(weapon.link)
		elseif weapon and weapon.id == 0 then
			SetTooltipText(ItemTooltip, MSG.WEAPON_UNEQUIP or "Empty slot (will unequip)")
		else
			SetTooltipText(ItemTooltip, MSG.WEAPON_NONE or "Weapons not saved for this style")
		end
		return
	end

	local catType = parent["StyleCategoryType"]

	if not catType then return end

	local currentId = STLUI.GetCurrentStyleSetId()
	local style = STLModel.GetStyleById(currentId)

	if not style then return end

	ClearTooltip(ItemTooltip)
	local offsetX = parent:GetParent():GetLeft() - parent:GetLeft() - 5
	InitializeTooltip(ItemTooltip, parent, RIGHT, offsetX, 0, LEFT)

	if catType == DUMMY_CATEGORY_COSTUME then
		local costume = style.Costume
		if costume and costume.id ~= 0 then
			local SHOW_NICKNAME, SHOW_PURCHASABLE_HINT, SHOW_BLOCK_REASON = true, true, true
			ItemTooltip:SetLink(costume.link)
		else 
			SetTooltipText(ItemTooltip, MSG.GEAR_APPEARANCE)
		end
	else
		local colId = style.Collectibles[catType]

		if colId and colId ~= 0 then
			local SHOW_NICKNAME, SHOW_PURCHASABLE_HINT, SHOW_BLOCK_REASON = true, true, true
			ItemTooltip:SetCollectible(colId, SHOW_NICKNAME, SHOW_PURCHASABLE_HINT, SHOW_BLOCK_REASON)
		else
			local name, texttureName = STLModel.GetCatInfoByCatType(catType)

			SetTooltipText(ItemTooltip, name)
		end
	end
end

function STLUI.HideTooltip(parent)
	STLUI.HideEditorTooltip() 
	ClearTooltip(ItemTooltip)
end

--[[
function STLUI.HandleNameChanged(editCtrl)
	local currentId = STLUI.GetCurrentStyleSetId()
	local style = STLModel.GetStyleById(currentId)

	if not style then return end

	-- update model
	style.Name = editCtrl:GetText()

	-- update UI
	local listControl = WM:GetControlByName('STL_MainListDetailListContainerList')
	local ctrl = ZO_ScrollList_GetSelectedControl(listControl)

	local nameControl = GetControl(ctrl, "Name")
	nameControl:SetText(style.Name)
end
--]]


--- Drag a weapon from the inventory (or equipped) onto a weapon cell to assign it.
function STLUI.OnWeaponSlotReceiveDrag(self)
	local slot = self["StyleWeaponSlot"]
	if not slot then return end

	local cursorType = GetCursorContentType()
	if cursorType ~= MOUSE_CONTENT_INVENTORY_ITEM and cursorType ~= MOUSE_CONTENT_EQUIPPED_ITEM then
		return
	end

	local bagId = GetCursorBagId()
	local slotIndex = GetCursorSlotIndex()
	ClearCursor()

	if not bagId or not slotIndex then return end

	if GetItemType(bagId, slotIndex) ~= ITEMTYPE_WEAPON then
		d(MSG.MSG_WEAPON_ONLY)
		return
	end

	local style = STLModel.GetStyleById(STLUI.GetCurrentStyleSetId())
	if not style then return end

	local newId = Id64ToString(GetItemUniqueId(bagId, slotIndex))

	-- a physical weapon can only be equipped in one slot -> reject duplicates
	if style.Weapons then
		for s, w in pairs(style.Weapons) do
			if s ~= slot and w and w.id == newId then
				d(MSG.MSG_WEAPON_DUP)
				return
			end
		end
	end

	style.Weapons = style.Weapons or {}
	style.Weapons[slot] = { id = newId, link = GetItemLink(bagId, slotIndex) }

	STLUI.UpdateStyleSetDetails()
end

--- Right-click a weapon cell to cycle its state:
---   assigned weapon -> empty (unequip) -> keep (don't touch) -> empty -> ...
--- Drag a weapon onto the cell to (re)assign it.
function STLUI.CycleWeaponSlot(self)
	local slot = self["StyleWeaponSlot"]
	if not slot then return end

	local style = STLModel.GetStyleById(STLUI.GetCurrentStyleSetId())
	if not style then return end

	style.Weapons = style.Weapons or {}
	local cur = style.Weapons[slot]

	if cur == nil then
		-- keep (don't touch) -> empty (unequip)
		style.Weapons[slot] = { id = 0, link = 0 }
	elseif cur.id == 0 then
		-- empty (unequip) -> keep (don't touch)
		style.Weapons[slot] = nil
	else
		-- assigned weapon -> empty (unequip)
		style.Weapons[slot] = { id = 0, link = 0 }
	end

	STLUI.UpdateStyleSetDetails()
end

function STLUI.OnWeaponSlotMouseUp(self, button, upInside)
	if not upInside then return end
	if button == MOUSE_BUTTON_INDEX_RIGHT then
		STLUI.CycleWeaponSlot(self)
	else
		STLUI.OnWeaponSlotReceiveDrag(self)
	end
end

--- Creates one weapon icon control in the detail panel (mirrors the collectible items).
local function CreateWeaponItemCtrl(slot, previousCtrl, anchorPoint, relPoint, xOffset, yOffset)
	local ctrl = WM:CreateControlFromVirtual("STL_StyleSetWeapon_"..slot, STLUI.detailControls.styleSetDetailsControl, 'STL_SetItemTemplate')
	ctrl:SetAnchor(anchorPoint, previousCtrl, relPoint, xOffset, yOffset)

	local itemCtrl = ctrl:GetNamedChild('Icon')
	itemCtrl:SetHandler('OnMouseEnter', function(self) STLUI.ShowTooltip(self) end)
	itemCtrl:SetHandler('OnMouseExit', function(self) STLUI.HideTooltip(self) end)
	itemCtrl:SetHandler('OnReceiveDrag', function(self) STLUI.OnWeaponSlotReceiveDrag(self) end)
	itemCtrl:SetHandler('OnMouseUp', function(self, button, upInside) STLUI.OnWeaponSlotMouseUp(self, button, upInside) end)
	itemCtrl["StyleWeaponSlot"] = slot

	return ctrl
end

function STLUI.InitStyleSetDetails()
	STLUI.detailControls.styleSetDetailsControl = WM:GetControlByName('STL_MainContent')
	STLUI.detailControls.styleSetDetailsControl:SetHidden(true)

	local function CreateStyleItemCtrl (catType, previousCtrl, anchorPoint, relPoint, xOffset, yOffset)
		local styleSetItemCtrl = WM:CreateControlFromVirtual("STL_StyleSetItem_"..catType, STLUI.detailControls.styleSetDetailsControl, 'STL_SetItemTemplate')
		styleSetItemCtrl:SetAnchor(anchorPoint, previousCtrl, relPoint, xOffset, yOffset)
		local itemCtrl = styleSetItemCtrl:GetNamedChild('Icon')

		-- tooltip
		itemCtrl:SetHandler('OnMouseEnter',function(self) STLUI.ShowTooltip(self) end)
		itemCtrl:SetHandler('OnMouseExit',function(self) STLUI.HideTooltip(self) end)
		itemCtrl["StyleCategoryType"] = catType
	
		return styleSetItemCtrl
	end

	local firstRowOffset = 40
	local rowOffset = 12
	local colSpacing = 12


	-- (Outfit + Title are now ZO_ComboBox dropdowns defined in XML on the action row.)

	-- Collectibles (grid now starts at the top of the content area)
	local categories = STLModel.GetCategories()

	local counter = 1
	local prevControl = CreateStyleItemCtrl(categories[1], STLUI.detailControls.styleSetDetailsControl, TOPLEFT, TOPLEFT, 5, 12)
	local firstOfRow = prevControl

	for categoryIndex = 2, #categories do
		if counter % 7 > 0 then
			prevControl = CreateStyleItemCtrl(categories[categoryIndex], prevControl, TOPLEFT, TOPRIGHT, colSpacing, 0)
		else
			prevControl = CreateStyleItemCtrl(categories[categoryIndex], firstOfRow, TOPLEFT, BOTTOMLEFT, 0, rowOffset)
			firstOfRow = prevControl
		end
		counter = counter + 1
	end

	-- Costume (Gear)
	if counter % 7 > 0 then
		CreateStyleItemCtrl(DUMMY_CATEGORY_COSTUME, prevControl, TOPLEFT, TOPRIGHT, colSpacing, 0)
	else
		CreateStyleItemCtrl(DUMMY_CATEGORY_COSTUME, firstOfRow, TOPLEFT, BOTTOMLEFT, 0, rowOffset)
	end

	-- separator above the weapons section
	local weaponsDivider = WM:CreateControl("STL_StyleWeaponsDivider", STLUI.detailControls.styleSetDetailsControl, CT_TEXTURE)
	weaponsDivider:SetTexture("EsoUI/Art/Miscellaneous/centerscreen_topDivider.dds")
	weaponsDivider:SetAnchor(TOPLEFT, firstOfRow, BOTTOMLEFT, 0, 26)
	weaponsDivider:SetDimensions(630, 4)

	-- Weapons section, placed under the separator
	local weaponsLabel = WM:CreateControlFromVirtual("STL_StyleSetWeaponsLabel", STLUI.detailControls.styleSetDetailsControl, 'STL_SetLabelTemplate')
	weaponsLabel:SetAnchor(TOPLEFT, weaponsDivider, BOTTOMLEFT, 0, 6)
	weaponsLabel:SetAnchor(BOTTOMRIGHT, weaponsDivider, BOTTOMLEFT, 300, 6 + 28)
	local wLabel = weaponsLabel:GetNamedChild("Label")
	wLabel:SetText(MSG.WEAPONS or "Weapons")
	wLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

	-- small bold "1" / "2" separators marking front bar vs back bar
	local function CreateBarLabel(text, prev, point, relPoint, xOff, yOff)
		local lbl = WM:CreateControl("STL_WeaponBarLabel_"..text, STLUI.detailControls.styleSetDetailsControl, CT_LABEL)
		lbl:SetFont("STLFontBold")
		lbl:SetText(text)
		lbl:SetColor(0.99, 0.67, 0.2, 1)
		lbl:SetDimensions(16, 80)
		lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		lbl:SetAnchor(point, prev, relPoint, xOff, yOff)
		return lbl
	end

	-- front bar: [1] main + off
	local bar1 = CreateBarLabel("1", weaponsLabel, TOPLEFT, BOTTOMLEFT, 0, rowOffset)
	local w1 = CreateWeaponItemCtrl(WEAPON_DISPLAY_SLOTS[1], bar1, LEFT, RIGHT, 4, 0)
	local w2 = CreateWeaponItemCtrl(WEAPON_DISPLAY_SLOTS[2], w1, LEFT, RIGHT, colSpacing, 0)
	-- back bar: [2] backup main + backup off
	local bar2 = CreateBarLabel("2", w2, LEFT, RIGHT, 14, 0)
	local w3 = CreateWeaponItemCtrl(WEAPON_DISPLAY_SLOTS[3], bar2, LEFT, RIGHT, 4, 0)
	local w4 = CreateWeaponItemCtrl(WEAPON_DISPLAY_SLOTS[4], w3, LEFT, RIGHT, colSpacing, 0)

		-- Companion (summoned on apply), in the free space to the right of the weapons
		local compParent = STLUI.detailControls.styleSetDetailsControl
		local compSep = WM:CreateControl("STL_CompanionSep", compParent, CT_BACKDROP)
		compSep:SetDimensions(2, 76)
		compSep:SetCenterColor(0.45, 0.45, 0.45, 0.7)
		compSep:SetEdgeColor(0, 0, 0, 0)
		compSep:SetAnchor(LEFT, w4, RIGHT, 24, 0)

		local compLabel = WM:CreateControl("STL_StyleCompanionLabel", compParent, CT_LABEL)
		compLabel:SetFont("STLFont")
		compLabel:SetText(MSG.COMPANION or "Companion")
		compLabel:SetColor(1, 1, 1, 1)
		compLabel:SetAnchor(TOPLEFT, compSep, TOPRIGHT, 14, 2)

		local compCombo = WM:CreateControlFromVirtual("STL_StyleCompanionCombo", compParent, "ZO_ComboBox")
		compCombo:SetDimensions(140, 28)
		compCombo:SetAnchor(TOPLEFT, compLabel, BOTTOMLEFT, 0, 4)

		local compPreview = WM:CreateControl("STL_StyleCompanionPreview", compParent, CT_TEXTURE)
		compPreview:SetDimensions(28, 28)
		compPreview:SetAnchor(LEFT, compCombo, RIGHT, 6, 0)
end



function STLUI.UpdateStyleSetDetails()
	trace("UpdateStyleSetDetails")

	local function UpdateControl(ctrl, texttureName, centerColor, edgeColor)
		local itemCtrl = ctrl:GetNamedChild('Icon')
		local bgCtrl = ctrl:GetNamedChild('BG')
		ctrl:SetHidden(false)
		itemCtrl:SetNormalTexture(texttureName)
		bgCtrl:SetCenterColor(centerColor:UnpackRGBA())
		bgCtrl:SetEdgeColor(edgeColor:UnpackRGBA())
	end


	local currentId = STLUI.GetCurrentStyleSetId()
	local style = STLModel.GetStyleById(currentId)

	if not style then return end

	-- (Outfit + Title are reflected in their dropdowns via RefreshOutfit/TitleSelection.)

	-- Update Collectibles
	local categories = STLModel.GetCategories()

	local texttureName
	local centerColor = STYLE_BG_COLOR
	local edgeColor = STYLE_BORDER_COLOR

	for categoryIndex = 1, #categories do
		local colId = style.Collectibles[categories[categoryIndex]]

		local styleSetItemCtrl = WM:GetControlByName("STL_StyleSetItem_"..categories[categoryIndex])

		if colId and colId ~= 0 then
			local name, description, icon, deprecatedLockedIcon, unlocked, purchasable, isActive, categoryType = GetCollectibleInfo(colId)
			texttureName = icon
		else
			local _
			_, texttureName = STLModel.GetCatInfoByCatType(categories[categoryIndex])

			if texttureName == "" then
				texttureName = "esoui/art/buttons/decline_up.dds"
			end
		end

		UpdateControl (styleSetItemCtrl, texttureName, centerColor, edgeColor)
	end
	
	-- costume (gear)
	texttureName = "/esoui/art/restyle/gamepad/gp_dyes_tabicon_outfitstyledye.dds"

	local styleSetItemCtrl = WM:GetControlByName("STL_StyleSetItem_"..DUMMY_CATEGORY_COSTUME)

	local costume = style.Costume
	if costume and costume.id ~= 0 then
		texttureName = GetItemLinkIcon(costume.link)
	end

	UpdateControl (styleSetItemCtrl, texttureName, centerColor, edgeColor)

	-- weapons (front + back bar)
	for i = 1, #WEAPON_DISPLAY_SLOTS do
		local slot = WEAPON_DISPLAY_SLOTS[i]
		local weaponCtrl = WM:GetControlByName("STL_StyleSetWeapon_"..slot)

		local weapon = style.Weapons and style.Weapons[slot]
		local tex
		local iconSize = 76               -- full size for real weapon icons
		if weapon == nil then
			tex = TEX_WEAPON_NONE          -- keep / don't touch this slot
			iconSize = 44                  -- small UI symbol -> shrink so it doesn't pixelate
		elseif weapon.id == 0 then
			tex = TEX_WEAPON_UNEQUIP       -- saved empty: will unequip on load
			iconSize = 44
		else
			tex = GetItemLinkIcon(weapon.link)
		end

		UpdateControl (weaponCtrl, tex, centerColor, edgeColor)
		local iconChild = weaponCtrl and weaponCtrl:GetNamedChild('Icon')
		if iconChild then iconChild:SetDimensions(iconSize, iconSize) end
	end
end

function STLUI.OnListAdd()
	trace('OnListAdd')
	local newId = STLModel.NewStyle()
	STLUI.SetCurrentStyleSetId(newId)
	STLUI.ShowStyleSetsTab()
	local style = STLModel.GetStyleById(newId)
	if style then d(zo_strformat(MSG.MSG_CREATED, style.Name)) end
end

function STLUI.OnListDelete()
	trace('OnListDelete')
	local id = STLUI.GetCurrentStyleSetId()
	local style = id and STLModel.GetStyleById(id)
	if not style then return end
	ZO_Dialogs_ShowDialog("STL_CONFIRM_DELETE", { styleId = id }, { mainTextParams = { style.Name } })
end

function STLUI.OnReloadStyle()
	trace('OnReloadStyle')
	local id = STLUI.GetCurrentStyleSetId()
	local style = id and STLModel.GetStyleById(id)
	if not style then return end
	ZO_Dialogs_ShowDialog("STL_CONFIRM_UPDATE", { styleId = id }, { mainTextParams = { style.Name } })
end

-- Registers the confirmation dialogs for destructive actions (update/delete)
function STLUI.RegisterDialogs()
	ZO_Dialogs_RegisterCustomDialog("STL_CONFIRM_UPDATE", {
		title = { text = MSG.CONFIRM_UPDATE_TITLE or "Update style" },
		mainText = { text = MSG.CONFIRM_UPDATE_TEXT or "Overwrite \"<<1>>\" with your current appearance?" },
		buttons = {
			{
				text = SI_DIALOG_CONFIRM,
				callback = function(dialog)
					STLModel.ReloadStyle(dialog.data.styleId)
					STLUI.ShowStyleSetsTab()
				end,
			},
			{ text = SI_DIALOG_CANCEL },
		},
	})

	ZO_Dialogs_RegisterCustomDialog("STL_CONFIRM_DELETE", {
		title = { text = MSG.CONFIRM_DELETE_TITLE or "Delete style" },
		mainText = { text = MSG.CONFIRM_DELETE_TEXT or "Delete the style \"<<1>>\"?" },
		buttons = {
			{
				text = SI_DIALOG_CONFIRM,
				callback = function(dialog)
					STLModel.DeleteStyle(dialog.data.styleId)
					STLUI.ShowStyleSetsTab()
				end,
			},
			{ text = SI_DIALOG_CANCEL },
		},
	})
end

function STLUI.OnEditStyleProperties()
	trace('OnEditStyleProperties')
	local currentId = STLUI.GetCurrentStyleSetId()
	if not currentId then
		return
	end

	ZO_Dialogs_ShowDialog("STL_EDIT_STYLE_PROPERTIES_DIALOG", {})
end

function STLUI.OnUseStyle()
	trace('OnUseStyle')
	STLModel.LoadStyleById(STLUI.GetCurrentStyleSetId())
	STLUI.PopulateQuickBarCombo()  -- reflect the applied style in the floating switcher
end

-- Options panel ------------------------------------------------------------

function STLUI.ToggleOptions()
	local panel = WM:GetControlByName('STL_Options')
	if not panel then return end
	local show = panel:IsHidden()
	panel:SetHidden(not show)
	if show then
		panel:BringWindowToTop()
		STLUI.RefreshOptions()
	end
end

function STLUI.RefreshOptions()
	local s = STLModel.Settings
	local function setState(name, val)
		local c = WM:GetControlByName(name)
		if not c then return end
		if val then ZO_CheckButton_SetChecked(c) else ZO_CheckButton_SetUnchecked(c) end
	end
	setState('STL_OptionsShowButtonCheck', s.ShowQuickBar ~= false)
	setState('STL_OptionsShowDropdownCheck', s.ShowQuickDropdown ~= false)
	setState('STL_OptionsLockButtonCheck', s.LockQuickBar == true)
	setState('STL_OptionsPlayMementosCheck', s.PlayEntranceMementos ~= false)
	setState('STL_OptionsCloseCombatCheck', s.CloseOnCombat == true)
end

function STLUI.InitOptions()
	local function setup(name, label, onToggle)
		local c = WM:GetControlByName(name)
		if not c then return end
		ZO_CheckButton_SetLabelText(c, label)
		ZO_CheckButton_SetToggleFunction(c, function(_, checked) onToggle(checked) end)
	end

	setup('STL_OptionsShowButtonCheck', MSG.OPT_SHOW_BUTTON or "Show floating button",
		function(v) STLModel.Settings.ShowQuickBar = v; STLUI.ApplyQuickBarSettings() end)
	setup('STL_OptionsShowDropdownCheck', MSG.OPT_SHOW_DROPDOWN or "Show quick-switch dropdown",
		function(v) STLModel.Settings.ShowQuickDropdown = v; STLUI.ApplyQuickBarSettings() end)
	setup('STL_OptionsLockButtonCheck', MSG.OPT_LOCK_BUTTON or "Lock the floating button position",
		function(v) STLModel.Settings.LockQuickBar = v; STLUI.ApplyQuickBarSettings() end)
	setup('STL_OptionsPlayMementosCheck', MSG.OPT_PLAY_MEMENTOS or "Play entrance mementos when applying a style",
		function(v) STLModel.Settings.PlayEntranceMementos = v end)
	setup('STL_OptionsCloseCombatCheck', MSG.OPT_CLOSE_COMBAT or "Close the window when entering combat",
		function(v) STLModel.Settings.CloseOnCombat = v end)

	local help = WM:GetControlByName('STL_OptionsHelp')
	if help then
		help:SetVerticalAlignment(TEXT_ALIGN_TOP)
		help:SetText(MSG.OPT_HELP or (
			"|cFFAA33How to build a style|r\n"..
			"- Set your look in-game, then press the Update button to capture it.\n"..
			"- Or drag a weapon from your inventory onto a weapon slot.\n"..
			"- Right-click a weapon slot to leave it empty (it will be unequipped).\n"..
			"- Pick an Outfit, a Title and an entrance Memento from the dropdowns.\n\n"..
			"|cFFAA33Entrance memento|r\n"..
			"When you apply a style, its memento plays to mask the change - your new look is revealed as the animation ends. If the memento is still on cooldown, the style won't switch (so the reveal always happens)."
		))
	end
end

-- localizes the hardcoded XML labels (called once after all controls exist)
function STLUI.LocalizeUI()
	local function setText(name, text)
		local c = WM:GetControlByName(name)
		if c then c:SetText(text) end
	end
	setText('STL_MainStyleBarLabel', MSG.STYLE)
	setText('STL_MainActionsOutfitLabel', MSG.OUTFIT)
	setText('STL_MainActionsTitleLabel', MSG.TITLE)
	setText('STL_MainApplyBandHotkeyLabel', MSG.HOTKEY)
	setText('STL_MainApplyBandMementoLabel', MSG.MEMENTO)
	setText('STL_MainApplyBandRevealLabel', MSG.REVEAL)
	setText('STL_MainApplyBandTitle', "|cFFAA33"..(MSG.APPLY_SECTION or "ON APPLY").."|r")
	setText('STL_OptionsTitle', MSG.OPTIONS)
end

function STLUI.OnInitMain()
    trace('OnInitMain')
    SM:RegisterTopLevel(STL_Main, true)

	STLUI.InitStyleSetDetails()
	STLUI.RegisterDialogs()
	-- zo_callLater(STLUI.ShowStyleSetsTab, 1000)
	-- zo_callLater(STLUI.ListColls, 1000)
end

function STLUI.OnHighlightItem (control, isHighlighted)
	-- trace('OnHighlightItem!')
end

function STLUI.SimpleRow_OnMouseEnter(rowControl)
	-- list:EnterRow(rowControl)
	--d("Item MouseEnter")
	local listControl = WM:GetControlByName('STL_MainListDetailListContainerList')
	ZO_ScrollList_MouseEnter(listControl, rowControl)
end

function STLUI.SimpleRow_OnMouseExit(rowControl)
	-- list:ExitRow(rowControl)
	--d("Item MouseExit")
	local listControl = WM:GetControlByName('STL_MainListDetailListContainerList')
	ZO_ScrollList_MouseExit(listControl, rowControl)
end

function STLUI.SimpleRow_OnMouseUp(rowControl, button, upInside)
	--local data = ZO_ScrollList_GetData(rowControl)
	--d("Item selected: "..data.name)
	if upInside then
		local listControl = WM:GetControlByName('STL_MainListDetailListContainerList')
		ZO_ScrollList_MouseClick(listControl, rowControl)
	end
end


function STLUI.OnSelectItem (previouslySelectedData, selectedData, reselectingDuringRebuild)

	if selectedData then
		trace("Item selected: "..selectedData.name)

		STLUI.SetCurrentStyleSetId(selectedData.id)
		STLUI.UpdateStyleSetDetails()
		--STLModel.LoadStyleById(selectedData.id)
	end
end


function STLUI.IsDataEqual(data1, data2)
	return data1.id == data2.id
end


function STLUI.FillMainList(dataType, setData) 

	local function SetupSimpleRow(control, data)
		local nameControl = GetControl(control, "Name")
		nameControl:SetText(data.name)
	end

	local listControl = WM:GetControlByName('STL_MainListDetailListContainerList')

	ZO_ScrollList_AddDataType(listControl, dataType, "STL_SimpleRow", 30, SetupSimpleRow)
	ZO_ScrollList_EnableHighlight(listControl, "ZO_ThinListHighlight", STLUI.OnHighlightItem)
	ZO_ScrollList_EnableSelection(listControl, "ZO_ThinListHighlight", STLUI.OnSelectItem)
	ZO_ScrollList_SetEqualityFunction(listControl, dataType, STLUI.IsDataEqual)

	local scrollData = ZO_ScrollList_GetDataList(listControl)
	-- scrollData:SetAlternateRowBackgrounds(true)

	ZO_ScrollList_Clear(listControl)
	
	local selectedData = {}
	local currentId = STLUI.GetCurrentStyleSetId()

	for i = 1, #setData do
		local data = setData[i]
		scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(dataType, data)

		if data.id == currentId or i == 1 then 
			selectedData = data
		end
	end

	STLUI.SetCurrentStyleSetId(selectedData.id)

	ZO_ScrollList_Commit(listControl)	
	ZO_ScrollList_SelectData(listControl, selectedData)
end



-- Style dropdown -----------------------------------------------------------

function STLUI.PopulateStyleCombo()
	local comboCtrl = WM:GetControlByName('STL_MainStyleBarCombo')
	if not comboCtrl then return end
	local combo = ZO_ComboBox_ObjectFromContainer(comboCtrl)
	combo:SetSortsItems(false)
	combo:ClearItems()

	local styles = STLModel.GetStylesSorted()
	local currentId = STLUI.GetCurrentStyleSetId()
	local selectedIndex = 1

	for i = 1, #styles do
		local s = styles[i]
		local entry = combo:CreateItemEntry(STLUI.StyleDisplayName(s.id, s.name), function() STLUI.OnStyleComboSelect(s.id) end)
		entry.styleId = s.id
		combo:AddItem(entry)
		if s.id == currentId then selectedIndex = i end
	end

	if #styles > 0 then
		combo:SelectItemByIndex(selectedIndex)   -- fires OnStyleComboSelect -> refreshes details
	end
end

function STLUI.OnStyleComboSelect(id)
	STLUI.SetCurrentStyleSetId(id)
	STLUI.UpdateStyleSetDetails()
	STLUI.RefreshOutfitSelection()
	STLUI.RefreshTitleSelection()
	STLUI.PopulateHotkeyCombo()      -- rebuild "taken" greying for the newly selected style
	STLUI.RefreshHotkeySelection()
	STLUI.RefreshMementoSelection()
	STLUI.RefreshRevealSelection()
	STLUI.RefreshCompanionSelection()
end

-- Hotkey slot --------------------------------------------------------------

-- (kept as a hook; the assigned slot is no longer shown in the dropdowns)
function STLUI.StyleDisplayName(id, name)
	return name
end

-- applies the style bound to hotkey slot n (called from Bindings.xml)
function STLUI.ApplySlot(n)
	for id, style in pairs(STLModel.StyleData.Styles) do
		if style.Hotkey == n then
			STLModel.LoadStyleById(id)
			STLUI.PopulateQuickBarCombo()
			return
		end
	end
	d(zo_strformat(MSG.MSG_NO_STYLE_SLOT, n))
end

function STLUI.PopulateHotkeyCombo()
	local ctrl = WM:GetControlByName('STL_MainApplyBandHotkeyCombo')
	if not ctrl then return end
	local combo = ZO_ComboBox_ObjectFromContainer(ctrl)
	if not combo then return end
	combo:SetSortsItems(false)
	combo:ClearItems()

	STLUI.hotkeyEntries = {}
	local noneEntry = combo:CreateItemEntry(MSG.HOTKEY_NONE or "- None -", function() STLUI.OnHotkeySelect(0) end)
	combo:AddItem(noneEntry)
	STLUI.hotkeyEntries[1] = 0

	-- which slots are already taken by OTHER styles (to grey them out)
	local currentId = STLUI.GetCurrentStyleSetId()
	local taken = {}
	for sid, s in pairs(STLModel.StyleData.Styles) do
		if sid ~= currentId and s.Hotkey then
			taken[s.Hotkey] = s.Name
		end
	end

	for n = 1, 15 do
		local label = (MSG.SLOT or "Slot").." "..n
		if taken[n] then
			label = "|c888888"..label.." ("..taken[n]..")|r"   -- greyed: already used
		end
		local entry = combo:CreateItemEntry(label, function() STLUI.OnHotkeySelect(n) end)
		combo:AddItem(entry)
		STLUI.hotkeyEntries[n + 1] = n
	end
end

function STLUI.OnHotkeySelect(n)
	if STLUI.suppressHotkeyCallback then return end
	local id = STLUI.GetCurrentStyleSetId()
	local style = STLModel.GetStyleById(id)
	if not style then return end

	if n == 0 then
		style.Hotkey = nil
	else
		-- one slot per style: clear it from whichever style had it before
		for sid, s in pairs(STLModel.StyleData.Styles) do
			if sid ~= id and s.Hotkey == n then s.Hotkey = nil end
		end
		style.Hotkey = n
	end

	STLUI.PopulateHotkeyCombo()     -- refresh the "taken" markers
	STLUI.RefreshHotkeySelection()  -- keep this style's slot selected
end

function STLUI.RefreshHotkeySelection()
	local ctrl = WM:GetControlByName('STL_MainApplyBandHotkeyCombo')
	if not ctrl or not STLUI.hotkeyEntries then return end
	local combo = ZO_ComboBox_ObjectFromContainer(ctrl)
	if not combo then return end

	local style = STLModel.GetStyleById(STLUI.GetCurrentStyleSetId())
	local wanted = (style and style.Hotkey) or 0
	local index = 1
	for i, n in ipairs(STLUI.hotkeyEntries) do
		if n == wanted then index = i break end
	end
	STLUI.suppressHotkeyCallback = true
	combo:SelectItemByIndex(index)
	STLUI.suppressHotkeyCallback = false
end

-- Outfit dropdown ----------------------------------------------------------

function STLUI.PopulateOutfitCombo()
	local ctrl = WM:GetControlByName('STL_MainActionsOutfitCombo')
	if not ctrl then return end
	local combo = ZO_ComboBox_ObjectFromContainer(ctrl)
	if not combo then return end
	combo:SetSortsItems(false)
	combo:ClearItems()

	STLUI.outfitEntries = {}   -- combo index -> outfitId (NO_OUTFIT_ID = none)

	local noneEntry = combo:CreateItemEntry(MSG.NO_OUTFIT or "No outfit", function() STLUI.OnOutfitSelect(STLModel.NO_OUTFIT_ID) end)
	combo:AddItem(noneEntry)
	STLUI.outfitEntries[1] = STLModel.NO_OUTFIT_ID

	local n = GetNumUnlockedOutfits(GAMEPLAY_ACTOR_CATEGORY_PLAYER)
	for i = 1, n do
		local manip = OFMGR:GetOutfitManipulator(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i)
		local name = manip and manip:GetOutfitName() or ""
		if name == "" then name = "Outfit "..i end
		local entry = combo:CreateItemEntry(name, function() STLUI.OnOutfitSelect(i) end)
		combo:AddItem(entry)
		STLUI.outfitEntries[i + 1] = i
	end
end

function STLUI.OnOutfitSelect(outfitId)
	if STLUI.suppressOutfitCallback then return end
	local style = STLModel.GetStyleById(STLUI.GetCurrentStyleSetId())
	if not style then return end
	style.OutfitId = outfitId
end

function STLUI.RefreshOutfitSelection()
	local ctrl = WM:GetControlByName('STL_MainActionsOutfitCombo')
	if not ctrl or not STLUI.outfitEntries then return end
	local combo = ZO_ComboBox_ObjectFromContainer(ctrl)
	if not combo then return end

	local style = STLModel.GetStyleById(STLUI.GetCurrentStyleSetId())
	local wanted = (style and style.OutfitId) or STLModel.NO_OUTFIT_ID
	local index = 1
	for i, oid in ipairs(STLUI.outfitEntries) do
		if oid == wanted then index = i break end
	end
	STLUI.suppressOutfitCallback = true
	combo:SelectItemByIndex(index)
	STLUI.suppressOutfitCallback = false
end

-- Title dropdown -----------------------------------------------------------

-- Some localized titles (e.g. the French female form of "Sombre Bourreau") come
-- back from the game as a broken 800+ char string with the title repeated and
-- comma-separated. Displaying it raw blows the dropdown off-screen. Collapse the
-- repetition and hard-cap the length so no pathological title can break the UI.
local function STL_CleanTitle(rawTitle)
	if not rawTitle or rawTitle == "" then return "" end
	local f = zo_strformat("<<1>>", rawTitle) or ""
	-- empty or unsubstituted (e.g. "<<1>>") = invalid/nil title -> drop it
	if f == "" or f:find("<<", 1, true) then return "" end
	if #f > 60 and f:find(", ", 1, true) then
		f = f:match("^(.-), ") or f
	end
	if #f > 50 then f = f:sub(1, 49) .. "…" end
	return f
end

function STLUI.PopulateTitleCombo()
	local ctrl = WM:GetControlByName('STL_MainActionsTitleCombo')
	if not ctrl then return end
	local combo = ZO_ComboBox_ObjectFromContainer(ctrl)
	if not combo then return end
	combo:SetSortsItems(false)
	combo:ClearItems()

	STLUI.titleEntries = {}   -- combo index -> titleId (NO_TITLE_ID = none)

	local noneEntry = combo:CreateItemEntry(MSG.NO_TITLE or "No title", function() STLUI.OnTitleSelect(STLModel.NO_TITLE_ID) end)
	combo:AddItem(noneEntry)
	STLUI.titleEntries[1] = STLModel.NO_TITLE_ID

	-- collect the earned titles, then sort alphabetically (keeping "No title" first)
	local titles = {}
	for i = 1, GetNumTitles() do
		local name = STL_CleanTitle(GetTitle(i))
		if name and name ~= "" then
			titles[#titles + 1] = { id = i, name = name }
		end
	end
	table.sort(titles, function(a, b) return a.name < b.name end)

	for _, t in ipairs(titles) do
		local entry = combo:CreateItemEntry(t.name, function() STLUI.OnTitleSelect(t.id) end)
		combo:AddItem(entry)
		STLUI.titleEntries[#STLUI.titleEntries + 1] = t.id
	end
end

function STLUI.OnTitleSelect(titleId)
	if STLUI.suppressTitleCallback then return end
	local style = STLModel.GetStyleById(STLUI.GetCurrentStyleSetId())
	if not style then return end
	style.TitleId = titleId
	style.IgnoreTitle = false
end

function STLUI.RefreshTitleSelection()
	local ctrl = WM:GetControlByName('STL_MainActionsTitleCombo')
	if not ctrl or not STLUI.titleEntries then return end
	local combo = ZO_ComboBox_ObjectFromContainer(ctrl)
	if not combo then return end

	local style = STLModel.GetStyleById(STLUI.GetCurrentStyleSetId())
	local wanted = (style and style.TitleId) or STLModel.NO_TITLE_ID
	local index = 1
	for i, tid in ipairs(STLUI.titleEntries) do
		if tid == wanted then index = i break end
	end
	STLUI.suppressTitleCallback = true
	combo:SelectItemByIndex(index)
	STLUI.suppressTitleCallback = false
end

-- Memento dropdown ---------------------------------------------------------

function STLUI.PopulateMementoCombo()
	local comboCtrl = WM:GetControlByName('STL_MainApplyBandMementoCombo')
	if not comboCtrl then return end
	local combo = ZO_ComboBox_ObjectFromContainer(comboCtrl)
	combo:SetSortsItems(false)
	combo:ClearItems()

	STLUI.mementoEntries = {}   -- combo index -> collectibleId (0 = none)

	local noneEntry = combo:CreateItemEntry(MSG.MEMENTO_NONE or "- None -", function() STLUI.OnMementoSelect(0) end)
	combo:AddItem(noneEntry)
	STLUI.mementoEntries[1] = 0

	local mementos = STLModel.GetMementosSorted()
	for i = 1, #mementos do
		local m = mementos[i]
		local entry = combo:CreateItemEntry(m.name, function() STLUI.OnMementoSelect(m.id) end)
		combo:AddItem(entry)
		STLUI.mementoEntries[i + 1] = m.id
	end
end

function STLUI.OnMementoSelect(mementoId)
	if STLUI.suppressMementoCallback then return end
	local id = STLUI.GetCurrentStyleSetId()
	if not id then return end
	STLModel.SetStyleMemento(id, mementoId)
	STLUI.UpdateMementoPreview()
end

-- reflects the current style's saved memento in the combo + preview (no callback)
function STLUI.RefreshMementoSelection()
	local comboCtrl = WM:GetControlByName('STL_MainApplyBandMementoCombo')
	if not comboCtrl or not STLUI.mementoEntries then return end
	local combo = ZO_ComboBox_ObjectFromContainer(comboCtrl)

	local style = STLModel.GetStyleById(STLUI.GetCurrentStyleSetId())
	local wanted = (style and style.Memento) or 0

	local index = 1   -- default "None"
	for i, mid in ipairs(STLUI.mementoEntries) do
		if mid == wanted then index = i break end
	end

	STLUI.suppressMementoCallback = true
	combo:SelectItemByIndex(index)
	STLUI.suppressMementoCallback = false

	STLUI.UpdateMementoPreview()
end

function STLUI.UpdateMementoPreview()
	local preview = WM:GetControlByName('STL_MainApplyBandMementoPreview')
	if not preview then return end

	local style = STLModel.GetStyleById(STLUI.GetCurrentStyleSetId())
	local mementoId = style and style.Memento or 0

	if mementoId and mementoId ~= 0 then
		local _, _, icon = GetCollectibleInfo(mementoId)
		preview:SetNormalTexture(icon)
	else
		preview:SetNormalTexture("esoui/art/icons/icon_missing.dds")
	end
end

-- Reveal-delay dropdown (per style) ----------------------------------------

STLUI.revealValues = { 0, 100, 400, 1000, 2000, 3000, 4000, 5000, 6000 }   -- ms options (tune to the memento's length)

function STLUI.PopulateRevealCombo()
	local comboCtrl = WM:GetControlByName('STL_MainApplyBandRevealCombo')
	if not comboCtrl then return end
	local combo = ZO_ComboBox_ObjectFromContainer(comboCtrl)
	if not combo then return end
	combo:SetSortsItems(false)
	combo:ClearItems()
	for _, ms in ipairs(STLUI.revealValues) do
		local entry = combo:CreateItemEntry(tostring(ms).." ms", function() STLUI.OnRevealSelect(ms) end)
		combo:AddItem(entry)
	end
end

function STLUI.OnRevealSelect(ms)
	if STLUI.suppressRevealCallback then return end
	local style = STLModel.GetStyleById(STLUI.GetCurrentStyleSetId())
	if not style then return end
	style.RevealDelay = ms
end

function STLUI.RefreshRevealSelection()
	local comboCtrl = WM:GetControlByName('STL_MainApplyBandRevealCombo')
	if not comboCtrl then return end
	local combo = ZO_ComboBox_ObjectFromContainer(comboCtrl)
	if not combo then return end
	local style = STLModel.GetStyleById(STLUI.GetCurrentStyleSetId())
	local wanted = (style and style.RevealDelay) or STLModel.Settings.RevealDelay or 400
	local index = 3   -- default to 400 ms if the stored value isn't one of the presets
	for i, ms in ipairs(STLUI.revealValues) do
		if ms == wanted then index = i break end
	end
	STLUI.suppressRevealCallback = true
	combo:SelectItemByIndex(index)
	STLUI.suppressRevealCallback = false
end

-- Companion dropdown (per style, summoned on apply) ------------------------

function STLUI.PopulateCompanionCombo()
	local comboCtrl = WM:GetControlByName('STL_StyleCompanionCombo')
	if not comboCtrl then return end
	local combo = ZO_ComboBox_ObjectFromContainer(comboCtrl)
	if not combo then return end
	combo:SetSortsItems(false)
	combo:ClearItems()

	STLUI.companionEntries = {}   -- combo index -> value (KEEP=don't touch, 0=dismiss, id=summon)

	local keepEntry = combo:CreateItemEntry(MSG.COMPANION_KEEP or "- Keep -", function() STLUI.OnCompanionSelect(STLModel.COMPANION_KEEP) end)
	combo:AddItem(keepEntry)
	STLUI.companionEntries[1] = STLModel.COMPANION_KEEP

	local noneEntry = combo:CreateItemEntry(MSG.COMPANION_NONE or "- None -", function() STLUI.OnCompanionSelect(0) end)
	combo:AddItem(noneEntry)
	STLUI.companionEntries[2] = 0

	local companions = STLModel.GetCompanionsSorted()
	for i = 1, #companions do
		local c = companions[i]
		local entry = combo:CreateItemEntry(c.name, function() STLUI.OnCompanionSelect(c.id) end)
		combo:AddItem(entry)
		STLUI.companionEntries[i + 2] = c.id
	end
end

function STLUI.OnCompanionSelect(companionId)
	if STLUI.suppressCompanionCallback then return end
	local id = STLUI.GetCurrentStyleSetId()
	if not id then return end
	STLModel.SetStyleCompanion(id, companionId)
	STLUI.UpdateCompanionPreview()
end

function STLUI.RefreshCompanionSelection()
	local comboCtrl = WM:GetControlByName('STL_StyleCompanionCombo')
	if not comboCtrl or not STLUI.companionEntries then return end
	local combo = ZO_ComboBox_ObjectFromContainer(comboCtrl)
	if not combo then return end

	local style = STLModel.GetStyleById(STLUI.GetCurrentStyleSetId())
	local wanted = (style and style.Companion) or STLModel.COMPANION_KEEP
	local index = 1
	for i, cid in ipairs(STLUI.companionEntries) do
		if cid == wanted then index = i break end
	end
	STLUI.suppressCompanionCallback = true
	combo:SelectItemByIndex(index)
	STLUI.suppressCompanionCallback = false

	STLUI.UpdateCompanionPreview()
end

function STLUI.UpdateCompanionPreview()
	local preview = WM:GetControlByName('STL_StyleCompanionPreview')
	if not preview then return end
	local style = STLModel.GetStyleById(STLUI.GetCurrentStyleSetId())
	local companionId = style and style.Companion or STLModel.COMPANION_KEEP
	if companionId and companionId > 0 then
		local _, _, icon = GetCollectibleInfo(companionId)
		preview:SetTexture(icon)
	elseif companionId == 0 then
		preview:SetTexture("esoui/art/buttons/decline_up.dds")       -- dismiss = X (like weapon "empty")
	else
		preview:SetTexture("esoui/art/miscellaneous/locked_up.dds")  -- keep = lock (like weapon "keep")
	end
end

function STLUI.ShowStyleSetsTab()
	trace('ShowStyleSetsTab')

	STLUI.detailControls.styleSetDetailsControl:SetHidden(false)
	STLUI.PopulateOutfitCombo()    -- outfit slots
	STLUI.PopulateTitleCombo()     -- earned titles
	STLUI.PopulateHotkeyCombo()    -- slot 1-15
	STLUI.PopulateMementoCombo()   -- owned mementos (same for every style)
	STLUI.PopulateRevealCombo()    -- per-style reveal delay (0/100/400/1000 ms)
	STLUI.PopulateCompanionCombo() -- owned companions (same for every style)
	STLUI.PopulateStyleCombo()     -- selects current style -> details + outfit/title/hotkey/memento refresh
	STLUI.PopulateQuickBarCombo()  -- keep the floating quick-switcher in sync
end

-- Floating quick-access bar ------------------------------------------------

function STLUI.OnQuickBarSelect(styleId)
	if STLUI.suppressQuickBarCallback then return end
	STLModel.LoadStyleById(styleId)
end

function STLUI.PopulateQuickBarCombo()
	if not STL_QuickBarCombo then return end
	local combo = ZO_ComboBox_ObjectFromContainer(STL_QuickBarCombo)
	if not combo then return end
	combo:SetSortsItems(false)
	combo:ClearItems()

	local styles = STLModel.GetStylesSorted()
	local wanted = STLModel.Settings.LastAppliedStyle
	local selectedIndex = 1

	for i = 1, #styles do
		local s = styles[i]
		local entry = combo:CreateItemEntry(STLUI.StyleDisplayName(s.id, s.name), function() STLUI.OnQuickBarSelect(s.id) end)
		combo:AddItem(entry)
		if s.id == wanted then selectedIndex = i end
	end

	-- show the last applied style (or the first) without re-applying it
	if #styles > 0 then
		STLUI.suppressQuickBarCallback = true
		combo:SelectItemByIndex(selectedIndex)
		STLUI.suppressQuickBarCallback = false
	end
end

function STLUI.OnQuickBarMoved(bg)
	STLModel.Settings.QuickBarLeft = bg:GetLeft()
	STLModel.Settings.QuickBarTop = bg:GetTop()
end

-- drag-handle hover feedback, only when the bar is unlocked
function STLUI.OnQuickBarEnter()
	if STLModel.Settings.LockQuickBar then return end
	WM:SetMouseCursor(MOUSE_CURSOR_PAN)
	STL_QuickBarBg:SetAlpha(0.5)
end

function STLUI.OnQuickBarExit()
	WM:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
	STL_QuickBarBg:SetAlpha(0)
end

function STLUI.ApplyQuickBarSettings()
	local s = STLModel.Settings
	local showButton = s.ShowQuickBar ~= false
	local showDropdown = s.ShowQuickDropdown ~= false

	-- the icon (with its drag handle) and the dropdown are toggled independently
	STL_QuickBarBg:SetHidden(not showButton)
	STL_QuickBarButton:SetHidden(not showButton)
	STL_QuickBarCombo:SetHidden(not showDropdown)
	STL_QuickBarBg:SetMovable(not s.LockQuickBar)
end

function STLUI.ShowQuickBarMenu()
	local s = STLModel.Settings
	local dropdownShown = (s.ShowQuickDropdown ~= false)

	ClearMenu()
	AddMenuItem(s.LockQuickBar and "Unlock position" or "Lock position", function()
		s.LockQuickBar = not s.LockQuickBar
		STLUI.ApplyQuickBarSettings()
	end)
	AddMenuItem(dropdownShown and "Hide dropdown" or "Show dropdown", function()
		s.ShowQuickDropdown = not dropdownShown
		STLUI.ApplyQuickBarSettings()
	end)
	AddMenuItem("Hide button", function()
		s.ShowQuickBar = false
		STLUI.ApplyQuickBarSettings()
	end)
	AddMenuItem("Open Stylich", function() STLUI.ToggleMain() end)
	ShowMenu(STL_QuickBarButton)
end

function STLUI.OnQuickBarButtonMouseUp(self, button, upInside)
	if not upInside then return end
	if button == MOUSE_BUTTON_INDEX_RIGHT then
		STLUI.ShowQuickBarMenu()
	elseif button == MOUSE_BUTTON_INDEX_LEFT then
		STLUI.ToggleMain()
	end
end

-- polled ~4x/s: greys the icon + shows the remaining seconds while the last
-- fired memento is on cooldown (so you know when you can switch again)
function STLUI.UpdateQuickBarCooldown()
	local cd = STL_QuickBarCooldown
	if not cd or not STL_QuickBarButton then return end

	local memId = STLModel.lastMemento
	local remaining = (memId and memId ~= 0) and (GetCollectibleCooldownAndDuration(memId) or 0) or 0

	if remaining > 0 and not STL_QuickBarButton:IsHidden() then
		cd:SetText(tostring(math.ceil(remaining / 1000)))
		cd:SetHidden(false)
		STL_QuickBarButton:SetAlpha(0.4)
	else
		cd:SetHidden(true)
		STL_QuickBarButton:SetAlpha(1)
		-- cooldown finished: stop polling until the next memento is fired
		EM:UnregisterForUpdate("STL_QuickBarCooldown")
	end
end

-- start the ~4x/s cooldown poll (called when a memento is fired); it self-stops at 0
function STLUI.StartCooldownWatch()
	EM:UnregisterForUpdate("STL_QuickBarCooldown")
	EM:RegisterForUpdate("STL_QuickBarCooldown", 250, STLUI.UpdateQuickBarCooldown)
end

function STLUI.InitQuickBar()
	local s = STLModel.Settings

	-- reparent to the HUD layer in Lua (XML OnInitialized would clobber the combo's own init)
	if STL_QuickBarCombo then STL_QuickBarCombo:SetParent(ZO_MainMenu) end

	if s.QuickBarLeft and s.QuickBarTop then
		STL_QuickBarBg:ClearAnchors()
		STL_QuickBarBg:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, s.QuickBarLeft, s.QuickBarTop)
	end

	-- cooldown indicator overlay (independent control so it isn't dimmed with the icon)
	if not STL_QuickBarCooldown then
		local cd = WM:CreateControl("STL_QuickBarCooldown", GuiRoot, CT_LABEL)
		cd:SetParent(ZO_MainMenu)
		cd:SetAnchor(CENTER, STL_QuickBarButton, CENTER, 0, 0)
		cd:SetFont("STLFontBold")
		cd:SetColor(1, 0.85, 0.3, 1)
		cd:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		cd:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		cd:SetHidden(true)
	end

	STLUI.PopulateQuickBarCombo()
	STLUI.ApplyQuickBarSettings()

	-- close the main window AND the options panel when entering combat (if enabled)
	if not STLUI.hudCallbacksRegistered then
		EM:RegisterForEvent("STL_CombatClose", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
			if inCombat and STLModel.Settings.CloseOnCombat then
				if STL_Main and not STL_Main:IsHidden() then STLUI.HideMain() end
				if STL_Options and not STL_Options:IsHidden() then STL_Options:SetHidden(true) end
			end
		end)

		STLUI.hudCallbacksRegistered = true
	end
end

-- test helper: tune the memento->look reveal delay live, e.g. "/styldelay 800"
function STLUI.SetRevealDelay(arg)
	local n = tonumber(arg)
	if n then
		STLModel.Settings.RevealDelay = n
		d("Stylich: reveal delay = "..n.." ms")
	else
		d("Stylich: reveal delay = "..tostring(STLModel.Settings.RevealDelay).." ms (usage: /styldelay <ms>)")
	end
end

function STLUI.ToggleDebug(extra)
    STLModel.isDebug = not STLModel.isDebug
    if STLModel.isDebug then
        d("Stylich: debug messages ON")
    else
        d("Stylich: debug messages OFF")
    end
end

function STLUI.ToggleMain(extra)
    trace('ToggleMain')
	SM:ToggleTopLevel(STL_Main)
	if not STL_Main:IsHidden() then
		STLUI.ShowStyleSetsTab()
	end
end

function STLUI.HideMain()
	trace('HideMain')
	SM:ToggleTopLevel(STL_Main)
end

function STLUI.StoreStyle(name)
    if not name or name == '' then
        d("Stylich: you must provide a name for the style to store")
        return
    end

	STLModel.StoreStyleByName(name)
	if not STL_Main:IsHidden() then
		STLUI.ShowStyleSetsTab() 
	end
end

function STLUI.LoadStyle(name)
    if not name or name == '' then
        d("Stylich: you must provide a name for the style to load")
        return
    end

    STLModel.LoadStyleByName (name)
end


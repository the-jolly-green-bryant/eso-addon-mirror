--[[

SWAPS by @hulksmashwarrior 

Version: 2.7.4

(updated by Garkin)
(updated by NathanaelTheOne)
(updated by Ayantir)
(updated by dOpiate)
(updated by calia1120)
(fixes added from cutlery and SirTwist from ESOUI forums)

Ayantir: The code is so ugly that you'll maybe want to rewrite the GUI entirely.

To drop : Chain() + all "xml" in this file.

]]--

local WM = GetWindowManager()
local SWAPS = {}

local function loadAbilitySlots(preset)
	for i = 1, 6 do
		SlotSkillAbilityInSlot(SWAPS.preset[preset].slots[i].t, SWAPS.preset[preset].slots[i].l, SWAPS.preset[preset].slots[i].a, i + 2)
	end
end

local function getPresetSlotTexture(preset, slot)
	if SWAPS.preset[preset].slots[slot].t == 0 then
		return ""
	else
		local _, tex = GetSkillAbilityInfo(SWAPS.preset[preset].slots[slot].t, SWAPS.preset[preset].slots[slot].l, SWAPS.preset[preset].slots[slot].a)
		return tex
	end
end

local function openmain(control, preset)
	control:SetHidden(false)
	SWAPS.newPresetConfig.currentPID = preset
	control.currentIconID = 1
	SWAPS.newPresetConfig.icon = SWAPS_iconPak[control.currentIconID]
	control.icon:SetTexture(SWAPS.newPresetConfig.icon)
	if control.type == "rename" then
		for i = 1, #SWAPS_iconPak do
			if SWAPS_iconPak[i] == SWAPS.preset[preset].tex then
				SWAPS.newPresetConfig.icon = SWAPS.preset[preset].tex
				SWAPS.newPresetConfig.currentIconID = i
				control.icon:SetTexture(SWAPS.preset[preset].tex)
			end
		end
	end
	for i = 1, 6 do
		control.slots[i].t = 0
		control.slots[i].l = 0
		control.slots[i].a = 0
	end
	control.editBox:SetText(SWAPS.preset[preset].name)
	for i = 1, 6 do
		control.slots[i]:SetTexture(getPresetSlotTexture(preset, i))
		if control.type == "rename" then
			SWAPS.newPresetConfig.slots[i] = {}
			SWAPS.newPresetConfig.slots[i].t = SWAPS.preset[preset].slots[i].t
			SWAPS.newPresetConfig.slots[i].l = SWAPS.preset[preset].slots[i].l
			SWAPS.newPresetConfig.slots[i].a = SWAPS.preset[preset].slots[i].a
		end
	end
	control.editBox:TakeFocus()
	control:BringWindowToTop()
	ZO_Skills:SetAllowBringToTop(false)
end

local function SetToolTip(control, text)
	control:SetHandler("OnMouseEnter", function(self)
		ZO_Tooltips_ShowTextTooltip(self, TOP, text)
	end)
	control:SetHandler("OnMouseExit", function(self)
		ZO_Tooltips_HideTextTooltip()
	end)
end

local function Chain(obj)
	 local T={}
	 setmetatable(T, {
		  __index = function(self, func)
				if func == "__END" then
					 return obj
				end
				return function(self, ...)
					 assert(obj[func], func .. " missing in object")
					 obj[func](obj, ...)
					 return self
				end
		  end} )
	 return T
end

local function drawPresetRow(number)

	SWAPS.rows = SWAPS.rows or {}
	SWAPS.rows[number] = {}
	
	local row = SWAPS.rows[number]
	local height = 80
	local width = 320
	local offsetY = 60
	local offsetX = 67
	row.frame = Chain(WM:CreateTopLevelWindow("Swaps_UI_Row".. number .. "_Frame" .. SWAPS.containerCount))
			:SetDimensions(width, height)
			:SetAnchor(TOPLEFT, SWAPS.scroll, TOPLEFT, 0, number * height - height)
			:SetParent(SWAPS.scroll)
		.__END
	row.icon = Chain(WM:CreateControl("$(parent)_icon", row.frame, CT_TEXTURE))
			:SetDimensions(80, 80)
			:SetAnchor(TOPLEFT, row.frame, TOPLEFT, 0, 0)
			:SetTexture("/esoui/art/actionbar/magechamber_firespelloverlay_down.dds")
			:SetDrawLayer(1)
		.__END
	row.label = Chain(WM:CreateControl("$(parent)_label", row.frame, CT_BUTTON))
			:SetText("New Preset")
			:SetFont("ZoFontAlert")
			:SetDimensions(300, height)
			:SetAnchor(TOPLEFT, row.frame, TOPLEFT, offsetX, 7)
			:SetDrawLayer(1)
			:SetHorizontalAlignment(0)
			:SetHandler("OnMouseEnter", function()
				row.frame:SetAlpha(1)
				row.bgOn:SetAlpha(1)
				for i = 1, 6 do
					row.icons[i]:SetAlpha(1)
				end
			end)
			:SetHandler("OnMouseExit", function()
				row.frame:SetAlpha(.8)
				row.bgOn:SetAlpha(0)
				for i = 1, 6 do
					row.icons[i]:SetAlpha(iconAlpha)
				end
			end)
			:SetHandler("OnClicked", function() loadAbilitySlots(number) end)
		.__END
	row.bgOn = Chain(WM:CreateControl("$(parent)_bgOn", row.frame, CT_TEXTURE))
			:SetDimensions(width, height + offsetY)
			:SetAnchor(TOPLEFT, row.frame, TOPLEFT, 0, 0)
			:SetAlpha(0)
			:SetTexture("/esoui/art/miscellaneous/listitem_highlight.dds")
			:SetDrawLayer(20)
		.__END
	row.div2 = Chain(WM:CreateControl(row.frame:GetName() .. "_div", SWAPS.scroll, CT_TEXTURE))
			:SetDimensions(width, 3)
			:SetAnchor(TOPLEFT, row.frame, TOPLEFT, 0, u)
			:SetAlpha(0.2)
			:SetTexture("/esoui/art/miscellaneous/horizontaldivider.dds")
			:SetDrawLayer(30)
		.__END
	row.settingsBtn = Chain(WM:CreateControl("$(parent)_settingsBtn", row.frame, CT_BUTTON))
			:SetDimensions(30, 30)
			:SetAnchor(TOPLEFT, row.frame, TOPLEFT, width - 50, 5)
			:SetAlpha(1)
			:SetDrawLayer(1)
			:SetNormalTexture("/esoui/art/menubar/menubar_mainmenu_over.dds")
			:SetHandler("OnClicked", function()
				SWAPS.UI.main.type = "rename"
				openmain(SWAPS.UI.main, number)
			end)
		.__END
	SetToolTip(row.settingsBtn, "Edit Preset")
	row.icons = {}
	for i = 1, 6 do
		local offset = i == 6 and 35 or 33
		row.icons[i] = Chain(WM:CreateControl("$(parent)_icon" .. i, row.frame, CT_TEXTURE))
				:SetDimensions(30, 30)
				:SetAnchor(TOPLEFT, row.frame, TOPLEFT, offsetX + offset * i - offset, 40)
				:SetAlpha(iconAlpha)
				:SetDrawLayer(1)
				:SetTexture(getPresetSlotTexture(number, i))
			.__END
	end
end

local function getNextIcon(control, currentId, iconPak, step)
	local iconId = currentId + step
	if iconId > #iconPak then iconId = 1 end
	if iconId < 1 then iconId = #iconPak end
	control:SetTexture(iconPak[iconId])
	control:SetDimensions(80, 80)
	return iconId
end

local function savePreset()
	local index = SWAPS.newPresetConfig.currentPID
	for slotNum = 3, 8 do
		local i = slotNum - 2
		SWAPS.preset[index].name = SWAPS.UI.main.editBox:GetText()
		SWAPS.preset[index].tex = SWAPS.newPresetConfig.icon
		SWAPS.preset[index].slots[i].name = GetSlotName(slotNum)
		SWAPS.preset[index].slots[i].t = SWAPS.newPresetConfig.slots[i].t
		SWAPS.preset[index].slots[i].l = SWAPS.newPresetConfig.slots[i].l
		SWAPS.preset[index].slots[i].a = SWAPS.newPresetConfig.slots[i].a
	end
end

local function updatePresetName(presetIndex)
	local label = SWAPS.rows[presetIndex].label
	label:SetText(SWAPS.preset[presetIndex].name)
	local tex = SWAPS.rows[presetIndex].icon 
	tex:SetTexture(SWAPS.preset[presetIndex].tex)
	
	for slotIndex = 1, 6 do
		local icon = SWAPS.rows[presetIndex].icons[slotIndex]
		icon:SetTexture(getPresetSlotTexture(presetIndex, slotIndex))
	end
	
end

local function parseHotbar(control)

	local function getTLA(abilityName)
		abilityName = zo_strlower(abilityName)
		 for skillType = 1, GetNumSkillTypes() do
			for skillLineIndex = 1, GetNumSkillLines(skillType) do
				for abilityIndex = 1, GetNumSkillAbilities(skillType, skillLineIndex) do
					local name, _, _, passive = GetSkillAbilityInfo(skillType, skillLineIndex, abilityIndex)
					if not passive then
						name = zo_strlower(name)
					if name == abilityName or name == SWAPS_skillAlias[abilityName] then
						return skillType, skillLineIndex, abilityIndex
					 end
					end
				end
			end
		end
		return 0, 0, 0
	end
	
	for slotNum = 3, 8 do
	
		local index = slotNum - 2
		local skillType, skillLineIndex, abilityIndex = 0, 0, 0
		local tex = GetSlotTexture(slotNum)
		if IsSlotUsed(slotNum) then
			local abilityId = GetSlotBoundId(slotNum)
			--for some reason does not work in all cases, so I will use workaround
			local _, progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
			skillType, skillLineIndex, abilityIndex = GetSkillAbilityIndicesFromProgressionIndex(progressionIndex)
			if skillType == 0 then
				local abilityName = GetSlotName(slotNum)
				skillType, skillLineIndex, abilityIndex = getTLA(abilityName)
			end
		end
		
		SWAPS.newPresetConfig.slots[index] = {}
		SWAPS.newPresetConfig.slots[index].t = skillType
		SWAPS.newPresetConfig.slots[index].l = skillLineIndex
		SWAPS.newPresetConfig.slots[index].a = abilityIndex
		
		control.slots[index]:SetTexture(tex)
		control.slots[index]:SetAlpha(1)
		control.notify:SetAlpha(0)
		
	end
	
end

function SWAPS_MacroButton(preset)
	if preset <= #SWAPS.preset then
		loadAbilitySlots(preset)
	else
		d("Preset ".. preset .." not found")
	end
end

function Swaps_NewPreset_OnMouseEnter()
	InitializeTooltip(InformationTooltip)
	InformationTooltip:AddLine("Create New Preset")
end

function Swaps_NewPreset_OnMouseExit()
	ClearTooltip(InformationTooltip)
end

local function createNewPreset(preset)
	local newId = #SWAPS.preset+1
	SWAPS.preset[newId]={}
	SWAPS.preset[newId].name = "New Preset"
	SWAPS.preset[newId].bindID = 0
	SWAPS.preset[newId].tex=""
	SWAPS.preset[newId].slots={}
	for slot = 1, 6 do
		SWAPS.preset[newId].slots[slot] = {}
		SWAPS.preset[newId].slots[slot].name = ""
		SWAPS.preset[newId].slots[slot].t = 0
		SWAPS.preset[newId].slots[slot].l = 0
		SWAPS.preset[newId].slots[slot].a = 0
	end
	drawPresetRow(newId)
end

function Swaps_NewPreset(control)

	SWAPS.UI.main.type = "new"
	
	createNewPreset()
	
	SWAPS.newPresetConfig.currentPID = #SWAPS.preset
	
	zo_callLater(function() SWAPS.UI.main.icon:SetTexture(SWAPS_iconPak[1]) end, 20)
	
	for i = 1, 6 do
		SWAPS.UI.main.slots[i]:SetAlpha(0)
	end
	
	SWAPS.UI.main.notify:SetAnchor(BOTTOMLEFT, SWAPS.UI.main.slots[1], BOTTOMLEFT, 0, 25)
	SWAPS.UI.main.notify:SetAlpha(1)
	SWAPS.UI.main.notify:SetText("Loading Current Hotbar")
	SWAPS.UI.main.notify:SetDrawLayer(1)
	
	zo_callLater(function() parseHotbar(SWAPS.UI.main, SWAPS.newPresetConfig.currentPID) end, 20)
	openmain(SWAPS.UI.main, #SWAPS.preset)
	
end

local function onLoadAddOn(evt, addonName)
	
	if addonName == "swaps" then
	
		ZO_CreateStringId("SI_BINDING_NAME_SWAPS_BUTTON_1", "Load Preset 1")
		ZO_CreateStringId("SI_BINDING_NAME_SWAPS_BUTTON_2", "Load Preset 2")
		ZO_CreateStringId("SI_BINDING_NAME_SWAPS_BUTTON_3", "Load Preset 3")
		ZO_CreateStringId("SI_BINDING_NAME_SWAPS_BUTTON_4", "Load Preset 4")
		ZO_CreateStringId("SI_BINDING_NAME_SWAPS_BUTTON_5", "Load Preset 5")
		ZO_CreateStringId("SI_BINDING_NAME_SWAPS_BUTTON_6", "Load Preset 6")
		ZO_CreateStringId("SI_BINDING_NAME_SWAPS_BUTTON_7", "Load Preset 7")
		ZO_CreateStringId("SI_BINDING_NAME_SWAPS_BUTTON_8", "Load Preset 8")
		ZO_CreateStringId("SI_BINDING_NAME_SWAPS_BUTTON_9", "Load Preset 9")
		ZO_CreateStringId("SI_BINDING_NAME_SWAPS_BUTTON_10", "Load Preset 10")
	
		SWAPS.containerCount = 1
		SWAPS.newPresetConfig = {}
		SWAPS.newPresetConfig.slots = {}
		SWAPS.newPresetConfig.currentIconID = 0

		local defaults = { preset = {}} 
		local savedVars = ZO_SavedVars:NewCharacterNameSettings("SWAPS_DB", 2, nil, defaults)
		SWAPS.preset = savedVars.preset

		local iconAlpha = 0.2
		SWAPS.UI = GetControl("Swaps")
		SWAPS.UI:SetParent(ZO_Skills)
		
		local bg = Chain(WM:CreateControl("fuzzBG", SWAPS.UI, CT_TEXTURE))
				:SetDimensions(370, 1025)
				:SetAnchor(TOPRIGHT, ZO_Skills, TOPLEFT, -20, -100)
				:SetTexture("EsoUI/Art/Miscellaneous/centerscreen_left.dds")
				:SetDrawLayer(100)
			.__END
		local side = Chain(WM:CreateControl("sideFuzz", SWAPS.UI, CT_TEXTURE))
				:SetDimensions(400, 50)
				:SetAnchor(TOPLEFT,bg,TOPRIGHT, 0, 0)
				:SetTexture("EsoUI/Art/Miscellaneous/centerscreen_right.dds")
				:SetDrawLayer(100)
			.__END
		SWAPS.container = Chain(WM:CreateControlFromVirtual("container", SWAPS.UI, "ZO_ScrollContainer"))
				:SetAnchor(TOPLEFT,SWAPS.UI,TOPLEFT, 0, 40)
				:SetDimensions(320, 750)
			.__END
		SWAPS.scroll = SWAPS.container:GetNamedChild("ScrollChild")
		
		for i = 1, #SWAPS.preset do
			drawPresetRow(i)
		end
		
		SWAPS.UI.main = Chain(WM:CreateTopLevelWindow(SWAPS.UI:GetName() .. "_main"))
				:SetDimensions(450, 300)
				:SetAnchor(CENTER,SWAPS.UI,CENTER, 100, 0)
				:SetHidden(true)
				:SetAlpha(1)
				:SetMovable(true)
			.__END
		SWAPS.UI.main.currentIconID = 1
		SWAPS.UI.main.bg = Chain(WM:CreateControl("$(parent)_bg", SWAPS.UI.main, CT_TEXTURE))
				:SetAnchor(CENTER, SWAPS.UI.main, CENTER, -150, 40)
				:SetDimensions(350, 400)
				:SetTexture("/esoui/art/lorelibrary/lorelibrary_bg_left.dds")
				:SetDrawLayer(10)
			.__END
		SWAPS.UI.main.bg2 = Chain(WM:CreateControl("$(parent)_bg2",SWAPS.UI.main, CT_TEXTURE))
				:SetAnchor(CENTER, SWAPS.UI.main.bg2, CENTER, 150, 40)
				:SetDimensions(250, 400)
				:SetTexture("/esoui/art/lorelibrary/lorelibrary_bg_right.dds")
				:SetDrawLayer(9)
			.__END
		SWAPS.UI.main.cancelBackgroundClicks = Chain(WM:CreateControl("$(parent)_cancelBackgroundClicks", SWAPS.UI.main, CT_BUTTON))
				:SetDimensions(550, 400)
				:SetAnchor(TOPRIGHT, SWAPS.UI.main, TOPRIGHT, 0, 0)
				:SetAlpha(1)
				:SetDrawLayer(8)
				:SetHandler("OnClicked", function(h) end)
			.__END
		SWAPS.UI.main.header = Chain(WM:CreateControl("$(parent)_header", SWAPS.UI.main, CT_LABEL))
				:SetText("Preset Settings")
				:SetFont("ZoFontAlert")
				:SetColor(0.8, 0.8, 0.8, 1)
				:SetScale(1)
				:SetHorizontalAlignment(1)
				:SetAnchor(CENTER, SWAPS.UI.main, CENTER, -60, -90)
				:SetDimensions(400, 50)
				:SetDrawLayer(1)
			.__END
		SWAPS.UI.main.cancel = Chain(WM:CreateControl("$(parent)_cancel", SWAPS.UI.main, CT_BUTTON))
				:SetDimensions(20, 20)
				:SetAnchor(TOPRIGHT, SWAPS.UI.main, TOPRIGHT, -22, -3)
				:SetNormalTexture("/esoui/art/quest/quest_abandon_up.dds")
				:SetAlpha(1)
				:SetDrawLayer(0)
				:SetHandler("OnClicked", function(h) SWAPS.UI.main:SetHidden(true) end)
			.__END
		SWAPS.UI.main.edit=Chain(WM:CreateControlFromVirtual("$(parent)_edit", SWAPS.UI.main, "ZO_EditBackdrop"))
				:SetDimensions(300, 30)
				:SetCenterColor(.4,.4,.4, 0)
				:SetEdgeColor(0, 0, 0, 0)
				:SetEdgeTexture("", 1, 1, 2, 5)
				:SetAlpha(1)
				:SetScale(1)
				:SetDrawLayer(1)
				:SetInsets(0, 0, 0, 0)
				:SetAnchor(TOPLEFT, SWAPS.UI.main, TOPLEFT, 80, 80)
			.__END
		SWAPS.UI.main.editLabel = Chain(WM:CreateControl("$(parent)_editLabel", SWAPS.UI.main, CT_LABEL))
				:SetText("Name:")
				:SetFont("ZoFontAlert")
				:SetColor(0.8, 0.8, 0.8, 1)
				:SetScale(1)
				:SetDrawLayer(1)
				:SetAnchor(TOPRIGHT, SWAPS.UI.main.edit, TOPLEFT, -20, 0)
				:SetDimensions(70, 40)
				:SetHorizontalAlignment(2)
			.__END
		SWAPS.UI.main.editBox = Chain(WM:CreateControlFromVirtual("$(parent)_editBox", SWAPS.UI.main.edit, "ZO_DefaultEditForBackdrop"))
				:SetText("New Name Here")
				:SetFont("ZoFontGameBold")
				:SetColor(0.3, 0.72, 1, 1)
				:SetMaxInputChars(20)
				:SetScale(1)
				:SetDrawLayer(1)
			.__END
		SWAPS.UI.main.editIconLabel = Chain(WM:CreateControl("$(parent)_editIconLabel",SWAPS.UI.main,CT_LABEL))
				:SetText("Icon:")
				:SetFont("ZoFontAlert")
				:SetColor(0.8, 0.8, 0.8, 1)
				:SetScale(1)
				:SetDrawLayer(1)
				:SetAnchor(TOPRIGHT, SWAPS.UI.main.editLabel, BOTTOMRIGHT, 0, 0)
				:SetDimensions(65, 50)
				:SetHorizontalAlignment(2)
			.__END
		SWAPS.UI.main.icon = Chain(WM:CreateControl("$(parent)_icon", SWAPS.UI.main, CT_TEXTURE))
				:SetDimensions(80, 80)
				:SetAnchor(CENTER, SWAPS.UI.main.editIconLabel, CENTER, 100, 0)
				:SetTexture(SWAPS_iconPak[1])
				:SetDrawLayer(1)
				:SetScale(1)
			.__END
		SWAPS.UI.main.icon.next = Chain(WM:CreateControl("$(parent)_icon_next", SWAPS.UI.main, CT_BUTTON))
				:SetDimensions(40, 40)
				:SetAnchor(CENTER, SWAPS.UI.main.icon, CENTER, 55, 0)
				:SetNormalTexture("/esoui/art/tooltips/tooltip_rightarrow.dds")
				:SetDrawLayer(1)
				:SetHandler("OnClicked", function(h)
					SWAPS.UI.main.currentIconID = getNextIcon(SWAPS.UI.main.icon, SWAPS.UI.main.currentIconID, SWAPS_iconPak, 1)
					SWAPS.newPresetConfig.icon = SWAPS_iconPak[SWAPS.UI.main.currentIconID]
				end)
			.__END
		SWAPS.UI.main.icon.prev = Chain(WM:CreateControl("$(parent)_icon_prev", SWAPS.UI.main, CT_BUTTON))
				:SetDimensions(40, 40)
				:SetAnchor(CENTER, SWAPS.UI.main.icon, CENTER, -55, 0)
				:SetNormalTexture("/esoui/art/tooltips/tooltip_leftarrow.dds")
				:SetDrawLayer(1)
				:SetHandler("OnClicked", function(h)
					SWAPS.UI.main.currentIconID = getNextIcon(SWAPS.UI.main.icon, SWAPS.UI.main.currentIconID, SWAPS_iconPak, -1)
					SWAPS.newPresetConfig.icon = SWAPS_iconPak[SWAPS.UI.main.currentIconID]
				end)
			.__END
		SWAPS.UI.main.slots = {}
		
		for i= 1, 6 do
			local offset = 33
			if i == 6 then offset = 38 end
			SWAPS.UI.main.slots[i] = {}
			SWAPS.UI.main.slots[i].t = 0
			SWAPS.UI.main.slots[i].l = 0
			SWAPS.UI.main.slots[i].a = 0
			SWAPS.UI.main.slots[i] = Chain(WM:CreateControl("$(parent)_slots" .. i, SWAPS.UI.main, CT_TEXTURE))
					:SetDimensions(30, 30)
					:SetAnchor(TOPLEFT, SWAPS.UI.main.icon.prev, BOTTOMLEFT, offset * i - 30, 25)
					:SetAlpha(1)
					:SetDrawLayer(1)
				.__END
		end
		SWAPS.UI.main.saveBtn = Chain(WM:CreateControl("$(parent)_saveBtn", SWAPS.UI.main, CT_BUTTON))
				:SetDimensions(100, 40)
				:SetText("SAVE")
				:SetAnchor(CENTER, SWAPS.UI.main.header, CENTER, 50, 220)
				:SetFont("ZoFontAlert")
				:SetDrawLayer(3)
				:SetNormalFontColor(0.85, 0.6, 0.13, 1)
				:SetMouseOverFontColor(1, 1.13, 0.13, 1)
				:SetHandler("OnClicked", function()
					if SWAPS.UI.main.type == "new" then
						savePreset()
						updatePresetName(SWAPS.newPresetConfig.currentPID)
						SWAPS.UI.main:SetHidden(true)
					end
					if SWAPS.UI.main.type == "rename" then
						savePreset()
						updatePresetName(SWAPS.newPresetConfig.currentPID)
						SWAPS.UI.main:SetHidden(true)
					end
				end)
			.__END
		SWAPS.UI.main.parseBtn = Chain(WM:CreateControl("$(parent)_parseBtn", SWAPS.UI.main, CT_BUTTON))
				:SetDimensions(80, 80)
				:SetMouseOverTexture("/esoui/art/hud/radialicon_trade_up.dds")
				:SetNormalTexture("/esoui/art/hud/radialicon_trade_over.dds")
				:SetAlpha(1)
				:SetAnchor(CENTER, SWAPS.UI.main.slots[1], CENTER, -40, 0)
				:SetDrawLayer(2)
				:SetHandler("OnClicked", function()
					for i = 1, 6 do
						SWAPS.UI.main.slots[i]:SetAlpha(0)
					end
					SWAPS.UI.main.notify:SetAnchor(BOTTOMLEFT, SWAPS.UI.main.slots[1], BOTTOMLEFT, 0, 25)
					SWAPS.UI.main.notify:SetAlpha(1)
					SWAPS.UI.main.notify:SetText("Loading Current Hotbar")
					SWAPS.UI.main.notify:SetDrawLayer(1)
					zo_callLater(function() parseHotbar(SWAPS.UI.main, SWAPS.newPresetConfig.currentPID) end, 20)
				end)
				:SetAlpha(.5)
			.__END
		SetToolTip(SWAPS.UI.main.parseBtn, "Load Current Hotbar")
		SWAPS.UI.main.remove = Chain(WM:CreateControl("$(parent)_remove", SWAPS.UI.main, CT_BUTTON))
				:SetDimensions(100, 40)
				:SetText("REMOVE")
				:SetAnchor(CENTER, SWAPS.UI.main.header, CENTER, -50, 220)
				:SetFont("ZoFontAlert")
				:SetDrawLayer(3)
				:SetNormalFontColor(0.85, 0.6, 0.13, 1)
				:SetMouseOverFontColor(1, 1.13, 0.13, 1)
				:SetHandler("OnClicked", function()
					if SWAPS.UI.main.type == "new" then end
					if SWAPS.UI.main.type == "rename" then
						table.remove(SWAPS.preset, SWAPS.newPresetConfig.currentPID)
						ZO_Skills:SetHidden(true)
						SWAPS.rows[SWAPS.newPresetConfig.currentPID].frame:SetAlpha(0)
						for i = 1, #SWAPS.preset do
							SWAPS.rows[i].frame:SetAlpha(0)
						end
						SWAPS.scroll:SetHidden(true)
						SWAPS.containerCount = SWAPS.containerCount + 1
						SWAPS.container = Chain(WINDOW_MANAGER:CreateControlFromVirtual("$(parent)_Container" .. SWAPS.containerCount, SWAPS.UI, "ZO_ScrollContainer"))
								:SetAnchor(TOPLEFT,SWAPS.UI,TOPLEFT, 0, 40)
								:SetDimensions(320, 750)
							.__END
						SWAPS.scroll = SWAPS.container:GetNamedChild("ScrollChild")
						ZO_Skills:SetHidden(false)
						SWAPS.scroll:SetHidden(false)
						for presetIndex = 1, #SWAPS.preset do
							drawPresetRow(presetIndex)
							updatePresetName(presetIndex)
						end
						SWAPS.UI.main:SetHidden(true)
					end
				end)
			.__END
		SWAPS.UI.main.notify=Chain(WM:CreateControl("$(parent)_notify ", SWAPS.UI.main, CT_LABEL))
				:SetFont("ZoFontTooltipSubtitle")
				:SetColor(0.8, 0.8, 0.8, 1)
				:SetScale(1)
				:SetDrawLayer(1)
				:SetDimensions(200, 50)
				:SetAlpha(0)
			.__END
		local s = Chain(WM:CreateControl(nil, SWAPS.UI.main, CT_BACKDROP))
				:SetEdgeTexture("", 1, 1, 1, 1)
				:SetCenterColor(135/255, 218/255, 221/255, 1)
				:SetAnchor(TOPLEFT, SWAPS.UI.main.editBox, TOPLEFT, -5, 0)
				:SetDimensions(230, 30)
				:SetAlpha(.3)
				:SetDrawLayer(5)
			.__END
		local s = Chain(WM:CreateControl(nil, SWAPS.UI.main,CT_BACKDROP))
				:SetEdgeTexture("", 1, 1, 1, 1)
				:SetCenterColor(135/255, 218/255, 221/255, 1)
				:SetAnchor(CENTER,SWAPS.UI.main.parseBtn,CENTER, 145, 0)
				:SetDimensions(250, 40)
				:SetAlpha(.3)
				:SetDrawLayer(5)
			.__END
			
		for i = 1, #SWAPS.preset do
			updatePresetName(i)
		end
		
	end
end

EVENT_MANAGER:RegisterForEvent("swaps", EVENT_ADD_ON_LOADED, onLoadAddOn)
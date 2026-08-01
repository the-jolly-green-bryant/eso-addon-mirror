Mephisto = Mephisto or {}
local MP = Mephisto

MP.prebuff = {}
local MPP = MP.prebuff
local MPQ = MP.queue
local MPG = MP.gui

function MPP.Init()
	MPP.name = MP.name .. "Prebuff"
	MPP.cache = {}
	
	MPP.CreatePrebuffTable()
	MPP.CreatePrebuffWindow()
	
	EVENT_MANAGER:RegisterForEvent(MPP.name, EVENT_ACTION_SLOT_ABILITY_USED, MPP.OnPrebuffed)
	EVENT_MANAGER:RegisterForEvent(MPP.name, EVENT_PLAYER_DEAD, function() MPP.cache = {} end)
end

function MPP.Prebuff(index)
	if IsUnitInCombat("player") then return	end
	
	local skillTable = MPP.GetPrebuffSkills(index)
	
	if #skillTable == 0 then
		return
	end
	
	local isToggle = MP.prebuffs[index][0].toggle
	
	-- restore if the same prebuff button is pressed twice
	if MPP.cache.index == index then
		MPP.RestoreHotbar()
		return
	end
	
	-- prevents multiple prebuffs from overlapping
	if MPP.cache.spells then
		MPP.RestoreHotbar()
	end
	
	local prebuffTask = function()
		MPP.cache = {
			index = index,
			hotbar = GetActiveHotbarCategory(),
			spells = MPP.GetCurrentHotbar(),
			toggle = isToggle,
		}
		
		for _, skill in ipairs(skillTable) do
			MP.SlotSkill(MPP.cache.hotbar, skill.slot, skill.id)
		end
		
		if not isToggle then
			MPP.cache.spell = skillTable[1]
			MPP.cache.delay = MP.prebuffs[index][0].delay
		end
	end
	MPQ.Push(prebuffTask)
end

function MPP.OnPrebuffed(_, slotIndex)
	if not MPP.cache and not MPP.cache.spell then return end
	if MPP.cache.toggle then return end
	if MPP.cache.hotbar ~= GetActiveHotbarCategory() then return end
	if MPP.cache.spell.slot ~= slotIndex then return end
	
	-- skill already gone
	if not MP.AreSkillsEqual(MPP.cache.spell.id, GetSlotBoundId(slotIndex, GetActiveHotbarCategory())) then
		MPP.cache = {}
		return
	end
	
	local weaponDelay = ArePlayerWeaponsSheathed() and 1000 or 0
	
	zo_callLater(function()
		MPQ.Push(function()
			MPP.RestoreHotbar()
		end)
	end, MPP.cache.delay + weaponDelay + GetLatency())
end

function MPP.RestoreHotbar()
	if not MPP.cache or not MPP.cache.spells then return end
	MPQ.Push(function()
		for slot = 3, 8 do
			if not MPP.cache or not MPP.cache.spells then return end
			local abilityId = MPP.cache.spells[slot]
			MP.SlotSkill(MPP.cache.hotbar, slot, abilityId)
		end
		MPP.cache = {}
	end)
end

function MPP.GetCurrentHotbar()
	local skillTable = {}
	for slot = 3, 8 do
		local hotbarCategory = GetActiveHotbarCategory()
		local abilityId = GetSlotBoundId(slot, hotbarCategory)
		local baseId = MP.GetBaseAbilityId(abilityId)
		skillTable[slot] = baseId
	end
	return skillTable
end

function MPP.GetPrebuffSkills(index)
	local skillTable = {} 
	for slot = 3, 8 do
		local abilityId = MP.prebuffs[index][slot]
		if abilityId and abilityId > 0 then
			table.insert(skillTable, {slot = slot, id = abilityId})
		end
	end
	return skillTable
end

function MPP.CreatePrebuffTable()
	if #MP.prebuffs == 0 then
		for i = 1, 5 do
			MP.prebuffs[i] = {
				[0] = {
					toggle = false,
					delay = 500,
				}
			}
		end
	end
end

function MPP.CreatePrebuffWindow()
	local dialog = WINDOW_MANAGER:CreateTopLevelWindow(MPP.name)
	MPP.dialog = dialog
	dialog:SetDimensions(600, 395)
	dialog:SetAnchor(CENTER, GUI_ROOT, CENTER, 0, 0)
	dialog:SetDrawTier(DT_HIGH)
	dialog:SetClampedToScreen(false)
	dialog:SetMouseEnabled(true)
	dialog:SetMovable(true)
	dialog:SetHidden(true)
	
	table.insert(MP.gui.dialogList, dialog)
		
	local background = WINDOW_MANAGER:CreateControlFromVirtual(dialog:GetName() .. "BG", dialog, "ZO_DefaultBackdrop")
	background:SetAlpha(0.95)
	
	local title = WINDOW_MANAGER:CreateControl(dialog:GetName() .. "Title", dialog, CT_LABEL)
	title:SetAnchor(CENTER, dialog, TOP, 0, 25)
	title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	title:SetHorizontalAlignment(TEXT_ALIGN_CENTER) 
	title:SetFont("ZoFontWinH1")
	title:SetText(GetString(MP_BUTTON_PREBUFF):upper())
	
	local hideButton = WINDOW_MANAGER:CreateControl(dialog:GetName() .. "Hide", dialog, CT_BUTTON)
	hideButton:SetDimensions(25, 25)
	hideButton:SetAnchor(TOPRIGHT, dialog, TOPRIGHT, -4, 4)
	hideButton:SetState(BSTATE_NORMAL)
	hideButton:SetClickSound(SOUNDS.DIALOG_HIDE)
	hideButton:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
	hideButton:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
	hideButton:SetPressedTexture("/esoui/art/buttons/decline_down.dds")
	hideButton:SetHandler("OnClicked", function(self) dialog:SetHidden(true) end)
	
	local helpButton = WINDOW_MANAGER:CreateControl(dialog:GetName() .. "Help", dialog, CT_BUTTON)
	helpButton:SetDimensions(25, 25)
	helpButton:SetAnchor(TOPRIGHT, dialog, TOPRIGHT, -6 -30, 3)
	helpButton:SetState(BSTATE_NORMAL)
	helpButton:SetNormalTexture("/esoui/art/menubar/menubar_help_up.dds")
	helpButton:SetMouseOverTexture("/esoui/art/menubar/menubar_help_over.dds")
	helpButton:SetPressedTexture("/esoui/art/menubar/menubar_help_up.dds")
	MPG.SetTooltip(helpButton, TOP, GetString(MP_PREBUFF_HELP))
	
	for i = 1, 5 do
		local prebuffBox = WINDOW_MANAGER:CreateControl(dialog:GetName() .. "Box" .. i, dialog, CT_CONTROL)
		prebuffBox:SetDimensions(500, 60)
		prebuffBox:SetAnchor(CENTER, preview, TOP, 0, 65 * i + 20)
		local prebuffBoxBG = WINDOW_MANAGER:CreateControl(prebuffBox:GetName() .. "BG", prebuffBox, CT_BACKDROP)
		prebuffBoxBG:SetCenterColor(1, 1, 1, 0)
		prebuffBoxBG:SetEdgeColor(1, 1, 1, 1)
		prebuffBoxBG:SetEdgeTexture(nil, 1, 1, 1, 0)
		prebuffBoxBG:SetAnchorFill(prebuffBox)
		
		local prebuffLabel = WINDOW_MANAGER:CreateControl(prebuffBox:GetName() .. "Label", prebuffBox, CT_LABEL)
		prebuffLabel:SetAnchor(CENTER, prebuffBox, LEFT, 25, 0)
		prebuffLabel:SetFont("ZoFontWinH1")
		prebuffLabel:SetText(i)
		
		local editBox = WINDOW_MANAGER:CreateControlFromVirtual(prebuffBox:GetName() .. "EditBox", prebuffBox, "ZO_DefaultEdit")
		editBox:SetDimensions(35, 20)
		editBox:SetAnchor(CENTER, prebuffBox, LEFT, 425, 0)
		editBox:SetTextType(TEXT_TYPE_NUMERIC_UNSIGNED_INT)
		editBox:SetHandler("OnTextChanged", function(self)
			MP.prebuffs[i][0].delay = tonumber(editBox:GetText()) or 0
		end)
		editBox:SetText(MP.prebuffs[i][0].delay)
		
		local editBoxBackground = WINDOW_MANAGER:CreateControlFromVirtual(editBox:GetName() .. "BG", editBox, "ZO_EditBackdrop")
		editBoxBackground:SetDimensions(editBox:GetWidth() + 10, editBox:GetHeight() + 10)
		editBoxBackground:SetAnchor(CENTER, editBox, CENTER, 0, 0)
		
		local editBoxLabel = WINDOW_MANAGER:CreateControl(editBox:GetName() .. "Label", prebuffBox, CT_LABEL)
		editBox.ctlabel = editBoxLabel
		editBoxLabel:SetAnchor(LEFT, editBox, RIGHT, 10, 2)
		editBoxLabel:SetFont("ZoFontGameSmall")
		editBoxLabel:SetText("Delay")
		
		local checkBox = WINDOW_MANAGER:CreateControlFromVirtual(prebuffBox:GetName() .. "CheckBox", prebuffBox, "ZO_CheckButton")
		checkBox:SetAnchor(CENTER, prebuffBox, LEFT, 330, 0)
		checkBox:SetHandler("OnClicked", function(self)
			local state = not ZO_CheckButton_IsChecked(self)
			MP_DefaultEdit_SetEnabled(editBox, not state)
			MP_CheckButton_SetCheckState(checkBox, state)
			MP.prebuffs[i][0].toggle = state
		end)
		
		local checkBoxLabel = WINDOW_MANAGER:CreateControl(checkBox:GetName() .. "Label", prebuffBox, CT_LABEL)
		checkBox.ctlabel = checkBoxLabel
		checkBoxLabel:SetAnchor(LEFT, checkBox, RIGHT, 5, 2)
		checkBoxLabel:SetFont("ZoFontGameSmall")
		checkBoxLabel:SetText("Toggle")		
		
		for slot = 1, 6 do
			local skill = WINDOW_MANAGER:CreateControl(prebuffBox:GetName() .. "Skill" .. slot, prebuffBox, CT_TEXTURE)
			skill:SetDrawLayer(DL_CONTROLS)
			skill:SetDimensions(40, 40)
			skill:SetAnchor(CENTER, prebuffBox, LEFT, 25 + slot * 42, 0)
			skill:SetMouseEnabled(true)
			skill:SetDrawLevel(2)
			local function OnSkillDragStart(self)
				if IsUnitInCombat("player") then return	end -- would fail at protected call anyway
				if GetCursorContentType() ~= MOUSE_CONTENT_EMPTY then return end
				
				local abilityId = MP.prebuffs[i][slot+2]
				if not abilityId then return end
				
				local progression = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId(abilityId)
				if not progression then return end
				
				local skillType, skillLine, skillIndex = GetSpecificSkillAbilityKeysByAbilityId(progression:GetAbilityId())
				if CallSecureProtected("PickupAbilityBySkillLine", skillType, skillLine, skillIndex) then
					MP.prebuffs[i][slot+2] = 0
					local abilityIcon = "/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds"
					skill:SetTexture(abilityIcon)
					
					MPP.CheckToggleCondition(i, checkBox, editBox)
				end
			end
			local function OnSkillDragReceive(self)
				if GetCursorContentType() ~= MOUSE_CONTENT_ACTION then return end
				local abilityId = GetCursorAbilityId()
				
				local progression = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId(abilityId)
				if not progression then return end
				
				if progression:IsUltimate() and slot < 6 or
					not progression:IsUltimate() and slot > 5 then
					-- Prevent ult on normal slot and vice versa
					return
				end
				
				if progression:IsChainingAbility() then
					abilityId = GetEffectiveAbilityIdForAbilityOnHotbar(abilityId, hotbar)
				end
				
				ClearCursor()
				
				local previousAbilityId = MP.prebuffs[i][slot+2]
				MP.prebuffs[i][slot+2] = abilityId
				
				local abilityIcon = "/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds"
				if abilityId and abilityId > 0 then
					abilityIcon = GetAbilityIcon(abilityId)
				end
				skill:SetTexture(abilityIcon)
				
				MPP.CheckToggleCondition(i, checkBox, editBox)
				
				if previousAbilityId and previousAbilityId > 0 then
					local previousProgression = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId(previousAbilityId)
					if not previousProgression then return end
					local skillType, skillLine, skillIndex = GetSpecificSkillAbilityKeysByAbilityId(previousProgression:GetAbilityId())
					CallSecureProtected("PickupAbilityBySkillLine", skillType, skillLine, skillIndex)
				end
			end
			skill:SetHandler("OnReceiveDrag", OnSkillDragReceive)
			skill:SetHandler("OnMouseUp", function(self)
				if MouseIsOver(self, 0, 0, 0, 0) then
					OnSkillDragReceive(self)
				end
			end)
			skill:SetHandler("OnDragStart", OnSkillDragStart)
			local abilityId = MP.prebuffs[i][slot+2]
			local abilityIcon = "/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds"
			if abilityId and abilityId > 0 then
				abilityIcon = GetAbilityIcon(abilityId)
			end
			skill:SetTexture(abilityIcon)
			
			local frame = WINDOW_MANAGER:CreateControl(skill:GetName() .. "Frame", skill, CT_TEXTURE)
			frame:SetDrawLayer(DL_CONTROLS)
			frame:SetDimensions(40, 40)
			frame:SetAnchor(CENTER, skill, CENTER, 0, 0)
			frame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
			frame:SetDrawLevel(3)
			
			MPP.CheckToggleCondition(i, checkBox, editBox)
		end
	end
end

function MPP.CheckToggleCondition(index, checkBox, editBox)
	local function Check()
		local i = 0
		for slot = 1, 6 do
			if MP.prebuffs[index][slot+2]
				and MP.prebuffs[index][slot+2] > 0 then
				i = i + 1
			end
			if i > 1 then
				return true
			end
		end
		return false
	end
	
	local state = Check()
	
	MP_CheckButton_SetCheckState(checkBox, MP.prebuffs[index][0].toggle)
	MP_DefaultEdit_SetEnabled(editBox, not MP.prebuffs[index][0].toggle)
	
	-- its always a toggle if there is more then 1 spell
	if state then
		MP_CheckButton_SetCheckState(checkBox, true)
		MP_CheckButton_SetEnableState(checkBox, false)
		MP_DefaultEdit_SetEnabled(editBox, false)
		MP.prebuffs[index][0].toggle = true
	end
end

function MP_DefaultEdit_SetEnabled(editBox, state)
	ZO_DefaultEdit_SetEnabled(editBox, state)
	if editBox.ctlabel then
		local color = state and ZO_SELECTED_TEXT or ZO_DISABLED_TEXT
		editBox.ctlabel:SetColor(color:UnpackRGBA())
	end
end

function MP_CheckButton_SetEnableState(checkBox, state)
	ZO_CheckButton_SetEnableState(checkBox, state)
	if checkBox.ctlabel then
		local color = state and ZO_SELECTED_TEXT or ZO_DISABLED_TEXT
		checkBox.ctlabel:SetColor(color:UnpackRGBA())
	end
end

function MP_CheckButton_SetCheckState(checkBox, state)
	ZO_CheckButton_SetCheckState(checkBox, state)
	if checkBox.ctlabel then
		checkBox.ctlabel:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
	end
end
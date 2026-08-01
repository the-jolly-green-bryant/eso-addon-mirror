Mephisto = Mephisto or {}
local MP = Mephisto

MP.preview = {}
local MPP = MP.preview

function MPP.Init()
	MPP.name = MP.name .. "Preview"
	MPP.CreatePrevieMPindow()
	
	LibChatMessage:RegisterCustomChatLink(MP.LINK_TYPES.PREVIEW, function(linkStyle, linkType, data, displayText)
		return ZO_LinkHandler_CreateLinkWithoutBrackets(displayText, nil, MP.LINK_TYPES.PREVIEW, data)
	end)
	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, MPP.HandleClickEvent)
	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, MPP.HandleClickEvent)
	
	MPP.chatCache = {}
	EVENT_MANAGER:RegisterForEvent(MPP.name, EVENT_CHAT_MESSAGE_CHANNEL, MPP.OnChatMessage)
end

function MPP.CreatePrevieMPindow()
	local window = WINDOW_MANAGER:CreateTopLevelWindow(MPP.name)
	MPP.window = window
	window:SetDimensions(GuiRoot:GetWidth() + 8, GuiRoot:GetHeight() + 8)
	window:SetAnchor(CENTER, GUI_ROOT, CENTER, 0, 0)
	window:SetDrawTier(DT_HIGH)
	window:SetClampedToScreen(false)
	window:SetMouseEnabled(true)
	window:SetMovable(false)
	window:SetHidden(true)
	
	table.insert(MP.gui.dialogList, window)
	
	local fullscreenBackground = WINDOW_MANAGER:CreateControlFromVirtual(window:GetName() .. "BG", window, "ZO_DefaultBackdrop")
	fullscreenBackground:SetAlpha(0.6)
	
	local preview = WINDOW_MANAGER:CreateControl(window:GetName() .. "Preview", window, CT_CONTROL)
	MPP.preview = preview
	preview:SetDimensions(800, 730)
	preview:SetAnchor(CENTER, window, CENTER, 0, 0)
	preview:SetMouseEnabled(true)
	
	local previewBackground = WINDOW_MANAGER:CreateControlFromVirtual(preview:GetName() .. "BG", preview, "ZO_DefaultBackdrop")
	previewBackground:SetAlpha(0.95)
		
	local hideButton = WINDOW_MANAGER:CreateControl(preview:GetName() .. "Hide", preview, CT_BUTTON)
	hideButton:SetDimensions(25, 25)
	hideButton:SetAnchor(TOPRIGHT, preview, TOPRIGHT, -4, 4)
	hideButton:SetState(BSTATE_NORMAL)
	hideButton:SetClickSound(SOUNDS.DIALOG_HIDE)
	hideButton:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
	hideButton:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
	hideButton:SetPressedTexture("/esoui/art/buttons/decline_down.dds")
	hideButton:SetHandler("OnClicked", function(self) window:SetHidden(true) end)
	
	local setupName = WINDOW_MANAGER:CreateControl(preview:GetName() .. "SetupName", preview, CT_LABEL)
	MPP.setupName = setupName
	setupName:SetAnchor(TOPLEFT, preview, TOPLEFT, 10, 5)
	setupName:SetFont("ZoFontWinH1")
	
	local zoneName = WINDOW_MANAGER:CreateControl(preview:GetName() .. "ZoneName", preview, CT_LABEL)
	MPP.zoneName = zoneName
	zoneName:SetAnchor(LEFT, setupName, RIGHT, 6, -4)
	zoneName:SetFont("ZoFontWinH2")
	zoneName:SetVerticalAlignment(TEXT_ALIGN_TOP)
	
	-- GEAR
	MPP.gear = {}
	local gearBox = WINDOW_MANAGER:CreateControl(window:GetName() .. "Gear", preview, CT_CONTROL)
	gearBox:SetDimensions(500, 665)
	gearBox:SetAnchor(TOPLEFT, preview, TOPLEFT, 10, 50)
	local gearBoxBG = WINDOW_MANAGER:CreateControl(gearBox:GetName() .. "BG", gearBox, CT_BACKDROP)
	gearBoxBG:SetCenterColor(1, 1, 1, 0)
	gearBoxBG:SetEdgeColor(1, 1, 1, 1)
	gearBoxBG:SetEdgeTexture(nil, 1, 1, 1, 0)
	gearBoxBG:SetAnchorFill(gearBox)
	for gearIndex, gearSlot in ipairs(MP.GEARSLOTS) do
		MPP.gear[gearIndex] = {}
		
		local gearIcon = WINDOW_MANAGER:CreateControl(gearBox:GetName() .. "Icon" .. gearIndex, gearBox, CT_TEXTURE)
		MPP.gear[gearIndex].icon = gearIcon
		gearIcon:SetDrawLayer(DL_CONTROLS)
		gearIcon:SetDimensions(36, 36)
		gearIcon:SetAnchor(TOPLEFT, gearBox, TOPLEFT, 10, 10 + (38 * (gearIndex-1)))
		gearIcon:SetTexture(MP.GEARICONS[gearSlot])
		gearIcon:SetMouseEnabled(true)
		gearIcon:SetDrawLevel(2)
		
		local gearFrame = WINDOW_MANAGER:CreateControl(gearBox:GetName() .. "Frame" .. gearIndex, gearBox, CT_TEXTURE)
		gearFrame:SetDrawLayer(DL_CONTROLS)
		gearFrame:SetDimensions(36, 36)
		gearFrame:SetAnchor(CENTER, gearIcon, CENTER, 0, 0)
		gearFrame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
		gearFrame:SetDrawLevel(3)
		
		local gearLabel = WINDOW_MANAGER:CreateControl(gearBox:GetName() .. "Name" .. gearIndex, gearBox, CT_LABEL)
		MPP.gear[gearIndex].label = gearLabel
		gearLabel:SetDrawLayer(DL_CONTROLS)
		gearLabel:SetAnchor(LEFT, gearIcon, RIGHT, 5, 0)
		gearLabel:SetDimensionConstraints(AUTO_SIZE, AUTO_SIZE, 439, 42)
		gearLabel:SetFont("ZoFontGame")
		gearLabel:SetMouseEnabled(true)
	end
	
	-- SKILLS
	MPP.skills = {[0] = {},	[1] = {}}
	local skillBox = WINDOW_MANAGER:CreateControl(window:GetName() .. "Skills", preview, CT_CONTROL)
	skillBox:SetDimensions(270, 102)
	skillBox:SetAnchor(TOPLEFT, preview, TOPLEFT, 520, 50)
	local skillBoxBG = WINDOW_MANAGER:CreateControl(skillBox:GetName() .. "BG", skillBox, CT_BACKDROP)
	skillBoxBG:SetCenterColor(1, 1, 1, 0)
	skillBoxBG:SetEdgeColor(1, 1, 1, 1)
	skillBoxBG:SetEdgeTexture(nil, 1, 1, 1, 0)
	skillBoxBG:SetAnchorFill(skillBox)
	for hotbarIndex = 0, 1 do
		for skillIndex = 0, 5 do
			local skillIcon = WINDOW_MANAGER:CreateControl(skillBox:GetName() .. "Icon" .. hotbarIndex .. skillIndex, skillBox, CT_TEXTURE)
			MPP.skills[hotbarIndex][skillIndex+3] = skillIcon
			skillIcon:SetDrawLayer(DL_CONTROLS)
			skillIcon:SetDimensions(40, 40)
			skillIcon:SetAnchor(TOPLEFT, skillBox, TOPLEFT, 10 + (42 * skillIndex), 10 + (42 * hotbarIndex))
			skillIcon:SetTexture("/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds")
			skillIcon:SetMouseEnabled(true)
			skillIcon:SetDrawLevel(2)
			
			local skillFrame = WINDOW_MANAGER:CreateControl(skillBox:GetName() .. "Frame" .. hotbarIndex .. skillIndex, skillBox, CT_TEXTURE)
			skillFrame:SetDrawLayer(DL_CONTROLS)
			skillFrame:SetDimensions(40, 40)
			skillFrame:SetAnchor(CENTER, skillIcon, CENTER, 0, 0)
			skillFrame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
			skillFrame:SetDrawLevel(3)
		end
	end
	
	-- FOOD
	local foodBox = WINDOW_MANAGER:CreateControl(window:GetName() .. "Food", preview, CT_CONTROL)
	foodBox:SetDimensions(270, 60)
	foodBox:SetAnchor(TOPLEFT, preview, TOPLEFT, 520, 50 + 102 + 10)
	local foodBoxBG = WINDOW_MANAGER:CreateControl(foodBox:GetName() .. "BG", foodBox, CT_BACKDROP)
	foodBoxBG:SetCenterColor(1, 1, 1, 0)
	foodBoxBG:SetEdgeColor(1, 1, 1, 1)
	foodBoxBG:SetEdgeTexture(nil, 1, 1, 1, 0)
	foodBoxBG:SetAnchorFill(foodBox)
	
	local foodIcon = WINDOW_MANAGER:CreateControl(foodBox:GetName() .. "Icon", foodBox, CT_TEXTURE)
	MPP.foodIcon = foodIcon
	foodIcon:SetDrawLayer(DL_CONTROLS)
	foodIcon:SetDimensions(40, 40)
	foodIcon:SetAnchor(TOPLEFT, foodBox, TOPLEFT, 10, 10)
	foodIcon:SetTexture("/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds")
	foodIcon:SetMouseEnabled(true)
	foodIcon:SetDrawLevel(2)
	
	local foodFrame = WINDOW_MANAGER:CreateControl(foodBox:GetName() .. "Frame", foodBox, CT_TEXTURE)
	foodFrame:SetDrawLayer(DL_CONTROLS)
	foodFrame:SetDimensions(40, 40)
	foodFrame:SetAnchor(CENTER, foodIcon, CENTER, 0, 0)
	foodFrame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
	foodFrame:SetDrawLevel(3)
	
	local foodLabel = WINDOW_MANAGER:CreateControl(foodBox:GetName() .. "Label", foodBox, CT_LABEL)
	MPP.foodLabel = foodLabel
	foodLabel:SetDrawLayer(DL_CONTROLS)
	foodLabel:SetAnchor(LEFT, foodIcon, RIGHT, 5, 0)
	foodLabel:SetDimensionConstraints(AUTO_SIZE, AUTO_SIZE, 205, 42)
	foodLabel:SetFont("ZoFontGame")
	
	-- CP
	MPP.cp = {}
	local cpBox = WINDOW_MANAGER:CreateControl(window:GetName() .. "CP", preview, CT_CONTROL)
	cpBox:SetDimensions(270, 348)
	cpBox:SetAnchor(TOPLEFT, preview, TOPLEFT, 520, 50 + 102 + 10 + 60 + 10)
	local cpBoxBG = WINDOW_MANAGER:CreateControl(cpBox:GetName() .. "BG", cpBox, CT_BACKDROP)
	cpBoxBG:SetCenterColor(1, 1, 1, 0)
	cpBoxBG:SetEdgeColor(1, 1, 1, 1)
	cpBoxBG:SetEdgeTexture(nil, 1, 1, 1, 0)
	cpBoxBG:SetAnchorFill(cpBox)
	for cpIndex = 1, 12 do
		local cpIcon = WINDOW_MANAGER:CreateControl(cpBox:GetName() .. "Icon" .. cpIndex, cpBox, CT_TEXTURE)
		cpIcon:SetDrawLayer(DL_CONTROLS)
		cpIcon:SetDimensions(20, 20)
		cpIcon:SetAnchor(TOPLEFT, cpBox, TOPLEFT, 10, 10 + (28 * (cpIndex-1)))
		cpIcon:SetTexture(MP.CPICONS[cpIndex])
		cpIcon:SetDrawLevel(2)
		
		local cpFrame = WINDOW_MANAGER:CreateControl(cpBox:GetName() .. "Frame" .. cpIndex, cpBox, CT_TEXTURE)
		cpFrame:SetDrawLayer(DL_CONTROLS)
		cpFrame:SetDimensions(26, 26)
		cpFrame:SetAnchor(CENTER, cpIcon, CENTER, 0, 0)
		cpFrame:SetTexture("/esoui/art/champion/actionbar/champion_bar_slot_frame.dds")
		cpFrame:SetDrawLevel(3)
		
		local cpLabel = WINDOW_MANAGER:CreateControl(cpBox:GetName() .. "Label" .. cpIndex, cpBox, CT_LABEL)
		MPP.cp[cpIndex] = cpLabel
		cpLabel:SetDrawLayer(DL_CONTROLS)
		cpLabel:SetAnchor(LEFT, cpIcon, RIGHT, 5, 0)
		cpLabel:SetFont("ZoFontGame")
		cpLabel:SetText("CP" .. cpIndex)
	end
	
	-- ICON
	local iconBox = WINDOW_MANAGER:CreateControl(window:GetName() .. "Icon", preview, CT_CONTROL)
	iconBox:SetDimensions(270, 124)
	iconBox:SetAnchor(TOPLEFT, preview, TOPLEFT, 520, 50 + 102 + 10 + 60 + 10 + 346 + 10 + 2)
	local iconBoxBG = WINDOW_MANAGER:CreateControl(iconBox:GetName() .. "BG", iconBox, CT_BACKDROP)
	iconBoxBG:SetCenterColor(1, 1, 1, 0)
	iconBoxBG:SetEdgeColor(1, 1, 1, 1)
	iconBoxBG:SetEdgeTexture(nil, 1, 1, 1, 0)
	iconBoxBG:SetAnchorFill(iconBox)
	local icon = WINDOW_MANAGER:CreateControl(iconBox:GetName() .. "Icon", iconBox, CT_TEXTURE)
	icon:SetTexture("/Mephisto/assets/icon128.dds")
	icon:SetDimensions(80, 80)
	icon:SetAnchor(CENTER, iconBox, CENTER, 0, 0)
end

function MPP.ShowPreviewFromSetup(setup, zoneName)
	-- TITLE
	MPP.setupName:SetText(setup:GetName():upper())
	MPP.zoneName:SetText(zoneName:upper())
	
	-- GEAR
	for i, gearSlot in ipairs(MP.GEARSLOTS) do
		local gear = setup:GetGear()[gearSlot]
		if gear and gear.link and #gear.link > 0 then
			local itemName = gear.link
			if gearSlot == EQUIP_SLOT_COSTUME and gear.creator then
				itemName = string.format("%s |c808080(%s)|r", gear.link, gear.creator)
			elseif gearSlot ~= EQUIP_SLOT_POISON and gearSlot ~= EQUIP_SLOT_BACKUP_POISON then
				itemName = string.format("%s |c808080(%s)|r", gear.link, GetString("SI_ITEMTRAITTYPE", GetItemLinkTraitInfo(gear.link)))
			end
			
			local function onHover()
				InitializeTooltip(ItemTooltip, MPP.preview, RIGHT, -12, 0, LEFT)
				ItemTooltip:SetLink(gear.link)
			end
			local function OnExit()
				ClearTooltip(ItemTooltip)
			end
			
			local itemLabel = MPP.gear[i].label
			itemLabel:SetText(itemName)
			itemLabel:SetHandler("OnMouseEnter", onHover)
			itemLabel:SetHandler("OnMouseExit", OnExit)
			
			local itemIcon = MPP.gear[i].icon
			itemIcon:SetTexture(GetItemLinkIcon(gear.link))
			itemIcon:SetHandler("OnMouseEnter", onHover)
			itemIcon:SetHandler("OnMouseExit", OnExit)
		else
			local itemLabel = MPP.gear[i].label
			itemLabel:SetText("-/-")
			itemLabel:SetHandler("OnMouseEnter", function() end)
			itemLabel:SetHandler("OnMouseExit", function() end)
				
			local itemIcon = MPP.gear[i].icon
			itemIcon:SetTexture(MP.GEARICONS[gearSlot])
			itemIcon:SetHandler("OnMouseEnter", function() end)
			itemIcon:SetHandler("OnMouseExit", function() end)
		end
	end
	
	-- FOOD
	local food = setup:GetFood()
	if food and food.link and #food.link > 0 then
		MPP.foodLabel:SetText(food.link)
		
		local foodIcon = MPP.foodIcon
		foodIcon:SetTexture(GetItemLinkIcon(food.link))
		foodIcon:SetHandler("OnMouseEnter", function()
			InitializeTooltip(ItemTooltip, MPP.preview, LEFT, 12, 0, RIGHT)
			ItemTooltip:SetLink(food.link)
		end)
		foodIcon:SetHandler("OnMouseExit", function()
			ClearTooltip(ItemTooltip)
		end)
	else
		MPP.foodLabel:SetText("-/-")
		
		local foodIcon = MPP.foodIcon
		foodIcon:SetTexture("/esoui/art/crafting/provisioner_indexicon_meat_disabled.dds")
		foodIcon:SetHandler("OnMouseEnter", function() end)
		foodIcon:SetHandler("OnMouseExit", function() end)
	end
	
	-- CP
	for cpIndex = 1, 12 do
		MPP.cp[cpIndex]:SetText("-/-")
		local cpId = setup:GetCP()[cpIndex]
		if cpId then
			local cpName = zo_strformat("<<C:1>>", GetChampionSkillName(cpId))
			if #cpName > 0 then
				local text = string.format("|c%s%s|r", MP.CPCOLOR[cpIndex], cpName)
				MPP.cp[cpIndex]:SetText(text)
			end
		end
	end
	
	-- SKILLS
	for hotbarCategory = 0, 1 do
		for slotIndex = 3, 8 do
			local abilityId = setup:GetHotbar(hotbarCategory)[slotIndex]
			local abilityIcon = "/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds"
			if abilityId and abilityId > 0 then
				abilityIcon = GetAbilityIcon(abilityId)
			end
			local skillControl = MPP.skills[hotbarCategory][slotIndex]
			skillControl:SetTexture(abilityIcon)
			if abilityId and abilityId > 0 then
				skillControl:SetHandler("OnMouseEnter", function()
					InitializeTooltip(AbilityTooltip, MPP.preview, LEFT, 12, 0, RIGHT)
					AbilityTooltip:SetAbilityId(abilityId)
				end)
				skillControl:SetHandler("OnMouseExit", function()
					ClearTooltip(AbilityTooltip)
				end)
			else
				skillControl:SetHandler("OnMouseEnter", function() end)
				skillControl:SetHandler("OnMouseExit", function() end)
			end
		end
	end
	
	MPP.window:SetHidden(false)
end

function MPP.ShowPreviewFromString(dataString, setupName)
	local ptr = 1
		
	-- GEAR
	for i, gearSlot in ipairs(MP.GEARSLOTS) do
		if gearSlot ~= EQUIP_SLOT_COSTUME then
			local itemId = dataString:sub(ptr, ptr + 5)
			ptr = ptr + 6
			
			local traitId = 0
			if gearSlot ~= EQUIP_SLOT_POISON
				and gearSlot ~= EQUIP_SLOT_BACKUP_POISON then
				
				traitId = MP.PREVIEW.TRAITS[dataString:sub(ptr, ptr)]
				ptr = ptr + 1
			end
			
			if tonumber(itemId) > 0 then
				local itemLink = string.format("|H0:item:%d:%d:%d:%d:%d:%d:%d:0:0:0:0:0:0:0:0:%d:%d:%d:%d:%d:%d|h|h", itemId, 30, 50, 26580, 0, 0, traitId, 00, 0, 1, 0, 10000, 0)
				
				local itemName = itemLink
				if tostring(traitId) ~= "0" then
					itemName = string.format("%s |c808080(%s)|r", itemLink, GetString("SI_ITEMTRAITTYPE", traitId))
				end
				
				local function onHover()
					InitializeTooltip(ItemTooltip, MPP.preview, RIGHT, -12, 0, LEFT)
					ItemTooltip:SetLink(itemLink)
				end
				local function OnExit()
					ClearTooltip(ItemTooltip)
				end
				
				local itemLabel = MPP.gear[i].label
				itemLabel:SetText(itemName)
				itemLabel:SetHandler("OnMouseEnter", onHover)
				itemLabel:SetHandler("OnMouseExit", OnExit)
				
				local itemIcon = MPP.gear[i].icon
				itemIcon:SetTexture(GetItemLinkIcon(itemLink))
				itemIcon:SetHandler("OnMouseEnter", onHover)
				itemIcon:SetHandler("OnMouseExit", OnExit)
			else
				local itemLabel = MPP.gear[i].label
				itemLabel:SetText("-/-")
				itemLabel:SetHandler("OnMouseEnter", function() end)
				itemLabel:SetHandler("OnMouseExit", function() end)
				
				local itemIcon = MPP.gear[i].icon
				itemIcon:SetTexture(MP.GEARICONS[gearSlot])
				itemIcon:SetHandler("OnMouseEnter", function() end)
				itemIcon:SetHandler("OnMouseExit", function() end)
			end
		else
			local itemLabel = MPP.gear[i].label
			itemLabel:SetText("-/-")
			itemLabel:SetHandler("OnMouseEnter", function() end)
			itemLabel:SetHandler("OnMouseExit", function() end)
			
			local itemIcon = MPP.gear[i].icon
			itemIcon:SetTexture(MP.GEARICONS[gearSlot])
			itemIcon:SetHandler("OnMouseEnter", function() end)
			itemIcon:SetHandler("OnMouseExit", function() end)
		end
	end
	
	-- SKILLS
	for hotbarCategory = 0, 1 do
		for slotIndex = 3, 8 do
			local abilityId = dataString:sub(ptr, ptr + 5)
			ptr = ptr + 6
			
			local abilityIcon = "/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds"
			if tonumber(abilityId) > 0 then
				abilityIcon = GetAbilityIcon(abilityId)
			end
			local skillControl = MPP.skills[hotbarCategory][slotIndex]
			skillControl:SetTexture(abilityIcon)
			if tonumber(abilityId) > 0 then
				skillControl:SetHandler("OnMouseEnter", function()
					InitializeTooltip(AbilityTooltip, MPP.preview, LEFT, 12, 0, RIGHT)
					AbilityTooltip:SetAbilityId(abilityId)
				end)
				skillControl:SetHandler("OnMouseExit", function()
					ClearTooltip(AbilityTooltip)
				end)
			else
				skillControl:SetHandler("OnMouseEnter", function() end)
				skillControl:SetHandler("OnMouseExit", function() end)
			end
		end
	end
	
	-- CP
	for cpIndex = 1, 12 do
		local cpId = dataString:sub(ptr, ptr + 2)
		ptr = ptr + 3
		
		MPP.cp[cpIndex]:SetText("-/-")
		if tonumber(cpId) > 0 then
			local cpName = zo_strformat("<<C:1>>", GetChampionSkillName(cpId))
			if #cpName > 0 then
				local text = string.format("|c%s%s|r", MP.CPCOLOR[cpIndex], cpName)
				MPP.cp[cpIndex]:SetText(text)
			end
		end
	end
	
	-- FOOD
	local foodId = MP.PREVIEW.FOOD[dataString:sub(ptr, ptr)]
	ptr = ptr + 1
	if tonumber(foodId) > 0 then
		local itemLink = string.format("|H0:item:%d:%d:%d:%d:%d:%d:0:0:0:0:0:0:0:0:0:%d:%d:%d:%d:%d:%d|h|h", foodId, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		MPP.foodLabel:SetText(itemLink)
		
		local foodIcon = MPP.foodIcon
		foodIcon:SetTexture(GetItemLinkIcon(itemLink))
		foodIcon:SetHandler("OnMouseEnter", function()
			InitializeTooltip(ItemTooltip, MPP.preview, LEFT, 12, 0, RIGHT)
			ItemTooltip:SetLink(itemLink)
		end)
		foodIcon:SetHandler("OnMouseExit", function()
			ClearTooltip(ItemTooltip)
		end)
	else
		MPP.foodLabel:SetText("-/-")
		
		local foodIcon = MPP.foodIcon
		foodIcon:SetTexture("/esoui/art/crafting/provisioner_indexicon_meat_disabled.dds")
		foodIcon:SetHandler("OnMouseEnter", function() end)
		foodIcon:SetHandler("OnMouseExit", function() end)
	end
	
	-- TITLE
	local name = setupName:sub(2, #setupName-1)
	MPP.setupName:SetText(name:upper())
	local sender = MPP.GetSenderFromCache(dataString)
	MPP.zoneName:SetText(sender:upper())
	
	MPP.window:SetHidden(false)
end

function MPP.PrintPreviewString(zone, pageId, index)
	local setup = Setup:FromStorage(zone.tag, pageId, index)
	
	local data = {}
	
	for _, gearSlot in ipairs(MP.GEARSLOTS) do
		if gearSlot ~= EQUIP_SLOT_COSTUME then
			local gear = setup:GetGearInSlot(gearSlot) or {id = "0", link = ""}
			
			local link = gear.link
			local itemId = GetItemLinkItemId(link)
			table.insert(data, string.format("%06d", itemId))
			
			if gearSlot ~= EQUIP_SLOT_POISON
				and gearSlot ~= EQUIP_SLOT_BACKUP_POISON then
				
				local traitId = GetItemLinkTraitInfo(link)
				table.insert(data, MP.PREVIEW.TRAITS[traitId])
			end
		end
	end
	
	local skillTable = setup:GetSkills()
	for hotbarCategory = 0, 1 do
		for slotIndex = 3, 8 do
			local abilityId = skillTable[hotbarCategory][slotIndex] or 0
			table.insert(data, string.format("%06d", abilityId))
		end
	end
	
	for slotIndex = 1, 12 do
		local cpId = setup:GetCP()[slotIndex] or 0
		table.insert(data, string.format("%03d", cpId))
	end
	
	table.insert(data, MP.PREVIEW.FOOD[setup:GetFood().id or 0])
	
	local linkData = table.concat(data, "")
	
	local linkText = setup:GetName()
	if #linkText > 20 then
		linkText = linkText:sub(1, 20)
	end
	
	local previewLink = ZO_LinkHandler_CreateLink(linkText, nil, MP.LINK_TYPES.PREVIEW, linkData)
	CHAT_SYSTEM.textEntry:InsertLink(previewLink)
end

function MPP.OnChatMessage(_, channelType, fromName, text, isCustomerService, fromDisplayName)
	local style, data, name = string.match(text, "||H(%d):" .. MP.LINK_TYPES.PREVIEW .. ":(.-)||h(.-)||h")
	if data and name then
		table.insert(MPP.chatCache, {
			data = data,
			sender = fromDisplayName:sub(2, #fromDisplayName),
		})
		if #MPP.chatCache > 5 then
			table.remove(MPP.chatCache, 1)
		end
	end
end

function MPP.GetSenderFromCache(dataString)
	for _, entry in ipairs(MPP.chatCache) do
		if entry.data == dataString then
			return entry.sender
		end
	end
	return ""
end

function MPP.HandleClickEvent(rawLink, mouseButton, linkText, linkStyle, linkType, dataString)
	if linkType ~= MP.LINK_TYPES.PREVIEW then return end
	
	if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
		MPP.ShowPreviewFromString(dataString, linkText)
	elseif mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
		ClearMenu()
		AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function()
			CHAT_SYSTEM.textEntry:InsertLink(rawLink)
		end, MENU_ADD_OPTION_LABEL)
		AddMenuItem(GetString(MP_LINK_IMPORT), function()
			d("soon(tm)")
		end, MENU_ADD_OPTION_LABEL)
		ShowMenu(nil, 2, MENU_TYPE_COMBO_BOX)
	end
	
	return true
end
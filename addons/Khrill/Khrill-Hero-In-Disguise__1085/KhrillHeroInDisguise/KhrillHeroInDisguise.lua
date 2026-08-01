------------------------------------------
--           Hero In Disguise           --
--              by Khrill               --
--                                      --
--               v 1.4.0                --
------------------------------------------

local KHID = {}
KHID.name  = "KhrillHeroInDisguise"
KHID.version = "1.4.0"

KHID.defaults = {
	enable	= true,
	anchor	= {TOP, TOP, -290, 75},
	hideEmpty = false,
	showConsumable = false,
	maxCol = 6,
	maxRow = 2,
	fixedSize = false,
	tooltipPosition = BOTTOMLEFT,
	newItem = true,
	itemIcon = true,
	itemIconColor = {r=1, g=0.414, b=0},
	sysmessage = false,
}
KHID.accountDefaults = {
	ignoreList = {}, --[itemInstanceId] = false
}
KHID.settings = KHID.defaults
KHID.accountSettings = KHID.accountDefaults

KHID.langString = nil
KHID.myCharacterName = nil
KHID.activate = false
KHID.selectedPanel = nil
KHID.selectedCat = 1
KHID.nbPanel = 0
KHID.sliderOffset = 1
KHID.onBank = false
KHID.showBank = false
KHID.Tooltip = nil
KHID.Tabard = nil
KHID.activeCooldown = nil

KHID.CatPanels = { --real values in initCat function
	[1] = { -- disguise
		name = GetString(SI_COLLECTIBLECATEGORYTYPE4),
		icon = "/esoui/art/treeicons/store_indexicon_costumes_up.dds",
		bagType = {ITEMTYPE_DISGUISE, ITEMTYPE_TABARD},
		collectionCat = 2,
		collectionType = {COLLECTIBLE_CATEGORY_TYPE_COSTUME, COLLECTIBLE_CATEGORY_TYPE_HAT, COLLECTIBLE_CATEGORY_TYPE_POLYMORPH, COLLECTIBLE_CATEGORY_TYPE_SKIN},
	},
	[2] = { -- mementos/trophy
		name = GetString(SI_COLLECTIBLECATEGORYTYPE5),
		icon = "/esoui/art/treeicons/store_indexicon_trophy_up.dds",
		bagType = {ITEMTYPE_TROPHY},
		collectionCat = 5,
		collectionType = {COLLECTIBLE_CATEGORY_TYPE_TROPHY},
	},
	[3] = { -- pet
		name = GetString(SI_COLLECTIBLECATEGORYTYPE3),
		icon = "/esoui/art/treeicons/store_indexicon_vanitypets_up.dds",
		bagType = {},
		collectionCat = 3,
		collectionType = {COLLECTIBLE_CATEGORY_TYPE_VANITY_PET},
	},
	[4] = { -- mount
		name = GetString(SI_COLLECTIBLECATEGORYTYPE2),
		icon="/esoui/art/treeicons/store_indexicon_mounts_up.dds",
		bagType = {},
		collectionCat = 4,
		collectionType = {COLLECTIBLE_CATEGORY_TYPE_MOUNT},
	},
	[5] = { -- assistant
		name = GetString(SI_COLLECTIBLECATEGORYTYPE8),
		icon = "/esoui/art/treeicons/store_indexicon_novelties_up.dds",  
		bagType = {},
		collectionCat = 8,
		collectionType = {COLLECTIBLE_CATEGORY_TYPE_ASSISTANT},
	},
}
KHID.Collection = {}
--[[KHID.Collection = {
--		[collectibleId] = {
--			type = COLLECTIBLE_CATEGORY_TYPE_COSTUME,
--			name = name,
--			icon = icon,
--			link = itemLink,
--			info = hint,
--			inBank = false,
--			inBag = false,
--		}
--		[<slotId>.<bagId>] = {
--			type = ITEMTYPE_DISGUISE, ITEMTYPE_TABARD
--			name = name,
--			icon = icon,
--			link = itemLink,
--			info = creator,
--			inBank = true if bagId = bank
--			inBag = true,
--		}
--	}
]]

local COLOR_KHRILLSELECT = "FF6A00" -- orange ^^
local COLOR_NOCOLOR = "FFFFFF" --transparent
local COLOR_DISABLED = "303030"  -- gray
local COLOR_TITLE = "FF0000" --red
local COLOR_TEXT = "A0A0A0"  --gray
local COLOR_ICON = "C5C29E" --COLOR_NOCOLOR --"C5C29E" --sand

local TEXTURE_SLIDER = 	"/esoui/art/miscellaneous/scrollbox_elevator.dds"
local TEXTURE_TITLEICON = "/esoui/art/icons/placeholder/icon_spell_rest_convalescence01.dds"
local TEXTURE_BANK = "/esoui/art/icons/mapkey/mapkey_bank.dds"

local SOUND_ERROR = SOUNDS.ABILITY_SLOT_CLEARED

local CELLSPACING = 14
local CELLBORDER = 10

local function HexToRGBA( hex )
	if string.len(hex) == 6 then hex = hex.."FF" end
    local rhex, ghex, bhex, ahex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6), string.sub(hex, 7, 8)
    return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255
end
local function RGBAToHex( r, g, b, a )
	if a == nil then a = 1 end
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.upper(string.format("%02x%02x%02x%02x", r * 255, g * 255, b * 255, a * 255))
end
local function isControlColorEgalTo(control, hexColor)
	return string.sub(RGBAToHex(control:GetColor()), 1, 6) == string.sub(hexColor, 1, 6)
end
local function GetItemLinkID(link)
	if type(link) == "string" then
		local itemId = link:match("|H.-:.-:(.-):")
		if itemId ~= nil then
			return tonumber(itemId)
		end
	end
	return nil
end
local function GetItemLinkItemLevel(itemLink)
	local level = GetItemLinkRequiredLevel(itemLink)
	if level == 50 then
		level = level + GetItemLinkRequiredVeteranRank(itemLink)
	end
	return level
end
local function getComputeId(bagId, slotId)
	if bagId == nil and slotId == nil then return nil end
	return string.format("%.1f", tonumber(slotId) + tonumber(bagId/10))
end
local function getIdFromComputeId(computeId)
	if computeId == nil then return nil end
	local slotId = math.floor(computeId)
	local bagId = computeId*10 - slotId*10
	return bagId, slotId
end
local function SignItemId(itemId)
	local SIGNED_INT_MAX = 2^32 / 2 - 1
	local INT_MAX = 2^32
	if(itemId and itemId > SIGNED_INT_MAX) then
		itemId = itemId - INT_MAX
	end
	return itemId
end
local function getKeyByValue(t, value)
	for k,v in pairs(t) do
		if v==value then return k end
	end
	return nil
end

local function addButton(parent, name, callbackFunction, text, font, tooltipText, tooltipAlign, textureNormal, textureMouseOver, textureClicked, color, width, height, left, top, alignValue, alignControl, alignControlValue, hideButton)
	--Add a button to an existing parent control (original code by Votan)
--	d("addButton "..name..","..tostring(hideButton))
	--Abort needed?
	if  (parent == nil or name == nil or callbackFunction == nil
		or width <= 0 or height <= 0 )
		and (textureNormal == nil or text == nil) then
			return nil
	end
	local button
    --Does the button already exist?
    button = WINDOW_MANAGER:GetControlByName(name, "")
    if button == nil then
        --Button does not exist yet and it should be hidden? Abort here!
        if hideButton == true then return nil end
        --Create the button control at the parent
        button = WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON)
    end
    --Button was created?
    if button ~= nil then
        -- -- Button should be hidden?
        -- if hideButton == false then
			local highlightColor = nil
			local isColorInitiated = false
			local defaultColor = color or COLOR_ICON
			button.color = defaultColor
            --Set the button's size
            button:SetDimensions(width, height)
            --Align the button
            if alignControl == nil then
                alignControl = parent
            end
            --SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
			if alignValue == nil then alignValue = TOPLEFT end
			if alignControlValue == nil then alignControlValue = TOPLEFT end
			button:ClearAnchors()
            button:SetAnchor(alignValue, alignControl, alignControlValue, left, top)
            --Texture or text?
            if (text ~= nil) then
                --Text
				button.type = "Label"
				highlightColor = COLOR_KHRILLSELECT
				local label
                 --Check if label exists
                label = WINDOW_MANAGER:GetControlByName(name .. "Label", "")
                if label == nil then
                    --Create the label for the button to hold the text
                    label = WINDOW_MANAGER:CreateControl(name .. "Label", button, CT_LABEL)
                end
				label:SetAnchorFill()
				label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
				label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
                --Set the label's font
                if font == nil then
                    label:SetFont("ZoFontGameSmall")
                else
                    label:SetFont(font)
                end
                --Set the button's text
                label:SetText(text)
				--Set default color
				label.color = defaultColor
				label:SetColor(HexToRGBA(defaultColor))
				label:SetHidden(false)
            else
                --Texture
				button.type = "Texture"
                local texture
                 --Check if texture exists
                texture = WINDOW_MANAGER:GetControlByName(name .. "Texture", "")
                if texture == nil then
                    --Create the texture for the button to hold the image
                    texture = WINDOW_MANAGER:CreateControl(name .. "Texture", button, CT_TEXTURE)
                end
                texture:SetAnchorFill()
                --Set the texture for normale state now
                texture:SetTexture(textureNormal)
                --Do we have seperate textures for the button states?
				if textureMouseOver == nil and textureClicked == nil then
					highlightColor = COLOR_KHRILLSELECT
					isColorInitiated = (isControlColorEgalTo(texture, highlightColor))
				end
				texture.color = defaultColor
				texture:SetColor(HexToRGBA(defaultColor))
                button.upTexture      = textureNormal
                button.downTexture    = textureMouseOver or textureNormal
                button.clickedTexture = textureClicked or textureNormal
            end
			button.highlightColor = highlightColor
			button.isColorInitiated = isColorInitiated
            if tooltipAlign == nil then tooltipAlign = TOP end
            --Set a tooltip?
            if tooltipText ~= nil then
                if button:GetHandler("OnMouseEnter") == nil then button:SetHandler("OnMouseEnter", function(self)
                    if self.downTexture then self:GetNamedChild("Texture"):SetTexture(self.downTexture) end
					if self.highlightColor ~= nil and not self.isColorInitiated then self:GetChild(1):SetColor(HexToRGBA(self.highlightColor)) end
                    ZO_Tooltips_ShowTextTooltip(self, tooltipAlign, tooltipText)
					end)
				end
                if button:GetHandler("OnMouseExit") == nil then button:SetHandler("OnMouseExit", function(self)
                    if self.upTexture then self:GetNamedChild("Texture"):SetTexture(self.upTexture) end
					if self.highlightColor ~= nil and not self.isColorInitiated then self:GetChild(1):SetColor(HexToRGBA(self.color)) end
                    ZO_Tooltips_HideTextTooltip()
					end)
				end
            else
                if button:GetHandler("OnMouseEnter") == nil then button:SetHandler("OnMouseEnter", function(self)
                    if self.downTexture then self:GetNamedChild("Texture"):SetTexture(self.downTexture) end
 					if self.highlightColor ~= nil and not self.isColorInitiated then self:GetChild(1):SetColor(HexToRGBA(self.highlightColor)) end
					end)
				end
                if button:GetHandler("OnMouseExit") == nil then button:SetHandler("OnMouseExit", function(self)
                    if self.upTexture then self:GetNamedChild("Texture"):SetTexture(self.upTexture) end
 					if self.highlightColor ~= nil and not self.isColorInitiated then self:GetChild(1):SetColor(HexToRGBA(self.color)) end
					end)
				end
            end
            --Set the callback function of the button
            if button:GetHandler("OnClicked") == nil then button:SetHandler("OnClicked", function(butn)
				if butn.highlightColor ~= nil and not butn.isColorInitiated then butn:GetChild(1):SetColor(HexToRGBA(butn.color)) end
				butn.isColorInitiated = not(butn.isColorInitiated)
                callbackFunction()
				end)
			end
			if button:GetHandler("OnMouseDown") == nil then button:SetHandler("OnMouseDown", function(butn, ctrl, alt, shift, command)
				if butn.clickedTexture then butn:GetNamedChild("Texture"):SetTexture(butn.clickedTexture) end
				end)
			end
			--Show the button and make it react on mouse input
			button:SetHidden(hideButton) --false)
			button:SetMouseEnabled(not hideButton) --true)
			--Return the button control
			return button
		-- else
			-- --Hide the button and make it not reacting on mouse input
			-- button:SetHidden(true)
			-- button:SetMouseEnabled(false)
		-- end
	else
		return nil
	end
end


-- // **********
-- //  DISGUISE
-- // **********
function KHID:ScanBag(bagId)
	--Scan bags to find disguises
--d("--ScanBag "..tostring(bagId))
	if bagId == nil then
		local maxItem = 0
		maxItem = maxItem + KHID:ScanBag(BAG_WORN)
		maxItem = maxItem + KHID:ScanBag(BAG_BACKPACK)
		maxItem = maxItem + KHID:ScanBag(BAG_BANK)
		return maxItem
	end

	if bagId == BAG_BANK and not KHID.showBank then return 0 end
	
	local equipIcon, slotHasItem, _, _, _, _ = GetEquippedItemInfo(EQUIP_SLOT_COSTUME)
	local bagSlots = GetBagSize(bagId)
	local found = 0
	for slotIndex = 0, bagSlots do
		local itemType = GetItemType(bagId, slotIndex)
		local consumable = IsItemConsumable(bagId, slotIndex)
		if (KHID.settings.showConsumable or (not KHID.settings.showConsumable and not consumable))
			and getKeyByValue(KHID.CatPanels[KHID.selectedCat].bagType, itemType) ~= nil
			and KHID.accountSettings.ignoreList[SignItemId(GetItemInstanceId(bagId, slotIndex))] == nil
		then
			local itemLink = GetItemLink(bagId, slotIndex)
			local itemName = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemName(bagId, slotIndex))
			local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyle, quality  = GetItemInfo(bagId, slotIndex)	
			local creatorName = GetItemCreatorName(bagId, slotIndex)
			found = found +1
			KHID.Collection[getComputeId(bagId, slotIndex)] = {type=itemType, name=itemName, icon=icon, link=itemLink, info=creatorName, inBank=(bagId==BAG_BANK), inBag = true}
			-- active ? -> selected
			if slotHasItem and bagId == BAG_WORN and equipIcon == icon then KHID.selectedPanel = getComputeId(bagId, slotIndex) end
		end
	end
	return found
end
function KHID:ScanCollection()
	-- collecions
--d("--ScanCollection "..KHID.selectedCat)
--[[CollectibleCategoryType
--##COLLECTIBLE_CATEGORY_TYPE_COSTUME	4
--##COLLECTIBLE_CATEGORY_TYPE_DLC		1
--##COLLECTIBLE_CATEGORY_TYPE_INVALID	0
--##COLLECTIBLE_CATEGORY_TYPE_MOUNT		2
--##COLLECTIBLE_CATEGORY_TYPE_TROPHY 	5
--##COLLECTIBLE_CATEGORY_TYPE_VANITY_PET 3
--##COLLECTIBLE_CATEGORY_TYPE_ASSISTANT 8  
]]
	local categoryId = KHID.CatPanels[KHID.selectedCat].collectionCat --2 disguise 3 pet 4 mount 5 trophy
	if categoryId == nil then
		return 0
	else
		local found = 0
		for categoryId = 1, GetNumCollectibleCategories() do
			local categoryName, numSubCategories, numCollectibles, unlockedCollectibles, totalCollectibles, hidesLocked  = GetCollectibleCategoryInfo(categoryId)
--		d(GetCollectibleCategoryInfo(categoryId))
			if numSubCategories > 0 then
				for subCategoryIndex=1, numSubCategories do
					--scan subcategory
					local subCategoryName, subNumCollectibles, subUnlockedCollectibles, subTotalCollectibles = GetCollectibleSubCategoryInfo(categoryId, subCategoryIndex)
--		d(GetCollectibleSubCategoryInfo(categoryId, subCategoryIndex))
					for i=1, subNumCollectibles do
						local collectibleId = GetCollectibleId(categoryId, subCategoryIndex, i)
--		d(GetCollectibleInfo(collectibleId))
						local name, description, icon, lockedIcon, unlocked, purchasable, isActive, categoryType, hint = GetCollectibleInfo(collectibleId)
						if unlocked and getKeyByValue(KHID.CatPanels[KHID.selectedCat].collectionType, categoryType) ~= nil then
							found = found +1
							KHID.Collection[collectibleId] = {type=categoryType, name=name, icon=icon, link=GetCollectibleLink(collectibleId, LINK_STYLE_DEFAULT), info=hint, inBank=false, inBag = false}
							-- active ? -> selected
							if isActive then KHID.selectedPanel = collectibleId end
						end
					end
				end
			end
			for i=1, numCollectibles do
				local collectibleId = GetCollectibleId(categoryId, nil, i)
		--d(GetCollectibleInfo(collectibleId))
				local name, description, icon, lockedIcon, unlocked, purchasable, isActive, categoryType, hint = GetCollectibleInfo(collectibleId)
				if unlocked and getKeyByValue(KHID.CatPanels[KHID.selectedCat].collectionType, categoryType) ~= nil then
					found = found +1
					KHID.Collection[collectibleId] = {type=categoryType, name=name, icon=icon, link=GetCollectibleLink(collectibleId, LINK_STYLE_DEFAULT), info=hint, inBank=false, inBag = false}
					-- active ? -> selected
					if isActive then KHID.selectedPanel = collectibleId end
				end
			end
		end
	--d("=> "..found)
		return found
	end	
end
function KHID:ShowDisguises()
--d("--ShowDisguises")
	KHID:resetPanels()
	local count = 0
	count = count + KHID:ScanBag()
	count = count + KHID:ScanCollection()
	if KHID.settings.sysmessage then
		local pattern = "|c"..COLOR_KHRILLSELECT.."["..KHID.name.."]|r => <<1>> items found"
		CHAT_SYSTEM:AddMessage(zo_strformat(pattern, count))
	end
	if count == 0 and KHID.settings.hideEmpty then
		KHID_ToggleUI()
--		KHID:CloseUI()
		return
	end

	--sort by name + id (Tabard as same name and type)
	local tempOrder = {}
	for disguiseId, Disguise in pairs(KHID.Collection) do
		if Disguise ~= nil then
			if not Disguise.inBank or KHID.showBank then table.insert(tempOrder, Disguise.name..disguiseId) end
		end
	end
	table.sort(tempOrder)
--	d(tempOrder)
	for _, compareName in pairs(tempOrder) do
		--add panel for each disguise founded
		for disguiseId, Disguise in pairs(KHID.Collection) do
			if compareName == Disguise.name..disguiseId then KHID:addPanel(disguiseId) end
		end
	end
	--adjust size
	if KHID.settings.fixedSize then
		KHIDUI:SetDimensions(CELLBORDER*2+KHID.settings.maxCol*(140+CELLSPACING)-CELLSPACING-1,CELLBORDER*2+KHID.settings.maxRow*(90+CELLSPACING)-CELLSPACING-1)	
	elseif KHID.nbPanel == 0 then
		KHIDUI:SetDimensions(CELLBORDER*2+3*(140+CELLSPACING)-CELLSPACING-1,CELLBORDER*2+90)
	elseif KHID.nbPanel == 1 then
		KHIDUI:SetDimensions(CELLBORDER*2+140,CELLBORDER*2+90)
	elseif KHID.nbPanel <= KHID.settings.maxCol then
		KHIDUI:SetDimensions(CELLBORDER*2+KHID.nbPanel*(140+CELLSPACING)-CELLSPACING-1,CELLBORDER*2+90)
	else
		local nbRow = tonumber(math.ceil(KHID.nbPanel/KHID.settings.maxCol))
		if nbRow > KHID.settings.maxRow then nbRow = KHID.settings.maxRow end
		KHIDUI:SetDimensions(CELLBORDER*2+KHID.settings.maxCol*(140+CELLSPACING)-CELLSPACING-1,CELLBORDER*2+nbRow*(90+CELLSPACING)-CELLSPACING-1)
	end
	KHID:refreshSlider()
	KHID:showTitle(KHID.nbPanel == 0)
end

local function updateCooldown(panelId, remaining, duration)
--d("--updateCooldown "..panelId.." - "..tostring(remaining)..", "..tostring(duration))
	local NO_LEADING_EDGE = false
	local inCooldown = (remaining > 0) and (duration > 0)
	local cooldownControl = GetControl("KHID_Panel_"..tostring(panelId)):GetNamedChild("Cooldown")
	
	cooldownControl:SetHidden(not inCooldown)
	if inCooldown then
		if KHID.activeCooldown ~= nil then
			cooldownControl = GetControl("KHID_Panel_"..tostring(KHID.activeCooldown)):GetNamedChild("Cooldown")
			cooldownControl:StartCooldown(remaining, duration, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, NO_LEADING_EDGE)
			return true
		else
			cooldownControl:StartCooldown(remaining, duration, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, NO_LEADING_EDGE)
			KHID.activeCooldown = panelId
			return false
		end
	else
		cooldownControl:ResetCooldown()
		KHID.activeCooldown = nil
		return false
	end
--	return inCooldown
end
local function equipDisguise(panelId, state)
	if KHID.Collection[panelId] == nil then return end
--d("--equipDisguise "..panelId.." - "..KHID.Collection[panelId].type.." - "..tostring(KHID.selectedPanel)..", "..tostring(state))
	
	if not(KHID.Collection[panelId].inBag) and
	(KHID.Collection[panelId].type == COLLECTIBLE_CATEGORY_TYPE_COSTUME
		or KHID.Collection[panelId].type == COLLECTIBLE_CATEGORY_TYPE_HAT
		or KHID.Collection[panelId].type == COLLECTIBLE_CATEGORY_TYPE_POLYMORPH
		or KHID.Collection[panelId].type == COLLECTIBLE_CATEGORY_TYPE_SKIN
	or KHID.Collection[panelId].type == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET
	or KHID.Collection[panelId].type == COLLECTIBLE_CATEGORY_TYPE_MOUNT
	or KHID.Collection[panelId].type == COLLECTIBLE_CATEGORY_TYPE_TROPHY
	or KHID.Collection[panelId].type == COLLECTIBLE_CATEGORY_TYPE_ASSISTANT)
	then
		-- collectibleId
		local remaining, duration = GetCollectibleCooldownAndDuration(panelId)
		if state then
			if updateCooldown(panelId, remaining, duration) then
--				if KHID.settings.sysmessage then
					local pattern = "|c"..COLOR_KHRILLSELECT.."["..KHID.name.."]|r  Cooldown = <<1>>s"
					CHAT_SYSTEM:AddMessage(zo_strformat(pattern, remaining/1000))
--				end
				PlaySound(SOUND_ERROR) --error
			else
				UseCollectible(panelId)
			end
		else
			if KHID.Collection[panelId].type == COLLECTIBLE_CATEGORY_TYPE_COSTUME
			or KHID.Collection[panelId].type == COLLECTIBLE_CATEGORY_TYPE_HAT
			or KHID.Collection[panelId].type == COLLECTIBLE_CATEGORY_TYPE_POLYMORPH
			or KHID.Collection[panelId].type == COLLECTIBLE_CATEGORY_TYPE_SKIN
			or KHID.Collection[panelId].type == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET
			then --unequip
				UseCollectible(panelId)
			else --update cooldown
				updateCooldown(panelId, remaining, duration)
			end
		end	
	elseif KHID.Collection[panelId].type == ITEMTYPE_DISGUISE or KHID.Collection[panelId].type == ITEMTYPE_TABARD then
		-- disguise&tabard => equip in SLOT_COSTUME
		if state then
			-- bagId, slotId (compute)
			local bagId, slotId = getIdFromComputeId(panelId)
			local usable, onlyFromActionSlot = IsItemUsable(bagId, slotId)
			EquipItem(bagId, slotId, EQUIP_SLOT_COSTUME)
		else
			UnequipItem(EQUIP_SLOT_COSTUME)
		end
		if KHID.Collection[panelId].type == ITEMTYPE_TABARD then
			KHID.Collection[panelId] = nil -- Tabard disappears or appears in backbag (new item)
		end
	elseif KHID.Collection[panelId].type == ITEMTYPE_TROPHY then
		-- trophy => use item
		if state then
			-- bagId, slotId (compute)
			local bagId, slotId = getIdFromComputeId(panelId)
			local usable, onlyFromActionSlot = IsItemUsable(bagId, slotId)
		    local remaining, duration = GetItemCooldownInfo(bagId, slotId)
			updateCooldown(panelId, remaining, duration)
			
			if usable and not onlyFromActionSlot and remaining == 0 then
				CallSecureProtected("UseItem", bagId, slotId)
			else
				if remaining > 0 then --and KHID.settings.sysmessage then
					local pattern = "|c"..COLOR_KHRILLSELECT.."["..KHID.name.."]|r  Cooldown = <<1>>s"
					CHAT_SYSTEM:AddMessage(zo_strformat(pattern, remaining/1000))
				end
				PlaySound(SOUND_ERROR) --error
			end
		else
			-- nothing
		end	
	end
end


-- // **********
-- //  UI PANEL
-- // **********
function KHID:addPanel(panelId)
	-- add a disguise
--d("--addPanel:"..panelId..", "..tostring(KHID.selectedPanel))
	local panelControl = GetControl("KHID_Panel_"..tostring(panelId))
	if panelControl == nil then
		panelControl = CreateControlFromVirtual("KHID_Panel_", KHIDUI, "KHID_Panel", tostring(panelId))
		-- place text
		panelControl.label = panelControl:GetNamedChild("Label")
		-- icons
		panelControl.icon = panelControl:GetNamedChild("Icon")
		panelControl.bank = panelControl:GetNamedChild("Bank")
		panelControl.bank:SetTexture(TEXTURE_BANK)
--		panelControl.bank:SetColor(HexToRGBA(COLOR_DISABLED))
	end
	
	if KHID.Collection[panelId] == nil then
		-- no record (empty)
		panelControl:SetHidden(true)
		panelControl.empty = true
		return nil --panelControl
	end
	if not KHID.Collection[panelId].inBank then
		if panelControl:GetHandler("OnMouseDown") == nil then panelControl:SetHandler("OnMouseDown", function(butn, ctrl, alt, shift, command)
				KHID_OnPanelSelect(panelId)
			end)
		end
	end
	if panelControl:GetHandler("OnMouseEnter") == nil then panelControl:SetHandler("OnMouseEnter", function(self)
				KHID:showTooltip(KHID.Collection[panelId], true)
			end)
	end
	if panelControl:GetHandler("OnMouseExit") == nil then panelControl:SetHandler("OnMouseExit", function(self)
				KHID:showTooltip(nil, false)
			end)
	end
--	panelControl:SetHandler("OnMouseWheel", function(self, delta) KHID:OnMouseWheel(delta) end)

	panelControl:ClearAnchors()
	if KHID.nbPanel < KHID.settings.maxCol then
		panelControl:SetAnchor(TOPLEFT, KHIDUI, TOPLEFT, CELLBORDER+KHID.nbPanel*(panelControl:GetWidth()+CELLSPACING), CELLBORDER)
	else
		local nbRow = tonumber(math.floor(KHID.nbPanel/KHID.settings.maxCol))
		panelControl:SetAnchor(TOPLEFT, KHIDUI, TOPLEFT, CELLBORDER+(KHID.nbPanel-KHID.settings.maxCol*nbRow)*(panelControl:GetWidth()+CELLSPACING), CELLBORDER+nbRow*(panelControl:GetHeight()+CELLSPACING))
		if KHID.selectedPanel == panelId then 
			if nbRow <= KHID.settings.maxRow then KHID.sliderOffset = 1
			else KHID.sliderOffset = tonumber(nbRow+1-KHID.settings.maxRow)
			end
		end
	end
	panelControl.label:SetText(KHID.Collection[panelId].name)
	panelControl.label:SetColor(HexToRGBA(COLOR_TEXT))
	panelControl.icon:SetTexture(KHID.Collection[panelId].icon)
	if KHID.Collection[panelId].inBank then
		panelControl.icon:SetColor(HexToRGBA(COLOR_DISABLED))
		panelControl.bank:SetHidden(false)
	else
		panelControl.icon:SetColor(HexToRGBA(COLOR_NOCOLOR))
		panelControl.bank:SetHidden(true)
	end
	panelControl:GetNamedChild("BG"):SetEdgeColor(HexToRGBA(COLOR_DISABLED))
	panelControl.empty = false
	KHID.nbPanel = KHID.nbPanel +1
	if KHID.selectedPanel == panelId then KHID_OnPanelSelect() end

	panelControl:SetHidden(false)
	return panelControl
end
function KHID:resetPanels()
--d("--resetPanels")
	for i=1,KHIDUI:GetNumChildren() do
		local controlName = KHIDUI:GetChild(i):GetName()
		if string.find(controlName, "KHID_Panel_") ~= nil then -- hide panel
			 KHIDUI:GetChild(i):SetHidden(true)
		end
	end
	-- for panelId=1,KHID.nbPanel do
		-- local panelControl = GetControl("KHID_Panel_"..tostring(panelId))
		-- if panelControl ~= nil then	panelControl:SetHidden(true) end
	-- end
	KHID.Collection = {} --reinit
	KHID.nbPanel = 0
--	KHID.sliderOffset = 1
end
function KHID:updatePanels()
	-- update printed panels with scroll slider position
--	d("updatePanels: offset="..KHID.sliderOffset)
	local tempOrder = {}
	for disguiseId, Disguise in pairs(KHID.Collection) do
		if Disguise ~= nil then table.insert(tempOrder, Disguise.name..disguiseId) end
	end
	table.sort(tempOrder)
	local count = 0
	for _, compareName in pairs(tempOrder) do
		for disguiseId, Disguise in pairs(KHID.Collection) do
			if compareName == Disguise.name..disguiseId then
				local panelControl = GetControl("KHID_Panel_"..tostring(disguiseId))
				local nbRow = tonumber(math.floor(count/KHID.settings.maxCol))
				if nbRow >= KHID.sliderOffset-1 and nbRow <= KHID.settings.maxRow+KHID.sliderOffset-2 then
					panelControl:ClearAnchors()
					if count < KHID.settings.maxCol then
						panelControl:SetAnchor(TOPLEFT, KHIDUI, TOPLEFT, CELLBORDER+count*(panelControl:GetWidth()+CELLSPACING), CELLBORDER)
					else
						panelControl:SetAnchor(TOPLEFT, KHIDUI, TOPLEFT, CELLBORDER+(count-KHID.settings.maxCol*nbRow)*(panelControl:GetWidth()+CELLSPACING), CELLBORDER+(nbRow-KHID.sliderOffset+1)*(panelControl:GetHeight()+CELLSPACING))
					end
					panelControl:SetHidden(false)
				else
					panelControl:SetHidden(true)
				end
				count = count +1
			end
		end
	end
end
function KHID_OnPanelSelect(panelId)
--d("--OnPanelSelect: "..tostring(panelId)..","..tostring(KHID.selectedCat).."-"..tostring(KHID.selectedPanel))
	if panelId == nil then --at start
		local panelControl = GetControl("KHID_Panel_"..tostring(KHID.selectedPanel))
		if panelControl == nil then return end
		-- select
		panelControl:GetNamedChild("BG"):SetEdgeColor(HexToRGBA(COLOR_KHRILLSELECT))
		panelControl.label:SetColor(HexToRGBA(COLOR_KHRILLSELECT))
	else --onclick
		local panelControl = GetControl("KHID_Panel_"..tostring(panelId))
		if panelControl == nil then return end

		if KHID.selectedPanel == panelId then --deselect
			panelControl:GetNamedChild("BG"):SetEdgeColor(HexToRGBA(COLOR_DISABLED))
			if panelControl.empty then
				panelControl.label:SetColor(HexToRGBA(COLOR_DISABLED))
			else
				panelControl.label:SetColor(HexToRGBA(COLOR_TEXT))
			end
			KHID.selectedPanel = nil
			equipDisguise(panelId, false)
		else
			-- deselect old
			if KHID.selectedPanel ~= nil then KHID_OnPanelSelect(KHID.selectedPanel) end
			-- select new
			panelControl:GetNamedChild("BG"):SetEdgeColor(HexToRGBA(COLOR_KHRILLSELECT))
			panelControl.label:SetColor(HexToRGBA(COLOR_KHRILLSELECT))
			-- equip disguise/item
			KHID.selectedPanel = panelId
			equipDisguise(panelId, true)
			-- if trophy -> no selection (use item)
			if KHID.selectedCat == 2 then
				-- deselect after 1s
				zo_callLater(function() KHID_OnPanelSelect(KHID.selectedPanel) end,1000)
			end
		end
	end
--	d("--end OnPanelSelect: "..tostring(panelId)..","..tostring(KHID.selectedCat).."-"..tostring(KHID.selectedPanel))
end

function KHID:OpenUI()
--d("--OpenUI")
	KHID:registerEvents(true)
	KHIDUI:SetHidden(false)
	KHID:ShowDisguises()
end
function KHID:CloseUI()
--d("--CloseUI")
	KHID:registerEvents(false)
	KHIDUITitle:SetHidden(true)
	KHIDUI:SetHidden(true)
end
function KHID:showTitle(state)
	KHIDUIIcon:SetHidden(not state)
	KHIDUILabel:SetHidden(not state)
	KHIDUITitle:SetHidden(state)
end

function KHID:showTooltip(CollectionItem, state)
	local tooltip = KHID.Tooltip
	local link = nil
	if CollectionItem ~= nil then link = CollectionItem.link end
	if state then
		-- Tooltip
		if link ~= nil then
--d(link..":")
--d(ZO_LinkHandler_ParseLink(link))
			InitializeTooltip(tooltip)
			tooltip:SetLink(link)
			if CollectionItem.info ~= "" then
				--ZO_Tooltip_AddDivider(tooltip)
				if CollectionItem.type == ITEMTYPE_TABARD then
					tooltip:AddLine(zo_strformat(SI_ITEM_FORMAT_STR_TABARD, CollectionItem.info), "ZoFontWinH5", 1,1,1, CENTER, MODIFY_TEXT_TYPE_NONE,TEXT_ALIGN_CENTER,true)
				else
					tooltip:AddLine(zo_strformat(SI_ITEM_FORMAT_STR_TYPE_PLUS_EXTRA_INFO, CollectionItem.info), "ZoFontWinH5", 1,1,1, CENTER, MODIFY_TEXT_TYPE_NONE,TEXT_ALIGN_CENTER,true)
				end
			end
		else
			state = false
		end
	end
	KHID:tooltipPosition()
	tooltip:SetHidden(not state)
end
function KHID:tooltipPosition()
	local tooltip = KHID.Tooltip
	local getAnchor = {
		[LEFT] = {point=RIGHT, x=-10, y=0},
		[RIGHT] = {point=LEFT, x=14, y=0},
		[TOPLEFT] = {point=TOPRIGHT, x=-10, y=0},
		[TOP] = {point=BOTTOM, x=0, y=-10},
		[TOPRIGHT] = {point=TOPLEFT, x=14, y=0},
		[BOTTOMLEFT] = {point=TOPLEFT, x=0, y=30},
		[BOTTOM] = {point=TOP, x=0, y=30},
		[BOTTOMRIGHT] = {point=TOPRIGHT, x=0, y=30},
	}
	if type(KHID.settings.tooltipPosition) == "string" then KHID.settings.tooltipPosition = KHID.defaults.tooltipPosition end
	local tipAnchor = getAnchor[KHID.settings.tooltipPosition]
    tooltip:ClearAnchors()
    tooltip:SetAnchor(tipAnchor.point, KHIDUI, KHID.settings.tooltipPosition, tipAnchor.x, tipAnchor.y)
end

function KHID:OnSliderMove(value)
--d("--OnSliderMove:"..value)
	KHID.sliderOffset = value
	KHID:updatePanels()
end
function KHID:OnMouseWheel(delta)
--d("--OnMouseWheel:"..delta)
	local offset = KHID.sliderOffset
	local nbRow = tonumber(math.ceil(KHID.nbPanel/KHID.settings.maxCol))
	offset = offset - delta
	if (offset > nbRow-KHID.settings.maxRow) then offset = nbRow-KHID.settings.maxRow+1 end
	if (offset < 1) then offset = 1 end
	
	KHID.sliderOffset = offset
	KHIDUISlider:SetValue(offset)
	KHID:updatePanels()
end
function KHID:refreshSlider()
	--scroll slider
	local nbRow = tonumber(math.ceil(KHID.nbPanel/KHID.settings.maxCol))
	KHIDUISlider:SetMinMax(1,nbRow-KHID.settings.maxRow+1)
--	KHIDUISlider:SetValue(1)
	KHIDUISlider:SetValue(KHID.sliderOffset)
	KHIDUISlider:SetHidden(nbRow <= KHID.settings.maxRow)
	KHID:updatePanels()
end


-- // **********
-- //  CAT ICON
-- // **********
local function GetInfoFromRowControl(rowControl)
	-- (from ITEMSAVER) --
	--gotta do this in case deconstruction...
	local dataEntry = rowControl.dataEntry
	local bagId, slotIndex 

	--case to handle equiped items
	if(not dataEntry) then
		bagId = rowControl.bagId
		slotIndex = rowControl.slotIndex
	else
		bagId = dataEntry.data.bagId
		slotIndex = dataEntry.data.slotIndex
	end

	--case to handle list dialog, list dialog uses index instead of slotIndex and bag instead of badId...?
	if(dataEntry and not bagId and not slotIndex) then 
		bagId = rowControl.dataEntry.data.bag
		slotIndex = rowControl.dataEntry.data.index
	end

	return bagId, slotIndex
end
local function getCatName(itemType)
	if itemType == ITEMTYPE_DISGUISE or itemType == ITEMTYPE_TABARD then
		return KHID.CatPanels[1].name
	elseif itemType == ITEMTYPE_TROPHY then
		return KHID.CatPanels[2].name
	else
		return nil
	end
end
local function getCatIcon(itemType)
	if itemType == ITEMTYPE_DISGUISE or itemType == ITEMTYPE_TABARD then
		return KHID.CatPanels[1].icon
	elseif itemType == ITEMTYPE_TROPHY then
		return KHID.CatPanels[2].icon
	else
		return nil
	end
end
function KHID:CreateCatIcon(rowControl)
	-- create if needed an icon for desguises & co
	local bagId, slotId = GetInfoFromRowControl(rowControl)
--	local bagId, slotId = ZO_Inventory_GetBagAndIndex(rowControl)
	local itemInstanceId = SignItemId(GetItemInstanceId(bagId, slotId))
	local itemType = GetItemType(bagId, slotId)
	local consumable = IsItemConsumable(bagId, slotId)
	
	local control = rowControl:GetNamedChild("KHIDIcon")
	if control == nil then
		control = WINDOW_MANAGER:CreateControl(rowControl:GetName() .. "KHIDIcon", rowControl, CT_TEXTURE)
		control:SetDimensions(30, 30)
		control:SetTexture(TEXTURE_TITLEICON)
		control:SetColor(HexToRGBA(COLOR_KHRILLSELECT))
	end
--d(tostring(itemInstanceId)..","..tostring(itemType)..","..tostring(getCatIcon(itemType)))
--d(rowControl:GetName())
	local icon = nil
	if KHID.accountSettings.ignoreList[itemInstanceId] == nil then --not ignore
		icon = getCatIcon(itemType)
		if icon ~= nil then
			control:SetTexture(icon)
			if not KHID.settings.showConsumable and consumable then --if consumable, icon color disabled
				control:SetColor(HexToRGBA(COLOR_NOCOLOR))
			else
				control:SetColor(KHID.settings.itemIconColor.r,KHID.settings.itemIconColor.g,KHID.settings.itemIconColor.b)
			end
			control:ClearAnchors()
			if(rowControl:GetNamedChild("SellPrice")) then
				control:SetAnchor(LEFT, rowControl:GetNamedChild("Name"), RIGHT, 10, 0)
--				control:SetAnchor(RIGHT, rowControl:GetNamedChild("SellPrice"), LEFT, -10, 0)
			else
				control:SetAnchor(LEFT, rowControl, LEFT)
			end
		end
	end
	control:SetHidden(icon == nil)

	return control
end

function KHID_SelectCat(panelId)
--	d("--SelectCat "..panelId)
	-- button for change selectedCat and item's category
	KHID.selectedCat = panelId
	KHID.selectedPanel = nil
	KHID:addCatButton()
	KHID:ShowDisguises()
end

-- // **********
-- //  Events
-- // **********
local function KHID_OnInventoryShow(self, hidden)
--	d("--OnInventoryShow:") --..tostring(hidden))
	if KHID.settings.enable and not KHID.onBank then 
		KHID:OpenUI()
	end
end
local function KHID_OnInventoryHide(self, hidden)
	KHID:CloseUI()
end
local function KHID_OnInventoryUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
--EVENT_INVENTORY_SINGLE_SLOT_UPDATE (integer eventCode, integer bagId, integer slotId, bool isNewItem, integer itemSoundCategory, InventoryUpdateReason updateReason)
-- d("--OnInventoryUpdate : "..bagId..","..slotId.." - "..tostring(isNewItem)..","..itemSoundCategory.."=>"..GetItemType(bagId, slotId))
	local type = GetItemType(bagId, slotId)
	-- when Tabard change, item goes into costume slot or return in backpack
	if type == ITEMTYPE_TABARD then
		if bagId == BAG_WORN then zo_callLater(function() KHID:ShowDisguises() end,1000) end --selected if worn
		-- refresh ui
		if not KHIDUI:IsHidden() then KHID:ShowDisguises() end
	elseif type == ITEMTYPE_DISGUISE then
		if isNewItem and KHID.settings.newItem then
--		d("-OnInventoryUpdate DISGUISE: "..bagId..","..slotId.." - "..tostring(isNewItem).."=>"..GetItemName(bagId, slotId))
			local msg = zo_iconFormat(TEXTURE_TITLEICON, 48, 48).."   "..zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemName(bagId, slotId)).." : "..GetString(SI_COLLECTIONS_UPDATED_ANNOUNCEMENT_TITLE)
			_G["CENTER_SCREEN_ANNOUNCE"]:AddMessage(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, CSA_EVENT_SMALL_TEXT, SOUNDS.COLLECTIBLE_UNLOCKED, msg) 
		end
		-- refresh ui
		if not KHIDUI:IsHidden() then KHID:ShowDisguises() end
	end
end

local function KHID_onNewItem()
--EVENT_COLLECTIBLE_NOTIFICATION_NEW  (integer eventCode)
	if KHID.settings.sysmessage then
		local msg = "|c"..COLOR_KHRILLSELECT.."["..KHID.name.."]|r => new disguise found"
		CHAT_SYSTEM:AddMessage(msg)
	end
	-- refresh ui
	if not KHIDUI:IsHidden() then KHID:ShowDisguises() end
end

local function KHID_OnDisguiseStateChanged(eventCode, unitTag, disguiseState)
--EVENT_DISGUISE_STATE_CHANGED (integer eventCode, string unitTag, integer disguiseState)
--d("--OnDisguiseStateChanged:"..unitTag..","..disguiseState)
	if unitTag == "player" and disguiseState == DISGUISE_STATE_DISCOVERED then
		-- discover -> lose disguise
		KHID.selectedPanel = nil
		if not KHIDUI:IsHidden() then KHID:ShowDisguises() end
	end
end
function KHID_ToggleUI()
	-- show/hide UI (by title button)
	local doVisible = KHIDUI:IsControlHidden()
	if doVisible then --show
		KHIDUITitleIcon:SetColor(HexToRGBA(COLOR_KHRILLSELECT))
		KHIDUITitleLabel:SetHidden(false)
		KHIDUI:SetHidden(false)
	else --hide
		KHIDUITitleIcon:SetColor(HexToRGBA(COLOR_NOCOLOR))
		KHIDUITitleLabel:SetHidden(true)
		KHIDUI:SetHidden(true)
	end
end
function KHID_ToggleByKey()
	-- show/hide by keybind
	if KHIDUI:IsHidden() then
		SetGameCameraUIMode(true)
		KHID:OpenUI()
	else
		SetGameCameraUIMode(false)
		KHID:CloseUI()
	end
end

local function SelectBank()
	-- // BankButton selected
	KHID.showBank = not KHID.showBank
	if not KHID.showBank then
		KHIDUIBankBtn:GetNamedChild("Texture"):SetColor(HexToRGBA(COLOR_DISABLED))
	else
		KHIDUIBankBtn:GetNamedChild("Texture"):SetColor(HexToRGBA(COLOR_KHRILLSELECT))
	end
	KHID:ShowDisguises()
end

function KHID_SaveAnchor()
	-- Save the new position of windows
--d("--SaveAnchor")
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = KHIDUITitle:GetAnchor()
	if isValidAnchor then
		KHID.settings.anchor = { point, relativePoint, offsetX, offsetY }
	end
end


-- // **********
-- //  Init
-- // **********
function KHID:GetLanguage()
	local lang = GetCVar("language.2")

	--supported languages
	if(lang == "fr") then return lang end
	if(lang == "de") then return lang end
	if(lang == "es") then return lang end

	--return english if not supported
	return "en"
end

function KHID:initCat()
	-- find real ESO informations
	for i=1, #KHID.CatPanels do
		for categoryId = 1, GetNumCollectibleCategories() do
--			d(categoryId)
--			d(GetCollectibleCategoryInfo(categoryId))
			local categoryName, _, _, _, _, _, categoryType  = GetCollectibleCategoryInfo(categoryId)
			if getKeyByValue(KHID.CatPanels[i].collectionType, categoryType) ~= nil then --match
				KHID.CatPanels[i].collectionCat = categoryId
				KHID.CatPanels[i].name = categoryName
				local normalIcon, pressedIcon, mouseoverIcon = GetCollectibleCategoryKeyboardIcons(categoryId)
				KHID.CatPanels[i].icon = normalIcon
			end
		end
	end
end
function KHID:addCatButton()
--d("--addCatButton: "..KHID.selectedCat)
	-- add a button for each category
	local cpt = 0
	local supportControl = GetControl("KHIDUICatPanel")
	for i=1, #KHID.CatPanels do
		local name = KHID.CatPanels[i].name
		local button = addButton(supportControl, "KHIDUICatPanelButton"..name, function(...) KHID_SelectCat(i) end, nil, nil, "|c"..COLOR_KHRILLSELECT..name.."|r", LEFT, KHID.CatPanels[i].icon, nil, nil, nil, 30, 30, 0, 25*cpt+2, TOP, supportControl, TOP, false)
		if i == KHID.selectedCat then --highlight orange
			button:GetChild(1):SetColor(HexToRGBA(COLOR_KHRILLSELECT))
			button.isColorInitiated = true
			--GetControl("KMCUICharPanelButton"..name.."Texture"):SetColor(HexToRGBA(COLOR_KHRILLSELECT))
		else
			button:GetChild(1):SetColor(HexToRGBA(COLOR_ICON))
--				GetControl("KMCUICharPanelButton"..name.."Texture"):SetColor(HexToRGBA(COLOR_ICON))
		end
		button:SetHidden(false)
		cpt = cpt +1
	end
end
local function addContextMenuOption(inventorySlot)
--	local bagId, slotId = ZO_Inventory_GetBagAndIndex(inventorySlot)
	local bagId, slotId = GetInfoFromRowControl(inventorySlot)
	local itemInstanceId = SignItemId(GetItemInstanceId(bagId, slotId))
	local itemType = GetItemType(bagId, slotId)
	local name = getCatName(itemType)
	if name ~= nil then
		name = " |c"..COLOR_KHRILLSELECT..name.."|r"
--d(itemType,name)
		if KHID.accountSettings.ignoreList[itemInstanceId] ~= nil then 
			AddMenuItem(KHID.langString.Message_Marked..name, function() --mark item (remove from ignoreList)
					KHID.accountSettings.ignoreList[itemInstanceId] = nil
					KHID:CreateCatIcon(inventorySlot)
					KHID:ShowDisguises()
				end, MENU_ADD_OPTION_LABEL)
		else
			AddMenuItem(KHID.langString.Message_Unmarked..name, function() --unmark item (add to ignoreList)
					KHID.accountSettings.ignoreList[itemInstanceId] = false
					KHID:CreateCatIcon(inventorySlot)
					KHID:ShowDisguises()
				end, MENU_ADD_OPTION_LABEL)
		end
	end
	ShowMenu(self)
end
local function addContextMenuOptionSoon(rowControl)
	if(rowControl:GetOwningWindow() == ZO_TradingHouse) then return end
	if(ZO_PlayerInventoryBackpack:IsHidden() and ZO_PlayerBankBackpack:IsHidden() and ZO_GuildBankBackpack:IsHidden() and ZO_EnchantingTopLevelInventoryBackpack:IsHidden()) then return end

	if(rowControl:GetParent() ~= ZO_Character) then
		zo_callLater(function() addContextMenuOption(rowControl:GetParent()) end, 50)
	else
		zo_callLater(function() addContextMenuOption(rowControl) end, 50)
	end
end

function KHID:registerEvents(state)
	if state then
		EVENT_MANAGER:RegisterForEvent(KHID.name, EVENT_DISGUISE_STATE_CHANGED, function(...) KHID_OnDisguiseStateChanged(...) end)
--		EVENT_MANAGER:RegisterForEvent(KHID.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...) KHID_OnInventoryUpdate(...) end)
	else
		EVENT_MANAGER:UnregisterForEvent(KHID.name, EVENT_DISGUISE_STATE_CHANGED)
--		EVENT_MANAGER:UnregisterForEvent(KHID.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
	end

end
function KHID:OnActivate()
	if not KHID.activate then
--d("--OnActivate")
		-- category buttons
		KHID:initCat()
		KHID:addCatButton()
		-- bank filter
		addButton(KHIDUI, "KHIDUIBankBtn", SelectBank, nil, nil, nil, TOP, TEXTURE_BANK, nil, nil, nil, 24, 24, 0, 0, BOTTOMRIGHT, KHIDUI, TOPRIGHT, false)

		ZO_PlayerInventory:SetHandler("OnShow", KHID_OnInventoryShow) --OnEffectivelyShown
		ZO_PlayerInventory:SetHandler("OnHide", KHID_OnInventoryHide) --OnEffectivelyHidden
		EVENT_MANAGER:RegisterForEvent(KHID.name, EVENT_OPEN_BANK, function(...) KHID.onBank = true end)
		EVENT_MANAGER:RegisterForEvent(KHID.name, EVENT_OPEN_GUILD_BANK, function(...) KHID.onBank = true end)
		EVENT_MANAGER:RegisterForEvent(KHID.name, EVENT_CLOSE_BANK, function(...) KHID.onBank = false end)
		EVENT_MANAGER:RegisterForEvent(KHID.name, EVENT_CLOSE_GUILD_BANK, function(...) KHID.onBank = false end)
		EVENT_MANAGER:RegisterForEvent(KHID.name, EVENT_COLLECTIBLE_NOTIFICATION_NEW, function(...) KHID_onNewItem() end)
		EVENT_MANAGER:RegisterForEvent(KHID.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...) KHID_OnInventoryUpdate(...) end)
		if KHID.settings.itemIcon then
			-- inventory hook (from ItemSaver)
			for _,v in pairs(PLAYER_INVENTORY.inventories) do
				local listView = v.listView
				if listView and listView.dataTypes and listView.dataTypes[1] then
					local hookedFunctions = listView.dataTypes[1].setupCallback				
					listView.dataTypes[1].setupCallback = 
						function(rowControl, slot)
							hookedFunctions(rowControl, slot)
							KHID:CreateCatIcon(rowControl)
						end				
				end
			end
			ZO_PreHook("ZO_InventorySlot_ShowContextMenu", addContextMenuOptionSoon)
		end

		KHID.activate = true
	end
	EVENT_MANAGER:UnregisterForEvent(KHID.name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:UnregisterForEvent(KHID.name, EVENT_PLAYER_ACTIVATED)
end
function KHID:OnInit(eventCode, addOnName)
    if ( addOnName ~= KHID.name) then return end
	
	KHID.langString = KHID_Lang[KHID:GetLanguage()]
	--bindings
	ZO_CreateStringId("SI_BINDING_NAME_KHIDTOGGLE", KHID.langString.SI_BINDING_NAME_KHIDTOGGLE)
	--settings
	KHID.settings = ZO_SavedVars:New(KHID.name .. "_settings", 1, nil, KHID.defaults)
--	KHID.settings = KHID.defaults --reinit for test
	KHID.accountSettings = ZO_SavedVars:NewAccountWide(KHID.name .. "_settings", 1, nil, KHID.accountDefaults)
	
	-- position
	KHIDUITitle:ClearAnchors()
	KHIDUITitle:SetAnchor(KHID.settings.anchor[1], GuiRoot, KHID.settings.anchor[2], KHID.settings.anchor[3], KHID.settings.anchor[4])
	-- scroll slider
	local slider = CreateControl("KHIDUISlider",KHIDUI,CT_SLIDER)
	slider:SetDimensions(30, KHID.settings.maxRow*105)
	slider:SetMouseEnabled(true)
	slider:SetThumbTexture(TEXTURE_SLIDER,TEXTURE_SLIDER,TEXTURE_SLIDER,20,105,0,0,1,1)
	slider:SetValueStep(1)
	slider:SetAnchor(TOPRIGHT,KHIDUI,TOPRIGHT,22,2)
	slider:SetHandler("OnValueChanged",function(self,value,eventReason) KHID:OnSliderMove(value) end)
	KHIDUI:SetHandler("OnMouseWheel", function(self, delta) KHID:OnMouseWheel(delta) end)
	-- ToolTip
	local tooltip = WINDOW_MANAGER:CreateControlFromVirtual("KHIDUITooltip", KHIDUI, "ZO_ItemIconTooltip")
    tooltip:SetHidden(true)
    tooltip:SetClampedToScreen(true)
	KHID.Tooltip = tooltip

	KHID:CommandOptionPanel()
	
	EVENT_MANAGER:RegisterForEvent(KHID.name, EVENT_PLAYER_ACTIVATED, function(...) KHID:OnActivate() end)
end

EVENT_MANAGER:RegisterForEvent(KHID.name, EVENT_ADD_ON_LOADED , function(_event, _name) KHID:OnInit(_event, _name) end)


-- // **********
-- //  Settings
-- // **********
function KHID:ToggleEnable(value)
	KHID.settings.enable = value
end
function KHID:TogglePositionning(value)
	-- enable/disabled movable frame and BG
	KHID:resetPanels()
	KHIDUI:SetDimensions(CELLBORDER*2+KHID.settings.maxCol*(140+CELLSPACING)-CELLSPACING-1,CELLBORDER*2+KHID.settings.maxRow*(90+CELLSPACING)-CELLSPACING-1)
	KHID:showTitle(value)
	KHIDUI:SetHidden(not value)
	KHIDUITitle:SetHidden(not value)
end

function KHID:CommandOptionPanel()
	--// Settings panel LAM2
	local LAM2 = LibStub("LibAddonMenu-2.0")
	if ( not LAM2 ) then return end
	
	local ADDON_NAME="Hero In Disguise"
	local ADDON_VERSION="v"..KHID.version
	local panelData = {
			type = "panel",
			name = ADDON_NAME,
			displayName = "|c"..COLOR_KHRILLSELECT.. ADDON_NAME .."|r (" .. KHID.langString.LOCALE .. ")",
			author = "|c"..COLOR_KHRILLSELECT.."Khrill|r",
			version = ADDON_VERSION,
			slashCommand = "/kda",
			registerForRefresh = true,
			registerForDefaults = true,
	}
	local settingsPanel = LAM2:RegisterAddonPanel(ADDON_NAME, panelData)
	local anchorTable = {"TOPLEFT","LEFT","BOTTOMLEFT","BOTTOM","BOTTOMRIGHT","RIGHT","TOPRIGHT"}

	local optionsTable = {
		------------SETTINGS--------------
		{
			type = "header",
			name = "|c"..COLOR_KHRILLSELECT..KHID.langString.Settings_control.."|r",
			width = "full",
		},
		{	-- enable
			type = "checkbox",
			name = KHID.langString.Settings_showWithInventory,
--			tooltip = KHID.langString.Settings_showWithInventory,
			getFunc = function() return KHID.settings.enable end,
			setFunc = function(value) KHID:ToggleEnable(value) end,
			width = "full",
			default = KHID.defaults.enable,
		},
		{
			type = "description",
			text = KHID.langString.Settings_keybindText,
			width = "full",
		},
		{	-- hide empty
			type = "checkbox",
			name = KHID.langString.Settings_hideEmpty,
--			tooltip = KHID.langString.Settings_hideEmpty,
			getFunc = function() return KHID.settings.hideEmpty end,
			setFunc = function(value) KHID.settings.hideEmpty = value end,
			width = "full",
			default = KHID.defaults.hideEmpty,
		},
		{	-- show consumable
			type = "checkbox",
			name = KHID.langString.Settings_showConsumable,
--			tooltip = KHID.langString.Settings_showConsumable,
			getFunc = function() return KHID.settings.showConsumable end,
			setFunc = function(value) KHID.settings.showConsumable = value end,
			width = "full",
			default = KHID.defaults.showConsumable,
		},
		{	-- max col
			type = "editbox",
			name = KHID.langString.Settings_maxCol,
			tooltip = "1 .. 9",
			getFunc = function() return KHID.settings.maxCol end,
			setFunc = function(value)
				if value~= nil and tostring(value) >= "1" and tostring(value) <= "9" then
					KHID.settings.maxCol = tonumber(value)
					if not KHIDUI:IsHidden() then KHID:updatePanels() end --KHID:ShowDisguises() end
				end
			end,
			width = "full",
			default = KHID.defaults.maxCol,
		},
		{	-- max row
			type = "editbox",
			name = KHID.langString.Settings_maxRow,
			tooltip = "1 .. 9",
			getFunc = function() return KHID.settings.maxRow end,
			setFunc = function(value)
				if value~= nil and tostring(value) >= "1" and tostring(value) <= "9" then
					KHID.settings.maxRow = tonumber(value)
					GetControl("KHIDUISlider"):SetDimensions(30, KHID.settings.maxRow*105)
					GetControl("KHIDUISlider"):SetThumbTexture(TEXTURE_SLIDER,TEXTURE_SLIDER,TEXTURE_SLIDER,20,(105/2)*KHID.settings.maxRow,0,0,1,1)
					GetControl("KHIDUISlider"):SetAnchor(TOPRIGHT,KHIDUI,TOPRIGHT,22,2)
					if not KHIDUI:IsHidden() then KHID:updatePanels() end --KHID:ShowDisguises() end
				end
			end,
			width = "full",
			default = KHID.defaults.maxRow,
		},
		{	-- fixed size
			type = "checkbox",
			name = KHID.langString.Settings_fixedSize,
--			tooltip = KHID.langString.Settings_hideEmpty,
			getFunc = function() return KHID.settings.fixedSize end,
			setFunc = function(value) KHID.settings.fixedSize = value end,
			width = "full",
			default = KHID.defaults.fixedSize,
		},
		{	-- tooltip position
			type = "dropdown",
			name = KHID.langString.Settings_tooltipPosition,
			tooltip = KHID.langString.Settings_tooltipPosition,
			choices = anchorTable, --{TOPLEFT,LEFT,BOTTOMLEFT,BOTTOM,BOTTOMRIGHT,RIGHT,TOPRIGHT},
			getFunc = function() local anchor = KHID.settings.tooltipPosition
						if anchor == TOPLEFT then return anchorTable[1] end
						if anchor == LEFT then return anchorTable[2] end
						if anchor == BOTTOMLEFT then return anchorTable[3] end
						if anchor == BOTTOM then return anchorTable[4] end
						if anchor == BOTTOMRIGHT then return anchorTable[5] end
						if anchor == RIGHT then return anchorTable[6] end
						if anchor == TOPRIGHT then return anchorTable[7] end
					end,
			setFunc = function(value)
						if value == anchorTable[1] then KHID.settings.tooltipPosition  = TOPLEFT end
						if value == anchorTable[2] then KHID.settings.tooltipPosition  = LEFT end
						if value == anchorTable[3] then KHID.settings.tooltipPosition  = BOTTOMLEFT end
						if value == anchorTable[4] then KHID.settings.tooltipPosition  = BOTTOM end
						if value == anchorTable[5] then KHID.settings.tooltipPosition  = BOTTOMRIGHT end
						if value == anchorTable[6] then KHID.settings.tooltipPosition  = RIGHT end
						if value == anchorTable[7] then KHID.settings.tooltipPosition  = TOPRIGHT end
						KHID:tooltipPosition()
					end,
			width = "full",
			default = KHID.defaults.tooltipPosition,
		},
		{	-- item icon
			type = "checkbox",
			name = KHID.langString.Settings_itemIcon,
			tooltip = KHID.langString.Settings_itemIconTip,
			getFunc = function() return KHID.settings.itemIcon end,
			setFunc = function(value)
						KHID.settings.itemIcon = value
						ReloadUI()
			end,
			width = "full",
			default = KHID.defaults.itemIcon,
			warning = KHID.langString.Settings_warning,
		},
		{	-- item icon color
			type = "colorpicker",
			name = KHID.langString.Settings_itemIconColor,
			--tooltip = "",
			getFunc = function() return KHID.settings.itemIconColor.r, KHID.settings.itemIconColor.g, KHID.settings.itemIconColor.b end,
			setFunc = function(r, g, b) KHID.settings.itemIconColor = {r=r, g=g, b=b} end,
			default = KHID.defaults.itemIconColor,
		},
		{	-- new item alert
			type = "checkbox",
			name = KHID.langString.Settings_newItem,
			tooltip = KHID.langString.Settings_newItemTip,
			getFunc = function() return KHID.settings.newItem end,
			setFunc = function(value) KHID.settings.newItem = value end,
			width = "full",
			default = KHID.defaults.newItem,
		},
		{	-- sysmessage
			type = "checkbox",
			name = KHID.langString.Settings_sysmessage,
--			tooltip = KHID.langString.Settings_enable,
			getFunc = function() return KHID.settings.sysmessage end,
			setFunc = function(value) KHID.settings.sysmessage = value end,
			width = "full",
			default = KHID.defaults.sysmessage,
		},
		
		------------positionning--------------
		{
			type = "header",
			name = "|c"..COLOR_KHRILLSELECT..KHID.langString.Settings_positionning.."|r",
			width = "full",
		},
		{
			type = "description",
			text = KHID.langString.Settings_positionningText,
			width = "full",
		},
		{
			type = "checkbox",
			name = KHID.langString.Settings_enable,
--			tooltip = KHID.langString.Settings_enable,
			getFunc = function() return KHID.positionning end,
			setFunc = function(value) KHID:TogglePositionning(value) end,
			width = "full",
			default = false,
		},
	}

	LAM2:RegisterOptionControls(ADDON_NAME, optionsTable)
end

SLASH_COMMANDS["/khiddebug"] = function()
	d(GetNumCollectibleCategories())
	for categoryId = 1, GetNumCollectibleCategories() do
		d(categoryId..":")
		d(GetCollectibleCategoryInfo(categoryId))
		d("-----")
--	local categoryName, numSubCatgories, numCollectibles, unlockedCollectibles, totalCollectibles, hidesLocked, normalIcon, pressedIcon, mouseoverIcon, categoryType  = GetCollectibleCategoryInfo(categoryId)
	end
 end

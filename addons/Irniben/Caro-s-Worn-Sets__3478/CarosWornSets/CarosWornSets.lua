CarosWornSets = {
  name = "CarosWornSets",  
}
local waitingForUpdate = false
local GS = GetString

local  myGearSlots = {
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_NECK,
    EQUIP_SLOT_RING1,
    EQUIP_SLOT_RING2,
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF,
    EQUIP_SLOT_POISON,
    EQUIP_SLOT_BACKUP_POISON,
    -- EQUIP_SLOT_COSTUME,
  }

local ignoreEmpty = {
    [EQUIP_SLOT_BACKUP_POISON] = true,
    [EQUIP_SLOT_POISON] = true,
} 

local isTwoHanded = {
    [WEAPONTYPE_FIRE_STAFF] = true,
    [WEAPONTYPE_FROST_STAFF] = true,
    [WEAPONTYPE_HEALING_STAFF] = true,
    [WEAPONTYPE_LIGHTNING_STAFF] = true,
    [WEAPONTYPE_TWO_HANDED_AXE] = true,
    [WEAPONTYPE_TWO_HANDED_HAMMER] = true,
    [WEAPONTYPE_TWO_HANDED_SWORD] = true,
	[WEAPONTYPE_BOW] = true,
}
	
local function cwsSetFont()
	local fontWeight = CarosWornSets.savedVariables.lightFont and "MEDIUM_FONT" or "BOLD_FONT"
	local shadow = CarosWornSets.savedVariables.thickShadow and "soft-shadow-thick" or "soft-shadow-thin"
	local CWSFontSize = CarosWornSets.savedVariables.fontSize or 13
	local myFont = string.format("$(%s)|$(KB_%s)|%s", fontWeight, CWSFontSize, shadow)
	CarosWornSetsIndicatorLabel:SetFont(myFont)
end

function CarosWornSets:Initialize()	
	EVENT_MANAGER:UnregisterForEvent(CarosWornSets.name, EVENT_ADD_ON_LOADED)
	
	self.savedVariables = ZO_SavedVars:NewAccountWide("CarosWornSetsSavedVariables", 1, nil, {}) -- account wide
	self:RestorePosition()
	cwsSetFont()
	CarosWornSets.fragment = ZO_HUDFadeSceneFragment:New(CarosWornSetsIndicator)

	if not CarosWornSets.savedVariables.hideInUi then
		HUD_SCENE:AddFragment(CarosWornSets.fragment)
		HUD_UI_SCENE:AddFragment(CarosWornSets.fragment)
	end
	
	if  CarosWornSets.savedVariables.showInInventory then SCENE_MANAGER:GetScene("inventory"):AddFragment(CarosWornSets.fragment) end
	if  CarosWornSets.savedVariables.showInBank then 
		SCENE_MANAGER:GetScene("bank"):AddFragment(CarosWornSets.fragment)
		SCENE_MANAGER:GetScene("guildBank"):AddFragment(CarosWornSets.fragment)
		SCENE_MANAGER:GetScene("houseBank"):AddFragment(CarosWornSets.fragment)
	end
	
	if CarosWornSets.savedVariables.showInSkills then
		SCENE_MANAGER:GetScene("skills"):AddFragment(CarosWornSets.fragment)
	end
	
	CarosWornSetsIndicatorLabel:SetDimensionConstraints(0, 0, CarosWornSets.savedVariables.maxWidth or 240, 0)
		
	CarosWornSets.savedVariables.bg = CarosWornSets.savedVariables.bg or {0,0,0,0.8}
	CarosWornSets.savedVariables.textCol = CarosWornSets.savedVariables.textCol or {1,1,1,1}

	CarosWornSets.savedVariables.orange = CarosWornSets.savedVariables.orange or {1, 0.161, 0, 1}
	CarosWornSets.savedVariables.yellow = CarosWornSets.savedVariables.yellow or {1, 0.953, 0, 1}
	CarosWornSets.savedVariables.purple = CarosWornSets.savedVariables.purple or {1, 0, 0.827, 1}
	CarosWornSets.savedVariables.specialCol = CarosWornSets.savedVariables.specialCol or {1,1,1,1}
	
	if CarosWornSets.savedVariables.hotbars == nil then CarosWornSets.savedVariables.hotbars = true end
	if CarosWornSets.savedVariables.ll == nil then CarosWornSets.savedVariables.ll = true end
	if CarosWornSets.savedVariables.monster == nil then CarosWornSets.savedVariables.monster = true end
	if CarosWornSets.savedVariables.eq == nil then CarosWornSets.savedVariables.eq = true end
	
	CarosWornSets.savedVariables.specialSets = CarosWornSets.savedVariables.specialSets or {}
		
	CarosWornSetsIndicator_BG:SetColor(unpack(CarosWornSets.savedVariables.bg))
	CarosWornSetsIndicatorLabel:SetColor(unpack(CarosWornSets.savedVariables.textCol))
	
	CarosWornSets.ShowWornSets()

	EVENT_MANAGER:RegisterForEvent(CarosWornSets.name.."InventoryChange", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId) CarosWornSets.inventoryChanged() end)
	EVENT_MANAGER:RegisterForEvent(CarosWornSets.name.."ArmoryRestore", EVENT_ARMORY_BUILD_RESTORE_RESPONSE, function() if not waitingForUpdate then CarosWornSets.ShowWornSets() end end)
	EVENT_MANAGER:RegisterForEvent(CarosWornSets.name.."HotbarChange", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function() if not waitingForUpdate then CarosWornSets.ShowWornSets() end end)
	
	EVENT_MANAGER:AddFilterForEvent(CarosWornSets.name.."InventoryChange", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
 
	
	     
    --menu:RegisterContextMenu(AddItem, menu.CATEGORY_PRIMARY)
    LibCustomMenu:RegisterContextMenu(function(inventorySlot)
			local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
			local hasSetInfo, _, _, _, neededNumber, itemSetId = GetItemLinkSetInfo(GetItemLink(bagId, slotIndex), false)
			if hasSetInfo and neededNumber and neededNumber > 1 and itemSetId and not CarosWornSets.savedVariables.specialSets[itemSetId] then
			  AddCustomMenuItem(GS(CaroWS_MarkAsSpecial), function()
				CarosWornSets.savedVariables.specialSets[itemSetId] = true
				CarosWornSets:ShowWornSets()	
			  end, "")
			end
		end, LibCustomMenu.CATEGORY_LATE)
 
	local panelData = {
		type = "panel",
		name = "Caro's Worn Sets",
		displayName =  "|c9e0911Caro|r's Worn Sets",
		author = "|c1d6dadIrniben|r",
		registerForRefresh = true,
    }
	
	local setToDelete = false
	
	local function getSetsInSV()
		local names = {}
		local keyByName = {}
		for setKey, _ in pairs(CarosWornSets.savedVariables.specialSets) do
			local setName = zo_strformat("<<C:1>>", GetItemSetName(setKey))
			table.insert(names, setName)
			keyByName[setName] = setKey
		end
		table.sort(names)
		local sortedIds = {}
		for _, setName in pairs(names) do
			table.insert(sortedIds, keyByName[setName])
		end
		return names, sortedIds
	end
	
	local specialSetNames, specialSetIds = getSetsInSV()
	
	local optionsData = {
		{
			type = "slider",
			name = GS(CaroWS_LAM_Size),
			max = 22,
			min = 10, --(optional)
			decimals = 0, 
			autoSelect = true,
			width = "full",
			getFunc = function() return CarosWornSets.savedVariables.fontSize or 13  end,
			setFunc = function(value) 
					CWSFontSize = value
					CarosWornSets.savedVariables.fontSize = CWSFontSize
					cwsSetFont()
				end,
		},	
		{
			type = "slider",
			name = GS(CaroWS_LAM_MaxWidth),
			max = 500,
			min = 200, --(optional)
			step = 20,
			decimals = 0, 
			autoSelect = true,
			width = "full",
			getFunc = function() return CarosWornSets.savedVariables.maxWidth or 240  end,
			setFunc = function(value) 
					CarosWornSets.savedVariables.maxWidth = value
					CarosWornSetsIndicatorLabel:SetDimensionConstraints(0, 0, CarosWornSets.savedVariables.maxWidth or 240, 0)
				end,
		},	
		{
			type = "button",
			name = GS(CaroWS_LAM_ResetPosition),
			width = "full",
			func = function() 
				CarosWornSetsIndicator:ClearAnchors()
				CarosWornSetsIndicator:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
				CarosWornSets.savedVariables.left = CarosWornSetsIndicator:GetLeft()
				CarosWornSets.savedVariables.top = CarosWornSetsIndicator:GetTop()
			end,
		},		
		{
			type = "colorpicker",
			name = GS(CaroWS_LAM_BG),
			getFunc = function() return unpack(CarosWornSets.savedVariables.bg) end,	
			setFunc = function(r,g,b,a)  
					CarosWornSets.savedVariables.bg = {r,g,b,a}
					CarosWornSetsIndicator_BG:SetColor(r,g,b,a)
				end,	
			width = "full",	
		},
		{
			type = "checkbox",
			name = GS(CaroWS_LAM_ShowInUI),
			width = "half",
			getFunc = function() return not CarosWornSets.savedVariables.hideInUi end,
			setFunc = function(value) 
					CarosWornSets.savedVariables.hideInUi = not value
					if value then 
						HUD_SCENE:AddFragment(CarosWornSets.fragment)
						HUD_UI_SCENE:AddFragment(CarosWornSets.fragment)
					else
						HUD_SCENE:RemoveFragment(CarosWornSets.fragment)
						HUD_UI_SCENE:RemoveFragment(CarosWornSets.fragment)
					end
				end,
		},	
		{
			type = "checkbox",
			name = GS(CaroWS_LAM_ShowInSkills),
			width = "half",
			getFunc = function() return CarosWornSets.savedVariables.showInSkills end,
			setFunc = function(value) 
					CarosWornSets.savedVariables.showInSkills = value
					if value then 
						SCENE_MANAGER:GetScene("skills"):AddFragment(CarosWornSets.fragment)
					else
						SCENE_MANAGER:GetScene("skills"):RemoveFragment(CarosWornSets.fragment)
					end
				end,
		},	
		{
			type = "checkbox",
			name = GS(CaroWS_LAM_ShowInInventory),
			width = "half",
			getFunc = function() return CarosWornSets.savedVariables.showInInventory end,
			setFunc = function(value) 
					CarosWornSets.savedVariables.showInInventory = value
					if value then 
						SCENE_MANAGER:GetScene("inventory"):AddFragment(CarosWornSets.fragment)
					else
						SCENE_MANAGER:GetScene("inventory"):RemoveFragment(CarosWornSets.fragment)
					end
				end,
		},
		{
			type = "checkbox",
			name = GS(CaroWS_LAM_ShowInBank),
			width = "half",
			getFunc = function() return CarosWornSets.savedVariables.showInBank end,
			setFunc = function(value) 
					CarosWornSets.savedVariables.showInBank = value
					if value then 
						SCENE_MANAGER:GetScene("bank"):AddFragment(CarosWornSets.fragment)
						SCENE_MANAGER:GetScene("guildBank"):AddFragment(CarosWornSets.fragment)
						SCENE_MANAGER:GetScene("houseBank"):AddFragment(CarosWornSets.fragment)
					else
						SCENE_MANAGER:GetScene("bank"):RemoveFragment(CarosWornSets.fragment)
						SCENE_MANAGER:GetScene("guildBank"):RemoveFragment(CarosWornSets.fragment)
						SCENE_MANAGER:GetScene("houseBank"):RemoveFragment(CarosWornSets.fragment)

					end
				end,
		},
		{
			type = "submenu",
			name = GS(CaroWS_LAM_Font),
			icon = "esoui/art/guild/tabicon_history_up.dds",
			controls = {
				{
					type = "checkbox",
					name = GS(CaroWS_LAM_FontBold),
					width = "half",
					getFunc = function() return CarosWornSets.savedVariables.lightFont end,
					setFunc = function(value) 
							CarosWornSets.savedVariables.lightFont = value
							cwsSetFont()
						end,
				},
				{
					type = "checkbox",
					name = GS(CaroWS_LAM_FontShadow),
					width = "half",
					getFunc = function() return CarosWornSets.savedVariables.thickShadow end,
					setFunc = function(value) 
							CarosWornSets.savedVariables.thickShadow = value
							cwsSetFont()
						end,
				},
				
				{
					type = "divider",
					width = "full",
				},	
				{
					type = "colorpicker",
					name = GS(CaroWS_LAM_TextCol),
					getFunc = function() return unpack(CarosWornSets.savedVariables.textCol) end,	
					setFunc = function(r,g,b,a)  
							CarosWornSets.savedVariables.textCol = {r,g,b,a}
							CarosWornSetsIndicatorLabel:SetColor(r,g,b,a)
						end,	
					width = "full",	
				},
				{
					type = "colorpicker",
					name = GS(CaroWS_LAM_Orange),
					getFunc = function() return unpack(CarosWornSets.savedVariables.orange) end,	
					setFunc = function(r,g,b,a)  
							CarosWornSets.savedVariables.orange = {r,g,b,a}
							CarosWornSets:ShowWornSets()
						end,	
					width = "full",	
				},
				{
					type = "colorpicker",
					name = GS(CaroWS_LAM_Yellow),
					getFunc = function() return unpack(CarosWornSets.savedVariables.yellow) end,	
					setFunc = function(r,g,b,a)  
							CarosWornSets.savedVariables.yellow = {r,g,b,a}
							CarosWornSets:ShowWornSets()
						end,	
					width = "full",	
				},
				{
					type = "colorpicker",
					name = GS(CaroWS_LAM_Purple),
					getFunc = function() return unpack(CarosWornSets.savedVariables.purple) end,	
					setFunc = function(r,g,b,a)  
							CarosWornSets.savedVariables.purple = {r,g,b,a}
							CarosWornSets:ShowWornSets()
						end,	
					width = "full",	
				},
			}
		},
		{
			type = "submenu",
			name = GS(CaroWS_LAM_Individual),
			icon = "esoui/art/guild/tabicon_history_up.dds",
			controls = {	
				{
					type = "checkbox",
					name = GS(CaroWS_LAM_Hotbars),
					width = "full",
					getFunc = function() return CarosWornSets.savedVariables.hotbars end,
					setFunc = function(value) 
							CarosWornSets.savedVariables.hotbars = value
							CarosWornSets:ShowWornSets()
						end,
				},
				{
					type = "checkbox",
					name = GS(CaroWS_LAM_Monster),
					width = "full",
					getFunc = function() return CarosWornSets.savedVariables.monster end,
					setFunc = function(value) 
							CarosWornSets.savedVariables.monster = value
							CarosWornSets:ShowWornSets()
						end,
				},
				{
					type = "checkbox",
					name = GS(CaroWS_LAM_LowLevel),
					width = "full",
					getFunc = function() return CarosWornSets.savedVariables.ll end,
					setFunc = function(value) 
							CarosWornSets.savedVariables.ll = value
							CarosWornSets:ShowWornSets()
						end,
				},
				{
					type = "checkbox",
					name = GS(CaroWS_LAM_EnchantQuality),
					width = "full",
					getFunc = function() return CarosWornSets.savedVariables.eq end,
					setFunc = function(value) 
							CarosWornSets.savedVariables.eq = value
							CarosWornSets:ShowWornSets()
						end,
				},	
				{
					type = "checkbox",
					name = GS(CaroWS_LAM_ShowLMH),
					width = "full",
					getFunc = function() return CarosWornSets.savedVariables.showLMH end,
					setFunc = function(value) 
							CarosWornSets.savedVariables.showLMH = value
							CarosWornSets:ShowWornSets()
						end,
				},		
			}
		},
		{
			type = "submenu",
			name = GS(CaroWS_LAM_Special),
			icon = "esoui/art/guild/tabicon_history_up.dds",
			controls = {
				{
					type = "description",
					text = GS(CaroWS_LAM_SpecialExp),
				},
				{
					type = "colorpicker",
					name = GS(CaroWS_LAM_SpecialCol),
					getFunc = function() return unpack(CarosWornSets.savedVariables.specialCol) end,	
					setFunc = function(r,g,b,a)  
							CarosWornSets.savedVariables.specialCol = {r,g,b,a}
							CarosWornSets:ShowWornSets()
						end,	
					width = "full",	
				},
				{
					type = "dropdown",
					name = GS(CaroWS_LAM_SpecialSets),
					width = "full",
					choices = specialSetNames,
					choicesValues = specialSetIds,
					sort = "name-up",
					default = false,
					getFunc = function() return setToDelete or "" end,
					setFunc = function(value) 
						setToDelete = value
					end,
					reference = "CarosWornSetsLAM_SpecialDropdown",
					disabled = function() return false end, -- refresh choices here
				},	
				{
					type = "button",
					name = GS(SI_DIALOG_REMOVE),
					width = "half",
					func = function() 
						if not setToDelete or setToDelete == 0 then return end
						CarosWornSets.savedVariables.specialSets[setToDelete] = nil
						CarosWornSetsLAM_SpecialDropdown:UpdateChoices(getSetsInSV())
						setToDelete = false
						CarosWornSets:ShowWornSets()						
					end,
					disabled = function() return not setToDelete end,		
				},	
			},
		}
	}
	
	local LAM = LibAddonMenu2
	
	local cwsPanel = LAM:RegisterAddonPanel("carowsOptions", panelData)
	LAM:RegisterOptionControls("carowsOptions", optionsData)	
	
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
		if panel ~= cwsPanel then return end
		CarosWornSetsIndicator:SetHidden(false)
		CarosWornSetsLAM_SpecialDropdown:UpdateChoices(getSetsInSV())
	end)

	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
		if panel ~= cwsPanel then return end
		CarosWornSetsIndicator:SetHidden(true)
	end)
	
end

local function checkHotbars()
	
	local hotBarCats = {HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP} -- HOTBAR_CATEGORY_WEREWOLF,
	local hbWarnings = {}
	
	if not CarosWornSets.savedVariables.hotbars then return hbWarnings end
	
    for barIndex, barCategory in pairs(hotBarCats) do
		
		local hbManager = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(barCategory) 
        for i = 1, 6 do
			local slotData = hbManager:GetSlotData(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + i)
            local skillData = slotData and slotData:GetPlayerSkillData()
			if skillData then 
				if not CanAbilityBeUsedFromHotbar(skillData:GetPointAllocatorProgressionData():GetAbilityId(), barCategory) then 
					table.insert(hbWarnings, string.format("%s (%s)", GS(SI_RESPECRESULT6),GS("CaroWS_bar", barCategory)))
					break
				end
			end
		end
			
    end
	return hbWarnings
end


function CarosWornSets.OnAddOnLoaded(event, addonName)
	if addonName == CarosWornSets.name then
		CarosWornSets:Initialize()
	end
end

function CarosWornSets.inventoryChanged()
	if waitingForUpdate == false then
		waitingForUpdate = true
		zo_callLater(function() CarosWornSets.ShowWornSets() end, 1000)
	end
end

local function IsItemSet(itemLink)
	if itemLink == nil then return false, nil end
	local hasSetInfo, _, _, _, neededNumber, itemSetId = GetItemLinkSetInfo(itemLink, false)
	
	hasSetInfo = hasSetInfo or false
	return hasSetInfo, tonumber(itemSetId), neededNumber
end




function CarosWornSets.ShowWornSets()
	waitingForUpdate = false
	local myWornSets = {}
	local myCPLevel = math.min(GetUnitChampionPoints("player"), 160)
	local myLevel = GetUnitLevel("player")
	local setCounts = {}
	local setNeeded = {}
	local ringOfMara = false
	local emptySlots = {}
	local enchantWarning = {}
	local warnLevel = {}
	local frontBar = {[EQUIP_SLOT_MAIN_HAND] = true, [EQUIP_SLOT_OFF_HAND] = true}
	local backBar = {[EQUIP_SLOT_BACKUP_MAIN] = true, [EQUIP_SLOT_BACKUP_OFF] = true}
	local twoHandedSlots = {}
	local lms = {[1] = 0, [2] = 0, [3] = 0}
	
	local function getSlotName(gearSlot, isWeapon, twoHanded)
		local slotName = ""

		if isWeapon then
			if twoHanded then
				return zo_strformat("<<C:1>>", GS(frontBar[gearSlot] and CaroWS_bar0 or CaroWS_bar1))
			end
			local reRouteSlots = {
				[EQUIP_SLOT_MAIN_HAND] = SI_EQUIPSLOT4,
				[EQUIP_SLOT_BACKUP_MAIN] = SI_EQUIPSLOT4,
				[EQUIP_SLOT_OFF_HAND] = SI_EQUIPSLOT5,
				[EQUIP_SLOT_BACKUP_OFF] = SI_EQUIPSLOT5,
			}
			return zo_strformat("<<C:1>> (<<2>>)", GS(reRouteSlots[gearSlot]), GS(frontBar[gearSlot] and CaroWS_bar0 or CaroWS_bar1))
		end
		return zo_strformat("<<C:1>>", GS("SI_EQUIPSLOT", gearSlot))
	end
	
	for _, gearSlot in ipairs(myGearSlots) do
		local itemLink = GetItemLink(BAG_WORN, gearSlot, LINK_STYLE_DEFAULT)
		if itemLink == "" then
			if not ignoreEmpty[gearSlot] then table.insert(emptySlots, gearSlot) end
		else
			local hasSetInfo, itemSetId, neededNumber = IsItemSet(itemLink)
			local weaponType = GetItemWeaponType(BAG_WORN, gearSlot)
			local armorType = GetItemArmorType(BAG_WORN, gearSlot)
			lms[armorType] = lms[armorType] or 0
			lms[armorType] = lms[armorType] + 1
			local isRingOfMara = false
			if GetItemLinkItemId(itemLink) == 44904 then ringOfMara = GetItemName(BAG_WORN, gearSlot) isRingOfMara = true end
			if isTwoHanded[weaponType] and gearSlot == EQUIP_SLOT_MAIN_HAND then 
				ignoreEmpty[EQUIP_SLOT_OFF_HAND] = true
				twoHandedSlots[EQUIP_SLOT_MAIN_HAND] = true
			elseif isTwoHanded[weaponType] and gearSlot == EQUIP_SLOT_BACKUP_MAIN then 
				ignoreEmpty[EQUIP_SLOT_BACKUP_OFF] = true
				twoHandedSlots[EQUIP_SLOT_BACKUP_MAIN] = true
			end
			if hasSetInfo then
				local numberToAdd = isTwoHanded[weaponType] and 2 or 1 -- will be 2 for two-handed weapons
				local unperfected = GetItemSetUnperfectedSetId(itemSetId)
				if unperfected and unperfected ~= 0 then 
					myWornSets[unperfected] = myWornSets[unperfected] or {worn=0, frontBar = 0, backBar = 0, needed=neededNumber}
					myWornSets[unperfected].perfected = itemSetId
					itemSetId = unperfected
				else
					myWornSets[itemSetId] = myWornSets[itemSetId] or {worn=0, frontBar = 0, backBar = 0, needed=neededNumber}
					myWornSets[itemSetId].unperfected = true
				end
				myWornSets[itemSetId] = myWornSets[itemSetId] or {worn=0, frontBar = 0, backBar = 0, needed=neededNumber}
				
				if frontBar[gearSlot] then 
					myWornSets[itemSetId].frontBar = myWornSets[itemSetId].frontBar + numberToAdd
				elseif backBar[gearSlot] then
					myWornSets[itemSetId].backBar = myWornSets[itemSetId].backBar + numberToAdd
				else
					myWornSets[itemSetId].worn = myWornSets[itemSetId].worn + numberToAdd
				end
				
				if GetItemDisplayQuality(BAG_WORN, gearSlot) == ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE then myWornSets[itemSetId].mythic = true end
				
				if gearSlot == EQUIP_SLOT_HEAD or gearSlot == EQUIP_SLOT_SHOULDERS then 
					if myWornSets[itemSetId].worn == 1 and myWornSets[itemSetId].needed < 3 then 
						myWornSets[itemSetId].noWarning = true 
					else 
						myWornSets[itemSetId].noWarning = false 
					end
				end
			end
			
			local itemId, enchantSubType = itemLink:match("|H[^:]+:item:([^:]+):[^:]+:[^:]+:[^:]+:([^:]+):")
			local itemQuality = GetItemLinkQuality(itemLink)
			if not ignoreEmpty[gearSlot] and enchantSubType and tonumber(enchantSubType) > 0 then
				local enchantQuality = GetItemLinkQuality(string.format("|H1:item:%i:%i:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h", itemId, enchantSubType))
				if enchantQuality < itemQuality then table.insert(enchantWarning, gearSlot) end
			end
			local reqCP = GetItemLinkRequiredChampionPoints(itemLink)
			if not isRingOfMara and (itemQuality < 5 and reqCP < 150 or (gearSlot ~= EQUIP_SLOT_BACKUP_POISON and gearSlot ~= EQUIP_SLOT_POISON)) then
				if reqCP < myCPLevel then table.insert(warnLevel, gearSlot) end
				if myCPLevel == 0 and GetItemLinkRequiredLevel(itemLink) < myLevel - 10 then table.insert(warnLevel, gearSlot) end
			end
		end
	end
	CarosWornSets.myWornSets = myWornSets
	local currentlyWornSets = {}
	CarosWornSets.currentlyWornSets = currentlyWornSets
	local orange = ZO_ColorDef:New(unpack(CarosWornSets.savedVariables.orange))
	local yellow = ZO_ColorDef:New(unpack(CarosWornSets.savedVariables.yellow))
	local purple = ZO_ColorDef:New(unpack(CarosWornSets.savedVariables.purple))
	local specialCol = ZO_ColorDef:New(unpack(CarosWornSets.savedVariables.specialCol))
	
	for itemSetId, setData in pairs(myWornSets) do
		local setName = GetItemSetName(itemSetId)
		if setData.perfected and not setData.unperfected then setName = GetItemSetName(setData.perfected) end
		local myText = ""
		
		if setData.frontBar > 0 or setData.backBar > 0 then
			myText = zo_strformat("<<1>>/<<2>>x <<C:3>>", setData.worn + setData.frontBar, setData.worn + setData.backBar, setName)  
		else
			myText = zo_strformat("<<1>>x <<C:2>>", setData.worn, setName)  
		end
		
		if setData.needed > setData.worn + setData.frontBar and setData.needed > setData.worn + setData.backBar then 
			if CarosWornSets.savedVariables.specialSets[itemSetId] then
				myText = specialCol:Colorize(myText)
			elseif not setData.noWarning then
				myText = orange:Colorize(string.format("%s |t28:28:esoui/art/miscellaneous/eso_icon_warning.dds:inheritcolor|t", myText))
			elseif CarosWornSets.savedVariables.monster then
				myText = yellow:Colorize(myText) 
			end
		elseif setData.mythic then
			myText = purple:Colorize(myText) 
		end
		table.insert(currentlyWornSets, myText)
	end
	table.sort(currentlyWornSets, function(a,b) return a > b end)
	if ringOfMara then table.insert(currentlyWornSets, zo_strformat("|cd50035 1x <<C:1>>", ringOfMara)) end
	local emptySlotsTexts = {}
	if #emptySlots > 5 then
		table.insert(currentlyWornSets, orange:Colorize(string.format("%s: %sx", GS(SI_QUICKSLOTS_EMPTY), #emptySlots)))
	elseif #emptySlots > 0 then
		for index, emptySlot in pairs(emptySlots) do
			local emptySlotText = ""
			if frontBar[emptySlot] or backBar[emptySlot] then
				if emptySlot == EQUIP_SLOT_OFF_HAND and emptySlots[index - 1] == EQUIP_SLOT_MAIN_HAND or emptySlot == EQUIP_SLOT_BACKUP_OFF and emptySlots[index - 1] == EQUIP_SLOT_BACKUP_MAIN  then
					emptySlotText = getSlotName(emptySlot, true, true)
					table.remove(emptySlotsTexts, #emptySlotsTexts)				
				else
					emptySlotText = getSlotName(emptySlot, true, false)
				end
			else
				emptySlotText = zo_strformat("<<C:1>>", GS("SI_EQUIPSLOT", emptySlot))
			end
			
			table.insert(emptySlotsTexts, emptySlotText)
		end
		table.insert(currentlyWornSets, orange:Colorize(string.format("%s: %s",  GS(SI_QUICKSLOTS_EMPTY),table.concat(emptySlotsTexts, ", "))))
	end
	if #enchantWarning > 0 and CarosWornSets.savedVariables.eq then
		if #enchantWarning > 5 then
			table.insert(currentlyWornSets, orange:Colorize(string.format(GS(CaroWS_EnchantQuality), #enchantWarning)))
		else
			for index, warnSlot in pairs(enchantWarning) do
				enchantWarning[index] = getSlotName(warnSlot, frontBar[warnSlot] or backBar[warnSlot], twoHandedSlots[warnSlot])
			end
			table.insert(currentlyWornSets, orange:Colorize(string.format(GS(CaroWS_EnchantQuality), table.concat(enchantWarning, ", "))))
		end
	end
	if #warnLevel > 0 and CarosWornSets.savedVariables.ll then
		if #warnLevel > 5 then
			table.insert(currentlyWornSets, orange:Colorize(string.format("%s: %sx", GS(SI_GROUP_LIST_PANEL_LEVEL_HEADER), #warnLevel)))
		else
			for index, warnSlot in pairs(warnLevel) do
				warnLevel[index] = getSlotName(warnSlot, frontBar[warnSlot] or backBar[warnSlot], twoHandedSlots[warnSlot])
			end
			table.insert(currentlyWornSets, orange:Colorize(string.format("%s: %s", GS(SI_GROUP_LIST_PANEL_LEVEL_HEADER), table.concat(warnLevel, ", "))))
		end
	end
	local hbWarnings = checkHotbars()
	for _, warning in pairs(hbWarnings) do
		table.insert(currentlyWornSets, orange:Colorize(warning))
	end
	if CarosWornSets.savedVariables.showLMH then
		lms[0] = nil
		table.insert(currentlyWornSets, string.format(GS(CaroWS_LMH), table.concat(lms, "/")))
	end
	CarosWornSetsIndicatorLabel:SetText(table.concat(currentlyWornSets, "\n"))
	
	--CarosWornSetsIndicator:SetHeight(CarosWornSetsIndicatorLabel:GetHeight()+8)
	--CarosWornSetsIndicator:SetWidth(CarosWornSetsIndicatorLabel:GetWidth()+8)
end

function CarosWornSets.OnRightClick(ctrl, shift)
	local CWSFontSize = CarosWornSets.savedVariables.fontSize or 13
	CWSFontSize = ctrl and CWSFontSize - 1 or CWSFontSize + 1
	if CWSFontSize >= 20 then CWSFontSize = 12 end
	if CWSFontSize <= 11 then CWSFontSize = 19 end
	CarosWornSets.savedVariables.fontSize = CWSFontSize
	cwsSetFont()
end

function CarosWornSets.DoubleClick(button, ctrl, shift)
	
end
			
function CarosWornSets.OnIndicatorMoveStop()
	CarosWornSets.savedVariables.left = CarosWornSetsIndicator:GetLeft()
	CarosWornSets.savedVariables.top = CarosWornSetsIndicator:GetTop()
end

function CarosWornSets:RestorePosition()
	local left = self.savedVariables.left
	local top = self.savedVariables.top
	--CarosWornSetsIndicator:SetHeight(CarosWornSetsIndicatorLabel:GetHeight()+8)
	--CarosWornSetsIndicator:SetWidth(CarosWornSetsIndicatorLabel:GetWidth()+8)
	CarosWornSetsIndicator:ClearAnchors()
	CarosWornSetsIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end
 

 EVENT_MANAGER:RegisterForEvent(CarosWornSets.name, EVENT_ADD_ON_LOADED, CarosWornSets.OnAddOnLoaded)
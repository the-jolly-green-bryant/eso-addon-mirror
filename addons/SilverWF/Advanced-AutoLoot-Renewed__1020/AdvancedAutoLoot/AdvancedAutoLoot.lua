local AdvancedAutoLoot = ZO_Object:Subclass()
AdvancedAutoLoot.db = nil
AdvancedAutoLoot.config = nil
AdvancedAutoLoot.LastAnchor = nil
AdvancedAutoLoot.SkipCloth = false
AdvancedAutoLoot.SkipWood = false
AdvancedAutoLoot.SkipMetal = false
AdvancedAutoLoot.SkipFood = false
AdvancedAutoLoot.SkipGlyph = false
AdvancedAutoLoot.SkipJwlr = false
AdvancedAutoLoot.SkipAlchemy = false
local CBM = CALLBACK_MANAGER
local Config = AdvancedAutoLootConfig
local defaults = 
	{
	destroyWorthless = false,
	destroyJprice = 0,
	minSdestroy = 0,
	announceJunk = true,
	autoLootActivated = true,
	accountWide = false,
	autoJunkSell = true,
	--autoBouncer = true,
	deleteDialogSuppress = false,
	returnDialogSuppress = false,
	allowStolenSort = false,
	keepSetItems = false,
	keepAnyJewelry = false,
	keepCrafted = true,
	keepCommonStyle = false,
	keepRareStyle = true,	
	keepExoticStyle = true,  
	keepResearchable = false,
	keepMainResearchable = true,
	keepIntricate = true,
	keepProvisionning = true,
	keepRecipes = true,
	keepFood = true,
	keepFoodCP = 150,
	keepPotions = true,
	keepPoison = true,
	keepPoisonCP = 150,
	keepBaits = true,
	keepGlyph = true,
	keepGlyphCP = 150,
	keepSoulgemFull = true,
	keepSoulgemEmpty = true,
	minQuality = 2,
	minItemCP = 0,
	keepBTG = true,
	keepISa = true,
	mailSettings = {
		['Cloth'] = {
			['Send'] = true,
			['To'] = '@SilverWF',
			['SendRaw'] = true,
			['SendMaterials'] = true,
			['SendBoosters'] = true,
			['Subject'] = 'RETURN my Cloth please',
			['MinNumber'] = 1,
			['SendEquipment'] = true,
			['MinEquipment'] = 1,			
			['MaxEquipment'] = 4,
			['KeepISa'] = true,	
			['SendOrnate'] = false},
		['Metal'] = {
			['Send'] = true,
			['To'] = '@SilverWF',
			['Subject'] = 'RETURN my Metal please',
			['SendRaw'] = true,
			['SendMaterials'] = true,
			['SendBoosters'] = true,
			['MinNumber'] = 1,
			['SendEquipment'] = true,
			['MinEquipment'] = 1,
			['MaxEquipment'] = 4,
			['KeepISa'] = true,
			['SendOrnate'] = false},		
		['Jwlr'] = {
			['Send'] = true,
			['To'] = '@SilverWF',
			['SendRaw'] = true,
			['SendMaterials'] = true,
			['SendBoosters'] = true,
			['Subject'] = 'RETURN my Jewelry please',
			['MinNumber'] = 1,
			['SendEquipment'] = true,
			['MinEquipment'] = 1,
			['MaxEquipment'] = 4,
			['KeepISa'] = true,
			['SendOrnate'] = false},	
		['Wood'] = {
			['Send'] = true,
			['To'] = '@SilverWF',
			['SendRaw'] = true,
			['SendMaterials'] = true,
			['SendBoosters'] = true,
			['Subject'] = 'RETURN my Wood please',
			['MinEquipment'] = 1,
			['MaxEquipment'] = 4,
			['SendEquipment'] = true,
			['MinNumber'] = 1,
			['KeepISa'] = true,
			['SendOrnate'] = false},
		['Food'] = {
			['Send'] = true,
			['KeepISa'] = true,	
			['To'] = '@SilverWF',
			['Subject'] = 'RETURN my Food please',
			['SendMaterials'] = true,
			['SendBoosters'] = true,
			['MinNumber'] = 1},
		['Alchemy'] = {
			['Send'] = true,
			['KeepISa'] = true,
			['To'] = '@SilverWF',
			['Subject'] = 'RETURN my Alchemy please',
			['MinNumber'] = 1},
		['Glyph'] = {
			['Send'] = true,
			['KeepISa'] = true,
			['To'] = '@SilverWF',
			['Subject'] = 'RETURN my Glyphs please',
			['SendRaw'] = true,
			['SendMaterials'] = true,
			['SendBoosters'] = true,
			['SendEquipment'] = true,
			['MinNumber'] = 1}
		},
	delay = 3000
}

function AdvancedAutoLoot:New( ... )
	local result =  ZO_Object.New( self )
	result:Initialize( ... )
	return result
end

--------------------------------------------------------------------------------------------------------------------
-- Toggle autoloot
--------------------------------------------------------------------------------------------------------------------
local function AA_AutoLootToggle() 
	local newState = 1 - GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT)
	SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, newState)
	if newState == 1 then
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.ACHIEVEMENT_AWARDED, "Autoloot is " .. "|c00FF0Cactive" .. "|r now")  
	else
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.DIALOG_DECLINE, "Autoloot is " .. "|cFF002Ainactive" .. "|r now")
	end
end

--------------------------------------------------------------------------------------------------------------------
-- Toggle autoloot stolen
--------------------------------------------------------------------------------------------------------------------
local function AA_AutoStealToggle() 
	local newState = 1 - GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN)
	SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, newState)
	if newState == 1 then
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.ACHIEVEMENT_AWARDED, "Autoloot stolen is " .. "|c00FF0Cenabled" .. "|r now")  
	else
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.DIALOG_DECLINE, "Autoloot stolen is " .. "|cFF002Adisabled" .. "|r now")
	end
end

--------------------------------------------------------------------------------------------------------------------
-- Initialize
--------------------------------------------------------------------------------------------------------------------
function AdvancedAutoLoot:Initialize( control )
	self.control = control
	self.control:RegisterForEvent( EVENT_ADD_ON_LOADED, function( ... ) self:OnLoaded( ... ) end )
	CBM:RegisterCallback( Config.EVENT_TOGGLE_AUTOLOOT, function() self:ToggleAutoLoot()    end )
	ZO_CreateStringId("SI_BINDING_NAME_AAL_AUTOLOOT", "|cFFFF70Autoloot|r change state")    
	ZO_CreateStringId("SI_BINDING_NAME_AAL_LOOTSTOLEN", "|cFF7070Autoloot stolen|r change state") 
	ZO_CreateStringId("SI_BINDING_NAME_AAL_SETTINGS", "Open |c99FF99AAL|r settings window")  
	SLASH_COMMANDS['/aaloot'] = function() AA_AutoLootToggle() end  
	SLASH_COMMANDS['/aasteal'] = function() AA_AutoStealToggle() end
end

function AdvancedAutoLoot:OnLoaded( event, addon )
	if addon ~="AdvancedAutoLoot" then return end         
	self.db = ZO_SavedVars:NewAccountWide( 'AdvancedAutoLoot_Db', 1.3, nil, defaults )   
	if not AdvancedAutoLoot_Db.Default[GetDisplayName()]['$AccountWide']["accountWide"] then self.db = ZO_SavedVars:New( 'AdvancedAutoLoot_Db', 1.3, nil, defaults ) end
	self.config = Config:New( self.db )
	self:ToggleAutoLoot()
	self.control:RegisterForEvent( EVENT_MAIL_OPEN_MAILBOX, function( ... ) self:CreateButtons( ... ) end )
	self.control:RegisterForEvent( EVENT_MAIL_INBOX_UPDATE, function( ... ) self:AutoMailBouncer( ... ) end )  
	self.control:RegisterForEvent( EVENT_MAIL_CLOSE_MAILBOX, function( ... ) self:RemoveButtons( ... ) end )
	self.control:RegisterForEvent( EVENT_MAIL_SEND_FAILED, function( ... ) self:OnMailFailure( ... ) end )
	self.control:RegisterForEvent( EVENT_OPEN_STORE, function() self:SellJunkItems() end )
end

--------------------------------------------------------------------------------------------------------------------
-- Toggle loot filtration
--------------------------------------------------------------------------------------------------------------------
function AdvancedAutoLoot:ToggleAutoLoot()
	if( self.db.autoLootActivated ) then
		self.control:RegisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function( _, ... ) self:OnInventoryUpdated( ... )  end)
	else
		self.control:UnregisterForEvent( EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
	end
end

--------------------------------------------------------------------------------------------------------------------
-- Loot qualification, need for mailer
--------------------------------------------------------------------------------------------------------------------
function AdvancedAutoLoot:IsOrnate(bagId,slotId)
return GetItemTrait(bagId,slotId) == ITEM_TRAIT_TYPE_ARMOR_ORNATE
	or GetItemTrait(bagId,slotId) == ITEM_TRAIT_TYPE_WEAPON_ORNATE
	or GetItemTrait(bagId,slotId) == ITEM_TRAIT_TYPE_JEWELRY_ORNATE
end

function AdvancedAutoLoot:IsRawMaterial(bagId,slotId)
return GetItemType(bagId,slotId) == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL
	or GetItemType(bagId,slotId) == ITEMTYPE_WOODWORKING_RAW_MATERIAL
	or GetItemType(bagId,slotId) == ITEMTYPE_CLOTHIER_RAW_MATERIAL
	or GetItemType(bagId,slotId) == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL
	or GetItemType(bagId,slotId) == ITEMTYPE_ENCHANTING_RUNE_ESSENCE
end

function AdvancedAutoLoot:IsMaterial(bagId,slotId)
return GetItemType(bagId,slotId) == ITEMTYPE_BLACKSMITHING_MATERIAL
	or GetItemType(bagId,slotId) == ITEMTYPE_WOODWORKING_MATERIAL
	or GetItemType(bagId,slotId) == ITEMTYPE_CLOTHIER_MATERIAL
	or GetItemType(bagId,slotId) == ITEMTYPE_ENCHANTING_RUNE_POTENCY
	or GetItemType(bagId,slotId) == ITEMTYPE_JEWELRYCRAFTING_MATERIAL
	or GetItemType(bagId,slotId) == ITEMTYPE_INGREDIENT
end

function AdvancedAutoLoot:IsBooster(bagId,slotId)
return GetItemType(bagId,slotId) == ITEMTYPE_BLACKSMITHING_BOOSTER
	or GetItemType(bagId,slotId) == ITEMTYPE_WOODWORKING_BOOSTER
	or GetItemType(bagId,slotId) == ITEMTYPE_CLOTHIER_BOOSTER
	or GetItemType(bagId,slotId) == ITEMTYPE_ENCHANTING_RUNE_ASPECT
	or GetItemType(bagId,slotId) == ITEMTYPE_ENCHANTMENT_BOOSTER
	or GetItemType(bagId,slotId) == ITEMTYPE_JEWELRYCRAFTING_BOOSTER
	or GetItemType(bagId,slotId) == ITEMTYPE_FLAVORING
end

function AdvancedAutoLoot:GetQuality(bagId,slotId)
	local _,_,_,_,_,_,_,qual = GetItemInfo(bagId,slotId)
	return qual
end

function AdvancedAutoLoot:GetArmorCraftType(bagId,slotId)
	local armorCraftType = 'none'
	local armorType = GetItemArmorType(bagId,slotId)
	if armorType ~= ARMORTYPE_NONE then
		if armorType == ARMORTYPE_LIGHT or armorType == ARMORTYPE_MEDIUM then
			armorCraftType = 'cloth'
		elseif armorType == ARMORTYPE_HEAVY then
			armorCraftType = 'metal'
		else
			armorCraftType = 'none'
		end
	end
	return armorCraftType
end

function AdvancedAutoLoot:GetWeaponCraftType(bagId,slotId)
	local weaponCraftType = 'none'
	local weaponType = GetItemWeaponType(bagId,slotId)
	if weaponType ~= WEAPONTYPE_NONE and weaponType ~= WEAPONTYPE_RUNE then
		if weaponType == WEAPONTYPE_AXE or weaponType == WEAPONTYPE_DAGGER or weaponType == WEAPONTYPE_HAMMER or weaponType == WEAPONTYPE_SWORD or weaponType == WEAPONTYPE_TWO_HANDED_AXE or weaponType == WEAPONTYPE_TWO_HANDED_HAMMER or weaponType == WEAPONTYPE_TWO_HANDED_SWORD then
			weaponCraftType = 'metal'
		elseif weaponType == WEAPONTYPE_BOW or weaponType == WEAPONTYPE_FIRE_STAFF or weaponType == WEAPONTYPE_FROST_STAFF or weaponType == WEAPONTYPE_HEALING_STAFF or weaponType == WEAPONTYPE_LIGHTNING_STAFF or weaponType == WEAPONTYPE_SHIELD then
			weaponCraftType = 'wood'
		else
			weaponCraftType = 'none'
		end
	end
	return weaponCraftType
end

function AdvancedAutoLoot:IsJewelry(bagId,slotId)
	local isJewelry = false
	local _,_,_,_,_,equipType,_,_ = GetItemInfo(bagId,slotId) 
	if equipType == 2 or equipType == 12 then
		isJewelry = true
	else 
		isJewelry = false
	end
	return isJewelry
end

function AdvancedAutoLoot:IsGlyph(bagId,slotId)
	local isGlyph = false
	local itemType = GetItemType(bagId,slotId)
	if itemType == ITEMTYPE_GLYPH_ARMOR or itemType == ITEMTYPE_GLYPH_JEWELRY or itemType == ITEMTYPE_GLYPH_WEAPON then
		isGlyph = true
	else 
		isGlyph = false
	end
	return isGlyph
end


--------------------------------------------------------------------------------------------------------------------
-- Mail Sender
--------------------------------------------------------------------------------------------------------------------
function AdvancedAutoLoot:SendFoodMails()
	local stack = 0
	local mailtext = ""
	local addtext = ""
	local bagSlots = GetBagSize(BAG_BACKPACK)
	local numSlot = 1
	local canAttach = false
	local currConfig = self.db.mailSettings.Food
	for i=0,bagSlots,1 do
		canAttach = CanQueueItemAttachment(1,i,numSlot)
		if not IsItemJunk(1,i) and canAttach then
			local usedInCraftingType, itemType, extraInfo1, extraInfo2, extraInfo3 = GetItemCraftingInfo(1,i)    
			if usedInCraftingType == CRAFTING_TYPE_PROVISIONING 
			and (not self:IsMaterial(1,i) or currConfig.SendMaterials)
			and (not self:IsBooster(1,i) or currConfig.SendBoosters)
			and not (ItemSaver and currConfig.KeepISa and ItemSaver_IsItemSaved(1,i)) 
			and not (FCOIS and currConfig.KeepISa and FCOIS.IsMailLocked(1,i)) then 
				addtext = GetItemLink (1,i)
				_,stack,_,_,_,_,_,_ = GetItemInfo(1,i)
				if stack > 1 then mailtext = mailtext.."\n"..addtext.." x"..tostring(stack) else mailtext = mailtext.."\n"..addtext end
				addtext = ""
				QueueItemAttachment(1,i,numSlot)
				numSlot = numSlot + 1
				if(numSlot == 7) then 
					SendMail(currConfig.To,currConfig.Subject, "Contains:"..mailtext)
					d("|c99FF99AAL:|cFFFFFF Sending 1 mail to "..currConfig.To..", with 6 provisioning items")
					numSlot = 1
					mailtext = ""
					zo_callLater(function() ADVANCED_AUTOLOOT:SendFoodMails() end, self.db.delay)
					return
				end
			end
		end	
	end
	if(numSlot > 1) then 
		if(numSlot - 1) >= currConfig.MinNumber then
			SendMail(currConfig.To,currConfig.Subject, "Contains:"..mailtext)
			d("|c99FF99AAL:|cFFFFFF Sending 1 mail to "..currConfig.To..", with ".. numSlot-1 .." provisioning items")
			numSlot = 1
		else
			ClearQueuedMail()
		end
		mailtext = ""
	end
	d("|c99FF99AAL:|c70FF70 Finished task 'Send provisioning mails'.|r")
	self.BtnFood.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_food_up.dds]])
end

function AdvancedAutoLoot:SendClothMails()
	local stack = 0
	local mailtext = ""
	local addtext = ""
	local bagSlots = GetBagSize(BAG_BACKPACK)
	local numSlot = 1
	local canAttach = false
	local currConfig = self.db.mailSettings.Cloth
	for i=0,bagSlots,1 do
		canAttach = CanQueueItemAttachment(1,i,numSlot)
		if not IsItemJunk(1,i) and (canAttach) then
			local usedInCraftingType, itemType, extraInfo1, extraInfo2, extraInfo3 = GetItemCraftingInfo(1,i)
			if  (not self:IsOrnate(1,i) or currConfig.SendOrnate)
			and (not self:IsMaterial(1,i) or currConfig.SendMaterials)
			and (not self:IsRawMaterial(1,i) or currConfig.SendRaw)
			and (not self:IsBooster(1,i) or currConfig.SendBoosters)
			and (usedInCraftingType == CRAFTING_TYPE_CLOTHIER or ( currConfig.SendEquipment and self:GetQuality(1,i) >= currConfig.MinEquipment and self:GetQuality(1,i) <= currConfig.MaxEquipment and self:GetArmorCraftType(1,i) == 'cloth'))
			and not (ItemSaver and currConfig.KeepISa and ItemSaver_IsItemSaved(1,i))
			and not (FCOIS and currConfig.KeepISa and FCOIS.IsMailLocked(1,i)) then 
				addtext = GetItemLink (1,i)
				_,stack,_,_,_,_,_,_ = GetItemInfo(1,i)
				if stack > 1 then mailtext = mailtext.."\n"..addtext.." x"..tostring(stack) else mailtext = mailtext.."\n"..addtext end
				addtext = ""
				QueueItemAttachment(1,i,numSlot)
				numSlot = numSlot + 1
				if(numSlot == 7) then 
					SendMail(currConfig.To,currConfig.Subject, "Contains:"..mailtext)
					d("|c99FF99AAL:|cFFFFFF Sending 1 mail to "..currConfig.To..", with 6 clothing items")
					numSlot = 1
					mailtext = ""
					zo_callLater(function() ADVANCED_AUTOLOOT:SendClothMails() end, self.db.delay)
					return
				end
			end
		end	
	end
	if(numSlot > 1) then 
		if(numSlot - 1) >= currConfig.MinNumber then
			SendMail(currConfig.To,currConfig.Subject, "Contains:"..mailtext)
			d("|c99FF99AAL:|cFFFFFF Sending 1 mail to "..currConfig.To..", with ".. numSlot -1 .." clothing items")
			numSlot=1
		else
			ClearQueuedMail()
		end
		mailtext = ""
	end
	d("|c99FF99AAL:|c70FF70 Finished task 'Send clothing mails'.|r")
	self.BtnCloth.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_cloth_up.dds]])

end

function AdvancedAutoLoot:SendGlyphMails()
	local stack = 0
	local mailtext = ""
	local addtext = ""
	local bagSlots = GetBagSize(BAG_BACKPACK)
	local numSlot = 1
	local canAttach = false
	local currConfig = self.db.mailSettings.Glyph
	for i=0,bagSlots,1 do
		canAttach = CanQueueItemAttachment(1,i,numSlot)
		if not IsItemJunk(1,i) and (canAttach) then
			local usedInCraftingType, itemType, extraInfo1, extraInfo2, extraInfo3 = GetItemCraftingInfo(1,i)
			if (not self:IsRawMaterial(1,i) or currConfig.SendRaw)
			and (not self:IsMaterial(1,i) or currConfig.SendMaterials)
			and (not self:IsBooster(1,i) or currConfig.SendBoosters) 
			and (usedInCraftingType == CRAFTING_TYPE_ENCHANTING or ( currConfig.SendEquipment and self:IsGlyph(1,i))) then 
				addtext = GetItemLink (1,i)
				_,stack,_,_,_,_,_,_ = GetItemInfo(1,i)
				if stack > 1 then mailtext = mailtext.."\n"..addtext.." x"..tostring(stack) else mailtext = mailtext.."\n"..addtext end
				addtext = ""
				QueueItemAttachment(1,i,numSlot)
				numSlot = numSlot + 1
				if(numSlot == 7) then 
					SendMail(currConfig.To,currConfig.Subject, "Contains:"..mailtext)
					d("|c99FF99AAL:|cFFFFFF Sending 1 mail to "..currConfig.To..", with 6 enchanting items")
					numSlot = 1
					mailtext = ""
					zo_callLater(function() ADVANCED_AUTOLOOT:SendGlyphMails() end, self.db.delay)
					return
				end
			end
		end	
	end
	if(numSlot > 1) then 
		if(numSlot - 1) >= currConfig.MinNumber then
			SendMail(currConfig.To,currConfig.Subject, "Contains:"..mailtext)
			d("|c99FF99AAL:|cFFFFFF Sending 1 mail to "..currConfig.To..", with ".. numSlot -1 .." enchanting items")
			numSlot=1
		else
			ClearQueuedMail()
		end
		mailtext = ""
	end
	d("|c99FF99AAL:|c70FF70 Finished task 'Send enchanting mails'.|r")
	self.BtnGlyph.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_glyph_up.dds]])
end

function AdvancedAutoLoot:SendMetalMails()
	local stack = 0
	local mailtext = ""
	local addtext = ""
	local bagSlots = GetBagSize(BAG_BACKPACK)
	local numSlot = 1
	local canAttach = false
	local currConfig = self.db.mailSettings.Metal
	for i=0,bagSlots,1 do
		canAttach = CanQueueItemAttachment(1,i,numSlot)
		if not IsItemJunk(1,i) and (canAttach) then
			local usedInCraftingType, itemType, extraInfo1, extraInfo2, extraInfo3 = GetItemCraftingInfo(1,i)
			if  (not self:IsOrnate(1,i) or currConfig.SendOrnate) 
			and	(not self:IsMaterial(1,i) or currConfig.SendMaterials) 
			and	(not self:IsRawMaterial(1,i) or currConfig.SendRaw) 
			and	(not self:IsBooster(1,i) or currConfig.SendBoosters) 
			and	(usedInCraftingType == CRAFTING_TYPE_BLACKSMITHING or (currConfig.SendEquipment and self:GetQuality(1,i) >= currConfig.MinEquipment and self:GetQuality(1,i) <= currConfig.MaxEquipment and  (self:GetArmorCraftType(1,i) == 'metal' or self:GetWeaponCraftType(1,i) == 'metal' ))) 
			and not (ItemSaver and currConfig.KeepISa and ItemSaver_IsItemSaved(1,i))
			and not (FCOIS and currConfig.KeepISa and FCOIS.IsMailLocked(1,i)) then  				
				addtext = GetItemLink (1,i)
				_,stack,_,_,_,_,_,_ = GetItemInfo(1,i)
				if stack > 1 then mailtext = mailtext.."\n"..addtext.." x"..tostring(stack) else mailtext = mailtext.."\n"..addtext end
				addtext = ""
				QueueItemAttachment(1,i,numSlot)
				numSlot = numSlot + 1
				if(numSlot == 7) then 
					SendMail(currConfig.To,currConfig.Subject, "Contains:"..mailtext)
					d("|c99FF99AAL:|cFFFFFF Sending 1 mail to "..currConfig.To..", with 6 blacksmithing items")
					numSlot = 1
					mailtext = ""
					zo_callLater(function() ADVANCED_AUTOLOOT:SendMetalMails() end, self.db.delay)
					return
				end
			end
		end	
	end
	if(numSlot > 1) then 
		if(numSlot - 1) >= currConfig.MinNumber then
			SendMail(currConfig.To,currConfig.Subject, "Contains:"..mailtext)
			d("|c99FF99AAL:|cFFFFFF Sending 1 mail to "..currConfig.To..", with ".. numSlot -1 .." blacksmithing items")
			numSlot=1
		else
			ClearQueuedMail()
		end
		mailtext = ""
	end
	d("|c99FF99AAL:|c70FF70 Finished task 'Send blacksmithing items'.|r")
	self.BtnMetal.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_metal_up.dds]])
end

function AdvancedAutoLoot:SendWoodMails()
	local stack = 0
	local mailtext = ""
	local addtext = ""
	local bagSlots = GetBagSize(BAG_BACKPACK)
	local numSlot = 1
	local canAttach = false
	local currConfig = self.db.mailSettings.Wood
	for i=0,bagSlots,1 do
		canAttach = CanQueueItemAttachment(1,i,numSlot)
		if not IsItemJunk(1,i) and (canAttach) then
			local usedInCraftingType, itemType,extraInfo1,extraInfo2,extraInfo3 = GetItemCraftingInfo(1,i)			
			if (not self:IsOrnate(1,i) or currConfig.SendOrnate) 
			and	(not self:IsMaterial(1,i) or currConfig.SendMaterials) 
			and	(not self:IsRawMaterial(1,i) or currConfig.SendRaw) 
			and	(not self:IsBooster(1,i) or currConfig.SendBoosters) 
			and	(usedInCraftingType == CRAFTING_TYPE_WOODWORKING or (currConfig.SendEquipment and self:GetQuality(1,i) >= currConfig.MinEquipment and self:GetQuality(1,i) <= currConfig.MaxEquipment and self:GetWeaponCraftType(1,i) == 'wood')) 
			and not (ItemSaver and currConfig.KeepISa and ItemSaver_IsItemSaved(1,i))
			and not (FCOIS and currConfig.KeepISa and FCOIS.IsMailLocked(1,i)) then  
				addtext = GetItemLink (1,i)
				_,stack,_,_,_,_,_,_ = GetItemInfo(1,i)
				if stack > 1 then mailtext = mailtext.."\n"..addtext.." x"..tostring(stack) else mailtext = mailtext.."\n"..addtext end
				addtext = ""
				QueueItemAttachment(1,i,numSlot)
				numSlot = numSlot + 1
				if(numSlot == 7) then 
					SendMail(currConfig.To,currConfig.Subject, "Contains:"..mailtext)
					d("|c99FF99AAL:|cFFFFFF Sending 1 mail to "..currConfig.To..", with 6 woodworking items")
					numSlot = 1
					mailtext = ""
					zo_callLater(function() ADVANCED_AUTOLOOT:SendWoodMails() end, self.db.delay)
					return
				end
			end
		end	
	end
	if(numSlot > 1) then 
		if(numSlot - 1) >= currConfig.MinNumber then
			SendMail(currConfig.To,currConfig.Subject,"Contains:"..mailtext)
			d("|c99FF99AAL:|cFFFFFF Sending 1 mail to "..currConfig.To..", with ".. numSlot -1 .." woodworking items")
			numSlot=1
		else
			ClearQueuedMail()
		end
		mailtext = ""
	end
	d("|c99FF99AAL:|c70FF70 Finished task 'Send woodworking items'.|r")      
	self.BtnWood.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_wood_up.dds]])

end

function AdvancedAutoLoot:SendJwlrMails()
	local stack = 0
	local mailtext = ""
	local addtext = ""
	local bagSlots = GetBagSize(BAG_BACKPACK)
	local numSlot = 1
	local canAttach = false
	local currConfig = self.db.mailSettings.Jwlr
	for i=0,bagSlots,1 do
		canAttach = CanQueueItemAttachment(1,i,numSlot)
		if not IsItemJunk(1,i) and (canAttach) then
			local usedInCraftingType, itemType,extraInfo1,extraInfo2,extraInfo3 = GetItemCraftingInfo(1,i)
			if (not self:IsOrnate(1,i) or currConfig.SendOrnate) 
			and	(not self:IsMaterial(1,i) or currConfig.SendMaterials) 
			and	(not self:IsRawMaterial(1,i) or currConfig.SendRaw) 
			and	(not self:IsBooster(1,i) or currConfig.SendBoosters) 
			and	(usedInCraftingType == CRAFTING_TYPE_JEWELRYCRAFTING or (currConfig.SendEquipment and self:GetQuality(1,i) >= currConfig.MinEquipment and self:GetQuality(1,i) <= currConfig.MaxEquipment and self:IsJewelry(1,i)))
			and not (ItemSaver and currConfig.KeepISa and ItemSaver_IsItemSaved(1,i))
			and not (FCOIS and currConfig.KeepISa and FCOIS.IsMailLocked(1,i)) then  		
				addtext = GetItemLink (1,i)
				_,stack,_,_,_,_,_,_ = GetItemInfo(1,i)
				if stack > 1 then mailtext = mailtext.."\n"..addtext.." x"..tostring(stack) else mailtext = mailtext.."\n"..addtext end
				addtext = ""
				QueueItemAttachment(1,i,numSlot)
				numSlot = numSlot + 1
				if(numSlot == 7) then 
					SendMail(currConfig.To, currConfig.Subject, "Contains:"..mailtext)
					d("|c99FF99AAL:|cFFFFFF Sending 1 mail to "..currConfig.To..", with 6 jewelrycrafting items")
					numSlot = 1
					mailtext = ""
					zo_callLater(function() ADVANCED_AUTOLOOT:SendJwlrMails() end, self.db.delay)
					return
				end
			end
		end	
	end
	if(numSlot > 1) then 
		if(numSlot - 1) >= currConfig.MinNumber then
			SendMail(currConfig.To, currConfig.Subject, "Contains:"..mailtext)
			d("|c99FF99AAL:|cFFFFFF Sending 1 mail to "..currConfig.To..", with ".. numSlot -1 .." jewelrycrafting items")
			numSlot=1
		else
			ClearQueuedMail()
		end
		mailtext = ""
	end
	d("|c99FF99AAL:|c70FF70 Finished task 'Send jewelrycrafting items'.|r")
	self.BtnJwlr.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_jwlr_up.dds]])
end

function AdvancedAutoLoot:SendAlchemyMails()
	local stack = 0
	local mailtext = ""
	local addtext = ""
	local bagSlots = GetBagSize(BAG_BACKPACK)
	local numSlot = 1
	local canAttach = false
	local currConfig = self.db.mailSettings.Alchemy
	for i=0,bagSlots,1 do
		canAttach = CanQueueItemAttachment(1,i,numSlot)
		if not IsItemJunk(1,i) and (canAttach) then
			local usedInCraftingType, itemType, extraInfo1, extraInfo2, extraInfo3 = GetItemCraftingInfo(1,i)	
			if usedInCraftingType == CRAFTING_TYPE_ALCHEMY then 
				addtext = GetItemLink (1,i)
				_,stack,_,_,_,_,_,_ = GetItemInfo(1,i)
				if stack > 1 then mailtext = mailtext.."\n"..addtext.." x"..tostring(stack) else mailtext = mailtext.."\n"..addtext end
				addtext = ""
				QueueItemAttachment(1,i,numSlot)
				numSlot = numSlot + 1
				if(numSlot == 7) then 
					SendMail(currConfig.To, currConfig.Subject, "Contains:"..mailtext)
					d("|c99FF99AAL|cFFFFFF: Sending 1 mail to "..currConfig.To..", with 6 alchemy items")
					numSlot = 1
					mailtext = ""
					zo_callLater(function() ADVANCED_AUTOLOOT:SendAlchemyMails() end, self.db.delay)
					return
				end
			end
		end	
	end
	if(numSlot > 1) then 
		if(numSlot - 1) >= currConfig.MinNumber then
			SendMail(currConfig.To, currConfig.Subject, "Contains:"..mailtext)
			d("|c99FF99AAL|cFFFFFF: Sending 1 mail to "..currConfig.To..", with ".. numSlot -1 .." alchemy items")
			numSlot=1
		else
			ClearQueuedMail()
		end
		mailtext = ""
	end
	d("|c99FF99AAL:|c70FF70 Finished task 'Send alchemy items'.|r")
	self.BtnAlchemy.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_alchemy_up.dds]])
end


--------------------------------------------------------------------------------------------------------------------
-- Loot filtration
--------------------------------------------------------------------------------------------------------------------
local function itemSalvageable (itemLink)
  if IsItemLinkForcedNotDeconstructable (itemLink) then return false -- Newest function of the API ver.100023, returns 'true' if item cannot be deconstructed
  else return true
  end
end

local function styleCommon (style) -- Common are: Dunmer (4), Bosmer (8), Khajiit (9), Redguard (2), Nord (5), Orc (3), Altmer (7), Breton (1), Argonian (6), Imperial (34)
	if style == 1 or style == 2 or style == 3 or style == 4 or style == 5 or style == 6 or style == 7 or style == 8 or style == 9 or style == 34 then return true
	else return false
	end
end

local function styleRare (style) -- Rare are: Ancient Elf (15), Barbaric (17), Primal (19), Daedric (20), Soul-Shriven (30), Mercenary (26), Glass (28), Xivkyn (29), Yokudan (35), Draugr (31), Ra Gada (44), Ashlander (54)
	if style == 15 or style == 17 or style == 19 or style == 20 or style == 26 or style == 28 or style == 29 or style == 30 or style == 31 or style == 35 or style == 44 or style == 54 then return true
	else return false 
	end
end

local function styleExotic (style) -- Exotic are: all others
	if style > 0 and not styleRare(style) and not styleCommon (style) then return true
	else return false   
	end
end

function AdvancedAutoLoot:IsItemResearchable(itemLink, announceJunk, bagId, slotId)
	if not CS then return false end
	
	local craft,line,trait = CS.GetTrait(itemLink)
	if not craft or not line or not trait then return false end
	
	-- This is overkill part, coz research filters already last, so if item can't be researched, then it would go to junk. It's better to store item for research, even set item and ignore CS settings here, rather than just junk them with no use.
	-- local itemSet = GetItemLinkSetInfo (itemLink)
	-- if itemSet and itemSet ~= "" and not CS.Account.option[14] then return false end -- Check if set items are allowed to be marked for research in the CraftStore, if not - AAL would ignore them too
	
	local CharacterName = GetUnitName ("player")
	local itemID = Id64ToString(GetItemUniqueId(bagId,slotId)) or ""
	for _, char in pairs(CS.GetCharacters()) do
		local owner = CS.Account.crafting.stored[craft][line][trait].owner or "none"
		--local research = CS.Account.crafting.research[char][craft][line][trait] and "|cFF9999not|r" or "|c99FF99yes|r"
		local haveid = CS.Account.crafting.stored[craft][line][trait].id or ""
		-- if CS.Account.crafting.studies[char][craft][line] then 
			-- d(char..", item: "..itemLink..", craft: "..craft..", line: "..line..", trait: "..trait..", can learn: "..research..", owner: "..owner..", id: "..haveid..", itemID: "..itemID)
		-- end
		if CS.Account.crafting.studies[char][craft][line] and not CS.Account.crafting.research[char][craft][line][trait] then
			if CS.Account.option[17] or (not CS.Account.option[17] and ((owner == "none") or (owner == CharacterName and haveid == itemID) or (owner ~= "Bank" and owner ~= char))) then -- Check if CraftStore allows to store duplicate items for research, if not - AAL would try to find already stored items of that type and trait in the CraftStore data
				if announceJunk then
					d("|c99FF99AAL|r: "..itemLink.." was kept for trait research by "..char)
				end
				return true
			end
		end
	end
	return false
end



-- EQUIP_TYPE_INVALID 0
-- EQUIP_TYPE_HEAD 1
-- EQUIP_TYPE_NECK 2
-- EQUIP_TYPE_CHEST 3
-- EQUIP_TYPE_SHOULDERS 4
-- EQUIP_TYPE_ONE_HAND 5
-- EQUIP_TYPE_TWO_HAND 6
-- EQUIP_TYPE_OFF_HAND 7
-- EQUIP_TYPE_WAIST 8 
-- EQUIP_TYPE_LEGS 9
-- EQUIP_TYPE_FEET 10
-- EQUIP_TYPE_COSTUME 11
-- EQUIP_TYPE_RING 12
-- EQUIP_TYPE_HAND 13
-- EQUIP_TYPE_MAIN_HAND 14
-- EQUIP_TYPE_POISON 15


-- Main autojunk function
function AdvancedAutoLoot:OnInventoryUpdated(bagId,slotId,isNewItem,itemSoundCategory,inventoryUpdateReason,stackCountChange)
	if (bagId==1 and isNewItem) then
    local isStolen = IsItemStolen(bagId,slotId)
	local _,_,_,_,_,equipType,itemStyle,quality = GetItemInfo(bagId,slotId) 
    local itemType, itemTypeS = GetItemType(bagId,slotId)
    local itemStack = stackCountChange 
    local itemTrait = GetItemTrait(bagId,slotId)
    local itemLink =  GetItemLink(bagId,slotId) 
    if isStolen and not self.db.allowStolenSort then
      return
    elseif isStolen and (itemType == ITEMTYPE_TRASH or itemType == ITEMTYPE_TREASURE or itemType == ITEMTYPE_TROPHY) and self.db.minSdestroy > 0 and quality <= self.db.minSdestroy then
      self:Destroyer(bagId,slotId,itemLink,itemStack)
      return
    end
    if itemTypeS == SPECIALIZED_ITEMTYPE_COLLECTIBLE_MONSTER_TROPHY or itemType == ITEMTYPE_TRASH or itemType == ITEMTYPE_TREASURE then self:Junker(bagId,slotId,itemLink,itemStack) return end
    if quality >= self.db.minQuality then return end -- It will keep any items above set quality unmatter what
    local itemCrafter = GetItemCreatorName(bagId,slotId)
    if itemCrafter ~= "" and self.db.keepCrafted then return end -- Check for crafted items
    local requiredCP = GetItemRequiredChampionPoints(bagId,slotId)
    local isIntricate = false
    if ItemSaver and self.db.keepISa and ItemSaver_IsItemSaved(bagId,slotId) then return end -- Item Saver handler here 
    if FCOIS and self.db.keepISa and FCOIS.IsJunkLocked(bagId,slotId) then return end -- FCO Item Saver handler here
    if equipType > 0 and equipType~=15 then -- Handler for weapon, armor or jewelry, exclude poison (15)
		if itemTrait == ITEM_TRAIT_TYPE_ARMOR_INTRICATE or itemTrait == ITEM_TRAIT_TYPE_WEAPON_INTRICATE or itemTrait == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE then isIntricate = true end
	  	local itemSet = GetItemLinkSetInfo (itemLink)
		if itemSet and itemSet ~= "" and self.db.keepSetItems then return end -- Check for set items
		if self:IsJewelry(bagId,slotId) and self.db.keepAnyJewelry and requiredCP == 160 and itemSalvageable(itemLink) then return end -- Check for any jewelry
		if equipType == 11 or itemType == ITEMTYPE_DISGUISE or itemType == ITEMTYPE_COSTUME then return -- Save for disguises, costumes etc
        elseif self.db.keepCommonStyle and styleCommon(itemStyle) and itemSalvageable(itemLink) and not self:IsJewelry(bagId,slotId) then return
        elseif self.db.keepRareStyle and styleRare(itemStyle) and itemSalvageable(itemLink) and not self:IsJewelry(bagId,slotId) then return
        elseif self.db.keepExoticStyle and styleExotic(itemStyle) and itemSalvageable(itemLink) and not self:IsJewelry(bagId,slotId) then return            
        elseif self.db.keepIntricate and isIntricate and itemSalvageable(itemLink) then return   
        elseif requiredCP >= self.db.minItemCP and self.db.minItemCP > 0 and itemSalvageable(itemLink) then return
        elseif BTG and self.db.keepBTG and BTG.MatchItemFilter(itemLink).match then return -- Begging the Gear handler here
		elseif self.db.keepResearchable and self.db.keepMainResearchable and CS and self:IsItemResearchable(itemLink, self.db.announceJunk, bagId, slotId) then return -- CraftStore integrations: check for items researchable on the main crafter
		elseif self.db.keepResearchable and CanItemLinkBeTraitResearched(itemLink) and (not self.db.keepMainResearchable or not CS) then return -- Handler for researchable items
        else self:Junker(bagId,slotId,itemLink,itemStack)
        return
      end
    elseif ((itemType == ITEMTYPE_INGREDIENT or itemType == ITEMTYPE_FLAVORING) and not self.db.keepProvisionning) then self:Junker(bagId,slotId,itemLink,itemStack) return
    elseif (itemType == ITEMTYPE_RECIPE and not self.db.keepRecipes) then self:Junker(bagId,slotId,itemLink,itemStack) return
    elseif (itemType == ITEMTYPE_POTION and (not self.db.keepPotions or requiredCP < self.db.keepFoodCP)) then self:Junker(bagId,slotId,itemLink,itemStack) return
    elseif ((itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK) and (not self.db.keepFood or requiredCP < self.db.keepFoodCP)) then self:Junker(bagId,slotId,itemLink,itemStack) return
    elseif (itemType == ITEMTYPE_LURE and not self.db.keepBaits) then self:Junker(bagId,slotId,itemLink,itemStack) return
    elseif (itemType == ITEMTYPE_POISON and (not self.db.keepPoison or requiredCP < self.db.keepPoisonCP)) then self:Junker(bagId,slotId,itemLink,itemStack) return
    elseif ((itemType == ITEMTYPE_GLYPH_ARMOR or itemType == ITEMTYPE_GLYPH_JEWELRY or itemType == ITEMTYPE_GLYPH_WEAPON) and (not self.db.keepGlyph or requiredCP < self.db.keepGlyphCP)) then self:Junker(bagId,slotId,itemLink,itemStack) return
    elseif (itemType == ITEMTYPE_SOUL_GEM and quality > 1 and not self.db.keepSoulgemFull) then self:Junker(bagId,slotId,itemLink,itemStack) return
    elseif (itemType == ITEMTYPE_SOUL_GEM and quality < 2 and not self.db.keepSoulgemEmpty) then self:Junker(bagId,slotId,itemLink,itemStack) return
    else return
    end
  end
end

function AdvancedAutoLoot:Junker(bagId,slotId,itemLink,itemStack)
	if self.db.destroyJprice > 0 then
		local _,stack,price,_,_,_,_,_ = GetItemInfo(bagId,slotId)
		price = price * stack
		if price and price < self.db.destroyJprice then
			self:Destroyer(bagId,slotId,itemLink,itemStack)
			return
		end
	end
	if self.db.announceJunk then
		if itemStack > 1 then 
			d("|c99FF99AAL|r:|cFFFF70 Junked|r "..itemLink.." x"..itemStack)
		else
			d("|c99FF99AAL|r:|cFFFF70 Junked|r "..itemLink)  
		end 
	end
	SetItemIsJunk(bagId,slotId,true)  
	return
end

function AdvancedAutoLoot:Destroyer(bagId,slotId,itemLink,itemStack)
-- All unique items (Museum pieces etc) would be saved here --
  local itemUnique = IsItemLinkUnique(itemLink)  
  if itemUnique then
    d("|c99FF99AAL|r: |c70FF70Unique item saved|r "..itemLink)
    return
  end

  if itemStack > 1 then 
    d("|c99FF99AAL|r:|cFF7070 Deleted|r "..itemLink.." x"..itemStack)
  else
    d("|c99FF99AAL|r:|cFF7070 Deleted|r "..itemLink)  
  end

  DestroyItem(bagId,slotId)
  return
end

-- End of main autojunk functionn

function AdvancedAutoLoot_Initialized( self )
    ADVANCED_AUTOLOOT = AdvancedAutoLoot:New( self )
end

function AdvancedAutoLoot:CreateCallBack(craft,textureDown,textureUp)
	return function(self)
		self.Icon:SetTexture(textureUp)	
		if craft == 'ALCHEMY' then
			d("|c99FF99AAL:|cFFFF70 Starting Alchemy send task|r")
			self.Icon:SetTexture(textureDown)
			ADVANCED_AUTOLOOT:SendAlchemyMails()
		elseif craft == 'CLOTH' then
			d("|c99FF99AAL:|cFFFF70 Starting Clothing send task|r")
			self.Icon:SetTexture(textureDown)
			ADVANCED_AUTOLOOT:SendClothMails()
		elseif craft == 'FOOD' then
			d("|c99FF99AAL:|cFFFF70 Starting Provisioning send task|r")
			self.Icon:SetTexture(textureDown)
			ADVANCED_AUTOLOOT:SendFoodMails()
		elseif craft == 'GLYPH' then
			d("|c99FF99AAL:|cFFFF70 Starting Enchanting send task|r")
			self.Icon:SetTexture(textureDown)
			ADVANCED_AUTOLOOT:SendGlyphMails()
		elseif craft == 'METAL' then
			d("|c99FF99AAL:|cFFFF70 Starting Blacksmithing send task|r")
			self.Icon:SetTexture(textureDown)
			ADVANCED_AUTOLOOT:SendMetalMails()
		elseif craft == 'WOOD' then
			d("|c99FF99AAL:|cFFFF70 Starting Woodworking send task|r")
			self.Icon:SetTexture(textureDown)
			ADVANCED_AUTOLOOT:SendWoodMails()
		elseif craft == 'JWLR' then
			d("|c99FF99AAL:|cFFFF70 Starting Jewelry send task|r")
			self.Icon:SetTexture(textureDown)
			ADVANCED_AUTOLOOT:SendJwlrMails()
		end
	end
end


function AdvancedAutoLoot:CreateButton(name,anchor,textureUp,textureDown,craft,visible)
	local btn = ZO_MainMenuSceneGroupBar:CreateControl(name,CT_CONTROL)
	btn:SetMouseEnabled(true)
	--btn:SetHandler('OnMouseEnter',ZO_MenuBarButtonTemplate_OnMouseEnter)
	btn:SetParent(ZO_MainMenuSceneGroupBar)
	btn:SetHidden(not visible)
	
	if(visible) then
		btn:SetAnchor(LEFT,self.LastAnchor,RIGHT,20,0)
		self.LastAnchor = btn
	end
	btn:SetWidth(32)
	btn:SetHeight(32)
	btn:SetHandler('OnMouseEnter',function (self)
		InitializeTooltip(InformationTooltip, self, BOTTOM, 0, -5)
		SetTooltipText(InformationTooltip, craft)
		self.IconHightlight:SetHidden(false) 
	end)
	btn:SetHandler('OnMouseExit',function(self) 
		self.IconHightlight:SetHidden(true) 
		ClearTooltip(InformationTooltip)
		end)
	btn:SetHandler('OnMouseDown',AdvancedAutoLoot:CreateCallBack(craft,textureDown,textureUp))

	local btnImage = btn:CreateControl(name.."_Icon",CT_TEXTURE)
	btn.Icon = btnImage
	btnImage:SetAnchor(128,btn,128,0,0)
	btnImage:SetTexture(textureUp)
	btnImage:SetWidth(64)
	btnImage:SetDrawLayer(2)
	btnImage:SetHeight(64)
	
	local btnImage_Highlight = btn:CreateControl(name.."_Icon_highlight",CT_TEXTURE)
	btn.IconHightlight = btnImage_Highlight
	btnImage_Highlight:SetAnchor(128,btn,128,0,0)
	btnImage_Highlight:SetTexture([[/AdvancedAutoLoot/Textures/mail_tabicon_inbox_over.dds]])
	btnImage_Highlight:SetWidth(64)
	btnImage_Highlight:SetDrawLayer(1)
	btnImage_Highlight:SetHeight(64)
	btnImage_Highlight:SetHidden(true)
	
	return btn
end

function AdvancedAutoLoot:CreateButtons()
	-- if not self.db.autoBouncer then
		-- d("|c99FF99AAL:|cFF7070 Auto-sender disabled. To use it - turn on Mail Bouncer, please")
		-- return
	-- end
	if(self.BtnAlchemy ~= nil) then
		local lastControl = ZO_MainMenuSceneGroupBarButton2
		if(self.db.mailSettings.Alchemy.Send) then
			self.BtnAlchemy:SetHidden(false)
			self.BtnAlchemy:SetAnchor(LEFT,lastControl,RIGHT,20,0)
			lastControl = self.BtnAlchemy
		end
		if(self.db.mailSettings.Cloth.Send) then
			self.BtnCloth:SetHidden(false)
			self.BtnCloth:SetAnchor(LEFT,lastControl,RIGHT,20,0)
			lastControl = self.BtnCloth
		end
		if(self.db.mailSettings.Food.Send) then
			self.BtnFood:SetHidden(false)
			self.BtnFood:SetAnchor(LEFT,lastControl,RIGHT,20,0)
			lastControl = self.BtnFood
		end
		if(self.db.mailSettings.Glyph.Send) then
			self.BtnGlyph:SetHidden(false)
			self.BtnGlyph:SetAnchor(LEFT,lastControl,RIGHT,20,0)
			lastControl = self.BtnGlyph
		end
		if(self.db.mailSettings.Metal.Send) then
			self.BtnMetal:SetHidden(false)
			self.BtnMetal:SetAnchor(LEFT,lastControl,RIGHT,20,0)
			lastControl = self.BtnMetal
		end
		if(self.db.mailSettings.Wood.Send) then
			self.BtnWood:SetHidden(false)
			self.BtnWood:SetAnchor(LEFT,lastControl,RIGHT,20,0)
			lastControl = self.BtnWood
		end
		if(self.db.mailSettings.Jwlr.Send) then
			self.BtnJwlr:SetHidden(false)
			self.BtnJwlr:SetAnchor(LEFT,lastControl,RIGHT,20,0)
			lastControl = self.BtnJwlr
		end
	else
		self.LastAnchor = ZO_MainMenuSceneGroupBarButton2
		self.BtnAlchemy = self:CreateButton('btnMailAlchemy',ZO_MainMenuSceneGroupBarButton2,[[/AdvancedAutoLoot/Textures/mail_alchemy_up.dds]],[[/AdvancedAutoLoot/Textures/mail_alchemy_down.dds]],'ALCHEMY',self.db.mailSettings.Alchemy.Send)
		self.BtnCloth = self:CreateButton('btnMailCloth',self.BtnAlchemy,[[/AdvancedAutoLoot/Textures/mail_cloth_up.dds]],[[/AdvancedAutoLoot/Textures/mail_cloth_down.dds]],'CLOTH',self.db.mailSettings.Cloth.Send)
		self.BtnFood = self:CreateButton('btnMailFood',self.BtnCloth,[[/AdvancedAutoLoot/Textures/mail_food_up.dds]],[[/AdvancedAutoLoot/Textures/mail_food_down.dds]],'FOOD',self.db.mailSettings.Food.Send)
		self.BtnGlyph = self:CreateButton('btnMailGlyph',self.BtnFood,[[/AdvancedAutoLoot/Textures/mail_glyph_up.dds]],[[/AdvancedAutoLoot/Textures/mail_glyph_down.dds]],'GLYPH',self.db.mailSettings.Glyph.Send)
		self.BtnMetal = self:CreateButton('btnMailMetal',self.BtnGlyph,[[/AdvancedAutoLoot/Textures/mail_metal_up.dds]],[[/AdvancedAutoLoot/Textures/mail_metal_down.dds]],'METAL',self.db.mailSettings.Metal.Send)
		self.BtnWood = self:CreateButton('btnMailWood',self.BtnMetal,[[/AdvancedAutoLoot/Textures/mail_wood_up.dds]],[[/AdvancedAutoLoot/Textures/mail_wood_down.dds]],'WOOD',self.db.mailSettings.Wood.Send)
    self.BtnJwlr = self:CreateButton('btnMailJwlr',self.BtnWood,[[/AdvancedAutoLoot/Textures/mail_jwlr_up.dds]],[[/AdvancedAutoLoot/Textures/mail_jwlr_down.dds]],'JWLR',self.db.mailSettings.Jwlr.Send)
	end
end

function AdvancedAutoLoot:RemoveButtons()
	if (self.BtnAlchemy ~= nil) then
		self.BtnAlchemy:SetHidden(true)
		self.BtnCloth:SetHidden(true)
		self.BtnFood:SetHidden(true)
		self.BtnGlyph:SetHidden(true)
		self.BtnMetal:SetHidden(true)
		self.BtnWood:SetHidden(true)
		self.BtnJwlr:SetHidden(true)
	end
	ClearQueuedMail()
end

function AdvancedAutoLoot:OnMailFailure(reason)
	ClearQueuedMail()
	d("|c99FF99AAL:|cFF7070 Mail couldn't be sent.|r Reason: "..reason)
end

--------------------------------------------------------------------------------------------------------------------
-- Autosell junk on every store open
--------------------------------------------------------------------------------------------------------------------
function AdvancedAutoLoot:SellJunkItems(bagID)
	if self.db.autoJunkSell then
		SellAllJunk()
	else return
	end
end

--------------------------------------------------------------------------------------------------------------------
-- Auto mail bouncer
--------------------------------------------------------------------------------------------------------------------
function AdvancedAutoLoot:AutoMailBouncer()
	--if not self.db.autoBouncer then return end
	local numMail = GetNumMailItems()
	if numMail == 0 then return end
	local lastId = nil
	local mailBase = {}
	for m = 1, numMail, 1 do -- Creating table of mails to return
		lastId = GetNextMailId( lastId )
		local SenderAccount, SenderName, Subject, Icon, Unread, SystemMail, CSmail, returnedMail, numAttachments, attMoney, CODvalue, Expires, RecvdTime = GetMailItemInfo( lastId )
		if string.find(SenderAccount, "@") and IsMailReturnable(lastId) and Subject ~= "" and numAttachments > 0 then
			if string.upper(string.sub(Subject,1,6)) == "RETURN" or string.upper(string.sub(Subject,1,6)) == "BOUNCE" then
				local maiL = {
				mailID = lastId,
				mailSender = tostring(SenderAccount),
				mailSubject = tostring(Subject),
				mailAttach = tostring(numAttachments),
        }
				table.insert (mailBase, maiL)
			end
		end
	end
	if table.getn (mailBase) > 0 then -- Returning mails if we have to
		for k, v in pairs (mailBase) do
			ReturnMail( v.mailID )
			d("|c99FF99AAL:|r Returned mail '"..(v.mailSubject).."' from "..(v.mailSender)..", with "..(v.mailAttach).." item(s)")
		end
	end
end

--------------------------------------------------------------------------------------------------------------------
-- Confirmation dialog handlers here
--------------------------------------------------------------------------------------------------------------------
function MAIL_INBOX:Delete() -- Rewritten ZOS deletion function
	if self.mailId then
		if self:IsMailDeletable() then
			local attachments, gold = GetMailAttachmentInfo(self.mailId)
			self.pendingDelete = true
			if attachments > 0 and gold > 0 then
				ZO_Dialogs_ShowDialog("DELETE_MAIL_ATTACHMENTS_AND_MONEY")
			elseif attachments > 0 then
				ZO_Dialogs_ShowDialog("DELETE_MAIL_ATTACHMENTS")
			elseif gold > 0 then
				ZO_Dialogs_ShowDialog("DELETE_MAIL_MONEY")
			elseif AdvancedAutoLoot:ConfirmDelete() then
				self:ConfirmDelete(self.mailId)
      else
        ZO_Dialogs_ShowDialog("DELETE_MAIL", {callback = function(...) self:ConfirmDelete(...) end, mailId = self.mailId})
			end
		end
	end
end

function MAIL_INBOX:Return() -- Rewritten ZOS return function
    if self.mailId then
        if IsMailReturnable(self.mailId) then
            local mailData = self:GetMailData(self.mailId)
            if (mailData.numAttachments > 0 or mailData.attachedMoney > 0) and (not AdvancedAutoLoot:ConfirmReturn()) then
                ZO_Dialogs_ShowDialog("MAIL_RETURN_ATTACHMENTS", {callback = ReturnMail, mailId = self.mailId}, {mainTextParams = {mailData.senderDisplayName}})
            else
                ReturnMail(self.mailId)
            end
        end
    end
end

function AdvancedAutoLoot:ConfirmDelete()
  local AccountName = GetDisplayName()
  if AdvancedAutoLoot_Db.Default[AccountName]['$AccountWide']["accountWide"] then
    if AdvancedAutoLoot_Db.Default[AccountName]['$AccountWide']["deleteDialogSuppress"] then return true
    else return false
    end
  else
    local CharacterName = GetUnitName ("player")
    if AdvancedAutoLoot_Db.Default[AccountName][CharacterName]["deleteDialogSuppress"] then return true
    else return false
    end
  end
end

function AdvancedAutoLoot:ConfirmReturn()
  local AccountName = GetDisplayName()
  if AdvancedAutoLoot_Db.Default[AccountName]['$AccountWide']["accountWide"] then
    if AdvancedAutoLoot_Db.Default[AccountName]['$AccountWide']["returnDialogSuppress"] then return true
    else return false
    end
  else
    local CharacterName = GetUnitName ("player")
    if AdvancedAutoLoot_Db.Default[AccountName][CharacterName]["returnDialogSuppress"] then return true
    else return false
    end
  end
end

local AdvancedAutoLoot = ZO_Object:Subclass()
AdvancedAutoLoot.db = nil
AdvancedAutoLoot.config = nil
AdvancedAutoLoot.DestroyList = {}
AdvancedAutoLoot.KeepRunning = true
AdvancedAutoLoot.TaskRunning = nil
AdvancedAutoLoot.LastAnchor = nil
AdvancedAutoLoot.SkipCloth = false
AdvancedAutoLoot.SkipWood = false
AdvancedAutoLoot.SkipMetal = false
AdvancedAutoLoot.SkipFood = false
AdvancedAutoLoot.SkipGlyph = false
AdvancedAutoLoot.SkipAlchemy = false
local CBM               = CALLBACK_MANAGER
local Config = AdvancedAutoLootConfig

local defaults = 
{
	testData = nil,
	keepOrnate = true,
	keepIntricate = true,
	keepProvisionning = true,
	keepRecipes = true,
	keepFood = true,
	--keepAlchemy = true,
	keepBaits = true,
	minQuality = 2,
	autoLootActivated = false,
	mailSettings = {
		['Cloth'] = {
			['Send'] = false,
			['To'] = '',
			['SendRaw'] = false,
			['SendMaterials'] = false,
			['SendBoosters'] = false,
			['Subject'] = 'Cloth delivery !',
			['MinNumber'] = 1,
			['SendWhite'] = false,
			['SendEquipment'] = true,
			['MaxEquipment'] = 4,
			['SendOrnate'] = false},
		['Metal'] = {
			['Send'] = false,
			['To'] = '',
			['SendRaw'] = false,
			['SendMaterials'] = false,
			['SendBoosters'] = false,
			['Subject'] = 'Metal delivery !',
			['MinNumber'] = 1,
			['SendWhite'] = false,
			['SendEquipment'] = true,
			['MaxEquipment'] = 4,
			['SendOrnate'] = false},		
		['Wood'] = {
			['Send'] = false,
			['To'] = '',
			['SendRaw'] = false,
			['SendMaterials'] = false,
			['SendBoosters'] = false,
			['Subject'] = 'Wood delivery !',
			['MaxEquipment'] = 4,
			['SendEquipment'] = true,
			['MinNumber'] = 1,
			['SendWhite'] = false,
			['SendOrnate'] = false},
		['Food'] = {
			['Send'] = false,
			['To'] = '',
			['SendRaw'] = false,
			['Subject'] = 'Food delivery !',
			['MinNumber'] = 1,
			['SendRecipes'] = false},
		['Alchemy'] = {
			['Send'] = false,
			['To'] = '',
			['SendRaw'] = false,
			['Subject'] = 'Alchemy delivery !',
			['MinNumber'] = 1},
		['Glyph'] = {
			['Send'] = false,
			['To'] = '',
			['SendMaterials'] = false,
			['SendBoosters'] = false,
			['Subject'] = 'Glyph delivery !',
			['MinNumber'] = 1}
		},
	delay = 5000
}

function AdvancedAutoLoot:New( ... )
	local result =  ZO_Object.New( self )
	result:Initialize( ... )
	return result
end

function AdvancedAutoLoot:Initialize( control )
	self.control = control
    self.control:RegisterForEvent( EVENT_ADD_ON_LOADED, function( ... ) self:OnLoaded( ... ) end )
    CBM:RegisterCallback( Config.EVENT_TOGGLE_AUTOLOOT, function() self:ToggleAutoLoot()    end )
end

function AdvancedAutoLoot:OnLoaded( event, addon )
	if addon ~="AdvancedAutoLoot" then 
		return
	end
	self.db = ZO_SavedVars:New( 'AdvancedAutoLoot_Db', 1.3, nil, defaults )
    self.config = Config:New( self.db )

    self:ToggleAutoLoot()
	self.control:RegisterForEvent( EVENT_MAIL_OPEN_MAILBOX, function( ... ) self:CreateButtons( ... ) end )
	self.control:RegisterForEvent( EVENT_MAIL_CLOSE_MAILBOX, function( ... ) self:RemoveButtons( ... ) end )
	self.control:RegisterForEvent( EVENT_MAIL_SEND_FAILED, function( ... ) self:OnMailFailure( ... ) end )
end

function AdvancedAutoLoot:ToggleAutoLoot()
	if( self.db.autoLootActivated ) then
		self.control:RegisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function( _, ... ) self:OnInventoryUpdated( ... )  end) -- Registers for gold change events then calls the CashMoney function.
		self.control:RegisterForEvent(EVENT_LOOT_UPDATED, function( _, ... ) self:OnLootUpdated( ... )  end)
	else
		self.control:UnregisterForEvent( EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
		self.control:UnregisterForEvent( EVENT_LOOT_UPDATED )
	end
end

function AdvancedAutoLoot:OnLootUpdated(numId)
	--d("Loot updated")
	LootMoney()
	local num = GetNumLootItems()
	for i=1,num ,1 do
		local lootId,name,icon,count,quality,value,isQuest = GetLootItemInfo(i)
		local link = GetLootItemLink(lootId,LINK_STYLE_BRACKETS)
		local _ , _, _, equipType, _ = GetItemLinkInfo( link )
		--d("Loot updated: "..link.." unk1"..tostring(unk1).." unk2 "..tostring(unk2).." unk3 "..tostring(unk3).." unk4 "..tostring(unk4).." unk5 "..tostring(unk5).." unk6 "..tostring(unk6))
		--d("Looting item "..GetLootItemLink(lootId,LINK_STYLE_BRACKETS).." quality "..quality)
		if( (equipType > 0 and quality >=self.db.minQuality) or equipType==0 or isQuest) then
			--we keep item 
		else
			table.insert(AdvancedAutoLoot.DestroyList,name)
		end
		
	end
	--d("End looting")
	LootAll()
	EndLooting()
end

function AdvancedAutoLoot:IsOrnate(bagId,slotId)
return GetItemTrait(bagId,slotId) == ITEM_TRAIT_TYPE_ARMOR_ORNATE or GetItemTrait(bagId,slotId) == ITEM_TRAIT_TYPE_WEAPON_ORNATE
end
function AdvancedAutoLoot:IsMaterial(bagId,slotId)
return GetItemType(bagId,slotId) == ITEMTYPE_BLACKSMITHING_MATERIAL
	or GetItemType(bagId,slotId) == ITEMTYPE_WOODWORKING_MATERIAL
	or GetItemType(bagId,slotId) == ITEMTYPE_CLOTHIER_MATERIAL
	or GetItemType(bagId,slotId) == ITEMTYPE_ENCHANTING_RUNE
end
function AdvancedAutoLoot:IsRawMaterial(bagId,slotId)
return GetItemType(bagId,slotId) == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL
	or GetItemType(bagId,slotId) == ITEMTYPE_WOODWORKING_RAW_MATERIAL
	or GetItemType(bagId,slotId) == ITEMTYPE_CLOTHIER_RAW_MATERIAL
end
function AdvancedAutoLoot:IsBooster(bagId,slotId)
return GetItemType(bagId,slotId) == ITEMTYPE_BLACKSMITHING_BOOSTER
	or GetItemType(bagId,slotId) == ITEMTYPE_WOODWORKING_BOOSTER
	or GetItemType(bagId,slotId) == ITEMTYPE_CLOTHIER_BOOSTER
	or GetItemType(bagId,slotId) == ITEMTYPE_ENCHANTMENT_BOOSTER
end
function AdvancedAutoLoot:IsWhite(bagId,slotId)
	local _,_,_,_,_,_,_,qual = GetItemInfo(bagId,slotId)
	return qual == 1
end
function AdvancedAutoLoot:GetQuality(bagId,slotId)
	local _,_,_,_,_,_,_,qual = GetItemInfo(bagId,slotId)
	return qual
end
function AdvancedAutoLoot:SendMails()
	if(not self.KeepRunning) then
		return
	end
	local bagSlots = GetBagSize and GetBagSize(BAG_BACKPACK) or select(2, GetBagInfo(BAG_BACKPACK))
	-- Send glyphs
	local numSlot = 1
	local canAttach
	local currConfig = self.db.mailSettings.Food
-- Send Provisionning Stuff
	if(currConfig.Send and not self.SkipFood and (self.TaskRunning == 'ALL' or self.TaskRunning == 'FOOD')) then
		for i=0,bagSlots,1 do
			if GetItemType(1,i) == ITEMTYPE_INGREDIENT or  (currConfig.SendRecipes and GetItemType(1,i) == ITEMTYPE_RECIPE) then 
				canAttach = CanQueueItemAttachment(1,i,numSlot)
				if(canAttach) then
					QueueItemAttachment(1,i,numSlot)
					numSlot = numSlot + 1
					if(numSlot == 7) then 
						SendMail(currConfig.To,currConfig.Subject,"")
						d("Sent 1 mail to "..currConfig.To.." containing 6 items")
						numSlot = 1
						zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
						return
					end
				
				end
			end	
		end
		if(numSlot ~= 1) then 
			if(numSlot - 1) >= currConfig.MinNumber then
				SendMail(currConfig.To,currConfig.Subject,"")
				d("Sent 1 mail to "..currConfig.To.." containing ".. numSlot -1 .."items")
				numSlot=1
			else
				ClearQueuedMail()
			end
			self.SkipFood = true
			if(self.TaskRunning == 'ALL') then
				zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
				return
			end
		end
		if(self.TaskRunning == 'FOOD') then
			self.TaskRunning = nil
			self.BtnFood.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_food_up.dds]])
		end
	end
	currConfig = self.db.mailSettings.Cloth
	if(currConfig.Send and (self.TaskRunning == 'ALL' or self.TaskRunning == 'CLOTH')) then
		--d("cloth")
		for i=0,bagSlots,1 do
			local usedInCraftingType, itemType,extraInfo1,extraInfo2,extraInfo3 = GetItemCraftingInfo(1,i)
			
			if  (not self:IsOrnate(1,i) or currConfig.SendOrnate) and
			    (not self:IsWhite(1,i) or currConfig.SendWhite or self:IsMaterial(1,i) or self:IsRawMaterial(1,i)) and
			    (not self:IsMaterial(1,i) or currConfig.SendMaterials) and
			    (not self:IsRawMaterial(1,i) or currConfig.SendRaw) and
				(not self:IsBooster(1,i) or currConfig.SendBoosters) and
				(usedInCraftingType == CRAFTING_TYPE_CLOTHIER or 
					( currConfig.SendEquipment and self:GetQuality(1,i) <= currConfig.MaxEquipment and GetItemType(1,i) == ITEMTYPE_ARMOR and (self:GetArmorType(1,i) == ARMORTYPE_MEDIUM or self:GetArmorType(1,i) == ARMORTYPE_LIGHT))) then 
				canAttach = CanQueueItemAttachment(1,i,numSlot)
				--d("Can attach : "..tostring(canAttach))
				if(canAttach) then
					QueueItemAttachment(1,i,numSlot)
					numSlot = numSlot + 1
					if(numSlot == 7) then 
						SendMail(currConfig.To,currConfig.Subject,"")
						d("Sent 1 mail to "..currConfig.To.." containing 6 items")
						numSlot = 1
						zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
						return
					end
				end
			end	
		end
		if(numSlot ~= 1) then 
			if(numSlot - 1) >= currConfig.MinNumber then
				SendMail(currConfig.To,currConfig.Subject,"")
				d("Sent 1 mail to "..currConfig.To.." containing ".. numSlot -1 .."items")
				numSlot=1
			else
				ClearQueuedMail()
			end
			self.SkipCloth = true
			if(self.TaskRunning == 'ALL') then
				zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
				return
			end
		end
		if(self.TaskRunning == 'CLOTH') then
			self.TaskRunning = nil
			self.BtnCloth.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_cloth_up.dds]])
		end
	end
	currConfig = self.db.mailSettings.Glyph
	if(currConfig.Send and (self.TaskRunning == 'ALL' or self.TaskRunning == 'GLYPH')) then
		for i=0,bagSlots,1 do
			local usedInCraftingType, itemType,extraInfo1,extraInfo2,extraInfo3 = GetItemCraftingInfo(1,i)
			if  (not self:IsMaterial(1,i) or currConfig.SendMaterials) and
				(not self:IsBooster(1,i) or currConfig.SendBoosters) and
				(usedInCraftingType == CRAFTING_TYPE_ENCHANTING) then 
				canAttach = CanQueueItemAttachment(1,i,numSlot)
				if(canAttach) then
					QueueItemAttachment(1,i,numSlot)
					numSlot = numSlot + 1
					if(numSlot == 7) then 
						SendMail(currConfig.To,currConfig.Subject,"")
						d("Sent 1 mail to "..currConfig.To.." containing 6 items")
						zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
						return
					end
				end
			end	
		end
		if(numSlot ~= 1) then 
			if(numSlot - 1) >= currConfig.MinNumber then
				SendMail(currConfig.To,currConfig.Subject,"")
				d("Sent 1 mail to "..currConfig.To.." containing ".. numSlot -1 .."items")
				numSlot=1
			else
				ClearQueuedMail()
			end
			self.SkipGlyph = true
			if(self.TaskRunning == 'ALL') then
				zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
				return
			end
		end
		if(self.TaskRunning == 'GLYPH') then
			self.TaskRunning = nil
			self.BtnGlyph.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_glyph_up.dds]])
		end
	end
	currConfig = self.db.mailSettings.Metal
	if(currConfig.Send and (self.TaskRunning == 'ALL' or self.TaskRunning == 'METAL')) then
		for i=0,bagSlots,1 do
			local usedInCraftingType, itemType,extraInfo1,extraInfo2,extraInfo3 = GetItemCraftingInfo(1,i)
			
			if  (not self:IsOrnate(1,i) or currConfig.SendOrnate) and
				(not self:IsWhite(1,i) or currConfig.SendWhite or self:IsMaterial(1,i) or self:IsRawMaterial(1,i)) and
				(not self:IsMaterial(1,i) or currConfig.SendMaterials) and
				(not self:IsRawMaterial(1,i) or currConfig.SendRaw) and
				(not self:IsBooster(1,i) or currConfig.SendBoosters) and
				(usedInCraftingType == CRAFTING_TYPE_BLACKSMITHING or 
					(currConfig.SendEquipment and self:GetQuality(1,i) <= currConfig.MaxEquipment and  ((GetItemType(1,i) == ITEMTYPE_ARMOR and (self:GetArmorType(1,i) == ARMORTYPE_HEAVY)) or (GetItemType(1,i) == ITEMTYPE_WEAPON and self:GetWeaponType(1,i) ~= WEAPONTYPE_BOW and self:GetWeaponType(1,i) ~= WEAPONTYPE_FIRE_STAFF and self:GetWeaponType(1,i) ~= WEAPONTYPE_SHIELD )))) then 				
				canAttach = CanQueueItemAttachment(1,i,numSlot)
				if(canAttach) then
					QueueItemAttachment(1,i,numSlot)
					numSlot = numSlot + 1
					if(numSlot == 7) then 
						SendMail(currConfig.To,currConfig.Subject,"")
						d("Sent 1 mail to "..currConfig.To.." containing 6 items")
						numSlot = 1
						zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
						return
					end
				
				end
			end	
		end
		if(numSlot ~= 1) then 
			if(numSlot - 1) >= currConfig.MinNumber then
				SendMail(currConfig.To,currConfig.Subject,"")
				d("Sent 1 mail to "..currConfig.To.." containing ".. numSlot -1 .."items")
				numSlot=1
			else
				ClearQueuedMail()
			end
			self.SkipMetal = true
			if(self.TaskRunning == 'ALL') then
				zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
				return
			end
		end
		if(self.TaskRunning == 'METAL') then
			self.TaskRunning = nil
			self.BtnMetal.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_metal_up.dds]])
		end
	end
	currConfig = self.db.mailSettings.Wood
	if(currConfig.Send and (self.TaskRunning == 'ALL' or self.TaskRunning == 'WOOD')) then
		for i=0,bagSlots,1 do
			local usedInCraftingType, itemType,extraInfo1,extraInfo2,extraInfo3 = GetItemCraftingInfo(1,i)			
			if  (not self:IsOrnate(1,i) or currConfig.SendOrnate) and
				(not self:IsWhite(1,i) or currConfig.SendWhite or self:IsMaterial(1,i) or self:IsRawMaterial(1,i)) and
				(not self:IsMaterial(1,i) or currConfig.SendMaterials) and
				(not self:IsRawMaterial(1,i) or currConfig.SendRaw) and
				(not self:IsBooster(1,i) or currConfig.SendBoosters) and
				(usedInCraftingType == CRAFTING_TYPE_WOODWORKING or 
					(currConfig.SendEquipment and self:GetQuality(1,i) <= currConfig.MaxEquipment and (self:GetWeaponType(1,i) == WEAPONTYPE_BOW or self:GetWeaponType(1,i) == WEAPONTYPE_FIRE_STAFF or self:GetWeaponType(1,i) == WEAPONTYPE_SHIELD ))) then 	
				canAttach = CanQueueItemAttachment(1,i,numSlot)
				if(canAttach) then
					QueueItemAttachment(1,i,numSlot)
					numSlot = numSlot + 1
					if(numSlot == 7) then 
						SendMail(currConfig.To,currConfig.Subject,"")
						d("Sent 1 mail to "..currConfig.To.." containing 6 items")
						numSlot = 1
						zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
						return
					end
				
				end
			end	
		end
		if(numSlot ~= 1) then 
			if(numSlot - 1) >= currConfig.MinNumber then
				SendMail(currConfig.To,currConfig.Subject,"")
				d("Sent 1 mail to "..currConfig.To.." containing ".. numSlot -1 .."items")
				numSlot=1
			else
				ClearQueuedMail()
			end
			self.SkipWood = true
			if(self.TaskRunning == 'ALL') then
				zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
				return
			end
		end
		if(self.TaskRunning == 'WOOD') then
			self.TaskRunning = nil
			self.BtnWood.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_wood_up.dds]])
		end
	end	
	currConfig = self.db.mailSettings.Alchemy
	if(currConfig.Send and (self.TaskRunning == 'ALL' or self.TaskRunning == 'ALCHEMY')) then
		for i=0,bagSlots,1 do
			local usedInCraftingType, itemType,extraInfo1,extraInfo2,extraInfo3 = GetItemCraftingInfo(1,i)	
			if usedInCraftingType == CRAFTING_TYPE_ALCHEMY then 
				canAttach = CanQueueItemAttachment(1,i,numSlot)
				if(canAttach) then
					QueueItemAttachment(1,i,numSlot)
					numSlot = numSlot + 1
					if(numSlot == 7) then 
						SendMail(currConfig.To,currConfig.Subject,"")
						d("Sent 1 mail to "..currConfig.To.." containing ".. numSlot -1 .."items")
						numSlot = 1
						zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
						return
					end
				
				end
			end	
		end
		if(numSlot ~= 1) then 
			if(numSlot - 1) >= currConfig.MinNumber then
				SendMail(currConfig.To,currConfig.Subject,"")
				d("Sent 1 mail to "..currConfig.To.." containing ".. numSlot -1 .."items")
				numSlot=1
			else
				ClearQueuedMail()
			end
			self.SkipAlchemy = true
			if(self.TaskRunning == 'ALL') then
				zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
				return
			end
		end
		if(self.TaskRunning == 'ALCHEMY') then
			self.TaskRunning = nil
			self.BtnAlchemy.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_alchemy_up.dds]])
		end
	end	
	if(self.TaskRunning == 'ALL') then
		self.TaskRunning = nil
		self.BtnAll.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_all_up.dds]])
	end	
end
function AdvancedAutoLoot:SendMailFood()
	local bagIcon,bagSlots = GetBagInfo(1)
	-- Send glyphs
	local numSlot = 1
	local canAttach
-- Send Provisionning Stuff
	if(self.db.sendProvisionning and (self.TaskRunning == 'ALL' or self.TaskRunning == 'FOOD')) then
		for i=0,bagSlots,1 do
			if GetItemType(1,i) == ITEMTYPE_INGREDIENT then 
				canAttach = CanQueueItemAttachment(1,i,numSlot)
				if(canAttach) then
					QueueItemAttachment(1,i,numSlot)
					numSlot = numSlot + 1
					if(numSlot == 7) then 
						SendMail(self.db.provisionningRecipient,self.db.provisionningTopic,"")
						d("Sent 1 mail to "..self.db.provisionningRecipient.." containing 6 items")
						numSlot = 1
						zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
						return
					end
				
				end
			end	
		end
		if(numSlot ~= 1) then 
			SendMail(self.db.provisionningRecipient,self.db.provisionningTopic,"")
			d("Sent 1 mail to "..self.db.provisionningRecipient.." containing ".. numSlot -1 .."items")
			numSlot=1
			zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
			return
		end
		if(self.TaskRunning == 'FOOD') then
			self.TaskRunning = nil
			self.BtnFood.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_food_up.dds]])
		end
	end	
end
function AdvancedAutoLoot:SendMailCloth()
	local bagIcon,bagSlots = GetBagInfo(1)
	-- Send glyphs
	local numSlot = 1
	local canAttach
-- Send Cloth/Leather
	if(self.db.sendCloth and (self.TaskRunning == 'ALL' or self.TaskRunning == 'CLOTH')) then
		for i=0,bagSlots,1 do
			if GetItemTrait(1,i) ~= ITEM_TRAIT_TYPE_ARMOR_ORNATE and GetItemTrait(1,i) ~= ITEM_TRAIT_TYPE_WEAPON_ORNATE and (GetItemType(1,i) == ITEMTYPE_ARMOR and (self:GetArmorType(1,i) == ARMORTYPE_MEDIUM or self:GetArmorType(1,i) == ARMORTYPE_LIGHT)) or (GetItemType(1,i) == ITEMTYPE_CLOTHIER_RAW_MATERIAL) then 
				canAttach = CanQueueItemAttachment(1,i,numSlot)
				--d("Can attach : "..tostring(canAttach))
				if(canAttach) then
					QueueItemAttachment(1,i,numSlot)
					numSlot = numSlot + 1
					if(numSlot == 7) then 
						SendMail(self.db.clothRecipient,self.db.clothTopic,"")
						d("Sent 1 mail to "..self.db.clothRecipient.." containing 6 items")
						numSlot = 1
						zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
						return
					end
				end
			end	
		end
		if(numSlot ~= 1) then 
			SendMail(self.db.clothRecipient,self.db.clothTopic,"")
			d("Sent 1 mail to "..self.db.clothRecipient.." containing ".. numSlot -1 .."items")
			numSlot=1
			zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
			return
		end
		if(self.TaskRunning == 'CLOTH') then
			self.TaskRunning = nil
			self.BtnCloth.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_cloth_up.dds]])
		end
	end
end
function AdvancedAutoLoot:SendMailGlyph()
	local bagIcon,bagSlots = GetBagInfo(1)
	-- Send glyphs
	local numSlot = 1
	local canAttach
	if(self.db.sendGlyph and (self.TaskRunning == 'ALL' or self.TaskRunning == 'GLYPH')) then
		for i=0,bagSlots,1 do
			if(GetItemType(1,i) == ITEMTYPE_GLYPH_ARMOR or GetItemType(1,i) == ITEMTYPE_GLYPH_JEWELRY or GetItemType(1,i) == ITEMTYPE_GLYPH_WEAPON) then 
				canAttach = CanQueueItemAttachment(1,i,numSlot)
				if(canAttach) then
					QueueItemAttachment(1,i,numSlot)
					numSlot = numSlot + 1
					if(numSlot == 7) then 
						SendMail(self.db.glyphRecipient,self.db.glyphTopic,"")
						d("Sent 1 mail to "..self.db.glyphRecipient.." containing 6 items")
						zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
						return
					end
				end
			end	
		end
		if(numSlot ~= 1) then 
			SendMail(self.db.glyphRecipient,self.db.glyphTopic,"")
			d("Sent 1 mail to "..self.db.glyphRecipient.." containing ".. numSlot -1 .."items")
			numSlot=1
			zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
			return
		end
		if(self.TaskRunning == 'GLYPH') then
			self.TaskRunning = nil
			self.BtnGlyph.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_glyph_up.dds]])
		end
	end
end
function AdvancedAutoLoot:SendMailMetal()
	local bagIcon,bagSlots = GetBagInfo(1)
	-- Send glyphs
	local numSlot = 1
	local canAttach
-- Send Metal Stuff
	if(self.db.sendMetal and (self.TaskRunning == 'ALL' or self.TaskRunning == 'METAL')) then
		for i=0,bagSlots,1 do
			if GetItemTrait(1,i) ~= ITEM_TRAIT_TYPE_ARMOR_ORNATE and GetItemTrait(1,i) ~= ITEM_TRAIT_TYPE_WEAPON_ORNATE and ((GetItemType(1,i) == ITEMTYPE_ARMOR and (self:GetArmorType(1,i) == ARMORTYPE_HEAVY)) or (GetItemType(1,i) == ITEMTYPE_WEAPON and self:GetWeaponType(1,i) ~= WEAPONTYPE_BOW and self:GetWeaponType(1,i) ~= WEAPONTYPE_FIRE_STAFF and self:GetWeaponType(1,i) ~= WEAPONTYPE_SHIELD )) then 
				canAttach = CanQueueItemAttachment(1,i,numSlot)
				if(canAttach) then
					QueueItemAttachment(1,i,numSlot)
					numSlot = numSlot + 1
					if(numSlot == 7) then 
						SendMail(self.db.metalRecipient,self.db.metalTopic,"")
						d("Sent 1 mail to "..self.db.metalRecipient.." containing 6 items")
						numSlot = 1
						zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
						return
					end
				
				end
			end	
		end
		if(numSlot ~= 1) then 
			SendMail(self.db.metalRecipient,self.db.metalTopic,"")
			d("Sent 1 mail to "..self.db.metalRecipient.." containing ".. numSlot -1 .."items")
			numSlot=1
			zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
			return
		end
		if(self.TaskRunning == 'METAL') then
			self.TaskRunning = nil
			self.BtnMetal.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_metal_up.dds]])
		end
	end
end
function AdvancedAutoLoot:SendMailWood()
	local bagIcon,bagSlots = GetBagInfo(1)
	-- Send glyphs
	local numSlot = 1
	local canAttach
-- Send Wood Stuff
	if(self.db.sendWood and (self.TaskRunning == 'ALL' or self.TaskRunning == 'WOOD')) then
		for i=0,bagSlots,1 do
			if GetItemTrait(1,i) ~= ITEM_TRAIT_TYPE_ARMOR_ORNATE and GetItemTrait(1,i) ~= ITEM_TRAIT_TYPE_WEAPON_ORNATE and GetItemType(1,i) == ITEMTYPE_WEAPON and (self:GetWeaponType(1,i) == WEAPONTYPE_BOW or self:GetWeaponType(1,i) == WEAPONTYPE_FIRE_STAFF or self:GetWeaponType(1,i) == WEAPONTYPE_SHIELD ) then 
				canAttach = CanQueueItemAttachment(1,i,numSlot)
				if(canAttach) then
					QueueItemAttachment(1,i,numSlot)
					numSlot = numSlot + 1
					if(numSlot == 7) then 
						SendMail(self.db.woodRecipient,self.db.woodTopic,"")
						d("Sent 1 mail to "..self.db.woodRecipient.." containing 6 items")
						numSlot = 1
						zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
						return
					end
				
				end
			end	
		end
		if(numSlot ~= 1) then 
			SendMail(self.db.woodRecipient,self.db.woodTopic,"")
			d("Sent 1 mail to "..self.db.woodRecipient.." containing ".. numSlot -1 .."items")
			numSlot=1
			zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
			return
		end
		if(self.TaskRunning == 'WOOD') then
			self.TaskRunning = nil
			self.BtnWood.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_wood_up.dds]])
		end
	end	

end
function AdvancedAutoLoot:SendMailAlchemy()
	local bagIcon,bagSlots = GetBagInfo(1)
	-- Send glyphs
	local numSlot = 1
	local canAttach
-- Send Alchemy Stuff
	if(self.db.sendAlchemy and (self.TaskRunning == 'ALL' or self.TaskRunning == 'ALCHEMY')) then
		for i=0,bagSlots,1 do
			if GetItemType(1,i) == ITEMTYPE_REAGENT then 
				canAttach = CanQueueItemAttachment(1,i,numSlot)
				if(canAttach) then
					QueueItemAttachment(1,i,numSlot)
					numSlot = numSlot + 1
					if(numSlot == 7) then 
						SendMail(self.db.alchemyRecipient,self.db.alchemyTopic,"")
						d("Sent 1 mail to "..self.db.alchemyRecipient.." containing 6 items")
						numSlot = 1
						zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
						return
					end
				
				end
			end	
		end
		if(numSlot ~= 1) then 
			SendMail(self.db.alchemyRecipient,self.db.alchemyTopic,"")
			d("Sent 1 mail to "..self.db.alchemyRecipient.." containing ".. numSlot -1 .."items")
			numSlot=1
			zo_callLater(function() ADVANCED_AUTOLOOT:SendMails() end, self.db.delay)
			return
		end
		if(self.TaskRunning == 'ALCHEMY') then
			self.TaskRunning = nil
			self.BtnAlchemy.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_alchemy_up.dds]])
		end
	end	
end

function AdvancedAutoLoot:GetArmorType(bagId,slotId)
	local icon = GetItemInfo(bagId,slotId)
	if (string.find(icon, "heavy")) then
	  return ARMORTYPE_HEAVY
	elseif string.find(icon,"medium") then
		return ARMORTYPE_MEDIUM
	elseif string.find(icon,"light") then
		return ARMORTYPE_LIGHT
	else
		return ARMORTYPE_NONE
	end
end

function AdvancedAutoLoot:GetWeaponType(bagId,slotId)

	local icon = GetItemInfo(bagId,slotId)
	
	if (string.find(icon, "1hsword")) then
	  return WEAPONTYPE_SWORD
	elseif string.find(icon,"2hsword") then
		return WEAPONTYPE_TWO_HANDED_SWORD
	elseif string.find(icon,"1haxe") then
		return WEAPONTYPE_AXE
	elseif string.find(icon,"2haxe") then
		return WEAPONTYPE_TWO_HANDED_AXE
	elseif string.find(icon,"1hhammer") then
		return WEAPONTYPE_HAMMER
	elseif string.find(icon,"2hhammer") then
		return WEAPONTYPE_TWO_HANDED_HAMMER
	elseif string.find(icon,"dagger") then
		return WEAPONTYPE_DAGGER
	elseif string.find(icon,"shield") then
		return WEAPONTYPE_SHIELD
	elseif string.find(icon,"bow") then
		return WEAPONTYPE_BOW
	elseif string.find(icon,"staff") then
		return WEAPONTYPE_FIRE_STAFF
	else
		return WEAPONTYPE_NONE
	end
end
function AdvancedAutoLoot:OnInventoryUpdated( bagId,slotId, isNewItem,updateReason,test1)
	
	if(bagId==1 and isNewItem) then
	
		local icon,stack,sellPrice,canUse,locked,equipType,itemStyle,quality = GetItemInfo(bagId,slotId)
		for i=1,#AdvancedAutoLoot.DestroyList,1 do
			if(GetItemName(bagId,slotId) == AdvancedAutoLoot.DestroyList[i]) then
				if	not (self.db.keepOrnate and (GetItemTrait(bagId,slotId) == ITEM_TRAIT_TYPE_ARMOR_ORNATE or GetItemTrait(bagId,slotId) == ITEM_TRAIT_TYPE_JEWELRY_ORNATE or GetItemTrait(bagId,slotId) == ITEM_TRAIT_TYPE_WEAPON_ORNATE))
					and not (self.db.keepIntricate and (GetItemTrait(bagId,slotId) == ITEM_TRAIT_TYPE_ARMOR_INTRICATE or GetItemTrait(bagId,slotId) == ITEM_TRAIT_TYPE_WEAPON_INTRICATE ))
					and GetItemType(bagId,slotId) ~= ITEMTYPE_DISGUISE and GetItemType(bagId,slotId) ~= ITEMTYPE_COSTUME then
					--d("Item to destroy : "..DestroyList[i])
					--d(GetItemTrait(bagId,slotId))
					DestroyItem(bagId,slotId)
				--else 
					--d("Item is ornate/intricate")
				end
				table.remove(AdvancedAutoLoot.DestroyList,i)
				break
			end
		end

		if(GetItemType(bagId,slotId) == ITEMTYPE_INGREDIENT and not self.db.keepProvisionning) then
			DestroyItem(bagId,slotId)
		end
		if(GetItemType(bagId,slotId) == ITEMTYPE_RECIPE and not self.db.keepRecipes and quality <=4) then
			DestroyItem(bagId,slotId)
		end
		if((GetItemType(bagId,slotId) == ITEMTYPE_FOOD or GetItemType(bagId,slotId) == ITEMTYPE_DRINK) and not self.db.keepFood) then
			DestroyItem(bagId,slotId)
		end		
		if(GetItemType(bagId,slotId) == ITEMTYPE_LURE and not self.db.keepBaits) then
			DestroyItem(bagId,slotId)
		end
	end
end

function AdvancedAutoLoot_Initialized( self )
    ADVANCED_AUTOLOOT = AdvancedAutoLoot:New( self )
    SLASH_COMMANDS['/toto'] = function() mTests() end
    SLASH_COMMANDS['/sendmails'] = function() ADVANCED_AUTOLOOT:SendMails() end
end

function mTests()
	local btn = ZO_MainMenuSceneGroupBar:CreateControl("ButtonTest",CT_CONTROL)
	BTNTEST = btn
	btn:SetMouseEnabled(true)
	--btn:SetHandler('OnMouseEnter',ZO_MenuBarButtonTemplate_OnMouseEnter)
	btn:SetParent(ZO_MainMenuSceneGroupBar)
	btn:SetAnchor(LEFT,ZO_MainMenuSceneGroupBarButton2,RIGHT,20,0)
	btn:SetWidth(32)
	btn:SetHeight(32)
	btn:SetHandler('OnMouseEnter',function () BTNTEST.IconHightlight:SetHidden(false) end)
	btn:SetHandler('OnMouseExit',function() BTNTEST.IconHightlight:SetHidden(true) end)
	local btnImage = btn:CreateControl("ButtonTestIcon",CT_TEXTURE)
	btn.Icon = btnImage
	btnImage:SetAnchor(128,btn,128,0,0)
	btnImage:SetTexture([[/AdvancedAutoLoot/Textures/mail_tabicon_inbox_up.dds]])
	btnImage:SetWidth(64)
	btnImage:SetDrawLayer(2)
	btnImage:SetHeight(64)
	
	local btnImage_Highlight = btn:CreateControl("ButtonTestIcon_highlight",CT_TEXTURE)
	btn.IconHightlight = btnImage_Highlight
	btnImage_Highlight:SetAnchor(128,btn,128,0,0)
	btnImage_Highlight:SetTexture([[/AdvancedAutoLoot/Textures/mail_tabicon_inbox_over.dds]])
	btnImage_Highlight:SetWidth(64)
	btnImage_Highlight:SetDrawLayer(1)
	btnImage_Highlight:SetHeight(64)
	btnImage_Highlight:SetHidden(true)	
end

function AdvancedAutoLoot:Reset()
self.SkipCloth = false
self.SkipMetal = false
self.SkipWood = false
self.SkipGlyph = false
self.SkipFood = false
self.SkipAlchemy = false
end
function AdvancedAutoLoot:CreateCallBack(craft,textureDown,textureUp)
return function(self)
		-- If a task is running already and it's mine : I stop it
		if(ADVANCED_AUTOLOOT.TaskRunning ~= nil and ADVANCED_AUTOLOOT.TaskRunning == craft) then
			ADVANCED_AUTOLOOT.KeepRunning = false
			ADVANCED_AUTOLOOT.TaskRunning = nil
			self.Icon:SetTexture(textureUp)	
		-- No running tasks I run mine
		elseif (ADVANCED_AUTOLOOT.TaskRunning == nil) then
			d("Starting task: "..craft)
			ADVANCED_AUTOLOOT.TaskRunning = craft
			ADVANCED_AUTOLOOT.KeepRunning = true
			self.Icon:SetTexture(textureDown)
			ADVANCED_AUTOLOOT:Reset()
			ADVANCED_AUTOLOOT:SendMails()
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
		if(lastControl ~= ZO_MainMenuSceneGroupBarButton2) then
			self.BtnAll:SetHidden(false)
			self.BtnAll:SetAnchor(LEFT,lastControl,RIGHT,20,0)
		end
	else
		self.LastAnchor = ZO_MainMenuSceneGroupBarButton2
		self.BtnAlchemy = self:CreateButton('btnMailAlchemy',ZO_MainMenuSceneGroupBarButton2,[[/AdvancedAutoLoot/Textures/mail_alchemy_up.dds]],[[/AdvancedAutoLoot/Textures/mail_alchemy_down.dds]],'ALCHEMY',self.db.mailSettings.Alchemy.Send)
		self.BtnCloth = self:CreateButton('btnMailCloth',self.BtnAlchemy,[[/AdvancedAutoLoot/Textures/mail_cloth_up.dds]],[[/AdvancedAutoLoot/Textures/mail_cloth_down.dds]],'CLOTH',self.db.mailSettings.Cloth.Send)
		self.BtnFood = self:CreateButton('btnMailFood',self.BtnCloth,[[/AdvancedAutoLoot/Textures/mail_food_up.dds]],[[/AdvancedAutoLoot/Textures/mail_food_down.dds]],'FOOD',self.db.mailSettings.Food.Send)
		self.BtnGlyph = self:CreateButton('btnMailGlyph',self.BtnFood,[[/AdvancedAutoLoot/Textures/mail_glyph_up.dds]],[[/AdvancedAutoLoot/Textures/mail_glyph_down.dds]],'GLYPH',self.db.mailSettings.Glyph.Send)
		self.BtnMetal = self:CreateButton('btnMailMetal',self.BtnGlyph,[[/AdvancedAutoLoot/Textures/mail_metal_up.dds]],[[/AdvancedAutoLoot/Textures/mail_metal_down.dds]],'METAL',self.db.mailSettings.Metal.Send)
		self.BtnWood = self:CreateButton('btnMailWood',self.BtnMetal,[[/AdvancedAutoLoot/Textures/mail_wood_up.dds]],[[/AdvancedAutoLoot/Textures/mail_wood_down.dds]],'WOOD',self.db.mailSettings.Wood.Send)
		self.BtnAll = self:CreateButton('btnMailAll',self.BtnWood,[[/AdvancedAutoLoot/Textures/mail_all_up.dds]],[[/AdvancedAutoLoot/Textures/mail_all_down.dds]],'ALL',true)

	end
end
function AdvancedAutoLoot:RemoveButtons()

	if(self.BtnAlchemy ~= nil) then
		self.BtnAlchemy:SetHidden(true)
		self.BtnCloth:SetHidden(true)
		self.BtnFood:SetHidden(true)
		self.BtnGlyph:SetHidden(true)
		self.BtnMetal:SetHidden(true)
		self.BtnWood:SetHidden(true)
		self.BtnAll:SetHidden(true)
	end
	if (self.KeepRunning and self.TaskRunning ~= nil) then
		self:OnMailFailure()
	end
end

function AdvancedAutoLoot:OnMailFailure(reason)
self.KeepRunning = false
if(self.TaskRunning == 'ALCHEMY') then
	self.TaskRunning = nil
	self.BtnAlchemy.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_alchemy_up.dds]])
end
if(self.TaskRunning == 'CLOTH') then
	self.TaskRunning = nil
	self.BtnCloth.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_cloth_up.dds]])
end
if(self.TaskRunning == 'FOOD') then
	self.TaskRunning = nil
	self.BtnFood.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_food_up.dds]])
end
if(self.TaskRunning == 'METAL') then
	self.TaskRunning = nil
	self.BtnMetal.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_metal_up.dds]])
end
if(self.TaskRunning == 'WOOD') then
	self.TaskRunning = nil
	self.BtnWood.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_wood_up.dds]])
end
if(self.TaskRunning == 'GLYPH') then
	self.TaskRunning = nil
	self.BtnGlyph.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_glyph_up.dds]])
end
if(self.TaskRunning == 'ALL') then
	self.TaskRunning = nil
	self.BtnAll.Icon:SetTexture([[/AdvancedAutoLoot/Textures/mail_all_up.dds]])
end
	
d("Mail couldn't be sent")
end
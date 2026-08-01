local sf = string.format

TB_InventoryInsight = ZO_Object:Subclass()

function TB_InventoryInsight:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function TB_InventoryInsight:Initialize()
	if self:Installed() then
		self.validCharacters = {}
		for i = 1, GetNumCharacters() do
			local name, gender, level, classId, raceId, alliance, id, locationId = GetCharacterInfo(i)
			self.validCharacters[id] = name
		end
		
		self.validGuilds = {}
		for i = 1, GetNumGuilds() do
			local id = GetGuildId(i)
			self.validGuilds[GetGuildName(id)] = true
		end
	end
end

function TB_InventoryInsight:Installed()
	return (IIfA ~= nil)
end

function TB_InventoryInsight:IsValidCharacter(characterId)
	local name = self.validCharacters[characterId]
	if name then
		return true, name
	end
	return false, ""
end

function TB_InventoryInsight:IsValidGuild(guildName)
	if self.validGuilds[guildName] then
		return true
	end
	return false
end

local function AddGuildCount(obj, guildName, num)
	--Item is in a guild bank
	obj.count = obj.count+num
	if obj.names[guildName] then
		obj.names[guildName].count = obj.names[guildName].count+num
	else
		obj.names[guildName] = {count = num, name = guildName}
	end
end

local function AddCharacterCount(obj, id, num, name)
	--Item is in a characters bag or wearing it
	obj.count = obj.count+num
	if obj.names[id] then
		obj.names[id].count = obj.names[id].count+num
	else
		obj.names[id] = {count = num, name = name}
	end
end

local function itemSum(info)
	if info.itemCount then
		return info.itemCount
	else
		local num = 0
		for slot, itemCount in pairs(info.bagSlot) do
			num = num + itemCount
		end
		return num
	end
end

local function IsMatchingItem(itemLink, matchCraftingSkillType, matchResearchLineIndex, matchTraitIndex)
	local traitType = GetItemLinkTraitInfo(itemLink)
	if TraitBuddy:IsResearchableTrait(traitType) then
		local craftingSkillType = TraitBuddy:LinkToCraftingSkillType(itemLink)
		if craftingSkillType==matchCraftingSkillType then
			local equipType = GetItemLinkEquipType(itemLink)
			local itemType = GetItemLinkItemType(itemLink)
			local armorType = GetItemLinkArmorType(itemLink)
			local weaponType = GetItemLinkWeaponType(itemLink)
			local researchLineIndex = TraitBuddy:ItemToResearchLineIndex(itemType, armorType, weaponType, equipType)
			if researchLineIndex==matchResearchLineIndex then
				local traitIndex = TraitBuddy:FindTraitIndex(craftingSkillType, researchLineIndex, traitType)
				if traitIndex==matchTraitIndex then
					return true
				end
			end
		end
	end
	return false
end

function TB_InventoryInsight:DisplayTooltip(control, GamePadMode, matchCraftingSkillType, matchResearchLineIndex, matchTraitIndex)
	--Count valid matching item links
	if self:Installed() then
		local onCharacter = {count=0, names={}}
		local inBank = 0
		local inGuild = {count=0, names={}}
		local DBv3 = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].DBv3
		for itemLink,details in pairs(DBv3) do
			if itemLink:find(ITEM_LINK_TYPE) then
				--Its a valid item link
				if IsMatchingItem(itemLink, matchCraftingSkillType, matchResearchLineIndex, matchTraitIndex) then
					--Only count the items with the same trait
					for location,info in pairs(details.locations) do
						if location == "Bank" then
							inBank = inBank+itemSum(info)
						else
							if self:IsValidGuild(location) then
								AddGuildCount(inGuild, location, itemSum(info))
							else
								local valid, name = self:IsValidCharacter(location)
								if valid then
									AddCharacterCount(onCharacter, location, itemSum(info), name)
								end
							end
						end
					end
				end
			end
		end
		
		--Show the results
		local names = ""
		for k,v in pairs(onCharacter.names) do
			if names:len()==0 then
				names = sf("%dx %s", v.count, v.name)
			else
				names = sf(", %dx %s", v.count, v.name)
			end
		end
		if GamePadMode then
			local style2 = TraitBuddy:GetGamepadStyle(2)
			local summary = sf("%s %s%s", zo_iconTextFormatNoSpace("esoui/art/MainMenu/menuBar_character_up.dds", 42, 42, onCharacter.count), zo_iconTextFormatNoSpace("esoui/art/icons/servicemappins/servicepin_bank.dds", 42, 42, inBank), zo_iconTextFormatNoSpace("esoui/art/MainMenu/menuBar_guilds_up.dds", 42, 42, inGuild.count))
			control:AddLine(summary, style2, control:GetStyle("bodySection"))
			if names:len()>0 then
				control:AddLine(names, style2, control:GetStyle("bodySection"))
			end
			for k,v in pairs(inGuild.names) do
				control:AddLine(sf("%dx %s", v.count, v.name), style2, control:GetStyle("bodySection"))
			end
		else
			local r,g,b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
			local summary = sf("%s %s%s", zo_iconTextFormatNoSpace("esoui/art/MainMenu/menuBar_character_up.dds", 32, 32, onCharacter.count), zo_iconTextFormatNoSpace("esoui/art/icons/servicemappins/servicepin_bank.dds", 32, 32, inBank), zo_iconTextFormatNoSpace("esoui/art/MainMenu/menuBar_guilds_up.dds", 32, 32, inGuild.count))
			control:AddLine(summary, "TBFontGame16", r,g,b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			if names:len()>0 then
				control:AddLine(names, "TBFontGame16", r,g,b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			end
			for k,v in pairs(inGuild.names) do
				control:AddLine(sf("%dx %s", v.count, v.name), "TBFontGame16", r,g,b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			end
		end
	end
end

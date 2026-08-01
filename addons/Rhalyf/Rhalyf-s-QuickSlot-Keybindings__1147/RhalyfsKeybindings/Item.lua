-- Inheritance LUA Doc: http://www.lua.org/pil/16.2.html 
local RK = RhalyfsKeybindings
local RK_Item = RhalyfsKeybindings.Item

local firstCharUpperCasePattern = "<<C:1>>"

function RK_Item:New(slotIndex, hotBarCategory)
--d("[RK_Item:New]slotIndex: " ..tostring(slotIndex) .. "; hotBarCategory: " ..tostring(hotBarCategory))
	local obj = ZO_Object.New(self)
	local retVar = obj:Initialize(slotIndex, hotBarCategory)
	if not retVar then
		--object's data is empty
		return nil
	end
	return obj
end

local SUPPORTED_HOTBAR_CATEGORY_DATA = {
	[HOTBAR_CATEGORY_QUICKSLOT_WHEEL] = {
		[ACTION_TYPE_ITEM]        = GetSlotItemLink,
		[ACTION_TYPE_COLLECTIBLE] = GetSlotItemLink,
		[ACTION_TYPE_QUEST_ITEM]  = GetSlotBoundId,
		[ACTION_TYPE_EMOTE]       = GetSlotBoundId,
		[ACTION_TYPE_QUICK_CHAT]  = GetSlotBoundId,
	},
}

function RK_Item:Initialize(slotIndex, hotBarCategory)
	return self:Update(slotIndex, hotBarCategory)
end

function RK_Item:Update(slotIndex, hotBarCategory)
	--Reset object's data so it can be updated later
	self.slot = nil
	self.slotType = nil
	self.link = nil
	self.name = nil
	self.formattedName = nil
	self.stack = nil

	--Update the object data now
	self.slot = slotIndex
	local slotType = GetSlotType(slotIndex, hotBarCategory)
	if not slotType then return false end

	self.slotType = slotType
	--d("[RK_Item:Initialize]slotIndex: " ..tostring(slotIndex) .. "; hotBarCategory: " ..tostring(hotBarCategory) .. ", slotType: " ..tostring(slotType))
	local slotTypeItemLinkFunc = (SUPPORTED_HOTBAR_CATEGORY_DATA[hotBarCategory] and SUPPORTED_HOTBAR_CATEGORY_DATA[hotBarCategory][slotType]) or nil
	if not slotTypeItemLinkFunc then return end

	--d(">found slotTypeItemLinkFunc")
	if slotType == ACTION_TYPE_QUEST_ITEM then
		local questItemId = slotTypeItemLinkFunc(slotIndex, hotBarCategory)
		self.link = questItemId
		self.name = zo_strformat(firstCharUpperCasePattern, GetQuestItemName(questItemId))
		self.stack = 0
		--d(">questId: " ..tostring(questItemId) .. ", name: " .. tostring(self.name))
	elseif slotType == ACTION_TYPE_EMOTE then
		local emoteId = slotTypeItemLinkFunc(slotIndex, hotBarCategory)
		local emoteIndex = GetEmoteIndex(emoteId)
		local slashName = GetEmoteInfo(emoteIndex)
		local collectibelId = GetEmoteCollectibleId(emoteIndex)
		self.link = emoteId
		self.name = slashName .. ": " .. zo_strformat(firstCharUpperCasePattern, GetCollectibleName(collectibelId))
		self.stack = 0
		--d(">emoteId: " ..tostring(emoteId) .. ", name: " .. tostring(self.name))
	elseif slotType == ACTION_TYPE_QUICK_CHAT then
		local quickChatId = slotTypeItemLinkFunc(slotIndex, hotBarCategory)
		self.link = quickChatId
		self.name = zo_strformat(firstCharUpperCasePattern, QUICK_CHAT_MANAGER:GetFormattedQuickChatName(quickChatId))
		self.stack = 0
		--d(">quickChatId: " ..tostring(quickChatId) .. ", name: " .. tostring(self.name))
	elseif slotType == ACTION_TYPE_COLLECTIBLE then
		local collectibleItemLink = slotTypeItemLinkFunc(slotIndex, hotBarCategory)
		local collectibleId = GetCollectibleIdFromLink(collectibleItemLink)
		self.link = collectibleItemLink
		self.name = zo_strformat(firstCharUpperCasePattern, GetCollectibleName(collectibleId))
		self.stack = 0
		--d(">collectibleItemLink: " ..tostring(collectibleItemLink) .. ", name: " .. tostring(self.name))
	else
		local itemLink = slotTypeItemLinkFunc(slotIndex, hotBarCategory)
		self.link = itemLink
		self.name = zo_strformat(firstCharUpperCasePattern, GetItemLinkName(itemLink))
		self.stack = GetItemLinkStacks(itemLink)
		--d(">link: " .. itemLink .. ", name: " .. tostring(self.name))
	end
	return self
end

function RK_Item:IsValid()
--d("[RK_Item:IsValid]slot: " ..tostring(self.slot) .. ", stack: " .. tostring(self.stack) .. ", link: " .. tostring(self.link) ..", name: " .. tostring(self.name) )
	return ((self.slot and self.slot > 0) and (self.stack and self.stack >= 0) and
			(self.link and not RK.IsEmpty(self.link)) and
			(self.name and not RK.IsEmpty(self.name))
	)
end

function RK_Item:BuildItemStr()
	local itemStr = RK.COLORS.WHITE

	if (not self:IsValid()) then
		return itemStr.."empty slot"
	end

	if (self.stack) then
		itemStr = itemStr.."x"..self.stack
	end
	itemStr = itemStr.." "..self:FormatLink(LINK_STYLE_BRACKETS)
	return itemStr
end

function RK_Item:FormatLink(itemLinkStyle)
	if type(self.link) ~= "string" then
--d("[RK_Item:FormatLink]slot: " ..tostring(self.link) .. "; name: " ..tostring(self.name) )
		return self.name or ""
	end --quest/emote/quickChat name instead of ItemLink

	local linkLength = self.link:len()
	local nameLength = self.name:len()
	local formattedName = self.formattedName or self:FormatName()
	if (itemLinkStyle == LINK_STYLE_BRACKETS) then
		formattedName = "["..formattedName.."]"
	end
	local finalLink = ""
	for i = 1, linkLength-2-nameLength do
		finalLink = finalLink..self.link:sub(i, i)
	end
	finalLink = finalLink..formattedName.."|h"
	return finalLink
end

function RK_Item:FormatName()
	if not self.name then return end

	local length = self.name:len()
	local final = ""
	for i = 1, length do
		local char = self.name:sub(i, i)
		if (i == 1 or self.name:sub(i-1, i-1) == " ") then
			final = final..char:upper()
		elseif (char == "^") then
			break
		else
			final = final..char
		end
	end
	self.formattedName = final
	return final
end

function RK_Item:Write() -- for debugging
	local str = ""
	for k, v in pairs(self) do
		str = str.."["..k.."]="..tostring(v)..",|r"
	end
	RK.Write(str.." IsValid: "..tostring(self:IsValid()))
end
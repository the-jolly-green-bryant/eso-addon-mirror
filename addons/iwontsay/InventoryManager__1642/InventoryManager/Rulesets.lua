local DEBUG = 
function() end
-- d

local function _tr(str)
	return str
end


if not InventoryManager then InventoryManager = {} end
local IM = InventoryManager

if not IM.IM_Rule then IM.IM_Rule = ZO_Object:Subclass() end
local IMR = IM.IM_Rule

if not IM.IM_Ruleset then IM.IM_Ruleset = ZO_Object:Subclass() end
local IMRS = IM.IM_Ruleset

IMR.text = ""

function IMR:New()
	local rule = ZO_Object.New(self)
  rule.action		= IM.ACTION_KEEP
  rule.minQuality 	= ITEM_QUALITY_TRASH
  rule.maxQuality 	= ITEM_QUALITY_LEGENDARY

  rule.filterType 		= "IM_FILTER_ANY"
  rule.filterSubType 	= "IM_FILTERSPEC_ANY"

  return rule
end

function IMR:Clone()
  local rule = IMR:New()
  for k,v in pairs(self) do
    rule[k] = v
  end
  return rule
end

function IMR:ToString()
	local qualityRangeText = ""
	local isSetText = ""
	local actionText = GetString("IM_ACTIONTXT", self.action)

	local itemDescription = zo_strformat(
		GetString(self.filterSubType),
			" " .. GetString(self.filterType))
	
	
	if self.maxCount then
		actionText = actionText .. " " .. zo_strformat(GetString(IM_RULETXT_EXECOUNT), self.maxCount)
	end
	
	if self.traitType then
		local which = (self.filterType == "IM_FILTER_CONSUMABLE" and 1) or 0
		if self.traitType < 0 then
			if self.traitType == IMRS.ITEM_TRAIT_TYPE_NOTRAIT then which = 2 end
			local str = (self.traitType == IMRS.ITEM_TRAIT_TYPE_ANY and "") or GetString("IM_META_TRAIT_TYPE", -self.traitType)
			itemDescription = zo_strformat(
				GetString("IM_META_TRAIT_TYPE_FORMAT", which), 
				itemDescription,
				str)
		else
			itemDescription = GetString("SI_ITEMTRAITTYPE", self.traitType) .. " " .. itemDescription
		end
	end

	if self.crafted then
		itemDescription = GetString(IM_RULETXT_CRAFTED) .. " " .. itemDescription
	end
	
	if self.worthless then
		itemDescription = GetString(IM_RULETXT_WORTHLESS) .. " " .. itemDescription
	end

	if self.junk then
		itemDescription = GetString(IM_RULETXT_JUNKED) .. " " .. itemDescription
	end
	
	if (IM.FCOISL:hasAddon() or IM.ISL:hasAddon()) and self.FCOISMark then
		if IM.FCOISL:IsNoMark(self.FCOISMark) then
			itemDescription = GetString(IM_FCOIS_UNMARKED) .. " " .. itemDescription
		elseif IM.FCOISL:IsAnyMark(self.FCOISMark) then
			itemDescription = itemDescription .. " " .. GetString(IM_FCOIS_WITHANYMARK)
		else
			itemDescription = itemDescription .. " " .. zo_strformat(
				GetString(IM_FCOIS_MARKEDASX),
				IM.FCOISL:GetIndexedMark(self.FCOISMark))
		end
	end

	if self.stolen then
		itemDescription = GetString(IM_RULETXT_STOLEN) .. " " .. itemDescription
	end

	if self.isSet then
		isSetText = " " .. GetString(IM_RULETXT_ISSET)
	end
	
  itemDescription = zo_strlower(itemDescription)
  if self.text ~= "" then
    itemDescription = itemDescription .. " " .. zo_strformat(GetString(IM_RULETXT_TXT), self.text)
  end
  
	if self.minQuality == self.maxQuality then
		qualityRangeText = " " .. zo_strformat(GetString("IM_RULETXT_QUALITY", 1),
			IM:getIQString(self.minQuality))
	elseif self.minQuality ~= ITEM_QUALITY_TRASH or self.maxQuality ~= ITEM_QUALITY_LEGENDARY then
		qualityRangeText = " " .. zo_strformat(GetString("IM_RULETXT_QUALITY", 2), 
			IM:getIQString(self.minQuality),
			IM:getIQString(self.maxQuality))
	end

	return zo_strformat(GetString(IM_RULETXTFORMAT),
		itemDescription,
		qualityRangeText,
		isSetText,
		actionText)
end

function IMR:Filter(data)

	local filterList = IM.filtertypes[self.filterType][self.filterSubType]
	
	if #filterList > 0 then
		local attrName = filterList[1]
		
		local found = false
		for i = 2, #filterList, 1 do
			if data[attrName] == filterList[i] then
				found = true
				break
			end
		end
		
		if not found then return false end
	end

	-- For sake of simplicity, translate 'intricate' and 'ornate' to a single value
	local traitType = data.traitType

	if traitType == ITEM_TRAIT_TYPE_ARMOR_NIRNHONED then
		traitType = ITEM_TRAIT_TYPE_WEAPON_NIRNHONED
	end

	if traitType == ITEM_TRAIT_TYPE_ARMOR_INTRICATE then
		traitType = ITEM_TRAIT_TYPE_WEAPON_INTRICATE
	end

	if traitType == ITEM_TRAIT_TYPE_ARMOR_ORNATE then
		traitType = ITEM_TRAIT_TYPE_WEAPON_ORNATE
	end

	if traitType == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE then
		traitType = ITEM_TRAIT_TYPE_WEAPON_INTRICATE
	end

	if traitType == ITEM_TRAIT_TYPE_JEWELRY_ORNATE then
		traitType = ITEM_TRAIT_TYPE_WEAPON_ORNATE
	end

	-- Ornate, Intricate, ect.
	if self.traitType then
		if self.traitType == IMRS.ITEM_TRAIT_TYPE_ANY then
			if traitType == ITEM_TRAIT_TYPE_NONE then return false end
		elseif self.traitType == IMRS.ITEM_TRAIT_TYPE_NOTRAIT then
			if traitType ~= ITEM_TRAIT_TYPE_NONE then return false end
		elseif self.traitType == IMRS.ITEM_TRAIT_TYPE_ANYUNKOTHERS then
			if not data.unknownothers then return false end
		elseif self.traitType == IMRS.ITEM_TRAIT_TYPE_ANYUNKNOWN then
			if not data.unknownself then return false end
		elseif self.traitType ~= traitType then
			return false
		end
	end
	
	-- FCO ItemSaver marker?
    -- Call with parameters suitable for both API's and let FCOISL sort it out.
    if (not IM.FCOISL:FitMark(data.itemInstanceId, self.FCOISMark, data.bagId, data.slotId)) or 
	   (not IM.ISL:FitMark(data.itemInstanceId, self.FCOISMark, data.bagId, data.slotId)) then return false end

	-- Junked?
	if self.junk and not data.junk then return false end
	
	-- Part of a set?
	if self.isSet and not data.isSet then return false end
	
	-- stolen only?
	if self.stolen and not data.stolen then return false end
	
	-- worthless?
	if self.worthless and data.value ~= 0 then return false end
	
	-- crafted?
	if self.crafted and not data.crafted then return false end
	
	-- outside wanted quality range?
	if data.quality < self.minQuality or data.quality > self.maxQuality  then return false end
	
  -- text matching
  if self.text ~= "" and not string.match(data.name, self.text) then return false end
  
	return true
end

IMRS.version = 1

function IMRS:New()
  local ruleset = ZO_Object.New(self)
  ruleset.rules = { }
  return ruleset
end

function IMRS:Clone()
  local ruleset = IMRS:New()
  for k,v in pairs(self) do
    ruleset[k] = v
  end
  ruleset["rules"] = { }
  for k,v in pairs(self["rules"]) do
    ruleset["rules"][k] = IMR.Clone(v)
  end
  return ruleset
end

local ExecCounters = nil

function IMRS:ResetCounters()
	ExecCounters = nil
end

function IMRS:Match(data, action)
	if not ExecCounters then ExecCounters = { } end
	
	for k, v in pairs(self.rules) do
		local res = v:Filter(data)
		
		-- Safeguards
		-- If it's locked, don't touch.
		-- If it's stolen, we can't put it in the bank.
		if res then
			if data.locked then res = false
			elseif data.stolen and v.action == IM.ACTION_STASH then res = false
			end
		end
		
		-- If we want a specific action, skip if it's not the one.
		if action and (action ~= v.action and v.action ~= IM.ACTION_KEEP) then res = false end
		
		-- If we reached the max execution count for that particular rule, skip it.
		if res and v.maxCount and ExecCounters[k] and ExecCounters[k] >= v.maxCount then
			res = false
		end
		
		if res then
			ExecCounters[k] = (ExecCounters[k] or 0) + 1
			data.action = v.action
			data.guildbank = v.guildbank
			return v.action, k, v:ToString()
		end
	end
	
	return IM.ACTION_KEEP, nil, nil
end

function IMRS:List()
	CHAT_SYSTEM:AddMessage(GetString(IM_LIST_NUM_RULES) .. #self.rules)
	
	for i = 1, #self.rules, 1 do
		if not self.rules[i] then
			break
		end
		CHAT_SYSTEM:AddMessage(GetString(IM_LIST_RULE) .. i .. ":" .. self.rules[i]:ToString())
	end
end

function IMRS:GetRuleList(action)
  return self.rules
end

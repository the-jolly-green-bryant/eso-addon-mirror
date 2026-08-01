local DEBUG = 
function() end
-- d

local function _tr(str)
	return str
end


if not InventoryManager then InventoryManager = {} end
local IM = InventoryManager

local VisitedLists = { }

IM.IM_RuleV2 = IM.IM_Rule:Subclass()
local IMR2 = IM.IM_RuleV2

IM.IM_RulesetV2 = IM.IM_Ruleset:Subclass()
local IMRS2 = IM.IM_RulesetV2

IMR2.version = 2

function IMR2:New()
  local rule = IM.IM_Rule.New(self)
  rule.action = nil
  return rule
end

function IMR2:Clone()
  local rule = IMR2:New()
    for k,v in pairs(self) do
    rule[k] = v
  end
  
  local action = rule.action
  rule.action = nil
  
  return rule, action
end

function IMR2:ToString()
	local qualityRangeText = ""
	local isSetText = ""
  local formatindex = 1

	local exeCountText = ""
	if self.maxCount then
		exeCountText = " " .. zo_strformat(GetString(IM_RULETXT_EXECOUNT), self.maxCount)
	end
  
  if self.negate then formatindex = 0 end
  
  if self.xref and self.xref ~= IM.ACTION_KEEP then 
    formatindex = formatindex + 2
    local tgtlist = GetString("IM_R2_HEADING", self.xref)
    return zo_strformat(GetString("IM_R2_FORMAT", formatindex), tgtlist, exeCountText)
  end
  
	local itemDescription = zo_strformat(
		GetString(self.filterSubType),
			" " .. GetString(self.filterType))
	
	
	
	if self.traitType then
		local which = (self.filterType == "IM_FILTER_CONSUMABLE" and 1) or 0
		if self.traitType < 0 then
			if self.traitType == IMRS2.ITEM_TRAIT_TYPE_NOTRAIT then which = 2 end
			local str = (self.traitType == IMRS2.ITEM_TRAIT_TYPE_ANY and "") or GetString("IM_META_TRAIT_TYPE", -self.traitType)
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

	return zo_strformat(GetString("IM_R2_FORMAT", formatindex),
		itemDescription,
		qualityRangeText,
		isSetText,
		exeCountText)
end

function IMR2:Filter(data)
  if self.xref and self.xref ~= IM.ACTION_KEEP then
    
    -- Avoid cycles - break if we were already here.
    if VisitedLists[self.xref] then return false end
    
    VisitedLists[self.xref] = true
    local action, index, text = IM.currentRuleset:Match(data, self.xref)
    VisitedLists[self.xref] = nil
    
    -- If we found a positive match on the referenced list, this cross reference matches
    if action ~= IM.ACTION_KEEP then return true end
  end

  return IM.IM_Rule.Filter(self, data)
end

IMRS2.version = 2

function IMRS2:New()
  local ruleset = IM.IM_Ruleset.New(self)
  ruleset.rules = nil
  ruleset.rulelists = { }
  
  for k,_ in pairs(IM.actionfunctions) do
    ruleset.rulelists[k] = { }
  end
  ruleset.rulelists[IM.ACTION_KEEP] = nil
  
  return ruleset
end

function IMRS2:Clone()
  if not self.rulelists then return IMRS2.Upgrade(self) end
  
  local ruleset = IMRS2:New()
  for k,v in pairs(self) do
    ruleset[k] = v
  end
  
  ruleset.rulelists = { }
  for k,v in pairs(self.rulelists) do
    ruleset.rulelists[k] = { }
    for k2,v2 in pairs(v) do
      ruleset.rulelists[k][k2] = IMR2.Clone(v2)
    end
  end
  
  return ruleset
end

function IMRS2:Upgrade()
  local ruleset = IMRS2:New()
  for _,v in pairs(self.rules) do
    local rule, action = IMR2.Clone(v)
    if action == IM.ACTION_KEEP then
      rule.negate = true
      for _, list in pairs(ruleset.rulelists) do
        list[#list + 1] = rule:Clone()
      end
    else
      local list = ruleset.rulelists[action]
      list[#list + 1] = rule
    end
  end
  return ruleset
end

local ExecCounters = { }

function IMRS2:ResetCounters()
	ExecCounters = { }
  VisitedLists = { }
end

function IMRS2:Match(data, action)
  -- Operations completely suspended: Do nothing in any case
  if IM.opssuspended then
    return IM.ACTION_KEEP, nil, nil
  end
  
  -- Locked: Do nothing in any case
  if data.locked then
    return IM.ACTION_KEEP, nil, nil
  end
  
  -- If action is not given, try any action that matches
  if not action then
    local raction = IM.ACTION_KEEP
    local rindex, rtext
    for k, _ in pairs(self.rulelists) do
      local action, index, text = self:Match(data, k)
      
      -- If we find an explicit 'do nothing' here, try to find a better match.
      -- Maybe it's because of a negative cross reference.
      if index and (not raction or action ~= IM.ACTION_KEEP) then
        raction = action
        rindex = index
        rtext = text
      end
    end
    return raction, rindex, rtext
  end
  
	if not ExecCounters[action] then ExecCounters[action] = { } end
  
  -- Stolen: No storing in bank or guild bank
  if data.stolen and (action == IM.ACTION_STASH or action == IM.ACTION_GB_STASH) then 
    return IM.ACTION_KEEP, nil, nil
  end
  local rulelist = self.rulelists[action]
	for k = 1, #rulelist, 1 do
    local v = rulelist[k]
		local res = v:Filter(data)

		-- If we reached the max execution count for that particular rule, skip it.
		if res and v.maxCount and ExecCounters[action][k] and ExecCounters[action][k] >= v.maxCount then
			res = false
		end
		
		if res then
			ExecCounters[action][k] = (ExecCounters[action][k] or 0) + 1
      data.action = (v.negate and IM.ACTION_KEEP) or action
			data.guildbank = v.guildbank
			return data.action, action .. ":" .. k, v:ToString()
		end
	end
	
	return IM.ACTION_KEEP, nil, nil
end

function IMRS2:List()
  for action, rulelist in pairs(self.rulelists) do
    if #rulelist > 0 then
      local str = GetString("IM_R2_HEADING", action) .. GetString(IM_R2_COUNT_TAG)
      CHAT_SYSTEM:AddMessage(zo_strformat(str, #rulelist))
      
      for i = 1, #rulelist, 1 do
        CHAT_SYSTEM:AddMessage("  " .. GetString(IM_LIST_RULE) .. i .. ":" .. rulelist[i]:ToString())
      end
      CHAT_SYSTEM:AddMessage("----")
    end
  end
end

function IMRS2:GetRuleList(action)
  return self.rulelists[action]
end

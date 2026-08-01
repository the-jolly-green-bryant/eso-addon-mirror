local DEBUG = 
function() end
-- d

local function _tr(str)
	return str
end

if not InventoryManager then InventoryManager = {} end
local IM = InventoryManager

local RE = IM.UI.RuleEdit


local function getChoiceboxLists(structure, fun)
	local _new = { }
	local _reverse = { }
	local _order = { }
	for i = 1, #structure, 1 do
		local n = structure[i][1]
		_new[n] = fun(n, i)
		_order[i] = _new[n]
		_reverse[_new[n]] = n
	end
	return { 
		["forward"] = _new, 
		["reverse"] = _reverse, 
		["order"] = _order, 
		["seltext"] = _order[1], 
		["selvalue"] = _reverse[_order[1]] 
	}
end

local function getChoiceboxListsAssoc(structure)
	local _new = { }
	local _reverse = { }
	local _order = { }
	for i = 1, #structure, 1 do
		local entry = structure[i]
		_new[entry[2]] = entry[1]
		_reverse[entry[1]] = entry[2]
		_order[#_order + 1] = entry[1]
	end
	return { 
		["forward"] = _new, 
		["reverse"] = _reverse, 
		["order"] = _order, 
		["seltext"] = _order[1], 
		["selvalue"] = _reverse[_order[1]] 
	}
end

local function getSpecificFilterTypes(whichFilter)
	local found = nil
	for i = 1, #IM.filterorder, 1 do
		if IM.filterorder[i][1] == whichFilter then
			found = IM.filterorder[i][2]
			break
		end
	end

	return getChoiceboxLists(found, function(n) return zo_strformat(GetString(n), GetString(IM_FILTER_RULE_ANY)) end)
end

local function getSpecificTraitTypes(whichFilter, whichSubFilter)
	local ttlist = IM.traitsorder[whichSubFilter] or IM.traitsorder[whichFilter] or { }
	
	local _new = { }
	local _reverse = { }
	local _order = { }
	local str
	for i = 1, #ttlist, 1 do
		if ttlist[i] <= 0 then
			str = GetString("IM_META_TRAIT_TYPE", -ttlist[i])
		else
			str = GetString("SI_ITEMTRAITTYPE", ttlist[i])
		end
		_new[ttlist[i]] = str
		_reverse[str] = ttlist[i]
		_order[#_order + 1] = str
	end
	return { 
		["forward"] = _new, 
		["reverse"] = _reverse, 
		["order"] = _order, 
		["seltext"] = _order[1], 
		["selvalue"] = _reverse[_order[1]] 
	}
end

function RE:GetControls()

	RE.filterTypesList = getChoiceboxLists(IM.filterorder, function(n) return GetString(n) end)
	RE.actionList = getChoiceboxLists(IM.actionorder, function(n) return GetString("IM_R2_HEADING", n) end)
  RE.xrefList  = getChoiceboxLists(IM.xreforder, function(n) return GetString("IM_R2_HEADING", n) end)
	RE.qualityList = getChoiceboxListsAssoc(IM.qualityorder)
	
	local guilds = { }
	for i = 1, GetNumGuilds(), 1 do
		local gid = GetGuildId(i)
		local gn = GetGuildName(gid)
		if gn ~= "" then
			guilds[#guilds + 1] = { gn, i }
		end
	end
	RE.guildList = getChoiceboxListsAssoc(guilds)
	
	RE.editingRule = IM.IM_RuleV2:New()
  RE.selectedAction = IM.ACTION_JUNK
  
	local rule = RE.editingRule
	RE:UpdateFilterSpecList(rule.filterType, rule.filterSubType)
	RE:UpdateTraitList(rule.filterType, rule.filterSubType)

	return {
    {
      type = "dropdown",
			width = "half",
      name = GetString(IM_SET_RULELIST),
      tooltip = GetString(IM_SET_RULELIST_TT),
			choices = RE.actionList["order"],
			getFunc = function() return RE.actionList["forward"][RE.selectedAction] end,
			setFunc = function(value) 
        RE.selectedAction = RE.actionList["reverse"][value]
        RE:UpdateRuleList()
      end,
    },
		{
			type = "description",
			text = "",
			width = "half",
		},
		{
			type = "dropdown",
			name = GetString(IM_RE_CURRENTRULES),
			width = "half",
			tooltip = GetString(IM_UI_LISTRULES_HEAD),
			choices = { "(invalid)" },
			getFunc = function() return RE:GetSelectedRule() end,
			setFunc = function(value) RE:SetSelectedRule(value) end,
			reference = "IWONTSAY_IM_CHO_RULES",
		},
		{
			type = "button",
			name = GetString(IM_RE_DELETERULE),
			width = "half",
			disabled = function() return RE:GetBtnDeleteDisabled() end,
			func = function() return RE:BtnDeleteClicked() end,
		},
		{
			type = "button",
			name = GetString(IM_RE_MOVERULEUP),
			width = "half",
			disabled = function() return RE:GetBtnMoveUpDisabled() end,
			func = function() return RE:BtnMoveUpClicked() end,
		},
		{
			type = "button",
			name = GetString(IM_RE_ADDRULEBEFORE),
			width = "half",
			func = function() return RE:BtnAddBeforeClicked() end,
		},
		{
			type = "button",
			name = GetString(IM_RE_MOVERULEDN),
			width = "half",
			disabled = function() return RE:GetBtnMoveDownDisabled() end,
			func = function() return RE:BtnMoveDownClicked() end,
		},
		{
			type = "button",
			name = GetString(IM_RE_ADDRULEAFTER),
			width = "half",
			func = function() return RE:BtnAddAfterClicked() end,
		},
		{
			type = "button",
			name = GetString(IM_RE_REPLACERULE),
			width = "half",
			disabled = function() return RE:GetBtnDeleteDisabled() end, -- Same condition as Delete
			func = function() return RE:BtnReplaceClicked() end,
		},
		{
			type = "description",
			text = "",
			width = "half",
		},
		{
			type = "description",
			text = GetString(IM_RE_DESC),
		},
		{
			type = "checkbox",
			name = GetString(IM_SET_NEGATE),
			tooltip = GetString(IM_SET_NEGATE_TT),
			width = "half",
			getFunc = function() return RE.editingRule.negate end,
			setFunc = function(value) RE.editingRule.negate = value end,
		},
		{
			type = "dropdown",
			name = GetString(IM_SET_XREF),
			tooltip = GetString(IM_SET_XREF_TT),
			width = "half",
			choices = RE.xrefList["order"],
			getFunc = function() return RE.xrefList["forward"][RE.editingRule.xref or IM.ACTION_KEEP] end,
			setFunc = function(value) RE.editingRule.xref = RE.xrefList["reverse"][value] end,
		},
		{
			type = "slider",
			name = GetString(IM_SET_EXECOUNT),
			tooltip = GetString(IM_SET_EXECOUNT_TT),
			min = 0,
			max = 500,
			getFunc = function() return RE.editingRule.maxCount or 0 end,
			setFunc = function(value) 
				RE.editingRule.maxCount = (value ~= 0 and value) or nil
			end,
			width = "half",	--or "half" (optional)
		},
		{
			type = "dropdown",
			name = GetString(IM_RE_GUILDBANK),
			tooltip = GetString(IM_RE_GUILDBANK_TT),
			width = "half",
			choices = RE.guildList["order"],
			getFunc = function() return RE.editingRule.guildbank or RE.guildList["seltext"] end,
			setFunc = function(value) RE.editingRule.guildbank = value end,
			disabled = function() return RE:GetChoGBDisabled() end,
		},
		{
			type = "dropdown",
			name = GetString(IM_RE_GENTYPE),
			width = "half",
			choices = RE.filterTypesList["order"],
			getFunc = function() return RE.filterTypesList["forward"][RE.editingRule.filterType] end,
			setFunc = function(value) RE:SetSelectedFilterType(value) end,
		},
		{
			type = "dropdown",
			name = GetString(IM_RE_SPECTYPE),
			width = "half",
			choices = { "(invalid)" },
			getFunc = function() return RE.filterSubTypesList["forward"][RE.editingRule.filterSubType] end,
			setFunc = function(value) RE:SetSelectedFilterSubType(value) end,
			reference = "IWONTSAY_IM_CHO_FILTERSPEC",
		},
		{
			type = "dropdown",
			name = GetString(IM_RE_TRAIT),
			width = "half",
			choices = { "(invalid)" },
			getFunc = function() return RE.traitList["forward"][RE.editingRule.traitType or 0] end,
			setFunc = function(value) RE:SetSelectedTraitType(value) end,
			reference = "IWONTSAY_IM_CHO_TRAIT",
		},
		{
			type = "dropdown",
			name = GetString(IM_FCOIS_CHOICE),
			width = "half",
			choices = IM.FCOISL:GetIconChoices(),
			getFunc = function() return IM.FCOISL:GetIndexedMark(RE.editingRule.FCOISMark) end,
			setFunc = function(value) RE.editingRule.FCOISMark = IM.FCOISL:GetMarkIndex(value) end,
			disabled = function() return not IM.FCOISL:hasAddon() and not IM.ISL:hasAddon() end,
			reference = "IWONTSAY_IM_CHO_FCOIS_CHOICE"
		},
		{
			type = "dropdown",
			name = GetString(IM_RE_MINQUAL),
			width = "half",
			choices = RE.qualityList["order"],
			getFunc = function() return RE.qualityList["forward"][RE.editingRule.minQuality] end,
			setFunc = function(value) RE.editingRule.minQuality = RE.qualityList["reverse"][value] end,
		},
		{
			type = "dropdown",
			name = GetString(IM_RE_MAXQUAL),
			width = "half",
			choices = RE.qualityList["order"],
			getFunc = function() return RE.qualityList["forward"][RE.editingRule.maxQuality] end,
			setFunc = function(value) RE.editingRule.maxQuality = RE.qualityList["reverse"][value] end,
		},
		{
			type = "checkbox",
			name = GetString(IM_RE_PARTOFSET),
			width = "half",
			disabled = function() return RE:GetIsSetCheckDisabled() end,
			getFunc = function() return RE.editingRule.isSet end,
			setFunc = function(value) RE.editingRule.isSet = value end,
		},
		{
			type = "checkbox",
			name = GetString(IM_RE_INJUNK),
			width = "half",
			getFunc = function() return RE.editingRule.junk end,
			setFunc = function(value) RE.editingRule.junk = value end,
		},
		{
			type = "checkbox",
			name = GetString(IM_RE_STOLEN),
			width = "half",
			getFunc = function() return RE.editingRule.stolen end,
			setFunc = function(value) RE.editingRule.stolen = value end,
		},
		{
			type = "checkbox",
			name = GetString(IM_RE_WORTHLESS),
			width = "half",
			getFunc = function() return RE.editingRule.worthless end,
			setFunc = function(value) RE.editingRule.worthless = value end,
		},
		{
			type = "checkbox",
			name = GetString(IM_RE_CRAFTED),
			width = "half",
			getFunc = function() return RE.editingRule.crafted end,
			setFunc = function(value) RE.editingRule.crafted = value end,
		},
		{
			type = "editbox",
			name = GetString(IM_SET_TXTMATCH),
			tooltip = GetString(IM_SET_TXTMATCH_TT),
			getFunc = function() return RE.editingRule.text end,
			setFunc = function(text) RE.editingRule.text = text end,
			isMultiline = false,
			width = "half",
		},
	}
end

function RE:Update()
	CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", RE.panel)
end

function RE:UpdateFCOIcons()
	if not IWONTSAY_IM_CHO_FCOIS_CHOICE then
		zo_callLater(function() RE:UpdateFCOIcons() end, 500)
		return
	end
	IWONTSAY_IM_CHO_FCOIS_CHOICE:UpdateChoices(IM.FCOISL:GetIconChoices());
end

function RE:BtnAddBeforeClicked()
	DEBUG("--- OnBtnAddBefore")
	local rs = IM.currentRuleset:GetRuleList(RE.selectedAction)
	RE.selectedRule = RE.selectedRule or 1
	table.insert(rs, RE.selectedRule, RE.editingRule)
	RE:UpdateRuleList(RE.selectedRule)
	IM:Save()
end

function RE:BtnAddAfterClicked()
	DEBUG("--- OnBtnAddAfter")
	local rs = IM.currentRuleset:GetRuleList(RE.selectedAction)
	RE.selectedRule = RE.selectedRule or 0
	RE.selectedRule = RE.selectedRule + 1
	table.insert(rs, RE.selectedRule, RE.editingRule)
	RE:UpdateRuleList(RE.selectedRule)
	IM:Save()
end

function RE:BtnDeleteClicked()
	DEBUG("--- OnBtnDelete")
	local rs = IM.currentRuleset:GetRuleList(RE.selectedAction)
	table.remove(rs, RE.selectedRule)
	if RE.selectedRule > #rs then
		RE.selectedRule = #rs
	end
	RE:UpdateRuleList(RE.selectedRule)
	IM:Save()
end

function RE:BtnReplaceClicked()
	DEBUG("--- OnBtnAddAfter")
	local rs = IM.currentRuleset:GetRuleList(RE.selectedAction)
	RE.selectedRule = RE.selectedRule or 1
	rs[RE.selectedRule] = RE.editingRule
	RE:UpdateRuleList(RE.selectedRule)
	IM:Save()
end

local function moveRule(direction)
	local rs = IM.currentRuleset:GetRuleList(RE.selectedAction)
	local tmp = rs[RE.selectedRule]
	rs[RE.selectedRule] = rs[RE.selectedRule+direction]
	rs[RE.selectedRule+direction] = tmp
	RE.selectedRule = RE.selectedRule+direction
	RE:UpdateRuleList(RE.selectedRule)
	IM:Save()
end

function RE:BtnMoveUpClicked()
	DEBUG("--- OnBtnMoveUp")
	moveRule(-1)
end

function RE:BtnMoveDownClicked()
	DEBUG("--- OnBtnMoveDown")
	moveRule(1)
end

function RE:GetBtnDeleteDisabled()
	DEBUG("--- GetBtnDeleteDisabled")
	return not RE.selectedRule 
end

function RE:GetBtnMoveUpDisabled()
	DEBUG("--- GetBtnDeleteDisabled")
	return not RE.selectedRule or RE.selectedRule == 1
end

function RE:GetBtnMoveDownDisabled()
	DEBUG("--- GetBtnDeleteDisabled")
	return not RE.selectedRule or RE.selectedRule == #RE.ruleList
end

function RE:GetChoGBDisabled()
	return RE.selectedAction ~= IM.ACTION_GB_STASH and RE.selectedAction ~= IM.ACTION_GB_RETRIEVE
end

function RE:UpdateTraitList(filterType, filterSubType)
	DEBUG("--- UpdateTraitList", filterType, filterSubType)
	RE.traitList = getSpecificTraitTypes(filterType, filterSubType)
	
	local traitTxt = (RE.editingRule.traitType and RE.traitList["forward"][RE.editingRule.traitType]) or RE.traitList["seltext"]

	if not IWONTSAY_IM_CHO_TRAIT then return end
	
	IWONTSAY_IM_CHO_TRAIT:UpdateChoices(RE.traitList["order"]);
	IWONTSAY_IM_CHO_TRAIT:UpdateValue(false, traitTxt);
	IWONTSAY_IM_CHO_TRAIT:UpdateValue(false);
end

function RE:UpdateFilterSpecList(whichFilter, preselection)
	DEBUG("--- UpdateFilterSpecList()", whichFilter, preselection)
	RE.filterSubTypesList = getSpecificFilterTypes(whichFilter)
	local fst = preselection or RE.filterSubTypesList["selvalue"]
	RE.editingRule.filterSubType = fst
	if not IWONTSAY_IM_CHO_FILTERSPEC then return end

	-- Go the long way of updating, since the UI is present
	RE.editingRule.filterSubType = nil
	
	IWONTSAY_IM_CHO_FILTERSPEC:UpdateChoices(RE.filterSubTypesList["order"]);
	IWONTSAY_IM_CHO_FILTERSPEC:UpdateValue(false, RE.filterSubTypesList["forward"][fst])
end

function RE:UpdateRuleList(preselection)
	DEBUG("--- UpdateRuleList()", preselection)
	
	local rules = IM.currentRuleset:GetRuleList(RE.selectedAction)
	RE.ruleList = { }
	RE.reverseRuleList = { }
	if #rules then
		for i = 1, #rules, 1 do
			RE.ruleList[i] = zo_strformat("<<1>>: <<2>>", i, rules[i]:ToString())
			RE.reverseRuleList[RE.ruleList[i]] = i
		end
	end
	
	if #RE.ruleList > 0 then
		IWONTSAY_IM_CHO_RULES:UpdateChoices(RE.ruleList)
		IWONTSAY_IM_CHO_RULES:UpdateValue(false, RE.ruleList[preselection or 1])
	else
		DEBUG(" -- Setting (empty)...")
		IWONTSAY_IM_CHO_RULES:UpdateChoices({ GetString(IM_RE_EMPTY) })
		IWONTSAY_IM_CHO_RULES:UpdateValue(false, GetString(IM_RE_EMPTY))
	end
end

function RE:GetIsSetCheckDisabled()
	DEBUG("--- GetIsSetCheckDisabled")
	local disabled = 
		RE.editingRule.filterType ~= "IM_FILTER_ANY" and 
		RE.editingRule.filterType ~= "IM_FILTER_WEAPON" and
		RE.editingRule.filterType ~= "IM_FILTER_APPAREL"
		
	if disabled then RE.editingRule.isSet = false end
	
	return disabled
end

function RE:GetSelectedRule()
	DEBUG("--- GetSelectedRule")
	return (RE.ruleList and RE.selectedRule and RE.ruleList[RE.selectedRule]) or "(empty)"
end

function RE:SetSelectedRule(whichRuleText)
	DEBUG("--- SetSelectedRule", whichRuleText)
	RE.selectedRule = RE.reverseRuleList[whichRuleText]
	local rule = IM.currentRuleset:GetRuleList(RE.selectedAction)[RE.selectedRule]
	RE.editingRule = (rule and rule:Clone()) or RE.editingRule
	rule = RE.editingRule
	
	RE:UpdateFilterSpecList(rule.filterType, rule.filterSubType)
	
end

function RE:SetSelectedFilterType(whichFilterText)
	DEBUG("--- SetSelectedFilterType", whichFilterText)
	local whichFilter = RE.filterTypesList["reverse"][whichFilterText]
	
	if RE.editingRule.filterType ~= whichFilter then
		RE.editingRule.filterType = whichFilter
		RE:UpdateFilterSpecList(whichFilter)
	end
end

function RE:SetSelectedFilterSubType(value)
	DEBUG("--- SetSelectedFilterSubType", value)
	local whichSubFilter = RE.filterSubTypesList["reverse"][value]
	
	if RE.editingRule.filterSubType ~= whichSubFilter then
		RE.editingRule.filterSubType = whichSubFilter
		RE:UpdateTraitList(RE.editingRule.filterType, RE.editingRule.filterSubType)
	end
end

function RE:SetSelectedTraitType(value)
	DEBUG("--- SetSelectedTraitType", value)
	RE.editingRule.traitType = RE.traitList["reverse"][value]
	if RE.editingRule.traitType == 0 then
		RE.editingRule.traitType = nil
	end
end

-- Called whenever the panel is first created. 
function RE:PopulateUI()
	DEBUG("--- PopulateUI")

	-- fired because of someone else?
	if not IWONTSAY_IM_CHO_FILTERSPEC then return end
	
	RE:UpdateRuleList()
end


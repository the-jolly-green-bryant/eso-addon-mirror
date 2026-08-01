
local Location = FasterTravel.Location
local Campaign = FasterTravel.Campaign
local Utils = FasterTravel.Utils

local Timer = FasterTravel.Timer

local WayshrineTooltip = FasterTravel.class()

local function AddTextToTooltip(tooltip,text,color)
	color = color or ZO_TOOLTIP_DEFAULT_COLOR
	tooltip:AddLine(text,"",color:UnpackRGB())
end

local function AddDividerToTooltip(tooltip)
	local t = tooltip
	if tooltip.AddNewDivider ~= nil then 
		tooltip:AddNewDivider()
	else
		ZO_Tooltip_AddDivider(t)
	end 
end

local function AddQuestTasksToTooltip(tooltip, quest)

	AddTextToTooltip(tooltip, quest.name,ZO_SELECTED_TEXT)
	
	local questIndex = quest.index
	
	local label
	
	for stepIndex,stepInfo in pairs(quest.steps) do 
	
		for conditionIndex,condition in pairs(stepInfo.conditions) do 
			AddTextToTooltip(tooltip, condition.text)
		end
	end 
end

local function GetRecallCostInfo()
	local cost = GetRecallCost()
	local hasEnough = CURRENCY_HAS_ENOUGH
	if cost > GetCurrentMoney() then 
		hasEnough = CURRENCY_NOT_ENOUGH
	end
	return cost,hasEnough
end

local REASON_CURRENCY_SPACING = 3
local function AddRecallToTooltip(tooltip,inCyrodiil)

	if inCyrodiil == true then 
	
		AddTextToTooltip(tooltip,GetString(SI_TOOLTIP_WAYSHRINE_CANT_RECALL_AVA), ZO_ERROR_COLOR)
		
	else
	
		local _, timeLeft = GetRecallCooldown()
		
		if timeLeft == 0 then
		
			local cost,hasEnough = GetRecallCostInfo()
		
			tooltip:AddMoney(tooltip, cost, SI_TOOLTIP_RECALL_COST, hasEnough)
			
			local moneyLine = GetControl(tooltip, "SellPrice")  
			local reasonLabel = GetControl(moneyLine, "Reason")
			local currencyControl = GetControl(moneyLine, "Currency")
			
			-- fix vertical align 
			currencyControl:ClearAnchors()
			currencyControl:SetAnchor(TOPLEFT, reasonLabel, TOPRIGHT, REASON_CURRENCY_SPACING, 0)
			
		else
		
			local text = zo_strformat(SI_TOOLTIP_WAYSHRINE_RECALL_COOLDOWN, ZO_FormatTimeMilliseconds(timeLeft, TIME_FORMAT_STYLE_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS))

			AddTextToTooltip(tooltip,text, ZO_HIGHLIGHT_TEXT)
		
		end
		
	end 
end

local function SetRecallAmount(tooltip,amount,hasEnough)
	local currencyControl = GetControl(GetControl(tooltip, "SellPrice"), "Currency")
	if currencyControl ~= nil then 
		ZO_CurrencyControl_SetSimpleCurrency(currencyControl, CURT_MONEY, amount, {showTooltips = false}, CURRENCY_DONT_SHOW_ALL, hasEnough)
	end
end

local function SetCooldownTimeleft(tooltip,timeLeft)
	-- TODO: Set cooldown line
end

local function UpdateRecallAmount(tooltip)

	local _, timeLeft = GetRecallCooldown()
	
	if timeLeft == 0 then
	
		local cost,hasEnough = GetRecallCostInfo()
		SetRecallAmount(tooltip,cost,hasEnough)
	else
		SetCooldownTimeleft(tooltip,timeLeft)
	end
	
end

local function SortQuestsTable(questTable)
	table.sort(questTable,function(x,y)
		if x.assisted == true then 
			return true
		elseif y.assisted == true then 
			return false 
		end
		return x.index < y.index
	end)
end 

local function CreateQuestsTable(quests)
	
	local questTable = {}
	
	for index,quest in pairs(quests) do
		table.insert(questTable,quest)
	end 
	
	return questTable
end

local function IsCyrodiilRow(data)
	if data == nil then return false end 
	return Location.Data.IsZoneIndexCyrodiil(data.zoneIndex)
end

local function IsKeepRow(data,isRecall,isKeep)
	if IsCyrodiilRow(data) == false then return false end 
	return (isRecall == true or isKeep == true) and data.isTransitus == true 
end 

local function IsCampaignRow(data)
	if IsCyrodiilRow(data) == false then return false end 
	return data.isCampaign == true 
end

local function AppendQuestsToTooltip(tooltip,data)
	if data.quests == nil then return end 

	AddDividerToTooltip(tooltip)
	
	local first = true
	
	local questsTable = data.quests.table
	
	if questsTable == nil then 
		questsTable = CreateQuestsTable(data.quests)
		data.quests.table = questsTable
	end 
	SortQuestsTable(questsTable)
	for i,quest in ipairs(questsTable) do 
		if first == false then AddDividerToTooltip(tooltip) end
		AddQuestTasksToTooltip(tooltip, quest)
		first = false
	end 
end

local function ShowToolTip(tooltip, control,data,offsetX,isRecall,isKeep,inCyrodiil)
	InitializeTooltip(tooltip, control, RIGHT, offsetX)
	
	AddTextToTooltip(tooltip, data.name, ZO_SELECTED_TEXT)
	
	if isRecall == true or (isKeep == true and IsCyrodiilRow(data) == false) then 
		AddRecallToTooltip(tooltip,inCyrodiil)
	elseif isRecall == false then 
		AddTextToTooltip(tooltip,GetString(SI_TOOLTIP_WAYSHRINE_CLICK_TO_FAST_TRAVEL), ZO_HIGHLIGHT_TEXT)
	end
	
	AppendQuestsToTooltip(tooltip,data)

end

local function HideToolTip(tooltip) 
	ClearTooltip(tooltip)
end 

local function ShowKeepTooltip(tooltip,control, offsetX, data)

	-- guessed defaults for last values 
	tooltip:SetKeep(data.nodeIndex, BGQUERY_ASSIGNED_AND_LOCAL, 1.0)
	
	AppendQuestsToTooltip(tooltip,data)
	
	tooltip:Show(control,offsetX)
	
end

local function AddTextWithIconToTooltip(tooltip,text,path,iconWidth,iconHeight,...)
	AddTextToTooltip(tooltip,zo_iconTextFormat(path,iconWidth,iconHeight,text),...)
end

local _iconWidth,_iconHeight = 28,28

local function ColourTextInline(text,colour)
	table.insert(text,"|c")
	table.insert(text,colour)
end

local function ColourFormat(r,g,b)
	return string.format("%02x%02x%02x",255 * r,255 * g, 255 * b)
end

local function FormatTextAndIcon(path,w,h,strfmt,...)
	local value = zo_strformat(strfmt, ...)
	return zo_iconTextFormat(path,w,h,value)
end

local function MapFactions(func)

	local ids = Campaign.FACTION_IDS
	local factions = Campaign.ICONS_FACTION_POPULATION
	local colors = Campaign.COLOURS_FACTION_POPULATION
	
	local path 
	
	local w,h = _iconWidth,_iconHeight
	
	local cur
	for i,id in ipairs(ids) do
		
		path = factions[id]
		
		cur = zo_iconFormat(path,26,28)
		
		func(id,cur,ColourFormat(colors[id]()))
	end
	
end


local function FormatFactionText(func,...)
	local text = {}
	
	MapFactions(function(id,cur,color)
	
		table.insert(text,cur)
		
		ColourTextInline(text,color)
		
		Utils.copy({func(id)},text)
	
	end)
	
	table.insert(text,"|r")
	
	return table.concat(text)
end

local function AddCampaignPopulationToTooltip(tooltip,data)

	local population = data.population
	
	local w,h = _iconWidth,_iconHeight
	
	local text = {}
	
	MapFactions(function(id,cur,color)
		local p = population[id]
		
		local path = ZO_CampaignBrowser_GetPopulationIcon(p)
		
		local t = Campaign.GetPopulationText(p)
		t = zo_iconTextFormat(path,w,h,t)
		
		ColourTextInline(text,color)
		
		table.insert(text,t)
	end)
	
	AddTextToTooltip(tooltip,table.concat(text))
	
	if data.group > 0 then 
		AddTextToTooltip(tooltip,FormatTextAndIcon("EsoUI/Art/Campaign/campaignBrowser_group.dds",w,h,SI_CAMPAIGN_BROWSER_TOOLTIP_NUM_GROUP_MEMBERS,data.group))
	end
	
	AddDividerToTooltip(tooltip)
	
	local friends = FormatTextAndIcon("EsoUI/Art/Campaign/campaignBrowser_friends.dds",w,h,SI_CAMPAIGN_BROWSER_TOOLTIP_NUM_FRIENDS, data.friends)

	local guildies = FormatTextAndIcon("EsoUI/Art/Campaign/campaignBrowser_guild.dds",w,h,SI_CAMPAIGN_BROWSER_TOOLTIP_NUM_GUILD_MEMBERS, data.guildies)
	
	AddTextToTooltip(tooltip,friends..guildies)
end

local function AddScoringTimeToTooltip(tooltip,times)
	
	local t = (times.start > 0 and times.start) or (times.finish > 0 and times.finish) or nil 
	
	if t == nil then return end 
	
	t= ZO_FormatTime(t, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
	
	local fmt = (times.finish > 0 and SI_CAMPAIGN_LEADERBOARDS_CLOSES_IN_TIMER) or SI_CAMPAIGN_LEADERBOARDS_REOPENS_IN_TIMER
	
	local text = zo_strformat(fmt,t)

	AddTextToTooltip(tooltip,text)
end

local function AddCampaignScoresToTooltip(tooltip,data)
	local scores = data.scores

	local times = data.times 
	
	local w,h = _iconWidth,_iconHeight
	
	local strScoringId = (times.start > 0 and SI_CAMPAIGN_LEADERBOARDS_SCORING_CLOSED ) or (times.finish > 0 and SI_CAMPAIGN_LEADERBOARDS_SCORING_OPEN) or SI_CAMPAIGN_OVERVIEW_CATEGORY_SCORING 
	
	AddTextToTooltip(tooltip,GetString(strScoringId),ZO_SELECTED_TEXT)
	
	AddTextToTooltip(tooltip,FormatFactionText(function(id)
		local s = scores[id]
		if s == nil then return "" end 
		return string.format("%d",s.score)
	end))
	
	AddScoringTimeToTooltip(tooltip,times)
end

local function AddCampaignRulesHeaderToTooltip(tooltip,data)

	AddTextToTooltip(tooltip,data.rulesetName, ZO_SELECTED_TEXT)
	
end

local function AddCampaignStatusToTooltip(tooltip,data)
	
	local id = data.nodeIndex
	
	if Campaign.IsPlayerQueued(id) == true then 
		
		local txt = Campaign.GetQueueStateText(id)
		
		if Utils.stringIsEmpty(txt.individual) == false then 
			AddTextToTooltip(tooltip, txt.individual)
		end 
		
		if Utils.stringIsEmpty(txt.group) == false then 
			AddTextToTooltip(tooltip,txt.group)
		end 
		
	else
		local key = (data.home == true and Campaign.ICON_ID_HOME) or (data.guest == true and Campaign.ICON_ID_GUEST)
	
		if key ~= nil then 
			local path = Campaign.GetIcon(key)
			local strId = (data.home == true and SI_CAMPAIGN_BROWSER_TOOLTIP_HOME_CAMPAIGN) or SI_CAMPAIGN_BROWSER_TOOLTIP_GUEST_CAMPAIGN
			AddTextWithIconToTooltip(tooltip,GetString(strId),path,_iconWidth,_iconHeight)
		end
	end 
end 


local function ShowCampaignTooltip(tooltip,control,offsetX,data)

	InitializeTooltip(tooltip, control, RIGHT, offsetX)
	
	AddTextToTooltip(tooltip, data.name, ZO_SELECTED_TEXT)
	
	AddCampaignRulesHeaderToTooltip(tooltip,data)
	
	AddCampaignStatusToTooltip(tooltip,data)
	
	AddDividerToTooltip(tooltip)
		
	AddCampaignScoresToTooltip(tooltip,data)
	
	AddDividerToTooltip(tooltip)
		
	AddCampaignPopulationToTooltip(tooltip,data)
end

local function UpdateTooltip(tooltip,hide,show,current)
	hide(tooltip) 
	if current == nil then return end 
	show(tooltip,current.icon,current.offsetX,current.data)
end 

function WayshrineTooltip:init(tab,infoTooltip,keepTooltip) 

	local _timer
	
	local _mode = 0 
	local _current = {}
	
	local function TimerTick()
		if _mode == 0 then 
			UpdateRecallAmount(infoTooltip,_current)
		elseif _mode == 1 then 
			UpdateTooltip(infoTooltip,HideToolTip,ShowCampaignTooltip,_current)
		elseif _mode == 2 then 
			UpdateTooltip(keepTooltip,keepTooltip.Hide,ShowKeepTooltip,_current)
		end
	end
	
	local function StartTimer()
		if _timer == nil then
			_timer = Timer(TimerTick,500)
		end 
		_timer:Start()
	end 
	
	local function StopTimer()
		if _timer == nil then return end
		_timer:Stop()
	end
	
	local function ShowCurrentTooltip(icon,data)
		if data == nil then return end
		
		local isRecall,isKeep,inCyrodiil = tab:IsRecall(),tab:IsKeep(),tab:InCyrodiil()
		
		local offsetX = -25
		
		_current.data = data 
		_current.icon = icon
		_current.offsetX = offsetX
		
		if IsKeepRow(data,isRecall,isKeep) == true then 
			_mode = 2 
			ShowKeepTooltip(keepTooltip,icon,offsetX,data)
		elseif IsCampaignRow(data) == true then 
			_mode = 1 
			ShowCampaignTooltip(infoTooltip,icon,offsetX,data)
		else
			_mode = 0 
			ShowToolTip(infoTooltip, icon,data,offsetX,isRecall,isKeep, inCyrodiil)
		end
		
		StartTimer()
	end
	
	self.Show = function(self,...)
		ShowCurrentTooltip(...)
	end 
	
	self.Hide = function(self)
		StopTimer()
		
		HideToolTip(infoTooltip) 
		
		keepTooltip:Hide()
	end 
	
end

FasterTravel.WayshrineTooltip = WayshrineTooltip
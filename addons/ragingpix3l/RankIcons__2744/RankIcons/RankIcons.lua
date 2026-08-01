local AddonName = "RankIcons"
local RI = RI or {}
local GUILD_ROSTER_MANAGER_RI_BuildMasterList = nil
local GUILD_ROSTER_KEYBOARD_RI_filterScrollList = nil
local guildId = -1


function RI_filterScrollList (self) 
	if GUILD_ROSTER_KEYBOARD_RI_filterScrollList~=nil then
		GUILD_ROSTER_KEYBOARD_RI_filterScrollList(self)
	end
	
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	local masterList = GUILD_ROSTER_MANAGER:GetMasterList()
	
	local guildId = GUILD_SELECTOR.guildId
	local guildName = GetGuildName(guildId)
	local scrollDataCopy = {}
	
	local n = #scrollData
	
	for i = 1,n do
		table.insert(scrollDataCopy,{displayName = scrollData[i].data.displayName,rankIndex = scrollData[i].data.rankIndex})
	end
	
	ZO_ClearNumericallyIndexedTable(scrollData)
	
	
	local sl = ZO_GuildRosterSearchLabel
    local filterTarget = sl:GetParent()
	
	local wm = WINDOW_MANAGER
	local anySelected = false
	
	local selectedRanks = {}
		
	for i = 1, 15 do 
		local btnName = filterTarget:GetName() .. "RankFilterBtn" .. i
		local button = RI.GetNamedChildEx(filterTarget,btnName)
		if (button and button:IsHidden() == false) then 
			if button.dataSelected == true then
				anySelected = true
				table.insert(selectedRanks, i)
			end
		end
			
	end
	
	
	local reverseRef = {}
	
	for i = 1, #masterList do
		reverseRef [string.lower(masterList[i].displayName)] = i
	end 
	
	for i = 1, n do
		local data = scrollDataCopy[i]  
		local canInsert = true
		
		if anySelected == true then
			canInsert = false
			if data ~= nil then
			
				
					local bfound = false
					for j=1,#selectedRanks do 
						if data.rankIndex ~= nil  then 
							if data.rankIndex == selectedRanks[j] then
								bfound = true
								break
							else					
							end
						end
					end
					if bfound == true then
						canInsert = true
					end
				end
		else
			canInsert = true
		end
		
		if canInsert then
			
			table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1,masterList[reverseRef[string.lower(data.displayName)]]))
		end
	end
	
	
end


local function nm(s1,s2) if (s1 == nil or s2 == nil) then return false end return string.match(s1:lower(),s2:lower() .. ".*") end

function RI.GetNamedChildEx(o,n) 
		local ret = nil
		
		if o == nil then return ret end
		
		for i = 1,o:GetNumChildren() do
			local ctrl = o:GetChild(i)
			if ctrl then
				if nm( ctrl:GetName(), n) then
					return ctrl
				end
			end
		end
		return ret
	end


function RI.GuildRosterEnable(enable)
  if ((enable)) then
		guildId = nil		
	
		local sharedInfo = ZO_GuildSharedInfo
		local sl = ZO_GuildRosterSearchLabel
		local filterTarget = sl:GetParent()
		
	
	local xpos = 1
	local ypos = 0
	local wm = WINDOW_MANAGER
	
	local function hOnMouseExit(ev) 
		InformationTooltip:SetHidden(true)
		if ev.dataSelected == true then
			ev:SetAlpha(1)
		else
			ev:SetAlpha(0.5)
		end
	end
	
	local function hOnMouseEnter(o)
		InitializeTooltip(InformationTooltip, o)
		SetTooltipText(InformationTooltip, "rank : " .. GetFinalGuildRankName(o.dataGuildId,o.dataRankIndex))
		InformationTooltip:SetHidden(false)
		if o.dataSelected == true then
			o:SetAlpha(1)
		else
			o:SetAlpha(0.5)
		end
	end
			
			
	local function hOnMouseUp (ev,button)
			if button ~= MOUSE_BUTTON_INDEX_LEFT then
				return
			end
			ev.dataSelected = not ev.dataSelected
			
			if ev.dataSelected == true then
				ev:SetAlpha(1)
				
			else
				ev:SetAlpha(0.5)
			end
			GUILD_ROSTER_MANAGER:RefreshData()
	end
	
	for i = 1,15 do
		local btnName = filterTarget:GetName() .. "RankFilterBtn" .. i
		local button = RI.GetNamedChildEx(filterTarget,btnName)
		if not button then
			
			button = wm:CreateControl(btnName, filterTarget, CT_BUTTON)
			
			button:SetHidden(true)
			button:SetMouseEnabled(false)
			button:SetDimensions(26, 26)
			
			button:SetHandler("OnMouseEnter", hOnMouseEnter)
			
			button:SetHandler("OnMouseExit", hOnMouseExit)
			
			
			button:SetHandler("OnMouseUp",  hOnMouseUp)
		end			
		
		
		button:SetPressedOffset(2, 2)
		button:ClearAnchors()
		button:SetAnchor(LEFT, filterTarget:GetChild(1), LEFT, 200 + 28*xpos, 18)
		
		button.dataSelected = false
		button:SetAlpha(0.5)

		xpos = xpos + 1			
	end

    GUILD_ROSTER_MANAGER_RI_BuildMasterList = GUILD_ROSTER_MANAGER.BuildMasterList
	GUILD_ROSTER_KEYBOARD_RI_filterScrollList = GUILD_ROSTER_KEYBOARD.FilterScrollList
	GUILD_ROSTER_KEYBOARD.FilterScrollList = RI_filterScrollList
	GUILD_ROSTER_MANAGER.BuildMasterList = RI_buildMasterList
	GUILD_ROSTER_MANAGER:RefreshData()
	
  end

end


function RI.InitButtonsForGuild(button,guildId,i,isValidForCurrentGuild)	
	
	if button == nil then return end
	
	if (isValidForCurrentGuild) then
		button:SetAlpha(0.5)
		
		button:SetNormalTexture(GetGuildRankLargeIcon(GetGuildRankIconIndex(guildId, i)))
		button.dataGuildId = guildId
		button.dataRankIndex = i
		button.dataSelected = false
	end
	
	button:SetHidden(not isValidForCurrentGuild)
	button:SetMouseEnabled(isValidForCurrentGuild)
	
	
end

function RI_buildMasterList (self)
	
	if GUILD_ROSTER_MANAGER_RI_BuildMasterList ~= nil then GUILD_ROSTER_MANAGER_RI_BuildMasterList(self) end
	
	if guildId ~= GUILD_SELECTOR.guildId then
		
		
		guildId = GUILD_SELECTOR.guildId
		local n = GetNumGuildRanks(guildId)
		
		local sl = ZO_GuildRosterSearchLabel
		local filterTarget = sl:GetParent()
		for i = 1, 15 do 
			local btnName = filterTarget:GetName() .. "RankFilterBtn" .. i
			local button = RI.GetNamedChildEx(filterTarget,btnName)
			
			if (button == nil) then 
				break
			end			
			RI.InitButtonsForGuild(button,guildId, i , i <= n)
		end
	end
end

function RI.H_PlayerActivated ()
  EVENT_MANAGER:UnregisterForEvent(AddonName, EVENT_PLAYER_ACTIVATED) 
  
  zo_callLater(function() RI.GuildRosterEnable(true) end, 199)
  
end

local function onAddOnLoaded(eventCode, pAddonName)

  if not (pAddonName == AddonName) then
    return
  end
  
  SLASH_COMMANDS["/calc"] = function(v) 
	SLASH_COMMANDS["/script"]("d(" .. v .. ")")	
  end
  
  EVENT_MANAGER:UnregisterForEvent(AddonName, EVENT_ADD_ON_LOADED)  
  EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_PLAYER_ACTIVATED, RI.H_PlayerActivated)

end

EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_ADD_ON_LOADED, onAddOnLoaded)

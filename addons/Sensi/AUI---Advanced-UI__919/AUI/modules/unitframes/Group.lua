local g_isInit = false

local maxGroupSize = 4
local maxRaidSize = 24	

local groupInviteList = {}
local isPreviewGroupSize = 4

local function InvitePendingGroupMembers()
	if not g_isInit then
		return
	end

	for unitTag, unitName in pairs(groupInviteList) do
		if IsUnitOnline(unitTag) and not IsUnitGrouped(unitTag) then
			GroupInviteByName(unitName)
			groupInviteList[unitTag] = nil
		end
	end	
	
	local length = AUI.Table.GetLength(groupInviteList)
	if length <= 0 then
		EVENT_MANAGER:UnregisterForUpdate("AUI_PendingGroupMembers")	
	end
end

local function LeaveGroup()
	GroupLeave()
end

local function PromoteToLeader(_unitTag)
	GroupPromote(_unitTag) 
end

local function Whisper(_unitTag)
	local unitName = GetUnitName(_unitTag)
	StartChatInput("", CHAT_CHANNEL_WHISPER, unitName)
end

local function TravelToPlayer(_unitTag)
	local unitName = GetUnitName(_unitTag)
	JumpToGroupMember(unitName)
end

local function KickPlayer(_unitTag)
	GroupKick(_unitTag) 
end

local function ReGroup()
	groupInviteList = {}

	for i = 1, GetGroupSize(), 1 do
		local unitTag = GetGroupUnitTagByIndex(i)
		
		local isUnitPlayer = AreUnitsEqual("player", unitTag)
		if not isUnitPlayer then
			local unitName = GetUnitName(unitTag)
			groupInviteList[unitTag] = unitName
		end
	end
	
	GroupDisband()
	
	EVENT_MANAGER:RegisterForUpdate("AUI_PendingGroupMembers", 100, InvitePendingGroupMembers)
end

local function CreateGroupMouseMenu(_unitTag)
	local isUnitPlayer = AreUnitsEqual("player", _unitTag) 
	local isPlayerLeader = IsUnitGroupLeader("player")
	local isUnitOnline = IsUnitOnline(_unitTag)
	
	if not isUnitPlayer then
		if isUnitOnline then
			AUI.AddMouseMenuButton("AUI_GROUP_WHISPER", AUI.L10n.GetString("whisper"), function() Whisper(_unitTag) end)
			AUI.AddMouseMenuButton("AUI_GROUP_TRAVEL_TO_PLAYER", AUI.L10n.GetString("travel_to_player"), function() TravelToPlayer(_unitTag) end)
				
			if isPlayerLeader then
				AUI.AddMouseMenuLine("AUI_GROUP_FISRT_LINE")
			end
		end
	end			
	
	if isPlayerLeader then
		if not isUnitPlayer then	
			if isUnitOnline then
				AUI.AddMouseMenuButton("AUI_GROUP_PROMOTE_TO_LEADER", AUI.L10n.GetString("promote_to_leader"), function() PromoteToLeader(_unitTag) end)
			end
			AUI.AddMouseMenuButton("AUI_GROUP_KICK_PLAYER", AUI.L10n.GetString("kick_from_group"), function() KickPlayer(_unitTag) end)
		end
		AUI.AddMouseMenuButton("AUI_GROUP_DISBAND", AUI.L10n.GetString("disband_group"), function() GroupDisband() end)
			
		for i = 1, GetGroupSize(), 1 do
			local unitTag = GetGroupUnitTagByIndex(i)
			local isUnitOnline = IsUnitOnline(unitTag)
			local isUnitPlayer = AreUnitsEqual("player", unitTag) 
				 
			if not isUnitPlayer and isUnitOnline then
				AUI.AddMouseMenuButton("AUI_GROUP_RE_GROUP", AUI.L10n.GetString("re_group"), function() ReGroup() end)
				break		
			end
		end		
	end	
		
	if not isUnitPlayer and isUnitOnline then
		AUI.AddMouseMenuLine("AUI_GROUP_SECOND_LINE")
	end
	AUI.AddMouseMenuButton("AUI_GROUP_LEAVE", AUI.L10n.GetString("leave_group"), function() LeaveGroup() end)		
end

function AUI.UnitFrames.Group.UpdateUI()
	if not g_isInit then
		return
	end

	local isPreviewShowed = AUI.UnitFrames.IsPreviewShow()
	local isRaid = AUI.UnitFrames.Group.IsRaid()
	local groupSize = 4
	
	local groupTemplate = AUI.UnitFrames.GetActiveGroupTemplateData()
	local frames = groupTemplate.frameData[AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].control.frames
	local companionFrames = groupTemplate.frameData[AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].control.frames
	local ungroupedCompanionFrame = companionFrames[AUI_COMPANION_UNIT_TAG]	
	
	if isRaid then
		local raidTemplate = AUI.UnitFrames.GetActiveRaidTemplateData()
	
		groupSize = 24
		
		frames = raidTemplate.frameData[AUI_UNIT_FRAME_TYPE_RAID_HEALTH].control.frames	
		companionFrames = raidTemplate.frameData[AUI_UNIT_FRAME_TYPE_RAID_COMPANION].control.frames				
	end		
	
	local sortedGroupList = {}
	local numActiveGroupPlayer = 0
	
	for i = 1, groupSize, 1 do
		local unitTag = GetGroupUnitTagByIndex(i)		
		if unitTag and DoesUnitExist(unitTag) or isPreviewShowed then	
			local role = 0
			local sortId = 0
		
			if isPreviewShowed then
				unitTag = "group" .. i					
				
				if i == 1 then
					role = LFG_ROLE_TANK
					sortId = 0
				elseif i == 2 then
					role = LFG_ROLE_HEAL
					sortId = 2
				else
					role = LFG_ROLE_DPS
					sortId = 1
				end
			else
				role = GetGroupMemberSelectedRole(unitTag)
				if role == LFG_ROLE_TANK then
					sortId = 0
				elseif role == LFG_ROLE_HEAL then
					sortId = 2			
				else
					sortId = 1
				end
			end			
		
			sortedGroupList[i] = 
			{
				sortId = sortId,
				role = role,
				unitTag = unitTag
			}			
			
			numActiveGroupPlayer = numActiveGroupPlayer + 1
		end		
	end	

	if numActiveGroupPlayer >= 2 or isPreviewShowed then
		table.sort (sortedGroupList, function (k1, k2) if k1 and k2 then return k1.sortId < k2.sortId end end )
	
		local frameCount = 0			
		local maxRowCount = 4
		local blockCount = 1
							
		local currentTop = 0
		local currentBlockTop = 0
		local currentBlockLeft = 0
		local currentLeft = 0

		local frameHeight = 0
		local frameWidth = 0
		local rowCount = 4	

		local lastFrame = nil
		for i, data in ipairs(sortedGroupList) do
			local unitTag = data.unitTag
			local groupFrame = frames[unitTag]
			
			if groupFrame then	
				groupFrame.role = data.role
				rowCount = groupFrame.settings.row_count
				
				if frameWidth == 0 then
					frameWidth = groupFrame:GetWidth()		
				end
				
				if frameHeight == 0 then
					frameHeight = groupFrame:GetHeight()		
				end								
						
				if groupFrame.settings.row_distance and groupFrame.settings.row_distance > 0 then
					frameHeight = frameHeight + groupFrame.settings.row_distance 
				end
														
				if groupFrame.settings.column_distance and groupFrame.settings.column_distance > 0 then
					frameWidth = frameWidth + groupFrame.settings.column_distance 
				end										
																										
				if frameCount > 1 and frameCount % (rowCount * 3) == 0 then
					if blockCount % 2 == 0 then
						currentBlockTop = 0
						currentTop = 0
						currentLeft = (currentLeft + frameWidth) + 20
						currentBlockLeft = currentLeft
					else
						currentLeft = currentBlockLeft
						currentTop = (currentTop + frameHeight) + 8
						currentBlockTop = currentTop
					end
										
					blockCount = blockCount + 1
				elseif frameCount % rowCount == 0 then
					if frameCount > 1 then
						currentTop = currentBlockTop
						currentLeft = currentLeft + frameWidth
					end
				else
					if isRaid then
						currentTop = currentTop + frameHeight + 4
					else
						currentTop = currentTop + frameHeight
					end
				end
				
				groupFrame:ClearAnchors()				
				groupFrame:SetAnchor(TOPLEFT, nil, TOPLEFT, currentLeft, currentTop)																												

				if groupFrame.leaderIconControl then
					local isUnitLeader = isPreviewShowed or IsUnitGroupLeader(unitTag)				
					if isUnitLeader then
						groupFrame.leaderIconControl:SetHidden(false)					
					else
						groupFrame.leaderIconControl:SetHidden(true)			
					end
				end								
			
				frameCount = frameCount + 1
				frameWidth = groupFrame:GetWidth()						
				frameHeight = groupFrame:GetHeight()		
				lastFrame = groupFrame
				
				local companionTag = GetCompanionUnitTagByGroupUnitTag(unitTag)
				local companionFrame = companionFrames[companionTag]
				if companionFrame then
					if DoesUnitExist(companionTag) or isPreviewShowed then					
						companionFrame:ClearAnchors()				
						companionFrame:SetAnchor(BOTTOMLEFT, groupFrame, nil, companionFrame.offsetX)	
						companionFrame:SetAnchor(BOTTOMRIGHT, groupFrame, nil, 0, companionFrame.offsetY + companionFrame:GetHeight() - 1)	

						if not isRaid then						
							currentTop = currentTop + frameHeight + 10
							frameHeight = companionFrame:GetHeight()
						end
						
						lastFrame = companionFrame
					end									
				end				
			end		
		end
		
		if frameCount > 0 then	
			if isRaid then
				AUI_Attributes_Window_Raid:SetHidden(false)	
				AUI_Attributes_Window_Group:SetHidden(true)
			else
				AUI_Attributes_Window_Raid:SetHidden(true)
				AUI_Attributes_Window_Group:SetHidden(false)
			end
		else
			AUI_Attributes_Window_Group:SetHidden(true)
			AUI_Attributes_Window_Raid:SetHidden(true)			
		end
		
		AUI.UnitFrames.Update(AUI_COMPANION_UNIT_TAG)
		
		for i = 1, groupSize, 1 do
			AUI.UnitFrames.Update("group" .. i)	
			AUI.UnitFrames.Update("group" .. i .. "companion")	
		end		
	elseif DoesUnitExist(AUI_COMPANION_UNIT_TAG) then	
		local groupTemplate = AUI.UnitFrames.GetActiveGroupTemplateData()	
		local frames = groupTemplate.frameData[AUI_UNIT_FRAME_TYPE_GROUP_HEALTH].control.frames		
		local companionFrames = groupTemplate.frameData[AUI_UNIT_FRAME_TYPE_GROUP_COMPANION].control.frames
		local companionFrame = companionFrames[AUI_COMPANION_UNIT_TAG]
		
		if companionFrame then
			companionFrame:ClearAnchors()				
			companionFrame:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 0)			
		end

		AUI.UnitFrames.Update(AUI_COMPANION_UNIT_TAG)
		
		AUI_Attributes_Window_Group:SetHidden(false)
		AUI_Attributes_Window_Raid:SetHidden(true)	

		for i = 1, groupSize, 1 do
			AUI.UnitFrames.Update("group" .. i)	
			AUI.UnitFrames.Update("group" .. i .. "companion")
		end			
	else
		AUI_Attributes_Window_Group:SetHidden(true)
		AUI_Attributes_Window_Raid:SetHidden(true)		
	end
end

function AUI.UnitFrames.Group.OnFrameMouseUp(_button, _ctrl, _alt, _shift, _frame)
	if not AUI.UnitFrames.IsPreviewShow() then
		if _frame.attributeId == AUI_UNIT_FRAME_TYPE_GROUP_HEALTH or _frame.attributeId == AUI_UNIT_FRAME_TYPE_RAID_HEALTH then
			if _button == 1 then
				AUI.HideMouseMenu()
			elseif _button == 2 then
				AUI.ShowMouseMenu(GetUnitName(_frame.unitTag))
				CreateGroupMouseMenu(_frame.unitTag)
			end		
		end
	end
end	
	
function AUI.UnitFrames.Group.IsRaid()
	local isPreviewShowed = AUI.UnitFrames.IsPreviewShow()
	if isPreviewShowed then
		if isPreviewGroupSize > 4 then
			return true
		end
	else
		if GetGroupSize() > 4 then
			return true
		end	
	end

	return false
end	
	
function AUI.UnitFrames.Group.SetPreviewGroupSize(_groupSize)
	isPreviewGroupSize = _groupSize	
end
	
function AUI.UnitFrames.Group.ReGroup()
	if not g_isInit then
		return
	end

	ReGroup()	
end		

function AUI.UnitFrames.Group.Load()
	g_isInit = true
	
	--disable default group frame
	ZO_UnitFramesGroups:SetHidden(true)		
end
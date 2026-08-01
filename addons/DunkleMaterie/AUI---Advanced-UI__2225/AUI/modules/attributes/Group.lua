local isLoaded = false

local maxGroupSize = 4
local maxRaidSize = 24	

local groupInviteList = {}
local isPreviewGroupSize = 4

local function InvitePendingGroupMembers()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Group.InvitePendingGroupMembers")
	end
	--/DebugMessage--

	if not isLoaded then
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

function AUI.Attributes.Group.UpdateUI(_unitTag)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Group.UpdateUI")
	end
	--/DebugMessage--

	local isPreviewShowed = AUI.Attributes.IsPreviewShow()
	
	if IsUnitGrouped(AUI_PLAYER_UNIT_TAG) or isPreviewShowed then
		local frameCount = 0			

		local isRaid = AUI.Attributes.Group.IsRaid()	
	
		local maxRowCount = 4
		local blockCount = 1
							
		local currentTop = 0
		local currentBlockTop = 0
		local currentBlockLeft = 0
		local currentLeft = 0

		local frameHeight = 0
		local frameWidth = 0
		local rowCount = 4	
	
		local groupSize = 4
		
		local currentTemplate = AUI.Attributes.GetCurrentTemplateData()	
		
		if not currentTemplate then
			return
		end
		
		local frames = currentTemplate.attributeData[AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].control.frames
		local shieldFrames = currentTemplate.attributeData[AUI_ATTRIBUTE_TYPE_GROUP_SHIELD].control.frames
		
		if isRaid then
			groupSize = 24
			
			frames = currentTemplate.attributeData[AUI_ATTRIBUTE_TYPE_RAID_HEALTH].control.frames
			shieldFrames = currentTemplate.attributeData[AUI_ATTRIBUTE_TYPE_RAID_SHIELD].control.frames		
		end	

		for i = 1, groupSize, 1 do
			local unitTag = GetGroupUnitTagByIndex(i)
			
			if isPreviewShowed then
				unitTag = "group" .. i
			end	
			
			local groupFrame = frames[unitTag]
			local groupShieldFrame = shieldFrames[unitTag]			
			
			if groupFrame and groupShieldFrame then	
				if unitTag and IsUnitGrouped(unitTag) or isPreviewShowed then
					rowCount = groupFrame.settings.rowCount or 4
					frameHeight = groupFrame:GetHeight()
					frameWidth = groupFrame:GetWidth()						
							
					if groupFrame.settings.rowDistance then
						frameHeight = frameHeight + groupFrame.settings.rowDistance 
					end
															
					if  groupFrame.settings.columnDistance then
						frameWidth = frameWidth + groupFrame.settings.columnDistance 
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
						currentTop = currentTop + frameHeight
					end
					groupFrame:ClearAnchors()				
					groupFrame:SetAnchor(TOPLEFT, _parent, TOPLEFT, currentLeft, currentTop)																								

					local isUnitLeader = isPreviewShowed or IsUnitGroupLeader(groupFrame.unitTag)

					if groupFrame.leaderIconControl then
						if isUnitLeader then
							groupFrame.leaderIconControl:SetHidden(false)					
						else
							groupFrame.leaderIconControl:SetHidden(true)			
						end
					end								
				
					frameCount = frameCount + 1
				end

				if not _unitTag or _unitTag == unitTag then
					AUI.Attributes.Update(unitTag)
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
	else
		AUI_Attributes_Window_Group:SetHidden(true)
		AUI_Attributes_Window_Raid:SetHidden(true)		
	end	
end

function AUI.Attributes.Group.OnFrameMouseUp(_button, _ctrl, _alt, _shift, _frame)
	if not AUI.Attributes.IsPreviewShow() then
		if _frame.attributeId == AUI_ATTRIBUTE_TYPE_GROUP_HEALTH or _frame.attributeId == AUI_ATTRIBUTE_TYPE_RAID_HEALTH then
			if _button == 1 then
				AUI.HideMouseMenu()
			elseif _button == 2 then
				AUI.ShowMouseMenu(GetUnitName(_frame.unitTag))
				CreateGroupMouseMenu(_frame.unitTag)
			end		
		end
	end
end	
	
function AUI.Attributes.Group.IsRaid()
	local isPreviewShowed = AUI.Attributes.IsPreviewShow()
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
	
function AUI.Attributes.Group.SetPreviewGroupSize(_groupSize)
	isPreviewGroupSize = _groupSize	
end
	
function AUI.Attributes.Group.ReGroup()
	if not isLoaded then
		return
	end

	ReGroup()	
end		

function AUI.Attributes.Group.Load()
	isLoaded = true
	
	--disable default group frame
	ZO_UnitFramesGroups:SetHidden(true)		
end
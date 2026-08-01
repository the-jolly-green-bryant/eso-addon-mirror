local g_Templates = 
{
	["Player"] = {},
	["Target"] = {},
	["Group"] = {},
	["Raid"] = {},
	["Boss"] = {},
	["Companion"] = {}
}

local g_tempGroupFames = {}
local g_tempRaidFames = {}	
local g_tempBossFames = {}

local g_activePlayerTemplate = nil
local g_activeTargetTemplate = nil
local g_activeGroupTemplate = nil
local g_activeRaidTemplate = nil
local g_activeBossTemplate = nil
local g_activeCompanionTemplate = nil

local g_activeTemplates = nil

local function SetControlData(_control)
	if _control then
		local controlName = _control:GetName()
	
		AUI.UnitFrames.ResetControlData(_control)
	
		if AUI.UnitFrames.IsPlayer(_control.attributeId) then
			_control.templateType = "Player"
			_control.templateName = AUI.Settings.Templates.Attributes.Player
		elseif AUI.UnitFrames.IsTarget(_control.attributeId) then
			_control.templateType = "Target"
			_control.templateName = AUI.Settings.Templates.Attributes.Target
		elseif AUI.UnitFrames.IsGroup(_control.attributeId) then
			_control.templateType = "Group"
			_control.templateName = AUI.Settings.Templates.Attributes.Group
		elseif AUI.UnitFrames.IsGroupCompanion(_control.attributeId) then
			_control.templateType = "Group"
			_control.templateName = AUI.Settings.Templates.Attributes.Group			
		elseif AUI.UnitFrames.IsRaid(_control.attributeId) then
			_control.templateType = "Raid"
			_control.templateName = AUI.Settings.Templates.Attributes.Raid		
		elseif AUI.UnitFrames.IsRaidCompanion(_control.attributeId) then
			_control.templateType = "Raid"
			_control.templateName = AUI.Settings.Templates.Attributes.Raid					
		elseif AUI.UnitFrames.IsBoss(_control.attributeId) then
			_control.templateType = "Boss"
			_control.templateName = AUI.Settings.Templates.Attributes.Boss
		elseif AUI.UnitFrames.IsMainCompanion(_control.attributeId) then
			_control.templateType = "Companion"
			_control.templateName = AUI.Settings.Templates.Attributes.Companion			
		end

		_control.bar = GetControl(_control, "_Bar")	
		_control.bar2 =  GetControl(_control, "_Bar2")	

		_control.textValueControl = GetControl(_control, "_Text_Value")
		_control.textMaxValueControl = GetControl(_control, "_Text_MaxValue")
		_control.textPercentControl = GetControl(_control, "_Text_Percent")
		_control.leaderIconControl = GetControl(_control, "_LeaderIcon")	
		_control.levelControl = GetControl(_control, "_Text_Level")	
		_control.championIconControl = GetControl(_control, "_ChampionIcon")	
		_control.classIconControl = GetControl(_control, "_ClassIcon")	
		_control.rankIconControl = GetControl(_control, "_RankIcon")	
		_control.titleControl = GetControl(_control, "_Title")	
		_control.unitNameControl = GetControl(_control, "_Text_Name")
		_control.offlineInfoControl = GetControl(_control, "_Text_Offline")
		_control.deadInfoControl = GetControl(_control, "_Text_DeadInfo")
		_control.warnerControl = GetControl(_control, "Warner")	
		
		_control.increasedArmorOverlayControl = GetControl(_control, "IncreasedArmorOverlay")
		_control.decreasedArmorOverlayControl = GetControl(_control, "DecreasedArmorOverlay")
		_control.increasedPowerOverlayControl = GetControl(_control, "IncreasedPowerOverlay")
		_control.decreasedPowerOverlayControl = GetControl(_control, "DecreasedPowerOverlay")

		if _control.warnerControl then
			_control.leftWarnerControl = GetControl(_control.warnerControl, "FrameLeftWarner")	
			_control.rightWarnerControl = GetControl(_control.warnerControl, "FrameRightWarner")	
			_control.centerWarnerControl = GetControl(_control.warnerControl, "FrameCenterWarner")
		end

		if _control.increasedArmorOverlayControl then
			_control.increasedArmorOverlayControl:SetHidden(true)
		end

		if _control.decreasedArmorOverlayControl then
			_control.decreasedArmorOverlayControl:SetHidden(true)		
		end
		
		if _control.increasedPowerOverlayControl and _control.increasedPowerOverlayControl.animation then
			_control.increasedPowerOverlayControl:SetHidden(true)		
		end
		
		if _control.decreasedPowerOverlayControl then
			_control.decreasedPowerOverlayControl:SetColor(AUI.Color.ConvertHexToRGBA("#000000", 1):UnpackRGBA())
			_control.decreasedPowerOverlayControl:SetHidden(true)
		end
	
		_control.defaultAnchor = 
		{
			[0] = {},
			[1] = {}
		}	
		_, _control.defaultAnchor[0].point, _, _control.defaultAnchor[0].relativePoint, _control.defaultAnchor[0].offsetX, _control.defaultAnchor[0].offsetY = _control:GetAnchor(0)
		_, _control.defaultAnchor[1].point, _, _control.defaultAnchor[1].relativePoint, _control.defaultAnchor[1].offsetX, _control.defaultAnchor[1].offsetY = _control:GetAnchor(1)
	
		if _control.bar then
			_control.bar.barGloss = GetControl(_control.bar, "Gloss")
			_control.bar.increaseRegControl = GetControl(_control.bar, "_IncreaseRegLeft")		
			_control.bar.decreaseRegControl = GetControl(_control.bar, "_DecreaseRegLeft")	

			_control.bar.defaultAnchor = 
			{
				[0] = {},
				[1] = {}
			}
	
			_, _control.bar.defaultAnchor[0].point, _, _control.bar.defaultAnchor[0].relativePoint, _control.bar.defaultAnchor[0].offsetX, _control.bar.defaultAnchor[0].offsetY = _control.bar:GetAnchor(0)		
			_, _control.bar.defaultAnchor[1].point, _, _control.bar.defaultAnchor[1].relativePoint, _control.bar.defaultAnchor[1].offsetX, _control.bar.defaultAnchor[1].offsetY = _control.bar:GetAnchor(1)

			if _control.bar.increaseRegControl then
				_control.bar.increaseRegControl.defaultAnchor = {}	
				_, _control.bar.increaseRegControl.defaultAnchor.point, _, _control.bar.increaseRegControl.defaultAnchor.relativePoint, _control.bar.increaseRegControl.defaultAnchor.offsetX, _control.bar.increaseRegControl.defaultAnchor.offsetY = _control.bar.increaseRegControl:GetAnchor(0)		

				if not _control.bar.increaseRegControl.animation then
					_control.bar.increaseRegControl.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("AUI_Attribute_ArrowAnimation", _control.bar.increaseRegControl)				
				end	
			end
			
			if _control.bar.decreaseRegControl then
				_control.bar.decreaseRegControl.defaultAnchor = {}	
				_, _control.bar.decreaseRegControl.defaultAnchor.point, _, _control.bar.decreaseRegControl.defaultAnchor.relativePoint, _control.bar.decreaseRegControl.defaultAnchor.offsetX, _control.bar.decreaseRegControl.defaultAnchor.offsetY = _control.bar.decreaseRegControl:GetAnchor(0)				

				if not _control.bar.decreaseRegControl.animation then
					_control.bar.decreaseRegControl.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("AUI_Attribute_ArrowAnimation", _control.bar.decreaseRegControl)					
				end	
			end
		end

		if _control.bar2 then
			_control.bar2.barGloss = GetControl(_control.bar2, "Gloss")					
			_control.bar2.increaseRegControl = GetControl(_control.bar2, "_IncreaseRegRight")	
			_control.bar2.decreaseRegControl = GetControl(_control.bar2, "_DecreaseRegRight")

			_control.bar2.defaultAnchor = 
			{
				[0] = {},
				[1] = {}
			}
			
			_, _control.bar2.defaultAnchor[0].point, _, _control.bar2.defaultAnchor[0].relativePoint, _control.bar2.defaultAnchor[0].offsetX, _control.bar2.defaultAnchor[0].offsetY = _control.bar2:GetAnchor(0)		
			_, _control.bar2.defaultAnchor[1].point, _, _control.bar2.defaultAnchor[1].relativePoint, _control.bar2.defaultAnchor[1].offsetX, _control.bar2.defaultAnchor[1].offsetY = _control.bar2:GetAnchor(1)	

			if _control.bar2.increaseRegControl then
				_control.bar2.increaseRegControl.defaultAnchor = {}	
				_, _control.bar2.increaseRegControl.defaultAnchor.point, _, _control.bar2.increaseRegControl.defaultAnchor.relativePoint, _control.bar2.increaseRegControl.defaultAnchor.offsetX, _control.bar2.increaseRegControl.defaultAnchor.offsetY = _control.bar2.increaseRegControl:GetAnchor(0)		

				if not _control.bar2.increaseRegControl.animation then
					_control.bar2.increaseRegControl.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("AUI_Attribute_ArrowAnimation", _control.bar2.increaseRegControl)				
				end	
			end
			
			if _control.bar2.decreaseRegControl then
				_control.bar2.decreaseRegControl.defaultAnchor = {}	
				_, _control.bar2.decreaseRegControl.defaultAnchor.point, _, _control.bar2.decreaseRegControl.defaultAnchor.relativePoint, _control.bar2.decreaseRegControl.defaultAnchor.offsetX, _control.bar2.decreaseRegControl.defaultAnchor.offsetY = _control.bar2.decreaseRegControl:GetAnchor(0)			

				if not _control.bar2.decreaseRegControl.animation then
					_control.bar2.decreaseRegControl.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("AUI_Attribute_ArrowAnimation", _control.bar2.decreaseRegControl)				
				end	
			end			
		end		
	end
end

local function LoadData(templateData, type)
	local data = templateData.frameData[type]

	if not data then
		return
	end
	
	local unitTag = nil
	local powerType = nil
	local attributeId = nil		
	
	if type == AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH then
		unitTag = AUI_PLAYER_UNIT_TAG
		powerType = POWERTYPE_HEALTH	
	elseif type == AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA then	
		unitTag = AUI_PLAYER_UNIT_TAG
		powerType = POWERTYPE_MAGICKA		
	elseif type == AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA then
		unitTag = AUI_PLAYER_UNIT_TAG
		powerType = POWERTYPE_STAMINA
	elseif type == AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT then
		unitTag = AUI_PLAYER_UNIT_TAG
		powerType = POWERTYPE_MOUNT_STAMINA
	elseif type == AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF then
		unitTag = AUI_PLAYER_UNIT_TAG
		powerType = POWERTYPE_WEREWOLF	
	elseif type == AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE then
		unitTag = AUI_CONTROLED_SIEGE_UNIT_TAG
		powerType = POWERTYPE_HEALTH	
	elseif type == AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD then
		unitTag = AUI_PLAYER_UNIT_TAG
		powerType = POWERTYPE_HEALTH			
	elseif type == AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_HEALTH then
		unitTag = AUI_TARGET_UNIT_TAG
		powerType = POWERTYPE_HEALTH	
	elseif type == AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_SHIELD then
		unitTag = AUI_TARGET_UNIT_TAG
		powerType = POWERTYPE_HEALTH	
	elseif type == AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_HEALTH then
		unitTag = AUI_TARGET_UNIT_TAG
		powerType = POWERTYPE_HEALTH	
	elseif type == AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_SHIELD then
		unitTag = AUI_TARGET_UNIT_TAG
		powerType = POWERTYPE_HEALTH			
	elseif type == AUI_UNIT_FRAME_TYPE_GROUP_HEALTH then
		unitTag = AUI_GROUP_UNIT_TAG
		powerType = POWERTYPE_HEALTH				
	elseif type == AUI_UNIT_FRAME_TYPE_RAID_HEALTH then
		unitTag = AUI_GROUP_UNIT_TAG
		powerType = POWERTYPE_HEALTH		
	elseif type == AUI_UNIT_FRAME_TYPE_BOSS_HEALTH then
		unitTag = AUI_BOSS_UNIT_TAG
		powerType = POWERTYPE_HEALTH	
	elseif type == AUI_UNIT_FRAME_TYPE_COMPANION then
		unitTag = AUI_COMPANION_UNIT_TAG
		powerType = POWERTYPE_HEALTH
	end			

	local controlName = data.name		
	local isVirtual = data.virtual
	if controlName then			
		if type == AUI_UNIT_FRAME_TYPE_GROUP_HEALTH then	
			data.control = AUI_Attributes_Window_Group
			data.control.frames = {}
					
			for i = 1, 4, 1 do
				local unitTag = "group" .. i
				local frame = CreateControlFromVirtual(controlName, data.control, controlName, i)	

				frame.unitTag = unitTag
				frame.powerType = powerType
				frame.attributeId = type
				frame.unitAttributeVisual = unitAttributeVisual						
				frame:SetHidden(true)
				frame:SetAlpha(1)		

				data.control.frames[frame.unitTag] = frame
				g_tempGroupFames[frame.unitTag] = frame	

				SetControlData(frame)		
			end						
		elseif type == AUI_UNIT_FRAME_TYPE_RAID_HEALTH then
			data.control = AUI_Attributes_Window_Raid
			data.control.frames = {}
					
			for i = 1, 24, 1 do
				local unitTag = "group" .. i
				local frame = CreateControlFromVirtual(controlName, data.control, controlName, unitTag)	
				frame.unitTag = unitTag
				frame.powerType = powerType
				frame.attributeId = type				
				frame:SetHidden(true)
				frame:SetAlpha(1)										

				data.control.frames[frame.unitTag] = frame	
				g_tempRaidFames[frame.unitTag] = frame

				SetControlData(frame)						
			end	
		elseif type == AUI_UNIT_FRAME_TYPE_GROUP_SHIELD then
			data.control = AUI_Attributes_Window_Group_Shield				
			data.control.frames = {}
					
			for i = 1, 4, 1 do
				local unitTag = "group" .. i
				local frame = CreateControlFromVirtual(controlName, g_tempGroupFames[unitTag], controlName, i)	

				frame.unitTag = unitTag
				frame.powerType = POWERTYPE_HEALTH
				frame.attributeId = type							
				frame:SetHidden(true)
				frame:SetAlpha(1)

				if frame.owns then
					frame.mainControl = g_tempGroupFames[unitTag]
					frame.mainControl.subControl = frame
				else
					frame:SetParent(g_tempGroupFames[unitTag])
				end

				data.control.frames[frame.unitTag] = frame

				SetControlData(frame)	
			end					
		elseif type == AUI_UNIT_FRAME_TYPE_RAID_SHIELD then
			data.control = AUI_Attributes_Window_Raid_Shield
			data.control.frames = {}
								
			for i = 1, 24, 1 do
				local unitTag = "group" .. i
				local frame = CreateControlFromVirtual(controlName, g_tempRaidFames[unitTag], controlName, i)	
				frame.unitTag = unitTag
				frame.powerType = POWERTYPE_HEALTH				
				frame.attributeId = type						
				frame:SetHidden(true)
				frame:SetAlpha(1)	

				if frame.owns then
					frame.mainControl = g_tempRaidFames[unitTag]
					frame.mainControl.subControl = frame
					frame:SetParent(frame.mainControl)
				else
					frame:SetParent(g_tempRaidFames[unitTag])
				end	

				data.control.frames[frame.unitTag] = frame
				
				SetControlData(frame)	
			end	
		elseif type == AUI_UNIT_FRAME_TYPE_GROUP_COMPANION then
			data.control = AUI_Attributes_Window_Group_Companion	 
			data.control.frames = {}
			
			local unitTag = "group1"
			local companionTag = AUI_COMPANION_UNIT_TAG
			
			local frame = CreateControlFromVirtual(controlName, AUI_Attributes_Window_Group, controlName, 0)	

			frame.unitTag = companionTag
			frame.powerType = POWERTYPE_HEALTH
			frame.attributeId = type					
			frame:SetHidden(true)
			frame:SetAlpha(1)

			data.control.frames[frame.unitTag] = frame

			SetControlData(frame)			
			
			for i = 1, 4, 1 do
				local unitTag = "group" .. i
				local companionTag = GetCompanionUnitTagByGroupUnitTag(unitTag)
				
				local frame = CreateControlFromVirtual(controlName, g_tempGroupFames[unitTag], controlName, i)	

				frame.unitTag = companionTag
				frame.powerType = POWERTYPE_HEALTH
				frame.attributeId = type					
				frame:SetHidden(true)
				frame:SetAlpha(1)

				data.control.frames[frame.unitTag] = frame

				SetControlData(frame)	
			end			
		elseif type == AUI_UNIT_FRAME_TYPE_RAID_COMPANION then
			data.control = AUI_Attributes_Window_Raid_Companion	 
			data.control.frames = {}
				
			for i = 1, 12, 1 do
				local unitTag = "group" .. i
				local companionTag = GetCompanionUnitTagByGroupUnitTag(unitTag)
				
				local frame = CreateControlFromVirtual(controlName, g_tempRaidFames[unitTag], controlName, i)		

				frame.unitTag = companionTag
				frame.powerType = POWERTYPE_HEALTH
				frame.attributeId = type					
				frame:SetHidden(true)
				frame:SetAlpha(1)				

				data.control.frames[frame.unitTag] = frame

				SetControlData(frame)	
			end				
		elseif type == AUI_UNIT_FRAME_TYPE_BOSS_HEALTH then
			data.control = AUI_Attributes_Window_Boss
			data.control.frames = {}
					
			for i = 1, MAX_BOSSES, 1 do
				local unitTag = "boss" .. i
				local frame = CreateControlFromVirtual(controlName, data.control, controlName, i)	

				frame.unitTag = unitTag
				frame.powerType = powerType
				frame.attributeId = type						
				frame:SetHidden(true)
				frame:SetAlpha(1)		

				data.control.frames[frame.unitTag] = frame
				g_tempBossFames[frame.unitTag] = frame	

				SetControlData(frame)						
			end	
		elseif type == AUI_UNIT_FRAME_TYPE_BOSS_SHIELD then
			data.control = AUI_Attributes_Window_Boss_Shield
			data.control.frames = {}
					
			for i = 1, MAX_BOSSES, 1 do
				local unitTag = "boss" .. i
				local frame = CreateControlFromVirtual(controlName, g_tempBossFames[unitTag], controlName, i)	
				frame.unitTag = unitTag
				frame.powerType = POWERTYPE_HEALTH				
				frame.attributeId = type	
				frame:SetHidden(true)
				frame:SetAlpha(1)	

				if frame.owns then
					frame.mainControl = g_tempBossFames[unitTag]
					frame.mainControl.subControl = frame
					frame:SetParent(frame.mainControl)
				else
					frame:SetParent(g_tempBossFames[unitTag])
				end						

				data.control.frames[frame.unitTag] = frame
				
				SetControlData(frame)				
			end					
		else
			if isVirtual then
				data.control = CreateControlFromVirtual(controlName, AUI_Attributes_Window, controlName)	
			else
				data.control = GetControl(controlName)
			end
		end
	
		if data.control then	
			data.control.unitTag = unitTag
			data.control.powerType = powerType	
			data.control.attributeId = type							
		
			if data.control.frames then
				for _, frame in pairs(data.control.frames) do
					data.control.defaultWidth = frame:GetWidth()
					data.control.defaultHeight = frame:GetHeight()				
					break
				end			
			else
				data.control.defaultWidth = data.control:GetWidth()
				data.control.defaultHeight = data.control:GetHeight()	
			end
			
			SetControlData(data.control)
		end		
	end		
	
	data.attributeId = type
end

function AUI.UnitFrames.AddPlayerTemplate(_name, _internName, _version, _data)
	if not _name or not _internName or not _version or not _data then
		return
	end

	local data = {}
	data.version = _version
	data.name = _name
	data.internName = _internName
	data.frameData = _data
	if not g_Templates.Player[_internName] then
		g_Templates.Player[_internName] = data
	end
end

function AUI.UnitFrames.AddTargetTemplate(_name, _internName, _version, _data)
	if not _name or not _internName or not _version or not _data then
		return
	end

	local data = {}
	data.version = _version
	data.name = _name
	data.internName = _internName
	data.frameData = _data
	if not g_Templates.Target[_internName] then
		g_Templates.Target[_internName] = data
	end
end

function AUI.UnitFrames.AddGroupTemplate(_name, _internName, _version, _data)
	if not _name or not _internName or not _version or not _data then
		return
	end

	local data = {}
	data.version = _version
	data.name = _name
	data.internName = _internName
	data.frameData = _data
	if not g_Templates.Group[_internName] then
		g_Templates.Group[_internName] = data
	end
end

function AUI.UnitFrames.AddRaidTemplate(_name, _internName, _version, _data)
	if not _name or not _internName or not _version or not _data then
		return
	end

	local data = {}
	data.version = _version
	data.name = _name
	data.internName = _internName
	data.frameData = _data
	if not g_Templates.Raid[_internName] then
		g_Templates.Raid[_internName] = data
	end
end

function AUI.UnitFrames.AddBossTemplate(_name, _internName, _version, _data)
	if not _name or not _internName or not _version or not _data then
		return
	end

	local data = {}
	data.version = _version
	data.name = _name
	data.internName = _internName
	data.frameData = _data
	if not g_Templates.Boss[_internName] then
		g_Templates.Boss[_internName] = data
	end
end

function AUI.UnitFrames.AddCompanionTemplate(_name, _internName, _version, _data)
	if not _name or not _internName or not _version or not _data then
		return
	end

	local data = {}
	data.version = _version
	data.name = _name
	data.internName = _internName
	data.frameData = _data
	if not g_Templates.Companion[_internName] then
		g_Templates.Companion[_internName] = data
	end
end

function AUI.UnitFrames.LoadTemplate()
	g_activeTemplates = {}

	local playerTemplateName = AUI.Settings.Templates.Attributes.Player
	local playerTemplateData = g_Templates.Player[playerTemplateName]

	LoadData(playerTemplateData, AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH)
	LoadData(playerTemplateData, AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD)
	LoadData(playerTemplateData, AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA)
	LoadData(playerTemplateData, AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA)
	LoadData(playerTemplateData, AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT)
	LoadData(playerTemplateData, AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF)
	LoadData(playerTemplateData, AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE)
	
	g_activePlayerTemplate = playerTemplateData
	g_activeTemplates["Player"] = playerTemplateData 

	local targetTemplateName = AUI.Settings.Templates.Attributes.Target
	local targetTemplateData = g_Templates.Target[targetTemplateName]

	LoadData(targetTemplateData, AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_HEALTH)
	LoadData(targetTemplateData, AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_SHIELD)
	LoadData(targetTemplateData, AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_HEALTH)
	LoadData(targetTemplateData, AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_SHIELD)
	
	g_activeTargetTemplate = targetTemplateData
	g_activeTemplates["Target"] = targetTemplateData	

	local groupTemplateName = AUI.Settings.Templates.Attributes.Group	
	local groupTemplateData = g_Templates.Group[groupTemplateName]
	
	LoadData(groupTemplateData, AUI_UNIT_FRAME_TYPE_GROUP_HEALTH)
	LoadData(groupTemplateData, AUI_UNIT_FRAME_TYPE_GROUP_SHIELD)
	LoadData(groupTemplateData, AUI_UNIT_FRAME_TYPE_GROUP_COMPANION)
	
	g_activeGroupTemplate = groupTemplateData
	g_activeTemplates["Group"] = groupTemplateData

	local raidTemplateName = AUI.Settings.Templates.Attributes.Raid 
	local raidTemplateData = g_Templates.Raid[raidTemplateName]
	
	LoadData(raidTemplateData, AUI_UNIT_FRAME_TYPE_RAID_HEALTH)
	LoadData(raidTemplateData, AUI_UNIT_FRAME_TYPE_RAID_SHIELD)
	LoadData(raidTemplateData, AUI_UNIT_FRAME_TYPE_RAID_COMPANION)
	
	g_activeRaidTemplate = raidTemplateData
	g_activeTemplates["Raid"] = raidTemplateData

	local bossTemplateName = AUI.Settings.Templates.Attributes.Boss
	local bossTemplateData = g_Templates.Boss[bossTemplateName]

	LoadData(bossTemplateData, AUI_UNIT_FRAME_TYPE_BOSS_HEALTH)
	LoadData(bossTemplateData, AUI_UNIT_FRAME_TYPE_BOSS_SHIELD)
	
	g_activeBossTemplate = bossTemplateData
	g_activeTemplates["Boss"] = bossTemplateData
	
	--local companionTemplateName = AUI.Settings.Templates.Attributes.Companion
	--local companionTemplateData = g_Templates.Companion[companionTemplateName]

	--LoadData(companionTemplateData, AUI_UNIT_FRAME_TYPE_COMPANION)
	
	--g_activeCompanionTemplate = companionTemplateData
	--g_activeTemplates["Companion"] = companionTemplateData	
	
	g_tempGroupFames = nil
	g_tempRaidFames = nil	
	g_tempBossFames = nil	
	
	for _, templateData in pairs(g_activeTemplates) do
		for type, data in pairs(templateData.frameData) do	
			if data.control  then
				if data.control.mainBar and templateData.frameData[data.control.mainBar] then
					data.control.mainControl = templateData.frameData[data.control.mainBar].control
					data.control.mainControl.subControl = data.control
				end		
				
				if data.control.dependent and templateData.frameData[data.control.dependent] then
					data.control.dependentControl = templateData.frameData[data.control.dependent].control
				end	
			end	
		end		
	end
	
	return g_activeTemplates
end

function AUI.UnitFrames.GetThemeNames(_templateType)
	local names = {}

	for templateType, data in pairs(g_Templates[_templateType]) do
		table.insert(names, {[data.internName] = data.name})
	end

	return names
end

function AUI.UnitFrames.GetActiveTemplates()
	return g_activeTemplates	
end

function AUI.UnitFrames.GetActivePlayerTemplateData()
	return g_activePlayerTemplate	
end

function AUI.UnitFrames.GetActiveTargetTemplateData()
	return g_activeTargetTemplate	
end

function AUI.UnitFrames.GetActiveGroupTemplateData()
	return g_activeGroupTemplate	
end

function AUI.UnitFrames.GetActiveRaidTemplateData()
	return g_activeRaidTemplate	
end

function AUI.UnitFrames.GetActiveBossTemplateData()
	return g_activeBossTemplate	
end

function AUI.UnitFrames.GetActiveCompanionTemplateData()
	return g_activeCompanionTemplate	
end

function AUI.UnitFrames.SetDeactivePlayerTemplate()
	g_activeTemplates.Player = nil
	g_activePlayerTemplate = nil
end

function AUI.UnitFrames.SetDeactiveTargetTemplate()
	g_activeTemplates.Target = nil
	g_activeTargetTemplate = nil
end

function AUI.UnitFrames.SetDeactiveGroupTemplate()
	g_activeTemplates.Raid = nil
	g_activeRaidTemplate = nil
end

function AUI.UnitFrames.SetDeactiveRaidTemplate()
	g_activeTemplates.Raid = nil
	g_activeRaidTemplate = nil
end

function AUI.UnitFrames.SetDeactiveBossTemplate()
	g_activeTemplates.Boss = nil
	g_activeBossTemplate = nil
end

function AUI.UnitFrames.SetDeactiveCompanionTemplate()
	g_activeTemplates.Companion = nil
	g_activeCompanionTemplate = nil
end
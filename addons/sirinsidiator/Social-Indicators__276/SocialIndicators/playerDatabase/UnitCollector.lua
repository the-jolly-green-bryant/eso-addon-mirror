local RegisterForEvent = SocialIndicators.RegisterForEvent
local LogDebug = SocialIndicators.LogDebug
local GetUnitRaceId = SocialIndicators.GetUnitRaceId

local UnitCollector = ZO_Object:Subclass()
SocialIndicators.UnitCollector = UnitCollector

local DONT_CREATE = true
local TARGET_UNIT_TAG = "reticleover"
local UPDATE_FROM_TARGET_TIMEOUT = 60

function UnitCollector:New(...)
	local object = ZO_Object.New(self)
	object:Initialize(...)
	return object
end

function UnitCollector:Initialize(database)
	self.database = database
	self.updateList = {}

	RegisterForEvent(EVENT_UNIT_CREATED, function(_, unitTag)
		if(GetUnitDisplayName(unitTag) == "") then return end -- there seems to be a bug that makes data unavailable when inviting members
		self:UpdateFromTargetIfNecessary(unitTag)
	end)
	local targetUnitFrame = ZO_UnitFrames_GetUnitFrame(TARGET_UNIT_TAG)
	ZO_PreHook(targetUnitFrame.nameLabel, 'SetText', function() self:UpdateFromTargetIfNecessary(TARGET_UNIT_TAG) end)
end

function UnitCollector:UpdateFromTargetIfNecessary(unitTag)
	if(DoesUnitExist(unitTag) and IsUnitPlayer(unitTag)) then
		local name = GetUnitName(unitTag)
		local now = GetTimeStamp()
		local updateList = self.updateList
		if(#name > 0 and (not updateList[name] or updateList[name] < now - UPDATE_FROM_TARGET_TIMEOUT)) then
			updateList[name] = now
			self:UpdateFromTarget(unitTag)
		end
	end
end

function UnitCollector:UpdateFromTarget(unitTag)
	local db = self.database
	local displayName = GetUnitDisplayName(unitTag)
	local player = db:GetPlayer(displayName)
	player:UpdateChampionPoints(GetUnitChampionPoints(unitTag))
	player:UpdateStatus(IsUnitOnline(unitTag) and PLAYER_STATUS_ONLINE or PLAYER_STATUS_OFFLINE, 0) -- TODO: give update reason so we don't update more accurate sources (guild, friendlist)
	player:Save()

	local character = db:GetCharacter(GetUnitName(unitTag))
	character:SetRace(GetUnitRaceId(unitTag))
	character:SetGender(GetUnitGender(unitTag))
	character:SetClass(GetUnitClassId(unitTag))
	character:SetAlliance(GetUnitAlliance(unitTag))
	character:SetAvARank(GetUnitAvARank(unitTag))
	character:UpdateLevel(GetUnitLevel(unitTag))
	character:UpdateZone(GetUnitZone(unitTag))
	if(not character:GetPlayer()) then
		character:SetPlayer(displayName)
	end
	if(unitTag == TARGET_UNIT_TAG) then
		character:UpdateLastMet()
	else -- in group
		character:UpdateLastSeen()
		character:UpdateTimesGrouped()
	end
	character:Save()
end

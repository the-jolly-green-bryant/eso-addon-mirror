
PinKiller = PinKiller or {}

PinKiller.compassPins = {
	MAP_PIN_TYPE_QUEST_OFFER,
	--MAP_PIN_TYPE_TRACKED_QUEST_CONDITION,
	--MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION,
	--MAP_PIN_TYPE_TRACKED_QUEST_ENDING,
	MAP_PIN_TYPE_QUEST_CONDITION,
	MAP_PIN_TYPE_QUEST_OPTIONAL_CONDITION,
	MAP_PIN_TYPE_QUEST_ENDING,
	MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION,
	MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION,
	MAP_PIN_TYPE_ASSISTED_QUEST_ENDING,
	
	MAP_PIN_TYPE_QUEST_OFFER_ZONE_STORY,
	MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_CONDITION,
	MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_OPTIONAL_CONDITION,
	MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_ENDING,
	MAP_PIN_TYPE_QUEST_ZONE_STORY_CONDITION,
	MAP_PIN_TYPE_QUEST_ZONE_STORY_OPTIONAL_CONDITION,
	MAP_PIN_TYPE_QUEST_ZONE_STORY_ENDING,
	
	MAP_PIN_TYPE_QUEST_OFFER_REPEATABLE,
	--MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION,
	--MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION,
	--MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_ENDING,
	MAP_PIN_TYPE_QUEST_REPEATABLE_CONDITION,
	MAP_PIN_TYPE_QUEST_REPEATABLE_OPTIONAL_CONDITION,
	MAP_PIN_TYPE_QUEST_REPEATABLE_ENDING,
	MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION,
	MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION,
	MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING,
	
	MAP_PIN_TYPE_POI_SEEN,
	MAP_PIN_TYPE_POI_COMPLETE,
	MAP_PIN_TYPE_TIMELY_ESCAPE_NPC,
--	MAP_PIN_TYPE_DARK_BROTHERHOOD_TARGET,
}

function PinKiller:InitializeCompassPins()
	-- save original settings
	self.originalAlphaCoefficients = {}
	self.originalMinVisibleAlpha = {}
	
	for _, pinType in pairs(self.compassPins) do
		--self.originalAlphaCoefficients[pinType] = {COMPASS.container:GetAlphaDropoffBehavior(pinType)}
		--self.originalMinVisibleAlpha[pinType] = COMPASS.container:GetMinVisibleAlpha(pinType)
	end
	
	self.originalAreaAnimation = COMPASS.PlayAreaPinOutAnimation
	
	for _, pinType in pairs(self.compassPins) do
		PinKiller:RefreshCompassPinSettings(pinType)
	end
	self:RefreshAreaAnimation()
end
	
function PinKiller:RefreshCompassPinSettings(pinType)

	local isEnabled = self:IsCompassPinTypeEnabled(pinType)
	if isEnabled then
		COMPASS.container:SetAlphaDropoffBehavior(pinType, 1, 0.75, 0, 85)
		--COMPASS.container:SetMinVisibleAlpha(pinType, PinKiller.originalMinVisibleAlpha[pinType]) 
	else
		COMPASS.container:SetAlphaDropoffBehavior(pinType, 1/99, 1/99, 0, 1)
		--COMPASS.container:SetMinVisibleAlpha(pinType, 2)
	end
	
end

local origFunction = COMPASS.container.IsCenterOveredPinSuppressed
function COMPASS.container:IsCenterOveredPinSuppressed(pinIndex, ...)
	if PinKiller:IsCompassPinTypeEnabled(self:GetCenterOveredPinType(pinIndex)) then
		return origFunction(self, pinIndex, ...)
	end
	return true
end

function PinKiller:RefreshAreaAnimation()
	local isEnabled = self:IsAreaPinAnimationEnabled()
	if isEnabled then
		COMPASS.PlayAreaPinOutAnimation = self.originalAreaAnimation
	else
		COMPASS.PlayAreaPinOutAnimation = COMPASS.StopAreaPinOutAnimation
	end
	COMPASS:PerformFullAreaQuestUpdate()
end


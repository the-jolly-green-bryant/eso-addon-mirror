-------------------------------------------------------------------------------
-- Leadz
-------------------------------------------------------------------------------
Leadz = Leadz or {}

Leadz.name = "Leadz"
Leadz.version = "1.1.7"
Leadz.displayName = "|c9900FFLeadz|r"
Leadz.author = "|c00a313Teebow Ganx|r"
Leadz.website = "https://www.youtube.com/channel/UCqE9Vi36WzTJBBbo9-G40bg"
Leadz.donation = "https://www.youtube.com/channel/UCqE9Vi36WzTJBBbo9-G40bg"

local function ActiveLeadSectionSortComparisonWithLeadTimes(leftAntiquityData, rightAntiquityData)

	-- We want all expiring antiquities at the top of the list
	local leftLeadTime = leftAntiquityData:GetLeadTimeRemainingS()
	if leftLeadTime == 0 then leftLeadTime = 9999999 end -- No lead time means no lead, so set to max lead time
	local rightLeadTime = rightAntiquityData:GetLeadTimeRemainingS()
	if rightLeadTime == 0 then rightLeadTime = 9999999 end -- No lead time means no lead, so set to max lead time
	if leftLeadTime ~= rightLeadTime then
		return leftLeadTime < rightLeadTime
	end

	-- If not expiring, sort by zone name
	local leftZoneName = GetZoneNameById(leftAntiquityData:GetZoneId())
	local rightZoneName = GetZoneNameById(rightAntiquityData:GetZoneId())
	if leftZoneName ~= rightZoneName then
		return leftZoneName < rightZoneName
	end

	-- In the same zone, sort by quality
	local leftQuality = leftAntiquityData:GetQuality()
	local rightQuality = rightAntiquityData:GetQuality()
	if leftQuality ~= rightQuality then
		return leftQuality < rightQuality
	end

	-- Same zone, same quality? Sort by name
	return leftAntiquityData:CompareNameTo(rightAntiquityData)
end

local function MatchAllAntiquitiesWithHasLead(antiquityData)
    return antiquityData:IsInProgress() or antiquityData:HasLead()
end

local function InstallNewSortFunction()

	if not ANTIQUITY_MANAGER or not ANTIQUITY_MANAGER.antiquitySectionData then -- delay if no antiquities data list yet
		zo_callLater( function() InstallNewSortFunction() end, 3000)
		return
	end

	for k, section in pairs(ANTIQUITY_MANAGER.antiquitySectionData) do
		if section.sectionType == ZO_ANTIQUITY_SECTION_TYPE.ACTIVE_LEAD then
			section.sortFunction = ActiveLeadSectionSortComparisonWithLeadTimes
			table.sort(section.list, section.sortFunction)
		end
	end

	ZO_SCRYABLE_ANTIQUITY_ALL_LEADS_SUBCATEGORY_DATA:SetAntiquityFilterFunction(MatchAllAntiquitiesWithHasLead)

end

function Leadz.EVENT_PLAYER_ACTIVATED(eventCode, isInitial)
	if isInitial == true then
		EVENT_MANAGER:UnregisterForEvent(Leadz.name, EVENT_PLAYER_ACTIVATED)
	end
end

function Leadz.EVENT_ADD_ON_LOADED(eventCode, addOnName)

	if(addOnName ~= Leadz.name) then return end

	-- All we do is replace the sort function of the active leads section to ours, which puts expiring leads at the top
	InstallNewSortFunction()
	
	-- Be a good citizen and unregister for load events now
	EVENT_MANAGER:UnregisterForEvent(Leadz.name, EVENT_ADD_ON_LOADED)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- A D D O N   E N T R Y   P O I N T
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- It all starts here actually, by registering our event handler to load our Addon
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

EVENT_MANAGER:RegisterForEvent(Leadz.name, EVENT_ADD_ON_LOADED, Leadz.EVENT_ADD_ON_LOADED)
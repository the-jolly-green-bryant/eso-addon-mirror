local RegisterForEvent = sidWarTools.RegisterForEvent
local UnregisterForEvent = sidWarTools.UnregisterForEvent
local L = sidWarTools.Localization

local function GetColorizedString(text, alliance)
	return GetAllianceColor(alliance):Colorize(text)
end

local function GetFormattedSiegeWeaponCount(keepId, battlegroundContext, alliance)
	local numSieges = GetNumSieges(keepId, battlegroundContext, alliance)
	if(numSieges > 0) then
		local allianceName = GetColorizedString(GetString("SI_ALLIANCE", alliance), alliance)
		return zo_strformat(L["KEEP_STATUS_SIEGE_WEAPON_COUNT"], numSieges, allianceName)
	end
end

local function Notify(formatStringKey, ...)
	d(zo_strformat(L[formatStringKey], ...))
end

local function InitializeKeepNotifications()
	local playerAlliance = GetUnitAlliance("player")

	local previousOwner
	local function GetPreviousOwner(keepId)
		if(not previousOwner) then
			previousOwner = {}
			for i = 1, GetNumKeeps() do
				local id, battlegroundContext = GetKeepKeysByIndex(i)
				previousOwner[id] = GetKeepAlliance(id, battlegroundContext)
			end
		end
		return previousOwner[keepId]
	end

	RegisterForEvent(EVENT_KEEP_UNDER_ATTACK_CHANGED, function(eventCode, keepId, battlegroundContext, underAttack)
		local oldOwner = GetPreviousOwner(keepId)
		local newOwner = GetKeepAlliance(keepId, battlegroundContext)
		local keepName = GetColorizedString(GetKeepName(keepId), oldOwner)

		if(underAttack) then
			local siegeCount = {}
			siegeCount[#siegeCount + 1] = GetFormattedSiegeWeaponCount(keepId, battlegroundContext, ALLIANCE_ALDMERI_DOMINION)
			siegeCount[#siegeCount + 1] = GetFormattedSiegeWeaponCount(keepId, battlegroundContext, ALLIANCE_DAGGERFALL_COVENANT)
			siegeCount[#siegeCount + 1] = GetFormattedSiegeWeaponCount(keepId, battlegroundContext, ALLIANCE_EBONHEART_PACT)

			if(#siegeCount > 0) then
				Notify("KEEP_STATUS_UNDER_ATTACK_WITH_SIEGES", keepName, table.concat(siegeCount, ", "))
			else
				Notify("KEEP_STATUS_UNDER_ATTACK", keepName)
			end
		else
			if(oldOwner == playerAlliance) then
				if(newOwner == oldOwner) then
					Notify("KEEP_STATUS_DEFENDED", keepName)
				else
					Notify("KEEP_STATUS_LOST", keepName, GetColorizedString(GetString("SI_ALLIANCE", newOwner), newOwner))
				end
			else
				if(newOwner == playerAlliance) then
					Notify("KEEP_STATUS_CONQUERED", keepName)
				elseif(newOwner == oldOwner) then
					Notify("KEEP_STATUS_DEFENDED_BY", keepName, GetColorizedString(GetString("SI_ALLIANCE", newOwner), newOwner))
				else
					Notify("KEEP_STATUS_LOST_TO", keepName, GetColorizedString(GetString("SI_ALLIANCE", newOwner), newOwner))
				end
			end
		end
		previousOwner[keepId] = newOwner
	end)
end

local function IsCampaignStateInitialized()
	return GetNumKeeps() > 0
end

local function Initialize(saveData)
	if(saveData.keepStatusNotifications) then
		if(IsCampaignStateInitialized()) then
			InitializeKeepNotifications()
		else
			local eventHandle = ""
			eventHandle = RegisterForEvent(EVENT_CAMPAIGN_STATE_INITIALIZED, function()
				UnregisterForEvent(EVENT_CAMPAIGN_STATE_INITIALIZED, eventHandle)
				InitializeKeepNotifications()
			end)
		end
	end
end

sidWarTools.InitializeKeepNotifications = Initialize

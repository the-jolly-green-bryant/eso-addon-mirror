local CompanionFix = {
	name = "CompanionFix",
	author = "@sinnereso",
	version = "2026.03.10",
	logo = "|c6666FF[CompanionFix]|r",
	errSnd = "PlayerAction_NotEnoughMoney",
}
function CompanionFix.AddOnLoaded(eventCode, addOnName)
	if addOnName ~= "CompanionFix" then return end
	EVENT_MANAGER:UnregisterForEvent("CompanionFix", EVENT_ADD_ON_LOADED)
	CompanionFix.Initialize()
end
function CompanionFix.Initialize()
	EVENT_MANAGER:RegisterForEvent("CompanionFix", EVENT_COMPANION_SUMMON_RESULT, CompanionFix.SummonCompanion)
end
function CompanionFix.SummonCompanion(eventID, summonResult, companionId)
	--df(tostring(summonResult) .. " - " .. tostring(companionId))
	if summonResult ~= 1 or IsUnitDeadOrReincarnating("player") then return end
	local companionName = zo_strformat("<<1>>", GetCompanionName(companionId))--<< Strip Genders
	zo_callLater(function() PlaySound(CompanionFix.errSnd) df(CompanionFix.logo .. " Summoning " .. tostring(companionName)) UseCollectible(GetCompanionCollectibleId(companionId)) end, 1500)
end
EVENT_MANAGER:RegisterForEvent("CompanionFix", EVENT_ADD_ON_LOADED, CompanionFix.AddOnLoaded)
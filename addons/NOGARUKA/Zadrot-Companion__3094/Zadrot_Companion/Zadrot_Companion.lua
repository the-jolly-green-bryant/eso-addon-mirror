local Name = "Zadrot_Companion"
Zadrot_Companion_Saved = {["Enabled"] = true, ["Companion"] = 9245}
local assistant = false

local function OnPlayerActivated(_, arg)
	if HasPendingCompanion() then
		Zadrot_Companion_Saved["Companion"] = GetCompanionCollectibleId(GetPendingCompanionDefId())
	elseif HasActiveCompanion() then
		Zadrot_Companion_Saved["Companion"] = GetCompanionCollectibleId(GetActiveCompanionDefId())
	elseif GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT) > 0 then
		assistant = true
	else
		zo_callLater(function()
			if Zadrot_Companion_Saved["Enabled"]
			and not IsCollectibleBlocked(Zadrot_Companion_Saved["Companion"])
			and IsCollectibleUsable(Zadrot_Companion_Saved["Companion"])
			then
				assistant = false
				--d("Summoning " .. GetCollectibleLink(Zadrot_Companion_Saved["Companion"]))
				UseCollectible(Zadrot_Companion_Saved["Companion"])
			end
		end, 1000 + GetCollectibleCooldownAndDuration(Zadrot_Companion_Saved["Companion"]))
	end
end
EVENT_MANAGER:RegisterForEvent(Name .. "Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

EVENT_MANAGER:RegisterForEvent(
	Name .. "CompanionActivated",
	EVENT_COMPANION_ACTIVATED,
	function(_, arg)
		Zadrot_Companion_Saved["Companion"] = GetCompanionCollectibleId(arg)
	end
)

EVENT_MANAGER:RegisterForEvent(
	Name .. "UnitCreated",
	EVENT_UNIT_CREATED,
	function(_, arg)
		if GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT) > 0
		then assistant = true end
	end
)

EVENT_MANAGER:RegisterForEvent(
	Name .. "UnitDestroyed",
	EVENT_UNIT_DESTROYED,
	function(_, arg)
		if assistant == true then OnPlayerActivated() end
	end
)

EVENT_MANAGER:RegisterForEvent(
	Name .. "PlayerCombatState",
	EVENT_PLAYER_COMBAT_STATE,
	function(_, arg)
		if not arg then OnPlayerActivated() end
	end
)

function Zadrot_SummonTrader()
	if IsCollectibleUnlocked(301) then
		UseCollectible(301)
	elseif IsCollectibleUnlocked(6378) then
		UseCollectible(6378)
	elseif IsCollectibleUnlocked(8995) then
		UseCollectible(8995)
	end
end

function Zadrot_SummonBanker()
	if IsCollectibleUnlocked(267) then
		UseCollectible(267)
	elseif IsCollectibleUnlocked(6376) then
		UseCollectible(6376)
	elseif IsCollectibleUnlocked(8994) then
		UseCollectible(8994)
	end
end

local function ZadrotSC(args)
	if Zadrot_Companion_Saved["Enabled"] then
		d("Zadrot Companion DISABLED")
		Zadrot_Companion_Saved["Enabled"] = false
	else
		d("Zadrot Companion ENABLED")
		Zadrot_Companion_Saved["Enabled"] = true
		OnPlayerActivated()
	end
end
SLASH_COMMANDS["/zc"] = ZadrotSC

ZO_CreateStringId("SI_BINDING_NAME_Trader", "Trader")
ZO_CreateStringId("SI_BINDING_NAME_Banker", "Banker")
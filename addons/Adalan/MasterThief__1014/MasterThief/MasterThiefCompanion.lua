--[[
MasterThief Companion Rapport Protection Module
--]]

if not MasterThief then
	MasterThief = {}
end

local MT = MasterThief

----------------------------------------
-- COMPANION DEFINITIONS
----------------------------------------

--[[
Flag reference — all flags are optional; omit rather than set to false.
  warnOnStealth     (string) : advisory shown once on entering stealth.
  warnOnBountyGain  (bool)   : warn when bounty increases; chance to dismiss before arrest.
  warnOnArrested    (bool)   : warn on arrest dialogue; uses arrestMessageKey for advice.
  arrestMessageKey  (string) : companion-specific advice at arrest.
  warnOnPayBounty   (bool)   : warn when player opens the pay-bounty guard interaction.
  dislikesContainer (bool)   : block/warn when looting a stolen container.
  dislikesTrove     (bool)   : block/warn when looting a Thieves Trove.
  dislikesPickpocket(bool)   : block/warn on any pickpocket attempt.
  dislikesBladeOfWoe(bool)   : block/warn when BoW synergy appears; warn after BoW kill.
  dislikesFencing   (bool)   : block/warn when the fence window opens.
  blockOutlawRefuge (bool)   : block entry to Outlaw Refuges / Thieves Den.
  blockDBSanctuary  (bool)   : auto-dismiss companion on entry to the DB Sanctuary.
  blockEdicts       (bool)   : reserved — UseItem is protected; no reliable intercept yet.
--]]
local COMPANION_DATA = {
	[1] = {  -- Bastian Hallix
		-- Dislikes: stealing (containers, corpses), pickpocketing, getting caught,
		--           fleeing guards, paying bounty, murder / Blade of Woe.
		name               = "Bastian",
		warnOnStealth      = "MT_COMP_STEALTH_BASTIAN",
		warnOnBountyGain   = true,
		dislikesContainer  = true,
		warnOnArrested     = true,
		arrestMessageKey   = "MT_COMP_ARRESTED_BASTIAN",
		dislikesPickpocket = true,
		dislikesBladeOfWoe = true,
	},
	[2] = {  -- Mirri Elendis
		-- Dislikes: murder / Blade of Woe, entering the Dark Brotherhood Sanctuary.
		name               = "Mirri",
		dislikesBladeOfWoe = true,
		blockDBSanctuary   = true,
	},
	[5] = {  -- Ember
		-- Dislikes: getting caught committing crime or trespassing, paying a guard your bounty.
		name             = "Ember",
		warnOnBountyGain = true,
		warnOnPayBounty  = true,
		warnOnArrested   = true,
		arrestMessageKey = "MT_COMP_ARRESTED_PAYBOUNTY",
	},
	[6] = {  -- Isobel Veloise
		-- Dislikes: stealing (containers, corpses), looting Thieves Troves,
		--           entering Outlaw Refuges and the Dark Brotherhood Sanctuary,
		--           murder / Blade of Woe.
		name               = "Isobel",
		warnOnStealth      = "MT_COMP_STEALTH_ISOBEL",
		dislikesTrove      = true,
		dislikesContainer  = true,
		blockOutlawRefuge  = true,
		blockDBSanctuary   = true,
		dislikesBladeOfWoe = true,
	},
	[8] = {  -- Sharp-as-Night
		-- Dislikes: paying a guard your bounty, pickpocketing a beggar, laborer, or fisher.
	
		name             = "Sharp",
		warnOnStealth    = "MT_COMP_STEALTH_SHARP",
		warnOnBountyGain = true,
		warnOnPayBounty  = true,
		warnOnArrested   = true,
		arrestMessageKey = "MT_COMP_ARRESTED_PAYBOUNTY",
    },
	[12] = {  -- Tanlorin
		-- Dislikes: stealing children's toys or dolls, murder / Blade of Woe.
		name               = "Tanlorin",
		warnOnStealth      = "MT_COMP_STEALTH_TANLORIN",
		dislikesBladeOfWoe = true,
	},
	[13] = {  -- Zerith-var
		-- Dislikes: stealing medicinal, religious, or sentimental items, using edicts, fencing stolen goods, paying a bounty.
		name             = "Zerith",
		warnOnStealth    = "MT_COMP_STEALTH_ZERITH",
		warnOnBountyGain = true,
		dislikesFencing  = true,
		blockEdicts      = true,
		warnOnArrested   = true,
		arrestMessageKey = "MT_COMP_ARRESTED_PAYBOUNTY",
		warnOnPayBounty  = true,
		dislikesBladeOfWoe = true,
	},
}

----------------------------------------
-- HELPERS
----------------------------------------

-- Returns the COMPANION_DATA entry for the active companion, or nil if:
--   - no companion is currently active
--   - the active companion has no entry in COMPANION_DATA
local function GetActiveCompanionData()
	if not MT.SavedVarsOptions then return nil end
	if not HasActiveCompanion or not HasActiveCompanion() then return nil end

	local id = GetActiveCompanionDefId()
	if not id or id == 0 then return nil end

	return COMPANION_DATA[id]
end

-- Displays an immediate red block message (type 0 = no queue delay).
local function CompanionBlock(companionName, message)
	MT:ShowMessage("|cFF4444" .. companionName .. " " .. message .. "|r", 0)
end

-- Displays a companion-attributed amber warning via the existing MT message system.
local function CompanionWarn(companionName, message)
	MT:ShowMessage("|cFFAA00" .. companionName .. " " .. message .. "|r", 2)
end

-- Returns true if blocking is enabled in settings.
-- Defaults to true if the key doesn't exist yet in saved variables.
local function ShouldBlock()
	if not MT.SavedVarsOptions then return false end
	local v = MT.SavedVarsOptions.CompanionBlockActions
	return v == nil or v == true
end

-- Returns true if warnings are enabled in settings.
-- Defaults to true if the key doesn't exist yet in saved variables.
local function ShouldWarn()
	if not MT.SavedVarsOptions then return false end
	local v = MT.SavedVarsOptions.CompanionWarnActions
	return v == nil or v == true
end

-- Resolves a string ID name stored in COMPANION_DATA to its localized value.
local function GetCompanionString(name)
	if not name then return "" end
	return GetString(_G[name]) or ""
end

----------------------------------------
-- CompanionOnEnterStealth
----------------------------------------

-- Called from SetStealMode() when iStealthState == 3 (entering sneak).
-- Fires a one-time advisory warning for companions with item-specific dislikes
function MT:CompanionOnEnterStealth()
	local data = GetActiveCompanionData()
	if not data or not data.warnOnStealth then return end
	if not ShouldWarn() then return end

	CompanionWarn(data.name, GetCompanionString(data.warnOnStealth))
end

----------------------------------------
-- CompanionOnLeaveStealth
----------------------------------------

-- Called from SetStealMode() when iStealthState == 0 (leaving sneak).
function MT:CompanionOnLeaveStealth()
end

----------------------------------------
-- CompanionOnPickpocket
----------------------------------------

-- Called from the StartInteraction hook in SetEvents() on any pickpocket attempt.
-- Returns true to block the action when blocking is enabled.
function MT:CompanionOnPickpocket()
	local data = GetActiveCompanionData()
	if not data or not data.dislikesPickpocket then return end

	if ShouldBlock() then
		CompanionBlock(data.name, GetString(MT_COMP_PICKPOCKET_BLOCK))
		return true
	elseif ShouldWarn() then
		CompanionWarn(data.name, GetString(MT_COMP_PICKPOCKET_WARN))
	end
end

----------------------------------------
-- CompanionOnTroveOrContainer
----------------------------------------

-- Called from the StartInteraction hook in SetEvents() for troves and stolen containers.
-- isTrove: true if the target is a Thieves Trove, false if a stolen container.
-- Returns true to block the action when blocking is enabled.
function MT:CompanionOnTroveOrContainer(isTrove)
	local data = GetActiveCompanionData()
	if not data then return end

	if isTrove and data.dislikesTrove then
		if ShouldBlock() then
			CompanionBlock(data.name, GetString(MT_COMP_TROVE_BLOCK))
			return true
		elseif ShouldWarn() then
			CompanionWarn(data.name, GetString(MT_COMP_TROVE_WARN))
		end
	elseif not isTrove and data.dislikesContainer then
		if ShouldBlock() then
			CompanionBlock(data.name, GetString(MT_COMP_CONTAINER_BLOCK))
			return true
		elseif ShouldWarn() then
			CompanionWarn(data.name, GetString(MT_COMP_CONTAINER_WARN))
		end
	end
end

----------------------------------------
-- CompanionOnCorpse
----------------------------------------

-- Called from the StartInteraction hook in SetEvents() when the target is a corpse.
-- Warn-only — corpse looting cannot be reliably blocked via the interaction hook.
function MT:CompanionOnCorpse()
	local data = GetActiveCompanionData()
	if not data or not data.dislikesContainer then return end
	if not ShouldWarn() then return end

	CompanionWarn(data.name, GetString(MT_COMP_CORPSE_WARN))
end

----------------------------------------
-- CompanionOnBountyGain
----------------------------------------

-- Called from BountyPayoff() in MasterThiefJustice.lua when bounty increases.
function MT:CompanionOnBountyGain(newBounty, oldBounty)
	local data = GetActiveCompanionData()
	if not data or not data.warnOnBountyGain then return end
	if not ShouldWarn() then return end

	CompanionWarn(data.name, GetString(MT_COMP_BOUNTY_WARN))
end

----------------------------------------
-- CompanionOnBladeOfWoeAvailable
----------------------------------------

-- Called from the SYNERGY.OnSynergyAbilityChanged hook when BoW synergy appears.
-- Returns true to suppress the synergy prompt when blocking is enabled.
-- When warn-only, shows a message but allows the prompt to appear.
function MT:CompanionOnBladeOfWoeAvailable()
	local data = GetActiveCompanionData()
	if not data or not data.dislikesBladeOfWoe then return end

	if ShouldBlock() then
		CompanionBlock(data.name, GetString(MT_COMP_BOW_BLOCK))
		return true
	elseif ShouldWarn() then
		CompanionWarn(data.name, GetString(MT_COMP_BOW_AVAILABLE_WARN))
	end
end

----------------------------------------
-- CompanionOnBladeOfWoe
----------------------------------------

-- Called from the BoW combat event (ability 76325) after the kill lands.
-- Secondary notification confirming rapport has already decreased.
function MT:CompanionOnBladeOfWoe()
	local data = GetActiveCompanionData()
	if not data or not data.dislikesBladeOfWoe then return end
	if not ShouldWarn() then return end

	CompanionWarn(data.name, GetString(MT_COMP_BOW_USED_WARN))
end

----------------------------------------
-- CompanionOnOutlawRefuge
----------------------------------------

-- Called from StartInteraction when the target is an Outlaw Refuge or Thieves Den.
-- Returns true to block entry when blocking is enabled.
function MT:CompanionOnOutlawRefuge()
	local data = GetActiveCompanionData()
	if not data or not data.blockOutlawRefuge then return end

	if ShouldBlock() then
		CompanionBlock(data.name, GetString(MT_COMP_REFUGE_BLOCK))
		return true
	elseif ShouldWarn() then
		CompanionWarn(data.name, GetString(MT_COMP_REFUGE_WARN))
	end
end

----------------------------------------
-- CompanionOnZoneChange
----------------------------------------

-- zoneId and zoneName are always 0/empty for subzone transitions, so detection relies
-- solely on an exact match of subZoneName == "Dark Brotherhood Sanctuary".
function MT:CompanionOnZoneChange(zoneName, subZoneName, zoneId)
	-- zoneId is always 0 and zoneName is always empty for subzone transitions,
	-- so the only reliable signal is subZoneName. Match the exact string to avoid
	-- false positives from "Seaside Sanctuary", "Sanctuary Wayshrine", etc.
	if not subZoneName or subZoneName:lower() ~= "dark brotherhood sanctuary" then return end

	local data = GetActiveCompanionData()
	if not data or not data.blockDBSanctuary then return end

	-- Dismiss the active companion to prevent rapport loss on entry
	local companionId = GetActiveCompanionDefId()
	if companionId and companionId ~= 0 then
		local collectibleId = GetCompanionCollectibleId(companionId)
		if collectibleId and collectibleId ~= 0 then
			UseCollectible(collectibleId)
			CompanionBlock(data.name, GetString(MT_COMP_DB_DISMISSED))
			return
		end
	end

	-- Companion wasn't active, just warn
	if ShouldWarn() then
		CompanionWarn(data.name, GetString(MT_COMP_DB_WARN))
	end
end

----------------------------------------
-- CompanionOnPayBounty
----------------------------------------

-- Called from StartInteraction when INTERACTION_PAY_BOUNTY fires.
function MT:CompanionOnPayBounty()
	local data = GetActiveCompanionData()
	if not data or not data.warnOnPayBounty then return end
	if not ShouldWarn() then return end

	CompanionWarn(data.name, GetString(MT_COMP_PAYBOUNTY_WARN))
end

----------------------------------------
-- CompanionOnArrested
----------------------------------------

-- Called from EVENT_JUSTICE_BEING_ARRESTED.
-- Fires when the arrest dialogue opens — the player can still flee, ask for clemency,
-- or pay the fine at this point. Warn only — can't block arrest.
function MT:CompanionOnArrested()
	local data = GetActiveCompanionData()
	if not data or not data.warnOnArrested then return end
	if not ShouldWarn() then return end

	local key = data.arrestMessageKey or "MT_COMP_ARRESTED_GENERIC"
	CompanionWarn(data.name, GetCompanionString(key))
end

----------------------------------------
-- CompanionOnFenceOpened
----------------------------------------

-- Called from MT.FenceOpened() in MasterThiefJustice.lua when the fence window opens.
-- Zerith dislikes fencing stolen goods. Returns true if blocked (caller bails out).
-- Uses ShowBaseScene() to close the fence rather than Hide("fence") — the scene name
-- varies by input mode and ShowBaseScene() is reliable in all cases.
function MT:CompanionOnFenceOpened()
	local data = GetActiveCompanionData()
	if not data or not data.dislikesFencing then return end

	if ShouldBlock() then
		CompanionBlock(data.name, GetString(MT_COMP_FENCE_BLOCK))
		zo_callLater(function() SCENE_MANAGER:ShowBaseScene() end, 100)
		return true
	elseif ShouldWarn() then
		CompanionWarn(data.name, GetString(MT_COMP_FENCE_WARN))
	end
end

----------------------------------------
-- CompanionOnEdictUse
----------------------------------------

-- Called when a Counterfeit Pardon or Leniency Edict is used.
-- Note: UseItem is a protected function — ZO_PreHook cannot intercept it reliably.
-- This function is retained for any future intercept point (e.g. keybind hook).
-- Zerith dislikes using edicts.
function MT:CompanionOnEdictUse()
	local data = GetActiveCompanionData()
	if not data or not data.blockEdicts then return end

	if ShouldBlock() then
		CompanionBlock(data.name, GetString(MT_COMP_EDICT_BLOCK))
		return true
	elseif ShouldWarn() then
		CompanionWarn(data.name, GetString(MT_COMP_EDICT_WARN))
	end
end

----------------------------------------
-- COMPANION LOCKPICK PERK
----------------------------------------

-- EVENT_LOCKPICK_BREAK_PREVENTED fires when the companion perk suppresses
-- a lockpick break (e.g. Tanlorin's Finesse). Active companion defId will
-- be 0 when triggered via the unlocked collectible with no companion summoned.
function MT:RegisterCompanionPerkEvents()
    EVENT_MANAGER:RegisterForEvent(MT.name .. "_LockpickBreakPrevented",
        EVENT_LOCKPICK_BREAK_PREVENTED, function()
            MT:TrackLockpickBreakPrevented()
        end)
end
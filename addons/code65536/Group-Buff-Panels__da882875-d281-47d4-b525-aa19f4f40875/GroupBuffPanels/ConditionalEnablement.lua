local LCA = LibCombatAlerts
local GBP = GroupBuffPanels


--[[ Registering your own Conditional Enablement -------------------------------
GBP.RegisterConditionalEnablement( abilityId, settingsText, checkFunction, overrideExisting )
* abilityId: effect that the Conditional Enablement will apply to
* settingsText: either a string or a string ID to display in the settings panel
* checkFunction: function returning true or false
* overrideExisting: external addons can set this to true to replace stock CEs

Call GBP.RefreshEnablementStates when an event necessitates a condition recheck
]]


--------------------------------------------------------------------------------
-- Demonstration of conditional enablement: item sets and abilities
--------------------------------------------------------------------------------

function GBP.RegisterStockConditionalEnablements( )
	local name = "GBP_StockConditionalEnablements"

	-- Item Sets ---------------------------------------------------------------

	-- Major Slayer
	GBP.RegisterConditionalEnablement(93109, SI_GBP_SETTING_CE_ITEMSET, function( )
		return GBP.GetItemSetEquippedCount(331) >= 3 -- War Machine
			or GBP.GetItemSetEquippedCount(332) >= 3 -- Master Architect
			or GBP.GetItemSetEquippedCount(496) >= 3 -- Roaring Opportunist
	end)

	-- Major Aegis
	GBP.RegisterConditionalEnablement(93123, SI_GBP_SETTING_CE_ITEMSET, function( )
		return GBP.GetItemSetEquippedCount(330) >= 3 -- Automated Defense
			or GBP.GetItemSetEquippedCount(333) >= 3 -- Inventor's Guard
			or GBP.GetItemSetEquippedCount(494) >= 3 -- Vrol's Command
			or GBP.GetItemSetEquippedCount(703) >= 3 -- Test of Resolve
	end)

	-- Major Courage
	GBP.RegisterConditionalEnablement(109966, SI_GBP_SETTING_CE_ABILITY_ITEMSET, function( )
		return GBP.GetItemSetEquippedCount(185) >= 3 -- Spell Power Cure
			or GBP.GetItemSetEquippedCount(391) >= 3 -- Olorime
			or GBP.DoesPlayerHaveSkillSlotted(39113) -- Ferocious Roar
	end)

	-- Powerful Assault
	GBP.RegisterConditionalEnablement(61771, SI_GBP_SETTING_CE_ITEMSET, function( )
		return GBP.GetItemSetEquippedCount(180) >= 3
	end)

	-- Aura of Pride (Spaulder of Ruin)
	GBP.RegisterConditionalEnablement(163401, SI_GBP_SETTING_CE_ITEMSET, function( )
		return GBP.GetItemSetEquippedCount(627) >= 1
	end)

	-- Pillager's Profit
	GBP.RegisterConditionalEnablement(172056, SI_GBP_SETTING_CE_ITEMSET, function( )
		return GBP.GetItemSetEquippedCount(649) >= 3
	end)

	-- Arkay's Charity
	GBP.RegisterConditionalEnablement(234295, SI_GBP_SETTING_CE_ITEMSET, function( )
		return GBP.GetItemSetEquippedCount(802) >= 3
	end)

	-- Abilities ---------------------------------------------------------------

	-- Major Resolve
	GBP.RegisterConditionalEnablement(61694, zo_strformat(SI_GBP_SETTING_CE_ABILITY, LCA.GetAbilityName(86122)), function( )
		return GBP.DoesPlayerHaveSkillSlotted({ 86122, 86126, 86130 })
	end)

	-- Radiating Regeneration
	GBP.RegisterConditionalEnablement(40079, zo_strformat(SI_GBP_SETTING_CE_ABILITY, LCA.GetAbilityName(40079)), function( )
		return GBP.DoesPlayerHaveSkillSlotted(40079)
	end)

	-- Echoing Vigor
	GBP.RegisterConditionalEnablement(61506, zo_strformat(SI_GBP_SETTING_CE_ABILITY, LCA.GetAbilityName(61505)), function( )
		return GBP.DoesPlayerHaveSkillSlotted(61505)
	end)

	-- Aggressive Horn
	GBP.RegisterConditionalEnablement(40224, zo_strformat(SI_GBP_SETTING_CE_ABILITY, LCA.GetAbilityName(40223)), function( )
		return GBP.DoesPlayerHaveSkillSlotted(40223)
	end)

	-- Standard of Might
	GBP.RegisterConditionalEnablement(32948, zo_strformat(SI_GBP_SETTING_CE_ABILITY, LCA.GetAbilityName(32947)), function( )
		return GBP.DoesPlayerHaveSkillSlotted({ 32947, 28988 })
	end)

	-- Update Monitoring -------------------------------------------------------

	-- Handle updates, which we delay and coalesce so that someone swapping gear
	-- via addon fires one update when the dust has cleared instead of spamming
	local refresh = function( )
		EVENT_MANAGER:UnregisterForUpdate(name)
		EVENT_MANAGER:RegisterForUpdate(name, 1000, GBP.RefreshEnablementStates, true)
	end
	EVENT_MANAGER:RegisterForEvent(name, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, function( _, result )
		if (result == ARMORY_BUILD_RESTORE_RESULT_SUCCESS) then
			refresh()
		end
	end)
	EVENT_MANAGER:RegisterForEvent(name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, refresh)
	EVENT_MANAGER:AddFilterForEvent(name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
	EVENT_MANAGER:AddFilterForEvent(name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
	EVENT_MANAGER:RegisterForEvent(name, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, refresh)

	-- Werewolf hotbar monitoring
	GBP.wwState = GetActiveHotbarCategory() == HOTBAR_CATEGORY_WEREWOLF
	EVENT_MANAGER:RegisterForEvent(name, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, function( _, didActiveHotbarChange, _, activeHotbarCategory )
		if (didActiveHotbarChange) then
			local newState = activeHotbarCategory == HOTBAR_CATEGORY_WEREWOLF
			if (GBP.wwState ~= newState) then
				GBP.wwState = newState
				refresh()
			end
		end
	end)
end


--------------------------------------------------------------------------------
-- Interface
--------------------------------------------------------------------------------

do
	local registrants = { }

	function GBP.RegisterConditionalEnablement( abilityId, settingsText, checkFunction, overrideExisting )
		if (type(abilityId) == "number" and (type(settingsText) == "number" or type(settingsText) == "string") and type(checkFunction) == "function" and (overrideExisting or not registrants[abilityId])) then
			registrants[abilityId] = {
				text = settingsText,
				fn = checkFunction,
			}
		end
	end

	function GBP.CheckConditionalEnablement( abilityId )
		local ce = registrants[abilityId]
		if (ce and GBP.GetPanelEnablement(abilityId, "C")) then
			return ce.fn()
		else
			return true
		end
	end

	function GBP.GetConditionalEnablement( abilityId )
		local ce = registrants[abilityId]
		if (ce) then
			return ce.text, ce.fn
		else
			return nil
		end
	end
end

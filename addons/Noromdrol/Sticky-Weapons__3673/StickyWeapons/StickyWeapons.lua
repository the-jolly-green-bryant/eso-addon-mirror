-- =================================================================================
-- SET UP SOME LOCAL VARS
-- =================================================================================
local em = GetEventManager()
local _
local InventoryScene = SCENE_MANAGER.scenes.inventory

-- =================================================================================
-- SET UP TABLE TO HOLD ADDON VARS
-- =================================================================================
if stickyWeapons == nil then stickyWeapons = {} end
stickyWeapons.name = "StickyWeapons"
stickyWeapons.version = "1.1.1"
stickyWeapons.displayName = "Sticky Weapons"
stickyWeapons.settings = {}                          
stickyWeapons.addonInitialized = false
stickyWeapons.defaults = {
	timeToWaitBeforeSheathing = 4,
	sheatheState = "unsheathed",
	enteringCombat = "do nothing",
	forcedState = "sheathed",
	chatMessages = false
}

-- =================================================================================
-- FUNCTION: Initialize
-- This essentially sets everything up and gets it going.
-- =================================================================================
function stickyWeapons.Initialize(event, addon)
	if addon ~= stickyWeapons.name then return end
	stickyWeapons.addonInitialized = true
	em:UnregisterForEvent("StickyWeaponsInitialize", EVENT_ADD_ON_LOADED)
	stickyWeapons.settings = ZO_SavedVars:NewCharacterIdSettings("StickyWeaponsSavedVars", 1, nil, stickyWeapons.defaults)
	ZO_CreateStringId("SI_BINDING_NAME_STICKY_WEAPONS_TOGGLE", "Force Sheathe/Unsheathe")
	stickyWeapons.MakeMenu()
	zo_callLater(stickyWeapons.PrintBanner, 1000)
end

-- =================================================================================
-- FUNCTION: PrintBanner
-- Prints the initialization text in chat.
-- =================================================================================
function stickyWeapons.PrintBanner()
	if stickyWeapons.settings.chatMessages then
		df("|c00BBFF%s v%s|r initialized.", stickyWeapons.displayName, stickyWeapons.version)
	end
	stickyWeapons.PrintForcedState()
end

-- =================================================================================
-- FUNCTION: PrintForcedState
-- This essentially sets everything up and gets it going.
-- =================================================================================
function stickyWeapons.PrintForcedState()
	if stickyWeapons.settings.chatMessages then
		df("|c00BBFF%s|r: force weapons |cffffff%s|r", stickyWeapons.displayName, stickyWeapons.settings.forcedState)
	end
end

-- =================================================================================
-- FUNCTION: ToggleForceSheatheUnsheathe
-- This is called by the bindings.xml file whenever the key binding is pressed.
-- =================================================================================
function stickyWeapons.ToggleForceSheatheUnsheathe()
	if stickyWeapons.settings.forcedState == "sheathed" then
		stickyWeapons.settings.forcedState = "unsheathed"
	else
		stickyWeapons.settings.forcedState = "sheathed"
		stickyWeapons.SheatheWeapons() -- instantly sheathe, because seems weird to not instantly sheathe when the button is pressed
	end
	stickyWeapons.PrintForcedState()
	stickyWeapons.StateChange()
end

-- =================================================================================
-- FUNCTION: StateChange
-- Called whenever an event has occured that requires the weapons to be unsheathed
-- or sheathed.
-- =================================================================================
function stickyWeapons.StateChange(...)
	if (IsUnitInCombat("player")) then
		if ArePlayerWeaponsSheathed() then
			if stickyWeapons.settings.enteringCombat == "unsheathe" then
				TogglePlayerWield()
			end
		end
	end
	if stickyWeapons.settings.forcedState == "unsheathed" then
		if ArePlayerWeaponsSheathed() then
			TogglePlayerWield()
		end
	else
		if stickyWeapons.settings.timeToWaitBeforeSheathing ~= nil then
			zo_callLater(stickyWeapons.SheatheWeapons, stickyWeapons.settings.timeToWaitBeforeSheathing * 1000)
		end
	end
end

-- =================================================================================
-- FUNCTION: SheatheWeapons
-- Sheathe weapons, as long as the player isn't in combat. It does this by checking
-- to see if the player is in combat, because it'd be rude to sheathe your weapon
-- while in a fight. It also checks to see if the weapon is already sheathed or not
-- so we don't accidentally draw it if it was already put away, because it's just
-- a toggle.
-- =================================================================================
function stickyWeapons.SheatheWeapons()
	if stickyWeapons.settings.forcedState == "sheathed" then
		if not IsUnitInCombat("player") then
			if not ArePlayerWeaponsSheathed() then
				TogglePlayerWield()
			end
		end
	end
end

-- =================================================================================
-- FUNCTION: StateChangeMount
-- Delay unsheathing weapons when getting off of your horse, because the animation
-- takes a second or so and cancels the toggle.
-- =================================================================================
function stickyWeapons.StateChangeMount(_, mounted)
	if not mounted then
		zo_callLater(stickyWeapons.StateChange, 1500)	
	end
end

function stickyWeapons.MakeMenu()
	local LAM = LibAddonMenu2
	local saveData = stickyWeapons.settings
	local panelName = "swPanel"

	local panelData = {
		type = "panel",
		name = "Sticky Weapons",
		displayName = "|c00BBFFSticky Weapons|r",
		author = "|cFEF7DCNo|cFDE281ro|cFCCB1Amd|cB08A03ro|c342B09l|r",
        version = stickyWeapons.version,
		slashCommand = "/sw",
	}

	local optionsData = {
		{
			type = "header",
			name = "General Settings",
		},
		{
			type = "checkbox",
			name = "Show status messages in chat",
			getFunc = function() return saveData.chatMessages end,
			setFunc = function(newValue) saveData.chatMessages = newValue end,  
			tooltip = "Display startup message. Display state messages in chat when toggling state.", 
			default = stickyWeapons.defaults.chatMessages,
		},
		{
			type = "header",
			name = "State Settings",
		},		
		{
			type = "dropdown",
		    name = "Force weapon to be",
		    getFunc = function() return saveData.forcedState end,
		    setFunc = function(newValue) saveData.forcedState = newValue end,    
		    choices = {"sheathed", "unsheathed"},
		    default = stickyWeapons.defaults.forcedState
	   },		
		{
 	    	type = "dropdown",
            name = "When attacked and weapon is sheathed",
            getFunc = function() return saveData.enteringCombat end,
			setFunc = function(newValue) saveData.enteringCombat = newValue end,    
            choices = {"do nothing", "unsheathe"},
        	default = stickyWeapons.defaults.timeToCheckCombatState
        },
		{
			type = "slider",
			name = "Time to wait in seconds before sheathing",
			getFunc = function() return saveData.timeToWaitBeforeSheathing end,
			setFunc = function(newValue) saveData.timeToWaitBeforeSheathing = newValue end,
			min = 0,
			max = 10,
			step = .5,
			decimals = 1,
			tooltip = "Time to wait, in seconds, before sheathing after combat.",
			default = stickyWeapons.defaults.timeToWaitBeforeSheathing
		},
	}

	local registeredPanel = LAM:RegisterAddonPanel(panelName, panelData)
	LAM:RegisterOptionControls(panelName, optionsData)
end

em:RegisterForEvent("StickyWeaponsInitialize", EVENT_ADD_ON_LOADED, function(...) stickyWeapons.Initialize(...) end)

em:RegisterForEvent("StickyWeaponsCombatTrigger", EVENT_PLAYER_COMBAT_STATE, stickyWeapons.StateChange)             -- going into and out of combat
em:RegisterForEvent("StickyWeaponsBookTrigger", EVENT_HIDE_BOOK, stickyWeapons.StateChange)                         -- finished reading a book/scroll
em:RegisterForEvent("StickyWeaponsCompanionTrigger", EVENT_COMPANION_SUMMON_RESULT, stickyWeapons.StateChange)      -- finished summoning a companion
em:RegisterForEvent("StickyWeaponsCraftingTrigger", EVENT_END_CRAFTING_STATION_INTERACT, stickyWeapons.StateChange) -- finished interacting with crafting station
em:RegisterForEvent("StickyWeaponsChatterTrigger", EVENT_CHATTER_END, stickyWeapons.StateChange)                    -- finished talking/interacting
em:RegisterForEvent("StickyWeaponsDyeingTrigger", EVENT_DYEING_STATION_INTERACT_END , stickyWeapons.StateChange)    -- finished interacting with a dyeing station
em:RegisterForEvent("StickyWeaponsStoreTrigger", EVENT_CLOSE_STORE, stickyWeapons.StateChange)                      -- finished interacting with a store/fence
em:RegisterForEvent("StickyWeaponsGuildBankTrigger", EVENT_CLOSE_GUILD_BANK, stickyWeapons.StateChange)             -- finished interacting with guild bank
em:RegisterForEvent("StickyWeaponsAliveTrigger", EVENT_PLAYER_ALIVE, stickyWeapons.StateChange)                     -- player is resurrected
em:RegisterForEvent("StickyWeaponsLootTrigger", EVENT_LOOT_CLOSED, stickyWeapons.StateChange)                       -- finished looting
em:RegisterForEvent("StickyWeaponsMountTrigger", EVENT_MOUNTED_STATE_CHANGED, stickyWeapons.StateChangeMount)       -- mounted or unmounted
em:RegisterForEvent("StickyWeaponsSwimTrigger", EVENT_PLAYER_NOT_SWIMMING, stickyWeapons.StateChange)               -- finished swimming
em:RegisterForEvent("StickyWeaponsActivatedTrigger", EVENT_PLAYER_ACTIVATED, stickyWeapons.StateChange)             -- player logged in, zoned, etc
em:RegisterForEvent("StickyWeaponsSkyshardTrigger", EVENT_SKYSHARDS_UPDATED, stickyWeapons.StateChange)             -- skyshard obtained
em:RegisterForEvent("StickyWeaponsCompanionTrigger", EVENT_COMPANION_ACTIVATED, stickyWeapons.StateChange)             -- skyshard obtained

InventoryScene:RegisterCallback("StateChange", function(oldState, newState) 
	-- states: hiding, showing, shown, hidden
	if(newState == "hidden") then
		zo_callLater(stickyWeapons.StateChange, 200)
	end
end)
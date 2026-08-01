local L = GetString
local SF = LibSFUtils

TTFAS.saved = nil

local saved = SF.safeTable()
local curprof = nil

local dbg = TTFAS.dbg
local SystemMessage = TTFAS.SystemMessage


local function TakeItem(lootitem)
	dbg(SF.str("Taking item: ", lootitem.myname, " (", lootitem.itemId, ")"))
    LootItemById(lootitem.lootId)
end



local function createRuleList()
	local filters = saved.filters
	local rules = TTFAS.rules

	local function addrule( rtbl, fval, rmethod, rcfg )
		if fval == FASFV:val(FAS_NEVER) then return end

		table.insert(rtbl, FASrule:New(fval, rmethod, rcfg))
	end

	local ruleList = {}
	addrule(ruleList, curprof.gear.companionGears, rules.CheckCompanionGear, {
			["minQual"] = curprof.gear.minCompQuality,
			})
	addrule(ruleList, curprof.gear.set, rules.CheckIsSetGear, {
			["minVal"]  = curprof.gear.minTTCValue,
			["baseprice"] = curprof.TTC_baseprice,
			["profit"] = curprof.TTC_profit,
			})
	addrule(ruleList, curprof.gear.setJewel, rules.CheckIsSetJewel, {
			["minVal"]  = curprof.gear.minTTCValue,
			["baseprice"] = curprof.TTC_baseprice,
			["profit"] = curprof.TTC_profit,
			})
	addrule(ruleList, curprof.gear.unresearched, rules.CheckCanResearch)
	addrule(ruleList, curprof.gear.ornate, rules.CheckIsOrnate)
	addrule(ruleList, curprof.gear.intricate, rules.CheckIsIntricate, {
			["cloth"] = curprof.gear.clothIntricate,
			["metal"] = curprof.gear.metalIntricate,
			["wood"] = curprof.gear.woodIntricate,
			["jewel"] = curprof.gear.jewelIntricate,
			})
	addrule(ruleList, curprof.gear.jewelry, rules.CheckJewelry, {
			["minQual"] = curprof.gear.minQuality,
			["minVal"]  = curprof.gear.minValue,
			["minTTCVal"]  = curprof.gear.minTTCValue,
			["baseprice"] = curprof.TTC_baseprice,
			["profit"] = curprof.TTC_profit,
			})
	addrule(ruleList, curprof.gear.armors, rules.CheckArmor, {
			["minQual"] = curprof.gear.minQuality,
			["minVal"]  = curprof.gear.minValue,
			["minTTCVal"]  = curprof.gear.minTTCValue,
			["baseprice"] = curprof.TTC_baseprice,
			["profit"] = curprof.TTC_profit,
			})
	addrule(ruleList, curprof.gear.weapons, rules.CheckWeapons, {
			["minQual"] = curprof.gear.minQuality,
			["minVal"]  = curprof.gear.minValue,
			["minTTCVal"]  = curprof.gear.minTTCValue,
			["baseprice"] = curprof.TTC_baseprice,
			["profit"] = curprof.TTC_profit,
			})

	addrule(ruleList, curprof.materials.crafting,   rules.CheckBlksmMat)
	addrule(ruleList, curprof.materials.crafting,   rules.CheckWoodMat)
	addrule(ruleList, curprof.materials.crafting,   rules.CheckClothMat)
	addrule(ruleList, curprof.materials.crafting,   rules.CheckJewelryMat)
	addrule(ruleList, curprof.materials.style,      rules.CheckStyleMat)
	addrule(ruleList, curprof.materials.trait,      rules.CheckTraitMat)
	addrule(ruleList, curprof.materials.ingredients, rules.CheckProvisMat) 
	addrule(ruleList, curprof.materials.alchemy,    rules.CheckAlchemyMat)
	addrule(ruleList, curprof.materials.runes,      rules.CheckEnchMat)
	addrule(ruleList, curprof.materials.furnishing, rules.CheckFurnMat)

	addrule(ruleList, curprof.treasures.treasures, rules.CheckTreasures,
			{["minQual"] = curprof.treasures.minQuality,})

	addrule(ruleList, curprof.containers.containers, rules.CheckContainer)

	addrule(ruleList, curprof.papers.recipes, rules.CheckRecipe)
	addrule(ruleList, curprof.papers.motifs, rules.CheckMotif)
	addrule(ruleList, curprof.papers.stylepages, rules.CheckStylePage)
	addrule(ruleList, curprof.papers.treasureMaps, rules.CheckTreasureMap)
	addrule(ruleList, curprof.papers.writs, rules.CheckWrit)
	addrule(ruleList, curprof.papers.paperTTC, rules.CheckPaperTTC)

	addrule(ruleList, FASFV:val(FAS_ALWAYS), rules.CheckQuest)

	addrule(ruleList, curprof.misc.glyphs, rules.CheckGlyph)
	addrule(ruleList, curprof.misc.foodAndDrink, rules.CheckProvisions)
	addrule(ruleList, curprof.misc.poisons, rules.CheckPoison)
	addrule(ruleList, curprof.misc.potions, rules.CheckPotion)

	addrule(ruleList, curprof.misc.furniture, rules.CheckFurniture)

	addrule(ruleList, curprof.misc.lockpicks, rules.CheckLockpick)
	addrule(ruleList, curprof.misc.soulGems, rules.CheckSoulGem)
	addrule(ruleList, curprof.misc.bait, rules.CheckBait)
	addrule(ruleList, FASFV:val(FAS_ALWAYS), rules.CheckAntiquity)
	return ruleList
end

local function runRuleList(rlst, lootitem)
	local rval = false
	for k,v in ipairs(rlst) do
		rval = v:check(lootitem)
		if rval then return true end
	end
	return rval
end

local function autocloseLootWindow()
	-- handle closeLootWindow is true
    local currentScene = SCENE_MANAGER:GetCurrentSceneName()
	dbg("(to close) currentScene = "..currentScene)
    if curprof.general.closeLootWindow and not IsShiftKeyDown() then
		EndLooting()
		if currentScene == 'hudui' or currentScene == 'interact' or currentScene == 'hud' then
			SCENE_MANAGER:RestoreHUDUIScene()

		else
		  SCENE_MANAGER:Show(currentScene)
		end
		-- add in a small delay for construction/destruction of an unneeded table
		-- in order to prevent getting kicked for message spam from
		-- the game if you manage to loot fast enough. Stupid, but it helps.
		local blah = {}
		local blah2 = {}
	end
end

-- Evaluate items from the loot container
local function OnLootUpdated(numId)
    if TTFAS.saved.enabled == false then
        return
    end
	if GetNumLootItems() == 0 then return end

	-- only execute if we are working with stolen items
	if SYSTEMS:GetObject("loot"):AreNonStolenItemsPresent() then return end

	-- deal with "Special" containers that must be cleared.
	local name, targetType, actionName, isOwned = GetLootTargetInfo()
	if name ~= "" then
		if targetType == INTERACT_TARGET_TYPE_ITEM then
			name = zo_strformat(SI_TOOLTIP_ITEM_NAME, name)
		elseif targetType == INTERACT_TARGET_TYPE_OBJECT then
			name = zo_strformat(SI_LOOT_OBJECT_NAME, name)
		elseif targetType == INTERACT_TARGET_TYPE_FIXTURE then
			name = zo_strformat(SI_TOOLTIP_FIXTURE_INSTANCE, name)
		end
	end
	dbg(SF.str("target info: ",name, " type: ",targetType, " actionName: ", actionName, " isOwned: ", isOwned))
	--  [TTFAS] target info: Thieves Trove type: 1 actionName: Steal From isOwned: true
	--  [TTFAS] target info: Nemic Zeric type: 1 actionName: Search isOwned: true
	--  [TTFAS] target info: safebox type: 1 actionName: Steal From isOwned: true
	--  [TTFAS] target info: Research Portfolio type: 2 actionName: isOwned: false
	--			(yes, this is a stolen Research Portfolio)
	dbg(SF.str("SYSTEMS:GetObject(\"loot\"):AreNonStolenItemsPresent() = ", 
				SYSTEMS:GetObject("loot"):AreNonStolenItemsPresent() ))

	-- handle "special" containers like Thief Troves, murdered bodies, and safeboxes
	-- These are always looted of everything - not filtered
	if name and name ~= "" and isOwned then 
		dbg("Stealing all from  ", name)
		LootAll(false)
		return
	end

	-- create the rule list we will be evaluating against
	local ruleList = createRuleList()

    dbg("TTFAS Start Stealing")

	-- handle looting from stolen containers found in the inventory
	-- not a rule or separate function because this has the option 
	-- of exiting OnLootUpdated(), which rules are not allowed to do.
	local currentScene = SCENE_MANAGER:GetCurrentSceneName()
	dbg("currentScene = ", currentScene)

	local invtainer = curprof.containers.invcontainers
	if currentScene == "inventory" then
		-- we already know that this is a stolen container from the check above
		if invtainer == "take all items" then
			-- loot all items from a container in the inventory
			dbg("Looting inventory container")
			LootAll(false)
			EndLooting()
			SCENE_MANAGER:Show("inventory")
			return

		elseif invtainer == "just open" then
			dbg("Just opening inventory container")
			return

		elseif invtainer == "follow rules" then
			-- fall through to loot processing
			dbg("Following rules for inventory container")
		end
	end

	-- always get the money!!
    LootCurrency(CURT_MONEY)

	-- process each of the items in the container to decide
	-- if we want them or not
    local num = GetNumLootItems()
    dbg("Loot items total : ", num)
    for i = 1, num, 1 do
		local lootitem = SFInvItem:NewLootIndex(i)

		dbg(SF.dstr("got item: ",i,". ", lootitem.name))

        if saved.debugMode then
            --dbg("[TTFAS Debug Log]")
			--lootitem:PrintDebug()
        end

		if runRuleList(ruleList, lootitem) then
			dbg("matched one of the rules")
			TakeItem(lootitem)
		end
	end

	-- handle closeLootWindow is true
	autocloseLootWindow()
end

-- keep track of registered events for TTFAS
local evtmgr = SF.EvtMgr:New("TTFAS")

function TTFAS:New(control)
    local result = ZO_Object.New(self)
    result.control = control
    evtmgr:registerEvt(EVENT_ADD_ON_LOADED, function(...)
        self:OnLoaded(...)
    end)
    return result
end

function TTFAS:Enable()
	TTFAS.saved.enabled = true

	-- Turn off auto-stealing in-game and in ThiefTools
	if curprof.general.turnOffGmAS then 
		SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, tostring(0))
	else
		SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, tostring(1))
	end
    if ThiefTools then
		ThiefTools.DisableAutoSteal()
	end
	if curprof.general.turnOffGmAL then 
		SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, tostring(0))
	else
		SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, tostring(1))
	end
	TTFAS.RegisterEvents()
end

function TTFAS:Disable()
	TTFAS.saved.enabled = false
	
	-- Restore original auto-stealing in-game and in ThiefTools
	SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, tostring(TTFAS.origALStolenSetting))
	SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, tostring(TTFAS.origALSetting))
	
	if ThiefTools  and TTFAS.origTTAL then
		ThiefTools.EnableAutoSteal()
	end
	TTFAS.UnregisterAllEvts()
end

function TTFAS.ToggleEnable()
	TTFAS.saved.enabled = not TTFAS.saved.enabled
	if TTFAS.saved.enabled == true then
		TTFAS.Enable()
		SystemMessage("Filtered AutoSteal ON")
		
	else
		TTFAS.Disable()
		SystemMessage("Filtered AutoSteal OFF")
	end
end

function TTFAS.ChangeCurProf(name)
	if not name then return end
	local newpr = TTFAS.profTbl.profiles[name]
	if newpr then
		curprof = newpr
		TTFAS.currentProfile = newpr
		TTFAS.saved.profileName = name
	end
end

function TTFAS:OnLoaded(event, addon)
    if addon ~= "ThiefToolsFilteredAutoSteal" then
        return
    end
    evtmgr:unregEvt(EVENT_ADD_ON_LOADED)

    -- load our saved variables
	TTFASLogger():Debug("Loading saved variables")
	TTFAS.loadsv()
	saved = TTFAS.saved
	curprof = TTFAS.currentProfile

    SLASH_COMMANDS["/ttfas"] = function(keyWord, argument)
        TTFAS.ToggleEnable()
    end

	evtmgr:registerEvt(EVENT_LOOT_UPDATED, function( _, ... ) 
		OnLootUpdated( ... )  
	end)
end

-- EVENT_PLAYER_ACTIVATED handler - executes every zone change once registered
-- (also called by runOnStart)
local function OnPlayerActivated()

    if TTFAS.saved.enabled then
    	SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, tostring(0))
    end
	if ThiefTools then
		ThiefTools.DisableAutoSteal()
	end

    if not TTFAS.StartupInfo and saved.banner then
		TTFASLogger():Debug("Display banner in chat")
		if TTFAS.saved.enabled then
			SystemMessage(TTFAS.name, " ", TTFAS.version, ": ", L(TTFAS_ENABLED))
			if curprof.general.closeLootWindow then
				SystemMessage(L(TTFAS_LOGIN_CLOSE_LOOT_WINDOW), L(TTFAS_ENABLED))
				
			else
				SystemMessage(L(TTFAS_LOGIN_CLOSE_LOOT_WINDOW), L(TTFAS_DISABLED))
			end
			
		else
			SystemMessage(TTFAS.name, " ", TTFAS.version, ": ", L(TTFAS_DISABLED))
		end
    end
    TTFAS.StartupInfo = true
end

-- EVENT_PLAYER_ACTIVATED handler - executes only the first time on game load
local ranIt = false
local function runOnStart()
	TTFASLogger():Debug("Initial runOnStart setup of game autoloot/autosteal")
	dbg("initial setup...")
	TTFAS.origALStolenSetting = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN)
	dbg("origALStolenSetting "..TTFAS.origALStolenSetting)
	TTFAS.origALSetting = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT)
	TTFAS.origLHSetting = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_LOOT_HISTORY)
	-- set up integrations values
	-- ThiefTools
	if ThiefTools and ThiefTools.GetAutoSteal then
		TTFASLogger():Debug("Initial setup of ThiefTools autosteal")
		TTFAS.origTTAL = ThiefTools.GetAutoSteal()
	end
	
	-- UnknownTracker
	if UnknownTracker then 
		TTFAS.UT_addon = true
	else
		TTFAS.UT_addon = false
	end
	
	-- TamrielTradeCentre
	if TamrielTradeCentre then 
		TTFAS.TTC_addon = true
	else
		TTFAS.TTC_addon = false
	end

	-- UI initialization can only be run once
	if not ranIt then
		TTFASLogger():Debug("Initializing Settings UI")
		TTFAS_Settings.InitSettingsUI(saved, curprof)
		ranIt = true
	end

	-- change the registration for EVENT_PLAYER_ACTIVATED
	evtmgr:unregEvt(EVENT_PLAYER_ACTIVATED)
	OnPlayerActivated()
	evtmgr:registerEvt(EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end


function TTFAS:ToggleAutoSteal()
	if TTFAS.saved.enabled then
		evtmgr:registerEvt(EVENT_LOOT_UPDATED, function( _, ... ) OnLootUpdated( ... )  end)
		
	else
		evtmgr:unregEvt(EVENT_LOOT_UPDATED )
	end
end






function TTFAS_Startup(self)
	TTFASLogger():Debug("Running TTFAS_Startup")
    _Instance = TTFAS
	TTFAS.control = self
	evtmgr:registerEvt(EVENT_ADD_ON_LOADED, function(...)
        TTFAS:OnLoaded(...)
    end)
end

function TTFAS_Enable()
	TTFASLogger():Debug("Running TTFAS_Enable")
	TTFASLogger():Debug("TTFAS.saved.enabled = ",TTFAS.saved.enabled)

	-- Turn off auto-stealing in-game and in ThiefTools
	if curprof.general.turnOffGmAS then 
		SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, tostring(0))
	end
	if ThiefTools then
		TTFASLogger():Debug("Running ThiefTools.DisableAutoSteal")
		ThiefTools.DisableAutoSteal()
	end
	if curprof.general.turnOffGmAL then 
		SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, tosstring(0))
	end
	if not TTFAS.saved.enabled then
		TTFAS.saved.enabled = true
		TTFAS.RegisterEvents()
	end
end

function TTFAS_Disable()
	TTFASLogger()r:Debug("Running TTFAS_Disable")
	TTFASLogger()r:Debug("TTFAS.saved.enabled = ",TTFAS.saved.enabled)

	-- Restore original auto-stealing in-game and in ThiefTools
	SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, TTFAS.origALStolenSetting)
	SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, TTFAS.origALSetting)
	if ThiefTools  then --and TTFAS.origTTAL then
		TTFASLogger():Debug("Running ThiefTools.EnableAutoSteal")
		--TTFASLogger():Debug("before enable - ThiefTools.options.chartt.autoSteal = ",ThiefTools.options.chartt.autoSteal)
		ThiefTools.EnableAutoSteal()
		--TTFASLogger():Debug("after enable - ThiefTools.options.chartt.autoSteal = ",ThiefTools.options.chartt.autoSteal)
	end
	
	if TTFAS.saved.enabled then
		TTFAS.saved.enabled = false
		TTFAS.UnregisterAllEvts()
	end
end

function TTFAS_isEnabled()
	return TTFAS.saved.enabled
end


-- does not include EVENT_ADD_ON_LOADED because this can be
-- invoked more than once.
function TTFAS.RegisterEvents(runOnce)
	TTFASLogger():Debug("Registering all events")
	
	evtmgr:registerEvt(EVENT_PLAYER_ACTIVATED, runOnStart)
	
	if not runOnce then
		runOnStart()
	end
end

function TTFAS.UnregisterAllEvts()
	TTFASLogger()r:Debug("Unregistering all events")
	evtmgr:unregAllEvt()
end


do
	TTFAS.RegisterEvents(true)
	-- only for event testing
	if TestTTFAS then
		TestTTFAS.RegisterEvents()
	end
end


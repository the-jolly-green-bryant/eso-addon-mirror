local LIB_IDENTIFIER = "LibFoodDrinkBuff"
local lib = LibStub:NewLibrary(LIB_IDENTIFIER, 2)

if not lib then return end

----------------
-- BUFF TYPES --
----------------
local FOOD_BUFF_NONE									= 0
local FOOD_BUFF_MAX_HEALTH								= 1
local FOOD_BUFF_MAX_MAGICKA								= 2
local FOOD_BUFF_MAX_STAMINA								= 4
local FOOD_BUFF_REGEN_HEALTH							= 8
local FOOD_BUFF_REGEN_MAGICKA							= 16
local FOOD_BUFF_REGEN_STAMINA							= 32
local FOOD_BUFF_SPECIAL_VAMPIRE							= 64
local FOOD_BUFF_FIND_FISHES								= 128
local FOOD_BUFF_MAX_ALL									= FOOD_BUFF_MAX_HEALTH		+ FOOD_BUFF_MAX_MAGICKA		+ FOOD_BUFF_MAX_STAMINA									-- 7
local FOOD_BUFF_MAX_HEALTH_MAGICKA						= FOOD_BUFF_MAX_HEALTH		+ FOOD_BUFF_MAX_MAGICKA																-- 3
local FOOD_BUFF_MAX_HEALTH_MAGICKA_FISH					= FOOD_BUFF_MAX_HEALTH		+ FOOD_BUFF_MAX_MAGICKA		+ FOOD_BUFF_FIND_FISHES									-- 131
local FOOD_BUFF_MAX_HEALTH_MAGICKA_REGEN_HEALTH_MAGICKA	= FOOD_BUFF_MAX_HEALTH		+ FOOD_BUFF_REGEN_HEALTH	+ FOOD_BUFF_MAX_MAGICKA		+ FOOD_BUFF_REGEN_MAGICKA	-- 27
local FOOD_BUFF_MAX_HEALTH_MAGICKA_REGEN_MAGICKA		= FOOD_BUFF_MAX_HEALTH		+ FOOD_BUFF_MAX_MAGICKA		+ FOOD_BUFF_REGEN_MAGICKA								-- 19
local FOOD_BUFF_MAX_HEALTH_MAGICKA_SPECIAL_VAMPIRE		= FOOD_BUFF_MAX_HEALTH		+ FOOD_BUFF_MAX_MAGICKA		+ FOOD_BUFF_SPECIAL_VAMPIRE								-- 67
local FOOD_BUFF_MAX_HEALTH_REGEN_ALL					= FOOD_BUFF_MAX_HEALTH		+ FOOD_BUFF_REGEN_HEALTH	+ FOOD_BUFF_REGEN_MAGICKA	+ FOOD_BUFF_REGEN_STAMINA	-- 57
local FOOD_BUFF_MAX_HEALTH_REGEN_HEALTH					= FOOD_BUFF_MAX_HEALTH		+ FOOD_BUFF_REGEN_HEALTH															-- 9
local FOOD_BUFF_MAX_HEALTH_REGEN_MAGICKA				= FOOD_BUFF_MAX_HEALTH		+ FOOD_BUFF_REGEN_MAGICKA															-- 17
local FOOD_BUFF_MAX_HEALTH_REGEN_STAMINA				= FOOD_BUFF_MAX_HEALTH		+ FOOD_BUFF_REGEN_STAMINA															-- 33
local FOOD_BUFF_MAX_HEALTH_STAMINA						= FOOD_BUFF_MAX_HEALTH		+ FOOD_BUFF_MAX_STAMINA																-- 5
local FOOD_BUFF_MAX_HEALTH_STAMINA_REGEN_HEALTH_STAMINA	= FOOD_BUFF_MAX_HEALTH		+ FOOD_BUFF_REGEN_HEALTH	+ FOOD_BUFF_MAX_STAMINA	+ FOOD_BUFF_REGEN_STAMINA		-- 29
local FOOD_BUFF_MAX_MAGICKA_REGEN_HEALTH				= FOOD_BUFF_MAX_MAGICKA		+ FOOD_BUFF_REGEN_HEALTH															-- 10
local FOOD_BUFF_MAX_MAGICKA_REGEN_MAGICKA				= FOOD_BUFF_MAX_MAGICKA		+ FOOD_BUFF_REGEN_MAGICKA															-- 18
local FOOD_BUFF_MAX_MAGICKA_REGEN_STAMINA				= FOOD_BUFF_MAX_MAGICKA		+ FOOD_BUFF_REGEN_STAMINA															-- 34
local FOOD_BUFF_MAX_MAGICKA_STAMINA						= FOOD_BUFF_MAX_MAGICKA		+ FOOD_BUFF_MAX_STAMINA																-- 6
local FOOD_BUFF_MAX_STAMINA_HEALTH_REGEN_MAGICKA		= FOOD_BUFF_MAX_STAMINA		+ FOOD_BUFF_MAX_HEALTH		+ FOOD_BUFF_REGEN_MAGICKA								-- 21
local FOOD_BUFF_MAX_STAMINA_HEALTH_REGEN_STAMINA		= FOOD_BUFF_MAX_HEALTH		+ FOOD_BUFF_MAX_STAMINA		+ FOOD_BUFF_REGEN_STAMINA								-- 37
local FOOD_BUFF_MAX_STAMINA_REGEN_HEALTH				= FOOD_BUFF_MAX_STAMINA		+ FOOD_BUFF_REGEN_HEALTH															-- 12
local FOOD_BUFF_MAX_STAMINA_REGEN_MAGICKA				= FOOD_BUFF_MAX_STAMINA		+ FOOD_BUFF_REGEN_MAGICKA															-- 20
local FOOD_BUFF_MAX_STAMINA_REGEN_STAMINA				= FOOD_BUFF_MAX_STAMINA		+ FOOD_BUFF_REGEN_STAMINA															-- 36
local FOOD_BUFF_REGEN_ALL								= FOOD_BUFF_REGEN_HEALTH	+ FOOD_BUFF_REGEN_MAGICKA	+ FOOD_BUFF_REGEN_STAMINA								-- 56
local FOOD_BUFF_REGEN_HEALTH_MAGICKA					= FOOD_BUFF_REGEN_HEALTH	+ FOOD_BUFF_REGEN_MAGICKA															-- 24
local FOOD_BUFF_REGEN_HEALTH_STAMINA					= FOOD_BUFF_REGEN_HEALTH	+ FOOD_BUFF_REGEN_STAMINA															-- 40
local FOOD_BUFF_REGEN_MAGICKA_STAMINA					= FOOD_BUFF_REGEN_MAGICKA	+ FOOD_BUFF_REGEN_STAMINA															-- 48
local FOOD_BUFF_REGEN_MAGICKA_STAMINA_FISH				= FOOD_BUFF_REGEN_MAGICKA	+ FOOD_BUFF_REGEN_STAMINA	+ FOOD_BUFF_FIND_FISHES									-- 176

--------------------
-- DRINKS'n'FOODS --
--------------------
local isDrinkBuff = {
	[61322] = FOOD_BUFF_REGEN_HEALTH,								-- Health Recovery
	[61325] = FOOD_BUFF_REGEN_MAGICKA,								-- Magicka Recovery
	[61328] = FOOD_BUFF_REGEN_STAMINA,								-- Health & Magicka Recovery
	[61335] = FOOD_BUFF_REGEN_HEALTH_MAGICKA,               		-- Health & Magicka Recovery (Liqueurs)
	[61340] = FOOD_BUFF_REGEN_HEALTH_STAMINA,						-- Health & Stamina Recovery
	[61345] = FOOD_BUFF_REGEN_MAGICKA_STAMINA,						-- Magicka & Stamina Recovery
	[61350] = FOOD_BUFF_REGEN_ALL,									-- All Primary Stat Recovery
	[66125] = FOOD_BUFF_MAX_HEALTH, 								-- Increase Max Health
	[66132] = FOOD_BUFF_REGEN_HEALTH,                       		-- Health Recovery (Alcoholic Drinks)
	[66137] = FOOD_BUFF_REGEN_MAGICKA,                      		-- Magicka Recovery (Tea)
	[66141] = FOOD_BUFF_REGEN_STAMINA,                      		-- Stamina Recovery (Tonics)
	[66586] = FOOD_BUFF_REGEN_HEALTH,                       		-- Health Recovery
	[66590] = FOOD_BUFF_REGEN_MAGICKA,                      		-- Magicka Recovery
	[66594] = FOOD_BUFF_REGEN_STAMINA,                      		-- Stamina Recovery
	[68416] = FOOD_BUFF_REGEN_ALL,                          		-- All Primary Stat Recovery (Crown Refreshing Drink)
	[72816] = FOOD_BUFF_REGEN_HEALTH_MAGICKA,               		-- Red Frothgar
	[72965] = FOOD_BUFF_REGEN_HEALTH_STAMINA,               		-- Health and Stamina Recovery (Cyrodilic Field Brew)
	[72968] = FOOD_BUFF_REGEN_HEALTH_MAGICKA,               		-- Health and Magicka Recovery (Cyrodilic Field Tea)
	[72971] = FOOD_BUFF_REGEN_MAGICKA_STAMINA,              		-- Magicka and Stamina Recovery (Cyrodilic Field Tonic)
	[84700] = FOOD_BUFF_REGEN_HEALTH_MAGICKA,               		-- 2h Witches event: Eyeballs
	[84704] = FOOD_BUFF_REGEN_ALL,                          		-- 2h Witches event: Witchmother's Party Punch
	[84720] = FOOD_BUFF_MAX_MAGICKA_REGEN_MAGICKA,          		-- 2h Witches event: Eye Scream
	[84731] = FOOD_BUFF_MAX_HEALTH_MAGICKA_REGEN_MAGICKA,   		-- 2h Witches event: Witchmother's Potent Brew
	[84732] = FOOD_BUFF_REGEN_HEALTH,                       		-- Increase Health Regen
	[84733] = FOOD_BUFF_REGEN_HEALTH,                       		-- Increase Health Regen
	[84735] = FOOD_BUFF_MAX_HEALTH_MAGICKA_SPECIAL_VAMPIRE, 		-- 2h Witches event: Double Bloody Mara
	[85497] = FOOD_BUFF_REGEN_ALL,                          		-- All Primary Stat Recovery
	[86559] = FOOD_BUFF_REGEN_MAGICKA_STAMINA_FISH,         		-- Fish Eye
	[86560] = FOOD_BUFF_REGEN_STAMINA,                      		-- Stamina Recovery
	[86673] = FOOD_BUFF_MAX_STAMINA_REGEN_STAMINA,          		-- Lava Foot Soup & Saltrice
	[86674] = FOOD_BUFF_REGEN_STAMINA,                      		-- Stamina Recovery
	[86677] = FOOD_BUFF_MAX_STAMINA_REGEN_HEALTH,           		-- Warning Fire (Bergama Warning Fire)
	[86678] = FOOD_BUFF_REGEN_HEALTH,                       		-- Health Recovery
	[86746] = FOOD_BUFF_REGEN_HEALTH_MAGICKA,               		-- Betnikh Spiked Ale (Betnikh Twice-Spiked Ale)
	[86747] = FOOD_BUFF_REGEN_HEALTH,                       		-- Health Recovery
	[86791] = FOOD_BUFF_REGEN_STAMINA,                      		-- Increase Stamina Recovery (Ice Bear Glow-Wine)
	[89957] = FOOD_BUFF_MAX_STAMINA_HEALTH_REGEN_STAMINA,   		-- Dubious Camoran Throne
	[92433] = FOOD_BUFF_REGEN_HEALTH_MAGICKA, 						-- Health & Magicka Recovery
	[92476] = FOOD_BUFF_REGEN_HEALTH_STAMINA, 						-- Health & Stamina Recovery
	[100502] = FOOD_BUFF_REGEN_HEALTH_MAGICKA,              		-- Deregulated Mushroom Stew (Health + magicka reg)
}

local isFoodBuff = {
	[17407] = FOOD_BUFF_MAX_HEALTH,                         		-- Increase Max Health
	[17577] = FOOD_BUFF_MAX_MAGICKA_STAMINA, 						-- Increase Max Magicka & Stamina
	[17581] = FOOD_BUFF_MAX_ALL, 									-- Increase All Primary Stats
	[17608] = FOOD_BUFF_REGEN_MAGICKA_STAMINA, 						-- Magicka & Stamina Recovery
	[17614] = FOOD_BUFF_REGEN_ALL, 									-- All Primary Stat Recovery
	[61218] = FOOD_BUFF_MAX_ALL,									-- Increase All Primary Stats
	[61255] = FOOD_BUFF_MAX_HEALTH_STAMINA,							-- Increase Max Health & Stamina
	[61257] = FOOD_BUFF_MAX_HEALTH_MAGICKA,							-- Increase Max Health & Magicka
	[61259] = FOOD_BUFF_MAX_HEALTH,									-- Increase Max Health
	[61260] = FOOD_BUFF_MAX_MAGICKA,								-- Increase Max Magicka
	[61261] = FOOD_BUFF_MAX_STAMINA,								-- Increase Max Stamina
	[61294] = FOOD_BUFF_MAX_MAGICKA_STAMINA,						-- Increase Max Magicka & Stamina
	[66128] = FOOD_BUFF_MAX_MAGICKA,                        		-- Increase Max Magicka (Fruit Dishes)
	[66130] = FOOD_BUFF_MAX_STAMINA,                        		-- Increase Max Stamina (Vegetable Dishes)
	[66551] = FOOD_BUFF_MAX_HEALTH,                         		-- Garlic and Pepper Venison Steak
	[66568] = FOOD_BUFF_MAX_MAGICKA,                        		-- Increase Max Magicka
	[66576] = FOOD_BUFF_MAX_STAMINA,                        		-- Increase Max Stamina
	[68411] = FOOD_BUFF_MAX_ALL,                            		-- Crown store
	[72819] = FOOD_BUFF_MAX_HEALTH_REGEN_STAMINA,           		-- Tripe Trifle Pocket
	[72822] = FOOD_BUFF_MAX_HEALTH_REGEN_HEALTH,            		-- Blood Price Pie
	[72824] = FOOD_BUFF_MAX_HEALTH_REGEN_ALL,               		-- Smoked Bear Haunch
	[72956] = FOOD_BUFF_MAX_HEALTH_STAMINA,                 		-- Max Health and Stamina (Cyrodilic Field Tack)
	[72959] = FOOD_BUFF_MAX_HEALTH_MAGICKA,                 		-- Max Health and Magicka (Cyrodilic Field Treat)
	[72961] = FOOD_BUFF_MAX_MAGICKA_STAMINA,                		-- Max Stamina and Magicka (Cyrodilic Field Bar)
	[84678] = FOOD_BUFF_MAX_MAGICKA,                        		-- Increase Max Magicka
	[84681] = FOOD_BUFF_MAX_MAGICKA_STAMINA,                		-- Pumpkin Snack Skewer
	[84709] = FOOD_BUFF_MAX_MAGICKA_REGEN_STAMINA,          		-- Crunchy Spider Skewer
	[84725] = FOOD_BUFF_MAX_MAGICKA_REGEN_HEALTH,           		-- The Brains!
	[84736] = FOOD_BUFF_MAX_HEALTH,                         		-- Increase Max Health
	[85484] = FOOD_BUFF_MAX_ALL,                            		-- Increase All Primary Stats
	[86749] = FOOD_BUFF_MAX_MAGICKA_STAMINA,                		-- Mud Ball
	[86787] = FOOD_BUFF_MAX_STAMINA,                        		-- Rajhin's Sugar Claws
	[86789] = FOOD_BUFF_MAX_HEALTH,                         		-- Alcaire Festival Sword-Pie
	[89955] = FOOD_BUFF_MAX_STAMINA_REGEN_MAGICKA,          		-- Candied Jester's Coins
	[89971] = FOOD_BUFF_MAX_STAMINA_HEALTH_REGEN_MAGICKA,   		-- Jewels of Misrule
	[92435] = FOOD_BUFF_MAX_HEALTH_MAGICKA,                 		-- Increase Health & Magicka
	[92437] = FOOD_BUFF_MAX_HEALTH,                         		-- Increase Health
	[92474] = FOOD_BUFF_MAX_HEALTH_STAMINA,                 		-- Increase Health & Stamina
	[92477] = FOOD_BUFF_MAX_HEALTH,                         		-- Increase Health
	[100488] = FOOD_BUFF_MAX_ALL,                           		-- Spring-Loaded Infusion (Increase all primary stats)
	[100498] = FOOD_BUFF_MAX_HEALTH_MAGICKA_REGEN_HEALTH_MAGICKA,	-- Clockwork Citrus Filet (Increase health + health Recovery, and magicka + magicka Recovery)
	[107748] = FOOD_BUFF_MAX_HEALTH_MAGICKA_FISH,                 	-- Lure Allure (Increase Health & Magicka)
	[107789] = FOOD_BUFF_MAX_HEALTH_STAMINA_REGEN_HEALTH_STAMINA,	-- Artaeum Takeaway Broth (Increase Health & Stamina & Health Recovery & Stamina Recovery)
}

---------------
-- FUNCTIONS --
---------------
function lib:GetTimeLeftInSeconds(timeInMilliseconds)
-- Calculate time left of a food/drink buff
	return math.max(zo_roundToNearest(timeInMilliseconds-(GetGameTimeMilliseconds()/1000), 1), 0)
end

function lib:GetFoodBuffInfos(unitTag)
-- Returns: number buffType, bool isDrink, number abilityId, string buffName, number timeStarted, number timeEnds, textureString iconTexture
	local numBuffs = GetNumBuffs(unitTag)
	if numBuffs > 0 then
		for i = 1, numBuffs do
			-- get buff infos
			--** _Returns: _buffName_, _timeStarted_, _timeEnding_, _buffSlot_, _stackCount_, _iconFilename_, _buffType_, _effectType_, _abilityType_, _statusEffectType_, _abilityId_, _canClickOff_
			local buffName, timeStarted, timeEnding, _, _, iconTexture, _, _, _, _, abilityId = GetUnitBuffInfo(unitTag, i)
			local buffTypeDrink = isDrinkBuff[abilityId] or false
			local buffTypeFood = isFoodBuff[abilityId] or false
			local buffType = FOOD_BUFF_NONE
			local isDrink = false
			-- It's a drink?
			if buffTypeDrink then
				isDrink = true
				buffType = buffTypeDrink
			elseif buffTypeFood then
				buffType = buffTypeFood
			end
            -- return
			if buffType ~= "" and buffType ~= FOOD_BUFF_NONE then
				if isDrinkBuff[abilityId] or isFoodBuff[abilityId] then
					return buffType, isDrink, abilityId, zo_strformat("<<C:1>>", buffName), timeStarted, timeEnding, iconTexture
				end
			end
		end
	end
	return FOOD_BUFF_NONE, nil, nil, nil, nil, nil, nil
end

function lib:IsFoodBuffActive(unitTag)
-- Returns: bool isBuffActive
	local numBuffs = GetNumBuffs(unitTag)
	if numBuffs > 0 then
		for i = 1, numBuffs do
			local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo(unitTag, i)
				if isDrinkBuff[abilityId] or isFoodBuff[abilityId] then
				return true
			end
		end
	end
	return false
end

function lib:IsFoodBuffActiveAndGetTimeLeft(unitTag)
-- Returns: bool isBuffActive, number timeLeftInSeconds , number abilityId
	local numBuffs = GetNumBuffs(unitTag)
	if numBuffs > 0 then
		for i = 1, numBuffs do
			local _, _, timeEnding, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo(unitTag, i)
			if isDrinkBuff[abilityId] or isFoodBuff[abilityId] then
				return true, lib:GetTimeLeftInSeconds(timeEnding), abilityId
			end
		end
	end
	return false, 0, nil
end

function lib:IsAbilityADrinkBuff(abilityId)
-- Returns: nilable:bool isAbilityADrinkBuff(true) or isAbilityAFoodBuff(false), or nil if not a food or drink buff
	if nil == abilityId then return nil end
	if isDrinkBuff[abilityId] then return true end
	if isFoodBuff[abilityId] then return false end
	return nil
end

-- Filter the event EVENT_EFFECT_CHANGED to the local player and only the abilityIds of the food/drink buffs
-- Possible additional filterTypes are: REGISTER_FILTER_UNIT_TAG, REGISTER_FILTER_UNIT_TAG_PREFIX
--> Performance gain as you check if a food/drink buff got active (gained, refreshed), or was  removed (faded, refreshed)
function lib:RegisterAbilityIdsFilterOnEventEffectChanged(addonEventNameSpace, callbackFunc, filterType, filterParameter)
	if addonEventNameSpace == nil or addonEventNameSpace == "" then return nil end
	if callbackFunc == nil or type(callbackFunc) ~= "function" then return nil end
	local eventCounter = 0
	for abilityId, _ in pairs(isFoodBuff) do
		eventCounter = eventCounter + 1
		local eventName = addonEventNameSpace .. eventCounter
		EVENT_MANAGER:RegisterForEvent(eventName, EVENT_EFFECT_CHANGED, callbackFunc)
		EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId, filterType, filterParameter)
	end
	for abilityId, _ in pairs(isDrinkBuff) do
		eventCounter = eventCounter + 1
		local eventName = addonEventNameSpace .. eventCounter
		EVENT_MANAGER:RegisterForEvent(eventName, EVENT_EFFECT_CHANGED, callbackFunc)
		EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId, filterType, filterParameter)
	end
	return true
end

-------------
-- GLOBALS --
-------------
lib.IS_FOOD_BUFF = isFoodBuff
lib.IS_DRINK_BUFF = isDrinkBuff

-----------
-- DEBUG --
-----------
function DEBUG_ACTIVE_BUFFS()
	local COUNT = 0
	local PLAYER_TAG = "player"
	local DIVIDER = ZO_ERROR_COLOR:Colorize("____________________________________")
	d(DIVIDER)
	df(ZO_ERROR_COLOR:Colorize("|cFF0000%s Debug:|r"), LIB_IDENTIFIER)
	for i = 1, GetNumBuffs(PLAYER_TAG) do
		local buffName, startTime, endTime, buffSlot, stackCount, iconFile, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff = GetUnitBuffInfo(PLAYER_TAG, i)
		COUNT = COUNT + 1
		d(zo_strformat("<<1>>. <<C:2>>, abilityId: <<3>>", COUNT, ZO_SELECTED_TEXT:Colorize(buffName), ZO_SELECTED_TEXT:Colorize(abilityId)))
	end
	d(DIVIDER)
end
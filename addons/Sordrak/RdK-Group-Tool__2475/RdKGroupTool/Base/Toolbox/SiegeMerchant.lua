-- RdK Group Tool SiegeMerchant
-- By @s0rdrak (PC / EU)

RdKGTool.toolbox.sm = RdKGTool.toolbox.sm or {}
local RdKGToolSm = RdKGTool.toolbox.sm
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.chatSystem = RdKGToolUtil.chatSystem or {}
local RdKGToolChat = RdKGToolUtil.chatSystem

RdKGToolSm.constants = RdKGToolSm.constants or {}
RdKGToolSm.constants.ITEM_REPAIR_WALL = 1 -- Does not exist anymore
RdKGToolSm.constants.ITEM_REPAIR_DOOR = 2 -- Does not exist anymore
RdKGToolSm.constants.ITEM_REPAIR_SIEGE = 3 -- Does not exist anymore
RdKGToolSm.constants.ITEM_BALLISTA_FIRE = 4
RdKGToolSm.constants.ITEM_BALLISTA_STONE = 5
RdKGToolSm.constants.ITEM_BALLISTA_LIGHTNING = 6
RdKGToolSm.constants.ITEM_TREBUCHET_FIRE = 7
RdKGToolSm.constants.ITEM_TREBUCHET_STONE = 8
RdKGToolSm.constants.ITEM_TREBUCHET_ICE = 9
RdKGToolSm.constants.ITEM_CATAPULT_MEATBAG = 10
RdKGToolSm.constants.ITEM_CATAPULT_OIL = 11
RdKGToolSm.constants.ITEM_CATAPULT_SCATTERSHOT = 12
RdKGToolSm.constants.ITEM_OIL = 13
RdKGToolSm.constants.ITEM_CAMP = 14
RdKGToolSm.constants.ITEM_RAM = 15
RdKGToolSm.constants.ITEM_KEEP_RECALL = 16
RdKGToolSm.constants.ITEM_DESTRUCTIBLE_REPAIR = 17 -- Does not exist anymore
RdKGToolSm.constants.ITEM_REPAIR_ALL = 18 -- Instead of 1,2,3,17
RdKGToolSm.constants.ITEM_POT_RED = 19
RdKGToolSm.constants.ITEM_POT_GREEN = 20
RdKGToolSm.constants.ITEM_POT_BLUE = 21
RdKGToolSm.constants.ITEM_TRI_POT = 22
RdKGToolSm.constants.ITEM_CF_TACK = 23
RdKGToolSm.constants.ITEM_CF_TREAT = 24
RdKGToolSm.constants.ITEM_CF_BAR = 25
RdKGToolSm.constants.ITEM_CF_BREW = 26
RdKGToolSm.constants.ITEM_CF_TEA = 27
RdKGToolSm.constants.ITEM_CF_TONIC = 28
RdKGToolSm.constants.ITEM_SOUL_GEM = 29
RdKGToolSm.constants.ITEM_SOUL_GEM_EMPTY = 30

RdKGToolSm.constants.PAYMENT_ONLY_AP = 1
RdKGToolSm.constants.PAYMENT_ONLY_GOLD = 2
RdKGToolSm.constants.PAYMENT_FIRST_AP = 3
RdKGToolSm.constants.PAYMENT_FIRST_GOLD = 4

RdKGToolSm.constants.STATE_BUY_SUCCESS = 1
RdKGToolSm.constants.STATE_BUY_FAILED_AP_MISSING = 2
RdKGToolSm.constants.STATE_BUY_FAILED_GOLD_MISSING = 3
RdKGToolSm.constants.STATE_BUY_FAILED_INVENTORY_SLOTS = 4
RdKGToolSm.constants.STATE_BUY_FAILED_ERROR = 5
RdKGToolSm.constants.STATE_BUY_FAILED_ERROR_PAYMENT = 6
RdKGToolSm.constants.STATE_BUY_FAILED_AP_OR_GOLD_MISSING = 7

RdKGToolSm.constants.STACK_NORMAL = 100
RdKGToolSm.constants.STACK_POTS = 200
RdKGToolSm.constants.STACK_WEAPONS = 20

RdKGToolSm.constants.PREFIX = "SM"

RdKGToolSm.callbackName = RdKGTool.addonName .. "SiegeMerchant"

RdKGToolSm.paymentOptions = RdKGToolSm.paymentOptions or {}

RdKGToolSm.config = {}

RdKGToolSm.state = {}
RdKGToolSm.state.initialized = false

RdKGToolSm.state.items = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_REPAIR_WALL] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_REPAIR_DOOR] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_REPAIR_SIEGE] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_BALLISTA_FIRE] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_BALLISTA_STONE] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_BALLISTA_LIGHTNING] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_TREBUCHET_FIRE] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_TREBUCHET_STONE] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_TREBUCHET_ICE] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CATAPULT_MEATBAG] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CATAPULT_OIL] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CATAPULT_SCATTERSHOT] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_OIL] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CAMP] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_RAM] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_KEEP_RECALL] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_DESTRUCTIBLE_REPAIR] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_REPAIR_ALL] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_POT_RED] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_POT_GREEN] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_POT_BLUE] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_TRI_POT] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_TACK] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_TREAT] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_BAR] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_BREW] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_TEA] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_TONIC] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_SOUL_GEM] = {}
RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_SOUL_GEM_EMPTY] = {}

RdKGToolSm.state.priorityList = {}
RdKGToolSm.state.priorityList[1] = RdKGToolSm.constants.ITEM_BALLISTA_STONE
RdKGToolSm.state.priorityList[2] = RdKGToolSm.constants.ITEM_BALLISTA_FIRE
RdKGToolSm.state.priorityList[3] = RdKGToolSm.constants.ITEM_CAMP
RdKGToolSm.state.priorityList[4] = RdKGToolSm.constants.ITEM_KEEP_RECALL
RdKGToolSm.state.priorityList[5] = RdKGToolSm.constants.ITEM_REPAIR_ALL
RdKGToolSm.state.priorityList[6] = RdKGToolSm.constants.ITEM_RAM
RdKGToolSm.state.priorityList[7] = RdKGToolSm.constants.ITEM_CATAPULT_SCATTERSHOT
RdKGToolSm.state.priorityList[8] = RdKGToolSm.constants.ITEM_CATAPULT_MEATBAG
RdKGToolSm.state.priorityList[9] = RdKGToolSm.constants.ITEM_OIL
RdKGToolSm.state.priorityList[10] = RdKGToolSm.constants.ITEM_TREBUCHET_STONE
RdKGToolSm.state.priorityList[11] = RdKGToolSm.constants.ITEM_TREBUCHET_FIRE
RdKGToolSm.state.priorityList[12] = RdKGToolSm.constants.ITEM_BALLISTA_LIGHTNING
RdKGToolSm.state.priorityList[13] = RdKGToolSm.constants.ITEM_TREBUCHET_ICE
RdKGToolSm.state.priorityList[14] = RdKGToolSm.constants.ITEM_CATAPULT_OIL
RdKGToolSm.state.priorityList[15] = RdKGToolSm.constants.ITEM_POT_RED
RdKGToolSm.state.priorityList[16] = RdKGToolSm.constants.ITEM_POT_GREEN
RdKGToolSm.state.priorityList[17] = RdKGToolSm.constants.ITEM_POT_BLUE
RdKGToolSm.state.priorityList[18] = RdKGToolSm.constants.ITEM_REPAIR_SIEGE -- Does not exist anymore
RdKGToolSm.state.priorityList[19] = RdKGToolSm.constants.ITEM_DESTRUCTIBLE_REPAIR -- Does not exist anymore
RdKGToolSm.state.priorityList[20] = RdKGToolSm.constants.ITEM_REPAIR_DOOR -- Does not exist anymore
RdKGToolSm.state.priorityList[21] = RdKGToolSm.constants.ITEM_REPAIR_WALL -- Does not exist anymore
RdKGToolSm.state.priorityList[22] = RdKGToolSm.constants.ITEM_TRI_POT
RdKGToolSm.state.priorityList[23] = RdKGToolSm.constants.ITEM_CF_TACK
RdKGToolSm.state.priorityList[24] = RdKGToolSm.constants.ITEM_CF_TREAT
RdKGToolSm.state.priorityList[25] = RdKGToolSm.constants.ITEM_CF_BAR
RdKGToolSm.state.priorityList[26] = RdKGToolSm.constants.ITEM_CF_BREW
RdKGToolSm.state.priorityList[27] = RdKGToolSm.constants.ITEM_CF_TEA
RdKGToolSm.state.priorityList[28] = RdKGToolSm.constants.ITEM_CF_TONIC
RdKGToolSm.state.priorityList[29] = RdKGToolSm.constants.ITEM_SOUL_GEM
RdKGToolSm.state.priorityList[30] = RdKGToolSm.constants.ITEM_SOUL_GEM_EMPTY

function RdKGToolSm.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolSm.callbackName, RdKGToolSm.OnProfileChanged)
	
	RdKGToolSm.CreateAllianceBasedItemList()
	RdKGToolSm.state.initialized = true
	RdKGToolSm.SetEnabled(RdKGToolSm.smVars.enabled)
end

function RdKGToolSm.GetDefaults()
	local defaults = {}
	defaults.enabled = false
	defaults.sendChatMessages = true
	defaults.items = {}
	defaults.items[RdKGToolSm.constants.ITEM_REPAIR_WALL] = {} -- Does not exist anymore
	defaults.items[RdKGToolSm.constants.ITEM_REPAIR_WALL].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_REPAIR_WALL].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_REPAIR_DOOR] = {} -- Does not exist anymore
	defaults.items[RdKGToolSm.constants.ITEM_REPAIR_DOOR].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_REPAIR_DOOR].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_REPAIR_SIEGE] = {} -- Does not exist anymore
	defaults.items[RdKGToolSm.constants.ITEM_REPAIR_SIEGE].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_REPAIR_SIEGE].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_BALLISTA_FIRE] = {}
	defaults.items[RdKGToolSm.constants.ITEM_BALLISTA_FIRE].minimum = 5
	defaults.items[RdKGToolSm.constants.ITEM_BALLISTA_FIRE].maximum = 10
	defaults.items[RdKGToolSm.constants.ITEM_BALLISTA_STONE] = {}
	defaults.items[RdKGToolSm.constants.ITEM_BALLISTA_STONE].minimum = 5
	defaults.items[RdKGToolSm.constants.ITEM_BALLISTA_STONE].maximum = 10
	defaults.items[RdKGToolSm.constants.ITEM_BALLISTA_LIGHTNING] = {}
	defaults.items[RdKGToolSm.constants.ITEM_BALLISTA_LIGHTNING].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_BALLISTA_LIGHTNING].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_TREBUCHET_FIRE] = {}
	defaults.items[RdKGToolSm.constants.ITEM_TREBUCHET_FIRE].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_TREBUCHET_FIRE].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_TREBUCHET_STONE] = {}
	defaults.items[RdKGToolSm.constants.ITEM_TREBUCHET_STONE].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_TREBUCHET_STONE].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_TREBUCHET_ICE] = {}
	defaults.items[RdKGToolSm.constants.ITEM_TREBUCHET_ICE].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_TREBUCHET_ICE].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_CATAPULT_MEATBAG] = {}
	defaults.items[RdKGToolSm.constants.ITEM_CATAPULT_MEATBAG].minimum = 2
	defaults.items[RdKGToolSm.constants.ITEM_CATAPULT_MEATBAG].maximum = 5
	defaults.items[RdKGToolSm.constants.ITEM_CATAPULT_OIL] = {}
	defaults.items[RdKGToolSm.constants.ITEM_CATAPULT_OIL].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_CATAPULT_OIL].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_CATAPULT_SCATTERSHOT] = {}
	defaults.items[RdKGToolSm.constants.ITEM_CATAPULT_SCATTERSHOT].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_CATAPULT_SCATTERSHOT].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_OIL] = {}
	defaults.items[RdKGToolSm.constants.ITEM_OIL].minimum = 3
	defaults.items[RdKGToolSm.constants.ITEM_OIL].maximum = 5
	defaults.items[RdKGToolSm.constants.ITEM_CAMP] = {}
	defaults.items[RdKGToolSm.constants.ITEM_CAMP].minimum = 2
	defaults.items[RdKGToolSm.constants.ITEM_CAMP].maximum = 3
	defaults.items[RdKGToolSm.constants.ITEM_RAM] = {}
	defaults.items[RdKGToolSm.constants.ITEM_RAM].minimum = 2
	defaults.items[RdKGToolSm.constants.ITEM_RAM].maximum = 5
	defaults.items[RdKGToolSm.constants.ITEM_KEEP_RECALL] = {}
	defaults.items[RdKGToolSm.constants.ITEM_KEEP_RECALL].minimum = 2
	defaults.items[RdKGToolSm.constants.ITEM_KEEP_RECALL].maximum = 5
	defaults.items[RdKGToolSm.constants.ITEM_DESTRUCTIBLE_REPAIR] = {} -- Does not exist anymore
	defaults.items[RdKGToolSm.constants.ITEM_DESTRUCTIBLE_REPAIR].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_DESTRUCTIBLE_REPAIR].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_REPAIR_ALL] = {}
	defaults.items[RdKGToolSm.constants.ITEM_REPAIR_ALL].minimum = 100
	defaults.items[RdKGToolSm.constants.ITEM_REPAIR_ALL].maximum = 100
	defaults.items[RdKGToolSm.constants.ITEM_POT_RED] = {}
	defaults.items[RdKGToolSm.constants.ITEM_POT_RED].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_POT_RED].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_POT_GREEN] = {}
	defaults.items[RdKGToolSm.constants.ITEM_POT_GREEN].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_POT_GREEN].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_POT_BLUE] = {}
	defaults.items[RdKGToolSm.constants.ITEM_POT_BLUE].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_POT_BLUE].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_TRI_POT] = {}
	defaults.items[RdKGToolSm.constants.ITEM_TRI_POT].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_TRI_POT].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_CF_TACK] = {}
	defaults.items[RdKGToolSm.constants.ITEM_CF_TACK].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_CF_TACK].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_CF_TREAT] = {}
	defaults.items[RdKGToolSm.constants.ITEM_CF_TREAT].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_CF_TREAT].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_CF_BAR] = {}
	defaults.items[RdKGToolSm.constants.ITEM_CF_BAR].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_CF_BAR].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_CF_BREW] = {}
	defaults.items[RdKGToolSm.constants.ITEM_CF_BREW].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_CF_BREW].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_CF_TEA] = {}
	defaults.items[RdKGToolSm.constants.ITEM_CF_TEA].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_CF_TEA].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_CF_TONIC] = {}
	defaults.items[RdKGToolSm.constants.ITEM_CF_TONIC].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_CF_TONIC].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_SOUL_GEM] = {}
	defaults.items[RdKGToolSm.constants.ITEM_SOUL_GEM].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_SOUL_GEM].maximum = 0
	defaults.items[RdKGToolSm.constants.ITEM_SOUL_GEM_EMPTY] = {}
	defaults.items[RdKGToolSm.constants.ITEM_SOUL_GEM_EMPTY].minimum = 0
	defaults.items[RdKGToolSm.constants.ITEM_SOUL_GEM_EMPTY].maximum = 0	
	defaults.paymentOption = RdKGToolSm.constants.PAYMENT_ONLY_AP
	return defaults
end

function RdKGToolSm.SetEnabled(value)
	if RdKGToolSm.state.initialized == true and value ~= nil then
		RdKGToolSm.smVars.enabled = value
		if value == true then
			EVENT_MANAGER:RegisterForEvent(RdKGToolSm.callbackName, EVENT_OPEN_STORE, RdKGToolSm.OnOpenStore)
		else
			EVENT_MANAGER:UnregisterForEvent(RdKGToolSm.callbackName, EVENT_OPEN_STORE)
		end
	end
end

--callbacks
function RdKGToolSm.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolSm.smVars = currentProfile.toolbox.sm
		RdKGToolSm.SetEnabled(RdKGToolSm.smVars.enabled)
	end
end

function RdKGToolSm.OnOpenStore(eventCode)
	if eventCode == EVENT_OPEN_STORE and IsInCyrodiil() == true then
		if RdKGToolSm.UpdateShopList() then
			RdKGToolSm.BuyItems()
			RdKGToolSm.DisplaySalesFeedback()
		end
	end
end

--internal functions
function RdKGToolSm.GetMinimum(key)
	return RdKGToolSm.smVars.items[key].minimum
end

function RdKGToolSm.SetMinimum(key, value)
	RdKGToolSm.smVars.items[key].minimum = value
end

function RdKGToolSm.GetMaximum(key)
	return RdKGToolSm.smVars.items[key].maximum
end

function RdKGToolSm.SetMaximum(key, value)
	RdKGToolSm.smVars.items[key].maximum = value
end

--Recall: |H1:item:141731:6:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h

function RdKGToolSm.CreateADItemList()
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_REPAIR_WALL].id = 27138
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_REPAIR_DOOR].id = 27962
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_REPAIR_SIEGE].id = 27112
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_BALLISTA_FIRE].id = 27970
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_BALLISTA_STONE].id = 36567
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_BALLISTA_LIGHTNING].id = 27973
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_TREBUCHET_FIRE].id = 27105
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_TREBUCHET_STONE].id = 44769
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_TREBUCHET_ICE].id = 44768
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CATAPULT_MEATBAG].id = 27964
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CATAPULT_OIL].id = 27967
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CATAPULT_SCATTERSHOT].id = 44770
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_OIL].id = 30359
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CAMP].id = 29533
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_RAM].id = 27136
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_KEEP_RECALL].id = 141731
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_DESTRUCTIBLE_REPAIR].id = 142133
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_REPAIR_ALL].id = 204483
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_POT_RED].id = 71071
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_POT_GREEN].id = 71073
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_POT_BLUE].id = 71072
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_TRI_POT].id = 217946
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_TACK].id = 71074
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_TREAT].id = 71075
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_BAR].id = 71076
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_BREW].id = 71077
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_TEA].id = 71078
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_TONIC].id = 71079
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_SOUL_GEM].id = 33271
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_SOUL_GEM_EMPTY].id = 33265
end

function RdKGToolSm.CreateDCItemList()
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_REPAIR_WALL].id = 27138
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_REPAIR_DOOR].id = 27962
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_REPAIR_SIEGE].id = 27112
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_BALLISTA_FIRE].id = 27972
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_BALLISTA_STONE].id = 36569
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_BALLISTA_LIGHTNING].id = 27975
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_TREBUCHET_FIRE].id = 27115
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_TREBUCHET_STONE].id = 44772
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_TREBUCHET_ICE].id = 44771
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CATAPULT_MEATBAG].id = 27966
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CATAPULT_OIL].id = 27969
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CATAPULT_SCATTERSHOT].id = 44773
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_OIL].id = 30359
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CAMP].id = 29535
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_RAM].id = 27835
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_KEEP_RECALL].id = 141731
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_DESTRUCTIBLE_REPAIR].id = 142133
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_REPAIR_ALL].id = 204483
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_POT_RED].id = 71071
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_POT_GREEN].id = 71073
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_POT_BLUE].id = 71072
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_TRI_POT].id = 217946
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_TACK].id = 71074
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_TREAT].id = 71075
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_BAR].id = 71076
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_BREW].id = 71077
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_TEA].id = 71078
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_TONIC].id = 71079
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_SOUL_GEM].id = 33271
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_SOUL_GEM_EMPTY].id = 33265
end

function RdKGToolSm.CreateEPItemList()
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_REPAIR_WALL].id = 27138
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_REPAIR_DOOR].id = 27962
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_REPAIR_SIEGE].id = 27112
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_BALLISTA_FIRE].id = 27971
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_BALLISTA_STONE].id = 36568
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_BALLISTA_LIGHTNING].id = 27974
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_TREBUCHET_FIRE].id = 27114
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_TREBUCHET_STONE].id = 44776
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_TREBUCHET_ICE].id = 44775
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CATAPULT_MEATBAG].id = 27965
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CATAPULT_OIL].id = 27968
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CATAPULT_SCATTERSHOT].id = 44777
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_OIL].id = 30359
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CAMP].id = 29534
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_RAM].id = 27850
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_KEEP_RECALL].id = 141731
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_DESTRUCTIBLE_REPAIR].id = 142133
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_REPAIR_ALL].id = 204483
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_POT_RED].id = 71071
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_POT_GREEN].id = 71073
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_POT_BLUE].id = 71072
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_TRI_POT].id = 217946
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_TACK].id = 71074
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_TREAT].id = 71075
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_BAR].id = 71076
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_BREW].id = 71077
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_TEA].id = 71078
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_CF_TONIC].id = 71079
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_SOUL_GEM].id = 33271
	RdKGToolSm.state.items[RdKGToolSm.constants.ITEM_SOUL_GEM_EMPTY].id = 33265
end

function RdKGToolSm.CreateAllianceBasedItemList()
	local alliance = GetUnitAlliance("player")
	if alliance == ALLIANCE_ALDMERI_DOMINION then
		RdKGToolSm.CreateADItemList()
	elseif alliance == ALLIANCE_EBONHEART_PACT then
		RdKGToolSm.CreateEPItemList()
	elseif alliance == ALLIANCE_DAGGERFALL_COVENANT then
		RdKGToolSm.CreateDCItemList()
	end
end

function RdKGToolSm.ClearStateEntries()
		for siegeIndex = 1, #RdKGToolSm.state.items do
		RdKGToolSm.state.items[siegeIndex].shopEntryGold = nil
		RdKGToolSm.state.items[siegeIndex].shopEntryAP = nil
		RdKGToolSm.state.items[siegeIndex].shopIndexGold = nil
		RdKGToolSm.state.items[siegeIndex].shopIndexAP = nil
		RdKGToolSm.state.items[siegeIndex].buyMax = nil
		RdKGToolSm.state.items[siegeIndex].buyMin = nil
		RdKGToolSm.state.items[siegeIndex].boughtGold = nil
		RdKGToolSm.state.items[siegeIndex].boughtAP = nil
		RdKGToolSm.state.items[siegeIndex].stack = 0
		RdKGToolSm.state.items[siegeIndex].statusCode = nil
		RdKGToolSm.state.items[siegeIndex].boughtItems = 0
	end
end

function RdKGToolSm.DisplaySalesFeedback()
	local showErrorUnknownMessage = false
	local showErrorPaymentOptionMessage = false
	local showErrorInventoryMessage = false
	local showErrorAPMessage = false
	local showErrorGoldMessage = false
	local showErrorApOrGoldMessage = false
	local showSuccessMessage = false

	for siegeIndex = 1, #RdKGToolSm.state.items do
		if RdKGToolSm.state.items[siegeIndex].statusCode == RdKGToolSm.constants.STATE_BUY_SUCCESS then
			showSuccessMessage = true
		elseif RdKGToolSm.state.items[siegeIndex].statusCode == RdKGToolSm.constants.STATE_BUY_FAILED_INVENTORY_SLOTS then
			showErrorInventoryMessage = true
		elseif RdKGToolSm.state.items[siegeIndex].statusCode == RdKGToolSm.constants.STATE_BUY_FAILED_AP_MISSING then
			showErrorAPMessage = true
		elseif RdKGToolSm.state.items[siegeIndex].statusCode == RdKGToolSm.constants.STATE_BUY_FAILED_GOLD_MISSING then
			showErrorGoldMessage = true
		elseif RdKGToolSm.state.items[siegeIndex].statusCode == RdKGToolSm.constants.STATE_BUY_FAILED_AP_OR_GOLD_MISSING then
			showErrorApOrGoldMessage = true
		elseif RdKGToolSm.state.items[siegeIndex].statusCode == RdKGToolSm.constants.STATE_BUY_FAILED_ERROR_PAYMENT then
			showErrorPaymentOptionMessage = true
		elseif RdKGToolSm.state.items[siegeIndex].statusCode == RdKGToolSm.constants.STATE_BUY_FAILED_ERROR then
			showErrorUnknownMessage = true
		end
	end
	if showSuccessMessage == true and showErrorGoldMessage == false and showErrorAPMessage == false and showErrorInventoryMessage == false and showErrorPaymentOptionMessage == false and showErrorUnknownMessage == false and showErrorApOrGoldMessage == false then
		RdKGToolChat.SendChatMessage(RdKGToolSm.constants.SUCCESS_MESSAGE, RdKGToolSm.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_NORMAL, RdKGToolSm.smVars.sendChatMessages)
	else
		if showErrorGoldMessage == true then
			RdKGToolChat.SendChatMessage(RdKGToolSm.constants.ERROR_PAYMENT_NOT_ENOUGH_GOLD, RdKGToolSm.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_WARNING, RdKGToolSm.smVars.sendChatMessages)
		end
		if showErrorAPMessage == true then
			RdKGToolChat.SendChatMessage(RdKGToolSm.constants.ERROR_PAYMENT_NOT_ENOUGH_AP, RdKGToolSm.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_WARNING, RdKGToolSm.smVars.sendChatMessages)
		end
		if showErrorApOrGoldMessage == true then
			RdKGToolChat.SendChatMessage(RdKGToolSm.constants.ERROR_PAYMENT_NOT_ENOUGH_AP_OR_GOLD, RdKGToolSm.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_WARNING, RdKGToolSm.smVars.sendChatMessages)
		end
		if showErrorInventoryMessage == true then
			RdKGToolChat.SendChatMessage(RdKGToolSm.constants.ERROR_PAYMENT_NOT_ENOUGH_INVENTORY_SLOTS, RdKGToolSm.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_WARNING, RdKGToolSm.smVars.sendChatMessages)
		end
		if showErrorPaymentOptionMessage == true then
			RdKGToolChat.SendChatMessage(RdKGToolSm.constants.ERROR_UNKNOWN_PAYMENT_OPTION, RdKGToolSm.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_WARNING, RdKGToolSm.smVars.sendChatMessages)
		end
		if showErrorUnknownMessage == true then
			RdKGToolChat.SendChatMessage(RdKGToolSm.constants.ERROR_UNKNOWN, RdKGToolSm.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_WARNING, RdKGToolSm.smVars.sendChatMessages)
		end		
	end
	--RdKGToolChat.SendChatMessage(RdKGToolSm.constants.ERROR_UNKNOWN, RdKGToolSm.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_WARNING, RdKGToolSm.smVars.sendChatMessages)
end

function RdKGToolSm.IsItemStackable(itemId)
	if itemId == 27138 or itemId == 27962 or itemId == 27112 or itemId == 141731 or
	   itemId == 29534 or itemId == 29535 or itemId == 29533 or itemId == 142133 or 
	   itemId == 27971 or itemId == 36568 or itemId == 27974 or itemId == 27114 or
	   itemId == 44776 or itemId == 44775 or itemId == 27965 or itemId == 27968 or
	   itemId == 44777 or itemId == 30359 or itemId == 27850 or itemId == 204483 or
	   itemId == 217946 or itemId == 71074 or itemId == 71075 or itemId == 71076 or
	   itemId == 71077 or itemId == 71078 or itemId == 71079 or itemId == 33271 or
	   itemId == 33265 then
		return true
	else
		return false
	end
end

function RdKGToolSm.GetMaxStackSize(itemId)
	if itemId == 27138 or itemId == 27962 or itemId == 27112 or itemId == 141731 or
	   itemId == 29534 or itemId == 29535 or itemId == 29533 or itemId == 142133 or 
	   itemId == 204483 or itemId == 71074 or itemId == 71075 or itemId == 71076 or 
	   itemId == 71077 or itemId == 71078 or itemId == 71079 then
		return RdKGToolSm.constants.STACK_NORMAL
	elseif itemId == 71071 or itemId == 71072 or itemId == 71073 or itemId == 217946 or
		   itemId == 33271 or itemId == 33265 then
		return RdKGToolSm.constants.STACK_POTS
	else
		return RdKGToolSm.constants.STACK_WEAPONS
	end
end

function RdKGToolSm.GetQuantity(storeIndex, paymentOption, quantity, siegeIndex)
	local statusCode = RdKGToolSm.constants.STATE_BUY_SUCCESS
	local slotSize = 0
	--d("siegeIndex: " .. siegeIndex)
	if quantity < 0 then
		return statusCode, 0, slotSize
	end
	if storeIndex.available ~= nil and storeIndex.costs ~= nil then
		local maxItems = storeIndex.available / storeIndex.costs
		local maxQuantity = quantity
		
		if RdKGToolSm.IsItemStackable(RdKGToolSm.state.items[siegeIndex].id) == true then
			local maxStackSize = RdKGToolSm.GetMaxStackSize(RdKGToolSm.state.items[siegeIndex].id)
			--local freeSpace = RdKGToolSm.state.itemSlots * 100 + (100 - (RdKGToolSm.state.items[siegeIndex].stack % 100))
			local freeSpace = RdKGToolSm.state.itemSlots * maxStackSize --+ (100 - (RdKGToolSm.state.items[siegeIndex].stack % 100))
			if freeSpace < quantity then
				--not enough free space available.
				maxQuantity = freeSpace
				statusCode = RdKGToolSm.constants.STATE_BUY_FAILED_INVENTORY_SLOTS
			end
			if maxItems < maxQuantity then
				--not enough ap or gold
				if paymentOption == RdKGToolSm.constants.PAYMENT_ONLY_AP then
					statusCode = RdKGToolSm.constants.STATE_BUY_FAILED_AP_MISSING
				elseif paymentOption == RdKGToolSm.constants.PAYMENT_ONLY_GOLD then
					statusCode = RdKGToolSm.constants.STATE_BUY_FAILED_GOLD_MISSING
				end
				maxQuantity = maxItem
			end
			--slotSize = maxQuantity - (100 - (maxQuantity % 100))
			slotSize = maxQuantity -- - (100 - (maxQuantity % 100))
			if maxQuantity == nil then
				maxQuantity = 0
			end
			if slotSize == nil or slotSize < 0 then
				slotSize = 0
			else
				local incompleteStacke = false
				if slotSize % maxStackSize ~= 0 then
					incompleteStacke = true
				end
				slotSize = (slotSize - (slotSize % maxStackSize)) / maxStackSize
				if incompleteStacke == true then
					slotSize = slotSize + 1
				end
			end

		else
			if RdKGToolSm.state.itemSlots < quantity then
				--not enough free space available.
				maxQuantity = RdKGToolSm.state.itemSlots
				slotSize = maxQuantity
				statusCode = RdKGToolSm.constants.STATE_BUY_FAILED_INVENTORY_SLOTS
			end
			if maxItems < maxQuantity then
				--not enough ap or gold
				if paymentOption == RdKGToolSm.constants.PAYMENT_ONLY_AP then
					statusCode = RdKGToolSm.constants.STATE_BUY_FAILED_AP_MISSING
				elseif paymentOption == RdKGToolSm.constants.PAYMENT_ONLY_GOLD then
					statusCode = RdKGToolSm.constants.STATE_BUY_FAILED_GOLD_MISSING
				end
				
				maxQuantity = maxItems
				slotSize = maxItems
			end
			
		end
		return statusCode, maxQuantity, slotSize
	else
		--d(slotSize)
		return statusCode, -1, slotSize
	end
end

function RdKGToolSm.BuySpecificItem(siegeIndex, quantity)
	local statusCode = RdKGToolSm.constants.STATE_BUY_SUCCESS
	local boughtItems = 0
	if quantity > 0 then
		local ap = GetAlliancePoints()
		local gold = GetCurrentMoney()
		local buyItem = false
		local simpleStoreIndex = {}
		local complexStoreIndex = {}
		
		if RdKGToolSm.smVars.paymentOption == RdKGToolSm.constants.PAYMENT_ONLY_AP then
			simpleStoreIndex.costs = RdKGToolSm.state.items[siegeIndex].shopEntryAP
			simpleStoreIndex.available = ap
			simpleStoreIndex.index = RdKGToolSm.state.items[siegeIndex].shopIndexAP
			simpleStoreIndex.error = RdKGToolSm.constants.ERROR_PAYMENT_NOT_ENOUGH_AP
		elseif RdKGToolSm.smVars.paymentOption == RdKGToolSm.constants.PAYMENT_ONLY_GOLD then
			simpleStoreIndex.costs = RdKGToolSm.state.items[siegeIndex].shopEntryGold
			simpleStoreIndex.available = gold
			simpleStoreIndex.index = RdKGToolSm.state.items[siegeIndex].shopIndexGold
			simpleStoreIndex.error = RdKGToolSm.constants.ERROR_PAYMENT_NOT_ENOUGH_GOLD
		elseif RdKGToolSm.smVars.paymentOption == RdKGToolSm.constants.PAYMENT_FIRST_AP or RdKGToolSm.smVars.paymentOption == RdKGToolSm.constants.PAYMENT_FIRST_GOLD then
			complexStoreIndex.ap = {}
			complexStoreIndex.ap.costs = RdKGToolSm.state.items[siegeIndex].shopEntryAP
			complexStoreIndex.ap.available = ap
			complexStoreIndex.ap.index = RdKGToolSm.state.items[siegeIndex].shopIndexAP
			complexStoreIndex.ap.error = RdKGToolSm.constants.ERROR_PAYMENT_NOT_ENOUGH_AP
			complexStoreIndex.gold = {}
			complexStoreIndex.gold.costs = RdKGToolSm.state.items[siegeIndex].shopEntryGold
			complexStoreIndex.gold.available = gold
			complexStoreIndex.gold.index = RdKGToolSm.state.items[siegeIndex].shopIndexGold
			complexStoreIndex.gold.error = RdKGToolSm.constants.ERROR_PAYMENT_NOT_ENOUGH_GOLD
			if complexStoreIndex.ap.costs ~= nil then
				RdKGToolChat.SendChatMessage("Item: " .. siegeIndex .. ", Quantity: " .. quantity .. ", AP: " .. complexStoreIndex.ap.costs, RdKGToolSm.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG, RdKGToolSm.smVars.sendChatMessages)
			end
			if complexStoreIndex.gold.costs ~= nil then
				RdKGToolChat.SendChatMessage("Item: " .. siegeIndex .. ", Quantity: " .. quantity .. ", Gold: " .. complexStoreIndex.gold.costs, RdKGToolSm.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG, RdKGToolSm.smVars.sendChatMessages)
			end
		else
			statusCode = RdKGToolSm.constants.STATE_BUY_FAILED_ERROR_PAYMENT
		end
		RdKGToolChat.SendChatMessage("Buy: nil, Item: " .. siegeIndex .. ", Quantity: " .. quantity, RdKGToolSm.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG, RdKGToolSm.smVars.sendChatMessages)
		if simpleStoreIndex.costs ~= nil or (complexStoreIndex.gold ~= nil and complexStoreIndex.ap ~= nil and (complexStoreIndex.gold.costs ~= nil or complexStoreIndex.ap.costs ~= nil)) then
			buyItem = true
			RdKGToolChat.SendChatMessage("Buy: true, Item: " .. siegeIndex .. ", Quantity: " .. quantity, RdKGToolSm.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG, RdKGToolSm.smVars.sendChatMessages)
		end
		--d("method called on siegeIndex: " .. siegeIndex)
		if buyItem == true then
			if simpleStoreIndex.costs ~= nil and simpleStoreIndex.available ~= nil then
				--AP or Gold
				local status, maxQuantity, stackSize = RdKGToolSm.GetQuantity(simpleStoreIndex, RdKGToolSm.smVars.paymentOption, quantity, siegeIndex)
				statusCode = status
				
				if statusCode ~= RdKGToolSm.constants.STATE_BUY_FAILED_ERROR_PAYMENT and statusCode ~= RdKGToolSm.constants.STATE_BUY_FAILED_ERROR then
					boughtItems = maxQuantity
					BuyStoreItem(simpleStoreIndex.index, maxQuantity)
					RdKGToolSm.state.itemSlots = RdKGToolSm.state.itemSlots - stackSize
					RdKGToolSm.state.items[siegeIndex].stack = RdKGToolSm.state.items[siegeIndex].stack + maxQuantity
					--d("BuyStoreItem: " .. siegeIndex .. " -> " .. maxQuantity)
				end
			elseif complexStoreIndex.ap ~= nil and complexStoreIndex.gold ~= nil then 
				--AP and Gold
				if RdKGToolSm.smVars.paymentOption == RdKGToolSm.constants.PAYMENT_FIRST_AP then
					--First AP
					local buyForGold = false
					local status, maxQuantity, stackSize = RdKGToolSm.GetQuantity(complexStoreIndex.ap, RdKGToolSm.constants.PAYMENT_ONLY_AP, quantity, siegeIndex)
					if maxQuantity > 0 and statusCode ~= RdKGToolSm.constants.STATE_BUY_FAILED_ERROR_PAYMENT and statusCode ~= RdKGToolSm.constants.STATE_BUY_FAILED_ERROR then
						boughtItems = maxQuantity
						BuyStoreItem(complexStoreIndex.ap.index, maxQuantity)
						RdKGToolSm.state.itemSlots = RdKGToolSm.state.itemSlots - stackSize
						RdKGToolSm.state.items[siegeIndex].stack = RdKGToolSm.state.items[siegeIndex].stack + maxQuantity
					end
					if status == RdKGToolSm.constants.STATE_BUY_SUCCESS and maxQuantity == -1 or status == RdKGToolSm.constants.STATE_BUY_FAILED_AP_MISSING then
						buyForGold = true
					else
						statusCode = status
					end
					
					--Then Gold
					if buyForGold == true then
						status, maxQuantity, stackSize = RdKGToolSm.GetQuantity(complexStoreIndex.gold, RdKGToolSm.constants.PAYMENT_ONLY_GOLD, quantity - boughtItems, siegeIndex)
						statusCode = status
						if maxQuantity > 0 and statusCode ~= RdKGToolSm.constants.STATE_BUY_FAILED_ERROR_PAYMENT and statusCode ~= RdKGToolSm.constants.STATE_BUY_FAILED_ERROR then
							boughtItems = boughtItems + maxQuantity
							BuyStoreItem(complexStoreIndex.gold.index, maxQuantity)
							RdKGToolSm.state.itemSlots = RdKGToolSm.state.itemSlots - stackSize
							RdKGToolSm.state.items[siegeIndex].stack = RdKGToolSm.state.items[siegeIndex].stack + maxQuantity
						end
						if statusCode == RdKGToolSm.constants.STATE_BUY_FAILED_GOLD_MISSING then
							statusCode = RdKGToolSm.constants.STATE_BUY_FAILED_AP_MISSING
						end
					end
					
				elseif RdKGToolSm.smVars.paymentOption == RdKGToolSm.constants.PAYMENT_FIRST_GOLD then
					--First Gold
					--d("fsg: " .. quantity)
					local buyForAP = false
					local status, maxQuantity, stackSize = RdKGToolSm.GetQuantity(complexStoreIndex.gold, RdKGToolSm.constants.PAYMENT_ONLY_GOLD, quantity, siegeIndex)
					if maxQuantity > 0 and statusCode ~= RdKGToolSm.constants.STATE_BUY_FAILED_ERROR_PAYMENT and statusCode ~= RdKGToolSm.constants.STATE_BUY_FAILED_ERROR then
						boughtItems = maxQuantity
						BuyStoreItem(complexStoreIndex.gold.index, maxQuantity)
						RdKGToolSm.state.itemSlots = RdKGToolSm.state.itemSlots - stackSize
						RdKGToolSm.state.items[siegeIndex].stack = RdKGToolSm.state.items[siegeIndex].stack + maxQuantity
						--d("bought")
					end
					if status == RdKGToolSm.constants.STATE_BUY_SUCCESS and maxQuantity == -1 or status == RdKGToolSm.constants.STATE_BUY_FAILED_GOLD_MISSING then
						buyForAP = true
					else
						statusCode = status
					end
					--d(statusCode)
					--Then AP
					if buyForAP == true then
						status, maxQuantity, stackSize = RdKGToolSm.GetQuantity(complexStoreIndex.ap, RdKGToolSm.constants.PAYMENT_ONLY_AP, quantity - boughtItems, siegeIndex)
						statusCode = status
						if maxQuantity > 0 and statusCode ~= RdKGToolSm.constants.STATE_BUY_FAILED_ERROR_PAYMENT and statusCode ~= RdKGToolSm.constants.STATE_BUY_FAILED_ERROR then
							boughtItems = boughtItems + maxQuantity
							BuyStoreItem(complexStoreIndex.ap.index, maxQuantity)
							RdKGToolSm.state.itemSlots = RdKGToolSm.state.itemSlots - maxQuantity
							RdKGToolSm.state.items[siegeIndex].stack = RdKGToolSm.state.items[siegeIndex].stack + stackSize
						end
						if statusCode == RdKGToolSm.constants.STATE_BUY_FAILED_AP_MISSING then
							statusCode = RdKGToolSm.constants.STATE_BUY_FAILED_AP_OR_GOLD_MISSING
						end
					end
					
				end
			else
				--Something is off
				statusCode = RdKGToolSm.constants.STATE_BUY_FAILED_ERROR
			end
		end
	end
	return statusCode, boughtItems
end

function RdKGToolSm.BuyItems()
	--Min
	RdKGToolSm.state.itemSlots = GetNumBagFreeSlots(BAG_BACKPACK)
	RdKGToolSm.UpdateInventoryList()
	RdKGToolSm.UpdatePersonalShoppingList()
	local validStatusCode = true
	for i = 1, #RdKGToolSm.state.priorityList do
		local siegeIndex = RdKGToolSm.state.priorityList[i]
		local statusCode, boughtItems = RdKGToolSm.BuySpecificItem(siegeIndex, RdKGToolSm.state.items[siegeIndex].buyMin)
		RdKGToolSm.state.items[siegeIndex].statusCode = statusCode
		RdKGToolSm.state.items[siegeIndex].boughtItems = boughtItems
		if statusCode ~= RdKGToolSm.constants.STATE_BUY_SUCCESS then
			validStatusCode = false
		end
	end
	--d(validStatusCode)
	--Max
	if validStatusCode == true then
		--RdKGToolSm.UpdateInventoryList()
		RdKGToolSm.UpdatePersonalShoppingList()
		for i = 1, #RdKGToolSm.state.priorityList do
			local siegeIndex = RdKGToolSm.state.priorityList[i]
			local statusCode, boughtItems = RdKGToolSm.BuySpecificItem(siegeIndex, RdKGToolSm.state.items[siegeIndex].buyMax)
			RdKGToolSm.state.items[siegeIndex].statusCode = statusCode
			RdKGToolSm.state.items[siegeIndex].boughtItems = RdKGToolSm.state.items[siegeIndex].boughtItems + boughtItems
		end
	end
end

function RdKGToolSm.UpdatePersonalShoppingList()
	for i = 1, #RdKGToolSm.smVars.items do
		RdKGToolSm.state.items[i].buyMax = RdKGToolSm.smVars.items[i].maximum - RdKGToolSm.state.items[i].stack
		RdKGToolSm.state.items[i].buyMin = RdKGToolSm.smVars.items[i].minimum - RdKGToolSm.state.items[i].stack
	end
end

function RdKGToolSm.UpdateShopList()
	RdKGToolSm.ClearStateEntries()
	local shopIdentified = false
	for itemIndex = 1, GetNumStoreItems() do
		local icon, name, stack, price, sellPrice, meetsRequirementsToBuy, meetsRequirementsToUse, quality, questNameColor, currencyType1, currencyQuantity1, currencyType2, currencyQuantity2, entryType = GetStoreEntryInfo(itemIndex)
		local _, _, _, itemId = ZO_LinkHandler_ParseLink(GetStoreItemLink(itemIndex))
		if itemId ~= nil then
			itemId = tonumber(itemId)
			--d(name .. ": " .. itemId .. ", " .. price .. ", " .. sellPrice .. ", " .. currencyQuantity1 .. currencyType1 .. ", " .. currencyQuantity2 .. currencyType2 .. ", " .. entryType)
			--d(#RdKGToolSm.state.items)
			for siegeIndex = 1, #RdKGToolSm.state.items do
				--d(RdKGToolSm.state.items[siegeIndex].id)
				--d(itemId)
				--d(RdKGToolSm.state.items[siegeIndex].id == itemId)
				if RdKGToolSm.state.items[siegeIndex].id == itemId then
					--d("item identified: " .. price .. ", " .. currencyQuantity1)
					shopIdentified = true
					if price ~= nil and price ~= 0 then
						RdKGToolSm.state.items[siegeIndex].shopEntryGold = price
						RdKGToolSm.state.items[siegeIndex].shopIndexGold = itemIndex
					elseif currencyQuantity1 ~= nil and currencyQuantity1 ~= 0 then
						RdKGToolSm.state.items[siegeIndex].shopEntryAP = currencyQuantity1
						RdKGToolSm.state.items[siegeIndex].shopIndexAP = itemIndex
					end
					break
				end
			end
		end			
	end
	return shopIdentified
end

function RdKGToolSm.UpdateInventoryList()
	for siegeIndex = 1, #RdKGToolSm.state.items do
		RdKGToolSm.state.items[siegeIndex].stack = 0
	end
	for invId = 0, GetBagSize(BAG_BACKPACK) do
		local _, _, _, itemId = ZO_LinkHandler_ParseLink(GetItemLink(BAG_BACKPACK, invId))
		--d(itemId)
		itemId = tonumber(itemId)
		
		if itemId ~= nil then
			local stack = GetSlotStackSize(BAG_BACKPACK, invId)
			for siegeIndex = 1, #RdKGToolSm.state.items do
				if RdKGToolSm.state.items[siegeIndex].id == itemId then
					RdKGToolSm.state.items[siegeIndex].stack = RdKGToolSm.state.items[siegeIndex].stack + stack
					break
				end
			end			
		end
	end
end

--menu interactions
function RdKGToolSm.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.SM_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SM_ENABLED,
					getFunc = RdKGToolSm.GetSmEnabled,
					setFunc = RdKGToolSm.SetSmEnabled
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SM_SEND_CHAT_MESSAGES,
					getFunc = RdKGToolSm.GetSmSendChatMessages,
					setFunc = RdKGToolSm.SetSmSendChatMessages
				},
				[3] = {
					type = "divider",
					width = "full"
				},
				[4] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_REPAIR_ALL,
					width = "full"
				},
				[5] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 1000,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemRepairAllMin,
					setFunc = RdKGToolSm.SetSmItemRepairAllMin,
					width = "full",
					default = 5
				},
				[6] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemRepairAllMax,
					setFunc = RdKGToolSm.SetSmItemRepairAllMax,
					width = "full",
					default = 10
				},
				[7] = {
					type = "divider",
					width = "full"
				},
				[8] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_BALLISTA_FIRE,
					width = "full"
				},
				[9] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemBallistaFireMin,
					setFunc = RdKGToolSm.SetSmItemBallistaFireMin,
					width = "full",
					default = 5
				},
				[10] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemBallistaFireMax,
					setFunc = RdKGToolSm.SetSmItemBallistaFireMax,
					width = "full",
					default = 10
				},
				[11] = {
					type = "divider",
					width = "full"
				},
				[12] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_BALLISTA_STONE,
					width = "full"
				},
				[13] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemBallistaMin,
					setFunc = RdKGToolSm.SetSmItemBallistaMin,
					width = "full",
					default = 5
				},
				[14] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemBallistaMax,
					setFunc = RdKGToolSm.SetSmItemBallistaMax,
					width = "full",
					default = 10
				},
				[15] = {
					type = "divider",
					width = "full"
				},
				[16] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_BALLISTA_LIGHTNING,
					width = "full"
				},
				[17] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemBallistaLightningMin,
					setFunc = RdKGToolSm.SetSmItemBallistaLightningMin,
					width = "full",
					default = 0
				},
				[18] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemBallistaLightningMax,
					setFunc = RdKGToolSm.SetSmItemBallistaLightningMax,
					width = "full",
					default = 0
				},
				[19] = {
					type = "divider",
					width = "full"
				},
				[20] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_TREBUCHET_FIRE,
					width = "full"
				},
				[21] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemTrebuchetFireMin,
					setFunc = RdKGToolSm.SetSmItemTrebuchetFireMin,
					width = "full",
					default = 0
				},
				[22] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemTrebuchetFireMax,
					setFunc = RdKGToolSm.SetSmItemTrebuchetFireMax,
					width = "full",
					default = 0
				},
				[23] = {
					type = "divider",
					width = "full"
				},
				[24] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_TREBUCHET_STONE,
					width = "full"
				},
				[25] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemTrebuchetStoneMin,
					setFunc = RdKGToolSm.SetSmItemTrebuchetStoneMin,
					width = "full",
					default = 0
				},
				[26] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemTrebuchetStoneMax,
					setFunc = RdKGToolSm.SetSmItemTrebuchetStoneMax,
					width = "full",
					default = 0
				},
				[27] = {
					type = "divider",
					width = "full"
				},
				[28] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_TREBUCHET_ICE,
					width = "full"
				},
				[29] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemTrebuchetIceMin,
					setFunc = RdKGToolSm.SetSmItemTrebuchetIceMin,
					width = "full",
					default = 0
				},
				[30] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemTrebuchetIceMax,
					setFunc = RdKGToolSm.SetSmItemTrebuchetIceMax,
					width = "full",
					default = 0
				},
				[31] = {
					type = "divider",
					width = "full"
				},
				[32] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_CATAPULT_MEATBAG,
					width = "full"
				},
				[33] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemCatapultMeatbagMin,
					setFunc = RdKGToolSm.SetSmItemCatapultMeatbagMin,
					width = "full",
					default = 2
				},
				[34] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemCatapultMeatbagMax,
					setFunc = RdKGToolSm.SetSmItemCatapultMeatbagMax,
					width = "full",
					default = 5
				},
				[35] = {
					type = "divider",
					width = "full"
				},
				[36] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_CATAPULT_OIL,
					width = "full"
				},
				[37] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemCatapultOilMin,
					setFunc = RdKGToolSm.SetSmItemCatapultOilMin,
					width = "full",
					default = 0
				},
				[38] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemCatapultOilMax,
					setFunc = RdKGToolSm.SetSmItemCatapultOilMax,
					width = "full",
					default = 0
				},
				[39] = {
					type = "divider",
					width = "full"
				},
				[40] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_CATAPULT_SCATTERSHOT,
					width = "full"
				},
				[41] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemCatapultScattershotMin,
					setFunc = RdKGToolSm.SetSmItemCatapultScattershotMin,
					width = "full",
					default = 0
				},
				[42] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemCatapultScattershotMax,
					setFunc = RdKGToolSm.SetSmItemCatapultScattershotMax,
					width = "full",
					default = 0
				},
				[43] = {
					type = "divider",
					width = "full"
				},
				[44] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_OIL,
					width = "full"
				},
				[45] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemOilMin,
					setFunc = RdKGToolSm.SetSmItemOilMin,
					width = "full",
					default = 3
				},
				[46] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemOilMax,
					setFunc = RdKGToolSm.SetSmItemOilMax,
					width = "full",
					default = 5
				},
				[47] = {
					type = "divider",
					width = "full"
				},
				[48] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_CAMP,
					width = "full"
				},
				[49] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 25,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemCampMin,
					setFunc = RdKGToolSm.SetSmItemCampMin,
					width = "full",
					default = 2
				},
				[50] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 25,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemCampMax,
					setFunc = RdKGToolSm.SetSmItemCampMax,
					width = "full",
					default = 3
				},
				[51] = {
					type = "divider",
					width = "full"
				},
				[52] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_RAM,
					width = "full"
				},
				[53] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemRamMin,
					setFunc = RdKGToolSm.SetSmItemRamMin,
					width = "full",
					default = 2
				},
				[54] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemRamMax,
					setFunc = RdKGToolSm.SetSmItemRamMax,
					width = "full",
					default = 5
				},
				[55] = {
					type = "divider",
					width = "full"
				},
				[56] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_KEEP_RECALL,
					width = "full"
				},
				[57] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemKeepRecallMin,
					setFunc = RdKGToolSm.SetSmItemKeepRecallMin,
					width = "full",
					default = 2
				},
				[58] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemKeepRecallMax,
					setFunc = RdKGToolSm.SetSmItemKeepRecallMax,
					width = "full",
					default = 5
				},
				[59] = {
					type = "divider",
					width = "full"
				},
				[60] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_POT_RED,
					width = "full"
				},
				[61] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemPotRedMin,
					setFunc = RdKGToolSm.SetSmItemPotRedMin,
					width = "full",
					default = 0
				},
				[62] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemPotRedMax,
					setFunc = RdKGToolSm.SetSmItemPotRedMax,
					width = "full",
					default = 0
				},
				[63] = {
					type = "divider",
					width = "full"
				},
				[64] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_POT_GREEN,
					width = "full"
				},
				[65] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemPotGreenMin,
					setFunc = RdKGToolSm.SetSmItemPotGreenMin,
					width = "full",
					default = 0
				},
				[66] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemPotGreenMax,
					setFunc = RdKGToolSm.SetSmItemPotGreenMax,
					width = "full",
					default = 0
				},
				[67] = {
					type = "divider",
					width = "full"
				},
				[68] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_POT_BLUE,
					width = "full"
				},
				[69] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemPotBlueMin,
					setFunc = RdKGToolSm.SetSmItemPotBlueMin,
					width = "full",
					default = 0
				},
				[70] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemPotBlueMax,
					setFunc = RdKGToolSm.SetSmItemPotBlueMax,
					width = "full",
					default = 0
				},
				[71] = {
					type = "divider",
					width = "full"
				},
				[72] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_TRI_POT,
					width = "full"
				},
				[73] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemTriPotMin,
					setFunc = RdKGToolSm.SetSmItemTriPotMin,
					width = "full",
					default = 0
				},
				[74] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemTriPotMax,
					setFunc = RdKGToolSm.SetSmItemTriPotMax,
					width = "full",
					default = 0
				},
				[75] = {
					type = "divider",
					width = "full"
				},
				[76] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_CF_TACK,
					width = "full"
				},
				[77] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemCfTackMin,
					setFunc = RdKGToolSm.SetSmItemCfTackMin,
					width = "full",
					default = 0
				},
				[78] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemCfTackMax,
					setFunc = RdKGToolSm.SetSmItemCfTackMax,
					width = "full",
					default = 0
				},
				[79] = {
					type = "divider",
					width = "full"
				},
				[80] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_CF_TREAT,
					width = "full"
				},
				[81] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemCfTreatMin,
					setFunc = RdKGToolSm.SetSmItemCfTreatMin,
					width = "full",
					default = 0
				},
				[82] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemCfTreatMax,
					setFunc = RdKGToolSm.SetSmItemCfTreatMax,
					width = "full",
					default = 0
				},
				[83] = {
					type = "divider",
					width = "full"
				},
				[84] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_CF_BAR,
					width = "full"
				},
				[85] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemCfBarMin,
					setFunc = RdKGToolSm.SetSmItemCfBarMin,
					width = "full",
					default = 0
				},
				[86] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemCfBarMax,
					setFunc = RdKGToolSm.SetSmItemCfBarMax,
					width = "full",
					default = 0
				},
				[87] = {
					type = "divider",
					width = "full"
				},
				[88] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_CF_BREW,
					width = "full"
				},
				[89] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemCfBrewMin,
					setFunc = RdKGToolSm.SetSmItemCfBrewMin,
					width = "full",
					default = 0
				},
				[90] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemCfBrewMax,
					setFunc = RdKGToolSm.SetSmItemCfBrewMax,
					width = "full",
					default = 0
				},
				[91] = {
					type = "divider",
					width = "full"
				},
				[92] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_CF_TEA,
					width = "full"
				},
				[93] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemCfTeaMin,
					setFunc = RdKGToolSm.SetSmItemCfTeaMin,
					width = "full",
					default = 0
				},
				[94] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemCfTeaMax,
					setFunc = RdKGToolSm.SetSmItemCfTeaMax,
					width = "full",
					default = 0
				},
				[95] = {
					type = "divider",
					width = "full"
				},
				[96] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_CF_TONIC,
					width = "full"
				},
				[97] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemCfTonicMin,
					setFunc = RdKGToolSm.SetSmItemCfTonicMin,
					width = "full",
					default = 0
				},
				[98] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemCfTonicMax,
					setFunc = RdKGToolSm.SetSmItemCfTonicMax,
					width = "full",
					default = 0
				},
				[99] = {
					type = "divider",
					width = "full"
				},
				[100] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_SOUL_GEM,
					width = "full"
				},
				[101] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemSoulGemMin,
					setFunc = RdKGToolSm.SetSmItemSoulGemMin,
					width = "full",
					default = 0
				},
				[102] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemSoulGemMax,
					setFunc = RdKGToolSm.SetSmItemSoulGemMax,
					width = "full",
					default = 0
				},
				[103] = {
					type = "divider",
					width = "full"
				},
				[104] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_SOUL_GEM_EMPTY,
					width = "full"
				},
				[105] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemSoulGemEmptyMin,
					setFunc = RdKGToolSm.SetSmItemSoulGemEmptyMin,
					width = "full",
					default = 0
				},
				[106] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 1000,
					step = 10,
					getFunc = RdKGToolSm.GetSmItemSoulGemEmptyMax,
					setFunc = RdKGToolSm.SetSmItemSoulGemEmptyMax,
					width = "full",
					default = 0
				},
				[107] = {
					type = "divider",
					width = "full"
				},
				[108] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.SM_PAYMENT_OPTIONS,
					choices = RdKGToolSm.GetSmPaymentOptions(),
					getFunc = RdKGToolSm.GetSmPaymentOption,
					setFunc = RdKGToolSm.SetSmPaymentOption
				}
				--[[
				[3] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_REPAIR_WALL,
					width = "full"
				},
				[4] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 500,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemRepairWallMin,
					setFunc = RdKGToolSm.SetSmItemRepairWallMin,
					width = "full",
					default = 100
				},
				[5] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 500,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemRepairWallMax,
					setFunc = RdKGToolSm.SetSmItemRepairWallMax,
					width = "full",
					default = 100
				},
				[6] = {
					type = "divider",
					width = "full"
				},
				[7] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_REPAIR_DOOR,
					width = "full"
				},
				[8] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 500,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemRepairDoorMin,
					setFunc = RdKGToolSm.SetSmItemRepairDoorMin,
					width = "full",
					default = 100
				},
				[9] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 500,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemRepairDoorMax,
					setFunc = RdKGToolSm.SetSmItemRepairDoorMax,
					width = "full",
					default = 100
				},
				
				[10] = {
					type = "divider",
					width = "full"
				},
				[11] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_REPAIR_SIEGE,
					width = "full"
				},
				[12] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 500,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemRepairSiegeMin,
					setFunc = RdKGToolSm.SetSmItemRepairSiegeMin,
					width = "full",
					default = 0
				},
				[13] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 500,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemRepairSiegeMax,
					setFunc = RdKGToolSm.SetSmItemRepairSiegeMax,
					width = "full",
					default = 0
				},
				[66] = {
					type = "divider",
					width = "full"
				},
				[67] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.SM_ITEM_DESTRUCTIBLE_REPAIR,
					width = "full"
				},
				[68] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MIN,
					min = 0,
					max = 500,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemDestructibleRepairMin,
					setFunc = RdKGToolSm.SetSmItemDestructibleRepairMin,
					width = "full",
					default = 0
				},
				[69] = {
					type = "slider",
					name = RdKGToolMenu.constants.SM_MAX,
					min = 0,
					max = 500,
					step = 1,
					getFunc = RdKGToolSm.GetSmItemDestructibleRepairMax,
					setFunc = RdKGToolSm.SetSmItemDestructibleRepairMax,
					width = "full",
					default = 0
				},
				]]
			}
		}
	}
	return menu
end

function RdKGToolSm.GetSmEnabled()
	return RdKGToolSm.smVars.enabled
end

function RdKGToolSm.SetSmEnabled(value)
	RdKGToolSm.SetEnabled(value)
end

function RdKGToolSm.GetSmSendChatMessages()
	return RdKGToolSm.smVars.sendChatMessages
end

function RdKGToolSm.SetSmSendChatMessages(value)
	RdKGToolSm.smVars.sendChatMessages = value
end

--[[
function RdKGToolSm.GetSmItemRepairWallMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_REPAIR_WALL)
end

function RdKGToolSm.SetSmItemRepairWallMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_REPAIR_WALL, value)
end

function RdKGToolSm.GetSmItemRepairWallMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_REPAIR_WALL)
end

function RdKGToolSm.SetSmItemRepairWallMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_REPAIR_WALL, value)
end

function RdKGToolSm.GetSmItemRepairDoorMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_REPAIR_DOOR)
end

function RdKGToolSm.SetSmItemRepairDoorMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_REPAIR_DOOR, value)
end

function RdKGToolSm.GetSmItemRepairDoorMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_REPAIR_DOOR)
end

function RdKGToolSm.SetSmItemRepairDoorMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_REPAIR_DOOR, value)
end

function RdKGToolSm.GetSmItemRepairSiegeMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_REPAIR_SIEGE)
end

function RdKGToolSm.SetSmItemRepairSiegeMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_REPAIR_SIEGE, value)
end

function RdKGToolSm.GetSmItemRepairSiegeMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_REPAIR_SIEGE)
end

function RdKGToolSm.SetSmItemRepairSiegeMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_REPAIR_SIEGE, value)
end
]]

function RdKGToolSm.GetSmItemBallistaFireMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_BALLISTA_FIRE)
end

function RdKGToolSm.SetSmItemBallistaFireMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_BALLISTA_FIRE, value)
end

function RdKGToolSm.GetSmItemBallistaFireMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_BALLISTA_FIRE)
end

function RdKGToolSm.SetSmItemBallistaFireMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_BALLISTA_FIRE, value)
end

function RdKGToolSm.GetSmItemBallistaMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_BALLISTA_STONE)
end

function RdKGToolSm.SetSmItemBallistaMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_BALLISTA_STONE, value)
end

function RdKGToolSm.GetSmItemBallistaMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_BALLISTA_STONE)
end

function RdKGToolSm.SetSmItemBallistaMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_BALLISTA_STONE, value)
end

function RdKGToolSm.GetSmItemBallistaLightningMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_BALLISTA_LIGHTNING)
end

function RdKGToolSm.SetSmItemBallistaLightningMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_BALLISTA_LIGHTNING, value)
end

function RdKGToolSm.GetSmItemBallistaLightningMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_BALLISTA_LIGHTNING)
end

function RdKGToolSm.SetSmItemBallistaLightningMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_BALLISTA_LIGHTNING, value)
end

function RdKGToolSm.GetSmItemTrebuchetFireMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_TREBUCHET_FIRE)
end

function RdKGToolSm.SetSmItemTrebuchetFireMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_TREBUCHET_FIRE, value)
end

function RdKGToolSm.GetSmItemTrebuchetFireMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_TREBUCHET_FIRE)
end

function RdKGToolSm.SetSmItemTrebuchetFireMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_TREBUCHET_FIRE, value)
end

function RdKGToolSm.GetSmItemTrebuchetStoneMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_TREBUCHET_STONE)
end

function RdKGToolSm.SetSmItemTrebuchetStoneMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_TREBUCHET_STONE, value)
end

function RdKGToolSm.GetSmItemTrebuchetStoneMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_TREBUCHET_STONE)
end

function RdKGToolSm.SetSmItemTrebuchetStoneMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_TREBUCHET_STONE, value)
end

function RdKGToolSm.GetSmItemTrebuchetIceMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_TREBUCHET_ICE)
end

function RdKGToolSm.SetSmItemTrebuchetIceMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_TREBUCHET_ICE, value)
end

function RdKGToolSm.GetSmItemTrebuchetIceMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_TREBUCHET_ICE)
end

function RdKGToolSm.SetSmItemTrebuchetIceMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_TREBUCHET_ICE, value)
end

function RdKGToolSm.GetSmItemCatapultMeatbagMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_CATAPULT_MEATBAG)
end

function RdKGToolSm.SetSmItemCatapultMeatbagMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_CATAPULT_MEATBAG, value)
end

function RdKGToolSm.GetSmItemCatapultMeatbagMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_CATAPULT_MEATBAG)
end

function RdKGToolSm.SetSmItemCatapultMeatbagMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_CATAPULT_MEATBAG, value)
end

function RdKGToolSm.GetSmItemCatapultOilMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_CATAPULT_OIL)
end

function RdKGToolSm.SetSmItemCatapultOilMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_CATAPULT_OIL, value)
end

function RdKGToolSm.GetSmItemCatapultOilMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_CATAPULT_OIL)
end

function RdKGToolSm.SetSmItemCatapultOilMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_CATAPULT_OIL, value)
end

function RdKGToolSm.GetSmItemCatapultScattershotMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_CATAPULT_SCATTERSHOT)
end

function RdKGToolSm.SetSmItemCatapultScattershotMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_CATAPULT_SCATTERSHOT, value)
end

function RdKGToolSm.GetSmItemCatapultScattershotMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_CATAPULT_SCATTERSHOT)
end

function RdKGToolSm.SetSmItemCatapultScattershotMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_CATAPULT_SCATTERSHOT, value)
end

function RdKGToolSm.GetSmItemOilMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_OIL)
end

function RdKGToolSm.SetSmItemOilMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_OIL, value)
end

function RdKGToolSm.GetSmItemOilMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_OIL)
end

function RdKGToolSm.SetSmItemOilMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_OIL, value)
end

function RdKGToolSm.GetSmItemCampMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_CAMP)
end

function RdKGToolSm.SetSmItemCampMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_CAMP, value)
end

function RdKGToolSm.GetSmItemCampMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_CAMP)
end

function RdKGToolSm.SetSmItemCampMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_CAMP, value)
end

function RdKGToolSm.GetSmItemRamMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_RAM)
end

function RdKGToolSm.SetSmItemRamMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_RAM, value)
end

function RdKGToolSm.GetSmItemRamMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_RAM)
end

function RdKGToolSm.SetSmItemRamMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_RAM, value)
end

function RdKGToolSm.GetSmItemKeepRecallMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_KEEP_RECALL)
end

function RdKGToolSm.SetSmItemKeepRecallMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_KEEP_RECALL, value)
end

function RdKGToolSm.GetSmItemKeepRecallMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_KEEP_RECALL)
end

function RdKGToolSm.SetSmItemKeepRecallMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_KEEP_RECALL, value)
end

--[[
function RdKGToolSm.GetSmItemDestructibleRepairMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_DESTRUCTIBLE_REPAIR)
end

function RdKGToolSm.SetSmItemDestructibleRepairMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_DESTRUCTIBLE_REPAIR, value)
end

function RdKGToolSm.GetSmItemDestructibleRepairMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_DESTRUCTIBLE_REPAIR)
end

function RdKGToolSm.SetSmItemDestructibleRepairMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_DESTRUCTIBLE_REPAIR, value)
end
]]
function RdKGToolSm.GetSmItemRepairAllMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_REPAIR_ALL)
end

function RdKGToolSm.SetSmItemRepairAllMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_REPAIR_ALL, value)
end

function RdKGToolSm.GetSmItemRepairAllMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_REPAIR_ALL)
end

function RdKGToolSm.SetSmItemRepairAllMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_REPAIR_ALL, value)
end

function RdKGToolSm.GetSmItemPotRedMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_POT_RED)
end

function RdKGToolSm.SetSmItemPotRedMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_POT_RED, value)
end

function RdKGToolSm.GetSmItemPotRedMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_POT_RED)
end

function RdKGToolSm.SetSmItemPotRedMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_POT_RED, value)
end

function RdKGToolSm.GetSmItemPotGreenMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_POT_GREEN)
end

function RdKGToolSm.SetSmItemPotGreenMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_POT_GREEN, value)
end

function RdKGToolSm.GetSmItemPotGreenMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_POT_GREEN)
end

function RdKGToolSm.SetSmItemPotGreenMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_POT_GREEN, value)
end

function RdKGToolSm.GetSmItemPotBlueMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_POT_BLUE)
end

function RdKGToolSm.SetSmItemPotBlueMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_POT_BLUE, value)
end

function RdKGToolSm.GetSmItemPotBlueMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_POT_BLUE)
end

function RdKGToolSm.SetSmItemPotBlueMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_POT_BLUE, value)
end

function RdKGToolSm.GetSmItemTriPotMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_TRI_POT)
end

function RdKGToolSm.SetSmItemTriPotMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_TRI_POT, value)
end

function RdKGToolSm.GetSmItemTriPotMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_TRI_POT)
end

function RdKGToolSm.SetSmItemTriPotMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_TRI_POT, value)
end

function RdKGToolSm.GetSmItemCfTackMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_CF_TACK)
end

function RdKGToolSm.SetSmItemCfTackMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_CF_TACK, value)
end

function RdKGToolSm.GetSmItemCfTackMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_CF_TACK)
end

function RdKGToolSm.SetSmItemCfTackMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_CF_TACK, value)
end

function RdKGToolSm.GetSmItemCfTreatMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_CF_TREAT)
end

function RdKGToolSm.SetSmItemCfTreatMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_CF_TREAT, value)
end

function RdKGToolSm.GetSmItemCfTreatMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_CF_TREAT)
end

function RdKGToolSm.SetSmItemCfTreatMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_CF_TREAT, value)
end

function RdKGToolSm.GetSmItemCfBarMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_CF_BAR)
end

function RdKGToolSm.SetSmItemCfBarMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_CF_BAR, value)
end

function RdKGToolSm.GetSmItemCfBarMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_CF_BAR)
end

function RdKGToolSm.SetSmItemCfBarMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_CF_BAR, value)
end

function RdKGToolSm.GetSmItemCfBrewMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_CF_BREW)
end

function RdKGToolSm.SetSmItemCfBrewMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_CF_BREW, value)
end

function RdKGToolSm.GetSmItemCfBrewMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_CF_BREW)
end

function RdKGToolSm.SetSmItemCfBrewMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_CF_BREW, value)
end

function RdKGToolSm.GetSmItemCfTeaMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_CF_TEA)
end

function RdKGToolSm.SetSmItemCfTeaMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_CF_TEA, value)
end

function RdKGToolSm.GetSmItemCfTeaMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_CF_TEA)
end

function RdKGToolSm.SetSmItemCfTeaMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_CF_TEA, value)
end

function RdKGToolSm.GetSmItemCfTonicMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_CF_TONIC)
end

function RdKGToolSm.SetSmItemCfTonicMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_CF_TONIC, value)
end

function RdKGToolSm.GetSmItemCfTonicMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_CF_TONIC)
end

function RdKGToolSm.SetSmItemCfTonicMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_CF_TONIC, value)
end

function RdKGToolSm.GetSmItemSoulGemMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_SOUL_GEM)
end

function RdKGToolSm.SetSmItemSoulGemMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_SOUL_GEM, value)
end

function RdKGToolSm.GetSmItemSoulGemMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_SOUL_GEM)
end

function RdKGToolSm.SetSmItemSoulGemMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_SOUL_GEM, value)
end

function RdKGToolSm.GetSmItemSoulGemEmptyMin()
	return RdKGToolSm.GetMinimum(RdKGToolSm.constants.ITEM_SOUL_GEM_EMPTY)
end

function RdKGToolSm.SetSmItemSoulGemEmptyMin(value)
	RdKGToolSm.SetMinimum(RdKGToolSm.constants.ITEM_SOUL_GEM_EMPTY, value)
end

function RdKGToolSm.GetSmItemSoulGemEmptyMax()
	return RdKGToolSm.GetMaximum(RdKGToolSm.constants.ITEM_SOUL_GEM_EMPTY)
end

function RdKGToolSm.SetSmItemSoulGemEmptyMax(value)
	RdKGToolSm.SetMaximum(RdKGToolSm.constants.ITEM_SOUL_GEM_EMPTY, value)
end

function RdKGToolSm.GetSmPaymentOptions()
	return {
		RdKGToolSm.paymentOptions[RdKGToolSm.constants.PAYMENT_ONLY_AP],
		RdKGToolSm.paymentOptions[RdKGToolSm.constants.PAYMENT_ONLY_GOLD],
		RdKGToolSm.paymentOptions[RdKGToolSm.constants.PAYMENT_FIRST_AP],
		RdKGToolSm.paymentOptions[RdKGToolSm.constants.PAYMENT_FIRST_GOLD]
	}
end

function RdKGToolSm.GetSmPaymentOption()
	return RdKGToolSm.paymentOptions[RdKGToolSm.smVars.paymentOption]
end

function RdKGToolSm.SetSmPaymentOption(value)
	if value ~= nil then
		for i = 1, #RdKGToolSm.paymentOptions do
			if RdKGToolSm.paymentOptions[i] == value then
				RdKGToolSm.smVars.paymentOption = i
				return
			end
		end
	end
end

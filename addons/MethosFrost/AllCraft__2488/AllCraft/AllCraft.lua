AllCraft = AllCraft or {}

AllCraft.name = "AllCraft"
AllCraft.version =  "0.910"

local function DismissPets() --Thank you @Dolgubon for not forcing to reinvent the wheel
	-- All the abilityIDs for pets that should not be near craft tables.
	local petIds = {
	[23304]=true, [30631]=true, [30636]=true, [30641]=true, [23319]=true, [30647]=true, 
	[30652]=true, [30657]=true, [23316]=true, [30664]=true, [30669]=true, [30674]=true , 
	[24613]=true, [30581]=true, [30584]=true, [30587]=true, [24636]=true, [30592]=true, 
	[30595]=true, [30598]=true, [24639]=true, [30618]=true, [30622]=true, [30626]=true, 
	[85982]=true, [85983]=true, [85984]=true, [85985]=true, [85986]=true, [85987]=true, 
	[85988]=true, [85989]=true, [85990]=true, [85991]=true, [85992]=true, [85993]=true, }

	-- Walk through the player's active buffs
	for i = 1, GetNumBuffs("player") do
		local _, _, _, buffSlot, _, _, _, _, _, _, abilityId, _ = GetUnitBuffInfo("player", i)
		-- Compare each buff's abilityID to the list of IDs we were given
		if petIds[abilityId] then
			-- Cancel the buff if we got a match
			CancelBuff(buffSlot)
		end
	end
end

AllCraft.InCraftingState = {}
local tableStarted = {}
local function CraftingComplete(eventCode,craftTableType)
		if AllCraft.InCraftingState == "refine" then
			AllCraft.InCraftingState = ""
			AllCraft_Decon.RefineKey()
		end
end

function InCraftingQuests()
	local Crafting = false
	for i=1, 25 do
		local type = GetJournalQuestType(i)
		if type == QUEST_TYPE_CRAFTING then
			Crafting = true
		end
	end
	return Crafting
end

local function TableInteract(eventCode,craftTableType)
	DismissPets()
	EVENT_MANAGER:RegisterForEvent(AllCraft.name, EVENT_CRAFT_COMPLETED, CraftingComplete)
	AllCraft_Decon.DeconInitialize(eventCode,craftTableType)
	AllCraft_Decon.HasWrits = InCraftingQuests()
	AllCraft_Decon.CraftTableInteract(eventCode,craftTableType)
end

local function LeaveTable()
	AllCraft.InCraftingState = nil
	EVENT_MANAGER:UnregisterForEvent(AllCraft.name, EVENT_CRAFT_COMPLETED)
	DeconstructList = {}
	AllCraft_Decon.CraftTableLeave()
end

--Register events
local function EventRegistration()
	EVENT_MANAGER:RegisterForEvent(AllCraft.name, EVENT_CRAFTING_STATION_INTERACT, TableInteract)
	EVENT_MANAGER:RegisterForEvent(AllCraft.name, EVENT_END_CRAFTING_STATION_INTERACT, LeaveTable)
end

local function AddonInitialize(event, addonName)

	--load saved variables and set defaults
	AllCraft_Decon.deconSettings = ZO_SavedVars:NewAccountWide("AllCraft", 2, "AllCraft_Decon", AllCraft_Decon.deconDefaults)

	if addonName ~= AllCraft.name then return end
	EVENT_MANAGER:UnregisterForEvent(AllCraft.name, EVENT_ADD_ON_LOADED)

	EventRegistration()
	AllCraftDeconMenu()
end

--**TODO** register for events only near crafting stations?

EVENT_MANAGER:RegisterForEvent(AllCraft.name, EVENT_ADD_ON_LOADED, AddonInitialize)
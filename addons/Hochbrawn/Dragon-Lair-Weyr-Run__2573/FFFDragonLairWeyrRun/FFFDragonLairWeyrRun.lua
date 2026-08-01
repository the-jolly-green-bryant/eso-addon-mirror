-- Create namespace for addon
FFFDragonLairWeyrRun = {
    version = "0.1.9.3",
    name = "FFFDragonLairWeyrRun",
    displayName = "Dragon Lair Weyr Run",
	wm = GetWindowManager(),
	LootWindow = nil,
	GuildBankDepositWindow = nil,
	LeaderBoardWindow = nil,
	tlw = {}, --nil, --Top Level Window
	PlayerIndex = {},
	PlayerNameMapping ={},
	ActivePlayer = {},
	Players = {},
	classes = {},
	myPlayerName = "",
	TotalFarmed = 0,
	ShowingGroup = true,
	ShowingFarmed = true,
	ShowingPlayerIndex = 1,
	LeaderFarmed = true,
	enter = false,
	bpStackSize = 0,
	backpackSlot = nil,
	transferItem = {},
	depositQuantity = 0,
	depositItem = {},
	RawLootTransactions = RawLootPlayerList:New(),
	PersistData = true,
	TimeStarted = 0--GetTimeStamp()
	
}

local desiredItemTypes = {

	[ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = {desired = true},
	[ITEMTYPE_ARMOR] = {desired = true},
	[ITEMTYPE_ARMOR_TRAIT]= {desired = true}, 
	[ITEMTYPE_CLOTHIER_RAW_MATERIAL]= {desired = true},
	[ITEMTYPE_WOODWORKING_RAW_MATERIAL]= {desired = true},
	[ITEMTYPE_FURNISHING_MATERIAL]= {desired = true},
	[ITEMTYPE_WEAPON_TRAIT]= {desired = true},
	[ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL]= {desired = true},
	[ITEMTYPE_JEWELRY_RAW_TRAIT]= {desired = true},
	[ITEMTYPE_JEWELRY_TRAIT]= {desired = true},
	[ITEMTYPE_REAGENT]= {desired = true},
	[ITEMTYPE_POTION_BASE]= {desired = true},
	[ITEMTYPE_POISON_BASE]= {desired = true},
	[ITEMTYPE_ENCHANTING_RUNE_ASPECT]= {desired = true},
	[ITEMTYPE_ENCHANTING_RUNE_ESSENCE]= {desired = true},
	[ITEMTYPE_ENCHANTING_RUNE_POTENCY]= {desired = true},
	[ITEMTYPE_INGREDIENT]= {desired = true},
	[ITEMTYPE_FISH]= {desired = true},
	[ITEMTYPE_LURE]= {desired = true},
	[ITEMTYPE_RACIAL_STYLE_MOTIF]= {desired = true},
	[ITEMTYPE_RECIPE] = {desired = true},
	[ITEMTYPE_WEAPON] = {desired = true},
	[ITEMTYPE_STYLE_MATERIAL] = {desired = true}
}

local desiredSpecializedTypes ={

	[SPECIALIZED_ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = { bar = 1 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_ARMOR]= { bar = 8 , quality = ITEM_QUALITY_ARTIFACT},
	[SPECIALIZED_ITEMTYPE_NONE]= { bar = 8, quality = ITEM_QUALITY_ARTIFACT},
	[SPECIALIZED_ITEMTYPE_ARMOR_TRAIT] = { bar = 8 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_CLOTHIER_RAW_MATERIAL] = { bar = 2 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_WOODWORKING_RAW_MATERIAL] = { bar = 3 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = { bar = 4 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_JEWELRY_RAW_TRAIT] = { bar = 4 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_JEWELRY_TRAIT] = { bar = 4 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_REAGENT_ANIMAL_PART]= { bar = 5 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_REAGENT_FUNGUS]= { bar = 5 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_REAGENT_HERB]= { bar = 5 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_POTION_BASE] = { bar = 5 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_POISON_BASE] = { bar = 5 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_ENCHANTING_RUNE_ASPECT] = { bar = 6 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = { bar = 6 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_ENCHANTING_RUNE_POTENCY] = { bar = 6 , quality = ITEM_QUALITY_NORMAL}, 
	[SPECIALIZED_ITEMTYPE_INGREDIENT_ALCOHOL] = { bar = 7 , quality = ITEM_QUALITY_NORMAL},  
	[SPECIALIZED_ITEMTYPE_INGREDIENT_DRINK_ADDITIVE] = { bar = 7 , quality = ITEM_QUALITY_NORMAL},  
	[SPECIALIZED_ITEMTYPE_INGREDIENT_FOOD_ADDITIVE] = { bar = 7 , quality = ITEM_QUALITY_NORMAL},  
	[SPECIALIZED_ITEMTYPE_INGREDIENT_FRUIT] = { bar = 7 , quality = ITEM_QUALITY_NORMAL},  
	[SPECIALIZED_ITEMTYPE_INGREDIENT_MEAT] = { bar = 7 , quality = ITEM_QUALITY_NORMAL},  
	[SPECIALIZED_ITEMTYPE_INGREDIENT_RARE] = { bar = 7 , quality = ITEM_QUALITY_NORMAL},  
	[SPECIALIZED_ITEMTYPE_INGREDIENT_TEA] = { bar = 7 , quality = ITEM_QUALITY_NORMAL},  
	[SPECIALIZED_ITEMTYPE_INGREDIENT_TONIC] = { bar = 7 , quality = ITEM_QUALITY_NORMAL},  
	[SPECIALIZED_ITEMTYPE_INGREDIENT_VEGETABLE] = { bar = 7 , quality = ITEM_QUALITY_NORMAL},  
	[SPECIALIZED_ITEMTYPE_FISH] = { bar = 7 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_LURE] = {bar = 7 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK] = {bar = 8 , quality = ITEM_QUALITY_ARTIFACT},
	[SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER] = {bar = 8 , quality = ITEM_QUALITY_ARTIFACT},
	[SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING] = { bar = 1 , quality = ITEM_QUALITY_ARTIFACT},
	[SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING] = { bar = 2 , quality = ITEM_QUALITY_ARTIFACT},
	[SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING] = { bar = 3 , quality = ITEM_QUALITY_ARTIFACT},
	[SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING] = { bar = 4 , quality = ITEM_QUALITY_ARTIFACT},
	[SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING] = { bar = 5 , quality = ITEM_QUALITY_ARTIFACT},
	[SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING] = { bar = 6 , quality = ITEM_QUALITY_ARTIFACT},
	[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK] = { bar = 7 , quality = ITEM_QUALITY_ARTIFACT},
	[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD] = { bar = 7 , quality = ITEM_QUALITY_ARTIFACT},
	[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING] = { bar = 7 , quality = ITEM_QUALITY_ARTIFACT},
	[SPECIALIZED_ITEMTYPE_STYLE_MATERIAL]= { bar = 8 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_BLACKSMITHING] = { bar = 1 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_CLOTHIER] ={ bar = 2 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_WOODWORKING] ={ bar = 3 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_JEWELRYCRAFTING]={ bar = 4 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_ALCHEMY] = {bar = 5 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_ENCHANTING]= { bar = 6 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_PROVISIONING] ={ bar = 7 , quality = ITEM_QUALITY_NORMAL},
	[SPECIALIZED_ITEMTYPE_WEAPON]= { bar = 8 , quality = ITEM_QUALITY_ARTIFACT},
	[SPECIALIZED_ITEMTYPE_WEAPON_TRAIT] = { bar = 8 , quality = ITEM_QUALITY_NORMAL},}

local function checkStack()
	local bpSlot = FFFDragonLairWeyrRun.backpackSlot
	FFFDragonLairWeyrRun.bpStackSize = GetSlotStackSize(BAG_BACKPACK, bpSlot)
	--d("stack size as on timed function".. tostring( FFFDragonLairWeyrRun.bpStackSize))
	if FFFDragonLairWeyrRun.bpStackSize ~= 0 then
		EVENT_MANAGER:UnregisterForUpdate(FFFDragonLairWeyrRun.name.."stack", checkStack)
		if FFFDragonLairWeyrRun.bpStackSize > FFFDragonLairWeyrRun.depositQuantity then
			-- stack found is larger than amount requested for deposit.  
			-- split stack and get new slot and confirm stack size again for deposit
			-- need a new slot to split stack to
			d("too many in stack")
			local destSlot = FindFirstEmptySlotInBag(BAG_BACKPACK)
			CallSecureProtected("RequestMoveItem", BAG_BACKPACK, FFFDragonLairWeyrRun.backpackSlot, BAG_BACKPACK, destSlot, FFFDragonLairWeyrRun.depositQuantity)
			FFFDragonLairWeyrRun.backpackSlot = destSlot
			d("waiting for item transfer")
			EVENT_MANAGER:RegisterForUpdate(FFFDragonLairWeyrRun.name.."stack",300, function() checkStack() end)
			return
		else
			-- set deposit to the quantity of the stack
			FFFDragonLairWeyrRun.depositQuantity = FFFDragonLairWeyrRun.bpStackSize
		end
		--d("backpack stacksize = ".. tostring(FFFDragonLairWeyrRun.bpStackSize))
		-- call bank deposit
		d("ready to call for bank deposit")
		FFFDragonLairWeyrRun.ItemDeposit_MakeDeposit()
		
		
		
		return
	end
	return
end

local function updateLeaders()
	-- function to update leaderboard when active every n number of seconds.
	-- see leaderStanding function for setup and call.
	
	if FFFDragonLairWeyrRun.Players == nil then return end
	local leaderStanding = {}
	local j = 1
	local next = next
	
	for i = 1, 24 do
		if FFFDragonLairWeyrRun.Players[i].AllValuedLoot.totalValue > 0 or FFFDragonLairWeyrRun.Players[i].GuildBankDeposits.totalValue > 0 then
			leaderStanding[j] = FFFDragonLairWeyrRun.Players[i]
			j = j+1
		end
		-- if FFFDragonLairWeyrRun.LeaderFarmed then
			-- if FFFDragonLairWeyrRun.Players[i].AllValuedLoot.totalValue > 0 then
				-- leaderStanding[j] = FFFDragonLairWeyrRun.Players[i]
				-- j = j+1
			-- end
		-- else
			-- if FFFDragonLairWeyrRun.Players[i].GuildBankDeposits.totalValue > 0 then
				-- leaderStanding[j] = FFFDragonLairWeyrRun.Players[i]
				-- j = j+1
			-- end
		-- end
	end
	
	
	
	
	-- local sortFunction = function(listEntry1,listEntry2) return listEntry1.AllValuedLoot.totalValue > listEntry2.AllValuedLoot.totalValue end
	-- if not LeaderFarmed then 
		-- -- sorting based on bank deposits
		-- sortFunction = function(listEntry1,listEntry2) return listEntry1.GuildBankDeposits.totalValue > listEntry2.GuildBankDeposits.totalValue end
	-- end
	
	-- table.sort(leaderStanding, sortFunction)
	if next(leaderStanding) ~= nil then
		--d("this is leaderStanding List",leaderStanding[1].AllValuedLoot.totalValue)
		FFFDragonLairWeyrRun.LeaderBoardWindow:OnLeaderUpdate(leaderStanding)
	end
	--d(leaderStanding)
end


function FFFDragonLairWeyrRun.formatLootTime(deltaTime)
	-- given a deltatime in seconds format to hh:mm:ss
	if deltaTime <= 0 then return "00:00:00" end
	local hh = string.format("%02.f", math.floor(deltaTime/3600))
	local mm = string.format("%02.f", math.floor(deltaTime/60 - (hh*60)))
	local ss = string.format("%02.f", math.floor(deltaTime - hh*3600 - mm * 60))
	return hh..":"..mm..":"..ss
	
end	



function FFFDragonLairWeyrRun.OnAddOnLoaded(event, addonName)
    if addonName == FFFDragonLairWeyrRun.name then 
		
		FFFDragonLairWeyrRun.CreateGroupControls()
		FFFDragonLairWeyrRun.Init()
		EVENT_MANAGER:UnregisterForEvent(FFFDragonLairWeyrRun.name, EVENT_ADD_ON_LOADED)
		
	end
    
end

function FFFDragonLairWeyrRun.OnPlayerDblClick(control)
	if control == nil then return end
	local playername = control:GetText()
	
	local index = FFFDragonLairWeyrRun.PlayerIndex[playername]
	FFFDragonLairWeyrRun.ShowingPlayerIndex = index
	--d("Hey..".. index.." got dblclicked. showing thier items now")
	-- showownitems assumes that you are currently showing group. so 
	-- check and accomodate to keep it simple for now.
	if FFFDragonLairWeyrRun.ShowingGroup then
		FFFDragonLairWeyrRun.ShowOwnItems()
	else
		FFFDragonLairWeyrRun.ShowingGroup = true
		FFFDragonLairWeyrRun.ShowOwnItems()
	end

end

function FFFDragonLairWeyrRun.Init()
	-- set lootwindow
	FFFDragonLairWeyrRun.LootWindow = FFFDragonLairWeyrRun.classes.LootMainWindow:New()
	-- set guildbankdepositwindow
	FFFDragonLairWeyrRun.GuildBankDepositWindow = FFFDragonLairWeyrRun.classes.GuildBankDepositWindow:New()
	-- set LeaderBoardWindow
	FFFDragonLairWeyrRun.LeaderBoardWindow= FFFDragonLairWeyrRun.classes.LeaderBoardWindow:New()
	
	-- setup control
	FFFDragonLairWeyrRun.SetUpControl()
	-- set up saved variables
	FFFDragonLairWeyrRun.savedVariables = ZO_SavedVars:New("FFFDragonLairWeyrRunSavedVars",2,nil,{})
	FFFDragonLairWeyrRun.RestorePosition()
	-- i think this next line registers the addon to get regular random saves approx every 15 mins
	GetAddOnManager():RequestAddOnSavedVariablesPrioritySave("FFFDragonLairWeyrRun\FFFDragonLairWeyrRun")
	
	-- store my player as it is used on several occasions
	FFFDragonLairWeyrRun.myPlayerName = GetUnitDisplayName("player")
	FFFDragonLairWeyrRun.myCharacterName = GetUnitName("player")
	-- build controls
	for i=1,25 do
		local scale = 1
		if i == 25 then scale = 2 end
		FFFDragonLairWeyrRun.AddPlayer("Dragon "..i,i, scale)
		-- set initial state to inactive
		--table.insert(FFFDragonLairWeyrRun.ActivePlayer, i)
		FFFDragonLairWeyrRun.ActivePlayer[i] = false
		FFFDragonLairWeyrRun.Players[i].lblPlayerName:SetHandler("OnMouseDoubleClick", function () FFFDragonLairWeyrRun.OnPlayerDblClick(FFFDragonLairWeyrRun.Players[i].lblPlayerName) end)

	end
	-- set my player and char mapping
	--table.insert(FFFDragonLairWeyrRun.PlayerNameMapping, FFFDragonLairWeyrRun.myCharacterName)
	FFFDragonLairWeyrRun.PlayerNameMapping[FFFDragonLairWeyrRun.myCharacterName] = FFFDragonLairWeyrRun.myPlayerName
	-- Add local player as the first member and set index to 1.
	-- Index is value of the player control that will be associated with the player.

	FFFDragonLairWeyrRun.PlayerIndex[FFFDragonLairWeyrRun.myPlayerName] = 1	
	
	-- and initialize player
	FFFDragonLairWeyrRun.InitPlayer(FFFDragonLairWeyrRun.myPlayerName, 1)
	
	-- Setup the Dragon Hoard - the grand total list  no @name on this one to protect it from others
	FFFDragonLairWeyrRun.PlayerIndex["Dragon Hoard"] = 25
	FFFDragonLairWeyrRun.InitPlayer("Dragon Hoard", 25)
	FFFDragonLairWeyrRun.transferItem.InTransit = false
	FFFDragonLairWeyrRun.Quit()

	
	
	
end


function FFFDragonLairWeyrRun.AddPlayer(playerName,num, scale)
	-- this is the default control ordering and setup only.
	-- add a new player control to group control
	-- Player 1 should always be the local player as they are added onaddonload in the Init.
	--table.insert(FFFDragonLairWeyrRun.Players, FFFDragonLairWeyrRun.classes.PlayerControl:New(playerName))
	FFFDragonLairWeyrRun.Players[num]=FFFDragonLairWeyrRun.classes.PlayerControl:New(playerName,scale)
	
	numPlayers = num
	--d("number of players in list " .. numPlayers)
	--(Currently set to add 4 players to one of 6 team strips)  Maybe this can be customized or made dynamic later.
	if numPlayers <= 4 then
		FFFDragonLairWeyrRun.Players[numPlayers]:AddToMain(FFFDragonLairWeyrRun.tlw[1], 5+(80*(numPlayers-1)),20)
	elseif numPlayers >4 and numPlayers <= 8 then
		FFFDragonLairWeyrRun.Players[numPlayers]:AddToMain(FFFDragonLairWeyrRun.tlw[2], 5+(80*(numPlayers-5)),20)
	elseif numPlayers >8 and numPlayers <= 12 then
		FFFDragonLairWeyrRun.Players[numPlayers]:AddToMain(FFFDragonLairWeyrRun.tlw[3], 5+(80*(numPlayers-9)),20)
	elseif numPlayers >12 and numPlayers <= 16 then
		FFFDragonLairWeyrRun.Players[numPlayers]:AddToMain(FFFDragonLairWeyrRun.tlw[4], 5+(80*(numPlayers-13)),20)	
	elseif numPlayers >16 and numPlayers <= 20 then
		FFFDragonLairWeyrRun.Players[numPlayers]:AddToMain(FFFDragonLairWeyrRun.tlw[5], 5+(80*(numPlayers-17)),20)
	elseif numPlayers > 20 and numPlayers <= 24 then
		FFFDragonLairWeyrRun.Players[numPlayers]:AddToMain(FFFDragonLairWeyrRun.tlw[6], 5+(80*(numPlayers-21)),20)
	else
		-- player 25 'Dragon Hoard' will add to its own frame tlw[7]
		FFFDragonLairWeyrRun.Players[numPlayers]:AddToMain(FFFDragonLairWeyrRun.tlw[7], 5,30)
	end

	
end

-- Build Group Controls
function FFFDragonLairWeyrRun.CreateGroupControls()
	-- this builds the 6 team windows and sets the bag space text for Team 1 that contains the local player
	-- create special window 7 for the 'Dragon Hoard'
	for index = 1, 7 do
		FFFDragonLairWeyrRun.tlw[index] = FFFDragonLairWeyrRun.wm:CreateTopLevelWindow("FFFDragonLairWeyrRunTeam"..index) 
		FFFDragonLairWeyrRun.tlw[index]:SetDimensions(330,180)
		FFFDragonLairWeyrRun.tlw[index]:SetResizeToFitDescendents(true)
		FFFDragonLairWeyrRun.tlw[index]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 200,100*index)
		FFFDragonLairWeyrRun.tlw[index]:SetMovable(true)
		FFFDragonLairWeyrRun.tlw[index]:SetMouseEnabled(true)
		FFFDragonLairWeyrRun.tlw[index]:SetHidden(true)
		-- setup handler to deal with new location after move
		FFFDragonLairWeyrRun.tlw[index]:SetHandler("OnMoveStop", FFFDragonLairWeyrRun.OnMoveStop)
		-- local backdrop as not needed to access again
		local GroupBackDrop = FFFDragonLairWeyrRun.wm:CreateControl("FFFDragonLairWeyrRunGroupBackDrop"..index, FFFDragonLairWeyrRun.tlw[index], CT_BACKDROP)
		GroupBackDrop:SetDimensions(330,180)
		GroupBackDrop:SetEdgeColor(.996,.867,.678,.9)
		GroupBackDrop:SetEdgeTexture("",1,1,2,0) 
		--SetEdgeTexture(string filename, number edgeFileWidth, number edgeFileHeight, number edgeSize, number edgeFilePadding)
		GroupBackDrop:SetCenterColor(0.0,0.0,0.0)
		GroupBackDrop:SetAnchor(TOPLEFT, FFFDragonLairWeyrRun.tlw[index], TOPLEFT,0,0)
		GroupBackDrop:SetAlpha(0.05)
		GroupBackDrop:SetDrawLayer(0)
		-- label for free bag space
		local lblTeamTitle = FFFDragonLairWeyrRun.wm:CreateControl("FFFDragonLairWeyrRunlblTeamTitle"..index, FFFDragonLairWeyrRun.tlw[index], CT_LABEL)
		lblTeamTitle:SetColor(.996,.867,.678,.9)
		lblTeamTitle:SetFont("ZoFontGameSmall")
		lblTeamTitle:SetScale(1)
		lblTeamTitle:SetDimensions(80,15)
		lblTeamTitle:SetText("WEYR TEAM "..index)
		lblTeamTitle:SetAnchor(TOPLEFT,FFFDragonLairWeyrRun.tlw[index], TOPLEFT,125,5)
		lblTeamTitle:SetDrawLayer(1)
		if index == 1 then
			-- show main group
			FFFDragonLairWeyrRun.tlw[index]:SetHidden(false)
			-- label for free bag space
			local lblFreeSlots = FFFDragonLairWeyrRun.wm:CreateControl("FFFDragonLairWeyrRunlblFreeSlots"..index, FFFDragonLairWeyrRun.tlw[index], CT_LABEL)
			lblFreeSlots:SetColor(.996,.867,.678,.9)
			lblFreeSlots:SetFont("ZoFontGameSmall")
			lblFreeSlots:SetScale(1)
			lblFreeSlots:SetDimensions(60,15)
			lblFreeSlots:SetText("Bag Space")
			lblFreeSlots:SetAnchor(TOPLEFT,FFFDragonLairWeyrRun.tlw[index], TOPLEFT,5,5)
			lblFreeSlots:SetDrawLayer(1)
			--Bag space
			FFFDragonLairWeyrRun.lblBagSpace = FFFDragonLairWeyrRun.wm:CreateControl("FFFDragonLairWeyrRunlblBagSpace"..index, FFFDragonLairWeyrRun.tlw[index], CT_LABEL)
			FFFDragonLairWeyrRun.lblBagSpace:SetColor(.996,.867,.678,.9)
			FFFDragonLairWeyrRun.lblBagSpace:SetFont("ZoFontGameSmall")
			FFFDragonLairWeyrRun.lblBagSpace:SetScale(1)
			FFFDragonLairWeyrRun.lblBagSpace:SetDimensions(60,15)
			FFFDragonLairWeyrRun.lblBagSpace:SetText("0")
			FFFDragonLairWeyrRun.lblBagSpace:SetAnchor(TOPLEFT,FFFDragonLairWeyrRun.tlw[index], TOPLEFT,75,5)
			FFFDragonLairWeyrRun.lblBagSpace:SetDrawLayer(1)
			-- Looting time
			FFFDragonLairWeyrRun.lblLootTime  = FFFDragonLairWeyrRun.wm:CreateControl("FFFDragonLairWeyrRunlblLootTime"..index, FFFDragonLairWeyrRun.tlw[index], CT_LABEL)
			FFFDragonLairWeyrRun.lblLootTime:SetColor(.996,.867,.678,.9)
			FFFDragonLairWeyrRun.lblLootTime:SetFont("ZoFontGameSmall")
			FFFDragonLairWeyrRun.lblLootTime:SetScale(1)
			FFFDragonLairWeyrRun.lblLootTime:SetDimensions(60,15)
			FFFDragonLairWeyrRun.lblLootTime:SetText("00:00:00")
			FFFDragonLairWeyrRun.lblLootTime:SetAnchor(TOPLEFT,FFFDragonLairWeyrRun.tlw[index], TOPLEFT,250,5)
			FFFDragonLairWeyrRun.lblLootTime:SetDrawLayer(1)
			
		elseif index == 7 then
			-- the dragon hoard
			
			FFFDragonLairWeyrRun.tlw[index] = FFFDragonLairWeyrRun.wm:CreateTopLevelWindow("FFFDragonLairWeyrRunHoard"..index) 
			FFFDragonLairWeyrRun.tlw[index]:SetDimensions(170,350) -- at least 360 high + scrolled list
			FFFDragonLairWeyrRun.tlw[index]:SetResizeToFitDescendents(true)
			FFFDragonLairWeyrRun.tlw[index]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 200,100*index)
			FFFDragonLairWeyrRun.tlw[index]:SetMovable(true)
			FFFDragonLairWeyrRun.tlw[index]:SetMouseEnabled(true)
			FFFDragonLairWeyrRun.tlw[index]:SetHidden(false)
			-- setup handler to deal with new location after move
			FFFDragonLairWeyrRun.tlw[index]:SetHandler("OnMoveStop", FFFDragonLairWeyrRun.OnMoveStop)
			-- local backdrop as not needed to access again
			local GroupBackDrop = FFFDragonLairWeyrRun.wm:CreateControl("FFFDragonLairWeyrRunHoardBackDrop"..index, FFFDragonLairWeyrRun.tlw[index], CT_BACKDROP)
			GroupBackDrop:SetDimensions(170,350)
			GroupBackDrop:SetEdgeColor(.996,.867,.678,.9)
			GroupBackDrop:SetEdgeTexture("",1,1,2,0) 
			--SetEdgeTexture(string filename, number edgeFileWidth, number edgeFileHeight, number edgeSize, number edgeFilePadding)
			GroupBackDrop:SetCenterColor(.5,0,0)
			GroupBackDrop:SetAnchor(TOPLEFT, FFFDragonLairWeyrRun.tlw[index], TOPLEFT,0,0)
			GroupBackDrop:SetAlpha(0.05)
			GroupBackDrop:SetDrawLayer(0)
			-- label for free bag space
			local lblTeamTitle = FFFDragonLairWeyrRun.wm:CreateControl("FFFDragonLairWeyrRunlblHoardTitle"..index, FFFDragonLairWeyrRun.tlw[index], CT_LABEL)
			lblTeamTitle:SetColor(.996,.867,.678,.9)
			lblTeamTitle:SetFont("ZoFontGameLarge")
			lblTeamTitle:SetScale(1)
			lblTeamTitle:SetDimensions(170,15)
			lblTeamTitle:SetText("THE HOARD BOARD")
			lblTeamTitle:SetAnchor(TOPLEFT,FFFDragonLairWeyrRun.tlw[index], TOPLEFT,5,5)
			lblTeamTitle:SetDrawLayer(1)
		end	
	end
	
end


function FFFDragonLairWeyrRun.OnMoveStop()
	-- event handler for when top level window stops being dragged and we can save its location
	FFFDragonLairWeyrRun.savedVariables.left = {}
	FFFDragonLairWeyrRun.savedVariables.top = {}
	for index = 1, 7 do
		FFFDragonLairWeyrRun.savedVariables.left[index] = FFFDragonLairWeyrRun.tlw[index]:GetLeft()
		FFFDragonLairWeyrRun.savedVariables.top[index] = FFFDragonLairWeyrRun.tlw[index]:GetTop()
	end
end

function FFFDragonLairWeyrRun.RestorePosition()
	-- restore the position of the control to the last saved position
	if FFFDragonLairWeyrRun.savedVariables.left == nil then return end
	for index = 1, 7 do
		local left = FFFDragonLairWeyrRun.savedVariables.left[index]
		local top = FFFDragonLairWeyrRun.savedVariables.top[index]
		FFFDragonLairWeyrRun.tlw[index]:ClearAnchors()
		FFFDragonLairWeyrRun.tlw[index]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
	end	
		
end

function FFFDragonLairWeyrRun.SetUpControl()
	
	-- get number of bag slots
	FFFDragonLairWeyrRun.numBagSlots = GetBagUseableSize(BAG_BACKPACK)
	FFFDragonLairWeyrRun.freeBagSlots = FFFDragonLairWeyrRun.GetFreeBagSlots()
	FFFDragonLairWeyrRun.lblBagSpace:SetText(FFFDragonLairWeyrRun.freeBagSlots)
	
end

function FFFDragonLairWeyrRun.GetFreeBagSlots()
	local freeslots = 0
	i=0
	while( i <= FFFDragonLairWeyrRun.numBagSlots)
	do
		if not HasItemInSlot(BAG_BACKPACK, i) then
			freeslots = freeslots + 1
		end
		i = i + 1
	end
	return freeslots
end

function FFFDragonLairWeyrRun.ShowOwnItems()
	-- switch display from group items to own items
	local index = FFFDragonLairWeyrRun.ShowingPlayerIndex
	local playerName = FFFDragonLairWeyrRun.Players[index].playerName
	if FFFDragonLairWeyrRun.ShowingGroup then
		FFFDragonLairWeyrRun.ShowingGroup = false
		if FFFDragonLairWeyrRun.ShowingFarmed then
			local itemList = FFFDragonLairWeyrRun.Players[index].AllValuedLoot--.items
			
			FFFDragonLairWeyrRun.LootWindow:ShowOwnItems(true,true, itemList,playerName )	
			--d("showing own items")
		else
			local itemList = FFFDragonLairWeyrRun.Players[index].GuildBankDeposits--.items
			FFFDragonLairWeyrRun.LootWindow:ShowOwnItems(true,false, itemList,playerName )	
			--d("showing own deposits")
		end
	else
		FFFDragonLairWeyrRun.ShowingGroup = true
		if FFFDragonLairWeyrRun.ShowingFarmed then
			local itemList = FFFDragonLairWeyrRun.Players[25].AllValuedLoot--.items
			FFFDragonLairWeyrRun.LootWindow:ShowOwnItems(false,true, itemList,playerName)
			--d("showing group items")
		else
			local itemList = FFFDragonLairWeyrRun.Players[25].GuildBankDeposits--.items
			FFFDragonLairWeyrRun.LootWindow:ShowOwnItems(false, false, itemList,playerName )	
			--d("showing group deposits")
		end
	end
end

function FFFDragonLairWeyrRun.ShowOwnDeposits()
	-- intially starts by showing farmed items as default
	if FFFDragonLairWeyrRun.ShowingFarmed then
		FFFDragonLairWeyrRun.ShowingFarmed = false
		--d("showing deposits")
	else
		FFFDragonLairWeyrRun.ShowingFarmed = true
		--d("showing farmed")
	end
	-- update lists
	FFFDragonLairWeyrRun.ShowingGroup = not FFFDragonLairWeyrRun.ShowingGroup
	FFFDragonLairWeyrRun.ShowOwnItems()
end

function FFFDragonLairWeyrRun.FindItemInBackpack(ItemToFindId)
	-- find and return bag slot with item in it
	--d("at the beginning")
	local srcBag = BAG_BACKPACK
	local bagCache = SHARED_INVENTORY:GenerateFullSlotData(nil, srcBag)
	d("looking for item in backpack")
	for _, data in pairs(bagCache) do
        local itemLink = GetItemLink(srcBag, data.slotIndex)
        local itemId = GetItemLinkItemId(itemLink)
        if itemId == ItemToFindId then 
			return data.slotIndex
        end
    end
	-- if not found then return nil
	--d("returning nil")
	return nil
	
end

function FFFDragonLairWeyrRun.ItemDeposit_GetItem(control)
	--d("First step is find/get items for deposit")
	-- get data from selected control 
	 
	FFFDragonLairWeyrRun.depositItem = {}
	FFFDragonLairWeyrRun.depositItem.itemInTransit = true
	FFFDragonLairWeyrRun.depositItem.itemLink = control:GetNamedChild("NameLabel"):GetText()
	-- needed to set tonumber as in lookups later it failed from string to number
	FFFDragonLairWeyrRun.depositItem.quantity = tonumber(control:GetNamedChild("CountsLabel"):GetText())
	FFFDragonLairWeyrRun.depositItem.itemId = tonumber(control:GetNamedChild("ItemId"):GetText()) 
	-- if quantity is greater than 200 then set to 200 max for transfer 
	--d(FFFDragonLairWeyrRun.depositItem.quantity)
	FFFDragonLairWeyrRun.depositQuantity = math.min(FFFDragonLairWeyrRun.depositItem.quantity, 200)
	-- craftbagable item may be left over from previous lootings and then will be found in backpack
	-- need to reduce craftbag total if found in backpack and craftbag total is non zero
	
	--d(FFFDragonLairWeyrRun.depositQuantity)
	FFFDragonLairWeyrRun.backpackSlot = FFFDragonLairWeyrRun.FindItemInBackpack(FFFDragonLairWeyrRun.depositItem.itemId)
	--d(FFFDragonLairWeyrRun.backpackSlot)
	if FFFDragonLairWeyrRun.backpackSlot == nil then 
		-- item not found in backpack
		-- check craftbagloot for item and transfer to backpack if found
		d("looking in craftbag loot list")
		local craftbagQuantity = FFFDragonLairWeyrRun.Players[1].CraftBagLoot[FFFDragonLairWeyrRun.depositItem.itemId]
		if craftbagQuantity ~= nil then
			-- found some that should be there so tranfer amount to backpack and get backpackSlot
			-- craftbagLoot quantity is reduced in MoveItemToBackpack function.
			FFFDragonLairWeyrRun.backpackSlot = FFFDragonLairWeyrRun.Players[1]:MoveItemToBackpack(FFFDragonLairWeyrRun.depositItem.itemId, FFFDragonLairWeyrRun.depositQuantity)
			--d("returned after transfer from backpack")
			
		end
		-- if item was found in backpack the quantity and adjustment to the craftbagLoot list will be made after successful deposit
	end
	--d(FFFDragonLairWeyrRun.backpackSlot)
	-- check if item was found or transfered from craftbag
	if FFFDragonLairWeyrRun.backpackSlot == nil then
		d("item has gone missing probably sold or destroyed, removing from loot.")
		-- do routine to remove items from loot list without deposit being triggered.
		local removedLoot = FFFDragonLairWeyrRun.Players[1]:SubtractFromAllValuedLoot(FFFDragonLairWeyrRun.depositItem.itemId,FFFDragonLairWeyrRun.depositQuantity)
		-- update players loot bargraph and remove from list
		FFFDragonLairWeyrRun.Players[1]:UpdateBar(removedLoot)
		if removedLoot.quantity == 0 then 
			FFFDragonLairWeyrRun.Players[1].AllValuedLoot.items[removedLoot.itemId] = nil
		end
		FFFDragonLairWeyrRun.depositItem.itemInTransit = false
		
		-- item will remain on group loot as a history but does not add to the deposit list
	else
		-- may need to wait for bag transfer to complete
		-- bpStackSize should be greater than 0 to get here
		--d("waiting for item transfer")
		EVENT_MANAGER:RegisterForUpdate(FFFDragonLairWeyrRun.name.."stack",300, function() checkStack() end)
		return
	end
	return
	
end

function FFFDragonLairWeyrRun.ItemDeposit_MakeDeposit()
	-- call to make guild bank deposit
	-- ready for deposit with depositQuantity and backpackSlot
	-- perform transfer
	d("starting transfer to guildbank")
	TransferToGuildBank(BAG_BACKPACK, FFFDragonLairWeyrRun.backpackSlot)
	-- we are listening to EVENT_GUILD_BANK_ITEM_ADDED for completion
	
	
end


function FFFDragonLairWeyrRun.CloseGuildBankDeposit()
	-- close guildbankdeposit window 
	EVENT_MANAGER:UnregisterForEvent(FFFDragonLairWeyrRun.name, EVENT_CLOSE_GUILD_BANK)
	FFFDragonLairWeyrRun.HideGuildBankDeposit()
	-- Stop listening for guild bank transfers
	EVENT_MANAGER:UnregisterForEvent(FFFDragonLairWeyrRun.name, EVENT_GUILD_BANK_ITEM_ADDED)
	
end

function FFFDragonLairWeyrRun.GuildBankItemAdded(event, slotId, addedByLocalPlayer, itemSoundCategory)
	-- looking for confirmation that bank item added.
	if addedByLocalPlayer and FFFDragonLairWeyrRun.depositItem.itemInTransit == true then
		d("Item Added to Guild Bank by local player")
	-- this is me
		local removedLoot = FFFDragonLairWeyrRun.Players[1]:SubtractFromAllValuedLoot(FFFDragonLairWeyrRun.depositItem.itemId,FFFDragonLairWeyrRun.depositQuantity)
		-- update players loot bargraph
		FFFDragonLairWeyrRun.Players[1]:UpdateBar(removedLoot)
		-- add deposited item to player guildbankdeposit
		FFFDragonLairWeyrRun.Players[1]:AddToGuildBankDeposits(removedLoot.itemLink, FFFDragonLairWeyrRun.depositQuantity, removedLoot.bar)
		-- and add to group guildbankdeposit
		FFFDragonLairWeyrRun.Players[25]:AddToGuildBankDeposits(removedLoot.itemLink, FFFDragonLairWeyrRun.depositQuantity, removedLoot.bar)
		-- remove item from player loot
		if removedLoot.quantity == 0 then 
			FFFDragonLairWeyrRun.Players[1].AllValuedLoot.items[removedLoot.itemId] = nil
		end
		FFFDragonLairWeyrRun.Players[1]:SubtractFromCraftBagLoot(FFFDragonLairWeyrRun.depositItem.itemId, FFFDragonLairWeyrRun.depositQuantity)
		-- update RawLootTransactions for the quantity deposited
		d(FFFDragonLairWeyrRun.myPlayerName, removedLoot.itemLink, FFFDragonLairWeyrRun.depositQuantity)
		FFFDragonLairWeyrRun.DepositTransaction(FFFDragonLairWeyrRun.myPlayerName,removedLoot.itemLink, FFFDragonLairWeyrRun.depositQuantity)
		
	-- update guildbank deposit window
		FFFDragonLairWeyrRun.GuildBankDeposit()
		-- "Deposited_In_Guild_Bank"..Quantity..ItemLink
		--CHAT_SYSTEM.textEntry:InsertLink(chatString)
		-- /g for group
		CHAT_SYSTEM.textEntry:InsertLink("/g ".."Deposited_In_Guild_Bank "..tostring(FFFDragonLairWeyrRun.depositQuantity).." "..tostring(FFFDragonLairWeyrRun.depositItem.itemLink))
		FFFDragonLairWeyrRun.depositItem.itemInTransit = false
		
	end
end


-- SLASH COMMANDS



function FFFDragonLairWeyrRun.GuildBankDeposit()
	-- open guild bank deposit window if at a guild bank
	if not IsGuildBankOpen() then return end
	-- get guild bank that is open to add to window title and for later transfer
	local guildBankId = GetSelectedGuildBankId()
	local guildName = GetGuildName(guildBankId)
	
	
	-- need to start looking for guildbank closed event to close bankdepositwindow if walk away
	EVENT_MANAGER:RegisterForEvent(FFFDragonLairWeyrRun.name, EVENT_CLOSE_GUILD_BANK, FFFDragonLairWeyrRun.CloseGuildBankDeposit)
	--
	-- start listening for guild bank deposits
	EVENT_MANAGER:RegisterForEvent(FFFDragonLairWeyrRun.name, EVENT_GUILD_BANK_ITEM_ADDED, FFFDragonLairWeyrRun.GuildBankItemAdded)
	--d("started listening for bank events")
	
	local itemList = FFFDragonLairWeyrRun.Players[1].AllValuedLoot--.items
	FFFDragonLairWeyrRun.GuildBankDepositWindow:ShowDepositItems(itemList)	
	FFFDragonLairWeyrRun.GuildBankDepositWindow:Show(guildName)
	-- keep ownitem lootwindow up to date if a deposit was made
	if not FFFDragonLairWeyrRun.ShowingGroup then
		-- showing farmed items
		if FFFDragonLairWeyrRun.ShowingFarmed then
			FFFDragonLairWeyrRun.LootWindow:ShowOwnItems(true,true, itemList)
		else
		-- leaving the index to the local player set to watch own deposits when at bank.
			local depositList = FFFDragonLairWeyrRun.Players[1].GuildBankDeposits--.items
			FFFDragonLairWeyrRun.LootWindow:ShowOwnItems(true,false, depositList)
		end
	else
	-- still showing group
	-- we are not changing the group farmed list, but the group deposit list would change
		if not FFFDragonLairWeyrRun.ShowingFarmed then
			local depositList = FFFDragonLairWeyrRun.Players[25].GuildBankDeposits--.items
			FFFDragonLairWeyrRun.LootWindow:ShowOwnItems(false,false, depositList)
		end
	end
end

function FFFDragonLairWeyrRun.HideGuildBankDeposit()
	FFFDragonLairWeyrRun.GuildBankDepositWindow:Hide()
	-- stop listening for guildbank closed event
end

function FFFDragonLairWeyrRun.ShowLeaderTotals()
	if FFFDragonLairWeyrRun.LeaderFarmed then
		-- was showing farmed now flip
		FFFDragonLairWeyrRun.LeaderFarmed = false
	else
		-- was showing deposits now flip
		FFFDragonLairWeyrRun.LeaderFarmed = true
	end
		
	FFFDragonLairWeyrRun.LeaderBoardWindow:ShowLeaderTotals(FFFDragonLairWeyrRun.LeaderFarmed)
end



function FFFDragonLairWeyrRun.ShowLeaderStanding()
	-- start a timed update function to update the leaderboard data every few seconds (TBD)
	FFFDragonLairWeyrRun.LeaderBoardWindow:Show()
	EVENT_MANAGER:RegisterForUpdate(FFFDragonLairWeyrRun.name.."leaders",2000, function() updateLeaders() end)
end

function FFFDragonLairWeyrRun.HideLeaderStanding()
	-- Stop a timed update function to update the leaderboard data every few seconds (TBD) and hide window
	EVENT_MANAGER:UnregisterForUpdate(FFFDragonLairWeyrRun.name.."leaders", updateLeaders)
	FFFDragonLairWeyrRun.LeaderBoardWindow:Hide()
	
end



function FFFDragonLairWeyrRun.ShowDetail()
	
	FFFDragonLairWeyrRun.LootWindow:Show()

end

function FFFDragonLairWeyrRun.HideDetail()
	FFFDragonLairWeyrRun.LootWindow:Hide()
end

function FFFDragonLairWeyrRun.ShowHoard()
	FFFDragonLairWeyrRun.tlw[7]:SetHidden(false)
	FFFDragonLairWeyrRun.Players[25]:Show()
end

function FFFDragonLairWeyrRun.HideHoard()
	FFFDragonLairWeyrRun.tlw[7]:SetHidden(true)
	FFFDragonLairWeyrRun.Players[25]:Hide()
end

function FFFDragonLairWeyrRun.Run()
	-- start applies for the entire addon with the exception of the onload which fires on startup from slash command /run
	
	EVENT_MANAGER:RegisterForEvent(FFFDragonLairWeyrRun.name, EVENT_LOOT_RECEIVED, FFFDragonLairWeyrRun.OnLootReceived)
	EVENT_MANAGER:RegisterForEvent(FFFDragonLairWeyrRun.name, EVENT_GROUP_UPDATE, FFFDragonLairWeyrRun.OnGroupUpdate)
	EVENT_MANAGER:RegisterForEvent(FFFDragonLairWeyrRun.name, EVENT_GROUP_MEMBER_JOINED, FFFDragonLairWeyrRun.OnMemberJoined)
	EVENT_MANAGER:RegisterForEvent(FFFDragonLairWeyrRun.name, EVENT_GROUP_MEMBER_LEFT, FFFDragonLairWeyrRun.OnMemberLeft)
	EVENT_MANAGER:RegisterForEvent(FFFDragonLairWeyrRun.name, EVENT_CHAT_MESSAGE_CHANNEL, FFFDragonLairWeyrRun.GroupChatMonitor)
	FFFDragonLairWeyrRun.OnGroupUpdate(EVENT_GROUP_UPDATE)
	FFFDragonLairWeyrRun.LootWindow:Show()
	FFFDragonLairWeyrRun.Players[25]:Show()
	FFFDragonLairWeyrRun.Players[1]:Show()
	FFFDragonLairWeyrRun.ShowLeaderStanding()
	d("Dragon Lair is the Best!")
	-- first time through this it will load from the saved variables then persistdata is set to false until next reloadui
	
	FFFDragonLairWeyrRun.RestoreLoot()
	FFFDragonLairWeyrRun.PersistData = false
	
end

function FFFDragonLairWeyrRun.Halt()
	-- Halt applies for the entire addon - from slash command /halt
	EVENT_MANAGER:UnregisterForEvent(FFFDragonLairWeyrRun.name, EVENT_LOOT_RECEIVED)
	EVENT_MANAGER:UnregisterForEvent(FFFDragonLairWeyrRun.name, EVENT_GROUP_UPDATE)
	EVENT_MANAGER:UnregisterForEvent(FFFDragonLairWeyrRun.name, EVENT_GROUP_MEMBER_JOINED)
	EVENT_MANAGER:UnregisterForEvent(FFFDragonLairWeyrRun.name, EVENT_GROUP_MEMBER_LEFT)
	EVENT_MANAGER:UnregisterForEvent(FFFDragonLairWeyrRun.name, EVENT_CHAT_MESSAGE_CHANNEL)
	EVENT_MANAGER:UnregisterForUpdate(FFFDragonLairWeyrRun.name.."leaders", updateLeaders)
end

function FFFDragonLairWeyrRun.LootStart()
	-- start loot tracking - from slash command /lootstart
	EVENT_MANAGER:RegisterForEvent(FFFDragonLairWeyrRun.name, EVENT_LOOT_RECEIVED, FFFDragonLairWeyrRun.OnLootReceived)
end

function FFFDragonLairWeyrRun.LootStop()
	-- stops listening to loot event from slash command /lootstop
	EVENT_MANAGER:UnregisterForEvent(FFFDragonLairWeyrRun.name, EVENT_LOOT_RECEIVED)
end



function FFFDragonLairWeyrRun.TransferItemToBackPack()
	-- rewrite of transfertobackpack()
	-- First call of this function is by the player with weyr xbp
	-- This function will continue to be called until CraftBagLoot is empty
	if FFFDragonLairWeyrRun.transferItem.InTransit == true then 
		return 
	else
		EVENT_MANAGER:UnregisterForUpdate(FFFDragonLairWeyrRun.name.."transfer",FFFDragonLairWeyrRun.TransferItemToBackPack)
	end
	if not HasCraftBagAccess() then return end
	
	local next = next
	if next(FFFDragonLairWeyrRun.Players[1].CraftBagLoot) == nil then
		-- CraftBagLoot is empty 
		d("Transfer is complete")
		-- unregister inventory event
		EVENT_MANAGER:UnregisterForEvent(FFFDragonLairWeyrRun.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		return
	end
	for itemId, itemQuantity in pairs(FFFDragonLairWeyrRun.Players[1].CraftBagLoot) do
		-- this will loop through all but we will exit after we get the first entry
		FFFDragonLairWeyrRun.transferItem.itemId = itemId
		if itemQuantity > 200 then 
			itemQuantity = 200
		end
		FFFDragonLairWeyrRun.transferItem.itemQuantity = itemQuantity
		break
	end
	
	if FFFDragonLairWeyrRun.transferItem.itemId ~= nil and FFFDragonLairWeyrRun.transferItem.InTransit == false then
		-- call for move
		FFFDragonLairWeyrRun.transferItem.InTransit = FFFDragonLairWeyrRun.MoveItemToBackpack()
		if not FFFDragonLairWeyrRun.transferItem.InTransit then
			d("Back pack could be full Transfer stopped")
			EVENT_MANAGER:UnregisterForEvent(FFFDragonLairWeyrRun.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
			return
		end
	else 
		d("Transfers are done")
		-- this might be a problem if freezes, not sure if this ever hits.
		EVENT_MANAGER:UnregisterForEvent(FFFDragonLairWeyrRun.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		return
	end
	-- item is in transit
	EVENT_MANAGER:RegisterForUpdate(FFFDragonLairWeyrRun.name.."transfer",300, function() FFFDragonLairWeyrRun.TransferItemToBackPack() end)
	
end

function FFFDragonLairWeyrRun.inventorySlotUpdate(event, bagId, slotId, isNewItem, itemSoundCategory,inventoryUpdateReason,stackCountChange)
	--EVENT_INVENTORY_SINGLE_SLOT_UPDATE (number eventCode, Bag bagId, number slotId, boolean isNewItem, ItemUISoundCategory itemSoundCategory, number inventoryUpdateReason, number stackCountChange)
	local transferedItemLink = GetItemLink(bagId, slotId)
	local transferedItemId = GetItemLinkItemId(transferedItemLink)
	if transferedItemId == FFFDragonLairWeyrRun.transferItem.itemId then
		-- same item. Adjust craftbagloot 
		-- then set the intransit to false. and set the craftbagloot item to nil if 0 quantity
		
		local cbQuantity = FFFDragonLairWeyrRun.Players[1].CraftBagLoot[transferedItemId]
		FFFDragonLairWeyrRun.Players[1].CraftBagLoot[transferedItemId] = cbQuantity - stackCountChange
		if FFFDragonLairWeyrRun.Players[1].CraftBagLoot[transferedItemId] <= 0 then
			FFFDragonLairWeyrRun.Players[1].CraftBagLoot[transferedItemId] = nil
		end
		FFFDragonLairWeyrRun.transferItem.InTransit = false
	end
	
end
function FFFDragonLairWeyrRun.MoveItemToBackpack()
	-- function that finds the item in the craftbag and starts the move to the backpack
	local craftbag = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_VIRTUAL)
	if craftbag == nil then return end
	-- find item in craftbag
	for _, slotdata in pairs(craftbag)  do
		local itemLink = GetItemLink(BAG_VIRTUAL, slotdata.slotIndex)
		local cbItemId = GetItemLinkItemId(itemLink)
		if cbItemId == FFFDragonLairWeyrRun.transferItem.itemId then
			-- found item in craftbag
			local destSlot = FindFirstEmptySlotInBag(BAG_BACKPACK)
			-- backpack is full if no free slot found
			if destSlot == nil then return false end
			local cbQuantity = GetSlotStackSize(BAG_VIRTUAL, slotdata.slotIndex)
			if cbQuantity < FFFDragonLairWeyrRun.transferItem.itemQuantity then
				-- if there is not enough in the craftbag then only move what is there.
				FFFDragonLairWeyrRun.transferItem.itemQuantity = cbQuantity
			end
			-- call to make the move, which does not happen right away.
			-- start listening for inventory slot updates filtered to reduce traffic
			EVENT_MANAGER:RegisterForEvent(FFFDragonLairWeyrRun.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, FFFDragonLairWeyrRun.inventorySlotUpdate)
			EVENT_MANAGER:AddFilterForEvent(FFFDragonLairWeyrRun.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, false)
			EVENT_MANAGER:AddFilterForEvent(FFFDragonLairWeyrRun.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
			EVENT_MANAGER:AddFilterForEvent(FFFDragonLairWeyrRun.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
			
			if IsProtectedFunction("RequestMoveItem") then
				CallSecureProtected("RequestMoveItem", BAG_VIRTUAL, slotdata.slotIndex, BAG_BACKPACK, destSlot,FFFDragonLairWeyrRun.transferItem.itemQuantity)
			else
				RequestMoveItem(BAG_VIRTUAL, slotdata.slotIndex, BAG_BACKPACK,destSlot,itemQuantity)
			end
			FFFDragonLairWeyrRun.transferItem.backpackSlot = destSlot
			-- now we need to listen for the player inventory to update
			-- return true as item is in transit
			return true
		end
		
	end
	
end

function FFFDragonLairWeyrRun.TransferToBackPack()
	-- transfer own player loot to backpack from slash command /xbp
	--d(tostring(FFFDragonLairWeyrRun.Players[1]:IsLootedLootEmpty()))
	d("Transfering to backpack")
	FFFDragonLairWeyrRun.TransferItemToBackPack()

	-- as items are moved if there were more than a single stack there will be items left in the LootedList, so loop on the move until fully empty
	--while not FFFDragonLairWeyrRun.Players[1]:IsLootedLootEmpty() do 
	-- while not FFFDragonLairWeyrRun.Players[1]:IsCraftBagLootEmpty() do 
		-- d("A bit more to go")
		-- FFFDragonLairWeyrRun.Players[1]:MoveToBackpack()
		
	-- end
	--d(tostring(FFFDragonLairWeyrRun.Players[1]:IsLootedLootEmpty()))
	--d("Transfering to backpack Complete")
end

function FFFDragonLairWeyrRun.Reset()
	-- reset all values and controls to 0 from slash command /reset
	-- does not clear members or consolidate the members to tighter teams
	-- does not clear the persitent data RawLootTransactions
	
	for player, value in pairs(FFFDragonLairWeyrRun.PlayerIndex) do
		FFFDragonLairWeyrRun.InitPlayer(player, value)
	end
	FFFDragonLairWeyrRun.LootWindow:Reset()
	FFFDragonLairWeyrRun.LeaderBoardWindow:Reset()
	FFFDragonLairWeyrRun.TimeStarted = 0--GetTimeStamp()
	FFFDragonLairWeyrRun.formatLootTime(FFFDragonLairWeyrRun.TimeStarted)
	FFFDragonLairWeyrRun.lblLootTime:SetText(FFFDragonLairWeyrRun.formatLootTime(FFFDragonLairWeyrRun.TimeStarted))
	
	
end

function FFFDragonLairWeyrRun.Quit()
	-- Quit applies for the entire addon - from slash command /quit
	-- Resets and stops all event listening and hides all controls
	EVENT_MANAGER:UnregisterForEvent(FFFDragonLairWeyrRun.name, EVENT_LOOT_RECEIVED)
	EVENT_MANAGER:UnregisterForEvent(FFFDragonLairWeyrRun.name, EVENT_GROUP_UPDATE)
	EVENT_MANAGER:UnregisterForEvent(FFFDragonLairWeyrRun.name, EVENT_GROUP_MEMBER_JOINED)
	EVENT_MANAGER:UnregisterForEvent(FFFDragonLairWeyrRun.name, EVENT_GROUP_MEMBER_LEFT)
	EVENT_MANAGER:UnregisterForEvent(FFFDragonLairWeyrRun.name, EVENT_CHAT_MESSAGE_CHANNEL)
	--
	FFFDragonLairWeyrRun.Reset()
	FFFDragonLairWeyrRun.LeaderBoardWindow:Reset()
	-- need to inactivate player too, not including self and group
	for i = 2, 24 do
		FFFDragonLairWeyrRun.ActivePlayer[i] = false
		
	end
	for player, value in pairs(FFFDragonLairWeyrRun.PlayerIndex) do
		FFFDragonLairWeyrRun.PlayerIndex[player] = nil
	end
	FFFDragonLairWeyrRun.PlayerIndex[FFFDragonLairWeyrRun.myPlayerName] = 1	
	
	-- and initialize player
	FFFDragonLairWeyrRun.InitPlayer(FFFDragonLairWeyrRun.myPlayerName, 1)
	
	-- Setup the Dragon Hoard - the grand total list  no @name on this one to protect it from others
	FFFDragonLairWeyrRun.PlayerIndex["Dragon Hoard"] = 25
	FFFDragonLairWeyrRun.InitPlayer("Dragon Hoard", 25)
	
	for i = 1 , 7 do
		FFFDragonLairWeyrRun.tlw[i]:SetHidden(true)
	end
	for i = 1, 25 do
		FFFDragonLairWeyrRun.Players[i]:Hide()
	end
	FFFDragonLairWeyrRun.LootWindow:Hide()
	FFFDragonLairWeyrRun.HideLeaderStanding()
	FFFDragonLairWeyrRun.PersistData = true
end

function FFFDragonLairWeyrRun.RestoreLoot()

	if FFFDragonLairWeyrRun.PersistData == false then return end
	
	FFFDragonLairWeyrRun.RawLootTransactions = nil
	FFFDragonLairWeyrRun.RawLootTransactions = RawLootPlayerList:New() 
	
	local Loot = FFFDragonLairWeyrRun.savedVariables.Loot
	if Loot == nil then return end
	local players = Loot.players
	
	for player, rll in pairs(players) do
		local playerIndex = FFFDragonLairWeyrRun.PlayerIndex[player]
		-- need to check if playerindex is nil.  If it is we dont add this player back to loottransactions.
		if playerIndex ~= nil then
			local addedplayer = FFFDragonLairWeyrRun.RawLootTransactions:Add(player)
			local items = rll.rawLootList.items
			for itemId, loot in pairs(items) do
				local addeditem = addedplayer.rawLootList:Add(loot.itemLink, loot.lootquantity, loot.depositquantity)
				
				local itemType,itemSpecialType = GetItemLinkItemType(addeditem.itemLink)
				
				local specialLoot = desiredSpecializedTypes[itemSpecialType]
				
				if playerIndex == 1 and GetSetting_Bool(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_ADD_TO_CRAFT_BAG) and CanItemLinkBeVirtual(addeditem.itemLink) and HasCraftBagAccess() then
					-- add item to craftbagloot
					if addeditem.lootquantity > 0 then 
						FFFDragonLairWeyrRun.Players[playerIndex]:AddToCraftBagLoot(addeditem.itemLink, addeditem.lootquantity)
					-- craftbagloot only carries ItemId and quantity for later retrieval from craftbag to backpack
					end
				end
				-- add to allvaluedloot in all cases
				if addeditem.lootquantity > 0 then 
					local lootItem = FFFDragonLairWeyrRun.Players[playerIndex]:AddToAllValuedLoot(addeditem.itemLink, addeditem.lootquantity, specialLoot.bar)
					local grouplootItem = FFFDragonLairWeyrRun.Players[25]:AddToAllValuedLoot(addeditem.itemLink, addeditem.lootquantity, specialLoot.bar)
					-- update player tile bar graphs
					FFFDragonLairWeyrRun.Players[playerIndex]:UpdateBar(lootItem) 	
					FFFDragonLairWeyrRun.Players[25]:UpdateBar(grouplootItem) 
				end
				-- and add to guildbankdeposits for player
				if addeditem.depositquantity > 0 then
					local depositItem = FFFDragonLairWeyrRun.Players[playerIndex]:AddToGuildBankDeposits(addeditem.itemLink, addeditem.depositquantity, specialLoot.bar)
					local groupdepositItem = FFFDragonLairWeyrRun.Players[25]:AddToGuildBankDeposits(addeditem.itemLink, addeditem.depositquantity, specialLoot.bar)
				end
				
			end
		else
			-- here if the player not indexed.. ie not in group then remove their loot data
			d(player.. " no longer in group and data removed")
			player = nil
		
		end
	end
	FFFDragonLairWeyrRun.savedVariables.Loot = FFFDragonLairWeyrRun.RawLootTransactions
	FFFDragonLairWeyrRun.ShowOwnItems()
end

function FFFDragonLairWeyrRun.ClearLoot()
	-- clear RawLootTransactions
	FFFDragonLairWeyrRun.RawLootTransactions = RawLootPlayerList:New()
	FFFDragonLairWeyrRun.savedVariables.Loot = FFFDragonLairWeyrRun.RawLootTransactions
	FFFDragonLairWeyrRun.Reset()
	
end

FFFDragonLairWeyrRun.commands = {
	["showdetail"] = FFFDragonLairWeyrRun.ShowDetail,
	["hidedetail"] = FFFDragonLairWeyrRun.HideDetail,
	["showhoard"] = FFFDragonLairWeyrRun.ShowHoard,
	["hidehoard"] = FFFDragonLairWeyrRun.HideHoard,
	["run"] = FFFDragonLairWeyrRun.Run,
	["halt"] = FFFDragonLairWeyrRun.Halt,
	["lootstart"] = FFFDragonLairWeyrRun.LootStart,
	["lootstop"] = FFFDragonLairWeyrRun.LootStop,
	["xbp"] = FFFDragonLairWeyrRun.TransferToBackPack,
	["showleaders"] = FFFDragonLairWeyrRun.ShowLeaderStanding,
	["hideleaders"] = FFFDragonLairWeyrRun.HideLeaderStanding,
	["deposit"] = FFFDragonLairWeyrRun.GuildBankDeposit,
	["reset"] = FFFDragonLairWeyrRun.Reset,
	["clearloot"] = FFFDragonLairWeyrRun.ClearLoot,
	["quit"] = FFFDragonLairWeyrRun.Quit
	
}
--["restoreloot"] = FFFDragonLairWeyrRun.RestoreLoot,
SLASH_COMMANDS["/weyr"] = function(arg)
    if not arg or arg == "" then
        d("Invalid Command")
    else
        local handle
		local actualArgs = ""
		local argIterator = arg:gmatch("%S+")
		local count = 0
		for s in argIterator do
			if not handle then
				handle = s
			else
				count = count + 1
				if count > 1 then actualArgs = actualArgs.." " end
				actualArgs = actualArgs..s
			end
		end

		local func = FFFDragonLairWeyrRun.commands[handle:lower()]
		if func ~= nil then
			func(actualArgs)
		else
            d("Valid Commands are:")
			d("/weyr showdetail - shows detail item panel")
			d("/weyr hidedetail - hides detail item panel")
			d("/weyr showhoard - shows hoard total bar graph panel")
			d("/weyr hidehoard - hides hoard total bar graph panel")
			d("/weyr run - starts the addon, shows windows")
			d("/weyr halt - stops the addon from event updates")
			d("/weyr lootstart - starts loot tracking if disabled by loot stop")
			d("/weyr lootstop - stop loot tracking, group events still active")
			d("/weyr xbp - transfer looted items from craftbag to backpack")
			d("/weyr showleaders - shows leader board")
			d("/weyr hideleaders - hides leader board")
			d("/weyr deposit - when at a guild bank starts deposit windows")
			d("/weyr reset - reset all player panels and detail list to zero")
			d("/weyr clearloot - resets all persistant data, do this before a run")
			d("/weyr quit - stops all tracking, resets all data to zero, hides all windows")
			
		end
		--d("/weyr report - report all player results")
	end
end

	

function FFFDragonLairWeyrRun.InitPlayer(playername, index)
	-- Set up default playerControl to provided playername 
	-- Also used to clear old member data 
	-- (remember to set active index to false (from calling location) if just clearing old member data)
	FFFDragonLairWeyrRun.Players[index]:InitPlayer(playername)
	FFFDragonLairWeyrRun.ActivePlayer[index] = true
end

function FFFDragonLairWeyrRun.AddPlayerToIndex(playername, playerCharName)
	--d("adding player "..playername)
	-- add player to player list
	
	--GetUnitDisplayName(string unitTag)   Return @name from a unitTag
	--Returns: string displayName
	-- create a name mapping from @name to charname
	
	FFFDragonLairWeyrRun.PlayerNameMapping[playerCharName] = playername
	
	-- playerIndex contains the @name and the index number of which playercontrol they occupy	
	
	-- need to know what index to give new player
	k=1
	for value, active in ipairs(FFFDragonLairWeyrRun.ActivePlayer) do
		--d(value, active)
		-- looking for first false active.
		if not active then 
			k = value
			break
		end
	end
	--d("adding player "..playername.." to index "..tostring(k))
	
	-- set player index to first inactive slot
	FFFDragonLairWeyrRun.PlayerIndex[playername] = k
	-- and initialize control
	FFFDragonLairWeyrRun.InitPlayer(playername, k)
	
end

function FFFDragonLairWeyrRun.ShowOccupiedGroups()
	-- show team windows that have players 
	-- Currently players are sequentially added base 4
	-- first hide all but the main player window Team 1
	for i = 1,7 do
		FFFDragonLairWeyrRun.tlw[i]:SetHidden(true)
	end
	
	for player,value in pairs(FFFDragonLairWeyrRun.PlayerIndex) do
		-- 
		local teamNumber = math.ceil(value/4)
		FFFDragonLairWeyrRun.tlw[teamNumber]:SetHidden(false)
	end
	
	
end


function FFFDragonLairWeyrRun.GroupChatMonitor(event, channelType, fromName, messageText, isCustomerService, fromDisplayName)
	-- monitor group chat for messageText starting with "Deposited_In_Guild_Bank"
	-- change to CHAT_CHANNEL_PARTY after testing is done. 
	if channelType ~= CHAT_CHANNEL_PARTY then return end
	--if channelType ~= CHAT_CHANNEL_SAY then return end
	-- split message string 
	local testString, quantity, itemLink =  SplitString(" ", messageText)
	if testString ~= "Deposited_In_Guild_Bank" then return end
	-- get player index from the fromDisplayName
	local playerIndex = FFFDragonLairWeyrRun.PlayerIndex[fromDisplayName]
	-- if playerIndex == 1 then this is self so dont remove item as it was removed / added at time of deposit
	--d(playerIndex, testString, quantity, itemLink)
	if playerIndex ~= 1 then
	-- now need to remove quantity deposited from player at playerindex and player[25]
		local itemId = GetItemLinkItemId(itemLink)
		local removedLoot = FFFDragonLairWeyrRun.Players[playerIndex]:SubtractFromAllValuedLoot(itemId,quantity)
		if removedLoot ~= nil then 
		
			-- update players loot bargraph
			FFFDragonLairWeyrRun.Players[playerIndex]:UpdateBar(removedLoot)
			-- add deposited item to player guildbankdeposit
			FFFDragonLairWeyrRun.Players[playerIndex]:AddToGuildBankDeposits(removedLoot.itemLink, quantity, removedLoot.bar)
			-- and add to group guildbankdeposit
			FFFDragonLairWeyrRun.Players[25]:AddToGuildBankDeposits(removedLoot.itemLink, quantity, removedLoot.bar)
			-- remove item from player loot
			if removedLoot.quantity == 0 then 
				FFFDragonLairWeyrRun.Players[playerIndex].AllValuedLoot.items[removedLoot.itemId] = nil
			end
		else
			-- if removedLoot is nil then localplayer does not have record of looting but should still record the deposit.
			-- setting bar to 1 as a placeholder
			FFFDragonLairWeyrRun.Players[playerIndex]:AddToGuildBankDeposits(itemLink, quantity, 1)
			-- and add to group guildbankdeposit
			FFFDragonLairWeyrRun.Players[25]:AddToGuildBankDeposits(itemLink, quantity, 1)
			
		end
		-- now update the deposited quantity in the RawLootTransactions for group players only
		FFFDragonLairWeyrRun.DepositTransaction(fromDisplayName, itemLink, quantity)
	end
	-- refresh group deposit item lists
	if not FFFDragonLairWeyrRun.ShowingFarmed then
		local depositList = FFFDragonLairWeyrRun.Players[25].GuildBankDeposits--.items
		FFFDragonLairWeyrRun.LootWindow:ShowOwnItems(false,false, depositList)
	end
		
end




function FFFDragonLairWeyrRun.OnGroupUpdate(event)
	-- this event fires when you join a group and when someone in zones in the group
	-- Also fires when someone else joins or leaves the group
	-- This does not fire when you invite someone to the group or if you leave the group
	EVENT_MANAGER:UnregisterForEvent(FFFDragonLairWeyrRun.name, EVENT_LOOT_RECEIVED)
	-- check group to player list 
	--d("Group Update")
	local groupSize = GetGroupSize() -- this max is 24 (currently) if it increases we need to move our 'Dragon Hoard'
	for i = 1, groupSize do
		-- using @membername
		
		playername = GetUnitDisplayName("group"..i)
		playerCharName = GetUnitName("group"..i)
		
		--d("this is playername "..playername.." and char name is ".. playerCharName)
		
		if FFFDragonLairWeyrRun.PlayerIndex[playername] == nil then
			-- not in list so add player
			FFFDragonLairWeyrRun.AddPlayerToIndex(playername, playerCharName)
		end		
	end
	FFFDragonLairWeyrRun.ShowOccupiedGroups()
	EVENT_MANAGER:RegisterForEvent(FFFDragonLairWeyrRun.name, EVENT_LOOT_RECEIVED, FFFDragonLairWeyrRun.OnLootReceived)
end


function FFFDragonLairWeyrRun.OnMemberLeft(event, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
	--EVENT_GROUP_MEMBER_LEFT (number eventCode, string memberCharacterName, GroupLeaveReason reason, boolean isLocalPlayer, boolean isLeader, string memberDisplayName, boolean actionRequiredVote)
	-- if the local player left we want to remove everyone from the player list except the local player.
	if isLocalPlayer then
		d(" leaving group .. "..memberDisplayName)
		-- do nothing
	else
		-- if someone else leave we need to remove the one
		-- when local player leaves this event fires for each other member as they are leaving the group as well.
		--d("memberCharacterName to remove= ".. memberCharacterName:gsub("%^%a+$", "", 1))
		local playerToRemove = memberDisplayName --the @name
		local playercharToRemove = memberCharacterName:gsub("%^%a+$", "", 1)
		local index = FFFDragonLairWeyrRun.PlayerIndex[playerToRemove]
		--d("member index was ..".. tostring(index))
		-- clear control and hide
		-- want to remove players items from AllValuedLoot from Player 25.
		-- have playerindex and valued items, remove from AllValuedLoot
		for _, item in pairs(FFFDragonLairWeyrRun.Players[index].AllValuedLoot.items) do
			local grouplootItem = FFFDragonLairWeyrRun.Players[25]:SubtractFromAllValuedLoot(item.itemId, item.quantity)
			FFFDragonLairWeyrRun.Players[25]:UpdateBar(grouplootItem)
			-- if we want the zero quantity items to be removed from the group loot 
			-- it needs to be after the bar graph was updated.
			-- so here
			-- check if item quantity is zero and set to nil if true
			--
			
		end
		-- show updated group items
		FFFDragonLairWeyrRun.ShowingGroup = false
		FFFDragonLairWeyrRun.ShowOwnItems()
		
		
		FFFDragonLairWeyrRun.InitPlayer("Dragon "..index, index)
		FFFDragonLairWeyrRun.Players[index]:Hide()
		-- set player active status to false as the initplayer function sets it to true by default
		FFFDragonLairWeyrRun.ActivePlayer[index] = false
		-- and remove player from Players list
		FFFDragonLairWeyrRun.PlayerNameMapping[playercharToRemove] = nil
		FFFDragonLairWeyrRun.PlayerIndex[playerToRemove] = nil
		--d(tostring(FFFDragonLairWeyrRun.PlayerIndex[playerToRemove]).."in index "..index)
		-- and remove loot transactions from player that has left group
		FFFDragonLairWeyrRun.RawLootTransactions[playerToRemove] = nil
		FFFDragonLairWeyrRun.savedVariables.Loot = FFFDragonLairWeyrRun.RawLootTransactions
	end
	FFFDragonLairWeyrRun.ShowOccupiedGroups()
end

function FFFDragonLairWeyrRun.OnMemberJoined(event, memberCharacterName, memberDisplayName, isLocalPlayer)
	--EVENT_GROUP_MEMBER_JOINED (number eventCode, string memberCharacterName, string memberDisplayName, boolean isLocalPlayer)
	
	--(when you start a new group you add first) as in isLocalPlayer = true
	if isLocalPlayer then return end
	local playername = memberDisplayName--memberCharacterName:gsub("%^%a+$", "", 1)
	local playerCharName = memberCharacterName:gsub("%^%a+$", "", 1)
	if FFFDragonLairWeyrRun.PlayerIndex[playername] == nil then
		-- not in list so add player
		FFFDragonLairWeyrRun.AddPlayerToIndex(playername, playerCharName)
	end	
	FFFDragonLairWeyrRun.ShowOccupiedGroups()
	
	
end


function FFFDragonLairWeyrRun.OnLootReceived(event, lootedBy, itemName, quantity, itemSound, lootType, isMe ,isPickPocketLoot, questicon, itemId,isStolen)
	--EVENT_LOOT_RECEIVED (number eventCode, string receivedBy, string itemName, number quantity, ItemUISoundCategory soundCategory, LootItemType lootType, boolean self, boolean isPickpocketLoot, string questItemIcon, number itemId, boolean isStolen)
	--d("loot by" .. lootedBy:gsub("%^%a+$", "", 1))
	-- is item Bound? if so dont track
	local index = FFFDragonLairWeyrRun.ShowingPlayerIndex
	
	if IsItemLinkBound(itemName) then return end
	--get type
	local itemType,itemSpecialType = GetItemLinkItemType(itemName)
	-- check if loot is desired to be tracked end if not in desired list
	local desiredLoot = desiredItemTypes[itemType]
	
	if desiredLoot == nil or desiredLoot.desired == false then return end
	-- desired item and in list
	local specialLoot = desiredSpecializedTypes[itemSpecialType]
	--d(specialLoot)
	-- check quality
	local itemQuality = GetItemLinkQuality(itemName)
	if itemQuality < specialLoot.quality then return end
	-- quality passed.
	
	-- which player looted
	local playerIndex = 0
	local atPlayerName = FFFDragonLairWeyrRun.PlayerNameMapping[lootedBy:gsub("%^%a+$", "", 1)]
	if isMe then
		playerIndex = 1
	-- set own free bag space on main window
		FFFDragonLairWeyrRun.freeBagSlots = FFFDragonLairWeyrRun.GetFreeBagSlots()
		FFFDragonLairWeyrRun.lblBagSpace:SetText(FFFDragonLairWeyrRun.freeBagSlots)
		-- for local player check if craftbag is being used.
		if GetSetting_Bool(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_ADD_TO_CRAFT_BAG) and CanItemLinkBeVirtual(itemName) and HasCraftBagAccess() then
			-- add item to craftbagloot
			FFFDragonLairWeyrRun.Players[playerIndex]:AddToCraftBagLoot(itemName, quantity)
			-- craftbagloot only carries ItemId and quantity for later retrieval from craftbag to backpack
		end
	else
		--local atPlayerName = FFFDragonLairWeyrRun.PlayerNameMapping[lootedBy:gsub("%^%a+$", "", 1)]	
		playerIndex = FFFDragonLairWeyrRun.PlayerIndex[atPlayerName]
	end
	-- have playerindex and valued item add to AllValuedLoot
	-- add to the RawLootTransactions at this time as well
	local rawloot = FFFDragonLairWeyrRun.LootTransaction(atPlayerName, itemName, quantity)
	
	local lootItem = FFFDragonLairWeyrRun.Players[playerIndex]:AddToAllValuedLoot(itemName, quantity, specialLoot.bar)
	local grouplootItem = FFFDragonLairWeyrRun.Players[25]:AddToAllValuedLoot(itemName, quantity, specialLoot.bar)
	-- this contains all types of valued items with item values.
	
	-- now update the appropriate itemlist in the details window
	if FFFDragonLairWeyrRun.ShowingGroup then
		FFFDragonLairWeyrRun.LootWindow:OnItemFarmed(grouplootItem, FFFDragonLairWeyrRun.Players[25].AllValuedLoot:ItemListTotal())
	elseif not FFFDragonLairWeyrRun.ShowingGroup and playerIndex == index then
		-- showing self only
		FFFDragonLairWeyrRun.LootWindow:OnItemFarmed(lootItem, FFFDragonLairWeyrRun.Players[index].AllValuedLoot:ItemListTotal())
	end
	
	-- update player tile bar graphs
	FFFDragonLairWeyrRun.Players[playerIndex]:UpdateBar(lootItem) 	
	FFFDragonLairWeyrRun.Players[25]:UpdateBar(grouplootItem) 
	
	-- update lootTimer
	-- if this is the first looting
	if FFFDragonLairWeyrRun.TimeStarted == 0 then
		FFFDragonLairWeyrRun.TimeStarted = GetTimeStamp()
	else
		FFFDragonLairWeyrRun.lblLootTime:SetText(FFFDragonLairWeyrRun.formatLootTime(GetTimeStamp() - FFFDragonLairWeyrRun.TimeStarted))
	end
	
end

function FFFDragonLairWeyrRun.LootTransaction(atPlayerName, itemName, quantity)
	-- get local reference
	local player = FFFDragonLairWeyrRun.RawLootTransactions:Add(atPlayerName)
	-- add the item they looted.
	local item = player.rawLootList:Add(itemName, quantity,0)
	
	FFFDragonLairWeyrRun.savedVariables.Loot = FFFDragonLairWeyrRun.RawLootTransactions
	return item
end

function FFFDragonLairWeyrRun.DepositTransaction(atPlayerName, itemName, quantity)
	-- get local reference
	local player = FFFDragonLairWeyrRun.RawLootTransactions:Add(atPlayerName)
	-- add the item they deposited.
	local item = player.rawLootList:Deposit(itemName, quantity)
	
	FFFDragonLairWeyrRun.savedVariables.Loot = FFFDragonLairWeyrRun.RawLootTransactions
	return item
end

EVENT_MANAGER:RegisterForEvent(FFFDragonLairWeyrRun.name, EVENT_ADD_ON_LOADED, FFFDragonLairWeyrRun.OnAddOnLoaded)
--
--Events are controlled by /commands 
--
--EVENT_MANAGER:RegisterForEvent(FFFDragonLairWeyrRun.name, EVENT_LOOT_RECEIVED, FFFDragonLairWeyrRun.OnLootReceived)
--EVENT_MANAGER:RegisterForEvent(FFFDragonLairWeyrRun.name, EVENT_GROUP_UPDATE, FFFDragonLairWeyrRun.OnGroupUpdate)
--EVENT_MANAGER:RegisterForEvent(FFFDragonLairWeyrRun.name, EVENT_GROUP_MEMBER_JOINED, FFFDragonLairWeyrRun.OnMemberJoined)
--EVENT_MANAGER:RegisterForEvent(FFFDragonLairWeyrRun.name, EVENT_GROUP_MEMBER_LEFT, FFFDragonLairWeyrRun.OnMemberLeft)
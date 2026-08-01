local GS = GetString
local CS = CraftStoreFixedAndImprovedLongClassName

local myAccentColor = "9e0911"
local myTextColor = "1d6dad"
local cll = CarosLootList

local cllD = cll.cllD
local cllPost = cll.cllPost

local craftsForDecon = {
	[CRAFTING_TYPE_BLACKSMITHING] = true,
	[CRAFTING_TYPE_CLOTHIER] = true,
	[CRAFTING_TYPE_INVALID] = true,
	[CRAFTING_TYPE_JEWELRYCRAFTING] = true,
	[CRAFTING_TYPE_WOODWORKING] = true,
}

local craftsForGlyphDecon = {
	[CRAFTING_TYPE_ENCHANTING] = true,
	[CRAFTING_TYPE_INVALID] = true,
}
	
function cll.cllButton()

	local lastFunctions = cll.sV.lastFunctions
	local lastFunctions2 = cll.sV.lastFunctions2
	local lastFunctions3 = cll.sV.lastFunctions3
	local lastFunctions4 = cll.sV.lastFunctions4

	if cll.optionButton then 
		cll.optionButton:SetHidden(not cll.sV.showButton) 
		cll.optionButton:ClearAnchors()
		cll.optionButton:SetAnchor(TOPRIGHT, ZO_ChatWindow, TOPRIGHT, -40 - cll.sV.buttonOffset, 6)
		return 
	end
	if not  cll.sV.showButton then return end
	cll.optionButton = WINDOW_MANAGER:CreateControl(nil, ZO_ChatWindow, CT_BUTTON)
	
	
	local function bankSplitArgsText(args, startFromSecond)
		local argTable = {}
		for i, arg in pairs(args) do
			if string.sub(arg, 4, 4) == ":" then
				argTable[string.sub(arg,1,3)] = tonumber(string.sub(arg, 5))
			else
				argTable[arg] = i
			end
		end
		local splitTexts = {
			{
				{"retr", string.format(GS(CLL_LCM_Bank_Retrieve))},
				{"depo", string.format(GS(CLL_LCM_Bank_Deposit))},
			},
			{
				{"writs", GS(SI_ITEMTYPEDISPLAYCATEGORY25)},
				{"recipes", GS(SI_ITEMTYPEDISPLAYCATEGORY21)},
				{"motifs", GS(SI_ITEMTYPEDISPLAYCATEGORY24)},
				{"furniture", GS(SI_RECIPECRAFTINGSYSTEM6)},
				{"style", GS(SI_COLLECTIBLECATEGORYTYPE24)},
			},
			{
				{"known", GS(CLL_CustBank_Known)},
				{"unknown", GS(CLL_CustBank_Unknown)},
				{"filterForPriceHigherThan", function() return argTable.pll and string.format("%s%s", GS(CLL_CustBank_FilterForPriceHigher), argTable.pll) end},
				{"filterForPriceLowerThan", function() return argTable.pul and string.format("%s%s", GS(CLL_CustBank_FilterForPriceLower), argTable.pul) end},
				{"filterForCostHigherThan", function() return argTable.cll and string.format("%s%s", GS(CLL_CustBank_FilterForCostHigher), argTable.cll) end},
				{"filterForCostLowerThan", function() return argTable.cul and string.format("%s%s", GS(CLL_CustBank_FilterForCostLower), argTable.cul) end},
				{"filterForMain", GS(CLL_CustBank_FilterForMain)},
				{"autoLearn", GS(CLL_CustBank_AutoLearn)},
			}
		}
		local textTable = {}
		local formatters = {"%s:", "%s", "(%s)"}
		startFromSecond = startFromSecond and 2 or 1
		for i = startFromSecond, #splitTexts do
			local subTable = {}
			for _, w in ipairs(splitTexts[i]) do
				if argTable[w[1]] then 
					if type(w[2]) == "function" then
						local returnText = w[2]()
						if returnText then table.insert(subTable, returnText) end
					else
						table.insert(subTable, w[2])
					end
				end
			end
			if #subTable > 0 then
				table.insert(textTable, string.format(formatters[i], table.concat(subTable, ", ")))
			end
		end
		
		return table.concat(textTable, " ")
	end
	
	local function bankSplitArgsFunction(args)
		local argTable = {}
		for i, v in ipairs(args) do
			if string.sub(v, 4, 4) == ":" then
				argTable[string.sub(v,1,3)] = tonumber(string.sub(v, 5))
			else
				argTable[v] = i
			end
		end
		cll.transferCustom(argTable)
	end
		
	local cllMyFunctions = {
		CLL_LCM_Post = function() cll.lootPost() end,
		CLL_LCM_PostAll = function() cll.lootPost("all") end,
		CLL_LCM_Current = function() cll.lootPost("current") end,
		CLL_LCM_Mawa = function() cll.lootPost("mawa") end,
		CLL_LCM_Batman = function() cll.lootPost("batman") end,
		CLL_LCM_NoArmor = function() cll.lootPost("noArmor") end,
		CLL_LCM_BindAll = function() cll.lootBind() end,
		CLL_LCM_BindPost = function() cll.lootBindPost() end,
		CLL_LCM_BindPostCurr = function() cll.lootBindPost("current") end,
		CLL_LCM_Furniture = function() cll.lootPost("furniture") end,
		CLL_LCM_Recipe = function() cll.lootPost("recipe") end,
		CLL_LCM_Motifs = function() cll.lootPost("motif") end,
		CLL_LCM_Crafting = function() cll.lootPost("crafting") end,
		CLL_LCM_Style = function() cll.lootPost("style") end,
		CLL_LCM_WritsAll = function() cll.lootPost("writsall") end,
		CLL_LCM_Writs = function() cll.lootPost("writs") end,
		CLL_LCM_WritsAbove = function() cll.lootPost("writs", cll.sV.writLimit) end,
		CLL_LCM_HouseBanks = function() cll.allChars("true") end,
		CLL_LCM_AllChars = function() cll.allChars() end,
		CLL_LCM_TakeWritsAbove = function() cll.transferCustom({retr = true, writs = true, filterForCostHigherThan = true, cll = cll.sV.writLimit, known = true, unknown = true}) end,
		CLL_LCM_Bank = function() cll.depositItems(true, false) end,
		CLL_LCM_BankOther = function() cll.depositItems(false, true)  end,
		CLL_LCM_BankAll = function() cll.depositItems(true, true) end,
		CLL_LCM_Bank_Stackables = function() cll.depositStackables(false, true) end,
		CLL_LCM_Bank_RecipesMotifs = function() cll.transferCustom({retr = true, autoLearn = false, filterForPriceLowerThan = true, pul = cll.sV.recipePriceFilterChars[GetCurrentCharacterId()] or cll.sV.recipePriceFilter, filterForMain = true, oneCopyOnly = true, known = false, unknown = true, recipes = true, furniture = true, motifs = true}) end,
		CLL_LCM_Bank_RecipesMotifsAndLearn = function() cll.transferCustom({retr = true, autoLearn = true, filterForPriceLowerThan = true,  pul = cll.sV.recipePriceFilterChars[GetCurrentCharacterId()] or cll.sV.recipePriceFilter, filterForMain = true, oneCopyOnly = true, known = false, unknown = true, recipes = true, furniture = true, motifs = true}) end,
		CLL_LCM_Decon = function() cll.checkCraftRefinement(cll.deconstruct) end,
		CLL_LCM_Refine = function() cll.checkCraftRefinement(cll.refine, true) end,
		CLL_LCM_DeconAll = function() cll.checkCraftRefinement(function() cll.deconstruct("true") end) end,
		CLL_LCM_DeconIntriOnly = function() cll.checkCraftRefinement(function() cll.deconstruct("true", nil, true) end) end,
		CLL_LCM_DeconGlyphs = function(myQuality) cll.checkCraftRefinement(function() cll.deconstruct(nil, myQuality[1]) end) end,
		bankSplitArgsFunction = bankSplitArgsFunction,
		CLL_TakeMats = function() cll.retrieveFromVirtual() end,
		CLL_LearnAll = function() cll.learnAllInInv(false) end,
		CLL_LearnAllPrice = function()  cll.learnAllInInv(true) end,
		CLL_TakeGuildStoreAttachements = function() cll.retrieveShoppingMailsAndLearn(false, false, true, false) end,
		CLL_TakeGuildStoreAttachementsAndLearn = function() cll.retrieveShoppingMailsAndLearn(true, false, true, false) end,
		CLL_TakeGuildStoreAttachementsAndBind = function() cll.retrieveShoppingMailsAndLearn(false, true, true, false) end,
		CLL_TakeGuildStoreAttachementsAndBoth = function() cll.retrieveShoppingMailsAndLearn(true, true, true, false) end,
	
		CLL_TakeGuildStoreMoney = function() cll.retrieveShoppingMailsAndLearn(false, false, false, true) end,
		CLL_TakeGuildStoreMoneyAndAttachements = function() cll.retrieveShoppingMailsAndLearn(false, false, true, true) end,
		CLL_TakeGuildStoreMoneyAndAttachementsAnd = function() cll.retrieveShoppingMailsAndLearn(true, true, true, true) end,
	
	}
	
	local cllMyFunctionPretexts = {
		CLL_LCM_Post = CLL_LCM_Menu1,
		CLL_LCM_PostAll = CLL_LCM_Menu1,
		CLL_LCM_Current = CLL_LCM_Menu1,
		CLL_LCM_Mawa = CLL_LCM_Menu1,
		CLL_LCM_Batman = CLL_LCM_Menu1,
		CLL_LCM_NoArmor = CLL_LCM_Menu1,
		--CLL_LCM_BindAll
		CLL_LCM_BindPost = CLL_LCM_BindAll,
		CLL_LCM_BindPostCurr = CLL_LCM_BindAll,
		CLL_LCM_Furniture = CLL_LCM_Menu3,
		CLL_LCM_Recipe =  CLL_LCM_Menu3,
		CLL_LCM_Motifs = CLL_LCM_Menu3,
		CLL_LCM_Crafting = CLL_LCM_Menu3,
		CLL_LCM_Style = CLL_LCM_Menu3,
		CLL_LCM_WritsAll = CLL_LCM_Menu3,
		CLL_LCM_Writs = CLL_LCM_Menu3,
		CLL_LCM_WritsAbove = CLL_LCM_Menu3,
		CLL_LCM_HouseBanks = CLL_LCM_Menu4,
		CLL_LCM_AllChars = CLL_LCM_Menu4,
		CLL_LCM_TakeWritsAbove = CLL_LCM_Bank_Retrieve,
		CLL_LCM_Bank = CLL_LCM_Bank_Deposit,
		CLL_LCM_BankOther = CLL_LCM_Bank_Deposit,
		CLL_LCM_BankAll = CLL_LCM_Bank_Deposit,
		CLL_LCM_Bank_Stackables = CLL_LCM_Bank_Stackables,
		CLL_LCM_Bank_RecipesMotifsAndLearn = {CLL_LCM_Bank_Retrieve, CLL_LCM_Bank_RecipesMotifs},
		CLL_LCM_DeconAll = CLL_LCM_Decon,
		CLL_LCM_DeconIntriOnly = CLL_LCM_Decon,
		CLL_TakeGuildStoreAttachementsAndLearn = CLL_TakeGuildStoreAttachements,
		CLL_TakeGuildStoreAttachementsAndBind = CLL_TakeGuildStoreAttachements,
		CLL_TakeGuildStoreAttachementsAndBoth = CLL_TakeGuildStoreAttachements,
		CLL_TakeGuildStoreMoneyAndAttachementsAnd = CLL_TakeGuildStoreMoneyAndAttachements, 
		CLL_LearnAll = CLL_LearnAllPre,
		CLL_LearnAllPrice = CLL_LearnAllPre,
	}
	
	local function getPretext(theText, theId)
		local myPretext = cllMyFunctionPretexts[theId]
		if myPretext then
			if type(myPretext) == "table" then
				for i=#myPretext, 1, -1 do
					theText = string.format("%s: %s", GS(myPretext[i]), theText)
				end
			else
				theText = string.format("%s: %s", GS(myPretext), theText)
			end
		end
		return theText
	end
	
	
	local function runFunctionAndSaveAsLast(myId, myCategory, myArgs, forceShift, forceCtrl)
		local myArgs = myArgs or {}
		if GetInteractionType() == INTERACTION_TRADINGHOUSE then myCategory = "kiosk" end
		if myCategory == "bank" then
			local theBag = GetBankingBag()
			if theBag ~= BAG_BANK then
				myCategory = string.format("%s%s", myCategory, cll.sV.sameForAllHousingChests and "X" or theBag)
			end
		end
		local shiftMode, ctrMode = IsShiftKeyDown(), IsControlKeyDown()
		if forceShift ~= nil then
			shiftMode, ctrMode = forceShift, forceCtrl
		end
		if shiftMode and ctrMode  then 
			lastFunctions4[myCategory] = myId
		elseif ctrMode  then
			lastFunctions3[myCategory] = myId
		elseif shiftMode then
			lastFunctions2[myCategory] = myId
		else
			lastFunctions[myCategory] = myId
		end
		if myCategory == "deconGlyphs" or myCategory == "deconUni" and string.sub(myId, 1, 19) == "CLL_LCM_DeconGlyphs" then
			myArgs = {tonumber(string.sub(myId, -1))}
			myId = "CLL_LCM_DeconGlyphs"
		end
		if string.sub(myId, 5, 7) == "///" then
			myId = "bankSplitArgsFunction"
		end
		
		cllMyFunctions[myId](myArgs)
	end
	cll.runFunctionAndSaveAsLast = runFunctionAndSaveAsLast
	
	local function getLastUsedFunctionAndMode()
		local myPrimaryFunctionText = false
		local theFunction = false
		local theArgs = {}
		local interactType = GetInteractionType()
		
		local myLastFunctions = IsShiftKeyDown() and IsControlKeyDown() and lastFunctions4 or 
								IsControlKeyDown() and lastFunctions3 or
								IsShiftKeyDown() and lastFunctions2 or
								lastFunctions
								
		if  TRADE_WINDOW.state == TRADE_STATE_TRADING then 
			myPrimaryFunctionText = GS(CLL_Button_TT1a)
			theFunction = false
		elseif interactType == INTERACTION_BANK then
			local myCategory = "bank"
			local theBag = GetBankingBag()
			if theBag ~= BAG_BANK then
				myCategory = string.format("%s%s", myCategory, cll.sV.sameForAllHousingChests and "X" or theBag)
			end
			if myLastFunctions[myCategory] then 
				if string.sub(myLastFunctions[myCategory], 5, 7) == "///" then
					theArgs = {SplitString("///", myLastFunctions[myCategory])}
					myPrimaryFunctionText = bankSplitArgsText(theArgs)
					theFunction = bankSplitArgsFunction
				else
					local textId = _G[myLastFunctions[myCategory]]
					myPrimaryFunctionText = GS(textId)
					if textId == CLL_LCM_TakeWritsAbove then myPrimaryFunctionText = string.format(myPrimaryFunctionText, cll.sV.writLimit) end
					myPrimaryFunctionText = getPretext(myPrimaryFunctionText, myLastFunctions[myCategory])
					theFunction = cllMyFunctions[myLastFunctions[myCategory]]
				end
			end
		elseif interactType == INTERACTION_CRAFT then
			local stationCraftType = GetCraftingInteractionType()			
			
			local myId = stationCraftType == CRAFTING_TYPE_INVALID and myLastFunctions["deconUni"] or
				stationCraftType == CRAFTING_TYPE_ENCHANTING and myLastFunctions["deconGlyphs"] or
				craftsForDecon[stationCraftType] and stationCraftType ~= CRAFTING_TYPE_INVALID and myLastFunctions["decon"] or
				false
							
			if myId then
				if string.sub(myId, 1, 19) == "CLL_LCM_DeconGlyphs" then
					local myQuality = tonumber(string.sub(myId, -1))				
					myPrimaryFunctionText =  string.format(GS(CLL_LCM_DeconGlyphs), GS("SI_ITEMQUALITY", myQuality))
					theFunction = cllMyFunctions["CLL_LCM_DeconGlyphs"]
					theArgs = {myQuality}
				else
					local textId = _G[myId]
					myPrimaryFunctionText = GS(textId)
					myPrimaryFunctionText = getPretext(myPrimaryFunctionText, myId)
					theFunction = cllMyFunctions[myId]
				end
			end
		elseif SCENE_MANAGER.currentScene:GetName() == "mailInbox" then
			local myId = myLastFunctions["mail"]
			if myId then 
				local textId = _G[myId]
				myPrimaryFunctionText = GS(textId)
				myPrimaryFunctionText = getPretext(myPrimaryFunctionText, myId)
				theFunction = cllMyFunctions[myId]
			end
		else
			local myCategory = interactType == INTERACTION_TRADINGHOUSE and "kiosk" or "loot"
			if myLastFunctions[myCategory] then
				local textId = _G[myLastFunctions[myCategory]]
				myPrimaryFunctionText = GS(textId)
				if textId == CLL_LCM_WritsAbove then myPrimaryFunctionText = string.format(myPrimaryFunctionText, cll.sV.writLimit) end
				myPrimaryFunctionText = getPretext(myPrimaryFunctionText, myLastFunctions[myCategory])
				theFunction = cllMyFunctions[myLastFunctions[myCategory]]
			end
		end
		if not myPrimaryFunctionText then theFunction = false end
		return myPrimaryFunctionText, theFunction, theArgs
	end
	
	local optionButton = cll.optionButton
	optionButton:SetDimensions(33,33)
	optionButton:SetNormalTexture("esoui/art/inventory/inventory_tabicon_misc_up.dds")
	optionButton:SetPressedTexture("esoui/art/inventory/inventory_tabicon_misc_down.dds")
	optionButton:SetMouseOverTexture("esoui/art/inventory/inventory_tabicon_misc_over.dds")
	optionButton:SetDisabledTexture("esoui/art/inventory/inventory_tabicon_misc_disabled.dds")
	optionButton:SetAnchor(TOPRIGHT, ZO_ChatWindow, TOPRIGHT, -40 - cll.sV.buttonOffset, 6)
	optionButton.caro = WINDOW_MANAGER:CreateControl(nil, optionButton, CT_TEXTURE)
	
	optionButton.caro:SetTexture("esoui/art/crafting/crafting_alchemy_badslot.dds")
	optionButton.caro:SetAnchor(CENTER, cll.optionButton, CENTER, -1)
	optionButton.caro:SetDimensions(20,20)
	optionButton.caro:SetTextureRotation(math.pi/4, 0.5,0.5)
	local function updateCLLButtonTooltip(control)
		local myPrimaryFunctionText = getLastUsedFunctionAndMode()
		myPrimaryFunctionText = myPrimaryFunctionText or GS(CLL_Button_TT2a)
		local myText = zo_strformat(string.format(GS(CLL_Button_TT), myPrimaryFunctionText, GS(CLL_Button_TT2a)), myAccentColor, myTextColor)
		ZO_Tooltips_ShowTextTooltip(control, RIGHT, myText) 
	end
	local shiftStatus = IsShiftKeyDown()
	local ctrlStatus = IsControlKeyDown()
	optionButton:SetHandler("OnMouseEnter",  function(self) 
		updateCLLButtonTooltip(self)
		EVENT_MANAGER:RegisterForUpdate("CLLTooltipUpdater", 200, 
			function() 
				if shiftStatus ~= IsShiftKeyDown() or ctrlStatus ~= IsControlKeyDown() then 
					shiftStatus = IsShiftKeyDown() 
					ctrlStatus = IsControlKeyDown()
					updateCLLButtonTooltip(self) 
				end 
			end)
	end)
	optionButton:SetHandler("OnMouseExit", function() 
		ZO_Tooltips_HideTextTooltip() 
		EVENT_MANAGER:UnregisterForUpdate("CLLTooltipUpdater")
	end)
	optionButton:SetHandler("OnMouseUp", function(self, button, upInside, ctrl, alt, shift, command)
		if not upInside then return end
		if button == 1 and TRADE_WINDOW.state == TRADE_STATE_TRADING and cll.tradeOffer(ctrl) then return end
		local myPrimaryFunctionText, theFunction, theArgs = getLastUsedFunctionAndMode()
		if button == 1 and theFunction then
			cllPost(myPrimaryFunctionText)
			theFunction(theArgs)
			return
		end
		local function createMenuEntry(myId, myCategory, createTable, addDots)
			local myQuality = false
			local myText = ""
			local args = {}
			if string.sub(myId, 5, 7) == "///" then -- retr--- depo---
				args = {SplitString("///", myId)}
				myText = bankSplitArgsText(args, createTable)
				--myId = "bankSplitArgsFunction"
			else
				if myCategory == "deconGlyphs" or myCategory == "deconUni" and string.sub(myId, 1, 19) == "CLL_LCM_DeconGlyphs"  then
					myQuality = tonumber(string.sub(myId, -1))
					myText = string.format(GS(CLL_LCM_DeconGlyphs), GS("SI_ITEMQUALITY", myQuality))
				else
					myText = GS(_G[myId])
				end
				if myId == "CLL_LCM_WritsAbove" then myText = string.format(myText, cll.sV.writLimit) end
				if myId == "CLL_LCM_TakeWritsAbove" then myText = string.format(myText, cll.sV.writLimit) end
			end	
			if addDots then
				myText = zo_strformat("... <<1>>", myText)
			else
				myText = zo_strformat("<<C:1>>", myText)
			end
			if createTable then
				return {label = myText, callback = function() runFunctionAndSaveAsLast(myId, myCategory, args) end}
			else
				return myText, function() runFunctionAndSaveAsLast(myId, myCategory, args) end
			end
		end
		local subMenu1 = {
			createMenuEntry("CLL_LCM_Post", "loot", true),
			createMenuEntry("CLL_LCM_Current", "loot", true),
			createMenuEntry("CLL_LCM_PostAll", "loot", true),
			{label = "-",},
			createMenuEntry("CLL_LCM_Mawa", "loot", true),
			createMenuEntry("CLL_LCM_NoArmor", "loot", true),
			{label = "-",},
			createMenuEntry("CLL_LCM_Batman", "loot", true),
		}
		
		local subMenu2 = {
			createMenuEntry("CLL_LCM_BindAll", "loot", true),
			createMenuEntry("CLL_LCM_BindPost", "loot", true, true),
			createMenuEntry("CLL_LCM_BindPostCurr", "loot", true, true),
		}
		
		local subMenu3 = {
			createMenuEntry("CLL_LCM_Furniture", "loot", true),
			createMenuEntry("CLL_LCM_Recipe", "loot", true),
			createMenuEntry("CLL_LCM_Motifs", "loot", true),
			createMenuEntry("CLL_LCM_Crafting", "loot", true),
			{label = "-",},
			createMenuEntry("CLL_LCM_Style", "loot", true),
			{label = "-",},
			createMenuEntry("CLL_LCM_WritsAll", "loot", true),
		}
		
	
		
		if WritWorthy then
			table.insert(subMenu3, createMenuEntry("CLL_LCM_Writs", "loot", true))
			table.insert(subMenu3, createMenuEntry("CLL_LCM_WritsAbove", "loot", true))
		end
		
		local subMenu4 = {
			createMenuEntry("CLL_LCM_HouseBanks", "loot", true),
			createMenuEntry("CLL_LCM_AllChars", "loot", true),
		}
		
		local subMenu5 = {
			createMenuEntry("CLL_LearnAll", "loot", true),
			createMenuEntry("CLL_LearnAllPrice", "loot", true),
		}
		
		ClearMenu()
		
		AddCustomMenuItem(GS(CLL_Info), cll.info)
		AddCustomSubMenuItem(GS(CLL_LCM_Menu1), subMenu1)
		AddCustomSubMenuItem(GS(CLL_LCM_Menu2), subMenu2)
		AddCustomSubMenuItem(GS(CLL_LCM_Menu3), subMenu3)
		
		if IIfA and IIfA.database then
			AddCustomSubMenuItem(GS(CLL_LCM_Menu4), subMenu4)
		end
		
		AddCustomSubMenuItem(GS(CLL_LearnAllPre), subMenu5)
		
		if HasCraftBagAccess() then
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem(createMenuEntry("CLL_TakeMats", "loot"))
		end
		
		if SCENE_MANAGER.currentScene:GetName() == "mailInbox" then
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem(createMenuEntry("CLL_TakeGuildStoreAttachements", "mail"))
			AddCustomMenuItem(createMenuEntry("CLL_TakeGuildStoreAttachementsAndLearn", "mail", false, true))
			AddCustomMenuItem(createMenuEntry("CLL_TakeGuildStoreAttachementsAndBind", "mail", false, true))
			AddCustomMenuItem(createMenuEntry("CLL_TakeGuildStoreAttachementsAndBoth", "mail", false, true))
			AddCustomMenuItem(createMenuEntry("CLL_TakeGuildStoreMoney", "mail"))
			AddCustomMenuItem(createMenuEntry("CLL_TakeGuildStoreMoneyAndAttachements", "mail"))
			AddCustomMenuItem(createMenuEntry("CLL_TakeGuildStoreMoneyAndAttachementsAnd", "mail", false, true))	
		end
	
		if IsGuildBankOpen() and CS and cll.sV.showOptionOnGuildBank and cll.sV.recipePriceFilterGuildBank then
			local guildId = GetSelectedGuildBankId()
			if DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_BANK_DEPOSIT) and
				DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_BANK_DEPOSIT) and 
				DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_BANK_WITHDRAW) then 	
					AddCustomMenuItem(string.format(GS(CLL_LCM_GuildBank), cll.sV.recipePriceFilterGuildBank), function() cll.retrieveAndLearnFromGuildBank() end)
			end
		end
		
		if GetInteractionType() == INTERACTION_BANK then
			local retrieveMenu = {}
			local depositMenu = {}
			if CS then
				table.insert(retrieveMenu, createMenuEntry("CLL_LCM_Bank_RecipesMotifs", "bank", true))
				table.insert(retrieveMenu, createMenuEntry("CLL_LCM_Bank_RecipesMotifsAndLearn", "bank", true, true))
				table.insert(retrieveMenu, {label = "-", callback = function() end}) 
			end
			

			table.insert(depositMenu, createMenuEntry("CLL_LCM_Bank", "bank", true))
			table.insert(depositMenu, createMenuEntry("CLL_LCM_BankOther", "bank", true))
			table.insert(depositMenu, createMenuEntry("CLL_LCM_BankAll", "bank", true))
			table.insert(depositMenu, {label = "-", callback = function() end})
			
			table.insert(retrieveMenu, createMenuEntry("retr///writs///known///unknown", "bank", true))
			table.insert(depositMenu, createMenuEntry("depo///writs///known///unknown", "bank", true))
			if WritWorthy then
				--table.insert(retrieveMenu, createMenuEntry("CLL_LCM_TakeWritsAbove", "bank", true))
				table.insert(retrieveMenu, createMenuEntry(string.format("retr///writs///known///unknown///filterForCostHigherThan///cll:%s", cll.sV.writLimit), "bank", true))
				table.insert(depositMenu, createMenuEntry(string.format("depo///writs///known///unknown///filterForCostHigherThan///cll:%s", cll.sV.writLimit), "bank", true))
			end
			table.insert(depositMenu, createMenuEntry("CLL_LCM_Bank_Stackables", "bank", true))
			
			table.insert(retrieveMenu, {label = "-", callback = function() end}) 
			table.insert(depositMenu, {label = "-", callback = function() end})
			table.insert(retrieveMenu, {label = zo_strformat("<<C:1>>", GS(CLL_LCM_Bank_Sets)), callback = function() cll.showSetListDiag(GetBankingBag(), true) end})
			table.insert(depositMenu, {label = zo_strformat("<<C:1>>", GS(CLL_LCM_Bank_Sets)), callback = function() cll.showSetListDiag(BAG_BACKPACK, false) end})
			
			table.insert(retrieveMenu, {label = GS(SI_HOUSEPERMISSIONPRESETSETTING0), callback = function() cll.showCustomDiag(true, IsShiftKeyDown(), IsControlKeyDown()) end})
			table.insert(depositMenu, {label = GS(SI_HOUSEPERMISSIONPRESETSETTING0), callback = function() cll.showCustomDiag(false, IsShiftKeyDown(), IsControlKeyDown()) end})
			
			AddCustomMenuItem("-", function() end)
			AddCustomSubMenuItem(GS(CLL_LCM_Bank_Retrieve), retrieveMenu)
			AddCustomSubMenuItem(GS(CLL_LCM_Bank_Deposit), depositMenu)
		end
		
		if GetInteractionType() == INTERACTION_CRAFT then 
			local stationCraftType = GetCraftingInteractionType()
						
			if craftsForDecon[stationCraftType]	then
				AddCustomMenuItem("-", function() end)
				local craftingCategory = stationCraftType == CRAFTING_TYPE_INVALID and "deconUni" or "decon"
				AddCustomMenuItem(GS(CLL_LCM_Decon), function() runFunctionAndSaveAsLast("CLL_LCM_Decon", craftingCategory) end)
				AddCustomMenuItem(GS(CLL_LCM_DeconAll), function() runFunctionAndSaveAsLast("CLL_LCM_DeconAll", craftingCategory) end)
				AddCustomMenuItem(GS(CLL_LCM_DeconIntriOnly), function() runFunctionAndSaveAsLast("CLL_LCM_DeconIntriOnly", craftingCategory) end)
				if stationCraftType ~= CRAFTING_TYPE_INVALID then AddCustomMenuItem(GS(CLL_LCM_Refine), function() runFunctionAndSaveAsLast("CLL_LCM_Refine", "decon") end) end
			end
			if craftsForGlyphDecon[stationCraftType] then
				local craftingCategory = stationCraftType == CRAFTING_TYPE_INVALID and "deconUni" or "deconGlyphs"
				AddCustomMenuItem("-", function() end)
				AddCustomMenuItem(createMenuEntry("CLL_LCM_DeconGlyphs2", craftingCategory))
				AddCustomMenuItem(createMenuEntry("CLL_LCM_DeconGlyphs3", craftingCategory))
				AddCustomMenuItem(createMenuEntry("CLL_LCM_DeconGlyphs4", craftingCategory))
				AddCustomMenuItem(createMenuEntry("CLL_LCM_DeconGlyphs5", craftingCategory))
			end
		end
		if CarosLootListSE then
			CarosLootListSE.addMenuEntries()
		end
		ShowMenu()
	end)
end
		
	
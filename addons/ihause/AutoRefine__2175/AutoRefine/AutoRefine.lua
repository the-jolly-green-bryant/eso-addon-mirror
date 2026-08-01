local AR_COLOR_GREEN = "2DC50E"
local AR_COLOR_BLUE = "3A92FF"
local AR_COLOR_PURPLE = "A02EF7"
local AR_COLOR_GOLD = "E9C629"
local AR_COLOR_WHITE = "FFFFFF"

AutoRefine.isCraftStationOpened = false
AutoRefine.isRefiningStarted = false
AutoRefine.isRefiningLoopStarted = false
AutoRefine.refiningLoopLastAmount = 0
AutoRefine.isExtraRefiningLoopStarted = false
AutoRefine.currentSkill = {}
AutoRefine.currentSkillStatistics = {}
AutoRefine.currentSkillSettings = {}
AutoRefine.currentCraftingType = "undefined"
AutoRefine.statistics = {}
AutoRefine.settings = {}

ZO_CreateStringId("SI_BINDING_NAME_AR_CRAFT", "Auto Refine")



local function dd(str)
	d("|c6699CCAutoRefine: "..str.. "|r")
end

local function toColoredText(str, colorStr)
	return zo_strformat("|c<<1>><<2>>|r", colorStr, str)
end

local function statsToColoredText(sk, greenStr, blueStr, purpleStr, goldStr)
	return (    
		   toColoredText(zo_strformat("<<1>>x", greenStr), AR_COLOR_GREEN)	.. " " 
		.. toColoredText(zo_strformat("<<1>>x", blueStr), AR_COLOR_BLUE) .. " " 
		.. toColoredText(zo_strformat("<<1>>x", purpleStr), AR_COLOR_PURPLE) .. " " 
		.. toColoredText(zo_strformat("<<1>>x", goldStr), AR_COLOR_GOLD)
	)
end

function AutoRefine:GetEmptyUpgradeMatStatistics()
	return 	{}
end

function AutoRefine:GetEmptySkillStatistics()
	return  
	{
		mat = 0,
		upgradeMat = self:GetEmptyUpgradeMatStatistics(),
		upgradeMatBefore = self:GetEmptyUpgradeMatStatistics()
	}
end

function AutoRefine:ClearStatistics()
	self.statistics = 
	{
		woodworking = self:GetEmptySkillStatistics(),
		clothier = self:GetEmptySkillStatistics(),
		blacksmithing = self:GetEmptySkillStatistics(),
		jewelrycrafting = self:GetEmptySkillStatistics(),
	}
end

function AutoRefine:Clear()
	self.currentSkill = {}
	self.currentCraftingType = "undefined"
	self.isCraftStationOpened = false
	self.isRefiningStarted = false
	self.isRefiningLoopStarted = false
	self.isExtraRefiningLoopStarted = false
	self:ClearStatistics()
	self.refiningLoopLastAmount = 0
end


function AutoRefine:InitCurrentSkill(craftingType)
    self.currentCraftingType = craftingType
	
	if craftingType == CRAFTING_TYPE_BLACKSMITHING then 
		self.currentSkill = self.blacksmithing 
		self.currentSkillStatistics = self.statistics.blacksmithing
		self.currentSkillSettings = self.settings.blacksmithing
		self.currentCoeff = self.settings.blacksmithingCoeff
		self.currentTraitCoeff = self.settings.blacksmithingTraitCoeff
	end
	if craftingType == CRAFTING_TYPE_CLOTHIER then 
		self.currentSkill = self.clothier
		self.currentSkillStatistics = self.statistics.clothier
		self.currentSkillSettings = self.settings.clothier		
		self.currentCoeff = self.settings.clothierCoeff
		self.currentTraitCoeff = self.settings.clothierTraitCoeff
	end
	if craftingType == CRAFTING_TYPE_WOODWORKING then 
		self.currentSkill = self.woodworking 
		self.currentSkillStatistics = self.statistics.woodworking
		self.currentSkillSettings = self.settings.woodworking
		self.currentCoeff = self.settings.woodworkingCoeff
		self.currentTraitCoeff = self.settings.woodworkingTraitCoeff
	end
	if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then 
		self.currentSkill = self.jewelrycrafting 
		self.currentSkillStatistics = self.statistics.jewelrycrafting
		self.currentSkillSettings = self.settings.jewelrycrafting
		self.currentCoeff = self.settings.jewelrycraftingCoeff
		self.currentTraitCoeff = self.settings.jewelrycraftingTraitCoeff
	end
end


function AutoRefine:FindNextTask()

	local slotIndex, bagId, amount = self:FindNextTaskByType(self.currentSkill.itemType)
	if (slotIndex ~= -1) then return slotIndex, bagId, amount end
	 
	return -1, BAG_BACKPACK, 0
end

function AutoRefine:FindNextExtraTask()

	if self.settings.refineStyleMats and self.currentSkill ~= self.jewelrycrafting then 
		local slotIndex, bagId, amount = self:FindNextTaskByType(ITEMTYPE_RAW_MATERIAL)
		if (slotIndex ~= -1) then return slotIndex, bagId, amount end
	end
	
	if self.settings.refineJewelryTraits and self.currentSkill == self.jewelrycrafting then 
		local slotIndex, bagId, amount = self:FindNextTaskByType(ITEMTYPE_JEWELRY_RAW_TRAIT)
		if (slotIndex ~= -1) then return slotIndex, bagId, amount end
	end
	
	if self.settings.refineJewelryBoosters and self.currentSkill == self.jewelrycrafting then 
		local slotIndex, bagId, amount = self:FindNextTaskByType(ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER)
		if (slotIndex ~= -1) then return slotIndex, bagId, amount end
	end	
	 
	return -1, BAG_BACKPACK, 0
end

local function fillUpgradeMatStatistics(upgradeMat, mats, str)
	for i = 1,#mats do
		local mat = mats[i]
		local id = AutoRefine:GetItemId(mat.link)
		upgradeMat[id] = AutoRefine:GetItemTotalCountById(id)
		
		if mat.color ~= nil then
			str[mat.color] = upgradeMat[id]
		end
	end
end

function AutoRefine:FillUpgradeMatStatistics(upgradeMat)

	local str = {}
	fillUpgradeMatStatistics(upgradeMat, self.currentSkill.mats, str)
	fillUpgradeMatStatistics(upgradeMat, self.currentSkill.traits, str)
	
	--dd( "You have: " .. statsToColoredText(self.currentSkill, str[AR_COLOR_GREEN], str[AR_COLOR_BLUE], str[AR_COLOR_PURPLE], str[AR_COLOR_GOLD]))
end

function AutoRefine:InitSkillStatistics()
	self.currentSkillStatistics.mat = 0
	self:FillUpgradeMatStatistics(self.currentSkillStatistics.upgradeMatBefore)	
end

function AutoRefine:IsMasterMerchant()
	return MasterMerchant ~= nil
end

function AutoRefine:IsTamrielTradeCenter()
	return TamrielTradeCentrePrice ~= nil
end

function AutoRefine:GetMMAvgPrice(itemLink)
	if self:IsMasterMerchant() then
		local stats = MasterMerchant:itemStats(itemLink, false)
		if stats ~= nil and stats.avgPrice ~= nil then return stats.avgPrice end
	end
	return 0
end

function AutoRefine:GetTTCAvgPrice(itemLink)
	if self:IsTamrielTradeCenter() then
		local info = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
		if info ~= nil and info.SuggestedPrice ~= nil then return info.SuggestedPrice * 1.125 end
	end
	return 0
end

function AutoRefine:GetATTAvgPrice(itemLink)
	if LibPrice.CanATTPrice() then
		local info =  LibPrice.ATTPrice(itemLink)
		if info ~= nil then return LibPrice.ATTPrice(itemLink).avgPrice end
	end
	return 0
end

local function getUpgradeMatsPrice(mats, st, avgPriceGetter)
	local result = 0
	for i = 1,#mats do
		local mat = mats[i]
		local price = avgPriceGetter(mat.link)	
		local id = AutoRefine:GetItemId(mat.link)
		if st[id] ~=nil then 
			result = result + avgPriceGetter(mat.link) * (st[id]/st.mat)
		end	
	end
	return result
end

function AutoRefine:GetUpgradeMatsPrice(sk, st, coefForUpgradeMats, coefForTraitsMats, avgPriceGetter)

	local result = 0
	result = getUpgradeMatsPrice(sk.mats, st, avgPriceGetter) * coefForUpgradeMats
	result = result + getUpgradeMatsPrice(sk.traits, st, avgPriceGetter) * coefForTraitsMats
	return result
end

function AutoRefine:GetRawMatsPrice(matCost, upgradeMats, coefForMats)
	return upgradeMats + 0.85 * matCost * coefForMats
end

function AutoRefine:PrintPricesForMat(matName, matCost, upgradeMats, coefForMats, withIcon)
	local rawMatPrice = self:GetRawMatsPrice(matCost, upgradeMats, coefForMats)
	local icon = " "
	if withIcon then icon = zo_iconFormat(GetItemLinkIcon(matName), "100%", "100%") end
	dd(zo_strformat("<<3>><<1>> price : <<2>>", matName, rawMatPrice, icon))
end


function AutoRefine:PrintPrices(skill, skillSettings, coeff, traitCoeff, avgPriceGetter)
	local sk = skill
	local st = skillSettings
	
	if st.mat == 0 then return end
	
	local upgradeMats = self:GetUpgradeMatsPrice(sk, st, coeff, traitCoeff, avgPriceGetter)
	
	self:PrintPricesForMat("Raw trash mat", 4, upgradeMats, 1, false)
	
	if sk == self.clothier then
		self:PrintPricesForMat(sk.matCp160RawLight, avgPriceGetter(sk.matCp160Light), upgradeMats, coeff, true)
		self:PrintPricesForMat(sk.matCp160RawMedium, avgPriceGetter(sk.matCp160Medium), upgradeMats, coeff, true)
	elseif sk == self.jewelrycrafting then
		self:PrintPricesForMat(sk.levelMats[1].raw, avgPriceGetter(sk.levelMats[1].refined), upgradeMats, coeff, true)
		self:PrintPricesForMat(sk.levelMats[2].raw, avgPriceGetter(sk.levelMats[2].refined), upgradeMats, coeff, true)
		self:PrintPricesForMat(sk.levelMats[3].raw, avgPriceGetter(sk.levelMats[3].refined), upgradeMats, coeff, true)
		self:PrintPricesForMat(sk.levelMats[4].raw, avgPriceGetter(sk.levelMats[4].refined), upgradeMats, coeff, true)
		self:PrintPricesForMat(sk.levelMats[5].raw, avgPriceGetter(sk.levelMats[5].refined), upgradeMats, coeff, true)	
	else	
		self:PrintPricesForMat(sk.matCp160Raw, avgPriceGetter(sk.matCp160), upgradeMats, coeff, true)
	end
end

function AutoRefine:PrintResult(link, amount, result, color)
	if amount > 0 then
		dd(toColoredText(zo_strformat("<<2>>x <<4>><<1>> (<<3>>%)", link, amount, result, zo_iconFormat(GetItemLinkIcon(link), "100%", "100%")), color))
	end
end

function AutoRefine:PrintMatResult(link, amount, color)
	if amount > 0 then
		dd(toColoredText(zo_strformat("<<2>>x <<3>><<1>>", link, amount, zo_iconFormat(GetItemLinkIcon(link), "100%", "100%")), color))
	end
end

local function saveSkillStatisticsReceived(mats, st, settings, printOutput)
	for i = 1,#mats do
		local mat = mats[i]
		local id = AutoRefine:GetItemId(mat.link)
		
		local count = st.upgradeMat[id] - st.upgradeMatBefore[id]
		
		if printOutput then		
			if mat.color ~= nil then
				AutoRefine:PrintMatResult(mat.link, count, mat.color)
			else
				AutoRefine:PrintMatResult(mat.link, count, AR_COLOR_WHITE)
			end
		end
		
		if settings[id] ~= nil then
			settings[id] = settings[id] + count
		else
			settings[id] = count
		end		
	end
end

local function printSkillStatisticsSaved(mats, settings)
	for i = 1,#mats do
		local mat = mats[i]
		local id = AutoRefine:GetItemId(mat.link)
		local amount = settings[id]
		local result = 0
		if settings.mat > 0 then
			result = math.floor(100000 * amount / settings.mat) / 1000
		end
		
		if mat.color ~= nil then
			AutoRefine:PrintResult(mat.link, amount, result, mat.color)
		else
			AutoRefine:PrintResult(mat.link, amount, result, AR_COLOR_WHITE)
		end		
	end
end

function AutoRefine:PrintSkillStatistics(printStatistics)

	local settings = self.currentSkillSettings
	
	if printStatistics then
		dd("saved for ".. settings.mat .." mats: ")
	
		printSkillStatisticsSaved(self.currentSkill.mats, settings)
		printSkillStatisticsSaved(self.currentSkill.traits, settings)
	end
	
	local pricePrinted = false
	if self:IsMasterMerchant() and self.settings.printMMPrice then
		dd("Master Merchant Prices ====")
		self:PrintPrices(self.currentSkill, self.currentSkillSettings, self.currentCoeff, self.currentTraitCoeff, function(itemLink) return AutoRefine:GetMMAvgPrice(itemLink) end)
		pricePrinted = true
	end	
	
	if self:IsTamrielTradeCenter() and self.settings.printTTCPrice then		
		dd("Tamriel Trade Center Prices ====")
		self:PrintPrices(self.currentSkill, self.currentSkillSettings, self.currentCoeff, self.currentTraitCoeff, function(itemLink) return AutoRefine:GetTTCAvgPrice(itemLink) end)
		pricePrinted = true
	end
	
	if LibPrice.CanATTPrice() and self.settings.printATTPrice then		
		dd("Arkadius Trade Tools Prices ====")
		self:PrintPrices(self.currentSkill, self.currentSkillSettings, self.currentCoeff, self.currentTraitCoeff, function(itemLink) return AutoRefine:GetATTAvgPrice(itemLink) end)
		pricePrinted = true
	end
	
	if pricePrinted then
		if self.currentSkillSettings.mat == 0 then
			dd("|cCC0000Can't calculate price for materials amount equals 0|r")
		elseif self.currentSkillSettings.mat < 10000 then
			dd("|cCC0000Please refine more mats for appropriate result.|r")
		end
	end
end

function AutoRefine:SaveSkillStatistics()
    if not self.isRefiningLoopStarted then return end
	
	dd("Refine ended ==<=")
	
	self:FillUpgradeMatStatistics(self.currentSkillStatistics.upgradeMat)
	local st = self.currentSkillStatistics
	
	local settings = self.currentSkillSettings
	settings.mat = settings.mat + st.mat
	
	if self.settings.printCurrentResult then dd("received: ") end
	
	saveSkillStatisticsReceived(self.currentSkill.mats, st, settings, self.settings.printCurrentResult)
	saveSkillStatisticsReceived(self.currentSkill.traits, st, settings, self.settings.printCurrentResult)
	
	self:PrintSkillStatistics(self.settings.printStatistics)
end

function AutoRefine:FinishExtraRefining()
	if not self.isExtraRefiningLoopStarted then return end
	
	-- todo: print received mats 
	
	dd("Extra Refine ended ==<=")
end

function AutoRefine:OnRefineButtonClicked(control)
	dd("Refine started ==>=")
	
	if (not self.isRefiningLoopStarted) then
		self.isRefiningLoopStarted = true
		self:InitSkillStatistics()
		self:Craft()
	end
end

local function doCraft()
	AutoRefine:Craft()
end

function AutoRefine:Craft()

	if self.isRefiningLoopStarted then
		local slotIndex, bagId, amount = self:FindNextTask()	
		if ( slotIndex ~= -1 and (not self.isRefiningStarted) and self.isCraftStationOpened ) then
			self.isRefiningStarted = true	
			
			self.refiningLoopLastAmount = math.min(MAX_ITERATIONS_PER_DECONSTRUCTION, amount) * 10
			PrepareDeconstructMessage()
			if AddItemToDeconstructMessage(bagId, slotIndex, self.refiningLoopLastAmount) then
				SendDeconstructMessage() 
			end
		elseif self.isCraftStationOpened then   
			self:SaveSkillStatistics()
			self.isRefiningLoopStarted = false

			self.isExtraRefiningLoopStarted = true
			dd("Extra Refine started ==>=")
		end 
		
	end
	
	if not self.isRefiningLoopStarted and self.isExtraRefiningLoopStarted then
		local slotIndex, bagId, amount = self:FindNextExtraTask()	
		if ( slotIndex ~= -1 and (not self.isRefiningStarted) and self.isCraftStationOpened ) then
			self.isRefiningStarted = true
			
			PrepareDeconstructMessage()
			if AddItemToDeconstructMessage(bagId, slotIndex, math.min(MAX_ITERATIONS_PER_DECONSTRUCTION, amount) * 10) then
				SendDeconstructMessage() 
			end	
		elseif self.isCraftStationOpened then 
			self:FinishExtraRefining()
			self.isExtraRefiningLoopStarted = false
			
		end 
	end
end

function AutoRefine.OnCraftCompleted(eventCode, craftSkill)
	 if AutoRefine.isRefiningStarted and AutoRefine.isCraftStationOpened then
		if AutoRefine.isRefiningLoopStarted then
		    --dd ("OnCraftCompleted " .. AutoRefine.refiningLoopLastAmount)
			AutoRefine.currentSkillStatistics.mat = AutoRefine.currentSkillStatistics.mat + AutoRefine.refiningLoopLastAmount
		end
		
	     AutoRefine.isRefiningStarted = false
	     zo_callLater(doCraft, math.random(450, 750))     
	 end
end

function AutoRefine.OnCraftingStationInteract(eventCode, craftingType)
	if	craftingType == CRAFTING_TYPE_BLACKSMITHING 
		or craftingType == CRAFTING_TYPE_CLOTHIER
		or craftingType == CRAFTING_TYPE_WOODWORKING 
		or craftingType == CRAFTING_TYPE_JEWELRYCRAFTING 
	then
		
		AutoRefine:Clear()
		AutoRefine.isCraftStationOpened = true
		AutoRefine:InitCurrentSkill(craftingType)
		
		EVENT_MANAGER:RegisterForEvent(AutoRefine.name, EVENT_CRAFT_COMPLETED, AutoRefine.OnCraftCompleted)
		
		if AutoRefine.settings.autoRefine then
			AutoRefine:OnRefineButtonClicked(nil)
		end

	end
end



function AutoRefine.OnEndCraftingStationInteract()
	if AutoRefine.isCraftStationOpened then
		AutoRefine.isCraftStationOpened = false
		EVENT_MANAGER:UnregisterForEvent(AutoRefine.name, EVENT_CRAFT_COMPLETED)		
		if AutoRefine.isRefiningLoopStarted then
			AutoRefine:SaveSkillStatistics()
		end
		if AutoRefine.isExtraRefiningLoopStarted then
			AutoRefine:FinishExtraRefining()
		end
		
		AutoRefine:Clear()
	end
end



function AutoRefine:GetPriceBySettings(sk, st, itemLink, coeff, traitCoeff, avgPriceGetter)
	local upgradeMats = self:GetUpgradeMatsPrice(sk, st, coeff, traitCoeff, avgPriceGetter)
	
	for i = 1,#sk.levelMats do
		local levelMat = sk.levelMats[i]
		
		if levelMat.raw == itemLink then
			return self:GetRawMatsPrice(avgPriceGetter(levelMat.refined), upgradeMats, coeff)
		end
	end
	
	return self:GetRawMatsPrice(sk.defaultMatCost, upgradeMats, 1)
end

function AutoRefine:GetPrice(itemLink, itemType, avgPriceGetter)
	if itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL then
		return self:GetPriceBySettings(self.woodworking, self.settings.woodworking, itemLink, self.settings.woodworkingCoeff, self.settings.woodworkingTraitCoeff, avgPriceGetter)
	end
	
	if itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL then
		return self:GetPriceBySettings(self.blacksmithing, self.settings.blacksmithing, itemLink, self.settings.blacksmithingCoeff, self.settings.blacksmithingTraitCoeff, avgPriceGetter)
	end
	
	if itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL then
		return self:GetPriceBySettings(self.clothier, self.settings.clothier, itemLink, self.settings.clothierCoeff, self.settings.clothierTraitCoeff, avgPriceGetter)
	end
	
	if itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL then
		return self:GetPriceBySettings(self.jewelrycrafting, self.settings.jewelrycrafting, itemLink, self.settings.jewelrycraftingCoeff, self.settings.jewelrycraftingTraitCoeff, avgPriceGetter)
	end
	
	return -1
end

function AutoRefine:GetMMPrice(itemLink, itemType)
	return self:GetPrice(itemLink, itemType, function(itemLink) return AutoRefine:GetMMAvgPrice(itemLink) end)
end

function AutoRefine:GetTTCPrice(itemLink, itemType)
	return self:GetPrice(itemLink, itemType, function(itemLink) return AutoRefine:GetTTCAvgPrice(itemLink) end)
end

function AutoRefine:GetATTPrice(itemLink, itemType)
	return self:GetPrice(itemLink, itemType, function(itemLink) return AutoRefine:GetATTAvgPrice(itemLink) end)
end

function AutoRefine:GetPriceForFilter(itemLink, itemType)

    local price = self:GetMMPrice(itemLink, itemType)
	if price > 0 then return price end
	
	return self:GetATTPrice(itemLink, itemType)
end

-- Slash command (/arstats)
local function AR_SC_DisplaySavedSkillStatistics(text)
	-- Cannot print statistics while crafting.
	if AutoRefine.isRefiningLoopStarted then return end

	local arg = string.lower(text)
	
	local oldCraftingType = AutoRefine.currentCraftingType

	if arg == "blacksmithing" then
	    AutoRefine:InitCurrentSkill(CRAFTING_TYPE_BLACKSMITHING)
	elseif arg == "clothing" or arg == "clothier" then
		AutoRefine:InitCurrentSkill(CRAFTING_TYPE_CLOTHIER)
	elseif arg == "woodworking" then
		AutoRefine:InitCurrentSkill(CRAFTING_TYPE_WOODWORKING)
	elseif arg == "jewelry" or arg == "jewelrycrafting" then
		AutoRefine:InitCurrentSkill(CRAFTING_TYPE_JEWELRYCRAFTING)
	else
		dd("the specified crafting skill is not supported.")
		dd("use any of the following: blacksmiting, clothing, woodworking, jewelry.")
		return
	end
	
	AutoRefine:PrintSkillStatistics(true)
    AutoRefine:Clear()
	AutoRefine:InitCurrentSkill(oldCraftingType)
end

local function printPrices(craftingType)
	local oldCraftingType = AutoRefine.currentCraftingType
	AutoRefine:InitCurrentSkill(craftingType)
	AutoRefine:PrintSkillStatistics(false)
	AutoRefine:Clear()
	AutoRefine:InitCurrentSkill(oldCraftingType)	
end

function AutoRefine.PrintAllPrices()
	if AutoRefine.isRefiningLoopStarted then return end
	
	printPrices(CRAFTING_TYPE_BLACKSMITHING)
	printPrices(CRAFTING_TYPE_CLOTHIER)
	printPrices(CRAFTING_TYPE_WOODWORKING)
	printPrices(CRAFTING_TYPE_JEWELRYCRAFTING)
end


function AutoRefine:InitSlashCommands()
	local LSC = LibSlashCommander
	if LSC == nil then
		SLASH_COMMANDS["/arstats"] = AR_SC_DisplaySavedSkillStatistics
	else
		local mainCommand = LSC:Register("/arstats", function()
			AR_SC_DisplaySavedSkillStatistics("")
		end, "AutoRefine statistics")

		local blacksmithStats = mainCommand:RegisterSubCommand()
		blacksmithStats:AddAlias("blacksmithing")
		blacksmithStats:SetDescription("Display blacksmithing refine statistics")
		blacksmithStats:SetCallback(function()
			AR_SC_DisplaySavedSkillStatistics("blacksmithing")
		end)

		local clothierStats = mainCommand:RegisterSubCommand()
		clothierStats:AddAlias("clothing")
		clothierStats:AddAlias("clothier")
		clothierStats:SetDescription("Display clothing refine statistics")
		clothierStats:SetCallback(function()
			AR_SC_DisplaySavedSkillStatistics("clothing")
		end)

		local woodworkingStats = mainCommand:RegisterSubCommand()
		woodworkingStats:AddAlias("woodworking")
		woodworkingStats:SetDescription("Display woodworking refine statistics")
		woodworkingStats:SetCallback(function()
			AR_SC_DisplaySavedSkillStatistics("woodworking")
		end)

		local jewelryStats = mainCommand:RegisterSubCommand()
		jewelryStats:AddAlias("jewelry")
		jewelryStats:AddAlias("jewelrycrafting")
		jewelryStats:SetDescription("Display jewelrycrafting refine statistics")
		jewelryStats:SetCallback(function()
			AR_SC_DisplaySavedSkillStatistics("jewelry")
		end)
	end
end


local function doInit()
	AutoRefine.settings = AutoRefine:GetSettings()	
	AutoRefine:InitializeOptions()
	AutoRefine:InitSlashCommands()
end

function AutoRefine:Init()
	zo_callLater(doInit, math.random(1500, 2500))
end

function AutoRefine.OnAddOnLoaded(event, addonName)
  if addonName == AutoRefine.name then
    AutoRefine:Init()
  end
end

local function IsShowingRefinement()
	return not ZO_SmithingTopLevelRefinementPanelSlotContainer:IsHidden()
end

local function PressCraft()
	dd("Refine started ==>=")
	
	if (not AutoRefine.isRefiningLoopStarted) then
		AutoRefine.isRefiningLoopStarted = true
		AutoRefine:InitSkillStatistics()
		AutoRefine:Craft()
	end
end

local keystripDef = {
    name = function() return "Auto Refine" end,
    keybind = "AR_CRAFT",
    callback = function() PressCraft() end,
    alignment = KEYBIND_STRIP_ALIGN_LEFT,
    visible = function() return IsShowingRefinement() end,
}
ZO_CreateStringId("SI_BINDING_NAME_AR_PRINT", "Print All Prices To Chat")

table.insert(SMITHING.keybindStripDescriptor, keystripDef)

EVENT_MANAGER:RegisterForEvent(AutoRefine.name, EVENT_END_CRAFTING_STATION_INTERACT, AutoRefine.OnEndCraftingStationInteract)
EVENT_MANAGER:RegisterForEvent(AutoRefine.name, EVENT_CRAFTING_STATION_INTERACT, AutoRefine.OnCraftingStationInteract)
EVENT_MANAGER:RegisterForEvent(AutoRefine.name, EVENT_ADD_ON_LOADED, AutoRefine.OnAddOnLoaded)



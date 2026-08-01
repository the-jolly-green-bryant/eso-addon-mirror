DoItAll = DoItAll or {}
local FCOISisLoaded = (FCOIS ~= nil and FCOIS.IsMarked ~= nil) or false

local function IsItemSavedByItemSaver(slot)
--d("[DoItAll]ItemSaver - bag: " .. tostring(slot.data.bagId) .. ", slot: " .. tostring(slot.data.slotIndex))
	if not DoItAll.Settings.GetRespectItemSaver() then return false end
	--local useISFilterSetSettings = DoItAll.Settings.GetUseISFilterSetChecks()
    if not ItemSaver_IsItemSaved then return false end
    --For backwards compatibility of older ItemSaver versions without item sets!
    local retVar = false
    --local setName
    --retVar, setName = ItemSaver_IsItemSaved(slot.data.bagId, slot.data.slotIndex)
    local data = slot.data
    retVar = ItemSaver_IsItemSaved(data.bagId, data.slotIndex)
    --if useISFilterSetSettings and retVar and setName ~= nil then
        --if ItemSaver_GetFilters then
            --[[
                    return {
                        store = setData.filterStore,
                        deconstruction = setData.filterDeconstruction,
                        research = setData.filterResearch,
                        guildStore = setData.filterGuildStore,
                        mail = setData.filterMail,
                        trade = setData.filterTrade,
                    }
             ]]
            --local savedInfoArray = ItemSaver_GetFilters(setName)
            --if savedInfoArray ~= nil and savedInfoArray["deconstruction"] ~= nil then
                --Item is saved with set for deconstruction
                --retVar = savedInfoArray["deconstruction"]
            --end
        --end
    --end
    return retVar
end

--Is item saved by FCOItemSaver?
local function IsItemSavedByFCOItemSaver(slot)
    --FCOItemSaver addon is not loaded?
    if not FCOISisLoaded then return false end
	local settings = DoItAll.Settings
    --ItemSaver and/or FCOItemSaver should be used?
	local respectItemSavers = settings.GetRespectItemSaver()
    if not respectItemSavers then return false end
    --if not useFCOISPanelAntiSettings then return false end
	local retVar = false
	local data = slot.data
	--Is the new FCOIS DeconstructionSelectionHandler supported?
    --FCOItemSaver "current panel" (Deconstruction, Refinement) checks should be used to allow some marker icons to be deconstructed/extracted, depending on the current settings within FCOIS?
    local useFCOISPanelAntiSettings = settings.GetUseFCOISFilterPanelChecks()

	local itemLink = GetItemLink(data.bagId, data.slotIndex)
--d("[DoItAll]bag: " .. tostring(data.bagId) .. ", slot: " .. tostring(data.slotIndex) .. ", " .. itemLink .. ", FCOIS loaded: " .. tostring(FCOISisLoaded) .. ", respectItemSavers: " .. tostring(respectItemSavers) .. ", useFCOISPanelAntiSettings: " ..tostring(useFCOISPanelAntiSettings))

	if useFCOISPanelAntiSettings then
		--Are we inside the refinement panel? Then abort here directly
		if DoItAll.IsShowingRefinement() then
--d(">refinement")
		--	Get the marked icons on the item that will be deconstructed
			local isAnyIconMarked, markedArray
			--FCOItemSaver version >= 1.0
			isAnyIconMarked, markedArray = FCOIS.IsMarked(data.bagId, data.slotIndex, -1)
--d(">> Refinement, marked: " .. tostring(isAnyIconMarked))
			return isAnyIconMarked
		else
--d(">deconstruction/enchanting extract")
			--Call the FCOItemSaver DeconstructionSelectionHandler
			--FCOIS.callDeconstructionSelectionHandler(bag, slot, echo, overrideChatOutput, suppressChatOutput, overrideAlert, suppressAlert, calledFromExternalAddon, panelId)
			--IMPORTANT: parameter "calledFromExternalAddon" MUST be set to true in order to let this function call work here !!!
			retVar = FCOIS.callDeconstructionSelectionHandler(data.bagId, data.slotIndex, false, false, true, false, true, true, nil) -- Do not send actual panel ID of FCOIS so Enchanting Extract, Decon and Decon Jewelry can be distinguished automatically!
		end
    else
		--Use old checks
   		--	Check if any icon is marked on the item for deconstruction
		local isAnyIconMarked, markedTable
		--FCOItemSaver version >= 1.0
		isAnyIconMarked, markedTable = FCOIS.IsMarked(data.bagId, data.slotIndex, -1)
		retVar = isAnyIconMarked
    end
--d("<< [DoItAll-IsItemSavedByFCOIS] blocked: " .. tostring(retVar))
    return retVar
end

local function IsItemResearchable(slot)
	if not DoItAll.Settings.GetKeepResearchableItems() then return false end
	local raState = slot.data.researchAssistant or ""
	return raState == "researchable"
end

local function canBeMovedToBank(slot)
	-- Cannot be moved to bank
	local bagId = slot.data.bagId
	local slotIndex = slot.data.slotIndex
	if bagId == nil or slotIndex == nil then return true end
	if IsItemStolen(bagId, slotId) then return false end
	local itemLink = GetItemLink(bagId, slotId)
	if itemLink == nil or itemLink == "" then return true end
	if bagId == BAG_BACKPACK and GetItemLinkBindType(itemLink) == BIND_TYPE_ON_PICKUP_BACKPACK then return false end
end

DoItAll.ItemFilter = ZO_Object:Subclass()

function DoItAll.ItemFilter:New(ignoreResearchable)
--d("[DoItAll] Itemfilter - new")
	local obj = ZO_Object.New(self)
	obj.ignoreResearchable = ignoreResearchable
	return obj
end

function DoItAll.ItemFilter:Filter(slot, filterWhere)
	filterWhere = filterWhere or ""
	local isFilteredFCOIS, isFilteredIS, isFilteredBank = false, false, false
	isFilteredFCOIS = FCOIS ~= nil and IsItemSavedByFCOItemSaver(slot)
	if not isFilteredFCOIS then
		isFilteredIS = ItemSaver_IsItemSaved ~= nil and IsItemSavedByItemSaver(slot)
	end
--d(">isFilteredFCOIS: " ..tostring(isFilteredFCOIS))
	if filterWhere ~= nil and filterWhere ~= "" then
		if filterWhere == "BANK_DEPOSIT" then
			isFilteredBank = canBeMovedToBank(slot)
		end
	end
	local isFilteredReturn = isFilteredBank or isFilteredFCOIS or isFilteredIS
	if self.ignoreResearchable then
		isFilteredReturn = isFilteredReturn or IsItemResearchable(slot)
	end
--d("[DoItAll] Itemfilter - Filtered: " .. tostring(isFilteredIS) .. "/" .. tostring(isFilteredFCOIS) .. " , return: " .. tostring(isFilteredReturn))
	return isFilteredReturn
end

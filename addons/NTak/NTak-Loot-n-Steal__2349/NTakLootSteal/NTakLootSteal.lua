NTLnS = {}
local NTakLootSteal = NTLnS
local ADDON_NAME = "NTakLootSteal"
local texts	= NTLnS_Texts

local slash = " / "
local currLanguage = GetCVar("language.2") or "en"
if currLanguage ~= "en" then slash = "/" end


------------------------------------------
--		GENERAL FUNCTIONS

--	Some useful functions
local function debug(str, force)
	if not(NTakLootSteal.settings.debug) and not(force) then return end
	if str == nil then str = "nil" end
	d("NTak Loot'n'Steal: " .. str)
end
local function BoolToNum(bool)
	return bool and 1 or 0
end
local function CopyTree(elm)
    local copy
    if type(elm) == 'table' then
		-- Copy object by iterating into it
        copy = {}
        for key, val in next, elm, nil do
            copy[CopyTree(key)] = CopyTree(val)
        end
        setmetatable(copy, CopyTree(getmetatable(elm)))
    else
		-- Not a table, simple copy
        copy = elm
    end
    return copy
end
local function TextPad(pad)
	return "|u" .. pad .. ":::|u"
end
local function TextIcon(path, size, pad)
	--	Prevent nil
	if size == nil then size = 32 end
	--	Format path
	path = "/esoui/" .. path
	--	Format icon with size
	local icon = "|t" .. size .. ":" .. size .. ":" .. path .. "|t"
	--	Add padding
	if pad	~= nil then
		icon = TextPad(pad) .. icon .. TextPad(pad)
    end
	--	Result
    return icon
end
local function TextColorRGB(t, r, g, b)
	--	Calculate rgb with "saturation"
	r = zo_min(255 * r)
	g = zo_min(255 * g)
	b = zo_min(255 * b)
	--	Format
	return string.format("|c%02x%02x%02x%s|r", r, g, b, t)
end
local function FormatLootInfo(icon, used, total, threshold, hideTotal)
	--	Escape fast if no total
	if total == nil then return icon .. used end

	--	Show/Hide total
	local temp = used
	if not(hideTotal) then
		temp = used .. slash .. total
    end
  
	--	Color under threshold
	if (total - used) <= threshold then
		temp = TextColorRGB(temp, 1, 0.1, 0.1)	-- These are the values for "red"
	end
  
	--	Result
	return " " .. icon .. temp .. " "
	--return icon .. temp
end
local function FormatTimer(s)
	--	years, months, days
	local d = s / 3600 / 24	
	if d > 1 then
		if d > 365 then
			return math.floor(d / 365) .. "y"
		end
		return math.floor(d) .. "d"
	end
	
	--	hours, minutes, seconds
	if s > 0 then
		if s > 3600 then
			return math.floor(s / 3600) .. "h"
		end
		if s > 60 then
			return math.floor(s / 60) .. "m"
		end
		return s .. "s"
	end
	
	--	Empty
	return ""
end


------------------------------------------
--		CONSTANTS

--	Variables from languages files
local hPos_Left		= texts.choices.hPosition[1]
local hPos_Center	= texts.choices.hPosition[2]
local hPos_Right	= texts.choices.hPosition[3]

--	Icons
local icons = {
	["Store"]		= TextIcon('art/guild/guildhistory_indexicon_guildstore_up.dds',	32),
	["Bag"] 		= TextIcon('art/mainmenu/menubar_inventory_up.dds',					32),
	--["Fence"]		= TextIcon('art/vendor/vendor_tabicon_fence_up.dds',				32),
	--["Fence"]		= TextIcon('art/vendor/vendor_tabicon_sell_up.dds',					32),
	["Fence"] 		= TextIcon('art/guild/guildhistory_indexicon_guildstore_up.dds',	32),
	--["Launder"]		= TextIcon('art/icons/servicemappins/servicepin_fence.dds',			28, 2),
	["Launder"]		= TextIcon('art/vendor/vendor_tabicon_fence_up.dds',				32),
	["Steal"]		= TextIcon('art/inventory/inventory_stolenitem_icon.dds',			24, 4),
	["Refresh"]		= TextIcon('art/help/help_tabicon_feedback_up.dds',					32),
	["Loot"]		= TextIcon('art/vendor/vendor_tabicon_buyback_up.dds',				32),
	["Lock"]		= TextIcon('art/tooltips/icon_lock.dds',							32),
}
NTLnS_Icons = icons	-- Share with options

--	Stealth states
--[[
local stealthStates = {
	STEALTH_STATE_NONE,						--	0
	STEALTH_STATE_DETECTED,					--	1
	STEALTH_STATE_HIDING,					--	2
	STEALTH_STATE_HIDDEN,					--	3
	STEALTH_STATE_STEALTH,					--	4
	STEALTH_STATE_HIDDEN_ALMOST_DETECTED,	--	5
	STEALTH_STATE_STEALTH_ALMOST_DETECTED,	--	6
}
]]


------------------------------------------
--		ADD/MODIFY CONTROLS

--	Loot window
--	New part
local lootInfos = WINDOW_MANAGER:CreateControl("AddedLootInfos", LOOT_WINDOW_FRAGMENT.control, CT_LABEL)
lootInfos:SetFont("ZoFontGameLargeBold")
--	Get default height for background
local lootBg = GetControl(LOOT_WINDOW_FRAGMENT.control:GetNamedChild("AlphaContainer"), "BG")
local lootBgInitHeight = lootBg:GetHeight()

--	New in inventory
local slotInfos = WINDOW_MANAGER:CreateControl("AddedSlotInfos", ZO_PlayerInventoryInfoBar, CT_LABEL)
slotInfos:SetFont("ZoFontGameLargeBold")

--	Inventory default "free slots" control
local freeSlots = ZO_PlayerInventoryInfoBarFreeSlots

-- this control displays the steal-confirm key, when targeting a stealable item
local stealLock = WINDOW_MANAGER:CreateControlFromVirtual("StealLock", ZO_ReticleContainerInteract, "ZO_KeybindButton")
stealLock:SetText(icons["Lock"])
stealLock:SetHidden(true)

--	Bounty Display
--	New parts
local centerTimer = -48
local infamyTimer = WINDOW_MANAGER:CreateControl("NTakInfamyTimer", ZO_HUDInfamyMeterFrame, CT_LABEL)
infamyTimer:SetAnchor(CENTER, ZO_HUDInfamyMeterFrame, BOTTOMRIGHT, centerTimer, centerTimer + 10)
infamyTimer:SetFont("ZoFontHeader")
infamyTimer:SetColor(.9, .7, .7, 1)
local bountyTimer = WINDOW_MANAGER:CreateControl("NTakBountyTimer", ZO_HUDInfamyMeterFrame, CT_LABEL)
bountyTimer:SetFont("ZoFontHeader")
bountyTimer:SetColor(.9, .9, .7, 1)


------------------------------------------
--		GETTERS / SETTERS

--	Auto-Loot
local function GetSettingAutoLoot()
	return tonumber(GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT))
end
local function SetSettingAutoLoot(value)
	value = BoolToNum(NTakLootSteal.settings.autoLoot and value)
	
	--	Escape if already correct
	if value == GetSettingAutoLoot() then return end

	--	Change setting
	SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, value)
end

--	Auto-Steal
local function GetSettingAutoSteal()
	return tonumber(GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN))
end
local function SetSettingAutoSteal(value)
	value = BoolToNum(NTakLootSteal.settings.autoSteal and value)

	--	Escape if not altering autosteal
	-- if not(NTakLootSteal.settings.smartAdvContainers) then return end

	--	Escape if already correct
	if value == GetSettingAutoSteal() then return end

	--	Change setting
	SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, value)
end


------------------------------------------
--		FUNCTIONS

--	Update all infos
local bagFree = 0
local bagUsed = 0
local bagMax = 0
local function UpdateInfos()
	--	Escape if no info in loot window or inventory
	if not(NTakLootSteal.settings.infoLoot) and not(NTakLootSteal.settings.infoInventory) then return end
	
	--	Text
	local infoTexts = {}
	local total
	local used
	local resetTimer = ""

	--	Bagpack space
	if NTakLootSteal.settings.infoBag then
		infoTexts[#infoTexts + 1]	= FormatLootInfo(icons["Bag"], bagUsed, bagMax, NTakLootSteal.settings.infoBagLowLimit) .. " "
	end
	
	--	Bagpack space
	if NTakLootSteal.settings.infoBagStolen then
		infoTexts[#infoTexts + 1]	= FormatLootInfo(icons["Steal"], 99) -- TO UPDATE
	end	

	--	Sold stealed items
	if NTakLootSteal.settings.infoSold then
		total, used, resetTimer = GetFenceSellTransactionInfo()
		--	--
		if NTakLootSteal.settings.infoGroupFenced then
			infoTexts[#infoTexts + 1] = FormatLootInfo(icons["Fence"], used, total, NTakLootSteal.settings.infoSoldLowLimit, true)
		else
			infoTexts[#infoTexts + 1] = FormatLootInfo(icons["Fence"], used, total, NTakLootSteal.settings.infoSoldLowLimit)
		end
	end
	
	--	Laundered stealed items
	if NTakLootSteal.settings.infoLaunder then
		total, used, resetTimer = GetFenceLaunderTransactionInfo()
		--	--
    	if NTakLootSteal.settings.infoGroupFenced then
			infoTexts[#infoTexts]	=	infoTexts[#infoTexts] ..
										FormatLootInfo(" & ", used, total, NTakLootSteal.settings.infoSoldLowLimit, true) ..
										" " .. slash .. total
		else
			infoTexts[#infoTexts + 1] = FormatLootInfo(icons["Launder"], used, total, NTakLootSteal.settings.infoLaunderLowLimit)
		end
	end

	--	Reset timer
	if NTakLootSteal.settings.infoTimer then
		local resetHours	= resetTimer / 3600
		local text			= ""
		if resetHours > 1 then
			text = "~" .. math.floor(resetHours + 0.5) .. "h"
		else
			text = "<" .. math.floor(resetHours * 60) .. "min"
		end
		-- i = i + 1
		infoTexts[#infoTexts + 1] = icons["Refresh"] .. text -- string.format("%dh%02d", resetHour, resetMin)
	end
	
	--	Add infos in loot window
	if NTakLootSteal.settings.infoLoot then
		lootInfos:SetText(table.concat(infoTexts, "  "))
	end
	
	--	Add/Replace infos in inventory
	if NTakLootSteal.settings.infoInventory then
		if NTakLootSteal.settings.infoBag and not(NTakLootSteal.settings.infoInventoryIcon) then
			infoTexts[1] = ""
		end
		slotInfos:SetText(table.concat(infoTexts, "  "))
	end
end


--	-v- 	Add stolen filter in inventory																-v-
--Allow only stolen items

local libFilters
local invFilterBarButtonAdded, invFilterBarButtonFlashControlAdded = false, false
local filterTabMenuButtonStolenFilter

local function NTakLootSteal_FilterCalback(slot)
	local isStolen = slot.stolen
	if isStolen then
		return true
	end
	local bagId, slotIndex = slot.bagId, slot.slotIndex
	return IsItemStolen(bagId, slotIndex)
end

local function HandleTabSwitch(tabData)
	PLAYER_INVENTORY:ChangeFilter(tabData)
end

local function CreateNewTabFilterData(filterType, subfilters, inventoryType, normal, pressed, highlight, hiddenColumns, hideTab)
	local filterString = GetString(SI_GAMEPAD_ITEM_STOLEN_LABEL)

	local tabData =
	{
		-- Custom data
		filterType = filterType,
        subfilters = subfilters,
		inventoryType = inventoryType,
		hiddenColumns = hiddenColumns,
		activeTabText = filterString,
		tooltipText = filterString,

		-- Menu bar data
		hidden = hideTab,
		ignoreVisibleCheck = hideTab == true,
		descriptor = ADDON_NAME,
		normal = normal,
		pressed = pressed,
		highlight = highlight,
		callback = HandleTabSwitch,
	}
	return tabData
end

local function onFragmentHiding(filterPanelId)
	if not libFilters then return end
	local invType = INVENTORY_BACKPACK
	filterPanelId = filterPanelId or libFilters:GetCurrentFilterTypeForInventory(invType)
	if filterPanelId then libFilters:UnregisterFilter(ADDON_NAME .. "_" .. tostring(filterPanelId), filterPanelId) end
end

local function ChangeFilterPreHook(self, filterTab)
	if not NTakLootSteal.settings.stolenFilter then return false end
	if filterTab.descriptor == ADDON_NAME then
		if not libFilters then return end
		local invType = INVENTORY_BACKPACK
		local filterPanelId = libFilters:GetCurrentFilterTypeForInventory(invType)
		if filterPanelId then
			if libFilters:IsFilterRegistered(ADDON_NAME .. "_" .. tostring(filterPanelId)) then
				onFragmentHiding(filterPanelId)
			end
			if not libFilters:IsFilterRegistered(ADDON_NAME .. "_" .. tostring(filterPanelId)) then
				libFilters:RegisterFilter(ADDON_NAME .. "_" .. tostring(filterPanelId), filterPanelId, NTakLootSteal_FilterCalback)
			end
			libFilters:RequestUpdate(filterPanelId)
		end
	else
		onFragmentHiding()
	end
end

local function onFragmentShown()
	local inventory = PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK]
	local menuBar = inventory.filterBar
	if not filterTabMenuButtonStolenFilter or not menuBar then return false end
	local filterButtonCtrl = ZO_MenuBar_GetButtonControl(menuBar, filterTabMenuButtonStolenFilter.descriptor)
	if not filterButtonCtrl then return false end
	filterTabMenuButtonStolenFilter.control = filterButtonCtrl
	local flashControl = GetControl(filterButtonCtrl, "Flash")
	if not flashControl then return false end
	ZO_AlphaAnimation:New(flashControl)
	invFilterBarButtonFlashControlAdded = true

	if not libFilters then return end
	local isStolenFilterTabActive = (inventory.filterBar.m_object:GetSelectedDescriptor() == ADDON_NAME) or false
	if isStolenFilterTabActive and filterTabMenuButtonStolenFilter and invFilterBarButtonFlashControlAdded then
		ChangeFilterPreHook(PLAYER_INVENTORY, filterTabMenuButtonStolenFilter)
	end
end

local function hookApplyBackpackLayout(self, layoutData)
	if not NTakLootSteal.settings.stolenFilter then return false end
	if(layoutData == self.appliedLayout and not layoutData.alwaysReapplyLayout) then
		return false
	end
	if not invFilterBarButtonAdded then
		filterTabMenuButtonStolenFilter = CreateNewTabFilterData(
				{ITEMFILTERTYPE_ALL},
				{"All",},
				INVENTORY_BACKPACK,
				"esoui/art/vendor/vendor_tabIcon_fence_up.dds",
				"esoui/art/vendor/vendor_tabIcon_fence_down.dds",
				"esoui/art/vendor/vendor_tabIcon_fence_over.dds",
				{["statValue"] = true},
				not(NTakLootSteal.settings.stolenFilter)
		)
		local inventory = self.inventories[INVENTORY_BACKPACK]
		local backpackFiltersOrig = inventory.tabFilters
		table.insert(backpackFiltersOrig, 1, filterTabMenuButtonStolenFilter)

		invFilterBarButtonAdded = true
	end
end

local function onFragmentStateChange(oldState, newState)
	if not NTakLootSteal.settings.stolenFilter then return false end
	if newState == SCENE_FRAGMENT_SHOWN then
		onFragmentShown()
	elseif newState == SCENE_FRAGMENT_HIDING then
		onFragmentHiding()
	end
end

--	Add stolen filter in inventory even if not using libFilters
local BAG = PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK]
local initStolenFilter = false
local function AddInventoryStolenFilter()
	if initStolenFilter then return end
	--	TODO: Make it to work again ?!
	-- table.insert(BAG.tabFilters, 1, {
		-- filterType = function(slot) return slot.stolen end,
        -- subfilters = {"All",},
		-- inventoryType = INVENTORY_BACKPACK,
		-- hiddenColumns = { ["statValue"] = true, },
		-- hidden = not(NTakLootSteal.settings.stolenFilter),
		-- activeTabText = GetString(SI_GAMEPAD_ITEM_STOLEN_LABEL),
		-- tooltipText = GetString(SI_GAMEPAD_ITEM_STOLEN_LABEL),
		-- normal = "esoui/art/vendor/vendor_tabIcon_fence_up.dds",
		-- pressed = "esoui/art/vendor/vendor_tabIcon_fence_down.dds",
		-- highlight = "esoui/art/vendor/vendor_tabIcon_fence_over.dds",
		-- callback = BAG.tabFilters[1].callback
	-- })
	initStolenFilter = true
end


------------------------------------------
--		EVENTS

--	BACKPACK
local function OnBagUpdate(code, bagID)
	--	Escape if not about backpack
	if (bagID ~= BAG_BACKPACK) then return end
	
	--	Update counts
	bagFree = GetNumBagFreeSlots(BAG_BACKPACK)
	bagUsed	= GetNumBagUsedSlots(BAG_BACKPACK)
	bagMax	= GetBagSize(BAG_BACKPACK)
	
	--	Update info texts
	UpdateInfos()
	
	--	Escape if not altering autoloot
	if not(NTakLootSteal.settings.openContainerIfBagLow) then return end
	
	--	Low space disables autoloot
	SetSettingAutoLoot((bagFree > NTakLootSteal.settings.openContainerLowLimit))
end
local function OnBagUpgrade(code, before, now)
	--	Escape if not upgraded
	if (before == now) then return end

	--	Just call the BagUpdate function
	OnBagUpdate(nil, BAG_BACKPACK)
end
local function OnFenceOpen(code, allowSell, allowLaunder)
	--	Just update the info values
	UpdateInfos()
end

--	STEALTH
local isHidden = false
local function IsHidden(value)
	return (value >= STEALTH_STATE_HIDDEN)
end
local function OnStealthStateChanged(event, unit, stealthState)
	--	Escape if not activated
	if not(NTakLootSteal.settings.smartStealing) then return end

	--	Update hidden value
	isHidden = IsHidden(stealthState)
		
	--	Prevent auto-steal if not hidden
	SetSettingAutoSteal(isHidden)
end


--	RETICLE
-- local text_1
-- local ZO_ReticleUpdateHiddenState = RETICLE.UpdateHiddenState
-- RETICLE.UpdateHiddenState = function(self, ...)
	-- local text = ZO_ReticleContainerStealthIconStealthText:GetText()
	-- if text ~= text_1 then d(text) end
	-- text_1 = text

	-- return ZO_ReticleUpdateHiddenState(self, ...)
-- end
local lastAction = ""
local insects = texts.insects
local function BeforeHandlingInteraction(interactable)
	if interactable and NTakLootSteal.settings.hideInteractInsects or NTakLootSteal.settings.hideInteractEmpty then
		--	Get details about action to be done
		local action, name, blocked, isOwned, additional, context, contextLink, criminal = GetGameCameraInteractableActionInfo()

		--	Escape if not "ok"
		if not(action and name) then return end
    
		--	Debug
		if NTakLootSteal.settings.debug then
			local newAction = action .. " / " .. name .. " / " .. SI_LOOT_TAKE			
			if not(newAction == lastAction) then
				lastAction = newAction
				debug(newAction)
			end			
			-- d(action == SI_LOOT_TAKE)
		end
    
		--	Hide empty
		if	NTakLootSteal.settings.hideInteractEmpty and
			additional == ADDITIONAL_INTERACT_INFO_EMPTY and
			blocked
		then return true end

		--	Hide insects
		if (action == texts.actions.take) then -- INTERACTION_HARVEST 28 
			if NTakLootSteal.settings.hideInteractInsects then
				if (name == insects[1]
				or name == insects[2]
				or name == insects[3]
				or name == insects[4]
				or name == insects[5]
				or name == insects[6]
				or name == insects[7]
				or name == insects[8])
				then
					--	Escape if insects
					return true
				end
			end
		end
		
		--	Hide sit
		-- if (action == texts.actions.use) then -- INTERACTION_HARVEST 28 
			-- if NTakLootSteal.settings.hideInteractSit then
				-- if name == texts.seats[1]
				-- then
					-- --	Escape if seat
					-- return true
				-- end
			-- end
		-- end
	end
	return false
end

local runningInfamy = false
local function UpdateInfamyTimer()
	local s = FormatTimer(GetSecondsUntilHeatDecaysToZero())
	infamyTimer:SetText(s)
	
	if s == "" then
		runningInfamy = false
		bountyTimer:ClearAnchors()
		bountyTimer:SetAnchor(CENTER, ZO_HUDInfamyMeterFrame, BOTTOMRIGHT, centerTimer, centerTimer)
		return
	end	
		
	zo_callLater(UpdateInfamyTimer, 1000)
end
local function OnInfamyUpdate(eventCode, oldInfamy, newInfamy, oldInfamyLevel, newInfamyLevel)
	if not(runningInfamy) then
		runningInfamy = true
		bountyTimer:ClearAnchors()
		bountyTimer:SetAnchor(CENTER, ZO_HUDInfamyMeterFrame, BOTTOMRIGHT, centerTimer, centerTimer - 10)
		UpdateInfamyTimer()
	end
end

--	BOUNTY
local runningBounty = false
local function UpdateBountyTimer()
	local s = FormatTimer(GetSecondsUntilBountyDecaysToZero())
	bountyTimer:SetText(s)
	
	if s == "" then
		runningBounty = false
		return
	end	
		
	zo_callLater(UpdateBountyTimer, 1000)
end
local function OnBountyUpdate(eventCode, oldBounty, newBounty, isInitialize)
	if not(runningBounty) then
		runningBounty = true
		UpdateBountyTimer()
	end
end


------------------------------------------
--		SMART THIEVING

local overrideSmart = false
function SetOverride(value)
	overrideSmart = value
	SetSettingAutoSteal(value)
end

local doubleTapRunning = false
function SetDoubleTap(value)
	--	Escapes
	if NTakLootSteal.settings.smartDoubleTap == 0 then return end
	if doubleTapRunning == value then return end
  
	--	Set
    doubleTapRunning = value
	SetOverride(value)

	--	Delay end
	if value then
		zo_callLater(function()
        	SetDoubleTap(false)
        end, NTakLootSteal.settings.smartDoubleTap)
	end
end
      
local STR_LOOT_STEAL		= GetString(SI_LOOT_STEAL)
local STR_CONTAINER_STEAL	= GetString(SI_GAMECAMERAACTIONTYPE20)
local STR_PICKPOCKET		= GetString(SI_GAMECAMERAACTIONTYPE21)
local function BlockFishing(display)
	--	Fast escape if not using any protection
	if overrideSmart or not(NTakLootSteal.settings.smartStealing) then
		return false
	end
  
	--	Get details about action to be done
	local action, name, blocked, isOwned, additional, context, contextLink, criminal = GetGameCameraInteractableActionInfo()

	--	Debug
	if NTakLootSteal.settings.debug then
		debug( "Action: "		.. (action or "") .. " " .. (name or "") .. " " .. BoolToNum(blocked)
			.. "  / Owned: "	.. BoolToNum(isOwned)
			.. "  / Plus: "		.. (additional or "")
			.. "  / Crime: "	.. BoolToNum(criminal)
			.. "  / Hidden: "	.. BoolToNum(isHidden)
			-- .. "  / Blocked: "	.. value
			,  display)
    end

  	--	No protection for regular interaction
	-- if not(isOwned) and not(criminal) then return false end

	--	Hidden, you can continue!
	if isHidden then return false end

	--	Specific protection if using advanced settings
	if action == STR_PICKPOCKET then	--	Pickpocket
		return NTakLootSteal.settings.smartAdvPickpocket
	elseif action == STR_LOOT_STEAL then		--	Steal from world
		return NTakLootSteal.settings.smartAdvWorldItems
	elseif action == STR_CONTAINER_STEAL then	--	Steal from containers
		if additional == ADDITIONAL_INTERACT_INFO_LOCKED then
			return NTakLootSteal.settings.smartAdvLocked		--	Prevent unwanted unlocking
		elseif GetSettingAutoSteal() == 1 then
			return NTakLootSteal.settings.smartAdvContainers	--	Prevent auto-loot stolen
		end
	end
  
	return false	--	All other cases (should not happen so often, I hope!)
end

--	Update the lock icon when reticle text updates
local function UpdateLock()
	stealLock:SetHidden(not(BlockFishing()) or not(NTakLootSteal.settings.lockIcon))
end

local ZO_ReticleUpdateText = RETICLE.UpdateInteractText
RETICLE.UpdateInteractText = function(self, ...)
	UpdateLock()
	return ZO_ReticleUpdateText(self, ...)
end

--	Interaction start
local ZO_StartInteractFishing
local ZO_StartInteractWheel
if FISHING_MANAGER ~= nil then
	ZO_StartInteractFishing = FISHING_MANAGER.StartInteraction
	function FISHING_MANAGER.StartInteraction(...)
		--	Prevent interaction
		if BlockFishing(true) then
			SetDoubleTap(true)
			return true
		end

		--	Else, continue with regular interaction
		return ZO_StartInteractFishing(...)
	end
end
if INTERACTIVE_WHEEL_MANAGER ~= nil then
	ZO_StartInteractWheel = INTERACTIVE_WHEEL_MANAGER.StartInteraction
	function INTERACTIVE_WHEEL_MANAGER.StartInteraction(...)
		--	Prevent interaction
		if BlockFishing(true) then
			SetDoubleTap(true)
			return true
		end

		--	Else, continue with regular interaction
		return ZO_StartInteractWheel(...)
	end
end

------------------------------------------
--		INIT INFOS

local function Init()
	--	LibFilters
	libFilters = LibFilters3
	NTLnS.libFilters = libFilters
	if libFilters then
		INVENTORY_FRAGMENT:RegisterCallback("StateChange", onFragmentStateChange)		
		--PreHook the ApplyLayout function to add the menubar button once properly
		ZO_PreHook(PLAYER_INVENTORY, "ApplyBackpackLayout", hookApplyBackpackLayout)
		--PreHook the ChangeFilter function to unregister the LibFilters filter function
		ZO_PreHook(PLAYER_INVENTORY, "ChangeFilter", ChangeFilterPreHook)
	else		
		ZO_PreHook(PLAYER_INVENTORY, "ApplyBackpackLayout", AddInventoryStolenFilter)
		-- INVENTORY_FRAGMENT:RegisterCallback("StateChange", AddInventoryStolenFilter)
	end

	--	Default values if not used
	freeSlots:SetAlpha(1)
	lootBg:SetHeight(lootBgInitHeight)
	lootInfos:SetText("")
	slotInfos:SetText("")
	LOOT_SCENE:UnregisterCallback("StateChange")
	
	--	Timers
	if NTakLootSteal.settings.showBountyTimers then
		infamyTimer:SetHidden(false)
		bountyTimer:SetHidden(false)
		
		local alpha = NTakLootSteal.settings.alphaBountyTimers
		infamyTimer:SetAlpha(alpha)		
		bountyTimer:SetAlpha(alpha)
		
		UpdateInfamyTimer()
		UpdateBountyTimer()
	else
		infamyTimer:SetHidden(true)
		bountyTimer:SetHidden(true)
	end
	
	--	Lock position
	stealLock:ClearAnchors()
	if NTakLootSteal.settings.lockAltPosition then
    	stealLock:SetAnchor(LEFT, ZO_ReticleContainerInteractKeybindButton, LEFT, 8, -2)
    else
    	stealLock:SetAnchor(LEFT, ZO_ReticleContainerInteractKeybindButton, LEFT, 25, -4)
    end
	
	--	Initialize values
	SetSettingAutoLoot(true)
	OnBagUpdate(nil, BAG_BACKPACK)
	OnStealthStateChanged(nil, nil, STEALTH_STATE_NONE)

	--	Open container event
	LOOT_SCENE:RegisterCallback("StateChange", function(old, new)
		lootInfos:SetHidden(new ~= SCENE_SHOWN and new ~= SCENE_HIDING)
		-- d(list:GetType()) -- TEST
	end)
	UpdateLock()

	--	Escape if infos not used
	if not(	NTakLootSteal.settings.infoBag or
			NTakLootSteal.settings.infoSold or
			NTakLootSteal.settings.infoLaunder or
			NTakLootSteal.settings.infoTimer
		) then
		return
	end
	
	--	Infos in Inventory
	if NTakLootSteal.settings.infoInventory then
		local offsetY = 0
    	if NTakLootSteal.settings.infoInventoryBelow then	
			offsetY = 24
		end
			
    	if NTakLootSteal.settings.infoInventoryIcon then
			--	Replace default "Inventory space: xxx/xxx"
			freeSlots:SetAlpha(0)
      		slotInfos:SetAnchor(LEFT, ZO_PlayerInventoryInfoBarFreeSlots, LEFT, -8, offsetY)
		else
			--	Place after default "Inventory space: xxx/xxx"
			slotInfos:SetAnchor(LEFT, ZO_PlayerInventoryInfoBarFreeSlots, RIGHT, 0, offsetY)
		end
	end
	
	--	Escape if info in loot not used
	if NTakLootSteal.settings.infoLoot then
		--	Position loot infos at the bottom of the loot window
		lootBg:SetHeight(lootBgInitHeight + 72)	-- Extend background for the new line
		local list = GetControl(LOOT_WINDOW_FRAGMENT.control:GetNamedChild("AlphaContainer"), "List")
		lootInfos:SetAlpha(NTakLootSteal.settings.infoLootAlpha)
		lootInfos:ClearAnchors()
		if NTakLootSteal.settings.infoLootAlign == hPos_Left then
			lootInfos:SetAnchor(TOPLEFT, list, BOTTOMLEFT, 24, 48)
		elseif NTakLootSteal.settings.infoLootAlign == hPos_Right then
			lootInfos:SetAnchor(TOPRIGHT, list, BOTTOMRIGHT, -5, 48)
		else
			lootInfos:SetAnchor(TOP, list, BOTTOM, 0, 48)
		end
	end
end
NTakLootSteal.Init = Init	-- Share with options


------------------------------------------
--		COMMANDS & ASSOCIATED

--	Override Smart Stealing
function Key_OverrideSmart(value)
    SetOverride(value)
end

--	Toggle Auto Loot                                         
function Key_ToggleAutoLoot()
	NTakLootSteal.settings.autoLoot = not(NTakLootSteal.settings.autoLoot)
	SetSettingAutoLoot(true) -- autoLoot value will override if 0
	debug("Autoloot is " .. GetSettingAutoLoot())
end

--	Beta
local function ToggleBeta()
	NTakLootSteal.settings.beta = not(NTakLootSteal.settings.beta)
	
	NTakLootSteal.settings.infoBagStolen = NTakLootSteal.settings.beta
	debug("Beta - Info “Count of stolen”: " .. BoolToNum(NTakLootSteal.settings.infoBagStolen), true)
	NTakLootSteal.Init()
	-- d("Nothing in beta right now!")
end
SLASH_COMMANDS["/ntlns_beta"] = ToggleBeta

--	Debug
local function ToggleDebug()
	NTakLootSteal.settings.debug = not(NTakLootSteal.settings.debug)
	debug("Debug is " .. BoolToNum(NTakLootSteal.settings.debug), true)
end
SLASH_COMMANDS["/ntlns_debug"] = ToggleDebug


------------------------------------------
--		ADDON LOAD

local function OnAddOnLoaded(eventCode, addonName)
	--	Escape if incorrect
	if addonName ~= ADDON_NAME then return end

	--	Unregister on load
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

	--	Default settings
	local defaults = {
		--	Account wide
		accountWide					= true,
		autoLoot					= (GetSettingAutoLoot() > 0), -- true,
		autoSteal					= (GetSettingAutoLoot() > 0), -- true,
		--	Open Container
		hideInteractEmpty			= false,
		hideInteractInsects			= false,
		openContainerIfBagLow		= true,
		openContainerLowLimit		= 10,
		--	Steal
		smartStealing				= true,
		smartDoubleTap				= 0,
		smartAdvanced				= false,
		smartAdvContainers			= true,
		smartAdvLocked				= true,
		smartAdvWorldItems			= true,
		smartAdvPickpocket			= true,
		lockIcon					= true,
		lockAltPosition				= false,
		showBountyTimers			= true,
		alphaBountyTimers			= 1,
		hideInteractSit				= false,
		--	Loot Window
		infoInventory				= true,
		infoInventoryIcon			= false,
		infoInventoryBelow			= false,
		stolenFilter				= true,
		infoLoot					= true,
		infoLootAlign				= hPos_Center,
		infoLootAlpha				= 1,
		infoBag						= true,
		infoBagLowLimit				= 10,
		infoBagStolen				= false,
		infoSold					= false,
		infoSoldLowLimit			= 10,
		infoLaunder					= false,
		infoLaunderLowLimit			= 10,
		infoGroupFenced				= false,
		infoTimer					= false,
		--	Debug
		debug						= false,
		beta						= false,
	}
	
	-- Get character settings
	NTakLootSteal.settings = ZO_SavedVars:NewCharacterIdSettings("NTakLootSteal_SavedVariables", 1, "Settings", defaults)
	-- Get (or create) account wide if selected
	if NTakLootSteal.settings.accountWide then
		if NTakLootSteal_SavedVariables.Default[GetDisplayName()]["$AccountWide"] == nil then
			local currents = CopyTree(NTakLootSteal_SavedVariables.Default[GetDisplayName()][GetCurrentCharacterId()]["Settings"])
			NTakLootSteal.settings = ZO_SavedVars:NewAccountWide("NTakLootSteal_SavedVariables", 1, "Settings", currents)
			zo_callLater(function()
				d("NTakLootSteal: Account-wide settings have been created from current character settings.")
			end, 5000)
		else
			NTakLootSteal.settings = ZO_SavedVars:NewAccountWide("NTakLootSteal_SavedVariables", 1, "Settings", defaults)
		end
	end
	
	--	TODO: MAKE IT WORK AGAIN
	NTakLootSteal.settings.stolenFilter = false	
	
	--	Initialize all
	NTLnS.InitSettings()
	Init()
	
	--	Register to various events	
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_STEALTH_STATE_CHANGED,					OnStealthStateChanged)
	EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_STEALTH_STATE_CHANGED,				REGISTER_FILTER_UNIT_TAG, "player")
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,			OnBagUpdate)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_INVENTORY_BAG_CAPACITY_CHANGED,		OnBagUpgrade)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_OPEN_FENCE,							OnFenceOpen)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_JUSTICE_INFAMY_UPDATED,				OnInfamyUpdate)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_JUSTICE_BOUNTY_PAYOFF_AMOUNT_UPDATED,	OnBountyUpdate)
	
	--	Prehooks
	ZO_PreHook(RETICLE, "TryHandlingInteraction", BeforeHandlingInteraction)
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

--[[

-- 2.1.3
○ Applied, dynamic, Hotfix for GoldRoad. When they finally change the function, IsInUI, from being private, this will automatically stop applying the Hotfix.

-- 2.1.2
○ Added padding below the divider

-- 2.1.1
○ Added missing parameters to ClearLines

-- 2.1
○ The custom price tooltip will now reset whenever the left tooltip clears and when it hides.
- this will stop it from continuing to show when switching to other windows that show the left tooltip

-- 2
○ Added sub-tootip so that price tooltip is always shown at the bottom of the standard tooltip, if available.

-- 1.5.1
○ fixed error caused by having TTC setting Sell Avg off.

-- 1.5
○ Added missing tooltip info 

-- 1.4.1
○ reverted from using hooks to replacing the original layout functions

-- 1.4
○ simplified hooking the gamepad tooltips
○ 

-- 1.3.1
○ fixed error caused by first time running ttc and it's settings have not been established.
○ 

-- 1.3
○ updated tooltip entry style to better fit the gamepad tooltips
○ removed the unused language folder
○ fixed error: Checking type on argument linkStyle failed in GetItemLink_lua, on opening decon assistant.
○ 

-- 1.2
○ removed LayoutFunction since the original is still being fired.

-- 1.1
○ added guild trader tooltip support.

-- 1
○ initial upload

GAMEPAD_TOOLTIP_COLOR_ABILITY_UPGRADE = 6
]]

local addonData = {
	displayName = "|cFF00FFIsJusta|r |cffffffGamepad Tamriel Trade Centre Plugin|r",
	name = "IsJustaGamepadTTCPlugin",
	prefix = "IJA_GPTTCP",
	version = "2.1.3",
}
local _settings = {}

local getTTC_Settings

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------

local custom_tooltip = ZO_InitializingObject:Subclass()

function custom_tooltip:Initialize(parent)
	self.anchors = {}
	self.parent = parent
	self.root = parent:GetNamedChild('Tip')
	table.insert(self.anchors, ZO_Anchor:New(select(2, self.root:GetAnchor(0))))
	table.insert(self.anchors, ZO_Anchor:New(select(2, self.root:GetAnchor(1))))
	
	self.control = CreateControlFromVirtual("$(parent)PriceTooltip", parent, "IJA_GamepadTTCP_Tooltip")
	self.control:SetWidth(parent:GetWidth())
	table.insert(self.anchors, ZO_Anchor:New(BOTTOMRIGHT, self.control, TOPRIGHT, 0, 0))
		
	parent.priceTooltip = self
	
	self.tooltip = self.control:GetNamedChild('Tip')
	ZO_Tooltip:Initialize(self.tooltip, ZO_TOOLTIP_STYLES)

	ZO_PostHookHandler(self.parent, 'OnEffectivelyHidden', function()
		self:Reset()
	end)

	local original_ClearLines = self.parent.tip.ClearLines
	self.parent.tip.ClearLines =  function(tip, ...)
		original_ClearLines(tip, ...)
		self:Reset()
	end
end

function custom_tooltip:Layout_TTC_PriceInfo(itemLink)
	self.tooltip:ClearLines()
	
	if (getTTC_Settings().EnableItemToolTipPricing) then
		local itemInfo = TamrielTradeCentre_ItemInfo:New(itemLink)
		local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemInfo)
		
		if (priceInfo ~= nil) then
			local ttcPrices = self.tooltip:AcquireSection(self.tooltip:GetStyle("ttcGamepadPriceSection"))
			
			-- Add divider.
			ttcPrices:AddTexture(ZO_GAMEPAD_HEADER_DIVIDER_TEXTURE, self.tooltip:GetStyle("dividerLine"))
			ttcPrices:AddLine('', self.tooltip:GetStyle("verticalPadding"))
			
			if (getTTC_Settings().EnableToolTipSuggested and priceInfo.SuggestedPrice ~= nil) then
				ttcPrices:AddLine(string.format("TTC " .. GetString(TTC_PRICE_SUGGESTEDXTOY), 
					TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice, 0), TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice * 1.25, 0)), 
					self.tooltip:GetStyle("bodyHeader"))
			end

			if (getTTC_Settings().EnableToolTipAggregate) then
				ttcPrices:AddLine(string.format("[Avg %s]\n[Min %s/Max %s]", TamrielTradeCentre:FormatNumber(priceInfo.Avg), 
					TamrielTradeCentre:FormatNumber(priceInfo.Min), TamrielTradeCentre:FormatNumber(priceInfo.Max)), 
					self.tooltip:GetStyle("bodyHeader"))
			end

			if (getTTC_Settings().EnableToolTipStat) then
				if (priceInfo.EntryCount ~= priceInfo.AmountCount) then
					ttcPrices:AddLine(string.format(GetString(TTC_PRICE_XLISTINGSYITEMS), TamrielTradeCentre:FormatNumber(priceInfo.EntryCount), TamrielTradeCentre:FormatNumber(priceInfo.AmountCount)), 
					self.tooltip:GetStyle("bodyHeader"))
				else
					ttcPrices:AddLine(string.format(GetString(TTC_PRICE_XLISTINGS), TamrielTradeCentre:FormatNumber(priceInfo.EntryCount)), 
					self.tooltip:GetStyle("bodyHeader"))
				end
			end
										
			if (getTTC_Settings().EnableToolTipSalePrice and priceInfo.SaleAvg ~= nil) then
				ttcPrices:AddLine(string.format(GetString(TTC_PRICE_SALEAVGX), TamrielTradeCentre:FormatNumber(priceInfo.SaleAvg, 2)), 
				self.tooltip:GetStyle("bodyHeader"))
				
				if (getTTC_Settings().EnableToolTipStat) then
					if (priceInfo.SaleEntryCount ~= priceInfo.SaleAmountCount) then
						ttcPrices:AddLine(string.format(GetString(TTC_PRICE_XSALESYITEMS), TamrielTradeCentre:FormatNumber(priceInfo.SaleEntryCount), TamrielTradeCentre:FormatNumber(priceInfo.SaleAmountCount)), 
						self.tooltip:GetStyle("bodyHeader"))
					else
						ttcPrices:AddLine(string.format(GetString(TTC_PRICE_XSALES), TamrielTradeCentre:FormatNumber(priceInfo.SaleEntryCount)), 
						self.tooltip:GetStyle("bodyHeader"))
					end
				end
			end
		
			-- Show update price table notice if it is out of date.
			if (getTTC_Settings().EnableToolTipLastUpdate) then
				ttcPrices:AddLine(TamrielTradeCentrePrice:GetPriceTableUpdatedDateString(), 
				self.tooltip:GetStyle("abilityUpgrade"))
			end
			self.tooltip:AddSection(ttcPrices)
			
			self:SetAnchors()
			self.control:SetHidden(false)
			self.control:SetHeight(ttcPrices:GetPrimaryDimension())
		end
	end
end

function custom_tooltip:Reset()
	self.control:SetHidden(true)
	self.root:ClearAnchors()
	self.anchors[1]:AddToControl(self.root)
	self.anchors[2]:AddToControl(self.root)
end

function custom_tooltip:SetAnchors()
	self.root:ClearAnchors()
	self.anchors[1]:AddToControl(self.root)
	self.anchors[3]:AddToControl(self.root)
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
-- add custom section style to ZO_TOOLTIP_STYLES
ZO_TOOLTIP_STYLES.ttcGamepadPriceSection = {
	paddingTop = 30,
	customSpacing = 20,
--	fontSize = "$(GP_34)",
	fontSize = "$(GP_27)",
	fontFace = "$(GAMEPAD_BOLD_FONT)",
	fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1, -- white
	uppercase = true,
	widthPercent = 100,
	horizontalAlignment = TEXT_ALIGN_CENTER
}

ZO_TOOLTIP_STYLES.verticalPadding = {
	customSpacing = 10,
	widthPercent = 100,
}

local function getFirstParam(itemLink)
	return itemLink
end

local function getItemLinkFromBagAndSlot(bagId, slotIndex)
	-- must use this method in order to prevent errors from 3rd pram getting passed as linkStyle
	return GetItemLink(bagId, slotIndex)
end

getTTC_Settings = function ()
	local settings = TamrielTradeCentre.Settings or {}
	return settings
end

local function getAndInitilizeTooltip(tooltipContainer)
	local priceTooltip = tooltipContainer.priceTooltip
	if not priceTooltip then
		priceTooltip = custom_tooltip:New(tooltipContainer)
	end
	return priceTooltip
end


---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
local addon = ZO_InitializingObject:Subclass()

function addon:Initialize(control)
	self.control = control
	zo_mixin(self, addonData)
	
	local function OnLoaded(_, name)
		if name ~= self.name then return end
		self.control:UnregisterForEvent(EVENT_ADD_ON_LOADED)
		
		self:SetupHooks()
	end
	control:RegisterForEvent( EVENT_ADD_ON_LOADED, OnLoaded)
	
	local function onPlayerActivated()
		control:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
		--	d( self.displayName .. " version: " .. self.version)
	end
	control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, onPlayerActivated)
end

function addon:SetupHooks()
	local function setupFunction(toolTipControl, functionName, getItemLinkFunction)
		local orig_function = toolTipControl[functionName]
		toolTipControl[functionName] = function(object, tooltipType, ...)
			-- For GAMEPAD_TOOLTIPS we must set the current function name, else it will show last used tooltip layoutFunction.
			-- This is normally done in GAMEPAD_TOOLTIPS's metaTable. Overriding a tooltip function breaks the metaTable.
			toolTipControl.currentLayoutFunctionName = functionName
			local isValidItemLink = orig_function(toolTipControl, tooltipType, ...)
			local tooltipContainer = toolTipControl:GetTooltipContainer(tooltipType)
			
			if tooltipContainer then
				local priceTooltip = getAndInitilizeTooltip(tooltipContainer)
				
				if priceTooltip then
					priceTooltip:Layout_TTC_PriceInfo(getItemLinkFunction(...))
				end
			end
	
			return isValidItemLink
		end
	end
	
	setupFunction(GAMEPAD_TOOLTIPS, 'LayoutBagItem', getItemLinkFromBagAndSlot) -- params (bagId, slotIndex, showCombinedCount, extraData)
	setupFunction(GAMEPAD_TOOLTIPS, 'LayoutItem', getFirstParam) -- first param itemLink
	setupFunction(GAMEPAD_TOOLTIPS, 'LayoutGuildStoreSearchResult', getFirstParam) -- first param itemLinkv
end

-- Fix for Gold Road
-- /EsoUI/Libraries/Utility/ZO_PlatformUtils.lua:119: Attempt to access a private function 'IsInUI' from insecure code.
if IsPrivateFunction('IsInUI') then
	ZO_IsIngameUI = function()
		return SCRIBING_DATA_MANAGER ~= nil
	end
end
--	/script d( ZO_IsIngameUI())

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
function IJA_GamepadTTCP_Initialize( ... )
	IJA_GAMEPADTTCP = addon:New( ... )
end

-- Must be the first line
ISD = {}

ISD.name = "InventorySpaceDisplay"
ISD.version = "1.7"
ISD.throttle = {}
ISD.defaults = {
	offsetX = 0,
	offsetY = 0,
	showFreeSpace = false,
	lockWindowPosition = false,
	autoHideDisplay = false,
	transparency = 1.0,
}

function ISD.CreateConfiguration()
	
	local LAM = LibStub("LibAddonMenu-2.0")

	local panelData = {
		type = "panel",
		name = "Inventory Space Display",
		author = "L8Knight",
		version = ISD.version,
		registerForDefaults = true,
	}

	LAM:RegisterAddonPanel(ISD.name.."Config", panelData)

	local controlData = {
		[1] = {
			type = "checkbox",
			name = "Lock Window Position",
			tooltip = "Prevents the display from being moved",
			getFunc = function() return ISD.vars.lockWindowPosition end,
			setFunc = function(newValue) ISD.UpdateLockStatus(newValue) end,
			default = ISD.defaults.lockWindowPosition,
		},
		[2] = {
			type = "checkbox",
			name = "Show Free Space",
			tooltip = "Display the number of free slots instead of used slots",
			getFunc = function() return ISD.vars.showFreeSpace end,
			setFunc = function(newValue) ISD.vars.showFreeSpace = newValue; ISD.UpdateLabel() end,
			default = ISD.defaults.showFreeSpace,
		},
		[3] = {
			type = "checkbox",
			name = "Auto Hide",
			tooltip = "Automatically hide the display when viewing non-interactive windows",
			getFunc = function() return ISD.vars.autoHideDisplay end,
			setFunc = function(newValue) ISD.vars.autoHideDisplay = newValue end,
			default = ISD.defaults.autoHideDisplay,
		},
		[4] = {
			type = "slider",
			name = "Transparency",
			tooltip = "Transparency value for the display",
			min = 0, max = 10, step = 1,
			getFunc = function() return ISD.vars.transparency * 10 end,
			setFunc = function(newValue) ISD.vars.transparency = newValue / 10.0; ISD.UpdateLabel() end,
			default = ISD.defaults.transparency * 10,
		},
	}

	LAM:RegisterOptionControls(ISD.name.."Config", controlData)

end

-- Initializer functions that runs once when the game is loading addons
function ISD.Initialize(eventCode, addOnName)

	-- Only initialize our own addon
	if ISD.name ~= addOnName then return end

	-- Load the saved variables
	ISD.vars = ZO_SavedVars:NewAccountWide("ISDVars", 2, nil, ISD.defaults)

	if ISD.vars.offsetX == 0 and ISD.vars.offsetY == 0 then
		local screenWidth, screenHeight = GuiRoot:GetDimensions()
		ISD.vars.offsetX = screenWidth / 2
		ISD.vars.offsetY = (screenHeight / 2) + 50
	end

	ISD.CreateConfiguration()

	InventorySpaceDisplay:ClearAnchors()
	InventorySpaceDisplay:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ISD.vars.offsetX, ISD.vars.offsetY)

	InventorySpaceDisplayLabel:ClearAnchors()
	InventorySpaceDisplayLabel:SetAnchor(TOP, InventorySpaceDisplay, TOP, 0, 0)

	InventorySpaceDisplayCount:ClearAnchors()
	InventorySpaceDisplayCount:SetAnchor(LEFT, InventorySpaceDisplayLabel, RIGHT, 5, 0)

	InventorySpaceDisplay:SetMovable(not ISD.vars.lockWindowPosition)

	ZO_PreHookHandler(ZO_KeybindStripControl, 'OnShow', ISD.HideSpaceDisplay)
	ZO_PreHookHandler(ZO_KeybindStripControl, 'OnHide', ISD.ShowSpaceDisplay)

	-- Called when we take something from the loot window
	--EVENT_MANAGER:RegisterForEvent("ISD", EVENT_LOOT_RECEIVED, function(...) ISD.EventDebug("EVENT_LOOT_RECEIVED") end)

	-- Called when the loot window is updated or opened
	--EVENT_MANAGER:RegisterForEvent("ISD", EVENT_LOOT_UPDATED, function(...) ISD.EventDebug("EVENT_LOOT_UPDATED", ...) end)

	-- Called when a slot in your inventory is modified
	EVENT_MANAGER:RegisterForEvent("ISD", EVENT_INVENTORY_SINGLE_SLOT_UPDATE , ISD.UpdateLabel)

	-- Called when you feed your mount
	EVENT_MANAGER:RegisterForEvent("ISD", EVENT_MOUNT_UPDATE , ISD.UpdateLabel)

	-- Called when you purchase more bag space
	EVENT_MANAGER:RegisterForEvent("ISD", EVENT_INVENTORY_BOUGHT_BAG_SPACE, ISD.UpdateLabel)
	
	ISD.UpdateLabel()

end

function ISD.EventDebug(...)

	d(...)

end

function ISD.UpdateLockStatus(newValue)

	ISD.vars.lockWindowPosition = newValue
	InventorySpaceDisplay:SetMovable(not ISD.vars.lockWindowPosition)

end

function ISD.MoveStop()
	
	ISD.vars.offsetX = InventorySpaceDisplay:GetLeft()
	ISD.vars.offsetY = InventorySpaceDisplay:GetTop()
	
end

function ISD.HideSpaceDisplay()

	-- Don't hide display when the loot window pops up
	if not ZO_Loot:IsHidden() then
		return
	end

	-- Otherwise, hide display when looking through inventory
	if ISD.vars.autoHideDisplay then
		InventorySpaceDisplay:SetHidden(true)
	end

end

function ISD.ShowSpaceDisplay()

	InventorySpaceDisplay:SetHidden(false)
	ISD.UpdateLabel()

end

function ISD.UpdateLabel()
	
	local usedSlots, maxSlots = PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)
	
	if ISD.vars.showFreeSpace then
		usedSlots = maxSlots - usedSlots
	end
	
	InventorySpaceDisplayCount:SetText(usedSlots.." / "..maxSlots)
	InventorySpaceDisplay:SetAlpha(ISD.vars.transparency)

end

-- Register for the init handler (needs to be declaired after the ISD.Initialize function)
EVENT_MANAGER:RegisterForEvent("ISD", EVENT_ADD_ON_LOADED, ISD.Initialize)

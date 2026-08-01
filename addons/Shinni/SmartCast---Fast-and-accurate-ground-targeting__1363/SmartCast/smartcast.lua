SmartCast = {}
local SmartCast = _G["SmartCast"]
-- check if the addon runs on a pre or post DB client
SmartCast.preDB = (QUICK_CAST_GROUND_ABILITIES_CHOICE_OFF == nil)
-- first slot/button of the ability bar
SmartCast.firstSlot = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1
-- only on post DB clients the ground targeting ultimates aren't cast instantly
-- if this is a pre DB client, we don't need to manipulate the ultimate slot
if SmartCast.preDB then
	SmartCast.lastSlot = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + ACTION_BAR_SLOTS_PER_PAGE - 1
else
	SmartCast.lastSlot = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1
end
-- localized name of the ground target type
SmartCast.localizedGround = GetString(SI_ABILITY_TOOLTIP_TARGET_TYPE_GROUND)
-- list of controls that are added to the ability buttons/slots
SmartCast.controls = {}
SmartCast.originalFunctions = {}
SmartCast.enabledSlots = {}
SmartCast.activeSlots = {}


function SmartCast.Prepare(slotNum)
	SmartCast.enabledSlots[slotNum] = true
	
	local button = ZO_ActionBar_GetButton(slotNum)
	-- check if this button has already been prepared
	if button and not SmartCast.originalFunctions[slotNum] then
		SmartCast.controls[slotNum]:SetTexture("/SmartCast/smartcast.dds")
		-- save the original functions so we can revert back when the ability is exchanged
		SmartCast.originalFunctions[slotNum] = {
			HandlePress = button.HandlePress,
			HandleRelease = button.HandleRelease,
		}
		-- overwrite the handlers
		button.HandlePress = button.HandlePressAndRelease
		button.HandleRelease = button.HandlePressAndRelease
		-- releasing the button should only be interpreted as pressing the ability again
		-- if we are currently targeting the ground
		-- e.g. the player might have cancelled the ability via blocking
		ZO_PreHook(button, "HandleRelease", function()
			return not IsPlayerGroundTargeting()
		end)
    end
end

-- this function reverts SmartCast.Prepare and is used if a ground targeting ability is replaced with
-- another ability
function SmartCast.Restore(slotNum)
	SmartCast.enabledSlots[slotNum] = false
	
	local button = ZO_ActionBar_GetButton(slotNum)
	-- check if this button needs to be reverted to the original state
	if button and SmartCast.originalFunctions[slotNum] then
		SmartCast.controls[slotNum]:SetTexture("/SmartCast/nosmartcast.dds")
		-- restore the original state by returning the original handlers to the button
		for key, value in pairs(SmartCast.originalFunctions[slotNum]) do
			button[key] = value
		end
		SmartCast.originalFunctions[slotNum] = nil
    end
end

function SmartCast.HandleSlotChanged(eventCode, slotNum)
	-- check if the slot is one of the 5 ability slots
	if slotNum < SmartCast.firstSlot then
		return
	end
	if slotNum > SmartCast.lastSlot then
		return
	end
	-- check if the ability is ground targeting
	local abilityId = GetSlotBoundId(slotNum)
	local targetType = GetAbilityTargetDescription(abilityId)
	if targetType == SmartCast.localizedGround then
		-- the abiliy is ground targeting so display the smart cast setting
		SmartCast.controls[slotNum]:SetHidden(false)
		-- update the cast functions to allow smart casting
		if SmartCast.preventSmart[abilityId] then
			SmartCast.Restore(slotNum)
		else
			SmartCast.Prepare(slotNum)
		end
	else
		-- the ability isn't ground targeting, so remove the settings display
		-- and restore the button/slot to remove smart casting
		SmartCast.controls[slotNum]:SetHidden(true)
		SmartCast.Restore(slotNum)
	end
end

-- the default ui refreshes the action bar on each EVENT_PLAYER_ACTIVATED
-- so it might be better to update the smart casting as well
function SmartCast.OnPlayerActivated()
	SmartCast.OnFullUpdate()
end

function SmartCast.OnFullUpdate(eventCode, isHotbarSwap)
	-- iterate over the 5 ability slots/buttons and update them
	for slotNum = SmartCast.firstSlot, SmartCast.lastSlot do
		SmartCast.HandleSlotChanged(eventCode, slotNum)
	end
end

function SmartCast.OnAddonLoaded(eventCode, addonName)
	if addonName ~= "SmartCast" then
		return
	end
	-- load smart cast settings
	SmartCast.preventSmart = ZO_SavedVars:New("SmartCast_SavedVariables", 1, "preventSmart", {})
	if not SmartCast.preDB then
		-- ZOS' smart cast needs to be off for this addon to work, so disable it
		SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_QUICK_CAST_GROUND_ABILITIES, QUICK_CAST_GROUND_ABILITIES_CHOICE_OFF)
	end
	-- create a control underneath each ability slot control, to diplay/change the smart cast settings
	for slotNum = SmartCast.firstSlot, SmartCast.lastSlot do
		local button = ZO_ActionBar_GetButton(slotNum)
		local control = WINDOW_MANAGER:CreateControl(nil, button.slot, CT_TEXTURE)
		-- the control is underneath the bottom right corner of the slot control
		control:SetAnchor(TOPLEFT, button.slot:GetNamedChild('FlipCard'), BOTTOMRIGHT,  -16, 2)
		control:SetAnchor(BOTTOMRIGHT, button.slot:GetNamedChild('FlipCard'), BOTTOMRIGHT,0, 18)
		control:SetTexture("/SmartCast/nosmartcast.dds")
		control:SetDrawLevel(2)
		control:SetHidden(true)
		control:SetMouseEnabled(true)
		-- when the settings control is clicked, change the smart cast setting for this ability
		control:SetHandler("OnMouseUp", function(control, ...)
			PlaySound("Click")
			local abilityId = GetSlotBoundId(slotNum)
			SmartCast.preventSmart[abilityId] = not SmartCast.preventSmart[abilityId]
			SmartCast.HandleSlotChanged(eventCode, slotNum)
		end)
		-- save the control in a list, so we can access it later to update the texture and visibility
		SmartCast.controls[slotNum] = control
	end
	-- add callbacks to update the smart cast when the abilities in the action bar are swapped etc
	EVENT_MANAGER:RegisterForEvent("SmartCast", EVENT_ACTION_SLOT_UPDATED, SmartCast.HandleSlotChanged)
	EVENT_MANAGER:RegisterForEvent("SmartCast", EVENT_PLAYER_ACTIVATED, SmartCast.OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent("SmartCast", EVENT_ACTION_SLOTS_FULL_UPDATE, SmartCast.OnFullUpdate)
end

EVENT_MANAGER:RegisterForEvent("SmartCast", EVENT_ADD_ON_LOADED, SmartCast.OnAddonLoaded)

-- mannimarco is nothing compared to the black magic below:
local origGetUIMousePosition = GetUIMousePosition
local origDown = ZO_ActionBar_OnActionButtonDown
local origNormalizePointToControl = NormalizePointToControl

local dummySelf = {
	registeredMessageFormatters = {}
}
dummySelf.registeredMessageFormatters = setmetatable(dummySelf.registeredMessageFormatters, {
	__index = function(tbl, key)
		GetUIMousePosition = function()
			GetUIMousePosition = origGetUIMousePosition
			return "OnSlotUp"
		end
		NormalizePointToControl = GetControl
		return NormalizeMousePositionToControl()
	end
})
dummySelf = setmetatable(dummySelf, {__call = CHAT_ROUTER.FormatAndAddChatMessage} )


ZO_PreHook("GetControl", function()
	if NormalizePointToControl ~= origNormalizePointToControl then
		NormalizePointToControl = origNormalizePointToControl
	end
end)

ZO_ActionBar_OnActionButtonDown = NormalizeMousePositionToControl
ZO_PreHook("ZO_ActionBar_OnActionButtonDown", function(buttonId)
	origDown(buttonId)
	if not SmartCast.enabledSlots[buttonId] then return true end
	SmartCast.activeSlots[buttonId] = true
	GetUIMousePosition = function() return buttonId, buttonId end
	NormalizePointToControl = dummySelf
end)

ZO_PreHook("ZO_ActionBar_OnActionButtonUp", function(buttonId)
	SmartCast.activeSlots[buttonId] = nil
end)

local origZO_ActionBar_CanUseActionSlots = ZO_ActionBar_CanUseActionSlots
function ZO_ActionBar_CanUseActionSlots()
	if next(SmartCast.activeSlots) and not IsPlayerGroundTargeting() then
		for slot in pairs(SmartCast.activeSlots) do
			ZO_ActionBar_OnActionButtonUp(slot)
		end
		return false
	end
	return origZO_ActionBar_CanUseActionSlots()
end


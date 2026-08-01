-- Basic Addon Info
local SQP = {
	addonName = "StaticsQuickslotProfiles",
	addonVersion = "2.3.0",
	author = "|CFF0000Static_Recharge|r",
}

-- Default Settings
SQP.Character = {
	Defaults = {
		Profiles = {},
		panelTop = nil,
		panelLeft = nil,
		profile1 = nil,
		profile2 = nil,
		profile3 = nil,
		profile4 = nil,
		profile5 = nil,
	},
	SavedVars = {
		Profiles = {},
	},
	varsVersion = 2,
}

-- Constants
local Const = {
	chatPrefix = "|cB759FF[SQP]: |cFFFFFF",
	chatSuffix = "|r",
	firstQuickslotIndex = 9,
	lastQuickslotIndex = 16,
	quickslotSize = 8,
	inventoryBagID = 1,
	itemLinkDefaultStyle = 0,
	inventoryStartIndex = 0,
	actionDelayMS = 350,
}

-- Sends info to the chatbox
function SQP.SendToChat(text)
	if text ~= nil then
		d(Const.chatPrefix .. text .. Const.chatSuffix)
	else
		d(Const.chatPrefix .. "nil string" .. Const.chatSuffix)
	end
end

-- Reports the information from all saved profiles and lists which items in inventory the addon recognizes as slottable.
function SQP.Debug()
	for i,v in pairs(SQP.Character.SavedVars.Profiles) do
		SQP.SendToChat("Profile: " .. i .. ":")
		for j,k in pairs(v) do
			SQP.SendToChat("Slot: " .. j .. ", itemID: " .. k.itemID .. ", itemLink: " .. k.itemLink .. ", identifier: " .. k.identifier)
		end
	end

	SQP.GetInventoryQuickslotInfo()
	SQP.SendToChat("Inventory Info:")
	for i,v in pairs(SQP.Inventory) do
		for j,k in pairs(v) do
			SQP.SendToChat("Slot: " .. k.slot .. ", itemID: " .. i .. ", itemLink: " .. k.itemLink .. ", identifier: " .. k.identifier)
		end
	end
end

-- Lists all the saved profiles
function SQP.List()
	SQP.SendToChat("List of saved profiles:")
	for i,v in pairs(SQP.Character.SavedVars.Profiles) do
		SQP.SendToChat(i)
	end
end

-- UI control functions
function SQP.ShowNewProfileMode(state)
	SQP_PanelComboBox:SetHidden(state)
	SQP_PanelNewButton:SetHidden(state)
	SQP_PanelClearButton:SetHidden(state)
	SQP_PanelSaveButton:SetHidden(state)
	SQP_PanelLoadButton:SetHidden(state)

	SQP_PanelEditBoxBG:SetHidden(not state)
	SQP_PanelEditBoxControl:SetHidden(not state)
	SQP_PanelOKButton:SetHidden(not state)
	SQP_PanelCancelButton:SetHidden(not state)
end

function SQP.NewButtonPressed()
	SQP.ShowNewProfileMode(true)
	SQP_PanelEditBoxControl:SetText("")
end

function SQP.EscapePressed()
	SQP.ShowNewProfileMode(false)
	SQP_PanelEditBoxControl:SetText("")
end

function SQP.New(profile)
	SQP.Save(profile)
	SQP.UpdateDropDownList()
	SQP.Dropdown:SetSelectedItem(profile)
	SQP_PanelEditBoxControl:SetText("")
	SQP.EscapePressed()
end


function SQP.Clear(profile)
	if SQP.Character.SavedVars.Profiles[profile] == nil then
		SQP.SendToChat("Not a valid profile name.")
	else
		SQP.Character.SavedVars.Profiles[profile] = nil
		SQP.SendToChat("Quickslot profile \"" .. profile .. "\" cleared.")
	end
	SQP.UpdateDropDownList()
end

function SQP.Save(profile)
	SQP.Character.SavedVars.Profiles[profile] = SQP.GetQuickslotInfo()
	SQP.SendToChat("Quickslots saved to profile \"" .. profile .. "\".")
	SQP.UpdateDropDownList()
	SQP.Dropdown:SetSelectedItem(profile)
end

function SQP.EnableButtons(state)
	SQP_PanelLoadButton:SetEnabled(state)
	SQP_PanelNewButton:SetEnabled(state)
	SQP_PanelClearButton:SetEnabled(state)
	SQP_PanelSaveButton:SetEnabled(state)
end

function SQP.OnMoveStop()
	SQP.Character.SavedVars.panelLeft = SQP_Panel:GetLeft()
	SQP.Character.SavedVars.panelTop = SQP_Panel:GetTop()
end

function SQP.RestorePanel()
	local left = SQP.Character.SavedVars.panelLeft
	local top = SQP.Character.SavedVars.panelTop

	if left ~= nil and top ~= nil then
		SQP_Panel:ClearAnchors()
		SQP_Panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
	end

	if SQP.Character.SavedVars.profile1 ~= nil then
		SQP_PanelProfile1Label:SetText("1: " .. SQP.Character.SavedVars.profile1)
	else
		SQP_PanelProfile1Label:SetText("1: Not Set")
	end

	if SQP.Character.SavedVars.profile2 ~= nil then
		SQP_PanelProfile2Label:SetText("2: " .. SQP.Character.SavedVars.profile2)
	else
		SQP_PanelProfile2Label:SetText("2: Not Set")
	end

	if SQP.Character.SavedVars.profile3 ~= nil then
		SQP_PanelProfile3Label:SetText("3: " .. SQP.Character.SavedVars.profile3)
	else
		SQP_PanelProfile3Label:SetText("3: Not Set")
	end

	if SQP.Character.SavedVars.profile4 ~= nil then
		SQP_PanelProfile4Label:SetText("4: " .. SQP.Character.SavedVars.profile4)
	else
		SQP_PanelProfile4Label:SetText("4: Not Set")
	end

	if SQP.Character.SavedVars.profile5 ~= nil then
		SQP_PanelProfile5Label:SetText("5: " .. SQP.Character.SavedVars.profile5)
	else
		SQP_PanelProfile5Label:SetText("5: Not Set")
	end
end

function SQP.InitDropDownList()
	local wm = WINDOW_MANAGER  --just an upvalue
	local profileComboBox = wm:CreateControlFromVirtual("SQP_PanelComboBox", SQP_Panel, "SQPComboBoxTemplate")  --create your dropdown container using the template above
	profileComboBox:ClearAnchors()
	profileComboBox:SetDimensions(200, 30)
	profileComboBox:SetAnchor(TOP, SQP_PanelTopDivider, BOTTOM, 0, 5)
	SQP.Dropdown = ZO_ComboBox_ObjectFromContainer(profileComboBox)
	SQP.UpdateDropDownList()
end

function SQP.UpdateDropDownList()
	SQP.Dropdown:ClearItems()
	for i,v in pairs(SQP.Character.SavedVars.Profiles) do
		local itemEntry = SQP.Dropdown:CreateItemEntry(i, function() return(i) end)
		SQP.Dropdown:AddItem(itemEntry)
	end
	SQP.Dropdown:SelectFirstItem()
end

function SQP.GetItemIDFromLink(itemLink)
	local itemID
	_, _, itemID = string.find(itemLink, ":(%d+):")
	return tonumber(itemID)
end

function SQP.GetIdentifierFromLink(itemLink)
	local identifier
	_, _, identifier = string.find(itemLink, ":(%d+)|")
	return tonumber(identifier)
end

-- Cycles through each item in the profile to load it into the quickslots
function SQP.QuickslotLoadIterator(profile, slot)
	local itemLink = SQP.Character.SavedVars.Profiles[profile][slot].itemLink
	local itemID = SQP.Character.SavedVars.Profiles[profile][slot].itemID
	local identifier = SQP.Character.SavedVars.Profiles[profile][slot].identifier
	local found = false
	CallSecureProtected("ClearSlot", slot)
	if itemLink ~= "" then
		local collectibleID = GetCollectibleIdFromLink(itemLink)
		if collectibleID ~= nil then
			CallSecureProtected("SelectSlotSimpleAction", ACTION_TYPE_COLLECTIBLE, collectibleID, slot)
		else
			if SQP.Inventory[itemID] ~= nil then
				if SQP.Inventory[itemID][2] ~= nil then
					for i,v in pairs(SQP.Inventory[itemID]) do
						if v.identifier == identifier then
							CallSecureProtected("SelectSlotItem", Const.inventoryBagID, v.slot, slot)
							found = true
							break
						end
					end
					if found == false then
						CallSecureProtected("SelectSlotItem", Const.inventoryBagID, SQP.Inventory[itemID][1].slot, slot)
					end
				else
					CallSecureProtected("SelectSlotItem", Const.inventoryBagID, SQP.Inventory[itemID][1].slot, slot)
				end
			else
				SQP.SendToChat(itemLink .. " not found in inventory.")
			end
		end		
	end
	slot = slot + 1
	if slot <= Const.lastQuickslotIndex then
		zo_callLater(function() SQP.QuickslotLoadIterator(profile, slot) end, Const.actionDelayMS)
	else
		SQP.SendToChat("Quickslots loaded from profile \"" .. profile .. "\".")
		zo_callLater(function() SQP.EnableButtons(true) end, Const.actionDelayMS)
	end
end

-- Loads the profile into the quickslots
function SQP.Load(profile)
	if SQP.Character.SavedVars.Profiles[profile] == nil then
		SQP.SendToChat("Not a valid profile name.")
	else
		SQP.GetInventoryQuickslotInfo()
		SQP.EnableButtons(false)
		SQP.QuickslotLoadIterator(profile, Const.firstQuickslotIndex)
	end
end

function SQP.GetInventoryQuickslotInfo()
	local bagSpace = GetBagSize(Const.inventoryBagID)
	SQP.Inventory = {}
	for i = Const.inventoryStartIndex, bagSpace do
		if IsValidItemForSlot(Const.inventoryBagID, i, Const.firstQuickslotIndex) then
			local itemID = GetItemId(Const.inventoryBagID, i)
			local itemLink = GetItemLink(Const.inventoryBagID, i)
			local identifier = SQP.GetIdentifierFromLink(itemLink)
			if SQP.Inventory[itemID] == nil then
				SQP.Inventory[itemID] = {}
				SQP.Inventory[itemID][1] = {slot = i, itemLink = itemLink, identifier = identifier}
			else
				info = {slot = i, itemLink = itemLink, identifier = identifier}
				table.insert(SQP.Inventory[itemID], info)
			end
		end
	end
end

function SQP.GetQuickslotInfo()
	local Info = {}
	for i = Const.firstQuickslotIndex, Const.lastQuickslotIndex do
		local itemLink = GetSlotItemLink(i)
		local itemID = SQP.GetItemIDFromLink(itemLink)
		local identifier = SQP.GetIdentifierFromLink(itemLink)
		Info[i] = {
			itemLink = itemLink,
			itemID = itemID,
			identifier = identifier
		}
	end
	return Info
end

function SQP.SelectQuickslot(slot)
	local current = GetCurrentQuickslot()
	if current ~= slot then
		SetCurrentQuickslot(slot)
	end
end

function SQP.CommandParse(args)
	local options = {}
	local searchResult = {string.match(args, "^(%S*)%s*(.-)$")}
	for i,v in pairs(searchResult) do
		if (v ~= nil and v~= "") then
			options[i] = string.lower(v)
		end
	end

	if #options == 0 then
		SQP.SendToChat("Commands:")
		SQP.SendToChat("/sqp clear <profile> - Clears the <profile>* from memory.")
		SQP.SendToChat("/sqp save <profile> - Saves the currently slotted quickslots to the <profile>*.")
		SQP.SendToChat("/sqp load <profile> - Loads <profile>* into the currently slotted quickslots.")
		SQP.SendToChat("/sqp list - Lists all saved profiles")
		SQP.SendToChat("/sqp debug - Lists debug information")
		SQP.SendToChat("*<profile> can be any valid string.")
	else
		if options[1] == "clear" then
			SQP.Clear(options[2])

		elseif options[1] == "save" then
			SQP.Save(options[2])

		elseif options[1] == "load" then
			SQP.Load(options[2])

		elseif options[1] == "debug" then
			SQP.Debug()

		elseif options[1] == "list" then
			SQP.List()

		else
			SQP.SendToChat("Invalid command.")

		end
	end
end

function SQP.SetToolTip(control, text)
	control:SetHandler("onMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, text) end)
	control:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
end

function SQP.TooltipInit()
	SQP.SetToolTip(SQP_PanelNewButton, "New")
	SQP.SetToolTip(SQP_PanelClearButton, "Clear")
	SQP.SetToolTip(SQP_PanelSaveButton, "Save")
	SQP.SetToolTip(SQP_PanelLoadButton, "Load")
	SQP.SetToolTip(SQP_PanelOKButton, "Accept")
	SQP.SetToolTip(SQP_PanelCancelButton, "Cancel")
	SQP.SetToolTip(SQP_PanelProfile1SetButton, "Set Profile 1")
	SQP.SetToolTip(SQP_PanelProfile1ClearButton, "Clear Profile 1")
	SQP.SetToolTip(SQP_PanelProfile2SetButton, "Set Profile 2")
	SQP.SetToolTip(SQP_PanelProfile2ClearButton, "Clear Profile 2")
	SQP.SetToolTip(SQP_PanelProfile3SetButton, "Set Profile 3")
	SQP.SetToolTip(SQP_PanelProfile3ClearButton, "Clear Profile 3")
	SQP.SetToolTip(SQP_PanelProfile4SetButton, "Set Profile 4")
	SQP.SetToolTip(SQP_PanelProfile4ClearButton, "Clear Profile 4")
	SQP.SetToolTip(SQP_PanelProfile5SetButton, "Set Profile 5")
	SQP.SetToolTip(SQP_PanelProfile5ClearButton, "Clear Profile 5")
end

function SQP.Initialize()
	SQP.Character.SavedVars = ZO_SavedVars:NewCharacterIdSettings("SQPCharVars", SQP.Character.varsVersion, nil, SQP.Character.Defaults, nil)

	ZO_CreateStringId("SI_BINDING_NAME_SQP_LOAD_PROFILE_1_HOTKEY", "Profile 1")
	ZO_CreateStringId("SI_BINDING_NAME_SQP_LOAD_PROFILE_2_HOTKEY", "Profile 2")
	ZO_CreateStringId("SI_BINDING_NAME_SQP_LOAD_PROFILE_3_HOTKEY", "Profile 3")
	ZO_CreateStringId("SI_BINDING_NAME_SQP_LOAD_PROFILE_4_HOTKEY", "Profile 4")
	ZO_CreateStringId("SI_BINDING_NAME_SQP_LOAD_PROFILE_5_HOTKEY", "Profile 5")
	ZO_CreateStringId("SI_BINDING_NAME_SQP_SELECT_QUICKSLOT_1", "Select Quickslot 1")
	ZO_CreateStringId("SI_BINDING_NAME_SQP_SELECT_QUICKSLOT_2", "Select Quickslot 2")
	ZO_CreateStringId("SI_BINDING_NAME_SQP_SELECT_QUICKSLOT_3", "Select Quickslot 3")
	ZO_CreateStringId("SI_BINDING_NAME_SQP_SELECT_QUICKSLOT_4", "Select Quickslot 4")
	ZO_CreateStringId("SI_BINDING_NAME_SQP_SELECT_QUICKSLOT_5", "Select Quickslot 5")
	ZO_CreateStringId("SI_BINDING_NAME_SQP_SELECT_QUICKSLOT_6", "Select Quickslot 6")
	ZO_CreateStringId("SI_BINDING_NAME_SQP_SELECT_QUICKSLOT_7", "Select Quickslot 7")
	ZO_CreateStringId("SI_BINDING_NAME_SQP_SELECT_QUICKSLOT_8", "Select Quickslot 8")

	QUICKSLOT_FRAGMENT:RegisterCallback("StateChange",  function(oldState, newState)
		if newState == SCENE_FRAGMENT_SHOWN then
			SQP_Panel:SetHidden(false)
		elseif newState == SCENE_FRAGMENT_HIDING then
			SQP_Panel:SetHidden(true)
		end
	end)

	SQP.RestorePanel()
	SQP.InitDropDownList()
	SQP.TooltipInit()

	EVENT_MANAGER:UnregisterForEvent(SQP.addonName, EVENT_ADD_ON_LOADED)
end

function SQP_ON_MOVE_STOP()
	SQP.OnMoveStop()
end

function SQP_NEW_BUTTON()
	SQP.NewButtonPressed()
end

function SQP_NEW_PROFILE()
	SQP.New(string.lower(SQP_PanelEditBoxControl:GetText()))
end

function SQP_ESCAPE_PRESSED()
	SQP.EscapePressed()
end

function SQP_CLEAR_BUTTON()
	SQP.Clear(SQP.Dropdown:GetSelectedItem())
end

function SQP_SAVE_BUTTON()
	SQP.Save(SQP.Dropdown:GetSelectedItem())
end

function SQP_LOAD_BUTTON()
	SQP.Load(SQP.Dropdown:GetSelectedItem())
end

function SQP_OK_BUTTON()
	SQP.New(string.lower(SQP_PanelEditBoxControl:GetText()))
end

function SQP_CANCEL_BUTTON()
	SQP.EscapePressed()
end

function SQP_LOAD_PROFILE_1_HOTKEY()
	if SQP.Character.SavedVars.profile1 ~= nil then
		SQP.Load(SQP.Character.SavedVars.profile1)
	end
end

function SQP_LOAD_PROFILE_2_HOTKEY()
	if SQP.Character.SavedVars.profile2 ~= nil then
		SQP.Load(SQP.Character.SavedVars.profile2)
	end
end

function SQP_LOAD_PROFILE_3_HOTKEY()
	if SQP.Character.SavedVars.profile3 ~= nil then
		SQP.Load(SQP.Character.SavedVars.profile3)
	end
end

function SQP_LOAD_PROFILE_4_HOTKEY()
	if SQP.Character.SavedVars.profile4 ~= nil then
		SQP.Load(SQP.Character.SavedVars.profile4)
	end
end

function SQP_LOAD_PROFILE_5_HOTKEY()
	if SQP.Character.SavedVars.profile5 ~= nil then
		SQP.Load(SQP.Character.SavedVars.profile5)
	end
end

function SQP_SELECT_QUICKSLOT(slot)
	SQP.SelectQuickslot(slot)
end

function SQP_PROFILE_1_SET()
	SQP.Character.SavedVars.profile1 = SQP.Dropdown:GetSelectedItem()
	SQP_PanelProfile1Label:SetText("1: " .. SQP.Character.SavedVars.profile1)
end

function SQP_PROFILE_1_CLEAR()
	SQP.Character.SavedVars.profile1 = nil
	SQP_PanelProfile1Label:SetText("1: Not Set")
end

function SQP_PROFILE_2_SET()
	SQP.Character.SavedVars.profile2 = SQP.Dropdown:GetSelectedItem()
	SQP_PanelProfile2Label:SetText("2: " .. SQP.Character.SavedVars.profile2)
end

function SQP_PROFILE_2_CLEAR()
	SQP.Character.SavedVars.profile2 = nil
	SQP_PanelProfile2Label:SetText("2: Not Set")
end

function SQP_PROFILE_3_SET()
	SQP.Character.SavedVars.profile3 = SQP.Dropdown:GetSelectedItem()
	SQP_PanelProfile3Label:SetText("3: " .. SQP.Character.SavedVars.profile3)
end

function SQP_PROFILE_3_CLEAR()
	SQP.Character.SavedVars.profile3 = nil
	SQP_PanelProfile3Label:SetText("3: Not Set")
end

function SQP_PROFILE_4_SET()
	SQP.Character.SavedVars.profile4 = SQP.Dropdown:GetSelectedItem()
	SQP_PanelProfile4Label:SetText("4: " .. SQP.Character.SavedVars.profile4)
end

function SQP_PROFILE_4_CLEAR()
	SQP.Character.SavedVars.profile4 = nil
	SQP_PanelProfile4Label:SetText("4: Not Set")
end

function SQP_PROFILE_5_SET()
	SQP.Character.SavedVars.profile5 = SQP.Dropdown:GetSelectedItem()
	SQP_PanelProfile5Label:SetText("5: " .. SQP.Character.SavedVars.profile5)
end

function SQP_PROFILE_5_CLEAR()
	SQP.Character.SavedVars.profile5 = nil
	SQP_PanelProfile5Label:SetText("5: Not Set")
end

SLASH_COMMANDS["/sqp"] = SQP.CommandParse

EVENT_MANAGER:RegisterForEvent(SQP.addonName, EVENT_ADD_ON_LOADED, SQP.Initialize)
FarmManager = {
    version = "1.0.0.0",
    name = "FarmManager",
    displayName = "Farm Manager",
    variableVersion = 2,
    classes = {}
}

local DIALOGS_RESET_CONFIRM = "FarmManager_Dialogs_ResetConfirm"

local FarmManagerKeybindButtonGroup =
{
	alignment = KEYBIND_STRIP_ALIGN_CENTER,
	{
		name = "Transfer Farmed Items",
		keybind = "UI_SHORTCUT_QUATERNARY",
		callback = function() FarmManager.StartTransfer() end
	}
}

function FarmManager.OnAddOnLoaded(_, addonName)
    if addonName ~= FarmManager.name then return end
    EVENT_MANAGER:UnregisterForEvent(FarmManager.name, EVENT_ADD_ON_LOADED)
    FarmManager.Init()
end

function FarmManager.Init()
	FarmManager.settings = FarmManager.classes.FmSettings:New()
	FarmManager.window = FarmManager.classes.FarmManagerMainWindow:New()
	FarmManager.farmer = FmFarmer:New(GetUnitName("player"))
end

function FarmManager.IsAtBank(_, newState)
	if newState == SCENE_SHOWING then
		KEYBIND_STRIP:AddKeybindButtonGroup(FarmManagerKeybindButtonGroup)
		FarmManager.farmer.bagId = GetBankingBag()
	elseif newState == SCENE_HIDDEN then
		KEYBIND_STRIP:RemoveKeybindButtonGroup(FarmManagerKeybindButtonGroup)
		FarmManager.farmer.bagId = BAG_DELETE
	end
end

function FarmManager.IsAtGuildBank(_, newState)
	if newState == SCENE_SHOWING then
		KEYBIND_STRIP:AddKeybindButtonGroup(FarmManagerKeybindButtonGroup)
		FarmManager.farmer.bagId = BAG_GUILDBANK
	elseif newState == SCENE_HIDDEN then
		KEYBIND_STRIP:RemoveKeybindButtonGroup(FarmManagerKeybindButtonGroup)
		FarmManager.farmer.bagId = BAG_DELETE
	end
end

function FarmManager.Show()
	FarmManager.window:Show()
end

function FarmManager.Hide()
	FarmManager.window:Hide()
end

function FarmManager.Start()
	EVENT_MANAGER:RegisterForEvent(FarmManager.name, EVENT_LOOT_RECEIVED, FarmManager.OnLootReceived)
	d("Farm Manager starting")
end

function FarmManager.Stop()
	EVENT_MANAGER:UnregisterForEvent(FarmManager.name, EVENT_LOOT_RECEIVED)
	d("Farm Manager stopping")
end

function FarmManager.StartTransfer()
	FarmManager.farmer:DepositItemsInBank()
end

function FarmManager.StartBackpackTransfer()
	FarmManager.farmer:MoveItemsToBackpack()
end

function FarmManager.OnLootReceived(_, _, itemLink, quantity, _, _, isMe)
	if not isMe then return end
	if FarmManager.settings:ShouldInclude(itemLink) == 0 then return end
	FarmManager.farmer:Farm(itemLink, quantity)
end

function FarmManager.Reset()
	ZO_Dialogs_ShowDialog(DIALOGS_RESET_CONFIRM)
end

FarmManager.commands = {
	["show"] = FarmManager.Show,
	["hide"] = FarmManager.Hide,
	["start"] = FarmManager.Start,
	["stop"] = FarmManager.Stop,
	["reset"] = FarmManager.Reset
}

SLASH_COMMANDS["/farm"] = function(arg)
	local handle
	local actualArgs = ""
	local argIterator = arg:gmatch("%S+")
	local count = 0
	local func
	for s in argIterator do
		if not handle then
			handle = s
		else
			count = count + 1
			if count > 1 then actualArgs = actualArgs.." " end
			actualArgs = actualArgs..s
		end
	end
	if handle then
		func = FarmManager.commands[handle:lower()]
		if func == nil then func = FarmManager.commands["show"] end
	else
		func = FarmManager.commands["show"]
	end
	func(actualArgs)
end

ESO_Dialogs[DIALOGS_RESET_CONFIRM] = {
	title = {
		text = "Reset?",
	},
	mainText = {
		text = "Are you sure you want to reset all Farm data? This action cannot be undone.",
	},
	buttons = {
		[1] = {
			text = SI_DIALOG_CONFIRM,
			callback = function(...)
				FarmManager.farmer:Reset()
				FarmManager.window:Reset()
			end,
		},
		[2] = {
			text = SI_DIALOG_CANCEL,
		}
	}
}

EVENT_MANAGER:RegisterForEvent(FarmManager.name, EVENT_ADD_ON_LOADED, FarmManager.OnAddOnLoaded)
--[[BANK_FRAGMENT:RegisterCallback("StateChange", FarmManager.IsAtBank)
GUILD_BANK_FRAGMENT:RegisterCallback("StateChange", FarmManager.IsAtGuildBank)
BACKPACK_BANK_LAYOUT_FRAGMENT:RegisterCallback("StateChange", FarmManager.IsAtBank)
BACKPACK_GUILD_BANK_LAYOUT_FRAGMENT:RegisterCallback("StateChange", FarmManager.IsAtGuildBank)]]--
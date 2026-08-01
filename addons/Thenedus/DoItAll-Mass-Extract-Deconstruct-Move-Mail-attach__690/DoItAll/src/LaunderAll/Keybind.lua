DoItAll = DoItAll or {}

local keystripDef = {
	{
		name = "Fence/Launder All",
		keybind = "SC_BANK_ALL",    
		callback = function() DoItAll.FenceOrLaunderAll() end,
		alignment = KEYBIND_STRIP_ALIGN_LEFT,
	}
} 

local function FenceOpened()
	KEYBIND_STRIP:AddKeybindButtonGroup(keystripDef)
	--Add the keystrip def to the global vars so we can reach it from everywhere
	DoItAll.currentKeyStripDef = keystripDef
end

local function FenceClosed()
	--Is not fast enough if one directly opens the mail panel
	--So remove the keybind as the mail scene get's loaded!
	KEYBIND_STRIP:RemoveKeybindButtonGroup(keystripDef)
    --Remove the current keystrip def from the global vars
    DoItAll.currentKeyStripDef = nil
end

EVENT_MANAGER:RegisterForEvent("DoItAllBank", EVENT_OPEN_FENCE, FenceOpened)
EVENT_MANAGER:RegisterForEvent("DoItAllBank", EVENT_CLOSE_STORE, FenceClosed)

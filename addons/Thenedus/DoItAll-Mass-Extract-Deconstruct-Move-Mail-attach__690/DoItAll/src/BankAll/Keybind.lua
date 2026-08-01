DoItAll = DoItAll or {}

local keystripDef = {
    {
        name = "Bank All",
        keybind = "SC_BANK_ALL",
        callback = function() DoItAll.BankAll() end,
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
    }
}

--[[
	local function BankOpened()
		KEYBIND_STRIP:RemoveKeybindButtonGroup(keystripDef)
		KEYBIND_STRIP:AddKeybindButtonGroup(keystripDef)
	end

	local function BankClosed()
		KEYBIND_STRIP:RemoveKeybindButtonGroup(keystripDef)
	end

	EVENT_MANAGER:RegisterForEvent("DoItAllBank", EVENT_OPEN_BANK, BankOpened)
	EVENT_MANAGER:RegisterForEvent("DoItAllBank", EVENT_CLOSE_BANK, BankClosed)
]]

local bankScene = SCENE_MANAGER:GetScene("bank")
bankScene:RegisterCallback("StateChange",  function(oldState, newState)
    if(newState == SCENE_SHOWING) then
        --Remove the old keybind if there is still one activated
        if DoItAll.currentKeyStripDef ~= nil then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(DoItAll.currentKeyStripDef)
        end
        KEYBIND_STRIP:AddKeybindButtonGroup(keystripDef)
    elseif(newState == SCENE_HIDDEN) then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(keystripDef)
        --Add the keystrip def to the global vars so we can reach it from everywhere
        DoItAll.currentKeyStripDef = nil
    end
end)

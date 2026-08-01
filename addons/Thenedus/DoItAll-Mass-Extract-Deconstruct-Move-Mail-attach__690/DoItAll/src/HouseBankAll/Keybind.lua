DoItAll = DoItAll or {}

local keystripDef = {
    {
        name = "Transfer All",
        keybind = "SC_BANK_ALL",
        callback = function() DoItAll.HouseBankAll() end,
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
    }
}

local houseBankScene = SCENE_MANAGER:GetScene("houseBank")
houseBankScene:RegisterCallback("StateChange",  function(oldState, newState)
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


MagBankSettings = {
    name = "MagBankSettings", -- Matches folder and Manifest file names.
    version = "1.0.1", -- A nuisance to match to the Manifest.
    author = "@Magnum1997",
    menuName = "Mag Bank Settings", -- A UNIQUE identifier for menu object.
}

function MagBankSettings.OnAddOnLoaded(event, addonName)
    -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
    if addonName == MagBankSettings.name then
        EVENT_MANAGER:UnregisterForEvent("MagBankSettings", EVENT_ADD_ON_LOADED)
    end
    MagBankSettings:Initialize()
end

function MagBankSettings:Initialize()
    local bankScene = SCENE_MANAGER:GetScene("bank")
    bankScene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWN then
            MagBankSettings.selectDeposit()
        end
    end)
end

function MagBankSettings.selectDeposit()
    --d(IsHouseBankBag(GetBankingBag())) -- TODO Investigate why not callback when house bank opened
    --if (IsHouseBankBag(GetBankingBag())) then
    --    ZO_MenuBar_SelectDescriptor(ZO_HouseBankMenuBar, SI_BANK_DEPOSIT)
    --else
    ZO_MenuBar_SelectDescriptor(ZO_PlayerBankMenuBar, SI_BANK_DEPOSIT)
    --end
end

-- When any addon is loaded, but before UI (Chat) is loaded.
EVENT_MANAGER:RegisterForEvent(MagBankSettings.name, EVENT_ADD_ON_LOADED, MagBankSettings.OnAddOnLoaded)
--EVENT_MANAGER:RegisterForEvent(MagBankSettings.name, EVENT_BANK_OPEN, MagBankSettings.selectDeposit)

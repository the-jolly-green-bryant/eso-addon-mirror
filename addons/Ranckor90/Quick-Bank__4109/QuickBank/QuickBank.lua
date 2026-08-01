QuickBank = {}
QuickBank.name = "QuickBank"
QuickBank.savedVars = nil

local function GetDefaults()
    return {
        depositGold = true,
        depositAP = true,
        depositWrits = true,
        depositTelVar = true,
        panelPos = { left = 100, top = 100 },
    }
end

local function MigrateDefaultProfileToWorldForCurrentCharacter(savedVarsTableName, worldName)
    local svRoot = _G[savedVarsTableName]
    if type(svRoot) ~= "table" then return end

    local displayName = GetDisplayName()
    local characterName = GetUnitName("player")

    local defaultBucket = svRoot["Default"]
    if type(defaultBucket) ~= "table" then return end
    if type(defaultBucket[displayName]) ~= "table" then return end
    if type(defaultBucket[displayName][characterName]) ~= "table" then return end

    svRoot[worldName] = svRoot[worldName] or {}
    svRoot[worldName][displayName] = svRoot[worldName][displayName] or {}

    -- If the world bucket for this character doesn't exist yet, move it over.
    if type(svRoot[worldName][displayName][characterName]) ~= "table" then
        svRoot[worldName][displayName][characterName] = defaultBucket[displayName][characterName]
        defaultBucket[displayName][characterName] = nil
    end
end

function QuickBank.OnAddOnLoaded(_, addonName)
    if addonName ~= QuickBank.name then return end

    local worldName = GetWorldName()
    local defaults = GetDefaults()

    -- Migrate ONLY the current character from the old "Default" bucket into the correct world bucket.
    -- (Other characters will migrate when you log into them on their respective server.)
    MigrateDefaultProfileToWorldForCurrentCharacter("QuickBankSavedVars", worldName)

    QuickBank.savedVars = ZO_SavedVars:New("QuickBankSavedVars", 1, nil, defaults, worldName)

    QuickBankSettings.Init()
    QuickBankUI.CreatePanel()

    SCENE_MANAGER:GetScene("bank"):RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWING then
            QuickBankUI.OnBankOpen()
        elseif newState == SCENE_HIDDEN and QuickBankUI.panel then
            QuickBankUI.panel:SetHidden(true)
        end
    end)

    EVENT_MANAGER:UnregisterForEvent(QuickBank.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(QuickBank.name, EVENT_ADD_ON_LOADED, QuickBank.OnAddOnLoaded)
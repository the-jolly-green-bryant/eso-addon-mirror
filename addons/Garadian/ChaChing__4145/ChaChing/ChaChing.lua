local previousGold = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)

local function IsFenceSceneActive()
    return SCENE_MANAGER:IsShowing("store") or SCENE_MANAGER:IsShowing("fence_keyboard")
end

local function OnStoreOpened()
    previousGold = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
end

local function OnGoldChange()
    if IsFenceSceneActive() then
        local currentGold = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
        if currentGold > previousGold then
            PlaySound(SOUNDS.ITEM_MONEY_CHANGED)
        end
        previousGold = currentGold
    end
end

EVENT_MANAGER:RegisterForEvent("ChaChing", EVENT_OPEN_STORE, OnStoreOpened)
EVENT_MANAGER:RegisterForEvent("ChaChing", EVENT_MONEY_UPDATE, OnGoldChange)

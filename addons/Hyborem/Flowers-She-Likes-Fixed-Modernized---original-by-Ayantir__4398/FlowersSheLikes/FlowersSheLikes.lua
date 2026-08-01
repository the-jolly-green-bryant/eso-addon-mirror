FlowersSheLikes = FlowersSheLikes or {}
local FSL = FlowersSheLikes
FSL.name = "FlowersSheLikes"

local FlowerList = {
    "Blessed Thistle", "Blue Entoloma", "Bugloss", "Columbine", "Corn Flower",
    "Dragonthorn", "Emetic Russula", "Imp Stool", "Lady's Smock", "Luminous Russula",
    "Mountain Flower", "Namira's Rot", "Nightshade", "Nirnroot", "Stinkhorn",
    "Violet Coprinus", "Water Hyacinth", "White Cap", "Wormwood", "Crimson Nirnroot"
}

-- FUNKCJA WYMUSZAJĄCA KOLOR (Zabezpieczona przed nil)
local function ForceColor()
    local _, name = GetGameCameraInteractableActionInfo()
    if not name or name == "" then return end
    
    local clean = zo_strformat("<<1>>", name):lower()
    local L = FSL[GetCVar("Language.2")] or FSL["en"]
    
    for i, flower in ipairs(FlowerList) do
        if clean == flower:lower() then
            -- Pobieramy kolor z nowej, unikalnej bazy
            local choice = (FSL.vars.selections or {})[i] or L.l3
            local idx = (choice == L.l1 and 1) or (choice == L.l2 and 2) or 3
            local c = FSL.vars.colors[idx]
            
            if c then
                ZO_ReticleContainerInteractContext:SetColor(c.r, c.g, c.b, c.a or 1)
                -- Ostatnia linia obrony: wymuszamy kolor bezpośrednio na Labelu tekstu
                local label = (SHARED_INTERACTION and SHARED_INTERACTION.interactPrompt.nameLabel)
                if label then label:SetColor(c.r, c.g, c.b, c.a or 1) end
            end
            return
        end
    end
end

local function OnLoaded(event, addonName)
    if addonName ~= FSL.name then return end
    EVENT_MANAGER:UnregisterForEvent(FSL.name, EVENT_ADD_ON_LOADED)

    -- Zmieniamy nazwę SavedVars na unikalną, by uniknąć konfliktów
    FSL.vars = LibSavedVars:NewAccountWide("FSL_Unique_SV_2026", "Account", {
        colors = {[1]={r=0,g=1,b=0,a=1}, [2]={r=0,g=0.5,b=1,a=1}, [3]={r=1,g=1,b=1,a=1}},
        selections = {}
    })

    if FSL.CreateSettingsMenu then FSL.CreateSettingsMenu() end
    
    -- PRIORYTET: Rejestrujemy funkcję, która nadpisuje kolory w każdej klatce interakcji
    SecurePostHook(ZO_Reticle, "TryHandlingInteraction", function(_, possible)
        if possible then 
            ForceColor() 
            -- Dodatkowe zabezpieczenie: jeśli inny addon nadpisze kolor milisekundę później, my go poprawimy
            zo_callLater(ForceColor, 10)
        else 
            ZO_ReticleContainerInteractContext:SetColor(1,1,1,1) 
        end
    end)
end

EVENT_MANAGER:RegisterForEvent(FSL.name, EVENT_ADD_ON_LOADED, OnLoaded)
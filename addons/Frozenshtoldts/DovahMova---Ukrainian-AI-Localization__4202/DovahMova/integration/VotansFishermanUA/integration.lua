local addonId = "VotansFisherman"
local integration = {}
integration.name = "VotansFishermanUA"

function integration:Initialize()
    if GetCVar("language.2") ~= "ua" then
        return
    end

    if not VOTANS_FISHERMAN then
        EVENT_MANAGER:RegisterForEvent(self.name .. "_WaitForAddon", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
            if addonName == addonId then
                EVENT_MANAGER:UnregisterForEvent(self.name .. "_WaitForAddon", EVENT_ADD_ON_LOADED)
                self:ApplyFix()
            end
        end)
        return
    end

    self:ApplyFix()
end

function integration:ApplyFix()
    -- Load translations via manifest (ua.lua)
    
    if VOTANS_FISHERMAN and VOTANS_FISHERMAN.InteractToLootType and VOTANS_FISHERMAN.ActionToLootType then
            local data = VOTANS_FISHERMAN
            
            -- Explicitly define the strings we want to match
            -- These should match the interaction prompt in the game (case-insensitive)
            -- We use stems/roots because the game uses declensions (e.g. "в річці")
            local interactStrings = {
                -- Foul (1)
                { id = 1, str = "стічн" }, -- стічна, стічній
                { id = 1, str = "бруд" },  -- брудна, брудній
                { id = 1, str = "масл" },  -- масляниста
                { id = 1, str = "смерд" }, -- смердюча
                { id = 1, str = "тухл" },  -- тухла
                { id = 1, str = "гниль" }, -- гниль
                
                -- River (2)
                { id = 2, str = "річк" }, -- річка, річки
                { id = 2, str = "річц" }, -- річці (locative)
                { id = 2, str = "прот" }, -- проточна
                
                -- Lake (3)
                { id = 3, str = "озер" }, -- озеро, озері, озерна
                
                -- Ocean (4)
                { id = 4, str = "морськ" }, -- морська
                { id = 4, str = "солон" },  -- солона
                { id = 4, str = "мор" },    -- морі (locative)
                { id = 4, str = "міст" }    -- містична
            }
            
            local actionStrings = {
                [1] = "Стічна риба",
                [2] = "Річкова риба",
                [3] = "Озерна риба",
                [4] = "Морська риба"
            }

            -- Update InteractToLootType
            for _, info in ipairs(interactStrings) do
                -- VotansFisherman uses zo_strformat("<<z:1>>", ...) on the game text, which lowercases it.
                -- It then checks if that text contains our key.
                -- So we just add the lowercase stem as the key.
                local key = info.str -- already lowercase stems
                data.InteractToLootType[key] = info.id
            end
            
            -- Update ActionToLootType
            for typeId, str in pairs(actionStrings) do
                data.ActionToLootType[str] = typeId
            end
            
            -- Refresh pins
            if data.RefreshPins then
                data:RefreshPins()
            end
    end
end

-- Debug command
SLASH_COMMANDS["/votanua"] = function()
    local action, interactableName, _, _, additionalInfo = GetGameCameraInteractableActionInfo()
    d("Action: " .. tostring(action))
    d("Interactable Name: " .. tostring(interactableName))
    
    if VOTANS_FISHERMAN then
        local typeText = ZO_CachedStrFormat("<<z:1>>", interactableName)
        d("Formatted Name: " .. tostring(typeText))
        
        local found = false
        for text, type in pairs(VOTANS_FISHERMAN.InteractToLootType) do
            if zo_plainstrfind(typeText, text) then
                d("MATCH FOUND: '" .. text .. "' -> Type " .. tostring(type))
                found = true
            end
        end
        if not found then
            d("NO MATCH FOUND in InteractToLootType")
        end
    end
end

if DovahMova then
    DovahMova:RegisterIntegration(addonId, integration)
end

integration:Initialize()

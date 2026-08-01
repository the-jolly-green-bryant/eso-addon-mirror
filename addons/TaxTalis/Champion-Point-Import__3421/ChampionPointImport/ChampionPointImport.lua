-----------------------------------------------------------------------------------
-- Addon Name: Champion Point Import
-- Creator: TaxTalis
-- Addon Ideal: Import Champion Points from text
-- Addon Creation Date: 2022-06-20
--
-- File Name: ChampionPointImport.lua
-- File Description: This file contains the main definition
-- Load Order Requirements: First
--
-----------------------------------------------------------------------------------
local startTime = GetGameTimeMilliseconds()
ChampionPointImport = {}
local CPI = ChampionPointImport
local classes = {}
CPI.classes = classes

-- MAJOR.MINOR.PATCH
-- MAJOR version : user will use settings and functionality if not configured from scratch once more
-- MINOR version : added functionality, changes are fully backwards compatible
-- PATCH version : bugfixes, tweaks and extensions, changes are fully backwards compatible

CPI.name = "ChampionPointImport"
CPI.title = "Champion Point Import"
CPI.author = "TaxTalis"
CPI.addonVersion = "0.02"

-- debugFlag
CPI.debugFlag = GetDisplayName() == "@TaxTalis"

function CPI.Import(data)
    if (data == nil) then
        error("Data isn't ready for import yet")
    end
    return data
end

local init = {}
function CPI.addInitialize(fn)
    init[#init + 1] = fn
end
EVENT_MANAGER:RegisterForEvent(CPI.name, EVENT_ADD_ON_LOADED, function(event, addonName)
    if addonName == CPI.name then
        for _, fn in pairs(init) do
            fn()
        end
        init = nil
        CPI.addInitialize = nil
        local initializationTime = GetGameTimeMilliseconds() - startTime
        if (CPI.debugFlag) then
            d("Champion Point Import initialized in " .. tostring(initializationTime) .. "ms")
        end
    end
end)

local function initialize()
end

CPI.addInitialize(initialize)

-------------------------------------------
--- DEBUG / TESTING -----------------------
-------------------------------------------
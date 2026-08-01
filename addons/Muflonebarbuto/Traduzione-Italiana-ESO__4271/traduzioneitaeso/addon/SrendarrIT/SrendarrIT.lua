-- ===========================================================================================
-- TraduzioneItaESO - Integrazione Srendarr
-- File: addon/SrendarrIT/SrendarrIT.lua
-- Pulisce i marker ^Imd (e simili) dai nomi delle abilità mostrati da Srendarr
-- ===========================================================================================

-- Hook GetAbilityName: Srendarr lo usa per ottenere i nomi delle aure
if not _G.__TradIta_AbilityNameHooked then
    _G.__TradIta_AbilityNameHooked = true

    local _origGetAbilityName = GetAbilityName
    GetAbilityName = function(abilityId)
        local name = _origGetAbilityName(abilityId)
        if not name or not name:find("%^[iI]") then return name end
        local pm = _G.ProcessMarkers
        if type(pm) ~= "function" then
            return name:gsub("%^[iI][%a%d_%-]+", "")
        end
        local ok, cleaned = pcall(pm, name)
        return (ok and cleaned and cleaned ~= "") and cleaned or name:gsub("%^[iI][%a%d_%-]+", "")
    end

    local _origZoStrformat = zo_strformat
    zo_strformat = function(fmt, ...)
        local result = _origZoStrformat(fmt, ...)
        -- Uscita immediata se non ci sono marker (caso >99% delle chiamate)
        if type(result) ~= "string" or (not result:find("%^i", 1, true) and not result:find("%^I", 1, true)) then
            return result
        end
        local pm = _G.ProcessMarkers
        if type(pm) ~= "function" then
            return result:gsub("%^[iI][%a%d_%-]+", "")
        end
        local ok, cleaned = pcall(pm, result)
        return (ok and cleaned and cleaned ~= "") and cleaned or result:gsub("%^[iI][%a%d_%-]+", "")
    end
end
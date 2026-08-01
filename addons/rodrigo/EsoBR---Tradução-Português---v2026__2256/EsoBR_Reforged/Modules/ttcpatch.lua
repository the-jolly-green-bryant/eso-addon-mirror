-- Wrap TamrielTradeCentre.Init at file-load time so the wrap is in place
-- before TTC's EVENT_ADD_ON_LOADED fires and calls Init.
-- TTC is listed in OptionalDependsOn, so its files load before EsoBR's.
if TamrielTradeCentre and GetCVar("language.2") == "br" then
    local _origInit = TamrielTradeCentre.Init
    TamrielTradeCentre.Init = function(self)
        local origGetCVar = _G.GetCVar
        _G.GetCVar = function(key, ...)
            if key == "language.2" then return "en" end
            return origGetCVar(key, ...)
        end
        local result = _origInit(self)
        _G.GetCVar = origGetCVar
        return result
    end
end

Reforged.Modules.register({
    id      = "ttcpatch",
    enabled = function()
        return GetCVar("language.2") == "br"
            and Reforged.IsAddonRunning("TamrielTradeCentre")
    end,
    activate = function()
        local rsd = Reforged.Settings.Data

        -- Patch GetLangCode so TTC uploads are tagged as English.
        local origGetLangCode = TamrielTradeCentre.GetLangCode
        TamrielTradeCentre.GetLangCode = function(self)
            return origGetLangCode(self) or "en-US"
        end

        -- If TTC's Init() ran before our file-load-time wrap was in place
        -- (i.e. events fired interleaved with file loading), re-run it now.
        -- TamrielTradeCentre.Data is only set when Init completes successfully.
        if not TamrielTradeCentre.Data then
            TamrielTradeCentre:Init()
        end

        -- Look up the English name for an item link from EsoBR's dump database.
        local function getItemNameEN(itemLink)
            if not rsd.Items then return nil end
            local itemId = tonumber((select(4, ZO_LinkHandler_ParseLink(itemLink))))
            if not itemId then return nil end
            return rsd.Items[itemId] or rsd.Items[tostring(itemId)]
        end

        -- Wrap TamrielTradeCentre_ItemInfo.New to inject English name and item ID.
        -- itemInfo.Name must be the EN name so NameSpecializedItemTypeToItemID can
        -- find the TTC internal ID in the EN lookup table (ItemLookUpTable_br.lua).
        if TamrielTradeCentre_ItemInfo then
            local origNew = TamrielTradeCentre_ItemInfo.New
            TamrielTradeCentre_ItemInfo.New = function(self, itemLink)
                local itemInfo = origNew(self, itemLink)
                if itemInfo then
                    local enName = getItemNameEN(itemLink)
                    if enName then
                        local _, specializedItemType = GetItemLinkItemType(itemLink)
                        local enFormatted = zo_strformat(SI_TOOLTIP_ITEM_NAME, enName)
                        itemInfo.Name = enFormatted
                        itemInfo.ID = TamrielTradeCentre_ItemInfo:NameSpecializedItemTypeToItemID(enFormatted, specializedItemType)
                    end
                end
                return itemInfo
            end
        end
    end,
})

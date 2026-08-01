Reforged.Modules.register({
    id      = "tradinghouse",
    enabled = function()
        return GetCVar("language.2") == "br"
    end,
    activate = function()
        local rsd = Reforged.Settings.Data

        Reforged.Modules.TradingHouse = Reforged.Modules.TradingHouse or {}

        -- Atalho para o usuário limpar o cache do indexador
        SLASH_COMMANDS["/esobr_clearcache"] = function()
            if rsd.PtToEnIndex then
                rsd.PtToEnIndex = nil
                d("|c44d62c[EsoBR Reforged]|r O cache da busca bilíngue foi apagado! Use /reloadui para forçar a recompilação na próxima tela de carregamento.")
            else
                d("|c44d62c[EsoBR Reforged]|r Nenhum cache encontrado.")
            end
        end

        -----------------------------------------------------------------------
        -- Build a PT→EN reverse index from all available data tables.
        -- MatchTradingHouseItemNames searches the game's INTERNAL item
        -- database which uses ENGLISH names regardless of br.lang.
        -- We need to translate the user's Portuguese search into English.
        -----------------------------------------------------------------------
        local ptToEn = {}

        -- Instantly load known small dictionaries
        local function loadDict(dict)
            for k, v in pairs(dict or {}) do
                if type(v) == "string" then ptToEn[zo_strlower(k)] = v end
            end
        end
        loadDict(rsd.SetsNames)
        loadDict(rsd.Potions)
        loadDict(rsd.Parts)
        loadDict(rsd.Prefixes)
        loadDict(rsd.Affixes)

        function Reforged.Modules.TradingHouse.CheckIndex()
            if not Reforged.Settings.TradingHouseSearch then return end

            if rsd.Items then
                -- Use a persistent cache tied to the game's API version.
                if rsd.PtToEnIndex and rsd.PtToEnVersion == rsd.ApiVersion then
                    for k, v in pairs(rsd.PtToEnIndex) do
                        ptToEn[k] = v
                    end
                    return
                end

                local itemKeys = {}
                for k in pairs(rsd.Items) do
                    itemKeys[#itemKeys + 1] = k
                end

                local totalItems = #itemKeys
                local currentIndex = 1

                local function startIndexing()
                    rsd.PtToEnIndex = {}
                    rsd.PtToEnVersion = rsd.ApiVersion

                    d(string.format("|c44d62c[ESOBR Reforged]|r Iniciando compilação do índice bilíngue (%d itens). Esse processo roda lentamente em segundo plano e pode levar alguns minutos...", totalItems))
                    
                    local function indexChunk()
                        local endIndex = math.min(currentIndex + 50, totalItems)
                        for i = currentIndex, endIndex do
                            local id = itemKeys[i]
                            local enName = rsd.Items[id]
                            if enName then
                                local link = string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", tostring(id))
                                local ptName = GetItemLinkName(link)
                                if ptName and ptName ~= "" then
                                    local ptKey = zo_strlower(ZO_CachedStrFormat("<<z:1>>", ptName))
                                    local enVal = zo_strlower(ZO_CachedStrFormat("<<z:1>>", enName))
                                    ptToEn[ptKey] = enVal
                                    rsd.PtToEnIndex[ptKey] = enVal
                                end
                            end
                        end
                        
                        currentIndex = endIndex + 1
                        if currentIndex <= totalItems then
                            zo_callLater(indexChunk, 50)
                        else
                            d("|c44d62c[ESOBR Reforged]|r Índice de busca bilíngue compilado (" .. totalItems .. " itens). IMPORTANTE: feche e abra o jogo novamente para que a busca bilíngue entre em vigor.")
                            ZO_Dialogs_ShowDialog("EsoBRReforgedRestartDialog")
                        end
                    end
                    indexChunk()
                end

                local dialogName = "EsoBRReforgedIndexDialog"
                if not ESO_Dialogs[dialogName] then
                    ESO_Dialogs[dialogName] = {
                        canQueue     = true,
                        title        = { text = "ESOBR Reforged - Otimização Bilíngue" },
                        mainText     = { text = "Para que a busca nos Mercadores funcione com todos os milhares de itens do jogo em português, precisamos construir um índice local.\n\nEsse processo é feito apenas uma vez (ou após grandes atualizações do jogo). Ele rodará de forma invisível no fundo e pode demorar alguns minutos.\n\nDeseja iniciar a compilação agora?\n(Se recusar, você poderá ativá-la mais tarde no menu: ESC → Opções → Addons → EsoBR Reforged → Busca Bilíngue Universal)." },
                        buttons = {
                            {
                                text       = SI_DIALOG_ACCEPT,
                                callback   = startIndexing,
                            },
                            {
                                text       = SI_DIALOG_DECLINE,
                                callback   = function() 
                                    d("|c44d62c[EsoBR Reforged]|r Compilação recusada. A busca universal permanecerá desativada.")
                                    Reforged.Settings.TradingHouseSearch = false
                                    if EsoBR_TradingHouse_Checkbox and EsoBR_TradingHouse_Checkbox.UpdateValue then
                                        EsoBR_TradingHouse_Checkbox:UpdateValue(false, false)
                                    end
                                end,
                            },
                        },
                    }
                end
                if not ESO_Dialogs["EsoBRReforgedRestartDialog"] then
                    ESO_Dialogs["EsoBRReforgedRestartDialog"] = {
                        canQueue = true,
                        title    = { text = "EsoBR Reforged - Reinicialização Necessária" },
                        mainText = { text = "O índice bilíngue foi compilado com sucesso!\n\nPara que a busca em português no Guild Trader funcione corretamente, você precisa fechar e abrir o jogo novamente.\n\nAs alterações só entrarão em vigor após reiniciar o ESO." },
                        buttons  = {
                            {
                                text = SI_DIALOG_ACCEPT,
                            },
                        },
                    }
                end

                ZO_Dialogs_ShowDialog(dialogName)
            end
        end

        -- Call check on player activation
        EVENT_MANAGER:RegisterForEvent("EsoBR_TH_IndexPrompt", EVENT_PLAYER_ACTIVATED, function()
            EVENT_MANAGER:UnregisterForEvent("EsoBR_TH_IndexPrompt", EVENT_PLAYER_ACTIVATED)
            Reforged.Modules.TradingHouse.CheckIndex()
        end)

        -----------------------------------------------------------------------
        -- findEnEquivalent(searchText)
        --
        -- Given a Portuguese search term, find the English equivalent so
        -- MatchTradingHouseItemNames can match against the internal EN database.
        -- Returns nil if no translation found (EN text passes through as-is).
        -----------------------------------------------------------------------
        local function findEnEquivalent(searchText)
            local lower = zo_strlower(searchText)

            -- 1. Exact match
            if ptToEn[lower] then return ptToEn[lower] end

            -- 2. Partial match — prefer shortest PT name containing the search term.
            -- Shorter matches (e.g. set names like "ladrão sangrento") yield cleaner
            -- single-word EN equivalents ("Gorethief") vs full item names whose
            -- longest EN word may be an unrelated term ("restoration").
            local bestEn, bestLen = nil, math.huge
            for ptName, enName in pairs(ptToEn) do
                if #ptName < bestLen and zo_strfind(ptName, lower, 1, true) then
                    bestEn  = enName
                    bestLen = #ptName
                end
            end

            -- If partial match found, extract the longest word to send as search term
            if bestEn then
                local longestWord = ""
                for word in string.gmatch(bestEn, "%a+") do
                    if #word > #longestWord then longestWord = word end
                end
                return longestWord ~= "" and longestWord or bestEn
            end

            return nil
        end

        -----------------------------------------------------------------------
        -- Hook: translate PT search text → EN before the hash lookup.
        -- English text passes through untouched (internal DB is already EN).
        -----------------------------------------------------------------------
        Reforged.Hooks.replace("MatchTradingHouseItemNames", function(original)
            return function(searchText)
                if not Reforged.Settings.TradingHouseSearch
                or not searchText or searchText == ""
                or #searchText < 3 then
                    return original(searchText)
                end

                local enTerm = findEnEquivalent(searchText)
                return original(enTerm or searchText)
            end
        end)
    end,
})

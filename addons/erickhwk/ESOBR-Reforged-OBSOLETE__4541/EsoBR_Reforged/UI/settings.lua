local Settings = Reforged.UI.Settings

local CHOICES     = { "Português", "Bilíngue — PT em destaque", "Bilíngue — EN em destaque", "Inglês" }
local CHOICES_VAL = { "br", "bren", "enbr", "en" }

local CHOICES_SHORT     = { "Português", "Inglês" }
local CHOICES_SHORT_VAL = { "br", "en" }

local PRESET_CHOICES     = { "Português", "Bilíngue — PT em destaque", "Bilíngue — EN em destaque", "Inglês", "Personalizado" }
local PRESET_CHOICES_VAL = { "br", "bren", "enbr", "en", "custom" }

-- All keys that support the full 4-option mode
local DISPLAY_KEYS = {
    "ShowNPC", "ShowLocations", "ShowCraft",
    "ShowItemsNamesTooltip", "ShowItemsEnchantsTooltip",
    "ShowItemsTraitsTooltip", "ShowItemsSetsTooltip",
    "ShowAbilitiesTooltip", "ShowChampionTooltip",
    "ShowCollectionsSetsMenu",
}

local function isStale() return Reforged.DB.isStale() end
local function staleWarning() return isStale() and "Banco de dados desatualizado." or false end

local function dropdown(name, tooltip, getKey, choices, choicesValues)
    return {
        type          = "dropdown",
        name          = name,
        tooltip       = tooltip,
        warning       = staleWarning,
        disabled      = isStale,
        choices       = choices or CHOICES,
        choicesValues = choicesValues or CHOICES_VAL,
        getFunc       = function() return Reforged.Settings[getKey] end,
        setFunc       = function(value)
            Reforged.Settings[getKey] = value
            Reforged.Settings.ModoGlobal = "custom"
        end,
        width         = "full",
    }
end

function Settings.register()
    local LAM = LibAddonMenu2

    local panelData = {
        type                = "panel",
        name                = "ESOBR Reforged",
        displayName         = "|c44d62cE|c77d926s|caadc20o|cdddf1aB|cffe014R|r Reforged",
        author              = "Hawke, MestreFrooke, Fabres",
        version             = Reforged.VERSION,
        slashCommand        = "/esobr",
        registerForRefresh  = true,
		feedback = "https://www.esoui.com/downloads/info2256-EsoBR-TraduoPortugus.html",
        registerForDefaults = true,
        website             = "http://www.universoeso.com.br",
    }

    local addonPanel = LAM:RegisterAddonPanel(panelData.name, panelData)

    local function applyPreset(value)
        if value == "custom" then return end
        for _, key in ipairs(DISPLAY_KEYS) do
            Reforged.Settings[key] = value
        end
        -- ShowAbilitiesMenu only supports br/en
        Reforged.Settings.ShowAbilitiesMenu = (value == "en" or value == "enbr") and "en" or "br"
        CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", addonPanel)
    end

    local opts = {}

    ---------------------------------------------------------------------------
    -- Database
    ---------------------------------------------------------------------------
    table.insert(opts, { type = "header", name = "|cffe014Banco de Dados|r", width = "full" })
    table.insert(opts, {
        type  = "description",
        text  = "Armazena os nomes coletados do cliente do jogo. Atualize sempre que uma nova versão do addon ou da API for lançada.",
        width = "full",
    })
    table.insert(opts, {
        type    = "button",
        name    = "Atualizar Banco de Dados",
        tooltip = "Coleta nomes em PT e EN para alimentar as exibições bilíngues. O processo troca o idioma do cliente temporariamente.",
        func    = function() Reforged.Dump.run() end,
        width   = "half",
    })
    table.insert(opts, {
        type    = "button",
        name    = "Aplicar Mudanças",
        tooltip = "Aplica mudanças pendentes recarregando a interface.",
        func    = function() ReloadUI() end,
        width   = "half",
    })

    ---------------------------------------------------------------------------
    -- Modo Global
    ---------------------------------------------------------------------------
    table.insert(opts, { type = "header", name = "|c44d62cModo de Exibição|r", width = "full" })
    table.insert(opts, {
        type  = "description",
        text  = "Aplica um modo a todas as categorias de uma vez. Escolha |cffe014Personalizado|r para ajustar cada categoria individualmente nas seções abaixo.",
        width = "full",
    })
    table.insert(opts, {
        type          = "dropdown",
        name          = "Modo Global",
        tooltip       = "Define o idioma de exibição para todas as categorias simultaneamente.",
        choices       = PRESET_CHOICES,
        choicesValues = PRESET_CHOICES_VAL,
        getFunc       = function() return Reforged.Settings.ModoGlobal end,
        setFunc       = function(value)
            Reforged.Settings.ModoGlobal = value
            applyPreset(value)
        end,
        width = "full",
    })

    ---------------------------------------------------------------------------
    -- Busca
    ---------------------------------------------------------------------------
    table.insert(opts, { type = "header", name = "|c44d62cBusca Bilíngue Universal|r", width = "full" })
    table.insert(opts, {
        type  = "description",
        text  = "Permite pesquisar itens digitando o nome em português. O addon localiza as correspondências em inglês automaticamente.",
        width = "full",
    })
    table.insert(opts, {
        type     = "checkbox",
        name     = "Busca — Inventário / Banco",
        tooltip  = "Ativa a busca em português nos campos de pesquisa do inventário, banco pessoal, banco de assinante, banco de guilda e Colecionador de Conjuntos.",
        warning  = staleWarning,
        disabled = isStale,
        getFunc  = function() return Reforged.Settings.EnglishSearch end,
        setFunc  = function(value) Reforged.Settings.EnglishSearch = value end,
    })
    table.insert(opts, {
        type      = "checkbox",
        name      = "Busca — Casa de Comerciantes",
        tooltip   = "Ativa a busca em português na casa de comerciantes. Um índice local é compilado na primeira busca. Atenção: este processo pode impactar a performance em computadores menos potentes e consoles.",
        warning   = staleWarning,
        disabled  = isStale,
        reference = "EsoBR_TradingHouse_Checkbox",
        getFunc   = function() return Reforged.Settings.TradingHouseSearch end,
        setFunc   = function(value)
            Reforged.Settings.TradingHouseSearch = value
            if value and Reforged.Modules.TradingHouse and Reforged.Modules.TradingHouse.CheckIndex then
                Reforged.Modules.TradingHouse.CheckIndex()
            end
        end,
    })

    ---------------------------------------------------------------------------
    -- World
    ---------------------------------------------------------------------------
    table.insert(opts, { type = "header", name = "|c44d62cMundo|r", width = "full" })
    table.insert(opts, dropdown("NPCs e Personagens",
        "Define como os nomes de NPCs e personagens são exibidos no mundo.",
        "ShowNPC"))
    table.insert(opts, dropdown("Locais e Zonas",
        "Define como os nomes de locais, zonas e pontos de interesse são exibidos.",
        "ShowLocations"))
    table.insert(opts, dropdown("Estações de Profissão",
        "Define como os nomes das estações de crafting são exibidos.",
        "ShowCraft"))

    ---------------------------------------------------------------------------
    -- Items
    ---------------------------------------------------------------------------
    table.insert(opts, { type = "header", name = "|c44d62cItens|r", width = "full" })
    table.insert(opts, dropdown("Nome do Item",
        "Idioma do nome principal exibido no tooltip e no inventário.",
        "ShowItemsNamesTooltip"))
    table.insert(opts, dropdown("Encantamentos",
        "Idioma do nome dos encantamentos no tooltip.",
        "ShowItemsEnchantsTooltip"))
    table.insert(opts, dropdown("Traços",
        "Idioma do nome dos traços de item no tooltip.",
        "ShowItemsTraitsTooltip"))
    table.insert(opts, dropdown("Conjuntos",
        "Idioma do nome dos conjuntos no tooltip.",
        "ShowItemsSetsTooltip"))

    ---------------------------------------------------------------------------
    -- Combat
    ---------------------------------------------------------------------------
    table.insert(opts, { type = "header", name = "|c44d62cCombate|r", width = "full" })
    table.insert(opts, dropdown("Menu de Habilidades",
        "Idioma dos nomes de habilidades no menu de habilidades (K).",
        "ShowAbilitiesMenu",
        CHOICES_SHORT,
        CHOICES_SHORT_VAL))
    table.insert(opts, dropdown("Tooltip de Habilidades",
        "Idioma dos nomes de habilidades no tooltip ao passar o mouse.",
        "ShowAbilitiesTooltip"))
    table.insert(opts, dropdown("Pontos de Campeão",
        "Idioma das habilidades de Campeão no tooltip.",
        "ShowChampionTooltip"))

    ---------------------------------------------------------------------------
    -- Collections
    ---------------------------------------------------------------------------
    table.insert(opts, { type = "header", name = "|c44d62cColeções|r", width = "full" })
    table.insert(opts, dropdown("Nomes na Coleção de Conjuntos",
        "Idioma dos nomes de conjuntos exibidos na coleção.",
        "ShowCollectionsSetsMenu"))

    ---------------------------------------------------------------------------
    -- System
    ---------------------------------------------------------------------------
    local LANG_LABELS = { br = "Português", en = "English" }

    local function langButton(lang)
        local tex = "EsoBR_Reforged/textures/" .. lang .. ".dds"
        return {
            type    = "button",
            name    = "|t32:22:" .. tex .. "|t  " .. LANG_LABELS[lang],
            tooltip = lang == "br" and "Alterar idioma do cliente para Português."
                                    or "Switch client language to English.",
            func    = function()
                if GetCVar("language.2") == lang then
                    ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "Você já está neste idioma.")
                    return
                end
                Reforged.UI.HUD.setLanguage(lang)
                ReloadUI()
            end,
            width = "half",
        }
    end

    table.insert(opts, { type = "header", name = "|c44d62cSistema|r", width = "full" })
    table.insert(opts, langButton("br"))
    table.insert(opts, langButton("en"))
    table.insert(opts, {
        type    = "checkbox",
        name    = "Manter idioma entre sessões",
        tooltip = "O jogo inicia no mesmo idioma escolhido na sessão anterior, ignorando a configuração do launcher.",
        getFunc = function() return GetCVar("IgnorePatcherLanguageSetting") == "1" end,
        setFunc = function(value) SetCVar("IgnorePatcherLanguageSetting", value and "1" or "0") end,
    })

    LAM:RegisterOptionControls(panelData.name, opts)
end

function Reforged.IsAddonRunning(addonName)
    local manager = GetAddOnManager()
    for i = 1, manager:GetNumAddOns() do
        local name, _, _, _, _, state = manager:GetAddOnInfo(i)
        if name == addonName and state == ADDON_STATE_ENABLED then
            return true
        end
    end
    return false
end

local function disableAddon(name)
    local manager = GetAddOnManager()
    for i = 1, manager:GetNumAddOns() do
        local n = manager:GetAddOnInfo(i)
        if n == name then
            manager:SetAddOnEnabled(i, false)
            return
        end
    end
end

local function registerConflictDialog()
    ZO_Dialogs_RegisterCustomDialog("EsoBRReforgedConflictDialog", {
        canQueue      = true,
        onlyQueueOnce = true,
        gamepadInfo   = { dialogType = GAMEPAD_DIALOGS.BASIC },
        title         = { text = "Conflito de Addons" },
        mainText      = { text = "|cffe014EsoBR|r e |cffe014EsoBR Reforged|r estão ativos ao mesmo tempo e causarão conflitos. O EsoBR é uma versão antiga do add-on e é recomendado que você o remova para evitar conflitos.\n\nQual deseja manter ativo?" },
        buttons = {
            {
                keybind    = "DIALOG_PRIMARY",
                text       = "Manter Reforged",
                callback   = function() disableAddon("EsoBR"); ReloadUI() end,
                clickSound = SOUNDS.DIALOG_ACCEPT,
            },
            {
                keybind    = "DIALOG_NEGATIVE",
                text       = "Manter EsoBR",
                callback   = function() disableAddon("EsoBR_Reforged"); ReloadUI() end,
                clickSound = SOUNDS.DIALOG_DECLINE,
            },
        },
    })
end

local function OnInit(_, addonName)
    if zo_strlower(addonName) ~= zo_strlower(Reforged.NAME) then return end
    EVENT_MANAGER:UnregisterForEvent(Reforged.NAME .. "_OnAddOnLoaded", EVENT_ADD_ON_LOADED)

    Reforged.DB.init()
    registerConflictDialog()

    -- If EsoBR original is running, skip module activation entirely to avoid
    -- hook conflicts. The dialog in OnPlayerActivated will prompt the user.
    if Reforged.IsAddonRunning("EsoBR") then return end

    if Reforged.SettingsChar.IsFirstLaunch then
        SetSetting(SETTING_TYPE_SUBTITLES, SUBTITLE_SETTING_ENABLED_FOR_NPCS, "true")
        SetSetting(SETTING_TYPE_SUBTITLES, SUBTITLE_SETTING_ENABLED_FOR_VIDEOS, "true")
        Reforged.SettingsChar.IsFirstLaunch = false
    end

    for _, flagCode in pairs(Reforged.FLAGS) do
        ZO_CreateStringId("SI_BINDING_NAME_ESOBR_REFORGED_" .. string.upper(flagCode),
            flagCode == "br" and "Língua Portuguesa" or "Língua Inglesa")
    end

    Reforged.Modules.activateAll()

    Reforged.UI.Settings.register()

    SLASH_COMMANDS["/esobr-reset-splash"] = function()
        Reforged.Settings.IsUpdateNeeded = true
        Reforged.Settings.Data.ApiVersion = 0
        d("EsoBR: splash resetada. Use /reloadui para ver.")
    end

    SLASH_COMMANDS["/esobr-reset"] = function()
        for k, v in pairs(Reforged.DB.Defaults) do
            Reforged.Settings[k] = type(v) == "table" and ZO_DeepTableCopy(v) or v
        end
        Reforged.SettingsChar.IsFirstLaunch = true
        d("EsoBR: addon resetado para instalação nova. Recarregando UI...")
        ReloadUI()
    end

    SLASH_COMMANDS["/esobr-test-conflict"] = function()
        ZO_Dialogs_ShowDialog("EsoBRReforgedConflictDialog")
    end
end

local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(Reforged.NAME .. "_OnPlayerActivated", EVENT_PLAYER_ACTIVATED)

    if Reforged.IsAddonRunning("EsoBR") then
        ZO_Dialogs_ShowDialog("EsoBRReforgedConflictDialog")
        return
    end

    Reforged.Dump.check()

    if Reforged.Settings.IsUpdateNeeded and Reforged.DB.isStale() then
        local confirmDialog = {
            canQueue     = true,
            onlyQueueOnce = true,
            gamepadInfo  = { dialogType = GAMEPAD_DIALOGS.BASIC },
            mainText     = { text = "\n\n|ac|t320:175:EsoBR_Reforged/textures/reforged_logo.dds|t\n\n\n\n\n|alBoas-vindas ao EsoBR!\n\nPara concluir sua configuração, você precisa atualizar o Banco de Dados. O processo leva cerca de um minuto, dependendo do seu hardware. Caso não possa fazer isso agora, você pode atualizar mais tarde em:\nESC → Opções → Addons → EsoBR → Atualizar Banco de Dados.\n\nVocê pode alterar o idioma nas configurações de Sistema ou definir atalhos em ESC → Controles.\n\nEste projeto foi criado e traduzido por @mestrefrooke, @FabresFour e recebeu a ferramenta bilíngue de @erickhwk. Bom jogo!" },
            buttons = {
                {
                    keybind    = "DIALOG_PRIMARY",
                    text       = "Atualizar Banco",
                    callback   = function() Reforged.Dump.run() end,
                    clickSound = SOUNDS.DIALOG_ACCEPT,
                },
                {
                    keybind    = "DIALOG_NEGATIVE",
                    text       = "Cancelar",
                    callback   = function() Reforged.Settings.IsUpdateNeeded = false end,
                    clickSound = SOUNDS.DIALOG_DECLINE,
                },
            },
        }
        ZO_Dialogs_RegisterCustomDialog("EsoBRReforgedDialog", confirmDialog)
        ZO_Dialogs_ReleaseDialog("EsoBRReforgedDialog", false)
        ZO_Dialogs_ShowDialog("EsoBRReforgedDialog")
    elseif Reforged.DB.isStale() then
        d("EsoBR: Banco de Dados desatualizado. Atualize em ESC → Opções → Addons → EsoBR.")
    end
end

EVENT_MANAGER:RegisterForEvent(Reforged.NAME .. "_OnAddOnLoaded",   EVENT_ADD_ON_LOADED,    OnInit)
EVENT_MANAGER:RegisterForEvent(Reforged.NAME .. "_OnPlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

-- Bypass: desativa todos os hooks durante interação com mesa de construção
-- para não interferir com o DolgubonsLazyWritCreator.
Reforged.craftingStationActive = false
EVENT_MANAGER:RegisterForEvent(Reforged.NAME .. "_CraftBypass", EVENT_CRAFTING_STATION_INTERACT, function()
    Reforged.craftingStationActive = true
end)
EVENT_MANAGER:RegisterForEvent(Reforged.NAME .. "_CraftBypass", EVENT_END_CRAFTING_STATION_INTERACT, function()
    Reforged.craftingStationActive = false
end)

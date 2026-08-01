function RPCompanion:InitializeSettings()
    local LAM2 = LibAddonMenu2
    if not LAM2 then
        d("[RP] LibAddonMenu-2.0 manquant.")
        return
    end

    local panelData = {
        type = "panel",
        name = "RPCompanion",
        displayName = "RPCompanion",
        author = "Didier Verstringe",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM2:RegisterAddonPanel("RPCompanionOptions", panelData)

    local optionsData = {
        {
            type = "description",
            text = "Addon RP pour gérer fiche personnage, journal, rencontres, profils, alignement et partage de fiche.",
        },
        {
            type = "checkbox",
            name = "Afficher le message de bienvenue",
            getFunc = function()
                return self.savedVars.settings.showWelcome
            end,
            setFunc = function(value)
                self.savedVars.settings.showWelcome = value
            end,
            default = self.defaults.settings.showWelcome,
        },
        {
            type = "editbox",
            name = "Préfixe des messages",
            getFunc = function()
                return self.savedVars.settings.prefix
            end,
            setFunc = function(value)
                self.savedVars.settings.prefix = value
            end,
            default = self.defaults.settings.prefix,
            isMultiline = false,
        },
        {
            type = "header",
            name = "Profil actif",
        },
        {
            type = "editbox",
            name = "Nom du personnage",
            getFunc = function()
                return self:GetActiveProfile().characterName or ""
            end,
            setFunc = function(value)
                self:GetActiveProfile().characterName = value
            end,
            default = "",
            isMultiline = false,
        },
        {
            type = "editbox",
            name = "Titre",
            getFunc = function()
                return self:GetActiveProfile().title or ""
            end,
            setFunc = function(value)
                self:GetActiveProfile().title = value
            end,
            default = "",
            isMultiline = false,
        },
        {
            type = "editbox",
            name = "Race",
            getFunc = function()
                return self:GetActiveProfile().race or ""
            end,
            setFunc = function(value)
                self:GetActiveProfile().race = value
            end,
            default = "",
            isMultiline = false,
        },
        {
            type = "editbox",
            name = "Alliance",
            getFunc = function()
                return self:GetActiveProfile().alliance or ""
            end,
            setFunc = function(value)
                self:GetActiveProfile().alliance = value
            end,
            default = "",
            isMultiline = false,
        },
        {
            type = "dropdown",
            name = "Statut RP",
            choices = { "Disponible", "Occupé", "Absent", "Hors RP" },
            getFunc = function()
                return self:GetActiveProfile().status or "Disponible"
            end,
            setFunc = function(value)
                self:GetActiveProfile().status = value
            end,
            default = "Disponible",
        },
        {
            type = "editbox",
            name = "Biographie",
            getFunc = function()
                return self:GetActiveProfile().biography or ""
            end,
            setFunc = function(value)
                self:GetActiveProfile().biography = value
            end,
            default = "",
            isMultiline = true,
            minHeight = 180,
        },
        {
            type = "editbox",
            name = "Actuellement",
            getFunc = function()
                return self:GetActiveProfile().current or ""
            end,
            setFunc = function(value)
                self:GetActiveProfile().current = value
            end,
            default = "",
            isMultiline = true,
            minHeight = 70,
        },
        {
            type = "editbox",
            name = "Aspect",
            getFunc = function()
                return self:GetActiveProfile().appearance or ""
            end,
            setFunc = function(value)
                self:GetActiveProfile().appearance = value
            end,
            default = "",
            isMultiline = true,
            minHeight = 90,
        },
        {
            type = "slider",
            name = "Loyal ↔ Chaotique",
            min = -100,
            max = 100,
            step = 1,
            getFunc = function()
                return self:GetActiveProfile().alignmentLawChaos or 0
            end,
            setFunc = function(value)
                self:GetActiveProfile().alignmentLawChaos = zo_round(value)
            end,
            default = 0,
        },
        {
            type = "slider",
            name = "Bon ↔ Mauvais",
            min = -100,
            max = 100,
            step = 1,
            getFunc = function()
                return self:GetActiveProfile().alignmentGoodEvil or 0
            end,
            setFunc = function(value)
                self:GetActiveProfile().alignmentGoodEvil = zo_round(value)
            end,
            default = 0,
        },
        {
            type = "slider",
            name = "Moralité",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function()
                return self:GetActiveProfile().morality or 50
            end,
            setFunc = function(value)
                self:GetActiveProfile().morality = zo_round(value)
            end,
            default = 50,
        },
        {
            type = "button",
            name = "Afficher la fiche dans le chat",
            func = function()
                self:ShowProfile()
            end,
            warning = "Affiche le profil actif dans le chat.",
        },
    }

    LAM2:RegisterOptionControls("RPCompanionOptions", optionsData)
end
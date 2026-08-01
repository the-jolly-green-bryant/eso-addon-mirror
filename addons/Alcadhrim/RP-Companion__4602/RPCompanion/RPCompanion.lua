RPCompanion = {}
RPCompanion.name = "RPCompanion"
RPCompanion.version = "1.0.0"

RPCompanion.NET_PREFIX = "RPCP1"
RPCompanion.NET_SEP = "|"

RPCompanion.defaults = {
    activeProfile = "Principal",

    profiles = {
        ["Principal"] = {
            characterName = "",
            title = "",
            race = "",
            alliance = "",
            biography = "",
            status = "Disponible",
            current = "",
            appearance = "",
            alignmentLawChaos = 0,
            alignmentGoodEvil = 0,
            morality = 50,
        },
    },

    journal = {},
    encounters = {},

    compatibleUsers = {},
    receivedProfiles = {},

    settings = {
        showWelcome = true,
        prefix = "[RP]",
        showHudStatus = false,
    }
}

local function Msg(text)
    local prefix = "[RP]"
    if RPCompanion.savedVars and RPCompanion.savedVars.settings and RPCompanion.savedVars.settings.prefix then
        prefix = RPCompanion.savedVars.settings.prefix
    end
    d(string.format("%s %s", prefix, text))
end

function RPCompanion:GetDefaultProfileData()
    return {
        characterName = "",
        title = "",
        race = "",
        alliance = "",
        biography = "",
        status = "Disponible",
        current = "",
        appearance = "",
        alignmentLawChaos = 0,
        alignmentGoodEvil = 0,
        morality = 50,
    }
end

function RPCompanion:GetActiveProfileName()
    if not self.savedVars.activeProfile or self.savedVars.activeProfile == "" then
        self.savedVars.activeProfile = "Principal"
    end
    return self.savedVars.activeProfile
end

function RPCompanion:EnsureProfileDefaults(profile)
    if profile.current == nil then profile.current = "" end
    if profile.appearance == nil then profile.appearance = "" end
    if profile.alignmentLawChaos == nil then profile.alignmentLawChaos = 0 end
    if profile.alignmentGoodEvil == nil then profile.alignmentGoodEvil = 0 end
    if profile.morality == nil then profile.morality = 50 end
end

function RPCompanion:GetActiveProfile()
    local name = self:GetActiveProfileName()

    if not self.savedVars.profiles then
        self.savedVars.profiles = {}
    end

    if not self.savedVars.profiles[name] then
        self.savedVars.profiles[name] = self:GetDefaultProfileData()
    end

    local profile = self.savedVars.profiles[name]
    self:EnsureProfileDefaults(profile)
    return profile
end

function RPCompanion:GetProfile()
    return self:GetActiveProfile()
end

function RPCompanion:SetProfileField(field, value)
    local profile = self:GetActiveProfile()
    if profile[field] ~= nil then
        profile[field] = value
        Msg(field .. " mis à jour.")
    else
        Msg("Champ inconnu : " .. tostring(field))
    end
end

function RPCompanion:GetLawChaosLabel(value)
    if value <= -75 then return "Très loyal" end
    if value <= -25 then return "Plutôt loyal" end
    if value < 25 then return "Neutre" end
    if value < 75 then return "Plutôt chaotique" end
    return "Très chaotique"
end

function RPCompanion:GetGoodEvilLabel(value)
    if value <= -75 then return "Très bon" end
    if value <= -25 then return "Plutôt bon" end
    if value < 25 then return "Neutre" end
    if value < 75 then return "Plutôt mauvais" end
    return "Très mauvais"
end

function RPCompanion:GetMoralityLabel(value)
    if value <= 20 then return "Très basse" end
    if value <= 40 then return "Basse" end
    if value <= 60 then return "Moyenne" end
    if value <= 80 then return "Élevée" end
    return "Exemplaire"
end

function RPCompanion:ShowProfile()
    local p = self:GetActiveProfile()
    Msg("===== FICHE RP =====")
    Msg("Profil : " .. self:GetActiveProfileName())
    Msg("Nom : " .. ((p.characterName ~= "" and p.characterName) or GetUnitName("player")))
    Msg("Titre : " .. ((p.title ~= "" and p.title) or "-"))
    Msg("Race : " .. ((p.race ~= "" and p.race) or "-"))
    Msg("Alliance : " .. ((p.alliance ~= "" and p.alliance) or "-"))
    Msg("Statut : " .. ((p.status ~= "" and p.status) or "-"))
    Msg("Bio : " .. ((p.biography ~= "" and p.biography) or "-"))
    Msg("Actuellement : " .. ((p.current ~= "" and p.current) or "-"))
    Msg("Aspect : " .. ((p.appearance ~= "" and p.appearance) or "-"))
    Msg("Loyal/Chaotique : " .. self:GetLawChaosLabel(p.alignmentLawChaos) .. " (" .. tostring(p.alignmentLawChaos) .. ")")
    Msg("Bon/Mauvais : " .. self:GetGoodEvilLabel(p.alignmentGoodEvil) .. " (" .. tostring(p.alignmentGoodEvil) .. ")")
    Msg("Moralité : " .. self:GetMoralityLabel(p.morality) .. " (" .. tostring(p.morality) .. ")")
end

function RPCompanion:AddJournalEntry(text)
    if not text or text == "" then return end
    if not self.savedVars.journal then
        self.savedVars.journal = {}
    end

    table.insert(self.savedVars.journal, 1, {
        date = GetDateStringFromTimestamp(GetTimeStamp()),
        text = text,
    })
end

function RPCompanion:DeleteJournalEntry(index)
    if self.savedVars.journal and self.savedVars.journal[index] then
        table.remove(self.savedVars.journal, index)
        return true
    end
    return false
end

function RPCompanion:AddEncounter(name, note)
    if not name or name == "" then return end
    if not self.savedVars.encounters then
        self.savedVars.encounters = {}
    end

    table.insert(self.savedVars.encounters, 1, {
        name = name,
        note = note or "",
        date = GetDateStringFromTimestamp(GetTimeStamp()),
    })
end

function RPCompanion:DeleteEncounter(index)
    if self.savedVars.encounters and self.savedVars.encounters[index] then
        table.remove(self.savedVars.encounters, index)
        return true
    end
    return false
end

function RPCompanion:CreateProfile(profileName)
    if not profileName or profileName == "" then
        return false
    end

    if not self.savedVars.profiles then
        self.savedVars.profiles = {}
    end

    if self.savedVars.profiles[profileName] then
        return false
    end

    self.savedVars.profiles[profileName] = self:GetDefaultProfileData()
    return true
end

function RPCompanion:SetActiveProfile(profileName)
    if self.savedVars.profiles and self.savedVars.profiles[profileName] then
        self.savedVars.activeProfile = profileName
        return true
    end
    return false
end

function RPCompanion:DeleteProfile(profileName)
    if not profileName or profileName == "" then return false end
    if profileName == "Principal" then return false end
    if not self.savedVars.profiles or not self.savedVars.profiles[profileName] then return false end

    self.savedVars.profiles[profileName] = nil

    if self.savedVars.activeProfile == profileName then
        self.savedVars.activeProfile = "Principal"
    end

    return true
end

function RPCompanion:GetSortedProfileNames()
    local names = {}
    for name, _ in pairs(self.savedVars.profiles or {}) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

function RPCompanion:SanitizeNetText(text)
    text = tostring(text or "")
    text = zo_strgsub(text, "\r", " ")
    text = zo_strgsub(text, "\n", "\\n")
    text = zo_strgsub(text, self.NET_SEP, "/")
    return text
end

function RPCompanion:UnsanitizeNetText(text)
    text = tostring(text or "")
    text = zo_strgsub(text, "\\n", "\n")
    return text
end

function RPCompanion:BuildPingMessage()
    return string.format("%s%sPING", self.NET_PREFIX, self.NET_SEP)
end

function RPCompanion:BuildPongMessage()
    return string.format("%s%sPONG", self.NET_PREFIX, self.NET_SEP)
end

function RPCompanion:BuildInspectRequestMessage()
    return string.format("%s%sINSPECTREQ%s%s", self.NET_PREFIX, self.NET_SEP, self.NET_SEP, self:SanitizeNetText(GetDisplayName()))
end

function RPCompanion:BuildProfileMessage()
    local p = self:GetActiveProfile()

    local parts = {
        self.NET_PREFIX,
        "PROFILE",
        self:SanitizeNetText(GetDisplayName()),
        self:SanitizeNetText(self:GetActiveProfileName()),
        self:SanitizeNetText(p.characterName),
        self:SanitizeNetText(p.title),
        self:SanitizeNetText(p.race),
        self:SanitizeNetText(p.alliance),
        self:SanitizeNetText(p.status),
        self:SanitizeNetText(p.biography),
        self:SanitizeNetText(p.current),
        self:SanitizeNetText(p.appearance),
        tostring(p.alignmentLawChaos or 0),
        tostring(p.alignmentGoodEvil or 0),
        tostring(p.morality or 50),
    }

    return table.concat(parts, self.NET_SEP)
end

function RPCompanion:PrepareWhisper(target, payload)
    if not target or target == "" then
        Msg("Cible invalide.")
        return
    end

    local whisperText = string.format("/w %s %s", target, payload)

    if StartChatInput then
        StartChatInput(whisperText)
        Msg("Whisper préparé pour " .. target .. ". Appuie sur Entrée pour l'envoyer.")
    else
        Msg("Impossible de préremplir le chat automatiquement.")
        Msg("Envoie manuellement : " .. whisperText)
    end
end

function RPCompanion:MarkCompatible(displayName)
    if not displayName or displayName == "" then return end

    self.savedVars.compatibleUsers[displayName] = {
        lastSeen = GetDateStringFromTimestamp(GetTimeStamp()),
    }
end

function RPCompanion:StoreReceivedProfile(fromDisplayName, profileName, characterName, title, race, alliance, status, biography, current, appearance, alignmentLawChaos, alignmentGoodEvil, morality)
    if not fromDisplayName or fromDisplayName == "" then return end

    self.savedVars.receivedProfiles[fromDisplayName] = {
        sender = fromDisplayName,
        profileName = profileName or "",
        characterName = characterName or "",
        title = title or "",
        race = race or "",
        alliance = alliance or "",
        status = status or "",
        biography = biography or "",
        current = current or "",
        appearance = appearance or "",
        alignmentLawChaos = tonumber(alignmentLawChaos) or 0,
        alignmentGoodEvil = tonumber(alignmentGoodEvil) or 0,
        morality = tonumber(morality) or 50,
        receivedAt = GetDateStringFromTimestamp(GetTimeStamp()),
    }

    self.selectedReceivedProfile = fromDisplayName
    self:MarkCompatible(fromDisplayName)
end

function RPCompanion:GetInspectTargetDisplayName()
    if GetUnitDisplayName then
        local target = GetUnitDisplayName("reticleover")
        if target and target ~= "" then
            return target
        end
    end
    return nil
end

function RPCompanion:RequestInspect(target)
    if not target or target == "" then
        target = self:GetInspectTargetDisplayName()
    end

    if not target or target == "" then
        Msg("Aucune cible valide. Utilise /rp inspect @UserID ou cible un joueur.")
        return
    end

    self:PrepareWhisper(target, self:BuildInspectRequestMessage())
end

function RPCompanion:HandleIncomingNetworkMessage(fromDisplayName, text)
    if not text or text == "" then return end
    if not zo_plainstrfind(text, self.NET_PREFIX .. self.NET_SEP) then return end

    local parts = {}
    for token in string.gmatch(text, "([^|]+)") do
        table.insert(parts, token)
    end

    if #parts < 2 then return end
    if parts[1] ~= self.NET_PREFIX then return end

    local msgType = parts[2]

    if msgType == "PING" then
        self:MarkCompatible(fromDisplayName)
        Msg(fromDisplayName .. " utilise RPCompanion.")
        self:PrepareWhisper(fromDisplayName, self:BuildPongMessage())
        return
    end

    if msgType == "PONG" then
        self:MarkCompatible(fromDisplayName)
        Msg(fromDisplayName .. " a répondu au test RPCompanion.")
        return
    end

    if msgType == "INSPECTREQ" then
        self:MarkCompatible(fromDisplayName)
        Msg(fromDisplayName .. " demande à consulter ta fiche RP.")
        self:PrepareWhisper(fromDisplayName, self:BuildProfileMessage())
        return
    end

    if msgType == "PROFILE" then
        local sender = self:UnsanitizeNetText(parts[3] or fromDisplayName)
        local profileName = self:UnsanitizeNetText(parts[4] or "")
        local characterName = self:UnsanitizeNetText(parts[5] or "")
        local title = self:UnsanitizeNetText(parts[6] or "")
        local race = self:UnsanitizeNetText(parts[7] or "")
        local alliance = self:UnsanitizeNetText(parts[8] or "")
        local status = self:UnsanitizeNetText(parts[9] or "")
        local biography = self:UnsanitizeNetText(parts[10] or "")
        local current = self:UnsanitizeNetText(parts[11] or "")
        local appearance = self:UnsanitizeNetText(parts[12] or "")
        local alignmentLawChaos = tonumber(parts[13] or 0) or 0
        local alignmentGoodEvil = tonumber(parts[14] or 0) or 0
        local morality = tonumber(parts[15] or 50) or 50

        self:StoreReceivedProfile(sender, profileName, characterName, title, race, alliance, status, biography, current, appearance, alignmentLawChaos, alignmentGoodEvil, morality)
        Msg("Fiche reçue de " .. sender)

        if self.RefreshUI then
            self:RefreshUI()
        end
        return
    end
end

function RPCompanion:RegisterChatListener()
    local function OnChatMessage(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
        if channelType == CHAT_CHANNEL_WHISPER then
            local sender = fromDisplayName or fromName or ""
            RPCompanion:HandleIncomingNetworkMessage(sender, text)
        end
    end

    EVENT_MANAGER:RegisterForEvent(self.name .. "_ChatListener", EVENT_CHAT_MESSAGE_CHANNEL, OnChatMessage)
end

function RPCompanion:PrintCompatibles()
    Msg("===== UTILISATEURS COMPATIBLES =====")
    local found = false
    for displayName, data in pairs(self.savedVars.compatibleUsers or {}) do
        found = true
        Msg(displayName .. " (vu : " .. tostring(data.lastSeen or "?") .. ")")
    end
    if not found then
        Msg("Aucun utilisateur détecté.")
    end
end

function RPCompanion:PrintReceivedProfiles()
    Msg("===== FICHES REÇUES =====")
    local found = false
    for displayName, data in pairs(self.savedVars.receivedProfiles or {}) do
        found = true
        Msg(displayName .. " -> " .. tostring(data.characterName or "-"))
    end
    if not found then
        Msg("Aucune fiche reçue.")
    end
end

function RPCompanion:PrintHelp()
    Msg("Commandes disponibles :")
    Msg("/rp help")
    Msg("/rp show")
    Msg("/rp ui")
    Msg("/rp inspect")
    Msg("/rp inspect @UserID")
    Msg("/rp set name <texte>")
    Msg("/rp set title <texte>")
    Msg("/rp set race <texte>")
    Msg("/rp set alliance <texte>")
    Msg("/rp set status <texte>")
    Msg("/rp set bio <texte>")
    Msg("/rp set current <texte>")
    Msg("/rp set appearance <texte>")
    Msg("/rp journal add <texte>")
    Msg("/rp encounter add <nom> <note>")
    Msg("/rp profile create <nom>")
    Msg("/rp profile use <nom>")
    Msg("/rp ping <@UserID>")
    Msg("/rp share <@UserID>")
    Msg("/rp compatibles")
    Msg("/rp inbox")
end

function RPCompanion:HandleSetCommand(args)
    local key, value = args:match("^(%S+)%s+(.+)$")
    if not key or not value then
        Msg("Utilisation : /rp set <champ> <valeur>")
        return
    end

    local mapping = {
        name = "characterName",
        title = "title",
        race = "race",
        alliance = "alliance",
        status = "status",
        bio = "biography",
        current = "current",
        appearance = "appearance",
    }

    local field = mapping[string.lower(key)]
    if not field then
        Msg("Champ invalide. Utilise : name, title, race, alliance, status, bio, current, appearance")
        return
    end

    self:SetProfileField(field, value)
end

function RPCompanion:HandleJournalCommand(args)
    local sub, rest = args:match("^(%S+)%s*(.*)$")
    sub = sub and string.lower(sub) or ""

    if sub == "add" then
        if rest ~= "" then
            self:AddJournalEntry(rest)
            Msg("Entrée de journal ajoutée.")
        else
            Msg("Utilisation : /rp journal add <texte>")
        end
    else
        Msg("Utilisation : /rp journal add <texte>")
    end
end

function RPCompanion:HandleEncounterCommand(args)
    local sub, rest = args:match("^(%S+)%s*(.*)$")
    sub = sub and string.lower(sub) or ""

    if sub == "add" then
        local name, note = rest:match("^(%S+)%s+(.+)$")
        if name and note then
            self:AddEncounter(name, note)
            Msg("Rencontre ajoutée.")
        else
            Msg("Utilisation : /rp encounter add <nom> <note>")
        end
    else
        Msg("Utilisation : /rp encounter add <nom> <note>")
    end
end

function RPCompanion:HandleProfileCommand(args)
    local sub, rest = args:match("^(%S+)%s*(.*)$")
    sub = sub and string.lower(sub) or ""

    if sub == "create" then
        if self:CreateProfile(rest) then
            Msg("Profil créé : " .. rest)
        else
            Msg("Impossible de créer ce profil.")
        end
    elseif sub == "use" then
        if self:SetActiveProfile(rest) then
            Msg("Profil actif : " .. rest)
            if self.RefreshUI then
                self:RefreshUI()
            end
        else
            Msg("Profil introuvable : " .. rest)
        end
    else
        Msg("Utilisation : /rp profile create <nom> | /rp profile use <nom>")
    end
end

function RPCompanion:InitializeCommands()
    SLASH_COMMANDS["/rp"] = function(text)
        text = text or ""
        local command, args = text:match("^(%S+)%s*(.-)$")
        command = command and string.lower(command) or ""

        if command == "" or command == "help" then
            self:PrintHelp()
        elseif command == "show" then
            self:ShowProfile()
        elseif command == "set" then
            self:HandleSetCommand(args)
        elseif command == "ui" then
            self:ToggleUI()
        elseif command == "inspect" then
            self:RequestInspect(args)
        elseif command == "journal" then
            self:HandleJournalCommand(args)
        elseif command == "encounter" then
            self:HandleEncounterCommand(args)
        elseif command == "profile" then
            self:HandleProfileCommand(args)
        elseif command == "ping" then
            self:PrepareWhisper(args, self:BuildPingMessage())
        elseif command == "share" then
            self:PrepareWhisper(args, self:BuildProfileMessage())
        elseif command == "compatibles" then
            self:PrintCompatibles()
        elseif command == "inbox" then
            self:PrintReceivedProfiles()
        else
            Msg("Commande inconnue. Tape /rp help")
        end
    end
end

function RPCompanion:Initialize()
    self.savedVars = ZO_SavedVars:NewCharacterIdSettings("RPCompanionSavedVars", 1, nil, self.defaults)

    if not self.savedVars.profiles then
        self.savedVars.profiles = ZO_DeepTableCopy(self.defaults.profiles)
    end
    if not self.savedVars.activeProfile then
        self.savedVars.activeProfile = "Principal"
    end
    if not self.savedVars.journal then
        self.savedVars.journal = {}
    end
    if not self.savedVars.encounters then
        self.savedVars.encounters = {}
    end
    if not self.savedVars.compatibleUsers then
        self.savedVars.compatibleUsers = {}
    end
    if not self.savedVars.receivedProfiles then
        self.savedVars.receivedProfiles = {}
    end
    if not self.savedVars.settings then
        self.savedVars.settings = ZO_DeepTableCopy(self.defaults.settings)
    end
    if self.savedVars.settings.showHudStatus == nil then
        self.savedVars.settings.showHudStatus = false
    end

    for _, profile in pairs(self.savedVars.profiles) do
        self:EnsureProfileDefaults(profile)
    end

    self:InitializeCommands()
    self:RegisterChatListener()
    self:CreateUI()

    if self.savedVars.settings and self.savedVars.settings.showWelcome then
        Msg("RPCompanion chargé. Tape /rp help")
    end

    if self.InitializeSettings then
        self:InitializeSettings()
    end
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= RPCompanion.name then return end
    EVENT_MANAGER:UnregisterForEvent(RPCompanion.name, EVENT_ADD_ON_LOADED)
    RPCompanion:Initialize()
end

EVENT_MANAGER:RegisterForEvent(RPCompanion.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
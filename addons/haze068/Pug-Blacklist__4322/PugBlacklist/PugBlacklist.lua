-- Global database
PugBlacklistDB = PugBlacklistDB or {}
PugBlacklistSettings = PugBlacklistSettings or {}

----------------------------------------------------
-- Debug Output with correct ESO color codes
----------------------------------------------------
local function Debug(msg)
    d("|cFFA500[PugBlacklist]|r " .. msg)
end

----------------------------------------------------
-- Settings
----------------------------------------------------
local defaults = {
    enableGroupWarnings = true,
    enableChatNotifications = true,
    showVisualIndicators = true,
    backupInterval = 7, -- days
    lastBackup = 0,
}

PugBlacklistSettings = ZO_SavedVars:New("PugBlacklistSettings", 2, nil, defaults)

----------------------------------------------------
-- NEU: Dateisystem-Funktionen (korrigiert für ESO)
----------------------------------------------------
local function GetAddonPath()
    -- In ESO können wir nicht direkt auf das Dateisystem zugreifen
    -- Wir verwenden einen festen Pfad im SavedVariables Verzeichnis
    return "Live/SavedVariables/"
end

local function EnsureBackupDirectory()
    -- In ESO können wir kein Verzeichnis erstellen
    -- Wir speichern einfach im SavedVariables-Verzeichnis
    local backupPath = GetAddonPath()
    
    Debug("Backups will be saved to SavedVariables directory")
    return backupPath
end

local function CreateBackupFile()
    local timestamp = GetTimeStamp()
    local dateString = os.date("%Y-%m-%d_%H-%M-%S", timestamp)
    local backupDir = EnsureBackupDirectory()
    
    -- In ESO können wir keine Dateien erstellen, also speichern wir nur in SavedVariables
    -- Sammle alle Blacklist-Einträge
    local entries = {}
    local count = 0
    
    for account, note in pairs(PugBlacklistDB) do
        -- Ignoriere Backup-Einträge
        if not string.find(account, "^backup_") then
            count = count + 1
            table.insert(entries, {
                account = account,
                note = note or ""
            })
        end
    end
    
    -- Sortiere alphabetisch
    table.sort(entries, function(a, b)
        return a.account < b.account
    end)
    
    -- Erstelle Dateiinhalt (für Anzeige)
    local content = "========================================\n"
    content = content .. "PUG BLACKLIST BACKUP\n"
    content = content .. "Created: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    content = content .. "Total Players: " .. count .. "\n"
    content = content .. "========================================\n\n"
    
    for _, entry in ipairs(entries) do
        local line = "@" .. entry.account
        if entry.note and entry.note ~= "" then
            line = line .. " - " .. entry.note
        end
        content = content .. line .. "\n"
    end
    
    -- Füge zusätzliche Informationen hinzu
    content = content .. "\n========================================\n"
    content = content .. "ADDON INFO\n"
    content = content .. "Addon: PugBlacklist v2.0\n"
    content = content .. "Author: @haze068\n"
    content = content .. "Discord: haze.3169\n"
    content = content .. "========================================\n"
    
    -- Speichere in Settings für interne Wiederherstellung
    PugBlacklistSettings.lastBackup = timestamp
    PugBlacklistSettings.backupData = content
    
    -- Track backup content (nicht als Datei, sondern als String)
    if not PugBlacklistSettings.backupContents then
        PugBlacklistSettings.backupContents = {}
    end
    PugBlacklistSettings.backupContents[tostring(timestamp)] = content
    
    Debug("|c00FF00Backup created successfully!|r")
    Debug("|c00FFFFBackup contains:|r " .. count .. " player(s)")
    
    -- Zeige eine Vorschau des Inhalts im Chat
    local previewCount = math.min(5, count)
    if previewCount > 0 then
        Debug("|cFFA500First " .. previewCount .. " entries:|r")
        for i = 1, previewCount do
            local entry = entries[i]
            Debug("  @|cFFA500" .. entry.account .. "|r" .. 
                  (entry.note ~= "" and " - |c00FF00" .. entry.note .. "|r" or ""))
        end
        if count > previewCount then
            Debug("  |cFFFF00... and " .. (count - previewCount) .. " more|r")
        end
    end
    
    -- Für Benutzer, die eine Datei wollen: Anleitung anzeigen
    Debug("|cFFFF00To save as a file:|r")
    Debug("|c00FFFF1. Copy the text below|r")
    Debug("|c00FFFF2. Paste into a text editor|r")
    Debug("|c00FFFF3. Save as: PugBlacklist_Backup_" .. dateString .. ".txt|r")
    
    -- Gib den Inhalt aus zum Kopieren
    d(" ")
    d("|cFF00FF============= BACKUP CONTENT =============|r")
    d(content)
    d("|cFF00FF========== END BACKUP CONTENT ==========|r")
    d(" ")
    
    return true, count
end

local function ListBackupFiles()
    local backups = {}
    
    -- Liste alle gespeicherten Backups auf
    if PugBlacklistSettings.backupContents then
        for timestamp, content in pairs(PugBlacklistSettings.backupContents) do
            table.insert(backups, {
                timestamp = tonumber(timestamp),
                content = content
            })
        end
    end
    
    -- Sortiere nach Datum (neueste zuerst)
    table.sort(backups, function(a, b)
        return a.timestamp > b.timestamp
    end)
    
    return backups
end

----------------------------------------------------
-- Core functions
----------------------------------------------------
local function NormalizeName(name)
    if not name then return "" end
    return string.lower(string.gsub(name, "^@", ""))
end

local function AddToBlacklist(accountName, note)
    if not accountName or accountName == "" then
        Debug("|cFF0000Error:|r No account name provided")
        return false
    end
    
    local key = NormalizeName(accountName)
    PugBlacklistDB[key] = note or ""
    
    Debug("Added |cFFA500@" .. key .. "|r to blacklist")
    if note and note ~= "" then
        Debug("Note: |c00FF00" .. note .. "|r")
    end
    
    return true
end

local function RemoveFromBlacklist(accountName)
    if not accountName then return false end
    
    local key = NormalizeName(accountName)
    if PugBlacklistDB[key] then
        PugBlacklistDB[key] = nil
        Debug("Removed |cFFA500@" .. key .. "|r from blacklist")
        return true
    else
        Debug("|cFFA500@" .. key .. "|r not found in blacklist")
        return false
    end
end

----------------------------------------------------
-- 1. VISUELLE WARNUNGEN
----------------------------------------------------
local warningControls = {}

local function CreateGroupWarningIndicator(unitTag)
    if not PugBlacklistSettings.showVisualIndicators then
        return
    end
    
    -- Finde das Gruppenfenster-Control
    local groupIndex = string.match(unitTag, "group(%d+)")
    if not groupIndex then return end
    
    -- Versuche verschiedene mögliche Control-Namen
    local controlNames = {
        "ZO_GroupMenu_Group"..groupIndex,
        "ZO_GroupMenuList"..groupIndex,
        "ZO_GroupMenuList1Row"..groupIndex,
        "GroupMenu_Group"..groupIndex
    }
    
    local parentControl
    for _, name in ipairs(controlNames) do
        parentControl = _G[name] or WINDOW_MANAGER:GetControlByName(name)
        if parentControl then break end
    end
    
    if not parentControl then return end
    
    -- Erstelle Warnungsindikator
    local indicator = WINDOW_MANAGER:CreateControl("PugBlacklist_Indicator_"..unitTag, parentControl, CT_TEXTURE)
    indicator:SetDimensions(16, 16)
    indicator:SetAnchor(RIGHT, parentControl, LEFT, -5, 0)
    indicator:SetTexture("/esoui/art/miscellaneous/warning_icon.dds")
    indicator:SetColor(1, 0, 0, 1) -- Rot
    indicator:SetHidden(true)
    
    warningControls[unitTag] = indicator
end

local function UpdateGroupVisuals()
    if not IsUnitGrouped("player") then return end
    
    local groupSize = GetGroupSize()
    for i = 1, groupSize do
        local unitTag = "group" .. i
        local accountName = GetUnitDisplayName(unitTag)
        
        if accountName then
            local key = NormalizeName(accountName)
            if PugBlacklistDB[key] then
                -- Erstelle Indikator falls nicht existiert
                if not warningControls[unitTag] then
                    CreateGroupWarningIndicator(unitTag)
                end
                
                -- Zeige Indikator
                if warningControls[unitTag] then
                    warningControls[unitTag]:SetHidden(false)
                end
                
                -- Chat-Benachrichtigung (wenn aktiviert)
                if PugBlacklistSettings.enableChatNotifications then
                    local charName = GetUnitName(unitTag) or "Unknown"
                    local note = PugBlacklistDB[key] or ""
                    local message = string.format("|cFF0000Blacklisted player in group:|r |c00FFFF%s|r (|cFFA500@%s|r)", 
                        charName, key)
                    if note ~= "" then
                        message = message .. " |c00FF00[" .. note .. "]|r"
                    end
                    
                    -- Nur einmal pro Session anzeigen
                    if not PugBlacklistSettings["notified_"..key] then
                        Debug(message)
                        PugBlacklistSettings["notified_"..key] = GetTimeStamp()
                    end
                end
            else
                -- Verstecke Indikator
                if warningControls[unitTag] then
                    warningControls[unitTag]:SetHidden(true)
                end
            end
        end
    end
end

----------------------------------------------------
-- 2. EINFACHES KONTEXTMENÜ (korrigiert)
----------------------------------------------------
local function AddContextMenuEntries()
    -- Event-Handler für Chat-Menü
    EVENT_MANAGER:RegisterForEvent("PugBlacklist_ChatMenu", EVENT_OPEN_CONTEXT_MENU, function(eventCode, contextType)
        if contextType == CONTEXT_MENU_CHAT then
            -- Kurze Verzögerung um sicherzustellen dass das Menü bereit ist
            zo_callLater(function()
                local targetName = GetChatMenuTargetName()
                if targetName and string.find(targetName, "@") then
                    -- Füge unsere Einträge hinzu
                    AddMenuItem("PugBlacklist: Add " .. targetName, function()
                        SCENE_MANAGER:Show('gameMenuInGame')
                        zo_callLater(function()
                            OpenGUI()
                            Debug("|c00FFFFUse the GUI to add " .. targetName .. " with a note|r")
                        end, 100)
                    end)
                    
                    AddMenuItem("PugBlacklist: Check " .. targetName, function()
                        local key = NormalizeName(targetName)
                        if PugBlacklistDB[key] then
                            local note = PugBlacklistDB[key] or ""
                            Debug("|cFF0000Player " .. targetName .. " is BLACKLISTED!|r")
                            if note ~= "" then
                                Debug("Note: |c00FF00" .. note .. "|r")
                            end
                        else
                            Debug("Player |cFFA500" .. targetName .. "|r is |c00FF00NOT blacklisted|r")
                        end
                    end)
                end
            end, 50)
        end
    end)
    
    Debug("Simple context menu system initialized")
end

----------------------------------------------------
-- 3. SUCHFELD IN GUI
----------------------------------------------------
local searchResults = {}
local function CreateSearchFunctionality(container)
    -- Suchfeld oben
    local searchBox = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)SearchBox", container, "ZO_DefaultEditForBackdrop")
    searchBox:SetDimensions(container:GetWidth() - 100, 30)
    searchBox:SetAnchor(TOPLEFT, container, TOPLEFT, 10, 10)
    searchBox:SetHandler("OnTextChanged", function(self)
        local searchText = self:GetText():lower()
        if searchText == "" then
            UpdateBlacklistDisplay()
        else
            -- Filtere Ergebnisse
            searchResults = {}
            local count = 0
            for accountName, note in pairs(PugBlacklistDB) do
                -- Ignoriere Backup-Einträge
                if not string.find(accountName, "^backup_") then
                    if string.find(accountName:lower(), searchText) or 
                       (note and string.find(note:lower(), searchText)) then
                        count = count + 1
                        searchResults[count] = {
                            text = "|cFFA500@" .. accountName .. "|r\n|c00FF00" .. (note or "") .. "|r",
                            account = accountName,
                            note = note or ""
                        }
                    end
                end
            end
            
            -- Sortiere
            table.sort(searchResults, function(a, b)
                return a.account < b.account
            end)
            
            -- Zeige Ergebnisse
            if blacklistScrollList then
                blacklistScrollList.data = searchResults
                if count == 0 then
                    blacklistScrollList.data[1] = {
                        text = "|cFFFF00No matching players found|r",
                        account = "",
                        note = ""
                    }
                end
                blacklistScrollList:Update()
            end
        end
    end)
    
    -- Suchfeld Label
    local searchLabel = WINDOW_MANAGER:CreateControl("$(parent)SearchLabel", container, CT_LABEL)
    searchLabel:SetDimensions(80, 30)
    searchLabel:SetAnchor(LEFT, searchBox, RIGHT, 10, 0)
    searchLabel:SetText("|c00FFFFSearch:|r")
    searchLabel:SetFont("ZoFontGame")
    searchLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    
    -- Clear Search Button
    local clearSearchBtn = WINDOW_MANAGER:CreateControl("$(parent)ClearSearchBtn", container, CT_BUTTON)
    clearSearchBtn:SetDimensions(80, 25)
    clearSearchBtn:SetAnchor(TOP, searchBox, BOTTOM, 0, 5)
    clearSearchBtn:SetText("|cFFFF00Clear Search|r")
    clearSearchBtn:SetFont("ZoFontGame")
    clearSearchBtn:SetHandler("OnClicked", function()
        searchBox:SetText("")
        UpdateBlacklistDisplay()
    end)
end

----------------------------------------------------
-- 4. CHAT-BENACHRICHTIGUNGEN
----------------------------------------------------
local function SetupChatNotifications()
    if not PugBlacklistSettings.enableChatNotifications then return end
    
    -- Spieler betritt Gruppe
    EVENT_MANAGER:RegisterForEvent("PugBlacklist_GroupUpdate", EVENT_GROUP_MEMBER_JOINED, function(eventCode, characterName, displayName)
        local key = NormalizeName(displayName)
        if PugBlacklistDB[key] then
            local note = PugBlacklistDB[key] or ""
            local message = string.format("|cFF0000BLACKLISTED PLAYER JOINED:|r\nCharacter: |c00FFFF%s|r\nAccount: |cFFA500@%s|r", 
                characterName, key)
            if note ~= "" then
                message = message .. "\nNote: |c00FF00" .. note .. "|r"
            end
            Debug(message)
        end
    end)
    
    -- Bei Gruppenwechsel
    EVENT_MANAGER:RegisterForEvent("PugBlacklist_GroupChanged", EVENT_GROUP_UPDATE, function()
        zo_callLater(UpdateGroupVisuals, 1000)
    end)
end

----------------------------------------------------
-- 5. BACKUP-FUNKTION (aktualisiert für ESO)
----------------------------------------------------
local function CreateBackup()
    local backupTime = GetTimeStamp()
    
    -- Erstelle Backup (in SavedVariables)
    local success, count = CreateBackupFile()
    
    if success then
        -- Erstelle zusätzlich internes Backup für schnelle Wiederherstellung
        local backupData = {}
        local backupCount = 0
        for account, note in pairs(PugBlacklistDB) do
            if not string.find(account, "^backup_") then -- Keine Backups sichern
                backupData[account] = note
                backupCount = backupCount + 1
            end
        end
        
        -- Serialisiere für internes Handling
        local serialized = ""
        for account, note in pairs(backupData) do
            serialized = serialized .. account .. "|||" .. (note or "") .. "\n"
        end
        
        -- Speichere in Settings für interne Wiederherstellung
        PugBlacklistSettings.lastBackup = backupTime
        PugBlacklistSettings.backupData = serialized
        
        Debug("|c00FF00Backup completed!|r")
        Debug("|c00FFFF" .. count .. " players backed up|r")
        
        return backupData
    else
        Debug("|cFF0000Backup failed!|r")
        return nil
    end
end

local function RestoreBackup()
    if not PugBlacklistSettings.backupData then
        Debug("|cFF0000No backup found!|r")
        return false
    end
    
    local restored = 0
    local lines = {}
    for line in string.gmatch(PugBlacklistSettings.backupData, "[^\n]+") do
        table.insert(lines, line)
    end
    
    for _, line in ipairs(lines) do
        local account, note = string.match(line, "(.+)|||(.+)")
        if account then
            if not PugBlacklistDB[account] then
                PugBlacklistDB[account] = note
                restored = restored + 1
            end
        end
    end
    
    Debug("|c00FF00Restored " .. restored .. " players from backup|r")
    return restored
end

local function CheckAutoBackup()
    if not PugBlacklistSettings.backupInterval or PugBlacklistSettings.backupInterval <= 0 then
        return
    end
    
    local currentTime = GetTimeStamp()
    local lastBackup = PugBlacklistSettings.lastBackup or 0
    
    -- Sicherstellen dass lastBackup eine gültige Zahl ist
    if lastBackup <= 0 then
        return
    end
    
    local daysSinceBackup = (currentTime - lastBackup) / 86400 -- Sekunden in Tage
    
    if daysSinceBackup >= PugBlacklistSettings.backupInterval then
        Debug("|cFFFF00Auto-backup triggered (after " .. math.floor(daysSinceBackup) .. " days)|r")
        CreateBackup()
    end
end

----------------------------------------------------
-- Erweiterte GUI-Funktionen
----------------------------------------------------
local blacklistContainer = nil
local blacklistScrollList = nil

local function UpdateBlacklistDisplay()
    if not blacklistScrollList then return end
    
    -- Clear old entries
    for i = 1, #blacklistScrollList.data do
        blacklistScrollList.data[i] = nil
    end
    
    -- Add new data
    local count = 0
    for accountName, note in pairs(PugBlacklistDB) do
        -- Ignoriere Backup-Einträge
        if not string.find(accountName, "^backup_") then
            count = count + 1
            local entryText = "|cFFA500@" .. accountName .. "|r"
            if note and note ~= "" then
                entryText = entryText .. "\n|c00FF00" .. note .. "|r"
            end
            
            blacklistScrollList.data[count] = {
                text = entryText,
                account = accountName,
                note = note or ""
            }
        end
    end
    
    -- Sort by account name
    table.sort(blacklistScrollList.data, function(a, b)
        return a.account < b.account
    end)
    
    -- If no entries, show "empty" message
    if count == 0 then
        blacklistScrollList.data[1] = {
            text = "|cFFFF00No players blacklisted|r",
            account = "",
            note = ""
        }
        count = 1
    end
    
    blacklistScrollList:Update()
end

----------------------------------------------------
-- NEU: Whisper-Funktion für den Autor
----------------------------------------------------
local function WhisperAuthor()
    local authorAccount = "@haze068"
    StartChatInput("", CHAT_CHANNEL_WHISPER, authorAccount)
    Debug("|c00FFFFWhispering author: " .. authorAccount .. "|r")
end

----------------------------------------------------
-- Existierende Funktionen (angepasst)
----------------------------------------------------
local function CheckPlayerInGroup(unitTag)
    if not unitTag then return false end
    
    local accountName = GetUnitDisplayName(unitTag)
    if not accountName then return false end
    
    local key = NormalizeName(accountName)
    if PugBlacklistDB[key] then
        local charName = GetUnitName(unitTag) or "Unknown"
        local note = PugBlacklistDB[key] or ""
        
        Debug("|cFF00FF========================================|r")
        Debug("|cFF0000BLACKLISTED PLAYER DETECTED|r")
        Debug("Character: |c00FFFF" .. charName .. "|r")
        Debug("Account: |cFFA500@" .. key .. "|r")
        if note ~= "" then
            Debug("Note: |c00FF00" .. note .. "|r")
        end
        Debug("|cFF00FF========================================|r")
        
        return true
    end
    
    return false
end

local function CheckCurrentGroup()
    if not IsUnitGrouped("player") then
        Debug("|cFFFF00You are not in a group|r")
        return false
    end
    
    local groupSize = GetGroupSize()
    Debug("Checking group with |c00FFFF" .. groupSize .. "|r members...")
    
    local found = false
    for i = 1, groupSize do
        if CheckPlayerInGroup("group" .. i) then
            found = true
        end
    end
    
    if not found then
        Debug("|c00FF00No blacklisted players in group|r")
    end
    
    return found
end

local function KickBlacklisted()
    if not IsUnitGrouped("player") then
        Debug("|cFFFF00You are not in a group|r")
        return 0
    end
    
    local kicked = 0
    local groupSize = GetGroupSize()
    
    for i = groupSize, 1, -1 do
        local unitTag = "group" .. i
        local accountName = GetUnitDisplayName(unitTag)
        
        if accountName then
            local key = NormalizeName(accountName)
            if PugBlacklistDB[key] then
                local charName = GetUnitName(unitTag) or "Unknown"
                Debug("Kicking |c00FFFF" .. charName .. "|r (|cFFA500@" .. key .. "|r)")
                GroupKick(unitTag)
                kicked = kicked + 1
            end
        end
    end
    
    if kicked > 0 then
        Debug("Kicked |c00FFFF" .. kicked .. "|r player(s)")
    else
        Debug("No blacklisted players to kick")
    end
    
    return kicked
end

local function ListBlacklisted()
    local count = 0
    
    for accountName, note in pairs(PugBlacklistDB) do
        if not string.find(accountName, "^backup_") then
            count = count + 1
            if note and note ~= "" then
                Debug("|cFFA500@" .. accountName .. "|r - |c00FF00" .. note .. "|r")
            else
                Debug("|cFFA500@" .. accountName .. "|r")
            end
        end
    end
    
    if count == 0 then
        Debug("|cFFFF00Blacklist is empty|r")
    else
        Debug("Total: |c00FFFF" .. count .. "|r player(s)")
    end
    
    return count
end

-- NEW FUNCTION: AddAllGroupMembers
local function AddAllGroupMembers()
    if not IsUnitGrouped("player") then
        Debug("|cFFFF00You are not in a group|r")
        return 0
    end
    
    local added = 0
    local groupSize = GetGroupSize()
    
    Debug("|cFF00FFAdding all group members to blacklist...|r")
    
    for i = 1, groupSize do
        local unitTag = "group" .. i
        
        -- Skip yourself
        if unitTag ~= "player" then
            local accountName = GetUnitDisplayName(unitTag)
            local charName = GetUnitName(unitTag)
            
            if accountName then
                local key = NormalizeName(accountName)
                if not PugBlacklistDB[key] then
                    local note = "Group member: " .. (charName or "Unknown")
                    PugBlacklistDB[key] = note
                    Debug("Added |cFFA500@" .. key .. "|r - " .. note)
                    added = added + 1
                else
                    Debug("|cFFA500@" .. key .. "|r already in blacklist")
                end
            end
        end
    end
    
    Debug("Added |c00FFFF" .. added .. "|r new player(s) to blacklist")
    return added
end

----------------------------------------------------
-- SLASH COMMANDS (erweitert)
----------------------------------------------------
local function ShowHelp()
    Debug("|cFF00FFAvailable commands:|r")
    Debug("|c00FFFF/pugblacklist add @Name [note]|r - Add player")
    Debug("|c00FFFF/pugblacklist remove @Name|r - Remove player")
    Debug("|c00FFFF/pugblacklist check|r - Check current group")
    Debug("|c00FFFF/pugblacklist kick|r - Kick blacklisted players")
    Debug("|c00FFFF/pugblacklist list|r - Show all blacklisted players")
    Debug("|c00FFFF/pugblacklist search @Name|r - Check specific player")
    Debug("|c00FFFF/pugblacklist clear|r - Clear entire blacklist")
    Debug("|c00FFFF/pugblacklist help|r - Show this help")
    Debug("|c00FFFF/pugblacklist addall|r - Add entire group to blacklist")
    Debug("|c00FFFF/pugblacklist backup|r - Create backup")
    Debug("|c00FFFF/pugblacklist restore|r - Restore from backup")
    Debug("|c00FFFF/pbl|r - Open GUI interface")
end

local function ProcessPugBlacklistCommand(param)
    if not param or param == "" then
        ShowHelp()
        return
    end
    
    local args = {}
    for arg in string.gmatch(param, "[^%s]+") do
        table.insert(args, arg)
    end
    
    local cmd = args[1]:lower()
    
    if cmd == "help" then
        ShowHelp()
        
    elseif cmd == "check" then
        CheckCurrentGroup()
        
    elseif cmd == "kick" then
        KickBlacklisted()
        
    elseif cmd == "list" then
        ListBlacklisted()
        
    elseif cmd == "add" then
        if args[2] then
            local account = args[2]
            local note = ""
            if args[3] then
                note = param:sub(param:find(args[3]))
            end
            AddToBlacklist(account, note)
        else
            Debug("Usage: /pugblacklist add @AccountName [note]")
        end
        
    elseif cmd == "remove" then
        if args[2] then
            RemoveFromBlacklist(args[2])
        else
            Debug("Usage: /pugblacklist remove @AccountName")
        end
        
    elseif cmd == "search" then
        if args[2] then
            local key = NormalizeName(args[2])
            if PugBlacklistDB[key] then
                local note = PugBlacklistDB[key] or ""
                Debug("|cFF0000Player @" .. key .. " is BLACKLISTED!|r")
                if note ~= "" then
                    Debug("Note: |c00FF00" .. note .. "|r")
                end
            else
                Debug("Player |cFFA500@" .. key .. "|r is |c00FF00NOT blacklisted|r")
            end
        else
            Debug("Usage: /pugblacklist search @AccountName")
        end
        
    elseif cmd == "clear" then
        local count = 0
        for accountName in pairs(PugBlacklistDB) do
            PugBlacklistDB[accountName] = nil
            count = count + 1
        end
        Debug("Cleared |c00FFFF" .. count .. "|r players from blacklist")
        
    elseif cmd == "addall" then
        AddAllGroupMembers()
        
    elseif cmd == "backup" then
        CreateBackup()
        
    elseif cmd == "restore" then
        RestoreBackup()
        Debug("|c00FF00Please reload UI to see restored players|r")
        
    elseif cmd == "test" then
        Debug("Addon is working correctly!")
        Debug("Blacklist entries: " .. ListBlacklisted())
        
    else
        Debug("Unknown command: |cFF0000" .. cmd .. "|r")
        ShowHelp()
    end
end

-- Function to open GUI
local function OpenGUI()
    if LibAddonMenu2 then
        LibAddonMenu2:OpenToPanel("PugBlacklistSettings")
        Debug("|c00FF00Opening Pug Blacklist GUI|r")
    else
        Debug("|cFFFF00LibAddonMenu-2.0 not found!|r")
        Debug("|cFFFF00Please install LibAddonMenu-2.0 from Minion or ESOUI.com|r")
    end
end

local function ProcessPBLCommand(param)
    -- /pbl opens the GUI regardless of parameters
    OpenGUI()
end

----------------------------------------------------
-- LibAddonMenu-2.0 Configuration (erweitert)
----------------------------------------------------
local function CreateSettingsMenu()
    if not LibAddonMenu2 then
        Debug("LibAddonMenu-2.0 not found! Install it from Minion or ESOUI.com")
        return
    end
    
    local panelData = {
        type = "panel",
        name = "Pug Blacklist",
        displayName = "|cFFA500Pug Blacklist|r",
        author = "Author: @haze068 | Discord: haze.3169",
        version = "2.0",
        slashCommand = "/pbl",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    
    local optionsTable = {
        {
            type = "header",
            name = "|cFF00FFInfo & Support|r",
            width = "full",
        },
        {
            type = "description",
            title = "|cFFA500Addon by @haze068|r",
            text = [[
|c00FFFFThank you for using PugBlacklist!|r

If you have questions, suggestions, or found a bug:
• Click the button below to whisper me in-game
• Contact me on Discord: |c00FFFFhaze.3169|r
• Leave feedback on ESOUI.com

|c00FF00Version 2.0 Features:|r
• Visual group warnings
• Context menu integration
• Search functionality
• Backup system (outputs to chat for manual saving)
• Enhanced GUI
            ]],
            width = "full",
        },
        {
            type = "button",
            name = "|c00FFFFWhisper @haze068|r",
            tooltip = "Send a whisper message to the addon author",
            func = function()
                WhisperAuthor()
            end,
            width = "full",
        },
        {
            type = "header",
            name = "|cFF00FFSettings|r",
            width = "full",
        },
        {
            type = "checkbox",
            name = "|c00FFFFEnable Group Warnings|r",
            tooltip = "Show warnings when blacklisted players are in group",
            getFunc = function() return PugBlacklistSettings.enableGroupWarnings end,
            setFunc = function(value) 
                PugBlacklistSettings.enableGroupWarnings = value
                if value then
                    UpdateGroupVisuals()
                else
                    -- Verstecke alle Indikatoren
                    for _, control in pairs(warningControls) do
                        if control then
                            control:SetHidden(true)
                        end
                    end
                end
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "|c00FFFFEnable Chat Notifications|r",
            tooltip = "Show chat notifications for blacklisted players",
            getFunc = function() return PugBlacklistSettings.enableChatNotifications end,
            setFunc = function(value) 
                PugBlacklistSettings.enableChatNotifications = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "|c00FFFFShow Visual Indicators|r",
            tooltip = "Show warning icons in group window",
            getFunc = function() return PugBlacklistSettings.showVisualIndicators end,
            setFunc = function(value) 
                PugBlacklistSettings.showVisualIndicators = value
                UpdateGroupVisuals()
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "|c00FFFFAuto-Backup Interval (days)|r",
            tooltip = "Automatically create backups after X days (0 = disabled)",
            min = 0,
            max = 30,
            step = 1,
            getFunc = function() return PugBlacklistSettings.backupInterval or 7 end,
            setFunc = function(value) 
                PugBlacklistSettings.backupInterval = value
            end,
            width = "full",
        },
        {
            type = "header",
            name = "|cFF00FFQuick Actions|r",
            width = "full",
        },
        {
            type = "button",
            name = "|c00FFFFCheck Current Group|r",
            tooltip = "Check if any group members are blacklisted",
            func = function()
                CheckCurrentGroup()
            end,
            width = "half",
        },
        {
            type = "button",
            name = "|cFF0000Kick Blacklisted|r",
            tooltip = "Kick all blacklisted players from current group",
            func = function()
                KickBlacklisted()
            end,
            width = "half",
        },
        {
            type = "button",
            name = "|cFFA500Create Backup|r",
            tooltip = "Create a backup (outputs to chat for manual saving)",
            func = function()
                CreateBackup()
            end,
            width = "half",
        },
        {
            type = "button",
            name = "|c00FF00Restore Backup|r",
            tooltip = "Restore from last backup",
            func = function()
                RestoreBackup()
                zo_callLater(UpdateBlacklistDisplay, 100)
            end,
            width = "half",
        },
        {
            type = "button",
            name = "|cFFA500Add Whole Group to Blacklist|r",
            tooltip = "Add all current group members to blacklist",
            func = function()
                AddAllGroupMembers()
                zo_callLater(UpdateBlacklistDisplay, 100)
            end,
            width = "full",
            warning = "This will add everyone except yourself!",
        },
        {
            type = "header",
            name = "|cFF00FFBlacklisted Players|r",
            width = "full",
        },
        {
            type = "custom",
            reference = "PugBlacklist_BlacklistContainer",
            width = "full",
            height = 300,
            func = function(container)
                blacklistContainer = container
                
                -- Suchfunktionalität hinzufügen
                CreateSearchFunctionality(container)
                
                -- Scroll Liste Position anpassen (unter Suchfeld)
                local scrollListContainer = WINDOW_MANAGER:CreateControl("$(parent)ScrollContainer", container, CT_CONTROL)
                scrollListContainer:SetDimensions(container:GetWidth() - 20, 200)
                scrollListContainer:SetAnchor(TOP, container, TOP, 0, 50)
                scrollListContainer:SetAnchor(BOTTOM, container, BOTTOM, 0, -40)
                
                -- Create scroll list
                local scrollData = {
                    name = "PugBlacklistScrollList",
                    parent = scrollListContainer,
                    width = scrollListContainer:GetWidth(),
                    height = scrollListContainer:GetHeight(),
                    rowHeight = 40,
                    data = {},
                    setup = function(rowControl, data)
                        rowControl:GetNamedChild("Text"):SetText(data.text)
                        rowControl:GetNamedChild("Text"):SetHeight(40)
                        rowControl:GetNamedChild("Text"):SetVerticalAlignment(TEXT_ALIGN_TOP)
                        rowControl:GetNamedChild("Text"):SetHorizontalAlignment(TEXT_ALIGN_LEFT)
                        rowControl:GetNamedChild("Text"):SetFont("ZoFontGame")
                        
                        -- Remove button for each entry
                        if data.account ~= "" then
                            local removeBtn = WINDOW_MANAGER:CreateControl("$(parent)RemoveBtn", rowControl, CT_BUTTON)
                            removeBtn:SetDimensions(80, 25)
                            removeBtn:SetAnchor(RIGHT, rowControl, RIGHT, -5, 0)
                            removeBtn:SetText("|cFF0000Remove|r")
                            removeBtn:SetFont("ZoFontGame")
                            removeBtn:SetHandler("OnClicked", function()
                                RemoveFromBlacklist("@" .. data.account)
                                zo_callLater(UpdateBlacklistDisplay, 100)
                            end)
                        end
                    end
                }
                
                blacklistScrollList = LAMCreateControl.scrolllist(scrollListContainer, scrollData)
                blacklistScrollList:SetAnchorFill(scrollListContainer)
                
                -- Update button
                local updateBtn = WINDOW_MANAGER:CreateControl("$(parent)UpdateBtn", container, CT_BUTTON)
                updateBtn:SetDimensions(100, 25)
                updateBtn:SetAnchor(BOTTOMLEFT, container, BOTTOMLEFT, 10, -5)
                updateBtn:SetText("|c00FFFFRefresh List|r")
                updateBtn:SetFont("ZoFontGame")
                updateBtn:SetHandler("OnClicked", UpdateBlacklistDisplay)
                
                -- Count display
                local countLabel = WINDOW_MANAGER:CreateControl("$(parent)CountLabel", container, CT_LABEL)
                countLabel:SetDimensions(150, 25)
                countLabel:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, -10, -5)
                countLabel:SetFont("ZoFontGame")
                countLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
                
                -- Initial update
                zo_callLater(function()
                    UpdateBlacklistDisplay()
                    local count = 0
                    for account in pairs(PugBlacklistDB) do
                        if not string.find(account, "^backup_") then
                            count = count + 1
                        end
                    end
                    countLabel:SetText("|cFFA500Total:|r |c00FFFF" .. count .. "|r player(s)")
                end, 50)
            end
        },
        {
            type = "header",
            name = "|cFF00FFAdd Player|r",
            width = "full",
        },
        {
            type = "editbox",
            name = "|cFFA500Account Name|r",
            tooltip = "Enter account name starting with @",
            getFunc = function() return "" end,
            setFunc = function(value)
                if value and value ~= "" then
                    PugBlacklistSettings.lastAccount = value
                end
            end,
            width = "half",
        },
        {
            type = "editbox",
            name = "|c00FF00Note|r",
            tooltip = "Optional note for this player",
            getFunc = function() return "" end,
            setFunc = function(value)
                local account = PugBlacklistSettings.lastAccount or ""
                if account ~= "" then
                    AddToBlacklist(account, value)
                    zo_callLater(UpdateBlacklistDisplay, 100)
                    PugBlacklistSettings.lastAccount = nil
                end
            end,
            width = "half",
        },
    }
    
    LibAddonMenu2:RegisterAddonPanel("PugBlacklistSettings", panelData)
    LibAddonMenu2:RegisterOptionControls("PugBlacklistSettings", optionsTable)
    
    Debug("Enhanced settings menu created")
end

----------------------------------------------------
-- Addon Initialization (korrigiert)
----------------------------------------------------
local function Initialize()
    -- NEUE: Willkommensnachricht beim Laden
    d("|cFF00FF========================================|r")
    d("|cFFA500PugBlacklist v2.0 loaded|r")
    d("|c00FFFFAddon by @haze068 | Discord: haze.3169|r")
    d("|cFF00FF========================================|r")
    
    Debug("|cFFA500PugBlacklist v2.0 INITIALIZING|r")
    
    -- Slash Commands
    SLASH_COMMANDS["/pugblacklist"] = ProcessPugBlacklistCommand
    SLASH_COMMANDS["/pbl"] = ProcessPBLCommand
    
    -- Neue Features initialisieren
    AddContextMenuEntries()
    SetupChatNotifications()
    CheckAutoBackup()
    
    -- Periodische Gruppenüberprüfung
    EVENT_MANAGER:RegisterForUpdate("PugBlacklist_GroupCheck", 5000, function()
        if IsUnitGrouped("player") and PugBlacklistSettings.enableGroupWarnings then
            UpdateGroupVisuals()
        end
    end)
    
    -- LibAddonMenu Settings
    CreateSettingsMenu()
    
    -- Status
    local count = 0
    for account in pairs(PugBlacklistDB) do
        if not string.find(account, "^backup_") then
            count = count + 1
        end
    end
    
    Debug("Blacklist contains |c00FFFF" .. count .. "|r player(s)")
    
    -- Letztes Backup anzeigen (mit nil-Check)
    local lastBackup = PugBlacklistSettings.lastBackup or 0
    if lastBackup > 0 then
        local days = math.floor((GetTimeStamp() - lastBackup) / 86400)
        Debug("Last backup: |c00FF00" .. days .. "|r days ago")
    end
    
    Debug("|c00FF00PugBlacklist READY!|r")
    Debug("Type |c00FFFF/pugblacklist help|r for commands")
    Debug("Type |c00FFFF/pbl|r for UI")
end

----------------------------------------------------
-- Addon Loading
----------------------------------------------------
local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= "PugBlacklist" then return end
    
    EVENT_MANAGER:UnregisterForEvent("PugBlacklist_Load", EVENT_ADD_ON_LOADED)
    
    Debug("Addon loaded successfully")
    
    zo_callLater(Initialize, 500)
end

EVENT_MANAGER:RegisterForEvent("PugBlacklist_Load", EVENT_ADD_ON_LOADED, OnAddonLoaded)

-- Fallback
zo_callLater(function()
    if not SLASH_COMMANDS["/pbl"] then
        Debug("Using fallback initialization...")
        Initialize()
    end
end, 3000)
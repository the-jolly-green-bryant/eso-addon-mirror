-------------------------------------------------------------------------------
-- Pit's Zenkosh Tracker - Optionsmenue und Slash-Befehle
--
-- Anklickbares Menue ueber LibAddonMenu-2.0. Fehlt die Bibliothek, laeuft das
-- Addon trotzdem, dann eben nur ueber /zenkosh.
-------------------------------------------------------------------------------

local A  = PitsZenkoshTracker
local UI = A.UI

local panel

-- Keyboard-Symbolpfade der acht Zielmarker (aus dem ESO-Quellcode)
local MARKER_ICONS = {
    [TARGET_MARKER_TYPE_ONE]   = "EsoUI/Art/TargetMarkers/Target_Blue_Square_64.dds",
    [TARGET_MARKER_TYPE_TWO]   = "EsoUI/Art/TargetMarkers/Target_Gold_Star_64.dds",
    [TARGET_MARKER_TYPE_THREE] = "EsoUI/Art/TargetMarkers/Target_Green_Circle_64.dds",
    [TARGET_MARKER_TYPE_FOUR]  = "EsoUI/Art/TargetMarkers/Target_Orange_Triangle_64.dds",
    [TARGET_MARKER_TYPE_FIVE]  = "EsoUI/Art/TargetMarkers/Target_Pink_Moons_64.dds",
    [TARGET_MARKER_TYPE_SIX]   = "EsoUI/Art/TargetMarkers/Target_Purple_Oblivion_64.dds",
    [TARGET_MARKER_TYPE_SEVEN] = "EsoUI/Art/TargetMarkers/Target_Red_Weapons_64.dds",
    [TARGET_MARKER_TYPE_EIGHT] = "EsoUI/Art/TargetMarkers/Target_White_Skull_64.dds",
}

local function MarkerIcon(m)
    if ZO_GetPlatformTargetMarkerIcon then
        local ic = ZO_GetPlatformTargetMarkerIcon(m)
        if ic then return ic end
    end
    return MARKER_ICONS[m]
end

-- Icon-Pfade und Namen aller acht Marker, plus Rueckabbildung Pfad -> Typ
local function MarkerIconChoices()
    local icons, tips, byIcon = {}, {}, {}
    for m = TARGET_MARKER_TYPE_ONE, TARGET_MARKER_TYPE_EIGHT do
        local ic = MarkerIcon(m)
        table.insert(icons, ic)
        table.insert(tips, A.MARKER_NAMES[m])
        byIcon[ic] = m
    end
    return icons, tips, byIcon
end

-- Ein Symbol nur einmal im Pool: kollidiert die neue Wahl mit dem anderen
-- Slot, tauschen die beiden, statt einen toten Doppel-Slot zu erzeugen.
local function SetPoolSlot(slot, markerType)
    local pool  = A.sv.pool
    local other = slot == 1 and 2 or 1
    if pool[other] == markerType then pool[other] = pool[slot] end
    pool[slot] = markerType
    A.ResetMarkerOwners()
end

-------------------------------------------------------------------------------
-- LibAddonMenu-Panel
-------------------------------------------------------------------------------

local function BuildPanel()
    if panel then return true end
    local LAM = LibAddonMenu2
    if not LAM then return false end

    local icons, tips, byIcon = MarkerIconChoices()

    panel = LAM:RegisterAddonPanel("PitsZenkoshTrackerOptions", {
        type                = "panel",
        name                = "Pit's Zenkosh Tracker",
        displayName         = "Pit's Zenkosh Tracker",
        author              = "@petethepower",
        version             = A.version,
        registerForRefresh  = true,
        registerForDefaults = true,
    })

    LAM:RegisterOptionControls("PitsZenkoshTrackerOptions", {
        {
            type = "description",
            text = "|cFFD37APit's Zenkosh Tracker|r - Idee und Name von |cFFFFFF@petethepower|r. " ..
                   "Danke fuers Testen und die Ideen!\n\n" ..
                   "Setzt Zielmarker auf Gegner mit deinem Alkosh und zeigt Alkosh + " ..
                   "Touch of Z'en (mit Stacks) im Timer-Fenster. Marker sind gruppenweit " ..
                   "sichtbar - im Progress vorher kurz ansagen.",
        },

        { type = "header", name = "Zielmarker" },
        {
            type    = "checkbox",
            name    = "Marker setzen",
            tooltip = "Setzt einen Zielmarker auf Gegner, solange dein Alkosh auf ihnen liegt.",
            getFunc = function() return A.sv.enabled end,
            setFunc = function(v) A.sv.enabled = v end,
            default = A.defaults.enabled,
        },
        {
            type     = "checkbox",
            name     = "Adds ebenfalls markieren",
            tooltip  = "Aus: nur Bosse (Bossleiste, ersatzweise Schwierigkeit \"toedlich\").",
            getFunc  = function() return A.sv.markAdds end,
            setFunc  = function(v) A.sv.markAdds = v end,
            default  = A.defaults.markAdds,
            disabled = function() return not A.sv.enabled end,
        },
        {
            type     = "iconpicker",
            name     = "Symbol fuer das erste Ziel",
            tooltip  = "Waehle das Zielmarker-Symbol.",
            choices        = icons,
            choicesTooltips = tips,
            iconSize   = 32,
            maxColumns = 4,
            visibleRows = 2,
            getFunc  = function() return MarkerIcon(A.sv.pool[1] or TARGET_MARKER_TYPE_SEVEN) end,
            setFunc  = function(ic) SetPoolSlot(1, byIcon[ic] or TARGET_MARKER_TYPE_SEVEN) end,
            default  = MarkerIcon(A.defaults.pool[1]),
            disabled = function() return not A.sv.enabled end,
        },
        {
            type     = "checkbox",
            name     = "Zweites Symbol nutzen",
            tooltip  = "Ein Ultimate debufft oft mehrere Gegner gleichzeitig (Boss + Mini). " ..
                       "Ein Symbol kann nur an einem Gegner haengen, daher ein zweites.",
            getFunc  = function() return A.sv.useSecond end,
            setFunc  = function(v) A.sv.useSecond = v; A.ResetMarkerOwners() end,
            default  = A.defaults.useSecond,
            disabled = function() return not A.sv.enabled end,
        },
        {
            type     = "iconpicker",
            name     = "Symbol fuer das zweite Ziel",
            choices        = icons,
            choicesTooltips = tips,
            iconSize   = 32,
            maxColumns = 4,
            visibleRows = 2,
            getFunc  = function() return MarkerIcon(A.sv.pool[2] or TARGET_MARKER_TYPE_SIX) end,
            setFunc  = function(ic) SetPoolSlot(2, byIcon[ic] or TARGET_MARKER_TYPE_SIX) end,
            default  = MarkerIcon(A.defaults.pool[2]),
            disabled = function() return not A.sv.enabled or not A.sv.useSecond end,
        },
        {
            type     = "checkbox",
            name     = "Nur in Dungeons und Trials",
            tooltip  = "Verhindert, dass im Overland wahllos markiert wird.",
            getFunc  = function() return A.sv.onlyInstances end,
            setFunc  = function(v) A.sv.onlyInstances = v end,
            default  = A.defaults.onlyInstances,
            disabled = function() return not A.sv.enabled end,
        },

        { type = "header", name = "Timer-Fenster" },
        {
            type    = "checkbox",
            name    = "Fenster anzeigen",
            tooltip = "Zeigt Alkosh und Touch of Z'en je Gegner. Blendet sich aus, wenn nichts laeuft.",
            getFunc = function() return A.sv.ui.show end,
            setFunc = function(v) A.sv.ui.show = v; UI.ApplyVisibility() end,
            default = A.defaults.ui.show,
        },
        {
            type    = "checkbox",
            name    = "Touch of Z'en mit anzeigen",
            tooltip = "Zweite Leiste je Gegner mit der Touch-of-Z'en-Restzeit und der Stack-Zahl.",
            getFunc = function() return A.sv.ui.showZen end,
            setFunc = function(v)
                A.sv.ui.showZen = v
                A.RegisterEffectEvents()
                UI.ApplyLayout()
            end,
            default = A.defaults.ui.showZen,
        },
        {
            type    = "checkbox",
            name    = "Rote Warnung bei Boss-Ablauf",
            tooltip = "Wenn der Alkosh eines Bosses ausgeht, blinkt fuer 5s eine rote Warnung " ..
                      "an der Stelle der Leiste - zum sofortigen Nachlegen.",
            getFunc = function() return A.sv.ui.expiryWarning end,
            setFunc = function(v) A.sv.ui.expiryWarning = v end,
            default = A.defaults.ui.expiryWarning,
        },
        {
            type    = "checkbox",
            name    = "Fenster gesperrt",
            tooltip = "Entsperrt kannst du es verschieben und an der Ecke groesser/kleiner ziehen.",
            getFunc = function() return A.sv.ui.locked end,
            setFunc = function(v) A.sv.ui.locked = v; UI.ApplyLock() end,
            default = A.defaults.ui.locked,
        },
        {
            type     = "slider",
            name     = "Groesse",
            tooltip  = "Geht auch direkt am Fenster: entsperren und die Ecke ziehen.",
            min = 50, max = 300, step = 5,
            getFunc  = function() return math.floor((A.sv.ui.scale or 1) * 100 + 0.5) end,
            setFunc  = function(v) UI.SetScale(v / 100) end,
            default  = 100,
        },
        {
            type    = "slider",
            name    = "Maximale Zeilen",
            min = 1, max = 10, step = 1,
            getFunc = function() return A.sv.ui.maxRows end,
            setFunc = function(v) A.sv.ui.maxRows = v; UI.ApplyLayout() end,
            default = A.defaults.ui.maxRows,
        },
        {
            type    = "checkbox",
            name    = "Nur Bosse im Fenster",
            tooltip = "Blendet Adds im Timer-Fenster aus. Wirkt nicht auf die Marker.",
            getFunc = function() return A.sv.ui.bossOnly end,
            setFunc = function(v) A.sv.ui.bossOnly = v end,
            default = A.defaults.ui.bossOnly,
        },
        {
            type = "button",
            name = "Position zuruecksetzen",
            func = function() UI.ResetPosition() end,
        },

        { type = "header", name = "Diagnose" },
        {
            type    = "checkbox",
            name    = "Alkosh von Mitspielern mitzaehlen",
            tooltip = "Aus: nur dein eigenes Alkosh zaehlt.",
            getFunc = function() return A.sv.includeGroup end,
            setFunc = function(v) A.sv.includeGroup = v; A.RegisterEffectEvents() end,
            default = A.defaults.includeGroup,
        },
        {
            type    = "description",
            text    = function()
                return "Z'en-Stacks: " .. (A.zenStackSource or "?") ..
                       "   (LibCombat = exakt, DoT-Zaehlung = Schaetzung)"
            end,
        },
        {
            type    = "checkbox",
            name    = "Debug-Ausgaben im Chat",
            getFunc = function() return A.sv.debug end,
            setFunc = function(v) A.sv.debug = v end,
            default = A.defaults.debug,
        },
        {
            type = "button",
            name = "Aktuelles Ziel pruefen",
            func = function() A.PrintTargetReport() end,
        },
    })

    return true
end

-------------------------------------------------------------------------------
-- Slash-Befehle
-------------------------------------------------------------------------------

function A.PrintTargetReport()
    if not DoesUnitExist("reticleover") then
        A.Msg("Kein Ziel unterm Fadenkreuz.")
        return
    end
    local wanted, untilMs, source = A.IsAlkoshOnReticle()
    local name = A.CleanName(GetUnitName("reticleover"))

    A.Msg("Ziel: %s | Boss: %s | feindlich: %s | Marker: %s",
        name,
        A.IsBossName(name) and "ja (Bossleiste)" or "nein",
        GetUnitReaction("reticleover") == UNIT_REACTION_HOSTILE and "ja" or "nein",
        tostring(GetUnitTargetMarkerType("reticleover")))

    local _, maxHp = GetUnitPower("reticleover", POWERTYPE_HEALTH)
    A.Msg("Schwierigkeit: %d | max. Leben: %d | Warnung (wichtig): %s",
        GetUnitDifficulty("reticleover"), maxHp or 0,
        (A.IsReticleImportant and A.IsReticleImportant()) and "ja" or "nein")
    A.Msg("Alkosh erkannt: %s%s", wanted and "JA" or "nein",
        source and string.format(" (ueber %s, noch %.1fs)", source,
            (untilMs - GetGameTimeMilliseconds()) / 1000) or "")

    local owners = A.GetMarkerOwners()
    for _, m in ipairs(A.ActivePool()) do
        local o = owners[m]
        A.Msg("  Marker %d: %s", m, o and o.name or "frei")
    end
end

local function PrintHelp()
    A.Msg("Befehle:")
    d("  /zenkosh                     - Optionsmenue oeffnen")
    d("  /zenkosh on | off            - Marker an/aus")
    d("  /zenkosh adds                - Adds mitmarkieren an/aus")
    d("  /zenkosh marker 7 6          - Symbole 1-8 (zweites optional)")
    d("  /zenkosh zen                 - Touch of Z'en im Fenster an/aus")
    d("  /zenkosh fenster             - Timer-Fenster an/aus")
    d("  /zenkosh lock                - Fenster sperren/entsperren")
    d("  /zenkosh groesse 50-300      - Fenstergroesse in Prozent")
    d("  /zenkosh reset               - Fensterposition zuruecksetzen")
    d("  /zenkosh clear               - Marker vom aktuellen Ziel nehmen")
    d("  /zenkosh test | status | debug")
    d("  (/alkosh geht weiterhin als Kurzform)")
end

local function PrintStatus()
    local pool = {}
    for _, m in ipairs(A.ActivePool()) do table.insert(pool, A.MARKER_NAMES[m] or tostring(m)) end

    A.Msg("Version %s | Marker: %s", A.version, A.sv.enabled and "an" or "aus")
    A.Msg("Marker: %s | Adds: %s | nur Instanzen: %s",
        table.concat(pool, ", "),
        A.sv.markAdds and "ja" or "nein",
        A.sv.onlyInstances and "ja" or "nein")
    A.Msg("Fenster: %s | gesperrt: %s | Groesse: %d%% | Zeilen: %d | nur Bosse: %s",
        A.sv.ui.show and "an" or "aus",
        A.sv.ui.locked and "ja" or "nein",
        math.floor((A.sv.ui.scale or 1) * 100 + 0.5),
        A.sv.ui.maxRows,
        A.sv.ui.bossOnly and "ja" or "nein")
    A.Msg("Z'en: %s (Stacks: %s) | Boss-Warnung: %s",
        A.sv.ui.showZen and "an" or "aus",
        A.zenStackSource or "?",
        A.sv.ui.expiryWarning and "an" or "aus")

    if UI and UI.Diagnose then
        A.Msg("Fenster-Status: %s", UI.Diagnose())
    else
        A.Msg("Fenster-Status: PitsZenkoshTrackerUI.lua nicht geladen - liegen alle drei " ..
              ".lua-Dateien im Ordner und steht die neue .txt daneben?")
    end
    A.Msg("Menue: %s", panel and "registriert (ESC > Einstellungen > Addons)"
                             or "nicht registriert, LibAddonMenu-2.0 fehlt")
end

local function HandleSlash(args)
    local cmd, param = string.match(zo_strlower(args or ""), "^%s*(%S*)%s*(.-)%s*$")

    if cmd == "" then
        if BuildPanel() then
            LibAddonMenu2:OpenToPanel(panel)
        else
            A.Msg("LibAddonMenu-2.0 nicht gefunden - ohne sie gibt es kein Menue.")
            A.Msg("Sie muss als eigenes Addon im AddOns-Ordner liegen, nicht nur im " ..
                  "libs-Ordner eines anderen Addons.")
            PrintHelp()
        end
    elseif cmd == "help" then
        PrintHelp()
    elseif cmd == "on" then
        A.sv.enabled = true;  A.Msg("Marker an")
    elseif cmd == "off" then
        A.sv.enabled = false; A.Msg("Marker aus")
    elseif cmd == "adds" then
        A.sv.markAdds = not A.sv.markAdds
        A.Msg("Adds mitmarkieren: %s", A.sv.markAdds and "ja" or "nein")
    elseif cmd == "zen" then
        A.sv.ui.showZen = not A.sv.ui.showZen
        A.RegisterEffectEvents()
        if UI.ApplyLayout then UI.ApplyLayout() end
        A.Msg("Touch of Z'en im Fenster: %s (Stacks: %s)",
            A.sv.ui.showZen and "an" or "aus", A.zenStackSource)
    elseif cmd == "fenster" then
        A.sv.ui.show = not A.sv.ui.show
        UI.ApplyVisibility()
        A.Msg("Timer-Fenster: %s", A.sv.ui.show and "an" or "aus")
    elseif cmd == "lock" then
        A.sv.ui.locked = not A.sv.ui.locked
        UI.ApplyLock()
        A.Msg("Fenster %s", A.sv.ui.locked and "gesperrt" or "entsperrt - verschiebbar, Ecke ziehen fuer Groesse")
    elseif cmd == "groesse" or cmd == "grosse" then
        local n = tonumber(param)
        if n then
            UI.SetScale(n / 100)
            A.Msg("Groesse: %d%%", math.floor(A.sv.ui.scale * 100 + 0.5))
        else
            A.Msg("Bitte eine Zahl zwischen 50 und 300 angeben.")
        end
    elseif cmd == "reset" then
        UI.ResetPosition()
        A.Msg("Fensterposition zurueckgesetzt.")
    elseif cmd == "marker" then
        local slot = 0
        for digits in string.gmatch(param, "%d+") do
            local m = tonumber(digits)
            if A.MARKER_NAMES[m] and m ~= TARGET_MARKER_TYPE_NONE then
                slot = slot + 1
                if slot <= 2 then SetPoolSlot(slot, m) end
            end
        end
        if slot >= 1 then
            A.sv.useSecond = slot >= 2
            PrintStatus()
        else
            A.Msg("Bitte Symbole 1-8 angeben, z.B. /zenkosh marker 7 6")
        end
    elseif cmd == "clear" then
        if DoesUnitExist("reticleover") then
            local current = GetUnitTargetMarkerType("reticleover")
            AssignTargetMarkerToReticleTarget(current)
            A.GetMarkerOwners()[current] = nil
            A.Msg("Marker vom Ziel genommen (falls einer drauf war).")
        else
            A.Msg("Kein Ziel unterm Fadenkreuz.")
        end
    elseif cmd == "test" then
        A.PrintTargetReport()
    elseif cmd == "debug" then
        A.sv.debug = not A.sv.debug
        A.Msg("Debug: %s", A.sv.debug and "an" or "aus")
    elseif cmd == "status" then
        PrintStatus()
    else
        PrintHelp()
    end
end

function A.InitSettings()
    SLASH_COMMANDS["/zenkosh"] = HandleSlash
    SLASH_COMMANDS["/alkosh"]  = HandleSlash   -- alter Befehl bleibt als Kurzform

    if BuildPanel() then return end
    EVENT_MANAGER:RegisterForEvent(A.name .. "_lam", EVENT_PLAYER_ACTIVATED, function()
        if BuildPanel() then
            EVENT_MANAGER:UnregisterForEvent(A.name .. "_lam", EVENT_PLAYER_ACTIVATED)
        end
    end)
end

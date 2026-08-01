-- ============================================================================
--  DsRGuildPvP Crown Arrow (mit LibGPS3)
-- ============================================================================

DsRGuildPvPCrown = DsRGuildPvPCrown or {}
local PvPCrown = DsRGuildPvPCrown

local GPS = LibGPS3

PvPCrown.hiddenShortly = false

------------------------------------------------------------
-- UI automatisch ausblenden, wenn Menüs geöffnet sind
------------------------------------------------------------
local function UpdateUIVisibility(hidden)
    PvPCrown.hiddenShortly = hidden

    if PvPCrown.hiddenShortly then
        if PvPCrown.IsInPvP() and DsRGuildPvP.pvp.PvPCrownEnabled then
            PvPCrown.ui:SetHidden(true)
        end
    else
        if PvPCrown.IsInPvP() and DsRGuildPvP.pvp.PvPCrownEnabled then
            PvPCrown.ui:SetHidden(false)
        end
    end
end

------------------------------------------------------------
-- PvP Status Check
------------------------------------------------------------
function PvPCrown.IsInPvP()
    if IsActiveWorldBattleground() then return false end
    if IsPlayerInAvAWorld() then return true end
    return false
end

-- ============================================================================
--  UI: Pfeil erstellen
-- ============================================================================
function CreateArrow()
    if not PvPCrown.IsInPvP() then return end

    if PvPCrown.ui and PvPCrown.tex then
        PvPCrown.ui:SetDimensions(
            DsRGuildPvP.pvp.PvPCrownArrowSize,
            DsRGuildPvP.pvp.PvPCrownArrowSize
        )
        PvPCrown.ui:SetHidden(not DsRGuildPvP.pvp.PvPCrownEnabled)
        PvPCrown.tex:SetColor(0, 1, 0, 1)
        return
    end

    local ui = WINDOW_MANAGER:CreateTopLevelWindow("DsR_CrownArrow")
    ui:SetDimensions(
        DsRGuildPvP.pvp.PvPCrownArrowSize,
        DsRGuildPvP.pvp.PvPCrownArrowSize
    )
    ui:SetAnchor(CENTER, GuiRoot, CENTER, 0.1, DsRGuildPvP.pvp.PvPCrownArrowPos + 0.1)
    ui:SetMouseEnabled(false)
    ui:SetMovable(false)
    ui:SetHidden(not DsRGuildPvP.pvp.PvPCrownEnabled)

    local tex = WINDOW_MANAGER:CreateControl("$(parent)Texture", ui, CT_TEXTURE)
    tex:SetAnchorFill()
    tex:SetTexture("/DsRGuildHall/misc/Crownpfeil.dds")
    tex:SetColor(0, 1, 0, 1)
    tex:SetTextureCoords(0, 1, 0, 1)
    tex:SetTextureRotation(0, 0.5, 0.5)

    PvPCrown.ui = ui
    PvPCrown.tex = tex
end

-- ============================================================================
--  Hilfsfunktionen: Positionen und Vektoren (LibGPS3)
-- ============================================================================
local function GetPlayerWorldPosition()
    local x, y = GetMapPlayerPosition("player")
    return GPS:LocalToGlobal(x, y)
end

local function GetCrownWorldPosition()
    if DsRGuildPvP.pvp.PvPCrownDebug then
        return 0.61083439508293, 0.42402521103659
    end

    if not IsUnitGroupLeader("player") then
        for i = 1, GROUP_SIZE_MAX do
            local tag = "group" .. i
            if DoesUnitExist(tag) and IsUnitGroupLeader(tag) then
                local x, y = GetMapPlayerPosition(tag)
                if x ~= 0 and y ~= 0 then
                    return GPS:LocalToGlobal(x, y)
                end
            end
        end
    end

    if IsUnitGroupLeader("player") then
        for i = 1, GROUP_SIZE_MAX do
            local tag = "group" .. i
            if DoesUnitExist(tag) and IsUnitGroupLeader(tag) then
                local x, y = GetMapPlayerPosition(tag)
                if x ~= 0 and y ~= 0 then
                    return GPS:LocalToGlobal(x, y)
                end
            end
        end
    end

    return nil
end

local function GetDistanceToCrown()
    local px, py = GetPlayerWorldPosition()
    local cx, cy = GetCrownWorldPosition()
    if not cx then return nil end

    local dx = cx - px
    local dy = cy - py

    return math.sqrt(dx * dx + dy * dy), dx, dy
end

local function GetAngleToCrown()
    local px, py = GetPlayerWorldPosition()
    local cx, cy = GetCrownWorldPosition()
    if not cx then return nil end

    local dx = cx - px
    local dy = cy - py

    local angleToCrown = math.atan2(dx, dy)
    local heading = GetPlayerCameraHeading()

    local angle = (angleToCrown - heading) % (2 * math.pi)

    return angle, angleToCrown, heading, dx, dy
end

-- ============================================================================
--  Entfernung pro Gruppenmitglied (für Liste)
-- ============================================================================
local function GetDistanceToCrownForUnit(tag)
    local x, y = GetMapPlayerPosition(tag)
    if x == 0 or y == 0 then return nil end

    local cx, cy = GetCrownWorldPosition()

    if not cx then return nil end

    local gx, gy = GPS:LocalToGlobal(x, y)

    local dx = cx - gx
    local dy = cy - gy

    return math.sqrt(dx * dx + dy * dy)
end

-- ============================================================================
--  Gruppenmitglieder sammeln + Entfernung + Sortierung
-- ============================================================================
local function GetGroupMembersWithDistance()
    local list = {}

    for i = 1, GROUP_SIZE_MAX do
        local tag = "group" .. i
        if DoesUnitExist(tag) and not IsUnitGroupLeader(tag) then
            local accName  = GetUnitDisplayName(tag)
            local charName = GetUnitName(tag)
            local dist     = GetDistanceToCrownForUnit(tag)

            if dist then
                table.insert(list, {
                    acc = accName,
                    name = charName,
                    distance = dist * 10000
                })
            end
        end
    end

    -- Debug: eigenen Spieler einfügen, wenn Liste leer ist
    if DsRGuildPvP.pvp.PvPCrownDebug and #list == 0 then
        local accName  = GetUnitDisplayName("player")
        local charName = GetUnitName("player")

        local dist = GetDistanceToCrown()
        if dist then dist = dist * 10000 else dist = 0 end
        table.insert(list, {
            acc = accName,
            name = charName,
            distance = dist
        })
    end

    table.sort(list, function(a, b)
        return a.acc < b.acc
    end)

    return list
end

-- ============================================================================
--  Farben je nach Entfernung
-- ============================================================================
local function GetColorForDistance(m)
    if m == 0.0 then
        return "|c89cff0"   -- Blau
    elseif m < 0.5 then
        return "|c00FF00"   -- Grün
    elseif m < 1.4 then
        return "|cFFFF00"   -- Gelb
    else
        return "|cFF0000"   -- Rot
    end
end

-- ============================================================================
--  Gruppenliste aktualisieren (mit Icons + Custom Names)
-- ============================================================================
local function UpdateGroupListWindow()
    local win = DsRGuildPvPCrownTableIndicator
    if not win then return end

    local label = win:GetNamedChild("List")
    if not label then return end

    local members = GetGroupMembersWithDistance()

    if #members == 0 then
        label:SetText("Keine Gruppenmitglieder")
        return
    end

    local lines = {}

    for _, entry in ipairs(members) do
        local m = math.floor(entry.distance * 10 + 0.5) / 10
        local color = GetColorForDistance(m)

        -- LibCustomIcons + LibCustomNames
        local texturePath, left, right, top, bottom = LibCustomIcons.GetStatic(entry.acc)
        local customName = LibCustomNames.Get(entry.acc)

        -- Klassenicon korrekt ermitteln
        local classIcon = ""
        local unitTag = nil

        -- Spieler selbst?
        if entry.acc == GetUnitDisplayName("player") then
            unitTag = "player"
        else
            -- Gruppenmitglieder finden
            for i = 1, GROUP_SIZE_MAX do
                local tag = "group" .. i
                if DoesUnitExist(tag) and GetUnitDisplayName(tag) == entry.acc then
                    unitTag = tag
                    break
                end
            end
        end

        -- Wenn wir einen gültigen UnitTag haben → Klassenicon holen
        if unitTag then
            local classId = GetUnitClassId(unitTag)
            if classId and classId > 0 then
                classIcon = zo_iconFormat(ZO_GetClassIcon(classId), 20, 20)
            end
        end

        local icon = ""
        local name = entry.acc:gsub("^@", "")

        if texturePath then
            icon = zo_iconFormat(texturePath, 21, 21)
        else
            icon = classIcon
        end

        if customName then
            name = customName
        end

        table.insert(lines, string.format("%s%.1fm|r  %s%s|r", color, m, icon, name))
    end

    label:SetText(table.concat(lines, "\n"))
end

-- ============================================================================
--  Fensterposition speichern & laden
-- ============================================================================
DsRGuildPvPCrownTable = DsRGuildPvPCrownTable or {}

function DsRGuildPvPCrownTable.SaveLoc()
    local win = DsRGuildPvPCrownTableIndicator
    if not win then return end

    local x, y = win:GetLeft(), win:GetTop()

    DsRGuildPvP.pvp.PvPCrownTableOffsetX = x
    DsRGuildPvP.pvp.PvPCrownTableOffsetY = y
end

function DsRGuildPvPCrownTable.LoadLoc()
    local win = DsRGuildPvPCrownTableIndicator
    if not win then return end

    local x = DsRGuildPvP.pvp.PvPCrownTableOffsetX
    local y = DsRGuildPvP.pvp.PvPCrownTableOffsetY

    if x and y then
        win:ClearAnchors()
        win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
        win:SetMouseEnabled(true)
        win:SetMovable(true)
        win:SetClampedToScreen(true)
    end

    local label = win:GetNamedChild("Label")
    if label then
        label:SetText(GetString(DsRGuildMenue_cyrodiilCrownListHead))
    end

    local bg = win:GetNamedChild("Bg")
    if bg then
        bg:SetAlpha(0)
    end
end

-- ============================================================================
--  Gruppe < 2? Fenster automatisch ausblenden
-- ============================================================================
local function IsGroupTooSmall()
    local count = 0

    for i = 1, GROUP_SIZE_MAX do
        if DoesUnitExist("group" .. i) then
            count = count + 1
        end
    end

    return count < 2
end

-- ============================================================================
--  Update-Loop
-- ============================================================================
local timeSinceLast = 0

local function OnUpdateCrown(frameTime)
    if not PvPCrown.IsInPvP() then 
        if PvPCrown.ui then
            PvPCrown.ui:SetHidden(true)
            if DsRGuildPvPCrownTableIndicator then
                DsRGuildPvPCrownTableIndicator:SetHidden(true)
            end
        end
        return
    end

    if not DsRGuildPvP.pvp.PvPCrownEnabled then
        if PvPCrown.ui then
            PvPCrown.ui:SetHidden(true)
            if DsRGuildPvPCrownTableIndicator then
                DsRGuildPvPCrownTableIndicator:SetHidden(true)
            end
        end
        return
    end

    -- Debug-Modus: Liste immer anzeigen, auch ohne Gruppe
    if DsRGuildPvP.pvp.PvPCrownDebug then
        if DsRGuildPvPCrownTableIndicator then
            DsRGuildPvPCrownTableIndicator:SetHidden(false)
        end
    else
        -- Normales Verhalten
        if IsGroupTooSmall() then
            if DsRGuildPvPCrownTableIndicator then
                DsRGuildPvPCrownTableIndicator:SetHidden(true)
            end
        elseif DsRGuildPvP.pvp.PvPCrownList then
            if DsRGuildPvPCrownTableIndicator then
                DsRGuildPvPCrownTableIndicator:SetHidden(false)
            end
        end
    end

    -- Liste immer aktualisieren (auch als Gruppenleiter), wenn aktiviert
    if DsRGuildPvP.pvp.PvPCrownList then
        UpdateGroupListWindow()
    end    

    -- Pfeil für Gruppenleiter ausblenden
    if IsUnitGroupLeader("player") then
        if PvPCrown.ui then PvPCrown.ui:SetHidden(true) end
        return
    end

    timeSinceLast = (timeSinceLast or 0) + frameTime
    if timeSinceLast < 0.05 then return end
    timeSinceLast = 0

    if not PvPCrown.tex or not PvPCrown.ui then
        CreateArrow()
    end

    local distance, dx, dy = GetDistanceToCrown()
    local angle = GetAngleToCrown()

    if not angle or not distance then
        if PvPCrown.ui then PvPCrown.ui:SetHidden(true) end
        return
    end

    local r, g, b = 1, 0, 0
    if ( distance * 10000 ) < 0.5 then
        r, g, b = 0, 1, 0
    elseif ( distance * 10000 ) < 1.4 then
        r, g, b = 1, 1, 0
    end
    PvPCrown.tex:SetColor(r, g, b, 1)

    if ( distance * 10000 ) > 0.2 then
        PvPCrown.tex:SetTexture("/DsRGuildHall/misc/Crownpfeil.dds")
        PvPCrown.tex:SetTextureRotation(angle + math.pi, 0.5, 0.5)
    else
        PvPCrown.tex:SetTexture("/DsRGuildHall/misc/CrownExakt.dds")
        PvPCrown.tex:SetColor(0.678, 0.847, 0.902, 1)
    end

    -- Fenster anzeigen, wenn nicht versteckt
    if PvPCrown.hiddenShortly == false then
        PvPCrown.ui:SetHidden(false)
    end
end

-- ============================================================================
--  Initialisierung
-- ============================================================================
function PvPCrown.OnAddOnLoaded(_, addonName)
    EVENT_MANAGER:RegisterForEvent("PvPCrown_PlayerActivated", EVENT_PLAYER_ACTIVATED, CreateArrow)
    EVENT_MANAGER:RegisterForUpdate("PvPCrown_Update", 0, OnUpdateCrown)

    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnShow", function() UpdateUIVisibility(true) end)
    ZO_PreHookHandler(ZO_InteractWindow,      "OnShow", function() UpdateUIVisibility(true) end)
    ZO_PreHookHandler(ZO_GameMenu_InGame,     "OnShow", function() UpdateUIVisibility(true) end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnShow", function() UpdateUIVisibility(true) end)

    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnHide", function() UpdateUIVisibility(false) end)
    ZO_PreHookHandler(ZO_InteractWindow,      "OnHide", function() UpdateUIVisibility(false) end)
    ZO_PreHookHandler(ZO_GameMenu_InGame,     "OnHide", function() UpdateUIVisibility(false) end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnHide", function() UpdateUIVisibility(false) end)
    
    DsRGuildPvPCrownTable.LoadLoc()
end

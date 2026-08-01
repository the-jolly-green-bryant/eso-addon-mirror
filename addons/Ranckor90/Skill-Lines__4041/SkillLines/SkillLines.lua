-- Ingame script to enable console Mode on PC
-- /script SetCVar("ForceConsoleFlow.2", "1")

SkillLines = {}
SkillLines.name = "SkillLines"
SkillLines.version = "2.1.2"
SkillLines.savedData = nil


local skillLines = {
    -- { category = "Class" , skillType = SKILL_TYPE_CLASS, names = {"Dragonknight", "Nightblade", "Sorcerer", "Templar", "Warden", "Necromancer"} },
    { category = "Weapon",       skillType = SKILL_TYPE_WEAPON,     names = {"Two Handed", "One Hand and Shield", "Dual Wield", "Bow", "Destruction Staff", "Restoration Staff"} },
    { category = "Armor",        skillType = SKILL_TYPE_ARMOR,      names = {"Light Armor", "Medium Armor", "Heavy Armor"} },
    { category = "World",        skillType = SKILL_TYPE_WORLD,      names = {"Excavation", "Legerdemain", "Scrying", "Soul Magic", "Werewolf", "Vampire"} },
    { category = "Guild",        skillType = SKILL_TYPE_GUILD,      names = {"Dark Brotherhood", "Fighters Guild", "Mages Guild", "Psijic Order", "Thieves Guild", "Undaunted"} },
    { category = "Alliance War", skillType = SKILL_TYPE_AVA,        names = {"Assault", "Support"} },
    { category = "Racial",       skillType = SKILL_TYPE_RACIAL,     names = {"Nord Skills", "Redguard Skills", "Orc Skills", "Dark Elf Skills", "High Elf Skills", "Wood Elf Skills", "Argonian Skills", "Khajiit Skills", "Breton Skills"} },
    { category = "Craft",        skillType = SKILL_TYPE_TRADESKILL, names = {"Alchemy", "Blacksmithing", "Clothing", "Enchanting", "Jewelry Crafting", "Provisioning", "Woodworking"} },
}


-- Locals for hot globals
local wm       = WINDOW_MANAGER
local EM       = EVENT_MANAGER
local SM       = SCENE_MANAGER
local GR       = GuiRoot
local insert   = table.insert
local sort     = table.sort
local strfmt   = string.format


-- Utils
local function CleanCharacterName(charName)
    return charName:gsub("%^%a+", "")
end


-- SavedVars helpers
local function SV()
    SkillLines.savedData = SkillLines.savedData or {}
    return SkillLines.savedData
end

local function SV_Server(server)
    local sv = SV()
    sv[server] = sv[server] or {}
    return sv[server]
end

local function SV_Account(server, account)
    local s = SV_Server(server)
    s[account] = s[account] or {}
    return s[account]
end

local function SV_Char(server, account, char)
    local a = SV_Account(server, account)
    a[char] = a[char] or {}
    return a[char]
end

-- Skill line index cache  SkillIndex[skillType][skillName] = index
local SkillIndex = {}

local function BuildSkillIndexForType(skillType)
    SkillIndex[skillType] = SkillIndex[skillType] or {}
    local t = SkillIndex[skillType]
    local n = GetNumSkillLines(skillType)
    for i = 1, n do
        local name = select(1, GetSkillLineInfo(skillType, i))
        if name and name ~= "" then t[name] = i end
    end
end

local function BuildSkillIndex()
    for _, cat in ipairs(skillLines) do
        BuildSkillIndexForType(cat.skillType)
    end
end

local function RefreshSkillIndexOnAdd()
    EM:RegisterForEvent(SkillLines.name .. "_IDX", EVENT_SKILL_LINE_ADDED, function(_, skillType)
        BuildSkillIndexForType(skillType)
        -- also refresh visible data (debounced)
        if SkillLines.DebouncedRefresh then
            SkillLines.DebouncedRefresh()
        end
    end)
end

-- Character data helpers
local function GetStoredCharacterData()
    local characters = {}
    local serverName  = SkillLines.activeServer or GetWorldName()
    local accountName = GetDisplayName()

    local bucket = SV_Account(serverName, accountName)
    for charName, _ in pairs(bucket) do
        if charName ~= "version" and type(bucket[charName]) == "table" then
            insert(characters, { name = charName, alliance = nil })
        end
    end
    sort(characters, function(a,b) return a.name < b.name end)
    return characters
end

local function GetAllServers()
    local servers = {}
    for k, v in pairs(SV()) do
        if type(v) == "table" and (k == "EU Megaserver" or k == "NA Megaserver") then
            insert(servers, k)
        end
    end
    sort(servers)
    return servers
end

local function GetCharactersForServer(serverName)
    local list = {}
    if not serverName then return list end
    local accountName = GetDisplayName()
    local bucket = SV_Account(serverName, accountName)
    for charName, _ in pairs(bucket) do
        if charName ~= "version" then insert(list, charName) end
    end
    sort(list)
    return list
end

local function DeleteCharacter(serverName, charName)
    if not (serverName and charName) then return false end
    local accountName = GetDisplayName()
    local acc = SV_Account(serverName, accountName)
    if not acc or not acc[charName] then return false end
    acc[charName] = nil
    d(strfmt("SkillLines: Deleted character '%s' on %s", charName, serverName))
    return true
end

local function DeleteAllCharacters(serverName)
    if not serverName then return false end
    local accountName = GetDisplayName()
    local acc = SV_Account(serverName, accountName)
    if acc then
        for k, _ in pairs(acc) do
            if k ~= "version" then acc[k] = nil end
        end
        d(strfmt("SkillLines: Deleted ALL characters on %s", serverName))
        return true
    end
    return false
end

-- Save & restore window geometry (reduced churn)
local function SaveWindowGeometry(control)
    local left, top = control:GetLeft(), control:GetTop()
    local w, h = control:GetDimensions()
    local sv = SV()
    local wp = sv.windowPosition or {}
    local ws = sv.windowSize or {}

    local posChanged = (wp.left ~= left) or (wp.top ~= top)
    local sizeChanged = (ws.width ~= w) or (ws.height ~= h)

    if posChanged then
        sv.windowPosition = { left = left, top = top }
        if sv.settings then
            sv.settings.posX, sv.settings.posY = left, top
        end
    end
    if sizeChanged then
        sv.windowSize = { width = w, height = h }
    end
end

local function RestoreWindowGeometry(control)
    local sv = SV()
    local pos = sv.windowPosition
    local size = sv.windowSize
    if pos then
        control:ClearAnchors()
        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos.left, pos.top)
    end
    if size then
        control:SetDimensions(
            math.min(size.width,  GuiRoot:GetWidth()  * 0.98),
            math.min(size.height, GuiRoot:GetHeight() * 0.90)
        )
    end
end

local function SaveWindowPosition(control) SaveWindowGeometry(control) end


-- Layout & scaling
local BASE_W, BASE_H = 1050, 700

local function LayoutForSize(root)
    local w, h = root:GetDimensions()
    local content = root.content
    if not content then return end

    local base = math.min(w / BASE_W, h / BASE_H)
    base = math.max(0.6, base)

    local userMult = 1.0
    if SV().settings then
        userMult = SV().settings.contentScale or 1.0
    end

    local finalScale = zo_clamp(base * userMult, 0.5, 3.0)
    content:SetScale(finalScale)

    content:SetDimensions(BASE_W, BASE_H)
    content:ClearAnchors()
    content:SetAnchor(CENTER, root, CENTER, 0, 0)
end

local function ApplyUIPositionFromSettings()
    local ui = wm:GetControlByName("SkillLinesUI")
    if not ui or not SV().settings then return end

    local rootW, rootH = GR:GetWidth(), GR:GetHeight()
    local w, h = ui:GetDimensions()
    local x = SV().settings.posX or 100
    local y = SV().settings.posY or 100

    x = zo_clamp(x, 0, math.max(0, rootW - w))
    y = zo_clamp(y, 0, math.max(0, rootH - h))

    ui:ClearAnchors()
    ui:SetAnchor(TOPLEFT, GR, TOPLEFT, x, y)

    SV().settings.posX = x
    SV().settings.posY = y
    SV().windowPosition = { left = x, top = y }
end

local function ApplyUIScaleFromSettings()
    local ui = wm:GetControlByName("SkillLinesUI")
    if not ui then return end
    LayoutForSize(ui)
end

local function ApplySettingsAll()
    ApplyUIPositionFromSettings()
    ApplyUIScaleFromSettings()
end


-- Reading & writing ranks (now O(#tracked skills))

local function UpdateCharacterSkillLevels()
    local rawName = GetUnitName("player")
    if not rawName or rawName == "" then return end

    local charName   = CleanCharacterName(rawName)
    local account    = GetDisplayName()
    local server     = GetWorldName()
    local svChar     = SV_Char(server, account, charName)

    for _, category in ipairs(skillLines) do
        local skillType = category.skillType
        local map       = SkillIndex[skillType]
        if map then
            for _, skillName in ipairs(category.names) do
                local idx = map[skillName]
                if idx then
                    local _, rank, discovered = GetSkillLineInfo(skillType, idx)
                    svChar[skillName] = discovered and rank or "-"
                else
                    svChar[skillName] = svChar[skillName] or "-"
                end
            end
        end
    end
end

local function GetCharacterSkillLevels(charName, skillName)
    local accountName = GetDisplayName()
    local serverName  = SkillLines.activeServer or GetWorldName()
    charName = CleanCharacterName(charName)
    local acc = SV_Account(serverName, accountName)
    if not acc or not acc[charName] then return "-" end
    return acc[charName][skillName] or "-"
end


-- Debounced data/UI refresh

local pendingRefresh = false
function SkillLines.DebouncedRefresh()
    if pendingRefresh then return end
    pendingRefresh = true
    zo_callLater(function()
        pendingRefresh = false
        UpdateCharacterSkillLevels()
        if SkillLines.RefreshSkillData then
            SkillLines.RefreshSkillData()
        end
        CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", "SkillLines_Panel")
    end, 50)
end


-- UI pools (rows) to avoid recreating controls

local RowPools = {}

local function CreateRow(parent)
    local row = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    row:SetDimensions(parent:GetWidth() - 20, 25)

    row.name = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    row.name:SetFont("$(MEDIUM_FONT)|14|soft-shadow-thin")
    row.name:SetAnchor(LEFT, row, LEFT, 10, 0)

    row.cells = {}
    return row
end

local function ResetRow(_, row)
    if row and row.SetHidden then
        row:SetHidden(true)
    end
end

local function EnsurePoolsForCategory(categoryKey, container, colHeaders)
    if RowPools[categoryKey] then return end

    RowPools[categoryKey] = {
        allRows = {}, 
        columns = #colHeaders,
    }

    local function factory(_)
        local row = CreateRow(container)
        table.insert(RowPools[categoryKey].allRows, row)
        return row
    end

    local function reset(_, row)
        if row and row.SetHidden then
            row:SetHidden(true)
        end
    end
    RowPools[categoryKey].pool = ZO_ObjectPool:New(factory, reset)
end


local function SetRowValues(row, charName, colNames, getRank)
    row.name:SetText(charName)
    local x = 130
    for i, col in ipairs(colNames) do
        local cell = row.cells[i]
        if not cell then
            cell = wm:CreateControl(nil, row, CT_LABEL)
            cell:SetFont("$(MEDIUM_FONT)|14|soft-shadow-thin")
            cell:SetDimensions(100, 25)
            cell:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            row.cells[i] = cell
        end
        cell:ClearAnchors()
        cell:SetAnchor(LEFT, row, LEFT, x, 0)
        cell:SetText(tostring(getRank(col)))
        x = x + 100
    end
    row:SetHidden(false)
end


-- Build & refresh UI

local function CreateSkillTable()
    local control = wm:GetControlByName("SkillLinesUI")
    if control then return end

    control = wm:CreateTopLevelWindow("SkillLinesUI")
    control:SetClampedToScreen(true)
    control:SetMovable(true)
    control:SetMouseEnabled(true)
    control:SetHidden(true)

    control:SetDimensions(math.min(BASE_W, GR:GetWidth() * 0.95), math.min(BASE_H, GR:GetHeight() * 0.70))
    control:SetResizeHandleSize(12)
    control:SetDimensionConstraints(700, 420, GR:GetWidth(), GR:GetHeight())

    RestoreWindowGeometry(control)
    control:SetHandler("OnMoveStop", function() SaveWindowGeometry(control) end)
    control:SetHandler("OnResizeStart", function() control.isResizing = true end)
    control:SetHandler("OnResizeStop", function()
        control.isResizing = false
        LayoutForSize(control)
        SaveWindowGeometry(control)
    end)
    control:SetHandler("OnWidthChanged",  function() if control:IsShown() then LayoutForSize(control) end end)
    control:SetHandler("OnHeightChanged", function() if control:IsShown() then LayoutForSize(control) end end)

    local bg = wm:CreateControl("$(parent)BG", control, CT_BACKDROP)
    bg:SetAnchorFill(control)
    bg:SetCenterColor(0, 0, 0, 0.8)

    local content = wm:CreateControl("$(parent)Content", control, CT_CONTROL)
    content:SetDimensions(BASE_W, BASE_H)
    content:SetAnchor(CENTER, control, CENTER, 0, 0)
    control.content = content

    local title = wm:CreateControl("$(parent)Title", content, CT_LABEL)
    title:SetText("Skill Lines Tracker")
    title:SetAnchor(TOP, content, TOP, 0, 5)
    title:SetFont("$(BOLD_FONT)|18|soft-shadow-thick")

    -- EU / NA switch
    local euButton = wm:CreateControlFromVirtual("$(parent)EUButton", content, "ZO_DefaultButton")
    euButton:SetDimensions(100, 25)
    euButton:SetAnchor(BOTTOMRIGHT, content, BOTTOMRIGHT, -210, -10)
    euButton:SetText("EU Server")
    euButton:SetHandler("OnClicked", function()
        SkillLines.activeServer = "EU Megaserver"
        SkillLines.DebouncedRefresh()
    end)

    local naButton = wm:CreateControlFromVirtual("$(parent)NAButton", content, "ZO_DefaultButton")
    naButton:SetDimensions(100, 25)
    naButton:SetAnchor(LEFT, euButton, RIGHT, 10, 0)
    naButton:SetText("NA Server")
    naButton:SetHandler("OnClicked", function()
        SkillLines.activeServer = "NA Megaserver"
        SkillLines.DebouncedRefresh()
    end)

    local versionLabel = wm:CreateControl("$(parent)VersionLabel", content, CT_LABEL)
    versionLabel:SetText("v." .. (SkillLines.version or ""))
    versionLabel:SetFont("$(MEDIUM_FONT)|12|soft-shadow-thin")
    versionLabel:SetAnchor(BOTTOMLEFT, content, BOTTOMLEFT, 5, -5)
    versionLabel:SetColor(0.8, 0.8, 0.8, 1)

    control.tabButtons = {}
    control.categoryContainers = {}
    control.categoryLabels = {}

    local tabX = 10
    local function ShowCategory(categoryName)
        for name, container in pairs(control.categoryContainers) do
            container:SetHidden(name ~= categoryName)
        end
    end
    control.ShowCategory = ShowCategory

    for i, category in ipairs(skillLines) do
        local tab = wm:CreateControlFromVirtual("$(parent)Tab"..category.category, content, "ZO_DefaultButton")
        tab:SetDimensions(100, 25)
        tab:SetAnchor(TOPLEFT, content, TOPLEFT, tabX, 30)
        tab:SetText(category.category)
        tab:SetHandler("OnClicked", function()
            ShowCategory(category.category)
        end)
        insert(control.tabButtons, tab)
        tabX = tabX + 105

        local container = wm:CreateControl("$(parent)Container"..category.category, content, CT_CONTROL)
        container:SetAnchor(TOPLEFT, content, TOPLEFT, 10, 60)
        container:SetDimensions(BASE_W - 20, BASE_H - 70)
        container:SetHidden(i ~= 1)
        control.categoryContainers[category.category] = container

        control.categoryLabels[category.category] = {}

        -- Headers
        local headerX = 130
        local columnWidth = 100
        for _, skillName in ipairs(category.names) do
            local header = wm:CreateControl(nil, container, CT_LABEL)
            header:SetText(skillName)
            header:SetAnchor(TOPLEFT, container, TOPLEFT, headerX, 5)
            header:SetFont("$(MEDIUM_FONT)|14|soft-shadow-thin")
            header:SetDimensions(columnWidth, 25)
            header:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            headerX = headerX + columnWidth
        end

        EnsurePoolsForCategory(category.category, container, category.names)
    end

    LayoutForSize(control)
    SkillLines.RefreshSkillData()
    ApplySettingsAll()
end

function SkillLines.RefreshSkillData()
    local control = wm:GetControlByName("SkillLinesUI")
    if not control then return end

    local characters = GetStoredCharacterData()

    for _, category in ipairs(skillLines) do
        local container = control.categoryContainers[category.category]
        local pool = RowPools[category.category].pool
        pool:ReleaseAllObjects()

        local meta = RowPools[category.category]
        for _, r in ipairs(meta.allRows) do
            if r and r.SetHidden then r:SetHidden(true) end
        end

        local y = 30
        if #characters == 0 then
            local row = pool:AcquireObject()
            row:ClearAnchors()
            row:SetAnchor(TOPLEFT, container, TOPLEFT, 10, y)
            row.name:SetText("No character data available")
            row:SetHidden(false)
        else
            for _, c in ipairs(characters) do
                local row = pool:AcquireObject()
                row:ClearAnchors()
                row:SetAnchor(TOPLEFT, container, TOPLEFT, 10, y)
                SetRowValues(row, c.name, category.names, function(skillName)
                    return GetCharacterSkillLevels(c.name, skillName) or "-"
                end)
                y = y + 28
            end
        end
    end

    if #skillLines > 0 and control.ShowCategory then
        control.ShowCategory(skillLines[1].category)
    end
end


-- Scene handling

local function OnSkillsSceneStateChange(oldState, newState)
    local control = wm:GetControlByName("SkillLinesUI")
    if newState == SCENE_SHOWN then
        SkillLines.DebouncedRefresh()
        if not control then
            CreateSkillTable()
            control = wm:GetControlByName("SkillLinesUI")
        end
        if control then
            control:SetHidden(false)
            ApplySettingsAll()
            LayoutForSize(control)
        end
    else
        if control then
            SaveWindowGeometry(control)
            control:SetHidden(true)
        end
    end
end


-- Settings panel

local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then
        d("SkillLines: LibAddonMenu-2.0 not found; settings panel disabled.")
        return
    end

    local panelName = "SkillLines_Panel"
    local panelData = {
        type = "panel",
        name = "Skill Lines",
        displayName = "Skill Lines",
        author = "Ranckor90",
        version = SkillLines.version or "1.0.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local defaults = { contentScale = 1.0, posX = 100, posY = 100 }

    local function RebuildCharacterDropdownChoices()
        local ctrl = _G["SkillLines_CharacterDropdown"]
        if not ctrl then return end

        local server = SkillLines.settingsState.selectedServer or (SkillLines.activeServer or GetWorldName())
        local list   = GetCharactersForServer(server)

        local choices, values
        if #list == 0 then
            choices = { "(no characters found)" }
            values  = { "(no characters found)" }
            SkillLines.settingsState.selectedChar = nil
        else
            sort(list)
            choices = list
            values  = list
            local wanted = SkillLines.settingsState.selectedChar
            local valid = false
            if wanted then
                for _, v in ipairs(list) do if v == wanted then valid = true break end end
            end
            if not valid then SkillLines.settingsState.selectedChar = list[1] end
        end

        ctrl:UpdateChoices(choices, values)
        ctrl:UpdateValue()
    end

    local function currentWindowSize()
        local ui = wm:GetControlByName("SkillLinesUI")
        if ui then return ui:GetWidth(), ui:GetHeight() else return BASE_W, BASE_H end
    end

    local wndW, wndH = currentWindowSize()
    local rootW, rootH = GR:GetWidth(), GR:GetHeight()
    local maxX = math.max(0, rootW - wndW)
    local maxY = math.max(0, rootH - wndH)

    local optionsTable = {
        { type = "header", name = "Scale (Resize)" },
        {
            type = "slider",
            name = "UI Scale",
            tooltip = "Scales the contents of the Skill Lines window. This multiplies the automatic scale from resizing.",
            min = 0.5, max = 3.0, step = 0.05, decimals = 2,
            getFunc = function() return (SV().settings and SV().settings.contentScale) or defaults.contentScale end,
            setFunc = function(value) SV().settings.contentScale = value; ApplyUIScaleFromSettings() end,
            default = defaults.contentScale,
        },

        { type = "header", name = "UI Position" },
        {
            type = "slider",
            name = "Position X",
            tooltip = "Horizontal position of the window (from the left edge).",
            min = 0, max = maxX, step = 1,
            getFunc = function() return (SV().settings and SV().settings.posX) or defaults.posX end,
            setFunc = function(v)
                local ui = wm:GetControlByName("SkillLinesUI")
                local w  = (ui and ui:GetWidth()) or BASE_W
                local clamped = zo_clamp(v, 0, math.max(0, GR:GetWidth() - w))
                SV().settings.posX = clamped
                ApplyUIPositionFromSettings()
            end,
            default = defaults.posX,
        },
        {
            type = "slider",
            name = "Position Y",
            tooltip = "Vertical position of the window (from the top edge).",
            min = 0, max = maxY, step = 1,
            getFunc = function() return (SV().settings and SV().settings.posY) or defaults.posY end,
            setFunc = function(v)
                local ui = wm:GetControlByName("SkillLinesUI")
                local h  = (ui and ui:GetHeight()) or BASE_H
                local clamped = zo_clamp(v, 0, math.max(0, GR:GetHeight() - h))
                SV().settings.posY = clamped
                ApplyUIPositionFromSettings()
            end,
            default = defaults.posY,
        },
        {
            type = "button",
            name = "Restore Defaults (UI)",
            tooltip = "Reset the UI scale and position to their defaults.",
            width = "full",
            func = function()
                local s = SV().settings
                s.contentScale = defaults.contentScale
                s.posX = defaults.posX
                s.posY = defaults.posY
                ApplySettingsAll()
                CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", panelName)
            end,
        },

        { type = "header", name = "Data Management" },
        {
            type = "dropdown",
            name = "Server",
            tooltip = "Choose which megaserver's character data to manage.",
            choices = { "EU Megaserver", "NA Megaserver" },
            getFunc = function()
                if not SkillLines.settingsState.selectedServer then
                    SkillLines.settingsState.selectedServer = SkillLines.activeServer or GetWorldName()
                end
                return SkillLines.settingsState.selectedServer
            end,
            setFunc = function(value)
                SkillLines.settingsState.selectedServer = value
                SkillLines.settingsState.selectedChar = nil
                RebuildCharacterDropdownChoices()
                CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", panelName)
            end,
            width = "full",
        },
        {
            type = "dropdown",
            name  = "Character",
            tooltip = "Pick a character to delete from SavedVars.",
            reference = "SkillLines_CharacterDropdown",
            choices = { "(no characters found)" },
            choicesValues = { "(no characters found)" },
            getFunc = function() return SkillLines.settingsState.selectedChar end,
            setFunc = function(value)
                if value ~= "(no characters found)" then
                    SkillLines.settingsState.selectedChar = value
                else
                    SkillLines.settingsState.selectedChar = nil
                end
            end,
            disabled = function()
                local server = SkillLines.settingsState.selectedServer or (SkillLines.activeServer or GetWorldName())
                return #GetCharactersForServer(server) == 0
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Delete Selected Character",
            tooltip = "Permanently remove the selected character's saved skill data.",
            func = function()
                local server = SkillLines.settingsState.selectedServer or (SkillLines.activeServer or GetWorldName())
                local char   = SkillLines.settingsState.selectedChar
                if DeleteCharacter(server, char) then
                    SkillLines.settingsState.selectedChar = nil
                    SkillLines.RefreshSkillData()
                    RebuildCharacterDropdownChoices()
                    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", panelName)
                    d("SkillLines: Character deleted.")
                else
                    d("SkillLines: Nothing deleted (no character selected or found).")
                end
            end,
            disabled = function() return not SkillLines.settingsState.selectedChar end,
            warning = "This cannot be undone.",
            width = "full",
        },
        {
            type = "button",
            name = "Delete ALL Characters (Server)",
            tooltip = "Delete all saved character data on the selected server.",
            func = function()
                local server = SkillLines.settingsState.selectedServer or (SkillLines.activeServer or GetWorldName())
                if DeleteAllCharacters(server) then
                    SkillLines.settingsState.selectedChar = nil
                    SkillLines.RefreshSkillData()
                    RebuildCharacterDropdownChoices()
                    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", panelName)
                    d("SkillLines: All characters deleted for server.")
                else
                    d("SkillLines: No characters to delete for server.")
                end
            end,
            warning = "This will remove ALL character entries for the selected server and cannot be undone.",
            width = "full",
        },
    }

    LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, optionsTable)
    RebuildCharacterDropdownChoices()

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(control)
        if control and control.data and control.data.name == panelData.name then
            local ui = wm:GetControlByName("SkillLinesUI")
            if not ui then
                RebuildCharacterDropdownChoices()
                return
            end
            local w, h = ui:GetWidth(), ui:GetHeight()
            local newMaxX = math.max(0, GR:GetWidth()  - w)
            local newMaxY = math.max(0, GR:GetHeight() - h)
            RebuildCharacterDropdownChoices()
        end
    end)
end


-- Event: player activated (debounced)

local function OnPlayerActivated()
    SkillLines.DebouncedRefresh()
end


-- Settings state (delete helpers UI)

SkillLines.settingsState = SkillLines.settingsState or {
    selectedServer = nil,
    selectedChar   = nil,
}


-- Addon init

local function OnAddOnLoaded(event, addonName)
    if addonName ~= SkillLines.name then return end

    SkillLines.savedData = ZO_SavedVars:NewAccountWide("SkillLinesSavedVars", 1, nil, {
        ["version"] = 1,
        ["EU Megaserver"] = {},
        ["NA Megaserver"] = {},
        windowPosition = { left = 100, top = 100 },
        windowSize     = { width = 1050, height = 700 },
        settings       = { contentScale = 1.0, posX = 100, posY = 100 },
    })

    local current = GetWorldName()
    SkillLines.activeServer = current
    SkillLines.settingsState.selectedServer = current

    BuildSkillIndex()
    RefreshSkillIndexOnAdd()

    UpdateCharacterSkillLevels()
    CreateSkillTable()
    ApplySettingsAll()

    local ok, err = pcall(CreateSettingsMenu)
    if not ok then d("SkillLines: Settings panel failed: "..tostring(err)) end

    EM:RegisterForEvent(SkillLines.name .. "_PA", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    local skillsScene = SM:GetScene("skills")
    skillsScene:RegisterCallback("StateChange", OnSkillsSceneStateChange)
end

EM:RegisterForEvent(SkillLines.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

QuestTest = QuestTest or {}

QuestTest.name = "Quest Test"
QuestTest.version = "1.1.0"
QuestTest.texture = "QuestTest/textures/rapport_gold_positive.dds"

QuestTest.defaults = {
    questNames = {
        ["Bath Time"] = true,
    },
    enabled = true,
    iconSize = 26,
    iconOffsetX = -34,
}

local activeIcons = {}
local scanQueued = false

local function QT_Print(message)
    d("|cFFD700Quest Test:|r " .. tostring(message))
end

local function QT_Normalize(value)
    if value == nil then return "" end
    value = zo_strtrim(tostring(value))
    return zo_strlower(value)
end

local function QT_IsWatchedQuestName(text)
    if not QuestTest.saved or not QuestTest.saved.questNames then return false end
    local normalizedText = QT_Normalize(text)
    for questName, enabled in pairs(QuestTest.saved.questNames) do
        if enabled and QT_Normalize(questName) == normalizedText then
            return true
        end
    end
    return false
end

local function QT_ControlLooksLikeJournal(control)
    local current = control
    for _ = 1, 8 do
        if not current then break end
        local name = current.GetName and current:GetName() or ""
        if name and (
            zo_strfind(name, "QuestJournal") or
            zo_strfind(name, "Journal") or
            zo_strfind(name, "GamepadQuest") or
            zo_strfind(name, "Quest")
        ) then
            return true
        end
        current = current.GetParent and current:GetParent() or nil
    end
    return false
end

local function QT_GetOrCreateIcon(labelControl)
    local key = tostring(labelControl)
    local icon = activeIcons[key]

    if icon == nil then
        icon = WINDOW_MANAGER:CreateControl(nil, labelControl:GetParent(), CT_TEXTURE)
        icon:SetTexture(QuestTest.texture)
        icon:SetDrawLayer(DL_OVERLAY)
        icon:SetDrawLevel(3)
        icon:SetMouseEnabled(false)
        activeIcons[key] = icon
    end

    return icon
end

local function QT_ShowIconBesideLabel(labelControl)
    if not labelControl or not labelControl.GetText then return end
    if not labelControl:IsHidden() and labelControl:IsControlHidden() then return end

    local size = QuestTest.saved.iconSize or 26
    local offsetX = QuestTest.saved.iconOffsetX or -34

    local icon = QT_GetOrCreateIcon(labelControl)
    icon:ClearAnchors()
    icon:SetDimensions(size, size)
    icon:SetTexture(QuestTest.texture)
    icon:SetHidden(false)
    icon:SetAnchor(RIGHT, labelControl, LEFT, offsetX, 0)
end

local function QT_HideMissingIcons(found)
    for key, icon in pairs(activeIcons) do
        if not found[key] then
            icon:SetHidden(true)
        end
    end
end

local function QT_ScanControl(control, found, depth)
    if not control or depth > 20 then return end

    if control.GetText and control.IsHidden and not control:IsHidden() then
        local text = control:GetText()
        if text and text ~= "" and QT_IsWatchedQuestName(text) and QT_ControlLooksLikeJournal(control) then
            local key = tostring(control)
            found[key] = true
            QT_ShowIconBesideLabel(control)
        end
    end

    if control.GetNumChildren and control.GetChild then
        local childCount = control:GetNumChildren()
        for i = 1, childCount do
            QT_ScanControl(control:GetChild(i), found, depth + 1)
        end
    end
end

function QuestTest.RefreshIcons()
    if not QuestTest.saved or not QuestTest.saved.enabled then
        for _, icon in pairs(activeIcons) do
            icon:SetHidden(true)
        end
        return
    end

    local found = {}
    QT_ScanControl(GuiRoot, found, 0)
    QT_HideMissingIcons(found)
end

local function QT_QueueScan()
    if scanQueued then return end
    scanQueued = true
    zo_callLater(function()
        scanQueued = false
        QuestTest.RefreshIcons()
    end, 100)
end

local function QT_AddQuestName(name)
    name = zo_strtrim(name or "")
    if name == "" then
        QT_Print("Use /qtadd Quest Name")
        return
    end

    QuestTest.saved.questNames[name] = true
    QT_Print("Added icon quest: |cFFFFFF" .. name .. "|r")
    QT_QueueScan()
end

local function QT_RemoveQuestName(name)
    name = zo_strtrim(name or "")
    if name == "" then
        QT_Print("Use /qtremove Quest Name")
        return
    end

    for questName in pairs(QuestTest.saved.questNames) do
        if QT_Normalize(questName) == QT_Normalize(name) then
            QuestTest.saved.questNames[questName] = nil
            QT_Print("Removed icon quest: |cFFFFFF" .. questName .. "|r")
            QT_QueueScan()
            return
        end
    end

    QT_Print("Quest not found in list: |cFFFFFF" .. name .. "|r")
end

local function QT_ListQuestNames()
    QT_Print("Tracked quest names:")
    for questName, enabled in pairs(QuestTest.saved.questNames) do
        if enabled then
            d(" - |cFFFFFF" .. questName .. "|r")
        end
    end
end

local function QT_RegisterSlashCommands()
    SLASH_COMMANDS["/qtadd"] = QT_AddQuestName
    SLASH_COMMANDS["/qtremove"] = QT_RemoveQuestName
    SLASH_COMMANDS["/qtlist"] = QT_ListQuestNames
    SLASH_COMMANDS["/qttoggle"] = function()
        QuestTest.saved.enabled = not QuestTest.saved.enabled
        QT_Print("Icons " .. (QuestTest.saved.enabled and "|c00FF00enabled|r" or "|cFF0000disabled|r"))
        QT_QueueScan()
    end
end

local function QT_RegisterRefreshHooks()
    EVENT_MANAGER:RegisterForUpdate(QuestTest.name .. "_JournalScan", 650, function()
        if QuestTest.saved and QuestTest.saved.enabled then
            QuestTest.RefreshIcons()
        end
    end)

    if SCENE_MANAGER then
        local scenes = {
            "questJournal",
            "gamepad_quest_journal",
            "journal",
        }

        for _, sceneName in ipairs(scenes) do
            local scene = SCENE_MANAGER:GetScene(sceneName)
            if scene then
                scene:RegisterCallback("StateChange", function(_, newState)
                    if newState == SCENE_SHOWN or newState == SCENE_SHOWING then
                        QT_QueueScan()
                    end
                end)
            end
        end
    end

    CALLBACK_MANAGER:RegisterCallback("QuestJournalUpdated", QT_QueueScan)
end

local function QT_OnLoaded(_, addonName)
    if addonName ~= QuestTest.name then return end

    QuestTest.saved = ZO_SavedVars:NewAccountWide("QuestTest_SavedVariables", 1, nil, QuestTest.defaults)

    QT_RegisterSlashCommands()
    QT_RegisterRefreshHooks()

    QT_Print("loaded. Gold positive rapport quest icons are active.")
    QT_QueueScan()
end

EVENT_MANAGER:RegisterForEvent(QuestTest.name, EVENT_ADD_ON_LOADED, QT_OnLoaded)

-- SlashFinder — browse slash commands registered by your addons.

local ADDON_NAME = "!SlashFinder"

local addonCommands = {}  -- addon title → { "/cmd1", "/cmd2", … }

local function IsCommand(cmd)
    return cmd and string.sub(cmd, 1, 1) == "/"
end

local function GetAddonTitle(name)
    local mgr = GetAddOnManager()
    for i = 1, mgr:GetNumAddOns() do
        local fileName, title = mgr:GetAddOnInfo(i)
        if fileName == name then
            return (title and title ~= "") and title or name
        end
    end
    return name
end

-- Sequential diff: snapshot SLASH_COMMANDS after each addon loads.

local skipAddons = { ["LibAnimation-1.0"] = true }
local lastSeen = {}

local function Snapshot()
    ZO_ClearTable(lastSeen)
    for cmd in pairs(SLASH_COMMANDS) do
        lastSeen[cmd] = true
    end
end

local function OnAddonLoaded(_, name)
    if name == ADDON_NAME then
        Snapshot()
        return
    end

    if name == "ZO_Ingame" then return end

    if skipAddons[name] then
        Snapshot()
        return
    end

    local newCmds = {}
    for cmd in pairs(SLASH_COMMANDS) do
        if IsCommand(cmd) and not lastSeen[cmd] then
            newCmds[#newCmds + 1] = cmd
        end
    end

    Snapshot()

    if #newCmds > 0 then
        local title = GetAddonTitle(name)
        local list = addonCommands[title]
        if list then
            for _, c in ipairs(newCmds) do
                list[#list + 1] = c
            end
        else
            table.sort(newCmds)
            addonCommands[title] = newCmds
        end
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)

local window

local function RebuildList()
    local scrollData = ZO_ScrollList_GetDataList(window.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    local filter = string.lower(window.searchBox:GetText() or "")

    local matching = {}
    for title, cmds in pairs(addonCommands) do
        if title ~= "ZO_Ingame" then
            local titleHit = filter == "" or string.find(string.lower(title), filter, 1, true)
            local shown = {}

            for _, cmd in ipairs(cmds) do
                if titleHit or string.find(string.lower(cmd), filter, 1, true) then
                    shown[#shown + 1] = cmd
                end
            end

            if #shown > 0 then
                matching[#matching + 1] = { title = title, cmds = shown }
            end
        end
    end

    table.sort(matching, function(a, b) return a.title < b.title end)

    for _, entry in ipairs(matching) do
        scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(2,
            { text = string.format("%s  (%d)", entry.title, #entry.cmds) }, nil)

        for _, cmd in ipairs(entry.cmds) do
            scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(1,
                { text = cmd }, nil)
        end

        scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(3, {}, nil)
    end

    ZO_ScrollList_Commit(window.list)

    local addons, total = 0, 0
    for title, v in pairs(addonCommands) do
        if title ~= "ZO_Ingame" then
            addons = addons + 1
            total = total + #v
        end
    end
    window.status:SetText(string.format("%d addons  •  %d commands", addons, total))
end

local function CreateWindow()
    local wm = WINDOW_MANAGER

    window = wm:CreateTopLevelWindow("SlashFinderWindow")
    window:SetDimensions(460, 480)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetHidden(true)
    window:SetClampedToScreen(true)
    window:SetDrawTier(1)
    window:SetMouseEnabled(true)
    window:SetMovable(true)

    local bg = wm:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill(window)
    bg:SetCenterColor(0.08, 0.08, 0.10, 0.94)
    bg:SetEdgeColor(0.25, 0.25, 0.30, 1)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/tips_AllianceBorder.dds", 8, 8)

    local titleBar = wm:CreateControl(nil, window, CT_BACKDROP)
    titleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    titleBar:SetAnchor(TOPRIGHT, window, TOPRIGHT, 0, 0)
    titleBar:SetHeight(30)
    titleBar:SetCenterColor(0.12, 0.12, 0.16, 1)

    local title = wm:CreateControl(nil, titleBar, CT_LABEL)
    title:SetAnchor(CENTER, titleBar, CENTER, 0, 0)
    title:SetFont("ZoFontWinH4")
    title:SetColor(1, 0.85, 0.4, 1)
    title:SetText("Slash Commands")

    local closeBtn = wm:CreateControl(nil, titleBar, CT_BUTTON)
    closeBtn:SetAnchor(TOPRIGHT, titleBar, TOPRIGHT, -4, 4)
    closeBtn:SetDimensions(20, 20)
    closeBtn:SetNormalTexture("EsoUI/Art/Buttons/closeButton_up.dds")
    closeBtn:SetPressedTexture("EsoUI/Art/Buttons/closeButton_down.dds")
    closeBtn:SetMouseOverTexture("EsoUI/Art/Buttons/closeButton_over.dds")
    closeBtn:SetHandler("OnClicked", function() window:SetHidden(true) end)

    local searchBg = wm:CreateControl(nil, window, CT_BACKDROP)
    searchBg:SetAnchor(TOPLEFT, titleBar, BOTTOMLEFT, 6, 6)
    searchBg:SetAnchor(TOPRIGHT, titleBar, BOTTOMRIGHT, -6, 6)
    searchBg:SetHeight(28)
    searchBg:SetCenterColor(0.15, 0.15, 0.18, 1)
    searchBg:SetEdgeColor(0.3, 0.3, 0.35, 1)
    searchBg:SetEdgeTexture("EsoUI/Art/Tooltips/tips_AllianceBorder.dds", 4, 4)

    window.searchBox = wm:CreateControl(nil, searchBg, CT_EDITBOX)
    window.searchBox:SetAnchor(TOPLEFT, searchBg, TOPLEFT, 8, 0)
    window.searchBox:SetAnchor(BOTTOMRIGHT, searchBg, BOTTOMRIGHT, -8, 0)
    window.searchBox:SetFont("ZoFontGame")
    window.searchBox:SetColor(1, 1, 1, 1)
    window.searchBox:SetMouseEnabled(true)
    window.searchBox:SetDrawLayer(2)
    window.searchBox:SetDefaultText("Filter by addon or command…")
    window.searchBox:SetHandler("OnTextChanged", function() RebuildList() end)
    window.searchBox:SetHandler("OnMouseDown", function(self) self:TakeFocus() end)

    local listContainer = wm:CreateControl(nil, window, CT_CONTROL)
    listContainer:SetAnchor(TOPLEFT, searchBg, BOTTOMLEFT, 0, 6)
    listContainer:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, 0, -28)

    window.list = CreateControlFromVirtual("SlashFinderList", listContainer, "ZO_ScrollList", nil)
    window.list:SetAnchorFill(listContainer)
    ZO_ScrollList_Initialize(window.list)

    ZO_ScrollList_AddDataType(window.list, 1, "SlashFinderCmdRow", 22,
        function(ctrl, data) ctrl:GetNamedChild("Text"):SetText(data.text) end,
        nil, nil, nil)
    ZO_ScrollList_AddDataType(window.list, 2, "SlashFinderHeaderRow", 22,
        function(ctrl, data) ctrl:GetNamedChild("Text"):SetText(data.text) end,
        nil, nil, nil)
    ZO_ScrollList_AddDataType(window.list, 3, "SlashFinderSpacerRow", 6,
        nil, nil, nil, nil)

    window.status = wm:CreateControl(nil, window, CT_LABEL)
    window.status:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 8, -6)
    window.status:SetFont("ZoFontGameSmall")
    window.status:SetColor(0.5, 0.5, 0.55, 1)

    window:SetHandler("OnKeyDown", function(_, key)
        if key == KEY_ESCAPE then window:SetHidden(true) end
    end)
end

SLASH_COMMANDS["/slashfinder"] = function(filter)
    if not window then CreateWindow() end
    if window:IsHidden() then
        window.searchBox:SetText(filter and filter ~= "" and filter or "")
        RebuildList()
        window:SetHidden(false)
    else
        window:SetHidden(true)
    end
end

SLASH_COMMANDS["/sf"] = SLASH_COMMANDS["/slashfinder"]

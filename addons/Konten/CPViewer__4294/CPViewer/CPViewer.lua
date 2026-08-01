local ADDON = "CPViewer"

local DISCIPLINES = {
    { id = 1, name = "Craft" },
    { id = 2, name = "Warfare" },
    { id = 3, name = "Fitness" },
}

local collapsed = {
    [1] = true,
    [2] = false,
    [3] = true,
}

local pendingCPChanges = {}
local activeSelection = nil

local function GetSlottedChampionPoints()
    local cpData = { [1] = {}, [2] = {}, [3] = {} }
    for slot = 1, 12 do
        local abilityId = GetSlotBoundId(slot, HOTBAR_CATEGORY_CHAMPION)
        if abilityId and abilityId > 0 then
            local name = zo_strformat("<<C:1>>", GetChampionSkillName(abilityId))
            local group = (slot <= 4) and 1 or (slot <= 8) and 2 or 3
            table.insert(cpData[group], { name = name, abilityId = abilityId, slotIndex = slot })
        end
    end
    return cpData
end

local function CreateWindow()
    local wm = WINDOW_MANAGER
    local win = wm:CreateTopLevelWindow("CPViewerWindow")
    win:SetDimensions(145, 220)
    win:SetAnchor(CENTER, GuiRoot, CENTER, 10, 0)
    win:SetMovable(true)
    win:SetClampedToScreen(true)
    win:SetHidden(true)

    local bg = wm:CreateControl(nil, win, CT_BACKDROP)
    bg:SetAnchorFill(win)
    bg:SetCenterColor(0, 0, 0, 0.55)
    bg:SetEdgeColor(0, 0, 0, 0.8)
    bg:SetMouseEnabled(true)
    bg:SetHandler("OnMouseDown", function(_, btn)
        if btn == MOUSE_BUTTON_INDEX_LEFT and not CPViewer_SV.locked then
            win:StartMoving()
        end
    end)

    bg:SetHandler("OnMouseUp", function(_, btn)
        if btn == MOUSE_BUTTON_INDEX_LEFT then
            win:StopMovingOrResizing()
        elseif btn == MOUSE_BUTTON_INDEX_RIGHT then
            ClearMenu()

            if CPViewer_SV.locked then
                AddCustomMenuItem("Unlock Panel", function()
                    CPViewer_SV.locked = false
                    win:SetMovable(true)
                end)
            else
                AddCustomMenuItem("Lock Panel", function()
                    CPViewer_SV.locked = true
                    win:SetMovable(false)
                end)
            end

            ShowMenu(bg)
        end
    end)

    win.scrollChild = wm:CreateControl(nil, win, CT_CONTROL)
    win.scrollChild:SetAnchor(TOPLEFT, win, TOPLEFT, 5, 5)
    win.scrollChild:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -8, -38)
    win.rows = {}

    local applyBtn = wm:CreateControlFromVirtual(nil, win, "ZO_DefaultButton")
    applyBtn:SetAnchor(BOTTOMLEFT, win, BOTTOMLEFT, 10, -5)
    applyBtn:SetDimensions(55, 20)
    applyBtn:SetText("Apply")
    applyBtn:SetFont("ZoFontGameSmall")

    local cooldownTime = 0
    local cooldownActive = false

    local function UpdateCooldown()
        if cooldownActive then
            local remaining = math.ceil(cooldownTime - GetFrameTimeSeconds())
            if remaining > 0 then
                applyBtn:SetText(zo_strformat("<<1>>s", remaining))
            else
                applyBtn:SetText("Apply")
                applyBtn:SetEnabled(true)
                cooldownActive = false
                EVENT_MANAGER:UnregisterForUpdate("CPViewerCooldown")
            end
        end
    end

    applyBtn:SetHandler("OnClicked", function()
        if next(pendingCPChanges) == nil then return end

        applyBtn:SetEnabled(false)
        cooldownActive = true
        cooldownTime = GetFrameTimeSeconds() + 30
        EVENT_MANAGER:RegisterForUpdate("CPViewerCooldown", 1000, UpdateCooldown)

        PrepareChampionPurchaseRequest()
        for slotIndex, skillId in pairs(pendingCPChanges) do
            AddHotbarSlotToChampionPurchaseRequest(slotIndex, skillId)
        end
        SendChampionPurchaseRequest()

        pendingCPChanges = {}
        PlaySound(SOUNDS.CHAMPION_STAR_SLOT)
        RefreshUI()
    end)

    local cancelBtn = wm:CreateControlFromVirtual(nil, win, "ZO_DefaultButton")
    cancelBtn:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -10, -5)
    cancelBtn:SetDimensions(55, 20)
    cancelBtn:SetText("Cancel")
    cancelBtn:SetFont("ZoFontGameSmall")
    cancelBtn:SetHandler("OnClicked", function()
        if next(pendingCPChanges) == nil then return end
        pendingCPChanges = {}
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        RefreshUI()
    end)

    return win
end

local window = CreateWindow()
ZO_PreHookHandler(ZO_Menu, "OnHide", function()
	if activeSelection then
		activeSelection = nil
		RefreshUI()
	end
end)

local function ClearRows()
    for _, r in ipairs(window.rows) do
        r:SetHidden(true)
        r:SetParent(nil)
    end
    window.rows = {}
end

local function AddHeaderRow(y)
    local wm = WINDOW_MANAGER
    local header = wm:CreateControl(nil, window.scrollChild, CT_LABEL)
    header:SetFont("ZoFontGameSmall")
    header:SetAnchor(TOPLEFT, window.scrollChild, TOPLEFT, 10, 0)
    header:SetMouseEnabled(true)

    local function RefreshHeaderColors()
        local txt = ""
        for i, disc in ipairs(DISCIPLINES) do
            local color
            if collapsed[disc.id] then
                color = "|c888888"
            else
                if disc.id == 1 then color = "|c80FF80"
                elseif disc.id == 2 then color = "|c3AA3FF"
                elseif disc.id == 3 then color = "|cFF5050"
                end
            end
            txt = txt .. color .. disc.name .. "|r"
            if i < #DISCIPLINES then txt = txt .. "  " end
        end
        header:SetText(txt)
    end

    header:SetHandler("OnMouseUp", function(_, btn)
        if btn == MOUSE_BUTTON_INDEX_LEFT then
            local mx, _ = GetUIMousePosition()
            local totalWidth = header:GetTextWidth()
            local sectionWidth = totalWidth / #DISCIPLINES
            local left = header:GetScreenRect()
            local clickIndex = math.floor((mx - left) / sectionWidth) + 1
            if clickIndex >= 1 and clickIndex <= 3 then
                for i = 1, 3 do collapsed[i] = (i ~= clickIndex) end
                RefreshUI()
            end
        end
    end)

    header.RefreshColors = RefreshHeaderColors
    table.insert(window.rows, header)
    return y + 16
end

local function ShowChampionPointMenu(discipline, slotIndex)
    ClearMenu()
	activeSelection = slotIndex
	RefreshUI()

    local blockedSkills = {}
    for slot = 1, 12 do
        local id = GetSlotBoundId(slot, HOTBAR_CATEGORY_CHAMPION)
        if id and id > 0 then blockedSkills[id] = true end
    end

    for _, newSkillId in pairs(pendingCPChanges) do
        blockedSkills[newSkillId] = true
    end

    local numSkills = GetNumChampionDisciplineSkills(discipline)
    local added = 0

    for i = 1, numSkills do
        local skillId = GetChampionSkillId(discipline, i)
        local spent = GetNumPointsSpentOnChampionSkill(skillId)
        if spent >= 50 and not blockedSkills[skillId] then
            local name = zo_strformat("<<C:1>>", GetChampionSkillName(skillId))
            AddMenuItem(name, function()
                local targetSlot = slotIndex
                local currentAbility = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_CHAMPION)

                if currentAbility and currentAbility > 0 then
                    local startSlot = ((discipline - 1) * 4) + 1
                    local endSlot = startSlot + 3
                    for s = startSlot, endSlot do
                        local checkId = GetSlotBoundId(s, HOTBAR_CATEGORY_CHAMPION)
                        if not checkId or checkId == 0 then
                            targetSlot = s
                            break
                        end
                    end
                end

                pendingCPChanges[targetSlot] = skillId
				activeSelection = nil
                PlaySound(SOUNDS.DIALOG_ACCEPT)
                RefreshUI()
            end, MENU_ADD_OPTION_LABEL)
            added = added + 1
        end
    end

    if added == 0 then
        AddCustomMenuItem("|c888888No available CP|r", function() end)
    end

    PlaySound(SOUNDS.MENU_BAR_CLICK)
    ShowMenu(window)
end

local function AddRow(y, text, discipline, slotIndex, clickable, isEmpty)
    local wm = WINDOW_MANAGER
    local label = wm:CreateControl(nil, window.scrollChild, CT_LABEL)
    label:SetFont("ZoFontGameSmall")
    label:SetAnchor(TOPLEFT, window.scrollChild, TOPLEFT, 6, y)
	if activeSelection == slotIndex then
		text = text:gsub("^• ", "• |cFF4040")
		text = text .. "|r"
	end
    label:SetText(text)
    label:SetMouseEnabled(true)

    if clickable then
        label:SetHandler("OnMouseEnter", function(self)
            self:SetColor(1, 1, 0, 1)
            local newSkillId = pendingCPChanges[slotIndex]
            if newSkillId then
                local newName = zo_strformat("<<C:1>>", GetChampionSkillName(newSkillId))
                InitializeTooltip(InformationTooltip, self, RIGHT, -10, 0)
                InformationTooltip:AddLine("|cFFFF00Pending Change|r", "ZoFontHeader2")
                if not isEmpty then
                    local currentId = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_CHAMPION)
                    if currentId and currentId > 0 then
                        local oldName = zo_strformat("<<C:1>>", GetChampionSkillName(currentId))
                        InformationTooltip:AddLine("|cAAAAAACurrent:|r " .. oldName)
                    end
                end
                InformationTooltip:AddLine("|cA4C8FFNew:|r " .. newName)
            end
        end)
        label:SetHandler("OnMouseExit", function(self)
            self:SetColor(1, 1, 1, 1)
            ClearTooltip(InformationTooltip)
        end)
        label:SetHandler("OnMouseUp", function(_, btn)
            if btn == MOUSE_BUTTON_INDEX_LEFT then
                ClearTooltip(InformationTooltip)
                ShowChampionPointMenu(discipline, slotIndex)
            end
        end)
    end

    table.insert(window.rows, label)
    return y + 14
end


function RefreshUI()
    if window:IsHidden() then return end
    ClearRows()

    local y = 4
    y = AddHeaderRow(y)
    local cpData = GetSlottedChampionPoints()

    for index, disc in ipairs(DISCIPLINES) do
        if not collapsed[disc.id] then
            local group = cpData[index]
            local totalSlots = 4
            local startSlot = ((disc.id - 1) * 4) + 1

            for s = 1, totalSlots do
                local slotIndex = startSlot + s - 1
                local abilityId = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_CHAMPION)
                local pendingId = pendingCPChanges[slotIndex]
                local text
                local isEmpty = (not abilityId or abilityId == 0)

                if pendingId then
                    local newName = zo_strformat("<<C:1>>", GetChampionSkillName(pendingId))
                    text = "• " .. newName .. " |cFFFF00(X)|r"
                elseif abilityId and abilityId > 0 then
                    local name = zo_strformat("<<C:1>>", GetChampionSkillName(abilityId))
                    text = "• " .. name
                else
                    text = "• |c888888— empty slot —|r"
                end

                y = AddRow(y, text, disc.id, slotIndex, true, isEmpty)
            end
        end
    end

    local totalHeight = y + 36
    window:SetHeight(math.max(120, math.min(totalHeight, 240)))

    if window.rows[1] and window.rows[1].RefreshColors then
        window.rows[1].RefreshColors()
    end
end

local function HookSceneVisibility()
    local wasVisible = false
    for sceneName, scene in pairs(SCENE_MANAGER.scenes) do
        if scene and not scene.CPViewerCallbackRegistered then
            scene:RegisterCallback("StateChange", function(_, newState)
                if not window then return end
                if newState == SCENE_SHOWING then
                    if sceneName ~= "hud" and sceneName ~= "hudui" then
                        if not window:IsHidden() then
                            wasVisible = true
                            window:SetHidden(true)
                        end
                    elseif wasVisible then
                        window:SetHidden(false)
                        wasVisible = false
                    end
                end
            end)
            scene.CPViewerCallbackRegistered = true
        end
    end
end

local function ToggleWindow()
    window:SetHidden(not window:IsHidden())
    RefreshUI()
end

local function OnHotbarUpdated(_, _, hotbarCategory)
    if hotbarCategory == HOTBAR_CATEGORY_CHAMPION then RefreshUI() end
end

local function OnPlayerActivated()
    RefreshUI()
end

function CPViewer_Toggle()
    if window then
        window:SetHidden(not window:IsHidden())
        if not window:IsHidden() then RefreshUI() end
    end
end

local function OnAddonLoaded(_, name)
    if name ~= ADDON then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_ADD_ON_LOADED)

    local defaults = { 
		x = 0, 
		y = 0, 
		locked = false, 
		visible = true 
	}

	CPViewer_SV = ZO_SavedVars:NewAccountWide("CPViewer_SavedVariables", 1, nil, defaults)

    if CPViewer_SV.x and CPViewer_SV.y then
        window:ClearAnchors()
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CPViewer_SV.x, CPViewer_SV.y)
    end

    window:SetHandler("OnMoveStop", function()
        CPViewer_SV.x = window:GetLeft()
        CPViewer_SV.y = window:GetTop()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_HOTBAR_SLOT_UPDATED, OnHotbarUpdated)
    EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    SLASH_COMMANDS["/cpv"] = ToggleWindow
    ZO_CreateStringId("SI_BINDING_NAME_CPVIEWER_TOGGLE", "Toggle CP Viewer")
    ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_CPVIEWER", "CP Viewer")

    HookSceneVisibility()
end

EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_ADD_ON_LOADED, OnAddonLoaded)

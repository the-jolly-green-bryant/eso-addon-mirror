local KRT = KwibusRandomThings
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER
local ADDON_NAME = KRT.name

local DEFAULTS = {
    kws = {
        enabled = true,
        profiles = {},
        lastProfile = "",
        offsetX = 150,
        offsetY = 150,
    }
}

KRT.KWS = {
    id = "kws",
    ui = nil,
    rows = {},
    selectedPlayers = {},
    comboBox = nil,
    editBox = nil,
    kickBtn = nil,
    fragment = nil,
    pendingInvites = {}, -- Tracks players waiting to be re-invited
    pendingKicksCount = 0, -- Tracks how many people we are waiting on the server to kick
    inviteTimeoutTimer = nil, -- Failsafe timer
}
local self = KRT.KWS

local function SV()
    if not KRT.sv.kws then
        KRT.sv.kws = ZO_DeepTableCopy(DEFAULTS.kws)
    end
    return KRT.sv.kws
end

function KRT.KWS:CreateUI()
    local existing = _G["KwibusSpaulderUI"]
    if existing and existing.SetHidden then
        self.ui = existing
        return
    end

    local win = WM:CreateTopLevelWindow("KwibusSpaulderUI")
    win:SetDimensions(350, 520)
    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV().offsetX, SV().offsetY)
    win:SetMouseEnabled(true)
    win:SetMovable(true)
    win:SetClampedToScreen(true)
    win:SetHidden(true)
    win:SetHandler("OnMoveStop", function(control)
        SV().offsetX = control:GetLeft()
        SV().offsetY = control:GetTop()
    end)

    local bg = WM:CreateControlFromVirtual(nil, win, "ZO_DefaultBackdrop")
    bg:SetAnchorFill()

    local title = WM:CreateControl(nil, win, CT_LABEL)
    title:SetFont("ZoFontWinH2")
    title:SetText("Kwibus Spaulder")
    title:SetAnchor(TOP, win, TOP, 0, 10)

    for i = 1, 12 do
        local row = WM:CreateControl(nil, win, CT_CONTROL)
        row:SetDimensions(330, 26)
        row:SetAnchor(TOPLEFT, win, TOPLEFT, 10, 40 + ((i - 1) * 26))

        local cb = WM:CreateControl(nil, row, CT_BUTTON)
        cb:SetDimensions(20, 20)
        cb:SetAnchor(LEFT, row, LEFT, 5, 0)
        cb:SetNormalTexture("esoui/art/buttons/checkbox_unchecked.dds")
        cb:SetMouseOverTexture("esoui/art/buttons/checkbox_mouseover.dds")
        cb:SetPressedTexture("esoui/art/buttons/checkbox_checked.dds")
        cb.checked = false

        local role = WM:CreateControl(nil, row, CT_TEXTURE)
        role:SetDimensions(24, 24)
        role:SetAnchor(LEFT, cb, RIGHT, 5, 0)

        local rr, rg, rb, ra = role:GetColor()
        row.roleOriginalColor = { rr, rg, rb, ra }

        local nameLabel = WM:CreateControl(nil, row, CT_LABEL)
        nameLabel:SetFont("ZoFontGame")
        nameLabel:SetAnchor(LEFT, role, RIGHT, 5, 0)
        nameLabel:SetDimensions(220, 24)

        local zoneIcon = WM:CreateControl(nil, row, CT_TEXTURE)
        zoneIcon:SetDimensions(24, 24)
        zoneIcon:SetAnchor(LEFT, nameLabel, RIGHT, 5, 0)

        local function UpdateCheckboxTexture(control, isChecked)
            if isChecked then
                control:SetNormalTexture("esoui/art/buttons/checkbox_checked.dds")
                control:SetMouseOverTexture("esoui/art/buttons/checkbox_checked_mouseover.dds")
                control:SetPressedTexture("esoui/art/buttons/checkbox_unchecked.dds")
            else
                control:SetNormalTexture("esoui/art/buttons/checkbox_unchecked.dds")
                control:SetMouseOverTexture("esoui/art/buttons/checkbox_mouseover.dds")
                control:SetPressedTexture("esoui/art/buttons/checkbox_checked.dds")
            end
        end

        cb:SetHandler("OnClicked", function(control)
            control.checked = not control.checked
            UpdateCheckboxTexture(control, control.checked)
            if row.displayName then
                self.selectedPlayers[row.displayName] = control.checked
            end
        end)
        cb.UpdateTexture = UpdateCheckboxTexture

        row.cb = cb
        row.role = role
        row.nameLabel = nameLabel
        row.zoneIcon = zoneIcon
        self.rows[i] = row
    end

    local kickBtn = WM:CreateControlFromVirtual(nil, win, "ZO_DefaultButton")
    kickBtn:SetAnchor(TOP, win, TOP, 0, 360)
    kickBtn:SetWidth(250)
    kickBtn:SetText("Kick & Re-invite Selected")
    kickBtn:SetHandler("OnClicked", function() self:KickAndReinvite() end)
    self.kickBtn = kickBtn

    local pTitle = WM:CreateControl(nil, win, CT_LABEL)
    pTitle:SetFont("ZoFontWinH3")
    pTitle:SetText("Profiles")
    pTitle:SetAnchor(TOPLEFT, win, TOPLEFT, 15, 400)

    local editBg = WM:CreateControlFromVirtual(nil, win, "ZO_EditBackdrop")
    editBg:SetDimensions(200, 26)
    editBg:SetAnchor(TOPLEFT, pTitle, BOTTOMLEFT, 0, 10)
    self.editBox = WM:CreateControlFromVirtual(nil, editBg, "ZO_DefaultEditForBackdrop")

    local saveBtn = WM:CreateControlFromVirtual(nil, win, "ZO_DefaultButton")
    saveBtn:SetDimensions(80, 28)
    saveBtn:SetAnchor(LEFT, editBg, RIGHT, 10, 0)
    saveBtn:SetText("Save")
    saveBtn:SetHandler("OnClicked", function()
        local pName = self.editBox:GetText()
        if pName and pName ~= "" then
            SV().profiles[pName] = ZO_DeepTableCopy(self.selectedPlayers)
            SV().lastProfile = pName
            self:UpdateProfileDropdown()
            self.editBox:SetText("")
        end
    end)

    local comboCtrl = WM:CreateControlFromVirtual(nil, win, "ZO_ComboBox")
    comboCtrl:SetDimensions(140, 26)
    comboCtrl:SetAnchor(TOPLEFT, editBg, BOTTOMLEFT, 0, 15)
    self.comboBox = ZO_ComboBox_ObjectFromContainer(comboCtrl)
    self.comboBox:SetSortsItems(false)

    local loadBtn = WM:CreateControlFromVirtual(nil, win, "ZO_DefaultButton")
    loadBtn:SetDimensions(70, 28)
    loadBtn:SetAnchor(LEFT, comboCtrl, RIGHT, 10, 0)
    loadBtn:SetText("Load")
    loadBtn:SetHandler("OnClicked", function()
        local selected = self.comboBox:GetSelectedItemData()
        if selected and selected.name then
            SV().lastProfile = selected.name
            local prof = SV().profiles[selected.name]
            if prof then
                self.selectedPlayers = ZO_DeepTableCopy(prof)
                self:RefreshRows()
            end
        end
    end)

    local deleteBtn = WM:CreateControlFromVirtual(nil, win, "ZO_DefaultButton")
    deleteBtn:SetDimensions(70, 28)
    deleteBtn:SetAnchor(LEFT, loadBtn, RIGHT, 10, 0)
    deleteBtn:SetText("Delete")
    deleteBtn:SetHandler("OnClicked", function()
        local selected = self.comboBox:GetSelectedItemData()
        if selected and selected.name then
            SV().profiles[selected.name] = nil
            if SV().lastProfile == selected.name then
                SV().lastProfile = ""
            end
            self:UpdateProfileDropdown()
        end
    end)

    self.ui = win
end

function KRT.KWS:UpdateProfileDropdown()
    if not self.comboBox then return end
    self.comboBox:ClearItems()

    if not SV().profiles then
        SV().profiles = {}
    end

    local targetIndex = 1
    local currentIndex = 1

    for pName, _ in pairs(SV().profiles) do
        local entry = self.comboBox:CreateItemEntry(pName, function() end)
        self.comboBox:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)

        if SV().lastProfile == pName then
            targetIndex = currentIndex
        end
        currentIndex = currentIndex + 1
    end

    self.comboBox:UpdateItems()
    local first = next(SV().profiles)
    if first then
        self.comboBox:SelectItemByIndex(targetIndex)
    end
end

local function RestoreRoleColor(row)
    local c = row.roleOriginalColor
    if c then
        row.role:SetColor(c[1], c[2], c[3], c[4])
    else
        row.role:SetColor(1, 1, 1, 1)
    end
end

local function SortGroupMembers(a, b)
    if a.roleWeight ~= b.roleWeight then
        return a.roleWeight < b.roleWeight
    end
    return (a.displayName or "") < (b.displayName or "")
end

function KRT.KWS:RefreshRows()
    if not self.ui or self.ui:IsHidden() then return end

    if self.kickBtn then
        self.kickBtn:SetEnabled(IsUnitGroupLeader("player"))
    end

    local groupSize = IsUnitGrouped("player") and GetGroupSize() or 1
    local myZoneId = GetUnitZoneIndex("player")
    local members = {}

    for i = 1, groupSize do
        local tag = IsUnitGrouped("player") and GetGroupUnitTagByIndex(i) or "player"
        local displayName = GetUnitDisplayName(tag)
        local role = GetGroupMemberSelectedRole(tag)
        local unitZoneId = GetUnitZoneIndex(tag)
        local roleWeight = 3

        if role == LFG_ROLE_TANK then
            roleWeight = 1
        elseif role == LFG_ROLE_HEAL then
            roleWeight = 2
        elseif role == LFG_ROLE_DPS then
            roleWeight = 3
        end

        table.insert(members, {
            tag = tag,
            displayName = displayName,
            role = role,
            roleWeight = roleWeight,
            inMyZone = (unitZoneId == myZoneId),
            isOnline = IsUnitOnline(tag),
        })
    end

    table.sort(members, SortGroupMembers)

    for i = 1, 12 do
        local row = self.rows[i]
        local member = members[i]

        if member then
            row.displayName = member.displayName
            row.nameLabel:SetText(member.displayName)

            local isChecked = self.selectedPlayers[member.displayName] or false
            row.cb.checked = isChecked
            row.cb.UpdateTexture(row.cb, isChecked)

            if member.role == LFG_ROLE_TANK then
                row.role:SetTexture("esoui/art/lfg/lfg_tank_down.dds")
                if member.isOnline then
                    row.role:SetColor(1, 0.2, 0.2, 1)
                else
                    RestoreRoleColor(row)
                end
            elseif member.role == LFG_ROLE_HEAL then
                row.role:SetTexture("esoui/art/lfg/lfg_healer_down.dds")
                if member.isOnline then
                    row.role:SetColor(0.2, 0.6, 1, 1)
                else
                    RestoreRoleColor(row)
                end
            elseif member.role == LFG_ROLE_DPS then
                row.role:SetTexture("esoui/art/lfg/lfg_dps_down.dds")
                if member.isOnline then
                    row.role:SetColor(0.2, 1, 0.2, 1)
                else
                    RestoreRoleColor(row)
                end
            else
                row.role:SetTexture("esoui/art/lfg/lfg_dps_down.dds")
                RestoreRoleColor(row)
            end

            if member.inMyZone then
                row.zoneIcon:SetTexture("esoui/art/buttons/accept_up.dds")
                row.zoneIcon:SetColor(0.2, 1, 0.2, 1)
            else
                row.zoneIcon:SetTexture("esoui/art/buttons/decline_up.dds")
                row.zoneIcon:SetColor(1, 0.2, 0.2, 1)
            end

            row.zoneIcon:SetHidden(false)
            row:SetHidden(false)
        else
            row:SetHidden(true)
            row.displayName = nil
        end
    end
end

function KRT.KWS:ExecuteInvites()
    if self.inviteTimeoutTimer then
        zo_removeCallLater(self.inviteTimeoutTimer)
        self.inviteTimeoutTimer = nil
    end

    if #self.pendingInvites > 0 then
        for _, name in ipairs(self.pendingInvites) do
            GroupInviteByName(name)
        end
        d("[Kwibus Spaulder] Re-invited " .. #self.pendingInvites .. " players.")
    end

    -- Clear lists
    self.pendingInvites = {}
    self.pendingKicksCount = 0
end

function KRT.KWS:KickAndReinvite()
    if not IsUnitGroupLeader("player") then
        d("[Kwibus Spaulder] You must be the group leader to kick players!")
        return
    end

    self.pendingInvites = {}
    self.pendingKicksCount = 0

    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        local displayName = GetUnitDisplayName(tag)

        if self.selectedPlayers[displayName] and not AreUnitsEqual(tag, "player") then
            table.insert(self.pendingInvites, displayName)
            GroupKick(tag)
            self.pendingKicksCount = self.pendingKicksCount + 1
        end
    end

    if self.pendingKicksCount > 0 then
        -- Failsafe: if the server bugs out and misses an EVENT_GROUP_MEMBER_LEFT, force invites after 3 seconds anyway
        if self.inviteTimeoutTimer then
            zo_removeCallLater(self.inviteTimeoutTimer)
        end

        self.inviteTimeoutTimer = zo_callLater(function()
            if self.pendingKicksCount > 0 then
                d("[Kwibus Spaulder] Kick confirmation timeout reached. Forcing invites.")
                self:ExecuteInvites()
            end
        end, 3000)
    end
end

function KRT.KWS:ToggleFragment()
    local groupScene = SCENE_MANAGER:GetScene("groupMenuKeyboard")
    if groupScene and self.fragment then
        local groupSize = IsUnitGrouped("player") and GetGroupSize() or 0
        local shouldShow = SV().enabled and (groupSize >= 5)

        if shouldShow then
            if not groupScene:HasFragment(self.fragment) then
                groupScene:AddFragment(self.fragment)
            end
        else
            if groupScene:HasFragment(self.fragment) then
                groupScene:RemoveFragment(self.fragment)
            end
        end
    end
end

function KRT.KWS:Initialize()
    SV()
    self:CreateUI()

    self.ui = _G["KwibusSpaulderUI"] or self.ui
    if not self.ui or not self.ui.SetHidden then
        d("[KWS] ERROR: KwibusSpaulderUI is not a valid UI control (missing SetHidden).")
        return
    end

    if not self.fragment then
        self.fragment = ZO_SimpleSceneFragment:New(self.ui)
    end

    self:ToggleFragment()

    local function OnGroupUpdate()
        self:ToggleFragment()
        if self.ui and not self.ui:IsHidden() then
            self:RefreshRows()
        end
    end

    local function OnGroupMemberLeft(eventCode, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
        OnGroupUpdate()

        -- If we are waiting for kicks to finish, reduce the tracker and send invites when it hits zero
        if self.pendingKicksCount > 0 then
            -- We only care if the person leaving is someone in our pending invite list
            for _, pendingName in ipairs(self.pendingInvites) do
                if pendingName == memberDisplayName then
                    self.pendingKicksCount = self.pendingKicksCount - 1
                    break
                end
            end

            -- Delay invites by 2s after the last kick is confirmed
            if self.pendingKicksCount <= 0 then
                zo_callLater(function()
                    self:ExecuteInvites()
                end, 2000)
            end
        end
    end

    EM:RegisterForEvent(ADDON_NAME .. "_KWSJoin", EVENT_GROUP_MEMBER_JOINED, OnGroupUpdate)
    EM:RegisterForEvent(ADDON_NAME .. "_KWSLeft", EVENT_GROUP_MEMBER_LEFT, OnGroupMemberLeft)
    EM:RegisterForEvent(ADDON_NAME .. "_KWSRole", EVENT_GROUP_MEMBER_ROLE_CHANGED, OnGroupUpdate)
    EM:RegisterForEvent(ADDON_NAME .. "_KWSLeader", EVENT_LEADER_UPDATE, OnGroupUpdate)

    self.ui:SetHandler("OnEffectivelyShown", function()
        self:RefreshRows()
        self:UpdateProfileDropdown()
    end)
end

function KRT.KWS:GetLAMSubmenu()
    return {
        type = "submenu",
        name = "Kwibus Spaulder",
        controls = {
            {
                type = "checkbox",
                name = "Enable Kwibus Spaulder",
                getFunc = function()
                    if SV().enabled == nil then
                        return true
                    else
                        return SV().enabled
                    end
                end,
                setFunc = function(value)
                    SV().enabled = value
                    self:ToggleFragment()
                end,
            },
            {
                type = "button",
                name = "Center Position",
                func = function()
                    if KRT.KWS.ui then
                        local rootW = GuiRoot:GetWidth()
                        local rootH = GuiRoot:GetHeight()
                        local w = KRT.KWS.ui:GetWidth()
                        local h = KRT.KWS.ui:GetHeight()
                        SV().offsetX = (rootW - w) / 2
                        SV().offsetY = (rootH - h) / 2
                        KRT.KWS.ui:ClearAnchors()
                        KRT.KWS.ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV().offsetX, SV().offsetY)
                    end
                end,
                width = "full",
                disabled = function()
                    return not SV().enabled
                end,
            },
        }
    }
end

KRT:RegisterModule(KRT.KWS)

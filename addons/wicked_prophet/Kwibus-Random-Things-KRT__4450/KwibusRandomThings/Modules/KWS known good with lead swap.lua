local KRT = KwibusRandomThings
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER
local ADDON_NAME = KRT.name

local DEFAULTS = {
    kws = {
        enabled = true,
        debug = false,
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
    selectedKicker = "",
    selectedLead = "",
    kickerComboBox = nil,
    leadComboBox = nil,
    comboBox = nil,
    editBox = nil,
    kickBtn = nil,
    fragment = nil,
    pendingInvites = {},
    pendingKicksCount = 0,
    inviteTimeoutTimer = nil,
    isProcessing = false,
    isPopulating = false,
}
local self = KRT.KWS

local function SV()
    if not KRT.sv then KRT.sv = {} end
    if not KRT.sv.kws then
        KRT.sv.kws = ZO_DeepTableCopy(DEFAULTS.kws)
    end
    if KRT.sv.kws.debug == nil then
        KRT.sv.kws.debug = DEFAULTS.kws.debug
    end
    return KRT.sv.kws
end

local function SyncKALSettings(kicker, lead)
    if self.isPopulating then return end

    if not KRT.sv then return end
    if not KRT.sv.kal then
        KRT.sv.kal = {}
    end

    local changed = false

    if kicker and kicker ~= "" then
        KRT.sv.kal.kickingPerson = kicker
        if KRT.sv.kal.knownAccounts then
            KRT.sv.kal.knownAccounts[kicker] = true
        end
        changed = true
    end

    if lead and lead ~= "" then
        KRT.sv.kal.actualLead = lead
        if KRT.sv.kal.knownAccounts then
            KRT.sv.kal.knownAccounts[lead] = true
        end
        changed = true
    end

    if changed and LibAddonMenu2 and LibAddonMenu2.UpdatePanelControls then
        local panel = _G[ADDON_NAME .. "_Panel"]
        if panel then
            LibAddonMenu2:UpdatePanelControls(panel)
        end
    end
end

function KRT.KWS:PopulateLeadKickerDropdowns()
    if not self.kickerComboBox or not self.leadComboBox then return end

    self.isPopulating = true

    self.kickerComboBox:ClearItems()
    self.leadComboBox:ClearItems()

    local groupSize = IsUnitGrouped("player") and GetGroupSize() or 1
    local kickerIndex = 1
    local leadIndex = 1
    local index = 1

    local noneEntry1 = self.kickerComboBox:CreateItemEntry("None", function()
        self.selectedKicker = ""
        if self.kickerComboBox and self.kickerComboBox.HideDropdown then
            self.kickerComboBox:HideDropdown()
        end
    end)
    self.kickerComboBox:AddItem(noneEntry1, ZO_COMBOBOX_SUPPRESS_UPDATE)

    local noneEntry2 = self.leadComboBox:CreateItemEntry("None", function()
        self.selectedLead = ""
        if self.leadComboBox and self.leadComboBox.HideDropdown then
            self.leadComboBox:HideDropdown()
        end
    end)
    self.leadComboBox:AddItem(noneEntry2, ZO_COMBOBOX_SUPPRESS_UPDATE)

    for i = 1, groupSize do
        local tag = IsUnitGrouped("player") and GetGroupUnitTagByIndex(i) or "player"
        local displayName = GetUnitDisplayName(tag)

        if displayName and displayName ~= "" then
            index = index + 1

            local kickerEntry = self.kickerComboBox:CreateItemEntry(displayName, function()
                self.selectedKicker = displayName
                SyncKALSettings(displayName, nil)
                if self.kickerComboBox and self.kickerComboBox.HideDropdown then
                    self.kickerComboBox:HideDropdown()
                end
            end)
            self.kickerComboBox:AddItem(kickerEntry, ZO_COMBOBOX_SUPPRESS_UPDATE)

            if string.lower(self.selectedKicker) == string.lower(displayName) then
                kickerIndex = index
            end

            local leadEntry = self.leadComboBox:CreateItemEntry(displayName, function()
                self.selectedLead = displayName
                SyncKALSettings(nil, displayName)
                if self.leadComboBox and self.leadComboBox.HideDropdown then
                    self.leadComboBox:HideDropdown()
                end
            end)
            self.leadComboBox:AddItem(leadEntry, ZO_COMBOBOX_SUPPRESS_UPDATE)

            if string.lower(self.selectedLead) == string.lower(displayName) then
                leadIndex = index
            end
        end
    end

    self.kickerComboBox:UpdateItems()
    self.leadComboBox:UpdateItems()

    self.kickerComboBox:SelectItemByIndex(kickerIndex)
    self.leadComboBox:SelectItemByIndex(leadIndex)

    self.isPopulating = false
end

function KRT.KWS:CreateUI()
    if self.ui and self.ui:GetNamedChild("Title") and #self.rows == 12 then
        return
    end

    local win = _G["KwibusSpaulderUI"]
    if not win then
        win = WM:CreateTopLevelWindow("KwibusSpaulderUI")
    end

    win:SetDimensions(320, 650)
    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV().offsetX or 150, SV().offsetY or 150)
    win:SetMouseEnabled(true)
    win:SetMovable(true)
    win:SetClampedToScreen(true)
    win:SetHidden(true)
    win:SetHandler("OnMoveStop", function(control)
        SV().offsetX = control:GetLeft()
        SV().offsetY = control:GetTop()
    end)

    if not win:GetNamedChild("Backdrop") then
        local bg = WM:CreateControlFromVirtual("$(parent)Backdrop", win, "ZO_DefaultBackdrop")
        if bg then bg:SetAnchorFill() end
    end

    if not win:GetNamedChild("Title") then
        local title = WM:CreateControl("$(parent)Title", win, CT_LABEL)
        if title then
            title:SetFont("ZoFontWinH2")
            title:SetText("Kwibus Spaulder")
            title:SetAnchor(TOP, win, TOP, 0, 10)
        end
    end

    for i = 1, 12 do
        local row = self.rows[i]
        if not row or not (row.cb and row.role and row.nameLabel and row.zoneIcon) then
            row = WM:CreateControl(nil, win, CT_CONTROL)
            row:SetDimensions(300, 26)
            row:SetAnchor(TOPLEFT, win, TOPLEFT, 10, 40 + ((i - 1) * 26))

            local cb = WM:CreateControl(nil, row, CT_BUTTON)
            cb:SetDimensions(20, 20)
            cb:SetAnchor(LEFT, row, LEFT, 5, 0)
            cb:SetNormalTexture("esoui/art/buttons/checkbox_unchecked.dds")
            cb:SetMouseOverTexture("esoui/art/buttons/checkbox_mouseover.dds")
            cb:SetPressedTexture("esoui/art/buttons/checkbox_checked.dds")
            cb:SetDisabledTexture("esoui/art/buttons/checkbox_disabled.dds")
            cb.checked = false

            local role = WM:CreateControl(nil, row, CT_TEXTURE)
            role:SetDimensions(24, 24)
            role:SetAnchor(LEFT, cb, RIGHT, 5, 0)

            local rr, rg, rb, ra = role:GetColor()
            row.roleOriginalColor = { rr, rg, rb, ra }

            local nameLabel = WM:CreateControl(nil, row, CT_LABEL)
            nameLabel:SetFont("ZoFontGame")
            nameLabel:SetAnchor(LEFT, role, RIGHT, 5, 0)
            nameLabel:SetDimensions(190, 24)

            local zoneIcon = WM:CreateControl(nil, row, CT_TEXTURE)
            zoneIcon:SetDimensions(24, 24)
            zoneIcon:SetAnchor(LEFT, nameLabel, RIGHT, 5, 0)

            cb:SetHandler("OnClicked", function(control)
                if row.isSelf or self.isProcessing then return end
                control.checked = not control.checked
                if control.checked then
                    control:SetNormalTexture("esoui/art/buttons/checkbox_checked.dds")
                    control:SetMouseOverTexture("esoui/art/buttons/checkbox_checked_mouseover.dds")
                else
                    control:SetNormalTexture("esoui/art/buttons/checkbox_unchecked.dds")
                    control:SetMouseOverTexture("esoui/art/buttons/checkbox_mouseover.dds")
                end
                if row.displayName then
                    self.selectedPlayers[row.displayName] = control.checked
                end
            end)

            row.cb = cb
            row.role = role
            row.nameLabel = nameLabel
            row.zoneIcon = zoneIcon
            self.rows[i] = row
        end
    end

    if not self.kickBtn then
        local kickBtn = WM:CreateControlFromVirtual(nil, win, "ZO_DefaultButton")
        if kickBtn then
            kickBtn:SetAnchor(TOP, win, TOP, 0, 360)
            kickBtn:SetWidth(230)
            kickBtn:SetText("Kick & Re-invite Selected")
            kickBtn:SetHandler("OnClicked", function() self:KickAndReinvite() end)
            self.kickBtn = kickBtn
        end
    end

    if not self.kickerComboBox then
        local leadHeader = WM:CreateControl("$(parent)LeadHeader", win, CT_LABEL)
        if leadHeader then
            leadHeader:SetFont("ZoFontWinH3")
            leadHeader:SetText("Lead Passing Settings")
            leadHeader:SetAnchor(TOPLEFT, win, TOPLEFT, 15, 400)
        end

        local kickerLabel = WM:CreateControl("$(parent)KickerLabel", win, CT_LABEL)
        if kickerLabel then
            kickerLabel:SetFont("ZoFontGame")
            kickerLabel:SetText("Kicker:")
            kickerLabel:SetAnchor(TOPLEFT, leadHeader, BOTTOMLEFT, 0, 8)
        end

        local kickerCtrl = WM:CreateControlFromVirtual("KwibusKickerComboBox", win, "ZO_ComboBox")
        if kickerCtrl and kickerLabel then
            kickerCtrl:SetDimensions(210, 24)
            kickerCtrl:SetAnchor(LEFT, kickerLabel, RIGHT, 10, 0)
            self.kickerComboBox = ZO_ComboBox_ObjectFromContainer(kickerCtrl)
            if self.kickerComboBox then
                self.kickerComboBox:SetSortsItems(false)
            end
        end

        local leadLabel = WM:CreateControl("$(parent)LeadLabel", win, CT_LABEL)
        if leadLabel and kickerLabel then
            leadLabel:SetFont("ZoFontGame")
            leadLabel:SetText("Lead:")
            leadLabel:SetAnchor(TOPLEFT, kickerLabel, BOTTOMLEFT, 0, 12)
        end

        local leadCtrl = WM:CreateControlFromVirtual("KwibusLeadComboBox", win, "ZO_ComboBox")
        if leadCtrl and leadLabel then
            leadCtrl:SetDimensions(210, 24)
            leadCtrl:SetAnchor(LEFT, leadLabel, RIGHT, 22, 0)
            self.leadComboBox = ZO_ComboBox_ObjectFromContainer(leadCtrl)
            if self.leadComboBox then
                self.leadComboBox:SetSortsItems(false)
            end
        end
    end

    if not self.comboBox then
        local pTitle = WM:CreateControl(nil, win, CT_LABEL)
        if pTitle then
            pTitle:SetFont("ZoFontWinH3")
            pTitle:SetText("Profiles")
            pTitle:SetAnchor(TOPLEFT, win, TOPLEFT, 15, 510)
        end

        local editBg = WM:CreateControlFromVirtual(nil, win, "ZO_EditBackdrop")
        if editBg then
            editBg:SetDimensions(190, 26)
            editBg:SetAnchor(TOPLEFT, pTitle, BOTTOMLEFT, 0, 8)
            self.editBox = WM:CreateControlFromVirtual(nil, editBg, "ZO_DefaultEditForBackdrop")
        end

        local saveBtn = WM:CreateControlFromVirtual(nil, win, "ZO_DefaultButton")
        if saveBtn and editBg then
            saveBtn:SetDimensions(80, 28)
            saveBtn:SetAnchor(LEFT, editBg, RIGHT, 10, 0)
            saveBtn:SetText("Save")
            saveBtn:SetHandler("OnClicked", function()
                if self.editBox then
                    local pName = self.editBox:GetText()
                    if pName and pName ~= "" then
                        SV().profiles[pName] = {
                            selectedPlayers = ZO_DeepTableCopy(self.selectedPlayers),
                            kicker = self.selectedKicker,
                            lead = self.selectedLead,
                        }
                        SV().lastProfile = pName
                        self:UpdateProfileDropdown()
                        self.editBox:SetText("")
                    end
                end
            end)
        end

        local comboCtrl = WM:CreateControlFromVirtual("KwibusProfileComboBox", win, "ZO_ComboBox")
        if comboCtrl and editBg then
            comboCtrl:SetDimensions(130, 26)
            comboCtrl:SetAnchor(TOPLEFT, editBg, BOTTOMLEFT, 0, 15)
            self.comboBox = ZO_ComboBox_ObjectFromContainer(comboCtrl)
            if self.comboBox then
                self.comboBox:SetSortsItems(false)
            end
        end

        local loadBtn = WM:CreateControlFromVirtual(nil, win, "ZO_DefaultButton")
        if loadBtn and comboCtrl then
            loadBtn:SetDimensions(70, 28)
            loadBtn:SetAnchor(LEFT, comboCtrl, RIGHT, 10, 0)
            loadBtn:SetText("Load")
            loadBtn:SetHandler("OnClicked", function()
                if self.comboBox then
                    local selected = self.comboBox:GetSelectedItemData()
                    if selected and selected.name then
                        SV().lastProfile = selected.name
                        local profData = SV().profiles and SV().profiles[selected.name]
                        if profData then
                            if profData.selectedPlayers then
                                self.selectedPlayers = ZO_DeepTableCopy(profData.selectedPlayers)
                            else
                                self.selectedPlayers = ZO_DeepTableCopy(profData)
                            end

                            if profData.kicker and profData.kicker ~= "" then
                                self.selectedKicker = profData.kicker
                            end

                            if profData.lead and profData.lead ~= "" then
                                self.selectedLead = profData.lead
                            end

                            SyncKALSettings(self.selectedKicker, self.selectedLead)
                            self:RefreshRows()
                        end
                    end
                end
            end)
        end

        local deleteBtn = WM:CreateControlFromVirtual(nil, win, "ZO_DefaultButton")
        if deleteBtn and loadBtn then
            deleteBtn:SetDimensions(70, 28)
            deleteBtn:SetAnchor(LEFT, loadBtn, RIGHT, 10, 0)
            deleteBtn:SetText("Delete")
            deleteBtn:SetHandler("OnClicked", function()
                if self.comboBox then
                    local selected = self.comboBox:GetSelectedItemData()
                    if selected and selected.name then
                        if SV().profiles then
                            SV().profiles[selected.name] = nil
                        end
                        if SV().lastProfile == selected.name then
                            SV().lastProfile = ""
                        end
                        self:UpdateProfileDropdown()
                    end
                end
            end)
        end
    end

    self.ui = win
end

function KRT.KWS:UpdateProfileDropdown()
    if not self.comboBox then return end
    self.comboBox:ClearItems()

    local sv = SV()
    if not sv.profiles then
        sv.profiles = {}
    end

    local targetIndex = 1
    local currentIndex = 1

    for pName, _ in pairs(sv.profiles) do
        local entry = self.comboBox:CreateItemEntry(pName, function() end)
        if entry then
            self.comboBox:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)

            if sv.lastProfile == pName then
                targetIndex = currentIndex
            end
            currentIndex = currentIndex + 1
        end
    end

    self.comboBox:UpdateItems()
    local first = next(sv.profiles)
    if first then
        self.comboBox:SelectItemByIndex(targetIndex)
    end
end

local function RestoreRoleColor(row)
    if not row or not row.role then return end
    local c = row.roleOriginalColor
    if c then
        row.role:SetColor(c[1], c[2], c[3], c[4])
    else
        row.role:SetColor(1, 1, 1, 1)
    end
end

local function SortGroupMembers(a, b)
    if not a or not b then return false end
    if a.roleWeight ~= b.roleWeight then
        return a.roleWeight < b.roleWeight
    end
    return (a.displayName or "") < (b.displayName or "")
end

function KRT.KWS:RefreshRows()
    if not self.ui then
        self:CreateUI()
    end

    if not self.ui or self.ui:IsHidden() then return end

    if self.kickBtn then
        self.kickBtn:SetEnabled((IsUnitGroupLeader("player") or SV().debug) and not self.isProcessing)
    end

    self:PopulateLeadKickerDropdowns()

    local groupSize = IsUnitGrouped("player") and GetGroupSize() or 1
    local myZoneId = GetUnitZoneIndex("player")
    local myDisplayName = string.lower(GetDisplayName() or "")
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

        local isSelf = AreUnitsEqual(tag, "player") or (displayName and string.lower(displayName) == myDisplayName)

        table.insert(members, {
            tag = tag,
            displayName = displayName,
            role = role,
            roleWeight = roleWeight,
            inMyZone = (unitZoneId == myZoneId),
            isOnline = IsUnitOnline(tag),
            isSelf = isSelf,
        })
    end

    table.sort(members, SortGroupMembers)

    for i = 1, 12 do
        local row = self.rows[i]
        local member = members[i]

        if row and row.cb and row.nameLabel and row.role and row.zoneIcon then
            if member then
                row.displayName = member.displayName
                row.isSelf = member.isSelf
                row.nameLabel:SetText(member.displayName or "")

                if member.isSelf then
                    row.cb:SetEnabled(false)
                    row.cb.checked = false
                    row.cb:SetNormalTexture("esoui/art/buttons/checkbox_disabled.dds")
                    row.cb:SetMouseOverTexture("esoui/art/buttons/checkbox_disabled.dds")
                    row.nameLabel:SetColor(0.5, 0.5, 0.5, 1)
                    if member.displayName then
                        self.selectedPlayers[member.displayName] = false
                    end
                else
                    row.cb:SetEnabled(not self.isProcessing)
                    row.nameLabel:SetColor(1, 1, 1, 1)
                    local isChecked = (member.displayName and self.selectedPlayers[member.displayName]) or false
                    row.cb.checked = isChecked
                    if isChecked then
                        row.cb:SetNormalTexture("esoui/art/buttons/checkbox_checked.dds")
                        row.cb:SetMouseOverTexture("esoui/art/buttons/checkbox_checked_mouseover.dds")
                    else
                        row.cb:SetNormalTexture("esoui/art/buttons/checkbox_unchecked.dds")
                        row.cb:SetMouseOverTexture("esoui/art/buttons/checkbox_mouseover.dds")
                    end
                end

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
                row.isSelf = false
            end
        end
    end
end

function KRT.KWS:ExecuteInvites()
    if self.inviteTimeoutTimer then
        zo_removeCallLater(self.inviteTimeoutTimer)
        self.inviteTimeoutTimer = nil
    end

    if self.pendingInvites and #self.pendingInvites > 0 then
        for _, name in ipairs(self.pendingInvites) do
            if name and name ~= "" then
                GroupInviteByName(name)
            end
        end
        d("[Kwibus Spaulder] Re-invited " .. #self.pendingInvites .. " players.")
    end

    self.pendingInvites = {}
    self.pendingKicksCount = 0
    self.isProcessing = false
    self:RefreshRows()
end

function KRT.KWS:KickAndReinvite()
    if self.isProcessing then
        return
    end

    if not IsUnitGroupLeader("player") and not SV().debug then
        d("[Kwibus Spaulder] You must be the group leader to kick players!")
        return
    end

    self.isProcessing = true
    self.pendingInvites = {}
    self.pendingKicksCount = 0

    if self.kickBtn then
        self.kickBtn:SetEnabled(false)
    end

    local groupSize = GetGroupSize() or 0
    for i = 1, groupSize do
        local tag = GetGroupUnitTagByIndex(i)
        if tag then
            local displayName = GetUnitDisplayName(tag)

            if displayName and self.selectedPlayers[displayName] and not AreUnitsEqual(tag, "player") then
                table.insert(self.pendingInvites, displayName)
                GroupKick(tag)
                self.pendingKicksCount = self.pendingKicksCount + 1
            end
        end
    end

    if self.pendingKicksCount > 0 then
        if self.inviteTimeoutTimer then
            zo_removeCallLater(self.inviteTimeoutTimer)
        end

        self.inviteTimeoutTimer = zo_callLater(function()
            if self.pendingKicksCount > 0 then
                d("[Kwibus Spaulder] Kick confirmation timeout reached. Forcing invites.")
                self:ExecuteInvites()
            end
        end, 3000)
    else
        self.isProcessing = false
        self:RefreshRows()
    end
end

function KRT.KWS:ToggleFragment()
    local groupScene = SCENE_MANAGER and SCENE_MANAGER:GetScene("groupMenuKeyboard")
    if groupScene and self.fragment then
        local groupSize = IsUnitGrouped("player") and GetGroupSize() or 0
        local shouldShow = SV().enabled and (SV().debug or groupSize >= 5)

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

        if self.pendingKicksCount > 0 then
            for _, pendingName in ipairs(self.pendingInvites) do
                if pendingName and memberDisplayName and pendingName == memberDisplayName then
                    self.pendingKicksCount = self.pendingKicksCount - 1
                    break
                end
            end

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
                type = "checkbox",
                name = "Debug Mode (Force UI Visible)",
                tooltip = "Force UI overlay to show in group menu regardless of group status or group size.",
                getFunc = function()
                    return SV().debug or false
                end,
                setFunc = function(value)
                    SV().debug = value
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
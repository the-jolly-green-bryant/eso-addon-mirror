local Addon = NMGuildHall
local UI = Addon.UI

local function UILogger()
    if Addon and Addon.Message and Addon.Message.For then
        return Addon.Message:For("UI")
    end
    return nil
end
local BUTTON_WIDTH = 300
local BUTTON_HEIGHT = 42
local ACTION_BUTTON_WIDTH = 280
local ACTION_BUTTON_HEIGHT = 60

-- Create base action button (used by group button pool)
function UI:CreateBaseActionButton(parent)
    self.actionButtonCounter = (self.actionButtonCounter or 0) + 1
    local timestamp = GetGameTimeMilliseconds()
    local btnName = "NMGuildHall_ActionButton_" .. self.actionButtonCounter .. "_" .. timestamp

    local btn = WINDOW_MANAGER:CreateControl(btnName, parent or self.content or GuiRoot, CT_BUTTON)
    if not btn then
        local log = UILogger()
        if log then
            log:Error(GetString(NMGH_ERR_ACTION_BTN_CREATE_FAILED), {name = btnName})
        end
        return nil
    end

    btn:SetDimensions(ACTION_BUTTON_WIDTH, ACTION_BUTTON_HEIGHT)

    -- Style
    local bgName = btnName .. "_BG"
    local bg = WINDOW_MANAGER:CreateControl(bgName, btn, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterTexture("EsoUI/Art/Miscellaneous/centerscreen_floating_center.dds")
    bg:SetCenterColor(0.08, 0.08, 0.12, 0.95)
    bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chatBG_edge.dds", 4, 4, 1, 1)
    bg:SetEdgeColor(0.8, 0.2, 0.3, 1.0)
    bg:SetInsets(2, 2, -2, -2)

    local labelName = btnName .. "_Label"
    local label = WINDOW_MANAGER:CreateControl(labelName, btn, CT_LABEL)
    label:SetFont("ZoFontGameLargeBold")
    label:SetAnchor(CENTER, btn, CENTER, 0, 0)
    label:SetColor(1, 1, 1, 1)

    btn.background = bg
    btn.label = label

    -- Hover/press handlers
    btn:SetHandler("OnMouseEnter", function()
        bg:SetCenterColor(0.15, 0.15, 0.20, 0.95)
        bg:SetEdgeColor(1.0, 0.3, 0.4, 1.0)
        bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chatBG_edge.dds", 8, 8, 1, 1)
    end)
    btn:SetHandler("OnMouseExit", function()
        bg:SetCenterColor(0.08, 0.08, 0.12, 0.9)
        bg:SetEdgeColor(0.8, 0.2, 0.3, 1.0)
        bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chatBG_edge.dds", 4, 4, 1, 1)
    end)
    btn:SetHandler("OnMouseDown", function()
        bg:SetCenterColor(0.05, 0.05, 0.08, 1.0)
        bg:SetEdgeColor(1.0, 0.4, 0.5, 1.0)
        bg:SetInsets(1, 1, -1, -1)
    end)
    btn:SetHandler("OnMouseUp", function()
        bg:SetCenterColor(0.15, 0.15, 0.20, 0.95)
        bg:SetEdgeColor(1.0, 0.3, 0.4, 1.0)
        bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chatBG_edge.dds", 8, 8, 1, 1)
        bg:SetInsets(2, 2, -2, -2)
    end)

    return btn
end

function UI:CreateModalEdit()
    if self.modalEditOverlay then
        return
    end

    local overlay, overlayBg = self:_CreateOverlay({
        controlPrefix = "NMGuildHall_ModalEdit",
        onDismiss = function()
            self:HideModalEdit()
        end,
    })
    if not overlay then
        return
    end

    local dialog = WINDOW_MANAGER:CreateControl("NMGuildHall_ModalEditDialog", overlay, CT_CONTROL)
    dialog:SetDimensions(760, 520)
    dialog:SetAnchor(CENTER, overlay, CENTER, 0, 0)

    local dialogBg = WINDOW_MANAGER:CreateControl("NMGuildHall_ModalEditDialogBG", dialog, CT_BACKDROP)
    dialogBg:SetAnchorFill()
    dialogBg:SetCenterColor(0.02, 0.02, 0.02, 1)
    dialogBg:SetEdgeTexture("EsoUI/Art/ChatWindow/chatBG_edge.dds", 2, 2, 1, 1)
    dialogBg:SetEdgeColor(0.8, 0.2, 0.3, 1)
    dialogBg:SetInsets(2, 2, -2, -2)

    local header = WINDOW_MANAGER:CreateControl("NMGuildHall_ModalEditDialogHeader", dialog, CT_TEXTURE)
    header:SetDimensions(760, 46)
    header:SetAnchor(TOP, dialog, TOP, 0, 0)
    header:SetTexture("EsoUI/Art/Performance/StatusMeter_BG.dds")
    header:SetColor(0.2, 0.05, 0.05, 1)

    local closeBtn = WINDOW_MANAGER:CreateControl("NMGuildHall_ModalEditDialogClose", dialog, CT_BUTTON)
    closeBtn:SetDimensions(24, 24)
    closeBtn:SetAnchor(TOPRIGHT, dialog, TOPRIGHT, -8, 8)
    closeBtn:SetNormalTexture("EsoUI/Art/Buttons/closeButton_up.dds")
    closeBtn:SetMouseOverTexture("EsoUI/Art/Buttons/closeButton_over.dds")
    closeBtn:SetHandler("OnClicked", function()
        self:HideModalEdit()
    end)

    local title = WINDOW_MANAGER:CreateControl("NMGuildHall_ModalEditDialogTitle", dialog, CT_LABEL)
    title:SetFont("ZoFontWinH3")
    title:SetAnchor(TOP, dialog, TOP, 0, 8)
    title:SetColor(0.9, 0.2, 0.3, 1)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local divider = WINDOW_MANAGER:CreateControl("NMGuildHall_ModalEditDialogDivider", dialog, CT_TEXTURE)
    divider:SetDimensions(700, 4)
    divider:SetAnchor(TOP, header, BOTTOM, 0, 0)
    divider:SetTexture("EsoUI/Art/Miscellaneous/horizontal_divider.dds")
    divider:SetColor(0.8, 0.2, 0.3, 0.6)

    local body = WINDOW_MANAGER:CreateControl("NMGuildHall_ModalEditDialogBody", dialog, CT_LABEL)
    body:SetFont("ZoFontGameLarge")
    body:SetAnchor(TOP, divider, BOTTOM, 0, 18)
    body:SetWidth(700)
    body:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    body:SetColor(0.9, 0.9, 0.9, 1)

    local editBox = nil
    local okEdit, created = pcall(function()
        return WINDOW_MANAGER:CreateControlFromVirtual("NMGuildHall_ModalEditDialogEdit", dialog, "ZO_DefaultEditMultiLine")
    end)
    if okEdit then
        editBox = created
    end
    if not editBox then
        editBox = WINDOW_MANAGER:CreateControlFromVirtual("NMGuildHall_ModalEditDialogEdit", dialog, "ZO_DefaultEdit")
        if editBox.SetMultiLine then
            editBox:SetMultiLine(true)
        end
        if editBox.SetNewLineEnabled then
            editBox:SetNewLineEnabled(true)
        end
    end
    editBox:SetAnchor(TOP, body, BOTTOM, 0, 12)
    editBox:SetDimensions(700, 320)
    if editBox.SetMaxInputChars then
        editBox:SetMaxInputChars(10000)
    end
    if editBox.SetColor then
        editBox:SetColor(1, 1, 1, 1)
    end

    local acceptBtn = self:CreateBaseActionButton(dialog)
    if acceptBtn then
        acceptBtn:SetDimensions(220, 36)
        acceptBtn:ClearAnchors()
        acceptBtn:SetAnchor(BOTTOM, dialog, BOTTOM, -130, -18)
        if acceptBtn.label then
            acceptBtn.label:SetFont("ZoFontGameBold")
        end
    end

    local cancelBtn = self:CreateBaseActionButton(dialog)
    if cancelBtn then
        cancelBtn:SetDimensions(220, 36)
        cancelBtn:ClearAnchors()
        cancelBtn:SetAnchor(BOTTOM, dialog, BOTTOM, 130, -18)
        if cancelBtn.label then
            cancelBtn.label:SetFont("ZoFontGameBold")
        end
    end

    self.modalEditOverlay = overlay
    self.modalEditOverlayBg = overlayBg
    self.modalEditDialog = dialog
    self.modalEditDialogBg = dialogBg
    self.modalEditDialogHeader = header
    self.modalEditDialogDivider = divider
    self.modalEditCloseBtn = closeBtn
    self.modalEditTitle = title
    self.modalEditBody = body
    self.modalEditEdit = editBox
    self.modalEditAcceptBtn = acceptBtn
    self.modalEditCancelBtn = cancelBtn
    self._modalEditState = nil
end

function UI:ShowModalEdit(params)
    params = params or {}

    if not self.modalEditOverlay then
        self:CreateModalEdit()
    end
    if not self.modalEditOverlay then
        return false
    end

    if self.dialogOverlay and self.dialogOverlay.IsHidden then
        local ok, hidden = pcall(self.dialogOverlay.IsHidden, self.dialogOverlay)
        if ok and hidden ~= true then
            self:HideDialog({
                skipSound = true,
                suppressParentHide = true,
            })
        end
    end

    local title = tostring(params.title or "")
    local body = tostring(params.body or "")
    local text = tostring(params.text or "")
    local readOnly = params.readOnly == true
    local hasAccept = type(params.onAccept) == "function"

    self.modalEditTitle:SetText(title)
    self.modalEditBody:SetText(body)
    self.modalEditEdit:SetText(text)

    if self.modalEditEdit.SetEditEnabled then
        self.modalEditEdit:SetEditEnabled(not readOnly)
    end

    self._modalEditState = {
        onAccept = params.onAccept,
        onCancel = params.onCancel,
    }

    if self.modalEditAcceptBtn then
        self.modalEditAcceptBtn:SetHidden(false)
        if self.modalEditAcceptBtn.label then
            self.modalEditAcceptBtn.label:SetText(hasAccept and tostring(params.acceptText or GetString(SI_DIALOG_ACCEPT)) or tostring(params.closeText or GetString(SI_DIALOG_CLOSE)))
        end
        self.modalEditAcceptBtn:SetHandler("OnClicked", function()
            if not hasAccept then
                self:HideModalEdit({ fireCancel = false })
                return
            end

            local current = self.modalEditEdit and self.modalEditEdit.GetText and self.modalEditEdit:GetText() or ""
            local ok = true
            local success, result = pcall(self._modalEditState.onAccept, current)
            ok = success and (result ~= false)
            if ok then
                self:HideModalEdit({ fireCancel = false })
            end
        end)
    end

    if self.modalEditCancelBtn then
        self.modalEditCancelBtn:SetHidden(not hasAccept)
        if hasAccept and self.modalEditCancelBtn.label then
            self.modalEditCancelBtn.label:SetText(tostring(params.cancelText or GetString(SI_DIALOG_CANCEL)))
        end
        if hasAccept then
            self.modalEditCancelBtn:SetHandler("OnClicked", function()
                self:HideModalEdit()
            end)
        else
            self.modalEditCancelBtn:SetHandler("OnClicked", nil)
        end
    end

    self.modalEditOverlay:SetHidden(false)
    PlaySound(SOUNDS.DIALOG_SHOW)

    if self.modalEditEdit.TakeFocus then
        self.modalEditEdit:TakeFocus()
    end
    if params.selectAll == true and self.modalEditEdit.SelectAll then
        self.modalEditEdit:SelectAll()
    end

    return true
end

function UI:HideModalEdit(opts)
    opts = opts or {}
    if not self.modalEditOverlay then
        return
    end

    local overlayWasHidden = false
    if self.modalEditOverlay.IsHidden then
        local ok, hidden = pcall(self.modalEditOverlay.IsHidden, self.modalEditOverlay)
        overlayWasHidden = ok and hidden == true
    end

    local state = self._modalEditState
    self._modalEditState = nil
    self.modalEditOverlay:SetHidden(true)

    if not overlayWasHidden and opts.skipSound ~= true then
        PlaySound(SOUNDS.DIALOG_CLOSE)
    end

    if not overlayWasHidden and opts.fireCancel ~= false and state and type(state.onCancel) == "function" then
        pcall(state.onCancel)
    end
end

function UI:CreateExportModal()
    self:CreateModalEdit()
end

function UI:ShowExportModal(exportString)
    if type(exportString) ~= "string" or exportString == "" then
        return
    end

    self:ShowModalEdit({
        title = GetString(NMGH_SETTINGS_EXPORT_DIALOG_TITLE),
        body = GetString(NMGH_SETTINGS_EXPORT_DIALOG_BODY),
        text = exportString,
        readOnly = true,
        selectAll = true,
        closeText = GetString(SI_DIALOG_CLOSE),
    })
end

function UI:HideExportModal(opts)
    self:HideModalEdit({
        fireCancel = false,
        skipSound = opts and opts.skipSound == true,
    })
end

function UI:CreateImportModal()
    self:CreateModalEdit()
end

function UI:ShowImportModal()
    self:ShowModalEdit({
        title = GetString(NMGH_SETTINGS_IMPORT_DIALOG_TITLE),
        body = GetString(NMGH_SETTINGS_IMPORT_DIALOG_BODY),
        text = "",
        readOnly = false,
        acceptText = GetString(SI_DIALOG_ACCEPT),
        cancelText = GetString(SI_DIALOG_CANCEL),
        onAccept = function(current)
            if Addon and Addon.Settings and Addon.Settings.ImportSettings then
                local ok, result = pcall(Addon.Settings.ImportSettings, Addon.Settings, current)
                return ok and result == true
            end
            return false
        end,
    })
end

function UI:HideImportModal(opts)
    self:HideModalEdit({
        fireCancel = false,
        skipSound = opts and opts.skipSound == true,
    })
end

-- Initialize a pool for group action buttons
function UI:CreateGroupButtonPool()
    self.groupButtonPool = ZO_ObjectPool:New(
        function()
            return self:CreateBaseActionButton()
        end,
        function(button)
            if not button then return end
            if button.SetHandler then
                button:SetHandler("OnClicked", nil)
            end
            if button.ClearAnchors then
                button:ClearAnchors()
            end
            if button.SetHidden then
                button:SetHidden(true)
            end
            if button.label then
                button.label:SetText("")
                button.label:SetColor(1, 1, 1, 1)
            end
            if button.background then
                button.background:SetCenterColor(0.08, 0.08, 0.12, 0.95)
                button.background:SetEdgeTexture("EsoUI/Art/ChatWindow/chatBG_edge.dds", 4, 4, 1, 1)
                button.background:SetEdgeColor(0.8, 0.2, 0.3, 1.0)
                button.background:SetInsets(2, 2, -2, -2)
            end
        end
    )
end

-- Acquire and configure a pooled group action button
function UI:AcquireGroupActionButton(parent, xOffset, yOffset, text, icon, callback)
    if not self.groupButtonPool then
        self:CreateGroupButtonPool()
    end
    local btn = self.groupButtonPool:AcquireObject()
    if not btn then return nil end

    btn:SetParent(parent)
    btn:ClearAnchors()
    btn:SetAnchor(TOP, parent, TOP, xOffset, yOffset)

    local labelText = text
    if icon and icon ~= "" then
        labelText = "|t32:32:" .. icon .. "|t " .. text
    end
    if btn.label then
        btn.label:SetText(labelText)
    end

    local safeCallback = function()
        if callback and type(callback) == "function" then
            local ok, err = pcall(callback)
            if not ok then
                local log = UILogger()
                if log then
                    log:Error(GetString(NMGH_ERR_ACTION_BTN_CALLBACK), {error = tostring(err)})
                end
            end
        end
    end
    btn:SetHandler("OnClicked", safeCallback)
    btn:SetHidden(false)
    return btn
end

-- Initialize a pool for campaign rows
function UI:CreateCampaignRowPool()
    self.campaignRowPool = ZO_ObjectPool:New(
        function()
            return self:CreateCampaignRow()
        end,
        function(row)
            if not row then return end
            row:SetHidden(true)
            row:ClearAnchors()
            if row.SetHandler then
                row:SetHandler("OnMouseUp", nil)
            end
            if row.background then
                row.background:SetCenterColor(0.08, 0.08, 0.12, 0.9)
                row.background:SetEdgeColor(0.3, 0.3, 0.35, 0.8)
            end
            -- Reset child controls if necessary
        end
    )
end

-- Create a campaign row control
function UI:CreateCampaignRow()
    self.campaignRowCounter = (self.campaignRowCounter or 0) + 1
    local rowName = "NMGuildHall_CampaignRow_" .. self.campaignRowCounter
    local row = WINDOW_MANAGER:CreateControl(rowName, self.campaignScrollChild or GuiRoot, CT_CONTROL)
    row:SetDimensions(640, 36)
    row:SetMouseEnabled(true)

    -- Background
    local bg = WINDOW_MANAGER:CreateControl(rowName .. "_BG", row, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.08, 0.08, 0.12, 0.9)
    bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chatBG_edge.dds", 2, 2, 1, 1)
    bg:SetEdgeColor(0.3, 0.3, 0.35, 0.8)
    bg:SetInsets(1, 1, -1, -1)
    row.background = bg

    -- Name
    local nameControl = WINDOW_MANAGER:CreateControl(rowName .. "_Name", row, CT_LABEL)
    nameControl:SetFont("ZoFontGameBold")
    nameControl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    nameControl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    nameControl:SetColor(1, 1, 1, 1)
    nameControl:SetAnchor(LEFT, row, LEFT, 10, 0)
    nameControl:SetWidth(200)
    row.nameLabel = nameControl

    -- Category
    local catControl = WINDOW_MANAGER:CreateControl(rowName .. "_Category", row, CT_LABEL)
    catControl:SetFont("ZoFontGameSmall")
    catControl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    catControl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    catControl:SetColor(0.6, 0.6, 0.6, 1)
    catControl:SetAnchor(LEFT, nameControl, RIGHT, 5, 0)
    row.catLabel = catControl

    -- Info
    local infoControl = WINDOW_MANAGER:CreateControl(rowName .. "_Info", row, CT_LABEL)
    infoControl:SetFont("ZoFontGameSmall")
    infoControl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    infoControl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    infoControl:SetColor(0.8, 0.8, 0.8, 1)
    infoControl:SetDimensions(150, 20)
    row.infoLabel = infoControl

    -- Social Columns
    row.socialCols = {}
    local socialStartOffset = 330
    local colWidth = 55
    local socialTypes = {"Guild", "Friends", "Group"}
    local socialIcons = {
        "EsoUI/Art/Campaign/campaignbrowser_guild.dds",
        "EsoUI/Art/Campaign/campaignbrowser_friends.dds",
        "EsoUI/Art/Campaign/campaignbrowser_group.dds"
    }

    for i, typeSuffix in ipairs(socialTypes) do
        local col = WINDOW_MANAGER:CreateControl(rowName .. "_Social_" .. typeSuffix, row, CT_CONTROL)
        col:SetDimensions(colWidth, 20)
        col:SetAnchor(LEFT, row, LEFT, socialStartOffset + (i - 1) * colWidth, 0)
        
        local icon = WINDOW_MANAGER:CreateControl(col:GetName() .. "_Icon", col, CT_TEXTURE)
        icon:SetDimensions(18, 18)
        icon:SetTexture(socialIcons[i])
        icon:SetAnchor(LEFT, col, LEFT, 0, 0)
        
        local label = WINDOW_MANAGER:CreateControl(col:GetName() .. "_Label", col, CT_LABEL)
        label:SetFont("ZoFontGameSmall")
        label:SetColor(1, 1, 1, 1)
        label:SetAnchor(LEFT, icon, RIGHT, 4, 0)
        
        row.socialCols[typeSuffix] = { container = col, icon = icon, label = label }
    end

    -- Alliance Icons
    row.allianceIcons = {}
    local iconSize = 20
    local iconSpacing = 4
    local allianceSuffixes = {"AD", "EP", "DC"}
    for i, suffix in ipairs(allianceSuffixes) do
        local icon = WINDOW_MANAGER:CreateControl(rowName .. "_" .. suffix, row, CT_TEXTURE)
        icon:SetDimensions(iconSize, iconSize)
        -- Anchors will be set in RefreshCampaignList as they depend on the row layout
        row.allianceIcons[i] = icon
    end

    -- Interaction Handlers
    row:SetHandler("OnMouseEnter", function()
        bg:SetCenterColor(0.15, 0.15, 0.2, 0.9)
        bg:SetEdgeColor(0.5, 0.5, 0.6, 1)
    end)
    row:SetHandler("OnMouseExit", function()
        bg:SetCenterColor(0.08, 0.08, 0.12, 0.9)
        bg:SetEdgeColor(0.3, 0.3, 0.35, 0.8)
    end)
    row:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            local campaignId = row.campaignId
            local campaignData = CAMPAIGN_BROWSER_MANAGER and CAMPAIGN_BROWSER_MANAGER:GetDataByCampaignId(campaignId)
            if not campaignData then
                if NMGuildHall and NMGuildHall.Message then
                    NMGuildHall.Message:Error(GetString(NMGH_ERR_EVENT_NOT_FOUND), {eventName = tostring(campaignId)})
                end
                return
            end
            local isGrouped = IsUnitGrouped("player")
            if NMGuildHall.Campaign then
                NMGuildHall.Campaign:ShowQueueDialog(campaignData)
            end
        end
    end)

    return row
end

-- Create a single teleport button (factory function for object pool)
function UI:CreateTeleportButton()
    self.teleportButtonCounter = self.teleportButtonCounter + 1
    -- Use unique identifier to prevent name collisions
    local uniqueId = GetGameTimeMilliseconds() .. "_" .. self.teleportButtonCounter
    local btnName = "NMGuildHall_TeleportButton_" .. uniqueId
    local bgName  = btnName .. "_BG"
    local iconName = btnName .. "_Icon"
    local labelName = btnName .. "_Label"

    -- Create button
    local btn = WINDOW_MANAGER:CreateControl(btnName, self.teleportScrollChild, CT_BUTTON)
    btn:SetDimensions(BUTTON_WIDTH, BUTTON_HEIGHT)

    -- Use standardized ESO button styling for consistency
    local bg = WINDOW_MANAGER:CreateControl(bgName, btn, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.08, 0.08, 0.12, 0.9) -- Default background
    bg:SetEdgeTexture("", 1, 1, 0, 0) -- No edges
    bg:SetEdgeColor(0, 0, 0, 0) -- Transparent edges
    bg:SetInsets(2, 2, -2, -2) -- Shadow for depth
    btn.background = bg

    -- Icon texture (separate control)
    local icon = WINDOW_MANAGER:CreateControl(iconName, btn, CT_TEXTURE)
    icon:SetDimensions(24, 24)
    icon:SetAnchor(LEFT, btn, LEFT, 8, 0)
    icon:SetHidden(true) -- Hidden by default, shown when icon is set
    btn.icon = icon

    -- Label with text (positioned to the right of icon)
    local label = WINDOW_MANAGER:CreateControl(labelName, btn, CT_LABEL)
    label:SetFont("ZoFontGame")
    label:SetAnchor(LEFT, icon, RIGHT, 4, 0) -- Position to right of icon
    label:SetAnchor(RIGHT, btn, RIGHT, -8, 0) -- Stretch to right edge
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(1, 1, 1, 1)
    btn.label = label

    return btn
end

-- Initialize the object pool for teleport buttons with proper cleanup
function UI:CreateTeleportButtonPool()
    self.teleportButtonPool = ZO_ObjectPool:New(
        function() -- Factory
            return self:CreateTeleportButton()
        end,
        function(button) -- Reset with proper cleanup
            if not button then return end

            -- Clear all handlers to prevent memory leaks
            if button.SetHandler then
                button:SetHandler("OnClicked", nil)
                button:SetHandler("OnMouseEnter", nil)
                button:SetHandler("OnMouseExit", nil)
                button:SetHandler("OnMouseDown", nil)
                button:SetHandler("OnMouseUp", nil)
                button:SetHandler("OnUpdate", nil)
                button:SetHandler("OnEffectivelyShown", nil)
                button:SetHandler("OnEffectivelyHidden", nil)
            end

            -- Clear anchors
            if button.ClearAnchors then
                button:ClearAnchors()
            end

            -- Hide button
            if button.SetHidden then
                button:SetHidden(true)
            end

            -- Reset backdrop visuals (CT_BACKDROP-safe)
            if button.background then
                if button.background.SetCenterColor then
                    button.background:SetCenterColor(0.08, 0.08, 0.12, 0.9)
                end
                if button.background.SetEdgeTexture then
                    button.background:SetEdgeTexture("", 1, 1, 0, 0)
                end
                if button.background.SetEdgeColor then
                    button.background:SetEdgeColor(0, 0, 0, 0)
                end
                if button.background.SetInsets then
                    button.background:SetInsets(2, 2, -2, -2)
                end
            end

            -- Clean up label
            if button.label then
                button.label:SetText("")
                button.label:SetColor(1, 1, 1, 1)
            end

            -- Clean up icon
            if button.icon then
                button.icon:SetTexture("")
                button.icon:SetHidden(true)
            end
        end
    )
end

function UI:CreateActionButton(parent, xOffset, yOffset, text, icon, callback)
    self.actionButtonCounter = self.actionButtonCounter + 1
    -- Use timestamp + counter to ensure unique names even if recreation happens quickly
    local timestamp = GetGameTimeMilliseconds()
    local btnName = "NMGuildHall_ActionButton_" .. self.actionButtonCounter .. "_" .. timestamp

    local btn = WINDOW_MANAGER:CreateControl(btnName, parent, CT_BUTTON)
    if not btn then
        local log = UILogger()
        if log then
            log:Error(GetString(NMGH_ERR_ACTION_BTN_CREATE_FAILED), {name = btnName})
        end
        return nil
    end

    btn:SetDimensions(ACTION_BUTTON_WIDTH, ACTION_BUTTON_HEIGHT)
    btn:SetAnchor(TOP, parent, TOP, xOffset, yOffset)

    -- Use enhanced ESO button styling with better textures
    local bgName = btnName .. "_BG"
    local bg = WINDOW_MANAGER:CreateControl(bgName, btn, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterTexture("EsoUI/Art/Miscellaneous/centerscreen_floating_center.dds")
    bg:SetCenterColor(0.08, 0.08, 0.12, 0.95)
    bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chatBG_edge.dds", 4, 4, 1, 1)
    bg:SetEdgeColor(0.8, 0.2, 0.3, 1.0)
    bg:SetInsets(2, 2, -2, -2)

    -- Button label
    local labelName = btnName .. "_Label"
    local label = WINDOW_MANAGER:CreateControl(labelName, btn, CT_LABEL)
    label:SetFont("ZoFontGameLargeBold")
    label:SetText("|t32:32:" .. icon .. "|t " .. text)
    label:SetAnchor(CENTER, btn, CENTER, 0, 0)
    label:SetColor(1, 1, 1, 1)

    btn.background = bg
    btn.label = label

    -- Track control for cleanup
    self.activeControls[btnName] = btn
    self.activeControls[bgName] = bg
    self.activeControls[labelName] = label

    -- Safe callback wrapper
    local safeCallback = function()
        if callback and type(callback) == "function" then
            local success, err = pcall(callback)
            if not success then
                local log = UILogger()
                if log then
                    log:Error(GetString(NMGH_ERR_ACTION_BTN_CALLBACK), {error = tostring(err)})
                end
            end
        end
    end

    btn:SetHandler("OnClicked", safeCallback)

    btn:SetHandler("OnMouseEnter", function()
        bg:SetCenterColor(0.15, 0.15, 0.20, 0.95) -- Lighter hover
        bg:SetEdgeColor(1.0, 0.3, 0.4, 1.0) -- Bright crimson edges
        bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chatBG_edge.dds", 8, 8, 1, 1) -- Thicker on hover (power of 2)
    end)

    btn:SetHandler("OnMouseExit", function()
        bg:SetCenterColor(0.08, 0.08, 0.12, 0.9) -- Restore to normal
        bg:SetEdgeColor(0.8, 0.2, 0.3, 1.0) -- Restore to crimson
        bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chatBG_edge.dds", 4, 4, 1, 1) -- Restore thickness
    end)

    btn:SetHandler("OnMouseDown", function()
        bg:SetCenterColor(0.05, 0.05, 0.08, 1.0) -- Darkest pressed state
        bg:SetEdgeColor(1.0, 0.4, 0.5, 1.0) -- Brightest crimson edges when pressed
        bg:SetInsets(1, 1, -1, -1) -- Compress slightly when pressed
    end)

    btn:SetHandler("OnMouseUp", function()
        bg:SetCenterColor(0.15, 0.15, 0.20, 0.95) -- Back to hover state
        bg:SetEdgeColor(1.0, 0.3, 0.4, 1.0) -- Back to hover crimson
        bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chatBG_edge.dds", 8, 8, 1, 1) -- Restore hover thickness
        bg:SetInsets(2, 2, -2, -2) -- Restore normal insets
    end)

    return btn
end

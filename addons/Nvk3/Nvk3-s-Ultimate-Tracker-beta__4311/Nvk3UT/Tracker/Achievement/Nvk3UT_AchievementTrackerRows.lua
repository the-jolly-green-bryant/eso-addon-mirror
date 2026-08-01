local addonName = "Nvk3UT"

Nvk3UT = Nvk3UT or {}

local Rows = {}
Rows.__index = Rows

local MODULE_NAME = addonName .. "AchievementTrackerRows"

local CATEGORY_TOGGLE_TEXTURES = {
    expanded = {
        up = "EsoUI/Art/Buttons/tree_open_up.dds",
        over = "EsoUI/Art/Buttons/tree_open_over.dds",
    },
    collapsed = {
        up = "EsoUI/Art/Buttons/tree_closed_up.dds",
        over = "EsoUI/Art/Buttons/tree_closed_over.dds",
    },
}

local LEFT_MOUSE_BUTTON = MOUSE_BUTTON_INDEX_LEFT or 1
local RIGHT_MOUSE_BUTTON = MOUSE_BUTTON_INDEX_RIGHT or 2

local CATEGORY_ROW_TYPES = {
    category = true,
}

local ENTRY_ROW_TYPES = {
    achievement = true,
    objective = true,
}

local function Call(callback, ...)
    if type(callback) == "function" then
        return callback(...)
    end
end

local function IsDebugLoggingEnabled()
    local utils = (Nvk3UT and Nvk3UT.Utils) or Nvk3UT_Utils
    if utils and type(utils.IsDebugEnabled) == "function" then
        return utils:IsDebugEnabled()
    end

    local diagnostics = (Nvk3UT and Nvk3UT.Diagnostics) or Nvk3UT_Diagnostics
    if diagnostics and type(diagnostics.IsDebugEnabled) == "function" then
        return diagnostics:IsDebugEnabled()
    end

    local addon = Nvk3UT
    if addon and type(addon.IsDebugEnabled) == "function" then
        return addon:IsDebugEnabled()
    end

    return false
end

local function DebugLog(message)
    if not IsDebugLoggingEnabled() then
        return
    end

    if d then
        d(string.format("[%s] %s", MODULE_NAME, tostring(message)))
    elseif print then
        print(string.format("[%s] %s", MODULE_NAME, tostring(message)))
    end
end

local function ApplyLabelDefaults(label)
    if not label or not label.SetHorizontalAlignment then
        return
    end

    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    if label.SetVerticalAlignment then
        label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    end
    if label.SetWrapMode then
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end
end

local function ApplyToggleDefaults(toggle)
    if not toggle or not toggle.SetVerticalAlignment then
        return
    end

    toggle:SetVerticalAlignment(TEXT_ALIGN_TOP)
end

local function ApplyFont(label, font)
    if not label or not label.SetFont then
        return
    end
    if not font or font == "" then
        return
    end
    label:SetFont(font)
end

local function ApplyBaseColor(control, r, g, b, a)
    if not control then
        return
    end

    local color = control.baseColor
    if type(color) ~= "table" then
        color = {}
        control.baseColor = color
    end

    color[1] = r or 1
    color[2] = g or 1
    color[3] = b or 1
    color[4] = a or 1

    if control.label and control.label.SetColor then
        control.label:SetColor(color[1], color[2], color[3], color[4])
    end
end

local function CountTableEntries(tbl)
    if type(tbl) ~= "table" then
        return 0
    end

    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end

    return count
end

local function IsCategoryRowType(rowType)
    return CATEGORY_ROW_TYPES[rowType] == true
end

local function IsEntryRowType(rowType)
    return ENTRY_ROW_TYPES[rowType] == true
end

local function SelectCategoryToggleTexture(expanded, isMouseOver)
    local textures = expanded and CATEGORY_TOGGLE_TEXTURES.expanded or CATEGORY_TOGGLE_TEXTURES.collapsed
    if isMouseOver then
        return textures.over
    end
    return textures.up
end

function Rows:Init(parent, opts)
    self.parent = parent
    self.fonts = (opts and opts.fonts) or {}
    self.callbacks = (opts and opts.callbacks) or {}
    self.activeControlsByKey = self.activeControlsByKey or {}
    self.freeControlsByType = self.freeControlsByType or {}
    self.allControls = self.allControls or {}
end

function Rows:SetFonts(fonts)
    self.fonts = fonts or {}
end

function Rows:SetCallbacks(callbacks)
    self.callbacks = callbacks or {}
end

function Rows:ReleaseAll()
    if not self.activeControlsByKey and not self.freeControlsByType then
        return
    end

    if not self.freeControlsByType then
        self.freeControlsByType = {}
    end

    if self.activeControlsByKey then
        for key, control in pairs(self.activeControlsByKey) do
            self.activeControlsByKey[key] = nil
            self:AddToFreePool(control)
        end
    end

    if self.previousActiveControlsByKey then
        for key, control in pairs(self.previousActiveControlsByKey) do
            self.previousActiveControlsByKey[key] = nil
            self:AddToFreePool(control)
        end
    end
end

function Rows:GetRowName(rowType, rowKey)
    local parentName = self.parent and self.parent.GetName and self.parent:GetName() or addonName
    local keyText = tostring(rowKey or "row")
    return string.format("%s_%s_%s", parentName, tostring(rowType or "row"), keyText)
end

function Rows:ResetControl(control)
    if not control then
        return
    end

    if control.SetHidden then
        control:SetHidden(true)
    end
    if control.SetAlpha then
        control:SetAlpha(1)
    end
    if control.SetMouseEnabled then
        control:SetMouseEnabled(true)
    end
    control.data = nil
    control.currentIndent = nil

    if control.ClearAnchors then
        control:ClearAnchors()
    end

    local label = control.label
    if label then
        if label.SetText then
            label:SetText("")
        end
        if label.SetColor then
            label:SetColor(1, 1, 1, 1)
        end
        if label.SetWrapMode then
            label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        end
        if label.SetHidden then
            label:SetHidden(false)
        end
    end

    if control.rowType == "category" then
        control.baseColor = nil
        if control.toggle then
            if control.toggle.SetTexture then
                control.toggle:SetTexture(SelectCategoryToggleTexture(false, false))
            end
            if control.toggle.SetHidden then
                control.toggle:SetHidden(false)
            end
        end
        control.isExpanded = nil
    elseif control.rowType == "achievement" then
        control.baseColor = nil
        if control.iconSlot then
            if control.iconSlot.SetTexture then
                control.iconSlot:SetTexture(nil)
            end
            if control.iconSlot.SetAlpha then
                control.iconSlot:SetAlpha(0)
            end
            if control.iconSlot.SetHidden then
                control.iconSlot:SetHidden(false)
            end
        end
    elseif control.rowType == "objective" then
        control.baseColor = nil
    end
end

function Rows:UpdateCategoryToggle(control, expanded)
    if not control or not control.toggle then
        return
    end
    control.toggle:SetHidden(false)
    if control.toggle.SetTexture then
        local isMouseOver = false
        if control.IsMouseOver and control:IsMouseOver() then
            isMouseOver = true
        elseif control.toggle.IsMouseOver and control.toggle:IsMouseOver() then
            isMouseOver = true
        end
        local texture = SelectCategoryToggleTexture(expanded, isMouseOver)
        control.toggle:SetTexture(texture)
    end
    if control.toggle.SetTextureRotation then
        local align = "left"
        local host = Nvk3UT and Nvk3UT.TrackerHost
        if host and type(host.GetContentAlignment) == "function" then
            local ok, value = pcall(host.GetContentAlignment, host)
            if ok and type(value) == "string" and value ~= "" then
                align = string.lower(value)
            end
        end

        local rotation = 0
        local texturePath = nil
        if align == "right" and expanded and host and type(host.ApplyChevronVisualTopRightExpanded) == "function" then
            texturePath, rotation = host.ApplyChevronVisualTopRightExpanded(control.toggle)
        else
            if align == "right" and not expanded then
                rotation = math.pi
            end
            control.toggle:SetTextureRotation(rotation, 0.5, 0.5)
        end

        local lastExpanded = control.__lastChevronExpanded
        if align == "right" and expanded and lastExpanded ~= expanded and IsDebugLoggingEnabled() then
            if texturePath == nil and control.toggle.GetTextureFileName then
                local okTexture, resolved = pcall(control.toggle.GetTextureFileName, control.toggle)
                if okTexture then
                    texturePath = resolved
                end
            end
            DebugLog(string.format(
                "CategoryChevron Achievement align=%s expanded=%s texture=%s rotation=%s",
                tostring(align),
                tostring(expanded),
                tostring(texturePath),
                tostring(rotation)
            ))
        end
        control.__lastChevronExpanded = expanded
    end
    control.isExpanded = expanded and true or false
end

function Rows:UpdateAchievementIconSlot(control)
    if not control or not control.iconSlot then
        return
    end

    if control.iconSlot.SetTexture then
        control.iconSlot:SetTexture(nil)
    end
    if control.iconSlot.SetAlpha then
        control.iconSlot:SetAlpha(0)
    end
    if control.iconSlot.SetHidden then
        control.iconSlot:SetHidden(false)
    end
end

function Rows:OnCategoryClicked(control)
    local expanded = not Call(self.callbacks.IsCategoryExpanded)
    Call(self.callbacks.SetCategoryExpanded, expanded, {
        trigger = "click",
        source = "AchievementTracker:OnCategoryClick",
    })
    Call(self.callbacks.Refresh)
    Call(self.callbacks.ScheduleToggleFollowup, "achievementCategoryToggle")
end

function Rows:ApplyFonts(control, rowType)
    if not control then
        return
    end

    if rowType == "category" then
        ApplyFont(control.label, self.fonts.category)
        ApplyFont(control.toggle, self.fonts.toggle)
    elseif rowType == "achievement" then
        ApplyFont(control.label, self.fonts.achievement)
    elseif rowType == "objective" then
        ApplyFont(control.label, self.fonts.objective)
    end
end

function Rows:CreateCategoryRow(rowKey)
    local control = CreateControlFromVirtual(self:GetRowName("Category", rowKey), self.parent, "AchievementsCategoryHeader_Template")
    control.rowType = "category"
    control.label = control:GetNamedChild("Label")
    control.toggle = control:GetNamedChild("Toggle")
    control.indentAnchor = control:GetNamedChild("IndentAnchor")

    ApplyLabelDefaults(control.label)
    ApplyToggleDefaults(control.toggle)
    self:ApplyFonts(control, "category")
    if control.toggle and control.toggle.SetTexture then
        control.toggle:SetTexture(SelectCategoryToggleTexture(false, false))
    end

    control:SetHandler("OnMouseUp", function(ctrl, button, upInside)
        if not upInside or button ~= LEFT_MOUSE_BUTTON then
            return
        end
        self:OnCategoryClicked(ctrl)
    end)
    control:SetHandler("OnMouseEnter", function(ctrl)
        Call(self.callbacks.ApplyMouseoverHighlight, ctrl)
        local expanded = ctrl.isExpanded
        if expanded == nil then
            expanded = Call(self.callbacks.IsCategoryExpanded)
        end
        self:UpdateCategoryToggle(ctrl, expanded)
    end)
    control:SetHandler("OnMouseExit", function(ctrl)
        Call(self.callbacks.RestoreBaseColor, ctrl)
        local expanded = ctrl.isExpanded
        if expanded == nil then
            expanded = Call(self.callbacks.IsCategoryExpanded)
        end
        self:UpdateCategoryToggle(ctrl, expanded)
    end)

    return control
end

function Rows:CreateAchievementRow(rowKey)
    local control = CreateControlFromVirtual(self:GetRowName("Achievement", rowKey), self.parent, "AchievementHeader_Template")
    control.rowType = "achievement"
    control.label = control:GetNamedChild("Label")
    control.iconSlot = control:GetNamedChild("IconSlot")

    if control.iconSlot then
        control.iconSlot:SetDimensions(18, 18)
        control.iconSlot:ClearAnchors()
        control.iconSlot:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
        if control.iconSlot.SetTexture then
            control.iconSlot:SetTexture(nil)
        end
        if control.iconSlot.SetAlpha then
            control.iconSlot:SetAlpha(0)
        end
        if control.iconSlot.SetHidden then
            control.iconSlot:SetHidden(false)
        end
    end

    if control.label then
        control.label:ClearAnchors()
        if control.iconSlot then
            control.label:SetAnchor(TOPLEFT, control.iconSlot, TOPRIGHT, 6, 0)
        else
            control.label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
        end
        control.label:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
    end

    ApplyLabelDefaults(control.label)
    self:ApplyFonts(control, "achievement")

    control:SetHandler("OnMouseUp", function(ctrl, button, upInside)
        if not upInside then
            return
        end

        if button == LEFT_MOUSE_BUTTON then
            if not ctrl.data or not ctrl.data.achievementId or not ctrl.data.hasObjectives then
                return
            end
            local achievementId = ctrl.data.achievementId
            local expanded = not Call(self.callbacks.IsEntryExpanded, achievementId)
            Call(self.callbacks.SetEntryExpanded, achievementId, expanded, "AchievementTracker:ToggleAchievementObjectives")
            Call(self.callbacks.Refresh)
            Call(self.callbacks.ScheduleToggleFollowup, "achievementEntryToggle")
        elseif button == RIGHT_MOUSE_BUTTON then
            if not ctrl.data or not ctrl.data.achievementId then
                return
            end
            Call(self.callbacks.ShowAchievementContextMenu, ctrl, ctrl.data)
        end
    end)
    control:SetHandler("OnMouseEnter", function(ctrl)
        Call(self.callbacks.ApplyMouseoverHighlight, ctrl)
    end)
    control:SetHandler("OnMouseExit", function(ctrl)
        Call(self.callbacks.RestoreBaseColor, ctrl)
    end)

    return control
end

function Rows:CreateObjectiveRow(rowKey)
    local control = CreateControlFromVirtual(self:GetRowName("Objective", rowKey), self.parent, "AchievementObjective_Template")
    control.rowType = "objective"
    control.label = control:GetNamedChild("Label")

    ApplyLabelDefaults(control.label)
    self:ApplyFonts(control, "objective")

    return control
end

function Rows:BeginRefresh()
    self.previousActiveControlsByKey = self.activeControlsByKey or {}
    self.activeControlsByKey = {}
    self.createdCount = 0
    self.reusedCount = 0
    self.createdCategory = 0
    self.reusedCategory = 0
    self.createdEntry = 0
    self.reusedEntry = 0
    self.freedCount = 0
end

local function RegisterAcquisitionStats(self, rowType, wasCreated)
    if IsCategoryRowType(rowType) then
        if wasCreated then
            self.createdCategory = (self.createdCategory or 0) + 1
        else
            self.reusedCategory = (self.reusedCategory or 0) + 1
        end
    elseif IsEntryRowType(rowType) then
        if wasCreated then
            self.createdEntry = (self.createdEntry or 0) + 1
        else
            self.reusedEntry = (self.reusedEntry or 0) + 1
        end
    end

    if wasCreated then
        self.createdCount = (self.createdCount or 0) + 1
    else
        self.reusedCount = (self.reusedCount or 0) + 1
    end
end

function Rows:AddToFreePool(control)
    if not control then
        return
    end

    self:ResetControl(control)

    local rowType = control.rowType or "generic"
    self.freeControlsByType = self.freeControlsByType or {}
    local pool = self.freeControlsByType[rowType]
    if not pool then
        pool = {}
        self.freeControlsByType[rowType] = pool
    end

    pool[#pool + 1] = control
end

function Rows:AcquireRow(rowKey, rowType, parent)
    if not self.activeControlsByKey then
        self.activeControlsByKey = {}
    end

    if not self.previousActiveControlsByKey then
        self.previousActiveControlsByKey = {}
    end

    if not self.freeControlsByType then
        self.freeControlsByType = {}
    end

    parent = parent or self.parent

    local wasCreated = false
    local control = self.previousActiveControlsByKey[rowKey]
    if control then
        self.previousActiveControlsByKey[rowKey] = nil
        if rowType and control.rowType ~= rowType then
            self:AddToFreePool(control)
            self.freedCount = (self.freedCount or 0) + 1
            control = nil
        end
    end

    if not control then
        local pool = self.freeControlsByType[rowType]
        if pool and #pool > 0 then
            control = table.remove(pool)
        end
    end

    if not control then
        if rowType == "category" then
            control = self:CreateCategoryRow(rowKey)
        elseif rowType == "achievement" then
            control = self:CreateAchievementRow(rowKey)
        elseif rowType == "objective" then
            control = self:CreateObjectiveRow(rowKey)
        end

        if control then
            wasCreated = true
            self.allControls[#self.allControls + 1] = control
        end
    end

    if control then
        self:ResetControl(control)
        control.rowType = rowType
        if control.SetParent and parent and control:GetParent() ~= parent then
            control:SetParent(parent)
        end
        self:ApplyFonts(control, rowType)
        self.activeControlsByKey[rowKey] = control
        RegisterAcquisitionStats(self, rowType, wasCreated)
        return control
    end

    return nil
end

function Rows:ApplyRow(control, rowType, rowData)
    if not control then
        return
    end

    control.rowType = rowType
    self:ApplyFonts(control, rowType)

    if rowType == "category" then
        control.data = rowData and rowData.data or nil
        if control.label and control.label.SetText then
            control.label:SetText(rowData and rowData.labelText or "")
        end
        if rowData and rowData.baseColor then
            ApplyBaseColor(control, unpack(rowData.baseColor))
        end
        self:UpdateCategoryToggle(control, rowData and rowData.expanded)
    elseif rowType == "achievement" then
        control.data = rowData and rowData.data or nil
        if control.label and control.label.SetText then
            control.label:SetText(rowData and rowData.labelText or "")
        end
        self:UpdateAchievementIconSlot(control)
        if rowData and rowData.baseColor then
            ApplyBaseColor(control, unpack(rowData.baseColor))
        end
    elseif rowType == "objective" then
        control.data = rowData and rowData.data or nil
        if control.label and control.label.SetText then
            control.label:SetText(rowData and rowData.labelText or "")
        end
        if rowData and rowData.color and control.label and control.label.SetColor then
            control.label:SetColor(unpack(rowData.color))
        end
    end
end

function Rows:EndRefresh()
    if not self.freeControlsByType then
        self.freeControlsByType = {}
    end

    if self.previousActiveControlsByKey then
        for key, control in pairs(self.previousActiveControlsByKey) do
            self.previousActiveControlsByKey[key] = nil
            self:AddToFreePool(control)
            self.freedCount = (self.freedCount or 0) + 1
        end
    end

    if IsDebugLoggingEnabled() then
        local activeCount = CountTableEntries(self.activeControlsByKey)
        DebugLog(string.format(
            "Rows refresh: active=%d freed=%d created(cat=%d entry=%d) reused(cat=%d entry=%d)",
            activeCount,
            self.freedCount or 0,
            self.createdCategory or 0,
            self.createdEntry or 0,
            self.reusedCategory or 0,
            self.reusedEntry or 0
        ))
    end
end

Nvk3UT.AchievementTrackerRows = Rows

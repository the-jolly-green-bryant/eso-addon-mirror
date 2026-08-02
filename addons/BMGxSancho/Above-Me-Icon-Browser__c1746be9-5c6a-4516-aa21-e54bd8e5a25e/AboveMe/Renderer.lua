AboveMe = AboveMe or {}
local AM = AboveMe
local WM = WINDOW_MANAGER

AM.renderControls = {}
AM.remoteSelections = AM.remoteSelections or {}

local function CreateIconControl(index)
    local control = WM:CreateControl("AboveMeIcon" .. index, AM.worldWindow, CT_TEXTURE)
    control:SetHidden(true)
    control:SetDrawLayer(DL_OVERLAY)
    control:SetDrawTier(DT_HIGH)
    control:SetDrawLevel(100)
    AM.renderControls[index] = control
    return control
end

function AM:CreateRenderer()
    self.renderSpace = WM:CreateControl("AboveMeRenderSpace", GuiRoot, CT_CONTROL)
    self.renderSpace:SetAnchorFill(GuiRoot)
    self.renderSpace:Create3DRenderSpace()
    self.renderSpace:SetHidden(true)

    self.worldWindow = WM:CreateTopLevelWindow("AboveMeWorldWindow")
    self.worldWindow:SetAnchorFill(GuiRoot)
    self.worldWindow:SetMouseEnabled(false)
    self.worldWindow:SetMovable(false)
    self.worldWindow:SetDrawLayer(DL_OVERLAY)
    self.worldWindow:SetDrawTier(DT_HIGH)
    self.worldWindow:SetDrawLevel(100)

    local fragment = ZO_HUDFadeSceneFragment:New(self.worldWindow)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
end

function AM:HideAllIcons()
    for _, control in pairs(self.renderControls) do
        control:SetHidden(true)
    end
end

function AM:GetSelectionForUnit(unitTag)
    if AreUnitsEqual("player", unitTag) then
        return self.saved.iconId
    end

    local displayName = GetUnitDisplayName(unitTag)
    if not displayName or displayName == "" then return nil end

    -- Every player owns their own selection. Remote selections are received
    -- automatically through LibGroupBroadcast and keyed by account name.
    return self.remoteSelections[displayName]
end

local function UnitCanDisplay(unitTag)
    if not DoesUnitExist(unitTag) or not IsUnitPlayer(unitTag) or not IsUnitOnline(unitTag) then return false end
    if unitTag ~= "player" then
        if not IsGroupMemberInSameWorldAsPlayer(unitTag) then return false end
        if IsGroupMemberInRemoteRegion(unitTag) then return false end
        if not IsGroupMemberInSameInstanceAsPlayer(unitTag) and not IsActiveWorldBattleground() then return false end
    end
    return true
end

function AM:UpdateRenderer()
    self:HideAllIcons()
    if not self.saved.enabled then return end
    if self.saved.combatOnly and not IsUnitInCombat("player") then return end

    Set3DRenderSpaceToCurrentCamera(self.renderSpace:GetName())
    local cX, cY, cZ = GuiRender3DPositionToWorldPosition(self.renderSpace:Get3DRenderSpaceOrigin())
    local fX, fY, fZ = self.renderSpace:Get3DRenderSpaceForward()
    local rX, rY, rZ = self.renderSpace:Get3DRenderSpaceRight()
    local uX, uY, uZ = self.renderSpace:Get3DRenderSpaceUp()

    local i11 = -(uY * fZ - uZ * fY)
    local i12 = -(rZ * fY - rY * fZ)
    local i13 = -(rY * uZ - rZ * uY)
    local i21 = -(uZ * fX - uX * fZ)
    local i22 = -(rX * fZ - rZ * fX)
    local i23 = -(rZ * uX - rX * uZ)
    local i31 = -(uX * fY - uY * fX)
    local i32 = -(rY * fX - rX * fY)
    local i33 = -(rX * uY - rY * uX)
    local i41 = -(uZ * fY * cX + uY * fX * cZ + uX * fZ * cY - uX * fY * cZ - uY * fZ * cX - uZ * fX * cY)
    local i42 = -(rX * fY * cZ + rY * fZ * cX + rZ * fX * cY - rZ * fY * cX - rY * fX * cZ - rX * fZ * cY)
    local i43 = -(rZ * uY * cX + rY * uX * cZ + rX * uZ * cY - rX * uY * cZ - rY * uZ * cX - rZ * uX * cY)

    local uiW, uiH = GuiRoot:GetDimensions()
    local index = 0

    local function RenderUnit(unitTag)
        if not UnitCanDisplay(unitTag) then return end
        if unitTag == "player" and not self.saved.showOwnIcon then return end
        if unitTag ~= "player" and not self.saved.showGroupIcons then return end

        local selectionId = self:GetSelectionForUnit(unitTag)
        if not selectionId then return end
        local icon = self:GetIcon(selectionId)
        if not icon or not icon.texture then return end

        local _, wX, wY, wZ = GetUnitRawWorldPosition(unitTag)
        wY = wY + (self.saved.height * 100)
        local pX = wX * i11 + wY * i21 + wZ * i31 + i41
        local pY = wX * i12 + wY * i22 + wZ * i32 + i42
        local pZ = wX * i13 + wY * i23 + wZ * i33 + i43
        if pZ <= 0 then return end

        local worldW, worldH = GetWorldDimensionsOfViewFrustumAtDepth(pZ)
        if not worldW or worldW == 0 or not worldH or worldH == 0 then return end
        local x, y = pX * uiW / worldW, -pY * uiH / worldH

        local dX, dY, dZ = wX - cX, wY - cY, wZ - cZ
        local distance = 1 + zo_sqrt(dX * dX + dY * dY + dZ * dZ)
        if distance > self.saved.maxDistance * 100 then return end

        index = index + 1
        local control = self.renderControls[index] or CreateIconControl(index)
        control:ClearAnchors()
        control:SetAnchor(BOTTOM, self.worldWindow, CENTER, x, y)
        control:SetTexture(icon.texture)
        control:SetTextureCoords(icon.left or 0, icon.right or 1, icon.top or 0, icon.bottom or 1)
        control:SetDimensions(self.saved.size, self.saved.size)
        local scale = 1
        if self.saved.distanceScaling then
            scale = math.max(0.45, math.min(1.25, 1000 / distance))
        end
        control:SetScale(scale)
        local fade = 1
        if self.saved.fadeWithDistance then
            local maxDistance = self.saved.maxDistance * 100
            local fadeStart = maxDistance * 0.60
            local fadeProgress = zo_clampedPercentBetween(fadeStart, maxDistance, distance)
            fade = 1 - fadeProgress
        end
        control:SetAlpha(self.saved.opacity * fade * fade)
        control:SetHidden(false)
    end

    if self.saved.showOwnIcon then RenderUnit("player") end
    if IsUnitGrouped("player") then
        -- ESO trial groups contain at most 12 players. Iterate known unit tags and
        -- let UnitCanDisplay filter tags that do not exist.
        for i = 1, 12 do
            local unitTag = "group" .. i
            if not AreUnitsEqual("player", unitTag) then
                RenderUnit(unitTag)
            end
        end
    end
end

function AM:StartRenderer()
    EVENT_MANAGER:UnregisterForUpdate("AboveMeRenderer")
    EVENT_MANAGER:RegisterForUpdate("AboveMeRenderer", self.saved.updateRate, function() self:UpdateRenderer() end)
end

LeaderDistanceAlert = {}
LeaderDistanceAlert.name = "LeaderDistanceAlert"

LeaderDistanceAlert.defaults = {
    enabled = true,
    maxDistanceMeters = 60,
    checkIntervalMs = 1000,
}

local LDA = LeaderDistanceAlert

local function SafeMetersBetweenUnits(unitTag1, unitTag2)
    if not DoesUnitExist(unitTag1) or not DoesUnitExist(unitTag2) then
        return nil, "unit_missing"
    end

    local zoneId1, x1, y1, z1 = GetUnitRawWorldPosition(unitTag1)
    local zoneId2, x2, y2, z2 = GetUnitRawWorldPosition(unitTag2)

    if not zoneId1 or not zoneId2 then
        return nil, "no_position"
    end

    if zoneId1 ~= zoneId2 then
        return nil, "different_zone"
    end

    local dx = x2 - x1
    local dy = y2 - y1
    local dz = z2 - z1

    local distanceCm = math.sqrt(dx * dx + dy * dy + dz * dz)
    local distanceMeters = distanceCm / 100

    return distanceMeters, nil
end

function LDA:CreateUI()
    local wm = WINDOW_MANAGER

    self.control = wm:CreateTopLevelWindow(self.name .. "Alert")
    self.control:SetDimensions(800, 80)
    self.control:SetAnchor(CENTER, GuiRoot, CENTER, 0, -220)
    self.control:SetHidden(true)
    self.control:SetMouseEnabled(false)
    self.control:SetMovable(false)
    self.control:SetClampedToScreen(true)

    self.label = wm:CreateControl(nil, self.control, CT_LABEL)
    self.label:SetAnchor(CENTER, self.control, CENTER, 0, 0)
    self.label:SetFont("ZoFontWinH1")
    self.label:SetColor(1, 0.2, 0.2, 1)
    self.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.label:SetText("")
end

function LDA:ShowAlert(text)
    if self.label then
        self.label:SetText(text)
    end

    if self.control then
        self.control:SetHidden(false)
    end
end

function LDA:HideAlert()
    if self.control then
        self.control:SetHidden(true)
    end
end

function LDA:CheckLeaderDistance()
    if not self.saved.enabled then
        self.wasTooFar = false
        self:HideAlert()
        return
    end

    if not IsUnitGrouped("player") then
        self.wasTooFar = false
        self:HideAlert()
        return
    end

    local leaderTag = GetGroupLeaderUnitTag()
    if not leaderTag or leaderTag == "" or leaderTag == "player" then
        self.wasTooFar = false
        self:HideAlert()
        return
    end

    local distanceMeters, err = SafeMetersBetweenUnits("player", leaderTag)
    if not distanceMeters then
        self.wasTooFar = false
        self:HideAlert()
        return
    end

    local tooFar = distanceMeters > self.saved.maxDistanceMeters

    if tooFar then
        self:ShowAlert(string.format(
            "TOO FAR FROM GROUP LEADER: %.0f m / %d m max",
            distanceMeters,
            self.saved.maxDistanceMeters
        ))
    else
        self:HideAlert()
    end

    self.wasTooFar = tooFar
end

function LDA:StartTracking()
    EVENT_MANAGER:UnregisterForUpdate(self.name .. "_Update")
    EVENT_MANAGER:RegisterForUpdate(
        self.name .. "_Update",
        self.saved.checkIntervalMs,
        function()
            self:CheckLeaderDistance()
        end
    )
end

function LDA:StopTracking()
    EVENT_MANAGER:UnregisterForUpdate(self.name .. "_Update")
    self:HideAlert()
end

function LDA:RefreshTracking()
    if not self.saved.enabled then
        self:StopTracking()
        return
    end

    if IsUnitGrouped("player") then
        self:StartTracking()
    else
        self:StopTracking()
    end
end

function LDA:OnGroupChanged()
    if IsUnitGrouped("player") and self.saved.enabled then
        self:StartTracking()
    else
        self:StopTracking()
        self.wasTooFar = false
    end
end

function LDA:CreateSettingsMenu()
    local LAM2 = LibAddonMenu2
    if not LAM2 then
        d("[LeaderDistanceAlert] LibAddonMenu-2.0 not found.")
        return
    end

    local panelData = {
        type = "panel",
        name = "Leader Distance Alert",
        displayName = "Leader Distance Alert",
        author = "Lebiez",
        version = "1.2.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM2:RegisterAddonPanel(self.name .. "_Options", panelData)

    local optionsTable = {
        {
            type = "checkbox",
            name = "Enable Addon",
            tooltip = "Enable or disable the leader distance tracking.",
            getFunc = function()
                return self.saved.enabled
            end,
            setFunc = function(value)
                self.saved.enabled = value
                if value then
                    self:RefreshTracking()
                    self:CheckLeaderDistance()
                else
                    self.wasTooFar = false
                    self:HideAlert()
                    self:StopTracking()
                end
            end,
            default = self.defaults.enabled,
            width = "full",
        },
        {
            type = "slider",
            name = "Maximum Distance to Leader",
            tooltip = "Maximum allowed distance before showing the visual alert.",
            min = 5,
            max = 200,
            step = 5,
            getFunc = function()
                return self.saved.maxDistanceMeters
            end,
            setFunc = function(value)
                self.saved.maxDistanceMeters = value
                self:CheckLeaderDistance()
            end,
            default = self.defaults.maxDistanceMeters,
            width = "full",
        },
        {
            type = "description",
            text = "A red visual alert will appear in the center of the screen when you exceed the configured distance.",
            width = "full",
        },
        {
            type = "slider",
            name = "Update Interval (ms)",
            tooltip = "Lower values are more responsive but use more resources.",
            min = 250,
            max = 3000,
            step = 250,
            getFunc = function()
                return self.saved.checkIntervalMs
            end,
            setFunc = function(value)
                self.saved.checkIntervalMs = value
                self:RefreshTracking()
            end,
            default = self.defaults.checkIntervalMs,
            width = "full",
        },
    }

    LAM2:RegisterOptionControls(self.name .. "_Options", optionsTable)
end

function LDA:OnPlayerActivated()
    self:RefreshTracking()
    self:CheckLeaderDistance()
end

function LDA:OnAddonLoaded(event, addonName)
    if addonName ~= self.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)

    self.saved = ZO_SavedVars:NewAccountWide("LeaderDistanceAlertSaved", 1, nil, self.defaults)
    self.wasTooFar = false

    self:CreateUI()
    self:CreateSettingsMenu()

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_UPDATE, function()
        self:OnGroupChanged()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function()
        self:OnPlayerActivated()
    end)

    self:RefreshTracking()
end

EVENT_MANAGER:RegisterForEvent(LDA.name, EVENT_ADD_ON_LOADED, function(...)
    LDA:OnAddonLoaded(...)
end)
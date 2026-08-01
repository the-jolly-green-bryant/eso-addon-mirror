
function KeepStatus:Initialize()
	KeepStatus.playerAlliance = GetUnitAlliance('player')

	KeepStatus:createUi()
    KeepStatus:refresh()

	EVENT_MANAGER:RegisterForEvent(KeepStatus.name, EVENT_PLAYER_ACTIVATED, KeepStatus.OnPlayerActivated)

	KeepStatus:OnOff()
end

-- Loads the addon; only hit once
function KeepStatus.OnAddOnLoaded(event, addonName)
	-- The event fires each time *any* addon loads; but we only care about when our own addon loads.
	if addonName ~= KeepStatus.name then
		return
	end

	EVENT_MANAGER:UnregisterForEvent(KeepStatus.name, EVENT_ADD_ON_LOADED)

	KeepStatus.SV = ZO_SavedVars:NewAccountWide("KeepStatusTrackerSettings", 1.0, "AccountWide", KeepStatus.defaults)

	KeepStatus:Initialize()
	KeepStatus:SetupCommands()
end

function KeepStatus:createUi()
	KeepStatus.ui = WINDOW_MANAGER:CreateTopLevelWindow("KeepStatus_UI")
    KeepStatus.ui:SetWidth(KeepStatus.width)
    KeepStatus.ui:SetMouseEnabled(true)
    KeepStatus.ui:SetMovable(true)
    KeepStatus.ui:SetClampedToScreen(false)
    KeepStatus.ui:SetHandler("OnMoveStop", KeepStatus.saveWindowPosition)

    local _, pt, relTo, relPt = KeepStatus_UI:GetAnchor()

    KeepStatus.ui:ClearAnchors()
    KeepStatus.ui:SetAnchor(KeepStatus.SV.selfPoint or TOPLEFT,
        GuiRoot, KeepStatus.SV.anchPoint or TOPRIGHT,
        KeepStatus.SV.xoff, KeepStatus.SV.yoff)

    KeepStatus.ui:SetHidden(false)
end

function KeepStatus:SetupCommands()
	SLASH_COMMANDS["/kstoggletimer"] = function (extra)
		if KeepStatus.SV.timerOn == true then
			KeepStatus.SV.timerOn = false
		else
			KeepStatus.SV.timerOn = true
		end
	end
end

function KeepStatus.actionLayerChange(_, _, activeLayerIndex)
    KeepStatus_UI:SetHidden(activeLayerIndex > 2)
end

function KeepStatus.OnPlayerActivated()
	KeepStatus.campaignId = GetCurrentCampaignId()

	KeepStatus:OnOff()
end

function KeepStatus:OnOff()
	KeepStatus.playerInPvP = IsInCyrodiil()

	if KeepStatus.playerInPvP == true then
		EVENT_MANAGER:RegisterForUpdate(KeepStatus.name .. "KeepCheck", 5000, function()
			KeepStatus:scanKeeps()
			KeepStatus:updateAll()
		end)

		EVENT_MANAGER:RegisterForUpdate(KeepStatus.name .. "UIUpdate", 1000, function()
			KeepStatus:printAll()
		end)

		EVENT_MANAGER:RegisterForEvent(KeepStatus.name, EVENT_ACTION_LAYER_POPPED, KeepStatus.actionLayerChange)
		EVENT_MANAGER:RegisterForEvent(KeepStatus.name, EVENT_ACTION_LAYER_PUSHED, KeepStatus.actionLayerChange)
	else
		KeepStatus_UI:SetHidden(true)

		EVENT_MANAGER:UnregisterForEvent(KeepStatus.name, EVENT_ACTION_LAYER_PUSHED)
		EVENT_MANAGER:UnregisterForEvent(KeepStatus.name, EVENT_ACTION_LAYER_POPPED)
	end
end

KeepStatus.entries = {}

function KeepStatus:reconfigureLabels()
    for _,entry in pairs(self.entries) do
        entry.type = nil
    end
end

function KeepStatus:hideRow(index)
    if self.entries[index] then
        self.entries[index].main:SetHidden(true)
    end
end

function KeepStatus:getUIRow(index)
    if #self.entries < index then
        table.insert(self.entries, self.Label())
        index = #self.entries
    end

    self.entries[index].main:SetHidden(false)

    return self.entries[index]
end

function KeepStatus:printAll()
	if KeepStatus.playerInPvP == false then
		return
	end

    local i = 1

	self:getUIRow(i):update(self.statusBar)
	i = i + 1

    for _,upgrade in pairs(self.upgrades) do
        self:getUIRow(i):update(upgrade)
        i = i + 1
    end

    self.ui:SetHeight(math.max(i*35,70))

    for j=i,#self.entries do
        self:hideRow(j)
    end
end

function KeepStatus:refresh()
    self.upgrades = {}

    self.statusBar = self.MainBar()
    self:scanKeeps()

    self:reconfigureLabels()
end

KeepStatus.upgrades = {}

function KeepStatus:checkAdd(keepID)
    if self.upgrades[keepID] == nil then
        local upgrade = self.Upgrade(keepID)

        if upgrade:needsUpgrade() then
            self.upgrades[keepID] = upgrade
        end
    end
end

function KeepStatus:updateAll()
	if KeepStatus.playerInPvP == false then
		return
	end

    for i,_ in pairs(self.upgrades) do
        self.upgrades[i]:update()
    end

	self.statusBar:update()
end

function KeepStatus:scanKeeps()
	if KeepStatus.playerInPvP == false then
		return
	end

    for i=3,20 do
        self:checkAdd(i)
    end
end

function KeepStatus.saveWindowPosition(window)
    local _, sP, _, aP, x, y = window:GetAnchor()

    KeepStatus.SV.anchPoint = aP
    KeepStatus.SV.selfPoint = sP
    KeepStatus.SV.xoff = x
    KeepStatus.SV.yoff = y
end

function KeepStatus.formatTime(delta)
    local sec = delta % 60
    delta = (delta - sec) / 60
    local min = delta % 60
    local out = min .. "m"
	out = out .. " " .. sec .. "s"

    return out
end

-- so that ESO can register the addon
EVENT_MANAGER:RegisterForEvent(KeepStatus.name, EVENT_ADD_ON_LOADED, KeepStatus.OnAddOnLoaded)
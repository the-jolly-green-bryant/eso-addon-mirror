local GH = "GroupHealth"

local function d() end

local function GH_CreateControl(suffix, parent, template)
    return CreateControlFromVirtual(parent:GetName()..suffix, parent, template)
end
--local Formatted_HP=math.floor(Original_HP/100)/10
local function GH_UpdateGroupBarText(control, healthPool, maxHealthPool)
    -- local healthPool, maxHealthPool = GetUnitPower(unitTag, POWERTYPE_HEALTH)
    local percentage = (healthPool > 0) and zo_round(healthPool * 100 / maxHealthPool) or 0
    control:SetText(string.format("%dk (%d%%)", healthPool/1000, percentage))
end

local function GH_ImproveGroupUnitFrame(unitFrame)
    local unitTag = unitFrame.unitTag
    unitFrame.hasGroupHealth = true

    -- Display health bar text
    local healthBarControl = unitFrame.healthBar.barControls[1]
    unitFrame.GHHealthBarText = GH_CreateControl("GHBarText", healthBarControl, "GHGroupBarText")

    local healthPool, maxHealthPool = GetUnitPower(unitTag, POWERTYPE_HEALTH)
    GH_UpdateGroupBarText(unitFrame.GHHealthBarText, healthPool, maxHealthPool)
    unitFrame:RefreshControls()
end

local function GH_ShouldImproveUnitFrame(unitFrame)
    return unitFrame and (not unitFrame.hasGroupHealth) and IsUnitOnline(unitFrame.unitTag) and (GetGroupSize() <= 4)
end

local function GH_ShouldUpdateUnitFrame(unitFrame)
    return unitFrame.hasGroupHealth
end

local function OnPowerUpdate(event, unitTag, powerPoolIndex, powerType, powerPool, powerPoolMax)
    if ZO_Group_IsGroupUnitTag(unitTag) then
        d("Power update", unitTag)
        local unitFrame = ZO_UnitFrames_GetUnitFrame(unitTag)
        if GH_ShouldUpdateUnitFrame(unitFrame) then
            local healthPool, maxHealthPool = GetUnitPower(unitTag, POWERTYPE_HEALTH)
            GH_UpdateGroupBarText(unitFrame.GHHealthBarText, healthPool, maxHealthPool)
        end
    end
end

local function OnUnitCreated(event, unitTag)
    if ZO_Group_IsGroupUnitTag(unitTag) then
        d("Unit created", unitTag)

        local pollCount = 0
        local pollLimit = 20
        local pollInterval = 100
        local pollGroupUnitFrame

        pollGroupUnitFrame = function()
            local unitFrame = ZO_UnitFrames_GetUnitFrame(unitTag)
            if unitFrame then
                if GH_ShouldImproveUnitFrame(unitFrame) then
                    GH_ImproveGroupUnitFrame(unitFrame)
                end
            else
                if (pollCount < pollLimit) then
                    zo_callLater(pollGroupUnitFrame, pollInterval)
                    pollCount = pollCount + 1
                else
                    d("Group unit frame was not ready in due time")
                end
            end
        end

        pollGroupUnitFrame()
    end
end

local function OnPlayerActivated()
    if IsUnitGrouped("player") and (GetGroupSize() <= 4) then
        local pollCount = 0
        local pollLimit = 10
        local pollInterval = 500
        local pollGroupUnitFrames

        pollGroupUnitFrames = function()
            if (UNIT_FRAMES.groupSize > 0) then
                for unitTag, unitFrame in pairs(UNIT_FRAMES.groupFrames) do
                    if (GH_ShouldImproveUnitFrame(unitFrame)) then
                        GH_ImproveGroupUnitFrame(unitFrame)
                    end
                end
            else
                if (pollCount < pollLimit) then
                    zo_callLater(pollGroupUnitFrames, pollInterval)
                    pollCount = pollCount + 1
                else
                    d("Group unit frames were not ready in due time")
                end
            end
        end

        pollGroupUnitFrames()
    end
end

local function OnGroupMemberConnectedStatus(event, unitTag)
    if IsUnitOnline(unitTag) then
        local unitFrame = ZO_UnitFrames_GetUnitFrame(unitTag)
        if GH_ShouldImproveUnitFrame(unitFrame) then
            GH_ImproveGroupUnitFrame(unitFrame)
        end
    end
end

local function OnAddOnLoaded(event, addOnName)
    if (addOnName == GH) then
        EVENT_MANAGER:UnregisterForEvent(GH, EVENT_ADD_ON_LOADED)

        EVENT_MANAGER:RegisterForEvent(GH, EVENT_UNIT_CREATED, OnUnitCreated)
        EVENT_MANAGER:RegisterForEvent(GH, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
        EVENT_MANAGER:RegisterForEvent(GH, EVENT_GROUP_MEMBER_CONNECTED_STATUS, OnGroupMemberConnectedStatus)

        EVENT_MANAGER:RegisterForEvent(GH, EVENT_POWER_UPDATE, OnPowerUpdate)

        local filters =
        {
            REGISTER_FILTER_UNIT_TAG_PREFIX, "group",
            REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH,
        }
        EVENT_MANAGER:AddFilterForEvent(GH, EVENT_POWER_UPDATE, unpack(filters))
    end
end

EVENT_MANAGER:RegisterForEvent(GH, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

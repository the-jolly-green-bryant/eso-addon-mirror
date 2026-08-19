local CAE = CrutchAlertsExtensions
local Crutch = CrutchAlerts
local Draw = Crutch.Drawing


---------------------------------------------------------------------
local SHADOW_IMAGE_NAMES = {
    ["Gloom Wraith"] = true,
    ["Trübsinnsgeist"] = true,
    ["Espectro tenebroso"] = true,
    ["Spectre de la mélancolie"] = true,
    ["闇のレイス"] = true,
    ["Темное привидение"] = true,
    ["幽暗怨灵"] = true,
}

-- Whether it's the right morph
local function IsShadowImage()
    for skillLineIndex = 1, GetNumSkillLines(SKILL_TYPE_CLASS) do
        local skillLineId = GetSkillLineId(SKILL_TYPE_CLASS, skillLineIndex)
        local _, _, isActive = GetSkillLineDynamicInfo(SKILL_TYPE_CLASS, skillLineIndex)
        -- d(GetSkillLineNameById(skillLineId) .. " " .. skillLineId)
        if (isActive and skillLineId == 39) then -- Shadow
            for skillIndex = 1, GetNumSkillAbilities(SKILL_TYPE_CLASS, skillLineIndex) do
                local progressionId = GetProgressionSkillProgressionId(SKILL_TYPE_CLASS, skillLineIndex, skillIndex)


                -- Summon Shade
                if (progressionId == 93) then
                    local name, _, _, _, _, purchased = GetSkillAbilityInfo(SKILL_TYPE_CLASS, skillLineIndex, skillIndex)
                    -- d(name .. " " .. progressionId)
                    if (purchased) then
                        local morph = GetProgressionSkillCurrentMorphSlot(progressionId)
                        return morph == MORPH_SLOT_MORPH_2
                    end
                end
            end
        end
    end
end

local function StartsWith(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end


---------------------------------------------------------------------
---------------------------------------------------------------------
local createdKeys = {} -- {[unitTag] = {key, key}}

local function OnUnitDestroyed(_, unitTag)
    if (createdKeys[unitTag]) then
        for _, key in ipairs(createdKeys[unitTag]) do
            Draw.RemoveGroundCircle(key)
        end
        ZO_ClearTable(createdKeys[unitTag])
    end
end

local function DrawThinCircle(x, y, z, radius, orientation, depthBuffer, rotate)
    local updateFunc
    if (rotate) then
        updateFunc = function(icon)
            local time = GetGameTimeMilliseconds() % 20000 / 20000
            local angle = time * 2 * math.pi
            icon:SetOrientation(orientation[1], orientation[2] + angle, orientation[3])
        end
    end

    return Draw.CreateOrientedTexture("CrutchAlertsExtensions/assets/thinring.dds",
        x, y, z, radius * 2, {0.8, 0, 1, 0.5}, orientation, updateFunc, depthBuffer)
end

local function OnUnitCreated(_, unitTag)
    OnUnitDestroyed(nil, unitTag)

    -- Crutch.dbgSpam(unitTag .. " - " .. tostring(GetUnitName(unitTag)))
    if (StartsWith(unitTag, "playerpet") and SHADOW_IMAGE_NAMES[GetUnitName(unitTag)] and IsShadowImage()) then
        local _, x, y, z = GetUnitRawWorldPosition(unitTag)
        local depthBuffer = true

        if (not createdKeys[unitTag]) then
            createdKeys[unitTag] = {}
        end

        table.insert(createdKeys[unitTag], DrawThinCircle(x, y, z, 28, nil, false))

        table.insert(createdKeys[unitTag], DrawThinCircle(x, y, z, 28, {0, 0, 0}, true, true))
        table.insert(createdKeys[unitTag], DrawThinCircle(x, y, z, 28, {0, math.pi/2, 0}, true, true))
        table.insert(createdKeys[unitTag], DrawThinCircle(x, y, z, 28, {0, math.pi/4, 0}, true, true))
        table.insert(createdKeys[unitTag], DrawThinCircle(x, y, z, 28, {0, math.pi*3/4, 0}, true, true))

        table.insert(createdKeys[unitTag], DrawThinCircle(x, y + 1200, z, 25.298, nil, false))
        table.insert(createdKeys[unitTag], DrawThinCircle(x, y - 1200, z, 25.298, nil, true))
    end
end


-- Units can change when going into another zone, e.g. with a banker
-- summoned as playerpet1, we don't get unit destroyed event after
-- rezoning. So clean up all the pets and redo them.
local function OnPlayerActivated()
    for i = 1, MAX_PET_UNIT_TAGS do
        local tag = "playerpet" .. i
        OnUnitDestroyed(nil, tag)
        if (DoesUnitExist(tag)) then
            OnUnitCreated(nil, tag)
        end
    end
end


---------------------------------------------------------------------
---------------------------------------------------------------------
local function InitializeUnitDrawing()
    local profile = CAE.profiles[CAE.csvs.currentProfile]

    if (profile.shadowImageWireframe) then
        EVENT_MANAGER:RegisterForEvent(CAE.name .. "UDUnitCreated", EVENT_UNIT_CREATED, OnUnitCreated)
        EVENT_MANAGER:RegisterForEvent(CAE.name .. "UDUnitDestroyed", EVENT_UNIT_DESTROYED, OnUnitDestroyed)
        EVENT_MANAGER:RegisterForEvent(CAE.name .. "UDPlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    end
end
CAE.InitializeUnitDrawing = InitializeUnitDrawing

local function UnregisterUnitDrawing()
    EVENT_MANAGER:UnregisterForEvent(CAE.name .. "UDUnitCreated", EVENT_UNIT_CREATED)
    EVENT_MANAGER:UnregisterForEvent(CAE.name .. "UDUnitDestroyed", EVENT_UNIT_DESTROYED)
    EVENT_MANAGER:UnregisterForEvent(CAE.name .. "UDPlayerActivated", EVENT_PLAYER_ACTIVATED)

    for i = 1, MAX_PET_UNIT_TAGS do
        local tag = "playerpet" .. i
        OnUnitDestroyed(nil, tag)
    end
end


---------------------------------------------------------------------
function CAE.GetUnitDrawingSettings()
    return {
        {
            type = "checkbox",
            name = "Show Shadow Image range",
            tooltip = "Draws a big ugly wireframe sphere showing the range of your Shadow Image Teleport, when you cast Shadow Image",
            default = false,
            getFunc = function() return CAE.profiles[CAE.csvs.currentProfile].shadowImageWireframe end,
            setFunc = function(value)
                CAE.profiles[CAE.csvs.currentProfile].shadowImageWireframe = value
                UnregisterUnitDrawing()
                InitializeUnitDrawing()
            end,
            width = "full",
        },
    }
end

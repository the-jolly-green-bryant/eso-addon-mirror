local CAE = CrutchAlertsExtensions
local Crutch = CrutchAlerts


---------------------------------------------------------------------
-- Profile data
---------------------------------------------------------------------
function CAE.AddCircleToProfile(rgb, color, radius, yOffset, forwardOffset, conditionalAbilityId, conditionalSetId, conditionalEffectId, activeBarOnly, depthBuffers)
    local profile = CAE.profiles[CAE.csvs.currentProfile]

    local index = CAE.FindFreeId(profile.circles)
    profile.circles[index] = {
        type = CAE.CIRCLE,
        rgb = rgb,
        color = color,
        radius = radius,
        yOffset = yOffset,
        forwardOffset = forwardOffset,
        conditionalAbilityId = conditionalAbilityId,
        conditionalSetId = conditionalSetId,
        conditionalEffectId = conditionalEffectId,
        activeBarOnly = activeBarOnly,
        depthBuffers = depthBuffers,
    }

    CAE.msg(zo_strformat("Added circle of radius <<1>> to profile <<2>>", radius, profile.profileName))

    return index
end

-- TODO: renderspace rectangle with solid color only
function CAE.AddRectangleToProfile(rgb, color, fillColor, width, height, edgeSize, yOffset, forwardOffset, conditionalAbilityId, conditionalSetId, conditionalEffectId, activeBarOnly)
    local profile = CAE.profiles[CAE.csvs.currentProfile]

    local index = CAE.FindFreeId(profile.circles)
    profile.circles[index] = {
        type = CAE.RECTANGLE,
        rgb = rgb,
        color = color,
        fillColor = fillColor,
        radius = width, -- width is called radius, just to reuse the circle property
        height = height,
        edgeSize = edgeSize,
        yOffset = yOffset,
        forwardOffset = forwardOffset,
        conditionalAbilityId = conditionalAbilityId,
        conditionalSetId = conditionalSetId,
        conditionalEffectId = conditionalEffectId,
        activeBarOnly = activeBarOnly,
    }

    CAE.msg(zo_strformat("Added rectangle <<1>> × <<2>> to profile <<3>>", height, width, profile.profileName))

    return index
end

function CAE.AddPresetToProfile(presetName)
    local profile = CAE.profiles[CAE.csvs.currentProfile]

    local index = CAE.FindFreeId(profile.circles)
    profile.circles[index] = ZO_DeepTableCopy(CAE.PresetShapes[presetName])

    CAE.msg(zo_strformat("Imported <<1>> to profile <<2>>", presetName, profile.profileName))
    return index
end

function CAE.RemoveCircleFromProfile(index)
    local profile = CAE.profiles[CAE.csvs.currentProfile]
    CAE.msg(zo_strformat("Removing circle of radius <<1>> from profile <<2>>", profile.circles[index].radius, profile.profileName))
    profile.circles[index] = nil
end


---------------------------------------------------------------------
-- Loading / Drawing
---------------------------------------------------------------------
local currentKeys = {}
local function CleanShapes()
    for _, key in pairs(currentKeys) do
        Crutch.Drawing.RemoveWorldTexture(key)
    end
    ZO_ClearTable(currentKeys)
end

local function CreateCircle(id, radius, rgb, color, yOffset, depthBuffers, forwardOffset)
    local _, x, y, z = GetUnitRawWorldPosition("player")

    -- Places circle at player's feet
    local function CircleFunc(icon)
        if (not CAE.freeze) then
            -- Make circle follow the player
            local _, pX, y, pZ = GetUnitRawWorldPosition("player")
            local _, _, heading = GetMapPlayerPosition("player")
            local x = math.sin(heading) * -forwardOffset + pX
            local z = math.cos(heading) * -forwardOffset + pZ

            icon:SetPosition(x, y + yOffset, z)
        end

        -- Make color change every update
        if (rgb) then
            local time = GetGameTimeMilliseconds() % 2000 / 2000
            local r, g, b = Crutch.ConvertHSLToRGB(time, 1, 0.5)
            icon:SetColor(r, g, b, color[4])
        end
    end

    currentKeys[id] = Crutch.Drawing.CreateWorldTexture(
        "CrutchAlerts/assets/floor/circle.dds",
        x,
        y + yOffset,
        z,
        radius * 2,
        radius * 2,
        color,
        depthBuffers,
        false,
        {math.pi/2, 0, 0},
        CircleFunc)
end

local function CreateRectangle(id, width, height, edgeSize, rgb, color, fillColor, yOffset, forwardOffset)
    local _, pX, y, pZ = GetUnitRawWorldPosition("player")
    local _, _, heading = GetMapPlayerPosition("player")
    local x = math.sin(heading) * -forwardOffset + pX
    local z = math.cos(heading) * -forwardOffset + pZ

    local function RectangleFunc(icon)
        if (not CAE.freeze) then
            -- Make it follow the player
            local _, pX, y, pZ = GetUnitRawWorldPosition("player")
            local _, _, heading = GetMapPlayerPosition("player")
            local x = math.sin(heading) * -forwardOffset + pX
            local z = math.cos(heading) * -forwardOffset + pZ

            icon:SetPosition(x, y + yOffset, z)
            icon:SetOrientation(-math.pi/2, heading, 0)
        end

        -- Make color change every update
        if (rgb) then
            local time = GetGameTimeMilliseconds() % 2000 / 2000
            local r, g, b = Crutch.ConvertHSLToRGB(time, 1, 0.5)
            icon:SetBackdropColors(nil, nil, nil, nil, r, g, b, color[4])
        end
    end

    currentKeys[id] = Crutch.Drawing.CreateSpaceControl(
        x,
        y + yOffset,
        z,
        false,
        {-math.pi/2, heading, 0},
        {
            backdrop = {
                width = width * 100,
                height = height * 100,
                centerColor = fillColor,
                edgeColor = color,
                edgeSize = edgeSize,
            },
        },
        RectangleFunc)
end

local function CreateShapeById(id)
    local profile = CAE.profiles[CAE.csvs.currentProfile]
    local shapeData = profile.circles[id]
    if (shapeData.type == CAE.CIRCLE) then
        CreateCircle(id, shapeData.radius, shapeData.rgb, shapeData.color, shapeData.yOffset, shapeData.depthBuffers, shapeData.forwardOffset)
    elseif (shapeData.type == CAE.RECTANGLE) then
        CreateRectangle(id, shapeData.radius, shapeData.height, shapeData.edgeSize, shapeData.rgb, shapeData.color, shapeData.fillColor, shapeData.yOffset, shapeData.forwardOffset)
    end
end

local function ShowShape(id)
    if (currentKeys[id]) then return end -- already showing
    CreateShapeById(id)
end

local function HideShape(id)
    if (not currentKeys[id]) then return end -- already hidden
    Crutch.Drawing.RemoveWorldTexture(currentKeys[id])
    currentKeys[id] = nil
end

local function UpdateShapes()
    local profile = CAE.profiles[CAE.csvs.currentProfile]
    for id, shapeData in pairs(profile.circles) do
        if (CAE.ShouldShapeBeShown(shapeData.conditionalAbilityId, shapeData.conditionalSetId, shapeData.conditionalEffectId, shapeData.activeBarOnly)) then
            ShowShape(id)
        else
            HideShape(id)
        end
    end
end
CAE.UpdateShapes = UpdateShapes


---------------------------------------------------------------------
-- Listeners for profile change
-- TODO: move to profiles.lua?
---------------------------------------------------------------------
local profileListeners = {}

function CAE.RegisterProfileChangedListener(name, func)
    profileListeners[name] = func
end

function CAE.UnregisterProfileChangedListener(name)
    profileListeners[name] = nil
end

local function FireProfileChanged(isSame)
    for _, listener in pairs(profileListeners) do
        listener(isSame)
    end
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
local prevProfile = -2
local function LoadCurrentProfile(forceChange)
    CleanShapes()
    UpdateShapes()

    local profile = CAE.profiles[CAE.csvs.currentProfile]

    local isSame = prevProfile == CAE.csvs.currentProfile
    prevProfile = CAE.csvs.currentProfile

    if (not isSame) then
        CAE.msg("Loaded profile " .. profile.profileName)
    end

    if (forceChange) then
        isSame = false
    end
    FireProfileChanged(isSame)
end
CAE.LoadCurrentProfile = LoadCurrentProfile

function CAE.InitializeShapes()
    LoadCurrentProfile()
end

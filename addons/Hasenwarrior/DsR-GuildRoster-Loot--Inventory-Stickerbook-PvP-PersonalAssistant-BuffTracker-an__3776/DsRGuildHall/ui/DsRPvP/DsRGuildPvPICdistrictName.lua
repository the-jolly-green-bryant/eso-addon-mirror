
-- Create namespace
DsRGuildPvPICdistrictName = {}
local DsRGuildPvPICdistrictName = DsRGuildPvPICdistrictName  or {}

DsRGuildPvPICdistrictName.name = "DsRGuildPvPICdistrictName"

local EVENT_NAMESPACE = 'DsRGuildPvPICdistrictName'

local PI            = math.pi
local Vector        = LibImplex.Vector
local SCALE         = 1
local HEIGHT        = 300
local IC_DISTRICTS  = {141, 142, 143, 146, 147, 148}
local ALLIANCE

local SHORT_EN_NAMES = {
    [141] = 'Nobles',
    [142] = 'Memorial',
    [143] = 'Arboretum',
    [146] = 'Arena',
    [147] = 'Temple',
    [148] = 'Elven Gardens',
}

local DISTRICT_LADDERS = {
    [3] = {
        [141] = {{5910.60, 13352, 154189.31}, 0.00},
        [142] = {{6177.06, 13352, 155529.24}, 1.50},
        [143] = {{4475.43, 13352, 155940.81}, 0.75},
        [146] = {{5808.02, 13352, 156012.89}, 1.00},
        [147] = {{4414.21, 13352, 154322.96}, 0.25},
        [148] = {{6175.10, 13352, 154701.49}, 1.50},
    },
    [2] = {
        [141] = {{167732.30, 11179, 20981.23}, 0.00},
        [142] = {{166836.60, 11179, 22796.48}, 1.00},
        [143] = {{166340.68, 11179, 21422.42}, 0.50},
        [146] = {{166341.71, 11179, 22326.58}, 0.50},
        [147] = {{166846.57, 11179, 20972.04}, 0.00},
        [148] = {{167738.94, 11179, 22792.80}, 1.00},
    },
    [1] = {
        [141] = {{275361.16, 12850, 181472.99}, 1.50},
        [142] = {{274020.06, 12850, 181708.23}, 1.00},
        [143] = {{273615.09, 12850, 180038.41}, 0.23},
        [146] = {{273539.26, 12850, 181370.65}, 0.50},
        [147] = {{275242.71, 12850, 179970.38}, 1.74},
        [148] = {{274850.06, 12850, 181737.74}, 1.00},
    }
}

local ALLIANCE_COLOR = {}
do
    for allianceId = 1, 3 do
        ALLIANCE_COLOR[allianceId] = {GetAllianceColor(allianceId):UnpackRGBA()}
        ALLIANCE_COLOR[allianceId][4] = 0.75
    end
    ALLIANCE_COLOR[0] = {1, 1, 1, 0.75}
end

-- ----------------------------------------------------------------------------

local function getLocalizedDistrictNames_EN(keepId)
    return SHORT_EN_NAMES[keepId]
end

local function getLocalizedDistrictNames_DE(keepId)
    return zo_strformat(SI_TOOLTIP_KEEP_NAME, GetKeepName(keepId))
end

local LOCALIZATIONS = {
    ['en'] = getLocalizedDistrictNames_EN,
    ['de'] = function(keepId)
        if keepId == 143 then return 'Arboretum' end
        return getLocalizedDistrictNames_DE(keepId)
    end,
}

local getLocalizedDistrictName = function(...) error('MUST CHANGE') end

local LADDERS_LABELS = {}

local function DrawLadderLabel(keepId)
    local ladderData = DISTRICT_LADDERS[ALLIANCE][keepId]

    local text = LibImplex.Text(
        getLocalizedDistrictName(keepId),
        CENTER,
        Vector(ladderData[1]) + {0, HEIGHT, 0},
        {0, ladderData[2] * PI, 0, true},
        0.56 * SCALE,
        nil,
        600,
        false,
        LibImplex.Text.OBJECT_FACTORIES.Object
    )

    text:Render()

    return text
end

local function setLabelColor(label, color)
    label.text:SetColor(color)
end

local function DrawEverything()
    for i = 1, 6 do
        local keepId = IC_DISTRICTS[i]

        local text = DrawLadderLabel(keepId)

        local label = {
            text = text,
        }
        LADDERS_LABELS[keepId] = label

        local alliance = GetKeepAlliance(keepId, BGQUERY_LOCAL)
        if alliance > 0 then
            local color = ALLIANCE_COLOR[alliance]
            setLabelColor(label, color)
        end
    end
end

local function ClearEverything()
    for i, label in pairs(LADDERS_LABELS) do
        if label ~= nil then
            label.text:Delete()
            label.text = nil

            LADDERS_LABELS[i] = nil
        end
    end
end

-- ----------------------------------------------------------------------------

local function withChecks(func)
    local function inner(_, keepId, battlegroundContext, ...)
        if battlegroundContext ~= BGQUERY_LOCAL then return end

        local label = LADDERS_LABELS[keepId]
        if not label then return end

        return func(label, keepId, battlegroundContext, ...)
    end

    return inner
end

local EVENT_HANDLERS = {
    [EVENT_KEEP_ALLIANCE_OWNER_CHANGED] = withChecks(function(label, keepId, battlegroundContext, owningAlliance, oldOwningAlliance)
        local allianceColor = ALLIANCE_COLOR[owningAlliance]
        setLabelColor(label, allianceColor)
    end),
    [EVENT_KEEPS_INITIALIZED] = function(_)
        for keepId, label in pairs(LADDERS_LABELS) do
            if label then
                local alliance = GetKeepAlliance(keepId, BGQUERY_LOCAL)
                local allianceColor = ALLIANCE_COLOR[alliance]
                setLabelColor(label, allianceColor)
            end
        end
    end
}

local function RegisterEvents()
    for event, handler in pairs(EVENT_HANDLERS) do
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, event, handler)
    end
end

local function UnregisterEvents()
    for event, _ in pairs(EVENT_HANDLERS) do
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, event)
    end
end

local IN_SEWERS

local function OnPlayerActivated()
    local inSewers = GetZoneId(GetUnitZoneIndex('player')) == 643
    if inSewers == IN_SEWERS then return end

    ALLIANCE = GetUnitAlliance('player')

    if not inSewers then
        ClearEverything()
        UnregisterEvents()
        return
    end

    DrawEverything()
    RegisterEvents()
end

function DsRGuildPvPICdistrictName.OnAddonLoaded(event, name)
    SCALE   = 0.8
    HEIGHT  = 120
    
    if DsRGuildPvP.pvp.PvPICsewers == true then
        local lang  = GetCVar("language.2")

        getLocalizedDistrictName = LOCALIZATIONS[lang]

        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    end
end

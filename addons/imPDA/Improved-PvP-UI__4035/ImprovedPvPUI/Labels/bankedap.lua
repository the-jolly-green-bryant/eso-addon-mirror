local PI = math.pi
local Object = LibImplex.Objects._3DStatic

local EVENT_NAMESPACE = 'IMP_CBA_EVENT_NAMESPACE'
-- local ALLIANCE
local SUBZONE_ID

-- ----------------------------------------------------------------------------

local function comma_value(n) -- credit http://richard.warburton.it
	local left, num, right = string.match(n, '^([^%d]*%d)(%d*)(.-)$')
	return left .. num:reverse():gsub('(%d%d%d)','%1,'):reverse() .. right
end

-- ----------------------------------------------------------------------------

local SUBZONE_NAME_TO_ID = {
    -- en ---------------------------------
    ["Western Elsweyr Gate"]        = 3356,
    -- ["Eastern Elsweyr Gate"]     = ...,
    ["Southern Morrowind Gate"]     = 3358,
    -- ["Northern Morrowind Gate"]  = ...,
    ["Northern High Rock  Gate"]    = 3360,
    -- ["Southern High Rock  Gate"] = 3361,
    -- fr ---------------------------------
    ["porte ouest d'Elsweyr^fd"]    = 3356,
    ["porte sud de Morrowind^fd"]   = 3358,
    ["porte nord de Hauteroche"]    = 3360,
    -- de ---------------------------------
    ["Westtor nach Elsweyr^nd"]     = 3356,
    ["Südtor nach Morrowind^nd"]    = 3358,
    ["Nordtor nach Hochfels^nd,an"] = 3360,
    -- ru ---------------------------------
    ["Западные ворота Эльсвейра"]   = 3356,
    ["Южные ворота Морровинда"]     = 3358,
    ["Северные ворота Хай-Рока"]    = 3360,
    -- es ---------------------------------
    ["puerta oeste de Elsweyr^fd"]  = 3356,
    ["puerta sur de Morrowind^f"]   = 3358,
    ["puerta norte de Roca Alta^f"] = 3360,
    -- zh ---------------------------------
    ["艾斯维尔西大门"]  = 3356,
    ["南方晨风之门"]    = 3358,
    ["北方高岩之门"]    = 3360,
}

local function GetSubzoneId()
    return SUBZONE_NAME_TO_ID[GetPlayerActiveSubzoneName()]
end

-- ----------------------------------------------------------------------------

local BANKS = {
    [3356] = {{395405, 24812+425, 883564}, {0, -0.10 * PI, 0}},  -- AD
    [3358] = {{929639, 40984+425, 313173}, {0,  0.71 * PI, 0}},  -- EP
    [3360] = {{159056, 34990+425,  92269}, {0, -0.39 * PI, 0}},  -- DC
}

local LABEL
local ICON
-- local ICON_TEXTURE = GetCurrencyKeyboardIcon(CURT_ALLIANCE_POINTS)
local ICON_TEXTURE = '/esoui/art/currency/alliancepoints_64.dds'

local function DrawIcon(label)
    local pX, pY, pZ = label:GetRelativePointCoordinates(BOTTOMRIGHT, 30, 39+8, -2)

    if ICON then
        ICON:SetPosition(pX, pY, pZ)
    else
        ICON = Object()
        ICON:SetTexture(ICON_TEXTURE)
        ICON:SetDimensions(0.6, 0.6)
        ICON:SetPosition(pX, pY, pZ)
        ICON:AddSystem(LibImplex.Systems.DepthBuffer)
        ICON:SetOrientation(unpack(label.orientation))
    end
end

local function setText(value)
    LABEL.text = comma_value(tostring(value))
    LABEL:Render()

    DrawIcon(LABEL)
end

local ANIMATION_EVENT_NAMESPACE = EVENT_NAMESPACE .. 'APAnimation'
local ANIMATION = IMP_BankedCurrencyAnimation.New(
    2100,
    setText,
    ANIMATION_EVENT_NAMESPACE
)

local function DrawLabel(currencyAmount, previousCurrencyAmount)
    local bankData = BANKS[SUBZONE_ID]
    if not bankData then return end

    if not LABEL then
        LABEL = LibImplex.Text(
            '',
            TOP,
            bankData[1],
            bankData[2],
            1,
            {46 / 255, 220 / 255, 34 / 255}
        )
        LABEL.useDepthBuffer = true  -- TODO: do I need this?
    end

    if previousCurrencyAmount then
        ANIMATION:Start(previousCurrencyAmount, currencyAmount)
    else
        setText(currencyAmount)
    end
end

local function ClearLabel()
    if LABEL then
        LABEL:Delete()
        LABEL = nil
    end

    if ICON then
        ICON:Delete()
        ICON = nil
    end
end

local function OnSubzoneChange(newSubzone)
    if newSubzone == SUBZONE_ID then return end
    SUBZONE_ID = newSubzone

    if not BANKS[SUBZONE_ID] then
        ClearLabel()

        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_BANKED_CURRENCY_UPDATE)
    else
        DrawLabel(GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_BANK))

        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_BANKED_CURRENCY_UPDATE, function(_, currency, newValue, oldValue)
            if currency ~= CURT_ALLIANCE_POINTS then return end
            DrawLabel(newValue, oldValue)
        end)
    end
end

local function OnPlayerActivated()
    local currentSubzoneId = GetSubzoneId()
    OnSubzoneChange(currentSubzoneId)
end

function IMP_CBA_Initialize(sv)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ZONE_CHANGED, function(_, ...) OnSubzoneChange(select(5, ...)) end)
end

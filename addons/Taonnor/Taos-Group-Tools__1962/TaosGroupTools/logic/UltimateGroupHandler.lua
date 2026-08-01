--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Local variables
]]--
local _logger = nil

local _name = "TGT-UltimateGroupHandler"
local _ultimateGroups = nil

--[[
	Table TGT_UltimateGroupHandler
]]--
TGT_UltimateGroupHandler = {}
TGT_UltimateGroupHandler.__index = TGT_UltimateGroupHandler

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	CreateUltimateGroups Creates UltimateGroups array
]]--
local function CreateUltimateGroups()
    -- Sorc
    local negate = {}
    negate.GroupName = "NEGATE"
    negate.GroupDescription = GetString(TGT_DESCRIPTIONS_NEGATE)
    negate.GroupAbilityPing = 1
    negate.GroupAbilityId = 28341

    local atro = {}
    atro.GroupName = "ATRO"
    atro.GroupDescription = GetString(TGT_DESCRIPTIONS_ATRO)
    atro.GroupAbilityPing = 2
    atro.GroupAbilityId = 23634

    local overload = {}
    overload.GroupName = "OVER"
    overload.GroupDescription = GetString(TGT_DESCRIPTIONS_OVER)
    overload.GroupAbilityPing = 3
    overload.GroupAbilityId = 24785

    -- Templar
    local sweep = {}
    sweep.GroupName = "SWEEP"
    sweep.GroupDescription = GetString(TGT_DESCRIPTIONS_SWEEP)
    sweep.GroupAbilityPing = 4
    sweep.GroupAbilityId = 22138
    
    local nova = {}
    nova.GroupName = "NOVA"
    nova.GroupDescription = GetString(TGT_DESCRIPTIONS_NOVA)
    nova.GroupAbilityPing = 5
    nova.GroupAbilityId = 21752

    local templarHeal = {}
    templarHeal.GroupName = "TPHEAL"
    templarHeal.GroupDescription = GetString(TGT_DESCRIPTIONS_TPHEAL)
    templarHeal.GroupAbilityPing = 6
    templarHeal.GroupAbilityId = 22223

    -- DK
    local standard = {}
    standard.GroupName = "STAND"
    standard.GroupDescription = GetString(TGT_DESCRIPTIONS_STAND)
    standard.GroupAbilityPing = 7
    standard.GroupAbilityId = 28988

    local leap = {}
    leap.GroupName = "LEAP"
    leap.GroupDescription = GetString(TGT_DESCRIPTIONS_LEAP)
    leap.GroupAbilityPing = 8
    leap.GroupAbilityId = 29012

    local magma = {}
    magma.GroupName = "MAGMA"
    magma.GroupDescription = GetString(TGT_DESCRIPTIONS_MAGMA)
    magma.GroupAbilityPing = 9
    magma.GroupAbilityId = 15957

    -- NB
    local stroke = {}
    stroke.GroupName = "STROKE"
    stroke.GroupDescription = GetString(TGT_DESCRIPTIONS_STROKE)
    stroke.GroupAbilityPing = 10
    stroke.GroupAbilityId = 33398

    local veil = {}
    veil.GroupName = "VEIL"
    veil.GroupDescription = GetString(TGT_DESCRIPTIONS_VEIL)
    veil.GroupAbilityPing = 11
    veil.GroupAbilityId = 25411

    local nbSoul = {}
    nbSoul.GroupName = "NBSOUL"
    nbSoul.GroupDescription = GetString(TGT_DESCRIPTIONS_NBSOUL)
    nbSoul.GroupAbilityPing = 12
    nbSoul.GroupAbilityId = 25091

    -- Warden
    -- BEAR not useful, its always up

    local wardenIce = {}
    wardenIce.GroupName = "FREEZE"
    wardenIce.GroupDescription = GetString(TGT_DESCRIPTIONS_FREEZE)
    wardenIce.GroupAbilityPing = 13
    wardenIce.GroupAbilityId = 86109

    local wardenHealing = {}
    wardenHealing.GroupName = "WDHEAL"
    wardenHealing.GroupDescription = GetString(TGT_DESCRIPTIONS_WDHEAL)
    wardenHealing.GroupAbilityPing = 14
    wardenHealing.GroupAbilityId = 85532

    -- Destro
    local staffDestro = {}
    staffDestro.GroupName = "DESTRO"
    staffDestro.GroupDescription = GetString(TGT_DESCRIPTIONS_DESTRO)
    staffDestro.GroupAbilityPing = 15
    staffDestro.GroupAbilityId = 83619

    -- Restro
    local staffHeal = {}
    staffHeal.GroupName = "STHEAL"
    staffHeal.GroupDescription = GetString(TGT_DESCRIPTIONS_STHEAL)
    staffHeal.GroupAbilityPing = 16
    staffHeal.GroupAbilityId = 83552

    -- 2H
    local twoHand = {}
    twoHand.GroupName = "BERSERK"
    twoHand.GroupDescription = GetString(TGT_DESCRIPTIONS_BERSERK)
    twoHand.GroupAbilityPing = 17
    twoHand.GroupAbilityId = 83216

    -- SB
    local shield = {}
    shield.GroupName = "SHIELD"
    shield.GroupDescription = GetString(TGT_DESCRIPTIONS_SHIELD)
    shield.GroupAbilityPing = 18
    shield.GroupAbilityId = 83272

    -- DW
    local dual = {}
    dual.GroupName = "DUAL"
    dual.GroupDescription = GetString(TGT_DESCRIPTIONS_DUAL)
    dual.GroupAbilityPing = 19
    dual.GroupAbilityId = 83600

    -- BOW
    local bow = {}
    bow.GroupName = "BOW"
    bow.GroupDescription = GetString(TGT_DESCRIPTIONS_BOW)
    bow.GroupAbilityPing = 20
    bow.GroupAbilityId = 83465

    -- Soul
    local soul = {}
    soul.GroupName = "SOUL"
    soul.GroupDescription = GetString(TGT_DESCRIPTIONS_SOUL)
    soul.GroupAbilityPing = 21
    soul.GroupAbilityId = 39270

    -- Werewolf
    local werewolf = {}
    werewolf.GroupName = "WERE"
    werewolf.GroupDescription = GetString(TGT_DESCRIPTIONS_WERE)
    werewolf.GroupAbilityPing = 22
    werewolf.GroupAbilityId = 32455

    -- Vamp
    local vamp = {}
    vamp.GroupName = "VAMP"
    vamp.GroupDescription = GetString(TGT_DESCRIPTIONS_VAMP)
    vamp.GroupAbilityPing = 23
    vamp.GroupAbilityId = 32624

    -- Mageguild
    local meteor = {}
    meteor.GroupName = "METEOR"
    meteor.GroupDescription = GetString(TGT_DESCRIPTIONS_METEOR)
    meteor.GroupAbilityPing = 24
    meteor.GroupAbilityId = 16536

    -- Fighterguild
    local dawnbreaker = {}
    dawnbreaker.GroupName = "DAWN"
    dawnbreaker.GroupDescription = GetString(TGT_DESCRIPTIONS_DAWN)
    dawnbreaker.GroupAbilityPing = 25
    dawnbreaker.GroupAbilityId = 35713

    -- Support
    local barrier = {}
    barrier.GroupName = "BARRIER"
    barrier.GroupDescription = GetString(TGT_DESCRIPTIONS_BARRIER)
    barrier.GroupAbilityPing = 26
    barrier.GroupAbilityId = 38573

    -- Assault
    local horn = {}
    horn.GroupName = "HORN"
    horn.GroupDescription = GetString(TGT_DESCRIPTIONS_HORN)
    horn.GroupAbilityPing = 27
    horn.GroupAbilityId = 38563

    --Goliath
    local goliath = {}
    goliath.GroupName = "GOLIATH"
    goliath.GroupDescription = GetString(TGT_DESCRIPTIONS_GOLIATH)
    goliath.GroupAbilityPing = 28
    goliath.GroupAbilityId = 115001

    --Colossus
    local colossus = {}
    colossus.GroupName = "COLOSSUS"
    colossus.GroupDescription = GetString(TGT_DESCRIPTIONS_COLOSSUS)
    colossus.GroupAbilityPing = 29
    colossus.GroupAbilityId = 122174

    --Reanimate
    local reanimate = {}
    reanimate.GroupName = "REANIMATE"
    reanimate.GroupDescription = GetString(TGT_DESCRIPTIONS_REANIMATE)
    reanimate.GroupAbilityPing = 30
    reanimate.GroupAbilityId = 115410

    -- Add groups
    _ultimateGroups = 
    { 
        negate, atro, overload, 
        sweep, nova, templarHeal, 
        standard, leap, magma, 
        stroke, veil, nbSoul,
        wardenIce, wardenHealing, 
        staffDestro, staffHeal, 
        twoHand, shield, dual, bow,
        soul, werewolf, vamp,
        meteor, dawnbreaker, 
        barrier, horn, goliath,
        colossus, reanimate
    }
end

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	GetUltimateGroupByAbilityPing gets the ultimate group from given ability ping
]]--
function TGT_UltimateGroupHandler.GetUltimateGroupByAbilityPing(abilityPing)
    for i, group in pairs(_ultimateGroups) do
        if (group.GroupAbilityPing == abilityPing) then
            return group
        end
    end

    -- not found
    _logger:logError("UltimateGroupHandler -> GetUltimateGroupByAbilityPing; AbilityId not found " .. tostring(abilityPing))

    return nil
end

--[[
	GetUltimateGroupByAbilityId gets the ultimate group from given ability ID
]]--
function TGT_UltimateGroupHandler.GetUltimateGroupByAbilityId(abilityID)
    for i, group in pairs(_ultimateGroups) do
        if (group.GroupAbilityId == abilityID) then
            return group
        end
    end

    -- not found
    _logger:logError("UltimateGroupHandler -> GetUltimateGroupByAbilityId; AbilityId not found " .. tostring(abilityID))

    return nil
end

--[[
	GetUltimateGroupByGroupName gets the ultimate group from given group name
]]--
function TGT_UltimateGroupHandler.GetUltimateGroupByGroupName(groupName)
    for i, group in pairs(_ultimateGroups) do
        if (string.lower(group.GroupName) == string.lower(groupName)) then
            return group
        end
    end

    -- not found
    _logger:logError("UltimateGroupHandler -> GetUltimateGroupByGroupName; GroupName not found " .. tostring(groupName))

    return nil
end

--[[
	GetUltimateGroups gets all ultimate groups
]]--
function TGT_UltimateGroupHandler.GetUltimateGroups()
    return _ultimateGroups
end

--[[
	Initialize initializes TGT_UltimateGroupHandler
]]--
function TGT_UltimateGroupHandler.Initialize()
    _logger = TGT_LOGGER

    CreateUltimateGroups()
    
    _logger:logTrace("TGT_UltimateGroupHandler -> Initialized")
end
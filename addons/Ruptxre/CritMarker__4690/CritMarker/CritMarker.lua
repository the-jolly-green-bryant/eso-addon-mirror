local EM = EVENT_MANAGER

local CritMarker = {
    name = "CritMarker",
    svName = "CritMarker_SV",
    svVersion = 1,
    SV = nil,
    ui = nil,
    settings = nil,
}

CritMarker.defaults = {
    critTexture = "Style1",
    killTexture = "Style1",
    critEnabled = true,
    killEnabled = true,
    color = "White",
    killColor = "Red",
    critSize = 32,
    killSize = 32,
    critSound = "Hard Hit",
    killSound = "Crunch",
    critSoundBoost = 1,
    killSoundBoost = 1,
}

CritMarker.TEXTURE_OPTIONS = {
    "Style1","Style2","Style3","Style4","Style5","Style6","Style7","Style8",
    "Style9","Style10","Style11","Style12","Style13","Style14","Style15","Style16",
    "Style17","Style18","Style19","Style20","Style21","Style22","Style23",
}

CritMarker.texLookup = {
    ["Style1"] = "hitmarker.dds",
    ["Style2"] = "hitmarker2.dds",
    ["Style3"] = "hitmarker3.dds",
    ["Style4"] = "hitmarker4.dds",
    ["Style5"] = "hitmarker5.dds",
    ["Style6"] = "hitmarker6.dds",
    ["Style7"] = "hitmarker7.dds",
    ["Style8"] = "hitmarker8.dds",
    ["Style9"] = "hitmarker9.dds",
    ["Style10"] = "hitmarker10.dds",
    ["Style11"] = "hitmarker11.dds",
    ["Style12"] = "hitmarker12.dds",
    ["Style13"] = "hitmarker13.dds",
    ["Style14"] = "hitmarker14.dds",
    ["Style15"] = "hitmarker15.dds",
    ["Style16"] = "hitmarker16.dds",
    ["Style17"] = "hitmarker17.dds",
    ["Style18"] = "hitmarker18.dds",
    ["Style19"] = "hitmarker19.dds",
    ["Style20"] = "hitmarker20.dds",
    ["Style21"] = "hitmarker21.dds",
    ["Style22"] = "hitmarker22.dds",
    ["Style23"] = "hitmarker23.dds",
}

CritMarker.SOUND_OPTIONS = { "None", "Soft Hit", "Hard Hit", "Bleed", "Crunch" }

CritMarker.soundLookup = {
    ["Soft Hit"] = SOUNDS.DEFAULT_CLICK,
    ["Hard Hit"] = SOUNDS.ABILITY_PICKED_UP,
    ["Bleed"] = SOUNDS.BOOK_OPEN,
    ["Crunch"] = SOUNDS.LOCKPICKING_UNLOCKED,
}

CritMarker.colorLookup = {
    White = {1,1,1},
    Black = {0,0,0},
    Red = {1,0.2,0.2},
    Orange = {1,0.5,0.1},
    Yellow = {1,0.9,0.2},
    Green = {0.2,1,0.3},
    Blue = {0.2,0.6,1},
    Purple = {0.7,0.3,1},
    Pink = {1,0.4,0.7},
}

CritMarker.rainbowColors = {
    {1,1,1},{1,0.2,0.2},{1,0.9,0.2},
    {0.2,1,0.3},{0.2,0.6,1},{0.7,0.3,1},
    {1,0.5,0.1},{1,0.4,0.7},
}

local zo_callLater = zo_callLater
local zo_removeCallLater = zo_removeCallLater
local PlaySound_local = PlaySound
local GetRawUnitName_local = GetRawUnitName
local GetUnitName_local = GetUnitName
local GetDisplayName_local = GetDisplayName
local GetFrameTimeMilliseconds_local = GetFrameTimeMilliseconds

local function EnsureDefault(tbl, key, default)
    if tbl[key] == nil then tbl[key] = default end
end

local Marker = {}
Marker.__index = Marker

function Marker:New(owner)
    local o = setmetatable({}, self)
    o.owner = owner
    o.window = nil
    o.texture = nil
    o.hideTimer = nil
    o.scaleTimer = nil
    o.fadeTimer = nil
    o.rainbowIndex = 1
    o.lastKillTime = 0
    o.lastKillTarget = nil
    o:CreateWindow()
    return o
end

function Marker:CreateWindow()
    local SV = self.owner.SV
    self.window = WINDOW_MANAGER:CreateTopLevelWindow("CritMarker_UI")
    self.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    self.window:SetDimensions(SV.critSize, SV.critSize)
    self.window:SetHidden(true)
    local tex = WINDOW_MANAGER:CreateControl(nil, self.window, CT_TEXTURE)
    tex:SetAnchorFill(self.window)
    tex:SetBlendMode(TEX_BLEND_MODE_ALPHA)
    self.texture = tex
    self:SetTexture("Crit")
end

function Marker:ClearTimer(field)
    local id = self[field]
    if id then
        zo_removeCallLater(id)
        self[field] = nil
    end
end

function Marker:SetTexture(markerType)
    local SV = self.owner.SV
    local key = markerType == "Kill" and SV.killTexture or SV.critTexture
    local file = self.owner.texLookup[key]
    if file and self.texture then
        self.texture:SetTexture("CritMarker/" .. file)
    end
end

function Marker:ApplySize(markerType)
    local SV = self.owner.SV
    local size = markerType == "Kill" and SV.killSize or SV.critSize
    self.window:SetDimensions(size, size)
end

function Marker:ApplyColor(name)
    if name == "Rainbow" then
        local c = self.owner.rainbowColors[self.rainbowIndex]
        self.texture:SetColor(c[1],c[2],c[3],1)
        self.rainbowIndex = (self.rainbowIndex % #self.owner.rainbowColors) + 1
        return
    end
    local c = self.owner.colorLookup[name]
    if c then self.texture:SetColor(c[1],c[2],c[3],1) end
end

function Marker:PlaySelectedSound(markerType)
    local SV = self.owner.SV
    local soundName = markerType == "Kill" and SV.killSound or SV.critSound
    local boost = markerType == "Kill" and SV.killSoundBoost or SV.critSoundBoost
    if not soundName or soundName == "None" then return end
    local id = self.owner.soundLookup[soundName]
    if not id then return end
    for i = 1, boost or 1 do PlaySound_local(id) end
end

function Marker:ResetTimers()
    self:ClearTimer("scaleTimer")
    self:ClearTimer("fadeTimer")
    self:ClearTimer("hideTimer")
end

function Marker:RunAnimation(markerType, preview, duration)
    duration = duration or 140
    self.texture:SetAlpha(1)
    if preview then
        self.window:SetScale(1)
    else
        self.window:SetScale(markerType == "Kill" and 1.75 or 1.5)
        self.scaleTimer = zo_callLater(function()
            if self.window then self.window:SetScale(1) end
            self.scaleTimer = nil
        end, 75)
        self.fadeTimer = zo_callLater(function()
            if self.texture then self.texture:SetAlpha(0.4) end
            self.fadeTimer = nil
        end, 60)
    end
    self.hideTimer = zo_callLater(function()
        if self.window then
            self.window:SetHidden(true)
            self.window:SetScale(1)
            if self.texture then self.texture:SetAlpha(1) end
        end
        self.hideTimer = nil
    end, duration)
end

function Marker:Show(colorOverride, markerType, force, duration, preview, playSound)
    local SV = self.owner.SV
    if not force then
        if markerType == "Kill" and not SV.killEnabled then return end
        if markerType ~= "Kill" and not SV.critEnabled then return end
    end
    self:ApplySize(markerType)
    self:SetTexture(markerType)
    self.window:SetHidden(false)
    self:ResetTimers()
    if playSound ~= false then self:PlaySelectedSound(markerType) end
    self:ApplyColor(colorOverride or SV.color)
    self:RunAnimation(markerType, preview, duration)
end

function Marker:HandleCombatCrit()
    self:Show(self.owner.SV.color, "Crit")
end

function Marker:HandlePvPKill(_, killerPlayerDisplayName, killerCharacterName, _, _, victimPlayerDisplayName, victimCharacterName)
    local myChar = GetRawUnitName_local(GetUnitName_local("player"))
    local myAcc = GetDisplayName_local()
    if killerCharacterName == myChar or killerPlayerDisplayName == myAcc then
        if victimCharacterName ~= myChar and victimPlayerDisplayName ~= myAcc then
            local now = GetFrameTimeMilliseconds_local()
            if victimCharacterName == self.lastKillTarget and (now - self.lastKillTime) < 1500 then return end
            self.lastKillTarget = victimCharacterName
            self.lastKillTime = now
            self:Show(self.owner.SV.killColor, "Kill")
        end
    end
end

function Marker:HandleDuelKill()
    self:Show(self.owner.SV.killColor, "Kill")
end

local Settings = {}
Settings.__index = Settings

function Settings:New(owner)
    return setmetatable({ owner = owner }, self)
end

function Settings:CreateMenu()
    local LAM = LibAddonMenu2
    local addon = self.owner
    local SV = addon.SV
    local marker = addon.ui

    LAM:RegisterAddonPanel("CritMarker_Settings", {
        type = "panel",
        name = "CritMarker",
        displayName = "|cFf0000CritMarker|r",
        author = "|cadff2f@Ruptxre|r & |c0FFFFF@Sikma|r",
        version = "1.0",
    })

    local function markerColorChoices()
        return { "White","Black","Red","Orange","Yellow","Green","Blue","Purple","Pink","Rainbow" }
    end

    LAM:RegisterOptionControls("CritMarker_Settings", {
        { type="header", name="General Settings" },
        { type="checkbox", name="Enable Critmarker", getFunc=function() return SV.critEnabled end, setFunc=function(v) SV.critEnabled=v end },
        { type="checkbox", name="Enable PvP Killmarker", getFunc=function() return SV.killEnabled end, setFunc=function(v) SV.killEnabled=v end },
        { type="dropdown", name="Critmarker Style", choices=addon.TEXTURE_OPTIONS, getFunc=function() return SV.critTexture end, setFunc=function(v) SV.critTexture=v marker:Show(SV.color,"Crit",true,2500,true,false) end },
        { type="dropdown", name="PvP Killmarker Style", choices=addon.TEXTURE_OPTIONS, getFunc=function() return SV.killTexture end, setFunc=function(v) SV.killTexture=v marker:Show(SV.killColor,"Kill",true,2500,true,false) end },
        { type="header", name="Testing" },
        { type="button", name="Test Critmarker", func=function() marker:Show(SV.color,"Crit",true) end },
        { type="button", name="Test PvP Killmarker", func=function() marker:Show(SV.killColor,"Kill",true) end },
        { type="header", name="Critmarker Settings" },
        { type="dropdown", name="Color", choices=markerColorChoices(), getFunc=function() return SV.color end, setFunc=function(v) SV.color=v end },
        { type="slider", name="Size", min=24, max=128, step=2, getFunc=function() return SV.critSize end, setFunc=function(v) SV.critSize=v marker:ApplySize("Crit") end },
        { type="dropdown", name="Sound", choices=addon.SOUND_OPTIONS, getFunc=function() return SV.critSound end, setFunc=function(v) SV.critSound=v end },
        { type="slider", name="Sound Boost", min=1, max=10, step=1, getFunc=function() return SV.critSoundBoost end, setFunc=function(v) SV.critSoundBoost=v end },
        { type="header", name="PvP Killmarker Settings" },
        { type="dropdown", name="Color", choices=markerColorChoices(), getFunc=function() return SV.killColor end, setFunc=function(v) SV.killColor=v end },
        { type="slider", name="Size", min=24, max=128, step=2, getFunc=function() return SV.killSize end, setFunc=function(v) SV.killSize=v marker:ApplySize("Kill") end },
        { type="dropdown", name="Sound", choices=addon.SOUND_OPTIONS, getFunc=function() return SV.killSound end, setFunc=function(v) SV.killSound=v end },
        { type="slider", name="Sound Boost", min=1, max=10, step=1, getFunc=function() return SV.killSoundBoost end, setFunc=function(v) SV.killSoundBoost=v end },
    })
end

function CritMarker:InitSavedVars()
    self.SV = ZO_SavedVars:NewAccountWide(self.svName, self.svVersion, nil, self.defaults)
    if self.SV.texture and self.texLookup[self.SV.texture] then
        if not self.SV.critTexture then self.SV.critTexture = self.SV.texture end
        if not self.SV.killTexture then self.SV.killTexture = self.SV.texture end
        self.SV.texture = nil
    end
    EnsureDefault(self.SV,"critTexture","Style1")
    EnsureDefault(self.SV,"killTexture","Style1")
    EnsureDefault(self.SV,"critSound","Hard Hit")
    EnsureDefault(self.SV,"killSound","Crunch")
    EnsureDefault(self.SV,"critSize",32)
    EnsureDefault(self.SV,"killSize",32)
    EnsureDefault(self.SV,"critSoundBoost",1)
    EnsureDefault(self.SV,"killSoundBoost",1)
    EnsureDefault(self.SV,"critEnabled",true)
    EnsureDefault(self.SV,"killEnabled",true)
end

function CritMarker:CreateModules()
    self.ui = Marker:New(self)
    self.settings = Settings:New(self)
    self.ui:ApplySize("Crit")
end

function CritMarker:RegisterEvents()
    EM:RegisterForEvent(self.name.."_COMBAT", EVENT_COMBAT_EVENT, function(...)
        local result = select(2,...)
        if result ~= ACTION_RESULT_CRITICAL_DAMAGE then return end
        self.ui:HandleCombatCrit()
    end)
    EM:AddFilterForEvent(self.name.."_COMBAT", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    EM:AddFilterForEvent(self.name.."_COMBAT", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_CRITICAL_DAMAGE)

    EM:RegisterForEvent(self.name.."_PVP_KILL", EVENT_PVP_KILL_FEED_DEATH, function(_, killLocation,
        killerPlayerDisplayName, killerCharacterName, killerAlliance, killerRank,
        victimPlayerDisplayName, victimCharacterName)
        self.ui:HandlePvPKill(killLocation, killerPlayerDisplayName, killerCharacterName,
            killerAlliance, killerRank, victimPlayerDisplayName, victimCharacterName)
    end)

    EM:RegisterForEvent(self.name.."_DUEL_FINISHED", EVENT_DUEL_FINISHED, function(_, duelResult, wasLocalPlayersResult)
        if duelResult == DUEL_RESULT_WON and wasLocalPlayersResult then
            self.ui:HandleDuelKill()
        end
    end)

    EM:RegisterForEvent(self.name.."_UNIVERSAL_KILL", EVENT_COMBAT_EVENT, function(_, result,
        isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName,
        sourceType, targetName, targetType, hitValue, powerType, damageType,
        log, sourceUnitId, targetUnitId)
        if result ~= ACTION_RESULT_DIED and result ~= ACTION_RESULT_DIED_XP and result ~= ACTION_RESULT_KILLING_BLOW then return end
        local rawSource = GetRawUnitName(sourceName)
        local rawTarget = GetRawUnitName(targetName)
        local myName = GetRawUnitName(GetUnitName("player"))
        if rawSource ~= myName and not AreUnitsEqual("player", sourceUnitId) then return end
        if rawTarget == myName or rawTarget == "" then return end
        self.ui:HandleDuelKill()
    end)
    EM:AddFilterForEvent(self.name.."_UNIVERSAL_KILL", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
end

function CritMarker:OnLoaded(_, addonName)
    if addonName ~= self.name then return end
    EM:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    self:InitSavedVars()
    self:CreateModules()
    self.settings:CreateMenu()
    self:RegisterEvents()
end

EM:RegisterForEvent(CritMarker.name, EVENT_ADD_ON_LOADED, function(...)
    CritMarker:OnLoaded(...)
end)

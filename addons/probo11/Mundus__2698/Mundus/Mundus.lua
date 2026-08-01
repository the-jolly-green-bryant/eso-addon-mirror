Mundus = {}
local ADDON_AUTHOR = "@probo11"
local ADDON_VERSION = "3.0"

local mundusIds = {13979, 13982, 13976, 13978, 13981, 13943, 13980, 13974, 13984, 13977, 13975, 13985, 13940}
local raidIds = {}

local mundusStones = {
    [1] = " "
}

Mundus.Name = "Mundus"

function Mundus:Initialize()
    self.Mundus = self.GetMundus()
    self.savedVariables = ZO_SavedVars:New("MundusSavedVariables", ADDON_VERSION, nil, {})
    self.CreateVar()
	--self.CheckData()
    EVENT_MANAGER:RegisterForEvent(Mundus.Name, EVENT_PLAYER_ACTIVATED, Mundus.CheckInstance)
    self.CreateSettingsWindow(mundusStones, ADDON_AUTHOR, ADDON_VERSION)
end

function Mundus.GetMundus()
    local numBuffs = GetNumBuffs("player")
    for i = 1, numBuffs do
        local buffName, _, _, _, _, _, _, _, _, _, id, _, _ = GetUnitBuffInfo("player", i)
        for j = 2, 14 do -- munduesStones length
            if id == mundusIds[j] then
                return id
            end
        end
    end
end

function Mundus.CheckInstance(event, player, zone)
    MundusIndicator:SetHidden(true)

    if (GetCurrentParticipatingRaidId() ~= 0 and raidIds[GetCurrentParticipatingRaidId()] ~= Mundus.Mundus and
        raidIds[GetCurrentParticipatingRaidId()] ~= " ") or
        (IsInCyrodiil("player") and Mundus.Mundus ~= Mundus.savedVariables.Cyro and Mundus.savedVariables.Cyro ~= " ") or
        (IsInImperialCity("player") and Mundus.Mundus ~= Mundus.savedVariables.IC and Mundus.savedVariables.IC ~= " ") or
        (IsUnitInDungeon("player") and GetCurrentParticipatingRaidId() == 0 and Mundus.Mundus ~=
            Mundus.savedVariables.PVE and Mundus.savedVariables.PVE ~= " ") then
        MundusIndicator:SetHidden(false)
    end
end

function Mundus.CreateVar()
    -- here check if it exists if not create else ignore
    if Mundus.savedVariables.BRP == nil then
        Mundus.savedVariables.BRP = " "
    end
    if Mundus.savedVariables.Cyro == nil then
        Mundus.savedVariables.Cyro = " "
    end
    if Mundus.savedVariables.IC == nil then
        Mundus.savedVariables.IC = " "
    end
    if Mundus.savedVariables.MA == nil then
        Mundus.savedVariables.MA = " "
    end
    if Mundus.savedVariables.PVE == nil then
        Mundus.savedVariables.PVE = " "
    end
    if Mundus.savedVariables.Trial_AA == nil then
        Mundus.savedVariables.Trial_AA = " "
    end
    if Mundus.savedVariables.Trial_AS == nil then
        Mundus.savedVariables.Trial_AS = " "
    end
    if Mundus.savedVariables.Trial_CR == nil then
        Mundus.savedVariables.Trial_CR = " "
    end
	if Mundus.savedVariables.Trial_DSR == nil then
        Mundus.savedVariables.Trial_DSR = " "
    end
    if Mundus.savedVariables.Trial_HOF == nil then
        Mundus.savedVariables.Trial_HOF = " "
    end
    if Mundus.savedVariables.Trial_KA == nil then
        Mundus.savedVariables.Trial_KA = " "
    end
    if Mundus.savedVariables.Trial_HRC == nil then
        Mundus.savedVariables.Trial_HRC = " "
    end
    if Mundus.savedVariables.Trial_MOL == nil then
        Mundus.savedVariables.Trial_MOL = " "
    end
    if Mundus.savedVariables.Trial_RG == nil then
        Mundus.savedVariables.Trial_RG = " "
    end
    if Mundus.savedVariables.Trial_SO == nil then
        Mundus.savedVariables.Trial_SO = " "
    end
    if Mundus.savedVariables.Trial_SS == nil then
        Mundus.savedVariables.Trial_SS = " "
    end
    if Mundus.savedVariables.VH == nil then
        Mundus.savedVariables.VH = " "
    end
    raidIds[1] = Mundus.savedVariables.Trial_HRC
    raidIds[2] = Mundus.savedVariables.Trial_AA
    raidIds[3] = Mundus.savedVariables.Trial_SO
    -- raidIds[4] = 
    raidIds[5] = Mundus.savedVariables.Trial_MOL
    raidIds[6] = Mundus.savedVariables.MA
    raidIds[7] = Mundus.savedVariables.Trial_HOF
    raidIds[8] = Mundus.savedVariables.Trial_AS
    raidIds[9] = Mundus.savedVariables.Trial_CR
    -- raidIds[10] = 
    raidIds[11] = Mundus.savedVariables.BRP
    raidIds[12] = Mundus.savedVariables.Trial_SS
    raidIds[13] = Mundus.savedVariables.Trial_KA
    raidIds[14] = Mundus.savedVariables.VH
    raidIds[15] = Mundus.savedVariables.Trial_RG
    raidIds[16] = Mundus.savedVariables.Trial_DSR
end

function Mundus.GetId(mundusName)
    if mundusName == " " then
        return " "
    end
    for i = 1, 14 do
        if mundusName == mundusStones[i] then

            return mundusIds[i - 1]
        end
    end
end

function Mundus.GetMundusName(mundusId)
    for i = 1, 14 do
        if mundusId == mundusIds[i] then
            return mundusStones[i + 1]
        end
    end
end

function Mundus.CheckData()
    d(GetUnitZoneIndex("player"), GetZoneId(GetUnitZoneIndex("player")))
    d(GetCurrentParticipatingRaidId(), GetRaidName(GetCurrentParticipatingRaidId()))
end

function Mundus.OnAddOnLoaded(event, addonName)
    if addonName == Mundus.Name then
        for _, abilityId in pairs(mundusIds) do
            local pos = string.find(GetAbilityName(abilityId), ":", 1)
            local cleanName = ZO_CachedStrFormat("<<C:1>>", string.sub(GetAbilityName(abilityId), pos + 2))
            mundusStones[#mundusStones + 1] = cleanName
        end
        Mundus:Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(Mundus.Name, EVENT_ADD_ON_LOADED, Mundus.OnAddOnLoaded)

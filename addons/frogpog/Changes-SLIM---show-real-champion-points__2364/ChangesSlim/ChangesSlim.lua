ChangesSlim = {}

local ChangesSlim = ChangesSlim

ChangesSlim.name = "ChangesSlim"
ChangesSlim.version = 1.7
ChangesSlim.displayName = "|cffffffChangesSlim SLIM - show real CP|r"

ChangesSlim.Defaults = {}

ChangesSlim.Defaults.showActualCP = true


ChangesSlim.SavedOrigCPStringFunction = GetLevelOrChampionPointsStringNoIcon
ChangesSlim.LOOPS = 10


function ChangesSlim:findThis(text)
    local parents = {};
    parents[1] = GuiRoot
    local newparents = {};
    local loops = 0;
    while loops < ChangesSlim.LOOPS do
        newparents = nil
        newparents = {}
        parentcount = 1
        loops = loops + 1;

        for _, x in ipairs(parents) do
            if x.GetChild then
                for i=1, x:GetNumChildren() do
                    local y = x:GetChild(i)
                    if y then
                        if y.GetChild then
                            newparents[parentcount] = y;
                            parentcount = parentcount + 1
                        end

                        if y.GetText and y:GetText():match(text) then
                            d ( y:GetName() )
                            local z = y
                            while z ~= nil do
                                z:SetAlpha(1)
                                z:SetHidden(false)
                                z = z:GetParent()
                            end
                        end
                    end
                end
            end
        end

        parents = nil
        parents = {}

        for i,x in ipairs(newparents) do
            parents[i] = x
        end
    end
end

local function hookIt()
    local mycpfunc = GetUnitChampionPoints

    if ChangesSlim.sv.showActualCP then
        function GetLevelOrChampionPointsStringNoIcon(level, championPoints)
            if championPoints and championPoints > 0 then
                return tostring(championPoints)
            elseif level and level > 0 then
                return tostring(level)
            else
                return ""
            end
        end
    else
        GetLevelOrChampionPointsStringNoIcon = ChangesSlim.SavedOrigCPStringFunction
        mycpfunc = GetUnitEffectiveChampionPoints
    end

    function ZO_GuildRosterManager:BuildMasterList()
        ZO_ClearNumericallyIndexedTable(self.masterList)
        local guildId = self.guildId
        local localPlayerIndex = GetPlayerGuildMemberIndex(guildId)
        local numGuildMembers = GetNumGuildMembers(guildId)
        for guildMemberIndex = 1, numGuildMembers do
            local displayName, note, rankIndex, status, secsSinceLogoff = GetGuildMemberInfo(guildId, guildMemberIndex)
            local online = (status ~= PLAYER_STATUS_OFFLINE)
            local rankId = GetGuildRankId(guildId, rankIndex)
            local isLocalPlayer = guildMemberIndex == localPlayerIndex
            local hasCharacter, rawCharacterName, zone, class, alliance, level, championPoints = GetGuildMemberCharacterInfo(guildId, guildMemberIndex)
            local data =  {
                index = guildMemberIndex,
                displayName = displayName,
                hasCharacter = hasCharacter,
                isLocalPlayer = isLocalPlayer,
                characterName = ZO_CachedStrFormat(SI_UNIT_NAME, rawCharacterName),
                gender = GetGenderFromNameDescriptor(rawCharacterName),
                level = level,
                championPoints = championPoints,
                class = class,
                formattedZone = ZO_CachedStrFormat(SI_ZONE_NAME, zone),
                alliance = alliance,
                formattedAllianceName = ZO_CachedStrFormat(SI_ALLIANCE_NAME, GetAllianceName(alliance)),
                note = note,
                rankIndex = rankIndex,
                rankId = rankId,
                type = SOCIAL_NAME_SEARCH,
                status = status,
            }
            ZO_SocialList_SetUpOnlineData(data, online, secsSinceLogoff)
            self.masterList[guildMemberIndex] = data
        end
    end

    function ZO_GroupList_Manager:BuildMasterList()
        ZO_ClearNumericallyIndexedTable(self.masterList)
        for i = 1, GetGroupSize() do
            local unitTag = GetGroupUnitTagByIndex(i)
            if unitTag then
                local selectedRole = GetGroupMemberSelectedRole(unitTag)
                local isDps = selectedRole == LFG_ROLE_DPS
                local isHeal = selectedRole == LFG_ROLE_HEAL
                local isTank = selectedRole == LFG_ROLE_TANK
                local rawCharacterName = GetRawUnitName(unitTag)
                local zoneName = ZO_CachedStrFormat(SI_ZONE_NAME, GetUnitZone(unitTag))
                local unitOnline = IsUnitOnline(unitTag)
                local displayName = GetUnitDisplayName(unitTag)
                local userFacingDisplayName = ZO_FormatUserFacingDisplayName(displayName)
                local status = unitOnline and PLAYER_STATUS_ONLINE or PLAYER_STATUS_OFFLINE
                self.masterList[i] =
                {
                    index = i,
                    unitTag = unitTag,
                    characterName = GetUnitName(unitTag),
                    rawCharacterName = rawCharacterName,
                    gender = GetGenderFromNameDescriptor(rawCharacterName),
                    formattedZone = zoneName,
                    class = GetUnitClassId(unitTag),
                    level = GetUnitLevel(unitTag),
                    championPoints = mycpfunc(unitTag),
                    leader = IsUnitGroupLeader(unitTag),
                    online = unitOnline,
                    isPlayer = AreUnitsEqual(unitTag, "player"),
                    isDps = isDps,
                    isHeal = isHeal,
                    isTank = isTank,
                    displayName = displayName,
                    status = status,
                    hasCharacter = true,
                    isGroup = true,
                    type = ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_SEARCH_TYPE_NAMES,
                }
            end
        end
    end
end


local function createSettings()
    local LAM = LibStub("LibAddonMenu-2.0")

    local settingsWindowData = {
        type = "panel",
        name = ChangesSlim.displayName,
        author = "|Jodynn & FROGPOG|r",
        version = tostring(ChangesSlim.version),
    }

    local settingsOptionsData = {

        {
            type = "checkbox",
            name = "Show Actual CP",
            tooltip = "Show CP player after cap",
            default = ChangesSlim.Defaults.showActualCP,
            getFunc = function() return ChangesSlim.sv.showActualCP end,
            setFunc = function(newValue)
                ChangesSlim.sv.showActualCP = newValue
                hookIt()
            end,
        },

    }

    local settingsOptionPanel = LAM:RegisterAddonPanel(ChangesSlim.name.."_LAM", settingsWindowData)
    LAM:RegisterOptionControls(ChangesSlim.name.."_LAM", settingsOptionsData)
end

function ChangesSlim:Initialize()
    ChangesSlim.sv = ZO_SavedVars:NewAccountWide("ChangesSlim_sv", 1, nil, ChangesSlim.Defaults)

    createSettings()

    hookIt()

end

local function OnAddonLoaded(event, addonName)
    if addonName ~= ChangesSlim.name then return end
    ChangesSlim:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ChangesSlim.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

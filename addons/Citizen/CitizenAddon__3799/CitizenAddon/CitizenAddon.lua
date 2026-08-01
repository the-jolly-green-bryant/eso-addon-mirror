CitizenAddon = {
    name = "CitizenAddon",

    player = {
        displayName = "",
        groupUnitTag = "",
        unitId = 0,
        classId = 0,
    },
    group = { --It will exclude offline members and companions
        size = 1, --GetGroupSize() returns 0 if you are not in a group, this will return 1 if you are alone
        unitDisplayName = {},
        unitIdToUnitTag = {},
        deadMembers = 0,
    },

    notifier = {
        banner = {
            left = 0,
            top = 0,
        },
        alert = {
            left = 0,
            top = 0,
        },
    },

    log = "",

    generalOptions = {
        addonManager = {
            activeAddonsCounter = false,
        },
        marker = {
            OsiIconSize = 84,
            selectedIconTexture = 1,
            configString = "",
        },
        realTimeClock = {
            active = false,
            left = 0,
            top = 0,
        },
    },

    combatOptions = {
        amIBlocking = {
            active = false,
            left = 0,
            top = 0,
        },
        resistanceMeter = {
            active = false,
            left = 0,
            top = 0,
        },
        nearbyMembers = {
            active = false,
            left = 0,
            top = 0,
            range = 20,
            DdOnly = false,
        },
    },

    PVEcontent = {
        CR = {
            siroriaFlareOsi = false,
            siroriaFlareOsiIconSize = 128,

            galenweHoarfrostOsi = false,
            galenweHoarfrostOsiIconSize = 128,
        },
        BRP = {
            waveIcons = {
                active = true,
                OsiIconSize = 128,
                duration = 7000,
            }
        },
        SS = {
            bossFlyTracker = false,
            lokke = {
                beamTimer = false,
                beamOsi = false,
                soloHeal = false,
                beamOsiIconSize = 128,
            },
            nahvi = {
                statueStoneFist = false,
                portalWipeTimer = false,
                portalEntranceTimer = false,
                portalInterrupt = false,
            }
        },
        RG = {
            oax = {
                poisonOsi = false,
                poisonOsiIconSize = 128,
            },
            bahsei = {
                deathTouchOsi = false,
                deathTouchOsiIconSize = 128,
                bleedTracker = false,
                bleedOsi = false,
                bleedOsiIconSize = 128,
                offTankOnly = false,
                offTankDisplayName = "",
                moulderingTaint = false,
                moulderingTaintLeft = 0,
                moulderingTaintTop = 0,
            },
        },
        CA = {
            varallion = {
                mindLinkOsi = true,
                mindLinkOsiIconSize = 128,
            },
        },
        DSR = {
            trash = {
                brewMasterPotionOsi = false,
                brewMasterPotionOsiIconSize = 164,
            },
            lyAndTu = {
                iceAndFireBrandOsi = false,
                iceAndFireBrandOsiIconSize = 128,
            },
            reef = {
                acidReflux = false,
            },
            taleria = {
                clockNumbersOsi = false,
                clockNumbersOsiIconSize = 84,
                behemothHack = false,
                behemothCrush = false,
                sirenLureOfTheSea = false,
                seaBoilerAspectOfTerror = false,
            }
        },
        SE = {
            yaseyla = {
                archerTrueShot = false,
            },
            archAndChimera = {
                crystalNumbersOSI = false,
                crystalNumbersOsiIconSize = 128
            },
            ansuul = {
                banishTracker = false,
            },
        },
    },
}
CitizenFunctions = {} --For general public functions so they don't get saved in SavedVariables
local fragments = {}
local oldZoneId = nil

local function Unregistor()
    EVENT_MANAGER:UnregisterForEvent(CitizenAddon.name .."InCombatInCR", EVENT_PLAYER_COMBAT_STATE)

    EVENT_MANAGER:UnregisterForEvent(CitizenAddon.name .."BrpPortalSpawned", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenAddon.name .."BrpAnnouncement", EVENT_DISPLAY_ANNOUNCEMENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenAddon.name .."InCombatInBRP", EVENT_PLAYER_COMBAT_STATE)

    EVENT_MANAGER:UnregisterForEvent(CitizenAddon.name .."InCombatInSS", EVENT_PLAYER_COMBAT_STATE)

    EVENT_MANAGER:UnregisterForEvent(CitizenAddon.name .."InCombatInRG", EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(CitizenAddon.name .."BossChangedInRG", EVENT_BOSSES_CHANGED)

    EVENT_MANAGER:UnregisterForEvent(CitizenAddon.name .."InCombatInCA", EVENT_PLAYER_COMBAT_STATE)

    EVENT_MANAGER:UnregisterForEvent(CitizenAddon.name .."InCombatInSWR", EVENT_PLAYER_COMBAT_STATE)

    EVENT_MANAGER:UnregisterForEvent(CitizenAddon.name .."InCombatInDSR", EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(CitizenAddon.name .."BossChangedInDSR", EVENT_BOSSES_CHANGED)

    EVENT_MANAGER:UnregisterForEvent(CitizenAddon.name .."InCombatInSE", EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(CitizenAddon.name .."BossChangedInSE", EVENT_BOSSES_CHANGED)

    for _, IconObject in pairs(CitizenMarker.mechanicIcons) do
        OSI.DiscardPositionIcon(IconObject)
    end
    for _, IconObject in pairs(CitizenBRP.waveIcons) do
        OSI.DiscardPositionIcon(IconObject)
    end
end

---CitizenAddon.name .."PlayerAlive", EVENT_PLAYER_ALIVE
local function PlayerResurrect()
    CitizenAddon.group.deadMembers = CitizenAddon.group.deadMembers - 1
end
---CitizenAddon.name .."PlayerDead", EVENT_PLAYER_DEAD
local function PlayerDied()
    CitizenAddon.group.deadMembers = CitizenAddon.group.deadMembers + 1
end
--Group death status changed
---CitizenAddon.name .."DeathStatus", EVENT_UNIT_DEATH_STATE_CHANGED
    --UNIT_TAG_PREFIX, 'group'
local function DeathStatus(_, unitTag, isDead)
    if isDead then
        CitizenAddon.group.deadMembers = CitizenAddon.group.deadMembers + 1
    elseif not isDead then
        if unitTag == CitizenAddon.player.groupUnitTag then
            return
        end
        CitizenAddon.group.deadMembers = CitizenAddon.group.deadMembers - 1
    end
end
--Check dead players when addon activated
local function DeathUpdate()
    CitizenAddon.group.deadMembers = 0

    if CitizenAddon.group.size<=1 then
        if IsUnitDead('player') then
            CitizenAddon.group.deadMembers = CitizenAddon.group.deadMembers + 1
        end
    else
        for i=1, CitizenAddon.group.size, 1 do
            if IsUnitDead(GetGroupUnitTagByIndex(i)) then
                CitizenAddon.group.deadMembers = CitizenAddon.group.deadMembers + 1
            end
        end
    end
end

--Get Group unit IDs
---CitizenAddon.name .."GetGroupUnitId", EVENT_EFFECT_CHANGED
    --UNIT_TAG_PREFIX, 'group'
    -- OR
    --UNIT_TAG, 'player'
local function GroupUnitIdFinder(_, changeType, _, _, unitTag, _, _, _, _, _, _, _, _, _, unitId, _, _)
    if changeType == EFFECT_RESULT_GAINED then
        if IsUnitPlayer(unitTag) then
            if CitizenAddon.group.unitIdToUnitTag[unitId] == nil then
                CitizenAddon.group.unitIdToUnitTag[unitId] = unitTag
                if unitTag == CitizenAddon.player.groupUnitTag then
                    CitizenAddon.player.unitId = unitId
                end
            end
        end
    end
    if #CitizenAddon.group.unitIdToUnitTag >= CitizenAddon.group.size then
        EVENT_MANAGER:UnregisterForEvent(CitizenAddon.name .."GetGroupUnitId", EVENT_EFFECT_CHANGED)
    end
end
--Update group information
---CitizenAddon.name .."GroupUpdated", EVENT_GROUP_UPDATE
---CitizenAddon.name .."GroupMemberJoined", EVENT_GROUP_MEMBER_JOINED
---CitizenAddon.name .."GroupMemberLeft", EVENT_GROUP_MEMBER_LEFT
---CitizenAddon.name .."GroupMemberConnectionStatusChanged", EVENT_GROUP_MEMBER_CONNECTED_STATUS
local function GroupUpdate()
    EVENT_MANAGER:UnregisterForEvent(CitizenAddon.name .."PlayerAlive", EVENT_PLAYER_ALIVE)
    EVENT_MANAGER:UnregisterForEvent(CitizenAddon.name .."PlayerDead", EVENT_PLAYER_DEAD)
    EVENT_MANAGER:UnregisterForEvent(CitizenAddon.name .."DeathStatus", EVENT_UNIT_DEATH_STATE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(CitizenAddon.name .."GetGroupUnitId", EVENT_EFFECT_CHANGED)
    CitizenAddon.group.unitDisplayName = {}
    CitizenAddon.group.unitIdToUnitTag = {}
    CitizenAddon.group.size = 0
    CitizenAddon.player.groupUnitTag = ""
    CitizenAddon.player.unitId = 0

    EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."PlayerAlive", EVENT_PLAYER_ALIVE, PlayerResurrect)

    if GetGroupSize()<=1 then
        CitizenAddon.group.size = 1
        EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."PlayerDead", EVENT_PLAYER_DEAD, PlayerDied)

        EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."GetGroupUnitId", EVENT_EFFECT_CHANGED, GroupUnitIdFinder)--FILTERS
            EVENT_MANAGER:AddFilterForEvent(CitizenAddon.name .."GetGroupUnitId", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, 'player')
        --

        if CitizenAddon.combatOptions.nearbyMembers.active then
            HUD_SCENE:RemoveFragment(fragments.CitizenNM)
            HUD_UI_SCENE:RemoveFragment(fragments.CitizenNM)

            EVENT_MANAGER:UnregisterForUpdate(CitizenAddon.name .."NearbyMembers")
        end
    else
        CitizenAddon.player.groupUnitTag = GetGroupUnitTagByIndex(GetGroupIndexByUnitTag('player'))

        EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."DeathStatus", EVENT_UNIT_DEATH_STATE_CHANGED, DeathStatus)--FILTERS
            EVENT_MANAGER:AddFilterForEvent(CitizenAddon.name .."DeathStatus", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, 'group')
        --

        for i=1, GetGroupSize(), 1 do
            if IsUnitPlayer(GetGroupUnitTagByIndex(i)) then
                if IsUnitOnline(GetGroupUnitTagByIndex(i)) then
                    CitizenAddon.group.size = CitizenAddon.group.size + 1
                end
                CitizenAddon.group.unitDisplayName[i] = GetUnitDisplayName(GetGroupUnitTagByIndex(i))
            end
        end
        EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."GetGroupUnitId", EVENT_EFFECT_CHANGED, GroupUnitIdFinder)--FILTERS
            EVENT_MANAGER:AddFilterForEvent(CitizenAddon.name .."GetGroupUnitId", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, 'group')
        --

        if CitizenAddon.combatOptions.nearbyMembers.active then
            HUD_SCENE:AddFragment(fragments.CitizenNM)
            HUD_UI_SCENE:AddFragment(fragments.CitizenNM)

            EVENT_MANAGER:UnregisterForUpdate(CitizenAddon.name .."NearbyMembers")
            EVENT_MANAGER:RegisterForUpdate(CitizenAddon.name .."NearbyMembers", 350, CitizenNearbyMembers.Refresh)
        end

        CitizenAddonMenu.UpdateTheOption(CITIZEN_RG_BAHSEI_OFF_TANK_ID, CitizenAddon.group.unitDisplayName)
    end
end

--Player activated
local function OnPlayerActivated(_, _)
    local zoneId, _, _, _ = GetUnitRawWorldPosition('player')

    CitizenMarker.PlayerActivated()

    if zoneId == oldZoneId then
        return
    else
        oldZoneId = zoneId
        Unregistor()

        if GetCurrentZoneDungeonDifficulty() == 2 then --DUNGEON_DIFFICULTY_VETERAN
            if zoneId == 1051 then --Cloudrest
                if CitizenAddon.PVEcontent.CR.siroriaFlareOsi or
                CitizenAddon.PVEcontent.CR.galenweHoarfrostOsi then
                    EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."InCombatInCR", EVENT_PLAYER_COMBAT_STATE, CitizenCR.CombatState)
                end

            elseif zoneId == 1082 then --Blackrose Prison
                if CitizenAddon.PVEcontent.BRP.waveIcons.active then
                    EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."BrpPortalSpawned", EVENT_COMBAT_EVENT, CitizenBRP.PortalSpawned)--FILTERS
                        EVENT_MANAGER:AddFilterForEvent(CitizenAddon.name .."BrpPortalSpawned", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
                        EVENT_MANAGER:AddFilterForEvent(CitizenAddon.name .."BrpPortalSpawned", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 114578)
                    --
                    EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."BrpAnnouncement", EVENT_DISPLAY_ANNOUNCEMENT, CitizenBRP.Announcement)
                    CitizenBRP.CombatState(nil, false)
                    EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."InCombatInBRP", EVENT_PLAYER_COMBAT_STATE, CitizenBRP.CombatState)
                end

            elseif zoneId == 1121 then --Sunspire
                if CitizenAddon.PVEcontent.SS.bossFlyTracker or
                CitizenAddon.PVEcontent.SS.lokke.beamOsi or
                CitizenAddon.PVEcontent.SS.lokke.beamTimer or
                CitizenAddon.PVEcontent.SS.nahvi.portalEntranceTimer or
                CitizenAddon.PVEcontent.SS.nahvi.portalInterrupt or
                CitizenAddon.PVEcontent.SS.nahvi.portalWipeTimer or
                CitizenAddon.PVEcontent.SS.nahvi.statueStoneFist then
                    EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."InCombatInSS", EVENT_PLAYER_COMBAT_STATE, CitizenSS.CombatState)
                end

            elseif zoneId == 1263 then --Rockgrove
                if CitizenAddon.PVEcontent.RG.oax.poisonOsi or
                CitizenAddon.PVEcontent.RG.bahsei.bleedOsi or
                CitizenAddon.PVEcontent.RG.bahsei.bleedTracker or
                CitizenAddon.PVEcontent.RG.bahsei.deathTouchOsi then
                    EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."InCombatInRG", EVENT_PLAYER_COMBAT_STATE, CitizenRG.CombatState)
                end
                if CitizenAddon.PVEcontent.RG.bahsei.moulderingTaint then
                    EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."BossChangedInRG", EVENT_BOSSES_CHANGED, CitizenRG.BossChanged)
                end

            elseif zoneId == 1301 then --Coral Aerie
                if CitizenAddon.PVEcontent.CA.varallion.mindLinkOsi then
                    EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."InCombatInCA", EVENT_PLAYER_COMBAT_STATE, CitizenCA.CombatState)
                end

            -- elseif zoneId == 1302 then --Shipwright's Regret

            elseif zoneId == 1344 then --Dreadsail Reef
                if CitizenAddon.PVEcontent.DSR.trash.brewMasterPotionOsi or
                CitizenAddon.PVEcontent.DSR.lyAndTu.iceAndFireBrandOsi or
                CitizenAddon.PVEcontent.DSR.reef.acidReflux or
                CitizenAddon.PVEcontent.DSR.taleria.behemothCrush or
                CitizenAddon.PVEcontent.DSR.taleria.behemothHack or
                CitizenAddon.PVEcontent.DSR.taleria.seaBoilerAspectOfTerror or
                CitizenAddon.PVEcontent.DSR.taleria.sirenLureOfTheSea then
                    EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."InCombatInDSR", EVENT_PLAYER_COMBAT_STATE, CitizenDSR.CombatState)
                end
                if CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsi then
                    EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."BossChangedInDSR", EVENT_BOSSES_CHANGED, CitizenDSR.BossChanged)
                end

            elseif zoneId == 1427 then --Sanity's Edge
                if CitizenAddon.PVEcontent.SE.yaseyla.archerTrueShot or
                CitizenAddon.PVEcontent.SE.ansuul.banishTracker then
                    EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."InCombatInSE", EVENT_PLAYER_COMBAT_STATE, CitizenSE.CombatState)
                end
                if CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOSI then
                    EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."BossChangedInSE", EVENT_BOSSES_CHANGED, CitizenSE.BossChanged)
                end
            end

        else --DUNGEON_DIFFICULTY_NORMAL
            if zoneId == 1082 then --Blackrose Prison
                if CitizenAddon.PVEcontent.BRP.waveIcons.active then
                    EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."BrpPortalSpawned", EVENT_COMBAT_EVENT, CitizenBRP.PortalSpawned)--FILTERS
                        EVENT_MANAGER:AddFilterForEvent(CitizenAddon.name .."BrpPortalSpawned", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
                        EVENT_MANAGER:AddFilterForEvent(CitizenAddon.name .."BrpPortalSpawned", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 114578)
                    --
                    EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."BrpAnnouncement", EVENT_DISPLAY_ANNOUNCEMENT, CitizenBRP.Announcement)
                    CitizenBRP.CombatState(nil, false)
                    EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."InCombatInBRP", EVENT_PLAYER_COMBAT_STATE, CitizenBRP.CombatState)
                end
            end
        end
    end
end

--Migrate saved vars version 1 to 2
local function MigrateOldSettings()
    local oldVars = CitizenAddonSavedVariables["Default"][GetUnitDisplayName('player')]["$AccountWide"]
    CitizenAddon.notifier = oldVars.notifier
    CitizenAddon.combatOptions.resistanceMeter = oldVars.resistanceMeter
    CitizenAddon.combatOptions.amIBlocking = oldVars.amIBlocking
    CitizenAddon.combatOptions.nearbyMembers = oldVars.nearbyMembers
    CitizenAddon.generalOptions.addonManager = oldVars.addonManager
    CitizenAddon.generalOptions.marker = oldVars.marker
    CitizenAddon.generalOptions.realTimeClock = oldVars.realTimeClock
    CitizenAddon.PVEcontent.CR = oldVars.CR
    CitizenAddon.PVEcontent.BRP = oldVars.BRP
    CitizenAddon.PVEcontent.SS = oldVars.SS
    CitizenAddon.PVEcontent.RG = oldVars.RG
    CitizenAddon.PVEcontent.CA = oldVars.CA
    CitizenAddon.PVEcontent.DSR = oldVars.DSR
    CitizenAddon.PVEcontent.SE = oldVars.SE
    CitizenAddon = ZO_SavedVars:NewAccountWide("CitizenAddonSavedVariables", 2, nil, CitizenAddon, nil)
    CitizenAddon.log = "Migrated saved vars version 1 to 2"
end

--Initialize addon
local function Initialize()
    if CitizenAddonSavedVariables~=nil and CitizenAddonSavedVariables["Default"][GetUnitDisplayName('player')]["$AccountWide"].version==1 then
        MigrateOldSettings()
    else
        CitizenAddon = ZO_SavedVars:NewAccountWide("CitizenAddonSavedVariables", 2, nil, CitizenAddon, nil)
    end
    CitizenMarker.savedPositions = ZO_SavedVars:NewAccountWide("CitizenMarkerSavedVariables", 1, nil, nil, nil)

    CitizenAddonMenu.AddonMenu()

    CitizenBanner:ClearAnchors()
    CitizenBanner:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CitizenAddon.notifier.banner.left, CitizenAddon.notifier.banner.top)
    CitizenAlert:ClearAnchors()
    CitizenAlert:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CitizenAddon.notifier.alert.left, CitizenAddon.notifier.alert.top)

    if CitizenAddon.generalOptions.addonManager.activeAddonsCounter then
        SCENE_MANAGER:GetScene("gameMenuInGame"):RegisterCallback("StateChange", CitizenAddonManager.MenuScene)
    end
    if CitizenAddon.generalOptions.realTimeClock.active then
        CitizenClock.Start()
        fragments.CitizenRTC = ZO_SimpleSceneFragment:New(CitizenRTC)

        HUD_SCENE:AddFragment(fragments.CitizenRTC)
        HUD_UI_SCENE:AddFragment(fragments.CitizenRTC)
    end

    if CitizenAddon.combatOptions.amIBlocking.active then
        CitizenAmIBlocking.Start()
    end
    if CitizenAddon.combatOptions.resistanceMeter.active then
        CitizenResistanceMeter.Start()
        fragments.CitizenRM = ZO_SimpleSceneFragment:New(CitizenRM)

        HUD_SCENE:AddFragment(fragments.CitizenRM)
        HUD_UI_SCENE:AddFragment(fragments.CitizenRM)
    end
    if CitizenAddon.combatOptions.nearbyMembers.active then
        CitizenNearbyMembers.Start()
        fragments.CitizenNM = ZO_SimpleSceneFragment:New(CitizenNM)

        CitizenNM_Range:SetText(CitizenAddon.combatOptions.nearbyMembers.range .."m")
        CitizenNM_DD:SetHidden(not CitizenAddon.combatOptions.nearbyMembers.DdOnly)
    end

    CitizenAddon.player.classId = GetUnitClassId('player')

    CitizenAddon.player.displayName = GetUnitDisplayName('player')
    GroupUpdate()
    DeathUpdate()
    EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."GroupUpdated", EVENT_GROUP_UPDATE, GroupUpdate)
    EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."GroupMemberJoined", EVENT_GROUP_MEMBER_JOINED, GroupUpdate)
    EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."GroupMemberLeft", EVENT_GROUP_MEMBER_LEFT, GroupUpdate)
    EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."GroupMemberConnectionStatusChanged", EVENT_GROUP_MEMBER_CONNECTED_STATUS, GroupUpdate)

	EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

--Command Handler
local function CommandHandler(args)
    args = args:gsub("%s+", "")

    if args == "m" then
        LibAddonMenu2:OpenToPanel(CitizenAddonMenu.PanelID)
    elseif args == "p" then
        CitizenMarker.PlaceAtMe()
    elseif args == "r" then
        CitizenMarker.RemoveNearestMarker()
    elseif args == "pos" then
        local zoneId, x, y, z = GetUnitRawWorldPosition('player')
        d("|cffffff[CITI]|r Your position: |cffffffzoneID|r:".. zoneId ..", |cffffffx|r:".. x ..", |cffffffy|r:".. y ..", |cffffffz|r:".. z)
    elseif args == "map" then
        local x, z, h, isShown = GetMapPlayerPosition('player')
        d("|cffffff[CITI]|r Your position: |cffffffx|r:".. x ..", |cffffffz|r:".. z ..", |cffffffh|r:".. h ..", |cffffffisShown|r:".. tostring(isShown))
    elseif args == "gp" then
        d("|cffffff[CITI]|r Group Size: ".. CitizenAddon.group.size ..", Amount of dead members: ".. CitizenAddon.group.deadMembers)

    else
        d("|cffffff[CITI]|r Command list:")
        d("|cffffff/citim|r - Open menu")
        d("|cffffff/citi p|r - Place marker at your position")
        d("|cffffff/citi r|r - Remove nearest marker to your position")
        d("|cffffff/citi pos|r - Print player's position in chat")
    end
end

--Addon loaded 
local function OnAddonLoaded(_, addonName)
	if addonName == CitizenAddon.name then
        Initialize()

        SLASH_COMMANDS["/citi"] = CommandHandler

        EVENT_MANAGER:UnregisterForEvent(CitizenAddon.name .."AddonLoad", EVENT_ADD_ON_LOADED)
    end
end

-------------------------
--Functions and Strings--
-------------------------
--Add Icon To String
---@param string string
---@param icon string
function CitizenFunctions.AddIconToString(string, icon)
    if icon ~= nil then
        if type(icon) == "number" then
            icon = GetAbilityIcon(icon)
        end
        local iconStr = zo_strformat("|t<<2>>:<<2>>:<<1>>|t", icon, 32)
        return zo_strformat("<<1>> <<2>>", iconStr, string)
    else
        return string
    end
end

--Check if item exist in table
---@param table table
---@param item any
function CitizenFunctions.TableContains(table, item)
    for _, v in pairs(table) do
        if v == item then
            return true
        end
    end
    return false
end

--Hash table remover
---@param table table
---@param key any
function CitizenFunctions.RemoveKey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end

--Table Spliter
---@param table table
---@param first integer
---@param last integer
function CitizenFunctions.TableSpliter(table, first, last)
    local sub = {}
    for i=first, last, 1 do
        sub[#sub+1] = table[i]
    end
    return sub
end

--Strings that will get added inside the game
local strings = {
    CITIZEN_ADDON_CREDIT_TEXT = "This was my personal Add-on previously made for personal use only, some functions are inspired by other Add-ons or they are completely copy-paste of other Add-ons due to my habit of original Add-on UI or lack of need to change anything in UI, all credits are written in the .txt file inside the Add-on folder.\nA shoutout thank to Odylon and Codes for their Add-ons and functions"
}
for id, val in pairs(strings) do
    ZO_CreateStringId(id, val)
    SafeAddVersion(id, 1)
end

EVENT_MANAGER:RegisterForEvent(CitizenAddon.name .."AddonLoad", EVENT_ADD_ON_LOADED, OnAddonLoaded)
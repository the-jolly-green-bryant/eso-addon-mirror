local LAM2 = LibAddonMenu2

--===================================--
-- Create Tables used in the addon --
--===================================--
local PvPRanks      = ZO_Object:New()
local ADDON_NAME    = "PvPRanks"
local CODE_VERSION  = 3.01
local ROW_HEIGHT    = 30
local ESO_STATS_LOADED = false

local ASSAULT_SKILL_LINE_INDEX   = 1
local SUPPORT_SKILL_LINE_INDEX   = 2
local MAX_SKILL_LINE_RANK        = 10

--=====================================================--
--======= DEBUG =========--
--=====================================================--
local DEBUG_MODE = false

local function debugMsg(msg, tableItem)
    if not DEBUG_MODE then return end
    if not PVP_RANKS_DEBUG_TABLE then PVP_RANKS_DEBUG_TABLE = {} end
    
    if msg and msg ~= "" then
        d(msg)
        table.insert(PVP_RANKS_DEBUG_TABLE, msg)
    end
    
    if tableItem then
        table.insert(PVP_RANKS_DEBUG_TABLE, tableItem)
    end
end
--=====================================================--

function PvPRanks:New()
    local obj = ZO_Object.New(self)
    local mt = getmetatable(obj)
    mt.__index = self
    obj.name    = ADDON_NAME
    obj.version = CODE_VERSION
    obj.savedVarVersion = 2.0 
    obj.rankInfo = {}
    obj.skillUnlocksByRank = {}
    obj.sv = {}
    obj.colors = {
        red         = "|cFF0000",
        darkOrange  = "|cFFA500",
        yellow      = "|cFFFF00",
    }
    return obj
end

function PvPRanks:Initialize()
    self.playerRank             = GetUnitAvARank("player")
    self.playerGender           = GetUnitGender("player")
    
    local defaultSavedVars = {
        ["RANK_HIGHLIGHT_COLOR"] = {1, 0, 0, 1},
        ["VET_TRACKER_COLOR"]    = {1, 0.8, 0, 1} -- Default golden tint for Veterancy Tracker
    }
    self.sv = ZO_SavedVars:New("PvPRanksSavedVars", self.savedVarVersion, nil, defaultSavedVars, GetWorldName())
    
    self.scrollList = self:CreateScrollList()
    
    self:InitializeRankInfo()
    self:InitializeSkillUnlocksByRank()
    self:UpdateRankInfoWithSkillUnlocks()
    self:UpdateScrollList()
end

--=====================================================--
--======= Modern Veterancy API Tracker Helper =========--
--=====================================================--
local function GetAvAVeterancyString()
    local trackType = REWARD_TRACK_TYPE_AVA_VETERANCY
    local trackId = GetActiveReferenceTrackIdsForRewardTrackType(trackType)
    if not trackId then return "Veterancy: Rank 0" end

    local trackIndex = GetReferenceTrackIndex(trackType, trackId)
    if not trackIndex then return "Veterancy: Rank 0" end

    local _, currentRank, progressToNextRank = GetInfoForRewardTrack(trackType, trackIndex)
    local rewardTrackId = GetRewardTrackIdFromReferenceTrackId(trackType, trackId)
    local totalNeeded = GetTotalProgressAtRewardTrackTier(rewardTrackId, currentRank) or 0

    if totalNeeded > 0 then
        return string.format("Veterancy: Rank %d (%s / %s)", 
            currentRank, 
            ZO_CommaDelimitNumber(progressToNextRank), 
            ZO_CommaDelimitNumber(totalNeeded)
        )
    else
        return string.format("Veterancy: Rank %d", currentRank)
    end
end

--=====================================================--
--======= Initialize RankInfo & Skill Unlocks =========--
--=====================================================--
function PvPRanks:InitializeRankInfo()
    local MAX_AVA_RANK          = 50
    local currentRankPoints     = 0
    self.rankInfo               = {}
    
    for rank=0, MAX_AVA_RANK do
        local subRankStartsAt, nextSubRankAt, rankStartsAt, nextRankAt  = GetAvARankProgress(currentRankPoints)
        local rankEndsAt = rankStartsAt ~= nextRankAt and nextRankAt - 1 or nil
        
        currentRankPoints = nextRankAt+1
        
        local rankName  = zo_strformat(SI_STAT_RANK_NAME_FORMAT, GetAvARankName(self.playerGender, rank))
        local rankIcon  = GetAvARankIcon(rank) 
        local data      = {["rank"] = rank, ["startsAt"] = rankStartsAt, ["endsAt"] = rankEndsAt, ["rankName"] = rankName, ["rankIcon"] = rankIcon}
        
        table.insert(self.rankInfo, data)
    end
end

function PvPRanks:InitializeSkillUnlocksByRank()
    if GetAssignedCampaignId() == 0 then return end
    
    local skillUnlocksByRank = self.skillUnlocksByRank
    if next(skillUnlocksByRank) ~= nil then return end
    
    for skillLineRank = 1, MAX_SKILL_LINE_RANK do
        local startsAt, nextRankStartsAt, endsAt
        
        if skillLineRank == 10 then
            local _, nextRankExtents = GetSkillLineRankXPExtents(SKILL_TYPE_AVA, ASSAULT_SKILL_LINE_INDEX, skillLineRank-1)
            startsAt = nextRankExtents
        else
            startsAt, nextRankStartsAt = GetSkillLineRankXPExtents(SKILL_TYPE_AVA, ASSAULT_SKILL_LINE_INDEX, skillLineRank)
            if nextRankStartsAt ~= nil then
                endsAt = nextRankStartsAt - 1
            else 
                return
            end
        end

        skillUnlocksByRank[skillLineRank] = {rankUnlocked = skillLineRank,  startsAt=startsAt, endsAt=endsAt, 
            skillsUnlocked = {
                [ASSAULT_SKILL_LINE_INDEX] = {},
                [SUPPORT_SKILL_LINE_INDEX] = {},
            },
        }
    end
    
    for skillLineIndex = 1, 2 do
        if SKILLS_DATA_MANAGER then
            local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(SKILL_TYPE_AVA, skillLineIndex)
            if skillLineData then
                local numSkills = type(skillLineData.GetNumSkills) == "function" and skillLineData:GetNumSkills() or 0
                for abilityIndex = 1, numSkills do
                    local skillData = skillLineData:GetSkillDataByIndex(abilityIndex)
                    if skillData then
                        local skillLineRank = type(skillData.GetUnlockLineRank) == "function" and skillData:GetUnlockLineRank() or 0
                        
                        local isPassive = false
                        if type(skillData.IsPassive) == "function" then
                            isPassive = skillData:IsPassive()
                        elseif type(skillData.IsSkillPassive) == "function" then
                            isPassive = skillData:IsSkillPassive()
                        end
                        
                        local skillInfo = {
                            skillName       = type(skillData.GetFormattedName) == "function" and skillData:GetFormattedName() or "Unknown",
                            iconPath        = type(skillData.GetIcon) == "function" and skillData:GetIcon() or "",
                            earnedAtRank    = skillLineRank,
                            isPassive       = isPassive,
                        }
                        
                        if skillLineRank > 0 and skillUnlocksByRank[skillLineRank] then
                            if not skillUnlocksByRank[skillLineRank].skillsUnlocked[skillLineIndex] then
                                skillUnlocksByRank[skillLineRank].skillsUnlocked[skillLineIndex] = {}
                            end
                            table.insert(skillUnlocksByRank[skillLineRank].skillsUnlocked[skillLineIndex], skillInfo)
                        end
                    end
                end
            end
        else
            local numAbilities = GetNumSkillAbilities(SKILL_TYPE_AVA, skillLineIndex)
            for abilityIndex = 1, numAbilities do
                local name, icon, skillLineRank, isPassive = GetSkillAbilityInfo(SKILL_TYPE_AVA, skillLineIndex, abilityIndex)
                
                local skillInfo = {
                    skillName       = name,
                    iconPath        = icon,
                    earnedAtRank    = skillLineRank,
                    isPassive       = isPassive,
                }
                if skillLineRank and skillUnlocksByRank[skillLineRank] then
                    if not skillUnlocksByRank[skillLineRank].skillsUnlocked[skillLineIndex] then
                        skillUnlocksByRank[skillLineRank].skillsUnlocked[skillLineIndex] = {}
                    end
                    table.insert(skillUnlocksByRank[skillLineRank].skillsUnlocked[skillLineIndex], skillInfo)
                end
            end
        end
    end
end

function PvPRanks:UpdateRankInfoWithSkillUnlocks()
    local rankInfo              = self.rankInfo
    local skillUnlocksByRank    = self.skillUnlocksByRank
    
    if next(skillUnlocksByRank) == nil then return end
    
    local function GetSkillRankUnlocked(startAp, endAp)
        for skillLineRank = 1, MAX_SKILL_LINE_RANK do
            local skillLineStartsAt = skillUnlocksByRank[skillLineRank].startsAt
            if skillLineStartsAt >= startAp and (not endAp or skillLineStartsAt <= endAp) then
                return skillLineRank
            end
        end
    end
    
    for rank, rankData in ipairs(rankInfo) do
        local unlockedSkillRank = GetSkillRankUnlocked(rankData.startsAt, rankData.endsAt)
        rankData.unlocks = skillUnlocksByRank[unlockedSkillRank]
    end
end

--=====================================================--
--======= ScrollList Functions =========--
--=====================================================--
function PvPRanks:UpdateScrollList()
    local rankInfo      = self.rankInfo
    local scrollList    = self.scrollList
    
    ZO_ScrollList_Clear(scrollList)
    local entryList = ZO_ScrollList_GetDataList(scrollList)
    
    for rank=1, #rankInfo do
        local entry = ZO_ScrollList_CreateDataEntry(1, rankInfo[rank])
        table.insert(entryList, entry)
    end
    
    ZO_ScrollList_Commit(scrollList)
end

function PvPRanks:CreateScrollList()
    local tlw = WINDOW_MANAGER:CreateTopLevelWindow("PvPRanks") 
    tlw:SetDimensions(275, 500)
    tlw:SetHidden(true)
    tlw:SetMouseEnabled(true)
    tlw:SetMovable(false)
    
    if ESO_STATS_LOADED then
        local esoStatsBtn = GetControl("EsoStatsToggleButton")
        tlw:ClearAnchors()
        tlw:SetAnchor(TOPLEFT, esoStatsBtn, BOTTOMLEFT, -5, 0)
        tlw:SetDimensions(275, 400)
    else
        tlw:SetAnchor(TOPLEFT, ZO_CampaignOverviewCategoriesContainer1, BOTTOMLEFT, 15, 0)
    end
    
    -- NEW: Dynamic AvA Veterancy Status Label
    local vetHeader = WINDOW_MANAGER:CreateControl(nil, tlw, CT_LABEL)
    vetHeader:SetFont("ZoFontWinH4")
    vetHeader:SetColor(unpack(self.sv["VET_TRACKER_COLOR"])) -- Uses user's saved color
    vetHeader:SetAnchor(TOPLEFT, tlw, TOPLEFT, 10, 10)
    self.vetHeader = vetHeader
    
    tlw:SetHandler("OnShow", function()
        self.playerRank = GetUnitAvARank("player")
        
        if self.vetHeader then
            self.vetHeader:SetText(GetAvAVeterancyString())
        end
        
        local scrollList = PVP_RANKS.scrollList
        local scrollBar = scrollList.scrollbar
        local minValue, maxValue = scrollBar:GetMinMax()
        local centerValue = self.playerRank * ROW_HEIGHT-(scrollList:GetHeight()/2)
        scrollBar:SetValue(centerValue)
    end)
    
    local list = WINDOW_MANAGER:CreateControlFromVirtual("PvPRanksScrollList", tlw, "ZO_ScrollList") 
    self.scrollList = list
    list:SetAnchor(TOPLEFT, tlw, TOPLEFT, 10, 45) 
    list:SetAnchor(BOTTOMRIGHT, tlw, BOTTOMRIGHT, -10, -10)
    list:SetAlpha(1)
    
    self.FRAGMENT_WINDOW = ZO_FadeSceneFragment:New(tlw)
    CAMPAIGN_OVERVIEW_SCENE:AddFragment(self.FRAGMENT_WINDOW)
    
    self.c_tlw = tlw
    self.c_scrollList = list
    
    local function AddTooltipLine(tooltip, line, padUp)
        if padUp then
            tooltip:AddVerticalPadding(-10) 
        end
        tooltip:AddLine(line, "ZoFontGame", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
    end

    local function ShowTooltip(rowControl, data)
        local AP_ICON = zo_iconFormat("EsoUI/Art/currency/alliancePoints.dds", 14, 14)
        InitializeTooltip(InformationTooltip, rowControl, TOPRIGHT, -50, 0, TOPLEFT)
       
        local rankNameHeading = zo_iconTextFormat(data.rankIcon, 35, 35, data.rankName)
        InformationTooltip:AddLine(rankNameHeading, "ZoFontGame", 1, 1,1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true) 
        ZO_Tooltip_AddDivider(InformationTooltip)
        
        local currentRankString = zo_strformat("<<1>><<2>>|r <<3>>", self.colors.yellow, GetString(SI_STAT_TRADESKILL_RANK), data.rank)
        local startsAtString    = zo_strformat("<<1>><<2>>|r <<3>> <<4>>", self.colors.yellow, "Starts at:", ZO_CommaDelimitNumber(data.startsAt), AP_ICON)
        
        AddTooltipLine(InformationTooltip, currentRankString, false)
        AddTooltipLine(InformationTooltip, startsAtString, true)
        
        if data.endsAt then
            local EndsAtString      = zo_strformat("<<1>><<2>>|r <<3>> <<4>>", self.colors.yellow, "Ends at:", ZO_CommaDelimitNumber(data.endsAt), AP_ICON)
            AddTooltipLine(InformationTooltip, EndsAtString, true)
        end
        
        local unlocks = data.unlocks
        if unlocks then
            ZO_Tooltip_AddDivider(InformationTooltip)
            
            local skillType = SKILL_TYPE_AVA
            local skillAssaultName = "Assault"
            local skillSupportName = "Support"
            
            if SKILLS_DATA_MANAGER then
                local assaultData = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(SKILL_TYPE_AVA, 1)
                local supportData = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(SKILL_TYPE_AVA, 2)
                if assaultData and type(assaultData.GetName) == "function" then skillAssaultName = assaultData:GetName() end
                if supportData and type(supportData.GetName) == "function" then skillSupportName = supportData:GetName() end
            else
                skillAssaultName = GetSkillLineInfo(SKILL_TYPE_AVA, 1)
                skillSupportName = GetSkillLineInfo(SKILL_TYPE_AVA, 2)
            end
            
            skillAssaultName = zo_strformat(SI_SKILLS_TREE_NAME_FORMAT, skillAssaultName)
            skillSupportName = zo_strformat(SI_SKILLS_TREE_NAME_FORMAT, skillSupportName)
            
            local unlocksHeading    = zo_strformat("<<1>> <<2>> <<3>> <<4>>", GetString(SI_GUILDHISTORYGENERALSUBCATEGORIES3), "at", ZO_CommaDelimitNumber(unlocks.startsAt), AP_ICON)
            InformationTooltip:AddLine(unlocksHeading, "ZoFontGame", 1, .5,0, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true) 
            
            ZO_Tooltip_AddDivider(InformationTooltip)
            
            local rank           = GetString(SI_GUILD_TOOLTIP_RANK)
            local assaultUnlocks = unlocks.skillsUnlocked[ASSAULT_SKILL_LINE_INDEX]
            local supportUnlocks = unlocks.skillsUnlocked[SUPPORT_SKILL_LINE_INDEX]
            
            local function AddUnlockedSkills(skillTable)
                for i=1, #skillTable do
                    local unlockedSkill = zo_iconTextFormat(skillTable[i].iconPath, 35, 35, skillTable[i].skillName)
                    InformationTooltip:AddLine(unlockedSkill, "ZoFontGame", 1, .5,0, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
                end
            end

            local assaultRankUnlocked   = zo_strformat("<<1>> <<2>> <<3>>", skillAssaultName, rank, unlocks.rankUnlocked)
            InformationTooltip:AddLine(assaultRankUnlocked, "ZoFontGame", 1, .5,0, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true) 
            
            if assaultUnlocks then AddUnlockedSkills(assaultUnlocks) end
            
            local supportRankUnlocked   = zo_strformat("<<1>> <<2>> <<3>>", skillSupportName, rank, unlocks.rankUnlocked)
            InformationTooltip:AddLine(supportRankUnlocked, "ZoFontGame", 1, .5,0, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true) 
            
            if supportUnlocks then AddUnlockedSkills(supportUnlocks) end
        end
    end
    
    local function HideTooltip(self)   
       ClearTooltip(InformationTooltip)
    end
    
    local function listRow_Setup(rowControl, data, list)
        rowControl:SetHeight(ROW_HEIGHT)
        rowControl:SetFont("ZoFontWinH4")
        rowControl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        rowControl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        rowControl:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        
        rowControl:SetHandler("OnMouseEnter", function(rowControl) ShowTooltip(rowControl, data) end)
        rowControl:SetHandler("OnMouseExit", HideTooltip)
        
        local rankInfo = data.dataEntry.data
        if rankInfo.rank == self.playerRank then
            local color = self.sv["RANK_HIGHLIGHT_COLOR"]
            rowControl:SetColor(unpack(color))
        else
            rowControl:SetColor(.772549,.760784,.61960,1)
        end
        
        local formattedRankIcon = zo_iconFormat(data.dataEntry.data.rankIcon, 35, 35)
        local formattedRowString = zo_strformat("<<1>>)<<2>><<3>>", rankInfo.rank, formattedRankIcon, data.rankName)
        
        rowControl:SetText(formattedRowString) 
    end 
    
    ZO_ScrollList_AddDataType(list, 1, "ZO_SelectableLabel", ROW_HEIGHT, listRow_Setup) 
    return list
end

--=====================================================--
--======= Utility & Event Functions =========--
--=====================================================--
function PvPRanks:UpdateRankHighlightColor()
    local color = self.sv["RANK_HIGHLIGHT_COLOR"]
    local activeControls = self.scrollList.activeControls
    local playerRank = GetUnitAvARank("player")
    
    for k,rowControl in pairs(activeControls) do
        local rankInfo = rowControl.dataEntry.data
        if rankInfo.rank == playerRank then
            rowControl:SetColor(unpack(color))
        else
            rowControl:SetColor(.772549,.760784,.61960,1)
        end
    end
end

local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
end

local function OnRankPointUpdate(eventCode, unitTag, rankPoints, difference)
    if unitTag ~= "player" then return end
    PVP_RANKS.playerRank = GetUnitAvARank("player")
    if PVP_RANKS and type(PVP_RANKS.UpdateRankHighlightColor) == "function" then
        PVP_RANKS:UpdateRankHighlightColor()
    end
end

local function OnRewardTrackProgressGained(eventCode, trackType, trackId, previousRankIndex, rankIndex, newProgress)
    if trackType ~= REWARD_TRACK_TYPE_AVA_VETERANCY then return end
    if PVP_RANKS and PVP_RANKS.vetHeader then
        PVP_RANKS.vetHeader:SetText(GetAvAVeterancyString())
    end
end

local function OnAssignedCampaignChanged(eventCode, newAssignedCampaignId) 
    if newAssignedCampaignId == 0 then return end
    PVP_RANKS:InitializeSkillUnlocksByRank()
    PVP_RANKS:UpdateRankInfoWithSkillUnlocks()
    PVP_RANKS:UpdateScrollList()
end

local function OnAddOnLoaded(_event, _sAddonName)
    if _sAddonName == "EsoStats" then
        ESO_STATS_LOADED = true
        if PVP_RANKS then
            local pvpRanks = GetControl("PvPRanks")
            local esoStatsBtn = GetControl("EsoStatsToggleButton")
            PvPRanks:ClearAnchors()
            PvPRanks:SetAnchor(TOPLEFT, esoStatsBtn, BOTTOMLEFT, -5, 0)
            PvPRanks:SetDimensions(275, 400)
        end
    end
    if _sAddonName == ADDON_NAME then
        PVP_RANKS = PvPRanks:New()
        PVP_RANKS:Initialize()
        
        -- Calls local or external settings generator safely
        if type(PVP_RANKS.CreateSettingsMenu) == "function" then
            PVP_RANKS:CreateSettingsMenu()
        elseif type(PvPRanks.CreateSettingsMenu) == "function" then
            PvPRanks.CreateSettingsMenu()
        end
        
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_RANK_POINT_UPDATE, OnRankPointUpdate)
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ASSIGNED_CAMPAIGN_CHANGED, OnAssignedCampaignChanged)
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_REWARD_TRACK_PROGRESS_GAINED, OnRewardTrackProgressGained)
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

local LAM2 = LibAddonMenu2

local colorYellow       = "|cFFFF00"    -- yellow 
local colorRed          = "|cFF0000"    -- Red

--===================================--
--=====   Settings Menu   ===========--
--===================================--
function PvPRanks.CreateSettingsMenu()
    local panelData = {
        type = "panel",
        name = "PvPRanks",
        displayName = "|cFF0000 PvP Ranks and Veterancy",
        author = "Circonian, ForgottenLight, Sufia_Heolcyn",
        version = "3.01",
        slashCommand = "/pvpranks",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Circonians_PvPRanks_Options", panelData)
    
    local optionsData = {
        [1] = {
            type = "description",
            text = colorYellow.."If you wish to submit a bug report or feature request for this updated version, please do so on the current fork's project page."
        },
        [2] = {
            type = "colorpicker",
            name = "Rank Highlight Color", 
            tooltip = "Changes the highlight color for your current PvP rank in the list.",
            -- FIXED: LAM2 specifically expects named r, g, b, a keys for its default reset action
            default = {r = 1, g = 0, b = 0, a = 1}, 
            getFunc = function() 
                if PVP_RANKS and PVP_RANKS.sv then
                    return unpack(PVP_RANKS.sv["RANK_HIGHLIGHT_COLOR"]) 
                end
                return 1, 0, 0, 1
            end,
            setFunc = function(r,g,b,a) 
                if PVP_RANKS and PVP_RANKS.sv then
                    PVP_RANKS.sv["RANK_HIGHLIGHT_COLOR"] = {r,g,b,a} 
                    if type(PVP_RANKS.UpdateRankHighlightColor) == "function" then
                        PVP_RANKS:UpdateRankHighlightColor()
                    end
                end 
            end,
        },
        [3] = {
            type = "colorpicker",
            name = "Veterancy Tracker Color", 
            tooltip = "Changes the text color for the Veterancy tracker header.",
            -- FIXED: Added named r, g, b, a keys here as well
            default = {r = 1, g = 0.8, b = 0, a = 1}, 
            getFunc = function() 
                if PVP_RANKS and PVP_RANKS.sv then
                    return unpack(PVP_RANKS.sv["VET_TRACKER_COLOR"]) 
                end
                return 1, 0.8, 0, 1
            end,
            setFunc = function(r,g,b,a) 
                if PVP_RANKS and PVP_RANKS.sv then
                    PVP_RANKS.sv["VET_TRACKER_COLOR"] = {r,g,b,a} 
                    if PVP_RANKS.vetHeader then
                        PVP_RANKS.vetHeader:SetColor(r, g, b, a)
                    end
                end 
            end,
        },
    }
    LAM2:RegisterOptionControls("Circonians_PvPRanks_Options", optionsData)
end
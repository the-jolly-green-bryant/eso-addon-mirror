-- CallToArm_CTA.lua (CTA module)
-- Create or reuse the global namespace table (safe if reloaded)
local CallToArm = _G.CallToArm or {}
_G.CallToArm = CallToArm
local CALLTOARM = CallToArm
CALLTOARM.CTA = CALLTOARM.CTA or {}

local CTA = CALLTOARM.CTA
local EM = EVENT_MANAGER

CTA._initDone = CTA._initDone or false
CTA._nextPollAt = CTA._nextPollAt or 0
CTA._updateHandle = "CALLTOARM_CTA_UPDATE"
CTA._leaderboardQueryAt = CTA._leaderboardQueryAt or {}
CTA._forcePopulationOnce = CTA._forcePopulationOnce or false
CTA._campaignDataRefreshAt = CTA._campaignDataRefreshAt or 0
CTA._debugNoFireCount = CTA._debugNoFireCount or 0
CTA._campaignWarmupAt = CTA._campaignWarmupAt or 0

CTA.Popup = CTA.Popup or {}

local POPUP_WIDTH = 900
local POPUP_HEIGHT = 180
local POLL_INTERVAL_SECONDS = 60

local function DebugCTA(msg)
    if CALLTOARM.SV and CALLTOARM.SV.debug then
        d("|c88ccff[CALLTOARM]|r: " .. tostring(msg))
    end
end

local function EnsureCampaignDataFeed(force)
    local now = GetTimeStamp and GetTimeStamp() or 0
    if not force and CTA._campaignDataRefreshAt ~= 0 and (now - CTA._campaignDataRefreshAt) < 60 then
        return
    end
    CTA._campaignDataRefreshAt = now

    if RegisterForAssignedCampaignData then
        RegisterForAssignedCampaignData()
    end
    if RegisterForCampaignSelectionData then
        RegisterForCampaignSelectionData()
    end
    if RequestCampaignSelectionData then
        RequestCampaignSelectionData()
    end
    if RequestCampaignData then
        RequestCampaignData()
    end

    if CAMPAIGN_BROWSER_MANAGER and CAMPAIGN_BROWSER_MANAGER.RebuildCampaignData then
        pcall(function()
            CAMPAIGN_BROWSER_MANAGER:RebuildCampaignData()
        end)
    end
end

local function GetAllianceIcon(alliance)
    if ZO_GetLargeAllianceSymbolIcon then
        return ZO_GetLargeAllianceSymbolIcon(alliance)
    end
    if ZO_GetAllianceSymbolIcon then
        return ZO_GetAllianceSymbolIcon(alliance)
    end
    return nil
end

local ZOS_GetAllianceColor = _G.GetAllianceColor

local function GetAllianceRGB(alliance)
    if type(ZOS_GetAllianceColor) == "function" then
        local c = ZOS_GetAllianceColor(alliance)
        if c and c.UnpackRGB then
            return c:UnpackRGB()
        end
    end
    if alliance == ALLIANCE_ALDMERI_DOMINION or alliance == 1 then
        return 1.0, 0.9, 0.2
    elseif alliance == ALLIANCE_EBONHEART_PACT or alliance == 2 then
        return 0.95, 0.3, 0.3
    elseif alliance == ALLIANCE_DAGGERFALL_COVENANT or alliance == 3 then
        return 0.3, 0.6, 1.0
    end
    return 1, 1, 1
end

local function GetAllianceNameShort(alliance)
    local name = GetAllianceName and GetAllianceName(alliance) or ""
    if name == "" then return "Alliance" end
    if name == "Aldmeri Dominion" then return "Dominion" end
    if name == "Daggerfall Covenant" then return "Covenant" end
    if name == "Ebonheart Pact" then return "Pact" end
    return name
end

local function Clamp01(value)
    local v = tonumber(value) or 0
    if v < 0 then return 0 end
    if v > 1 then return 1 end
    return v
end

local function RGBToHex(r, g, b)
    local rr = math.floor(Clamp01(r) * 255 + 0.5)
    local gg = math.floor(Clamp01(g) * 255 + 0.5)
    local bb = math.floor(Clamp01(b) * 255 + 0.5)
    return string.format("%02X%02X%02X", rr, gg, bb)
end

local function BuildTextureTag(path, size)
    if not path or path == "" then return "" end
    local s = tonumber(size) or 28
    return string.format("|t%d:%d:%s|t", s, s, path)
end

local function GetGuildHeraldryData(gid)
    if not GetGuildHeraldryAttribute then return nil end
    local bgCategory, bgStyle, backgroundPrimaryColorIndex, backgroundSecondaryColorIndex, crestCategoryIndex, crestStyleIndex, crestColorIndex = GetGuildHeraldryAttribute(gid)
    if not bgCategory then return nil end

    local data = {}
    data.bgCategoryIconPath = GetHeraldryGuildFinderBackgroundCategoryIcon and GetHeraldryGuildFinderBackgroundCategoryIcon(bgCategory)
    data.bgStyleIconPath = GetHeraldryGuildFinderBackgroundStyleIcon and GetHeraldryGuildFinderBackgroundStyleIcon(bgCategory, bgStyle)
    data.crestIconPath = GetHeraldryGuildFinderCrestStyleIcon and GetHeraldryGuildFinderCrestStyleIcon(crestCategoryIndex, crestStyleIndex)

    local _, _, crestR, crestG, crestB = GetHeraldryColorInfo(crestColorIndex)
    local _, _, backgroundPrimaryR, backgroundPrimaryG, backgroundPrimaryB = GetHeraldryColorInfo(backgroundPrimaryColorIndex)
    local _, _, backgroundSecondaryR, backgroundSecondaryG, backgroundSecondaryB = GetHeraldryColorInfo(backgroundSecondaryColorIndex)

    data.crestColor = { crestR, crestG, crestB }
    data.primaryBackgroundColor = { backgroundPrimaryR, backgroundPrimaryG, backgroundPrimaryB }
    data.secondaryBackgroundColor = { backgroundSecondaryR, backgroundSecondaryG, backgroundSecondaryB }
    data.hasHeraldry = not (backgroundPrimaryColorIndex == 1 and backgroundSecondaryColorIndex == 1 and crestCategoryIndex == 1 and crestStyleIndex == 1 and crestColorIndex == 1)
    return data
end

local function GetGuildCrestIcon(gid)
    if not GetGuildHeraldryAttribute or not GetHeraldryGuildFinderCrestStyleIcon then
        return nil
    end
    local _, _, _, _, crestCategoryIndex, crestStyleIndex = GetGuildHeraldryAttribute(gid)
    if not crestCategoryIndex then return nil end
    return GetHeraldryGuildFinderCrestStyleIcon(crestCategoryIndex, crestStyleIndex)
end

local function BuildCtaCenterMessage(msg)
    return tostring(msg or "")
end

function CTA.Popup:Ensure()
    if self.control then return end
    if not WINDOW_MANAGER then return end

    local root = GuiRoot
    local control = WINDOW_MANAGER:CreateControl("CALLTOARM_CTA_Popup", root, CT_CONTROL)
    control:SetDimensions(POPUP_WIDTH, POPUP_HEIGHT)
    control:ClearAnchors()
    control:SetAnchor(CENTER, root, CENTER, 0, -150)
    control:SetHidden(true)
    control:SetMouseEnabled(false)

    local bg = WINDOW_MANAGER:CreateControl("$(parent)BG", control, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.7)
    bg:SetEdgeColor(0, 0, 0, 0.9)

    local banner = WINDOW_MANAGER:CreateControl("$(parent)Banner", control, CT_TEXTURE)
    banner:SetTexture("EsoUI/Art/AvA/AvA_battlegroundBanner.dds")
    banner:SetAnchorFill()
    banner:SetAlpha(0.25)

    local allianceIcon = WINDOW_MANAGER:CreateControl("$(parent)AllianceIcon", control, CT_TEXTURE)
    allianceIcon:SetDimensions(96, 96)
    allianceIcon:SetAnchor(LEFT, control, LEFT, 24, 0)

    local guildBlock = WINDOW_MANAGER:CreateControl("$(parent)GuildBlock", control, CT_CONTROL)
    guildBlock:SetDimensions(120, 120)
    guildBlock:SetAnchor(RIGHT, control, RIGHT, -24, 0)

    local guildBanner = WINDOW_MANAGER:CreateControl("$(parent)GuildBanner", guildBlock, CT_TEXTURE)
    guildBanner:SetDimensions(120, 120)
    guildBanner:SetAnchor(CENTER, guildBlock, CENTER, 0, 0)
    guildBanner:SetTexture("EsoUI/Art/Guild/guildHeraldry_background_default.dds")
    guildBanner:SetDrawLayer(DL_BACKGROUND)

    local guildPattern = WINDOW_MANAGER:CreateControl("$(parent)GuildPattern", guildBlock, CT_TEXTURE)
    guildPattern:SetDimensions(120, 120)
    guildPattern:SetAnchor(CENTER, guildBlock, CENTER, 0, 0)
    guildPattern:SetHidden(true)
    guildPattern:SetDrawLayer(DL_ARTWORK)

    local guildCrest = WINDOW_MANAGER:CreateControl("$(parent)GuildCrest", guildBlock, CT_TEXTURE)
    guildCrest:SetDimensions(120, 120)
    guildCrest:SetAnchor(CENTER, guildBlock, CENTER, 0, 0)
    guildCrest:SetHidden(true)
    guildCrest:SetDrawLayer(DL_OVERLAY)
    guildCrest:SetBlendMode(TEX_BLEND_MODE_ALPHA)

    local guildText = WINDOW_MANAGER:CreateControl("$(parent)GuildText", guildBlock, CT_LABEL)
    guildText:SetFont("ZoFontGamepad36")
    guildText:SetAnchor(CENTER, guildBlock, CENTER, 0, 0)
    guildText:SetColor(1, 1, 1, 0.9)
    guildText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    guildText:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local message = WINDOW_MANAGER:CreateControl("$(parent)Message", control, CT_LABEL)
    message:SetFont("ZoFontGamepad42")
    message:SetAnchor(CENTER, control, CENTER, 0, 0)
    message:SetDimensions(POPUP_WIDTH - 260, POPUP_HEIGHT - 40)
    message:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    message:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    message:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    local footer = WINDOW_MANAGER:CreateControl("$(parent)Footer", control, CT_LABEL)
    footer:SetFont("ZoFontGamepad18")
    footer:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, 16, -8)
    footer:SetColor(1, 1, 1, 0.6)
    footer:SetText("")
    footer:SetHidden(true)

    self.control = control
    self.bg = bg
    self.banner = banner
    self.allianceIcon = allianceIcon
    self.guildBanner = guildBanner
    self.guildPattern = guildPattern
    self.guildCrest = guildCrest
    self.guildText = guildText
    self.message = message
    self.footer = footer
end

function CTA.Popup:Show(args)
    if not args or not args.message or args.message == "" then
        DebugCTA("CTA Popup: missing message")
        return false
    end
    self:Ensure()
    if not self.control then
        DebugCTA("CTA Popup: control not available")
        return false
    end

    local allianceId = tonumber(args.allianceId) or 0
    local guildName = args.guildName or (args.guildId and GetGuildName(args.guildId)) or "Guild"
    local duration = tonumber(args.durationSeconds) or 6

    local icon = GetAllianceIcon(allianceId)
    if icon then
        self.allianceIcon:SetTexture(icon)
        self.allianceIcon:SetHidden(false)
    else
        self.allianceIcon:SetHidden(true)
    end

    local r, g, b = GetAllianceRGB(allianceId)
    self.bg:SetCenterColor(r, g, b, 0.2)
    self.bg:SetEdgeColor(r, g, b, 0.8)

    local heraldry = GetGuildHeraldryData(args.guildId or 0)
    if heraldry then
        self.guildBanner:SetTexture(heraldry.bgCategoryIconPath or "EsoUI/Art/Guild/guildHeraldry_background_default.dds")
        if heraldry.primaryBackgroundColor then
            self.guildBanner:SetColor(unpack(heraldry.primaryBackgroundColor))
        else
            self.guildBanner:SetColor(1, 1, 1, 1)
        end
        if heraldry.bgStyleIconPath then
            self.guildPattern:SetTexture(heraldry.bgStyleIconPath)
            if heraldry.secondaryBackgroundColor then
                self.guildPattern:SetColor(unpack(heraldry.secondaryBackgroundColor))
            else
                self.guildPattern:SetColor(1, 1, 1, 1)
            end
            self.guildPattern:SetHidden(false)
        else
            self.guildPattern:SetHidden(true)
        end
        if heraldry.crestIconPath then
            self.guildCrest:SetTexture(heraldry.crestIconPath)
            if heraldry.crestColor then
                self.guildCrest:SetColor(unpack(heraldry.crestColor))
            else
                self.guildCrest:SetColor(1, 1, 1, 1)
            end
            self.guildCrest:SetHidden(false)
        else
            self.guildCrest:SetHidden(true)
        end
        self.guildText:SetHidden(true)
    else
        self.guildBanner:SetTexture("EsoUI/Art/Guild/guildHeraldry_background_default.dds")
        self.guildBanner:SetColor(1, 1, 1, 1)
        self.guildPattern:SetHidden(true)
        local crest = GetGuildCrestIcon(args.guildId or 0)
        if crest then
            self.guildCrest:SetTexture(crest)
            self.guildCrest:SetColor(1, 1, 1, 1)
            self.guildCrest:SetHidden(false)
        else
            self.guildCrest:SetHidden(true)
        end
        self.guildText:SetText(guildName)
        self.guildText:SetHidden(false)
    end

    self.message:SetText(args.message)

    self.control:SetAlpha(1)
    self.control:SetHidden(false)

    if self._hideHandle then
        EVENT_MANAGER:UnregisterForUpdate(self._hideHandle)
    end
    self._hideHandle = "CALLTOARM_CTA_POPUP_HIDE"
    zo_callLater(function()
        if self.control then
            self.control:SetHidden(true)
        end
    end, duration * 1000)

    DebugCTA(string.format("CTA Popup: shown (%ds)", duration))
    return true
end

local function DefaultCtaState()
    return {
        lastFiredAt = {
            empPush = 0,
            dethrone = 0,
            warBegins = 0,
            warRages = 0,
            population = 0,
        },
        lastSeen = {
            top1Name = "",
            top2Name = "",
            emperorName = "",
            lastEmpKeepsOwned = -1,
            lastPopulationSummary = "",
            lastPopBars = {
                [ALLIANCE_ALDMERI_DOMINION] = -1,
                [ALLIANCE_EBONHEART_PACT] = -1,
                [ALLIANCE_DAGGERFALL_COVENANT] = -1,
            },
        },
        homeCampaignPresence = {
            wasInHomeCampaign = false,
            firedOnceWhileInHomeCampaign = false,
        },
    }
end

local function EnsureByGuild(gid)
    if not CALLTOARM.SV then return nil end
    CALLTOARM.SV.byGuild = CALLTOARM.SV.byGuild or {}
    if gid and gid ~= 0 then
        if CALLTOARM.SV.byGuild[gid] == nil then
            CALLTOARM.SV.byGuild[gid] = {}
        end
        local g = CALLTOARM.SV.byGuild[gid]
        g.campaign = g.campaign or { homeCampaignId = 0 }
        g.cta = g.cta or {}

        local cta = g.cta
        cta.enabled = cta.enabled == true
        cta.polling = cta.polling or { intervalSeconds = 1800 }
        cta.polling.intervalSeconds = tonumber(cta.polling.intervalSeconds) or 1800
        cta.doNotDisturb = cta.doNotDisturb or {
            enabled = true,
            suppressInTrials = true,
            suppressInVetDungeons = true,
            suppressInSoloActivities = true,
            suppressInInfiniteArchive = true,
            fireOnceWhileInHomeCampaign = true,
            mode = "none",
        }
        if cta.doNotDisturb.mode == nil then
            cta.doNotDisturb.mode = "none"
            if cta.doNotDisturb.enabled then
                if cta.doNotDisturb.suppressInTrials then
                    cta.doNotDisturb.mode = "mercenary"
                elseif cta.doNotDisturb.suppressInVetDungeons then
                    cta.doNotDisturb.mode = "battle"
                elseif cta.doNotDisturb.suppressInSoloActivities or cta.doNotDisturb.suppressInInfiniteArchive then
                    cta.doNotDisturb.mode = "peace"
                end
            end
        end
        if cta.doNotDisturb.mode == "trial" then cta.doNotDisturb.mode = "mercenary" end
        if cta.doNotDisturb.mode == "vet" then cta.doNotDisturb.mode = "battle" end
        if cta.doNotDisturb.mode == "solo" or cta.doNotDisturb.mode == "archive" then
            cta.doNotDisturb.mode = "peace"
        end
        cta.alerts = cta.alerts or {
            empPush = false,
            dethrone = false,
            warBegins = false,
            warRages = false,
            population = false,
        }
        if cta.alerts.population == nil then
            cta.alerts.population = false
        end
        cta.rules = cta.rules or { dethroneKeepThreshold = 3 }
        cta.display = cta.display or { popupSeconds = 6, useFancyPopup = true }
        if cta.display.useFancyPopup == nil then
            cta.display.useFancyPopup = true
        elseif cta.display.useFancyPopup == false and cta.display._migratedFancy ~= true then
            cta.display.useFancyPopup = true
            cta.display._migratedFancy = true
        end
        cta.templates = cta.templates or {
            empPush = "{Guild} needs you - {ListedPlayer} is pushing for Emperorship!",
            dethrone = "{Guild} Emperor {EmpPlayer} needs you - protect the throne!",
            warBegins = "{Guild}, {GuildAlliance} calls you to Cyrodiil - war begins!",
            warRages = "{GuildAlliance} is at war - {Guild} mount up!",
            population1 = "{Guild} The enemy begins to march",
            population2 = "{Guild} borders may be compromised",
            population3 = "{Guild} War begins, prepare for battle",
            population4 = "{Guild} Mount up! We are at war!",
        }
        if cta.templates.population1 == nil then cta.templates.population1 = "{Guild} The enemy begins to march" end
        if cta.templates.population2 == nil then cta.templates.population2 = "{Guild} borders may be compromised" end
        if cta.templates.population3 == nil then cta.templates.population3 = "{Guild} War begins, prepare for battle" end
        if cta.templates.population4 == nil then cta.templates.population4 = "{Guild} Mount up! We are at war!" end
        cta.cooldown = cta.cooldown or { seconds = 1800 }
        cta.population = cta.population or { intervalSeconds = 1800 }
        cta.population.intervalSeconds = tonumber(cta.population.intervalSeconds) or 1800
        cta.activity = cta.activity or {
            overland = true,
            groupDungeons = false,
            trials = false,
            arenasArchive = false,
            pvpOther = false,
        }
        cta.state = cta.state or DefaultCtaState()
        cta.state.lastFiredAt = cta.state.lastFiredAt or {}
        if cta.state.lastFiredAt.population == nil then
            cta.state.lastFiredAt.population = 0
        end
        cta.state.lastSeen = cta.state.lastSeen or {}
        if cta.state.lastSeen.lastPopulationSummary == nil then
            cta.state.lastSeen.lastPopulationSummary = ""
        end
        if cta.state.lastSeen.lastPopulationLevel == nil then
            cta.state.lastSeen.lastPopulationLevel = 0
        end
        if cta.state.lastSeen.lastPopulationPF == nil then
            cta.state.lastSeen.lastPopulationPF = 0
        end
        if cta.state.lastSeen.lastPopulationEC == nil then
            cta.state.lastSeen.lastPopulationEC = 0
        end

        return g
    end
    return nil
end

local function GetRepresentedGuildId()
    if not CALLTOARM.SV or not CALLTOARM.SV.cta then return 0 end
    local gid = tonumber(CALLTOARM.SV.cta.representedGuildId) or 0
    if gid == 0 and CALLTOARM.Guild and CALLTOARM.Guild.GetLockedGuildId then
        gid = tonumber(CALLTOARM.Guild.GetLockedGuildId()) or 0
        if gid ~= 0 then
            CALLTOARM.SV.cta.representedGuildId = gid
        end
    end
    if gid == 0 and CALLTOARM.Guild and CALLTOARM.Guild.GetSelectedGuildId then
        gid = tonumber(CALLTOARM.Guild.GetSelectedGuildId()) or 0
    end
    return gid
end

local function GetHomeCampaignId(gid)
    local g = EnsureByGuild(gid)
    if not g then return 0 end
    return tonumber(g.campaign and g.campaign.homeCampaignId) or 0
end

local function GetGuildCtaSettings(gid)
    local g = EnsureByGuild(gid)
    if not g then return nil end
    return g.cta
end

local function IsEligibleForCTA(gid)
    return gid ~= 0
end

local function GetZoneDisplayTypeSafe()
    if _G.GetCurrentZoneDisplayType then
        local v = _G.GetCurrentZoneDisplayType()
        if v ~= nil then return v end
    end
    if GetZoneDisplayType and GetUnitZone then
        local zone = GetUnitZone("player")
        if type(zone) == "number" then
            local v = GetZoneDisplayType(zone)
            if v ~= nil then return v end
        end
    end
    return nil
end

local function GetCurrentGroupDifficulty()
    if GetGroupDifficulty then
        return GetGroupDifficulty()
    end
    return nil
end

local function IsTrueSoloOrCompanion()
    if not IsUnitGrouped or not IsUnitGrouped("player") then
        return true
    end
    if not GetGroupSize then return false end
    local groupSize = GetGroupSize()
    if groupSize <= 1 then return true end
    if groupSize == 2 and IsGroupCompanionUnitTag then
        for i = 1, 2 do
            local unitTag = "group" .. i
            if IsGroupCompanionUnitTag(unitTag) then
                return true
            end
        end
    end
    return false
end

local function IsInTrial()
    local inInstance = IsInInstance and IsInInstance() == true
    if not inInstance then return false end
    local displayType = GetZoneDisplayTypeSafe()
    return displayType == ZONE_DISPLAY_TYPE_TRIAL
end

local function IsInVeteranDungeon()
    local inInstance = IsInInstance and IsInInstance() == true
    if not inInstance then return false end
    local displayType = GetZoneDisplayTypeSafe()
    if displayType ~= ZONE_DISPLAY_TYPE_DUNGEON then return false end
    local difficulty = GetCurrentGroupDifficulty()
    return difficulty == GROUP_DIFFICULTY_VETERAN
end

local function IsInGroupArena()
    local inInstance = IsInInstance and IsInInstance() == true
    if not inInstance then return false end
    local displayType = GetZoneDisplayTypeSafe()
    if displayType ~= ZONE_DISPLAY_TYPE_ARENA then return false end
    return not IsTrueSoloOrCompanion()
end

local function IsInSoloActivity()
    if IsInMaelstromArena and IsInMaelstromArena() then return true end
    if IsInVeteranMaelstromArena and IsInVeteranMaelstromArena() then return true end
    local inInstance = IsInInstance and IsInInstance() == true
    if not inInstance then return false end
    local displayType = GetZoneDisplayTypeSafe()
    if displayType ~= ZONE_DISPLAY_TYPE_ARENA then return false end
    return IsTrueSoloOrCompanion()
end

local function IsInInfiniteArchive()
    if IsInstanceEndlessDungeon and IsInstanceEndlessDungeon() then return true end
    if ENDLESS_DUNGEON_MANAGER and ENDLESS_DUNGEON_MANAGER.IsPlayerInEndlessDungeon then
        return ENDLESS_DUNGEON_MANAGER:IsPlayerInEndlessDungeon()
    end
    local inInstance = IsInInstance and IsInInstance() == true
    if not inInstance then return false end
    local displayType = GetZoneDisplayTypeSafe()
    return displayType == ZONE_DISPLAY_TYPE_ENDLESS_DUNGEON
end

local function ShouldSuppressForActivity(settings)
    if not settings or not settings.doNotDisturb then
        return false
    end
    local mode = settings.doNotDisturb.mode or "none"
    if mode == "none" then return false end
    if mode == "peace" then
        return IsInTrial() or IsInVeteranDungeon() or IsInGroupArena() or IsInSoloActivity() or IsInInfiniteArchive()
    end
    if mode == "deserter" then
        return IsInTrial() or IsInVeteranDungeon() or IsInGroupArena()
    end
    if mode == "battle" then
        return IsInTrial() or IsInVeteranDungeon()
    end
    if mode == "mercenary" then
        return IsInTrial()
    end
    if mode == "trial" then return IsInTrial() end
    if mode == "vet" then return IsInVeteranDungeon() end
    if mode == "solo" then return IsInSoloActivity() end
    if mode == "archive" then return IsInInfiniteArchive() end
    return false
end

local function GetCampaignQueryType(campaignId)
    if campaignId == GetAssignedCampaignId() then
        return BGQUERY_ASSIGNED_CAMPAIGN
    end
    return BGQUERY_LOCAL
end

local function GetPopulationForCampaign(campaignId)
    if not campaignId or campaignId == 0 then return nil end

    EnsureCampaignDataFeed(false)

    if GetNumSelectionCampaigns and GetSelectionCampaignId and GetSelectionCampaignPopulationData then
        for selectionIndex = 1, GetNumSelectionCampaigns() do
            local id = GetSelectionCampaignId(selectionIndex)
            if id == campaignId then
                return {
                    [ALLIANCE_ALDMERI_DOMINION] = GetSelectionCampaignPopulationData(selectionIndex, ALLIANCE_ALDMERI_DOMINION),
                    [ALLIANCE_EBONHEART_PACT] = GetSelectionCampaignPopulationData(selectionIndex, ALLIANCE_EBONHEART_PACT),
                    [ALLIANCE_DAGGERFALL_COVENANT] = GetSelectionCampaignPopulationData(selectionIndex, ALLIANCE_DAGGERFALL_COVENANT),
                }
            end
        end
    end

    if CAMPAIGN_BROWSER_MANAGER and CAMPAIGN_BROWSER_MANAGER.GetCampaignDataList then
        if CAMPAIGN_BROWSER_MANAGER.RebuildCampaignData then
            CAMPAIGN_BROWSER_MANAGER:RebuildCampaignData()
        end
        local list = CAMPAIGN_BROWSER_MANAGER:GetCampaignDataList() or {}
        for i = 1, #list do
            local data = list[i]
            if data and data.id == campaignId then
                return {
                    [ALLIANCE_ALDMERI_DOMINION] = data.alliancePopulation1,
                    [ALLIANCE_EBONHEART_PACT] = data.alliancePopulation2,
                    [ALLIANCE_DAGGERFALL_COVENANT] = data.alliancePopulation3,
                }
            end
        end
    end

    return nil
end

local function GetEmperorKeepsOwned(campaignId, alliance)
    if not GetCampaignRulesetId then return 0, 0 end
    local rulesetId = GetCampaignRulesetId(campaignId)
    if not rulesetId then return 0, 0 end
    local numKeeps = GetCampaignRulesetNumImperialKeeps(rulesetId, alliance)
    local owned = 0
    local queryType = GetCampaignQueryType(campaignId)
    for i = 1, numKeeps do
        local keepId = GetCampaignRulesetImperialKeepId(rulesetId, alliance, i)
        if keepId and keepId ~= 0 then
            local keepAlliance = GetKeepAlliance(keepId, queryType)
            if keepAlliance == alliance then
                owned = owned + 1
            end
        end
    end
    return owned, numKeeps
end

local function ExpandTemplate(template, replacements)
    local text = tostring(template or "")
    for key, value in pairs(replacements or {}) do
        text = text:gsub("{" .. key .. "}", tostring(value or ""))
    end
    return text
end

local function WrapCenterMessage(text, maxChars)
    local limit = tonumber(maxChars) or 64
    local s = tostring(text or "")
    if s == "" or #s <= limit then return s end
    local out = {}
    local line = ""
    for word in s:gmatch("%S+") do
        if #line == 0 then
            line = word
        elseif (#line + 1 + #word) <= limit then
            line = line .. " " .. word
        else
            out[#out + 1] = line
            line = word
        end
    end
    if line ~= "" then out[#out + 1] = line end
    return table.concat(out, "\n")
end

local function Lower(text)
    text = tostring(text or "")
    if zo_strlower then
        return zo_strlower(text)
    end
    return string.lower(text)
end

local function GetGuildNameSafe(gid)
    if gid and gid ~= 0 then
        return GetGuildName(gid) or "Guild"
    end
    return "Guild"
end

local function IsBattlegroundWorld()
    if IsActiveWorldBattleground and IsActiveWorldBattleground() then
        return true
    end
    return false
end

local function IsInAnyDungeon()
    local inInstance = IsInInstance and IsInInstance() == true
    if not inInstance then return false end
    local displayType = GetZoneDisplayTypeSafe()
    return displayType == ZONE_DISPLAY_TYPE_DUNGEON
end

local function IsInOverlandOrPublicContent()
    local inInstance = IsInInstance and IsInInstance() == true
    if not inInstance then
        return true
    end
    local displayType = GetZoneDisplayTypeSafe()
    if displayType == nil then
        -- Treat unknown as overland to avoid suppressing alerts at login
        return true
    end
    if displayType == ZONE_DISPLAY_TYPE_PUBLIC_DUNGEON then
        return true
    end
    if displayType == ZONE_DISPLAY_TYPE_ZONE then
        return true
    end
    return false
end

local function IsInPvpOutsideHomeCampaign(homeCampaignId)
    if IsBattlegroundWorld() then
        return true
    end
    local inAvA = IsPlayerInAvAWorld and IsPlayerInAvAWorld() == true
    if not inAvA then return false end
    if GetCurrentCampaignId then
        local current = tonumber(GetCurrentCampaignId()) or 0
        if current ~= 0 and current ~= tonumber(homeCampaignId or 0) then
            return true
        end
    end
    -- Covers Imperial City / AvA maps without a matching home campaign id.
    return true
end

local function IsActivityAllowed(settings, homeCampaignId)
    local activity = settings and settings.activity
    if not activity then
        return true
    end

    -- Fast-path: open world (non-instance, non-AvA)
    local inInstance = IsInInstance and IsInInstance() == true
    local inAvA = IsPlayerInAvAWorld and IsPlayerInAvAWorld() == true
    if not inInstance then
        if not inAvA then
            return activity.overland ~= false
        end
    end

    if IsInTrial() then
        local allowed = activity.trials ~= false
        if not allowed then DebugCTA("CTA Activity: suppressed by trials filter.") end
        return allowed
    end
    if IsInAnyDungeon() then
        local allowed = activity.groupDungeons ~= false
        if not allowed then DebugCTA("CTA Activity: suppressed by group dungeon filter.") end
        return allowed
    end
    if IsInGroupArena() or IsInSoloActivity() or IsInInfiniteArchive() then
        local allowed = activity.arenasArchive ~= false
        if not allowed then DebugCTA("CTA Activity: suppressed by arena/archive filter.") end
        return allowed
    end
    if IsInPvpOutsideHomeCampaign(homeCampaignId) then
        local allowed = activity.pvpOther ~= false
        if not allowed then DebugCTA("CTA Activity: suppressed by PvP filter.") end
        return allowed
    end
    if IsInOverlandOrPublicContent() then
        local allowed = activity.overland ~= false
        if not allowed then DebugCTA("CTA Activity: suppressed by overland filter.") end
        return allowed
    end

    return true
end

local function BuildGuildMemberLookup(gid)
    local map = {}
    if not GetNumGuildMembers or not GetGuildMemberInfo then
        return map
    end
    local num = GetNumGuildMembers(gid) or 0
    for i = 1, num do
        -- API 101050: GetGuildMemberInfo returns account/display name first;
        -- the second return is the guild note, not a character name.
        local displayName = GetGuildMemberInfo(gid, i)
        if displayName and displayName ~= "" then
            map[Lower(displayName)] = true
        end

        -- Character identity is supplied separately by GetGuildMemberCharacterInfo.
        if GetGuildMemberCharacterInfo then
            local hasCharacter, characterName = GetGuildMemberCharacterInfo(gid, i)
            if hasCharacter and characterName and characterName ~= "" then
                map[Lower(characterName)] = true
            end
        end
    end
    return map
end

local function QueryLeaderboardIfNeeded(campaignId, alliance)
    if not QueryCampaignLeaderboardData then return end
    if not campaignId or campaignId == 0 or not alliance then return end
    CTA._leaderboardQueryAt = CTA._leaderboardQueryAt or {}
    local key = tostring(campaignId) .. ":" .. tostring(alliance)
    local last = CTA._leaderboardQueryAt[key] or 0
    local now = GetTimeStamp and GetTimeStamp() or 0
    if (now - last) < 120 then
        return
    end
    CTA._leaderboardQueryAt[key] = now
    QueryCampaignLeaderboardData(campaignId, alliance)
end

local function CanFire(settings, alertKey)
    if CTA._debugBypassCooldownActive == true then
        return true
    end
    local cooldown = tonumber(settings.cooldown and settings.cooldown.seconds) or 600
    local last = tonumber(settings.state.lastFiredAt[alertKey]) or 0
    return (GetTimeStamp() - last) >= cooldown
end

local function MarkFired(settings, alertKey)
    settings.state.lastFiredAt[alertKey] = GetTimeStamp()
end

local function FireAlert(settings, templateKey, replacements)
    local template = settings.templates and settings.templates[templateKey] or ""
    local msg = ExpandTemplate(template, replacements)
    local duration = tonumber(settings.display and settings.display.popupSeconds) or 6
    local guildId = replacements and replacements.guildId or 0
    local allianceId = replacements and replacements.allianceId or 0

    local iconPrefix = BuildCtaCenterMessage("")
    local r, g, b = GetAllianceRGB(allianceId)
    local allianceHex = RGBToHex(r, g, b)
    local wrapped = WrapCenterMessage(msg, 64)
    local coloredMsg = string.format("|c%s%s|r", allianceHex, wrapped)
    local centerMsg = string.format("%s%s", iconPrefix, coloredMsg)

    local sound = (SOUNDS and SOUNDS.ACHIEVEMENT_AWARDED) or nil

    if CALLTOARM.UI and CALLTOARM.UI.ShowCenter then
        CALLTOARM.UI.ShowCenter(centerMsg, duration)
    elseif CENTER_SCREEN_ANNOUNCE and CENTER_SCREEN_ANNOUNCE.CreateMessageParams and CENTER_SCREEN_ANNOUNCE.DisplayMessage and sound then
        local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, sound)
        if params.SetLifespanMS and duration then
            params:SetLifespanMS(duration * 1000)
        end
        params:SetText(centerMsg)
        CENTER_SCREEN_ANNOUNCE:DisplayMessage(params)
    elseif ZO_Alert and UI_ALERT_CATEGORY_ALERT and sound then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, sound, centerMsg)
    else
        d(centerMsg)
    end
    DebugCTA("CTA Triggered: " .. tostring(templateKey))
    DebugCTA("CTA Fired: " .. tostring(msg))
end

function CTA.FormatCenterMessage(msg, guildId, allianceId)
    return BuildCtaCenterMessage(msg, guildId, allianceId)
end

local function CheckEmperorPush(gid, settings, campaignId, guildAlliance)
    if settings.alerts.empPush ~= true then return false end
    if not CanFire(settings, "empPush") then return false end

    if GetNumCampaignAllianceLeaderboardEntries then
        local num = GetNumCampaignAllianceLeaderboardEntries(campaignId, guildAlliance)
        if not num or num == 0 then
            QueryLeaderboardIfNeeded(campaignId, guildAlliance)
            return false
        end
    end

    local owned, total = GetEmperorKeepsOwned(campaignId, guildAlliance)
    if total == 0 or owned < 4 then
        return false
    end

    local _, rank, name, _, _, displayName = GetCampaignAllianceLeaderboardEntryInfo(campaignId, guildAlliance, 1)
    if not rank or tonumber(rank) ~= 1 then
        return false
    end

    local candidateDisplay = displayName or ""
    local candidateName = name or ""
    if candidateDisplay == "" and candidateName == "" then
        return false
    end

    local memberLookup = BuildGuildMemberLookup(gid)
    local isGuildMember = false
    if candidateDisplay ~= "" and memberLookup[Lower(candidateDisplay)] then
        isGuildMember = true
    end
    if candidateName ~= "" and memberLookup[Lower(candidateName)] then
        isGuildMember = true
    end
    DebugCTA(string.format(
        "CTA Emp Push: keeps=%d/%d rank=%s display=%s character=%s guildMember=%s",
        tonumber(owned) or 0,
        tonumber(total) or 0,
        tostring(rank),
        tostring(candidateDisplay),
        tostring(candidateName),
        tostring(isGuildMember)
    ))

    if not isGuildMember then
        return false
    end

    local topName = (candidateDisplay ~= "" and candidateDisplay) or candidateName
    settings.state.lastSeen.top1Name = topName
    FireAlert(settings, "empPush", {
        guildId = gid,
        allianceId = guildAlliance,
        Guild = GetGuildNameSafe(gid),
        ListedPlayer = topName,
        GuildAlliance = GetAllianceNameShort(guildAlliance),
    })
    MarkFired(settings, "empPush")
    return true
end

local function CheckDethrone(gid, settings, campaignId, guildAlliance)
    if settings.alerts.dethrone ~= true then return false end
    if not CanFire(settings, "dethrone") then return false end
    if not DoesCampaignHaveEmperor(campaignId) then return false end

    local emperorAlliance, emperorCharacter, emperorDisplay = GetCampaignEmperorInfo(campaignId)
    if emperorAlliance ~= guildAlliance then return false end

    local owned, total = GetEmperorKeepsOwned(campaignId, guildAlliance)
    if total == 0 then return false end

    local threshold = tonumber(settings.rules.dethroneKeepThreshold) or 3
    if owned > threshold then
        settings.state.lastSeen.lastEmpKeepsOwned = owned
        return false
    end

    if settings.state.lastSeen.lastEmpKeepsOwned == owned then
        return false
    end

    settings.state.lastSeen.lastEmpKeepsOwned = owned
    FireAlert(settings, "dethrone", {
        guildId = gid,
        allianceId = guildAlliance,
        Guild = GetGuildNameSafe(gid),
        EmpPlayer = emperorDisplay or emperorCharacter or "",
        GuildAlliance = GetAllianceNameShort(guildAlliance),
    })
    MarkFired(settings, "dethrone")
    return true
end

local function CheckWarBegins(gid, settings, campaignId, guildAlliance)
    if settings.alerts.warBegins ~= true then return false end
    if not CanFire(settings, "warBegins") then return false end
    local pop = GetPopulationForCampaign(campaignId)
    if not pop then return false end

    local lastSeen = settings.state and settings.state.lastSeen and settings.state.lastSeen.lastPopBars or {}
    local anyTransition = false
    for alliance, alliancePop in pairs(pop) do
        local last = lastSeen[alliance]
        if last == nil then last = -1 end
        if alliancePop == CAMPAIGN_POP_LOW and (last == CAMPAIGN_POP_NONE or last < CAMPAIGN_POP_LOW) then
            anyTransition = true
        end
        lastSeen[alliance] = alliancePop or -1
    end

    if not anyTransition then return false end

    FireAlert(settings, "warBegins", {
        guildId = gid,
        allianceId = guildAlliance,
        Guild = GetGuildNameSafe(gid),
        GuildAlliance = GetAllianceNameShort(guildAlliance),
    })
    MarkFired(settings, "warBegins")
    return true
end

local function CheckWarRages(gid, settings, campaignId, guildAlliance)
    if settings.alerts.warRages ~= true then return false end
    if not CanFire(settings, "warRages") then return false end
    local pop = GetPopulationForCampaign(campaignId)
    if not pop then return false end

    local hotCount = 0
    for _, alliancePop in pairs(pop) do
        if alliancePop and alliancePop >= CAMPAIGN_POP_MEDIUM then
            hotCount = hotCount + 1
        end
    end

    if hotCount < 2 then return false end

    FireAlert(settings, "warRages", {
        guildId = gid,
        allianceId = guildAlliance,
        Guild = GetGuildNameSafe(gid),
        GuildAlliance = GetAllianceNameShort(guildAlliance),
    })
    MarkFired(settings, "warRages")
    return true
end

local function GetPopulationSeverity(pop, guildAlliance)
    local own = tonumber(pop[guildAlliance]) or 0
    local enemyMax = 0
    for alliance, value in pairs(pop) do
        if alliance ~= guildAlliance then
            enemyMax = math.max(enemyMax, tonumber(value) or 0)
        end
    end

    if enemyMax >= CAMPAIGN_POP_FULL and own <= CAMPAIGN_POP_MEDIUM then
        return "CRITICAL"
    end
    if enemyMax >= CAMPAIGN_POP_HIGH and own <= CAMPAIGN_POP_LOW then
        return "HIGH"
    end
    if enemyMax >= CAMPAIGN_POP_MEDIUM then
        return "MEDIUM"
    end
    return "LOW"
end

local function BuildPopulationSummary(pop, guildAlliance)
    local severity = GetPopulationSeverity(pop, guildAlliance)
    local ad = tonumber(pop[ALLIANCE_ALDMERI_DOMINION]) or 0
    local e1 = tonumber(pop[ALLIANCE_EBONHEART_PACT]) or 0
    local e2 = tonumber(pop[ALLIANCE_DAGGERFALL_COVENANT]) or 0
    return string.format("%s | AD:%d E1:%d E2:%d", severity, ad, e1, e2)
end

local function GetPopulationUrgencyLevel(pop, guildAlliance)
    local severity = GetPopulationSeverity(pop, guildAlliance)
    if severity == "CRITICAL" then return 4 end
    if severity == "HIGH" then return 3 end
    if severity == "MEDIUM" then return 2 end
    return 1
end

local POPULATION_MESSAGES = {
    [0] = {
        neutral = {
            "{GuildAlliance} holds advantage in Cyrodiil",
            "{GuildAlliance} stable — no reinforcements needed",
            "War balanced — veterans hold the line",
        },
        congrats = {
            "{GuildAlliance} stands strong — well fought",
            "Banners fly high across Cyrodiil",
        },
        winddown = {
            "Fighting fades — day ends in {GuildAlliance} favour",
        },
    },
    [1] = {
        neutral = {
            "Enemy patrols increase on {GuildAlliance} borders",
            "Skirmishes flare — vigilance advised",
        },
        improving = {
            "{GuildAlliance} steadies front — borders hold",
        },
        worsening = {
            "Enemy pressure grows — border aid needed",
        },
    },
    [2] = {
        neutral = {
            "{GuildAlliance} outnumbered — warriors needed",
            "Ruby Throne contested — {GuildAlliance} calls",
        },
        improving = {
            "Tide turns — join now, press advantage",
            "Fresh blades could aid {GuildAlliance}",
        },
        worsening = {
            "Enemy numbers swell — reinforcements needed",
            "Cyrodiil calls — {GuildAlliance} may falter",
        },
    },
    [3] = {
        neutral = {
            "Enemy surge — {GuildAlliance} falls back",
            "{GuildAlliance} heavily outnumbered",
        },
        improving = {
            "Line bends, not broken — join now",
            "{GuildAlliance} rallies — your strength matters",
        },
        worsening = {
            "Keeps threatened — {GuildAlliance} losing ground",
            "War nears decision — fighters urgently needed",
        },
    },
    [4] = {
        neutral = {
            "Defeat near — {GuildAlliance} needs you now",
            "Enemy banners dominate — final stand nears",
        },
        improving = {
            "Hope remains — warriors must answer call",
            "{GuildAlliance} still fights — stand now",
        },
        worsening = {
            "War nearly lost — decisive action needed",
            "Hour of duty — answer call or yield field",
        },
    },
    [5] = {
        win = {
            "War winds down — {GuildAlliance} claims night",
            "Victory holds — last banners fly",
        },
        loss = {
            "War fades — {GuildAlliance} withdraws",
            "Fallen honoured — day ends in defeat",
        },
        reflective = {
            "Dead rest where they fell — remember them",
            "Cyrodiil grows quiet once more",
        },
    },
}

local function GetPopulationBars(pop, guildAlliance)
    local ad = tonumber(pop[ALLIANCE_ALDMERI_DOMINION]) or 0
    local e1 = tonumber(pop[ALLIANCE_EBONHEART_PACT]) or 0
    local e2 = tonumber(pop[ALLIANCE_DAGGERFALL_COVENANT]) or 0
    if guildAlliance == ALLIANCE_ALDMERI_DOMINION then
        return ad, e1, e2
    elseif guildAlliance == ALLIANCE_EBONHEART_PACT then
        return e1, ad, e2
    end
    return e2, ad, e1
end

local function PickMessage(list)
    if not list or #list == 0 then return nil end
    local index = math.random(1, #list)
    return list[index]
end

local function SelectPopulationMessage(tier, pf, ec, momentum, lastEC)
    local bucket = POPULATION_MESSAGES[tier]
    if not bucket then return nil end

    if tier == 0 then
        if ec <= 2 then
            return PickMessage(bucket.neutral)
        end
        if lastEC and ec < lastEC then
            return PickMessage(bucket.winddown)
        end
        return PickMessage(bucket.congrats)
    end

    if tier >= 1 and tier <= 4 then
        if momentum > 0 then
            return PickMessage(bucket.improving or bucket.neutral)
        elseif momentum < 0 then
            return PickMessage(bucket.worsening or bucket.neutral)
        end
        return PickMessage(bucket.neutral)
    end

    if tier == 5 then
        if ec <= 1 then
            return PickMessage(bucket.reflective)
        end
        if pf > ec then
            return PickMessage(bucket.win)
        elseif pf < ec then
            return PickMessage(bucket.loss)
        end
        return PickMessage(bucket.reflective)
    end

    return nil
end

local function FireAlertText(settings, messageText, replacements)
    local template = tostring(messageText or "")
    local msg = ExpandTemplate(template, replacements)
    local duration = tonumber(settings.display and settings.display.popupSeconds) or 6
    local guildId = replacements and replacements.guildId or 0
    local allianceId = replacements and replacements.allianceId or 0

    local iconPrefix = BuildCtaCenterMessage("")
    local r, g, b = GetAllianceRGB(allianceId)
    local allianceHex = RGBToHex(r, g, b)
    local wrapped = WrapCenterMessage(msg, 64)
    local coloredMsg = string.format("|c%s%s|r", allianceHex, wrapped)
    local centerMsg = string.format("%s%s", iconPrefix, coloredMsg)

    local sound = (SOUNDS and SOUNDS.ACHIEVEMENT_AWARDED) or nil

    if CALLTOARM.UI and CALLTOARM.UI.ShowCenter then
        CALLTOARM.UI.ShowCenter(centerMsg, duration)
    elseif CENTER_SCREEN_ANNOUNCE and CENTER_SCREEN_ANNOUNCE.CreateMessageParams and CENTER_SCREEN_ANNOUNCE.DisplayMessage and sound then
        local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, sound)
        if params.SetLifespanMS and duration then
            params:SetLifespanMS(duration * 1000)
        end
        params:SetText(centerMsg)
        CENTER_SCREEN_ANNOUNCE:DisplayMessage(params)
    elseif ZO_Alert and UI_ALERT_CATEGORY_ALERT and sound then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, sound, centerMsg)
    else
        d(centerMsg)
    end
    DebugCTA("CTA Triggered: population tier message")
    DebugCTA("CTA Fired: " .. tostring(msg))
end

local function CheckPopulationAlert(gid, settings, campaignId, guildAlliance, force)
    if settings.alerts.population ~= true then
        DebugCTA("CTA Pop: disabled.")
        return false
    end

    local pop = GetPopulationForCampaign(campaignId)
    if not pop then
        DebugCTA("CTA Poll: population data unavailable.")
        EnsureCampaignDataFeed(true)
        return false
    end

    local pf, e1, e2 = GetPopulationBars(pop, guildAlliance)
    local ec = (e1 or 0) + (e2 or 0)
    local lastPF = tonumber(settings.state.lastSeen.lastPopulationPF) or 0
    local lastEC = tonumber(settings.state.lastSeen.lastPopulationEC) or 0
    local delta = pf - ec
    local momentum = (pf - ec) - (lastPF - lastEC)

    local tier = 0
    if pf == 0 and ec > 0 then
        tier = 5
    elseif pf > ec or (pf == ec and ec <= 2) then
        tier = 0
    elseif ec < lastEC and pf <= 1 then
        tier = 5
    elseif pf <= 1 and ec >= 5 then
        tier = 4
    elseif delta <= -3 and ec >= 4 then
        tier = 3
    elseif (delta == -1 or delta == -2) and ec >= 3 then
        tier = 2
    elseif (pf == ec and ec >= 3) or (pf == 1 and ec == 2) then
        tier = 1
    else
        tier = 0
    end

    local now = GetTimeStamp and GetTimeStamp() or 0
    local interval = tonumber(settings.population and settings.population.intervalSeconds) or 1800
    if interval < 60 then interval = 60 end

    local lastFired = tonumber(settings.state.lastFiredAt.population) or 0
    local lastTier = tonumber(settings.state.lastSeen.lastPopulationLevel) or 0
    local changed = (tier ~= lastTier)

    if not force then
        if not changed and (now - lastFired) < interval then
            return false
        end
    end

    settings.state.lastSeen.lastPopulationLevel = tier
    settings.state.lastSeen.lastPopulationPF = pf
    settings.state.lastSeen.lastPopulationEC = ec
    settings.state.lastSeen.lastPopulationSummary = BuildPopulationSummary(pop, guildAlliance)

    local message = SelectPopulationMessage(tier, pf, ec, momentum, lastEC)
    if not message then return false end

    FireAlertText(settings, message, {
        guildId = gid,
        allianceId = guildAlliance,
        Guild = GetGuildNameSafe(gid),
        GuildAlliance = GetAllianceNameShort(guildAlliance),
    })
    settings.state.lastFiredAt.population = now

    DebugCTA(string.format("CTA Pop: PF=%d E1=%d E2=%d EC=%d delta=%d momentum=%d tier=%d", pf, e1, e2, ec, delta, momentum, tier))
    return true
end

function CTA.SetRepresentedGuild(gid)
    if not CALLTOARM.SV then return end
    CALLTOARM.SV.cta = CALLTOARM.SV.cta or {}
    CALLTOARM.SV.cta.representedGuildId = tonumber(gid) or 0
    CTA._nextPollAt = 0
end

function CTA.GetRepresentedGuildId()
    return GetRepresentedGuildId()
end

function CTA.GetGuildSettings(gid)
    return GetGuildCtaSettings(gid)
end

function CTA.SetRepresentationLock(seconds)
    CALLTOARM.SV.cta.representLockedUntil = GetTimeStamp() + (tonumber(seconds) or 600)
end

function CTA.ClearRepresentationLock()
    CALLTOARM.SV.cta.representLockedUntil = 0
end

function CTA.DebugDump(gid, campaignId)
    local settings = GetGuildCtaSettings(gid)
    if not settings then
        DebugCTA("CTA Debug: no settings for guild " .. tostring(gid))
        return
    end

    local displayType = GetZoneDisplayTypeSafe()
    local inInstance = IsInInstance and IsInInstance() == true
    local inAvA = IsPlayerInAvAWorld and IsPlayerInAvAWorld() == true

    DebugCTA("CTA Debug: ----")
    DebugCTA(string.format("CTA Debug: guildId=%s campaignId=%s alliance=%s", tostring(gid), tostring(campaignId), tostring(GetGuildAlliance(gid))))
    DebugCTA(string.format("CTA Debug: zoneDisplayType=%s inInstance=%s inAvA=%s", tostring(displayType), tostring(inInstance), tostring(inAvA)))
    DebugCTA(string.format("CTA Debug: enabled=%s cooldown=%s popInterval=%s", tostring(settings.enabled), tostring(settings.cooldown and settings.cooldown.seconds), tostring(settings.population and settings.population.intervalSeconds)))
    DebugCTA(string.format("CTA Debug: alerts empPush=%s dethrone=%s warBegins=%s warRages=%s population=%s", tostring(settings.alerts and settings.alerts.empPush), tostring(settings.alerts and settings.alerts.dethrone), tostring(settings.alerts and settings.alerts.warBegins), tostring(settings.alerts and settings.alerts.warRages), tostring(settings.alerts and settings.alerts.population)))
    DebugCTA(string.format("CTA Debug: activity overland=%s groupDungeons=%s trials=%s arenasArchive=%s pvpOther=%s", tostring(settings.activity and settings.activity.overland), tostring(settings.activity and settings.activity.groupDungeons), tostring(settings.activity and settings.activity.trials), tostring(settings.activity and settings.activity.arenasArchive), tostring(settings.activity and settings.activity.pvpOther)))
    DebugCTA(string.format("CTA Debug: DND mode=%s fireOnceHome=%s", tostring(settings.doNotDisturb and settings.doNotDisturb.mode), tostring(settings.doNotDisturb and settings.doNotDisturb.fireOnceWhileInHomeCampaign)))
    DebugCTA("CTA Debug: ----")
end

function CTA.UpdateHomeCampaignPresence(settings, inHomeCampaign)
    local presence = settings.state.homeCampaignPresence
    if inHomeCampaign then
        if not presence.wasInHomeCampaign then
            presence.wasInHomeCampaign = true
            presence.firedOnceWhileInHomeCampaign = false
        end
    else
        presence.wasInHomeCampaign = false
        presence.firedOnceWhileInHomeCampaign = false
    end
end

function CTA.RunPoll()
    local gid = GetRepresentedGuildId()
    if gid == 0 then
        DebugCTA("CTA Poll: no represented/locked guild.")
        return
    end
    local bypassCooldown = CTA._debugBypassCooldownOnce == true
    CTA._debugBypassCooldownOnce = false
    CTA._debugBypassCooldownActive = bypassCooldown
    if not IsEligibleForCTA(gid) then return end

    local settings = GetGuildCtaSettings(gid)
    if not settings or settings.enabled ~= true then
        DebugCTA("CTA Poll: settings disabled.")
        CTA._debugBypassCooldownActive = false
        return
    end

    DebugCTA("CTA Poll: checking alerts.")

    local guildAlliance = GetGuildAlliance(gid)
    if guildAlliance == 0 and CALLTOARM.Guild and CALLTOARM.Guild.GetSelectedGuildAlliance then
        guildAlliance = tonumber(CALLTOARM.Guild.GetSelectedGuildAlliance()) or 0
    end
    if guildAlliance == 0 then
        DebugCTA("CTA Poll: no guild alliance.")
        CTA._debugBypassCooldownActive = false
        return
    end

    local campaignId = GetHomeCampaignId(gid)
    if campaignId == 0 and CALLTOARM.Guild and CALLTOARM.Guild.GetLockedCampaignId then
        local lockedCampaign = tonumber(CALLTOARM.Guild.GetLockedCampaignId()) or 0
        if lockedCampaign ~= 0 then
            CALLTOARM.Guild.SetHomeCampaignId(gid, lockedCampaign)
            campaignId = lockedCampaign
            DebugCTA("CTA Poll: using locked campaign id.")
        end
    end
    if (campaignId == 0 or campaignId == nil) and GetAssignedCampaignId then
        campaignId = GetAssignedCampaignId()
        if campaignId and campaignId ~= 0 then
            DebugCTA("CTA Poll: using assigned campaign id.")
        end
    end
    if not campaignId or campaignId == 0 then
        DebugCTA("CTA Poll: no campaign id.")
        CTA._debugBypassCooldownActive = false
        return
    end

    if not IsActivityAllowed(settings, campaignId) then
        local displayType = GetZoneDisplayTypeSafe() or -1
        local inInstance = IsInInstance and IsInInstance() == true
        local inAvA = IsPlayerInAvAWorld and IsPlayerInAvAWorld() == true
        DebugCTA(string.format("CTA Poll: activity suppressed (displayType=%s, inInstance=%s, inAvA=%s).", tostring(displayType), tostring(inInstance), tostring(inAvA)))
        CTA._debugBypassCooldownActive = false
        return
    end

    QueryLeaderboardIfNeeded(campaignId, guildAlliance)

    local inAvA = IsPlayerInAvAWorld and IsPlayerInAvAWorld()
    local inHomeCampaign = false
    if inAvA and GetCurrentCampaignId then
        inHomeCampaign = (GetCurrentCampaignId() == campaignId)
    end

    CTA.UpdateHomeCampaignPresence(settings, inHomeCampaign)

    if inHomeCampaign and settings.doNotDisturb and settings.doNotDisturb.fireOnceWhileInHomeCampaign then
        if settings.state.homeCampaignPresence.firedOnceWhileInHomeCampaign then
            return
        end
    end

    local forcePopulation = CTA._forcePopulationOnce == true
    CTA._forcePopulationOnce = false

    local fired = false
    fired = CheckEmperorPush(gid, settings, campaignId, guildAlliance) or fired
    fired = CheckDethrone(gid, settings, campaignId, guildAlliance) or fired
    -- These alert modes were already implemented and configurable but were not
    -- included in the polling chain, so they could never fire during normal use.
    fired = CheckWarBegins(gid, settings, campaignId, guildAlliance) or fired
    fired = CheckWarRages(gid, settings, campaignId, guildAlliance) or fired
    fired = CheckPopulationAlert(gid, settings, campaignId, guildAlliance, forcePopulation) or fired

    if not fired then
        CTA._debugNoFireCount = (CTA._debugNoFireCount or 0) + 1
        if CTA._debugNoFireCount % 10 == 0 then
            DebugCTA("CTA Poll: no alerts fired.")
        end
    end

    if fired and inHomeCampaign and settings.doNotDisturb and settings.doNotDisturb.fireOnceWhileInHomeCampaign then
        settings.state.homeCampaignPresence.firedOnceWhileInHomeCampaign = true
    end
    CTA._debugBypassCooldownActive = false
end

local function ShouldPollNow(settings)
    local now = GetTimeStamp()
    if CTA._nextPollAt == 0 then
        CTA._nextPollAt = now
    end
    if now >= CTA._nextPollAt then
        CTA._nextPollAt = now + POLL_INTERVAL_SECONDS
        return true
    end
    return false
end

local function OnUpdate()
    local gid = GetRepresentedGuildId()
    if gid == 0 then return end
    local settings = GetGuildCtaSettings(gid)
    if not settings or settings.enabled ~= true then return end

    -- Warmup campaign data feed after relog / character swap
    local now = GetTimeStamp and GetTimeStamp() or 0
    if CTA._campaignWarmupAt == 0 or (now - CTA._campaignWarmupAt) >= 10 then
        CTA._campaignWarmupAt = now
        EnsureCampaignDataFeed(true)
    end

    if ShouldPollNow(settings) then
        EnsureCampaignDataFeed(false)
        CTA.RunPoll()
    end
end

function CTA.Init()
    if CTA._initDone then return end
    CTA._initDone = true
    EnsureCampaignDataFeed(true)
    EM:RegisterForUpdate(CTA._updateHandle, 1000, OnUpdate)

    if EVENT_PLAYER_ACTIVATED then
        EM:RegisterForEvent("CALLTOARM_CTA_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
            CTA._nextPollAt = 0
            CTA._forcePopulationOnce = true
            DebugCTA("CTA: player activated, forcing population check.")
            CTA.RunPoll()
        end)
    end

    if EVENT_KEEP_ALLIANCE_OWNER_CHANGED then
        EM:RegisterForEvent("CALLTOARM_CTA_KEEP", EVENT_KEEP_ALLIANCE_OWNER_CHANGED, function()
            CTA._nextPollAt = 0
            CTA.RunPoll()
        end)
    end

    if EVENT_CAMPAIGN_LEADERBOARD_DATA_RECEIVED then
        EM:RegisterForEvent("CALLTOARM_CTA_LB", EVENT_CAMPAIGN_LEADERBOARD_DATA_RECEIVED, function(_, campaignId)
            local gid = GetRepresentedGuildId()
            if gid == 0 then return end
            local home = GetHomeCampaignId(gid)
            if home ~= 0 and home == campaignId then
                CTA._nextPollAt = 0
                CTA.RunPoll()
            end
        end)
    end

    if EVENT_CAMPAIGN_STATE_INITIALIZED then
        EM:RegisterForEvent("CALLTOARM_CTA_STATE", EVENT_CAMPAIGN_STATE_INITIALIZED, function(_, campaignId)
            local gid = GetRepresentedGuildId()
            if gid == 0 then return end
            local home = GetHomeCampaignId(gid)
            if home ~= 0 and home == campaignId then
                CTA._nextPollAt = 0
                CTA.RunPoll()
            end
        end)
    end

    if EVENT_CAMPAIGN_SELECTION_DATA_CHANGED then
        EM:RegisterForEvent("CALLTOARM_CTA_SELECTION_DATA", EVENT_CAMPAIGN_SELECTION_DATA_CHANGED, function()
            CTA._nextPollAt = 0
            CTA.RunPoll()
        end)
    end
end


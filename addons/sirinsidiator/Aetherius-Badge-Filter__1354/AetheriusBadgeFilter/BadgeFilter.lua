local ABF = AetheriusBadgeFilter
local internal = ABF.internal

local CreateBadgeEntry = internal.CreateBadgeEntry

local BadgeFilter = ZO_InitializingObject:Subclass()
ABF.class.BadgeFilter = BadgeFilter

local BADGE_FILTER_NAME_PATTERN = "Aetherius.?Badge.?Filter"

function BadgeFilter:Initialize(guilds, saveData)
    self.guilds = guilds
    self.saveData = saveData
    self.filteredBadge = {}
    self.checkedGuilds = {}
end

function BadgeFilter:SetGuild(guildId)
    self.currentGuildId = guildId
    local guildName = GetGuildName(guildId)
    self.currentGuild = self.guilds[guildName]
    if(not self.currentGuild) then
        self.currentGuild = self:CheckGuildInfo(guildId)
    end
    self.dirty = true
end

function BadgeFilter:IsCurrentGuild(guildId)
    return self.currentGuildId == guildId
end

function BadgeFilter:CheckGuildInfo(guildId, force)
    local guildName = GetGuildName(guildId)
    if(not self.checkedGuilds[guildName] or force) then
        self.checkedGuilds[guildName] = true
        if(not self.guilds[guildName] and (GetGuildDescription(guildId):find(BADGE_FILTER_NAME_PATTERN) or GetGuildMotD(guildId):find(BADGE_FILTER_NAME_PATTERN))) then
            ABF:RegisterGuild(GetWorldName(), guildName)
            return self.guilds[guildName]
        end
    end
end

function BadgeFilter:SupportsBadges()
    return self.currentGuild ~= nil
end

function BadgeFilter:GetCurrentGuildInfo()
    return self.currentGuild
end

local function SortByNameAsc(a, b)
    return a.name < b.name
end

function BadgeFilter:CollectBadges(forced)
    if(self.dirty or forced) then
        self:ClearAll()

        local badgeTable = {}
        local guildId = self.currentGuildId
        for i = 1, GetNumGuildMembers(guildId) do
            local _, note = GetGuildMemberInfo(guildId, i)
            local badges = self:ParseBadges(note)
            for j = 1, #badges do
                local badge = badges[j]
                badgeTable[badge] = (badgeTable[badge] or 0) + 1
            end
        end

        local currentData = self.currentGuild
        local badgeTypes = currentData.badges

        for _, badgeData in pairs(badgeTypes) do
            badgeData.count = 0
        end

        local collected = {}
        for badge, count in pairs(badgeTable) do
            local name, color = self:GetBadgeNameAndColor(badge)
            local badgeData = badgeTypes[name] or CreateBadgeEntry(name)
            if(not badgeData.color) then
                badgeData.color = color
            end
            badgeData.count = count
            collected[#collected + 1] = badgeData
        end

        table.sort(collected, SortByNameAsc)
        currentData.collected = collected
        self.dirty = false
    end
end

function BadgeFilter:ParseBadges(note)
    local badges = {}
    for badge in note:gmatch("|c.......-|r") do
        badges[#badges + 1] = badge
    end
    return badges
end

function BadgeFilter:GetBadgeNameAndColor(badge)
    local color, name = badge:match("|c(......)(.-)|r")
    return name, color
end

function BadgeFilter:GetListEntries()
    local saveData, currentData = self.saveData, self.currentGuild
    return (saveData.showScannedBadges or #currentData.entries == 0) and currentData.collected or currentData.entries
end

function BadgeFilter:HasSelectedBadge(note)
    local badges = self:ParseBadges(note)
    for i = 1, #badges do
        local name = self:GetBadgeNameAndColor(badges[i])
        if(self.filteredBadge[name]) then return true end
        local relations = self.currentGuild.relations
        if(relations[name]) then
            for _, relatedName in ipairs(relations[name]) do
                if(self.filteredBadge[relatedName]) then return true end
            end
        end
    end
    return false
end

function BadgeFilter:IsAnyBadgeSelected()
    if(not self.currentGuild) then return false end
    for badge, state in pairs(self.filteredBadge) do
        if(state) then
            return true
        end
    end
    return false
end

function BadgeFilter:ClearAll()
    local filteredBadge = self.filteredBadge
    for key in pairs(filteredBadge) do
        filteredBadge[key] = nil
    end
end

function BadgeFilter:SetBadge(name, state)
    self.filteredBadge[name] = state
end

function BadgeFilter:GetBadge(name)
    if(self.filteredBadge[name]) then
        return true
    end
    return false
end

function BadgeFilter:GetFilteredCount()
    return NonContiguousCount(self.filteredBadge)
end

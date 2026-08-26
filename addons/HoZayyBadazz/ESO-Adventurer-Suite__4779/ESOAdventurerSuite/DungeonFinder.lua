-- ESO Adventurer Suite
-- Alphabetical runtime Dungeon Finder index
local EPC = ESOProgressionCoach
EPC.DungeonFinder = EPC.DungeonFinder or {}
local D = EPC.DungeonFinder

D.PAGE_SIZE = 10
D.MAX_ACTIVITY_ID = 15000

local BASE_GAME = {
    ["arx corinium"]=true,["banished cells i"]=true,["banished cells ii"]=true,
    ["blackheart haven"]=true,["blessed crucible"]=true,["city of ash i"]=true,["city of ash ii"]=true,
    ["crypt of hearts i"]=true,["crypt of hearts ii"]=true,["darkshade caverns i"]=true,["darkshade caverns ii"]=true,
    ["direfrost keep"]=true,["elden hollow i"]=true,["elden hollow ii"]=true,["fungal grotto i"]=true,
    ["fungal grotto ii"]=true,["selene's web"]=true,["spindleclutch i"]=true,["spindleclutch ii"]=true,
    ["tempest island"]=true,["vaults of madness"]=true,["volanfe ll"]=true,["volenfell"]=true,
    ["wayrest sewers i"]=true,["wayrest sewers ii"]=true,
}

local function cleanName(name)
    name = tostring(name or "")
    if type(zo_strformat) == "function" and name ~= "" then
        local ok, formatted = pcall(zo_strformat, "<<C:1>>", name)
        if ok and formatted and formatted ~= "" then name = formatted end
    end
    return name
end

local function sourceFor(name)
    local key = string.lower(cleanName(name))
    key = key:gsub("^veteran%s+", ""):gsub("^the%s+", "")
    if BASE_GAME[key] then return "BASE GAME" end
    return "DLC / CHAPTER"
end


local function norm(text)
    text = string.lower(cleanName(text))
    text = text:gsub("^veteran%s+", ""):gsub("^normal%s+", ""):gsub("^the%s+", "")
    text = text:gsub("[^%w]+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return text
end

local function safeCall(fn, ...)
    if type(fn) ~= "function" then return false end
    return pcall(fn, ...)
end

local function message(text)
    if EPC and type(EPC.Print) == "function" then EPC:Print(text)
    elseif type(d) == "function" then d("[EAS] " .. tostring(text)) end
end

D.difficulty = D.difficulty or "NORMAL"
D.role = D.role or "DPS"
D.autoAccept = D.autoAccept ~= false
D.enforceRoles = D.enforceRoles ~= false

function D:SetDifficulty(value)
    value = tostring(value or "NORMAL"):upper()
    self.difficulty = value == "VETERAN" and "VETERAN" or "NORMAL"
end

function D:CycleRole()
    local order = {"DPS", "TANK", "HEALER"}
    local current = tostring(self.role or "DPS")
    for i, v in ipairs(order) do
        if v == current then self.role = order[(i % #order) + 1]; return self.role end
    end
    self.role = "DPS"
    return self.role
end

function D:GetRoleConstant()
    if self.role == "TANK" then return LFG_ROLE_TANK end
    if self.role == "HEALER" then return LFG_ROLE_HEAL end
    return LFG_ROLE_DPS
end

function D:GetSelectedActivityId()
    local selected = self:GetSelected()
    if not selected then return nil end
    if self.difficulty == "VETERAN" then
        return selected.veteranActivityId or selected.activityId
    end
    return selected.normalActivityId or selected.activityId
end

function D:IsQueued()
    if type(IsCurrentlySearchingForGroup) == "function" then
        local ok, queued = pcall(IsCurrentlySearchingForGroup)
        if ok and queued then return true end
    end
    if type(GetActivityFinderStatus) == "function" then
        local ok, status = pcall(GetActivityFinderStatus)
        if ok then
            return status == ACTIVITY_FINDER_STATUS_QUEUED or status == ACTIVITY_FINDER_STATUS_READY_CHECK
        end
    end
    return false
end

function D:QueueSelected()
    local activityId = self:GetSelectedActivityId()
    local selected = self:GetSelected()
    if not selected or not activityId then message("Select a dungeon first."); return false end
    if self:IsQueued() then message("You are already in an Activity Finder queue."); return false end

    if type(UpdateSelectedLFGRole) == "function" then
        pcall(UpdateSelectedLFGRole, self:GetRoleConstant())
    end
    if type(SetVeteranDifficulty) == "function" then
        pcall(SetVeteranDifficulty, self.difficulty == "VETERAN")
    end
    if type(ClearActivityFinderSearch) ~= "function" or type(AddActivityFinderSpecificSearchEntry) ~= "function" or type(StartActivityFinderSearch) ~= "function" then
        message("ESO Activity Finder API is unavailable on this client.")
        return false
    end
    pcall(ClearActivityFinderSearch)
    local okAdd = pcall(AddActivityFinderSpecificSearchEntry, activityId)
    if not okAdd then message("Could not add that dungeon to Activity Finder."); return false end
    local ok, result = pcall(StartActivityFinderSearch)
    if ok then
        if EPC.DungeonHistory and EPC.DungeonHistory.RememberQueuedDifficulty then
            EPC.DungeonHistory:RememberQueuedDifficulty(self.difficulty)
        end
        message(string.format("Queue requested: %s [%s / %s]", selected.name or "Dungeon", self.difficulty, self.role))
        return true, result
    end
    message("ESO rejected the queue request.")
    return false
end

function D:CancelQueue()
    if type(CancelGroupSearches) ~= "function" then message("Cancel queue API is unavailable."); return false end
    local ok = pcall(CancelGroupSearches)
    if ok then message("Activity Finder queue canceled.") end
    return ok
end

function D:FindReplacement()
    if type(CanSendLFMRequest) ~= "function" or type(SendLFMRequest) ~= "function" then
        message("Find Replacement is not available on this client.")
        return false
    end
    local ok, can = pcall(CanSendLFMRequest)
    if not ok or not can then
        message("ESO cannot request a replacement for your current group right now.")
        return false
    end
    local sent = pcall(SendLFMRequest)
    if sent then message("Replacement request sent to Activity Finder.") end
    return sent
end

local function findOptionIndex(userType, countFn, infoFn, wanted)
    if type(countFn) ~= "function" or type(infoFn) ~= "function" then return nil end
    local okCount, count = pcall(countFn, userType)
    if not okCount then return nil end
    wanted = norm(wanted)
    for i = 1, tonumber(count) or 0 do
        local ok, name = pcall(infoFn, userType, i)
        if ok and norm(name) == wanted then return i end
    end
    return nil
end

function D:CreateHostListing()
    local selected = self:GetSelected()
    if not selected then message("Select a dungeon first."); return false end
    if self:IsQueued() then message("Leave the Activity Finder queue before creating a Group Finder listing."); return false end
    if type(RequestCreateGroupListing) ~= "function" or type(SetGroupFinderUserTypeGroupListingCategory) ~= "function" then
        message("ESO Group Finder creation API is unavailable on this client.")
        return false
    end
    if type(IsUnitSoloOrGroupLeader) == "function" then
        local ok, leader = pcall(IsUnitSoloOrGroupLeader, "player")
        if ok and not leader then message("Only the group leader can host a listing."); return false end
    end

    local ut = GROUP_FINDER_GROUP_LISTING_USER_TYPE_GROUP_LISTING_DRAFT
    if ut == nil then message("ESO Group Finder draft type is unavailable."); return false end

    pcall(SetGroupFinderUserTypeGroupListingCategory, ut, GROUP_FINDER_CATEGORY_DUNGEON)
    if type(UpdateGroupFinderUserTypeGroupListingOptions) == "function" then pcall(UpdateGroupFinderUserTypeGroupListingOptions, ut) end

    local primaryWanted = self.difficulty == "VETERAN" and "Veteran" or "Normal"
    local primary = findOptionIndex(ut, GetGroupFinderUserTypeGroupListingNumPrimaryOptions, GetGroupFinderUserTypeGroupListingPrimaryOptionByIndex, primaryWanted)
    if primary and type(SetGroupFinderUserTypeGroupListingPrimaryOption) == "function" then
        pcall(SetGroupFinderUserTypeGroupListingPrimaryOption, ut, primary)
        if type(UpdateGroupFinderUserTypeGroupListingOptions) == "function" then pcall(UpdateGroupFinderUserTypeGroupListingOptions, ut) end
    end

    local secondary = findOptionIndex(ut, GetGroupFinderUserTypeGroupListingNumSecondaryOptions, GetGroupFinderUserTypeGroupListingSecondaryOptionByIndex, selected.name)
    if secondary and type(SetGroupFinderUserTypeGroupListingSecondaryOption) == "function" then
        pcall(SetGroupFinderUserTypeGroupListingSecondaryOption, ut, secondary)
    elseif type(SetGroupFinderUserTypeGroupListingSecondaryOptionDefault) == "function" then
        pcall(SetGroupFinderUserTypeGroupListingSecondaryOptionDefault, ut)
    end

    if GROUP_FINDER_SIZE_STANDARD and type(SetGroupFinderUserTypeGroupListingGroupSize) == "function" then
        pcall(SetGroupFinderUserTypeGroupListingGroupSize, ut, GROUP_FINDER_SIZE_STANDARD)
    end
    if GROUP_FINDER_PLAYSTYLE_STANDARD and type(SetGroupFinderUserTypeGroupListingPlaystyle) == "function" then
        pcall(SetGroupFinderUserTypeGroupListingPlaystyle, ut, GROUP_FINDER_PLAYSTYLE_STANDARD)
    end
    if type(SetGroupFinderUserTypeGroupListingAutoAcceptRequests) == "function" then
        pcall(SetGroupFinderUserTypeGroupListingAutoAcceptRequests, ut, self.autoAccept == true)
    end
    if type(SetGroupFinderUserTypeGroupListingEnforceRoles) == "function" then
        pcall(SetGroupFinderUserTypeGroupListingEnforceRoles, ut, self.enforceRoles == true)
    end
    if type(GroupFinderUserTypeGroupListingClearDesiredRoles) == "function" then pcall(GroupFinderUserTypeGroupListingClearDesiredRoles, ut) end
    if type(SetGroupFinderUserTypeGroupListingRoleCount) == "function" then
        if LFG_ROLE_TANK then pcall(SetGroupFinderUserTypeGroupListingRoleCount, ut, LFG_ROLE_TANK, 1) end
        if LFG_ROLE_HEAL then pcall(SetGroupFinderUserTypeGroupListingRoleCount, ut, LFG_ROLE_HEAL, 1) end
        if LFG_ROLE_DPS then pcall(SetGroupFinderUserTypeGroupListingRoleCount, ut, LFG_ROLE_DPS, 2) end
    end
    if type(SetGroupFinderUserTypeGroupListingRequiresInviteCode) == "function" then pcall(SetGroupFinderUserTypeGroupListingRequiresInviteCode, ut, false) end
    if type(SetGroupFinderUserTypeGroupListingTitle) == "function" then pcall(SetGroupFinderUserTypeGroupListingTitle, ut, tostring(selected.name or "Dungeon Group")) end
    if type(SetGroupFinderUserTypeGroupListingDescription) == "function" then
        pcall(SetGroupFinderUserTypeGroupListingDescription, ut, string.format("%s - %s. 1 Tank / 1 Healer / 2 DPS.", tostring(selected.name or "Dungeon"), self.difficulty))
    end

    local ok = pcall(RequestCreateGroupListing)
    if ok then
        message(string.format("Host listing requested: %s [%s]", selected.name or "Dungeon", self.difficulty))
        if not secondary then message("ESO did not expose an exact dungeon option; listing uses the default dungeon selection.") end
    else
        message("ESO rejected the Group Finder listing request.")
    end
    return ok
end

function D:StartScan(force)
    if self.scanning then return end
    if self.ready and not force then return end
    self.scanning = true
    self.ready = false
    self.entries = {}
    self.page = 1
    self.selectedIndex = nil
    local seen = {}
    local id = 1
    local function step()
        local stopAt = math.min(self.MAX_ACTIVITY_ID, id + 399)
        for activityId = id, stopAt do
            if type(GetActivityInfo) == "function" then
                local ok, name, levelMin, levelMax, cpMin, cpMax, groupType, minGroup, description = pcall(GetActivityInfo, activityId)
                if ok and name and name ~= "" then
                    local isDungeon = (LFG_GROUP_TYPE_REGULAR ~= nil and groupType == LFG_GROUP_TYPE_REGULAR)
                    if type(GetActivityType) == "function" then
                        local typeOk, activityType = pcall(GetActivityType, activityId)
                        if typeOk and activityType ~= nil then
                            isDungeon = activityType == LFG_ACTIVITY_DUNGEON or activityType == LFG_ACTIVITY_MASTER_DUNGEON
                        end
                    end
                    if isDungeon then
                        local display = cleanName(name)
                        local key = norm(display)
                        local activityType = nil
                        if type(GetActivityType) == "function" then
                            local tOk, t = pcall(GetActivityType, activityId)
                            if tOk then activityType = t end
                        end
                        local entry = seen[key]
                        if not entry then
                            entry = {
                                activityId = activityId,
                                name = display,
                                source = sourceFor(display),
                                levelMin = tonumber(levelMin) or 0,
                                championMin = tonumber(cpMin) or 0,
                                description = tostring(description or ""),
                            }
                            seen[key] = entry
                            self.entries[#self.entries+1] = entry
                        end
                        if activityType == LFG_ACTIVITY_MASTER_DUNGEON then entry.veteranActivityId = activityId
                        elseif activityType == LFG_ACTIVITY_DUNGEON then entry.normalActivityId = activityId end
                    end
                end
            end
        end
        id = stopAt + 1
        if id <= self.MAX_ACTIVITY_ID and type(zo_callLater) == "function" then
            zo_callLater(step, 1)
        else
            table.sort(self.entries, function(a,b) return string.lower(a.name) < string.lower(b.name) end)
            self.scanning = false
            self.ready = true
            if EPC.Journal and EPC.Journal.activeTab == "DUNGEONS" and EPC.Journal.RefreshSuitePage then EPC.Journal:RefreshSuitePage("DUNGEONS") end
        end
    end
    step()
end

function D:ChangePage(delta)
    local count = #(self.entries or {})
    local pages = math.max(1, math.ceil(count / self.PAGE_SIZE))
    self.page = math.max(1, math.min(pages, (tonumber(self.page) or 1) + (tonumber(delta) or 0)))
end

function D:SelectRow(row)
    local idx = ((tonumber(self.page) or 1)-1) * self.PAGE_SIZE + (tonumber(row) or 1)
    if self.entries and self.entries[idx] then self.selectedIndex = idx end
end

function D:GetSelected()
    return self.entries and self.entries[self.selectedIndex or 0] or nil
end

function D:BuildView()
    if not self.ready and not self.scanning then self:StartScan(false) end
    local all = self.entries or {}
    local count = #all
    local pages = math.max(1, math.ceil(count / self.PAGE_SIZE))
    self.page = math.max(1, math.min(pages, tonumber(self.page) or 1))
    local first = (self.page-1) * self.PAGE_SIZE + 1
    local rows = {}
    for i=first, math.min(count, first+self.PAGE_SIZE-1) do rows[#rows+1] = all[i] end
    return {rows=rows,total=count,page=self.page,pageCount=pages,selected=self:GetSelected(),scanning=self.scanning,ready=self.ready,difficulty=self.difficulty,role=self.role,autoAccept=self.autoAccept,enforceRoles=self.enforceRoles,queued=self:IsQueued()}
end

function D:Initialize()
    self.entries = self.entries or {}
    self.page = 1
    self:StartScan(false)
end


-- v0.25.28: Event-driven live ESO Group Finder browser integrated into the Codex Dungeon Finder.
D.viewMode = D.viewMode or "DUNGEONS"
D.livePage = D.livePage or 1
D.liveSelectedIndex = D.liveSelectedIndex or nil
D.liveDifficulty = D.liveDifficulty or "ALL"

local function liveCategoryOrder()
    local out = {}
    local candidates = {
        GROUP_FINDER_CATEGORY_DUNGEON,
        GROUP_FINDER_CATEGORY_TRIAL,
        GROUP_FINDER_CATEGORY_ARENA,
        GROUP_FINDER_CATEGORY_ENDLESS_DUNGEON,
        GROUP_FINDER_CATEGORY_ZONE,
        GROUP_FINDER_CATEGORY_ADVENTURE_ZONE,
        GROUP_FINDER_CATEGORY_CUSTOM,
    }
    local seen = {}
    for _, value in ipairs(candidates) do
        if value ~= nil and not seen[value] then
            seen[value] = true
            out[#out+1] = value
        end
    end
    return out
end

local function getLiveCategoryName(category)
    if category == nil then return "GROUPS" end
    if type(GetString) == "function" then
        local ok, text = pcall(GetString, "SI_GROUPFINDERCATEGORY", category)
        if ok and text and text ~= "" then return cleanName(text) end
    end
    return "CATEGORY " .. tostring(category)
end

local function liveRoleSummary(data)
    if not data or type(data.GetRoleStatusCount) ~= "function" then return "" end
    local parts = {}
    local roles = {
        {LFG_ROLE_TANK, "T"},
        {LFG_ROLE_HEAL, "H"},
        {LFG_ROLE_DPS, "D"},
    }
    for _, entry in ipairs(roles) do
        if entry[1] ~= nil then
            local ok, desired, attained = pcall(data.GetRoleStatusCount, data, entry[1])
            if ok then
                desired = tonumber(desired) or 0
                attained = tonumber(attained) or 0
                if desired > 0 or attained > 0 then
                    parts[#parts+1] = string.format("%s %d/%d", entry[2], attained, desired)
                end
            end
        end
    end
    return table.concat(parts, "  ")
end

function D:SetViewMode(mode)
    mode = tostring(mode or "DUNGEONS"):upper()
    if mode == "LIVE" then
        self.viewMode = "LIVE"
        self.livePage = 1
        self.liveSelectedIndex = nil
        self:RefreshLiveListings(true)
    else
        self.viewMode = "DUNGEONS"
        if type(RequestSetGroupFinderExpectingUpdates) == "function" then
            pcall(RequestSetGroupFinderExpectingUpdates, false)
        end
    end
end

function D:GetLiveCategory()
    local order = liveCategoryOrder()
    if #order == 0 then return nil end
    if self.liveCategory == nil then self.liveCategory = order[1] end
    return self.liveCategory
end

function D:CycleLiveCategory()
    local order = liveCategoryOrder()
    if #order == 0 then return nil end
    local current = self:GetLiveCategory()
    local nextIndex = 1
    for i, value in ipairs(order) do
        if value == current then nextIndex = (i % #order) + 1 break end
    end
    self.liveCategory = order[nextIndex]
    self.livePage = 1
    self.liveSelectedIndex = nil
    self:RefreshLiveListings(true)
    return self.liveCategory
end

function D:SetLiveDifficulty(value)
    value = tostring(value or "ALL"):upper()
    if value ~= "NORMAL" and value ~= "VETERAN" then value = "ALL" end
    self.liveDifficulty = value
    self.livePage = 1
    self.liveSelectedIndex = nil
    self:RefreshLiveListings(true)
end

function D:ConfigureLiveFilters()
    local category = self:GetLiveCategory()
    if category == nil then return false end

    -- Let ESO rebuild category-specific defaults first. This clears stale activity
    -- selections from a previously viewed category before we apply Suite filters.
    if type(SetGroupFinderFilterCategory) == "function" then
        pcall(SetGroupFinderFilterCategory, category, true)
    end

    -- Never silently restrict live results to the player's current role.
    if type(SetGroupFinderFilterEnforceRoles) == "function" then
        pcall(SetGroupFinderFilterEnforceRoles, false)
    end

    local supportsDifficulty = category == GROUP_FINDER_CATEGORY_DUNGEON
        or category == GROUP_FINDER_CATEGORY_TRIAL
        or category == GROUP_FINDER_CATEGORY_ARENA
    if supportsDifficulty and type(SetGroupFinderFilterPrimaryOptionByIndex) == "function" then
        local count = 0
        if type(GetGroupFinderFilterNumPrimaryOptions) == "function" then
            local ok, value = pcall(GetGroupFinderFilterNumPrimaryOptions)
            if ok then count = tonumber(value) or 0 end
        end

        -- The Suite defaults to ALL so Normal + Veteran listings are both visible.
        -- Explicit NORMAL/VETERAN buttons narrow the results only when requested.
        if count > 0 then
            for i = 1, count do
                pcall(SetGroupFinderFilterPrimaryOptionByIndex, i, self.liveDifficulty == "ALL")
            end
            if self.liveDifficulty == "NORMAL" then
                pcall(SetGroupFinderFilterPrimaryOptionByIndex, 1, true)
            elseif self.liveDifficulty == "VETERAN" then
                pcall(SetGroupFinderFilterPrimaryOptionByIndex, math.min(2, count), true)
            end
        end
    end
    return true
end

function D:RefreshLiveListings(force)
    if self.viewMode ~= "LIVE" and not force then return false end
    if type(RequestGroupFinderSearch) ~= "function" then
        message("ESO Group Finder live search is unavailable on this client.")
        return false
    end
    if type(IsUnitInBattleground) == "function" then
        local ok, inBg = pcall(IsUnitInBattleground, "player")
        if ok and inBg then message("Group Finder search is unavailable in Battlegrounds."); return false end
    end
    if type(GetUnitLevel) == "function" then
        local ok, level = pcall(GetUnitLevel, "player")
        if ok and (tonumber(level) or 50) < 10 then message("Group Finder requires level 10."); return false end
    end
    self:ConfigureLiveFilters()
    if type(RequestSetGroupFinderExpectingUpdates) == "function" then pcall(RequestSetGroupFinderExpectingUpdates, true) end
    self.liveSearchPending = true
    self.liveSearchId = nil

    -- Prefer ESO's own search manager. It handles the server search cooldown, queues
    -- a request when necessary, owns currentSearchId, and rebuilds result objects
    -- only after the matching search completes.
    if type(GROUP_FINDER_SEARCH_MANAGER) == "table" and type(GROUP_FINDER_SEARCH_MANAGER.ExecuteSearch) == "function" then
        local ok = pcall(GROUP_FINDER_SEARCH_MANAGER.ExecuteSearch, GROUP_FINDER_SEARCH_MANAGER)
        if ok then return true end
    end

    -- Compatibility fallback for clients where the manager is unavailable.
    local ok, searchId = pcall(RequestGroupFinderSearch)
    if ok and searchId ~= nil then
        self.liveSearchId = searchId
        return true
    end
    self.liveSearchPending = false
    message("ESO could not start the Group Finder search.")
    return false
end

function D:GetLiveResults()
    if type(GROUP_FINDER_SEARCH_MANAGER) ~= "table" or type(GROUP_FINDER_SEARCH_MANAGER.GetSearchResults) ~= "function" then return {} end
    local ok, results = pcall(GROUP_FINDER_SEARCH_MANAGER.GetSearchResults, GROUP_FINDER_SEARCH_MANAGER)
    if not ok or type(results) ~= "table" then return {} end
    return results
end

function D:ChangeLivePage(delta)
    self:BuildLiveView()
    local results = self._filteredLiveResults or self:GetLiveResults()
    local pages = math.max(1, math.ceil(#results / self.PAGE_SIZE))
    self.livePage = math.max(1, math.min(pages, (tonumber(self.livePage) or 1) + (tonumber(delta) or 0)))
    self.liveSelectedIndex = nil
end

function D:SelectLiveRow(row)
    self:BuildLiveView()
    local results = self._filteredLiveResults or self:GetLiveResults()
    local idx = ((tonumber(self.livePage) or 1)-1) * self.PAGE_SIZE + (tonumber(row) or 1)
    if results[idx] then self.liveSelectedIndex = idx end
end

function D:GetSelectedLive()
    local results = self._filteredLiveResults or self:GetLiveResults()
    return results[self.liveSelectedIndex or 0]
end

local function liveListingText(data)
    local title, description, owner = "Group Listing", "", ""
    if data then
        if type(data.GetTitle) == "function" then local ok,v=pcall(data.GetTitle,data); if ok and v then title=cleanName(v) end end
        if type(data.GetDescription) == "function" then local ok,v=pcall(data.GetDescription,data); if ok and v then description=tostring(v) end end
        if type(data.GetOwnerDisplayName) == "function" then local ok,v=pcall(data.GetOwnerDisplayName,data); if ok and v then owner=tostring(v) end end
    end
    return title, description, owner
end

local function isLastBossListing(data)
    local title, description = liveListingText(data)
    local text = string.lower(tostring(title or "") .. " " .. tostring(description or ""))
    local patterns = {
        "last boss", "final boss", "last pull", "final pull", "last fight", "final fight",
        "boss only", "last boss farm", "final boss farm", "last boss kill", "final boss kill",
        "lastboss", "finalboss", "end boss", "endboss", "last encounter", "final encounter"
    }
    for _, phrase in ipairs(patterns) do if string.find(text, phrase, 1, true) then return true end end
    if text:match("%f[%a]lb%f[%A]") then return true end
    return false
end

local function looksLikeWTS(data)
    local title, description = liveListingText(data)
    local text = string.lower(tostring(title or "") .. " " .. tostring(description or ""))
    return text:find("wts",1,true) or text:find("selling",1,true) or text:find("sell run",1,true)
end

local function requiredCP(data)
    if not data then return 0 end
    for _, method in ipairs({"GetChampionPointsRequirement", "GetChampionPointRequirement", "GetMinimumChampionPoints"}) do
        if type(data[method]) == "function" then
            local ok,v=pcall(data[method],data); if ok and tonumber(v) then return tonumber(v) end
        end
    end
    return 0
end

function D:IsLastBossListing(data) return isLastBossListing(data) end

function D:BuildLiveView()
    local raw = self:GetLiveResults()
    local results = {}
    local hideWTS = EPC.saved and EPC.saved.groupFinderWidgetHideWTS ~= false
    local hideHighCP = EPC.saved and EPC.saved.groupFinderWidgetHideHighCP == true
    local playerCP = 0
    if type(GetUnitChampionPoints) == "function" then local ok,v=pcall(GetUnitChampionPoints,"player"); if ok then playerCP=tonumber(v) or 0 end end
    local category = self:GetLiveCategory()
    local customCategory = rawget(_G, "GROUP_FINDER_CATEGORY_CUSTOM")
    for _,data in ipairs(raw) do
        local include = true
        if hideWTS and category ~= customCategory and looksLikeWTS(data) then include=false end
        if include and hideHighCP then
            local req=requiredCP(data); if req > 0 and playerCP < req then include=false end
        end
        if include then results[#results+1]=data end
    end
    self._filteredLiveResults = results
    local count = #results
    local pages = math.max(1, math.ceil(count / self.PAGE_SIZE))
    self.livePage = math.max(1, math.min(pages, tonumber(self.livePage) or 1))
    local first = (self.livePage-1) * self.PAGE_SIZE + 1
    local rows = {}
    for i=first, math.min(count, first+self.PAGE_SIZE-1) do
        local data = results[i]
        local title, description, owner = liveListingText(data)
        local autoAccept, activeApplication, joinability = false, false, nil
        if data then
            if type(data.DoesGroupAutoAcceptRequests) == "function" then local ok,v=pcall(data.DoesGroupAutoAcceptRequests,data); if ok then autoAccept=v==true end end
            if type(data.IsActiveApplication) == "function" then local ok,v=pcall(data.IsActiveApplication,data); if ok then activeApplication=v==true end end
            if type(data.GetJoinabilityResult) == "function" then local ok,v=pcall(data.GetJoinabilityResult,data); if ok then joinability=v end end
        end
        rows[#rows+1] = {data=data,title=title,owner=owner,description=description,roles=liveRoleSummary(data),autoAccept=autoAccept,activeApplication=activeApplication,joinability=joinability,absoluteIndex=i,lastBoss=(EPC.saved and EPC.saved.groupFinderWidgetLastBossHighlight == true and isLastBossListing(data)) or false,requiredCP=requiredCP(data)}
    end
    local state = nil
    if type(GROUP_FINDER_SEARCH_MANAGER) == "table" and type(GROUP_FINDER_SEARCH_MANAGER.GetSearchState) == "function" then
        local ok, v = pcall(GROUP_FINDER_SEARCH_MANAGER.GetSearchState, GROUP_FINDER_SEARCH_MANAGER)
        if ok then state = v end
    end
    local selected = self:GetSelectedLive()
    return {
        viewMode="LIVE", rows=rows, total=count, rawTotal=#raw, page=self.livePage, pageCount=pages,
        selected=selected, category=category, categoryName=getLiveCategoryName(category),
        difficulty=self.liveDifficulty, searchState=state,
    }
end

function D:ApplySelectedLive()
    local data = self:GetSelectedLive()
    if not data then message("Select a live Group Finder listing first."); return false end
    local joinability = nil
    if type(data.GetJoinabilityResult) == "function" then local ok,v=pcall(data.GetJoinabilityResult,data); if ok then joinability=v end end
    local success = GROUP_FINDER_ACTION_RESULT_SUCCESS
    local entitlement = GROUP_FINDER_ACTION_RESULT_FAILED_ENTITLEMENT_REQUIREMENT
    if joinability ~= nil and joinability ~= success and joinability ~= entitlement then
        message("That listing is not currently joinable.")
        return false
    end
    if type(ZO_Dialogs_ShowPlatformDialog) == "function" then
        local ok = pcall(ZO_Dialogs_ShowPlatformDialog, "GROUP_FINDER_APPLICATION_KEYBOARD", data)
        if ok then return true end
    end
    if type(data.GetListingIndex) == "function" and type(RequestApplyToGroupListing) == "function" then
        local okIndex, index = pcall(data.GetListingIndex, data)
        if okIndex and index then
            local ok = pcall(RequestApplyToGroupListing, index, "")
            if ok then return true end
        end
    end
    message("ESO could not open the application dialog for that listing.")
    return false
end

function D:WhisperSelectedLive()
    local data = self:GetSelectedLive()
    if not data or type(data.GetOwnerDisplayName) ~= "function" then message("Select a live listing first."); return false end
    local ok, owner = pcall(data.GetOwnerDisplayName, data)
    if not ok or not owner or owner == "" then message("Listing owner is unavailable."); return false end
    if type(StartChatInput) == "function" then
        StartChatInput("/w " .. tostring(owner) .. " ")
        return true
    end
    return false
end

function D:RescindLiveApplication()
    if type(RequestResolveGroupListingApplication) ~= "function" or RESOLVE_GROUP_LISTING_APPLICATION_REQUEST_RESCIND == nil then
        message("ESO cannot rescind the application on this client.")
        return false
    end
    local ok = pcall(RequestResolveGroupListingApplication, RESOLVE_GROUP_LISTING_APPLICATION_REQUEST_RESCIND)
    if ok then message("Group Finder application rescind requested.") end
    return ok
end

local easOldDungeonInitialize02528 = D.Initialize
function D:Initialize()
    if easOldDungeonInitialize02528 then easOldDungeonInitialize02528(self) end
    if self._liveCallbacksRegistered then return end
    if type(GROUP_FINDER_SEARCH_MANAGER) == "table" and type(GROUP_FINDER_SEARCH_MANAGER.RegisterCallback) == "function" then
        local function refreshCodex()
            self.liveSearchPending = false
            if self.viewMode == "LIVE" and EPC.Journal and EPC.Journal.activeTab == "GROUPFINDER" and EPC.Journal.RefreshSuitePage then
                EPC.Journal:RefreshSuitePage("GROUPFINDER")
            end
        end
        GROUP_FINDER_SEARCH_MANAGER:RegisterCallback("OnGroupFinderSearchResultsReady", refreshCodex)
        GROUP_FINDER_SEARCH_MANAGER:RegisterCallback("OnGroupFinderSearchResultsUpdated", refreshCodex)
        GROUP_FINDER_SEARCH_MANAGER:RegisterCallback("OnSearchStateChanged", refreshCodex)
        self._liveCallbacksRegistered = true
    end
end


-- v0.25.29: Direct completion/update listeners keep the standalone Group Finder tab in sync.
if EVENT_MANAGER and EVENT_GROUP_FINDER_SEARCH_COMPLETE then
    EVENT_MANAGER:RegisterForEvent("ESOAdventurerSuite_GroupFinder_SearchComplete", EVENT_GROUP_FINDER_SEARCH_COMPLETE, function(_, result, searchId)
        if D.viewMode ~= "LIVE" then return end
        if D.liveSearchId ~= nil and searchId ~= D.liveSearchId then return end
        D.liveSearchPending = false
        if type(GROUP_FINDER_SEARCH_MANAGER) == "table" and type(GROUP_FINDER_SEARCH_MANAGER.RefreshSearchResults) == "function" then
            pcall(GROUP_FINDER_SEARCH_MANAGER.RefreshSearchResults, GROUP_FINDER_SEARCH_MANAGER)
        end
        if EPC.Journal and EPC.Journal.activeTab == "GROUPFINDER" and EPC.Journal.RefreshSuitePage then EPC.Journal:RefreshSuitePage("GROUPFINDER") end
    end)
end
if EVENT_MANAGER and EVENT_GROUP_FINDER_SEARCH_UPDATED then
    EVENT_MANAGER:RegisterForEvent("ESOAdventurerSuite_GroupFinder_SearchUpdated", EVENT_GROUP_FINDER_SEARCH_UPDATED, function(_, searchId)
        if D.viewMode ~= "LIVE" then return end
        if D.liveSearchId ~= nil and searchId ~= D.liveSearchId then return end
        if type(GROUP_FINDER_SEARCH_MANAGER) == "table" and type(GROUP_FINDER_SEARCH_MANAGER.RefreshSearchResults) == "function" then
            pcall(GROUP_FINDER_SEARCH_MANAGER.RefreshSearchResults, GROUP_FINDER_SEARCH_MANAGER)
        end
        if EPC.Journal and EPC.Journal.activeTab == "GROUPFINDER" and EPC.Journal.RefreshSuitePage then EPC.Journal:RefreshSuitePage("GROUPFINDER") end
    end)
end

-- Group Finder social sources: public listings and guild roster members only.
-- ESOUI policy hardening: do not build or retain a roster of arbitrary non-grouped nearby players.
D.socialMode = D.socialMode or "PUBLIC"
D.socialPage = D.socialPage or 1
D.socialSelectedKey = D.socialSelectedKey or nil
D.SOCIAL_PAGE_SIZE = 10

local function easCleanSocialText(value, fallback)
    local text = tostring(value or "")
    if text == "" then return fallback or "" end
    if type(zo_strformat) == "function" then
        local ok, formatted = pcall(zo_strformat, "<<C:1>>", text)
        if ok and formatted and formatted ~= "" then text = formatted end
    end
    return text
end

local function easNowSeconds()
    if type(GetTimeStamp) == "function" then
        local ok, value = pcall(GetTimeStamp)
        if ok and tonumber(value) then return tonumber(value) end
    end
    return 0
end

local function easIsOnlineGuildStatus(playerStatus, secsSinceLogoff)
    if PLAYER_STATUS_OFFLINE ~= nil and playerStatus == PLAYER_STATUS_OFFLINE then return false end
    if tonumber(secsSinceLogoff) and tonumber(secsSinceLogoff) > 0 then return false end
    return true
end

local function easAlreadyInPlayersGroup(displayName)
    if displayName == nil or displayName == "" or type(IsPlayerInGroup) ~= "function" then return false end
    local ok, grouped = pcall(IsPlayerInGroup, displayName)
    return ok and grouped == true
end

function D:SetSocialMode(mode)
    mode = tostring(mode or "PUBLIC")
    if mode ~= "PUBLIC" and mode ~= "GUILD" then mode = "PUBLIC" end
    self.socialMode = mode
    self.socialPage = 1
    self.socialSelectedKey = nil
    if mode == "PUBLIC" then
        self:SetViewMode("LIVE")
        self:RefreshLiveListings(true)
    end
end

function D:CycleSocialMode()
    local order = {"PUBLIC", "GUILD"}
    local current = tostring(self.socialMode or "PUBLIC")
    for i, value in ipairs(order) do
        if value == current then
            self:SetSocialMode(order[(i % #order) + 1])
            return
        end
    end
    self:SetSocialMode("PUBLIC")
end

function D:GetGuildPartyCandidates()
    local entries, seen = {}, {}
    local ownDisplay = type(GetDisplayName) == "function" and tostring(GetDisplayName() or "") or ""
    local guildCount = 0
    if type(GetNumGuilds) == "function" then local ok,v=pcall(GetNumGuilds); if ok then guildCount=tonumber(v) or 0 end end

    for guildIndex=1,guildCount do
        local okId, guildId = pcall(GetGuildId, guildIndex)
        if okId and guildId then
            local guildName = "Guild"
            if type(GetGuildName) == "function" then local ok,v=pcall(GetGuildName,guildId); if ok and v and v~="" then guildName=easCleanSocialText(v,guildName) end end
            local memberCount = 0
            if type(GetNumGuildMembers) == "function" then local ok,v=pcall(GetNumGuildMembers,guildId); if ok then memberCount=tonumber(v) or 0 end end
            for memberIndex=1,memberCount do
                if type(GetGuildMemberInfo) == "function" then
                    local okInfo, displayName, _, _, playerStatus, secsSinceLogoff = pcall(GetGuildMemberInfo, guildId, memberIndex)
                    displayName = easCleanSocialText(displayName, "")
                    local key = string.lower(displayName)
                    if okInfo and displayName ~= "" and displayName ~= ownDisplay and not seen[key] and easIsOnlineGuildStatus(playerStatus, secsSinceLogoff) then
                        local characterName, zoneName, level, championPoints = displayName, "Online", 0, 0
                        if type(GetGuildMemberCharacterInfo) == "function" then
                            local okChar, hasCharacter, charName, zone, _, _, charLevel, cp = pcall(GetGuildMemberCharacterInfo, guildId, memberIndex)
                            if okChar and hasCharacter then
                                characterName = easCleanSocialText(charName, displayName)
                                zoneName = easCleanSocialText(zone, "Online")
                                level = tonumber(charLevel) or 0
                                championPoints = tonumber(cp) or 0
                            end
                        end
                        seen[key] = true
                        entries[#entries+1] = {
                            key = "G:" .. key,
                            kind = "GUILD",
                            displayName = displayName,
                            characterName = characterName,
                            guildName = guildName,
                            zoneName = zoneName,
                            level = level,
                            championPoints = championPoints,
                            inYourGroup = easAlreadyInPlayersGroup(displayName),
                        }
                    end
                end
            end
        end
    end
    table.sort(entries, function(a,b)
        local ag = a.inYourGroup == true and 1 or 0
        local bg = b.inYourGroup == true and 1 or 0
        if ag ~= bg then return ag < bg end
        return string.lower(a.displayName or "") < string.lower(b.displayName or "")
    end)
    return entries
end

function D:BuildSocialView()
    local mode = tostring(self.socialMode or "PUBLIC")
    if mode == "PUBLIC" then return self:BuildLiveView() end
    if mode ~= "GUILD" then mode = "PUBLIC" self.socialMode = "PUBLIC" return self:BuildLiveView() end
    local all = self:GetGuildPartyCandidates()
    local pageSize = tonumber(self.SOCIAL_PAGE_SIZE) or 10
    local pages = math.max(1, math.ceil(#all / pageSize))
    self.socialPage = math.max(1, math.min(pages, tonumber(self.socialPage) or 1))
    local first = (self.socialPage - 1) * pageSize + 1
    local rows = {}
    for i=first, math.min(#all, first + pageSize - 1) do rows[#rows+1] = all[i] end
    local selected = nil
    for _,entry in ipairs(all) do if entry.key == self.socialSelectedKey then selected = entry break end end
    return {mode=mode, rows=rows, total=#all, page=self.socialPage, pageCount=pages, selected=selected}
end

function D:ChangeSocialPage(delta)
    self.socialPage = math.max(1, (tonumber(self.socialPage) or 1) + (tonumber(delta) or 0))
end

function D:SelectSocialRow(row)
    local view = self:BuildSocialView()
    local entry = view.rows and view.rows[tonumber(row) or 0]
    if entry then self.socialSelectedKey = entry.key end
end

function D:GetSelectedSocial()
    local view = self:BuildSocialView()
    return view.selected
end

function D:InviteSelectedSocial()
    local selected = self:GetSelectedSocial()
    if not selected or not selected.displayName then message("Select a guild member first."); return false end
    if easAlreadyInPlayersGroup(selected.displayName) then message(tostring(selected.displayName) .. " is already in your group."); return false end
    if type(TryGroupInviteByName) == "function" then
        local ok = pcall(TryGroupInviteByName, selected.displayName, false, true)
        return ok
    elseif type(GroupInviteByName) == "function" then
        local ok = pcall(GroupInviteByName, selected.displayName)
        if ok then message("Group invite sent to " .. tostring(selected.displayName) .. ".") end
        return ok
    end
    message("ESO group invite API is unavailable on this client.")
    return false
end

function D:WhisperSelectedSocial()
    local selected = self:GetSelectedSocial()
    if not selected or not selected.displayName then message("Select a guild member first."); return false end
    if type(StartChatInput) == "function" then
        StartChatInput("/w " .. tostring(selected.displayName) .. " ")
        return true
    end
    return false
end

-- No EVENT_RETICLE_TARGET_CHANGED registration: the public build does not collect arbitrary nearby players.


-- v0.25.42: live Group Finder tracking parity improvements.
-- Original implementation for ESO Adventurer Suite; follows ESO's native
-- Group Finder search/result APIs without copying third-party addon code.
local easOldSetViewMode02542 = D.SetViewMode
local easOldSetLiveDifficulty02542 = D.SetLiveDifficulty
local easOldCycleLiveCategory02542 = D.CycleLiveCategory
local easOldBuildLiveView02542 = D.BuildLiveView

local function easGfSupportsDifficulty(category)
    return category == GROUP_FINDER_CATEGORY_DUNGEON
        or category == GROUP_FINDER_CATEGORY_TRIAL
        or category == GROUP_FINDER_CATEGORY_ARENA
end

function D:LiveCategorySupportsDifficulty(category)
    return easGfSupportsDifficulty(category or self:GetLiveCategory())
end

function D:SetViewMode(mode)
    mode = tostring(mode or "DUNGEONS"):upper()
    if mode == "LIVE" and not self._easDifficultyInitialized02542 then
        local saved = EPC.saved and EPC.saved.groupFinderWidgetDifficulty or nil
        saved = tostring(saved or "NORMAL"):upper()
        if saved ~= "VETERAN" then saved = "NORMAL" end
        self.liveDifficulty = saved
        self._easDifficultyInitialized02542 = true
    end
    return easOldSetViewMode02542(self, mode)
end

function D:SetLiveDifficulty(value)
    if not self:LiveCategorySupportsDifficulty() then return false end
    value = tostring(value or "NORMAL"):upper()
    if value ~= "VETERAN" then value = "NORMAL" end
    if EPC.saved then EPC.saved.groupFinderWidgetDifficulty = value end
    self._filteredLiveResults = {}
    self.liveSearchPending = true
    return easOldSetLiveDifficulty02542(self, value)
end

function D:ToggleLiveDifficulty()
    if not self:LiveCategorySupportsDifficulty() then return false end
    local current = tostring(self.liveDifficulty or "NORMAL"):upper()
    return self:SetLiveDifficulty(current == "VETERAN" and "NORMAL" or "VETERAN")
end

function D:CycleLiveCategory()
    self._filteredLiveResults = {}
    self.liveSearchPending = true
    local result = easOldCycleLiveCategory02542(self)
    if EPC.saved then EPC.saved.groupFinderWidgetCategory = self.liveCategory end
    return result
end

local EAS_GF_SHORT_CODES_02542 = {
    ["cloudrest"] = "CR",
    ["scalecaller peak"] = "SCP",
    ["aetherian archive"] = "AA",
    ["hel ra citadel"] = "HRC",
    ["sanctum ophidia"] = "SO",
    ["maw of lorkhaj"] = "MOL",
    ["halls of fabrication"] = "HOF",
    ["asylum sanctorium"] = "AS",
    ["sunspire"] = "SS",
    ["kyne's aegis"] = "KA",
    ["kynes aegis"] = "KA",
    ["rockgrove"] = "RG",
    ["dreadsail reef"] = "DSR",
    ["sanity's edge"] = "SE",
    ["sanitys edge"] = "SE",
    ["lucent citadel"] = "LC",
    ["ossein cage"] = "OC",
    ["dragonstar arena"] = "DSA",
    ["maelstrom arena"] = "MA",
    ["blackrose prison"] = "BRP",
    ["vatashran hollows"] = "VH",
    ["vateshran hollows"] = "VH",
    ["white-gold tower"] = "WGT",
    ["white gold tower"] = "WGT",
    ["imperial city prison"] = "ICP",
    ["ruins of mazzatun"] = "ROM",
    ["cradle of shadows"] = "COS",
    ["bloodroot forge"] = "BF",
    ["falkreath hold"] = "FH",
    ["fang lair"] = "FL",
    ["scalecaller peak"] = "SCP",
    ["moon hunter keep"] = "MHK",
    ["march of sacrifices"] = "MOS",
    ["depths of malatar"] = "DOM",
    ["frostvault"] = "FV",
    ["lair of maarselok"] = "LOM",
    ["moongrave fane"] = "MGF",
    ["icereach"] = "IR",
    ["unhallowed grave"] = "UG",
    ["stone garden"] = "SG",
    ["castle thorn"] = "CT",
    ["black drake villa"] = "BDV",
    ["the cauldron"] = "TC",
    ["red petal bastion"] = "RPB",
    ["the dread cellar"] = "TDC",
    ["coral aerie"] = "CA",
    ["shipwright's regret"] = "SR",
    ["shipwrights regret"] = "SR",
    ["earthen root enclave"] = "ERE",
    ["graven deep"] = "GD",
    ["bal sunnar"] = "BS",
    ["scrivener's hall"] = "SH",
    ["scriveners hall"] = "SH",
    ["bedlam veil"] = "BV",
    ["oathsworn pit"] = "OP",
    ["exiled redoubt"] = "ER",
    ["lep seclusa"] = "LS",
}

local function easGfListingTargetText(data)
    if not data then return "" end
    local category = nil
    if type(data.GetCategory) == "function" then
        local ok, value = pcall(data.GetCategory, data)
        if ok then category = value end
    end
    if category == GROUP_FINDER_CATEGORY_ENDLESS_DUNGEON
        or category == GROUP_FINDER_CATEGORY_ADVENTURE_ZONE
        or category == GROUP_FINDER_CATEGORY_ZONE
        or category == GROUP_FINDER_CATEGORY_CUSTOM
        or category == GROUP_FINDER_CATEGORY_PVP then
        return ""
    end
    for _, method in ipairs({"GetSecondaryOptionText", "GetActivityName", "GetTargetName"}) do
        if type(data[method]) == "function" then
            local ok, value = pcall(data[method], data)
            if ok and value and tostring(value) ~= "" then return cleanName(value) end
        end
    end
    return ""
end

local function easGfMakeFallbackCode(name)
    name = tostring(name or "")
    local words = {}
    for word in string.gmatch(name, "[%a']+") do
        local lower = string.lower(word)
        if lower ~= "of" and lower ~= "the" and lower ~= "and" then words[#words+1] = word end
    end
    if #words == 0 then return "" end
    if #words == 1 then
        local raw = string.upper(words[1])
        return string.sub(raw, 1, math.min(2, #raw))
    end
    local out = ""
    for _, word in ipairs(words) do
        out = out .. string.upper(string.sub(word, 1, 1))
        if #out >= 4 then break end
    end
    return out
end

function D:GetListingShortCode(data)
    local target = easGfListingTargetText(data)
    if target == "" then return "" end
    local normalized = string.lower(target):gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    normalized = normalized:gsub("^%s+", ""):gsub("%s+$", "")
    for fullName, code in pairs(EAS_GF_SHORT_CODES_02542) do
        if string.find(normalized, fullName, 1, true) then return code end
    end
    return easGfMakeFallbackCode(target)
end

function D:GetActualRoleSummary(data)
    if not data or type(data.GetRoleStatusCount) ~= "function" then return "ROLES: ANY" end
    local parts = {}
    local anyData = false
    local roles = {
        {LFG_ROLE_TANK, "T"},
        {LFG_ROLE_HEAL, "H"},
        {LFG_ROLE_DPS, "D"},
    }
    for _, entry in ipairs(roles) do
        if entry[1] ~= nil then
            local ok, desired, attained = pcall(data.GetRoleStatusCount, data, entry[1])
            if ok then
                desired = tonumber(desired) or 0
                attained = tonumber(attained) or 0
                if desired > 0 or attained > 0 then
                    anyData = true
                    parts[#parts+1] = string.format("%s %d/%d", entry[2], attained, desired)
                end
            end
        end
    end
    if not anyData then return "ROLES: ANY" end
    return "ROLES: " .. table.concat(parts, "  ")
end

function D:BuildLiveView()
    local view = easOldBuildLiveView02542(self)
    if self.liveSearchPending then
        view.rows = {}
        view.total = 0
        view.page = 1
        view.pageCount = 1
        view.selected = nil
        return view
    end
    for _, row in ipairs(view.rows or {}) do
        row.shortCode = self:GetListingShortCode(row.data)
        row.roles = self:GetActualRoleSummary(row.data)
        if row.data and type(row.data.GetSecondaryOptionText) == "function" then
            local ok, value = pcall(row.data.GetSecondaryOptionText, row.data)
            if ok and value then row.instanceName = cleanName(value) end
        end
    end
    return view
end

function ESOAdventurerSuite_GroupFinderNextCategory()
    if not D then return end
    if D.socialMode ~= "PUBLIC" then D:SetSocialMode("PUBLIC") end
    D:CycleLiveCategory()
    if EPC.Journal and EPC.Journal.activeTab == "GROUPFINDER" and EPC.Journal.RefreshSuitePage then
        EPC.Journal:RefreshSuitePage("GROUPFINDER")
    end
end

function ESOAdventurerSuite_GroupFinderToggleDifficulty()
    if not D or not D:LiveCategorySupportsDifficulty() then return end
    if D.socialMode ~= "PUBLIC" then D:SetSocialMode("PUBLIC") end
    D:ToggleLiveDifficulty()
    if EPC.Journal and EPC.Journal.activeTab == "GROUPFINDER" and EPC.Journal.RefreshSuitePage then
        EPC.Journal:RefreshSuitePage("GROUPFINDER")
    end
end

-- v0.25.42 hotfix: keep first-search loading state independent from ESO's
-- generic search-state callback, which can fire before results are ready.
local easOldRefreshLiveListings02542 = D.RefreshLiveListings
local easOldBuildLiveView02542b = D.BuildLiveView
local easOldInitialize02542b = D.Initialize

function D:RefreshLiveListings(force)
    self.liveAwaitingResults02542 = true
    self._filteredLiveResults = {}
    local ok = easOldRefreshLiveListings02542(self, force)
    if ok == false then self.liveAwaitingResults02542 = false end
    return ok
end

function D:BuildLiveView()
    local view = easOldBuildLiveView02542b(self)
    if self.liveAwaitingResults02542 then
        view.rows = {}
        view.total = 0
        view.page = 1
        view.pageCount = 1
        view.selected = nil
    end
    return view
end

function D:Initialize()
    if easOldInitialize02542b then easOldInitialize02542b(self) end
    if self._easLiveReadyCallbacks02542 then return end
    local function markReady()
        self.liveAwaitingResults02542 = false
        if self.viewMode == "LIVE" and EPC.Journal and EPC.Journal.activeTab == "GROUPFINDER" and EPC.Journal.RefreshSuitePage then
            EPC.Journal:RefreshSuitePage("GROUPFINDER")
        end
    end
    if type(GROUP_FINDER_SEARCH_MANAGER) == "table" and type(GROUP_FINDER_SEARCH_MANAGER.RegisterCallback) == "function" then
        GROUP_FINDER_SEARCH_MANAGER:RegisterCallback("OnGroupFinderSearchResultsReady", markReady)
        GROUP_FINDER_SEARCH_MANAGER:RegisterCallback("OnGroupFinderSearchResultsUpdated", markReady)
    end
    if EVENT_MANAGER and EVENT_GROUP_FINDER_SEARCH_COMPLETE then
        EVENT_MANAGER:RegisterForEvent("ESOAdventurerSuite_GroupFinderReady02542", EVENT_GROUP_FINDER_SEARCH_COMPLETE, function()
            markReady()
        end)
    end
    self._easLiveReadyCallbacks02542 = true
end

-- v0.27.79 - Current ESO random dungeon queue support.
-- Current ESO clients expose Random Dungeon as an Activity Finder SET rather
-- than through the retired AddActivityFinderRandomSearchEntry API.
local function easFindRandomDungeonSet(activityType)
    if type(GetNumActivitySetsByType) ~= "function"
        or type(GetActivitySetIdByTypeAndIndex) ~= "function" then
        return nil
    end

    local okCount, count = pcall(GetNumActivitySetsByType, activityType)
    if not okCount then return nil end

    local fallbackId
    for index = 1, tonumber(count) or 0 do
        local okId, setId = pcall(GetActivitySetIdByTypeAndIndex, activityType, index)
        if okId and setId and setId ~= 0 then
            fallbackId = fallbackId or setId
            -- The Random Dungeon set is the dungeon set that carries reward data.
            if type(DoesActivitySetHaveRewardData) == "function" then
                local okReward, hasReward = pcall(DoesActivitySetHaveRewardData, setId)
                if okReward and hasReward then
                    return setId
                end
            end
        end
    end
    return fallbackId
end

local function easQueueResultAccepted(result)
    if result == nil then return false end
    return result == ACTIVITY_QUEUE_RESULT_SUCCESS
        or result == ACTIVITY_QUEUE_RESULT_REQUEST_QUEUED
        or result == ACTIVITY_QUEUE_RESULT_NEW_SEARCH_INITIATED
end

local function easQueueResultText(result)
    if type(GetString) == "function" and result ~= nil then
        local ok, text = pcall(GetString, "SI_ACTIVITYQUEUERESULT", result)
        if ok and text and text ~= "" then return text end
    end
    return "Activity Finder result " .. tostring(result)
end

function D:QueueRandom(difficulty)
    difficulty = tostring(difficulty or self.difficulty or "NORMAL"):upper()
    self:SetDifficulty(difficulty)

    if self:IsQueued() then
        message("You are already in an Activity Finder queue.")
        return false
    end

    if type(UpdateSelectedLFGRole) == "function" then
        pcall(UpdateSelectedLFGRole, self:GetRoleConstant())
    end

    -- Match ESO's normal/veteran state before building the request.
    if type(SetVeteranDifficulty) == "function" then
        local isVeteran = self.difficulty == "VETERAN"
        pcall(SetVeteranDifficulty, isVeteran)
    end

    if type(ClearActivityFinderSearch) ~= "function"
        or type(StartActivityFinderSearch) ~= "function" then
        message("ESO Activity Finder API is unavailable on this client.")
        return false
    end

    local activityType = self.difficulty == "VETERAN"
        and LFG_ACTIVITY_MASTER_DUNGEON
        or LFG_ACTIVITY_DUNGEON

    if activityType == nil then
        message("ESO random dungeon activity type is unavailable on this client.")
        return false
    end

    pcall(ClearActivityFinderSearch)

    local added = false

    -- Current API (Update 47 / API 101050+): random queues are activity sets.
    if type(AddActivityFinderSetSearchEntry) == "function" then
        local setId = easFindRandomDungeonSet(activityType)
        if setId then
            local okAdd = pcall(AddActivityFinderSetSearchEntry, setId)
            added = okAdd == true
        end
    end

    -- Compatibility fallback for older clients that still expose this call.
    if not added and type(AddActivityFinderRandomSearchEntry) == "function" then
        local okAdd = pcall(AddActivityFinderRandomSearchEntry, activityType)
        added = okAdd == true
    end

    if not added then
        message("Could not add Random Dungeon to Activity Finder.")
        return false
    end

    local ok, result = pcall(StartActivityFinderSearch)
    if not ok then
        message("ESO rejected the random dungeon queue request.")
        return false
    end

    if not easQueueResultAccepted(result) then
        message("Random dungeon queue failed: " .. easQueueResultText(result))
        return false, result
    end

    if EPC.DungeonHistory and EPC.DungeonHistory.RememberQueuedDifficulty then
        EPC.DungeonHistory:RememberQueuedDifficulty(self.difficulty)
    end
    message(string.format("Queued Random %s Dungeon [%s].", self.difficulty == "VETERAN" and "Veteran" or "Normal", self.role or "DPS"))
    return true, result
end

function D:IsDailyRandomRewardEligible()
    if type(IsEligibleForDailyActivityReward) == "function" then
        local ok, eligible = pcall(IsEligibleForDailyActivityReward)
        if ok then return eligible == true end
    end
    return nil
end

-- ============================================================================
-- v0.27.67 - Specific dungeon multi-select queue
-- Clicking dungeon rows toggles them in/out of a queue selection. ESO Activity
-- Finder accepts multiple specific search entries, so players can queue for any
-- chosen combination (one dungeon, three dungeons, etc.) in one request.
-- ============================================================================
D.multiSelected = D.multiSelected or {}

local function easDungeonSelectionKey2767(entry)
    if not entry then return nil end
    local key = norm(entry.name or "")
    if key == "" then key = tostring(entry.activityId or "") end
    return key ~= "" and key or nil
end

function D:IsEntrySelected(entry)
    local key = easDungeonSelectionKey2767(entry)
    return key ~= nil and self.multiSelected and self.multiSelected[key] == true
end

function D:GetMultiSelectedEntries()
    local out = {}
    for _, entry in ipairs(self.entries or {}) do
        if self:IsEntrySelected(entry) then out[#out + 1] = entry end
    end
    return out
end

function D:GetMultiSelectedCount()
    return #self:GetMultiSelectedEntries()
end

function D:ClearMultiSelection()
    self.multiSelected = {}
end

function D:SelectRow(row)
    local idx = ((tonumber(self.page) or 1)-1) * self.PAGE_SIZE + (tonumber(row) or 1)
    local entry = self.entries and self.entries[idx]
    if not entry then return end
    self.selectedIndex = idx -- keep a focused row for details / host listing
    self.multiSelected = self.multiSelected or {}
    local key = easDungeonSelectionKey2767(entry)
    if key then self.multiSelected[key] = not (self.multiSelected[key] == true) end
end

function D:QueueSelected()
    local selectedEntries = self:GetMultiSelectedEntries()
    local focused = self:GetSelected()

    -- Backward compatibility: if nothing has been toggled yet, queue the focused
    -- dungeon as a single specific selection.
    if #selectedEntries == 0 and focused then selectedEntries[1] = focused end
    if #selectedEntries == 0 then message("Select one or more dungeons first."); return false end
    if self:IsQueued() then message("You are already in an Activity Finder queue."); return false end

    if type(UpdateSelectedLFGRole) == "function" then
        pcall(UpdateSelectedLFGRole, self:GetRoleConstant())
    end
    if type(SetVeteranDifficulty) == "function" then
        pcall(SetVeteranDifficulty, self.difficulty == "VETERAN")
    end
    if type(ClearActivityFinderSearch) ~= "function"
        or type(AddActivityFinderSpecificSearchEntry) ~= "function"
        or type(StartActivityFinderSearch) ~= "function" then
        message("ESO Activity Finder API is unavailable on this client.")
        return false
    end

    pcall(ClearActivityFinderSearch)
    local added, skipped = 0, 0
    for _, entry in ipairs(selectedEntries) do
        local activityId
        if self.difficulty == "VETERAN" then
            activityId = entry.veteranActivityId
        else
            activityId = entry.normalActivityId
        end
        -- Some ESO clients expose only a generic activity id. Use it only when
        -- there is no explicit mode-specific mapping at all.
        if not activityId and not entry.normalActivityId and not entry.veteranActivityId then
            activityId = entry.activityId
        end
        if activityId then
            local okAdd = pcall(AddActivityFinderSpecificSearchEntry, activityId)
            if okAdd then added = added + 1 else skipped = skipped + 1 end
        else
            skipped = skipped + 1
        end
    end

    if added == 0 then
        message(string.format("None of the selected dungeons are available in %s mode.", self.difficulty))
        return false
    end

    local ok, result = pcall(StartActivityFinderSearch)
    if ok then
        if EPC.DungeonHistory and EPC.DungeonHistory.RememberQueuedDifficulty then
            EPC.DungeonHistory:RememberQueuedDifficulty(self.difficulty)
        end
        local suffix = skipped > 0 and string.format(" (%d unavailable skipped)", skipped) or ""
        message(string.format("Queue requested: %d selected dungeon%s [%s / %s]%s", added, added == 1 and "" or "s", self.difficulty, self.role, suffix))
        return true, result
    end

    message("ESO rejected the selected dungeon queue request.")
    return false
end

-- v0.27.69 - ESO-styled movable and resizable dungeon queue HUD.
-- Replaces the passive ESO Activity Finder queue indicator while deliberately
-- leaving ESO's ready-check dialog intact so ACCEPT / DECLINE remains usable.
local QUEUE_HUD_DEFAULT_LEFT = 1480
local QUEUE_HUD_DEFAULT_TOP = 250
local QUEUE_HUD_DEFAULT_WIDTH = 360
local QUEUE_HUD_DEFAULT_HEIGHT = 128
local QUEUE_HUD_MIN_WIDTH = 300
local QUEUE_HUD_MIN_HEIGHT = 118
local QUEUE_HUD_MAX_WIDTH = 720
local QUEUE_HUD_MAX_HEIGHT = 300

local function easQueueStatusText2768(status)
    if ACTIVITY_FINDER_STATUS_READY_CHECK ~= nil and status == ACTIVITY_FINDER_STATUS_READY_CHECK then return "DUNGEON FOUND" end
    if ACTIVITY_FINDER_STATUS_QUEUED ~= nil and status == ACTIVITY_FINDER_STATUS_QUEUED then return "SEARCHING" end
    if ACTIVITY_FINDER_STATUS_IN_PROGRESS ~= nil and status == ACTIVITY_FINDER_STATUS_IN_PROGRESS then return "IN DUNGEON" end
    return "NOT QUEUED"
end

local function easQueueIsActive2768(status)
    return (ACTIVITY_FINDER_STATUS_QUEUED ~= nil and status == ACTIVITY_FINDER_STATUS_QUEUED)
        or (ACTIVITY_FINDER_STATUS_READY_CHECK ~= nil and status == ACTIVITY_FINDER_STATUS_READY_CHECK)
end

-- v0.27.70 - Hide ESO's passive Activity Finder queue HUD completely.
-- ESO has used several different global/control names across UI revisions, so we
-- keep an explicit list and also discover queue/status controls once at runtime.
-- The secure ready-check dialog is deliberately excluded.
local EAS_NATIVE_QUEUE_HUD_NAMES_2770 = {
    "ZO_ActivityFinderStatus",
    "ZO_ActivityFinderStatus_Keyboard",
    "ZO_ActivityFinderQueueStatus",
    "ZO_ActivityFinderQueueStatus_Keyboard",
    "ZO_LFG_ActivityFinderStatus",
    "ZO_LFG_ActivityFinderStatus_Keyboard",
    "ZO_LFG_QueueStatus",
    "ZO_LFG_QueueStatus_Keyboard",
    "ZO_LFGQueueStatus",
    "ZO_LFGQueueStatus_Keyboard",
    "ZO_LFG_Status",
    "ZO_LFG_Status_Keyboard",
    "ZO_GroupFinderStatus",
    "ZO_GroupFinderStatus_Keyboard",
}

-- v0.27.73 - Safe native queue HUD lookup.
--
-- IMPORTANT: Do not enumerate _G or inspect arbitrary global values here. ESO
-- exposes private/protected C functions in the global environment; merely
-- indexing one of those values from insecure addon code can taint the callstack.
-- Only resolve the small allow-list of known UI control names, and only keep
-- actual userdata controls.
function D:DiscoverNativeQueueHud2770()
    if self.nativeQueueHudDiscoveryDone2770 then return end
    self.nativeQueueHudDiscoveryDone2770 = true
    self.nativeQueueHudControls2770 = self.nativeQueueHudControls2770 or {}
    local seen = {}

    local function remember(control)
        if type(control) == "userdata" and control ~= self.queueHud2768 and not seen[control] then
            seen[control] = true
            self.nativeQueueHudControls2770[#self.nativeQueueHudControls2770 + 1] = control
        end
    end

    -- First resolve only explicit, known global CONTROL names. rawget is used so
    -- no metatable lookup can touch ESO's private/protected API functions.
    for _, name in ipairs(EAS_NATIVE_QUEUE_HUD_NAMES_2770) do
        remember(rawget(_G, name))
    end

    -- v0.27.74: ESO's current queue widget name can vary by keyboard/gamepad/UI
    -- revision. Instead of scanning _G (unsafe), enumerate WINDOW_MANAGER's UI
    -- controls only. This cannot touch private C functions. We accept only names
    -- that clearly identify an Activity Finder/LFG queue/status control, and we
    -- deliberately exclude anything containing READY or CHECK so ESO's secure
    -- Accept / Decline ready-check remains available.
    local wm = WINDOW_MANAGER
    if wm and type(wm.GetNumControls) == "function" and type(wm.GetControlByIndex) == "function" then
        local okCount, count = pcall(wm.GetNumControls, wm)
        if okCount and type(count) == "number" then
            for i = 1, count do
                local okControl, control = pcall(wm.GetControlByIndex, wm, i)
                if okControl and type(control) == "userdata" and control ~= self.queueHud2768 then
                    local okName, controlName = pcall(control.GetName, control)
                    if okName and type(controlName) == "string" and controlName ~= "" then
                        local lowerName = string.lower(controlName)
                        local finderName = string.find(lowerName, "activityfinder", 1, true)
                            or string.find(lowerName, "lfg", 1, true)
                        local statusName = string.find(lowerName, "queue", 1, true)
                            or string.find(lowerName, "status", 1, true)
                        local readyName = string.find(lowerName, "ready", 1, true)
                            or string.find(lowerName, "check", 1, true)
                        local suiteName = string.find(lowerName, "eas_", 1, true)
                            or string.find(lowerName, "esoadventurersuite", 1, true)
                        if finderName and statusName and not readyName and not suiteName then
                            remember(control)
                        end
                    end
                end
            end
        end
    end
end

function D:SuppressNativeQueueHud2768()
    -- Suppress only ESO's passive queued/searching display. The required
    -- ACCEPT / DECLINE ready-check remains untouched.
    self:DiscoverNativeQueueHud2770()
    for _, control in ipairs(self.nativeQueueHudControls2770 or {}) do
        if control and control ~= self.queueHud2768 then
            pcall(control.SetHidden, control, true)
        end
    end
end

function D:CreateQueueHud2768()
    if self.queueHud2768 or not WINDOW_MANAGER then return self.queueHud2768 end
    local frame = WINDOW_MANAGER:CreateTopLevelWindow("EAS_DungeonQueueHUD2768")
    local savedWidth = EPC.saved and tonumber(EPC.saved.dungeonQueueHudWidth) or nil
    local savedHeight = EPC.saved and tonumber(EPC.saved.dungeonQueueHudHeight) or nil
    savedWidth = math.max(QUEUE_HUD_MIN_WIDTH, math.min(QUEUE_HUD_MAX_WIDTH, savedWidth or QUEUE_HUD_DEFAULT_WIDTH))
    savedHeight = math.max(QUEUE_HUD_MIN_HEIGHT, math.min(QUEUE_HUD_MAX_HEIGHT, savedHeight or QUEUE_HUD_DEFAULT_HEIGHT))
    frame:SetDimensions(savedWidth, savedHeight)
    if frame.SetDimensionConstraints then frame:SetDimensionConstraints(QUEUE_HUD_MIN_WIDTH, QUEUE_HUD_MIN_HEIGHT, QUEUE_HUD_MAX_WIDTH, QUEUE_HUD_MAX_HEIGHT) end
    if frame.SetResizeHandleSize then frame:SetResizeHandleSize(20) end
    frame:SetClampedToScreen(true)
    frame:SetMouseEnabled(true)
    frame:SetMovable(true)
    frame:SetHidden(true)
    if frame.SetDrawLayer then frame:SetDrawLayer(DL_OVERLAY) end
    if DT_HIGH ~= nil and frame.SetDrawTier then frame:SetDrawTier(DT_HIGH) end

    local left = EPC.saved and tonumber(EPC.saved.dungeonQueueHudLeft) or nil
    local top = EPC.saved and tonumber(EPC.saved.dungeonQueueHudTop) or nil
    if left == nil or left < 0 then left = QUEUE_HUD_DEFAULT_LEFT end
    if top == nil or top < 0 then top = QUEUE_HUD_DEFAULT_TOP end
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

    local bg = WINDOW_MANAGER:CreateControl("EAS_DungeonQueueHUDBG2768", frame, CT_BACKDROP)
    bg:SetAnchor(TOPLEFT, frame, TOPLEFT, 2, 2)
    bg:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -2, -2)
    bg:SetCenterColor(0.025, 0.022, 0.018, 0.92)
    bg:SetEdgeTexture(nil, 1, 1, 2)
    bg:SetEdgeColor(0.92, 0.72, 0.25, 0.95)

    local title = WINDOW_MANAGER:CreateControl("EAS_DungeonQueueHUDTitle2768", frame, CT_LABEL)
    title:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 9)
    title:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -12, 9)
    title:SetHeight(22)
    title:SetFont("ZoFontGameBold")
    title:SetColor(0.96, 0.80, 0.36, 1)
    title:SetText("DUNGEON FINDER")

    local status = WINDOW_MANAGER:CreateControl("EAS_DungeonQueueHUDStatus2768", frame, CT_LABEL)
    status:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 34)
    status:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -12, 34)
    status:SetHeight(24)
    status:SetFont("ZoFontGameBold")
    status:SetColor(0.96, 0.80, 0.36, 1)

    local details = WINDOW_MANAGER:CreateControl("EAS_DungeonQueueHUDDetails2768", frame, CT_LABEL)
    details:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 60)
    details:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -12, 60)
    details:SetHeight(22)
    details:SetFont("ZoFontGame")
    details:SetColor(0.92, 0.94, 0.97, 1)

    local selected = WINDOW_MANAGER:CreateControl("EAS_DungeonQueueHUDSelected2768", frame, CT_LABEL)
    selected:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 84)
    selected:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -12, 84)
    selected:SetHeight(20)
    selected:SetFont("ZoFontGameSmall")
    selected:SetColor(0.72, 0.78, 0.84, 1)

    local hint = WINDOW_MANAGER:CreateControl("EAS_DungeonQueueHUDHint2768", frame, CT_LABEL)
    hint:SetAnchor(BOTTOMLEFT, frame, BOTTOMLEFT, 12, -8)
    hint:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -12, -8)
    hint:SetHeight(16)
    hint:SetFont("ZoFontGameSmall")
    hint:SetColor(0.96, 0.80, 0.36, 1)
    hint:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    hint:SetText("DRAG TO MOVE - EDGES TO RESIZE")

    frame:SetHandler("OnMoveStop", function(control)
        if not EPC.saved then return end
        EPC.saved.dungeonQueueHudLeft = math.max(0, tonumber(control:GetLeft()) or 0)
        EPC.saved.dungeonQueueHudTop = math.max(0, tonumber(control:GetTop()) or 0)
    end)
    frame:SetHandler("OnResizeStop", function(control)
        if not EPC.saved then return end
        local w, h = control:GetDimensions()
        EPC.saved.dungeonQueueHudWidth = math.floor((tonumber(w) or QUEUE_HUD_DEFAULT_WIDTH) + 0.5)
        EPC.saved.dungeonQueueHudHeight = math.floor((tonumber(h) or QUEUE_HUD_DEFAULT_HEIGHT) + 0.5)
    end)

    self.queueHud2768 = frame
    self.queueHudStatus2768 = status
    self.queueHudDetails2768 = details
    self.queueHudSelected2768 = selected
    return frame
end

-- v0.27.71 - Resolve the actual Activity Finder match during the ready check.
-- This is important for multi-select queues: the matched activity may be only
-- one of several dungeons the player selected.
function D:GetMatchedDungeonName2771()
    if type(GetCurrentLFGActivityId) == "function" and type(GetActivityInfo) == "function" then
        local okId, activityId = pcall(GetCurrentLFGActivityId)
        activityId = okId and tonumber(activityId) or 0
        if activityId and activityId > 0 then
            local okInfo, name = pcall(GetActivityInfo, activityId)
            if okInfo and type(name) == "string" and name ~= "" then
                return name
            end
        end
    end

    -- Safe fallback for clients where the matched activity is not exposed yet.
    local list = self.GetMultiSelectedEntries and self:GetMultiSelectedEntries() or {}
    if #list == 1 and list[1] and list[1].name then
        return tostring(list[1].name)
    end
    local focused = self.GetSelected and self:GetSelected() or nil
    if focused and focused.name and #list <= 1 then
        return tostring(focused.name)
    end
    return "Matched dungeon"
end

function D:GetQueueSelectionSummary2768()
    local list = self.GetMultiSelectedEntries and self:GetMultiSelectedEntries() or {}
    if #list > 0 then
        if #list == 1 then return tostring(list[1].name or "1 selected dungeon") end
        return string.format("%d specific dungeons selected", #list)
    end
    local focused = self.GetSelected and self:GetSelected() or nil
    return focused and tostring(focused.name or "Selected dungeon") or "Dungeon queue"
end

-- v0.27.72 - Queue HUD is gameplay-only. Hide it while the Tamriel Codex
-- or an ESO menu (Inventory, Character, Map, etc.) owns the screen, then
-- restore it automatically when gameplay resumes if the queue is still active.
function D:IsQueueHudTemporarilySuppressed2772()
    local journal = EPC and EPC.Journal
    if journal and journal.window and type(journal.window.IsHidden) == "function" then
        local ok, hidden = pcall(journal.window.IsHidden, journal.window)
        if ok and hidden == false then return true end
    end

    if EPC and type(EPC.IsGameplayHudSuppressed) == "function" then
        local ok, suppressed = pcall(EPC.IsGameplayHudSuppressed, EPC)
        if ok and suppressed == true then return true end
    end
    return false
end

function D:SetLayoutMode(active)
    active = active == true
    self.queueHudLayoutMode2768 = active
    local frame = self:CreateQueueHud2768()
    if not frame then return end

    if active then
        frame:SetHidden(false)
        frame:SetMouseEnabled(true)
        frame:SetMovable(true)
        if frame.SetResizeHandleSize then frame:SetResizeHandleSize(20) end
        if self.queueHudStatus2768 then self.queueHudStatus2768:SetText("LAYOUT PREVIEW") end
        if self.queueHudDetails2768 then self.queueHudDetails2768:SetText("NORMAL  |  DPS") end
        if self.queueHudSelected2768 then self.queueHudSelected2768:SetText("DUNGEON QUEUE HUD") end
    else
        self:RefreshQueueHud2768()
    end
end

function D:RefreshQueueHud2768(status)
    local frame = self:CreateQueueHud2768()
    if not frame then return end
    if self.queueHudLayoutMode2768 == true then
        frame:SetHidden(false)
        if self.queueHudStatus2768 then self.queueHudStatus2768:SetText("LAYOUT PREVIEW") end
        if self.queueHudDetails2768 then self.queueHudDetails2768:SetText("NORMAL  |  DPS") end
        if self.queueHudSelected2768 then self.queueHudSelected2768:SetText("DUNGEON QUEUE HUD") end
        return
    end
    if status == nil and type(GetActivityFinderStatus) == "function" then
        local ok, value = pcall(GetActivityFinderStatus)
        if ok then status = value end
    end
    local active = easQueueIsActive2768(status)
    local temporarilySuppressed = active and self:IsQueueHudTemporarilySuppressed2772()
    frame:SetHidden((not active) or temporarilySuppressed)
    if not active then return end

    -- Keep ESO's passive queue HUD suppressed even while the Suite HUD is
    -- temporarily hidden by a menu, so the native overlay does not leak through.
    self:SuppressNativeQueueHud2768()
    if temporarilySuppressed then return end
    self.queueHudStatus2768:SetText(easQueueStatusText2768(status))
    self.queueHudDetails2768:SetText(string.format("%s  |  %s", tostring(self.difficulty or "NORMAL"), tostring(self.role or "DPS")))

    if ACTIVITY_FINDER_STATUS_READY_CHECK ~= nil and status == ACTIVITY_FINDER_STATUS_READY_CHECK then
        self.queueHudSelected2768:SetText(self:GetMatchedDungeonName2771())
    else
        self.queueHudSelected2768:SetText(self:GetQueueSelectionSummary2768())
    end
end

function D:InitializeQueueHud2768()
    if self.queueHudInitialized2768 then return end
    self.queueHudInitialized2768 = true
    self:CreateQueueHud2768()
    if EVENT_ACTIVITY_FINDER_STATUS_UPDATE ~= nil and EVENT_MANAGER then
        EVENT_MANAGER:RegisterForEvent("ESOAdventurerSuite_DungeonQueueHUD2768", EVENT_ACTIVITY_FINDER_STATUS_UPDATE,
            function(_, status) self:RefreshQueueHud2768(status) end)
    end
    if EVENT_MANAGER then
        EVENT_MANAGER:RegisterForUpdate("ESOAdventurerSuite_DungeonQueueHUDPoll2768", 750, function()
            self:RefreshQueueHud2768()
        end)
    end
    self:RefreshQueueHud2768()
end

if EVENT_MANAGER and EVENT_ADD_ON_LOADED then
    EVENT_MANAGER:RegisterForEvent("ESOAdventurerSuite_DungeonQueueHUDLoad2768", EVENT_ADD_ON_LOADED, function(_, addonName)
        if addonName ~= EPC.name and addonName ~= EPC.legacyName then return end
        EVENT_MANAGER:UnregisterForEvent("ESOAdventurerSuite_DungeonQueueHUDLoad2768", EVENT_ADD_ON_LOADED)
        if zo_callLater then zo_callLater(function() D:InitializeQueueHud2768() end, 500) else D:InitializeQueueHud2768() end
    end)
end

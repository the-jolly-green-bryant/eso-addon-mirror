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

-- v0.25.68 - Real ESO random dungeon queue support.
-- Uses the Activity Finder random queue type so ESO awards the normal daily/random rewards.
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

    if type(ClearActivityFinderSearch) ~= "function"
        or type(AddActivityFinderRandomSearchEntry) ~= "function"
        or type(StartActivityFinderSearch) ~= "function" then
        message("ESO random Activity Finder API is unavailable on this client.")
        return false
    end

    local activityType
    if self.difficulty == "VETERAN" then
        activityType = LFG_ACTIVITY_MASTER_DUNGEON
    else
        activityType = LFG_ACTIVITY_DUNGEON
    end

    if activityType == nil then
        message("ESO random dungeon activity type is unavailable on this client.")
        return false
    end

    pcall(ClearActivityFinderSearch)
    local okAdd = pcall(AddActivityFinderRandomSearchEntry, activityType)
    if not okAdd then
        message("Could not add the random dungeon queue to Activity Finder.")
        return false
    end

    local ok, result = pcall(StartActivityFinderSearch)
    if ok then
        if EPC.DungeonHistory and EPC.DungeonHistory.RememberQueuedDifficulty then
            EPC.DungeonHistory:RememberQueuedDifficulty(self.difficulty)
        end
        message(string.format("Random %s dungeon queue requested [%s].", self.difficulty == "VETERAN" and "Veteran" or "Normal", self.role or "DPS"))
        return true, result
    end

    message("ESO rejected the random dungeon queue request.")
    return false
end

function D:IsDailyRandomRewardEligible()
    if type(IsEligibleForDailyActivityReward) == "function" then
        local ok, eligible = pcall(IsEligibleForDailyActivityReward)
        if ok then return eligible == true end
    end
    return nil
end

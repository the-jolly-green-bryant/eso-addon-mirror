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

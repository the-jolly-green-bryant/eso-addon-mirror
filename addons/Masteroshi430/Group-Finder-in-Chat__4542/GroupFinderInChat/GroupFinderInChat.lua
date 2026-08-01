GroupFinderInChat = {}
GroupFinderInChat.name = "GroupFinderInChat"

-- Localize hot globals: avoids a global-table lookup on every call,
-- which matters here since these run inside a per-listing loop.
local GetGroupFinderSearchNumListings = GetGroupFinderSearchNumListings
local GetGroupFinderSearchListingLeaderDisplayNameByIndex = GetGroupFinderSearchListingLeaderDisplayNameByIndex
local GetGroupFinderSearchListingTitleByIndex = GetGroupFinderSearchListingTitleByIndex
local GetGroupFinderSearchListingDescriptionByIndex = GetGroupFinderSearchListingDescriptionByIndex
local GetGroupFinderSearchListingCategoryByIndex = GetGroupFinderSearchListingCategoryByIndex
local GetGroupFinderSearchListingRoleStatusCount = GetGroupFinderSearchListingRoleStatusCount
local GetGroupFinderSearchListingPlaystyleByIndex = GetGroupFinderSearchListingPlaystyleByIndex
local GetGroupFinderSearchListingOptionsSelectionTextByIndex = GetGroupFinderSearchListingOptionsSelectionTextByIndex
local IsGroupFinderCategoryAvailable = IsGroupFinderCategoryAvailable
local ZO_LinkHandler_CreateLinkWithoutBrackets = ZO_LinkHandler_CreateLinkWithoutBrackets
local zo_strformat = zo_strformat
local GetString = GetString
local IsPlayerActivated = IsPlayerActivated
local IsUnitGrouped = IsUnitGrouped
local tconcat = table.concat

-- A single queue + ticker replaces one zo_callLater-per-listing with an
-- ever-growing delay (10000*listing). That old approach could schedule a
-- message half an hour out for a large search, and if the 5-minute rescan
-- fired before the queue drained you'd get overlapping/duplicate output.
-- A shared queue drained on a fixed interval keeps memory/timer usage flat
-- regardless of how many listings come back, and never overlaps itself.
local MESSAGE_INTERVAL_MS = 1500
local messageQueue = {}
local queueRunning = false

local function drainQueue()
    local msg = table.remove(messageQueue, 1)
    if msg then
        CHAT_ROUTER:AddSystemMessage(msg)
    end
    if #messageQueue > 0 then
        zo_callLater(drainQueue, MESSAGE_INTERVAL_MS)
    else
        queueRunning = false
    end
end

local function queueMessage(msg)
    messageQueue[#messageQueue + 1] = msg
    if not queueRunning then
        queueRunning = true
        zo_callLater(drainQueue, MESSAGE_INTERVAL_MS)
    end
end

function GroupFinderInChat.TurnOn()
    if not GroupFinderInChat.alreadyRunning then
        EVENT_MANAGER:RegisterForUpdate("GroupFinderInChatGo", 300000, GroupFinderInChat.go) -- updates every 5mn
        GroupFinderInChat.alreadyRunning = true
        zo_callLater(GroupFinderInChat.go, 5000)
    end
end

function GroupFinderInChat.TurnOff()
    GroupFinderInChat.alreadyRunning = nil
    EVENT_MANAGER:UnregisterForUpdate("GroupFinderInChatGo") -- see you soon
    messageQueue = {}
    queueRunning = false
end

function GroupFinderInChat.go()
    if not IsPlayerActivated() or IsUnitGrouped("player") then return end

    local numListings = GetGroupFinderSearchNumListings()
    for listing = 1, numListings do
        local category = GetGroupFinderSearchListingCategoryByIndex(listing)

        -- Filter on category first, before touching any of the more
        -- expensive listing-detail getters or building link/string data
        -- for a listing we're going to discard anyway.
        if IsGroupFinderCategoryAvailable(category) then
            local leaderDisplayName = GetGroupFinderSearchListingLeaderDisplayNameByIndex(listing)
            leaderDisplayName = ZO_LinkHandler_CreateLinkWithoutBrackets(leaderDisplayName, nil, "display", leaderDisplayName)
            local title = GetGroupFinderSearchListingTitleByIndex(listing)
            local description = GetGroupFinderSearchListingDescriptionByIndex(listing)

            local dpsNeeded, dps = GetGroupFinderSearchListingRoleStatusCount(listing, LFG_ROLE_DPS)
            local healNeeded, heal = GetGroupFinderSearchListingRoleStatusCount(listing, LFG_ROLE_HEAL)
            local noneNeeded, none = GetGroupFinderSearchListingRoleStatusCount(listing, LFG_ROLE_INVALID)
            local tankNeeded, tank = GetGroupFinderSearchListingRoleStatusCount(listing, LFG_ROLE_TANK)

            local total = dps + heal + none + tank
            local totalNeeded = dpsNeeded + healNeeded + noneNeeded + tankNeeded
            local missingTanks = tankNeeded - tank
            local missingHeals = healNeeded - heal
            local missingDps = dpsNeeded - dps

            local missingTanksStr = missingTanks > 0 and (missingTanks .. "|t24:24:EsoUI/Art/LFG/LFG_tank_down.dds|t ") or ""
            local missingHealsStr = missingHeals > 0 and (missingHeals .. "|t24:24:EsoUI/Art/LFG/LFG_healer_down.dds|t ") or ""
            local missingDpsStr = missingDps > 0 and (missingDps .. "|t24:24:EsoUI/Art/LFG/LFG_dps_down.dds|t") or ""

            local missingMsg = ""
            if missingTanksStr ~= "" or missingHealsStr ~= "" or missingDpsStr ~= "" then
                missingMsg = "currently hiring " .. missingTanksStr .. missingHealsStr .. missingDpsStr
            end

            local playstyle = GetGroupFinderSearchListingPlaystyleByIndex(listing)
            local playstyleName = "[" .. zo_strformat(GetString("SI_GROUPFINDERPLAYSTYLE", playstyle), 2) .. "]"
            local primary, secondary = GetGroupFinderSearchListingOptionsSelectionTextByIndex(listing)
            local optionsText = ""
            local categoryName = ""
            if primary ~= "" and secondary ~= "" then
                optionsText = "|Cff7f00[" .. primary .. " " .. secondary .. " " .. total .. "/" .. totalNeeded .. "]"
            elseif primary ~= "" then
                optionsText = "|Cff7f00[" .. primary .. " " .. total .. "/" .. totalNeeded .. "]"
            else
                -- Only compute this when we're actually going to use it —
                -- the other two branches discarded it anyway.
                categoryName = "[" .. zo_strformat(GetString("SI_GROUPFINDERCATEGORY", category), 2) .. " " .. total .. "/" .. totalNeeded .. "]"
            end

            local msg = tconcat({
                "|CFFFFFF[GroupFinder]", categoryName, optionsText,
                " |r|Cff0000", leaderDisplayName, " |CFFFFFF", title, " ", description,
                " ", playstyleName, " ", missingMsg,
            })

            queueMessage(msg)
        end
    end
end

EVENT_MANAGER:RegisterForEvent("GroupFinderInChatGo", EVENT_GROUP_FINDER_SEARCH_COMPLETE, GroupFinderInChat.TurnOn)
EVENT_MANAGER:RegisterForEvent("GroupFinderInChatGo", EVENT_GROUP_MEMBER_JOINED, GroupFinderInChat.TurnOff)

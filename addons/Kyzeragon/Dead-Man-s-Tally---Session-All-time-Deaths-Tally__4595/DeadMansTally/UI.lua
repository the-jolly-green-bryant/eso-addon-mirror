local DMT = DeadMansTally

local currSVs

local session = true
local showing = {
    ungroupedplayer = {
        enabled = true,
        buttonName = "Player",
    },
    group = {
        enabled = true,
        buttonName = "Group",
    },
    companion = {
        enabled = false,
        buttonName = "Companion",
    },
    groupcompanion = {
        enabled = false,
        buttonName = "GroupCompanion",
    },
    playerpet = {
        enabled = false,
        buttonName = "PlayerPet",
    },
    boss = {
        enabled = false,
        buttonName = "Boss",
    },
}

local currServer = 1
local SERVERS = {
    [1] = {displayName = "all servers", texture = "all.dds"}, -- will include PTS, but whatev
    [2] = {displayName = "NA Megaserver", texture = "NA.dds"},
    [3] = {displayName = "EU Megaserver", texture = "EU.dds"},
}

---------------------------------------------------------------------
function DMT.SavePosition()
    currSVs.x = DMTTally:GetLeft()
    currSVs.y = DMTTally:GetTop()
end

function DMT.Hide()
    currSVs.show = false
    DMTTally:SetHidden(true)
end

function DMT.Show()
    currSVs.show = true
    DMTTally:SetHidden(false)
end

function DMT.ToggleUI()
    if (currSVs.show) then
        DMT.Hide()
    else
        DMT.Show()
    end
end


---------------------------------------------------------------------
function DMT.Lock()
    DMTTally:SetMovable(false)
    currSVs.locked = true
end

function DMT.Unlock()
    DMTTally:SetMovable(true)
    currSVs.locked = false
end


---------------------------------------------------------------------
local function UpdateButtons()
    for tagType, options in pairs(showing) do
        local button = DMTTallyButtons:GetNamedChild(options.buttonName)
        if (options.enabled) then
            button:SetDesaturation(0)
            button:SetColor(1, 1, 1, 1)
        else
            button:SetDesaturation(1)
            button:SetColor(0.5, 0.5, 0.5, 1)
        end
    end

    DMTTallyButtonsAllSession:SetTexture(session and "/esoui/art/buttons/radiobuttonup.dds" or "/esoui/art/buttons/radiobuttondown.dds")
    DMTTallyButtonsRefresh:SetHidden(not session)
    DMTTallyButtonsServer:SetHidden(session)
    if (not session) then
        DMTTallyButtonsServer:SetTexture("DeadMansTally/art/" .. SERVERS[currServer].texture)
    end
end

local truncatedText = {} -- caching, how much does it matter?
local function TruncateText(orig)
    if (truncatedText[orig]) then
        return truncatedText[orig]
    end

    local text = orig
    DMTDummyText:SetWidth(300)
    DMTDummyText:SetText(text)
    if (DMTDummyText:GetTextWidth() <= 150) then
        truncatedText[orig] = text
        return text
    end

    for i = 1, #orig do
        DMTDummyText:SetWidth(300)
        DMTDummyText:SetText(text)
        if (DMTDummyText:GetTextWidth() <= 140) then -- Slightly shorter to fit the ellipsis
            text = text .. "..."
            truncatedText[orig] = text
            return text
        end
        text = string.sub(text, 1, #text - 1)
    end

    truncatedText[orig] = text
    return text
end

local sorted = {}
local function UpdateSorted()
    local totalTally = {}
    local tablesToTally = {}

    if (session) then
        table.insert(tablesToTally, DMT.svs.currentDeaths)
    else
        DMT.LoadOthers()
        if (currSVs.includeInAll and (currServer == 1 or GetWorldName() == SERVERS[currServer].displayName)) then
            table.insert(tablesToTally, DMT.svs.foreverDeaths)
        end
        for serverName, serverData in pairs(DMT.othersSVs) do
            if (currServer == 1
                or (currServer == 2 and serverName == "NA Megaserver")
                or (currServer == 3 and serverName == "EU Megaserver")) then
                for _, accData in pairs(serverData) do
                    table.insert(tablesToTally, accData.foreverDeaths)
                end
            end
        end
    end

    -- For each table we care about...
    for _, tableToTally in ipairs(tablesToTally) do
        -- ... add all values only if the type is enabled
        for tagType, typeTable in pairs(tableToTally) do
            if (showing[tagType].enabled) then
                for k, v in pairs(typeTable) do
                    if (not totalTally[k]) then
                        totalTally[k] = 0
                    end
                    totalTally[k] = totalTally[k] + v
                end
            end
        end
    end

    -- Order them
    ZO_ClearTable(sorted)
    for name, num in pairs(totalTally) do
        table.insert(sorted, {name = name, num = num, display = TruncateText(name)})
    end
    table.sort(sorted, function(a, b)
        if (a.num == b.num) then
            return a.name < b.name
        end
        return a.num > b.num
    end)
end

function DMT.GetSorted()
    return sorted
end

local function UpdateAll()
    UpdateSorted()

    UpdateButtons()
    DMTTallyHeader:SetText(session and "Session Deaths" or "All-time Multi-acc Deaths")

    -- Concat them
    local nameColumn = ""
    local numColumn = ""
    for _, entry in ipairs(sorted) do
        nameColumn = string.format("%s%s\n", nameColumn, entry.display)
        numColumn = string.format("%s%d\n", numColumn, entry.num)
    end

    DMTTallyNames:SetText(nameColumn)
    DMTTallyCount:SetText(numColumn)

    local CAP_LINES = 12
    -- local cappedHeight = (#sortedNames > CAP_LINES) and CAP_LINES*25.5 or DMTTallyNames:GetTextHeight()
    local cappedHeight = (#sorted > CAP_LINES) and CAP_LINES*19 or DMTTallyNames:GetTextHeight()
    DMTTallyScrollContainer:SetHeight(cappedHeight)
    DMTTally:SetHeight(cappedHeight + 52)

    DMTTally:ClearAnchors()
    DMTTally:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, currSVs.x, currSVs.y)

    DMTTally:SetScale(currSVs.scale)
end
DMT.UpdateAll = UpdateAll


---------------------------------------------------------------------
function DMT.OnToggleClicked(button, tagType)
    showing[tagType].enabled = not showing[tagType].enabled
    UpdateAll()
end

function DMT.OnSessionToggled()
    session = not session
    UpdateAll()
end

function DMT.OnServerCycled()
    currServer = currServer + 1
    if (currServer > 3) then
        currServer = 1
    end
    UpdateAll()
end

function DMT.ClearSession()
    for tagType, tab in pairs(DMT.svs.currentDeaths) do
        ZO_ClearTable(tab)
    end

    UpdateAll()
end


---------------------------------------------------------------------
function DMT.InitializeUI()
    currSVs = DMT.packedSVs[GetWorldName()][GetUnitDisplayName("player")]

    DMTTally:ClearAnchors()
    DMTTally:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, currSVs.x, currSVs.y)
    DMTTally:SetHidden(not currSVs.show)
    DMTTally:SetMovable(not currSVs.locked)

    UpdateAll()
end

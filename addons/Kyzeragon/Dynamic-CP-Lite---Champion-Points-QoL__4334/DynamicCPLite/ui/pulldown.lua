local CREATE_NEW_STRING = "-- Create New --"

---------------------------------------------------------------------
-- Per-tree values
local function GetMiddlePoint(tree)
    if (tree == "Green") then
        return ZO_ChampionPerksActionBarSlot2:GetCenter() + ZO_ChampionPerksActionBarSlot3:GetCenter()
    elseif (tree == "Blue") then
        return ZO_ChampionPerksActionBarSlot6:GetCenter() + ZO_ChampionPerksActionBarSlot7:GetCenter()
    elseif (tree == "Red") then
        return ZO_ChampionPerksActionBarSlot10:GetCenter() + ZO_ChampionPerksActionBarSlot11:GetCenter()
    end
    return 0
end

local TEXT_COLORS = {
    Green = {0.55, 0.78, 0.22},
    Blue = {0.35, 0.73, 0.9},
    Red = {0.88, 0.4, 0.19},
}

local TEXT_COLORS_HEX = {
    Green = "a5d752",
    Blue = "59bae7",
    Red = "e46b2e",
}

local INDEX_TO_TREE = {
    [1] = "Green",
    [2] = "Blue",
    [3] = "Red",
}

local TREE_TO_FIRST_INDEX = {
    Green = 1,
    Blue = 5,
    Red = 9,
}

local function GetStarControlFromIndex(index)
    local tree = INDEX_TO_TREE[math.floor((index - 1) / 4) + 1]
    local starIndex = (index - 1) % 4 + 1
    return DynamicCPPulldown:GetNamedChild(tree):GetNamedChild("Star" .. tostring(starIndex))
end

---------------------------------------------------------------------
-- Slot sets
---------------------------------------------------------------------
local currentSelected = {} -- {Green = "Craft",}

-- Iterate through the UI stars to find the championSkilLData for a skillId
-- I guess this info is UI-only, so this is Not IdealTM
local function FindChampionSkillData(skillId)
    local skillDataFromManager = CHAMPION_DATA_MANAGER:GetChampionSkillData(skillId)
    if (skillDataFromManager) then
        return skillDataFromManager
    end

    -- Not sure if this is still needed. I didn't have the above previously,
    -- but I don't remember if there was a reason I didn't use that or I just didn't know
    for i = 1, ZO_ChampionPerksCanvas:GetNumChildren() do
        local child = ZO_ChampionPerksCanvas:GetChild(i)
        if (child.star and child.star.championSkillData) then
            local id = child.star.championSkillData.championSkillId
            if (id == skillId) then
                return child.star.championSkillData
            end
        end
    end
end

local function ShowSlottables(tree, data)
    for i = 1, 4 do
        local starControl = GetStarControlFromIndex(i + TREE_TO_FIRST_INDEX[tree] - 1)
        local skillId = data[i]

        local color = TEXT_COLORS[tree]
        if (skillId) then
            -- Show it in yellow if it's not unlocked
            local unlocked = WouldChampionSkillNodeBeUnlocked(skillId, GetNumPointsSpentOnChampionSkill(skillId))
            if (not unlocked) then
                color = {1, 1, 0.5}
            end
            starControl:GetNamedChild("Name"):SetText(zo_strformat("<<C:1>>", GetChampionSkillName(skillId)))
            if (DynamicCP.savedOptions.showPulldownPoints) then
                starControl:GetNamedChild("Points"):SetText(GetNumPointsSpentOnChampionSkill(skillId))
            else
                starControl:GetNamedChild("Points"):SetText("")
            end
        else
            starControl:GetNamedChild("Name"):SetText("")
            starControl:GetNamedChild("Points"):SetText("")
        end
        starControl.SetColors(color)
    end
end


---------------------------------------------------------------------
-- Since U43, the ActionBar has deferred initialization, so it's
-- possible the user hasn't opened the CP screen yet before changing
-- CP via addons
DynamicCP.pulldownInitialized = false

---------------------------------------------------------------------
-- Update every item in the pulldown
local function ApplyCurrentSlottables(currentSlottables)
    if (not DynamicCP.pulldownInitialized) then return end

    for index = 1, 12 do
        local slottableSkillData = currentSlottables[index]
        local star = GetStarControlFromIndex(index)

        local tree = "Red"
        if (index <= 4) then
            tree = "Green"
        elseif (index <= 8) then
            tree = "Blue"
        end
        star.SetColors(TEXT_COLORS[tree])

        -- It could be empty
        if (not slottableSkillData) then
            star:GetNamedChild("Name"):SetText("")
            star:GetNamedChild("Points"):SetText("")
        else
            -- Set labels
            local id = slottableSkillData.championSkillId
            star:GetNamedChild("Name"):SetText(zo_strformat("<<C:1>>", GetChampionSkillName(id)))

            -- TODO: show pending points after refactor
            if (DynamicCP.savedOptions.showPulldownPoints) then
                star:GetNamedChild("Points"):SetText(GetNumPointsSpentOnChampionSkill(id))
            else
                star:GetNamedChild("Points"):SetText("")
            end
        end
    end
end
DynamicCP.ApplyCurrentSlottables = ApplyCurrentSlottables


---------------------------------------------------------------------
-- Expand / hide the pulldown
local function TogglePulldown()
    if (DynamicCPPulldown:IsHidden()) then
        -- Expand it
        DynamicCPPulldownTabArrowExpanded:SetHidden(IsConsoleUI())
        DynamicCPPulldownTabArrowHidden:SetHidden(true)
        DynamicCPPulldown:SetHidden(false)
        DynamicCPPulldownTab:SetAnchor(TOP, DynamicCPPulldown, BOTTOM)
        DynamicCP.savedOptions.pulldownExpanded = true
    else
        -- Hide it
        DynamicCPPulldownTabArrowExpanded:SetHidden(true)
        DynamicCPPulldownTabArrowHidden:SetHidden(IsConsoleUI())
        DynamicCPPulldown:SetHidden(true)
        DynamicCPPulldownTab:SetAnchor(TOP, ZO_ChampionPerksActionBar, BOTTOM)
        DynamicCP.savedOptions.pulldownExpanded = false
    end
end
DynamicCP.TogglePulldown = TogglePulldown


---------------------------------------------------------------------
-- tree = "Green" "Blue" "Red"
local function InitTree(control, tree)
    local width = ZO_ChampionPerksActionBarSlot4:GetRight() - ZO_ChampionPerksActionBarSlot1:GetLeft() + 20

    -- Size and position
    control:SetHeight(40)
    control:SetWidth(width)
    control:SetAnchor(TOP, GuiRoot, TOPLEFT, GetMiddlePoint(tree) / 2, ZO_ChampionPerksActionBar:GetBottom())

    -- Stars
    local color = TEXT_COLORS[tree]
    local starNameLength = width - 20 - (DynamicCP.savedOptions.showPulldownPoints and 20 or 0)
    -- local starNameLength = width / 2 - 20 - (DynamicCP.savedOptions.showPulldownPoints and 20 or 0)

    local star1 = CreateControlFromVirtual("$(parent)Star1", control, "DynamicCPPulldownStar", "")
    star1:SetAnchor(TOPLEFT, control, TOPLEFT)
    star1.SetColors(color)
    star1:GetNamedChild("Name"):SetWidth(starNameLength)
    local star2 = CreateControlFromVirtual("$(parent)Star2", control, "DynamicCPPulldownStar", "")
    star2:SetAnchor(TOPLEFT, star1, BOTTOMLEFT)
    star2.SetColors(color)
    star2:GetNamedChild("Name"):SetWidth(starNameLength)
    local star3 = CreateControlFromVirtual("$(parent)Star3", control, "DynamicCPPulldownStar", "")
    star3:SetAnchor(TOPLEFT, star2, BOTTOMLEFT)
    star3.SetColors(color)
    star3:GetNamedChild("Name"):SetWidth(starNameLength)
    local star4 = CreateControlFromVirtual("$(parent)Star4", control, "DynamicCPPulldownStar", "")
    star4:SetAnchor(TOPLEFT, star3, BOTTOMLEFT)
    star4.SetColors(color)
    star4:GetNamedChild("Name"):SetWidth(starNameLength)
end

local function ApplyPulldownFonts()
    if (not DynamicCP.pulldownInitialized) then return end

    local styles = DynamicCP.GetStyles()

    -- Star names
    for i = 1, 12 do
        GetStarControlFromIndex(i):GetNamedChild("Name"):SetFont(styles.smallFont)
        GetStarControlFromIndex(i):GetNamedChild("Points"):SetFont(styles.smallFont)
    end
end
DynamicCP.ApplyPulldownFonts = ApplyPulldownFonts

local function ReanchorPulldown()
    if (not DynamicCP.pulldownInitialized) then return end

    DynamicCPPulldownGreen:SetAnchor(TOP, GuiRoot, TOPLEFT, GetMiddlePoint("Green") / 2, ZO_ChampionPerksActionBar:GetBottom())
    DynamicCPPulldownBlue:SetAnchor(TOP, GuiRoot, TOPLEFT, GetMiddlePoint("Blue") / 2, ZO_ChampionPerksActionBar:GetBottom())
    DynamicCPPulldownRed:SetAnchor(TOP, GuiRoot, TOPLEFT, GetMiddlePoint("Red") / 2, ZO_ChampionPerksActionBar:GetBottom())
end
DynamicCP.ReanchorPulldown = ReanchorPulldown

function DynamicCP.InitPulldown()
    InitTree(DynamicCPPulldownGreen, "Green")
    InitTree(DynamicCPPulldownBlue, "Blue")
    InitTree(DynamicCPPulldownRed, "Red")

    DynamicCP.pulldownInitialized = true

    ApplyPulldownFonts()
end

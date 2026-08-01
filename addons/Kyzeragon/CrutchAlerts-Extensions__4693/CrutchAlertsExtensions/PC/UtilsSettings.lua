local CAE = CrutchAlertsExtensions


---------------------------------------------------------------------
local lineTag1, lineTag2
local groupMemberTags = {}
local groupMemberNames = {}
local function RefreshGroupMembers()
    ZO_ClearTable(groupMemberTags)
    ZO_ClearTable(groupMemberNames)
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if (tag and IsUnitOnline(tag)) then
            table.insert(groupMemberTags, tag)
            table.insert(groupMemberNames, zo_strformat("<<1>> <<2>> (<<3>>)", GetUnitName(tag), GetUnitDisplayName(tag), tag))
        end
    end
end


---------------------------------------------------------------------
function CAE.CreateUtilsSettingsMenu()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "|c08BD1DCrutchAlerts Extensions - Utils|r",
        author = "Kyzeragon",
        version = CAE.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "description",
            text = "These \"settings\" are just some utilities that are not stored in profiles.",
            width = "full",
        },
        {
            type = "description",
            title = "|c08BD1DTemporary Line|r",
            text = "Choose group members to draw a line between. Because M0R really wants this in a dropdown. Hint: you can show the distance in the main CrutchAlerts settings > Debug > Show line distance. Note that this is assigned by unit tag, so the players connected by the line may change when unit tags change",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Draw line player 1",
            choices = {},
            choicesValues = {},
            getFunc = function()
                RefreshGroupMembers()
                CAE_Line1Dropdown:UpdateChoices(groupMemberNames, groupMemberTags)
                return lineTag1
            end,
            setFunc = function(value)
                lineTag1 = value
                CAE.DrawLine(lineTag1, lineTag2)
            end,
            width = "full",
            reference = "CAE_Line1Dropdown",
        },
        {
            type = "dropdown",
            name = "Draw line player 2",
            choices = {},
            choicesValues = {},
            getFunc = function()
                RefreshGroupMembers()
                CAE_Line2Dropdown:UpdateChoices(groupMemberNames, groupMemberTags)
                return lineTag2
            end,
            setFunc = function(value)
                lineTag2 = value
                CAE.DrawLine(lineTag1, lineTag2)
            end,
            width = "full",
            reference = "CAE_Line2Dropdown",
        },
        {
            type = "button",
            name = "Remove line",
            tooltip = "Remove the line if there is one",
            func = function()
                CAE.RemoveLine()
            end,
            width = "full",
        },
    }

    LAM:RegisterAddonPanel("CrutchAlertsExtensionsUtils", panelData)
    LAM:RegisterOptionControls("CrutchAlertsExtensionsUtils", optionsData)
end
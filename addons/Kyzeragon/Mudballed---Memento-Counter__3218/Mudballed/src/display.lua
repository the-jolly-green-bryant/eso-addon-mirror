Mudballed = Mudballed or {}
local Mud = Mudballed

---------------------------------------------------------------------
-- lazy, copied from https://stackoverflow.com/questions/15706270/sort-a-table-in-lua
local function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a, b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

local ballNames = {
    "mudball",
    "snowball",
    "pie",
    "blossom",
    "crow",
}

local truncatedText = {} -- Cache to avoid calculating a lot

local function TruncateText(orig)
    if (truncatedText[orig]) then
        return truncatedText[orig]
    end

    local text = orig
    MudballedDummyText:SetWidth(300)
    MudballedDummyText:SetText(text)
    if (MudballedDummyText:GetTextWidth() <= 160) then
        return text
    end

    for i = 1, #orig do
        MudballedDummyText:SetWidth(300)
        MudballedDummyText:SetText(text)
        if (MudballedDummyText:GetTextWidth() <= 150) then -- Slightly shorter to fit the ellipsis
            text = text .. "..."
            truncatedText[orig] = text
            return text
        end
        text = string.sub(text, 1, #text - 1)
    end

    return text
end

function Mud.DumpTruncated()
    d(truncatedText)
end

---------------------------------------------------------------------
local function UpdateTally(control, mainTally, options, title)
    local tally = {}
    for _, ballName in ipairs(ballNames) do
        if (options[ballName]) then
            -- Add all of the entries to the result tally
            for name, count in pairs(mainTally[ballName]) do
                if (not tally[name]) then
                    tally[name] = 0
                end
                tally[name] = tally[name] + count
            end
        end
    end

    local col1 = {}
    local col2 = {}
    local numLines = 0
    for name, count in spairs(tally, function(t, a, b) return t[b] < t[a] end) do
        table.insert(col1, TruncateText(name))
        table.insert(col2, count)
        numLines = numLines + 1
    end

    -- Update controls
    control:GetNamedChild("Header"):SetText(title)
    control:GetNamedChild("Names"):SetText(table.concat(col1, "\n"))
    control:GetNamedChild("Count"):SetText(table.concat(col2, "\n"))

    control:GetNamedChild("Names"):SetHeight(1000)
    local textHeight = control:GetNamedChild("Names"):GetTextHeight()
    control:GetNamedChild("Names"):SetHeight(textHeight)
    control:GetNamedChild("Count"):SetHeight(textHeight)

    local cappedHeight = (numLines > Mud.savedOptions.capLines) and Mud.savedOptions.capLines*25.5 or textHeight
    control:GetNamedChild("ScrollContainer"):SetHeight(cappedHeight)
    control:SetHeight(cappedHeight + 52)
end

local function UpdateButtons(control, allTally, sessionTally, options, titleWord)
    if (options.mudball) then
        control:GetNamedChild("ButtonsMudball"):SetDesaturation(0)
        control:GetNamedChild("ButtonsMudball"):SetColor(1, 1, 1, 1)
    else
        control:GetNamedChild("ButtonsMudball"):SetDesaturation(1)
        control:GetNamedChild("ButtonsMudball"):SetColor(0.5, 0.5, 0.5, 1)
    end

    if (options.snowball) then
        control:GetNamedChild("ButtonsSnowball"):SetDesaturation(0)
        control:GetNamedChild("ButtonsSnowball"):SetColor(1, 1, 1, 1)
    else
        control:GetNamedChild("ButtonsSnowball"):SetDesaturation(1)
        control:GetNamedChild("ButtonsSnowball"):SetColor(0.5, 0.5, 0.5, 1)
    end

    if (options.pie) then
        control:GetNamedChild("ButtonsPie"):SetDesaturation(0)
        control:GetNamedChild("ButtonsPie"):SetColor(1, 1, 1, 1)
    else
        control:GetNamedChild("ButtonsPie"):SetDesaturation(1)
        control:GetNamedChild("ButtonsPie"):SetColor(0.5, 0.5, 0.5, 1)
    end

    if (options.blossom) then
        control:GetNamedChild("ButtonsBlossom"):SetDesaturation(0)
        control:GetNamedChild("ButtonsBlossom"):SetColor(1, 1, 1, 1)
    else
        control:GetNamedChild("ButtonsBlossom"):SetDesaturation(1)
        control:GetNamedChild("ButtonsBlossom"):SetColor(0.5, 0.5, 0.5, 1)
    end

    if (options.crow) then
        control:GetNamedChild("ButtonsCrow"):SetDesaturation(0)
        control:GetNamedChild("ButtonsCrow"):SetColor(1, 1, 1, 1)
    else
        control:GetNamedChild("ButtonsCrow"):SetDesaturation(1)
        control:GetNamedChild("ButtonsCrow"):SetColor(0.5, 0.5, 0.5, 1)
    end

    control:GetNamedChild("ButtonsAllSession"):SetTexture(options.all and "/esoui/art/buttons/radiobuttondown.dds" or "/esoui/art/buttons/radiobuttonup.dds")

    UpdateTally(control, options.all and allTally or sessionTally, options, (options.all and "All-Time " or "Session ") .. titleWord)
end

local function UpdateAllTallies()
    UpdateButtons(MudballedSourceTally, Mud.savedOptions.sourceTally, Mud.sessionSourceTally, Mud.savedOptions.sourceDisplay, "Victims")
    MudballedSourceTally:SetHidden(not Mud.savedOptions.sourceDisplay.show)

    UpdateButtons(MudballedTargetTally, Mud.savedOptions.targetTally, Mud.sessionTargetTally, Mud.savedOptions.targetDisplay, "Attackers")
    MudballedTargetTally:SetHidden(not Mud.savedOptions.targetDisplay.show)
end
Mud.UpdateAllTallies = UpdateAllTallies

---------------------------------------------------------------------
function Mud.OnButtonClicked(buttonType, isSource)
    if (isSource) then
        Mud.savedOptions.sourceDisplay[buttonType] = not Mud.savedOptions.sourceDisplay[buttonType]
    else
        Mud.savedOptions.targetDisplay[buttonType] = not Mud.savedOptions.targetDisplay[buttonType]
    end
    UpdateAllTallies()
end

function Mud.InitializeDisplay()
    MudballedSourceTally:ClearAnchors()
    MudballedSourceTally:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, Mud.savedOptions.sourceDisplay.x, Mud.savedOptions.sourceDisplay.y)
    MudballedTargetTally:ClearAnchors()
    MudballedTargetTally:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, Mud.savedOptions.targetDisplay.x, Mud.savedOptions.targetDisplay.y)

    UpdateAllTallies()
end

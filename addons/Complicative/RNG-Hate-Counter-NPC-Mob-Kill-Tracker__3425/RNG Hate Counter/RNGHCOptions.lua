RNGHCOptions = {}

local LAM2 = LibAddonMenu2

local function cStart(hex)
    return "|c" .. hex
end

local function cEnd()
    return "|r"
end

function RNGHCOptions.Init()
    -------------------------------------------------------------------------------------------------
    -- Creating Settings  --
    -------------------------------------------------------------------------------------------------

    local panelData = {
        type = "panel",
        name = "RNG Hate Counter",
        author = 'Complicative',
        version = RNGHateCounter.version,
        website = "https://www.esoui.com/downloads/author-68201.html"
    }

    LAM2:RegisterAddonPanel("RNGHateCounterOptions", panelData)

    local optionsData = {}
    optionsData[#optionsData + 1] = {
        type = "description",
        text = "RNG Hate Counter tracks all killing blows on any NPC. Up to 3 NPC can be selected, to have independent chat output for. An additional slider is available for all other NPC."
            .. "\n\n" ..
            "Example: Setting the " .. cStart("33FF33") .. "NPC #1" .. cEnd() .. " to " ..
            cStart("FF3333") ..
            "Mammoth" ..
            cEnd() ..
            " and setting it's " .. cStart("33FF33") .. "Throttle" .. cEnd() .. " slider to " ..
            cStart("FF3333") ..
            "5" ..
            cEnd() ..
            ", while having the " ..
            cStart("33FF33") ..
            "Throttle All Other" .. cEnd() .. " slider on " .. cStart("FF3333") .. "10" .. cEnd() .. ", "
            ..
            "will result with outputs for Mammoth kills at 5,10,15,.. and all other NPC at 10,20,30,..." .. "\n\n" ..
            "Commands:" .. "\n" ..
            "/rnghatecounter or /killcount will show a list of all your kills."
    }
    optionsData[#optionsData + 1] = {
        type = "editbox",
        name = "NPC #1",
        tooltip = "Name of NPC to get independet chat output for",
        getFunc =
        function()
            if RNGHateCounter.Settings.squirrel1 ~= nil then
                return RNGHateCounter.Settings.squirrel1
            else
                return ""
            end
        end,
        setFunc =
        function(text)
            if text == "" then
                RNGHateCounter.Settings.squirrel1 = nil
            else
                RNGHateCounter.Settings.squirrel1 = text
            end
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Throttle",
        tooltip = "Amount of kills until the next chat output",
        min = 0,
        max = 100,
        getFunc = function() return RNGHateCounter.Settings.throttle1 end,
        setFunc = function(value) RNGHateCounter.Settings.throttle1 = value end,
    }
    optionsData[#optionsData + 1] = {
        type = "divider",
    }
    optionsData[#optionsData + 1] = {
        type = "editbox",
        name = "NPC #2",
        tooltip = "Name of NPC to get independet chat output for",
        getFunc =
        function()
            if RNGHateCounter.Settings.squirrel2 ~= nil then
                return RNGHateCounter.Settings.squirrel2
            else
                return ""
            end
        end,
        setFunc =
        function(text)
            if text == "" then
                RNGHateCounter.Settings.squirrel2 = nil
            else
                RNGHateCounter.Settings.squirrel2 = text
            end
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Throttle",
        tooltip = "Amount of kills until the next chat output",
        min = 0,
        max = 100,
        getFunc = function() return RNGHateCounter.Settings.throttle2 end,
        setFunc = function(value) RNGHateCounter.Settings.throttle2 = value end,
    }
    optionsData[#optionsData + 1] = {
        type = "divider",
    }
    optionsData[#optionsData + 1] = {
        type = "editbox",
        name = "NPC #3",
        tooltip = "Name of NPC to get independet chat output for",
        getFunc =
        function()
            if RNGHateCounter.Settings.squirrel3 ~= nil then
                return RNGHateCounter.Settings.squirrel3
            else
                return ""
            end
        end,
        setFunc =
        function(text)
            if text == "" then
                RNGHateCounter.Settings.squirrel3 = nil
            else
                RNGHateCounter.Settings.squirrel3 = text
            end
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Throttle",
        tooltip = "Amount of kills until the next chat output",
        min = 0,
        max = 100,
        getFunc = function() return RNGHateCounter.Settings.throttle3 end,
        setFunc = function(value) RNGHateCounter.Settings.throttle3 = value end,
    }
    optionsData[#optionsData + 1] = {
        type = "divider",
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Throttle All Other",
        tooltip = "Amount of kills per NPC until the next chat output",
        min = 0,
        max = 100,
        getFunc = function() return RNGHateCounter.Settings.throttle end,
        setFunc = function(value) RNGHateCounter.Settings.throttle = value end,
    }
    optionsData[#optionsData + 1] = {
        type = "divider",
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Timestamp",
        tooltip = "Toggles a timestamp at the start of any chat output",
        getFunc = function() return RNGHateCounter.Settings.timeStamp end,
        setFunc = function(value) RNGHateCounter.Settings.timeStamp = value end,
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Hide Button",
        tooltip = "Toggle if the RNG Hate Counter Button is hidden",
        getFunc = function() return RNGHateCounter.Settings.buttonHidden end,
        setFunc = function(value)
            RNGHCUI.SetHidden(RNGHCUI.buttonFragment, value)
            RNGHateCounter.Settings.buttonHidden = value
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Hide Kill Count on Button",
        tooltip = "Toggle if the RNG Hate Counter Button Label with total killcount is hidden",
        getFunc = function() return RNGHateCounter.Settings.buttonLabelHidden end,
        setFunc = function(value)
            RNGHateCounter.Settings.buttonLabelHidden = value
            RNGHCButtonControlButtonLabel:SetHidden(value)
        end,
    }
    --[[ optionsData[#optionsData + 1] = {
        type = "slider",
        name = "List Font Size",
        min = 18,
        max = 24,
        getFunc = function() return RNGHateCounter.Settings.scrollListFontSize end,
        setFunc = function(value) RNGHateCounter.Settings.scrollListFontSize = value RNGHCUI.Update() end,
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "List Row Height",
        min = 30,
        max = 72,
        getFunc = function() return RNGHateCounter.Settings.scrollListRowHeight end,
        setFunc = function(value) RNGHateCounter.Settings.scrollListRowHeight = value RNGHCUI.Update() end,
        requiresReload = true
    } ]]
    --[[ optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Debug",
        tooltip = "I wouldn't touch that",
        getFunc = function() return debug end,
        setFunc = function(value) debug = value end,
    } ]]

    LAM2:RegisterOptionControls("RNGHateCounterOptions", optionsData)


    -------------------------------------------------------------------------------------------------
    -- Creating Settings End --
    -------------------------------------------------------------------------------------------------
end

function KhajiitVoice:GenerateRaisedinElsweyrDescription()
    local playerRace = GetUnitRace("player")
    local playerName = GetUnitName("player")
    local tooltipText = "Enable " ..
        playerName ..
        ", a " ..
        playerRace .. ", to use Khajiit speech patterns."
    return tooltipText
end

function KhajiitVoice:GenerateCharacterDescription()
    local traits = KhajiitVoice.savedVars.personalityTraits
    local playerName = GetUnitName("player")
    local playerRace = GetUnitRace("player")
    local description = {}

    -- Base introduction
    table.insert(description, playerName .. " is a")

    -- Determine primary traits (> 60)
    local primaryTraits = {}
    local secondaryTraits = {}
    local contradictions = {}

    -- Categorize traits by intensity
    if traits.scholarlyTone > 60 then table.insert(primaryTraits, "scholarly") end
    if traits.kindSoulTone > 60 then table.insert(primaryTraits, "kind-hearted") end


    -- Secondary traits (30-60)
    if traits.scholarlyTone > 30 and traits.scholarlyTone <= 60 then table.insert(secondaryTraits, "somewhat learned") end
    if traits.kindSoulTone > 30 and traits.kindSoulTone <= 60 then table.insert(secondaryTraits, "compassionate") end



    -- Build the main description
    if playerRace == "Khajiit" then
        if #primaryTraits == 0 and #secondaryTraits == 0 then
            table.insert(description, " typical Khajiit")
        else
            -- Handle contradictions first
            if #contradictions > 0 then
                local contradiction = contradictions[1] -- Use the first contradiction
                table.insert(description, " " .. contradiction.desc .. " Khajiit")
            else
                -- No contradictions, build normally
                if #primaryTraits > 0 then
                    if #primaryTraits == 1 then
                        table.insert(description, " " .. primaryTraits[1] .. " Khajiit")
                    elseif #primaryTraits == 2 then
                        table.insert(description, " " .. primaryTraits[1] .. " and " .. primaryTraits[2] .. " Khajiit")
                    else
                        table.insert(description,
                            " " ..
                            table.concat(primaryTraits, ", ", 1, #primaryTraits - 1) ..
                            ", and " .. primaryTraits[#primaryTraits] .. " Khajiit")
                    end
                else
                    table.insert(description, " Khajiit")
                end
            end
        end
    else
        table.insert(description, playerName .. " is a " .. playerRace .. " adventurer.")
    end


    -- Add specific backstory elements based on traits
    if playerRace == "Khajiit" then
        local khajiitBackstory = {}


        if traits.scholarlyTone > 30 then
            table.insert(khajiitBackstory, playerName .. " has some formal education and enjoy intellectual pursuits")
        end




        if traits.kindSoulTone > 60 then
            table.insert(khajiitBackstory, playerName .. " is known for acts of compassion and generosity")
        end



        -- Add pronoun preference explanation
        local pronounPrefs = {}
        local weights = KhajiitVoice.savedVars.pronounWeights
        local total = weights.thisOne + weights.charName + weights.khajiit

        if weights.thisOne > (total * 0.5) then
            table.insert(pronounPrefs, "They prefer the humble 'this one' when speaking of themselves")
        elseif weights.charName > (total * 0.5) then
            table.insert(pronounPrefs, "They speak of themselves by name, showing confidence in their identity")
        elseif weights.khajiit > (total * 0.5) then
            table.insert(pronounPrefs, "They use the formal 'Khajiit' when referring to themselves")
        else
            table.insert(pronounPrefs, "They vary between humble and confident self-reference depending on the situation")
        end

        -- Add Cyrodiilic influence note
        if traits.cyrodiilicTone > 50 then
            table.insert(khajiitBackstory, "Their time spent among Imperials has influenced their speech patterns")
        end

        -- Combine everything
        local fullDescription = table.concat(description, "")

        if #khajiitBackstory > 0 then
            fullDescription = fullDescription .. ". " .. table.concat(khajiitBackstory, ". ")
        end

        if #pronounPrefs > 0 then
            fullDescription = fullDescription .. ". " .. table.concat(pronounPrefs, ". ")
        end

        fullDescription = fullDescription .. "."

        return fullDescription
    end
end

-- Settings Menu Creation
function KhajiitVoice:CreateSettingsMenuKhajiit()
    local LAM = LibAddonMenu2
    if not LAM then return end
    local playerName = GetUnitName("player")

    local panelData = {
        type = "panel",
        name = "Speak Like Khajiit",
        displayName = "Speak Like Khajiit",
        author = "YFNatey",
        version = "1.0.0",
        slashCommand = "/khajiitvoice",
        registerForRefresh = true,
    }

    local optionsData = {
        {
            type = "description",
            tooltip = function()
                return KhajiitVoice:GenerateCharacterDescription()
            end,
            text = playerName,
            width = "full"
        },
        {
            type = "header",
            name = "General Settings"
        },
        {
            type = "editbox",
            name = "Custom Name",
            tooltip =
            "Enter a custom name to use instead of your character name",
            getFunc = function() return KhajiitVoice.savedVars.customAliasText or "" end,
            setFunc = function(value)
                KhajiitVoice.savedVars.customAliasText = value
                -- Auto-enable if text is entered
                if value and value ~= "" then
                    KhajiitVoice.savedVars.useCustomAlias = true
                else
                    KhajiitVoice.savedVars.useCustomAlias = false
                end
            end,
            isMultiline = false,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Use Custom Name",
            getFunc = function() return KhajiitVoice.savedVars.useCustomAlias end,
            setFunc = function(value) KhajiitVoice.savedVars.useCustomAlias = value end,
            disabled = function()
                return not KhajiitVoice.savedVars.customAliasText or KhajiitVoice.savedVars.customAliasText == "" or
                    not KhajiitVoice.savedVars.permKhajiit
            end,

        },


        {
            type = "checkbox",
            name = "Enable Khajiit Dialogue",
            tooltip = "Toggle the entire addon on or off. Automatically turned off for non-Khajiit characters.",
            getFunc = function() return KhajiitVoice.savedVars.enabled end,
            setFunc = function(value) KhajiitVoice.savedVars.enabled = value end,
        },

        {
            type = "header",
            name = "Self-Reference Tendencies"
        },
        {
            type = "slider",
            name = "\"This one\"",
            tooltip = "How often to use 'this one' (humble, traditional, mysterious)",
            min = 5,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.pronounWeights.thisOne end,
            setFunc = function(value) KhajiitVoice.savedVars.pronounWeights.thisOne = value end,
            disabled = function()
                return not KhajiitVoice.savedVars.permKhajiit
            end,
        },
        {
            type = "slider",
            name = "Character Name",
            tooltip = function()
                if KhajiitVoice.savedVars.useCustomAlias and
                    KhajiitVoice.savedVars.customAliasText ~= "" then
                    return "How often to use your roleplay name '" ..
                        KhajiitVoice.savedVars.customAliasText .. "' (personal, confident)"
                else
                    return "How often to use your character's name (personal, confident)"
                end
            end,
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.pronounWeights.charName end,
            setFunc = function(value) KhajiitVoice.savedVars.pronounWeights.charName = value end,
            disabled = function()
                return not KhajiitVoice.savedVars.permKhajiit
            end,
        },
        {
            type = "slider",
            name = "\"Khajiit\"",
            tooltip = "How often to use 'Khajiit' (generic, formal, cautious)",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.pronounWeights.khajiit end,
            setFunc = function(value) KhajiitVoice.savedVars.pronounWeights.khajiit = value end,
            disabled = function()
                return not KhajiitVoice.savedVars.permKhajiit
            end,
        },
        {
            type = "slider",
            name = "Cyrodiilic",
            tooltip =
            "Higher values make your character speak more like a Cyrodiilic Imperial (less Khajiit speech patterns)",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.cyrodiilicTone end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.cyrodiilicTone = value end,
            disabled = function()
                return not KhajiitVoice.savedVars.permKhajiit
            end,
        },

        --[[{
            type = "header",
            name = "Personality Traits"
        },
        {
            type = "checkbox",
            name = "Friendly Goodbyes",
            tooltip = "Replace goodbye/farewell text with Khajiit expressions",
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.replaceGoodbyes end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.replaceGoodbyes = value end,
        },
        {
            type = "slider",
            name = "Kind Soul",
            tooltip =
            "A gentle and compassionate Khajiit who speaks with warmth and empathy. Uses friendly terms and caring expressions.",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.kindSoulTone end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.kindSoulTone = value end,
        },
        {
            type = "slider",
            name = "Curious",
            tooltip =
            "An inquisitive Khajiit who asks thoughtful questions and makes insightful observations. Speaks with natural curiosity about the world and its mysteries.",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.scholarlyTone end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.scholarlyTone = value end,
        --},]]

        {
            type = "divider"
        },


        {
            type = "description",
            text = "Thank you for using Speak Like Khajiit!",
            width = "full"
        },
        {
            type = "description",
            text = "More Addons",
            tooltip =
            "Cinematic Dialogue - Immersive Interactions\n See your character while speaking to NPCs, hide subtitles, and more",
            width = "full"
        },

        {
            type = "header",
            name = "Donations link"
        },
        {
            type = "description",
            text = "Author: YFNatey, Xbox NA",
            width = "full"
        },
        {
            type = "button",
            name = "Paypal",
            tooltip = "paypal.me/yfnatey",
            func = function() RequestOpenUnsafeURL("https://paypal.me/yfnatey") end,
            width = "half"
        },

    }

    LAM:RegisterAddonPanel("KhajiitVoicePanel", panelData)
    LAM:RegisterOptionControls("KhajiitVoicePanel", optionsData)
end

function KhajiitVoice:CreateSettingsMenuNonKhajiit()
    local LAM = LibAddonMenu2
    if not LAM then return end
    local playerName = GetUnitName("player")

    local panelData = {
        type = "panel",
        name = "Speak Like Khajiit",
        displayName = "Speak Like Khajiit",
        author = "YFNatey",
        version = KhajiitVoice.version,
        slashCommand = "/khajiitvoice",
        registerForRefresh = true,
    }

    local optionsData = {
        {
            type = "description",

            text = playerName,
            width = "full"
        },
        {
            type = "header",
            name = "General Settings"
        },
        {
            type = "checkbox",
            name = "Raised in Elsweyr",
            tooltip = function()
                return KhajiitVoice:GenerateRaisedinElsweyrDescription()
            end,
            getFunc = function() return KhajiitVoice.savedVars.permKhajiit end,
            setFunc = function(value) KhajiitVoice.savedVars.permKhajiit = value end,
        },
        {
            type = "editbox",
            name = "Custom Name",
            tooltip =
            "Enter a custom name to use instead of your character name",
            getFunc = function() return KhajiitVoice.savedVars.customAliasText or "" end,
            setFunc = function(value)
                KhajiitVoice.savedVars.customAliasText = value
                -- Auto-enable if text is entered
                if value and value ~= "" then
                    KhajiitVoice.savedVars.useCustomAlias = true
                else
                    KhajiitVoice.savedVars.useCustomAlias = false
                end
            end,
            isMultiline = false,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Use Custom Name",
            getFunc = function() return KhajiitVoice.savedVars.useCustomAlias end,
            setFunc = function(value) KhajiitVoice.savedVars.useCustomAlias = value end,
            disabled = function()
                return not KhajiitVoice.savedVars.customAliasText or KhajiitVoice.savedVars.customAliasText == "" or
                    not KhajiitVoice.savedVars.permKhajiit
            end,

        },

        {
            type = "header",
            name = "Self-Reference Tendencies"
        },
        {
            type = "slider",
            name = "\"This one\"",
            tooltip = "How often to use 'this one' (humble, traditional, mysterious)",
            min = 5,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.pronounWeights.thisOne end,
            setFunc = function(value) KhajiitVoice.savedVars.pronounWeights.thisOne = value end,
            disabled = function()
                return not KhajiitVoice.savedVars.permKhajiit
            end,
        },
        -- Update the Character Name slider tooltip to reflect this:
        {
            type = "slider",
            name = "Character Name",
            tooltip = function()
                if KhajiitVoice.savedVars.useCustomAlias and
                    KhajiitVoice.savedVars.customAliasText ~= "" then
                    return "How often to use your roleplay name '" ..
                        KhajiitVoice.savedVars.customAliasText .. "' (personal, confident)"
                else
                    return "How often to use your character's name (personal, confident)"
                end
            end,
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.pronounWeights.charName end,
            setFunc = function(value) KhajiitVoice.savedVars.pronounWeights.charName = value end,
            disabled = function()
                return not KhajiitVoice.savedVars.permKhajiit
            end,
        },
        {
            type = "slider",
            name = "\"Khajiit\"",
            tooltip = "How often to use 'Khajiit' (generic, formal, cautious)",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.pronounWeights.khajiit end,
            setFunc = function(value) KhajiitVoice.savedVars.pronounWeights.khajiit = value end,
            disabled = function()
                return not KhajiitVoice.savedVars.permKhajiit
            end,
        },
        {
            type = "slider",
            name = "Cyrodiilic",
            tooltip =
            "Higher values make your character speak more like a Cyrodiilic Imperial (less Khajiit speech patterns)",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.cyrodiilicTone end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.cyrodiilicTone = value end,
            disabled = function()
                return not KhajiitVoice.savedVars.permKhajiit
            end,
        },

        --[[{
            type = "header",
            name = "Personality Traits"
        },
        {
            type = "checkbox",
            name = "Friendly Goodbyes",
            tooltip = "Replace goodbye/farewell text with Khajiit expressions",
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.replaceGoodbyes end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.replaceGoodbyes = value end,
        },
        {
            type = "slider",
            name = "Kind Soul",
            tooltip =
            "A gentle and compassionate Khajiit who speaks with warmth and empathy. Uses friendly terms and caring expressions.",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.kindSoulTone end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.kindSoulTone = value end,
        },
        {
            type = "slider",
            name = "Curious",
            tooltip =
            "An inquisitive Khajiit who asks thoughtful questions and makes insightful observations. Speaks with natural curiosity about the world and its mysteries.",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.scholarlyTone end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.scholarlyTone = value end,
        --},]]

        {
            type = "header",
            name = "Support"
        },
        {
            type = "description",
            text = "Author: YFNatey, Xbox NA",
            width = "full"
        },
        {
            type = "description",
            text = "More Addons",
            tooltip = [[Cinematic Dialog Enhanced
- Removes forced camera angle when talking to NPCs
- Hide subtitles
- scrolling movie-like subtitles
- Extra cinematic features]],
            width = "full"
        },
        {
            type = "description",
            text = "If you enjoy this addon, consider supporting its development!",
            width = "full"
        },
        {
            type = "button",
            name = "Paypal",
            tooltip = "paypal.me/yfnatey",
            func = function() RequestOpenUnsafeURL("https://paypal.me/yfnatey") end,
            width = "half"
        },

    }

    LAM:RegisterAddonPanel("KhajiitVoicePanel", panelData)
    LAM:RegisterOptionControls("KhajiitVoicePanel", optionsData)
end

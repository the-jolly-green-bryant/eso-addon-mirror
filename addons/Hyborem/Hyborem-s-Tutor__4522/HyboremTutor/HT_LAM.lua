HT_LAM = HT_LAM or {}

local function GetTimestamp()
    return os.date("%H:%M:%S")
end

local function d(msg)
    if not msg then return end
    local serverKey = GetWorldName()
    local vars = HyboremTutor_Vars and HyboremTutor_Vars[serverKey]
    if vars and vars.enableLogs then
        CHAT_SYSTEM:AddMessage(string.format("[%s] [HT_LAM] %s", GetTimestamp(), msg))
    end
end

local function GetVars()
    local serverKey = GetWorldName()
    HyboremTutor_Vars = HyboremTutor_Vars or {}
    HyboremTutor_Vars[serverKey] = HyboremTutor_Vars[serverKey] or {}
    return HyboremTutor_Vars[serverKey]
end

local charnames = {}
local charids = {}
local charid2charnames = {}
local selectedExcludeChar = "None selected"

function HT_LAM.BuildCharacterList()
    if not LibCharacterKnowledge then 
        return false
    end
    
    local charlist = LibCharacterKnowledge.GetCharacterList()
    if not charlist or type(charlist) ~= "table" or #charlist == 0 then 
        return false
    end
    
    charnames = {}
    charids = {}
    charid2charnames = {}
    
    for i = 1, #charlist do
        if charlist[i] and charlist[i].name and charlist[i].name ~= "" then
            charnames[i] = charlist[i].name
            charids[i] = tostring(charlist[i].id)
            charid2charnames[tostring(charlist[i].id)] = charlist[i].name
        end
    end
    
    d("Character list built: " .. (#charlist))
    return true
end

function HT_LAM.GetCharacterChoices()
    return charnames
end

function HT_LAM.GetCharacterNameById(id)
    if not id or id == "0" or id == "None selected" then return "None selected" end
    return charid2charnames[tostring(id)] or "None selected"
end

function HT_LAM.GetCharacterIdByName(name)
    if name == "None selected" then return "0" end
    for id, n in pairs(charid2charnames) do
        if n == name then
            return id
        end
    end
    return "0"
end

function HT_LAM.GetSelectedExcludeChar()
    return selectedExcludeChar
end

function HT_LAM.SetSelectedExcludeChar(name)
    selectedExcludeChar = name
end

function HT_LAM.CreateMenu()
    if not LibAddonMenu2 then
        d("LibAddonMenu2 not found")
        return
    end
    
    if not HT_LAM.BuildCharacterList() then
        d("ERROR: Failed to build character list - LCK not ready!")
        return
    end
    
    local panelData = {
        type = "panel",
        name = "Hyborem's Tutor",
        displayName = "|cFFFF00Hyborem's Tutor|r",
        author = "Hyborem",
        version = "1.0.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local options = {}
    local priorityChoices = { "Priority", "Price limit" }
    local tooltipModeChoices = { "All characters", "Only missing (can learn)", "Only traders" }

    table.insert(options, {
        type = "description",
        text = "|c00FF00Priority|r = ignores price limit\n|cFF0000Price limit|r = respects global limit",
        fontSize = "medium",
    })

    for i = 1, 3 do
        table.insert(options, { type = "header", name = "Priority Slot " .. i })

        table.insert(options, {
            type = "dropdown",
            name = "Assign Character",
            choices = charnames,
            getFunc = function()
                local vars = GetVars()
                local p = vars["p"..i]
                if not p or p.char == "0" or p.char == "None selected" then
                    return "None selected"
                end
                return HT_LAM.GetCharacterNameById(p.char)
            end,
            setFunc = function(selectedName)
                local vars = GetVars()
                if not vars["p"..i] then
                    vars["p"..i] = { char = "0", m = false, r = false, p = false }
                end
                local id = HT_LAM.GetCharacterIdByName(selectedName)
                vars["p"..i].char = id
                d("Slot "..i.." set to: "..selectedName.." (ID: "..id..")")
            end,
            width = "full",
        })

        table.insert(options, {
            type = "dropdown",
            name = "Motifs",
            choices = priorityChoices,
            getFunc = function()
                local vars = GetVars()
                local p = vars["p"..i]
                return (p and p.m) and priorityChoices[1] or priorityChoices[2]
            end,
            setFunc = function(v)
                local vars = GetVars()
                if not vars["p"..i] then
                    vars["p"..i] = { char = "0", m = false, r = false, p = false }
                end
                vars["p"..i].m = (v == priorityChoices[1])
            end,
        })

        table.insert(options, {
            type = "dropdown",
            name = "Recipes",
            choices = priorityChoices,
            getFunc = function()
                local vars = GetVars()
                local p = vars["p"..i]
                return (p and p.r) and priorityChoices[1] or priorityChoices[2]
            end,
            setFunc = function(v)
                local vars = GetVars()
                if not vars["p"..i] then
                    vars["p"..i] = { char = "0", m = false, r = false, p = false }
                end
                vars["p"..i].r = (v == priorityChoices[1])
            end,
        })

        table.insert(options, {
            type = "dropdown",
            name = "Plans",
            choices = priorityChoices,
            getFunc = function()
                local vars = GetVars()
                local p = vars["p"..i]
                return (p and p.p) and priorityChoices[1] or priorityChoices[2]
            end,
            setFunc = function(v)
                local vars = GetVars()
                if not vars["p"..i] then
                    vars["p"..i] = { char = "0", m = false, r = false, p = false }
                end
                vars["p"..i].p = (v == priorityChoices[1])
            end,
        })
    end

    table.insert(options, { type = "header", name = "Trader" })
    table.insert(options, {
        type = "dropdown",
        name = "Assign Trader",
        choices = charnames,
        getFunc = function()
            local vars = GetVars()
            local val = vars.trader or "0"
            if val == "None selected" then return "None selected" end
            return HT_LAM.GetCharacterNameById(val)
        end,
        setFunc = function(selectedName)
            local vars = GetVars()
            local id = HT_LAM.GetCharacterIdByName(selectedName)
            vars.trader = id
            d("Trader set to: "..selectedName.." (ID: "..id..")")
        end,
        width = "full",
    })

    table.insert(options, { type = "header", name = "Script Learning" })
    table.insert(options, {
        type = "dropdown",
        name = "Assign Script Learner",
        choices = charnames,
        getFunc = function()
            local vars = GetVars()
            local val = vars.scriptLearner or "0"
            if val == "None selected" then return "None selected" end
            return HT_LAM.GetCharacterNameById(val)
        end,
        setFunc = function(selectedName)
            local vars = GetVars()
            local id = HT_LAM.GetCharacterIdByName(selectedName)
            vars.scriptLearner = id
            d("Script Learner set to: "..selectedName.." (ID: "..id..")")
        end,
        width = "full",
    })

    -- Auto-Learning Settings
    table.insert(options, { type = "header", name = "Auto-Learning Settings" })
    table.insert(options, {
        type = "checkbox",
        name = "Autolearn Outfit Styles (Bound)",
        getFunc = function()
            local vars = GetVars()
            return vars.autolearnBoundStyles == true
        end,
        setFunc = function(v)
            local vars = GetVars()
            vars.autolearnBoundStyles = v
        end,
    })
    table.insert(options, {
        type = "checkbox",
        name = "Autolearn Outfit Styles (Unbound)",
        getFunc = function()
            local vars = GetVars()
            return vars.autolearnUnboundStyles == true
        end,
        setFunc = function(v)
            local vars = GetVars()
            vars.autolearnUnboundStyles = v
        end,
    })
    table.insert(options, {
        type = "checkbox",
        name = "Autolearn Unbound Scripts",
        getFunc = function()
            local vars = GetVars()
            return vars.autolearnUnboundScripts == true
        end,
        setFunc = function(v)
            local vars = GetVars()
            vars.autolearnUnboundScripts = v
        end,
    })
    table.insert(options, {
        type = "editbox",
        name = "Max scripts per type to keep in bank",
        isNumeric = true,
        getFunc = function()
            local vars = GetVars()
            return tostring(vars.minScripts or 0)
        end,
        setFunc = function(v)
            local vars = GetVars()
            vars.minScripts = tonumber(v) or 0
        end,
    })

    -- Price Limits
    table.insert(options, { type = "header", name = "Price Limits (Gold)" })
    table.insert(options, {
        type = "editbox",
        name = "Limit: Motifs",
        isNumeric = true,
        getFunc = function()
            local vars = GetVars()
            return tostring(vars.lM or 5000)
        end,
        setFunc = function(v)
            local vars = GetVars()
            vars.lM = tonumber(v) or 0
        end,
        default = "5000",
    })
    table.insert(options, {
        type = "editbox",
        name = "Limit: Recipes",
        isNumeric = true,
        getFunc = function()
            local vars = GetVars()
            return tostring(vars.lR or 20000)
        end,
        setFunc = function(v)
            local vars = GetVars()
            vars.lR = tonumber(v) or 0
        end,
        default = "20000",
    })
    table.insert(options, {
        type = "editbox",
        name = "Limit: Plans",
        isNumeric = true,
        getFunc = function()
            local vars = GetVars()
            return tostring(vars.lP or 3000)
        end,
        setFunc = function(v)
            local vars = GetVars()
            vars.lP = tonumber(v) or 0
        end,
        default = "3000",
    })
    table.insert(options, {
        type = "editbox",
        name = "Limit: Scripts",
        isNumeric = true,
        getFunc = function()
            local vars = GetVars()
            return tostring(vars.lS or 5000)
        end,
        setFunc = function(v)
            local vars = GetVars()
            vars.lS = tonumber(v) or 0
        end,
        default = "5000",
    })
    table.insert(options, {
        type = "editbox",
        name = "Limit: Style Pages",
        isNumeric = true,
        getFunc = function()
            local vars = GetVars()
            return tostring(vars.lST or 10000)
        end,
        setFunc = function(v)
            local vars = GetVars()
            vars.lST = tonumber(v) or 0
        end,
        default = "10000",
    })

    -- Tooltip Settings (NOWA SEKCJA)
    table.insert(options, { type = "header", name = "Tooltip Settings" })
    table.insert(options, {
        type = "checkbox",
        name = "Enable tooltips",
        getFunc = function()
            local vars = GetVars()
            return vars.enableTooltips == true
        end,
        setFunc = function(v)
            local vars = GetVars()
            vars.enableTooltips = v
        end,
    })
    table.insert(options, {
        type = "dropdown",
        name = "Tooltip Display Mode",
        tooltip = "What to show in item tooltips",
        choices = tooltipModeChoices,
        getFunc = function()
            local vars = GetVars()
            return vars.tooltipMode or "All characters"
        end,
        setFunc = function(v)
            local vars = GetVars()
            vars.tooltipMode = v
        end,
        width = "full",
    })

    -- Excluded Characters (NOWA SEKCJA)
    table.insert(options, { type = "header", name = "Excluded Characters" })
    table.insert(options, {
        type = "description",
        text = "Characters listed here will be ignored by the auto-learn system.",
        fontSize = "small",
    })

    table.insert(options, {
        type = "dropdown",
        name = "Select Character",
        choices = charnames,
        getFunc = function()
            return selectedExcludeChar
        end,
        setFunc = function(selectedName)
            selectedExcludeChar = selectedName
        end,
        width = "half",
    })

    table.insert(options, {
        type = "button",
        name = function()
            local selected = selectedExcludeChar
            if not selected or selected == "None selected" then
                return "Add Selected"
            end
            local vars = GetVars()
            local excluded = vars.excludedCharacters or {}
            local isExcluded = false
            for _, name in ipairs(excluded) do
                if name == selected then
                    isExcluded = true
                    break
                end
            end
            return isExcluded and "Remove Selected" or "Add Selected"
        end,
        func = function()
            local vars = GetVars()
            local selected = selectedExcludeChar
            if not selected or selected == "None selected" then
                d("No character selected")
                return
            end
            vars.excludedCharacters = vars.excludedCharacters or {}
            local found = false
            for i, name in ipairs(vars.excludedCharacters) do
                if name == selected then
                    table.remove(vars.excludedCharacters, i)
                    found = true
                    d("Removed " .. selected .. " from excluded list")
                    break
                end
            end
            if not found then
                table.insert(vars.excludedCharacters, selected)
                d("Added " .. selected .. " to excluded list")
            end
            LibAddonMenu2:RefreshPanel("HyboremTutor_Menu")
        end,
        width = "half",
    })

    table.insert(options, {
        type = "description",
        name = "Excluded List",
        text = function()
            local vars = GetVars()
            local excluded = vars.excludedCharacters or {}
            if #excluded == 0 then
                return "No excluded characters"
            end
            return table.concat(excluded, ", ")
        end,
        width = "full",
    })

    -- Debug
    table.insert(options, { type = "header", name = "Debug" })
    table.insert(options, {
        type = "checkbox",
        name = "Enable debug messages",
        getFunc = function()
            local vars = GetVars()
            return vars.enableLogs == true
        end,
        setFunc = function(v)
            local vars = GetVars()
            vars.enableLogs = v
        end,
    })
    table.insert(options, {
        type = "checkbox",
        name = "Auto-learn from inventory after closing bank",
        getFunc = function()
            local vars = GetVars()
            return vars.autoLearnEnabled == true
        end,
        setFunc = function(v)
            local vars = GetVars()
            vars.autoLearnEnabled = v
        end,
        default = false,
    })

    -- Donate button
    table.insert(options, {
        type = "button",
        name = "|t32:32:HyboremTutor/icon/Hyborem.dds|t Donate",
        func = function()
            SCENE_MANAGER:Show('mailSend')
            zo_callLater(function()
                ZO_MailSendToField:SetText("@HyboremInfernal")
                ZO_MailSendSubjectField:SetText("Hyborem's Tutor Support")
            end, 250)
        end,
        width = "full",
    })

    LibAddonMenu2:RegisterAddonPanel("HyboremTutor_Menu", panelData)
    LibAddonMenu2:RegisterOptionControls("HyboremTutor_Menu", options)
    
    d("Menu created successfully with " .. (#charnames) .. " characters")
end
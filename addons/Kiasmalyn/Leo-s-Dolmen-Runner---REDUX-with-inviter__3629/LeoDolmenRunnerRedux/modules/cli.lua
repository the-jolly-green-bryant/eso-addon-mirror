------------------------------------------
-- CLI configuration
------------------------------------------
LeoDolmenRunnerRedux = LeoDolmenRunnerRedux or {}

LDR = LeoDolmenRunnerRedux

LDR.help = function()
    local helpMessage = {
        "Available options: ",
        "    /lrr toggle",
        "    ------- Blacklist --------",
        "    /lrr bl",
        "    /lrr bl add <name>",
        "    /lrr bl rem <name>",
        "    /lrr bl clear",
        "    -------- Inviter ---------",
        "    /lrr ai list",
        '    /lrr ai add "<term>"',
        '    /lrr ai rem "<term>"',
        "    /lrr ai reset"
    }

    LDR.utils:PrintArrayInList(helpMessage)

    return
end

SLASH_COMMANDS["/lrr"] = function(cmd)
    -------------------------------
    --- extract options.  also captures anything in quotes for later parsing
    -------------------------------
    local options = {}
    index = 1
    quotedText = string.match(cmd, '%b""')
    if quotedText ~= nil then
        quotedText = (quotedText:gsub('"', ''))
        LDR.utils:Debug(zo_strformat(GetString(LRR_DEBUG_QUOTED_TEXT_FOUND), quotedText))
    end

    for value in string.gmatch(cmd, "%w+") do
        options[index] = value
        index = index + 1
    end

    LDR.utils:Debug(zo_strformat(GetString(LRR_DEBUG_NUM_OPTS_FOUND), tostring(#options)))

    ---------------------------------
    --- help option capture
    ---------------------------------
    if #options == 0 or options[1] == "help" then
        LDR.help()
        return
    end

    ---------------------------------
    --- UI option capture
    ---------------------------------
    if options[1] == GetString(LRR_COMMAND_OPT_TOGGLE) then
        LDR.ui:ToggleShow()
    elseif options[1] == "admin" and #options == 2 and options[2] == "wayshrines" then
        -- prints a list of wayshrines and node numbers in the chat box
        local totalNodes = GetNumFastTravelNodes()
        d("TotalNodes: " .. totalNodes)
        local i = 1
        while i <= totalNodes do
            local _, name, _, _, icon = GetFastTravelNodeInfo(i)
            d("Node: " .. i .. ", " .. name)

            i = i + 1
        end
    ---------------------------------
    --- Blacklist option capture
    ---------------------------------
    elseif options[1] == GetString(LRR_COMMAND_OPT_BL) then
        if #options == 2 and options[2] == GetString(LRR_COMMAND_PARAM_CLEAR) then
            LDR.inviter:ClearBlacklist()
        elseif #options == 3 and options[2] == GetString(LRR_COMMAND_PARAM_ADD) then
            LDR.inviter:AddPlayerToBlacklist(options[3])
        elseif #options == 3 and options[2] == GetString(LRR_COMMAND_PARAM_REM) then
            LDR.inviter:RemovePlayerFromBlacklist(options[3])
        else
            LDR.inviter:DisplayBlacklist()
        end
    ---------------------------------
    --- Debug option capture
    ---------------------------------
    elseif options[1] == GetString(LRR_COMMAND_OPT_DEBUG) and #options == 2 then
        LDR.utils:ToggleDebug(options[2])
    ---------------------------------
    --- Auto Inviter option capture
    ---------------------------------
    elseif options[1] == GetString(LRR_COMMAND_OPT_AI) then
        ------------ just reset terms
        if #options == 2 and options[2] == GetString(LRR_COMMAND_PARAM_RESET) then
            LDR.settings.inviter.terms = LDR.defaults.inviter.terms
            LDR.utils:Log(GetString(LRR_COMMAND_FEEDBACK_TERMS_RESET))
            ------------ add terms
        elseif #options >= 3 and options[2] == GetString(LRR_COMMAND_PARAM_ADD) then
            local toAdd = quotedText

            if quotedText == nil then
                if type(options[3]) == "string" and options[3] ~= nil then
                    -- must be single word with no quotes
                    toAdd = options[3]
                end
            end

            if type(toAdd) == "string" then
                LDR.utils:Debug(zo_strformat(GetString(LRR_DEBUG_NUM_OPTS_ADDING_TERM), toAdd))
                LDR.inviter:AddTermToMessageList(toAdd)
            end

            ----------- remove terms
        elseif #options >= 3 and options[2] == GetString(LRR_COMMAND_PARAM_REM) then
            local toRemove = quotedText
            if toRemove == nil and type(options[3]) == "string" and options[3] ~= nil then
                toRemove = options[3]
            end

            if toRemove ~= nil then
                LDR.utils:Debug((zo_strformat(GetString(LRR_DEBUG_NUM_OPTS_REMOVE_TERM), toRemove)))
                LDR.inviter:RemoveTermFromMessageList(toRemove)
            end
        else
            LDR.inviter:DisplayTerms()
        end
    else
        LDR.utils:Log(GetString(LRR_COMMAND_OPT_UNKNOWN))
        LDR.help()
    end
end

-- setup reload alias command and set debug if me
if GetDisplayName() == LDR.username then
    SLASH_COMMANDS["/re"] = function(cmd)
        ReloadUI()
    end
    LDR.utils.isDebug = true
end
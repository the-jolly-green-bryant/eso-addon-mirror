--- @class (partial) AbilityIconsFramework
local AbilityIconsFramework = AbilityIconsFramework

--- Creates slash commands to be used for debugging.
function AbilityIconsFramework.CreateSlashCommands()
    AbilityIconsFramework.CreateGetAbilityDetailsCommand()
    AbilityIconsFramework.CreateGetIconsCommand()
    AbilityIconsFramework.CreteGetSavedVarsCommand()
    AbilityIconsFramework.CreateSetOptionGlobalIconsCommand()
    AbilityIconsFramework.CreateSetOptionSkillStyleIconsCommand()
    AbilityIconsFramework.CreateSetOptionCustomIconsCommand()
    AbilityIconsFramework.CreateSetOptionMismatchedIconsCommand()
end

--- Creates the /getabilitydetails command, to retrieve details about the ability found at a specified slot.
function AbilityIconsFramework.CreateGetAbilityDetailsCommand()
    SLASH_COMMANDS["/getabilitydetails"] = function(strInput)
        local params = {}
        for word in strInput:gmatch("%w+") do table.insert(params, word) end
        local skillIndex = params[1]
        local inactive = params[2] or "0"

        local hotbarCategory = GetActiveHotbarCategory()
        if inactive == "1" then
            hotbarCategory = hotbarCategory == HOTBAR_CATEGORY_PRIMARY
                             and HOTBAR_CATEGORY_BACKUP or HOTBAR_CATEGORY_PRIMARY
        end

        local baseAbilityId = AbilityIconsFramework.GetBaseAbilityId(skillIndex, hotbarCategory)
        CHAT_SYSTEM:AddMessage("Base Ability ID: " .. (baseAbilityId or -1))
        local abilityId = AbilityIconsFramework.GetAbilityId(skillIndex, hotbarCategory)
        CHAT_SYSTEM:AddMessage("Ability ID: " .. (abilityId or -1))

        local primaryScriptId, secondaryScriptId, tertiaryScriptId = GetCraftedAbilityActiveScriptIds(abilityId)
        local scriptLink = ""
        if primaryScriptId ~= 0 or secondaryScriptId ~= 0 or tertiaryScriptId ~= 0 then
            CHAT_SYSTEM:AddMessage("Focus Script: " .. GetCraftedAbilityScriptDisplayName(primaryScriptId) .. "(" .. primaryScriptId .. ")")
            CHAT_SYSTEM:AddMessage("Signature Script: " .. GetCraftedAbilityScriptDisplayName(secondaryScriptId) .. "(" .. secondaryScriptId .. ")")
            CHAT_SYSTEM:AddMessage("Affix Script: " .. GetCraftedAbilityScriptDisplayName(tertiaryScriptId) .. "(" .. tertiaryScriptId .. ")")
            if primaryScriptId ~= 0 and secondaryScriptId ~= 0 and tertiaryScriptId ~= 0 then
                scriptLink = ZO_LinkHandler_CreateChatLink(GetCraftedAbilityLink, abilityId, primaryScriptId, secondaryScriptId, tertiaryScriptId)
                CHAT_SYSTEM:AddMessage("Scribed Skill Link: " .. scriptLink)
            end
        end
    end
end

--- Creates the /geticons command, to retrieve available icons for the skill found at the specified slot.
function AbilityIconsFramework.CreateGetIconsCommand()
    SLASH_COMMANDS["/geticons"] = function(strInput)
        local params = {}
        for word in strInput:gmatch("%w+") do table.insert(params, word) end
        local skillIndex = params[1]
        local inactive = params[2] or "0"

        local hotbarCategory = GetActiveHotbarCategory()
        if inactive == "1" then
            hotbarCategory = hotbarCategory == HOTBAR_CATEGORY_PRIMARY
                             and HOTBAR_CATEGORY_BACKUP or HOTBAR_CATEGORY_PRIMARY
        end

        local collectibleIcon = AbilityIconsFramework.GetSkillStyleIcon(skillIndex, hotbarCategory)
        CHAT_SYSTEM:AddMessage("Collectible Icon: " .. (collectibleIcon or "nil"))
        local customIcon = AbilityIconsFramework.GetCustomAbilityIcon(skillIndex, hotbarCategory)
        CHAT_SYSTEM:AddMessage("Custom Icon: " .. (customIcon or "nil"))
        local abilityIcon = AbilityIconsFramework.GetDefaultAbilityIcon(skillIndex, hotbarCategory)
        CHAT_SYSTEM:AddMessage("Default Icon: " .. (abilityIcon or "nil"))
    end
end

--- Creates the /getsavedvars command, to check the contents of the addon's saved variables.
function AbilityIconsFramework.CreteGetSavedVarsCommand()
    SLASH_COMMANDS["/getsavedvars"] = function ()
        CHAT_SYSTEM:AddMessage("----------------------------------")

        local sv1 = AbilityIconsFramework_SavedVariables["Default"][GetDisplayName()]["$AccountWide"]
        CHAT_SYSTEM:AddMessage("AbilityIconsFramework_SavedVariables:")
        for key, value in pairs(sv1) do
            CHAT_SYSTEM:AddMessage("[" .. key .. "] -> " .. tostring(value))
        end

        CHAT_SYSTEM:AddMessage("----------------------------------")

        local sv2 = AbilityIconsFramework_Globals["Default"][GetDisplayName()]["$AccountWide"]["global_settings"]
        CHAT_SYSTEM:AddMessage("AbilityIconsFramework_Globals:")
        for key, value in pairs(sv2) do
            CHAT_SYSTEM:AddMessage("[" .. key .. "] -> " .. tostring(value))
        end

        CHAT_SYSTEM:AddMessage("----------------------------------")

        local sv3 = AbilityIconsFramework_Settings["Default"][GetDisplayName()][GetCurrentCharacterId()]["character_settings"]
        CHAT_SYSTEM:AddMessage("AbilityIconsFramework_Settings:")
        for key, value in pairs(sv3) do
            CHAT_SYSTEM:AddMessage("[" .. key .. "] -> " .. tostring(value))
        end

        CHAT_SYSTEM:AddMessage("----------------------------------")
    end
end

--- Creates the /setoptionglobalicons command, to change the display setting for global (Account Wide) Icons
function AbilityIconsFramework.CreateSetOptionGlobalIconsCommand()
    SLASH_COMMANDS["/setoptionglobalicons"] = function(option)
        if string.lower(option) == "false" or option == "0" or string.lower(option) == "off" then
            AbilityIconsFramework.SetOptionGlobalIcons(false)
            CHAT_SYSTEM:AddMessage("Glocal (Account Wide) Icons are now OFF")
        elseif string.lower(option) == "true" or option == "1" or string.lower(option) == "on" then
            AbilityIconsFramework.SetOptionGlobalIcons(true)
            CHAT_SYSTEM:AddMessage("Glocal (Account Wide) Icons are now ON")
        end
    end
end

--- Creates the /setoptionskillstyleicons command, to change the display setting for Skill Style Icons
function AbilityIconsFramework.CreateSetOptionSkillStyleIconsCommand()
    SLASH_COMMANDS["/setoptionskillstyleicons"] = function(option)
        if string.lower(option) == "false" or option == "0" or string.lower(option) == "off" then
            AbilityIconsFramework.SetOptionSkillStyleIcons(false)
            CHAT_SYSTEM:AddMessage("Skill Style Icons are now OFF")
        elseif string.lower(option) == "true" or option == "1" or string.lower(option) == "on" then
            AbilityIconsFramework.SetOptionSkillStyleIcons(true)
            CHAT_SYSTEM:AddMessage("Skill Style Icons are now ON")
        end
    end
end

--- Creates the /setoptioncustomicons command, to change the display setting for Custom Scribed Ability Icons
function AbilityIconsFramework.CreateSetOptionCustomIconsCommand()
    SLASH_COMMANDS["/setoptioncustomicons"] = function(option)
        if string.lower(option) == "false" or option == "0" or string.lower(option) == "off" then
            AbilityIconsFramework.SetOptionCustomIcons(false)
            CHAT_SYSTEM:AddMessage("Custom Scribed Ability Icons are now OFF")
        elseif string.lower(option) == "true" or option == "1" or string.lower(option) == "on" then
            AbilityIconsFramework.SetOptionCustomIcons(true)
            CHAT_SYSTEM:AddMessage("Custom Scribed Ability Icons are now ON")
        end
    end
end

--- Creates the /setoptionmismatchedicons command, to change the display setting for Mismatched Skill Icon replacements
function AbilityIconsFramework.CreateSetOptionMismatchedIconsCommand()
    SLASH_COMMANDS["/setoptionmismatchedicons"] = function(option)
        if string.lower(option) == "false" or option == "0" or string.lower(option) == "off" then
            AbilityIconsFramework.SetOptionMismatchedIcons(false)
            CHAT_SYSTEM:AddMessage("Mismatched Skill Icon replacements are now OFF")
        elseif string.lower(option) == "true" or option == "1" or string.lower(option) == "on" then
            AbilityIconsFramework.SetOptionMismatchedIcons(true)
            CHAT_SYSTEM:AddMessage("Mismatched Skill Icon replacements are now ON")
        end
    end
end

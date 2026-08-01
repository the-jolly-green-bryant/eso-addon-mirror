LibCustomDialog = {}
local LibCustomDialog = LibCustomDialog

LibCustomDialog.name = "LibCustomDialog"
LibCustomDialog.version = 1.0

LibCustomDialog.MAX_CHATTER_OPTIONS = 10 -- same as base game, don't wanna break things ;)

LibCustomDialog.DECORATOR_NONE = 1
LibCustomDialog.DECORATOR_PERSUADE = 2
LibCustomDialog.DECORATOR_INTIMIDATE = 3
LibCustomDialog.DECORATOR_LIE = 4

LibCustomDialog.InteractionGlobal = INTERACTION

-- Dialog Reference:
--     speaker          Who is speaking (displayed in the header line)    
--     text             The dialog text
--     textfemale       A variant for female characters to be used instead of the "text" member
--     insertCharName   If true, the string in the text field gets used in a zo_strformat with the players name.
--                      Make sure to use the <<1>> where you want the character name to be.
--     options          The options, see options reference. Also note, the "Goodbye" option will be added automatically.
--                      ESO supports 10 entries for options, with one being always used with the "Goodbye" option (= 9 available for you)
-- 
-- Options Reference:
--     text             The display text of the option
--     textfemale       A variant for female characters to be used instead of the "text" member
--     decorator        If for example persuasion or intimidation is required
--     nextDialog       The next dialog object to be displayed in the dialog tree
--     important        If true, the option will get highlighted red (refer to choices in a dialog trees in quests)
--     seen             If true, the option will get grayed out (you don't want to set this to true yourself normally)
--     type             The type of option. Typically you want CHATTER_START_TALK, but refer to MsgInteractType on ESOUI for other values
--     callback         A function to be executed if the option gets selected.
--     endDialog        Option to end the dialog tree there, without the use of another dialog screen with only a "Goodbye" option.
--     insertCharName   If true, the string in the text field gets used in a zo_strformat with the players name.
--                      Make sure to use the <<1>> where you want the character name to be.


-- Handler function for gamepad changed event
function LibCustomDialog.UpdateGamepadMode()
    if IsInGamepadPreferredMode() then
        LibCustomDialog.InteractionGlobal = GAMEPAD_INTERACTION
    else
        LibCustomDialog.InteractionGlobal = INTERACTION
    end
end


-- Starts the display with a dialogObject. See reference on how those objects are supposed to look like
function LibCustomDialog.ShowDialog(dialogObject, useCharacterFraming)
    -- Not yet determined if it's necessary or if, what of it is
    local CONVERSATION_INTERACTION = {
        type = "Interact",
        interactTypes = { INTERACTION_CONVERSATION, INTERACTION_QUEST },
        OnInteractSwitch = function() INTERACTION:SwitchInteraction() end,
    }

    dialogObject = dialogObject or {}
    local dialog = {
        speaker = dialogObject.speaker or "No speaker provided",
        text = dialogObject.text or "No text provided",
        textfemale = dialogObject.textfemale or nil,
        options = dialogObject.options or {},
        insertCharName = dialogObject.insertCharName or false,
    }
    
    
    -- Reset last interaction and set new message. Check for gender specific variant and displays it instead if applicable.
    local text = dialog.text
    if dialog.textfemale and (GetUnitGender("player") == GENDER_FEMALE) then
        text = dialog.textfemale 
    end 
    if dialog.insertCharName then
        text = zo_strformat(text, GetUnitName("player"))
    end
    
    LibCustomDialog.InteractionGlobal:ResetInteraction(text)

    
    
    -- Set speaker name
    local speakertext = ""
    if dialog.speaker ~= "" then
        speakertext = zo_strformat("-<<1>>-", dialog.speaker)
    end
    if IsInGamepadPreferredMode() then -- This needs to be done separate, as the title control has a different name on both modes
        GAMEPAD_INTERACTION.control:GetNamedChild("Title"):SetText(speakertext)
    else
        INTERACTION.control:GetNamedChild("TargetAreaTitle"):SetText(speakertext)
    end
    
    
    
    -- Setup the options
    LibCustomDialog.PopulateChatterOptions(dialog.options)
    
    -- Show the dialog window
    INTERACT_WINDOW:OnBeginInteraction(CONVERSATION_INTERACTION)
    ZO_InteractionManager:ShowInteractWindow()
    
    if useCharacterFraming then
        d("[LibCustomDialog] Framing character for chatter window (not yet implemented)")
    end
end

function LibCustomDialog.ResetDialogSeen(dialogObject)
    if not dialogObject or not dialogObject.options or type(dialogObject.options ~= "table") then return end
    for _, option in ipairs(dialogObject.options) do
        option.seen = nil
        if option.nextDialog then LibCustomDialog.ResetDialogSeen(option.dialog) end
    end
end


function LibCustomDialog.PopulateChatterOptions(options)
    -- INTERACTION:PopulateChatterOption(controlIndex, callback, displayText, type, additionalArg, importantOption, seen, importantOptionsArray)
    --      controlIndex            (number)                index of the option control (1-10)
    --      callback or dialog id   (function or number)    either a function with custom code or a number for a dialog index (use function whenever possible)
    --      displayText             (string)                what's to be displayed for the option
    --      type                    (MsgInteractType)       See esoui wiki globals for option (Seems not to matter what you use)
    --      additionalArg           (number)                for gold payments for example
    --      importantOption         (bool)                  if true, all options flagged true will get highlighted red (refer to choices in a dialog trees in quests)
    --      seen                    (bool)                  if true, option gets grayed / marked as seen
    --      importantOptionsArray   (table)                 a reference to a table holding all options to be marked as important


    -- Reset important options
    LibCustomDialog.InteractionGlobal.importantOptions = {}
    
    
    -- Build options
    for i, optionData in ipairs(options) do
        if i < LibCustomDialog.MAX_CHATTER_OPTIONS then
            local option = {
                text = optionData.text or "No text provided",
                textfemale = optionData.text or nil,
                type = optionData.type or CHATTER_START_TALK,
                callback = optionData.callback or nil,
                important = optionData.important or false,
                seen = optionData.seen or false,
                nextDialog = optionData.nextDialog or false,
                endDialog = optionData.endDialog or false,
                decorator = optionData.decorator or LibCustomDialog.DECORATOR_NONE,
                insertCharName = optionData.insertCharName or false,
            }
            
            
            -- Set text with regard of player character gender
            local text = ""
            if option.textfemale and (GetUnitGender("player") == GENDER_FEMALE) then
                text = option.textfemale
            else
                text = option.text
            end
            
            -- Insert the player character's name if so desired
            if insertCharName then
                text = zo_strformat(text, GetUnitName("player"))
            end
            
            
            if option.decorator == LibCustomDialog.DECORATOR_INTIMIDATE then
                local type, lineindex = GetSpecificSkillAbilityKeysByAbilityId(29062) 
                local _, _, _, _, _, hasIntimidateUnlocked = GetSkillAbilityInfo(type, lineindex, 6)
                
                if not hasIntimidateUnlocked then
                    option.type = CHATTER_TALK_CHOICE_INTIMIDATE_DISABLED
                    text = zo_strformat(SI_CONVERSATION_OPTION_SPEECHCRAFT_UNUSUABLE_FORMAT, GetString(SI_CONVERSATION_OPTION_SPEECHCRAFT_INTIMIDATE), text)
                    -- d("[LibCustomDialog] Intimidation failed")
                else
                    text = zo_strformat(SI_CONVERSATION_OPTION_SPEECHCRAFT_FORMAT, GetString(SI_CONVERSATION_OPTION_SPEECHCRAFT_INTIMIDATE), text)
                    -- d("[LibCustomDialog] Intimidation successful")
                end
            elseif option.decorator == LibCustomDialog.DECORATOR_PERSUADE then
                local type, lineindex = GetSpecificSkillAbilityKeysByAbilityId(29061) 
                local _, _, _, _, _, hasPersuadeUnlocked = GetSkillAbilityInfo(type, lineindex, 6)

                if not hasPersuadeUnlocked then
                    option.type = CHATTER_TALK_CHOICE_PERSUADE_DISABLED
                    text = zo_strformat(SI_CONVERSATION_OPTION_SPEECHCRAFT_UNUSUABLE_FORMAT, GetString(SI_CONVERSATION_OPTION_SPEECHCRAFT_PERSUADE), text)
                    -- d("[LibCustomDialog] Persuasion failed")
                else
                    text = zo_strformat(SI_CONVERSATION_OPTION_SPEECHCRAFT_FORMAT, GetString(SI_CONVERSATION_OPTION_SPEECHCRAFT_PERSUADE), text)
                    -- d("[LibCustomDialog] Persuasion successful")
                end
            elseif option.decorator == LibCustomDialog.DECORATOR_LIE then

            else

            end
      
            
      
            
            LibCustomDialog.InteractionGlobal:PopulateChatterOption(i, function()
                -- d("[LibCustomDialog] Clicked option \"" .. option.text .. "\".")
                
                -- mark option as seen
                options[i].seen = true
                
                -- if there is a callback, fire it
                if option.callback and type(option.callback) == "function" then
                    -- d("[LibCustomDialog] Firing attached callback function")
                    option.callback()
                end
                
                -- In case there is no endDialog flag but also no next dialog.
                if not option.endDialog and not option.nextDialog then
                    option.endDialog = true
                end
                
                
                -- if the tree ends here, close the chatter window
                if option.endDialog then
                    -- d("[LibCustomDialog] End of dialog tree.")
                    LibCustomDialog.InteractionGlobal:CloseChatter()
                end
                
                -- if there is another dialog to show, show it!
                if option.nextDialog then
                    -- d("[LibCustomDialog] Showing attached continuation")
                    LibCustomDialog.ShowDialog(option.nextDialog)
                end
            end, text, option.type, nil, option.important, option.seen, LibCustomDialog.InteractionGlobal.importantOptions)
        end
    end
    
    -- Get the index for the Goodbye entry
    local farewellIndex = 10
    if #options < LibCustomDialog.MAX_CHATTER_OPTIONS then
        farewellIndex = #options + 1
    end
    
    -- Goodbye option
    LibCustomDialog.InteractionGlobal:PopulateChatterOption(farewellIndex, function()
        -- d("[LibCustomDialog] Closed dialog with 'Goodbye'")
        LibCustomDialog.InteractionGlobal:CloseChatter()
    end, GetString(SI_GOODBYE), CHATTER_GOODBYE, nil, false, false, LibCustomDialog.InteractionGlobal.importantOptions)

    -- Finalize options
    LibCustomDialog.InteractionGlobal:FinalizeChatterOptions(farewellIndex)
end


local function OnLibraryLoaded(event, addonName)
    if addonName ~= LibCustomDialog.name then return end
    EVENT_MANAGER:UnregisterForEvent(LibCustomDialog.name, EVENT_ADD_ON_LOADED)
    
    EVENT_MANAGER:RegisterForEvent(LibCustomDialog.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, LibCustomDialog.UpdateGamepadMode)
    LibCustomDialog.UpdateGamepadMode()
end
EVENT_MANAGER:RegisterForEvent(LibCustomDialog.name, EVENT_ADD_ON_LOADED, OnLibraryLoaded)
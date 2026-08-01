LibCraftText = LibCraftText or {}


-- Quest Names ---------------------------------
--
-- Pass quest name from GetJournalQuestInfo()[1]:
--      local quest_name = GetJournalQuestInfo(i)
--      local quest_type = LibCraftText.DailyQuestNameToCraftingType(quest_name)
--

-- Return CRAFTING_TYPE_BLACKSMITHING for "Blacksmithing Writ" and so on.
-- Return nil if not a known daily crafting quest name.
--
function LibCraftText.DailyQuestNameToCraftingType(quest_name)
    LibCraftText.BuildReverseLookupTables()
    return LibCraftText.DAILY.QUEST_NAME[quest_name]
end

-- Return a list of 1 or more crafting types that match the given
-- quest name.
--
-- Both Blacksmithing and Woodworking use "A Masterful Weapon" for one of
-- their possible quest names, which is why you can sometimes get a list
-- of two possible crafting types.
--
function LibCraftText.MasterQuestNameToCraftingTypeList(quest_name)
    LibCraftText.BuildReverseLookupTables()
    return LibCraftText.MASTER.QUEST_NAME[quest_name]
end


-- Quest Conditions ----------------------------------------------------------
--
-- Return a table that describes what this quest condtion requires.
--
-- Table fields vary depending on crafting type and condition, but field
-- values will be rows from lang/xx.lua tables.
--
--              BS/CL/WW/JW
-- item         ITEM                H1_SWORD            "Craft Normal
-- material     MATERIAL            RUBEDITE              Rubedite Sword"
-- quality      QUALITY             EPIC                "Quality: Epic"
-- trait        TRAIT               WEAPON_SHARPENED    "Trait: Sharpened"
-- set          SET                 MORKULDIN           "Set: Morkuldin"
-- motif        MOTIF               WOOD_ELF            "Style: Wood Elf"
--
--              Enchanting          "Craft Grand Glyph of Health With Ta"
-- potency      MATERIAL            DERADO
-- essence      "                   OKO
-- aspect       "                   TA
--
--              Alchemy             "Craft Essence of Ravage Health"
-- trait        ALCHEMY_TRAIT       RAVAGE_HEALTH
-- solvent      MATERIAL            LORKHANS_TEARS
-- trait_list   { BREACH            "with the following traits:"
--              , FRACTURE
--              , RAVAGE_HEALTH }
--
--              Provisioning        "Craft Baked Potato"
-- item         RECIPE              BAKED_POTATO
--
--              Enchanting, Alchemy "Acquire Ta Aspect Rune"
-- material     MATERIAL            TA
--
--              Miscellaneous       "Deliver Goods to Nearest Writ Quartermaster"
-- misc         DAILY.COND          DELIVER_NEAREST_QUARTERMASTER
--                                  "Travel to Mournhold to Meet Your Contact"
--              MASTER.COND         TRAVEL_EP
--
function LibCraftText.ParseDailyCondition(crafting_type, cond_text)
    return LibCraftText.Daily.ParseConditionInternal(crafting_type, cond_text)
end

function LibCraftText.ParseMasterCondition(crafting_type, cond_text)
    return LibCraftText.Master.ParseConditionInternal(crafting_type, cond_text)
end


-- Quest Dialogs -------------------------------------------------------------
--
-- Convert dialog titles or options to their corresponding crafting_type.

                        -- "-Blacksmith Delivery Crate-"
function LibCraftText.DailyDialogTurnInTitleToCraftingType(dialog_title)
    return LibCraftText.TableValueToKey(
              LibCraftText.DAILY.DIALOG.TITLE_TURN_IN
            , dialog_title
            )
end
                        -- "<Examine the Blacksmith Writs.>"
function LibCraftText.DailyDialogOptionToCraftingType(option_text)
    return LibCraftText.TableValueToKey(
              LibCraftText.DAILY.DIALOG.OPTION_EXAMINE
            , option_text
            )
end
                        -- Is this one of the two daily crafting writ boards?
                        -- "-Equipment Crafting Writs-"
                        -- "-Consumables Crafting Writs-"
function LibCraftText.DailyDialogTitleIsWritBoard(dialog_title)
    return LibCraftText.TableValueToKey(
              LibCraftText.DAILY.DIALOG.TITLE_OFFER
            , dialog_title
            )
end


-- Turning in Master Writs to Rolis Hlaalu -----------------------------------

-- Convert Rolis dialog option "I've finished the Blacksmithing job."
-- into CRAFTING_TYPE_BLACKSMITHING.
--
function LibCraftText.RolisDialogOptionToCraftingType(dialog_text)
    LibCraftText.BuildReverseLookupTables()
    return LibCraftText.MASTER.DIALOG.OPTION_FINISH[dialog_text]
end


-- Helpful Utilities ---------------------------------------------------------
--
-- These utilities are not the primary purpose of LibCraftText, but they
-- prove so helpful when using LibCraftText that I'll make them public.
--

-- Iterating
--
-- for step_i, cond_i in LibCraftText.EachCondition(quest_index) do
--      cond_text = GetJournalQuestConditionInfo(quest_index, step_i, cond_i)
--      result = LibCraftText.ParseDailyCondition(crafting_type, cond_text)
--      ...
-- end
--
function LibCraftText.EachCondition(quest_index)
    local step_i = 1
    local cond_i = 0
                        -- Re-fetch step and condition counts with
                        -- each iteration, just in case calling code
                        -- changed things out from under us.
    local function next()
                        -- Advance to next condition within current step
        cond_i = cond_i + 1
                        -- Did we advance to the next step?
        local step_info    = { GetJournalQuestStepInfo(quest_index, step_i) }
        local condition_ct = step_info[5]
        if cond_i <= condition_ct then
                        -- RETURN next condtion within current step.
            return step_i, cond_i
        end

        cond_i = 1

                    -- Advance to next step that has conditions.
        local step_ct = GetJournalQuestNumSteps(quest_index)
        step_i  = step_i + 1
        while step_i <= step_ct do
            local step_info = { GetJournalQuestStepInfo(quest_index, step_i) }
            local cond_ct   = step_info[5]
            if 1 <= cond_ct then
                    -- RETURN first condition of next step.
                return step_i, cond_i
            end
        end
                    -- END ITERATION: We've run out of steps. We're done
        return nil
    end

    return next
end

-- Just parse it and tell me the results.
--
-- Figures out whether the quest is a daily or master writ quest, then
-- returns a list of result tables from either ParseDailyCondition() or
-- ParseMasterCondition().
--
-- Returns a list of result_table elements from Parse(Daily/Master)Condition above.
-- result_table elements also include step/condition indexes so that you can
-- match up these table with additional data from the ZOS API:
--
-- quest_index
-- step_index
-- condition_index
-- condition_text
--
function LibCraftText.ParseQuest(quest_index)
    local self = LibCraftText

                        -- Differentiate between daily or master writ.

                        -- Master writs never have more than one required item.
    local return_first_hit = true
                        -- Find the correct crafting_type(s)
    local quest_name       = GetJournalQuestInfo(quest_index)
    local ct_list          = self.MasterQuestNameToCraftingTypeList(quest_name)
    local func             = self.ParseMasterCondition
    if not ct_list then
        local ct = self.DailyQuestNameToCraftingType(quest_name)
        if not ct then return nil end
        ct_list = { ct }
        func = self.ParseDailyCondition
                        -- Daily writs have a list of up to three required
                        -- items (such as medium arm cops, bracers, helmet)
        return_first_hit = false
    end

    for _,crafting_type in ipairs(ct_list) do
        local result_list = {}
        for step_i, cond_i in self.EachCondition(quest_index) do
            local cond_text = GetJournalQuestConditionInfo( quest_index
                                                          , step_i
                                                          , cond_i )
            local result = func(crafting_type, cond_text)
            if result then
                result.quest_index     = quest_index
                result.step_index      = step_i
                result.condition_index = cond_i
                result.condition_text  = cond_text
                table.insert(result_list, result)
                if return_first_hit then
                    return result_list
                end
            end
        end
        if 0 < #result_list then
            return result_list
        end
    end
    return nil
end

                        -- Dump to chat window
function LibCraftText.ParseAndDump(quest_index)
    local self        = LibCraftText
    local result_list = self.ParseQuest(quest_index)
    self.DumpTable(result_list)
end

                        -- A recursive table dumper that does a marginally better
                        -- job of indenting than d()
function LibCraftText.DumpTable(t, indent_ct)
    local grey  = "|c999999"
    local white = "|cFFFFFF"
    local red   = "|cFF6666"
    if not t then
        d(red..tostring(t))
        return
    end
    indent_ct = indent_ct or 1
    local indent = string.format(".%"..(indent_ct*4).."."..(indent_ct*4).."s","")
                        -- Infinite recursion blocker
    if 4 < indent_ct then
        d(grey..indent.."...")
        return
    end
                        -- Can we squish down to single line?
    local has_sub_tables = false
    for _,v in pairs(t) do
        if type(v) == "table" then
            has_sub_tables = true
            break
        end
    end
    if not has_sub_tables then
        local line = ""
        local sorted = LibCraftText.SortedKeys(t)
        for _,k in ipairs(sorted) do
            local v = t[k]
            line = line .. string.format(grey.."%s:"..white.."%s  ",tostring(k),tostring(v))
        end
        d(indent..line)
    else
                        -- Gonna have to recurse, so print each key/value pair
                        -- on its own line.
        local sorted = LibCraftText.SortedKeys(t)
        for _,k in ipairs(sorted) do
            local v = t[k]
            local vv = tostring(v)
            if type(v) == "table" then vv = "table" end -- Omit useless hex addresses.
            d(string.format(grey..indent.."%-4s: "..white.."%s", tostring(k), vv))
            if type(v) == "table" then
                LibCraftText.DumpTable(v,1+indent_ct)
            end
        end
    end
end
                        -- To provide more stable output.
function LibCraftText.SortedKeys(t)
    local r = {}
    for k,_ in pairs(t) do
        table.insert(r,k)
    end
    table.sort(r)
    return r
end

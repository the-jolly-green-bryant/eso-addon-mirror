local A = ESOBuildTracker
local INPUT_DIALOG = "ESOBuildTrackerTextInput"

function A.RegisterInputDialog()
    if A.inputDialogRegistered then return end
    ZO_Dialogs_RegisterCustomDialog(INPUT_DIALOG, {
        gamepadInfo = { dialogType = GAMEPAD_DIALOGS.PARAMETRIC },
        blockDialogReleaseOnPress = true,
        title = { text = function(dialog) return dialog.data.title end },
        mainText = { text = "Select Edit to enter text, then Save. Back cancels." },
        setup = function(dialog, data)
            dialog.ebtValue, dialog.ebtSaved = data.value or "", nil
            dialog:setupFunc()
        end,
        parametricList = {
            { template = "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem", templateData = {
                setup = function(control, data, selected)
                    local dialog = data.dialog
                    control.highlight:SetHidden(not selected)
                    control.editBoxControl.textChangedCallback = function(edit) dialog.ebtValue = edit:GetText() end
                    control.editBoxControl:SetMaxInputChars(dialog.data.maxChars or 120)
                    control.editBoxControl:SetText(dialog.ebtValue)
                end,
                narrationText = ZO_GetDefaultParametricListEditBoxNarrationText,
            } },
        },
        buttons = {
            { keybind = "DIALOG_PRIMARY", text = "Edit", callback = function(dialog)
                local control = dialog.entryList:GetTargetControl()
                if control then control.editBoxControl:TakeFocus() end
            end },
            { keybind = "DIALOG_SECONDARY", text = "Save", callback = function(dialog)
                local value = (dialog.ebtValue or ""):match("^%s*(.-)%s*$")
                if dialog.data.validate then
                    local valid, message = dialog.data.validate(value)
                    if not valid then
                        A.Notify(message)
                        if dialog.warningTextControl then dialog.warningTextControl:SetText(message); dialog.warningTextControl:SetHidden(false) end
                        return
                    end
                end
                dialog.ebtSaved = value
                ZO_Dialogs_ReleaseDialogOnButtonPress(INPUT_DIALOG)
            end },
            { keybind = "DIALOG_NEGATIVE", text = "Cancel", callback = function() ZO_Dialogs_ReleaseDialogOnButtonPress(INPUT_DIALOG) end },
        },
        OnHiddenCallback = function(dialog)
            A.inputPromptOpen = false
            if dialog.ebtSaved ~= nil then dialog.data.commit(dialog.ebtSaved) end
            if A.scene and A.scene:IsShowing() then A.ResumeControls(); A.RebuildPages() end
        end,
    })
    A.inputDialogRegistered = true
end

function A.Input(title, value, commit, maxChars, validate)
    A.RegisterInputDialog()
    A.inputPromptOpen = true
    A.SuspendControls()
    ZO_Dialogs_ShowGamepadDialog(INPUT_DIALOG, {
        title = title, value = tostring(value or ""), commit = commit,
        maxChars = maxChars or 120, validate = validate,
    })
end

local function Nonempty(value)
    return value ~= "", "Enter a name, or cancel."
end

function A.RequireBuild()
    local build = A.ActiveBuild()
    if not build then A.Notify("Create or select a target build first."); A.ShowTab(4) end
    return build
end

function A.NewBuild(fromViewed)
    local snapshot = fromViewed and A.GetViewedSnapshot() or nil
    if fromViewed and not snapshot then A.Notify("Wait for a capture before copying it."); return end
    A.Input("Name your target build", "Build " .. A.saved.nextBuildNumber, function(name)
        local build, err = A.CreateBuild(name, snapshot)
        if not build then A.Notify(err); return end
        A.Notify("Target created: " .. build.name .. ". Select a Gear or Skills row to edit its requirements.")
        A.ShowTab(1)
    end, 60, Nonempty)
end

function A.OpenBuildMenu(id)
    local build
    for _, candidate in ipairs(A.saved.builds) do if candidate.id == id then build = candidate end end
    if not build then return end
    A.OpenMenu(build.name, function()
        return {
            A.Row("Use this target", build.name, "Apply this target to the Gear, Skills and Stats tabs.", function()
                A.saved.activeBuildId = id; A.Notify("Tracking: " .. build.name); A.ShowTab(1)
            end),
            A.Row("Rename build", build.name, "Change the target's name.", function()
                A.Input("Rename build", build.name, function(value) build.name = value; A.Notify("Build renamed.") end, 60, Nonempty)
            end),
            A.Row("Build notes", build.notes, "Add a short note about this build, such as dungeon healing or PvP. Notes are not automatic requirements.", function()
                A.Input("Build notes", build.notes, function(value) build.notes = value end, 500)
            end),
            A.Row("Stop tracking", "Keep the build saved", "Remove the active comparison without deleting targets or snapshots.", function()
                if A.saved.activeBuildId == id then A.saved.activeBuildId = nil end
                A.Back()
            end),
            A.Row("Delete this build", build.name, "Delete this target only. Snapshots remain intact. A confirmation follows.", function()
                A.OpenMenu("Delete " .. build.name .. "?", {
                    A.Row("Cancel", "Keep this build", "Return without deleting.", A.Back),
                    A.Row("Confirm deletion", "Remove " .. build.name, "This removes the target build and its requirements.", function()
                        A.DeleteBuild(id); A.ShowTab(4); A.Notify("Target build deleted.")
                    end),
                })
            end),
        }
    end)
end

local function EnsureGear(build, key)
    local goal = build.gear[key]
    if not goal or goal.status == "empty" then goal = { status = "equipped" }; build.gear[key] = goal end
    return goal
end

function A.Choose(title, choices, commit)
    local rows = {}
    for _, candidate in ipairs(choices) do
        local choice = candidate
        rows[#rows + 1] = A.Row(choice.label, "Select to apply", choice.detail or choice.label, function()
            commit(choice.value); A.Back()
        end)
    end
    A.OpenMenu(title, rows)
end

local function EnumChoices(prefix, constants, includeNone)
    local choices = { { label = "Any / do not check", value = nil } }
    if includeNone then choices[#choices + 1] = { label = "No trait", value = ITEM_TRAIT_TYPE_NONE or 0 } end
    for _, constant in ipairs(constants) do
        local value = _G[constant]
        if value ~= nil then choices[#choices + 1] = { label = A.EnumName(prefix, value), value = value } end
    end
    return choices
end

function A.PickSet(build, key)
    local filter = ""
    local function Apply(id, name)
        local goal = EnsureGear(build, key)
        goal.setId, goal.setName = id, name
        A.Back()
    end
    A.OpenMenu("Target set", function()
        local rows = {
            A.Row("Search sets", filter ~= "" and filter or "Filter by part of a name", "Search the game's set-collection names. For a crafted or missing set, enter its exact name manually.", function()
                A.Input("Search sets", filter, function(value) filter = value end)
            end),
            A.Row("Any set", "Do not check set membership", "Other requirements still apply.", function() Apply(nil, nil) end),
            A.Row("No set", "Require a non-set item", "The item must not belong to a set.", function() Apply(0, nil) end),
            A.Row("Enter exact set name", "For crafted or unlisted sets", "Use the set name as it appears in your game's language. Spelling matters; capitalization does not.", function()
                A.Input("Exact target set name", filter, function(value) Apply(nil, value) end, 120, Nonempty)
            end),
        }
        for _, entry in ipairs(A.SetCatalog()) do
            local set = entry
            if filter == "" or A.Normalize(set.name):find(A.Normalize(filter), 1, true) then
                rows[#rows + 1] = A.Row(set.name, "Set target", "Track this exact set ID, including its perfected or normal variant.", function() Apply(set.id, set.name) end)
            end
        end
        return rows
    end)
end

function A.EditGear(key)
    local build = A.RequireBuild()
    if not build then return end
    A.OpenMenu("Gear target", function()
        local item = A.FindItem(A.GetViewedSnapshot(), key)
        local goal = build.gear[key]
        local function Field(field, value)
            local target = EnsureGear(build, key)
            target[field] = value
            if field == "enchantName" then target.enchantGlyph = nil end
        end
        local rows = {
            A.Row("Use viewed item as target", item and item.slotLabel or key, "Copy the viewed item's set, trait, enchantment type, quality and item type. Later changes to live gear will not change this target.", function()
                if item and item.status == "equipped" then build.gear[key] = A.GearGoal(item); A.Notify("Copied item requirements."); A.RebuildPages()
                else A.Notify("There is no readable item in the viewed slot.") end
            end),
            A.Row("Set", goal and goal.setName or "Select a target set", A.GearGoalText(goal), function() A.PickSet(build, key) end),
            A.Row("Trait", goal and goal.trait ~= nil and A.EnumName("SI_ITEMTRAITTYPE", goal.trait) or "Any", "Select the desired trait. The chosen item type determines armor or weapon traits for offhand slots.", function()
                local category = (key == "neck" or key == "ring1" or key == "ring2") and "JEWELRY" or "ARMOR"
                local weaponType = goal and goal.weaponType or item and item.weaponType
                if (key == "frontMain" or key == "backMain" or key == "frontOff" or key == "backOff") and weaponType ~= WEAPONTYPE_SHIELD then category = "WEAPON" end
                local names = category == "ARMOR" and { "DIVINES", "IMPENETRABLE", "INFUSED", "NIRNHONED", "REINFORCED", "STURDY", "TRAINING", "WELL_FITTED", "PROSPEROUS" }
                    or category == "WEAPON" and { "CHARGED", "DECISIVE", "DEFENDING", "INFUSED", "NIRNHONED", "POWERED", "PRECISE", "SHARPENED", "TRAINING" }
                    or { "ARCANE", "BLOODTHIRSTY", "HARMONY", "HEALTHY", "INFUSED", "PROTECTIVE", "ROBUST", "SWIFT", "TRIUNE" }
                local constants = {}
                for _, name in ipairs(names) do constants[#constants + 1] = "ITEM_TRAIT_TYPE_" .. category .. "_" .. name end
                A.Choose("Target trait", EnumChoices("SI_ITEMTRAITTYPE", constants, true), function(value) Field("trait", value) end)
            end),
            A.Row("Minimum quality", goal and goal.quality ~= nil and A.EnumName("SI_ITEMQUALITY", goal.quality) or "Any", "This quality or better counts as a match.", function()
                A.Choose("Minimum quality", EnumChoices("SI_ITEMQUALITY", { "ITEM_FUNCTIONAL_QUALITY_NORMAL", "ITEM_FUNCTIONAL_QUALITY_MAGIC", "ITEM_FUNCTIONAL_QUALITY_ARCANE", "ITEM_FUNCTIONAL_QUALITY_ARTIFACT", "ITEM_FUNCTIONAL_QUALITY_LEGENDARY" }), function(value) Field("quality", value) end)
            end),
            A.Row("Enchantment type", goal and (goal.enchantGlyph or goal.enchantName) or "Any", "For imported glyphs, verify the desired glyph on an item, then use its heading. Matches the enchantment heading from the item tooltip. Numeric enchantment strength is not checked in this version.", function()
                local options = {
                    A.Row("Any enchantment", "Do not check", "Ignore enchantment type.", function() Field("enchantName", nil); A.Back() end),
                    A.Row("No enchantment", "Require none", "Require an empty enchantment heading.", function() Field("enchantName", ""); A.Back() end),
                    A.Row("Use viewed enchantment", item and item.enchantName or "Unavailable", "Copy its enchantment type, not the numeric strength.", function()
                        if item and item.enchantReadComplete then Field("enchantName", item.enchantName or ""); A.Back()
                        else A.Notify("The viewed enchantment could not be read.") end
                    end),
                    A.Row("Enter enchantment heading", "Exact text from the item tooltip", "Use the enchantment's heading in your game language; capitalization does not matter.", function()
                        A.Input("Target enchantment heading", goal and goal.enchantName or "", function(value) Field("enchantName", value); A.Back() end, 120, Nonempty)
                    end),
                }
                A.OpenMenu("Enchantment type", options)
            end),
        }
        if key == "frontMain" or key == "backMain" or key == "frontOff" or key == "backOff" then
            rows[#rows + 1] = A.Row("Weapon / shield type", "Choose a type", "A two-handed target is tracked in the main-hand slot. You can separately require the offhand slot to be empty.", function()
                A.Choose("Weapon type", EnumChoices("SI_WEAPONTYPE", { "WEAPONTYPE_AXE", "WEAPONTYPE_DAGGER", "WEAPONTYPE_HAMMER", "WEAPONTYPE_SWORD", "WEAPONTYPE_TWO_HANDED_AXE", "WEAPONTYPE_TWO_HANDED_HAMMER", "WEAPONTYPE_TWO_HANDED_SWORD", "WEAPONTYPE_BOW", "WEAPONTYPE_FIRE_STAFF", "WEAPONTYPE_FROST_STAFF", "WEAPONTYPE_LIGHTNING_STAFF", "WEAPONTYPE_HEALING_STAFF", "WEAPONTYPE_SHIELD" }), function(value)
                    local target = EnsureGear(build, key)
                    if target.weaponType ~= value then target.trait = nil end
                    target.weaponType, target.armorType = value, nil
                end)
            end)
        elseif key ~= "neck" and key ~= "ring1" and key ~= "ring2" and key ~= "frontPoison" and key ~= "backPoison" and key ~= "costume" then
            rows[#rows + 1] = A.Row("Armor weight", "Light / Medium / Heavy", "Require an armor weight.", function()
                A.Choose("Armor weight", EnumChoices("SI_ARMORTYPE", { "ARMORTYPE_LIGHT", "ARMORTYPE_MEDIUM", "ARMORTYPE_HEAVY" }), function(value) Field("armorType", value) end)
            end)
        end
        rows[#rows + 1] = A.Row("Minimum item CP", goal and tostring(goal.requiredCP or "Any") or "Any", "Optional item CP requirement. Clearing it also removes the copied level requirement.", function()
            A.Input("Minimum item CP (blank = any)", goal and goal.requiredCP or "", function(value)
                local target = EnsureGear(build, key)
                target.requiredCP, target.requiredLevel = tonumber(value), nil
            end, 5, function(value) local n = tonumber(value); return value == "" or n and n >= 0 and n <= 160 and n % 10 == 0, "Use 0 to 160 in steps of 10, or leave blank." end)
        end)
        rows[#rows + 1] = A.Row("Require empty slot", "For unused offhands or optional slots", "Count this slot as matching only when it is empty.", function() build.gear[key] = { status = "empty" }; A.Back() end)
        rows[#rows + 1] = A.Row("Stop tracking this slot", "Remove this slot's requirements", "The slot no longer contributes to progress.", function() build.gear[key] = nil; A.Back() end)
        return rows
    end)
end

function A.EditSkill(barIndex, skillIndex)
    local build = A.RequireBuild()
    if not build then return end
    local function Set(goal) build.skills[barIndex][skillIndex] = goal; A.Back() end
    A.OpenMenu("Skill target", function()
        local skill = A.GetViewedSnapshot().bars[barIndex].slots[skillIndex]
        return {
            A.Row("Use viewed skill", skill.name or "Empty", "Copy the current assignment and scribed scripts, where applicable.", function()
                if skill.status == "slotted" then Set(A.SkillGoal(skill)) else A.Notify("There is no readable skill in this slot.") end
            end),
            A.Row("Choose skill or morph", "Browse character skill lines", "Includes normal abilities and morphs exposed by your character's skill lines. For a scribed setup, copy a viewed skill with the desired scripts.", function()
                local catalog, filter = A.SkillCatalog(skillIndex == 6), ""
                A.OpenMenu("Choose target skill", function()
                    local rows = { A.Row("Search skills", filter, "Filter the available names.", function()
                        A.Input("Search skills", filter, function(value) filter = value end)
                    end) }
                    for _, candidate in ipairs(catalog) do
                        local target = candidate
                        if filter == "" or A.Normalize(target.name):find(A.Normalize(filter), 1, true) then
                            rows[#rows + 1] = A.Row(target.name, "Select target", "Requires this skill and morph. Skill rank changes do not require a new target.", function()
                                build.skills[barIndex][skillIndex] = A.Copy(target); A.Back(); A.Back()
                            end)
                        end
                    end
                    return rows
                end)
            end),
            A.Row("Enter exact skill name", "Fallback for an unlisted skill", "Name-only matching. Use the precise morph name from the game. This mode does not check scribed scripts.", function()
                A.Input("Target skill or morph name", "", function(value) Set({ status = "slotted", name = value }) end, 120, Nonempty)
            end),
            A.Row("Require empty slot", "No skill assigned", "This slot matches when empty.", function() Set({ status = "empty" }) end),
            A.Row("Stop tracking this slot", "Remove requirement", "This slot no longer contributes to progress.", function() Set(nil) end),
        }
    end)
end

function A.EditStat(constant, label, barKey)
    local build = A.RequireBuild()
    if not build then return end
    if not barKey then A.Notify("Refresh on a normal front or back bar before setting a stat target."); return end
    local targets = build.stats[barKey] or {}
    A.Input(label .. " - " .. barKey .. " bar minimum", targets[constant] or "", function(value)
        build.stats[barKey] = build.stats[barKey] or {}
        build.stats[barKey][constant] = tonumber(value)
        A.Notify(value == "" and "Stat target removed." or "Minimum saved for the " .. barKey .. " bar.")
    end, 16, function(value)
        local n = tonumber(value)
        return value == "" or n and n >= 0 and n <= 10000000 and n == math.floor(n), "Enter a nonnegative whole number, or leave blank to stop tracking."
    end)
end

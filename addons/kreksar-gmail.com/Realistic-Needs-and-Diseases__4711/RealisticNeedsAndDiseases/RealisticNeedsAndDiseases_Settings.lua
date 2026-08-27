-- RealisticNeedsAndDiseases_Settings.lua
-- Builds the LibAddonMenu-2.0 settings panel.

RealisticNeeds = RealisticNeeds or {}
local RN = RealisticNeeds

local Settings = {}
RN.Settings = Settings

Settings.panelId = "RealisticNeedsAndDiseasesPanel"

-- Friendly display order/labels for all 5 diseases — all are auto-wired
-- with a real trigger (frostbite/heatstroke via temperature exposure,
-- mageBane/fightersBane/thiefsBane via typed combat damage taken).
local ROLLABLE_DISEASES = {
    { id = "frostbite",  label = "Frostbite (sustained cold)" },
    { id = "heatstroke", label = "Heatstroke (sustained heat)" },
    { id = "mageBane", label = "Mage's Bane (magic/fire/cold/shock damage taken)" },
    { id = "fightersBane", label = "Fighter's Bane (physical damage taken)" },
    { id = "thiefsBane", label = "Thief's Bane (poison/disease damage taken)" },
}

function Settings.Initialize(sv)
    Settings.sv = sv

    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Realistic Needs and Diseases",
        displayName = "Realistic Needs and Diseases",
        author = "@Kreksar5 and Claude.ai",
        version = RN.VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    Settings.panelData = panelData  -- exposed for /healersguide slash command
    LAM:RegisterAddonPanel(Settings.panelId, panelData)

    local optionsTable = {
        { type = "header", name = "Realistic Needs and Diseases" },
        {
            type = "checkbox",
            name = "Enable the addon",
            tooltip = "True master switch for the entire addon's simulation — takes priority over both toggles below. When OFF: hunger/thirst/fatigue/drunkenness stop decaying, food/drink/water no longer restores them, no new disease can be contracted, no active disease can progress or self-cure, curing a disease with an ingredient stops working too, the status bar hides, and any visible disease overlay tints clear immediately. Nothing is uninstalled or lost — your current needs/disease state is just frozen in place until you turn this back on.",
            getFunc = function() return sv.settings.masterEnabled end,
            setFunc = function(value)
                sv.settings.masterEnabled = value
                if value then
                    -- Re-enabling: restore the status bar (respecting the
                    -- separate showStatusBar preference) and repaint any
                    -- diseases that were already active so their overlay
                    -- tints reappear immediately instead of waiting for the
                    -- next severity change.
                    if RN.StatusBar and RN.StatusBar.SetShown then
                        RN.StatusBar.SetShown(sv.settings.showStatusBar)
                    end
                    if RN.StatusIconsTransparency and RN.StatusIconsTransparency.SetShown then
                        RN.StatusIconsTransparency.SetShown(sv.settings.statusIconsTransparencyEnabled)
                    end
                    if RN.StatusBars and RN.StatusBars.SetShown then
                        RN.StatusBars.SetShown(sv.settings.statusBarsEnabled)
                    end
                    if RN.Overlay and RN.Overlay.RefreshAll then
                        RN.Overlay.RefreshAll(sv)
                    end
                else
                    -- Disabling: hide the status bar and clear every disease
                    -- overlay outright, regardless of showStatusBar, so there's
                    -- no leftover UI implying the system is still running.
                    if RN.StatusBar and RN.StatusBar.SetShown then
                        RN.StatusBar.SetShown(false)
                    end
                    if RN.StatusIconsTransparency and RN.StatusIconsTransparency.SetShown then
                        RN.StatusIconsTransparency.SetShown(false)
                    end
                    if RN.StatusBars and RN.StatusBars.SetShown then
                        RN.StatusBars.SetShown(false)
                    end
                    if RN.Overlay and RN.Overlay.ClearDisease then
                        for diseaseId in pairs(RN.Diseases) do
                            RN.Overlay.ClearDisease(diseaseId)
                        end
                    end
                end
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Enable needs tracking",
            tooltip = "Independent of \"Enable the disease system\" below — turning this off doesn't touch disease contraction, progression, self-cure, or curing in any way. When OFF (and \"Enable the addon\" above stays on): hunger, thirst, fatigue, and drunkenness stop decaying, and food/drink/water consumption no longer restores them — they're frozen at whatever they were, not reset to anything.",
            getFunc = function() return sv.settings.needsSystemEnabled end,
            setFunc = function(value) sv.settings.needsSystemEnabled = value end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Use icon-based status display",
            tooltip = "Shows a second, icon-based status window alongside the text status window above (not instead of it — toggle \"Show needs status window\" separately if you want just one). Fixed icons for all 4 needs and all 5 diseases, always in the same position, where TRANSPARENCY (not color) indicates severity — fully transparent means a need is satisfied or a disease isn't present, fully opaque means a need is completely empty or a disease is Severe. Position is drag-movable in-game, independent of the text window's position.",
            getFunc = function() return sv.settings.statusIconsTransparencyEnabled end,
            setFunc = function(value)
                sv.settings.statusIconsTransparencyEnabled = value
                if RN.StatusIconsTransparency and RN.StatusIconsTransparency.SetShown then
                    RN.StatusIconsTransparency.SetShown(value and sv.settings.masterEnabled ~= false)
                end
            end,
            default = false,
        },
        {
            type = "slider", name = "Icon status display size", min = 0.5, max = 2.0, step = 0.05, decimals = 2,
            tooltip = "Scales the entire icon-based status window (icons and their spacing together) up or down. 1.0 = default size.",
            getFunc = function() return sv.settings.statusIconsTransparencyScale end,
            setFunc = function(value)
                sv.settings.statusIconsTransparencyScale = value
                if RN.StatusIconsTransparency and RN.StatusIconsTransparency.ApplyDisplaySettings then
                    RN.StatusIconsTransparency.ApplyDisplaySettings(sv)
                end
            end,
            default = 1.0,
        },
        {
            type = "slider", name = "Icon status display max opacity", min = 0.2, max = 1.0, step = 0.05, decimals = 2,
            tooltip = "Caps how opaque an icon can get even at its worst (a completely empty need or a Severe disease). This multiplies on top of the normal transparency-by-severity effect rather than replacing it — at 0.5, for example, a Severe disease renders at half the opacity it normally would, and everything below Severe scales down proportionally with it. 1.0 = default (full opacity at worst).",
            getFunc = function() return sv.settings.statusIconsTransparencyMaxOpacity end,
            setFunc = function(value)
                sv.settings.statusIconsTransparencyMaxOpacity = value
                if RN.StatusIconsTransparency and RN.StatusIconsTransparency.ApplyDisplaySettings then
                    RN.StatusIconsTransparency.ApplyDisplaySettings(sv)
                end
            end,
            default = 1.0,
        },
        {
            type = "checkbox",
            name = "Use bar-based status display",
            tooltip = "Shows a mini health-bar-style status window — one bar each for hunger/thirst/fatigue (always shown, full = satisfied, empty = critical), plus a drunkenness bar that only appears once you're actually inebriated and fills up as it increases, and one bar per currently-active disease (fills up as severity worsens). Independent toggle — can run alongside the text window and/or the icon display above. Position is drag-movable in-game.",
            getFunc = function() return sv.settings.statusBarsEnabled end,
            setFunc = function(value)
                sv.settings.statusBarsEnabled = value
                if RN.StatusBars and RN.StatusBars.SetShown then
                    RN.StatusBars.SetShown(value and sv.settings.masterEnabled ~= false)
                end
            end,
            default = false,
        },
        {
            type = "slider", name = "Bar status display size", min = 0.5, max = 2.0, step = 0.05, decimals = 2,
            tooltip = "Scales the entire bar-based status window (bars, labels, and spacing together) up or down. 1.0 = default size.",
            getFunc = function() return sv.settings.statusBarsScale end,
            setFunc = function(value)
                sv.settings.statusBarsScale = value
                if RN.StatusBars and RN.StatusBars.ApplyDisplaySettings then
                    RN.StatusBars.ApplyDisplaySettings(sv)
                end
            end,
            default = 1.0,
        },
        {
            type = "slider", name = "Bar status display opacity", min = 0.2, max = 1.0, step = 0.05, decimals = 2,
            tooltip = "Overall transparency of the whole bar-based status window (background panel, bars, and labels together) — lower values make the whole window more see-through. 1.0 = fully opaque (default).",
            getFunc = function() return sv.settings.statusBarsOpacity end,
            setFunc = function(value)
                sv.settings.statusBarsOpacity = value
                if RN.StatusBars and RN.StatusBars.ApplyDisplaySettings then
                    RN.StatusBars.ApplyDisplaySettings(sv)
                end
            end,
            default = 1.0,
        },
        {
            type = "slider", name = "Disease overlay max opacity", min = 0.1, max = 1.0, step = 0.05, decimals = 2,
            tooltip = "Caps how strong the full-screen disease tint can get, even at Severe. This scales the existing per-severity ceilings (Mild/Moderate/Severe each already fade in to a different strength) proportionally down together, rather than replacing them individually — at 0.5, for example, Severe renders at half its normal strength, and Mild/Moderate scale down right along with it. 1.0 = default (unscaled). Mirrors the same overlay opacity slider added to Frostfall's hot/cold screen effect.",
            getFunc = function() return sv.settings.diseaseOverlayMaxOpacity end,
            setFunc = function(value)
                sv.settings.diseaseOverlayMaxOpacity = value
                if RN.Overlay and RN.Overlay.RefreshAll then
                    RN.Overlay.RefreshAll(sv)
                end
            end,
            default = 1.0,
        },
        { type = "header", name = "Needs — decay & restoration" },
        {
            type = "checkbox",
            name = "Accelerate decay with temperature (Frostfall/LibZoneTemp)",
            tooltip = "Hunger, thirst, and fatigue always decay at their natural baseline rate (set below). When enabled, hot/cold environments accelerate that decay further. Disabling this never speeds decay up — it only removes the temperature-based acceleration.",
            getFunc = function() return sv.settings.coupleToFrostfall end,
            setFunc = function(value) sv.settings.coupleToFrostfall = value end,
            default = true,
        },
        {
            type = "slider", name = "Minutes for hunger to empty (natural rate)", min = 5, max = 120, step = 5,
            tooltip = "How many real minutes it takes hunger to drain from 100 to 0 at the natural baseline rate (before any temperature acceleration). Lower = hungrier faster. 5 = fastest possible (5 min full-to-empty); 120 = slowest (2 hours).",
            getFunc = function() return sv.settings.decayMinutes.hunger end,
            setFunc = function(value) sv.settings.decayMinutes.hunger = value end,
            default = 60,
        },
        {
            type = "slider", name = "Minutes for thirst to empty (natural rate)", min = 5, max = 120, step = 5,
            tooltip = "How many real minutes it takes thirst to drain from 100 to 0 at the natural baseline rate (before any temperature acceleration). Lower = thirstier faster. 5 = fastest possible (5 min full-to-empty); 120 = slowest (2 hours).",
            getFunc = function() return sv.settings.decayMinutes.thirst end,
            setFunc = function(value) sv.settings.decayMinutes.thirst = value end,
            default = 45,
        },
        {
            type = "slider", name = "Minutes for fatigue to empty (natural rate)", min = 5, max = 120, step = 5,
            tooltip = "How many real minutes it takes fatigue to drain from 100 to 0 at the natural baseline rate (before temperature or stamina-exertion acceleration). Lower = more tired faster. 5 = fastest possible (5 min full-to-empty); 120 = slowest (2 hours).",
            getFunc = function() return sv.settings.decayMinutes.fatigue end,
            setFunc = function(value) sv.settings.decayMinutes.fatigue = value end,
            default = 90,
        },
        {
            type = "slider", name = "Hunger restored per food eaten", min = 5, max = 100, step = 5,
            getFunc = function() return sv.settings.restoreAmounts.food end,
            setFunc = function(value) sv.settings.restoreAmounts.food = value end,
            default = 30,
        },
        {
            type = "slider", name = "Thirst restored per drink consumed", min = 5, max = 100, step = 5,
            getFunc = function() return sv.settings.restoreAmounts.drink end,
            setFunc = function(value) sv.settings.restoreAmounts.drink = value end,
            default = 30,
        },
        {
            type = "slider", name = "Thirst restored per wild water node harvested", min = 0, max = 100, step = 5,
            tooltip = "Set to 0 to disable this entirely — no thirst restore and no chat message when harvesting a water node.",
            getFunc = function() return sv.settings.restoreAmounts.harvest end,
            setFunc = function(value) sv.settings.restoreAmounts.harvest = value end,
            default = 15,
        },
        {
            type = "description",
            text = "Hunger/thirst/fatigue/drunkenness status messages and notifications are now driven by 4 fixed bands dividing the 0-100 range equally (no longer adjustable thresholds) — see the README for the exact band breakpoints and messages.",
        },
        {
            type = "checkbox",
            name = "Show needs status window",
            getFunc = function() return sv.settings.showStatusBar end,
            setFunc = function(value)
                sv.settings.showStatusBar = value
                if RN.StatusBar and RN.StatusBar.SetShown then
                    RN.StatusBar.SetShown(value)
                end
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Show native top-screen notifications",
            tooltip = "The top-right toast (the same system used for screenshot/achievement/loot notifications) for important events like disease contraction/cure and low-need warnings. The exact native call used here is best-effort and unverified against a live client. This is independent of the chat-message toggle below.",
            getFunc = function() return sv.settings.showNativeNotifications end,
            setFunc = function(value) sv.settings.showNativeNotifications = value end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Also log notifications to chat",
            tooltip = "Off by default. When enabled, every notification (disease contraction/cure, band-transition warnings, etc.) is also printed to chat in addition to the top-screen popup above, giving you a scrollback log of everything that happened. Doesn't affect /rnd debug output, which always prints to chat regardless of this setting.",
            getFunc = function() return sv.settings.showChatMessages end,
            setFunc = function(value) sv.settings.showChatMessages = value end,
            default = false,
        },
        {
            type = "button",
            name = "Reset status window position",
            tooltip = "The status window is drag-movable in-game. If it gets lost off-screen, use this to bring it back to the default top-left position.",
            func = function()
                sv.settings.statusBarPosition = { x = 16, y = 100 }
                CHAT_SYSTEM:AddMessage("|c88CCFF[Realistic Needs and Diseases]|r Status window position reset. Reload UI to see the change take effect.")
            end,
        },
        {
            type = "button",
            name = "Reset icon status window position",
            tooltip = "The icon-based status window is drag-movable in-game separately from the text window. If it gets lost off-screen, use this to bring it back to its default position.",
            func = function()
                sv.settings.statusIconsTransparencyPosition = { x = 16, y = 340 }
                CHAT_SYSTEM:AddMessage("|c88CCFF[Realistic Needs and Diseases]|r Icon status window position reset. Reload UI to see the change take effect.")
            end,
        },
        {
            type = "button",
            name = "Reset bar status window position",
            tooltip = "The bar-based status window is drag-movable in-game separately from the other status windows. If it gets lost off-screen, use this to bring it back to its default position.",
            func = function()
                sv.settings.statusBarsPosition = { x = 16, y = 220 }
                CHAT_SYSTEM:AddMessage("|c88CCFF[Realistic Needs and Diseases]|r Bar status window position reset. Reload UI to see the change take effect.")
            end,
        },

        { type = "header", name = "Disease contraction chances" },
        {
            type = "checkbox",
            name = "Enable the disease system",
            tooltip = "Independent of \"Enable needs tracking\" above and the master switch further up — turning this off doesn't touch hunger/thirst/fatigue/drunkenness in any way. When OFF (and \"Enable the addon\" stays on): no new disease can be contracted (neither from sustained cold/heat exposure nor from combat damage), and no disease already active can worsen in severity or self-cure on its own — it just sits frozen at its current severity. Curing a disease you already have with an ingredient still works exactly the same either way — this only stops new contraction and progression, not treatment. Any disease overlay tints on screen clear immediately while this is off, and reappear at their correct severity the moment you turn it back on.",
            getFunc = function() return sv.settings.diseaseSystemEnabled end,
            setFunc = function(value)
                sv.settings.diseaseSystemEnabled = value
                if value then
                    if RN.Overlay and RN.Overlay.RefreshAll then
                        RN.Overlay.RefreshAll(sv)
                    end
                else
                    if RN.Overlay and RN.Overlay.ClearDisease then
                        for diseaseId in pairs(RN.Diseases) do
                            RN.Overlay.ClearDisease(diseaseId)
                        end
                    end
                end
            end,
            default = true,
        },
        {
            type = "description",
            text = "Frostbite and Heatstroke first become possible once their temperature trigger has held continuously for 5 minutes — after that, they keep re-rolling every 60 seconds for as long as the exposure continues, until contracted or until you leave the trigger range. Mage's Bane, Fighter's Bane, and Thief's Bane are each rolled per qualifying hit of real typed damage taken (magic/fire/cold/shock; physical; and poison/disease respectively) — keep these very low, since combat damage can land far more often than the 60-second re-roll interval.",
        },
    }

    -- Combat-damage diseases keep a much tighter chance/step range than
    -- the exposure-based ones (frostbite/heatstroke), since a hit can land
    -- far more often than the 60-second re-roll interval fires.
    local LOW_CHANCE_DISEASES = { mageBane = true, fightersBane = true, thiefsBane = true }

    for _, entry in ipairs(ROLLABLE_DISEASES) do
        local isLowChance = LOW_CHANCE_DISEASES[entry.id]
        table.insert(optionsTable, {
            type = "slider",
            name = entry.label .. " chance (%)",
            min = 0,
            max = isLowChance and 10 or 50,
            step = isLowChance and 0.5 or 1,
            getFunc = function() return (sv.settings.diseaseChances[entry.id] or 0) * 100 end,
            setFunc = function(value) sv.settings.diseaseChances[entry.id] = value / 100 end,
            default = isLowChance and 1 or 10,
        })
    end

    -- ─────────────────────────────────────────────────────────────────────────
    -- Healer's Guide — a lore-friendly, read-only reference panel. Built
    -- dynamically from RN.Diseases/RN.DISEASE_ORDER rather than hardcoded
    -- text, so it can never drift out of sync with the actual cure data —
    -- if an ingredient or trait changes in Data.lua, this updates itself
    -- automatically next time the panel opens.
    --
    -- UNVERIFIED AGAINST LAM SOURCE: type = "submenu" with a nested
    -- `controls` array is the commonly-documented way to group a block of
    -- LAM controls behind a single collapsible/expandable entry, but this
    -- project doesn't have LibAddonMenu-2.0's own source to confirm the
    -- exact field name against this specific LAM version. If it doesn't
    -- render as expected, the likely fix is unwrapping `healersGuideControls`
    -- and inserting each entry directly into optionsTable instead (flat,
    -- always-visible, no collapsible submenu) — worth a quick visual check.
    -- ─────────────────────────────────────────────────────────────────────────
    local healersGuideControls = {
        {
            type = "description",
            text = "Every affliction that takes root in the body answers to the right alchemy — not the brewed potions sold in town, but the raw herb, egg, or growth itself, eaten plain. A trained healer learns which reagent calms which sickness, and how severe a case it can still turn back.",
        },
        {
            type = "description",
            text = "A case caught early (Mild) yields to almost any suitable reagent. Left to fester (Moderate, then Severe), only a stronger — and rarer — preparation of the same cure will still work; the common herb alone is no longer enough on its own. Eating the matching tier (or anything rarer than it) cures the affliction outright, the moment it's eaten.",
        },
        {
            type = "description",
            text = "There is a gentler way for those without access to rare ingredients: a patient kept well-fed, well-watered, and well-rested, who eats the common (tier 1) remedy again and again, will find even a Severe case loosening its grip one stage at a time — slower than the rare cure, but it asks nothing more of the purse than patience and a full larder. Note that the body needs a short rest between doses of the common remedy before it will answer to it again — overfeeding it the same herb in a hurry does nothing extra.",
        },
    }

    for _, diseaseId in ipairs(RN.DISEASE_ORDER) do
        local def = RN.Diseases[diseaseId]
        if def then
            table.insert(healersGuideControls, { type = "header", name = def.name })

            local introText = def.flavorNote or ""
            if def.curativeTraitName then
                introText = introText .. string.format(" Answers to remedies of the %s tradition.", def.curativeTraitName)
            end
            table.insert(healersGuideControls, { type = "description", text = introText })

            local tierLabels = { "Mild", "Moderate", "Severe" }
            for tier = 1, 3 do
                local entries = def.remedyIngredients[tier]
                if entries and #entries > 0 then
                    local names = {}
                    for _, entry in ipairs(entries) do
                        table.insert(names, entry.name)
                    end
                    table.insert(healersGuideControls, {
                        type = "description",
                        text = string.format("  %s cure: %s", tierLabels[tier], table.concat(names, " or ")),
                    })
                end
            end
        end
    end

    table.insert(optionsTable, { type = "header", name = "Healer's Guide" })
    table.insert(optionsTable, {
        type = "submenu",
        name = "Open the Healer's Guide",
        controls = healersGuideControls,
    })

    table.insert(optionsTable, { type = "header", name = "Feedback emotes" })
    table.insert(optionsTable, {
        type = "checkbox",
        name = "Enable feedback emotes",
        tooltip = "Plays a thematic emote periodically while a need is critically low, a disease is active, or drunkenness is high. Independent of chat/toast notifications, which always happen regardless of this setting.",
        getFunc = function() return sv.settings.enableEmotes end,
        setFunc = function(value) sv.settings.enableEmotes = value end,
        default = true,
    })
    table.insert(optionsTable, {
        type = "description",
        text = "Choose which emote plays for each category. The dropdown lists every emote you currently own (including personality-overridden variants), via the same live enumeration Frostfall uses for its own hot/cold emote settings — not a fixed list, so it reflects your actual account.",
    })

    -- Built fresh each time the panel opens (cheap enumeration call), so a
    -- newly-unlocked emote/personality shows up without needing a reload.
    local emoteLabels, emoteValues = RN.Feedback.BuildEmoteChoices()
    local CATEGORY_LABELS = { hunger = "Hunger", thirst = "Thirst", fatigue = "Fatigue", disease = "Disease", drunkenness = "Drunkenness" }
    for _, category in ipairs({ "hunger", "thirst", "fatigue", "disease", "drunkenness" }) do
        table.insert(optionsTable, {
            type = "dropdown",
            name = CATEGORY_LABELS[category] .. " emote",
            choices = emoteLabels,
            getFunc = function()
                local currentId = sv.settings.emoteChoiceId[category]
                for i, value in ipairs(emoteValues) do
                    if value == currentId then return emoteLabels[i] end
                end
                return emoteLabels[#emoteLabels]  -- "None (disabled)"
            end,
            setFunc = function(chosenLabel)
                for i, label in ipairs(emoteLabels) do
                    if label == chosenLabel then
                        sv.settings.emoteChoiceId[category] = emoteValues[i]
                        return
                    end
                end
            end,
        })
    end

    table.insert(optionsTable, { type = "header", name = "Drunkenness" })
    table.insert(optionsTable, {
        type = "description",
        text = "Drinking alcoholic beverages (detected by name keyword — mead, ale, wine, etc.) builds up drunkenness. It wears off slowly on its own over time, and much faster while resting (standing still, sitting, or sleeping).",
    })
    table.insert(optionsTable, {
        type = "slider", name = "Drunkenness gained per alcoholic drink", min = 5, max = 50, step = 5,
        getFunc = function() return sv.settings.drunkennessPerDrink end,
        setFunc = function(value) sv.settings.drunkennessPerDrink = value end,
        default = 15,
    })
    table.insert(optionsTable, {
        type = "slider", name = "Hours to sober up unaided (no resting)", min = 1, max = 3, step = 1,
        getFunc = function() return 100 / (sv.settings.drunkennessBaselineDecayPerSecond * 3600) end,
        setFunc = function(value) sv.settings.drunkennessBaselineDecayPerSecond = 100 / (value * 3600) end,
        default = 2,
    })
    table.insert(optionsTable, {
        type = "slider", name = "Resting sobers you up this many times faster", min = 2, max = 10, step = 1,
        getFunc = function() return sv.settings.drunkennessRestMultiplier end,
        setFunc = function(value) sv.settings.drunkennessRestMultiplier = value end,
        default = 4,
    })

    table.insert(optionsTable, { type = "header", name = "Coffee" })
    table.insert(optionsTable, {
        type = "description",
        text = "Drinking coffee (detected by name keyword) restores fatigue in addition to the normal thirst restore every drink gives.",
    })
    table.insert(optionsTable, {
        type = "slider", name = "Fatigue restored per coffee", min = 5, max = 100, step = 5,
        getFunc = function() return sv.settings.restoreAmounts.coffeeFatigue end,
        setFunc = function(value) sv.settings.restoreAmounts.coffeeFatigue = value end,
        default = 25,
    })

    table.insert(optionsTable, { type = "header", name = "Fatigue recovery" })
    table.insert(optionsTable, {
        type = "description",
        text = "Three ways to recover fatigue: standing still out of combat for a while, sitting for a shorter while, or sleeping/meditating (a /sleep, /sleep2, /faint, /pray, or /kneelpray pose) for a full restore. All three require not moving and being out of combat.",
    })
    table.insert(optionsTable, {
        type = "slider", name = "Minutes standing still before passive regen begins", min = 1, max = 10, step = 1,
        getFunc = function() return sv.settings.restStationaryThresholdSeconds / 60 end,
        setFunc = function(value) sv.settings.restStationaryThresholdSeconds = value * 60 end,
        default = 3,
    })
    table.insert(optionsTable, {
        type = "slider", name = "Seconds seated before regen begins", min = 10, max = 180, step = 10,
        getFunc = function() return sv.settings.restSeatedThresholdSeconds end,
        setFunc = function(value) sv.settings.restSeatedThresholdSeconds = value end,
        default = 60,
    })
    table.insert(optionsTable, {
        type = "slider", name = "Seconds sleeping/meditating before full restore", min = 10, max = 180, step = 10,
        getFunc = function() return sv.settings.restSleepThresholdSeconds end,
        setFunc = function(value) sv.settings.restSleepThresholdSeconds = value end,
        default = 60,
    })

    table.insert(optionsTable, { type = "header", name = "Debugging" })
    table.insert(optionsTable, {
        type = "description",
        text = "Debug and testing tools are available via the /rnd debug command. Type /rnd debug in chat for usage.",
    })

    LAM:RegisterOptionControls(Settings.panelId, optionsTable)
end

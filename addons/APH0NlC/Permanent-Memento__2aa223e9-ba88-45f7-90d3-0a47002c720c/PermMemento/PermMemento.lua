-- Permanent Memento
-- LICENSE
-- Copyright 2025-2026 @APHONlC
-- Licensed under the Apache License, Version 2.0.

-- TESTED: 2026-03-26 | Release v0.8.7 | APIVersion: 101049 | LAM2 v41
local is_release_build = false
local REQUIRED_LAM_VERSION = 41
local REQUIRED_LCA_VERSION = 7060

local PM = {
    name = "PermMemento",
    version = "0.8.7",
    defaults = {
        active_id = nil,
        is_paused = false,
        is_log_enabled = false,
        is_csa_enabled = true,
        is_csa_cleanup_enabled = true,
        is_random_on_login = false,
        is_random_on_zone = false,
        is_loop_in_combat = false,
        is_performance_mode = true,
        use_account_settings = false,
        show_in_hud = false,
        is_unrestricted = false,
        is_auto_cleanup = true,
        enable_stats_ui = false,
        enable_random_fav = false,
        enable_learning = false,
        is_stop_spinning = false, 
        is_migrated_087 = false,
        has_shown_lib_warning_087 = false,
        alc_disabled_pm = false, 
        last_version = "0.8.6",
        version_history = {},
        learned_data = {},
        favorites = {},
        total_loops = 0,
        memento_usage = {},
        install_date = nil,
        delay_idle = 3,
        delay_in_menu = 5,
        delay_combat_end = 5,
        delay_resurrect = 5,
        delay_teleport = 5,
        delay_move = 3,
        delay_sprint = 3,
        delay_block = 3,
        delay_swim = 5,
        delay_sneak = 3,
        delay_mount = 5,
        delay_cast = 3,
        csa_durations = {
            activation = 3, stop = 3, sync = 3, ui = 3,
            random = 3, error = 3, settings = 3, cleanup = 3
        },
        ui = {
            left = 1627, top = 32, is_locked = false, is_hidden = true,
            scale = (IsConsoleUI() and 1.0 or 1.0)
        },
        ui_menu = {
            left = -1, top = -1, scale = (IsConsoleUI() and 1.2 or 1.0)
        },
        sync_module = {
            delay = 0, is_random = false, ignore_in_combat = true, is_enabled = false
        }
    },
    is_looping = false,
    is_scanning = false,
    is_mem_check_queued = false,
    loop_token = 0,
    last_pos = { x = 0, y = 0, z = 0, t = 0 },
    is_moving = false,
    is_sync_firing = false,
    pending_sync_id = nil,
    next_fire_time = 0,
    learned_count = 0,
    session_loops = 0,
    current_fav_count = 0,
    current_sv_size_kb = 0,
    next_random_precalc = nil,
    last_priority_save_time = 0,
    mem_state = 0,
    mem_freed = 0,
    mem_next_sweep = 0,
    sync_engine = {},
    is_menu_built = false,
    active_names = {},
    active_ids = {},
    sync_names = {},
    sync_ids = {},
    learned_list_names = {},
    learned_list_values = {},
    fav_all_names = {},
    fav_all_ids = {},
    fav_current_names = {},
    fav_current_ids = {},
    char_list_values = {},
    char_list_names = {},
    selected_sync_id = nil,
    pending_id = nil,
    selected_char_copy = nil,
    selected_char_delete = nil,
    selected_learned_id = nil,
    selected_fav_candidate = nil,
    selected_fav_removal = nil,
    ctrl_active_dropdown = nil,
    ctrl_sync_dropdown = nil,
    ctrl_learned_dropdown = nil,
    ctrl_fav_candidate_dropdown = nil,
    ctrl_fav_remove_dropdown = nil,
    is_scene_callback_registered = false,
    scene_callback_fn = nil,
    ui_update_fn = nil
}

PM.memento_data = {
    [336]   = { id = 336,   ref_id = 21226,  dur = 13000,   name = "Finvir's Trinket" },
    [341]   = { id = 341,   ref_id = 26829,  dur = 27000,   name = "Almalexia's Enchanted Lantern" },
    [349]   = { id = 349,   ref_id = 42008,  dur = 16000,   name = "Token of Root Sunder" },
    [594]   = { id = 594,   ref_id = 85344,  dur = 180000,  name = "Storm Atronach Aura" },
    [758]   = { id = 758,   ref_id = 86978,  dur = 180000,  name = "Floral Swirl Aura" },
    [759]   = { id = 759,   ref_id = 86977,  dur = 180000,  name = "Wild Hunt Transform" },
    [760]   = { id = 760,   ref_id = 86976,  dur = 180000,  name = "Wild Hunt Leaf-Dance Aura" },
    [1183]  = { id = 1183,  ref_id = 92868,  dur = 180000,  name = "Dwemervamidium Mirage" },
    [9361]  = { id = 9361,  ref_id = 153672, dur = 18000,   name = "Inferno Cleats" },
    [9862]  = { id = 9862,  ref_id = 162813, dur = 180000,  name = "Astral Aurora Projector" },
    [10652] = { id = 10652, ref_id = 175730, dur = 180000,  name = "Soul Crystals of the Returned" },
    [10706] = { id = 10706, ref_id = 176334, dur = 180000,  name = "Blossom Bloom" },
    [13092] = { id = 13092, ref_id = 229843, dur = 70500,   name = "Remnant of Meridia's Light" },
    [347]   = { id = 347,   ref_id = 41950,  dur = 33000,   name = "Fetish of Anger" },
    [596]   = { id = 596,   ref_id = 85349,  dur = 18000,   name = "Storm Atronach Transform" },
    [1167]  = { id = 1167,  ref_id = 91365,  dur = 6000,    name = "The Pie of Misrule" },
    [1182]  = { id = 1182,  ref_id = 92867,  dur = 10000,   name = "Dwarven Tonal Forks" },
    [1384]  = { id = 1384,  ref_id = 97274,  dur = 18000,   name = "Swarm of Crows" },
    [10236] = { id = 10236, ref_id = 166513, dur = 30000,   name = "Mariner's Nimbus Stone" },
    [10371] = { id = 10371, ref_id = 170722, dur = 60000,   name = "Fargrave Occult Curio" },
    [11480] = { id = 11480, ref_id = 195745, dur = 180000,  name = "Summoned Booknado" },
    [13105] = { id = 13105, ref_id = 229989, dur = 60000,   name = "Surprising Snowglobe" },
    [13736] = { id = 13736, ref_id = 242404, dur = 195000,  name = "Shimmering Gala Gown Veil" }
}

function PM.get_settings_library()
    local am = GetAddOnManager()
    local lam_v, lam_e = 0, false
    local lca_v, lca_e = 0, false
    for i = 1, am:GetNumAddOns() do
        local name, _, _, _, _, state = am:GetAddOnInfo(i)
        local is_en = (state == ADDON_STATE_ENABLED)
        if name == "LibAddonMenu-2.0" then
            local v = am:GetAddOnVersion(i)
            if is_en then
                lam_v = math.max(lam_v, v); lam_e = true
            elseif not lam_e then
                lam_v = math.max(lam_v, v)
            end
        end
        if name == "LibCombatAlerts" then
            local v = am:GetAddOnVersion(i)
            if is_en then
                lca_v = math.max(lca_v, v); lca_e = true
            elseif not lca_e then
                lca_v = math.max(lca_v, v)
            end
        end
    end
    return lam_v, lam_e, lca_v, lca_e
end

function PM.show_missing_library_warning()
    local lam_ver, lam_en, lca_ver, lca_en = PM.get_settings_library()
    local lam_req, lca_req = REQUIRED_LAM_VERSION, REQUIRED_LCA_VERSION
    
    local lam_state = (lam_ver == 0) and "Missing" or (not lam_en and "Not Enabled" or (lam_ver < lam_req and "Outdated" or "OK"))
    local lca_state = (lca_ver == 0) and "Missing" or (not lca_en and "Not Enabled" or (lca_ver < lca_req and "Outdated" or "OK"))
    
    if lam_state == "OK" and lca_state == "OK" then return end
    
    local alerts = {}
    if lam_state == "Missing" then table.insert(alerts, "|c00FFFFLibAddonMenu-2.0|r (Missing)")
    elseif lam_state == "Not Enabled" then table.insert(alerts, string.format("|c00FFFFLibAddonMenu-2.0|r (Disabled) [%sv%d|r]", lam_ver >= lam_req and "|c00FF00" or "|cFF0000", lam_ver))
    elseif lam_state == "Outdated" then table.insert(alerts, string.format("|c00FFFFLibAddonMenu-2.0|r (Outdated) [|cFF0000v%d|r]", lam_ver)) end

    if lca_state == "Missing" then table.insert(alerts, "|c00FFFFLibCombatAlerts|r (Missing)")
    elseif lca_state == "Not Enabled" then table.insert(alerts, string.format("|c00FFFFLibCombatAlerts|r (Disabled) [%sv%d|r]", lca_ver >= lca_req and "|c00FF00" or "|cFF0000", lca_ver))
    elseif lca_state == "Outdated" then table.insert(alerts, string.format("|c00FFFFLibCombatAlerts|r (Outdated) [|cFF0000v%d|r]", lca_ver)) end
    
    if not PM.settings.has_shown_lib_warning_087 then
        local dialog_id = "PM_MISSING_LIBRARY_WARN"
        local popup_title = "|cFF0000PM - Optional Dependency Alert|r"
        local popup_body = "For full functionality, please update or install and enable:\n\n" .. table.concat(alerts, "\n")
                           
        local function on_ack()
            PM.settings.has_shown_lib_warning_087 = true
            local tick_ms = GetGameTimeMilliseconds()
            if (tick_ms - PM.last_priority_save_time) >= 900000 then
                GetAddOnManager():RequestAddOnSavedVariablesPrioritySave(PM.name)
                PM.last_priority_save_time = tick_ms
            end
        end

        if not ESO_Dialogs[dialog_id] then
            ESO_Dialogs[dialog_id] = {
                canQueue = true, 
                gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC }, 
                title = { text = popup_title }, 
                mainText = { text = popup_body },
                buttons = { { text = "Acknowledge / Close", keybind = "DIALOG_PRIMARY", callback = on_ack } }
            }
        end

        zo_callLater(function()
            if IsInGamepadPreferredMode() then ZO_Dialogs_ShowGamepadDialog(dialog_id) 
            else ZO_Dialogs_ShowDialog(dialog_id) end
        end, 2000)
    end

    local csa_msg = ""
    if lam_state == lca_state and lam_state ~= "OK" then
        csa_msg = string.format("%s Optional Libraries!", lam_state)
    elseif lam_state ~= "OK" and lca_state == "OK" then
        if lam_state == "Outdated" then csa_msg = string.format("Optional Dependency Enabled LibAddonMenu-2.0 Incorrect Version \"v%d\"", lam_ver)
        else csa_msg = string.format("%s Optional Library LibAddonMenu-2.0!", lam_state) end
    elseif lca_state ~= "OK" and lam_state == "OK" then
        if lca_state == "Outdated" then csa_msg = string.format("Optional Dependency Enabled LibCombatAlerts Incorrect Version \"v%d\"", lca_ver)
        else csa_msg = string.format("%s Optional Library LibCombatAlerts!", lca_state) end
    else
        csa_msg = "Missing/Outdated Optional Libraries!"
    end
    
    local show_csa = true
    local show_chat = true
    
    local bad_lam = (lam_state ~= "OK")
    local bad_lca = (lca_state ~= "OK")
    local correct_lam = (lam_state == "Not Enabled" and lam_ver >= lam_req)
    local correct_lca = (lca_state == "Not Enabled" and lca_ver >= lca_req)
    
    local only_disabled_correct = false
    if bad_lam and bad_lca then only_disabled_correct = (correct_lam and correct_lca)
    elseif bad_lam then only_disabled_correct = correct_lam
    elseif bad_lca then only_disabled_correct = correct_lca end

    if only_disabled_correct then
        if IsConsoleUI() then
            show_chat = false
            show_csa = true
        else
            show_csa = false
            show_chat = true
        end
    end

    local chat_msg = "|cFF0000[PM Error]|r " .. csa_msg
    
    zo_callLater(function()
        if show_chat and CHAT_SYSTEM then CHAT_SYSTEM:AddMessage(chat_msg) end
        
        if show_csa and CENTER_SCREEN_ANNOUNCE then
            local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
            params:SetText("|cFF0000[PM Error]|r " .. csa_msg)
            params:SetLifespanMS(10000)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
        end
    end, 4000)
end

local function is_alc_enabled()
    local am = GetAddOnManager()
    for i = 1, am:GetNumAddOns() do
        local addon_name, _, _, _, is_running = am:GetAddOnInfo(i)
        if addon_name == "AutoLuaMemoryCleaner" and is_running then return true end
    end
    return false
end

function PM.format_memory(value_mb)
    if value_mb >= 1048576 then return string.format("%.2f TB", value_mb / 1048576)
    elseif value_mb >= 1024 then return string.format("%.2f GB", value_mb / 1024)
    elseif value_mb >= 1 then return string.format("%.2f MB", value_mb)
    else return string.format("%d KB", math.floor(value_mb * 1024)) end
end

function PM.toggle_core_events()
end

function PM.toggle_cleanup_events()
    local should_be_active = PM.settings.is_auto_cleanup and not is_alc_enabled()
    
    if should_be_active then
        EVENT_MANAGER:RegisterForEvent(PM.name .. "_CombatState", EVENT_PLAYER_COMBAT_STATE,
            function(event_code, in_combat)
                if not in_combat then PM.trigger_memory_check("CombatEnd", 3000) end
            end)

        if SCENE_MANAGER and not PM.is_scene_callback_registered then
            PM.scene_callback_fn = function(scene, old_state, new_state)
                if new_state == SCENE_SHOWN and scene.name ~= "hud" and scene.name ~= "hudui" then
                    PM.trigger_memory_check("Menu", 6000)
                end
            end
            SCENE_MANAGER:RegisterCallback("SceneStateChanged", PM.scene_callback_fn)
            PM.is_scene_callback_registered = true
        end

        if PM.settings.enable_stats_ui then
            EVENT_MANAGER:RegisterForEvent(PM.name .. "_LowMem", EVENT_LUA_LOW_MEMORY,
                function() PM.run_manual_cleanup(true, true) end)
        else
            EVENT_MANAGER:UnregisterForEvent(PM.name .. "_LowMem", EVENT_LUA_LOW_MEMORY)
        end
    else
        EVENT_MANAGER:UnregisterForEvent(PM.name .. "_CombatState", EVENT_PLAYER_COMBAT_STATE)
        EVENT_MANAGER:UnregisterForEvent(PM.name .. "_LowMem", EVENT_LUA_LOW_MEMORY)
        if SCENE_MANAGER and PM.is_scene_callback_registered then
            SCENE_MANAGER:UnregisterCallback("SceneStateChanged", PM.scene_callback_fn)
            PM.is_scene_callback_registered = false
        end
        EVENT_MANAGER:UnregisterForUpdate(PM.name .. "_MemFallback")
        PM.mem_state = 0; PM.is_mem_check_queued = false
    end
end

function PM.toggle_stats_ui_tracker()
    if not PM.settings then return end
    if PM.settings.enable_stats_ui then
        EVENT_MANAGER:RegisterForUpdate(PM.name .. "_StatsUpdate", 1000, function()
            local s_ctrl = _G["PM_StatsText"]
            if s_ctrl and s_ctrl.desc and not s_ctrl:IsHidden() then
                s_ctrl.desc:SetText(PM.get_stats_text())
            end
        end)
    else
        EVENT_MANAGER:UnregisterForUpdate(PM.name .. "_StatsUpdate")
    end
end

function PM.toggle_sync_listener()
    if not PM.settings then return end
    if PM.settings.sync_module.is_enabled then
        EVENT_MANAGER:RegisterForEvent(PM.name .. "_Sync", EVENT_CHAT_MESSAGE_CHANNEL,
            PM.on_sync_chat_message)
    else
        EVENT_MANAGER:UnregisterForEvent(PM.name .. "_Sync", EVENT_CHAT_MESSAGE_CHANNEL)
    end
end

function PM.trigger_priority_save()
    if not PM.settings.enable_stats_ui then return end
    local tick_ms = GetGameTimeMilliseconds()
    if (tick_ms - PM.last_priority_save_time) >= 900000 then
        GetAddOnManager():RequestAddOnSavedVariablesPrioritySave(PM.name)
        PM.last_priority_save_time = tick_ms
    end
end

function PM.get_data(target_id)
    if PM.memento_data[target_id] then return PM.memento_data[target_id] end
    if PM.acct_saved and PM.acct_saved.learned_data then
        if PM.acct_saved.learned_data[target_id] then
            return PM.acct_saved.learned_data[target_id]
        end
    end
    if PM.settings.is_unrestricted then
        return {
            id = target_id, ref_id = 0, dur = 10000,
            name = (GetCollectibleName(target_id) or "Unknown")
        }
    end
    return nil
end

function PM.calculate_ram_overhead_recursive(t, seen_map)
    seen_map = seen_map or {}
    if seen_map[t] then return 0, 0, 0, 0 end
    seen_map[t] = true
    
    local keys, raw_bytes, total_refs = 0, 0, 0
    local array_slots, hash_slots, nested_ib = 0, 0, 0

    for k, v in pairs(t) do
        keys = keys + 1
        total_refs = total_refs + 1
        
        -- GC Header overhead for string keys
        if type(k) == "string" then raw_bytes = raw_bytes + #k + 16 end
        
        local v_type = type(v)
        if v_type == "string" then raw_bytes = raw_bytes + #v + 16
        elseif v_type == "number" then raw_bytes = raw_bytes + 8
        elseif v_type == "boolean" then raw_bytes = raw_bytes + 8
        elseif v_type == "table" then
            local rb, tr, k2, ib2 = PM.calculate_ram_overhead_recursive(v, seen_map)
            raw_bytes = raw_bytes + rb
            total_refs = total_refs + tr
            keys = keys + k2
            nested_ib = nested_ib + ib2
        end
        
        if type(k) == "number" and k > 0 and k % 1 == 0 then array_slots = array_slots + 1
        else hash_slots = hash_slots + 1 end
    end
    
    total_refs = total_refs + 1
    local function next_power_2(n)
        local p = 1
        while p < n do p = p * 2 end
        return p
    end
    
    local allocated_array_slots = next_power_2(array_slots)
    local allocated_hash_slots = next_power_2(hash_slots)
    
    -- Using 8-byte array slots and 24-byte hash slots to reflect ESO's 32-bit constrained LuaJIT pointers
    local invisible_structure_bytes = (allocated_array_slots * 8) + (allocated_hash_slots * 24) + 16 + nested_ib
    return raw_bytes, total_refs, keys, invisible_structure_bytes
end

function PM.get_true_ram_footprint(t)
    local rb, tr, k, ib = PM.calculate_ram_overhead_recursive(t)
    -- TValue is 8-bytes under the 32-bit pointer limits
    return (rb + (k * 8) + ib)
end

function PM.get_high_precision_sv_disk_size(t)
    local function count_sv_chars_recursive(t, depth, seen)
        if type(t) ~= "table" or seen[t] then return 0 end
        seen[t] = true
        
        local chars = 0
        for k, v in pairs(t) do
            -- ESO native formatting uses 4 spaces per depth
            chars = chars + (depth * 4)
            
            local k_type = type(k)
            if k_type == "string" then chars = chars + #k + 7
            elseif k_type == "number" then chars = chars + 10 end
            
            local v_type = type(v)
            if v_type == "string" then chars = chars + #v + 4 
            elseif v_type == "number" then chars = chars + 10
            elseif v_type == "boolean" then chars = chars + (v and 4 or 5) + 2
            elseif v_type == "table" then 
                chars = chars + 1 + (depth * 4) + 2 -- \n    {\n
                chars = chars + count_sv_chars_recursive(v, depth + 1, seen) 
                chars = chars + (depth * 4) + 3     --     },\n
            end
        end
        return chars
    end
    
    -- Table Name + formatting + EOF spacing trimmed slightly to align closer to base-10 outputs
    return count_sv_chars_recursive(t, 1, {}) + #PM.name + 2
end

function PM.get_top_mementos()
    if not PM.acct_saved or not PM.acct_saved.memento_usage then return "\n  None" end
    local sort_list = {}
    for t_id, t_count in pairs(PM.acct_saved.memento_usage) do
        table.insert(sort_list, {id = t_id, count = t_count})
    end
    table.sort(sort_list, function(a, b) return a.count > b.count end)
    
    local out_str = ""
    for i = 1, math.min(5, #sort_list) do
        local m_name = GetCollectibleName(sort_list[i].id) or "Unknown"
        out_str = out_str .. string.format("\n  %d. %s (%d loops)", i, m_name, sort_list[i].count)
    end
    if out_str == "" then return "\n  None" end
    return out_str
end

function PM.get_stats_text()
    if not PM.settings.enable_stats_ui then
        return "Statistics Tracking is currently DISABLED to save memory."
    end
    local c_mem = IsConsoleUI() and GetTotalUserAddOnMemoryPoolUsageMB() or (collectgarbage("count") / 1024)
    local warn_str = ""; local limit_str = ""
    
    if IsConsoleUI() then
        limit_str = "100 MB (Hard Limit)"
        if c_mem > 85 then warn_str = "|cFF0000(EXCEEDS CONSOLE LIMIT)|r"
        else warn_str = "|c00FF00(Safe)|r" end
    else
        limit_str = "Dynamic [512MB] (Auto-Scaling)"
        if c_mem > 400 then warn_str = "|cFFA500(High Global Memory)|r"
        else warn_str = "|c00FF00(Safe)|r" end
    end

    local f_count = PM.current_fav_count or 0
    local tot_loops = (PM.acct_saved and PM.acct_saved.total_loops) or 0
    local install_d = (PM.acct_saved and PM.acct_saved.install_date) or "Unknown"
    local v_hist = (PM.acct_saved and PM.acct_saved.version_history) or {PM.version}
    local v_hist_str = table.concat(v_hist, ", ")
    
    local sv_status = _G["PermMementoSaved"] and "|c00FF00Healthy|r" or "|cFF0000Corrupted|r"
    
    local lam_ver, lam_en, lca_ver, lca_en = PM.get_settings_library()
    
    local function get_lib_str(ver, en, name, req)
        if ver == 0 then return string.format("|cFF0000%s (Missing)|r", name) end
        if not en then return string.format("|cFF0000%s (Disabled - v%d)|r", name, ver) end
        if ver < req then return string.format("|cFF0000%s (v%d) (PLEASE UPDATE %s TO v%d)|r", name, ver, name, req) end
        return string.format("|c00FF00%s (v%d)|r", name, ver)
    end
    
    local lib_str = get_lib_str(lam_ver, lam_en, "LAM2", REQUIRED_LAM_VERSION) .. " | " .. get_lib_str(lca_ver, lca_en, "LCA", REQUIRED_LCA_VERSION)
    
    local mem_raw = PM.get_true_ram_footprint(PM)
    local mem_mb = mem_raw / (1024 * 1024)
    local mem_kb = mem_raw / 1024
    local mem_str = (mem_mb >= 1) and string.format("%.2f MB", mem_mb) or string.format("%.2f KB", mem_kb)
    
    local sv_precision_bytes = PM.get_high_precision_sv_disk_size(_G["PermMementoSaved"] or {})
    local sv_size_kb = sv_precision_bytes / 1024
    local sv_size_mb = sv_size_kb / 1024
    local sv_str = (sv_size_mb >= 1) and string.format("%.2f MB", sv_size_mb) or string.format("%.2f KB", sv_size_kb)

    local sv_warn = ""
    if IsConsoleUI() then
        if sv_size_kb > 1000 then sv_warn = "|cFFA500(WARNING: Large Console File)|r"
        else sv_warn = "|c00FF00(Safe)|r" end
    else
        if sv_size_kb > 5000 then sv_warn = "|cFFA500(Large File)|r"
        else sv_warn = "|c00FF00(Safe)|r" end
    end
    
    local format_str = "Installed Since: %s\nVersion History: %s\nActive Library: %s\n" ..
        "Max Lua Memory: %s\nCurrent Global Memory: %s %s\n" ..
        "Data Footprint: %s (Estimated)\n" ..
        "SavedVariable Disk Size: %s (%s) %s\nSession Loops: %d | Total Loops: %d\n" ..
        "Favorites: %d | Learned: %d\n\nMost Used Mementos:%s"

    return string.format(
        format_str,
        install_d, v_hist_str, lib_str, limit_str, PM.format_memory(c_mem),
        warn_str, mem_str, sv_str, sv_status, sv_warn, PM.session_loops,
        tot_loops, f_count, PM.learned_count, PM.get_top_mementos()
    )
end

function PM.update_learned_count()
    local cc = 0
    if PM.acct_saved and PM.acct_saved.learned_data then
        for _ in pairs(PM.acct_saved.learned_data) do cc = cc + 1 end
    end
    PM.learned_count = cc
end

function PM.update_fav_count()
    local cc = 0
    if PM.settings and PM.settings.favorites then
        for k, v in pairs(PM.settings.favorites) do if v then cc = cc + 1 end end
    end
    PM.current_fav_count = cc
end

function PM.update_settings_reference()
    if PM.char_saved and PM.char_saved.use_account_settings then
        PM.settings = PM.acct_saved
    else
        PM.settings = PM.char_saved
    end
    
    if not PM.settings then return end
    
    if type(PM.settings.ui) ~= "table" then
        PM.settings.ui = ZO_ShallowTableCopy(PM.defaults.ui)
    end
    if type(PM.settings.ui_menu) ~= "table" then
        PM.settings.ui_menu = ZO_ShallowTableCopy(PM.defaults.ui_menu)
    end
    if type(PM.settings.sync_module) ~= "table" then
        PM.settings.sync_module = ZO_ShallowTableCopy(PM.defaults.sync_module)
    end
    if type(PM.settings.csa_durations) ~= "table" then
        PM.settings.csa_durations = ZO_ShallowTableCopy(PM.defaults.csa_durations)
    end
    if PM.acct_saved and type(PM.acct_saved.learned_data) ~= "table" then
        PM.acct_saved.learned_data = {}
    end
    if PM.settings.favorites == nil then PM.settings.favorites = {} end
    
    if PM.settings.ui.scale == nil then
        PM.settings.ui.scale = (IsConsoleUI() and 1.0 or 1.0)
    end
    if PM.settings.ui_menu.scale == nil then
        PM.settings.ui_menu.scale = (IsConsoleUI() and 1.2 or 1.0)
    end

    PM.update_learned_count()
    PM.update_ui_anchor()
    PM.toggle_ui_update()
    PM.update_favorites_choices()
    PM.apply_spin_stop()
end

function PM.migrate_data()
    if PM.settings then
        local c_map = {
            activeId = "active_id", paused = "is_paused", logEnabled = "is_log_enabled",
            csaEnabled = "is_csa_enabled", csaCleanupEnabled = "is_csa_cleanup_enabled",
            randomOnLogin = "is_random_on_login", randomOnZone = "is_random_on_zone",
            loopInCombat = "is_loop_in_combat", performanceMode = "is_performance_mode",
            useAccountSettings = "use_account_settings", showInHUD = "show_in_hud",
            unrestricted = "is_unrestricted", autoCleanup = "is_auto_cleanup",
            enableStatsUI = "enable_stats_ui", enableRandomFav = "enable_random_fav",
            enableLearning = "enable_learning", stopSpinning = "is_stop_spinning",
            migrated086 = "is_migrated_086", libWarningShown086 = "has_shown_lib_warning_086",
            alcDisabledPM = "alc_disabled_pm", lastVersion = "last_version",
            versionHistory = "version_history", learnedData = "learned_data",
            totalLoops = "total_loops", mementoUsage = "memento_usage",
            installDate = "install_date", delayIdle = "delay_idle", delayInMenu = "delay_in_menu",
            delayCombatEnd = "delay_combat_end", delayResurrect = "delay_resurrect",
            delayTeleport = "delay_teleport", delayMove = "delay_move",
            delaySprint = "delay_sprint", delayBlock = "delay_block", delaySwim = "delay_swim",
            delaySneak = "delay_sneak", delayMount = "delay_mount", delayCast = "delay_cast",
            csaDurations = "csa_durations", uiMenu = "ui_menu", sync = "sync_module"
        }
        for old_k, new_k in pairs(c_map) do
            if PM.settings[old_k] ~= nil then
                PM.settings[new_k] = PM.settings[old_k]
                PM.settings[old_k] = nil
            end
        end
        if PM.settings.ui then
            if PM.settings.ui.locked ~= nil then
                PM.settings.ui.is_locked = PM.settings.ui.locked
                PM.settings.ui.locked = nil
            end
            if PM.settings.ui.hidden ~= nil then
                PM.settings.ui.is_hidden = PM.settings.ui.hidden
                PM.settings.ui.hidden = nil
            end
        end
        if PM.settings.sync_module then
            if PM.settings.sync_module.random ~= nil then
                PM.settings.sync_module.is_random = PM.settings.sync_module.random
                PM.settings.sync_module.random = nil
            end
            if PM.settings.sync_module.ignoreInCombat ~= nil then
                PM.settings.sync_module.ignore_in_combat = PM.settings.sync_module.ignoreInCombat
                PM.settings.sync_module.ignoreInCombat = nil
            end
            if PM.settings.sync_module.enabled ~= nil then
                PM.settings.sync_module.is_enabled = PM.settings.sync_module.enabled
                PM.settings.sync_module.enabled = nil
            end
        end

        if not PM.settings.is_migrated_086 then
            PM.settings.ui.is_hidden = true; PM.settings.show_in_hud = false
            PM.settings.enable_stats_ui = false; PM.settings.is_log_enabled = false
            PM.settings.is_auto_cleanup = true; PM.settings.is_csa_cleanup_enabled = true
            PM.settings.is_csa_enabled = true; PM.settings.enable_random_fav = false
            PM.settings.enable_learning = false; PM.settings.is_unrestricted = false
            PM.settings.is_loop_in_combat = false; PM.settings.is_performance_mode = true
            PM.settings.is_random_on_login = false; PM.settings.is_random_on_zone = false
            PM.settings.is_stop_spinning = false; PM.settings.sync_module.is_enabled = false
            PM.settings.is_migrated_086 = true
        end

        local delays_to_fix = {
            "delay_move", "delay_sprint", "delay_block", "delay_cast", "delay_swim",
            "delay_sneak", "delay_mount", "delay_idle", "delay_teleport", "delay_resurrect",
            "delay_in_menu", "delay_combat_end"
        }
        for _, k in ipairs(delays_to_fix) do
            if PM.settings[k] and PM.settings[k] > 20 then
                PM.settings[k] = PM.settings[k] / 1000
            end
        end
        for k, v in pairs(PM.settings.csa_durations) do
            if v > 10 then PM.settings.csa_durations[k] = v / 1000 end
        end
        if PM.settings.sync_module and PM.settings.sync_module.delay then
            if PM.settings.sync_module.delay > 20 then
                PM.settings.sync_module.delay = PM.settings.sync_module.delay / 1000
            end
        end
    end

    if PM.acct_saved and PM.acct_saved.learned_data then
        for id, data in pairs(PM.acct_saved.learned_data) do
            if data.aid and not data.ref_id then data.ref_id = data.aid; data.aid = nil end
            if data.refID and not data.ref_id then data.ref_id = data.refID; data.refID = nil end
        end
    end
    
    if _G["PermMementoSaved"] then
        for w_name, w_data in pairs(_G["PermMementoSaved"]) do
            if type(w_data) == "table" then
                for a_name, a_data in pairs(w_data) do
                    if type(a_data) == "table" then
                        for p_id, p_data in pairs(a_data) do
                            if type(p_data) == "table" then
                                if p_id == "$AccountWide" then
                                    p_data["autoResumeScan"] = nil
                                elseif p_data["Character"] then
                                    p_data["Character"]["autoResumeScan"] = nil
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if PM.acct_saved then PM.acct_saved.autoResumeScan = nil end
    if PM.char_saved then PM.char_saved.autoResumeScan = nil end
end

function PM.safe_csa(text, dur_key, limit_override)
    if not PM.settings.is_csa_enabled or not CENTER_SCREEN_ANNOUNCE then return end
    local d_sec = (dur_key and PM.settings.csa_durations[dur_key]) or 6
    local str_limit = limit_override or 70 
    
    if string.len(text) <= str_limit then
        local p = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
        p:SetText(text); p:SetLifespanMS(d_sec * 1000)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(p); return
    end

    local chunks = {}; local cur_chunk = ""
    for word in string.gmatch(text, "%S+") do
        local test_str = (cur_chunk == "") and word or (cur_chunk .. " " .. word)
        if string.len(test_str) > str_limit and cur_chunk ~= "" then
            table.insert(chunks, cur_chunk); cur_chunk = word
        else
            cur_chunk = test_str
        end
    end
    if cur_chunk ~= "" then table.insert(chunks, cur_chunk) end

    local delay_ms = 0; local hex_color = ""
    for i, chunk in ipairs(chunks) do
        local f_msg = chunk
        if i > 1 then f_msg = hex_color .. "..." .. f_msg end
        if i < #chunks then f_msg = f_msg .. "..." end

        local idx = 1
        while idx <= string.len(chunk) do
            local c_tag = string.match(chunk, "^|c%x%x%x%x%x%x", idx)
            if c_tag then hex_color = c_tag; idx = idx + 8
            elseif string.sub(chunk, idx, idx + 1) == "|r" then hex_color = ""; idx = idx + 2
            else idx = idx + 1 end
        end

        local opens = 0; for _ in string.gmatch(f_msg, "|c%x%x%x%x%x%x") do opens = opens + 1 end
        local closes = 0; for _ in string.gmatch(f_msg, "|r") do closes = closes + 1 end
        if opens > closes then f_msg = f_msg .. "|r" end

        if delay_ms > 0 then
            zo_callLater(function() 
                local p = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(
                    CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE
                )
                p:SetText(f_msg); p:SetLifespanMS(d_sec * 1000)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(p)
            end, delay_ms)
        else
            local p = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(
                CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE
            )
            p:SetText(f_msg); p:SetLifespanMS(d_sec * 1000)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(p)
        end
        delay_ms = delay_ms + 1500
    end
end

function PM.log_msg(msg, is_csa, dur_key, limit_override)
    if not PM.settings then return end
    if PM.settings.is_csa_enabled and is_csa then
        PM.safe_csa("|cFFD700" .. tostring(msg) .. "|r", dur_key, limit_override)
    end
    if PM.settings.is_log_enabled then
        local f_msg = "|cFF9900[PM]|r " .. string.gsub(tostring(msg), "\n", " ")
        if CHAT_SYSTEM then CHAT_SYSTEM:AddMessage(f_msg) end
    end
end

function PM.apply_spin_stop()
    if IsConsoleUI() then return end
    local scene_list = { "character", "stats", "interact" }
    for _, s_name in ipairs(scene_list) do
        local scene_obj = SCENE_MANAGER:GetScene(s_name)
        if scene_obj then
            local has_frag = scene_obj:HasFragment(FRAME_PLAYER_FRAGMENT)
            if PM.settings.is_stop_spinning and has_frag then
                scene_obj:RemoveFragment(FRAME_PLAYER_FRAGMENT)
            elseif not PM.settings.is_stop_spinning and not has_frag then
                scene_obj:AddFragment(FRAME_PLAYER_FRAGMENT)
            end
        end
    end
end

function PM.get_random_supported()
    if not PM.settings.enable_random_fav then return nil end
    local avail = {}
    if PM.settings.favorites then
        for f_id, is_fav in pairs(PM.settings.favorites) do
            if is_fav and IsCollectibleUnlocked(f_id) then
                local is_hardcoded = (PM.memento_data[f_id] ~= nil)
                if PM.settings.is_unrestricted or is_hardcoded then table.insert(avail, f_id) end
            end
        end
    end
    if #avail > 0 then return avail[math.random(#avail)] end
    
    for f_id, _ in pairs(PM.memento_data) do
        if IsCollectibleUnlocked(f_id) then table.insert(avail, f_id) end
    end
    
    if PM.settings.is_unrestricted and PM.acct_saved and PM.acct_saved.learned_data then
        for f_id, _ in pairs(PM.acct_saved.learned_data) do
            if IsCollectibleUnlocked(f_id) then table.insert(avail, f_id) end
        end
    end
    return #avail > 0 and avail[math.random(#avail)] or nil
end

function PM.get_random_learned()
    if not PM.settings.enable_random_fav then return nil end
    if not PM.acct_saved or not PM.acct_saved.learned_data then return nil end
    local avail = {}
    for f_id, _ in pairs(PM.acct_saved.learned_data) do
        if IsCollectibleUnlocked(f_id) then table.insert(avail, f_id) end
    end
    return #avail > 0 and avail[math.random(#avail)] or nil
end

function PM.get_random_any()
    if not PM.settings.enable_random_fav then return nil end
    local avail = {}
    for i = 1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO) do
        local f_id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
        if f_id and IsCollectibleUnlocked(f_id) then table.insert(avail, f_id) end
    end
    return #avail > 0 and avail[math.random(#avail)] or nil
end

function PM.update_movement_state()
    if not GetUnitRawWorldPosition then return end
    local p_x, _, p_z = GetUnitRawWorldPosition("player")
    local tick_ms = GetGameTimeMilliseconds()
    
    if PM.last_pos.t == 0 then
        PM.last_pos = {x=p_x, z=p_z, t=tick_ms}; PM.is_moving = false; return
    end
    
    if (tick_ms - PM.last_pos.t) > 100 then 
        local dist = zo_sqrt((p_x - PM.last_pos.x)^2 + (p_z - PM.last_pos.z)^2)
        PM.is_moving = (dist > 0.5)
        PM.last_pos = {x=p_x, z=p_z, t=tick_ms}
    end
end

function PM.get_action_state()
    if IsResurrecting and IsResurrecting() then
        return true, "|cFF0000(Resurrecting)|r", (PM.settings.delay_resurrect or 5) * 1000
    end
    if IsUnitReincarnating and IsUnitReincarnating("player") then
        return true, "|cFF0000(Reviving)|r", (PM.settings.delay_resurrect or 5) * 1000
    end
    
    local is_blocking = false
    if IsBlockActive and IsBlockActive() then is_blocking = true
    elseif IsUnitBlocking and IsUnitBlocking("player") then is_blocking = true end
    
    if is_blocking then
        return true, "|cFF4500(Blocking)|r", (PM.settings.delay_block or 5) * 1000
    end
    if IsSprinting and IsSprinting() then
        return true, "|c00CED1(Sprinting)|r", (PM.settings.delay_sprint or 5) * 1000
    end
    if IsUnitSwimming and IsUnitSwimming("player") then
        return true, "|c0064D2(Swimming)|r", (PM.settings.delay_swim or 5) * 1000
    end
    if IsMounted and IsMounted("player") then
        return true, "|cFFF000(Mounted)|r", (PM.settings.delay_mount or 5) * 1000
    end
    
    local is_sneaking = GetUnitStealthState and GetUnitStealthState("player") ~= STEALTH_STATE_NONE
    if is_sneaking then
        return true, "|c1EBEA5(Sneaking)|r", (PM.settings.delay_sneak or 5) * 1000
    end
    if PM.is_moving then
        return true, "|c00CED1(Moving)|r", (PM.settings.delay_move or 5) * 1000
    end
    return false, "", 0
end

function PM.update_ui_anchor()
    if not PM.ui_window or not PM.settings then return end
    PM.ui_window:ClearAnchors(); PM.ui_window:SetMovable(not PM.settings.ui.is_locked)
    local x_offset = 0; if _G["PP"] then x_offset = 0.5 end 
    local is_pad = IsConsoleUI() or IsInGamepadPreferredMode()
    
    if PM.settings.show_in_hud then
        PM.ui_window:SetScale(PM.settings.ui.scale or (is_pad and 1.0 or 1.0))
        if PM.settings.ui.left == PM.defaults.ui.left and PM.settings.ui.top == PM.defaults.ui.top then
            if is_pad then PM.ui_window:SetAnchor(LEFT, ZO_Compass, RIGHT, 15, 0)
            else PM.ui_window:SetAnchor(LEFT, ZO_Compass, RIGHT, 25 + x_offset, -5) end
        else
            PM.ui_window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PM.settings.ui.left, PM.settings.ui.top)
        end
    else
        PM.ui_window:SetScale(PM.settings.ui_menu.scale or (is_pad and 1.2 or 1.0))
        local d_left, d_top = PM.defaults.ui_menu.left, PM.defaults.ui_menu.top
        if PM.settings.ui_menu.left == d_left and PM.settings.ui_menu.top == d_top then
            if is_pad then
                PM.ui_window:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -50, 50)
            else
                if ZO_CollectionsBook_TopLevelSearchBox then
                    PM.ui_window:SetAnchor(LEFT, ZO_CollectionsBook_TopLevelSearchBox, RIGHT, 10 + x_offset, 0)
                else PM.ui_window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 100 + x_offset, 100) end
            end
        else
            PM.ui_window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PM.settings.ui_menu.left, PM.settings.ui_menu.top)
        end
    end
end

function PM.update_ui_scenes()
    if not PM.hudFragment or not PM.menuFragment then return end
    local hud_arr = {"hud", "hudui", "gamepad_hud", "interact"}
    local menu_arr = {"collectionsBook", "gamepad_collections_book", "gamepadCollectionsBook"}
    
    for _, nm in ipairs(hud_arr) do
        local s = SCENE_MANAGER:GetScene(nm)
        if s and s:HasFragment(PM.hudFragment) then s:RemoveFragment(PM.hudFragment) end
    end
    for _, nm in ipairs(menu_arr) do
        local s = SCENE_MANAGER:GetScene(nm)
        if s and s:HasFragment(PM.menuFragment) then s:RemoveFragment(PM.menuFragment) end
    end
    
    if not PM.settings.ui.is_hidden then
        if PM.settings.show_in_hud then
            for _, nm in ipairs(hud_arr) do
                local s = SCENE_MANAGER:GetScene(nm)
                if s then s:AddFragment(PM.hudFragment) end
            end
        else
            for _, nm in ipairs(menu_arr) do
                local s = SCENE_MANAGER:GetScene(nm)
                if s then s:AddFragment(PM.menuFragment) end
            end
        end
    end
    PM.update_ui_anchor()
end

function PM.toggle_ui_update()
    if not PM.ui_window then return end
    if PM.settings.ui.is_hidden then
        PM.ui_window:SetHandler("OnUpdate", nil)
        PM.ui_window:SetHidden(true)
        PM.update_ui_scenes()
    else
        PM.ui_window:SetHandler("OnUpdate", PM.ui_update_fn)
        PM.update_ui_scenes()
        
        local cur_scene = SCENE_MANAGER:GetCurrentScene()
        local should_show = false
        
        if cur_scene then
            if PM.settings.show_in_hud and cur_scene:HasFragment(PM.hudFragment) then
                should_show = true
            elseif not PM.settings.show_in_hud and cur_scene:HasFragment(PM.menuFragment) then
                should_show = true
            end
        end
        
        PM.ui_window:SetHidden(not should_show)
    end
end

function PM.create_mover(target, label_text)
        local wasHidden = target:IsHidden()
        target:SetHidden(false)
        
        local mover = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_TOPLEVELCONTROL)
        local t_scale = target:GetScale() or 1
        local w, h = target:GetWidth() * t_scale, target:GetHeight() * t_scale
        if w < 50 then w = 250 end
        if h < 20 then h = 60 end
        mover:SetDimensions(w, h)
        
        mover:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, target:GetLeft(), target:GetTop())
        mover:SetDrawTier(DT_HIGH)
        mover:SetDrawLayer(DL_OVERLAY)
        
        if wasHidden then target:SetHidden(true) end
        mover:SetDrawLevel(9999)
        mover:SetMouseEnabled(true)
        mover:SetMovable(true)
        mover:SetClampedToScreen(true)
            
        local bg = WINDOW_MANAGER:CreateControl(nil, mover, CT_BACKDROP)
        bg:SetAnchorFill(mover)
        bg:SetCenterColor(0, 0.5, 0.7, 0.32)
        bg:SetEdgeColor(0, 0.5, 0.7, 1)
        bg:SetEdgeTexture('', 8, 1, 0)
        
        local lbl = WINDOW_MANAGER:CreateControl(nil, mover, CT_LABEL)
        lbl:SetAnchorFill(mover)
        local font_mover = IsInGamepadPreferredMode() and "ZoFontGamepad27" or "ZoFontWinH5"
        lbl:SetFont(font_mover)
        lbl:SetColor(1, 0.82, 0, 0.9)
        lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        lbl:SetText(label_text)
        
        mover.target = target
        
        mover:SetHandler("OnMoveStop", function(self)
            self.target:ClearAnchors()
            self.target:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self:GetLeft(), self:GetTop())
        end)
        
        return mover
    end

    function PM.unlock_ui()
        if PM.is_ui_unlocked then return end
        PM.is_ui_unlocked = true
        
        if SCENE_MANAGER then SCENE_MANAGER:Show("hud") end
        
        PM.orig_pos = {
            ui = {left = PM.settings.ui.left, top = PM.settings.ui.top},
            ui_menu = {left = PM.settings.ui_menu.left, top = PM.settings.ui_menu.top}
        }
        
        local cur_scene = SCENE_MANAGER:GetCurrentScene()
        if cur_scene and PM.ui_window then
            local t_frag = PM.settings.show_in_hud and PM.hudFragment or PM.menuFragment
            if cur_scene:HasFragment(t_frag) then 
                PM.ui_window:SetHidden(false) 
            end
        end
        
        PM.movers = {}
        if PM.ui_window then 
            table.insert(PM.movers, PM.create_mover(PM.ui_window, "PM UI")) 
        end

        local dialog_id = "PM_UI_UNLOCK_PROMPT"
        if not ESO_Dialogs[dialog_id] then
            ESO_Dialogs[dialog_id] = {
                canQueue = true, 
                gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC }, 
                title = { text = "|c00FFFFPM UI Unlocked|r" }, 
                mainText = { 
                    text = "Move the UI elements to your desired locations.\n\n" ..
                           "Press Accept to Save.\nPress Decline to Cancel." 
                },
                buttons = { 
                    { 
                        text = "Save", keybind = "DIALOG_PRIMARY", 
                        callback = function() PM.lock_ui(true) end 
                    },
                    { 
                        text = "Cancel", keybind = "DIALOG_NEGATIVE", 
                        callback = function() PM.lock_ui(false) end 
                    }
                }
            }
        end

        zo_callLater(function()
            if IsInGamepadPreferredMode() then 
                ZO_Dialogs_ShowGamepadDialog(dialog_id) 
            else 
                ZO_Dialogs_ShowDialog(dialog_id) 
            end
        end, 500)
    end

    function PM.lock_ui(save)
        if not PM.is_ui_unlocked then return end
        PM.is_ui_unlocked = false
        
        if PM.movers then
            for _, mover in ipairs(PM.movers) do
                mover:SetHidden(true)
            end
            PM.movers = {}
        end
        
        if save then
            if PM.ui_window then
                if PM.settings.show_in_hud then
                    PM.settings.ui.left = PM.ui_window:GetLeft()
                    PM.settings.ui.top = PM.ui_window:GetTop()
                else
                    PM.settings.ui_menu.left = PM.ui_window:GetLeft()
                    PM.settings.ui_menu.top = PM.ui_window:GetTop()
                end
            end
            PM.log_msg("UI Positions Saved.", true, "ui", 90)
        else
            PM.settings.ui.left = PM.orig_pos.ui.left
            PM.settings.ui.top = PM.orig_pos.ui.top
            PM.settings.ui_menu.left = PM.orig_pos.ui_menu.left
            PM.settings.ui_menu.top = PM.orig_pos.ui_menu.top
            
            PM.update_ui_anchor()
            PM.log_msg("UI Positioning Cancelled.", true, "ui", 90)
        end
        
        PM.toggle_ui_update()
    end

    function PM.create_ui()
    local win = WINDOW_MANAGER:CreateControl("PermMementoUI", GuiRoot, CT_TOPLEVELCONTROL)
    win:SetClampedToScreen(true); win:SetMouseEnabled(true)
    win:SetDrawTier(DT_OVERLAY); win:SetDrawLayer(DL_OVERLAY)
    win:SetDrawLevel(100); win:SetHidden(true)
    PM.ui_window = win
    
    if PM.is_lca_valid then
        PM.ui_mover = LibCombatAlerts.MoveableControl:New(win)
        PM.ui_mover:RegisterCallback(PM.name .. "_UI", 2, function(new_pos)
            if not PM.settings then return end 
            if type(new_pos.left) == "number" and type(new_pos.top) == "number" then
                if PM.settings.show_in_hud then
                    PM.settings.ui.left = new_pos.left
                    PM.settings.ui.top = new_pos.top
                else
                    PM.settings.ui_menu.left = new_pos.left
                    PM.settings.ui_menu.top = new_pos.top
                end
            end
        end)
    else
        win:SetHandler("OnMoveStop", function(ctrl) 
            if not PM.settings then return end 
            if PM.settings.show_in_hud then
                PM.settings.ui.left = ctrl:GetLeft(); PM.settings.ui.top = ctrl:GetTop()
            else
                PM.settings.ui_menu.left = ctrl:GetLeft(); PM.settings.ui_menu.top = ctrl:GetTop()
            end
        end)
    end
    
    local tex_bg = WINDOW_MANAGER:CreateControl("PermMementoBG", win, CT_BACKDROP)
    tex_bg:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 0)
    tex_bg:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, 0, 0)
    tex_bg:SetCenterColor(0, 0, 0, 0.6)
    tex_bg:SetEdgeColor(0.6, 0.6, 0.6, 0.8)
    tex_bg:SetEdgeTexture(nil, 1, 1, 1, 0)
    
    local text_lbl = WINDOW_MANAGER:CreateControl("PermMementoLabel", win, CT_LABEL)
    if IsInGamepadPreferredMode() then text_lbl:SetFont("ZoFontGamepad22")
    else text_lbl:SetFont("ZoFontGameSmall") end
    
    text_lbl:SetColor(1, 1, 1, 1); text_lbl:SetText("[PM] Ready")
    text_lbl:SetAnchor(CENTER, win, CENTER, 0, 0)
    
    local function force_resize()
        win:SetDimensions(text_lbl:GetTextWidth() + 20, text_lbl:GetTextHeight() + 10)
    end
    local last_tick = 0
    
    PM.ui_update_fn = function(ctrl, f_time)
        PM.update_movement_state()
        if not PM.settings then return end 
        local r_rate = PM.settings.is_performance_mode and 1.0 or 0.25
        if (f_time - last_tick < r_rate) then return end
        last_tick = f_time

        local md = PM.get_data(PM.settings.active_id)
        if not PM.settings.active_id or not md then 
            local idle_txt = "[PM] Inactive"
            local l2 = ""
            if PM.settings.is_unrestricted then l2 = l2 .. "|cFF0000[UNRESTRICTED]|r " end
            if PM.settings.sync_module.is_enabled then l2 = l2 .. "|c00BFFF(Sync: ON)|r " end
            
            if PM.mem_state == 1 then l2 = l2 .. "|cFFFF00[Cleaning LUA Memory...]|r "
            elseif PM.mem_state == 2 then
                l2 = l2 .. string.format("|c00FF00[%s Freed]|r ", PM.format_memory(PM.mem_freed))
            elseif PM.mem_state == 3 then 
                local diff = math.floor((PM.mem_next_sweep - GetGameTimeMilliseconds()) / 1000)
                l2 = l2 .. string.format("|cAAAAAA[Next Memory Sweep %ds]|r ", math.max(0, diff))
            end
            
            l2 = string.match(l2, "^%s*(.-)%s*$")
            if l2 ~= "" then idle_txt = idle_txt .. "\n" .. l2 end
            text_lbl:SetText(idle_txt); force_resize(); return 
        end
        
        if PM.settings.is_paused then
            text_lbl:SetText(string.format("[PM] %s |cFF0000(Paused)|r", md.name))
            force_resize(); return
        end
        
        local st_info = ""
        if IsUnitDead and IsUnitDead("player") then st_info = "|c881EE4(Dead)|r"
        elseif IsUnitInCombat and IsUnitInCombat("player") and not PM.settings.is_loop_in_combat then
            st_info = "|cEF008C(Combat)|r"
        else
            local is_busy, act_txt, _ = PM.get_action_state()
            if is_busy then
                st_info = act_txt 
            elseif (IsInteracting and IsInteracting()) or
                   (IsPlayerInteractingWithObject and IsPlayerInteractingWithObject()) then
                st_info = "|cFFA500(Busy)|r"
            end
        end
        
        local cd_txt = ""; local cd_rem = 0
        if GetCollectibleCooldownAndDuration then
            cd_rem, _ = GetCollectibleCooldownAndDuration(PM.settings.active_id)
        end
        
        if cd_rem > 0 then cd_txt = string.format(" |cFFA500(%.1fs)|r", cd_rem / 1000) 
        else 
            if st_info == "" then 
                local tick_ms = GetGameTimeMilliseconds()
                if tick_ms < PM.next_fire_time then 
                    local d_sec = (PM.next_fire_time - tick_ms) / 1000
                    cd_txt = string.format(" |cFF69B4(Delaying... %.1fs)|r", d_sec)
                else cd_txt = " |c00FF00(Ready)|r" end
            end 
        end
        
        local f_str = string.format("[PM] %s", md.name)
        local x_info = ""
        if st_info ~= "" or cd_txt ~= "" then x_info = x_info .. st_info .. cd_txt end
        
        if PM.acct_saved and PM.acct_saved.learned_data then
            if PM.acct_saved.learned_data[PM.settings.active_id] then
                x_info = x_info .. string.format(" |cAAAAAA(Learned: %d)|r", PM.learned_count)
            end
        end
        
        if x_info ~= "" then f_str = f_str .. " " .. string.match(x_info, "^%s*(.-)%s*$") end

        if PM.pending_sync_id then
            local s_name = GetCollectibleName(PM.pending_sync_id) or "?"
            f_str = f_str .. " |cFF8800(Queued: " .. s_name .. ")|r"
        end
        
        if (PM.settings.is_random_on_zone or PM.settings.is_random_on_login) then
            if PM.next_random_precalc then
                local n_name = GetCollectibleName(PM.next_random_precalc) or "?"
                f_str = f_str .. " |cAA88FF(Next: " .. n_name .. ")|r"
            end
        end

        local l2 = ""
        if PM.settings.is_unrestricted then l2 = l2 .. "|cFF0000[UNRESTRICTED]|r " end
        if PM.settings.sync_module.is_enabled then l2 = l2 .. "|c00BFFF(Sync: ON)|r " end
        
        if PM.mem_state == 1 then l2 = l2 .. "|cFFFF00[Cleaning LUA Memory...]|r "
        elseif PM.mem_state == 2 then
            l2 = l2 .. string.format("|c00FF00[%s Freed]|r ", PM.format_memory(PM.mem_freed))
        elseif PM.mem_state == 3 then 
            local diff = math.floor((PM.mem_next_sweep - GetGameTimeMilliseconds()) / 1000)
            l2 = l2 .. string.format("|cAAAAAA[Next Memory Sweep %ds]|r ", math.max(0, diff))
        end
        
        l2 = string.match(l2, "^%s*(.-)%s*$")
        if l2 ~= "" then f_str = f_str .. "\n" .. l2 end

        text_lbl:SetText(f_str); force_resize()
    end
    
    PM.uiLabel = text_lbl
    PM.hudFragment = ZO_HUDFadeSceneFragment:New(win)
    PM.menuFragment = ZO_FadeSceneFragment:New(win)
end

function PM.run_manual_cleanup(is_auto, is_emergency)
    PM.mem_state = 1
    zo_callLater(function()
        local before = collectgarbage("count") / 1024
        collectgarbage("collect")
        if is_emergency then collectgarbage("collect") end
        local after = collectgarbage("count") / 1024
        PM.mem_freed = before - after
        PM.mem_state = 0
        
        if PM.mem_freed > 0.01 then
            local msg = string.format("Memory Freed %s", PM.format_memory(PM.mem_freed))
            if PM.settings.is_log_enabled and CHAT_SYSTEM then
                CHAT_SYSTEM:AddMessage("|cFF9900[PM]|r " .. msg)
            end
            
            local show_csa = PM.settings.is_csa_enabled
            if is_auto and not PM.settings.is_csa_cleanup_enabled then show_csa = false end
            
            if show_csa and CENTER_SCREEN_ANNOUNCE then
                local d_sec = PM.settings.csa_durations.cleanup or 6
                local p = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(
                    CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE
                )
                p:SetText("|cFFD700" .. msg .. "|r"); p:SetLifespanMS(d_sec * 1000)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(p)
            end
        end
    end, 500)
end

function PM.trigger_memory_check(check_type, delay)
    if not PM.settings.enable_stats_ui and not PM.settings.is_auto_cleanup then return end
    if is_alc_enabled() then return end
    if PM.mem_state == 1 or PM.is_mem_check_queued then return end 
    
    local is_con = IsConsoleUI()
    local current_mb = is_con and GetTotalUserAddOnMemoryPoolUsageMB() or (collectgarbage("count") / 1024)
    local limit_threshold = is_con and 85 or 400

    if current_mb >= limit_threshold then
        local in_combat = IsUnitInCombat and IsUnitInCombat("player")
        if in_combat or IsUnitDead("player") then return end
        PM.is_mem_check_queued = true 

        zo_callLater(function()
            PM.is_mem_check_queued = false
            if PM.mem_state == 1 then return end
            
            local still_in_combat = IsUnitInCombat and IsUnitInCombat("player")
            if still_in_combat or IsUnitDead("player") then return end

            if check_type == "Menu" then
                local in_menu = SCENE_MANAGER and not (
                    SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui")
                )
                if not in_menu then return end 
            end

            local recheck_mb = is_con and GetTotalUserAddOnMemoryPoolUsageMB() or (collectgarbage("count") / 1024)
            if recheck_mb >= limit_threshold then
                PM.run_manual_cleanup(true)
                EVENT_MANAGER:UnregisterForUpdate(PM.name .. "_MemFallback")
                EVENT_MANAGER:RegisterForUpdate(PM.name .. "_MemFallback", 300000, function()
                    PM.trigger_memory_check("Fallback", 0)
                end)
            end
        end, delay)
    else
        EVENT_MANAGER:UnregisterForUpdate(PM.name .. "_MemFallback")
        PM.mem_state = 0
    end
end

function PM.is_busy()
    if not IsPlayerActivated() then return true, (PM.settings.delay_teleport or 5) * 1000 end
    if IsUnitDead and IsUnitDead("player") then return true, 2000 end
    
    local in_combat = IsUnitInCombat and IsUnitInCombat("player")
    if in_combat then
        if not PM.settings.is_loop_in_combat then
            return true, (PM.settings.delay_combat_end or 5) * 1000
        end
    end
    
    if GetCraftingInteractionType and GetCraftingInteractionType() ~= 0 then return true, 2000 end
    if ZO_CraftingUtils_IsPerformingCrafting and ZO_CraftingUtils_IsPerformingCrafting() then
        return true, 2000
    end
    if SCENE_MANAGER and SCENE_MANAGER:IsShowing("interact") then return true, 2000 end
    
    local is_interact = (IsInteracting and IsInteracting())
    local get_interact = (GetInteractionType and GetInteractionType() ~= INTERACTION_NONE)
    local is_obj_interact = (IsPlayerInteractingWithObject and IsPlayerInteractingWithObject())
    if is_interact or get_interact or is_obj_interact then return true, 1000 end
    
    if SCENE_MANAGER and not (SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui")) then
        return true, (PM.settings.delay_in_menu or 5) * 1000
    end
    
    local is_act_busy, _, act_delay = PM.get_action_state()
    if is_act_busy then return true, act_delay end
    
    return false, 0
end

function PM.on_effect_changed(eventCode, changeType, effectSlot, effectName, unitTag, beginTime,
                              endTime, stackCount, iconName, buffType, effectType, abilityType,
                              statusEffectType, unitName, unitId, abilityId, sourceUnitId)
    if not PM.settings or not PM.settings.active_id then return end
    if not PM.settings.enable_learning then return end
    
    local is_gain = (changeType == EFFECT_RESULT_GAINED)
    if (PM.settings.is_unrestricted or PM.is_scanning) and is_gain then
         local act_id = PM.settings.active_id
         local is_unlearned = (PM.acct_saved and PM.acct_saved.learned_data and
                               not PM.acct_saved.learned_data[act_id])
                               
         if not PM.memento_data[act_id] and is_unlearned then
             local cd_rem = 0; local cd_dur = 10000
             if GetCollectibleCooldownAndDuration then
                 cd_rem, cd_dur = GetCollectibleCooldownAndDuration(act_id)
             end
             local s_dur = (cd_dur > 0) and cd_dur or 10000 
             local c_name = GetCollectibleName(act_id)
             if not PM.acct_saved.learned_data then PM.acct_saved.learned_data = {} end
             
             local r_id = 0
             local c_data = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(act_id)
             if c_data and c_data.GetReferenceId then r_id = c_data:GetReferenceId() end
             if r_id == 0 then r_id = abilityId end 

             PM.acct_saved.learned_data[act_id] = {
                 id = act_id, ref_id = r_id, dur = s_dur, name = c_name
             }
             PM.update_learned_count()
             
             local out_msg = string.format(
                 "Saved: %s\nID: %d | RefID: %d | Dur: %dms | Total Learned: %d",
                 c_name, act_id, r_id, s_dur, PM.learned_count
             )
             PM.log_msg(out_msg, true, "settings", 70)
         end
    end
    
    local md = PM.get_data(PM.settings.active_id)
    local is_match = false
    if md and md.ref_id > 0 and abilityId == md.ref_id then is_match = true end
    
    if is_match and changeType == EFFECT_RESULT_FADED then
        PM.loop_token = (PM.loop_token or 0) + 1
        PM.run_loop(PM.loop_token)
    end
end

function PM.auto_scan_mementos()
    if not PM.settings.enable_learning then
        PM.log_msg("Learning Mode is currently DISABLED.", true, "error"); return
    end
    if PM.is_scanning then return end
    PM.is_scanning = true
    
    local c_count = 0
    local max_col = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO)
    
    PM.log_msg("Auto-Scan...Reloading UI...", true, "settings", 90)
    PM.acct_saved.recentScans = {} 
    
    for i = 1, max_col do
        local m_id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
        if m_id and IsCollectibleUnlocked(m_id) then
            local is_known = false
            if PM.acct_saved and PM.acct_saved.learned_data then
                if PM.acct_saved.learned_data[m_id] then is_known = true end
            end
            
            if not is_known then 
                local _, cd_dur = GetCollectibleCooldownAndDuration(m_id)
                local s_dur = (cd_dur > 0) and cd_dur or 10000 
                local c_name = GetCollectibleName(m_id)
                if not PM.acct_saved.learned_data then PM.acct_saved.learned_data = {} end
                
                local r_id = 0
                local c_data = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(m_id)
                if c_data and c_data.GetReferenceId then r_id = c_data:GetReferenceId() end
                
                PM.acct_saved.learned_data[m_id] = {
                    id = m_id, ref_id = r_id, dur = s_dur, name = c_name
                }
                table.insert(PM.acct_saved.recentScans, m_id)
                c_count = c_count + 1
            end
        end
    end
    
    PM.is_scanning = false
    if c_count == 0 then
        PM.log_msg("All owned mementos have already been learned.", true, "settings", 90)
        PM.acct_saved.recentScans = nil 
    else
        PM.update_learned_count()
        PM.log_msg("Successfully Learned " .. c_count .. " new mementos! Reloading UI...", false)
        PM.is_menu_built = false; zo_callLater(function() ReloadUI("ingame") end, 3000)
    end
end

function PM.run_loop(req_token)
    if not PM.settings or PM.settings.is_paused or not PM.settings.active_id then return end
    if req_token ~= PM.loop_token then return end
    
    local md = PM.get_data(PM.settings.active_id)
    if not md then PM.settings.active_id = nil; return end
    
    local is_busy, w_delay = PM.is_busy()
    if is_busy then 
        local wait_ms = (w_delay > 0) and w_delay or ((PM.settings.delay_idle or 0) * 1000)
        if wait_ms < 100 then wait_ms = 100 end
        if GetGameTimeMilliseconds then
            PM.next_fire_time = GetGameTimeMilliseconds() + wait_ms
        end
        zo_callLater(function() PM.run_loop(req_token) end, wait_ms); return 
    end
    PM.trigger_memory_check("Loop", 0)
    
    local cur_target = PM.settings.active_id
    if PM.pending_sync_id then cur_target = PM.pending_sync_id end
    
    local cd_rem = 0
    if GetCollectibleCooldownAndDuration then
        cd_rem, _ = GetCollectibleCooldownAndDuration(cur_target)
    end
    if cd_rem and cd_rem > 500 then 
        local wait_ms = cd_rem + ((PM.settings.delay_idle or 0) * 1000)
        if wait_ms < 1000 then wait_ms = 1000 end
        if GetGameTimeMilliseconds then
            PM.next_fire_time = GetGameTimeMilliseconds() + wait_ms
        end
        zo_callLater(function() PM.run_loop(req_token) end, wait_ms); return 
    end
    
    PM.is_looping = true 
    if PM.pending_sync_id then
         PM.is_sync_firing = true; UseCollectible(PM.pending_sync_id)
         zo_callLater(function()
             if req_token ~= PM.loop_token then return end
             local s_rem, s_dur = 0, 10000
             if GetCollectibleCooldownAndDuration then
                 s_rem, s_dur = GetCollectibleCooldownAndDuration(PM.pending_sync_id)
             end
             local wait_ms = (s_rem > 0) and s_rem or s_dur
             PM.log_msg("Sync Finished...", true, "sync", 80)
             PM.pending_sync_id = nil; PM.is_sync_firing = false; PM.is_looping = false
             if GetGameTimeMilliseconds then
                 PM.next_fire_time = GetGameTimeMilliseconds() + wait_ms + 1000
             end
             zo_callLater(function() PM.run_loop(req_token) end, wait_ms + 1000)
         end, 500); return 
    end

    UseCollectible(PM.settings.active_id) 
    PM.session_loops = PM.session_loops + 1
    if PM.acct_saved then
        PM.acct_saved.total_loops = (PM.acct_saved.total_loops or 0) + 1
        if not PM.acct_saved.memento_usage then PM.acct_saved.memento_usage = {} end
        local curr_use = PM.acct_saved.memento_usage[PM.settings.active_id] or 0
        PM.acct_saved.memento_usage[PM.settings.active_id] = curr_use + 1
        PM.trigger_priority_save()
    end
    
    local rand_zone = PM.settings.is_random_on_zone
    local rand_log = PM.settings.is_random_on_login
    if (rand_zone or rand_log) and PM.settings.enable_random_fav then
        PM.next_random_precalc = PM.get_random_supported()
    end
    PM.is_looping = false
    
    local is_unres = PM.settings.is_unrestricted
    if not PM.memento_data[PM.settings.active_id] and not is_unres then
        PM.settings.active_id = nil; return
    end
    
    local wait_ms = md.dur + 1000 + ((PM.settings.delay_idle or 0) * 1000)
    if GetGameTimeMilliseconds then PM.next_fire_time = GetGameTimeMilliseconds() + wait_ms end
    zo_callLater(function() PM.run_loop(req_token) end, wait_ms)
end

function PM.start_loop(c_id, bypass_res)
    local md = PM.get_data(c_id)
    if not md then return end
    
    if not PM.memento_data[c_id] and not PM.settings.is_unrestricted and not bypass_res then
        PM.log_msg(
            "Activating " .. md.name .. " (Looping Disabled - Unrestricted Mode Required)",
            true, "activation", 70
        )
        UseCollectible(c_id); return 
    end

    PM.settings.active_id = c_id; PM.settings.is_paused = false
    PM.loop_token = (PM.loop_token or 0) + 1
    
    local rand_zone = PM.settings.is_random_on_zone
    local rand_log = PM.settings.is_random_on_login
    if (rand_zone or rand_log) and PM.settings.enable_random_fav then
        PM.next_random_precalc = PM.get_random_supported()
    end
    
    local cur_token = PM.loop_token 
    local is_busy, w_delay = PM.is_busy()
    if is_busy then 
        local wait_ms = (w_delay > 0) and w_delay or ((PM.settings.delay_idle or 0) * 1000)
        if wait_ms < 100 then wait_ms = 100 end
        if GetGameTimeMilliseconds then PM.next_fire_time = GetGameTimeMilliseconds() + wait_ms end
        zo_callLater(function() PM.run_loop(cur_token) end, wait_ms)
    else 
        PM.is_looping = true; UseCollectible(c_id); PM.is_looping = false
        PM.session_loops = PM.session_loops + 1
        if PM.acct_saved then
            PM.acct_saved.total_loops = (PM.acct_saved.total_loops or 0) + 1
            if not PM.acct_saved.memento_usage then PM.acct_saved.memento_usage = {} end
            local curr_use = PM.acct_saved.memento_usage[c_id] or 0
            PM.acct_saved.memento_usage[c_id] = curr_use + 1
            PM.trigger_priority_save()
        end
        local wait_ms = md.dur + 1000 + ((PM.settings.delay_idle or 0) * 1000)
        if GetGameTimeMilliseconds then PM.next_fire_time = GetGameTimeMilliseconds() + wait_ms end
        zo_callLater(function() PM.run_loop(cur_token) end, wait_ms) 
    end
end

function PM.update_profile_list()
    PM.profile_list_names = {}
    PM.profile_list_values = {}
    local raw_names = {}
    
    if PM.acct_saved and PM.acct_saved.profiles then
        for p_name, _ in pairs(PM.acct_saved.profiles) do
            table.insert(raw_names, p_name)
        end
    end
    table.sort(raw_names)
    
    for _, p_name in ipairs(raw_names) do
        local display_name = p_name
        if PM.settings and PM.settings.active_profile == p_name then
            display_name = "|c00FF00" .. p_name .. "|r"
        end
        table.insert(PM.profile_list_names, display_name)
        table.insert(PM.profile_list_values, p_name)
    end
    
    if #PM.profile_list_names == 0 then
        table.insert(PM.profile_list_names, "None")
        table.insert(PM.profile_list_values, "")
    end
    
    local ddl = _G["PM_ProfileDropdown"]
    if ddl and ddl.UpdateChoices then
        ddl:UpdateChoices(PM.profile_list_names, PM.profile_list_values)
        ddl:UpdateValue(false, PM.selected_profile_name or "")
    end
end

function PM.save_profile(p_name)
    if not p_name or p_name == "" then
        PM.log_msg("Profile name cannot be empty.", true, "error"); return
    end
    if not PM.acct_saved.profiles then PM.acct_saved.profiles = {} end
    
    local exclude = {
        learned_data = true, favorites = true, total_loops = true,
        memento_usage = true, install_date = true, version_history = true,
        last_version = true, is_migrated_087 = true,
        has_shown_lib_warning_087 = true, alc_disabled_pm = true,
        active_profile = true
    }
    
    local new_prof = {}
    for k, v in pairs(PM.settings) do
        if not exclude[k] then
            if type(v) == "table" then
                new_prof[k] = ZO_DeepTableCopy(v)
            else
                new_prof[k] = v
            end
        end
    end
    
    PM.settings.active_profile = p_name
    PM.acct_saved.profiles[p_name] = new_prof
    PM.log_msg("Profile Saved: " .. p_name, true, "settings", 90)
    PM.profile_input_text = ""
    PM.selected_profile_name = p_name
    PM.update_profile_list()
end

function PM.load_profile(p_name)
    if not p_name or p_name == "" then
        PM.log_msg("No profile selected to load.", true, "error"); return
    end
    if PM.acct_saved.profiles and PM.acct_saved.profiles[p_name] then
        local p_data = PM.acct_saved.profiles[p_name]
        for k, v in pairs(p_data) do
            if type(v) == "table" then
                PM.settings[k] = ZO_DeepTableCopy(v)
            else
                PM.settings[k] = v
            end
        end
        PM.settings.active_profile = p_name
        PM.log_msg("Profile Loaded: " .. p_name, true, "settings", 90)
        zo_callLater(function() ReloadUI("ingame") end, 1000)
    end
end

function PM.delete_profile(p_name)
    if not p_name or p_name == "" then
        PM.log_msg("No profile selected to delete.", true, "error"); return
    end
    if PM.acct_saved.profiles and PM.acct_saved.profiles[p_name] then
        PM.acct_saved.profiles[p_name] = nil
        if PM.settings.active_profile == p_name then
            PM.settings.active_profile = nil
        end
        PM.log_msg("Profile Deleted: " .. p_name, true, "settings", 90)
        if PM.selected_profile_name == p_name then PM.selected_profile_name = "" end
        PM.update_profile_list()
    end
end

function PM.delete_learned_data(del_id)
    if not del_id or del_id == 0 then return end
    if PM.acct_saved and PM.acct_saved.learned_data then
        PM.acct_saved.learned_data[del_id] = nil
        PM.log_msg("Learned data deleted.", true, "settings", 90)
        PM.update_menu_choices()
        local lrn_ddl = _G["PM_LearnedDropdown"]
        if lrn_ddl then lrn_ddl:UpdateValue(false, 0) end
    end
end

function PM.delete_all_learned_data()
    if PM.acct_saved and PM.acct_saved.learned_data then
        PM.acct_saved.learned_data = {}
        PM.log_msg("ALL Learned data deleted.", true, "settings", 90)
        PM.update_menu_choices()
        local lrn_ddl = _G["PM_LearnedDropdown"]
        if lrn_ddl then lrn_ddl:UpdateValue(false, 0) end
    end
end

function PM.update_favorites_choices()
    PM.update_fav_count()
    PM.fav_all_names, PM.fav_all_ids = {}, {}
    PM.fav_current_names, PM.fav_current_ids = {"None"}, {0}
    
    local arr_all = {}
    local max_cat = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO)
    for i = 1, max_cat do
        local f_id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
        if f_id and IsCollectibleUnlocked(f_id) then
            table.insert(arr_all, {name=GetCollectibleName(f_id), id=f_id})
        end
    end
    table.sort(arr_all, function(a,b) return a.name < b.name end)
    for _, t in ipairs(arr_all) do
        local f_str = t.name; local md = PM.get_data(t.id)
        if md then f_str = f_str .. string.format(" (%ds)", md.dur / 1000) end
        if PM.settings.favorites[t.id] then f_str = "|c00FF00" .. f_str .. " (Fav)|r" end
        table.insert(PM.fav_all_names, f_str); table.insert(PM.fav_all_ids, t.id)
    end
    
    local arr_fav = {}
    if PM.settings and PM.settings.favorites then
        for f_id, is_fav in pairs(PM.settings.favorites) do
            if is_fav and IsCollectibleUnlocked(f_id) then
                table.insert(arr_fav, {name=GetCollectibleName(f_id), id=f_id})
            end
        end
    end
    table.sort(arr_fav, function(a,b) return a.name < b.name end)
    for _, t in ipairs(arr_fav) do 
        local f_str = t.name; local md = PM.get_data(t.id)
        if md then f_str = f_str .. string.format(" (%ds)", md.dur / 1000) end
        table.insert(PM.fav_current_names, f_str); table.insert(PM.fav_current_ids, t.id) 
    end
    
    local cand_ddl = _G["PM_FavCandidateDropdown"]
    if cand_ddl and cand_ddl.UpdateChoices then
        cand_ddl:UpdateChoices(PM.fav_all_names, PM.fav_all_ids)
        cand_ddl:UpdateValue()
    end
    
    local rem_ddl = _G["PM_FavRemoveDropdown"]
    if rem_ddl and rem_ddl.UpdateChoices then
        rem_ddl:UpdateChoices(PM.fav_current_names, PM.fav_current_ids)
        rem_ddl:UpdateValue()
    end
end

function PM.toggle_favorite(f_id)
    if not f_id or f_id == 0 then return end
    if not PM.settings.favorites then PM.settings.favorites = {} end
    if PM.settings.favorites[f_id] then
        PM.settings.favorites[f_id] = nil
        PM.log_msg("Removed from Favorites: " .. GetCollectibleName(f_id), true, "settings", 90)
    else
        PM.settings.favorites[f_id] = true
        PM.log_msg("Added to Favorites: " .. GetCollectibleName(f_id), true, "settings", 90)
    end
    PM.update_favorites_choices()
end

function PM.delete_all_favorites()
    if PM.settings then PM.settings.favorites = {} end
    PM.log_msg("All Favorites Cleared.", true, "settings", 90)
    PM.update_favorites_choices()
end

function PM.update_menu_choices()
    PM.active_names, PM.active_ids = {"None"}, {0}
    local arr_act = {}
    for f_id, md in pairs(PM.memento_data) do
        if IsCollectibleUnlocked(f_id) then
            table.insert(arr_act, {name=md.name, id=f_id, dur=md.dur, stat=md.stationary})
        end
    end
    table.sort(arr_act, function(a,b) return a.name < b.name end)
    for i, t in ipairs(arr_act) do
        local stat_str = t.stat and " (Stationary)" or ""
        local f_str = string.format("%s (%ds)%s", t.name, t.dur / 1000, stat_str)
        if PM.settings and PM.settings.active_id == t.id then
            f_str = "|c00FF00" .. f_str .. "|r"
        end
        table.insert(PM.active_names, f_str); table.insert(PM.active_ids, t.id)
    end
    local act_ddl = _G["PM_ActiveDropdown"]
    if act_ddl and act_ddl.UpdateChoices then
        act_ddl:UpdateChoices(PM.active_names, PM.active_ids)
    end

    PM.sync_names, PM.sync_ids = {"None"}, {0}
    local arr_sync = {}
    local max_cat = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO)
    for i = 1, max_cat do
        local f_id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
        if f_id and IsCollectibleUnlocked(f_id) then
            table.insert(arr_sync, {name=GetCollectibleName(f_id), id=f_id})
        end
    end
    table.sort(arr_sync, function(a,b) return a.name < b.name end)
    for i, t in ipairs(arr_sync) do 
        local f_str = t.name; local md = PM.get_data(t.id)
        if md then f_str = f_str .. string.format(" (%ds)", md.dur / 1000) end
        table.insert(PM.sync_names, f_str); table.insert(PM.sync_ids, t.id) 
    end
    local sync_ddl = _G["PM_SyncDropdown"]
    if sync_ddl and sync_ddl.UpdateChoices then
        sync_ddl:UpdateChoices(PM.sync_names, PM.sync_ids)
    end
    
    PM.learned_list_names, PM.learned_list_values = {"None"}, {0}
    if PM.acct_saved and PM.acct_saved.learned_data then
        local arr_lrn = {}
        for f_id, md in pairs(PM.acct_saved.learned_data) do table.insert(arr_lrn, md) end
        table.sort(arr_lrn, function(a,b) return a.name < b.name end)
        for i, md in ipairs(arr_lrn) do 
            local f_str = md.name .. string.format(" (%ds)", md.dur / 1000)
            table.insert(PM.learned_list_names, f_str); table.insert(PM.learned_list_values, md.id) 
        end
    end
    local lrn_ddl = _G["PM_LearnedDropdown"]
    if lrn_ddl and lrn_ddl.UpdateChoices then
        lrn_ddl:UpdateChoices(PM.learned_list_names, PM.learned_list_values)
    end
end

function PM.on_combat_event(eventCode, result, isError, abilityName, abilityGraphic,
                            actionSlotType, sourceName, sourceType, targetName, targetType,
                            hitValue, powerType, damageType, log, sourceUnitId, targetUnitId,
                            abilityId, overflow)
    if not PM.settings or not PM.settings.active_id then return end
    
    if result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_BEGIN_CHANNEL then
        PM.loop_token = (PM.loop_token or 0) + 1
        local tkn = PM.loop_token
        local w_ms = (PM.settings.delay_cast or 3) * 1000
        
        if GetAbilityCastInfo then
            local is_chan, c_time, chan_time = GetAbilityCastInfo(abilityId)
            if c_time and c_time > 0 then w_ms = c_time + 500 end
            if is_chan and chan_time and chan_time > 0 then w_ms = chan_time + 500 end
        end
        
        if GetGameTimeMilliseconds then
            PM.next_fire_time = GetGameTimeMilliseconds() + w_ms
        end
        zo_callLater(function() PM.run_loop(tkn) end, w_ms)
    end
end

function PM.on_collectible_use_result(eventCode, result, isAttemptingActivation)
    if not PM.settings or not PM.settings.active_id then return end
    
    if isAttemptingActivation and result ~= 0 then
        PM.loop_token = (PM.loop_token or 0) + 1
        local tkn = PM.loop_token
        local w_ms = 2000 
        
        if GetGameTimeMilliseconds then
            PM.next_fire_time = GetGameTimeMilliseconds() + w_ms
        end
        zo_callLater(function() PM.run_loop(tkn) end, w_ms)
    end
end

function PM.hook_game_ui()
    ZO_PreHook("UseCollectible", function(c_id)
        if not PM.settings then return end
        if PM.is_looping or PM.is_scanning then return end
        if GetCollectibleCategoryType(c_id) ~= COLLECTIBLE_CATEGORY_TYPE_MEMENTO then return end
        if PM.is_sync_firing then return end
        
        if (c_id == 336 or c_id == 341) and PM.settings.active_id ~= c_id then
            local is_col = SCENE_MANAGER and (
                SCENE_MANAGER:IsShowing("collectionsBook") or
                SCENE_MANAGER:IsShowing("gamepadCollectionsBook")
            )
            local is_qs = SCENE_MANAGER and SCENE_MANAGER:IsShowing("quickslot")
            if not is_col and not is_qs then return end
        end
        
        local md = PM.get_data(c_id)
        local is_col = SCENE_MANAGER and (
            SCENE_MANAGER:IsShowing("collectionsBook") or
            SCENE_MANAGER:IsShowing("gamepadCollectionsBook")
        )
        
        if not md and PM.settings.is_unrestricted and is_col and PM.settings.enable_learning then
             local c_name = GetCollectibleName(c_id)
             if not PM.acct_saved.learned_data then PM.acct_saved.learned_data = {} end
             
             local r_id = 0
             local c_data = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(c_id)
             if c_data and c_data.GetReferenceId then r_id = c_data:GetReferenceId() end
             
             zo_callLater(function()
                 local c_rem = 0; local c_dur = 10000
                 if GetCollectibleCooldownAndDuration then
                     c_rem, c_dur = GetCollectibleCooldownAndDuration(c_id)
                 end
                 local s_dur = (c_dur > 0) and c_dur or 10000 
                 PM.acct_saved.learned_data[c_id] = {
                     id = c_id, ref_id = r_id, dur = s_dur, name = c_name
                 }
                 PM.update_learned_count()
                 local out_msg = string.format(
                     "Saved: %s\nID: %d | RefID: %d | Dur: %dms | Total Learned: %d",
                     c_name, c_id, r_id, s_dur, PM.learned_count
                 )
                 PM.log_msg(out_msg, true, "settings", 70); PM.is_menu_built = false 
             end, 500)
        end

        if PM.settings.active_id == c_id then
             PM.settings.active_id = nil; PM.settings.is_paused = false
             PM.loop_token = (PM.loop_token or 0) + 1
             PM.log_msg("Auto-loop Stopped", true, "stop", 90)
             PM.pending_id = 0; PM.next_fire_time = 0; return
        end
        
        if md then
            if not PM.memento_data[c_id] and not PM.settings.is_unrestricted then
                 PM.log_msg(
                     "Activating " .. md.name .. " (Looping Disabled - Unrestricted Required)",
                     true, "activation", 70
                 ); return
            end
            local is_sw = (PM.settings.active_id ~= nil)
            PM.settings.active_id = c_id; PM.settings.is_paused = false
            PM.loop_token = (PM.loop_token or 0) + 1; PM.pending_id = c_id 
            
            if is_sw then
                PM.log_msg("Memento switched to: " .. md.name, true, "activation", 90)
            else
                PM.log_msg("Auto-loop started: " .. md.name, true, "activation", 90)
            end
            
            local tkn = PM.loop_token
            zo_callLater(function() PM.run_loop(tkn) end, 100)
        else
            if PM.settings.active_id then
                PM.settings.active_id = nil; PM.loop_token = (PM.loop_token or 0) + 1
                PM.pending_id = 0; PM.next_fire_time = 0
                PM.log_msg("Auto-loop Stopped", true, "stop", 90)
            end
        end
    end)
end

function PM.sync_engine.initialize()
  SLASH_COMMANDS["/pmsync"] = function(arg_str)
    if not PM.settings.sync_module.is_enabled then
        PM.log_msg("Group Sync is currently DISABLED.", true, "error"); return
    end
    if not arg_str or string.len(arg_str) < 1 then
        PM.log_msg("Usage: /pmsync <searchterm>, /pmsync random OR /pmsync stop", true, "error", 70)
        return
    end
    local c_arg = string.lower(arg_str)
    
    if c_arg == "stop" then
         if StartChatInput then
             StartChatInput("PM STOP", CHAT_CHANNEL_PARTY)
         elseif CHAT_SYSTEM then
             CHAT_SYSTEM:StartTextEntry("PM STOP")
         end
         if PM.settings then
             PM.settings.active_id = nil; PM.loop_token = (PM.loop_token or 0) + 1
         end
         PM.next_fire_time = 0; return
    elseif c_arg == "random" then 
         local r_id = PM.get_random_any()
         if r_id then
            local l_str = GetCollectibleLink(r_id, LINK_STYLE_BRACKETS)
            if StartChatInput then
                StartChatInput(string.format("PM %s", l_str), CHAT_CHANNEL_PARTY)
            elseif CHAT_SYSTEM then
                CHAT_SYSTEM:StartTextEntry(string.format("PM %s", l_str))
            end
            PM.log_msg("Sent Random Sync Request", true, "sync", 90); return
         end
    end
    
    local max_cat = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO)
    for i = 1, max_cat do
      local f_id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
      if f_id and IsCollectibleUnlocked(f_id) then
          if string.find(string.lower(GetCollectibleName(f_id)), c_arg, 1, true) then
            local l_str = GetCollectibleLink(f_id, LINK_STYLE_BRACKETS)
            if StartChatInput then
                StartChatInput(string.format("PM %s", l_str), CHAT_CHANNEL_PARTY)
            elseif CHAT_SYSTEM then
                CHAT_SYSTEM:StartTextEntry(string.format("PM %s", l_str))
            end
            return
          end
      end
    end
    PM.log_msg("Memento not found or not unlocked.", true, "error", 90)
  end
  SLASH_COMMANDS["/permmementosync"] = SLASH_COMMANDS["/pmsync"]

  local function attempt_col(c_id)
    if not IsCollectibleUsable(c_id) then return end
    if not PM.settings or not PM.settings.sync_module.is_enabled then return end 
    if IsUnitInCombat and IsUnitInCombat("player") and PM.settings.sync_module.ignore_in_combat then
        return
    end
    
    if PM.settings.active_id then
         PM.log_msg("Sync received! Queuing...", true, "sync", 70); PM.pending_sync_id = c_id
    else
         local c_rem = 0
         if GetCollectibleCooldownAndDuration then
             c_rem, _ = GetCollectibleCooldownAndDuration(c_id)
         end
         if c_rem and c_rem > 0 then
             PM.log_msg("Sync received but on cooldown...", true, "sync", 70)
             zo_callLater(function() attempt_col(c_id) end, c_rem + 1000)
         else
             PM.log_msg("Sync received! Playing...", true, "sync", 80)
             PM.is_sync_firing = true; UseCollectible(c_id)
             zo_callLater(function() PM.is_sync_firing = false end, 1000)
         end
    end
  end

  PM.on_sync_chat_message = function(eventCode, channelType, fromName, text)
    if channelType ~= CHAT_CHANNEL_PARTY then return end
    local cl_name = zo_strformat("<<1>>", fromName)
    if string.match(text, "^PM STOP") then
        if cl_name == GetUnitDisplayName("player") then
            PM.log_msg("Sent Group Stop Command.", true, "sync", 90); return
        end
        if PM.settings then
            PM.settings.active_id = nil; PM.loop_token = (PM.loop_token or 0) + 1
            PM.pending_sync_id = nil; PM.next_fire_time = 0
            PM.log_msg("Group Stop received from " .. cl_name, true, "stop", 90)
        end
        return
    end
    
    local f_id
    for v_id in string.gmatch(text, "^PM |H1:collectible:(%d+)|h|h$") do f_id = tonumber(v_id) end
    if not f_id then
        for v_id in string.gmatch(text, "^PM (%d+)$") do f_id = tonumber(v_id) end
    end
    if not f_id or not IsCollectibleUnlocked(f_id) then return end
    if cl_name == GetUnitDisplayName("player") then
        PM.log_msg("Sent Group Sync Command.", true, "sync", 90); return
    end
    if not PM.settings then return end 
    
    local s_delay = PM.settings.sync_module.delay or 0
    if PM.settings.sync_module.is_random then s_delay = math.random(0, s_delay) end
    if s_delay == 0 then
        attempt_col(f_id)
    else
        zo_callLater(function() attempt_col(f_id) end, s_delay * 1000)
    end
  end
  PM.toggle_sync_listener()
end

function PM.build_menu()
    if PM.is_menu_built then return end
    
    local lam_ver, lam_en, lca_ver, lca_en = PM.get_settings_library()
    if not lam_en or lam_ver < 30 then return end

    if lam_ver >= 30 and lam_ver < REQUIRED_LAM_VERSION then
        zo_callLater(function()
            local warn_msg = string.format(
                "|cFFFF00Warning: LibAddonMenu is outdated (v%d). Update to v%d+ for PM.|r", 
                lam_ver, REQUIRED_LAM_VERSION
            )
            if CHAT_SYSTEM then CHAT_SYSTEM:AddMessage("|cFF9900[PM]|r " .. warn_msg) end
            if CENTER_SCREEN_ANNOUNCE then
                local p = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(
                    CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE
                )
                p:SetText(warn_msg); p:SetLifespanMS(4000)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(p)
            end
        end, 4000)
    end

    PM.is_menu_built = true
    PM.update_menu_choices(); PM.update_favorites_choices()
    
    if not PM.acct_saved.profiles then PM.acct_saved.profiles = {} end
    
    if not PM.acct_saved.is_profiles_migrated then
        local usr = GetDisplayName(); local srv = GetWorldName() or "Default"
        local raw_sv = _G["PermMementoSaved"]
        if raw_sv and raw_sv[srv] and raw_sv[srv][usr] then
            for r_id, r_data in pairs(raw_sv[srv][usr]) do
                if r_id ~= "$AccountWide" and type(r_data) == "table" and r_data["Character"] then
                    local char_nm = r_data["$LastCharacterName"]
                    if not char_nm or char_nm == "" then
                        char_nm = zo_strformat("<<1>>", GetCharacterNameById(r_id))
                    end
                    if char_nm and char_nm ~= "" and not PM.acct_saved.profiles[char_nm] then
                        PM.acct_saved.profiles[char_nm] = ZO_DeepTableCopy(r_data["Character"])
                    end
                end
            end
        end
        PM.acct_saved.is_profiles_migrated = true
        PM.log_msg("Old character settings successfully migrated to Profiles.", true, "settings")
    end

    PM.update_profile_list()

    local is_eu = (GetWorldName() == "EU Megaserver")
    local is_pad = IsConsoleUI() or IsInGamepadPreferredMode()
    local lib_lam = LibAddonMenu2 or _G["LibAddonMenu2"]
    if not lib_lam then return end

    local hdr_data = {
        type = "panel", name = "Permanent Memento",
        displayName = "|c9CD04CPermanent Memento|r",
        author = "|ca500f3A|r|cb400e6P|r|cc300daH|r|cd200cdO|r|ce100c1NlC|r",
        version = PM.version, registerForRefresh = true
    }
    local b_data = {}

    if is_pad then
        table.insert(b_data, {
            type = "button", name = "|c00FF00PERMANENT MEMENTO STATS|r", width = "full",
            tooltip = function() return PM.get_stats_text() end, func = function() end
        })
        table.insert(b_data, {
            type = "button", name = "|c00FF00COMMANDS INFO|r", width = "full",
            tooltip = "Review chat commands in normal mode.", func = function() end
        })
    end

    if not is_pad and not is_eu then
        table.insert(b_data, {
            type = "button", width = "half",
            name = "|cFFD700DONATE|r to @|ca500f3A|r|cb400e6P|r|cc300daH|r|cd200cdO|r|ce100c1NlC|r",
            tooltip = "Opens the in-game mail. Thank you! for your donation!",
            func = function()
                SCENE_MANAGER:Show("mailSend")
                zo_callLater(function()
                    ZO_MailSendToField:SetText("@APHONlC")
                    ZO_MailSendSubjectField:SetText("PermMemento Support")
                    ZO_MailSendBodyField:TakeFocus()
                end, 200)
            end
        })
    end

    table.insert(b_data, {
        type = "button", name = "|c00FFFFMigrate SavedVariables|r", width = is_pad and "full" or "half",
        tooltip = "Manually triggers the data migration process.",
        func = function()
            PM.migrate_data(); PM.log_msg("Data migration complete...", true, "settings", 80)
            zo_callLater(function() ReloadUI("ingame") end, 2000)
        end
    })

    local grp_gen = {
        {
            type = "checkbox", name = "Use Account-Wide Settings",
            tooltip = "If ON, settings are shared across all characters.",
            getFunc = function() return PM.char_saved.use_account_settings end,
            setFunc = function(v)
                PM.char_saved.use_account_settings = v
                PM.update_settings_reference(); ReloadUI("ingame")
            end
        },
        {
            type = "dropdown", name = "Select Active Memento", reference = "PM_ActiveDropdown",
            tooltip = "Select a memento. Click 'Apply' to start.",
            choices = PM.active_names, choicesValues = PM.active_ids,
            getFunc = function()
                if PM.pending_id == nil then return PM.settings.active_id or 0 end
                return PM.pending_id
            end,
            setFunc = function(v) PM.pending_id = v end,
            disabled = function() return PM.settings.is_random_on_zone end
        },
        {
            type = "button", name = "|cFFFF00Activate Random Memento|r", width = "half",
            tooltip = "Immediately picks and starts a random supported memento.",
            func = function()
                local r_id = PM.get_random_supported()
                if r_id then
                    PM.settings.active_id = r_id
                    PM.log_msg("Randomly Selected: " .. PM.get_data(r_id).name, true, "random", 90)
                    PM.start_loop(r_id)
                end
            end
        },
        {
            type = "button", name = "|c00FF00Apply Selected Memento|r", width = "half",
            tooltip = "|c00FF00Starts the memento selected above.|r",
            func = function()
                if PM.pending_id and PM.pending_id ~= 0 then
                    PM.settings.active_id = PM.pending_id
                    local md = PM.get_data(PM.pending_id)
                    PM.log_msg("Selected via Menu: " .. (md.name or "Unknown"), true, "activation")
                    PM.start_loop(PM.pending_id); PM.pending_id = nil
                elseif PM.pending_id == 0 then
                    PM.settings.active_id = nil; PM.loop_token = (PM.loop_token or 0) + 1
                    PM.log_msg("Auto-loop Stopped", true, "stop", 90)
                    PM.pending_id = nil; PM.next_fire_time = 0
                end
            end
        },
        {
            type = "button", name = "|cFF0000STOP LOOP|r", width = "full",
            tooltip = "Stops the currently running memento loop.",
            func = function()
                PM.settings.active_id = nil; PM.loop_token = (PM.loop_token or 0) + 1
                PM.pending_id = 0; PM.settings.is_random_on_zone = false
                PM.settings.is_random_on_login = false; PM.next_fire_time = 0
                PM.log_msg("Auto-loop Stopped", true, "stop", 90)
            end
        },
        {
            type = "checkbox", name = "Randomize on Zone Change",
            tooltip = "Picks and plays a random memento whenever you change zones.",
            getFunc = function() return PM.settings.is_random_on_zone end,
            setFunc = function(v) PM.settings.is_random_on_zone = v end
        },
        {
            type = "checkbox", name = "Randomize on Login",
            tooltip = "Picks and plays a random memento when you login.",
            getFunc = function() return PM.settings.is_random_on_login end,
            setFunc = function(v) PM.settings.is_random_on_login = v end
        },
        {
            type = "checkbox", name = "Loop in Combat",
            tooltip = "Allows the memento to attempt firing during combat.",
            getFunc = function() return PM.settings.is_loop_in_combat end,
            setFunc = function(v) PM.settings.is_loop_in_combat = v end
        },
        {
            type = "checkbox", name = "Screen Announcements",
            tooltip = "Shows large text alerts on screen.",
            getFunc = function() return PM.settings.is_csa_enabled end,
            setFunc = function(v) PM.settings.is_csa_enabled = v end
        },
        {
            type = "checkbox", name = "Show Auto Cleanup Announcements",
            tooltip = "Shows large text alerts on screen when Lua Memory is automatically cleaned.",
            getFunc = function() return PM.settings.is_csa_cleanup_enabled end,
            setFunc = function(v) PM.settings.is_csa_cleanup_enabled = v end,
            disabled = function() return is_alc_enabled() end
        },
        {
            type = "checkbox", name = "Performance Mode",
            tooltip = "Reduces UI update frequency by 75% to save resources.",
            getFunc = function() return PM.settings.is_performance_mode end,
            setFunc = function(v) PM.settings.is_performance_mode = v end
        },
        {
            type = "checkbox", name = "Auto Lua Cleanup",
            tooltip = function()
                if is_alc_enabled() then return "|cFF0000DISABLED: Standalone ALC Detected.|r" end
                return "Background memory cleaner. Automatically runs when memory hits 400MB " ..
                       "(PC) or 85MB (Console) to prevent stuttering. Triggers outside combat."
            end,
            getFunc = function() return PM.settings.is_auto_cleanup end,
            setFunc = function(v)
                PM.settings.is_auto_cleanup = v; PM.toggle_cleanup_events()
            end,
            disabled = function() return is_alc_enabled() end
        }
    }

if is_pad then
        table.insert(b_data, {
            type = "submenu", name = "|c00FF00General Settings|r",
            tooltip = "Core configuration and active memento selection.",
            controls = grp_gen
        })
    else
        table.insert(b_data, { type = "header", name = "|c00FF00General Settings|r" })
        for _, ctrl in ipairs(grp_gen) do table.insert(b_data, ctrl) end
        table.insert(b_data, {
            type = "checkbox", name = "Enable Chat Logs",
            tooltip = "Shows status messages in your chat window.",
            getFunc = function() return PM.settings.is_log_enabled end,
            setFunc = function(v) PM.settings.is_log_enabled = v end
        })
        table.insert(b_data, {
            type = "checkbox", name = "Stop Character Spinning in Menus",
            tooltip = "Prevents camera from shifting in Stats/Inventory.",
            getFunc = function() return PM.settings.is_stop_spinning end,
            setFunc = function(v)
                PM.settings.is_stop_spinning = v; PM.apply_spin_stop()
            end
        })
    end

    local grp_pwr = {
        {
            type = "checkbox", name = "Enable Stats Tracker",
            tooltip = "ON: Tracks memory statistics.\nOFF: Stops Tracking memory statistics.",
            getFunc = function() return PM.settings.enable_stats_ui end,
            setFunc = function(v)
                PM.settings.enable_stats_ui = v; PM.toggle_stats_ui_tracker()
                PM.toggle_cleanup_events()
                PM.log_msg("Stats Tracker: " .. (v and "ON" or "OFF"), true, "settings")
            end
        },
        {
            type = "checkbox", name = "Enable Randomization & Favorites",
            tooltip = "ON: Enables Randomization features and Favorites selection.\n" ..
                      "OFF: Disables Randomization features and Favorites selection.",
            getFunc = function() return PM.settings.enable_random_fav end,
            setFunc = function(v)
                PM.settings.enable_random_fav = v
                PM.log_msg("Random & Favorites: " .. (v and "ON" or "OFF"), true, "settings")
            end
        },
        {
            type = "checkbox", name = "Enable Learning Mode",
            tooltip = "ON: Enables Auto-Scan and learning of unknown mementos.\n" ..
                      "OFF: Disables Auto-Scan and learning of unknown mementos.",
            getFunc = function() return PM.settings.enable_learning end,
            setFunc = function(v)
                PM.settings.enable_learning = v
                PM.log_msg("Learning Mode: " .. (v and "ON" or "OFF"), true, "settings")
            end
        }
    }
    
    if not is_pad then
        table.insert(grp_pwr, {
            type = "checkbox", name = "Enable Party Sync Listener",
            tooltip = "ON: Listens to chat for party sync requests.\nOFF: Disables party sync requests.",
            getFunc = function() return PM.settings.sync_module.is_enabled end,
            setFunc = function(v)
                PM.settings.sync_module.is_enabled = v; PM.toggle_sync_listener()
                PM.log_msg("Sync Listening: " .. (v and "ON" or "OFF"), true, "settings")
            end
        })
    end
    table.insert(b_data, {
        type = "submenu", name = "|cFFA500Module Manager|r",
        tooltip = "Turn off unused modules entirely.", controls = grp_pwr
    })

    local grp_ui = {
        {
            type = "checkbox", name = "UI Visibility",
            tooltip = "Shows or hides the status text completely.",
            getFunc = function() return not PM.settings.ui.is_hidden end,
            setFunc = function(v)
                PM.settings.ui.is_hidden = not v; PM.toggle_ui_update()
                PM.log_msg("UI Visibility...", true, "ui", 90)
            end
        },
        {
            type = "checkbox", name = "UI Mode",
            tooltip = "ON: Shows during normal gameplay (HUD).\nOFF: Shows ONLY in Collections.",
            getFunc = function() return PM.settings.show_in_hud end,
            setFunc = function(v)
                PM.settings.show_in_hud = v
                PM.update_ui_scenes()
                PM.log_msg("UI Mode: " .. (v and "HUD Only" or "Menu Only"), true, "ui")
            end,
            disabled = function() return PM.settings.ui.is_hidden end
        },
        {
            type = "slider", name = "HUD UI Scale",
            tooltip = "Adjusts the size of the status text UI in HUD mode.",
            min = 0.5, max = 2.0, step = 0.1, decimals = 1,
            getFunc = function() return PM.settings.ui.scale or (is_pad and 1.0 or 1.0) end,
            setFunc = function(v) PM.settings.ui.scale = v; PM.update_ui_anchor() end
        },
        {
            type = "slider", name = "Menu UI Scale",
            tooltip = "Adjusts the size of the status text UI in Menu mode.",
            min = 0.5, max = 2.0, step = 0.1, decimals = 1,
            getFunc = function() return PM.settings.ui_menu.scale or (is_pad and 1.2 or 1.0) end,
            setFunc = function(v) PM.settings.ui_menu.scale = v; PM.update_ui_anchor() end
        }
    }
    
    table.insert(b_data, {
        type = "submenu", name = "|c00FFFFUI Visibility Settings|r",
        tooltip = "Options for the on-screen status text.", controls = grp_ui
    })

    local function preview_window(win_ctrl)
        win_ctrl:SetHidden(false)
    end

    local ui_pos_controls = {}
    
    if not is_pad then
        table.insert(ui_pos_controls, {
            type = "button", name = "|cFFD700UNLOCK UI POSITIONING|r",
            tooltip = "Allows you to freely drag the UI around the screen.",
            func = function() PM.unlock_ui() end, width = "full"
        })
        table.insert(ui_pos_controls, {
            type = "button", name = "|cFF0000LOCK UI POSITIONING|r",
            tooltip = "Manually locks UI positioning and removes all highlights.",
            func = function() PM.lock_ui(true) end, width = "full",
            disabled = function() return not PM.is_ui_unlocked end
        })
    end

    table.insert(ui_pos_controls, {
        type = "checkbox", name = "Lock UI Position",
        tooltip = "Prevents the on-screen status text UI from being moved.",
        getFunc = function() return PM.settings.ui.is_locked end,
        setFunc = function(v)
            PM.settings.ui.is_locked = v
            if PM.ui_window then PM.ui_window:SetMovable(not v) end
        end
    })

    if is_pad and PM.is_lca_valid then
        table.insert(ui_pos_controls, { 
            type = "button", name = "Move UI (D-Pad)", width = "half",
            func = function() 
                preview_window(PM.ui_window)
                if PM.ui_mover then PM.ui_mover:ToggleGamepadMove(true) end
            end,
            disabled = function() return PM.ui_mover == nil or PM.settings.ui.is_locked end
        })
    end

    local reset_width = (is_pad and PM.is_lca_valid) and "half" or "full"
    table.insert(ui_pos_controls, { 
        type = "button", name = "|cFF0000RESET UI POSITION|r", width = reset_width,
        func = function() 
            PM.settings.ui.left = PM.defaults.ui.left
            PM.settings.ui.top = PM.defaults.ui.top
            PM.settings.ui_menu.left = PM.defaults.ui_menu.left
            PM.settings.ui_menu.top = PM.defaults.ui_menu.top
            PM.update_ui_anchor(); PM.log_msg("UI Position Reset.", true, "ui", 90)
            
            zo_callLater(function()
                if PM.is_ui_unlocked and PM.movers and PM.movers[1] and PM.ui_window then
                    PM.ui_window:SetHidden(false)
                    PM.movers[1]:ClearAnchors()
                    PM.movers[1]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PM.ui_window:GetLeft(), PM.ui_window:GetTop())
                end
            end, 50)
        end 
    })

    table.insert(b_data, {
        type = "submenu", name = "|c00FFFFConfigure UI Positions|r", controls = ui_pos_controls
    })

    if not is_pad then
        local grp_sync = {
            {
                type = "description",
                text = function()
                    if not PM.settings.sync_module.is_enabled then
                        return "|cFF0000Group Sync is DISABLED via Module Manager.|r"
                    end
                    return "Group synchronization options."
                end
            },
            {
                type = "dropdown", name = "Select Sync Request", reference = "PM_SyncDropdown",
                tooltip = "Broadcasts a memento to your group to sync up animations.",
                choices = PM.sync_names, choicesValues = PM.sync_ids,
                getFunc = function() return 0 end,
                setFunc = function(v)
                    if v and v ~= 0 then
                        local l_str = GetCollectibleLink(v, LINK_STYLE_BRACKETS)
                        if StartChatInput then
                            StartChatInput(string.format("PM %s", l_str), CHAT_CHANNEL_PARTY)
                        elseif CHAT_SYSTEM then
                            CHAT_SYSTEM:StartTextEntry(string.format("PM %s", l_str))
                        end
                    end
                end,
                disabled = function() return not PM.settings.sync_module.is_enabled end
            },
            {
                type = "button", name = "Send Random Sync",
                tooltip = "Picks a random unlocked memento and broadcasts it to group.",
                func = function()
                    local r_id = PM.get_random_any()
                    if r_id then
                        local l_str = GetCollectibleLink(r_id, LINK_STYLE_BRACKETS)
                        if StartChatInput then
                            StartChatInput(string.format("PM %s", l_str), CHAT_CHANNEL_PARTY)
                        elseif CHAT_SYSTEM then
                            CHAT_SYSTEM:StartTextEntry(string.format("PM %s", l_str))
                        end
                    end
                end,
                disabled = function() return not PM.settings.sync_module.is_enabled end
            },
            {
                type = "button", name = "Send Stop Command",
                tooltip = "Sends a STOP command to your group, halting their loops.",
                func = function()
                    if StartChatInput then
                        StartChatInput("PM STOP", CHAT_CHANNEL_PARTY)
                    elseif CHAT_SYSTEM then
                        CHAT_SYSTEM:StartTextEntry("PM STOP")
                    end
                end,
                disabled = function() return not PM.settings.sync_module.is_enabled end
            },
            {
                type = "checkbox", name = "Randomize Sync Delay",
                tooltip = "Adds random variation to the sync start time.",
                getFunc = function() return PM.settings.sync_module.is_random end,
                setFunc = function(v) PM.settings.sync_module.is_random = v end,
                disabled = function() return not PM.settings.sync_module.is_enabled end
            },
            {
                type = "slider", name = "Sync Delay (Seconds)",
                tooltip = "Fixed delay before starting a synced memento.",
                min = 0, max = 10, step = 1,
                getFunc = function() return PM.settings.sync_module.delay end,
                setFunc = function(v) PM.settings.sync_module.delay = v end,
                disabled = function()
                    return not PM.settings.sync_module.is_enabled or PM.settings.sync_module.is_random
                end
            }
        }
        table.insert(b_data, {
            type = "submenu", name = "|c800080Sync Settings|r",
            tooltip = "Group synchronization options.", controls = grp_sync
        })
    end

    local grp_fav = {
        {
            type = "description",
            text = function()
                if not PM.settings.enable_random_fav then
                    return "|cFF0000Favorites Manager is DISABLED via the Module Manager.|r"
                end
                return "If you have favorites in this list, 'Randomize' features will ONLY " ..
                       "pick from here. If empty, they pick from all."
            end
        },
        {
            type = "dropdown", name = "Select Memento to Favorite",
            tooltip = "Select any memento to Add or Remove from favorites.",
            reference = "PM_FavCandidateDropdown",
            choices = PM.fav_all_names, choicesValues = PM.fav_all_ids,
            getFunc = function() return PM.selected_fav_candidate or 0 end,
            setFunc = function(v) PM.selected_fav_candidate = v end,
            disabled = function() return not PM.settings.enable_random_fav end
        },
        {
            type = "button", name = "Apply to Favorites",
            tooltip = "Adds or Removes the selected memento above from your favorites.",
            func = function() PM.toggle_favorite(PM.selected_fav_candidate) end,
            disabled = function() return not PM.settings.enable_random_fav end
        },
        { type = "divider" },
        {
            type = "dropdown", name = "View Current Favorites",
            tooltip = "Select a favorite here to remove it.",
            reference = "PM_FavRemoveDropdown",
            choices = PM.fav_current_names, choicesValues = PM.fav_current_ids,
            getFunc = function() return PM.selected_fav_removal or 0 end,
            setFunc = function(v) PM.selected_fav_removal = v end,
            disabled = function() return not PM.settings.enable_random_fav end
        },
        {
            type = "button", name = "Remove Selected Favorite",
            tooltip = "Removes the memento selected in 'View Current Favorites'.",
            func = function() PM.toggle_favorite(PM.selected_fav_removal) end,
            disabled = function() return not PM.settings.enable_random_fav end
        },
        {
            type = "button", name = "|cFF0000Clear All Favorites|r",
            tooltip = "|cFF0000Removes all mementos from your favorites list.|r",
            func = function() PM.delete_all_favorites() end,
            disabled = function() return not PM.settings.enable_random_fav end
        }
    }
    table.insert(b_data, {
        type = "submenu", name = "|c9CD04CFavorites Manager|r",
        tooltip = "Manage your list of favorite mementos for randomization.", controls = grp_fav
    })

    local grp_prof = {
        {
            type = "description",
            text = function()
                if PM.char_saved.use_account_settings then
                    return "|cFF0000Profile Manager is DISABLED while 'Use Account-Wide Settings' is active.|r"
                end
                return "Create, load, or delete character-specific settings profiles."
            end
        },
        {
            type = "editbox", name = "New Profile Name",
            tooltip = "Enter a name for your new profile.",
            isMultiline = false,
            getFunc = function() return PM.profile_input_text or "" end,
            setFunc = function(v) PM.profile_input_text = v end,
            disabled = function() return PM.char_saved.use_account_settings end
        },
        {
            type = "button", name = "|c00FF00SAVE AS NEW PROFILE|r", width = "full",
            tooltip = "Deeply copies your current settings into the new profile.",
            func = function() PM.save_profile(PM.profile_input_text) end,
            disabled = function() return PM.char_saved.use_account_settings end
        },
        { type = "divider" },
        {
            type = "dropdown", name = "Select Profile", reference = "PM_ProfileDropdown",
            tooltip = "Select an existing profile to load or delete.",
            choices = PM.profile_list_names, choicesValues = PM.profile_list_values,
            getFunc = function() return PM.selected_profile_name or "" end,
            setFunc = function(v) PM.selected_profile_name = v end,
            disabled = function() return PM.char_saved.use_account_settings end
        },
        {
            type = "button", name = "|c00FFFFLOAD PROFILE|r", width = "half",
            tooltip = "Loads the selected profile and reloads the UI.",
            func = function() PM.load_profile(PM.selected_profile_name) end,
            disabled = function() return PM.char_saved.use_account_settings end
        },
        {
            type = "button", name = "|cFF0000DELETE PROFILE|r", width = "half",
            tooltip = "Deletes the selected profile permanently.",
            func = function() PM.delete_profile(PM.selected_profile_name) end,
            disabled = function() return PM.char_saved.use_account_settings end
        }
    }
    table.insert(b_data, {
        type = "submenu", name = "|cFFFF00Profile Manager|r",
        tooltip = "Manage and dynamically swap your settings profiles.", controls = grp_prof
    })

    local grp_lrn = {
        {
            type = "description",
            text = function()
                if not PM.settings.enable_learning then
                    return "|cFF0000Learned Data Management is DISABLED via Module Manager.|r"
                end
                return "Manage mementos scanned by the Auto-Scan feature."
            end
        },
        {
            type = "dropdown", name = "Learned Mementos", reference = "PM_LearnedDropdown",
            tooltip = "Select a learned memento to manage.",
            choices = PM.learned_list_names, choicesValues = PM.learned_list_values,
            getFunc = function() return PM.selected_learned_id or 0 end,
            setFunc = function(v) PM.selected_learned_id = v end,
            disabled = function() return not PM.settings.enable_learning end
        },
        {
            type = "button", name = "|c00FF00ACTIVATE SELECTION|r", width = "half",
            tooltip = "|c00FF00Activates the memento currently selected in the dropdown.|r",
            func = function()
                if PM.selected_learned_id and PM.selected_learned_id ~= 0 then
                    PM.settings.active_id = PM.selected_learned_id
                    local md = PM.get_data(PM.selected_learned_id)
                    PM.log_msg("Selected (Learned): " .. (md and md.name or "?"), true, "activation")
                    PM.start_loop(PM.selected_learned_id)
                end
            end,
            disabled = function() return not PM.settings.enable_learning end
        },
        {
            type = "button", name = "|cFFFF00LEARN: Auto-Scan|r", width = "half",
            tooltip = "|cFFFF00Scans all owned mementos, activates them to learn their IDs.|r",
            func = function() PM.auto_scan_mementos() end,
            disabled = function() return not PM.settings.enable_learning end
        },
        {
            type = "button", name = "Delete Selected Memento", width = "half",
            tooltip = "Removes the selected memento from Learned Data.",
            func = function() PM.delete_learned_data(PM.selected_learned_id) end,
            disabled = function() return not PM.settings.enable_learning end
        },
        {
            type = "button", name = "RANDOMIZED LEARNED", width = "half",
            tooltip = "Picks a random memento from your Learned Data list.",
            func = function()
                local r_id = PM.get_random_learned()
                if r_id then
                    PM.settings.active_id = r_id
                    PM.log_msg("Randomly Selected: " .. PM.get_data(r_id).name, true, "random", 90)
                    PM.start_loop(r_id)
                else
                    PM.log_msg("No learned data found.", true, "error")
                end
            end,
            disabled = function() return not PM.settings.enable_learning end
        },
        {
            type = "button", name = "|cFF0000DELETE ALL LEARNED|r", width = "full",
            tooltip = "|cFF0000WARNING: Deletes ALL manual and auto-scanned learned data.|r",
            func = function() PM.delete_all_learned_data() end,
            disabled = function() return not PM.settings.enable_learning end
        }
    }
    table.insert(b_data, {
        type = "submenu", name = "|cFFFF00Learned Data Management|r",
        tooltip = "Manage mementos scanned by the Auto-Scan feature.", controls = grp_lrn
    })

    local grp_dur = {
        {
            type = "slider", name = "Activate Messages Duration",
            tooltip = "Duration for 'Started' messages.", min=1, max=10, step=1,
            getFunc=function() return PM.settings.csa_durations.activation end,
            setFunc=function(v) PM.settings.csa_durations.activation = v end
        },
        {
            type = "slider", name = "Stop Messages Duration",
            tooltip = "Duration for 'Stopped' messages.", min=1, max=10, step=1,
            getFunc=function() return PM.settings.csa_durations.stop end,
            setFunc=function(v) PM.settings.csa_durations.stop = v end
        },
        {
            type = "slider", name = "UI Toggle Messages Duration",
            tooltip = "Duration for UI Hidden/Visible messages.", min=1, max=10, step=1,
            getFunc=function() return PM.settings.csa_durations.ui end,
            setFunc=function(v) PM.settings.csa_durations.ui = v end
        },
        {
            type = "slider", name = "Random/Zoning Messages Duration",
            tooltip = "Duration for Randomizer messages.", min=1, max=10, step=1,
            getFunc=function() return PM.settings.csa_durations.random end,
            setFunc=function(v) PM.settings.csa_durations.random = v end
        },
        {
            type = "slider", name = "Settings Messages Duration",
            tooltip = "Duration for Settings change messages.", min=1, max=10, step=1,
            getFunc=function() return PM.settings.csa_durations.settings end,
            setFunc=function(v) PM.settings.csa_durations.settings = v end
        },
        {
            type = "slider", name = "Cleanup Messages Duration",
            tooltip = "Duration for Auto Cleanup messages.", min=1, max=10, step=1,
            getFunc=function() return PM.settings.csa_durations.cleanup end,
            setFunc=function(v) PM.settings.csa_durations.cleanup = v end
        }
    }
    
    if not is_pad then
        table.insert(grp_dur, 3, {
            type = "slider", name = "Sync Messages Duration",
            tooltip = "Duration for Sync related messages.", min=1, max=10, step=1,
            getFunc=function() return PM.settings.csa_durations.sync end,
            setFunc=function(v) PM.settings.csa_durations.sync = v end
        })
    end
    table.insert(b_data, {
        type = "submenu", name = "|cAAAAAAAnnouncement Durations (Seconds)|r",
        tooltip = "Configure how long text stays on screen.", controls = grp_dur
    })

    local grp_delay = {
        {
            type = "slider", name = "Delay After Going Idle", min = 0, max = 10, step = 1,
            tooltip = "Base delay between loops when not busy.",
            getFunc = function() return PM.settings.delay_idle end,
            setFunc = function(v) PM.settings.delay_idle = v end
        },
        {
            type = "slider", name = "Menu/Interaction Delay", min = 0, max = 10, step = 1,
            tooltip = "Wait time when in menus or interacting.",
            getFunc = function() return PM.settings.delay_in_menu end,
            setFunc = function(v) PM.settings.delay_in_menu = v end
        },
        {
            type = "slider", name = "Delay After Casting Skill", min = 0, max = 10, step = 1,
            tooltip = "Time to wait after casting a skill before resuming loop.",
            getFunc = function() return PM.settings.delay_cast end,
            setFunc = function(v) PM.settings.delay_cast = v end
        },
        {
            type = "slider", name = "Delay After Exiting Combat", min = 0, max = 10, step = 1,
            tooltip = "Wait time after leaving combat before resuming loop.",
            getFunc = function() return PM.settings.delay_combat_end end,
            setFunc = function(v) PM.settings.delay_combat_end = v end
        },
        {
            type = "slider", name = "Delay After Resurrecting/Reviving", min = 0, max = 10, step = 1,
            tooltip = "Wait time when resurrecting a player.",
            getFunc = function() return PM.settings.delay_resurrect end,
            setFunc = function(v) PM.settings.delay_resurrect = v end
        },
        {
            type = "slider", name = "Delay After Teleport/ReloadUI", min = 0, max = 20, step = 1,
            tooltip = "Wait time after zoning, reloading, or logging in.",
            getFunc = function() return PM.settings.delay_teleport end,
            setFunc = function(v) PM.settings.delay_teleport = v end
        },
        {
            type = "slider", name = "Delay After Moving", min = 0, max = 10, step = 1,
            tooltip = "Wait time when moving.",
            getFunc = function() return PM.settings.delay_move end,
            setFunc = function(v) PM.settings.delay_move = v end
        },
        {
            type = "slider", name = "Delay After Sprinting", min = 0, max = 10, step = 1,
            tooltip = "Wait time when sprinting.",
            getFunc = function() return PM.settings.delay_sprint end,
            setFunc = function(v) PM.settings.delay_sprint = v end
        },
        {
            type = "slider", name = "Delay After Blocking", min = 0, max = 10, step = 1,
            tooltip = "Wait time when blocking.",
            getFunc = function() return PM.settings.delay_block end,
            setFunc = function(v) PM.settings.delay_block = v end
        },
        {
            type = "slider", name = "Delay After Exiting Swimming", min = 0, max = 10, step = 1,
            tooltip = "Wait time when swimming.",
            getFunc = function() return PM.settings.delay_swim end,
            setFunc = function(v) PM.settings.delay_swim = v end
        },
        {
            type = "slider", name = "Delay After Sneaking", min = 0, max = 10, step = 1,
            tooltip = "Wait time when sneaking.",
            getFunc = function() return PM.settings.delay_sneak end,
            setFunc = function(v) PM.settings.delay_sneak = v end
        },
        {
            type = "slider", name = "Delay After Un-Mounting", min = 0, max = 10, step = 1,
            tooltip = "Wait time when mounted.",
            getFunc = function() return PM.settings.delay_mount end,
            setFunc = function(v) PM.settings.delay_mount = v end
        }
    }
    table.insert(b_data, {
        type = "submenu", name = "|cAAAAAAMemento Delays (Seconds)|r",
        tooltip = "Fine-tune how long the addon waits after specific actions.", controls = grp_delay
    })

    local grp_cmd = {}
    if not is_pad then
        table.insert(grp_cmd, {
            type = "button", name = "|cFF0000FORCE CONSOLE MODE|r",
            tooltip = "|cFF0000WARNING: SIMULATES CONSOLE FLOW ON PC. REQUIRES RELOAD.\n" ..
                      "IF STUCK, USE COMMAND:\n/script SetCVar(\"ForceConsoleFlow.2\", \"0\")\n" ..
                      "THEN TYPE /reloadui|r",
            func = function()
                local cur_cvar = GetCVar("ForceConsoleFlow.2")
                local n_val = (cur_cvar == "1") and "0" or "1"
                SetCVar("ForceConsoleFlow.2", n_val); ReloadUI("ingame")
            end
        })
    end
    
    table.insert(grp_cmd, {
        type = "button", name = "|cFF0000UNRESTRICTED MODE|r",
        tooltip = "|cFF0000WARNING: ALLOWS LOOPING ANY MEMENTO. MAY CAUSE ISSUES.|r",
        func = function()
            PM.settings.is_unrestricted = not PM.settings.is_unrestricted
            local s_txt = (PM.settings.is_unrestricted and "ON" or "OFF")
            PM.log_msg("Unrestricted Mode: " .. s_txt, true, "settings")
        end
    })
    table.insert(grp_cmd, {
        type = "button", name = "|c00FFFFCLEAN LUA MEMORY|r",
        tooltip = "Manually triggers Lua garbage collection to free unused memory.",
        func = function() PM.run_manual_cleanup(false) end
    })
    table.insert(grp_cmd, {
        type = "button", name = "Reload UI",
        tooltip = "Reloads the User Interface.", func = function() ReloadUI("ingame") end
    })
    
    table.insert(b_data, {
        type = "submenu", name = "|cFF0000Commands|r",
        tooltip = "Available chat commands and utility buttons.", controls = grp_cmd
    })

    if not is_pad then
        local live_stats = {
            type = "submenu", name = "Permanent Memento Stats",
            tooltip = "Live tracking of memory and usage data.",
            controls = {
                {
                    type = "description", title = "|c00FFFFLive Statistics|r",
                    text = "Statistics Tracking is Disabled...", reference = "PM_StatsText"
                }
            }
        }
        table.insert(b_data, live_stats)
        
        local cmd_txt = "" ..
            "|c00FFFF/pmem <name>|r |cFFD700- Force loop a specific memento|r\n" ..
            "|c00FFFF/pmemstop|r |cFFD700- Stops current loop & Auto-Scan|r\n" ..
            "|c00FFFF/pmemrand|r |cFFD700- Activate a random memento|r\n" ..
            "|c00FFFF/pmemrandzone|r |cFFD700- Toggle Zone Randomizer|r\n" ..
            "|c00FFFF/pmemrandlog|r |cFFD700- Toggle Login Randomizer|r\n" ..
            "|c00FFFF/pmemscan|r |cFFD700- Starts silent Auto-Scan|r\n" ..
            "|c00FFFF/pmemclean|r |cFFD700- Run manual Lua memory cleanup|r\n" ..
            "|c00FFFF/pmemcsacls|r |cFFD700- Toggle Auto-Cleanup Announcements|r\n" ..
            "|c00FFFF/pmemui|r |cFFD700- Toggle status display|r\n" ..
            "|c00FFFF/pmemhud|r |cFFD700- Toggle HUD/Menu mode|r\n" ..
            "|c00FFFF/pmemlock|r |cFFD700- Lock/unlock UI dragging|r\n" ..
            "|c00FFFF/pmemresetui|r |cFFD700- Reset UI scale/position|r\n" ..
            "|c00FFFF/pmemcsa|r |cFFD700- Toggle Screen Announcements|r\n" ..
            "|c00FFFF/pmemfree|r |cFFD700- Toggle Unrestricted Mode|r\n" ..
            "|c00FFFF/pmsync <name>|r |cFFD700- Send party sync request|r\n" ..
            "|c00FFFF/pmsyncrand|r |cFFD700- Send random party sync|r\n" ..
            "|c00FFFF/pmsyncstop|r |cFFD700- Send party stop request|r\n" ..
            "|c00FFFF/pmemcur|r |cFFD700- Print current looping memento|r\n" ..
            "|c00FFFF/pmemlist|r |cFFD700- List all learned data|r\n" ..
            "|c00FFFF/pmemplay <name>|r |cFFD700- Force loop a learned memento|r\n" ..
            "|c00FFFF/pmemwipe|r |cFFD700- Wipe all learned data permanently|r\n" ..
            "|c00FFFF/pmempause|r |cFFD700- Pause/Resume the current loop|r\n" ..
            "|c00FFFF/pmemcombat|r |cFFD700- Toggle Loop in Combat|r\n" ..
            "|c00FFFF/pmemperf|r |cFFD700- Toggle Performance Mode|r\n" ..
            "|c00FFFF/pmemautoclean|r |cFFD700- Toggle Auto Lua Cleanup|r\n" ..
            "|c00FFFF/pmemacct|r |cFFD700- Toggle Account-Wide Settings|r\n" ..
            "|c00FFFF/pmemwipefav|r |cFFD700- Clear all favorites|r\n" ..
            "|c00FFFF/pmemreset|r |cFFD700- Resets settings to default|r\n" ..
            "|c00FFFF/pmemhudscale <val>|r |cFFD700- Set HUD UI scale|r\n" ..
            "|c00FFFF/pmemmenuscale <val>|r |cFFD700- Set Menu UI scale|r\n" ..
            "|c00FFFF/pmemlogs|r |cFFD700- Toggle Chat Logs|r\n" ..
            "|c00FFFF/pmemnospin|r |cFFD700- Toggle Stop Spinning in Menus|r\n" ..
            "|c00FFFF/pmsyncon|r |cFFD700- Toggle Sync Listening|r\n" ..
            "|c00FFFF/pmsyncdelay|r |cFFD700- Toggle Random Sync Delay|r\n" ..
            "|c00FFFF/pmemstats|r |cFFD700- Toggle Stats Tracker|r\n" ..
            "|c00FFFF/pmemrandfav|r |cFFD700- Toggle Random/Favorites Module|r\n" ..
            "|c00FFFF/pmemlearn|r |cFFD700- Toggle Learning Mode Module|r"
            
        table.insert(b_data, {
            type = "description", title = "Commands Info", text = cmd_txt
        })
    end

    local function ResetToDefaults()
        local exclude = {
            learned_data = true, favorites = true, total_loops = true,
            memento_usage = true, install_date = true, version_history = true,
            last_version = true, is_migrated_086 = true,
            has_shown_lib_warning_086 = true, alc_disabled_pm = true
        }
        
        for k, v in pairs(PM.defaults) do
            if not exclude[k] then
                if type(v) == "table" then
                    PM.settings[k] = ZO_ShallowTableCopy(v)
                else
                    PM.settings[k] = v
                end
            end
        end
        
        PM:toggle_cleanup_events(); ReloadUI("ingame")
    end

    if is_pad then
        table.insert(b_data, { 
            type = "button", 
            name = "|cFF0000RESET TO DEFAULTS|r", 
            tooltip = "|cFF0000RESETS ALL SETTINGS TO DEFAULT VALUES.|r",
            func = ResetToDefaults, 
            width = "full" 
        })
        table.insert(b_data, {
            type = "button", name = "|cFFD700Buy Me A Coffee|r", width = "full",
            tooltip = "Thank you! Donations help support continued development!\n\n" ..
                      "Link: https://buymeacoffee.com/aph0nlc", func = function() end
        })
        table.insert(b_data, {
            type = "button", name = "|cFF0000BUG REPORT|r", width = "full",
            tooltip = "Found an issue? Report it here:\n\n" ..
                      "https://www.esoui.com/portal.php?id=360&a=listbugs", func = function() end
        })
    else
        table.insert(b_data, { 
            type = "button", 
            name = "|cFF0000RESET TO DEFAULTS|r", 
            tooltip = "|cFF0000RESETS ALL SETTINGS TO DEFAULT VALUES.|r",
            func = ResetToDefaults, 
            width = "full" 
        })
        table.insert(b_data, {
            type = "button", name = "|cFFD700Buy Me A Coffee|r", width = "full",
            tooltip = "Thank you! Donations help support continued development and maintenance! " ..
                      "Opens a secure link to my Buy Me A Coffee page in your default browser.",
            func = function() RequestOpenUnsafeURL("https://buymeacoffee.com/aph0nlc") end
        })
        table.insert(b_data, {
            type = "button", name = "|cFF0000BUG REPORT|r", width = "full",
            tooltip = "Found an issue? Opens the Bug Portal on ESOUI in your default browser.",
            func = function() RequestOpenUnsafeURL("https://www.esoui.com/portal.php?id=360&a=listbugs") end
        })
    end

    lib_lam:RegisterAddonPanel("PermMementoOptions", hdr_data)
    lib_lam:RegisterOptionControls("PermMementoOptions", b_data)

    PM.ctrl_active_dropdown = _G["PM_ActiveDropdown"]
    PM.ctrl_sync_dropdown = _G["PM_SyncDropdown"]
    PM.ctrl_learned_dropdown = _G["PM_LearnedDropdown"]
    PM.ctrl_fav_candidate_dropdown = _G["PM_FavCandidateDropdown"]
    PM.ctrl_fav_remove_dropdown = _G["PM_FavRemoveDropdown"]
end

function PM.init(eventCode, addOnName)
    if addOnName ~= PM.name then return end
    EVENT_MANAGER:UnregisterForEvent(PM.name, EVENT_ADD_ON_LOADED)
    
    local srv = GetWorldName() or "Default"
    local sv_name = "PermMementoSaved"
    local account = GetDisplayName()
    local charId = GetCurrentCharacterId()

    if _G[sv_name] and _G[sv_name][srv] and _G[sv_name][srv][account] then
        local root_acct = _G[sv_name][srv][account]["$AccountWide"]
        if root_acct then
            _G[sv_name]["Default"] = _G[sv_name]["Default"] or {}
            _G[sv_name]["Default"][account] = _G[sv_name]["Default"][account] or {}
            _G[sv_name]["Default"][account]["$AccountWide"] = _G[sv_name]["Default"][account]["$AccountWide"] or {}
            _G[sv_name]["Default"][account]["$AccountWide"][srv] = _G[sv_name]["Default"][account]["$AccountWide"][srv] or {}
            
            if root_acct["AccountWide"] then
                for k, v in pairs(root_acct["AccountWide"]) do
                    _G[sv_name]["Default"][account]["$AccountWide"][srv][k] = v
                end
            end
            
            for k, v in pairs(root_acct) do
                if k ~= "AccountWide" and type(k) == "string" and not string.match(k, "^%$") then
                    _G[sv_name]["Default"][account]["$AccountWide"][srv][k] = v
                end
            end
        end
        
        if charId and _G[sv_name][srv][account][charId] then
            local root_char = _G[sv_name][srv][account][charId]
            if root_char then
                _G[sv_name]["Default"] = _G[sv_name]["Default"] or {}
                _G[sv_name]["Default"][account] = _G[sv_name]["Default"][account] or {}
                _G[sv_name]["Default"][account][charId] = _G[sv_name]["Default"][account][charId] or {}
                _G[sv_name]["Default"][account][charId][srv] = _G[sv_name]["Default"][account][charId][srv] or {}
                
                if root_char["Character"] then
                    for k, v in pairs(root_char["Character"]) do
                        _G[sv_name]["Default"][account][charId][srv][k] = v
                    end
                end
                
                for k, v in pairs(root_char) do
                    if k ~= "Character" and type(k) == "string" and not string.match(k, "^%$") then
                        _G[sv_name]["Default"][account][charId][srv][k] = v
                    end
                end
            end
        end
        
        _G[sv_name][srv] = nil
    end

    PM.acct_saved = ZO_SavedVars:NewAccountWide(
        sv_name, 1, srv, PM.defaults
    )
    PM.char_saved = ZO_SavedVars:NewCharacterIdSettings(
        sv_name, 1, srv, PM.defaults
    )

    local pm_deprecated = {"recentScans", "target_wipe_string"}
    for _, key in ipairs(pm_deprecated) do
        PM.acct_saved[key] = nil
        PM.char_saved[key] = nil
    end

    if PM.char_saved.use_account_settings == nil then
        PM.char_saved.use_account_settings = PM.defaults.use_account_settings
    end

    local sv_tables = {PM.acct_saved, PM.char_saved}
    for _, sv in ipairs(sv_tables) do
        if sv.showInHUD ~= nil then
            sv.show_in_hud = sv.showInHUD
            sv.showInHUD = nil
        end
        if sv.ui and sv.ui.hidden ~= nil then
            sv.ui.is_hidden = sv.ui.hidden
            sv.ui.hidden = nil
        end
    end
    
    PM.settings = PM.char_saved.use_account_settings and PM.acct_saved or PM.char_saved
    
    EVENT_MANAGER:RegisterForEvent(PM.name .. "_UIRefresh", EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(PM.name .. "_UIRefresh", EVENT_PLAYER_ACTIVATED)
        
        if PM.settings.show_in_hud and PM.settings.ui then
            PM.settings.ui.is_hidden = false
        end

        zo_callLater(function()
            PM.toggle_ui_update()
        end, 1000)
    end)
    
    PM.update_settings_reference(); PM.migrate_data() 

    if not PM.loop_token then PM.loop_token = 0 end
    
    if not PM.acct_saved.install_date then
        local d = GetDate()
        if d and type(d) == "number" then d = tostring(d) end
        if d and string.len(d) == 8 then
            local yyyy = string.sub(d, 1, 4)
            local mm = string.sub(d, 5, 6)
            local dd = string.sub(d, 7, 8)
            PM.acct_saved.install_date = yyyy .. "/" .. mm .. "/" .. dd
        else
            PM.acct_saved.install_date = GetDateStringFromTimestamp(GetTimeStamp())
        end
    end
    
    if not PM.acct_saved.version_history then PM.acct_saved.version_history = {} end
    
    local no_hist = (#PM.acct_saved.version_history == 0)
    local diff_v = (PM.acct_saved.last_version and PM.acct_saved.last_version ~= PM.version)
    if no_hist and diff_v then
        table.insert(PM.acct_saved.version_history, PM.acct_saved.last_version)
    end
    
    local v_len = #PM.acct_saved.version_history
    if v_len == 0 or PM.acct_saved.version_history[v_len] ~= PM.version then
        table.insert(PM.acct_saved.version_history, PM.version)
        if #PM.acct_saved.version_history > 3 then
            table.remove(PM.acct_saved.version_history, 1)
        end
    end
    PM.acct_saved.last_version = PM.version
    
    local lam_ver, lam_en, lca_ver, lca_en = PM.get_settings_library()
    
    local is_lam_ok = (lam_en and lam_ver >= 30)
    PM.is_lca_valid = (LibCombatAlerts ~= nil and lca_en and lca_ver >= 7010)

    if not is_lam_ok or not PM.is_lca_valid then 
        PM.show_missing_library_warning() 
    end
    
    PM.create_ui(); PM.hook_game_ui(); PM.sync_engine.initialize()
    if not IsConsoleUI() then PM.toggle_stats_ui_tracker() end
    
    EVENT_MANAGER:RegisterForEvent(PM.name .. "_Combat", EVENT_COMBAT_EVENT, function(...)
        PM.on_combat_event(...)
    end)
    EVENT_MANAGER:AddFilterForEvent(
        PM.name .. "_Combat", EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER
    )
    
    EVENT_MANAGER:RegisterForEvent(PM.name .. "_Effect", EVENT_EFFECT_CHANGED, function(...)
        PM.on_effect_changed(...)
    end)
    EVENT_MANAGER:AddFilterForEvent(
        PM.name .. "_Effect", EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_UNIT_TAG, "player"
    )
    
    EVENT_MANAGER:RegisterForEvent(PM.name .. "_UseResult", EVENT_COLLECTIBLE_USE_RESULT,
        function(ev_code, res, is_act) PM.on_collectible_use_result(ev_code, res, is_act) end
    )

    PM.toggle_cleanup_events()
    EVENT_MANAGER:RegisterForEvent(PM.name, EVENT_PLAYER_ACTIVATED, function()
        PM.on_player_activated(); PM.build_menu(); PM.pending_id = PM.settings.active_id
    end)
    
    SLASH_COMMANDS["/pmem"] = function(raw_arg)
        if not PM.settings then return end
        local c_arg = raw_arg:lower()
        if c_arg == "" then
            local c1 = "" ..
                "|c00FF00[1/2] PermMemento Core Commands:|r\n" ..
                "|c00FFFF/pmem <name>|r (or |cFF0000/permmemento|r) |cFFD700- Force loop memento|r\n" ..
                "|c00FFFF/pmemstop|r (or |cFF0000/permmementostop|r) |cFFD700- Stops loop & Scan|r\n" ..
                "|c00FFFF/pmemrand|r (or |cFF0000/pmemrandom|r) |cFFD700- Activate random|r\n" ..
                "|c00FFFF/pmemrandzone|r (or |cFF0000/pmemrandomzonechange|r) |cFFD700- Zone Rand|r\n" ..
                "|c00FFFF/pmemrandlog|r (or |cFF0000/pmemrandomlogin|r) |cFFD700- Login Rand|r\n" ..
                "|c00FFFF/pmemscan|r (or |cFF0000/pmemautolearn|r) |cFFD700- Starts Auto-Scan|r\n" ..
                "|c00FFFF/pmemclean|r (or |cFF0000/pmemcleanup|r) |cFFD700- Manual Lua cleanup|r\n" ..
                "|c00FFFF/pmemcsacls|r (or |cFF0000/pmemcsacleanup|r) |cFFD700- Auto-Cleanup CSA|r\n" ..
                "|c00FFFF/pmemui|r (or |cFF0000/pmemtoggleui|r) |cFFD700- Toggle UI visibility|r\n" ..
                "|c00FFFF/pmemhud|r (or |cFF0000/pmemuimode|r) |cFFD700- Toggle HUD/Menu mode|r\n" ..
                "|c00FFFF/pmemlock|r (or |cFF0000/pmemuilock|r) |cFFD700- Lock/unlock UI|r\n" ..
                "|c00FFFF/pmemresetui|r (or |cFF0000/pmemuireset|r) |cFFD700- Reset UI pos|r\n" ..
                "|c00FFFF/pmemcsa|r (or |cFF0000/pmemtogglecsa|r) |cFFD700- Toggle Screen CSA|r\n" ..
                "|c00FFFF/pmemfree|r (or |cFF0000/pmemunrestrict|r) |cFFD700- Toggle Unrestricted|r\n" ..
                "|c00FFFF/pmsync <name>|r (or |cFF0000/permmementosync|r) |cFFD700- Party sync|r\n" ..
                "|c00FFFF/pmsyncrand|r (or |cFF0000/permmementosyncrandom|r) |cFFD700- Rand sync|r\n" ..
                "|c00FFFF/pmsyncstop|r (or |cFF0000/permmementosyncstop|r) |cFFD700- Party stop|r"

            local c2 = "" ..
                "|c00FF00[2/2] PermMemento Data & Settings Commands:|r\n" ..
                "|c00FFFF/pmemcur|r (or |cFF0000/pmemcurrent|r) |cFFD700- Print current loop|r\n" ..
                "|c00FFFF/pmemlist|r (or |cFF0000/pmemlearned|r) |cFFD700- List all learned|r\n" ..
                "|c00FFFF/pmemplay <name>|r (or |cFF0000/pmemactivatelearned|r) |cFFD700- Play|r\n" ..
                "|c00FFFF/pmemwipe|r (or |cFF0000/pmemdeletealllearned|r) |cFFD700- Wipe data|r\n" ..
                "|c00FFFF/pmempause|r (or |cFF0000/pmemtogglepause|r) |cFFD700- Pause loop|r\n" ..
                "|c00FFFF/pmemcombat|r (or |cFF0000/pmemloopincombat|r) |cFFD700- Loop in Combat|r\n" ..
                "|c00FFFF/pmemperf|r (or |cFF0000/pmemperformancemode|r) |cFFD700- Toggle Perf|r\n" ..
                "|c00FFFF/pmemautoclean|r (or |cFF0000/pmemautocleanup|r) |cFFD700- Auto Cleanup|r\n" ..
                "|c00FFFF/pmemacct|r (or |cFF0000/pmemuseaccountsettings|r) |cFFD700- Acct Wide|r\n" ..
                "|c00FFFF/pmemwipefav|r (or |cFF0000/pmemdeleteallfavorites|r) |cFFD700- Clear Fav|r\n" ..
                "|c00FFFF/pmemreset|r (or |cFF0000/pmemresetdefaults|r) |cFFD700- Reset default|r\n" ..
                "|c00FFFF/pmemhudscale <val>|r (or |cFF0000/pmemsethudscale|r) |cFFD700- Set HUD|r\n" ..
                "|c00FFFF/pmemmenuscale <val>|r (or |cFF0000/pmemsetmenuscale|r) |cFFD700- Set Menu|r\n" ..
                "|c00FFFF/pmemstats|r |cFFD700- Toggle Stats Tracker|r\n" ..
                "|c00FFFF/pmemrandfav|r |cFFD700- Toggle Random/Favorites Module|r\n" ..
                "|c00FFFF/pmemlearn|r |cFFD700- Toggle Learning Mode Module|r\n"
            
            if not IsConsoleUI() then
                c2 = c2 ..
                "|c00FFFF/pmemlogs|r (or |cFF0000/pmemchatlogs|r) |cFFD700- Toggle Chat Logs|r\n" ..
                "|c00FFFF/pmemnospin|r (or |cFF0000/pmemstopspinning|r) |cFFD700- Menu Spin|r\n" ..
                "|c00FFFF/pmsyncon|r (or |cFF0000/pmemsyncenable|r) |cFFD700- Sync Listening|r\n" ..
                "|c00FFFF/pmsyncdelay|r (or |cFF0000/pmemsyncrandomdelay|r) |cFFD700- Rand Delay|r"
            end
            
            local c_list = {"|c00FF00Supported Mementos:|r "}
            local arr_act = {}
            for f_id, md in pairs(PM.memento_data) do
                if IsCollectibleUnlocked(f_id) then table.insert(arr_act, md) end
            end
            table.sort(arr_act, function(a,b) return a.name < b.name end)
            
            for _, md in ipairs(arr_act) do
                table.insert(c_list, "- |cFFFFFF" .. md.name .. "|r |cFFD700(" .. (md.dur/1000) .. "s)|r ")
            end
            
            if CHAT_SYSTEM then
                CHAT_SYSTEM:AddMessage("|cFF9900[PM]|r\n" .. c1)
                CHAT_SYSTEM:AddMessage(" "); CHAT_SYSTEM:AddMessage(" ")
                CHAT_SYSTEM:AddMessage("|cFF9900[PM]|r\n" .. c2)
                CHAT_SYSTEM:AddMessage(" "); CHAT_SYSTEM:AddMessage(" ")
                CHAT_SYSTEM:AddMessage("|cFF9900[PM]|r\n" .. table.concat(c_list))
            end
            return
        end
        
        local is_found = false
        for f_id, md in pairs(PM.memento_data) do 
            if string.find(string.lower(md.name), c_arg, 1, true) then 
                if IsCollectibleUnlocked(f_id) then 
                    PM.log_msg("Auto-loop started: " .. md.name, true, "activation", 90)
                    PM.start_loop(f_id); is_found = true; break 
                else
                    PM.log_msg("Memento found but NOT unlocked: " .. md.name, true, "error", 80)
                    is_found = true; break
                end 
            end 
        end
        if not is_found then
            PM.log_msg("Memento not found or not supported.", true, "error", 90)
        end
    end
    SLASH_COMMANDS["/permmemento"] = SLASH_COMMANDS["/pmem"]

    SLASH_COMMANDS["/pmemstats"] = function()
        PM.settings.enable_stats_ui = not PM.settings.enable_stats_ui
        PM.toggle_stats_ui_tracker(); PM.toggle_cleanup_events()
        local t_txt = PM.settings.enable_stats_ui and "ON" or "OFF"
        PM.log_msg("Stats Tracker: " .. t_txt, true, "settings")
    end
    
    SLASH_COMMANDS["/pmemrandfav"] = function()
        PM.settings.enable_random_fav = not PM.settings.enable_random_fav
        local t_txt = PM.settings.enable_random_fav and "ON" or "OFF"
        PM.log_msg("Random & Favorites: " .. t_txt, true, "settings")
    end
    
    SLASH_COMMANDS["/pmemlearn"] = function()
        PM.settings.enable_learning = not PM.settings.enable_learning
        local t_txt = PM.settings.enable_learning and "ON" or "OFF"
        PM.log_msg("Learning Mode: " .. t_txt, true, "settings")
    end

    SLASH_COMMANDS["/pmemstop"] = function()
        PM.settings.active_id = nil; PM.loop_token = (PM.loop_token or 0) + 1
        PM.log_msg("Auto-loop Stopped", true, "stop", 90)
        PM.pending_id = 0; PM.next_fire_time = 0
    end
    SLASH_COMMANDS["/permmementostop"] = SLASH_COMMANDS["/pmemstop"]

    SLASH_COMMANDS["/pmemclean"] = function() PM.run_manual_cleanup(false) end
    SLASH_COMMANDS["/pmemcleanup"] = SLASH_COMMANDS["/pmemclean"]

    SLASH_COMMANDS["/pmemcsacls"] = function()
        PM.settings.is_csa_cleanup_enabled = not PM.settings.is_csa_cleanup_enabled
        local t_txt = PM.settings.is_csa_cleanup_enabled and "ON" or "OFF"
        PM.log_msg("Auto-Cleanup CSA: " .. t_txt, true, "settings") 
    end
    SLASH_COMMANDS["/pmemcsacleanup"] = SLASH_COMMANDS["/pmemcsacls"]

    SLASH_COMMANDS["/pmemui"] = function() 
        PM.settings.ui.is_hidden = not PM.settings.ui.is_hidden; PM.toggle_ui_update()
        local t_txt = PM.settings.ui.is_hidden and "HIDDEN" or "VISIBLE"
        PM.log_msg("UI Visibility: " .. t_txt, true, "ui") 
    end
    SLASH_COMMANDS["/pmemtoggleui"] = SLASH_COMMANDS["/pmemui"]

    SLASH_COMMANDS["/pmemhud"] = function() 
        PM.settings.show_in_hud = not PM.settings.show_in_hud; PM.update_ui_scenes()
        local t_txt = PM.settings.show_in_hud and "HUD" or "Menu"
        PM.log_msg("UI Mode: " .. t_txt, true, "settings") 
    end
    SLASH_COMMANDS["/pmemuimode"] = SLASH_COMMANDS["/pmemhud"]

    SLASH_COMMANDS["/pmemrandzone"] = function() 
        PM.settings.is_random_on_zone = not PM.settings.is_random_on_zone
        local t_txt = PM.settings.is_random_on_zone and "ON" or "OFF"
        PM.log_msg("Random on Zone: " .. t_txt, true, "settings") 
    end
    SLASH_COMMANDS["/pmemrandomzonechange"] = SLASH_COMMANDS["/pmemrandzone"]

    SLASH_COMMANDS["/pmemrandlog"] = function() 
        PM.settings.is_random_on_login = not PM.settings.is_random_on_login
        local t_txt = PM.settings.is_random_on_login and "ON" or "OFF"
        PM.log_msg("Random on Login: " .. t_txt, true, "settings") 
    end
    SLASH_COMMANDS["/pmemrandomlogin"] = SLASH_COMMANDS["/pmemrandlog"]

    SLASH_COMMANDS["/pmemrand"] = function() 
        local r_id = PM.get_random_supported()
        if r_id then
            PM.settings.active_id = r_id
            PM.log_msg("Randomly Selected: " .. PM.get_data(r_id).name, true, "random")
            PM.start_loop(r_id)
        end 
    end
    SLASH_COMMANDS["/pmemrandom"] = SLASH_COMMANDS["/pmemrand"]

    SLASH_COMMANDS["/pmemrandlrn"] = function() 
        local r_id = PM.get_random_learned()
        if r_id then
            PM.settings.active_id = r_id
            PM.log_msg("Randomly Selected (Learned): " .. PM.get_data(r_id).name, true, "random")
            PM.start_loop(r_id) 
        else PM.log_msg("No learned data found.", true, "error") end 
    end
    SLASH_COMMANDS["/pmemrandomlearned"] = SLASH_COMMANDS["/pmemrandlrn"]

    SLASH_COMMANDS["/pmemcsa"] = function() 
        PM.settings.is_csa_enabled = not PM.settings.is_csa_enabled
        local t_txt = PM.settings.is_csa_enabled and "ON" or "OFF"
        PM.log_msg("Screen Announcements: " .. t_txt, true, "settings") 
    end
    SLASH_COMMANDS["/pmemtogglecsa"] = SLASH_COMMANDS["/pmemcsa"]

    SLASH_COMMANDS["/pmemfree"] = function() 
        PM.settings.is_unrestricted = not PM.settings.is_unrestricted
        local t_txt = PM.settings.is_unrestricted and "ON" or "OFF"
        PM.log_msg("Unrestricted Mode: " .. t_txt, true, "settings") 
    end
    SLASH_COMMANDS["/pmemunrestrict"] = SLASH_COMMANDS["/pmemfree"]

    SLASH_COMMANDS["/pmemlock"] = function() 
        PM.settings.ui.is_locked = not PM.settings.ui.is_locked
        if PM.ui_window then
            PM.ui_window:SetMovable(not PM.settings.ui.is_locked)
        end
        local t_txt = PM.settings.ui.is_locked and "Locked" or "Unlocked"
        PM.log_msg("UI " .. t_txt, true, "ui") 
    end
    SLASH_COMMANDS["/pmemuilock"] = SLASH_COMMANDS["/pmemlock"]

    SLASH_COMMANDS["/pmemresetui"] = function() 
        PM.settings.ui.left = PM.defaults.ui.left
        PM.settings.ui.top = PM.defaults.ui.top
        PM.settings.ui_menu.left = PM.defaults.ui_menu.left
        PM.settings.ui_menu.top = PM.defaults.ui_menu.top
        PM.update_ui_anchor(); PM.log_msg("UI Position Reset.", true, "ui") 
    end
    SLASH_COMMANDS["/pmemuireset"] = SLASH_COMMANDS["/pmemresetui"]

    SLASH_COMMANDS["/pmemwipe"] = function() PM.delete_all_learned_data() end
    SLASH_COMMANDS["/pmemdeletealllearned"] = SLASH_COMMANDS["/pmemwipe"]

    SLASH_COMMANDS["/pmemscan"] = function() PM.auto_scan_mementos() end
    SLASH_COMMANDS["/pmemautolearn"] = SLASH_COMMANDS["/pmemscan"]

    SLASH_COMMANDS["/pmemlist"] = function()
        if PM.acct_saved and PM.acct_saved.learned_data then 
            local out_msg = "Learned Data:\n"; local cc = 0
            for _, md in pairs(PM.acct_saved.learned_data) do
                out_msg = out_msg .. "- " .. md.name .. " (" .. (md.dur/1000) .. "s)\n"
                cc = cc + 1
            end
            if cc == 0 then PM.log_msg("Learned Data is empty.", false)
            else PM.log_msg(out_msg, false) end
        else PM.log_msg("Learned Data is empty.", false) end
    end
    SLASH_COMMANDS["/pmemlearned"] = SLASH_COMMANDS["/pmemlist"]

    SLASH_COMMANDS["/pmemplay"] = function(raw_arg) 
        local c_arg = raw_arg:lower()
        if c_arg and c_arg ~= "" then 
            if PM.acct_saved and PM.acct_saved.learned_data then 
                for f_id, md in pairs(PM.acct_saved.learned_data) do 
                    if string.find(string.lower(md.name), c_arg, 1, true) then 
                        PM.settings.active_id = f_id
                        PM.log_msg("Activated (Learned): " .. md.name, true, "activation")
                        PM.start_loop(f_id); return 
                    end 
                end 
            end
            PM.log_msg("Learned Memento not found: " .. c_arg, true, "error") 
        end 
    end
    SLASH_COMMANDS["/pmemactivatelearned"] = SLASH_COMMANDS["/pmemplay"]

    SLASH_COMMANDS["/pmemcur"] = function() 
        local md = PM.get_data(PM.settings.active_id)
        if PM.settings.active_id and md then
            PM.log_msg("Active: " .. (md.name or "Unknown"), false)
        else PM.log_msg("Inactive", false) end 
    end
    SLASH_COMMANDS["/pmemcurrent"] = SLASH_COMMANDS["/pmemcur"]

    SLASH_COMMANDS["/pmempause"] = function()
        PM.settings.is_paused = not PM.settings.is_paused
        if PM.settings.is_paused then
            PM.log_msg("Auto-loop PAUSED.", true, "stop", 90)
        else
            PM.log_msg("Auto-loop RESUMED.", true, "activation", 90)
            if PM.settings.active_id then PM.run_loop(PM.loop_token) end
        end
    end
    SLASH_COMMANDS["/pmemtogglepause"] = SLASH_COMMANDS["/pmempause"]

    SLASH_COMMANDS["/pmemcombat"] = function()
        PM.settings.is_loop_in_combat = not PM.settings.is_loop_in_combat
        local t_txt = PM.settings.is_loop_in_combat and "ON" or "OFF"
        PM.log_msg("Loop In Combat: " .. t_txt, true, "settings")
    end
    SLASH_COMMANDS["/pmemloopincombat"] = SLASH_COMMANDS["/pmemcombat"]

    SLASH_COMMANDS["/pmemperf"] = function()
        PM.settings.is_performance_mode = not PM.settings.is_performance_mode
        local t_txt = PM.settings.is_performance_mode and "ON" or "OFF"
        PM.log_msg("Performance Mode: " .. t_txt, true, "settings")
    end
    SLASH_COMMANDS["/pmemperformancemode"] = SLASH_COMMANDS["/pmemperf"]

    SLASH_COMMANDS["/pmemautoclean"] = function()
        if is_alc_enabled() then
            PM.log_msg("Auto Cleanup DISABLED because ALC Addon is running.", true, "error")
            return
        end
        PM.settings.is_auto_cleanup = not PM.settings.is_auto_cleanup
        PM.toggle_cleanup_events()
        local t_txt = PM.settings.is_auto_cleanup and "ON" or "OFF"
        PM.log_msg("Auto Lua Cleanup: " .. t_txt, true, "settings")
    end
    SLASH_COMMANDS["/pmemautocleanup"] = SLASH_COMMANDS["/pmemautoclean"]

    SLASH_COMMANDS["/pmemacct"] = function()
        PM.char_saved.use_account_settings = not PM.char_saved.use_account_settings
        PM.update_settings_reference()
        PM.log_msg("Account-Wide Settings...", true, "settings", 80)
        zo_callLater(function() ReloadUI("ingame") end, 2000)
    end
    SLASH_COMMANDS["/pmemuseaccountsettings"] = SLASH_COMMANDS["/pmemacct"]

    SLASH_COMMANDS["/pmemwipefav"] = function() PM.delete_all_favorites() end
    SLASH_COMMANDS["/pmemdeleteallfavorites"] = SLASH_COMMANDS["/pmemwipefav"]

    SLASH_COMMANDS["/pmemreset"] = function()
        local exclude = {
            learned_data = true, favorites = true, total_loops = true,
            memento_usage = true, install_date = true, version_history = true,
            last_version = true, is_migrated_086 = true,
            has_shown_lib_warning_086 = true, alc_disabled_pm = true
        }
        
        for k, v in pairs(PM.defaults) do
            if not exclude[k] then
                if type(v) == "table" then
                    PM.settings[k] = ZO_ShallowTableCopy(v)
                else
                    PM.settings[k] = v
                end
            end
        end
        
        PM:toggle_cleanup_events(); ReloadUI("ingame")
    end
    SLASH_COMMANDS["/pmemresetdefaults"] = SLASH_COMMANDS["/pmemreset"]

    SLASH_COMMANDS["/pmemhudscale"] = function(raw_arg)
        local n_val = tonumber(raw_arg)
        if n_val and n_val >= 0.5 and n_val <= 2.0 then
            PM.settings.ui.scale = n_val; PM.update_ui_anchor()
            PM.log_msg("HUD Scale set to: " .. n_val, true, "ui")
        else PM.log_msg("Usage: /pmemhudscale <0.5 to 2.0>", true, "error", 90) end
    end
    SLASH_COMMANDS["/pmemsethudscale"] = SLASH_COMMANDS["/pmemhudscale"]

    SLASH_COMMANDS["/pmemmenuscale"] = function(raw_arg)
        local n_val = tonumber(raw_arg)
        if n_val and n_val >= 0.5 and n_val <= 2.0 then
            PM.settings.ui_menu.scale = n_val; PM.update_ui_anchor()
            PM.log_msg("Menu Scale set to: " .. n_val, true, "ui")
        else PM.log_msg("Usage: /pmemmenuscale <0.5 to 2.0>", true, "error", 90) end
    end
    SLASH_COMMANDS["/pmemsetmenuscale"] = SLASH_COMMANDS["/pmemmenuscale"]

    if not IsConsoleUI() then
        SLASH_COMMANDS["/pmemlogs"] = function()
            PM.settings.is_log_enabled = not PM.settings.is_log_enabled
            local t_txt = PM.settings.is_log_enabled and "ON" or "OFF"
            PM.log_msg("Chat Logs: " .. t_txt, true, "settings")
        end
        SLASH_COMMANDS["/pmemchatlogs"] = SLASH_COMMANDS["/pmemlogs"]

        SLASH_COMMANDS["/pmemnospin"] = function()
            PM.settings.is_stop_spinning = not PM.settings.is_stop_spinning
            PM.apply_spin_stop()
            local t_txt = PM.settings.is_stop_spinning and "ON" or "OFF"
            PM.log_msg("Stop Spinning in Menus: " .. t_txt, true, "settings")
        end
        SLASH_COMMANDS["/pmemstopspinning"] = SLASH_COMMANDS["/pmemnospin"]

        SLASH_COMMANDS["/pmsyncon"] = function()
            PM.settings.sync_module.is_enabled = not PM.settings.sync_module.is_enabled
            PM.toggle_sync_listener()
            local t_txt = PM.settings.sync_module.is_enabled and "ON" or "OFF"
            PM.log_msg("Sync Listening: " .. t_txt, true, "settings")
        end
        SLASH_COMMANDS["/pmemsyncenable"] = SLASH_COMMANDS["/pmsyncon"]

        SLASH_COMMANDS["/pmsyncdelay"] = function()
            PM.settings.sync_module.is_random = not PM.settings.sync_module.is_random
            local t_txt = PM.settings.sync_module.is_random and "ON" or "OFF"
            PM.log_msg("Random Sync Delay: " .. t_txt, true, "settings")
        end
        SLASH_COMMANDS["/pmemsyncrandomdelay"] = SLASH_COMMANDS["/pmsyncdelay"]
    end
    
    SLASH_COMMANDS["/pmsyncstop"] = function() 
        if StartChatInput then
            StartChatInput("PM STOP", CHAT_CHANNEL_PARTY)
        elseif CHAT_SYSTEM then
            CHAT_SYSTEM:StartTextEntry("PM STOP")
        end
        if PM.settings then
            PM.settings.active_id = nil; PM.loop_token = (PM.loop_token or 0) + 1
        end
        PM.next_fire_time = 0 
    end
    SLASH_COMMANDS["/permmementosyncstop"] = SLASH_COMMANDS["/pmsyncstop"]

    SLASH_COMMANDS["/pmsyncrand"] = function() 
        local r_id = PM.get_random_any()
        if r_id then
            local l_str = GetCollectibleLink(r_id, LINK_STYLE_BRACKETS)
            if StartChatInput then
                StartChatInput(string.format("PM %s", l_str), CHAT_CHANNEL_PARTY)
            elseif CHAT_SYSTEM then
                CHAT_SYSTEM:StartTextEntry(string.format("PM %s", l_str))
            end
            PM.log_msg("Sent Random Sync Request", true, "sync", 90)
        end
    end
    SLASH_COMMANDS["/permmementosyncrandom"] = SLASH_COMMANDS["/pmsyncrand"]
end

function PM.on_player_activated()
    local is_alc_running = is_alc_enabled()
    
    if is_alc_running and PM.settings.is_auto_cleanup and not PM.settings.alc_disabled_pm then
        PM.settings.alc_disabled_pm = true
        local msg1 = "Auto Lua Memory Cleaner detected. "
        local msg2 = "PM's internal cleaner has been suspended to prevent conflicts."
        PM.log_msg(msg1 .. msg2, false, "settings", 90)
    elseif not is_alc_running and PM.settings.alc_disabled_pm then
        PM.settings.alc_disabled_pm = false
        PM.settings.is_auto_cleanup = true; PM.settings.is_csa_cleanup_enabled = true
        local msg1 = "ALC Addon no longer detected. "
        local msg2 = "PM's internal cleaner has safely resumed."
        PM.log_msg(msg1 .. msg2, false, "settings", 90)
    end
    
    PM.toggle_cleanup_events()
    if PM.settings.is_auto_cleanup and not is_alc_running then
        PM.trigger_memory_check("ZoneLoad", 5000)
    end
    
    if PM.acct_saved and PM.acct_saved.recentScans and #PM.acct_saved.recentScans > 0 then
        zo_callLater(function()
            PM.log_msg("Newly Learned Mementos from Auto-Scan:", false)
            for _, f_id in ipairs(PM.acct_saved.recentScans) do
                local md = PM.acct_saved.learned_data[f_id]
                if md then
                    local out_msg = string.format(
                        "- %s (ID: %d | RefID: %d | Dur: %dms)",
                        md.name, md.id, md.ref_id, md.dur
                    )
                    PM.log_msg(out_msg, false)
                end
            end
            PM.acct_saved.recentScans = nil 
        end, 2000)
    end

    local w_ms = (PM.settings.delay_teleport or 5) * 1000
    local r_zone = PM.settings.is_random_on_zone
    local r_log = PM.settings.is_random_on_login
    local r_fav = PM.settings.enable_random_fav
    
    if r_zone and r_fav then 
        local r_id = PM.get_random_supported()
        if r_id then
            PM.settings.active_id = r_id
            PM.log_msg("Zone Random: " .. PM.get_data(r_id).name, true, "random")
        end
    elseif r_log and not PM.settings.active_id and r_fav then 
        local r_id = PM.get_random_supported()
        if r_id then
            PM.settings.active_id = r_id
            PM.log_msg("Login Random: " .. PM.get_data(r_id).name, true, "random")
        end 
    end
    
    if PM.settings and PM.settings.active_id and not PM.settings.is_paused then 
        local tkn = PM.loop_token
        zo_callLater(function()
            if PM.settings.active_id then PM.run_loop(tkn) end
        end, w_ms) 
    end
end

EVENT_MANAGER:RegisterForEvent(PM.name, EVENT_ADD_ON_LOADED, function(...) PM.init(...) end)
_G.PermMementoCore = PM
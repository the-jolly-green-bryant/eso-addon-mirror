-- Auto Lua Memory Cleaner
-- LICENSE
-- Copyright 2025-2026 @APHONlC
-- Licensed under the Apache License, Version 2.0.

-- TESTED: 2026-03-26 | Release v0.0.8 | APIVersion: 101049 | LAM2 v41
local is_release_build = true
local REQUIRED_LAM_VERSION = 41
local REQUIRED_LCA_VERSION = 7060
local stat_fps_total = 0
local stat_fps_count = 0

local function IsConsoleUI()
    return IsInGamepadPreferredMode()
end

local ALC = {
    name = "AutoLuaMemoryCleaner",
    version = "0.0.8",
    defaults = {
        is_enabled = true,
        threshold_pc = 400,
        threshold_console = 60,
        fallback_delay_sec = 300,
        is_csa_enabled = true,
        is_log_enabled = false,
        show_ui = false,
        is_ui_locked = false,
        ui_x = nil,
        ui_y = nil,
        track_stats = false,
        is_migrated_008 = false,
        has_shown_lib_warning_008 = false,
        total_cleanups = 0,
        total_mb_freed = 0,
        last_session_cleanups = 0,
        last_session_mb_freed = 0,
        prev_session_cleanups = 0,
        prev_session_mb_freed = 0,
        install_date = nil,
        is_graph_enabled = false,
        is_stats_log_enabled = false,
        session_history = {},
        graph_x = nil,
        graph_y = nil,
        is_graph_locked = false,
        is_graph_detached = false,
        is_graph_global = false,
        is_ui_global = false,
        is_session_global = false,
        version_history = {},
        show_mem_ui_bar = false,
        show_graph_diags = true,
        lite_mode = false,
        track_fps = false,
        track_ping = false,
        track_memory_gains = false,
        track_frametime = false,
        show_session_ui = false,
        session_ui_x = nil,
        session_ui_y = nil,
        is_session_locked = false,
        session_track_peak = false,
        session_track_avg = false,
        session_track_final = false,
        session_track_cleaned = false,
        
        prev_session_perf = {
            ft_peak = 0,
            ft_avg = 0,
            ft_final = 0,
            ft_ticks = 0,
            fps_loss_max = 0,
            fps_avg = 0
        },
        
        is_profiler_enabled = false,
        can_profile_self = false,
        include_esoprofiler = false,
        exclude_libs = false,
        saved_profiler_data = {},
        specific_lib_excludes = {},
        specific_addon_excludes = {}
    },
    mem_state = 0,
    is_mem_check_queued = false,
    session_cleanups = 0,
    session_mb_freed = 0,
    last_priority_save_time = 0,
    last_ui_update = 0,
    is_scene_callback_registered = false,
    scene_callback_fn = nil,
    ui_update_fn = nil,
    is_profiling = false,
    frametime_avg_accumulator = 0,
    frametime_ticks = 0
}

local graph_window = nil
local max_points = 60
local last_graph_mb = 0
local session_peak_mb = 0

local graph_labels = {}
local graph_segments = {}
local graph_grid_lines = {}
local graph_labels_x = {}
local graph_grid_lines_v = {}
local graph_latency_dots = {}
local graph_frametime_dots = {}
local graph_labels_lat = {}
local graph_latency_pool = {}
local graph_frametime_pool = {}

local diag_labels = {}
local graph_last_diag_time = 0
local graph_last_sec_mb = 0

local stat_ticks = 0
local stat_total_ping = 0
local stat_baseline_fps = 0
local stat_fps_stable_ticks = 0
local stat_last_fps_raw = 0
local stat_baseline_ping = 0
local stat_ping_stable_ticks = 0
local stat_last_ping_raw = 0

local session_window = nil
local history_label = nil
local stat_session_ticks = 0
local stat_session_fps_loss_max = 0
local stat_session_fps_loss_final = 0
local stat_session_ping_max = 0
local stat_session_ping_final = 0
local stat_session_ping_total = 0
local stat_session_kb_max = 0
local stat_session_kb_final = 0
local stat_session_kb_total = 0
local stat_session_mb_max = 0
local stat_session_mb_final = 0
local stat_session_mb_total = 0
local stat_session_fps_loss_total = 0
local stat_session_current_mb_total = 0
local stat_session_ft_max = 0
local stat_session_ft_final = 0
local stat_session_ft_total = 0
local stat_session_fps_total = 0
local stat_session_fps_final = 0

local function format_dynamic_gain(mbValue)
    local value = mbValue
    if value < 1 then
        value = value * 1024
        return string.format("%.2f KB", value)
    elseif value < 1024 then
        return string.format("%.2f MB", value)
    elseif value < 1024 * 1024 then
        value = value / 1024
        return string.format("%.2f GB", value)
    else
        value = value / (1024 * 1024)
        return string.format("%.2f TB", value)
    end
end

local function capitalizeAddonName(str)
    return (str:gsub("^%l", string.upper))
end

function ALC.format_time(ms_val)
    if not ms_val then return "0 ms" end
    if ms_val < 1000 then return string.format("%.1f ms", ms_val) end
    local sec = ms_val / 1000
    if sec < 60 then return string.format("%.1f sec", sec) end
    local mins = sec / 60
    if mins < 60 then return string.format("%.1f min", mins) end
    local hrs = mins / 60
    return string.format("%.2f hr", hrs)
end

function ALC.get_hybrid_memory_data()
    return collectgarbage("count") / 1024
end

function ALC.get_console_pool_mb()
    return GetTotalUserAddOnMemoryPoolUsageMB() or 0
end

function ALC.get_alc_color(val, is_spike_mb)
    local limit = IsConsoleUI() and ALC.settings.threshold_console or ALC.settings.threshold_pc
    local pct = math.min((val / limit) * 100, 100)
    
    if is_spike_mb then
        if pct >= 90 then return 1, 0, 0, "|cFF0000"
        elseif pct >= 75 then return 1, 0.5, 0, "|cFFA500"
        else return 0, 1, 0, "|c00FF00" end
    else
        if val >= (IsConsoleUI() and 100 or 512) then return 1, 0, 0, "|cFF0000"
        elseif val >= (IsConsoleUI() and 60 or 320) then return 1, 0.65, 0, "|cFFA500"
        else return 0, 1, 0, "|c00FF00" end
    end
end

function ALC.get_gradient_color(block_mb, peak_mb)
    if IsConsoleUI() then
        if block_mb < 60 then return 0, 1, 0
        elseif block_mb < 100 then return 1, 0.65, 0
        else return 1, 0, 0 end
    else
        if block_mb < 320 then return 0, 1, 0
        elseif block_mb < 449 then return 1, 0.65, 0
        else return 1, 0, 0 end
    end
end

function ALC.get_main_label_color(mbCurrent, thresholdMB)
    local pct = math.min((mbCurrent / thresholdMB) * 100, 100)
    local r, g, b
    if pct < 80 then r, g, b = 0, 1, 0
    elseif pct < 95 then r, g, b = 1, 0.65, 0 
    else r, g, b = 1, 0, 0 end
    local r255, g255, b255 = r*255, g*255, b*255
    return string.format("%02x%02x%02x", r255, g255, b255), r, g, b
end

function ALC.get_fixed_hard_cap_color(mbCurrent)
    if IsConsoleUI() then
        if mbCurrent >= 100 then return "|cFF0000"
        elseif mbCurrent >= 60 then return "|cFFA500"
        else return "|c00FF00" end
    else
        if mbCurrent >= 512 then return "|cFF0000"
        elseif mbCurrent >= 320 then return "|cFFA500"
        else return "|c00FF00" end
    end
end

function ALC.set_tag_alignment(l, y_off) 
    l:ClearAnchors()
    l:SetAnchor(LEFT, graph_window, TOPLEFT, 305, y_off - 6) 
end

function ALC.check_session_peak()
    if not ALC.settings.is_stats_log_enabled then return end
    local current_mb = ALC.get_hybrid_memory_data()
    if current_mb > session_peak_mb then session_peak_mb = current_mb end
end

function ALC.get_settings_library()
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

function ALC.calculate_ram_overhead_recursive(t, seen_map, depth)
    seen_map = seen_map or {}
    depth = depth or 0
    if depth > 20 then return 0, 0, 0, 0 end
    if seen_map[t] then return 0, 0, 0, 0 end
    seen_map[t] = true
    
    local keys, raw_bytes, total_refs = 0, 0, 0
    local array_slots, hash_slots, nested_ib = 0, 0, 0
    local instruction_limit = 0

    for k, v in pairs(t) do
        instruction_limit = instruction_limit + 1
        if instruction_limit > 5000 then break end

        keys = keys + 1; total_refs = total_refs + 1
        
        if type(k) == "string" then raw_bytes = raw_bytes + #k + 16 end
        
        local v_type = type(v)
        if v_type == "string" then raw_bytes = raw_bytes + #v + 16
        elseif v_type == "number" then raw_bytes = raw_bytes + 8
        elseif v_type == "boolean" then raw_bytes = raw_bytes + 8
        elseif v_type == "table" then
            local rb, tr, k2, ib2 = ALC.calculate_ram_overhead_recursive(v, seen_map, depth + 1)
            raw_bytes = raw_bytes + rb; total_refs = total_refs + tr
            keys = keys + k2; nested_ib = nested_ib + ib2
        end
        
        if type(k) == "number" and k > 0 and k % 1 == 0 then array_slots = array_slots + 1
        else hash_slots = hash_slots + 1 end
    end
    
    total_refs = total_refs + 1
    local function next_power_2(n)
        local p = 1
        while p < n do p = p * 2 end; return p
    end
    
    local allocated_array_slots = next_power_2(array_slots)
    local allocated_hash_slots = next_power_2(hash_slots)
    local invisible_structure_bytes = (allocated_array_slots * 8) + (allocated_hash_slots * 24) + 16 + nested_ib
    return raw_bytes, total_refs, keys, invisible_structure_bytes
end

function ALC.get_true_ram_footprint(t)
    local rb, tr, k, ib = ALC.calculate_ram_overhead_recursive(t, {}, 0)
    return (rb + (k * 8) + ib)
end

function ALC.get_high_precision_sv_disk_size(t)
    local function count_sv_chars_recursive(t, depth, seen)
        if type(t) ~= "table" or seen[t] or depth > 20 then return 0 end
        seen[t] = true
        
        local chars = 0
        local instruction_limit = 0
        for k, v in pairs(t) do
            instruction_limit = instruction_limit + 1
            if instruction_limit > 5000 then break end

            chars = chars + (depth * 4)
            local k_type = type(k)
            if k_type == "string" then chars = chars + #k + 7
            elseif k_type == "number" then chars = chars + 10 end
            
            local v_type = type(v)
            if v_type == "string" then chars = chars + #v + 4 
            elseif v_type == "number" then chars = chars + 10
            elseif v_type == "boolean" then chars = chars + (v and 4 or 5) + 2
            elseif v_type == "table" then 
                chars = chars + 1 + (depth * 4) + 2 
                chars = chars + count_sv_chars_recursive(v, depth + 1, seen) 
                chars = chars + (depth * 4) + 3     
            end
        end
        return chars
    end
    return count_sv_chars_recursive(t, 1, {}) + 20
end

function ALC.format_memory(value_mb)
    if value_mb >= 1048576 then return string.format("%.2f TB", value_mb / 1048576)
    elseif value_mb >= 1024 then return string.format("%.2f GB", value_mb / 1024)
    elseif value_mb >= 1 then return string.format("%.2f MB", value_mb)
    else return string.format("%d KB", math.floor(value_mb * 1024)) end
end

function ALC.refresh_stats_tracker()
    if not ALC.settings then return end
    if ALC.settings.track_stats and not IsConsoleUI() then
        EVENT_MANAGER:RegisterForUpdate(ALC.name .. "_StatsUpdate", 1000, function()
            local stats_ctrl = _G["ALC_StatsText"]
            if stats_ctrl and stats_ctrl.desc and not stats_ctrl:IsHidden() then
                stats_ctrl.desc:SetText(ALC.get_stats_text())
            end
        end)
    else 
        EVENT_MANAGER:UnregisterForUpdate(ALC.name .. "_StatsUpdate") 
    end
end

function ALC.toggle_core_events()
    if ALC.settings.is_enabled then
        EVENT_MANAGER:RegisterForEvent(ALC.name .. "_CombatState", EVENT_PLAYER_COMBAT_STATE, 
            function(event_code, in_combat) 
                if not in_combat then ALC.trigger_memory_check("CombatEnd", 3000) end 
            end
        )
        EVENT_MANAGER:RegisterForEvent(ALC.name .. "_LowMem", EVENT_LUA_LOW_MEMORY, 
            function()
                if IsConsoleUI() then
                    ALC.run_manual_cleanup()
                end
            end
        )
        EVENT_MANAGER:RegisterForUpdate(ALC.name .. "_AutoSweep", 5000,
            function()
                if not IsPlayerMoving() then
                    ALC.trigger_memory_check("Idle", 1000)
                else
                    ALC.trigger_memory_check("AutoSweep", 0)
                end
            end
        )
        if SCENE_MANAGER and not ALC.is_scene_callback_registered then
            ALC.scene_callback_fn = function(scene, old_state, new_state)
                if new_state == SCENE_SHOWN then
                    local s_name = scene:GetName()
                    if s_name ~= "hud" and s_name ~= "hudui" and s_name ~= "gamepad_hud" then 
                        ALC.trigger_memory_check("Menu", 6000) 
                    end
                end
            end
            SCENE_MANAGER:RegisterCallback("SceneStateChanged", ALC.scene_callback_fn)
            ALC.is_scene_callback_registered = true
        end
    else
        EVENT_MANAGER:UnregisterForEvent(ALC.name .. "_CombatState", EVENT_PLAYER_COMBAT_STATE)
        EVENT_MANAGER:UnregisterForEvent(ALC.name .. "_LowMem", EVENT_LUA_LOW_MEMORY)
        EVENT_MANAGER:UnregisterForUpdate(ALC.name .. "_IdleCheck")
        EVENT_MANAGER:UnregisterForUpdate(ALC.name .. "_AutoSweep")
        if SCENE_MANAGER and ALC.is_scene_callback_registered then
            SCENE_MANAGER:UnregisterCallback("SceneStateChanged", ALC.scene_callback_fn)
            ALC.is_scene_callback_registered = false
        end
        EVENT_MANAGER:UnregisterForUpdate(ALC.name .. "_Fallback")
        ALC.mem_state = 0
        ALC.is_mem_check_queued = false
    end
end

function ALC.toggle_ui_update()
    if not ALC.ui_window then return end
    if ALC.settings.show_ui then
        ALC.ui_window:SetHandler("OnUpdate", ALC.ui_update_fn)
    else 
        ALC.ui_window:SetHandler("OnUpdate", nil)
    end
    
    if ALC.settings.is_graph_enabled and ALC.settings.show_ui then
        if not graph_window then ALC.build_graph_ui() end
        EVENT_MANAGER:RegisterForUpdate("ALC_GraphTick", 250, function() 
            ALC.update_graph_visuals() 
        end)
    else
        EVENT_MANAGER:UnregisterForUpdate("ALC_GraphTick")
    end
    ALC.update_ui_scenes()
end

function ALC.safe_csa(text, custom_limit)
    if not ALC.settings.is_csa_enabled or not CENTER_SCREEN_ANNOUNCE then return end
    local limit = custom_limit or 70 
    
    if string.len(text) <= limit then
        local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
        params:SetText(text)
        params:SetLifespanMS(4000)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
        return
    end
    
    local chunks = {}
    local current_chunk = ""
    
    for word in string.gmatch(text, "%S+") do
        local test_str = (current_chunk == "") and word or (current_chunk .. " " .. word)
        if string.len(test_str) > limit and current_chunk ~= "" then 
            table.insert(chunks, current_chunk)
            current_chunk = word
        else 
            current_chunk = test_str 
        end
    end
    
    if current_chunk ~= "" then table.insert(chunks, current_chunk) end

    local delay_ms = 0
    local active_color = ""
    
    for i, chunk in ipairs(chunks) do
        local final_msg = chunk
        if i > 1 then final_msg = active_color .. "..." .. final_msg end
        if i < #chunks then final_msg = final_msg .. "..." end
        
        local idx = 1
        while idx <= string.len(chunk) do
            local c_tag = string.match(chunk, "^|c%x%x%x%x%x%x", idx)
            if c_tag then 
                active_color = c_tag; idx = idx + 8
            elseif string.sub(chunk, idx, idx + 1) == "|r" then 
                active_color = ""; idx = idx + 2
            else 
                idx = idx + 1 
            end
        end
        
        local opens = 0
        for _ in string.gmatch(final_msg, "|c%x%x%x%x%x%x") do opens = opens + 1 end
        local closes = 0
        for _ in string.gmatch(final_msg, "|r") do closes = closes + 1 end
        if opens > closes then final_msg = final_msg .. "|r" end

        if delay_ms > 0 then
            zo_callLater(function() 
                local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(
                    CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE
                )
                params:SetText(final_msg)
                params:SetLifespanMS(4000)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
            end, delay_ms)
        else
            local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(
                CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE
            )
            params:SetText(final_msg)
            params:SetLifespanMS(4000)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
        end
        delay_ms = delay_ms + 1500
    end
end

function ALC.get_stats_text()
    if not ALC.settings.track_stats then 
        return "Tracking DISABLED. Enable 'Track Statistics' or type /alcstats to view live data." 
    end
    
    local current_mb = ALC.get_hybrid_memory_data()
    local mem_warning = ""
    local lua_limit_txt = ""
    
    if IsConsoleUI() then
        lua_limit_txt = "100 MB (Hard Limit)"
        mem_warning = current_mb > 70 and "|cFF0000(EXCEEDS CONSOLE LIMIT)|r" or "|c00FF00(Safe)|r" 
    else
        lua_limit_txt = "Dynamic [512MB] (Auto-Scaling)"
        mem_warning = current_mb > 400 and "|cFFA500(High Global Memory)|r" or "|c00FF00(Safe)|r" 
    end
    
    local install_date = ALC.settings.install_date or "Unknown"
    local v_history = table.concat(ALC.settings.version_history or {ALC.version}, ", ")
    
    local lam_ver, lam_en, lca_ver, lca_en = ALC.get_settings_library()
    
    local function get_lib_str(ver, en, name, req)
        if ver == 0 then return string.format("|cFF0000%s (Missing)|r", name) end
        if not en then return string.format("|cFF0000%s (Disabled - v%d)|r", name, ver) end
        if ver < req then return string.format("|cFF0000%s (v%d) (PLEASE UPDATE %s TO v%d)|r", name, ver, name, req) end
        return string.format("|c00FF00%s (v%d)|r", name, ver)
    end
    
    local lib_text = get_lib_str(lam_ver, lam_en, "LAM2", REQUIRED_LAM_VERSION) .. " | " .. get_lib_str(lca_ver, lca_en, "LCA", REQUIRED_LCA_VERSION)
    
    local pc_data_str = ""
    if not IsConsoleUI() then
        local mem_raw = ALC.get_true_ram_footprint(ALC)
        local mem_mb = mem_raw / (1024 * 1024)
        local mem_kb = mem_raw / 1024
        local mem_str = (mem_mb >= 1) and string.format("%.2f MB", mem_mb) or string.format("%.2f KB", mem_kb)
        local sv_prec_bytes = ALC.get_high_precision_sv_disk_size(_G["AutoLuaCleaner"] or {})
        local sv_size_kb = sv_prec_bytes / 1024
        local sv_size_mb = sv_size_kb / 1024
        local sv_str = (sv_size_mb >= 1) and string.format("%.2f MB", sv_size_mb) or string.format("%.2f KB", sv_size_kb)
        local sv_health = _G["AutoLuaCleaner"] and "|c00FF00Healthy|r" or "|cFF0000Corrupted|r"
        local sv_warn = (sv_size_kb > 5000) and "|cFFA500(Large File)|r" or "|c00FF00(Safe)|r"
        pc_data_str = string.format("Data Footprint: %s (Estimated)\nSavedVariable Disk Size: %s (%s) %s\n", mem_str, sv_str, sv_health, sv_warn)
    end

    local prof_txt = ""
    local p_data = ALC.settings.saved_profiler_data
    if p_data and p_data[1] and p_data[1].peak and p_data[1].peak > 0 then
        prof_txt = string.format(
            "\n\n|c00FFFF[Last Profiler Scan]|r\nPeak: %.1fms by [%s]",
            p_data[1].peak,
            p_data[1].name
        )
    end
    
    local num_errors = ALC.settings.error_logs and #ALC.settings.error_logs or 0
    local err_str = num_errors > 0 and string.format("|cFF0000%d (Check Logs)|r", num_errors) or "|c00FF000 (Healthy)|r"

    return string.format(
        "Installed Since: %s\nVersion History: %s\nActive Library: %s\n" ..
        "Max Lua Memory: %s\nCurrent Global Memory: %s %s\n%s" ..
        "Active Errors: %s\n\n" ..
        "|c00FF00[Session Statistics]|r\nCleanups Triggered: %d\nMemory Freed: %s\n\n" ..
        "|cFFA500[Previous Session Statistics]|r\nCleanups Triggered: %d\nMemory Freed: %s\n\n" ..
        "|c00FFFF[Lifetime Statistics]|r\nTotal Cleanups: %d\nTotal Memory Freed: %s%s", 
        install_date, v_history, lib_text, lua_limit_txt, ALC.format_memory(current_mb), 
        mem_warning, pc_data_str, err_str, ALC.session_cleanups, ALC.format_memory(ALC.session_mb_freed), 
        ALC.settings.prev_session_cleanups or 0, 
        ALC.format_memory(ALC.settings.prev_session_mb_freed or 0),
        ALC.settings.total_cleanups or 0, 
        ALC.format_memory(ALC.settings.total_mb_freed or 0),
        prof_txt
    )
end

function ALC.migrate_data()
    if ALC.settings then
        ALC.settings.pmOverridden = nil
        if not ALC.settings.is_migrated_008 then
            ALC.settings.is_migrated_008 = true
        end
        if ALC.settings.threshold_console == 85 or ALC.settings.threshold_console == 70 then
            ALC.settings.threshold_console = 60
        end
    end
    if _G["AutoLuaCleaner"] then
        for world_name, world_data in pairs(_G["AutoLuaCleaner"]) do
            if type(world_data) == "table" then
                for account_name, account_data in pairs(world_data) do
                    if type(account_data) == "table" then
                        for profile_id, profile_data in pairs(account_data) do
                            if type(profile_data) == "table" then 
                                profile_data["pmOverridden"] = nil 
                            end
                        end
                    end
                end
            end
        end
    end
end

function ALC.create_mover(target, label_text)
    local mover = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_TOPLEVELCONTROL)
    mover:SetDimensions(target:GetWidth(), target:GetHeight())
    mover:SetAnchor(CENTER, target, CENTER, 0, 0)
    mover:SetDrawTier(DT_HIGH)
    mover:SetDrawLayer(DL_OVERLAY)
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

function ALC.unlock_ui()
    if ALC.is_ui_unlocked then return end
    ALC.is_ui_unlocked = true
    
    if SCENE_MANAGER then SCENE_MANAGER:Show("hud") end
    
    ALC.orig_pos = {
        ui = {x = ALC.settings.ui_x, y = ALC.settings.ui_y},
        graph = {x = ALC.settings.graph_x, y = ALC.settings.graph_y, detached = ALC.settings.is_graph_detached},
        session = {x = ALC.settings.session_ui_x, y = ALC.settings.session_ui_y}
    }
    
    local cur_scene = SCENE_MANAGER:GetCurrentScene()
    if cur_scene then
        if ALC.ui_window and cur_scene:HasFragment(ALC.hud_fragment) then 
            ALC.ui_window:SetHidden(false) 
        end
        if graph_window and cur_scene:HasFragment(ALC.graph_fragment) then 
            graph_window:SetHidden(false) 
        end
        if session_window and cur_scene:HasFragment(ALC.session_fragment) then 
            session_window:SetHidden(false) 
        end
    end
    
    ALC.movers = {}
        if ALC.ui_window then table.insert(ALC.movers, ALC.create_mover(ALC.ui_window, "Memory UI")) end
        if graph_window then table.insert(ALC.movers, ALC.create_mover(graph_window, "Graph UI")) end
        if session_window then table.insert(ALC.movers, ALC.create_mover(session_window, "Session UI")) end
        
        ALC.references = {}
        local function create_ref(target, text)
            if not target or target:IsHidden() or target:GetWidth() == 0 or target:GetHeight() == 0 then return end
            if not target.SetName then return end
            
            local ref = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_TOPLEVELCONTROL)
            ref:SetDimensions(target:GetWidth(), target:GetHeight())
            ref:SetAnchor(CENTER, target, CENTER, 0, 0)
            ref:SetDrawTier(DT_HIGH)
            ref:SetDrawLayer(DL_OVERLAY)
            ref:SetDrawLevel(9998)
            ref:SetMouseEnabled(false)
            ref:SetMovable(false)
            
            local bg = WINDOW_MANAGER:CreateControl(nil, ref, CT_BACKDROP)
            bg:SetAnchorFill(ref)
            bg:SetCenterColor(0, 0.4, 0.6, 0.3)
            bg:SetEdgeColor(0, 0.4, 0.6, 1)
            bg:SetEdgeTexture('', 8, 1, 0)
            
            local lbl = WINDOW_MANAGER:CreateControl(nil, ref, CT_LABEL)
            lbl:SetAnchorFill(ref)
            lbl:SetFont(IsInGamepadPreferredMode() and "ZoFontGamepad27" or "ZoFontWinH5")
            lbl:SetColor(1, 1, 1, 0.8)
            lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            lbl:SetText(text)
            table.insert(ALC.references, ref)
        end
        
        local function scanHUD(parent)
            if not parent or not parent:IsHidden() or not parent.GetNumChildren then return end
            for i = 1, parent:GetNumChildren() do
                local child = parent:GetChild(i)
                if child and child:GetType() == CT_TOPLEVELCONTROL and not child:IsHidden() then
                    local name = child:GetName()
                    local alc_match = string.match(name, "^ALC") or string.match(name, "^AutoLuaMemoryCleaner")
                    local system_match = string.match(name, "^ZO") or string.match(name, "^GuiRoot")
                    if not alc_match and not system_match then
                        create_ref(child, name or "Addon UI")
                    end
                end
            end
        end

        local hud_scene = IsInGamepadPreferredMode() and "gamepad_hud" or "hud"
        local scene = SCENE_MANAGER:GetScene(hud_scene)
        if scene then
            local fragments = scene:GetFragments()
            if fragments then
                for _, frag in ipairs(fragments) do
                    if frag.GetControl then
                        local control = frag:GetControl()
                        if control and not control:IsHidden() and control.SetName then
                            local name = control:GetName() or frag:GetName()
                            if name and string.len(name) > 0 then
                                create_ref(control, name)
                            end
                        end
                    end
                end
            end
        end
        
        scanHUD(GuiRoot)

        local dialog_id = "ALC_UI_UNLOCK_PROMPT"
    if not ESO_Dialogs[dialog_id] then
        ESO_Dialogs[dialog_id] = {
            canQueue = true, 
            gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC }, 
            title = { text = "|c00FFFFALC UI Unlocked|r" }, 
            mainText = { text = "Move the UI elements to your desired locations.\n\nPress Accept to Save.\nPress Decline to Cancel." },
            buttons = { 
                { text = "Save", keybind = "DIALOG_PRIMARY", callback = function() ALC.lock_ui(true) end },
                { text = "Cancel", keybind = "DIALOG_NEGATIVE", callback = function() ALC.lock_ui(false) end }
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

function ALC.lock_ui(save)
    if not ALC.is_ui_unlocked then return end
    ALC.is_ui_unlocked = false
    
    for _, mover in ipairs(ALC.movers) do
        mover:SetHidden(true)
    end
    ALC.movers = {}
    
    if ALC.references then
        for _, ref in ipairs(ALC.references) do
            ref:SetHidden(true)
        end
        ALC.references = {}
    end
    
    if save then
        if ALC.ui_window then
            ALC.settings.ui_x = ALC.ui_window:GetLeft()
            ALC.settings.ui_y = ALC.ui_window:GetTop()
        end
        if graph_window then
            ALC.settings.graph_x = graph_window:GetLeft()
            ALC.settings.graph_y = graph_window:GetTop()
            ALC.settings.is_graph_detached = true
        end
        if session_window then
            ALC.settings.session_ui_x = session_window:GetLeft()
            ALC.settings.session_ui_y = session_window:GetTop()
        end
        if CHAT_SYSTEM then CHAT_SYSTEM:AddMessage("|c00FFFF[ALC]|r UI Positions Saved.") end
    else
        ALC.settings.ui_x = ALC.orig_pos.ui.x
        ALC.settings.ui_y = ALC.orig_pos.ui.y
        ALC.settings.graph_x = ALC.orig_pos.graph.x
        ALC.settings.graph_y = ALC.orig_pos.graph.y
        ALC.settings.is_graph_detached = ALC.orig_pos.graph.detached
        ALC.settings.session_ui_x = ALC.orig_pos.session.x
        ALC.settings.session_ui_y = ALC.orig_pos.session.y
        
        ALC.update_ui_anchor()
        ALC.update_graph_anchor()
        ALC.update_session_anchor()
        if CHAT_SYSTEM then CHAT_SYSTEM:AddMessage("|c00FFFF[ALC]|r UI Positioning Cancelled.") end
    end
    
    ALC.toggle_ui_update()
    if session_window then
        session_window:SetHidden(not ALC.settings.show_session_ui)
    end
end

function ALC.run_manual_cleanup(force_feedback)
    ALC.mem_state = 1
    ALC.last_cleanup_time = GetGameTimeMilliseconds()
    zo_callLater(function()
        local before_lua = collectgarbage("count") / 1024
        local before_pool = ALC.get_console_pool_mb()
        for i = 1, 2 do collectgarbage("collect") end
        
        zo_callLater(function()
            local after_lua = collectgarbage("count") / 1024
            local after_pool = ALC.get_console_pool_mb()
            local freed = before_lua - after_lua
            local freed_pool = before_pool - after_pool
            ALC.mem_state = 0
            
            if freed > 0.001 then
                ALC.session_cleanups = ALC.session_cleanups + 1
                ALC.session_mb_freed = ALC.session_mb_freed + freed
                
                if ALC.settings and ALC.settings.track_stats then
                    ALC.settings.total_cleanups = (ALC.settings.total_cleanups or 0) + 1
                    ALC.settings.total_mb_freed = (ALC.settings.total_mb_freed or 0) + freed
                    ALC.settings.last_session_cleanups = ALC.session_cleanups
                    ALC.settings.last_session_mb_freed = ALC.session_mb_freed
                    
                    local now = GetGameTimeMilliseconds()
                    if (now - ALC.last_priority_save_time) >= 900000 then
                        GetAddOnManager():RequestAddOnSavedVariablesPrioritySave(ALC.name)
                        ALC.last_priority_save_time = now
                    end
                end
                
                local msg = ""
                if IsConsoleUI() then
                    msg = string.format("Mem Pool Freed: %s (LUA Mem: %s)", ALC.format_memory(math.max(freed_pool, 0)), ALC.format_memory(freed))
                else
                    msg = string.format("LUA Mem Freed: %s (Mem Pool: %s)", ALC.format_memory(freed), ALC.format_memory(math.max(freed_pool, 0)))
                end
                
                if ALC.settings.is_log_enabled and CHAT_SYSTEM then 
                    CHAT_SYSTEM:AddMessage("|c00FFFF[ALC]|r " .. msg) 
                end
                ALC.safe_csa("|c00FFFF" .. msg .. "|r", 90)
            elseif force_feedback then
                local msg = IsConsoleUI() 
                    and "Mem Pool Freed: 0 MB (Console Pool Locked)" 
                    or "LUA Mem Freed: 0 MB (Already Clean)"
                if ALC.settings.is_log_enabled and CHAT_SYSTEM then 
                    CHAT_SYSTEM:AddMessage("|c00FFFF[ALC]|r " .. msg) 
                end
                ALC.safe_csa("|c00FFFF" .. msg .. "|r", 90)
            end
            
            if ALC.settings.show_ui then ALC.update_ui() end
        end, 200)
    end, 500)
end

function ALC.trigger_memory_check(check_type, delay)
    if not ALC.settings.is_enabled then return end
    if ALC.mem_state == 1 or ALC.is_mem_check_queued then return end
    
    local now_ms = GetGameTimeMilliseconds()
    local fallback_ms = ALC.settings.fallback_delay_sec * 1000
    if (now_ms - (ALC.last_cleanup_time or 0)) < fallback_ms then return end
    
    local current_pool = ALC.get_hybrid_memory_data()
    local current_lua = collectgarbage("count") / 1024
    local limit_threshold = IsConsoleUI() and ALC.settings.threshold_console or ALC.settings.threshold_pc

    if current_pool >= limit_threshold or (IsConsoleUI() and current_lua >= limit_threshold) then
        local in_combat = IsUnitInCombat and IsUnitInCombat("player")
        if in_combat or IsUnitDead("player") then 
            if ALC.settings.show_ui then ALC.update_ui() end
            return 
        end

        ALC.is_mem_check_queued = true
        zo_callLater(function()
            ALC.is_mem_check_queued = false
            if ALC.mem_state == 1 then return end
            
            local still_in_combat = IsUnitInCombat and IsUnitInCombat("player")
            if still_in_combat or IsUnitDead("player") then 
                if ALC.settings.show_ui then ALC.update_ui() end
                return 
            end
            
            if check_type == "Menu" then
                local is_hud = SCENE_MANAGER:IsShowing("hud")
                local is_hudui = SCENE_MANAGER:IsShowing("hudui")
                local in_menu = SCENE_MANAGER and not (is_hud or is_hudui)
                if not in_menu then return end 
            end
            
            local recheck_pool = ALC.get_hybrid_memory_data()
            local recheck_lua = collectgarbage("count") / 1024
            if recheck_pool >= limit_threshold or (IsConsoleUI() and recheck_lua >= limit_threshold) then
                ALC.run_manual_cleanup()
                EVENT_MANAGER:UnregisterForUpdate(ALC.name .. "_Fallback")
                EVENT_MANAGER:RegisterForUpdate(ALC.name .. "_Fallback", 
                    ALC.settings.fallback_delay_sec * 1000, 
                    function() ALC.trigger_memory_check("Fallback", 0) end
                )
            end
        end, delay)
    else
        EVENT_MANAGER:UnregisterForUpdate(ALC.name .. "_Fallback")
        ALC.mem_state = 0
    end
end

function ALC.update_graph_visuals()
    local alc = ALC
    if not alc.settings.is_graph_enabled or not graph_window or graph_window:IsHidden() then
        return
    end
    
    if alc.settings.lite_mode and not alc.settings.show_graph_diags then return end
    alc.graph_data = alc.graph_data or {} 
        
    local is_lite = alc.settings.lite_mode
    local current_mb = IsConsoleUI() and alc.get_console_pool_mb() or alc.get_hybrid_memory_data()
    local current_lat = alc.settings.track_ping and GetLatency() or 0
    local fps = (alc.settings.track_fps or alc.settings.track_frametime) and GetFramerate() or 0
    local current_ft = fps > 0 and math.floor(1000 / fps) or 0
    local delta_mb = current_mb - last_graph_mb
    local gain_pop = (delta_mb > 0) and 1.0 or 0.3
    last_graph_mb = current_mb
    
    local drawing_peak_mb = IsConsoleUI() and 100 or 512
    
    if not is_lite then
        local peak_mb = IsConsoleUI() and 100 or 512
        for _, v in ipairs(alc.graph_data) do 
            if v > peak_mb then peak_mb = v end 
        end
        
        if current_mb > peak_mb then peak_mb = current_mb end
        table.insert(alc.graph_data, current_mb)
        if #alc.graph_data > max_points then table.remove(alc.graph_data, 1) end
        
        if alc.settings.track_ping then
            table.insert(graph_latency_pool, current_lat)
            if #graph_latency_pool > max_points then table.remove(graph_latency_pool, 1) end
        end
        
        if alc.settings.track_frametime then
            table.insert(graph_frametime_pool, current_ft)
            if #graph_frametime_pool > max_points then table.remove(graph_frametime_pool, 1) end
        end
        
        local lat_markers = IsConsoleUI() 
            and {0, 50, 100, 150, 200, 250, 300, 350} 
            or {0, 20, 60, 100, 125, 250, 375, 750, 1000}
            
        local function get_active_row(val, markers, max_rows)
            if val <= markers[1] then return 1 end
            if val >= markers[#markers] then return max_rows end
            for i = 1, #markers - 1 do
                if val >= markers[i] and val <= markers[i+1] then
                    local frac = (val - markers[i]) / (markers[i+1] - markers[i])
                    local start_row = ((i - 1) / (#markers - 1)) * max_rows
                    local end_row = (i / (#markers - 1)) * max_rows
                    local row = start_row + (frac * (end_row - start_row))
                    
                    local floorVal = math.floor(row)
                    local fracPart = row - floorVal
                    local roundedRow = (fracPart >= 0.5) and (floorVal + 1) or floorVal
                    return math.max(roundedRow, 1)
                end
            end
            return 1
        end
        
        local max_rows = 36
        for i = 1, #alc.graph_data do
            local val = alc.graph_data[i]
            local lat_val = graph_latency_pool[i]
            local ft_val = graph_frametime_pool[i]
            local prev_val = (i > 1) and alc.graph_data[i-1] or val
            
            local is_kb_shift = alc.settings.track_memory_gains 
                and (val - prev_val) > 0.001 
                and (val - prev_val) < 1.0
                
            local tail_alpha = (0.2 + 0.8 * (i / max_points))
            local final_alpha = (i == #alc.graph_data) and gain_pop or tail_alpha
            
            local active_blocks = math.max(math.floor((val / drawing_peak_mb) * max_rows), 1)
            local is_over_ceiling = val >= drawing_peak_mb
            if is_over_ceiling then active_blocks = max_rows end
            
            for j = 1, max_rows do
                local seg = graph_segments[i][j]
                if j == active_blocks then
                    local block_val = (j / max_rows) * drawing_peak_mb
                    local r, g, b = alc.get_gradient_color(block_val, drawing_peak_mb)
                    if is_over_ceiling then r, g, b = 1, 0, 0 end
                    seg:SetColor(r, g, b, final_alpha)
                    seg:SetHidden(false)
                elseif j == (active_blocks + 1) and is_kb_shift then
                    local kb_factor = math.min((val - prev_val) / 1.0, 1.0)
                    local kr, kg, kb = 0.5 + (0.5 * kb_factor), 0.2 * kb_factor, 0.5 + (0.5 * kb_factor)
                    seg:SetColor(kr, kg, kb, final_alpha)
                    seg:SetHidden(false)
                else 
                    seg:SetHidden(true) 
                end
            end
            
            if alc.settings.track_ping and graph_latency_dots[i] and lat_val then
                local lat_active = get_active_row(lat_val, lat_markers, max_rows)
                local seg = graph_segments[i][lat_active]
                if seg then
                    if lat_val <= 250 then
                        graph_latency_dots[i]:SetColor(1, 1, 0, final_alpha) 
                    elseif lat_val <= 375 then
                        graph_latency_dots[i]:SetColor(1.0, 0.08, 0.58, final_alpha) 
                    else
                        graph_latency_dots[i]:SetColor(0.93, 0.51, 0.93, final_alpha) 
                    end
                    graph_latency_dots[i]:ClearAnchors()
                    graph_latency_dots[i]:SetAnchor(CENTER, seg, CENTER, 0, 0)
                    graph_latency_dots[i]:SetHidden(false)
                else 
                    graph_latency_dots[i]:SetHidden(true) 
                end
            else 
                if graph_latency_dots[i] then graph_latency_dots[i]:SetHidden(true) end 
            end
            
            if alc.settings.track_frametime and graph_frametime_dots[i] and ft_val then
                local ft_active = get_active_row(ft_val, lat_markers, max_rows)
                local seg = graph_segments[i][ft_active]
                if seg then
                    graph_frametime_dots[i]:SetColor(0, 1, 1, final_alpha)
                    graph_frametime_dots[i]:ClearAnchors()
                    graph_frametime_dots[i]:SetAnchor(CENTER, seg, CENTER, 0, 0)
                    graph_frametime_dots[i]:SetHidden(false)
                else
                    graph_frametime_dots[i]:SetHidden(true)
                end
            else
                if graph_frametime_dots[i] then graph_frametime_dots[i]:SetHidden(true) end
            end
        end
        
        local markers = IsConsoleUI() 
            and {0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100} 
            or {0, 64, 128, 192, 256, 320, 384, 448, 512}
            
        if peak_mb > (IsConsoleUI() and 100 or 512) then 
            table.insert(markers, math.ceil(peak_mb)) 
        end
        
        for _, l in ipairs(graph_labels) do l:SetHidden(true) end
        for _, gl in ipairs(graph_grid_lines) do gl:SetHidden(true) end
        for _, l in ipairs(graph_labels_lat) do l:SetHidden(true) end
        
        for i, mark in ipairs(markers) do
            local lbl = graph_labels[i]
            local g_line = graph_grid_lines[i]
            if lbl and (mark <= peak_mb or mark == 0) then
                local y_offset = 180 - ((mark / peak_mb) * 180)
                alc.set_tag_alignment(lbl, y_offset)
                
                local m_color = "|c00FF00"
                if IsConsoleUI() then
                    if mark >= 100 then m_color = "|cFF0000"
                    elseif mark >= 60 then m_color = "|cFFA500" end
                else
                    if mark >= 512 then m_color = "|cFF0000"
                    elseif mark >= 320 then m_color = "|cFFA500" end
                end
                
                lbl:SetText(m_color .. mark .. "MB|r")
                lbl:SetHidden(false)
                if g_line then
                    g_line:ClearAnchors()
                    g_line:SetAnchor(LEFT, graph_window, TOPLEFT, 60, y_offset)
                    g_line:SetAnchor(RIGHT, graph_window, TOPLEFT, 300, y_offset)
                    g_line:SetHidden(false)
                end
            end
        end
        
        if alc.settings.track_ping or alc.settings.track_frametime then
            for i, mark in ipairs(lat_markers) do
                local lbl = graph_labels_lat[i]
                if lbl then
                    local y_offset = 180 - ((i - 1) * (180 / (#lat_markers - 1)))
                    lbl:ClearAnchors()
                    lbl:SetAnchor(RIGHT, graph_window, TOPLEFT, 55, y_offset - 6)
                    
                    local l_text = ""
                    if mark <= 250 then
                        l_text = string.format("|c00FFFF%d|r|cFFFF00ms|r", mark)
                    elseif mark <= 375 then
                        l_text = string.format("|cFF1493%d|r|c00FFFFms|r", mark)
                    else
                        l_text = string.format("|cEE82EE%d|r|c00FFFFms|r", mark)
                    end
                    
                    lbl:SetText(l_text)
                    lbl:SetHidden(false)
                end
            end
        end
        
        local x_vals = {"15s", "12s", "9s", "6s", "3s", "0s"}
        for i, l in ipairs(graph_labels_x) do 
            l:SetText(x_vals[i])
            l:SetHidden(false) 
        end
    end
    
    local current_time = GetFrameTimeMilliseconds()
    if not graph_last_diag_time or (current_time - graph_last_diag_time) >= 1000 then
        graph_last_diag_time = current_time
        local gain_mb = 0
        local gain_kb = 0
        
        local needs_math = alc.settings.show_graph_diags 
            or alc.settings.session_track_peak 
            or alc.settings.session_track_avg 
            or alc.settings.session_track_final
            or alc.settings.track_frametime
            
        if needs_math then
            graph_last_sec_mb = graph_last_sec_mb == 0 and current_mb or graph_last_sec_mb
            gain_mb = math.max(current_mb - graph_last_sec_mb, 0)
            graph_last_sec_mb = current_mb
            gain_kb = gain_mb * 1024
            
            if alc.settings.session_track_peak then
                if current_mb > session_peak_mb then session_peak_mb = current_mb end
                if gain_kb > stat_session_kb_max then stat_session_kb_max = gain_kb end
                if gain_mb > stat_session_mb_max then stat_session_mb_max = gain_mb end
                if alc.settings.track_ping and current_lat > stat_session_ping_max then 
                    stat_session_ping_max = current_lat 
                end
                if alc.settings.track_frametime and current_ft > stat_session_ft_max then 
                    stat_session_ft_max = current_ft 
                end
            end
            
            if alc.settings.session_track_avg then
                stat_session_ticks = stat_session_ticks + 1
                stat_session_kb_total = stat_session_kb_total + gain_kb
                stat_session_mb_total = stat_session_mb_total + gain_mb
                stat_session_current_mb_total = stat_session_current_mb_total + current_mb
                if alc.settings.track_ping then 
                    stat_session_ping_total = stat_session_ping_total + current_lat 
                end
                if alc.settings.track_frametime then 
                    stat_session_ft_total = stat_session_ft_total + current_ft 
                end
                if alc.settings.track_fps then 
                    stat_session_fps_total = stat_session_fps_total + fps 
                end
            end
            
            if alc.settings.session_track_final then
                stat_session_kb_final = gain_kb
                stat_session_mb_final = gain_mb
                if alc.settings.track_ping then stat_session_ping_final = current_lat end
                if alc.settings.track_frametime then stat_session_ft_final = current_ft end
                if alc.settings.track_fps then stat_session_fps_final = fps end
            end
            
            if alc.settings.track_frametime then
                alc.frametime_ticks = alc.frametime_ticks + 1
                alc.frametime_avg_accumulator = alc.frametime_avg_accumulator + current_ft
                
                if current_ft > alc.settings.prev_session_perf.ft_peak then
                    alc.settings.prev_session_perf.ft_peak = current_ft
                end
            end
        end
        
        if alc.settings.show_graph_diags then
            local limit = IsConsoleUI() and alc.settings.threshold_console or alc.settings.threshold_pc
            local pct = math.min((current_mb / limit) * 100, 100)
            local c_fps = "|c888888Off|r"; local c_drop = "|c888888Off|r"
            local c_ping = "|c888888Off|r"; local c_avg = "|c888888Off|r"
            local c_spike = "|c888888Off|r"
            local alc_status_color = alc.get_fixed_hard_cap_color(current_mb)
            
            if alc.settings.track_fps then
                if stat_baseline_fps == 0 or fps > stat_baseline_fps then
                    stat_baseline_fps = fps
                    stat_fps_stable_ticks = 0
                elseif math.abs(fps - stat_last_fps_raw) <= 2 then
                    stat_fps_stable_ticks = stat_fps_stable_ticks + 1
                    if stat_fps_stable_ticks >= 60 then 
                        stat_baseline_fps = fps
                        stat_fps_stable_ticks = 0 
                    end
                else 
                    stat_fps_stable_ticks = 0 
                end
                stat_last_fps_raw = fps
                
                stat_fps_count = stat_fps_count + 1
                stat_fps_total = stat_fps_total + fps
                local current_avg_fps = math.floor(stat_fps_total / stat_fps_count)
                
                local fps_drop = math.max(stat_baseline_fps - fps, 0)
                if alc.settings.session_track_peak and fps_drop > stat_session_fps_loss_max then 
                    stat_session_fps_loss_max = fps_drop 
                end
                if alc.settings.session_track_final then 
                    stat_session_fps_loss_final = fps_drop 
                end
                if alc.settings.session_track_avg then 
                    stat_session_fps_loss_total = stat_session_fps_loss_total + fps_drop 
                end
                
                if fps_drop > alc.settings.prev_session_perf.fps_loss_max then
                    alc.settings.prev_session_perf.fps_loss_max = fps_drop
                end
                
                c_fps = fps >= 50 and "|c00FF00" or (fps >= 30 and "|cFFA500" or "|cFF0000")
                local c_afps = current_avg_fps >= 50 and "|c00FF00" or "|cFF0000"
                c_drop = fps_drop <= 5 and "|c00FF00" or (fps_drop <= 15 and "|cFFA500" or "|cFF0000")
                
                diag_labels.fps:SetText(string.format("FPS: %s%d|r", c_fps, fps))
                diag_labels.avg_fps:SetText(string.format("Avg FPS: %s%d|r", c_afps, current_avg_fps))
                diag_labels.fps_drop:SetText(string.format("FPS Loss: %s-%d|r", c_drop, fps_drop))
            else 
                diag_labels.fps:SetText("FPS: Off")
                diag_labels.avg_fps:SetText("Avg FPS: Off")
                diag_labels.fps_drop:SetText("FPS Loss: Off") 
            end
            
            if alc.settings.track_frametime then
                local is_ft_spike = current_ft > 20
                local c_ft = is_ft_spike and "|c00FFFF" or "|c1E90FF"
                diag_labels.frametime:SetText(
                    string.format("|c00FFFFFrametime|r: %s%d ms|r", c_ft, current_ft)
                )
            else
                diag_labels.frametime:SetText("|c00FFFFFrametime|r: Off")
            end
            
            if alc.settings.track_ping then
                stat_ticks = stat_ticks + 1
                stat_total_ping = stat_total_ping + current_lat
                
                if stat_baseline_ping == 0 or current_lat < stat_baseline_ping then
                    stat_baseline_ping = current_lat
                    stat_ping_stable_ticks = 0
                elseif math.abs(current_lat - stat_last_ping_raw) <= 10 then
                    stat_ping_stable_ticks = stat_ping_stable_ticks + 1
                    if stat_ping_stable_ticks >= 60 then 
                        stat_baseline_ping = current_lat
                        stat_ping_stable_ticks = 0 
                    end
                else 
                    stat_ping_stable_ticks = 0 
                end
                stat_last_ping_raw = current_lat
                
                local current_spike = 0
                if current_lat > stat_baseline_ping + 50 then 
                    current_spike = current_lat - stat_baseline_ping 
                end
                
                local avg_ping = math.floor(stat_total_ping / stat_ticks)
                
                local function get_ping_color(val)
                    if val <= 250 then return "|cFFFF00" 
                    elseif val <= 375 then return "|cFF1493" 
                    else return "|cEE82EE" end 
                end
                
                c_ping = get_ping_color(current_lat)
                c_avg = get_ping_color(avg_ping)
                c_spike = get_ping_color(current_spike)
                
                diag_labels.ms:SetText(string.format("|cFFFF00ms|r: %s%d|r", c_ping, current_lat))
                diag_labels.avg_ms:SetText(string.format("Avg |cFFFF00ms|r: %s%d|r", c_avg, avg_ping))
                diag_labels.spike_pct:SetText(string.format("Spike: %s+%dms|r", c_spike, current_spike))
            else 
                diag_labels.ms:SetText("|cFFFF00ms|r: Off")
                diag_labels.avg_ms:SetText("Avg |cFFFF00ms|r: Off")
                diag_labels.spike_pct:SetText("Spike: Off") 
            end
            
            if alc.settings.track_memory_gains then
                diag_labels.kb:SetText(string.format("|cFF00FFAvg KB|r: %d", gain_kb))
                diag_labels.mb:SetText(string.format("|cFFFFFFAvg MB|r: %s%.2f|r", alc_status_color, gain_mb))
            else 
                diag_labels.kb:SetText("|cFF00FFAvg KB|r: Off")
                diag_labels.mb:SetText("|cFFFFFFAvg MB|r: Off") 
            end
            
            diag_labels.pct:SetText(string.format("Total: %s%d%%|r", alc_status_color, pct))
        end
        
        if is_lite then alc.update_history_text() end
    end
end

function ALC.save_session_history()
    if not ALC.settings.is_stats_log_enabled or session_peak_mb == 0 then return end
    
    local session_data = {
        date = GetDateStringFromTimestamp(GetTimeStamp()) .. " " .. GetTimeString(),
        has_peak = ALC.settings.session_track_peak, 
        has_avg = ALC.settings.session_track_avg,
        has_final = ALC.settings.session_track_final, 
        has_cleaned = ALC.settings.session_track_cleaned
    }
    
    if ALC.settings.session_track_peak then
        session_data.peak_mb = string.format("%.2f", session_peak_mb)
        session_data.peak_ping = stat_session_ping_max
        session_data.peak_fps_loss = stat_session_fps_loss_max
        session_data.peak_kb = stat_session_kb_max
        session_data.peak_ft = stat_session_ft_max
    end
    
    if ALC.settings.session_track_avg then
        session_data.avg_ping = stat_session_ticks > 0 
            and math.floor(stat_session_ping_total / stat_session_ticks) or 0
        session_data.avg_kb = stat_session_ticks > 0 
            and math.floor(stat_session_kb_total / stat_session_ticks) or 0
        session_data.avg_fps_loss = stat_session_ticks > 0 
            and math.floor(stat_session_fps_loss_total / stat_session_ticks) or 0
        session_data.avg_current_mb = stat_session_ticks > 0 
            and (stat_session_current_mb_total / stat_session_ticks) or 0
        session_data.avg_ft = stat_session_ticks > 0 
            and math.floor(stat_session_ft_total / stat_session_ticks) or 0
        session_data.avg_fps = stat_session_ticks > 0 
            and math.floor(stat_session_fps_total / stat_session_ticks) or 0
    end
    
    if ALC.settings.session_track_final then
        local current_mb = ALC.get_hybrid_memory_data()
        session_data.final_mb = string.format("%.2f", current_mb)
        session_data.final_ping = stat_session_ping_final
        session_data.final_fps_loss = stat_session_fps_loss_final
        session_data.final_kb = stat_session_kb_final
        session_data.final_ft = stat_session_ft_final
        session_data.final_fps = stat_session_fps_final
    end
    
    if ALC.settings.session_track_cleaned then
        if ALC.settings.is_enabled then 
            session_data.mem_cleaned_str = ALC.format_memory(ALC.session_mb_freed or 0)
        else 
            session_data.mem_cleaned_str = "OFF" 
        end
    end
    
    table.insert(ALC.settings.session_history, session_data)
    while #ALC.settings.session_history > 3 do 
        table.remove(ALC.settings.session_history, 1) 
    end
end

function ALC.format_history(entry)
    local lines = { string.format("|c00FFFF[%s]|r", entry.date or "?") }
    
    if entry.has_peak then
        table.insert(lines, string.format(
            "  |cFF0000Peak:|r %sMB | Latency: %s | FT: %s | FPS Loss: -%d | Gain: %dKB", 
            entry.peak_mb or "?", ALC.format_time(entry.peak_ping), ALC.format_time(entry.peak_ft), 
            entry.peak_fps_loss or 0, entry.peak_kb or 0
        ))
    end
    
    if entry.has_avg then
        table.insert(lines, string.format(
            "  |cFFA500Average:|r %sMB | Latency: %s | FT: %s | avg FPS: %d | FPS Loss: -%d | Gain: %dKB", 
            string.format("%.2f", entry.avg_current_mb or 0), ALC.format_time(entry.avg_ping), 
            ALC.format_time(entry.avg_ft), entry.avg_fps or 0, entry.avg_fps_loss or 0, entry.avg_kb or 0
        ))
    end
    
    if entry.has_final then
        table.insert(lines, string.format(
            "  |cFFFFFFFinal:|r %sMB | Latency: %s | FT: %s | avg FPS: %d | FPS Loss: -%d | Gain: %dKB", 
            entry.final_mb or "?", ALC.format_time(entry.final_ping), ALC.format_time(entry.final_ft), 
            entry.final_fps or 0, entry.final_fps_loss or 0, entry.final_kb or 0
        ))
    end
    
    if entry.has_cleaned then
        table.insert(lines, string.format("  |c00FFFFMemCleaned:|r %s", entry.mem_cleaned_str or "OFF"))
    end
    
    if not entry.has_peak and not entry.has_avg and not entry.has_final and not entry.has_cleaned then
        table.insert(lines, string.format("  |cFF0000Peak:|r %sMB", entry.peak or "?"))
    end
    
    return table.concat(lines, "\n")
end

function ALC.get_profiler_color(peak_ms)
    if peak_ms >= 500 then return "FF0000"
    elseif peak_ms >= 100 then return "FFA500"
    elseif peak_ms >= 20 then return "FFFF00"
    elseif peak_ms >= 5 then return "00FF00"
    elseif peak_ms >= 1 then return "FFFFFF"
    else return "888888" end
end

function ALC.update_history_text()
    if not history_label then return end
    
    local hist_txt = "|c00FFFF[Previous Session Statistics]|r\n"
    if #ALC.settings.session_history == 0 then 
        hist_txt = hist_txt .. "No data logged yet.\n" 
    else
        for i = 1, #ALC.settings.session_history do
            hist_txt = hist_txt .. ALC.format_history(ALC.settings.session_history[i]) .. "\n"
        end
    end
    
    local p_perf = ALC.settings.prev_session_perf
    if p_perf and p_perf.ft_ticks and p_perf.ft_ticks > 0 then
        local avg_ft = p_perf.ft_avg
        local prev_freed = ALC.settings.prev_session_mb_freed or 0
        local formattedFreed = format_dynamic_gain(prev_freed)
        
        hist_txt = hist_txt .. string.format(
            "\n|c00FFFF[Previous Session Performance]|r\n" ..
            "  Avg Frame: %d\n" .. 
            "  Max FPS Loss: -%d FPS\n" ..
            "  Frametime: %s | %s | %s\n" .. 
            "  Memory Freed: %s\n",
            p_perf.fps_avg or 0, p_perf.fps_loss_max or 0, ALC.format_time(p_perf.ft_final), 
            ALC.format_time(p_perf.ft_peak), ALC.format_time(avg_ft), formattedFreed
        )
    end
    
    local p_data = ALC.settings.saved_profiler_data
    if p_data and #p_data > 0 then
        hist_txt = hist_txt .. "|c00FFFF[Last Profiler Scan Top 10]|r\n"
        for i = 1, math.min(10, #p_data) do
            local mod = p_data[i]
            local color = ALC.get_profiler_color(mod.peak)
            hist_txt = hist_txt .. string.format(
                "  %d. %s |c%s[%s]|r\n",
                i, ALC.format_time(mod.peak), color, mod.name
            )
        end
    end
    
    history_label:SetText(hist_txt)
    
    if session_window then
        local text_w = history_label:GetTextWidth()
        local text_h = history_label:GetTextHeight()
        local min_width = IsConsoleUI() and 380 or 280
        session_window:SetDimensions(math.max(text_w + 20, min_width), math.max(text_h + 15, 60))
    end
end

function ALC.update_graph_anchor()
    if not graph_window then return end
    graph_window:ClearAnchors()
    if ALC.settings.is_graph_detached and ALC.settings.graph_x and ALC.settings.graph_y then
        graph_window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ALC.settings.graph_x, ALC.settings.graph_y)
    else
        graph_window:SetAnchor(TOPLEFT, ALC.ui_window, BOTTOMLEFT, 0, 5) 
    end
end

function ALC.update_session_anchor()
    if not session_window then return end
    session_window:ClearAnchors()
    if ALC.settings.session_ui_x and ALC.settings.session_ui_y then
        session_window:SetAnchor(
            TOPLEFT, GuiRoot, TOPLEFT, 
            ALC.settings.session_ui_x, ALC.settings.session_ui_y
        )
    else
        if graph_window and not graph_window:IsHidden() then 
            session_window:SetAnchor(TOPLEFT, graph_window, BOTTOMLEFT, 0, 15)
        else 
            session_window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 50, 400) 
        end
    end
end

function ALC.build_session_ui()
    if not session_window then
        session_window = WINDOW_MANAGER:CreateControl("ALC_SessionUI", GuiRoot, CT_TOPLEVELCONTROL)
        session_window:SetDimensions(700, 250)
        session_window:SetClampedToScreen(true) 
        session_window:SetMouseEnabled(true)
        session_window:SetMovable(not ALC.settings.is_session_locked)
        
        session_window:SetDrawTier(DT_HIGH)
        session_window:SetDrawLayer(DL_OVERLAY)
        session_window:SetDrawLevel(9000)
        
        if ALC.is_lca_valid then
            ALC.session_mover = LibCombatAlerts.MoveableControl:New(session_window)
            ALC.session_mover:RegisterCallback(ALC.name .. "_Sess", 2, function(new_pos)
                if type(new_pos.left) == "number" then ALC.settings.session_ui_x = new_pos.left end
                if type(new_pos.top) == "number" then ALC.settings.session_ui_y = new_pos.top end
            end)
        else
            session_window:SetHandler("OnMoveStop", function(ctrl)
                ALC.settings.session_ui_x = ctrl:GetLeft()
                ALC.settings.session_ui_y = ctrl:GetTop()
            end)
        end
        
        local bg = WINDOW_MANAGER:CreateControl(nil, session_window, CT_BACKDROP)
        bg:SetAnchorFill(session_window)
        bg:SetCenterColor(0, 0, 0, 0.4)
        bg:SetEdgeColor(0, 0, 0, 0)
        
        local is_pad = IsInGamepadPreferredMode()
        local font_hist = is_pad and "ZoFontGamepad18" or "$(CHAT_FONT)|14|soft-shadow-thin"
        
        history_label = WINDOW_MANAGER:CreateControl(nil, session_window, CT_LABEL)
        history_label:SetFont(font_hist)
        history_label:SetColor(0.8, 0.8, 0.8, 1)
        history_label:SetAnchor(TOPLEFT, session_window, TOPLEFT, 5, 5)
        
        local cd_name = "ALC_ProfilerTimer"
        ALC.profiler_timer_lbl = WINDOW_MANAGER:CreateControl(cd_name, session_window, CT_LABEL)
        ALC.profiler_timer_lbl:SetFont(font_hist)
        ALC.profiler_timer_lbl:SetColor(1, 0, 0, 1) 
        ALC.profiler_timer_lbl:SetAnchor(TOPLEFT, session_window, TOPLEFT, 160, 5)
        ALC.profiler_timer_lbl:SetText("")
        
        if not ALC.prof_scan_btn then
            local btn_name = "ALC_ProfScanBtn"
            local btn = WINDOW_MANAGER:CreateControlFromVirtual(
                btn_name, session_window, "ZO_DefaultButton"
            )
            local btn_w = is_pad and 90 or 75
            local btn_h = is_pad and 28 or 25
            btn:SetDimensions(btn_w, btn_h)
            btn:SetFont(is_pad and "ZoFontGamepad18" or "ZoFontGameSmall")
            btn:SetAnchor(TOPRIGHT, session_window, TOPRIGHT, -5, 5)
            btn:SetText(ALC.is_profiling and "Stop" or "Scan")
            btn:SetHandler("OnClicked", function() ALC.start_profiler() end)
            ALC.prof_scan_btn = btn
        end
        
        ALC.session_fragment = ZO_HUDFadeSceneFragment:New(session_window)
    end
    ALC.update_session_anchor()
    
    if session_window then
        ALC.update_ui_scenes()
        if ALC.settings.show_session_ui then ALC.update_history_text() end
    end
end

function ALC.update_ui_anchor()
    if not ALC.ui_window then return end
    ALC.ui_window:ClearAnchors()
    if ALC.settings.ui_x and ALC.settings.ui_y then
        ALC.ui_window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ALC.settings.ui_x, ALC.settings.ui_y)
    else
        if ZO_CompassFrame then 
            ALC.ui_window:SetAnchor(RIGHT, ZO_CompassFrame, LEFT, -40, 0)
        else 
            ALC.ui_window:SetAnchor(TOP, GuiRoot, TOP, -300, 40) 
        end
    end
    ALC.ui_window:SetDimensions(150, 40)
    
    if ALC.ui_label then
        local show_bar = ALC.settings.show_mem_ui_bar
        if show_bar and not ALC.percent_bar then
            local pct_bg = WINDOW_MANAGER:CreateControl("ALC_PercentBG", ALC.ui_label, CT_BACKDROP)
            pct_bg:SetDimensions(130, 8)
            pct_bg:SetAnchor(TOP, ALC.ui_label, BOTTOM, 0, 5)
            pct_bg:SetCenterColor(0, 0, 0, 0.4)
            pct_bg:SetEdgeColor(0, 0, 0, 1)
            ALC.percent_bg = pct_bg
            
            local pct_bar = WINDOW_MANAGER:CreateControl("ALC_PercentBar", pct_bg, CT_TEXTURE)
            pct_bar:SetAnchor(LEFT, pct_bg, LEFT, 0, 0)
            pct_bar:SetDimensions(0, 8)
            ALC.percent_bar = pct_bar
        end
        if ALC.percent_bg then ALC.percent_bg:SetHidden(not show_bar) end
        if ALC.percent_bar then ALC.percent_bar:SetHidden(not show_bar) end
    end
end

function ALC.update_ui()
    if not ALC.settings.show_ui then return end
    
    local current_lua = ALC.get_hybrid_memory_data()
    local pool_mb = ALC.get_console_pool_mb()
    local current_main = IsConsoleUI() and pool_mb or current_lua
    
    local user_limit = IsConsoleUI() and ALC.settings.threshold_console or ALC.settings.threshold_pc
    local _, fill_r, fill_g, fill_b = ALC.get_main_label_color(current_main, user_limit)
    local fill_pct = math.min((current_main / user_limit) * 100, 100)
    
    local status_color = ALC.get_fixed_hard_cap_color(current_main)
    
    local t_str = IsUnitInCombat("player") and "|cFF0000[ALC] (Combat)|r" or "|c00FFFF[ALC]|r"
    local m_str = ALC.format_memory(current_main)
    
    if IsConsoleUI() then
        local lua_str = string.format(" |c888888(LUA Mem: %.2f MB)|r", current_lua)
        ALC.ui_label:SetText(string.format("%s Mem Pool: %s%s%s", t_str, status_color, m_str, lua_str))
    else
        local pool_str = string.format(" |c888888(Mem Pool: %d MB)|r", math.floor(pool_mb))
        ALC.ui_label:SetText(string.format("%s LUA Mem: %s%s%s", t_str, status_color, m_str, pool_str))
    end
    
    if ALC.percent_bar then
        ALC.percent_bar:SetDimensions(130 * (fill_pct / 100), 8)
        ALC.percent_bar:SetColor(fill_r, fill_g, fill_b, 1)
    end
    ALC.ui_window:SetDimensions(ALC.ui_label:GetTextWidth() + 20, 40)
end

function ALC.create_ui()
    local win = WINDOW_MANAGER:CreateControl("AutoLuaCleanerUI", GuiRoot, CT_TOPLEVELCONTROL)
    win:SetClampedToScreen(true)
    win:SetMouseEnabled(true)
    win:SetMovable(not ALC.settings.is_ui_locked)
    win:SetHidden(true) 
    
    win:SetDrawTier(DT_HIGH)
    win:SetDrawLayer(DL_OVERLAY)
    win:SetDrawLevel(9000)
    
    ALC.ui_window = win
    ALC.update_ui_anchor()
    
    if ALC.is_lca_valid then
        ALC.ui_mover = LibCombatAlerts.MoveableControl:New(win)
        ALC.ui_mover:RegisterCallback(ALC.name .. "_UI", 2, function(new_pos)
            if type(new_pos.left) == "number" then ALC.settings.ui_x = new_pos.left end
            if type(new_pos.top) == "number" then ALC.settings.ui_y = new_pos.top end
        end)
    else
        win:SetHandler("OnMoveStop", function(ctrl) 
            ALC.settings.ui_x = ctrl:GetLeft()
            ALC.settings.ui_y = ctrl:GetTop()
        end)
    end
    
    local bg_tex = WINDOW_MANAGER:CreateControl("AutoLuaCleanerBG", win, CT_BACKDROP)
    bg_tex:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 0)
    bg_tex:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, 0, 0)
    bg_tex:SetCenterColor(0, 0, 0, 0.6)
    bg_tex:SetEdgeColor(0.6, 0.6, 0.6, 0.8)
    bg_tex:SetEdgeTexture(nil, 1, 1, 1, 0)
    
    local is_pad = IsInGamepadPreferredMode()
    local font_main = is_pad and "ZoFontGamepad22" or "ZoFontGameSmall"
    
    local text_lbl = WINDOW_MANAGER:CreateControl("AutoLuaCleanerLabel", win, CT_LABEL)
    text_lbl:SetFont(font_main)
    text_lbl:SetColor(1, 1, 1, 1)
    text_lbl:SetText("[ALC] Loading...")
    text_lbl:SetAnchor(CENTER, win, CENTER, 0, 0)
    ALC.ui_label = text_lbl
    
    ALC.ui_update_fn = function(ctrl, frame_time)
        if not ALC.settings.show_ui then return end
        if frame_time - ALC.last_ui_update < 1.0 then return end
        ALC.last_ui_update = frame_time
        ALC.update_ui()
    end
    ALC.hud_fragment = ZO_HUDFadeSceneFragment:New(win)
end

function ALC.update_ui_scenes()
    if not ALC.hud_fragment then return end
    local valid_scenes = {"hud", "hudui", "gamepad_hud"}
    
    for _, s_name in ipairs(valid_scenes) do
        local scene = SCENE_MANAGER:GetScene(s_name)
        if scene then 
            scene:RemoveFragment(ALC.hud_fragment)
            if ALC.graph_fragment then scene:RemoveFragment(ALC.graph_fragment) end
            if ALC.session_fragment then scene:RemoveFragment(ALC.session_fragment) end
        end
    end
    
    for _, s_name in ipairs(valid_scenes) do
        local hud_scene = SCENE_MANAGER:GetScene(s_name)
        if hud_scene then
            if ALC.settings.show_ui and not ALC.settings.is_ui_global then 
                hud_scene:AddFragment(ALC.hud_fragment) 
            end
            
            if ALC.graph_fragment and ALC.settings.is_graph_enabled and ALC.settings.show_ui then
                if not ALC.settings.is_graph_global then 
                    hud_scene:AddFragment(ALC.graph_fragment) 
                end
            end
            
            if ALC.session_fragment and ALC.settings.show_session_ui then
                if not ALC.settings.is_session_global then
                    hud_scene:AddFragment(ALC.session_fragment)
                end
            end
        end
    end
    
    local cur_scene = SCENE_MANAGER:GetCurrentScene()
    
    if ALC.ui_window then
        if not ALC.settings.show_ui then
            ALC.ui_window:SetHidden(true)
        else
            local should_show = ALC.settings.is_ui_global or (cur_scene and cur_scene:HasFragment(ALC.hud_fragment))
            ALC.ui_window:SetHidden(not should_show)
        end
    end
    
    if graph_window then
        if not (ALC.settings.is_graph_enabled and ALC.settings.show_ui) then
            graph_window:SetHidden(true)
        else
            local should_show = ALC.settings.is_graph_global or (cur_scene and cur_scene:HasFragment(ALC.graph_fragment))
            graph_window:SetHidden(not should_show)
        end
    end
    
    if session_window then
        if not ALC.settings.show_session_ui then
            session_window:SetHidden(true)
        else
            local should_show = ALC.settings.is_session_global or (cur_scene and cur_scene:HasFragment(ALC.session_fragment))
            session_window:SetHidden(not should_show)
        end
    end
end

function ALC.build_graph_ui()
    if not graph_window then
        graph_window = WINDOW_MANAGER:CreateControl("ALC_GraphUI", GuiRoot, CT_TOPLEVELCONTROL)
        graph_window:SetDimensions(360, 230)
        graph_window:SetClampedToScreen(true)
        graph_window:SetMouseEnabled(true)
        graph_window:SetMovable(not ALC.settings.is_graph_locked)
        graph_window:SetDrawTier(DT_HIGH)
        graph_window:SetDrawLayer(DL_OVERLAY)
        graph_window:SetDrawLevel(9000)
        
        ALC.update_graph_anchor()
        
        if ALC.is_lca_valid then
            ALC.graph_mover = LibCombatAlerts.MoveableControl:New(graph_window)
            ALC.graph_mover:RegisterCallback(ALC.name .. "_Graph", 2, function(new_pos)
                if type(new_pos.left) == "number" then ALC.settings.graph_x = new_pos.left end
                if type(new_pos.top) == "number" then ALC.settings.graph_y = new_pos.top end
                ALC.settings.is_graph_detached = true
            end)
        else
            graph_window:SetHandler("OnMoveStop", function(ctrl)
                ALC.settings.graph_x = ctrl:GetLeft()
                ALC.settings.graph_y = ctrl:GetTop()
                ALC.settings.is_graph_detached = true
            end)
        end
        
        local bg = WINDOW_MANAGER:CreateControl(nil, graph_window, CT_BACKDROP)
        bg:SetAnchor(TOPLEFT, graph_window, TOPLEFT, 60, 0)
        bg:SetAnchor(BOTTOMRIGHT, graph_window, TOPLEFT, 300, 180)
        bg:SetCenterColor(0, 0, 0, 0.4)
        bg:SetEdgeColor(0, 0, 0, 0)
        ALC.graph_bg = bg
        
        local is_pad = IsInGamepadPreferredMode()
        local font_lbl = is_pad and "ZoFontGamepad18" or "$(CHAT_FONT)|14|soft-shadow-thin"
        local font_diag = is_pad and "ZoFontGamepad18" or "$(CHAT_FONT)|12|soft-shadow-thin"
        
        ALC.graph_data = ALC.graph_data or {}
        local col_w = 240 / max_points
        local max_rows = 36
        local row_h = 180 / max_rows 
        
        for i = 1, max_points do
            graph_segments[i] = {}
            for j = 1, max_rows do
                local seg = WINDOW_MANAGER:CreateControl(nil, graph_window, CT_TEXTURE)
                seg:SetAnchor(BOTTOMLEFT, bg, BOTTOMLEFT, (i - 1) * col_w, (j - 1) * row_h * -1)
                seg:SetDimensions(col_w - 1, row_h - 1)
                seg:SetHidden(true)
                table.insert(graph_segments[i], seg)
            end
            
            graph_latency_dots[i] = WINDOW_MANAGER:CreateControl(nil, graph_window, CT_TEXTURE)
            graph_latency_dots[i]:SetDimensions(3, 3)
            graph_latency_dots[i]:SetColor(1.0, 0.08, 0.58, 1)
            graph_latency_dots[i]:SetHidden(true)
            
            graph_frametime_dots[i] = WINDOW_MANAGER:CreateControl(nil, graph_window, CT_TEXTURE)
            graph_frametime_dots[i]:SetDimensions(3, 3)
            graph_frametime_dots[i]:SetHidden(true)
        end
        
        graph_grid_lines = {}
        graph_grid_lines_v = {}
        graph_labels = {}
        graph_labels_lat = {}
        
        for i = 1, 12 do
            local gl = WINDOW_MANAGER:CreateControl(nil, graph_window, CT_LINE)
            gl:SetThickness(1); gl:SetColor(1, 1, 1, 0.15); gl:SetHidden(true)
            gl:SetAnchor(LEFT, bg, TOPLEFT, 0, (i-1)*(180/12))
            gl:SetAnchor(RIGHT, bg, TOPLEFT, 240, (i-1)*(180/12))
            table.insert(graph_grid_lines, gl)
            
            local l = WINDOW_MANAGER:CreateControl(nil, graph_window, CT_LABEL)
            l:SetFont(font_lbl); l:SetDimensions(55, 20)
            l:SetHorizontalAlignment(TEXT_ALIGN_LEFT); l:SetHidden(true)
            table.insert(graph_labels, l)
            
            local lat_l = WINDOW_MANAGER:CreateControl(nil, graph_window, CT_LABEL)
            lat_l:SetFont(font_lbl); lat_l:SetDimensions(55, 20)
            lat_l:SetHorizontalAlignment(TEXT_ALIGN_CENTER) 
            lat_l:SetColor(0, 1, 1, 1)
            lat_l:SetHidden(true)
            lat_l:SetAnchor(LEFT, bg, LEFT, -60, (i-1)*(180/12) - 6)
            table.insert(graph_labels_lat, lat_l)
        end
        
        for i = 1, 6 do
            local glv = WINDOW_MANAGER:CreateControl(nil, graph_window, CT_LINE)
            glv:SetThickness(1); glv:SetColor(1, 1, 1, 0.15)
            glv:SetAnchor(TOPLEFT, bg, TOPLEFT, (i-1)*48, 0)
            glv:SetAnchor(BOTTOMRIGHT, bg, BOTTOMLEFT, (i-1)*48, 0)
            table.insert(graph_grid_lines_v, glv)
            
            local l = WINDOW_MANAGER:CreateControl(nil, graph_window, CT_LABEL)
            l:SetFont(font_lbl); l:SetDimensions(30, 20)
            l:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            l:SetAnchor(TOP, bg, BOTTOMLEFT, (i-1)*48, 2)
            table.insert(graph_labels_x, l)
        end
        
        local diag_win = WINDOW_MANAGER:CreateControl(nil, graph_window, CT_CONTROL)
        diag_win:SetDimensions(100, 168)
        diag_win:SetDrawLevel(5)
        ALC.diag_win = diag_win 
        
        local function make_lbl(name, y_off, text)
            local l = WINDOW_MANAGER:CreateControl(name, diag_win, CT_LABEL)
            l:SetFont(font_diag)
            l:SetAnchor(TOPLEFT, diag_win, TOPLEFT, 0, y_off)
            l:SetText(text)
            return l
        end
        
        diag_labels.pct = make_lbl("ALC_GraphPct", 0, "Total")
        diag_labels.fps = make_lbl("ALC_GraphFps", 14, "FPS")
        diag_labels.avg_fps = make_lbl("ALC_GraphAvgFps", 28, "Avg FPS")
        diag_labels.fps_drop = make_lbl("ALC_GraphFpsDrop", 42, "FPS Loss")
        diag_labels.frametime = make_lbl("ALC_GraphFT", 56, "|c00FFFFFrametime|r")
        diag_labels.ms = make_lbl("ALC_GraphMs", 70, "|cFFFF00ms|r")
        diag_labels.avg_ms = make_lbl("ALC_GraphAvgMs", 84, "Avg |cFFFF00ms|r")
        diag_labels.spike_pct = make_lbl("ALC_GraphSpikePct", 98, "Spike")
        diag_labels.kb = make_lbl("ALC_GraphKb", 112, "|cFF00FFAvg KB|r")
        diag_labels.mb = make_lbl("ALC_GraphMb", 126, "|cFFFFFFAvg MB|r")
        
        ALC.graph_fragment = ZO_HUDFadeSceneFragment:New(graph_window)
    end
    
    local is_lite = ALC.settings.lite_mode
    local is_diagnostics_on = ALC.settings.show_graph_diags
    
    if ALC.diag_win then
        ALC.diag_win:ClearAnchors()
        if is_lite then 
            ALC.diag_win:SetAnchor(TOPLEFT, graph_window, TOPLEFT, 65, 5) 
        else 
            ALC.diag_win:SetAnchor(TOPLEFT, ALC.graph_bg, TOPLEFT, 5, 15) 
        end
        ALC.diag_win:SetHidden(not is_diagnostics_on)
    end
    
    if ALC.graph_bg then ALC.graph_bg:SetHidden(is_lite) end
    if is_lite then
        for _, seg in ipairs(graph_segments) do 
            for _, s in ipairs(seg) do s:SetHidden(true) end 
        end
        for _, dt in ipairs(graph_latency_dots) do dt:SetHidden(true) end
        for _, ft in ipairs(graph_frametime_dots) do ft:SetHidden(true) end
        for _, gl in ipairs(graph_grid_lines) do gl:SetHidden(true) end
        for _, glv in ipairs(graph_grid_lines_v) do glv:SetHidden(true) end
        for _, l in ipairs(graph_labels) do l:SetHidden(true) end
        for _, l in ipairs(graph_labels_lat) do l:SetHidden(true) end
        for _, l in ipairs(graph_labels_x) do l:SetHidden(true) end
    end
    ALC.update_session_anchor()
end

function ALC.show_missing_library_warning()
    local lam_ver, lam_en, lca_ver, lca_en = ALC.get_settings_library()
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
    
    if not ALC.settings.has_shown_lib_warning_008 then
        local dialog_id = "ALC_MISSING_LIBRARY_WARN"
        local popup_title = "|cFF0000ALC - Optional Dependency Alert|r"
        local popup_body = "For full functionality, please update or install and enable:\n\n" .. table.concat(alerts, "\n")
                           
        local function on_ack()
            ALC.settings.has_shown_lib_warning_008 = true
            local tick_ms = GetGameTimeMilliseconds()
            if (tick_ms - ALC.last_priority_save_time) >= 900000 then
                GetAddOnManager():RequestAddOnSavedVariablesPrioritySave(ALC.name)
                ALC.last_priority_save_time = tick_ms
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

    local chat_msg = "|cFF0000[ALC Error]|r " .. csa_msg
    
    zo_callLater(function()
        if show_chat and CHAT_SYSTEM then CHAT_SYSTEM:AddMessage(chat_msg) end
        
        if show_csa and CENTER_SCREEN_ANNOUNCE then
            local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
            params:SetText("|cFF0000[ALC Error]|r " .. csa_msg)
            params:SetLifespanMS(10000)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
        end
    end, 4000)
end

function ALC.parse_profiler_data()
    local addon_times = {}
    local path_cache = {}
    local valid_cache = {}
    
    if not GetScriptProfilerNumFrames then
        return {{ name = "API Error", peak = 0 }}
    end
    
    local num_frames = GetScriptProfilerNumFrames()
    local parse_start_time = GetGameTimeMilliseconds()
    
    for f = 1, num_frames do
        if IsConsoleUI() and (GetGameTimeMilliseconds() - parse_start_time) > 750 then
            if CHAT_SYSTEM then CHAT_SYSTEM:AddMessage("|cFF0000[ALC]|r Console CPU Limit Reached: Partial Scan Results Generated.") end
            break
        end
        
        local num_rec = GetScriptProfilerFrameNumRecords(f)
        for r = 1, num_rec do
            local rec_idx, start_ns, end_ns, _, rec_type = GetScriptProfilerRecordInfo(f, r)
            
            if rec_type == SCRIPT_PROFILER_RECORD_DATA_TYPE_CLOSURE then
                local _, f_path, _ = GetScriptProfilerClosureInfo(rec_idx)
                if f_path then
                    local mod_name = path_cache[f_path]
                    if mod_name == nil then
                        mod_name = string.match(f_path, "user:/AddOns/([^/]+)/")
                        if not mod_name and string.find(f_path, "EsoUI") then mod_name = "esoui" end
                        path_cache[f_path] = mod_name or false
                    end
                    
                    if mod_name and mod_name ~= "esoui" then
                        local is_valid = valid_cache[mod_name]
                        if is_valid == nil then
                            is_valid = true
                            if not ALC.settings.can_profile_self and mod_name == ALC.name then 
                                is_valid = false 
                            end
                            if not ALC.settings.include_esoprofiler and mod_name:lower() == "esoprofiler" then 
                                is_valid = false 
                            end
                            local m_name_lower = mod_name:lower()
                            local is_lib = string.find(m_name_lower, "lib")
                            if ALC.settings.exclude_libs and is_lib then 
                                is_valid = false 
                            end
                            if is_lib and ALC.settings.specific_lib_excludes[mod_name] then 
                                is_valid = false 
                            end
                            if not is_lib and ALC.settings.specific_addon_excludes[mod_name] then 
                                is_valid = false 
                            end
                            valid_cache[mod_name] = is_valid
                        end
                        
                        local duration_ms = (end_ns - start_ns) / 1000000
                        if is_valid and duration_ms > 0 then
                            addon_times[mod_name] = (addon_times[mod_name] or 0) + duration_ms
                        end
                    end
                end
            end
        end
    end
    
    local sorted = {}
    for name, time in pairs(addon_times) do
        table.insert(sorted, { name = name, peak = time })
    end
    table.sort(sorted, function(a, b) return a.peak > b.peak end)
    
    local top_all = {}
    for i = 1, #sorted do
        top_all[i] = {
            name = sorted[i].name,
            peak = math.floor(sorted[i].peak * 100) / 100
        }
    end
    
    if #top_all == 0 then table.insert(top_all, { name = "None Scanned", peak = 0 }) end
    return top_all
end

function ALC.stop_profiler()
    if not ALC.is_profiling then return end
    
    EVENT_MANAGER:UnregisterForUpdate("ALC_ProfilerCheck")
    StopScriptProfiler()
    ALC.is_profiling = false
    
    if ALC.prof_scan_btn then ALC.prof_scan_btn:SetText("Scan") end
    
    local function process_data()
        ALC.settings.saved_profiler_data = ALC.parse_profiler_data()
        GetAddOnManager():RequestAddOnSavedVariablesPrioritySave(ALC.name)
        ALC.last_priority_save_time = GetGameTimeMilliseconds()
        
        local p_data = ALC.settings.saved_profiler_data
        
        if not p_data or #p_data == 0 or (p_data[1] and p_data[1].name == "None Scanned") then
            d("|c00FFFF[ALC Profiler]|r No data")
            ALC.safe_csa("|c00FFFFNo data|r", 90)
        else
            d("|c00FFFF[ALC Profiler Full Results]|r")
            for i, mod in ipairs(p_data) do
                local formatted = ALC.format_time(mod.peak)
                local color = ALC.get_profiler_color(mod.peak)
                d(string.format("  %d. %s |c%s[%s]|r", i, formatted, color, mod.name))
            end
            
            local top = p_data[1]
            local formatted = ALC.format_time(top.peak)
            local color = ALC.get_profiler_color(top.peak)
            local msg = string.format("|c00FFFFTop Load:|r %s |c%s[%s]|r", formatted, color, top.name)
            ALC.safe_csa(msg, 90)
        end
        
        if ALC.settings.show_session_ui then ALC.update_history_text() end
        if ALC.profiler_timer_lbl then ALC.profiler_timer_lbl:SetText("") end
        
        if IsConsoleUI() then
            d("|cFF0000[ALC]|r Console UI will reload in 5 seconds to flush memory...")
            zo_callLater(function() ReloadUI("ingame") end, 5000)
        end
    end

    if IsUnitInCombat and IsUnitInCombat("player") then
        if ALC.profiler_timer_lbl then ALC.profiler_timer_lbl:SetText("Waiting...") end
        d("|c00FFFF[ALC]|r Scan finished. Waiting for combat to end to process data...")
        EVENT_MANAGER:RegisterForEvent(ALC.name .. "_ProfCom", EVENT_PLAYER_COMBAT_STATE, 
            function(event_code, in_combat)
                if not in_combat then
                    EVENT_MANAGER:UnregisterForEvent(ALC.name .. "_ProfCom", EVENT_PLAYER_COMBAT_STATE)
                    local cd = 5
                    if ALC.profiler_timer_lbl then 
                        ALC.profiler_timer_lbl:SetText(string.format("(%ds)", cd)) 
                    end
                    EVENT_MANAGER:RegisterForUpdate(ALC.name .. "_ProfWait", 1000, function()
                        cd = cd - 1
                        if ALC.profiler_timer_lbl then 
                            ALC.profiler_timer_lbl:SetText(string.format("(%ds)", cd)) 
                        end
                        if cd <= 0 then
                            EVENT_MANAGER:UnregisterForUpdate(ALC.name .. "_ProfWait")
                            process_data()
                        end
                    end)
                end
            end
        )
    else
        process_data()
    end
end

function ALC.start_profiler()
    if ALC.is_profiling then 
        ALC.stop_profiler() 
        return 
    end
    if not ALC.settings.is_profiler_enabled then return end
    
    ALC.is_profiling = true
    StartScriptProfiler()
    d("|c00FFFF[ALC]|r Profiler Module started.")
    
    if ALC.prof_scan_btn then ALC.prof_scan_btn:SetText("Stop") end
    
    local is_console = IsConsoleUI()
    ALC.profiler_ticks = is_console and 30 or 60
    
    if ALC.profiler_timer_lbl then 
        ALC.profiler_timer_lbl:SetText(string.format("(%ds)", ALC.profiler_ticks)) 
    end
    
    EVENT_MANAGER:RegisterForUpdate("ALC_ProfilerCheck", 1000, function()
        if ALC.profiler_ticks > 0 then
            ALC.profiler_ticks = ALC.profiler_ticks - 1
            if ALC.profiler_timer_lbl then
                ALC.profiler_timer_lbl:SetText(string.format("(%ds)", ALC.profiler_ticks))
            end
            if ALC.profiler_ticks == 0 then ALC.stop_profiler() end
        end
        
        if is_console and ALC.get_hybrid_memory_data() >= 80.0 then
            d("|cFF0000[ALC] Critical memory usage! Profiler stopped early to prevent crash.|r")
            ALC.safe_csa("|cFF0000Critical memory! Profiler stopped.|r", 90)
            ALC.profiler_ticks = 0
            ALC.stop_profiler()
        end
    end)
end

function ALC.integrate_with_perm_memento()
    local pm_core = _G["PermMementoCore"]
    if pm_core and type(pm_core) == "table" and pm_core.settings then
        pm_core.settings.is_auto_cleanup = false
        pm_core.settings.is_csa_cleanup_enabled = false
        EVENT_MANAGER:UnregisterForUpdate(pm_core.name .. "_MemFallback")
    end
end

function ALC.init(event_code, addon_name)
    if addon_name ~= ALC.name then return end
    EVENT_MANAGER:UnregisterForEvent(ALC.name, EVENT_ADD_ON_LOADED)
    
    local active_world = GetWorldName() or "Default"
    local sv_name = "AutoLuaCleaner"
    local account = GetDisplayName()

    if _G[sv_name] and _G[sv_name][active_world] and _G[sv_name][active_world][account] then
        local old_data = _G[sv_name][active_world][account]["AccountWide"]
        if old_data then
            _G[sv_name]["Default"] = _G[sv_name]["Default"] or {}
            _G[sv_name]["Default"][account] = _G[sv_name]["Default"][account] or {}
            _G[sv_name]["Default"][account]["$AccountWide"] = _G[sv_name]["Default"][account]["$AccountWide"] or {}
            _G[sv_name]["Default"][account]["$AccountWide"][active_world] = _G[sv_name]["Default"][account]["$AccountWide"][active_world] or {}
            
            for k, v in pairs(old_data) do
                _G[sv_name]["Default"][account]["$AccountWide"][active_world][k] = v
            end
            _G[sv_name][active_world] = nil
        end
    end

    ALC.settings = ZO_SavedVars:NewAccountWide(
        sv_name, 1, active_world, ALC.defaults
    )
    ALC.migrate_data()

    local lam_ver, lam_en, lca_ver, lca_en = ALC.get_settings_library()

    local is_lam_ok = (lam_en and lam_ver >= 30)
    ALC.is_lca_valid = (LibCombatAlerts ~= nil and lca_en and lca_ver >= 7010)

    if not is_lam_ok or not ALC.is_lca_valid then 
        ALC.show_missing_library_warning() 
    end
    
    if not ALC.settings.install_date then
        local raw_d = GetDate()
        if raw_d and type(raw_d) == "number" then raw_d = tostring(raw_d) end
        if raw_d and string.len(raw_d) == 8 then 
            ALC.settings.install_date = string.sub(raw_d, 1, 4) .. "/" .. 
                string.sub(raw_d, 5, 6) .. "/" .. string.sub(raw_d, 7, 8)
        else 
            ALC.settings.install_date = GetDateStringFromTimestamp(GetTimeStamp()) 
        end
        d("|c00FFFF[ALC]|r Initial installation date recorded.")
    end
    
    local s_avg_acc = ALC.frametime_avg_accumulator or 0
    local s_ticks = ALC.frametime_ticks or 0
    
    if s_ticks > 0 then
        local current_fps = GetFramerate()
        local ft_final = current_fps > 0 and math.floor(1000 / current_fps) or 0
        local avg_ft = math.floor(s_avg_acc / s_ticks)
        
        ALC.settings.prev_session_perf.ft_ticks = s_ticks
        ALC.settings.prev_session_perf.ft_avg = avg_ft
        ALC.settings.prev_session_perf.ft_final = ft_final
    end
    
    ALC.frametime_avg_accumulator = 0
    ALC.frametime_ticks = 0
    ALC.session_cleanups = 0
    ALC.session_mb_freed = 0
    
    stat_session_ft_max = 0
    stat_session_ft_final = 0
    stat_session_ft_total = 0
    stat_session_fps_total = 0
    stat_session_fps_final = 0
    
    local p_data = ALC.settings.saved_profiler_data
    if p_data and p_data[1] and p_data[1].peak and p_data[1].peak > 0 then
        ALC.settings.prev_session_perf.p_scan_occured = true
        ALC.settings.prev_session_perf.p_scan_peak = p_data[1].peak
        ALC.settings.prev_session_perf.p_scan_name = p_data[1].name
    else
        ALC.settings.prev_session_perf.p_scan_occured = false
    end
    
    ALC.settings.prev_session_cleanups = ALC.settings.last_session_cleanups or 0
    ALC.settings.prev_session_mb_freed = ALC.settings.last_session_mb_freed or 0
    ALC.settings.last_session_cleanups = 0
    ALC.settings.last_session_mb_freed = 0
    
    if not ALC.settings.version_history then ALC.settings.version_history = {} end
    local hist_len = #ALC.settings.version_history
    if hist_len == 0 or ALC.settings.version_history[hist_len] ~= ALC.version then 
        table.insert(ALC.settings.version_history, ALC.version)
        if #ALC.settings.version_history > 3 then 
            table.remove(ALC.settings.version_history, 1) 
        end 
        
        ALC.settings.saved_profiler_data = {}
        if CHAT_SYSTEM then 
            CHAT_SYSTEM:AddMessage("|c00FFFF[ALC]|r Version updated. Old profiler scans wiped.") 
        end
    end
    
    ALC.settings.prev_session_perf.ft_peak = 0
    ALC.settings.prev_session_perf.fps_loss_max = 0
    
    ALC.create_ui()
    ALC.build_lam2_menu()
    
    if not IsConsoleUI() then ALC.refresh_stats_tracker() end
    ALC.toggle_core_events()
    ALC.toggle_ui_update()
    ALC.build_session_ui()
    
    EVENT_MANAGER:RegisterForEvent(ALC.name, EVENT_PLAYER_ACTIVATED, function() 
        ALC.integrate_with_perm_memento()
        ALC.trigger_memory_check("ZoneLoad", 5000) 
    end)

    SLASH_COMMANDS["/alc"] = function(raw_arg)
        local parsed_cmd = raw_arg:lower()
        if parsed_cmd == "" then
            local sl_cmds = {
                "|c00FF00Available ALC Commands:|r\n", 
                "|c00FFFF/alcon|r |cFFD700- Toggle Auto Cleanup|r\n", 
                "|c00FFFF/alcui|r |cFFD700- Toggle Memory UI|r\n",
                "|c00FFFF/alclock|r |cFFD700- Lock/Unlock UI|r\n", 
                "|c00FFFF/alcreset|r |cFFD700- Reset UI position|r\n", 
                "|c00FFFF/alcgraph|r |cFFD700- Toggle Memory Graph|r\n",
                "|c00FFFF/alcgraphlock|r |cFFD700- Lock/Unlock Graph|r\n", 
                "|c00FFFF/alclite|r |cFFD700- Toggle Lite Mode|r\n", 
                "|c00FFFF/alcdiags|r |cFFD700- Toggle Graph Diagnostics|r\n",
                "|c00FFFF/alcbar|r |cFFD700- Toggle Memory UI Bar|r\n", 
                "|c00FFFF/alcfps|r |cFFD700- Toggle FPS Tracking|r\n", 
                "|c00FFFF/alcping|r |cFFD700- Toggle Latency Tracking|r\n",
                "|c00FFFF/alcframetime|r |cFFD700- Toggle Frametime Tracking|r\n",
                "|c00FFFF/alcgains|r |cFFD700- Toggle KB/MB Tracking|r\n", 
                "|c00FFFF/alcsession|r |cFFD700- Toggle Session UI|r\n", 
                "|c00FFFF/alcsessionlock|r |cFFD700- Lock Session UI|r\n",
                "|c00FFFF/alcsessionreset|r |cFFD700- Reset Session UI|r\n", 
                "|c00FFFF/alccsa|r |cFFD700- Toggle Announcements|r\n", 
                "|c00FFFF/alcstats|r |cFFD700- Toggle Saving Statistics|r\n",
                "|c00FFFF/alcstatpeak|r |cFFD700- Toggle Session Peak Logs|r\n", 
                "|c00FFFF/alcstatavg|r |cFFD700- Toggle Session Avg Logs|r\n",
                "|c00FFFF/alcstatfinal|r |cFFD700- Toggle Session Final Logs|r\n", 
                "|c00FFFF/alcstatclean|r |cFFD700- Toggle Session Clean Logs|r\n",
                "|c00FFFF/alcprofile|r |cFFD700- Toggle Profiler Module|r\n",
                "|c00FFFF/alcself|r |cFFD700- Toggle ALC in Profiler Scan|r\n",
                "|c00FFFF/alclibs|r |cFFD700- Toggle Library Filtering|r\n",
                "|c00FFFF/alcstart|r |cFFD700- Start " .. (IsConsoleUI() and "30s" or "60s") .. " Profiler Data Gather|r\n",
                "|c00FFFF/alcprostop|r |cFFD700- Stop Profiler Scan|r\n",
                "|c00FFFF/alcprolist|r |cFFD700- List Profiler Results to Chat|r\n",
                "|c00FFFF/alcdelvars|r |cFFD700- Reset ALL settings to defaults|r\n"
            }
            if not IsConsoleUI() then 
                table.insert(sl_cmds, "|c00FFFF/alclogs|r |cFFD700- Toggle Chat Logs|r\n") 
            end
            table.insert(sl_cmds, "|c00FFFF/alcclean|r |cFFD700- Force manual Lua cleanup|r")
            
            if CHAT_SYSTEM then 
                CHAT_SYSTEM:AddMessage("|c00FFFF[ALC]|r\n" .. table.concat(sl_cmds)) 
            end
            return
        end
    end
    SLASH_COMMANDS["/autoluaclean"] = SLASH_COMMANDS["/alc"]

    SLASH_COMMANDS["/alcon"] = function() 
        ALC.settings.is_enabled = not ALC.settings.is_enabled
        ALC.toggle_core_events() 
    end
    SLASH_COMMANDS["/alcenable"] = SLASH_COMMANDS["/alcon"]
    
    SLASH_COMMANDS["/alcui"] = function() 
        ALC.settings.show_ui = not ALC.settings.show_ui
        ALC.toggle_ui_update() 
    end
    SLASH_COMMANDS["/alctoggleui"] = SLASH_COMMANDS["/alcui"]
    
    SLASH_COMMANDS["/alclock"] = function() 
        ALC.settings.is_ui_locked = not ALC.settings.is_ui_locked
        if ALC.ui_window then ALC.ui_window:SetMovable(not ALC.settings.is_ui_locked) end 
    end
    SLASH_COMMANDS["/alcuilock"] = SLASH_COMMANDS["/alclock"]
    
    SLASH_COMMANDS["/alcreset"] = function() 
        ALC.settings.ui_x = nil
        ALC.settings.ui_y = nil
        ALC.update_ui_anchor() 
    end
    SLASH_COMMANDS["/alcuireset"] = SLASH_COMMANDS["/alcreset"]
    
    SLASH_COMMANDS["/alccsa"] = function() 
        ALC.settings.is_csa_enabled = not ALC.settings.is_csa_enabled 
    end
    SLASH_COMMANDS["/alctogglecsa"] = SLASH_COMMANDS["/alccsa"]
    
    SLASH_COMMANDS["/alcstats"] = function() 
        ALC.settings.track_stats = not ALC.settings.track_stats
        ALC.refresh_stats_tracker() 
    end
    SLASH_COMMANDS["/alctogglestats"] = SLASH_COMMANDS["/alcstats"]

    if not IsConsoleUI() then 
        SLASH_COMMANDS["/alclogs"] = function() 
            ALC.settings.is_log_enabled = not ALC.settings.is_log_enabled 
        end
        SLASH_COMMANDS["/alcchatlogs"] = SLASH_COMMANDS["/alclogs"] 
    end

    SLASH_COMMANDS["/alcclean"] = function() ALC.run_manual_cleanup(true) end
    SLASH_COMMANDS["/alccleanup"] = SLASH_COMMANDS["/alcclean"]

    if ALC.settings.is_stats_log_enabled then
        EVENT_MANAGER:RegisterForUpdate("ALC_StatsTick", 60000, function() 
            ALC.check_session_peak() 
        end) 
    end
    
    EVENT_MANAGER:RegisterForEvent("ALC_LogOut", EVENT_PLAYER_DEACTIVATED, function() 
        ALC.save_session_history() 
    end)

    SLASH_COMMANDS["/alcgraph"] = function() 
        ALC.settings.is_graph_enabled = not ALC.settings.is_graph_enabled
        ALC.toggle_ui_update() 
    end
    
    SLASH_COMMANDS["/alcgraphreset"] = function() 
        ALC.settings.graph_x = nil
        ALC.settings.graph_y = nil
        ALC.settings.is_graph_detached = false
        if graph_window and ALC.ui_window then 
            graph_window:ClearAnchors()
            graph_window:SetAnchor(TOPLEFT, ALC.ui_window, BOTTOMLEFT, 0, 5) 
        end 
    end
    
    SLASH_COMMANDS["/alcgraphlock"] = function() 
        ALC.settings.is_graph_locked = not ALC.settings.is_graph_locked
        if graph_window then graph_window:SetMovable(not ALC.settings.is_graph_locked) end 
    end
    
    SLASH_COMMANDS["/alclite"] = function() 
        ALC.settings.lite_mode = not ALC.settings.lite_mode
        if ALC.settings.lite_mode then ALC.settings.show_graph_diags = true end
        ALC.build_graph_ui() 
    end
    
    SLASH_COMMANDS["/alcdiags"] = function()
        ALC.settings.show_graph_diags = not ALC.settings.show_graph_diags
        ALC.build_graph_ui() 
    end
    
    SLASH_COMMANDS["/alcbar"] = function() 
        ALC.settings.show_mem_ui_bar = not ALC.settings.show_mem_ui_bar
        ALC.update_ui_anchor() 
    end
    
    SLASH_COMMANDS["/alcfps"] = function() 
        ALC.settings.track_fps = not ALC.settings.track_fps
        stat_baseline_fps = 0
        stat_fps_stable_ticks = 0
        stat_last_fps_raw = 0
        ALC.build_graph_ui() 
    end
    
    SLASH_COMMANDS["/alcping"] = function() 
        ALC.settings.track_ping = not ALC.settings.track_ping
        stat_ticks = 0
        stat_total_ping = 0
        stat_baseline_ping = 0
        stat_ping_stable_ticks = 0
        stat_last_ping_raw = 0
        graph_latency_pool = {}
        ALC.build_graph_ui() 
    end
    
    SLASH_COMMANDS["/alcframetime"] = function() 
        ALC.settings.track_frametime = not ALC.settings.track_frametime
        graph_frametime_pool = {}
        ALC.build_graph_ui() 
    end
    
    SLASH_COMMANDS["/alcgains"] = function() 
        ALC.settings.track_memory_gains = not ALC.settings.track_memory_gains
        ALC.build_graph_ui() 
    end
    
    SLASH_COMMANDS["/alcsession"] = function() 
        ALC.settings.show_session_ui = not ALC.settings.show_session_ui
        ALC.build_session_ui() 
    end
    
    SLASH_COMMANDS["/alcsessionlock"] = function() 
        ALC.settings.is_session_locked = not ALC.settings.is_session_locked
        if session_window then session_window:SetMovable(not ALC.settings.is_session_locked) end 
    end
    
    SLASH_COMMANDS["/alcsessionreset"] = function() 
        ALC.settings.session_ui_x = nil
        ALC.settings.session_ui_y = nil
        ALC.update_session_anchor() 
    end
    
    SLASH_COMMANDS["/alcstatpeak"] = function() 
        ALC.settings.session_track_peak = not ALC.settings.session_track_peak 
    end
    
    SLASH_COMMANDS["/alcstatavg"] = function() 
        ALC.settings.session_track_avg = not ALC.settings.session_track_avg 
    end
    
    SLASH_COMMANDS["/alcstatfinal"] = function() 
        ALC.settings.session_track_final = not ALC.settings.session_track_final 
    end

    SLASH_COMMANDS["/alcprofile"] = function() 
        ALC.settings.is_profiler_enabled = not ALC.settings.is_profiler_enabled
        d("|c00FFFF[ALC]|r Profiler Logic: " .. tostring(ALC.settings.is_profiler_enabled))
    end
    
    SLASH_COMMANDS["/alclibs"] = function() 
        ALC.settings.exclude_libs = not ALC.settings.exclude_libs
        d("|c00FFFF[ALC]|r Exclude Libraries filter is now [|cFFFF00" .. 
            (ALC.settings.exclude_libs and "ON" or "OFF") .. "|r]")
    end
    SLASH_COMMANDS["/alclibraries"] = SLASH_COMMANDS["/alclibs"]
    
    SLASH_COMMANDS["/alcstart"] = function() ALC.start_profiler() end
    
    SLASH_COMMANDS["/alcprostop"] = function() ALC.stop_profiler() end
    SLASH_COMMANDS["/alcstop"] = SLASH_COMMANDS["/alcprostop"]
    
    SLASH_COMMANDS["/alcprolist"] = function()
        local p_data = ALC.settings.saved_profiler_data
        if not p_data or #p_data == 0 or (p_data[1] and p_data[1].name == "None Scanned") then
            d("|c00FFFF[ALC]|r No data. Run a scan.")
            return 
        end
        d("|c00FFFF[ALC Profiler Full Results]|r")
        for i, mod in ipairs(p_data) do
            local formatted = ALC.format_time(mod.peak)
            local color = ALC.get_profiler_color(mod.peak)
            d(string.format("  %d. %s |c%s[%s]|r", i, formatted, color, mod.name))
        end
    end
    
    SLASH_COMMANDS["/alcdelvars"] = function() 
        d("|cFF0000[ALC] Wiping all settings...|r")
        local exclude = {
            total_cleanups = true, total_mb_freed = true, last_session_cleanups = true,
            last_session_mb_freed = true, prev_session_cleanups = true, prev_session_mb_freed = true,
            install_date = true, version_history = true, session_history = true,
            prev_session_perf = true, saved_profiler_data = true, is_migrated_008 = true,
            has_shown_lib_warning_008 = true, specific_lib_excludes = true,
            specific_addon_excludes = true
        }
        for k, v in pairs(ALC.defaults) do
            if not exclude[k] then
                if type(v) == "table" then ALC.settings[k] = ZO_ShallowTableCopy(v)
                else ALC.settings[k] = v end
            end
        end
        ReloadUI("ingame")
    end
    SLASH_COMMANDS["/alcwipe"] = SLASH_COMMANDS["/alcdelvars"]
    
    SLASH_COMMANDS["/alcstatclean"] = function() 
        ALC.settings.session_track_cleaned = not ALC.settings.session_track_cleaned 
    end
end

function ALC.build_lam2_menu()
    local lam_ver, lam_en, lca_ver, lca_en = ALC.get_settings_library()
    if not lam_en or lam_ver < 30 then return end

    if lam_ver >= 30 and lam_ver < REQUIRED_LAM_VERSION then
        zo_callLater(function()
            local warn_msg = string.format(
                "|cFFFF00Warning: LibAddonMenu is outdated (v%d). Update to v%d+ for ALC.|r", 
                lam_ver, REQUIRED_LAM_VERSION
            )
            if CHAT_SYSTEM then CHAT_SYSTEM:AddMessage("|cFF0000[ALC]|r " .. warn_msg) end
            if CENTER_SCREEN_ANNOUNCE then
                local p = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(
                    CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE
                )
                p:SetText(warn_msg); p:SetLifespanMS(4000)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(p)
            end
        end, 4000)
    end

    local c_cmds = {
        "|c00FFFF/alcon|r |cFFD700- Toggle Auto Cleanup|r\n\n",
        "|c00FFFF/alcui|r |cFFD700- Toggle Memory UI|r\n\n",
        "|c00FFFF/alclock|r |cFFD700- Lock/Unlock UI|r\n\n",
        "|c00FFFF/alcreset|r |cFFD700- Reset UI position|r\n\n",
        "|c00FFFF/alcbar|r |cFFD700- Toggle Memory UI Bar|r\n\n",
        "|c00FFFF/alcgraph|r |cFFD700- Toggle Memory Graph|r\n\n",
        "|c00FFFF/alcgraphlock|r |cFFD700- Lock/Unlock Graph|r\n\n",
        "|c00FFFF/alcgraphreset|r |cFFD700- Reset Graph position|r\n\n",
        "|c00FFFF/alclite|r |cFFD700- Toggle Lite Mode|r\n\n",
        "|c00FFFF/alcdiags|r |cFFD700- Toggle Graph Diagnostics|r\n\n",
        "|c00FFFF/alcsession|r |cFFD700- Toggle Session UI|r\n\n",
        "|c00FFFF/alcsessionlock|r |cFFD700- Lock Session UI|r\n\n",
        "|c00FFFF/alcsessionreset|r |cFFD700- Reset Session UI|r\n\n",
        "|c00FFFF/alccsa|r |cFFD700- Toggle Announcements|r\n\n",
        "|c00FFFF/alcstats|r |cFFD700- Toggle Saving Statistics|r\n\n",
        "|c00FFFF/alcprofile|r |cFFD700- Toggle Profiler Module|r\n\n",
        "|c00FFFF/alcself|r |cFFD700- Toggle ALC in Profiler Scan|r\n\n",
        "|c00FFFF/alclibs|r |cFFD700- Toggle Library Filtering|r\n\n",
        "|c00FFFF/alcstart|r |cFFD700- Start " .. (is_pad and "30s" or "60s") .. " Profiler Data Gather|r\n\n", 
        "|c00FFFF/alcprostop|r |cFFD700- Stop Profiler Scan|r\n\n",
        "|c00FFFF/alcprolist|r |cFFD700- List Profiler Results to Chat|r\n\n",
        "|c00FFFF/alcwipedata|r |cFFD700- Soft-delete a specific SavedVariables table|r\n\n",
        "|c00FFFF/alcdelvars|r |cFFD700- Reset ALL settings to defaults|r\n\n",
        "|c00FFFF/alcclean|r |cFFD700- Force manual Lua cleanup|r"
    }
    
    local pc_cmds = {
        "|c00FFFF/alcon|r |cFFD700- Toggle Auto Cleanup|r\n",
        "|c00FFFF/alcui|r |cFFD700- Toggle Memory UI|r\n",
        "|c00FFFF/alclock|r |cFFD700- Lock/Unlock UI|r\n",
        "|c00FFFF/alcreset|r |cFFD700- Reset UI position|r\n",
        "|c00FFFF/alcbar|r |cFFD700- Toggle Memory UI Bar|r\n",
        "|c00FFFF/alcgraph|r |cFFD700- Toggle Memory Graph|r\n",
        "|c00FFFF/alcgraphlock|r |cFFD700- Lock/Unlock Graph|r\n",
        "|c00FFFF/alcgraphreset|r |cFFD700- Reset Graph position|r\n",
        "|c00FFFF/alclite|r |cFFD700- Toggle Lite Mode|r\n",
        "|c00FFFF/alcdiags|r |cFFD700- Toggle Graph Diagnostics|r\n",
        "|c00FFFF/alcfps|r |cFFD700- Toggle FPS Tracking|r\n",
        "|c00FFFF/alcping|r |cFFD700- Toggle Latency Tracking|r\n",
        "|c00FFFF/alcgains|r |cFFD700- Toggle KB/MB Tracking|r\n",
        "|c00FFFF/alcsession|r |cFFD700- Toggle Session UI|r\n",
        "|c00FFFF/alcsessionlock|r |cFFD700- Lock Session UI|r\n",
        "|c00FFFF/alcsessionreset|r |cFFD700- Reset Session UI|r\n",
        "|c00FFFF/alcstatpeak|r |cFFD700- Toggle Session Peak Logs|r\n",
        "|c00FFFF/alcstatavg|r |cFFD700- Toggle Session Avg Logs|r\n",
        "|c00FFFF/alcstatfinal|r |cFFD700- Toggle Session Final Logs|r\n",
        "|c00FFFF/alcstatclean|r |cFFD700- Toggle Session Clean Logs|r\n",
        "|c00FFFF/alccsa|r |cFFD700- Toggle Announcements|r\n",
        "|c00FFFF/alclogs|r |cFFD700- Toggle Chat Logs|r\n",
        "|c00FFFF/alcstats|r |cFFD700- Toggle Saving Statistics|r\n",
        "|c00FFFF/alcprofile|r |cFFD700- Toggle Profiler Module|r\n",
        "|c00FFFF/alcself|r |cFFD700- Toggle ALC in Profiler Scan|r\n",
        "|c00FFFF/alclibs|r |cFFD700- Toggle Library Filtering|r\n",
        "|c00FFFF/alcstart|r |cFFD700- Start " .. (is_pad and "30s" or "60s") .. " Profiler Data Gather|r\n", 
        "|c00FFFF/alcprostop|r |cFFD700- Stop Profiler Scan|r\n",
        "|c00FFFF/alcprolist|r |cFFD700- List Profiler Results to Chat|r\n",
        "|c00FFFF/alcwipedata|r |cFFD700- Soft-delete a specific SavedVariables table|r\n",
        "|c00FFFF/alcdelvars|r |cFFD700- Reset ALL settings to defaults|r\n",
        "|c00FFFF/alcclean|r |cFFD700- Force manual Lua cleanup|r"
    }

    local is_eu_server = (GetWorldName() == "EU Megaserver")
    local is_pad = IsConsoleUI() or IsInGamepadPreferredMode()
    local lib_lam = LibAddonMenu2 or _G["LibAddonMenu2"]
    if not lib_lam then return end
    
    local headerTitle = capitalizeAddonName(ALC.name)
    local menu_header = { 
        type = "panel", 
        name = "|c9CD04CAuto Lua Memory Cleaner|r", 
        displayName = "|c00FFFFAuto Lua Memory Cleaner|r", 
        author = "@|ca500f3A|r|cb400e6P|r|cc300daH|r|cd200cdO|r|ce100c1NlC|r", 
        version = ALC.version, 
        registerForRefresh = true 
    }
    
    local build_data = {}
    
    if is_pad then
        table.insert(build_data, { 
            type = "button", 
            name = "|c00FF00ALC LIVE STATS|r", 
            tooltip = function() return ALC.get_stats_text() end, 
            func = function() end, 
            width = "full" 
        })
        table.insert(build_data, { 
            type = "button", 
            name = "|c00FF00COMMANDS INFO|r", 
            tooltip = table.concat(c_cmds), 
            func = function() end, 
            width = "full" 
        })
    end
    
    if not is_pad and not is_eu_server then
        table.insert(build_data, { 
            type = "button", 
            name = "|c00FFFFMANUAL CLEANUP|r", 
            func = function() ALC.run_manual_cleanup(true) end, 
            width = "half" 
        })
        table.insert(build_data, { 
            type = "button", 
            name = "|cFFD700DONATE|r to @|ca500f3A|r|cb400e6P|r|cc300daH|r|cd200cdO|r|ce100c1NlC|r", 
            tooltip = "Opens the in-game mail. Thank you!", 
            func = function() 
                SCENE_MANAGER:Show("mailSend")
                zo_callLater(function() 
                    ZO_MailSendToField:SetText("@APHONlC")
                    ZO_MailSendSubjectField:SetText("Auto Lua Memory Cleaner Support")
                    ZO_MailSendBodyField:TakeFocus() 
                end, 200) 
            end, 
            width = "half" 
        })
    else
        table.insert(build_data, { 
            type = "button", 
            name = "|c00FFFFMANUAL CLEANUP|r", 
                unc = function() ALC.run_manual_cleanup(true) end, 
            width = "full" 
        })
    end
    
    local menu_w = GetUIPlatform() == UI_PLATFORM_PC and "half" or "full"
    
    table.insert(build_data, { type = "header", name = "|c00FF00Cleanup Settings|r" })
    
    table.insert(build_data, { 
        type = "checkbox", 
        name = "Enable Auto Cleanup", 
        getFunc = function() return ALC.settings.is_enabled end, 
        setFunc = function(v) 
            ALC.settings.is_enabled = v
            ALC.toggle_core_events() 
        end 
    })

    if IsConsoleUI() then 
        table.insert(build_data, { 
            type = "slider", 
            name = "Console Memory Threshold (MB)", 
            min = 5, max = 95, step = 1, 
            getFunc = function() return ALC.settings.threshold_console end, 
            setFunc = function(v) ALC.settings.threshold_console = v end 
        })
    else 
        table.insert(build_data, { 
            type = "slider", 
            name = "PC Memory Threshold (MB)", 
            min = 50, max = 800, step = 1, 
            getFunc = function() return ALC.settings.threshold_pc end, 
            setFunc = function(v) ALC.settings.threshold_pc = v end 
        }) 
    end

    table.insert(build_data, { 
        type = "slider", 
        name = "Repeat Cleanup Delay (Seconds)", 
        min = 30, max = 1200, step = 10, 
        getFunc = function() return ALC.settings.fallback_delay_sec end, 
        setFunc = function(v) ALC.settings.fallback_delay_sec = v end 
    })
    
    if not is_pad then
        table.insert(build_data, { 
            type = "checkbox", 
            name = "Enable Chat Logs", 
            getFunc = function() return ALC.settings.is_log_enabled end, 
            setFunc = function(v) ALC.settings.is_log_enabled = v end 
        }) 
    end
    
    table.insert(build_data, { 
        type = "checkbox", 
        name = "Track Statistics", 
        getFunc = function() return ALC.settings.track_stats end, 
        setFunc = function(v) 
            ALC.settings.track_stats = v
            ALC.refresh_stats_tracker()
            local s_ctrl = _G["ALC_StatsText"]
            if s_ctrl and s_ctrl.desc then s_ctrl.desc:SetText(ALC.get_stats_text()) end 
        end 
    })
    
    table.insert(build_data, { 
        type = "checkbox", 
        name = "Screen Announcements", 
        getFunc = function() return ALC.settings.is_csa_enabled end, 
        setFunc = function(v) ALC.settings.is_csa_enabled = v end 
    })
    
    table.insert(build_data, { type = "divider" })
    
    table.insert(build_data, {
        type = "submenu",
        name = "|c00FFFFMemory UI|r",
        controls = {
            { 
                type = "checkbox", 
                name = "Show Memory UI", 
                getFunc = function() return ALC.settings.show_ui end, 
                setFunc = function(v) 
                    ALC.settings.show_ui = v
                    ALC.toggle_ui_update() 
                end 
            },
            { 
                type = "checkbox", 
                name = "Show UI Cleanup Bar", 
                getFunc = function() return ALC.settings.show_mem_ui_bar end, 
                setFunc = function(v) 
                    ALC.settings.show_mem_ui_bar = v
                    ALC.update_ui_anchor() 
                end, 
                disabled = function() return not ALC.settings.show_ui end 
            }
        }
    })

    table.insert(build_data, {
        type = "submenu",
        name = "|c00FFFFGraph UI|r",
        controls = {
            { 
                type = "checkbox", 
                name = "Enable Memory Graph UI", 
                getFunc = function() return ALC.settings.is_graph_enabled end, 
                setFunc = function(v) 
                    ALC.settings.is_graph_enabled = v
                    ALC.toggle_ui_update() 
                end, 
                disabled = function() return not ALC.settings.show_ui end 
            },
            { 
                type = "checkbox", 
                name = "Show Diagnostics Text", 
                getFunc = function() return ALC.settings.show_graph_diags end, 
                setFunc = function(v) 
                    ALC.settings.show_graph_diags = v
                    ALC.build_graph_ui() 
                end, 
                disabled = function() return not ALC.settings.is_graph_enabled end 
            },
            { 
                type = "checkbox", 
                name = "Enable [Text Only] Lite Mode", 
                getFunc = function() return ALC.settings.lite_mode end, 
                setFunc = function(v) 
                    ALC.settings.lite_mode = v
                    if v then ALC.settings.show_graph_diags = true end
                    ALC.build_graph_ui() 
                end, 
                disabled = function() return not ALC.settings.is_graph_enabled end 
            }
        }
    })
    
    table.insert(build_data, {
        type = "submenu",
        name = "|c00FFFFPrevious Session Logs|r",
        controls = {
            { 
                type = "checkbox", 
                name = "Log Session History", 
                getFunc = function() return ALC.settings.is_stats_log_enabled end, 
                setFunc = function(v) 
                    ALC.settings.is_stats_log_enabled = v
                    if v then 
                        EVENT_MANAGER:RegisterForUpdate("ALC_StatsTick", 60000, function() 
                            ALC.check_session_peak() 
                        end) 
                    else 
                        EVENT_MANAGER:UnregisterForUpdate("ALC_StatsTick") 
                    end 
                end 
            },
            {
                type = "checkbox",
                name = "Show Session History UI",
                getFunc = function() return ALC.settings.show_session_ui end,
                setFunc = function(v)
                    ALC.settings.show_session_ui = v
                    ALC.build_session_ui()
                end
            },
            {
                type = "checkbox",
                name = "Log Session PEAK Data",
                tooltip = "Logs the highest spike recorded during your session.",
                getFunc = function() return ALC.settings.session_track_peak end,
                setFunc = function(v) ALC.settings.session_track_peak = v end
            },
            {
                type = "checkbox",
                name = "Log Session AVERAGE Data",
                tooltip = "Logs the average for your session.",
                getFunc = function() return ALC.settings.session_track_avg end,
                setFunc = function(v) ALC.settings.session_track_avg = v end
            },
            {
                type = "checkbox",
                name = "Log Session FINAL Data",
                tooltip = "Logs the exact numbers seen right before you reloaded/logged out.",
                getFunc = function() return ALC.settings.session_track_final end,
                setFunc = function(v) ALC.settings.session_track_final = v end
            },
            {
                type = "checkbox",
                name = "Track MemCleaned (Session UI Only)",
                tooltip = "Logs how much RAM was saved during the session.",
                getFunc = function() return ALC.settings.session_track_cleaned end,
                setFunc = function(v) ALC.settings.session_track_cleaned = v end
            }
        }
    })
    
    table.insert(build_data, {
        type = "submenu",
        name = "|cFFA500Tracking Modules|r",
        controls = {
            { type = "checkbox", name = "Track Ping",
                getFunc = function() return ALC.settings.track_ping end,
                setFunc = function(v) ALC.settings.track_ping = v end, width = menu_w },
            { type = "checkbox", name = "Track FPS",
                getFunc = function() return ALC.settings.track_fps end,
                setFunc = function(v) ALC.settings.track_fps = v end, width = menu_w },
            { type = "checkbox", name = "Track Memory Gains",
                getFunc = function() return ALC.settings.track_memory_gains end,
                setFunc = function(v) ALC.settings.track_memory_gains = v end, width = menu_w },
            { type = "checkbox", name = "Track Frametime",
                getFunc = function() return ALC.settings.track_frametime end,
                setFunc = function(v) ALC.settings.track_frametime = v end, width = menu_w }
        }
    })
    
    table.insert(build_data, {
        type = "submenu",
        name = "|cFFA500Profiler Modules|r",
        controls = {
            {
                type = "checkbox",
                name = "Enable Profiler Logic",
                getFunc = function() return ALC.settings.is_profiler_enabled end,
                setFunc = function(v) ALC.settings.is_profiler_enabled = v end
            },
            {
                type = "checkbox",
                name = "Include ALC in Scan",
                getFunc = function() return ALC.settings.can_profile_self end,
                setFunc = function(v) ALC.settings.can_profile_self = v end,
                disabled = function() return not ALC.settings.is_profiler_enabled end
            },
            {
                type = "checkbox",
                name = "Include ESOProfiler in Scan",
                tooltip = "Include ESOProfiler's resources. Default is OFF (excluded).",
                getFunc = function() return ALC.settings.include_esoprofiler end,
                setFunc = function(v) ALC.settings.include_esoprofiler = v end,
                disabled = function() return not ALC.settings.is_profiler_enabled end
            },
            {
                type = "checkbox",
                name = "Exclude Libraries from Scan",
                tooltip = "Excludes standard 'Lib' dependencies from top load calculations.",
                getFunc = function() return ALC.settings.exclude_libs end,
                setFunc = function(v) ALC.settings.exclude_libs = v end,
                disabled = function() return not ALC.settings.is_profiler_enabled end
            },
            {
                type = "button", 
                name = IsConsoleUI() and "|cFF0000START 30s PROFILER|r" or "|cFF0000START 60s PROFILER|r",
                tooltip = "Start the data gather now.",
                func = function() ALC.start_profiler() end, width = "full",
                disabled = function() return not ALC.settings.is_profiler_enabled end
            }
        }
    })

    local am = GetAddOnManager()
    local libs_found, addons_found = {}, {}
    for i = 1, am:GetNumAddOns() do
        local addon_name, _, _, _, _, state = am:GetAddOnInfo(i)
        if state == ADDON_STATE_ENABLED then
            if string.find(addon_name:lower(), "lib") then
                table.insert(libs_found, addon_name)
            else
                table.insert(addons_found, addon_name)
            end
        end
    end
    table.sort(libs_found); table.sort(addons_found)

    local lib_controls = {}
    for _, l_name in ipairs(libs_found) do
        table.insert(lib_controls, {
            type = "checkbox", name = l_name,
            getFunc = function() return ALC.settings.specific_lib_excludes[l_name] or false end,
            setFunc = function(v) ALC.settings.specific_lib_excludes[l_name] = v end,
            disabled = function() return not ALC.settings.is_profiler_enabled end
        })
    end
    table.insert(build_data, {
        type = "submenu", name = "|cFFFF00Specific Library Exclusions|r",
        tooltip = "Select specific libraries to exclude from the scan results.",
        controls = lib_controls
    })

    local addon_controls = {}
    for _, a_name in ipairs(addons_found) do
        table.insert(addon_controls, {
            type = "checkbox", name = a_name,
            getFunc = function() return ALC.settings.specific_addon_excludes[a_name] or false end,
            setFunc = function(v) ALC.settings.specific_addon_excludes[a_name] = v end,
            disabled = function() return not ALC.settings.is_profiler_enabled end
        })
    end
    table.insert(build_data, {
        type = "submenu", name = "|cFFFF00Specific Addon Exclusions|r",
        tooltip = "Select specific addons to exclude from the scan results.",
        controls = addon_controls
    })
    
    local function preview_window(win_ctrl)
        local cur_scene = SCENE_MANAGER:GetCurrentScene()
        if not cur_scene then return end
        
        local t_frag = nil
        if win_ctrl == ALC.ui_window then t_frag = ALC.hud_fragment
        elseif win_ctrl == graph_window then t_frag = ALC.graph_fragment
        elseif win_ctrl == session_window then t_frag = ALC.session_fragment end
        
        if t_frag and cur_scene:HasFragment(t_frag) then
            win_ctrl:SetHidden(false)
        end
    end

    local ui_pos_controls = {}

    table.insert(ui_pos_controls, { 
        type = "checkbox", 
        name = "Render Memory UI in Menus", 
        getFunc = function() return ALC.settings.is_ui_global end, 
        setFunc = function(v) 
            ALC.settings.is_ui_global = v
            ALC.update_ui_scenes() 
        end, 
        disabled = function() return not ALC.settings.show_ui end 
    })

    table.insert(ui_pos_controls, {
        type = "checkbox",
        name = "Lock Memory UI Position",
        getFunc = function() return ALC.settings.is_ui_locked end,
        setFunc = function(v)
            ALC.settings.is_ui_locked = v
            if ALC.ui_window then ALC.ui_window:SetMovable(not v) end
        end,
        disabled = function() return not ALC.settings.show_ui end
    })

    table.insert(ui_pos_controls, { 
        type = "checkbox", 
        name = "Render Graph UI in Menus", 
        getFunc = function() return ALC.settings.is_graph_global end, 
        setFunc = function(v) 
            ALC.settings.is_graph_global = v
            ALC.update_ui_scenes() 
        end, 
        disabled = function() return not ALC.settings.is_graph_enabled end 
    })

    table.insert(ui_pos_controls, {
        type = "checkbox",
        name = "Lock Graph UI Position",
        getFunc = function() return ALC.settings.is_graph_locked end,
        setFunc = function(v)
            ALC.settings.is_graph_locked = v
            if graph_window then graph_window:SetMovable(not v) end
        end,
        disabled = function() return not ALC.settings.is_graph_enabled end
    })

    table.insert(ui_pos_controls, {
        type = "checkbox",
        name = "Render Session UI in Menus",
        getFunc = function() return ALC.settings.is_session_global end,
        setFunc = function(v)
            ALC.settings.is_session_global = v
            ALC.update_ui_scenes()
        end,
        disabled = function() return not ALC.settings.show_session_ui end
    })

    table.insert(ui_pos_controls, {
        type = "checkbox",
        name = "Lock Session UI Position",
        getFunc = function() return ALC.settings.is_session_locked end,
        setFunc = function(v)
            ALC.settings.is_session_locked = v
            if session_window then session_window:SetMovable(not v) end
        end,
        disabled = function() return not ALC.settings.show_session_ui end
    })

    if is_pad and ALC.is_lca_valid then
        table.insert(ui_pos_controls, { 
            type = "button", name = "Move Memory UI (D-Pad)", width = "half",
            func = function() 
                preview_window(ALC.ui_window)
                if ALC.ui_mover then ALC.ui_mover:ToggleGamepadMove(true) end
            end,
            disabled = function() return ALC.ui_mover == nil or ALC.settings.is_ui_locked end
        })
    end
    table.insert(ui_pos_controls, { 
        type = "button", name = "|cFF0000RESET MEMORY POS|r", width = "half",
        func = function() 
            ALC.settings.ui_x = nil
            ALC.settings.ui_y = nil
            ALC.update_ui_anchor() 
            preview_window(ALC.ui_window)
            if ALC.settings.is_log_enabled and CHAT_SYSTEM then 
                CHAT_SYSTEM:AddMessage("|c00FFFF[ALC]|r Memory UI Position Reset.") 
            end 
        end,
        disabled = function() return not ALC.settings.show_ui end
    })
    
    if is_pad and ALC.is_lca_valid then
        table.insert(ui_pos_controls, { 
            type = "button", name = "Move Graph UI (D-Pad)", width = "half",
            func = function() 
                preview_window(graph_window)
                if ALC.graph_mover then ALC.graph_mover:ToggleGamepadMove(true) end
            end,
            disabled = function() return ALC.graph_mover == nil or ALC.settings.is_graph_locked end
        })
    end
    table.insert(ui_pos_controls, { 
        type = "button", name = "|cFF0000RESET GRAPH POS|r", width = "half",
        func = function() 
            ALC.settings.graph_x = nil
            ALC.settings.graph_y = nil
            ALC.settings.is_graph_detached = false
            ALC.update_graph_anchor() 
            preview_window(graph_window)
            if CHAT_SYSTEM then 
                CHAT_SYSTEM:AddMessage("|c00FFFF[ALC]|r Graph UI Position Reset.") 
            end 
        end,
        disabled = function() return not ALC.settings.is_graph_enabled end
    })

    if is_pad and ALC.is_lca_valid then
        table.insert(ui_pos_controls, { 
            type = "button", name = "Move Session UI (D-Pad)", width = "half",
            func = function() 
                preview_window(session_window)
                if ALC.session_mover then ALC.session_mover:ToggleGamepadMove(true) end
            end,
            disabled = function() return ALC.session_mover == nil or ALC.settings.is_session_locked end
        })
    end
    table.insert(ui_pos_controls, { 
        type = "button", name = "|cFF0000RESET SESSION POS|r", width = "half",
        func = function() 
            ALC.settings.session_ui_x = nil
            ALC.settings.session_ui_y = nil
            ALC.update_session_anchor() 
            preview_window(session_window)
            if ALC.settings.is_log_enabled and CHAT_SYSTEM then 
                CHAT_SYSTEM:AddMessage("|c00FFFF[ALC]|r Session UI Position Reset.") 
            end
        end,
        disabled = function() return not ALC.settings.show_session_ui end
    })

    table.insert(build_data, {
        type = "submenu",
        name = "|c00FFFFConfigure UI Positions|r",
        controls = ui_pos_controls
    })
    
    if not is_pad then
        local live_stats = {
            type = "submenu", 
            name = "ALC Live Statistics", 
            controls = { 
                { 
                    type = "description", 
                    title = "|c00FFFFLive Statistics|r", 
                    text = "Statistics Tracking is Disabled...", 
                    reference = "ALC_StatsText" 
                } 
            } 
        }
        table.insert(build_data, live_stats)
        
        local profiler_results = {
            type = "submenu", 
            name = "ALC Profiler Results", 
            controls = { 
                { 
                    type = "description", 
                    title = "|c00FFFFScanned Addons & Libraries|r", 
                    text = function()
                        local p_data = ALC.settings.saved_profiler_data
                        local fallback = "NO SCANNED DATA START 60S PROFILER FIRST."
                        if not p_data or #p_data == 0 then return fallback end
                        if p_data[1] and p_data[1].name == "None Scanned" then return fallback end
                        
                        local lines = {}
                        for i, mod in ipairs(p_data) do
                            local formatted = ALC.format_time(mod.peak)
                            local color = ALC.get_profiler_color(mod.peak)
                            table.insert(lines, string.format(
                                "  %d. %s |c%s[%s]|r", 
                                i, formatted, color, mod.name
                            ))
                        end
                        return table.concat(lines, "\n")
                    end
                } 
            } 
        }
        table.insert(build_data, profiler_results)
        
        table.insert(build_data, { 
            type = "description", 
            title = "Commands Info", 
            text = table.concat(pc_cmds) 
        })
    end
    
    table.insert(build_data, { type = "divider" })

    local function ResetToDefaults()
        local exclude = {
            total_cleanups = true, total_mb_freed = true, last_session_cleanups = true,
            last_session_mb_freed = true, prev_session_cleanups = true, prev_session_mb_freed = true,
            install_date = true, version_history = true, session_history = true,
            prev_session_perf = true, saved_profiler_data = true, is_migrated_008 = true,
            has_shown_lib_warning_008 = true, specific_lib_excludes = true,
            specific_addon_excludes = true
        }
        for k, v in pairs(ALC.defaults) do
            if not exclude[k] then
                if type(v) == "table" then
                    ALC.settings[k] = ZO_ShallowTableCopy(v)
                else
                    ALC.settings[k] = v
                end
            end
        end
        ReloadUI("ingame")
    end

    if is_pad then
        table.insert(build_data, { 
            type = "button", 
            name = "|cFF0000RESET TO DEFAULTS|r", 
            tooltip = "|cFF0000RESETS ALL SETTINGS TO DEFAULT VALUES.|r",
            func = ResetToDefaults, 
            width = "full" 
        })
        table.insert(build_data, { 
            type = "button", 
            name = "|cFFD700Buy Me A Coffee|r", 
            tooltip = "Link: https://buymeacoffee.com/aph0nlc", 
            func = function() end, 
            width = "full" 
        })
        table.insert(build_data, { 
            type = "button", 
            name = "|cFF0000BUG REPORT|r", 
            tooltip = "Link: https://www.esoui.com/portal.php?id=360&a=listbugs", 
            func = function() end, 
            width = "full" 
        })
    else
        table.insert(build_data, { 
            type = "button", 
            name = "|cFF0000RESET TO DEFAULTS|r", 
            tooltip = "|cFF0000RESETS ALL SETTINGS TO DEFAULT VALUES.|r",
            func = ResetToDefaults, 
            width = "full" 
        })
        table.insert(build_data, { 
            type = "button", 
            name = "|cFFD700Buy Me A Coffee|r", 
            func = function() RequestOpenUnsafeURL("https://buymeacoffee.com/aph0nlc") end, 
            width = "full" 
        })
        table.insert(build_data, { 
            type = "button", 
            name = "|cFF0000BUG REPORT|r", 
            func = function() RequestOpenUnsafeURL("https://www.esoui.com/portal.php?id=360&a=listbugs") end, 
            width = "full" 
        })
    end

    ALC.lam_panel = lib_lam:RegisterAddonPanel("AutoLuaCleanerOptions", menu_header)
    lib_lam:RegisterOptionControls("AutoLuaCleanerOptions", build_data)
end

EVENT_MANAGER:RegisterForEvent(
    ALC.name, 
    EVENT_ADD_ON_LOADED, 
    function(...) ALC.init(...) end
)
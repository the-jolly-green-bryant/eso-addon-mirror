local strings = {
    SI_MGC_ADDON_DESCRIPTION = "The enabled add-on will perform LUA garbage collection when the current memory consumption exceeds the specified level.",
    SI_MGC_AUTO_CLEAR = "Enable cleanup",
    SI_MGC_AUTO_CLEAR_TOOLTIP = "Enable automatic memory cleanup of unused variables.",
    SI_MGC_REFRESH_RATE = "Time between attempts, min",
    SI_MGC_REFRESH_RATE_TOOLTIP = "Once every N minutes, memory will be cleared if a violation of the specified limits is detected.",
    SI_MGC_COMPARISON_METHOD = "Comparison of memory spent",
    SI_MGC_COMPARISON_METHOD_TOOLTIP = "Memory consumption is exceeded, either relative (%%) or absolute (MB).",
    SI_MGC_OVERFLOW_RELATIVE = "Relative (%%)",
    SI_MGC_OVERFLOW_RELATIVE_TOOLTIP = "The percentage of memory exceeded at which it is necessary to cause a cleanup",
    SI_MGC_OVERFLOW_ABSOLUTE = "Absolute (MB)",
    SI_MGC_OVERFLOW_ABSOLUTE_TOOLTIP = "The value of memory exceeded at which it is necessary to cause a cleanup",
    SI_MGC_SHOW_DEBUG_MESSAGES = "Show debug messages",
    SI_MGC_SILENT_MODE = "Silent Mode (Disable ALL chat messages)",
    SI_MGC_MEMORY_INIT_MAX = "|ceeeeeeMemory limit set: |cAFD3FF%d MB.",
    SI_MGC_MEMORY_OVERFLOW_DEBUG = "|ceeeeeeNow: |c77ff7a%d MB; |ceeeeeeLimit: |cAFD3FF%d MB.",
    SI_MGC_MEMORY_OVERFLOW_REACHED = "|ceeeeeeBefore: |cff7d77%d MB; |ceeeeeeAfter: |c77ff7a%d MB; |ceeeeeeCleared: |cAFD3FF%d MB.",
}

for id, val in pairs(strings) do
    ZO_CreateStringId(id, val)
    SafeAddVersion(id, 1)
end

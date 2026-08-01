-- Initalize RunesVoice to use as Table to store
-- the Addon in it.
if RunesVoice == nil then RunesVoice = {} end

-- Store AddonMenu as Array of Panel, Options pairs
RunesVoice.menu = {
    -- Block
    [1] = {
      -- Panel
      [1] = {
        type = "panel",
        name = RunesVoice.Addon.displayName,
        author = RunesVoice.Addon.author,
        version = RunesVoice.Addon.version,
        slashCommand = RunesVoice.Addon.command,
        registerForRefresh = true,
        registerForDefaults = true,
        resetFunc = function() RunesVoice:resetAddonMenu() end
      },
      -- Options
      [2] = {
        -- Header Information
        [1] = {
          type = "header",
          name = GetString(HEADER_INFO),
          width = "full"
        },
        -- Option Information Box
        [2] = {
          type = "description",
          text = GetString(DESC_ADDON),
          width = "full"
        },
        -- Header RapidChant Options
        [3] = {
          type = "header",
          name = GetString(HEADER_OPTIONS_RAPIDCHANT),
          width = "full"
        },
        -- Add Checkbox to enable fast crafting runes
        [4] = {
          type = "checkbox",
          name = GetString(CB_TITLE_RECH_ENABLE),
          tooltip = GetString(CB_TT_RECH_ENABLE),
          getFunc = function() return RunesVoice:getConfigValue('rach_enable') end,
          setFunc = function(enable) RunesVoice:setConfigValue('rach_enable', enable) end
        },
        -- Header Debug
        [5] = {
          type = "header",
          name = GetString(HEADER_OPTIONS_DEBUG),
          whidth = "full"
        },
        -- Debug Enable/Disable All
        [6] = {
          type = "checkbox",
          name = GetString(CB_TITLE_DEBUG),
          tooltip = GetString(CB_TT_DEBUG),
          getFunc = function() return RunesVoice:getConfigValue('debug_enable') end,
          setFunc = function(enable) RunesVoice:setConfigValue('debug_enable', enable) end
        },
        -- Debug Enable/Disable Info
        [7] = {
          type = "checkbox",
          name = GetString(CB_TITLE_DEBUG_INFO),
          tooltip = GetString(CB_TT_DEBUG_INFO),
          getFunc = function() return RunesVoice:getConfigValue('debug_enable_info') end,
          setFunc = function(enable) RunesVoice:setConfigValue('debug_enable_info', enable) end
        },
        -- Debug Enable/Disable Warning
        [8] = {
          type = "checkbox",
          name = GetString(CB_TITLE_DEBUG_WARNING),
          tooltip = GetString(CB_TT_DEBUG_WARNING),
          getFunc = function() return RunesVoice:getConfigValue('debug_enable_warning') end,
          setFunc = function(enable) RunesVoice:setConfigValue('debug_enable_warning', enable) end
        },
        -- Debug Enable/Disable Error
        [9] = {
          type = "checkbox",
          name = GetString(CB_TITLE_DEBUG_ERROR),
          tooltip = GetString(CB_TT_DEBUG_ERROR),
          getFunc = function() return RunesVoice:getConfigValue('debug_enable_error') end,
          setFunc = function(enable) RunesVoice:setConfigValue('debug_enable_error', enable) end
        }
      }
    }
  }
  
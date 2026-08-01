--[[ Settings GUI ]]-- 
 
----------------------------------------
-- Functions to SHOW Settings data --
----------------------------------------

------------------------------
-- 
function ElderScrollsOfAlts.LoadSettings()
  --local LAM = LibStub("LibAddonMenu-2.0")
  local LAM = LibAddonMenu2
  local panelData = {
      type = "panel",
      name         = ElderScrollsOfAlts.name,
      displayName  = ElderScrollsOfAlts.Colorize(ElderScrollsOfAlts.menuName),
      author       = ElderScrollsOfAlts.Colorize(ElderScrollsOfAlts.author, "AAF0BB"),
      version      = ElderScrollsOfAlts.Colorize(ElderScrollsOfAlts.version, "AA00FF"),
      slashCommand = "/ElderScrollsOfAlts",
      registerForRefresh  = true,
      registerForDefaults = true,
  }
  ElderScrollsOfAlts.view.LAMPanel = LAM:RegisterAddonPanel(ElderScrollsOfAlts.menuName, panelData)
  local optionsTable = {}
  ElderScrollsOfAlts.view.pauseactivesave = false
  ---- -- --- -- --- ----
  -- ACCOUNT SETTINGS  --
  ---- -- --- -- --- ----
  optionsTable[1] = {
    type  = "header",
    name  = GetString(ESOA_SETTINGS_ACCOUNTWIDE),
    width = "full",	--or "half" (optional)
  }
  optionsTable[#optionsTable+1] = {
    type = "slider",
    name = GetString(ESOA_SETTINGS_CHARNAMEFIELD_NAME),
    getFunc = function() return ElderScrollsOfAlts.altData.fieldWidthForName end,
    setFunc = function(value) ElderScrollsOfAlts.altData.fieldWidthForName = value end,
    min = 50,
    max = 300,
    step = 1, --(optional)
    clampInput = false, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
    decimals = 0, -- when specified the input value is rounded to the specified number of decimals (optional)
    autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
    inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional) 
    tooltip = GetString(ESOA_SETTINGS_CHARNAMEFIELD_TT),
    width = "full", --or "half" (optional)
    warning = GetString(ESOA_SETTINGS_CHARNAMEFIELD_WARNING),
    requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
    default = 160, -- default value or function that returns the default value (optional)
    reference = "ESOA_NameSlider" -- unique global reference to control (optional)
  }
  
  
  -- Account Settings --

  ---- -- --- -- --- ----
  -- CHAR SETTINGS     --
  ---- -- --- -- --- ----
  optionsTable[#optionsTable+1] = {
    type  = "header",
    name  = GetString(ESOA_SETTINGS_CHAR_SETTINGS),
    width = "full",	--or "half" (optional)
  }
  optionsTable [#optionsTable+1] = {
    type    = "checkbox",
    name    = GetString(ESOA_SETTINGS_SHOWBUTTON_NAME),
    tooltip = GetString(ESOA_SETTINGS_SHOWBUTTON_TT),
    getFunc = function() return ElderScrollsOfAlts.GetUIButtonShown() end,
    setFunc = function(value)   ElderScrollsOfAlts.SetUIButtonShown(value)  end,
    width   = "half",
  }
  optionsTable [#optionsTable+1] = {
    type    = "checkbox",
    name    = GetString(ESOA_SETTINGS_MOUSEHIGHLIGHT_NAME),
    tooltip = GetString(ESOA_SETTINGS_MOUSEHIGHLIGHT_TT),
    getFunc = function() return ElderScrollsOfAlts.GetUIViewMouseHighlightShown() end,
    setFunc = function(value)   ElderScrollsOfAlts.SetUIViewMouseHighlightShown(value)  end,
    width   = "half",
  }
  optionsTable [#optionsTable+1] = {
    type    = "checkbox",
    name    = GetString(ESOA_SETTINGS_STOPACTIVE_NAME),
    tooltip = GetString(ESOA_SETTINGS_STOPACTIVE_TT),
    getFunc = function() return ElderScrollsOfAlts.view.pauseactivesave end,
    setFunc = function(value)
      ElderScrollsOfAlts.view.pauseactivesave = value
      --ElderScrollsOfAlts:SetupCPBar()
    end,
    width   = "full",
  }
  optionsTable [#optionsTable+1] = {
    type    = "checkbox",
    name    = GetString(ESOA_SETTINGS_STOPINSTANCE_NAME),
    tooltip = GetString(ESOA_SETTINGS_STOPINSTANCE_TT),
    getFunc = function() return ElderScrollsOfAlts.view.dontLoadDataInDungeon end,
    setFunc = function(value)
      ElderScrollsOfAlts.view.dontLoadDataInDungeon = value
      --ElderScrollsOfAlts:SetupCPBar()
    end,
    width   = "full",
  }
  optionsTable [#optionsTable+1] = {
    type    = "checkbox",
    name    = GetString(ESOA_SETTINGS_STOPCOMBAT_NAME),
    tooltip = GetString(ESOA_SETTINGS_STOPCOMBAT_TT),
    getFunc = function() return ElderScrollsOfAlts.view.dontLoadDataInCombat end,
    setFunc = function(value)
      ElderScrollsOfAlts.view.dontLoadDataInCombat = value
      --ElderScrollsOfAlts:SetupCPBar()
    end,
    width   = "full",
  }
  optionsTable [#optionsTable+1] = {
    type    = "checkbox",
    name    = GetString(ESOA_SETTINGS_STOPPVP_NAME),
    tooltip = GetString(ESOA_SETTINGS_STOPPVP_TT),
    getFunc = function() return ElderScrollsOfAlts.view.dontLoadDataWhilePvPFlagged end,
    setFunc = function(value)
      ElderScrollsOfAlts.view.dontLoadDataWhilePvPFlagged = value
      --ElderScrollsOfAlts:SetupCPBar()
    end,
    width   = "full",
  }
  
  
  --[[
  optionsTable [#optionsTable+1] = {
    type    = "checkbox",
    name    = GetString(ESOA_SETTINGS_HIDEUIMENUS_NM),
    tooltip = GetString(ESOA_SETTINGS_HIDEUIMENUS_TT),
    getFunc = function() return ElderScrollsOfAlts.savedVariables.hideinmenus end,
    setFunc = function(value)   ElderScrollsOfAlts.SetUIHIdeInMenues(value) end,
    width   = "full",
  }--]]
  
  --
  optionsTable [#optionsTable+1] = {
    type    = "checkbox",
    name    = GetString(ESOA_SETTINGS_CPACTIVEBAR1_NM),
    tooltip = GetString(ESOA_SETTINGS_CPACTIVEBAR1_TT),
    getFunc = function() return ElderScrollsOfAlts.savedVariables.cpactivebar1.show end,
    setFunc = function(value)
      ElderScrollsOfAlts.savedVariables.cpactivebar1.show = value
      ElderScrollsOfAlts:SetupCPBar()
    end,
    width   = "half",	--or "half" (optional)
  }
  optionsTable [#optionsTable+1] = {
    type    = "checkbox",
    name    = GetString(ESOA_SETTINGS_CPACTIVEBAR2_NM),
    tooltip = GetString(ESOA_SETTINGS_CPACTIVEBAR2_TT),
    getFunc = function() return ElderScrollsOfAlts.savedVariables.cpactivebar2.show end,
    setFunc = function(value)
      ElderScrollsOfAlts.savedVariables.cpactivebar2.show = value
      ElderScrollsOfAlts:SetupCPBar()
      end,
    width   = "half",	--or "half" (optional)
  }
  --[[TODO
  optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name    = GetString(ESOA_SETTINGS_AUTOUSEDEF_NM),
      tooltip = GetString(ESOA_SETTINGS_AUTOUSEDEF_TT), 
      getFunc = function() return ElderScrollsOfAlts.altData.automaticallyusedefaults end,
      setFunc = function(value)
        ElderScrollsOfAlts.altData.automaticallyusedefaults = value
      end,
      width = "half",	--or "half" (optional)
  }
  --]]
  
  --
  optionsTable[#optionsTable+1] = {
    type  = "header",
    name  = GetString(ESOA_SETTINGS_OPTIONS),
    width = "full",	--or "half" (optional)
  }
  optionsTable[#optionsTable+1] = {
    type    = "colorpicker",
    name    = GetString(ESOA_SETTINGS_SKILLCOLOR_soon_NAME),
    tooltip = GetString(ESOA_SETTINGS_SKILLCOLOR_soon_TT),
    getFunc = function()               
      if(ElderScrollsOfAlts.savedVariables.colors==nil or ElderScrollsOfAlts.savedVariables.colors.colorTimerNear==nil) then
          ElderScrollsOfAlts.SetupDefaultColors()
      end
      return              
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNear.r,
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNear.g,
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNear.b,
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNear.a      
    end,
    setFunc = 	function(r,g,b,a)
      --(alpha is optional)
      --d(r, g, b, a)
      --local c = ZO_ColorDef:New(r,g,b,a)
      --c:Colorize(text)
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNear = {}
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNear.r = r
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNear.g = g
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNear.b = b
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNear.a = a
    end,
    width = "full",	--or "half" (optional)
  }
  optionsTable[#optionsTable+1] = {
    type = "colorpicker",
    name = GetString(ESOA_SETTINGS_SKILLCOLOR_sooner_NAME),
    tooltip = GetString(ESOA_SETTINGS_SKILLCOLOR_sooner_TT),
    getFunc = function()               
      if(ElderScrollsOfAlts.savedVariables.colors==nil or ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer==nil) then
          ElderScrollsOfAlts.SetupDefaultColors()
      end
      return              
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer.r,
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer.g,
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer.b,
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer.a      
    end,
    setFunc = 	function(r,g,b,a)
      --(alpha is optional)
      --d(r, g, b, a)
      --local c = ZO_ColorDef:New(r,g,b,a)
      --c:Colorize(text)
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer = {}
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer.r = r
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer.g = g
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer.b = b
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer.a = a
    end,
    width = "full",	--or "half" (optional)
  }
  
  optionsTable[#optionsTable+1] = {
    type = "colorpicker",
    name = GetString(ESOA_SETTINGS_SKILLCOLOR_done_NAME),
    tooltip = GetString(ESOA_SETTINGS_SKILLCOLOR_done_TT),
    getFunc = function()               
      if(ElderScrollsOfAlts.savedVariables.colors==nil or ElderScrollsOfAlts.savedVariables.colors.colorTimerDone==nil) then
          ElderScrollsOfAlts.SetupDefaultColors()
      end
      return              
      ElderScrollsOfAlts.savedVariables.colors.colorTimerDone.r,
      ElderScrollsOfAlts.savedVariables.colors.colorTimerDone.g,
      ElderScrollsOfAlts.savedVariables.colors.colorTimerDone.b,
      ElderScrollsOfAlts.savedVariables.colors.colorTimerDone.a      
    end,
    setFunc = 	function(r,g,b,a)
      --(alpha is optional)
      --d(r, g, b, a)
      --local c = ZO_ColorDef:New(r,g,b,a)
      --c:Colorize(text)
      ElderScrollsOfAlts.savedVariables.colors.colorTimerDone = {}
      ElderScrollsOfAlts.savedVariables.colors.colorTimerDone.r = r
      ElderScrollsOfAlts.savedVariables.colors.colorTimerDone.g = g
      ElderScrollsOfAlts.savedVariables.colors.colorTimerDone.b = b
      ElderScrollsOfAlts.savedVariables.colors.colorTimerDone.a = a
    end,
    width = "full",	--or "half" (optional)
  }
  
  optionsTable[#optionsTable+1] = {
    type    = "colorpicker",
    name    = GetString(ESOA_SETTINGS_SKILLCOLOR_na_NAME),
    tooltip = GetString(ESOA_SETTINGS_SKILLCOLOR_na_TT),
    getFunc = function()               
      if(ElderScrollsOfAlts.savedVariables.colors==nil or ElderScrollsOfAlts.savedVariables.colors.colorTimerNone==nil) then
          ElderScrollsOfAlts.SetupDefaultColors()
      end
      return              
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNone.r,
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNone.g,
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNone.b,
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNone.a      
    end,
    setFunc = 	function(r,g,b,a)
      --(alpha is optional)
      --d(r, g, b, a)
      --local c = ZO_ColorDef:New(r,g,b,a)
      --c:Colorize(text)
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNone = {}
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNone.r = r
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNone.g = g
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNone.b = b
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNone.a = a
    end,
    width = "full",	--or "half" (optional)
  }
  
  
  optionsTable[#optionsTable+1] = {
    type    = "colorpicker",
    name    = GetString(ESOA_SETTINGS_SKILLCOLOR_Max_NAME),
    tooltip = GetString(ESOA_SETTINGS_SKILLCOLOR_Max_TT),
    getFunc = function()               
      if(ElderScrollsOfAlts.savedVariables.colors==nil or ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax==nil) then
          ElderScrollsOfAlts.SetupDefaultColors()
      end
      return              
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax.r,
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax.g,
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax.b,
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax.a      
    end,
    setFunc = 	function(r,g,b,a)
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax = {}
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax.r = r
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax.g = g
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax.b = b
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax.a = a
    end,
    width = "full",	--or "half" (optional)
  }
  optionsTable[#optionsTable+1] = {
    type    = "colorpicker",
    name    = GetString(ESOA_SETTINGS_SKILLCOLOR_NearMax_NAME),
    tooltip = GetString(ESOA_SETTINGS_SKILLCOLOR_NearMax_TT),
    getFunc = function()               
      if(ElderScrollsOfAlts.savedVariables.colors==nil or ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax==nil) then
          ElderScrollsOfAlts.SetupDefaultColors()
      end
      return              
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax.r,
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax.g,
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax.b,
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax.a      
    end,
    setFunc = 	function(r,g,b,a)
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax = {}
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax.r = r
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax.g = g
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax.b = b
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax.a = a
    end,
    width = "full",	--or "half" (optional)
  }
  --
  
  -- Save/Load Settings
  optionsTable[#optionsTable+1] = {
    type = "button",
    name = GetString(ESOA_KEY_SETTINGS_SAVE_TITLE),  --"Save these settings",
    tooltip = GetString(ESOA_KEY_SETTINGS_SAVE_MSG), --"Save these as settings so they can be used later?",
    func = function()  ElderScrollsOfAlts:DoSaveProfileSettings() end,
    width = "full",	--or "half" (optional)
    warning = GetString(ESOA_KEY_SETTINGS_NOCONFIRM),
  }
  -- Save/Load Settings
  optionsTable[#optionsTable+1] = {
    type = "button",
    name = GetString(ESOA_KEY_SETTINGS_LOAD_TITLE), --"Load saved settings",
    tooltip = GetString(ESOA_KEY_SETTINGS_LOAD_MSG), --"Load settings from saved profile?",
    func = function()  ElderScrollsOfAlts:DoLoadProfileSettings() end,
    width = "full",	--or "half" (optional)
    warning = GetString(ESOA_KEY_SETTINGS_NOCONFIRM),
  }
  --
  
  
  -- Character Base Options --
  
  optionsTable [#optionsTable+1] = {
    type = "header",
    name = GetString(ESOA_SETTINGS_MAINT_HDR_NAME),
    text = GetString(ESOA_SETTINGS_MAINT_HDR_TEXT),
    tooltip = GetString(ESOA_SETTINGS_MAINT_HDR_TT),
  }
  optionsTable[#optionsTable+1] = {
    type = "dropdown",
    name = GetString(ESOA_SETTINGS_CHAR_NAME),
    tooltip = GetString(ESOA_SETTINGS_CHAR_TT) .. tostring(ElderScrollsOfAlts.savedVariables.selected.charactername),
    choices = ElderScrollsOfAlts:ListOfCharacterNames(),
    getFunc = function() return GetString(ESOA_SETTINGS_SELECT) end,
    setFunc = function(var) ElderScrollsOfAlts:SelectCharacterName(var) end,
    width = "full",	--or "half" (optional)
    reference = "ESOA_SETTINGS_CHARMAIN_Select",--TODO refresh me
  }
  optionsTable[#optionsTable+1] = {
    type = "button",
    name = GetString(ESOA_SETTINGS_DELETE_NAME),
    tooltip = GetString(ESOA_SETTINGS_DELETE_TT),
    func  = function()  ElderScrollsOfAlts:DoDeleteSelectedCharacter() end,
    width = "half",	--or "half" (optional)
    warning = GetString(ESOA_KEY_SETTINGS_NOCONFIRM),	--(optional)
  }
  -- Character Maintanance Options --
  
  optionsTable[#optionsTable+1] = {
    type  = "header",
    name  = "Views",
    width = "full",	--or "half" (optional)
  }    
  --[[
  optionsTable [#optionsTable+1] = {
    type    = "checkbox",
    name    = "Use dropdown for Views, instead of buttons.",
    tooltip = "On or off.",
    getFunc = function() return ElderScrollsOfAlts.GetUIViewDropDownShown() end,
    setFunc = function(value)   ElderScrollsOfAlts.SetUIViewDropDownShown(value)  end,
    width   = "full",	--or "half" (optional)
  }
  --]]
  optionsTable[#optionsTable+1] = {
    type    = "button",
    name    = GetString(ESOA_SETTINGS_RESET_VIEWS_BTN_NT),
    tooltip = GetString(ESOA_SETTINGS_RESET_VIEWS_BTN_TT),
    func    = function()  ElderScrollsOfAlts:ResetUIViews() end,
    width   = "half",	--or "half" (optional)
    warning = GetString(ESOA_KEY_SETTINGS_NOCONFIRM),	--(optional)
  } 
  --New from template
  --TODO template dropdown to pick from
  optionsTable[#optionsTable+1] = {
    type    = "dropdown",
    name    = GetString(ESOA_SETTINGS_NFT_SELECT_NAME),
    tooltip = GetString(ESOA_SETTINGS_NFT_SELECT_TT),
    choices = ElderScrollsOfAlts:SettingsListOfViewTemplateNames(),
    getFunc = function() return tostring(ElderScrollsOfAlts.savedVariables.selected.viewTemplate) end,
    setFunc = function(var) ElderScrollsOfAlts.savedVariables.selected.viewTemplate = (var) end,
    width = "full",	--or "half" (optional)
    reference = "ESOA_SETTINGS_TV_SelectView",
  }    
  optionsTable[#optionsTable+1] = {
    type    = "button",
    name    = GetString(ESOA_SETTINGS_NFT_NAME),
    tooltip = GetString(ESOA_SETTINGS_NFT_TT),
    func    = function()  ElderScrollsOfAlts:DoAddNewViewData() end,
    width   = "half",	--or "half" (optional)
    warning = GetString(ESOA_KEY_SETTINGS_NOCONFIRM),	--(optional)
  }
  optionsTable[#optionsTable+1] = {
    type    = "dropdown",
    name    = GetString(ESOA_SETTINGS_EDITVIEWSELECT_NAME),
    tooltip = GetString(ESOA_SETTINGS_EDITVIEWSELECT_TT),
    choices = ElderScrollsOfAlts:SettingsListOfViews(),
    getFunc = function() return tostring(ElderScrollsOfAlts.savedVariables.selected.viewidx) end,
    setFunc = function(var) ElderScrollsOfAlts.savedVariables.selected.viewidx = tonumber(var) end,
    width = "full",	--or "half" (optional)
    reference = "ESOA_SETTINGS_DD_SelectView",
  }
  optionsTable[#optionsTable+1] = {
    type    = "button",
    name    = GetString(ESOA_SETTINGS_EDITVIEWEDIT_NAME),
    tooltip = GetString(ESOA_SETTINGS_EDITVIEWEDIT_TT),
    func    = function()  ElderScrollsOfAlts:DoEditSelectedView() end,
    width   = "half",	--or "half" (optional)
    warning = GetString(ESOA_KEY_SETTINGS_NOCONFIRM),	--(optional)
  }
  optionsTable[#optionsTable+1] = {
    type    = "button",
    name    = GetString(ESOA_SETTINGS_EDITVIEWDELETE_NAME),
    tooltip = GetString(ESOA_SETTINGS_EDITVIEWDELETE_TT),
    func    = function()  ElderScrollsOfAlts:DoDeleteSelectedView() end,
    width   = "half",	--or "half" (optional)
    warning = GetString(ESOA_KEY_SETTINGS_NOCONFIRM),	--(optional)
  }
  optionsTable[#optionsTable+1] = {
    type    = "editbox",
    name    = GetString(ESOA_SETTINGS_EDITVIEWNAME_NAME),
    tooltip = GetString(ESOA_SETTINGS_EDITVIEWNAME_TT),
    getFunc = function() return ElderScrollsOfAlts.view.SettingsViewName end,
    setFunc = function(value)   ElderScrollsOfAlts.view.SettingsViewName = value  end,
    width   = "half",	--or "half" (optional)
    isMultiline = false,
    isExtraWide = false,
    default = "", -- default value or function that returns the default value (optional)      
    reference = "ESOASettingsTitleEditbox" -- unique global reference to control (optional)
  }
  --xxx
  optionsTable [#optionsTable+1] = {
    type    = "checkbox",
    name    = GetString(ESOA_SETTINGS_EDITVIEWSAVEALLOWODD_NM),
    tooltip = GetString(ESOA_SETTINGS_EDITVIEWSAVEALLOWODD_TT),
    getFunc = function() return ElderScrollsOfAlts.savedVariables.allowsaveoddviewnames end,
    setFunc = function(value)   ElderScrollsOfAlts.savedVariables.allowsaveoddviewnames = value end,
    width   = "half",	--or "half" (optional)
  }
  --
  optionsTable[#optionsTable+1] = {
    type    = "editbox",
    name    = GetString(ESOA_SETTINGS_EDITVIEWDATA_NAME),
    tooltip = GetString(ESOA_SETTINGS_EDITVIEWDATA_TT),
    getFunc = function() return ElderScrollsOfAlts.GetEditSelectedViewText() end,
    setFunc = function(text) ElderScrollsOfAlts.SetEditSelectedViewText(text) end,
    width   = "full",	--or "half" (optional)
    isMultiline = true,
    isExtraWide = true,
    reference = "ESOASettingsViewEditbox" -- unique global reference to control (optional)
  }
  optionsTable[#optionsTable+1] = {
    type    = "button",
    name    = GetString(ESOA_SETTINGS_TESTBUTTON_NAME),
    tooltip = GetString(ESOA_SETTINGS_TESTBUTTON_TT),
    func    = function()  ElderScrollsOfAlts:DoTestSelectedView() end,
    width   = "half",	--or "half" (optional)
    warning = GetString(ESOA_KEY_SETTINGS_NOCONFIRM),	--(optional)
  }
  optionsTable[#optionsTable+1] = {
    type    = "button",
    name    = GetString(ESOA_SETTINGS_SAVEBUTTON_NAME),
    tooltip = GetString(ESOA_SETTINGS_SAVEBUTTON_TT),
    func    = function()  ElderScrollsOfAlts:DoSaveSelectedView() end,
    width   = "half",	--or "half" (optional)
    warning = GetString(ESOA_KEY_SETTINGS_NOCONFIRM),	--(optional)
  }
  --https://github.com/sirinsidiator/ESO-LibAddonMenu/blob/master/LibAddonMenu-2.0/exampleoptions.lua
  --optionsTable[#optionsTable+1] = {
  --    type  = "submenu",
  --    name  = "All Allowable Entries in a View",
  --      controls = {
  --        [1] = {
  --        },
  --      }  
  --}
  optionsTable[#optionsTable+1] = {
    type    = "dropdown",
    name    = GetString(ESOA_SETTINGS_DD_VIEWENTRIES1_NAME),
    tooltip = GetString(ESOA_SETTINGS_DD_VIEWENTRIES_TT),
    choices = ElderScrollsOfAlts:ListOfViewEntries1(),
    getFunc = function() return GetString(ESOA_SETTINGS_SELECT) end,
    setFunc = function(var) ElderScrollsOfAlts:SetSelectedAllowedViewEntry(var) end,
    width = "half",	--or "half" (optional)
    reference = "ESOA_SETTINGS_ENTRIES_Select1",--TODO refresh me
  }
  optionsTable[#optionsTable+1] = {
    type    = "dropdown",
    name    = GetString(ESOA_SETTINGS_DD_VIEWENTRIES2_NAME),
    tooltip = GetString(ESOA_SETTINGS_DD_VIEWENTRIES_TT),
    choices = ElderScrollsOfAlts:ListOfViewEntries2(),
    getFunc = function() return GetString(ESOA_SETTINGS_SELECT) end,
    setFunc = function(var) ElderScrollsOfAlts:SetSelectedAllowedViewEntry(var) end,
    width = "half",	--or "half" (optional)
    reference = "ESOA_SETTINGS_ENTRIES_Select2",--TODO refresh me
  }
  optionsTable[#optionsTable+1] = {
    type    = "dropdown",
    name    = GetString(ESOA_SETTINGS_DD_VIEWENTRIES3_NAME),
    tooltip = GetString(ESOA_SETTINGS_DD_VIEWENTRIES_TT),
    choices = ElderScrollsOfAlts:ListOfViewEntries3(),
    getFunc = function() return GetString(ESOA_SETTINGS_SELECT) end,
    setFunc = function(var) ElderScrollsOfAlts:SetSelectedAllowedViewEntry(var) end,
    width = "half",	--or "half" (optional)
    reference = "ESOA_SETTINGS_ENTRIES_Select3",--TODO refresh me
  }
  optionsTable[#optionsTable+1] = {
    type    = "dropdown",
    name    = GetString(ESOA_SETTINGS_DD_VIEWENTRIES4_NAME),
    tooltip = GetString(ESOA_SETTINGS_DD_VIEWENTRIES_TT),
    choices = ElderScrollsOfAlts:ListOfViewEntries4(),
    getFunc = function() return GetString(ESOA_SETTINGS_SELECT) end,
    setFunc = function(var) ElderScrollsOfAlts:SetSelectedAllowedViewEntry(var) end,
    width = "half",	--or "half" (optional)
    reference = "ESOA_SETTINGS_ENTRIES_Select4",--TODO refresh me
  }
  optionsTable[#optionsTable+1] = {
    type    = "editbox",
    name    = GetString(ESOA_SETTINGS_ED_VIEWENTRIES_NAME),
    tooltip = GetString(ESOA_SETTINGS_ED_VIEWENTRIES_TT),
    getFunc = function() return ElderScrollsOfAlts.GetSelectedAllowedViewEntry() end,
    setFunc = function(text)    end,
    width   = "half",	--or "half" (optional)
    isMultiline = false,
    isExtraWide = false,
    --reference = "ESOASettingsViewEditbox" -- unique global reference to control (optional)
  }
  
  optionsTable[#optionsTable+1] = {
    type = "editbox",
    name = GetString(ESOA_SETTINGS_ED_ALLVIEWENTRIES_NAME),
    --tooltip = "Edit selected View!",
    getFunc = function() return ElderScrollsOfAlts.GetAllAllowedViewEntries() end,
    setFunc = function(text)    ElderScrollsOfAlts.SetAllAllowedViewEntries(text) end,
    width   = "full",	--or "half" (optional)
    isMultiline = true,
    isExtraWide = true,
    --reference = "ESOASettingsViewEditbox" -- unique global reference to control (optional)
  }

  -- VIEWS --
  
  --
  LAM:RegisterOptionControls(ElderScrollsOfAlts.menuName, optionsTable)
end

------------------------------
-- 
function ElderScrollsOfAlts.LoadSettings2()
  --
end

--EOF
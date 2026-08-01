EPT = EPT or {}
local EPT = EPT

local fontNames = {
  [1] = "Univers57",
  [2] = "Univers67",
  [3] = "ProseAntique",
  [4] = "Handwritten",
  [5] = "StoneTablet",
}

local positionUpDown = {
  [1] = "above",
  [2] = "below"
}

local originList = {
  EPT_ORIGIN_ALL,
  EPT_ORIGIN_ARENA ,
  EPT_ORIGIN_TRIAL ,
  EPT_ORIGIN_DUNGEON ,
  EPT_ORIGIN_UNDAUNTED ,
  EPT_ORIGIN_CRAFTING ,
  EPT_ORIGIN_OVERLAND ,
  EPT_ORIGIN_MISC ,
  EPT_ORIGIN_MYTHIC,
  EPT_ORIGIN_PVP,
}

local filterLists = {
  [1] = EPT_SETTINGS_FILTER_WHITE,
  [2] = EPT_SETTINGS_FILTER_BLACK,
}

local actions = {
  [1] = EPT_SETTINGS_BUTTON_ADD,
  [2] = EPT_SETTINGS_BUTTON_REMOVE,
}

local function SettingsInformation( self )
  return
  {
    {
        type = "header",
        name = EPT_SETTINGS_COLORS,
    },
  }
end

local function SettingsDesign(self)
  local design = self.store.design
  return
  {
    {
        type = "description",
        --title = "My Title",	--(optional)
        title = nil,	--(optional)
        text = EPT_DUMMY_DESCRIPTION,
        width = "half",	--or "half" (optional)
    },
    {
        type = "button",
        name = EPT_DUMMY_BUTTON,
        tooltip = "",
        func = function()
          self.demo.set.hidden = not self.demo.set.hidden
          self.demo.set.win:SetHidden(self.demo.set.hidden)
        end,
        width = "half",	--or "half" (optional)

        --warning = "Will need to reload the UI.",	--(optional)
    },
    {
        type = "slider",
        name = EPT_SETTINGS_ICONSIZE_NAME,
        tooltip = EPT_SETTINGS_ICONSIZE_TOOLTIP,
        min = 20,
        max = 80,
        step = 5,	--(optional)
        getFunc = function() return design.iconSize end,
        setFunc = function(newValue)
          design.iconSize = newValue
          self:UpdateDesign()
        end,
        width = "half",
        --default = 5,	--(optional)
    },
    {
        type = "dropdown",
        name = EPT_SETTINGS_FONT_NAME,
        tooltip = EPT_SETTINGS_FONT_TOOLTIP,
        choices = fontNames,
        getFunc = function() return fontNames[design.font] end,
        setFunc = function(fontName)
            for index, name in ipairs(fontNames) do
              if name == fontName then
                design.font = index
                break
              end
            end
            self:UpdateDesign()
          end,
          width = "half"
    },
    {
        type = "description",
        --title = "My Title",	--(optional)
        title = nil,	--(optional)
        text = EPT_SPECIAL_NOTE,
        width = "full",	--or "half" (optional)
    },
    {
        type = "header",
        name = EPT_SETTINGS_COLORS,
        width = "full",	--or "half" (optional)
    },
    {
        type = "header",
        name = EPT_SETTINGS_COLOR_TIMER,
        width = "half",	--or "half" (optional)
    },
    {
        type = "header",
        name = EPT_SETTINGS_COLOR_VALUE,
        width = "half",	--or "half" (optional)
    },
    {
      type = "colorpicker",
      name = EPT_SETTINGS_COLOR_ACTIVE_NAME,
      tooltip = EPT_SETTINGS_COLOR_ACTIVE_TOOLTIP,
      getFunc = function() return unpack(design.color.active) end,	--(alpha is optional)
      setFunc = function(r,g,b,a)
        design.color.active = {r, g, b, a}
      end,
      width = "half",	--or "half" (optional)
    },

    {
      type = "colorpicker",
      name = EPT_SETTINGS_COLOR_HIGH_NAME,
      tooltip = EPT_SETTINGS_COLOR_HIGH_TOOLTIP,
      getFunc = function() return unpack(design.color.high) end,	--(alpha is optional)
      setFunc = function(r,g,b,a)
        design.color.high = {r, g, b, a}
      end,
      width = "half",	--or "half" (optional)
    },

    {
      type = "colorpicker",
      name = EPT_SETTINGS_COLOR_COOLDOWN_NAME,
      tooltip = EPT_SETTINGS_COLOR_COOLDOWN_TOOLTIP,
      getFunc = function() return unpack(design.color.cooldown) end,	--(alpha is optional)
      setFunc = function(r,g,b,a)
        design.color.cooldown = {r, g, b, a}
      end,
      width = "half",	--or "half" (optional)
    },
    {
      type = "colorpicker",
      name = EPT_SETTINGS_COLOR_MEDIUM_NAME,
      tooltip = EPT_SETTINGS_COLOR_MEDIUM_TOOLTIP,
      getFunc = function() return unpack(design.color.medium) end,	--(alpha is optional)
      setFunc = function(r,g,b,a)
        design.color.medium = {r, g, b, a}
      end,
      width = "half",	--or "half" (optional)
    },

    {
      type = "colorpicker",
      name = EPT_SETTINGS_COLOR_STAMDBY_NAME,
      tooltip = EPT_SETTINGS_COLOR_STAMDBY_TOOLTIP,
      getFunc = function() return unpack(design.color.standby) end,	--(alpha is optional)
      setFunc = function(r,g,b,a)
        design.color.standby = {r, g, b, a}
      end,
      width = "half",	--or "half" (optional)
    },

    {
      type = "colorpicker",
      name = EPT_SETTINGS_COLOR_LOW_NAME,
      tooltip = EPT_SETTINGS_COLOR_LOW_TOOLTIP,
      getFunc = function() return unpack(design.color.low) end,	--(alpha is optional)
      setFunc = function(r,g,b,a)
        design.color.low = {r, g, b, a}
      end,
      width = "half",	--or "half" (optional)
    },

    {
      type = "header",
      name = EPT_SETTINGS_INDICATOR,
      width = "full",	--or "half" (optional)
    },
    {
      type = "checkbox",
      name = EPT_SETTINGS_INDICATOR_SHOW_DECIMAL_NAME,
      tooltip = EPT_SETTINGS_INDICATOR_SHOW_DECIMAL_TOOLTIP,
      getFunc = function() return design.indicator.showDecimal end,
      setFunc = function(bool)
        design.indicator.showDecimal = bool
      end,
      width = "half"
    },
    {
      type = "checkbox",
      name = EPT_SETTINGS_INDICATOR_CHANGE_COLOR_NAME,
      tooltip = EPT_SETTINGS_INDICATOR_CHANGE_COLOR_TOOLTIP,
      getFunc = function() return design.indicator.changeColor end,
      setFunc = function(bool)
        design.indicator.changeColor = bool
      end,
      width = "half"
    },
    {
        type = "slider",
        name = EPT_SETTINGS_INDICATOR_SIZE_NAME,
        tooltip = EPT_SETTINGS_INDICATOR_SIZE_TOOLTIP,
        min = 1,
        max = 11,
        step = 1,	--(optional)
        getFunc = function() return design.indicator.size end,
        setFunc = function(newValue)
          design.indicator.size = newValue
          self:UpdateDesign()
        end,
        width = "half",
        --default = 5,	--(optional)
    },
    {
        type = "dropdown",
        name = EPT_SETTINGS_INDICATOR_FONT_NAME,
        tooltip = EPT_SETTINGS_INDICATOR_FONT_TOOLTIP,
        choices = fontNames,
        getFunc = function() return fontNames[design.indicator.font] end,
        setFunc = function(fontName)
            for index, name in ipairs(fontNames) do
              if name == fontName then
                design.indicator.font = index
                break
              end
            end
            self:UpdateDesign()
          end,
        width = "half"
    },
    {
        type = "slider",
        name = EPT_SETTINGS_INDICATOR_OFFSETX_NAME,
        tooltip = EPT_SETTINGS_INDICATOR_OFFSETX_TOOLTIP,
        min = -100,
        max = 100,
        step = 1,	--(optional)
        getFunc = function() return design.indicator.offSetX end,
        setFunc = function(newValue)
          design.indicator.offSetX = newValue
          self:UpdateDesign()
        end,
        width = "half",
        --default = 5,	--(optional)
    },
    {
        type = "slider",
        name = EPT_SETTINGS_INDICATOR_OFFSETY_NAME,
        tooltip = EPT_SETTINGS_INDICATOR_OFFSETY_TOOLTIP,
        min = -100,
        max = 100,
        step = 1,	--(optional)
        getFunc = function() return design.indicator.offSetY end,
        setFunc = function(newValue)
          design.indicator.offSetY = newValue
          self:UpdateDesign()
        end,
        width = "half",
        --default = 5,	--(optional)
    },

    {
        type = "header",
        name = EPT_SETTINGS_EDGE,
        width = "full",	--or "half" (optional)
    },
    {
      type = "checkbox",
      name = EPT_SETTINGS_EDGE_SHOW_NAME,
      tooltip = EPT_SETTINGS_EDGE_SHOW_TOOLTIP,
      getFunc = function() return design.edge.show end,
      setFunc = function(bool)
        design.edge.show = bool
        self:UpdateDesign()
      end,
      width = "half"
    },
    {
      type = "checkbox",
      name = EPT_SETTINGS_EDGE_CHANGE_COLOR_NAME,
      tooltip = EPT_SETTINGS_EDGE_CHANGE_COLOR_TOOLTIP,
      getFunc = function() return design.edge.changeColor end,
      setFunc = function(bool)
        design.edge.changeColor = bool
        self:UpdateDesign()
      end,
      width = "half"
    },
    {
        type = "slider",
        name = EPT_SETTINGS_EDGE_SIZE_NAME,
        tooltip = EPT_SETTINGS_EDGE_SIZE_TOOLTIP,
        min = 0,
        max = 20,
        step = 2,	--(optional)
        getFunc = function() return design.edge.size end,
        setFunc = function(newValue)
          design.edge.size = newValue
          self:UpdateDesign()
        end,
        width = "half",
    },


    {
        type = "header",
        name = EPT_SETTINGS_NAME_DISPLAY,
        width = "full",	--or "half" (optional)
    },
    {
        type = "slider",
        name = EPT_SETTINGS_NAME_DISPLAY_SIZE_NAME,
        tooltip = EPT_SETTINGS_NAME_DISPLAY_SIZE_TOOLTIP,
        min = 5,
        max = 50,
        step = 5,	--(optional)
        getFunc = function() return design.nameDisplay.size end,
        setFunc = function(newValue)
          design.nameDisplay.size = newValue
          self:UpdateDesign()
        end,
        width = "half",
        --default = 5,	--(optional)
    },
    {
        type = "dropdown",
        name = EPT_SETTINGS_NAME_DISPLAY_POSITION_NAME,
        tooltip = EPT_SETTINGS_NAME_DISPLAY_POSITION_TOOLTIP,
        choices = positionUpDown,
        getFunc = function() return design.nameDisplay.position end,
        setFunc = function(position)
          design.nameDisplay.position = position
          self:UpdateDesign()
          end,
          width = "half"
    },
    {
      type = "checkbox",
      name = EPT_SETTINGS_NAME_DISPLAY_GAME_NAME,
      tooltip = EPT_SETTINGS_NAME_DISPLAY_GAME_TOOLTIP,
      getFunc = function() return design.nameDisplay.gameMode end,
      setFunc = function(bool)
        design.nameDisplay.gameMode = bool
        self:UpdateDesign()
      end,
      width = "half"
    },
    {
      type = "checkbox",
      name = EPT_SETTINGS_NAME_DISPLAY_SHOW_BACKGROUND_NAME,
      tooltip = EPT_SETTINGS_NAME_DISPLAY_SHOW_BACKGROUND_TOOLTIP,
      getFunc = function() return design.nameDisplay.showBackground end,
      setFunc = function(bool)
        design.nameDisplay.showBackground = bool
        self:UpdateDesign()
      end,
      width = "half"
    },
    {
      type = "checkbox",
      name = EPT_SETTINGS_NAME_DISPLAY_MOUSE_NAME,
      tooltip = EPT_SETTINGS_NAME_DISPLAY_MOUSE_TOOLTIP,
      getFunc = function() return design.nameDisplay.mouseMode end,
      setFunc = function(bool)
        design.nameDisplay.mouseMode = bool
        self:UpdateDesign()
      end,
      width = "half"
    },
    --{
    --  type = "checkbox",
    --  disabled = true,
    --  name = EPT_SETTINGS_NAME_DISPLAY_HOVER_NAME,
    --  tooltip = EPT_SETTINGS_NAME_DISPLAY_HOVER_TOOLTIP,
    --  getFunc = function() return design.nameDisplay.mouseHover end,
    --  setFunc = function(bool)
    --    design.nameDisplay.mouseHover = bool
    --    self:UpdateDesign()
    --  end,
    --  width = "half"
    --},
    {
        type = "header",
        name = EPT_SETTINGS_TRANSPARENCY,
        width = "full",	--or "half" (optional)
    },
    {
      type = "checkbox",
      name = EPT_SETTINGS_TRANSPARENCY_NAME,
      --tooltip = EPT_SETTINGS_TRANSPARENCY_TOOLTIP,
      getFunc = function() return design.hiding end,
      setFunc = function(bool)
        design.hiding = bool
        self.SetVisibility()
      end,
      width = "full",
      warning = EPT_SETTINGS_TRANSPARENCY_WARNING
    },
  }
end

local function SettingsSpecialSets(self)
  return {
      {
          type = "description",
          --title = "My Title",	--(optional)
          title = nil,	--(optional)
          text = EPT_SPECIAL_NOTE,
          width = "full",	--or "half" (optional)
      },
      {
        type = "submenu",
        name = self.procSets[496].setName,
        controls = self:SettingsOpportunist()
      },
      {
        type = "submenu",
        name = self.procSets[455].setName,
        controls = self:SettingsZen()
      },
      {
        type = "submenu",
        name = self.procSets[147].setName,
        controls = self:SettingsMartial()
      },
    }
end

local function SettingsFilter(self)
  return {
    {
      type = "checkbox",
      name = EPT_SETTINGS_FILTER_ACTIVE_NAME,
      tooltip = EPT_SETTINGS_FILTER_ACTIVE_TOOLTIP,
      getFunc = function() return self.store.filter.active end,
      setFunc = function(bool)
        self.store.filter.active = bool
        EPT.ResetGui()
      end,
      width = "full",
      warning = "Reload UI"
    },
--    {
--      type = "checkbox",
--      disabled = function() return not self.store.filter.active end,
--      name = EPT_SETTINGS_FILTER_TYPE_NAME,
--      tooltip = EPT_SETTINGS_FILTER_TYPE_TOOLTIP,
--      getFunc = function() return self.store.filter.type end,
--      setFunc = function(bool)
--        self.store.filter.type = bool
--        EPT.ResetGui()
--      end,
--      width = "full",
--      warning = "Reload UI"
--    },
    {
      type = "dropdown",
      disabled = function() return not self.store.filter.active end,
      name = EPT_SETTINGS_FILTER_TYPE_NAME,
      tooltip = "",
      choices = filterLists,
      getFunc = function()
          local i
          if self.store.filter.type then i=1 else i=2 end
          return filterLists[i]
        end,
      setFunc = function( select )
          if select == EPT_SETTINGS_FILTER_WHITE then
            self.store.filter.type = true
          else
            self.store.filter.type = false
          end
          self.ResetGui()
        end,
      width = "Full",
      --warning = "Reload UI"
    },
    {
      type = "header",
      name = EPT_SETTINGS_FILTER_MANAGE_LIST,
      width = "full",	--or "half" (optional)
    },
    --    {
    --      type = "checkbox",
    --      name = EPT_SETTINGS_FILTER_TYPE_NAME,
    --      --onText = "White",
    --      --offText = "Black",
    --      tooltip = EPT_SETTINGS_FILTER_TYPE_TOOLTIP,
    --      getFunc = function() return self.filter.type end,
    --      setFunc = function(bool)
    --        self.filter.type = bool
    --        EPT_Filter_Set_List:UpdateChoices(self:FilterSetChoices())
    --        EPT.ResetGui()
    --      end,
    --      width = "full"
    --    },
    {
      type = "dropdown",
      name = EPT_SETTINGS_FILTER_TYPE_NAME,
      tooltip = "",
      choices = filterLists,
      getFunc = function()
          local i
          if self.filter.type then i=1 else i=2 end
          return filterLists[i]
        end,
      setFunc = function( select )
          if select == EPT_SETTINGS_FILTER_WHITE then
            self.filter.type = true
          else
            self.filter.type = false
          end
          EPT_Filter_Set_List:UpdateChoices(self:FilterSetChoices())
        end,
      width = "Full",
      --warning = "Reload UI"
    },
--    {
--      type = "checkbox",
--      --disabled = function() return not self.store.filter.active end,
--      name = EPT_SETTINGS_FILTER_SELECT_ACTION,
--      tooltip = EPT_SETTINGS_FILTER_SELECT_ACTION_TOOLTIP,
--      getFunc = function() return self.filter.action end,
--      setFunc = function(bool)
--        self.filter.action = bool
--        --EPT_Filter_Button:UpdateName(bool and EPT_SETTINGS_BUTTON_ADD or EPT_SETTINGS_BUTTON_REMOVE)
--        --EPT_Filter_Button:UpdateName("test")
--        EPT_Filter_Set_List:UpdateChoices(self:FilterSetChoices())
--        EPT.ResetGui()
--      end,
--      width = "full"
--    },
    {
      type = "dropdown",
      name = EPT_SETTINGS_FILTER_SELECT_ACTION,
      tooltip = "",
      choices = actions,
      getFunc = function()
          local i
          if self.filter.action then i=1 else i=2 end
          return actions[i]
        end,
      setFunc = function( select )
          if select == EPT_SETTINGS_BUTTON_ADD then
            self.filter.action = true
          else
            self.filter.action = false
          end
          EPT_Filter_Set_List:UpdateChoices(self:FilterSetChoices())
        end,
      width = "Full",
      --warning = "Reload UI"
    },
    {
        type = "dropdown",
        --disabled = function() return not self.store.filter.active end,
        name = EPT_SETTINGS_FILTER_SELECT_ORIGIN,
        tooltip = "",
        choices = originList,
        getFunc = function() return self.filter.origin end,
        setFunc = function( select )
          self.filter.origin = select
          EPT_Filter_Set_List:UpdateChoices(self:FilterSetChoices())
          end,
        width = "Full",
    },
    {
        type = "dropdown",
        --disabled = function() return not self.store.filter.active end,
        name = EPT_SETTINGS_FILTER_SELECT_SET,
        tooltip = "",
        choices = self:FilterSetChoices(),
        getFunc = function() return end,
        setFunc = function(select)
          self.filter.selected = self.GetSetIdBySetName(select)
          --EPT_Filter_Set_List:UpdateChoices(self:FilterSetChoices())
          end,
        width = "Full",
        reference = "EPT_Filter_Set_List",
        scrollable = true,
    },
    {
        type = "description",
        --title = "My Title",	--(optional)
        title = nil,	--(optional)
        text = "",
        width = "half",	--or "half" (optional)
        reference = "EPT_Filter_Output"
    },
    {
        type = "button",
        --name = self.filter.action and EPT_SETTINGS_BUTTON_ADD or EPT_SETTINGS_BUTTON_REMOVE,
        name = "Execute",
        tooltip = "",
        func = function()
          local setId = self.filter.selected
          if setId ~= nil then
            self.store[setId][self.filter.type and "whiteList" or "blackList"] = self.filter.action
          end
          EPT_Filter_Set_List:UpdateChoices( self:FilterSetChoices() )
          self.ResetGui()
        end,
        width = "half",	--or "half" (optional)
        reference = "EPT_Filter_Button",
        --warning = "Will need to reload the UI.",	--(optional)
    },
--    {
--      type = "header",
--      name = EPT_SETTINGS_FILTER_SET_INFO,
--      width = "full",	--or "half" (optional)
--    },
--    {
--        type = "dropdown",
--        name = EPT_SETTINGS_FILTER_SELECT_ORIGIN,
--        tooltip = "",
--        choices = originList,
--        getFunc = function() return self.filter.originInfo end,
--        setFunc = function( select )
--          self.filter.originInfo = select
--          EPT_Filter_Set_List_Info:UpdateChoices(self:FilterSetChoices())
--          EPT_OnBlacklist:UpdateValue()
--          end,
--        width = "half",
--    },
--    {
--        type = "dropdown",
--        name = EPT_SETTINGS_FILTER_SELECT_SET,
--        tooltip = "",
--        choices = self:FilterSetChoices(),
--        getFunc = function() return end,
--        setFunc = function(select)
--          self.filter.selectedInfo = self.GetSetIdBySetName(select)
--          EPT_OnBlacklist:UpdateValue()
--          end,
--        width = "half",
--        reference = "EPT_Filter_Set_List_Info",
--    },
--    {
--        type = "description",
--        --title = "My Title",	--(optional)
--        title = nil,	--(optional)
--        text = function() return self.filter.originInfo end,
--        width = "full",	--or "half" (optional)
--        reference = "EPT_OnBlacklist",
--    },
  }
end

local function SettingsFeedback(self)
  return
  {

  }
end


local function SettingsNormalPerfectedSets(self)
  return {
      {
          type = "slider",
          name = "OverWrite required number of pieces",
          tooltip = "Set to 5, to have the addon work as usual!" ,
          min =1,
          max =5,
          step =1,	--(optional)
          getFunc = function() return self.store.setPieceOverwrite end,
          setFunc = function(newValue)
            self.store.setPieceOverwrite = newValue
          end,
          width = "half",
          warning = "changes required \reloadui",
      },
      {
          type = "divider",
      },
      {
          type = "description",
          title = "Overwrite for Combination of normal and perfected Setpieces",
          text = "This options provides a workaround to be able to combine normal and perfected Gear. Keep in mind this is only meant as a hotfix until a more permanent solution is created.",
      },
      {
          type = "divider",
      },
      {
          type = "description",
          title = "How to use it:",
          text = "If you combine normal and perfected gear, set the slider to 3. Then check if the icon will track the set by proccing it."..
                  "If the icon doesnt work, set the slider to the number of normal pieces you are wearing.",
      },
      {
          type = "divider",
      },
      {
          type = "description",
          title = "Known Issues: ",
          text = "+ if you set the slider below 3, an icon will be shown for each, normal and perfect set. Depending on the set both or only the normal icon will actually track the set. \n"..
                 "+ this workaround will effect all sets with a five piece bonus, regardless if there exists a normal and perfected version or not.\n" ..
                 "That means: if you set the overwrite to 3 and have only three pieces of, for exammple, hollowfang in a setup. It will also show the hollowfang icon.",
      },
    }
end

function EPT:CreateAddonMenu()
  local panelData = {
  type                = "panel",
  name                = self.displayName,
  displayName         = self.displayName,
  author              = self.author,
  version             = self.version,
  registerForRefresh = true,
  }

  local optionsTable = {
    {
        type = "description",
        --title = "My Title",	--(optional)
        title = nil,	--(optional)
        text = EPT_FEEDBACK_DESCRIPTION,
        width = "half",	--or "half" (optional)
    },
    {
        type = "button",
        name = EPT_FEEDBACK_BUTTON,
        tooltip = "",
        func = function()
              local server = GetWorldName()
              local function PrefillMail()
                ZO_MailSendToField:SetText("@Exoy94")
                ZO_MailSendSubjectField:SetText(self.name)
                ZO_MailSendBodyField:TakeFocus()
              end
              --if GetWorldName() == "EU Megaserver" then
                SCENE_MANAGER:Show('mailSend')
                zo_callLater(PrefillMail, 250)
              --end
        end,
        width = "half",	--or "half" (optional)
        warning = EPT_FEEDBACK_WARNING,	--(optional)
    },
    {
      type = "checkbox",
      name = EPT_SETTINGS_FILTER_ACTIVE_NAME,
      tooltip = EPT_SETTINGS_FILTER_ACTIVE_TOOLTIP,
      getFunc = function() return self.store.setPieceOverwrite end,
      setFunc = function()
        self.store.setPieceOverwrite = bool
        EPT.ResetGui()
      end,
      width = "full",
      warning = "Reload UI"
    },

  }

  table.insert(optionsTable, {type = "submenu", name = EPT_SETTINGS_DESIGN, controls = SettingsDesign(self)})
  table.insert(optionsTable, {type = "submenu", name = EPT_SETTINGS_SPECIAL, controls = SettingsSpecialSets(self)})
  table.insert(optionsTable, {type = "submenu", name = EPT_SETTINGS_FILTER, controls = SettingsFilter(self)})
  table.insert(optionsTable, {type = "submenu", name = "Normal/Perfected Gear", controls = SettingsNormalPerfectedSets(self)})

  LibAddonMenu2:RegisterAddonPanel( self.name .. "Options", panelData )
  LibAddonMenu2:RegisterOptionControls( self.name .. "Options", optionsTable )
end

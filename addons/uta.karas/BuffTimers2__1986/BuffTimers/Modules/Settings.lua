local profileCreatable = false
local profileCreateDst = ''
local profileCreateSrc = BuffTimers.defaultProfile
local profileDeletable = false
local profileDeleteTgt = BuffTimers.defaultProfile

function BuffTimers:SettingsBuildMenu()
  local addonPanel = {
    type                = 'panel',
    name                = self.name,
    displayName         = ZO_ColorDef:New('3366cc'):Colorize(self.name),
    author              = self.author,
    version             = self.version,
    registerForRefresh  = true,
    registerForDefaults = true,
  }

  local icon_list = {''}
  local icon_tips = {'Use Default'}
  for skillType=1, GetNumSkillTypes() do
    for skillIndex=1, GetNumSkillLines(skillType) do
      for abilityIndex=1, GetNumSkillAbilities(skillType, skillIndex) do
        abilityName, abilityIcon = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
        table.insert(icon_list, abilityIcon)
        table.insert(icon_tips, abilityName)
      end
    end
  end

  local optionControls = {
    {
      type = 'header',
      name = ZO_ColorDef:New('6699ff'):Colorize('Profiles'),
    },
    {
      type = 'dropdown',
      name = 'Choose Profile',
      choices = self.profiles.profileNames,
      reference = 'selfProfileDropdown1',
      warning = 'Reload UI',
      getFunc = function() return self.player.activeProfile end,
      setFunc = function(value)
        if value ~= self.player.activeProfile then
          self:ProfileLoad(value)
          ReloadUI()
        end
      end,
    },
    {
      type = 'submenu',
      name = 'Create Profile',
      controls = {
        {
          type = 'dropdown',
          name = 'Copy From',
          choices = self.profiles.profileNames,
          reference = 'selfProfileDropdown2',
          getFunc = function() return profileCreateSrc end,
          setFunc = function(value) profileCreateSrc = value end,
        },
        {
          type = 'editbox',
          name = 'Profile Name',
          warning = function()
            if profileCreatable then
              return false
            else
              if profileCreateDst == '' then
                return false
              else
                return 'Already Taken'
              end
            end
          end,
          getFunc = function() return profileCreateDst end,
          setFunc = function(value)
            if value == '' then
              profileCreatable = false
              profileCreateDst = value
            else
              profileCreatable = true
              profileCreateDst = value
              for k, v in pairs(self.profiles.profileNames) do
                if v == profileCreateDst then profileCreatable = false end
              end
            end
            CALLBACK_MANAGER:FireCallbacks('LAM-RefreshPanel', BuffTimersPanel)
          end,
        },
        {
          type = 'button',
          name = 'Create',
          func = function()
            self:ProfileCreate(profileCreateDst, profileCreateSrc)
            profileCreatable = false
            profileCreateDst = ''
            selfProfileDropdown1:UpdateChoices(self.profiles.profileNames)
            selfProfileDropdown2:UpdateChoices(self.profiles.profileNames)
            selfProfileDropdown3:UpdateChoices(self.profiles.profileNames)
            CALLBACK_MANAGER:FireCallbacks('LAM-RefreshPanel', BuffTimersPanel)
          end,
          disabled = function() return not profileCreatable end,
        },
      },
    },
    {
      type = 'submenu',
      name = 'Delete Profile',
      controls = {
        {
          type = 'dropdown',
          name = 'Target Profile',
          choices = self.profiles.profileNames,
          reference = 'selfProfileDropdown3',
          getFunc = function() return profileDeleteTgt end,
          setFunc = function(value)
            profileDeleteTgt = value
            if profileDeleteTgt == self.defaultProfile then
              profileDeletable = false
            else
              profileDeletable = true
            end
          end,
        },
        {
          type = 'button',
          name = 'Delete',
          disabled = function() return not profileDeletable end,
          func = function()
            if profileDeleteTgt == self.player.activeProfile then
              self:ProfileLoad(self.defaultProfile)
              self:ProfileDelete(profileDeleteTgt)
              ReloadUI()
            else
              self:ProfileDelete(profileDeleteTgt)
              profileDeletable = false
              profileDeleteTgt = self.defaultProfile
              selfProfileDropdown1:UpdateChoices(self.profiles.profileNames)
              selfProfileDropdown2:UpdateChoices(self.profiles.profileNames)
              selfProfileDropdown3:UpdateChoices(self.profiles.profileNames)
              CALLBACK_MANAGER:FireCallbacks('LAM-RefreshPanel', BuffTimersPanel)
            end
          end,
        },
      },
    },
  }

  if self.settings.notification.enable then
    ZO_CombineNumericallyIndexedTables(optionControls, {
      {
        type = 'header',
        name = ZO_ColorDef:New('6699ff'):Colorize('Notification Settings'),
      },
      {
        type = 'checkbox',
        name = 'Notification Enable',
        warning = 'Reload UI',
        getFunc = function() return self.settings.notification.enable end,
        setFunc = function()
          self.settings.notification.enable = not self.settings.notification.enable
          ReloadUI()
        end,
      },
      {
        type = 'slider',
        name = 'Notification Duration',
        min = 1,
        max = 10,
        step = 0.5,
        getFunc = function() return self.settings.notification.duration end,
        setFunc = function(number) self.settings.notification.duration = number end,
      },
      {
        type = 'colorpicker',
        name = 'Notification Color',
        getFunc = function() return unpack(self.settings.notification.color) end,
        setFunc = function(r,g,b,a)
          self.settings.notification.color = {r,g,b,a}
          self:NotificationApplySettings()
        end,
      },
      {
        type = 'checkbox',
        name = 'Notification Lock',
        getFunc = function() return self.settings.notification.locked end,
        setFunc = function()
          self.settings.notification.locked = not self.settings.notification.locked
          self:NotificationApplySettings()
          if self.settings.notification.locked then
            self.notification.label:SetText('')
          else
            self.notification.label:SetText('--------- Notification here! ---------')
          end
        end,
      },
    })
  else
    ZO_CombineNumericallyIndexedTables(optionControls, {
      {
        type = 'header',
        name = ZO_ColorDef:New('6699ff'):Colorize('Notification Settings'),
      },
      {
        type = 'checkbox',
        name = 'Notification Enable',
        warning = 'Reload UI',
        getFunc = function() return self.settings.notification.enable end,
        setFunc = function()
          self.settings.notification.enable = not self.settings.notification.enable
          ReloadUI()
        end,
      },
    })
  end

  ZO_CombineNumericallyIndexedTables(optionControls, {
    {
      type = 'header',
      name = ZO_ColorDef:New('6699ff'):Colorize('Bar Settings'),
    },
    {
      type = 'submenu',
      name = 'Common',
      controls = {
        {
          type = 'slider',
          name = 'Number of Bars',
          min = 1,
          max = 15,
          step = 1,
          warning = 'Reload UI',
          getFunc = function() return self.settings.numberBars end,
          setFunc = function(number)
            self.settings.numberBars = number
            for k, v in pairs(self.settings.buffNames) do
              if v > number then
                self.settings.buffNames[k]  = nil
              end
            end
            while #self.settings.barData > number do
              table.remove(self.settings.barData, (number + 1))
            end
            ReloadUI()
          end,
        },
        {
          type = 'slider',
          name = 'Interval of refreshing bar (ms)',
          min = 100,
          max = 1000,
          step = 100,
          getFunc = function() return self.settings.updateSpeed end,
          setFunc = function(number) self.settings.updateSpeed = number end,
        },
      },
    },
  })

  for i=1, self.settings.numberBars do
    local barOptions = {
      {
        type = 'submenu',
        name = 'Bar ' .. i,
        controls = {
          {
            type = 'checkbox',
            name = 'Lock',
            getFunc = function() return self.settings.barData[i].locked end,
            setFunc = function()
              self.settings.barData[i].locked = not self.settings.barData[i].locked
              self:WindowApplySettings(i, self.settings.barData[i])
            end,
          },
          {
            type = 'checkbox',
            name = 'Always Show',
            getFunc = function() return self.settings.barData[i].alwaysShow end,
            setFunc = function()
              self.settings.barData[i].alwaysShow = not self.settings.barData[i].alwaysShow
              self:WindowApplySettings(i, self.settings.barData[i])
            end,
          },
          {
            type = 'editbox',
            name = 'Buff Name',
            getFunc = function() return self.settings.barData[i].buffName end,
            setFunc = function(value)
              for k, v in pairs(self.settings.buffNames) do
                if v == i then self.settings.buffNames[k] = nil end
              end
              if tonumber(value) then
                self.settings.buffNames[tonumber(value)] = i
              else
                self.settings.buffNames[value] = i
              end
              self.settings.barData[i].buffName = value
            end,
          },
          {
            type = 'header',
            name = 'Display Settings',
          },
          {
            type = 'slider',
            name = 'Width',
            min = 0,
            max = 1000,
            step = 5,
            getFunc = function() return self.settings.barData[i].width end,
            setFunc = function(number)
              self.settings.barData[i].width = number
              self:WindowApplySettings(i, self.settings.barData[i])
            end,
          },
          {
            type = 'slider',
            name = 'Height',
            min = 0,
            max = 200,
            step = 5,
            getFunc = function() return self.settings.barData[i].height end,
            setFunc = function(number)
              self.settings.barData[i].height = number
              self:WindowApplySettings(i, self.settings.barData[i])
            end,
          },
          {
            type = 'slider',
            name = 'Text Size',
            min = 10,
            max = 100,
            step = 2,
            getFunc = function() return self.settings.barData[i].textSize end,
            setFunc = function(number)
              self.settings.barData[i].textSize = number
              self:WindowApplySettings(i, self.settings.barData[i])
            end,
          },
          {
            type = 'checkbox',
            name = 'Reverse Bar Direction',
            getFunc = function() return self.settings.barData[i].reverse end,
            setFunc = function()
              self.settings.barData[i].reverse = not self.settings.barData[i].reverse
              self:WindowApplySettings(i, self.settings.barData[i])
            end,
          },
          {
            type = 'colorpicker',
            name = 'Bar Color Left',
            getFunc = function() return self.settings.barData[i].colorBar[1], self.settings.barData[i].colorBar[2], self.settings.barData[i].colorBar[3], self.settings.barData[i].colorBar[4] end,
            setFunc = function(r,g,b,a)
              self.settings.barData[i].colorBar[1] = r
              self.settings.barData[i].colorBar[2] = g
              self.settings.barData[i].colorBar[3] = b
              self.settings.barData[i].colorBar[4] = a
              self:WindowApplySettings(i, self.settings.barData[i])
            end,
          },
          {
            type = 'colorpicker',
            name = 'Bar Color Right',
            getFunc = function() return self.settings.barData[i].colorBar[5], self.settings.barData[i].colorBar[6], self.settings.barData[i].colorBar[7], self.settings.barData[i].colorBar[8] end,
            setFunc = function(r,g,b,a)
              self.settings.barData[i].colorBar[5] = r
              self.settings.barData[i].colorBar[6] = g
              self.settings.barData[i].colorBar[7] = b
              self.settings.barData[i].colorBar[8] = a
              self:WindowApplySettings(i, self.settings.barData[i])
            end,
          },
          {
            type = 'colorpicker',
            name = 'Bar Color Edge',
            getFunc = function() return unpack(self.settings.barData[i].colorEdge) end,
            setFunc = function(r,g,b,a)
              self.settings.barData[i].colorEdge = {r,g,b,a}
              self:WindowApplySettings(i, self.settings.barData[i])
            end,
          },
          {
            type = 'colorpicker',
            name = 'Bar Color Background',
            getFunc = function() return unpack(self.settings.barData[i].colorBackground) end,
            setFunc = function(r,g,b,a)
              self.settings.barData[i].colorBackground = {r,g,b,a}
              self:WindowApplySettings(i, self.settings.barData[i])
            end,
          },
          {
            type = 'colorpicker',
            name = 'Text Color',
            getFunc = function() return unpack(self.settings.barData[i].colorLabel) end,
            setFunc = function(r,g,b,a)
              self.settings.barData[i].colorLabel = {r,g,b,a}
              self:WindowApplySettings(i, self.settings.barData[i])
            end,
          },
          {
            type = 'header',
            name = 'Icon Settings',
          },
          {
            type = 'checkbox',
            name = 'Show Icon',
            getFunc = function() return self.settings.barData[i].icon.show end,
            setFunc = function()
              self.settings.barData[i].icon.show = not self.settings.barData[i].icon.show
              self:WindowApplySettings(i, self.settings.barData[i])
            end,
          },
          {
            type = 'slider',
            name = 'Size',
            min = 10,
            max = 100,
            step = 2,
            getFunc = function() return self.settings.barData[i].icon.size end,
            setFunc = function(number)
              self.settings.barData[i].icon.size = number
              self:WindowApplySettings(i, self.settings.barData[i])
            end,
          },
          {
            type = 'colorpicker',
            name = 'Color',
            getFunc = function() return unpack(self.settings.barData[i].icon.color) end,
            setFunc = function(r,g,b,a)
              self.settings.barData[i].icon.color = {r,g,b,a}
              self:WindowApplySettings(i, self.settings.barData[i])
            end,
          },
          {
            type = 'iconpicker',
            name = 'Custom Icon',
            choices = icon_list,
            choicesTooltips = icon_tips,
            maxColumns = 10,
            visibleRows = 10,
            iconSize = 40,
            getFunc = function() return self.settings.barData[i].icon.customIconTexture end,
            setFunc = function(value)
              self.settings.barData[i].icon.customIcon = (value ~= '')
              self.settings.barData[i].icon.customIconTexture = value
              self:WindowApplySettings(i, self.settings.barData[i])
            end,
          },
        },
      },
    }
    if self.settings.notification.enable then
      ZO_CombineNumericallyIndexedTables(barOptions[1].controls, {
        {
          type = 'header',
          name = 'Notification Settings',
        },
        {
          type = 'slider',
          name = 'Threshold',
          tooltip = '0 means no notifications',
          min = 0,
          max = 10,
          step = 0.5,
          getFunc = function() return self.settings.barData[i].notification.threshold end,
          setFunc = function(number) self.settings.barData[i].notification.threshold = number end,
        },
        {
          type = 'dropdown',
          name = 'Sound',
          choices = self.sounds,
          getFunc = function() return self.settings.barData[i].notification.sound end,
          setFunc = function(value)
            self.settings.barData[i].notification.sound = value
            PlaySound(value)
          end,
        },
        {
          type = 'checkbox',
          name = 'Text Notification',
          getFunc = function() return self.settings.barData[i].notification.text end,
          setFunc = function() self.settings.barData[i].notification.text = not self.settings.barData[i].notification.text end,
        },
        {
          type = 'editbox',
          name = 'Custom Text',
          getFunc = function() return self.settings.barData[i].notification.customText end,
          setFunc = function(value) self.settings.barData[i].notification.customText = value end,
        },
      })
    end
    table.insert(optionControls, barOptions[1])
  end

  ZO_CombineNumericallyIndexedTables(optionControls, {
    {
      type = 'header',
      name = ZO_ColorDef:New('6699ff'):Colorize('Group/Raid Buffs Settings'),
    },
  })
  for i=1, #self.groupBuffs do
    local barNumber = self.groupBuffs[i].barNumber
    local groupBuffOptions = {
      {
        type = 'submenu',
        name = 'Track ' .. self.groupBuffs[i].name .. ' in group/raid',
        controls = {
          {
            type = 'checkbox',
            name = 'Track ' .. self.groupBuffs[i].name,
            warning = 'Reload UI',
            getFunc = function() return self.settings.groupBuffData[barNumber].track end,
            setFunc = function()
              self.settings.groupBuffData[barNumber].track = not self.settings.groupBuffData[barNumber].track
              ReloadUI()
            end,
          },
        },
      },
    }
    if self.settings.groupBuffData[barNumber].track then
      ZO_CombineNumericallyIndexedTables(groupBuffOptions[1].controls, {
        {
          type = 'checkbox',
          name = 'Lock',
          getFunc = function() return self.settings.groupBuffData[barNumber].locked end,
          setFunc = function()
            self.settings.groupBuffData[barNumber].locked = not self.settings.groupBuffData[barNumber].locked
            self:WindowApplySettings(barNumber, self.settings.groupBuffData[barNumber])
          end,
        },
        {
          type = 'checkbox',
          name = 'Always Show',
          getFunc = function() return self.settings.groupBuffData[barNumber].alwaysShow end,
          setFunc = function()
            self.settings.groupBuffData[barNumber].alwaysShow = not self.settings.groupBuffData[barNumber].alwaysShow
            self:WindowApplySettings(barNumber, self.settings.groupBuffData[barNumber])
          end,
        },
        {
          type = 'header',
          name = 'Display Settings',
        },
        {
          type = 'slider',
          name = 'Width',
          min = 0,
          max = 1000,
          step = 5,
          getFunc = function() return self.settings.groupBuffData[barNumber].width end,
          setFunc = function(number)
            self.settings.groupBuffData[barNumber].width = number
            self:WindowApplySettings(barNumber, self.settings.groupBuffData[barNumber])
          end,
        },
        {
          type = 'slider',
          name = 'Height',
          min = 0,
          max = 200,
          step = 5,
          getFunc = function() return self.settings.groupBuffData[barNumber].height end,
          setFunc = function(number)
            self.settings.groupBuffData[barNumber].height = number
            self:WindowApplySettings(barNumber, self.settings.groupBuffData[barNumber])
          end,
        },
        {
          type = 'slider',
          name = 'Text Size',
          min = 10,
          max = 100,
          step = 2,
          getFunc = function() return self.settings.groupBuffData[barNumber].textSize end,
          setFunc = function(number)
            self.settings.groupBuffData[barNumber].textSize = number
            self:WindowApplySettings(barNumber, self.settings.groupBuffData[barNumber])
          end,
        },
        {
          type = 'checkbox',
          name = 'Reverse Bar Direction',
          getFunc = function() return self.settings.groupBuffData[barNumber].reverse end,
          setFunc = function()
            self.settings.groupBuffData[barNumber].reverse = not self.settings.groupBuffData[barNumber].reverse
            self:WindowApplySettings(barNumber, self.settings.groupBuffData[barNumber])
          end,
        },
        {
          type = 'colorpicker',
          name = 'Bar Color Left',
          getFunc = function() return self.settings.groupBuffData[barNumber].colorBar[1], self.settings.groupBuffData[barNumber].colorBar[2], self.settings.groupBuffData[barNumber].colorBar[3], self.settings.groupBuffData[barNumber].colorBar[4] end,
          setFunc = function(r,g,b,a)
            self.settings.groupBuffData[barNumber].colorBar[1] = r
            self.settings.groupBuffData[barNumber].colorBar[2] = g
            self.settings.groupBuffData[barNumber].colorBar[3] = b
            self.settings.groupBuffData[barNumber].colorBar[4] = a
            self:WindowApplySettings(barNumber, self.settings.groupBuffData[barNumber])
          end,
        },
        {
          type = 'colorpicker',
          name = 'Bar Color Right',
          getFunc = function() return self.settings.groupBuffData[barNumber].colorBar[5], self.settings.groupBuffData[barNumber].colorBar[6], self.settings.groupBuffData[barNumber].colorBar[7], self.settings.groupBuffData[barNumber].colorBar[8] end,
          setFunc = function(r,g,b,a)
            self.settings.groupBuffData[barNumber].colorBar[5] = r
            self.settings.groupBuffData[barNumber].colorBar[6] = g
            self.settings.groupBuffData[barNumber].colorBar[7] = b
            self.settings.groupBuffData[barNumber].colorBar[8] = a
            self:WindowApplySettings(barNumber, self.settings.groupBuffData[barNumber])
          end,
        },
        {
          type = 'colorpicker',
          name = 'Bar Color Edge',
          getFunc = function() return unpack(self.settings.groupBuffData[barNumber].colorEdge) end,
          setFunc = function(r,g,b,a)
            self.settings.groupBuffData[barNumber].colorEdge = {r,g,b,a}
            self:WindowApplySettings(barNumber, self.settings.groupBuffData[barNumber])
          end,
        },
        {
          type = 'colorpicker',
          name = 'Bar Color Background',
          getFunc = function() return unpack(self.settings.groupBuffData[barNumber].colorBackground) end,
          setFunc = function(r,g,b,a)
            self.settings.groupBuffData[barNumber].colorBackground = {r,g,b,a}
            self:WindowApplySettings(barNumber, self.settings.groupBuffData[barNumber])
          end,
        },
        {
          type = 'colorpicker',
          name = 'Text Color',
          getFunc = function() return unpack(self.settings.groupBuffData[barNumber].colorLabel) end,
          setFunc = function(r,g,b,a)
            self.settings.groupBuffData[barNumber].colorLabel = {r,g,b,a}
            self:WindowApplySettings(barNumber, self.settings.groupBuffData[barNumber])
          end,
        },
        {
          type = 'header',
          name = 'Icon Settings',
        },
        {
          type = 'checkbox',
          name = 'Show Icon',
          getFunc = function() return self.settings.groupBuffData[barNumber].icon.show end,
          setFunc = function()
            self.settings.groupBuffData[barNumber].icon.show = not self.settings.groupBuffData[barNumber].icon.show
            self:WindowApplySettings(barNumber, self.settings.groupBuffData[barNumber])
          end,
        },
        {
          type = 'colorpicker',
          name = 'Color',
          getFunc = function() return unpack(self.settings.groupBuffData[barNumber].icon.color) end,
          setFunc = function(r,g,b,a)
            self.settings.groupBuffData[barNumber].icon.color = {r,g,b,a}
            self:WindowApplySettings(barNumber, self.settings.groupBuffData[barNumber])
          end,
        },
        {
          type = 'slider',
          name = 'Size',
          min = 10,
          max = 100,
          step = 2,
          getFunc = function() return self.settings.groupBuffData[barNumber].icon.size end,
          setFunc = function(number)
            self.settings.groupBuffData[barNumber].icon.size = number
            self:WindowApplySettings(barNumber, self.settings.groupBuffData[barNumber])
          end,
        },
      })
      if self.settings.notification.enable then
        ZO_CombineNumericallyIndexedTables(groupBuffOptions[1].controls, {
          {
            type = 'header',
            name = 'Notification Settings',
          },
          {
            type = 'slider',
            name = 'Threshold',
            tooltip = '0 means no notifications',
            min = 0,
            max = 10,
            step = 0.5,
            getFunc = function() return self.settings.groupBuffData[barNumber].notification.threshold end,
            setFunc = function(number) self.settings.groupBuffData[barNumber].notification.threshold = number end,
          },
          {
            type = 'dropdown',
            name = 'Sound',
            choices = self.sounds,
            getFunc = function() return self.settings.groupBuffData[barNumber].notification.sound end,
            setFunc = function(value)
              self.settings.groupBuffData[barNumber].notification.sound = value
              PlaySound(value)
            end,
          },
          {
            type = 'checkbox',
            name = 'Text Notification',
            getFunc = function() return self.settings.groupBuffData[barNumber].notification.text end,
            setFunc = function() self.settings.groupBuffData[barNumber].notification.text = not self.settings.groupBuffData[barNumber].notification.text end,
          },
          {
            type = 'editbox',
            name = 'Custom Text',
            getFunc = function() return self.settings.groupBuffData[barNumber].notification.customText end,
            setFunc = function(value) self.settings.groupBuffData[barNumber].notification.customText = value end,
          },
        })
      end
    end
    table.insert(optionControls, groupBuffOptions[1])
  end

  ZO_CombineNumericallyIndexedTables(optionControls, {
    {
      type = 'header',
      name = ZO_ColorDef:New('6699ff'):Colorize('Debug Settings'),
    },
    {
      type = 'checkbox',
      name = 'Debug Mode',
      getFunc = function() return self.debug end,
      setFunc = function() self.debug = not self.debug end,
    },
  })

  LibAddonMenu2:RegisterAddonPanel('BuffTimersPanel', addonPanel)
  LibAddonMenu2:RegisterOptionControls('BuffTimersPanel', optionControls)
end

function BuffTimers:SettingsDeepCopy(dstData, k, v)
  if dstData[k] == nil then
    if type(v) == 'table' then
      dstData[k] = ZO_DeepTableCopy(v)
    else
      dstData[k] = v
    end
  elseif type(dstData[k]) == 'table' then
    for k2, v2 in pairs(v) do
      self:SettingsDeepCopy(dstData[k], k2, v2)
    end
  end
end

function BuffTimers:SettingsLoad()
  local defaultProfiles = {
    ['profileNames'] = {
      [1] = self.defaultProfile,
    },
    ['profileData'] = {
      [self.defaultProfile] = {
        barData       = {},
        buffNames     = {},
        groupBuffData = {},
        numberBars    = 1,
        updateSpeed   = 100,
        notification  = {color = {0.9,0.1,0.1,1}, duration = 2, enable = false, locked = true, offset = {x=0, y=0}},
      },
    },
  }
  self.profiles = ZO_SavedVars:NewAccountWide('BuffTimersSavedVariables', 1, nil, defaultProfiles, nil, '$InstallationWide')

  local defaultPlayer = {
    activeProfile = self.defaultProfile,
  }
  self.player = ZO_SavedVars:NewCharacterIdSettings('BuffTimersSavedVariables', 1, nil, defaultPlayer)

  self:ConvertOldData1to2()
  self:ProfileLoad()
  self:SettingsLoadBars()
end

function BuffTimers:SettingsLoadBars()
  for i=1, self.settings.numberBars do
    if self.settings.barData[i] == nil then
      self.settings.barData[i] = ZO_DeepTableCopy(self.defaultBarData)
      self.settings.barData[i].offset.y = self.settings.barData[i].offset.y + (50 * i)
    else
      self:SettingsLoadBarsCopyDefaults(self.settings.barData[i])
    end
  end
  for i=1, #self.groupBuffs do
    local srcData = self.groupBuffs[i]
    if self.settings.groupBuffData[srcData.barNumber] == nil then
      self.settings.groupBuffData[srcData.barNumber] = ZO_DeepTableCopy(self.defaultBarData)
      self.settings.groupBuffData[srcData.barNumber].track        = false
      self.settings.groupBuffData[srcData.barNumber].offset.x     = self.settings.groupBuffData[srcData.barNumber].offset.x + 200
      self.settings.groupBuffData[srcData.barNumber].offset.y     = self.settings.groupBuffData[srcData.barNumber].offset.y + (50 * i)
      self.settings.groupBuffData[srcData.barNumber].buffName     = srcData.name
      self.settings.groupBuffData[srcData.barNumber].icon.texture = srcData.iconTexture
    else
      self:SettingsLoadBarsCopyDefaults(self.settings.groupBuffData[srcData.barNumber])
    end
  end
end

function BuffTimers:SettingsLoadBarsCopyDefaults(dstData)
  for k, v in pairs(self.defaultBarData) do
    self:SettingsDeepCopy(dstData, k, v)
  end
end

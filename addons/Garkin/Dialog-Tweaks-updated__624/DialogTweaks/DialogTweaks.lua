local DialogTweaks = ZO_Object:Subclass()

DialogTweaks.defaults = {
   ["numberedOptions"] = true,
   ["notSoVisibleGoodbye"] = false,
   ["removeDashes"] = true,
   ["nameAlignment"] = "center",
   ["nameColor"] = ZO_NORMAL_TEXT,
   ["icons"] = "tweaked",
}
DialogTweaks.alignments = {
   "left",
   "center",
   "right",
}
DialogTweaks.icons = {
   "none",
   "default",
   "tweaked",
}

local CHATTER_GENERIC_ACCEPT = 42
local CHATTER_COMPLETE_QUEST = 43

DialogTweaks.dialogIcons = {
   [CHATTER_START_TALK]                                  = "EsoUI/Art/ChatWindow/chat_notification_up.dds",
   [CHATTER_TALK_CHOICE]                                 = "EsoUI/Art/ChatWindow/chat_notification_up.dds",
   [CHATTER_TALK_CHOICE_MONEY]                           = "EsoUI/Art/Bank/bank_tabIcon_deposit_up.dds",
   [CHATTER_TALK_CHOICE_INTIMIDATE_DISABLED]             = "EsoUI/Art/ChatWindow/chat_notification_up.dds",
   [CHATTER_TALK_CHOICE_PERSUADE_DISABLED]               = "EsoUI/Art/ChatWindow/chat_notification_up.dds",
   [CHATTER_START_NEW_QUEST_BESTOWAL]                    = "EsoUI/Art/WorldMap/map_indexIcon_quests_up.dds",
   [CHATTER_START_ADVANCE_COMPLETABLE_QUEST_CONDITIONS]  = "EsoUI/Art/ChatWindow/chat_overflowarrow_up.dds", 
   [CHATTER_START_COMPLETE_QUEST]                        = "EsoUI/Art/MenuBar/menuBar_help_up.dds",
   [CHATTER_START_GIVE_ITEM]                             = "EsoUI/Art/Inventory/inventory_tabIcon_quickslot_up.dds",
   [CHATTER_START_BANK]                                  = "EsoUI/Art/MainMenu/menuBar_inventory_up.dds",
   [CHATTER_START_BUY_BAG_SPACE]                         = "EsoUI/Art/MainMenu/menuBar_inventory_up.dds",
   [CHATTER_START_GUILDBANK]                             = "EsoUI/Art/Guild/guildHistory_indexIcon_guildBank_up.dds",
   [CHATTER_START_SHOP]                                  = "EsoUI/Art/Guild/guildHistory_indexIcon_guildStore_up.dds",
   [CHATTER_START_STABLE]                                = "EsoUI/Art/Mounts/tabicon_mounts_up.dds",
   [CHATTER_START_TRADINGHOUSE]                          = "EsoUI/Art/Guild/guildHistory_indexIcon_guildStore_up.dds",
   [CHATTER_START_PICKPOCKET]                            = "EsoUI/Art/Inventory/inventory_stolenitem_icon.dds",
   [CHATTER_START_PAY_BOUNTY]                            = "EsoUI/Art/Bank/bank_tabIcon_deposit_up.dds",
   [CHATTER_GOODBYE]                                     = "EsoUI/Art/Buttons/decline_up.dds",
   [CHATTER_GENERIC_ACCEPT]                              = "EsoUI/Art/Buttons/accept_up.dds",
   [CHATTER_COMPLETE_QUEST]                              = "EsoUI/Art/Buttons/accept_up.dds",
   [CHATTER_COMPLETE_QUEST_CONFIRM]                      = "EsoUI/Art/Buttons/accept_up.dds",
   [CHATTER_COMPLETE_QUEST_DIALOG]                       = "EsoUI/Art/Buttons/accept_up.dds",
}

function DialogTweaks:SetTitleColor()
   ZO_InteractWindowTargetAreaTitle:SetColor(self.config.nameColor["r"], self.config.nameColor["g"], self.config.nameColor["b"], self.config.nameColor["a"])
end

function DialogTweaks:SetTitleAlignment()
   if self.config.nameAlignment == "left" then
      ZO_InteractWindowTargetAreaTitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
   elseif self.config.nameAlignment == "center" then
      ZO_InteractWindowTargetAreaTitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
   elseif self.config.nameAlignment == "right" then
      ZO_InteractWindowTargetAreaTitle:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
   end
end

local INTERACT_TITLE_FORMAT = EsoStrings[SI_INTERACT_TITLE_FORMAT]
function DialogTweaks:RemoveDashes()
   if self.config.removeDashes then
      EsoStrings[SI_INTERACT_TITLE_FORMAT] = "<<1>>"
   elseif EsoStrings[SI_INTERACT_TITLE_FORMAT] ~= INTERACT_TITLE_FORMAT then
      EsoStrings[SI_INTERACT_TITLE_FORMAT] = INTERACT_TITLE_FORMAT
   end
end

function DialogTweaks:SetIcons()
   if self.config.icons == "none" then
      USE_CHATTER_OPTION_ICON = false
   else
      USE_CHATTER_OPTION_ICON = true
   end
end

function DialogTweaks:Init(eventCode, addonName)
   if addonName == "DialogTweaks" then
      self.config = ZO_SavedVars:New("DialogTweaksSavedVars", 1, nil, self.defaults, nil)

      local optionsCount = 0
      local PopulateChatterOption = ZO_Interaction.PopulateChatterOption
      function ZO_Interaction.PopulateChatterOption(manager, controlID, optionIndex, optionText, optionType, ...)
         local optionControl = manager.optionControls[controlID]
         local icon = GetControl(optionControl, "IconImage")
         optionsCount = optionsCount + 1

         if self.config.numberedOptions then
            optionText = zo_strformat("<<1>>|u10:0::|u<<2>>", optionsCount, optionText)
         end

         if optionType == CHATTER_GOODBYE then
            if self.config.notSoVisibleGoodbye then
               optionText = ZO_DEFAULT_DISABLED_COLOR:Colorize(optionText)
            end
            optionsCount = 0 
         end

         PopulateChatterOption(manager, controlID, optionIndex, optionText, optionType, ...)

         if self.config.notSoVisibleGoodbye and self.config.icons ~= "none" then
            icon:SetDesaturation(optionType == CHATTER_GOODBYE and 1 or 0)
         end

         if self.config.icons == "tweaked" then
            local iconFile = self.dialogIcons[optionType]
            if iconFile then
               icon:SetTexture(iconFile)
               icon:SetHidden(false)
            else
               --d(optionType)
               icon:SetHidden(true)
            end
         end
      end

      self:SetTitleColor()
      self:SetTitleAlignment()
      self:SetIcons()
      self:RemoveDashes()

      self:CreateSettings()
   end
end

function DialogTweaks:CreateSettings()
   local panelData = {
      type = 'panel',
      name = "Biki's Dialog Tweaks",
      displayName = ZO_HIGHLIGHT_TEXT:Colorize("Biki's Dialog Tweaks"),
      author = 'Biki & Garkin',
      version = '2',
      slashCommand = "/dialogtweaks",
      registerForRefresh = true,
      registerForDefaults = true,
   }
   local optionsData = {
      {
         type = 'checkbox',
         name = 'Number the options',
         tooltip = 'Numbers the options in a dialog beginning with 1. You can press the corresponding key to select that option',
         getFunc = function() return self.config.numberedOptions end,
         setFunc = function(value) self.config.numberedOptions = value end,
         default = self.defaults.numberedOptions,
      },
      {
         type = 'checkbox',
         name = 'Gray out "Goodbye"',
         tooltip = 'Grays out the Goodbye option a bit so it is less distracting',
         getFunc = function() return self.config.notSoVisibleGoodbye end,
         setFunc = function(value) self.config.notSoVisibleGoodbye = value end,
         default = self.defaults.notSoVisibleGoodbye,
      },
      {
         type = 'checkbox',
         name = 'Remove dashes from NPC name',
         tooltip = 'Removes the dashes (-) from the NPC/target name',
         getFunc = function() return self.config.removeDashes end,
         setFunc = function(value) self.config.removeDashes = value; self:RemoveDashes() end,
         default = self.defaults.removeDashes,
      },
      {
         type = 'dropdown',
         name = 'Alignment of NPC name',
         tooltip = 'Select the alignment of the NPC/target name',
         choices = self.alignments,
         getFunc = function() return self.config.nameAlignment end,
         setFunc = function(value) self.config.nameAlignment = value; self:SetTitleAlignment() end,
         default = self.defaults.nameAlignment,
      },
      {
         type = 'dropdown',
         name = 'Show dialog icons',
         tooltip = 'Select dialog icons',
         choices = self.icons,
         getFunc = function() return self.config.icons end,
         setFunc = function(value) self.config.icons = value; self:SetIcons() end,
         default = self.defaults.icons,
      },
      {
         type = 'colorpicker',
         name = 'NPC name/target color',
         tooltip = 'Adjust the color of the NPC/target name',
         getFunc = function() return self.config.nameColor["r"], self.config.nameColor["g"], self.config.nameColor["b"], self.config.nameColor["a"] end,
         setFunc = function(r, g, b, a) self.config.nameColor = { ["r"] = r, ["g"] =g, ["b"] = b, ["a"] = a }; self:SetTitleColor() end,
         default = self.defaults.nameColor,
      },
   }
   local LAM2 = LibAddonMenu2
   LAM2:RegisterAddonPanel("_bikisDialogTweaks", panelData)
   LAM2:RegisterOptionControls("_bikisDialogTweaks", optionsData)
end

EVENT_MANAGER:RegisterForEvent("DialogTweaks", EVENT_ADD_ON_LOADED, function(...) DialogTweaks:Init(...) end)


--LibAddonMenu2.0 Required

--------------
-- Variables
--------------

local Positions = {
    [1] = "Bottom Right",
    [2] = "Right",
    [3] = "Top Right",
    [4] = "Top",
    [5] = "Top Left",
    [6] = "Left",
    [7] = "Bottom Left",
    [8] = "Bottom",
    }


---------
-- Menu
---------

function EQA.AddonMenu()

  local panelData = {
    type = "panel",
    name = "ExoYs Quickslot Assistant",
    displayName = "|c40FF00ExoY|r Quickslot Assistant",
    author = "|c40FF00ExoY|r",
    version = EQA.version,
    slashCommand = "/eqamenu",
    --registerForRefresh = true,
    --registerForDefaults = true,
    }

  local optionsData = {
  [1] = {
      type = "submenu",
      name = "Potion Settings",
      --tooltip = "My submenu tooltip",	--(optional)
      controls = {
          [1] = {
              type = "checkbox",
              name = "Potion Lock",
              --tooltip = "Checkbox's tooltip text.",
              getFunc = function() return EQA.LockPotion end,
              setFunc = function(SelectLockPotion)
                EQA.LockPotion = SelectLockPotion
                EQA.savedVariables.LockPotion = SelectLockPotion
              end,
          },
          [2] = {
              type = "dropdown",
              name = "Potion Position",
              tooltip = "Choose which quickslot position your desired potion is on.",
              choices = Positions,
              getFunc = function() return Positions[EQA.PositionPotion] end,
              setFunc = function(SelectPositionPotion)
                for index, name in ipairs(Positions) do
                  if name == SelectPositionPotion then
                    EQA.PositionPotion = index
                    EQA.savedVariables.PositionPotion = index
                    EQA.CheckCollision()
                    break
                    end
                  end
                end,
          },
      },
    },
    [2] = {
        type = "submenu",
        name = "BuffFood Settings",
        --tooltip = "My submenu tooltip",	--(optional)
        controls = {
            [1] = {
                type = "checkbox",
                name = "BuffFood Lock",
                tooltip = "Lock on BuffFood when it is expired",
                getFunc = function() return EQA.LockBuffFood end,
                setFunc = function(SelectLockBuffFood)
                  EQA.LockBuffFood = SelectLockBuffFood
                  EQA.savedVariables.LockBuffFood = SelectLockBuffFood
                end,
            },
            [2] = {
                type = "dropdown",
                name = "BuffFood Position",
                tooltip = "Choose which quickslot position your desired buff food is on.",
                choices = Positions,
                getFunc = function() return Positions[EQA.PositionBuffFood] end,
                setFunc = function(SelectPositionBuffFood)
                  for index, name in ipairs(Positions) do
                    if name == SelectPositionBuffFood then
                      EQA.PositionBuffFood = index
                      EQA.savedVariables.PositionBuffFood = index
                      EQA.CheckCollision()
                      break
                      end
                    end
                  end,
            },
            [3] = {
                type = "checkbox",
                name = "BuffFood Reminder",
                tooltip = "Reminder when BuffFood is expired",
                getFunc = function() return EQA.BuffFoodNotification end,
                setFunc = function(SelectBuffFoodNotification)
                  EQA.BuffFoodNotification = SelectBuffFoodNotification
                  EQA.savedVariables.BuffFoodNotification = SelectBuffFoodNotification
                end,
            },
            [4] = {
                type = "colorpicker",
                name = "Color of Reminder",
                --tooltip = "If you need it ..",
                getFunc = function() return unpack(EQA.BuffFoodNotificationColor) end,	--(alpha is optional)
                setFunc = function(r,g,b,a)
                  EQA.savedVariables.BuffFoodNotificationColor = {r, g, b, a}
                  EQA_BuffFood_Notification_Label:SetColor(r,g,b,a)
                end,
                width = "full",	--or "half" (optional)
            },
            [5] = {
              type = "editbox",
              name = "Text to display",
              --tooltip = "If you need it ..",
              getFunc = function() return EQA.BuffFoodNotificationText end,
              setFunc = function(SelectBuffFoodNotificationText)
                EQA.savedVariables.BuffFoodNotificationText = SelectBuffFoodNotificationText
                EQA_BuffFood_Notification_Label:SetText(SelectBuffFoodNotificationText)
              end,
              isMultiline = true,	--boolean
              width = "full",	--or "half" (optional)
            },
            [6] = {
                type = "slider",
                name = "Font Size",
                --tooltip = "Slider's tooltip text.",
                min = 20,
                max = 74,
                step = 2,	--(optional)
                getFunc = function() return EQA.BuffFoodNotificationSize end,
                setFunc = function(SelectBuffFoodNotificationSize)
                  EQA.savedVariables.BuffFoodNotificationSize = SelectBuffFoodNotificationSize
                  EQA.BuffFoodNotificationSize = SelectBuffFoodNotificationSize
                  EQA.SetFontSize(EQA_BuffFood_Notification, EQA_BuffFood_Notification_Label, SelectBuffFoodNotificationSize)
                end,
                --width = "half",	--or "half" (optional)
                --default = 5,	--(optional)
            },
            [7] = {
                type = "slider",
                name = "NotificationScale",
                tooltip = "Can be used to increase Notificationsize even further.",
                min = 1,
                max = 3,
                step = 0.5,	--(optional)
                getFunc = function() return EQA.BuffFoodNotificationScale end,
                setFunc = function(SelectBuffFoodNotificationScale)
                  EQA.savedVariables.BuffFoodNotificationScale = SelectBuffFoodNotificationScale
                  EQA.BuffFoodNotificationScale = SelectBuffFoodNotificationScale
                  EQA_BuffFood_Notification_Label:SetScale(SelectBuffFoodNotificationScale)
                end,
                --width = "half",	--or "half" (optional)
                --default = 5,	--(optional)
            },
        },
      },
  [3] = {
            type = "checkbox",
            name = "Active in PvP",
            --tooltip = "Checkbox's tooltip text.",
            getFunc = function() return EQA.EnableInPvP end,
            setFunc = function(SelectPvPHandler)
              EQA.EnableInPvP = SelectPvPHandler
              EQA.savedVariables.EnableInPvP = SelectPvPHandler
            end,
            warning = "Will need to reload the UI.",	--(optional)
        },
  [4] = {
         type = "checkbox",
          name = "In PvE only in Dungeon/Raids",
          --tooltip = "Checkbox's tooltip text.",
          getFunc = function() return EQA.OnlyInRaid end,
          setFunc = function(SelectRaid)
            EQA.OnlyInRaid = SelectRaid
            EQA.savedVariables.OnlyInRaid = SelectRaid
          end,
          warning = "Will need to reload the UI.",	--(optional)
      },
  [5] = {
      type = "submenu",
      name = "Clever Alchemist (Experimental)",
      --tooltip = "My submenu tooltip",	--(optional)
      controls = {
          [1] = {
              type = "checkbox",
              name = "Activate Clever Modus",
              tooltip = "Lock on BuffFood when it is expired",
              getFunc = function() return EQA.CleverModus end,
              setFunc = function(SelectLockBuffFood)
                EQA.CleverModus = SelectLockBuffFood
                EQA.savedVariables.CleverModus = SelectLockBuffFood
              end,
              warning = "Will need to reload the UI.",	--(optional)
          },
          [2] = {
              type = "dropdown",
              name = "Empty Position",
              tooltip = "Choose which quickslot position your desired buff food is on.",
              choices = Positions,
              getFunc = function() return Positions[EQA.PositionEmpty - 8] end,
              setFunc = function(SelectPositionBuffFood)
                for index, name in ipairs(Positions) do
                  if name == SelectPositionBuffFood then
                    EQA.PositionEmpty = index + 8
                    EQA.savedVariables.PositionEmpty = index + 8
                    break
                    end
                  end
                end,
          },
          [3] = {
                  type = "description",
                  title = "Setup for Experiment",	--(optional)
                  --title = nil,	--(optional)
                  text = "To avoid posible any lua errors or malfunktion disable all >Lock< options.",
                  width = "full",	--or "half" (optional)
              },
          [4] = {
                  type = "description",
                  --title = "Setup for Experiment",	--(optional)
                  title = nil,	--(optional)
                  text = "The experimental mode is an independent mode, therefor ignoring the PvP and PvE settings",
                  width = "full",	--or "half" (optional)
              },
          [5] = {
                  type = "description",
                  title = "BuffFood Reminder",	--(optional)
                  --title = nil,	--(optional)
                  text = "The BuffFood-Reminder function (without its' locking feature) should still work with its PvP and PvE settings",
                  width = "full",	--or "half" (optional)
              },
        },
      },
  }

  LibAddonMenu2:RegisterAddonPanel("EQA_Settings", panelData)
  LibAddonMenu2:RegisterOptionControls("EQA_Settings", optionsData)

end

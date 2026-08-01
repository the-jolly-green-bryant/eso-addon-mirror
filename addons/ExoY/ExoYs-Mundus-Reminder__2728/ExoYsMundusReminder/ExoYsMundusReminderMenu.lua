--LibAddonMenu2.0 Required

---------
-- Menu
---------

local fontNames = {
  [1] = "Univers57",
  [2] = "Univers67",
  [3] = "ProseAntique",
  [4] = "Handwritten",
  [5] = "StoneTablet",
}

local fontOutlines = {
  [1] = "soft-shadow-thick",
  [2] = "soft-shadow-thin",
  [3] = "thick-outline",

}

function EMR.AddonMenu()

  local panelData = {
    type = "panel",
    name = "ExoYs Mundus Reminder",
    displayName = "|c40FF00ExoY|r's Mundus Reminder",
    author = EMR.author,
    version = EMR.version,
    slashCommand = "/emrmenu",
  }

  local optionsData =
    {
      {
          type = "slider",
          name = "Reminder Duration",
          --tooltip = "Slider's tooltip text.",
          min = 1,
          max = 30,
          step = 1,	--(optional)
          getFunc = function() return EMR.savedVariables.duration end,
          setFunc = function(duration)
            EMR.savedVariables.duration = duration
            EMR.duration = duration
          end,
          --width = "half",	--or "half" (optional)
          --default = 5,	--(optional)
      },
      {
        type = "submenu",
        name = "Activation Setting",
        --tooltip = "My submenu tooltip",	--(optional)
        controls =
          {
            {
                type = "header",
                name = "Locations",
                width = "full",	--or "half" (optional)
            },
            {
                type = "checkbox",
                name = "Normal Instance",
                --tooltip = "",
                getFunc = function() return EMR.savedVariables.normal end,
                setFunc = function(normal)
                  EMR.savedVariables.normal = normal
                end,
                warning = "Will need to reload the UI.",	--(optional)
            },
            {
                type = "checkbox",
                name = "Veteran Instances",
                --tooltip = "",
                getFunc = function() return EMR.savedVariables.veteran end,
                setFunc = function(veteran)
                  EMR.savedVariables.veteran = veteran
                end,
                warning = "Will need to reload the UI.",	--(optional)
            },
            {
                type = "checkbox",
                name = "Cyrodil and Imperial City ",
                --tooltip = "",
                getFunc = function() return EMR.savedVariables.ava end,
                setFunc = function(ava)
                  EMR.savedVariables.ava = ava
                end,
                warning = "Will need to reload the UI.",	--(optional)
            },
            {
                type = "header",
                name = "Queue",
                width = "full",	--or "half" (optional)
            },
            {
                type = "checkbox",
                name = "Dungeon and Battleground Finder",
                --tooltip = "",
                getFunc = function() return EMR.savedVariables.queueParty end,
                setFunc = function(queueParty)
                  EMR.savedVariables.queueParty = queueParty
                end,
                warning = "Will need to reload the UI.",	--(optional)
            },
            {
                type = "checkbox",
                name = "Cyrodil and Imperial City Queue",
                --tooltip = "",
                getFunc = function() return EMR.savedVariables.queueAVA end,
                setFunc = function(queueAVA)
                  EMR.savedVariables.queueAVA = queueAVA
                end,
                warning = "Will need to reload the UI.",	--(optional)
            },
            {
                type = "header",
                name = "Duels",
                width = "full",	--or "half" (optional)
            },
            {
                type = "checkbox",
                name = "Duel Invitation",
                --tooltip = "",
                getFunc = function() return EMR.savedVariables.duelInv end,
                setFunc = function(duelInv)
                  EMR.savedVariables.duelInv = duelInv
                end,
                warning = "Will need to reload the UI.",	--(optional)
            },
            {
                type = "checkbox",
                name = "Duel Start",
                --tooltip = "",
                getFunc = function() return EMR.savedVariables.duelStart end,
                setFunc = function(duelStart)
                  EMR.savedVariables.duelStart = duelStart
                end,
                warning = "Will need to reload the UI.",	--(optional)
            },
            {
                type = "header",
                name = "miscellaneous",
                width = "full",	--or "half" (optional)
            },
            {
                type = "checkbox",
                name = "Joined Group",
                --tooltip = "",
                getFunc = function() return EMR.savedVariables.group end,
                setFunc = function(group)
                  EMR.savedVariables.group = group
                end,
                warning = "Will need to reload the UI.",	--(optional)
            },
          },
        },
      {
        type = "submenu",
        name = "Notification",
        --tooltip = "My submenu tooltip",	--(optional)
        controls =
          {
            {
                type = "checkbox",
                name = "Unlock UI",
                --tooltip = "",
                getFunc = function() return false end,
                setFunc = function(uiShow)
                  if uiShow then
                    EMR_Mundus_Notification_Label:SetText("Mundus Stone")
                    EMR_Mundus_Notification:SetMovable(uiShow)
                  end
                  EMR_Mundus_Notification:SetHidden(not uiShow)
                  EMR_Mundus_Notification:SetMovable(uiShow)
                end,
            },
            {
                type = "header",
                name = "Font",
                width = "full",	--or "half" (optional)
            },
            {
                type = "dropdown",
                name = "Font",
                choices = fontNames,
                getFunc = function() return fontNames[EMR.savedVariables.fontPathNo] end,
                setFunc = function(fontName)
                  for index, name in ipairs(fontNames) do
                    if name == fontName then
                      EMR.savedVariables.fontPathNo = index
                      EMR.UpdateNotification()
                      break
                      end
                    end
                  end,
            },
            {
                type = "dropdown",
                name = "Outline",
                choices = fontOutlines,
                getFunc = function() return fontOutlines[EMR.savedVariables.fontOutlineNo] end,
                setFunc = function(outlineName)
                  for index, name in ipairs(fontOutlines) do
                    if name == outlineName then
                      EMR.savedVariables.fontOutlineNo = index
                      EMR.UpdateNotification()
                      break
                      end
                    end
                  end,
            },
            {
              type = "colorpicker",
              name = "Font Color",
              --tooltip = "If you need it ..",
              getFunc = function() return unpack(EMR.savedVariables.fontColor) end,	--(alpha is optional)
              setFunc = function(r,g,b,a)
                EMR.savedVariables.fontColor = {r, g, b, a}
                EMR.UpdateNotification()
              end,
              width = "full",	--or "half" (optional)
            },
            {
                type = "slider",
                name = "Font Size",
                --tooltip = "Slider's tooltip text.",
                min = 20,
                max = 74,
                step = 2,	--(optional)
                getFunc = function() return EMR.savedVariables.fontSize end,
                setFunc = function(fontSize)
                  EMR.savedVariables.fontSize = fontSize
                  --EMR.SetFontSize(EMR_Mundus_Notification, EMR_Mundus_Notification_Label, FontSize)
                  --EMR.AdaptDimension()
                  EMR.UpdateNotification()
                end,
                --width = "half",	--or "half" (optional)
                --default = 5,	--(optional)
            },
            {
                type = "slider",
                name = "Scale",
                tooltip = "Increase size even further. Will get blury though",
                min = 1,
                max = 3,
                step = 0.5,	--(optional)
                getFunc = function() return EMR.savedVariables.uiScale end,
                setFunc = function(scale)
                  EMR.savedVariables.uiScale = scale
                  --EMR_Mundus_Notification_Label:SetScale(Scale)
                  --EMR.AdaptDimension()
                  EMR.UpdateNotification()
                end,
                --width = "half",	--or "half" (optional)
                --default = 5,	--(optional)
            },
--            {
--                type = "header",
--                name = "Background",
--                width = "full",	--or "half" (optional)
--            },
            {
              type = "colorpicker",
              name = "Background Color",
              --tooltip = "If you need it ..",
              getFunc = function() return unpack(EMR.savedVariables.bgColor) end,	--(alpha is optional)
              setFunc = function(r,g,b,a)
                EMR.savedVariables.bgColor = {r, g, b, a}
                EMR.UpdateNotification()
              end,
              width = "full",	--or "half" (optional)
            },
--            {
--                type = "slider",
--                name = "Edge Size",
--                --tooltip = "Slider's tooltip text.",
--                min = 1,
--                max = 3,
--                step = 0.5,	--(optional)
--                getFunc = function() return EMR.savedVariables.edgeSize end,
--                setFunc = function(edgeSize)
--                  EMR.savedVariables.edgeSize = edgeSize
--                  --EMR_Mundus_Notification_Label:SetScale(Scale)
---                  --EMR.AdaptDimension()
--                  EMR.UpdateNotification()
--                end,
                --width = "half",	--or "half" (optional)
                --default = 5,	--(optional)
  --          },
--            {
--              type = "colorpicker",
--              name = "Edge Color",
--              --tooltip = "If you need it ..",
--              getFunc = function() return unpack(EMR.savedVariables.edgeColor) end,	--(alpha is optional)
--              setFunc = function(r,g,b,a)
--                EMR.savedVariables.edgeColor = {r, g, b, a}
--                EMR.UpdateNotification()
--              end,
--              width = "full",	--or "half" (optional)
--            },
          },
        },
      }

  LibAddonMenu2:RegisterAddonPanel("EMR_Settings", panelData)
  LibAddonMenu2:RegisterOptionControls("EMR_Settings", optionsData)

end

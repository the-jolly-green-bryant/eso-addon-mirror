local HideGroupFrames = HideGroupFrames

function HideGroupFrames.CreateSettingsWindow()
     local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
     local sv = HGFVars["Default"][GetDisplayName()][GetCurrentCharacterId()]

     local panelData = {
          type = "panel",
          name = "HideGroupFrames",
          displayName = "HideGroupFrames Settings",
          author = HideGroupFrames.author,
          version = HideGroupFrames.version,
     }
     LAM2:RegisterAddonPanel(HideGroupFrames.name .. "Settings", panelData)

     local Settings = {
          [1] = {
               type = "header",
               name = "HideGroupFrames Information",
               width = "full"
          },
          [2] = {
               type = "description",
               text = "Toggle In-game Group Frames.",
               width = "full"
          },
          [3] = {
               type = "checkbox",
               name = "Hide Group Frames",
               getFunc = function() return sv["hideGroupFrames"] end,
               setFunc = function(value)
                     sv["hideGroupFrames"] = value
                     ZO_UnitFramesGroups:SetHidden(value)
                end,
               default = true,
               requiresReload = true,
               width = "full",
          },
     }
     LAM2:RegisterOptionControls(HideGroupFrames.name .. "Settings", Settings)
end

function PJD.BuildMenu()
  local panelName = PJD.name .. "Panel"
  local LAM = LibAddonMenu2
  local panelData = {
    type = "panel",
    name = "PleaseJustDebuff",
    author = "@Jarva [EU]",
    registerForDefaults = true,
  }

  LAM:RegisterAddonPanel(panelName, panelData)

  optionsData = {
    [1] = {
      type = "checkbox",
      name = "Show only in combat",
      getFunc = function() return PJD.SV.showOnlyInCombat end,
      setFunc = function(value)
        PJD.SV.showOnlyInCombat = value
        if value and not IsUnitInCombat("player") then
          return PJD.RemoveFromHUD()
        end
        PJD.AddToHUD()
      end
    },
    [2] = {
      type = "submenu",
      name = "Debuffs",
      controls = {
        {
          type = "checkbox",
          name = "Taunt",
          requiresReload = true,
          getFunc = function()
            if PJD.SV.trackers["Taunt"] ~= nil then
              return PJD.SV.trackers["Taunt"]
            end
            return true
          end,
          setFunc = function(value)
            PJD.SV.trackers["Taunt"] = value
          end
        },
      },
    },
    [3] = {
      type = "header",
      name = "The Tank Club",
    },
    [4] = {
      type = "description",
      text = "Whether you are new to tanking or one of the very best - The Tank Club community is open to all. We have over 5000+ members and offer a wide range of help, discussion, information, builds, giveaways, contests and much more - join us today!",
    },
    [5] = {
      type = "button",
      name = "Join the Discord",
      func = function() RequestOpenUnsafeURL("https://discord.gg/pt3HZg9") end,
    },
  }

  for k,v in ipairs(PJD.debuffTrackers) do
    table.insert(optionsData[2].controls, {
      type = "checkbox",
      name = v.name,
      requiresReload = true,
      getFunc = function()
        if PJD.SV.trackers[v.shortCode] ~= nil then
          return PJD.SV.trackers[v.shortCode]
        end
        return v.default or false
      end,
      setFunc = function(value)
        PJD.SV.trackers[v.shortCode] = value
      end
    })
  end

  LAM:RegisterOptionControls(panelName, optionsData)
end

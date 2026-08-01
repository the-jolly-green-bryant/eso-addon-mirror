function PB.QOLMenu( optionsData )
  optionsData[#optionsData + 1] = {
    type = "submenu",
    name = "Map Icons",
    controls = {
      {
        type = "checkbox",
        name = "Home Previews",
        tooltip = "Show icons on map for home previews(not bought) on the world map.",
        getFunc = function() return PB.db.default.options.mapFlags.homePreviews end,
        setFunc = function(newValue)
          PB.db.default.options.mapFlags.homePreviews = newValue
        end,
        width = "full",
        default = PB.db.default.options.mapFlags.homePreviews,
      },
      --{
      --  type = "checkbox",
      --  name = "Home Previews - Zone",
      --  tooltip = "Show icons on map for home previews(not bought) on the zone map.",
      --  getFunc = function() return PB.db.options.mapFlags.homePreviewsZone end,
      --  setFunc = function(newValue)
      --    PB.db.options.mapFlags.homePreviewsZone = newValue
      --  end,
      --  width = "full",
      --  default = PB.db.options.mapFlags.homePreviewsZone,
      --},
      {
        type = "checkbox",
        name = "Owned Homes",
        tooltip = "Show icons on map for homes already bought on the world map.",
        getFunc = function() return PB.db.default.options.mapFlags.ownedHomes end,
        setFunc = function(newValue)
          PB.db.default.options.mapFlags.ownedHomes = newValue
        end,
        width = "full",
        default = PB.db.default.options.mapFlags.ownedHomes,
      },
      {
        type = "checkbox",
        name = "Dungeons",
        tooltip = "Show icons on map for dungones on the world map.",
        getFunc = function() return PB.db.default.options.mapFlags.dungeons end,
        setFunc = function(newValue)
          PB.db.default.options.mapFlags.dungeons = newValue
        end,
        width = "full",
        default = PB.db.default.options.mapFlags.dungeons,
      },
      {
        type = "checkbox",
        name = "Trials",
        tooltip = "Show icons on map for trials on the world map.",
        getFunc = function() return PB.db.default.options.mapFlags.trials end,
        setFunc = function(newValue)
          PB.db.default.options.mapFlags.trials = newValue
        end,
        width = "full",
        default = PB.db.default.options.mapFlags.trials,
      },
      {
        type = "checkbox",
        name = "Wayshines",
        tooltip = "Show icons on map for wayshines on the world map.",
        getFunc = function() return PB.db.default.options.mapFlags.waypoints end,
        setFunc = function(newValue)
          PB.db.default.options.mapFlags.waypoints = newValue
        end,
        width = "full",
        default = PB.db.default.options.mapFlags.waypoints,
      }
    }
  }

  optionsData[#optionsData + 1] = {
    type = "submenu",
    name = "Vendors",
    controls = {
      {
        type = "checkbox",
        name = "Hide Crafted Items",
        tooltip = "Hide crafted items from the sell to vendor screen.",
        getFunc = function() return PB.db.default.options.vendor.hideCrafted end,
        setFunc = function(newValue)
          PB.db.default.options.vendor.hideCrafted = newValue
        end,
        width = "full",
        default = PB.db.default.options.vendor.hideCrafted,
      }, {
        type = "checkbox",
        name = "Hide Reconstruction Items",
        tooltip = "Hide reconstructed items from the sell to vendor screen.",
        getFunc = function() return PB.db.default.options.vendor.hideReconstruction end,
        setFunc = function(newValue)
          PB.db.default.options.vendor.hideReconstruction = newValue
        end,
        width = "full",
        default = PB.db.default.options.vendor.hideReconstruction,
      }, {
        type = "checkbox",
        name = "Hide Transmutation Items",
        tooltip = "Hide items that have been transmuted from the sell to vendor screen.",
        getFunc = function() return PB.db.default.options.vendor.hideTransmutation end,
        setFunc = function(newValue)
          PB.db.default.options.vendor.hideTransmutation = newValue
        end,
        width = "full",
        default = PB.db.default.options.vendor.hideTransmutation,
      }, {
        type = "checkbox",
        name = "Hide Unsellable Items",
        tooltip = "Hide items that cannot be sold to vendors from the sell to vendor screen.",
        getFunc = function() return PB.db.default.options.vendor.hideUnsellable end,
        setFunc = function(newValue)
          PB.db.default.options.vendor.hideUnsellable = newValue
        end,
        width = "full",
        default = PB.db.default.options.vendor.hideUnsellable,
      }
    }
  }

  optionsData[#optionsData + 1] = {
    type = "submenu",
    name = "Deconstruction",
    controls = {
      {
        type = "checkbox",
        name = "Hide Crafted Items",
        tooltip = "Hide crafted items from the deconstruction screen.",
        getFunc = function() return PB.db.default.options.deconstruct.hideCrafted end,
        setFunc = function(newValue)
          PB.db.default.options.deconstruct.hideCrafted = newValue
        end,
        width = "full",
        default = PB.db.default.options.deconstruct.hideCrafted,
      }, {
        type = "checkbox",
        name = "Hide Reconstruction Items",
        tooltip = "Hide reconstructed items from the deconstruction screen.",
        getFunc = function() return PB.db.default.options.deconstruct.hideReconstruction end,
        setFunc = function(newValue)
          PB.db.default.options.deconstruct.hideReconstruction = newValue
        end,
        width = "full",
        default = PB.db.default.options.deconstruct.hideReconstruction,
      }, {
        type = "checkbox",
        name = "Hide Transmutation Items",
        tooltip = "Hide items that have been transmuted from the deconstruction screen.",
        getFunc = function() return PB.db.default.options.deconstruct.hideTransmutation end,
        setFunc = function(newValue)
          PB.db.default.options.deconstruct.hideTransmutation = newValue
        end,
        width = "full",
        default = PB.db.default.options.deconstruct.hideTransmutation,
      }
    }
  }
end
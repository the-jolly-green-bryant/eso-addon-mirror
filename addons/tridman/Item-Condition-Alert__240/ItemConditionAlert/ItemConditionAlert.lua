--[[

Addon:    Item Condition Alert

Author:   @tridman
          Code based on "Graphic Durability Presenter" by Stabsome

]]--


ItemConditionAlert                      = {}
ItemConditionAlert.Name                 = "ItemConditionAlert"
ItemConditionAlert.Version              = "1.5.9"
ItemConditionAlert.Command              = "/ica"

ItemConditionAlert.sv                   = {}
ItemConditionAlert.wordlist             = {}

ItemConditionAlert.TYPE_ARMOR           = 1
ItemConditionAlert.TYPE_WEAPON          = 2
ItemConditionAlert.FLAG_REDRAW          = false

ItemConditionAlert.layouts              = {"Vertical", "Vertical Inv.", "Horizontal", "Horizontal Inv.", "Compact", "Horiz. all Weapons", "Inv. Horiz. all Weapons", "Vert. all Weapons", "Inv. Vert. all Weapons", "Reticle"}
ItemConditionAlert.ItemStates           = {"OK", "GOOD", "MODERATE", "LOW", "DOWN"}
ItemConditionAlert.outlineSize          = 64
ItemConditionAlert.iconSize             = 45
ItemConditionAlert.windowSizeX          = 126
ItemConditionAlert.windowSizeY          = 143
ItemConditionAlert.windowPaddingX       = 20
ItemConditionAlert.windowPaddingY       = 30
ItemConditionAlert.layoutDistanceX      = 100
ItemConditionAlert.layoutDistanceY      = 100
ItemConditionAlert.offsetX              = 12
ItemConditionAlert.offsetY              = 5

ItemConditionAlert.SvName               = "ICA_SavedVariables"
ItemConditionAlert.ConfigVersion        = 4

ItemConditionAlert.SvDefaults = {
  Scale = 1,
  DimX = 890,
  DimY = 150,
  OffsetX = 0,
  OffsetY = 0,
  AnchorPosition = TOPLEFT, 
  Layout = ItemConditionAlert.layouts[1],
  Movable = true,
  Nothreshold = false,
  Alpha = 1,
  FadedAlpha = 0.8,
  Font = {
    OffsetX = 0,
    OffsetY = 0,
    Family = "Fontin Regular",
    Size = 20,
    Style = "normal",
    Color = {r = 1, g = 1, b = 1, a = 1}
  },
  StateThresholds = {
    [ItemConditionAlert.ItemStates[1]] = {90, 100},
    [ItemConditionAlert.ItemStates[2]] = {60, 90},
    [ItemConditionAlert.ItemStates[3]] = {30, 60}, 
    [ItemConditionAlert.ItemStates[4]] = {1, 30},
  },
  VisibilityThreshold = ItemConditionAlert.ItemStates[3],
  WeaponVisibThreshold = ItemConditionAlert.ItemStates[4],
  Percentage = true
}

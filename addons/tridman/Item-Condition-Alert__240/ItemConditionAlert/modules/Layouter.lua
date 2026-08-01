local ItemConditionAlert = {}
ItemConditionAlert = _G["ItemConditionAlert"]
ItemConditionAlert.Layouter = {}

local HORIZONTAL = {
  ["HELM"]        = {X = -3,  Y = 0.5},
  ["CHEST"]       = {X = -2,  Y = 0.5},
  ["SHOULDERS"]   = {X = -1,  Y = 0.5},
  ["HANDS"]       = {X =  0,  Y = 0.5},
  ["WAIST"]       = {X =  1,  Y = 0.5},
  ["LEGS"]        = {X =  2,  Y = 0.5},
  ["FEET"]        = {X =  3,  Y = 0.5},
  ["MAIN_HAND"]   = {X = -0.5,  Y = -0.5},
  ["OFF_HAND"]    = {X =  0.5,  Y = -0.5},
  ["BACKUP_MAIN"] = {X = -0.5,  Y = -0.5},
  ["BACKUP_OFF"]  = {X =  0.5,  Y = -0.5},
}

local INV_HORIZONTAL = {
  ["HELM"]        = {X = -3,  Y = -0.5},
  ["CHEST"]       = {X = -2,  Y = -0.5},
  ["SHOULDERS"]   = {X = -1,  Y = -0.5},
  ["HANDS"]       = {X =  0,  Y = -0.5},
  ["WAIST"]       = {X =  1,  Y = -0.5},
  ["LEGS"]        = {X =  2,  Y = -0.5},
  ["FEET"]        = {X =  3,  Y = -0.5},
  ["MAIN_HAND"]   = {X = -0.5,  Y = 0.5},
  ["OFF_HAND"]    = {X =  0.5,  Y = 0.5},
  ["BACKUP_MAIN"] = {X = -0.5,  Y = 0.5},
  ["BACKUP_OFF"]  = {X =  0.5,  Y = 0.5},
}

local VERTICAL = {
  ["HELM"]        = {X = -0.5,  Y = -3},
  ["CHEST"]       = {X = -0.5,  Y = -2},
  ["SHOULDERS"]   = {X = -0.5,  Y = -1},
  ["HANDS"]       = {X = -0.5,  Y =  0},
  ["WAIST"]       = {X = -0.5,  Y =  1},
  ["LEGS"]        = {X = -0.5,  Y =  2},
  ["FEET"]        = {X = -0.5,  Y =  3},
  ["MAIN_HAND"]   = {X =  0.5,  Y = -0.5},
  ["OFF_HAND"]    = {X =  0.5,  Y =  0.5},
  ["BACKUP_MAIN"] = {X =  0.5,  Y = -0.5},
  ["BACKUP_OFF"]  = {X =  0.5,  Y =  0.5},
}

local INV_VERTICAL = {
  ["HELM"]        = {X =  0.5,  Y = -3},
  ["CHEST"]       = {X =  0.5,  Y = -2},
  ["SHOULDERS"]   = {X =  0.5,  Y = -1},
  ["HANDS"]       = {X =  0.5,  Y =  0},
  ["WAIST"]       = {X =  0.5,  Y =  1},
  ["LEGS"]        = {X =  0.5,  Y =  2},
  ["FEET"]        = {X =  0.5,  Y =  3},
  ["MAIN_HAND"]   = {X = -0.5,  Y = -0.5},
  ["OFF_HAND"]    = {X = -0.5,  Y =  0.5},
  ["BACKUP_MAIN"] = {X = -0.5,  Y = -0.5},
  ["BACKUP_OFF"]  = {X = -0.5,  Y =  0.5},
}

local COMPACT = {
  ["HELM"]        = {X =  0,  Y = -1},
  ["HANDS"]       = {X = -1,  Y =  0},
  ["CHEST"]       = {X =  0,  Y =  0},
  ["SHOULDERS"]   = {X =  1,  Y =  0},
  ["WAIST"]       = {X = -1,  Y =  1},
  ["LEGS"]        = {X =  0,  Y =  1},
  ["FEET"]        = {X =  1,  Y =  1},
  ["MAIN_HAND"]   = {X = -1,  Y = -1},
  ["OFF_HAND"]    = {X =  1,  Y = -1},
  ["BACKUP_MAIN"] = {X = -1,  Y = -1},
  ["BACKUP_OFF"]  = {X =  1,  Y = -1},
}

local HAWEAPONS = {
  ["HELM"]        = {X = -3,  Y = 0.5},
  ["CHEST"]       = {X = -2,  Y = 0.5},
  ["SHOULDERS"]   = {X = -1,  Y = 0.5},
  ["HANDS"]       = {X =  0,  Y = 0.5},
  ["WAIST"]       = {X =  1,  Y = 0.5},
  ["LEGS"]        = {X =  2,  Y = 0.5},
  ["FEET"]        = {X =  3,  Y = 0.5},
  ["MAIN_HAND"]   = {X = -1.5,  Y = -0.5, Ignoreautoswitch = true},
  ["OFF_HAND"]    = {X = -0.5,  Y = -0.5, Ignoreautoswitch = true},
  ["BACKUP_MAIN"] = {X =  0.5,  Y = -0.5, Ignoreautoswitch = true},
  ["BACKUP_OFF"]  = {X =  1.5,  Y = -0.5, Ignoreautoswitch = true},
}

local INV_HAWEAPONS = {
  ["HELM"]        = {X = -3,  Y = -0.5},
  ["CHEST"]       = {X = -2,  Y = -0.5},
  ["SHOULDERS"]   = {X = -1,  Y = -0.5},
  ["HANDS"]       = {X =  0,  Y = -0.5},
  ["WAIST"]       = {X =  1,  Y = -0.5},
  ["LEGS"]        = {X =  2,  Y = -0.5},
  ["FEET"]        = {X =  3,  Y = -0.5},
  ["MAIN_HAND"]   = {X = -1.5,  Y = 0.5, Ignoreautoswitch = true},
  ["OFF_HAND"]    = {X = -0.5,  Y = 0.5, Ignoreautoswitch = true},
  ["BACKUP_MAIN"] = {X =  0.5,  Y = 0.5, Ignoreautoswitch = true},
  ["BACKUP_OFF"]  = {X =  1.5,  Y = 0.5, Ignoreautoswitch = true},
}

local VAWEAPONSL = {
  ["HELM"]        = {X = -0.5,  Y = -3},
  ["CHEST"]       = {X = -0.5,  Y = -2},
  ["SHOULDERS"]   = {X = -0.5,  Y = -1},
  ["HANDS"]       = {X = -0.5,  Y =  0},
  ["WAIST"]       = {X = -0.5,  Y =  1},
  ["LEGS"]        = {X = -0.5,  Y =  2},
  ["FEET"]        = {X = -0.5,  Y =  3},
  ["MAIN_HAND"]   = {X =  0.5,  Y = -1.5, Ignoreautoswitch = true},
  ["OFF_HAND"]    = {X =  0.5,  Y = -0.5, Ignoreautoswitch = true},
  ["BACKUP_MAIN"] = {X =  0.5,  Y =  0.5, Ignoreautoswitch = true},
  ["BACKUP_OFF"]  = {X =  0.5,  Y =  1.5, Ignoreautoswitch = true},
}

local INV_VAWEAPONS = {
  ["HELM"]        = {X =  0.5,  Y = -3},
  ["CHEST"]       = {X =  0.5,  Y = -2},
  ["SHOULDERS"]   = {X =  0.5,  Y = -1},
  ["HANDS"]       = {X =  0.5,  Y =  0},
  ["WAIST"]       = {X =  0.5,  Y =  1},
  ["LEGS"]        = {X =  0.5,  Y =  2},
  ["FEET"]        = {X =  0.5,  Y =  3},
  ["MAIN_HAND"]   = {X = -0.5,  Y = -1.5, Ignoreautoswitch = true},
  ["OFF_HAND"]    = {X = -0.5,  Y = -0.5, Ignoreautoswitch = true},
  ["BACKUP_MAIN"] = {X = -0.5,  Y =  0.5, Ignoreautoswitch = true},
  ["BACKUP_OFF"]  = {X = -0.5,  Y =  1.5, Ignoreautoswitch = true},
}

local RETICLE = {
  ["HELM"]        = {X =    0,  Y = -1.5},
  ["CHEST"]       = {X = -1.5,  Y = -0.5},
  ["SHOULDERS"]   = {X =  1.5,  Y = -0.5},
  ["HANDS"]       = {X = -1.5,  Y =  0.5},
  ["WAIST"]       = {X =  1.5,  Y =  0.5},
  ["LEGS"]        = {X = -0.5,  Y =  1.5},
  ["FEET"]        = {X =  0.5,  Y =  1.5},
  ["MAIN_HAND"]   = {X =   -1,  Y = -1.5},
  ["OFF_HAND"]    = {X =    1,  Y = -1.5},
  ["BACKUP_MAIN"] = {X =   -1,  Y = -1.5},
  ["BACKUP_OFF"]  = {X =    1,  Y = -1.5},
}

function ItemConditionAlert.Layouter:getItemsLayout(layout)
  
  local layoutedItems = ItemConditionAlert.SlotItem.DefaultItems:New()
  local mylayout = VERTICAL
  local myposition = TOPLEFT
  
  if (layout == ItemConditionAlert.layouts[1]) or (layout == ItemConditionAlert.layouts[2]) then
    ItemConditionAlert.sv.DimX = 2 * ItemConditionAlert.layoutDistanceX
    ItemConditionAlert.sv.DimY = 7 * ItemConditionAlert.layoutDistanceY
    if (layout == ItemConditionAlert.layouts[1]) then mylayout = VERTICAL end
    if (layout == ItemConditionAlert.layouts[2]) then mylayout = INV_VERTICAL end
  elseif (layout == ItemConditionAlert.layouts[3]) or (layout == ItemConditionAlert.layouts[4]) then
    ItemConditionAlert.sv.DimX = 7 * ItemConditionAlert.layoutDistanceX
    ItemConditionAlert.sv.DimY = 2 * ItemConditionAlert.layoutDistanceY
    if (layout == ItemConditionAlert.layouts[3]) then mylayout = HORIZONTAL end
    if (layout == ItemConditionAlert.layouts[4]) then mylayout = INV_HORIZONTAL end
  elseif layout == ItemConditionAlert.layouts[5] then
    ItemConditionAlert.sv.DimX = 3 * ItemConditionAlert.layoutDistanceX
    ItemConditionAlert.sv.DimY = 3 * ItemConditionAlert.layoutDistanceY
    mylayout = COMPACT
  elseif (layout == ItemConditionAlert.layouts[6]) or (layout == ItemConditionAlert.layouts[7]) then
    ItemConditionAlert.sv.DimX = 7 * ItemConditionAlert.layoutDistanceX
    ItemConditionAlert.sv.DimY = 2 * ItemConditionAlert.layoutDistanceY
    if (layout == ItemConditionAlert.layouts[6]) then mylayout = HAWEAPONS end
    if (layout == ItemConditionAlert.layouts[7]) then mylayout = INV_HAWEAPONS end
  elseif (layout == ItemConditionAlert.layouts[8]) or (layout == ItemConditionAlert.layouts[9]) then
    ItemConditionAlert.sv.DimX = 2 * ItemConditionAlert.layoutDistanceX
    ItemConditionAlert.sv.DimY = 7 * ItemConditionAlert.layoutDistanceY
    if (layout == ItemConditionAlert.layouts[8]) then mylayout = VAWEAPONSL end
    if (layout == ItemConditionAlert.layouts[9]) then mylayout = INV_VAWEAPONS end
  elseif (layout == ItemConditionAlert.layouts[10]) then
    ItemConditionAlert.sv.DimX = 4 * ItemConditionAlert.layoutDistanceX
    ItemConditionAlert.sv.DimY = 4 * ItemConditionAlert.layoutDistanceY
    ItemConditionAlert.sv.AnchorPosition = CENTER
    ItemConditionAlert.sv.OffsetX = 0
    ItemConditionAlert.sv.OffsetY = 0
    mylayout = RETICLE
  end
  

  for item, values in pairs(mylayout) do
    layoutedItems[item].X = values.X  * ItemConditionAlert.layoutDistanceX
    layoutedItems[item].Y = values.Y * ItemConditionAlert.layoutDistanceY
    layoutedItems[item].Ignoreautoswitch = values.Ignoreautoswitch
  end
  
  return layoutedItems, myposition
end
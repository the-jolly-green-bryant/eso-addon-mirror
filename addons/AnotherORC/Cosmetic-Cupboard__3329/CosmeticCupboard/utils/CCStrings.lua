local strings = {

  -- Tabe names
  CC_MEMENTO_TAB = "Quickslots",
  CC_COLLECTION_TAB = "Collections",
  CC_EMOTE_TAB = "Emotes",

  -- Panel name
  CC_TAB_MENU_COLLECTIBLE = "Collectibles",
  CC_TAB_MENU_EMOTE       = "Emotes",
  CC_TAB_MENU_MEMENTO     = "Mementos",

  -- [[ Events ]] --
  -- Collection Panel
  CC_ON_COLLECTIBLE_CLICKED       = "OnCollectibleClicked",
  CC_ON_COLLECTIBLE_SHIFT_CLICKED = "OnCollectibleShiftClicked",
  CC_ON_COLLECTIBLE_CTRL_CLICKED  = "OnCollectibleCtrlClicked",
  CC_ON_COLLECTIBLE_RIGHT_CLICKED = "OnCollectibleRightClicked",

  CC_ON_CHANGES_MADE              = "OnChangesMade",
  CC_ON_CHANGES_SAVED             = "OnChangesSaved",

  CC_ON_PROFILE_CHANGED           = "OnProfileChanged",

  -- Scene
  CC_ON_PANEL_OPENED              = "OnPanelOpened",
  CC_ON_PANEL_CLOSED              = "OnPanelClosed",

  -- UI Events
  CC_ON_DRAG_START                = "OnItemDragStart",
  CC_ON_DRAG_DROP                 = "OnItemDragDrop",

  CC_ON_EQUIP_START               = "OnEquipStart",
  CC_ON_EQUIPE_FINISH             = "OnEquipFinish",
}

local function CreateStrings()
  for i, j in pairs(strings) do
    ZO_CreateStringId(i, j)
  end
end

CreateStrings()
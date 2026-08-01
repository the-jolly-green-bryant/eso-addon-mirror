CraftAutoLoot      = {}

CraftAutoLoot.name = "CraftAutoLoot"

function CraftAutoLoot:Initialize()
  ZO_ReticleContainerInteract:SetHandler("OnShow", function()
    local action, container, _, _, additionalInfo, _ = GetGameCameraInteractableActionInfo()
    local searchAction                               = "Search"
    local isAction                                   = {
      ["Mine"] = true,
      ["Collect"] = true,
      ["Cut"] = true,
      ["Reel In"] = true,
    }
    local isLootable                                 = {
      ["Apple Basket"] = true,
      ["Apple Crate"] = true,
      ["Apples"] = true,
      ["Backpack"] = true,
      ["Bookshelf"] = true,
      ["Barrel"] = true,
      ["Barrels"] = true,
      ["Basket"] = true,
      ["Cabinet"] = true,
      ["Cauldron"] = true,
      ["Cupboard"] = true,
      ["Corn Basket"] = true,
      ["Crate"] = true,
      ["Crates"] = true,
      ["Desk"] = true,
      ["Drawers"] = true,
      ["Dresser"] = true,
      ["Flour Sack"] = true,
      ["Greens Basket"] = true,
      ["Heavy Crate"] = true,
      ["Heavy Sack"] = true,
      ["Jewelry Box"] = true,
      ["Keg"] = true,
      ["Melon Basket"] = true,
      ["Millet Basket"] = true,
      ["Nightstand"] = true,
      ["Pumpkin Basket"] = true,
      ["Rack"] = true,
      ["Sack"] = true,
      ["Saltrice Sack"] = true,
      ["Seasoning Sack"] = true,
      ["Tomato Crate"] = true,
      ["Trunk"] = true,
      ["Urn"] = true,
      ["Wardrobe"] = true,
    }
    if isAction[action] or ((isLootable[container]) and action == searchAction) then
      SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, 1)
    else
      SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, 0)
    end
  end)
end

function CraftAutoLoot.OnAddOnLoaded(event, addonName)
  if addonName == CraftAutoLoot.name then
    CraftAutoLoot:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(CraftAutoLoot.name, EVENT_ADD_ON_LOADED, CraftAutoLoot.OnAddOnLoaded)

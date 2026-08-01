HouseClick = {
  name = "HouseClick",
  version = "1.2",

  default = {
  },
}

local HC = HouseClick

function HC.OnAddOnLoaded(_, name)
  if name == HC.name then
    HC:Initialize()
    EVENT_MANAGER:UnregisterForEvent(HC.name, EVENT_ADD_ON_LOADED)
  end
end

EVENT_MANAGER:RegisterForEvent(HC.name, EVENT_ADD_ON_LOADED, HC.OnAddOnLoaded)

function HC:RequestJumpInsideToCurrentHouse()
  text = ZO_HousingBook_KeyboardContentsName:GetText()

  for houseid = 1, 250 do
    if string.upper(GetCollectibleName(GetCollectibleIdForHouse(houseid))) == text then
      RequestJumpToHouse(houseid, false)
      SCENE_MANAGER:ShowBaseScene()
      break
    end
  end
end

function HC:RequestJumpOutsideToCurrentHouse()
  text = ZO_HousingBook_KeyboardContentsName:GetText()

  for houseid = 1, 250 do
    if string.upper(GetCollectibleName(GetCollectibleIdForHouse(houseid))) == text then
      RequestJumpToHouse(houseid, true)
      SCENE_MANAGER:ShowBaseScene()
      break
    end
  end
end

function HC:Initialize()
  ZO_CreateStringId("SI_BINDING_NAME_PRIMARYHOUSEINSIDE", "Primary house inside")
  ZO_CreateStringId("SI_BINDING_NAME_PRIMARYHOUSEOUTSIDE", "Primary house outside")

  ZO_HousingBook_KeyboardContentsHousingInteractButtonsTravelToHouse:SetHandler('OnHide', function()
    ZO_HousingBook_KeyboardContentsCustomHousingInteractButtonsTravelInside:SetHidden(not ZO_HousingBook_KeyboardContentsCustomHousingInteractButtonsTravelInside:IsHidden())
    ZO_HousingBook_KeyboardContentsCustomHousingInteractButtonsTravelOutside:SetHidden(not ZO_HousingBook_KeyboardContentsCustomHousingInteractButtonsTravelOutside:IsHidden())
  end)

  ZO_HousingBook_KeyboardContentsHousingInteractButtonsTravelToHouse:SetHandler('OnShow', function()
    ZO_HousingBook_KeyboardContentsCustomHousingInteractButtonsTravelInside:SetHidden(not ZO_HousingBook_KeyboardContentsCustomHousingInteractButtonsTravelInside:IsHidden())
    ZO_HousingBook_KeyboardContentsCustomHousingInteractButtonsTravelOutside:SetHidden(not ZO_HousingBook_KeyboardContentsCustomHousingInteractButtonsTravelOutside:IsHidden())
  end)
end

function HouseClick.inside(control)
    HC:RequestJumpInsideToCurrentHouse()
end

function HouseClick.outside(control)
    HC:RequestJumpOutsideToCurrentHouse()
end

function HouseClick.keybindOutside()
  RequestJumpToHouse(GetHousingPrimaryHouse(), true)
end

function HouseClick.keybindInside()
  RequestJumpToHouse(GetHousingPrimaryHouse(), false)
end

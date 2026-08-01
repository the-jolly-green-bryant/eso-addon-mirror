local AGS = AwesomeGuildStore

local MultiChoiceFilterBase = AGS.class.MultiChoiceFilterBase

local FILTER_ID = AGS.data.FILTER_ID
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID

local UnknownGearFilter = MultiChoiceFilterBase:Subclass()
AGS.class.UnknownGearFilter = UnknownGearFilter

function UnknownGearFilter:New(...)
    return MultiChoiceFilterBase.New(self, ...)
end

function UnknownGearFilter:Initialize()

  local filterIcons = {}
  filterIcons[1] = {
    id = 1,
    label = "Unknown gear",
    icon = "/esoui/art/tutorial/tutorial_collections_tabicon_itemsets_%s.dds",
  }

	MultiChoiceFilterBase.Initialize(self, FILTER_ID.UNKNOWN_GEAR_FILTER, AGS.class.FilterBase.GROUP_LOCAL, ("Unknown Gear"), filterIcons )

  self:SetEnabledSubcategories({
    [SUB_CATEGORY_ID.ALL] = true,
  })
end

function UnknownGearFilter:FilterLocalResult(itemData)
  local itemLinkItemType, itemLinkSpecializedItemType = GetItemLinkItemType(itemData.itemLink)
  if itemLinkItemType == ITEMTYPE_WEAPON or itemLinkItemType == ITEMTYPE_ARMOR or itemLinkItemType == ITEMTYPE_JEWELRY then
    if not IsItemLinkSetCollectionPiece(itemData.itemLink) then return nil end
    return not IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemData.itemLink))
  else
    return false
  end
end

function AGS_UGF.initAGS()
	--MultiChoiceFilterBase.Initialize(self, FILTER_ID.UNKNOWN_GEAR_FILTER, AGS.class.FilterBase.GROUP_LOCAL, ("Unknown Gear"), filterIcons )
  AGS:RegisterFilter(UnknownGearFilter:New())
  AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(FILTER_ID.UNKNOWN_GEAR_FILTER))
end
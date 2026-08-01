local Addon = FarmingPartyPlus
if type(Addon) ~= 'table' or Addon.New == nil then
  Addon = ZO_Object:Subclass()
end

Addon.Name = 'FarmingPartyPlus'
Addon.Modules = Addon.Modules or {}
Addon.Classes = Addon.Classes or {}
Addon.DataTypes = Addon.DataTypes or {
  MEMBER = 1,
  MEMBER_ITEM = 2,
  FILTER_HEADER = 3,
  FILTER_ROW = 4,
  FILTER_RECIPE_VALUE = 5
}
Addon.SaveData = Addon.SaveData or {}
Addon.Settings = Addon.Settings or {}

FarmingPartyPlus = Addon

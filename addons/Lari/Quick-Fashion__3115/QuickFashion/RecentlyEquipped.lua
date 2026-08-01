local QF = _G["QF"]

local WM = WINDOW_MANAGER

local function TrimRecentlyEquippedList(collectibleType, list)
  local maxSize = QF.SavedVars.numRecentCollectibles
  while #list > maxSize do
    table.remove(list)
  end
  QF.SavedVars.RecentCollectibles[collectibleType] = list
end

function QF.AddToRecentlyEquipped(collectibleId, collectibleType)
  local list = QF.SavedVars.RecentCollectibles[collectibleType]
  table.insert(list, 1, collectibleId)
  for i = 2, #list do
    if list[i] == collectibleId then
      table.remove(list, i)
    end
  end

  TrimRecentlyEquippedList(collectibleType, list)

  if QF.SavedVars.collectibleTab == "recent" then
    QF.CreateCollectibleGridByType(collectibleType)
  end
end

-- Used to adjust numRecentCollectibles under Settings
function QF.RefreshRecentlyEquipped()
  for collectibleType,_ in pairs(QF.SavedVars.RecentCollectibles) do
    local list = QF.SavedVars.RecentCollectibles[collectibleType]
    TrimRecentlyEquippedList(collectibleType, list)
  end

  QF.InitCollectibleCategoryItems()
  QF.FilterByIcons()
end

----------------------------------
-- INITIALIZATION --
----------------------------------

function QF.InitRecentlyEquippedIcons()
  local RecentCollectibles = QF.SavedVars.RecentCollectibles
  for collectibleType,_ in pairs(RecentCollectibles) do
    if RecentCollectibles[collectibleType] ~= nil then
      local size = #RecentCollectibles[collectibleType]
      for i = 1, size do
        local collectibleId = RecentCollectibles[collectibleType][i]
        QF.CreateCollectibleIcon(collectibleId, collectibleType)
      end
    end
  end
end

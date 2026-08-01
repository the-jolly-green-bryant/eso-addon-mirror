-- Lionas's Food & Drink Reminder
-- Author: Lionas
-- CommonUtil

LioFADRCommon = {}

-- テーブルの長さを取得する
function LioFADRCommon.getTableLength(T)

  local count = 0
  
  if (T ~= nil) then
    
    for _ in pairs(T) do
      count = count + 1 
    end
  
  end

  return count

end

-- テーブルに指定の要素が含まれているかどうか  
function LioFADRCommon.isContain(element, tbl)

  if table == nil or LioFADRCommon.getTableLength(tbl) == 0 then
    return false
  end

  for _, id in pairs(tbl) do

    if( id == element ) then
      return true
    end

  end

  return false

end


-- テーブルに指定のkeyが含まれているかどうか  
function LioFADRCommon.isContainKey(key, tbl)

  if table == nil or LioFADRCommon.getTableLength(tbl) == 0 then
    return false
  end

  for k, v in pairs(tbl) do

    if( k == key ) then
      return true
    end

  end

  return false

end


-- Clear table
function LioFADRCommon.clearTable(tbl)

  if(tbl ~= nil and (LioFADRCommon.getTableLength(tbl) ~= 0)) then

    for i, v in pairs(tbl) do
      tbl[i] = nil
    end

  end

end


-- Insert table
function LioFADRCommon.insertTable(tbl, element)
  
  if(not LioFADRCommon.isContain(element, tbl)) then
    table.insert(tbl, element)
  end
  
end


-- テーブルから削除
function LioFADRCommon.removeFromTable(table, abilityId)

  local i = 1
  while (i <= #table) do
    if(table[i] == abilityId) then
      table[i] = nil
    else
      i = i + 1
    end
  end  

end

-- 色設定
function LioFADRCommon.getColoredString(color, str)

  return "|c" .. color .. str .. "|r"

end


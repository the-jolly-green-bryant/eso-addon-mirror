LibChars = {}

function LibChars:initialize(savedVariablesAccount, fnCharNew, fnCharExists, fnCharRemoved)
  local touchedChars = {}
  local charsToRemove = {}
  
  local savedVariables = ZO_SavedVars:NewAccountWide(savedVariablesAccount, 1, 'LibChars', {chars= {}})
    
  for i=1,GetNumCharacters() do
    local charName, gender, level, classId, raceId, alliance, charId, locationId = GetCharacterInfo(i)
    charName = charName:sub(1, charName:find("%^") - 1)
    
    local doFnCharNew = true
    if savedVariables.chars[charId] then
      if type(savedVariables.chars[charId]) ~= 'table' then
        savedVariables.chars[charId] = {
          name = charName
        }
      else
        savedVariables.chars[charId].name = charName
      end      
      doFnCharNew = false
    else
      savedVariables.chars[charId] = {
        name = charName     
      }    
    end
    
    if doFnCharNew then
      if type(fnCharNew) == 'function' then
        fnCharNew(charId, savedVariables.chars[charId])    
      end
    else
      if type(fnCharExists) == 'function' then
        fnCharExists(charId, savedVariables.chars[charId])
      end    
    end
    
    touchedChars[charId] = true
  end
  
  for charId,v in pairs(savedVariables.chars) do
    if not touchedChars[charId] then
     charsToRemove[charId] = true
    end
  end
  
  for charId,v in pairs(charsToRemove) do
    if type(fnCharRemoved) == 'function' then
      fnCharRemoved(charId, savedVariables.chars[charId])
    end
    savedVariables.chars[charId] = nil
  end
  
  return savedVariables
end
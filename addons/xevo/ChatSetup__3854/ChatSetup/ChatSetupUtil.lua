ChatSetupUtil = {}

local function trim(s)
    if s == nil then return "" end
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end


ChatSetupUtil.Behead = function (sentence)
    local result = trim(string.match(sentence, "%S+ *"))
    if result ~= nil then   
        sentence = trim(string.sub(sentence, string.len(result) + 1))

    else
        result = nil
        sentence = nil
        
    end
    return result, sentence
end

ChatSetupUtil.SplitString = function (sentence)
    local result = {}
    local i = 0
    while sentence ~= nil do
        i = i + 1
        result[i], sentence = GSSUtil.Behead(sentence)
    end
    
    return result
end

ChatSetupUtil.Trim = trim


ChatSetupUtil.TableLength = function(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end



ChatSetupUtil.btoi = function(b)
  return b and 1 or 0
end


ChatSetupUtil.GetChildControlByName = function(parentControl, childName)
    local numChildren = parentControl:GetNumChildren()
    
    local result = nil
    
    for i = 1, numChildren do
        local control = parentControl:GetChild(i)
        if (control ~= nil) then
            local n = control:GetName()
            if n == childName then
                result = control
            end
        end
    end
    
    return result
end


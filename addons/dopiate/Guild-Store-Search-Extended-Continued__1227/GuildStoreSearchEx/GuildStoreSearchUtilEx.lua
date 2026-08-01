
gsse.utils.Behead = function (sentence)
    local result = string.match(sentence, "%S+ *")
    if result ~= nil then   
        sentence = string.sub(sentence, string.len(result) + 1)

    else
        result = nil
        sentence = nil
        
    end
    return result, sentence
end

gsse.utils.SplitString = function (sentence)
    local result = {}
    local i = 0
    while sentence ~= nil do
        i = i + 1
        result[i], sentence = gsse.utils.Behead(sentence)
    end
    
    return result
end

gsse.utils.Trim = function (s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

gsse.utils.FirstChar = function(s)
    return s:sub(1,1)
end

gsse.utils.GetQualityColor = function(s)
	local colors=GetItemQualityColor(s)
	
	local colorcode=gsse.utils.ToHex(colors.r*255)..gsse.utils.ToHex(colors.g*255)..gsse.utils.ToHex(colors.b*255)

    return colorcode
end

gsse.utils.ToHex = function(s)
	local hex=string.format("%x",s)
	
	if string.len(hex)<2 then hex="0"..hex end
	
	return hex
end




MailerDemon = {}


function MailerDemon.FindInList(findMe, map) -- find element v of l satisfying f(v)
	for mapKey, mapValue in ipairs(map) do
		if (tostring(findMe) == tostring(mapKey)) or (tostring(findMe) == tostring (mapValue)) then return true end
		if (findMe == mapValue) or (findMe == mapKey) then return true end
	end
	return false
end


function MailerDemon.Itemize(listString, active, item)

	local ret = listString

	if active then
		if string.sub(listString, -1) == " " then
			ret = listString .. item
		else
			ret = listString .. ", " .. item
		end

	end

	return ret
end


-- return the first integer index holding the value
function MailerDemon.GetTableIndexFor(t,val)
    for k,v in ipairs(t) do
        if v == val then return k end
    end
end


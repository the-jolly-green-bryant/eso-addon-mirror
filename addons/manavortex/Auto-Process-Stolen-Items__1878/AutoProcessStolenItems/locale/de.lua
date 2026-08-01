local strings = {
	-- [1] = "osmetic", 
	-- [2] = "tensil", 
	-- [3] = "ish", 
	-- [4] = "ookware", 
	-- [5] = "inkware", 
}


-- Overwrite English strings
for stringId, value in ipairs(strings) do
    AutoProcessStolenItems.crowStrings[stringId] = value
end

--Functions relating to Strings

-- take a string and break by spaces to an array
split_w = function (astring)   -- String sentence
    if (astring == nil) then
		print("split_w nil")
		return {}
	end

	local words = {}
	for w in string.gmatch(astring, "%S+") do
		table.insert(words,w)
	end
	return words	--array of the words
end


--[[
test = "In Veteran White-Gold Tower, become completely engulfed in flame by the Planar Inhibitor's Heat Stroke attack before it completes its Daedric Catastrophe attack. Then stay alive until the Planar Inhibitor is defeated."
split = split_w(test)
print("Split_w returned a table of " .. #split .. "  words.")

--print(dump(split))
--]]

flow_w = function( words_t, max_length )
--[[ given an array of words  { [1]="TENTENTEN0", [2] = "FOUR", [3]="THREE"}
	return an array of array of words so that the length is not greater than max_length
with max_length 10
  {  [1] = {[1]="TENTENTEN0"},  --array of 1 value
      [2] = {[1]="FOUR", [2]="THREE"}  --array of 2 value
	}
--]]
    if words_t == nil then
		print("words_t is nil in flow_s")
		return nil
	end

	if type(max_length) ~= "number" then
		print("max_length is not a number in flow_s")
		print("max_length is type " .. type(max_length) .. " in flow_s")
		return nil
	end



	local result = {}
	local line_t = {}
	local line_len = 0
	for i, word in ipairs (words_t) do
	--	print (word)
		if (string.len(word) + line_len) > max_length then
			table.insert(result,line_t)
			line_t = {}
			line_len = 0
		end
		table.insert(line_t, word)
		if line_len >  0 then
			line_len = line_len + string.len(word) +1		--Allow for Spaces
		else
			line_len = line_len + string.len(word)
		end
	end
	table.insert(result,line_t)
	return result
end


join_s = function (words_tt)
--given an array of array of words (output from flow_w) Produce a string with \n
    if words_tt == nil then
		print("parameter nil in join_s")
		return nil
	end

	local result = ""

	for i,words_t in ipairs (words_tt) do

		for _,word in ipairs (words_t) do
			result = result .. " " ..  word
		end

		if ( i ~= #words_tt) then
			result = result .."\n"		-- Don't add Trailing \n  on last line.
		end
	end
	return result
end

--[[

test = "In Veteran White-Gold Tower, become completely engulfed in flame by the Planar Inhibitor's Heat Stroke attack before it completes its Daedric Catastrophe attack. Then stay alive until the Planar Inhibitor is defeated."
split_words = split_w(test)
--print("Split_w returned a table of " .. #split .. "  words.")
flow_words = flow_w(split_words, 60)
flow_string = join_s(flow_words)
--print(dump(split))
print(flow_string)
--]]

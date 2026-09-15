-- PB's Translate -- splitting a chat line into words
--
-- Chat text is not clean prose. It carries the client's own markup -- item links, colour
-- codes, texture icons -- and it is typed fast, on a controller, by people who write "u r"
-- and "dont". Both are dealt with here, before the grammar sees anything:
--
--   * markup is lifted out whole and handed back untouched in the output, so a linked item
--     stays a working link inside the translation;
--   * contractions and chat spellings are expanded into the words they stand for, so the
--     grammar only ever has to know "do not", never "don't", "dont" and "do'nt".
--
-- A token is one of
--   { kind = "word", w = "lower case", orig = "As Typed" }
--   { kind = "num",  v = "160" }
--   { kind = "punct", v = "." | "!" | "?" | "," | ";" | ":" }
--   { kind = "raw",  v = "anything else, verbatim" }

PBsTranslate = PBsTranslate or {}
local T = PBsTranslate

-- Chat spellings, and the apostrophe-less contractions people type on a console keyboard.
-- Only forms that cannot mean anything else are listed: "its", "ill" and "were" are real
-- words and are left alone ("its" is the one exception -- in chat it is "it is" far more often
-- than the possessive). "def" is not here: in Cyrodiil it means defend, and dict/Cyrodiil.lua
-- has it.
local NORMALIZE = {
	im = "i am", ive = "i have", youre = "you are", theyre = "they are",
	dont = "do not", doesnt = "does not", didnt = "did not", isnt = "is not", arent = "are not",
	wasnt = "was not", werent = "were not", cant = "can not", cannot = "can not",
	wont = "will not", couldnt = "could not", shouldnt = "should not", wouldnt = "would not",
	havent = "have not", hasnt = "has not", hadnt = "had not", mustnt = "must not",
	thats = "that is", whats = "what is", wheres = "where is", hows = "how is", whos = "who is",
	theres = "there is", heres = "here is", lets = "let's",
	wanna = "want to", gonna = "going to", gotta = "have to", hafta = "have to",
	u = "you", ur = "your", r = "are", ya = "you", yu = "you", pls = "please", plz = "please",
	pl0x = "please", cuz = "because", coz = "because", bc = "because", cos = "because",
	tho = "though", thru = "through", abt = "about", w = "with", bout = "about",
	b4 = "before", b = "be", shud = "should", cud = "could", wud = "would", ["2day"] = "today", tmrw = "tomorrow", tmr = "tomorrow", tonite = "tonight",
	rn = "right now", atm = "at the moment", n = "and", nd = "and", k = "ok", kk = "ok",
	okay = "ok", yea = "yes", yeah = "yes", yep = "yes", yup = "yes", nope = "no", nah = "no",
	ppl = "people", msg = "message", pic = "picture", ez = "easy", srsly = "seriously",
	prob = "probably", probs = "probably", sry = "sorry", soz = "sorry",
	plsss = "please", pleeease = "please", someone = "someone", sb = "somebody",
}

-- 's after these is "is"; after anything else it is the possessive.
local S_IS = {
	it = true, that = true, what = true, where = true, who = true, how = true, there = true,
	here = true, he = true, she = true, this = true, everything = true, everyone = true,
	nothing = true, something = true, someone = true, when = true, why = true,
}

local N_T_BASE = { ca = "can", wo = "will", sha = "shall" }

local function PushWords(tokens, phrase, orig)
	local first = true
	for word in phrase:gmatch("[^ \t\r\n]+") do
		tokens[#tokens + 1] = { kind = "word", w = word, orig = first and orig or word }
		first = false
	end
end

-- One word as typed, possibly with an apostrophe, into one or more word tokens.
local function PushWord(tokens, orig)
	local lower = T.Lower(orig)

	local head, tail = lower:match("^(.-)'([A-Za-z]*)$")
	if head and head ~= "" then
		if lower == "let's" then
			PushWords(tokens, "let's", orig)
			return
		end
		if tail == "t" and head:sub(-1) == "n" then
			local base = head:sub(1, -2)
			PushWords(tokens, (N_T_BASE[base] or base) .. " not", orig)
			return
		end
		if tail == "m" then
			PushWords(tokens, head .. " am", orig)
			return
		elseif tail == "re" then
			PushWords(tokens, head .. " are", orig)
			return
		elseif tail == "ve" then
			PushWords(tokens, head .. " have", orig)
			return
		elseif tail == "ll" then
			PushWords(tokens, head .. " will", orig)
			return
		elseif tail == "d" then
			PushWords(tokens, head .. " would", orig)
			return
		elseif tail == "s" or tail == "" then
			if tail == "s" and S_IS[head] then
				PushWords(tokens, head .. " is", orig)
			else
				local original = orig:match("^(.-)'") or head
				tokens[#tokens + 1] = { kind = "word", w = head, orig = original }
				tokens[#tokens + 1] = { kind = "word", w = "'s", orig = "'s" }
			end
			return
		end
		-- Anything else with an apostrophe in it: drop the apostrophe and carry on.
		lower = head .. tail
		orig = lower
	end

	local expanded = NORMALIZE[lower]
	if expanded then
		PushWords(tokens, expanded, orig)
		return
	end
	tokens[#tokens + 1] = { kind = "word", w = lower, orig = orig }
end

local PUNCT = { ["."] = true, ["!"] = true, ["?"] = true, [","] = true, [";"] = true, [":"] = true }

function T.Tokenize(text)
	local tokens = {}
	if type(text) ~= "string" then
		return tokens
	end

	-- Typographic apostrophes (U+2018/U+2019) are what a phone or a PS5 keyboard may produce.
	text = text:gsub("\226\128\153", "'"):gsub("\226\128\152", "'")

	local i, length = 1, #text
	while i <= length do
		local c = text:sub(i, i)

		if c == "|" then
			local markup = text:match("^|H.-|h.-|h", i) or text:match("^|t.-|t", i)
			if markup then
				tokens[#tokens + 1] = { kind = "raw", v = markup }
				i = i + #markup
			else
				local colour = text:match("^|c%x%x%x%x%x%x", i) or text:match("^|r", i)
				if colour then
					i = i + #colour
				else
					tokens[#tokens + 1] = { kind = "raw", v = "|" }
					i = i + 1
				end
			end
		elseif c:match("[ \t\r\n]") then
			i = i + 1
		elseif c:match("[A-Za-z]") then
			local word = text:match("^[A-Za-z][A-Za-z0-9]*'[A-Za-z]+", i) or text:match("^[A-Za-z][A-Za-z0-9]*", i)
			PushWord(tokens, word)
			i = i + #word
		elseif c:match("[0-9]") then
			local word = text:match("^[0-9]+[A-Za-z][A-Za-z0-9]*", i)
			if word then
				PushWord(tokens, word)
				i = i + #word
			else
				local number = text:match("^[0-9]+[%.,]?[0-9]*", i)
				if number:sub(-1) == "." or number:sub(-1) == "," then
					number = number:sub(1, -2)
				end
				tokens[#tokens + 1] = { kind = "num", v = number }
				i = i + #number
			end
		elseif PUNCT[c] then
			-- "..." and "?!" collapse to one mark; a question mark anywhere in the run wins.
			local run = text:match("^[%.!%?,;:]+", i)
			local mark = run:find("?", 1, true) and "?" or run:sub(1, 1)
			tokens[#tokens + 1] = { kind = "punct", v = mark }
			i = i + #run
		elseif c == "-" and #tokens > 0 and tokens[#tokens].kind == "word" and text:sub(i + 1, i + 1):match("[A-Za-z]") then
			-- well-known, re-roll: read as two words.
			i = i + 1
		elseif c == "'" or c == "\"" or c == "(" or c == ")" or c == "*" or c == "~" then
			i = i + 1
		else
			-- Anything else -- another script, an emoji, a symbol -- stays as typed. Runs of it
			-- are kept together so a Japanese word is not cut into bytes.
			local run = text:match("^[^ \t\r\nA-Za-z0-9|%.!%?,;:]+", i) or c
			tokens[#tokens + 1] = { kind = "raw", v = run }
			i = i + #run
		end
	end

	return tokens
end

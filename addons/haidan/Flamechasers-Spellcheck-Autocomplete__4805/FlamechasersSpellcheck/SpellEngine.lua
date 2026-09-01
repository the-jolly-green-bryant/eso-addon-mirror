local FSC = FlamechasersSpellcheck

local English = FSC.English
local Frequency = FSC.Frequency
local DeleteIndex = FSC.CorrectionDeletes
local ESO = FSC.ESO
local Chat = FSC.Chat

local LOWER_A = string.byte("a")
local LOWER_Z = string.byte("z")
local MAX_CORRECTION_COST = 235
local MAX_DELETE_CANDIDATES = 96
local MAX_PERSONAL_CORRECTION_WORDS = 800
local MAX_PERSONAL_CORRECTION_BUCKET = 6
local MAX_CORRECTION_SUGGESTION_CACHE = 192

local function IsPackEnabled(self,id)
    return self:IsDictionaryEnabled(id)
end

-- Scores here are only priors. The final rank also considers weighted typing
-- error cost, corpus frequency, ESO/chat vocabulary, surrounding words and the
-- player's own accepted corrections.
local COMMON_PRIORITY = {
    ["the"] = 150, ["this"] = 140, ["that"] = 138, ["there"] = 136, ["their"] = 134,
    ["they"] = 132, ["then"] = 126, ["than"] = 124, ["with"] = 122, ["what"] = 120,
    ["when"] = 118, ["where"] = 116, ["which"] = 114, ["would"] = 112, ["could"] = 110,
    ["should"] = 108, ["because"] = 132, ["really"] = 108, ["pretty"] = 104, ["people"] = 102,
    ["please"] = 100, ["before"] = 98, ["after"] = 96, ["about"] = 94, ["again"] = 92,
    ["anyone"] = 90, ["someone"] = 88, ["something"] = 86,
    ["dungeon"] = 160, ["dungeons"] = 150, ["veteran"] = 146, ["normal"] = 138,
    ["group"] = 138, ["damage"] = 136, ["healer"] = 152, ["tank"] = 152,
    ["build"] = 130, ["skill"] = 128, ["skills"] = 126, ["boss"] = 126,
    ["nightblade"] = 160, ["werewolf"] = 154, ["scribing"] = 150, ["hello"] = 140, ["sorry"] = 120,
}

local COMMON_CORRECTIONS = {
    ["teh"] = { "the" }, ["thsi"] = { "this" }, ["taht"] = { "that" },
    ["recieve"] = { "receive" }, ["recieved"] = { "received" }, ["recieving"] = { "receiving" },
    ["definately"] = { "definitely" }, ["definetly"] = { "definitely" },
    ["seperate"] = { "separate" }, ["wierd"] = { "weird" },
    ["becuase"] = { "because" }, ["becasue"] = { "because" }, ["beacuse"] = { "because" },
    ["adress"] = { "address" }, ["addres"] = { "address" },
    ["occured"] = { "occurred" }, ["untill"] = { "until" }, ["wich"] = { "which" },
    ["freind"] = { "friend" }, ["freinds"] = { "friends" },
    ["acheive"] = { "achieve" }, ["acheived"] = { "achieved" },
    ["tommorow"] = { "tomorrow" }, ["tomorow"] = { "tomorrow" },
    ["goverment"] = { "government" }, ["enviroment"] = { "environment" },
    ["neccessary"] = { "necessary" }, ["necesary"] = { "necessary" },
    ["begining"] = { "beginning" }, ["beleive"] = { "believe" }, ["beleived"] = { "believed" },
    ["probaly"] = { "probably" }, ["probabaly"] = { "probably" },
    ["mesage"] = { "message" }, ["sugestion"] = { "suggestion" },
    ["corretion"] = { "correction" }, ["langauge"] = { "language" },
    ["alot"] = { "a lot" }, ["atleast"] = { "at least" }, ["aswell"] = { "as well" },
    ["inthe"] = { "in the" }, ["onthe"] = { "on the" }, ["tothe"] = { "to the" },
    ["dont"] = { "don't" }, ["doesnt"] = { "doesn't" }, ["didnt"] = { "didn't" },
    ["isnt"] = { "isn't" }, ["arent"] = { "aren't" }, ["wasnt"] = { "wasn't" },
    ["werent"] = { "weren't" }, ["havent"] = { "haven't" }, ["hasnt"] = { "hasn't" },
    ["hadnt"] = { "hadn't" }, ["couldnt"] = { "couldn't" }, ["shouldnt"] = { "shouldn't" },
    ["wouldnt"] = { "wouldn't" }, ["youre"] = { "you're" }, ["theyre"] = { "they're" },
    ["weve"] = { "we've" }, ["youve"] = { "you've" }, ["theyve"] = { "they've" },
    ["thats"] = { "that's" }, ["theres"] = { "there's" }, ["whats"] = { "what's" },
}

local QWERTY_NEIGHBORS = {
    q="wa", w="qase", e="wsdr", r="edft", t="rfgy", y="tghu", u="yhji", i="ujko", o="iklp", p="ol",
    a="qwsz", s="awedxz", d="serfcx", f="drtgvc", g="ftyhbv", h="gyujnb", j="huikmn", k="jiolm", l="kop",
    z="asx", x="zsdc", c="xdfv", v="cfgb", b="vghn", n="bhjm", m="njk",
}

local function Normalize(word)
    if not word then return "" end
    word = word:gsub("’", "'"):gsub("‘", "'")
    word = string.lower(word)
    word = word:gsub("^[-']+", ""):gsub("[-']+$", "")
    return word
end
function FSC:NormalizeWord(word) return Normalize(word) end

local function NormalizeCorrection(word)
    if not word then return "" end
    word = string.lower(word:gsub("’", "'"):gsub("‘", "'"))
    word = word:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
    return word
end

local function IsAsciiWord(word)
    return word ~= "" and word:match("^[a-z][a-z'%-]*$") ~= nil
end

-- Lua string patterns operate on UTF-8 bytes. Build a same-byte-length shadow for
-- token scanning so typographic apostrophes behave like ordinary apostrophes while
-- every returned byte index still maps exactly to ESO's original EditBox text.
function FSC:BuildWordScanShadow(text)
    text = tostring(text or "")
    return (text:gsub("’", "'''"):gsub("‘", "'''"))
end

function FSC:IsKnownNormalized(word)
    if not word or word == "" then return true end
    if #word <= 1 then return true end
    if self.sessionIgnored and self.sessionIgnored[word] then return true end
    if self.saved and self.saved.userWords and self.saved.userWords[word] then return true end
    if self:IsKnownByEnabledDictionary(word) then return true end

    if #word > 2 and word:sub(-2) == "'s" then
        local root = word:sub(1, -3)
        if self:IsKnownNormalized(root) then return true end
    end

    if word:find("-", 1, true) then
        local foundPart = false
        for part in word:gmatch("[^%-]+") do
            foundPart = true
            if not self:IsKnownNormalized(part) then return false end
        end
        if foundPart then return true end
    end
    return false
end

function FSC:IsKnown(word) return self:IsKnownNormalized(Normalize(word)) end

local function GetChunkBounds(text, startIndex, endIndex)
    local left = startIndex
    while left > 1 and not text:sub(left - 1, left - 1):match("%s") do left = left - 1 end
    local right = endIndex
    while right < #text and not text:sub(right + 1, right + 1):match("%s") do right = right + 1 end
    return left, right
end

local function IsAsciiFragmentAdjacentToNonAscii(text, startIndex, endIndex)
    local beforeByte = startIndex > 1 and text:byte(startIndex - 1) or nil
    local afterByte = endIndex < #text and text:byte(endIndex + 1) or nil
    return (beforeByte and beforeByte >= 128) or (afterByte and afterByte >= 128) or false
end

function FSC:ShouldSkipToken(text, startIndex, endIndex, rawWord)
    if not rawWord or #rawWord <= 1 then return true end

    -- The spelling engine intentionally targets ASCII English words. Lua's byte-based
    -- pattern matching can otherwise split an accented UTF-8 word (for example,
    -- "café") into an ASCII fragment ("caf") and underline/learn that fragment.
    -- If either byte directly touching this ASCII token is non-ASCII, leave the whole
    -- mixed-language token alone rather than pretending the fragment is English.
    if IsAsciiFragmentAdjacentToNonAscii(text, startIndex, endIndex) then return true end

    local before = startIndex > 1 and text:sub(startIndex - 1, startIndex - 1) or ""
    if before == "@" then return true end
    if before == "/" and startIndex <= 2 then return true end

    local chunkStart, chunkEnd = GetChunkBounds(text, startIndex, endIndex)
    local chunk = text:sub(chunkStart, chunkEnd)
    local lowerChunk = string.lower(chunk)
    if chunk:find("|", 1, true) then return true end
    if lowerChunk:find("://", 1, true) then return true end
    if lowerChunk:find("www.", 1, true) then return true end
    if lowerChunk:find("discord.gg", 1, true) then return true end
    if lowerChunk:find("@", 1, true) and chunkStart == startIndex then return true end
    return false
end

function FSC:FindMisspellings(text)
    local results = {}
    if not text or text == "" then return results end
    local scanText = self:BuildWordScanShadow(text)
    local searchFrom = 1
    while true do
        local s, e = scanText:find("[A-Za-z][A-Za-z'%-]*", searchFrom)
        if not s then break end
        local rawWord = text:sub(s, e)
        local normalized = Normalize(rawWord)
        if not self:ShouldSkipToken(text, s, e, rawWord)
            and IsAsciiWord(normalized)
            and not self:IsKnownNormalized(normalized) then
            results[#results + 1] = { startIndex=s, endIndex=e, raw=rawWord, normalized=normalized }
        end
        searchFrom = e + 1
    end
    return results
end

local function IsWordChar(char)
    return char ~= "" and char:match("[A-Za-z'%-]") ~= nil
end

local function FindWordBefore(text, beforeIndex, scanText)
    scanText = scanText or FSC:BuildWordScanShadow(text)
    local i = math.min(#text, math.max(0, beforeIndex or #text))
    while i > 0 do
        while i > 0 and not IsWordChar(scanText:sub(i, i)) do i = i - 1 end
        if i <= 0 then return nil, 0 end
        local finish = i
        while i > 0 and IsWordChar(scanText:sub(i, i)) do i = i - 1 end
        local startIndex = i + 1
        if not IsAsciiFragmentAdjacentToNonAscii(text, startIndex, finish) then
            local word = Normalize(text:sub(startIndex, finish))
            if word ~= "" then return word, i end
        end
    end
    return nil, 0
end

local function FindWordAfter(text, afterIndex, scanText)
    scanText = scanText or FSC:BuildWordScanShadow(text)
    local i = math.max(1, (afterIndex or 0) + 1)
    while i <= #text do
        while i <= #text and not IsWordChar(scanText:sub(i, i)) do i = i + 1 end
        if i > #text then return nil end
        local startIndex = i
        while i <= #text and IsWordChar(scanText:sub(i, i)) do i = i + 1 end
        local finish = i - 1
        if not IsAsciiFragmentAdjacentToNonAscii(text, startIndex, finish) then
            local word = Normalize(text:sub(startIndex, finish))
            if word ~= "" then return word end
        end
    end
    return nil
end

function FSC:GetCorrectionContext(text, startIndex, endIndex)
    text = text or ""
    local scanText = self:BuildWordScanShadow(text)
    local previousWord, beforePrevious = FindWordBefore(text, (startIndex or 1) - 1, scanText)
    local previousPreviousWord = nil
    if previousWord then previousPreviousWord = select(1, FindWordBefore(text, beforePrevious, scanText)) end
    return {
        text = text,
        startIndex = startIndex,
        endIndex = endIndex,
        cursor = startIndex,
        previousPreviousWord = previousPreviousWord,
        previousWord = previousWord,
        nextWord = FindWordAfter(text, endIndex or startIndex or 0, scanText),
    }
end

local function IsKeyboardNeighbor(a, b)
    local neighbors = QWERTY_NEIGHBORS[a]
    return neighbors and neighbors:find(b, 1, true) ~= nil
end

local function InsertCost(char)
    if char == "'" or char == " " then return 35 end
    return 100
end

local function DeleteCost(word, index)
    local char = word:sub(index, index)
    if char == "'" or char == " " then return 35 end
    local before = index > 1 and word:sub(index - 1, index - 1) or ""
    local after = index < #word and word:sub(index + 1, index + 1) or ""
    if char == before or char == after then return 55 end
    return 100
end

local function SubstituteCost(a, b)
    if a == b then return 0 end
    if IsKeyboardNeighbor(a, b) then return 58 end
    return 100
end

local function WeightedDamerauLevenshtein(a, b, maximum)
    local lenA, lenB = #a, #b
    if math.abs(lenA - lenB) * 35 > maximum then return maximum + 1 end
    if a == b then return 0 end

    local prevPrev, prev, curr = nil, {}, {}
    prev[0] = 0
    for j = 1, lenB do prev[j] = prev[j - 1] + InsertCost(b:sub(j, j)) end

    for i = 1, lenA do
        curr[0] = prev[0] + DeleteCost(a, i)
        local rowMin = curr[0]
        local ca = a:sub(i, i)
        for j = 1, lenB do
            local cb = b:sub(j, j)
            local deletion = prev[j] + DeleteCost(a, i)
            local insertion = curr[j - 1] + InsertCost(cb)
            local substitution = prev[j - 1] + SubstituteCost(ca, cb)
            local value = math.min(deletion, insertion, substitution)
            if i > 1 and j > 1 and prevPrev
                and ca == b:sub(j - 1, j - 1)
                and a:sub(i - 1, i - 1) == cb then
                value = math.min(value, prevPrev[j - 2] + 52)
            end
            curr[j] = value
            if value < rowMin then rowMin = value end
        end
        if rowMin > maximum + 100 then return maximum + 1 end
        prevPrev, prev, curr = prev, curr, prevPrev or {}
    end
    return prev[lenB]
end

local function EnsureCorrectionLearning(self)
    if not self.saved then return nil end
    self.saved.correctionLearning = self.saved.correctionLearning or { pairs={}, acceptances=0 }
    local store = self.saved.correctionLearning
    store.pairs = store.pairs or {}
    store.acceptances = store.acceptances or 0
    return store
end

local function TableSize(map)
    local count = 0
    for _ in pairs(map or {}) do count = count + 1 end
    return count
end

local function PruneCorrectionLearning(store)
    if not store or TableSize(store.pairs) <= MAX_PERSONAL_CORRECTION_WORDS then return end
    local ranked = {}
    for typo, choices in pairs(store.pairs) do
        local total = 0
        for _, count in pairs(choices) do total = total + count end
        ranked[#ranked + 1] = { typo=typo, total=total }
    end
    table.sort(ranked, function(a,b)
        if a.total == b.total then return a.typo < b.typo end
        return a.total > b.total
    end)
    local keep = {}
    for i=1, math.min(600, #ranked) do keep[ranked[i].typo] = true end
    for typo in pairs(store.pairs) do if not keep[typo] then store.pairs[typo] = nil end end
end

local function LearnedCorrectionCount(self, typo, candidate)
    if not self:IsCorrectionLearningEnabled() then return 0 end
    local store = self.saved and self.saved.correctionLearning
    local bucket = store and store.pairs and store.pairs[typo]
    return bucket and (bucket[candidate] or 0) or 0
end

function FSC:RecordCorrectionAcceptance(typo, replacement, context)
    typo = Normalize(typo)
    replacement = NormalizeCorrection(replacement)
    if typo == "" or replacement == "" then return end

    local learnCorrections = self:IsCorrectionLearningEnabled()
    if learnCorrections then
        local store = EnsureCorrectionLearning(self)
        if store then
            local bucket = store.pairs[typo]
            if not bucket then bucket = {}; store.pairs[typo] = bucket end
            bucket[replacement] = math.min(255, (bucket[replacement] or 0) + 1)

            if TableSize(bucket) > MAX_PERSONAL_CORRECTION_BUCKET then
                local ranked = {}
                for word,count in pairs(bucket) do ranked[#ranked+1] = {word=word,count=count} end
                table.sort(ranked,function(a,b)
                    if a.count == b.count then return a.word < b.word end
                    return a.count > b.count
                end)
                local keep = {}
                for i=1, math.min(4,#ranked) do keep[ranked[i].word]=ranked[i].count end
                for word in pairs(bucket) do bucket[word]=nil end
                for word,count in pairs(keep) do bucket[word]=count end
            end

            store.acceptances = (store.acceptances or 0) + 1
            if store.acceptances % 40 == 0 then PruneCorrectionLearning(store) end
            self:InvalidateAutocompleteCaches()
        end
    end

    -- Accepted corrections are also a high-confidence autocomplete signal when
    -- personalization is enabled.
    if not replacement:find(" ",1,true) then
        self:RecordAutocompleteAcceptance(
            context and context.previousWord or nil,
            replacement,
            context and context.previousPreviousWord or nil,
            context and context.previousThirdWord or nil
        )
    end
end

local function FrequencyScore(self, word)
    if word:find(" ",1,true) then return 0 end
    return self:GetDictionaryFrequencyScore(word)
end

local function CandidateContextScore(self, context, candidate)
    if not context then return 0 end
    if candidate:find(" ",1,true) then
        local first = candidate:match("^([^ ]+)")
        local last = candidate:match("([^ ]+)$")
        local score = self:GetLanguageContextScore(context.previousPreviousWord, context.previousWord, first, nil)
        if context.nextWord and last then
            score = score + math.floor(self:GetLanguageContextScore(nil, last, context.nextWord, nil) * 0.45)
        end
        return score
    end
    return self:GetLanguageContextScore(
        context.previousPreviousWord,
        context.previousWord,
        candidate,
        context.nextWord
    )
end

local function AddCandidate(self, candidateMap, word, typo, sourceBonus, source, context, forcedCost)
    if not word or word == "" then return false end
    word = NormalizeCorrection(word)
    if word == "" or word == typo then return false end
    if self.IsSuggestionSafe and not self:IsSuggestionSafe(word, context, source) then return false end
    local cost = forcedCost or WeightedDamerauLevenshtein(typo, word, MAX_CORRECTION_COST)
    if cost > MAX_CORRECTION_COST then return false end

    local frequency = FrequencyScore(self, word)
    local learned = LearnedCorrectionCount(self, typo, word)
    local contextScore = CandidateContextScore(self, context, word)
    local score = 3000 - (cost * 10) + (frequency * 0.68) + (sourceBonus or 0)
    score = score + (COMMON_PRIORITY[word] or 0)
    score = score + math.min(2400, learned * 760)
    score = score + contextScore

    local existing = candidateMap[word]
    if not existing or score > existing.score then
        candidateMap[word] = {
            word=word, score=score, cost=cost, frequency=frequency,
            source=source or "dictionary", learned=learned,
        }
        return true
    end
    return false
end

local function AddLearnedCandidates(self, typo, candidateMap, context)
    if not self:IsCorrectionLearningEnabled() then return end
    local store = self.saved and self.saved.correctionLearning
    local bucket = store and store.pairs and store.pairs[typo]
    if not bucket then return end
    for word in pairs(bucket) do
        AddCandidate(self, candidateMap, word, typo, 1000, "learned", context, nil)
    end
end

local function AddEditDistanceOneCandidates(self, typo, candidateMap, context)
    local len = #typo
    for i = 1, len do
        local candidate = typo:sub(1, i - 1) .. typo:sub(i + 1)
        if self:IsKnownNormalized(candidate) then AddCandidate(self,candidateMap,candidate,typo,100,"edit1",context) end
    end
    for i = 1, len - 1 do
        local swapped = typo:sub(1,i-1)..typo:sub(i+1,i+1)..typo:sub(i,i)..typo:sub(i+2)
        if self:IsKnownNormalized(swapped) then AddCandidate(self,candidateMap,swapped,typo,130,"transpose",context) end
    end
    for i = 1, len do
        local left, right = typo:sub(1,i-1), typo:sub(i+1)
        for byte = LOWER_A, LOWER_Z do
            local candidate = left .. string.char(byte) .. right
            if self:IsKnownNormalized(candidate) then AddCandidate(self,candidateMap,candidate,typo,70,"edit1",context) end
        end
    end
    for i = 0, len do
        local left, right = typo:sub(1,i), typo:sub(i+1)
        for byte = LOWER_A, LOWER_Z do
            local candidate = left .. string.char(byte) .. right
            if self:IsKnownNormalized(candidate) then AddCandidate(self,candidateMap,candidate,typo,70,"edit1",context) end
        end
    end
end

local function GenerateDeletes(term, maximumDistance)
    local seen, ordered = {[term]=true}, {term}
    local frontier = {term}
    for _ = 1, maximumDistance do
        local nextFrontier = {}
        for _, value in ipairs(frontier) do
            for i = 1, #value do
                local deleted = value:sub(1,i-1) .. value:sub(i+1)
                if not seen[deleted] then
                    seen[deleted] = true
                    ordered[#ordered+1] = deleted
                    nextFrontier[#nextFrontier+1] = deleted
                end
            end
        end
        frontier = nextFrontier
    end
    return ordered
end

local function AddDeleteIndexCandidates(self, typo, candidateMap, context)
    if not self:IsDictionaryEnabled("english") then return end
    if not DeleteIndex or not DeleteIndex.Lookup or #typo < 3 then return end
    local prefixLength = math.min(DeleteIndex.maxPrefixLength or 5, #typo)
    local prefix = typo:sub(1,prefixLength)
    local signatures = GenerateDeletes(prefix, 2)
    local found, ordered = {}, {}
    for _, signature in ipairs(signatures) do
        DeleteIndex.Lookup(signature, found, ordered)
        if #ordered >= MAX_DELETE_CANDIDATES then break end
    end
    local inspected = 0
    for _, word in ipairs(ordered) do
        inspected = inspected + 1
        AddCandidate(self,candidateMap,word,typo,40,"delete-index",context)
        if inspected >= MAX_DELETE_CANDIDATES then break end
    end
end

local function AddEnglishPrefixFallback(self, typo, candidateMap, context)
    if not self:IsDictionaryEnabled("english") then return end
    if not English.buckets or #typo < 3 then return end
    local key = typo:sub(1,3)
    if not key:match("^[a-z][a-z][a-z]$") then return end
    local blob = English.buckets[key]
    if not blob then return end
    local inspected = 0
    for suffix in blob:gmatch("[^\n]+") do
        inspected = inspected + 1
        AddCandidate(self,candidateMap,key..suffix,typo,-30,"prefix-fallback",context)
        if inspected >= 240 then break end
    end
end

local function AddChatCandidates(self, typo, candidateMap, context)
    if not self:IsDictionaryEnabled("english") then return end
    if not Chat.tokens then return end
    for word in pairs(Chat.tokens) do AddCandidate(self,candidateMap,word,typo,220,"chat",context) end
end

local function EnsureESOSuggestionTokens(esoOnly)
    local cacheKey = esoOnly and "spellcheckSuggestionTokensESOOnly" or "spellcheckSuggestionTokens"
    local signatureKey = cacheKey .. "Signature"
    local signature = FSC:GetDictionaryStateSignature()
    if ESO[cacheKey] and ESO[signatureKey] == signature then return ESO[cacheKey] end
    local tokens = {}
    ESO.ForEachEnabledStaticToken(function(word) tokens[word]=true end)
    if not esoOnly then
        ESO.ForEachEnabledStaticPhrase(function(phrase)
            for token in phrase:gmatch("[A-Za-z][A-Za-z'%-]*") do
                local normalized=Normalize(token)
                if normalized~="" then tokens[normalized]=true end
            end
        end)
    end
    ESO[cacheKey]=tokens
    ESO[signatureKey]=signature
    return tokens
end

local function EnsureESOStaticCorrectionLengthIndex(esoOnly)
    local cacheKey = esoOnly and "staticCorrectionLengthIndexESOOnly" or "staticCorrectionLengthIndex"
    local signatureKey = cacheKey .. "Signature"
    local signature = FSC:GetDictionaryStateSignature()
    if ESO[cacheKey] and ESO[signatureKey] == signature then return ESO[cacheKey] end

    local index = {}
    for word in pairs(EnsureESOSuggestionTokens(esoOnly) or {}) do
        local length = #word
        local bucket = index[length]
        if not bucket then bucket = {}; index[length] = bucket end
        bucket[#bucket + 1] = word
    end
    ESO[cacheKey] = index
    ESO[signatureKey] = signature
    return index
end

local function GetESORuntimeCorrectionIndexes()
    -- RuntimeESOCollector maintains these incrementally as client vocabulary is
    -- learned, keeping setup work completely off the right-click interaction path.
    return ESO.runtimeCorrectionAllLengthIndex or {}, ESO.runtimeCorrectionEdgeIndex or {}
end

local function HasLikelyCorrectionAlignment(typo, word)
    local lt, lw = #typo, #word
    if lt <= 4 or lw <= 4 then return true end
    if typo:sub(1,1) == word:sub(1,1) or typo:sub(-1) == word:sub(-1) then return true end
    if typo:sub(2,2) == word:sub(2,2) or typo:sub(-2,-2) == word:sub(-2,-2) then return true end

    -- Preserve two-edit cases where one character is missing/inserted at each edge
    -- ("ightblad" -> "nightblade") without opening the expensive full scan.
    local typoFirst2, wordFirst2 = typo:sub(1,2), word:sub(1,2)
    if word:sub(1,3):find(typoFirst2,1,true) or typo:sub(1,3):find(wordFirst2,1,true) then return true end
    local typoLast2, wordLast2 = typo:sub(-2), word:sub(-2)
    if word:sub(-3):find(typoLast2,1,true) or typo:sub(-3):find(wordLast2,1,true) then return true end
    return false
end

local function AddESOCandidates(self, typo, candidateMap, context)
    if not self:IsDictionaryEnabled("eso") then return end
    if not ESO then return end

    local esoCandidatesAdded = 0
    local function TryWord(word, sourceBonus, source, alignedOnly)
        if alignedOnly and not HasLikelyCorrectionAlignment(typo, word) then return end
        if AddCandidate(self,candidateMap,word,typo,sourceBonus,source,context) then
            esoCandidatesAdded = esoCandidatesAdded + 1
        end
    end

    -- Static ESO vocabulary is small, but length indexing still avoids needless
    -- scoring work and keeps this path consistent with runtime vocabulary.
    local staticByLength = EnsureESOStaticCorrectionLengthIndex(not IsPackEnabled(self,"english"))
    local minStaticLength = math.max(1, #typo - 3)
    local maxStaticLength = #typo + 3
    for length = minStaticLength, maxStaticLength do
        for _, word in ipairs(staticByLength[length] or {}) do
            TryWord(word,430,"eso",true)
        end
    end

    -- Runtime names can number in the thousands. They are indexed by first/last
    -- character while being collected, so the normal correction path touches only a
    -- small union of likely words instead of scanning every token of nearby lengths.
    local runtimeByLength, runtimeByEdge = GetESORuntimeCorrectionIndexes()
    local runtimeSeen = {}
    local firstChar, lastChar = typo:sub(1,1), typo:sub(-1)
    local minLength = math.max(1, #typo - 3)
    local maxLength = #typo + 3
    for length = minLength, maxLength do
        local edge = runtimeByEdge[length]
        if edge then
            local function Visit(bucket)
                for _, word in ipairs(bucket or {}) do
                    if not runtimeSeen[word] then
                        runtimeSeen[word] = true
                        if not ESO.IsRuntimeTokenEnabled or ESO.IsRuntimeTokenEnabled(word) then
                            TryWord(word,380,"eso-runtime",false)
                        end
                    end
                end
            end
            Visit(edge.first and edge.first[firstChar])
            Visit(edge.last and edge.last[lastChar])
        end
    end

    -- Two simultaneous endpoint errors are unusual but valid. If the fast ESO pass
    -- found nothing and no other correction source has anything either, preserve the
    -- old exhaustive behavior as a quality fallback.
    if esoCandidatesAdded == 0 and TableSize(candidateMap) == 0 then
        for length = minStaticLength, maxStaticLength do
            for _, word in ipairs(staticByLength[length] or {}) do
                if not HasLikelyCorrectionAlignment(typo, word) then
                    TryWord(word,430,"eso",false)
                end
            end
        end
        for length = minLength, maxLength do
            for word in pairs(runtimeByLength[length] or {}) do
                if not runtimeSeen[word]
                    and (not ESO.IsRuntimeTokenEnabled or ESO.IsRuntimeTokenEnabled(word)) then
                    TryWord(word,380,"eso-runtime",false)
                end
            end
        end
    end
end

local function AddUserAndPersonalCandidates(self, typo, candidateMap, context)
    if self.saved and self.saved.userWords then
        for word in pairs(self.saved.userWords) do AddCandidate(self,candidateMap,word,typo,460,"user",context) end
    end
    local unigrams = self:IsPersonalizationEnabled() and self.saved and self.saved.autocomplete and self.saved.autocomplete.unigrams
    if unigrams then
        for word,count in pairs(unigrams) do
            if count >= 2 and math.abs(#word-#typo) <= 3 then
                AddCandidate(self,candidateMap,word,typo,math.min(360,count*28),"personal",context)
            end
        end
    end
end

local function AddSplitCandidates(self, typo, candidateMap, context)
    if #typo < 4 or #typo > 24 then return end
    local function SplitPartIsUseful(part)
        if part == "a" or part == "i" then return true end
        local frequency = self:GetDictionaryFrequencyScore(part)
        if frequency >= 180 then return true end
        if self:IsDictionaryEnabled("english")
            and Chat.tokens and Chat.tokens[part] then return true end
        return false
    end
    for split = 1, #typo-1 do
        local left,right=typo:sub(1,split),typo:sub(split+1)
        if self:IsKnownNormalized(left) and self:IsKnownNormalized(right)
            and SplitPartIsUseful(left) and SplitPartIsUseful(right) then
            AddCandidate(self,candidateMap,left.." "..right,typo,80,"split",context,90)
        end
    end
end

local function AddRegisteredDictionaryCorrectionCandidates(self, typo, candidateMap, context)
    self:EnumerateRegisteredCorrectionCandidates(typo, context, function(word, sourceBonus, source, forcedCost)
        AddCandidate(self, candidateMap, word, typo, sourceBonus or 0, source or "dictionary-pack", context, forcedCost)
    end)
end

function FSC:GetSuggestions(word, limit, context)
    limit = limit or 5
    local typo = Normalize(word)
    if typo == "" then return {} end
    context = context or {}

    self.suggestionCache = self.suggestionCache or {}
    local dictionarySignature = self:GetDictionaryStateSignature()
    local cacheKey = table.concat({typo, context.previousPreviousWord or "", context.previousWord or "", context.nextWord or "", context.text or "", tostring(context.startIndex or ""), tostring(context.endIndex or ""), dictionarySignature}, "\31")
    local cached = self.suggestionCache[cacheKey]
    if cached then
        local copy={}
        for i=1,math.min(limit,#cached) do copy[i]=cached[i] end
        return copy
    end

    local candidateMap={}
    local englishEnabled = self:IsDictionaryEnabled("english")
    local forced=englishEnabled and COMMON_CORRECTIONS[typo] or nil
    if forced then
        for index,candidate in ipairs(forced) do
            AddCandidate(self,candidateMap,candidate,typo,1500-(index*20),"common",context,45+(index-1)*10)
        end
    end

    AddLearnedCandidates(self,typo,candidateMap,context)
    AddEditDistanceOneCandidates(self,typo,candidateMap,context)
    AddDeleteIndexCandidates(self,typo,candidateMap,context)
    AddChatCandidates(self,typo,candidateMap,context)
    AddESOCandidates(self,typo,candidateMap,context)
    AddUserAndPersonalCandidates(self,typo,candidateMap,context)
    AddSplitCandidates(self,typo,candidateMap,context)
    AddRegisteredDictionaryCorrectionCandidates(self,typo,candidateMap,context)

    -- Rare-word fallback. It is deliberately on-demand only and capped; the live
    -- autocomplete path never walks this SCOWL bucket.
    if TableSize(candidateMap) < 10 then AddEnglishPrefixFallback(self,typo,candidateMap,context) end

    local ranked={}
    for _,data in pairs(candidateMap) do ranked[#ranked+1]=data end
    table.sort(ranked,function(a,b)
        if a.score == b.score then
            if a.cost == b.cost then
                if a.frequency == b.frequency then return a.word < b.word end
                return a.frequency > b.frequency
            end
            return a.cost < b.cost
        end
        return a.score > b.score
    end)

    local results={}
    for i=1,math.min(10,#ranked) do results[i]=ranked[i].word end

    -- Correction contexts include the surrounding line, so an unbounded cache would
    -- slowly retain every distinct typo/context pair seen during a long play session.
    -- Keep the useful short-term cache, but reset it before it can become a quiet
    -- session-memory leak.
    local cacheCount = self.suggestionCacheCount or 0
    if self.suggestionCache[cacheKey] == nil then
        cacheCount = cacheCount + 1
        if cacheCount > MAX_CORRECTION_SUGGESTION_CACHE then
            self.suggestionCache = {}
            cacheCount = 1
        end
    end
    self.suggestionCacheCount = cacheCount
    self.suggestionCache[cacheKey]=results
    local copy={}
    for i=1,math.min(limit,#results) do copy[i]=results[i] end
    return copy
end

function FSC:ApplyCase(original, replacement)
    if not original or original == "" then return replacement end
    if replacement:find(" ",1,true) then
        if original == string.upper(original) then return string.upper(replacement) end
        if original:sub(1,1) == string.upper(original:sub(1,1)) then
            return string.upper(replacement:sub(1,1)) .. replacement:sub(2)
        end
        return replacement
    end
    if original == string.upper(original) then return string.upper(replacement) end
    if original:sub(1,1) == string.upper(original:sub(1,1)) then
        return string.upper(replacement:sub(1,1)) .. replacement:sub(2)
    end
    return replacement
end

return FSC

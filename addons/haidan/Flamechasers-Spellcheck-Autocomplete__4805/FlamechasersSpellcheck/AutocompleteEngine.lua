local FSC = FlamechasersSpellcheck

local English = FSC.English
local Frequency = FSC.Frequency
local DeleteIndex = FSC.CorrectionDeletes
local ESO = FSC.ESO
local Chat = FSC.Chat

local AUTOCOMPLETE_LIMIT = 3
local MAX_PERSONAL_UNIGRAMS = 3000
local PRUNED_PERSONAL_UNIGRAMS = 2400
local MAX_PERSONAL_NEXT_WORDS = 24
local KEEP_PERSONAL_NEXT_WORDS = 16
local MAX_PERSONAL_TRIGRAM_CONTEXTS = 1800
local KEEP_PERSONAL_TRIGRAM_CONTEXTS = 1400
local MAX_PERSONAL_FOURGRAM_CONTEXTS = 1200
local KEEP_PERSONAL_FOURGRAM_CONTEXTS = 900
local SUPER_SESSION_MAX_WORDS = 900
local SUPER_SESSION_MAX_CONTEXTS = 1400
local SUPER_SESSION_MAX_AGE = 900

-- Small cold-start language model. This is intentionally chat-shaped rather than
-- literary: it gives useful first-use ranking while the bounded personal model
-- learns the player's actual ESO vocabulary and phrasing.
local GENERAL_CONTEXT_PHRASES = {
    "thank you", "thanks for", "good luck", "good game", "good morning", "good night",
    "looking for", "look for", "looking for a tank", "looking for a healer", "looking for tank", "looking for healer", "looking for one more",
    "need a", "need to", "need help", "need more", "need some", "need a tank", "need a healer", "need tank", "need healer", "need one tank", "need one healer", "need one dps",
    "need one more", "want a", "want to", "want more", "want some", "have a", "have to",
    "going to", "going to be", "going to bed", "trying to", "able to", "can you", "can we", "could you", "would you",
    "do you", "do you want to", "did you", "are you", "are you going to", "were you", "will you",
    "i am", "i have", "i think", "i need", "i want", "i can", "i will", "i don't",
    "i don't know", "i don't think", "i don't want", "i dont know", "i dont think", "we are", "we have", "we need", "we can",
    "we should", "you are", "you can", "you have", "you need", "you want",
    "anyone know", "anyone want", "anyone need", "anyone have", "let me", "let me know", "let me keep", "let me check", "let me see", "let's go",
    "a lot", "a little", "a bit", "one more", "for the", "in the", "on the", "at the", "with the",
    "from the", "to the", "of the", "this is", "that is", "there is", "there are", "it is", "it was",
    "it looks", "it feels", "pretty good", "really good", "so much", "too much", "more than", "less than",
    "right now", "right there", "hard mode", "normal mode", "veteran mode", "group finder", "damage dealer",
    "craft bag", "crown store", "champion points", "monster set", "outfit station", "transmute station",
    "eso plus", "black gem foundry", "ossein cage", "infinite archive", "scrivener's hall",
    "good luck have fun", "thanks for the group", "thanks for group", "ready when you are",
}

-- Super mode uses a separate cold-start model so Standard mode keeps its exact
-- existing behavior. These phrases are deliberately compact, conversational, and MMO-shaped.
-- They are not a neural model; they simply give the higher-order/backoff scorer useful priors
-- until the player's own local model has enough history.
local SUPER_CONTEXT_PHRASES = {
    "i think we should", "i think we can", "i think we need", "i think it is", "i think it's",
    "i don't think so", "i don't think we", "i don't know if", "i don't know why", "i don't know what",
    "i don't want to", "i don't need to", "i just want to", "i just need to", "i just got",
    "i was going to", "i was trying to", "i was about to", "i have to go", "i have no idea",
    "i can do that", "i can help with", "i can run it", "i can tank it", "i can heal it",
    "we should probably", "we should be able", "we can do", "we can run", "we can try",
    "we need one more", "we need a tank", "we need a healer", "we need more dps", "we are ready",
    "do you want to", "do you guys want", "do we want to", "did you get", "did you see",
    "are you still", "are you guys", "are we doing", "are we gonna", "are we ready",
    "can you help", "can you invite", "can you queue", "can you share", "can we run",
    "could you please", "would you like to", "would you mind", "want to run", "wanna run",
    "let me know if", "let me check", "let me see", "let me try", "let me swap",
    "give me a second", "give me a minute", "one more time", "one more run", "one more person",
    "be right back", "on my way", "ready when you are", "whenever you are ready", "good to go",
    "that makes sense", "that sounds good", "that should work", "that would be", "that is fine",
    "this should be", "this is probably", "it should be", "it would be", "it might be",
    "it looks like", "it feels like", "it seems like", "there should be", "there is a",
    "thanks for the group", "thanks for group", "thank you for", "good luck everyone", "good game guys",
    "anyone want to", "anyone need", "anyone know if", "anyone up for", "anyone have a",
    "looking for one", "looking for a tank", "looking for a healer", "looking for more",
    "need one more", "need a tank", "need a healer", "need some help", "need help with",
    "queue for random", "queue for vet", "queue for normal", "run the pledge", "run some pledges",
    "run a dungeon", "run some dungeons", "do the hardmode", "do hard mode", "try hard mode",
    "last boss hardmode", "last boss hm", "first boss", "second boss", "final boss",
    "group finder queue", "random veteran dungeon", "random normal dungeon", "daily pledge",
    "swap to tank", "swap to healer", "swap to dps", "switch build", "switch setup",
    "need more sustain", "need more damage", "need more healing", "need more resistance",
    "out of stamina", "out of magicka", "low on stamina", "low on magicka", "almost dead",
    "drop your ult", "use your ult", "use the synergy", "take the synergy", "hold block",
    "block the heavy", "dodge the heavy", "interrupt the boss", "bash the boss", "stack on boss",
    "stay in group", "come to me", "come over here", "move to the", "go to the",
    "rez the tank", "rez the healer", "rez the dps", "i'll rez", "i can rez",
    "got the achievement", "got the trifecta", "got the lead", "got the drop", "got the set",
    "farm this dungeon", "farm the set", "farm some gear", "need the lead", "need the drop",
    "what build are", "what set are", "what skill are", "what class are", "what role are",
    "which one do", "which one is", "how much damage", "how much health", "how much resistance",
    "not sure if", "not sure why", "pretty sure it's", "pretty sure we", "probably gonna",
    "maybe we can", "maybe we should", "maybe try", "might as well", "should be fine",
    "works for me", "fine by me", "sounds good to me", "no problem", "all good",
    "yeah i think", "yeah we can", "yeah that's", "yep i can", "nope i don't",
    "sorry i was", "sorry about that", "my bad", "my mistake", "all my fault",
    "i'm still here", "i'm on my way", "i'm in combat", "i'm out of combat", "i'm ready",
    "i need to swap", "i need to change", "i need to grab", "i need to repair", "i need to sell",
    "give me lead", "pass me lead", "invite me please", "send me invite", "share the quest",
    "meet at the wayshrine", "at the wayshrine", "inside the dungeon", "outside the dungeon",
    "black gem foundry", "scrivener's hall", "infinite archive", "ossein cage", "hard mode boss",
}

local ESO_CONTEXT_PHRASE_CATEGORIES = {
    ["craft bag"]="systems", ["crown store"]="systems", ["champion points"]="systems",
    ["monster set"]="sets", ["outfit station"]="systems", ["transmute station"]="systems",
    ["eso plus"]="systems", ["black gem foundry"]="activities", ["ossein cage"]="activities",
    ["infinite archive"]="activities", ["scrivener's hall"]="activities",
    ["meet at the wayshrine"]="locations", ["at the wayshrine"]="locations",
    ["inside the dungeon"]="activities", ["outside the dungeon"]="activities",
}

local GENERIC_SEED_STOPWORDS = {
    ["a"]=true,["an"]=true,["and"]=true,["at"]=true,["for"]=true,["from"]=true,
    ["in"]=true,["of"]=true,["on"]=true,["the"]=true,["to"]=true,["with"]=true,
}

local ESO_DOMAIN_WORDS = {
    ["dungeon"]="activities",["dungeons"]="activities",["trial"]="activities",["trials"]="activities",["arena"]="activities",["arenas"]="activities",
    ["tank"]="combat",["tanking"]="combat",["healer"]="combat",["healing"]="combat",["damage"]="combat",["boss"]="activities",
    ["bosses"]="activities",["build"]="combat",["builds"]="combat",["skill"]="skills",["skills"]="skills",["group"]="activities",
    ["groups"]="activities",["veteran"]="activities",["normal"]="activities",["hardmode"]="activities",["hardmodes"]="activities",
    ["pledge"]="activities",["pledges"]="activities",["wayshrine"]="locations",["wayshrines"]="locations",["synergy"]="combat",
    ["synergies"]="combat",["taunt"]="combat",["taunts"]="combat",["parse"]="combat",["parsing"]="combat",
    ["werewolf"]="systems",["werewolves"]="systems",["vampire"]="systems",["mythic"]="sets",["mythics"]="sets",
    ["scribing"]="systems",["subclass"]="systems",["subclassing"]="systems",["nightblade"]="general",["templar"]="general",
    ["warden"]="general",["arcanist"]="general",["necromancer"]="general",["sorcerer"]="general",["dragonknight"]="general",
}

local function IsESOCategoryEnabled(id)
    return not ESO or not ESO.IsSubcategoryEnabled or ESO.IsSubcategoryEnabled(id)
end

local function IsWordChar(char) return char ~= "" and char:match("[A-Za-z'%-]") ~= nil end
local function StartsWith(word,prefix) return prefix=="" or word:sub(1,#prefix)==prefix end
local function TrigramKey(a,b) return (a or "") .. "\31" .. (b or "") end
local function FourgramKey(a,b,c) return (a or "") .. "\31" .. (b or "") .. "\31" .. (c or "") end

local function IsPackEnabled(self,id)
    return self:IsDictionaryEnabled(id)
end

local function CanUseColdStartPhrase(phrase)
    local subcategory=ESO_CONTEXT_PHRASE_CATEGORIES[phrase]
    if not subcategory then return true end
    return IsPackEnabled(FSC,"eso") and IsESOCategoryEnabled(subcategory)
end

local function BoundedDamerauLevenshtein(a,b,maximum)
    local lenA,lenB=#a,#b
    if math.abs(lenA-lenB)>maximum then return maximum+1 end
    if a==b then return 0 end
    local prevPrev,prev,curr=nil,{},{}
    for j=0,lenB do prev[j]=j end
    for i=1,lenA do
        curr[0]=i
        local rowMin=curr[0]
        local ca=a:sub(i,i)
        for j=1,lenB do
            local cb=b:sub(j,j)
            local cost=ca==cb and 0 or 1
            local value=math.min(prev[j]+1,curr[j-1]+1,prev[j-1]+cost)
            if i>1 and j>1 and prevPrev and ca==b:sub(j-1,j-1) and a:sub(i-1,i-1)==cb then
                value=math.min(value,prevPrev[j-2]+1)
            end
            curr[j]=value
            if value<rowMin then rowMin=value end
        end
        if rowMin>maximum then return maximum+1 end
        prevPrev,prev,curr=prev,curr,prevPrev or {}
    end
    return prev[lenB]
end

local function Increment(map,key,amount,maximum)
    if not map or not key or key=="" then return 0 end
    local value=(map[key] or 0)+(amount or 1)
    if maximum and value>maximum then value=maximum end
    map[key]=value
    return value
end

local function TableSize(map)
    local count=0
    for _ in pairs(map or {}) do count=count+1 end
    return count
end

local function EnsureAutocompleteStore(self)
    if not self.saved then return nil end
    self.saved.autocomplete=self.saved.autocomplete or {}
    local store=self.saved.autocomplete
    store.unigrams=store.unigrams or {}
    store.bigrams=store.bigrams or {}
    store.trigrams=store.trigrams or {}
    store.fourgrams=store.fourgrams or {}
    store.learnedMessages=store.learnedMessages or 0
    return store
end

function FSC:InvalidateAutocompleteCaches()
    self.suggestionCache = {}
    self.suggestionCacheCount = 0
    self.superPredictionCacheKey = nil
    self.superPredictionCacheResults = nil
end

local function PruneNextWords(nextWords)
    if TableSize(nextWords)<=MAX_PERSONAL_NEXT_WORDS then return end
    local ranked={}
    for word,count in pairs(nextWords) do ranked[#ranked+1]={word=word,count=count} end
    table.sort(ranked,function(a,b) if a.count==b.count then return a.word<b.word end return a.count>b.count end)
    local keep={}
    for i=1,math.min(KEEP_PERSONAL_NEXT_WORDS,#ranked) do keep[ranked[i].word]=ranked[i].count end
    for word in pairs(nextWords) do nextWords[word]=nil end
    for word,count in pairs(keep) do nextWords[word]=count end
end

local function AddBigram(store,previous,word,amount)
    if not previous or previous=="" or not word or word=="" then return end
    local nextWords=store.bigrams[previous]
    if not nextWords then nextWords={}; store.bigrams[previous]=nextWords end
    Increment(nextWords,word,amount or 1,255)
    PruneNextWords(nextWords)
end

local function AddTrigram(store,previousPrevious,previous,word,amount)
    if not previousPrevious or previousPrevious=="" or not previous or previous=="" or not word or word=="" then return end
    local key=TrigramKey(previousPrevious,previous)
    local nextWords=store.trigrams[key]
    if not nextWords then nextWords={}; store.trigrams[key]=nextWords end
    Increment(nextWords,word,amount or 1,255)
    PruneNextWords(nextWords)
end

local function AddFourgram(store,a,b,c,word,amount)
    if not a or a=="" or not b or b=="" or not c or c=="" or not word or word=="" then return end
    local key=FourgramKey(a,b,c)
    local nextWords=store.fourgrams[key]
    if not nextWords then nextWords={}; store.fourgrams[key]=nextWords end
    Increment(nextWords,word,amount or 1,255)
    PruneNextWords(nextWords)
end

local function PruneTrigramContexts(store)
    if TableSize(store.trigrams)<=MAX_PERSONAL_TRIGRAM_CONTEXTS then return end
    local ranked={}
    for key,nextWords in pairs(store.trigrams) do
        local total=0
        for _,count in pairs(nextWords) do total=total+count end
        ranked[#ranked+1]={key=key,total=total}
    end
    table.sort(ranked,function(a,b) if a.total==b.total then return a.key<b.key end return a.total>b.total end)
    local keep={}
    for i=1,math.min(KEEP_PERSONAL_TRIGRAM_CONTEXTS,#ranked) do keep[ranked[i].key]=true end
    for key in pairs(store.trigrams) do if not keep[key] then store.trigrams[key]=nil end end
end

local function PruneFourgramContexts(store)
    if TableSize(store.fourgrams)<=MAX_PERSONAL_FOURGRAM_CONTEXTS then return end
    local ranked={}
    for key,nextWords in pairs(store.fourgrams) do
        local total=0
        for _,count in pairs(nextWords) do total=total+count end
        ranked[#ranked+1]={key=key,total=total}
    end
    table.sort(ranked,function(a,b) if a.total==b.total then return a.key<b.key end return a.total>b.total end)
    local keep={}
    for i=1,math.min(KEEP_PERSONAL_FOURGRAM_CONTEXTS,#ranked) do keep[ranked[i].key]=true end
    for key in pairs(store.fourgrams) do if not keep[key] then store.fourgrams[key]=nil end end
end

local function PrunePersonalUnigrams(store)
    if TableSize(store.unigrams)<=MAX_PERSONAL_UNIGRAMS then return end
    local ranked={}
    for word,count in pairs(store.unigrams) do ranked[#ranked+1]={word=word,count=count} end
    table.sort(ranked,function(a,b) if a.count==b.count then return a.word<b.word end return a.count>b.count end)
    local keep={}
    for i=1,math.min(PRUNED_PERSONAL_UNIGRAMS,#ranked) do keep[ranked[i].word]=ranked[i].count end
    for word in pairs(store.unigrams) do store.unigrams[word]=nil end
    for word,count in pairs(keep) do store.unigrams[word]=count end
    for previous in pairs(store.bigrams) do if not keep[previous] then store.bigrams[previous]=nil end end
end

local function TokenizeLearnable(self,text)
    local tokens={}
    local scanText=self:BuildWordScanShadow(text)
    local searchFrom=1
    while true do
        local s,e=scanText:find("[A-Za-z][A-Za-z'%-]*",searchFrom)
        if not s then break end
        local raw=text:sub(s,e)
        local normalized=self:NormalizeWord(raw)
        if normalized~="" and #normalized<=28 and not self:ShouldSkipToken(text,s,e,raw) then tokens[#tokens+1]=normalized end
        searchFrom=e+1
    end
    return tokens
end

-- Super's higher-order/session model respects strong sentence boundaries. Standard's
-- existing unigram/bigram/trigram learner intentionally keeps its original tokenization.
local function TokenizeLearnableEntries(self,text)
    local entries={}
    local scanText=self:BuildWordScanShadow(text)
    local searchFrom=1
    local previousEnd=nil
    local forceBoundary=true
    while true do
        local s,e=scanText:find("[A-Za-z][A-Za-z'%-]*",searchFrom)
        if not s then break end
        local raw=text:sub(s,e)
        local normalized=self:NormalizeWord(raw)
        local skip=normalized=="" or #normalized>28 or self:ShouldSkipToken(text,s,e,raw)
        if not skip then
            local boundary=forceBoundary or previousEnd==nil
            if previousEnd then
                local gap=text:sub(previousEnd+1,s-1)
                if gap:find("[%.%!%?%:%;\n\r]") then boundary=true end
            end
            entries[#entries+1]={word=normalized,boundary=boundary}
            previousEnd=e
            forceBoundary=false
        else
            previousEnd=e
            forceBoundary=true
        end
        searchFrom=e+1
    end
    return entries
end

function FSC:LearnAutocompleteText(text)
    if not self:IsPersonalizationEnabled() then return end
    if not text or text=="" then return end
    local store=EnsureAutocompleteStore(self)
    if not store then return end
    local tokens=TokenizeLearnable(self,text)
    local previousPrevious,previous=nil,nil
    for _,word in ipairs(tokens) do
        Increment(store.unigrams,word,1,255)
        if previous then AddBigram(store,previous,word,1) end
        if previousPrevious and previous then AddTrigram(store,previousPrevious,previous,word,1) end
        previousPrevious,previous=previous,word
    end
    if self:IsSuperSuggestionsEnabled() then
        local a,b,c=nil,nil,nil
        for _,entry in ipairs(TokenizeLearnableEntries(self,text)) do
            if entry.boundary then a,b,c=nil,nil,nil end
            if a and b and c then AddFourgram(store,a,b,c,entry.word,1) end
            a,b,c=b,c,entry.word
        end
    end
    store.learnedMessages=(store.learnedMessages or 0)+1
    FSC.personalAutocompletePrefixIndex=nil
    if store.learnedMessages%40==0 then PrunePersonalUnigrams(store) end
    if store.learnedMessages%80==0 then PruneTrigramContexts(store) end
    if self:IsSuperSuggestionsEnabled() and store.learnedMessages%100==0 then
        PruneFourgramContexts(store)
    end
end

function FSC:RecordAutocompleteAcceptance(previousWord,word,previousPreviousWord,previousThirdWord)
    if not self:IsPersonalizationEnabled() then return end
    local normalized=self:NormalizeWord(word)
    if normalized=="" or normalized:find(" ",1,true) then return end
    local store=EnsureAutocompleteStore(self)
    if not store then return end
    Increment(store.unigrams,normalized,2,255)
    if previousWord and previousWord~="" then AddBigram(store,previousWord,normalized,3) end
    if previousPreviousWord and previousWord then AddTrigram(store,previousPreviousWord,previousWord,normalized,4) end
    if self:IsSuperSuggestionsEnabled()
        and previousThirdWord and previousPreviousWord and previousWord then
        AddFourgram(store,previousThirdWord,previousPreviousWord,previousWord,normalized,5)
    end
    FSC.personalAutocompletePrefixIndex=nil
    self:InvalidateAutocompleteCaches()
end

local function BuildSeedNgrams()
    local signature=FSC:GetDictionaryStateSignature()
    if FSC.autocompleteSeedBigrams and FSC.autocompleteSeedTrigrams and FSC.autocompleteSeedSignature==signature then
        return FSC.autocompleteSeedBigrams,FSC.autocompleteSeedTrigrams
    end
    local bigrams,trigrams={},{}
    local function AddPhrase(phrase,weight,suppressGenericStarts)
        local words={}
        for token in tostring(phrase):gsub("’","'"):gsub("‘","'"):gmatch("[A-Za-z][A-Za-z'%-]*") do words[#words+1]=FSC:NormalizeWord(token) end
        for i=1,#words-1 do
            local previous,word=words[i],words[i+1]
            if previous~="" and word~="" and (not suppressGenericStarts or not GENERIC_SEED_STOPWORDS[previous]) then
                bigrams[previous]=bigrams[previous] or {}
                bigrams[previous][word]=(bigrams[previous][word] or 0)+weight
            end
        end
        for i=1,#words-2 do
            local a,b,word=words[i],words[i+1],words[i+2]
            if a~="" and b~="" and word~="" then
                local key=TrigramKey(a,b)
                trigrams[key]=trigrams[key] or {}
                trigrams[key][word]=(trigrams[key][word] or 0)+weight
            end
        end
    end
    if IsPackEnabled(FSC,"english") then
        for _,phrase in ipairs(GENERAL_CONTEXT_PHRASES) do if CanUseColdStartPhrase(phrase) then AddPhrase(phrase,4,false) end end
    end
    FSC:ForEachEnabledDictionaryPhrase(function(phrase,weight,suppressGenericStarts)
        AddPhrase(phrase,weight or 4,suppressGenericStarts==true)
    end,false)
    FSC.autocompleteSeedBigrams=bigrams
    FSC.autocompleteSeedTrigrams=trigrams
    FSC.autocompleteSeedSignature=signature
    return bigrams,trigrams
end

local function BuildSuperSeedNgrams()
    local signature=FSC:GetDictionaryStateSignature()
    if FSC.superSeedBigrams and FSC.superSeedTrigrams and FSC.superSeedFourgrams and FSC.superSeedSignature==signature then
        return FSC.superSeedBigrams,FSC.superSeedTrigrams,FSC.superSeedFourgrams
    end
    local bigrams,trigrams,fourgrams={},{},{}
    local function AddPhrase(phrase,weight,suppressGenericStarts)
        local words={}
        for token in tostring(phrase):gsub("’","'"):gsub("‘","'"):gmatch("[A-Za-z][A-Za-z'%-]*") do
            local normalized=FSC:NormalizeWord(token)
            if normalized~="" then words[#words+1]=normalized end
        end
        for i=1,#words-1 do
            local a,b=words[i],words[i+1]
            if not suppressGenericStarts or not GENERIC_SEED_STOPWORDS[a] then
                bigrams[a]=bigrams[a] or {}
                bigrams[a][b]=(bigrams[a][b] or 0)+weight
            end
        end
        for i=1,#words-2 do
            local a,b,c=words[i],words[i+1],words[i+2]
            local key=TrigramKey(a,b)
            trigrams[key]=trigrams[key] or {}
            trigrams[key][c]=(trigrams[key][c] or 0)+weight
        end
        for i=1,#words-3 do
            local a,b,c,d=words[i],words[i+1],words[i+2],words[i+3]
            local key=FourgramKey(a,b,c)
            fourgrams[key]=fourgrams[key] or {}
            fourgrams[key][d]=(fourgrams[key][d] or 0)+weight
        end
    end
    if IsPackEnabled(FSC,"english") then
        for _,phrase in ipairs(GENERAL_CONTEXT_PHRASES) do if CanUseColdStartPhrase(phrase) then AddPhrase(phrase,2) end end
        for _,phrase in ipairs(SUPER_CONTEXT_PHRASES) do if CanUseColdStartPhrase(phrase) then AddPhrase(phrase,4) end end
    end
    FSC:ForEachEnabledDictionaryPhrase(function(phrase,weight,suppressGenericStarts)
        AddPhrase(phrase,weight or 3,suppressGenericStarts==true)
    end,true)
    FSC.superSeedBigrams=bigrams
    FSC.superSeedTrigrams=trigrams
    FSC.superSeedFourgrams=fourgrams
    FSC.superSeedSignature=signature
    return bigrams,trigrams,fourgrams
end

local function IsStrongSentenceBoundary(char)
    return char=="." or char=="!" or char=="?" or char==";" or char=="\n" or char=="\r"
end

local function IsAsciiFragmentAdjacentToNonAscii(text,startIndex,endIndex)
    local beforeByte=startIndex>1 and text:byte(startIndex-1) or nil
    local afterByte=endIndex<#text and text:byte(endIndex+1) or nil
    return (beforeByte and beforeByte>=128) or (afterByte and afterByte>=128) or false
end

local function FindPreviousWordInSentence(text,beforeIndex,scanText)
    scanText=scanText or FSC:BuildWordScanShadow(text)
    local i=math.min(#text,math.max(0,beforeIndex or #text))
    while i>0 do
        while i>0 do
            local char=scanText:sub(i,i)
            if IsStrongSentenceBoundary(char) then return nil,0 end
            if IsWordChar(char) then break end
            i=i-1
        end
        if i<=0 then return nil,0 end

        local finish=i
        while i>0 and IsWordChar(scanText:sub(i,i)) do i=i-1 end
        local startIndex=i+1
        if not IsAsciiFragmentAdjacentToNonAscii(text,startIndex,finish) then
            local word=FSC:NormalizeWord(text:sub(startIndex,finish))
            if word~="" then return word,i end
        end
        -- This was only the ASCII fragment of a UTF-8 word. Keep walking left for
        -- the nearest genuine ASCII context word instead of returning the fragment.
    end
    return nil,0
end

local function FindNextWordInSentence(text,afterIndex,scanText)
    scanText=scanText or FSC:BuildWordScanShadow(text)
    local i=math.max(1,math.min(#text+1,(afterIndex or 0)+1))
    while i<=#text do
        while i<=#text do
            local char=scanText:sub(i,i)
            if IsStrongSentenceBoundary(char) then return nil,#text+1 end
            if IsWordChar(char) then break end
            i=i+1
        end
        if i>#text then return nil,#text+1 end

        local startIndex=i
        while i<=#text and IsWordChar(scanText:sub(i,i)) do i=i+1 end
        local finish=i-1
        if not IsAsciiFragmentAdjacentToNonAscii(text,startIndex,finish) then
            local word=FSC:NormalizeWord(text:sub(startIndex,finish))
            if word~="" then return word,i end
        end
        -- Skip a partial accented/non-ASCII token and continue to the next real word.
    end
    return nil,#text+1
end

local function FindPreviousWord(text,beforeIndex,scanText)
    scanText=scanText or FSC:BuildWordScanShadow(text)
    local i=math.min(#text,math.max(0,beforeIndex or #text))
    while i>0 do
        while i>0 and not IsWordChar(scanText:sub(i,i)) do i=i-1 end
        if i<=0 then return nil,0 end
        local finish=i
        while i>0 and IsWordChar(scanText:sub(i,i)) do i=i-1 end
        local startIndex=i+1
        if not IsAsciiFragmentAdjacentToNonAscii(text,startIndex,finish) then
            local word=FSC:NormalizeWord(text:sub(startIndex,finish))
            if word~="" then return word,i end
        end
    end
    return nil,0
end

function FSC:GetAutocompleteContext(text,cursor)
    text=text or ""
    cursor=math.max(0,math.min(#text,cursor or #text))
    local scanText=self:BuildWordScanShadow(text)
    local tokenStart=cursor+1
    local i=cursor
    while i>0 and IsWordChar(scanText:sub(i,i)) do tokenStart=i; i=i-1 end
    local tokenEnd=cursor
    local j=cursor+1
    while j<=#text and IsWordChar(scanText:sub(j,j)) do tokenEnd=j; j=j+1 end
    local rawPrefix=tokenStart<=cursor and text:sub(tokenStart,cursor) or ""
    local prefix=self:NormalizeWord(rawPrefix)

    -- These original two fields intentionally keep the Standard-mode behavior unchanged.
    local previousWord,beforePrevious=FindPreviousWord(text,tokenStart-2,scanText)
    local previousPreviousWord=nil
    if previousWord then previousPreviousWord=select(1,FindPreviousWord(text,beforePrevious,scanText)) end

    -- Super-only context parsing is deliberately gated so Standard retains its cheap path.
    local superPreviousWord,superPreviousPreviousWord,superPreviousThirdWord=nil,nil,nil
    local nextWord,nextNextWord=nil,nil
    local superEnabled=self:IsSuperSuggestionsEnabled()
    if superEnabled then
        local superBeforePrevious,superBeforeThird=0,0
        superPreviousWord,superBeforePrevious=FindPreviousWordInSentence(text,tokenStart-2,scanText)
        if superPreviousWord then
            superPreviousPreviousWord,superBeforeThird=FindPreviousWordInSentence(text,superBeforePrevious,scanText)
            if superPreviousPreviousWord then
                superPreviousThirdWord=select(1,FindPreviousWordInSentence(text,superBeforeThird,scanText))
            end
        end
        local nextAfter=0
        nextWord,nextAfter=FindNextWordInSentence(text,tokenEnd,scanText)
        if nextWord then nextNextWord=select(1,FindNextWordInSentence(text,nextAfter-1,scanText)) end
    end

    local beforeToken=tokenStart>1 and text:sub(tokenStart-1,tokenStart-1) or ""
    local chunkStart=tokenStart
    while chunkStart>1 and not text:sub(chunkStart-1,chunkStart-1):match("%s") do chunkStart=chunkStart-1 end
    local chunkEnd=math.max(tokenEnd,cursor)
    while chunkEnd<#text and not text:sub(chunkEnd+1,chunkEnd+1):match("%s") do chunkEnd=chunkEnd+1 end
    local chunk=text:sub(chunkStart,chunkEnd)
    local lowerChunk=string.lower(chunk)
    local suppressed=false
    if beforeToken=="@" then suppressed=true end
    if beforeToken=="/" and tokenStart<=2 then suppressed=true end
    if chunk:find("|",1,true) then suppressed=true end
    if lowerChunk:find("://",1,true) or lowerChunk:find("www.",1,true) or lowerChunk:find("discord.gg",1,true) then suppressed=true end
    local atWordBoundary=prefix=="" and cursor>0 and text:sub(cursor,cursor):match("%s")~=nil
    if prefix=="" and not atWordBoundary then suppressed=true end
    if prefix~="" and not prefix:match("^[a-z][a-z'%-]*$") then suppressed=true end

    local currentCounts,currentLast,ordinal={},{},0
    if superEnabled then
        local left=text:sub(1,math.max(0,tokenStart-1))
        local leftScan=self:BuildWordScanShadow(left)
        local searchFrom=1
        while true do
            local wordStart,wordEnd=leftScan:find("[A-Za-z][A-Za-z'%-]*",searchFrom)
            if not wordStart then break end
            if not IsAsciiFragmentAdjacentToNonAscii(left,wordStart,wordEnd) then
                local word=self:NormalizeWord(left:sub(wordStart,wordEnd))
                if word~="" then
                    ordinal=ordinal+1
                    currentCounts[word]=(currentCounts[word] or 0)+1
                    currentLast[word]=ordinal
                end
            end
            searchFrom=wordEnd+1
        end
    end

    return {
        text=text,cursor=cursor,tokenStart=tokenStart,tokenEnd=tokenEnd,rawPrefix=rawPrefix,prefix=prefix,
        previousWord=previousWord,previousPreviousWord=previousPreviousWord,
        previousThirdWord=superPreviousThirdWord,
        superPreviousWord=superPreviousWord,superPreviousPreviousWord=superPreviousPreviousWord,
        superPreviousThirdWord=superPreviousThirdWord,nextWord=nextWord,nextNextWord=nextNextWord,
        currentWordCounts=currentCounts,currentWordLast=currentLast,currentWordOrdinal=ordinal,
        atWordBoundary=atWordBoundary,suppressed=suppressed,
    }
end

local function PersonalUnigramCount(store,word) return store and store.unigrams and (store.unigrams[word] or 0) or 0 end
local function PersonalBigramCount(store,previous,word)
    if not store or not previous or not store.bigrams then return 0 end
    local nextWords=store.bigrams[previous]
    return nextWords and (nextWords[word] or 0) or 0
end
local function PersonalTrigramCount(store,a,b,word)
    if not store or not a or not b or not store.trigrams then return 0 end
    local nextWords=store.trigrams[TrigramKey(a,b)]
    return nextWords and (nextWords[word] or 0) or 0
end
local function PersonalFourgramCount(store,a,b,c,word)
    if not store or not a or not b or not c or not store.fourgrams then return 0 end
    local nextWords=store.fourgrams[FourgramKey(a,b,c)]
    return nextWords and (nextWords[word] or 0) or 0
end
local function SeedBigramCount(previous,word)
    if not previous then return 0 end
    local bigrams=select(1,BuildSeedNgrams())
    local nextWords=bigrams[previous]
    return nextWords and (nextWords[word] or 0) or 0
end
local function SeedTrigramCount(a,b,word)
    if not a or not b then return 0 end
    local _,trigrams=BuildSeedNgrams()
    local nextWords=trigrams[TrigramKey(a,b)]
    return nextWords and (nextWords[word] or 0) or 0
end

function FSC:GetLanguageContextScore(previousPreviousWord,previousWord,word,nextWord)
    word=self:NormalizeWord(word)
    if word=="" then return 0 end
    local store=self:IsPersonalizationEnabled() and EnsureAutocompleteStore(self) or nil
    local score=0
    local pb=PersonalBigramCount(store,previousWord,word)
    local pt=PersonalTrigramCount(store,previousPreviousWord,previousWord,word)
    local sb=SeedBigramCount(previousWord,word)
    local st=SeedTrigramCount(previousPreviousWord,previousWord,word)
    score=score+math.min(1900,pb*380)+math.min(3200,pt*920)
    score=score+math.min(720,sb*90)+math.min(1250,st*210)
    if nextWord then
        local rightPB=PersonalBigramCount(store,word,nextWord)
        local rightSB=SeedBigramCount(word,nextWord)
        score=score+math.min(1250,rightPB*320)+math.min(500,rightSB*70)
        if previousWord then
            local rightPT=PersonalTrigramCount(store,previousWord,word,nextWord)
            local rightST=SeedTrigramCount(previousWord,word,nextWord)
            score=score+math.min(1800,rightPT*700)+math.min(700,rightST*150)
        end
    end
    return score
end

local function IsPersonalCandidateAllowed(self,store,word)
    if self:IsKnownNormalized(word) then return true end
    return PersonalUnigramCount(store,word)>=2
end

local function AddAutocompleteCandidate(self,candidates,store,context,word,sourceBonus,source,allowNonPrefix,trustedKnown)
    word=self:NormalizeWord(word)
    if word=="" or #word>32 then return false end
    local exactPrefix=StartsWith(word,context.prefix)
    if context.prefix~="" and not exactPrefix and not allowNonPrefix then return false end
    if context.prefix~="" and word==context.prefix then return false end
    if not trustedKnown and not IsPersonalCandidateAllowed(self,store,word) then return false end
    -- Product-level hard denylist for the prediction bar only. It is intentionally not
    -- used by SpellEngine/right-click corrections.
    if self.IsPredictionBarHardBlocked and self:IsPredictionBarHardBlocked(word) then return false end
    -- Safety is deliberately a last-mile eligibility gate. It never participates in
    -- scoring/ranking, and it runs only after the cheap prefix/known-word checks.
    if self.IsSuggestionSafe and not self:IsSuggestionSafe(word, context, source) then return false end
    local frequencyScore=self:GetDictionaryFrequencyScore(word)
    local unigramCount=PersonalUnigramCount(store,word)
    local remaining=math.max(0,#word-#context.prefix)
    local score=1000+frequencyScore+(sourceBonus or 0)
    score=score+math.min(560,unigramCount*28)
    score=score+self:GetLanguageContextScore(context.previousPreviousWord,context.previousWord,word,nil)
    if context.prefix~="" then
        score=score+math.min(100,#context.prefix*12)-math.min(120,remaining*4)
        if not exactPrefix then score=score-160 end
    end
    local existing=candidates[word]
    if not existing or score>existing.score then candidates[word]={word=word,score=score,source=source or "dictionary"}; return true end
    return false
end

local function AddFrequencyPrefixCandidates(self,candidates,store,context)
    if not IsPackEnabled(self,"english") then return end
    if not Frequency or not Frequency.prefixTop then return end
    local prefix=context.prefix
    if #prefix<1 or #prefix>2 then return end
    local blob=Frequency.prefixTop[prefix]
    if not blob then return end
    for word in blob:gmatch("[^\n]+") do AddAutocompleteCandidate(self,candidates,store,context,word,80,"frequency") end
end

local function AddEnglishPrefixCandidates(self,candidates,store,context)
    if not IsPackEnabled(self,"english") then return end
    local prefix=context.prefix
    if #prefix<3 then return end
    local key=prefix:sub(1,3)
    if not key:match("^[a-z][a-z][a-z]$") then return end
    local blob=Frequency.prefixTop3[key]
    if blob then
        for word in blob:gmatch("[^\n]+") do
            if StartsWith(word,prefix) then AddAutocompleteCandidate(self,candidates,store,context,word,0,"english",false,true) end
        end
        return
    end
    if not English or not English.buckets then return end
    local dictionaryBlob=English.buckets[key]
    if not dictionaryBlob then return end
    local inspected=0
    for suffix in dictionaryBlob:gmatch("[^\n]+") do
        inspected=inspected+1
        local word=key..suffix
        if StartsWith(word,prefix) then AddAutocompleteCandidate(self,candidates,store,context,word,0,"english",false,true) end
        if inspected>=72 then break end
    end
end

local function EnsureESOAutocompleteTokens()
    local signature=FSC:GetDictionaryStateSignature()
    if ESO.autocompleteTokens and ESO.autocompleteTokensSignature==signature then return ESO.autocompleteTokens end
    local tokens={}
    ESO.ForEachEnabledStaticToken(function(word) tokens[word]=true end)
    ESO.ForEachEnabledStaticPhrase(function(phrase)
        for token in phrase:gsub("’","'"):gsub("‘","'"):gmatch("[A-Za-z][A-Za-z'%-]*") do
            local word=FSC:NormalizeWord(token)
            if word~="" and not GENERIC_SEED_STOPWORDS[word] then tokens[word]=true end
        end
    end)
    ESO.autocompleteTokens=tokens
    ESO.autocompleteTokensSignature=signature
    return tokens
end

local function BuildPrefix3Index(tokens)
    local index={}
    for word in pairs(tokens or {}) do
        if #word>=3 then
            local key=word:sub(1,3)
            if key:match("^[a-z][a-z][a-z]$") then
                local bucket=index[key]
                if not bucket then bucket={}; index[key]=bucket end
                bucket[#bucket+1]=word
            end
        end
    end
    return index
end
local function EnsureESOPrefixIndex()
    local signature=FSC:GetDictionaryStateSignature()
    if ESO.autocompletePrefixIndex and ESO.autocompletePrefixIndexSignature==signature then return ESO.autocompletePrefixIndex end
    ESO.autocompletePrefixIndex=BuildPrefix3Index(EnsureESOAutocompleteTokens())
    ESO.autocompletePrefixIndexSignature=signature
    return ESO.autocompletePrefixIndex
end
local function EnsureESORuntimePrefixIndex()
    local signature=FSC:GetDictionaryStateSignature()
    if ESO.runtimeAutocompletePrefixIndex and ESO.runtimeAutocompletePrefixIndexSignature==signature then return ESO.runtimeAutocompletePrefixIndex end
    local tokens={}
    ESO.ForEachEnabledRuntimeToken(function(word) tokens[word]=true end)
    ESO.runtimeAutocompletePrefixIndex=BuildPrefix3Index(tokens)
    ESO.runtimeAutocompletePrefixIndexSignature=signature
    return ESO.runtimeAutocompletePrefixIndex
end
local function EnsurePersonalPrefixIndex(store)
    if FSC.personalAutocompletePrefixIndex then return FSC.personalAutocompletePrefixIndex end
    local index={}
    for word,count in pairs(store and store.unigrams or {}) do
        if count>=2 and #word>=2 then
            local key2=word:sub(1,2); index[key2]=index[key2] or {}; index[key2][#index[key2]+1]=word
            if #word>=3 then local key3=word:sub(1,3); index[key3]=index[key3] or {}; index[key3][#index[key3]+1]=word end
        end
    end
    FSC.personalAutocompletePrefixIndex=index
    return index
end
local function ScaledDomainBonus(context,fullBonus)
    local length=#(context.prefix or "")
    if length<=1 then return 0 end
    if length==2 then return math.floor(fullBonus*0.4) end
    return fullBonus
end

local function AddSmallLexiconCandidates(self,candidates,store,context)
    if IsPackEnabled(self,"english") and Chat and Chat.tokens then
        for word in pairs(Chat.tokens) do if StartsWith(word,context.prefix) then AddAutocompleteCandidate(self,candidates,store,context,word,420,"chat",false,true) end end
    end
    if self.saved and self.saved.userWords then
        for word in pairs(self.saved.userWords) do if StartsWith(word,context.prefix) then AddAutocompleteCandidate(self,candidates,store,context,word,320,"user",false,true) end end
    end
    if IsPackEnabled(self,"eso") then
        for word,subcategory in pairs(ESO_DOMAIN_WORDS) do
            if IsESOCategoryEnabled(subcategory) and StartsWith(word,context.prefix) then
                AddAutocompleteCandidate(self,candidates,store,context,word,ScaledDomainBonus(context,720),"eso-domain",false,true)
            end
        end
        if ESO and #context.prefix>=3 then
            local key=context.prefix:sub(1,3)
            local esoIndex=EnsureESOPrefixIndex()
            for _,word in ipairs((esoIndex and esoIndex[key]) or {}) do if StartsWith(word,context.prefix) then AddAutocompleteCandidate(self,candidates,store,context,word,ScaledDomainBonus(context,500),"eso",false,true) end end
            local runtimeIndex=EnsureESORuntimePrefixIndex()
            for _,word in ipairs((runtimeIndex and runtimeIndex[key]) or {}) do if StartsWith(word,context.prefix) then AddAutocompleteCandidate(self,candidates,store,context,word,ScaledDomainBonus(context,580),"eso-runtime",false,true) end end
        end
    end
end

local function AddPersonalPrefixCandidates(self,candidates,store,context)
    if not store or not store.unigrams or #context.prefix<2 then return end
    local index=EnsurePersonalPrefixIndex(store)
    local key=context.prefix:sub(1,math.min(3,#context.prefix))
    for _,word in ipairs(index[key] or {}) do if StartsWith(word,context.prefix) then AddAutocompleteCandidate(self,candidates,store,context,word,120,"personal",false,true) end end
end

local function AddContextCandidates(self,candidates,store,context)
    local previous=context.previousWord
    if not previous then return end
    if context.previousPreviousWord and store and store.trigrams then
        local nextWords=store.trigrams[TrigramKey(context.previousPreviousWord,previous)]
        for word in pairs(nextWords or {}) do if context.prefix=="" or StartsWith(word,context.prefix) then AddAutocompleteCandidate(self,candidates,store,context,word,520,"personal-trigram",false,true) end end
    end
    if store and store.bigrams and store.bigrams[previous] then
        for word in pairs(store.bigrams[previous]) do if context.prefix=="" or StartsWith(word,context.prefix) then AddAutocompleteCandidate(self,candidates,store,context,word,260,"personal-context",false,true) end end
    end
    local seedBigrams,seedTrigrams=BuildSeedNgrams()
    if context.previousPreviousWord then
        local nextWords=seedTrigrams[TrigramKey(context.previousPreviousWord,previous)]
        for word in pairs(nextWords or {}) do if context.prefix=="" or StartsWith(word,context.prefix) then AddAutocompleteCandidate(self,candidates,store,context,word,300,"seed-trigram",false,true) end end
    end
    if seedBigrams[previous] then
        for word in pairs(seedBigrams[previous]) do if context.prefix=="" or StartsWith(word,context.prefix) then AddAutocompleteCandidate(self,candidates,store,context,word,120,"seed-context",false,true) end end
    end
end

local function GenerateOneDeleteSignatures(term)
    local out={term}
    local seen={[term]=true}
    for i=1,#term do
        local deleted=term:sub(1,i-1)..term:sub(i+1)
        if not seen[deleted] then seen[deleted]=true; out[#out+1]=deleted end
    end
    return out
end

local function PrefixWithinOneEdit(prefix,word)
    if #prefix < 4 or #word < #prefix - 1 then return false end
    local minLength=math.max(1,#prefix-1)
    local maxLength=math.min(#word,#prefix+1)
    for length=minLength,maxLength do
        if BoundedDamerauLevenshtein(prefix,word:sub(1,length),1)<=1 then return true end
    end
    return false
end

local SMALL_FUZZY_DELETE_INDEX=nil
local SMALL_FUZZY_DELETE_INDEX_SIGNATURE=nil
local function AddSmallFuzzyIndexWord(index,word,bonus,source)
    local base=word:sub(1,math.min(5,#word))
    for _,signature in ipairs(GenerateOneDeleteSignatures(base)) do
        local bucket=index[signature]
        if not bucket then bucket={}; index[signature]=bucket end
        bucket[#bucket+1]={word=word,bonus=bonus,source=source}
    end
end
local function EnsureSmallFuzzyDeleteIndex()
    local signature=FSC:GetDictionaryStateSignature()
    if SMALL_FUZZY_DELETE_INDEX and SMALL_FUZZY_DELETE_INDEX_SIGNATURE==signature then return SMALL_FUZZY_DELETE_INDEX end
    local index={}
    if IsPackEnabled(FSC,"english") and Chat and Chat.tokens then
        for word in pairs(Chat.tokens) do AddSmallFuzzyIndexWord(index,word,1050,"chat-fuzzy") end
    end

    if IsPackEnabled(FSC,"eso") then
        -- Include the full ESO autocomplete vocabulary here as well, not only the
        -- small hand-picked domain list. This lets known ESO names survive a typo
        -- inside the typed prefix without scanning the ESO vocabulary every keystroke.
        local esoTokens=EnsureESOAutocompleteTokens()
        for word in pairs(esoTokens or {}) do AddSmallFuzzyIndexWord(index,word,1120,"eso-name-fuzzy") end
        if ESO and ESO.ForEachEnabledRuntimeToken then
            ESO.ForEachEnabledRuntimeToken(function(word) AddSmallFuzzyIndexWord(index,word,1100,"eso-runtime-fuzzy") end)
        elseif ESO and ESO.runtimeTokens then
            for word in pairs(ESO.runtimeTokens) do AddSmallFuzzyIndexWord(index,word,1100,"eso-runtime-fuzzy") end
        end
        for word,subcategory in pairs(ESO_DOMAIN_WORDS) do
            if IsESOCategoryEnabled(subcategory) then AddSmallFuzzyIndexWord(index,word,780,"eso-fuzzy") end
        end
    end
    SMALL_FUZZY_DELETE_INDEX=index
    SMALL_FUZZY_DELETE_INDEX_SIGNATURE=signature
    return index
end

-- A tiny dedicated delete index guarantees recall for high-value chat/ESO words
-- without scanning those vocabularies or walking the full dictionary on every
-- keystroke. It complements the capped generic correction index.
local function AddSmallFuzzyLexiconCandidates(self,candidates,store,context)
    local prefix=context.prefix
    if #prefix<4 or self:IsKnownNormalized(prefix) then return end
    local base=prefix:sub(1,math.min(5,#prefix))
    local index=EnsureSmallFuzzyDeleteIndex()
    local seen={}
    for _,signature in ipairs(GenerateOneDeleteSignatures(base)) do
        for _,entry in ipairs(index[signature] or {}) do
            if not seen[entry.word] then
                seen[entry.word]=true
                if PrefixWithinOneEdit(prefix,entry.word) then
                    AddAutocompleteCandidate(self,candidates,store,context,entry.word,entry.bonus,entry.source,true,true)
                end
            end
        end
    end
end

local function AddDeleteFuzzyCandidates(self,candidates,store,context)
    if not IsPackEnabled(self,"english") then return end
    local prefix=context.prefix
    if #prefix<4 or self:IsKnownNormalized(prefix) or not DeleteIndex or not DeleteIndex.Lookup then return end
    local base=prefix:sub(1,math.min(DeleteIndex.maxPrefixLength or 5,#prefix))
    local found,ordered={},{}
    for _,signature in ipairs(GenerateOneDeleteSignatures(base)) do
        DeleteIndex.Lookup(signature,found,ordered,12)
        if #ordered>=28 then break end
    end
    local inspected=0
    for _,word in ipairs(ordered) do
        inspected=inspected+1
        if #word>=#prefix-1 then
            local best=2
            local lengths={#prefix-1,#prefix,#prefix+1}
            for _,length in ipairs(lengths) do
                if length>0 and length<=#word then
                    local distance=BoundedDamerauLevenshtein(prefix,word:sub(1,length),1)
                    if distance<best then best=distance end
                end
            end
            if best<=1 then
                local fuzzyBonus=450
                if IsPackEnabled(self,"english") and Chat.tokens and Chat.tokens[word] then fuzzyBonus=fuzzyBonus+240 end
                if IsPackEnabled(self,"eso") and ESO_DOMAIN_WORDS[word] and IsESOCategoryEnabled(ESO_DOMAIN_WORDS[word]) then fuzzyBonus=fuzzyBonus+320 end
                if self.saved and self.saved.userWords and self.saved.userWords[word] then fuzzyBonus=fuzzyBonus+360 end
                local personalCount=PersonalUnigramCount(store,word)
                if personalCount>=2 then fuzzyBonus=fuzzyBonus+math.min(300,personalCount*24) end
                AddAutocompleteCandidate(self,candidates,store,context,word,fuzzyBonus,"delete-fuzzy",true,true)
            end
        end
        if inspected>=28 then break end
    end
end

local function AddLearnedCorrectionCandidates(self,candidates,store,context)
    if not self:IsCorrectionLearningEnabled() then return end
    local prefix=context.prefix
    if prefix=="" or not self.saved or not self.saved.correctionLearning then return end
    local bucket=self.saved.correctionLearning.pairs and self.saved.correctionLearning.pairs[prefix]
    if not bucket then return end
    for word,count in pairs(bucket) do
        if not word:find(" ",1,true) then
            AddAutocompleteCandidate(self,candidates,store,context,word,math.min(1200,500+count*180),"learned-correction",true,true)
        end
    end
end

local function AddRegisteredDictionaryAutocompleteCandidates(self,candidates,store,context)
    self:EnumerateRegisteredAutocompleteCandidates(context, function(word, sourceBonus, source, allowNonPrefix, trustedKnown)
        AddAutocompleteCandidate(self,candidates,store,context,word,sourceBonus or 0,source or "dictionary-pack",allowNonPrefix==true,trustedKnown~=false)
    end)
end

local function BuildStandardCandidateMap(self,context,store)
    local candidates={}
    AddContextCandidates(self,candidates,store,context)
    if not context.atWordBoundary then
        AddFrequencyPrefixCandidates(self,candidates,store,context)
        AddEnglishPrefixCandidates(self,candidates,store,context)
        AddSmallLexiconCandidates(self,candidates,store,context)
        AddPersonalPrefixCandidates(self,candidates,store,context)
        AddLearnedCorrectionCandidates(self,candidates,store,context)
        AddSmallFuzzyLexiconCandidates(self,candidates,store,context)
        AddDeleteFuzzyCandidates(self,candidates,store,context)
    end
    AddRegisteredDictionaryAutocompleteCandidates(self,candidates,store,context)
    return candidates
end

local function RankCandidateMap(candidates,limit)
    local ranked={}
    for _,data in pairs(candidates) do ranked[#ranked+1]=data end
    table.sort(ranked,function(a,b)
        if a.score==b.score then if #a.word==#b.word then return a.word<b.word end return #a.word<#b.word end
        return a.score>b.score
    end)
    local results={}
    for i=1,math.min(limit,#ranked) do results[i]=ranked[i].word end
    return results,ranked
end

local function BucketTotal(bucket)
    local total=0
    for _,count in pairs(bucket or {}) do total=total+(tonumber(count) or 0) end
    return total
end

local function SmoothedContextScore(bucket,word,scale)
    if not bucket then return 0 end
    local count=tonumber(bucket[word]) or 0
    if count<=0 then return 0 end
    local total=BucketTotal(bucket)
    if total<=0 then return 0 end
    local probability=count/total
    local reliability=math.min(1,total/6)
    return scale * reliability * (0.30 * (math.log(1+count)/math.log(8)) + 0.70 * probability)
end

local function EnsureSuperSession(self)
    if self.superAutocompleteSession then return self.superAutocompleteSession end
    self.superAutocompleteSession={
        serial=0,messages=0,unigrams={},bigrams={},trigrams={},fourgrams={}
    }
    return self.superAutocompleteSession
end

local function TouchSessionNext(map,key,word,serial,isOwn)
    if not key or key=="" or not word or word=="" then return end
    local bucket=map[key]
    if not bucket then bucket={}; map[key]=bucket end
    local entry=bucket[word]
    if not entry then entry={count=0,own=0,last=serial}; bucket[word]=entry end
    entry.count=math.min(32,(entry.count or 0)+1)
    if isOwn then entry.own=math.min(32,(entry.own or 0)+1) end
    entry.last=serial
end

local function SessionBucketNewest(bucket)
    local newest=0
    for _,entry in pairs(bucket or {}) do newest=math.max(newest,entry.last or 0) end
    return newest
end

local function PruneSessionContextMap(session,map)
    local serial=session.serial or 0
    for key,bucket in pairs(map) do
        for word,entry in pairs(bucket) do
            if serial-(entry.last or 0)>SUPER_SESSION_MAX_AGE then bucket[word]=nil end
        end
        if next(bucket)==nil then map[key]=nil end
    end
    if TableSize(map)<=SUPER_SESSION_MAX_CONTEXTS then return end
    local ranked={}
    for key,bucket in pairs(map) do ranked[#ranked+1]={key=key,last=SessionBucketNewest(bucket)} end
    table.sort(ranked,function(a,b) return a.last>b.last end)
    local keep={}
    for i=1,math.min(SUPER_SESSION_MAX_CONTEXTS,#ranked) do keep[ranked[i].key]=true end
    for key in pairs(map) do if not keep[key] then map[key]=nil end end
end

local function PruneSuperSession(session)
    local serial=session.serial or 0
    for word,entry in pairs(session.unigrams) do
        if serial-(entry.last or 0)>SUPER_SESSION_MAX_AGE then session.unigrams[word]=nil end
    end
    if TableSize(session.unigrams)>SUPER_SESSION_MAX_WORDS then
        local ranked={}
        for word,entry in pairs(session.unigrams) do
            ranked[#ranked+1]={word=word,last=entry.last or 0,count=entry.count or 0}
        end
        table.sort(ranked,function(a,b)
            if a.last==b.last then return a.count>b.count end
            return a.last>b.last
        end)
        local keep={}
        for i=1,math.min(SUPER_SESSION_MAX_WORDS,#ranked) do keep[ranked[i].word]=true end
        for word in pairs(session.unigrams) do if not keep[word] then session.unigrams[word]=nil end end
    end
    PruneSessionContextMap(session,session.bigrams)
    PruneSessionContextMap(session,session.trigrams)
    PruneSessionContextMap(session,session.fourgrams)
end

function FSC:ObserveAutocompleteSessionText(text,isOwn)
    if not text or text=="" then return end
    if not self:IsSuperSuggestionsEnabled() then return end
    if not isOwn and not self:IsSuperConversationContextEnabled() then return end
    local tokens=TokenizeLearnableEntries(self,text)
    if #tokens==0 then return end
    local session=EnsureSuperSession(self)
    local a,b,c=nil,nil,nil
    for _,token in ipairs(tokens) do
        local word=token.word
        if token.boundary then a,b,c=nil,nil,nil end
        session.serial=session.serial+1
        local entry=session.unigrams[word]
        if not entry then entry={count=0,own=0,last=session.serial}; session.unigrams[word]=entry end
        entry.count=math.min(48,(entry.count or 0)+1)
        if isOwn then entry.own=math.min(48,(entry.own or 0)+1) end
        entry.last=session.serial
        if c then TouchSessionNext(session.bigrams,c,word,session.serial,isOwn) end
        if b and c then TouchSessionNext(session.trigrams,TrigramKey(b,c),word,session.serial,isOwn) end
        if a and b and c then TouchSessionNext(session.fourgrams,FourgramKey(a,b,c),word,session.serial,isOwn) end
        a,b,c=b,c,word
    end
    session.messages=session.messages+1
    if session.messages%35==0 then PruneSuperSession(session) end
    self.superPredictionCacheKey=nil
    self.superPredictionCacheResults=nil
end

local function SessionEntryScore(session,entry,scale)
    if not entry then return 0 end
    local age=math.max(0,(session.serial or 0)-(entry.last or 0))
    local recency=1/(1+age*0.055)
    local count=entry.count or 0
    local own=entry.own or 0
    return scale * recency * math.min(1.65,0.38 + math.log(1+count)/2.15 + math.min(0.35,own*0.05))
end

local function SessionContextScore(session,map,key,word,scale)
    local bucket=key and map[key] or nil
    local entry=bucket and bucket[word] or nil
    return SessionEntryScore(session,entry,scale)
end

local function AddSuperContextCandidates(self,candidates,store,context,session)
    local p1=context.superPreviousWord
    local p2=context.superPreviousPreviousWord
    local p3=context.superPreviousThirdWord
    local prefix=context.prefix
    local function AddBucket(bucket,bonus,source)
        for word in pairs(bucket or {}) do
            if prefix=="" or StartsWith(word,prefix) then
                AddAutocompleteCandidate(self,candidates,store,context,word,bonus,source,false,true)
            end
        end
    end
    local function AddSessionBucket(bucket,bonus,source)
        for word,entry in pairs(bucket or {}) do
            local trusted=(entry.own or 0)>0 or (entry.count or 0)>=2 or self:IsKnownNormalized(word)
            if trusted and (prefix=="" or StartsWith(word,prefix)) then
                AddAutocompleteCandidate(self,candidates,store,context,word,bonus,source,false,true)
            end
        end
    end
    if p3 and p2 and p1 and store and store.fourgrams then
        AddBucket(store.fourgrams[FourgramKey(p3,p2,p1)],980,"personal-fourgram")
    end
    if session then
        if p3 and p2 and p1 then AddSessionBucket(session.fourgrams[FourgramKey(p3,p2,p1)],760,"session-fourgram") end
        if p2 and p1 then AddSessionBucket(session.trigrams[TrigramKey(p2,p1)],520,"session-trigram") end
        if p1 then AddSessionBucket(session.bigrams[p1],300,"session-bigram") end
    end
    local sb,st,sf=BuildSuperSeedNgrams()
    if p3 and p2 and p1 then AddBucket(sf[FourgramKey(p3,p2,p1)],700,"super-seed-fourgram") end
    if p2 and p1 then AddBucket(st[TrigramKey(p2,p1)],400,"super-seed-trigram") end
    if p1 then AddBucket(sb[p1],170,"super-seed-bigram") end
end

local function AddSuperRecencyPrefixCandidates(self,candidates,store,context,session)
    if not session or context.prefix=="" then return end
    local ranked={}
    for word,entry in pairs(session.unigrams) do
        local trusted=(entry.own or 0)>0 or (entry.count or 0)>=2 or self:IsKnownNormalized(word)
        if trusted and StartsWith(word,context.prefix) then
            ranked[#ranked+1]={word=word,score=SessionEntryScore(session,entry,500)}
        end
    end
    table.sort(ranked,function(a,b) return a.score>b.score end)
    for i=1,math.min(32,#ranked) do
        AddAutocompleteCandidate(self,candidates,store,context,ranked[i].word,220+ranked[i].score,"session-prefix",false,true)
    end
end

local function AddCurrentMessagePrefixCandidates(self,candidates,store,context)
    if context.prefix=="" then return end
    for word,count in pairs(context.currentWordCounts or {}) do
        if count>0 and StartsWith(word,context.prefix) and word~=context.prefix then
            AddAutocompleteCandidate(self,candidates,store,context,word,180+math.min(360,count*120),"current-message",false,true)
        end
    end
end

local function SuperStaticScore(context,word)
    local p1,p2,p3=context.superPreviousWord,context.superPreviousPreviousWord,context.superPreviousThirdWord
    local sb,st,sf=BuildSuperSeedNgrams()
    local score=0
    if p3 and p2 and p1 then score=score+SmoothedContextScore(sf[FourgramKey(p3,p2,p1)],word,2200) end
    if p2 and p1 then score=score+SmoothedContextScore(st[TrigramKey(p2,p1)],word,1200) end
    if p1 then score=score+SmoothedContextScore(sb[p1],word,520) end
    return score
end

local function SuperPersistentScore(store,context,word)
    if not store then return 0 end
    local p1,p2,p3=context.superPreviousWord,context.superPreviousPreviousWord,context.superPreviousThirdWord
    local score=0
    if p3 and p2 and p1 then
        score=score+SmoothedContextScore(store.fourgrams and store.fourgrams[FourgramKey(p3,p2,p1)],word,5200)
    end
    if p2 and p1 then
        score=score+SmoothedContextScore(store.trigrams and store.trigrams[TrigramKey(p2,p1)],word,3000)
    end
    if p1 then
        score=score+SmoothedContextScore(store.bigrams and store.bigrams[p1],word,1350)
    end
    local unigram=PersonalUnigramCount(store,word)
    score=score+math.min(520,math.log(1+unigram)*140)
    return score
end

local function SuperSessionScore(session,context,word)
    if not session then return 0 end
    local p1,p2,p3=context.superPreviousWord,context.superPreviousPreviousWord,context.superPreviousThirdWord
    local score=0
    if p3 and p2 and p1 then score=score+SessionContextScore(session,session.fourgrams,FourgramKey(p3,p2,p1),word,3300) end
    if p2 and p1 then score=score+SessionContextScore(session,session.trigrams,TrigramKey(p2,p1),word,2100) end
    if p1 then score=score+SessionContextScore(session,session.bigrams,p1,word,950) end
    score=score+SessionEntryScore(session,session.unigrams[word],360)
    return score
end

local function SuperCurrentMessageScore(context,word)
    local count=context.currentWordCounts and (context.currentWordCounts[word] or 0) or 0
    if count<=0 then return 0 end
    local last=context.currentWordLast and (context.currentWordLast[word] or 0) or 0
    local age=math.max(0,(context.currentWordOrdinal or 0)-last)
    return math.min(640,count*170) * (1/(1+age*0.12))
end

local function SuperRightContextScore(store,session,context,word)
    local nextWord=context.nextWord
    if not nextWord then return 0 end
    local score=0
    if store then
        score=score+SmoothedContextScore(store.bigrams and store.bigrams[word],nextWord,1000)
        if context.superPreviousWord then
            score=score+SmoothedContextScore(store.trigrams and store.trigrams[TrigramKey(context.superPreviousWord,word)],nextWord,1700)
        end
    end
    local sb,st=BuildSuperSeedNgrams()
    score=score+SmoothedContextScore(sb[word],nextWord,360)
    if context.superPreviousWord then score=score+SmoothedContextScore(st[TrigramKey(context.superPreviousWord,word)],nextWord,620) end
    if session then
        score=score+SessionContextScore(session,session.bigrams,word,nextWord,650)
        if context.superPreviousWord then
            score=score+SessionContextScore(session,session.trigrams,TrigramKey(context.superPreviousWord,word),nextWord,1100)
        end
    end
    return score
end

local function ApplySuperScoring(self,candidates,store,context,session)
    for word,data in pairs(candidates) do
        local bonus=0
        bonus=bonus+SuperPersistentScore(store,context,word)
        bonus=bonus+SuperStaticScore(context,word)
        bonus=bonus+SuperSessionScore(session,context,word)
        bonus=bonus+SuperCurrentMessageScore(context,word)
        bonus=bonus+SuperRightContextScore(store,session,context,word)

        -- When a long context is available, avoid generic high-frequency words drowning out
        -- a clearly learned phrase continuation. This is a soft penalty, never a hard filter.
        if context.superPreviousPreviousWord and bonus<180 then bonus=bonus-90 end
        if context.atWordBoundary and bonus>900 then bonus=bonus+240 end
        if context.superPreviousWord==word and bonus<1200 then bonus=bonus-180 end
        data.score=data.score+bonus
        data.superBonus=bonus
    end
end

function FSC:GetStandardAutocompleteSuggestions(text,cursor,limit)
    limit=limit or AUTOCOMPLETE_LIMIT
    local context=self:GetAutocompleteContext(text,cursor)
    if context.suppressed then return {},context end
    local store=self:IsPersonalizationEnabled() and EnsureAutocompleteStore(self) or nil
    local candidates=BuildStandardCandidateMap(self,context,store)
    return RankCandidateMap(candidates,limit),context
end

function FSC:GetSuperAutocompleteSuggestions(text,cursor,limit)
    limit=limit or AUTOCOMPLETE_LIMIT
    local context=self:GetAutocompleteContext(text,cursor)
    if context.suppressed then return {},context end
    local store=self:IsPersonalizationEnabled() and EnsureAutocompleteStore(self) or nil
    local session=EnsureSuperSession(self)
    local dictionarySignature=self:GetDictionaryStateSignature()
    local cacheKey=table.concat({
        tostring(limit),context.prefix or "",context.superPreviousThirdWord or "",context.superPreviousPreviousWord or "",
        context.superPreviousWord or "",context.nextWord or "",tostring(context.atWordBoundary),
        tostring(context.cursor or 0),context.text or "",tostring(session.serial or 0),dictionarySignature
    },"\31")
    if self.superPredictionCacheKey==cacheKey and self.superPredictionCacheResults then
        local copy={}
        for i=1,math.min(limit,#self.superPredictionCacheResults) do copy[i]=self.superPredictionCacheResults[i] end
        return copy,context
    end

    local candidates=BuildStandardCandidateMap(self,context,store)
    AddSuperContextCandidates(self,candidates,store,context,session)
    AddSuperRecencyPrefixCandidates(self,candidates,store,context,session)
    AddCurrentMessagePrefixCandidates(self,candidates,store,context)
    ApplySuperScoring(self,candidates,store,context,session)
    local results=RankCandidateMap(candidates,limit)
    self.superPredictionCacheKey=cacheKey
    self.superPredictionCacheResults=results
    local copy={}
    for i=1,math.min(limit,#results) do copy[i]=results[i] end
    return copy,context
end

function FSC:GetAutocompleteSuggestions(text,cursor,limit)
    if self:IsSuperSuggestionsEnabled() then
        return self:GetSuperAutocompleteSuggestions(text,cursor,limit)
    end
    return self:GetStandardAutocompleteSuggestions(text,cursor,limit)
end

return FSC

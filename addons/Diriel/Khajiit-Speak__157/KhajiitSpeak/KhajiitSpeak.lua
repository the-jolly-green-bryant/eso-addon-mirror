
local KS = {}
KS.name = "Khajiit Speak"
KS.version = "1.17"
KS.svVersion = 117
KS.svName = "KjtSpk_PstntVars"
KS.author = "Diriel"
KS.website = "https://www.esoui.com/downloads/info157-KhajiitSpeak.html"

local ksPrefix = "["..KS.name.."]"

--Config?
local fluffyQuestionsA = 
{
	'I is wondering%s',
	'I is curious%s',
	'Please indulge me,',
	'You will indulge me%s',
	'Hmm...',
	'Hmm...', --Two, for double the chance. =P
	'Tell me,',
	'You will tell me%s',
	'Forgive me for asking, but',
	'Forgive me, but',
	--'I apologise for asking, but', --Too much. Too much.
	'I would like to know%s',
	'Please tell me%s',
	'I must know%s',
	'You must tell me%s',
	'Please answer me%s',
	'Answer me%s'
}

local fluffySuffix = 
{
	'.',
	'...',
	','
	--', yes?', --Felt kind of weird whenever it came up.
	--', no?' --Same.
}

local fluffyYes =
{
	--'I\'m pleased to say yes', --Isn't neutral enough to work everywhere.
	'I is going to say yes',
	'I can only say yes',
	'I can easily say yes',
	
	'Uhm... Yes',
	'Let me think... Yes',
	'I is thinking... Yes'
}

local fluffyNo =
{
	'I is afraid not',
	'I is going to say no',
	'I have to say no',
	'My only choice is to say no',
	
	'Uhm... No',
	'Let me think... No',
	'I is thinking... No'
}

local fluffyGoodbye =
{
	'%s must go now.',
	'%s must go.',
	'%s is going now.',
	'%s is leaving now.',
	'%s must leave.',
	
	'%s must stop talking.',
	'%s can talk no longer.',
	'%s can talk no more.',
	'%s will speak no more.',
	'%s has had enough talk.',
	'%s will talk more later.',
	'%s tires of this talk.',
	
	'%s\'s ears grow tired of this.',
	'%s\'s tongue grows tired now.'
}

local blanketReplace = 
{
	['Azura'] = 'Azurah',
	['Lorkhan'] = 'Lorkhaj',
	['Mehrunes Dagon'] = 'Merrunz',
	['Stendarr'] = 'S\'rendarr',
	['Sheogorath'] = 'Sheggorath',
	
	['(to)(%p)'] = 'to do so%2',
	
	['([Tt])(hanks)'] = "%1hank you",
	
	['Me either.'] = "I does not either.",
	['Me neither.'] = "Neither do I."
}

local wordReplaceRandom = --These are mainly examples right now. Will flesh them out as I go in future updates.
{
	['(steal)(s?)'] = {
		'pilfer%2',
		'take ownership of',
		'acquire%2',
		'procure%2'
	},
	['(hand)(s?)'] = {
		'paw%2'
	},
	['(fist)(s?)'] = {
		'paw%2',
		'claws'
	},
	['foot'] = {
		'paw'
	},
	['feet'] = {
		'paws'
	},
	
	['[Tt]hank you'] = {
		'I thank you'
	}
}

local weighting = --Format: ['word'] = <-100 - 100 weight percentage>. Weighting is done before any conversion of the line, so contractions should be included.
{
	['no'] = -25, --Negative or formal words
	['can\'t'] = -25,
	['couldn\'t'] = -25,
	['won\'t'] = -25,
	['wouldn\'t'] = -25,
	['don\'t'] = -25,
	['wrong'] = -25,
	['bad'] = -25,
	['not'] = -15,
	['sad'] = -10,
	['unhappy'] = -10,
	['please'] = -5,
	
	['yes'] = 25, --Positive or informal words
	['can'] = 25,
	['could'] = 25,
	['will'] = 25,
	['right'] = 25,
	['good'] = 25,
	['would'] = 20,
	['happy'] = 15,
	['like'] = 15,
	['pleased'] = 10,
	['want'] = 5
}

--Grammar parsing rules config.
local fragments =
{
	['who'] = true,
	['what'] = true,
	['where'] = true,
	['when'] = true,
	['why'] = true,
	['how'] = true,
	['do'] = true,
	['does'] = true,
	['did'] = true,
	['for'] = true,
	['if'] = true,
	['is'] = true,
	['be'] = true,
	['am'] = true,
	['are'] = true,
	['will'] = true,
	['would'] = true,
	['could'] = true,
	['can'] = true,
	['may'] = true,
	['has'] = true,
	['was'] = true,
	['should'] = true,
	['and'] = true,
	['have'] = true,
	['the'] = true,
	['then'] = true,
	['this'] = true,
	['that'] = true,
	['these'] = true,
	['those'] = true,
	['any'] = true,
	['anything'] = true,
	['exactly'] = true,
	['before'] = true,
	['with'] = true,
	['must'] = true,
	
	['here'] = true,
	['there'] = true,
	['anywhere'] = true, --Lol
	
	['before'] = true,
	['still'] = true,
	['clearly'] = true,
	['really'] = true,
	['definitely'] = true,
	['distinctly'] = true,
	['never'] = true,
	['just'] = true,
	['not'] = true,
	
	['worry'] = true,
	
	['he'] = true,
	['she'] = true,
	['his'] = true,
	['her'] = true,
	['you'] = true,
	['your'] = true,
	['me'] = true,
	['we'] = true,
	['they'] = true,
	['it'] = true,
	
	['i'] = true,
	['i\'ll'] = true,
	['i\'m'] = true,
	['we'] = true,
	['we\'ll'] = true
}

local fragmentExceptions = --Used for exceptions to certain rules. Damn you, English!
{
	['who'] = true,
	['where'] = true,
	--['when'] = true, Shouldn't be here?
	['why'] = true,
	['how'] = true,
	['can'] = true,
	['may'] = true,
	['will'] = true,
	['would'] = true,
	['may'] = true,
	['does'] = true,
	['not'] = true,
	['do'] = true,
	['should'] = true,
	['did'] = true,
	['must'] = true,
	
	['which'] = false,
	['and'] = false,
	['before'] = false,
	['still'] = false,
	['clearly'] = false,
	['already'] = false,
	['really'] = false,
	['definitely'] = false,
	['distinctly'] = false,
	['officially'] = false,
	['never'] = false,
	['just'] = false,
	['only'] = false
}

local nxtWrdExceptions = --Used for mainly honorifics like "My Queen"
{
	['queen'] = true,
	['king'] = true,
	['liege'] = true,
	['lord'] = true,
	['lady'] = true,
	['master'] = true,
	['mistress'] = true
}

local contConv = --Used for exceptions in converting contractions. Why does English have so many exceptions? ;w;
{
	['do'] = true,
	['does'] = true,
	['be'] = true,
	['it'] = true,
	['he'] = true,
	['she'] = true,
	['his'] = true,
	['her'] = true,
	['you'] = true,
	['me'] = true,
	['we'] = true,
	['they'] = true,
	['have'] = true,
	
	['that'] = true,
	
	['there'] = true,
	
	--['the'] = true,
	
	['i'] = true,
	['i\'ll'] = true,
	['i\'m'] = true,
	['we'] = true,
	['we\'ll'] = true
}

local contDblRef = --EEEENGLISH... This is a case-by-case contraction fix for references to things that use two words. Eg; "Dark Brotherhood"
{
	['dark'] = {
		['brotherhood'] = false,
		['forest'] = false --(This is an example)
	},
	['fort'] = {
		['walls'] = false
	}
}

--Not config
local origPopOpts = INTERACTION.PopulateChatterOption
local gpOrigPopOpts = ZO_GamepadInteraction.PopulateChatterOption

local khajiitRace = GetUnitRace("player")
local khajiitName = GetUnitName("player")
local khajiitNameFirst = khajiitName:sub(0, (khajiitName:find(" ") or (zo_strlen(khajiitName)+1))-1)
local khajiitGender = GetUnitGender("player")
local config = -- <--Not config indeed.
{
	enabled = (khajiitRace == "Khajiit"),
	useName = true,
	useRace = true,
	dynRace = false,
	fluffChance = 0.33,
	fluffBye = 1,
	fullName = false,
	
	wordSubbing = true,
	lineWeighting = true,
	impolitePnoun = true,
	
	nickName = "",
	alwaysNick = false
}

local rand = 0;
local lastRand = -1
local lastQRand = -1
local lineWeight = 0.0

local function KjtSpk_Round(num)
  return math.floor(num + 0.5)
end
local function KjtSpk_Clamp(num, minimum, maximum)
	if num < minimum then
		num = minimum
	elseif num > maximum then
		num = maximum
	end
	return num
end

local function KjtSpk_TrimJunk(str)
	return str:gsub('^%A*(.-)%A*$', '%1')
end
local function KjtSpk_FrstChrCase(str, case)
	if case then
		return str:sub(1,1):upper()..str:sub(2)
	end
	return str:sub(1,1):lower()..str:sub(2)
end
local function KjtSpk_Replace(str, s, e, rep)
	return str:sub(1,s-1)..rep..str:sub(s+e)
end

local function KjtSpk_GenSeed(str)
	local result = 0
	
	for i=1, zo_strlen(str) do
		result = result + str:sub(i, i):byte()
	end
	
	return result
end
local function KjtSpk_GenGndr(t)
	if khajiitGender == 1 then
		if t == 0 then
			return "she"
		else
			return "her"
		end
	elseif khajiitGender == 2 then
		if t == 0 then
			return "he"
		elseif t == 1 then
			return "him"
		elseif t == 2 then
			return "his"
		end
	end
	return "it" --Sanity check, because I'm rarely sane.
end
local function KjtSpk_GenPnoun(reqUpr, weight, ignoreRepeats)
	
	local name = khajiitNameFirst
	if config.fullName == true then
		name = khajiitName
	end
	
	weight = weight or 0.0
	
	local nickChance = math.random() + weight
	if (nickChance > 0.5 or config.alwaysNick) and not(config.nickName == "") then
		name = config.nickName
	end
	
	rand = math.random() + weight
	
	--rand = rand + weight
	
	if lastRand == 2 then ignoreRepeats = true end
	
	if rand < 0.333 then
		if ((lastRand <= 0.0) or (lastRand >= 0.333)) or ignoreRepeats then
			result = khajiitRace
		else
			result = "this one"
		end
	elseif rand < 0.666 then
		if ((lastRand < 0.333) or (lastRand >= 0.666)) or ignoreRepeats then
			result = "this one"
			
		else
			result = name
		end
	else
		if (lastRand <= 0.666) or ignoreRepeats then
			result = name
		else
			result = khajiitRace
		end
	end
	
	lastRand = rand
	
	if (not config.useName) and (result == name) then
		if (rand >= 0.5) and config.useRace then
			result = khajiitRace
		else
			result = "this one"
		end
	end
	if (not config.useRace) and ((result == khajiitRace) or (result == "Khajiit")) then
		if (rand >= 0.5) and config.useName then
			result = name
		else
			result = "this one"
		end
	end
	if (not config.dynRace) and (result == khajiitRace) then
		result = "Khajiit"
	end
	
	if (result == "this one") and reqUpr then
		result = KjtSpk_FrstChrCase(result, true)
	end
	return result
end

local function KjtSpk_GetNxtWrd(str, index)
	local length = zo_strlen(str)
	local nxtS = str:find('%s+', index) or index
	local endS = str:find('%s+', nxtS+1) or length
	
	if str:sub(endS, endS) == ' ' and endS < length then
		endS = endS-1
	end
	return str:sub(nxtS+1, endS), endS
end

local function KjtSpk_IsFragment(val, searchMode, extra)
	val = val:lower()
	local hasApos = val:find('\'')
	if hasApos then
		val = val:sub(1, hasApos-1)
	end
	
	if ((not searchMode) or (searchMode == 0)) and fragments[val] ~= nil then
		return true
	elseif searchMode == 1 and fragmentExceptions[val] ~= nil then
		return true
	elseif searchMode == 2 and contConv[val] ~= nil then
		return true
	elseif searchMode == 3 and contDblRef[val] ~= nil then
		extra = extra or ""
		if contDblRef[val][extra] ~= nil then
			return true
		end
	end
	return false
end

local function KjtSpk_InsFluff(str, ins, where)
	local partB = str:sub(where, str:len())
	local pBFind = partB:find(" ")
	local fWrd = ""
	if pBFind then
		fWrd = partB:sub(1, pBFind-1)
	else
		fWrd = partB:sub(1, -2)
	end
	
	local lChr = ins:sub(-1)
	local caps = ((lChr == '.') or (fWrd:lower() == "i") or fWrd:find('\'')) --Or or or or or or or or or or or or or or or
	return str:sub(1,where-1)..ins..' '..KjtSpk_FrstChrCase(partB, caps)
end

local function KjtSpk_UndoNtCont(str, cont, rep) --Khajiit hates contractions, very much!
	rep = rep or cont:sub(5, -4)
	
	local cLen = zo_strlen(cont)-4
	local rLen = zo_strlen(rep)
	local test = str:find(cont)
	if test ~= nil then
		while test do
			local initTest = str:sub(test+cLen+1, test+cLen+1)
			if (initTest == '!') or (initTest == '.') or (initTest == '?') or (initTest == ',') then
				str = KjtSpk_Replace(str, test+1, cLen, rep.." not")
			else
				str = KjtSpk_Replace(str, test+1, cLen, rep)
				local notPoint = str:find(' ', test) or zo_strlen(str)
				local nxtWrd = KjtSpk_GetNxtWrd(str, notPoint-rLen)
				local nxtWrdSuffix = nxtWrd:sub(-1)
				if KjtSpk_IsFragment(nxtWrd, 2) or ((nxtWrdSuffix == '!') or (nxtWrdSuffix == '.') or (nxtWrdSuffix == '?') or (nxtWrdSuffix == ',')) then
					if nxtWrd == 'have' or nxtWrd == 'has' or nxtWrd == 'do' or nxtWrd == 'does' then
						str = KjtSpk_Replace(str, notPoint, 0, " not")
					elseif nxtWrd == 'be' or ((nxtWrdSuffix == '!') or (nxtWrdSuffix == '.') or (nxtWrdSuffix == '?') or (nxtWrdSuffix == ',')) then
						str = KjtSpk_Replace(str, test + rLen +1, 0, " not")
					else
						str = KjtSpk_Replace(str, notPoint+(zo_strlen(nxtWrd)+1), 0, " not")
					end
				else
					notPoint = str:find(' %l', test) or zo_strlen(str)
					nxtWrd = KjtSpk_GetNxtWrd(str, notPoint-rLen)
					
					if KjtSpk_IsFragment(nxtWrd) then
						--Mini word sweep
						local nRes = -1
						local eIndx = notPoint+1 --+zo_strlen(nxtWrd)
						local sStr = str:sub(eIndx, -2)
						
						for s in sStr:gmatch("%S+") do
							local suffix = s:sub(-1)
							local lnxtWrd = KjtSpk_GetNxtWrd(str, eIndx)
							
							--local first = s:sub(1, 1)
							--if ((suffix == '!') or (suffix == '.') or (suffix == '?') or (suffix == ',')) or (not KjtSpk_IsFragment(s) and first == first:lower()) then --Old check. Capitolized words were invalid for not placement.
							
							if ((suffix == '!') or (suffix == '.') or (suffix == '?') or (suffix == ',')) or (not KjtSpk_IsFragment(s) and not KjtSpk_IsFragment(s:lower(), 3, lnxtWrd:lower())) then
								nRes = eIndx + zo_strlen(s) --NOTE: Recently added " + zo_strlen(s)" Keep an eye on.
								break
							end
							eIndx = eIndx + zo_strlen(s) + 1
						end
						
						if nRes ~= -1 then
							str = KjtSpk_Replace(str, nRes, 0, " not")
						else
							notPoint = str:find(' %l', test+1 --[[zo_strlen(nxtWrd)]]) or zo_strlen(str)
							str = KjtSpk_Replace(str, notPoint, 0, " not")
						end
					else
						str = KjtSpk_Replace(str, notPoint, 0, " not")
					end
				end
			end
			
			test = str:find(cont)
		end
	end
	return str
end

--When did this all get so messy? @_@
local function KjtSpk_ParseLine(str, gamepad, dbg)
	local result = ""
	
	lastRand = 2;
	math.randomseed(math.floor(KjtSpk_GenSeed(str)/2))
	math.random() --Pop one random, first is always dodgy.
	
	if (str ~= "Goodbye.") then
		
		lineWeight = 0.0
		if config.lineWeighting then
			local strLwr = str:lower()
			for k, v in pairs(weighting) do
				local wrdCount = 0
				for i in strLwr:gmatch(k.."%A") do
					wrdCount = wrdCount + 1
				end
				lineWeight = KjtSpk_Clamp(lineWeight + (wrdCount * (v/100)), -1.0, 1.0)
			end
			strLwr = nil
		end
		
		--Khajiitify Contractions (Note to self: Make this MUCH less... Overhead-ie.)
		if str:find("'s") then
			local sWrd = "is"
			if str:find("been") or str:find("[Ww]hat's he") or str:find("[Ww]hat's she") then
				sWrd = "has"
			end
			
			str = str:gsub("[Ww]hen's", function(wrd) return wrd:sub(1, 1).."hen "..sWrd end)
			str = str:gsub("[Ww]here's", function(wrd) return wrd:sub(1, 1).."here "..sWrd end)
			str = str:gsub("[Ww]hy's", function(wrd) return wrd:sub(1, 1).."hy "..sWrd end)
			str = str:gsub("[Ww,Tt]hat's", function(wrd) return wrd:sub(1, 1).."hat "..sWrd end)
			str = str:gsub("[Hh]ow's", function(wrd) return wrd:sub(1, 1).."ow "..sWrd end)
			str = str:gsub("[Ww]ho's", function(wrd) return wrd:sub(1, 1).."ho "..sWrd end)
			str = str:gsub("[Ii]t's", function(wrd) return wrd:sub(1, 1).."t "..sWrd end)
			str = str:gsub("[Ll]et's", function(wrd) return wrd:sub(1, 1).."et us" end)
			str = str:gsub("[Hh]ere's", function(wrd) return wrd:sub(1, 1).."ere is" end)
		end
		if str:find("'t") then
			str = KjtSpk_UndoNtCont(str, "[Cc]an't", 'an')
			str = KjtSpk_UndoNtCont(str, "[Ww]on't", 'ill')
			str = KjtSpk_UndoNtCont(str, "[Ss]houldn't")
			str = KjtSpk_UndoNtCont(str, "[Ww]ouldn't")
			str = KjtSpk_UndoNtCont(str, "[Aa]ren't")
			str = KjtSpk_UndoNtCont(str, "[Dd]on't")
			str = KjtSpk_UndoNtCont(str, "[Dd]oesn't")
			str = KjtSpk_UndoNtCont(str, "[Ii]sn't")
			str = KjtSpk_UndoNtCont(str, "[Hh]asn't")
			str = KjtSpk_UndoNtCont(str, "[Hh]aven't")
			str = KjtSpk_UndoNtCont(str, "[Ww]eren't")
		end
		if str:find("'re") then
			str = str:gsub("[Yy]ou're", function(wrd) return wrd:sub(1, 1).."ou are" end)
			str = str:gsub("[Tt]hey're", function(wrd) return wrd:sub(1, 1).."hey are" end)
			str = str:gsub("[Ww]e're", function(wrd) return wrd:sub(1, 1).."e are" end)
		end
		if str:find("'ll") then
			str = str:gsub("[Ww]e'll", function(wrd) return wrd:sub(1, 1).."e will" end)
			str = str:gsub("[Yy]ou'll", function(wrd) return wrd:sub(1, 1).."ou will" end)
			str = str:gsub("[Ww]hat'll", function(wrd) return wrd:sub(1, 1).."hat will" end)
		end
		if str:find("'ve") then
			str = str:gsub("[Yy]ou've", function(wrd) return wrd:sub(1, 1).."ou have" end)
			str = str:gsub("[Ww]e've", function(wrd) return wrd:sub(1, 1).."e have" end)
		end
		if str:find("'d") then
			str = str:gsub("[Hh]ow'd", function(wrd) return wrd:sub(1, 1).."ow did" end)
		end
		
		--Make questions more Khajiiti
		rand = math.random()
		local qLength = str:len()
		local qFind = str:find('%?', qLength - math.ceil((rand * qLength)/2))
		if qFind and (qLength > 10) then --Leave short and snappy questions alone.
			local backwardness = str:reverse()
			local bkwrdSPnt = (qLength - qFind) +2
			local eFind = backwardness:find(' [%.%?!%]>]', bkwrdSPnt)
			
			if eFind then
				eFind = (qLength - eFind)+2
			else
				eFind = 1
			end
			
			local fWrd = str:sub(eFind, (str:find("%s", eFind+1) or (eFind+1))-1)
			if (fWrd:lower() == "do") and (not str:find("any", eFind) and not str:find("not", eFind) and not str:find(",", eFind)) then --Flippy around type Khajiit questions B.
				local prefix = ""
				if eFind > 1 then
					prefix = str:sub(1, eFind-1)
				end
				str = prefix..KjtSpk_FrstChrCase(str:sub(eFind+3, qFind-1), true)..", yes"..str:sub(qFind)
			elseif ((fWrd:lower() == "is") or (fWrd:lower() == "are") or (fWrd:lower() == "am") or (fWrd:lower() == "would") or (fWrd:lower() == "will") or (fWrd:lower() == "can") or (fWrd:lower() == "may")) and (not str:find("any", eFind) and not str:find("not", eFind) and not str:find(",", eFind)) then --Flippy around type Khajiit questions A.
				local nxtS = str:find(' ', eFind) or eFind
				local wrdA = str:sub(eFind, nxtS-1)
				local wrdB = str:sub(nxtS+1, str:find(' ', nxtS+1)-1)
				
				local prefix = ""
				if eFind > 1 then
					prefix = str:sub(1, eFind-1)
				end
				
				str = prefix..KjtSpk_FrstChrCase(wrdB, true)..str:sub((nxtS+zo_strlen(wrdB))+1, qFind-1)..", yes"..str:sub(qFind)
				
				local wrdAPoint = str:find(' ', eFind) or zo_strlen(str)
				local nxtWrd = KjtSpk_GetNxtWrd(str, wrdAPoint)
				local nxtWrdSuffix = nxtWrd:sub(-1)
				
				if KjtSpk_IsFragment(nxtWrd, 1) or ((nxtWrdSuffix == '!') or (nxtWrdSuffix == '.') or (nxtWrdSuffix == '?') or (nxtWrdSuffix == ',')) then
					str = KjtSpk_Replace(str, wrdAPoint+1, 0, wrdA:lower()..' ')
				else
					--wrdAPoint = str:find(' %l', eFind) or zo_strlen(str)
					nxtWrd = KjtSpk_GetNxtWrd(str, wrdAPoint)
					
					if (wrdB ~= "he" and wrdB ~= "she" and wrdB ~= "you" and wrdB ~= "I" and wrdB ~= "me" and wrdB ~= "my") and not KjtSpk_IsFragment(nxtWrd) then
						--Mini word sweep
						local nRes = -1
						local eIndx = wrdAPoint+zo_strlen(nxtWrd)+2
						local sStr = str:sub(eIndx, -2)
						for s in sStr:gmatch("%S+") do
							local suffix = s:sub(-1)
							if (suffix == '!') or (suffix == '.') or (suffix == '?') then -- or (suffix == ',')
								nRes = eIndx
								break
							elseif KjtSpk_IsFragment(s) then
								nRes = eIndx + zo_strlen(s)+1
								break
							end
							eIndx = eIndx + zo_strlen(s)+1
						end
						
						if nRes ~= -1 then
							str = KjtSpk_Replace(str, nRes, 0, wrdA:lower()..' ')
						else
							str = KjtSpk_Replace(str, wrdAPoint+1, 0, wrdA:lower()..' ')
						end
					else
						if KjtSpk_IsFragment(wrdB) and not(KjtSpk_IsFragment(wrdB, 2)) then
							nxtS = str:find(' ', wrdAPoint+1) or eFind
							str = KjtSpk_Replace(str, nxtS+1, 0, wrdA:lower()..' ')
						else
							str = KjtSpk_Replace(str, wrdAPoint+1, 0, wrdA:lower()..' ')
						end
					end
				end
			elseif (rand < config.fluffChance) and eFind <= 1 then --Other questions, generic fluff. NOTE: Recently added eFind <= 1. Keep an eye on it.
				if not str:sub(eFind, qFind):find(',') then --Ignore questions that have commas in them. They get all run-on-y.
					if (str:sub(eFind, eFind+2):lower() ~= "and") and (str:sub(eFind, eFind) ~= '"') then --Don't do this if the question starts with "And."
						if str:sub(eFind, eFind+1):lower() == "so" then --Remove any "So" or "Then" from the start of the question, fluff serves the same purpose.
							str = str:sub(eFind+3)
						elseif str:sub(eFind, eFind+3):lower() == "then" then
							str = str:sub(eFind+5)
						end
						
						local pick = KjtSpk_Round(math.random() * (#fluffyQuestionsA - 1))+1
						if pick == lastQRand then
							if pick == #fluffyQuestionsA then
								pick = pick -1
							else
								pick = pick +1
							end
						end
						local fluff = (fluffyQuestionsA[pick]:format(fluffySuffix[KjtSpk_Round(math.random() * (#fluffySuffix - 1))+1]))
						if fluff:sub(-3) == '...' then
							proMatchSO = 0
						end
						str = KjtSpk_InsFluff(str, fluff, eFind)
						lastQRand = pick
					end
				end
			end
		end
		
		--Some yes/no garbling.
		rand = math.random()
		if rand < config.fluffChance then
			if str:find("No%A") then
				local pick = KjtSpk_Round(math.random() * (#fluffyNo - 1))+1
				str = str:gsub("(No)(%A)", (fluffyNo[pick])..'%2')
			elseif str:find("Yes%A") then
				local pick = KjtSpk_Round(math.random() * (#fluffyYes - 1))+1
				str = str:gsub("(Yes)(%A)", (fluffyYes[pick])..'%2')
			end
		end
		
		--Word subbing
		local randHolding = math.random() --This is to stop sentence seeding changing whenever more random word subs are added.
		if config.wordSubbing then
			--[[if lineWeight < 0.0 then --This was moved to the pronoun sweep.
				str = str:gsub("(%A)(you)(%A)", "%1it%3")
			end]]
			
			for k, v in pairs(blanketReplace) do
				str = str:gsub(k, v)
			end
			
			for k, v in pairs(wordReplaceRandom) do
				if math.random() < (config.fluffChance*1.5) then
					local find, wrdEnd = str:find(k..'%A')
					if find then
						local suffix = str:sub(wrdEnd, wrdEnd)
						
						str = str:gsub(k..suffix, v[KjtSpk_Round(math.random() * (#v - 1))+1]..suffix)
					end
				end
			end
		end
		
		rand = randHolding
		--Personal Pronouns Sweep
		if str:find('I') or str:find('[Mm][ey]') or (config.impolitePnoun and lineWeight < 0.0 and str:find('[Yy]ou')) then
			local proMatchS = false
			local proMatchSO = 0
			local proMatchLWA = false
			local proMatchLWB = false
			local proUsed = false
			local tProUsed = false
			local newSentence = true
			
			local lWrd = ""
			local lWrdIndx = 1
			local slWrd = ""
			
			local wrkStr = ""
			local wrkIndx = 0
			local maxIndx = zo_strlen(str)
			
			local function checkPrevWrd(origWrd) --Eeww, nested function! Think of a less AWFUL way to do this, me!
				if proMatchLWB then
					--Previous word fixup
					local lWrdSuffix = lWrd:sub(-1, -1)
					if lWrdSuffix:find("%p") then
						lWrd = lWrd:sub(1, -2)
					end
					
					if lWrd:lower() == "do" and lWrdSuffix ~= "," then
						result = KjtSpk_Replace(result, lWrdIndx+1, 1, "oes")
						proMatchLWB = false
					elseif lWrd:lower() == "am" then
						if lWrd:sub(1, 1) == "A" then
							result = KjtSpk_Replace(result, lWrdIndx, 2, "Is")
						else
							result = KjtSpk_Replace(result, lWrdIndx, 2, "is")
						end
						proMatchLWB = false
					elseif lWrd:lower() == "are" then
						if lWrd:sub(1, 1) == "A" then
							result = KjtSpk_Replace(result, lWrdIndx, 3, "Is")
						else
							result = KjtSpk_Replace(result, lWrdIndx, 3, "is")
						end
						proMatchLWB = false
					elseif lWrd:lower() == "have" and KjtSpk_IsFragment(origWrd) then
						result = KjtSpk_Replace(result, lWrdIndx+1, 3, "as")
						proMatchLWB = false
					elseif lWrd:lower() == "should" then
						proMatchLWB = false
					elseif lWrd:lower() == "can" then
						proMatchLWB = false
					end
				end
			end
			
			local prevOptR = config.useRace
			if str:lower():find('khajiit') then config.useRace = false end
			local prevOptN = config.useName
			if str:lower():find(khajiitName) then config.useName = false end
			
			--GetFirstWord for pronoun loop
			local firstSpace = str:find(' ', 1) or maxIndx
			if str:sub(firstSpace, firstSpace) == ' ' and firstSpace < maxIndx then
				firstSpace = firstSpace-1
			end
			wrkStr = str:sub(1, firstSpace)
			
			local lastIndx = -1 --Let's just make sure the loop doesn't stall. Whiles are scary and I hate them.
			while wrkIndx < maxIndx do
				if lastIndx > -1 then --Hey look, it's actually useful for skipping the first loop here anyway.
					if firstSpace >= maxIndx then
						break
					end
					wrkStr, wrkIndx = KjtSpk_GetNxtWrd(str, wrkIndx+1)
				end
				
				if lastIndx >= wrkIndx then
					--With any luck, this will never ever happen. x3
					result = "KhajiitSpeak has encounted a critical error, please disable the addon and report the line of text that caused this! "
					break
				end
				
				local suffix = wrkStr:sub(-1)
				local validSuffix = (suffix == '!') or (suffix == '.') or (suffix == '?') or (suffix == ')') or (suffix == ']')
				if validSuffix then
					if wrkStr:sub(-3) == '...' then
						wrkStr = wrkStr:sub(1, -4)
						suffix = '...'
					else
						wrkStr = wrkStr:sub(1, -2)
					end
				else
					if suffix == ',' then
						wrkStr = wrkStr:sub(1, -2)
					else
						suffix = ""
					end
				end
				
				--Get next word for processing.
				local nxtWrd = KjtSpk_TrimJunk(KjtSpk_GetNxtWrd(str, wrkIndx):lower())
				
				--Nasty IfElse chain incoming.
				if nxtWrdExceptions[nxtWrd] == nil then --Disallow changing pronouns before an honorific title.
					if config.impolitePnoun and lineWeight < 0.0 and wrkStr:lower() == "you" then
						if wrkStr:sub(1, 1) == "Y" then
							wrkStr = 'It'
						else
							wrkStr = 'it'
						end
						proMatchLWA, proMatchLWB = true, true
						checkPrevWrd("you")
					elseif wrkStr == "I" then
						if (proMatchSO > 0) and (not tProUsed) then
							wrkStr = KjtSpk_GenGndr(0)
							if (not KjtSpk_IsFragment(lWrd)) or (lWrd == "") or (fragmentExceptions[lWrd:lower()] == nil) or (fragmentExceptions[lWrd:lower()] == false) then proMatchLWA = true end
							proMatchLWB, proUsed = true, true
						else
							wrkStr = KjtSpk_GenPnoun(newSentence, lineWeight)
							if (not KjtSpk_IsFragment(lWrd)) or (lWrd == "") or (fragmentExceptions[lWrd:lower()] == nil) or (fragmentExceptions[lWrd:lower()] == false) then proMatchLWA = true end
							proMatchS, proMatchSO, proMatchLWB = true, 1, true
						end
						checkPrevWrd("I")
					elseif wrkStr == "I'm" then
						if (proMatchSO > 0) and (not tProUsed) then
							wrkStr = KjtSpk_GenGndr(0).." is"
							proMatchLWA, proMatchLWB, proUsed = true, true, true
						else
							wrkStr = KjtSpk_GenPnoun(newSentence, lineWeight).." is"
							proMatchS, proMatchSO = true, 1
						end
						checkPrevWrd("I'm")
					elseif wrkStr == "I'll" then --NOTE: Maybe give this a chance of being "shall" as well as "will"
						if (proMatchSO > 0) and (not tProUsed) then
							wrkStr = KjtSpk_GenGndr(0).." will"
							proUsed = true
						else
							wrkStr = KjtSpk_GenPnoun(newSentence, lineWeight).." will"
							proMatchS, proMatchSO = true, 1
						end
						checkPrevWrd("I'll")
					elseif wrkStr == "I've" then
						if (proMatchSO > 0) and (not tProUsed) then
							wrkStr = KjtSpk_GenGndr(0).." has"
							proUsed = true
						else
							wrkStr = KjtSpk_GenPnoun(newSentence, lineWeight).." has"
							proMatchS, proMatchSO = true, 1
						end
						checkPrevWrd("I've")
					elseif wrkStr == "I'd" then
						if (proMatchSO > 0) and (not tProUsed) then
							wrkStr = KjtSpk_GenGndr(0).." would"
							proUsed = true
						else
							wrkStr = KjtSpk_GenPnoun(newSentence, lineWeight).." would"
							proMatchS, proMatchSO = true, 1
						end
						checkPrevWrd("I'd")
					elseif wrkStr:lower() == "me" then
						if (proMatchSO > 0) and (not tProUsed) then
							wrkStr = KjtSpk_GenGndr(1)
							proUsed = true
						else
							wrkStr = KjtSpk_GenPnoun(newSentence, lineWeight)
							proMatchS, proMatchSO = true, 1
						end
						checkPrevWrd("me")
					elseif wrkStr:lower() == "my" then
						if (proMatchSO > 0) and (not tProUsed) then
							wrkStr = KjtSpk_GenGndr(2)
							proUsed = true
						else
							wrkStr = KjtSpk_GenPnoun(newSentence, lineWeight).."'s"
							proMatchS, proMatchSO = true, 1
						end
						checkPrevWrd("my")
					elseif wrkStr:lower() == "myself" then
						if proMatchS and (not tProUsed) then
							wrkStr = KjtSpk_GenGndr(1).."self"
							proUsed = true
						else
							wrkStr = KjtSpk_GenPnoun(newSentence, lineWeight).."'s self"
							proMatchS, proMatchSO = true, 1
						end
						
						checkPrevWrd("myself")
					elseif (wrkStr:lower() == "he") or (wrkStr:lower() == "she") then
						if proUsed then
							local lLwrd = lWrd:lower()
							if (lLwrd == "which") and (suffix ~= "." and suffix ~= "!" and suffix ~= "?") then
								wrkStr = "they"
								proMatchLWA = true
							else
								wrkStr = "that one"
							end
						else
							tProUsed = true
						end
					elseif (wrkStr:lower() == "him") or (wrkStr:lower() == "her") then
						if proUsed then
							if wrkStr:lower() == "her" then --Damn English!
								local lLwrd = lWrd:lower()
								if newSentence or ((KjtSpk_IsFragment(lLwrd) or lLwrd == "saw") and (suffix ~= "." and suffix ~= "!" and suffix ~= "?")) then
									wrkStr = "their"
								else
									wrkStr = "them"
								end
							else
								wrkStr = "them"
							end
						else
							tProUsed = true
						end
					elseif (wrkStr:lower() == "his") or (wrkStr:lower() == "hers") then
						if proUsed then
							if wrkStr:lower() == "his" then --Damn English... More so than the last time!
								local lLwrd = lWrd:lower()
								if newSentence or ((KjtSpk_IsFragment(lLwrd) or lLwrd == "saw") and (suffix ~= "." and suffix ~= "!" and suffix ~= "?")) then
									wrkStr = "their"
								else
									wrkStr = "theirs"
								end
							else
								wrkStr = "theirs"
							end
						else
							tProUsed = true
						end
					else
						if proMatchLWA then
							--Next word fixup
							if wrkStr == "am" or wrkStr == "are" then wrkStr = "is"
							elseif (wrkStr == "do") and not(lWrd:lower() == "it") then wrkStr = "does"
							elseif (wrkStr == "go") then wrkStr = "goes"
							elseif (wrkStr == "have") then wrkStr = "has"
							else
								local lC = wrkStr:sub(-1)
								local sLC = wrkStr:sub(-2, -2)
								if lC == "d" then
									if (((sLC == "e") and (wrkStr:sub(-3, -3) == "e")) or ((sLC == "l") and (wrkStr:sub(-3, -3) == "e")) or ((sLC == "n") and not(wrkStr == "found"))) and not(wrkStr:sub(-4, -4) == "r") then
										wrkStr = wrkStr .. "s"
									end
								elseif lC == "e" then
									if (sLC == "f") then
										wrkStr = wrkStr:sub(1, -3) .. "ves"
									elseif (sLC == "g") or (sLC == "e") or (sLC == "s") or ((sLC == "m") and wrkStr ~= "came") or (sLC == "t") or (sLC == "p") or ((sLC == "v") and not(wrkStr:sub(-3, -3) == "a")) or ((sLC == "k") and ((wrkStr:sub(-4, -4) == "v") or not(wrkStr:sub(-3, -3) == "o"))) then
										wrkStr = wrkStr .. "s"
									end
								elseif lC == "f" then
									if sLC == "a" then
										wrkStr = wrkStr:sub(1, -3) .. "ves"
									end
								elseif lC == "h" then
									if (sLC == "s") or (sLC == "c") then
										wrkStr = wrkStr .. "es"
									end
								elseif lC == "k" then
									if (sLC == "n") or (sLC == "r") or (sLC == "s") then
										wrkStr = wrkStr .. "s"
									end
								elseif lC == "n" then
									if ((sLC == "a") and not(wrkStr:sub(-3, -3) == "c")) or ((sLC == "r") and not(wrkStr:sub(1, 2) == "re")) then
										wrkStr = wrkStr .. "s"
									end
								elseif lC == "p" then
									if (sLC == "l") or (sLC == "e") then
										wrkStr = wrkStr .. "s"
									end
								elseif lC == "r" then
									if ((sLC == "e") or (sLC == "a")) and not(wrkStr:sub(-3, -3) == "v") then
										wrkStr = wrkStr .. "s"
									end
								elseif lC == "s" then
									if (lWrd:lower() == "they") then --For he/she -> they
										wrkStr = wrkStr:sub(1, -2)
									elseif (sLC == "s") then
										wrkStr = wrkStr .. "es"
									end
								elseif lC == "t" then
									if (sLC == "n") or (sLC == "c") or (sLC == "b") or (sLC == "u") or (sLC == "p") or (sLC == "f") or (sLC == "e" and wrkStr ~= "get") or (wrkStr == "get" and not KjtSpk_IsFragment(slWrd)) then
										wrkStr = wrkStr .. "s"
									end
								elseif lC == "w" then
									if sLC == "o" then
										wrkStr = wrkStr .. "s"
									end
								elseif lC == "y" then
									if ((sLC == "a") or (sLC == "o")) and (wrkStr ~= "may") then
										wrkStr = wrkStr .. "s"
									end
								elseif lC == "l" then
									if (sLC ~= "l") then
										wrkStr = wrkStr .. "s"
									end
								end
							end
							if (fragmentExceptions[wrkStr:lower()] == nil) or (fragmentExceptions[wrkStr:lower()] == true) then
								proMatchLWA = false
							end
						end
					end
				end
				slWrd = lWrd
				lWrd = wrkStr .. suffix
				lWrdIndx = zo_strlen(result) + 1
				
				
				if newSentence then
					wrkStr = KjtSpk_FrstChrCase(wrkStr, true)
				end
				
				result = result .. wrkStr .. suffix .. " "
				
				if validSuffix then
					newSentence = true
					proMatchS = false
					if (math.random() < 0.05) or (proMatchSO >= 2) then
						proMatchSO = 0
					elseif (proMatchSO ~= 0) then
						proMatchSO = proMatchSO + 1
					end
				else
					newSentence = false
				end
				
				lastIndx = wrkIndx
			end
			config.useRace = prevOptR
			config.useName = prevOptN
			result = result:sub(1, -2)
		else --No pronouns in line
			result = str
		end
		
		if dbg then
			result = result .. "\r\nLine Weight: " .. lineWeight
		end
	else --Replace Goodbye
		if config.fluffBye > 0 then
			lastRand = 2;
			
			if config.fluffBye == 1 then
				if config.dynRace then
					result = fluffyGoodbye[1]:format(khajiitRace)
				else
					result = fluffyGoodbye[1]:format("Khajiit")
				end
			else
				--Take the seed from the NPC name so it doesn't change pronoun mid conversation.
				if not gamepad then
					math.randomseed(KjtSpk_GenSeed(ZO_InteractWindowTargetAreaTitle:GetText():gsub('^%A*(.-)%A*$', '%1'))) --Trim any non letters from start/finish
				else
					math.randomseed(KjtSpk_GenSeed(ZO_InteractWindow_GamepadTitle:GetText()))
				end
				math.random() --Pop one random, first is always dodgy.
				rand = math.random()
				result = fluffyGoodbye[KjtSpk_Round(math.random() * (#fluffyGoodbye - 1))+1]:format(KjtSpk_GenPnoun(true, lineWeight, true))
			end
		else
			result = str
		end
		lineWeight = 0.0
	end
	
	lastRand = rand;
	return result
end


--Command stuff and init
local ksColours = 
{
	Default = "|cC5C29E",
	White = "|cFFFFFF",
	Purple = "|c8855BB",
	Pink = "|c995599",
	Blue = "|c555599",
	Red = "|c995555"
}

local function KjtSpk_SetHooks(on)
	if on then
		INTERACTION.PopulateChatterOption = function(...)
			local hackyHack = {...}
			hackyHack[4] = KjtSpk_ParseLine(hackyHack[4], false)
			origPopOpts(unpack(hackyHack))
		end
		ZO_GamepadInteraction.PopulateChatterOption = function(...)
			local hackyHack = {...}
			hackyHack[4] = KjtSpk_ParseLine(hackyHack[4], true)
			gpOrigPopOpts(unpack(hackyHack))
		end
	else
		INTERACTION.PopulateChatterOption = origPopOpts
		ZO_GamepadInteraction.PopulateChatterOption = gpOrigPopOpts
	end
end

local function KjtSpk_Cmd(str)
	local validArgs = (str and (zo_strlen(str) > 0))
	str = str:lower()
	local args = {}
	local i = 1
	for s in str:gmatch("%S+") do
		args[i] = s
		i = i + 1
	end
	
	local prefix = ksColours.Purple..ksPrefix..ksColours.White
	if validArgs and (args[1] == "conf") then
		if args[2] and (args[2] == "usename") then
			config.useName = not config.useName
			if config.useName then
				d(prefix.." Name pronoun Enabled for character \""..khajiitName.."\".")
			else
				d(prefix.." Name pronoun Disabled for character \""..khajiitName.."\".")
			end
		elseif args[2] and (args[2] == "fullname") then
			config.fullName = not config.fullName
			if config.fullName then
				d(prefix.." Using full name for character \""..khajiitName.."\".")
			else
				d(prefix.." Using first name for character \""..khajiitName.."\".")
			end
		elseif args[2] and (args[2] == "userace") then
			config.useRace = not config.useRace
			if config.useRace then
				d(prefix.." Race pronoun Enabled for character \""..khajiitName.."\".")
			else
				d(prefix.." Race pronoun Disabled for character \""..khajiitName.."\".")
			end
		elseif args[2] and (args[2] == "dynrace") then
			if khajiitRace == "Khajiit" then d(prefix.." This command has no affect on Khajiit!") return end
			
			config.dynRace = not config.dynRace
			if config.dynRace then
				d(prefix.." Race pronoun for character \""..khajiitName.."\" set to \""..khajiitRace.."\".")
			else
				d(prefix.." Race pronoun for character \""..khajiitName.."\" set to \"Khajiit\".")
			end
		elseif args[2] and (args[2] == "fluffchance") then
			local percent = tonumber(args[3])
			if not percent or percent < 0 or percent > 100 then
				d(ksColours.Purple..ksPrefix.."\r\n"..ksColours.Pink.."/ks conf fluffchance "..ksColours.Blue.."[percent]\r\n"..ksColours.White.."Sets the chance of inserting flavor text in dialog options.\r\nCurrent: "..tostring(config.fluffChance*100)..ksColours.White.." - Default: 33")
			else
				config.fluffChance = percent/100
				d(prefix.." Fluff Chance updated to: "..tostring(percent))
			end
		elseif args[2] and (args[2] == "goodbye") then
			local param = tonumber(args[3])
			if not param or param < 0 or param > 2 then
				d(ksColours.Purple..ksPrefix.."\r\n"..ksColours.Pink.."/ks conf goodbye "..ksColours.Blue.."[mode]\r\n"..ksColours.White.."Sets the goodbye mode. (0 = None, 1 = Static, 2 = Random)\r\nCurrent: "..tostring(config.fluffBye)..ksColours.White.." - Default: 1")
			else
				config.fluffBye = param
				d(prefix.." Goodbye Mode changed to: "..tostring(config.fluffBye))
			end
		elseif args[2] and (args[2] == "wordsubbing") then
			config.wordSubbing = not config.wordSubbing
			if config.wordSubbing then
				d(prefix.." Word Substitutions Enabled for character \""..khajiitName.."\".")
			else
				d(prefix.." Word Substitutions Disabled for character \""..khajiitName.."\".")
			end
		elseif args[2] and (args[2] == "weightlines") then
			config.lineWeighting = not config.lineWeighting
			if config.lineWeighting then
				d(prefix.." Line Weighting Enabled for character \""..khajiitName.."\".")
			else
				d(prefix.." Line Weighting Disabled for character \""..khajiitName.."\".")
			end
		elseif args[2] and (args[2] == "impolite") then
			config.impolitePnoun = not config.impolitePnoun
			if config.wordSubbing then
				d(prefix.." Impolite Pronouns Enabled for character \""..khajiitName.."\".")
			else
				d(prefix.." Impolite Pronouns Disabled for character \""..khajiitName.."\".")
			end
		elseif args[2] and (args[2] == "nickname") then
			if args[3] then
				config.nickName = ""
				local i2 = 3
				local bs = args[i2]
				local name = ""
				while not(bs == nil) do
					name = name .. KjtSpk_FrstChrCase(bs, true) .. " "
					i2 = i2+1
					bs = args[i2]
				end
				config.nickName = name:sub(0, zo_strlen(name)-1)
				d(prefix.." Set nickname \""..config.nickName.."\" for character \""..khajiitName.."\".")
			else
				config.nickName = ""
				d(prefix.." Removed nickname for character \""..khajiitName.."\".")
			end
		elseif args[2] and (args[2] == "alwaysnick") then
			config.alwaysNick = not config.alwaysNick
			if config.alwaysNick then
				d(prefix.." Always using Nickname for character \""..khajiitName.."\".")
			else
				d(prefix.." Occasionally using Nickname for character \""..khajiitName.."\".")
			end
		else
			d(ksColours.Purple..ksPrefix.."\r\n"..
			ksColours.Pink.."/ks conf fluffchance"..ksColours.Blue.." [percent]"..ksColours.White.." - Set the chance of fluff text being inserted.\r\n"..
			ksColours.Pink.."/ks conf goodbye"..ksColours.Blue.." [mode]"..ksColours.White.." - Set the mode used to handle the 'goodbye' line.\r\n"..
			ksColours.Pink.."/ks conf dynrace"..ksColours.White.." - Toggle: Race pronoun Dynamic or \"Khajiit\"\r\n"..
			ksColours.Pink.."/ks conf userace"..ksColours.White.." - Toggle: Race can be used as a pronoun.\r\n"..
			ksColours.Pink.."/ks conf usename"..ksColours.White.." - Toggle: Name can be used as a pronoun.\r\n"..
			ksColours.Pink.."/ks conf fullname"..ksColours.White.." - Toggle: Use entire character name.\r\n"..
			ksColours.Pink.."/ks conf nickname"..ksColours.White.." - String: The character's nickname, may be used instead of name.\r\n"..
			ksColours.Pink.."/ks conf alwaysnick"..ksColours.White.." - Toggle: Always use the characters nickname instead of name.\r\n"..
			ksColours.Pink.."/ks conf wordsubbing"..ksColours.White.." - Toggle: Certain words are replaced with more Khajiiti versions.\r\n"..
			ksColours.Pink.."/ks conf weightlines"..ksColours.White.." - Toggle: Weight lines positively or negatively to alter pronoun choice.\r\n"..
			ksColours.Pink.."/ks conf impolite"..ksColours.White.." - Toggle: When line weight is negative \"You\" will be replaced with \"It\"\r\n")
		end
	elseif validArgs and (args[1] == "toggle") then
		config.enabled = not config.enabled
		KjtSpk_SetHooks(config.enabled)
		if config.enabled then
			d(prefix.." Enabled for character \""..khajiitName.."\".")
		else
			d(prefix.." Disabled for character \""..khajiitName.."\".")
		end
	elseif validArgs and (args[1] == "status") then
		if config.enabled then
			d(prefix.." Enabled for character \""..khajiitName.."\".\r\nVersion: "..tostring(config.version))
		else
			d(prefix.." Disabled for character \""..khajiitName.."\".\r\nVersion: "..tostring(config.version))
		end
	else
		d(ksColours.Purple..ksPrefix.."\r\n"..
		ksColours.Pink.."/ks status"..ksColours.White.." - Display addon version and enabled status for current character.\r\n"..
		ksColours.Pink.."/ks toggle"..ksColours.White.." - Toggle addon enabled for current character.\r\n"..
		ksColours.Pink.."/ks conf"..ksColours.White.." - Display addon config commands.\r\n")
	end
end

local function KjtSpk_Init(eventCode, addOnName)
	if addOnName ~= "KhajiitSpeak" then return end
	config = ZO_SavedVars:NewAccountWide(KS.svName, KS.svVersion, nil, config, GetWorldName(), nil)
	if not config then
		d(ksPrefix .. " Fatal Error! Could not create config profile.")
		return
	end

	if config.enabled then
		KjtSpk_SetHooks(config.enabled)
	end

	SLASH_COMMANDS["/ks"] = KjtSpk_Cmd
	SLASH_COMMANDS["/khajiitspeak"] = KjtSpk_Cmd

	local LAM = LibAddonMenu2
	if LAM ~= nil then
		local cfgPnl =
		{
			type = "panel",
			name = KS.name,
			displayName = KS.name,
			author = KS.author,
			registerForRefresh = true,
			registerForDefaults = true,
			version = KS.version,
			website = KS.website,
		}

		local cfgCtrl = {
			{
				type = "checkbox",
				name = "Enabled for "..khajiitNameFirst,
				tooltip = "Whether the addon is enabled for this character.",
				getFunc = function() return config.enabled end,
				setFunc = function(v)
					config.enabled = v
					KjtSpk_SetHooks(config.enabled)
				end,
				width = "full",
				default = (khajiitRace == "Khajiit")
			},
			{
				type = "header",
				name = "Config",
				disabled = function() return not(config.enabled) end,
				width = "full"
			},
			{
				type = "description",
				text = " \nPronouns",
				width = "full"
			},
			{
				type = "checkbox",
				name = "Use Race",
				tooltip = "Whether the character's race is a valid pronoun.\n \nEg; \""..ksColours.Purple..khajiitRace..ksColours.Default.." stole nothing!\"",
				getFunc = function() return config.useRace end,
				setFunc = function(v) config.useRace = v end,
				width = "half",
				disabled = function() return not(config.enabled) end,
				default = true
			},
			{
				type = "checkbox",
				name = "Dynamic Race",
				tooltip = "Whether or not the race pronoun is forced to 'Khajiit' or the character's actual race. This is useful for a character that perhaps grew up in Elsweyr, but is not racially confused.\nWill have no effect on Khajiit characters.\n \nEg; \""..ksColours.Purple.."Khajiit"..ksColours.Default.." may have stolen something.\"\n(Requires 'Use Race')",
				getFunc = function() return config.dynRace end,
				setFunc = function(v) config.dynRace = v end,
				width = "half",
				disabled = function() return not(config.enabled and config.useRace) end,
				default = false
			},
			{
				type = "checkbox",
				name = "Use Name",
				tooltip = "Whether the character's name is a valid pronoun. Disabling this is useful if your character has a distracting or lore unfriendly name, alternatively see Nickname below.\n \nEg; \""..ksColours.Purple..khajiitNameFirst..ksColours.Default.." is a milk drinker.\"",
				getFunc = function() return config.useName end,
				setFunc = function(v) config.useName = v end,
				width = "full",
				disabled = function() return not(config.enabled) end,
				default = true
			},
			{
				type = "checkbox",
				name = "Impolite Pronouns",
				tooltip = "Whether or not (on a negative line weight) the addon will substitute second person pronouns for \"it.\"\nThis feature attempts to inject a little Khajitti personality by being rude to characters when the line is considered negative.\n \nEg;\n\"Khajiit whishes "..ksColours.Purple.."you"..ksColours.Default.." would not do that.\"\n     v\n\"Khajiit whishes "..ksColours.Purple.."it"..ksColours.Default.." would not do that.\"\n \n(Requires 'Line Weighting')",
				getFunc = function() return config.impolitePnoun end,
				setFunc = function(v) config.impolitePnoun = v end,
				width = "full",
				disabled = function() return not(config.enabled and config.lineWeighting) end,
				default = true,
				warning = ksColours.Red.."This feature is experimental!"
			},
			{
				type = "description",
				text = " \nNaming",
				width = "full"
			},
			{
				type = "checkbox",
				name = "Full Name",
				tooltip = "Whether to use the character's entire name rather than just the first name. This will have no effect on characters with no surname.\n \nEg; \""..ksColours.Purple..khajiitName..ksColours.Default.." longs for warm sands.\"\n(Requires 'Use Name')",
				getFunc = function() return config.fullName end,
				setFunc = function(v) config.fullName = v end,
				width = "full",
				disabled = function() return not(config.enabled and config.useName) end,
				default = false
			},
			{
				type = "editbox",
				name = "Nickname",
				tooltip = "The character's nickname.\nThis will sometimes be used as a pronoun instead of the character's actual name.\n \nEg;\n'Razum-dar' -> 'Raz'\n \n(Leave blank to disable.)\n(Requires 'Use Name')",
				getFunc = function() return config.nickName end,
				setFunc = function(v) config.nickName = v end,
				width = "full",
				disabled = function() return not(config.enabled and config.useName) end,
				default = ""
			},
			{
				type = "checkbox",
				name = "Always use nickname",
				tooltip = "Whether to always use the character's nickname instead of their actual name.\nThis is useful for characters with a lore unfriendly name.\n \n(Requires 'Nickname')",
				getFunc = function() return config.alwaysNick end,
				setFunc = function(v) config.alwaysNick = v end,
				width = "full",
				disabled = function() return not(config.enabled and config.useName and not(config.nickName == "")) end,
				default = false
			},
			{
				type = "description",
				text = " \nSystem",
				width = "full"
			},
			{
				type = "slider",
				name = "Fluff Chance",
				tooltip = "The global chance of fluff text being inserted into various places. This text attempts to make lines sound more Khajiit in personality. Higher values will make inserts more common, lower values less so.\n \n0% will disable this feature entirely.\n33% is the recommended value.\n \nEg;\""..ksColours.Purple.."You will tell Khajiit..."..ksColours.Default.." Where is "..KjtSpk_GenGndr(0).." going?\"",
				min = 0,
				max = 100,
				step = 1,
				getFunc = function() return config.fluffChance*100 end,
				setFunc = function(v) config.fluffChance = v/100 end,
				disabled = function() return not(config.enabled) end,
				width = "full",
				default = 33
			},
			{
				type = "checkbox",
				name = "Line Weighting",
				tooltip = "Whether or not lines are scored based on positive or negative intent. Pronoun choice is then altered by this value. The result is that negative and unfriendly lines will be more likely to choose \"Khajiit\" and positive lines will be more likely to choose \""..khajiitNameFirst..".\"\nDisabled, the choice of pronoun is purely random.\n \nOther features may also require this to be enabled.\n \n"..ksColours.Red.."Warning: This feature is performance intensive, and may cause trouble on older machines.",
				getFunc = function() return config.lineWeighting end,
				setFunc = function(v) config.lineWeighting = v end,
				width = "full",
				disabled = function() return not(config.enabled) end,
				default = true
			},
			{
				type = "checkbox",
				name = "Word Subbing",
				tooltip = "Whether or not words will be randomly substitued for others. This feature attempts to inject a little more Khajiiti personality into the text.\n \nEg;\n\"You want Khajiit to "..ksColours.Purple.."steal"..ksColours.Default.." that?\"\n     v\n\"You want Khajiit to "..ksColours.Purple.."take ownership of"..ksColours.Default.." that?\"\n \n(Driven by 'Fluff Chance')",
				getFunc = function() return config.wordSubbing end,
				setFunc = function(v) config.wordSubbing = v end,
				width = "full",
				disabled = function() return not(config.enabled and config.fluffChance > 0) end,
				default = true
			},
			{
				type = "dropdown",
				name = "Goodbye Line Mode",
				tooltip = "The mode the addon will use to alter the goodbye line.\n \nOff - The goodbye line will always read 'Goodbye.'\n \nStatic - The goodbye line will always read 'Khajiit must go now.'\n \nDynamic - The goodbye line will be chosen at random.\n \nDynamic is recommended, but Static is default to keep in line with normal game behaviour.\n \nEg;\""..ksColours.Purple.."Goodbye."..ksColours.Default.."\"\nEg;\""..ksColours.Purple.."Khajiit must go now."..ksColours.Default.."\"\nEg;\""..ksColours.Purple..khajiitName.." has had enough talk."..ksColours.Default.."\"",
				choices = {"Off", "Static", "Dynamic"},
				getFunc = function() if config.fluffBye == 0 then return "Off" elseif config.fluffBye == 1 then return "Static" else return "Dynamic" end end,
				setFunc = function(v) if v == "Off" then config.fluffBye = 0 elseif v == "Static" then config.fluffBye = 1 else config.fluffBye = 2 end end,
				disabled = function() return not(config.enabled) end,
				width = "full",
				default = "Static"
			}
		}

		LAM:RegisterAddonPanel("KhajiitSpeak", cfgPnl)
		LAM:RegisterOptionControls("KhajiitSpeak", cfgCtrl)
	else
		d(ksPrefix.." LAM missing. This shouldn't happen!")
	end

	SLASH_COMMANDS["/ksdebug"] = KjtSpk_CmdDbg
end
EVENT_MANAGER:RegisterForEvent("KhajiitSpeak", EVENT_ADD_ON_LOADED, KjtSpk_Init)

function KjtSpk_CmdDbg(str)
	d(KjtSpk_ParseLine(str, false, true))
end
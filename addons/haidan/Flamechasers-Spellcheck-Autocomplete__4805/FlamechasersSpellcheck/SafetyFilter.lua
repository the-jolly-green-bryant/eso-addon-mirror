local FSC = FlamechasersSpellcheck

-- Suggestion safety is intentionally separate from spelling dictionaries and from the
-- prediction model itself. Dictionaries answer "is this a word?" and the prediction
-- engine answers "how likely is this completion?"; this module only answers "should
-- the addon proactively show this particular completion in this local context?"
--
-- Typed text is never censored, edited, blocked, hidden, or rejected. The model may
-- still learn/score language normally. Safety is a last-mile candidate gate only.
--
-- Design goals:
--   * Keep the contextual classifier meaning-based rather than globally blocking
--     ordinary crime/violence vocabulary. A separate product-level prediction-bar
--     denylist below intentionally excludes a narrow set of high-risk terms.
--   * Combine several local signals instead: topic + intent/action + nearby phrasing.
--   * Treat self-harm and sexual/exploitative contexts involving minors as higher
--     priority than the general game-context exemption.
--   * Recognize clear prevention/reporting/support contexts so safety discussion is
--     not punished.
--   * Keep the hot path cheap: one bounded context profile is cached per suggestion
--     request, and candidate-specific checks are small set lookups / short phrases.

local ALWAYS_BLOCKED_SUGGESTION_TOKENS = {}

-- Intentionally narrow: severe slurs / abuse that the addon should never volunteer as
-- a completion. This is not used to censor typed text.
local ALWAYS_BLOCKED_TOKEN_DATA = [[
beaner beaners
chink chinks
coon coons
dago dagos
fag fags faggot faggots
gook gooks
jap japs
kike kikes
kkk
nigga niggas nigger niggers
paki pakis
porchmonkey porchmonkeys
raghead ragheads
redskin redskins
sandnigger sandniggers
spic spics
towelhead towelheads
tranny trannies
wetback wetbacks
wop wops
zipperhead zipperheads
kys
]]

for token in ALWAYS_BLOCKED_TOKEN_DATA:gmatch("%S+") do
    ALWAYS_BLOCKED_SUGGESTION_TOKENS[token] = true
end

-- Prediction-bar-only hard denylist.
--
-- This is deliberately separate from IsSuggestionSafe(): these words are simply not
-- useful for the addon to *proactively volunteer* in the three-word prediction bar.
-- They remain valid typed text, remain spellchecked normally, and remain eligible as
-- right-click correction candidates. The contextual safety classifier still handles
-- ordinary ambiguous words (kill, steal, attack, hack, bomb, etc.) without weakening
-- normal ESO/chat predictions.
local PREDICTION_BAR_BLOCKED_TOKENS = {}
local PREDICTION_BAR_BLOCKED_TOKEN_DATA = [[
-- Minor / under-18 identifiers. Intentionally broad by product decision.
baby babies newborn newborns infant infants
preschooler preschoolers toddler toddlers
child children schoolchild schoolchildren
kid kids kiddo kiddos youngster youngsters
youth youths juvenile juveniles
minor minors underage underaged
preteen preteens tween tweens
adolescent adolescents
teen teens teenage teenager teenagers
schoolboy schoolboys schoolgirl schoolgirls
boy boys girl girls
kiddie kiddies kiddy kiddys
schoolkid schoolkids youngling younglings
tyke tykes jailbait

-- Suicide / self-harm terms with high screenshot/reputational risk.
suicide suicides suicidal suicidality
selfharm selfinjury selfmutilation
unalive unaliving kms kys
sewerslide sewercide selfdelete selfdeleted selfdeleting selfdeletion
overdose overdoses overdosed overdosing

-- Sexual exploitation / highly sensitive sexual terms.
pedophile pedophiles pedophilia
paedophile paedophiles paedophilia
pedo pedos pederast pederasts
groomer groomers grooming
molest molests molested molesting molester molesters molestation
incest incestuous
bestiality zoophilia necrophilia
lolicon shotacon loli shota
csam childporn childpornography
barelylegal
sext sexts sexting
nude nudes porn pornography pornographic

-- Sexual-orientation / gendered slurs and strongly derogatory labels.
fag fags faggot faggots
lesbo lesbos
dyke dykes
homo homos
sodomite sodomites
tranny trannies

-- High-specificity violent / coercive crimes. Generic combat words are excluded.
murder murders murdered murdering murderer murderers
homicide homicides manslaughter
rape rapes raped raping rapist rapists
kidnap kidnaps kidnapped kidnapping kidnapper kidnappers
abduct abducts abducted abducting abduction abductions abductor abductors
blackmail blackmails blackmailed blackmailing blackmailer blackmailers
extort extorts extorted extorting extortion extortionist extortionists
ransom ransoms ransoming
burglary burglar burglaries burglars
arson arsonist arsonists
counterfeit counterfeits counterfeited counterfeiting counterfeiter counterfeiters
forgery forgeries forger forgers
fraud frauds fraudulent fraudster fraudsters
embezzle embezzles embezzled embezzling embezzlement
launder launders laundered laundering moneylaundering
trafficking trafficker traffickers humantrafficking
smuggling smuggler smugglers
dox doxes doxed doxing doxer doxers
doxx doxxes doxxed doxxing doxxer doxxers
swatting
terrorism terrorist terrorists

-- High-specificity cybercrime / malicious-software vocabulary.
phish phishes phished phishing phisher phishers
phreak phreaks phreaking
cryptojacking credentialstuffing
malware ransomware
keylogger keyloggers
spyware

-- High-risk illicit drug terms. Generic words such as drug/pills are excluded.
cocaine heroin fentanyl
meth methamphetamine
crackcocaine
mdma
]]

for line in PREDICTION_BAR_BLOCKED_TOKEN_DATA:gmatch("[^\n]+") do
    -- Allow category comments inside the compact data blob.
    line = line:gsub("%-%-.*$", "")
    for token in line:gmatch("%S+") do
        PREDICTION_BAR_BLOCKED_TOKENS[token] = true
    end
end

-- General real-world risk vocabulary. None of these words are globally blocked.
local GENERAL_RISK_TOKENS = {
    steal=true, stealing=true, stolen=true, shoplift=true, shoplifting=true,
    rob=true, robbing=true, robbery=true, burglar=true, burglary=true,
    scam=true, scams=true, scamming=true, fraud=true, fraudulent=true,
    phish=true, phishing=true, counterfeit=true, counterfeiting=true,
    hack=true, hacking=true, hacked=true, malware=true, ransomware=true,
    bomb=true, bombs=true, explosive=true, explosives=true,
    poison=true, poisoning=true, poisoned=true,
    kidnap=true, kidnapping=true, kidnapped=true,
    murder=true, murdering=true, murdered=true,
    rape=true, raped=true, raping=true, rapist=true,
    arson=true, extort=true, extortion=true, blackmail=true, blackmailing=true,
    smuggle=true, smuggling=true, traffick=true, trafficking=true,
    bribe=true, bribery=true, laundering=true, forgery=true, forged=true,
    cocaine=true, heroin=true, fentanyl=true, meth=true, methamphetamine=true,
}

local CONTROLLED_TRANSACTION_TOKENS = {
    cocaine=true, heroin=true, fentanyl=true, meth=true, methamphetamine=true,
    counterfeit=true, stolen=true,
}

-- These terms remain high-risk even when an ESO/game word is nearby. This prevents a
-- broad game-context token such as "guild" from acting as a bypass for scams, malware,
-- hard drugs, explosives, kidnapping, or sexual violence.
local STRONG_REALWORLD_RISK_TOKENS = {
    scam=true, scams=true, scamming=true, fraud=true, fraudulent=true,
    phish=true, phishing=true, counterfeit=true, counterfeiting=true,
    hack=true, hacking=true, hacked=true, malware=true, ransomware=true,
    bomb=true, bombs=true, explosive=true, explosives=true,
    kidnap=true, kidnapping=true, kidnapped=true, rape=true, raped=true, raping=true, rapist=true,
    arson=true, extort=true, extortion=true, blackmail=true, blackmailing=true,
    smuggle=true, smuggling=true, traffick=true, trafficking=true,
    bribery=true, laundering=true, forgery=true,
    cocaine=true, heroin=true, fentanyl=true, meth=true, methamphetamine=true,
}

local OPERATIONAL_TOKENS = {
    buy=true, buying=true, sell=true, selling=true, get=true, getting=true,
    make=true, making=true, build=true, building=true, create=true, creating=true,
    obtain=true, obtaining=true, acquire=true, acquiring=true,
    hide=true, hiding=true, bypass=true, bypassing=true, evade=true, evading=true,
    disable=true, disabling=true,
    steal=true, stealing=true, rob=true, robbing=true,
    hack=true, hacking=true, scam=true, scamming=true,
    poison=true, poisoning=true, commit=true, committing=true,
    extort=true, blackmail=true, blackmailing=true, smuggle=true, smuggling=true,
    traffick=true, trafficking=true, launder=true, laundering=true, forge=true, forgery=true,
}

-- Self-harm is handled as a separate, higher-priority contextual domain. Outcome/method
-- words are deliberately broad but do nothing by themselves; they only matter when
-- combined with self-reference, self-harm topic language, or dangerous intent phrasing.
local SELF_HARM_TOPIC_TOKENS = {
    suicide=true, suicidal=true, selfharm=true, selfinjury=true,
    unalive=true, unaliving=true, kms=true,
}

local SELF_HARM_OUTCOME_TOKENS = {
    die=true, dying=true, dead=true, death=true,
}

local SELF_HARM_METHOD_TOKENS = {
    overdose=true, overdosing=true, pills=true, dosage=true, dose=true,
    hang=true, hanging=true, cut=true, cutting=true,
    poison=true, poisoning=true, jump=true, jumping=true,
}

local STRONG_SELF_HARM_METHOD_TOKENS = {
    overdose=true, overdosing=true,
}

local SELF_REFERENCE_TOKENS = {
    myself=true, yourself=true, herself=true, himself=true, themselves=true,
    life=true,
}

-- Child/minor safety is also compositional. Generic words such as child, teen, girl,
-- boy, photo, date, etc. remain fully usable on their own.
local STRONG_MINOR_TOKENS = {
    child=true, children=true, kid=true, kids=true,
    minor=true, minors=true, underage=true,
}

local SOFT_MINOR_TOKENS = {
    teen=true, teens=true, teenage=true, teenager=true, teenagers=true,
    boy=true, boys=true, girl=true, girls=true,
}

local SEXUAL_CONTEXT_TOKENS = {
    sex=true, sexual=true, sexually=true, sext=true, sexting=true,
    nude=true, nudes=true, naked=true, porn=true, pornography=true,
    explicit=true, erotic=true, intimate=true,
}

local EXPLOITATION_TOKENS = {
    groom=true, groomed=true, grooming=true,
    exploit=true, exploited=true, exploiting=true, exploitation=true,
    solicit=true, soliciting=true, solicitation=true,
    coerce=true, coerced=true, coercing=true, coercion=true,
    blackmail=true, blackmailing=true,
}

-- Romantic/contact language is too broad to use with ordinary "boy/girl/teen" text,
-- but becomes a useful extra signal when the context explicitly says "underage",
-- "minor", or supplies an under-18 age.
local UNDERAGE_ROMANTIC_TOKENS = {
    date=true, dating=true, kiss=true, kissing=true,
    boyfriend=true, girlfriend=true,
}

local UNDERAGE_CONTACT_TOKENS = {
    meet=true, meeting=true, dm=true, message=true, messaging=true, contact=true, contacting=true,
}

local UNDERAGE_ADULT_TARGET_TOKENS = {
    older=true, adult=true, adults=true, man=true, men=true, woman=true, women=true,
}

-- Direct interpersonal violence is separate from generic ESO combat vocabulary. Words
-- such as kill/shoot/stab are never blocked on their own; they become relevant only
-- when composed with a real-person target and intent/threat language.
local VIOLENCE_ACTION_TOKENS = {
    kill=true, killing=true, hurt=true, hurting=true, attack=true, attacking=true,
    shoot=true, shooting=true, stab=true, stabbing=true, beat=true, beating=true,
    strangle=true, strangling=true, choke=true, choking=true, murder=true, murdering=true,
}

local PERSON_TARGET_TOKENS = {
    you=true, him=true, her=true, them=true, someone=true, somebody=true,
    person=true, people=true, neighbor=true, neighbour=true, coworker=true, colleague=true,
    teacher=true, ex=true, boyfriend=true, girlfriend=true, wife=true, husband=true,
}

local THREAT_INTENT_PATTERNS = {
    " i will ", " i'll ", " im going to ", " i'm going to ", " i am going to ",
    " gonna ", " planning to ", " plan to ", " want to ", " wanna ",
}

local DIRECT_THREAT_PATTERNS = {
    " kill you ", " kill him ", " kill her ", " kill them ",
    " hurt you ", " hurt him ", " hurt her ", " hurt them ",
    " shoot you ", " shoot him ", " shoot her ", " shoot them ",
    " stab you ", " stab him ", " stab her ", " stab them ",
    " strangle you ", " choke you ", " beat you ",
}

local PERSON_TARGET_PATTERNS = {
    " my boss ", " my coworker ", " my colleague ", " my neighbor ", " my neighbour ",
    " my teacher ", " my ex ", " my wife ", " my husband ",
}

-- Facilitation/evasion patterns are intentionally about *doing* wrongdoing, not merely
-- mentioning it. This mirrors modern moderation taxonomies that separate discussion
-- from instructions/advice that facilitate illicit conduct.
local ILLICIT_FACILITATION_PATTERNS = {
    " how to buy ", " how do i buy ", " where can i buy ", " where do i buy ", " where to buy ",
    " how to sell ", " where can i sell ", " where do i sell ", " where to sell ",
    " how to get ", " how do i get ", " where can i get ", " where do i get ", " where to get ",
    " how to make ", " how do i make ", " how to build ", " how do i build ",
    " how to steal ", " how do i steal ", " how to rob ", " how do i rob ",
    " how to hack ", " how do i hack ", " how to scam ", " how do i scam ",
    " hide evidence ", " destroy evidence ", " evade police ", " avoid police ",
    " evade detection ", " avoid detection ", " without getting caught ",
    " bypass security ", " disable security ",
}

local SELF_HARM_ENCOURAGEMENT_PATTERNS = {
    " kill yourself ", " go kill yourself ", " go die ", " you should die ",
    " you should kill yourself ", " better off dead ",
}

local SELF_HARM_METHOD_SEEKING_PATTERNS = {
    " suicide methods ", " methods of suicide ", " ways to commit suicide ",
    " ways to die ", " easiest way to die ", " quickest way to die ",
    " painless way to die ", " least painful way to die ",
    " best way to kill myself ", " easiest way to kill myself ",
}

-- Game context may relax GENERAL crime/violence terms, but NEVER bypasses the
-- self-harm or minor-safety domains above.
local GAME_CONTEXT_TOKENS = {
    eso=true, tamriel=true, dungeon=true, dungeons=true, trial=true, trials=true,
    quest=true, quests=true, npc=true, npcs=true, boss=true, bosses=true,
    pvp=true, pve=true, cyrodiil=true, battleground=true, battlegrounds=true,
    nightblade=true, templar=true, arcanist=true, warden=true, sorcerer=true,
    necromancer=true, dragonknight=true, werewolf=true,
    skill=true, skills=true, morph=true, morphs=true,
    addon=true, addons=true, guild=true, guilds=true, zone=true, zones=true,
    gear=true, parse=true, parsing=true, dummy=true,
}

-- Strongly protective words. Unlike the old implementation, their mere presence does
-- not automatically exempt the whole message ("evade police" is not protective).
local PROTECTIVE_CANDIDATE_TOKENS = {
    report=true, reporting=true, reported=true,
    prevent=true, preventing=true, prevention=true,
    protect=true, protecting=true, protection=true,
    hotline=true, helpline=true, emergency=true,
    safety=true, safe=true, support=true, recovery=true,
    therapist=true, counselor=true, counselling=true, counseling=true,
    victim=true, victims=true, survivor=true, survivors=true,
    warning=true, warnings=true, awareness=true,
}

local INTENT_PATTERNS = {
    " how to ", " how do i ", " how can i ", " best way to ",
    " where can i ", " where do i ", " where to ", " teach me to ",
    " help me ", " i want to ", " i wanna ", " i need to ",
    " can i ", " could i ", " tell me how ", " show me how ",
    " how many ", " what dose ", " what dosage ",
}

local CONTACT_SOLICITATION_PATTERNS = {
    " where can i meet ", " where do i meet ", " where to meet ",
    " want to meet ", " wanna meet ", " looking to meet ",
    " how can i contact ", " how do i contact ",
}

-- These are contextual patterns, not blocked phrases. They help identify when otherwise
-- ordinary words form a self-harm meaning only after composition.
local SELF_HARM_PHRASE_PATTERNS = {
    " kill myself ", " kill yourself ", " kill herself ", " kill himself ",
    " hurt myself ", " hurt yourself ", " harm myself ", " harm yourself ",
    " end my life ", " end your life ", " take my life ", " take your life ",
    " want to die ", " wanna die ", " wish i was dead ", " wish i were dead ",
    " dont want to live ", " do not want to live ",
    " commit suicide ",
}

-- Strongly protective *purposes*. Pattern direction matters; this avoids treating a
-- single word such as "police" or "detection" as a universal safety bypass.
local PROTECTIVE_PURPOSE_PATTERNS = {
    " how to report ", " how do i report ", " how can i report ",
    " report a ", " report the ", " report this ",
    " how to prevent ", " how can i prevent ", " prevent suicide ",
    " suicide prevention ", " suicide hotline ", " crisis hotline ",
    " get help ", " seek help ", " need help ", " needs help ",
    " keep safe ", " stay safe ", " child safety ", " internet safety ",
    " protect a child ", " protect children ", " protect kids ",
    " child protection ", " report abuse ", " report exploitation ",
    " abuse prevention ", " exploitation prevention ",
    " victim of ", " survivor of ", " warning about ", " awareness of ",
}

local BENIGN_DISCUSSION_PATTERNS = {
    " news about ", " article about ", " story about ", " documentary about ",
    " talking about ", " discussion about ", " discussing ",
    " law about ", " laws about ", " illegal because ",
}

local function NormalizeSafetyToken(token)
    if not token then return "" end
    token = tostring(token):gsub("’", "'"):lower()
    token = token:gsub("^[-']+", ""):gsub("[-']+$", "")
    return token
end

local function IsAlwaysBlockedToken(token)
    token = NormalizeSafetyToken(token)
    if token == "" then return false end
    if ALWAYS_BLOCKED_SUGGESTION_TOKENS[token] then return true end
    if #token > 2 and token:sub(-2) == "'s" then
        return ALWAYS_BLOCKED_SUGGESTION_TOKENS[token:sub(1, -3)] == true
    end
    return false
end

local function IsPredictionBarBlockedToken(token)
    token = NormalizeSafetyToken(token)
    if token == "" then return false end
    if PREDICTION_BAR_BLOCKED_TOKENS[token] then return true end
    if #token > 2 and token:sub(-2) == "'s" then
        return PREDICTION_BAR_BLOCKED_TOKENS[token:sub(1, -3)] == true
    end
    return false
end

-- Prediction-bar-only gate. Keep this function out of SpellEngine.lua: correction
-- candidates intentionally do not use the hard denylist.
function FSC:IsPredictionBarHardBlocked(candidate)
    if not candidate or candidate == "" then return false end

    local normalized = tostring(candidate):gsub("’", "'"):lower()

    -- Prediction candidates can contain a hyphen. Check the compact form as well so
    -- common euphemisms such as a hyphenated self-harm term cannot bypass the exact
    -- token list. This is still exact matching, never substring matching.
    if normalized:find("-", 1, true) then
        local compact = normalized:gsub("[^a-z']", "")
        if IsPredictionBarBlockedToken(compact) then return true end
    end

    for token in normalized:gmatch("[a-z']+") do
        if IsPredictionBarBlockedToken(token) then return true end
    end

    -- Catch hyphenated/compounded spellings such as self-harm without globally using
    -- substring matching (which would create false positives such as classic/assassin).
    local compact = normalized:gsub("[^a-z]", "")
    if compact ~= "" and PREDICTION_BAR_BLOCKED_TOKENS[compact] then return true end

    return false
end

local function AddTokens(text, target)
    text = tostring(text or ""):gsub("’", "'"):lower()
    for token in text:gmatch("[a-z']+") do
        token = NormalizeSafetyToken(token)
        if token ~= "" then
            target[token] = true
            if #token > 2 and token:sub(-2) == "'s" then target[token:sub(1, -3)] = true end
        end
    end
end

local function HasAny(tokens, set)
    for token in pairs(tokens or {}) do
        if set[token] then return true end
    end
    return false
end

local function NormalizePhrase(text)
    local words = {}
    local normalized = tostring(text or ""):gsub("’", "'"):lower()
    for token in normalized:gmatch("[a-z']+") do
        token = NormalizeSafetyToken(token)
        if token ~= "" then words[#words + 1] = token end
    end
    return " " .. table.concat(words, " ") .. " "
end

local function HasAnyPattern(phrase, patterns)
    for _, pattern in ipairs(patterns) do
        if phrase:find(pattern, 1, true) then return true end
    end
    return false
end

local function HasIntentPattern(phrase)
    return HasAnyPattern(phrase, INTENT_PATTERNS)
end

local function HasSelfHarmPhrase(phrase)
    return HasAnyPattern(phrase, SELF_HARM_PHRASE_PATTERNS)
end

local function HasProtectivePurpose(phrase)
    return HasAnyPattern(phrase, PROTECTIVE_PURPOSE_PATTERNS)
end

local function HasContactSolicitation(phrase)
    return HasAnyPattern(phrase, CONTACT_SOLICITATION_PATTERNS)
end

local function HasBenignDiscussion(phrase)
    return HasAnyPattern(phrase, BENIGN_DISCUSSION_PATTERNS)
end

local function HasThreatIntent(phrase)
    return HasAnyPattern(phrase, THREAT_INTENT_PATTERNS)
end

local function HasDirectThreat(phrase)
    return HasAnyPattern(phrase, DIRECT_THREAT_PATTERNS)
end

local function HasIllicitFacilitation(phrase)
    return HasAnyPattern(phrase, ILLICIT_FACILITATION_PATTERNS)
end

local function HasSelfHarmEncouragement(phrase)
    return HasAnyPattern(phrase, SELF_HARM_ENCOURAGEMENT_PATTERNS)
end

local function HasSelfHarmMethodSeeking(phrase)
    return HasAnyPattern(phrase, SELF_HARM_METHOD_SEEKING_PATTERNS)
end

local function HasUnderageAgeSignal(text)
    local lower = tostring(text or ""):lower()
    if lower:find("under 18", 1, true) or lower:find("under eighteen", 1, true) then
        return true
    end

    -- "14 year old", "14-year-old", "14 years old". We intentionally require the
    -- age wording; a bare number in ESO chat is not meaningful for this check.
    for ageText in lower:gmatch("(%d+)%s+years%s+old") do
        local age = tonumber(ageText)
        if age and age < 18 then return true end
    end
    for ageText in lower:gmatch("(%d+)%s+year%s+old") do
        local age = tonumber(ageText)
        if age and age < 18 then return true end
    end
    for ageText in lower:gmatch("(%d+)%-year%-old") do
        local age = tonumber(ageText)
        if age and age < 18 then return true end
    end
    for ageText in lower:gmatch("(%d+)%s+year%-old") do
        local age = tonumber(ageText)
        if age and age < 18 then return true end
    end
    for ageText in lower:gmatch("(%d+)%s*yo") do
        local age = tonumber(ageText)
        if age and age < 18 then return true end
    end
    for ageText in lower:gmatch("(%d+)%s*y/o") do
        local age = tonumber(ageText)
        if age and age < 18 then return true end
    end

    -- Common conversational age disclosures. These signals are only meaningful when
    -- combined with sexual/exploitative/contact context later, so recognizing them here
    -- does not make ordinary numbers unsafe.
    for ageText in lower:gmatch("age%s+(%d%d?)") do
        local age = tonumber(ageText)
        if age and age < 18 then return true end
    end
    for ageText in lower:gmatch("i%s+am%s+(%d%d?)") do
        local age = tonumber(ageText)
        if age and age < 18 then return true end
    end
    for ageText in lower:gmatch("im%s+(%d%d?)") do
        local age = tonumber(ageText)
        if age and age < 18 then return true end
    end
    for ageText in lower:gmatch("he%s+is%s+(%d%d?)") do
        local age = tonumber(ageText)
        if age and age < 18 then return true end
    end
    for ageText in lower:gmatch("she%s+is%s+(%d%d?)") do
        local age = tonumber(ageText)
        if age and age < 18 then return true end
    end
    for ageText in lower:gmatch("they%s+are%s+(%d%d?)") do
        local age = tonumber(ageText)
        if age and age < 18 then return true end
    end
    for ageText in lower:gmatch("(%d%d?)%s*[fm]%f[%W]") do
        local age = tonumber(ageText)
        if age and age >= 10 and age < 18 then return true end
    end

    return false
end

local function GetLocalWindow(context)
    if not context then return "", 1, 0 end
    local text = tostring(context.text or "")
    local cursor = tonumber(context.cursor)
    local startIndex = tonumber(context.startIndex or context.tokenStart)
    local endIndex = tonumber(context.endIndex or context.tokenEnd)

    local center = cursor or startIndex or #text
    center = math.max(0, math.min(#text, center))
    local windowStart = math.max(1, center - 140)
    local windowEnd = math.min(#text, math.max(center + 80, endIndex or center))
    return text:sub(windowStart, windowEnd), windowStart, windowEnd
end

local function ComposeCandidateWindow(context, candidate, fallbackLocalText, windowStart, windowEnd)
    if not context then return tostring(candidate or "") end
    local text = tostring(context.text or "")
    local startIndex = tonumber(context.startIndex or context.tokenStart)
    local endIndex = tonumber(context.endIndex or context.tokenEnd)

    if startIndex and endIndex and startIndex >= 1 and endIndex >= startIndex - 1 then
        local replacementEnd = math.max(startIndex - 1, endIndex)
        local composed = text:sub(1, startIndex - 1) .. tostring(candidate or "") .. text:sub(replacementEnd + 1)
        local adjustedEnd = math.min(#composed, (windowEnd or #composed) + #tostring(candidate or ""))
        return composed:sub(windowStart or 1, adjustedEnd)
    end

    return tostring(fallbackLocalText or "") .. " " .. tostring(candidate or "")
end

local function BuildContextProfile(context)
    if not context then return nil end
    if context._fscSuggestionSafetyProfile then return context._fscSuggestionSafetyProfile end

    local localText, windowStart, windowEnd = GetLocalWindow(context)
    local tokens = {}
    AddTokens(localText, tokens)
    local phrase = NormalizePhrase(localText)

    local profile = {
        localText = localText,
        windowStart = windowStart,
        windowEnd = windowEnd,
        tokens = tokens,
        phrase = phrase,
        hasGeneralRisk = HasAny(tokens, GENERAL_RISK_TOKENS),
        hasControlled = HasAny(tokens, CONTROLLED_TRANSACTION_TOKENS),
        hasOperational = HasAny(tokens, OPERATIONAL_TOKENS),
        hasGame = HasAny(tokens, GAME_CONTEXT_TOKENS)
            or phrase:find(" elder scrolls ", 1, true) ~= nil,
        hasIntent = HasIntentPattern(phrase),
        hasProtectivePurpose = HasProtectivePurpose(phrase),

        hasSelfHarmTopic = HasAny(tokens, SELF_HARM_TOPIC_TOKENS),
        hasSelfHarmOutcome = HasAny(tokens, SELF_HARM_OUTCOME_TOKENS),
        hasSelfHarmMethod = HasAny(tokens, SELF_HARM_METHOD_TOKENS),
        hasStrongSelfHarmMethod = HasAny(tokens, STRONG_SELF_HARM_METHOD_TOKENS),
        hasSelfReference = HasAny(tokens, SELF_REFERENCE_TOKENS),
        hasSelfHarmPhrase = HasSelfHarmPhrase(phrase),

        hasStrongMinor = HasAny(tokens, STRONG_MINOR_TOKENS),
        hasSoftMinor = HasAny(tokens, SOFT_MINOR_TOKENS),
        hasSexual = HasAny(tokens, SEXUAL_CONTEXT_TOKENS),
        hasExploitation = HasAny(tokens, EXPLOITATION_TOKENS),
        hasUnderageRomantic = HasAny(tokens, UNDERAGE_ROMANTIC_TOKENS),
        hasUnderageContact = HasAny(tokens, UNDERAGE_CONTACT_TOKENS),
        hasUnderageAge = HasUnderageAgeSignal(localText),
        hasContactSolicitation = HasContactSolicitation(phrase),
        hasBenignDiscussion = HasBenignDiscussion(phrase),
        hasViolenceAction = HasAny(tokens, VIOLENCE_ACTION_TOKENS),
        hasPersonTarget = HasAny(tokens, PERSON_TARGET_TOKENS),
    }

    context._fscSuggestionSafetyProfile = profile
    return profile
end

-- Build a compact risk vector for a piece of local text. Scores are ordinal rather than
-- probabilistic: 0 means no relevant signal, while 4 means the phrase has crossed the
-- point where the addon should not proactively add a completion in that category.
--
-- The important design choice is that we score BOTH the text as the player has typed it
-- and the hypothetical text after inserting the candidate. The candidate is suppressed
-- only when it creates/increases a hazardous completion (or itself extends one). This
-- "risk delta" behavior preserves prediction quality even inside sensitive discussions.
local function EvaluateRiskState(text)
    local tokens = {}
    AddTokens(text, tokens)
    local phrase = NormalizePhrase(text)

    local state = {
        phrase = phrase,
        tokens = tokens,
        protective = HasProtectivePurpose(phrase),
        benignDiscussion = HasBenignDiscussion(phrase),
        game = HasAny(tokens, GAME_CONTEXT_TOKENS) or phrase:find(" elder scrolls ", 1, true) ~= nil,
        selfHarm = 0,
        minors = 0,
        illicit = 0,
        threat = 0,
    }

    -----------------------------------------------------------------------------
    -- Suicide / self-harm
    -----------------------------------------------------------------------------
    local shTopic = HasAny(tokens, SELF_HARM_TOPIC_TOKENS)
    local shOutcome = HasAny(tokens, SELF_HARM_OUTCOME_TOKENS)
    local shMethod = HasAny(tokens, SELF_HARM_METHOD_TOKENS)
    local shStrongMethod = HasAny(tokens, STRONG_SELF_HARM_METHOD_TOKENS)
    local selfRef = HasAny(tokens, SELF_REFERENCE_TOKENS)
    local intent = HasIntentPattern(phrase)
    local operational = HasAny(tokens, OPERATIONAL_TOKENS)
    local shPhrase = HasSelfHarmPhrase(phrase)
    local encouragement = HasSelfHarmEncouragement(phrase)
    local methodSeeking = HasSelfHarmMethodSeeking(phrase)

    if shTopic or shOutcome or shMethod or selfRef then state.selfHarm = 1 end
    if shTopic and (shMethod or shOutcome or selfRef) then state.selfHarm = math.max(state.selfHarm, 2) end
    if selfRef and intent and (shMethod or shOutcome) then state.selfHarm = math.max(state.selfHarm, 3) end
    if shStrongMethod and intent then state.selfHarm = math.max(state.selfHarm, 4) end
    if shTopic and intent and (shMethod or shOutcome or operational) then state.selfHarm = math.max(state.selfHarm, 4) end
    if shPhrase or encouragement or methodSeeking or tokens.kms then state.selfHarm = 4 end

    -- Protective/supportive framing lowers ambiguous discussion but does not erase an
    -- explicit harmful instruction/encouragement. That prevents phrases such as
    -- "suicide prevention ... how to overdose" from becoming a universal bypass.
    if state.protective and state.selfHarm > 0 and not (shPhrase or encouragement or methodSeeking or tokens.kms or (shStrongMethod and intent)) then
        state.selfHarm = math.max(0, state.selfHarm - 2)
    elseif state.benignDiscussion and state.selfHarm > 0 and state.selfHarm < 4 then
        state.selfHarm = math.max(0, state.selfHarm - 1)
    end

    -----------------------------------------------------------------------------
    -- Sexual/exploitative content involving minors
    -----------------------------------------------------------------------------
    local strongMinor = HasAny(tokens, STRONG_MINOR_TOKENS)
    local softMinor = HasAny(tokens, SOFT_MINOR_TOKENS)
    local underageAge = HasUnderageAgeSignal(text)
    local sexual = HasAny(tokens, SEXUAL_CONTEXT_TOKENS)
    local exploitation = HasAny(tokens, EXPLOITATION_TOKENS)
    local romantic = HasAny(tokens, UNDERAGE_ROMANTIC_TOKENS)
    local contact = HasAny(tokens, UNDERAGE_CONTACT_TOKENS)
    local adultTarget = HasAny(tokens, UNDERAGE_ADULT_TARGET_TOKENS)
    local contactSolicitation = HasContactSolicitation(phrase)
    local lookingFor = phrase:find(" looking for ", 1, true) ~= nil

    if strongMinor or softMinor or underageAge or sexual or exploitation then state.minors = 1 end
    if (strongMinor or underageAge) and (sexual or exploitation) then state.minors = 4 end
    if underageAge and romantic then state.minors = math.max(state.minors, 4) end
    if underageAge and contact and contactSolicitation then state.minors = math.max(state.minors, 4) end
    if underageAge and adultTarget and lookingFor then state.minors = math.max(state.minors, 4) end
    if softMinor and sexual and (intent or exploitation or contactSolicitation) then state.minors = math.max(state.minors, 4) end
    if (strongMinor or underageAge) and exploitation and (intent or operational) then state.minors = math.max(state.minors, 4) end

    -- Benign discussion can reduce a pre-existing sensitive topic, but never makes a
    -- candidate that itself introduces the sexual/minor combination eligible; the
    -- candidate-delta check below handles that conservatively.
    if state.protective and state.minors > 0 and state.minors < 4 then
        state.minors = math.max(0, state.minors - 1)
    elseif state.benignDiscussion and state.minors > 0 and state.minors < 4 then
        state.minors = math.max(0, state.minors - 1)
    end

    -----------------------------------------------------------------------------
    -- General illicit facilitation
    -----------------------------------------------------------------------------
    local generalRisk = HasAny(tokens, GENERAL_RISK_TOKENS)
    local controlled = HasAny(tokens, CONTROLLED_TRANSACTION_TOKENS)
    local operationalRisk = HasAny(tokens, OPERATIONAL_TOKENS)
    local illicitPattern = HasIllicitFacilitation(phrase)

    if generalRisk then state.illicit = 1 end
    if generalRisk and operationalRisk then state.illicit = math.max(state.illicit, 2) end
    if generalRisk and intent then state.illicit = math.max(state.illicit, 3) end
    if generalRisk and operationalRisk and intent then state.illicit = math.max(state.illicit, 4) end
    if illicitPattern and (generalRisk or controlled) then state.illicit = 4 end
    if controlled and operationalRisk and intent then state.illicit = math.max(state.illicit, 4) end

    -- Game context only relaxes game-ambiguous crime language. Strong real-world terms
    -- (scams, malware, hard drugs, explosives, kidnapping, sexual violence) never get
    -- this exemption merely because "ESO" or "guild" appears nearby.
    local strongRealWorldRisk = HasAny(tokens, STRONG_REALWORLD_RISK_TOKENS)
    if state.game and state.illicit > 0 and not strongRealWorldRisk and not illicitPattern then
        state.illicit = math.max(0, state.illicit - 3)
    end

    -- Reporting is a directional protective purpose for this domain. It may neutralize
    -- "report a scam" but cannot neutralize a phrase that separately contains an
    -- explicit facilitation/evasion pattern.
    local reportingPurpose = phrase:find(" report ", 1, true) ~= nil
        or phrase:find(" reporting ", 1, true) ~= nil
        or phrase:find(" reported ", 1, true) ~= nil
    if (state.protective or reportingPurpose) and state.illicit > 0 and not illicitPattern then
        state.illicit = math.max(0, state.illicit - 3)
    elseif state.benignDiscussion and state.illicit > 0 and state.illicit < 4 then
        state.illicit = math.max(0, state.illicit - 1)
    end

    -----------------------------------------------------------------------------
    -- Direct interpersonal threats / violent intent
    -----------------------------------------------------------------------------
    local violenceAction = HasAny(tokens, VIOLENCE_ACTION_TOKENS)
    local personTarget = HasAny(tokens, PERSON_TARGET_TOKENS) or HasAnyPattern(phrase, PERSON_TARGET_PATTERNS)
    local threatIntent = HasThreatIntent(phrase)
    local directThreat = HasDirectThreat(phrase)

    if violenceAction then state.threat = 1 end
    if violenceAction and personTarget then state.threat = math.max(state.threat, 2) end
    if violenceAction and personTarget and threatIntent then state.threat = 4 end
    if directThreat and threatIntent then state.threat = 4 end

    if state.protective and state.threat > 0 and state.threat < 4 then
        state.threat = math.max(0, state.threat - 1)
    elseif state.benignDiscussion and state.threat > 0 and state.threat < 4 then
        state.threat = math.max(0, state.threat - 1)
    end

    return state
end

local function CandidateCategorySignals(candidateTokens)
    return {
        selfHarm = HasAny(candidateTokens, SELF_HARM_TOPIC_TOKENS)
            or HasAny(candidateTokens, SELF_HARM_OUTCOME_TOKENS)
            or HasAny(candidateTokens, SELF_HARM_METHOD_TOKENS)
            or HasAny(candidateTokens, SELF_REFERENCE_TOKENS),
        minors = HasAny(candidateTokens, STRONG_MINOR_TOKENS)
            or HasAny(candidateTokens, SOFT_MINOR_TOKENS)
            or HasAny(candidateTokens, SEXUAL_CONTEXT_TOKENS)
            or HasAny(candidateTokens, EXPLOITATION_TOKENS)
            or HasAny(candidateTokens, UNDERAGE_ROMANTIC_TOKENS)
            or HasAny(candidateTokens, UNDERAGE_CONTACT_TOKENS)
            or HasAny(candidateTokens, UNDERAGE_ADULT_TARGET_TOKENS),
        illicit = HasAny(candidateTokens, GENERAL_RISK_TOKENS)
            or HasAny(candidateTokens, CONTROLLED_TRANSACTION_TOKENS)
            or HasAny(candidateTokens, OPERATIONAL_TOKENS),
        threat = HasAny(candidateTokens, VIOLENCE_ACTION_TOKENS)
            or HasAny(candidateTokens, PERSON_TARGET_TOKENS),
        protective = HasAny(candidateTokens, PROTECTIVE_CANDIDATE_TOKENS),
    }
end

local function CrossesUnsafeBoundary(beforeScore, afterScore, candidateRelevant)
    if afterScore < 4 then return false end
    -- A candidate that turns a previously non-actionable phrase into a hazardous one
    -- is rejected. If the text was already hazardous, neutral words are still allowed,
    -- but another category-relevant completion is not proactively supplied.
    if beforeScore < 4 then return true end
    if candidateRelevant then return true end
    return false
end

function FSC:IsSuggestionSafe(candidate, context, source)
    if not candidate or candidate == "" then return false end

    local candidateTokens = {}
    local foundToken = false
    local normalized = tostring(candidate):gsub("’", "'"):lower()

    -- The same word can enter one prediction request from several sources (seed,
    -- personal model, runtime vocabulary, etc.). Safety is source-independent, so
    -- cache the final decision on the request context and avoid reclassifying it.
    local safetyCache = nil
    if context then
        safetyCache = context._fscSuggestionSafetyCandidateCache
        if not safetyCache then
            safetyCache = {}
            context._fscSuggestionSafetyCandidateCache = safetyCache
        end
        local cached = safetyCache[normalized]
        if cached ~= nil then return cached end
    end
    local function Finish(value)
        if safetyCache then safetyCache[normalized] = value end
        return value
    end

    for token in normalized:gmatch("[a-z']+") do
        foundToken = true
        token = NormalizeSafetyToken(token)
        if IsAlwaysBlockedToken(token) then return Finish(false) end
        if token ~= "" then
            candidateTokens[token] = true
            if #token > 2 and token:sub(-2) == "'s" then candidateTokens[token:sub(1, -3)] = true end
        end
    end
    if not foundToken then return Finish(false) end

    local signals = CandidateCategorySignals(candidateTokens)

    -- Protective completions themselves (help, hotline, report, safety, etc.) are safe
    -- to offer even when the surrounding conversation is sensitive. Typed text is never
    -- modified either way.
    if signals.protective then return Finish(true) end

    local profile = BuildContextProfile(context)
    if not profile then return Finish(true) end

    -- Keep the common path extremely cheap. This is intentionally broader than the old
    -- fast path only by a few direct-threat signals; it does not touch model scoring.
    local contextSensitive = profile.hasGeneralRisk or profile.hasSelfHarmTopic
        or profile.hasSelfHarmOutcome or profile.hasSelfHarmMethod or profile.hasSelfReference
        or profile.hasSelfHarmPhrase or profile.hasStrongMinor or profile.hasSoftMinor
        or profile.hasSexual or profile.hasExploitation or profile.hasUnderageAge
        or profile.hasUnderageRomantic or profile.hasUnderageContact
        or profile.hasViolenceAction or profile.hasPersonTarget

    local candidateSensitive = signals.selfHarm or signals.minors or signals.illicit or signals.threat
    if not contextSensitive and not candidateSensitive then return Finish(true) end

    local beforeText = profile.localText or ""
    local composedText = ComposeCandidateWindow(
        context, candidate, profile.localText, profile.windowStart, profile.windowEnd
    )

    local before = profile.beforeRiskState
    if not before then
        before = EvaluateRiskState(beforeText)
        profile.beforeRiskState = before
    end
    local after = EvaluateRiskState(composedText)

    -- Highest-priority domains first. Game vocabulary never overrides these checks.
    if CrossesUnsafeBoundary(before.minors, after.minors, signals.minors) then return Finish(false) end
    if CrossesUnsafeBoundary(before.selfHarm, after.selfHarm, signals.selfHarm) then return Finish(false) end
    if CrossesUnsafeBoundary(before.threat, after.threat, signals.threat) then return Finish(false) end
    if CrossesUnsafeBoundary(before.illicit, after.illicit, signals.illicit) then return Finish(false) end

    return Finish(true)
end

return FSC

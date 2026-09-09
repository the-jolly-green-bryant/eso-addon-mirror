local TT = TamrielicTongues

TT.Comprehension = {}

-- Counts describe token occurrences and clause/grammar pairs, never decoded text.
function TT.Comprehension:Render(document, knowledge)
    local stats = {
        words = 0, translatedWords = 0, unknownWords = 0,
        grammarBlockedWords = 0, clauses = 0, blockedClauses = 0,
        grammarRequirements = 0, knownGrammarRequirements = 0,
        unmetGrammarRequirements = 0,
    }
    local allowed = {}
    for id, clause in pairs(document.clauses) do
        local understood = true
        stats.clauses = stats.clauses + 1
        for construction, requirement in pairs(clause.grammar) do
            stats.grammarRequirements = stats.grammarRequirements + 1
            if TT.Knowledge:KnowsGrammar(knowledge, construction, requirement) then
                stats.knownGrammarRequirements = stats.knownGrammarRequirements + 1
            else
                understood = false
                stats.unmetGrammarRequirements = stats.unmetGrammarRequirements + 1
            end
        end
        allowed[id] = understood
        if not understood then stats.blockedClauses = stats.blockedClauses + 1 end
    end

    local output = {}
    for index, token in ipairs(document.tokens) do
        local text = token.original
        if token.kind == "word" then
            stats.words = stats.words + 1
            if token.unknown then stats.unknownWords = stats.unknownWords + 1 end
            -- Missing clause scope fails closed too. OOV cannot be explicitly mastered.
            if not allowed[token.clauseId] then
                stats.grammarBlockedWords = stats.grammarBlockedWords + 1
            elseif (token.unknown and TT.Knowledge:GetVocabularyLevel(knowledge) == 100)
                or (not token.unknown and TT.Knowledge:KnowsVocabulary(
                    knowledge, token.conceptId, token.requirement)) then
                text = token.decoded
                stats.translatedWords = stats.translatedWords + 1
            end
        end
        output[index] = text
    end
    return table.concat(output), stats
end

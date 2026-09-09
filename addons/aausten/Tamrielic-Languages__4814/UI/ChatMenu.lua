local TT = TamrielicTongues

TT.ChatMenu = {}

function TT.ChatMenu:GetActiveLanguageLabel()
    local id = TT.Settings:GetActiveLanguage()
    if id == TT.Constants.COMMON_LANGUAGE_ID then
        return TT.Locale:Get("COMMON_NAME")
    end
    local profile = TT.Registry:Resolve(id)
    return profile and TT.Locale:LanguageName(profile) or id
end

function TT.ChatMenu:CycleLanguage(direction)
    local ordered = TT.Registry:GetOrdered()
    local ids = { TT.Constants.COMMON_LANGUAGE_ID }
    for _, profile in ipairs(ordered) do
        ids[#ids + 1] = profile.id
    end

    local current = TT.Settings:GetActiveLanguage()
    local index = 1
    for i, id in ipairs(ids) do
        if id == current then
            index = i
            break
        end
    end

    local delta = direction and direction < 0 and -1 or 1
    index = index + delta
    if index < 1 then
        index = #ids
    elseif index > #ids then
        index = 1
    end

    TT.Settings:SetActiveLanguage(ids[index])
    return ids[index]
end

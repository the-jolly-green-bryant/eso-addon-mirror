local TT = TamrielicTongues

TT.ChatInput = {
    hooked = false,
}

function TT.ChatInput:GetMaxCharacters()
    if type(MAX_TEXT_CHAT_INPUT_CHARACTERS) == "number" then
        return MAX_TEXT_CHAT_INPUT_CHARACTERS
    end
    return TT.Constants.DEFAULT_MAX_CHAT_CHARACTERS
end

function TT.ChatInput:BeforeSubmit(chatSystem)
    local languageId = TT.Settings:GetActiveLanguage()
    if languageId == TT.Constants.COMMON_LANGUAGE_ID then
        return false
    end

    if not chatSystem or not chatSystem.textEntry then
        return false
    end

    local text = chatSystem.textEntry:GetText()
    if not text or text == "" then
        return false
    end

    -- Slash commands must remain native ESO commands.
    if text:sub(1, 1) == "/" then
        return false
    end

    -- Preserve forwarded messages even if their marker version/language is
    -- newer than this client can decode. Legacy signatures are recognized too.
    if TT.Versioning:ParseMarker(text) ~= nil or TT.MessageDetector:Detect(text) then
        return false
    end

    local encoded, errorMessage = TT.Translator:Encode(languageId, text)
    if not encoded then
        TT:Print(errorMessage or TT.Locale:Get("TRANSLATE_FAILED"))
        return true
    end

    local maxCharacters = self:GetMaxCharacters()
    if #encoded > maxCharacters then
        TT:Print(TT.Locale:Get(
            "MESSAGE_TOO_LONG",
            #encoded,
            maxCharacters
        ))
        return true
    end

    chatSystem.textEntry:SetText(encoded)
    return false
end

function TT.ChatInput:Initialize()
    if self.hooked then
        return
    end

    if not SharedChatSystem or not ZO_PreHook then
        TT:Print(TT.Locale:Get("HOOK_FAILED"))
        return
    end

    ZO_PreHook(SharedChatSystem, "SubmitTextEntry", function(chatSystem)
        return TT.ChatInput:BeforeSubmit(chatSystem)
    end)

    self.hooked = true
end

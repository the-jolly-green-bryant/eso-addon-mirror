local TT = TamrielicTongues

TT.Formatter = {}

function TT.Formatter:Translation(profile, decoded)
    if TT.saved and TT.saved.showLanguageName then
        return string.format(
            "|c%s%s|r %s",
            TT.Constants.TRANSLATION_PREFIX_COLOR,
            TT.Locale:Get("TRANSLATION_PREFIX", TT.Locale:LanguageName(profile)),
            decoded
        )
    end

    return decoded
end

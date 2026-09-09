local TT = TamrielicTongues

TT.MessageDetector = {}

function TT.MessageDetector:Detect(text)
    return TT.Translator:Detect(text)
end

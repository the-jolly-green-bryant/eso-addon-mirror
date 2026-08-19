local strings = {
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS
        = "탐욕스러운 백작부인 추적",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS_TOOLTIP
        = "탐욕스러운 백작부인 보물 사냥에 사용 가능한 보물을 표시합니다.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW
        = "공물의 회계 담당자 추적",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW_TOOLTIP
        = "공물의 회계 담당자(까마귀) 보물 사냥에 사용 가능한 보물을 표시합니다.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_SETTINGS
        = "설정",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_ON
        = "탐욕스러운 백작부인 추적: 켜짐",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_OFF
        = "탐욕스러운 백작부인 추적: 꺼짐",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_ON
        = "공물의 회계 담당자 추적: 켜짐",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_OFF
        = "공물의 회계 담당자 추적: 꺼짐",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end

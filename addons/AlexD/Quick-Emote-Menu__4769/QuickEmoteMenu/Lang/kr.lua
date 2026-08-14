local strings = {
    SI_QUICKEMOTEMENU_UNKNOWN_NAME         = "?",
    SI_QUICKEMOTEMENU_CATEGORIES           = "카테고리",
    SI_QUICKEMOTEMENU_FAVORITES            = "즐겨찾기",
    SI_QUICKEMOTEMENU_NO_FAVORITES         = "(비어 있음)",
    SI_QUICKEMOTEMENU_BINDING_TOGGLE       = "전환",
    SI_QUICKEMOTEMENU_OPTION_HOVER         = "하위 메뉴 호버 지연 (ms)",
    SI_QUICKEMOTEMENU_OPTION_HOVER_TOOLTIP = "0 = 클릭 시에만 열기",
    SI_QUICKEMOTEMENU_OPTION_CLOSE         = "이모트 재생 후 메뉴 닫기 (좌클릭)",
    SI_QUICKEMOTEMENU_OPTION_RESET         = "버튼 위치 초기화",
    SI_QUICKEMOTEMENU_OPTION_DESCRIPTION   = [[|c3399FF조작|r
• 버튼을 좌클릭하여 메뉴 열기/닫기
• 우클릭 후 드래그하여 버튼 이동
• 이모트를 좌클릭하여 재생
• 이모트를 우클릭하여 즐겨찾기 추가/제거

|c3399FF메뉴|r
• 카테고리 — 카테고리별 이모트 탐색
• 즐겨찾기 — 저장된 이모트 빠른 접근
• 하위 메뉴는 호버 또는 클릭 시 열림 (지연 설정 참조)
• 메뉴는 버튼 위치에 따라 상하좌우로 열림

|c3399FF팁|r
• 단축키로 메뉴 전환
• /qempanel 로 이 설정 패널 열기
• 즐겨찾기는 계정 전체에 저장]],
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end

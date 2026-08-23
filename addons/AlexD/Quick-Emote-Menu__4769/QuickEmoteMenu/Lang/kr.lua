local strings = {
    SI_QUICKEMOTEMENU_UNKNOWN_NAME          = "?",
    SI_QUICKEMOTEMENU_CATEGORIES            = "카테고리",
    SI_QUICKEMOTEMENU_FAVORITES             = "즐겨찾기",
    SI_QUICKEMOTEMENU_NO_FAVORITES          = "(비어 있음)",
    SI_QUICKEMOTEMENU_BINDING_TOGGLE        = "전환",
    SI_QUICKEMOTEMENU_OPTION_HOVER          = "하위 메뉴 호버 지연 (ms)",
    SI_QUICKEMOTEMENU_OPTION_HOVER_TOOLTIP  = "0 = 클릭 시에만 열기",
    SI_QUICKEMOTEMENU_OPTION_UIMODE         = "UI 모드에서만 버튼 표시",
    SI_QUICKEMOTEMENU_OPTION_UIMODE_TOOLTIP =
    "마우스 커서가 활성화된 경우(UI 모드)에만 메인 버튼을 표시합니다. 일반 게임/상호작용 모드로 돌아가면 숨겨집니다.",
    SI_QUICKEMOTEMENU_OPTION_DETACH         = "채팅에서 버튼 분리",
    SI_QUICKEMOTEMENU_OPTION_DETACH_TOOLTIP = "채팅 창 밖으로 버튼을 이동합니다. 버튼을 자유롭게 드래그하여 이동할 수 있습니다.",
    SI_QUICKEMOTEMENU_OPTION_SETTINGS       = "설정",
    SI_QUICKEMOTEMENU_OPTION_ATTACH_BUTTON  = "버튼 연결",
    SI_QUICKEMOTEMENU_OPTION_DETACH_BUTTON  = "버튼 분리",
    SI_QUICKEMOTEMENU_OPTION_SHOW_PANEL     = "설정 패널 표시",
    SI_QUICKEMOTEMENU_OPTION_CLOSE          = "이모트 재생 후 메뉴 닫기 (좌클릭)",
    SI_QUICKEMOTEMENU_OPTION_RESET          = "버튼 위치 초기화",
    SI_QUICKEMOTEMENU_OPTION_CHAT_BUTTON_OFFSET_X         = "채팅 버튼 X 오프셋",
    SI_QUICKEMOTEMENU_OPTION_CHAT_BUTTON_OFFSET_X_TOOLTIP = "채팅 창 옵션 버튼을 기준으로 한 버튼의 가로 오프셋입니다. 버튼이 채팅 창에 연결된 경우에만 적용됩니다.",
    SI_QUICKEMOTEMENU_OPTION_DESCRIPTION    = [[
|c3399FF기능|r
• 카테고리와 즐겨찾기를 통한 빠른 이모트 접근
• 카테고리와 이모트는 게임 데이터에서 직접 불러옵니다
• 게임에 추가된 새로운 이모트는 목록에 자동으로 표시됩니다

|c3399FF조작|r
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
• 즐겨찾기는 계정 전체에 저장
]],
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end

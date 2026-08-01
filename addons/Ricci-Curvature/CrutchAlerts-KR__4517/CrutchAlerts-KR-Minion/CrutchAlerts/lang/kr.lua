local function TamrielKR_IsKoreanClient()
	if TamrielKR and TamrielKR.GetLanguage then
		local ok, lang = pcall(TamrielKR.GetLanguage, TamrielKR)
		if ok and lang == "kr" then
			return true
		end
	end
	return GetCVar("language.2") == "kr"
end

if not TamrielKR_IsKoreanClient() then
	return
end

local Crutch = CrutchAlerts
if not Crutch then return end

local function GetActualLanguage()
    if TamrielKR and type(TamrielKR.GetLanguage) == "function" then
        return tostring(TamrielKR:GetLanguage())
    end
    return tostring(GetCVar("language.2"))
end

if GetActualLanguage() ~= "kr" then return end

local MENU_TRANSLATIONS = {
    ["Unlock UI"] = "UI 잠금 해제",
    ["General"] = "일반",
    ["Show begin casts"] = "시전 시작 경고 표시",
    ["      Show non-enemy casts"] = "      비적대 시전도 표시",
    ["Show gained casts"] = "획득형 시전 경고 표시",
    ["Show casts on others"] = "다른 대상 경고 표시",
    ["Alert size"] = "경고 크기",
    ["Show damageable timers"] = "공격 가능 타이머 표시",
    ["    Consolidate damageable to info panel"] = "    공격 가능 타이머를 정보 패널에 통합",
    ["Show arcanist timers"] = "아카니스트 타이머 표시",
    ["Show Magma Shell Timer"] = "Magma Shell 타이머 표시",
    ["Show dragonknight Magma Shell"] = "드래곤나이트 마그마 셸 표시",
    ["Show dragonknight Engulfing Dragonfire"] = "드래곤나이트 인걸핑 드래곤파이어 표시",
    ["Show templar Radiant Destruction"] = "템플러 광휘의 파괴 표시",
    ["Show Fencer's Parry"] = "펜서의 패리 표시",
    ["Show Voltaic Overload Timer"] = "Voltaic Overload 타이머 표시",
    ["Show Fate Sealer Timer"] = "Fate Sealer 타이머 표시",
    ["Show Arcane Knot Timer"] = "Arcane Knot 타이머 표시",
    ["Show Shattered Timer"] = "Shattered 타이머 표시",
    ["Show Radiant Lamplight Timer"] = "Radiant Lamplight 타이머 표시",
    ["Show Death Touch Timer"] = "Death Touch 타이머 표시",
    ["Advanced IDs"] = "고급 ID 설정",
    ["Blacklist IDs, separated by commas"] = "차단할 ID 목록 (쉼표 구분)",
    ["Vertical Boss Health Bar"] = "세로 보스 체력바",
    ["Show boss health bar"] = "보스 체력바 표시",
    ["Use horizontal bars"] = "가로형 체력바 사용",
    ["Size"] = "크기",
    ["Foreground color"] = "전경 색상",
    ["Background color"] = "배경 색상",
    ["Use \"floor\" rounding"] = "\"내림\" 반올림 사용",
    ["Rounding: Why?"] = "반올림: 이유",
    ["Info Panel"] = "정보 패널",
    ["In-World Icons / Textures"] = "월드 아이콘 / 텍스처",
    ["Update interval"] = "업데이트 간격",
    ["Use drawing levels"] = "그리기 레벨 사용",
    ["Group Member Icons"] = "그룹원 아이콘",
    ["Show group icon for self"] = "자신에게도 그룹 아이콘 표시",
    ["Vertical offset"] = "세로 오프셋",
    ["Opacity"] = "투명도",
    ["Hide icons behind objects"] = "오브젝트 뒤 아이콘 숨기기",
    ["Show tanks"] = "탱커 표시",
    ["Tank color"] = "탱커 색상",
    ["Show healers"] = "힐러 표시",
    ["Healer color"] = "힐러 색상",
    ["Show DPS"] = "DPS 표시",
    ["DPS color"] = "DPS 색상",
    ["Show crown"] = "왕관 표시",
    ["Crown color"] = "왕관 색상",
    ["Show dead group members"] = "사망한 그룹원 표시",
    ["Use support icons for dead"] = "사망 시 역할 아이콘 우선 사용",
    ["Dead color"] = "사망 색상",
    ["Resurrecting color"] = "부활 중 색상",
    ["Rez pending color"] = "부활 대기 색상",
    ["Individual Player Icons"] = "개별 플레이어 아이콘",
    ["Add new player icon"] = "새 플레이어 아이콘 추가",
    ["Select player to edit"] = "편집할 플레이어 선택",
    ["Delete player icon"] = "플레이어 아이콘 삭제",
    ["Texture type"] = "텍스처 유형",
    ["Custom texture path"] = "사용자 지정 텍스처 경로",
    ["Texture color"] = "텍스처 색상",
    ["Texture size"] = "텍스처 크기",
    ["Text"] = "텍스트",
    ["Text color"] = "텍스트 색상",
    ["Text size"] = "텍스트 크기",
    ["Positioning Markers"] = "위치 마커",
    ["Use flat icons"] = "평면 아이콘 사용",
    ["Oriented Textures"] = "방향성 텍스처",
    ["Hide textures behind objects"] = "오브젝트 뒤 텍스처 숨기기",
    ["Other Icons"] = "기타 아이콘",
    ["Crowd Control"] = "군중 제어",
    ["Show icon UI"] = "아이콘 UI 표시",
    ["Show obnoxious UI"] = "대형 UI 표시",
    ["Play sound"] = "소리 재생",
    ["Sound volume"] = "소리 볼륨",
    ["Show info in chat"] = "채팅에 정보 표시",
    ["Miscellaneous"] = "기타",
    ["Show subtitles in chat"] = "채팅에 자막 표시",
    ["No-subtitles zones"] = "자막 제외 지역",
    ["Add no-subtitles zone ID"] = "자막 제외 지역 ID 추가",
    ["Enable \"fun\" stuff"] = "\"재미 요소\" 활성화",
    ["Debug"] = "디버그",
    ["Show raid lead diagnostics"] = "레이드 진단 표시",
    ["Show debug on alert"] = "경고에 디버그 표시",
    ["Show debug chat spam"] = "디버그 채팅 스팸 표시",
    ["Show other debug"] = "기타 디버그 표시",
    ["Show line distance"] = "선 거리 표시",
    ["Asylum Sanctorium"] = "Asylum Sanctorium",
    ["Play sound for cone on self"] = "자신 대상 콘 소리 재생",
    ["Play sound for cone on others"] = "다른 대상 콘 소리 재생",
    ["Show minis' health bars"] = "미니 보스 체력바 표시",
    ["Show Llothis name and enrage / respawn"] = "Llothis 이름 및 광폭/재등장 표시",
    ["Show Llothis bolts timer"] = "Llothis 볼트 타이머 표시",
    ["Show Llothis cone timer"] = "Llothis 콘 타이머 표시",
    ["Show Llothis teleport timer"] = "Llothis 순간이동 타이머 표시",
    ["Show Felms name and enrage / respawn"] = "Felms 이름 및 광폭/재등장 표시",
    ["Show Felms teleport timer"] = "Felms 순간이동 타이머 표시",
    ["Cloudrest"] = "Cloudrest",
    ["Show spears indicator"] = "창 인디케이터 표시",
    ["Play spears sound"] = "창 소리 재생",
    ["Show Hoarfrost timer"] = "서리 타이머 표시",
    ["Alert drop Hoarfrost"] = "Hoarfrost 버리기 경고",
    ["Show Hoarfrost icon"] = "Hoarfrost 아이콘 표시",
    ["Show flare sides"] = "플레어 위치 표시",
    ["Show flare icon"] = "플레어 아이콘 표시",
    ["Color Ody death icon"] = "Ody 사망 아이콘 색상 변경",
    ["Dreadsail Reef"] = "Dreadsail Reef",
    ["Alert Building Static stacks"] = "Building Static 중첩 경고",
    ["Building Static stacks threshold"] = "Building Static 경고 기준치",
    ["Alert Volatile Residue stacks"] = "Volatile Residue 중첩 경고",
    ["Volatile Residue stacks threshold"] = "Volatile Residue 경고 기준치",
    ["Show Arcing Cleave guidelines"] = "Arcing Cleave 가이드선 표시",
    ["Halls of Fabrication"] = "Halls of Fabrication",
    ["Show Shock Field for triplets"] = "트리플렛 Shock Field 표시",
    ["Show Assembly General icons"] = "Assembly General 아이콘 표시",
    ["    Assembly General icons size"] = "    Assembly General 아이콘 크기",
    ["|c08BD1DEffect Timers|r"] = "|c08BD1D효과 타이머|r",
    ["Effect Timers"] = "효과 타이머",
    ["|c08BD1DProminent Alerts|r"] = "|c08BD1D강조 경고|r",
    ["Prominent Alerts"] = "강조 경고",
    ["Show prominent alerts"] = "강조 경고 표시",
    ["Alert Direct Current"] = "Direct Current 경고",
    ["Alert Glacial Spikes"] = "Glacial Spikes 경고",
    ["Alert Creeper Spawn"] = "Creeper 생성 경고",
    ["Alert Grievous Retaliation"] = "Grievous Retaliation 경고",
    ["Alert Cascading Boot"] = "Cascading Boot 경고",
    ["Alert Reclaim the Ruined"] = "Reclaim the Ruined 경고",
    ["Alert Stomp"] = "Stomp 경고",
    ["Alert Hemorrhage Ended (Tank Only)"] = "Hemorrhage 종료 경고 (탱커 전용)",
    ["Alert Darkness Inflicted"] = "Darkness Inflicted 경고",
    ["Alert Fate Sealer"] = "Fate Sealer 경고",
    ["Alert Shattering Strike"] = "Shattering Strike 경고",
    ["Alert Thunderous Impact"] = "Thunderous Impact 경고",
    ["Alert Grip of Lorkhaj"] = "Grip of Lorkhaj 경고",
    ["Alert Grasp of Lorkhaj"] = "Grasp of Lorkhaj 경고",
    ["Alert Threshing Wings"] = "Threshing Wings 경고",
    ["Alert Unstable Void"] = "Unstable Void 경고",
    ["Alert Spectral Revenge"] = "Spectral Revenge 경고",
    ["Alert Dominator's Chains"] = "Dominator's Chains 경고",
    ["Alert Savage Blitz"] = "Savage Blitz 경고",
    ["Alert Chain Pull"] = "Chain Pull 경고",
    ["Alert Shield Charge"] = "Shield Charge 경고",
    ["Alert Sundering Gale"] = "Sundering Gale 경고",
    ["Alert Lava Whip"] = "Lava Whip 경고",
    ["Alert Heat Wave"] = "Heat Wave 경고",
    ["Alert Winter's Reach"] = "Winter's Reach 경고",
    ["Alert Draining Poison"] = "Draining Poison 경고",
    ["Alert Meteor Call"] = "Meteor Call 경고",
    ["Alert Venomous Arrow (Arc 4+)"] = "Venomous Arrow 경고 (Arc 4+)",
    ["Alert Poison Arrow Spray"] = "Poison Arrow Spray 경고",
    ["Alert Volatile Poison"] = "Volatile Poison 경고",
    ["Alert Teleport Strike"] = "Teleport Strike 경고",
    ["Alert Soul Tether"] = "Soul Tether 경고",
    ["Kyne's Aegis"] = "Kyne's Aegis",
    ["Show Exploding Spear landing spot"] = "Exploding Spear 착지 지점 표시",
    ["Show Blood Prison icon"] = "Blood Prison 아이콘 표시",
    ["Show Falgravn 2nd floor DPS stacks"] = "Falgravn 2층 DPS 위치 표시",
    ["    Falgravn icon size"] = "    Falgravn 아이콘 크기",
    ["Lucent Citadel"] = "Lucent Citadel",
    ["Show Cavot Agnan spawn spot"] = "Cavot Agnan 생성 위치 표시",
    ["    Cavot Agnan icon size"] = "    Cavot Agnan 아이콘 크기",
    ["Show Orphic Shattered Shard mirror icons"] = "Orphic 거울 아이콘 표시",
    ["    Orphic numbered icons"] = "    Orphic 숫자 아이콘 사용",
    ["    Orphic icons size"] = "    Orphic 아이콘 크기",
    ["Show Arcane Conveyance tether"] = "Arcane Conveyance 연결선 표시",
    ["Show Weakening Charge timer"] = "Weakening Charge 타이머 표시",
    ["Show Xoryn Tempest position icons"] = "Xoryn Tempest 위치 아이콘 표시",
    ["    Tempest icons size"] = "    Tempest 아이콘 크기",
    ["Maw of Lorkhaj"] = "Maw of Lorkhaj",
    ["Show Zhaj'hassa cleanse pad cooldowns"] = "Zhaj'hassa 정화 패드 쿨다운 표시",
    ["Show Twins Aspect icons"] = "Twins Aspect 아이콘 표시",
    ["Show Twins color swap"] = "Twins 색상 전환 경고 표시",
    ["Opulent Ordeal"] = "Opulent Ordeal",
    ["Show Affinity icons"] = "Affinity 아이콘 표시",
    ["Ossein Cage"] = "Ossein Cage",
    ["Show group-wide Caustic Carrion"] = "그룹 전체 Caustic Carrion 표시",
    ["    Show additional group members"] = "    추가 그룹원 정보 표시",
    ["Show titans' health bars"] = "타이탄 체력바 표시",
    ["Show curse positioning icons"] = "저주 위치 아이콘 표시",
    ["    Match AOCH icons"] = "    AOCH 아이콘과 동일하게 사용",
    ["    Show middle icons"] = "    중앙 아이콘도 표시",
    ["    Curse positioning icons size"] = "    저주 위치 아이콘 크기",
    ["Show Enfeeblement debuffs"] = "Enfeeblement 디버프 표시",
    ["Print titan damage on HM"] = "하드모드에서 타이탄 피해 채팅 출력",
    ["Show Stricken timer"] = "Stricken 타이머 표시",
    ["Show Dominator's Chains tether"] = "Dominator's Chains 연결선 표시",
    ["Show time until Titanic Leap"] = "Titanic Leap까지 시간 표시",
    ["Show timer for Titanic Clash"] = "Titanic Clash 타이머 표시",
    ["Rockgrove"] = "Rockgrove",
    ["Show Noxious Sludge sides"] = "Noxious Sludge 좌우 배정 표시",
    ["Show Noxious Sludge icons"] = "Noxious Sludge 아이콘 표시",
    ["Show Bleeding timer"] = "Bleeding 타이머 표시",
    ["Show Death Touch icons"] = "Death Touch 아이콘 표시",
    ["Show time until Noxious Sludge"] = "Noxious Sludge까지 시간 표시",
    ["Show time until Savage Blitz"] = "Savage Blitz까지 시간 표시",
    ["Show time until portal"] = "포탈까지 시간 표시",
    ["Show portal direction"] = "포탈 방향 표시",
    ["Show number of players in portal"] = "포탈 인원 수 표시",
    ["Show time until Sickle Strike"] = "Sickle Strike까지 시간 표시",
    ["Show time until Cursed Ground"] = "Cursed Ground까지 시간 표시",
    ["Show your curse preview lines"] = "내 저주 미리보기 선 표시",
    ["Preview lines color"] = "미리보기 선 색상",
    ["Show your curse lines"] = "내 저주 선 표시",
    ["Curse lines color"] = "저주 선 색상",
    ["Show group members' curse lines"] = "다른 그룹원 저주 선 표시",
    ["Group curse lines color"] = "그룹 저주 선 색상",
    ["Portal number"] = "포탈 번호",
    ["Add dangerous ability"] = "위험 기술 추가",
    ["Remove ability"] = "기술 제거",
    ["Portal time margin"] = "포탈 시간 여유",
    ["Sanity's Edge"] = "Sanity's Edge",
    ["Show Chimera puzzle numbers"] = "키메라 퍼즐 숫자 표시",
    ["Chimera icons size"] = "키메라 아이콘 크기",
    ["Show center of Ansuul arena"] = "Ansuul 전장 중앙 표시",
    ["Ansuul icon size"] = "Ansuul 아이콘 크기",
    ["Sunspire"] = "Sunspire",
    ["Show Lokkestiiz HM beam position icons"] = "Lokkestiiz HM 빔 위치 아이콘 표시",
    ["    Lokkestiiz solo heal icons"] = "    Lokkestiiz 솔힐 아이콘 사용",
    ["Lokkestiiz HM icons size"] = "Lokkestiiz HM 아이콘 크기",
    ["Show some Lokkestiiz HM Storm Breath telegraphs"] = "Lokkestiiz HM 폭풍 숨결 바닥 표시",
    ["Show Yolnahkriin position icons"] = "Yolnahkriin 위치 아이콘 표시",
    ["    Yolnahkriin left position icons"] = "    Yolnahkriin 왼쪽 위치 아이콘 사용",
    ["Yolnahkriin icons size"] = "Yolnahkriin 아이콘 크기",
    ["Show players without Focused Fire"] = "Focused Fire 없는 플레이어 표시",
    ["Show time until Focus Fire"] = "Focus Fire까지 시간 표시",
    ["Show next Eternal Servant mechanic"] = "다음 Eternal Servant 기믹 표시",
    ["Blackrose Prison"] = "Blackrose Prison",
    ["Dragonstar Arena"] = "Dragonstar Arena",
    ["Infinite Archive"] = "Infinite Archive",
    ["Auto mark Fabled"] = "Fabled 자동 표식",
    ["Auto mark Negate casters"] = "Negate 시전자 자동 표식",
    ["Show Brewmaster elixir spot"] = "Brewmaster 엘릭서 위치 표시",
    ["Play sound for Uppercut / Power Bash"] = "Uppercut / Power Bash 소리 재생",
    ["Play sound for dangerous abilities"] = "위험 기술 소리 재생",
    ["Print puzzle solution"] = "퍼즐 해답 출력",
    ["Maelstrom Arena"] = "Maelstrom Arena",
    ["Show the current round"] = "현재 라운드 표시",
    ["Stage 1 extra text"] = "1단계 추가 텍스트",
    ["Stage 2 extra text"] = "2단계 추가 텍스트",
    ["Stage 3 extra text"] = "3단계 추가 텍스트",
    ["Stage 4 extra text"] = "4단계 추가 텍스트",
    ["Stage 5 extra text"] = "5단계 추가 텍스트",
    ["Stage 6 extra text"] = "6단계 추가 텍스트",
    ["Stage 7 extra text"] = "7단계 추가 텍스트",
    ["Stage 8 extra text"] = "8단계 추가 텍스트",
    ["Stage 9 extra text"] = "9단계 추가 텍스트",
    ["Vateshran Hollows"] = "Vateshran Hollows",
    ["Show missed score adds"] = "놓친 점수 쫄 표시",
    ["Black Gem Foundry"] = "Black Gem Foundry",
    ["Show Rupture preview line"] = "Rupture 미리보기 선 표시",
    ["Shipwright's Regret"] = "Shipwright's Regret",
    ["Suggest stacks for Soul Bomb"] = "Soul Bomb 중첩 추천 표시",
    ["Never"] = "안 함",
    ["Tank Only"] = "탱커만",
    ["Always"] = "항상",
    ["Hardmode only"] = "하드모드만",
    ["Veteran + Hardmode"] = "베테랑 + 하드모드",
    ["Self/Heal Only"] = "자신/힐러만",
    ["None"] = "없음",
    ["Portal 1"] = "포탈 1",
    ["Portal 2"] = "포탈 2",
}

local DETAIL_TRANSLATIONS = CrutchAlertsKRTooltips or {}

local THRESHOLD_TRANSLATIONS = {
    ["Beyblade"] = "회전",
    ["Statue Smash"] = "석상 강타",
    ["Shockwave"] = "충격파",
    ["Knockdown"] = "넉다운",
    ["Shield"] = "보호막",
    ["Execute"] = "처형",
    ["Simulacra"] = "시뮬라크라",
    ["Conduits"] = "전도체",
    ["Spinner"] = "스피너",
    ["Reset"] = "초기화",
    ["Terminals"] = "단말기",
    ["Big Jump"] = "대점프",
    ["Siroria starts jumping"] = "시로리아 점프 시작",
    ["Atros + Beam"] = "아트로 + 빔",
    ["Beam + Atros"] = "빔 + 아트로",
    ["Cataclysm"] = "대격변",
    ["Time Shift"] = "시간 왜곡",
    ["Takeoff"] = "이륙",
    ["Enrage"] = "광폭화",
    ["Shamans"] = "주술사",
    ["Conga Line"] = "일렬 이동",
    ["Floor Shatter"] = "바닥 파쇄",
    ["Mini"] = "미니",
    ["Abomination"] = "어보미네이션",
    ["Behemoth"] = "베헤모스",
    ["Meteor"] = "운석",
    ["Run!"] = "도망!",
    ["Atronach"] = "아트로나크",
    ["2nd Teleports"] = "2차 순간이동",
    ["1st Teleports"] = "1차 순간이동",
    ["Same-color Atro"] = "같은 색 아트로",
    ["Off-color Atro"] = "다른 색 아트로",
    ["Big Split"] = "대분열",
    ["Split"] = "분열",
    ["Winter Storm"] = "겨울 폭풍",
    ["Bridge"] = "다리",
    ["Wamasu"] = "와마수",
    ["Portals"] = "포탈",
    ["Shrapnel"] = "파편",
    ["Fires start"] = "불 시작",
    ["Gargoyle"] = "가고일",
    ["Monstrous Growth"] = "거대 성장",
    ["Harvester"] = "하베스터",
    ["Prisoners"] = "죄수",
    ["Shades"] = "그림자",
    ["Chudan"] = "추단",
    ["Xal Nur"] = "잘 누르",
    ["Brazier"] = "화로",
    ["Banish"] = "추방",
    ["Grove"] = "숲",
    ["Adds"] = "쫄",
    ["Grovel"] = "엎드리기",
    ["Crystal"] = "수정",
    ["Colossus"] = "콜로서스",
    ["Stone Orb"] = "돌 구슬",
    ["Leiminid"] = "레이미니드",
    ["Winter's Purge"] = "겨울의 숙청",
}

local EXACT_RUNTIME_TRANSLATIONS = {
    ["|c6a00ffTETHERED!|r"] = "|c6a00ff연결됨!|r",
    ["|cCCCCCCUp next:|r"] = "|cCCCCCC다음:|r",
    ["|cff00ffSeeking Surge dropped!|r"] = "|cff00ffSeeking Surge 드롭!|r",
    ["Blazing Flame Atronach"] = "불타는 화염 아트로나크",
    ["Sparking Cold-Flame Atronach"] = "번개치는 냉염 아트로나크",
    ["Clockwise |t100%:100%:esoui/art/housing/rotation_arrow_reverse.dds:inheritcolor|t"] = "시계 방향 |t100%:100%:esoui/art/housing/rotation_arrow_reverse.dds:inheritcolor|t",
    ["Counter-Clockwise|t100%:100%:esoui/art/housing/rotation_arrow.dds:inheritcolor|t"] = "반시계 방향|t100%:100%:esoui/art/housing/rotation_arrow.dds:inheritcolor|t",
}

local function TranslateText(text)
    if type(text) ~= "string" or text == "" then
        return text
    end

    local translated = MENU_TRANSLATIONS[text] or DETAIL_TRANSLATIONS[text] or THRESHOLD_TRANSLATIONS[text] or EXACT_RUNTIME_TRANSLATIONS[text]
    if translated then
        return translated
    end

    text = text:gsub("Counter%-Clockwise", "반시계 방향")
    text = text:gsub("Clockwise", "시계 방향")
    text = text:gsub("Suggested stack:", "추천 중첩:")
    text = text:gsub("TETHERED!", "연결됨!")
    text = text:gsub("INTERRUPT!", "차단!")
    text = text:gsub("Soon™️", "곧")
    text = text:gsub("Boss in ", "보스 등장까지 ")
    text = text:gsub("Portal (%d):", "포탈 %1:")
    text = text:gsub("Portal ", "포탈 ")
    text = text:gsub("(%d+) in portal", "%1명 포탈")
    text = text:gsub(" in portal", " 포탈 내부")
    text = text:gsub("Up next:", "다음:")

    return text
end

local function LocalizeOptionTree(node)
    if type(node) ~= "table" then
        return
    end

    for key, value in pairs(node) do
        if key == "name" or key == "title" or key == "tooltip" or key == "tooltipText" or key == "warning" or key == "text" or key == "dialogTitle" then
            if type(value) == "string" then
                node[key] = TranslateText(value)
            end
        elseif key == "choices" and type(value) == "table" then
            for i, choice in ipairs(value) do
                if type(choice) == "string" then
                    value[i] = TranslateText(choice)
                end
            end
        elseif type(value) == "table" then
            LocalizeOptionTree(value)
        end
    end
end

local function GetLAMPanelName(control)
    if type(control) ~= "userdata" and type(control) ~= "table" then
        return nil
    end

    if control.panel and type(control.panel.GetName) == "function" then
        return control.panel:GetName()
    end

    if type(control.GetName) == "function" then
        local name = control:GetName()
        if name and name ~= "" then
            return name
        end
    end

    if type(control.GetParent) == "function" then
        local parent = control:GetParent()
        if parent then
            return GetLAMPanelName(parent)
        end
    end

    return nil
end

local function HookLAMCreateControls()
    if not LAMCreateControl or LAMCreateControl._tamrielKrCrutchWrapped then
        return
    end
    LAMCreateControl._tamrielKrCrutchWrapped = true

    for widgetType, creator in pairs(LAMCreateControl) do
        if type(creator) == "function" then
            LAMCreateControl[widgetType] = function(parent, widgetData, ...)
                if GetLAMPanelName(parent) == "CrutchAlertsOptions" and type(widgetData) == "table" then
                    LocalizeOptionTree(widgetData)
                end
                return creator(parent, widgetData, ...)
            end
        end
    end
end

local function LocalizeControlTooltipData(control)
    if type(control) ~= "userdata" and type(control) ~= "table" then
        return
    end

    if GetLAMPanelName(control) ~= "CrutchAlertsOptions" then
        return
    end

    if type(control.data) == "table" then
        LocalizeOptionTree(control.data)
    end

    for _, childName in ipairs({"label", "title", "desc"}) do
        local child = control[childName]
        if child and type(child.GetText) == "function" and type(child.SetText) == "function" then
            child:SetText(TranslateText(child:GetText()))
        end
    end
end

local function HookLAMTooltips()
    if ZO_Options_OnMouseEnter and not CrutchAlerts._tamrielKrOptionsMouseEnterWrapped then
        local origOptionsOnMouseEnter = ZO_Options_OnMouseEnter
        ZO_Options_OnMouseEnter = function(control, ...)
            LocalizeControlTooltipData(control)
            return origOptionsOnMouseEnter(control, ...)
        end
        CrutchAlerts._tamrielKrOptionsMouseEnterWrapped = true
    end

    local LAM = LibAddonMenu2
    if LAM and LAM.util and type(LAM.util.SetUpTooltip) == "function" and not LAM.util._tamrielKrCrutchTooltipWrapped then
        local origSetUpTooltip = LAM.util.SetUpTooltip
        LAM.util.SetUpTooltip = function(control, data, tooltipData, ...)
            if type(data) == "table" then
                LocalizeOptionTree(data)
            end
            if type(tooltipData) == "table" then
                LocalizeOptionTree(tooltipData)
            end
            local result = origSetUpTooltip(control, data, tooltipData, ...)
            LocalizeControlTooltipData(control)
            return result
        end
        LAM.util._tamrielKrCrutchTooltipWrapped = true
    end
end

local function HookLAM()
    local LAM = LibAddonMenu2
    if not LAM or LAM._tamrielKrCrutchHooked then
        return
    end
    LAM._tamrielKrCrutchHooked = true

    local origRegisterAddonPanel = LAM.RegisterAddonPanel
    LAM.RegisterAddonPanel = function(self, panelName, panelData, ...)
        if panelName == "CrutchAlertsOptions" and type(panelData) == "table" then
            LocalizeOptionTree(panelData)
        end
        return origRegisterAddonPanel(self, panelName, panelData, ...)
    end

    local origRegisterOptionControls = LAM.RegisterOptionControls
    LAM.RegisterOptionControls = function(self, panelName, optionsData, ...)
        if panelName == "CrutchAlertsOptions" and type(optionsData) == "table" then
            LocalizeOptionTree(optionsData)
        end
        return origRegisterOptionControls(self, panelName, optionsData, ...)
    end
end

local function WrapInfoPanel()
    local IP = Crutch.InfoPanel
    if not IP or IP._tamrielKrWrapped then
        return
    end
    IP._tamrielKrWrapped = true

    local origSetLine = IP.SetLine
    if type(origSetLine) == "function" then
        IP.SetLine = function(index, text, scale, alpha)
            return origSetLine(index, TranslateText(text), scale, alpha)
        end
    end

    local origCountDownToTargetTime = IP.CountDownToTargetTime
    if type(origCountDownToTargetTime) == "function" then
        IP.CountDownToTargetTime = function(index, prefix, targetTime, scale)
            return origCountDownToTargetTime(index, TranslateText(prefix), targetTime, scale)
        end
    end

    local origCountDownDuration = IP.CountDownDuration
    if type(origCountDownDuration) == "function" then
        IP.CountDownDuration = function(index, prefix, durationMs, scale)
            return origCountDownDuration(index, TranslateText(prefix), durationMs, scale)
        end
    end

    local origCountDownHardStop = IP.CountDownHardStop
    if type(origCountDownHardStop) == "function" then
        IP.CountDownHardStop = function(index, prefix, durationMs, showTimer)
            return origCountDownHardStop(index, TranslateText(prefix), durationMs, showTimer)
        end
    end

    local origCountDownDamageable = IP.CountDownDamageable
    if type(origCountDownDamageable) == "function" then
        IP.CountDownDamageable = function(durationSeconds, prefix)
            return origCountDownDamageable(durationSeconds, TranslateText(prefix))
        end
    end
end

local function TranslateNestedStrings(node)
    if type(node) ~= "table" then
        return
    end

    for key, value in pairs(node) do
        if type(value) == "string" then
            node[key] = TranslateText(value)
        elseif type(value) == "table" then
            TranslateNestedStrings(value)
        end
    end
end

local function FinalizeHooks(attempt)
    attempt = attempt or 1

    if type(Crutch.DisplayNotification) == "function" and not Crutch._tamrielKrNotificationWrapped then
        local origDisplayNotification = Crutch.DisplayNotification
        Crutch.DisplayNotification = function(abilityId, textLabel, timer, sourceUnitId, sourceName, sourceType, targetUnitId, targetName, targetType, result, preventOverwrite)
            return origDisplayNotification(
                abilityId,
                TranslateText(textLabel),
                timer,
                sourceUnitId,
                sourceName,
                sourceType,
                targetUnitId,
                targetName,
                targetType,
                result,
                preventOverwrite
            )
        end
        Crutch._tamrielKrNotificationWrapped = true
    end

    if type(Crutch.format) == "table" and not Crutch._tamrielKrFormatTranslated then
        for _, data in pairs(Crutch.format) do
            if type(data) == "table" and type(data.text) == "string" then
                data.text = TranslateText(data.text)
            end
        end
        Crutch._tamrielKrFormatTranslated = true
    end

    local BHB = Crutch.BossHealthBar
    if type(BHB) == "table" and not BHB._tamrielKrThresholdsTranslated then
        if type(BHB.thresholds) == "table" then
            TranslateNestedStrings(BHB.thresholds)
        end
        if type(BHB.eaThresholds) == "table" then
            TranslateNestedStrings(BHB.eaThresholds)
        end
        BHB._tamrielKrThresholdsTranslated = true
    end

    if not Crutch._tamrielKrBindingLocalized and SI_BINDING_NAME_CRUTCH_TOGGLE_GENERAL then
        SafeAddString(SI_BINDING_NAME_CRUTCH_TOGGLE_GENERAL, "일반 경고 전환")
        Crutch._tamrielKrBindingLocalized = true
    end

    if attempt < 20 then
        local ready =
            Crutch._tamrielKrNotificationWrapped and
            Crutch._tamrielKrFormatTranslated and
            Crutch._tamrielKrBindingLocalized and
            type(Crutch.BossHealthBar) == "table" and Crutch.BossHealthBar._tamrielKrThresholdsTranslated

        if not ready then
            zo_callLater(function() FinalizeHooks(attempt + 1) end, 50)
        end
    end
end

HookLAM()
HookLAMCreateControls()
HookLAMTooltips()
WrapInfoPanel()
zo_callLater(function() FinalizeHooks(1) end, 0)

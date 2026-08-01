-- =============================================================================
-- === OptimalWeave Language File: Korean (ko.lua)                           ===
-- =============================================================================
--[[
    AddOn Name:         OptimalWeave
    File:               lang/ko.lua
    Description:        Korean localization using ZO_CreateStringId
    Version:            1.17.0
    Author:             Orollas & VollständigerName
--]]
-- =============================================================================

-- =============================================================================
-- == PANEL & AUTHOR INFORMATION ===============================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_PANEL_NAME", "|c6D6D6DOp|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve|r")
ZO_CreateStringId("OW_MENU_AUTHORS", "|cEE82EEO|r|cDD74ECr|r|cCD65EAo|r|cBC57E8l|r|cAB48E6l|r|c9B3AE4a|r|c8A2BE2s|r & |cFFD700Vo|r|cF7D418l|r|cF3D324l|r|cEFD130s|r|cEBD03Ctä|r|cE3CD54n|r|cE0CC60d|r|cDCCA6Ci|r|cD8C978g|r|cD4C784e|r|cD0C690r|r|cCCC49CNa|r|cC4C1B4me|r")
ZO_CreateStringId("OW_MENU_WEBSITE", "https://github.com/VollstaendigerName")

-- =============================================================================
-- == INFORMATION SECTION ======================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_INFO_HEADER", "정보 & 리드미")
ZO_CreateStringId("OW_MENU_INFO_TEXT", "글로벌 쿨다운(GCD)은 1000ms입니다. OptimalWeave는 선택한 모드에 따라 능력 큐 관리를 도와 웨이빙을 최적화합니다. 아래 설정을 사용하여 동작을 사용자 정의하세요.")
ZO_CreateStringId("OW_MENU_MODE_HEADER", "핵심 메커니즘")
ZO_CreateStringId("OW_MENU_CONDITIONS_HEADER", "활성화 규칙")
ZO_CreateStringId("OW_MENU_ADVANCED_HEADER", "고급 제어")
ZO_CreateStringId("OW_MENU_PERFORMANCE_HEADER", "성능 설정")
ZO_CreateStringId("OW_MENU_MODE_ACTIVE", "애드온 활성")
ZO_CreateStringId("OW_MENU_MODE_INACTIVE", "애드온 비활성")
ZO_CreateStringId("OW_MENU_DISABLED_TOOLTIP", "이 옵션은 현재 비활성화됨")
ZO_CreateStringId("OW_MENU_LATENCY_WARNING", "경고: 높은 지연 값은 입력 지연을 초래할 수 있습니다!")

ZO_CreateStringId("OW_MENU_DISCLAIMER_LABEL", "|cFF0000고지사항|r") 
ZO_CreateStringId("OW_MENU_DISCLAIMER_TOOLTIP",  "|cFF0000고지사항:|r이 애드온은 ZeniMax Media Inc.에서 제작하지 않았으며 제휴, 지원하지 않습니다. The Elder Scrolls® 및 관련 로고는 미국 및/또는 기타 국가에서 ZeniMax Media Inc.의 등록 상표 또는 상표입니다. 모든 권리 보유.")

-- =============================================================================
-- == CORE SETTINGS ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SETTINGS_HEADER", "핵심 설정")
ZO_CreateStringId("OW_MENU_MODE_LABEL", "작동 모드")
ZO_CreateStringId("OW_MENU_MODE_TOOLTIP", "|c00FF00순차적:|r 경공격 후에만 능력을 사용할 수 있습니다.\n|cFF0000엄격:|r 엄격한 차단. GCD 중 기술 큐 없음.\n|cFFFF00지능형:|r 스마트 차단. 경량 공격이 큐에 없을 때만 기술 큐 허용.\n|c00FFFF비활성:|r 비활성.")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_COND", "순차적")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_HARD", "엄격")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_SOFT", "지능형")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_NONE", "비활성")
ZO_CreateStringId("OW_MENU_COMBAT_LABEL", "전투 중에만 활성")
ZO_CreateStringId("OW_MENU_COMBAT_TOOLTIP", "선택 시, OptimalWeave는 전투 중에만 능력 큐를 관리합니다.")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_LABEL", "적대적 대상이 있을 때만 활성")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_TOOLTIP", "큐 관리를 위해 적대적 대상이 필요합니다.")
ZO_CreateStringId("OW_MENU_BLOCKING_LABEL", "차단 중 무시")
ZO_CreateStringId("OW_MENU_BLOCKING_TOOLTIP", "차단 중 제어를 비활성화합니다.")
ZO_CreateStringId("OW_MENU_GROUNDAOE_LABEL", "지면 능력 이중 시전 차단")
ZO_CreateStringId("OW_MENU_GROUNDAOE_TOOLTIP", "지면 대상 능력의 우발적 이중 시전을 방지합니다.")
ZO_CreateStringId("OW_MENU_DISABLE_TANK", "탱크로 비활성화")
ZO_CreateStringId("OW_MENU_DISABLE_TANK_TOOLTIP", "탱크 역할이 활성일 때 자동 비활성화")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL", "힐러로 비활성화")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL_TOOLTIP", "힐러 역할이 활성일 때 자동 비활성화")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR", "백바에서 기능 비활성화")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR_TOOLTIP", "백바에서 애드온 대부분의 기능을 비활성화합니다.")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR", "백바에서 웨이브 지원 비활성화")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR_TOOLTIP", "백바에서 웨이브 지원(GCD 관리)을 비활성화합니다.")

ZO_CreateStringId("OW_MENU_DEACTIVATE_IN_PVP_HEADER", "PvP 비활성화")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP", "PvP 지역에서 기능 비활성화")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP_TOOLTIP", "PvP 지역에서 애드온 대부분의 기능을 비활성화합니다")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP", "PvP에서 웨이브 지원 비활성화")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP_TOOLTIP", "PvP 지역에서 웨이브 지원(GCD 관리)을 비활성화합니다")

-- =============================================================================
-- == BLOCK ID SETTINGS ========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKED_HEADER", "차단된 능력")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_LABEL", "새 ID 차단")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_TOOLTIP", "능력 ID 입력 (예: 134160)")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_LABEL", "현재 차단된 ID")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_TOOLTIP", "제거하려면 클릭")

-- =============================================================================
-- == ADVANCED SETTINGS ========================================================
-- =============================================================================
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL", "즉시 시전 버퍼 (ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL_TOOLTIP", "즉시 능력 안전 마진 (0-100ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED", "채널링 버퍼 (ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED_TOOLTIP", "채널링 기술 버퍼 (0-400ms)")
ZO_CreateStringId("OW_MENU_GCD_SLOT", "GCD 추적 슬롯")
ZO_CreateStringId("OW_MENU_GCD_SLOT_TOOLTIP", "GCD 감지를 위한 액션 바 슬롯 (3-8)")
ZO_CreateStringId("OW_MENU_MIN_GCD", "최소 GCD 임계값 (ms)")
ZO_CreateStringId("OW_MENU_MIN_GCD_TOOLTIP", "인식할 최소 GCD 지속 시간 (0-20ms)")
ZO_CreateStringId("OW_MENU_QUEUE_TIME", "기본 큐 시간 (ms)")
ZO_CreateStringId("OW_MENU_QUEUE_TIME_TOOLTIP", "기본 입력 큐 창 (100-2000ms)")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_LABEL", "바 교체 시 재설정")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_TOOLTIP", "바 교체 시 GCD 재설정")
ZO_CreateStringId("OW_MENU_RESETONDODGE_LABEL", "회피 구르기 시 재설정")
ZO_CreateStringId("OW_MENU_RESETONDODGE_TOOLTIP", "회피 구르기 시 GCD 재설정")
ZO_CreateStringId("OW_MENU_RESET_TIME_LABEL", "재설정 시간 (초)")
ZO_CreateStringId("OW_MENU_RESET_TIME_TOOLTIP", "아무것도 시전하지 않은 이 시간 후 추적 재설정")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_LABEL", "자동 GCD 추적 슬롯")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_TOOLTIP", "3-8 슬롯에서 최고의 GCD 추적 슬롯 자동 선택")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_LABEL", "자동 무기 장착")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_TOOLTIP", "전투 중 무기 자동 장착")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_LABEL", "모두 재설정")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_TOOLTIP", "모든 설정을 기본값으로 재설정")

-- =============================================================================
-- == LATENCY COMPENSATION =====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_LATENCY_HEADER", "지연 보상")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_LABEL", "자동 지연 조정")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_TOOLTIP", "현재 지연에 따른 타이밍 자동 조정. 안정적인 연결 시 권장.")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_LABEL", "수동 입력 지연 (ms)")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_TOOLTIP", "고정 지연 값 (0-200ms). 자동 모드 비활성 시에만 사용.")

-- =============================================================================
-- == (SUB)CLASS SETTINGS ======================================================
-- =============================================================================

-- == Grim Focus SETTINGS ======================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_HEADER", "직업 및 길드 특정 설정")
ZO_CreateStringId("OW_MENU_SUBCLASS_GRIMFOCUS", "그림 포커스")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS", "필요 스택")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS_TOOLTIP", "그림 포커스 활성화에 필요한 스택 수 (권장: 10)")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS", "모든 그림 포커스 변형 차단")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS_TOOLTIP", "|cFF5555• 끈질긴 집중:|r 항상 차단\n|cFFFF00• 그림 포커스 및 무자비한 결심:|r 10 스택에서만 사용 가능\n|cAAAAAA비활성:|r 모든 변형에 대한 기본 동작")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE", "사용자 스택 활성화")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE_TOOLTIP", "|cFFD700활성:|r 사용자 스택 설정 사용 \n" ..
                  "|cAAAAAA비활성:|r 그림 포커스와 무자비한 결심을 항상 10 스택까지 차단, 끈질긴 집중 항상 차단\n")

-- == BLOCK GUILDS SETTINGS ===================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_GUILDS", "길드")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS", "파이터 길드 헌터 기술 차단")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS_TOOLTIP", "파이터 길드 헌터 기술 모든 변형 차단 (전문 헌터, 위장 헌터 & 사악한 헌터)")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS", "메이지 길드 빛 기술 차단")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS_TOOLTIP", "빛 기술 모든 변형 차단 (매직라이트, 내면의 빛 & 빛나는 매직라이트)")   

ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS", "PvP에서 비활성화")
ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS_TOOLTIP", "PvP 지역에서 헌터/빛 능력 차단 비활성화")

-- == BLOCK MOLTEN WHIP SETTINGS ===============================================
ZO_CreateStringId("OW_MENU_SUBCLASS_MOLTENWHIP", "용암 채찍")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK", "용암 채찍 기술 차단")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK_TOOLTIP", "세 스택을 잃지 않도록 용암 채찍 기술 차단")

-- == BLOCK FATECARVER SETTINGS ================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_FATECARVER", "아르카니스트 페이트카버")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS", "페이트카버 시전 차단")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS_TOOLTIP", "조건 충족 시까지 페이트카버 시전 방지.")
ZO_CreateStringId("OW_MENU_CRUX_STACKS", "필요 크룩스 스택")
ZO_CreateStringId("OW_MENU_CRUX_STACKS_TOOLTIP", "페이트카버 시전 가능한 최소 크룩스 스택 (권장: 3)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM", "HP 임계값 (%)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOLTIP", "HP가 이 값 미만일 때 페이트카버 차단 비활성화")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE", "페이트카버 HP 확인 활성화")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE_TOOLTIP", "낮은 체력 시 페이트카버 차단 비활성화")

ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM", "스태미나 임계값 (%)")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOLTIP", "낮은 스태미나 시 페이트카버 차단 비활성화")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE", "페이트카버 스태미나 확인 활성화")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE_TOOLTIP", "낮은 스태미나 시 페이트카버 차단 비활성화")

-- == BLOCK CEPHALIARCH'S FLAIL SETTINGS ==========================================
ZO_CreateStringId("OW_MENU_SUBCLASS_CEPHALIARCHSFLAIL", "세팔리아크의 플레일")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL", "세팔리아크의 플레일 차단")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL_TOOLTIP", "크룩스 스택 3개 보유 시 세팔리아크의 플레일 차단")

-- == BLOCK TENTACULAR DREAD SETTINGS ==========================================
ZO_CreateStringId("OW_MENU_SUBCLASS_TENTACULAR", "공포의 촉수")
ZO_CreateStringId("OW_MENU_TENTACULAR", "공포의 촉수 차단")
ZO_CreateStringId("OW_MENU_TENTACULAR_TOOLTIP", "조건 충족 시까지 공포의 촉수 기술 차단.")


-- == Execute Check Settings ================================================
ZO_CreateStringId("OW_MENU_EXECUTE_HEADER", "처형 확인")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE", "처형 확인 활성화")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE_TOOLTIP", "처형 확인 기능 활성화 또는 비활성화")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD", "처형 임계값 (%)")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD_TOOLTIP", "처형 주문 허용 대상 체력 백분율")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELLS_HEADER", "처형 주문")

-- == Grouped Execute Spells ================================================
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS", "빛나는 파괴, 빛나는 영광, 빛나는 억압")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS_TOOLTIP", "대상이 처형 범위일 때까지 빛나는 파괴 변형 차단")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS", "암살자의 검, 꿰뚫기, 킬러의 검")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS_TOOLTIP", "대상이 처형 범위일 때까지 암살자의 검 변형 차단")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS", "마도사의 분노, 마도사의 격노, 끝없는 격노")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS_TOOLTIP", "대상이 처형 범위일 때까지 마도사의 격노 변형 차단")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS", "역베기, 역베기 일도, 처형자")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS_TOOLTIP", "대상이 처형 범위일 때까지 역베기 변형 차단")

-- == Work in progress ================================================
ZO_CreateStringId("OW_WIP", "작업 중")

-- =============================================================================
-- == WEAPON SETTINGS ==========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEADER", "무기 유형에 따른 비활성화")

ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON", "무기 유형에서 웨이브 지원 비활성화")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON_TOOLTIP", "선택한 무기 유형에 대해서만 웨이브 지원(GCD 관리) 비활성화")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON", "무기 유형에서 기능 비활성화")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON_TOOLTIP", "선택한 무기 유형에 대해 애드온 대부분의 기능 비활성화")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE", "도끼")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE_TOOLTIP", "도끼 장착 시 비활성화")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER", "망치")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER_TOOLTIP", "망치 장착 시 비활성화")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD", "검")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD_TOOLTIP", "검 장착 시 비활성화")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER", "단검")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER_TOOLTIP", "단검 장착 시 비활성화")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD", "양손 검")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD_TOOLTIP", "양손 검 장착 시 비활성화")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE", "양손 도끼")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE_TOOLTIP", "양손 도끼 장착 시 비활성화")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER", "양손 망치")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER_TOOLTIP", "양손 망치 장착 시 비활성화")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW", "활")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW_TOOLTIP", "활 장착 시 비활성화")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF", "불 지팡이")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF_TOOLTIP", "불 지팡이 장착 시 비활성화")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF", "얼음 지팡이")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF_TOOLTIP", "얼음 지팡이 장착 시 비활성화")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF", "번개 지팡이")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF_TOOLTIP", "번개 지팡이 장착 시 비활성화")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF", "치유 지팡이")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF_TOOLTIP", "치유 지팡이 장착 시 비활성화")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD", "방패")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD_TOOLTIP", "방패 장착 시 비활성화")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE", "룬")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE_TOOLTIP", "룬 장착 시 비활성화")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE", "무기 없음")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE_TOOLTIP", "무기 미장착 시 비활성화")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED", "예약 무기")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED_TOOLTIP", "예약 무기 유형 장착 시 비활성화")

-- =============================================================================
-- == CUSTOM BLOCK LIST SETTINGS ==============================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLIST_HEADER", "사용자 지정 차단 목록")
ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_HEADER", "사용자 차단 목록")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_DESC", "주문 ID를 추가하여 사용 차단. 액션 바 슬롯을 우클릭하여 주문을 추가할 수도 있습니다 (UI 재로드 필요)")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_LABEL", "주문 ID")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_TOOLTIP", "숫자 주문 ID 입력 (예: 185805)")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_ADD_BUTTON", "차단 목록에 추가")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_LIST_HEADER", "차단된 주문:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST", "사용자 차단 목록 활성화")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_TOOLTIP", "사용자 차단 목록 기능 활성화 또는 비활성화")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SV_DESC", "SavedVariables 파일 확인:\n customBlockList = {\n   [주문ID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK", "차단 목록 체력 확인 활성화")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "활성화 시, 차단 목록의 주문은 체력이 임계값을 초과할 때만 차단됩니다.")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT", "차단 목록 체력 임계값 (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "차단 목록 주문은 체력이 이 백분율을 초과할 때만 차단됩니다.")

-- =============================================================================
-- == CUSTOM RECAST BLOCK LIST SETTINGS ========================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLERECASTBLOCK_HEADER", "사용자 재시전 차단 목록")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_DESC", "주문 ID를 추가하여 남은 효과 시간이 임계값 미만일 때까지 재시전 차단. 액션 바 슬롯을 우클릭하여 주문을 추가할 수도 있습니다 (UI 재로드 필요).")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_LABEL", "주문 ID")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_TOOLTIP", "숫자 주문 ID 입력 (예: 185805)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_ADD_BUTTON", "재시전 차단 목록에 추가")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_LIST_HEADER", "재시전 차단된 주문:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST", "사용자 재시전 차단 목록 활성화")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_TOOLTIP", "사용자 재시전 차단 목록 기능 활성화 또는 비활성화")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME", "재시전 차단 시간 (초)")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME_TOOLTIP", "재시전 차단 목록의 주문을 다시 시전할 수 있는 초 단위 시간 (1.0 = 1초)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SV_DESC", "SavedVariables 파일 확인:\n customRecastBlockList = {\n   [주문ID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK", "재시전 차단 목록 체력 확인 활성화")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "활성화 시, 재시전 차단 목록의 주문은 체력이 임계값을 초과할 때만 차단됩니다.")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT", "재시전 차단 목록 체력 임계값 (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "재시전 차단 목록 주문은 체력이 이 백분율을 초과할 때만 차단됩니다.")

-- =============================================================================

ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_MAIN_TEXT", "스킬 ID가 추가/제거되었습니다. 더 이상 스킬을 추가하거나 제거하지 않으려면 변경 사항을 표시하기 위해 UI를 다시 로드하십시오.")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_YES", "UI 다시 로드")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_LATER", "나중에")

ZO_CreateStringId("OW_MENU_DIALOG_BUTTON_OK", "확인")
ZO_CreateStringId("OW_MENU_INVALID_ID_DIALOG_MAIN_TEXT", "오류: 유효한 주문 ID를 입력하십시오")
ZO_CreateStringId("OW_MENU_ID_NOT_EXIST_DIALOG_MAIN_TEXT", "주문 ID가 존재하지 않습니다")
ZO_CreateStringId("OW_MENU_ID_IS_IN_SV_DIALOG_MAIN_TEXT",  "주문 ID가 이미 차단 목록에 있습니다")

-- =============================================================================
-- == RESOURCE-BASED BLOCK LIST SETTINGS =======================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_RESOURCE_HEADER", "자원 기반 차단 목록")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_RESOURCE_DESC", "주 자원(마법 또는 스태미나)이 임계값 미만일 때 차단할 스킬 ID를 추가합니다. 행동 바 슬롯을 우클릭하여 스킬을 추가할 수도 있습니다 (UI 다시 로드 필요).")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST", "자원 기반 차단 목록 활성화")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST_TOOLTIP", "자원 기반 차단 목록 기능을 활성화 또는 비활성화합니다")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK", "자원 확인 활성화")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK_TOOLTIP", "활성화되면, 자원 차단 목록의 스킬은 주 자원(마법 또는 스태미나)이 임계값 이상일 때만 차단됩니다.")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT", "자원 임계값 (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT_TOOLTIP", "자원 차단 목록의 스킬은 주 자원(마법 또는 스태미나)이 이 백분율 이상일 때만 차단됩니다.")
ZO_CreateStringId("OW_MENU_RESOURCE_BLOCK_SPELL", "스킬: ")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK", "마법 확인")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK_TOOLTIP", "이 스킬에 대해 마법 기반 차단 활성화")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE", "마법이 임계값 미만일 때 차단")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE_TOOLTIP", "마법이 임계값 미만일 때 스킬 차단 (미만일 때만 허용하려면 체크 해제)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD", "마법 임계값 (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD_TOOLTIP", "마법 백분율 임계값")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK", "스태미나 확인")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK_TOOLTIP", "이 스킬에 대해 스태미나 기반 차단 활성화")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE", "스태미나가 임계값 미만일 때 차단")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE_TOOLTIP", "스태미나가 임계값 미만일 때 스킬 차단 (미만일 때만 허용하려면 체크 해제)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD", "스태미나 임계값 (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD_TOOLTIP", "스태미나 백분율 임계값")

-- =============================================================================
-- == KEYBINDINGS LOCALIZATION =================================================
-- =============================================================================

ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_OPTIMALWEAVE", "|c6D6D6DOpti|r|c8A8A8AmalWea|r|cC4C4C4ve|r")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_MODE", "모드 전환 (엄격/지능형/비활성)")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_BLOCK_LIST", "사용자 차단 목록 전환")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_RECAST_BLOCK_LIST", "사용자 재시전 차단 목록 전환")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEave_TOGGLE_BACKBAR_FEATURES", "백바 기능 비활성화 전환")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_WEAVE_ASSIST", "백바 웨이브 지원 비활성화 전환")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_EXECUTE_CHECK", "처형 확인 전환")

-- =============================================================================
-- == REMOVE BUTTON ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_BUTTON", "제거")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_TOOLTIP", "이 스킬을 차단 목록에서 제거합니다 (/reloadui 필요)")

-- =============================================================================
-- == SETTIINGS MODE ===========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_MODE_SELECTION_LABEL", "설정 모드")
ZO_CreateStringId("OW_MENU_MODE_SELECTION_TOOLTIP", "설정을 이 계정의 모든 캐릭터에서 공유할지(계정 전체) 아니면 각 캐릭터별로 따로 저장할지(캐릭터별) 선택합니다.")
ZO_CreateStringId("OW_MENU_MODE_ACCOUNTWIDE", "계정 전체")
ZO_CreateStringId("OW_MENU_MODE_PERCHARACTER", "캐릭터별")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_SETTINGS_MAIN_TEXT", "설정 모드가 변경되었습니다. 변경 사항을 적용하려면 UI를 다시 로드하시겠습니까?")

-- =============================================================================
-- == IN COMBAT MENU BLOCKING ==================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU", "전투 중 마지막 메뉴 차단")
ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU_TOOLTIP", "전투 중 마지막 메뉴 (ALT)가 열리는 것을 방지합니다.")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU", "전투 중 캐릭터 메뉴 차단")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU_TOOLTIP", "전투 중 캐릭터 메뉴 (C)가 열리는 것을 방지합니다.")

-- =============================================================================
-- == GCD DISPLAY ==============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SHOW_GCD_LABEL", "전역 재사용 대기시간(GCD) 표시")
ZO_CreateStringId("OW_MENU_SHOW_GCD_TOOLTIP", "액션 바 위에 GCD 표시기(ZOS 제공)를 표시합니다.")

-- =============================================================================
-- == BLOCKLIST COMBAT ONLY ====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_LABEL", "전투 중에만 차단 목록 사용")
ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_TOOLTIP", "모든 사용자 지정 차단 목록은 전투 중에만 활성화됩니다. 전투 외부에서는 모든 차단 목록이 비활성화됩니다.")

-- =============================================================================
-- === END OF KOREAN LOCALIZATION ==============================================
-- =============================================================================
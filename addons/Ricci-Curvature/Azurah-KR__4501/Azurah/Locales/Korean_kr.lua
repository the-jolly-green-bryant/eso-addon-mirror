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

local Azurah = _G["Azurah"]
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Korean
-- Missing keys fall back to English_en.lua
------------------------------------------------------------------------------------------------------------------

L.Azurah = "|c67b1e9A|c4779cezurah|r"
L.Usage = "|c67b1e9A|c4779cezurah|r - 사용법:\n|cffc600  /azurah unlock|r |cffffff =  UI 이동 잠금 해제|r\n|cffc600  /azurah save|r |cffffff =  UI 잠금 후 위치 저장|r\n|cffc600  /azurah undo|r |cffffff =  대기 중인 변경 취소|r\n|cffc600  /azurah exit|r |cffffff =  저장하지 않고 UI 잠금|r"
L.ThousandsSeparator = ","
L.ToggleCompassVisibility = "나침반 표시 전환"
L.ToggleCombatVisibility = "전역 불투명도 전환"
L.ToggleAbilityBlocking = "능력 차단 전환"
L.AzurahAbilityBlock = "차단"
L.AzurahAbilityBlocked = "|c67b1e9Azurah|r: 액션 바 설정에 의해 능력이 차단되었습니다."

-- move window names
L.Health = "플레이어 생명력"
L.HealthSiege = "공성 장비 체력"
L.Magicka = "플레이어 마법력"
L.Werewolf = "늑대인간 타이머"
L.Stamina = "플레이어 스태미나"
L.StaminaMount = "탈것 스태미나"
L.Experience = "경험치 바"
L.EquipmentStatus = "장비 상태"
L.Synergy = "시너지"
L.Compass = "나침반"
L.ReticleOver = "대상 체력"
L.ActionBar = "액션 바"
L.PetGroup = "소환수 그룹"
L.Group = "그룹원"
L.Raid1 = "레이드 그룹 1"
L.Raid2 = "레이드 그룹 2"
L.Raid3 = "레이드 그룹 3"
L.Raid4 = "레이드 그룹 4"
L.Raid5 = "레이드 그룹 5"
L.Raid6 = "레이드 그룹 6"
L.FocusedQuest = "퀘스트 추적기"
L.PlayerPrompt = "플레이어 상호작용 프롬프트"
L.AlertText = "경고 텍스트 알림"
L.CenterAnnounce = "화면 중앙 알림"
L.InfamyMeter = "현상금 표시"
L.TelVarMeter = "텔 바 표시"
L.ActiveCombatTips = "전투 팁"
L.Tutorial = "튜토리얼"
L.CaptureMeter = "AvA 점령 미터"
L.BagWatcher = "가방 감시 바"
L.WerewolfTimer = "늑대인간 타이머"
L.LootHistory = "전리품 기록"
L.RamSiege = "공성추"
L.Subtitles = "자막"
L.PaperDoll = "페이퍼돌"
L.QuestTimer = "퀘스트 타이머"
L.PlayerBuffs = "플레이어 버프/디버프"
L.TargetDebuffs = "대상 디버프"
L.Reticle = "조준점"
L.Interact = "상호작용 텍스트"
L.BattlegroundScore = "전장 점수"
L.DialogueWindow = "대화 창"
L.StealthIcon = "은신 아이콘"
L.EndlessArchive = "엔들리스 아카이브"
L.WykkydReticle = "조준점 프레임 크기는 Wykkyd Full Immersion이 관리합니다"
L.WykkydSubtitles = "자막 크기는 Wykkyd Full Immersion이 관리합니다"

-- dropdown menus
L.DropOverlay1 = "오버레이 없음"
L.DropOverlay2 = "모두 표시"
L.DropOverlay3 = "현재값 / 최대값"
L.DropOverlay4 = "현재값 / 퍼센트"
L.DropOverlay5 = "현재값만"
L.DropOverlay6 = "퍼센트만"
L.DropColourBy1 = "기본값"
L.DropColourBy2 = "반응 기준"
L.DropColourBy3 = "레벨 기준"
L.DropExpBarStyle1 = "기본값"
L.DropExpBarStyle2 = "항상 표시"
L.DropExpBarStyle3 = "항상 숨김"
L.DropHAlign1 = "자동"
L.DropHAlign2 = "왼쪽 정렬"
L.DropHAlign3 = "오른쪽 정렬"
L.DropHAlign4 = "가운데 정렬"

-- tabs
L.TabButton1 = "일반"
L.TabButton2 = "능력치"
L.TabButton3 = "대상"
L.TabButton4 = "액션 바"
L.TabButton5 = "경험치"
L.TabButton6 = "나침반"
L.TabButton7 = "도둑질"
L.TabButton8 = "가방 감시"
L.TabButton9 = "늑대인간"
L.TabButton10 = "프로필"
L.TabHeader1 = "일반 설정"
L.TabHeader2 = "플레이어 능력치 설정"
L.TabHeader3 = "대상 창 설정"
L.TabHeader4 = "액션 바 설정"
L.TabHeader5 = "경험치 바 설정"
L.TabHeader6 = "나침반 설정"
L.TabHeader7 = "도둑질 설정"
L.TabHeader8 = "가방 감시 설정"
L.TabHeader9 = "늑대인간 타이머 설정"
L.TabHeader10 = "프로필 설정"

-- unlock window
L.UnlockHeader = "UI 잠금 해제"
L.ChangesPending = "|cffffff변경 사항이 저장 대기 중입니다!|r\n|cffff00'UI 잠금 (저장)'을 눌러 저장하세요.|r\n저장하지 않은 변경은 다시 불러오면 사라집니다."
L.UnlockGridEnable = "그리드 스냅 켜기"
L.UnlockGridDisable = "그리드 스냅 끄기"
L.UnlockLockFrames = "UI 잠금 (저장)"
L.UndoChanges = "변경 취소"
L.ExitNoSave = "저장하지 않고 종료"
L.UnlockReset = "기본값으로 초기화"
L.UnlockResetConfirm = "초기화 확인"

-- settings: generic
L.SettingOverlayFormat = "오버레이 형식"
L.SettingOverlayShield = "보호막 체력"
L.SettingOverlayShieldTip = "현재 보호막 체력을 포함합니다."
L.SettingOverlayFancy = "천 단위 구분 표시"
L.SettingOverlayFancyTip = "이 오버레이의 큰 숫자를 구분 기호로 나눌지 설정합니다.\n\n예: 10000은 10' .. L.ThousandsSeparator .. '000 형식으로 표시됩니다."
L.SettingOverlayFont = "오버레이 텍스트 글꼴"
L.SettingOverlayStyle = "오버레이 텍스트 색상 및 스타일"
L.SettingOverlaySize = "오버레이 텍스트 크기"
L.SettingUseReadyColor = "준비 완료 색상 사용"
L.SettingUseReadyColorTip = "활성 바의 궁극기가 시전 가능할 때 다른 색상으로 바꿀지 설정합니다. 별도 색상을 설정하지 않았거나 궁극기가 부족하면 위 색상을 사용합니다."
L.SettingHorizontalOffset = "가로 오프셋"
L.SettingVerticalOffset = "세로 오프셋"

-- settings: general tab
L.GeneralWarning = "경고"
L.GeneralAnchorDesc = "잠금을 해제하면 마우스로 UI 창을 이동하고 마우스 휠로 크기를 조정할 수 있습니다. 잠금 해제된 각 UI 창에는 이동용 오버레이가 표시되므로 현재 화면에 보이지 않는 창도 옮길 수 있습니다.\n\n잠그면 변경 사항이 저장됩니다. '변경 취소'를 누르면 잠금 해제 이후의 변경 사항이 모두 되돌아갑니다. 개별 창을 우클릭하면 그 창의 대기 중 변경만 초기화합니다. 저장하지 않고 종료하면 배치 결과를 확인할 수 있지만, 다시 잠금을 해제해 저장하지 않으면 다음 /reload 때 원래대로 돌아갑니다.\n\n잠금 해제 상태에서는 Esc로 설정을 빠져나가거나 채팅에 |cffff00/azurah unlock|r 을 입력해 모든 프레임을 표시할 수 있습니다."
L.GeneralEditFrameDesc = "Azurah로 이동하거나 크기를 조정한 프레임의 세부 설정을 변경합니다.\n\n불투명도를 바꾸면 프레임이 얼마나 투명하게 보일지 결정됩니다.\n\n전투 수정 옵션을 켜면 전투 중일 때만 별도의 불투명도를 적용할 수 있습니다."
L.GeneralUIOptions = "UI 프레임 옵션"
L.GeneralDescription1 = "지원되는 프레임을 이동하거나 크기를 조정하려면"
L.GeneralDescription2 = "를 사용하고, 불투명도와 기타 옵션은 아래에서 설정하세요."
L.GeneralDescription3 = "액션 바 크기를 바꾼 뒤에는 반드시 |cffff00/reloadui|r 해야 합니다. 그렇지 않으면 바 교체 시 버튼이 잘못 보일 수 있습니다. 또한 키보드/게임패드 모드를 오갈 때는 Azurah로 프레임을 수정하기 전에 먼저 리로드해야 합니다."
L.GeneralEditFrames = "UI 프레임 옵션 편집"
L.GeneralEditFrameChoice = "편집할 프레임 선택"
L.GeneralEditFrameNone = "편집할 프레임이 없습니다."
L.GeneralEditFrameReset = "프레임 초기화"
L.GeneralEditFrameResetTip = "선택한 프레임에 대한 Azurah 수정값을 모두 지웁니다. 다른 UI 개편 애드온과 충돌할 때 유용합니다.\n\n참고: 초기화 적용 전 |cffff00/reloadui|r 가 필요합니다."
L.GeneralAnchorUnlock = "UI 창 잠금 해제"
L.GeneralNotification = "알림 텍스트"
L.General_Notification = "정렬 설정"
L.General_NotificationTip = "알림 텍스트의 가로 정렬을 선택합니다. 기본의 '자동'은 알림 프레임 위치에 따라 왼쪽 또는 오른쪽을 자동 선택합니다."
L.General_NotificationWarn = "이 설정은 알림 텍스트 프레임을 잠금 해제 후 이동하거나, UI를 다시 불러와야 적용됩니다."
L.General_MiscHeader = "기타"
L.General_GlobalOpacity = "전역 불투명도 전환"
L.General_GlobalOpacityTip = "이 옵션이나 키 바인딩을 켜면 개별 프레임의 불투명도 설정을 임시로 무시하고 모든 프레임을 보이게 합니다. 끄면 개별 프레임 설정을 다시 사용합니다."
L.General_ModeChange = "키보드/게임패드 모드 변경 시 리로드"
L.General_ModeChangeTip = "키보드와 게임패드 모드를 전환할 때 UI를 다시 불러옵니다. 기본적으로는 전환 후 수동 리로드 전까지 Azurah 위치 변경이 계속 초기화될 수 있습니다."
L.General_ATrackerDisable = "활동 추적기 비활성화"
L.General_ATrackerDisableTip = "던전 찾기나 전장 같은 활동 상태 표시를 비활성화합니다."

-- settings: attributes tab
L.AttributesFadeMin = "표시: 가득 찼을 때"
L.AttributesFadeMinTip = "해당 능력치가 가득 찼을 때 바의 불투명도를 설정합니다. 100%는 완전 표시, 0%는 완전 숨김입니다.\n\n기본 UI 값은 0%입니다."
L.AttributesFadeMax = "표시: 가득 차지 않았을 때"
L.AttributesFadeMaxTip = "해당 능력치가 가득 차지 않았을 때의 불투명도를 설정합니다. 예: 달리기 중 스태미나. 100%는 완전 표시, 0%는 완전 숨김입니다.\n\n기본 UI 값은 100%입니다."
L.AttributesLockSize = "능력치 바 크기 고정"
L.AttributesLockSizeTip = "추가 체력이나 자원을 얻어도 능력치 바 크기가 변하지 않도록 고정합니다.\n\n기본 UI 값은 꺼짐입니다."
L.AttributesCombatBars = "표시: 전투 중"
L.AttributesCombatBarsTip = "전투 중에는 항상 '가득 차지 않았을 때' 불투명도를 사용합니다."
L.AttributesOverlayHealth = "오버레이 텍스트: 생명력"
L.AttributesOverlayMagicka = "오버레이 텍스트: 마법력"
L.AttributesOverlayStamina = "오버레이 텍스트: 스태미나"
L.AttributesOverlayFormatTip = "이 능력치 바의 오버레이 텍스트 표시 방식을 설정합니다.\n\n기본 UI 값은 오버레이 없음입니다."

-- settings: target tab
L.TargetLockSize = "대상 바 크기 고정"
L.TargetLockSizeTip = "추가 체력을 가진 대상을 선택해도 대상 바 크기가 변하지 않도록 고정합니다.\n\n기본 UI 값은 꺼짐입니다."
L.TargetRPName = "대상의 @계정명 숨기기"
L.TargetRPNameTip = "대상 프레임에서 @계정명 태그를 표시하지 않습니다. 참고: 게임의 이름 표시 설정에서 '유저 ID 우선'을 선택한 경우 일반 캐릭터 이름이 숨겨질 수 있습니다."
L.TargetRPTitle = "대상 칭호 숨기기"
L.TargetRPTitleTip = "대상 플레이어의 칭호를 숨깁니다."
L.TargetRPTitleWarn = "UI 리로드가 필요합니다."
L.TargetRPInteract = "상호작용 @계정명 숨기기"
L.TargetRPInteractTip = "플레이어 상호작용 프레임에서 @계정명 태그를 표시하지 않습니다."
L.TargetColourByBar = "대상 체력 바 색상 지정"
L.TargetColourByBarTip = "대상 체력 바 색상을 반응 또는 난이도(레벨) 기준으로 칠할지 설정합니다."
L.TargetColourByName = "대상 이름 색상 지정"
L.TargetColourByNameTip = "대상 이름표를 반응 또는 난이도(레벨) 기준으로 칠할지 설정합니다."
L.TargetColourByLevel = "대상 레벨 색상 지정"
L.TargetColourByLevelTip = "대상 레벨을 난이도(레벨)에 따라 색상 표시할지 설정합니다."
L.TargetIconClassShow = "플레이어 직업 아이콘 표시"
L.TargetIconClassShowTip = "대상 플레이어의 직업 아이콘을 표시할지 설정합니다."
L.TargetIconClassByName = "이름표 옆에 직업 아이콘 표시"
L.TargetIconClassByNameTip = "직업 아이콘을 대상 체력 바 왼쪽 대신 이름표 왼쪽에 표시할지 설정합니다."
L.TargetIconAllianceShow = "플레이어 동맹 아이콘 표시"
L.TargetIconAllianceShowTip = "대상 플레이어의 동맹 아이콘을 표시할지 설정합니다."
L.TargetIconAllianceByName = "이름표 옆에 동맹 아이콘 표시"
L.TargetIconAllianceByNameTip = "동맹 아이콘을 대상 체력 바 오른쪽 대신 이름표 오른쪽에 표시할지 설정합니다."
L.TargetOverlayFormatTip = "대상 바 오버레이 텍스트 표시 방식을 설정합니다.\n\n기본 UI 값은 오버레이 없음입니다."
L.BossbarHeader = "보스 바 설정"
L.BossbarOverlayFormatTip = "보스 바 오버레이 텍스트 표시 방식을 설정합니다. 보스 바는 현재 활성 보스들의 체력 총합을 보여줍니다.\n\n기본 UI 값은 오버레이 없음입니다."

-- settings: action bar tab
L.ActionBarHideBindBG = "키 바인드 배경 숨기기"
L.ActionBarHideBindBGTip = "액션 바 키 바인드 뒤의 어두운 배경을 보일지 설정합니다."
L.ActionBarHideBindText = "키 바인드 텍스트 숨기기"
L.ActionBarHideBindTextTip = "액션 바 아래의 키 바인드 텍스트를 보일지 설정합니다."
L.ActionBarHideWeaponSwap = "무기 교체 아이콘 숨기기"
L.ActionBarHideWeaponSwapTip = "단축키와 퀵슬롯 사이의 무기 교체 아이콘 표시 여부를 설정합니다."
L.ActionBarBlockMageLight = "마지 라이트 차단"
L.ActionBarBlockMageLightTip = "활성화 시 Mage Light 및 변이 스킬 사용을 막습니다. 키 바인드로도 전환할 수 있습니다."
L.ActionBarBlockExpertHunter = "전문 사냥꾼 차단"
L.ActionBarBlockExpertHunterTip = "활성화 시 Expert Hunter 및 변이 스킬 사용을 막습니다. 키 바인드로도 전환할 수 있습니다."
L.ActionBarBlockedWarning = "차단 경고 표시"
L.ActionBarBlockedWarningTip = "위 설정으로 능력 사용이 막혔을 때 채팅에 메시지를 출력합니다."
L.ActionBarOverlayShow = "오버레이 표시"
L.ActionBarOverlayUltValue = "오버레이 텍스트: 궁극기 값"
L.ActionBarOverlayUltValueShowTip = "궁극기 버튼 위에 현재 궁극기 수치를 표시할지 설정합니다."
L.ActionBarOverlayUltValueShowCost = "능력 비용 표시"
L.ActionBarOverlayUltValueShowCostTip = "오버레이에 현재 궁극기 수치만 보여줄지, 궁극기 수치/능력 비용을 함께 보여줄지 설정합니다."
L.ActionBarOverlayUltPercent = "오버레이 텍스트: 궁극기 퍼센트"
L.ActionBarOverlayUltPercentShowTip = "궁극기 버튼 위에 현재 궁극기 수치를 퍼센트로 표시할지 설정합니다."
L.ActionBarOverlayUltPercentRelative = "상대 퍼센트 표시"
L.ActionBarOverlayUltPercentRelativeTip = "퍼센트를 현재 장착한 궁극기 비용 기준으로 표시할지, 최대 궁극기 풀 500 기준으로 표시할지 설정합니다."
L.ActionBarOverlayUltPercentCap = "100%로 제한"
L.ActionBarOverlayUltPercentCapTip = "상대 퍼센트 표시 시 현재 궁극기 비용보다 더 많이 보유해도 100%를 넘겨 표시하지 않습니다."

-- settings: experience bar tab
L.ExperienceDisplayStyle = "표시 방식"
L.ExperienceDisplayStyleTip = "경험치 바의 표시 방식을 설정합니다.\n\n참고: 항상 표시를 선택해도 제작 중이거나 월드 맵을 열면 다른 창과 겹치지 않도록 숨겨집니다."
L.ExperienceOverlayFormatTip = "경험치 바의 오버레이 텍스트 표시 방식을 설정합니다.\n\n기본 UI 값은 오버레이 없음입니다."

-- settings: compass tab
L.CompassEnabled = "나침반 사용"
L.CompassEnabledTip = "나침반을 보이거나 숨깁니다. 키 바인드 전환도 가능합니다."
L.CompassLabelScale = "나침반 라벨 크기"
L.CompassLabelScaleTip = "나침반 대상 라벨 텍스트 크기를 설정합니다."
L.CompassLabelPosition = "나침반 라벨 위치"
L.CompassLabelPositionTip = "나침반 기준으로 라벨 텍스트의 세로 위치를 위아래로 조정합니다."
L.CompassWidth = "나침반 너비"
L.CompassWidthTip = "나침반의 고정 너비를 설정합니다. 기본값은 800입니다. 위에서 조절하는 핀/마커 크기와는 별개입니다."
L.CompassHeight = "나침반 높이"
L.CompassHeightTip = "나침반의 고정 높이를 설정합니다. 기본값은 39입니다. 위에서 조절하는 핀/마커 크기와는 별개입니다."
L.CompassOpacity = "나침반 불투명도"
L.CompassOpacityTip = "나침반의 투명도 수준을 설정합니다. 기본값은 100입니다."
L.CompassHideBar = "나침반 바 숨기기"
L.CompassHideBarTip = "나침반 배경 바 텍스처를 숨깁니다."
L.CompassPinLabel = "라벨 텍스트 숨기기"
L.CompassPinLabelTip = "현재 보고 있는 핀 대상의 식별 텍스트를 숨길지 설정합니다. 예: 현재 바라보는 퀘스트 마커 이름.\n\n기본 UI 값은 꺼짐입니다."
L.CompassReset = "나침반 초기화"
L.CompassResetTip1 = "나침반을 게임 기본 설정과 위치로 되돌립니다."
L.CompassResetTip2 = "참고: Azurah의 나침반 수정은 Harvest Map과 충돌하지 않으며, 3D 핀과 Spawned Resource Filter도 이동/크기 조정된 나침반에서 정상 동작합니다."
L.CompassResetWarn = "이 작업은 자동으로 UI를 다시 불러옵니다."

-- settings: thievery tab
L.Thievery_TheftBlocked = "|c67b1e9A|c4779cezurah|r - 설정에 의해 절도가 차단되었습니다."
L.Thievery_TheftPrevent = "월드 아이템 실수 절도 방지"
L.Thievery_TheftPreventTip = "월드에 전시된 소유 아이템을 실수로 훔치는 것을 막을지 설정합니다. 적발 시 현상금이 붙는 방어구, 무기, 음식 등이 포함됩니다.\n\n참고: 컨테이너 약탈은 보호하지 않습니다."
L.Thievery_TheftSafer = "더 안전한 월드 아이템 절도"
L.Thievery_TheftSaferTip = "완전히 은신했을 때만 소유 아이템 절도를 다시 허용할지 설정합니다.\n\n참고: 그래도 컨테이너 약탈은 보호하지 않습니다."
L.Thievery_CTheftSafer = "컨테이너 절도 더 안전하게"
L.Thievery_CTheftSaferTip = "완전히 은신하지 않으면 소유 컨테이너를 열지 못하게 할지 설정합니다."
L.Thievery_PTheftSafer = "소매치기 더 안전하게"
L.Thievery_PTheftSaferTip = "완전히 은신하지 않으면 소매치기를 막아 더 안전하게 할지 설정합니다."
L.Thievery_TheftSaferWarn = "기술적으로는 치트에 가깝습니다!"
L.Thievery_TheftAnnounceBlock = "절도 차단 시 알림"
L.Thievery_TheftAnnounceBlockTip = "도둑질 설정으로 절도가 차단되었을 때 알릴지 설정합니다.\n\n알림은 현재 채팅 창에 출력됩니다."

-- settings: bag watcher tab
L.Bag_Desc = "가방 감시는 경험치 바처럼 보이는 막대를 생성하여 가방이 얼마나 찼는지 보여줍니다. 가방 내용이 바뀔 때 잠시 나타나며, 가방이 거의 찼을 때 항상 보이도록 설정할 수도 있습니다."
L.Bag_Enable = "가방 감시 사용"
L.Bag_ReverseAlignment = "막대 방향 반전"
L.Bag_ReverseAlignmentTip = "막대가 오른쪽으로 차오르도록 방향을 반전할지 설정합니다. 아이콘 위치도 반대편으로 이동합니다."
L.Bag_LowSpaceLock = "공간 부족 시 항상 표시"
L.Bag_LowSpaceLockTip = "가방이 거의 찼을 때 가방 감시를 항상 표시할지 설정합니다."
L.Bag_LowSpaceTrigger = "공간 부족 기준"
L.Bag_LowSpaceTriggerTip = "가방 여유 공간이 몇 칸 남았을 때 부족 상태로 볼지 설정합니다."

-- settings: werewolf tab
L.Werewolf_Desc = "늑대인간 타이머는 남은 변신 시간을 초 단위로 표시하는 별도의 이동 가능한 창입니다. 얼마나 더 사냥할 시간이 남았는지 쉽게 파악할 수 있습니다. 기본 위치는 궁극기 버튼 바로 오른쪽입니다."
L.Werewolf_Enable = "늑대인간 타이머 사용"
L.Werewolf_Flash = "시간 연장 시 반짝임"
L.Werewolf_FlashTip = "변신 남은 시간이 늘어날 때 타이머 아이콘이 잠시 반짝일지 설정합니다."
L.Werewolf_IconOnRight = "아이콘을 오른쪽에 표시"
L.Werewolf_IconOnRightTip = "타이머 왼쪽 대신 오른쪽에 아이콘을 표시할지 설정합니다."

-- settings: profiles tab
L.Profile_Desc = "여기서 설정 프로필을 관리할 수 있습니다. 계정 전체 프로필을 활성화하면 이 계정의 모든 캐릭터에 같은 설정을 적용할 수 있습니다. 이 옵션은 영구적이므로, 패널 하단 체크박스로 먼저 프로필 관리를 활성화해야 합니다."
L.Profile_UseGlobal = "계정 전체 프로필 사용"
L.Profile_UseGlobalWarn = "로컬/계정 전체 프로필 전환 시 인터페이스를 다시 불러옵니다."
L.Profile_Copy = "복사할 프로필 선택"
L.Profile_CopyTip = "선택한 프로필의 설정을 현재 활성 프로필에 복사합니다. 활성 프로필은 현재 캐릭터 또는 계정 전체 프로필입니다. 기존 설정은 영구적으로 덮어씌워집니다.\n\n이 작업은 되돌릴 수 없습니다!"
L.Profile_CopyButton = "프로필 복사"
L.Profile_CopyButtonWarn = "프로필 복사 시 인터페이스를 다시 불러옵니다."
L.Profile_Delete = "삭제할 프로필 선택"
L.Profile_DeleteTip = "선택한 프로필의 설정을 데이터베이스에서 삭제합니다. 나중에 그 캐릭터로 접속하고 계정 전체 프로필을 쓰지 않는 경우 기본 설정으로 새 프로필이 생성됩니다.\n\n프로필 삭제는 영구적입니다!"
L.Profile_DeleteButton = "프로필 삭제"
L.Profile_Guard = "프로필 관리 사용"

-- settings: edit frames tab
L.EditFrame_Select = "편집할 프레임 선택:"
L.EditFrame_Opacity = "프레임 불투명도"
L.EditFrame_OpacityTip = "이 프레임의 투명도 수준을 설정합니다."
L.EditFrame_CombatOpt = "전투 옵션"
L.EditFrame_CombatOptTip = "전투 중에만 표시될 프레임 변경을 설정합니다."
L.EditFrame_OpacityC = "전투 중 불투명도"
L.EditFrame_OpacityCTip = "전투 중 이 프레임의 투명도 수준을 설정합니다."

------------------------------------------------------------------------------------------------------------------

if (GetCVar("language.2") == "kr") then
    for k, v in pairs(Azurah:GetLocale()) do
        if (not L[k]) then
            L[k] = v
        end
    end

    function Azurah:GetLocale()
        return L
    end
end

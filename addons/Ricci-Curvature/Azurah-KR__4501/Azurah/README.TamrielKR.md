# Azurah - Korean Patch

이 패키지는 현재 독립 `-KR` 애드온으로는 안전하지 않아 원본 폴더에 덮어써야 하는 한국어 패치입니다.

## 설치 방법

1. 원본 애드온 `Azurah`를 먼저 설치합니다.
2. 게임을 종료합니다.
3. 압축 안의 `Azurah` 폴더 내용을 `AddOns` 안의 원본 `Azurah` 폴더에 덮어씁니다.
4. 원본 애드온만 켜고, 별도 `-KR` 애드온처럼 설치하지 않습니다.

## 포함 파일

- `Azurah/Azurah.txt` (Korean_kr.lua 로드 라인 추가)
- `Azurah/Locales/Korean_kr.lua`

## 비고

- Azurah의 각 모듈은 파일 로드 시점에 `local L = Azurah:GetLocale()`로 로케일 테이블 참조를 캡처하고, `Settings.lua`는 드롭다운 값을 로컬 배열에 미리 복사합니다.
- 또한 `OnInitialize`에서 LAM 설정 패널과 키바인딩 문자열이 baked되므로, 로케일 파일은 반드시 Azurah 본체 로딩 도중 다른 로케일들과 같은 시점에 실행되어야 합니다.
- 이 때문에 `## DependsOn: Azurah` 기반 독립 패치 애드온으로 분리하면 한글이 적용되지 않습니다. 오버라이트 방식이 유일하게 안전한 배포 방법입니다.

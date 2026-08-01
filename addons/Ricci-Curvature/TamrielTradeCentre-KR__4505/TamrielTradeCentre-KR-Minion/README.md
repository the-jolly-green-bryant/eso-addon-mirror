# TamrielTradeCentre - Korean Patch

이 패키지는 Minion/ESOUI 배포를 위한 독립 한국어 패치 애드온입니다.

## 설치 방법

1. 원본 애드온 `TamrielTradeCentre`를 먼저 설치합니다.
2. 이 패키지를 `AddOns` 폴더에 별도 폴더로 풀어 설치합니다.
3. TamrielKR 환경에서는 한국어일 때만 자동 적용됩니다.

## 포함 파일

- `TamrielTradeCentre/ItemLookUpTable_kr.lua`
- `TamrielTradeCentre/lang/kr.lua`

## 비고

- `## DependsOn: TamrielTradeCentre` 기반으로 원본 애드온 다음에 로드됩니다.
- 패치 파일은 비한글 환경에서 즉시 종료되도록 가드가 들어 있습니다.
- 원본 폴더에 직접 덮어쓰지 않는 Minion 친화적 구조입니다.

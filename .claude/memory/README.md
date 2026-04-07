# `.claude/memory/` — 프로젝트 영구 메모리

이 폴더는 Claude가 이 프로젝트에서 한 실수, 배운 교훈, 내린 결정의
**영구 저장소**입니다. 저장소와 함께 커밋되고 모든 세션에서 자동으로 로드됩니다.

## 파일

| 파일 | 용도 | 어떻게 채워지나 |
|---|---|---|
| `mistakes.md` | 과거 실수와 그 교훈 | `record-mistake.sh` hook이 자동 초안 작성, Claude가 *교훈* 줄을 채움 |
| `lessons.md` | 코드베이스에 대한 항구적 교훈 | Claude가 `mistake-recorder` 스킬로 추가 |
| `decisions.md` | 아키텍처 결정 (ADR) | Claude/사용자가 결정 시점에 추가 |

## 사용 방법

- `SessionStart` hook이 세션 시작 시마다 위 파일들의 끝부분(약 80줄)을
  Claude의 컨텍스트에 자동 주입합니다.
- 도구 호출이 실패하면 `PostToolUseFailure` hook이 `mistakes.md`에
  항목을 자동 추가합니다. Claude는 그 항목의 *교훈* 줄을 채워야 합니다.
- Claude는 작업 중 새로 배운 것을 `mistake-recorder` 스킬로 직접 추가할 수 있습니다.

## 보안

- 비밀, 토큰, PII, 고객 식별 정보는 절대 기록하지 않습니다.
- 메모리 파일도 일반 코드와 같은 코드 리뷰 대상입니다.

## 위생

- 한 파일이 ~500줄을 넘으면 오래된 항목을 `*.archive.md`로 분리합니다.
- 항목을 삭제할 땐 메모를 남깁니다(예: "ADR-0007로 대체됨").

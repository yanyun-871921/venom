---
description: 현재 프로젝트를 분석하여 .claude/ 전체를 이 프로젝트에 맞게 진화시킵니다. 새 파일 생성과 기존 파일 수정(deep 모드)을 모두 수행합니다. 이 폴더를 새 프로젝트에 막 도입한 직후 한 번 실행하세요.
argument-hint: "[quick|standard|deep, 기본 standard]"
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
---

# /venom — 프로젝트 주입 및 진화

당신은 지금 이 가이드라인 세트(`CLAUDE.md` + `.claude/`)가 막 복사된 새 프로젝트의
루트에 있습니다. 당신의 임무는 **이 프로젝트를 깊이 이해하고, 그 이해를
영속적인 프로젝트 특화 규칙·스킬·훅·메모리로 응결시키는 것**입니다.

> 분석 깊이 인자: `$ARGUMENTS` (기본 `standard`)
>
> | 모드 | 새 파일 생성 | 기존 파일 수정 | 코드 샘플링 | 신규 hook 작성 | 예상 시간 |
> |---|---|---|---|---|---|
> | `quick` | ✅ 최소 | ❌ | ❌ | ❌ | 2~5분 |
> | `standard` | ✅ | ❌ | 가벼움 | ❌ | 5~15분 |
> | `deep` | ✅ | **✅** | **✅** | **✅** | 15~60분 |

---

## 0단계: 사전 점검

1. 현재 작업 디렉토리가 프로젝트 루트인가? (`CLAUDE.md`와 `.claude/`가 함께 있어야 함)
2. 이전에 흡수한 흔적이 있는가?
   - `.claude/rules/60-project.md`
   - `.claude/skills/project-*/`
   - `.claude/memory/decisions.md`의 `ADR-0002` 또는 그 후속 항목
   - `.claude/.venom-backup/`
3. 흔적이 있다면 사용자에게 *덮어쓸지, 보강할지, 중단할지* 묻고 답을 기다립니다.
4. **deep 모드라면**: `.claude/.venom-backup/<ISO타임스탬프>/` 폴더를 만들고
   수정 대상이 될 수 있는 모든 기존 파일(`rules/`, `skills/`, `hooks/`,
   `settings.json`, `CLAUDE.md`)을 그대로 백업합니다. 백업 없이는 파일을
   수정하지 않습니다.

## 1단계: 프로젝트 메타데이터 수집 (병렬)

다음을 한꺼번에 조사합니다.

- **매니페스트/락파일**: `package.json`, `pyproject.toml`, `requirements*.txt`,
  `Cargo.toml`, `go.mod`, `Gemfile`, `pom.xml`, `build.gradle`, `composer.json`,
  `Pipfile`, `mix.exs`, `pubspec.yaml`, `Package.swift`
- **빌드 시스템**: `Makefile`, `Justfile`, `Taskfile.yml`, `Dockerfile`,
  `docker-compose.yml`, `.dockerignore`, `pnpm-workspace.yaml`, `nx.json`,
  `turbo.json`, `lerna.json`
- **CI 설정**: `.github/workflows/*`, `.gitlab-ci.yml`, `.circleci/config.yml`,
  `azure-pipelines.yml`, `Jenkinsfile`, `.buildkite/`
- **린트/포맷 설정**: `.eslintrc*`, `.prettierrc*`, `ruff.toml`, `pyproject.toml`의
  `[tool.*]`, `.editorconfig`, `.rubocop.yml`, `rustfmt.toml`, `.golangci.yml`,
  `biome.json`
- **테스트 프레임워크**: `pytest.ini`, `jest.config.*`, `vitest.config.*`,
  `phpunit.xml`, `playwright.config.*`, `cypress.config.*`
- **문서**: `README*`, `CONTRIBUTING*`, `ARCHITECTURE*`, `docs/`, `ADR/`
- **환경**: `.env.example`, `.envrc`, `.tool-versions`, `.nvmrc`,
  `.python-version`, `mise.toml`, `asdf` 설정
- **VCS**: `git log --oneline -20`, `git remote -v`, `git branch -a`,
  최근 6개월 커밋의 prefix 패턴, 활성 PR 템플릿

각 발견 사항을 한 줄 메모로 정리합니다.

## 2단계: 디렉토리 구조 매핑

- `find . -maxdepth 3 -type d` (Glob 또는 Bash)로 상위 구조 파악.
- 소스 루트 식별 (`src/`, `lib/`, `app/`, `pkg/`, `internal/` 등).
- 테스트 루트 식별 (`tests/`, `__tests__/`, `spec/`, `test/`).
- 모노레포 여부 (`packages/`, `apps/`, workspace 매니페스트).
- 자동 생성 디렉토리 (`generated/`, `*_pb2.py`, `__generated__/`).
- 무시 디렉토리 (`.gitignore` 파싱 + `protect-paths.sh` 목록과 교차).

**deep 모드**에서는 핵심 디렉토리(소스 루트, 테스트 루트, 진입점)에서 가장
큰 파일과 가장 최근에 수정된 파일을 각 1~2개씩 직접 읽어 스타일/네이밍/에러
처리/로깅 컨벤션을 관찰합니다.

## 3단계: 컨벤션 추출

읽은 자료에서 다음을 도출합니다. 확신할 수 없는 항목은 *추측하지 않고*
사용자 질문 후보 목록에 모아둡니다.

- **언어와 버전**, **패키지 매니저**, **주요 프레임워크**
- **빌드/테스트/린트/타입체크/포맷/dev 서버 명령**
- **네이밍 컨벤션** (camelCase vs snake_case, 파일/디렉토리 규칙)
- **모듈 경계** (레이어, 도메인 분리, public API 표면)
- **테스트 전략** (단위/통합/E2E의 위치와 명령, 픽스처 패턴)
- **금기 사항** (직접 편집 금지 디렉토리, 자동 생성 코드, 마이그레이션 파일)
- **CI 게이트** (PR 머지 전 반드시 통과해야 하는 체크)
- **브랜치/릴리스 흐름** (trunk-based, gitflow, release-please 등)
- **로깅·관측 스택**, **에러 처리 패턴**, **DI/IoC 컨테이너**
- **민감 데이터 패턴** (이 프로젝트에서 절대 로깅/커밋되면 안 되는 것)

---

## 4단계 (모든 모드): 새 파일 생성

다음을 항상 새로 만듭니다(또는 기존이 있으면 보강).

### 4.1 `.claude/rules/60-project.md`
프로젝트 특화 규칙(스택, 명령, 디렉토리 지도, 컨벤션, CI 게이트, 함정).

### 4.2 `.claude/skills/project-build/SKILL.md`
이 프로젝트의 빌드/테스트/린트/포맷을 *정확한* 명령·플래그·작업 디렉토리로
실행하는 스킬. 모노레포라면 workspace 필터까지 포함.

### 4.3 `.claude/skills/project-architecture/SKILL.md` *(standard·deep만)*
모듈 트리, 레이어 의존 방향, public API 경계, 핵심 추상화. deep 모드에서는
실제 코드 샘플링 결과 기반.

### 4.4 `.claude/memory/decisions.md`에 ADR 추가
```markdown
## ADR-NNNN: /venom $ARGUMENTS 실행 — <YYYY-MM-DD>
- 상태: 채택
- 맥락: 이 프로젝트의 컨벤션을 가이드라인 세트에 흡수시키기 위해 실행.
- 결정: 다음 파일을 생성/수정함 — <목록>
- 결과: 다음 세션부터 Claude가 이 프로젝트의 컨벤션을 자동으로 따른다.
- 모드: $ARGUMENTS
- 백업 위치: .claude/.venom-backup/<ISO타임스탬프>/   (deep 모드일 때만)
```

### 4.5 `.claude/memory/lessons.md`에 즉석 교훈 추가
흡수 과정에서 발견한 비자명한 사실(예: "테스트는 반드시 `pnpm -w test`로
워크스페이스 루트에서 실행해야 한다", "User 모델은 항상 UserService.save()를
거쳐야 audit 로그가 남는다")을 즉시 기록합니다.

---

## 5단계 (deep 모드 전용): 기존 파일 진화

`deep` 모드에서는 기존 범용 파일을 이 프로젝트에 맞게 *진화*시킵니다.
**0단계의 백업 없이 진행 금지.** 변경 전후 이유는 모두 ADR에 기록.

### 5.1 `CLAUDE.md` 진화
- 9번 부록 목록에 새로 추가된 `60-project.md`와 그 외 신규 규칙 파일을 등재.
- 프로젝트 고유 어휘(예: 도메인 용어)가 있다면 짧은 용어집 섹션을 추가.
- 150줄 예산을 넘지 않도록 다른 곳에서 줄여야 한다면 줄인다.

### 5.2 `.claude/rules/` 진화
- `10-coding-standards.md`: 이 프로젝트의 실제 네이밍 규칙·줄 길이·import
  순서·에러 처리 패턴으로 *교체*. 예를 들어 "snake_case"가 사실인지
  관측한 결과에 따라 단정.
- `20-security.md`: 이 프로젝트의 민감 데이터 패턴(예: customer_id는 로깅 금지),
  사용 중인 비밀 관리 방식(Vault, AWS Secrets Manager, doppler 등)을 추가.
- `30-git-commit.md`: 실제 사용 중인 커밋 prefix 규약(conventional commits,
  jira 키 prefix 등)과 브랜치 명명, 머지 정책을 반영.
- `40-testing.md`: 실제 테스트 위치·명명 규칙·픽스처 패턴·CI 게이트로 교체.
- 필요하면 `45-logging.md`, `46-observability.md`, `47-i18n.md` 같은
  새 도메인 규칙 파일을 추가.

### 5.3 `.claude/skills/` 진화
- `test-runner/SKILL.md`: 이 프로젝트의 정확한 명령·인자·환경 변수로 교체
  (범용 자동 감지는 백업 안에 보존).
- `code-review/SKILL.md`: 이 프로젝트의 CI 게이트와 알려진 함정을 체크리스트에 추가.
- `git-workflow/SKILL.md`: 실제 PR 템플릿, 라벨, 리뷰어 규칙을 반영.
- 필요하면 신규 스킬 추가:
  - `db-migration/SKILL.md` — 이 프로젝트의 마이그레이션 도구·명령·롤백 절차
  - `release/SKILL.md` — 릴리스 절차·체인지로그 갱신 방법
  - `api-contract/SKILL.md` — OpenAPI/Proto/GraphQL 스키마 변경 절차
  - `feature-flag/SKILL.md` — 플래그 도입·제거 절차

### 5.4 `.claude/hooks/` 진화
- `auto-format.sh`: 이 프로젝트가 실제로 사용하는 포매터(예: `ruff format`이
  아니라 `black` + `isort`)와 정확한 인자로 단순화.
- `block-dangerous.sh`: 이 프로젝트 고유의 위험 명령 패턴 추가
  (예: `prisma migrate reset`, `terraform destroy`, `helm uninstall`,
  `kubectl delete -n production`, 운영 DB 직접 접근).
- `protect-paths.sh`: 이 프로젝트의 자동 생성 디렉토리, 마이그레이션 파일,
  스냅샷, 골든 파일 등을 보호 목록에 추가.
- 필요하면 신규 hook 추가 (스크립트 작성 → `settings.json`에 등록):
  - `pre-commit-style-check.sh` — 이 프로젝트의 컨벤션 위반을 PreToolUse(Edit)에서 사전 차단
  - `block-prod-config.sh` — `production.yml`/`prod.env`류 편집 차단
  - `enforce-test-with-code.sh` — 소스 파일 편집 시 같은 모듈에 테스트가 있는지 확인
  - `inject-schema.sh` — UserPromptSubmit 단계에서 현재 DB 스키마/타입 정의를 컨텍스트에 주입

새 hook을 추가하면 반드시 `settings.json`의 적절한 이벤트 배열에 등록하고,
JSON 유효성을 `python3 -c "import json; json.load(open('.claude/settings.json'))"`로
검증합니다.

### 5.5 `.claude/settings.json` 진화
- `permissions.allow`: 이 프로젝트의 안전한 빌드/테스트/린트 명령을 추가하여
  사용자 승인 클릭을 줄임.
- `permissions.deny`: 이 프로젝트의 위험 명령을 명시적으로 차단.
- `env`: 프로젝트 표준 환경 변수 추가 (단, 비밀 값은 *절대* 넣지 않음).

### 5.6 `.claude/memory/` 보강
- 흡수 과정에서 새로 알게 된 함정·관례를 모두 `lessons.md`에 기록.
- 흡수 자체를 ADR로 남김.

---

## 6단계: 검증

- 생성/수정한 각 파일을 다시 읽어 사실 오류를 확인합니다.
- 추출한 빌드/테스트/린트 명령을 *실제로* 한 번씩 실행해봅니다
  (각각 5분 이내 타임아웃, 실패해도 OK — 명령 자체의 존재만 확인).
- 명령이 존재하지 않으면 해당 줄을 제거하거나 "(미확인)"으로 표시합니다.
- 신규/수정 hook 스크립트는 `bash -n`으로 문법 검증하고
  `chmod +x`로 실행 권한을 부여합니다.
- `.claude/settings.json`을 JSON 유효성 검사합니다.
- (deep 모드) 대표적인 위험 명령을 hook에 stdin으로 흘려 차단되는지
  스모크 테스트합니다.

## 7단계: 사용자 보고

다음 형식으로 끝맺습니다.

```
## /venom $ARGUMENTS 결과 — <YYYY-MM-DD>

### 감지된 스택
- 언어: ...
- 패키지 매니저: ...
- 프레임워크: ...
- CI: ...
- 모노레포: ...

### 새로 생성된 파일
- ...

### 진화된 기존 파일 (deep 모드)
- ...
- 백업: .claude/.venom-backup/<타임스탬프>/

### 새로 추가된 hook (deep 모드)
- ...

### 검증 결과
- ✅ 빌드 명령: ...
- ✅ 테스트 명령: ...
- ⚠️ 린트: 미발견
- ✅ JSON 유효성: OK
- ✅ hook 문법: OK
- ✅ hook 스모크 테스트: <개수>/<개수> 통과

### 사용자에게 묻고 싶은 것
1. ...
2. ...

### 되돌리는 방법 (deep 모드)
백업을 복원하려면:
  cp -a .claude/.venom-backup/<타임스탬프>/. .claude/

이 프로젝트는 흡수되었습니다. 다음 세션부터 Claude는 위 컨벤션을 자동으로 따릅니다.
```

---

## 절대 규칙

- **deep 모드는 백업 없이 진행하지 않는다.** 0단계 백업이 실패하면 즉시 중단.
- **추측하지 않는다.** 확신할 수 없는 항목은 사용자 질문 목록에 둔다.
  잘못 단정한 규칙은 잘못된 판단을 영속화한다.
- **비밀을 흡수하지 않는다.** `.env`, `id_rsa`, 자격증명 파일을 읽지 않는다.
  `protect-paths` hook이 어차피 차단하지만, 시도조차 하지 않는다.
- **메모리에 PII/비밀을 쓰지 않는다.** 비밀이 들어갈 수 있는 패턴은
  변수명·경로·구조만 기록하고 값은 절대 기록하지 않는다.
- **흡수가 끝나도 커밋하지 않는다.** 사용자가 결과를 검토한 뒤 직접 커밋한다.
- **`memory/`를 정리(prune)하지 않는다.** 흡수와 무관한 과거 기록은 그대로 둔다.
- **표준 모드에서는 기존 파일을 수정하지 않는다.** 진화는 deep 모드 전용.

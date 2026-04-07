---
name: git-workflow
description: 사용자가 "커밋해줘", "스테이지해줘", "PR 만들어줘", "브랜치 만들어줘", "이거 올려줘", "git 작업 도와줘"라고 할 때 사용하세요. 안전한 git 작업, 커밋 메시지 작성, PR 생성을 위한 표준 절차를 제공합니다. 파괴적 명령은 절대 실행하지 않습니다.
---

# Git 워크플로우 스킬

이 스킬은 `.claude/rules/30-git-commit.md`를 강제한다. 그 규칙과 충돌하는
어떤 행동도 하지 않는다.

## 커밋 절차

1. **상황 파악(병렬 실행).**
   - `git status` (`-uall` 플래그 금지 — 큰 레포에서 메모리 폭발)
   - `git diff` (스테이지 안 됨)
   - `git diff --staged`
   - `git log --oneline -10` (커밋 메시지 스타일 학습)

2. **변경 분석.**
   - 변경의 본질(feat / fix / docs / refactor / test / chore / perf / build / ci).
   - 비밀이 들어 있을 가능성이 있는 파일(`.env`, `*.pem`, `id_rsa`, `credentials*`)이
     스테이지된 게 있다면 멈추고 사용자에게 경고한다.

3. **메시지 작성.**
   - 제목: 명령형, 72자 이내, 끝에 마침표 없음.
   - 본문: *왜*에 초점. *무엇*은 diff가 보여준다.
   - 깨지는 변경, 이슈 링크, 마이그레이션 노트가 있다면 본문에.

4. **명시적 스테이징과 커밋(병렬).**
   - 파일을 이름으로 `git add path1 path2`. `-A`, `.` 금지.
   - `git commit -m "$(cat <<'EOF' ... EOF)"` 형식의 HEREDOC.
   - 커밋 후 `git status`로 성공 확인(순차).

5. **pre-commit hook 실패 시.**
   - 절대 `--no-verify`로 우회하지 않는다.
   - 절대 *이전* 커밋에 `--amend` 하지 않는다(hook 실패 시 커밋은 만들어지지 않은 상태이므로 `--amend`는 *이전* 커밋을 손상시킨다).
   - 문제를 고치고 다시 스테이지하고 새 커밋을 만든다.

## PR 절차

1. 베이스 브랜치와 분기점 이후의 *모든* 커밋을 본다(마지막 커밋만 보지 말 것).
2. 제목은 70자 이내로 짧게.
3. 본문은 다음 형식:
   ```markdown
   ## Summary
   - 1~3개의 불릿

   ## Test plan
   - [ ] 검증 항목 1
   - [ ] 검증 항목 2
   ```
4. `gh pr create --title "..." --body "$(cat <<'EOF' ... EOF)"`.
5. 끝나면 PR URL을 사용자에게 돌려준다.

## 절대 금지
- `push --force`(공유 브랜치). 사용자가 명시 요청 시 `--force-with-lease`만 허용.
- `reset --hard` (푸시 안 한 작업이 있는 브랜치).
- 타인 커밋에 `--amend`.
- 사용자가 요청하지 않은 commit / push / PR.
- `git rebase -i`, `git add -i` (인터랙티브 플래그는 이 환경에서 동작하지 않음).

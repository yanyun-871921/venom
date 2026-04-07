# 30 — Git, 커밋, 브랜치, PR

## 언제 커밋하나
- **사용자가 명시적으로 요청할 때만.** "도움이 되려고" 몰래 커밋하지 않는다.
- 한 커밋에 한 논리적 변경. 제목에 "그리고"를 쓰고 싶다면 커밋을 분리해야 한다.

## 커밋 메시지 형식
```
<type>: <명령형 제목, 72자 이내>

<본문 — 72자 줄바꿈. *왜*를 설명하고, 이슈를 링크하고, 깨지는 변경을 명시한다.>
```
타입: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`, `build`, `ci`.

## 스테이징
- 파일은 이름으로 명시적으로 스테이징한다: `git add path/to/file`.
- `git add -A`나 `git add .`는 금지 — 쓰레기와 비밀까지 끌고 들어온다.
- 커밋 전에 `git status`, `git diff --staged`로 검토한다.

## 브랜치
- 사용자가 허락하지 않는 한 `main`/`master`/`release/*`에 직접 커밋하지 않는다.
- 브랜치 이름: `feat/<짧은-설명>`, `fix/<이슈-id>`, `chore/<범위>`.

## 금지
- `git push --force` (사용자가 요청할 때만 `--force-with-lease` 허용).
- 푸시 안 한 작업이 있는 브랜치에서 `git reset --hard`.
- `git commit --no-verify`, `--no-gpg-sign`.
- `git rebase -i`, `git add -i` (인터랙티브 플래그는 이 하네스에서 동작하지 않음).
- 타인 커밋에 `--amend`. 항상 새 커밋을 만든다.

## PR
- 제목 ≤ 70자. 본문은 **Summary**와 **Test plan** 섹션을 갖는다.
- 사용자가 요청하지 않는 한 PR을 열지 않는다.

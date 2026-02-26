# xoxopenclaw Fly.io 초기 세팅 (새 도화지)

요청한 스펙으로 바로 시작할 수 있게 준비된 전용 템플릿입니다.

- 앱 이름: `xoxopenclaw`
- 리전: `nrt`
- 메모리: `131072mb`
- VM 사이즈: `performance-16x`
- 볼륨: `500GB`

## 1) Codespaces에서 한 번에 실행 (복붙용)

> 아래 블록은 **토큰을 파일에 저장하지 않고** 현재 셸 세션에서만 사용합니다.

```bash
cd /workspace/openclawkr

export FLY_API_TOKEN='<YOUR_FLY_TOKEN>'
export DISCORD_BOT_TOKEN='<YOUR_DISCORD_BOT_TOKEN>'
export ANTHROPIC_API_KEY='<YOUR_ANTHROPIC_API_KEY>'

fly auth token >/dev/null
./deploy/fly/xoxopenclaw/bootstrap.sh
```

## 2) 진짜로 Fly 전용 트리만 남기고 싶을 때 (파괴적)

아래 명령은 현재 레포에서 Fly 배포 관련 최소 파일만 남기고 삭제합니다. 되돌리기 어렵습니다.

```bash
cd /workspace/openclawkr

KEEP_LIST=$'deploy/fly/xoxopenclaw\nfly.toml\nfly.private.toml\nDockerfile\nDockerfile.sandbox\nDockerfile.sandbox-common\nDockerfile.sandbox-browser\n.git\n.gitignore'

declare -A keep_map
while IFS= read -r path; do
  [[ -z "$path" ]] && continue
  keep_map["$path"]=1
done <<< "$KEEP_LIST"

shopt -s dotglob nullglob
for item in * .*; do
  [[ "$item" == "." || "$item" == ".." ]] && continue
  [[ -n "${keep_map[$item]:-}" ]] && continue
  rm -rf -- "$item"
done
```

## 3) 초기 확인 명령

```bash
fly status --app xoxopenclaw
fly logs --app xoxopenclaw
fly ssh console --app xoxopenclaw
```

## 보안 메모

- 이미 공유한 Fly API 토큰은 즉시 폐기(rotate) 권장.
- 새 토큰 발급 후 다시 로그인/배포하세요.

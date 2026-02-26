# xoxopenclaw Fly.io 초기 세팅 (새 도화지)

요청 스펙:

- 앱 이름: `xoxopenclaw`
- 리전: `nrt`
- 메모리: `131072mb`
- VM: `performance-16x`
- 볼륨: `500GB`

## 1) env 파일에 토큰 저장

```bash
cd /workspace/openclawkr/deploy/fly/xoxopenclaw
cp .env.example .env
```

`.env`에 실제 값 입력:

```dotenv
FLY_API_TOKEN=...
DISCORD_BOT_TOKEN=...
SLACK_BOT_TOKEN=...
GEMINI_API_KEY=...
ANTHROPIC_API_KEY=...
```

## 2) Codespaces 전체 복붙 실행

```bash
cd /workspace/openclawkr
./deploy/fly/xoxopenclaw/bootstrap.sh
```

## 3) 초기 확인

```bash
fly status --app xoxopenclaw
fly logs --app xoxopenclaw
fly ssh console --app xoxopenclaw
```

## 4) Fly 전용 트리만 남기기 (파괴적, 선택)

```bash
cd /workspace/openclawkr
./deploy/fly/xoxopenclaw/prune-to-fly.sh
```

## 보안 메모

- `.env`는 `deploy/fly/xoxopenclaw/.gitignore`로 커밋 제외 처리됨.
- 이미 노출된 토큰은 즉시 rotate 권장.

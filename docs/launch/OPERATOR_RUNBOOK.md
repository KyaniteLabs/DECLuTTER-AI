# DECLuTTER-AI Operator Runbook

Last verified: 2026-04-23
Live base URL: `https://kyanitelabs.tech/declutter`
Operator URL: `https://kyanitelabs.tech/declutter/operator`
Deployed commit: `6e87762`
Host: `root@100.92.68.103`

## What this surface does

The private operator flow lets one authenticated operator:

1. open the private cockpit,
2. upload a single item photo,
3. run home multimodal analysis,
4. create a Cash-to-Clear session + item + public listing,
5. copy the public listing URL.

The current live stack is self-hosted:

- auth mode: shared token
- storage backend: local volume
- uploads path in container: `/data/uploads`
- session DB path in container: `/data/declutter_ai_sessions.sqlite3`
- inference provider: home OpenAI-compatible endpoint (`qwen3.6-35b-a3b`)

## Access

- username: `operator`
- password source: `/docker/declutter/env.hostinger`
- env key: `DECLUTTER_SHARED_ACCESS_TOKEN`

Do **not** paste the token into shell history or process arguments if you can avoid it.
Use a temporary curl config file instead.

Example on the VPS:

```bash
. /docker/declutter/env.hostinger
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
cat > "$TMPDIR/operator.curlrc" <<CFG
user = "operator:${DECLUTTER_SHARED_ACCESS_TOKEN}"
CFG
chmod 600 "$TMPDIR/operator.curlrc"
curl --config "$TMPDIR/operator.curlrc" https://kyanitelabs.tech/declutter/operator
```

## Health checks

### Public health

```bash
curl -fsS https://kyanitelabs.tech/declutter/health/
```

Expected:

```json
{"status":"ok"}
```

### Readiness

```bash
curl -fsS https://kyanitelabs.tech/declutter/health/readiness
```

Current expected shape:

- `self_hosted_mvp_ready: true`
- `home_inference_configured: true`
- `multimodal_model_configured: true`
- `ready_for_production: false`

`ready_for_production` is still false because optional external integrations are not configured (`firebase_admin`, cloud storage, eBay API).
That is expected for the self-hosted MVP.

## Restart / redeploy

### Quick restart only

```bash
ssh root@100.92.68.103
cd /docker/declutter
docker compose restart declutter-api
docker ps --filter name=declutter-api
curl -fsS https://kyanitelabs.tech/declutter/health/
```

### Pull latest main and rebuild

```bash
ssh root@100.92.68.103
cd /docker/declutter/DECLuTTER-AI
git fetch origin
git checkout main
git pull --ff-only origin main
cd /docker/declutter
docker compose build declutter-api
docker compose up -d declutter-api
docker inspect --format '{{.State.Health.Status}}' declutter-api
```

## Live smoke test

This avoids leaking the shared token in the process list.

```bash
ssh root@100.92.68.103
. /docker/declutter/env.hostinger
BASE='https://kyanitelabs.tech/declutter'
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
cat > "$TMPDIR/api.curlrc" <<CFG
header = "Authorization: Bearer ${DECLUTTER_SHARED_ACCESS_TOKEN}"
CFG
cat > "$TMPDIR/operator.curlrc" <<CFG
user = "operator:${DECLUTTER_SHARED_ACCESS_TOKEN}"
CFG
chmod 600 "$TMPDIR/api.curlrc" "$TMPDIR/operator.curlrc"

curl --config "$TMPDIR/api.curlrc" "$BASE/health/"
curl --config "$TMPDIR/api.curlrc" "$BASE/health/readiness"
curl -sS -o /dev/null -w '%{http_code}\n' "$BASE/operator"
curl --config "$TMPDIR/operator.curlrc" -sS -o /dev/null -w '%{http_code}\n' "$BASE/operator"
```

Expected:

- health returns `200`
- readiness returns `200`
- unauthenticated `/operator` returns `401`
- authenticated `/operator` returns `200`

## Full operator sprint QA

Form fields:

- file field: `image`
- text field: `condition`
- text field: `label_override`

Authenticated operator sprint request shape:

```bash
curl --config "$TMPDIR/operator.curlrc" \
  -X POST \
  -F "condition=good" \
  -F "label_override=" \
  -F "image=@/path/to/item.png;type=image/png" \
  "$BASE/operator/sprint"
```

Successful response markers:

- `Sprint complete`
- `Public listing URL`
- a generated `/declutter/public/listings/...` URL

## Last verified live result (2026-04-23)

Executed against production after deploying commit `6e87762`:

- `/health/` returned `200`
- `/health/readiness` returned `self_hosted_mvp_ready=true`
- unauthenticated `/operator` returned `401`
- authenticated `/operator` returned `200`
- protected `/analysis/intake` accepted a synthetic PNG upload
- protected `/analysis/run` returned:
  - engine: `openai-compatible:qwen3.6-35b-a3b`
  - labels: `book`, `camera`
- `/operator/sprint` completed successfully without manual override
- generated public listing returned `200`
- `/operator/sprint` also completed with manual label override `manual qa camera`

## Known limitations

1. `ready_for_production` is intentionally false until optional external integrations are configured.
2. The home model can be flaky; the adapter now retries alternate prompt variants before surfacing an error, but manual label override remains the operator escape hatch.
3. Public listings are self-hosted HTML pages, not marketplace listings.
4. Storage is local to the VPS volume, not cloud object storage.
5. Operator auth is shared-password Basic auth, suitable for the current private MVP but not a multi-user admin system.

## If the operator sprint fails

Check in this order:

1. container health
2. readiness endpoint
3. model endpoint env values in `/docker/declutter/env.hostinger`
4. recent container logs

Commands:

```bash
ssh root@100.92.68.103
cd /docker/declutter
docker ps --filter name=declutter-api
docker inspect --format '{{.State.Health.Status}}' declutter-api
docker logs --tail 100 declutter-api
```

If the image upload works but the model still flakes, retry once.
If it still fails, submit the operator form with `label_override` filled in so the listing can still be created.

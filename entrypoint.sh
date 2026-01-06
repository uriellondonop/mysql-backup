#!/usr/bin/env bash
set -euo pipefail

echo "▶️ Iniciando backup MySQL"

# ============================
# 1️⃣ Timestamp único
# ============================
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# ============================
# 2️⃣ Directorio local versionado
# ============================
LOCAL_BACKUP_DIR="backup/${TIMESTAMP}"
mkdir -p "$LOCAL_BACKUP_DIR"

echo "📂 Backup local: $LOCAL_BACKUP_DIR"

# ============================
# 3️⃣ Dump MySQL
# ============================
# shellcheck disable=SC2086
mydumper \
  --host "$MYSQL_HOST" \
  --user "$MYSQL_USER" \
  --password "$MYSQL_PASSWORD" \
  --port "$MYSQL_PORT" \
  --database "$MYSQL_DATABASE" \
  -C -c --clear \
  -o "$LOCAL_BACKUP_DIR"

echo "✅ Dump completado"

# ============================
# 4️⃣ Configuración rclone
# ============================
rclone config touch

cat <<EOF > ~/.config/rclone/rclone.conf
[remote]
type = s3
provider = Cloudflare
access_key_id = $R2_ACCESS_KEY_ID
secret_access_key = $R2_SECRET_ACCESS_KEY
endpoint = $R2_ENDPOINT
acl = private
EOF

# ============================
# 5️⃣ Subida a R2 (NO sync)
# ============================
REMOTE_PATH="$R2_BUCKET/$R2_PATH/$TIMESTAMP"

echo "☁️ Subiendo a R2: $REMOTE_PATH"

rclone copy "$LOCAL_BACKUP_DIR" "remote:$REMOTE_PATH"

echo "🏁 Backup finalizado correctamente"

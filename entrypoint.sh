#!/bin/sh
set -e

echo "▶️ Preparando backup MySQL..."

# 1️⃣ Timestamp único
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# 2️⃣ Construir path final
export R2_PATH="$R2_PATH/$TIMESTAMP"

echo "📂 Backup se guardará en: $R2_PATH"

# 3️⃣ Ejecutar entrypoint ORIGINAL del contenedor base
exec /docker-entrypoint.sh

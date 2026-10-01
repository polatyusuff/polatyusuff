#!/usr/bin/env bash
# Sunucu ve tüm node'ların durumunu tek ekranda gösterir.
# Kullanım: bash scripts/durum.sh
set -uo pipefail

echo "=== Sunucu ==="
echo "Çalışma süresi: $(uptime -p)"
echo "Yük:            $(cut -d' ' -f1-3 /proc/loadavg)"
free -h | awk 'NR==1 || /Mem|Swap/'
echo
df -h / | awk 'NR==1 || NR==2'
echo

echo "=== Node'lar ==="
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
for dir in "$ROOT"/nodes/*/; do
  name="$(basename "$dir")"
  [[ "$name" == _* ]] && continue
  [[ -f "$dir/docker-compose.yml" ]] || continue
  echo "--- $name"
  (cd "$dir" && docker compose ps --format 'table {{.Name}}\t{{.Status}}')
done

echo
echo "=== Kaynak kullanımı ==="
docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}'

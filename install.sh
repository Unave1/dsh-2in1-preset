#!/usr/bin/env bash
# 安装二合一破甲预设到当前 dsh 环境
set -euo pipefail

DSH_HOME="${DSH_HOME:-$HOME/.dsh}"
PROFILE="${PROFILE:-web}"
DST="$DSH_HOME/profiles/$PROFILE"
TS="$(date +%Y%m%d-%H%M%S)"

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

command -v dsh >/dev/null 2>&1 || echo "! 没找到 dsh 命令，装完自行验证"

mkdir -p "$DST"

if [ -f "$DST/cordis.patch.yml" ]; then
  cp "$DST/cordis.patch.yml" "$DST/cordis.patch.yml.bak.$TS"
  echo "· 已备份旧 profile patch -> cordis.patch.yml.bak.$TS"
fi
if [ -f "$DSH_HOME/AGENTS.md" ]; then
  cp "$DSH_HOME/AGENTS.md" "$DSH_HOME/AGENTS.md.bak.$TS"
  echo "· 已备份旧 AGENTS.md -> AGENTS.md.bak.$TS"
fi

cp "$here/cordis.patch.yml" "$DST/cordis.patch.yml"
cp "$here/AGENTS.md" "$DSH_HOME/AGENTS.md"

# 第一层必须没有 dsh-app:managed 标记，否则 App 升级会覆盖掉
if head -3 "$DSH_HOME/AGENTS.md" | grep -q "dsh-app:managed"; then
  sed -i '1,3{/dsh-app:managed/d}' "$DSH_HOME/AGENTS.md"
  echo "· 已移除 dsh-app:managed 标记"
fi

echo "✓ 装好了：$DST/cordis.patch.yml  和  $DSH_HOME/AGENTS.md"
echo "  验证：dsh --dump-config --profile $PROFILE | grep -E 'preset-purge|selectedDefault'"

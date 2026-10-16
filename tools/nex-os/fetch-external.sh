#!/bin/bash
# Baja a external/ las partes del SDK de Rockchip listadas en external.lock, cada una
# en su commit fijo. Si external/<dir> ya existe en ese commit, no hace nada.
#
# Uso: tools/nex-os/fetch-external.sh
set -euo pipefail

SDK_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
LOCK="$SDK_DIR/tools/nex-os/external.lock"

grep -Ev '^\s*(#|$)' "$LOCK" | while read -r dir repo commit; do
	dest="$SDK_DIR/external/$dir"
	if [ "$(git -C "$dest" rev-parse HEAD 2>/dev/null)" = "$commit" ]; then
		echo "external/$dir: ya en ${commit:0:12}"
		continue
	fi
	echo "external/$dir: bajando ${commit:0:12} de $repo"
	rm -rf "$dest"
	git init -q "$dest"
	git -C "$dest" fetch -q --depth 1 "$repo" "$commit"
	git -C "$dest" -c advice.detachedHead=false checkout -q FETCH_HEAD
done

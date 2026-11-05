#!/usr/bin/env bash
# Установка защиты от утечки секретов: pre-commit + Gitleaks (Linux/macOS).
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Запустите скрипт внутри Git-репозитория (в папке проекта)." >&2
  exit 1
fi
ROOT="$(git rev-parse --show-toplevel)"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v pre-commit >/dev/null 2>&1; then
  if command -v pipx >/dev/null 2>&1; then
    pipx install pre-commit
  elif command -v python3 >/dev/null 2>&1; then
    python3 -m pip install --user pre-commit
  else
    echo "Нужен Python 3 (python3) или pipx." >&2
    exit 1
  fi
  export PATH="$HOME/.local/bin:$PATH"
fi

for f in .pre-commit-config.yaml .gitleaksignore .gitleaks.toml; do
  if [ -e "$ROOT/$f" ]; then
    echo "Уже есть $f, не перезаписываю."
  else
    cp "$SRC/$f" "$ROOT/$f"
    echo "Скопирован $f"
  fi
done

cd "$ROOT"
pre-commit install
echo "Готово. Хук установлен в .git/hooks/pre-commit."
echo "Первый запуск скачает Gitleaks, нужен интернет."
echo "Проверка: pre-commit run --all-files"

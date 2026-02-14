#!/bin/bash
# PreToolUse hook: plan.md と prompt.md への編集を自動承認
#
# 入力: stdin から JSON (tool_name, tool_input)
# 出力: JSON で permissionDecision を返す

set -euo pipefail

INPUT=$(cat)

# ツール入力からファイルパスを取得
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

# ファイルパスが空の場合は何もしない（通常のフローに任せる）
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# plan.md または prompt.md への編集の場合、自動承認
if [[ "$FILE_PATH" == */plan.md || "$FILE_PATH" == */prompt.md ]]; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
  exit 0
fi

# それ以外は通常のフローに任せる
exit 0

---
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
description: '実装作業の開始時に、作業計画（plan.md）とプロンプト履歴（prompt.md）を管理する'
---

# 実装開始スキル

実装作業を開始する際に、構造化された作業ディレクトリを作成し、計画とプロンプト履歴を管理します。

## 使用方法

```
/start-impl <作業の説明>
```

または、ファイル参照付き：

```
/start-impl @file.md の内容を実装する
```

## 作業フロー

### Step 0: Plan Modeに入る

**重要**: このスキルを開始したら、まず `EnterPlanMode` ツールを使用してPlan Modeに入ってください。

Plan Modeでは：
- コードベースの探索と調査のみを行う（Read, Glob, Grep）
- 実際のコード変更は行わない
- **Plan Mode中はWrite/Editが使用できないため、ファイルへの書き込みは行わない**

探索が完了したら `ExitPlanMode` でPlan Modeを抜け、その後 prompt.md と plan.md への書き込みを行います。

### Step 1: 作業ディレクトリの初期化

以下のスクリプトを実行して作業ディレクトリを作成してください：

```bash
~/.claude/skills/start-impl/scripts/init-work-dir.sh "<作業名>" "<プロジェクトルート>/tmp"
```

**出力例:**
```json
{
  "work_dir": "/path/to/project/tmp/0001_feature-name",
  "plan_file": "/path/to/project/tmp/0001_feature-name/plan.md",
  "prompt_file": "/path/to/project/tmp/0001_feature-name/prompt.md",
  "sequence_number": "0001",
  "work_name": "feature-name"
}
```

### Step 2: Plan Modeを抜けてファイルに書き込む

探索が完了したら `ExitPlanMode` でPlan Modeを抜け、以下を行います：

1. `prompt.md` にユーザーからの指示を**そのまま**記録（加筆・修正は禁止）
2. `plan.md` に以下を記載：
   - 作業の概要と目的
   - 関連ファイルの調査結果
   - 実装計画（フェーズ分け、タスクリスト）
   - 懸念事項やリスク

### Step 3: ユーザー承認

**重要**: コード変更は勝手に実施してはいけません。

1. `plan.md` をユーザーに提示
2. 実装の許可を得る
3. 許可が得られるまでプランを調整

### Step 4: 実装と記録

許可後：
1. 計画に従って実装
2. ユーザーからの追加指示は `prompt.md` に追記
3. 実施内容も `prompt.md` に記録

## prompt.md のフォーマット

```markdown
# プロンプト履歴

## 初回指示 (YYYY-MM-DD)

### ユーザーからの指示

{プロンプトをそのまま貼る}

### 実施内容

実施した内容を記載

---

## フィードバック 1 (YYYY-MM-DD)

### ユーザーからのフィードバック

{プロンプトをそのまま貼る}

### 実施内容

実施した内容を記載
```

## ヒント

- 作業ディレクトリは連番管理（0001, 0002, ...）で自動採番
- 作業名はハイフン区切りの小文字に正規化される
- 複数プロジェクトで使用可能（base-dir を指定）

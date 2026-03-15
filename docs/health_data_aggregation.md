# ヘルスデータ集計機能 実装ノート

## 機能概要

Health Connect からヘルスデータ（体重・体脂肪率・摂取カロリー）を取得し、選択可能な集計期間ごとに統計値を算出・可視化する機能。

日々の測定値にはばらつきやノイズが含まれるため、生データをそのまま表示するのではなく、集計によって実際の体の傾向を把握しやすくすることが目的。

## 対象メトリクス

| メトリクス | Health Connect データ型 | 単位 |
|---|---|---|
| 体重 | WeightRecord | kg |
| 体脂肪率 | BodyFatRecord | % |
| 摂取カロリー | NutritionRecord (totalCalories) | kcal |

## 集計期間

- 1日
- 1週間
- 1ヶ月
- 将来的に追加可能な設計とする

## 算出する統計値

各メトリクス・各集計期間について以下を算出する:

- **平均値 (Average)**: 期間内データの算術平均
- **中央値 (Median)**: 期間内データの中央値。外れ値の影響を受けにくい
- **最大値 (Maximum)**: 期間内の最大測定値
- **最小値 (Minimum)**: 期間内の最小測定値

## データフロー

```
Health Connect (Android)
        │
        ▼
┌──────────────────┐
│   Data Layer     │
│                  │
│  HealthConnect   │
│  DataSource      │──→ Health Connect SDK 経由でデータ取得
│        │         │
│        ▼         │
│  DTO / Mapper    │──→ SDK の型を Domain Entity に変換
│        │         │
│        ▼         │
│  Repository      │──→ Domain 層の Repository interface を実装
│  Implementation  │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│  Domain Layer    │
│                  │
│  Repository      │──→ データ取得の契約（interface）
│  Interface       │
│        │         │
│        ▼         │
│  UseCase         │──→ 集計期間に基づく統計値の算出
│  (Aggregation)   │    （平均・中央値・最大・最小）
│        │         │
│        ▼         │
│  Entity          │──→ メトリクス値、集計結果を表現
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│ Presentation     │
│ Layer            │
│                  │
│  Provider /      │──→ Riverpod で状態管理
│  Notifier        │    UseCase を呼び出し UI 状態を更新
│        │         │
│        ▼         │
│  Page / Widget   │──→ チャート表示・サマリービュー
└──────────────────┘
```

### フロー詳細

1. **取得 (Retrieval)**: Data Layer の DataSource が Health Connect SDK を通じて指定期間の生データを取得する。取得したデータは DTO として受け取り、Mapper で Domain Entity に変換する。
2. **集計 (Aggregation)**: Domain Layer の UseCase が集計ロジックを実行する。集計期間（日・週・月）ごとにデータをグルーピングし、各グループに対して統計値（平均・中央値・最大・最小）を算出する。
3. **表示 (Display)**: Presentation Layer の Provider/Notifier が UseCase の結果を保持し、UI に提供する。Page/Widget がチャートやサマリーとして可視化する。

## レイヤー責務と配置方針

### Data Layer (`features/health_data/data/`)

| コンポーネント | 責務 |
|---|---|
| HealthConnectDataSource | Health Connect SDK との通信 |
| DTO (Data Transfer Object) | SDK レスポンスの型定義 |
| Mapper | DTO → Domain Entity の変換 |
| RepositoryImpl | Repository interface の実装 |

### Domain Layer (`features/health_data/domain/`)

| コンポーネント | 責務 |
|---|---|
| Entity | メトリクス値・集計結果のモデル |
| Repository (interface) | データ取得の契約定義 |
| UseCase | 集計ロジック（統計値算出） |

### Presentation Layer (`features/health_data/presentation/`)

| コンポーネント | 責務 |
|---|---|
| Provider / Notifier | Riverpod による状態管理、UseCase 呼び出し |
| Page | 画面構成 |
| Widget | チャート・サマリーの表示部品 |

## データソースに関する前提

- Health Connect は Android 専用 API であり、Flutter からは Platform Channel またはプラグイン経由でアクセスする
- Health Connect へのアクセスにはユーザーの明示的な権限許可が必要
- データの記録頻度はユーザーや連携アプリに依存するため、欠損期間が存在しうる

## 既知の制約と考慮事項

- **データ欠損**: 集計期間内にデータが存在しない場合の扱いを決める必要がある（空表示 or 前回値の引き継ぎ等）
- **Health Connect の利用可能性**: Health Connect が端末にインストールされていない場合のフォールバック処理
- **権限管理**: 権限が拒否された場合のエラーハンドリングと UI フィードバック
- **Platform Channel 設計**: Flutter ↔ Android 間の通信インターフェース設計

## 今後のタスク

- [ ] Health Connect プラグイン/Platform Channel の選定・実装
- [ ] Domain Entity の定義（メトリクス値、集計結果）
- [ ] Repository interface の定義
- [ ] 集計 UseCase の実装（平均・中央値・最大・最小）
- [ ] Repository 実装（Health Connect DataSource 経由）
- [ ] Riverpod Provider/Notifier の実装
- [ ] チャート表示の実装
- [ ] サマリービューの実装
- [ ] 集計期間の切り替え UI
- [ ] 権限リクエスト・エラーハンドリング
- [ ] データ欠損時の表示方針決定と実装
- [ ] 単体テスト（UseCase の集計ロジック）
- [ ] 結合テスト（データ取得〜表示の一連フロー）

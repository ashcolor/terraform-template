# Terraform Webシステムテンプレート

## ドキュメント

- [Terraform](https://registry.terraform.io/namespaces/hashicorp)

## 準備

1. IAMを作成する

1. tfstateファイルを保存するバケットを作成する

1. provider.tfのバケット名を変更する（この部分では変数を使用できないため）
```
  bucket = "{prefix}-terraform-state"
```

1. user_data.shにミドルウェアのインストールと設定を記載する


1. 環境ディレクトリに移動

```
cd [dev/stg/prod]
```

1. 変数定義ファイルをコピー
```
cp terraform.tfvars.example terraform.tfvars
```

  必要に応じて変数を書き換える

## 実行手順

プラグインのインストール

```yaml
terraform init
```

構文チェック

```bash
terraform validate
```

tfファイルのフォーマット

```bash
terraform fmt -recursive
```

実行計画の表示

```bash
terraform plan
```

リソースの適用

```yaml
terraform apply
```

リソースの削除

```bash
terraform destroy
```

関数の動作確認

```bash
terraform console
```

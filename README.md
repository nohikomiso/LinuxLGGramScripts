LG Gram ノートパソコンで Linux ドライバーの機能を活用するためのスクリプト集です。

このリポジトリは [leoomi/LinuxLGGramScripts](https://github.com/leoomi/LinuxLGGramScripts) のフォークであり、オリジナルのドライバーでは完全に対応していない **LG gram 15Z960 (2016年モデル)** 用の修正が含まれています。

## 動作確認済み環境
このリポジトリの修正（`acpi_call` フォールバック）は、以下の環境で正常に動作することを確認済みです。

| 項目 | 詳細情報 |
| :--- | :--- |
| **機種 (Model)** | LG gram 15Z960-G.AA12J (2016) |
| **BIOS** | 15ZA1730 X64 (2017/05/29) |
| **KBC** | 38.10.00 |
| **CPU** | Intel Core i5-6200U |
| **OS** | Ubuntu 24.04.4 LTS |
| **Kernel** | 6.11.0-29-generic |

## 2016年モデル (15Z960) などの旧モデルについて
標準の `lg_laptop` カーネルドライバーで充電制限パスが見つからない旧モデルでは、`acpi_call` をフォールバックとして使用します。

### 必須パッケージのインストール
旧モデルで動作させるには、以下のパッケージと `acpi_call` カーネルモジュールのビルドが必要です。Ubuntu 24.04 (HWEカーネル環境など) では DKMS により自動的に署名・ビルドされます。

```bash
# カーネルヘッダーのインストール (DKMSビルドに必要)
sudo apt install linux-headers-$(uname -r)

# acpi_call (DKMS) のインストール
sudo apt install acpi-call-dkms
sudo modprobe acpi_call
```

## インストール方法
このリポジトリをクローンし、ディレクトリを PATH に追加するか、`.sh` ファイルを既存の PATH が通ったディレクトリにコピーしてください。また、スクリプトに実行権限を与えてください。

```sh
chmod +x *.sh
```

## 使い方
これらのスクリプトは `sudo` を使用するため、パスワードが必要になる場合があります。
全てのスクリプトは、引数なしで実行すると現在の設定を反転（トグル）させます。また、明確に **on** または **off** をパラメータとして指定することも可能です。

例:
```sh
./lgbatterylimit.sh on
```

### 利用可能なスクリプト:
* `lgbatterylimit.sh` - 有効にすると、バッテリーの充電を 80% に制限します。バッテリーの寿命を延ばすのに役立ちます。
* `lgfamode.sh` - 静音ファンモードを有効にします。
* `lgfnlock.sh` - FN ロックを切り替えます。有効な場合、FN キーを押さなくても F キーの特殊機能が動作します。
* `lgreadermode.sh` - キーボードのリーダーモード LED を点灯させ、ブルーライトを削減するリーダーモードを有効にします。
* `lgtouchpadled.sh` - キーボードのタッチパッド LED をオン/オフします（タッチパッド自体の動作には影響しません）。
* `lgusbcharge.sh` - パソコンの電源がオフの時の USB 給電をオン/オフします。

## チップス
ブート時にはこれらの設定がリセットされるため、`cron` を使用して起動時に自動設定することをお勧めします。

```sh
sudo crontab -e
```

例:
```sh
@reboot /home/USER/path/to/lgbatterylimit.sh on
```

---
English documentation is available in [README_en.md](./README_en.md).

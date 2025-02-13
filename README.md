# jcls-typst
日本語標準 Typst 用テンプレート

## `jcls-typst`の概要

LaTeX の jsclasses に近い見た目を実現できる，日本語標準 Typst 用テンプレートです．

- `main.typ` : 文書本体ファイル
- `jcls.typ` : JSMEテンプレート用の設定ファイル
- `bib_style.typ` : 参考文献の設定ファイル
- `tex_jsme_style.typ` : BibTeX形式文献の設定ファイル

使用方法は，次章を参考にしてください．
必要なTypstファイル一式は，GitHub上の本レポジトリから入手可能で，自由に改変ができます．
本テンプレートを使用したことにより発生した問題に対しては，一切の責任を持ちませんのでご了承ください．

## 使用方法

`jcls-typst` の使用方法について説明します．

### 1. Typstのインストール

[Visual Studio Code](https://code.visualstudio.com/) を利用する方法が最も簡単です．
ローカル環境にダウンロードし，インストールを行ってください．

Visual Studio Code内の拡張機能から，`Tinymist Typst` を選択し，インストールします．
インストールが終わると，Typstがローカル環境で使用可能になります．

### 2. フォントのインストール

本テンプレートと同一の文書を作るには，使用するコンピュータにフォントのインストールが必要です．
本テンプレートで使用しているフォントは，全て無料でダウンロードが可能です．
使用しているフォントは，以下の通りです．

| 形式 | フォント名 |
| ---- | ---- |
| ゴシック体 | [Harano Aji Gothic](https://github.com/trueroad/HaranoAjiFonts) |
| 明朝体 | [Harano Aji Mincho](https://github.com/trueroad/HaranoAjiFonts) |
| 英字 | [CMU Serif](https://fontlibrary.org/en/font/cmu-serif#google_vignette) |
| 数式 | [Latin Modern Math](https://ctan.org/tex-archive/fonts/lm-math) |
| 日本語書式設定 | [Adobe Blank](https://github.com/adobe-fonts/adobe-blank) |

これ以外のフォントを使用したい場合，`jcls.typ`ファイル内の`setting font`のフォント名を変更することで使用できます．

### 3. 本テンプレートをコピー

本テンプレートをクローンして，ローカル環境で利用できるようにします．

```zsh
git clone https://github.com/tkrhsmt/jcls-typst.git
```

または，zipファイルをダウンロードしてください．

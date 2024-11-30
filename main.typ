
#import "style/jcls.typ": *
#import "style/bib_style.typ": *
#show: bib_init
#show: jcls_init
#show: equate.with(breakable: true, number-mode: "line")

#show: maketitle.with(
  title: [jclsテンプレート],
  authors: (
    (
      name: "橋本 丈瑠",
      email: "tkrhsmt@gmail.com",
      affiliation: "東京理科大学 機械航空宇宙工学科 塚原研究室",
    ),
  ),
  abstract: "",
  tableofcontents: true
)

#chapter[はじめに]

本テンプレートについて，その特徴や利用方法を紹介します．

= テンプレートの特徴

本テンプレートは，#latex の日本語classライクなtypst環境の構築を目指しています．
#latex では日本語テンプレートとしてjsclassesが使用されるケースが多く，なるべくこれに近いフォーマットとなるように調整しています．
テンプレートはgithub上で管理されており，誰でも自由に使用することができます．



= テンプレートの利用方法

本章では，テンプレートを利用するために必要な環境について説明します．

== フォントのインストール

本テンプレートでは，指定されたフォントを利用します．
このため，あらかじめ使用するPCにフォントのインストールが必要です．

#block(fill: luma(240), inset: 15pt, width: 100%)[
  - 明朝体　　　：　Harano Aji Mincho
  - ゴシック体　：　Harano Aji Gothic
  - 英字　　　　：　CMU Serif
  - 数式　　　　：　Latin Modern Math
]

これらのフォントは，全て無料で利用することができます．
日本語フォントは，#link("https://github.com/trueroad/HaranoAjiFonts")からダウンロード可能です．
英字フォントは，#link("https://fontlibrary.org/en/font/cmu-serif")などからダウンロード可能です．
数式フォントは，#link("https://ctan.org/tex-archive/fonts/lm-math")などからダウンロード可能です．

== typstのインストール

typstのインストールは，#link("https://github.com/typst/typst")を確認してください．
vscode上で実行する場合には，ターミナル環境でコンパイラをインストールする必要はありません．
vscodeの場合，「拡張機能」から「Tinymist Typst」を選択し，インストールします．

#pagebreak()
#chapter[テンプレートの表示]

このチャプターでは，本テンプレートがどのような見た目を出力するのかについて紹介します．

= 数式環境

数式を書くには，ドルマーク環境を用いて
```typst
$ H(X) = sum_(x in X) - p(x) log p(x) $
```
のように記述します．このとき，
$ H(X) = sum_(x in X) - p(x) log p(x) $
と表示されます．
複数行の数式を記述するには，
```typst
$
  I(X:Y) &= H(X) + H(Y) - H(X, Y)\
  &= H(X) - H(X|Y)\
  &= sum_(x in X, y in Y) p(x,y) log (p(x, y))/(p(x) p(y))
$
```
のように記述します．このとき，
$
  I(X:Y) &= H(X) + H(Y) - H(X, Y)\
  &= H(X) - H(X|Y)\
  &= sum_(x in X, y in Y) p(x,y) log (p(x, y))/(p(x) p(y))
$
と表示されます．
数式番号はequateパッケージを利用しており，改行ごとに番号が割り振られます．
しかし，長い数式などの関係で番号付けを一時的に避けたい場合があります．
この場合，次の`#nonumber`関数を利用できます．
例えば，
```typst
$
  F &= H(X)
    + lambda_1{integral_(-infinity)^(infinity) p(x) space d x - 1}
    + lambda_2{integral_(-infinity)^(infinity) p(x) x space d x}#nonumber\
    &#h(6cm)+ lambda_3{integral_(-infinity)^(infinity) p(x) x^2 space d x - sigma^2}
$<eq:laglange>
```
と書いた場合，
$
  F &= H(X)
    + lambda_1{integral_(-infinity)^(infinity) p(x) space d x - 1}
    + lambda_2{integral_(-infinity)^(infinity) p(x) x space d x}#nonumber\
    &#h(6cm)+ lambda_3{integral_(-infinity)^(infinity) p(x) x^2 space d x - sigma^2}
$<eq:laglange>
と出力されます．
このとき，`<eq:laglange>`のように記述したことで，この数式にラベルを付けることができます．
ラベルは`@eq:laglange`のようにして参照することで，@eq:laglange のように表示させることができます．

= figure環境

図や表は，typstの文法をそのまま利用できます．
以下はその例です．
使用時には，`#figure`関数を併用します．
これによって，図や表にキャプションや配置オプションを定義することができます．例えば，
```typst
#figure(
  table(
    columns: 2,
    [*Amount*], [*Ingredient*],
    [360g], [Baking flour],
    [250g], [Butter (room temp.)],
    [150g], [Brown sugar],
    [100g], [Cane sugar],
    [100g], [70% cocoa chocolate],
    [100g], [35-40% cocoa chocolate],
    [2], [Eggs],
    [Pinch], [Salt],
    [Drizzle], [Vanilla extract],
  ),
  caption: "TypstのTable guideで紹介されているクッキーのレシピ．",
  placement: bottom
)<cokkie-recipie>
```
のように書けば，以下のように表示されます．
#figure(
  table(
    columns: 2,
    [*Amount*], [*Ingredient*],
    [360g], [Baking flour],
    [250g], [Butter (room temp.)],
    [150g], [Brown sugar],
    [100g], [Cane sugar],
    [100g], [70% cocoa chocolate],
    [100g], [35-40% cocoa chocolate],
    [2], [Eggs],
    [Pinch], [Salt],
    [Drizzle], [Vanilla extract],
  ),
  caption: "TypstのTable guideで紹介されているクッキーのレシピ．",
  placement: bottom
)<cokkie-recipie>

#pagebreak()

引用するには，`@cokkie-recipie`のように記述すれば，@cokkie-recipie のように表示されます．

図の場合も，同様にして
```typst
#figure(
  image("figure/640x480.png", width: 50%),
  caption: "イメージの例．",
  placement: top
)<sample-image>
```
#figure(
  image("figure/640x480.png", width: 50%),
  caption: "イメージの例．",
  placement: top
)<sample-image>
のように記述すれば，上記のような表示が可能です．

引用するには，`@sample-image`のように記述すれば，@sample-image のように表示されます．

= 文献の引用

文献を引用するには，`bibliography-list`関数を利用します．
Typstでは，`bibliography`関数を使うのが一般的ですが，日本語文献には対応していません．
このため，本テンプレートでは独自に開発した文献管理システムを利用します．
これによって，日本語文献と英語文献を混在したBibTeX形式を利用することができます．
本テンプレートの文献形式は，日本機械学会のフォーマットに準拠しています．

文献の書き方は，例えば以下のようになります．

```typst
#bibliography-list(lang: "jp")[
    #bib-tex()[
        @article{tsukahara2023,
            author  = {塚原, 隆裕},
            yomi    = {Tsukahara, Takahiro},
            title   = {私の「ながれを学ぶ」使命感},
            journal = {ながれ：日本流体力学会誌},
            volume  = {42},
            number  = {3},
            pages   = {222},
            year    = {2023},
            url     = {https://www.nagare.or.jp/publication/nagare/archive/2023/3.html}
    ]
]
```

`bib-tex`関数を利用して，この中にBibTeX形式で文献を記述します．
或いは，BibTeXに準拠せず，直接記述することも可能です．

```typst
#bibliography-list(lang: "jp")[
    #bib-item(author: "塚原", year: "2023", label: <tsukahara2023_2>, yomi: "Tsukahara, Takahiro", yearnum: (110, 114))[塚原隆裕, 私の「ながれを学ぶ」使命感, ながれ：日本流体力学会誌, Vol. 42, No. 3, (2023), p. 222.]
]
```

文献の引用は簡単です．`@tsukahara2023`のように記述すれば，@tsukahara2023 のように文献を引用することができます．

#include "refs.typ"

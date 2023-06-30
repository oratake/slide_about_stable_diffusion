---
theme: gaia
paginate: true
backgroundColor: #fff
backgroundImage: url('https://marp.app/assets/hero-background.svg')
style: |
  span.text-small {
    text-size: 1em;
  }
  span.text-black-700 {
    color: #bbb;
  }

  section.split {
    overflow: visible;
    display: grid;
    grid-template-columns: 1fr 1fr;
    grid-template-rows: 100px auto;
    grid-template-areas: 
        "slideheading slideheading"
        "leftpanel rightpanel";
  }
  /* split debug */
  /*
  section.split h3, 
  section.split .ldiv, 
  section.split .rdiv { border: 1.5pt dashed dimgray; }
  */
  section.split h3 {
      grid-area: slideheading;
      font-size: 50px;
  }
  section.split .ldiv { grid-area: leftpanel; }
  section.split .rdiv { grid-area: rightpanel; }
---

<!--
_class: lead
_paginate: false
-->

![bg left:40%](https://user-images.githubusercontent.com/3185871/246604819-7898c656-611d-4de9-9f2c-05c4544f7f22.png)

# **今更 Stable Diffusion 入門してみた**

第6回 リベもくLT会  
oratake

スライド: ![w:200](https://marp.app/assets/marp.svg)

---

# **お品書き**

1. Stable Diffusion とは?
1. 画像生成の流れ
1. 生成の精度を上げるあれこれ
    1. 欲しい要素を手軽に追加 (LoRA/LyCORIS)
    1. ポーズを決め打ちで出す (ControlNet)

---

# 前提・おことわり

- あとでスライドは公開します
  - リンクついてます。具体的な手順は別途URLからご覧ください
- 今日は飛ばし飛ばしで雰囲気だけお話します
- 学習データをもとにした自動生成の是非については言及を差し控えます
  - 私は音楽を作曲、演奏する立場でしたが、生み出す人の力は本当に尊敬しています
  - 今回はあくまで画像生成の現状としてご覧ください

---

<!--
_backgroundImage: none
-->

![bg cover](https://github.com/oratake/slide_about_stable_diffusion/assets/3185871/99fca63e-8b22-4b62-81df-d28ba197231e)

---

<!--
_class: lead invert blend-difference
_backgroundColor: inherit
_backgroundImage: none
-->

![bg cover brightness:0.8](https://github.com/oratake/slide_about_stable_diffusion/assets/3185871/99fca63e-8b22-4b62-81df-d28ba197231e)

# Stable Diffusionとは？

```
# プロンプト
masterpiece, HDR, fantasy art, hills, ancient ruins crumbling,
holizon, small dragons,field of flowers
Negative prompt: <lora:easynegative:1>
Steps: 20, Sampler: DPM++ SDE Karras, CFG scale: 7, Seed: 256032659,
Face restoration: CodeFormer, Size: 720x480, Model hash: a1535d0a42, Model: AnythingV5Ink_v32Ink
```

---

# Stable Diffusionとは

- 2022年に登場した画像を生成することができるMLモデル(最新v2.1)
- 作成したい画像のイメージを英単語で区切って入力(**プロンプト**)することで、様々な画像を生成できる
- 類似: Midjourney、DALL·E2

![bg right:30%](https://user-images.githubusercontent.com/3185871/246637560-58962abb-2bee-4d55-8348-0fbb4118a08b.jpg)

```
# 右で爆ぜてるグリコさんのプロンプト例
1 girl, serious face, front view, full body,
sports uniform, rising hands up, running hard,
explosion background
```

---

<style scoped>
section {
  font-size: 1.5rem;
}
</style>

# Stable Diffusionの画像生成
- Stable(安定した) Diffusion(拡散) :[原理についての解説(GIGAZINE)](https://gigazine.net/news/20221006-visuals-explaining-stable-diffusion/)
- べらぼうな枚数の画像を特徴を表す**単語**と**重み**とともに学習、ノイズ化
- ノイズからプロンプトの単語っぽい特徴を見出して画像を磨き上げる(標準で20回ぐらい)
![w:600](https://user-images.githubusercontent.com/3185871/246441353-3168a2b8-6963-4674-9917-6676ae044738.jpg) ![w:400](https://user-images.githubusercontent.com/3185871/246342846-506d46f8-1976-4648-91db-86dbf7eb82f3.jpg)

cf. つまり[Stable Diffusionの生成設定まとめ](https://note.com/gcem156/n/n8b7c0c1a6ad9) ≒ [超簡単！！ふくろうの書き方](https://ameblo.jp/muko104/entry-11209884633.html) ...ってｺﾄ!? <span class="text-black-700 text-small"><ﾌｩﾝ!?</span>

<!--
拡散モデル: ノイズ画像から少しずつノイズを取り除くことでキレイな画像を生成するモデル
拡散→逆拡散
拡散されたガウシアンノイズ(完全なノイズ)からU-Netというニューラルネットワークで逆拡散(画像生成)
-->

---

<!-- _class: lead -->
# **こまけぇこたぁいいんだよ**
![w:700](https://pbs.twimg.com/media/CCehL_CUIAAlpZK.png)
参考画像はよ

---

### 実際の画像の作り方

**きょうのレシピ**

- よさめのグラボ ・・・ 1丁
- Stable Diffusion・・・大さじ1
- Pythonが動く環境・・・少々
- 学習モデル(Checkpoint)・・・お好みで

※ 参考までに小生の環境:
Core i7 Gen10 (8C16T) + RTX3060 mobile + Linux
Stable Diffusion Web UI (AUTOMATIC1111版) + Docker

---

<!-- _class: lead -->

![bg left:30%](https://github.com/oratake/slide_about_stable_diffusion/assets/3185871/294dd2c1-0567-454e-9fb9-c5418e9a1f86)

# 画像生成の流れ
### _画像生成職人の朝は早い―_

```
# プロンプト
masterpiece, HDR, 1 girl, (Monk's working clothes, dark orange wear),
seriously face, black low ponytail, turning pottery on the wheel, japanese pottery, ceramic art
Negative prompt: <lora:easynegative:1>
Steps: 20, Sampler: DPM++ SDE Karras, CFG scale: 7, Seed: 2263055328,
Face restoration: CodeFormer, Size: 480x720, Model hash: a1535d0a42, Model: AnythingV5Ink_v32Ink
```

---

# 画像生成の流れ

txt2img(単語から画像)での画像生成
1. Stable Diffusion を準備
1. モデルを選んで作りたい画像の特徴を書き出す
1. ＼生成／

詳しくみていく→

---

### Stable Diffusion の準備
<!-- _class: split -->

<div class="ldiv">

![w:500](https://user-images.githubusercontent.com/3185871/248258639-4535212a-db24-4247-a8e7-725b38f90d88.png)

</div>

<div class="rdiv">

- AUTOMATIC1111版 Web UI がおすすめ(わりとユーザ多そう)
- グラボがなくてもできるが、時間がべらぼうに掛かるのであった方は良い

導入方法例:
[Win+Python](https://resanaplaza.com/2023/05/21/%E3%80%90%E6%9C%80%E7%9F%AD%EF%BC%86%E7%B0%A1%E5%8D%98%E3%80%91stable-diffusion-web-ui-%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB%E6%96%B9%E6%B3%95%EF%BC%88automatic1111%E7%89%88%EF%BC%89/), [Docker](https://github.com/AbdBarho/stable-diffusion-webui-docker)

</div>

---

### モデルを選択

モデルは [ChilloutMix(リアル系)](https://civitai.com/models/6424/chilloutmix) か [Anything(アート系)](https://civitai.com/models/9409?modelVersionId=90854)を使用
※ChilloutMixはセンシティブ注意

- [Civitai](https://civitai.com/)
MLモデル、LoRAの配布サイト
センシティブ(+13)の閲覧はログインが必要

---

<style scoped>
  section.split {
    grid-template-columns: 6fr 4fr;
    grid-template-rows: 50px auto;
  }
</style>

### モデル例
<!-- _class: split -->

<div class="ldiv">

|Anything v5|ChilloutMix Ni|
|:--:|:--:|
|![w:300](https://user-images.githubusercontent.com/3185871/248264983-82d79ba6-98b2-401d-8c08-41c7e9b4f19c.png)|![w:300](https://user-images.githubusercontent.com/3185871/248265708-dad24ab6-d449-4b39-b0dc-92170ad20190.png)|

</div>

<div class="rdiv">

アート系とリアル系の代表的なモデル

```
# プロンプト
masterpiece, HDR, 1 girl,
smile, straw hat,
white dress, meadow
<negative> EasyNegative, nsfw
```

</div>

---

### 生成前の設定
- **Prompt** と **Negative Prompt** の項目に単語,文章を指定する
  - Promptには画像に付与したい特徴、  
  Negativeには要らない特徴を指定
- **画像サイズ**、**生成の回数**を指定
  - 画像サイズが大きいと生成に時間がかかるが綺麗になり **やすい** (なるとは言っていない)
  - 生成回数が多いと画像が綺麗になり **やすい** (なるとは言って略
  - 小生は20回、480x720ぐらいで生成する
    - 人物生成,ポートフォリオが多いので縦長にしがち
- Generateで生成

---

<style scoped>
  section.split p {
    margin-top: 0px;
  }
  section.split marp-pre {
    margin-top: 0px;
  }
</style>

### プロンプトの一例
<!-- _class: split -->

<div class="ldiv">

![](https://github.com/oratake/slide_about_stable_diffusion/assets/3185871/72456ad7-9b12-4576-b232-dba29a49fce6)

</div>

<div class="rdiv">

- 文頭に高画質系の単語を並べてくっきりした画像にする
  - どうしてもノイズから作っているからかぼやけがち
- カンマ区切り(文でも可)
- ()や数値で強調、{}やマイナスで弱める

```
masterpiece, HDR, 1 girl, solo, chibi:1.5,
cute dress with ruffles, (fuwafuwa illustration:1.2),
white background, <lora:NadaNamie:1>
```

</div>

---

### よくつかう単語例

- エログロ避け: nsfw (ネガティブに記載)
Not Safe for Work つまり職場では見られないよ！ということ
- 高画質系: masterpiece, HDR, hyper detailed 部位名
- 画角: cowboy shot, looking at viewer
- 装飾: brown black low ponytail with pink fluffy scrunchies

- プロンプトの勉強に→ [ちちぷい](https://www.chichi-pui.com/)
AI生成画像投稿サイト。たまにプロンプトが併記されてる。
参考にしつつ、よさそうなLoRAやModelの物色にも使える。
センシティブ絵もそこそこあるのでnsfw！

---

<!-- _class: lead -->

# **精度を上げるあれこれ**

---

<!-- _class: lead -->

### あるある

例:ベタ塗りタッチのパキっとした絵を生成したい
→それについてのプロンプトを毎回大量に書く必要がある
→うまいこといかねぇ
→めんどい。

---

### LoRAで楽をする
- Low-Rank Adaptation: 数十枚程度で学習できるモデル
- メインの学習モデルに対して容量がだいぶ少ないものが多い
cf. Checkpoint: 3GB, LoRA: 100MB
※目的が違うので単純比較はできないことに留意
- 文字のプロンプトでは足りない特徴を付加するのに向いている
- プロンプトと同様に組み合わせることも可能

---

### LoRAの一例 (flat color)

![w:500](https://user-images.githubusercontent.com/3185871/248477717-bbff4f08-fc96-47b7-b7a6-21dd9256d721.png) ![w:500](https://user-images.githubusercontent.com/3185871/248477970-2555b408-a286-400f-801d-0e35295bb4a2.png)
← Flat Color あり

---

### いまの画像のプロンプト

```
masterpiece, HDR, 1 girl, 18yo, full body, gravure pose, hyper detailed face,
extreamly kind face, cute face, kawaii, oversized white shirt with fluffy,
(light pink short pants), (black leggings), brown black low twintails, BREAK
street, pavement with stone, brick building, building sign, congestion
Negative prompt: <lora:easynegative:1>, skirt
```

`<lora:flat_color:1>` を足しただけで鈴木英人,わたせせいぞう感出る

![w:300](https://data.smart-flash.jp/wp-content/uploads/2020/09/28123041/suzuki1_1_Y.jpg) ![w:370](https://seizo-watase.com/wp/wp-content/uploads/2022/08/kyobashi2022_thum-730x500.jpg)

---

<!-- _class: lead -->

### あるある

![w:400](https://shitekikininarunews.up.seesaa.net/image/img_1.jpg)
~~変な~~かっこいいポーズさせてぇ

---

### OpenPoseでポーズ制御

- MLの姿勢推定でよく使われるもの(らしい)
- 3次元の姿勢を推定して2次元画像で表現できる

![w:300](https://shitekikininarunews.up.seesaa.net/image/img_1.jpg) ![w:360](https://user-images.githubusercontent.com/3185871/248469762-ec2fd80a-8ef3-44d0-94c1-f0186b36cd20.png) ![w:360](https://user-images.githubusercontent.com/3185871/248469819-6cb1dc2a-6f37-4b2b-a32c-90cdf2fb4be0.png)

---

<!-- _class: lead -->

### もうちょい難しそうなやつ

![w:500](https://camo.githubusercontent.com/97ece0acecc916ff427b4a1c92078b3d7113528ea2a5afc0f6aa85d65f75210c/68747470733a2f2f7062732e7477696d672e636f6d2f6d656469612f4648353347746a61514141443478713f666f726d61743d6a7067266e616d653d6c61726765)

---

### 推定がうまく行かないことも

![w:400](https://camo.githubusercontent.com/97ece0acecc916ff427b4a1c92078b3d7113528ea2a5afc0f6aa85d65f75210c/68747470733a2f2f7062732e7477696d672e636f6d2f6d656469612f4648353347746a61514141443478713f666f726d61743d6a7067266e616d653d6c61726765) ![w:350](https://user-images.githubusercontent.com/3185871/247779714-aba9058a-5f00-497b-ba60-81a36a655c50.png) ![w:350](https://user-images.githubusercontent.com/3185871/247779694-97d9dbaf-f754-48b5-ab6d-abbd1af1de56.png)

---

### (解決策)あるよ。

- [OpenPose Editor(公式:導入手順)](https://github.com/fkunn1326/openpose-editor.git)

![w:500](https://user-images.githubusercontent.com/3185871/248482768-67f002df-ae1f-4092-b843-3aee6db06cc4.png) ![bg right:40%](https://user-images.githubusercontent.com/3185871/248257334-ba4f708c-33fa-4604-a0e3-c05bdce63730.png)

- 3Dでいじるやつもあった [3D OpenPose Editor](https://github.com/nonnonstop/sd-webui-3d-open-pose-editor)

---

### こんなこともある

ツェペリのおっさんじゃないすか
![w:300](https://user-images.githubusercontent.com/3185871/248257334-ba4f708c-33fa-4604-a0e3-c05bdce63730.png)正 ![w:300](https://user-images.githubusercontent.com/3185871/248255553-95b25681-528f-47a2-90e8-c23f8eaa7c8c.png)誤
![bg right:30%](https://manga-fan.info/jojo/img/0017_m500.jpg)

---

### 考察

- おそらく関節の点でしか認識できてない？
- 足が卍型になるより外側に折り畳んだほうが自然と判定したのでは
- ツェペリのおっさん爆誕
- あまりにも変なポーズは取らせづらそう
- 人体の構造を無視すると生成自体失敗する

---

### この他にも色々と

- [Cutoff](https://koneko3.com/cutting-off-prompt-effect/) 色移り低減
- [ControlNet Reference](https://koneko3.com/controlnet-v11-preprocess-reference/) 同じキャラ生成
- [Latent Couple](https://koneko3.com/how-to-use-latent-couple/) 人の書き分け(画面分割プロンプト適用)
- [ControlNet SoftEdge](https://www.ultra-noob.com/blog/2023/18/) 線を維持して色を塗り替える

などなど

* オレ達の戦いはまだ始まったばかりだ...!
**★oratake先生の次回作にご期待ください**

---

### 画像の自動生成界隈に触れてみての所感

- すごいじだいになったなぁとおもいました(小並感)
- 著作権フリーな画像を用いたモデルの選定も進む
  - 適正な商用利用のため
- 「極めてなにか生命に対する侮辱を感じ」るものが生成されることもままある
  - 顔、指が特に崩壊しがち腕足増え目だが、完成度は日々高まっている
- 自動生成とはいえ生成者の発想、知見は相当問われる
  - なんか作って、でいいものができないのは何事でも同じ。作業者のスキルを活かすのは自分

---

### ご清聴ありがとうございました

**生産者表示**

|||
|:--:|--|
|リベ名|oratake|
|仕事|東大阪の町工場の営業|
|職歴|中学校教員(音楽,技術), バックエンド屋|
|興味範囲|Vim,ArchLinux,React,PHP,Docker,GraphQL,Rust,WASM|
|好きなこと|鉄道,旅,キャンプ,珈琲お茶,ぬいぐるみ|


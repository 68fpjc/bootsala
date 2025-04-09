# bootsala.x

## これはなに？

X68000 版『沙羅曼蛇』の実行ファイルを読み込み、メモリ上でパッチを当てて起動するツールです。黒歴史として公開します。

以下は、当時のアーカイブに同梱されていた bootsala.doc です (一部修正してあります) 。

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

		   今さらという気がしないでもないけど
		    「沙羅曼蛇」ダイナミックパッチャ
			       bootsala.x
			Copyright 1998 Igarashi

───────────────────────────────────
━━━━━━
これはなに？
──────
　「沙羅曼蛇」(Copyright 1986 KONAMI, 1988 SHARP/SPS) のHDDインストール
を支援するプログラムです。

━━
詳細
──
　「沙羅曼蛇」メインプログラムSALA.Xは、メモリアドレス$f0000～$fdfffの固
定領域をゲーム用ワークエリアとして使用しています。そのため、余計なデバイ
スドライバや常駐プログラムを組み込んでいると、このワークエリアが確保でき
ずに異常終了してしまいます。これがネックになって、多くの場合、HDDへのイ
ンストールはうまくいきません (正確にはメモリの使用状況の問題なのですが)。
bootsala.xは、この現象を回避するためのプログラムです。

━━━
使い方
───
１：HDD上に適当なディレクトリを作り、「沙羅曼蛇」マスターディスク中のファ
    イルをすべてコピーする

２：１のディレクトリまたは、環境変数pathの通っているディレクトリに
    bootsala.xをコピーする

３：以下のような起動用バッチファイルを作る
	mux
	msx -s soundprm.sal
	msx -b14 bgmdata.sal
	bootsala
	mux -r

４：１のディレクトリに移動し、FD0に「沙羅曼蛇」マスターディスクを挿入し、
    ３のバッチファイルを実行する

※　起動には700Kバイト程度のフリーエリアが必要です。

━━━━━
オプション
─────
　'bootsala -?'などと未定義のオプションを指定すると、下記のような簡単な
ヘルプを表示します。

	DINAMIC-PATCHER for 沙羅曼蛇 Copyright 1998 Igarashi
	usage:	bootsala [option]
		-c<0-f>	クレジット設定
		-t<0-1>	サウンドタイプ設定
		-p<0-3>	残機数設定
		-l<0-1>	コイン投入口設定
		-x<0-3>	最大クレジット設定
		-d<0-3>	難易度設定
		-s<0-1>	デモサウンド設定
		-o<0-1>	モニタ選択
		-m<0-1>	テストモード選択
		-g<0-3>	画面モード設定
	デフォルトは -c0 -s0 -p1 -l1 -x1 -d1 -e0 -o0 -m1 -g0 です

　bootsala.xで使用できるオプションを以下に示します。オプションの大文字、
小文字は区別しません。

	-c<n>	クレジット設定
			n=0	1 COIN 1 CREDIT
			n=1	1 COIN 2 CREDIT
			n=2	1 COIN 3 CREDIT
			n=3	1 COIN 4 CREDIT
			n=4	1 COIN 5 CREDIT
			n=5	1 COIN 6 CREDIT
			n=6	1 COIN 7 CREDIT
			n=7	2 COIN 1 CREDIT
			n=8	2 COIN 3 CREDIT
			n=9	2 COIN 5 CREDIT
			n=a	3 COIN 1 CREDIT
			n=b	3 COIN 2 CREDIT
			n=c	3 COIN 4 CREDIT
			n=d	4 COIN 1 CREDIT
			n=e	4 COIN 3 CREDIT
			n=f	x COIN x CREDIT (プレイ不可)
	-t<n>	サウンドタイプ設定
			n=0	テーブル筐体用
			n=1	アップライト筐体用
	-p<n>	残機数設定
			n=0	残機数２
			n=1	残機数３
			n=2	残機数５
			n=3	残機数７
	-l<n>	コイン投入口設定
			n=0	投入口１つ
			n=1	投入口２つ
	-x<n>	最大クレジット設定
			n=0	最大クレジット１
			n=1	最大クレジット３
			n=2	最大クレジット５
			n=3	最大クレジット９
	-d<n>	難易度設定
			n=0	EASY
			n=1	NORMAL
			n=2	DIFFICULT
			n=3	VERY DIFFICULT
	-s<n>	デモサウンド設定
			n=0	デモサウンドなし
			n=1	デモサウンドあり
	-o<n>	モニタ選択
			n=0	NORMAL
			n=1	UPSIDE DOWN
	-m<n>	テストモード選択
			n=0	GAME
			n=1	SELF TEST
	-g<n>	画面モード設定
			n=0	256*256 31KHz
			n=1	256*256 15KHz
			n=2	512*512 31KHz
			n=3	512*512 15KHz

　'-g'オプション以外は、DIPSW.SALによるディップスイッチ機能をオプション
化したものです (DIPSW.SALについては後述)。

━━━━━━
実行時の注意
──────
●bootsala.xは、以下のバージョンのSALA.Xにのみ対応しています。

	SALA               X       141119  88-09-29  11:58:00

ただし、bootsala.xには隠しオプションがあって…詳しくはbootsala.sを読んで
ください。

●ZMUSICなどのサウンドドライバは常駐解除しておきましょう。

●Timer-Dが動いていると、悲惨なことになります。Human68Kのバックグラウン
ド機能を有効にしている方は、TNB製作所のTDPAUSE.XやY.Nakamura氏のBGOFF.X
などでTimer-Dを殺しておきましょう。また、これらはMUX.Xよりも先に実行する
ようにしてください。例えばTDPAUSE.Xを使用する場合、起動用バッチファイル
の内容は以下のようになります。

	tdpause
	mux
	msx -s soundprm.sal
	msx -b14 bgmdata.sal
	bootsala
	mux -r
	tdpause -r

●X68030対策として、bootsala.x内部でスプリアス割り込みを殺しているので、
sprious.x等は不要です。また、Xellent30(s)環境ではかまだ氏のSALA030.BFDに
よる、MUX.Xへのパッチが必要 (のはず) です (X68030では必要ないと思うので
すが…)。

●作者はX68030上でのみ動作確認をしています。

━━━━━━━━━━━━
X68000版「沙羅曼蛇」の謎
────────────
　X68000版「沙羅曼蛇」の解析結果を少しだけ、以下に紹介します。X68ゲーマー
の間では常識かも知れませんが…。

●X68000版では、SALA.X起動時にカレントディレクトリからDIPSW.SALという３
バイトのファイルを読み込んで、アーケード版でいうディップスイッチの設定を
することができます (DIPSW.SALが見つからなかった場合は、SALA.X内部のデー
タが使用されます)。

	１バイト目 (デフォルト：$00 = %0000_0000)
	┌─┬─┬─┬─┬─┬─┬─┬─┐
	│  │ 0│ 0│ 0│              │
	└─┴─┴─┴─┴─┴─┴─┴─┘
          │                    │
          │                    0000 ... 1 COIN 1 CREDIT
          │                    0001 ... 1 COIN 2 CREDIT
          │                    0010 ... 1 COIN 3 CREDIT
          │                    0011 ... 1 COIN 4 CREDIT
          │                    0100 ... 1 COIN 5 CREDIT
          │                    0101 ... 1 COIN 6 CREDIT
          │                    0110 ... 1 COIN 7 CREDIT
          │                    0111 ... 2 COIN 1 CREDIT
          │                    1000 ... 2 COIN 3 CREDIT
          │                    1001 ... 2 COIN 5 CREDIT
          │                    1010 ... 3 COIN 1 CREDIT
          │                    1011 ... 3 COIN 2 CREDIT
          │                    1100 ... 3 COIN 4 CREDIT
          │                    1101 ... 4 COIN 1 CREDIT
          │                    1110 ... 4 COIN 3 CREDIT
          │                    1111 ... x COIN x CREDIT (プレイ不可)
          0 ... SOUND TYPE TABLE
          1 ... SOUND TYPE UPRIGHT

	２バイト目 (デフォルト：$ad = %1010_1101)
	┌─┬─┬─┬─┬─┬─┬─┬─┐
	│  │      │      │  │      │
	└─┴─┴─┴─┴─┴─┴─┴─┘
          │    │      │    │    │
          │    │      │    │    00 ... 2 PLAYER
          │    │      │    │    01 ... 3 PLAYER
          │    │      │    │    10 ... 5 PLAYER
          │    │      │    │    11 ... 7 PLAYER
          │    │      │    0 ... COIN SLOT ONE
          │    │      │    1 ... COIN SLOT TWO
          │    │      00 ... MAX CREDIT 1
          │    │      01 ... MAX CREDIT 3
          │    │      10 ... MAX CREDIT 5
          │    │      11 ... MAX CREDIT 9
          │    00 ... EASY
          │    01 ... NORMAL
          │    10 ... DIFFICULT
          │    11 ... VERY DIFFICULT
	  0 ... DEMO SOUND OFF
	  1 ... DEMO SOUND ON

	３バイト目 (デフォルト：$80 = %1000_0000)
	┌─┬─┬─┬─┬─┬─┬─┬─┐
	│  │ 0│  │ 0│ 0│ 0│ 0│ 0│
	└─┴─┴─┴─┴─┴─┴─┴─┘
          │      │
          │      0 ... MONITOR NORMAL
          │      1 ... MONITOR UPSIDE DOWN
          │
	  0 ... GAME
	  1 ... SELF TEST

　X68000版では意味のないものもあります…ということはつまり、bootsala.xの
オプションでも実は意味をなさないものがあるということです。

　なお、bootsala.x使用時には常に、DIPSW.SALの設定内容は無視されます。オ
プションを使用してください。

●　キーボード操作による特殊機能一覧

	・SHIFT+UNDO
		→DOS復帰
	・SHIFT+OPT.1キーを押しながら起動
		→テストモード
	・HELPキーを押しながら起動
		→15KHzモード (※)
	・INSキーを点灯させたまま、SHIFTキーを押しながら起動
		→512*512ドットモード (※)
	・SHIFTキーを押しながら起動、以下のようにLEDを点灯させ、OPT.1を
	  押しながらゲームスタート
			かな   ローマ字 コード入力
			 OFF        OFF        OFF ... ROUND 1
			 OFF        OFF         ON ... ROUND 2
			 OFF         ON        OFF ... ROUND 3
			 OFF         ON         ON ... ROUND 4
			  ON        OFF        OFF ... ROUND 5
			  ON        OFF         ON ... ROUND 6
		→ラウンドセレクト

(※) … bootsala.x使用時には無視されます。オプションを使用してください。

━━━━━━━━━━
再アセンブルについて
──────────
　Makefileを読んでください。

━━━━━━
その他の注意
──────

●bootsala.xは、私が勝手に作成したものです。コナミ、シャープ、SPSとは無
関係ですので、各社に対する問い合わせは御遠慮ください。

●例によって無保証です。各自の責任において使用してください。


						     Jan 1 1998 いがらし
```

## 連絡先

https://github.com/68fpjc/bootsala

*========================================================================
*	bootsala.s
*			Written by Igarashi
*========================================================================
		.cpu	68000
*========================================================================
		.include	doscall.mac
		.include	iocscall.mac
*========================================================================
		.text
		.even
*========================================================================
entry:
		lea.l	inisp(pc),sp

		bsr	initdosvec	*for SETPDB

		movea.l	a0,a5

		bsr	offmem		*bss以降のメモリブロックを解放
		bsr	puttitle	*タイトル表示
		bsr	chkarg

		bsr	chkver
				*SALA.Xをロード
		pea.l	0.w		*環境 (親と同じ)
		pea.l	(sp)		*コマンドライン (なし)
		pea.l	salafn(pc)	*実行ファイル名 ('SALA.X')
		move.w	#1,-(sp)	*EXEC_LOADONLY
		DOS	__EXEC
		lea.l	14(sp),sp
		tst.l	d0
		bmi	loaderror

				*ロードしたままエラー終了すると
				*まずいらしいので
		pea.l	16(a5)		*SIZEofMEMPTR
		DOS	__SETPDB
		addq.l	#4,sp

		bsr	patch1		*パッチ１
		bsr	patch2		*パッチ２
		bsr	flushcache	*MPU キャッシュのフラッシュ

		bsr	setspint	*スプリアス割り込みを殺す

				*SALA.Xにプロセス管理を戻す
		pea.l	16(a0)		*SIZEofMEMPTR
		DOS	__SETPDB
		addq.l	#4,sp

		bsr	savemfp
		move.l	a4,-(sp)	*スタートアドレス
		move.w	#4,-(sp)	*EXEC_EXECONLY
		DOS	__EXEC
		addq.l	#6,sp
		move.l	d0,-(sp)
		bsr	rstrmfp
		tst.l	(sp)+
		bmi	execerror

.ifdef SAVE_SPURIOUS
		bsr	resetspint	*スプリアス割り込みを復帰
.else
					*ベクタアドレスは復帰しない
					*（ROM中を指したまま）
.endif	*SAVE_SPURIOUS
		DOS	__EXIT

*------------------------------------------------------------------------
nfounderror:	lea.l	nfoundmes(pc),a0
		bra	errorexit
vererror:	lea.l	vererrmes(pc),a0
		bra	errorexit
vererror2:	lea.l	vererrmes2(pc),a0
		bra	errorexit
loaderror:
		lea.l	loaderrmes(pc),a0
		bra	errorexit
execerror:
		lea.l	execerrmes(pc),a0
		bra	errorexit
usage:
		lea.l	usgmes(pc),a0
errorexit:
		move.w	#2,-(sp)	*STDERR
		pea.l	(a0)
		DOS	__FPUTS
		addq.l	#6,sp

		move.w	#1,-(sp)
		DOS	__EXIT2

*------------------------------------------------------------------------
*	MFPの辻褄合わせ
*	TACRのみセーブしているけど、他にもあるかも…
*------------------------------------------------------------------------
savemfp:
SAVREGS		reg	d0-d1/a0-a1
		movem.l	SAVREGS,-(sp)
		lea.l	$e88019,a1	*TACR
		IOCS	__B_BPEEK
		move.b	d0,mfpbuf
		movem.l	(sp)+,SAVREGS
		rts
rstrmfp:
SAVREGS		reg	d0-d1/a0-a1
		movem.l	SAVREGS,-(sp)
		lea.l	$e88019,a1	*TACR
		move.b	mfpbuf,d1
		IOCS	__B_BPOKE
		movem.l	(sp)+,SAVREGS
		rts

*------------------------------------------------------------------------
*	コマンドライン解析
*		in:	a2.l	コマンドライン
*		out:	none
*		broken:	none
*------------------------------------------------------------------------
chkarg:
SAVREGS		reg	d0-d4/a0/a2
		movem.l	SAVREGS,-(sp)
		lea.l	dipsw(pc),a0
DIPSW0		reg	d2
DIPSW1		reg	d3
DIPSW2		reg	d4
		move.b	0(a0),DIPSW0
		move.b	1(a0),DIPSW1
		move.b	2(a0),DIPSW2

		addq.l	#1,a2
arglp:		move.b	(a2)+,d0
		beq	chkargretn
		cmpi.b	#' ',d0
		beq	arglp
		cmpi.b	#'	',d0
		beq	arglp
		cmpi.b	#'-',d0
		bne	usage
		move.b	(a2)+,d0
		ori.b	#$20,d0
		cmpi.b	#'v',d0
		beq	vopt
		move.b	(a2)+,d1
		bsr	gethex
		bmi	usage
		cmpi.b	#'c',d0
		beq	copt
		cmpi.b	#'t',d0
		beq	topt
		cmpi.b	#'p',d0
		beq	popt
		cmpi.b	#'l',d0
		beq	lopt
		cmpi.b	#'x',d0
		beq	xopt
		cmpi.b	#'d',d0
		beq	dopt
		cmpi.b	#'s',d0
		beq	sopt
		cmpi.b	#'o',d0
		beq	oopt
		cmpi.b	#'m',d0
		beq	mopt
		cmpi.b	#'g',d0
		beq	gopt

		bra	usage
vopt:		st.b	extend
		bra	arglp
copt:		cmpi.b	#15,d1
		bhi	usage
		andi.b	#%1111_0000,DIPSW0
		or.b	d1,DIPSW0
		bra	arglp
topt:		cmpi.b	#1,d1
		bhi	usage
		ror.b	#1,d1
		andi.b	#%0111_1111,DIPSW0
		or.b	d1,DIPSW0
		bra	arglp
popt:		cmpi.b	#3,d1
		bhi	usage
		andi.b	#%1111_1100,DIPSW1
		or.b	d1,DIPSW1
		bra	arglp
lopt:		cmpi.b	#1,d1
		bhi	usage
		rol.b	#2,d1
		andi.b	#%1111_1011,DIPSW1
		or.b	d1,DIPSW1
		bra	arglp
xopt:		cmpi.b	#3,d1
		bhi	usage
		rol.b	#3,d1
		andi.b	#%1110_0111,DIPSW1
		or.b	d1,DIPSW1
		bra	arglp
dopt:		cmpi.b	#3,d1
		bhi	usage
		ror.b	#3,d1
		andi.b	#%1001_1111,DIPSW1
		or.b	d1,DIPSW1
		bra	arglp
sopt:		cmpi.b	#1,d1
		bhi	usage
		ror.b	#1,d1
		andi.b	#%0111_1111,DIPSW1
		or.b	d1,DIPSW1
		bra	arglp
oopt:		cmpi.b	#1,d1
		bhi	usage
		ror.b	#3,d1
		andi.b	#%1101_1111,DIPSW2
		or.b	d1,DIPSW2
		bra	arglp
mopt:		cmpi.b	#1,d1
		bhi	usage
		ror.b	#1,d1
		andi.b	#%0111_1111,DIPSW2
		or.b	d1,DIPSW2
		bra	arglp
gopt:		cmpi.b	#3,d1
		bhi	usage
		move.b	d1,crtmode
		bra	arglp
chkargretn:
		move.b	DIPSW0,(a0)+
		move.b	DIPSW1,(a0)+
		move.b	DIPSW2,(a0)+
		movem.l	(sp)+,SAVREGS
		rts

*------------------------------------------------------------------------
gethex:
		cmpi.b	#'0',d1
		bcs	5f
		cmpi.b	#'9',d1
		bhi	5f
		subi.b	#'0',d1
		bra	9f
5:		ori.b	#$20,d1
		cmpi.b	#'a',d1
		bcs	8f
		cmpi.b	#'f',d1
		bhi	8f
		subi.b	#'a'-10,d1
		bra	9f
8:		moveq.l	#-1,d1		*N=1
9:		rts

*------------------------------------------------------------------------
*	SALA.X のバージョンチェック
*------------------------------------------------------------------------
chkver:
		lea.l	-(53+1)(sp),sp	*SIZEofFILESBUF+1
		move.w	#$0020,-(sp)	*ARCHIVE
		pea.l	salafn(pc)
		pea.l	2+4(sp)
		DOS	__FILES
		lea.l	10(sp),sp
		tst.l	d0
		bmi	nfounderror

		move.l	$16(sp),d0	*FTIME
		cmpi.l	#$5f40113d,d0	*88-09-29 11:58:00
		beq	@f
				*88-09-21 16:56:00というバージョンも
				*手元にあります。かれこれ８年ほど前に
				*入手した不正コピーモノなので、
				*製品版でこのタイムスタンプを持つものが
				*存在するかどうかは不明です。
				*一応、隠し機能として対応してみましたが、
				*パッチが不完全かもしれません
		tst.b	extend
		beq	vererror
		addq.b	#1,version
		cmpi.l	#$87001135,d0	*88-09-21 16:56:00
		bne	vererror
@@:		lea.l	53+1(sp),sp
		rts

*------------------------------------------------------------------------
*	パッチその１
*	ワーク$f0000〜$fe000をメモリブロック末尾へスライド
*		in:	a0.l	沙羅曼蛇メモリ管理ブロック
*		out:	none
*		broken:	none
*		notice:	1:MPU キャッシュのフラッシュは行わない
*			2:ワークの範囲が有効かどうかはSALA.Xまかせ
*------------------------------------------------------------------------
patch1:
SAVREGS		reg	d0-d2/a0
		movem.l	SAVREGS,-(sp)

				*ワーク先頭を$10000の倍数に整合
		move.w	8(a0),d0	*pspMEMEND
		subq.w	#1,d0		*d0.l = ワークの上位ワード

		lea.l	256(a0),a0	*SIZEofPSP
		lea.l	patchtbl_a(pc),a1
		move.b	version(pc),d1
		beq	@f
		lea.l	patchtbl_b(pc),a1
@@:
		moveq.l	#0,d1
		moveq.l	#$0f,d2
		bra	5f
1:		add.l	d1,a0
		cmp.w	(a0),d2
		bne	vererror2
		move.w	d0,(a0)
5:		move.w	(a1)+,d1
		bne	1b
9:		movem.l	(sp)+,SAVREGS
		rts

*------------------------------------------------------------------------
*	パッチその２
*		in:	a0.l	沙羅曼蛇メモリ管理ブロック
*		out:	none
*		broken:	none
*		notice:	MPUキャッシュのフラッシュは行わない
*------------------------------------------------------------------------
patch2:
SAVREGS		reg	d0/a0-a2
		movem.l	SAVREGS,-(sp)
		lea.l	256(a0),a0	*SIZEofPSP
				*ディップスイッチ関連
		lea.l	dipsw(pc),a1

		clr.w	d0
		move.b	version(pc),d0
		add.w	d0,d0
		move.w	@f(pc,d0.w),d0
		jsr	@f(pc,d0.w)
		movem.l	(sp)+,SAVREGS
		rts
@@:		.dc.w	patch2_ver_a-@b
		.dc.w	patch2_ver_b-@b

patch2_ver_a:
		movea.l	a0,a2
		adda.l	#$0212d6,a2
		move.b	(a1)+,(a2)+	*
		move.b	(a1)+,(a2)+	*
		move.b	(a1)+,(a2)+	*}
		move.w	patch2dat1(pc),$00064a+4+4+2+4(a0)
					*DOS __FILES -> moveq.l #-1,d0
				*画面モード
		lea.l	patch2dat2_ver_a(pc),a1
		lea.l	$000350+2+4+4+2(a0),a2
		move.l	(a1)+,(a2)+	*4
		move.l	(a1)+,(a2)+	*4
		rts

patch2_ver_b:
		movea.l	a0,a2
		adda.l	#$0212f8,a2
		move.b	(a1)+,(a2)+	*
		move.b	(a1)+,(a2)+	*
		move.b	(a1)+,(a2)+	*}
		move.w	patch2dat1(pc),$00064a+4+4+2+4(a0)
					*DOS __FILES -> moveq.l #-1,d0
				*画面モード
		lea.l	patch2dat2_ver_b(pc),a1
		lea.l	$000350+2+4+4+2(a0),a2
		move.l	(a1)+,(a2)+	*4
		move.l	(a1)+,(a2)+	*4
		rts

*------------------------------------------------------------------------
patch2dat1:	moveq.l	#-1,d0		*2
patch2dat2_ver_a:
patch2dat2_ver_b:
		jsr	1f.l		*6
		bra.s	*+18		*2

1:		moveq.l	#0,d1
		move.b	crtmode(pc),d1
		add.w	d1,d1
		move.w	9f(pc,d1.w),d1
		rts
9:		.dc.w	$010a,$0109,$0108,$0107

*========================================================================
*	DOSコール$ff50〜$ff7fのベクタを$ff80〜$ffafへコピー
*		in:	none
*		out:	none
*		broken:	none
*========================================================================
initdosvec:
SAVREGS		reg	d0/a0-a1
		movem.l	SAVREGS,-(sp)
.if 0
		DOS	__VERNUM
		cmpi.w	#$020f,d0
		bcc	9f
.endif
		pea.l	0.w
		DOS	__SUPER
		move.l	d0,(sp)
		lea.l	$1800+$50*4.w,a0
		lea.l	$1800+$80*4.w,a1
		moveq.l	#(($1800+$80*4)-($1800+$50*4))/4-1,d0
@@:		move.l	(a0)+,(a1)+
		dbra	d0,@b
		tst.l	(sp)
		bmi	@f
		DOS	__SUPER
@@:		addq.l	#4,sp
9:		movem.l	(sp)+,SAVREGS
		rts

*------------------------------------------------------------------------
*	プロセスのメモリブロックを切り詰める
*------------------------------------------------------------------------
offmem:
SAVREGS		reg	d0/a0-a1
		movem.l	SAVREGS,-(sp)
		lea.l	16(a0),a0
		suba.l	a0,a1
		pea.l	(a1)
		pea.l	(a0)
		DOS	__SETBLOCK
		addq.l	#8,sp
		movem.l	(sp)+,SAVREGS
		rts

*------------------------------------------------------------------------
*	MPUキャッシュのフラッシュ
*		in:	none
*		out:	none
*		broken:	none
*------------------------------------------------------------------------
flushcache:
SAVREGS		reg	d0/d1
		movem.l	SAVREGS,-(sp)
		moveq.l	#1,d0
		.cpu	68020
		and.b	*-3(pc,d0.w*2),d0
		.cpu	68000
		beq	@f
		moveq.l	#3,d1		*flush
		moveq.l	#$ac,d0		*SYS_STAT
		trap	#15
@@:		movem.l	(sp)+,SAVREGS
		rts

*------------------------------------------------------------------------
*	スプリアス割り込みを殺す
*		in:	none
*		out:	none
*		broken:	none
*------------------------------------------------------------------------
setspint:
.ifdef SAVE_SPURIOUS
		pea.l	vectwork(pc)
		pea.l	chvecttbl(pc)
		bsr	setvects
		addq.l	#8,sp
		rts
.else	*SAVE_SPURIOUS
SAVREGS		reg	d0-d1/a0-a1
		movem.l	SAVREGS,-(sp)
		lea.l	$18*4.w,a1
		IOCS	__B_LPEEK
		movea.l	d0,a1
		IOCS	__B_WPEEK
		cmpi.w	#$4e73,d0
		beq	9f		*すでに殺されていた
		lea.l	$ff0000,a1
@@:		IOCS	__B_WPEEK	*ROMからrteを探す
		cmpi.w	#$4e73,d0	*
		bne	@b		*}
		subq.l	#2,a1
		move.l	a1,d1		*ベクタアドレス設定
		lea.l	$18*4.w,a1	*
		IOCS	__B_LPOKE	*}
9:		movem.l	(sp)+,SAVREGS
		rts
.endif	*SAVE_SPURIOUS

*------------------------------------------------------------------------
*	スプリアス割り込みの復帰
*		in:	none
*		out:	none
*		broken:	none
*------------------------------------------------------------------------
.ifdef SAVE_SPURIOUS
resetspint:
		pea.l	vectwork(pc)
		pea.l	chvecttbl(pc)
		bsr	resetvects
		addq.l	#8,sp
		rts
*------------------------------------------------------------------------
onlyrte:	rte
*------------------------------------------------------------------------
VECT		.macro	no,addr
		.dc.w	no
.if no.ne.0
		.dc.l	addr
.endif
		.endm
*------------------------------------------------------------------------
chvecttbl:
		VECT	$0018,onlyrte	*スプリアス割り込み
		VECT	0,0

*------------------------------------------------------------------------
*	割り込みベクタの書き換え
*		in:	(sp).l	テーブル
*			4(sp).l	ベクタセーブワーク
*		out:	none
*		broken:	none
*		notice:	テーブルの形式は以下の通り
*				.dc.w	vectno
*				.dc.l	addr
*				.dc.w	vectno
*					:
*				.dc.w	0
*------------------------------------------------------------------------
setvects:
SAVREGS		reg	d0/a0-a1
SAVSIZ		=	(1+2)*4
		movem.l	SAVREGS,-(sp)
		movem.l	SAVSIZ+4(sp),a0-a1
		bra	5f
1:		move.l	(a0)+,-(sp)
		move.w	d0,-(sp)
		DOS	__INTVCG
		move.l	d0,(a1)+
		DOS	__INTVCS
		addq.l	#6,sp
5:		move.w	(a0)+,d0
		bne	1b
		movem.l	(sp)+,SAVREGS
		rts

*------------------------------------------------------------------------
*	setvectsで書き換えた割り込みベクタの復帰
*		in:	(sp).l	テーブル
*			4(sp).l	ベクタセーブワーク
*		out:	none
*		broken:	none
*------------------------------------------------------------------------
resetvects:
SAVREGS		reg	d0/a0-a1
SAVSIZ		=	(1+2)*4
		movem.l	SAVREGS,-(sp)
		movem.l	SAVSIZ+4(sp),a0-a1
		bra	5f
1:		move.l	(a1)+,d1
		beq	9f		*書き換え中に中断されたらしい
		move.l	d1,-(sp)
		move.w	d0,-(sp)
		DOS	__INTVCS
		addq.l	#6,sp
		addq.l	#4,a0
5:		move.w	(a0)+,d0
		bne	1b
9:		movem.l	(sp)+,SAVREGS
		rts
.endif	*SAVE_SPURIOUS
*------------------------------------------------------------------------
puttitle:
		pea.l	title(pc)
		bra	tostdout
tostdout:
		DOS	__PRINT
		addq.l	#4,sp
		rts

*------------------------------------------------------------------------
PATTBL		.macro	ofs
.if ofs.ne.0
_TMP2		=	ofs-1-64	*SIZEofXHEADER
		.dc.w	_TMP2-_TMP
_TMP		=	_TMP2
.else
		.dc.w	0
.endif
		.endm
*------------------------------------------------------------------------
patchtbl_a:
_TMP	=	0
		.include	pattbl_a.inc
		PATTBL	0

*------------------------------------------------------------------------
patchtbl_b:
_TMP	=	0
		.include	pattbl_b.inc
		PATTBL	0

*------------------------------------------------------------------------
dipsw:		.dc.b	%0000_0000,%1010_1101,%1000_0000
salafn:		.dc.b	'SALA.X',0
title:		.dc.b	'DINAMIC-PATCHER for 沙羅曼蛇 v1.01 Copyright 1998 Igarashi'
		.dc.b	$0d,$0a,0
usgmes:		.dc.b	'usage:	bootsala [option]',$0d,$0a
		.dc.b	'	-c<0-f>	クレジット設定',$0d,$0a
		.dc.b	'	-t<0-1>	サウンドタイプ設定',$0d,$0a
		.dc.b	'	-p<0-3>	残機数設定',$0d,$0a
		.dc.b	'	-l<0-1>	コイン投入口設定',$0d,$0a
		.dc.b	'	-x<0-3>	最大クレジット設定',$0d,$0a
		.dc.b	'	-d<0-3>	難易度設定',$0d,$0a
		.dc.b	'	-s<0-1>	デモサウンド設定',$0d,$0a
		.dc.b	'	-o<0-1>	モニタ選択',$0d,$0a
		.dc.b	'	-m<0-1>	テストモード選択',$0d,$0a
		.dc.b	'	-g<0-3>	画面モード設定',$0d,$0a
*		.dc.b	'	-v	謎のバージョンへの対応',$0d,$0a
		.dc.b	'デフォルトは '
		.dc.b	'-c0 -s0 -p1 -l1 -x1 -d1 -e0 -o0 -m1 -g0'
		.dc.b	' です',$0d,$0a,0
nfoundmes:	.dc.b	'bootsala.x: SALA.Xが見つかりません',$0d,$0a,0
vererrmes:	.dc.b	'bootsala.x: SALA.Xのバージョンが違います',$0d,$0a,0
vererrmes2:	.dc.b	'bootsala.x: SALA.Xのバージョンが違うようです',$0d,$0a,0
loaderrmes:	.dc.b	'bootsala.x: SALA.Xの起動に失敗しました',$0d,$0a,0
execerrmes:	.dc.b	'bootsala.x: SALA.X実行中にエラーが発生しました',$0d,$0a,0

*========================================================================
		.bss
		.even
vectwork:	.ds.l	1
crtmode:	.ds.b	1
version:	.ds.b	1
extend:		.ds.b	1
mfpbuf:		.ds.b	1

*========================================================================
		.stack
		.even

		.ds.l	256/4
inisp:

*========================================================================
		.end	entry



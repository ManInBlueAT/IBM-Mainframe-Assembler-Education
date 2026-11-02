/***********************************************************************
* The Towers of Hanoi
* https://en.wikipedia.org/wiki/Tower_of_Hanoi
***********************************************************************/

/* initialize screen */
Address "TSO" "CLS"
Call IMPORT FSSAPI
Address FSS
Call FSSINIT
maxlines=FSSHeight()

/* handle input parameters */
If maxlines=24 Then
  maxsclices=8
Else
  maxslices=11
Parse Arg slices . '(' timeout .
If DATATYPE(slices)<>'NUM' Then slices=4
Else If slices<=0 Then slices=0
Else If slices>maxslices Then slices=maxslices
If DATATYPE(timeout)<>'NUM' Then timeout=1000
Else If timeout<=0 Then timeout=1
Else If timeout>3000 Then timeout=3000

/* set color codes for 7 colors */
cc.1=#PROT+#BLUE+#REVERSE
cc.2=#PROT+#RED+#REVERSE
cc.3=#PROT+#PINK+#REVERSE
cc.4=#PROT+#GREEN+#REVERSE
cc.5=#PROT+#TURQ+#REVERSE
cc.6=#PROT+#YELLOW+#REVERSE
cc.7=#PROT+#WHITE+#REVERSE
/* other attribute settings */
cc.21=#PROT+#GREEN
cc.22=#PROT+#HI
cc.23=#PROT+#REVERSE+#HI

/* display headline */
Call FSSTEXT 'The Towers of Hanoi',2,31,,cc.22
/* display stack numbers */
li=maxlines-3
Call FSSTEXT '1',li,15,,cc.22
Call FSSTEXT '2',li,40,,cc.22
Call FSSTEXT '3',li,65,,cc.22

/* display source stack */
maxspace=maxslices*2+1
Do i=1 By 1 To slices
  ix=INT((i-1)//7+1)
  li=maxlines-4-slices*2-2+2*i
  len=maxspace-(maxslices-i)*2
  slicepos=INT(14-(len-1)/2)
  /*
  Call FSSTEXT COPIES(' ',len),li,slicepos,,cc.ix
  Call FSSTEXT COPIES(' ',len),li+1,slicepos,,cc.ix
  */
  padlen=INT((maxspace-len)/2)
  If i<10 Then
    lenleft=i
  Else
    lenleft=i-1
  slicestr=COPIES('*',lenleft)||i||COPIES('*',i)
  stringi=COPIES(' ',padlen)||slicestr||COPIES(' ',padlen)
  Call FSSTEXT stringi,li,4,,cc.ix
  Call FSSTEXT stringi,li+1,4,,cc.ix
  End

Call FSSTEXT 'Press ENTER or any PF key to interrupt...', ,
  maxlines,1,60,cc.22
inittimeout=MAX(timeout,2000)
"REFRESH" inittimeout /* initial display incl. clear screen */
Call HandleFSSKey

/* remember stack data */
s.0=slices
s.1=0
s.2=0
count=0

/* move slices */
Call Hanoi slices 0 1

/* end processing */
Call FSSINIT
Call FSSTEXT 'Press ENTER or any PF key to quit', ,
  maxlines,1,60,cc.22
CALL FSSMESSAGE maxlines-1
Call FSSZERRLM slices 'slices moved in' count 'steps',
  'from stack 1 to 2 using auxiliary stack 3'
event=FSSRefresh() /* refresh and wait */
Call ExitProc
Exit 0

/*----------------------------------------------------------------------
* Recursively move slices
*---------------------------------------------------------------------*/
Hanoi: Procedure Expose count cc. maxslices s. maxlines timeout
  Parse Arg n a b
  help=3-a-b
  If n>1 Then Call Hanoi n-1 a help
  count=count+1
  Call MoveSlice
  If n>1 Then Call Hanoi n-1 help b
  Return

/*----------------------------------------------------------------------
* Do a specific move graphically
*---------------------------------------------------------------------*/
MoveSlice:
  Call FSSINIT
  maxspace=maxslices*2+1
  ix=INT((n-1)//7+1)
  len=maxspace-(maxslices-n)*2
  lia=maxlines-4-s.a*2
  posa=4+25*a
  sliceposa=INT(14+25*a-(len-1)/2)
  lib=maxlines-4-s.b*2-2
  posb=4+25*b
  sliceposb=INT(14+25*b-(len-1)/2)
  padlen=INT((maxspace-len)/2)
  If n<10 Then
    lenleft=n
  Else
    lenleft=n-1
  slicestr=COPIES('*',lenleft)||n||COPIES('*',n)
  stringb=COPIES(' ',padlen)||slicestr||COPIES(' ',padlen)
  /*
  If n=1 & a=0 & s.a=2 & b=2 & s.b=0 Then
  Say 'ix' ix 'lia' lia 'posa' posa 'lib' lib 'posb' posb 'len' len,
    'sliceposb' sliceposb 'maxspace' maxspace 'cc.21' cc.21,
    'cc.ix' cc.ix 'a' a 'b' b 'help' help 's.a' s.a 's.b' s.b,
    's.help' s.help 'maxlines' maxlines 'slices' slices 'n' n
  */
  /*
  Call FSSTEXT COPIES(' ',len),lia,sliceposa,,cc.21
  Call FSSTEXT COPIES(' ',len),lia+1,sliceposa,,cc.21
  Call FSSTEXT COPIES(' ',len),lib,sliceposb,,cc.ix
  Call FSSTEXT COPIES(' ',len),lib+1,sliceposb,,cc.ix
  */
  Call FSSTEXT COPIES(' ',maxspace),lia,posa,,cc.21
  Call FSSTEXT COPIES(' ',maxspace),lia+1,posa,,cc.21
  Call FSSTEXT stringb,lib,posb,,cc.ix
  Call FSSTEXT stringb,lib+1,posb,,cc.ix
  s.a=s.a-1
  s.b=s.b+1

  stpos=14
  Call FSSTEXT 'Step',4,stpos,,cc.21
  Call FSSTEXT FORMAT(count,4)||':',4,stpos+5,,cc.22
  Call FSSTEXT 'Moving slice',4,stpos+11,,cc.21
  Call FSSTEXT FORMAT(n,2),4,stpos+24,,cc.ix
  Call FSSTEXT 'from stack',4,stpos+27,,cc.21
  Call FSSTEXT FORMAT(a+1,1),4,stpos+38,,cc.22
  Call FSSTEXT 'to stack',4,stpos+40,,cc.21
  Call FSSTEXT FORMAT(b+1,1),4,stpos+49,,cc.22

  Call FSSTEXT 'Press ENTER or any PF key to interrupt...', ,
    maxlines,1,60,cc.22
  "REFRESH" timeout      /* '0' refresh only changed parts */
  Call HandleFSSKey
  Return

/*----------------------------------------------------------------------
* Handle keyboard interrupt
*---------------------------------------------------------------------*/
HandleFSSKey:
  event=FSSKey()     /* 4711 if timeout */
  If event=4711 Then Return
  Call FSSTEXT 'Press PF3 to quit or ENTER or',
    'any other PF key to continue',maxlines,1,60,cc.22
  CALL FSSMESSAGE maxlines-1
  Call FSSZERRLM 'Do you want to quit?',maxlines-1,1,72,cc.22
  event=FSSREFRESH() /* refresh and wait */
  If event=#PFK03 Then Call ExitProc
  Call FSSZERRLM COPIES(' ',72)
  Return

/*----------------------------------------------------------------------
* Exit procedure
*---------------------------------------------------------------------*/
ExitProc:
  Call FSSCLOSE
  Exit 0


//HANOIASM JOB (MBA),                                                   00000122
//             'Hanoi ASM',                                             00000201
//             CLASS=A,                                                 00000300
//             MSGCLASS=A,                                              00000400
//             NOTIFY=HERC01,                                           00000501
//             TIME=1440,                                               00000600
//             MSGLEVEL=(1,1)                                           00000700
//********************************************************************* 00000801
//* Name: HERC01.MYSTUFF.JCL(HANOIASM)                                  00000901
//*                                                                     00001001
//* Description: Towers of Hanoi. Please refer to                       00001121
//*   https://en.wikipedia.org/wiki/Tower_of_Hanoi                      00001221
//*   The job contains the section HANOIASM as entry point (main        00001321
//*   program) and two variants of handling the movement of the         00001421
//*   slices: a recursive one (section HANOIREC) and an iterative one   00001521
//*   (section HANOIITR). The sections are assembled, linked and        00001621
//*   executed                                                          00001721
//* Input: Number of slices slices (1<=slices<=20), source stack from   00001821
//*   (0<=from<=2), destination stack to (0<=to<=2) (from<>to) are      00001921
//*   entered in //GO.HANOIIN DD                                        00002021
//* Output: Print output to //GO.HANOIOUT DD that shows the steps with  00002121
//*   information on which slice is moved from/to which stack           00002221
//********************************************************************* 00002301
//*                                                                     00002400
//*-------------------------------------------------------------------- 00002501
//HANOIREC EXEC ASMFC,PARM.ASM=(LOAD,NODECK),MAC1='SYS2.MACLIB'         00002601
//ASM.SYSGO DD DSNAME=&&OBJSET,UNIT=SYSSQ,                             X00002701
//             SPACE=(80,(200,50)),                                    X00002801
//             DISP=(MOD,PASS)                                          00002901
//ASM.SYSIN DD *                                                        00003001
*********************************************************************** 00003101
* ///////////////////////////////////////////////////////////////////// 00003201
* Title: HANOIREC - process steps recursively and  print slice movement 00003301
*   lines                                                               00003421
* Author: ManInBlueAT                                                   00003501
* Language: ASM                                                         00003601
*                                                                       00003701
* Description: Recursive function HANOIREC processes the following      00003821
*   sequence of steps: Move the uppper n-1 slices from the source       00003921
*   (from) to the auxiliary stack (aux), move the lowest slice (n)      00004021
*   from the source to the destination stack (to) and move the upper    00004121
*   n-1 slices from the aux to the destination stack. Apply this        00004221
*   algorithm to all levels n recursively what results in 2**n-1 steps. 00004321
*                                                                       00004401
* Changes:                                                              00004501
* - ManInBlueAT, 2026-10-09 New module                                  00004601
* ///////////////////////////////////////////////////////////////////// 00004701
         PRINT GEN                                                      00004801
         REGISTER                                                       00004901
HANOIREC CSECT                                                          00005001
         SAVE  (14,12)                                                  00005101
         BALR  R12,0                                                    00005201
         USING *,R12                                                    00005301
         LR    R2,R1               remember address of paramter list    00005421
* allocate instance data                                                00005501
         LA    R0,INSTL            length of area to be allocated       00005621
         GETMAIN R,LV=(0)          allocate area with length R0         00005701
         LR    R11,R1              address of allocated storage in R1   00005821
         USING INSTANCE,R11        SAVEAREA is at the start of INSTANCE 00005921
         LA    R3,SAVEAREA                                              00006001
         ST    R3,8(,R13)                                               00006101
         ST    R13,SAVEAREA+4                                           00006201
         LR    R13,R3                                                   00006301
*--- handle parameters                                                  00006421
*        WTO   'HANOIREC... start HANOIREC'                             00006501
         L     R3,0(,R2)           reference address list               00006601
         L     R4,0(,R3)           reference 1st address (HANOIOUT)     00006701
         ST    R4,HANOIOUT         store address in HANOIOUT            00006801
         L     R4,4(,R3)           reference 2nd address                00006901
         ZAP   SLICE(2),0(2,R4)                                         00007001
         L     R4,8(,R3)           reference 3nd address                00007101
         ZAP   FROM(1),0(1,R4)                                          00007201
         L     R4,12(,R3)          reference 4th address                00007301
         ZAP   TO(1),0(1,R4)                                            00007401
         L     R4,16(,R3)          reference 5th address                00007501
         ZAP   AUX(1),0(1,R4)                                           00007601
         L     R4,20(,R3)          reference 6th address                00007701
         ZAP   STEPS(4),0(4,R4)                                         00007801
* remember current slice value and current stack values as received     00007901
         ZAP   CSLICE,SLICE                                             00008001
         ZAP   CFROM,FROM                                               00008101
         ZAP   CTO,TO                                                   00008201
         ZAP   CAUX,AUX                                                 00008301
* check if slice is not greater 1 - no recursive calls                  00008401
         CP    CSLICE,=P'1'                                             00008501
         BNP   DOSTEP              <=1 or overflow BC X'0C'             00008601
* slice>1 --> call HANOIREC recursively two times with slice-1          00008701
* put together argument values for 1st recursive call                   00008801
* HANOIREC(SLICE-1,FROM,AUX,TO,STEPS)                                   00008901
* set addresses of parameters                                           00009001
         L     R4,HANOIOUT                                              00009101
         ST    R4,AHANOUT                                               00009201
         LA    R4,SLICE                                                 00009301
         ST    R4,ASLICE                                                00009401
         LA    R4,FROM                                                  00009501
         ST    R4,AFROM                                                 00009601
         LA    R4,TO                                                    00009701
         ST    R4,ATO                                                   00009801
         LA    R4,AUX                                                   00009901
         ST    R4,AAUX                                                  00010001
         LA    R4,STEPS                                                 00010101
         ST    R4,ASTEPS                                                00010201
* set slice and stack values in instance area                           00010301
         SP    SLICE,=P'1'         decrement slice                      00010401
*        ZAP   FROM,CFROM          no change                            00010501
         ZAP   TO,CAUX                                                  00010601
         ZAP   AUX,CTO                                                  00010701
* call HANOIREC recursively - 1st call                                  00010801
         CALL  HANOIREC,(ALIST)                                         00010901
* recover received slice and stack values from instance area            00011001
* as Cxxxxx values are no longer valid                                  00011101
         ZAP   CSLICE,SLICE                                             00011201
         AP    CSLICE,=P'1'        increment slice (current level)      00011321
         ZAP   CFROM,FROM                                               00011401
         ZAP   CAUX,TO                                                  00011501
         ZAP   CTO,AUX                                                  00011601
* do the step                                                           00011701
         B     DOSTEP                                                   00011801
DO2ND    EQU   *                                                        00011901
* set stack valaues for recursive call 2                                00012001
* HANOIREC(SLICE-1,AUX,TO,FROM,STEPS)                                   00012101
* set addresses of parameters                                           00012201
         L     R4,HANOIOUT                                              00012301
         ST    R4,AHANOUT                                               00012401
         LA    R4,SLICE                                                 00012521
         ST    R4,ASLICE                                                00012601
         LA    R4,FROM                                                  00012701
         ST    R4,AFROM                                                 00012801
         LA    R4,TO                                                    00012901
         ST    R4,ATO                                                   00013001
         LA    R4,AUX                                                   00013101
         ST    R4,AAUX                                                  00013201
         LA    R4,STEPS                                                 00013301
         ST    R4,ASTEPS                                                00013401
* set slice and stack values in instance area                           00013501
*        ZAP   SLICE,CSLICE        no change                            00013601
*        SP    SLICE,=P'1'         no change, already decremented       00013721
         ZAP   FROM,CAUX                                                00013801
         ZAP   TO,CTO                                                   00013901
         ZAP   AUX,CFROM                                                00014001
* call HANOILN recursively - 2nd call                                   00014101
         CALL  HANOIREC,(ALIST)                                         00014201
* go to end of segment                                                  00014301
         B     PROCEND             end of segment                       00014401
*---                                                                    00014501
* Perform the step of moving a slice. The counter steps is increased,   00014621
* current slice cslice is moved from the current source stack cfrom     00014701
* to the current destination stack cto                                  00014801
DOSTEP   EQU   *                                                        00014901
         AP    STEPS,=P'1'         increment steps                      00015021
* prepare step line record                                              00015101
         MVC   TRGTSTPS,TMPSTPS                                         00015201
         ED    TRGTSTPS,STEPS                                           00015301
         MVC   OSTEP,TRGTSTPS+1                                         00015401
         MVC   TRGTSLC,TMPSLC                                           00015501
         ED    TRGTSLC,CSLICE                                           00015601
         MVC   OSLICE,TRGTSLC+2                                         00015701
         MVC   TRGTSTK,TMPSTK                                           00015801
         ED    TRGTSTK,CFROM                                            00015901
         MVC   OFROM,TRGTSTK+1                                          00016001
         MVC   TRGTSTK,TMPSTK                                           00016101
         ED    TRGTSTK,CTO                                              00016201
         MVC   OTO,TRGTSTK+1                                            00016301
         L     R4,HANOIOUT         load address of HANOIOUT DCB         00016401
         PUT   (R4),OREC           write step line                      00016501
* do 2nd recursive call after step if current slice number>1            00016601
         CP    CSLICE,=P'1'                                             00016701
         BP    DO2ND               >1 BC X'02'                          00016801
* end of segment processing                                             00016901
PROCEND  EQU   *                                                        00017021
* return to caller actions                                              00017101
         L     R13,SAVEAREA+4                                           00017201
* return current number of steps in caller INSTANCE structure           00017301
         ZAP   STEPSPOS(4,R13),STEPS(4)                                 00017403
* free current INSTANCE area                                            00017501
         LA    R1,INSTANCE                                              00017601
         LA    R0,INSTL            length of allocated area             00017705
         FREEMAIN R,LV=(0),A=(1)   free area R1 with length R0          00017801
*        WTO   'HANOIREC... end HANOIREC'                               00017905
         RETURN (14,12),RC=0                                            00018001
*--- data definitions                                                   00018101
* list of parameters (for recursive call of HANOIREC)                   00018201
ALIST    DS    0A                                                       00018301
AHANOUT  DS    A                                                        00018401
ASLICE   DS    A                                                        00018501
AFROM    DS    A                                                        00018601
ATO      DS    A                                                        00018701
AAUX     DS    A                                                        00018801
ASTEPS   DS    A                                                        00018901
* remember current slice and stack values as received                   00019001
CSLICE   DS    PL2                 slice value                          00019101
CFROM    DS    PL1                 from value                           00019201
CTO      DS    PL1                 to value                             00019301
CAUX     DS    PL1                 auxiliary value                      00019401
* savearea and parameters (and local data of the instance, if any)      00019501
* to be allocated before recursive calls                                00019621
INSTANCE DSECT                                                          00019701
SAVEAREA DS    18F                                                      00019801
HANOIOUT DS    A(4)                address of output file DCB           00019901
SLICE    DS    PL2                                                      00020001
FROM     DS    PL1                                                      00020101
TO       DS    PL1                                                      00020201
AUX      DS    PL1                                                      00020301
STEPS    DS    PL4                                                      00020401
         DC    CL3'   '            alignment                            00020521
INSTL    EQU   *-INSTANCE                                               00020601
STEPSPOS EQU   STEPS-INSTANCE                                           00020701
* end DSECT, continue CSECT                                             00020801
HANOIREC CSECT                                                          00020901
* output line definition for step                                       00021001
OREC     DS    0CL133                                                   00021101
         DC    CL1' '              ASO character                        00021201
         DC    CL5'Step '                                               00021301
OSTEP    DS    CL7                 current step number                  00021401
         DC    CL15': Moving slice '                                    00021501
OSLICE   DS    CL2                 current slice                        00021601
         DC    CL12' from stack '                                       00021701
OFROM    DS    CL1                 from stack                           00021801
         DC    CL4' to '                                                00021901
OTO      DS    CL1                 to stack                             00022001
         DC    CL85' '                                                  00022101
* templates and target fields for print preparation                     00022201
TRGTSLC  DS    CL4                                                      00022301
TMPSLC   DC    X'40202120'                                              00022419
TRGTSTK  DS    CL2                                                      00022501
TMPSTK   DC    X'4020'                                                  00022619
TRGTSTPS DS    CL8                                                      00022701
TMPSTPS  DC    X'4020202020202120'                                      00022819
*--- literals, if any, will go here                                     00022901
         LTORG *                                                        00023001
*--- end of section                                                     00023101
         END   HANOIREC                                                 00023201
/*                                                                      00023301
//*-------------------------------------------------------------------- 00023401
//HANOIITR EXEC ASMFC,PARM.ASM=(LOAD,NODECK),MAC1='SYS2.MACLIB'         00023501
//ASM.SYSGO DD DSNAME=&&OBJSET,UNIT=SYSSQ,                             X00023601
//             SPACE=(80,(200,50)),                                    X00023701
//             DISP=(MOD,PASS)                                          00023801
//ASM.SYSIN DD *                                                        00023901
*********************************************************************** 00024001
* ///////////////////////////////////////////////////////////////////// 00024101
* Title: HANOIITR - process steps iteratively and  print slice movement 00024201
*        lines                                                          00024301
* Author: ManInBlueAT                                                   00024401
* Language: ASM                                                         00024501
*                                                                       00024601
* Description: Iterative function HANOIITR to process the 2**n-1        00024721
*   steps. There are sequences of three categories of movement starting 00024821
*   with from stack to to stack or auxiliary stack depending on an odd  00024921
*   or even number of slices. The direction of any movement is          00025021
*   dependent on the sizes of the top slices of the involved from and   00025121
*   to stacks.                                                          00025221
*                                                                       00025321
* Changes:                                                              00025401
* - ManInBlueAT, 2026-10-09 New module                                  00025501
* ///////////////////////////////////////////////////////////////////// 00025601
         MACRO                                                          00025719
&NAME    SWAPF &FIXED41,&FIXED42   swap binary fixed 4 bytes values 1,2 00025819
         XC    &FIXED41,&FIXED42                                        00025919
         XC    &FIXED42,&FIXED41                                        00026019
         XC    &FIXED41,&FIXED42                                        00026119
         MEND                                                           00026219
*---------------------------------------------------------------------- 00026319
         PRINT GEN                                                      00026401
         REGISTER                                                       00026501
HANOIITR CSECT                                                          00026601
         SAVE  (14,12)                                                  00026701
         BALR  R12,0                                                    00026801
         USING *,R12                                                    00026901
         LR    R2,R1               remember address to paramter list    00027001
         LA    R3,SAVEAREA                                              00027101
         ST    R3,8(,R13)                                               00027201
         ST    R13,SAVEAREA+4                                           00027301
         LR    R13,R3                                                   00027401
*--- handle parameters                                                  00027501
         WTO   'HANOIITR... start HANOIITR'                             00027602
         L     R3,0(,R2)           reference address list               00027701
         L     R4,0(,R3)           reference 1st address (HANOIOUT)     00027801
         ST    R4,HANOIOUT         store address in HANOIOUT            00027901
         L     R4,4(,R3)           reference 2nd address                00028001
         ZAP   SLICES(2),0(2,R4)                                        00028104
         L     R4,8(,R3)           reference 3nd address                00028201
         ZAP   FROM(1),0(1,R4)                                          00028301
         L     R4,12(,R3)          reference 4th address                00028401
         ZAP   TO(1),0(1,R4)                                            00028501
         L     R4,16(,R3)          reference 5th address                00028601
         ZAP   AUX(1),0(1,R4)      (initialized by caller)              00028705
         L     R4,20(,R3)          reference 6th address                00028801
         ZAP   STEPS(4),0(4,R4)    (initialized by caller to 0)         00028919
         ST    R4,ASTEPS           remember address of i/o parm steps   00029003
* convert slices parm to binary - value aligned, convert, store binary  00029121
         ZAP   TPALIGN,SLICES                                           00029210
         CVB   R3,TPALIGN                                               00029310
         ST    R3,BSLICES                                               00029410
*--- allocate dynamic stack data                                        00029521
* get length area to be allocated: STKDYNL*3*(SLICES+1)                 00029621
         L     R3,BSLICES          no of slices                         00029711
         A     R3,=F'1'            no of slices+1                       00029811
         LA    R4,STKDYNL          dynamic stack element (slice)        00029917
         MR    R2,R4               dynamic slices storage per stack     00030017
         ST    R3,STKSLCS1         store binary storage length slices+1 00030111
         M     R2,=F'3'            storage for dynamic part 3 stacks    00030211
         ST    R3,STKALLOC         remember length of allocated storage 00030311
         GETMAIN R,LV=(3)          allocate area with length R3         00030411
         LR    R11,R1              R11 points to the allocated area     00030511
         USING STKDYN,R11          using R11 area for dynamic stk data  00030611
*--- initialize STK (stack) structure                                   00030720
* Internally we always move slices from from stack 1 to to stack 2      00030807
* with auxiliary stack aux 3 if slices is odd and from from stack 1     00030907
* to to stack 3 with aux stack 2 if slices is even. We assign the       00031007
* stack names given as parameters as display names accordingly.         00031121
* As the index orgin in AL is 0 the array indices of the STK data       00031207
* is 0 to 2 (so we use stack 0,1,2)                                     00031320
         ZAP   STKDSPNO,FROM       display from stack to STK 0          00031407
         L     R5,BSLICES                                               00031517
         N     R5,=F'1'            check if no of slices is odd         00031617
         BZ    CONTEVEN            go to even if bit not set on pos 1   00031707
         ZAP   STKDSPNO+STKDSPNL,TO    display to stack to STK 1        00031807
         ZAP   STKDSPNO+2*STKDSPNL,AUX display aux stack to STK 2       00031907
         B     CONTINIT                                                 00032007
CONTEVEN EQU   *                                                        00032107
         ZAP   STKDSPNO+STKDSPNL,AUX  display aux stack to STK 1        00032207
         ZAP   STKDSPNO+2*STKDSPNL,TO display to stack to STK 2         00032307
CONTINIT EQU   *                                                        00032407
* For every stack, maintain the count of slices and track the slices    00032507
* by their position numbers (sizes) on the stack. Initially, all slices 00032621
* are on stack 0.                                                       00032721
         MVC   STKCOUNT(4),BSLICES STK 0 count starts with all slices   00032819
         MVC   (STKCOUNT+STKCOUNL)(4),=X'00000000' STK 1 count set to 0 00032915
         MVC   (STKCOUNT+2*STKCOUNL)(4),=X'00000000' STK 2 count set 0  00033015
* The slices are maintained in STKSLICE array per stack. The indices    00033108
* used are 1 to slices. The slice with index 0 (no real slice) is set   00033221
* to a value (99) higher than any specified input value for slices.     00033321
* So, every slice number (representing the "size" of the slice) on a    00033421
* stack will always be smaller. In any situation the smallest slice     00033521
* (least size number) has the top position (highest slice index on the  00033621
* stack, >=1)                                                           00033721
         LA    R2,99               slice imaginary high (size) value    00033821
         ST    R2,STKSLICE         set value to STKSLICE element 0      00033911
         L     R3,STKSLCS1         dynamic storage slices per stack     00034012
         ST    R2,STKSLICE(R3)     set value to stack 1 element 0       00034112
         A     R3,STKSLCS1         dynamic storage slices per stack     00034221
         ST    R2,STKSLICE(R3)     set value to stack 2 element 0       00034312
* initialize slices 1 to BSLICES for every stack                        00034411
         L     R2,BSLICES          initial i                            00034512
         L     R3,=F'1'            initial value for slices-i+1         00034612
         LR    R5,R2               i                                    00034712
         LA    R6,STKDYNL          dynamic stack element (slice)        00034817
         MR    R4,R6               STKDYNL*i initial displacement       00034917
         LA    R4,0                R4 (was and) is 0                    00035019
SLCINIT  C     R2,=X'00000001'                                          00035120
         BL    ENDINIT                                                  00035218
* slice(0,i)=slices-i+1 --> the nearer the ground the larger the slice  00035312
         ST    R3,STKSLICE(R5)     slices-i+1 to stk 0 offset i         00035412
* initialize element slices-i+1 for stack 1,2 with 0 as these stacks    00035512
* are empty at begin                                                    00035612
         LA    R6,STKSLICE         basis for elements stack 1 and 2     00035712
         AR    R6,R5               + displacement current slice element 00035821
         A     R6,STKSLCS1         move to position stack 1             00035912
         ST    R4,0(R6)            initialize stk 1 element with 0      00036012
         A     R6,STKSLCS1         move to position stack 2             00036112
         ST    R4,0(R6)            initialize with 0                    00036212
* prepare next iteration                                                00036312
         S     R2,=F'1'            i=i-1                                00036412
         A     R3,=F'1'            next larger slice                    00036512
         LA    R6,STKDYNL                                               00036617
         SR    R5,R6               stack 0, next lower position         00036717
         B     SLCINIT                                                  00036812
ENDINIT  EQU   *                                                        00036918
* perform 2**slices-1 steps to move the slices                          00037013
         LA    R2,1                                                     00037113
         L     R3,BSLICES                                               00037213
         SLA   R2,0(R3)            R2 is now 2**slices                  00037318
         LA    R3,1                current step initialized with 1      00037421
         ST    R3,R3HELP           R3HELP shadows R3                    00037521
* --- perform the steps loop                                            00037621
* Do series of three different moves until done: 0 to 1 or 0 to 2       00037713
* or 1 to 2 or vice versa (category 1, 2, 0)                            00037813
* category = residue class 0,1,2 of step modulo 3 starting with 1       00037921
         LA    R4,1                start with move category R4 1        00038014
STPLOOP  C     R2,R3HELP                                                00038114
         BNH   STPLPEND            R3HELP is 2**slices --> stop         00038219
MOVEC1   C     R4,=X'00000001'     category 1 move: 0-1 or vice versa   00038320
         BNE   MOVEC2                                                   00038413
         MVC   BFROM(4),=X'00000000' from stack 0                       00038518
         MVC   BTO(4),=X'00000001' to stack 1                           00038618
         LA    R4,2                next move is category R4 2           00038714
         B     STPLPCNT                                                 00038814
MOVEC2   C     R4,=X'00000002'     category 2 move: 0-2 or vice versa   00038920
         BNE   MOVEC0                                                   00039013
         MVC   BFROM(4),=X'00000000' from stack 0                       00039118
         MVC   BTO(4),=X'00000002' to stack 2                           00039218
         LA    R4,0                next move is category R4 0           00039314
         B     STPLPCNT                                                 00039414
MOVEC0   EQU   *                   category 0 move: 1-2 or vice versa   00039513
         MVC   BFROM(4),=X'00000001' from stack 1                       00039618
         MVC   BTO(4),=X'00000002' to stack 2                           00039718
         LA    R4,1                next move is category 1              00039813
STPLPCNT EQU   *                                                        00039914
         B     DOMOVE                                                   00040014
*                                                                       00040119
STPLPNXT EQU   *                                                        00040214
         A     R3,=F'1'            increment steps                      00040319
         ST    R3,R3HELP                                                00040413
         B     STPLOOP                                                  00040514
*                                                                       00040614
DOMOVE   EQU   *                                                        00040714
* Determine move direction (s to d or d to s) depending on what         00040814
* is legal. Even if count(d) is 0 the comparison will work as           00040921
* slice(stack,0) is initialized with a value higher than any number     00041021
* of slices                                                             00041121
* check STKSLICE(BFROM,STKCOUNT(BFROM)) < STKSLICE(BTO,STKCOUNT(BTO))   00041221
* if not change move direction                                          00041321
* from side                                                             00041421
         LA    R7,STKCOUNL                                              00041517
         M     R6,BFROM            STKCOUNTL*BFROM displacement         00041616
         LA    R5,STKCOUNT(R7)                                          00041719
         ST    R5,XFSTKCNT         address from stack count             00041821
         L     R9,STKCOUNT(R7)                                          00041919
         LA    R5,STKDYNL                                               00042017
         MR    R8,R5               relative BFROM count pos STKSLICE    00042121
         L     R7,STKSLCS1                                              00042216
         M     R6,BFROM            get stack position acc. to BFROM     00042317
         AR    R7,R9               get STKSLICE position                00042417
         LA    R5,STKSLICE(R7)                                          00042519
         ST    R5,XFSTKSLC         address from slice                   00042619
         L     R6,STKSLICE(R7)     get slice value                      00042717
         ST    R6,XSLCFROM         from slice value                     00042821
* to side                                                               00042921
         LA    R7,STKCOUNL                                              00043017
         M     R6,BTO              STKCOUNTL*BTO displacement           00043116
         LA    R5,STKCOUNT(R7)                                          00043219
         ST    R5,XTSTKCNT         address to stack count               00043319
         L     R9,STKCOUNT(R7)                                          00043419
         LA    R5,STKDYNL                                               00043517
         MR    R8,R5               relative BTO count pos STKSLICE      00043621
         L     R7,STKSLCS1                                              00043716
         M     R6,BTO              get stack position acc. to BTO       00043821
         AR    R7,R9               get STKSLICE position                00043921
         LA    R5,STKSLICE(R7)                                          00044019
         ST    R5,XTSTKSLC         address to slice                     00044119
         L     R6,STKSLICE(R7)     get slice value                      00044221
         ST    R6,XSLCTO           to slice value                       00044321
*                                                                       00044421
         C     R6,XSLCFROM         compare to slice with from slice     00044519
         BNL   CONTMOVE            top slc stk to >= top slc stk from   00044620
* change direction of move as top slice to < top slice from             00044721
         SWAPF BFROM,BTO           swap from and to                     00044819
         SWAPF XFSTKCNT,XTSTKCNT   swap addresses from,to counts        00044919
         SWAPF XFSTKSLC,XTSTKSLC   swap addresses from,to slice         00045019
         SWAPF XSLCFROM,XSLCTO     swap stored from and to slice values 00045119
* move the slice                                                        00045221
CONTMOVE EQU   *                                                        00045318
         LA    R5,STKDYNL          displacement for one slice element   00045419
         A     R5,XTSTKSLC                                              00045520
         L     R6,XSLCFROM         from slice value                     00045619
         ST    R6,0(R5)            store from slice to to sclice+1      00045720
         L     R5,XTSTKCNT         to stack count                       00045820
         L     R6,0(R5)                                                 00045920
         A     R6,=F'1'            add 1 to to stack count value        00046020
         ST    R6,0(R5)            store new value to to stack count    00046120
         L     R5,XFSTKSLC         set from slice to 0                  00046220
         LA    R6,0                                                     00046319
         ST    R6,0(R5)            set from slice to 0                  00046420
         L     R5,XFSTKCNT         from stack count                     00046520
         L     R6,0(R5)                                                 00046620
         S     R6,=F'1'            subtract 1 from from stk count value 00046720
         ST    R6,0(R5)            store new value to from stack count  00046820
* prepare step information fields for output record                     00046921
         CVD   R3,TPALIGN          current step                         00047019
         ZAP   STEPS,TPALIGN       store current step                   00047119
         L     R5,XSLCFROM         current slice                        00047219
         CVD   R5,TPALIGN                                               00047319
         ZAP   SLICES,TPALIGN      store current slice                  00047419
         LA    R7,STKDSPNL                                              00047519
         M     R6,BFROM            STKDSPNL*BFROM displacement          00047619
         LA    R9,STKDSPNO                                              00047719
         AR    R9,R7                                                    00047819
         ZAP   FROM(1),0(1,R9)                                          00047919
         LA    R7,STKDSPNL                                              00048019
         M     R6,BTO              STKDSPNL*BFROM displacement          00048119
         LA    R9,STKDSPNO                                              00048219
         AR    R9,R7                                                    00048319
         ZAP   TO(1),0(1,R9)                                            00048419
* prepare step line output record using the fields set above            00048521
         MVC   TRGTSTPS,TMPSTPS                                         00048619
         ED    TRGTSTPS,STEPS                                           00048719
         MVC   OSTEP,TRGTSTPS+1                                         00048819
         MVC   TRGTSLC,TMPSLC                                           00048919
         ED    TRGTSLC,SLICES                                           00049019
         MVC   OSLICE,TRGTSLC+2                                         00049119
         MVC   TRGTSTK,TMPSTK                                           00049219
         ED    TRGTSTK,FROM                                             00049319
         MVC   OFROM,TRGTSTK+1                                          00049419
         MVC   TRGTSTK,TMPSTK                                           00049519
         ED    TRGTSTK,TO                                               00049619
         MVC   OTO,TRGTSTK+1                                            00049719
         L     R5,HANOIOUT         load address of HANOIOUT DCB         00049820
         PUT   (R5),OREC           write step line                      00049920
         B     STPLPNXT                                                 00050014
*                                                                       00050119
STPLPEND EQU   *                                                        00050214
         S     R3,=F'1'                                                 00050319
         CVD   R3,TPALIGN                                               00050419
         ZAP   STEPS,TPALIGN       store number of steps performed      00050519
* end of segment processing                                             00050601
PROCEND  EQU   *                   end of segment processing            00050701
* return to caller actions                                              00050801
         L     R13,SAVEAREA+4                                           00050901
* return current number of steps to caller (adress ASTEPS)              00051018
         L     R3,ASTEPS                                                00051104
         ZAP   0(4,R3),STEPS(4)                                         00051204
* free dynamic stack data                                               00051305
         L     R0,STKALLOC         length of allocated  area            00051405
         FREEMAIN R,LV=(0),A=(11)  free area R11 with length R0         00051511
         WTO   'HANOIITR... end HANOIITR'                               00051605
         RETURN (14,12),RC=0                                            00051701
*---                                                                    00051821
* debug                                                                 00051917
*        L     R5,BSLICES                                               00052017
*        CVD   R5,TPALIGN                                               00052117
*        MVC   TRGTVAL,TMPVAL                                           00052219
*        ED    TRGTVAL,TPALIGN                                          00052319
*        MVC   MSGVALUE,TRGTVAL                                         00052419
*        WTO   MF=(E,MSGBLOCK)                                          00052517
*        B     PROCEND                                                  00052617
*                                                                       00052717
*                                                                       00052819
*--- data definitions                                                   00052901
* info for the 3 stacks                                                 00053005
STKDSPNO DS    3PL1                display no of the stack              00053105
STKDSPNL EQU   1                                                        00053217
STKCOUNT DS    3F                  count                                00053315
STKCOUNL EQU   4                                                        00053417
*--- stack slice info - dynamically depending on no of slices           00053521
* allocate 3 times no of slices (3 times no of slices STKDYNL bytes)    00053605
         CNOP  0,4                                                      00053711
STKDYN   DSECT                                                          00053805
STKSLICE DS    XL4                                                      00053911
STKDYNL  EQU   *-STKDYN                                                 00054005
* end DSECT, continue CSECT                                             00054105
HANOIITR CSECT                                                          00054205
         CNOP  0,4                                                      00054305
STKSLCS1 DS    F                   dnynamic slices+1 storage per stack  00054411
STKALLOC DS    F                   length of alloced dyn stack area     00054511
R3HELP   DS    F                   R3 value in storage as help          00054618
XSLCFROM DS    F                   number of slice to move from         00054718
XSLCTO   DS    F                   number of slice to move to           00054818
XFSTKCNT DS    F                   address from stack count             00054919
XTSTKCNT DS    F                   address to stack count               00055019
XFSTKSLC DS    F                   address from slice                   00055119
XTSTKSLC DS    F                   address to slice                     00055219
         CNOP  0,8                                                      00055305
TPALIGN  DS    PL8                 aligned packed decimal 8 bytes long  00055409
*---                                                                    00055521
SAVEAREA DS    18F                                                      00055601
*--- parameters (by value except reference to output file DCB HANOIOUT) 00055721
* remember address of variable (reference, output) for STEPS in ASTEPS  00055804
* to return number of steps to caller                                   00055904
HANOIOUT DS    A(4)                address of output file DCB           00056001
SLICES   DS    PL2                                                      00056104
FROM     DS    PL1                                                      00056201
TO       DS    PL1                                                      00056301
AUX      DS    PL1                                                      00056401
STEPS    DS    PL4                                                      00056501
ASTEPS   DS    A(4)                remember caller's steps address      00056604
* parameters a binary values                                            00056710
BSLICES  DS    F                                                        00056811
BFROM    DS    F                                                        00056911
BTO      DS    F                                                        00057011
*--- output line definition for step                                    00057121
OREC     DS    0CL133                                                   00057201
         DC    CL1' '              ASO character                        00057301
         DC    CL5'Step '                                               00057401
OSTEP    DS    CL7                 current step number                  00057501
         DC    CL15': Moving slice '                                    00057601
OSLICE   DS    CL2                 current slice                        00057701
         DC    CL12' from stack '                                       00057801
OFROM    DS    CL1                 from stack                           00057901
         DC    CL4' to '                                                00058001
OTO      DS    CL1                 to stack                             00058101
         DC    CL85' '                                                  00058201
* templates and target fields for print preparation                     00058301
TRGTSLC  DS    CL4                                                      00058401
TMPSLC   DC    X'40202120'                                              00058519
TRGTSTK  DS    CL2                                                      00058601
TMPSTK   DC    X'4020'                                                  00058719
TRGTSTPS DS    CL8                                                      00058801
TMPSTPS  DC    X'4020202020202120'                                      00058919
*---                                                                    00059021
*                                                                       00059119
* WTO message for debug purposes                                        00059207
*         CNOP  0,4                                                     00059320
*MSGBLOCK EQU   *                                                       00059420
*         DC    H'80'               length of WTO buffer                00059520
*         DC    H'0'                should be binary zeroes             00059620
*MSGTEXT  DS    0CL76                                                   00059720
*         DC    CL11'HANOIITR...'                                       00059820
*MSGVALUE DS    CL16                                                    00059920
*         DC    CL3'...'                                                00060020
*         DC    CL46' '                                                 00060120
* WTO msg additional stuff                                              00060220
*TRGTVAL  DS    CL16                                                    00060320
*TMPVAL   DC    X'40202020202020202020202020202120'                     00060420
*                                                                       00060519
*                                                                       00060619
*--- literals, if any, will go here                                     00060701
         LTORG *                                                        00060801
*--- end of section                                                     00060901
         END   HANOIITR                                                 00061001
/*                                                                      00061101
//*-------------------------------------------------------------------- 00061201
//HANOIASM EXEC ASMFCLG,PARM.ASM=(OBJ,NODECK),MAC1='SYS2.MACLIB',      X00061301
//             REGION.GO=128K                                           00061401
//ASM.SYSIN DD *                                                        00061501
*********************************************************************** 00061601
* ///////////////////////////////////////////////////////////////////// 00061701
* Title: HANOIASM - The Towers of Hanoi                                 00061801
* Author: ManInBlueAT                                                   00061901
* Language: ASM                                                         00062001
*                                                                       00062101
* Description: Move n slices from source stack from to destination      00062221
*   stack to using auxiliary stack aux (6-from-to). A recursive or      00062321
*   iterative algorithm is applied according to the choice (REC or      00062421
*   ITER) entered in the input record. Please refer to                  00062521
*   https://en.wikipedia.org/wiki/Tower_of_Hanoi                        00062621
*                                                                       00062701
* Changes:                                                              00062801
* - ManInBlueAT, 2026-10-09 New program                                 00062901
* ///////////////////////////////////////////////////////////////////// 00063001
         PRINT GEN                                                      00063101
         REGISTER                                                       00063201
HANOIASM CSECT                                                          00063301
         SAVE  (14,12)                                                  00063401
         BALR  R12,0                                                    00063501
         USING *,R12                                                    00063601
         LA    R2,SAVEAREA                                              00063701
         ST    R2,8(,R13)                                               00063801
         ST    R13,SAVEAREA+4                                           00063901
         LR    R13,R2                                                   00064001
*--- start processing                                                   00064101
         WTO   'HANOIASM... Begin execution'                            00064201
         LA    R11,0               return code 0                        00064301
         OPEN  (HANOIIN,(INPUT))                                        00064401
         OPEN  (HANOIOUT,(OUTPUT))                                      00064501
* read towers of hanoi runtime parameters: slices from to               00064601
         GET   HANOIIN,IREC                                             00064701
* check parameters                                                      00064801
         PACK  SLICES,ISLICES                                           00064901
         CP    SLICES,=P'0'                                             00065001
         BNP   ERRP1               <=0 or overlfow BC X'0D'             00065101
         CP    SLICES,=P'20'                                            00065201
         BP    ERRP1               >11 BC X'02'                         00065301
*                                                                       00065401
         PACK  FROM,IFROM                                               00065501
         CP    FROM,=P'0'                                               00065601
         BNP   ERRP23              <=0 or overflow BC X'0D'             00065701
         CP    FROM,=P'3'                                               00065801
         BP    ERRP23              >3 BC X'02'                          00065901
*                                                                       00066001
         PACK  TO,ITO                                                   00066101
         CP    TO,=P'0'                                                 00066201
         BNP   ERRP23              <=0 or overflow BC X'0D'             00066301
         CP    TO,=P'3'                                                 00066401
         BP    ERRP23              >3 BC X'02'                          00066501
         CP    FROM,TO                                                  00066601
         BZ    ERRP23              = BC X'08'                           00066701
*                                                                       00066801
         CLC   IALG,=C'REC '                                            00066901
         BE    C4OK                = BC X'08'                           00067001
         CLC   IALG,=C'ITER'                                            00067101
         BNE   ERRP4               = BC X'07'                           00067201
C4OK     EQU   *                                                        00067301
* all checks ok, determine AUX stack number                             00067401
         ZAP   AUX,=P'6'           aux=6-from-to                        00067501
         SP    AUX,FROM                                                 00067601
         SP    AUX,TO                                                   00067701
* prepare headline OHEAD                                                00067801
         MVC   TRGTSLC,TMPSLC                                           00067901
         ED    TRGTSLC,SLICES                                           00068001
         MVC   OHSLICES,TRGTSLC+2                                       00068101
         MVC   TRGTSTK,TMPSTK                                           00068201
         ED    TRGTSTK,FROM                                             00068301
         MVC   OHFROM,TRGTSTK+1                                         00068401
         MVC   TRGTSTK,TMPSTK                                           00068501
         ED    TRGTSTK,TO                                               00068601
         MVC   OHTO,TRGTSTK+1                                           00068701
         MVC   TRGTSTK,TMPSTK                                           00068801
         ED    TRGTSTK,AUX                                              00068901
         MVC   OHAUX,TRGTSTK+1                                          00069001
         PUT   HANOIOUT,OHEAD      write headline                       00069101
         PUT   HANOIOUT,=CL133' '  write space line                     00069201
* initialize number of steps                                            00069301
         ZAP   STEPS,=P'0'                                              00069401
* call HANOILN to peform the necessary steps                            00069501
         CLC   IALG,=C'REC '                                            00069601
         BE    CALLREC             = BC X'08'                           00069701
         WTO   'HANOIASM... calling HANOIITR'                           00069801
         CALL  HANOIITR,(ALIST)                                         00069901
         WTO   'HANOIASM... back from HANOIITR'                         00070001
         B     PREPEND                                                  00070101
CALLREC  EQU   *                                                        00070201
         WTO   'HANOIASM... calling HANOIREC'                           00070301
         CALL  HANOIREC,(ALIST)                                         00070401
         WTO   'HANOIASM... back from HANOIREC'                         00070501
* prepare trailing line OTRAIL                                          00070601
PREPEND  EQU   *                                                        00070701
         MVC   TRGTSTPS,TMPSTPS                                         00070801
         ED    TRGTSTPS,STEPS                                           00070901
         MVC   OTSTEPS,TRGTSTPS+1                                       00071001
         PUT   HANOIOUT,=CL133' '  write space line                     00071101
         PUT   HANOIOUT,OTRAIL     write trailing line                  00071201
         B     PROCEND             end of program                       00071301
* handle no input record provided                                       00071401
ATFIEND  EQU   *                                                        00071501
         MVC   OMSGNO,=C'0001'                                          00071601
         MVC   OMSGTYPE,=C'E'                                           00071701
         MVC   OMSGTEXT,BLANK                                           00071801
         MVC   OMSGTEXT(21),=C'No input record found'                   00071901
         PUT   HANOIOUT,OMSG                                            00072001
         LA    R11,8               return code                          00072101
         B     PROCEND             end of program                       00072201
* parameter error messages                                              00072301
ERRP1    EQU   *                                                        00072401
         MVC   OMSGNO,=C'0002'                                          00072501
         MVC   OMSGTYPE,=C'E'                                           00072601
         MVC   OMSGTEXT,BLANK                                           00072701
         MVC   OMSGTEXT(38),=C'Number of slices must be 1<=slices<=20'  00072801
         PUT   HANOIOUT,OMSG       Write error message                  00072901
         LA    R11,8               return code                          00073001
         B     PROCEND             end of program                       00073101
*                                                                       00073201
ERRP23   EQU   *                                                        00073301
         MVC   OMSGNO,=C'0003'                                          00073401
         MVC   OMSGTYPE,=C'E'                                           00073501
         MVC   OMSGTEXT,BLANK                                           00073601
         MVC   OMSGTEXT(42),=C'Values from,to must be 1<=from,to<=3 andX00073701
                from<>to'                                               00073801
         PUT   HANOIOUT,OMSG       Write error message                  00073901
         LA    R11,8               return code                          00074001
         B     PROCEND             end of program                       00074101
*                                                                       00074201
ERRP4    EQU   *                                                        00074301
         MVC   OMSGNO,=C'0004'                                          00074401
         MVC   OMSGTYPE,=C'E'                                           00074501
         MVC   OMSGTEXT,BLANK                                           00074601
         MVC   OMSGTEXT(49),=C'Algorithm spcification must be either REX00074701
               C or ITER'                                               00074801
         PUT   HANOIOUT,OMSG       Write error message                  00074901
         LA    R11,8               return code                          00075001
         B     PROCEND             end of program                       00075101
* end of program processing                                             00075201
PROCEND  EQU   *                                                        00075301
* close files                                                           00075401
         CLOSE (HANOIIN)                                                00075501
         CLOSE (HANOIOUT)                                               00075601
* handle trailer message to console                                     00075701
         LTR   R11,R11                                                  00075801
         BE    PROCENDA                                                 00075901
         WTO   'HANOIASM... Program ended with errors'                  00076001
         B     PROCENDB                                                 00076101
PROCENDA EQU   *                                                        00076201
         WTO   'HANOIASM... Normal end of program'                      00076301
PROCENDB EQU   *                                                        00076401
* return to caller                                                      00076501
         L     R13,SAVEAREA+4                                           00076601
         LR    R15,R11                                                  00076701
         RETURN (14,12),RC=(15)                                         00076801
*--- data definitions                                                   00076901
* INSTANCE - same structure as in HANOILN to allow                      00077001
* return values using this structure (STEPS)                            00077101
SAVEAREA DS    18F                                                      00077201
OFDUMMY  DC    A(HANOIOUT)         address output file DCB - not used   00077301
* fields also used as parameters                                        00077401
SLICES   DS    PL2                 number of slices to move             00077501
FROM     DS    PL1                 from stack number                    00077601
TO       DS    PL1                 to stack number                      00077701
AUX      DS    PL1                 auxiliary stack number               00077801
STEPS    DS    PL4                 number of steps                      00077901
         DC    CL3'   '                                                 00078001
* Parameters to HANOILN (proper way to pass parameters...)              00078101
ALIST    DC    A(HANOIOUT)                                              00078201
         DC    A(SLICES)                                                00078301
         DC    A(FROM)                                                  00078401
         DC    A(TO)                                                    00078501
         DC    A(AUX)                                                   00078601
         DC    X'80'                                                    00078701
         DC    AL3(STEPS)                                               00078801
*--- file definitions                                                   00078921
HANOIIN  DCB   DSORG=PS,RECFM=FB,LRECL=80,MACRF=(GM),EODAD=ATFIEND,    X00079001
               DEVD=DA,DDNAME=HANOIIN                                   00079101
HANOIOUT DCB   DSORG=PS,RECFM=FBA,LRECL=133,MACRF=(PM),                X00079201
               DEVD=DA,DDNAME=HANOIOUT                                  00079301
*--- input record definition                                            00079421
IREC     DS    0CL80               input record                         00079501
         DS    CL1' '              comment marker (ASM editor profile)  00079601
ISLICES  DS    CL2                 no of slices (0<=SLICES<=11)         00079701
         DS    CL1' '              filler                               00079801
IFROM    DS    CL1                 from stack (1<=FROM<=3)              00079901
         DS    CL1' '              filler                               00080001
ITO      DS    CL1                 to stack (1<=TO<=3,TO<>FROM)         00080101
         DS    CL1' '              filler                               00080201
IALG     DS    CL4                 algorithm REC or ITER                00080301
         DS    CL68                filler                               00080401
*--- output record definitions                                          00080521
* output record definition for headline                                 00080621
OHEAD    DS    0CL133                                                   00080701
         DC    CL1' '              ASO character                        00080801
         DC    CL7'Moving '                                             00080901
OHSLICES DS    CL2                                                      00081001
         DC    CL26' slices from source stack '                         00081101
OHFROM   DS    CL1                                                      00081201
         DC    CL22' to destination stack '                             00081301
OHTO     DS    CL1                                                      00081401
         DC    CL23' using auxiliary stack '                            00081501
OHAUX    DS    CL1                                                      00081601
         DC    CL49' '                                                  00081701
* output record definition for trailing line                            00081801
OTRAIL   DS    0CL133                                                   00081901
         DC    CL1' '              ASO character                        00082001
         DC    CL8'Done in '                                            00082101
OTSTEPS  DS    CL7                                                      00082201
         DC    CL6' steps'                                              00082301
         DC    CL111' '                                                 00082401
* templates and target fields for print preparation                     00082501
TRGTSLC  DS    CL4                                                      00082601
TMPSLC   DC    X'40202120'                                              00082719
TRGTSTK  DS    CL2                                                      00082801
TMPSTK   DC    X'4020'                                                  00082919
TRGTSTPS DS    CL8                                                      00083001
TMPSTPS  DC    X'4020202020202120'                                      00083119
* output record definition for error messages                           00083201
BLANK    DC    133CL1' '           all blank                            00083301
OMSG     DS    0CL133                                                   00083401
         DC    CL1' '              ASO character                        00083501
         DC    CL3'HAN'            message no prefix                    00083601
OMSGNO   DS    CL4                 message no                           00083701
OMSGTYPE DS    CL1                 message type (I,W,E)                 00083801
         DC    CL1' '              filler                               00083901
OMSGTEXT DS    CL123               message text                         00084001
*--- Literals, if any, will go here                                     00084101
         LTORG *                                                        00084201
*--- end of section                                                     00084301
         END   HANOIASM                                                 00084401
/*                                                                      00084501
//*-------------------------------------------------------------------- 00084601
//LKED.SYSIN  DD *                                                      00084701
              ENTRY HANOIASM                                            00084801
/*                                                                      00084901
*---------------------------------------------------------------------- 00085001
//GO.HANOIIN  DD *                                                      00085101
*05 1 2 ITER                                                            00085221
/*                                                                      00085301
//GO.HANOIOUT DD SYSOUT=*,DCB=(RECFM=FBA,LRECL=133,BLKSIZE=1330)        00085401
//                                                                      00085501

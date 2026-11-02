//HANOICOB JOB (MBA),
//             'Hanoi iter COBOL',
//             CLASS=A,
//             MSGCLASS=A,
//             NOTIFY=HERC01,
//             REGION=8M,TIME=1440,
//             MSGLEVEL=(1,1)
//*********************************************************************
//*
//* Name: HERC01.MYSTUFF.JCL(HANOICOB)
//*
//* Desc: Towers of Hanoi.
//*       Number of slices n (PIC 99, 1<=n<=10), source stack s
//*       (PIC 99, 0<=s<=2) and destination stack d (PIC 99,
//*       (0<=d<=2)&(d<>s)) are entered in //GO.SYSIN DD
//*
//*********************************************************************
//HANOI    EXEC COBUCG,
//         PARM.COB='FLAGW,LOAD,SUPMAP,SIZE=2048K,BUF=1024K'
//COB.SYSPUNCH DD DUMMY
//COB.SYSIN    DD *
      * //////////////////////////////////////////////////////////
      * // Name: ManInBlueAT
      * // Program: The Towers of Hanoi
      * // Language: COBOL
      * //
      * // Desc:
      * // Move n slices from source stack s to destination stack d
      * // using help stack h (3-s-d)
      * // As recursion is not supported in COBOL 360 an iterative
      * // algorithm is applied. Please refer to
      * // https://en.wikipedia.org/wiki/Tower_of_Hanoi
      * //
      * // Changes:
      * // - ManInBlueAT, 2024-05-18 New program
      * //////////////////////////////////////////////////////////
       IDENTIFICATION DIVISION.
       PROGRAM-ID.  'HANOI'.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER.  IBM-360.
       OBJECT-COMPUTER.  IBM-360.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT HANOI-SYSIN
              ASSIGN TO UT-S-SYSIN.
      *
       DATA DIVISION.
       FILE SECTION.
       FD  HANOI-SYSIN
           RECORDING MODE IS F
           RECORD CONTAINS 80 CHARACTERS
           BLOCK  CONTAINS  1 RECORDS
           LABEL RECORDS ARE OMITTED
           DATA RECORD IS HANOI-SYSIN-RECORD.
           01  HANOI-SYSIN-RECORD.
             02 HANOI-SYSIN-SLICES PIC 99.
             02 HANOI-SYSIN-SOURCE PIC 99.
             02 HANOI-SYSIN-DEST   PIC 99.
             02 FILLER             PIC X(74).
       WORKING-STORAGE SECTION.
           77 N            PIC 99.
           77 S            PIC 99.
           77 D            PIC 99.
           77 HLP-1        PIC 99.
           77 HLP-2        PIC 99.
           77 I            PIC 99999 COMP.
           77 STEPS        PIC 99999 COMP.
           77 SM           PIC 99.
           77 DM           PIC 99.
           01 DISPLAY-ZZ.
             05 DISPL-ZZ   PIC Z9 OCCURS 4.
           01 DISPL-STEPS  PIC ZZZZ9.
           01 STACK.
             05 STACKSTRUC OCCURS 3 TIMES.
               10 DISPLAY-NO PIC 99.
               10 COUNT      PIC 99.
               10 SLICE      PIC 99 OCCURS 11 TIMES.
      *
       PROCEDURE DIVISION.
       MAIN-PART.
           OPEN INPUT HANOI-SYSIN.
           READ HANOI-SYSIN AT END
             DISPLAY '** EOF on SYSIN. No data found. Exit.'
             STOP RUN.
           MOVE HANOI-SYSIN-SLICES TO N.
           MOVE HANOI-SYSIN-SOURCE TO S.
           MOVE HANOI-SYSIN-DEST   TO D.
           CLOSE HANOI-SYSIN.
      *
      * Internally we always move slices
      * from stack 0 to 1 with help stack 2 if n is odd and
      * from stack 0 to 2 with help stack 1 if n is even
      * As the index origin in COBOL is 1 the array indices of
      * stack is 1 to 3
      *
           MOVE S TO DISPLAY-NO (1).
           DIVIDE 2 INTO N GIVING HLP-1 REMAINDER HLP-2.
           IF HLP-2 = 1
             MOVE D TO DISPLAY-NO (2)
             COMPUTE DISPLAY-NO (3) = 3 - S - D
             MOVE DISPLAY-NO (3) TO HLP-1
           ELSE
             MOVE D TO DISPLAY-NO (3)
             COMPUTE DISPLAY-NO (2) = 3 - S - D
             MOVE DISPLAY-NO (2) TO HLP-1.
      *
           MOVE N TO DISPL-ZZ (1).
           MOVE S TO DISPL-ZZ (2).
           MOVE D TO DISPL-ZZ (3).
           MOVE DISPLAY-NO (HLP-1) TO DISPL-ZZ (4).
           DISPLAY 'Moving ', DISPL-ZZ (1), ' slices from stack ',
             DISPL-ZZ (2), ' to stack ', DISPL-ZZ (3),
             ' using help stack ', DISPL-ZZ (4).
           DISPLAY ' '.
      *
      * Initialize stack structure. For every stack, maintain the count
      * of slices and track the slices by their position number on the
      * stack. Initiallly all slices are on stack 0
      *
           MOVE N TO COUNT (1).
           MOVE 0 TO COUNT (2).
           MOVE 0 TO COUNT (3).
      *
      * The slices are maintained in SLICE per stack. The indices used
      * are 2 to 11 (maximum 10 slices). SLICE 1 is set to a value
      * (99) higher than any n (max 10) so that any existing slice
      * number will always be smaller. The smallest slice has the top
      * position on the stack with the highest index
      *
           MOVE 99 TO SLICE (1, 1).
           MOVE 99 TO SLICE (2, 1).
           MOVE 99 TO SLICE (3, 1).
      *
           COMPUTE I = N + 1.
           PERFORM INIT-SLICES UNTIL I LESS  2.
      *
           COMPUTE STEPS = 2 ** N - 1.
           MOVE 1 TO I.
           PERFORM MOVE-SLICE UNTIL I GREATER STEPS.
      *
           DISPLAY ' '.
           DISPLAY 'Done.'.
           STOP RUN.
      *
       INIT-SLICES.
           COMPUTE SLICE (1, I) = N - I + 2.
           MOVE 0 TO SLICE (2, I).
           MOVE 0 TO SLICE (3, I).
           COMPUTE I = I - 1.
      *
       MOVE-SLICE.
      *
      * Do series of three different moves until done: 0 to 1 or 0 to 2
      * or 1 to 2 or vice versa
      *
           DIVIDE 3 INTO I GIVING HLP-1 REMAINDER HLP-2.
           IF HLP-2 = 1
      *        move 0 to 1 or vice versa
             MOVE 1 TO S
             MOVE 2 TO D
           ELSE IF HLP-2 = 2
      *        move 0 to 2 or vice versa
             MOVE 1 TO S
             MOVE 3 TO D
           ELSE
      *        move 1 to 2 or vice versa
             MOVE 2 TO S
             MOVE 3 TO D.
           PERFORM MOVE-SLICE-1.
           COMPUTE I = I + 1.
      *
       MOVE-SLICE-1.
           COMPUTE HLP-1 = COUNT (S) + 1.
           COMPUTE HLP-2 = COUNT (D) + 1.
      *
      * Determine move direction (s to d or d to s) depending on what
      * is legal. Even if COUNT (D) is 0 the comparison will work as
      * SLICE (stack, 0 --> 1) is initialized with a value higher
      * than any number of slices
      *
           IF SLICE (S, HLP-1) LESS SLICE (D, HLP-2)
             MOVE S TO SM
             MOVE D TO DM
           ELSE
             MOVE D TO SM
             MOVE S TO DM.
      *
      * do the move
      *
           COMPUTE HLP-1 = COUNT (SM) + 1.
           COMPUTE HLP-2 = COUNT (DM) + 1.
           ADD 1 TO HLP-2.
           MOVE SLICE (SM, HLP-1) TO SLICE (DM, HLP-2).
           COMPUTE COUNT (DM) = HLP-2 - 1.
           MOVE 0 TO SLICE (SM, HLP-1).
           SUBTRACT 1 FROM COUNT (SM).
      *
           MOVE I TO DISPL-STEPS.
           MOVE SLICE (DM, HLP-2) TO DISPL-ZZ (1).
           MOVE DISPLAY-NO (SM) TO DISPL-ZZ (2).
           MOVE DISPLAY-NO (DM) TO DISPL-ZZ (3).
           DISPLAY 'Step ', DISPL-STEPS ': Moving slice ',
             DISPL-ZZ (1), ' from stack ', DISPL-ZZ (2),
             ' to stack ', DISPL-ZZ (3).
      *
/*
//COB.SYSLIB  DD DSNAME=SYS1.COBLIB,DISP=SHR
//GO.SYSOUT   DD SYSOUT=*,DCB=(RECFM=FBA,LRECL=161,BLKSIZE=16100)
//GO.SYSIN    DD *
 4 0 1
/*
//

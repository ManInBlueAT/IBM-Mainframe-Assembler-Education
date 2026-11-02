//HANOIPLI JOB (MBA),
//             'Hanoi rec PL/1',
//             CLASS=A,
//             MSGCLASS=A,
//             NOTIFY=HERC01,
//             REGION=8M,TIME=1440,
//             MSGLEVEL=(1,1)
//**********************************************************************
//* Name: HERC01.MYSTUFF.JCL(HANOIPLI)
//*
//* Desc: Towers of Hanoi.
//*       Number of slices n (1<=n<=10), source stack s (0<=s<=2)
//*       and destination stack d (0<=d<=2)&(d<>s)) are entered
//*       in //GO.SYSIN DD
//**********************************************************************
//HANOI    EXEC PL1LFCG,PARM.PL1L='LOAD,NODECK,OPT=02'
//PL1L.SYSLIN DD UNIT=SYSDA
//PL1L.SYSIN DD *
 HANOI: PROC OPTIONS (MAIN) REORDER;
 /* ////////////////////////////////////////////////////////////////////
  * Name: ManInBlueAT
  * Program: The Towers of Hanoi
  * Language: PL/1
  *
  * Desc:
  * Move n slices from source stack s to destination stack d using help
  * stack h (3-s-d). A recursive algorithm is applied. Please refer to
  * https://en.wikipedia.org/wiki/Tower_of_Hanoi
  *
  * Changes:
  * - ManInBlueAT, 2024-05-20 New program
  * ///////////////////////////////////////////////////////////////// */
 DECLARE N      BINARY FIXED(31);
 DECLARE S      BINARY FIXED(31);
 DECLARE D      BINARY FIXED(31);
 DECLARE H      BINARY FIXED(31);
 DECLARE STEPS  BINARY FIXED(31);

 DECLARE SYSIN FILE;
 DECLARE SYSPRINT FILE;

 GET LIST(N,S,D) FILE(SYSIN);
 H = 3 - S - D;

 PUT EDIT('Moving ',N,' slices from source stack ',S,
   ' to destination stack ',D,' using help stack ',H)
   (A(7),F(2,0),A(26),F(2,0),A(22),F(2,0),A(18),F(2,0))
   FILE(SYSPRINT);
 PUT SKIP FILE(SYSPRINT);

 STEPS = 0;
 STEPS = DOHANOI(N,S,D,H,STEPS);

 PUT SKIP(2) EDIT('Done.')(A(5)) FILE(SYSPRINT);

 /* --------------------------------------------------------------------
  * Recursive function DOHANOI that processes the sequence of steps:
  * Move uppper n-1 slices from source to help stack, move lowest slice
  * (slice n) from source to destination stack and move upper n-1 slices
  * from help stack to destination stack
  * ----------------------------------------------------------------- */
 DOHANOI: PROCEDURE(N,S,D,H,STEPS) RECURSIVE;
   DECLARE N      BINARY FIXED(31);
   DECLARE S      BINARY FIXED(31);
   DECLARE D      BINARY FIXED(31);
   DECLARE H      BINARY FIXED(31);
   DECLARE STEPS  BINARY FIXED(31);

   IF (N > 1) THEN DO;
     STEPS = DOHANOI(N-1,S,H,D,STEPS);
     STEPS = DOSTEP(N,S,D,STEPS);
     STEPS = DOHANOI(N-1,H,D,S,STEPS);
     END;
   ELSE
     STEPS = DOSTEP(N,S,D,STEPS);

   RETURN(STEPS);
 END DOHANOI;

 /* --------------------------------------------------------------------
  * DOSTEP performs the step of moving a slice. The counter STEPS is
  * increased and the current slice i is moved from the current source
  * stack sc to the current destination stack dc
  * ----------------------------------------------------------------- */
 DOSTEP: PROCEDURE(I,SC,DC,STEPS);
   DECLARE I      BINARY FIXED(31);
   DECLARE SC     BINARY FIXED(31);
   DECLARE DC     BINARY FIXED(31);
   DECLARE STEPS  BINARY FIXED(31);
   STEPS = STEPS + 1;
   PUT SKIP EDIT('Step ',STEPS,': Moving slice ',I,' from stack ',
     SC,' to stack ',DC)
     (A(5),F(5,0),A(15),F(2,0),A(12),F(2,0),A(10),F(2,0))
     FILE(SYSPRINT);

   RETURN(STEPS);
 END DOSTEP;

 END HANOI;
/*
//GO.SYSPRINT DD SYSOUT=*,DCB=(RECFM=FBA,LRECL=161,BLKSIZE=16100)
//GO.SYSIN DD *
4 0 1
/*
//

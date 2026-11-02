/***********************************************************************
 The Towers of Hanoi - iterative solution according to
 https://en.wikipedia.org/wiki/Tower_of_Hanoi
***********************************************************************/

  Say ' '
  Say 'The Towers of Hanoi'
  Say ' '
  Say 'Please enter the number of slices to be moved (not too many!):'
  Parse Pull n
  Say ' '
  Say 'Please enter the source stack (0<=s<=2):'
  Parse Pull s
  Say ' '
  Say 'Please enter the destination stack ((0<=d<=2)&(d<>s)):'
  Parse Pull d
  Say ' '
  Say 'Moving' n 'slices from source stack' s 'to destination stack' d,
      'using help stack' 3-s-d
  Say ' '
  Say ' '
  c=0
  /* internally we always move slices
     from stack 0 to 1 with help stack 2 if n is odd and
     from stack 0 to 2 with help stack 1 if n is even */
  stack.0.display=s
  If n//2=1 Then Do
    /* odd number of slices */
    stack.1.display=d
    stack.2.display=3-s-d
    End
  Else Do
    /* even number of slices */
    stack.2.display=d
    stack.1.display=3-s-d
    End

  /* Initialize stack structure. For every stack, maintain the count of
     slices and track the slices by their position number on the stack.
     Initiallly all slices are on stack 0 */
  stack.0.count=n
  stack.1.count=0
  stack.2.count=0
  /* set slice.0 to a value higher than any n so that any existing
     slice number will always be smaller */
  stack.0.slice.0=99999
  stack.1.slice.0=99999
  stack.2.slice.0=99999
  Do i=n By -1 To 1
    /* the smallest slice has the top position on the stack with the
       highest index */
    stack.0.slice.i=n-i+1
    stack.1.slice.i=0
    stack.2.slice.i=0
    End

  /* Do series of three different moves until done: 0 to 1 or 0 to 2 or
     1 to 2 or vice versa */
  Do i=1 By 1 To 2**n-1
    relstepno=i//3
    If relstepno=1 Then
      /* move 0 to 1 or vice versa */
      Call MoveSlice i 0 1
    Else If relstepno=2 Then
      /* move 0 to 2 or vice versa */
      Call MoveSlice i 0 2
    Else /* relstepno=0 */
      /* move 1 to 2 or vice versa */
      Call MoveSlice i 1 2
      End

  Say ' ';
  Say 'End of execution'
  Exit

/***********************************************************************
 Move a slice in the legal direction
***********************************************************************/
MoveSlice: Procedure Expose stack.
  Parse Arg stepno s d

  scount=stack.s.count
  dcount=stack.d.count

  /* Determine move direction (s to d or d to s) depending on what is
     legal. Even if dcount is 0 the comparison will work as slice.0
     is inititialized with value higher than any number of slices */
  If stack.s.slice.scount<stack.d.slice.dcount Then Do
    sm=s
    dm=d
    End
  Else Do
    sm=d
    dm=s
    End

  /* do the move */
  smcount=stack.sm.count
  dmcount=stack.dm.count
  dmcount=dmcount+1
  stack.dm.slice.dmcount=stack.sm.slice.smcount
  stack.dm.count=dmcount
  stack.sm.slice.smcount=0
  stack.sm.count=stack.sm.count-1

  Say 'Step'||FORMAT(stepno,7)': slice '||,
    FORMAT(stack.dm.slice.dmcount,2)||,
    ' from stack '||stack.sm.display||' to stack '||stack.dm.display
  Return


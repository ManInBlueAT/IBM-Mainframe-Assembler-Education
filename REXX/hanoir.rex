/* */
/* https://en.wikipedia.org/wiki/Tower_of_Hanoi */
/* */
  Parse Arg n .
  If n='' Then n=3
  If n=0 Then Exit 0
  c=0
  Say ' '
  Say 'Moving' n 'slices from source stack 1 to destination stack 2',
    'using auxiliary stack 3'
  Say ' '
  /* Call DoHanoi n 1 2 3 */
  c=DoHanoi1(n 1 2 3 c)
  Say ' '
  Say 'Done in' c 'steps.'
  Exit 0

  DoHanoi: Procedure Expose c
    Parse Arg n s t a
    If n>1 Then Do
      Call DoHanoi n-1 s a t
      c=c+1
      Say 'Step' FORMAT(c,7) 'Moving slice' FORMAT(n,2) 'from stack' s,
        'to stack' t
      Call DoHanoi n-1 a t s
      End
    Else Do
      c=c+1
      Say 'Step' FORMAT(c,7) 'Moving slice' FORMAT(n,2) 'from stack' s,
        'to stack' t
      End
  Return

  DoHanoi1: Procedure
    Parse Arg n s t a c
    If n>1 Then Do
      c=DoHanoi1(n-1 s a t c)
      c=c+1
      Say 'Step' FORMAT(c,7) 'Moving slice' FORMAT(n,2) 'from stack' s,
        'to stack' t
      c=DoHanoi1(n-1 a t s c)
      End
    Else Do
      c=c+1
      Say 'Step' FORMAT(c,7) 'Moving slice' FORMAT(n,2) 'from stack' s,
        'to stack' t
      End
  Return c


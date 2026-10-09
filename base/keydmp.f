      SUBROUTINE KEYDMP (IOUT,IRECNT,KEYWRD,ARRAY,KARD)
      IMPLICIT NONE
C----------
C BASE $Id$
C----------
      INTEGER IRECNT,IOUT
      REAL ARRAY(12)
      CHARACTER*10 KARD(12)
      CHARACTER*8 KEYWRD
      WRITE (IOUT,70) IRECNT,KEYWRD,ARRAY,KARD
   70 FORMAT (/,' CARD NUM =',I5,'; KEYWORD FIELD = ''',A8,''''/
     >        '      PARAMETERS ARE:',12F14.12,/
     >        '      COL 11 TO 130 =''',12A10,'''')
C
      RETURN
      END

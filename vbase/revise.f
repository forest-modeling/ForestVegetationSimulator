      SUBROUTINE REVISE(VAR, REV)
      USE FVSVERSION
      IMPLICIT NONE
cf2py intent(in) var
cf2py intent(out) rev
C----------
C VBASE
C----------
C  REVISE -- Returns the build date for use in run output headers.
C  CALLED FROM: GROHED, FILOPN, SUMHED, SUMOUT, ECVOLS, PRTRLS, DGDRIV
C----------
      CHARACTER VAR*2, REV*10

      REV = FVSVER_DATE

      RETURN
      END

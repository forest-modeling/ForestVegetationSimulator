      SUBROUTINE SITSET
      IMPLICIT NONE
C----------
C TT $Id$
C----------
C  THIS SUBROUTINE LOADS THE SITEAR ARRAY WITH A SITE INDEX FOR EACH
C  SPECIES WHICH WAS NOT ASSIGNED A SITE INDEX BY KEYWORD, AND LOADS
C  THE SDIDEF ARRAY WITH SDI MAXIMUMS FOR EACH SPECIES WHICH WAS NOT
C  ASSIGNED AN SDI MAXIMUM USING THE SDIMAX KEYWORD.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'VOLSTD.F77'
C
C
COMMONS
C----------
      CHARACTER FORST*2,DIST*2,PROD*2,VAR*2,VOLEQ*11
      INTEGER IFIASP, ERRFLAG
      INTEGER I,INTFOR,IREGN,ISPC,J,JJ,K
      REAL SDICON(MAXSP),TEM,SITELO,SITEHI,SLOSSP,SHISSP
C----------
C SPECIES ORDER FOR TETONS VARIANT:
C
C  1=WB,  2=LM,  3=DF,  4=PM,  5=BS,  6=AS,  7=LP,  8=ES,  9=AF, 10=PP,
C 11=UJ, 12=RM, 13=BI, 14=MM, 15=NC, 16=MC, 17=OS, 18=OH
C
C VARIANT EXPANSION:
C BS USES ES EQUATIONS FROM TT
C PM USES PI (COMMON PINYON) EQUATIONS FROM UT
C PP USES PP EQUATIONS FROM CI
C UJ AND RM USE WJ (WESTERN JUNIPER) EQUATIONS FROM UT
C BI USES BM (BIGLEAF MAPLE) EQUATIONS FROM SO
C MM USES MM EQUATIONS FROM IE
C NC AND OH USE NC (NARROWLEAF COTTONWOOD) EQUATIONS FROM CR
C MC USES MC (CURL-LEAF MTN-MAHOGANY) EQUATIONS FROM SO
C OS USES OT (OTHER SP.) EQUATIONS FROM TT
C----------
      DATA SDICON /
     & 621., 409., 570., 358., 620., 562., 679., 620., 602., 446., 
     & 497., 411., 619., 680., 452., 501., 409., 452./ 
C----------
C IF SITEAR(I) HAS NOT BEEN SET WITH SITECODE KEYWORD, LOAD IT
C WITH DEFAULT SITE VALUES.
C----------
      TEM = 50.
      IF(ISISP .GT. 0)THEN
        IF(SITEAR(ISISP) .GT. 0.0) TEM = SITEAR(ISISP)
      ENDIF
      IF(ISISP .EQ. 0) ISISP = 3
C----------
C  GET THE APPROPRIATE SITE INDEX RANGE VALUES FOR THE SITE SPECIES.
C----------
        SLOSSP = 0.
        SHISSP = 999.
        CALL SITERANGE (1,ISISP,SLOSSP,SHISSP)
C
      DO 10 I=1,MAXSP
C----------
C  GET THE APPROPRIATE SITE INDEX RANGE VALUES FOR THIS SPECIES.
C----------
        SITELO = 0.
        SITEHI = 999.
        CALL SITERANGE (1,I,SITELO,SITEHI)
C
      IF(TEM .LT. SLOSSP)TEM=SLOSSP
      IF(SITEAR(I) .LE. 0.0) SITEAR(I) = SITELO +
     & (TEM-SLOSSP)/(SHISSP-SLOSSP)
     & *(SITEHI-SITELO)
   10 CONTINUE
C----------
C LOAD THE SDIDEF ARRAY.
C----------
      DO 40 I=1,MAXSP
        IF(SDIDEF(I) .GT. 0.0) GO TO 40
        IF(BAMAX .GT. 0.) THEN
          SDIDEF(I)=BAMAX/(0.5454154*(PMSDIU/100.))
        ELSE
          SDIDEF(I) = SDICON(I)
        ENDIF
   40 CONTINUE
C
      DO 92 I=1,15
      J=(I-1)*10 + 1
      JJ=J+9
      IF(JJ.GT.MAXSP)JJ=MAXSP
      WRITE(JOSTND,90)(NSP(K,1)(1:2),K=J,JJ)
   90 FORMAT(/'SPECIES ',5X,10(A2,6X))
      WRITE(JOSTND,91)(SDIDEF(K),K=J,JJ )
   91 FORMAT('SDI MAX ',   10F8.0)
      IF(JJ .EQ. MAXSP)GO TO 93
   92 CONTINUE
   93 CONTINUE
C----------
C  LOAD VOLUME EQUATION ARRAYS FOR ALL SPECIES
C----------
      INTFOR = KODFOR - (KODFOR/100)*100
      WRITE(FORST,'(I2)')INTFOR
      IF(INTFOR.LT.10)FORST(1:1)='0'
      IREGN = KODFOR/100
      DIST='  '
      PROD='  '
      VAR='TT'
C
      DO ISPC=1,MAXSP
      READ(FIAJSP(ISPC),'(I4)')IFIASP
      IF(((METHC(ISPC).EQ.6).OR.(METHC(ISPC).EQ.9)).AND.
     &     (VEQNNC(ISPC).EQ.'           '))THEN
        CALL VOLEQDEF(VAR,IREGN,FORST,DIST,IFIASP,PROD,VOLEQ,ERRFLAG)
        VEQNNC(ISPC)=VOLEQ
      ENDIF
      IF(((METHB(ISPC).EQ.6).OR.(METHB(ISPC).EQ.9)).AND.
     &     (VEQNNB(ISPC).EQ.'           '))THEN
        CALL VOLEQDEF(VAR,IREGN,FORST,DIST,IFIASP,PROD,VOLEQ,ERRFLAG)
        VEQNNB(ISPC)=VOLEQ
      ENDIF
      ENDDO
C----------
C  IF FIA CODES WERE IN INPUT DATA, WRITE TRANSLATION TABLE
C---------
      IF(LFIA) THEN
        CALL FIAHEAD(JOSTND)
        WRITE(JOSTND,211) (NSP(I,1)(1:2),FIAJSP(I),I=1,MAXSP)
 211    FORMAT ((T12,8(A3,'=',A6,:,'; '),A,'=',A6))
      ENDIF
C----------
C  WRITE VOLUME EQUATION NUMBER TABLE
C----------
      CALL VOLEQHEAD(JOSTND)
      WRITE(JOSTND,230)(NSP(J,1)(1:2),VEQNNC(J),VEQNNB(J),J=1,MAXSP)
 230  FORMAT(4(2X,A2,4X,A10,1X,A10,1X))
C
      RETURN
      END

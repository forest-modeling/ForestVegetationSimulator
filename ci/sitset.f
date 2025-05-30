      SUBROUTINE SITSET
      IMPLICIT NONE
C----------
C CI $Id$
C----------
C  THIS SUBROUTINE IS USED TO SET SIMULATION CONTROLLING VALUES
C  THAT HAVE NOT BEEN SET USING THE KEYWORDS --- SDIMAX, BAMAX.
C
C  IT IS ALSO USED TO SET DEFAULTS WHICH ARE DEPENDENT ON FOREST CODE
C  WITHIN A VARIANT.
C----------
C
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
      INCLUDE 'CICOM.F77'
C
C
      INCLUDE 'VOLSTD.F77'
C
C
COMMONS
C----------
      CHARACTER FORST*2,DIST*2,PROD*2,VAR*2,VOLEQ*11
      INTEGER IFIASP,ERRFLAG,ISPC,I,INTFOR,IREGN,J,JJ,K
      REAL BAMAXA(130),SLO,SHI,TEM,SLOSSP,SHISSP
      REAL R4SDI(MAXSP)
C----------
C     SPECIES LIST FOR CENTRAL IDAHO VARIANT.
C
C     1 = WESTERN WHITE PINE (WP)          PINUS MONTICOLA
C     2 = WESTERN LARCH (WL)               LARIX OCCIDENTALIS
C     3 = DOUGLAS-FIR (DF)                 PSEUDOTSUGA MENZIESII
C     4 = GRAND FIR (GF)                   ABIES GRANDIS
C     5 = WESTERN HEMLOCK (WH)             TSUGA HETEROPHYLLA
C     6 = WESTERN REDCEDAR (RC)            THUJA PLICATA
C     7 = LODGEPOLE PINE (LP)              PINUS CONTORTA
C     8 = ENGLEMANN SPRUCE (ES)            PICEA ENGELMANNII
C     9 = SUBALPINE FIR (AF)               ABIES LASIOCARPA
C    10 = PONDEROSA PINE (PP)              PINUS PONDEROSA
C    11 = WHITEBARK PINE (WB)              PINUS ALBICAULIS
C    12 = PACIFIC YEW (PY)                 TAXUS BREVIFOLIA
C    13 = QUAKING ASPEN (AS)               POPULUS TREMULOIDES
C    14 = WESTERN JUNIPER (WJ)             JUNIPERUS OCCIDENTALIS
C    15 = CURLLEAF MOUNTAIN-MAHOGANY (MC)  CERCOCARPUS LEDIFOLIUS
C    16 = LIMBER PINE (LM)                 PINUS FLEXILIS
C    17 = BLACK COTTONWOOD (CW)            POPULUS BALSAMIFERA VAR. TRICHOCARPA
C    18 = OTHER SOFTWOODS (OS)
C    19 = OTHER HARDWOODS (OH)
C
C  SURROGATE EQUATION ASSIGNMENT:
C
C  FROM THE IE VARIANT:
C      USE 17(PY) FOR 12(PY)             (IE17 IS REALLY TT2=LM)
C      USE 18(AS) FOR 13(AS)             (IE18 IS REALLY UT6=AS)
C      USE 13(LM) FOR 11(WB) AND 16(LM)  (IE13 IS REALLY TT2=LM)
C      USE 19(CO) FOR 17(CW) AND 19(OH)  (IE19 IS REALLY CR38=OH)
C
C  FROM THE UT VARIANT:
C      USE 12(WJ) FOR 14(WJ)
C      USE 20(MC) FOR 15(MC)             (UT20 = SO30=MC, WHICH IS
C                                                  REALLY WC39=OT)
C----------
C  DATA STATEMENTS
C----------
      DATA BAMAXA/
     &  7*100., 130., 3*95., 220., 213., 140., 175., 154., 137.,
     &  122., 152., 100., 2*220., 233., 220., 175., 250., 2*190.,
     &  226., 140., 200., 210., 140., 160., 200., 160., 200., 160.,
     &  180., 160., 4*200., 160., 225., 2*160., 2*170., 215., 210.,
     &  225., 210., 220., 300., 225., 350., 280., 225., 280., 342.,
     &  200., 230., 282., 350., 280., 300., 280., 150., 253., 2*242.,
     &  250., 275., 225., 300., 220., 270., 220., 2*225., 2*250.,
     &  150., 230., 140., 175., 240., 140., 210., 200., 250., 230.,
     &  200., 170., 200., 170., 160., 230., 220., 160., 2*200., 2*180.,
     &  190., 120., 140., 156., 120., 210., 140., 160., 214., 130.,
     &  154., 120., 300., 2*130., 200., 100., 75., 2*100., 110.,
     &  3*150./
      DATA R4SDI/
     &  529.,423.,570.,562.,682.,762.,679.,620.,602.,446.,621.,
     &  576.,562.,272.,501.,409.,452.,409.,452./
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
      IF(TEM .LT. SLOSSP)TEM=SLOSSP
C----------
C  GET THE APPROPRIATE SITE INDEX RANGE VALUES FOR THIS SPECIES.
C----------
        SLO = 0.
        SHI = 999.
        CALL SITERANGE (1,I,SLO,SHI)
C
      IF(SITEAR(I) .LE. 0.0) SITEAR(I) = SLO +
     & (TEM-SLOSSP)/(SHISSP-SLOSSP)
     & *(SHI-SLO)
   10 CONTINUE
C----------
C  SET METHB & METHC DEFAULTS.  DEFAULTS ARE INITIALIZED TO 999 IN
C  **GRINIT**.  IF THEY HAVE A DIFFERENT VALUE NOW, THEY WERE CHANGED
C  BY KEYWORD IN INITRE. ONLY CHANGE THOSE NOT SET BY KEYWORD.
C
C  NEZ PERCE (IFOR=1) IS A REGION 1 FOREST. ALL OTHERS FORESTS IN THIS
C  VARIANT ARE IN REGION 4.
C----------
      DO 50 ISPC=1,MAXSP
      IF(IFOR.EQ.1)THEN
        IF(METHB(ISPC).EQ.999)METHB(ISPC)=6
        IF(METHC(ISPC).EQ.999)METHC(ISPC)=6
      ELSE
        IF(METHB(ISPC).EQ.999)METHB(ISPC)=6
        IF(METHC(ISPC).EQ.999)METHC(ISPC)=6
      ENDIF
   50 CONTINUE
C----------
C  SET SDIDEF AND BAMAX VALUES WHICH HAVE NOT BEEN SET BY KEYWORD.
C  If a user sets BAMAX, then set the SDI maximums by species with this equation:
C     SDIDEF(I)=BAMAX/(0.5454154*(PMSDIU/100.))
C  If a user hasn�t set BAMAX, then set SDI maximums based on region. 
C  If in R1 (ifor eq 1), then set the SDI maximums by species based on habitat type: 
C          BAMAX=BAMAXA(ICINDX)
C          SDIDEF(I)=BAMAX/(0.5454154*(PMSDIU/100.)) 
C  Or
C          SDIDEF(I)= BAMAXA(ICINDX)/(0.5454154*(PMSDIU/100.))
C
C  If in R4, then set SDI maximums by species based on R4SDI values and
C     change the calculation method to zeide if not set by the user:
C         IF(CALCSDI.EQ.' ')LZEIDE = .TRUE.
C          SDIDEF(I) = R4SDI(I)
C----------
      IF(CALCSDI.EQ.' ' .AND. IFOR .LT. 2) LZEIDE = .FALSE.
      IF (BAMAX .GT. 0.0) THEN
        DO I=1,MAXSP
          IF(SDIDEF(I).LE.0.)
     &      SDIDEF(I)=BAMAX/(0.5454154*(PMSDIU/100.))
        ENDDO
      ELSE
        BAMAX=BAMAXA(ICINDX)
        DO I=1,MAXSP
          IF(IFOR .LT. 2) THEN
            IF(SDIDEF(I).LE.0.)
     &        SDIDEF(I)=BAMAX/(0.5454154*(PMSDIU/100.))
          ELSE
            IF(SDIDEF(I).LE.0.) SDIDEF(I)=R4SDI(I)
          ENDIF
        ENDDO
      ENDIF          
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
      VAR='CI'
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

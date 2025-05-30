        SUBROUTINE FVSVOL
        USE MRULES_MOD
        IMPLICIT NONE
C----------
C VVOLUME $Id$
C----------
C
C  THIS SUBROUTINE CALLS THE VOLINIT ROUTINE TO ACCESS THE
C  THE NATIONAL CRUISE SYSTEM VOLUME LIBRARY FOR METHB OR METHC
C  EQUAL TO 5 (GEVORKIANTZ) OR 6. IT ALSO CONTAINS ENTRY POINTS
C  AT THE END FOR OTHER VARIANT-SPECIFIC SPECIAL VOLUME
C  CALCULATION METHODZ (METHB OR METHC = 8)
C----------
COMMONS
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'ARRAYS.F77'
      INCLUDE 'COEFFS.F77'
      INCLUDE 'CONTRL.F77'
      INCLUDE 'PLOT.F77'
      INCLUDE 'VOLSTD.F77'

      COMMON/FVSVOLCOM/IREGN,FORST,VOLEQ,MTOPP,MTOPS,PROD
C
COMMONS
C----------
      CHARACTER*1 BFTOP,CFTOP,CTYPE,HTTYPE,LIVEDUM
      CHARACTER*2 FORST,PROD
      CHARACTER*4 CONSPEC,FIASP
      CHARACTER*11 EQNC,EQNB,VOLEQ
      INTEGER CUTFLG,BFPFLG,CUPFLG,CDPFLG,SPFLG
      INTEGER IT,ITRNC,ISPC,INTFOR,IERR,IZERO,FIASPCD
      INTEGER I1,IREGN,IFC
      INTEGER I,II,I3,I7,I15,I20,I21,I01,I02
      INTEGER ITD,BADUM,SIDUM,HTTDUM,IDIST,TLOGS
      INTEGER HTLOG,HTREF
      REAL VMAX,BARK,BRATIO,H,D,BBF,BBFV,BV,VM,VN,VVN
      REAL FC,DBTBH,TVOL1,TVOL2,TVOL4,TVOL7,TDIBB,TDIBC
      REAL NOLOGP,NOLOGS
      REAL BOLHT(21),LOGLEN(20),TVOL(15)
      REAL HT1PRD,HT2PRD,MTOPP,MTOPS,STUMP,TOPDIAM
      REAL XTOPD,HTC1,HTC2
      REAL DRCOB,UPSHT1,UPSHT2,UPSD1,UPSD2,AVGZ1,AVGZ2,CLMSTOP
      LOGICAL TKILL,CTKFLG,BTKFLG,LCONE,DEBUG
C----- New Variables added for 03/2023 Version of NVEL
      INTEGER CRATIO, CULL, DECAYCD, MRULFLG, BRKHT, BRKTD
      REAL    BIODRY(15), BIOGRN(15)
      TYPE(MERCHRULES)::MERRLS

C----------
C  NATIONAL CRUISE SYSTEM ROUTINES (METHOD = 6)
C----------
      ENTRY NATCRS (VN,VM,BBFV,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,
     1              CTKFLG,BTKFLG,IT)
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------

      CRATIO = 0
      CULL = 0
      DECAYCD = 0
      MRULFLG = 0
      BRKHT = 0
      BRKTD = 0
      CLMSTOP = 0

      CALL DBCHK (DEBUG,'FVSVOL',6,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC,IFOR
    3 FORMAT(' ENTERING SUBROUTINE FVSVOL CYCLE,IFOR =',I5,i4)
      IF(DEBUG)WRITE(JOSTND,*)' ENTERING NATCRS ISPC,D,H,TKILL,BARK,',
     &'ITRNC,CTKFLG,BTKFLG,IT= ',ISPC,D,H,TKILL,BARK,ITRNC,CTKFLG,
     & BTKFLG,IT

      READ(FIAJSP(ISPC), '(I4)')FIASPCD

      IDIST=1
      IF(KODFOR.GT.10000)THEN
        IREGN = KODFOR/10000
        INTFOR=KODFOR/100-IREGN*100
      ELSE
        IREGN = KODFOR/100
        INTFOR = KODFOR - (KODFOR/100)*100
      ENDIF

      IF(VARACD.EQ.'PN' .OR. VARACD.EQ.'OP')THEN
        IF(IREGN.EQ.8)THEN
          IREGN=6
          INTFOR=9
        ENDIF
      ELSEIF(VARACD.EQ.'NC')THEN
        IF(IREGN.EQ.8)THEN
          IREGN=5
          INTFOR=10
        ENDIF
      ELSEIF(VARACD.EQ.'SO')THEN
        IF(IREGN.EQ.7)THEN
          SELECT CASE (KODFOR)
          CASE (701)
            IREGN=5
            INTFOR=5
          CASE (799)
            IREGN=6
            INTFOR=1
          END SELECT
        ENDIF
      ENDIF
      
      IF(VARACD.EQ.'SN')IDIST=KODFOR-(KODFOR/100)*100

      WRITE(FORST,'(I2)')INTFOR
      IF(INTFOR.LT.10)FORST(1:1)='0'
      WRITE(FIASP,('(A)'))JSP(ISPC)
      HTTYPE='F'
      IERR=0
      DBTBH = D*(1-BARK)
      IF(DEBUG)WRITE(JOSTND,*)' INTFOR, IREGN= ',INTFOR, IREGN
      DO 100 IZERO=1,15
      TVOL(IZERO)=0.
      BIODRY(IZERO)=0.
      BIOGRN(IZERO)=0.
  100 CONTINUE
C
C  REGION 9 INPUTS OUTSIDE-BARK TOP DIAMETERS TO VOLINIT
C  REGION 8 DOES NOT CARE, TOP DIAMETERS ARE HARD WIRED
C  WESTERN VARIANTS INPUT INSIDE-BARK TOP DIAMETERS 
C  MTOPP (primary product - BdFt, Sawlog)
C  MTOPS (secondary product - Cuft, Pulpwood)
C
      IF((IREGN.EQ.8).OR.(IREGN.EQ.9))THEN
        MTOPP=BFTOPD(ISPC)
        MTOPS=TOPD(ISPC)
      ELSE
        MTOPP=BFTOPD(ISPC)*BARK
        MTOPS=TOPD(ISPC)*BARK
      ENDIF
C----------
C  CALL TO VOLUME INTERFACE - VOLINIT - CUBIC VOLUMES
C  INITIALIZE CONSTANT ARGUMENTS, AND VARIABLES
C----------
      IF(DEBUG) WRITE(JOSTND,*)
     &  'IREGN,ISPC,D,BFMIND,DBHMIN,MTOPP,MTOPS = ',
     &  IREGN,ISPC,D,BFMIND(ISPC),DBHMIN(ISPC),MTOPP,MTOPS
     
      IF(D.LT.DBHMIN(ISPC))THEN
C
C       Tree DBH does not meet min merch for Pulp/CuFT or Saw/BdFt
C
        TVOL(1)=0.
        TVOL(4)=0.
        TVOL(7)=0.
        BBFV=0.
C
C       EASTERN VARIANTS DO NOT NEED TOTAL VOLUME SO GO TO NEXT TREE
C       FOR WESTERN VARIANTS CALCULATE TOTAL CUBIC FOR ALL TREES
C
        IF(IREGN.EQ.8 .OR. IREGN.EQ.9) GO TO 500
      ENDIF

      VOLEQ=VEQNNC(ISPC)
      STUMP=STMP(ISPC)
      PROD='02'

C     Setting top diameter spec for calculating height to diameter for
C     Merch CuFt.
C     Region 5 uses inside bark diameter,
C     Region 9 computes a saw timber CuFt, VOL(4),
C     other regions need top diameter set at secondary product for this
C     step of process. That is why TOPDIAM for Region 9 is set to MTOPP
C     here which is the saw timber spec instead of typical CuFt spec, MTOPS.
C
      IF(IREGN.EQ.5) THEN
        TOPDIAM=TOPD(ISPC)*BARK
      ELSE
        TOPDIAM=MTOPS
      ENDIF

      DBTBH = D*(1-BARK)

      IF((IREGN.EQ.9 .OR. IREGN.EQ.8) .AND. D.GE.BFMIND(ISPC))THEN
        STUMP=BFSTMP(ISPC)
        TOPDIAM=MTOPP
        PROD='01'
      ENDIF
C
C       Tree DBH meets min merch for Pulp/CuFT only
C

C      I1=0     ! no longer in use a.o. 10/28/2022 to prevent address space pollution
      I3=3      ! second dimension of LOGDIA(,x) array
      I7=7      ! first dimension of LOGVOL(x,) array
      I15=15    ! Dimension of VOL(x) array
      I20=20    ! second dimension of LOGVOL(,x) array, dimension of LOGLEN(x)
      I21=21    ! first dimension of LOGDIA(x,) array, dimension of BOLHT(x)

C     Initialize independant volinit variables to prevent shared address space
      HTLOG = 0 ! Replaces I1 in position 11 of volinit call
      HTREF = 0 ! Replaces I1 in position 18 of volinit call

      DRCOB = 0.  ! Replaces X1 in position 08 of volinit call
      UPSHT1 = 0. ! Replaces X1 in position 14 of volinit call
      UPSHT2 = 0. ! Replaces X1 in position 15 of volinit call
      UPSD1 = 0.  ! Replaces X1 in position 16 of volinit call
      UPSD2 = 0.  ! Replaces X1 in position 17 of volinit call
      AVGZ1 = 0.  ! Replaces X1 in position 19 of volinit call
      AVGZ2 = 0.  ! Replaces X1 in position 20 of volinit call

C     INITIALIZE ARRAYS LOADED BY VOLUME ROUTINES (NVEL)
C     DIMENSIONS BASED ON VARIABLES SET DIRECTLY ABOVE
      DO I=1,I21
        DO II=1,I3
          LOGDIA(I,II)=0.0
        ENDDO
        BOLHT(I)=0.0
      ENDDO
      DO I=1,I20
        DO II=1,I7
          LOGVOL(II,I)=0.0
        ENDDO
        LOGLEN(I)=0.0
      ENDDO

C----------
C  CONSTANT CHARACTER ARGUMENTS
C----------
      CTYPE='F'
C----------
C  PRODUCT FLAGS
C----------
C  TOAL CUBIC
      CUTFLG=1
C  BF
      BFPFLG=1
C  MERCH CUBIC
      CUPFLG=1
C  CORDWOOD
      CDPFLG=1
C  SECONDARY PRODUCT
      SPFLG=1
C----------
C  GET FORM CLASS FOR THIS TREE.
C----------
      CALL FORMCL(ISPC,IFOR,D,FC)
      IFC=IFIX(FC)
C
C  THE NVEL USES FORMCLASS TO PASS NUMBER OF STEMS FOR
C  R3 WOODLAND SPECIES, IF DVE EQ.NO. SET IFC TO ZERO
C   
      IF((VOLEQ(4:6).EQ.'DVE').OR.(VOLEQ(4:6).EQ.'dve'))IFC=0
      IF(DEBUG)WRITE(JOSTND,*)' ISPC,INTFOR,D,FC,IFC= ',
     &ISPC,INTFOR,D,FC,IFC

      TLOGS = 0
      NOLOGP = 0.
      NOLOGS = 0.
      HT1PRD=0.
      HT2PRD=0.
      IERR=0
      SIDUM=0
      BADUM=0
      HTTDUM=0
      LIVEDUM=' '
      CONSPEC='    '

      IF(DEBUG)WRITE(JOSTND,*)
     & 'CALLING VOLINIT CF ISPC,IREGN,FORST,VOLEQ = ',
     &                      ISPC,IREGN,FORST,VOLEQ
      IF(DEBUG)WRITE(JOSTND,*)
     & '  TOPDIAM,MTOPS,STUMP,D,DRCOB,HTTYPE,H,I1 = ',
     &    TOPDIAM,MTOPS,STUMP,D,DRCOB,HTTYPE,H,I1
      IF(DEBUG)WRITE(JOSTND,*)'  HT1PRD,HT2PRD,IFC,DBTBH,BARK = ',
     &                           HT1PRD,HT2PRD,IFC,DBTBH,BARK
      IF(DEBUG)WRITE(JOSTND,*)'  CUTFLG,BFPFLG,CUPFLG,CDPFLG,SPFLG = ',
     &                           CUTFLG,BFPFLG,CUPFLG,CDPFLG,SPFLG
      IF(DEBUG)WRITE(JOSTND,*)
     & '  CONSPEC=',CONSPEC,' PROD=',PROD,' HTTDUM=',HTTDUM,
     & ' LIVEDUM=',LIVEDUM,' BADUM=',BADUM,' SIDUM= ',SIDUM
      IF(DEBUG)WRITE(JOSTND,*)'  CTYPE,IERR,IDIST = ',
     &                           CTYPE,IERR,IDIST

C     It does not appear that the secondary product top diameter MTOPS,
C     5th argument, functions. So it is used in primary product position on
C     this call to compute the height to merch cubic top diameter. Region 5
C     is a special case and so TOPDIAM is set above.

C      CALL VOLINIT(IREGN,FORST,VOLEQ,TOPDIAM,MTOPS,STUMP,
C     & D,DRCOB,HTTYPE,H,HTLOG,HT1PRD,HT2PRD,UPSHT1,UPSHT2,UPSD1,UPSD2,
C     & HTREF,AVGZ1,AVGZ2,IFC,
C     & DBTBH,BARK*100.,I3,I7,I15,I20,I21,TVOL,LOGVOL,LOGDIA,LOGLEN,
C     & BOLHT,TLOGS,NOLOGP,NOLOGS,CUTFLG,BFPFLG,CUPFLG,CDPFLG,
C    & SPFLG,CONSPEC,PROD,HTTDUM,LIVEDUM,
C     & BADUM,SIDUM,CTYPE,IERR,IDIST)

      CALL VOLINITNVB(IREGN,FORST,VOLEQ,TOPDIAM,MTOPS,STUMP,D,
     +   DRCOB,HTTYPE,H,HTLOG,HT1PRD,HT2PRD,UPSHT1,UPSHT2,UPSD1,
     +   UPSD2,HTREF,AVGZ1,AVGZ2,IFC,DBTBH,BARK*100,CRATIO,CULL,DECAYCD,
     +   TVOL,LOGVOL,LOGDIA,LOGLEN,BOLHT,TLOGS,NOLOGP,NOLOGS,CUTFLG,
     +   BFPFLG,CUPFLG,CDPFLG,SPFLG,CONSPEC,PROD,HTTDUM,LIVEDUM,
     +   BADUM,SIDUM,CTYPE,IERR,IDIST,BRKHT,BRKTD,FIASPCD,BIODRY,
     +   BIOGRN,MRULFLG,MERRLS,CLMSTOP)
C
      IF(DEBUG)WRITE(JOSTND,*)
     & 'AFTER VOLINIT CF IERR,PROD,HT1PRD,HT2PRD = ',
     &                   IERR,PROD,HT1PRD,HT2PRD
      IF(DEBUG)WRITE(JOSTND,*)'   TVOL = ',TVOL
      IF(DEBUG)WRITE(JOSTND,*)'   LOGVOL= ',LOGVOL
      IF(DEBUG)WRITE(JOSTND,*)'   LOGDIA= ',LOGDIA
      IF(DEBUG)WRITE(JOSTND,*)'   LOGLEN= ',LOGLEN
      IF(DEBUG)WRITE(JOSTND,*)'   BOLHT,TLOGS,NOLOGP,NOLOGS= ',
     &                            BOLHT,TLOGS,NOLOGP,NOLOGS

C----------
C  STORE CALCULATED MERCH CUBIC HEIGHT
C                               West     East
C  Primary product (HT1PRD):    BdFt     Sawlog
C  Secondary Product (HT2PRD):  CuFt     Pulpwood
C
C  While working on this routine 5/24/2017, using default volume equation 
C  assignments, Region 9 (Variants CS, LS, NE) is the only one that
C  returns value in HT2PRD, others are captured from HT1PRD with the
C  merch CuFt top diameter set for primary product (volinit 4th argument).
C----------
C  Old R8, pulpwood process no longer needed, need to store pulp ht here
C    -DW August 2022
C----------
      IF(D.GE.BFMIND(ISPC))THEN
        IF(IT.GT.0)HT2TD(IT,1)=HT1PRD
C     Region 8 requires at least 10 feet of product from the tree 
C     for the tree volume to be included.
        IF((IREGN.EQ.8).AND.(HT1PRD.LT.10.))THEN
          TVOL(4)=0.
          TVOL(2)=0.
        ENDIF  
      ENDIF        
      IF(D.GE.DBHMIN(ISPC))THEN
        IF(IT.GT.0) THEN
          IF (IREGN.EQ.9 .OR. IREGN.EQ.8) THEN
            HT2TD(IT,2)=HT2PRD
          ELSE
            HT2TD(IT,2)=HT1PRD
          ENDIF
        ENDIF
      ENDIF



C----------
C  END OF CF SECTION
C----------

C  IF THE BF VOLUME EQUATION IS DIFFERENT THAN THE CF VOLUME EQ OR
C  THE TOP DIAMETER SPECIFICATION FOR THE CUFT AND BDFT PRODUCTS
C  ARE DIFFERENT, THEN STORE CUBIC VOLUMES AND CALL  VOLINIT AGAIN
C  TO CALCULATE BF VOLUMES ONLY
C----------
      IF((VEQNNB(ISPC).NE.VEQNNC(ISPC)).OR.(IREGN.EQ.5)
     &  .OR. ((MTOPP.NE.MTOPS) .AND. (IREGN.NE.9 .AND. IREGN.NE.8)))THEN
        TVOL1=TVOL(1)
        TVOL4=TVOL(4)
        TVOL7=TVOL(7)
        VOLEQ=VEQNNB(ISPC)

C       Region 8 Clark equation needs saw timber top diameter spec 
C       inserted into equation identification.
        IF(IREGN.EQ.8 .AND. VOLEQ(4:6).EQ.'CLK')THEN
          WRITE(BFTOP,'(I1)')NINT(BFTOPD(ISPC))
          VOLEQ(3:3)=BFTOP
        ENDIF
        DO IZERO=1,15
        TVOL(IZERO)=0.
        ENDDO

        STUMP=BFSTMP(ISPC)
        PROD='01'
C       I1=0 ! no longer in use a.o. 10/28/2022 to prevent address space pollution
        I3=3
        I7=7
        I15=15
        I20=20
        I21=21

C     Initialize independant volinit variables to prevent shared address space
      HTLOG = 0 ! Replaces I1 in position 11 of volinit call
      HTREF = 0 ! Replaces I1 in position 18 of volinit call

      DRCOB = 0.  ! Replaces X1 in position 08 of volinit call
      UPSHT1 = 0. ! Replaces X1 in position 14 of volinit call
      UPSHT2 = 0. ! Replaces X1 in position 15 of volinit call
      UPSD1 = 0.  ! Replaces X1 in position 16 of volinit call
      UPSD2 = 0.  ! Replaces X1 in position 17 of volinit call
      AVGZ1 = 0.  ! Replaces X1 in position 19 of volinit call
      AVGZ2 = 0.  ! Replaces X1 in position 20 of volinit call
C----------
C  CONSTANT CHARACTER ARGUMENTS
C----------
        CTYPE='F'
C----------
C  PRODUCT FLAGS
C----------
C  TOAL CUBIC
        CUTFLG=0
C  BF
        BFPFLG=1
C  MERCH CUBIC
        CUPFLG=0
C  CORDWOOD
        CDPFLG=0
C  SECONDARY PRODUCT
        SPFLG=0
C  CONSTANTS
        TLOGS = 0
        NOLOGP = 0.
        NOLOGS = 0.
        IF((IREGN.NE.8)
     &     .AND.(VOLEQ(4:6).NE.'DVE'))THEN
          HT1PRD=0.
          HT2PRD=0.
        ENDIF
        IF((IREGN.EQ.8).AND.(VOLEQ(4:6).EQ.'CLK'))THEN
          HT1PRD=0.
          HT2PRD=0.
        ENDIF
        IERR=0
        SIDUM=0
        BADUM=0
        HTTDUM=0
        LIVEDUM=' '
        CONSPEC='   '

        IF(IREGN.EQ.5)MTOPP=BFTOPD(ISPC)*BARK

      DBTBH = D*(1-BARK)

      IF(DEBUG)WRITE(JOSTND,*)
     & 'CALLING VOLINIT BF ISPC,IREGN,FORST,VOLEQ = ',
     &                      ISPC,IREGN,FORST,VOLEQ
      IF(DEBUG)WRITE(JOSTND,*)
     & '  MTOPP,MTOPS,STUMP,D,DRCOB,HTTYPE,H,I1 = ',
     &    MTOPP,MTOPS,STUMP,D,DRCOB,HTTYPE,H,I1
      IF(DEBUG)WRITE(JOSTND,*)'  HT1PRD,HT2PRD,IFC,DBTBH,BARK = ',
     &                           HT1PRD,HT2PRD,IFC,DBTBH,BARK
      IF(DEBUG)WRITE(JOSTND,*)'  CUTFLG,BFPFLG,CUPFLG,CDPFLG,SPFLG = ',
     &                           CUTFLG,BFPFLG,CUPFLG,CDPFLG,SPFLG
      IF(DEBUG)WRITE(JOSTND,*)
     & '  CONSPEC=',CONSPEC,' PROD=',PROD,' HTTDUM=',HTTDUM,
     & ' LIVEDUM=',LIVEDUM,' BADUM=',BADUM,' SIDUM= ',SIDUM
      IF(DEBUG)WRITE(JOSTND,*)'  CTYPE,IERR,IDIST = ',
     &                           CTYPE,IERR,IDIST

        CALL VOLINITNVB(IREGN,FORST,VOLEQ,MTOPP,MTOPS,STUMP,D,
     +   DRCOB,HTTYPE,H,HTLOG,HT1PRD,HT2PRD,UPSHT1,UPSHT2,UPSD1,
     +   UPSD2,HTREF,AVGZ1,AVGZ2,IFC,DBTBH,BARK*100,CRATIO,CULL,DECAYCD,
     +   TVOL,LOGVOL,LOGDIA,LOGLEN,BOLHT,TLOGS,NOLOGP,NOLOGS,CUTFLG,
     +   BFPFLG,CUPFLG,CDPFLG,SPFLG,CONSPEC,PROD,HTTDUM,LIVEDUM,
     +   BADUM,SIDUM,CTYPE,IERR,IDIST,BRKHT,BRKTD,FIASPCD,BIODRY,
     +   BIOGRN,MRULFLG,MERRLS,CLMSTOP)

      IF(DEBUG)WRITE(JOSTND,*)
     & 'AFTER VOLINIT BF IERR,PROD,HT1PRD,HT2PRD= ',
     &                   IERR,PROD,HT1PRD,HT2PRD
      IF(DEBUG)WRITE(JOSTND,*)'   TVOL = ',TVOL
      IF(DEBUG)WRITE(JOSTND,*)'   LOGVOL= ',LOGVOL
      IF(DEBUG)WRITE(JOSTND,*)'   LOGDIA= ',LOGDIA
      IF(DEBUG)WRITE(JOSTND,*)'   LOGLEN= ',LOGLEN
      IF(DEBUG)WRITE(JOSTND,*)'   BOLHT,TLOGS,NOLOGP,NOLOGS= ',
     &                            BOLHT,TLOGS,NOLOGP,NOLOGS

        IF(D.GE.BFMIND(ISPC))THEN
          IF(IT.GT.0)HT2TD(IT,1)=HT1PRD
        ELSE
          IF(IT.GT.0)HT2TD(IT,1)=0.0
          TVOL(2)=0.0
        ENDIF
C
C  WHEN THERE IS NO CF VOL. EQ. NO. (E.G. CF METHC=2 OR 3, AND CFVOL
C  OR OCFVOL IS CALLED FROM VOLS, MUST SET VMAX SO TRUNCATED VOLUMES
C  ARE CALCULATED
C
        TVOL(1)=TVOL1
        TVOL(4)=TVOL4
        TVOL(7)=TVOL7
        IF((IREGN.EQ.8).AND.(HT1PRD.LT.10.))THEN
          TVOL(4)=0.
          TVOL(2)=0.
        ENDIF  
      ENDIF                   ! END OF BF SECTION
  500 CONTINUE
C----------
C  SET RETURN VALUES.
C----------
      IF((IREGN.EQ.8).OR.(IREGN.EQ.9))THEN
        IF(D.LT.BFMIND(ISPC))THEN
          VN=TVOL(4)
          VM=0.
        ELSE
          VN=TVOL(4)+TVOL(7)
          VM=TVOL(4)
        ENDIF
        IF(VN.LT.0.)VN=0.
        VMAX=VN
      ELSE                  ! ALL OTHER REGIONS
        VN=TVOL(1)
        IF(VN.LT.0.)VN=0.
        VMAX=VN
        IF(D .LT. DBHMIN(ISPC))THEN
          VM = 0.
        ELSE
          VM=TVOL(4)
          IF(VM.LT.0.)VM=0.
        ENDIF
      ENDIF

      IF(D.LT.BFMIND(ISPC))THEN
        BBFV=0.
      ELSE
        IF(METHB(ISPC).EQ.9) THEN
          BBFV=TVOL(10)
        ELSE
          BBFV=TVOL(2)
        ENDIF
        IF(BBFV.LT.0.)BBFV=0.
      ENDIF
      IF(DEBUG)WRITE(JOSTND,*)'  IN FVSVOL D, VN, VM, VMAX, BBFV = ',
     &                            D, VN, VM, VMAX, BBFV
      CTKFLG = .TRUE.
      BTKFLG = .TRUE.
      RETURN
C
C
C----------
C  ENTER ANY OTHER CUBIC HERE
C----------
      ENTRY OCFVOL (VN,VM,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,LCONE,
     &              CTKFLG,IT)
      CALL DBCHK (DEBUG,'FVSVOL',6,ICYC)
      IF(DEBUG) WRITE(JOSTND,13)ICYC,IFOR
   13 FORMAT(' ENTERING FVSVOL-OCFVOL CYCLE,IFOR =',I5,I4)
      IF(DEBUG)WRITE(JOSTND,*)'  ARGUMENTS: VN,VM,
     &ISPC,D,H,TKILL,BARK,ITRNC,VMAX,LCONE,CTKFLG,IT'
      IF(DEBUG)WRITE(JOSTND,*)'  OCFVOL IN:  ',
     & VN,VM,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,LCONE,CTKFLG,IT

      VVN=0.0
      BBF=0.0
C
      SELECT CASE (VARACD)
        CASE ('AK')
          CALL FVSBRUCEDEMARS(VN,VM,VMAX,D,H,ISPC,BARK,LCONE,CTKFLG)
C
        CASE ('CR')
          CALL FVSHANNBARE(VN,VM,VMAX,ISPC,D,H,CTKFLG)
C
        CASE ('NC')
          CALL FVSSIERRALOG(VN,VM,VMAX,ISPC,D,H,BARK,LCONE,CTKFLG)
C
        CASE ('CS','LS','NE')
          VN=0.
          VM=0.
          IF (IMC(IT) .GE. 3 .OR. D .LT. DBHMIN(ISPC))GOTO 600
          CALL TWIGCF(ISPC,H,D,VN,VM,IT)
  600     CONTINUE
C
        CASE DEFAULT
          VN=0.
          VMAX=0.
          VM=0.
          CTKFLG = .FALSE.
C
      END SELECT
C----------
C  SET RETURN VALUES HERE
C----------
      CTKFLG = .TRUE.
      IF(VN.LE.0.)THEN
        VN=0.
        CTKFLG = .FALSE.
      ENDIF
      IF(VM.LE.0.)THEN
        VM=0.
      ENDIF
      VMAX=VN
      IF(DEBUG)WRITE(JOSTND,*)'  OCFVOL OUT: ',
     & VN,VM,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,LCONE,CTKFLG,IT
      RETURN
C
C
C----------
C  ENTER ANY OTHER BOARD HERE.
C----------
      ENTRY OBFVOL (BBFV,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,LCONE,
     &              BTKFLG,IT)
      CALL DBCHK (DEBUG,'FVSVOL',6,ICYC)
      IF(DEBUG) WRITE(JOSTND,23)ICYC,IFOR
   23 FORMAT(' ENTERING FVSVOL-OBFVOL CYCLE,IFOR =',I5,I4)
      IF(DEBUG)WRITE(JOSTND,*)'  ARGUMENTS: ',
     &'BBFV,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,LCONE,BTKFLG,IT'
      IF(DEBUG)WRITE(JOSTND,*)'  OBFVOL IN:  ',
     & BBFV,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,LCONE,BTKFLG,IT
C
      SELECT CASE (VARACD)
        CASE ('AK')      
          VVN=0.0
          BBF=0.0
          IF(D .GE. 9.0 .AND. H .GT. 40.0)
     &    CALL FVSOLDGRO(ISPC,VVN,D,H,BBF)
          BBFV=BBF
C
        CASE ('CR')
          CALL HANNBAREBF(BBFV,ISPC,D,H,VMAX,BTKFLG)
C
        CASE ('NC')
          ITD=INT(BFTOPD(ISPC)+0.5)
          IF(ITD.GT.100) ITD = 100
          CALL LOGS(D,H,ITD,ITD,DBHMIN(ISPC),BFMIND(ISPC),ISPC,
     &            BFSTMP(ISPC),BV,JOSTND)
          BBFV=BV
C
        CASE ('CS','LS','NE')
          BBFV=0.
          IF(D .LT. BFMIND(ISPC) .OR. IMC(IT) .GT. 1)GOTO 700
          CALL TWIGBF(ISPC,H,D,VMAX,BBFV)
  700     CONTINUE
C
        CASE DEFAULT
          BBFV=0.
C
      END SELECT
C
      BTKFLG = .TRUE.
      IF(BBFV .LE. 0.) THEN
        BBFV=0.
        BTKFLG=.FALSE.
      ENDIF    
      IF(DEBUG)WRITE(JOSTND,*)'  OBFVOL OUT: ',
     & BBFV,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,LCONE,BTKFLG,IT
      RETURN
C
C
C----------
C  ENTRY POINT FOR SENDING VOLUME EQN NUMBER TO THE FVS-TO-NATCRZ ROUTINE
C----------
      ENTRY GETEQN(ISPC,D,H,EQNC,EQNB,TDIBC,TDIBB)
      CALL DBCHK (DEBUG,'FVSVOL',6,ICYC)
      IF(DEBUG) WRITE(JOSTND,33)ICYC,IFOR
   33 FORMAT(' ENTERING FVSVOL-GETEQN CYCLE,IFOR =',I5,I4)
      IF(DEBUG)WRITE(JOSTND,*)'  ARGUMENTS: ',
     &'ISPC,D,H,EQNC,EQNB,TDIBC,TDIBB'
      IF(DEBUG)WRITE(JOSTND,*)'  GETEQN IN:  ',
     & ISPC,D,H,EQNC,EQNB,TDIBC,TDIBB

      EQNC=VEQNNC(ISPC)
      EQNB=VEQNNB(ISPC)
      TDIBC=TOPD(ISPC)*BRATIO(ISPC,D,H)
      TDIBB=BFTOPD(ISPC)*BRATIO(ISPC,D,H)

      IF(DEBUG)WRITE(JOSTND,*)'  GETEQN OUT: ',
     & ISPC,D,H,EQNC,EQNB,TDIBC,TDIBB
      RETURN

      END

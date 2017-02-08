C     Last change:  BCM  28 Sep 99    2:46 pm
      SUBROUTINE getreg(Begsrs,Nobs,Havsrs,Havesp,Userx,Nrusrx,Bgusrx,
     &                  Itdtst,Leastr,Eastst,Luser,Elong,Adjtd,Adjao,
     &                  Adjls,Adjtc,Adjso,Adjhol,Adjsea,Adjcyc,Adjusr,
     &                  Nusrrg,Havtca,Rgaicd,Lam,Fcntyp,Havhol,Lomtst,
     &                  Ch2tst,Chi2cv,Tlimit,Pvaic,Inptok)
      IMPLICIT NONE
c-----------------------------------------------------------------------
c     getreg.f, Release 1, Subroutine Version 1.6, Modified 03 Feb 1995.
c-----------------------------------------------------------------------
c     Specify the regression and time series parts of the model
c-----------------------------------------------------------------------
c     Code added to incorporate automatic TD selection
c     BCM - January 1994
c-----------------------------------------------------------------------
      INCLUDE 'stdio.i'
      INCLUDE 'lex.i'
      INCLUDE 'notset.prm'
      INCLUDE 'srslen.prm'
      INCLUDE 'model.prm'
      INCLUDE 'model.cmn'
      INCLUDE 'mdldat.cmn'
      INCLUDE 'picktd.cmn'
      INCLUDE 'tbllog.i'
      INCLUDE 'svllog.i'
      INCLUDE 'usrreg.cmn'
      INCLUDE 'units.cmn'
      INCLUDE 'error.cmn'
c     ------------------------------------------------------------------
      DOUBLE PRECISION ONE,ZERO
      LOGICAL F,T
      PARAMETER(ONE=1D0,ZERO=0D0,F=.false.,T=.true.)
c     ------------------------------------------------------------------
      CHARACTER effttl*(PCOLCR),rgfile*(PFILCR),rgfmt*(PFILCR)
      LOGICAL argok,Havesp,havfmt,Havsrs,haveux,hvfile,hvstrt,hvuttl,
     &        Inptok,Elong,havtd,Havhol,havln,havlp,Luser,Havtca,
     &        lumean,luseas,fixvec,havcyc,herror,Ch2tst,Leastr
      INTEGER Bgusrx,Begsrs,i,j,k,idisp,itmpvc,nchr,nelt,nflchr,nfmtch,
     &        neltux,Nobs,Nrusrx,peltux,Itdtst,ivec,igrp,i2,n2,k2,ispn,
     &        Adjtd,Adjao,Adjls,Adjtc,Adjso,Adjhol,Adjsea,Adjcyc,Adjusr,
     &        Nusrrg,nbvec,icol,ic1,Fcntyp,begcol,endcol,Lomtst,iuhl,
     &        Eastst,ielt
      DOUBLE PRECISION Userx,dvec,Rgaicd,urmean,urnum,bvec,Lam,Chi2cv,
     &                 daicdf,Tlimit,Pvaic
      DIMENSION Bgusrx(2),Begsrs(2),itmpvc(0:1),Userx(*),ivec(1),
     &          dvec(1),urmean(PB),urnum(PB),ispn(2),fixvec(PB),
     &          bvec(PB),iuhl(PUHLGP),Rgaicd(PAICT),daicdf(PAICT)
c-----------------------------------------------------------------------
      INTEGER strinx
      LOGICAL chkcvr,gtarg,dpeq,istrue
      EXTERNAL strinx,chkcvr,gtarg,dpeq,istrue
c-----------------------------------------------------------------------
c     The spec dictionary was made with this command
c  ../../dictionary/strary < ../../dictionary/regression.dic
c-----------------------------------------------------------------------
      CHARACTER ARGDIC*138
      INTEGER argidx,argptr,PARG,arglog
      PARAMETER(PARG=21)
      DIMENSION argptr(0:PARG),arglog(2,PARG)
      PARAMETER(ARGDIC='variablesuserdatastartfileformatbprintsaveaictes
     &teastermeansnoapplyusertypetcrateaicdiffsavelogcenteruserchi2testc
     &hi2testcvtlimitpvaictest')
c-----------------------------------------------------------------------
      CHARACTER YSNDIC*5
      INTEGER ysnptr,PYSN
      PARAMETER(PYSN=2)
      DIMENSION ysnptr(0:PYSN)
      PARAMETER(YSNDIC='yesno')
c     ------------------------------------------------------------------
      CHARACTER AICDIC*82
      INTEGER aicidx,aicptr,PAIC
      PARAMETER(PAIC=12)
      DIMENSION aicptr(0:PAIC),aicidx(4)
      PARAMETER(AICDIC='tdtdnolpyeartdstocktd1coeftd1nolpyeartdstock1coe
     &feastereasterstockuserlomloqlpyear')
c-----------------------------------------------------------------------
      CHARACTER URGDIC*144
      INTEGER urgidx,urgptr,PURG
      PARAMETER(PURG=25)
      DIMENSION urgptr(0:PURG),urgidx(PUREG)
      PARAMETER(URGDIC='constantseasonaltdtdstocklomloqlpyearlomstockeas
     &tersceasterlaborthanksholidayholiday2holiday3holiday4holiday5aolsr
     &ptcsotransitoryeasterstockuser')
c     ------------------------------------------------------------------
      CHARACTER MDLDIC*33
      INTEGER mdlind,mdlptr,PMODEL
      PARAMETER(PMODEL=8)
      DIMENSION mdlptr(0:PMODEL),mdlind(PMODEL)
      PARAMETER(MDLDIC='tdaolsholidayuserseasonalusertcso')
c     ------------------------------------------------------------------
      CHARACTER URRDIC*12
      INTEGER urrptr,PURR
      PARAMETER(PURR=2)
      DIMENSION urrptr(0:PURR)
      PARAMETER(URRDIC='meanseasonal')
c     ------------------------------------------------------------------
      DATA argptr/1,10,14,18,23,27,33,34,39,43,50,61,68,76,82,89,96,106,
     &            114,124,130,139/
      DATA ysnptr/1,4,6/
      DATA aicptr/1,3,13,20,27,38,50,56,67,71,74,77,83/
      DATA urgptr/1,9,17,19,26,29,32,38,46,52,60,65,71,78,86,94,102,110,
     &            112,114,116,118,120,130,141,145/
      DATA mdlptr/1,3,5,7,14,26,30,32,34/
      DATA urrptr/1,5,13/
c-----------------------------------------------------------------------
c     Assume the input is OK and we don't have any of the arguments
c-----------------------------------------------------------------------
      peltux=PLEN*PUREG
      haveux=F
      hvuttl=F
      hvfile=F
      havfmt=F
      hvstrt=F
      nfmtch=1
      havtd=F
      Havhol=F
      havln=F
      havlp=F
      havcyc=F
      lumean=F
      luseas=F
      nbvec=NOTSET
      CALL setlg(F,PB,fixvec)
c-----------------------------------------------------------------------
      CALL setint(NOTSET,2*PARG,arglog)
      CALL setint(NOTSET,2,ispn)
      CALL setint(0,PUHLGP,iuhl)
c-----------------------------------------------------------------------
c     Initialize the format and file
c-----------------------------------------------------------------------
      CALL setchr(' ',PFILCR,rgfile)
      CALL setchr(' ',PFILCR,rgfmt)
c-----------------------------------------------------------------------
c     Argument get loop
c-----------------------------------------------------------------------
      DO WHILE (T)
       IF(gtarg(ARGDIC,argptr,PARG,argidx,arglog,Inptok))THEN
        IF(Lfatal)RETURN
        GO TO(10,20,30,40,50,60,70,80,90,100,110,120,130,150,160,170,
     &        140,180,190,191,192)argidx
c-----------------------------------------------------------------------
c     variables argument
c-----------------------------------------------------------------------
   10   CALL gtpdrg(Begsrs,Nobs,Havsrs,Havesp,F,havtd,Havhol,havln,
     &               havlp,argok,Inptok)
c        IF(.not.Lfatal.and.(Picktd.and.(Fcntyp.ne.4.and.
c     &    (.not.dpeq(Lam,1D0)))))
c     &    CALL rmlnvr(Priadj,Nobs)
        IF(Lfatal)RETURN
        GO TO 200
c-----------------------------------------------------------------------
c     Names and number of columns for the user regression variables
c-----------------------------------------------------------------------
   20   CALL gtnmvc(LPAREN,T,PUREG,Usrttl,Usrptr,Ncusrx,PCOLCR,argok,
     &              Inptok)
        IF(Lfatal)RETURN
        hvuttl=argok.and.Ncusrx.gt.0
        GO TO 200
c-----------------------------------------------------------------------
c     Data argument
c-----------------------------------------------------------------------
   30   IF(hvfile)CALL inpter(PERROR,Errpos,'Getting data from a file')
c     ------------------------------------------------------------------
        CALL gtdpvc(LPAREN,T,peltux,Userx,neltux,argok,Inptok)
        IF(Lfatal)RETURN
        haveux=argok.and.neltux.gt.0
        GO TO 200
c-----------------------------------------------------------------------
c     Start argument
c-----------------------------------------------------------------------
   40   CALL gtdtvc(Havesp,Sp,LPAREN,F,1,Bgusrx,nelt,argok,Inptok)
        IF(Lfatal)RETURN
        hvstrt=argok.and.nelt.gt.0
        GO TO 200
c-----------------------------------------------------------------------
c     File argument
c-----------------------------------------------------------------------
   50   IF(haveux)CALL inpter(PERROR,Errpos,
     &                        'Already have user regression')
        CALL gtnmvc(LPAREN,T,1,rgfile,itmpvc,neltux,PFILCR,argok,Inptok)
        IF(Lfatal)RETURN
c     ------------------------------------------------------------------
        IF(argok.and.neltux.gt.0)THEN
         CALL eltlen(1,itmpvc,neltux,nflchr)
         IF(Lfatal)RETURN
         hvfile=T
        END IF
        GO TO 200
c-----------------------------------------------------------------------
c     Format argument
c-----------------------------------------------------------------------
   60   CALL gtnmvc(LPAREN,T,1,rgfmt,itmpvc,nelt,PFILCR,argok,Inptok)
        IF(Lfatal)RETURN
        IF(argok)THEN
         nfmtch=itmpvc(1)-1
         havfmt=T
        END IF
        GO TO 200
c-----------------------------------------------------------------------
c     Initial values for the regression.  May want to change this
c later so that the betas only need take some initial values instead
c of all or none.
c-----------------------------------------------------------------------
   70   CALL gtrgvl(nbvec,fixvec,bvec,Inptok)
        IF(Lfatal)RETURN
        GO TO 200
c-----------------------------------------------------------------------
c     Print argument
c-----------------------------------------------------------------------
   80   CALL getprt(LSPREG,NSPREG,Inptok)
        GO TO 200
c-----------------------------------------------------------------------
c     Save argument
c-----------------------------------------------------------------------
   90   CALL getsav(LSPREG,NSPREG,Inptok)
        GO TO 200
c-----------------------------------------------------------------------
c     aictest argument
c-----------------------------------------------------------------------
  100   CALL gtdcvc(LPAREN,F,4,AICDIC,aicptr,PAIC,'Choices for aictest a
     &re td, tdnolpyear, tdstock, td1coef, td1nolpyear,',
     &              aicidx,nelt,argok,Inptok)
        IF(Lfatal)RETURN
        IF(.not.argok)THEN
         CALL writln('        tdstock, tdstock1coef, lom, loq, lpyear, e
     &aster, easterstock,',STDERR,Mt2,F)
         CALL writln('        and user.',STDERR,Mt2,F)
        END IF
        IF(argok)THEN
         DO i=1,nelt
          IF(aicidx(i).eq.7.or.aicidx(i).eq.8)THEN
           Leastr=T
           IF(Eastst.eq.0)THEN
            Eastst=aicidx(i)-6
           ELSE
            CALL inpter(PERROR,Errpos,
     &     'Can only specify one of easter and easterstock in aictest.')
            Inptok=F
           END IF
*           Havhol=T
          ELSE IF(aicidx(i).eq.9)THEN
           Luser=T
c-----------------------------------------------------------------------
c      input for Lomtst  (BCM March 2008)
c-----------------------------------------------------------------------
          ELSE IF(aicidx(i).gt.9)THEN
           IF(Lomtst.eq.0)THEN
            Lomtst=aicidx(i)-9
           ELSE
            CALL inpter(PERROR,Errpos,
     &        'Can only specify one of lom, loq, or lpyear in aictest.')
            Inptok=F
           END IF
          ELSE
           IF(Itdtst.eq.0)THEN
            Itdtst=aicidx(i)
*            havtd=T
           ELSE
            CALL inpter(PERROR,Errpos,
     &           'Can only specify one type of trading day in aictest.')
            Inptok=F
           END IF
          END IF
         END DO
         IF(Inptok)Iregfx=0
        END IF
        GO TO 200
c-----------------------------------------------------------------------
c     eastermeans argument
c-----------------------------------------------------------------------
  110   CALL gtdcvc(LPAREN,F,1,YSNDIC,ysnptr,PYSN,
     &              'Choices for eastermeans are yes and no.',
     &              ivec,nelt,argok,Inptok)
        IF(Lfatal)RETURN
        IF(argok.and.nelt.gt.0)Elong=ivec(1).eq.1
        GO TO 200
c-----------------------------------------------------------------------
c     noapply argument
c-----------------------------------------------------------------------
  120   CALL gtdcvc(LPAREN,T,PMODEL,MDLDIC,mdlptr,PMODEL,'Choices for th
     &e noapply argument are td, ao, ls, holiday, or user.',
     &              mdlind,nelt,argok,Inptok)
        IF(Lfatal)RETURN
c     ------------------------------------------------------------------
        IF(argok.and.nelt.gt.0)THEN
         DO i=1,nelt
          IF(mdlind(i).eq.1)THEN
           Adjtd=-1
          ELSE IF(mdlind(i).eq.2)THEN
           Adjao=-1
          ELSE IF(mdlind(i).eq.3)THEN
           Adjls=-1
          ELSE IF(mdlind(i).eq.4)THEN
           Adjhol=-1
          ELSE IF(mdlind(i).eq.5)THEN
           Adjsea=-1
          ELSE IF(mdlind(i).eq.6)THEN
           Adjusr=-1
          ELSE IF(mdlind(i).eq.7)THEN
           Adjtc=-1
          ELSE IF(mdlind(i).eq.8)THEN
           Adjso=-1
          END IF
         END DO
        END IF
        GO TO 200
c-----------------------------------------------------------------------
c     usertype argument
c-----------------------------------------------------------------------
  130   CALL gtdcvc(LPAREN,F,PUREG,URGDIC,urgptr,PURG,
     &              'Improper entry for usertype.  See '//SPCSEC//
     &              ' of '//DOCNAM//'.',urgidx,Nusrrg,argok,Inptok)
        IF(Lfatal)RETURN
c     ------------------------------------------------------------------
        IF(argok.and.Nusrrg.gt.0)THEN
         DO i=1,Nusrrg
          IF(urgidx(i).eq.1)THEN
           Usrtyp(i)=PRGTCN
          ELSE IF(urgidx(i).eq.2)THEN
           Usrtyp(i)=PRGTUS
          ELSE IF(urgidx(i).eq.3)THEN
           Usrtyp(i)=PRGTTD
           IF(.not.havtd)havtd=T
          ELSE IF(urgidx(i).eq.4)THEN
           Usrtyp(i)=PRGTST
           IF(.not.havtd)havtd=T
          ELSE IF(urgidx(i).eq.5)THEN
           Usrtyp(i)=PRGTLM
           IF(.not.havln)havln=T
          ELSE IF(urgidx(i).eq.6)THEN
           Usrtyp(i)=PRGTLQ
           IF(.not.havln)havln=T
          ELSE IF(urgidx(i).eq.7)THEN
           Usrtyp(i)=PRGTLY
           IF(.not.havlp)havlp=T
          ELSE IF(urgidx(i).eq.8)THEN
           Usrtyp(i)=PRGTSL
          ELSE IF(urgidx(i).eq.9)THEN
           Usrtyp(i)=PRGTEA
           Havhol=T
          ELSE IF(urgidx(i).eq.10)THEN
           Usrtyp(i)=PRGTEC
           Havhol=T
          ELSE IF(urgidx(i).eq.11)THEN
           Usrtyp(i)=PRGTLD
           Havhol=T
          ELSE IF(urgidx(i).eq.12)THEN
           Usrtyp(i)=PRGTTH
           Havhol=T
          ELSE IF(urgidx(i).ge.13.and.urgidx(i).le.17)THEN
           IF(.not.Havhol)Havhol=T
           IF(iuhl(urgidx(i)-12).eq.0)iuhl(urgidx(i)-12)=1
           IF(urgidx(i).eq.13)THEN
            Usrtyp(i)=PRGTUH
           ELSE IF(urgidx(i).eq.14)THEN
            Usrtyp(i)=PRGUH2
           ELSE IF(urgidx(i).eq.15)THEN
            Usrtyp(i)=PRGUH3
           ELSE IF(urgidx(i).eq.16)THEN
            Usrtyp(i)=PRGUH4
           ELSE IF(urgidx(i).eq.17)THEN
            Usrtyp(i)=PRGUH5
           END IF
          ELSE IF(urgidx(i).eq.18)THEN
           Usrtyp(i)=PRGTAO
          ELSE IF(urgidx(i).eq.19)THEN
           Usrtyp(i)=PRGTLS
          ELSE IF(urgidx(i).eq.20)THEN
           Usrtyp(i)=PRGTRP
          ELSE IF(urgidx(i).eq.21)THEN
           Usrtyp(i)=PRGTTC
          ELSE IF(urgidx(i).eq.22)THEN
           Usrtyp(i)=PRGTSO
          ELSE IF(urgidx(i).eq.23)THEN
           Usrtyp(i)=PRGCYC
           IF(.not.havcyc)havcyc=T
          ELSE IF(urgidx(i).eq.24)THEN
           Usrtyp(i)=PRGTES
           Havhol=T
          ELSE IF(urgidx(i).eq.25.or.urgidx(i).eq.NOTSET)THEN
           Usrtyp(i)=PRGTUD
          END IF
         END DO
        END IF
        GO TO 200
c-----------------------------------------------------------------------
c     centeruser argument
c-----------------------------------------------------------------------
  140   CALL gtdcvc(LPAREN,F,1,URRDIC,urrptr,PURR,
     &              'Choices for centeruser are mean and seasonal.',
     &              ivec,nelt,argok,Inptok)
        IF(Lfatal)RETURN
        IF(argok.and.nelt.gt.0)THEN
         lumean=ivec(1).eq.1
         luseas=ivec(1).eq.2
        END IF
        GO TO 200
c-----------------------------------------------------------------------
c     tcrate - alpha value for all TC outliers
c-----------------------------------------------------------------------
  150   IF(Havtca)THEN
         CALL inpter(PERROR,Errpos,'Cannot specify tcrate in both the re
     &gression and outlier specs')
         Inptok=F
        ELSE
  	   CALL gtdpvc(LPAREN,T,1,dvec,nelt,argok,Inptok)
         IF(Lfatal)RETURN
         IF(argok.and.nelt.gt.0)THEN
          IF(dvec(1).le.ZERO.or.dvec(1).ge.ONE)THEN
           CALL inpter(PERROR,Errpos,
     &                 'Value of tcrate must be between 0 and 1.')
           Inptok=F
          ELSE
           Tcalfa=dvec(1)
           Havtca=T
          END IF
         END IF
        END IF
        GO TO 200
c-----------------------------------------------------------------------
c     AIC test difference for the regression-based AIC test
c-----------------------------------------------------------------------
  160   CALL gtdpvc(LPAREN,F,PAICT,daicdf,nelt,argok,Inptok)
        IF(Lfatal)RETURN
        IF(argok)THEN
         IF(nelt.eq.1)THEN
          DO ielt=1,PAICT
           Rgaicd(ielt)=daicdf(1)
          END DO
         ELSE IF(nelt.gt.0)THEN
          DO ielt=1,PAICT
           IF(.not.dpeq(daicdf(ielt),DNOTST))Rgaicd(ielt)=daicdf(ielt)
          END DO
         END IF
        END IF
        GO TO 200
c-----------------------------------------------------------------------
c     savelog  argument
c-----------------------------------------------------------------------
  170   CALL getsvl(LSLREG,NSLREG,Inptok)
        GO TO 200
c-----------------------------------------------------------------------
c     chi2test argument
c-----------------------------------------------------------------------
  180   CALL gtdcvc(LPAREN,F,1,YSNDIC,ysnptr,PYSN,
     &              'Choices for chi2test are yes and no.',
     &              ivec,nelt,argok,Inptok)
        IF(Lfatal)RETURN
        IF(argok.and.nelt.gt.0)Ch2tst=ivec(1).eq.1
        GO TO 200
c-----------------------------------------------------------------------
c     chi2testcv argument
c-----------------------------------------------------------------------
  190   CALL gtdpvc(LPAREN,T,1,dvec,nelt,argok,Inptok)
        IF(Lfatal)RETURN
        IF(nelt.gt.0.and.argok)THEN
         IF(dvec(1).le.ZERO.or.dvec(1).ge.ONE)THEN
          CALL inpter(PERROR,Errpos,
     &                 'Value of chi2testcv must be between 0 and 1.')
          Inptok=F
         ELSE
          Chi2cv=dvec(1)
         END IF
        END IF
        GO TO 200
c-----------------------------------------------------------------------
c     tlimit argument
c-----------------------------------------------------------------------
  191   CALL gtdpvc(LPAREN,T,1,dvec,nelt,argok,Inptok)
        IF(Lfatal)RETURN
        IF(nelt.gt.0.and.argok)THEN
         IF(dvec(1).le.ZERO)THEN
          CALL inpter(PERROR,Errpos,
     &                 'Value of tlimit must be greater than 0.')
          Inptok=F
         ELSE
          Tlimit=dvec(1)
         END IF
        END IF
        GO TO 200
c-----------------------------------------------------------------------
c     pvaictest argument
c-----------------------------------------------------------------------
  192   CALL gtdpvc(LPAREN,T,1,dvec,nelt,argok,Inptok)
        IF(Lfatal)RETURN
        IF(nelt.gt.0.and.argok)THEN
         IF(dvec(1).le.ZERO)THEN
          CALL inpter(PERROR,Errpos,
     &                 'Value of pvaictest must be greater than 0.')
          Inptok=F
         ELSE IF(dvec(1).ge.ONE)THEN
          CALL inpter(PERROR,Errpos,
     &                 'Value of pvaictest must be less than 1.')
          Inptok=F
         ELSE
          Pvaic=ONE-dvec(1)
         END IF
        END IF
        GO TO 200
       END IF
c-----------------------------------------------------------------------
       IF(nbvec.ne.NOTSET)THEN
c-----------------------------------------------------------------------
c     Insert value for Leap Year regressor that will be removed
c-----------------------------------------------------------------------
        IF(Picktd.and.(Fcntyp.ne.4.and.(.not.dpeq(Lam,1D0))))THEN
         ic1=1
         icol=strinx(T,Colttl,Colptr,ic1,Nb,'Leap Year')
         DO WHILE (icol.gt.0)
          IF(icol.le.nbvec)THEN
           DO i=nbvec,icol,-1
            bvec(i+1)=bvec(i)
            fixvec(i+1)=fixvec(i)
           END DO
          END IF
          Bvec(icol)=ONE
          nbvec=nbvec+1
          IF(icol.eq.Nb)THEN
           icol=0
          ELSE
           ic1=icol+1
           icol=strinx(T,Colttl,Colptr,ic1,Nb,'Leap Year')
          END IF
         END DO
        END IF                                                                                                                                                                             
        IF(nbvec.gt.0.and.nbvec.NE.(Nb+Ncusrx))THEN
         WRITE(STDERR,1000)
         WRITE(Mt2,1000)
 1000    FORMAT(' ERROR: Number of initial values is not the same as ',
     &          'the number of regression',/,'        variables.')
        ELSE
         DO i=1,Nb+Ncusrx
          Regfx(i)=fixvec(i)
          B(i)=bvec(i)
         END DO
        END IF
       END IF
c     ------------------------------------------------------------------
c     If the data are from the file get the data
c-----------------------------------------------------------------------
       IF(Inptok.and.hvfile.and..not.haveux)THEN
        IF(Ncusrx.gt.0)THEN
         CALL gtfldt(peltux,rgfile,nflchr,havfmt,rgfmt(1:nfmtch),2,
     &               Userx,neltux,Havesp,Sp,F,' ',0,F,' ',0,0,hvstrt,
     &               Bgusrx,Ncusrx,ispn,ispn,T,haveux,Inptok)
        ELSE
         WRITE(STDERR,1010)
         WRITE(Mt2,1010)
        END IF
       END IF
c-----------------------------------------------------------------------
c     Check for the required arguments
c-----------------------------------------------------------------------
       IF(Inptok.and.(hvuttl.or.haveux))THEN
c-----------------------------------------------------------------------
c     check user-defined regression type selection.  First, check to 
c     see if user-defined regression variables are defined.
c-----------------------------------------------------------------------
        IF(Nusrrg.gt.0)THEN
c-----------------------------------------------------------------------
c     If only one type given, use it for all user-defined regression 
c     variables.
c-----------------------------------------------------------------------
         IF(Nusrrg.eq.1)THEN
          DO i=2,Ncusrx
           Usrtyp(i)=Usrtyp(1)
          END DO
         END IF
c-----------------------------------------------------------------------
c      Check to see if User-defined holiday groups are defined
c-----------------------------------------------------------------------
         CALL chkuhg(iuhl,Nguhl,herror)
         IF(herror)THEN
          WRITE(STDERR,1040)
          WRITE(Mt2,1040)
 1040     FORMAT(' ERROR: Cannot specify holiday group types for ',
     &           'user-defined regression',/,
     &           '        variables out of sequence.')
          Inptok=F
         END IF
        END IF
        IF(.not.(hvuttl.eqv.haveux))THEN
         WRITE(STDERR,1010)
         WRITE(Mt2,1010)
 1010    FORMAT(/,' ERROR: Need to specify both user-defined ',
     &            'regression variables (with user',/,
     &            '        argument) and X matrix (with file or data ',
     &            'argument).')
         Inptok=F
c     ------------------------------------------------------------------
        ELSE IF(mod(neltux,Ncusrx).ne.0)THEN
         WRITE(STDERR,1020)neltux,Ncusrx
         WRITE(Mt2,1020)neltux,Ncusrx
 1020    FORMAT(/,' ERROR: Number of user-defined X elements=',i4,
     &          /,'        not equal to a multiple of the number of ',
     &            'columns=',i3,'.',/)
         Inptok=F
c     ------------------------------------------------------------------
        ELSE
         IF(.not.hvstrt)CALL cpyint(Begsrs,2,1,Bgusrx)
         Nrusrx=neltux/Ncusrx
         IF(.not.chkcvr(Bgusrx,Nrusrx,Begspn,Nspobs,Sp))THEN
          CALL cvrerr('user-defined regression variables',Bgusrx,Nrusrx,
     &                'span of the data',Begspn,Nspobs,Sp)
          IF(Lfatal)RETURN
          Inptok=F
c     ------------------------------------------------------------------
         ELSE
          idisp=Grp(Ngrp)-1
          DO i=1,Ncusrx
           idisp=idisp+1
           CALL getstr(Usrttl,Usrptr,Ncusrx,i,effttl,nchr)
           IF(.not.Lfatal)THEN
            IF(Usrtyp(i).eq.PRGTUH)THEN
             CALL adrgef(B(idisp),effttl(1:nchr),'User-defined Holiday',
     &                   PRGTUH,Regfx(idisp),T)
            ELSE IF(Usrtyp(i).eq.PRGUH2)THEN
             CALL adrgef(B(idisp),effttl(1:nchr),
     &                   'User-defined Holiday Group 2',PRGUH2,
     &                   Regfx(idisp),T)
            ELSE IF(Usrtyp(i).eq.PRGUH3)THEN
             CALL adrgef(B(idisp),effttl(1:nchr),
     &                   'User-defined Holiday Group 3',PRGUH3,
     &                   Regfx(idisp),T)
            ELSE IF(Usrtyp(i).eq.PRGUH4)THEN
             CALL adrgef(B(idisp),effttl(1:nchr),
     &                   'User-defined Holiday Group 4',PRGUH4,
     &                   Regfx(idisp),T)
            ELSE IF(Usrtyp(i).eq.PRGUH5)THEN
             CALL adrgef(B(idisp),effttl(1:nchr),
     &                   'User-defined Holiday Group 5',PRGUH5,
     &                   Regfx(idisp),T)
            ELSE IF(Usrtyp(i).eq.PRGTUS)THEN
             CALL adrgef(B(idisp),effttl(1:nchr),
     &                   'User-defined Seasonal',PRGTUS,Regfx(idisp),T)
            ELSE
             CALL adrgef(B(idisp),effttl(1:nchr),'User-defined',PRGTUD,
     &                   Regfx(idisp),T)
            END IF
           END IF
           IF(Lfatal)RETURN
          END DO
c     ------------------------------------------------------------------
c     estimate and Remove either regressor mean or seasonal mean
c     ------------------------------------------------------------------
          IF(lumean)THEN
           CALL setdp(ZERO,PB,urmean)
           DO i=1,neltux
            i2=MOD(i,Ncusrx)
            IF(i2.eq.0)i2=Ncusrx
            urmean(i2)=urmean(i2)+Userx(i)
           END DO
           DO i=1,Ncusrx
            urmean(i)=urmean(i)/DBLE(Nrusrx)
           END DO
           DO i=1,neltux
            i2=MOD(i,Ncusrx)
            IF(i2.eq.0)i2=Ncusrx
            Userx(i)=Userx(i)-urmean(i2)
           END DO
          ELSE IF(luseas)THEN
           n2=Sp*Ncusrx
           DO i=1,Sp
            CALL setdp(ZERO,PB,urmean)
            CALL setdp(ZERO,PB,urnum)
            i2=(i-1)*Ncusrx+1
            DO j=i2,neltux,n2
             DO k=j,Ncusrx+j-1
              k2=MOD(k,Ncusrx)
              IF(k2.eq.0)k2=Ncusrx
              urmean(k2)=urmean(k2)+Userx(k)
              urnum(k2)=urnum(k2)+ONE
             END DO
            END DO
            DO j=1,Ncusrx
             urmean(j)=urmean(j) / urnum(j)
            END DO
            DO j=i2,neltux,n2
             DO k=j,Ncusrx+j-1
              k2=MOD(k,Ncusrx)
              IF(k2.eq.0)k2=Ncusrx
              Userx(k)=Userx(k)-urmean(k2)
             END DO
            END DO
           END DO
          END IF
c     ------------------------------------------------------------------
         END IF
        END IF
       END IF
       IF(Lfatal)RETURN
       IF(Nb.gt.0)THEN
c-----------------------------------------------------------------------
c     Check if the regression model parameters are fixed.  Sets iregfx.
c-----------------------------------------------------------------------
        CALL regfix()
c     ------------------------------------------------------------------
c     set indicator variable for fixed User-defined regressors.
c     ------------------------------------------------------------------
        Userfx=F
        IF(Ncusrx.gt.0.and.Iregfx.ge.2)THEN
         IF(Iregfx.eq.3)THEN
          Userfx=T
         ELSE
          igrp=strinx(F,Grpttl,Grpptr,1,Ngrptl,'User-defined')
          begcol=Grp(igrp-1)
          endcol=Grp(igrp)-1
          Userfx=istrue(Regfx,begcol,endcol)
         END IF
        END IF
c-----------------------------------------------------------------------
c     sort outlier regressors specified by the user, if any.
c-----------------------------------------------------------------------
        CALL otsort()
c-----------------------------------------------------------------------
        IF(Nusrrg.gt.0.and.Ncusrx.eq.0)THEN
         WRITE(STDERR,1030)
         WRITE(Mt2,1030)
 1030    FORMAT(' ERROR: Cannot specify group types for ',
     &          'user-defined regression',/,
     &          '        variables if user-defined regression ',
     &          'variables are not',/,
     &          '        defined in the regression spec.')
         Inptok=F
        END IF
       END IF
c-----------------------------------------------------------------------
c      Check to see if lom, loq, or lpyear regressors can be generated
c      for this series.  (BCM March 2008)
c-----------------------------------------------------------------------
       IF(Lomtst.eq.1.and.Sp.ne.12)THEN
        CALL writln('WARNING: The program will only perform an AIC test 
     &on the length of month',STDERR,Mt2,T)
        CALL writln('         regressor for monthly time series.',
     &              STDERR,Mt2,F)
        Lomtst=0
       ELSE IF(Lomtst.eq.2.and.Sp.ne.4)THEN
        CALL writln('WARNING: The program will only perform an AIC test 
     &on the length of quarter',STDERR,Mt2,T)
        CALL writln('         regressor for quarterly time series.',
     &              STDERR,Mt2,F)
        Lomtst=0
       ELSE IF(Lomtst.eq.3.and.(.not.(Sp.eq.4.or.Sp.eq.12)))THEN
        CALL writln('WARNING: The program will only perform an AIC test 
     &on the leap year',STDERR,Mt2,T)
        CALL writln('         regressor for monthly or quarterly time se
     &ries.',STDERR,Mt2,F)
        Lomtst=0
       END IF
c-----------------------------------------------------------------------
c      Check to see if trading day model selected is compatable with
c      choice of Lomtst (BCM March 2008)
c-----------------------------------------------------------------------
       IF((Lomtst.eq.1.or.Lomtst.eq.2).and.Picktd)THEN
        IF(Lomtst.eq.1)
     &     CALL writln('ERROR: AIC test for the length of month regresso
     &r cannot be specified when',Mt2,STDERR,T)
        IF(Lomtst.eq.2)
     &     CALL writln('ERROR: AIC test for the length of quarter regres
     &sor cannot be specified when',Mt2,STDERR,T)
        CALL writln('       the td or td1coef option is given in the var
     &iables argument.',Mt2,STDERR,F)
        Lomtst=0
        Inptok=F
       ELSE IF(Lomtst.eq.3.and.(Picktd.and.(.not.dpeq(Lam,ONE))))THEN
        CALL writln('ERROR: AIC test for the leap year regressor cannot  
     &be specified when the',Mt2,STDERR,T)
        CALL writln('       td or td1coef option is given in the variabl
     &es argument and a',Mt2,STDERR,F)
        CALL writln('       power transformation is performed.',Mt2,
     &              STDERR,F)
        Lomtst=0
        Inptok=F
       END IF
c-----------------------------------------------------------------------
       IF(Itdtst.eq.3.and.Itdtst.eq.6)THEN
        IF(Lomtst.eq.1)THEN
         CALL writln('ERROR: AIC test for the length of month regressor 
     &cannot be specified when',Mt2,STDERR,T)
        ELSE IF(Lomtst.eq.2)THEN
         CALL writln('ERROR: AIC test for the length of quarter regresso
     &r cannot be specified when',Mt2,STDERR,T)
        ELSE
         CALL writln('ERROR: AIC test for the leap year regressor cannot 
     & be specified when',Mt2,STDERR,T)
        END IF
        CALL writln('       the tdstock or tdstock1coef option is given 
     &in the aictest argument.',Mt2,STDERR,F)
        Lomtst=0
        Inptok=F
       END IF
c-----------------------------------------------------------------------
       IF(Itdtst.gt.0.and.(.not.havtd))havtd=T
       IF(Leastr.and.(.not.Havhol))Havhol=T
       IF((Lomtst.eq.1.or.Lomtst.eq.2).and.(.not.havln))havln=T
       IF(Lomtst.eq.3.and.(.not.havln))havlp=T
       IF(Adjtd.eq.1.and.(.NOT.(havtd.or.havln.or.havlp)))Adjtd=0
       IF(Adjhol.eq.1.and.(.not.Havhol))Adjhol=0
       IF(Adjcyc.eq.1.and.(.not.havcyc))Adjcyc=0
       IF(Nguhl.eq.0.and.Ch2tst)Ch2tst=F
c-----------------------------------------------------------------------
       RETURN
  200  CONTINUE
      END DO
c     -----------------------------------------------------------------
      END
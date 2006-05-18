%%[0
%include lhs2TeX.fmt
%include afp.fmt
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Subsumption (fitting in) for types
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1 module {%{EHC}TyFitsInCommon} import({%{BASE}Common}, EHTy, EHError) export (FIOut(..), emptyFO, foHasErrs)
%%]

%%[2 import({%{EHC}Cnstr})
%%]

%%[4 import({%{EHC}Opts}) export(AppSpineInfo(..), unknownAppSpineInfoL, arrowAppSpineInfoL, prodAppSpineInfoL)
%%]

%%[4 import({%{EHC}Substitutable}) export(FitsIn, FitsIn',fitsInLWith)
%%]

%%[9 import(EHCore,EHCoreSubst)
%%]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Interface to result/output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1.FIOut
data FIOut  =   FIOut   { foTy     ::  Ty      ,  foErrL   ::  ErrL    }

emptyFO     =   FIOut   { foTy     =   Ty_Any  ,  foErrL   =   []      }
%%]

%%[2.FIOut -1.FIOut
data FIOut  =  FIOut  {  foTy     ::  Ty      ,  foErrL   ::  ErrL  ,  foCnstr           ::  Cnstr           }
%%]

%%[2.FIOut.empty
emptyFO     =  FIOut  {  foTy     =   Ty_Any  ,  foErrL   =   []    ,  foCnstr           =   emptyCnstr      }
%%]

%%[4.FIOut -(2.FIOut 2.FIOut.empty)
data FIOut  =  FIOut    {  foCnstr           ::  Cnstr               ,  foTy              ::  Ty
                        ,  foUniq            ::  UID                 ,  foAppSpineL       ::  [AppSpineInfo]
                        ,  foErrL            ::  ErrL  
%%]
%%[9
                        ,  foCSubst          ::  CSubst              ,  foPredOccL        ::  [PredOcc]
                        ,  foLCoeL           ::  [Coe]               ,  foRCoeL           ::  [Coe]
%%]
%%[10
                        ,  foRowCoeL         ::  AssocL HsName Coe
%%]
%%[11
                        ,  foEqCnstr         ::  Cnstr
%%]
%%[4.FIOut.tl
                        }
%%]

%%[4.emptyFO
emptyFO     =  FIOut    {  foCnstr           =   emptyCnstr          ,  foTy              =   Ty_Any
                        ,  foUniq            =   uidStart            ,  foAppSpineL       =   []
                        ,  foErrL            =   []         
%%]
%%[9
                        ,  foCSubst          =   emptyCSubst         ,  foPredOccL        =   []
                        ,  foLCoeL           =   []                  ,  foRCoeL           =   []
%%]
%%[10
                        ,  foRowCoeL         =   []
%%]
%%[11
                        ,  foEqCnstr         =   emptyCnstr
%%]
%%[4.emptyFO.tl
                        }
%%]

%%[1.foHasErrs
foHasErrs :: FIOut -> Bool
foHasErrs = not . null . foErrL
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% "Ty app spine" gam, to be merged with tyGam in the future
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[4.AppSpine
data AppSpineInfo
  =  AppSpineInfo
       { asCoCo         :: CoContraVariance
       , asFIO          :: FIOpts -> FIOpts
       }

unknownAppSpineInfoL :: [AppSpineInfo]
unknownAppSpineInfoL = repeat (AppSpineInfo CoContraVariant fioMkUnify)

arrowAppSpineInfoL :: [AppSpineInfo]
arrowAppSpineInfoL = [AppSpineInfo ContraVariant fioMkStrong, AppSpineInfo CoVariant id]

prodAppSpineInfoL :: [AppSpineInfo]
prodAppSpineInfoL = repeat (AppSpineInfo CoVariant id)
%%]

%%[9.AppSpine -4.AppSpine
data AppSpineInfo
  =  AppSpineInfo
       { asCoCo         :: CoContraVariance
       , asFIO          :: FIOpts -> FIOpts
       , asFOUpdCoe     :: FIOut -> FIOut -> FIOut
       }

unknownAppSpineInfoL :: [AppSpineInfo]
unknownAppSpineInfoL = repeat (AppSpineInfo CoContraVariant fioMkUnify (\_ x -> x))

arrowAppSpineInfoL :: [AppSpineInfo]
arrowAppSpineInfoL
  =  [  AppSpineInfo ContraVariant fioMkStrong
            (\_ x -> x)
     ,  AppSpineInfo CoVariant id
            (\ffo afo
                ->  let  (u',u1) = mkNewUID (foUniq afo)
                         n = uidHNm u1
                         r = mkCoe (\e ->  CExpr_Lam n e)
                         l = mkCoe (\e ->  CExpr_App e
                                             (coeWipeWeave emptyCnstr (foCSubst afo) (foLCoeL ffo) (foRCoeL ffo)
                                               `coeEvalOn` CExpr_Var n)
                                   )
                    in   afo  { foRCoeL = r : foRCoeL afo, foLCoeL = l : foLCoeL afo
                              , foUniq = u'
                              }
            )
     ]

prodAppSpineInfoL :: [AppSpineInfo]
prodAppSpineInfoL = repeat (AppSpineInfo CoVariant id (\_ x -> x))
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% wrapper around fitsIn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[4.FitsIn
type FitsIn' = FIOpts -> UID -> Ty -> Ty -> FIOut
type FitsIn = FIOpts -> UID -> Ty -> Ty -> (Ty,Cnstr,ErrL)
%%]

%%[4.fitsInLWith
fitsInLWith :: (FIOut -> FIOut -> FIOut) -> FitsIn' -> FIOpts -> UID -> TyL -> TyL -> (FIOut,[FIOut])
fitsInLWith foCmb elemFits opts uniq tyl1 tyl2
  = (fo,foL)
  where ((_,fo),foL)
          = foldr  (\(t1,t2) ((u,foThr),foL)
                      -> let  (u',ue) = mkNewLevUID u
                              fo = elemFits opts u (foCnstr foThr |=> t1) (foCnstr foThr |=> t2)
                         in   ((u',foCmb fo foThr),fo:foL)
                   )
                   ((uniq,emptyFO),[])
            . zip tyl1
            $ tyl2
%%]


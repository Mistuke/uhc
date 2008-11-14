%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EHC Compile Phase building blocks: parsers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CompilePhase building blocks: parsers

%%[8 module {%{EH}EHC.CompilePhase.Parsers}
%%]

%%[8 import(UU.Parsing, UU.Parsing.Offside)
%%]
%%[8 import(qualified EH.Util.ScanUtils as ScanUtils, {%{EH}Scanner.Common})
%%]
%%[8 import(EH.Util.ParseUtils)
%%]

%%[8 import({%{EH}EHC.Common})
%%]
%%[8 import({%{EH}EHC.CompileUnit})
%%]
%%[8 import({%{EH}EHC.CompileRun})
%%]
-- EH parser
%%[8 import(qualified {%{EH}EH} as EH, qualified {%{EH}EH.Parser} as EHPrs)
%%]
-- HS parser
%%[8 import(qualified {%{EH}HS} as HS, qualified {%{EH}HS.Parser} as HSPrs)
%%]
-- HI parser
%%[20 import(qualified {%{EH}HI} as HI, qualified {%{EH}HI.Parser} as HIPrs)
%%]
-- Core parser
%%[(20 codegen) import(qualified {%{EH}Core} as Core, qualified {%{EH}Core.Parser} as CorePrs)
%%]
-- Grin parser
%%[(8 codegen grin) import(qualified {%{EH}GrinCode} as Grin, qualified {%{EH}GrinCode.Parser} as GrinParser)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Compile actions: parsing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8 export(cpParseOffside,cpParsePlain',cpParsePlain,cpParseEH)
cpParseOffside :: HSPrs.HSParser a -> ScanUtils.ScanOpts -> EcuUpdater a -> String -> HsName -> EHCompilePhase ()
cpParseOffside parser scanOpts store description modNm
 = do { cr <- get
      ; (fn,fh) <- lift $ openFPath (ecuFilePath (crCU modNm cr)) ReadMode
      ; tokens  <- lift $ offsideScanHandle scanOpts fn fh
      ; let (res,msgs) = parseOffsideToResMsgs parser tokens
            errs       = map (rngLift emptyRange mkPPErr) msgs
      ; cpUpdCU modNm (store res)
      ; cpSetLimitErrsWhen 5 description errs
      }

cpParsePlain' :: PlainParser Token a -> ScanUtils.ScanOpts -> EcuUpdater a -> FPath -> HsName -> EHCompilePhase [Err]
cpParsePlain' parser scanOpts store fp modNm
 = do { cr <- get
      ; (fn,fh) <- lift $ openFPath fp ReadMode
      ; tokens  <- lift $ scanHandle scanOpts fn fh
      ; let (res,msgs) = parseToResMsgs parser tokens
            errs       = map (rngLift emptyRange mkPPErr) msgs
      ; when (null errs)
             (cpUpdCU modNm (store res))
      ; return errs
      }

cpParsePlain :: PlainParser Token a -> ScanUtils.ScanOpts -> EcuUpdater a -> String -> FPath -> HsName -> EHCompilePhase ()
cpParsePlain parser scanOpts store description fp modNm
 = do { errs <- cpParsePlain' parser scanOpts store fp modNm
      ; cpSetLimitErrsWhen 5 description errs
      }

cpParseEH :: HsName -> EHCompilePhase ()
cpParseEH
  = cpParseOffside EHPrs.pAGItf ehScanOpts ecuStoreEH "Parse (EH syntax) of module"
%%]

%%[(8 grin) export(cpParseGrin)
cpParseGrin :: HsName -> EHCompilePhase ()
cpParseGrin modNm
  = do { cr <- get
       ; cpParsePlain GrinParser.pModule grinScanOpts ecuStoreGrin "Parse grin" (ecuFilePath (crCU modNm cr)) modNm
       }
%%]

%%[8.cpParseHs export(cpParseHs)
cpParseHs :: HsName -> EHCompilePhase ()
cpParseHs = cpParseOffside HSPrs.pAGItf hsScanOpts ecuStoreHS "Parse (Haskell syntax) of module"
%%]

%%[99 -8.cpParseHs export(cpParseHs)
cpParseHs :: Bool -> HsName -> EHCompilePhase ()
cpParseHs litmode
  = cpParseOffside HSPrs.pAGItf (hsScanOpts {ScanUtils.scoLitmode = litmode}) ecuStoreHS
                   ("Parse (" ++ (if litmode then "Literate " else "") ++ "Haskell syntax) of module")
%%]

%%[20 export(cpParseOffsideStopAtErr)
cpParseOffsideStopAtErr :: HSPrs.HSParser a -> ScanUtils.ScanOpts -> EcuUpdater a -> HsName -> EHCompilePhase ()
cpParseOffsideStopAtErr parser scanOpts store modNm
 = do { cr <- get
      ; (fn,fh) <- lift $ openFPath (ecuFilePath (crCU modNm cr)) ReadMode
      ; tokens  <- lift $ offsideScanHandle scanOpts fn fh
      ; let (res,_) = parseOffsideToResMsgsStopAtErr parser tokens
      ; cpUpdCU modNm (store res)
      }
%%]

%%[20.cpParseHsImport export(cpParseHsImport)
cpParseHsImport :: HsName -> EHCompilePhase ()
cpParseHsImport = cpParseOffsideStopAtErr HSPrs.pAGItfImport hsScanOpts ecuStoreHS
%%]

%%[99 -20.cpParseHsImport export(cpParseHsImport)
cpParseHsImport :: Bool -> HsName -> EHCompilePhase ()
cpParseHsImport litmode = cpParseOffsideStopAtErr HSPrs.pAGItfImport (hsScanOpts {ScanUtils.scoLitmode = litmode}) ecuStoreHS
%%]

%%[(20 codegen) export(cpParseCore)
cpParseCore :: HsName -> EHCompilePhase ()
cpParseCore modNm
  = do { cr <- get
       ; let  (ecu,_,opts,fp) = crBaseInfo modNm cr
              fpC     = fpathSetSuff "core" fp
       ; cpMsg' modNm VerboseALot "Parsing" Nothing fpC
       ; errs <- cpParsePlain' CorePrs.pCModule coreScanOpts ecuStoreCore fpC modNm
       ; when (ehcDebugStopAtCoreError opts) $ cpSetLimitErrsWhen 5 "Parse Core (of previous compile) of module" errs
       ; return ()
       }
%%]

%%[20 export(cpParsePrevHI)
cpParsePrevHI :: HsName -> EHCompilePhase ()
cpParsePrevHI modNm
  = do { cr <- get
       ; let  (ecu,_,opts,fp) = crBaseInfo modNm cr
              fpH     = fpathSetSuff "hi" fp
       ; cpMsg' modNm VerboseALot "Parsing" Nothing fpH
       ; errs <- cpParsePlain' HIPrs.pAGItf hiScanOpts ecuStorePrevHI fpH modNm
       ; when (ehcDebugStopAtHIError opts) $ cpSetLimitErrsWhen 5 "Parse HI (of previous compile) of module" errs
       ; return ()
       }
%%]



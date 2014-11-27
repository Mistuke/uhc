%%[(8 core)

-- | Core Public API (provisional, to be refactored)
--
-- Intended for constructing basic Core Programs. Use the binary serialization from `UHC.Util.Binary`
-- to produce a core file, which can be compiled by UHC.
--
-- Restrictions:
--
--  - Extendable data types are not supported
--  - Generated code is not (type-)checked, might cause runtime crashes
--  - Core parsing/Pretty printing is incomplete and might be partially broken.
--
-- TODO:
-- - Constructor applications (mkCon) always have to be fully saturated. (move to acoreTagTup)
-- - Haskell constructor names must be unambigous per module (mkHSCTag)

module %%@{%{EH}%%}Core.API
  (
  -- * Core AST
  -- | The datatypes making up a Core program.
    EC.CModule
  , EC.CImport
  , EC.CExport
  , EC.CDeclMeta
  , EC.CDataCon
  , EC.CExpr
  , EC.CBind
  , EC.CAlt
  , EC.CPat
  , EC.CPatFld

  -- * Construction functions
  -- ** Constants
  , mkUnit
  , mkInt

%%[[97
  , mkInteger
%%]]
  , mkString
  , mkError
  , mkUndefined

  -- ** Variables
  , mkVar

  -- ** Let Bindings
  , mkLet1Plain
  , mkLet1Strict
  , mkLetRec

  -- ** Abstraction
  , mkLam

  -- ** Application
  , mkApp

  -- ** Binds/Bounds
  , mkBind1
  , mkBind1Nm1

  -- ** Constructor tags
  , mkCTag
  , destructCTag

  , ctagUnit
  , ctagTup
  , ctagTrue
  , ctagFalse
  , ctagCons
  , ctagNil

  -- ** Case
  -- | Scrutinizes an expression and executes the appropriate alternative.
  -- The scrutinee of a case statement is required to be in WHNF (weak head normal form).
  , mkCaseDflt

  , mkAlt
  , mkPatCon
  , mkPatRestEmpty
  , mkPatFldBind


  -- ** Datatypes
  , mkTagTup


  -- ** Module
  , mkModule
  , mkImport
  , mkExport
  , mkMetaData
  , mkMetaDataCon
  , mkMetaDataConFromCTag

  -- * Utilities
  , mkMain

  , parseExpr
  , printModule
  
  -- * Re-exports (or not???)
  , module %%@{%{EH}%%}Base.API
  )
  where

import qualified Data.Map as M
import Data.List
import Data.Ord

--import %%@{%{EH}%%}AbstractCore hiding (acoreCaseDflt)
import qualified %%@{%{EH}%%}AbstractCore as AC
import %%@{%{EH}%%}Base.API
import %%@{%{EH}%%}Base.Common
import %%@{%{EH}%%}Base.HsName
import qualified %%@{%{EH}%%}Core as EC
import %%@{%{EH}%%}Core.Pretty
import %%@{%{EH}%%}Core.Parser
import %%@{%{EH}%%}Scanner.Common
import %%@{%{EH}%%}Opts
import qualified %%@{%{EH}%%}CodeGen.Tag as C
import UHC.Util.ParseUtils
import UHC.Util.Pretty
import UU.Parsing.Machine
import UU.Parsing.MachineInterface
import UU.Parsing.Interface

-- **************************************
-- Constants
-- **************************************

-- TODO how should we handle the type?
-- | Creates the unit expresssion.
mkUnit :: EHCOpts -> EC.CExpr
mkUnit _ = AC.acoreTup []

-- | Creates an `Int` constant.
mkInt :: EHCOpts -> Int -> EC.CExpr
mkInt = AC.acoreInt

%%[[97
-- | Creates a Core 'Integer' constant.
mkInteger :: EHCOpts
    -> Integer  -- ^ The integer.
    -> EC.CExpr
-- TODO acoreInt2 or acoreBuiltinInteger ?
mkInteger = AC.acoreBuiltinInteger
%%]]

-- | Creates a string expression.
-- The expression represents a packed String, which can be passed to Haskell generated Core functions.
mkString :: EHCOpts
    -> String   -- ^ The string.
    -> EC.CExpr
mkString = AC.acoreBuiltinString

-- | Generates an error expression, failing with the given string when evaluated. ('error' in haskell)
mkError :: EHCOpts
    -> String   -- ^ The error message.
    -> EC.CExpr
mkError = AC.acoreBuiltinError

-- | Generates an undefined expression, failing when evaluated. ('undefined' in haskell)
mkUndefined :: EHCOpts -> EC.CExpr
mkUndefined = AC.acoreBuiltinUndefined


-- **************************************
-- Constants
-- **************************************

-- | Creates a variable expression.
mkVar :: HsName -> EC.CExpr
mkVar = AC.acoreVar

-- **************************************
-- Let Bindings
-- **************************************

-- | Creates a (non-recursive) let binding.
mkLet1Plain :: HsName   -- ^ The identifier.
    -> EC.CExpr       -- ^ The expression to bind.
    -> EC.CExpr       -- ^ The body.
    -> EC.CExpr
mkLet1Plain = AC.acoreLet1Plain

-- | Creates a let binding, which is strict in the bound expression.
mkLet1Strict :: HsName   -- ^ The identifer.
    -> EC.CExpr        -- ^ The expression to bind. Will be evaluated to WHNF, before the body is evaluated.
    -> EC.CExpr        -- ^ The body.
    -> EC.CExpr
mkLet1Strict = AC.acoreLet1Strict

-- | Creates a let binding, where the bindings may be mutually recursive.
mkLetRec :: [EC.CBind]  -- ^ The bindings.
    -> EC.CExpr    -- ^ The body.
    -> EC.CExpr
mkLetRec = AC.acoreLetRec

-- **************************************
-- Abstraction
-- **************************************

mkLam :: [HsName] -> EC.CExpr -> EC.CExpr
mkLam = AC.acoreLam

-- **************************************
-- Application
-- **************************************
-- | Applies the first expression to all given arguments.
mkApp :: EC.CExpr    -- ^ The lambda to apply.
    -> [EC.CExpr]  -- ^ The arguments (the empty list is allowed).
    -> EC.CExpr
mkApp = AC.acoreApp

-- **************************************
-- Binds / Bounds
-- **************************************

mkBind1 :: HsName -> EC.CExpr -> EC.CBind
mkBind1 = AC.acoreBind1

mkBind1Nm1 :: HsName -> EC.CBind
mkBind1Nm1 = AC.acoreBind1Nm1

-- **************************************
-- Constructor tags
-- **************************************

-- | Creates a constructor tag.
mkCTag :: HsName  -- ^ Fully qualified Datatype name.
    -> HsName       -- ^ Fully qualified Constructor name.
    -> Int          -- ^ Tag number.
    -> Int          -- ^ Arity.
    -> CTag
mkCTag tyNm conNm tg ar = CTag tyNm conNm tg ar (-1)

-- | Destruct a `CTag`.
destructCTag :: a -- ^ Algebra for record/tuple case.
    -> (HsName -> HsName -> Int -> Int -> a)    -- ^ Algebra for datatype case. Order of arguments is the same as in 'makeCTag'.
    -> CTag
    -> a
destructCTag arec _ CTagRec = arec
destructCTag _ adat (CTag {ctagTyNm = ty, ctagNm = nm, ctagTag' = tag, ctagArity = ar}) = adat ty nm tag ar

-- | `CTag` for unit values ('()' in haskell).
ctagUnit :: CTag
ctagUnit = ctagTup

-- | `CTag` of tuple/records.
ctagTup :: CTag
ctagTup = CTagRec


ctagTrue :: EHCOpts -> CTag
ctagTrue = AC.ctagTrue

ctagFalse :: EHCOpts -> CTag
ctagFalse = AC.ctagFalse

ctagCons :: EHCOpts -> CTag
ctagCons = AC.ctagCons

ctagNil :: EHCOpts -> CTag
ctagNil = AC.ctagNil

-- **************************************
-- Case
-- **************************************

-- TODO verify that this sorting is always correct (see also AbstractCore/Utils.chs)
-- | A Case expression, possibly with a default value.
mkCaseDflt  :: EC.CExpr        -- ^ The scrutinee. Required to be in WHNF.
        -> [EC.CAlt]      -- ^ The alternatives.
        -> Maybe EC.CExpr  -- ^ The default value. (TODO what is the behaviour if it is Nothing?)
        -> EC.CExpr
mkCaseDflt e as def =
  AC.acoreCaseDflt e (sortBy (comparing (getTag . fst . AC.acoreUnAlt)) as) def
  where -- gets the tag for constructors, or returns 0 if this is not a constructor pattern
        -- TODO is this always safe?
        getTag t = case AC.acorePatMbCon t of
                        Just (tag, _, _) -> ctagTag tag
                        Nothing          -> 0

-- | Creates an alternative of a case statement.
mkAlt :: EC.CPat   -- ^ The pattern with which to match the case scrutinee.
        -> EC.CExpr     -- ^ The value of this alternative.
        -> EC.CAlt
mkAlt = AC.acoreAlt

-- | Matches the case scrutinee with the given constructor tag.
mkPatCon :: CTag   -- ^ The constructor to match.
    -> EC.CPatRest          -- ^ ???
    -> [EC.CPatFld]         -- ^ ???
    -> EC.CPat
mkPatCon = AC.acorePatCon

-- | patrest, empty TODO what does it mean?
mkPatRestEmpty :: EC.CPatRest
mkPatRestEmpty = AC.acorePatRestEmpty

-- | TODO ??? pat field
mkPatFldBind :: (HsName,EC.CExpr)  -- ^ lbl, offset ???
    -> EC.CBind     -- ^ ??
    -> EC.CPatFld
mkPatFldBind = AC.acorePatFldBind

-- **************************************
-- Datatypes
-- **************************************

-- | Creates a new tuple/record with the given values.
-- Has to be fully applied, partial application is not allowed.
mkTagTup :: CTag -> [EC.CExpr] -> EC.CExpr
mkTagTup = AC.acoreTagTup

-- **************************************
-- Module
-- **************************************


-- | Creates a module.
mkModule :: HsName    -- ^ The name of the module.
    -> [EC.CExport]        -- ^ The exports.
    -> [EC.CImport]        -- ^ The imports (only direct imports, not transitive ones).
    -> [EC.CDeclMeta]      -- ^ The meta information.
    -> EC.CExpr            -- ^ The body of the module.
    -> EC.CModule
mkModule = EC.CModule_Mod

-- | Creates an import.
mkImport :: HsName -- ^ The module to import.
    -> EC.CImport
mkImport = EC.CImport_Import

mkExport :: HsName -> EC.CExport
mkExport = EC.CExport_Export

-- | Creates the metadata for one datatype.
mkMetaData :: HsName  -- ^ The name of the dataype.
    -> [EC.CDataCon]       -- ^ The constructors of the dataype.
    -> EC.CDeclMeta
mkMetaData = EC.CDeclMeta_Data

-- | Creates the metadata for one constructor.
mkMetaDataCon :: HsName   -- ^ The fully qualified name of the constructor.
    -> Int                  -- ^ The tag of this constructor.
    -> Int                  -- ^ The arity of this constructor.
    -> EC.CDataCon
mkMetaDataCon = EC.CDataCon_Con

mkMetaDataConFromCTag :: CTag -- ^ CTag to export.
    -> Maybe EC.CDataCon   -- ^ The constructor description. Nothing if it is a record/tuple constructor.
mkMetaDataConFromCTag = destructCTag Nothing (\_ b c d -> Just $ mkMetaDataCon b c d)

-- **************************************
-- Utilities
-- **************************************


-- | Creates the main entry point, calling the given function when run. The given
-- function to call has to be in scope (either define it in the same module,
-- or import it).
-- In addition, the module "UHC.Run" has to be imported!
mkMain :: HsName       -- ^ The function containing the user code to call.
    -> EC.CExpr
mkMain main = mainEhc
  where mainEhc = AC.acoreLet1Plain mainNm
            (mainWrap $ AC.acoreVar main)
            (AC.acoreVar mainNm)
        mainNm = hsnMain
%%[[8
        mainWrap = id
%%][99
        mainWrap = \m -> AC.acoreApp (AC.acoreVar hsnEhcRunMain) [m]
%%]]


-- | Parses an expression.
parseExpr :: EHCOpts -> String -> Either [String] EC.CExpr
parseExpr ehcOpts str = case parseToResMsgs pCExpr tokens of
    (res, []) -> Right res
    (_, errs) -> Left $ map show errs
  where scanOpts = coreScanOpts ehcOpts
        tokens = scan scanOpts (initPos str) str

printModule :: EHCOpts -> EC.CModule -> PP_Doc
printModule = ppCModule

%%]

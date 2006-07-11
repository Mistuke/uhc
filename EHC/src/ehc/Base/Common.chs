%%[0
%include lhs2TeX.fmt
%include afp.fmt
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Common
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1 module {%{EH}Base.Common}
%%]

%%[1 import(UU.Scanner.Position) export(HSNM(..),HsName(..), hsnWild, hsnArrow, strProd, hsnProd, hsnProdArity, hsnUnknown, hsnIsArrow, hsnIsProd, hsnInt, hsnChar)
%%]

%%[1 export(hsnNegate,hsnError)
%%]

%%[1 export(AssocL, ppAssocL)
%%]

%%[1.exp.hdAndTl export(hdAndTl, hdAndTl')
%%]

%%[1 import(UU.Pretty, Data.List) export(ppListSep, ppCommaList, ppListSepFill, ppSpaced, ppAppTop, ppCon, ppCmt)
%%]

%%[1 export(SemApp(..))
%%]

%%[1 export(assocLKeys)
%%]

%%[1 export(ParNeed(..), ParNeedL, parNeedApp, ppParNeed)
%%]

%%[2 export(UID, mkNewLevUID, mkNewLevUID2, mkNewLevUID3, mkNewLevUID4, mkNewLevUID5, mkNewLevUID6, mkNewLevUID7, mkNewLevUID8, uidNext, mkNewUID, mkNewUIDL, uidStart, uidNull)
%%]

%%[2 export(assocLMapElt,assocLMapKey)
%%]

%%[2 export(unions)
%%]

%%[3 export(hsnUn, hsnIsUn, hsnUnUn)
%%]

%%[4 export(listCombineUniq)
%%]

%%[4 export(CoContraVariance(..), cocoOpp)
%%]

%%[4 export(FIMode(..),fimOpp,fimSwapCoCo)
%%]

%%[5 export(hsnBool,hsnTrue,hsnFalse,hsnString,hsnList,hsnListCons,hsnListNil)
%%]

%%[6 export(hsnStar)
%%]

%%[7 export(hsnRow,hsnRec,hsnSum,hsnRowEmpty,hsnIsRec,hsnIsSum)
%%]

%%[7 export(hsnORow,hsnCRow,hsnORec,hsnCRec,hsnOSum,hsnCSum)
%%]

%%[7 export(positionalFldNames,ppFld,mkExtAppPP,mkPPAppFun)
%%]

%%[7 export(assocLElts,uidHNm)
%%]

%%[7 export(Seq,mkSeq,unitSeq,concatSeq,"(<+>)",seqToList,emptySeq,concatSeqs)
%%]

%%[7 export(mkNewLevUIDL,mkInfNewLevUIDL)
%%]

%%[7_2 import(qualified Data.Map as Map, Data.Map(Map), qualified Data.Set as Set, Data.Set(Set))
%%]

%%[7_2 export(threadMap,Belowness(..), groupAllBy, mergeListMap)
%%]

%%[8 -(1.exp.hdAndTl 1.Misc.hdAndTl) import (EH.Util.Utils hiding (tr,trp)) export(module EH.Util.Utils)
%%]

%%[8 import (EH.Util.FPath,IO,Char) export(putPPLn,putWidthPPLn,putPPFile,Verbosity(..),putCompileMsg, openFPath,writeToFile, writePP)
%%]

%%[8 export(hsnFloat)
%%]

%%[8 export(hsnPrefix,hsnSuffix,hsnConcat)
%%]

%%[8 export(hsnUndefined,hsnPrimAddInt,hsnMain)
%%]

%%[88 export(sortByOn,sortOn,groupOn,groupSortOn)
%%]

%%[8 import (qualified Data.Map as Map) export(showPP,ppPair,ppFM)
%%]

%%[8 export(hsnUniqSupplyL,hsnLclSupplyL)
%%]

%%[8 export(CTag(..),ctagChar,ctagInt)
%%]

%%[8 export(CTagsMp)
%%]

%%[90 export(groupSortByOn)
%%]

%%[9 export(hsnOImpl,hsnCImpl,hsnPrArrow,hsnIsPrArrow,hsnIsUnknown)
%%]

%%[9 export(ppListV,ppAssocLV)
%%]

%%[9 hs export(PredOccId(..),mkPrId,poiHNm)
%%]

%%[9 hs export(PrfCtxtId)
%%]

%%[9 hs export(snd3,thd)
%%]

%%[10 export(hsnDynVar)
%%]

%%[99 export(hsnInteger,hsnDouble)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Haskell names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1.HsName.type
data HsName
  =   HNm String
  deriving (Eq,Ord)

instance Show HsName where
  show (HNm s) = s
%%]

%%[1
instance PP HsName where
  pp h = pp (show h)
%%]

%%[7.HsName.type -1.HsName.type
data HsName
  =   HNm String
  |   HNPos Int
%%]
%%[8
  |   HNmQ [HsName]
%%]
%%[7
  deriving (Eq,Ord)
%%]

%%[7
instance Show HsName where
  show (HNm s    )  = s
  show (HNPos p  )  = show p
%%]
%%[8
  show (HNmQ ns  )  = concat $ intersperse "." $ map show ns
%%]

%%[1
strProd :: Int -> String
%%]

%%[1.HsName.Base.itf
hsnArrow, hsnUnknown, hsnInt, hsnChar, hsnWild
                                    ::  HsName
hsnProd                             ::  Int -> HsName
hsnProdArity                        ::  HsName -> Int
%%]

%%[1.HsName.Base.impl
hsnArrow                            =   HNm "->"
hsnUnknown                          =   HNm "??"
hsnInt                              =   HNm "Int"
hsnChar                             =   HNm "Char"
hsnWild                             =   HNm "_"
strProd         i                   =   ',' : show i
hsnProd                             =   HNm . strProd

hsnIsArrow, hsnIsProd               ::  HsName -> Bool
hsnIsArrow      hsn                 =   hsn == hsnArrow

hsnIsProd       (HNm (',':_))       =   True
hsnIsProd       _                   =   False

hsnProdArity    (HNm (_:ar))        =   read ar
%%]

%%[1.other
hsnNegate                           =   HNm "negate"
hsnError                            =   HNm "error"
%%]

%%[3.strUn
strUn                               =   "un"
%%]

%%[99.strUn -3.strUn
strUn                               =   "-"
%%]

%%[3
hsnUn                               ::  HsName -> HsName
hsnUn           nm                  =   HNm (strUn ++ show nm)
%%]

%%[3
hsnIsUn         (HNm s)             =   isPrefixOf strUn s

hsnUnUn         (HNm s)             =   HNm (drop (length strUn) s)
%%]

%%[5
hsnBool                             =   HNm "Bool"
hsnTrue                             =   HNm "True"
hsnFalse                            =   HNm "False"
hsnString                           =   HNm "String"
hsnList                             =   HNm "[]"
hsnListCons                         =   HNm ":"
hsnListNil                          =   HNm "[]"
%%]

%%[5
hsnIsList       hsn                 =   hsn == hsnList
%%]

%%[6
hsnStar                             =   HNm "*"
%%]

%%[7
hsnORow                             =   HNm "(|"
hsnCRow                             =   HNm "|)"
hsnOSum                             =   HNm "(<"
hsnCSum                             =   HNm ">)"
hsnORec                             =   HNm "("
hsnCRec                             =   HNm ")"

hsnRow                              =   HNm "Row"
hsnRec                              =   HNm "Rec"
hsnSum                              =   HNm "Var"
hsnRowEmpty                         =   HNm (show hsnORow ++ show hsnCRow)

hsnIsRec, hsnIsSum, hsnIsRow        ::  HsName -> Bool
hsnIsRec        hsn                 =   hsn == hsnRec
hsnIsSum        hsn                 =   hsn == hsnSum
hsnIsRow        hsn                 =   hsn == hsnRow

positionalFldNames                  ::  [HsName]
positionalFldNames                  =   map HNPos [1..]
%%]

%%[8
hsnPrefix                           ::  String -> HsName -> HsName
hsnPrefix   p   hsn                 =   HNm (p ++ show hsn)

hsnSuffix                           ::  HsName -> String -> HsName
hsnSuffix       hsn   p             =   HNm (show hsn ++ p)

hsnConcat                           ::  HsName -> HsName -> HsName
hsnConcat       h1    h2            =   HNm (show h1 ++ show h2)
%%]

%%[8
hsnFloat                            =   HNm "Float"
%%]

%%[8
hsnMain                             =   HNm "main"
hsnUndefined                        =   HNm "undefined"
hsnPrimAddInt						=	HNm "primAddInt"
%%]

%%[9
hsnOImpl                            =   HNm "(!"
hsnCImpl                            =   HNm "!)"
hsnPrArrow                          =   HNm "=>"

hsnIsPrArrow                        ::  HsName -> Bool
hsnIsPrArrow    hsn                 =   hsn == hsnPrArrow
hsnIsUnknown                        =   (==hsnUnknown)
%%]

%%[10
hsnDynVar                           =   HNm "?"
%%]

%%[99
hsnInteger                          =   HNm "Integer"
hsnDouble                           =   HNm "Double"
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Make HsName of something
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1
class HSNM a where
  mkHNm :: a -> HsName

instance HSNM HsName where
  mkHNm = id

instance HSNM Int where
  mkHNm = mkHNm . show

%%]

%%[1.HSNM.String
instance HSNM String where
  mkHNm s = HNm s
%%]

%%[8.HSNM.String -1.HSNM.String
instance HSNM String where
  mkHNm s
    = mk $ map HNm $ wordsBy (=='.') $ s
    where mk [n] = n
          mk ns  = HNmQ ns
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% HsName class instances
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1 hs
instance Position HsName where
  line   _ = (-1)
  column _ = (-1)
  file   _ = ""
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Name supply, with/without uniqueness required
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8 hs
hsnUniqSupplyL :: UID -> [HsName]
hsnUniqSupplyL = map uidHNm . iterate uidNext

hsnLclSupplyL :: [HsName]
hsnLclSupplyL = map (\i -> HNm ("_" ++ show i)) [1..]
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Unique id's
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[2.UID.Base
newtype UID= UID [Int] deriving (Eq,Ord)
%%]

%%[2.UID.UIDL
type UIDL = [UID]
%%]

%%[2.UID.Show
instance Show UID where
  show (UID ls) = concat . intersperse "_" . map show . reverse $ ls
%%]

%%[2.UID.mkNewLevUID
uidNext :: UID -> UID
uidNext (UID (l:ls)) = UID (l+1:ls)

mkNewLevUID :: UID -> (UID,UID)
mkNewLevUID u@(UID ls) = (uidNext u,UID (0:ls))
%%]

%%[2.UID.Utils
mkNewLevUID2 u = let { (u',u1)          = mkNewLevUID   u; (u'',u2)         = mkNewLevUID   u'} in (u'',u1,u2)
mkNewLevUID3 u = let { (u',u1,u2)       = mkNewLevUID2  u; (u'',u3)         = mkNewLevUID   u'} in (u'',u1,u2,u3)
mkNewLevUID4 u = let { (u',u1,u2)       = mkNewLevUID2  u; (u'',u3,u4)      = mkNewLevUID2  u'} in (u'',u1,u2,u3,u4)
mkNewLevUID5 u = let { (u',u1,u2)       = mkNewLevUID2  u; (u'',u3,u4,u5)   = mkNewLevUID3  u'} in (u'',u1,u2,u3,u4,u5)
mkNewLevUID6 u = let { (u',u1,u2,u3)    = mkNewLevUID3  u; (u'',u4,u5,u6)   = mkNewLevUID3  u'} in (u'',u1,u2,u3,u4,u5,u6)
mkNewLevUID7 u = let { (u',u1,u2,u3,u4) = mkNewLevUID4  u; (u'',u5,u6,u7)    = mkNewLevUID3  u'} in (u'',u1,u2,u3,u4,u5,u6,u7)
mkNewLevUID8 u = let { (u',u1,u2,u3,u4) = mkNewLevUID4  u; (u'',u5,u6,u7,u8) = mkNewLevUID4  u'} in (u'',u1,u2,u3,u4,u5,u6,u7,u8)

uidStart :: UID
uidStart = UID [0]

uidNull :: UID
uidNull  = UID []

mkNewUID :: UID -> (UID,UID)
mkNewUID   uid = (uidNext uid,uid)

mkInfNewUIDL' :: (UID -> (UID,UID)) -> UID -> [UID]
mkInfNewUIDL' mk uid
  =  let  l = iterate (\(nxt,uid) -> mk nxt) . mkNewUID $ uid
     in   map snd l

mkNewUIDL' :: (UID -> (UID,UID)) -> Int -> UID -> [UID] -- assume sz > 0
mkNewUIDL' mk sz uid
  =  take sz (mkInfNewUIDL' mk uid)

mkNewUIDL :: Int -> UID -> [UID] -- assume sz > 0
mkNewUIDL = mkNewUIDL' mkNewUID

instance PP UID where
  pp = text . show
%%]

%%[7
uidHNm :: UID -> HsName
uidHNm = HNm . show
%%]

%%[7
mkInfNewLevUIDL :: UID -> [UID]
mkInfNewLevUIDL = mkInfNewUIDL' mkNewLevUID

mkNewLevUIDL :: Int -> UID -> [UID]
mkNewLevUIDL = mkNewUIDL' mkNewLevUID
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Proof context id
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9 hs
type PrfCtxtId = UID
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pred occurrence id
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9 hs
data PredOccId =  PredOccId {poiCxId :: PrfCtxtId, poiId :: UID} deriving (Show,Eq,Ord)

mkPrId :: PrfCtxtId -> UID -> PredOccId
mkPrId ci u = PredOccId ci u

poiHNm :: PredOccId -> HsName
poiHNm = uidHNm . poiId

instance PP PredOccId where
  pp poi = "Cx:" >|< pp (poiCxId poi) >|< "/Pr:" >|< pp (poiId poi)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Ordered sequence, 'delayed concat' list
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[7
newtype Seq a = Seq ([a] -> [a])

emptySeq :: Seq a
emptySeq = Seq id

mkSeq :: [a] -> Seq a
mkSeq l = Seq (l++)

unitSeq :: a -> Seq a
unitSeq e = Seq (e:)

concatSeq :: Seq a -> Seq a -> Seq a
concatSeq (Seq s1) (Seq s2) = Seq (s1.s2)

concatSeqs :: [Seq a] -> Seq a
concatSeqs = foldr (<+>) emptySeq

infixr 5 <+>

(<+>) :: Seq a -> Seq a -> Seq a
(<+>) = concatSeq

seqToList :: Seq a -> [a]
seqToList (Seq s) = s []

instance Functor Seq where
  fmap f = mkSeq . map f . seqToList
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Semantics classes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1.SemApp
class SemApp a where
  semApp            ::  a -> a -> a
  semAppTop         ::  a -> a
  semCon            ::  (Position n,HSNM n) => n -> a
  semParens         ::  a -> a
  mk1App            ::  a -> a -> a
  mkApp             ::  [a] -> a
  mk1ConApp         ::  (Position n,HSNM n) => n -> a -> a
  mkConApp          ::  (Position n,HSNM n) => n -> [a] -> a
  mkProdApp         ::  [a] -> a
  mk1Arrow          ::  a -> a -> a
  mkArrow           ::  [a] -> a -> a
%%]
%%[1.SemApp.default
  mkApp as          =   case as of  [a]  ->  a
                                    _    ->  semAppTop (foldl1 semApp as)
  mk1App     a r    =   mkApp [a,r]
  mkConApp   c as   =   mkApp (semCon c : as)
  mk1ConApp  c a    =   mkConApp c [a]
  mkProdApp  as     =   mkConApp (hsnProd (length as)) as
  mk1Arrow   a r    =   mkApp [semCon hsnArrow,a,r]
  mkArrow           =   flip (foldr mk1Arrow)
%%]
class SemApp a where
  semApp            ::  a -> a -> a
  semAppTop         ::  a -> a
  semCon            ::  HsName -> a
  semParens         ::  a -> a
  mkApp             ::  [a] -> a
  mkConApp          ::  HsName -> [a] -> a
  mkProdApp         ::  [a] -> a
  mk1Arrow          ::  a -> a -> a
  mkArrow           ::  [a] -> a -> a
  mkApp as          =   case as of  [a]  ->  a
                                    _    ->  semAppTop (foldl1 semApp as)
  mkConApp   c as   =   mkApp (semCon c : as)
  mkProdApp  as     =   mkConApp (hsnProd (length as)) as
  mk1Arrow   a r    =   mkApp [semCon hsnArrow,a,r]
  mkArrow           =   flip (foldr mk1Arrow)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Building specific structures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1.MkConApp
%%]
type MkConApp t = (HsName -> t,t -> t -> t,t -> t,t -> t)

%%[1.mkApp.Base
%%]
mkApp :: SemApp t => [t] -> t
mkApp ts
  =  case ts of
       [t]  ->  t
       _    ->  semAppTop (foldl1 semApp ts)

%%[1.mkApp.mkConApp
%%]
mkConApp :: SemApp t => HsName -> [t] -> t
mkConApp c ts = mkApp (semCon c : ts)

%%[1.mkApp.mkProdApp
%%]
mkProdApp :: SemApp t => [t] -> t
mkProdApp ts = mkConApp (hsnProd (length ts)) ts

%%[7 -1.mkApp.mkProdApp
%%]

%%[1.mkApp.mkArrow
%%]
mk1Arrow :: SemApp t => t -> t -> t
mk1Arrow a r = mkApp [semCon hsnArrow,a,r]

mkArrow :: SemApp t => [t] -> t -> t
mkArrow = flip (foldr mk1Arrow)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pretty printing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1.PP.ppAppTop
ppAppTop :: PP arg => (HsName,arg) -> [arg] -> PP_Doc -> PP_Doc
ppAppTop (conNm,con) args dflt
  =  if       hsnIsArrow conNm  then  ppListSep "" "" (" " >|< con >|< " ") args
     else if  hsnIsProd  conNm  then  ppListSep "(" ")" "," args
%%]
%%[5
     else if  hsnIsList  conNm  then  ppListSep "[" "]" "," args
%%]
%%[7
     else if  hsnIsRec   conNm  then  ppListSep (hsnORec >|< con) hsnCRec "," args
     else if  hsnIsSum   conNm  then  ppListSep (hsnOSum >|< con) hsnCSum "," args
     else if  hsnIsRow   conNm  then  ppListSep (hsnORow >|< con) hsnCRow "," args
%%]
%%[1
                                else  dflt
%%]

%%[1.PP.NeededByExpr
ppListSep :: (PP s, PP c, PP o, PP a) => o -> c -> s -> [a] -> PP_Doc
ppListSep o c s pps = o >|< hlist (intersperse (pp s) (map pp pps)) >|< c

ppCon :: HsName -> PP_Doc
ppCon nm =  if    hsnIsProd nm
            then  pp_parens (text (replicate (hsnProdArity nm - 1) ','))
            else  pp nm

ppCmt :: PP_Doc -> PP_Doc
ppCmt p = "{-" >#< p >#< "-}"
%%]

%%[1.PP.Rest
ppCommaList :: PP a => [a] -> PP_Doc
ppCommaList = ppListSep "[" "]" ","

ppSpaced :: PP a => [a] -> PP_Doc
ppSpaced = ppListSep "" "" " "

ppListSepFill :: (PP s, PP c, PP o, PP a) => o -> c -> s -> [a] -> PP_Doc
ppListSepFill o c s pps
  = l pps
  where l []      = o >|< c
        l [p]     = o >|< pp p >|< c
        l (p:ps)  = fill ((o >|< pp p) : map (s >|<) ps) >|< c
%%]

%%[7
ppFld :: String -> HsName -> HsName -> PP_Doc -> PP_Doc
ppFld sep positionalNm nm f
  = if nm == positionalNm then f else nm >#< sep >#< f

mkPPAppFun :: HsName -> PP_Doc -> PP_Doc
mkPPAppFun c p = if c == hsnRowEmpty then empty else p >|< "|"

mkExtAppPP :: (HsName,PP_Doc,[PP_Doc]) -> (HsName,PP_Doc,[PP_Doc],PP_Doc) -> (PP_Doc,[PP_Doc])
mkExtAppPP (funNm,funNmPP,funPPL) (argNm,argNmPP,argPPL,argPP)
  =  if hsnIsRec funNm || hsnIsSum funNm
     then (mkPPAppFun argNm argNmPP,argPPL)
     else (funNmPP,funPPL ++ [argPP])
%%]

%%[4
%%]
instance PP a => PP (Maybe a) where
  pp m = maybe (pp "?") pp m

instance PP Bool where
  pp b = pp (show b)

%%[9
instance (PP a, PP b) => PP (a,b) where
  pp (a,b) = ppListSep "(" ")" "," [pp a,pp b]
%%]

%%[8
ppPair :: (PP a, PP b) => (a,b) -> PP_Doc
ppPair (x,y) = pp_parens (pp x >|< "," >|< pp y)
%%]

%%[8
showPP :: PP a => a -> String
showPP x = disp (pp x) 100 ""
%%]

%%[8
ppFM :: (PP k,PP v) => Map.Map k v -> PP_Doc
ppFM = ppAssocL . Map.toList
%%]

%%[9
ppListV :: PP a => [a] -> PP_Doc
ppListV = vlist . map pp
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Putting stuff on output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
putWidthPPLn :: Int -> PP_Doc -> IO ()
putWidthPPLn w pp = putStrLn (disp pp w "")

putPPLn :: PP_Doc -> IO ()
putPPLn = putWidthPPLn 4000

putCompileMsg :: Verbosity -> Verbosity -> String -> Maybe String -> HsName -> FPath -> IO ()
putCompileMsg v optsVerbosity msg mbMsg2 modNm fNm
  = if optsVerbosity >= v 
    then putStrLn (strBlankPad 25 msg ++ " " ++ strBlankPad 15 (show modNm) ++ " (" ++ fpathToStr fNm ++ maybe "" (\m -> ", " ++ m) mbMsg2 ++ ")")
    else return ()

putPPFile :: String -> PP_Doc -> Int -> IO ()
putPPFile fn pp wid
  =  do  {  h <- openFile fn WriteMode
         ;  hPutStrLn h (disp pp wid "")
         ;  hClose h
         }

openFPath :: FPath -> IOMode -> IO (String, Handle)
openFPath fp mode | fpathIsEmpty fp = case mode of
                                        ReadMode      -> return ("<stdin>" ,stdin )
                                        WriteMode     -> return ("<stdout>",stdout)
                                        AppendMode    -> return ("<stdout>",stdout)
                                        ReadWriteMode -> error "cannot use stdin/stdout with random access"
                  | otherwise       = do
                                        let fNm = fpathToStr fp
                                        h <- openFile fNm mode
                                        return (fNm,h)

writePP ::  (a -> PP_Doc) -> a -> FPath -> IO ()
writePP f text fp = writeToFile (show.f $ text) fp

writeToFile str fp
  = do { (fn, fh) <- openFPath fp WriteMode
       ; hPutStrLn fh str
       ; hClose fh
       }

%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Prio computation for need of parenthesis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1.ParNeed
data ParNeed =  ParNotNeeded | ParNeededLow | ParNeeded | ParNeededHigh | ParOverrideNeeded
                deriving (Eq,Ord)

type ParNeedL = [ParNeed]

parNeedApp :: HsName -> (ParNeed,ParNeedL)
parNeedApp conNm
  =  let  pr  | hsnIsArrow  conNm   =  (ParNeededLow,[ParNotNeeded,ParNeeded])
              | hsnIsProd   conNm   =  (ParOverrideNeeded,repeat ParNotNeeded)
              | otherwise           =  (ParNeeded,repeat ParNeededHigh)
     in   pr

ppParNeed :: PP p => ParNeed -> ParNeed -> p -> PP_Doc
ppParNeed locNeed globNeed p
  = par (pp p)
  where par = if globNeed > locNeed then pp_parens else id
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Co/Contra variance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[4.CoContraVariance
data CoContraVariance =  CoVariant | ContraVariant | CoContraVariant deriving (Show,Eq)
%%]

%%[4
instance PP CoContraVariance where
  pp CoVariant        = pp "CC+"
  pp ContraVariant    = pp "CC-"
  pp CoContraVariant  = pp "CCo"
%%]

%%[4.cocoOpp
cocoOpp :: CoContraVariance -> CoContraVariance
cocoOpp  CoVariant      =   ContraVariant
cocoOpp  ContraVariant  =   CoVariant
cocoOpp  _              =   CoContraVariant
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Belowness
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[7_2
data Belowness = Below | NotBelow | UnknownBelow deriving (Show,Eq,Ord)
%%]

%%[7_2
instance PP Belowness where
  pp Below        = pp "B+"
  pp NotBelow     = pp "B-"
  pp UnknownBelow = pp "B?"
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Tags (of data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8 hs
data CTag
  = CTagRec
  | CTag {ctagTyNm :: HsName, ctagNm :: HsName, ctagTag :: Int, ctagArity :: Int}
  deriving (Show,Eq,Ord)

ctagInt  =  CTag hsnInt  hsnInt  0 1
ctagChar =  CTag hsnChar hsnChar 0 1
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Misc info passed to backend
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8 hs
type CTagsMp = AssocL HsName (AssocL HsName CTag)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% AssocL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1.AssocL
type AssocL k v = [(k,v)]
%%]

%%[1.ppAssocL
ppAssocL :: (PP k, PP v) => AssocL k v -> PP_Doc
ppAssocL al = ppListSepFill "[ " " ]" ", " (map (\(k,v) -> pp k >|< ":" >|< pp v) al)
%%]

%%[9.ppAssocL -1.ppAssocL
ppAssocL' :: (PP k, PP v) => ([PP_Doc] -> PP_Doc) -> AssocL k v -> PP_Doc
ppAssocL' ppL al = ppL (map (\(k,v) -> pp k >|< ":" >|< pp v) al)

ppAssocL :: (PP k, PP v) => AssocL k v -> PP_Doc
ppAssocL = ppAssocL' (pp_block "[" "]" ",")

ppAssocLV :: (PP k, PP v) => AssocL k v -> PP_Doc
ppAssocLV = ppAssocL' vlist
%%]

%%[2
assocLMap :: (k -> v -> (k',v')) -> AssocL k v -> AssocL k' v'
assocLMap f = map (uncurry f)

assocLMapElt :: (v -> v') -> AssocL k v -> AssocL k v'
assocLMapElt f = assocLMap (\k v -> (k,f v))

assocLMapKey :: (k -> k') -> AssocL k v -> AssocL k' v
assocLMapKey f = assocLMap (\k v -> (f k,v))
%%]

%%[1
assocLKeys :: AssocL k v -> [k]
assocLKeys = map fst
%%]

%%[7
assocLElts :: AssocL k v -> [v]
assocLElts = map snd
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Fitting mode (should be in FitsIn, but here it avoids mut rec modules)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[4.FIMode
data FIMode  =  FitSubLR
             |  FitSubRL
             |  FitUnify
%%]
%%[4_2
             |  FitMeet
             |  FitJoin
%%]
%%[4
             deriving (Eq,Ord)
%%]

%%[4
fimOpp :: FIMode -> FIMode
fimOpp m
  =  case m of
       FitSubLR  -> FitSubRL
       FitSubRL  -> FitSubLR
%%]
%%[4_2
       FitMeet   -> FitJoin
       FitJoin   -> FitMeet
%%]
%%[4
       _         -> m
%%]

%%[4
fimSwapCoCo :: CoContraVariance -> FIMode -> FIMode
fimSwapCoCo coco m = case coco of {ContraVariant -> fimOpp m; _ -> m}
%%]

%%[4
instance Show FIMode where
  show FitSubLR  = "<="
  show FitSubRL  = ">="
  show FitUnify  = "=="
%%]
%%[4_2
  show FitMeet   = "=^="
  show FitJoin   = "=v="
%%]

%%[4
instance PP FIMode where
  pp m = pp (show m)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Misc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1.Misc.hdAndTl
hdAndTl' :: a -> [a] -> (a,[a])
hdAndTl' _ (a:as) = (a,as)
hdAndTl' n []     = (n,[])

hdAndTl :: [a] -> (a,[a])
hdAndTl = hdAndTl' undefined
%%]

%%[2.unions
unions :: Eq a => [[a]] -> [a]
unions = foldr union []
%%]

%%[4.listCombineUniq
listCombineUniq :: Eq a => [[a]] -> [a]
listCombineUniq = nub . concat
%%]

%%[7_2
threadMap :: (a -> c -> (b, c)) -> c -> [a] -> ([b], c)
threadMap f c = foldr (\a (bs, c) -> let (b, c') = f a c in (b:bs, c')) ([], c)
%%]

%%[7_2

groupAllBy :: Ord b => (a -> b) -> [a] -> [[a]]
groupAllBy f = Map.elems . foldr (\v -> Map.insertWith (++) (f v) [v]) Map.empty 

%%]

%%[7_2

mergeListMap :: Ord k => Map k [a] -> Map k [a] -> Map k [a]
mergeListMap = Map.unionWith (++)

%%]

%%[88
sortOn :: Ord b => (a -> b) -> [a] -> [a]
sortOn = sortByOn compare

sortByOn :: (b -> b -> Ordering) -> (a -> b) -> [a] -> [a]
sortByOn cmp sel = sortBy (\e1 e2 -> sel e1 `cmp` sel e2)

groupOn :: Eq b => (a -> b) -> [a] -> [[a]]
groupOn sel = groupBy (\e1 e2 -> sel e1 == sel e2)

groupSortOn :: Ord b => (a -> b) -> [a] -> [[a]]
groupSortOn sel = groupOn sel . sortOn sel
%%]

%%[90
groupByOn :: (b -> b -> Bool) -> (a -> b) -> [a] -> [[a]]
groupByOn eq sel = groupBy (\e1 e2 -> sel e1 `eq` sel e2)

groupSortByOn :: (b -> b -> Ordering) -> (a -> b) -> [a] -> [[a]]
groupSortByOn cmp sel = groupByOn (\e1 e2 -> cmp e1 e2 == EQ) sel . sortByOn cmp sel
%%]

%%[8 export(strBlankPad)
strBlankPad :: Int -> String -> String
strBlankPad n s = s ++ replicate (n - length s) ' '
%%]

%%[9
snd3 :: (a,b,c) -> b
snd3 (a,b,c) = b

thd :: (a,b,c) -> c
thd (a,b,c) = c
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Verbosity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
data Verbosity
  = VerboseQuiet | VerboseNormal | VerboseALot
  deriving (Eq,Ord)
%%]


%%[1

-- | Base Public API (provisional, to be refactored)
--
module %%@{%{EH}%%}Base.API
  (
  -- * Opts
  -- | Options to the compiler.
    EHCOpts
  , defaultEHCOpts

  -- * Names
  -- | Names in UHC have to be of the form P1.P2....Pn.Ident . All names
  -- in module M must have the form M.Ident . Datatype and constructor names
  -- have to start with an uppercase letter, functions with a lowercase letter.
  , mkUniqueHsName
  , mkHsName
  , mkHsName1
  , addHsNamePrefix

  -- * Constructor Tags
  -- From Base.Common
  , CTag

  -- * Names
  , HsName

  -- * Error
  , Err

  -- * Misc
%%[[99
  , hsnEhcRunMain
%%]]
%%[[8
  , hsnMain
%%]]
  )
  where

import %%@{%{EH}%%}Base.Common
import %%@{%{EH}%%}Base.HsName
import %%@{%{EH}%%}Base.HsName.Builtin
import %%@{%{EH}%%}Opts
import %%@{%{EH}%%}Error

import qualified Data.Map as M

-- **************************************
-- Names
-- **************************************

-- | Creates a new Core name. All names generated with this function live in
-- the "Core API" namespace and will not collide with names in other namespaces.
-- Names in the "Core API" namespace cannot be called from Haskell code.
--
-- Use this function to create names used only inside Core code generated by your own Compiler,
-- e.g. module-scoped or local functions.
mkUniqueHsName :: String    -- ^ Name prefix. Used to distinguish names generated by different API consumers,
                            -- but may also be used to differentiate between different varieties by one API consumer.
                            -- Use reverse-dns notation if possible, e.g. "nl.uu.agda.identOfVarietyA"
    -> [String]             -- ^ The module prefix.
    -> String               -- ^ The name to make unique.
    -> HsName
-- UHC expects names to be of the _Modf variety. If _Base/hsnFromString is used
-- instead things start to break, e.g. calling functions defined in other packages.
mkUniqueHsName prefix = hsnMkModf1 (M.singleton HsNameUniqifier_CoreAPI [HsNameUnique_String prefix])

-- | Creates a new Core name. The generated name lives in the default namespace,
-- hence may clash with Haskell-defined names.
mkHsName :: [String]    -- ^ The module prefix.
    -> String           -- ^ The local name of the identifier.
    -> HsName
mkHsName = hsnMkModf1 M.empty

-- | Creates a new Core name. The generated name lives in the default namespace,
-- hence may clash with Haskell-defined names.
mkHsName1 :: String
    -> HsName
mkHsName1 nm = mkHsName (init xs) (last xs)
  -- TODO there is probably something like that somewhere in UHC?
  where xs = splitBy '.' nm
        splitBy :: Eq a => a -> [a] -> [[a]]
        splitBy sep = (foldr (\x (a1:as) -> if x == sep then ([]:a1:as) else ((x:a1):as)) [[]])

-- | Adds an additional prefix to a 'HsName'. This can be used to derive a new
-- unique name from an existing name.
addHsNamePrefix :: String -> HsName -> HsName
addHsNamePrefix prefix name = hsnUniqifyStr HsNameUniqifier_CoreAPI prefix name

-- | Local helper function. Converts string names to HsNames.
hsnMkModf1 :: HsNameUniqifierMp -> [String] -> String -> HsName
-- UHC expects names to be of the _Modf variety. If _Base/hsnFromString is used
-- instead things start to break, e.g. calling functions defined in other packages.
hsnMkModf1 uniq mods nm = hsnMkModf mods (hsnFromString nm) uniq

%%]

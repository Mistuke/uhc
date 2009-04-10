{- ----------------------------------------------------------------------------------------
   what    : array
   expected: ok
---------------------------------------------------------------------------------------- -}

module DataArray1 where

import Data.Array

main :: IO ()
main
  = do let l  = 0 :: Int
           h  = 4 :: Int
           a1 = listArray (l,h) [h*10,(h-1)*10 ..]
       putStrLn (show (a1 ! l))
       putStrLn (show (assocs a1))
       putStrLn (show (bounds a1))
       putStrLn (show (indices a1))
       putStrLn (show a1)


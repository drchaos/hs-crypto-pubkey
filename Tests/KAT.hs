{-# LANGUAGE OverloadedStrings #-}
module KAT where

import Test.Framework (Test, defaultMain, testGroup)
import Test.Framework.Providers.HUnit (testCase)
import Test.QuickCheck
import Test.QuickCheck.Test
import Test.HUnit
import System.IO (hFlush, stdout)

import Data.ByteString (ByteString)
import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as BC

import Crypto.PubKey.RSA
import Crypto.PubKey.MaskGenFunction
import qualified Crypto.Hash.SHA1 as SHA1

import KAT.OAEP
import KAT.PSS
import KAT.DSA

data VectorMgf = VectorMgf { seed :: ByteString
                           , dbMask :: ByteString
                           }

doMGFTest (i, vmgf) = testCase (show i) (dbMask vmgf @=? actual)
    where actual = mgf1 SHA1.hash (seed vmgf) (B.length $ dbMask vmgf)

vectorsMGF =
    [ VectorMgf
        { seed = "\xdf\x1a\x89\x6f\x9d\x8b\xc8\x16\xd9\x7c\xd7\xa2\xc4\x3b\xad\x54\x6f\xbe\x8c\xfe"
        , dbMask = "\x66\xe4\x67\x2e\x83\x6a\xd1\x21\xba\x24\x4b\xed\x65\x76\xb8\x67\xd9\xa4\x47\xc2\x8a\x6e\x66\xa5\xb8\x7d\xee\x7f\xbc\x7e\x65\xaf\x50\x57\xf8\x6f\xae\x89\x84\xd9\xba\x7f\x96\x9a\xd6\xfe\x02\xa4\xd7\x5f\x74\x45\xfe\xfd\xd8\x5b\x6d\x3a\x47\x7c\x28\xd2\x4b\xa1\xe3\x75\x6f\x79\x2d\xd1\xdc\xe8\xca\x94\x44\x0e\xcb\x52\x79\xec\xd3\x18\x3a\x31\x1f\xc8\x97\x39\xa9\x66\x43\x13\x6e\x8b\x0f\x46\x5e\x87\xa4\x53\x5c\xd4\xc5\x9b\x10\x02\x8d"
        }
    ]

katTests =
    [ testGroup "MGF1" $ map doMGFTest (zip [0..] vectorsMGF)
    , pssTests
    , oaepTests
    , dsaTests
    ]

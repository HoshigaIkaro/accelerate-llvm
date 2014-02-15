{-# LANGUAGE EmptyDataDecls #-}
{-# LANGUAGE TypeFamilies   #-}
-- |
-- Module      : Data.Array.Accelerate.LLVM.Native.Target
-- Copyright   :
-- License     :
--
-- Maintainer  : Trevor L. McDonell <tmcdonell@nvidia.com>
-- Stability   : experimental
-- Portability : non-portable (GHC extensions)
--

module Data.Array.Accelerate.LLVM.Native.Target
  where

-- llvm-general
import LLVM.General.Target                                      hiding ( Target )

-- accelerate
import Data.Array.Accelerate.LLVM.Target
import Data.Array.Accelerate.LLVM.Native.Compile

-- standard library
import Control.Monad.Error
import System.IO.Unsafe
import Foreign.Ptr


-- | Native machine code JIT execution target
--
data Native

instance Target Native where
  data ExecutableR Native = NativeR { executableR :: [FunPtr ()] }

  {-# NOINLINE targetTriple #-}
  targetTriple _ =
    Just $ unsafePerformIO getProcessTargetTriple

  {-# NOINLINE targetDataLayout #-}
  targetDataLayout _ = unsafePerformIO $
    either error Just `fmap` (runErrorT $ withDefaultTargetMachine getTargetMachineDataLayout)

  compileForTarget m n =
    NativeR `fmap` compileForMCJIT m n


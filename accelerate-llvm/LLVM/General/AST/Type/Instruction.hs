{-# LANGUAGE DataKinds      #-}
{-# LANGUAGE GADTs          #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE RankNTypes     #-}
{-# LANGUAGE TypeOperators  #-}
-- |
-- Module      : LLVM.General.AST.Type.Instruction
-- Copyright   : [2015] Trevor L. McDonell
-- License     : BSD3
--
-- Maintainer  : Trevor L. McDonell <tmcdonell@cse.unsw.edu.au>
-- Stability   : experimental
-- Portability : non-portable (GHC extensions)
--

module LLVM.General.AST.Type.Instruction
  where

import LLVM.General.AST.Type.Bits
import LLVM.General.AST.Type.Name
import LLVM.General.AST.Type.Operand
import LLVM.General.AST.Type.Constant

import Data.Array.Accelerate.Type


-- | <http://llvm.org/docs/LangRef.html#metadata-nodes-and-metadata-strings>
--
-- Metadata can be attached to an instruction.
--
-- type InstructionMetadata = forall a. [(String, MetadataNode a)]         -- FIXME ??


-- | <http://llvm.org/docs/LangRef.html#terminators>
--
-- TLM: well, I don't think the types of these terminators make any sense. When
--      we branch, we are not propagating a particular value, just moving the
--      program counter, and anything we have declared already is available for
--      later computations. Maybe, we can make some of this explicit in the
--      @phi@ node?
--
data Terminator a where
  -- | <http://llvm.org/docs/LangRef.html#ret-instruction>
  --
  Ret           :: Terminator ()

  -- | <http://llvm.org/docs/LangRef.html#ret-instruction>
  --
  RetVal        :: Operand a
                -> Terminator a
  -- | <http://llvm.org/docs/LangRef.html#br-instruction>
  --
  Br            :: Label
                -> Terminator ()

  -- | <http://llvm.org/docs/LangRef.html#br-instruction>
  --
  CondBr        :: Operand Bool
                -> Label
                -> Label
                -> Terminator ()

  -- | <http://llvm.org/docs/LangRef.html#switch-instruction>
  --
  Switch        :: Operand a
                -> Label
                -> [(Constant a, Label)]
                -> Terminator ()


-- | Predicate for comparison instruction
--
data Predicate = EQ | NE | LT | LE | GT | GE

-- | Attributes for the function call instruction
--
data FunctionAttribute
  = NoReturn
  | NoUnwind
  | ReadOnly
  | ReadNone


-- | Non-terminating instructions
--
--  * <http://llvm.org/docs/LangRef.html#binaryops>
--
--  * <http://llvm.org/docs/LangRef.html#bitwiseops>
--
--  * <http://llvm.org/docs/LangRef.html#memoryops>
--
--  * <http://llvm.org/docs/LangRef.html#otherops>
--
--
data Instruction a where
  -- Binary Operations
  -- <http://llvm.org/docs/LangRef.html#binary-operations>

  -- | <http://llvm.org/docs/LangRef.html#add-instruction>
  --   <http://llvm.org/docs/LangRef.html#fadd-instruction>
  --
  Add           :: NumType a
                -> Operand a
                -> Operand a
                -> Instruction a

  -- | <http://llvm.org/docs/LangRef.html#sub-instruction>
  --   <http://llvm.org/docs/LangRef.html#fsub-instruction>
  --
  Sub           :: NumType a
                -> Operand a
                -> Operand a
                -> Instruction a

  -- | <http://llvm.org/docs/LangRef.html#mul-instruction>
  --   <http://llvm.org/docs/LangRef.html#fmul-instruction>
  --
  Mul           :: NumType a
                -> Operand a
                -> Operand a
                -> Instruction a

  -- | <http://llvm.org/docs/LangRef.html#udiv-instruction>
  --   <http://llvm.org/docs/LangRef.html#sdiv-instruction>
  --
  Quot          :: IntegralType a
                -> Operand a
                -> Operand a
                -> Instruction a

  -- | <http://llvm.org/docs/LangRef.html#urem-instruction>
  --   <http://llvm.org/docs/LangRef.html#srem-instruction>
  --
  Rem           :: IntegralType a
                -> Operand a
                -> Operand a
                -> Instruction a

  -- | <http://llvm.org/docs/LangRef.html#fdiv-instruction>
  --
  Div           :: FloatingType a
                -> Operand a
                -> Operand a
                -> Instruction a

  -- | <http://llvm.org/docs/LangRef.html#shl-instruction>
  --
  ShiftL        :: IntegralType a
                -> Operand a
                -> Operand Int
                -> Instruction a

  -- | <http://llvm.org/docs/LangRef.html#lshr-instruction>
  --
  ShiftRL       :: IntegralType a
                -> Operand a
                -> Operand Int
                -> Instruction a

  -- | <http://llvm.org/docs/LangRef.html#ashr-instruction>
  ShiftRA       :: IntegralType a
                -> Operand a
                -> Operand Int
                -> Instruction a

  -- Bitwise Binary Operations
  -- <http://llvm.org/docs/LangRef.html#bitwise-binary-operations>

  -- | <http://llvm.org/docs/LangRef.html#and-instruction>
  --
  BAnd          :: IntegralType a
                -> Operand a
                -> Operand a
                -> Instruction a

  -- | <http://llvm.org/docs/LangRef.html#or-instruction>
  --
  BOr           :: IntegralType a
                -> Operand a
                -> Operand a
                -> Instruction a

  -- | <http://llvm.org/docs/LangRef.html#xor-instruction>
  --
  BXor          :: IntegralType a
                -> Operand a
                -> Operand a
                -> Instruction a

  -- Vector Operations
  -- <http://llvm.org/docs/LangRef.html#vector-operations>
  -- ExtractElement
  -- InsertElement
  -- ShuffleVector

  -- Aggregate Operations
  -- <http://llvm.org/docs/LangRef.html#aggregate-operations>
  -- ExtractValue
  -- InsertValue

  -- Memory Access and Addressing Operations
  -- <http://llvm.org/docs/LangRef.html#memory-access-and-addressing-operations>
  -- Alloca
  -- Load
  -- Store
  -- GetElementPtr
  -- Fence
  -- CmpXchg
  -- AtomicRMW

  -- | <http://llvm.org/docs/LangRef.html#trunc-to-instruction>
  --
  Trunc         :: (BitSize a > BitSize b)      -- TLM: expelling this constraint may be tricky
                => IntegralType a               -- Integral OR Char OR Bool ):
                -> IntegralType b
                -> Operand a
                -> Instruction b

  -- | <http://llvm.org/docs/LangRef.html#fptrunc-to-instruction>
  --
  FTrunc        :: (BitSize a > BitSize b)
                => FloatingType a
                -> FloatingType b
                -> Operand a
                -> Instruction b

  -- | <http://llvm.org/docs/LangRef.html#zext-to-instruction>
  --   <http://llvm.org/docs/LangRef.html#sext-to-instruction>
  --
  Ext           :: (BitSize a < BitSize b)
                => IntegralType a               -- Integral OR Char OR Bool ):
                -> IntegralType b
                -> Operand a
                -> Instruction b

  -- | <http://llvm.org/docs/LangRef.html#fpext-to-instruction>
  --
  FExt          :: (BitSize a < BitSize b)
                => FloatingType a
                -> FloatingType b
                -> Operand a
                -> Instruction b

  -- | <http://llvm.org/docs/LangRef.html#fptoui-to-instruction>
  --   <http://llvm.org/docs/LangRef.html#fptosi-to-instruction>
  --
  FPToInt       :: FloatingType a
                -> IntegralType b
                -> Operand a
                -> Instruction b

  -- | <http://llvm.org/docs/LangRef.html#uitofp-to-instruction>
  --   <http://llvm.org/docs/LangRef.html#sitofp-to-instruction>
  --
  IntToFP       :: IntegralType a
                -> FloatingType b
                -> Operand a
                -> Instruction b

  -- | <http://llvm.org/docs/LangRef.html#bitcast-to-instruction>
  --
  BitCast       :: (BitSizeEq a b ~ True)
                => ScalarType b
                -> Operand a
                -> Instruction b

  -- PtrToInt
  -- IntToPtr
  -- AddrSpaceCast

  -- Other Operations
  -- <http://llvm.org/docs/LangRef.html#other-operations>

  -- | <http://llvm.org/docs/LangRef.html#icmp-instruction>
  --   <http://llvm.org/docs/LangRef.html#fcmp-instruction>
  --
  Cmp           :: ScalarType a
                -> Predicate
                -> Operand a
                -> Operand a
                -> Instruction Bool

  -- | <http://llvm.org/docs/LangRef.html#phi-instruction>
  --
  Phi           :: ScalarType a
                -> [(Operand a, Label)]
                -> Instruction a

  -- | <http://llvm.org/docs/LangRef.html#call-instruction>
  --
  Call          :: Function args t
                -> [FunctionAttribute]
                -> Instruction t

  -- | <http://llvm.org/docs/LangRef.html#select-instruction>
  Select        :: ScalarType a
                -> Operand Bool
                -> Operand a
                -> Operand a
                -> Instruction a

  -- VAArg
  -- LandingPad


-- data Function t where
--   Body :: ScalarType r -> Label ->      Function r
--   Lam  :: ScalarType a -> Function r -> Function (a -> r)

-- data Function args t where
--   Body :: ScalarType r -> Label                        -> Function ()       r
--   Lam  :: ScalarType a -> Operand a -> Function args t -> Function (args,a) t

data Function args t where
  Body :: ScalarType r -> Label                        -> Function '[]         r
  Lam  :: ScalarType a -> Operand a -> Function args t -> Function (a ': args) t

data HList (l :: [*]) where
  HNil  :: HList '[]
  HCons :: e -> HList l -> HList (e ': l)


-- | Instances of instructions may be given a name, allowing their results to be
-- referenced as Operands. Instructions returning void (e.g. function calls)
-- don't need names.
--
data Named ins a where
  (:=) :: Name a -> ins a -> Named ins a
  Do   :: ins ()          -> Named ins ()


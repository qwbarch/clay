{-# LANGUAGE
    EmptyDataDecls
  , OverloadedStrings
  , GeneralizedNewtypeDeriving
  , FlexibleInstances
  , ExistentialQuantification
  , StandaloneDeriving
  #-}
module Clay.Size
(

-- * Size type.
  Size
, LengthUnit
, Percentage
, nil
, unitless

-- * Size constructors.

, cm
, mm
, inches
, px
, pt
, pc
, em
, ex
, pct
, rem
, vw
, vh
, vmin
, vmax

-- * Calculation operators for calc

, (@+@)

-- * Shorthands for properties that can be applied separately to each box side.

, sym
, sym2
, sym3

-- * Angle type.

, Angle
, Deg
, Rad
, Grad
, Turn

-- * Constructing angles.

, deg
, rad
, grad
, turn

)
where

import Data.Monoid
import Prelude hiding (rem)
import Data.Text (Text)

import Clay.Common
import Clay.Property
import Clay.Stylesheet

-------------------------------------------------------------------------------

-- | Sizes can be given using a length unit (e.g. em, px).
data LengthUnit

-- | Sizes can be given in percentages.
data Percentage

data Size a = SimpleSize Text | forall b c. SumSize (Size b) (Size c)

deriving instance Show (Size a)

sizeToText :: Size a -> Text
sizeToText (SimpleSize txt) = txt
sizeToText (SumSize a b) = "(" <> sizeToText a <> " + " <> sizeToText b <> ")"

instance Val (Size a) where
  value (SimpleSize a) = value a
  value s@(SumSize _ _) = Value $ browsers <> Plain ("calc" <> sizeToText s)

instance Auto (Size a) where auto = Clay.Common.auto
instance Normal (Size a) where normal = Clay.Common.normal
instance Inherit (Size a) where inherit = Clay.Common.inherit
instance None (Size a) where none = Clay.Common.none

-- | Zero size.
nil :: Size a
nil = SimpleSize "0"

-- | Unitless size (as recommended for line-height).
unitless :: Double -> Size a
unitless i = SimpleSize ((plain . unValue . value) i)

cm, mm, inches, px, pt, pc :: Double -> Size LengthUnit

-- | Size in centimeters.
cm i = SimpleSize (cssDoubleText i <> "cm")

-- | Size in millimeters.
mm i = SimpleSize (cssDoubleText i <> "mm")

-- | Size in inches (1in = 2.54 cm).
inches i = SimpleSize (cssDoubleText i <> "in")

-- | Size in pixels.
px i = SimpleSize (cssDoubleText i <> "px")

-- | Size in points (1pt = 1/72 of 1in).
pt i = SimpleSize (cssDoubleText i <> "pt")

-- | Size in picas (1pc = 12pt).
pc i = SimpleSize (cssDoubleText i <> "pc")

em, ex, rem, vw, vh, vmin, vmax :: Double -> Size LengthUnit

-- | Size in em's (computed cssDoubleText of the font-size).
em i = SimpleSize (cssDoubleText i <> "em")

-- | SimpleSize in ex'es (x-height of the first avaliable font).
ex i = SimpleSize (cssDoubleText i <> "ex")

-- | SimpleSize in rem's (em's, but always relative to the root element).
rem i = SimpleSize (cssDoubleText i <> "rem")

-- | SimpleSize in vw's (1vw = 1% of viewport width).
vw i = SimpleSize (cssDoubleText i <> "vw")

-- | SimpleSize in vh's (1vh = 1% of viewport height).
vh i = SimpleSize (cssDoubleText i <> "vh")

-- | SimpleSize in vmin's (the smaller of vw or vh).
vmin i = SimpleSize (cssDoubleText i <> "vmin")

-- | SimpleSize in vmax's (the larger of vw or vh).
vmax i = SimpleSize (cssDoubleText i <> "vmax")

-- | SimpleSize in percents.
pct :: Double -> Size Percentage
pct i = SimpleSize (cssDoubleText i <> "%")

instance Num (Size LengthUnit) where
  fromInteger = px . fromInteger
  (+)    = error   "plus not implemented for Size"
  (*)    = error  "times not implemented for Size"
  abs    = error    "abs not implemented for Size"
  signum = error "signum not implemented for Size"
  negate = error "negate not implemented for Size"

instance Fractional (Size LengthUnit) where
  fromRational = px . fromRational
  recip  = error  "recip not implemented for Size"

instance Num (Size Percentage) where
  fromInteger = pct . fromInteger
  (+)    = error   "plus not implemented for Size"
  (*)    = error  "times not implemented for Size"
  abs    = error    "abs not implemented for Size"
  signum = error "signum not implemented for Size"
  negate = error "negate not implemented for Size"

instance Fractional (Size Percentage) where
  fromRational = pct . fromRational
  recip  = error  "recip not implemented for Size"

-- | Plus operator to combine sizes into calc function
infixl 6 @+@
(@+@) :: Size a -> Size a -> Size a
a @+@ b = SumSize a b

-------------------------------------------------------------------------------

sym :: (a -> a -> a -> a -> Css) -> a -> Css
sym k a = k a a a a

sym3 :: (a -> a -> a -> a -> Css) -> a -> a -> a -> Css
sym3 k tb l r = k tb l tb r

sym2 :: (a -> a -> a -> a -> Css) -> a -> a -> Css
sym2 k tb lr = k tb lr tb lr

-------------------------------------------------------------------------------

data Deg
data Rad
data Grad
data Turn

newtype Angle a = Angle Value
  deriving (Val, Auto, Inherit, Other)

-- | Angle in degrees.
deg :: Double -> Angle Deg
deg i = Angle (value i <> "deg")

-- | Angle in radians.
rad :: Double -> Angle Rad
rad i = Angle (value i <> "rad")

-- | Angle in gradians (also knows as gons or grades).
grad :: Double -> Angle Grad
grad i = Angle (value i <> "grad")

-- | Angle in turns.
turn :: Double -> Angle Turn
turn i = Angle (value i <> "turn")

instance Num (Angle Deg) where
  fromInteger = deg . fromInteger
  (+)    = error   "plus not implemented for Angle"
  (*)    = error  "times not implemented for Angle"
  abs    = error    "abs not implemented for Angle"
  signum = error "signum not implemented for Angle"
  negate = error "negate not implemented for Angle"

instance Fractional (Angle Deg) where
  fromRational = deg . fromRational
  recip  = error  "recip not implemented for Angle"

instance Num (Angle Rad) where
  fromInteger = rad . fromInteger
  (+)    = error   "plus not implemented for Angle"
  (*)    = error  "times not implemented for Angle"
  abs    = error    "abs not implemented for Angle"
  signum = error "signum not implemented for Angle"
  negate = error "negate not implemented for Angle"

instance Fractional (Angle Rad) where
  fromRational = rad . fromRational
  recip  = error  "recip not implemented for Angle"

instance Num (Angle Grad) where
  fromInteger = grad . fromInteger
  (+)    = error   "plus not implemented for Angle"
  (*)    = error  "times not implemented for Angle"
  abs    = error    "abs not implemented for Angle"
  signum = error "signum not implemented for Angle"
  negate = error "negate not implemented for Angle"

instance Fractional (Angle Grad) where
  fromRational = grad . fromRational
  recip  = error  "recip not implemented for Angle"

instance Num (Angle Turn) where
  fromInteger = turn . fromInteger
  (+)    = error   "plus not implemented for Angle"
  (*)    = error  "times not implemented for Angle"
  abs    = error    "abs not implemented for Angle"
  signum = error "signum not implemented for Angle"
  negate = error "negate not implemented for Angle"

instance Fractional (Angle Turn) where
  fromRational = turn . fromRational
  recip  = error  "recip not implemented for Angle"

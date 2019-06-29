---
title: 'Primer on Probabilities: A basis for simulating WoW Classic'
---

Recently I've been getting very excited for the re-release of the original World of Warcraft, dubbed _Classic WoW_. When I was younger, particularly during the _Burning Crusade_ WoW expansion, I discovered a community which extensively modeled the combat mechanics of the game with the intent on performing optimally in many person encounters called _raids_. Back then there was a forum called _Elitist Jerks_ that cultivated this analysis we now refer to as _Theorycrafting_. Much has changed since those years and I figured I could sate my curiosity before the release date by attempting this sort of modeling in Haskell.

## Probability
A while back, a colleague of mine showed me a really cool paper on [probabilistic programming](http://web.engr.oregonstate.edu/~erwig/papers/PFP_JFP06.pdf) in Haskell, which is now the basis for this project. I don't intend this to be a monad tutorial, so you'll need some prerequisite knowledge to really grok the code. Otherwise, enjoy following along from a high level.

Here is the base definition for a probability distribution along with a `Show` instance (so we can print it) and `Applicative`/`Monad` instances to combine distributions.
```haskell
{-# LANGUAGE DeriveFunctor          #-}

import           Text.Printf         (printf)

newtype Dist a = Dist {unDist :: [(a, Float)]} deriving (Functor)

instance Show a => Show (Dist a) where
  show (Dist xs) = concat $
    flip map xs (\(x,p) -> printf "%.3f %s\n" p (show x))

instance Applicative Dist where
    pure x              = Dist [(x, 1)]
    Dist fs <*> Dist xs = Dist
        [(f x, p1 * p2) | (f, p1) <- fs, (x, p2) <- xs]

instance Monad Dist where
    Dist xs >>= f = Dist
        [(y, p1 * p2) | (x, p1) <- xs, (y, p2) <- unDist (f x)]
```

As an example, let's model a 6-sided die: 

```haskell
-- | d6 is a six sided die roll
d6 :: Dist Int
d6 = Dist [(x, 1 / 6) | x <- [1 .. 6]]
```

evaluating it yields
```haskell
d6
0.167 1
0.167 2
0.167 3
0.167 4
0.167 5
0.167 6
```

Due to the `Monad` implementation, we can combine them (using a new `dedup` function to group by identical rolls):
```haskell
import qualified Data.Map            as M

-- | dedup will combine identical events, summing their probabilities
dedup :: Ord a => Dist a -> Dist a
dedup (Dist xs) =
  Dist $ M.toList $ M.fromListWith (+) xs

result = dedup $ do
  x <- d6
  y <- d6
  return $ (x + y) == 7
```
->
```haskell
result
0.833 False
0.167 True
```

Pretty cool! What else can we do? Hrm, what if we could discard any instances that don't meet a criteria. Hey, that sounds a lot like `Alternative`!
```haskell
instance Alternative Dist where
  empty = Dist []
  dist@(Dist (_:_)) <|> _ = dist
  _ <|> y = y
```
This gives us the nifty [`guard`](http://hackage.haskell.org/package/base-4.12.0.0/docs/Control-Monad.html#v:guard) function which returns `empty` on false predicates, thus short-circuiting monadic computations via the `MonadPlus` [law](https://en.wikibooks.org/wiki/Haskell/Alternative_and_MonadPlus#Alternative_and_MonadPlus_laws) `mzero >>= f  =  mzero`. This is automatically derived because `Dist` is an instance of both `Alternative` and `Monad`.

Ok, that may be a fair bit to take in. No worries, it ends up allowing us to clip off all the rolls that aren't 7 from our previous distribution:
```haskell
result = dedup $ do
  x <- d6
  y <- d6
  let is7 = x + y == 7
  guard is7
  return is7
```
->
```haskell
result
0.167 True
```
Notice how there are no more `False` events. This is useful if we want to clip out events that don't match a predicate.

This can be easily turned into a helper function:
```haskell
-- | distribution that matches a predicate
distWhere :: (a -> Bool) -> Dist a -> Dist a
distWhere f dist = do
  x <- dist
  guard (f x)
  return x
```

## WoW
Now that we've got a feeling for how these compose, lets take a look at a more involved example. When a spell lands, it falls into one of three categories: Miss (no damage), Hit (normal damage), and Crit (More damage).
```haskell
data SpellResolve = Miss | Hit | Crit
  deriving (Eq, Ord, Show)
```
Using this, we can sketch out a basic model for spell casting (40% `Miss`, 30% `Hit`, 30% `Crit`).
```haskell
castDist :: Dist SpellResolve
castDist =
  Dist [(Miss, 0.4), (Hit, 0.3), (Crit, 0.3)]
```

One thing that's commonly needed is the ability to model multiple rounds of combat:
```haskell
-- | chains a distribution for a number of rounds
rounds :: Int -> Dist a -> Dist [a]
rounds 0 _ = Dist [([],1)] -- pre-seeded with empty list
rounds n dist = (:) <$> dist <*> rounds (n - 1) dist
```
Notice how we pre-seeded the base case with a distribution of an empty list. This is because we're moving from `Dist SpellResult` -> `Dist [SpellResult]` and we don't want to short-circuit the computation by operating on a distribution with no events as that is the list monad's `mzero` and `empty` definition.

Giving it a run yields:
```haskell
res = rounds 2 castDist
```
->
```haskell
res
0.160 [Miss,Miss]
0.120 [Miss,Hit]
0.120 [Miss,Crit]
0.120 [Hit,Miss]
0.090 [Hit,Hit]
0.090 [Hit,Crit]
0.120 [Crit,Miss]
0.090 [Crit,Hit]
0.090 [Crit,Crit]
```

One of the limitations in modeling WoW mechanics is that we don't have a game engine to actually run combat numbers a bajillion times and then average them out. Instead, we try to approximate outcomes via probabilities, bu without access to actual raid environments, we're rather unsuited for handling certain mechanics.

## Improved Shadow Bolt
One of these mechanics is the Warlock talent, _Improved Shadow Bolt_. With 5 points allocated, it reads:

> Your Shadow Bolt critical strikes increase shadow damage done to the target by 20% until 4 non-periodic damage sources are applied. Effect lasts a maximum of 12 seconds.

Since we don't have access to the rest of the raid, we will need to find another way of determining the effects of this skill as we can't calculate how much shadow damage other raid members are doing. Instead, we approximate by assuming all other warlocks are equally geared and we ignore other sources of shadow damage, i.e. from a Shadow Priest. We'll use the current Warlock's stats as a way to approximate this affect raid wide. Since we're not running long simulations, we'll try to find the _average effect of this skill per crit_ and apply it to the warlock as a flat bonus on critical spells. This front loads the damage calculations and lets us avoid running long multi-round simulations.

Ok then, what do we need?
- The warlock's crit chance
- The warlocks base damage (ellided from this post for simplicity's sake)
- A function which simulates 4 rounds of our distribution, removing anything after the first crit. Crits trigger a new application of Improved Shadow Bolt, effectively _clipping_ this debuff and replacing it. As such, only the first crit's damage can be applied to the benefit of this Improved Shadow Bolt.

```haskell
impShadowBolt :: Dist [SpellResolve]
impShadowBolt =
  trim <$> rounds 4 castDist
  where
    trim (Crit:xs) = [Crit]
    trim (x:xs)    = x : trim xs
    trim []        = []

res = dedup $ impShadowBolt
```
->
```haskell
res
0.026 [Miss,Miss,Miss,Miss]
0.019 [Miss,Miss,Miss,Hit]
0.019 [Miss,Miss,Miss,Crit]
0.019 [Miss,Miss,Hit,Miss]
0.014 [Miss,Miss,Hit,Hit]
0.014 [Miss,Miss,Hit,Crit]
0.048 [Miss,Miss,Crit]
0.019 [Miss,Hit,Miss,Miss]
0.014 [Miss,Hit,Miss,Hit]
0.014 [Miss,Hit,Miss,Crit]
0.014 [Miss,Hit,Hit,Miss]
0.011 [Miss,Hit,Hit,Hit]
0.011 [Miss,Hit,Hit,Crit]
0.036 [Miss,Hit,Crit]
0.120 [Miss,Crit]
0.019 [Hit,Miss,Miss,Miss]
0.014 [Hit,Miss,Miss,Hit]
0.014 [Hit,Miss,Miss,Crit]
0.014 [Hit,Miss,Hit,Miss]
0.011 [Hit,Miss,Hit,Hit]
0.011 [Hit,Miss,Hit,Crit]
0.036 [Hit,Miss,Crit]
0.014 [Hit,Hit,Miss,Miss]
0.011 [Hit,Hit,Miss,Hit]
0.011 [Hit,Hit,Miss,Crit]
0.011 [Hit,Hit,Hit,Miss]
0.008 [Hit,Hit,Hit,Hit]
0.008 [Hit,Hit,Hit,Crit]
0.027 [Hit,Hit,Crit]
0.090 [Hit,Crit]
0.300 [Crit]
```
That's it! Now we'd just have to tally up the expected damage from these and multiply it by the amount of the Imp Shadow Bolt modifier (20%).

Hopefully this has wet your appetite -- I've been having a blast running simulations like these. The full repo is [here](https://github.com/owen-d/vanilla) for those interested. I'll be following up with another post detailing how we determine cast rotations for warlocks which need to use life tap intermitently for mana.

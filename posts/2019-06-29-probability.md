---
title: Primer on Probabilities: A basis for simulating WoW Classic
---

Recently I've been getting very excited for the re-release of the original World of Warcraft, dubbed _Classic WoW_. When I was younger, particularly during the _Burning Crusade_ WoW expansion, I discovered a community which extensively modeled the combat mechanics of the game with the intent on performing optimally in many person encounters called _raids_. Back then there was a forum called _Elitist Jerks_ that cultivated this analysis we now refer to as _Theorycrafting_. Much has changed since those years and I figured I could sate my curiosity before the release date by attempting this sort of modeling in Haskell.

## Probability
A while back, a colleague of mine showed me a really cool paper on [probibalistic programming](http://web.engr.oregonstate.edu/~erwig/papers/PFP_JFP06.pdf) in Haskell. This proved to be inspriational for this project. I don't intend this to be a monad tutorial, so you'll need some prerequisite knowledge on those to really grok the code, but it might not be necessary to follow it in a hand-wavy sense.

Here we'll have the base definition along with a `Show` instance (so we can print it) and `Applicative`/`Monad` instances to combine distributions.
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

However, because of the `Monad` implementation, we can combine them (using a new `dedup` function to group by identical rolls):
```haskell
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
  (Dist (x:xs)) <|> _ = Dist (x:xs)
  _ <|> y = y
```
This gives us the nifty [`guard`](http://hackage.haskell.org/package/base-4.12.0.0/docs/Control-Monad.html#v:guard) function which returns `empty` on false predicates, thus short-circuiting applicative computations via the `Alternative` [law](https://en.wikibooks.org/wiki/Haskell/Alternative_and_MonadPlus#Alternative_and_MonadPlus_laws) `empty <|> u  =  u`.

Ok, that may be a fair bit to take in. No worries, it ends up allowing us to clip off all the rolls that aren't 7 from our previous distribution:
```haskell
result = dedup $ do
  x <- d6
  y <- d6
  let is7 = x + y == 7
  guard (is7)
  return is7
```
->
```haskell
result
0.167 True
```
Notice how there are no more False events. This is useful if we want to clip out events that don't match a predicate.

Now that we've got a feeling for how these compose, lets take a look at a more involved example.

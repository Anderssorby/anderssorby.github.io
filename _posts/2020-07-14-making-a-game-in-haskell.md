---
layout: default
title:  "Making a game in Haskell"
date:   2020-07-14 14:14:04 +0200
categories: functional-programming haskell
---

# Making a game in Haskell

During my vacation I've been working on making a game in Haskell called [HexTech](https://github.com/Anderssorby/hextech-backend). It has been really
fun and inspiring and I've learned a lot of new things. The game is a sort of turn-based strategy game on a hexagonal grid. It is mostly a hobby project
and it has taken more time than I wanted, but I have been making steady progress. I'm using several tutorials as a guide: 
[this guide for working with hexagonal grids](https://www.redblobgames.com/grids/hexagons/) and [this one which really gave me a kick start](http://jxv.io/blog/2018-02-28-A-Game-in-Haskell.html).
A lot of my source is based on a rewrite of that game code.

Concepts and libraries that I have used and needed to learn include: monad transformers, lenses, and SDL bindings. They lead to very elegant code and makes
things like managing state and updating values easy in a purely functional context. Later I might want to rewrite the program to use a FRP (Functional Reactive Programming)
design with a library like NetWire. I'm going to give some examples of the concepts.

## Monad Transformers

Monads are sort of expressions that can be composed and are used to encode side effects in Haskell. I'm not going to describe them in detail here.

The state of the program is represented by this record type:
```haskell
import Control.Lens

-- State of the program
data Model = Model
  { vGame :: Game
  , vScene :: SceneType
  , vNextScene :: SceneType
  , vTitle :: TitleVars
  , vPlay :: PlayVars
  , vInput :: Input
  , vCamera :: Camera
  , vSettings :: Settings
  } deriving (Show, Eq)
makeClassy_ ''Model
```

The `makeClassy_` uses Template Haskell to generate lenses for all the fields including a typeclass `HasModel s`.

The program itself is wrapped inside this all-around newtype monad:

```haskell
newtype HexTech a = HexTech (ReaderT Config (StateT Model IO) a)
  deriving (Functor, Applicative, Monad, MonadReader Config, MonadState Model, MonadIO, MonadThrow, MonadCatch)

runHexTech :: Config -> Model -> HexTech a -> IO a
runHexTech config v (HexTech m) = evalStateT (runReaderT m config) v
```

`Config` represents read only resources and values like sprites, font and music. This massive monad can do everything necessary in the program and with the
`runHexTech` function we can initialize the state and reader monads. Elsewhere in the code I mostly use an unresolved monad and list the necessary constraints instead.

More to come...

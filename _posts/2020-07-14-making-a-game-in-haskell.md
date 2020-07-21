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

### Challenges with this approach

This approach has some drawbacks. Most notably we loose some type safety since most of the programs logic is encapsulated in the newtype monad `HexTech`. Almost all
of the primary functions of this program are working on this monad which means essentially that anything, even IO, is allowed anywhere. This means that we are basically back to
an imperative style program. It is possible to restrict this a bit by not explicitly declaring functions as returning this monad, but only listing the minimal
type class constraints. This usually also includes `MonadIO` because of the SDL functions. It can be enforced somewhat by restricitng the available constraints in upstream functions
so that smaller functions can not have any more constraints than their parents. 

For example take a look at the signature to the main loop (which is very based on the DinoRush example):

```haskell
mainLoop
  :: ( MonadReader Config m
     , MonadState State.Model m
     , Audio m
     , Logger m
     , Clock m
     , CameraControl m
     , Renderer m
     , SDLRenderer m
     , MonadIO m
     , HasInput m
     , SceneManager m
     )
  => m ()
mainLoop = do
  Input.updateInput
  input <- Input.getInput
  clearScreen
  scene <- gets vScene
  step scene
  drawScreen
  delayMilliseconds frameDeltaMilliseconds
  nextScene <- gets vNextScene
  stepScene scene nextScene
  let quit = nextScene == Scene'Quit || Input.iQuit input
  unless quit mainLoop
 where
  playScene = Play.playScene
  step scene = do
    case scene of
      Scene'Title    -> Title.titleStep
      Scene'Play     -> State.stepScene playScene
      Scene'Pause    -> pauseStep
      Scene'GameOver -> return ()
      Scene'Quit     -> return ()

  stepScene scene nextScene = do
    when (nextScene /= scene) $ do
      case nextScene of
        Scene'Title -> titleTransition
        Scene'Play  -> case scene of
          Scene'Title -> State.sceneTransition playScene
          Scene'Pause -> pauseToPlay
          _           -> return ()
        Scene'Pause -> case scene of
          Scene'Play -> playToPause
          _          -> return ()
        Scene'GameOver -> return ()
        Scene'Quit     -> return ()
      modify (\v -> v { vScene = nextScene })
```

My ambition from this point is to reduce the complexity of this mainLoop by adding a generic abstraction to Scene and reduce the number of type classes.
Also using more qualified imports would make the code more navigateable.

## Lenses

Lenses provides purely functional first-class setters and getters which can be configured to work on any structure.

## SDL bindings

[Simple DirectMedia Layer (SDL)](https://libsdl.org) is a cross platform C library with access to graphics hardware via OpenGL and Direct3D. It is therefore
well suited for making games although you are responsible for combining the primitive components to more high level graphics and audio logic.

More to come...

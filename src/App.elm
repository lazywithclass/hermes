port module App exposing (..)

import Html exposing (Html, text, div, img, button, input, span)
import Html.Attributes exposing (src, class, defaultValue, style)
import Html.Events exposing (onClick, onInput)
import Array exposing (Array, fromList, get, length)
import Time exposing (Time, every, millisecond, second)
import String exposing (split, words, left, right, slice)
import Keyboard exposing (KeyCode, presses)


-- when there's no effects
pure : Model -> ( Model, Cmd Msg )
pure model = ( model, Cmd.none )


tuplise : String -> Array ( String, Bool)
tuplise = words >> List.map (\w -> (w, True)) >> fromList


welcomeMsg : Array (String, Bool)
welcomeMsg = tuplise "Hello! Welcome to Hermes, an awesome speed reader app!"


--| Init State + Model
type alias Model =
  { word : String
  , nth : Int
  , words : Array (String, Bool)
  , sec : Time
  -- wpm handlers
  , wpm : Float
  , defaultWpm : Float
  -- pause/play
  , playing : Bool
  -- keyboard
  , pressed : Int
  }

init : String -> ( Model, Cmd Msg )
init flags =
  { word = ""
  , nth = 0
  , words = welcomeMsg
  , sec = 0
  , wpm = toFloat 300
  , defaultWpm = toFloat 300
  , playing = False
  , pressed = 0
  } |> pure


--| Helpers
getMaybe : Int -> Array (String, Bool) -> String
getMaybe nth words =
  case get nth words of
    Nothing     -> ""
    Just (string, bool) -> string


toMilliseconds : Float -> Time
toMilliseconds wpm = 60000 / wpm


iter : Bool -> Int -> Int
iter bool step = case bool of
  True -> step + 1
  False -> step


--| ORP
isPunc : String -> Int
isPunc str =
  if str == "!" || str == ":" || str == "," || str == "."
  then 1
  else 0

getOrpIndex : String -> Int
getOrpIndex word =
  let 
    realLen = String.length word
    last = slice (realLen - 1) realLen word
    len = realLen - (isPunc last)
  in
    case len of
      1 -> 0
      2 -> 1
      3 -> 1
      _ -> (floor <| toFloat len / 2) - 1

orp : String -> List (Html msg)
orp word =
  let orpI = getOrpIndex word
      len = String.length word
  in [ left orpI word |> text
     , span [ style [ ( "color", "red" ) ] ]
         [ slice orpI (orpI + 1) word |> text ]
     , right (len - (orpI + 1)) word |> text
     ]


--| Effects
type Msg
  = IncWpm
  | DecWpm
  | Tick Time
  | GetText String
  | Pressed Int
  -- JS calls
  | SendWord
  | GetWeight Float


--| Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of

    IncWpm ->
    { model | wpm = model.wpm + 50
    , defaultWpm = model.defaultWpm + 50
    } |> pure

    DecWpm ->
    { model | wpm = model.wpm - 50
    , defaultWpm = model.defaultWpm - 50
    } |> pure

    Tick time ->
    { model | wpm = model.defaultWpm
    , nth = iter model.playing model.nth % length model.words
    , word = getMaybe model.nth model.words
    , sec = time
    } |> pure

    GetText text ->
    { model | words = tuplise text } |> pure

    Pressed key -> pure <|
      if key == 32
      then { model | playing = not model.playing }
      else model

    -- port calls.. only real effectful thing
    SendWord -> ( model, weightQuestion model.word )

    GetWeight weight ->
    { model | wpm = model.wpm * weight } |> pure



--| View
view : Model -> Html Msg
view model =
  div []
      [ div []
          [ button [ onClick DecWpm, class "pure-button" ] [ text "Dec" ]
          , button [ onClick IncWpm, class "pure-button" ] [ text "Inc" ]
          , input [ defaultValue "Paste text here!", onInput GetText ] []
          ]
      , div [ class "word" ] (orp model.word)
      ]


--| Sub
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
       [ every (toMilliseconds model.wpm) Tick
       , every (toMilliseconds model.wpm) (always SendWord)
       , presses Pressed
       , weightAnswer GetWeight 
       ]


--| ports
port weightQuestion : String -> Cmd msg
port weightAnswer : (Float -> msg) -> Sub msg

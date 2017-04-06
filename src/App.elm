port module App exposing (..)

import Html exposing (Html, text, div, img, button, input, span)
import Html.Attributes exposing (src, class, defaultValue, style)
import Html.Events exposing (onClick, onInput)
import Array exposing (Array, fromList, get, length)
import Time exposing (Time, millisecond, second)
import String exposing (join, split, words, left, right, slice, fromChar)
import Keyboard exposing (..)


type alias Model =
    { word : String
    , nth : Int
    , words : Array String
    , sec : Time
    , wpm : Float
    , defaultWpm : Float
    , playing : Bool
    , pressed : Int
    }


init : String -> ( Model, Cmd Msg )
init flags =
    ( { word = ""
      , nth = 0
      , words = fromList [ "Hello", "here", "are", "some", "strings." ]
      , sec = 0
      , wpm = toFloat 300
      , defaultWpm = toFloat 300
      , playing = False
      , pressed = 0
      }
    , Cmd.none )


type Msg
    = IncWpm
    | DecWpm
    | Tick Time
    | GetText String
    | Pressed Int
    | SendWord
    | GetWeight Float


port weightQuestion : String -> Cmd msg
port weightAnswer : (Float -> msg) -> Sub msg

getMaybe : Int -> Array String -> String
getMaybe nth words = case get nth words of
  Nothing -> ""
  Just string -> string

{-
wpm doesnt have to be float until we actually do the division
because the Time has to be a Float
-}
toMilliseconds : Float -> Time
toMilliseconds wpm = 60000 / wpm


iter : Bool -> Int -> Int
iter bool step = case bool of
  True -> step + 1
  False -> step


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = case msg of

  IncWpm ->
    ( { model
        | wpm = model.wpm + 50
        , defaultWpm = model.defaultWpm + 50
      }, Cmd.none )

  DecWpm ->
    ( { model
        | wpm = model.wpm - 50
        , defaultWpm = model.defaultWpm - 50
      }, Cmd.none )

  Tick time ->
    ( { model
        | wpm = model.defaultWpm
        , nth = (iter model.playing model.nth) % length model.words
        , word = getMaybe model.nth model.words
        , sec = time
      }
    , Cmd.none )

  GetText text ->
    ( { model | words = fromList (words text) } , Cmd.none )

  Pressed key ->
    if key == 32
    then ( { model | playing = not model.playing } , Cmd.none )
    else ( model, Cmd.none )

  SendWord -> ( model, (weightQuestion model.word) )

  GetWeight weight ->
    ( { model
        | wpm = model.wpm * weight
      }, Cmd.none )

getOrpIndex : String -> Int
getOrpIndex word =
  let len = String.length word
  in case len of
       1 -> 0
       2 -> 1
       3 -> 1
       _ -> (floor (toFloat len / 2)) - 1

orp : String -> List (Html msg)
orp word =
  let orpI = getOrpIndex word
  in case String.length word of
       len -> [ text (left orpI word)
              , span [ style [ ( "color", "red" ) ] ]
                     [ text (slice orpI (orpI + 1) word)]
              , text (right (len - (orpI + 1)) word)
              ]


view : Model -> Html Msg
view model =
  div []
      [ div []
          [ button [ onClick DecWpm, class "pure-button" ] [ text "Dec" ]
          , button [ onClick IncWpm, class "pure-button" ] [ text "Inc" ]
          , input [ defaultValue "Some text here", onInput GetText ] []
          ]
      , div [ class "word" ] (orp model.word)
      ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
       [ Time.every (toMilliseconds model.wpm) Tick
       , Time.every (toMilliseconds model.wpm) (always SendWord)
       , Keyboard.presses (\int -> Pressed int)
       , weightAnswer GetWeight 
       ]

port module App exposing (..)

import Html exposing (Html, text, div, img, button, input, span)
import Html.Attributes exposing (src, class, defaultValue, style)
import Html.Events exposing (onClick, onInput)
import Array exposing (..)
import Time exposing (Time, millisecond, second)
import String exposing (join, split, words, left, right)
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
    ( { word = "Let's start"
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
    = NextWord
    | IncWpm
    | DecWpm
    | StartOver
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
  NextWord -> ( model, Cmd.none )
  IncWpm -> ( { model
              | wpm = model.wpm + 50
              , defaultWpm = model.defaultWpm + 50
              }, Cmd.none)
  DecWpm -> ( { model
              | wpm = model.wpm - 50
              , defaultWpm = model.defaultWpm - 50
              }, Cmd.none)
  StartOver -> ( model, Cmd.none )
  Tick time -> ( { model
                 | wpm = model.defaultWpm
                 , nth = (iter model.playing model.nth) % length model.words
                 , word = getMaybe model.nth model.words
                 , sec = time
                 }, Cmd.none )
  GetText text -> ( { model | words = fromList (words text) }, Cmd.none )
  Pressed key ->
    if key == 32 then ( { model | playing = not model.playing }, Cmd.none )
    else ( model, Cmd.none )
  SendWord -> ( model, (weightQuestion model.word) )
  GetWeight weight -> ( { model
                         | wpm = model.wpm * weight
                         }, Cmd.none )


-- function ORP(word){
--   var length = word.length;
--   while('\n,.?!:;"'.indexOf(word[--length]) !== -1);
--   switch(++length) {
--   case 0: case 1: return 0;
--   case 2: case 3: return 1;
--   default: return Math.floor(length / 2) - 1;
--   }
-- }
getOrpIndex : String -> Int
getOrpIndex word = case String.length word of
            1 -> 0
            2 -> 1
            3 -> 1
            _ -> (floor (String.length word / 2)) - 1

orp : String -> List (Html msg)
orp word = case String.length word of
    _ -> [ text (left (getOrpIndex word - 1) word)
         , span [ style [ ( "color", "red" ) ] ]
                [ text (toString (String.charAt (getOrdpIndex word))) ]
         , text (right word ((getOrpIndex word) + 1) (String.length word))
         ]


view : Model -> Html Msg
view model =
  div [ onClick NextWord ]
  [div []
    [ button [ onClick DecWpm ] [ text "Dec" ]
    , button [ onClick IncWpm ] [ text "Inc" ]
    , input [ defaultValue "Some text here", onInput GetText ] []
    ]
  , div [ class "word" ] (orp model.word)
  ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Time.every (toMilliseconds model.wpm) Tick
      , Time.every (toMilliseconds model.wpm) (always SendWord)
      , Keyboard.presses (\int -> Pressed int)
      , weightAnswer GetWeight 
      ]

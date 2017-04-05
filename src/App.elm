port module App exposing (..)

import Html exposing (Html, text, div, img, button, input)
import Html.Attributes exposing (src, class, defaultValue)
import Html.Events exposing (onClick, onInput)
import Array exposing (..)
import Time exposing (Time, millisecond, second)
import String exposing (join, split, words)
import Keyboard exposing (..)


type alias Model =
    { word : String
    , nth : Int
    , words : Array String
    , sec : Time
    , wpm : Float
    , playing : Bool
    , pressed : Int
    }


init : String -> ( Model, Cmd Msg )
init flags =
    ( { word = "Let's start"
      , nth = 0
      , words = fromList [ "Hello", "here", "are", "some", "strings." ]
      , sec = 0
      , wpm = toFloat 350
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
    | GetSyllables Int


port syllableQuestion : String -> Cmd msg
port syllableAnswer : (Int -> msg) -> Sub msg


getMaybe : Int -> Array String -> String
getMaybe nth words = case get nth words of
  Nothing -> ""
  Just string -> string


toMilliseconds : Float -> Time
toMilliseconds wpm = 60000 / wpm


iter : Bool -> Int -> Int
iter bool step = case bool of
  True -> step + 1
  False -> step


wordSpeed: Float -> String -> Float
wordSpeed wpm word = (wpm * 3)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = case msg of
  NextWord -> ( model, Cmd.none )
  IncWpm -> ( { model | wpm = model.wpm + 50 }, Cmd.none)
  DecWpm -> ( { model | wpm = model.wpm - 50 }, Cmd.none)
  StartOver -> ( model, Cmd.none )
  Tick time -> ( { model
                 | nth = (iter model.playing model.nth) % 5
                 , word = getMaybe model.nth model.words
                 , sec = time
                 }, Cmd.none )
  GetText text -> ( { model | words = fromList (words text) }, Cmd.none )
  Pressed key ->
    if key == 32 then ( { model | playing = not model.playing }, Cmd.none )
    else ( model, Cmd.none )
  SendWord -> ( model, (syllableQuestion model.word) )
  GetSyllables syllables -> ( { model | word = toString syllables}, Cmd.none )


view : Model -> Html Msg
view model =
  div [ onClick NextWord ]
  [div []
    [ button [ onClick DecWpm ] [ text "Dec" ]
    , button [ onClick IncWpm ] [ text "Inc" ]
    , input [ defaultValue "Some text here", onInput GetText ] []
    ]
  , div [ class "word" ] [ text model.word ]
  ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Time.every (toMilliseconds model.wpm) Tick
      , Time.every (toMilliseconds model.wpm) (always SendWord)
      , Keyboard.presses (\int -> Pressed int)
      , syllableAnswer GetSyllables
      ]

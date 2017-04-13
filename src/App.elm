port module App exposing (..)

import Array exposing (Array, fromList, get)
import Html exposing (Html, text, div, img, button, input, span)
import Html.Attributes exposing (src, class, defaultValue, style)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error)
import Keyboard exposing (KeyCode, presses)
import String exposing (split, words, left, right, slice)
import Time exposing (Time, every, millisecond, second)

import Tokeniser exposing (..)

-- when there's no effects
pure : Model -> ( Model, Cmd Msg )
pure model = ( model, Cmd.none )


welcomeMsg : Array (String, Bool)
welcomeMsg = parseHtmlString myElement


--| Init State + Model
type alias Model =
  { word : String
  , nth : Int
  , words : Array (String, Bool)
  , sec : Time
  -- wpm handlers
  , wordSpeed : Float
  , wpm : Float
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
  , wordSpeed = toFloat 300
  , wpm = toFloat 300
  , playing = False
  , pressed = 0
  } |> pure


--| Helpers
getMaybe : Int -> Array (String, Bool) -> (String, Bool)
getMaybe nth words =
  case get nth words of
    Nothing -> ("", False)
    Just tuple -> tuple


toMilliseconds : Float -> Time
toMilliseconds wpm = 60000 / wpm


iter : Bool -> Int -> Int
iter bool step =
  case bool of
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
  let
    orpI = getOrpIndex word
    len = String.length word
  in
    [ left orpI word |> text
    , span [ style [ ( "color", "red" ) ] ]
        [ slice orpI (orpI + 1) word |> text ]
    , right (len - (orpI + 1)) word |> text
    ]


--| Messages
type Msg
  = IncWpm
  | DecWpm
  | GetText String
  | Pressed Int
  | GetWeight Float
  | Tick Time
  | GetContent String
  | FetchContentCompleted (Result Http.Error String)


--| Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of

    IncWpm ->
    { model | wpm = model.wpm + 50 } |> pure

    DecWpm ->
    { model | wpm = model.wpm - 50 } |> pure

    GetText text ->
    -- `parseString` can cause a stack overflow if text is super long!!
    -- example: Pasting the entire book of great expectations
    { model | words = parseString text |> fromList } |> pure
    --| for testing
    -- { model | words = parseHtmlString text } |> pure

    Pressed key -> pure <|
      if key == 32
      then { model | playing = not model.playing }
      else model

    GetWeight weight ->
    { model | wordSpeed = model.wpm * weight } |> pure

    -- EFFECTS : Messages that produce Cmd effects
    Tick time ->
      let
        nth = iter model.playing model.nth
        (word, isPlaying) = getMaybe nth model.words
      in
        ( { model | wordSpeed = model.wpm
          , nth = nth % Array.length model.words
          , word = word
          , playing = model.playing && isPlaying
          , sec = time
          }
        , weightQuestion word )

    GetContent link -> (model, fetchContentCmd link)

    FetchContentCompleted result -> fetchContentCompleted model result


-- http
fetchContent : String -> Http.Request String
fetchContent =
    String.append "https://crossorigin.me/" >> Http.getString 


fetchContentCmd : String -> Cmd Msg
fetchContentCmd s =
    Http.send FetchContentCompleted (fetchContent s)


fetchContentCompleted : Model ->
                        Result Http.Error String ->
                        ( Model, Cmd Msg )
fetchContentCompleted model result =
  case result of
    Ok sourceString ->
      { model | words = parseHtmlString sourceString } |> pure
      -- { model | word = sourceString } |> pure
        
    Err _ -> pure model


--| View
view : Model -> Html Msg
view model =
  div []
      [ div []
          [ button [ onClick DecWpm, class "pure-button" ] [ text "Dec" ]
          , button [ onClick IncWpm, class "pure-button" ] [ text "Inc" ]
          , input [ defaultValue "Paste text here!", onInput GetText ] []
          , input [ defaultValue "Paste link here!", onInput GetContent ] []
          ]
      , div [ class "word" ] (orp model.word)
      ]


--| Sub
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
       [ every (toMilliseconds model.wordSpeed) Tick
       , presses Pressed
       , weightAnswer GetWeight
       ]


--| ports
port weightQuestion : String -> Cmd msg
port weightAnswer : (Float -> msg) -> Sub msg

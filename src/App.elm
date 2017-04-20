port module App exposing (..)

import Array exposing (Array, fromList, get)
import Html exposing (Html, text, div, img, button, input, span)
import Html.Attributes exposing (src, class, defaultValue, style)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error)
import Keyboard exposing (KeyCode, presses)
-- import String exposing (split, words, left, right, slice)
import Time exposing (Time, every, millisecond, second)

--| import stuff
import Helpers exposing (..)
import Tokeniser exposing (..)
import GetContent exposing (..)


-- when there's no effects
pure : Model -> ( Model, Cmd Msg )
pure model = ( model, Cmd.none )


welcomeMsg : Array Word -- ( String, Bool )
welcomeMsg = parseHtmlString myElement
-- welcomeMsg = fromList <| parseString "Lets test (this thing (and some nested) parens), \"ok we are testing\""


--| Init State + Model
type alias Model =
  { word : String
  , nth : Int
  , words : Array Word
  , context: (Bool, String)
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
  , context = (False, "")
  , sec = 0
  , wordSpeed = toFloat 300
  , wpm = toFloat 300
  , playing = False
  , pressed = 0
  } |> pure


--| Messages
type Msg
  = IncWpm
  | DecWpm
  | GetText String
  | Pressed Int
  | GetWeight Float
  | Tick Time
  | GetContent String
  | FetchContentCompleted (Result Error String)


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
    -- { model | words = parseString text |> fromList } |> pure
    -- | for testing
    { model | words = parseHtmlString text } |> pure

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
        wordConstr = getMaybe nth (Slow "") model.words
        playWord playing word = playing &&
          case word of
            Norm _ -> True
            Slow _ -> False
        word = unwrapWord wordConstr
        (inContext, closing) = model.context
        context = if inContext
                  then endsContext closing word
                  else startsContext word
      in
        ( { model | nth = nth % Array.length model.words
          , word = word
          -- , playing = model.playing && isPlaying
          , playing = playWord model.playing wordConstr
          , sec = time
          , context = context
          }
        , weightQuestion word )

    GetContent link ->
      ( model, fetchContentCmd link FetchContentCompleted )

    FetchContentCompleted result ->
      { model | words = fetchContentCompleted model.words result } |> pure


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
      , div [ class "context" ]
            [ case model.context of
                (True, closing) -> text closing
                _ -> text ""
            ]
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

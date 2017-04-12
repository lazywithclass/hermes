module GetContent exposing (..)

import App exposing (Msg, Model)

import Http exposing (..)


fetchRandomQuote : Http.Request String
fetchRandomQuote =
    Http.getString "our thing"


fetchRandomQuoteCmd : Cmd Msg
fetchRandomQuoteCmd =
    Http.send App.FetchContentCompleted fetchRandomQuote


fetchContentCompleted : App.Model ->
                        Result Http.Error String ->
                        ( App.Model, Cmd Msg )
fetchContentCompleted model result =
    case result of
        Ok newQuote ->
            ( { model | quote = newQuote }, Cmd.none )

        Err _ ->
            ( model, Cmd.none )



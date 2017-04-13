module GetContent exposing (..)

import Array exposing (Array)
import Http exposing (Request, Error, send, getString)
import String exposing (append)

import Tokeniser exposing (..)

fetchContent : String -> Request String
fetchContent = append "https://crossorigin.me/" >> getString


fetchContentCmd : String -> (Result Error String -> msg) -> Cmd msg
fetchContentCmd s cb = send cb (fetchContent s)


fetchContentCompleted : Array ( String, Bool ) ->
                        Result Error String ->
                        Array ( String, Bool )
fetchContentCompleted old result =
  case result of

    Ok sourceString -> parseHtmlString sourceString
      -- sourceString

    Err _ -> old

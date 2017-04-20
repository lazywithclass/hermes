module GetContent exposing (..)

import Array exposing (Array)
import Http exposing (Request, Error, send, getString)
import String exposing (append)

import Tokeniser exposing (..)


fetchContent : String -> Request String
fetchContent = append "https://crossorigin.me/" >> getString


fetchContentCmd : String -> (Result Error String -> msg) -> Cmd msg
fetchContentCmd s cb = send cb (fetchContent s)


fetchContentCompleted : Array Word ->
                        Result Error String ->
                        Array Word
fetchContentCompleted old result =
  case result of

    Ok sourceString -> parseHtmlString sourceString
      -- sourceString

    Err _ -> old

module Helpers exposing (..)

import Html exposing (Html, text, span)
import Html.Attributes exposing (style)
import Time exposing (Time)
import String exposing (slice, left, right) 
import Array exposing (Array, get)


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
startsContext : String -> (Bool, String)
startsContext word =
  case slice 0 1 word of
    "("  -> (True, ")")
    "\"" -> (True, "\"")
    _    -> (False, "")


endsContext : String -> String -> (Bool, String)
endsContext closing word =
  let
    len = String.length word
    last = slice (len - 1) len word
    fromLast = if isPunc last == 1
      then slice (len - 2) (len - 1) word
      else last
    closed = closing == fromLast
  in
    if closed then (False, "") else (True, closing)


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

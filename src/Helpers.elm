module Helpers exposing (..)

import Html exposing (Html, text, span)
import Html.Attributes exposing (style)
import Time exposing (Time)
import String exposing (slice, left, right) 
import Array exposing (Array, get)


getMaybe : Int -> a -> Array a -> a
getMaybe nth default words =
  case get nth words of
    Nothing -> default
    Just word -> word


toMilliseconds : Float -> Time
toMilliseconds wpm = 60000 / wpm


iter : Bool -> Int -> Int
iter bool step =
  case bool of
    True -> step + 1
    False -> step


isPunc : String -> Bool
isPunc str =
  if str == "!" || str == ":" || str == "," || str == "."
  then True
  else False



--| Contextual punctuation
push : a -> List a -> List a
push item stk = item :: stk


pop : List a -> ( Maybe a, List a )
pop stk =
    let
        item = List.head stk
        tail = List.tail stk
    in
      case item of
        Nothing -> ( Nothing, stk )
        Just item ->
          let
            newstk =
              case tail of
                Nothing -> []
                Just tail -> tail
          in
            ( Just item, newstk )


top : List String -> String
top stk =
  case List.head stk of
    Nothing -> ""
    Just s -> s


empty : List String -> Bool
empty stk =
  case top stk of
    "" -> True
    _ -> False


notInContext : List String -> Bool
notInContext = empty


extendContext : String -> List String -> List String
extendContext word stk =
  case left 1 word of
    "(" -> push ")" stk
    "\"" -> push "\"" stk
    _ -> stk


stripAllPunc : String -> String
stripAllPunc str =
  let
    last = right 1 str
  in
    if isPunc last
    then stripAllPunc <| String.dropRight 1 str
    else str


shrinkContext : String -> List String -> List String    
shrinkContext word stk =
  if notInContext stk
  then stk
  else
    let
      stripped = stripAllPunc word
      last = right 1 stripped
      ( lastContext, newstk ) = pop stk
    in
      case ( last, lastContext ) of
        ( x, Just y ) ->
          if x == y
          then newstk
          else stk -- invalid
        _ -> stk


--| ORP
getOrpIndex : String -> Int
getOrpIndex word =
  let
    realLen = String.length word
    last = slice (realLen - 1) realLen word
    len =
      if isPunc last then realLen - 1 else realLen
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

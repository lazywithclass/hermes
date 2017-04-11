module Tokeniser exposing (..)

import Array exposing (Array, fromList, get, length)
import String exposing (split, words, left, right, slice)

import HtmlParser exposing (..)
import HtmlParser.Util exposing (..)

myElement : String
myElement = """<p xmlns="http://www.w3.org/1999/xhtml">For example:</p>
<div xmlns="http://www.w3.org/1999/xhtml" class="lisp">
<pre class="lisp prettyprinted" style=""><span class="opn">(</span><span class="pun">+</span><span class="pln"> </span><span class="lit">137</span><span class="pln"> </span><span class="lit">349</span><span class="clo">)</span><span class="pln">
</span><i><span class="lit">486</span></i><span class="pln">

</span><span class="opn">(</span><span class="pun">-</span><span class="pln"> </span><span class="lit">1000</span><span class="pln"> </span><span class="lit">334</span><span class="clo">)</span><span class="pln">
</span><i><span class="lit">666</span></i><span class="pln">

</span><span class="opn">(</span><span class="pun">*</span><span class="pln"> </span><span class="lit">5</span><span class="pln"> </span><span class="lit">99</span><span class="clo">)</span><span class="pln">
</span><i><span class="lit">495</span></i><span class="pln">

</span><span class="opn">(</span><span class="pun">/</span><span class="pln"> </span><span class="lit">10</span><span class="pln"> </span><span class="lit">5</span><span class="clo">)</span><span class="pln">
</span><i><span class="lit">2</span></i><span class="pln">

</span><span class="opn">(</span><span class="pun">+</span><span class="pln"> </span><span class="lit">2.7</span><span class="pln"> </span><span class="lit">10</span><span class="clo">)</span><span class="pln">
</span><i><span class="lit">12.7</span></i>
</pre></div>
<p>Hello, fuck face! Fuck off, will you?</p>
<div>quickSort [1..5000]</div>
"""

parseHtmlString : String -> Array (String, Bool)
parseHtmlString str =
  let
    els = parse str
  in
    fromList <|
    List.concatMap
          (\el ->
             case el of
               Element "p" attr content ->
                 parseString (textContent content)
               Element "div" attr content ->
                 [(textContent content, False)]
               _ -> []) els

parseString : String -> List ( String, Bool)
parseString = words >> List.map (\w -> (w, True)) -- >> fromList

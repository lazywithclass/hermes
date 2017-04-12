module Tokeniser exposing (..)

import Array exposing (Array, fromList, get, length)
import String exposing (split, words, left, right, slice)
import HtmlParser exposing (..)
import HtmlParser.Util exposing (..)

myElement : String
myElement = """
<p>Hello! Welcome to Hermes!</p>
<p xmlns="http://www.w3.org/1999/xhtml">Here's some code for you:</p>
<p>(Press Space to continue!)</p>
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
<p>More code:</p>
<div>quickSort [1..5000]</div>
<p>Now, fuck face, go and fuck off, will you? Thanks.</p>
"""

parseHtmlString : String -> Array (String, Bool)
parseHtmlString =
  let
    parseElement el =
      case el of
        Element identifier _ content ->
          -- this can be abstracted
          -- allow the user to configure the behavior
          case identifier of
            "p" -> parseString (textContent content)
            "div" -> [(textContent content, False)]
            _ -> []
        _ -> []
  in
    parse >> List.concatMap parseElement >> fromList


parseString : String -> List ( String, Bool )
parseString = words >> List.map (\w -> (w, True))-- >> fromList

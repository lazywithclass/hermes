module Tokeniser exposing (..)

import Array exposing (Array, fromList, get, length)
import String exposing (words, uncons, dropLeft)
import HtmlParser exposing (..)
import HtmlParser.Util exposing (..)

strip : String -> String -> String
strip pat str =
  case pat of
    "" -> str
    _ -> 
      case (uncons pat, uncons str) of
        (Just (c1,rst1), Just (c2,rst2)) ->
          if c1 == c2
          then strip rst1 rst2
          else strip pat rst2
        (_,_) -> ""

myElement : String
myElement = """
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xml:lang="en" lang="en">
<!-- Created by GNU Texinfo 5.1, http://www.gnu.org/software/texinfo/ -->
<head>
<title>Structure and Interpretation of Computer Programs, 2e: Dedication</title>

<meta name="description" content="Structure and Interpretation of Computer Programs, 2e: Dedication" />
<meta name="keywords" content="Structure and Interpretation of Computer Programs, 2e: Dedication" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<meta name="Generator" content="texi2any" />
<meta charset="utf-8" />
<link href="index.xhtml#Top" rel="start" title="Top" />
<link href="Term-Index.xhtml#Term-Index" rel="index" title="Term Index" />
<link href="index.xhtml#SEC_Contents" rel="contents" title="Table of Contents" />
<link href="index.xhtml#Top" rel="prev" title="Top" />
<link href="Foreword.xhtml#Foreword" rel="next" title="Foreword" />
<link href="UTF.xhtml#UTF" rel="prev" title="UTF" />

<link href="css/style.css" rel="stylesheet" type="text/css" />
<link href="css/prettify.css" rel="stylesheet" type="text/css" />

<script src="js/jquery.min.js" type="text/javascript"></script>
<script src="js/footnotes.js" type="text/javascript"></script>
<script src="js/browsertest.js" type="text/javascript"></script>
</head>

<body>
<section><span class="top jump" title="Jump to top"><a href="#pagetop" accesskey="t">⇡</a></span><a id="pagetop"></a><a id="Dedication"></a>
<nav class="header">
<p>
Next: <a href="Foreword.xhtml#Foreword" accesskey="n" rel="next">Foreword</a>, Prev: <a href="UTF.xhtml#UTF" accesskey="p" rel="prev">UTF</a>, Up: <a href="index.xhtml#Top" accesskey="u" rel="prev">Top</a>   [<a href="index.xhtml#SEC_Contents" title="Table of contents" accesskey="c" rel="contents">Contents</a>]</p>
</nav>
<a id="Dedication-1"></a>
<h2 class="unnumbered">Dedication</h2>

<p>This book is dedicated, in respect and admiration, to the spirit that lives in
the computer.
</p>
<blockquote>
<p>“I think that it’s extraordinarily important that we in computer science keep
fun in computing. When it started out, it was an awful lot of fun. Of course,
the paying customers got shafted every now and then, and after a while we began
to take their complaints seriously. We began to feel as if we really were
responsible for the successful, error-free perfect use of these machines. I
don’t think we are. I think we’re responsible for stretching them, setting
them off in new directions, and keeping fun in the house. I hope the field of
computer science never loses its sense of fun. Above all, I hope we don’t
become missionaries. Don’t feel as if you’re Bible salesmen. The world has
too many of those already. What you know about computing other people will
learn. Don’t feel as if the key to successful computing is only in your hands.
What’s in your hands, I think and hope, is intelligence: the ability to see the
machine as more than when you were first led up to it, that you can make it
more.”
</p>
<p>—Alan J. Perlis (April 1, 1922 – February 7, 1990)
</p></blockquote>

<nav class="header">
<p>
Next: <a href="Foreword.xhtml#Foreword" accesskey="n" rel="next">Foreword</a>, Prev: <a href="UTF.xhtml#UTF" accesskey="p" rel="prev">UTF</a>, Up: <a href="index.xhtml#Top" accesskey="u" rel="prev">Top</a>   [<a href="index.xhtml#SEC_Contents" title="Table of contents" accesskey="c" rel="contents">Contents</a>]</p>
</nav>


</section><span class="bottom jump" title="Jump to bottom"><a href="#pagebottom" accesskey="b">⇣</a></span><a id="pagebottom"></a>
</body>
</html>
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
            "script" -> []
            _ -> parseString (textContent content)
        _ -> []
  in
    strip "<html" >> dropLeft 1 >> parse >> List.concatMap parseElement >> fromList


parseString : String -> List ( String, Bool )
parseString = words >> List.map (\w -> (w, True))-- >> fromList

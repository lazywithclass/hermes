## Hermes

Hermes is a speed reading app with a look at practical usage.

Pair programmed at [RC](https://recurse.com) SP1 2017 by Carl J. Factora & Alberto Zaccagni

### The idea

Being able to speed read technical books and documents.

The challenge is that sometimes while reading you encounter code snippets, or chemical
formulas, or math expressions, it would be great if those could appear on screen, nicely
formatted, so you don't exit your speed reading flow.

We will provide a GIF soon!


### Features

This is still under heavy development, we will provide a set of features and how to use them in a short while!


### TODOS

* [x] single word at the center of the page, with colors and font
* [x] take an array of string and show them one after the other
  * [x] update the string on click
  * [x] update based off time
* [x] configure speed of words
* [x] read from input at start
* [x] read from input on change
* [x] center the whole word, not just on the first letter
* [x] pressing spacebar prevents nth from being iterated
* [x] another press resumes from the same point
* [x] associate weights with words
  * [x] a longer word lasts longer
  * [x] a word close to a comma lasts longer
  * [x] a word close to a semicolumn lasts even longer
  * [x] a word close to a full stop lasts even longer
* [x] handle normal text and code text differently
* [x] Get HTML code from a link
* [] given a URL and a function
  * [] format code
  * [] dont print paging
* [] handle ( ) " " etc as punctuation
* [] contextual punctuation

### Current goal:

We have successfully implemented the functionality to pull raw HTML code from a user-inputted site. We still have to clean up several things, including:

* removing extra-text generated from a website (e.g. text contained in scripts)
* For some reason we are not able to do this regardless of handling it in `Tokenisier`.
* Example of this result is in `src/scratch`
* Show specially formatted text in a nice way (currently, we only show it as raw text in a `div`).

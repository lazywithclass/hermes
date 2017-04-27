## Hermes

Hermes is a speed reading app with a look at practical usage.

Pair programmed at [RC](https://recurse.com) SP1 2017 by Carl J. Factora & Alberto Zaccagni

### The idea

Being able to speed read technical books and documents.

The challenge is that sometimes while reading you encounter code snippets, or chemical
formulas, or math expressions, it would be great if those could appear on screen, nicely
formatted, so you don't exit your speed reading flow.

We will provide a GIF soon!


### How to run it

```bash
$ elm-app start
```


### Features

This is still under heavy development, for now we have:

 * basic speed reading with letter focus
 * longer words will stay on screen for longer
 * punctuation will keep words on screen for longer
 * code stops execution giving you time to go through it
 * more to come!


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
  * [x] respect code with new lines
  * [] dont print paging
* [x] handle ( ) " " etc as punctuation
* [x] contextual punctuation
  * [x] next step is having a stack of nested punctuations, gradually disappearing
  * [x] handle multi character punctuaction (e.g. `...`)
  * [x] nested punctuation (e.g. (hello, have (some fun now) with parens))
* [x] we need a more intelligent way to detect punctuation
* [] handle HTTP error
* [] add a loading icon when we are fetching HTML contents from the URL

### Known problems

* [] nested elements *may* cause some problems with `parseHtmlString`. I.e., we need to handle nested websites properly.
* [] contextual punctuation does not respect window size
* [] contextual punctuation cannot handle `"))"` yet
* [] whenever the whole thing starts with a contextual punctuation then the punctuation is continously pushed into the context

### Current goal:

We are broken. This is fine. (dog with his house on fire here)

Reason is because of the long-ass recursion in `parseElement` due to ?

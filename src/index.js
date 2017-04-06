require('./main.css')
var logoPath = require('./logo.svg')
var Elm = require('./Main.elm')

var root = document.getElementById('root')
var app = Elm.Main.embed(root, logoPath)
app.ports.weightQuestion.subscribe(function(word) {
  app.ports.weightAnswer.send(weight(word))
})

let puncWeight = {
  '.': 55 / 100,
  '!': 55 / 100,
  '?': 55 / 100,
  ';': 90 / 100,
  ',': 95 / 100,
  ':': 95 / 100
}

function isVowel(char) {
  return ['a', 'e', 'i', 'o', 'u'].indexOf(char) > -1
}

function weight(word) {
  let lastCharacter = word[word.length - 1],
      multiplier = puncWeight[lastCharacter] ? puncWeight[lastCharacter] : 1,
      vowels = word.split('').reduce((sum, c) => isVowel(c) ? sum + 1 : sum, 0)

  let result = 1
  if (vowels >= 3 && vowels <= 4)  result = 1 / 2
  if (vowels >= 5 && vowels <= 6)  result = 1 / 4
  if (vowels >= 7)                 result = 1 / 8

  return result * multiplier
}

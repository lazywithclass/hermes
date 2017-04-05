require('./main.css');
var logoPath = require('./logo.svg');
var Elm = require('./Main.elm');

var root = document.getElementById('root');
var syllable = require('./syllable');

var app = Elm.Main.embed(root, logoPath);
app.ports.syllableQuestion.subscribe(function(word) {
  console.log('TEST', syllable)
  app.ports.syllableAnswer.send(syllable(word));
});

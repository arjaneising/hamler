init = (txt, Hamler) ->
  tpls = new Hamler './demo.hamler'


  tpls.render 'demo',
    append: document.querySelector 'body'
    vars:
      advantages: [
        {
          title: 'Lightweight'
          desc: 'Templates and the rendering engine are only a few kB in size. Very speedy download times!'
          goodfor: 'end users'
        }
        {
          title: 'Easy to maintain'
          desc: 'Writing templates the DRY way!'
          goodfor: 'developers'
        }
        {
          title: 'Standalone or with RequireJS or jQuery'
          desc: 'Easy asynchronous loading!'
          goodfor: 'developers'
        }
        {
          title: 'Fast'
          desc: 'By modifying the DOM only once per template, it\'s pretty darn fast!'
        }
        {
          title: 'Fun'
          desc: 'Previous things combined results in a lot ot fun.'
        }
      ]
      stats:
        linesCs: 443
        linesJs: 457
        sizeJs: 7216





require.config
  paths:
    text: './lib/text'
    Hamler: '../hamler'

window.addEventListener 'load', ->
  requirejs ['text', 'Hamler'], init
, false
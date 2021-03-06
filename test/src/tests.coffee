test 'It should append attributes properly', ->
  fixture = $ '#qunit-fixture'

  fixture.children().remove()

  haml = new Hamler """
                    %p.abc
                    %p.def.ghijkl
                    %p#mno
                    %p.abc#def.ghi
                    %p( tabindex = "5" )
                    %p( tabindex = "6", rel = "foo" )
                    %p( rel = @foo )
                    %p{ :rel => "foo" }
                    %p{ :rel => @foo, :ref => 'ola' }
                    %p{ :data-lol => `@foo + @foo + @foo.length` }
                    """,
    append: fixture[0],
    vars:
      foo: 'hello'

  pElms = fixture.find 'p'

  ok pElms.eq(0).hasClass('abc'), 'We want the class `abc` on the first paragraph'

  ok pElms.eq(1).hasClass('def'), 'We want the class `def` on the second paragraph'
  ok pElms.eq(1).hasClass('ghijkl'), 'We want the class `ghijkl` on the second paragraph'

  equal pElms.eq(2).attr('id'), 'mno', 'We want the id `mno` on the third paragraph'

  equal pElms.eq(3).attr('id'), 'def', 'We want the id `def` on the fourth paragraph'
  ok pElms.eq(3).hasClass('abc'), 'We want the class `abx` on the fourth paragraph'
  ok pElms.eq(3).hasClass('ghi'), 'We want the class `ghi` on the fourth paragraph'

  equal pElms.eq(4).attr('tabindex'), '5', 'We want the attr `tabindex` to be "5" on the fifth paragraph'

  equal pElms.eq(5).attr('tabindex'), '6', 'We want the attr `tabindex` to be "6" on the sixth paragraph'
  equal pElms.eq(5).attr('rel'), 'foo', 'We want the attr `rel` to be "foo" on the sixth paragraph'

  equal pElms.eq(6).attr('rel'), 'hello', 'We want the attr `rel` to be "hello" on the seventh paragraph'

  equal pElms.eq(7).attr('rel'), 'foo', 'We want the attr `rel` to be "foo" on the eighth paragraph'

  equal pElms.eq(8).attr('rel'), 'hello', 'We want the attr `rel` to be "hello" on the ninth paragraph'
  equal pElms.eq(8).attr('ref'), 'ola', 'We want the attr `ref` to be "ola" on the ninth paragraph'

  equal pElms.eq(9).attr('data-lol'), 'hellohello5', 'We want the attr `data-lol` to be "hellohello5" on the tenth paragraph'




test 'It should indent simple documents properly', ->
  fixture = $ '#qunit-fixture'

  fixture.children().remove()

  haml = new Hamler """
                    .test-abc
                      %p.win-a EPIC WIN
                      .win-b
                        %p.win-c MORE WIN
                    %p GRANDE FAIL
                    """,
    append: fixture[0]

  divElm = fixture.find '.test-abc'
  pElms = divElm.find 'p'
  innerDivElms = divElm.find 'div'

  ok divElm.eq(0).hasClass('test-abc'), 'We want the class `abc` on the div'
  equal pElms.length, 2, 'We want only two paragraphs in the div with class `test-abc`'
  notEqual pElms.eq(0).text().indexOf('EPIC WIN'), -1, 'We want the text "EPIC WIN" to be in the first paragraph.'
  notEqual pElms.eq(1).text().indexOf('MORE WIN'), -1, 'We want the text "MORE WIN" to be in the third paragraph.'
  equal innerDivElms.length, 1, 'We want only one div in the div with class `test-abc`'




test 'It should indent complex documents properly', ->
  fixture = $ '#qunit-fixture'

  fixture.children().remove()

  haml = new Hamler """
                    .test-abc
                      %p A
                      %p B
                      .c
                        %p D
                        %p E
                        %p F
                      .g G
                      .h
                        .i
                          .j
                            %p K
                          .l L
                        .m M
                      .n N
                      .o O
                    """,
    append: fixture[0]

  divElm = fixture.find '.test-abc'

  ch = divElm.children()

  cCh = divElm.find('.c').children()
  hCh = divElm.find('.h').children()
  iCh = divElm.find('.i').children()
  jCh = divElm.find('.j').children()

  equal ch.length, 7, 'The div should contain seven direct children'
  notEqual ch.eq(0).text().indexOf('A'), -1, 'First child of the div should contain an "A"'
  notEqual ch.eq(1).text().indexOf('B'), -1, 'Second child of the div should contain a "B"'
  notEqual ch.eq(3).text().indexOf('G'), -1, 'Fourth child of the div should contain a "G"'
  notEqual ch.eq(5).text().indexOf('N'), -1, 'Sixth child of the div should contain an "N"'
  notEqual ch.eq(6).text().indexOf('O'), -1, 'Seventh child of the div should contain an "O"'

  equal cCh.length, 3, 'The div with class `c` should contain three children'
  notEqual cCh.eq(0).text().indexOf('D'), -1, 'First child of the div with class `c` should contain a "D"'
  notEqual cCh.eq(1).text().indexOf('E'), -1, 'Second child of the div with class `c` should contain an "E"'
  notEqual cCh.eq(2).text().indexOf('F'), -1, 'Third child of the div with class `c` should contain an "F"'

  equal hCh.length, 2, 'The div with class `h` should contain two children'
  notEqual hCh.eq(1).text().indexOf('M'), -1, 'Second child of the div with class `h` should contain a "M"'

  equal iCh.length, 2, 'The div with class `i` should contain two children'
  notEqual iCh.eq(1).text().indexOf('L'), -1, 'Second child of the div with class `i` should contain a "L"'

  equal jCh.length, 1, 'The div with class `j` should contain one child'
  ok jCh.is('p'), 'Only child of the div with class `j` should be a paragraph'
  notEqual jCh.eq(0).text().indexOf('K'), -1, 'Only child of the div with class `j` should contain a "K"'

  equal divElm.find('div').length, 9, 'There should be exactly nine divs nested in the wrapper div'
  equal divElm.find('p').length, 6, 'There should be exactly six paragraphs nested in the wrapper div'




test 'It should be able to make decisions based on passed arguments', ->
  fixture = $ '#qunit-fixture'

  fixture.children().remove()

  haml = new Hamler """
                    .test-abc
                      - if @first === 'Hello'
                        %p= @first
                      - else
                        %p FAIL
                      %hr.first
                      - unless true
                        %p FAIL
                      - else
                        %p WIN
                      %hr.second
                      - if @first.length > 999
                        %p FAIL
                      - elseif @first.length < 2
                        %p ALSO FAIL
                        .fail
                          %p Indent failure?
                      - else
                        %p WIN
                      %hr.third
                      %h2 TEST FIRST?
                      .some-diff
                        %h3 TEST AGAIN?
                        - if true
                          %span WIN
                        - else
                          %strong FAIL
                        %p
                          = @first
                          DUDE
                    - if true
                      %p.winwinwin LOLWUT
                    """,
    append: fixture[0],
    vars:
      first: 'Hello'

  divElm = fixture.find '.test-abc'
  someDiffCh = fixture.find('.some-diff').children()

  ch = divElm.children()

  equal ch.length, 8, 'The div should contain three direct children'
  ok ch.eq(0).is('p'), 'The first child should be a paragraph'
  notEqual ch.eq(0).text().indexOf('Hello'), -1, 'The first child should contain "Hello"'
  ok ch.eq(1).is('hr.first'), 'The second child should be a horizontal line with class `first`'
  ok ch.eq(2).is('p'), 'The third child should be a paragraph'
  notEqual ch.eq(2).text().indexOf('WIN'), -1, 'The third child should contain "WIN"'
  ok ch.eq(3).is('hr.second'), 'The fourth child should be a horizontal line with class `second`'
  notEqual ch.eq(4).text().indexOf('WIN'), -1, 'The fifth child should contain "WIN"'
  ok ch.eq(5).is('hr.third'), 'The sixth child should be a horizontal line with class `third`'
  notEqual ch.eq(6).text().indexOf('TEST FIRST?'), -1, 'The seventh child should contain "TEST FIRST?"'
  ok ch.eq(6).is('h2'), 'The seventh child should be a paragraph'
  ok ch.eq(7).is('div.some-diff'), 'The eighth child should be a div with class `some-diff`'

  equal someDiffCh.length, 3
  ok someDiffCh.eq(0).is('h3'), 'First elm should be a H3'
  notEqual someDiffCh.eq(0).text().indexOf('TEST AGAIN?'), -1, 'The first elm should contain "TEST AGAIN?"'
  ok someDiffCh.eq(1).is('span'), 'Second elm should be a SPAN'
  notEqual someDiffCh.eq(1).text().indexOf('WIN'), -1, 'The second elm should contain "WIN"'
  ok someDiffCh.eq(2).is('p'), 'Third elm should be a P'
  notEqual someDiffCh.eq(2).text().indexOf('Hello'), -1, 'The third elm should contain "Hello"'
  notEqual someDiffCh.eq(2).text().indexOf('DUDE'), -1, 'The third elm should contain "DUDE"'

  equal divElm.next('p.winwinwin').length, 1, 'There should be a paragraph after the div'

  console.log someDiffCh[2].innerHTML



test 'It should be able to repeat stuff', ->
  fixture = $ '#qunit-fixture'

  fixture.children().remove()

  haml = new Hamler """
                    .test-numbers
                      - @numbers.each do |number|
                        %p
                          Your lucky number is!
                          %strong= @number
                          - if @number > 100
                            %blink AWESOME
                    .test-hashes
                      %ul#portfolio
                        - @portfolio.each do |item|
                          %li{ :data-foo => @item.foo }
                            %h2= @item.name
                            %p= @item.desc
                    """,
    append: fixture[0],
    vars:
      numbers: [400, 8123, 42, 3.14]
      portfolio: [
        {
          foo: 'random'
          name: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit'
          desc: 'Maecenas sit amet leo eget justo sollicitudin dapibus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.'
        }
        {
          foo: 'foobar'
          name: 'Duis eu dapibus urna'
          desc: 'Aliquam porta lorem a risus consectetur congue. Integer et arcu suscipit nibh elementum lobortis.'
        }
        {
          foo: 'booboo'
          name: 'Donec gravida mauris ac massa ultrices a commodo erat pulvinar'
          desc: 'Etiam et ligula tortor, vel tempus neque. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce eget justo arcu. '
        }
      ]


  numbersElm = fixture.find '.test-numbers'

  ch = numbersElm.children()
  pElms = numbersElm.find 'p'
  strongElms = pElms.find 'strong'
  blinkElms = pElms.find 'blink'

  equal ch.length, 4, 'There should be four children in the numbers div'
  equal pElms.length, 4, 'There should be four paragraphs'
  equal strongElms.length, 4, 'There should be four strong elements'
  equal blinkElms.length, 2, 'There should be two blink elements'
  notEqual strongElms.eq(0).text().indexOf('400'), -1, 'There should be a 400 in the first strong'
  notEqual strongElms.eq(1).text().indexOf('8123'), -1, 'There should be a 8123 in the first strong'
  notEqual strongElms.eq(2).text().indexOf('42'), -1, 'There should be a 42 in the first strong'
  notEqual strongElms.eq(3).text().indexOf('3.14'), -1, 'There should be a 3.14 in the first strong'


  hashElm = fixture.find '.test-hashes'

  ch = hashElm.children()
  ulElm = hashElm.find 'ul'
  liElms = ulElm.find 'li'

  equal ch.length, 1, 'There should be one childr in the hash div'
  equal ulElm.children().length, 3, 'There should only be two children in the list'
  equal liElms.length, 3, 'Therse children should be list items'

  li = liElms.eq 0

  equal li.attr('data-foo'), 'random', 'The first list item should have a foo data attr with value "random"'

  li = liElms.eq 1

  equal li.attr('data-foo'), 'foobar', 'The second list item should have a foo data attr with value "foobar"'
  notEqual li.find('h2').text().indexOf('Duis eu dapibus urna'), -1, 'The second list item H2 should contain the right text'
  notEqual li.find('p').text().indexOf('Integer et arcu suscipit nib'), -1, 'The second list item desc should contain the right text'

  li = liElms.eq 2

  equal li.attr('data-foo'), 'booboo', 'The first list item should have a foo data attr with value "booboo"'


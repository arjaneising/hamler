class Hamler
  constructor: (urlOrHaml, @options = {})->
    @templates = {}
    @queue = []
    if urlOrHaml.indexOf("\n") is -1
      @loadResource urlOrHaml
    else
      @completed = true
      @templates[0] = urlOrHaml
      @render 0, options
    return this




  loadResource: (url) ->
    $ = window.jQuery or @options.jQuery or false
    
    context = this
    context.completed = false

    # Try including via RequireJS
    if typeof require is 'function'
      require ["text!#{ url }"], (data) ->
        context.completed = true
        context.parseFile.call context, data
        context.clearQueue()

    # Or via jQuery
    else if $
      promise = $.ajax url,
        cache: @options.cache ? true
        dataType: 'text'
      promise.done (data) ->
        context.completed = true
        context.parseFile.call context, data
        context.clearQueue()
      return promise

    # Or via the oldscool ajax wrappers
    else
      try
        xmlhttp = new XMLHttpRequest()
      catch e
        try
          xmlhttp = new ActiveXObject 'Msxml2.XMLHTTP'
        catch e
          try
            xmlhttp = new ActiveXObject 'Microsoft.XMLHTTP'
          catch e
            xmlhttp = false
      return null unless xmlhttp

      try
        xmlhttp.open 'get', url
        xmlhttp.onreadystatechange = (result) ->
          if xmlhttp.readyState is 4 and not context.completed
            context.completed = true
            context.parseFile.call context, xmlhttp.responseText
            context.clearQueue()
        xmlhttp.send null
      catch e
        return false
      xmlhttp




  # Split the file in parts, save it in a local var
  parseFile: (data) ->
    regex = /^\${3}\s([a-zA-Z0-9]+)\s\${3}$/

    lines = data.split "\n"
    name = null

    for line in lines
      if regex.test line
        [a, name] = line.match regex
        @templates[name] = []
      else if name
        @templates[name].push line



  clearQueue: ->
    while @queue.length
      item = @queue.shift()
      @render item.name, item.options



  # Accepts some variables and the name/id of a template
  render: (name, options) ->
    unless @completed
      @queue.push
        name: name
        options: options
      return false

    vars = options.vars ? {}
    elm = @haml @templates[name], vars
    if options.append
      return options.append.appendChild elm
    else if options.prepend
      return options.prepend.insertBefore elm, options.prepend.firstChild
    else if options.before
      return options.before.parentNode.insertBefore elm, options.before
    else if options.after
      return options.after.parentNode.insertBefore elm, options.after.nextSibling
    else
      return elm




  haml: (lines, vars) ->
    standardIndent = false
    lines = lines.split "\n" if typeof lines is 'string'
    level = 0
    prevLevel = -1

    # Stores the last added nodes in order of deepness
    appendParents = [document.createDocumentFragment()]

    indentCorrections = []

    for i, line of lines
      # Check how deep the current line is indented
      indentMatch = line.match /^[\s]+/

      # Only the first time we indent, to discover which type op indentation we want
      if standardIndent is false and indentMatch isnt null
        standardIndent = indentMatch[0].length

      level = 0
      if indentMatch isnt null
        level = indentMatch[0].length / standardIndent


      # Indentcorrections are control structures.
      # If the indent level is higher than a certain point of an active indentcorrection,
      # it saves the line.
      # If we are back to the original level, feed the lines as argument to the Haml function.
      # Recursion bitches!
      shouldParseLine = true
      for corr in indentCorrections
        continue if corr.active is false

        if corr.type is 'each'
          if level > corr.level
            corr.collected.push line.substr (corr.level + 1) * standardIndent
            shouldParseLine = false
          else
            corr.active = false
            for value in vars[corr.loop]
              $v = @cloneObj vars
              $v[corr.key] = value
              appendParents[corr.level].appendChild @haml corr.collected, $v

        else
          if level > corr.level
            if corr.show
              corr.collected.push line.substr (corr.level + 1) * standardIndent
            shouldParseLine = false
          else
            corr.active = false
            if corr.collected.length
              $v = @cloneObj vars
              appendParents[corr.level].appendChild @haml corr.collected, $v


      unless shouldParseLine
        continue


      # Parse the current line, could be any type of line
      elm = @parseLine line, vars


      # The 'element' is a string, so we 'parse' the string to see which control structure it is,
      # and what its arguments are.
      if typeof elm is 'string'
        [type, args...] = elm.split '|'

        if type in ['if', 'elseif', 'else']
          show = args[0]

          if show is 'o' # oppose
            opposeTo = null
            for i in [(indentCorrections.length - 1)..0]
              corr = indentCorrections[i]
              if corr.level is level and corr.type is 'if'
                opposeTo = corr.show
                break
            if opposeTo is null
              throw 'Nothing to else or elseif from'
            else
              show = if opposeTo then 'h' else 's'
          indentCorrections.push
            active: true
            level: level
            show: show is 's'
            type: type
            collected: []
        else
          indentCorrections.push
            active: true
            level: level
            type: 'each'
            collected: []
            loop: args[0]
            key: args[1]
        continue


      unless elm
        continue


      # We unindented one or more levels
      if level < prevLevel
        # As many unindents as needed
        for i in [0...(prevLevel - level)]
          l = appendParents.length
          continue if l < 3
          appendParents[l - 2].appendChild appendParents[l - 1]
          appendParents.splice l - 1, 1
        appendParents[appendParents.length - 2].appendChild elm
        appendParents[appendParents.length - 1] = elm

      # Same indentation level, add to the children of the parent node
      else if level is prevLevel
        appendParents[appendParents.length - 2].appendChild elm
        appendParents[appendParents.length - 1] = elm

      # Indentend one level, append current node as first child of the parent node
      else if level - prevLevel is 1
        appendParents[appendParents.length - 1].appendChild elm
        appendParents.push elm

      else
        throw 'Too much indentation'
      
      prevLevel = level


    # Close with indent corrections as well, but a bit different.
    for corr in indentCorrections
      continue if corr.active is false
      if corr.type is 'each'
        for value in vars[corr.loop]
          $v = @cloneObj vars
          $v[corr.key] = value
          appendParents[corr.level].appendChild @haml corr.collected, $v
          appendParents.splice corr.level + 1, Infinity
      else
        if corr.collected.length
          $v = @cloneObj vars
          appendParents[corr.level].appendChild @haml corr.collected, $v
          appendParents.splice corr.level + 1, Infinity


    return appendParents[0]



  # Simpleclone an object
  cloneObj: (obj) ->
    clone = {}

    for key, val of obj
      if typeof val is 'object'
        clone[key] = @cloneObj val
      else
        clone[key] = val

    clone




  parseLine: (line, vars) ->
    $v = @cloneObj vars # easy acces to template veriables

    # Strip the whitespace
    line = line.replace /^\s+/, ''

    return false if line.length is 0

    parsed = line.match /// ^
      (%[a-zA-Z0-9]+)? # element
      (\.[-\w\u00C0-\uFFFF]+)? # classes before the id
      (\#[-\w\u00C0-\uFFFF=$]+)? # id
      (\.[-\w\u00C0-\uFFFF]+)? # classes after the id
      ((\{[^}]+\})|(\([^)]+\)))? # other attributes
      (=?[\s]+[\s\S]+)? # actual content
      $ ///

    # Not an element, must be a control structure or text
    if parsed is null
      # Control structure
      if line.indexOf('-') is 0
        action = line.match /^\-\s+(if|unless|elseif|else|\$v\.([a-zA-Z0-9.]+)\.each\sdo\s\|([a-zA-Z0-9]+)\|)/
        if action is null
          throw 'Unrecognized control structure'
        else
          if not action[2]
            if action[1] is 'if' or action[1] is 'unless'
              show = eval line.substring(action[0].length)
              show = not show if action[1] is 'unless'
              return 'if|s' if show
              return 'if|h'
            else if action[1] is 'elseif'
              show = eval line.substring(action[0].length)
              return 'elseif|h' unless show
              return 'elseif|o'
            else
              return 'elseif|o'
          else
            return "each|#{ action[2]}|#{ action[3] }"
      # Plain text
      else
        return @htmlify line
    # An actual element, build it
    else
      # Element nodename
      nodeName = 'div'
      nodeName = parsed[1].substr(1) if parsed[1]

      attrs = {}

      className = (parsed[2] || '') + (parsed[4] || '')
      className = className.replace(/\./g, ' ').replace(/^\s+|\s+$/g, '') # strip some whitespace
      attrs['class'] = className if className.length

      if parsed[3]
        attrs['id'] = parsed[3].substr 1

      if parsed[5]
        @parseAttrs attrs, parsed[5], $v

      elm = document.createElement nodeName

      for attr, val of attrs
        elm.setAttribute attr, val

      if parsed[8]
        txt = parsed[8]
        if txt.indexOf('=') is 0
          txt = eval parsed[8].substr 1 # eval = evil, I know. go ahead and fix this in your next pull request
        elm.appendChild @htmlify txt

      elm


  # Parse HTML by setting the innerhtml prop of a div.
  # Then move all nodes inclusing text nodes to a document fragment.
  htmlify: (text) ->
    frag = document.createDocumentFragment()
    div = document.createElement 'div'
    div.innerHTML = text
    frag.appendChild div

    while div.firstChild
      frag.appendChild div.removeChild div.firstChild

    frag.removeChild div

    frag




  # Loop over all tokens, recognise attribute names and their values from it
  parseAttrs: (attrs, str, $v) ->
    tokens = str.substr(1, str.length - 2).split ''

    addUpUntil = ''
    addedUp = ''
    parts = []
    ignoreSpaces = true

    for token, i in tokens
      nextToken = if i < (tokens.length - 1) then tokens[i + 1] else ''
      # Concat all tokens until a special character is found
      unless ignoreSpaces and token is ' '
        addedUp += token
      if token in addUpUntil.split ''
        parts.push addedUp
        addUpUntil = ''
        addedUp = ''
        ignoreSpaces = true
      # Commas to separate attributes
      else if token is ',' and not addUpUntil
        parts.push addedUp
        addUpUntil = ''
        addedUp = ''
        ignoreSpaces = true
      # Quotes for attribute values
      else if token is '"' and not addUpUntil
        addUpUntil = '"'
        ignoreSpaces = false
      else if token is "'" and not addUpUntil
        addUpUntil = "'"
        ignoreSpaces = false
      # Some cases of the attribute names
      else if token is ':' and not addUpUntil
        addUpUntil = '>'
      else if token is '=' and not addUpUntil
        addUpUntil = ' '
      else if token is '$' and nextToken is 'v' and not addUpUntil
        addUpUntil = ', '

    attr = null
    value = null

    for part in parts
      if part.indexOf('"') is 0 or part.indexOf("'") is 0
        value = part.substr 1, part.length - 2
      else if part.indexOf('$v') is 0
        if part.lastIndexOf(',') is part.length - 1
          part = part.substr 0, part.length - 1
        value = eval part # eval = evil, I know. go ahead and fix this in your next pull request
      else
        if part.indexOf(':') is 0
          attr = part.substr 1, part.length - 3
        else
          attr = part.substr 0, part.length - 1
        value = null

      if attr and value
        attrs[attr] = value
        attr = null
        value = null
    return


window.Hamler = Hamler


if typeof define is 'function' and define.amd
  define 'Hamler', ->
    Hamler
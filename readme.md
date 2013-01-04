# Hamler

*Client-side Haml parser written in CoffeeScript*

---

Separation of content, presentation and behaviour. It is one of the axioms of modern web development. But we still write some HTML in our JavaScript (or CoffeeScript).

Hamler allows you to write simple [Haml](http://haml.info/) templates using a subset of the most important Haml features, and mix it with control structures from JavaScript.

---

## Demo

Demo on Github-pages: <http://arjaneising.github.com/hamler/demo/>

---

## How does it work?

This is what your JavaScript looks like:

```
templates = new Hamler('/path/tp/templates.hamler');
templates.render('random', {
  append: document.querySelector('body'),
  vars: {
    obj: {
      foo: 123,
      bar: 456,
      baz: 789
    }
  }
);
```

First loading the template file, then appending the template in that file with name "demo".

So what does the `templates.hamler` file look like?

```
$$$ random $$$

.some-class
  %h1 A title
  %ul
    %li= @obj.foo
    %li= @obj.bar
    %li= @obj.baz
 
$$$ another $$$
…
```

---

## Variables and control structures in Hamler

Variables are passed as object to the options object as second argument to the render function.

In the templates, you can access them like this for echo-ing:

```
%h1= @variableName
```

Or as an attribute:

```
%p{ :class => @someClass }
```

Although on some places you can modify the variables using JavaScript, it should at all times be avoided and be taken care of in the regular JavaScript.

If you want to do calculations for the attributes, wrap them arround backticks:

```
%p{ :class => `Math.sqrt(@someClass.length * 5)` }
```

### Control structures

```
%h1
  - if @title.length > 100
    = @title.substr(0, 100) + '…'
  - elseif @title.length === 42
    = @title.toUpperCase()
  - else
    = @title
``` 

You can also use `unless`. Note there is no space between the `else` and `if` in `elseif`.

```
%ul.items
  - @items.each do |item|
    %li= @item
```

---

## License

Just like main Haml project, Hamler is licensed under MIT license. See the file `LICENSE`.
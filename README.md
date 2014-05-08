Hamlet
======

Truly amazing templating!

Examples
--------

### Hello World

```haml
%button(click=@hello) Say Hello!
```

```coffee-script
hello: ->
  alert "Hello World!"
```

### Simple HTML

```haml
%h1 Welcome to the world of Tomorrow!
%p Where all of your wildest dreams will come true!
```

### Corresponding Bindings

```haml
%input(type="text" value=@value)
%select(value=@value)
  - each [0..@max], (option) ->
    %option(value=option)= option
%hr
%input(type="range" value=@value min="1" max=@max)
%hr
%progress(value=@value max=@max)
```

```coffee-script
max: 10
value: Observable 5
```

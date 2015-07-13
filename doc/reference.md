
# Package Reference

#### ``@!``

```
Expresso.@!(ex)
```

> Set access restrictions on modules and types.

`@!` allows module and type internals to be hidden from users of libraries.

  * Only `export`ed symbols are visible from outside a module.
  * Type fields can only be accessed via getter/setter methods.

### Syntax

```
@! [
<<configuration and metadata>>
],
<<module or type definition>>
```

Note the `,` after the clossing `]` and the space between `@!` and the opening `[`. **Both are required**. Configuration and metadata can be things such as docstrings. Further additions might be added at a later time.

### Examples

#### Modules

```julia
@! [],
module M

export f

f(x) = g(x, 2x)

g(x, y) = y, x

end
```

Description:

`M.g` will not be visible from outside of the module. Only exported symbols can be accessed.

The user-defined module `M` is wrapped in another module and renamed using `gensym` so that it cannot be accessed easily. All exports from the inner module are imported into the outer one and then re-exported. The outer module is named `M`.

#### Types

```julia
@! [],
type T
    x :: Int := begin
        getx() = self.x - 10
        setx!(val) = 0 < val < self.x ? self.x = val : error("Cannot set.")
    end
end
```

Description:

The type `T` has a single field, `x :: Int`, which is made private by using the `@!` macro and defining a block of accessors with the syntax `:= begin ... end`.

Each method in the block takes an implicit first argument `self::T` which references the object itself and allows for accessing the private field `x`. Outside of the type `x` is not easily accessible.

### Documention

To add documentation to either a module or type that has been defined with `@!` one can pass a docstring in the `[ ... ]` block:

```julia
@! [
"..."
],
module M
# ...
end
]
```

and for types the fields and accessors can also be documented:

```julia
@! [
"..."
],
type T
    "..."
    y :: Int
    x :: Int := begin
        "..."
        getx() = self.x - 10
        "..."
        setx!(val) = self.x -= val
    end
end
```


---

#### ``@merge``

```
Expresso.@merge(func, modules...)
```

> Merge functions from different modules.

*Example:*

```julia
module A

type T end
f(::T) = T

end

module B

type T end
f(::T) = T

end

@merge f A B

f(A.T())
f(B.T())
```

If several modules provide methods suitable for the specified arguments then the first listed, in the above example it would be `A`, is selected.

### Generated Code

`@merge` uses `@generated` to build specialised code for each tuple of arguments passed to the merged function. The resulting code will typically have little to no overhead due to inlining of the dispatch function.

*Example:*

```julia
module A

f(x::Int, y::Float64) = x + 2y

end

module B

f(x::Float64, y::Int) = x - 3y

end

@merge f A B

test(x, y) = f(x, y) + f(y, x)

@code_llvm test(1, 1.0)
```

```llvm
define double @julia_test_21348(i64, double) {
top:
  %2 = sitofp i64 %0 to double
  %3 = fmul double %1, 2.000000e+00
  %4 = fadd double %2, %3
  %5 = mul i64 %0, 3
  %6 = sitofp i64 %5 to double
  %7 = fsub double %1, %6
  %8 = fadd double %4, %7
  ret double %8
}
```


---

#### ``@\\``

```
Expresso.@\(ex)
```

> Anonymous functions syntax with implicit numbered arguments.

Numbering of arguments starts from `1` and are written using the transpose operator `'`. `@\` always defines a `...` type function so that the last listed argument does not limit how many arguments can be taken by the function.

*Examples:*

```julia
map((@\ 1' - 10), 1:10)
reduce((@\ 1' - 1' / 2'), 10:1000)
```

**Note:** For short definitions this syntax does not have much advantage over traditional `->` syntax, but when the argument names are unimportant this syntax can be handy.


---

#### ``@S_str``

```
Expresso.S"text"
```

> Create `Symbol`s from strings with shorter syntax.

*Example:*

```julia
S"foo-bar"
```


---

#### ``Head``

```
Expresso.Head
```

> Symbolic dispatch type.

Dispatch to particular methods depending on the value of an expression's `.head` field.

*Example:*

```julia
f(::Head{:macro})    = # ...
f(::Head{:function}) = # ...
```

```
Expresso.Head(ex)
```

> Conveince constructor for the `Head` type.

*Example:*

```julia
Head(:(module M end))
```


---

#### ``@H_str``

```
Expresso.H"args"
```

> Shorthand syntax for dispatching on expression `.head`s.

*Example:*

```julia
f(::H"macrocall, call") = # ...
```


---

#### ``@defmacro``

```
Expresso.@defmacro(head, body)
```

> Define macros with keyword names.

*Examples:*

```julia
@defmacro:using(args...) begin
    # ...
end

@using foo bar baz

@defmacro:end(ex) foo(ex)

@end begin
    # ...
end
```


---

#### ``@for``

```
Expresso.@for(itr, body)
```

> Shorthand `for`-loop syntax.

*Example:*

```julia
@for i in 1:10 println(i)
```


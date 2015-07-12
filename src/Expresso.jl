module Expresso

using Compat, Base.Meta

include("defmacro.jl")
include("utilities.jl")
include("lambda.jl")
include("dispatch.jl")
include("properties.jl")
include("merge.jl")

include("Templates.jl")

"""
Main features:

- Access control macro, ``@!``, for setting type fields and un-exported symbols as private.
- Function merging macro, ``@merge``, to combine functions from different modules.

All documentation can be viewed with the ``?`` mode or [reference page](doc/refernece.md).

A quick taste:

```julia
julia> using Expresso

julia> @! [
       \"""
       docs go here...
       \"""
       ],
       type T
           x :: Int := begin
               "getter..."
               getx() = self.x - 10
               "setter..."
               setx!(val) = 0 < val < self.x ? self.x = val : error("Can't do that.")
           end
       end
T

julia> t = T(10)
T(10)

julia> t.x
ERROR: type T has no field x

julia> getx(t)
0

julia> setx!(t, 11)
ERROR: Can't do that.
 in setx! at none:11

julia> setx!(t, 6)
6

julia> t
T(6)

julia> @defmacro:for(itr, body) esc(Expr(:for, itr, body))

julia> @for i in 1:10 print(i, " ")
1 2 3 4 5 6 7 8 9 10
```

**Exports:**

$(join(["- ``$(n)``" for n in names(Expresso)], "\n"))

Detailed documentation for the exports listed above can be found using ``?``.

"""
Expresso

end # module

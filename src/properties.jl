
export @!

"""
    Expresso.@!(ex)

> Set access restrictions on modules and types.

``@!`` allows module and type internals to be hidden from users of libraries.

- Only ``export``ed symbols are visible from outside a module.
- Type fields can only be accessed via getter/setter methods.

### Syntax

    @! [
    <<configuration and metadata>>
    ],
    <<module or type definition>>

Note the ``,`` after the clossing ``]`` and the space between ``@!`` and the opening
``[``. **Both are required**. Configuration and metadata can be things such as docstrings.
Further additions might be added at a later time.

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

``M.g`` will not be visible from outside of the module. Only exported symbols can be
accessed.

The user-defined module ``M`` is wrapped in another module and renamed using ``gensym`` so
that it cannot be accessed easily. All exports from the inner module are imported into the
outer one and then re-exported. The outer module is named ``M``.

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

The type ``T`` has a single field, ``x :: Int``, which is made private by using the ``@!``
macro and defining a block of accessors with the syntax ``:= begin ... end``.

Each method in the block takes an implicit first argument ``self::T`` which references the
object itself and allows for accessing the private field ``x``. Outside of the type ``x``
is not easily accessible.

### Documention

To add documentation to either a module or type that has been defined with ``@!`` one can
pass a docstring in the ``[ ... ]`` block:

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

"""
macro (!)(ex) buildexpr(Head(ex), ex.args...) end

buildexpr(::H"tuple", args::Expr, body::Expr) = buildexpr(Head(body), args, body)

buildexpr(::Any...) = throw(ArgumentError("Invalid '@!' syntax used."))

type Metadata
    docs

    # TODO: other fields.

    function Metadata(ex::Expr)
        @assert isexpr(ex, :vect) "Invalid metadata section."
        object = new("")
        for arg in ex.args
            isdoc(arg) && (object.docs = arg)
        end
        object
    end
end

# Types. #

function buildexpr(::H"type", args::Expr, expr::Expr)
    metadata = Metadata(args)
    vars, body, outer = parsetype(expr.args[end], nameof(expr))
    map((@\ replacequalified!(1', vars)), outer)
    expr.args[end] = Expr(:block, body...)
    quote
        @doc $(esc(metadata.docs)) $(esc(expr))
        $(esc(insertdocs(outer)))
        $(esc(nameof(expr)))
    end
end

function parsetype(ex::Expr, typename::Symbol)
    vars = Dict()
    body = []
    outer = []
    for arg in ex.args
        if isexpr(arg, :(:=))
            field, funcs = arg.args
            name = nameof(field)
            vars[name] = gensym(name)
            push!(body, replacefield(field, vars[name]))
            for func in funcs.args
                isline(func) && continue
                isdef(func)  && addself!(func, typename)
                push!(outer, func)
            end
        else
            push!(body, arg)
        end
    end
    vars, body, outer
end

function insertdocs(outer)
    block = []
    while !isempty(outer)
        tmp = shift!(outer)
        if isdoc(tmp) && !isempty(outer)
            push!(block, :(@doc $(tmp) $(shift!(outer))))
        else
            push!(block, tmp)
        end
    end
    Expr(:block, block...)
end

# Modules. #

function buildexpr(::H"module", args::Expr, expr::Expr)
    metadata = Metadata(args)
    modname = nameof(expr)
    newname = gensym("module:$(modname)")
    newexpr = :(module $(newname) end)
    append!(newexpr.args[end].args, expr.args[end].args[3:end])
    Expr(:toplevel,
        (quote
            module $(modname)
                @doc $(metadata.docs) $(modname)
                using Expresso
                $(newexpr)
            end
        end).args[end], # Only the module expression is wanted.
        quote
            let private = $(modname).$(newname), public = $(modname)
                eval(public, Expresso.imports(private))
                eval(public, Expresso.exports(private))
                public
            end
        end
    ) |> esc
end

imports(m::Module) = Expr(:toplevel,
    [Expr(:import, :., module_name(m), n) for n in exported_symbols(m)]...
)

exports(m::Module) = Expr(:toplevel, Expr(:export, exported_symbols(m)...))

exported_symbols(m::Module) = filter((@\ 1' ≠ module_name(m)), names(m))

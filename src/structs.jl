
export @immutable, @type

"""
    Expresso.@immutable(args...)

> Construct an anonymous immutable type instance.

*Example:*

```julia
t = @immutable(
    a = 1.0,
    b = 2.1,
)

t.a + t.b
```

**See also:** ``@type``.

"""
@defmacro:immutable(args...) buildcall(:i, args...)

"""
    Expresso.@type(args...)

> Construct an anonymous mutable type instance.

*Example:*

```julia
t = @type(
    x = 2,
    y = 3,
)

t.x += t.y

```

### Syntax

In the example above each field and it's value were specified using ``field = value`` syntax.
When packing a group of variables into a ``@type`` or ``@immutable`` the following pattern can
become repetetive:

```julia
x, z = 1, 3
t = @type(
    x = x,
    y = 2,
    z = z,
)
```

and can be avoided by just providing the variable name in place of ``field = value``:

```julia
x, z = 1, 3
t = @type(x, y = 2, z)
```

which is equivalent to the previous example. The same syntax also applies to ``@immutable``.

**See also:** ``@immutable``.

"""
@defmacro:type(args...) buildcall(:m, args...)

function buildcall(kind, args...)
    names, values = Expr(:tuple), Expr(:tuple)
    @for a in args addfields!(names.args, values.args, a)
    :($(symbol(kind, "_struct"))($(esc(names)), $(esc(values))...))
end

addfields!(n, v, x::Expr)        = addfields!(n, v, Head(x), x)
addfields!(n, v,  ::H"=, kw", x) = (push!(n, Val{x.args[1]}()); push!(v, x.args[2]))
addfields!(n, v, s::Symbol)      = (push!(n, Val{s}()); push!(v, s))

addfields!(others...) = throw(ArgumentError("Invalid '@type'/'@immutable' syntax."))

@generated i_struct(fields, args...) = struct(false, fields, args...)
@generated m_struct(fields, args...) = struct(true,  fields, args...)

function struct{T}(ismutable::Bool, ::Type{T}, args...)
    name = gensym("[generated $(ismutable ? "type" : "immutable")]")
    expr = Expr(:type, ismutable, name)
    body = [Expr(:(::), x.parameters[1], y) for (x, y) in zip(T.parameters, args)]
    push!(expr.args, Expr(:block, body...))
    eval(current_module(), expr)
    :($(current_module()).$(name)(args...))
end

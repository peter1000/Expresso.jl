
export @immutable, @type

@defmacro:immutable(args...) buildcall(:i, args...)

"""
    @immutable(args...)

> Construct an anonymous immutable type instance.

```julia
t = @immutable(
    a = 1.0,
    b = 2.1,
)

t.a + t.b
```
"""
:@immutable

@defmacro:type(args...) buildcall(:m, args...)

"""
    @type(args...)

> Construct an anonymous mutable type instance.

*Example:*

```julia
t = @type(
    x = 2,
    y = 3,
)

t.x += t.y
```
"""
:@type

function buildcall(kind, args...)
    names = Expr(:tuple)
    values = Expr(:tuple)
    for a in args
        push!(names.args, Val{a.args[1]}())
        push!(values.args, a.args[2])
    end
    :($(symbol(kind, "_struct"))($(esc(names)), $(esc(values))...))
end

@generated i_struct(fields, args...) = struct(false, fields, args...)
@generated m_struct(fields, args...) = struct(true,  fields, args...)

module Anonymous end

function struct{T}(ismutable::Bool, ::Type{T}, args...)
    name = gensym("[generated $(ismutable ? "type" : "immutable")]")
    expr = Expr(:type, ismutable, name)
    body = [Expr(:(::), x.parameters[1], y) for (x, y) in zip(T.parameters, args)]
    push!(expr.args, Expr(:block, body...))
    eval(Anonymous, expr)
    :(Expresso.Anonymous.$(name)(args...))
end

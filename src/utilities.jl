
export @S_str

"""
    Expresso.S"text"

> Create ``Symbol``s from strings with shorter syntax.

*Example:*

```julia
S"foo-bar"
```

"""
macro S_str(text) quot(symbol(text)) end

export @for

"""
    Expresso.@for(itr, body)

> Shorthand ``for``-loop syntax.

*Example:*

```julia
@for i in 1:10 println(i)
```

"""
@defmacro:for(itr, body) esc(Expr(:for, itr, body))

function nameof(ex::Expr)
    isexpr(ex, :type)   && return nameof(ex.args[2])
    isexpr(ex, :module) && return ex.args[2]
    isexpr(ex, :(::))   && return ex.args[1]
    nameof(ex.args[1])
end
nameof(s::Symbol) = s

getcall(ex::Expr) = isexpr(ex, :call) ? ex : getcall(ex.args[1])

replacefield(ex::Expr, name)  = (ex.args[1] = name; ex)
replacefield(s::Symbol, name) = name

isdef(ex::Expr) = isexpr(ex, [:function, :(=)]) && isexpr(ex.args[1], :call)
isdef(other)    = false

addself!(ex::Expr, tname::Symbol) = insert!(getcall(ex).args, 2, :(self::$(tname)))

function walk!(f!::Function, ex::Expr)
    @for arg in ex.args (f!(arg); walk!(f!, arg))
    ex
end
walk!(f!::Function, other) = (f!(other); other)

isqualified(ex, name) = isexpr(ex, :.) && ex.args[1] ≡ name

function replacequalified!(ex::Expr, name::Symbol, vars::Dict)
    isqualified(ex, name) || return ex
    var = ex.args[end].args[1]
    ex.args[end] = QuoteNode(get(vars, var, var))
    ex
end
replacequalified!(other, ::Symbol, ::Dict) = other

replacequalified!(ex, vars) = walk!(ex) do arg
    replacequalified!(arg, :self, vars)
end

isdoc(s::AbstractString) = true
isdoc(ex::Expr)          = isexpr(ex, :string)
isdoc(other)             = false

isline(lnn::LineNumberNode) = true
isline(ex::Expr)            = isexpr(ex, :line)
isline(other)               = false

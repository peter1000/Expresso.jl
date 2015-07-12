
export @\

"""
    Expresso.@\\(ex)

> Anonymous functions syntax with implicit numbered arguments.

Numbering of arguments starts from ``1`` and are written using the transpose operator ``'``.
``@\\`` always defines a ``...`` type function so that the last listed argument does not
limit how many arguments can be taken by the function.

*Examples:*

```julia
map((@\\ 1' - 10), 1:10)
reduce((@\\ 1' - 1' / 2'), 10:1000)
```

**Note:** For short definitions this syntax does not have much advantage over traditional
``->`` syntax, but when the argument names are unimportant this syntax can be handy.
"""
macro (\)(ex) esc(buildlambda(ex)) end

# Implementation. #

"""
Convert an ``@\\``-style anonymous function expression to standard syntax.
"""
function buildlambda(ex::Expr)
    vars = rewritebody!(ex)
    isempty(vars) && return :(($(gensym())...) -> $(ex))
    args = [get(vars, n, argname(n)) for n in 1:maximum(keys(vars))]
    head = Expr(:tuple, args..., Expr(:..., gensym()))
    :($(head) -> $(ex))
end
buildlambda(other) = buildlambda(Expr(:block, other))

"""
Does the expression match the form ``<num::Int>'``?
"""
isarg(ex::Expr) = isexpr(ex, S"'") && length(ex.args) ≡ 1 && isa(ex.args[1], Int)
isarg(other)    = false

"Create a unique variable name based on a provided number ``n``."
argname(n) = gensym("var:$(n)")

"""
Walk through ``Expr`` object and replace all ``<::Int>'`` nodes with ``gensym``d variables.

Returns a ``Dict{Int, Symbol}`` of argument number and generated variable name.
"""
function rewritebody!(ex::Expr, vars::Dict = Dict())
    if isarg(ex)
        ex.args = [get!(vars, ex.args[1], argname(ex.args[1]))]
        ex.head = :block
    else
        @for a in ex.args rewritebody!(a, vars)
    end
    vars
end
rewritebody!(::Any, vars::Dict) = vars

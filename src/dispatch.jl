
export Head

"""
    Expresso.Head

> Symbolic dispatch type.

Dispatch to particular methods depending on the value of an expression's ``.head`` field.

*Example:*

    f(::Head{:macro})    = # ...
    f(::Head{:function}) = # ...

"""
immutable Head{H} end

"""
    Expresso.Head(ex)

> Conveince constructor for the ``Head`` type.

*Example:*

    Head(:(module M end))

"""
Head(ex::Expr)  = Head{ex.head}()
Head(s::Symbol) = Head{s}()

export @H_str

"""
    Expresso.H"args"

> Shorthand syntax for dispatching on expression ``.head``s.

*Example:*

    f(::H"macrocall, call") = # ...

"""
macro H_str(text)
    Expr(:curly, :Union, map((@\ Head{symbol(1')}), split(text, ", "))...)
end

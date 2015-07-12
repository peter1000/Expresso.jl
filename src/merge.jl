
export @merge

"""
    Expresso.@merge(func, modules...)

> Merge functions from different modules.

*Example:*

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

If several modules provide methods suitable for the specified arguments then the first
listed, in the above example it would be ``A``, is selected.

"""
macro merge(func, modules...) buildmerge(func, modules) end

function buildmerge(func, modules)
    mods  = [getfield(current_module(), m) for m in modules]
    funcs = [(m, getfield(m, func)) for m in mods]
    quote
        @generated function $(func)(args...)
            m = module_name(Expresso.pickmodule($(funcs), args))
            :($(m).$($(quot(func)))(args...))
        end
    end |> esc
end

function pickmodule(choices, args)
    @for (m, fn) in choices method_exists(fn, args) && return m
    throw(ArgumentError("No suitable method found with arguments '$(args)'."))
end

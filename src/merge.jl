
export @merge

"""
    Expresso.@merge(func, modules...)

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

If several modules provide methods suitable for the specified arguments then the first
listed, in the above example it would be ``A``, is selected.

### Generated Code

``@merge`` uses ``@generated`` to build specialised code for each tuple of arguments passed
to the merged function. The resulting code will typically have little to no overhead due
to inlining of the dispatch function.

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

"""
macro merge(func, modules...)   buildmerge(func, false, modules) end

export @kwmerge

"""
    Expresso.@kwmerge(func, modules...)

> Variant of ``@merge`` with support for passing keyword arguments.

*Example:*

```julia
@kwmerge f A B
f(1, a = 2, b =  3)
```

**Note:** This macro should only be used when keywords are actually needed since the
generated code will probably not be as efficient as that of ``@merge``.
"""
macro kwmerge(func, modules...) buildmerge(func, true,  modules) end

function buildmerge(f, keywords, mods)
    mapping = [(m, getfield(m, f)) for m in [getfield(current_module(), m) for m in mods]]
    m = :(Expresso.pickmodule($(mapping), args))
    x = keywords ?
        :($(f)(args...; kws...) = :($($(m)).$($(quot(f)))(args...; kws...))) :
        :($(f)(args...)         = :($($(m)).$($(quot(f)))(args...)))
    esc(:(@generated $(x)))
end

function pickmodule(choices, args)
    @for (m, fn) in choices method_exists(fn, args) && return module_name(m)
    throw(ArgumentError("No suitable method found with arguments '$(args)'."))
end

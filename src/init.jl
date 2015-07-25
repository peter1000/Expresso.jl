
export @atinit

"""
    Expresso.@atinit(block)

> Register code to be run at module initialisation.

This macro extends ``__init__`` to allow a series of blocks to be executed when a module is
initialised. The actual ``__init__`` function must not be defined when using ``@atinit``.

This may be useful for macros that need to register generated code which must be run at
module initialisation time rather than parse time since multiple macros cannot define their
own ``__init__`` functions.

*Example:*

```julia
@atinit begin
    # First to be run.
end

@atinit foo() # Second to be run.
```

"""
macro atinit(block)
    quote
        @__init__
        atinit(() -> $(esc(block)))
    end
end

init(m::Module) = for f in getfield(m, :__hooks__) f() end

macro __init__()
    quote
        isdefined(:__hooks__) || (const $(esc(:__hooks__)) = Function[])
        isdefined(:__init__)  || ($(esc(:__init__))()      = init($(current_module())))
    end
end

atinit(f::Function) = (push!(getfield(current_module(), :__hooks__), f); nothing)


export atinit

"""
    Expresso.atinit(block)

> Register code to be run at module initialisation.

This function replaces ``__init__`` to allow a series of blocks to be executed when a module
is initialised. The actual ``__init__`` function must not be defined when using ``atinit``.

This may be useful for macros that need to register generated code which must be run at
module initialisation time rather than parse time since multiple macros cannot define their
own ``__init__`` functions.

*Example:*

```julia
atinit() do
    # First to be run.
end

atinit(foo) # Second to be run.
```

"""
function atinit(f::Function, m = current_module())
    isdefined(m, :__hooks__) || eval(m, :(const __hooks__ = Function[]))
    isdefined(m, :__init__)  || eval(m, :(__init__() = Expresso.init($(m))))
    push!(getfield(m, :__hooks__), f)
    nothing
end

init(m::Module) = for f in getfield(m, :__hooks__) f() end

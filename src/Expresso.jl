module Expresso

"""
# Expresso.jl

> Expression and macro utilities for Julia.

The package provides several utilities for working with expressions as well as a macro,
``@!``, for restricting access for modules and type fields. See the documentation
for ``@!`` for details and examples.

"""
Expresso

using Compat, Base.Meta

include("defmacro.jl")
include("utilities.jl")
include("lambda.jl")
include("dispatch.jl")
include("properties.jl")
include("merge.jl")

end # module

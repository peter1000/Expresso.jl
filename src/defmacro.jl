
export @defmacro

"""
    Expresso.@defmacro(head, body)

> Define macros with keyword names.

*Examples:*

    @defmacro:using(args...) begin
        # ...
    end

    @using foo bar baz

    @defmacro:end(ex) foo(ex)

    @end begin
        # ...
    end

"""
macro defmacro(head, body)
    Expr(:macro,
        Expr(:call,
            head.args[1].args[1],
            head.args[2:end]...),
        body
    ) |> esc
end

module Templates

"""
    Templates

> Package documentation DSL.

Extract docstrings from the Julia documentation system and render to markdown files.
"""
Templates

export build, @file_str

function build(func, title = "package")
    info("Generating $(title) documentation...")
    func()
    info("Done.")
end

macro file_str(text) makefilestr(text) end

function makefilestr(text)
    file, text = split(text, "\n", limit = 2)
    parts = split(text, r"{{|}}")
    out = []
    for i in 1:length(parts)
        push!(out, genwrite(iseven(i), parts[i]))
    end
    quote
        open(joinpath(dirname(@__FILE__), $(file)), "w") do f
            info("- $($(file))")
            $(Expr(:block, out...))
        end
    end
end

genwrite(pred, part) = pred ?
    :(writemime(f, "text/plain", @doc($(esc(parse(part)))))) :
    :(print(f, $(esc(part))))

# Missing methods.

function Markdown.plain(io::IO, quot::Markdown.BlockQuote)
    for content in quot.content
        print(io, "> ")
        Markdown.plain(io, content)
    end
end

function Markdown.plaininline(io::IO, link::Markdown.Link)
    s = sprint(io -> Markdown.plaininline(io, link.text))
    print(io, "[$(s)]($(link.url))")
end

end

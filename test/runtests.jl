using Base.Test

macro wrappedallocs(expr)
    argnames = [gensym() for a in expr.args]
    quote
        function g($(argnames...))
            @allocated $(Expr(expr.head, argnames...))
        end
        $(Expr(:call, :g, [esc(a) for a in expr.args]...))
    end
end

@testset "computed field types" begin
    include("computed/runtests.jl")
end

include("simple_interface.jl")
include("interface_with_parent.jl")

module NotebookTest
    using NBInclude
    @nbinclude(joinpath(@__DIR__, "..", "demo.ipynb"))
end

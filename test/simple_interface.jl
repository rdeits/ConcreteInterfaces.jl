module M1
using Interfaces

struct B
    x::Int
end

struct C
    x::Float64
end

@interface Foo{T} self begin
    foo(y::T)::Base.promote_op(+, T, Float64) = self.x + y
    bar(y::T)::T = self.x
end

end

@testset "simple interface" begin
    b = M1.B(1)
    c = M1.C(2.0)
    @test isa(@inferred(M1.Foo{Float64}(b)), M1.Foo{Float64, Float64})
    F = M1.Foo{Float64}.([b, c])
    @test eltype(F) == M1.Foo{Float64, Float64}
    @test @inferred(M1.foo(F[1], 2.0)) == 3.0
    @test M1.foo.(F, 2.0) == [3.0, 4.0]
    y = zeros(2)
    @test @wrappedallocs(y .= M1.foo.(F, 2.0)) == 0
end



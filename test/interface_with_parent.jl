module M2
using Interfaces

abstract type A end

struct B <: A
    x::Int
end

struct C <: A
    x::Float64
end

@interface Foo{T} self::A begin
    foo(y::T)::Base.promote_op(+, T, Float64) = self.x + y
    bar(y::T)::T = self.x
end
end

@testset "simple interface with parent" begin
    b = M2.B(1)
    c = M2.C(2.0)
    @test isa(@inferred(M2.Foo{Float64}(b)), M2.Foo{Float64, Float64})
    F = M2.Foo{Float64}.([b, c])
    @test eltype(F) == M2.Foo{Float64, Float64}
    @test @inferred(M2.foo(F[1], 2.0)) == 3.0
    @test M2.foo.(F, 2.0) == [3.0, 4.0]
    y = zeros(2)
    @test @wrappedallocs(y .= M2.foo.(F, 2.0)) == 0
end
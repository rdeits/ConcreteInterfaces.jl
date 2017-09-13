module M1
using Interfaces

struct B
    x::Int
end

struct C
    x::Float64
end

@interface Foo{T}(self) begin
    foo(y::T)::Base.promote_op(+, T, Float64) = self.x + y
    bar(y::T)::T = self.x
end

@interface Ifc2(x, y) begin
    get_z()::Float64 = x + y
end

@interface Ifc3{T}(x, y) begin
    get_z()::T = x + y
end

@interface Ifc4{T <: Integer}(x::Integer) begin
    bar(y::T)::T = x - y
end

end

@testset "simple interface" begin
    b = M1.B(1)
    c = M1.C(2.0)
    @test isa(@inferred(M1.Foo{Float64}(b)), M1.Foo{Float64, Float64})
    F = M1.Foo{Float64}.([b, c])
    @test F[1].self === b
    @test F[2].self === c
    @test eltype(F) == M1.Foo{Float64, Float64}
    @test @inferred(M1.foo(F[1], 2.0)) == 3.0
    @test M1.foo.(F, 2.0) == [3.0, 4.0]
    y = zeros(2)
    @test @wrappedallocs(y .= M1.foo.(F, 2.0)) == 0
end

@testset "interface with no args" begin
    I = [M1.Ifc2(1, 2.0), M1.Ifc2(3, 4.0)]
    @test I[1].x === 1
    @test I[1].y === 2.0
    @test I[2].x === 3
    @test I[2].y === 4.0
    @test M1.get_z.(I) == [3.0, 7.0]
    @test @inferred(M1.get_z(I[1])) == 3.0
    y = zeros(2)
    @test @wrappedallocs(y .= M1.get_z.(I)) == 0
end

@testset "parametric interface with no args" begin
    I = [M1.Ifc3{Complex{Float64}}(1, 2.0), M1.Ifc3{Complex{Float64}}(3, 4.0)]
    @test M1.get_z.(I) == [3.0 + 0im, 7.0 + 0im]
end

@testset "parametric interface with restriction" begin
    i1 = M1.Ifc4{Int}(23)
    @test @inferred(M1.bar(i1, 5)) === 18
end


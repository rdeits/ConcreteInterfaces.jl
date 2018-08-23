@computed mutable struct A{V <: AbstractVector}
    a::eltype(V)
end

@testset "basic example" begin
    a = A{Vector{Int}}(3.0)
    @test a.a === Int(3)
end

@computed mutable struct B{N, M, T}
    a::NTuple{N + M, T}
    B{N, M, T}(x::T) where {N, M, T} = new{N, M, T}(ntuple(i -> x, N + M))
    B{N, M, T}(x::S) where {N, M, T, S} = B{N, M, T}(convert(T, x))
end

@computed mutable struct C{T <: Number}
    a::typeof(one(T) / one(T))
    C{T <: Number}() where {T <: Number} = new(0)
    function C{T <: Number}(x) where T <: Number
        return new(x)
    end
end
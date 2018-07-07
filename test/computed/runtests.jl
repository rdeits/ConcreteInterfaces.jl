using ConcreteInterfaces.ComputedFieldTypes
using Base.Test

# Verify that @computed works on types with no computed fields

@computed struct NoComputed
    x::Int
end

@test typeof(@inferred(NoComputed(1))) === NoComputed
@test fulltype(NoComputed) === NoComputed

@computed struct NoComputedInner
    x::Int
    NoComputedInner(y) = new(y + 1)
end

@test typeof(@inferred(NoComputedInner(2))) === NoComputedInner
@test fulltype(NoComputedInner) === NoComputedInner
@test NoComputedInner(5).x == 6

include("readme_examples.jl")
include("inheritance.jl")

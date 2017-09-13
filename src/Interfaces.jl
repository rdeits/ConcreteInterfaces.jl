__precompile__()

module Interfaces

export @interface

include("ComputedFieldTypes/src/ComputedFieldTypes.jl")
using .ComputedFieldTypes
using FunctionWrappers: FunctionWrapper
using MacroTools

abstract type AbstractInterface end

function argtype(expr)
    if @capture(expr, x_::T_)
        return T
    else
        return :(Any)
    end
end

function parse_wrapper_field(expr)
    @assert @capture(expr, f_(y__)::X_ = ex_)
    :($(f)::FunctionWrapper{$(esc(X)), $(esc(:Tuple)){$(esc.(argtype.(y))...)}})
end

baretype(s::Symbol) = s
function baretype(ex::Expr)
    @assert @capture(ex, X_ <: T_)
    return X
end

function build_constructor(name, T, captures)
    :($name{$(baretype.(T)...)}($(captures...)) where {$(T...)})
end

function parse_closure(expr)
    @assert @capture(expr, f_(args__)::T_ = body_)
    if isempty(args)
        :(() -> $(body))
    else
        :($(args...) -> $(body))
    end
end

function outer_method(name, typeparams, methodexpr)
    @assert @capture(methodexpr, f_(args__)::T_ = body_)
    argtype = if isempty(typeparams)
        name
    else
        :($(name){$(baretype.(typeparams)...)})
    end
    :($f(self::$(argtype), $(args...)) where {$(typeparams...)} = self.$f($(args...)))
end

function parse_name(constructor)
    if @capture(constructor, S_{T__}(args__))
        return S, T, args
    elseif @capture(constructor, S_(args__))
        return S, [], args
    else
        error("couldn't parse $(constructor)")
    end
end

add_any(x::Symbol) = :($x::Any)
add_any(x::Expr) = x

macro interface(constructor, block)
    method_args = [arg for arg in block.args if arg.head == :(=)]
    wrapper_fields = parse_wrapper_field.(method_args)
    name, typeparams, captures = parse_name(constructor)
    quote
        @computed struct $(esc(name)){$(esc.(typeparams)...)} <: AbstractInterface
            $(esc.(add_any.(captures))...)
            $(wrapper_fields...)
                    
            $(esc(build_constructor(name, typeparams, captures))) = new($(esc.(captures)...), $(esc.(parse_closure.(method_args))...))
        end
                
        $(esc.(outer_method.(name, [typeparams], method_args))...)
    end
end

end
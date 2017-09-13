module Interfaces

export @interface

include("ComputedFieldTypes/src/ComputedFieldTypes.jl")
using .ComputedFieldTypes
using FunctionWrappers: FunctionWrapper
using MacroTools

abstract type AbstractInterface end

function parse_type_params(name_expr)
    if @capture(name_expr, S_{T__})
        return T
    else
        return []
    end
end 

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

parse_constructor(typeexpr::Symbol, capture) = :($(typeexpr)($(capture)))

function parse_constructor(typeexpr, capture)
    @assert @capture(typeexpr, S_{T__})
    :($S{$(baretype.(T)...)}($(capture)) where {$(T...)})
end

function parse_closure(expr)
    @assert @capture(expr, f_(args__)::T_ = body_)
    :($(args...) -> $(body))
end

function outer_method(typeexpr, methodexpr)
    interface_argtype = if @capture(typeexpr, S_{T__})
        S
    else
        typeexpr
    end
    @assert @capture(methodexpr, f_(args__)::T_ = body_)
    :($f(self::$(interface_argtype), $(args...)) where {$(parse_type_params(typeexpr)...)} = self.$f($(args...)))
end

macro interface(name, capture, block)
    method_args = [arg for arg in block.args if arg.head == :(=)]
    wrapper_fields = parse_wrapper_field.(method_args)
    quote
        @computed struct $(esc(name)) <: AbstractInterface
            $(wrapper_fields...)
                    
            $(esc(parse_constructor(name, capture))) = new($(esc.(parse_closure.(method_args))...))
        end
                
        $(esc.(outer_method.(name, method_args))...)
    end
end

end
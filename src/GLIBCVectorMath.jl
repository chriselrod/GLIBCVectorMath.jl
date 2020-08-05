module GLIBCVectorMath

using SIMDPirates

const F32 = Union{Float32,SVec{<:Any,Float32}}
const F64 = Union{Float64,SVec{<:Any,Float64}}

include("exp.jl")
# include("log.jl")

end

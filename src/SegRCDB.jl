module SegRCDB

using Random: AbstractRNG, Xoshiro
using TOML: TOML

using Distributions
using ColorTypes: Gray, RGB
using FixedPointNumbers: N0f8
using StaticArrays: @SVector
using ToStruct: ToStruct

include("util.jl")
include("config.jl")
export SegRCDBRuntimeConfig,
    SegRCDBParameterSearchConfig, SegRCDBDatasetConfig, SegRCDBInstanceParams

include("pnoise1.jl")

end

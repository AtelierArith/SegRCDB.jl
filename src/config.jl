Base.@kwdef struct SegRCDBRuntimeConfig
    save_root::String = "SegRCDB-dataset"
    numof_images::Int = 20000
    numof_classes::Int = (typemax(UInt8) - 1)
end

# Based on `make_SegRCDB.sh` not `SegRCDB_params.py`
Base.@kwdef struct SegRCDBParameterSearchConfig
    seed::Int = 0
    vertex_num::Int = 500
    line_width::Float64 = 0.1
    perlin_min::Int = 0
    perlin_max::Int = 4
    radius_min::Int = 0
    radius_max::Int = 50
    line_num_min::Int = 1
    line_num_max::Int = 50
    oval_rate::Int = 2
end

Base.@kwdef struct SegRCDBDatasetConfig
    seed::Int = 12345
    image_size::Int = 512
    start_pos::Int = 512
    instance_num::Int = 32
    mode::String = "M1"
end

struct SegRCDBInstanceParams
    Category_num::Int
    Vertex::Int
    Perlin_noise::Float64
    line_width::Float64
    Center_rad::Int64
    Line_num::Int
    Oval_rate_x::Float64
    Oval_rate_y::Float64
    Color_Gray::Int
end

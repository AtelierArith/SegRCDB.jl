using TOML
using Distributions: Exponential
using Printf: @sprintf
using Random
using ProgressMeter

using SegRCDB
using SegRCDB: uniform

function main()
    runtime_config = SegRCDBRuntimeConfig()
    parameter_search_config = SegRCDBParameterSearchConfig()

    # unpacking parameters
    (;
        seed,
        line_num_min, line_num_max, perlin_min, perlin_max,
        radius_min, radius_max,
        oval_rate,
    ) = parameter_search_config
    (; save_root, numof_classes) = runtime_config
    numof_classes ≤ typemax(UInt8) - 1 || error("$numof_classes must satisfy ≤ 254")

    rng = Xoshiro(seed)
    gray = 0
    vertex_number = 3
    param_dir_root = joinpath(save_root, "param")
    θ = parameter_search_config.vertex_num / 5
    d = Exponential(θ)
    @showprogress for c in 1:numof_classes
        mkpath(param_dir_root)
        # perameter search
        while true
            vertex_number = floor(Int, rand(rng, d))
            2 < vertex_number ≤ parameter_search_config.vertex_num && break
        end
        line_draw_num = rand(rng, line_num_min:line_num_max)
        perlin_noise_coefficient = uniform(rng, perlin_min, perlin_max)
        line_width = uniform(rng, 0.0, parameter_search_config.line_width)
        start_rad = rand(rng, radius_min:radius_max)
        oval_rate_x = uniform(rng, 1, oval_rate)
        oval_rate_y = uniform(rng, 1, oval_rate)
        gray += 1

        param = Dict(
            "Category_num" => c,
            "Vertex" => vertex_number,
            "Perlin_noise" => perlin_noise_coefficient,
            "line_width" => line_width, # when in Rome, do as the Romans do.
            "Center_rad" => start_rad,
            "Line_num" => line_draw_num,
            "Oval_rate_x" => oval_rate_x,
            "Oval_rate_y" => oval_rate_y,
            "Color_Gray" => gray,
        )
        fname = joinpath(param_dir_root, "$(@sprintf "%05d" c).toml")
        open(fname, "w") do io
            TOML.print(io, param)
        end
    end
end

main()

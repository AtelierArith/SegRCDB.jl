using Printf: @sprintf
using Random: Xoshiro
using TOML

using ColorTypes: RGB, Gray
using FixedPointNumbers: N0f8
using FileIO: save
using ImageDraw: Point, LineSegment
using ImageDraw: draw!
using ProgressMeter: Progress, next!, finish!
using ToStruct: ToStruct

using SegRCDB
using SegRCDB: uniform, pnoise1

function main()
    runtime_config = SegRCDBRuntimeConfig()
    (; save_root, numof_images, numof_classes) = runtime_config

    dataset_config = SegRCDBDatasetConfig()
    (; seed, image_size, image_size, start_pos, instance_num, mode) =
        dataset_config
    dir4image = joinpath(save_root, "image")
    dir4mask = joinpath(save_root, "mask")
    mkpath(dir4image)
    mkpath(dir4mask)
    param_dir_root = joinpath(save_root, "param")

    p = Progress(numof_images, "Generating...")
    Base.Threads.@threads for image_id in 1:numof_images
        rng = Xoshiro(image_id)
        canvas = zeros(RGB{N0f8}, image_size, image_size)
        mask = zeros(Gray{N0f8}, image_size, image_size)

        for _ in 1:instance_num
            c = rand(rng, 1:numof_classes)
            fname = joinpath(param_dir_root, "$(@sprintf "%05d" c).toml")
            d = TOML.parsefile(fname)
            params = ToStruct.tostruct(SegRCDBInstanceParams, d)
            #class_num = int(l[0][1])
            class_num = params.Category_num
            #vertex_number = int(l[1][1])
            vertex_number = params.Vertex
            #perlin_noise_coefficient = float(l[2][1])
            perlin_noise_coefficient = params.Perlin_noise
            #line_width = float(l[3][1])
            line_width = params.line_width
            #start_rad = float(l[4][1])
            start_rad = params.Center_rad
            #line_draw_num = int(l[5][1])
            line_draw_num = params.Line_num
            #oval_rate_x = float(l[6][1])
            oval_rate_x = params.Oval_rate_x
            #oval_rate_y = float(l[7][1])
            oval_rate_y = params.Oval_rate_y
            #g = int(l[8][1])
            g = params.Color_Gray
            class_color = Gray{N0f8}(reinterpret(N0f8, UInt8(g)))

            start_pos_h = (image_size + rand(rng, -1*start_pos:start_pos)) / 2
            start_pos_w = (image_size + rand(rng, -1*start_pos:start_pos)) / 2
            θs = [i * 2π / vertex_number for i in 0:vertex_number]

            vertex_x = Vector{Float64}(undef, vertex_number + 1)
            vertex_y = Vector{Float64}(undef, vertex_number + 1)
            for i in eachindex(θs, vertex_x, vertex_y)
                s, c = sincos(θs[i])
                vertex_x[i] = (c * start_rad * oval_rate_x + start_pos_w)
                vertex_y[i] = (s * start_rad * oval_rate_y + start_pos_h)
            end

            noise_x = Vector{Float64}(undef, vertex_number + 1)
            noise_y = Vector{Float64}(undef, vertex_number + 1)
            for line_draw in 1:line_draw_num
                for i in eachindex(noise_x, noise_y)
                    xu = uniform(rng, 0, 10000)
                    nx =
                        pnoise1(xu) * perlin_noise_coefficient * 2 -
                        perlin_noise_coefficient
                    noise_x[i] = nx

                    yu = uniform(rng, 0, 10000)
                    ny =
                        pnoise1(yu) * perlin_noise_coefficient * 2 -
                        perlin_noise_coefficient
                    noise_y[i] = ny
                end

                for i in eachindex(θs, vertex_x, vertex_y, noise_x, noise_y)
                    # Dear all
                    # WHAT IS `line_width` ??? I HAVE NO IDEA
                    s, c = sincos(θs[i])
                    vertex_x[i] -= c * (noise_x[i] - line_width)
                    vertex_y[i] -= s * (noise_y[i] - line_width)
                end
                # considering boundary condition
                vertex_x[end] = vertex_x[begin]
                vertex_y[end] = vertex_y[begin]

                if mode == "M1"
                    for i in 1:vertex_number
                        p1 = Point(floor(Int, vertex_x[i]), floor(Int, vertex_y[i]))
                        p2 = Point(floor(Int, vertex_x[i+1]), floor(Int, vertex_y[i+1]))
                        draw!(mask, LineSegment(p1, p2), class_color)
                    end
                end

                object_gray = reinterpret(N0f8, rand(rng, UInt8))
                object_color = RGB{N0f8}(object_gray, object_gray, object_gray)
                for i in 1:vertex_number
                    p1 = Point(floor(Int, vertex_x[i]), floor(Int, vertex_y[i]))
                    p2 = Point(floor(Int, vertex_x[i+1]), floor(Int, vertex_y[i+1]))
                    draw!(
                        canvas,
                        LineSegment(p1, p2),
                        object_color,
                    )
                end
            end
        end
        imagename = @sprintf "%06d.png" image_id
        save(
            joinpath(dir4image, imagename),
            canvas,
        )

        maskname = @sprintf "%06d.png" image_id
        save(
            joinpath(dir4mask, maskname),
            mask,
        )
        # update progressmeter
        next!(p)
    end
    finish!(p)
end

main()

using Test

using PythonCall
using CondaPkg
using StableRNGs

using Aqua: Aqua
using JET: JET

CondaPkg.add_pip("noise")

const pynoise = pyimport("noise")

using SegRCDB
using SegRCDB: pnoise1

@testset "Aqua" begin
    Aqua.test_all(SegRCDB; deps_compat = false, stale_deps=false)
end

@testset "JET" begin
    if VERSION ≥ v"1.10"
        JET.test_package(SegRCDB; target_defined_modules=true)
    end
end

@testset "pnoise1" begin
    pynoise = pyimport("noise")
    rng = StableRNG(123)
    xs = [SegRCDB.uniform(rng, 0, 10000) for _ in 1:100]
    @test SegRCDB.pnoise1.(xs) == pyconvert.(Number, pynoise.pnoise1.(xs))
end

@testset "SegRCDBRuntimeConfig" begin
    config = SegRCDBRuntimeConfig()
    @test config.save_root == "SegRCDB-dataset"
    @test config.numof_images == 20000
    @test config.numof_classes == 254
end

@testset "SegRCDBParameterSearchConfig" begin
    config = SegRCDBParameterSearchConfig()
    @test config.seed == 0
    @test config.vertex_num == 500
    @test config.line_width == 0.1
    @test config.perlin_min == 0
    @test config.perlin_max == 4
    @test config.radius_min == 0
    @test config.radius_max == 50
    @test config.line_num_min == 1
    @test config.line_num_max == 50
    @test config.oval_rate == 2
end

@testset "SegRCDBDatasetConfig" begin
    config = SegRCDBDatasetConfig()
    @test config.seed == 12345
    @test config.image_size == 512
    @test config.start_pos == 512
    @test config.instance_num == 32
    @test config.mode == "M1"
end

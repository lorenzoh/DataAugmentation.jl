include("./imports.jl")


@testset ExtendedTestSet "DataAugmentation.jl" begin
    @testset ExtendedTestSet "base.jl" begin
        include("base.jl")
    end
    @testset ExtendedTestSet "testing.jl" begin
        include("testing.jl")
    end
    @testset ExtendedTestSet "buffered.jl" begin
        include("buffered.jl")
    end
    @testset ExtendedTestSet "projective/base.jl" begin
        include("projective/base.jl")
    end
    @testset ExtendedTestSet "projective/compose.jl" begin
        include("projective/compose.jl")
    end
    @testset ExtendedTestSet "projective/crop.jl" begin
        include("projective/crop.jl")
    end
    @testset ExtendedTestSet "projective/affine.jl" begin
        include("projective/affine.jl")
    end
    @testset ExtendedTestSet "projective/warp.jl" begin
        include("projective/warp.jl")
    end
    @testset ExtendedTestSet "items/image.jl" begin
        include("items/image.jl")
    end
    @testset ExtendedTestSet "items/keypoints.jl" begin
        include("items/keypoints.jl")
    end
    @testset ExtendedTestSet "items/mask.jl" begin
        include("items/mask.jl")
    end
    @testset ExtendedTestSet "preprocessing.jl" begin
        include("preprocessing.jl")
    end
    @testset ExtendedTestSet "oneof.jl" begin
        include("oneof.jl")
    end
    @testset ExtendedTestSet "visualization.jl" begin
        include("visualization.jl")
    end
    @testset ExtendedTestSet "rowtransforms.jl" begin
        include("rowtransforms.jl")
    end
end

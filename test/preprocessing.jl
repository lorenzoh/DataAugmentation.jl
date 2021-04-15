include("./imports.jl")



@testset ExtendedTestSet "Normalize" begin
    @testset ExtendedTestSet "normalize" begin
        image = rand(Float32, 10, 10, 3)
        means = SVector{3}(rand(Float32, 1, 1, 3))
        stds = SVector{3}(rand(Float32, 1, 1, 3))
        @test denormalize(normalize(copy(image), means, stds), means, stds) ≈ image
    end

    @testset ExtendedTestSet "Normalize" begin
        item = ArrayItem(zeros(10, 10, 3))
        means =  SVector{3}(ones(1, 1, 3))
        stds =  SVector{3}(ones(1, 1, 3))
        tfm = Normalize(means, stds)
        @test itemdata(apply(tfm, item)) ≈ -1 .* ones(10, 10, 3)
    end
end

@testset ExtendedTestSet "NormalizeIntensity" begin
    @testset ExtendedTestSet "NormalizeIntensity" begin
        item = ArrayItem(Float32.(collect(1:5)))
        ground_truth = [-1.2649, -0.6325, 0, 0.6325, 1.2649]
        tfm = NormalizeIntensity()
        @test itemdata(apply(tfm, item)) ≈ ground_truth
    end

    @testset ExtendedTestSet "NormalizeIntensity" begin
    item = Image(Float32.(collect(1:5)))
    ground_truth = [-1.2649, -0.6325, 0, 0.6325, 1.2649]
    tfm = NormalizeIntensity()
    @test itemdata(apply(tfm, item)) ≈ ground_truth
    end
end

@testset ExtendedTestSet "AddChannel" begin
    @testset ExtendedTestSet "AddChannel" begin
    item = Image(rand(Float32, 20, 20, 20, 2))
    tfm = AddChannel()
    @test size(itemdata(apply(tfm, item))) == (20, 20, 20, 2, 1)
    end

    @testset ExtendedTestSet "AddChannel" begin
    item = Image(rand(Float32, 20, 2))
    tfm = AddChannel()
    @test size(itemdata(apply(tfm, item))) == (20, 2, 1)
    end

    @testset ExtendedTestSet "AddChannel" begin
    item = MaskBinary(rand(Bool, 20, 2))
    tfm = AddChannel()
    @test size(itemdata(apply(tfm, item))) == (20, 2, 1)
    end
end

@testset ExtendedTestSet "ToEltype" begin
    tfm = ToEltype(RGB)
    data = rand(RGB, 10, 10)
    imagergb = Image(data)
    imagegray = Image((Gray.(data)))
    @test itemdata(apply(ToEltype(Gray), imagegray)) === itemdata(imagegray)
    @test itemdata(apply(ToEltype(Gray), imagergb)) ≈ itemdata(imagegray)
end


@testset ExtendedTestSet "ImageToTensor" begin
    @testset ExtendedTestSet "imagetotensor,tensortoimage" begin
        data = rand(RGB, 10, 10)
        @test size(imagetotensor(data)) == (10, 10, 3)
        @test data |> imagetotensor |> tensortoimage ≈ data

    end

    @testset ExtendedTestSet "ImageToTensor" begin
        image = Image(rand(RGB, 10, 10))
        tfm = ImageToTensor()
        @test_nowarn apply(tfm, image)
        a = itemdata(apply(tfm, image))
        @test size(a) == (10, 10, 3)
    end
end

@testset ExtendedTestSet "OneHot" begin
    tfm = OneHot()
    mask = rand(1:4, 10, 10)
    item = MaskMulti(mask, 1:4)
    @test_nowarn apply(tfm, item)
    aitem = apply(tfm, item)
    @test size(itemdata(aitem)) == (10, 10, 4)

    item2 = MaskMulti(rand(1:3, 10, 10), 1:4)
    buf = itemdata(aitem)
    bufcopy = copy(buf)
    apply!(aitem, tfm, item2)
    @test itemdata(item) == itemdata(item2) || itemdata(aitem) != bufcopy

end

@testset ExtendedTestSet "Image pipeline" begin
    image = Image(rand(RGB, 150, 150))

    tfm = compose(
        ToEltype(RGB),
        RandomResizeCrop((128, 64)),
        ImageToTensor(),
        Normalize([0, 0, 0], [1, 1, 1])
    )

    @test_nowarn apply(tfm, image)

    res = apply(tfm, image)
    a = itemdata(res)
    @test size(a) == (128, 64, 3)
    @test eltype(a) == Float32
end

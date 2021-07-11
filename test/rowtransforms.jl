include("imports.jl")

@testset ExtendedTestSet "`NormalizeRow`" begin
    cols = [:col1, :col2, :col3]
    item = TabularItem((; zip(cols, [1, "a", 10])...), cols)
    cols_to_normalize = [:col1, :col3]
    col1_mean, col1_std = 10, 100
    col3_mean, col3_std = 100, 10
    normdict = Dict(:col1 => (col1_mean, col1_std), :col3 => (col3_mean, col3_std))

    tfm = NormalizeRow(normdict, cols_to_normalize)
    # @test_nowarn apply(tfm, item)
    testapply(tfm, item)
    titem = apply(tfm, item)
    @test titem.data[:col1] == (item.data[:col1] - col1_mean)/col1_std
    @test titem.data[:col3] == (item.data[:col3] - col3_mean)/col3_std
end

@testset ExtendedTestSet "`FillMissing`" begin
    cols = [:col1, :col2, :col3]
    item = TabularItem((; zip(cols, [1, missing, missing])...), cols)
    cols_to_fill = [:col1, :col3]
    col1_fmval = 1000.
    col3_fmval = 1000.
    fmdict = Dict()
    fmdict[:col1], fmdict[:col3] = col1_fmval, col3_fmval

    tfm1 = FillMissing(fmdict, cols_to_fill)
    @test_nowarn apply(tfm, item)
    titem = apply(tfm, item)
    @test titem.data[:col1] == (ismissing(item.data[:col1]) ? col1_fmval : item.data[:col1])
    @test titem.data[:col3] == (ismissing(item.data[:col3]) ? col3_fmval : item.data[:col3])
    @test ismissing(titem.data[:col2])

    fmdict[:col2] = "d"
    tfm2 = FillMissing(fmdict, [:col1, :col2, :col3])
    testapply(tfm2, item)
    titem2 = apply(tfm2, item)
    @test titem2.data[:col2] == (ismissing(item.data[:col2]) ? "d" : item.data[:col2])
end

@testset ExtendedTestSet "`Categorify`" begin
    cols = [:col1, :col2, :col3, :col4]
    item = TabularItem((; zip(cols, [1, "a", "A", missing])...), cols)
    cols_to_categorify = [:col2, :col3, :col4]
    
    categorydict = Dict(:col2 => ["a", "b", "c"], :col3 => ["C", "B", "A"], :col4 => [missing, 10, 20])
    tfm = Categorify(categorydict, cols_to_categorify)
    @test !any(ismissing.(tfm.dict[:col4]))
    @test_nowarn apply(tfm, item)
    testapply(tfm, item)
    titem = apply(tfm, item)
    @test titem.data[:col2] == 2
    @test titem.data[:col3] == 4
    @test titem.data[:col4] == 1
end
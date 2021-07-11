module DataAugmentation

using ColorBlendModes
using CoordinateTransformations
using Distributions: Sampleable, Uniform, Categorical
using IndirectArrays: IndirectArray
using ImageDraw
using Images
using Images: Colorant, permuteddimsview
using ImageTransformations
using ImageTransformations: center, _center, box_extrapolation, warp!
using Interpolations
using MosaicViews: mosaicview
using OffsetArrays: OffsetArray
using LinearAlgebra: I
using Parameters
using Random
using Rotations
using Setfield
using StaticArrays
using Statistics
using Test: @test, @test_nowarn


include("./base.jl")
include("./wrapper.jl")
include("./buffered.jl")
include("./sequence.jl")
include("./items/arrayitem.jl")
include("./projective/base.jl")
include("./items/image.jl")
include("./items/table.jl")
include("./items/keypoints.jl")
include("./items/mask.jl")
include("./projective/compose.jl")
include("./projective/crop.jl")
include("./projective/affine.jl")
include("./projective/warp.jl")
include("./oneof.jl")
include("./preprocessing.jl")
include("./rowtransforms.jl")
include("./colortransforms.jl")
include("testing.jl")
include("./visualization.jl")


export Item,
    Transform,
    ArrayItem,
    MapElem,
    Identity,
    Sequence,
    Project,
    Image,
    TabularItem,
    Keypoints,
    Polygon,
    ToEltype,
    ImageToTensor,
    Normalize,
    NormalizeIntensity,
    MaskMulti,
    MaskBinary,
    BoundingBox,
    ScaleKeepAspect,
    ScaleRatio,
    itemdata,
    Crop,
    CenterCrop,
    RandomCrop,
    ScaleFixed,
    Rotate,
    RandomResizeCrop,
    CenterResizeCrop,
    Buffered,
    BufferedThreadsafe,
    OneHot,
    Zoom,
    OneOf,
    Maybe,
    apply,
    Reflect,
    WarpAffine,
    FlipX,
    FlipY,
    PinOrigin,
    AdjustBrightness,
    AdjustContrast,
    apply!,
    PadDivisible,
    ResizePadDivisible,
    onehot,
    showitems,
    showgrid,
    Bounds,
    getcategorypools


end # module

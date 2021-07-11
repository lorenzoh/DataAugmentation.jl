using DataAugmentation
using Images
using StaticArrays
using Test
using TestSetExtensions
using CoordinateTransformations


using DataAugmentation: Item, Transform, getrandstate, itemdata, setdata, ComposedProjectiveTransform,
    projectionbounds, getprojection, offsetcropbounds,
    CroppedProjectiveTransform, getbounds, project, project!, makebuffer, imagetotensor, imagetotensor!,
    normalize, normalize!, tensortoimage, denormalize, denormalize!,
    NormalizeRow, FillMissing, Categorify, TabularItem
using DataAugmentation: testitem, testapply, testapply!, testprojective
import DataAugmentation: apply, compose

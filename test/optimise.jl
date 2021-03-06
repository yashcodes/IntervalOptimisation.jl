﻿using IntervalArithmetic, IntervalOptimisation
using Test

@testset "IntervalOptimisation tests" begin

    @testset "Minimise in 1D using default data structure i.e HeapedVector" begin
        global_min, minimisers = minimise(x->x, -10..10)
        @test global_min ⊆ -10 .. -9.999
        @test length(minimisers) == 1
        @test minimisers[1] ⊆ -10 .. -9.999

        global_min, minimisers = minimise(x->x^2, -10..11, tol = 1e-10)
        @test global_min ⊆ 0..1e-20
        @test length(minimisers) == 1
        @test minimisers[1] ⊆ -0.1..0.1

        global_min, minimisers = minimise(x->(x^2-2)^2, -10..11)
        @test global_min ⊆ 0..1e-7
        @test length(minimisers) == 2
        @test sqrt(2) ∈ minimisers[2]
    end

    for Structure in (SortedVector, HeapedVector)

        @testset "Minimise in 1D using SoretedVector" begin
            global_min, minimisers = minimise(x->x, -10..10, structure = Structure)
            @test global_min ⊆ -10 .. -9.999
            @test length(minimisers) == 1
            @test minimisers[1] ⊆ -10 .. -9.999

            global_min, minimisers = minimise(x->x^2, -10..11, tol=1e-10, structure = Structure)
            @test global_min ⊆ 0..1e-20
            @test length(minimisers) == 1
            @test minimisers[1] ⊆ -0.1..0.1

            global_min, minimisers = minimise(x->(x^2-2)^2, -10..11, structure = Structure)
            @test global_min ⊆ 0..1e-7
            @test length(minimisers) == 2
            @test sqrt(2) ∈ max(minimisers[1], minimisers[2])
        end


        @testset "Discontinuous function in 1D" begin

            H(x) = (sign(x) + 1) / 2   # Heaviside function except at 0, where H(0) = 0.5
            global_min, minimisers = minimise(x -> abs(x) + H(x) - 1, -10..11, tol=1e-5, structure = Structure)
            @test global_min ⊆ -1 .. -0.9999
            @test length(minimisers) == 1
            @test 0 ∈ minimisers[1]
            @test diam(minimisers[1]) <= 1e-5
        end


        @testset "Smooth function in 2D" begin
            global_min, minimisers = minimise( X -> ( (x,y) = X; x^2 + y^2 ), (-10..10) × (-10..10), structure = Structure )
            @test global_min ⊆ 0..1e-7
            @test all(X ⊆ (-1e-3..1e3) × (-1e-3..1e-3) for X in minimisers)
        end

    end

end
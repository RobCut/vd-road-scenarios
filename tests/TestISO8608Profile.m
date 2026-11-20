classdef TestISO8608Profile < matlab.unittest.TestCase
    %TestISO8608Profile Tests for the ISO 8608 profile generator.

    methods (Test)
        function test_profile_length(testCase)
            %test_profile_length Verify that the profile has the
            %   expected number of samples.
            L = 100;
            dx = 0.05;
            p = roadprofile.iso8608Profile('A', L, dx);
            N = round(L / dx);
            testCase.verifyEqual(numel(p.x), N);
            testCase.verifyEqual(numel(p.z), N);
            testCase.verifyEqual(p.dx, dx, 'AbsTol', 1e-12);
        end

        function test_profile_seed_deterministic(testCase)
            %test_profile_seed_deterministic Verify that two calls with
            %   the same seed produce identical output.
            L = 100;
            dx = 0.05;
            p1 = roadprofile.iso8608Profile('B', L, dx, Seed=42);
            p2 = roadprofile.iso8608Profile('B', L, dx, Seed=42);
            testCase.verifyEqual(p1.z, p2.z, 'AbsTol', 1e-12);
        end

        function test_profile_different_seed(testCase)
            %test_profile_different_seed Verify that different seeds
            %   produce different output.
            L = 100;
            dx = 0.05;
            p1 = roadprofile.iso8608Profile('B', L, dx, Seed=42);
            p2 = roadprofile.iso8608Profile('B', L, dx, Seed=43);
            testCase.verifyNotEqual(p1.z, p2.z);
        end

        function test_profile_zero_mean(testCase)
            %test_profile_zero_mean Verify that the generated profile
            %   has zero mean.
            L = 100;
            dx = 0.05;
            p = roadprofile.iso8608Profile('C', L, dx, Seed=1);
            testCase.verifyEqual(mean(p.z), 0, 'AbsTol', 1e-10);
        end

        function test_profile_roughness_increases_with_class(testCase)
            %test_profile_roughness_increases_with_class Verify that
            %   variance increases monotonically from class A to class C.
            L = 1000;
            dx = 0.01;
            vA = var(roadprofile.iso8608Profile('A', L, dx, Seed=1).z);
            vB = var(roadprofile.iso8608Profile('B', L, dx, Seed=1).z);
            vC = var(roadprofile.iso8608Profile('C', L, dx, Seed=1).z);
            testCase.verifyGreaterThan(vB, vA);
            testCase.verifyGreaterThan(vC, vB);
        end
    end
end
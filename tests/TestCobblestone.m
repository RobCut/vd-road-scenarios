classdef TestCobblestone < matlab.unittest.TestCase
    %TestCobblestone Tests for the cobblestone pattern.

    methods (Test)
        function test_cobble_length(testCase)
            %test_cobble_length Verify the sample count.
            p = roadprofile.cobblestone(10, 0.005, 0.02, 0.1);
            testCase.verifyEqual(numel(p.x), round(10/0.005));
        end

        function test_cobble_seed_deterministic(testCase)
            %test_cobble_seed_deterministic Verify that the same seed
            %   produces identical output.
            p1 = roadprofile.cobblestone(10, 0.005, 0.02, 0.1, Seed=42);
            p2 = roadprofile.cobblestone(10, 0.005, 0.02, 0.1, Seed=42);
            testCase.verifyEqual(p1.z, p2.z, 'AbsTol', 1e-12);
        end

        function test_cobble_dominant_frequency(testCase)
            %test_cobble_dominant_frequency Verify that the spectrum
            %   has its peak near 1/wavelength.
            lambda = 0.1; L = 10; dx = 0.002;
            p = roadprofile.cobblestone(L, dx, 0.02, lambda, Seed=1);
            N = numel(p.z);
            Z = abs(fft(p.z));
            f = (0:N-1)' / (N * dx);
            [~, idx] = max(Z(2:floor(N/2)));
            testCase.verifyEqual(f(idx+1), 1/lambda, 'RelTol', 0.15);
        end

        function test_cobble_zero_mean(testCase)
            %test_cobble_zero_mean Verify that the profile is mean-zero.
            p = roadprofile.cobblestone(10, 0.005, 0.02, 0.1, Seed=1);
            testCase.verifyEqual(mean(p.z), 0, 'AbsTol', 1e-10);
        end

        function test_rms_height(testCase)
            %test_rms_height Verify that the RMS height equals the requested value.
            p = roadprofile.cobblestone(10, 0.005, 0.02, 0.1, Seed=1);
            testCase.verifyEqual(sqrt(mean(p.z.^2)), 0.02, 'RelTol', 1e-12);
        end
    end
end
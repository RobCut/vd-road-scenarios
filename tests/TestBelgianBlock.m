classdef TestBelgianBlock < matlab.unittest.TestCase
    %TestBelgianBlock Tests for the belgian block pattern.

    methods (Test)
        function test_belgian_length(testCase)
            %test_belgian_length Verify the sample count.
            p = roadprofile.belgianBlock(10, 0.005, 0.03, 0.2);
            testCase.verifyEqual(numel(p.x), round(10/0.005));
        end

        function test_belgian_seed_deterministic(testCase)
            %test_belgian_seed_deterministic Verify that the same seed
            %   produces identical output.
            p1 = roadprofile.belgianBlock(10, 0.005, 0.03, 0.2, Seed=42);
            p2 = roadprofile.belgianBlock(10, 0.005, 0.03, 0.2, Seed=42);
            testCase.verifyEqual(p1.z, p2.z, 'AbsTol', 1e-12);
        end

        function test_belgian_different_seed(testCase)
            %test_belgian_different_seed Verify that different seeds
            %   produce different output.
            p1 = roadprofile.belgianBlock(10, 0.005, 0.03, 0.2, Seed=42);
            p2 = roadprofile.belgianBlock(10, 0.005, 0.03, 0.2, Seed=43);
            testCase.verifyNotEqual(p1.z, p2.z);
        end

        function test_belgian_dominant_frequency(testCase)
            %test_belgian_dominant_frequency Verify that the spectrum
            %   has its peak near 1/wavelength.
            lambda = 0.2; L = 10; dx = 0.005;
            p = roadprofile.belgianBlock(L, dx, 0.03, lambda, Seed=1);
            N = numel(p.z);
            Z = abs(fft(p.z));
            f = (0:N-1)' / (N * dx);
            [~, idx] = max(Z(2:floor(N/2)));
            testCase.verifyEqual(f(idx+1), 1/lambda, 'RelTol', 0.15);
        end

        function test_belgian_zero_mean(testCase)
            %test_belgian_zero_mean Verify that the profile is mean-zero.
            p = roadprofile.belgianBlock(10, 0.005, 0.03, 0.2, Seed=1);
            testCase.verifyEqual(mean(p.z), 0, 'AbsTol', 1e-10);
        end

        function test_belgian_nyquist_violation(testCase)
            %test_belgian_nyquist_violation Verify that a wavelength
            %   below 2*dx raises roadprofile:invalidFrequency.
            testCase.verifyError( ...
                @() roadprofile.belgianBlock(10, 0.05, 0.03, 0.05), ...
                'roadprofile:invalidFrequency');
        end
    end
end
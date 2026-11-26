classdef TestISO8608Profile < matlab.unittest.TestCase
    %TestISO8608Profile Tests for the ISO 8608 profile generator.

    methods (Test)
        function test_profile_length(testCase)
            %test_profile_length Verify that the profile has the
            %   expected number of samples.
            L = 100;
            dx = 0.05;
            p = roadprofile.iso8608Profile(L, dx, 'A');
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
            p1 = roadprofile.iso8608Profile(L, dx, 'B', Seed=42);
            p2 = roadprofile.iso8608Profile(L, dx, 'B', Seed=42);
            testCase.verifyEqual(p1.z, p2.z, 'AbsTol', 1e-12);
        end

        function test_profile_different_seed(testCase)
            %test_profile_different_seed Verify that different seeds
            %   produce different output.
            L = 100;
            dx = 0.05;
            p1 = roadprofile.iso8608Profile(L, dx, 'B', Seed=42);
            p2 = roadprofile.iso8608Profile(L, dx, 'B', Seed=43);
            testCase.verifyNotEqual(p1.z, p2.z);
        end

        function test_profile_zero_mean(testCase)
            %test_profile_zero_mean Verify that the generated profile
            %   has zero mean.
            L = 100;
            dx = 0.05;
            p = roadprofile.iso8608Profile(L, dx, 'C', Seed=1);
            testCase.verifyEqual(mean(p.z), 0, 'AbsTol', 1e-10);
        end

        function test_profile_roughness_increases_with_class(testCase)
            %test_profile_roughness_increases_with_class Verify that
            %   variance increases monotonically from class A to class C.
            L = 1000;
            dx = 0.01;
            vA = var(roadprofile.iso8608Profile(L, dx, 'A', Seed=1).z);
            vB = var(roadprofile.iso8608Profile(L, dx, 'B', Seed=1).z);
            vC = var(roadprofile.iso8608Profile(L, dx, 'C', Seed=1).z);
            testCase.verifyGreaterThan(vB, vA);
            testCase.verifyGreaterThan(vC, vB);
        end

        function test_profile_spectrum_matches_psd(testCase)
            %test_profile_spectrum_matches_psd Verify |X(k)|^2 = G(n_k)*dn/2
            %   inside the default band and zero outside.
            testCase.checkSpectrum(100, 0.05);
        end

        function test_profile_variance(testCase)
            %test_profile_variance Verify that the sample variance equals
            %   sum(G(k) * dn) over the default band (exact by Parseval).
            L = 1000;
            dx = 0.01;
            p = roadprofile.iso8608Profile(L, dx, 'B', Seed=1);
            N = numel(p.z);
            Leff = N * dx;
            k = (1:floor(N/2)-1)';
            n = k / Leff;
            n = n(n >= 0.011 & n <= 2.83);
            G_theory = roadprofile.iso8608PSD('B', n);
            var_theory = sum(G_theory) / Leff * N / (N - 1);
            testCase.verifyEqual(var(p.z), var_theory, 'RelTol', 1e-10);
        end

        function test_profile_class_ratio(testCase)
            %test_profile_class_ratio Verify that with the same seed,
            %   class B is exactly 2x class A, and class C is exactly 2x B.
            L = 100;
            dx = 0.05;
            classes = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'};
            prev = roadprofile.iso8608Profile(L, dx, 'A', Seed=1);
            for i = 2:numel(classes)
                curr = roadprofile.iso8608Profile(L, dx, classes{i}, Seed=1);
                testCase.verifyEqual(curr.z, 2 * prev.z, 'RelTol', 1e-10);
                prev = curr;
            end
        end

        function test_profile_too_short(testCase)
            %test_profile_too_short Verify that a profile shorter than 4
            %   samples raises roadprofile:invalidLength.
            testCase.verifyError( ...
                @() roadprofile.iso8608Profile(0.1, 0.05, 'A'), ...
                'roadprofile:invalidLength');
        end

        function test_profile_invalid_class(testCase)
            %test_profile_invalid_class Verify that an unknown class
            %   raises roadprofile:invalidClass.
            testCase.verifyError( ...
                @() roadprofile.iso8608Profile(100, 0.05, 'Z'), ...
                'roadprofile:invalidClass');
        end

        function test_profile_non_integer_length(testCase)
            %test_profile_non_integer_length Same spectral check when L/dx is
            %   not an integer (Leff = N*dx).
            testCase.checkSpectrum(100, 0.03);
        end

        function test_profile_length_inf(testCase)
            %test_profile_length_inf Verify that infinite L is rejected
            %   (mustBePositive alone accepts Inf).
            testCase.verifyError( ...
                @() roadprofile.iso8608Profile(Inf, 0.05, 'B'), ...
                'MATLAB:validators:mustBeFinite');
        end

        function test_profile_seed_string(testCase)
            %test_profile_seed_string Verify that a non-numeric seed
            %   is rejected before rng is called.
            testCase.verifyError( ...
                @() roadprofile.iso8608Profile(100, 0.05, 'B', Seed="abc"), ...
                'MATLAB:validators:mustBeNumeric');
        end

        function test_profile_seed_negative(testCase)
            %test_profile_seed_negative Verify that a negative seed is
            %   rejected.
            testCase.verifyError( ...
                @() roadprofile.iso8608Profile(100, 0.05, 'B', Seed=-1), ...
                'MATLAB:validators:mustBeNonnegative');
        end

        function test_profile_seed_vector(testCase)
            %test_profile_seed_vector Verify that a vector seed is
            %   rejected before rng is called.
            testCase.verifyError( ...
                @() roadprofile.iso8608Profile(100, 0.05, 'B', Seed=[1 2]), ...
                'MATLAB:validators:mustBeScalarOrEmpty');
        end

        function test_profile_seed_non_integer(testCase)
            %test_profile_seed_non_integer Verify that a non-integer seed
            %   is rejected.
            testCase.verifyError( ...
                @() roadprofile.iso8608Profile(100, 0.05, 'B', Seed=1.5), ...
                'MATLAB:validators:mustBeInteger');
        end

        function test_profile_empty_band(testCase)
            %test_profile_empty_band Verify that a band with no spectral line
            %   raises roadprofile:emptyBand.
            testCase.verifyError( ...
                @() roadprofile.iso8608Profile(100, 0.05, 'B', NMin=20, NMax=30), ...
                'roadprofile:emptyBand');
        end
    end

    methods
        function checkSpectrum(testCase, L, dx)
            %checkSpectrum Compare the periodogram of a class B profile with
            %   the PSD in the default band.
            p = roadprofile.iso8608Profile(L, dx, 'B', Seed=42);
            N = numel(p.z);  Leff = N*dx;
            k = (1:floor(N/2)-1)';  n = k/Leff;
            P = abs(fft(p.z)/N).^2;  P = P(k+1);
            in = n >= 0.011 & n <= 2.83;
            target = roadprofile.iso8608PSD('B', n(in))/Leff/2;
            testCase.verifyEqual(P(in), target, 'RelTol', 1e-8);
            testCase.verifyLessThan(max(P(~in)), 1e-20);
        end
    end
end
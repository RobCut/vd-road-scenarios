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
            %test_profile_spectrum_matches_psd Verify that |X(k)|^2 equals
            %   G(n_k) * dn / 2 (Hermitian pair), where X = fft(z)/N.
            L = 100;
            dx = 0.05;
            p = roadprofile.iso8608Profile(L, dx, 'B', Seed=42);
            N = numel(p.z);
            Leff = N * dx;
            Z = fft(p.z);
            k = (1:floor(N/2)-1)';
            n = k / Leff;
            G_theory = roadprofile.iso8608PSD('B', n);
            X_amp_sq = abs(Z(k+1)).^2 / N^2;
            target = G_theory * (1/Leff) / 2;
            relErr = abs(X_amp_sq - target) ./ target;
            testCase.verifyLessThan(max(relErr), 1e-8);
        end

        function test_profile_variance(testCase)
            %test_profile_variance Verify that the sample variance equals
            %   sum(G(k) * dn) within statistical tolerance.
            L = 1000;
            dx = 0.01;
            p = roadprofile.iso8608Profile(L, dx, 'B', Seed=1);
            N = numel(p.z);
            Leff = N * dx;
            k = (1:floor(N/2)-1)';
            n = k / Leff;
            G_theory = roadprofile.iso8608PSD('B', n);
            var_theory = sum(G_theory) / Leff * N / (N - 1);
            testCase.verifyEqual(var(p.z), var_theory, 'RelTol', 1e-4);
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
            %test_profile_non_integer_length Verify that the spectrum
            %   is correct when L/dx is not an integer (Leff = N*dx).
            L = 100;
            dx = 0.03;
            p = roadprofile.iso8608Profile(L, dx, 'B', Seed=42);
            N = numel(p.z);
            Leff = N * dx;
            Z = fft(p.z);
            k = (1:floor(N/2)-1)';
            n = k / Leff;
            G_theory = roadprofile.iso8608PSD('B', n);
            X_amp_sq = abs(Z(k+1)).^2 / N^2;
            target = G_theory * (1/Leff) / 2;
            relErr = abs(X_amp_sq - target) ./ target;
            testCase.verifyLessThan(max(relErr), 1e-8);
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
    end
end
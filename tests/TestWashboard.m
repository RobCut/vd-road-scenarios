classdef TestWashboard < matlab.unittest.TestCase
    %TestWashboard Tests for the washboard pattern.

    methods (Test)
        function test_washboard_length(testCase)
            %test_washboard_length Verify the sample count.
            p = roadprofile.washboard(100, 0.01, 0.02, 0.5);
            testCase.verifyEqual(numel(p.x), round(100/0.01));
        end

        function test_washboard_amplitude(testCase)
            %test_washboard_amplitude Verify that the profile is a
            %   pure sinusoid with the requested amplitude.
            A = 0.02;
            p = roadprofile.washboard(100, 0.005, A, 0.5);
            testCase.verifyEqual(max(p.z), A, 'AbsTol', 1e-6);
            testCase.verifyEqual(min(p.z), -A, 'AbsTol', 1e-6);
        end

        function test_washboard_frequency(testCase)
            %test_washboard_frequency Verify the dominant frequency
            %   matches 1/wavelength.
            lambda = 0.5; L = 100; dx = 0.01;
            p = roadprofile.washboard(L, dx, 0.02, lambda);
            N = numel(p.z);
            Z = abs(fft(p.z));
            f = (0:N-1)' / (N * dx);
            [~, idx] = max(Z(2:floor(N/2)));
            testCase.verifyEqual(f(idx+1), 1/lambda, 'RelTol', 1e-6);
        end

        function test_washboard_nyquist_violation(testCase)
            %test_washboard_nyquist_violation Verify that a wavelength
            %   below 2*dx (frequency above Nyquist) raises
            %   roadprofile:invalidFrequency.
            testCase.verifyError( ...
                @() roadprofile.washboard(100, 0.05, 0.02, 0.05), ...
                'roadprofile:invalidFrequency');
        end

        function test_washboard_invalid_wavelength(testCase)
            %test_washboard_invalid_wavelength Verify that non-positive
            %   wavelength is rejected.
            testCase.verifyError( ...
                @() roadprofile.washboard(100, 0.05, 0.02, 0), ...
                'MATLAB:validators:mustBePositive');
        end
    end
end
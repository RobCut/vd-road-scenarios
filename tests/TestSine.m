classdef TestSine < matlab.unittest.TestCase
    %TestSine Tests for the sinusoidal profile pattern.

    methods (Test)
        function test_sine_length(testCase)
            %test_sine_length Verify the sample count.
            p = roadprofile.sine(100, 0.05, 0.2, 0.01);
            testCase.verifyEqual(numel(p.x), round(100/0.05));
            testCase.verifyEqual(p.dx, 0.05, 'AbsTol', 1e-12);
        end

        function test_sine_value_at_origin(testCase)
            %test_sine_value_at_origin Verify z(0) = A*sin(Phase).
            A = 0.01; ph = pi/4;
            p = roadprofile.sine(10, 0.01, 0.2, A, Phase=ph);
            testCase.verifyEqual(p.z(1), A * sin(ph), 'AbsTol', 1e-12);
        end

        function test_sine_amplitude(testCase)
            %test_sine_amplitude Verify peak amplitude matches A tightly.
            A = 0.02;
            p = roadprofile.sine(100, 0.005, 0.15, A);
            testCase.verifyEqual(max(p.z), A, 'AbsTol', 1e-6);
            testCase.verifyEqual(min(p.z), -A, 'AbsTol', 1e-6);
        end

        function test_sine_frequency(testCase)
            %test_sine_frequency Verify dominant frequency and amplitude.
            freq = 0.25; A = 0.01;
            p = roadprofile.sine(100, 0.01, freq, A);
            N = numel(p.z); dx = p.dx;
            Z = abs(fft(p.z));
            f = (0:N-1)' / (N * dx);
            [~, idx] = max(Z(2:floor(N/2)));
            testCase.verifyEqual(f(idx+1), freq, 'RelTol', 1e-9);
            testCase.verifyEqual(2 * Z(idx+1) / N, A, 'RelTol', 1e-9);
        end

        function test_sine_integer_periods_zero_mean(testCase)
            %test_sine_integer_periods_zero_mean Verify that an integer
            %   number of periods gives zero mean.
            p = roadprofile.sine(100, 0.01, 0.2, 0.01);
            testCase.verifyEqual(mean(p.z), 0, 'AbsTol', 1e-10);
        end

        function test_sine_non_integer_periods_nonzero_mean(testCase)
            %test_sine_non_integer_periods_nonzero_mean Verify that a
            %   non-integer number of periods does NOT force zero mean
            %   (unlike ISO 8608 profiles, sine is not mean-centered).
            p = roadprofile.sine(100, 0.01, 0.237, 0.01);
            testCase.verifyGreaterThan(abs(mean(p.z)), 1e-6);
        end

        function test_sine_nyquist_violation(testCase)
            %test_sine_nyquist_violation Verify that Frequency at or above
            %   Nyquist raises roadprofile:invalidFrequency.
            testCase.verifyError( ...
                @() roadprofile.sine(100, 0.05, 10, 0.01), ...
                'roadprofile:invalidFrequency');
            testCase.verifyError( ...
                @() roadprofile.sine(100, 0.05, 15, 0.01), ...
                'roadprofile:invalidFrequency');
        end

        function test_sine_invalid_frequency(testCase)
            %test_sine_invalid_frequency Verify that Frequency <= 0 is
            %   rejected by the arguments block.
            testCase.verifyError( ...
                @() roadprofile.sine(100, 0.05, 0, 0.01), ...
                'MATLAB:validators:mustBePositive');
            testCase.verifyError( ...
                @() roadprofile.sine(100, 0.05, -0.1, 0.01), ...
                'MATLAB:validators:mustBePositive');
        end

        function test_sine_negative_amplitude(testCase)
            %test_sine_negative_amplitude Verify that negative amplitude
            %   is rejected.
            testCase.verifyError( ...
                @() roadprofile.sine(100, 0.05, 0.2, -0.01), ...
                'MATLAB:validators:mustBeNonnegative');
        end

        function test_sine_invalid_length(testCase)
            %test_sine_invalid_length Verify that L, dx <= 0 are rejected.
            testCase.verifyError( ...
                @() roadprofile.sine(0, 0.05, 0.2, 0.01), ...
                'MATLAB:validators:mustBePositive');
            testCase.verifyError( ...
                @() roadprofile.sine(100, 0, 0.2, 0.01), ...
                'MATLAB:validators:mustBePositive');
        end

        function test_sine_too_short(testCase)
            %test_sine_too_short Verify that a profile with fewer than 2
            %   samples raises roadprofile:invalidLength.
            testCase.verifyError( ...
                @() roadprofile.sine(0.01, 0.05, 0.2, 0.01), ...
                'roadprofile:invalidLength');
        end

        function test_sine_phase_nan(testCase)
            %test_sine_phase_nan Verify that NaN Phase is rejected.
            testCase.verifyError( ...
                @() roadprofile.sine(100, 0.05, 0.2, 0.01, Phase=NaN), ...
                'MATLAB:validators:mustBeFinite');
        end

        function test_sine_phase_vector(testCase)
            %test_sine_phase_vector Verify that a non-scalar Phase is
            %   rejected.
            testCase.verifyError( ...
                @() roadprofile.sine(100, 0.05, 0.2, 0.01, Phase=[0 0]), ...
                'MATLAB:validation:IncompatibleSize');
        end

        function test_sine_length_inf(testCase)
            %test_sine_length_inf Verify that infinite L is rejected
            %   (mustBePositive alone accepts Inf).
            testCase.verifyError( ...
                @() roadprofile.sine(Inf, 0.05, 0.2, 0.01), ...
                'MATLAB:validators:mustBeFinite');
        end
    end
end
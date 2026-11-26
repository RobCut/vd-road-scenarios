classdef TestChirp < matlab.unittest.TestCase
    %TestChirp Tests for the chirp (frequency sweep) pattern.

    methods (Test)
        function test_chirp_length(testCase)
            %test_chirp_length Verify the sample count.
            p = roadprofile.chirp(100, 0.01, 0.2, 5.0, 0.01);
            testCase.verifyEqual(numel(p.x), round(100/0.01));
        end

        function test_chirp_matches_formula(testCase)
            %test_chirp_matches_formula Verify the linear sweep law sample
            %   by sample.
            L = 100; dx = 0.005; f0 = 0.5; f1 = 5; A = 0.01;
            p = roadprofile.chirp(L, dx, f0, f1, A);
            expected = A * sin(2*pi*(f0*p.x + (f1 - f0)*p.x.^2/(2*L)));
            testCase.verifyEqual(p.z, expected, 'AbsTol', 1e-12);
        end

        function test_chirp_amplitude(testCase)
            %test_chirp_amplitude Verify the peak is close to A.
            A = 0.01;
            p = roadprofile.chirp(100, 0.005, 0.2, 5.0, A);
            testCase.verifyEqual(max(abs(p.z)), A, 'RelTol', 0.05);
        end

        function test_chirp_final_frequency_nyquist(testCase)
            %test_chirp_final_frequency_nyquist Verify that f1 above
            %   Nyquist raises roadprofile:invalidFrequency.
            testCase.verifyError( ...
                @() roadprofile.chirp(100, 0.05, 0.5, 20, 0.01), ...
                'roadprofile:invalidFrequency');
        end

        function test_chirp_zero_frequency(testCase)
            %test_chirp_zero_frequency Verify that f0 <= 0 is rejected.
            testCase.verifyError( ...
                @() roadprofile.chirp(100, 0.01, 0, 5, 0.01), ...
                'MATLAB:validators:mustBePositive');
        end
    end
end
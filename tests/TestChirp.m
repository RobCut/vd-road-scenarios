classdef TestChirp < matlab.unittest.TestCase
    %TestChirp Tests for the chirp (frequency sweep) pattern.

    methods (Test)
        function test_chirp_length(testCase)
            %test_chirp_length Verify the sample count.
            p = roadprofile.chirp(100, 0.01, 0.2, 5.0, 0.01);
            testCase.verifyEqual(numel(p.x), round(100/0.01));
        end

        function test_chirp_frequency_sweep(testCase)
            %test_chirp_frequency_sweep Verify the frequency sweeps
            %   from f0 to f1 by analysing short-time windows at the
            %   start and at the end.
            L = 100; dx = 0.005; f0 = 0.5; f1 = 5.0;
            p = roadprofile.chirp(L, dx, f0, f1, 0.01);
            N = numel(p.z);
            nWin = round(2 / dx);  % ~2 m window
            % Early window
            seg = p.z(1:nWin);
            Z = abs(fft(seg));
            f = (0:nWin-1)' / (nWin * dx);
            [~, idx] = max(Z(2:floor(nWin/2)));
            testCase.verifyEqual(f(idx+1), f0, 'RelTol', 0.30);
            % Late window
            seg = p.z(end-nWin+1:end);
            Z = abs(fft(seg));
            [~, idx] = max(Z(2:floor(nWin/2)));
            testCase.verifyEqual(f(idx+1), f1, 'RelTol', 0.30);
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
classdef TestMultiSine < matlab.unittest.TestCase
    %TestMultiSine Tests for the multi-sine pattern.

    methods (Test)
        function test_multisine_length(testCase)
            %test_multisine_length Verify the sample count.
            p = roadprofile.multiSine(100, 0.01, [1, 2], [0.01, 0.005]);
            testCase.verifyEqual(numel(p.x), round(100/0.01));
        end

        function test_multisine_pure_tone(testCase)
            %test_multisine_pure_tone Verify that a single component
            %   reduces to sine.
            p = roadprofile.multiSine(100, 0.01, [1.5], [0.02]);
            pRef = roadprofile.sine(100, 0.01, 1.5, 0.02);
            testCase.verifyEqual(p.z, pRef.z, 'AbsTol', 1e-12);
        end

        function test_multisine_amplitudes_independent(testCase)
            %test_multisine_amplitudes_independent Verify that each
            %   frequency component carries its requested amplitude.
            L = 100; dx = 0.005;
            freqs = [1.0, 2.5, 4.0];
            amps  = [0.01, 0.005, 0.002];
            p = roadprofile.multiSine(L, dx, freqs, amps);
            N = numel(p.z);
            Z = 2 * abs(fft(p.z)) / N;
            fs = (0:N-1)' / (N * dx);
            for k = 1:numel(freqs)
                [~, idx] = min(abs(fs - freqs(k)));
                testCase.verifyEqual(Z(idx), amps(k), 'RelTol', 0.10);
            end
        end

        function test_multisine_mismatched_lengths(testCase)
            %test_multisine_mismatched_lengths Verify that mismatched
            %   freqs/amps lengths are rejected.
            testCase.verifyError( ...
                @() roadprofile.multiSine(100, 0.01, [1, 2], [0.01]), ...
                'roadprofile:invalidParameter');
        end

        function test_multisine_nyquist_violation(testCase)
            %test_multisine_nyquist_violation Verify that any frequency
            %   above Nyquist raises roadprofile:invalidFrequency.
            testCase.verifyError( ...
                @() roadprofile.multiSine(100, 0.05, [1, 20], [0.01, 0.01]), ...
                'roadprofile:invalidFrequency');
        end
    end
end
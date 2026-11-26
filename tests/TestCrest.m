classdef TestCrest < matlab.unittest.TestCase
    %TestCrest Tests for the crest (triangular peak) pattern.

    methods (Test)
        function test_crest_length(testCase)
            %test_crest_length Verify the sample count.
            p = roadprofile.crest(100, 0.05, 0.05, 0.6, 10);
            testCase.verifyEqual(numel(p.x), round(100/0.05));
        end

        function test_crest_peak_at_midpoint(testCase)
            %test_crest_peak_at_midpoint Verify the peak equals height
            %   at the exact midpoint (sample-aligned).
            H = 0.05; w = 0.6; x0 = 10;
            p = roadprofile.crest(100, 0.01, H, w, x0);
            xMid = x0 + w/2;
            idx = find(abs(p.x - xMid) < 1e-10, 1);
            testCase.verifyNotEmpty(idx);
            testCase.verifyEqual(p.z(idx), H, 'AbsTol', 1e-12);
        end

        function test_crest_zero_outside(testCase)
            %test_crest_zero_outside Verify that z = 0 outside the window.
            H = 0.05; w = 0.6; x0 = 10;
            p = roadprofile.crest(100, 0.01, H, w, x0);
            testCase.verifyTrue(all(p.z(p.x < x0) == 0));
            testCase.verifyTrue(all(p.z(p.x > x0 + w) == 0));
        end

        function test_crest_c0_not_c1(testCase)
            %test_crest_c0_not_c1 Verify that the slope is discontinuous
            %   at the peak (triangular, C0 not C1).
            H = 0.05; w = 0.6; x0 = 10;
            p = roadprofile.crest(100, 0.01, H, w, x0);
            xMid = x0 + w/2;
            idx = find(abs(p.x - xMid) < 1e-10, 1);
            slopeBefore = (p.z(idx) - p.z(idx-1)) / p.dx;
            slopeAfter  = (p.z(idx+1) - p.z(idx)) / p.dx;
            testCase.verifyEqual(slopeBefore,  2*H/w, 'AbsTol', 1e-10);
            testCase.verifyEqual(slopeAfter,  -2*H/w, 'AbsTol', 1e-10);
        end

        function test_crest_negative_height(testCase)
            %test_crest_negative_height Verify that negative height is
            %   rejected (use valley for depressions).
            testCase.verifyError( ...
                @() roadprofile.crest(100, 0.01, -0.05, 0.6, 10), ...
                'MATLAB:validators:mustBeNonnegative');
        end

        function test_crest_width_too_small(testCase)
            %test_crest_width_too_small Verify that width < 4*dx is rejected.
            testCase.verifyError( ...
                @() roadprofile.crest(100, 0.05, 0.05, 0.15, 10), ...
                'roadprofile:invalidWidth');
        end
    end
end
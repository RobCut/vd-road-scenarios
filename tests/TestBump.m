classdef TestBump < matlab.unittest.TestCase
    %TestBump Tests for the isolated bump profile pattern.

    methods (Test)
        function test_bump_length(testCase)
            %test_bump_length Verify the sample count.
            p = roadprofile.bump(100, 0.05, 0.05, 0.6, 10);
            testCase.verifyEqual(numel(p.x), round(100/0.05));
            testCase.verifyEqual(p.dx, 0.05, 'AbsTol', 1e-12);
        end

        function test_bump_peak_amplitude(testCase)
            %test_bump_peak_amplitude Verify that the bump reaches
            %   exactly the requested amplitude at its midpoint.
            A = 0.05; w = 0.6; x0 = 10;
            p = roadprofile.bump(100, 0.01, A, w, x0);
            xMid = x0 + w/2;
            idx = find(abs(p.x - xMid) < p.dx, 1);
            testCase.verifyEqual(p.z(idx), A, 'AbsTol', A/100);
        end

        function test_bump_zero_outside_window(testCase)
            %test_bump_zero_outside_window Verify that z is zero
            %   before x0 and after x0 + w.
            A = 0.05; w = 0.6; x0 = 10;
            p = roadprofile.bump(100, 0.01, A, w, x0);
            testCase.verifyTrue(all(p.z(p.x < x0) == 0));
            testCase.verifyTrue(all(p.z(p.x > x0 + w) == 0));
        end

        function test_bump_continuity(testCase)
            %test_bump_continuity Verify that z is continuous at the
            %   window edges (half-versine is C1, so no jumps).
            A = 0.05; w = 0.6; x0 = 10;
            p = roadprofile.bump(100, 0.01, A, w, x0);
            edges = [x0, x0 + w];
            for k = 1:2
                idx = find(abs(p.x - edges(k)) < p.dx, 1);
                testCase.verifyLessThan(abs(p.z(idx)), A/100);
            end
        end

        function test_bump_position_outside_road(testCase)
            %test_bump_position_outside_road Verify that a bump placed
            %   outside the road window produces an all-zero profile.
            p = roadprofile.bump(100, 0.05, 0.05, 0.6, 200);
            testCase.verifyEqual(max(abs(p.z)), 0, 'AbsTol', 1e-12);
        end

        function test_bump_negative_amplitude(testCase)
            %test_bump_negative_amplitude Verify that negative amplitude
            %   is rejected (use pothole for depressions).
            testCase.verifyError( ...
                @() roadprofile.bump(100, 0.05, -0.05, 0.6, 10), ...
                'MATLAB:validators:mustBeNonnegative');
        end

        function test_bump_zero_width(testCase)
            %test_bump_zero_width Verify that zero width is rejected.
            testCase.verifyError( ...
                @() roadprofile.bump(100, 0.05, 0.05, 0, 10), ...
                'MATLAB:validators:mustBePositive');
        end

        function test_bump_width_exceeds_road(testCase)
            %test_bump_width_exceeds_road Verify that a bump wider than
            %   the road does not error (it is simply truncated).
            p = roadprofile.bump(10, 0.05, 0.05, 20, 0);
            testCase.verifyGreaterThan(max(p.z), 0);
        end

        function test_bump_length_inf(testCase)
            %test_bump_length_inf Verify that infinite L is rejected.
            testCase.verifyError( ...
                @() roadprofile.bump(Inf, 0.05, 0.05, 0.6, 10), ...
                'MATLAB:validators:mustBeFinite');
        end
    end
end
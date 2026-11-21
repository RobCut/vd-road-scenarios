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
            %test_bump_peak_amplitude Verify that the bump reaches exactly
            %   the requested amplitude at its midpoint (sample-aligned).
            A = 0.05; w = 0.6; x0 = 10;
            p = roadprofile.bump(100, 0.01, A, w, x0);
            xMid = x0 + w/2;
            idx = find(abs(p.x - xMid) < 1e-10, 1);
            testCase.verifyNotEmpty(idx);
            testCase.verifyEqual(p.z(idx), A, 'AbsTol', 1e-12);
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
            %test_bump_continuity Verify that the discrete slope stays
            %   below the analytic maximum (no jumps in value or slope).
            A = 0.05; w = 0.6; x0 = 10; dx = 0.01;
            p = roadprofile.bump(100, dx, A, w, x0);
            maxSlope = A * pi / w;
            testCase.verifyLessThanOrEqual( ...
                max(abs(diff(p.z))), maxSlope * dx * (1 + 1e-6));
        end

        function test_bump_entirely_outside(testCase)
            %test_bump_entirely_outside Verify that a bump with no
            %   overlap with the road raises roadprofile:invalidPosition.
            testCase.verifyError( ...
                @() roadprofile.bump(100, 0.05, 0.05, 0.6, 200), ...
                'roadprofile:invalidPosition');
            testCase.verifyError( ...
                @() roadprofile.bump(100, 0.05, 0.05, 0.6, -10), ...
                'roadprofile:invalidPosition');
        end

        function test_bump_starts_before_road(testCase)
            %test_bump_starts_before_road Verify that a bump starting
            %   before x = 0 is truncated (still produces a valid,
            %   partially visible bump).
            A = 0.05; w = 1.0; x0 = -0.5;
            p = roadprofile.bump(100, 0.01, A, w, x0);
            testCase.verifyGreaterThan(max(p.z), 0);
            testCase.verifyLessThanOrEqual(max(p.z), A);
        end

        function test_bump_width_too_small(testCase)
            %test_bump_width_too_small Verify that width < 4*dx is rejected.
            testCase.verifyError( ...
                @() roadprofile.bump(100, 0.05, 0.05, 0.1, 10), ...
                'roadprofile:invalidWidth');
        end

        function test_bump_width_inf(testCase)
            %test_bump_width_inf Verify that infinite width is rejected.
            testCase.verifyError( ...
                @() roadprofile.bump(100, 0.05, 0.05, Inf, 10), ...
                'MATLAB:validators:mustBeFinite');
        end

        function test_bump_position_inf(testCase)
            %test_bump_position_inf Verify that infinite position is rejected.
            testCase.verifyError( ...
                @() roadprofile.bump(100, 0.05, 0.05, 0.6, Inf), ...
                'MATLAB:validators:mustBeFinite');
        end

        function test_bump_position_nan(testCase)
            %test_bump_position_nan Verify that NaN position is rejected.
            testCase.verifyError( ...
                @() roadprofile.bump(100, 0.05, 0.05, 0.6, NaN), ...
                'MATLAB:validators:mustBeFinite');
        end

        function test_bump_too_short(testCase)
            %test_bump_too_short Verify that N < 2 raises invalidLength.
            testCase.verifyError( ...
                @() roadprofile.bump(0.01, 0.05, 0.05, 0.6, 0), ...
                'roadprofile:invalidLength');
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
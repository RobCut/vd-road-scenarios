classdef TestKink < matlab.unittest.TestCase
    %TestKink Tests for the kink (slope change) pattern.

    methods (Test)
        function test_kink_length(testCase)
            %test_kink_length Verify the sample count.
            p = roadprofile.kink(100, 0.05, 50, 0.01, -0.01);
            testCase.verifyEqual(numel(p.x), round(100/0.05));
        end

        function test_kink_slope_before(testCase)
            %test_kink_slope_before Verify that the slope is slopeBefore
            %   before the kink point.
            m = 0.01; pos = 50;
            p = roadprofile.kink(100, 0.01, pos, m, -m);
            idx = find(p.x < pos, 1, 'last');
            slope = (p.z(idx) - p.z(idx-1)) / p.dx;
            testCase.verifyEqual(slope, m, 'AbsTol', 1e-10);
        end

        function test_kink_slope_after(testCase)
            %test_kink_slope_after Verify that the slope is slopeAfter
            %   after the kink point.
            m = 0.01; pos = 50;
            p = roadprofile.kink(100, 0.01, pos, m, -m);
            idx = find(p.x > pos, 1);
            slope = (p.z(idx+1) - p.z(idx)) / p.dx;
            testCase.verifyEqual(slope, -m, 'AbsTol', 1e-10);
        end

        function test_kink_continuity(testCase)
            %test_kink_continuity Verify that z is continuous at the kink.
            m = 0.01; pos = 50;
            p = roadprofile.kink(100, 0.01, pos, m, -m);
            idx = find(p.x >= pos, 1);
            testCase.verifyEqual(p.z(idx) - p.z(idx-1), m * p.dx, ...
                'AbsTol', 1e-10);
        end

        function test_kink_zero_at_origin(testCase)
            %test_kink_zero_at_origin Verify that z(0) = 0.
            p = roadprofile.kink(100, 0.05, 50, 0.01, -0.01);
            testCase.verifyEqual(p.z(1), 0, 'AbsTol', 1e-12);
        end
    end
end
classdef TestPothole < matlab.unittest.TestCase
    %TestPothole Tests for the isolated pothole profile pattern.

    methods (Test)
        function test_pothole_length(testCase)
            %test_pothole_length Verify the sample count.
            p = roadprofile.pothole(100, 0.05, 0.05, 0.6, 10);
            testCase.verifyEqual(numel(p.x), round(100/0.05));
            testCase.verifyEqual(p.dx, 0.05, 'AbsTol', 1e-12);
        end

        function test_pothole_depth_at_midpoint(testCase)
            %test_pothole_depth_at_midpoint Verify that the depression
            %   reaches exactly -depth at its midpoint.
            D = 0.05; w = 0.6; x0 = 10;
            p = roadprofile.pothole(100, 0.01, D, w, x0);
            xMid = x0 + w/2;
            idx = find(abs(p.x - xMid) < 1e-10, 1);
            testCase.verifyNotEmpty(idx);
            testCase.verifyEqual(p.z(idx), -D, 'AbsTol', 1e-12);
        end

        function test_pothole_is_negative_of_bump(testCase)
            %test_pothole_is_negative_of_bump Verify that pothole is the
            %   exact negation of bump (same L, dx, depth, width, x0).
            L = 100; dx = 0.01; D = 0.05; w = 0.6; x0 = 10;
            pB = roadprofile.bump(L, dx, D, w, x0);
            pP = roadprofile.pothole(L, dx, D, w, x0);
            testCase.verifyEqual(pP.x, pB.x, 'AbsTol', 1e-12);
            testCase.verifyEqual(pP.z, -pB.z, 'AbsTol', 1e-12);
            testCase.verifyEqual(pP.dx, pB.dx, 'AbsTol', 1e-12);
        end

        function test_pothole_zero_outside_window(testCase)
            %test_pothole_zero_outside_window Verify that z is zero
            %   outside the pothole window.
            p = roadprofile.pothole(100, 0.01, 0.05, 0.6, 10);
            testCase.verifyTrue(all(p.z(p.x < 10) == 0));
            testCase.verifyTrue(all(p.z(p.x > 10.6) == 0));
        end

        function test_pothole_negative_depth(testCase)
            %test_pothole_negative_depth Verify that negative depth is
            %   rejected (use bump for elevation).
            testCase.verifyError( ...
                @() roadprofile.pothole(100, 0.05, -0.05, 0.6, 10), ...
                'MATLAB:validators:mustBeNonnegative');
        end

        function test_pothole_width_too_small(testCase)
            %test_pothole_width_too_small Verify that width < 4*dx is
            %   rejected (inherited from bump).
            testCase.verifyError( ...
                @() roadprofile.pothole(100, 0.05, 0.05, 0.1, 10), ...
                'roadprofile:invalidWidth');
        end

        function test_pothole_entirely_outside(testCase)
            %test_pothole_entirely_outside Verify that a pothole with no
            %   overlap with the road raises roadprofile:invalidPosition.
            testCase.verifyError( ...
                @() roadprofile.pothole(100, 0.05, 0.05, 0.6, 200), ...
                'roadprofile:invalidPosition');
        end
    end
end
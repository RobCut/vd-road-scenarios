classdef TestStep < matlab.unittest.TestCase
    %TestStep Tests for the step pattern.

    methods (Test)
        function test_step_length(testCase)
            %test_step_length Verify the sample count.
            p = roadprofile.step(100, 0.05, 0.05, 50);
            testCase.verifyEqual(numel(p.x), round(100/0.05));
            testCase.verifyEqual(p.dx, 0.05, 'AbsTol', 1e-12);
        end

        function test_step_before_position(testCase)
            %test_step_before_position Verify that z = 0 before position.
            p = roadprofile.step(100, 0.05, 0.05, 50);
            testCase.verifyTrue(all(p.z(p.x < 50) == 0));
        end

        function test_step_after_position(testCase)
            %test_step_after_position Verify that z = height after position.
            H = 0.05;
            p = roadprofile.step(100, 0.05, H, 50);
            testCase.verifyTrue(all(p.z(p.x >= 50) == H));
        end

        function test_step_exact_position(testCase)
            %test_step_exact_position Verify that the first sample at or
            %   past position receives the full height (sharp step).
            H = 0.05; pos = 50;
            p = roadprofile.step(100, 0.05, H, pos);
            idx = find(p.x >= pos, 1);
            testCase.verifyEqual(p.z(idx), H, 'AbsTol', 1e-12);
            testCase.verifyEqual(p.z(idx-1), 0, 'AbsTol', 1e-12);
        end

        function test_step_negative_height(testCase)
            %test_step_negative_height Verify that a negative height
            %   produces a downward step.
            H = -0.02;
            p = roadprofile.step(100, 0.05, H, 50);
            testCase.verifyTrue(all(p.z(p.x >= 50) == H));
        end

        function test_step_position_outside(testCase)
            %test_step_position_outside Verify that a position outside
            %   the road produces an all-zero or all-height profile.
            pBelow = roadprofile.step(100, 0.05, 0.05, -10);
            testCase.verifyTrue(all(pBelow.z == 0.05));
            pAbove = roadprofile.step(100, 0.05, 0.05, 200);
            testCase.verifyTrue(all(pAbove.z == 0));
        end

        function test_step_width_smooth(testCase)
            %test_step_width_smooth Verify that Width > 0 produces a
            %   sigmoid transition (no sharp discontinuity).
            H = 0.05; pos = 50; w = 1.0;
            p = roadprofile.step(100, 0.01, H, pos, Width=w);
            maxJump = max(abs(diff(p.z)));
            testCase.verifyLessThan(maxJump, H/2);
        end

        function test_step_length_inf(testCase)
            %test_step_length_inf Verify that infinite L is rejected.
            testCase.verifyError( ...
                @() roadprofile.step(Inf, 0.05, 0.05, 50), ...
                'MATLAB:validators:mustBeFinite');
        end
    end
end
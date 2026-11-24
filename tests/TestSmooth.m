classdef TestSmooth < matlab.unittest.TestCase
    %TestSmooth Tests for the flat road profile.

    methods (Test)
        function test_smooth_length(testCase)
            %test_smooth_length Verify the sample count.
            p = roadprofile.smooth(100, 0.05);
            testCase.verifyEqual(numel(p.x), round(100/0.05));
            testCase.verifyEqual(p.dx, 0.05, 'AbsTol', 1e-12);
        end

        function test_smooth_all_zero(testCase)
            %test_smooth_all_zero Verify that z is identically zero.
            p = roadprofile.smooth(100, 0.05);
            testCase.verifyTrue(all(p.z == 0));
        end

        function test_smooth_too_short(testCase)
            %test_smooth_too_short Verify that N < 2 raises invalidLength.
            testCase.verifyError( ...
                @() roadprofile.smooth(0.01, 0.05), ...
                'roadprofile:invalidLength');
        end

        function test_smooth_length_inf(testCase)
            %test_smooth_length_inf Verify that infinite L is rejected.
            testCase.verifyError( ...
                @() roadprofile.smooth(Inf, 0.05), ...
                'MATLAB:validators:mustBeFinite');
        end
    end
end
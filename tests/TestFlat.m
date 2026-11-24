classdef TestFlat < matlab.unittest.TestCase
    %TestFlat Tests for the flat (constant-height) profile pattern.

    methods (Test)
        function test_flat_length(testCase)
            %test_flat_length Verify the sample count.
            p = roadprofile.flat(100, 0.05);
            testCase.verifyEqual(numel(p.x), round(100/0.05));
            testCase.verifyEqual(p.dx, 0.05, 'AbsTol', 1e-12);
        end

        function test_flat_default_zero(testCase)
            %test_flat_default_zero Verify that z is identically zero
            %   when Height is not provided.
            p = roadprofile.flat(100, 0.05);
            testCase.verifyTrue(all(p.z == 0));
        end

        function test_flat_constant_height(testCase)
            %test_flat_constant_height Verify that z equals Height
            %   when specified.
            h = 0.02;
            p = roadprofile.flat(100, 0.05, h);
            testCase.verifyTrue(all(p.z == h));
        end

        function test_flat_too_short(testCase)
            %test_flat_too_short Verify that N < 2 raises
            %   roadprofile:invalidLength.
            testCase.verifyError( ...
                @() roadprofile.flat(0.01, 0.05), ...
                'roadprofile:invalidLength');
        end

        function test_flat_length_inf(testCase)
            %test_flat_length_inf Verify that infinite L is rejected.
            testCase.verifyError( ...
                @() roadprofile.flat(Inf, 0.05), ...
                'MATLAB:validators:mustBeFinite');
        end

        function test_flat_height_inf(testCase)
            %test_flat_height_inf Verify that infinite Height is rejected.
            testCase.verifyError( ...
                @() roadprofile.flat(100, 0.05, Inf), ...
                'MATLAB:validators:mustBeFinite');
        end

        function test_flat_height_nan(testCase)
            %test_flat_height_nan Verify that NaN Height is rejected.
            testCase.verifyError( ...
                @() roadprofile.flat(100, 0.05, NaN), ...
                'MATLAB:validators:mustBeFinite');
        end
    end
end
classdef TestValley < matlab.unittest.TestCase
    %TestValley Tests for the valley (triangular depression) pattern.

    methods (Test)
        function test_valley_length(testCase)
            %test_valley_length Verify the sample count.
            p = roadprofile.valley(100, 0.05, 0.05, 0.6, 10);
            testCase.verifyEqual(numel(p.x), round(100/0.05));
        end

        function test_valley_is_negated_crest(testCase)
            %test_valley_is_negated_crest Verify that valley is the exact
            %   negation of crest on the z field.
            L = 100; dx = 0.01; D = 0.05; w = 0.6; x0 = 10;
            pC = roadprofile.crest(L, dx, D, w, x0);
            pV = roadprofile.valley(L, dx, D, w, x0);
            testCase.verifyEqual(pV.x, pC.x, 'AbsTol', 1e-12);
            testCase.verifyEqual(pV.z, -pC.z, 'AbsTol', 1e-12);
        end

        function test_valley_negative_depth(testCase)
            %test_valley_negative_depth Verify that negative depth is
            %   rejected (use crest for peaks).
            testCase.verifyError( ...
                @() roadprofile.valley(100, 0.05, -0.05, 0.6, 10), ...
                'MATLAB:validators:mustBeNonnegative');
        end
    end
end
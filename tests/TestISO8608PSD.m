classdef TestISO8608PSD < matlab.unittest.TestCase
    %TestISO8608PSD Tests for the ISO 8608 PSD formula.
    %   Covers all roughness classes, vector input, and input validation.

    properties (Constant)
        n0 = 0.1;
        G0 = struct( ...
            'A', 16e-6, ...
            'B', 64e-6, ...
            'C', 256e-6, ...
            'D', 1024e-6, ...
            'E', 4096e-6, ...
            'F', 16384e-6, ...
            'G', 65536e-6, ...
            'H', 262144e-6)
    end

    methods (Test)
        function test_all_classes_at_n0(testCase)
            %test_all_classes_at_n0 Verify the reference PSD at n0 for
            %   every class.
            classes = fieldnames(testCase.G0);
            for i = 1:numel(classes)
                c = classes{i};
                expected = testCase.G0.(c);
                actual = roadprofile.iso8608PSD(c, testCase.n0);
                testCase.verifyEqual(actual, expected, 'RelTol', 1e-12);
            end
        end

        function test_lowercase_class_accepted(testCase)
            %test_lowercase_class_accepted Verify that lowercase input is
            %   normalized to uppercase.
            testCase.verifyEqual( ...
                roadprofile.iso8608PSD('a', testCase.n0), 16e-6);
        end

        function test_vector_input(testCase)
            %test_vector_input Verify that the function is vectorized.
            n = [0.01, 0.1, 1.0];
            expected = 16e-6 .* (n ./ 0.1) .^ (-2);
            actual = roadprofile.iso8608PSD('A', n);
            testCase.verifyEqual(actual, expected, 'RelTol', 1e-12);
        end

        function test_n_zero(testCase)
            %test_n_zero Verify that n = 0 is rejected.
            testCase.verifyError( ...
                @() roadprofile.iso8608PSD('A', 0), ...
                'MATLAB:validators:mustBePositive');
        end

        function test_n_negative(testCase)
            %test_n_negative Verify that negative n is rejected.
            testCase.verifyError( ...
                @() roadprofile.iso8608PSD('A', -0.1), ...
                'MATLAB:validators:mustBePositive');
        end

        function test_n_non_numeric(testCase)
            %test_n_non_numeric Verify that non-numeric n is rejected.
            testCase.verifyError( ...
                @() roadprofile.iso8608PSD('A', 'abc'), ...
                'MATLAB:validators:mustBeNumeric');
        end

        function test_unknown_class(testCase)
            %test_unknown_class Verify that an unknown class produces
            %   roadprofile:invalidClass.
            testCase.verifyError( ...
                @() roadprofile.iso8608PSD('Z', testCase.n0), ...
                'roadprofile:invalidClass');
        end
    end
end
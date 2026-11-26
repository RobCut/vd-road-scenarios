classdef TestRngState < matlab.unittest.TestCase
    %TestRngState Seeded calls must not alter the global random state.

    properties (TestParameter)
        Generator = struct( ...
            'iso8608',      @() roadprofile.iso8608Profile(20, 0.01, 'B', Seed=1), ...
            'belgianBlock', @() roadprofile.belgianBlock(20, 0.01, 0.03, 0.2, Seed=1), ...
            'cobblestone',  @() roadprofile.cobblestone(20, 0.01, 0.02, 0.1, Seed=1), ...
            'compose',      @() roadprofile.compose(20, 0.01, struct('Start', 0, ...
            'Stop', 20, 'Type', "iso8608", 'Params', {{'B'}}), Seed=1))
    end

    methods (Test)
        function test_state_preserved(testCase, Generator)
            %test_state_preserved Compare rng before and after the call.
            before = rng;
            Generator();
            testCase.verifyEqual(rng, before);
        end
    end
end
classdef TestEdge < matlab.unittest.TestCase
    %TestEdge Tests for the edge (plateau) pattern.

    methods (Test)
        function test_edge_length(testCase)
            %test_edge_length Verify the sample count.
            p = roadprofile.edge(100, 0.05, 0.05, 20, 40);
            testCase.verifyEqual(numel(p.x), round(100/0.05));
            testCase.verifyEqual(p.dx, 0.05, 'AbsTol', 1e-12);
        end

        function test_edge_inside_window(testCase)
            %test_edge_inside_window Verify that z = height inside [start, stop).
            H = 0.05; s = 20; e = 40;
            p = roadprofile.edge(100, 0.01, H, s, e);
            inside = p.x >= s & p.x < e;
            testCase.verifyTrue(all(p.z(inside) == H));
        end

        function test_edge_outside_window(testCase)
            %test_edge_outside_window Verify that z = 0 outside the window.
            H = 0.05; s = 20; e = 40;
            p = roadprofile.edge(100, 0.01, H, s, e);
            outside = p.x < s | p.x >= e;
            testCase.verifyTrue(all(p.z(outside) == 0));
        end

        function test_edge_discontinuity(testCase)
            %test_edge_discontinuity Verify that the boundary is a true
            %   step (C0, no C1) with jump exactly H.
            H = 0.05; s = 20;
            p = roadprofile.edge(100, 0.01, H, s, 40);
            idx = find(p.x >= s, 1);
            testCase.verifyEqual(p.z(idx) - p.z(idx-1), H, 'AbsTol', 1e-12);
        end

        function test_edge_start_after_stop(testCase)
            %test_edge_start_after_stop Verify that start >= stop raises
            %   roadprofile:invalidPosition.
            testCase.verifyError( ...
                @() roadprofile.edge(100, 0.05, 0.05, 40, 20), ...
                'roadprofile:invalidPosition');
        end

        function test_edge_stop_beyond_road(testCase)
            %test_edge_stop_beyond_road Verify that stop > Leff raises
            %   roadprofile:invalidPosition.
            testCase.verifyError( ...
                @() roadprofile.edge(10, 0.05, 0.05, 5, 20), ...
                'roadprofile:invalidPosition');
        end

        function test_edge_reaches_road_end(testCase)
            %test_edge_reaches_road_end Verify that stop = L is accepted.
            p = roadprofile.edge(10, 0.05, 0.05, 5, 10);
            testCase.verifyEqual(p.z(end), 0.05);
        end

        function test_edge_empty_window(testCase)
            %test_edge_empty_window Verify that a window between two samples
            %   is rejected.
            testCase.verifyError( ...
                @() roadprofile.edge(10, 0.05, 0.05, 5.01, 5.04), ...
                'roadprofile:invalidPosition');
        end
    end
end
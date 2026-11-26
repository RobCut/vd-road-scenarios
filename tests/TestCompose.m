classdef TestCompose < matlab.unittest.TestCase
    %TestCompose Tests for the multi-zone profile composer.

    methods (Test)
        function test_compose_empty_segments(testCase)
            %test_compose_empty_segments Verify that an empty segment
            %   array produces a flat zero profile.
            segs = struct('Start', {}, 'Stop', {}, 'Type', {}, 'Params', {});
            p = roadprofile.compose(100, 0.05, segs);
            testCase.verifyEqual(numel(p.x), round(100/0.05));
            testCase.verifyTrue(all(p.z == 0));
        end

        function test_compose_single_sine_matches_direct(testCase)
            %test_compose_single_sine_matches_direct Verify that a
            %   single sine segment covering the entire road produces
            %   the same z as calling sine directly.
            L = 100; dx = 0.05; freq = 0.2; A = 0.01;
            segs = struct('Start', 0, 'Stop', L, 'Type', "sine", ...
                'Params', {{freq, A}});
            pComposed = roadprofile.compose(L, dx, segs);
            pDirect = roadprofile.sine(L, dx, freq, A);
            testCase.verifyEqual(pComposed.x, pDirect.x, 'AbsTol', 1e-12);
            testCase.verifyEqual(pComposed.z, pDirect.z, 'AbsTol', 1e-12);
        end

        function test_compose_two_contiguous_sines(testCase)
            %test_compose_two_contiguous_sines Verify that two
            %   contiguous sine segments produce a profile that matches
            %   the piecewise concatenation of two direct calls, with
            %   no gaps and no overlaps at the boundary.
            L = 100; dx = 0.05; f = 0.2; A = 0.01;
            segs = [ ...
                struct('Start', 0,   'Stop', 50, 'Type', "sine", 'Params', {{f, A}}), ...
                struct('Start', 50,  'Stop', 100, 'Type', "sine", 'Params', {{f, A}}) ...
                ];
            p = roadprofile.compose(L, dx, segs);
            p1 = roadprofile.sine(50, dx, f, A);
            p2 = roadprofile.sine(50, dx, f, A);
            expected = [p1.z; p2.z];
            testCase.verifyEqual(p.z, expected, 'AbsTol', 1e-12);
        end

        function test_compose_flat_gap(testCase)
            %test_compose_flat_gap Verify that gaps between segments
            %   are filled with zero (flat default).
            L = 100; dx = 0.05;
            segs = [ ...
                struct('Start', 0,   'Stop', 10, 'Type', "sine", 'Params', {{0.2, 0.01}}), ...
                struct('Start', 90,  'Stop', 100, 'Type', "sine", 'Params', {{0.2, 0.01}}) ...
                ];
            p = roadprofile.compose(L, dx, segs);
            gap = p.x >= 10 & p.x < 90;
            testCase.verifyTrue(all(p.z(gap) == 0));
        end

        function test_compose_overlap_summed(testCase)
            %test_compose_overlap_summed Verify that overlapping segments
            %   are summed where they overlap.
            L = 100; dx = 0.05;
            segs = [ ...
                struct('Start', 0,   'Stop', 60, 'Type', "flat", 'Params', {{0.02}}), ...
                struct('Start', 40,  'Stop', 100, 'Type', "flat", 'Params', {{0.03}}) ...
                ];
            p = roadprofile.compose(L, dx, segs);
            onlyFirst = p.x >= 0 & p.x < 40;
            overlap = p.x >= 40 & p.x < 60;
            onlySecond = p.x >= 60 & p.x < 100;
            testCase.verifyTrue(all(abs(p.z(onlyFirst) - 0.02) < 1e-12));
            testCase.verifyTrue(all(abs(p.z(overlap) - 0.05) < 1e-12));
            testCase.verifyTrue(all(abs(p.z(onlySecond) - 0.03) < 1e-12));
        end

        function test_compose_remove_mean(testCase)
            %test_compose_remove_mean Verify that RemoveMean=true
            %   produces a zero-mean profile.
            L = 100; dx = 0.05;
            segs = struct('Start', 0, 'Stop', L, 'Type', "flat", 'Params', {{0.05}});
            p = roadprofile.compose(L, dx, segs, RemoveMean=true);
            testCase.verifyEqual(mean(p.z), 0, 'AbsTol', 1e-12);
        end

        function test_compose_iso8608_segments_different_seeds(testCase)
            %test_compose_iso8608_segments_different_seeds Verify that
            %   two iso8608 segments of the same class are not identical
            %   (each segment receives a derived seed from the master seed).
            L = 200; dx = 0.05;
            segs = [ ...
                struct('Start', 0,   'Stop', 100, 'Type', "iso8608", 'Params', {{'B'}}), ...
                struct('Start', 100, 'Stop', 200, 'Type', "iso8608", 'Params', {{'B'}}) ...
                ];
            p = roadprofile.compose(L, dx, segs, Seed=42);
            s1 = p.z(1:round(100/dx));
            s2 = p.z(round(100/dx)+1:end);
            testCase.verifyNotEqual(s1, s2);
        end

        function test_compose_iso8608_reproducible(testCase)
            %test_compose_iso8608_reproducible Verify that the same
            %   master seed produces identical output across calls.
            L = 200; dx = 0.05;
            segs = [ ...
                struct('Start', 0,   'Stop', 100, 'Type', "iso8608", 'Params', {{'B'}}), ...
                struct('Start', 100, 'Stop', 200, 'Type', "iso8608", 'Params', {{'C'}}) ...
                ];
            p1 = roadprofile.compose(L, dx, segs, Seed=42);
            p2 = roadprofile.compose(L, dx, segs, Seed=42);
            testCase.verifyEqual(p1.z, p2.z, 'AbsTol', 1e-12);
        end

        function test_compose_unknown_type(testCase)
            %test_compose_unknown_type Verify that an unknown Type
            %   raises roadprofile:unknownPattern.
            L = 100; dx = 0.05;
            segs = struct('Start', 0, 'Stop', L, 'Type', "unknown", 'Params', {{}});
            testCase.verifyError( ...
                @() roadprofile.compose(L, dx, segs), ...
                'roadprofile:unknownPattern');
        end

        function test_compose_segment_invalid_start(testCase)
            %test_compose_segment_invalid_start Verify that negative
            %   Start raises roadprofile:invalidSegment.
            L = 100; dx = 0.05;
            segs = struct('Start', -1, 'Stop', 10, 'Type', "sine", 'Params', {{0.2, 0.01}});
            testCase.verifyError( ...
                @() roadprofile.compose(L, dx, segs), ...
                'roadprofile:invalidSegment');
        end

        function test_compose_segment_start_after_stop(testCase)
            %test_compose_segment_start_after_stop Verify that Start >= Stop
            %   raises roadprofile:invalidSegment.
            L = 100; dx = 0.05;
            segs = struct('Start', 50, 'Stop', 40, 'Type', "sine", 'Params', {{0.2, 0.01}});
            testCase.verifyError( ...
                @() roadprofile.compose(L, dx, segs), ...
                'roadprofile:invalidSegment');
        end

        function test_compose_segment_past_road(testCase)
            %test_compose_segment_past_road Verify that Stop beyond Leff
            %   raises roadprofile:invalidSegment.
            L = 100; dx = 0.05;
            segs = struct('Start', 0, 'Stop', 200, 'Type', "sine", 'Params', {{0.2, 0.01}});
            testCase.verifyError( ...
                @() roadprofile.compose(L, dx, segs), ...
                'roadprofile:invalidSegment');
        end

        function test_compose_pattern_error_propagated(testCase)
            %test_compose_pattern_error_propagated Verify that a
            %   pattern-level error (e.g. invalidWidth for a too-short
            %   bump) is wrapped as roadprofile:invalidSegment with the
            %   segment index and the original cause.
            L = 100; dx = 0.05;
            segs = struct('Start', 10, 'Stop', 20, 'Type', "bump", ...
                'Params', {{0.05, 0.1, 0}});  % width 0.1 < 4*dx = 0.2
            try
                roadprofile.compose(L, dx, segs);
                testCase.verifyFail('Expected invalidSegment');
            catch ME
                testCase.verifyEqual(ME.identifier, 'roadprofile:invalidSegment');
                testCase.verifyNotEmpty(ME.cause);
            end
        end

                function test_compose_non_integer_boundaries(testCase)
            %test_compose_non_integer_boundaries Verify that Start and Stop
            %   not aligned to the grid snap to nearest sample without
            %   dimension errors.
            L = 10; dx = 0.1;
            segs = struct('Start', 0.04, 'Stop', 0.96, 'Type', "flat", ...
                'Params', {{0.05}});
            p = roadprofile.compose(L, dx, segs);
            i0 = round(0.04/0.1);  % = 0
            i1 = round(0.96/0.1);  % = 10
            testCase.verifyTrue(all(abs(p.z(i0+1:i1) - 0.05) < 1e-12));
            testCase.verifyTrue(all(p.z(i1+1:end) == 0));
        end

        function test_compose_segment_shorter_than_sample(testCase)
            %test_compose_segment_shorter_than_sample Verify that a
            %   segment shorter than one sample raises invalidSegment.
            L = 100; dx = 0.1;
            segs = struct('Start', 10, 'Stop', 10.05, 'Type', "flat", ...
                'Params', {{0}});
            testCase.verifyError( ...
                @() roadprofile.compose(L, dx, segs), ...
                'roadprofile:invalidSegment');
        end

        function test_compose_seed_traceability(testCase)
            %test_compose_seed_traceability Verify that the SeedUsed
            %   field reproduces the segment.
            L = 100; dx = 0.05; class = 'B';
            segs = struct('Start', 0, 'Stop', L, 'Type', "iso8608", ...
                'Params', {{class}});
            p = roadprofile.compose(L, dx, segs, Seed=42);
            derivedSeed = p.segments(1).SeedUsed;
            pDirect = roadprofile.iso8608Profile(L, dx, class, Seed=derivedSeed);
            testCase.verifyEqual(p.z, pDirect.z, 'AbsTol', 1e-12);
        end

        function test_compose_seed_recorded_without_global(testCase)
            %test_compose_seed_recorded_without_global Verify that
            %   SeedUsed is recorded even without a global seed.
            L = 100; dx = 0.05;
            segs = struct('Start', 0, 'Stop', L, 'Type', "iso8608", ...
                'Params', {{'B'}});
            p = roadprofile.compose(L, dx, segs);
            testCase.verifyTrue(isfield(p.segments, 'SeedUsed'));
            derivedSeed = p.segments(1).SeedUsed;
            pDirect = roadprofile.iso8608Profile(L, dx, 'B', Seed=derivedSeed);
            testCase.verifyEqual(p.z, pDirect.z, 'AbsTol', 1e-12);
        end

        function test_compose_relative_position(testCase)
            %test_compose_relative_position Verify that the position of
            %   a bump is relative to the start of its segment.
            L = 100; dx = 0.01; A = 0.05; w = 0.6;
            segs = struct('Start', 50, 'Stop', 50+w, 'Type', "bump", ...
                'Params', {{A, w, 0}});
            p = roadprofile.compose(L, dx, segs);
            xMid = 50 + w/2;
            idx = find(abs(p.x - xMid) < 1e-10, 1);
            testCase.verifyNotEmpty(idx);
            testCase.verifyEqual(p.z(idx), A, 'AbsTol', 1e-12);
        end

        function test_compose_segment_start_nan(testCase)
            %test_compose_segment_start_nan Verify that NaN Start raises
            %   invalidSegment.
            L = 100; dx = 0.05;
            segs = struct('Start', NaN, 'Stop', 10, 'Type', "sine", ...
                'Params', {{0.2, 0.01}});
            testCase.verifyError( ...
                @() roadprofile.compose(L, dx, segs), ...
                'roadprofile:invalidSegment');
        end

        function test_compose_segment_stop_vector(testCase)
            %test_compose_segment_stop_vector Verify that a vector Stop
            %   raises invalidSegment.
            L = 100; dx = 0.05;
            segs = struct('Start', 0, 'Stop', [10 20], 'Type', "sine", ...
                'Params', {{0.2, 0.01}});
            testCase.verifyError( ...
                @() roadprofile.compose(L, dx, segs), ...
                'roadprofile:invalidSegment');
        end

        function test_compose_segment_missing_params(testCase)
            %test_compose_segment_missing_params Verify that a segment
            %   without Params raises invalidSegment.
            L = 100; dx = 0.05;
            segs = struct('Start', 0, 'Stop', 10, 'Type', "sine");
            testCase.verifyError( ...
                @() roadprofile.compose(L, dx, segs), ...
                'roadprofile:invalidSegment');
        end

        function test_compose_segments_preserved(testCase)
            %test_compose_segments_preserved Verify that p.segments
            %   preserves the input fields.
            L = 100; dx = 0.05;
            segs = struct('Start', 0, 'Stop', L, 'Type', "flat", ...
                'Params', {{0.02}});
            p = roadprofile.compose(L, dx, segs);
            testCase.verifyEqual(p.segments(1).Start, 0);
            testCase.verifyEqual(p.segments(1).Stop, L);
            testCase.verifyEqual(p.segments(1).Type, "flat");
        end

        function test_compose_cobblestone_reproducible(testCase)
            %test_compose_cobblestone_reproducible Verify that a
            %   cobblestone segment is reproducible via SeedUsed.
            L = 10; dx = 0.005;
            segs = struct('Start', 0, 'Stop', L, 'Type', "cobblestone", ...
                'Params', {{0.02, 0.1}});
            p1 = roadprofile.compose(L, dx, segs, Seed=42);
            p2 = roadprofile.compose(L, dx, segs, Seed=42);
            testCase.verifyEqual(p1.z, p2.z, 'AbsTol', 1e-12);

            derivedSeed = p1.segments(1).SeedUsed;
            pDirect = roadprofile.cobblestone(L, dx, 0.02, 0.1, Seed=derivedSeed);
            testCase.verifyEqual(p1.z, pDirect.z, 'AbsTol', 1e-12);
        end

        function test_compose_belgian_reproducible(testCase)
            %test_compose_belgian_reproducible Verify that a belgianBlock
            %   segment is reproducible via SeedUsed.
            L = 10; dx = 0.005;
            segs = struct('Start', 0, 'Stop', L, 'Type', "belgianBlock", ...
                'Params', {{0.03, 0.2}});
            p1 = roadprofile.compose(L, dx, segs, Seed=42);
            p2 = roadprofile.compose(L, dx, segs, Seed=42);
            testCase.verifyEqual(p1.z, p2.z, 'AbsTol', 1e-12);

            derivedSeed = p1.segments(1).SeedUsed;
            pDirect = roadprofile.belgianBlock(L, dx, 0.03, 0.2, Seed=derivedSeed);
            testCase.verifyEqual(p1.z, pDirect.z, 'AbsTol', 1e-12);
        end
    end
end
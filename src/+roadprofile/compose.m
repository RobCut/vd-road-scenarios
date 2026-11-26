function p = compose(L, dx, segments, options)
%COMPOSE Combine multiple road profile patterns into one scenario.
%   P = COMPOSE(L, DX, SEGMENTS) returns a struct P with fields x, z, dx,
%   segments, containing a composite road profile of length L (m) sampled
%   at DX (m). Each element of SEGMENTS defines a pattern placed on the
%   interval [Start, Stop], with T interval [Start, Stop]. Type is one of "iso8608", "sine", "washboard",
%   "chirp", "multiSine", "belgianBlock", "cobblestone", "bump",
%   "pothole", "crest", "valley", "edge", "step", "kink", "flat". Params
%   is a cell of arguments passed to the pattern after (L, dx).
%
%   P = COMPOSE(..., RemoveMean=true) subtracts the mean from the composed
%   profile.
%
%   P = COMPOSE(..., Seed=S) derives a seed for every stochastic segment.
%   It is stored in P.segments(k).SeedUsed. A non-empty SeedUsed in the
%   input takes precedence, so compose(L, dx, P.segments) replays P.
%
%   Segment boundaries are snapped to the nearest sample:
%       i0 = round(Start / DX), i1 = round(Stop / DX)
%   and the segment covers samples i0+1 : i1, with length Lseg = (i1 - i0)
%   * DX. Segments can be contiguous, disjoint, or overlapping; overlapping
%   contributions are summed. Regions not covered by any segment remain
%   zero.
%
%   Pattern-level errors (for example invalidWidth when a bump is too short
%   for DX) are wrapped as roadprofile:invalidSegment with the segment
%   index in the message and the original exception as cause.
%
%   See also roadprofile.flat, roadprofile.sine, roadprofile.bump,
%   roadprofile.pothole, roadprofile.iso8608Profile.

arguments
    L (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    dx (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    segments struct
    options.RemoveMean (1,1) logical = false
    options.Seed {mustBeNumeric, mustBeInteger, mustBeNonnegative, mustBeScalarOrEmpty} = []
end

[x, N] = roadprofile.internal.sampleGrid(L, dx, 2);
z = zeros(N, 1);
if isempty(segments)
    p.x = x;
    p.z = z;
    p.dx = dx;
    p.segments = segments;
    return;
end
requiredFields = {'Start', 'Stop', 'Type', 'Params'};
for k = 1:numel(segments)
    for f = 1:numel(requiredFields)
        if ~isfield(segments(k), requiredFields{f})
            error('roadprofile:invalidSegment', ...
                'Segment %d is missing field %s', k, requiredFields{f});
        end
    end
    s = segments(k).Start;
    if ~isnumeric(s) || ~isscalar(s) || ~isfinite(s)
        error('roadprofile:invalidSegment', ...
            'Segment %d has invalid Start (must be a finite numeric scalar)', k)
    end
    s = segments(k).Stop;
    if ~isnumeric(s) || ~isscalar(s) || ~isfinite(s)
        error('roadprofile:invalidSegment', ...
            'Segment %d has invalid Stop (must be a finite numeric scalar)', k)
    end
end
if ~isempty(options.Seed)
    stream = RandStream('mt19937ar', 'Seed', options.Seed);
end
segmentsOut = segments;
for k = 1:numel(segments)
    seg = segments(k);
    i0 = round(seg.Start / dx);
    i1 = round(seg.Stop / dx);
    if i0 < 0 || i1 > N || i0 >= i1
        error('roadprofile:invalidSegment', ...
            'Segment %d has invalid index range [%d, %d] for N = %d', ...
            k, i0, i1, N);
    end
    Lseg = (i1 - i0) * dx;
    try
        switch string(seg.Type)
            case {'iso8608', 'cobblestone', 'belgianBlock'}
                if any(cellfun(@(c) any(strcmpi(c, "Seed")), seg.Params))
                    error('roadprofile:invalidSegment', ...
                        'Use compose(..., Seed=S) or SeedUsed, not Seed in Params');
                end
                if isempty(options.Seed)
                    derivedSeed = randi([1, 2^31 - 1]);
                else
                    derivedSeed = randi(stream, [1, 2^31 - 1]);
                end
                if isfield(seg, 'SeedUsed') && ~isempty(seg.SeedUsed)
                    derivedSeed = seg.SeedUsed;   % replay
                end
                name = string(seg.Type);
                if name == "iso8608"
                    name = "iso8608Profile";
                end
                segZ = feval("roadprofile." + name, Lseg, dx, ...
                    seg.Params{:}, "Seed", derivedSeed);
                segmentsOut(k).SeedUsed = derivedSeed;

            case {'sine', 'washboard', 'chirp', 'multiSine', 'bump', ...
                    'pothole', 'crest', 'valley', 'edge', 'step', ...
                    'kink', 'flat'}
                segZ = feval("roadprofile." + string(seg.Type), ...
                    Lseg, dx, seg.Params{:});

            otherwise
                error('roadprofile:unknownPattern', ...
                    'Segment %d has unknown type "%s"', k, seg.Type);
        end
    catch ME
        if strcmp(ME.identifier, 'roadprofile:unknownPattern')
            rethrow(ME);
        end
        newME = MException('roadprofile:invalidSegment', ...
            'Segment %d (%s) failed: %s', k, seg.Type, ME.message);
        newME = addCause(newME, ME);
        throw(newME);
    end
    z(i0+1:i1) = z(i0+1:i1) + segZ.z;
end
if options.RemoveMean
    z = z - mean(z);
end

p.x = x;
p.z = z;
p.dx = dx;
p.segments = segmentsOut;
end

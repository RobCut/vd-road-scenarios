# Design Decisions

## 1. Frequency band

`iso8608Profile` synthesises the lines n = k/Leff inside [NMin, NMax],
by default 0.011–2.83 cycles/m, always below Nyquist. DC is excluded.
`NMin=0, NMax=Inf` gives the full spectrum.

## 2. Amplitude scaling

The PSD is single-sided. Each bin carries variance `G*Δn`, corresponding
to a cosine of amplitude `A = √(2·G·Δn)`. With the Hermitian pair and
`z = real(ifft(X))·N`, the relation is `|X| = √(G·Δn/2)`. The variance of
the generated profile is `mean(z.^2) = Σ G·Δn`.

## 3. Generation method

Amplitudes are fixed by the ISO 8608 model, phases are drawn from a
uniform distribution in `[0, 2π)`. Consequences:

- The periodogram of any single realization matches the theoretical PSD
  exactly by construction.
- Profiles of different classes with the same seed are exact scaled
  copies (factor 2 per class), because only the amplitudes change.
- A single point of the ensemble is not exactly Gaussian: the excess
  kurtosis is -1.5·Σσk⁴/(Σσk²)², with σk² the variance of line k. With
  the default band it is about -0.60 (L = 80 m), -0.30 (L = 100 m) and
  -0.05 (L = 1000 m), as the first line carries 61%, 39% and 9% of the
  variance. Use long profiles if Gaussianity matters.

`examples/psd_comparison.m` checks the spectrum independently of the
generator's frequency grid, with a Welch estimate (Hann window, 50%
overlap) on a 10 km profile.

## 4. Length and spacing

`N = round(L/dx)`. The effective length is `Leff = N*dx`, which may
differ from the requested `L`. The spectral resolution is `Δn = 1/Leff`.
Spectral generators need `N >= 4`, other patterns `N >= 2`
(`roadprofile:invalidLength`). Narrow-band surfaces also need a road at
least `wavelength/bw` long.

## 5. Seed handling

When a `Seed` is provided, the generator saves the current `rng` state,
sets the requested seed, and restores the previous state on exit via
`onCleanup`. This ensures the function is deterministic but does not
pollute the global random state, even if it raises an error mid-way.

## 6. Common profile structure

Every pattern in `+roadprofile/` returns a struct with fields:

- `x` — column vector of spatial positions (m), starting at 0
- `z` — column vector of road height (m), same length as `x`
- `dx` — spatial resolution (m)

The effective length is `Leff = N*dx`, where `N = round(L/dx)`, and
`x(end) = (N-1)*dx`. This convention is shared by all patterns, including compose.

Function signatures follow the pattern `pattern(L, dx, <parameters>,
Name=Value...)`, with `L` and `dx` first because they define the
domain. Parameters that are common to many patterns use name-value
arguments with sensible defaults (e.g. `Phase=0`).

## 7. Frequency vs wavelength
`sine`, `chirp` and `multiSine` take spatial frequency (cycles/m), as in
ISO 8608. `washboard`, `belgianBlock` and `cobblestone` take wavelength
(m), the natural description of a paved surface.

## 8. Nyquist and aliasing
`sine`, `chirp`, `multiSine` (and `washboard`, through `sine`) reject
frequencies at or above `1/(2*dx)`. Narrow-band surfaces require
`n0 + 3*sigma <= 1/(2*dx)`. Both raise `roadprofile:invalidFrequency`.

## 9. Mean behavior
Spectral generators (`iso8608Profile`, `belgianBlock`, `cobblestone`)
are mean-zero. Deterministic patterns keep their natural mean.

## 10. Bump pattern

The `bump` pattern produces a single isolated obstacle with a versine
(raised-cosine) profile:

    z(x) = AMP/2 * (1 - cos(2*pi*(x - X0)/W))  for X0 <= x <= X0+W

Parameters:

- `AMP` is the peak height, reached at the midpoint `X0 + W/2`. Not
  peak-to-peak.
- `W` is the base width, the length of the window where the bump is
  non-zero.
- `X0` is the start position; the bump extends to `X0 + W`.

Design choices:

- **Shape**: versine, not half-sine. The versine has zero slope at the
  edges, so the profile is C1 continuous. A half-sine would have
  non-zero end slopes, which is standard for regulation-defined speed
  bumps but more demanding on numerical solvers. This is a deliberate
  choice in favour of C1 continuity.
- **Width minimum**: `W >= 4*dx`. Below this threshold the window
  contains at most four samples and the shape is degenerate; the
  function raises `roadprofile:invalidWidth`. Note that 4*dx does not
  guarantee a well-sampled peak: if `X0` is not aligned with the grid,
  the highest sample can be up to 15% below `AMP` (worst case with
  `W = 4*dx` and offset `dx/2`). The peak sampling error drops below
  1% for `W >= 16*dx`.
- **Overlap with road**: the bump window `[X0, X0+W]` must overlap
  `[0, (N-1)*dx]` with non-zero length. Mere touching at a single
  point (e.g. `X0 + W == 0` or `X0 == (N-1)*dx`) is treated as no
  overlap and raises `roadprofile:invalidPosition`. Partial overlap
  (bump starting before 0 or extending past the last sample) is
  allowed and the bump is truncated to the road domain. Silent
  all-zero profiles are considered user errors and are not accepted.
- **Potholes**: `roadprofile.pothole(L, dx, DEPTH, W, X0)` negates the
  `z` field of `bump(L, dx, DEPTH, W, X0)`. `x` and `dx` are unchanged.
  `bump` itself accepts only non-negative amplitude; the sign
  convention is captured by the function name, not by the amplitude.

## 11. Pothole pattern

`pothole(L, dx, DEPTH, W, X0)` is the negation of `bump(L, dx, DEPTH, W, X0)`
on the `z` field, with `DEPTH >= 0`. The parameter name is `depth` (not
`amplitude`) because the sign is captured by the function name, not by
the value. All validity constraints of `bump` apply unchanged: width
minimum `W >= 4*dx`, overlap requirement, `N >= 2`, finiteness and
non-negativity of the amplitude. The `x` and `dx` fields are identical
to the corresponding `bump` profile.

This relationship means that any future fix or refinement to `bump`
(for example a change in the width minimum or the shape) propagates
automatically to `pothole`.

## 12. Flat pattern

`flat(L, dx, H=0)` produces a constant road elevation:

    z(x) = Height     for all x in [0, (N-1)*dx]

Default `H = 0` makes it a gap filler in composed scenarios: any
region not covered by an explicit segment is flat at zero elevation.
Non-zero `H` produces a raised or lowered constant surface, useful
for testing discontinuities and step responses.

`flat` does not smooth transitions. A non-zero height at the boundary
between two segments produces a step in the profile. This is a
deliberate choice: smoothing would hide a discontinuity from the user,
whereas for robustness testing the user may want to inject one
explicitly. The v0.1 scope deliberately omits fade/transition regions
in `compose`; a future release may add them as an optional feature.

## 13. Compose

`compose(L, dx, SEGMENTS, RemoveMean=false, Seed=[])` assembles a
composite profile from a struct array of segments. Each element has
fields `Start`, `Stop`, `Type`, `Params`.

**Tiling on indices.** Segment boundaries are snapped to the nearest
sample:

    i0 = round(Start / dx)
    i1 = round(Stop / dx)

and the segment covers samples `i0+1 : i1` (stop excluded). Its local
length is `Lseg = (i1 - i0) * dx`, which is exactly the length passed
to the pattern. Consequence: two contiguous segments `[a, b)` and
`[b, c)` tile without gaps or overlaps, regardless of `a, b, c` being
multiples of `dx`.

**Validation.** Each segment is checked for the four required fields
and for `Start` and `Stop` being finite numeric scalars. A segment
with `i0 < 0`, `i1 > N`, or `i0 >= i1` raises
`roadprofile:invalidSegment`. A `Type` not in the allowed set
(see the list in the compose help) raises
`roadprofile:unknownPattern`. Pattern-level errors (for example
`invalidWidth` from a bump whose segment is too short) are wrapped as
`roadprofile:invalidSegment` with the segment index in the message
and the original exception as cause.

**Overlap and gaps.** Overlapping segments are summed where they
overlap. Regions not covered by any segment remain at zero elevation
(equivalent to `flat(L, dx)`).

**Relative positions.** Parameters in `Params` are passed positionally
to the pattern after `(Lseg, dx)`. The `position` argument of `bump`
and `pothole` is therefore relative to the start of the segment, not to
the global `x`. A bump with `Start = 50, position = 0` peaks at
`x = 50 + W/2`.

**Seed derivation.** Every stochastic segment (`iso8608`, `belgianBlock`,
`cobblestone`) gets a seed, drawn from a `RandStream` initialised with the
global `Seed`, or from the global stream if none is given. It is stored in
`p.segments(k).SeedUsed`. A non-empty `SeedUsed` in the input takes
precedence, so `compose(L, dx, p.segments)` replays the composition.
`Seed` inside `Params` is rejected.

**Independent realizations.** Each `iso8608` segment is an independent
realization: it has no content below `max(NMin, 1/Lseg)`, and it is mean-zero on
its own domain. Two 100 m B segments are therefore *not* equivalent to
one 200 m B profile: the low-frequency content differs, and the mean
of each segment is removed separately before being composed.

**Discontinuities.** `compose` does not smooth transitions. If a
stochastic segment ends at a non-zero elevation and the next starts
at zero, the profile has a step at the boundary. This is a deliberate
design choice, consistent with `flat` (see §12). Smoothing will be
added as an optional feature in a future release if needed.

**Empty segments.** An empty `segments` array is valid and produces a
flat zero profile.

## 14. Stochastic patterns and seed handling

Three patterns are stochastic: `iso8608Profile`, `belgianBlock`,
`cobblestone`. Each accepts an optional `Seed` name-value argument.

**Reference behavior.** With a `Seed` supplied, the pattern saves the
global `rng` state, sets `rng(Seed, 'twister')`, generates, and restores
the global state via `onCleanup`. Without a `Seed`, the pattern uses the
current global `rng` state and produces a different realization at each
call.

**Reproducibility.** `compose` derives a distinct seed for every
stochastic segment, whether or not a global `Seed` is given. The
derived seed is stored in `p.segments(k).SeedUsed`, so each segment can
be regenerated individually with
`pattern(Lseg, dx, ..., Seed=SeedUsed)`. To replay a composition, pass `p.segments` back or use the same global `Seed`.

**Determinism of the generator.** `rng(Seed, 'twister')` pins the
algorithm, so a given seed produces the same profile regardless of
which generator was active before. This is independent of the `rng`
default, which can change across MATLAB releases.

**Direct use.** Patterns called directly with a fixed `Seed` are
deterministic. Patterns called directly without a `Seed` are not. There
is no auto-derivation at the pattern level: `compose` is the only
function that derives seeds automatically, and it does so for all
stochastic segments it receives.

**Anti-aliasing.** Event patterns are sampled at `dx` without any anti-aliasing filter. Rendering
a long profile at page width compresses many samples into few pixels
and may look blocky. For readable figures, use `dx` comparable to
the smallest feature you want to show, or plot a zoom.

## 15. Other patterns
- `chirp`: linear frequency sweep from f0 at x = 0 to f1 at x = L.
- `multiSine`: sum of sinusoids with independent amplitudes and phases.
- `belgianBlock`, `cobblestone`: Gaussian PSD, relative bandwidth 0.30 and
  0.15; the input is the RMS height.
- `crest`, `valley`: triangular, non-negative height, width >= 4*dx.
- `edge`: plateau on [S, E), 0 <= S < E <= N*dx.
- `step`: sharp, or a logistic transition when Width > 0.
- `kink`: slope change at a non-negative position, z(0) = 0.
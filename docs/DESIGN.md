# Design Decisions

## 1. Frequency band

The PSD is defined for spatial frequencies `n = 1/Leff ... 1/(2*dx)`, where
`Leff = N*dx` is the effective profile length. The DC component (n = 0) is
excluded, as the generated profile is always mean-zero. The ISO 8608 band
(0.011–2.83 cycles/m) is not applied as a hard cut: the generator produces
the full spectrum up to Nyquist, and band-limiting is left to the
`filterProfile` utility (planned, not yet implemented).

## 2. Amplitude scaling

The PSD is single-sided. Each bin carries variance `G*Δn`, corresponding
to a cosine of amplitude `A = √(2·G·Δn)`. With the Hermitian pair and
`z = real(ifft(X))·N`, the relation is `|X| = √(G·Δn/2)`. The variance of
the generated profile is `var(z) ≈ Σ G·Δn`.

## 3. Generation method

Amplitudes are fixed by the ISO 8608 model, phases are drawn from a
uniform distribution in `[0, 2π)`. Consequences:

- The periodogram of any single realization matches the theoretical PSD
  exactly by construction.
- Profiles of different classes with the same seed are exact scaled
  copies (factor 2 per class), because only the amplitudes change.
- The generated profile is approximately Gaussian by the central limit
  theorem, since it is a sum of many independent sinusoids.

The `psd_comparison.png` figure in `results/` shows theory against a
multi-realization average; it illustrates the spectrum but is not a
statistical validation. A Welch-based estimate on a long profile is a
possible future addition (project 16/19).

## 4. Length and spacing

`N = round(L/dx)`. The effective length is `Leff = N*dx`, which may
differ from the requested `L`. The spectral resolution is `Δn = 1/Leff`.
If `N < 4` the generator raises `roadprofile:invalidLength`, because
the positive-frequency set would be empty or incoherent.
For `sine` and event-based patterns, the minimum is `N >= 2`: there is no
positive-frequency set to fill, so the `N < 4` threshold does not apply.

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
`x(end) = (N-1)*dx`. This convention is shared by `iso8608Profile`,
`sine`, and all future patterns (`step`, `bump`, `pothole`,
`speedBump`, `compose`, ...).

Function signatures follow the pattern `pattern(L, dx, <parameters>,
Name=Value...)`, with `L` and `dx` first because they define the
domain. Parameters that are common to many patterns use name-value
arguments with sensible defaults (e.g. `Phase=0`).

## 7. Frequency vs wavelength

Patterns that describe a periodic structure accept frequency in
cycles/m, not wavelength in metres. This is consistent with the ISO
8608 convention (spatial frequency `n`) and makes the Nyquist check
trivial: `freq < 1/(2*dx)`. Users who think in wavelengths can compute
`freq = 1/lambda`. A future helper `roadprofile.wavelengthToFrequency`
is planned but not yet implemented.

## 8. Nyquist and aliasing

Patterns with a dominant frequency (currently `sine`, future `chirp`
and `multiSine`) raise `roadprofile:invalidFrequency` if the requested
frequency is greater than or equal to the Nyquist frequency
`1/(2*dx)`. This prevents silent aliasing, which would produce a
profile at a lower apparent frequency than requested.

## 9. Mean behavior

`iso8608Profile` removes the mean from the generated profile, so the
resulting road height is always mean-zero. This is appropriate for a
stationary stochastic process. Deterministic patterns (`sine`, and the
future `bump`, `pothole`, `step`) do not remove the mean: their mean
depends on the number of full periods inside the profile, and forcing
zero would distort the physical meaning of the signal.

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

`flat(L, dx, Height=0)` produces a constant road elevation:

    z(x) = Height     for all x in [0, (N-1)*dx]

Default `Height = 0` makes it a gap filler in composed scenarios: any
region not covered by an explicit segment is flat at zero elevation.
Non-zero `Height` produces a raised or lowered constant surface, useful
for testing discontinuities and step responses.

`flat` does not smooth transitions. A non-zero height at the boundary
between two segments produces a step in the profile. This is a
deliberate choice: smoothing would hide a discontinuity from the user,
whereas for robustness testing the user may want to inject one
explicitly. The v0.1 scope deliberately omits fade/transition regions
in `compose`; a future release may add them as an optional feature.
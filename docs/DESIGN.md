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

## 5. Seed handling

When a `Seed` is provided, the generator saves the current `rng` state,
sets the requested seed, and restores the previous state on exit via
`onCleanup`. This ensures the function is deterministic but does not
pollute the global random state, even if it raises an error mid-way.
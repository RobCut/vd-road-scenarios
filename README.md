# vd-road-scenarios

[![MATLAB Tests](https://github.com/RobCut/vd-road-scenarios/actions/workflows/test.yml/badge.svg)](https://github.com/RobCut/vd-road-scenarios/actions/workflows/test.yml)

A MATLAB toolbox for generating synthetic road profiles: ISO 8608 roughness, proving-ground surfaces, deterministic events, and a composer for multi-zone scenarios.

## Problem

Vehicle dynamics and durability simulations need road inputs. ISO 8608 defines a spectral model for stochastic roughness, but real proving grounds also contain deterministic events (bumps, potholes, steps), narrow-band surfaces (Belgian block, cobblestone, washboard), and smooth transitions. Re-implementing each of these patterns from scratch, in a consistent way, is time-consuming and error-prone.

`vd-road-scenarios` provides a unified catalog and a composer that assembles them into a single spatial profile.

## What it does

- `roadprofile.iso8608PSD`, `roadprofile.iso8608Profile`: ISO 8608 classes A–H, mean-zero stochastic roughness.
- `roadprofile.sine`, `roadprofile.washboard`, `roadprofile.chirp`, `roadprofile.multiSine`: deterministic periodic and sweep patterns.
- `roadprofile.belgianBlock`, `roadprofile.cobblestone`: narrow-band stochastic proving-ground surfaces.
- `roadprofile.bump`, `roadprofile.pothole`, `roadprofile.crest`, `roadprofile.valley`, `roadprofile.edge`, `roadprofile.step`, `roadprofile.kink`, `roadprofile.flat`: events, discontinuities, and constant surfaces.
- `roadprofile.compose`: assemble segments into a multi-zone scenario, with deterministic seed derivation for the stochastic patterns.

## Results

![Catalog overview](results/catalog_overview.png)

*The complete catalog of 15 patterns on a common spatial grid.*

![Scenario showcase](results/scenario_showcase.png)

*A 1000 m mixed scenario built with `compose`: ISO B, Belgian block, bump, cobblestone, pothole, ISO C, washboard, ISO D.*

## Method

Each pattern returns a struct with fields `x`, `z`, `dx` (column vectors, `x` starting at 0). Patterns accept `(L, dx, ...)` as the first two positional arguments and follow common conventions (frequency in cycles/m, Nyquist check on any dominant frequency, `Seed` name-value for stochastic patterns).

`compose` snaps segment boundaries to the nearest sample, sums overlapping contributions, fills gaps with zero, and derives a unique seed for every stochastic segment (recorded in `p.segments(k).SeedUsed`). The design decisions are documented in `docs/DESIGN.md`.

## Limitations

- 1D only: `z(x)`, no 3D surfaces or lateral variation (2D road patches are deferred).
- No vehicle model: this toolbox produces road profiles, not vehicle responses. Simulation is out of scope.
- `compose` does not smooth transitions: if a stochastic segment ends at a non-zero elevation and the next starts at zero, the profile has a step. This is a deliberate choice, documented in DESIGN §13.
- No import from CRG/CSV yet (planned).

## Reproducibility

Requirements:

- MATLAB R2026b Update 1 (verified). Newer versions should work.
- No additional toolboxes.

To reproduce:

1. Open `vd-road-scenarios.prj` in MATLAB. The project adds `src/` and `tests/` to the path.
2. Run the test suite: ```runtests('tests')```
3. Regenerate the figures: ```run('examples/catalog_overview.m')```, ```run('examples/scenario_showcase.m')```


## Documentation

- `docs/DESIGN.md` — design decisions, pattern conventions, seed handling.
- `data/` — canonical JSON files for vehicle parameters are **not** included here: they live in `vehkit`. This project only produces spatial profiles.

## License

MIT. See `LICENSE`.

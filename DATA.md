# Data Sources and Notes

This project does not use external datasets. All road profiles are
generated synthetically from published formulas:

- **ISO 8608**: standard reference for the spatial power spectral density
  of road roughness. The classes A–H and the reference value at
  `n0 = 0.1 cycles/m` come from the standard.
- **Versine (bump, pothole)**: standard raised-cosine shape, zero slope
  at the edges.
- **Narrow-band stochastic surfaces (belgianBlock, cobblestone)**: a
  Gaussian PSD centered at `1/wavelength` with a configurable relative
  bandwidth. The relative bandwidth values (30% for Belgian block, 15%
  for cobblestone) are chosen empirically from published proving-ground
  descriptions.
- **Discontinuities (edge, step, kink)**: mathematical idealizations,
  not measured road features.

No proprietary data, no test-track measurements, no FSAE team material
are used.
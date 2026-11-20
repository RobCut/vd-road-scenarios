function G = iso8608PSD(roadClass, n)
%ISO8608PSD Spatial power spectral density of road roughness (ISO 8608).
%   G = ISO8608PSD(CLASS, N) returns the one-sided displacement PSD G_d(n)
%   in m^3 at the spatial frequency N (in cycles/m) for the given roughness
%   CLASS('A' to 'H').
%
%   The ISO 8608 model is:
%
%       G_d(n) = G_d(n0) * (n / n0)^(-2)
%
%   with n0 = 0.1 cycles/m and G_d(n0) depending on the class:
%       A: 16e-6    B: 64e-6    C: 256e-6   D: 1024e-6
%       E: 4096e-6  F: 16384e-6 G: 65536e-6 H: 262144e-6
%
%   N may be a scalar or an array. All elements must be positive.
%
%   See also roadprofile.iso8608Profile.

arguments
    roadClass {mustBeTextScalar}
    n {mustBeNumeric, mustBePositive}
end

roadClass = upper(string(roadClass));
G0 = classReferencePSD(roadClass);
n0 = 0.1;
G = G0 .* (n ./ n0) .^ (-2);
end

function G0 = classReferencePSD(roadClass)
%classReferencePSD Return the reference PSD at n0 = 0.1 cycles/m.
switch roadClass
    case "A"
        G0 = 16e-6;
    case "B"
        G0 = 64e-6;
    case "C"
        G0 = 256e-6;
    case "D"
        G0 = 1024e-6;
    case "E"
        G0 = 4096e-6;
    case "F"
        G0 = 16384e-6;
    case "G"
        G0 = 65536e-6;
    case "H"
        G0 = 262144e-6;
    otherwise
        throw(MException('roadprofile:invalidClass', ...
            'Unknown road roughness class: %s', roadClass));
end
end
#!/usr/bin/env python3
# v0.6  june/2026  mountaineerbr
# calculate lunar illuminated fraction
# geocentric by default; topocentric with --lon and --lat
# requires astropy and jplephem

import sys
import argparse
import warnings
import numpy as np
from astropy import units as u
from astropy.time import Time
from astropy.coordinates import get_body, solar_system_ephemeris, EarthLocation

try:
    from erfa import ErfaWarning
except Exception:
    ErfaWarning = Warning

# ERFA warns for UTC dates before UTC existed or beyond known leap seconds
warnings.filterwarnings(
    "ignore",
    category=ErfaWarning,
    message=r'ERFA function ".*" yielded .*"dubious year.*"',
)

def illuminated_fraction(t, ephem, location=None):
    with solar_system_ephemeris.set(ephem):
        sun = get_body("sun", t, location=location)
        moon = get_body("moon", t, location=location)

    psi = sun.separation(moon)      # elongation
    # phase angle, Meeus eq. 48.3 (arctan2 resolves the quadrant)
    i = np.arctan2(sun.distance * np.sin(psi),
                   moon.distance - sun.distance * np.cos(psi))
    k = float(0.5 * (1.0 + np.cos(i)))

    # clamp possible roundoff near exact new/full moon
    return float(np.clip(k, 0.0, 1.0))


def parse_time(s):
    try:
        return Time(float(s), format="jd", scale="utc")
    except ValueError:
        return Time(s, scale="utc")


def main():
    parser = argparse.ArgumentParser(
        description="Lunar illuminated fraction. Geocentric by default; "
                    "give --lon and --lat for "
                    "topocentric (parallax) correction.")
    parser.add_argument("date", nargs="*",
                        help="UTC date/time string or Julian Date "
                             "(default: now)")
    parser.add_argument("--lon", "--longitude", type=float, default=None,
                        help="observer longitude, decimal degrees east "
                             "(west negative)")
    parser.add_argument("--lat", "--latitude", type=float, default=None,
                        help="observer latitude, decimal degrees north "
                             "(south negative)")
    parser.add_argument("--height", type=float, default=0.0,
                        help="observer height, metres (default 0; "
                             "only with lon/lat)")
    args = parser.parse_args()

    arg_input = " ".join(args.date).strip()

    if arg_input:
        try:
            t = parse_time(arg_input)
        except Exception as e:
            print(f"Invalid date '{arg_input}': {e}. Using current time.",
                  file=sys.stderr)
            t = Time.now()
    else:
        t = Time.now()

    location = None
    if (args.lon is None) != (args.lat is None):
        print("Need both --lon and --lat for topocentric; "
              "falling back to geocentric.", file=sys.stderr)
    elif args.lon is not None:
        try:
            location = EarthLocation(lon=args.lon * u.deg,
                                     lat=args.lat * u.deg,
                                     height=args.height * u.m)
        except Exception as e:
            print(f"Invalid observer location: {e}. "
                  f"Falling back to geocentric.", file=sys.stderr)
    elif args.height != 0.0:
        print("--height ignored without --lon and --lat; "
              "using geocentric.", file=sys.stderr)

    try:
        # de440s: valid 1849--2150;  de440: 1550--2650
        frac = illuminated_fraction(t, "de440s", location)
    except Exception as e:
        print(f"JPL DE440s unavailable or date out of range: {e}. "
              f"Using builtin.", file=sys.stderr)
        try:
            frac = illuminated_fraction(t, "builtin", location)
        except Exception as e:
            print(f"Builtin ephemeris failed: {e}", file=sys.stderr)
            sys.exit(1)

    #print(f"{frac:.6f}")
    print(f"{frac * 100:.4f}%")


if __name__ == "__main__":
    main()


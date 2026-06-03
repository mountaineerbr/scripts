#!/usr/bin/env python3
# v0.4  june/2026  mountaineerbr
# calculate geocentric lunar illuminated fraction
# requires astropy and jplephem
# https://ssd.jpl.nasa.gov/horizons/

import sys
from astropy.time import Time
from astropy.coordinates import get_body_barycentric, solar_system_ephemeris


def illuminated_fraction(t, ephem):
    with solar_system_ephemeris.set(ephem):
        earth = get_body_barycentric("earth", t)
        moon = get_body_barycentric("moon", t)
        sun = get_body_barycentric("sun", t)

    sun_from_moon = sun - moon
    earth_from_moon = earth - moon

    cos_phase = (
        sun_from_moon.dot(earth_from_moon)
        / (sun_from_moon.norm() * earth_from_moon.norm())
    ).decompose().value

    cos_phase = min(1.0, max(-1.0, cos_phase))
    return 0.5 * (1.0 + cos_phase)


def main():
    arg_input = " ".join(sys.argv[1:]).strip()

    if len(sys.argv) > 1 and arg_input:
        try:
            t = Time(arg_input, scale="utc")
        except Exception as e:
            print(f"Invalid date '{arg_input}': {e}. Using current time.",
                  file=sys.stderr)
            t = Time.now()
    else:
        t = Time.now()

    try:
        frac = illuminated_fraction(t, "de440s")  #jpl
    except Exception as e:
        print(f"JPL DE440s unavailable: {e}. Using builtin.", file=sys.stderr)
        frac = illuminated_fraction(t, "builtin")

    print(f"{frac * 100:.4f}%")


if __name__ == "__main__":
    main()


"""Builds assets/map/land.json, the coastlines of the map of tales.

Source: Natural Earth 1:110m land (public domain,
https://github.com/nvkelso/natural-earth-vector/blob/master/geojson/ne_110m_land.geojson).
Rings are simplified (Douglas-Peucker), rounded to 0.1 degree, and
Antarctica is dropped: the map shows 58 S to 84 N.

Usage: python3 tool/map/build_world_map.py <ne_110m_land.geojson>
"""
import json
import sys

TOLERANCE = 0.25  # degrees


def simplify(points, tol):
    if len(points) < 3:
        return points
    (x1, y1), (x2, y2) = points[0], points[-1]
    dx, dy = x2 - x1, y2 - y1
    norm = (dx * dx + dy * dy) ** 0.5 or 1e-9
    best, index = 0.0, 0
    for i in range(1, len(points) - 1):
        px, py = points[i]
        d = abs(dy * px - dx * py + x2 * y1 - y2 * x1) / norm
        if d > best:
            best, index = d, i
    if best <= tol:
        return [points[0], points[-1]]
    return simplify(points[: index + 1], tol)[:-1] + simplify(points[index:], tol)


def simplify_ring(points):
    """A closed ring: split at the point farthest from the start, simplify
    both halves (a ring's endpoints coincide, which Douglas-Peucker can't
    use as a baseline)."""
    if points[0] == points[-1]:
        points = points[:-1]
    x0, y0 = points[0]
    far = max(range(len(points)), key=lambda i: (points[i][0] - x0) ** 2 + (points[i][1] - y0) ** 2)
    first = simplify(points[: far + 1], TOLERANCE)
    second = simplify(points[far:] + [points[0]], TOLERANCE)
    return first[:-1] + second[:-1]


def main(path):
    data = json.load(open(path))
    rings = []
    for feature in data["features"]:
        geometry = feature["geometry"]
        polygons = geometry["coordinates"]
        if geometry["type"] == "Polygon":
            polygons = [polygons]
        for polygon in polygons:
            outer = polygon[0]
            if max(p[1] for p in outer) < -58:
                continue  # Antarctica
            ring = simplify_ring([(p[0], p[1]) for p in outer])
            if len(ring) < 4:
                continue
            flat = []
            for lon, lat in ring:
                flat += [round(lon, 1), round(max(lat, -58.0), 1)]
            rings.append(flat)
    out = {
        "source": "Natural Earth 1:110m land, public domain (naturalearthdata.com)",
        "rings": rings,
    }
    with open("assets/map/land.json", "w") as f:
        json.dump(out, f, separators=(",", ":"))
    print(len(rings), "rings,", sum(len(r) for r in rings) // 2, "points")


if __name__ == "__main__":
    main(sys.argv[1])

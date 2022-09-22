import { Delaunay } from 'd3-delaunay';
import { polygon } from 'polygon-tools';
import Offset from 'polygon-offset';
import lodash from 'lodash';

const InsidePolygon = require('point-in-polygon');

export default {
  genVoronoi(rng, size, grid) {
    const points = [];

    for (let i = 0; i < size; i += grid) {
      for (let j = 0; j < size; j += grid) {
        points.push([
          Math.round(rng.next() * grid) + i,
          Math.round(rng.next() * grid) + j,
        ]);
      }
    }

    return Array
      .from(Delaunay.from(points).trianglePolygons())
      .map((triangle, id) => ({
        key: id,
        points: triangle,
        color: undefined,
      }));
  },
  createSector(id, name) {
    const color = ((id - 1) % 9) + 1;

    return {
      key: id,
      color: `editor-color-${color}`,
      name,
      triangles: [],
    };
  },
  createBlackhole(id, name, position, radius) {
    return {
      key: id,
      name,
      position,
      radius,
    };
  },
  toggleTriangleToSector(key, toggle, sector, triangles, sectors) {
    const triangle = triangles.find((p) => p.key === key);

    if (toggle) {
      if (triangle.color) {
        if (lodash.includes(sector.triangles, triangle)) {
          triangle.color = undefined;
          lodash.remove(sector.triangles, (p) => p.key === triangle.key);
        } else {
          sectors.forEach((s) => {
            lodash.remove(s.triangles, (p) => p.key === triangle.key);
          });

          triangle.color = sector.color;
          sector.triangles.push(triangle);
        }
      } else {
        triangle.color = sector.color;
        sector.triangles.push(triangle);
      }
    } else {
      if (triangle.color) {
        sectors.forEach((s) => {
          lodash.remove(s.triangles, (p) => p.key === triangle.key);
        });
      }

      triangle.color = sector.color;
      sector.triangles.push(triangle);
    }

    return { triangles, sectors };
  },
  assembleTriangles(sectors) {
    const errors = [];

    sectors = sectors
      .filter((sector) => sector.triangles.length > 0)
      .map((sector, key) => {
        // join triangles into sector
        const pointPolygons = sector.triangles.map((shape) => shape.points);
        const unionResult = polygon.union(...pointPolygons);

        if (unionResult.length > 1) {
          errors.push(`${sector.name}: certaines parties du secteur ont été supprimées.`);
        }

        const points = unionResult[0];

        return {
          key,
          name: sector.name,
          color: sector.color,
          points,
          points03: this.offsetPolygon(points, 0.3),
          points05: this.offsetPolygon(points, 0.5),
          points25: this.offsetPolygon(points, 2.5),
          area: polygon.area(points),
          centroid: polygon.centroid(points),
          systems: [],
        };
      });

    return { sectors, errors };
  },
  genSystem(rng, sectors, systemData, options) {
    let i = 0;

    return sectors.reduce((acc, sector) => {
      // reset sector systems
      sector.systems = [];

      // compute bounding box
      const minx = Math.ceil(Math.min(...sector.points05.map(([x, _y]) => x)));
      const miny = Math.ceil(Math.min(...sector.points05.map(([_x, y]) => y)));
      const maxx = Math.floor(Math.max(...sector.points05.map(([x, _y]) => x)));
      const maxy = Math.floor(Math.max(...sector.points05.map(([_x, y]) => y)));

      // generate random points in bounding box
      const hpsCount = options.points;
      const hotPoints = [];

      while (hotPoints.length < hpsCount) {
        const point = { x: rng.next(minx, maxx), y: rng.next(miny, maxy) };

        if (InsidePolygon([point.x, point.y], sector.points25)) {
          hotPoints.push(point);
        }
      }

      // compute longest side of the bounding box
      const longestSide = Math.max(Math.abs(minx - maxx), Math.abs(miny - maxy));
      const hpsRadius = (longestSide / hpsCount) * options.spread;

      // in the bouding box, loop for all possible points (inside the polygon)
      for (let px = minx; px <= maxx; px += 1) {
        for (let py = miny; py <= maxy; py += 1) {
          if (InsidePolygon([px, py], sector.points05)) {
            // compute proximity with hot points
            let threshold = hotPoints
              .map(({ x, y }) => Math.sqrt(Math.abs(x - px) ** 2 + Math.abs(y - py) ** 2))
              .map((d) => (Math.max(hpsRadius - d, 0) / hpsRadius) ** options.attenuation)
              .reduce((acc2, d) => acc2 + d);

            // apply thershold functions
            threshold *= options.density / 100;
            threshold = Math.min(threshold, options.maxDensity / 100);

            if (rng.next() < threshold) {
              i += 1;

              const type = this.getRandomSystemType(systemData, rng);
              const system = { key: i, position: { x: px, y: py }, type };

              acc.push(system);
              sector.systems.push(system);
            }
          }
        }
      }

      return acc;
    }, []);
  },
  offsetPolygon(points, size = 0.2) {
    const offset = new Offset();
    const p = offset.data(points).padding(0);
    return offset.data(p).padding(size)[0];
  },
  getRandomSystemType(systemData, rng) {
    const systemProbSum = systemData.reduce((acc, s) => acc + parseInt(s.gen_prob_factor, 10), 0);
    const systemProbSteps = systemData.reduce(({ acc, i }, s, idx) => {
      const newVal = i + (parseInt(s.gen_prob_factor, 10) / systemProbSum);
      acc.push(newVal);

      if (idx < systemData.length - 1) {
        return { acc, i: newVal };
      }

      return acc;
    }, { acc: [], i: 0 });

    const index = systemProbSteps.findIndex((prob) => rng.next() < prob);
    const { key } = systemData[index];
    return key;
  },
};

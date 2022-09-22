import {
  Path,
  Vector2,
  BufferAttribute,
  Matrix4,
  Mesh,
} from 'three';

import { MeshLine, MeshLineMaterial } from 'three.meshline';
import * as P from 'paper/dist/paper-core';

export function offsetContour(_offset, contour, z) {
  // adapted from: https://discourse.threejs.org/t/offsetcontour-function/3185 <3 Paul West
  const result = [];

  const offset = new BufferAttribute(new Float32Array([_offset, 0, 0]), 3);

  for (let i = 0; i < contour.length; i += 1) {
    const v1 = new Vector2().subVectors(contour[i - 1 < 0 ? contour.length - 1 : i - 1], contour[i]);
    const v2 = new Vector2().subVectors(contour[i + 1 === contour.length ? 0 : i + 1], contour[i]);
    const angle = v2.angle() - v1.angle();
    const halfAngle = angle * 0.5;

    const hA = halfAngle;
    const tA = v2.angle() + Math.PI * 0.5;

    const shift = Math.tan(hA - Math.PI * 0.5);
    const shiftMatrix = new Matrix4().set(
           1, 0, 0, 0,
      -shift, 1, 0, 0,
           0, 0, 1, 0,
           0, 0, 0, 1,
    );

    const tempAngle = tA;
    const rotationMatrix = new Matrix4().set(
      Math.cos(tempAngle), -Math.sin(tempAngle), 0, 0,
      Math.sin(tempAngle), Math.cos(tempAngle), 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1,
    );

    const translationMatrix = new Matrix4().set(
      1, 0, 0, contour[i].x,
      0, 1, 0, contour[i].y,
      0, 0, 1, 0,
      0, 0, 0, 1,
    );

    const cloneOffset = offset.clone()
      .applyMatrix4(shiftMatrix)
      .applyMatrix4(rotationMatrix)
      .applyMatrix4(translationMatrix);

    result.push(new Vector2(cloneOffset.getX(0), cloneOffset.getY(0)));
  }

  const result3 = result.reduce((acc, r) => acc.concat(r.x, r.y, z), []);
  result3.push(result3[0], result3[1], result3[2]);

  return result3;
}

export async function dashedOffsetContour(vectors2, offset = 0.1, z, options) {
  const points = offsetContour(offset, vectors2, z);
  const geom = new MeshLine();
  geom.setPoints(points);
  const material = new MeshLineMaterial(options);
  const line = new Mesh(geom, material);

  return line;
}

// Paper.js segments to a Three.js bezier Path
export function pSegmentToThreePath(segments) {
  // adapted from: brianxu/PaperjsToThreejs - MIT License - Copyright (c) 2018 Baoxuan(Brian) Xu
  const bezierPath = new Path();
  for (let i = 0; i < segments.length; i += 1) {
    const curr = segments[i];
    const next = segments[(i + 1) % segments.length];
    const p = [];
    p[0] = new Vector2(curr[0][0], curr[0][1]);
    p[1] = new Vector2(curr[2][0] + curr[0][0], curr[2][1] + curr[0][1]);
    p[2] = new Vector2(next[1][0] + next[0][0], next[1][1] + next[0][1]);
    p[3] = new Vector2(next[0][0], next[0][1]);
    if (i === 0) {
      bezierPath.moveTo(p[0].x, p[0].y);
    }
    bezierPath.bezierCurveTo(
      p[1].x, p[1].y,
      p[2].x, p[2].y,
      p[3].x, p[3].y,
    );
  }

  bezierPath.closePath();
  return bezierPath;
}

// from a list of intersecting disks, return a bezier curve outlining it as a Three Shape
export function toPath(radars) {
  const disks = radars.map(({ x, y, radius }) => new P.Path.Circle({
    center: new P.Point(x, y),
    radius,
    fillColor: 'white',
  }));
  if (!disks.length) return [];

  const [c1, ...cx] = disks;
  const united = cx.reduce((acc, c) => acc.unite(c), c1);

  // extract and map an array of segments
  // each arrays items are a cluster
  if (united.segments === undefined) {
    const [, { children }] = united.exportJSON({ asString: false });

    return children.map((child) => {
      const [, { segments }] = child;
      return pSegmentToThreePath(segments);
    });
  }

  // in case there is only one cluster
  // extract and return a 1-sized array
  const [, { segments }] = united.exportJSON({ asString: false });
  return [pSegmentToThreePath(segments)];
}

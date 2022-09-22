import {
  FrontSide,
  Group,
  Mesh,
  MeshBasicMaterial,
  ShapeBufferGeometry,
  PlaneGeometry,
  Shape,
  Vector2,
  Vector3,
} from 'three';
import { MeshLine, MeshLineMaterial } from 'three.meshline';
import Offset from 'polygon-offset';

import config from '@/config';
import Block from './block';
import { disposeObjectTree } from '../three-utils';

const meshLineGroupSize = 3;

// due to a weird bug on the Offset external lib
// I had to make the padding twice
// the first one to "correct" the data (with a null padding)
// the second one is the real padding operation
export function offsetSector(sector, size = 0.2) {
  const offset = new Offset();
  const points = offset.data(sector.points).padding(0);

  try {
    return offset.data(points).padding(size);
  } catch (err) {
    return [points];
  }
}

export default class Sector extends Block {
  constructor(map) {
    super(map, 'Sector');
  }

  _create() {
    this.createSectors('near');
    this.createSectors('medium');
    this.createSectors('far');
    this.resetRepaint();
  }

  _update() {
    if (this.map.data.hasToRepaintSectors) {
      this.group.children.forEach((child) => disposeObjectTree(child));
      this.group.children = [];

      this.createSectors('near');
      this.createSectors('medium');
      this.createSectors('far');
      this.refresh();

      this.resetRepaint();
    }
  }

  resetRepaint() {
    this.map.data.hasToRepaintSectors = false;
  }

  createSectors(distance) {
    const distances = {
      near: { near: 20, far: 80, offset: 0.15, line: 0.05, opacity: 0.05 },
      medium: { near: 80, far: 200, offset: 0.15, line: 0.1, opacity: 0.05 },
      far: { near: 200, far: this.map.maxZ, offset: 0.3, line: 0.2, opacity: 0.12 },
    };

    // sector lines and sector labels
    const group = new Group();
    group.name = `sector-${distance}`;
    Object.assign(group.userData, { near: distances[distance].near, far: distances[distance].far });

    this.map.data.sectors.forEach((sector) => {
      const colors = sector.owner ? this.colors[sector.owner] : this.colors.neutral;
      const material = sector.owner ? this.colors[sector.owner].material.darker : this.map.materials.lightGrey;

      offsetSector(sector, distances[distance].offset).forEach((polygon) => {
        const points = polygon.reduce((acc, [x, y]) => acc.concat([x, y, config.MAP.Z_SECTOR_NEAR]), []);
        points.push(points[0], points[1], points[2]);

        for (let i = meshLineGroupSize; i < points.length - meshLineGroupSize; i += meshLineGroupSize) {
          const lMaterial = new MeshLineMaterial({
            color: colors.hex.darker,
            transparent: true,
            lineWidth: distances[distance].line,
          });

          const geom = new MeshLine();
          geom.setPoints(points.slice(i - meshLineGroupSize, i + meshLineGroupSize));
          const line = new Mesh(geom, lMaterial);
          line.material.opacity = 0.5;
          group.add(line);
        }
      });

      offsetSector(sector, distances[distance].offset).forEach((polygon) => {
        const points = polygon.map(([x, y]) => new Vector2(x, y));
        const shape = new Shape(points);
        const geometry = new ShapeBufferGeometry(shape);
        const mesh = new Mesh(geometry, material.clone());
        mesh.position.setZ(config.MAP.Z_SECTOR_FAR);
        mesh.material.opacity = distances[distance].opacity;
        group.add(mesh);
      });

      if (distance === 'far') {
        const position = [sector.centroid[0], sector.centroid[1], config.MAP.Z_SECTOR_FAR_LABEL];
        const label = this.sectorLabel(sector.name, position, colors.hex.lighter, 1.5);
        label.gameObject = { type: 'sector', data: sector.id };

        group.add(label);
      }
    });

    this.group.add(group);
  }

  sectorLabel(message, position, color, size = 10) {
    const label = new Group();

    const material = new MeshBasicMaterial({ color, side: FrontSide });
    const shapes = this.map.fonts.nunito800.generateShapes(message.toUpperCase(), size);
    const textGeometry = new ShapeBufferGeometry(shapes);
    const textSize = new Vector3();
    textGeometry.computeBoundingBox();
    textGeometry.boundingBox.getSize(textSize);

    // center text to position
    const x = position[0] - (textGeometry.boundingBox.max.x / 2);
    const y = position[1] - (textGeometry.boundingBox.max.y / 2);
    const z = position[2];

    const textMesh = new Mesh(textGeometry, material);
    textMesh.position.set(x, y, z);
    textMesh.userData.hoverable = true;
    label.add(textMesh);

    const padding = 5;
    const rect = new PlaneGeometry(textSize.x + (2 * padding), textSize.y + (2 * padding), 32);
    const backgroundMesh = new Mesh(rect, this.map.materials.white.clone());
    backgroundMesh.position.set(x + (textSize.x / 2), y + (textSize.y / 2), z - 0.01);
    backgroundMesh.material.opacity = 0;
    backgroundMesh.userData.hoverable = true;
    label.add(backgroundMesh);

    return label;
  }
}

import {
  Group,
  Mesh,
  RingGeometry,
  Line,
  ShapeBufferGeometry,
  BufferGeometry,
  Vector3,
} from 'three';

import config from '@/config';
import Block from './block';

export default class Blackhole extends Block {
  constructor(map) {
    super(map, 'Blackhole');
  }

  _create() {
    this.createBlackolesNear();
    this.createBlackolesFar();
  }

  _update() {
    // pass
  }

  createBlackolesNear() {
    let group = this.getGroupByName('blackholes');
    const z = config.MAP.Z_BLACKHOLE;

    if (!group) {
      group = new Group();
      group.name = 'blackholes-near';
      Object.assign(group.userData, { near: 20, far: 200 });
    }

    // loop through all blackholes
    this.map.data.blackholes.forEach(({ radius, position, name }) => {
      const white = this.map.materials.white;
      const black = this.map.materials.black;

      // blackhole disks aesthetic
      const disks = [
        [0.0001, radius, black, 0.5, 0],
        [radius + 0.10, radius + 0.12, white, 0.10, 0.01],
        [radius - 0.06, radius - 0.10, white, 0.30, 0.01],
        [radius - 0.32, radius - 0.30, white, 0.26, 0.01],
        [radius - 0.52, radius - 0.50, white, 0.22, 0.01],
        [radius - 0.72, radius - 0.70, white, 0.18, 0.01],
        [radius - 0.92, radius - 0.90, white, 0.14, 0.01],
        [radius - 1.12, radius - 1.10, white, 0.10, 0.01],
        [radius - 1.32, radius - 1.30, white, 0.06, 0.01],
        [radius - 1.52, radius - 1.50, white, 0.03, 0.01],
        [0.0001, 1 * (radius / 4), black, 0.4, 0],
        [0.0001, 2 * (radius / 4), black, 0.4, 0],
        [0.0001, 3 * (radius / 4), black, 0.4, 0],
      ];

      disks.forEach(([inner, outer, material, opacity, zShift]) => {
        const disk = new RingGeometry(inner, outer, 128);
        const mesh = new Mesh(disk, material.clone());
        mesh.position.set(position.x, position.y, z + zShift);
        mesh.material.opacity = opacity;
        group.add(mesh);
      });

      // blackhole name
      const shape1 = this.map.fonts.nunito800.generateShapes(name.toUpperCase(), 0.4);
      const text1 = new ShapeBufferGeometry(shape1);
      const size1 = new Vector3();
      text1.computeBoundingBox();
      text1.boundingBox.getSize(size1);
      const mesh1 = new Mesh(text1, this.map.materials.white.clone());
      mesh1.position.set(position.x - (size1.x / 2), position.y - (size1.y / 2), z + 0.01);
      group.add(mesh1);

      const label = this.map.vm.$t('galaxy.map.blackhole').toUpperCase();
      const shape2 = this.map.fonts.nunito800.generateShapes(label, 0.2);
      const text2 = new ShapeBufferGeometry(shape2);
      const size2 = new Vector3();
      text2.computeBoundingBox();
      text2.boundingBox.getSize(size2);
      const mesh2 = new Mesh(text2, this.map.materials.white.clone());
      mesh2.position.set(position.x - (size1.x / 2), position.y + 0.35, z + 0.01);
      mesh2.material.opacity = 0.50;
      group.add(mesh2);

      // blackhole names aesthetic
      const points1 = [
        new Vector3(position.x - (size1.x / 2) + size2.x + 0.1, position.y + 0.45, z + 0.01),
        new Vector3(position.x - (size1.x / 2) + size2.x + 1.0, position.y + 0.45, z + 0.01),
      ];
      const geometry1 = new BufferGeometry().setFromPoints(points1);
      const line1 = new Line(geometry1, this.map.materials.white.clone());
      line1.material.opacity = 0.50;
      group.add(line1);

      const points2 = [
        new Vector3(position.x - (size1.x / 2) - 0.6, position.y - 0.4, z + 0.01),
        new Vector3(position.x - (size1.x / 2) + 0.4, position.y - 0.4, z + 0.01),
      ];
      const geometry2 = new BufferGeometry().setFromPoints(points2);
      const line2 = new Line(geometry2, this.map.materials.white.clone());
      line2.material.opacity = 0.50;
      group.add(line2);
    });

    this.group.add(group);
  }

  createBlackolesFar() {
    let group = this.getGroupByName('blackholes');
    const z = config.MAP.Z_BLACKHOLE;

    if (!group) {
      group = new Group();
      group.name = 'blackholes-far';
      Object.assign(group.userData, { near: 200, far: this.map.maxZ });
    }

    // loop through all blackholes
    this.map.data.blackholes.forEach(({ radius, position }) => {
      const white = this.map.materials.white;
      const black = this.map.materials.black;

      // blackhole disks aesthetic
      const disks = [
        [0.0001, radius, black, 1.0, 0],
        [radius - 0.06, radius - 0.20, white, 1.0, 0.01],
        [0.0001, 1 * (radius / 4), black, 0.6, 0],
        [0.0001, 2 * (radius / 4), black, 0.6, 0],
        [0.0001, 3 * (radius / 4), black, 0.6, 0],
      ];

      disks.forEach(([inner, outer, material, opacity, zShift]) => {
        const disk = new RingGeometry(inner, outer, 128);
        const mesh = new Mesh(disk, material.clone());
        mesh.position.set(position.x, position.y, z + zShift);
        mesh.material.opacity = opacity;
        group.add(mesh);
      });
    });

    this.group.add(group);
  }
}

import {
  MeshBasicMaterial,
  BufferGeometry,
  Line,
  Group,
  BufferAttribute,
} from 'three';

import Block from './block';

export default class Crosshair extends Block {
  constructor(map) {
    super(map, 'Crosshair');
  }

  _create() {
    // crosshair size
    const x = 0.4;
    const y = 0.2;

    const material = new MeshBasicMaterial({ color: 0x000000 });
    const geometry = new BufferGeometry();

    // crosshair
    const vertices = new Float32Array([
      0, y, 0,
      0, -y, 0,
      0, 0, 0,
      x, 0, 0,
      -x, 0, 0,
    ]);
    geometry.setAttribute('position', new BufferAttribute(vertices, 3));

    const crosshair = new Line(geometry, material);
    crosshair.position.set(0, 0, -10);

    // make it a child of camera
    this.map.camera.add(crosshair);
    this.map.scene.add(this.map.camera);

    // Block#update() calls ._create() until Block#group.children.length > 0, so we need to add something
    this.group.add(new Group());
  }

  onZ() { /* noop */ }
}

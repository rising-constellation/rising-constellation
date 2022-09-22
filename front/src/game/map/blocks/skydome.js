import {
 Group,
 LoadingManager,
} from 'three';

import { MTLLoader } from 'three/examples/jsm/loaders/MTLLoader';
import { OBJLoader } from 'three/examples/jsm/loaders/OBJLoader';

import Block from './block';

export default class Skydome extends Block {
  constructor(map) {
    super(map, 'Skydome');
  }

  _create() {
    // position is centered on the map
    const skyDomePosition = {
      x: this.map.size / 2,
      y: this.map.size / 2,
      z: -250,
    };
    const scale = 330;

    const skydomeGroup = new Group();
    Object.assign(skydomeGroup.userData, { near: -Infinity, far: Infinity });

    const onProgress = () => {};
    const onError = (err) => { throw err; };
    const manager = new LoadingManager();

    new MTLLoader(manager)
      .setMaterialOptions({ ignoreZeroRGBs: true })
      .setPath('./map/skydome/')
      .load('skybowl_001_LL.mtl', (materials) => {
        materials.preload();
        Object.entries(materials.materials).forEach(([, material]) => {
          material.alphaTest = 0;
          material.transparent = true;
          material.fog = false;
        });

        new OBJLoader(manager)
          .setMaterials(materials)
          .setPath('./map/skydome/')
          .load('skybowl_001_LL.obj', (sky) => {
            sky.rotateX(Math.PI / 2);
            sky.position.x = skyDomePosition.x;
            sky.position.y = skyDomePosition.y;
            sky.position.z = skyDomePosition.z;
            sky.scale.set(scale, scale, scale);
            sky.name = 'skydome';
            skydomeGroup.add(sky);
          }, onProgress, onError);
      });

    this.group.add(skydomeGroup);
  }

  _update() {
    this.log(`updating ${this.group.name}`);
  }
}

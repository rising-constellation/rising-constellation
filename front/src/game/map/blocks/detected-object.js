import config from '@/config';
import { Group } from 'three';
import Block from './block';

import { disposeObjectTree } from '../three-utils';

export default class DetectedObject extends Block {
  constructor(map) {
    super(map, 'DetectedObject');
  }

  _create() {
    this.createDetectedObjects();
    this.resetRepaint();
    this.refresh();
  }

  _update() {
    if (this.map.data.hasToRepaintDetectedObjects) {
      disposeObjectTree(this.getGroupByName('detected-objects'));
      this.group.children = this.group.children.filter((group) => group.name !== 'detected-objects');

      this.createDetectedObjects();
      this.resetRepaint();
      this.refresh();
    }
  }

  resetRepaint() {
    this.map.data.hasToRepaintDetectedObjects = false;
  }

  createDetectedObjects() {
    const detectedObjectsGroup = new Group();
    detectedObjectsGroup.name = 'detected-objects';

    Object.assign(detectedObjectsGroup.userData, { near: 20, far: 200 });

    this.map.data.detectedObjects.forEach(({ angle, position: { x, y }, faction }) => {
      const sprite = this.map.materials.sprites.characters[faction].character.clone();
      sprite.position.set(x, y, config.MAP.Z_CHARACTER_NEAR_SPRITE);
      sprite.material = sprite.material.clone();
      sprite.material.rotation = angle;

      detectedObjectsGroup.add(sprite);
    });

    this.group.add(detectedObjectsGroup);
  }
}

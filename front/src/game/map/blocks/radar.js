import {
  Group,
  Mesh,
  ShapePath,
  ShapeGeometry,
} from 'three';

import config from '@/config';
import store from '@/store';
import * as P from 'paper/dist/paper-core';
import {
  toPath, dashedOffsetContour,
} from '../floor-utils';

import { disposeObjectTree } from '../three-utils';

import Block from './block';

export default class Radar extends Block {
  constructor(map) {
    super(map, 'Radar');

    P.install(this);
    P.setup([1000, 1000]);
  }

  async _create() {
    this.createRadar();
    this.resetRepaint();
    this.refresh();
  }

  async _update() {
    if (this.map.data.hasToRepaintRadars) {
      disposeObjectTree(this.getGroupByName('radar'));
      this.group.children = this.group.children.filter((group) => group.name !== 'radar');

      this.createRadar();
      this.resetRepaint();
      this.refresh();
    }
  }

  resetRepaint() {
    this.map.data.hasToRepaintRadars = false;
  }

  onZ(z) {
    Block.prototype.onZ.call(this, z);
  }

  createRadar() {
    const radarGroup = new Group();
    radarGroup.name = 'radar';
    Object.assign(radarGroup.userData, { near: 20, far: 200 });

    if (store.state.game.mapOptions.mode === 'radar') {
      const radarsByFactions = Object.values(this.map.data.radars).reduce((acc, radar) => {
        (acc[radar.faction_id] = acc[radar.faction_id] || []).push(radar.disk);
        return acc;
      }, {});

      Object.entries(radarsByFactions).forEach(([factionId, radars]) => {
        const faction = store.state.game.victory.factions.find((f) => f.id === parseInt(factionId, 10));
        const ownFaction = faction.id === store.state.game.player.faction_id;
        const colors = this.colors[faction.key];

        // draw lines max radar
        if (ownFaction) {
          toPath(radars).forEach((path) => {
            const length = path.getLength();
            const points = length > 30 ? length / 3 : 10;
            const dash = 2 / length;
            const vectors = path.getPoints(points);

            const rd1Opts = {
              color: colors.hex.normal,
              transparent: true,
              lineWidth: 0.02,
              dashArray: dash,
              dashRatio: 0.2,
              dashOffset: 0 };

            dashedOffsetContour(vectors, 0, config.MAP.Z_FLOOR, rd1Opts)
              .then((radarDashed1) => {
                radarGroup.add(radarDashed1);
              });

            const rd2Opts = {
              color: colors.hex.normal,
              transparent: true,
              lineWidth: 0.03,
              dashArray: dash,
              dashRatio: 0.95,
              dashOffset: 0.88 * dash };
            dashedOffsetContour(vectors, 0, config.MAP.Z_FLOOR, rd2Opts)
              .then((radarDashed2) => {
                radarGroup.add(radarDashed2);
              });

            const rlOpts = { color: colors.hex.darker, lineWidth: 0.025 };
            dashedOffsetContour(vectors, 0.15, config.MAP.Z_FLOOR, rlOpts)
              .then((radarLine) => {
                radarGroup.add(radarLine);
              });

            const shape = new ShapePath();
            shape.subPaths = [path];
            const geometry = new ShapeGeometry(shape.toShapes());
            const radar = new Mesh(geometry, colors.material.normal.clone());
            radar.material.opacity = 0.12;
            radar.position.set(0, 0, config.MAP.Z_FLOOR);
            radarGroup.add(radar);
          });
        } else {
          toPath(radars).forEach((path) => {
            const length = path.getLength();
            const points = length > 30 ? length / 3 : 10;
            const vectors = path.getPoints(points);
            const options = { color: colors.hex.normal, lineWidth: 0.025 };

            dashedOffsetContour(vectors, 0, config.MAP.Z_FLOOR, options)
              .then((radarLine) => {
                radarGroup.add(radarLine);
              });
          });
        }
      });
    }

    this.group.add(radarGroup);
  }
}

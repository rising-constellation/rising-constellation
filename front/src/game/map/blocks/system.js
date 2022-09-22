import {
  Group,
  Mesh,
  RingGeometry,
  ShapeBufferGeometry,
  PlaneGeometry,
  Vector3,
} from 'three';

import config from '@/config';
import store from '@/store';
import { disposeObjectTree } from '../three-utils';

import Block from './block';

const nearHoverDisk = new RingGeometry(0.0001, 0.5, 32);
const farHoverDisk = new RingGeometry(0.0001, 2, 32);

const modes = ['population', 'visibility', 'radar'];

export default class System extends Block {
  constructor(map) {
    super(map, 'System');
  }

  _create() {
    this.mode = store.state.game.mapOptions.mode;

    this.groups = modes.reduce((groups, modeName) => {
      groups[modeName] = this.group.clone();
      return groups;
    }, {});

    this.group = this.groups[this.mode];
    modes.forEach((modeName) => {
      if (modeName !== this.mode) {
        this.map.scene.add(this.groups[modeName]);
        this.groups[modeName].visible = false;
      }
    });

    this.createSystems(true);
    this.resetRepaint();
  }

  _update() {
    const mode = store.state.game.mapOptions.mode;

    if (this.mode !== mode) {
      this.mode = mode;
      this.group = this.groups[mode];
      modes.forEach((modeName) => {
        if (modeName === mode) {
          this.groups[modeName].visible = true;
        } else {
          this.groups[modeName].visible = false;
        }
      });

      this.refresh();
    }

    if (this.map.data.systemsToRepaint.size > 0) {
      this.createSystems();
      this.refresh();
      this.resetRepaint();
    }
  }

  resetRepaint() {
    this.map.data.systemsToRepaint.clear();
  }

  createSystems(initial = false) {
    modes.forEach((mode) => {
      let sng = this.groups[mode].children.find((group) => group.name === 'systems-near');
      let sfg = this.groups[mode].children.find((group) => group.name === 'systems-far');

      if (!sng) {
        sng = new Group();
        sng.name = 'systems-near';
        Object.assign(sng.userData, { near: 20, far: 200 });
      }

      if (!sfg) {
        sfg = new Group();
        sfg.name = 'systems-far';
        Object.assign(sfg.userData, { near: 200, far: this.map.maxZ });
      }

      // precompute some geometries
      const geometries = this.map.gameData.stellar_system.reduce((acc, system) => {
        acc[system.key] = new RingGeometry(0.0002, 0.2 * system.display_size_factor, 32);
        return acc;
      }, {});

      // loop through all systems
      this.map.data.systems.forEach((system) => {
        const name = `system-${system.id}`;

        // only if tutorial mode, change neutral dominion in sector 2 with
        // fake myrmezir dominion
        if (store.state.game.galaxy.tutorial_id
          && system.status === 'inhabited_neutral' && system.sector_id === 2) {
          system.faction = 'myrmezir';
          system.owner = 'Myrmezir';
          system.status = 'inhabited_dominion';
        }

        // check need to create or recreate the object
        if (initial || this.map.data.systemsToRepaint.has(system.id)) {
          if (!initial) {
            disposeObjectTree(sng.children.find((g) => g.userData.name === name));
            disposeObjectTree(sfg.children.find((g) => g.userData.name === name));
          }

          // create near system
          const sn = this.nearSystem(system, name, mode);
          sng.add(sn);

          // create far system
          const sf = this.farSystem(system, name, geometries);
          sfg.add(sf);
        }
      });

      this.groups[mode].add(sng);
      this.groups[mode].add(sfg);
    });
  }

  nearSystem(system, name, mode) {
    const sn = new Group();
    sn.name = 'system-near';
    sn.userData.name = name;

    // affect game object here in order to allow click
    sn.gameObject = { type: 'system', data: system };

    // system info
    const faction = system.faction ? system.faction : 'neutral';
    const colors = this.colors[faction];
    const visibility = system.visibility === 0 ? 'unknown' : 'known';
    const habitability = ['uninhabitable', 'uninhabited'].includes(system.status) ? 'uninhabited' : 'inhabited';
    const populationClass = store.state.game.data.population_class.find((pc) => pc.key === system.class);

    // hover disk
    const hover = new Mesh(nearHoverDisk, this.map.materials.white.clone());
    hover.visible = false;
    hover.position.set(system.position.x, system.position.y, config.MAP.Z_SYSTEM_NEAR_STAR - 0.01);
    hover.material.opacity = 0.12;
    hover.userData.hoverable = true;
    hover.userData.showOnHover = true;
    sn.add(hover);

    // system sprite
    const base = this.map.materials.sprites.systems[system.type][habitability][visibility].clone();
    base.position.set(system.position.x, system.position.y, config.MAP.Z_SYSTEM_NEAR_STAR);
    base.userData.hoverable = true;
    sn.add(base);

    if (['inhabited_dominion', 'inhabited_player'].includes(system.status)) {
      const owner = system.status === 'inhabited_dominion' ? 'dominion' : 'player';
      const type = this.map.materials.sprites.systems[system.type].factions[faction][owner][visibility].clone();
      type.position.set(system.position.x, system.position.y, config.MAP.Z_SYSTEM_NEAR_STAR + 0.01);
      sn.add(type);
    }

    const ownSystem = this.map.playerSystems.find((sys) => sys.id === system.id);
    const ownDominion = this.map.playerDominions.find((sys) => sys.id === system.id);
    const systemName = ['inhabited_neutral', 'inhabited_dominion'].includes(system.status)
      ? `${system.name}*` : system.name;

    if ((ownDominion || ownSystem) || (!system.owner && system.visibility === 0)) {
      const labelVisibility = !!system.owner;

      sn.add(this.createSystemLabel(system, { x: 0.46, y: -0.12 }, systemName, labelVisibility, {
        fontSize: 0.25,
        textColor: this.map.materials.black,
        bckColor: colors.material.darker,
        zIndex: config.MAP.Z_SYSTEM_NEAR_LABEL,
      }));
    } else {
      sn.add(this.createSystemLabel(system, { x: 0.46, y: 0.08 }, systemName, false, {
        fontSize: 0.25,
        textColor: this.map.materials.black,
        bckColor: colors.material.darker,
        zIndex: config.MAP.Z_SYSTEM_NEAR_LABEL,
      }));

      if (system.owner) {
        sn.add(this.createSystemLabel(system, { x: 0.46, y: -0.30 }, system.owner, false, {
          fontSize: 0.18,
          textColor: this.map.materials.black,
          bckColor: colors.material.lighter,
          zIndex: config.MAP.Z_SYSTEM_NEAR_LABEL,
        }));
      } else {
        const label = system.score === 0
          ? this.map.vm.$t('galaxy.map.uninhabitable')
          : `${system.score} ${this.map.vm.$tc('galaxy.map.orbit', system.score)}`;

        sn.add(this.createSystemLabel(system, { x: 0.46, y: -0.30 }, label, false, {
          fontSize: 0.18,
          textColor: this.map.materials.black,
          bckColor: colors.material.lighter,
          zIndex: config.MAP.Z_SYSTEM_NEAR_LABEL,
        }));
      }
    }

    if (mode === 'visibility') {
      if (system.visibility > 0) {
        sn.add(this.createSystemLabel(system, { x: 0.26, y: 0.26 }, `${system.visibility}`, true, {
          fontSize: 0.15,
          textColor: this.map.materials.white,
          zIndex: config.MAP.Z_SYSTEM_NEAR_LABEL,
        }));

        // size-visibility related circle
        const disk = new RingGeometry(0.0001, 0.25 * system.visibility, 128);
        const mesh = new Mesh(disk, colors.material.normal.clone());
        mesh.position.set(system.position.x, system.position.y, config.MAP.Z_SYSTEM_NEAR_STAR - 0.01);
        mesh.material.opacity = 0.25;
        sn.add(mesh);
      }
    } else if (mode === 'population') {
      if (populationClass && system.visibility > 2) {
        sn.add(this.createSystemLabel(system, { x: 0.26, y: 0.26 }, `${populationClass.points}`, true, {
          fontSize: 0.15,
          textColor: this.map.materials.white,
          zIndex: config.MAP.Z_SYSTEM_NEAR_LABEL,
        }));

        // size-class related circle
        const disk = new RingGeometry(0.0001, 0.15 * populationClass.points, 128);
        const mesh = new Mesh(disk, colors.material.normal.clone());
        mesh.position.set(system.position.x, system.position.y, config.MAP.Z_SYSTEM_NEAR_STAR - 0.01);
        mesh.material.opacity = 0.25;
        sn.add(mesh);
      }
    }

    return sn;
  }

  farSystem(system, name, geometries) {
    const sf = new Group();
    sf.name = 'system-far';
    sf.userData.name = name;

    const geometry = geometries[system.type];
    const material = system.faction
      ? this.colors[system.faction].material.lighter
      : this.map.materials.white;
    const opacity = system.visibility === 0
      ? 0.5 : 1.0;

    const circle = new Mesh(geometry, material.clone());
    circle.position.set(system.position.x, system.position.y, config.MAP.Z_SYSTEM_FAR_STAR);
    circle.material.opacity = opacity;
    sf.add(circle);

    const ownSystem = this.map.playerSystems.find((sys) => sys.id === system.id);
    const ownDominion = this.map.playerDominions.find((sys) => sys.id === system.id);

    if (ownSystem || ownDominion) {
      const playerFaction = store.state.game.player.faction;
      const own = new Mesh(farHoverDisk, this.colors[playerFaction].material.normal.clone());
      own.position.set(system.position.x, system.position.y, config.MAP.Z_SYSTEM_FAR_OWN);
      own.material.opacity = 0.20;
      sf.add(own);
    }

    return sf;
  }

  createSystemLabel(system, shift, text, isVisible, options) {
    const gameObject = { type: 'system', data: system };
    const position = {
      x: system.position.x + shift.x,
      y: system.position.y + shift.y,
    };

    return this.createLabel(position, text, isVisible, gameObject, options);
  }

  createLabel(position, text, isVisible, gameObject, options) {
    const label = new Group();
    label.gameObject = gameObject;
    label.userData.hoverable = true;

    if (!isVisible) {
      label.visible = false;
      label.userData.showOnHover = true;
    }

    const shape = this.map.fonts.nunito800.generateShapes(text.toUpperCase(), options.fontSize);
    const textGeometry = new ShapeBufferGeometry(shape);
    const textSize = new Vector3();
    textGeometry.computeBoundingBox();
    textGeometry.boundingBox.getSize(textSize);

    const x = position.x;
    const y = position.y;
    const z = options.zIndex;

    const textMesh = new Mesh(textGeometry, options.textColor);
    textMesh.position.set(x, y, z);
    label.add(textMesh);

    if (options.bckColor) {
      const padding = 0.1;
      const rect = new PlaneGeometry(textSize.x + (2 * padding), textSize.y + (2 * padding), 32);
      const backgroundMesh = new Mesh(rect, options.bckColor);
      backgroundMesh.position.set(x + (textSize.x / 2), y + (textSize.y / 2), z - 0.01);
      label.add(backgroundMesh);
    }

    return label;
  }
}

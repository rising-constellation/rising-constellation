import {
  AmbientLight,
  Raycaster,
  Vector2,
  Vector3,
  TextureLoader,
} from 'three';

import { MapControls } from 'three/examples/jsm/controls/OrbitControls';

import Stats from 'stats-js';
import TWEEN from '@tweenjs/tween.js';
import store from '@/store';
import config from '@/config';
import { loadFonts, materialsFactory } from './three-utils';
import { Radar, Sector, System, Blackhole, Skydome, Character, DetectedObject } from './blocks';

let currentlyHoveredObject;

export default class Map {
  constructor({ scene, camera, renderer, $root, vm, data, fov, $socket, $toasted }) {
    this.isDev = config.MODE === 'development';
    this.log = this.isDev ? console.log : () => {};
    this.scene = scene;
    this.camera = camera;
    this.camera.updateProjectionMatrix();

    this.$root = $root;
    this.$socket = $socket;
    this.$toasted = $toasted;
    this.vm = vm;
    this.data = data;
    this.renderer = renderer;
    this.requestAnimationFrame = null;
    this.inSystem = null;
    this.moving = false;
    this.hovercaster = new Raycaster();
    this.textureLoader = new TextureLoader();
    this.windowHeight = 100;
    this.windowWidth = 100;

    this.onWindowResize();
    this.controls = new MapControls(this.camera, renderer.domElement);
    this.controls.enableKeys = true;
    this.controls.keyPanSpeed = 30;
    this.controls.enableDamping = true;
    this.controls.dampingFactor = 0.2;

    // compute map dimensions
    this.size = store.state.game.galaxy.size;
    const halfSize = this.size / 2;

    const boundaries = [{ x: Infinity, y: Infinity }, { x: -Infinity, y: -Infinity }];
    this.data.systems.forEach(({ position: { x, y } }) => {
      if (x < boundaries[0].x) boundaries[0].x = x;
      if (x > boundaries[1].x) boundaries[1].x = x;
      if (y < boundaries[0].y) boundaries[0].y = y;
      if (y > boundaries[1].y) boundaries[1].y = y;
    });

    /*
    Trigonometry: tan(⍺) = opposite/adjacent
      fov/2 = ⍺
             /|
            / | adjacent = z
           /  |
          /___|
      opposite = halfSize
    */
    this.maxZ = halfSize / Math.tan((fov / 2) * (Math.PI / 180));
    this.maxZ = Math.max(this.maxZ, 330);
    this.minZ = 30;
    this.initialZ = config.MAP.Z_DEFAULT;
    // last Z, to be able to get back to it after a context switch or a move
    this.lastZ = config.MAP.Z_DEFAULT;
    // in a system, Z at which the user is 'locked'
    this.systemZ = 4;

    // constrain pan to boundaries
    const minPan = new Vector3(boundaries[0].x, boundaries[0].y, 0);
    const maxPan = new Vector3(boundaries[1].x, boundaries[1].y, 20);
    const v = new Vector3();
    this.constrainPan = () => {
      v.copy(this.controls.target);
      this.controls.target.clamp(minPan, maxPan);
      v.sub(this.controls.target);
      this.camera.position.sub(v);
    };
    this.controls.addEventListener('change', this.constrainPan.bind(this));

    // listen to map position update
    this.controls.addEventListener('end', () => {
      store.commit('game/updateMapPosition', {
        x: Math.round(this.camera.position.x),
        y: Math.round(this.camera.position.y),
        z: Math.round(this.camera.position.z),
      });
    });

    // only enable for tests
    this.controls.screenSpacePanning = true;
    this.controls.enableRotate = this.isDev;
    this.controls.addEventListener('change', this.onControlChange.bind(this));

    this.mouse = new Vector2(1, 1);
    this.mouseLastPosition = {};
    document.addEventListener('mousemove', this.onMouseMove.bind(this), false);
    this.renderer.domElement.addEventListener('pointerdown', this.onMouseDown.bind(this), true);
    this.renderer.domElement.addEventListener('pointerup', this.onMouseUp.bind(this), true);
    this.renderer.domElement.addEventListener('contextmenu', this.onMouseUp.bind(this), true);

    const ambientLight = new AmbientLight(0xffffff);
    this.scene.add(ambientLight);

    // initial camera position
    const { x, y } = this.playerSystems.length ? this.playerSystems[0].position : { x: halfSize, y: halfSize };
    this.setCameraPosition(x, y, this.initialZ);
    this.camera.zoom = 1;
    this.blocks = [];
    this.materials = materialsFactory(this);

    // monotonic time offset
    this.timeOffset = store.state.game.time.now_monotonic - Date.now();

    // events
    this.$root.$on('map:centerToSystem', (systemId) => {
      this.centerToSystem(systemId, config.MAP.Z_DEFAULT, 600);
    });

    this.$root.$on('map:centerToCharacter', (character) => {
      if (character.system) {
        this.centerToSystem(character.system, config.MAP.Z_DEFAULT, 600);
      } else {
        const speed = store.state.game.data.speed.find((i) => i.key === store.state.game.time.speed);
        const speedFactor = speed.factor;

        const action = character.actions.queue[0];
        const p1 = action.data.source_position;
        const p2 = action.data.target_position;

        const elapsed = this.timeOffset + Date.now() - action.started_at;
        const progress = (speedFactor * elapsed) / (180000 * action.total_time);

        const pX = p1.x + progress * (p2.x - p1.x);
        const pY = p1.y + progress * (p2.y - p1.y);

        this.move(pX, pY, config.MAP.Z_DEFAULT, 600, 'centerToCharacter');
      }
    });

    this.$root.$on('map:hidePath', () => {
      const character = this.getBlockByName('Character');
      character.hideHoverPath();
    });

    this.$root.$on('map:addAction', (action, payload) => {
      this.addCharacterAction(action, payload);
    });
  }

  get playerSystems() {
    return store.state.game.player.stellar_systems;
  }

  get playerDominions() {
    return store.state.game.player.dominions;
  }

  get gameData() {
    return store.state.game.data;
  }

  async init() {
    // setup stats for dev only
    let stats = { begin() { }, end() { } };
    if (this.isDev) {
      stats = new Stats();
      stats.setMode(0);
      stats.domElement.setAttribute('id', 'threejs-stats');
      document.body.appendChild(stats.domElement);
    }

    this.fonts = await loadFonts();

    this.sceneInit();

    this.mapUpdate = true;
    const animate = () => {
      // always call this, otherwise tweens don't finish
      TWEEN.update();

      // don't update the map while we're in a system because it's hidden behind
      if (!this.mapUpdate) {
        this.requestAnimationFrame = requestAnimationFrame(animate);
        return;
      }

      stats.begin();
      this.controls.update();
      const { z } = this.camera.position;
      this.blocks.forEach((block) => {
        // block.update() is async but we don't want to wait for it to be done!
        block.update();
        block.animationCallbacks.forEach(({ far, near, cb }) => {
          if (z < far && z >= near) {
            cb();
          }
        });
      });

      this.renderer.render(this.scene, this.camera);
      stats.end();

      this.requestAnimationFrame = requestAnimationFrame(animate);
    };

    animate();
  }

  destroy() {
    if (this.isDev) {
      const stats = document.getElementById('threejs-stats');
      stats.parentNode.removeChild(stats);
    }

    this.unbindEvents();
  }

  bindEvents() {
    setTimeout(() => { this.onWindowResize(); }, 0);
    this.$root.$on('enterSystem', (system) => { this.enterSystem(system); });
    this.$root.$on('exitSystem', () => { this.exitSystem(); });
    window.addEventListener('resize', this.onWindowResize.bind(this), false);
  }

  unbindEvents() {
    cancelAnimationFrame(this.requestAnimationFrame);
    window.removeEventListener('resize', this.onWindowResize);
    document.removeEventListener('change', this.onControlChange);
    document.removeEventListener('mousemove', this.onMouseMove);
    this.renderer.domElement.removeEventListener('pointerdown', this.onMouseDown);
    this.renderer.domElement.removeEventListener('pointerup', this.onMouseUp);
    this.renderer.domElement.removeEventListener('contextmenu', this.onMouseUp);
    this.controls.removeEventListener('change', this.constrainPan);
  }

  // EVENT LISTENERS
  onMouseDown(event) {
    this.onClick(event, 'down');
  }

  onMouseUp(event) {
    this.onClick(event, 'up');
  }

  onClick(event, type) {
    let button;
    switch (event.button) {
      case 1: button = 'middle'; break;
      case 2: button = 'right'; break;
      default: button = 'left'; break;
    }

    if (event.ctrlKey && button === 'left') {
      button = 'right';
    }

    if (type === 'down') {
      this.mouseLastPosition = { x: event.clientX, y: event.clientY };
    }

    if (type === 'up' && !this.inSystem) {
      if (currentlyHoveredObject) {
        const clickedObject = currentlyHoveredObject.gameObject;

        if (clickedObject.type === 'system') {
          const system = clickedObject.data;

          if (button === 'left') {
            store.dispatch('game/openSystem', { vm: this.vm, id: system.id });
          } else {
            this.addCharacterAction('jump', { system });
          }
        } else if (clickedObject.type === 'character') {
          const characterId = clickedObject.data;

          if (button === 'left') {
            store.dispatch('game/selectCharacter', { vm: this.vm, id: characterId });
          }
        }
      } else if (button === 'left') {
        if (this.mouseLastPosition.x === event.clientX && this.mouseLastPosition.y === event.clientY) {
          store.dispatch('game/unselectCharacter');
        }
      }

      this.mouseLastPosition = {};
    }
  }

  onWindowResize() {
    this.windowHeight = window.innerHeight;
    this.windowWidth = window.innerWidth;
    this.camera.aspect = this.windowWidth / this.windowHeight;
    this.camera.updateProjectionMatrix();

    this.renderer.setSize(this.windowWidth, this.windowHeight);
  }

  onControlChange() {
    if (this.moving) return;
    if (this.camera.zoom !== 1) {
      // to be on the safe side
      this.camera.zoom = 1;
    }

    const { position } = this.camera;
    if (position.z > this.maxZ) {
      this.setCameraPosition(position.x, position.y, this.maxZ);
    } else if (position.z < this.minZ) {
      this.setCameraPosition(position.x, position.y, this.minZ);
    }

    // in system: lock camera
    if (this.inSystem) {
      const { x, y } = this.inSystem.position;
      this.setCameraPosition(x, y, this.systemZ);
    }

    this.onZ(this.camera.position.z);
  }

  onZ(z) {
    this.blocks.forEach((block) => block.onZ(z));
  }

  onMouseMove(event) {
    event.preventDefault();

    // hover system
    if (!this.inSystem) {
      this.mouse.x = (event.clientX / this.windowWidth) * 2 - 1;
      this.mouse.y = -(event.clientY / this.windowHeight) * 2 + 1;
      this.hovercaster.setFromCamera(this.mouse, this.camera);

      // we can "generically" use hover
      const types = [
        { block: 'System', group: 'systems-near' },
        { block: 'Character', group: 'characters-on-map' },
        { block: 'Character', group: 'character-names-on-map' },
        { block: 'Sector', group: 'sector-far' },
      ];

      for (let i = 0; i < types.length; i += 1) {
        const type = types[i];
        const block = this.getBlockByName(type.block);
        if (!block) {
          continue;
        }

        if (type.block === 'Sector' && block.shown !== type.group) {
          break;
        }

        if (type.block === 'System' && currentlyHoveredObject) {
          // something is already hovered
          const intersection = this.hovercaster
            .intersectObjects([currentlyHoveredObject, ...currentlyHoveredObject.children], true);

          // see if it's still hovered or if one of its children is hovered
          if (intersection.length) {
            if (intersection[0].object.parent.id === currentlyHoveredObject.id) {
              break;
            }

            if (intersection[0]?.object?.parent?.gameObject) {
              currentlyHoveredObject = intersection[0].object.parent;
              break;
            }
          }
        }

        if (block) {
          const groups = block.getGroupByName(type.group).children;
          const intersection = this.hovercaster
            .intersectObjects(groups, true)
            .filter(({ object }) => object.userData?.hoverable);

          if (intersection.length > 0) {
            const intersecting = 0;
            const { object: intersectedObject } = intersection[intersecting];
            // We intersected a single object, we want the hover to effect the whole system,
            // not just the hovered ring or child-object.
            // Search in intersected object's parents the closer 'hoverable object'.
            let hoveredGroup = intersectedObject;

            while (hoveredGroup && !('gameObject' in hoveredGroup)) {
              hoveredGroup = hoveredGroup.parent;
            }

            const stillHovering = currentlyHoveredObject && (hoveredGroup.id === currentlyHoveredObject.id);

            if (!hoveredGroup) {
              this.hideHover();
            } else if (!stillHovering) {
              if (hoveredGroup.gameObject.type === 'sector') {
                store.commit('game/addMapOverlay', hoveredGroup.gameObject);
              }

              this.hideHover();
              this.showHover(hoveredGroup, type.block);
              break;
            } else {
              break;
            }
          } else {
            this.hideHover();
          }
        }
      }
    }
  }

  sceneInit() {
    const initialBlocks = [
      // new Crosshair(this),
      new Skydome(this),
      new Blackhole(this),
      new Radar(this),
      new DetectedObject(this),
      new Sector(this),
      new System(this),
      new Character(this),
    ];

    Promise.all(initialBlocks.map((block) => {
      const p = block.update({}).then((_) => {
        block.group.children.forEach((group) => { group.visible = false; });
        this.blocks.push(block);
        this.scene.add(block.group);
      });
      return p;
    }));
  }

  addCharacterAction(action, metadata = {}) {
    if (!store.state.game.selectedCharacter) {
      return;
    }

    const { character, system } = metadata;
    const characterBlock = this.getBlockByName('Character');

    const actions = [];
    let virtualPosition = store.state.game.selectedCharacter.actions.virtual_position;
    const characterId = store.state.game.selectedCharacter.id;
    const itinerary = characterBlock.computePath(virtualPosition, system.id);

    if (itinerary.length) {
      actions.push(...itinerary.map((a) => ({
        type: 'jump',
        data: { source: a.source, target: a.target },
      })));

      virtualPosition = actions[actions.length - 1].data.target;
    }

    if (['fight', 'sabotage', 'assassination', 'conversion'].includes(action)) {
      actions.push({
        type: action,
        data: {
          target: virtualPosition,
          target_character: character,
        },
      });
    }

    if (['colonization', 'conquest', 'raid', 'loot', 'infiltrate', 'make_dominion',
         'encourage_hate'].includes(action)) {
      actions.push({ type: action, data: { target: virtualPosition } });
    }

    this.$socket.player.push('add_character_actions', {
      character_id: characterId,
      actions,
    }).receive('error', (err) => {
      this.$toastError(err.reason);
    });
  }

  showHover(hoveredGroup, type) {
    currentlyHoveredObject = hoveredGroup;
    hoveredGroup.children
      .filter((obj) => obj.userData.showOnHover === true)
      .forEach((obj) => {
        obj.visible = true;
      });

    if (type === 'System' && Character.canHoverPath()) {
      const character = this.getBlockByName('Character');
      character.hoverPathTo(hoveredGroup.gameObject.data);
    }
  }

  hideHover() {
    if (currentlyHoveredObject) {
      if (currentlyHoveredObject.gameObject.type === 'sector') {
        store.commit('game/clearMapOverlay');
      }

      let objectsToHide = currentlyHoveredObject.children;
      if (!currentlyHoveredObject.name && currentlyHoveredObject.parent) {
        // the hovered object is a system label, parent is system, we want to hide the system hover
        objectsToHide = currentlyHoveredObject.parent.children;
      }
      objectsToHide
        .filter((obj) => obj.userData.showOnHover === true)
        .forEach((obj) => {
          obj.visible = false;
        });

      currentlyHoveredObject = undefined;

      const character = this.getBlockByName('Character');
      character.hideHoverPath();
    }
  }

  centerToSystem(systemId, z, time) {
    const system = this.data.systems.find((s) => s.id === systemId);

    if (system) {
      this.move(system.position.x, system.position.y, z, time, 'centerToSystem');
    }
  }

  setCameraPosition(x, y, z = this.camera.position.z) {
    this.camera.position.set(x, y, z);
    this.camera.lookAt(new Vector3(x, y, 0));
    this.controls.target = new Vector3(x, y, 0);
  }

  async move(x, y, z = this.camera.position.z, time, reason) {
    if (this.moving) {
      return Promise.resolve();
    }

    this.moving = reason;

    if (!time) {
      this.setCameraPosition(x, y, z);
      this.moving = false;
      return Promise.resolve();
    }

    return new Promise((resolve) => {
      new TWEEN.Tween(this.camera.position)
        .to({ x, y, z }, time)
        .easing(TWEEN.Easing.Cubic.InOut)
        .onComplete(() => {
          this.moving = false;
          resolve();
        })
        .onUpdate((position) => {
          // eslint-disable-next-line no-shadow
          const { x, y, z } = position;

          this.camera.lookAt(new Vector3(x, y, 0));
          this.controls.target = new Vector3(x, y, 0);
          this.onZ(z);
        })
        .start();
    });
  }

  moveRel(xDelta, yDelta) {
    const pos = this.camera.position;
    this.setCameraPosition(pos.x + xDelta, pos.y + yDelta);
  }

  enterSystem(system) {
    this.inSystem = system;

    if (this.camera.position.z !== this.systemZ) {
      this.lastZ = this.camera.position.z;
    }

    const systemPosition = system.position;
    const moveDuration = 500;

    this.vm.$ambiance.sound('system-open');
    this.move(systemPosition.x, systemPosition.y, this.systemZ, moveDuration, 'enterSystem');

    setTimeout(() => {
      store.commit('game/finishSystemTransition');

      if (this.mapUpdate) {
        this.mapUpdate = false;
      }
    }, moveDuration);
  }

  exitSystem() {
    const backToZ = this.lastZ || this.initialZ;

    this.mapUpdate = true;
    this.inSystem = null;
    this.lastZ = null;

    this.vm.$ambiance.sound('system-close');
    this.move(this.camera.position.x, this.camera.position.y, backToZ, 500, 'exitSystem');
  }

  getBlockByName(name) {
    return this.blocks.find((block) => block.group.name === name);
  }
}

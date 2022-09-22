import {
  BufferGeometry,
  RingGeometry,
  Group,
  Line,
  LineBasicMaterial,
  Mesh,
  Vector3,
  ShapeBufferGeometry,
  PlaneGeometry,
} from 'three';

import { MeshLine, MeshLineMaterial } from 'three.meshline';
import path from 'ngraph.path';
import createGraph from 'ngraph.graph';

import config from '@/config';
import store from '@/store';
import Block from './block';
import { disposeObject, disposeObjectTree } from '../three-utils';

function arrayToPoints(xs, z = 0) {
  return xs.map(([x, y]) => new Vector3(x, y, z));
}

function shortenLine(p1, p2, size) {
  const _p1 = p1;
  const _p2 = p2;

  const dx = _p2.x - _p1.x;
  const dy = _p2.y - _p1.y;
  const length = Math.sqrt(dx * dx + dy * dy);
  const scale = (length - size) / length;

  p2.x = _p1.x + (dx * scale);
  p2.y = _p1.y + (dy * scale);

  p1.x = _p2.x + ((_p1.x - _p2.x) * scale);
  p1.y = _p2.y + ((_p1.y - _p2.y) * scale);

  return { p1, p2, length };
}

const meshLineMaterialsByFaction = {};

export default class Character extends Block {
  constructor(map) {
    super(map, 'Character');
    // cache of all currently moving character paths, to update lines only when they change
    this.coordsText = '';
    this.pathfinder = this.createPathFinder();
    // We need to display and move character names and we want to only instanciate the text mesh once.
    // This object is a cache `character.name => mesh`
    this.names = {};

    // cache some geometries or meshes
    const hoverDisk = new RingGeometry(0.0001, 0.6, 32);

    this.cache = {
      hoverMesh: new Mesh(hoverDisk, this.map.materials.white012),
    };
  }

  _create() {
    const displayRange = { near: 20, far: 200 };

    const hoverGroup = new Group();
    hoverGroup.name = 'hover-path';
    Object.assign(hoverGroup.userData, displayRange);

    const material = new LineBasicMaterial({ color: 0xffffff, opacity: 0.25, transparent: true });
    // For the hover we create a line with a geometry that has no points.
    // We will modify this geometry to show paths instead of creating
    // a new line or new geometry.
    const points = arrayToPoints([]);
    const geometry = new BufferGeometry().setFromPoints(points);
    const line = new Line(geometry, material);
    this.line = line;
    hoverGroup.add(line);
    this.group.add(hoverGroup);

    // lines showing planned moves
    const moveGroup = new Group();
    moveGroup.name = 'moving-characters';
    Object.assign(moveGroup.userData, displayRange);
    this.group.add(moveGroup);

    // character names
    const namesGroup = new Group();
    namesGroup.name = 'character-names-on-map';
    Object.assign(namesGroup.userData, displayRange);
    this.group.add(namesGroup);

    // current position of characters on their path
    const characterGroup = new Group();
    characterGroup.name = 'characters-on-map';
    Object.assign(characterGroup.userData, displayRange);
    this.group.add(characterGroup);
  }

  _update() {
    this.showMovingCharacters();
  }

  showMovingCharacters() {
    const allCoords = [];
    const characters = store.state.game.player.characters
      .reduce((queues, c) => {
        if (c.status !== 'on_board') {
          return queues;
        }

        const queue = c.actions.queue
          .filter((q) => q.type === 'jump')
          .map((q) => {
            const sourceInfo = this.map.data.systems.find((s) => s.id === q.data.source);
            const targetInfo = this.map.data.systems.find((s) => s.id === q.data.target);

            const line = shortenLine(
              { x: sourceInfo.position.x, y: sourceInfo.position.y },
              { x: targetInfo.position.x, y: targetInfo.position.y },
              0.3,
            );

            q.data.name = c.name;
            q.data.id = c.id;
            q.data.type = c.type;
            q.data.faction = c.owner.faction;
            q.data.line = line;

            allCoords.push(`(${line.p1.x};${line.p1.y})`);
            allCoords.push(`(${line.p2.x};${line.p2.y})`);
            return q;
          });

        if (queue.length) {
          queues.push(queue);
        }
        return queues;
      }, []);

    const coordsText = allCoords.join('/');

    // only when the paths change
    if (coordsText !== this.coordsText) {
      this.coordsText = coordsText;
      const moveGroup = this.getGroupByName('moving-characters');

      // empty group
      while (moveGroup.children.length) {
        const line = moveGroup.children.pop();
        disposeObject(line, true, true, false);
      }

      characters.forEach((character) => {
        const { faction } = character[0].data;

        // draw wide line for each segment except the first one,
        // the first one being the 'animated' on taken care of further
        // down below (see 'characters-on-map')
        for (let i = 1; i < character.length; i += 1) {
          const { line } = character[i].data;

          if (!meshLineMaterialsByFaction[faction]) {
            meshLineMaterialsByFaction[faction] = new MeshLineMaterial({
              color: this.colors[faction].hex.normal,
              transparent: true,
              lineWidth: 0.05,
              opacity: 0.6,
            });
          }

          const wideLineMaterial = meshLineMaterialsByFaction[faction];
          const wideLine = new MeshLine();
          wideLine.setPoints([line.p1.x, line.p1.y, config.MAP.Z_CHARACTER_NEAR_LINE, line.p2.x, line.p2.y, config.MAP.Z_CHARACTER_NEAR_LINE]);
          const mesh = new Mesh(wideLine, wideLineMaterial);
          moveGroup.add(mesh);
        }
      });
    }

    // character names
    const namesGroup = this.getGroupByName('character-names-on-map');
    const namesInUse = store.state.game.player.characters.map((c) => c.name);
    const idsInUse = store.state.game.player.characters.map((c) => c.id);
    const factionsInUse = store.state.game.player.characters.map((c) => c.owner.faction);

    // instanciate names we haven't already seen
    namesInUse.forEach((name, i) => {
      if (!(name in this.names)) {
        const group = this.characterLabel(
          idsInUse[i],
          name,
          this.colors[factionsInUse[i]],
          config.MAP.Z_CHARACTER_NEAR_LABEL,
        );
        this.names[name] = group;
        namesGroup.add(group);
      }
    });

    // only show character names we are using
    Object.keys(this.names).forEach((name) => {
      this.names[name].visible = store.state.game.mapOptions.showCharacterLabel && namesInUse.includes(name);
    });

    const characterGroup = this.getGroupByName('characters-on-map');
    const now = Date.now();
    if (!this.lastDrawAt) {
      this.lastDrawAt = now;
    }

    // perf: only draw every 80ms
    if (now - this.lastDrawAt > 80) {
      this.lastDrawAt = now;

      // empty group
      while (characterGroup.children.length) {
        const line = characterGroup.children.pop();
        disposeObject(line);
      }

      // draw wide line on first segment of each character
      characters.forEach((character) => {
        // first segment is the one on which the character is currently moving
        const segment = character[0];
        const {
          data: {
            name,
            faction,
            line,
          },
          total_time: totalTime,
          remaining_time: remainingTime,
          started_at: startedAt,
        } = segment;

        let percent = this.progress(startedAt, remainingTime, totalTime);
        percent = Math.min(percent, 100);
        percent = Math.max(percent, 0);

        const pX = line.p1.x + percent * (line.p2.x - line.p1.x);
        const pY = line.p1.y + percent * (line.p2.y - line.p1.y);
        const segmentStart = [pX, pY];
        const segmentEnd = [line.p2.x, line.p2.y];

        this.names[name].position.set(pX, pY, 0.5);

        const material = new MeshLineMaterial({ color: this.colors[faction].hex.normal, lineWidth: 0.05 });
        const geometry = new MeshLine();
        geometry.setPoints([...segmentStart, config.MAP.Z_CHARACTER_NEAR_LINE, ...segmentEnd, config.MAP.Z_CHARACTER_NEAR_LINE]);
        const mesh = new Mesh(geometry, material);
        characterGroup.add(mesh);

        const hover = this.cache.hoverMesh.clone();
        hover.visible = false;
        hover.position.set(pX, pY, config.MAP.Z_SYSTEM_NEAR_HOVER);
        Object.assign(hover.userData, { showOnHover: true });
        characterGroup.add(hover);

        const angle = Math.atan2(line.p2.y - line.p1.y, line.p2.x - line.p1.x) + (2 * Math.PI);
        const sprite = this.map.materials.sprites.characters[faction][character[0].data.type].clone();
        sprite.position.set(pX, pY, config.MAP.Z_CHARACTER_NEAR_SPRITE);
        sprite.material = sprite.material.clone();
        sprite.material.rotation = angle;

        sprite.userData.hoverable = true;
        sprite.gameObject = { type: 'character', data: character[0].data.id };

        characterGroup.add(sprite);
      });
    }

    // idle characters
    let idleCharactersGroup = this.getGroupByName('idle-characters');
    if (idleCharactersGroup) {
      disposeObjectTree(idleCharactersGroup);
    }

    idleCharactersGroup = new Group();
    idleCharactersGroup.name = 'idle-characters';
    Object.assign(idleCharactersGroup.userData, { near: 20, far: 200 });
    this.group.add(idleCharactersGroup);

    const groupedIdleCharacters = store.state.game.player.characters
      .filter((c) => c.status === 'on_board' && c.action_status === 'idle')
      .reduce((acc, c) => {
        acc[c.system] = [...acc[c.system] || [], c];
        return acc;
      }, {});

    Object.values(groupedIdleCharacters).forEach((idleCharacters) => {
      idleCharacters.forEach((c, i) => {
        this.names[c.name].children[1].geometry.computeBoundingBox();

        const size = this.names[c.name].children[1].geometry.boundingBox;
        const x = Math.abs(size.max.x) + Math.abs(size.min.x) + 0.80;
        const y = Math.abs(size.max.y) + Math.abs(size.min.y) - 0.68;
        const shift = i * 0.46;

        this.names[c.name].visible = store.state.game.mapOptions.showCharacterLabel;
        this.names[c.name].position.set(c.position.x - x, c.position.y - size.max.y - y - shift, config.MAP.Z_SYSTEM_NEAR_STAR);
      });
    });
  }

  setHoverPath(array) {
    if (array.length) {
      this.hoverPath = true;
    } else {
      this.hoverPath = false;
    }
    const points = arrayToPoints(array);
    this.line.geometry.setFromPoints(points);
    this.line.geometry.computeBoundingSphere();
  }

  getSelected() {
    return store.state.game.player.characters.find((c) => c.id === store.state.game.selectedCharacter.id);
  }

  getPosition(character) {
    return character.actions.virtual_position === null
      ? store.state.game.selectedCharacter.system : character.actions.virtual_position;
  }

  computePath(fromSystemId, toSystemId) {
    if (fromSystemId === toSystemId) {
      return [];
    }

    const found = this.pathfinder.find(fromSystemId, toSystemId);
    const itinerary = [];

    for (let i = found.length - 2; i >= 0; i -= 1) {
      const s1 = this.map.data.systems.find((s) => s.id === found[i].id);
      const s2 = this.map.data.systems.find((s) => s.id === found[i + 1].id);
      itinerary.push({
        p1: { x: s1.position.x, y: s1.position.y },
        p2: { x: s2.position.x, y: s2.position.y },
        source: s2.id,
        target: s1.id,
      });
    }

    return itinerary;
  }

  hoverPathTo(system) {
    const character = this.getSelected();
    const position = this.getPosition(character);

    if (position !== system.id) {
      this.displayedTravelPath = this.computePath(position, system.id);
      const p = this.displayedTravelPath.reduce((xs, { p1, p2 }) => xs.concat([[p2.x, p2.y], [p1.x, p1.y]]), []);
      this.setHoverPath(p);
    }
  }

  hideHoverPath() {
    this.setHoverPath([]);
  }

  characterLabel(characterId, name, colors, z) {
    const characterName = new Group();

    const font = this.map.fonts.nunito800;
    const shape = font.generateShapes(name.toUpperCase(), 0.25);
    const textGeometry = new ShapeBufferGeometry(shape);
    const textSize = new Vector3();
    textGeometry.computeBoundingBox();
    textGeometry.boundingBox.getSize(textSize);

    const x = 0.5;
    const y = -0.15;
    const text = new Mesh(textGeometry, colors.material.darker);
    text.position.set(x, y, z);
    characterName.add(text);

    const padding = 0.1;
    const rect = new PlaneGeometry(textSize.x + (2 * padding), textSize.y + (2 * padding), 32);
    const background = new Mesh(rect, this.map.materials.black100);
    background.position.set(x + textSize.x / 2, y + padding * 1.2, z - 0.05);
    background.userData.hoverable = true;
    background.gameObject = { type: 'character', data: characterId };

    characterName.add(background);
    return characterName;
  }

  createPathFinder() {
    const { systems, galaxy } = store.state.game;

    this.log('create pathfinder');
    const graph = createGraph();

    systems.forEach((system) => {
      graph.addNode(system.id);
    });

    galaxy.edges.forEach((edge) => {
      graph.addLink(edge.s1.id, edge.s2.id, {
        s1: edge.s1,
        s2: edge.s2,
        weight: edge.weight,
      });
    });

    return path.nba(graph, {
      distance(from, to, link) {
        return link.data.weight;
      },
    });
  }

  static canHoverPath() {
    const character = store.state.game.selectedCharacter;

    if (!character) { return false; }

    if (character.status !== 'on_board' || character.action_status === 'docking'
      || (character.type === 'spy'
      && character.spy.cover.value < store.state.game.data.constant[0].cover_threshold)) {
      return false;
    }

    return true;
  }
}

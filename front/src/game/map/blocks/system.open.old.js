/* eslint-disable */

import { Group } from 'three';
/*
import {
  CircleGeometry,
  Group,
  Line,
  LineBasicMaterial,
  LineDashedMaterial,
  LineLoop,
  Mesh,
  MeshLambertMaterial,
  Object3D,
  RepeatWrapping,
  SphereGeometry,
} from 'three';
*/

// import Prando from 'prando';
// import store from '@/store';
import Block from './block';
// import { createRing } from '../three-utils';

// const twoPI = Math.PI * 2;

function takeRandomListItem(rng, list) {
  return list[rng.nextInt(0, list.length - 1)];
}

export default class System extends Block {
  constructor(map) {
    super(map, 'System');

    this.range = { far: 19.8, near: 0 };
  }

  _create() {
    const group1 = new Group();
    Object.assign(group1.userData, this.range);
    /*

    const starSize = [0.02, 0.08];
    const systemsData = this.map.data.stellar_system;

    store.state.game.systems.forEach((system) => {
      const rng = new Prando(system.id);
      const systemData = systemsData.find((s) => s.key === system.type);

      const sphereRadius = rng.next(starSize[0], starSize[1]) * systemData.display_size_factor;
      const material = this.map.materials[`ttt_${system.type}`];

      const geom = new SphereGeometry(sphereRadius, 20, 20);
      const star = new Mesh(geom, material);

      star.position.x = system.position.x;
      star.position.y = system.position.y;
      star.position.z = 0;

      star.gameObject = system;

      group1.add(star);
    });

    */
    this.group.add(group1);
  }

  _update() {
    // console.log('updating System');
  }

  addSystemBodies(system, position) {
    /*
    const alreadyInstantiated = this.find((group) => group.userData.systemId === system.id);
    if (alreadyInstantiated) {
      // do not instantiate system bodies more than once per system
      return;
    }

    const rng = new Prando(system.id);
    const bodiesSpec = [
      { type: 'habitable_planet', size: [0.01, 0.02], materials: ['ttt_13b7bf', 'ttt_26a9c7', 'ttt_40b8f5', 'ttt_39a3db'] },
      { type: 'sterile_planet', size: [0.01, 0.02], materials: ['ttt_feffd2', 'ttt_e9fefe', 'ttt_ede4c7'] },
      { type: 'gaseous_giant', size: [0.03, 0.04], materials: ['ttt_fffe99', 'ttt_feffd2', 'ttt_fcf09a', 'ttt_f2ba85'] },
      { type: 'asteroid_belt', size: [0.03, 0.04], materials: ['ttt_e3e3e3', 'ttt_f5f5f5', 'ttt_cceef0'] },
      { type: 'moon', size: [0.0002, 0.0003], materials: ['ttt_9c9c9c', 'ttt_6a6a6a'] },
      { type: 'asteroid', size: [0.0002, 0.0003], materials: ['ttt_9c9c9c', 'ttt_6a6a6a'] },
    ];

    const { threeToneToon1 } = this.map.materials;
    const systemBodies = new Group();
    systemBodies.name = 'system-bodies';
    Object.assign(systemBodies.userData, this.range);
    systemBodies.userData.systemId = system.id;

    system.bodies.forEach((body, orbitIndex) => {
      const bodySpec = bodiesSpec.find((b) => b.type === body.type);
      const bodyMaterial = takeRandomListItem(rng, bodySpec.materials);

      const planetGroup = new Group();
      const planetRadius = rng.next(bodySpec.size[0], bodySpec.size[1]);
      // const orbitStartingAngle = rng.next(0, 360);
      const orbitStartingAngle = 0;
      const minOrbitRadius = planetRadius + 0.1;

      const planetGeom = new Mesh(new SphereGeometry(planetRadius, 20, 20), this.map.materials[bodyMaterial]);
      const planet = new Object3D();
      planet.add(planetGeom);

      if (body.type === 'habitable_planet') {
        const atmoGeom = new Mesh(
          new SphereGeometry(planetRadius * 1.2, 20, 20),
          new MeshLambertMaterial({
            color: 0xc2c2c2,
            transparent: true,
            opacity: 0.3,
          }),
        );
        atmoGeom.castShadow = false;
        planet.add(atmoGeom);
      }

      planet.orbitRadius = orbitIndex * rng.next(0.12, 0.18) + minOrbitRadius;
      planet.rotSpeed = 0.003 + Math.random() * 0.005;

      planetGroup.position.set(position.x, position.y, 0);

      const planetAxis = new Group();
      // initial position on orbit
      planetAxis.rotation.z = orbitStartingAngle;
      planetGroup.add(planetAxis);

      planet.position.y = planet.orbitRadius;
      planetAxis.add(planet);

      const alphaMap = this.map.textureLoader.load('/game/textures/alpha7.png');
      alphaMap.wrapS = RepeatWrapping;
      alphaMap.wrapT = RepeatWrapping;
      alphaMap.repeat.set(50, 50);

      // moons / subbodies
      let moonOrbit = 0.04;
      body.bodies.forEach((obj) => {
        const g1 = new SphereGeometry(0.005, 8, 8);
        // parent
        const newParent = new Group();
        newParent.position.set(planet.position.x, planet.position.y, 0);
        // pivots
        const pivot1 = new Group();
        pivot1.rotation.z = Math.random() * (2 * Math.PI);
        newParent.rotSpeed = 0.03 + Math.random() * 0.05;
        newParent.add(pivot1);
        // mesh
        const mesh1 = new Mesh(g1, threeToneToon1);
        mesh1.position.y = moonOrbit;
        pivot1.add(mesh1);
        planetGroup.add(newParent);

        this.animationCallbacks.push({
          ...this.range,
          cb: () => {
            newParent.rotation.z += newParent.rotSpeed;
          },
        });

        // draw the orbit for moons only, not for asteroids
        if (obj.type === 'moon') {
          const pos = {
            x: newParent.position.x,
            y: newParent.position.y,
            z: newParent.position.z,
          };
          const ring = createRing(alphaMap, [0.02, moonOrbit], pos, 0xffff00);
          planetGroup.add(ring);
        }

        moonOrbit += Math.random() / 35;
      });

      systemBodies.add(planetGroup);

      this.animationCallbacks.push({
        ...this.range,
        cb: () => {
          planetGroup.rotation.z += planet.rotSpeed;
        },
      });

      const orbitGeom = new CircleGeometry(planet.orbitRadius, 160);
      const orbitMat = new LineBasicMaterial({color: 0x212121, linewidth: 0.02});
      orbitGeom.vertices.shift();
      const orbit = new LineLoop(orbitGeom, orbitMat);
      orbit.computeLineDistances();
      orbit.position.x = position.x;
      orbit.position.y = position.y;
      orbit.position.z = 0;
      systemBodies.add(orbit);
    });

    // outer gradient ring
    const alphaMap = this.map.textureLoader.load('/game/textures/alpha5.png');
    const ring = createRing(alphaMap, [0.65, 0.9], { x: position.x, y: position.y, z: 0 });
    systemBodies.add(ring);

    // potential full circles
    const n1 = rng.nextInt(1, 5);
    for (let i = 0; i < n1; i += 1) {
      const thetaStart = rng.next(0, twoPI);
      const thetaLength = rng.next(0, 10) <= 3 ? twoPI : rng.next(0, twoPI);
      const circleGeom = new CircleGeometry(rng.next(0.01, 2), 160, thetaStart, thetaLength);
      const circleMat = new LineBasicMaterial({
        color: 0xffffff,
        opacity: rng.next(0, n1 / 10),
        transparent: true,
      });
      circleGeom.vertices.shift();
      const circle = new Line(circleGeom, circleMat);
      circle.position.set(position.x, position.y, 0);
      systemBodies.add(circle);
    }
    // short arcs
    const n2 = rng.nextInt(5, 12);
    for (let i = 0; i < n2; i += 1) {
      const thetaStart = rng.next(0, twoPI);
      const thetaLength = rng.next(0, twoPI / 6);
      const circleGeom = new CircleGeometry(rng.next(0.01, 2), 160, thetaStart, thetaLength);
      const circleMat = new LineBasicMaterial({
        color: 0xffffff,
        opacity: rng.next(0, n2 / 10),
        transparent: true,
      });
      circleGeom.vertices.shift();
      const circle = new Line(circleGeom, circleMat);
      circle.position.set(position.x, position.y, 0);
      systemBodies.add(circle);
    }

    this.group.add(systemBodies);
    */
  }
}

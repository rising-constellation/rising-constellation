import {
  MeshBasicMaterial,
  FrontSide,
  FontLoader,
  RingBufferGeometry,
  Mesh,
  SpriteMaterial,
  Sprite,
} from 'three';

import tinycolor from 'tinycolor2';
import store from '@/store';

export function colorsFactory() {
  // prepapre a "neutral" factions' color
  const colors = [{ key: 'neutral', color: '#ffffff' }]
    .concat(store.state.game.data.faction);

  return colors.reduce((acc, faction) => {
    const color = tinycolor(faction.color);

    const normal = parseInt(color.toHex(), 16);
    const lighter = parseInt(color.lighten(20).toHex(), 16);
    const darker = parseInt(color.darken(20).toHex(), 16);

    acc[faction.key] = {
      hex: { normal, lighter, darker },
      material: {
        normal: new MeshBasicMaterial({ color: normal, transparent: true, side: FrontSide }),
        lighter: new MeshBasicMaterial({ color: lighter, transparent: true, side: FrontSide }),
        darker: new MeshBasicMaterial({ color: darker, transparent: true, side: FrontSide }),
      },
    };

    return acc;
  }, {});
}

export function materialsFactory(map) {
  const colors = colorsFactory();

  const white = new MeshBasicMaterial({ color: 0xe6e6e6, transparent: true, side: FrontSide });
  const lightGrey = new MeshBasicMaterial({ color: 0xbfbfbf, transparent: true, side: FrontSide });
  const black = new MeshBasicMaterial({ color: 0x000000, transparent: true, side: FrontSide });

  // pre-render stars' sprites
  const uninhabitedTexture = map.textureLoader.load('map/systems/uninhabited.png');
  const inhabitedTexture = map.textureLoader.load('map/systems/inhabited.png');
  const playerTexture = map.textureLoader.load('map/systems/player.png');
  const dominionTexture = map.textureLoader.load('map/systems/dominion.png');

  const factionsWithNeutral = [...map.gameData.faction, ...[{ key: 'neutral' }]];

  const systemsSprite = map.gameData.stellar_system.reduce((acc, system) => {
    const size = 0.40 * system.display_size_factor;

    const unMmat04 = new SpriteMaterial({ map: uninhabitedTexture, opacity: 0.5 });
    const unSprite04 = new Sprite(unMmat04);
    unSprite04.transparent = true;
    unSprite04.scale.set(size, size, 1);

    const unMmat10 = new SpriteMaterial({ map: uninhabitedTexture, opacity: 1.0 });
    const unSprite10 = new Sprite(unMmat10);
    unSprite10.scale.set(size, size, 1);
    unSprite10.transparent = true;

    const inMmat04 = new SpriteMaterial({ map: inhabitedTexture, opacity: 0.5 });
    const inSprite04 = new Sprite(inMmat04);
    inSprite04.scale.set(size, size, 1);
    inSprite04.transparent = true;

    const inMmat10 = new SpriteMaterial({ map: inhabitedTexture, opacity: 1.0 });
    const inSprite10 = new Sprite(inMmat10);
    inSprite10.scale.set(size, size, 1);
    inSprite10.transparent = true;

    acc[system.key] = {};
    acc[system.key].uninhabited = { known: unSprite10, unknown: unSprite04 };
    acc[system.key].inhabited = { known: inSprite10, unknown: inSprite04 };
    acc[system.key].factions = factionsWithNeutral.reduce((acc2, faction) => {
      const factionColor = colors[faction.key];

      const playerMat04 = new SpriteMaterial({ map: playerTexture, opacity: 0.5, color: factionColor.hex.darker });
      const playerSprite04 = new Sprite(playerMat04);
      playerSprite04.transparent = true;
      playerSprite04.scale.set(size, size, 1);

      const playerMat10 = new SpriteMaterial({ map: playerTexture, opacity: 1.0, color: factionColor.hex.darker });
      const playerSprite10 = new Sprite(playerMat10);
      playerSprite10.transparent = true;
      playerSprite10.scale.set(size, size, 1);

      const dominionMat04 = new SpriteMaterial({ map: dominionTexture, opacity: 0.5, color: factionColor.hex.darker });
      const dominionSprite04 = new Sprite(dominionMat04);
      dominionSprite04.transparent = true;
      dominionSprite04.scale.set(size, size, 1);

      const dominionMat10 = new SpriteMaterial({ map: dominionTexture, opacity: 1.0, color: factionColor.hex.darker });
      const dominionSprite10 = new Sprite(dominionMat10);
      dominionSprite10.transparent = true;
      dominionSprite10.scale.set(size, size, 1);

      acc2[faction.key] = {
        player: { known: playerSprite10, unknown: playerSprite04 },
        dominion: { known: dominionSprite10, unknown: dominionSprite04 },
      };
      return acc2;
    }, {});

    return acc;
  }, {});

  // pre-render characters sprites
  const textures = {
    character: map.textureLoader.load('map/characters/character.png'),
    admiral: map.textureLoader.load('map/characters/admiral.png'),
    spy: map.textureLoader.load('map/characters/spy.png'),
    speaker: map.textureLoader.load('map/characters/speaker.png'),
  };

  const charactersSprite = store.state.game.data.faction.reduce((acc, faction) => {
    const color = colors[faction.key];
    acc[faction.key] = {};

    Object.keys(textures).forEach((texture) => {
      const material = new SpriteMaterial({ map: textures[texture], color: color.hex.lighter });
      const sprite = new Sprite(material);
      sprite.transparent = true;
      sprite.scale.set(0.50, 0.50, 1);

      acc[faction.key][texture] = sprite;
    });

    return acc;
  }, {});

  return {
    white,
    lightGrey,
    black,
    sprites: {
      systems: systemsSprite,
      characters: charactersSprite,
    },
  };
}

export async function loadFonts() {
  const loader = new FontLoader();

  const fonts = [
    { name: 'nunito300', path: 'fonts/nunito-regular.json' },
    { name: 'nunito800', path: 'fonts/nunito-black-regular.json' },
    { name: 'montserrat700', path: 'fonts/montserrat-bold-regular.json' },
  ];

  const promises = fonts
    .map((font) => new Promise((resolve) => loader.load(font.path, (_font) => resolve(_font))));

  return Promise.all(promises).then((f) => f.reduce((acc, font, i) => {
    acc[fonts[i].name] = font;
    return acc;
  }, {}));
}

export function createRing(alphaMap, [innerRadius, outerRadius], position, color = 0xffffff) {
  const geometry = new RingBufferGeometry(innerRadius, outerRadius, 128, 1);
  const matProps = {
    color,
    opacity: 0.8,
    transparent: true,
  };
  if (alphaMap) {
    Object.assign(matProps, {
      alphaMap,
      alphaTest: 0.005,
    });
  }
  const material = new MeshBasicMaterial(matProps);
  const ring = new Mesh(geometry, material);
  ring.position.set(
    position.x,
    position.y,
    position.z || 0,
  );
  return ring;
}

// round to the closest multiple of 'prec'
// roundTo(112, 25) -> 100
// roundTo(112, 25) -> 100
// roundTo(125.1, 0.2) -> 125.2
export function roundTo(n, prec) {
  const step = prec || 1.0;
  const inv = 1.0 / step;
  return Math.round(n * inv) / inv;
}

// is point in the circle 'center-radius'
export function inCircle(center, point, radius) {
  const dx = center.x - point.x;
  const dy = center.y - point.y;
  const d2 = dx ** 2 + dy ** 2;
  return d2 < (radius ** 2);
}

// dist between p1 and p2
export function dist(p1, p2) {
  return Math.sqrt((p1.x - p2.x) ** 2 + (p1.y - p2.y) ** 2);
}

/**
 * dispose functions inspired by https://github.com/lume/lume/blob/a16fc59473e11ac53e7fa67e1d3cb7e060fe1d72/src/utils/three.ts
 * The MIT License
 * Copyright (c) 2015 LUME authors (https://github.com/lume/lume#contributors)
*/
function isRenderItem(obj) {
  return 'geometry' in obj && 'material' in obj;
}

function disposeMaterial(obj) {
  if (!isRenderItem(obj)) return;

  // because obj.material can be a material or array of materials
  const materials = ([]).concat(obj.material);

  materials.forEach((material) => {
    material.dispose();
  });
}

export function disposeObject(obj, removeFromParent = true, destroyGeometry = true, destroyMaterial = true) {
  if (!obj) return;

  if (isRenderItem(obj)) {
      if (obj.geometry && destroyGeometry) obj.geometry.dispose();
      if (destroyMaterial) disposeMaterial(obj);
  }

  if (removeFromParent) {
    Promise.resolve().then(() => {
      // if we remove children in the same tick then we can't continue traversing,
      // so we defer to the next microtask
      if (obj.parent) {
        obj.parent.remove(obj);
      }
    });
  }
}

export function disposeObjectTree(obj, disposeOptions = { removeFromParent: true, destroyGeometry: true, destroyMaterial: true }) {
  obj.traverse((node) => {
    disposeObject(
      node,
      disposeOptions.removeFromParent,
      disposeOptions.destroyGeometry,
      disposeOptions.destroyMaterial,
    );
  });
}

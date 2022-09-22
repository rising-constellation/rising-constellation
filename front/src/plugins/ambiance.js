import { Howl } from 'howler';
import Path from '@/utils/path';

import soundSprite from '@/../public/sound/event-sprite.json';

const soundList = Object.keys(soundSprite).reduce((acc, key) => {
  const name = key.split('_')[0];

  if (!acc[name]) acc[name] = [];
  acc[name].push(key);

  return acc;
}, {});

const activeSounds = new Map();

let timeout = null;
let musicPlayer = null;
let soundPlayer = null;
// let voicePlayer = null;

const contexts = {
  game: {
    current: 0,
    delayBetweenTracks: 30,
    sources: [
      'myrmezirs-law.mp3',
      'dark-side-of-the-ark.mp3',
      'cult-of-cardan.mp3',
      'syns-uprising.mp3',
      'tetra-colossus.mp3',
    ],
  },
  portal: {
    current: 0,
    delayBetweenTracks: 0,
    sources: [
      'main-theme.mp3',
    ],
  },
};

export const ambiance = {
  settings: {
    master: 0.5,
    music: 1.0,
    sound: 1.0,
    voice: 1.0,
  },
  context: 'portal',

  async init(settings, context) {
    Object.assign(this.settings, settings);
    if (context) {
      this.context = context;
    }

    soundPlayer = new Howl({
      src: [Path.relative('sound/event-sprite.mp3')],
      volume: this.getVolume('sound'),
      sprite: soundSprite,
      onend: (id) => {
        activeSounds.forEach((value, key) => {
          if (value === id) {
            activeSounds.delete(key);
          }
        });
      },
    });

    // TODO: fetch sprite
    /*
    const voiceSprite = null;
    voicePlayer = new Howl({
      src: ['sound/voice.mp3'],
      volume: this.getVolume('voice'),
      sprite: voiceSprite,
    });
    */

    return this.play();
  },

  async play() {
    if (musicPlayer) return;

    return new Promise((resolve) => {
      clearTimeout(timeout);
      const c = this.context;
      const cursor = contexts[c].current;
      const delay = contexts[c].delayBetweenTracks;
      const source = contexts[c].sources[cursor];
      const filePath = Path.relative(`music/${source}`);

      contexts[c].current = (cursor + 1) % contexts[c].sources.length;

      musicPlayer = new Howl({
        src: [filePath],
        volume: this.getVolume('music'),
        html5: true,
        onend: () => {
          timeout = setTimeout(() => {
            musicPlayer = null;
            this.play();
          }, delay * 1000);
        },
        onload: () => {
          musicPlayer.play();
          resolve();
        },
      });
    });
  },

  async pause() {
    if (musicPlayer) {
      clearTimeout(timeout);
      musicPlayer.fade(this.getVolume('music'), 0, 500);

      await new Promise((resolve) => { setTimeout(resolve, 500); });
      musicPlayer.stop();
      musicPlayer.unload();
      musicPlayer = null;
    }
  },

  async changeContext(context) {
    if (context !== this.context) {
      await this.pause();
      this.context = context;
      return this.play();
    }
  },

  sound(key) {
    if (soundList[key]) {
      const sounds = soundList[key];
      const sound = sounds[Math.floor(Math.random() * sounds.length)];
      const id = activeSounds.get(key);
      if (id) {
        soundPlayer.stop(id);
        activeSounds.set(key, soundPlayer.play(sound));
      } else {
        activeSounds.set(key, soundPlayer.play(sound));
      }
    } else {
      // console.log(`sound "${key}" not found`);
    }
  },

  voice(key) {
    console.log(key);
    // play voice
  },

  updateVolume(type, volume) {
    this.settings[type] = volume;

    if (musicPlayer) {
      musicPlayer.volume(this.getVolume('music'));
    }

    soundPlayer.volume(this.getVolume('sound'));
    // voicePlayer.volume(this.getVolume('voice'));
  },

  getVolume(type) {
    return this.settings.master * this.settings[type];
  },
};

export default {
  ambiance,
  install(Vue) {
    Vue.prototype.$ambiance = ambiance;
  },
};

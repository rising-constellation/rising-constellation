import Vue from 'vue';
import Cookies from 'js-cookie';

const cookiesKeys = ['faction', 'instance', 'profile', 'registration_token', 'user_token'];

const setView = (state) => {
  // set view to last overlay, or to map if none
  // and change map status
  state.view = state.activeOverlay || 'map';
  state.isMapLocked = state.view !== 'map';

  return state;
};

const loadAuthData = () => cookiesKeys.reduce((acc, key) => {
  const value = ['faction', 'instance', 'profile'].includes(key)
    ? parseInt(Cookies.get(key), 10) : Cookies.get(key);

  if (value) {
    acc[key] = value;
  }

  return acc;
}, {});

const defaultState = () => {
  console.log('Game store created');

  return {
    // connection process
    // also check that channels are all actives
    auth: loadAuthData(),
    connected: false,
    isDead: false,
    activeChannels: {
      global: false,
      faction: false,
      player: false,
    },

    // set current view
    view: 'map',
    activeOverlay: null,
    mapOverlay: null,
    isMapLocked: false,
    hasSystemTransition: false,

    // building box
    production: null,

    // affectation box
    assignment: null,

    // only for 'system' view
    selectedSystem: undefined,

    // selection
    selectedCharacter: undefined,

    // ouverture d'agent ou de joueur
    openedCharacter: undefined,
    openedPlayer: undefined,

    // reactive data from server
    onlinePlayers: {},

    // unread messages
    unreadMessages: 0,

    // shortkey characters' group
    charactersGroup: {},

    // tutorial active step
    tutorialStep: 0,

    // map
    mapPosition: { x: 0, y: 0, z: 0 },
    mapOptions: {
      mode: 'visibility',
      showCharacterLabel: true,
    },

    data: {},
    time: {},
    galaxy: {},
    victory: {},
    character_market: {},
    faction: {},
    player: {},
    textNotifications: [],
    boxNotifications: [],
    systems: [],
  };
};

const gameStore = {
  namespaced: true,
  state: defaultState(),
  getters: {
    theme(state) {
      if (state.connected && state.data.faction) {
        return state.data.faction
          .find((f) => f.key === state.player.faction)
          .theme;
      }

      return '';
    },
    themeByKey(state) {
      return ((key) => {
        const faction = state.data.faction.find((f) => f.key === key);
        return faction ? faction.theme : '';
      });
    },
    onlinePlayersNumber(state) {
      return Object.keys(state.onlinePlayers).length;
    },
    tickToMilisecondFactor(state) {
      return (180 / state.data.speed.find((s) => s.key === state.time.speed).factor) * 1000;
    },
    tickToSecondFactor(state) {
      return (180 / state.data.speed.find((s) => s.key === state.time.speed).factor);
    },
  },
  mutations: {
    init(state, payload) {
      console.log('Game store initialized');

      cookiesKeys.forEach((key) => {
        if (payload[key]) {
          Cookies.set(key, payload[key]);
        }
      });

      state.auth = loadAuthData();
    },
    clear(state) {
      Object.assign(state, defaultState());
    },
    statusChannel(state, payload) {
      const { channel, status } = payload;

      state.activeChannels[channel] = status;
      state.connected = state.activeChannels.global
        && state.activeChannels.faction
        && state.activeChannels.player;
    },

    discardTextNotification(state, payload) {
      const index = state.textNotifications.findIndex((notif) => notif.id === payload);

      if (index > -1) {
        state.textNotifications.splice(index, 1);
      }
    },
    discardFirstBoxNotification(state) {
      state.boxNotifications.shift();
    },

    startSystemTransition(state) {
      state.hasSystemTransition = true;
    },
    finishSystemTransition(state) {
      state.hasSystemTransition = false;
    },

    addOverlay(state, overlay) {
      // set overlay to active if no other overlay is already active
      if (!state.activeOverlay) { // eslint-disable-line
        state.activeOverlay = overlay;
      }

      state = setView(state);
    },
    removeOverlay(state) {
      // remove overlay, if exist
      state.activeOverlay = null;

      state = setView(state);
    },

    addMapOverlay(state, payload) {
      state.mapOverlay = payload;
    },

    clearMapOverlay(state) {
      state.mapOverlay = null;
    },

    prepareProduction(state, payload) {
      state.production = payload;
    },
    clearProduction(state) {
      state.production = undefined;
    },

    prepareAssignment(state, payload) {
      state.assignment = payload;
    },
    clearAssignment(state) {
      state.assignment = null;
    },

    tutorialNextStep(state) {
      state.tutorialStep += 1;
    },
    tutorialPrevStep(state) {
      state.tutorialStep -= 1;
    },

    updateOnlinePlayers(state, onlinePlayers) {
      state.onlinePlayers = onlinePlayers;
    },

    updateUnreadMessages(state, unreadMessages) {
      if (unreadMessages > 99) unreadMessages = '99+';
      state.unreadMessages = unreadMessages;
    },

    updateCharactersGroup(state, { key, characterId }) {
      // remove previous group for same character
      Object.keys(state.charactersGroup).forEach((k) => {
        if (state.charactersGroup[k] === characterId) {
          Vue.set(state.charactersGroup, k, null);
        }
      });

      Vue.set(state.charactersGroup, key, characterId);
    },

    updateMapPosition(state, position) {
      state.mapPosition = position;
    },

    updateMapOptions(state, { key, value }) {
      state.mapOptions[key] = value;
    },

    setPlayer(state, player) {
      state.player = player;

      if (player.is_dead) {
        state.isDead = true;
      }
    },

    setNotifications(state, notifications) {
      const notifs = notifications.reduce((acc, notif, i) => {
        if (notif.type === 'sound') {
          this._vm.$ambiance.sound(`notif-${notif.key}`);
          return acc;
        }

        if (notif.type === 'text') {
          const id = state.textNotifications.length + i;
          const timestamp = Date.now();

          this._vm.$ambiance.sound('new-text-notif');
          notif = Object.assign(notif, { id, timestamp });

          acc.text.push(notif);
        }

        if (notif.type === 'box') {
          this._vm.$ambiance.sound('new-box-notif');
          acc.box.push(notif);
        }

        return acc;
      }, { text: [], box: [] });

      state.textNotifications = state.textNotifications.concat(notifs.text);
      state.boxNotifications = state.boxNotifications.concat(notifs.box);
    },

    selectSystem(state, selectedSystem) {
      if (selectedSystem) {
        selectedSystem.receivedAt = Date.now();
      }

      state.selectedSystem = selectedSystem;
    },

    selectCharacter(state, selectedCharacter) {
      const character = typeof selectedCharacter === 'object' ? selectedCharacter : undefined;

      if (character) {
        character.receivedAt = Date.now();
      }

      state.selectedCharacter = character;
    },

    update(state, payload) {
      if (payload.global_data) {
        state.data = Object.freeze(payload.global_data);
      }

      if (payload.global_time) {
        state.time = payload.global_time;
      }

      // remove systems ?
      if (payload.global_galaxy) {
        state.galaxy = payload.global_galaxy;
      }

      if (payload.global_galaxy_sector) {
        state.galaxy.sectors = payload.global_galaxy_sector;
      }

      if (payload.global_galaxy_player) {
        state.galaxy.players = payload.global_galaxy_player;
      }

      if (payload.global_character_market) {
        state.character_market = payload.global_character_market;
      }

      if (payload.global_victory) {
        state.victory = payload.global_victory;
      }

      if (payload.player_player) {
        this.commit('game/setPlayer', payload.player_player);
      }

      if (payload.player_notifs) {
        this.commit('game/setNotifications', payload.player_notifs);
      }

      // remove detected_objects ?
      // remove radars ?
      if (payload.faction_faction) {
        state.faction = payload.faction_faction;
      }
    },
  },
  actions: {
    async openSystem(store, { vm, id }) {
      return new Promise((resolve, reject) => {
        vm.$socket.faction.push('get_system', { system_id: id })
          .receive('ok', ({ system }) => {
            this.commit('game/startSystemTransition');
            this.commit('game/selectSystem', system);
            this.commit('game/addOverlay', 'system');
            this.commit('game/clearProduction');

            vm.$root.$emit('enterSystem', system);
            resolve(system);
          })
          .receive('error', (data) => {
            Vue.toasted.error(data.reason);
            reject();
          });
      });
    },
    reloadSystem(store, socket) {
      // very naive method, must see if it's ok
      if (store.state.selectedSystem) {
        socket.faction
          .push('get_system', { system_id: store.state.selectedSystem.id })
          .receive('ok', ({ system }) => {
            this.commit('game/selectSystem', system);
          });
      }
    },
    closeSystem(store, vm) {
      // Only close a system when no pending transitions
      if (!store.state.hasSystemTransition) {
        this.commit('game/selectSystem', undefined);
        this.commit('game/removeOverlay', 'system');
        vm.$root.$emit('exitSystem');
      }
    },

    selectCharacter(store, { vm, id }) {
      vm.$socket.player.push('get_character', { character_id: id })
        .receive('ok', ({ character }) => {
          this.commit('game/selectCharacter', character);
        })
        .receive('error', (data) => {
          Vue.toasted.error(data.reason);
        });
    },
    unselectCharacter() {
      this.commit('game/clearProduction');
      this.commit('game/selectCharacter', undefined);
    },
    reloadSelectedCharacter(store, socket) {
      if (store.state.selectedCharacter) {
        socket.player
          .push('get_character', { character_id: store.state.selectedCharacter.id })
          .receive('ok', ({ character }) => {
            this.commit('game/selectCharacter', character);
          });
      }
    },

    openCharacter(store, { vm, id }) {
      vm.$socket.faction.push('get_character', { character_id: id })
        .receive('ok', ({ character }) => {
          store.state.openedCharacter = typeof character === 'object' ? character : undefined;
        })
        .receive('error', (data) => {
          Vue.toasted.error(data.reason);
        });
    },
    closeCharacter(store) {
      store.state.openedCharacter = undefined;
    },

    openPlayer(store, { vm, id }) {
      vm.$socket.global.push('get_player', { player_id: id })
        .receive('ok', ({ player }) => {
          store.state.openedPlayer = typeof player === 'object' ? player : undefined;
        })
        .receive('error', (data) => {
          Vue.toasted.error(data.reason);
        });
    },
    closePlayer(store) {
      store.state.openedPlayer = undefined;
    },
  },
};

export default gameStore;

// import { App, Window } from 'nw.gui';
import { createAxiosInstance } from '@/plugins/axios';
import { loadLanguage, setLanguage, defaultLanguage } from '@/plugins/i18n';
import { ambiance } from '@/plugins/ambiance';
import { versionCheck } from '@/utils/loader';
import config from '@/config';

let axios;

const portalStore = {
  namespaced: true,
  state: {
    isSignedIn: null,
    isInMaintenance: null,
    hasCorrectVersion: null,
    requiredVersion: '',
    hasConnectivity: true,

    isAdmin: false,
    account: undefined,
    activeProfile: null,
    data: {},
    apiToken: '',

    settings: {
      ambiance: ambiance.settings,
    },
    conversations: [],
  },
  getters: {
    conversations(state) {
      return (instanceId) => {
        const conversations = instanceId
          ? state.conversations.filter((c) => c.iid === instanceId)
          : state.conversations.filter((c) => c.iid === null);

        return Array.from(conversations)
          .sort((a, b) => new Date(b.last_message_update) - new Date(a.last_message_update));
      };
    },
    unreadMessages(state) {
      return (instanceId) => {
        const conversations = instanceId
          ? state.conversations.filter((c) => c.iid === instanceId && c.unread > 0)
          : state.conversations.filter((c) => c.iid === null && c.unread > 0);

        return conversations.reduce((acc, c) => acc + c.unread, 0);
      };
    },
    conversation(state) {
      return (conversationId) => state.conversations.find(({ id }) => id === conversationId);
    },
  },
  mutations: {
    isSignedIn(state, payload) {
      state.isSignedIn = payload;
    },
    isInMaintenance(state, payload) {
      state.isInMaintenance = payload;
    },
    hasCorrectVersion(state, payload) {
      if (config.IS_STEAM) {
        state.hasCorrectVersion = payload;
      } else {
        // web version is by definition always up-to-date
        state.hasCorrectVersion = true;
      }
    },
    requiredVersion(state, payload) {
      state.requiredVersion = payload;
    },
    hasConnectivity(state, payload) {
      state.hasConnectivity = payload;
    },
    isAdmin(state, payload) {
      state.isAdmin = payload;
    },
    account(state, payload) {
      state.account = payload;

      if (state.account && state.account.email && state.account.email.endsWith('@steam')) {
        const [steamId] = state.account.email.split('@');
        state.account.steam_id = steamId;
        state.account.email = '';
      }
    },
    updateAccountMoney(state, amount) {
      state.account.money += amount;
    },
    updateData(state, payload) {
      state.data = payload;
    },
    apiToken(state, payload) {
      state.apiToken = payload;
    },
    initSettings(state) {
      if (!state.account.settings.lang) {
        state.account.settings.lang = state.settings.lang;
      }

      Object.assign(state.settings, state.account.settings);
      if (!state.settings.lang) {
        state.settings.lang = 'en';
      } else {
        localStorage.setItem('lang', state.settings.lang);
      }

      if (config.IS_STEAM) {
        const nwin = Window.get();
        nwin.zoomLevel = state.account.settings.uiScale || 0;
      }

      ambiance.init(state.settings.ambiance, 'portal');
    },
    initActiveProfile(state, profiles) {
      if (profiles.length > 0) {
        if (state.settings.activeProfileId) {
          const profile = profiles.find((p) => p.id === state.settings.activeProfileId);
          state.activeProfile = profile;
        } else {
          state.activeProfile = profiles[0];
        }
        this._vm.$socket.connectProfile(state.activeProfile.id);
      }
    },
    updateSettings(state, payload) {
      Object.assign(state.settings, payload);
      axios.post('/accounts/settings', { settings: state.settings });
    },
    addConversations(state, conversations) {
      conversations.forEach((conversation) => {
        if (!state.conversations.find(({ id: conversationId }) => conversationId === conversation.id)) {
          if (!conversation.messages) {
            conversation.messages = [];
          }

          state.conversations.push(conversation);
        }
      });
    },
    updateConversation(state, { id, messages, page, isLastPage }) {
      const conversation = state.conversations.find(({ id: conversationId }) => conversationId === id);

      if (!conversation) {
        state.conversations.push(conversation);
      }

      mergeMessages(conversation, messages, state.activeProfile);
      conversation.page = page;
      conversation.isLastPage = isLastPage;
    },
    updateConversationUnread(state, { id }) {
      const conversation = state.conversations.find(({ id: conversationId }) => conversationId === id);
      this._vm.$socket.profile.push('read_conv', { cid: id })
        .receive('ok', (data) => {
          conversation.lastSeen = data.last_seen;
        });

      conversation.unread = 0;
    },
    updateConversationMembers(state, { id, members }) {
      const conversation = state.conversations.find(({ id: conversationId }) => conversationId === id);
      conversation.members = members;
    },
    newConversation(state, conversation) {
      if (!conversation.messages) {
        conversation.messages = [];
      }

      state.conversations.push(conversation);
    },
    newMessage(state, { conversation, message }) {
      const { cid, id, content_html: content, inserted_at: date, cm_id: cmId } = message;
      const pid = conversation.members.find((member) => member.id === message.cm_id).iid;
      const conv = state.conversations.find(({ id: conversationId }) => conversationId === cid);
      const name = conv.members.find(({ id: memberId }) => memberId === cmId).name;

      conv.isLastPage = false;
      conv.last_message_update = conversation.last_message_update;

      mergeMessages(conv, [{ content_html: content, date, id, name, pid }], state.activeProfile);
    },
  },
  actions: {
    async init({ commit, dispatch }) {
      console.log('Portal store created');

      axios = createAxiosInstance();

      try {
        const account = await axios.get('/account');
        const profiles = await axios.get(`/accounts/${account.data.id}/profiles`);

        commit('account', account.data);
        commit('initSettings');

        // connect websockets
        this._vm.$socket.init();

        commit('initActiveProfile', profiles.data);
        commit('isSignedIn', true);
        commit('isAdmin', account.data.role === 'admin');
        dispatch('initConversations');
        await dispatch('initLanguage');

        // load game data
        const { data } = await axios.get('/data');
        commit('updateData', data);
      } catch (err) {
        console.error(err);
        return false;
      }

      return true;
    },
    setApiToken({ commit }, apiToken) {
      commit('apiToken', apiToken);
    },
    async initLanguage({ state }) {
      await loadLanguage(defaultLanguage);
      let { lang } = state.settings;
      if (!lang && localStorage.getItem('lang')) {
        lang = localStorage.getItem('lang');
      }
      await setLanguage(lang);
    },
    async setLanguage({ commit }, lang) {
      await setLanguage(lang);
      localStorage.setItem('lang', lang);

      commit('updateSettings', { lang });
    },
    async updateActiveProfile({ state, commit }, profile) {
      state.activeProfile = profile;
      this._vm.$socket.connectProfile(profile.id);
      commit('updateSettings', { activeProfileId: profile.id });
    },
    async updateAmbiance({ commit }, settings) {
      Object.keys(settings).forEach((type) => ambiance.updateVolume(type, settings[type]));
      commit('updateSettings', { ambiance: settings });
    },
    async updateVersion({ commit }, requiredVersion) {
      commit('requiredVersion', requiredVersion);

      try {
        commit('hasCorrectVersion', await versionCheck());
      } catch (err) {
        // server could be down during maintenance
      }
    },
    async initConversations({ state, commit }, instanceId) {
      const query = instanceId
        ? `/messenger/${state.activeProfile.id}/instance/${instanceId}`
        : `/messenger/${state.activeProfile.id}`;

      axios.get(query).then(({ data }) => {
        commit('addConversations', data);
      });
    },
    async loadConversation({ state, commit }, conversationId) {
      const conversation = state.conversations.find(({ id }) => id === conversationId);
      const page = conversation.page ? conversation.page + 1 : 1;

      if (!conversation.isLastPage) {
        return axios.get(`/messenger/${state.activeProfile.id}/${conversationId}?page=${page}`).then(({ data, headers }) => {
          const isLastPage = page >= headers['total-pages'];
          commit('updateConversation', { id: conversationId, messages: data, page, isLastPage });
          commit('updateConversationUnread', { id: conversationId });
        });
      }

      commit('updateConversationUnread', { id: conversationId });
    },
    async logout({ commit }) {
      commit('isSignedIn', false);
      commit('isAdmin', false);
      commit('account', undefined);

      try {
        await axios.post('/logout', {});
      } catch (err) {
        // console.error(err)
      }

      if (config.IS_STEAM) {
        // eslint-disable-next-line no-undef
        App.quit();
      } else {
        window.location = config.BASE_URL;
      }
    },
  },
};

function mergeMessages(conversation, messages, activeProfile) {
  const existingMessageIDs = conversation.messages.map(({ id }) => id);

  let unread = 0;
  messages.forEach((message) => {
    if (!existingMessageIDs.includes(message.id)) {
      conversation.messages.push(message);

      if (message.pid !== activeProfile.id) {
        unread += 1;
      }
    }
  });
  conversation.unread = unread;

  conversation.messages.sort(({ id: id1 }, { id: id2 }) => id2 - id1);
}

export default portalStore;

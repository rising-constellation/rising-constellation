import Vue from 'vue';
import Vuex from 'vuex';

import portal from '@/portal/store';
import game from '@/game/store';

Vue.use(Vuex);

const store = new Vuex.Store({
  modules: { portal, game },
});

export default store;

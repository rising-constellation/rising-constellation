import Vue from 'vue';

import VueToasted from 'vue-toasted';
import VueLodash from 'vue-lodash';
import VueConfig from 'vue-config';
import VueSvgIcon from 'vue-svgicon';
import VueCustomScrollbar from 'vue-custom-scrollbar';
import VueShortkey from 'vue-shortkey';
import { VTooltip, VPopover } from 'v-tooltip';
import vSelect from 'vue-select';

import lodash from 'lodash';

import App from '@/App.vue';
import config from '@/config';
import store from '@/store';
import router from '@/router';

import '@/icons';
import '@/plugins/filters';

import axios from '@/plugins/axios';
import { i18n } from '@/plugins/i18n';
import Socket from '@/plugins/websockets';
import Ambiance from '@/plugins/ambiance';

import Appsignal from '@appsignal/javascript';
import { errorHandler } from '@appsignal/vue';

const isDev = !process.env.VUE_APP_APPSIGNAL_FRONT;
if (!isDev) {
  const appsignal = new Appsignal({
    key: process.env.VUE_APP_APPSIGNAL_FRONT,
    revision: process.env.VUE_APP_APPSIGNAL_REVISION,
  });

  Vue.config.errorHandler = errorHandler(appsignal, Vue);
}

Vue.use(Socket);
Vue.use(Ambiance);
Vue.use(VueShortkey, { prevent: ['input', 'textarea'] });
Vue.use(VueLodash, { lodash });
Vue.use(axios);
Vue.use(VueConfig, config);
Vue.use(VueSvgIcon, { tagName: 'svgicon' });
Vue.use(VueToasted, {
  position: 'bottom-right',
  duration: 3000,
  keepOnHover: true,
});

Vue.component('v-scrollbar', VueCustomScrollbar);
Vue.component('v-popover', VPopover);
Vue.component('v-select', vSelect);

Vue.directive('tooltip', VTooltip);

Vue.config.performance = isDev;
Vue.config.productionTip = false;

new Vue({
  i18n,
  router,
  store,
  render: (h) => h(App),
}).$mount('#app');

// remove right click globally
document.addEventListener('contextmenu', (event) => event.preventDefault());
document.addEventListener('click', () => Ambiance.ambiance.sound('click'));

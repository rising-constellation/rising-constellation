import axiosLib from 'axios';
import store from '@/store';
import config from '@/config';

export function createAxiosInstance() {
  // http/cors configs
  const axios = axiosLib.create({ baseURL: `${config.BASE_URL}/api` });
  if (config.IS_STEAM) {
    axios.interceptors.request.use((opt) => {
      if (store.state.portal.apiToken) {
        // console.log('with bearer token', store.state.portal.apiToken);
        opt.headers.Authorization = `Bearer ${store.state.portal.apiToken}`;
      }

      return opt;
    }, (error) => Promise.reject(error));
  }
  return axios;
}

const axios = createAxiosInstance();

export default {
  axios,
  install(Vue) {
    Vue.prototype.$axios = axios;
  },
};

import Vue from 'vue';
import VueI18n from 'vue-i18n';
import { Settings } from 'luxon';

import { createAxiosInstance } from '@/plugins/axios';
import { escape } from '@/plugins/filters';
import { renderMd } from '@/utils/markdown';

import portalJSON from '@/locales/en/portal.json';
import gameJSON from '@/locales/en/game.json';
import dataJSON from '@/locales/en/data.json';
import errorsJSON from '@/locales/en/errors.json';

const defaultLanguage = 'en';
const loadedLanguages = ['na'];
const availableLanguages = ['fr', 'en', 'de'];
const filesPromises = (lang) => [
  import(`@/locales/${lang}/portal.json`),
  import(`@/locales/${lang}/game.json`),
  import(`@/locales/${lang}/data.json`),
  import(`@/locales/${lang}/errors.json`),
];

Vue.use(VueI18n);

const axios = createAxiosInstance();

const i18n = new VueI18n({
  locale: defaultLanguage,
  fallbackLocale: defaultLanguage,
  messages: { [defaultLanguage]: Object.assign(portalJSON, gameJSON, dataJSON, errorsJSON) },
});

async function loadLanguage(lang) {
  if (!availableLanguages.includes(lang)) {
    return false;
  }
  if (i18n.locale !== lang && !loadedLanguages.includes(lang)) {
    const contents = await Promise.all(filesPromises(lang));

    contents.forEach((content, i) => {
      if (i === 0) {
        i18n.setLocaleMessage(lang, content.default);
      } else {
        i18n.mergeLocaleMessage(lang, content.default);
      }
    });

    loadedLanguages.push(lang);
  }

  return true;
}

export async function setLanguage(lang) {
  if (await loadLanguage(lang)) {
    i18n.locale = lang;
    Settings.defaultLocale = lang;
    axios.defaults.headers.common['Accept-Language'] = lang;
    document.querySelector('html').setAttribute('lang', lang);
  }

  return lang;
}

Vue.prototype.$toastChangesetError = function $toastChangesetError(axiosException) {
  if (typeof axiosException === 'object' && axiosException.response && axiosException.response.data && axiosException.response.data.message) {
    const messages = axiosException.response.data.message;
    Object.entries(messages).forEach(([key, errors]) => {
      errors.forEach((error) => {
        const p1 = `toast.changeset.key['${key}']`;
        const p2 = `toast.changeset.error['${error}']`;
        let translatedKey = this.$t(p1);
        if (translatedKey === p1) translatedKey = key;
        let translatedError = this.$t(p2, [translatedKey]);
        if (translatedError === p2) translatedError = `${translatedKey} ${error}`;

        this.$toasted.error(translatedError);
      });
    });
  } else {
    this.$toasted.error('Erreur');
  }
};

Vue.prototype.$toastError = function $toastError(reason) {
  const keypath = `toast.error['${reason}']`;
  const translation = this.$t(keypath);
  if (!translation || translation === keypath) {
    this.$toasted.error(reason);
  } else {
    this.$toasted.error(translation);
  }
};

Vue.prototype.$tmd = function $toastError(...args) {
  return renderMd(this.$t(...args));
};

Vue.prototype.$escape = escape;

export { i18n, loadLanguage, availableLanguages, defaultLanguage };

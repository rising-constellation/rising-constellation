import { DateTime } from 'luxon';

/* eslint-disable import/prefer-default-export */
import Vue from 'vue';
import formatNumber from '@/utils/format';

// number filters
Vue.filter('integer', formatNumber.integer);
Vue.filter('float', formatNumber.float);
Vue.filter('mixed', formatNumber.mixed);
Vue.filter('signed', (value) => formatNumber.integer(value, true));
Vue.filter('obfuscate', formatNumber.obfuscate);

// date filters
Vue.filter('datetime-short', ((date) => {
  const format = {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
    hour: 'numeric',
  };

  return Intl.DateTimeFormat(navigator.language, format).format(new Date(date));
}));

Vue.filter('datetime-long', ((date) => {
  const format = {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    hour: 'numeric',
    minute: 'numeric',
  };

  return Intl.DateTimeFormat(navigator.language, format).format(new Date(date));
}));

Vue.filter('date-short', ((date) => {
  const format = {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  };

  return Intl.DateTimeFormat(navigator.language, format).format(new Date(date));
}));

Vue.filter('date-long', ((date) => {
  const format = {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  };

  return Intl.DateTimeFormat(navigator.language, format).format(new Date(date));
}));

Vue.filter('counter', ((remainingSeconds) => {
  if (remainingSeconds === Infinity) {
    return '--:--:--';
  }

  const hours = Math.floor(remainingSeconds / 3600).toString();
  remainingSeconds %= 3600;
  const minutes = Math.floor(remainingSeconds / 60).toString();
  const seconds = Math.round(remainingSeconds % 60).toString();

  return `${hours.padStart(2, '0')}:${minutes.padStart(2, '0')}:${seconds.padStart(2, '0')}`;
}));

Vue.filter('luxon-std', ((timestamp) => DateTime.fromMillis(timestamp).toLocaleString(DateTime.DATETIME_MED_WITH_SECONDS)));

const { replace } = '';
const detect = /[&<>'"]/g;
const lookup = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  "'": '&#39;',
  '"': '&quot;',
};
const replacer = (character) => lookup[character];
const escape = (input) => replace.call(input, detect, replacer);
Vue.filter('escape', escape);
export { escape };

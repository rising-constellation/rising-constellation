import config from '@/config';

export default {
  relative(subpath) {
    const depth = window.location.pathname.replace('/portal', '').split('/');
    const completePath = depth.length === 1 ? './' : '../'.repeat(depth.length - 1);

    if (config.IS_STEAM) {
      return `/dist/main/${subpath}`;
    }
    return `${completePath}portal/${subpath}`;
  },
};

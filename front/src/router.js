import Vue from 'vue';
import Router from 'vue-router';

import config from '@/config';
import store from '@/store';

Vue.use(Router);

const onlyAdminGuard = (to, from, next) => {
  if (store.state.portal.isAdmin) {
    next();
  } else {
    next('/');
  }
};

const router = new Router({
  mode: config.IS_STEAM ? 'hash' : 'history',
  base: config.IS_STEAM ? '/dist/main/' : process.env.BASE_URL,
  routes: [
    {
      path: '/',
      component: () => import('@/portal/pages/Menu.vue'),
    }, {
      path: '/new-player',
      component: () => import('@/portal/pages/NewPlayer.vue'),
    }, {
      path: '/play',
      component: () => import('@/portal/pages/Play.vue'),
      children: [
        {
          path: '', redirect: 'slow',
        }, {
          path: 'fast',
          component: () => import('@/portal/pages/play/Flash.vue'),
        }, {
          path: 'medium',
          component: () => import('@/portal/pages/play/Tactical.vue'),
        }, {
          path: 'slow',
          component: () => import('@/portal/pages/play/Legacy.vue'),
        }, {
          path: 'tutorial',
          component: () => import('@/portal/pages/play/Tutorial.vue'),
        }, {
          path: 'from-scenarios/:speed',
          component: () => import('@/portal/pages/play/Scenarios.vue'),
        }, {
          path: 'new/:sid',
          component: () => import('@/portal/pages/play/New.vue'),
        },
      ],
    }, {
      path: '/instance/:iid',
      component: () => import('@/portal/pages/Instance.vue'),
    }, {
      path: '/create',
      beforeEnter: onlyAdminGuard,
      component: () => import('@/portal/pages/Create.vue'),
      children: [
        { path: '', redirect: 'maps' }, {
          path: 'maps',
          component: () => import('@/portal/pages/create/Maps.vue'),
        }, {
          path: 'scenarios',
          component: () => import('@/portal/pages/create/Scenarios.vue'),
        },
      ],
    }, {
      path: '/create/map/:id',
      beforeEnter: onlyAdminGuard,
      component: () => import('@/portal/pages/create/Map.vue'),
    }, {
      path: '/create/scenario/:mode/:id',
      beforeEnter: onlyAdminGuard,
      component: () => import('@/portal/pages/create/Scenario.vue'),
    }, {
      path: '/account',
      component: () => import('@/portal/pages/Account.vue'),
      children: [
        {
          path: '', redirect: 'info',
        }, {
          path: 'info',
          component: () => import('@/portal/pages/account/Info.vue'),
        }, {
          path: 'password',
          component: () => import('@/portal/pages/account/Password.vue'),
        },
      ],
    }, {
      path: '/profiles',
      component: () => import('@/portal/pages/Profile.vue'),
      children: [
        {
          path: ':pid',
          component: () => import('@/portal/pages/profile/Detail.vue'),
        },
      ],
    }, {
      path: '/standings',
      component: () => import('@/portal/pages/Standings.vue'),
    }, {
      path: '/messenger',
      component: () => import('@/portal/pages/Messenger.vue'),
    }, {
      path: '/settings',
      component: () => import('@/portal/pages/Settings.vue'),
    }, {
      path: '/fight-simulator',
      component: () => import('@/portal/pages/FightSimulator.vue'),
    }, {
      path: '/maintenance',
      component: () => import('@/portal/pages/Maintenance.vue'),
    }, {
      path: '/game',
      component: () => import('@/game/Game.vue'),
    }, {
      path: '*',
      component: () => import('@/portal/pages/Menu.vue'),
    },
  ],
});

router.beforeEach(async (to, from, next) => {
  if (store.state.portal.isSignedIn) {
    if (!store.state.portal.activeProfile && !['/menu', '/new-player'].includes(to.path)) {
      router.push('/');
      return;
    }

    if (from.path === '/game' && to.path !== '/game') {
      router.app.$socket.leaveGame();
    }
  }

  next();
});

export default router;

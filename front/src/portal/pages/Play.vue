<template>
  <default-layout>
    <div class="fluid-panel">
      <v-scrollbar class="panel-aside">
        <section class="panel-aside-links">
          <router-link
            class="panel-aside-link"
            to="/play/slow">
            <div class="panel-aside-link-header">
              <h2>{{ $t('page.play.slow.title') }}</h2>
              <span>{{ $t('page.play.slow.subtitle') }}</span>
            </div>
            <p
              class="panel-aside-link-content"
              v-html="$t('page.play.slow.description')" />
          </router-link>
          <router-link
            :class="{ 'is-free-dashed': account.is_free }"
            class="panel-aside-link"
            to="/play/medium">
            <div class="panel-aside-link-header">
              <h2>{{ $t('page.play.medium.title') }}</h2>
              <span>{{ $t('page.play.medium.subtitle') }}</span>
            </div>
            <p class="panel-aside-link-content">
              {{ $t('page.play.medium.description') }}
            </p>
          </router-link>
          <router-link
            :class="{ 'is-free-dashed': account.is_free }"
            class="panel-aside-link"
            to="/play/fast">
            <div class="panel-aside-link-header">
              <h2>{{ $t('page.play.fast.title') }}</h2>
              <span>{{ $t('page.play.fast.subtitle') }}</span>
            </div>
            <p class="panel-aside-link-content">
              {{ $t('page.play.fast.description') }}
            </p>
          </router-link>
          <router-link
            class="panel-aside-link"
            to="/play/tutorial">
            <div class="panel-aside-link-header">
              <h2>{{ $t('page.play.tutorial.title') }}</h2>
            </div>
            <p class="panel-aside-link-content">
              {{ $t('page.play.tutorial.description') }}
            </p>
          </router-link>
        </section>

        <hr class="margin">
      </v-scrollbar>

      <router-view></router-view>
    </div>
  </default-layout>
</template>

<script>
import DefaultLayout from '@/portal/layouts/Default.vue';

export default {
  name: 'play',
  computed: {
    account() { return this.$store.state.portal.account; },
  },
  components: {
    DefaultLayout,
  },
};
</script>

<template>
  <div class="portal-context">
    <div class="layout">
      <div class="layout-topbar">
        <div class="navbar top">
          <div class="navbar-left">
            <router-link
              class="navbar-main-button"
              to="/">
              <div class="navbar-main-button-icon">
                <svgicon class="icon" name="logo/simple" />
              </div>
            </router-link>

            <router-link
              class="navbar-button-title"
              to="/play">
              {{ $t('layout.default.play') }}
            </router-link>

            <template v-if="account.role === 'admin'">
              <router-link
                class="navbar-button-title"
                to="/create">
                {{ $t('layout.default.forge') }}
              </router-link>

              <!--
              <a
                class="navbar-button-title disabled"
                href="#">
                Arène
              </a>

              <a
                class="navbar-button-title disabled"
                href="#">
                Citadelle
              </a>
              -->
            </template>

            <router-link
              class="navbar-button-title"
              to="/standings">
              {{ $t('layout.default.standings') }}
            </router-link>
          </div>

          <div class="navbar-right">
            <div class="navbar-group-buttons right">
              <router-link
                class="navbar-button-account"
                to="/account">
                <div class="name">{{ activeProfile.name }}</div>
                <div class="info">online</div>
              </router-link>

              <router-link
                class="navbar-button-icon"
                v-tooltip="$t('layout.default.settings')"
                to="/settings">
                <svgicon class="icon" name="options" />
              </router-link>
              <router-link
                class="navbar-button-icon"
                v-tooltip="$t('layout.default.messenger')"
                to="/messenger">
                <span
                  v-show="unreadMessages > 0"
                  class="info">
                  {{ unreadMessages }}
                </span>
                <svgicon class="icon" name="chat" />
              </router-link>
              <a
                class="navbar-button-icon disabled"
                v-tooltip="$t('layout.default.not_yet_available')"
                href="#">
                <svgicon class="icon" name="infinite" />
              </a>
            </div>

            <router-link
              class="navbar-main-button"
              :to="`/profiles/${activeProfile.id}?mode=edit`">
              <div class="navbar-main-button-image">
                <img :src="avatarProfile" />
              </div>
            </router-link>
          </div>
        </div>
      </div>

      <div class="layout-content">
        <slot />
      </div>
    </div>
  </div>
</template>

<script>
import Path from '@/utils/path';

export default {
  name: 'default-layout',
  computed: {
    account() { return this.$store.state.portal.account; },
    activeProfile() { return this.$store.state.portal.activeProfile; },
    avatarProfile() { return Path.relative(`data/avatars/${this.activeProfile.avatar}`); },
    unreadMessages() { return this.$store.getters['portal/unreadMessages'](); },
  },
};
</script>

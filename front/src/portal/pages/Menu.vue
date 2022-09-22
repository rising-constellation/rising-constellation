<template>
  <div class="portal-context">
    <div class="menu-component">
      <svg
        class="main-logo"
        viewBox="0 0 1000 1000">
        <!-- eslint-disable-next-line -->
        <path class="main-logo-line" d="M828,361.42A356.14,356.14,0,0,0,149,559.9a51,51,0,0,0,31.32,97,351.58,351.58,0,0,0,22.78,39.7A71,71,0,1,0,303.44,796.89,356.15,356.15,0,0,0,828,361.42ZM185.19,653.11a47.35,47.35,0,0,1-5.76,1.9,48.36,48.36,0,0,1-12.41,1.6,49,49,0,0,1-17.68-94.69,45.54,45.54,0,0,1,5.8-1.85,47.93,47.93,0,0,1,5.92-1.1,48.79,48.79,0,0,1,6-.36,47.75,47.75,0,0,1,7.22.54c.36.05.72.1,1.08.17s.73.12,1.08.2a49,49,0,0,1,26.4,81.53l-.81.85c-.27.28-.55.55-.83.81a48.72,48.72,0,0,1-10.46,7.78A45.57,45.57,0,0,1,185.19,653.11ZM171,500c0-181.42,147.58-329,329-329S829,318.58,829,500,681.41,829,500,829a327,327,0,0,1-181.75-54.89,71,71,0,0,0-92.37-92.37A328.43,328.43,0,0,1,203.72,643,51,51,0,0,0,176,557.41,329.17,329.17,0,0,1,171,500Zm20.58,152.29a51,51,0,0,0,10.5-7.68,326.22,326.22,0,0,0,21.73,38,70.05,70.05,0,0,0-11.22,6.22A343.65,343.65,0,0,1,191.58,652.29ZM305.81,791.23c-1.29,1.57-2.64,3.09-4.06,4.54a69,69,0,1,1-97.53-97.52q2.17-2.13,4.55-4.07t4.93-3.68a68.16,68.16,0,0,1,11.24-6.19l1-.43,1.08-.44A69,69,0,0,1,316.55,773c-.14.36-.29.72-.44,1.07s-.28.67-.43,1a68.25,68.25,0,0,1-6.19,11.25Q307.77,788.85,305.81,791.23ZM500,844a342,342,0,0,1-188.85-56.59,69.72,69.72,0,0,0,6.22-11.23A331.15,331.15,0,1,0,169,500a334.49,334.49,0,0,0,4.88,57.07,51.89,51.89,0,0,0-6.86-.46,50.5,50.5,0,0,0-6.3.39A345.51,345.51,0,0,1,156,500c0-189.69,154.31-344,344-344S844,310.31,844,500,689.68,844,500,844Z"/>
        <!-- eslint-disable-next-line -->
        <path class="main-logo-line" d="M177.64,565.94c-.36-.1-.73-.18-1.1-.27l-1.11-.24a43.14,43.14,0,0,0-8.41-.82,43,43,0,0,0-16.57,3.32,43,43,0,0,0,26.36,81.56,43,43,0,0,0,21.65-12.57c.26-.29.53-.58.79-.88s.53-.61.79-.92a43,43,0,0,0-22.4-69.18Zm19.65,62.91c-.24.35-.49.69-.74,1s-.51.66-.77,1a37.18,37.18,0,0,1-15.67,11.36A36.54,36.54,0,0,1,167,644.61,37,37,0,0,1,151.67,574a35.08,35.08,0,0,1,5.72-2.06,35.56,35.56,0,0,1,5.94-1.1q1.83-.18,3.69-.18a36.76,36.76,0,0,1,9.78,1.32l1.14.33c.38.11.76.24,1.14.37a37,37,0,0,1,18.21,56.22Z"/>
        <!-- eslint-disable-next-line -->
        <path class="main-logo-line" d="M252.38,684.61a62.5,62.5,0,0,0-21.87,3.92l-1.1.41-1,.41a62.26,62.26,0,0,0-11.35,6.11q-2.55,1.74-4.91,3.7h0q-2.34,1.94-4.49,4.1a63,63,0,0,0,89.06,89.06c1.44-1.43,2.8-2.92,4.1-4.48s2.55-3.22,3.71-4.92a62.26,62.26,0,0,0,6.11-11.35c.14-.33.28-.67.41-1s.28-.73.41-1.1a63,63,0,0,0-59.08-84.87Zm54,81.24L306,767l-.39,1a57.09,57.09,0,0,1-9.7,16.37,58.1,58.1,0,0,1-4.16,4.43,57,57,0,0,1-80.56-80.56,58.1,58.1,0,0,1,4.43-4.16,57.09,57.09,0,0,1,16.37-9.7l1-.39,1.12-.39a57,57,0,0,1,72.25,72.25Z"/>
      </svg>

      <div class="menu-sidebar">
        <div class="menu-sidebar-top">
          <div class="menu-sidebar-section">
            <div class="menu-card-container">
              <player-card
                v-if="activeProfile"
                :profile="activeProfile" />
              <router-link
                v-else
                to="/new-player"
                class="card-container has-hover">
                <div class="card-header">
                  <div class="card-header-icon">
                    <svgicon
                      class="icon"
                      name="close"
                      style="transform: rotate(45deg)" />
                  </div>
                  <div class="card-header-content">
                    <div class="title-large nowrap">
                      {{ $t('page.menu.create_profile') }}
                    </div>
                  </div>
                </div>

                <div class="card-body">
                  <div class="card-illustration">
                    <img src="/portal/data/avatars/empty.jpg" />
                  </div>

                  <div class="card-information">
                    <div class="card-panel-window">
                      <div class="card-panel-container">
                        <div class="card-panel">
                          <blockquote>
                            {{ $t('page.menu.create_profile_text') }}
                          </blockquote>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </router-link>
            </div>
          </div>
          <div
            v-if="activeProfile"
            class="menu-sidebar-section is-nav">
            <router-link to="play">
              {{ $t('page.menu.start') }}
            </router-link>
          </div>
        </div>
        <div class="menu-sidebar-bottom">
          <div class="menu-sidebar-section is-nav">
            <div @click="logout">
              {{ $t('page.menu.exit') }}
            </div>
          </div>
        </div>
      </div>

      <!--
      <div
        v-if="activeProfile"
        class="menu-info">
        <div class="menu-info-box">
          <h2>{{ $t('page.menu.ea_title') }}</h2>
          <p>{{ $t('page.menu.ea_p1') }}</p>
          <p>{{ $t('page.menu.ea_p2') }}</p>
          <p>{{ $t('page.menu.ea_p3') }}</p>
          <div
            style="margin-top: 10px;"
            class="default-input">
            <label for="name">{{ $t('page.instance.discord_link') }}</label>
            <input
              type="text"
              :value="`https://discord.gg/${$t('link.discord_invite')}`"
              disabled />
            <button
              @click="copyToClipboard(`https://discord.gg/${$t('link.discord_invite')}`)"
              v-tooltip="$t('page.instance.clipboard_copy')"
              class="default-button action">
              ⇪
            </button>
          </div>
        </div>
        <div class="menu-info-box">
          <h2>{{ $t('page.menu.epic_title') }}</h2>
          <p>{{ $t('page.menu.epic_p1') }}</p>
          <p>{{ $t('page.menu.epic_p2') }}</p>
        </div>
          <div class="menu-info-box">
          <h2>{{ $t('page.menu.legacy_title') }}</h2>
          <p>{{ $t('page.menu.legacy_p1') }}</p>
        </div>
        <div class="menu-info-box">
          <h2>{{ $t('page.menu.web_title') }}</h2>
          <p>{{ $t('page.menu.web_p1') }}</p>
          <p>{{ $t('page.menu.web_p2') }}</p>
        </div>
        <div class="menu-info-box">
          <h2>{{ $t('page.menu.tactical_title') }}</h2>
          <p>{{ $t('page.menu.tactical_p1') }}</p>
        </div>
      </div>
      -->
    </div>
  </div>
</template>

<script>
import PlayerCard from '@/portal/components/card/PlayerCard.vue';

export default {
  name: 'main-menu',
  computed: {
    activeProfile() { return this.$store.state.portal.activeProfile; },
  },
  methods: {
    async copyToClipboard(content) {
      await navigator.clipboard.writeText(content);
    },
    logout() {
      this.$store.dispatch('portal/logout');
    },
  },
  components: {
    PlayerCard,
  },
};
</script>

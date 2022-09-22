<template>
  <default-layout>
    <div class="fluid-panel is-not-full-sized">
      <v-scrollbar class="panel-aside">
        <div class="panel-aside-bloc">
          <div class="radio-input is-horizontal">
            <div class="label">
              {{ $t('page.settings.language_choice') }}
            </div>
            <div class="content">
              <div
                v-for="(language, languageCode) in languages"
                :key="languageCode"
                class="content-item">
                <input
                  type="radio"
                  :id="`size-${languageCode}`"
                  :value="languageCode"
                  v-model="selectedLanguage"
                  @change="setLanguage">
                <label :for="`size-${languageCode}`">
                  <strong>
                    {{ language }}
                  </strong>
                </label>
              </div>
            </div>
          </div>
        </div>

        <div
          v-if="mode === 'development'"
          class="panel-aside-bloc">
          <div class="radio-input">
            <div class="label">
              Test son
            </div>
            <div class="content">
              <button
                @click="testSound('click')"
                class="default-button">
                1
              </button>
              <button
                @click="testSound('panel-open')"
                class="default-button">
                2
              </button>
              <button
                @click="testSound('panel-close')"
                class="default-button">
                3
              </button>
              <button
                @click="testSound('system-open')"
                class="default-button">
                4
              </button>
              <button
                @click="testSound('system-close')"
                class="default-button">
                5
              </button>
              <button
                @click="testSound('mini-panel-open')"
                class="default-button">
                6
              </button>
              <button
                @click="testSound('error')"
                class="default-button">
                7
              </button>
            </div>
          </div>
        </div>

        <hr class="margin">
      </v-scrollbar>

      <div class="panel-content is-small">
        <div class="panel-header">
          <h1>
            <strong>{{ $t('page.settings.title') }}</strong>
          </h1>
        </div>

        <v-scrollbar class="content">
          <div
            class="default-input">
            <label for="name">{{ $t('page.settings.master_volume') }}</label>
            <div class="input-slider">
              <vue-slider
                :lazy="true"
                :min="0"
                :max="1"
                :interval="0.01"
                :dotSize="16"
                :height="8"
                tooltip="none"
                v-model="ambiance.master"
                @change="updateAmbiance">
              </vue-slider>
            </div>
          </div>

          <hr class="separator">

          <div
            class="default-input">
            <label for="name">{{ $t('page.settings.music_volume') }}</label>
            <div class="input-slider">
              <vue-slider
                :lazy="true"
                :min="0"
                :max="1"
                :interval="0.01"
                :dotSize="16"
                :height="8"
                tooltip="none"
                v-model="ambiance.music"
                @change="updateAmbiance">
              </vue-slider>
            </div>
          </div>

          <div
            class="default-input">
            <label for="name">{{ $t('page.settings.sound_volume') }}</label>
            <div class="input-slider">
              <vue-slider
                :lazy="true"
                :min="0"
                :max="1"
                :interval="0.01"
                :dotSize="16"
                :height="8"
                tooltip="none"
                v-model="ambiance.sound"
                @change="updateAmbiance">
              </vue-slider>
            </div>
          </div>

          <div
            class="default-input">
            <label for="name">{{ $t('page.settings.voice_volume') }}</label>
            <div class="input-slider">
              <vue-slider
                :lazy="true"
                :min="0"
                :max="1"
                :interval="0.01"
                :dotSize="16"
                :height="8"
                tooltip="none"
                v-model="ambiance.voice"
                @change="updateAmbiance">
              </vue-slider>
            </div>
          </div>

          <hr class="margin">
        </v-scrollbar>
      </div>

      <v-scrollbar class="panel-aside">
        <div
          v-show="isSteam"
          class="panel-aside-bloc">
          <div class="checkbox-input">
            <input
              type="checkbox"
              id="windowed"
              v-model="windowed">
            <label for="windowed">{{ $t('page.settings.windowed') }}</label>
          </div>

          <div class="default-input">
            <label for="name">
              {{ $t('page.settings.resolution') }}
              <strong>
                {{ Math.round(Math.pow(1.2, uiScale) * 20) * 5 }}%
              </strong>
            </label>
            <div class="input-slider">
              <vue-slider
                :lazy="true"
                :min="-3"
                :max="3"
                :interval="0.5"
                :marks="true"
                :hideLabel="true"
                :dotSize="16"
                :height="8"
                tooltip="none"
                v-model="uiScale"
                @change="updateUIScale">
              </vue-slider>
            </div>
          </div>
        </div>

        <hr class="margin">
      </v-scrollbar>
    </div>
  </default-layout>
</template>

<script>
import VueSlider from 'vue-slider-component';
import DefaultLayout from '@/portal/layouts/Default.vue';
import { availableLanguages } from '@/plugins/i18n';
import config from '@/config';

// eslint-disable-next-line prefer-const
let nwin = {
  isFullscreen: false,
  leaveFullscreen() {},
  enterFullscreen() {},
  zoomLevel: 0,
};

// const ngui = require('nw.gui');
// nwin = ngui.Window.get();

export default {
  name: 'settings',
  data() {
    return {
      mode: config.MODE,
      languages: {
        en: 'English',
        fr: 'Français',
        de: 'Deutsch (Umlaufbestand)',
      },
      selectedLanguage: this.$store.state.portal.settings.lang,
      ambiance: this.$store.state.portal.settings.ambiance,
      windowed: !nwin.isFullscreen,
      isSteam: config.IS_STEAM,
      uiScale: this.$store.state.portal.settings.uiScale || 0,
    };
  },
  computed: {
    availableLanguages() { return availableLanguages; },
  },
  watch: {
    windowed(isWindowed) {
      if (isWindowed) {
        nwin.leaveFullscreen();
      } else {
        nwin.enterFullscreen();
      }
    },
  },
  methods: {
    testSound(key) {
      this.$ambiance.sound(key);
    },
    async setLanguage() {
      const language = this.selectedLanguage;
      await this.$store.dispatch('portal/setLanguage', language);
    },
    async updateAmbiance() {
      await this.$store.dispatch('portal/updateAmbiance', this.ambiance);
    },
    updateUIScale() {
      nwin.zoomLevel = this.uiScale;
      this.$store.commit('portal/updateSettings', { uiScale: this.uiScale });
    },
  },
  components: {
    DefaultLayout,
    VueSlider,
  },
};
</script>

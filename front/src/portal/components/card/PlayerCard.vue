<template>
  <div class="card-container">
    <div class="card-header">
      <div class="card-header-icon">
        <svgicon class="icon" name="logo/simple" />
      </div>
      <div class="card-header-content">
        <div class="title-large nowrap">
          {{ profile.name }}
        </div>
      </div>
    </div>

    <div class="card-body">
      <div class="card-illustration">
        <img :src="path" />
      </div>

      <div class="card-information">
        <div class="card-panel-controls">
          <svgicon
            class="card-panel-control"
            name="caret-left"
            @click="movePanelToLeft"
            v-if="leftControl" />
          <div v-else></div>
          <svgicon
            class="card-panel-control"
            name="caret-right"
            @click="movePanelToRight"
            v-if="rightControl" />
          <div v-else></div>
        </div>

        <div class="card-panel-window">
          <div
            ref="panelContainer"
            class="card-panel-container"
            :style="{ left: panelContainerPosition + 'px' }">
            <div class="card-panel">
              <blockquote>
                {{ quote }}
              </blockquote>

              <div
                v-show="profile.full_name"
                class="complex-bonus">
                <div>
                  <strong>{{ profile.full_name }}</strong>
                </div>
              </div>
              <div class="complex-bonus">
                <div>{{ $t('page.profile_detail.field_age') }}</div><div>{{ profile.age }}</div>
              </div>
            </div>

            <div
              v-if="profile.long_description"
              class="card-panel">
              <h2>{{ $t('page.profile_detail.field_long_description') }}</h2>
              <p style="white-space: pre-wrap;">
                {{ profile.long_description }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import CardMixin from '@/game/mixins/CardMixin';
import Path from '@/utils/path';

export default {
  name: 'player-card',
  mixins: [CardMixin],
  props: {
    profile: Object,
  },
  computed: {
    path() { return Path.relative(`data/avatars/${this.profile.avatar}`); },
    quote() { return this.profile.description ? this.profile.description : '—'; },
  },
};
</script>

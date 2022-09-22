<template>
  <div
    class="card-container"
    :class="`f-${theme}`">
    <div class="card-header">
      <div class="card-header-icon">
        <svgicon :name="`faction/${profile.faction}-small`" />
      </div>
      <div class="card-header-content">
        <div class="title-large nowrap">
          {{ profile.name }}
          <template v-if="!profile.is_active">
            ({{ $t('inactive') }})
          </template>
        </div>
        <div
          v-show="profile.is_dead"
          class="title-small">
          {{ $t('card.profile.dead_player') }}
        </div>
      </div>
    </div>

    <div class="card-body">
      <div class="card-illustration">
        <img :src="`data/avatars/${profile.avatar}`" />
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
                <div>{{ $t('page.profile_detail.field_age') }}</div>
                <div>{{ profile.age }}</div>
              </div>

              <h2 style="margin-top: 62px;">
                {{ $t('card.profile.ranking') }}
              </h2>
              <div class="complex-bonus">
                <div>{{ $t('card.profile.elo') }}</div>
                <div>{{ profile.elo | integer }}</div>
              </div>
            </div>

            <div
              v-if="profile.long_description"
              class="card-panel">
              <p style="white-space: pre-wrap;">
                {{ profile.long_description }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div
      v-if="playerId !== profile.id"
      class="card-action">
      <div class="card-action-button">
        <div
          @click="$emit('sendMessage', profile.id)"
          class="button">
          <div>{{ $t('card.profile.contact') }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import CardMixin from '@/game/mixins/CardMixin';

export default {
  name: 'profile-card',
  mixins: [CardMixin],
  props: {
    profile: Object,
  },
  computed: {
    quote() { return this.profile.description ? this.profile.description : '—'; },
    playerId() { return this.$store.state.game.player.id; },
  },
};
</script>

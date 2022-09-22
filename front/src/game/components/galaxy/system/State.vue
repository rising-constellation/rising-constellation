<template>
  <div>
    <div class="system-content-group">
      <div class="system-content-group-header">
        <div class="main">
          {{ $t('system.system_owner_title') }}
        </div>
      </div>

      <div
        v-if="isOwnProperty"
        class="system-content-group-info"
        v-html="$tmd(`system.status.own_${system.status}`)">
      </div>
      <div
        v-else
        class="system-content-group-info"
        v-html="$tmd(`system.status.${system.status}`, { player: ownerName })">
      </div>
    </div>

    <system-population-status
      v-if="!['uninhabitable', 'uninhabited'].includes(system.status)"
      :system="system"
      :color="color" />

    <div
      class="system-content-group"
      v-if="isOwnProperty">
      <div class="system-content-group-header">
        <div class="main">
          {{ $t('system.system_state_title') }}
        </div>
      </div>

      <template v-if="system.status === 'inhabited_player'">
        <div
          @click="pushAction('transform_system_to_dominion')"
          :class="{ 'disabled': isLastSystem }"
          class="button">
          <div :class="{ 'dashed': isLastSystem }">
            {{ $t('system.transform_to_dominion') }}
          </div>
          <div class="icon-value">
            {{ transformCost | integer }}
            <svgicon name="resource/ideology" />
          </div>
        </div>
        <div
          @click="pushAction('abandon_system')"
          :class="{ 'disabled': isLastSystem }"
          class="button">
          <div :class="{ 'dashed': isLastSystem }">
            {{ $t('system.abandon_system') }}
          </div>
          <div class="icon-value">
            {{ abandonmentCost | integer }}
            <svgicon name="resource/ideology" />
          </div>
        </div>
      </template>
      <template v-if="system.status === 'inhabited_dominion'">
        <div
          @click="pushAction('transform_dominion_to_system')"
          class="button">
          <div>{{ $t('system.transform_to_system') }}</div>
          <div class="icon-value">
            {{ transformCost | integer }}
            <svgicon name="resource/ideology" />
          </div>
        </div>
        <div
          @click="pushAction('abandon_dominion')"
          class="button">
          <div>{{ $t('system.abandon_dominion') }}</div>
          <div class="icon-value">
            {{ abandonmentCost | integer }}
            <svgicon name="resource/ideology" />
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script>
import SystemPopulationStatus from '@/game/components/galaxy/system/PopulationStatus.vue';

export default {
  name: 'system-state',
  props: {
    system: Object,
    isOwnProperty: Boolean,
    color: String,
  },
  computed: {
    constant() { return this.$store.state.game.data.constant[0]; },
    player() { return this.$store.state.game.player; },
    isLastSystem() { return this.player.stellar_systems.length <= 1; },
    ownerName() {
      return this.system.owner ? this.system.owner.name : '';
    },
    abandonmentCost() { return this.constant.abandonment_cost; },
    transformCost() {
      return this.constant.transform_initial_cost
        + (this.player.transformed_system_count * this.constant.transform_additional_cost);
    },
  },
  methods: {
    pushAction(action) {
      this.$socket.player.push(action, {
        system_id: this.system.id,
      }).receive('error', (data) => {
        this.$toastError(data.reason);
      });
    },
  },
  components: {
    SystemPopulationStatus,
  },
};
</script>

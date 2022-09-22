<template>
  <tr @click="$emit('open')">
    <td>
      <svgicon
        class="icon"
        name="disc"
        v-tooltip="$t(`instance.state.${instance.state}.toast`)"
        :class="instance.state" />
      <span
        class="star"
        v-tooltip="$t('portal_components.instance_row.registered')"
        v-show="hasRegistration">★</span>
    </td>

    <td>
      <div class="header">
        <h2>{{ instance.name }}</h2>
        <em>#{{ instance.id }}</em>
        <span class="toast">
          {{ $t('portal_components.instance_row.capacity', {registeredCount: currentPlayer, maxPlayers: maxPlayer}) }}
        </span>
        <span class="toast">
          {{ $t(`map.size.${instance.game_metadata.size}.toast`) }}
        </span>
      </div>

      <em>
        <span
          v-for="(f, i) in instance.factions"
          :key="`i${instance.id}-f${f.faction_ref}`">
          <template v-if="i > 0"> vs </template>
          <strong>
            <span
              class="bull"
              :class="getTheme(f.faction_ref)">
            </span>

            {{ $t(`data.faction.${f.faction_ref}.name`) }}
            [{{ f.registrations_count }}/{{ f.capacity }}]
          </strong>
        </span>
      </em>
    </td>

    <td class="actions">
      <button
        class="default-button"
        :class="{
          'disabled': ['instance_full', 'has_registration'].includes(action),
        }"
        v-if="action !== 'no_registration'"
        @click="handleClick">
        {{ $t(`instance.registration_state.${action}`) }}
      </button>
    </td>
  </tr>
</template>

<script>
export default {
  name: 'instance-row',
  props: {
    instance: Object,
    profiles: Array,
  },
  computed: {
    faction() { return this.$store.state.portal.data.faction; },
    maxPlayer() { return this.instance.factions.reduce((a, b) => a + b.capacity, 0); },
    currentPlayer() {
      return this.instance.factions.reduce((a, b) => a + b.registrations_count, 0);
    },
    hasRegistration() {
      return !!this.profiles
        .find((p) => p.registrations.find((p2) => p2.faction.instance.id === this.instance.id));
    },
    action() {
      if (this.instance.state === 'ended') {
        return 'no_registration';
      }

      if (this.hasRegistration) {
        return this.instance.state === 'running'
          ? 'can_play'
          : 'has_registration';
      }

      if (this.instance.registration_status === 'open') {
        return this.currentPlayer < this.maxPlayer
          ? 'can_registrate'
          : 'instance_full';
      }

      return 'no_registration';
    },
  },
  methods: {
    handleClick(e) {
      if (this.action === 'can_play') {
        e.preventDefault();

        // intercept signal
        // call play function...
      }
    },
    getTheme(key) {
      return key
        ? `theme-${this.faction.find((f) => f.key === key).theme}`
        : '';
    },
  },
};
</script>

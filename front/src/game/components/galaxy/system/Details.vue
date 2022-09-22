<template>
  <div>
    <div class="system-content-group">
      <div class="system-content-group-header">
        <div class="main">
          {{ $t('galaxy.system.details.infrastructure') }}
        </div>
      </div>

      <div class="system-content-group-item">
        <div class="details-label">
          <span class="info" v-tooltip="$t(`resource-description.mobility`)">?</span>
          {{ $t('galaxy.system.details.mobility') }}
        </div>

        <div v-if="!system.mobility">
          <div class="yield-box">
            ░░░ <svgicon name="resource/mobility" />
          </div>
        </div>
        <v-popover
          v-else
          trigger="hover"
          class="details-value">
          <div class="yield-box">
            {{ system.mobility.value | integer }}
            <svgicon name="resource/mobility" />
          </div>
          <resource-detail
            slot="popover"
            :title="$t('galaxy.system.details.mobility')"
            :value="system.mobility.value"
            :details="system.mobility.details" />
        </v-popover>
      </div>
      <div class="system-content-group-item">
        <div class="details-label">
          {{ $t('galaxy.system.details.workforce') }}
        </div>

        <div class="details-value">
          <div class="yield-box large">
            <span v-if="!system.population">░░░░░░░░░</span>
            <population-value
              v-else
              :initial="system.population" />
            <svgicon name="resource/population" />
          </div>
        </div>
      </div>
    </div>

    <div class="system-content-group">
      <div class="system-content-group-header">
        <div class="main">
          {{ $t('galaxy.system.details.military') }}
        </div>
      </div>

      <div class="system-content-group-item">
        <div class="details-label">
          <span class="info" v-tooltip="$t(`resource-description.radar`)">?</span>
          {{ $t('galaxy.system.details.radar') }}
        </div>

        <div v-if="!system.radar">
          <div class="yield-box">
            ░░░ <svgicon name="resource/radar" />
          </div>
        </div>
        <v-popover
          v-else
          trigger="hover"
          class="details-value">
          <div class="yield-box">
            {{ system.radar.value | integer }}
            <svgicon name="resource/radar" />
          </div>
          <resource-detail
            slot="popover"
            :title="$t('galaxy.system.details.radar')"
            :value="system.radar.value"
            :details="system.radar.details" />
        </v-popover>
      </div>
      <div class="system-content-group-item">
        <div class="details-label">
          {{ $t('galaxy.system.details.fighters_init_xp') }}
        </div>

        <div v-if="!system.fighter_lvl">
          <div class="yield-box">
            ░░░ <svgicon name="resource/fighter_lvl" />
          </div>
        </div>
        <v-popover
          v-else
          trigger="hover"
          class="details-value">
          <div class="yield-box">
            {{ system.fighter_lvl.value | integer }}
            <svgicon name="resource/fighter_lvl" />
          </div>
          <resource-detail
            slot="popover"
            :title="$t('galaxy.system.details.experience')"
            :value="system.fighter_lvl.value"
            :details="system.fighter_lvl.details" />
        </v-popover>
      </div>
      <div class="system-content-group-item">
        <div class="details-label">
          {{ $t('galaxy.system.details.corvettes_init_xp') }}
        </div>

        <div v-if="!system.corvette_lvl">
          <div class="yield-box">
            ░░░ <svgicon name="resource/corvette_lvl" />
          </div>
        </div>
        <v-popover
          v-else
          trigger="hover"
          class="details-value">
          <div class="yield-box">
            {{ system.corvette_lvl.value | integer }}
            <svgicon name="resource/corvette_lvl" />
          </div>
          <resource-detail
            slot="popover"
            :title="$t('galaxy.system.details.experience')"
            :value="system.corvette_lvl.value"
            :details="system.corvette_lvl.details" />
        </v-popover>
      </div>
      <div class="system-content-group-item">
        <div class="details-label">
          {{ $t('galaxy.system.details.frigates_init_xp') }}
        </div>

        <div v-if="!system.frigate_lvl">
          <div class="yield-box">
            ░░░ <svgicon name="resource/frigate_lvl" />
          </div>
        </div>
        <v-popover
          v-else
          trigger="hover"
          class="details-value">
          <div class="yield-box">
            {{ system.frigate_lvl.value | integer }}
            <svgicon name="resource/frigate_lvl" />
          </div>
          <resource-detail
            slot="popover"
            :title="$t('galaxy.system.details.experience')"
            :value="system.frigate_lvl.value"
            :details="system.frigate_lvl.details" />
        </v-popover>
      </div>
      <div class="system-content-group-item">
        <div class="details-label">
          {{ $t('galaxy.system.details.capital_ships_init_xp') }}
        </div>

        <div v-if="!system.capital_lvl">
          <div class="yield-box">
            ░░░ <svgicon name="resource/capital_lvl" />
          </div>
        </div>
        <v-popover
          v-else
          trigger="hover"
          class="details-value">
          <div class="yield-box">
            {{ system.capital_lvl.value | integer }}
            <svgicon name="resource/capital_lvl" />
          </div>
          <resource-detail
            slot="popover"
            :title="$t('galaxy.system.details.experience')"
            :value="system.capital_lvl.value"
            :details="system.capital_lvl.details" />
        </v-popover>
      </div>
    </div>

    <div class="system-content-group">
      <div class="system-content-group-header">
        <div class="main">
          {{ $t('galaxy.system.details.visibility') }}
        </div>
      </div>

      <div class="system-content-group-item">
        <div class="details-label">
          <span class="info" v-tooltip="$t(`resource-description.counter_intelligence`)">?</span>
          {{ $t('galaxy.system.details.counterintelligence') }}
        </div>

        <div v-if="!system.counter_intelligence">
          <div class="yield-box">
            ░░░ <svgicon name="resource/counter_intelligence" />
          </div>
        </div>
        <v-popover
          v-else
          trigger="hover"
          class="details-value">
          <div class="yield-box">
            {{ system.counter_intelligence.value | integer }}
            <svgicon name="resource/counter_intelligence" />
          </div>
          <resource-detail
            slot="popover"
            :title="$t('galaxy.system.details.counterintelligence')"
            :value="system.counter_intelligence.value"
            :details="system.counter_intelligence.details" />
        </v-popover>
      </div>
      <div class="system-content-group-item">
        <div class="details-label">
          <span class="info" v-tooltip="$t(`resource-description.remove_contact`)">?</span>
          {{ $t('galaxy.system.details.fixing') }}
        </div>

        <div v-if="!system.remove_contact">
          <div class="yield-box">
            ░░░ <svgicon name="resource/remove_contact" />
          </div>
        </div>
        <v-popover
          v-else
          trigger="hover"
          class="details-value">
          <div class="yield-box">
            {{ system.remove_contact.change | integer }}
            <svgicon name="resource/remove_contact" />
          </div>
          <resource-detail
            slot="popover"
            :title="$t('galaxy.system.details.fixing')"
            :value="system.remove_contact.change"
            :details="system.remove_contact.details" />
        </v-popover>
      </div>
    </div>
  </div>
</template>

<script>
import ResourceDetail from '@/game/components/generic/ResourceDetail.vue';
import PopulationValue from '@/game/components/galaxy/system/PopulationValue.vue';

export default {
  name: 'system-details',
  props: {
    system: Object,
    isOwnSystem: Boolean,
    color: String,
  },
  components: {
    ResourceDetail,
    PopulationValue,
  },
};
</script>

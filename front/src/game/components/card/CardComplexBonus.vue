<template>
  <div>
    <div
      v-for="bonus in bonuses"
      :key="bonus.key"
      class="complex-bonus">
      <!-- bonus DIRECT -->
      <template v-if="bonus.bonusIn.from === 'none'">
        <div>
          {{ $t(`data.bonus_pipeline_out.${bonus.to}.name`) }}
        </div>
        <div>
          <strong>{{ bonus.value | mixed(1, true) }}</strong>
          <svgicon
            v-show="bonus.bonusOut.icon !== 'resource/resource'"
            :name="bonus.bonusOut.icon" />
        </div>
      </template>

      <!-- bonus FROM stellar_body -->
      <template v-else-if="bonus.bonusIn.from === 'stellar_body'">
        <div>
          {{ $t(`data.bonus_pipeline_out.${bonus.to}.name`) }}
          (<strong>
            {{ bonus.value | mixed }} ×
            <template v-if="body">{{ body[bonus.bonusIn.from_key] }}</template>
            <svgicon :name="bonus.bonusIn.icon" />
          </strong>)
        </div>
        <div>
          <strong v-if="body">{{ mul(bonus.value, body[bonus.bonusIn.from_key]) }}</strong>
          <strong v-else>?</strong>
          <svgicon
            v-show="bonus.bonusOut.icon !== 'resource/resource'"
            :name="bonus.bonusOut.icon" />
        </div>
      </template>

      <!-- bonus FROM outside  -->
      <template v-else-if="['stellar_system', 'player', 'army', 'spy', 'speaker'].includes(bonus.bonusIn.from)">
        <template v-if="bonus.from === bonus.to">
          <div>
            {{ $t(`data.bonus_pipeline_out.${bonus.to}.name`) }}
          </div>
          <div>
            <strong>
              {{ bonus.value * 100 | signed }}%
            </strong>
            <svgicon
              v-show="bonus.bonusOut.icon !== 'resource/resource'"
              :name="bonus.bonusOut.icon" />
          </div>
        </template>
        <template v-else>
          <div>
            {{ $t(`data.bonus_pipeline_out.${bonus.to}.name`) }}
            (<strong>
              {{ bonus.value | mixed }} ×
              <template v-if="system">{{ system[bonus.bonusIn.from_key].value }}</template>
              <svgicon :name="bonus.bonusIn.icon" />
            </strong>)
          </div>
          <div>
            <strong v-if="system">{{ mul(bonus.value, system[bonus.bonusIn.from_key].value) }}</strong>
            <strong v-else>?</strong>
            <svgicon
              v-show="bonus.bonusOut.icon !== 'resource/resource'"
              :name="bonus.bonusOut.icon" />
          </div>
        </template>
      </template>

      <!-- bonus FROM  -->
      <template v-else>
        {{ $t('card.complex_bonus.not_implemented') }}
      </template>
    </div>
  </div>
</template>

<script>
import format from '@/utils/format';

export default {
  name: 'card-complex-bonus',
  props: {
    bonus: Array,
    // stellar system
    body: {
      type: Object,
      required: false,
    },
    system: {
      type: Object,
      required: false,
    },
    // player
    player: {
      type: Object,
      required: false,
    },
  },
  computed: {
    bonuses() {
      return this.bonus.map((bonus) => {
        const bonusIn = this.bonusIn.find((b) => bonus.from === b.key);
        const bonusOut = this.bonusOut.find((b) => bonus.to === b.key);

        return { ...bonus, ...{ bonusIn, bonusOut } };
      });
    },
    bonusIn() { return this.$store.state.game.data.bonus_pipeline_in; },
    bonusOut() { return this.$store.state.game.data.bonus_pipeline_out; },
  },
  methods: {
    mul(value, prop) {
      if (prop !== '?') {
        const result = value * prop;
        return format.mixed(result, 1, true);
      }

      return '?';
    },
    formatMixedOrString(val) {
      if (typeof val === 'string') {
        return val;
      }
      return format.mixed(val, 1, true);
    },
  },
};
</script>

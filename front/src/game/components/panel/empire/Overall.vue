<template>
  <div class="panel-content is-small">
    <v-scrollbar class="has-padding">
      <h1 class="panel-default-title">
        {{ $t('panel.empire.overall_title') }}
      </h1>

      <section>
        <div class="panel-content-number-bloc">
          <div class="label">
            {{ $t('panel.empire.system_count') }}
          </div>
          <div class="value">
            {{ player.stellar_systems.length }}/{{ player.max_systems.value }}
          </div>
        </div>
        <div class="panel-content-number-bloc">
          <div class="label">
            {{ $t('panel.empire.dominion_count') }}
          </div>
          <div class="value">
            {{ player.dominions.length }}/{{ player.max_dominions.value }}
          </div>
        </div>
        <div class="panel-content-number-bloc">
          <div class="label">
            {{ $t('panel.empire.dominion_rate') }}
          </div>
          <div class="value">
            {{ player.dominion_rate.value * 100 }}%
          </div>
        </div>
      </section>

      <hr class="panel-default-hr">

      <section>
        <div class="panel-content-number-bloc">
          <div class="label">
            {{ $t('panel.empire.credit_income') }}
          </div>
          <div class="value">
            {{ player.credit.change | float(1, true) }}
          </div>
        </div>
        <div class="panel-content-number-bloc">
          <div class="label">
            {{ $t('panel.empire.technology_income') }}
          </div>
          <div class="value">
            {{ player.technology.change | float(1, true) }}
          </div>
        </div>
        <div class="panel-content-number-bloc">
          <div class="label">
            {{ $t('panel.empire.ideology_income') }}
          </div>
          <div class="value">
            {{ player.ideology.change | float(1, true) }}
          </div>
        </div>
      </section>

      <hr class="panel-default-hr">

      <section>
        <div class="panel-content-number-bloc">
          <div class="label">
            {{ $t('panel.empire.lex_count') }}
          </div>
          <div class="value">
            {{ player.doctrines.length }}
          </div>
        </div>
        <div class="panel-content-number-bloc">
          <div class="label">
            {{ $t('panel.empire.policy_count') }}
          </div>
          <div class="value">
            {{ player.policies.length }}/{{ player.max_policies }}
          </div>
        </div>
        <div class="panel-content-number-bloc">
          <div class="label">
            {{ $t('panel.empire.patent_count') }}
          </div>
          <div class="value">
            {{ player.patents.length }}
          </div>
        </div>
      </section>
    </v-scrollbar>
  </div>
</template>

<script>
export default {
  name: 'empire-overall-panel',
  computed: {
    player() { return this.$store.state.game.player; },
  },
};
</script>

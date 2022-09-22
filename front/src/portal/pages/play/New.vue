<template>
  <div class="panel-fragment">
    <div
      class="panel-content is-full-sized"
      ref="container">
      <div class="panel-header">
        <h1>
          {{ $t('page.play.new.header') }}
        </h1>

        <button
          class="default-button"
          :disabled="!isValid"
          @click="save">
          <template v-if="waiting">...</template>
          <template v-else>{{ $t('page.play.new.save') }}</template>
        </button>
      </div>

      <v-scrollbar
        v-if="loaded"
        class="content">
        <router-link
          v-if="scenario"
          class="close-button"
          :to="`/play/from-scenarios/${scenario.game_data.speed}`">
          {{ $t('page.instance.back') }}
        </router-link>
        <div
          v-if="scenario"
          class="column-container is-two">
          <div class="column-item">
            <div class="default-input">
              <label for="name">
                {{ $t('page.play.new.field_name') }}
                <span>{{ instance.name.length }}/120</span>
              </label>
              <input
                type="text"
                id="name"
                autocomplete="off"
                v-model="instance.name" />
            </div>

            <div class="default-input">
              <label for="description">
                {{ $t('page.play.new.field_description') }}
                <span>{{ instance.description.length }}/5000</span>
              </label>
              <textarea
                id="description"
                v-model="instance.description">
              </textarea>
            </div>

            <h2 class="default-title">{{ $t('page.play.new.field_factions') }}</h2>
            <div
              v-for="(faction, i) in scenario.game_data.factions"
              :key="faction.key"
              class="default-input">
              <label :for="`faction-${faction.key}`">
                <span
                  class="has-color-indicator"
                  :class="getTheme(faction.key)">
                  {{ faction.key }}
                </span>
                <strong>{{ faction.capacity }}</strong>
              </label>
              <div class="input-slider">
                <vue-slider
                  :id="`faction-${faction.key}`"
                  :min="minPlayerByFaction"
                  :max="maxPlayerByFaction"
                  :interval="1"
                  :marks="maxPlayerByFaction <= 30"
                  :dotSize="16" :height="8"
                  :hideLabel="true" tooltip="none"
                  @change="$forceUpdate()"
                  v-model.number="scenario.game_data.factions[i].capacity">
                </vue-slider>
              </div>
            </div>
          </div>

          <div class="column-item">
            <instance-map
              :size="containerSize"
              :scenario="scenario" />
          </div>

          <hr class="margin">
        </div>
        <div
          class="full-sized-text"
          v-else>
          {{ $t('page.play.new.scenario_not_found') }}
        </div>

        <hr class="margin">
      </v-scrollbar>
      <loading-mask v-else />
    </div>

    <v-scrollbar class="panel-aside">
      <div class="panel-aside-bloc">
        <div class="radio-input is-horizontal">
          <div class="label">
            {{ $t('page.play.new.field_opening') }}
          </div>
          <div class="content">
            <div
              v-for="value in start_settings"
              :key="`start-${value}`"
              class="content-item">
              <input
                type="radio"
                :id="`start-${value}`"
                :value="value"
                v-model="instance.start_setting">
              <label :for="`start-${value}`">
                <strong>{{ $t(`page.play.new.start_settings['${value}']`) }}</strong>
              </label>
            </div>
          </div>
        </div>

        <div
          v-if="instance.start_setting === 'auto'"
          class="default-input">
          <label for="opening_date">{{ $t('page.play.new.field_opening_date') }}</label>
          <input
            type="datetime-local"
            id="opening_date"
            v-model="instance.opening_date" />
        </div>

        <div class="radio-input is-horizontal">
          <div class="label">
            {{ $t('page.play.new.field_registrations') }}
          </div>
          <div class="content">
            <div
              v-for="value in registration_types"
              :key="`registration-${value}`"
              class="content-item">
              <input
                type="radio"
                :id="`registration-${value}`"
                :value="value"
                v-model="instance.registration_type">
              <label :for="`registration-${value}`">
                <strong>{{ $t(`page.play.new.registration_types['${value}']`) }}</strong>
              </label>
            </div>
          </div>
        </div>

        <div
          v-if="canBeRanked"
          class="radio-input is-horizontal">
          <div class="label">
            {{ $t('page.play.new.field_mode') }}
          </div>
          <div class="content">
            <div
              v-for="value in game_mode_types"
              :key="`game_mode-${value}`"
              class="content-item">
              <input
                type="radio"
                :id="`game_mode-${value}`"
                :value="value"
                v-model="instance.game_mode_type">
              <label :for="`game_mode-${value}`">
                <strong>{{ $t(`page.play.new.game_mode_types['${value}']`) }}</strong>
              </label>
            </div>
          </div>
        </div>
      </div>

      <div
        v-show="isAdmin"
        class="panel-aside-bloc">
        <div class="default-input">
          <label for="seed">{{ $t('page.play.new.field_seed') }}</label>
          <input
            id="seed"
            type="text"
            v-model="instance.seed" />
          <button
            @click="instance.seed = newSeed()"
            class="default-button action">
            ↺
          </button>
        </div>

        <button
          class="default-button"
          @click="instance.seed = scenario.game_data.seed">
          {{ $t('page.play.new.button_seed') }}
        </button>
      </div>

      <hr class="margin">
    </v-scrollbar>
  </div>
</template>

<script>
import Loading from '@/portal/mixins/Loading';
import VueSlider from 'vue-slider-component';

import LoadingMask from '@/portal/components/LoadingMask.vue';
import InstanceMap from '@/portal/components/InstanceMap.vue';

import newSeed from '@/portal/utils';

export default {
  name: 'play-new',
  mixins: [Loading],
  data() {
    return {
      containerSize: 0,
      scenario: undefined,
      waiting: false,
      minPlayerByFaction: 1,
      maxPlayerByFaction: 10,
      instance: {
        name: '',
        description: '',
        start_setting: 'manual',
        opening_date: '',
        registration_type: 'late_registration',
        registration_status: 'closed',
        game_mode_type: 'ranked',
        game_type: 'public',
        public: true,
        factions: [],
        seed: null,
      },
      start_settings: [
        'manual',
        // 'auto',
        // 'when_full',
      ],
      registration_types: ['pre_registration', 'late_registration'],
      game_mode_types: ['ranked', 'casual'],
    };
  },
  computed: {
    data() { return this.$store.state.portal.data; },
    isAdmin() { return this.$store.state.portal.isAdmin; },
    isValid() {
      if (this.instance.name !== '' && this.instance.description !== '' && !this.waiting) {
        if (this.instance.start_setting === 'auto' && this.instance.opening_date === '') {
          return false;
        }
        return true;
      }
      return false;
    },
    canBeRanked() {
      return this.scenario && this.isAdmin && this.scenario.game_data.speed === 'fast';
    },
  },
  methods: {
    async loadData() {
      const resp = await this.releaseLoading(this.$axios.get(`/scenarios/${this.$route.params.sid}`));
      this.scenario = resp.data;

      const defaultFactionCapacity = Math.round(
        resp.data.game_metadata.system_number / 6 / resp.data.game_data.factions.length,
      );

      this.maxPlayerByFaction = defaultFactionCapacity * 3;

      this.instance.name = this.scenario.game_metadata.name;
      this.instance.description = this.scenario.game_metadata.description;

      this.scenario.game_data.factions = this.scenario.game_data.factions
        .map((f) => Object.assign(f, { capacity: defaultFactionCapacity }));
    },
    async save() {
      if (this.isValid) {
        this.waiting = true;

        this.instance.opening_date = new Date(this.instance.opening_date).toISOString();
        this.instance.factions = this.scenario.game_data.factions
          .map((f) => ({ key: f.key, capacity: f.capacity }));

        this.instance.seed = typeof this.instance.seed === 'string'
          ? this.instance.seed.split(',').map((s) => parseInt(s, 10))
          : this.instance.seed;

        if (!this.canBeRanked) {
          this.instance.game_mode_type = 'casual';
        }

        try {
          const { data } = await this.$axios.post(
            '/instances',
            { instance: this.instance, scenario_id: this.scenario.id },
          );

          this.$router.push(`/instance/${data.id}`);
        } catch (err) {
          this.$toastChangesetError(err);
        }

        this.waiting = false;
      }
    },
    getTheme(key) {
      if (this.data.faction) {
        return key
          ? `theme-${this.data.faction.find((f) => f.key === key).theme}`
          : '';
      }
    },
    newSeed() {
      return newSeed();
    },
  },
  mounted() {
    this.containerSize = ((this.$refs.container.clientWidth - (25 * 2)) / 2) - 20;
    this.instance.opening_date = new Date().toISOString().slice(0, -8);
    this.instance.seed = newSeed();
    this.loadData();
  },
  components: {
    LoadingMask,
    InstanceMap,
    VueSlider,
  },
};
</script>

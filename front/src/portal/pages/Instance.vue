<template>
  <default-layout>
    <div class="fluid-panel">
      <v-scrollbar class="panel-aside">
        <template v-if="loaded">
          <template v-if="account.role === 'admin' || account.id === instance.account_id">
            <section class="panel-aside-info">
              <h2>{{ $t('page.instance.manage') }}</h2>
              <p>
                {{ $t('page.instance.status_is') }}
                <strong>{{ $t(`instance.state.${instance.state}.name`) }}</strong>.
              </p>

              <div class="instance-action">
                <button
                  @click="doAction('publish')"
                  v-show="instance.state === 'created'"
                  class="default-button">
                  <template v-if="waiting">...</template>
                  <template v-else>{{ $t('page.instance.publish') }}</template>
                </button>
                <button
                  @click="doAction('start')"
                  v-show="instance.state === 'open'"
                  class="default-button">
                  <template v-if="waiting">...</template>
                  <template v-else>{{ $t('page.instance.start') }}</template>
                </button>
                <button
                  @click="doAction('pause')"
                  v-show="instance.state === 'running'"
                  class="default-button">
                  <template v-if="waiting">...</template>
                  <template v-else>{{ $t('page.instance.pause') }}</template>
                </button>
                <button
                  @click="doAction('resume')"
                  v-show="instance.state === 'paused'"
                  class="default-button">
                  <template v-if="waiting">...</template>
                  <template v-else>{{ $t('page.instance.resume') }}</template>
                </button>
                <button
                  @click="doAction('restart')"
                  v-show="instance.state === 'not_running'"
                  class="default-button">
                  <template v-if="waiting">...</template>
                  <template v-else>{{ $t('page.instance.restart') }}</template>
                </button>
                <button
                  @click="doAction('finish')"
                  v-show="instance.state === 'paused'"
                  class="default-button">
                  <template v-if="waiting">...</template>
                  <template v-else>{{ $t('page.instance.stop') }}</template>
                </button>
              </div>

              <p
                v-if="startingProgress.step !== 0"
                class="starting-progress">
                <span class="label">{{ startingProgress.step }}</span>
                <span class="value">
                  {{ $t(`page.instance.start_steps.${startingProgress.status}`) }}
                </span>
              </p>

              <p
                v-if="account.id !== instance.account_id && account.role === 'admin'"
                style="color: red;">
                {{ $t('page.instance.admin_warning') }}
              </p>
              <p v-else>
                {{ $t('page.instance.owner_warning') }}
              </p>
            </section>
            
            <hr class="separator">
          </template>

          <div
            class="instance-button"
            :class="{ 'active': selected === null }"
            @click="selected = null">
            <div class="instance-button-content">
              <strong>{{ $t('page.instance.overview') }}</strong>
            </div>
          </div>

          <hr class="separator">

          <div
            v-for="f in instance.factions"
            class="instance-button"
            :class="[
              getTheme(f.faction_ref),
              { 'active': selected === f.id },
            ]"
            :key="`faction-${f.id}`"
            @click="selected = f.id">
            <div class="instance-logo">
              <svgicon class="icon" :name="`faction/${f.faction_ref}`" />
            </div>
            <div class="instance-button-content">
              <strong>
                {{ $t(`data.faction.${f.faction_ref}.name`) }}
                <span v-show="chosenFaction === f.id">★</span>
              </strong>
              <span class="instance-button-capacity">
                <span class="label">
                  {{ f.registrations_count }}/{{ f.capacity }}
                </span>
                <span class="gauge-container">
                  <span
                    class="gauge-content"
                    :style="`width: ${(f.registrations_count / f.capacity) * 100}%`">
                  </span>
                </span>
              </span>
            </div>
          </div>

          <hr class="margin">
        </template>
      </v-scrollbar>

      <div
        class="panel-content is-square"
        ref="container">
        <template v-if="loaded">
          <router-link
            class="close-button"
            :to="`/play/${instance.game_metadata.speed}`">
            {{ $t('page.instance.back') }}
          </router-link>
          <div class="panel-header is-hover">
            <h1><strong>{{ instance.name }}</strong></h1>

            <button
              @click="play"
              v-show="instance.state !== 'created' && instance.state !== 'ended'"
              class="default-button"
              :class="{
                'disabled': instance.state !== 'running',
                'instance-play-button': instance.state === 'running',
              }">
              <template v-if="!registered">
                {{ $t('page.instance.choose_faction') }}
              </template>
              <template v-else-if="instance.state !== 'running'">
                {{ $t('page.instance.wait') }}
              </template>
              <template v-else>
                <template v-if="waiting">...</template>
                <template v-else>{{ $t('page.instance.play') }}</template>
              </template>
              <span
                v-show="instance.state === 'running'"
                class="instance-play-button-icon">
                <svgicon class="icon" name="action/fight" />
              </span>
            </button>
          </div>

          <div class="content is-instance">
            <instance-map
              :selected="getSelectedFactionKey()"
              :size="containerSize"
              :scenario="instance" />
          </div>
        </template>

        <loading-mask v-else />
      </div>

      <v-scrollbar class="panel-aside">
        <template v-if="loaded">
          <template v-if="!selected">
            <section class="panel-aside-info">
              <h2>{{ $t('page.instance.description') }}</h2>
              <p
                class="is-large"
                v-html="nl2br(instance.description)"></p>
            </section>

            <section class="panel-aside-info">
              <h2>{{ $t('page.instance.find_players') }}</h2>
              <p>{{ $t('page.instance.ea_note') }}</p>
              <div
                v-if="isSteam"
                class="default-input has-m10">
                <label for="name">{{ $t('page.instance.discord_link') }}</label>
                <input
                  v-model="discordLink"
                  type="text"
                  disabled />
                <button
                  @click="copyToClipboard(discordLink)"
                  v-tooltip="$t('page.instance.clipboard_copy')"
                  class="default-button action">
                  ⇪
                </button>
              </div>
              <a
                v-else
                class="default-button has-m10"
                target="_blank"
                :href="discordLink">
                {{ $t('page.tutorial.join_discord') }}
              </a>
            </section>
          </template>

          <template v-else>
            <section class="panel-aside-info">
              <div class="instance-action">
                <button
                  v-if="instance.registration_status !== 'open'"
                  class="default-button disabled">
                  {{ $t('page.instance.registration_closed') }}
                </button>
                <button
                  v-else-if="registered && registered.faction.id !== faction.id"
                  class="default-button disabled">
                  {{ $t('page.instance.already_registered') }}
                </button>
                <button
                  v-else-if="emptySeats.length === 0"
                  class="default-button disabled">
                  {{ $t('page.instance.no_empty_seats') }}
                </button>
                <button
                  v-else-if="registered && ['running', 'paused'].includes(instance.state)"
                  class="default-button disabled">
                  {{ $t('page.instance.game_already_running') }}
                </button>
                <button
                  v-else-if="registered && registered.faction.id === faction.id"
                  @click="unjoin(registered.faction.id, registered.profile.id)"
                  class="default-button">
                  <template v-if="waiting">...</template>
                  <template v-else>{{ $t('page.instance.unregister') }}</template>
                </button>
                <button
                  v-else
                  @click="join()"
                  v-tooltip="account.is_free
                    ? $t('page.instance.join_money_info')
                    : ''"
                  class="default-button"
                  :class="{ 'disabled': !enoughMoney }">
                  {{ $t('page.instance.register') }}
                  <template v-if="account.is_free">
                    ({{ $t('page.instance.join_money_amount', { amount: 500 }) }})
                  </template>
                </button>
              </div>

              <p>
                <a href="#" @click="showRegistration = !showRegistration">
                  <template v-if="showRegistration">{{ $t('page.instance.hide_members') }}</template>
                  <template v-else>{{ $t('page.instance.show_members') }}</template>
                </a>
              </p>
            </section>
            
            <hr class="separator">

            <table
              v-if="showRegistration"
              class="default-table profiles-table">
              <tr
                v-for="r in takenSeats"
                :key="`registration-${r.id}`">
                <td>
                  <strong>{{ r.profile.name }}</strong>
                  <span v-if="registered && registered.profile.id === r.profile.id">★</span>
                </td>
              </tr>
              <tr
                v-for="i in emptySeats"
                :key="`free-registration-${i}`">
                <td>{{ $t('page.instance.free_spot') }}</td>
              </tr>
            </table>

            <template v-else>
              <section class="panel-aside-info">
                <h2>{{ $t(`data.faction.${faction.faction_ref}.name`) }}</h2>
                <p
                  class="is-large"
                  v-html="nl2br($t(`data.faction.${faction.faction_ref}.description`))"></p>
              </section>

              <section class="panel-aside-info">
                <h2>{{ $t('page.instance.initial_character') }}</h2>
                <p class="is-large">
                  <strong>{{ $tc(`data.character.${factionData.initial_character_type}.name`) }}</strong>
                  (<strong>{{
                    $tc(`data.character.${factionData.initial_character_type}.specializations.${factionData.initial_character_spec1}`)
                  }}</strong>)
                </p>
              </section>

              <section class="panel-aside-info">
                <h2>{{ $t('page.instance.tradition') }}</h2>
                <p
                  v-for="tradition in factionData.traditions"
                  :key="tradition.key"
                  class="is-large">
                  <strong>{{ $t(`data.tradition.${tradition.key}.name`) }}</strong>
                  ({{ $t(`data.tradition.${tradition.key}.bonus`) }})<br>
                  {{ $t(`data.tradition.${tradition.key}.description`) }}
                </p>
              </section>
            </template>
          </template>

          <hr class="margin">
        </template>
      </v-scrollbar>
    </div>
  </default-layout>
</template>

<script>
import config from '@/config';

import Loading from '@/portal/mixins/Loading';

import LoadingMask from '@/portal/components/LoadingMask.vue';
import InstanceMap from '@/portal/components/InstanceMap.vue';

import DefaultLayout from '@/portal/layouts/Default.vue';

export default {
  name: 'instance',
  mixins: [Loading],
  data() {
    return {
      isSteam: config.IS_STEAM,
      containerSize: 0,
      selected: null,
      instance: null,
      registrations: [],
      registered: null,
      waiting: false,
      polling: null,
      showRegistration: false,
      startingProgress: {
        step: 0,
        status: '',
      },
    };
  },
  computed: {
    data() { return this.$store.state.portal.data; },
    account() { return this.$store.state.portal.account; },
    activeProfile() { return this.$store.state.portal.activeProfile; },
    discordLink() { return `https://discord.gg/${this.$t('link.discord_invite')}`; },
    faction() {
      return this.instance.factions.find((f) => f.id === this.selected);
    },
    factionData() {
      return this.data.faction.find((f) => f.key === this.faction.faction_ref);
    },
    emptySeats() {
      if (this.faction) {
        const length = this.faction.capacity - this.faction.registrations_count;
        return Array.from({ length }, (x, i) => i);
      }
      return [];
    },
    takenSeats() {
      return this.registrations.filter((r) => r.faction.id === this.faction.id);
    },
    chosenFaction() {
      return this.registered
        ? this.registered.faction.id
        : null;
    },
    enoughMoney() {
      if (this.account.is_free) {
        return this.account.money >= 500;
      }

      return true;
    },
  },
  methods: {
    async loadData(iid, releaseWaiting = false) {
      try {
        const [instance, registrations] = await this.waitFor([
          this.$axios.get(`/instances/${iid}`),
          this.$axios.get(`/instances/${iid}/registrations`),
        ]);

        // disallow entering not slow instane for free account
        if (this.account.is_free && instance.data.game_data.speed !== 'slow') {
          this.$router.push('/');
        }

        this.instance = instance.data;
        this.registrations = registrations.data;
        this.registered = this.registrations.find((r) => this.activeProfile.id === r.profile.id);
        this.loaded = true;

        if (releaseWaiting) {
          this.waiting = false;
        }
      } catch (err) {
        this.$toastError('Erreur');
      }
    },
    async join() {
      if (this.enoughMoney && !this.waiting) {
        this.waiting = true;

        try {
          await this.$axios.post(
            `/registrations/profile/${this.activeProfile.id}`,
            { instance_id: this.instance.id, faction_id: this.selected },
          );

          if (this.account.is_free && this.instance.game_data.speed === 'slow') {
            this.$store.commit('portal/updateAccountMoney', -500);
          }

          await this.loadData(this.instance.id);
        } catch (err) {
          this.$toastError(err.response.data.message);
        }

        this.waiting = false;
      }
    },
    async unjoin(factionId) {
      if (!this.waiting) {
        this.waiting = true;

        try {
          await this.$axios.put(`/registrations/profile/${this.activeProfile.id}/cancel`, { faction_id: factionId });

          if (this.account.is_free && this.instance.game_data.speed === 'slow') {
            this.$store.commit('portal/updateAccountMoney', 500);
          }

          await this.loadData(this.instance.id);
        } catch (err) {
          this.$toastError(err.response.data.message);
        }

        this.waiting = false;
      }
    },
    async play() {
      if (!this.waiting && this.registered && this.instance.state === 'running') {
        this.waiting = true;

        try {
          const { data } = await this.$axios
            .get(`/instances/${this.instance.id}/game/start/${this.registered.token}`);

          this.$ambiance.sound('play');
          this.$store.commit('game/init', data);
          this.$ambiance.changeContext('game');

          this.$router.push('/game');
        } catch (err) {
          this.$toastError(err.response.data.message);
        }
      }
    },
    async doAction(action) {
      if (!this.waiting) {
        this.waiting = true;

        if (action === 'start' || action === 'restart') {
          this.$socket.user.on('broadcast', ({ status, instanceId }) => {
            if (this.instance.id !== instanceId) return;
              this.startingProgress = {
                step: this.startingProgress.step + 1,
                status,
              };
          });
          this.$socket.instance.push('start', {}, 30 * 60 * 1000)
            .receive('ok', () => {
              this.startingProgress = { step: 0, status: '' };
              this.loadData(this.instance.id, true);
            })
            .receive('timeout', () => {
              this.$toasted.error('Timeout');
            })
            .receive('error', ({ reason }) => {
              this.$toastError(reason);
            });
          return;
        }

        try {
          await this.$axios.put(`/instances/${this.instance.id}/${action}`);
          await this.loadData(this.instance.id);
        } catch (err) {
          this.$toastError(err.response.data.message);
        }

        this.waiting = false;
      }
    },
    async copyToClipboard() {
      await navigator.clipboard.writeText(this.discordLink);
    },
    nl2br(text) {
      return text.replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1<br />$2');
    },
    getTheme(key) {
      if (this.data.faction) {
        return key
          ? `theme-${this.data.faction.find((f) => f.key === key).theme}`
          : '';
      }
    },  
    getSelectedFactionKey() {
      if (this.selected) {
        return this.instance.factions.find((f) => f.id === this.selected).faction_ref;
      }
      return null;
    },
    async copyToClipboard(text) {
      await navigator.clipboard.writeText(text);
    },
  },
  async mounted() {
    this.containerSize = ((this.$refs.container.clientWidth - (25 * 2)));
    await this.loadData(this.$route.params.iid);
    this.$socket.joinInstance(this.instance.id);

    this.polling = setInterval(() => {
      this.loadData(this.$route.params.iid);
    }, this.$config.POLLING.SHORT);
  },
  beforeDestroy() {
    this.$socket.leaveInstance();
    clearInterval(this.polling);
  },
  components: {
    LoadingMask,
    InstanceMap,
    DefaultLayout,
  },
};
</script>

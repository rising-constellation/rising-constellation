<template>
  <div class="panel-fragment">
    <div class="panel-content is-full-sized">
      <div class="content is-tutorial">
        <div class="tutorial-box">
          <h2 v-html="$tmd('page.tutorial.title')"></h2>
          <div class="button">
            <button
              @click="start"
              class="default-button fullsized"
              :class="{ 'disabled': waiting }">
              <template v-if="waiting">
                {{ $t('page.tutorial.waiting') }}
              </template>
              <template v-else>
                {{ $t('page.tutorial.play') }}
              </template>
            </button>
          </div>
          <div class="info">
            <p>{{ $t('page.tutorial.description_1') }}</p>
            <p>{{ $t('page.tutorial.description_2') }}</p>
          </div>
        </div>
      </div>
    </div>

    <v-scrollbar class="panel-aside">
      <div class="panel-aside-info">
        <h2>{{ $t('page.tutorial.find_help') }}</h2>
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
      </div>

      <div class="panel-aside-info">
        <h2>{{ $t('page.tutorial.learn_more') }}</h2>
        <div
          v-if="isSteam"
          class="default-input has-m10">
          <label for="name">{{ $t('page.tutorial.wiki_link') }}</label>
          <input
            v-model="wikiLink"
            type="text"
            disabled />
          <button
            @click="copyToClipboard(wikiLink)"
            v-tooltip="$t('page.instance.clipboard_copy')"
            class="default-button action">
            ⇪
          </button>
        </div>
        <a
          v-else
          class="default-button has-m10"
          target="_blank"
          :href="wikiLink">
          {{ $t('page.tutorial.to_the_wiki') }}
        </a>
      </div>

      <div class="panel-aside-info">
        <h2>{{ $t('page.tutorial.fight_simulator') }}</h2>
        <router-link
          class="default-button has-m10"
          to="/fight-simulator">
          {{ $t('page.tutorial.fight_simulator_access') }}
        </router-link>
      </div>


    </v-scrollbar>
  </div>
</template>

<script>
import config from '@/config';

export default {
  name: 'play-tutorial',
  data() {
    return {
      isSteam: config.IS_STEAM,
      waiting: false,
    };
  },
  computed: {
    activeProfile() { return this.$store.state.portal.activeProfile; },
    discordLink() { return `https://discord.gg/${this.$t('link.discord_invite')}`; },
    wikiLink() { return 'https://rising-constellation.fandom.com/fr/wiki/Wiki_Rising_Constellation'; },
  },
  methods: {
    async start() {
      if (!this.waiting) {
        this.waiting = true;

        try {
          const { data } = await this.$axios.get(`/instances/tutorial/game/start/${this.activeProfile.id}`);

          this.$ambiance.sound('play');
          this.$store.commit('game/init', data);
          this.$ambiance.changeContext('game');

          this.$router.push('/game');
        } catch (err) {
          this.waiting = false;
          this.$toastError(err.response.data.message);
        }
      }
    },
    async copyToClipboard(text) {
      await navigator.clipboard.writeText(text);
    },
  },
};
</script>

<template>
  <div class="panel-fragment">
    <div class="panel-content is-square">
      <div class="panel-header">
        <h1 v-html="$tmd('page.profile_detail.header')" />
      </div>

      <v-scrollbar
        v-if="loaded"
        class="content">
        <div class="column-container is-two">
          <div class="column-item">
            <div class="cards-container is-centered">
              <div>
                <player-card
                  :profile="profile"
                  class="is-highlighted" />
                <br />

                <button
                  v-show="mode === 'new'"
                  style="position: relative; z-index: 1; margin-top: 10px; width: 300px;"
                  :disabled="!isValid"
                  @click="createFirstProfile"
                  class="default-button">
                  <template v-if="waiting">...</template>
                  <template v-else>{{ $t('page.profile_detail.begin') }}</template>
                </button>

                <button
                  v-show="mode === 'edit'"
                  style="position: relative; z-index: 1; margin-top: 10px; width: 300px;"
                  :disabled="!isValid"
                  @click="save"
                  class="default-button">
                  <template v-if="waiting">...</template>
                  <template v-else>{{ $t('page.profile_detail.save') }}</template>
                </button>
              </div>
            </div>
          </div>

          <div class="column-item">
            <div
              :class="{ 'has-error': !(profile.name.length <= 30) }"
              class="default-input">
              <label for="name">{{ $t('page.profile_detail.field_name') }}</label>
              <input
                type="text"
                id="name"
                autocomplete="off"
                v-model="profile.name" />
            </div>

            <div
              :class="{ 'has-error': !(profile.full_name.length <= 120) }"
              class="default-input">
              <label for="full_name">{{ $t('page.profile_detail.field_full_name') }}</label>
              <input
                type="text"
                id="full_name"
                autocomplete="off"
                v-model="profile.full_name" />
              <button
                @click="generateName"
                class="default-button action">
                ↺
              </button>
            </div>

            <div
              :class="{ 'has-error': !(profile.description.length <= 120) }"
              class="default-input">
              <label for="description">{{ $t('page.profile_detail.field_description') }}</label>
              <input
                type="text"
                id="description"
                autocomplete="off"
                v-model="profile.description" />
            </div>

            <div
              :class="{ 'has-error': !(profile.age >= 10 && profile.age <= 140) }"
              class="default-input">
              <label for="age">{{ $t('page.profile_detail.field_age') }}</label>
              <input
                id="age"
                type="number"
                v-model.number="profile.age" />
            </div>

            <div
              :class="{ 'has-error': !(profile.long_description.length <= 1200) }"
              class="default-input">
              <label for="long_description">{{ $t('page.profile_detail.field_long_description') }}</label>
              <textarea
                id="long_description"
                v-model="profile.long_description">
              </textarea>
            </div>
          </div>
        </div>

        <hr class="margin">
      </v-scrollbar>
      <loading-mask v-else />
    </div>

    <v-scrollbar
      class="panel-aside"
      v-if="loaded">
      <div class="panel-aside-bloc">
        <div class="radio-input is-image">
          <div class="label">
            {{ $t('page.profile_detail.profile_picture') }}
          </div>
          <div class="content">
            <div
              v-for="(avatar, i) in avatars"
              :key="`avatar-${i}`"
              class="content-item">
              <input
                type="radio"
                :id="`avatar-${i}`"
                :value="avatar"
                v-model="profile.avatar">
              <label :for="`avatar-${i}`">
                <img :src="resolvePath(avatar)">
              </label>
            </div>
          </div>
        </div>
      </div>

      <hr class="margin">
    </v-scrollbar>
    <loading-mask
      v-else
      class="panel-aside" />
  </div>
</template>

<script>
import Loading from '@/portal/mixins/Loading';
import Path from '@/utils/path';

import LoadingMask from '@/portal/components/LoadingMask.vue';
import PlayerCard from '@/portal/components/card/PlayerCard.vue';

const genders = ['male', 'female'];
const availableAvatars = [
  'avatarM_001.jpg', 'avatarM_002.jpg', 'avatarM_003.jpg', 'avatarM_004.jpg', 'avatarM_005.jpg', 'avatarM_006.jpg', 'avatarM_007.jpg',
  'avatarF_001.jpg', 'avatarF_002.jpg', 'avatarF_003.jpg', 'avatarF_004.jpg', 'avatarF_005.jpg', 'avatarF_006.jpg', 'avatarF_007.jpg',
];

export default {
  name: 'profile-detail',
  mixins: [Loading],
  data() {
    return {
      mode: '',
      waiting: false,
      avatars: [],
      profile: {
        avatar: '',
        name: '',
        full_name: '',
        description: '',
        long_description: '',
        age: 0,
      },
    };
  },
  computed: {
    account() { return this.$store.state.portal.account; },
    culture() { return this.$store.state.portal.data.culture; },
    isValid() {
      if (this.profile) {
        return this.profile.name && this.profile.age
          && availableAvatars.includes(this.profile.avatar)
          && !this.waiting;
      }

      return false;
    },
  },
  methods: {
    async createFirstProfile() {
      if (this.isValid) {
        this.waiting = true;

        try {
          // create new profile
          const resp = await this.$axios.post(
            `/accounts/${this.account.id}/profiles`,
            { aid: this.account.id, profile: this.profile },
          );

          // set profile to store and settings
          const { data } = await this.$axios.get(`/accounts/${this.account.id}/profiles`);
          const profile = data.find((p) => p.id === resp.data.id);
          await this.$store.dispatch('portal/updateActiveProfile', profile);

          // redirect
          this.$router.push('/play/tutorial');
        } catch (err) {
          this.$toastChangesetError(err);
        }

        this.waiting = false;
      }
    },
    async save() {
      if (this.isValid) {
        this.waiting = true;

        try {
          await this.$axios.put(`/profiles/${this.profile.id}`, { profile: this.profile });

          // update profile to store and settings
          const { data } = await this.$axios.get(`/accounts/${this.account.id}/profiles`);
          const profile = data.find((p) => p.id === this.profile.id);
          await this.$store.dispatch('portal/updateActiveProfile', profile);
        } catch (err) {
          this.$toastChangesetError(err);
        }

        this.waiting = false;
      }
    },
    async loadData(pid) {
      const { data } = await this.$axios.get(`/profiles/${pid}`);
      Object.keys(data).forEach((key) => {
        if (data[key] === null) {
          data[key] = '';
        }
      });
      Object.assign(this.profile, data);
      this.releaseLoading(0);
    },
    async generateName() {
      this.profile.full_name = await this.loadName();
    },
    async loadName() {
      const culture = this.culture[Math.floor(Math.random() * this.culture.length)];
      const gender = genders[Math.floor(Math.random() * genders.length)];

      const [firstname, lastname] = await Promise.all([
        this.$axios.get(`/name/${culture.firstname_repo[gender]}/1`),
        this.$axios.get(`/name/${culture.lastname_repo}/1`),
      ]);

      return `${firstname.data[0]} ${lastname.data[0]}`;
    },
    resolvePath(filename) {
      return Path.relative(`data/avatars/${filename}`);
    },
  },
  async mounted() {
    const shuffledAvatars = availableAvatars.sort(() => Math.random() - 0.5);
    this.avatars = shuffledAvatars;

    // fetch query params, setup mode
    this.mode = !this.$route.query.mode
      ? 'new'
      : this.$route.query.mode;

    if (this.mode === 'new') {
      this.profile = {
        avatar: shuffledAvatars[0],
        name: this.account.name,
        full_name: '',
        description: '',
        long_description: '',
        age: 40,
      };
      this.releaseLoading(0);
    } else {
      this.loadData(this.$route.params.pid);
    }
  },
  components: {
    LoadingMask,
    PlayerCard,
  },
};
</script>

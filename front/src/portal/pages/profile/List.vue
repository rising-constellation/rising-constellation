<template>
  <div class="panel-fragment">
    <div class="panel-content is-medium">
      <div class="panel-header">
        <h1 v-html="$tmd('page.profile_list.header', { profileCount: profiles.length, maxProfiles: maxProfiles })" />
      </div>

      <v-scrollbar class="content">
        <div class="cards-container">
          <player-card
            v-for="profile in profiles"
            :key="profile.id"
            :profile="profile"
            @click.native="$router.push(`/profiles/${profile.id}?mode=edit`)"
            class="is-highlighted" />

          <div
            v-for="slot in emptySlots"
            :key="`slot-${slot}`"
            class="card-container"
            @click="$router.push(`/profiles/new?mode=new`)">
            <div class="card-header">
              <div class="card-header-icon">
                <svgicon class="icon" name="logo/simple" />
              </div>
              <div class="card-header-content">
                <div class="title-large nowrap">
                </div>
              </div>
            </div>
            <div class="card-body">
              <div class="card-illustration">
                <img :src="path('empty.jpg')" />
              </div>

              <div class="card-information">
                <div class="card-panel-window">
                  <div class="card-panel-container">
                    <div class="card-panel">
                      {{ $t('page.profile_list.profile_is_free') }}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <hr class="margin">
      </v-scrollbar>
    </div>

    <v-scrollbar class="panel-aside">
    </v-scrollbar>
  </div>
</template>

<script>
import PlayerCard from '@/portal/components/card/PlayerCard.vue';
import Path from '@/utils/path';

export default {
  name: 'profile-list',
  data() {
    return {
      maxProfiles: 2,
    };
  },
  computed: {
    profiles() { return this.$store.state.portal.profiles; },
    emptySlots() { return [...Array(this.maxProfiles - this.profiles.length).keys()]; },
  },
  methods: {
    path(filename) { return Path.relative(`data/avatars/${filename}`); },
  },
  components: {
    PlayerCard,
  },
};
</script>

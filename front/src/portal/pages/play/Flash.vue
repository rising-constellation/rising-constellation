<template>
  <div class="panel-fragment">
    <div class="panel-content is-full-sized">
      <div
        v-if="account.is_free"
        class="free-dashed-overlay">
        <div class="fd-content">
          <h1>{{ $t('page.play.free_locked_title') }}</h1>
          <p>{{ $t('page.play.free_locked_content') }}</p>
          <footer>
            <router-link to="/upgrade">
              {{ $t('page.play.free_locked_link') }}
            </router-link>
          </footer>
        </div>
      </div>
      <div class="panel-header">
        <h1 v-html="$tmd('page.play.fast.header')" />

        <router-link
          to="/play/from-scenarios/fast"
          class="default-button">
          <svgicon class="icon" name="bookmark" />
          {{ $t('page.play.new_game') }}
        </router-link>
      </div>

      <v-scrollbar
        v-if="loaded"
        class="content">
        <div
          class="default-help"
          v-html="$tmd('page.play.ea_disclaimer')">
        </div>

        <div
          v-if="instances.length === 0"
          class="full-sized-text">
          {{ $t('page.play.no_game_found') }}
        </div>
        <template v-else>
          <table class="default-table instances-table">
            <template v-for="instance in instances">
              <instance-row
                @open="$router.push(`/instance/${instance.id}`)"
                :key="instance.id"
                :instance="instance"
                :profiles="profiles" />
            </template>
          </table>
        </template>
      </v-scrollbar>
      <loading-mask v-else />
    </div>

    <v-scrollbar
      :class="{ 'is-free-dashed': account.is_free }"
      class="panel-aside">
      <div class="panel-aside-bloc">
        <div class="radio-input is-horizontal">
          <div class="label">
            {{ $t('page.play.games') }}
          </div>
          <div class="content">
            <div
              v-for="{key, value, label} in availableStates"
              :key="`status-${key}`"
              class="content-item">
              <input
                type="radio"
                :id="`status-${key}`"
                :value="value"
                v-model="state">
              <label :for="`status-${key}`">
                <strong>{{ label }}</strong>
              </label>
            </div>
          </div>
        </div>
      </div>

      <hr class="margin">
    </v-scrollbar>
  </div>
</template>

<script>
import Loading from '@/portal/mixins/Loading';
import InstanceList from '@/portal/mixins/InstanceList';

import LoadingMask from '@/portal/components/LoadingMask.vue';
import InstanceRow from '@/portal/components/InstanceRow.vue';

export default {
  name: 'play-flash',
  mixins: [Loading, InstanceList('fast')],
  computed: {
    account() { return this.$store.state.portal.account; },
  },
  components: {
    LoadingMask,
    InstanceRow,
  },
};
</script>

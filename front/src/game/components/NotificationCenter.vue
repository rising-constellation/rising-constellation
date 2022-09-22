<template>
  <div class="notification-center">
    <div
      :class="{ 'is-hidden': textNotifs.length === 0 }"
      class="text-notification-container">
      <div class="text-notification-items">
        <div
          v-for="notif in textNotifs"
          :key="notif.id"
          class="text-notification-item"
          v-html="$tmd(`notification.text.${notif.key}`, notif.data)"
          @click="discardAndCenterTextNotif(notif)">
        </div>
      </div>
      <div
        v-if="textNotifs.length - 1 > 0"
        class="text-notification-counter">
        {{ textNotifs.length - 1 }}+
      </div>
    </div>

    <div
      :class="{ 'is-hidden': boxNotifs.length === 0 }"
      class="box-notification-container">
      <div
        v-if="boxNotifs.length > 0"
        class="box-notification-item">
        <notif-dispatcher :notification="currentBoxNotif" />

        <button
          class="box-notification-system"
          v-if="currentBoxNotif.system_id"
          v-tooltip.left="$t('notification.box.center_system')"
          @click="openSystem(currentBoxNotif.system_id)">
          <svgicon name="disc" />
        </button>

        <div class="box-notification-footer">
          <div
            class="button"
            @click="closeCurrentBoxNotif">
            {{ $t('notification.box.close') }}
            <template v-if="boxNotifs.length > 1">
              (+{{ boxNotifs.length - 1 }})
            </template>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import NotifDispatcher from '@/game/components/box-notification/NotifDispatcher.vue';

let interval;

export default {
  name: 'notification-center',
  computed: {
    textNotifs() { return this.$store.state.game.textNotifications.slice().reverse(); },
    boxNotifs() { return this.$store.state.game.boxNotifications; },
    currentBoxNotif() {
      return this.boxNotifs.length > 0
        ? this.boxNotifs[0]
        : null;
    },
  },
  methods: {
    discardAndCenterTextNotif(notif) {
      if (notif.system_id) {
        this.openSystem(notif.system_id);
      }

      this.$store.commit('game/discardTextNotification', notif.id);
    },
    openSystem(systemId) {
      this.$store.dispatch('game/openSystem', { vm: this, id: systemId });
    },
    closeCurrentBoxNotif() {
      this.$store.commit('game/discardFirstBoxNotification');
    },
  },
  mounted() {
    interval = setInterval(() => {
      const now = Date.now();

      this.textNotifs.forEach((notif) => {
        if (now - notif.timestamp > 30000) {
          this.$store.commit('game/discardTextNotification', notif.id);
        }
      });
    }, 1000);
  },
  beforeDestroy() {
    clearInterval(interval);
  },
  components: {
    NotifDispatcher,
  },
};
</script>

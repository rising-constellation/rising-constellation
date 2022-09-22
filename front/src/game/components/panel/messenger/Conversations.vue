<template>
  <v-scrollbar class="has-padding">
    <h1 class="panel-default-title">
      {{ $t('panel.messenger.messenger') }}
      <div class="group-button">
        <div
          class="button squared"
          @click="$emit('new', 'conversation')">
          <div>+</div>
        </div>
        <div
          class="button"
          @click="$emit('new', 'group')">
          <div>{{ $t('panel.messenger.new.group') }}</div>
        </div>
      </div>
    </h1>

    <div
      v-for="(conversation, cid) in conversations"
      :key="cid"
      class="conversation-item"
      :class="{ 'is-active': conversation.unread > 0 }"
      @click="$emit('open', conversation.id)">
      <span
        v-show="conversation.unread > 0"
        class="conversation-item-unread">
        {{ conversation.unread }}
      </span>
      <span
        v-html="getConversationName(conversation)"
        class="conversation-item-name">
      </span>
      <span class="conversation-item-date">
        {{ conversation.last_message_update | datetime-long }}
      </span>
    </div>
  </v-scrollbar>
</template>

<script>
export default {
  name: 'conversations',
  computed: {
    instanceId() { return this.$store.state.game.auth.instance; },
    conversations() { return this.$store.getters['portal/conversations'](this.instanceId); },
    profile() { return this.$store.state.game.player; },
  },
  methods: {
    getConversationName(conversation) {
      if (conversation.is_group) {
        return `${conversation.name} (${conversation.members.length})`;
      }

      const member = conversation.members.find((m) => m.iid !== this.profile.id);
      const player = this.$store.state.game.galaxy.players[member.iid];
      const theme = this.$store.getters['game/themeByKey'](player.faction);

      return `<span class="is-color-${theme}">${member.name}</span>`;
    },
  },
};
</script>

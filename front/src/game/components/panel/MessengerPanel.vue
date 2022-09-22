<template>
  <div
    class="panel-container is-left"
    :class="theme"
    @click.self="close">
    <div class="panel-navbar">
      <button
        v-for="panel in panels"
        v-tooltip.right="$t(`panel.messenger.${panel}`)"
        :key="panel"
        :class="{ 'is-active': activePanel === panel }"
        @click="activePanel = panel">
      </button>
    </div>

    <div class="panel-content is-small">
      <conversations
        v-show="mode === 'conversations'"
        @open="openConversation"
        @new="newConversation" />

      <conversation
        v-if="mode === 'conversation'"
        :conversationId="openConversationId"
        @close="closeConversation" />

      <new-conversation
        v-if="mode === 'new'"
        :mode="newMode"
        :initialPlayer="initialPlayer"
        @open="openConversation"
        @close="closeConversation" />
    </div>
  </div>
</template>

<script>
import Conversations from '@/game/components/panel/messenger/Conversations.vue';
import Conversation from '@/game/components/panel/messenger/Conversation.vue';
import NewConversation from '@/game/components/panel/messenger/NewConversation.vue';

export default {
  name: 'messenger-panel',
  data() {
    return {
      activePanel: 'messenger',
      panels: ['messenger'],
      mode: 'conversations',
      openConversationId: null,
      newMode: null,
      initialPlayer: {},
    };
  },
  computed: {
    theme() { return this.$store.getters['game/theme']; },
  },
  methods: {
    async open(initial) {
      if (initial && initial.initConversation) {
        this.$socket.global
          .push('get_player', { player_id: initial.initConversation })
          .receive('ok', ({ player }) => {
            this.newConversation('conversation');
            this.initialPlayer = player;
          });
      }
    },
    openConversation(conversationId) {
      this.openConversationId = conversationId;
      this.$socket.profile.push('read_conv', { cid: conversationId });
      this.mode = 'conversation';
    },
    closeConversation() {
      this.openConversationId = null;
      this.mode = 'conversations';
    },
    newConversation(mode) {
      this.newMode = mode;
      this.initialPlayer = {};
      this.mode = 'new';
    },
    close() {
      this.closeConversation();
      this.$emit('close');
    },
  },
  components: {
    Conversations,
    Conversation,
    NewConversation,
  },
};
</script>

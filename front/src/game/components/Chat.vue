<template>
  <div
    v-show="!mapOverlay"
    class="chat-container">
    <div class="chat-input-box">
      <input
        v-model="newChatMessage"
        @keyup.enter="sendChatMessage"
        :placeholder="$t('in_game_chat.placeholder')"
        class="chat-input" />
    </div>

    <div
      class="chat-messages"
      :class="`show-${visibleLinesCount}-lines`">
      <div
        v-for="(message, i) in reversedChat"
        :key="i"
        class="chat-message">
        <strong>{{ message.from }}</strong>
        {{ message.message }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'chat',
  data() {
    return {
      newChatMessage: '',
    };
  },
  computed: {
    mapOverlay() { return this.$store.state.game.mapOverlay; },
    faction() { return this.$store.state.game.faction; },
    player() { return this.$store.state.game.player; },
    reversedChat() { return this.faction.chat.slice(0).reverse(); },
    visibleLinesCount() {
      return this.$store.state.game.selectedSystem
        ? 1 : 5;
    },
  },
  watch: {
    reversedChat() {
      this.$ambiance.sound('new-chat-message');
    },
  },
  methods: {
    sendChatMessage() {
      if (this.newChatMessage.length > 0) {
        this.$socket.faction.push('push_chat_message', {
          from: this.player.name,
          message: this.newChatMessage,
        }).receive('ok', () => {
          this.newChatMessage = '';
        }).receive('error', (data) => {
          this.$toastError(data.reason);
        });
      }
    },
  },
};
</script>

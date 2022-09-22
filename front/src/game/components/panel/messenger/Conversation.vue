<template>
  <v-scrollbar
    @ps-y-reach-end="loadConversationNextPage"
    class="has-padding">
    <h1 class="panel-default-title">
      {{ getConversationName(conversation) }}
      <div
        v-show="view === 'message'"
        class="group-button">
        <div
          v-if="conversation.is_group && !conversation.is_faction"
          class="button squared"
          @click="view = 'settings'">
          <div><svgicon name="options" /></div>
        </div>
        <div
          class="button"
          @click="$emit('close')">
          <div>{{ $t('panel.messenger.return') }}</div>
        </div>
      </div>
      <div
        v-show="view === 'settings'"
        class="group-button">
        <div
          class="button"
          @click="view = 'message'">
          <div>{{ $t('panel.messenger.return') }}</div>
        </div>
      </div>
    </h1>

    <template v-if="view === 'message'">
      <div class="conversation-form-textarea">
        <textarea
          :placeholder="$t('panel.messenger.your_message')"
          v-model="newMessage">
        </textarea>
      </div>
      <div class="conversation-form-button">
        <button
          :disabled="isInputLocked"
          @click="sendMessage">
          <div>{{ $t('panel.messenger.send') }}</div>
        </button>
      </div>

      <div
        v-for="message in conversation.messages"
        class="message-item"
        :key="`message-${message.id}`">
        <div class="message-item-metadata">
          <strong
            v-html="getPlayerTheme(message.name, message.pid)"
            @click="openPlayer(message.pid)">
          </strong>,
          {{ message.date | datetime-long }}
        </div>
        <div
          class="message-item-content"
          v-html="message.content_html">
        </div>
      </div>

      <div
        class="message-item"
        v-if="isLoadingMessage && !conversation.messages.length">
        <div class="message-item-loading">
          {{ $t('panel.messenger.loading') }}
        </div>
      </div>
    </template>
    <template v-else>
      <div
        v-for="member in conversation.members"
        class="pcb-player"
        :key="member.id">
        <div class="squared">
          <span
            v-tooltip="$t('panel.messenger.admin')"
            v-show="member.is_admin">
            ♦
          </span>
        </div>
        <div
          @click="openPlayer(member.iid)"
          class="large">
          <strong>{{ member.name }}</strong>
        </div>
        <div class="squared">
          <span
            @click="removePlayer(member.iid)"
            v-tooltip="$t('panel.messenger.remove_from_group')"
            v-show="isConversationAdmin && !member.is_admin && conversation.members.length > 2">
            ×
          </span>
        </div>
      </div>

      <template v-if="isConversationAdmin">
        <div class="conversation-form-select">
          <profile-select
            :instanceId="instanceId"
            :initials="factionProfiles"
            :discardedIds="conversation.members.map((m) => m.iid)"
            v-model="newMember" />
        </div>

        <div class="conversation-form-button">
          <button
            :disabled="isInputLocked"
            @click="addMember">
            <div>{{ $t('panel.messenger.add_to_group') }}</div>
          </button>
        </div>
      </template>
    </template>
  </v-scrollbar>
</template>

<script>
import ProfileSelect from '@/game/components/generic/ProfileSelect.vue';

export default {
  name: 'conversation',
  data() {
    return {
      newMessage: '',
      isInputLocked: false,
      isLoadingMessage: false,
      view: 'message',
      newMember: null,
    };
  },
  props: {
    conversationId: Number,
  },
  computed: {
    instanceId() { return this.$store.state.game.auth.instance; },
    conversation() { return this.$store.getters['portal/conversation'](this.conversationId); },
    profile() { return this.$store.state.game.player; },
    isConversationAdmin() {
      return this.conversation.members.find((m) => m.iid === this.profile.id).is_admin;
    },
    factionProfiles() {
      return this.$store.state.game.faction.players.map((p) => ({ label: p.name, id: p.id }));
    },
  },
  methods: {
    async loadConversation(conversationId) {
      this.isLoadingMessage = true;
      await this.$store.dispatch('portal/loadConversation', conversationId);
      this.isLoadingMessage = false;
    },
    async loadConversationNextPage() {
      if (this.view === 'message' && this.conversation && !this.isLoadingMessage && !this.conversation.isLastPage) {
        this.isLoadingMessage = true;
        await this.$store.dispatch('portal/loadConversation', this.conversation.id);
        this.isLoadingMessage = false;
      }
    },
    async sendMessage() {
      if (!this.isInputLocked && this.newMessage !== '') {
        const message = this.newMessage;
        this.isInputLocked = true;
        this.newMessage = '';
        await this.$axios.post(`/messenger/${this.profile.id}/${this.conversationId}`, { content_raw: message });
        this.isInputLocked = false;
      }
    },
    async addMember() {
      if (!this.isInputLocked && this.newMember) {
        const newMember = this.newMember.id;
        this.isInputLocked = true;
        this.newMember = null;
        const { data } = await this.$axios.put(`/messenger/${this.profile.id}/${this.conversationId}/add/${newMember}`);

        this.$store.commit(
          'portal/updateConversationMembers',
          { id: data.conversation.id, members: data.conversation.members },
        );

        this.isInputLocked = false;
      }
    },
    async removePlayer(playerId) {
      if (!this.isInputLocked && playerId) {
        this.isInputLocked = true;
        const { data } = await this.$axios.delete(`/messenger/${this.profile.id}/${this.conversationId}/remove/${playerId}`);

        this.$store.commit(
          'portal/updateConversationMembers',
          { id: data.conversation.id, members: data.conversation.members },
        );

        this.isInputLocked = false;
      }
    },
    getConversationName(conversation) {
      return conversation.is_group
        ? `${conversation.name} (${conversation.members.length})`
        : conversation.members.find((m) => m.iid !== this.profile.id).name;
    },
    getPlayerTheme(name, pid) {
      if (!pid) return name;

      const player = this.$store.state.game.galaxy.players[pid];
      const theme = this.$store.getters['game/themeByKey'](player.faction);
      return `<span class="is-color-${theme}">${name}</span>`;
    },
    openPlayer(playerId) {
      this.$store.dispatch('game/openPlayer', { vm: this, id: playerId });
    },
  },
  mounted() {
    this.loadConversation(this.conversationId);
  },
  components: {
    ProfileSelect,
  },
};
</script>

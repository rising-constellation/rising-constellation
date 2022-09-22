<template>
  <default-layout>
    <div class="fluid-panel">
      <v-scrollbar class="panel-aside">
        <a
          v-for="(conversation, cid) in conversations"
          :key="cid"
          class="panel-aside-conversation"
          :class="{ 'is-active': conversation.id === openConversationId }"
          @click="openConversation(conversation.id)">
          <span
            v-show="conversation.unread > 0"
            class="item-unread">
            {{ conversation.unread }}
          </span>
          <span class="item-name">
            {{ getConversationName(conversation) }}
          </span>
          <span class="item-date">
            {{ conversation.last_message_update | datetime-long }}
          </span>
        </a>
        <hr class="margin">
      </v-scrollbar>

      <div
        v-if="mode === 'conversation' && openConversationId === null"
        class="panel-content is-square"
        ref="container">
        <div class="panel-header">
          <h1>{{ $t('page.messenger.messenger') }}</h1>

          <button
            class="default-button"
            v-tooltip="$t('page.messenger.new_conversation')"
            @click="mode = 'new_conversation'">
            +
          </button>
          <button
            style="margin-left: 20px"
            class="default-button"
            @click="mode = 'new_group'">
            {{ $t('page.messenger.new_group') }}
          </button>
        </div>
        <div class="full-sized-text">
          {{ $t('page.messenger.empty_state') }}
        </div>
      </div>

      <div
        v-else-if="mode === 'conversation'"
        class="panel-content is-square"
        ref="container">
        <div
          @click="openConversationId = null"
          class="close-button">
          {{ $t('page.instance.back') }}
        </div>
        <div class="panel-header">
          <h1><strong>{{ getConversationName(conversation) }}</strong></h1>
        </div>
        <v-scrollbar
          @ps-y-reach-end="loadConversationNextPage"
          class="content">
          <div
            style="margin-bottom: 10px"
            class="default-input">
            <label for="message">{{ $t('page.messenger.answer') }}</label>
            <textarea
              id="message"
              style="height: 65px"
              v-model="message">
            </textarea>
          </div>

          <a
            href="#"
            class="default-button"
            :class="{ 'disabled': !isValid }"
            style="margin-bottom: 20px"
            @click="sendMessage">
            <template v-if="waiting">...</template>
            <template v-else>{{ $t('page.messenger.send') }}</template>
          </a>

          <div>
            <div
              v-for="message in conversation.messages"
              class="conversation-message"
              :class="{ 'is-own': message.pid === activeProfile.id }"
              :key="`message-${message.id}`">
              <div class="conversation-message-header">
                <strong>{{ message.name }}</strong>
                <span>{{ message.date | datetime-long }}</span>
              </div>
              <div v-html="message.content_html"></div>
            </div>
          </div>
        </v-scrollbar>

      </div>

      <div
        v-else
        class="panel-content is-square"
        ref="container">
        <div
          @click="mode = 'conversation'"
          class="close-button">
          {{ $t('page.instance.back') }}
        </div>
        <div class="panel-header">
          <h1>{{ $t(`page.messenger.${mode}`) }}</h1>

          <button
            class="default-button"
            :disabled="!isValid"
            @click="create">
            <template v-if="waiting">...</template>
            <template v-else>{{ $t('page.messenger.create') }}</template>
          </button>
        </div>
        <v-scrollbar class="content">
          <template v-if="mode === 'new_group'">
            <div class="default-input">
              <label for="name">
                {{ $t('page.messenger.group_name') }}
                <span>{{ name.length }}/120</span>
              </label>
              <input
                type="text"
                id="name"
                v-model="name" />
            </div>

            <input-profile-select
              :label="$t('page.messenger.add_profiles')"
              :multiple="true"
              :discardedIds="[activeProfile.id]"
              v-model="members" />
          </template>
          <template v-else>
            <input-profile-select
              :label="$t('page.messenger.add_profile')"
              :discardedIds="[activeProfile.id]"
              v-model="member"/>
          </template>
          <div class="default-input">
            <label for="message">
              {{ $t('page.messenger.first_message') }}
            </label>
            <textarea
              id="message"
              v-model="message">
            </textarea>
          </div>
        </v-scrollbar>
      </div>

      <v-scrollbar class="panel-aside">
        <template v-if="openConversationId">
          <section class="panel-aside-members">
            <div
              v-for="member in conversation.members"
              class="member"
              :key="member.id">
              <div class="name">
                {{ member.name }}
                <span
                  v-tooltip="$t('page.messenger.admin')"
                  v-show="member.is_admin">
                  ♦
                </span>
              </div>
              <div
                class="action"
                @click="removeMember(member.iid)"
                v-tooltip="$t('page.messenger.remove_from_group')"
                v-show="isConversationAdmin && !member.is_admin && conversation.members.length > 2">
                ×
              </div>
            </div>
          </section>

          <div
            v-if="isConversationAdmin"
            class="panel-aside-bloc">
            <input-profile-select
              :label="'Ajoutez un profil'"
              :discardedIds="conversation.members.map((m) => m.iid)"
              v-model="newMember" />

            <button
              class="default-button"
              @click="addMember">
              <div>{{ $t('page.messenger.add_from_group') }}</div>
            </button>
          </div>
        </template>
        <hr class="margin">
      </v-scrollbar>
    </div>
  </default-layout>
</template>

<script>
import DefaultLayout from '@/portal/layouts/Default.vue';
import InputProfileSelect from '@/portal/components/InputProfileSelect.vue';

export default {
  name: 'messenger',
  data() {
    return {
      mode: 'conversation',
      openConversationId: null,
      member: null,
      members: [],
      message: '',
      name: '',
      waiting: false,
      isLoadingMessage: false,
      newMember: null,
    };
  },
  computed: {
    isValid() {
      if (this.mode === 'new_conversation') {
        return this.member && this.message;
      }

      if (this.mode === 'new_group') {
        return this.members.length > 0 && this.name && this.name.length <= 120 && this.message;
      }

      if (this.mode === 'conversation') {
        return this.message;
      }

      return false;
    },
    activeProfile() { return this.$store.state.portal.activeProfile; },
    conversations() { return this.$store.getters['portal/conversations'](); },
    conversation() {
      return this.openConversationId
        ? this.$store.getters['portal/conversation'](this.openConversationId)
        : null;
    },
    isConversationAdmin() {
      return this.openConversationId
        ? this.conversation.members.find((m) => m.iid === this.activeProfile.id).is_admin
        : false;
    },
  },
  methods: {
    async openConversation(conversationId) {
      this.isLoadingMessage = true;

      await this.$store.dispatch('portal/loadConversation', conversationId);

      this.isLoadingMessage = false;
      this.mode = 'conversation';
      this.openConversationId = conversationId;
    },
    async loadConversationNextPage() {
      if (this.mode === 'conversation' && this.openConversationId
          && !this.isLoadingMessage && !this.conversation.isLastPage) {
        this.isLoadingMessage = true;
        await this.$store.dispatch('portal/loadConversation', this.conversation.id);
        this.isLoadingMessage = false;
      }
    },
    async sendMessage() {
      if (this.isValid && !this.waiting) {
        const message = this.message;
        this.waiting = true;
        this.message = '';

        await this.$axios
          .post(`/messenger/${this.activeProfile.id}/${this.openConversationId}`, { content_raw: message });

        this.waiting = false;
      }
    },
    async create() {
      if (this.isValid && !this.waiting) {
        this.waiting = true;

        if (this.mode === 'new_conversation') {
          const message = this.message;
          const toPlayer = this.member.id;
          this.message = '';
          this.member = null;

          const { data } = await this.$axios.post(
            `/messenger/new/${this.activeProfile.id}`,
            { content_raw: message, to: toPlayer },
          );

          this.openConversation(data.cid);
        } else if (this.mode === 'new_group') {
          const message = this.message;
          const name = this.name;
          const membersId = this.members.map((m) => m.id);
          this.message = '';
          this.name = '';
          this.members = [];

          const { data } = await this.$axios.post(
            `/messenger/new/${this.activeProfile.id}/group`,
            { profiles_ids: membersId, name, content_raw: message },
          );

          this.openConversation(data.cid);
        }

        this.waiting = false;
      }
    },
    async addMember() {
      if (this.newMember) {
        const newMember = this.newMember.id;
        this.newMember = null;
        const { data } = await this.$axios
          .put(`/messenger/${this.activeProfile.id}/${this.openConversationId}/add/${newMember}`);

        this.$store.commit(
          'portal/updateConversationMembers',
          { id: data.conversation.id, members: data.conversation.members },
        );
      }
    },
    async removeMember(memberId) {
      if (memberId) {
        const { data } = await this.$axios
          .delete(`/messenger/${this.activeProfile.id}/${this.openConversationId}/remove/${memberId}`);

        this.$store.commit(
          'portal/updateConversationMembers',
          { id: data.conversation.id, members: data.conversation.members },
        );
      }
    },
    getConversationName(conversation) {
      return conversation.is_group
        ? `${conversation.name} (${conversation.members.length})`
        : conversation.members.find((m) => m.iid !== this.activeProfile.id).name;
    },
  },
  components: {
    DefaultLayout,
    InputProfileSelect,
  },
};
</script>

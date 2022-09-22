<template>
  <v-scrollbar class="has-padding">
    <h1 class="panel-default-title">
      {{ $t(`panel.messenger.new.${mode}`) }}
      <div
        class="button"
        @click="$emit('close')">
        <div>{{ $t('panel.messenger.return') }}</div>
      </div>
    </h1>

    <template v-if="mode === 'group'">
      <div class="conversation-form-input">
        <input
          :placeholder="$t('panel.messenger.group_name')"
          v-model="name">
      </div>

      <label
        for="isFaction"
        class="conversation-form-checkbox">
        <input
          type="checkbox"
          id="isFaction"
          v-model="isFaction">
        {{ $t('panel.messenger.faction_group') }}
      </label>

      <div
        v-show="!isFaction"
        class="conversation-form-select">
        <profile-select
          :instanceId="instanceId"
          :initials="factionProfiles"
          :discardedIds="[profile.id]"
          :multiple="true"
          v-model="members" />
      </div>
    </template>

    <template v-else>
      <div class="conversation-form-select">
        <template v-if="initialPlayer.id">
          {{ $t('panel.messenger.contact_player', { player: initialPlayer.name }) }}
        </template>

        <profile-select
          v-else
          :instanceId="instanceId"
          :initials="factionProfiles"
          :discardedIds="[profile.id]"
          v-model="member" />
      </div>
    </template>

    <div class="conversation-form-textarea">
      <textarea
        :placeholder="$t('panel.messenger.your_message')"
        v-model="message">
      </textarea>
    </div>

    <div class="conversation-form-button">
      <button
        :disabled="isInputLocked"
        @click="create">
        <div>{{ $t('panel.messenger.send') }}</div>
      </button>
    </div>
  </v-scrollbar>
</template>

<script>
import ProfileSelect from '@/game/components/generic/ProfileSelect.vue';

export default {
  name: 'new-conversation',
  data() {
    return {
      member: null,
      members: [],
      message: '',
      name: '',
      isFaction: false,
      isInputLocked: false,
    };
  },
  props: {
    mode: String,
    initialPlayer: Object,
  },
  computed: {
    instanceId() { return parseInt(this.$store.state.game.auth.instance, 10); },
    profile() { return this.$store.state.game.player; },
    factionProfiles() {
      return this.$store.state.game.faction.players.map((p) => ({ label: p.name, id: p.id }));
    },
  },
  methods: {
    async create() {
      if (this.isInputLocked || this.message === '') return;

      if (this.mode === 'conversation') {
        let toPlayer = null;

        if (this.initialPlayer && this.initialPlayer.id) {
          toPlayer = this.initialPlayer.id;
        } else {
          if (!this.member) return;
          toPlayer = this.member.id;
        }

        if (!toPlayer) return;

        const message = this.message;
        this.isInputLocked = true;
        this.message = '';

        const { data } = await this.$axios.post(
          `/messenger/new/${this.profile.id}/${this.instanceId}`,
          { content_raw: message, to: toPlayer },
        );

        this.$emit('open', data.cid);
        this.isInputLocked = false;
      } else if (this.mode === 'group') {
        if (!this.name || (!this.isFaction && this.members.length === 0)) return;

        const message = this.message;
        const name = this.name;
        const membersId = this.members.map((m) => m.id);

        const payload = this.isFaction
          ? { profiles_ids: [], name, content_raw: message, faction: this.$store.state.game.faction.id }
          : { profiles_ids: membersId, name, content_raw: message };

        this.isInputLocked = true;
        this.message = '';
        this.name = '';

        const { data } = await this.$axios
          .post(`/messenger/new/${this.profile.id}/${this.instanceId}/group`, payload);

        this.$emit('open', data.cid);
        this.isInputLocked = false;
      }
    },
  },
  components: {
    ProfileSelect,
  },
};
</script>

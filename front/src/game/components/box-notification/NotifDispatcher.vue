<template>
  <component
    :is="`${(notification.key).replace(/[_]/g, '-') }-notif`"
    :data="notification.data" />
</template>

<script>
import InfiltrationNotif from '@/game/components/box-notification/InfiltrationNotif.vue';
import AssassinationNotif from '@/game/components/box-notification/AssassinationNotif.vue';
import MakeDominionNotif from '@/game/components/box-notification/MakeDominionNotif.vue';
import EncourageHateNotif from '@/game/components/box-notification/EncourageHateNotif.vue';
import ConversionNotif from '@/game/components/box-notification/ConversionNotif.vue';
import SabotageNotif from '@/game/components/box-notification/SabotageNotif.vue';
import ColonizationNotif from '@/game/components/box-notification/ColonizationNotif.vue';
import ConquestNotif from '@/game/components/box-notification/ConquestNotif.vue';
import RaidNotif from '@/game/components/box-notification/RaidNotif.vue';
import LootNotif from '@/game/components/box-notification/LootNotif.vue';
import FightNotif from '@/game/components/box-notification/FightNotif.vue';

export default {
  name: 'notif-dispatcher',
  props: {
    notification: Object,
  },
  components: {
    InfiltrationNotif,
    AssassinationNotif,
    MakeDominionNotif,
    EncourageHateNotif,
    ConversionNotif,
    SabotageNotif,
    ColonizationNotif,
    ConquestNotif,
    RaidNotif,
    LootNotif,
    FightNotif,
  },
};
</script>

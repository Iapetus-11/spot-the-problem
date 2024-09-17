<script setup lang="ts">
    import { faSpinnerThird } from '@fortawesome/pro-solid-svg-icons';
    import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
</script>

<template>
    <FontAwesomeIcon
        :icon="faSpinnerThird"
        class="animate-spin text-6xl text-verdigris-base"
        fixed-width
    />
</template>

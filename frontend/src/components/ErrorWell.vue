<script setup lang="ts">
    const emit = defineEmits<{
        retry: [];
    }>();
</script>

<template>
    <div class="flex flex-col gap-2 items-center max-w-[20rem]">
        <p class="text-center text-bittersweet-base">Oops... something went wrong while loading this content :/</p>
        <button type="button" class="button" @click="emit('retry')">Retry</button>
    </div>
</template>

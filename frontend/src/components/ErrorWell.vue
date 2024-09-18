<script setup lang="ts">
    const emit = defineEmits<{
        retry: [];
    }>();
</script>

<template>
    <div class="flex max-w-[20rem] flex-col items-center gap-2">
        <p class="text-center text-salmon-base">
            Oops... something went wrong while loading this content :/
        </p>
        <button type="button" class="button" @click="emit('retry')">Retry</button>
    </div>
</template>

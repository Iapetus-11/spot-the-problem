<script setup lang="ts">
    import { faLeft } from '@fortawesome/pro-regular-svg-icons';
    import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
</script>

<template>
    <Transition name="fade" appear>
        <div class="mt-[25vh] flex w-full flex-col items-center gap-3">
            <h2 class="text-3xl text-bittersweet-base">404 Page Not Found</h2>

            <a href="/" class="button">
                <FontAwesomeIcon :icon="faLeft" class="mr-2" />
                Go Back Home
            </a>
        </div>
    </Transition>
</template>

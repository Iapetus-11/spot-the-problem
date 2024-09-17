<script setup lang="ts">
    import { listProblemSets } from '@/services/api/problemSets';
    import { type AsyncDataState } from '@/utils';
    import { onBeforeMount, onUnmounted, reactive } from 'vue';
    import LoadingSpinner from '@/components/LoadingSpinner.vue';
    import ErrorWell from '@/components/ErrorWell.vue';

    const problemSetsState = reactive<AsyncDataState<string[]>>({
        loading: false,
        error: null,
        data: null,
        cancel: null,
    });
    async function loadProblemSets() {
        const { data, cancel } = listProblemSets();

        problemSetsState.cancel = cancel;
        problemSetsState.loading = true;
        
        try {
            problemSetsState.data = await data;
        } catch (error) {
            console.error(error);
            problemSetsState.error = error;
        }
        
        problemSetsState.loading = false;
    }

    onBeforeMount(() => {
        loadProblemSets();
    });

    onUnmounted(() => {
        problemSetsState.cancel?.();
    });
</script>

<template>
    <Transition name="fade" mode="out-in">
        <div v-if="problemSetsState?.loading" class="flex justify-center mt-[35vh] -translate-y-1/2">
            <LoadingSpinner />
        </div>
        <div v-else-if="problemSetsState?.error" class="flex justify-center mt-[35vh] -translate-y-1/2">
            <ErrorWell @retry="loadProblemSets" />
        </div>
        <div v-else class="flex gap-6 p-6">
            <a
                v-for="problemSetName in problemSetsState!.data"
                :key="problemSetName"
                class="card cursor-pointer p-14 text-xl tracking-widest uppercase"
                :href="`problem-set/${problemSetName}`"
            >
                {{ problemSetName }}
            </a>
        </div>
    </Transition>
</template>

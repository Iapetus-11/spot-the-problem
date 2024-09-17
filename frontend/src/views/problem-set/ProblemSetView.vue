<script setup lang="ts">
    import { listProblems, type ProblemInfo } from '@/services/api/problemSets';
    import type { AsyncDataState } from '@/utils';
    import { onBeforeMount, onUnmounted, reactive } from 'vue';

    const props = defineProps({
        problemSetName: { type: String, required: true },
    });

    const problemsState = reactive<AsyncDataState<ProblemInfo[]>>({
        loading: false,
        error: null,
        data: null,
        cancel: null,
    });
    async function loadProblems() {
        const { data, cancel } = listProblems(props.problemSetName);
        
        problemsState.loading = true;
        problemsState.cancel = cancel;
        
        try {
            problemsState.data = await data;
        } catch (error) {
            console.error(error);
            problemsState.error = error;
        }

        problemsState.loading = false;
    }

    onBeforeMount(() => {
        loadProblems();
    });

    onUnmounted(() => {
        problemsState.cancel?.();
    });
</script>

<template>
    <Transition name="fade" mode="out-in">
        <div v-if="problemsState?.loading" class="flex justify-center mt-[35vh] -translate-y-1/2">
            <LoadingSpinner />
        </div>
        <div v-else-if="problemsState?.error" class="flex justify-center mt-[35vh] -translate-y-1/2">
            <ErrorWell @retry="loadProblems" />
        </div>
        <div v-else class="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6 p-6">
            <div
                v-for="problem in problemsState.data"
                :key="problem.difficulty"
                class="card p-4"
            >
                <div class="flex justify-between gap-2 uppercase tracking-widest">
                    <p class="text-xl">{{ problem.name }}</p>
                    <p class="text-sm">#{{ problem.category }}</p>
                </div>
                <p>{{ problem.description }}</p>
            </div>
        </div>
    </Transition>
</template>

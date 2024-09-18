<script setup lang="ts">
    import { listProblems, type ProblemInfo } from '@/services/api/problemSets';
    import type { AsyncDataState } from '@/utils';
    import { onBeforeMount, onUnmounted, reactive } from 'vue';
    import LoadingSpinner from '@/components/LoadingSpinner.vue';
    import ErrorWell from '@/components/ErrorWell.vue';

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
        <div v-if="problemsState?.loading" class="mt-[35vh] flex -translate-y-1/2 justify-center">
            <LoadingSpinner />
        </div>
        <div
            v-else-if="problemsState?.error"
            class="mt-[35vh] flex -translate-y-1/2 justify-center"
        >
            <ErrorWell @retry="loadProblems" />
        </div>
        <div v-else class="grid grid-cols-1 gap-6 p-6 md:grid-cols-2 xl:grid-cols-3">
            <a
                v-for="problem in problemsState.data"
                :key="problem.difficulty"
                :href="`/problem-set/${problemSetName}/${problem.id}`"
                class="card card-hoverable cursor-pointer p-4"
            >
                <div class="flex justify-between gap-2 uppercase tracking-widest">
                    <p class="text-xl">#{{ problem.id }} {{ problem.name }}</p>
                    <p class="text-sm">({{ problem.category }})</p>
                </div>
                <p>{{ problem.description }}</p>
            </a>
        </div>
    </Transition>
</template>

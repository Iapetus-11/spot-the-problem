<script setup lang="ts">
    import { getProblem, type ProblemInfo } from '@/services/api/problemSets';
    import type { AsyncDataState } from '@/utils';
    import { onBeforeMount, onUnmounted, reactive, ref } from 'vue';
    import LoadingSpinner from '@/components/LoadingSpinner.vue';
    import ErrorWell from '@/components/ErrorWell.vue';

    const props = defineProps({
        problemSetName: { type: String, required: true },
        problemId: { type: String, required: true },
    });

    const problemState = reactive<AsyncDataState<ProblemInfo>>({
        loading: false,
        error: null,
        data: null,
        cancel: null,
    });
    const problemLines = ref<{ id: number, content: string }[]>()
    async function loadProblem() {
        const { data, cancel } = getProblem(props.problemSetName, props.problemId);

        problemState.loading = true;
        problemState.cancel = cancel;

        try {
            problemState.data = await data;
        } catch (error) {
            console.error(error);
            problemState.error = error;
        }

        problemState.loading = false;

        problemLines.value = problemState.data?.content.split('\n').map((line, idx) => ({ id: idx, content: (line + '\n') }));
    }

    const problemCodeContainer = ref();

    const selectedLine = ref();
    const answerJustification = ref('');

    onBeforeMount(() => {
        loadProblem();
    });

    onUnmounted(() => {
        problemState.cancel?.();
    });

    window.addEventListener('mousemove', () => {
        console.log(window.getSelection());
    })
</script>

<template>
    <Transition name="fade" mode="out-in">
        <div v-if="problemState?.loading" class="mt-[35vh] flex -translate-y-1/2 justify-center">
            <LoadingSpinner />
        </div>
        <div v-else-if="problemState?.error" class="mt-[35vh] flex -translate-y-1/2 justify-center">
            <ErrorWell @retry="loadProblem" />
        </div>
        <div v-else class="flex flex-col gap-6 p-6">
            <div>
                <p class="text-cerulean-base">
                    {{ problemState.data!.description }}
                </p>
                <p class="text-sm text-cerulean-base">
                    Select the line with the problem and justify your answer on the right.
                </p>
            </div>

            <div class="flex gap-6">
                <code ref="problemCodeContainer" class="flex flex-col py-2 pl-3 pr-0 card whitespace-pre overflow-x-auto w-full">
                    <span
                        v-for="{ id, content } in problemLines"
                        :key="id"
                        class="hover:bg-peach-base hover:text-cerulean-base w-full transition-colors rounded-md -ml-1.5 pl-1.5 cursor-pointer"
                        :class="{'bg-peach-base text-cerulean-base': selectedLine === id}"
                        @click="selectedLine === id ? selectedLine = null : selectedLine = id"
                    >
                        <span class="mr-1 opacity-50">{{ id.toString().padStart(2, '0') }}</span>
                        {{ content }}
                    </span>
                </code>

                <div class="card min-w-[33%] px-3 py-2">
                    <p v-if="selectedLine !== null" class="mb-1">Please explain the problem on line {{ selectedLine }}:</p>
                    <textarea v-model="answerJustification" class="bg-transparent w-full h-full"></textarea>
                </div>
            </div>
        </div>
    </Transition>
</template>

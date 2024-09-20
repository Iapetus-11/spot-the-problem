<script setup lang="ts">
    import { getProblem, type ProblemInfo } from '@/services/api/problemSets';
    import type { AsyncDataState } from '@/utils';
    import { onBeforeMount, onUnmounted, reactive, ref, watch } from 'vue';
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
    const problemLines = ref<{ id: number; content: string }[]>();
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

        problemLines.value = problemState.data?.content
            .split('\n')
            .map((line, idx) => ({ id: idx, content: line + '\n' }));
    }

    const problemCodeContainerElement = ref<HTMLElement>();
    const answerJustificationElement = ref<HTMLTextAreaElement>();

    const selectedLine = ref<number | null>(null);
    const answerJustification = ref('');

    function handleLineClick(lineId: number) {
        if (selectedLine.value === lineId) {
            selectedLine.value = null;
        } else {
            selectedLine.value = lineId;
        }
    }

    watch(answerJustificationElement, (answerJustificationElement) => {
        answerJustificationElement?.focus();
    });

    function clearAnswer() {
        answerJustification.value = '';
        selectedLine.value = null;
    }

    function submit() {
        console.log('submit!');
    }

    onBeforeMount(() => {
        loadProblem();
    });

    onUnmounted(() => {
        problemState.cancel?.();
    });
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
                    Select the line with the problem and justify your answer in the other box.
                </p>
            </div>

            <div class="flex gap-6 max-lg:flex-col">
                <code
                    ref="problemCodeContainerElement"
                    class="card flex w-full flex-col overflow-x-auto whitespace-pre py-2 pl-3 pr-0"
                >
                    <span
                        v-for="{ id, content } in problemLines"
                        :key="id"
                        class="-ml-1.5 w-full cursor-pointer rounded-md pl-1.5 transition-colors hover:bg-peach-base hover:text-cerulean-base"
                        :class="{ 'bg-peach-base text-cerulean-base': selectedLine === id }"
                        @click="handleLineClick(id)"
                    >
                        <span class="mr-1 opacity-50">{{ id.toString().padStart(2, '0') }}</span>
                        {{ content }}
                    </span>
                </code>

                <form @submit.prevent="submit" class="flex min-w-[33%] flex-col gap-3">
                    <div class="card relative h-full min-h-[200px] w-full px-3 py-2">
                        <TransitionGroup name="fade">
                            <p
                                v-if="selectedLine === null"
                                class="absolute left-1/2 top-1/2 min-w-[90%] -translate-x-1/2 -translate-y-1/2 text-center"
                            >
                                Select a line on the left, then type in your answer here.
                            </p>

                            <template v-else>
                                <div class="flex h-full flex-col pb-10">
                                    <p class="mb-1">
                                        Please explain the problem on line {{ selectedLine }}:
                                    </p>

                                    <textarea
                                        v-model="answerJustification"
                                        class="answer-justification-textarea h-full w-full resize-none bg-transparent placeholder:text-white placeholder:opacity-50"
                                        ref="answerJustificationElement"
                                        placeholder="Type here..."
                                    >
                                    </textarea>
                                </div>

                                <div
                                    class="-mr-5 ml-auto flex w-fit gap-3 rounded-md bg-egg-base p-2.5 mt-7 max-lg:-mb-10 lg:-mt-10"
                                >
                                    <button
                                        type="button"
                                        @click="clearAnswer"
                                        class="button whitespace-nowrap"
                                    >
                                        Clear Answer
                                    </button>

                                    <button type="button" class="button whitespace-nowrap">
                                        Show Answer
                                    </button>
                                </div>
                            </template>
                        </TransitionGroup>
                    </div>
                </form>
            </div>
        </div>
    </Transition>
</template>

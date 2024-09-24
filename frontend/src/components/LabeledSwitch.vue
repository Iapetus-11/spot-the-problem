<script setup lang="ts" generic="T">
    import { reactive, ref, watch } from 'vue';

    const props = withDefaults(defineProps<{
        options: Array<{ label: string, value: T }>;
        cellClass?: string;
        disabled?: boolean;
        coverClass?: string;
        disabledCoverClass?: string;
    }>(), {
        cellClass: '',
        disabled: false,
        coverClass: 'bg-blue-700',
        disabledCoverClass: 'bg-blue-400',
    });

    const modelValue = defineModel<T>();

    const selectedLabel = ref(props.options.find(o => o.value === modelValue.value)?.label ?? props.options[0].label);
    const optionElements = reactive<Record<string, Element>>({});

    watch(selectedLabel, () => {
        modelValue.value = props.options.find(o => o.label === selectedLabel.value)!.value;
    }, { immediate: true });
</script>

<template>
    <div
        class="relative flex items-center bg-white rounded-full border border-gray-300 font-medium shadow-sm
               leading-tight"
    >
        <button
            v-for="{ label } in options"
            :key="label"
            @click="selectedLabel = label"
            type="button"
            :ref="(el) => (optionElements[label] = el as Element)"
            class="p-2 px-3 transition z-10 disabled:cursor-not-allowed"
            :class="[selectedLabel === label ? 'text-white outline-blue-300' : 'text-gray-700', cellClass]"
            :style="{ width: `${100 / options.length}%` }"
            :disabled="disabled"
        >
            {{ label }}
        </button>

        <div
            v-if="optionElements[selectedLabel]"
            class="absolute left-0 top-0 h-full rounded-full transform duration-150 ease-out shadow-md"
            :class="disabled ? disabledCoverClass : coverClass"
            :style="{
                width: `${100 / options.length}%`,
                transform: `translateX(${100 * options.findIndex(o => o.label === selectedLabel)}%)`
            }"
        />
    </div>
</template>

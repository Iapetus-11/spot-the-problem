import { ref, type Ref } from "vue";

export interface AsyncState<T> {
    value: Ref<T | undefined>;
    error: Ref<Error | undefined>;
    loading: Ref<boolean>;
    promise: Promise<T>;
}

/**
 * Create reactive state for a promise
 * @returns Refs relating to the state of the promise
 */
export function useAsyncState<T>(promise: Promise<T>): AsyncState<T> {
    promise = Promise.resolve(promise); // Make sure we're dealing with a promise

    const state: AsyncState<T> = {
        value: ref(undefined),
        error: ref(undefined),
        loading: ref(true),
        promise,
    };

    promise.then(
        (val) => {
            state.value.value = val;
            state.loading.value = false;
        },
        (err) => {
            state.error.value = err;
            state.loading.value = false;
        },
    );

    return state;
}
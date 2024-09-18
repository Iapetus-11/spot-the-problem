export type AsyncDataState<T> = {
    loading: boolean;
    error: any;
    data: T | null;
    cancel: (() => void) | null;
};

import { reactive, ref, type App, type Ref } from 'vue';
import { login as _login } from './services/api/login';
import type { AsyncDataState } from './utils';

export type Auth = {
    loginState: AsyncDataState<string>;
    login: (username: string, password: string) => void;
    loginHash: Ref<string>;
};

function auth() {
    const loginHash = ref(localStorage.getItem('login-hash'));

    function setloginHash(v: string) {
        loginHash.value = v;
        localStorage.setItem('login-hash', v);
    }

    const loginState = reactive<AsyncDataState<string>>({
        loading: false,
        error: null,
        data: null,
        cancel: null,
    });
    async function login(username: string, password: string) {
        loginState.loading = true;

        const { data, cancel } = _login(username, password);
        loginState.cancel = cancel;

        try {
            loginState.data = await data;
            setloginHash(loginState.data);
        } catch (error) {
            console.error(error);
            loginState.error = error;
        }

        loginState.loading = false;
    }

    return {
        loginState,
        login,
        loginHash,
    };
}

function install(app: App) {
    app.provide('auth', auth());
}

export default {
    install,
};

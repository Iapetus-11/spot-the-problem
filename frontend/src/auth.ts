import { reactive, ref, type App } from "vue"
import { useAsyncState } from "./utils";

async function _logIn(username: string, password: string): Promise<string> {
        const response = fetch(import.meta.env.VITE_API_BASE_URL, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ username, password }),
        })

        return response.then(res => res.json()).then(res => res.login_hash);
    }

function auth() {
    const loginState = ref();
    function logIn(username: string, password: string) {
        loginState.value = useAsyncState(_logIn(username, password));
    }

    return {
        loginState,
        logIn,
    }
}

function install(app: App) {
    app.provide('auth', auth());
}

export default {
    install,
}
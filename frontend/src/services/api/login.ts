import { request, type FetchResponseValue } from '../requests';

export function login(username: string, password: string): FetchResponseValue<string> {
    const { response, cancel } = request('POST', new URL(`/api/login`, window.location.origin), {
        body: { username, password },
    });

    return { data: response.then((res) => res.json()), cancel };
}
